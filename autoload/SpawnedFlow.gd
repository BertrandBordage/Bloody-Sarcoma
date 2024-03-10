extends Node


const MAX_SPAWNED = 500
const PATH_SEARCH_OFFSET_INTERVAL: float = 10.0
const UPSTREAM_VELOCITY_MULTIPLIER = 10.0
const DOWNSTREAM_VELOCITY_MULTIPLIER = 5.0
var spawn_container: Node2D
var spawned_bodies: Array[RigidBody2D] = []
var flow_paths: Array[FlowPath] = []
var visible_paths: Array = []
var player_speed: float = 0.0
var spawn_exclusion_global_position: Vector2
var spawn_exclusion_polygon: PackedVector2Array
var lymphocyte_scene: PackedScene = load("res://lymphocyte.tscn")
var red_blood_cell_scene: PackedScene = load("res://red_blood_cell.tscn")
var spawnable_scene_names: Array[String] = [
    "Lymphocyte",
    "RedBloodCell",
]
var spawnable_probabilities: Array[float] = [
    0.0,
    100.0,
]
var lymphocyte_probability: float:
    get:
        return spawnable_probabilities[0]
    set(value):
        spawnable_probabilities[0] = value
var spawned_this_frame: bool = false


# TODO: Spawn cells all AFTER the path as well. Ideally make the before/after decision based on current velocity.
# TODO: Spawn non-player cancer cells depending on how many were dropped in a given area.


class FlowPath:
    var path: Path2D
    var curve: Curve2D
    var bounding_box: PackedVector2Array

    func _init(init_path: Path2D):
        path = init_path
        curve = path.curve
        bounding_box = get_bounding_box()

    func get_bounding_box() -> PackedVector2Array:
        var left: float = +INF
        var right: float = -INF
        var top: float = +INF
        var bottom: float = -INF
        var curve_transform: Transform2D = path.global_transform
        for point in curve.get_baked_points():
            point *= curve_transform
            if point.x < left:
                left = point.x
            if point.x > right:
                right = point.x
            if point.y < top:
                top = point.y
            if point.y > bottom:
                bottom = point.y
        return PackedVector2Array([
            Vector2(left, top),
            Vector2(right, top),
            Vector2(right, bottom),
            Vector2(left, bottom),
        ])

    func is_visible() -> bool:
        return Geometry2D.intersect_polygons(
            bounding_box,
            # FIXME: Replace with the loaded polygon, not the exclusion polygon.
            SpawnedFlow.spawn_exclusion_polygon,
        ).size() > 0



func find_closest_point_outside_spawn_exclusion(
    curve: Curve2D, from_position: Vector2, offset: float, downstream: bool = false,
):
    var is_start: bool = true
    var point_with_rotation: Transform2D
    var max_offset = curve.get_baked_length()
    while offset < max_offset if downstream else offset > 0:
        point_with_rotation = curve.sample_baked_with_rotation(offset).translated(from_position)
        if not Geometry2D.is_point_in_polygon(
            point_with_rotation.origin, spawn_exclusion_polygon,
        ):
            if is_start:
                # The path is not even in view.
                # Do not use it as a candidate for spawning.
                return "outside"
            return point_with_rotation
        offset += PATH_SEARCH_OFFSET_INTERVAL if downstream else -PATH_SEARCH_OFFSET_INTERVAL
        is_start = false
    return null


func get_spawn_position(paths: Array, downstream: bool = false, initial: bool = false):
    if initial:
        # TODO: Implement and call this on program start.
        pass
    # Take a path randomly.
    paths.shuffle()
    for path in paths:
        var curve = path.curve
        var point_with_rotation = find_closest_point_outside_spawn_exclusion(
            curve,
            path.global_position,
            curve.get_closest_offset(spawn_exclusion_global_position),
            downstream,
        )
        if point_with_rotation is String and point_with_rotation == "outside":
            # The path is not even in view, skip to the next path.
            continue
        if point_with_rotation == null:
            # Start from the end, in case the curve was looping.
            point_with_rotation = find_closest_point_outside_spawn_exclusion(
                curve,
                path.global_position,
                0.0 if downstream else curve.get_baked_length(),  # End offset.
                downstream,
            )
        return point_with_rotation


func spawn_random(paths: Array, body_to_respawn = null):
    if spawned_this_frame:
        if body_to_respawn != null:
            body_to_respawn.queue_free()
        return
    # Take a random spawn direction, upstream or downstream.
    var downstream = randf() >= 0.5
    var spawn = get_spawn_position(paths, downstream)
    if spawn == null or (spawn is String and spawn == "outside"):
        return

    var scene_name: String = Math.choice(spawnable_scene_names, spawnable_probabilities)
    var spawned: RigidBody2D
    if body_to_respawn == null or scene_name != body_to_respawn.NAME:
        if body_to_respawn != null:
            body_to_respawn.queue_free()

        if spawned_bodies.size() >= MAX_SPAWNED:
            return
        var scene: PackedScene
        match scene_name:
            "Lymphocyte":
                scene = lymphocyte_scene
            "RedBloodCell":
                scene = red_blood_cell_scene
        spawned = scene.instantiate()
        spawn_container.add_child.call_deferred(spawned)
        # We don’t use global_position due to this bug: https://github.com/godotengine/godot/issues/74323
        spawned.set_deferred("global_transform", Transform2D(randf_range(-PI, PI), spawn.origin))
    else:
        spawned = body_to_respawn
        # We don’t use global_position due to this bug: https://github.com/godotengine/godot/issues/74323
        spawned.global_transform.origin = spawn.origin
        spawned.rotation = randf_range(-PI, PI)

    spawned.linear_velocity = Vector2.UP.rotated(
        spawn.get_rotation()
    ) * player_speed * (
        DOWNSTREAM_VELOCITY_MULTIPLIER if downstream
        else UPSTREAM_VELOCITY_MULTIPLIER
    )
    spawned.angular_velocity = 0.0
    spawned_this_frame = true


func move_bodies_in_flow(paths: Array) -> void:
    for body in spawned_bodies:
        var closest_curve: Curve2D
        var closest_distance: float = INF

        for path in paths:
            var point = path.global_position + path.curve.get_closest_point(body.global_position)
            var distance = (point - body.global_position).length()
            if distance < closest_distance:
                closest_curve = path.curve
                closest_distance = distance

        if closest_distance == INF:
            continue

        var offset = closest_curve.get_closest_offset(body.global_position)
        var flow_rotation: float = closest_curve.sample_baked_with_rotation(offset).get_rotation()
        body.apply_force(
            Heartbeat.blood_pressure * Vector2.UP.rotated(flow_rotation)
        )


func _process(_delta):
    visible_paths = flow_paths.filter(
        func (flow_path: FlowPath): return flow_path.is_visible()
    ).map(func (flow_path: FlowPath): return flow_path.path)

    if not spawned_this_frame:
        spawn_random(visible_paths)
    move_bodies_in_flow(visible_paths)
    spawned_this_frame = false


func respawn_if_possible(body: RigidBody2D):
    spawn_random(visible_paths, body)
