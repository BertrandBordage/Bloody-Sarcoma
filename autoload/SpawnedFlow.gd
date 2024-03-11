extends Node


const MAX_SPAWNED = 500
const PATH_SEARCH_OFFSET_INTERVAL: float = 10.0
const UPSTREAM_VELOCITY_MULTIPLIER = 10.0
const DOWNSTREAM_VELOCITY_MULTIPLIER = 5.0
const CLOSEST_CURVE_QUANTIZATION = 20  # pixels
var spawn_container: Node2D
var spawned_bodies: Array[RigidBody2D] = []
var flow_paths: Array[FlowPath] = []
var visible_flow_paths: Array[FlowPath] = []
var visible_paths: Array = []
var player_speed: float = 0.0
var spawn_exclusion_global_position: Vector2
var spawn_exclusion_polygon: PackedVector2Array
var lymphocyte_scene: PackedScene = load("res://bodies/lymphocyte.tscn")
var red_blood_cell_scene: PackedScene = load("res://bodies/red_blood_cell.tscn")
var bacteria_scene: PackedScene = load("res://bodies/bacteria.tscn")
var neutrophil_scene: PackedScene = load("res://bodies/neutrophil.tscn")
var spawnable_scene_names: Array[String] = [
    "Lymphocyte",
    "RedBloodCell",
    "Bacteria",
    "Neutrophil",
]
var spawnable_probabilities: Array[float] = [
    0.0,
    100.0,
    0.25,
    0.5,
]
var lymphocyte_probability: float:
    get:
        return spawnable_probabilities[0]
    set(value):
        spawnable_probabilities[0] = value
var spawned_this_frame: bool = false
var flow_directions_cache: Dictionary = {}


# TODO: Spawn non-player cancer cells depending on how many were dropped in a given area.


func quantize_point(point: Vector2) -> Vector2:
    return round(
        point / CLOSEST_CURVE_QUANTIZATION
    ) * CLOSEST_CURVE_QUANTIZATION


class FlowPath:
    var path: Path2D
    var curve: Curve2D
    var offset_rounding: float
    var bounding_box: PackedVector2Array

    func _init(init_path: Path2D):
        path = init_path
        curve = path.curve
        offset_rounding = round(
            curve.get_baked_length() / curve.get_baked_points().size()
        )
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

    func get_closest_offset(point: Vector2):
        var offset = curve.get_closest_offset(point)
        return round(offset / offset_rounding) * offset_rounding

    func get_point_and_direction(from_point: Vector2):
        var offset = get_closest_offset(from_point)
        var transform = curve.sample_baked_with_rotation(offset)
        var point = path.global_position + transform.origin
        var direction = Vector2.UP.rotated(transform.get_rotation())
        return [point, direction]

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


func get_spawn_position(downstream: bool = false, initial: bool = false):
    if initial:
        # TODO: Implement and call this on program start.
        pass
    # Take a path randomly.
    visible_paths.shuffle()
    for path in visible_paths:
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


func spawn_random(body_to_respawn = null):
    if spawned_this_frame:
        if body_to_respawn != null:
            body_to_respawn.queue_free()
        return
    # Take a random spawn direction, upstream or downstream.
    var downstream = randf() >= 0.5
    var spawn = get_spawn_position(downstream)
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
            "Bacteria":
                scene = bacteria_scene
            "Neutrophil":
                scene = neutrophil_scene
            _:
                push_warning("Unknown scene name %s" % scene_name)
                return
        spawned = scene.instantiate()
        spawn_container.add_child.call_deferred(spawned)
        # We don’t use global_position due to this bug: https://github.com/godotengine/godot/issues/74323
        spawned.set_deferred("global_transform", Transform2D(randf_range(-PI, PI), spawn.origin))
    else:
        spawned = body_to_respawn
        spawned.reset_for_respawn()
        # We don’t use global_position due to this bug: https://github.com/godotengine/godot/issues/74323
        spawned.global_transform.origin = spawn.origin
        spawned.rotation = randf_range(-PI, PI)

    spawned.linear_velocity = Vector2.UP.rotated(
        spawn.get_rotation() + randf_range(-PI/2, PI/2)
    ) * Heartbeat.blood_pressure * (
        DOWNSTREAM_VELOCITY_MULTIPLIER if downstream
        else UPSTREAM_VELOCITY_MULTIPLIER
    )
    spawned.angular_velocity = randf() - 0.5
    spawned_this_frame = true


func get_flow_direction(body: RigidBody2D) -> Vector2:
    var quantized_point = quantize_point(body.global_position)
    if quantized_point in flow_directions_cache:
        return flow_directions_cache[quantized_point]

    var closest_direction: Vector2
    var closest_distance: float = INF

    for flow_path: FlowPath in visible_flow_paths:
        var point_and_direction = flow_path.get_point_and_direction(quantized_point)
        var point = point_and_direction[0]
        var distance = (point - body.global_position).length()
        if distance < closest_distance:
            closest_direction = point_and_direction[1]
            closest_distance = distance

    if closest_distance == INF:
        closest_direction = Vector2.UP

    flow_directions_cache[quantized_point] = closest_direction
    return closest_direction


func move_bodies_in_flow() -> void:
    for body in spawned_bodies:
        body.apply_force(Heartbeat.blood_pressure * get_flow_direction(body))


func _process(_delta):
    visible_flow_paths = flow_paths.filter(
        func (flow_path: FlowPath): return flow_path.is_visible()
    )
    visible_paths = visible_flow_paths.map(
        func (flow_path: FlowPath): return flow_path.path
    )

    if not spawned_this_frame:
        spawn_random()
    move_bodies_in_flow()
    spawned_this_frame = false


func respawn_if_possible(body: RigidBody2D):
    spawn_random(body)
