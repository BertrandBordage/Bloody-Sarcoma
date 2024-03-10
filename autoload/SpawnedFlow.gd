extends Node


const MAX_SPAWNED = 600
const PATH_SEARCH_OFFSET_INTERVAL: float = 10.0
const VELOCITY_MULTIPLIER = 100.0
var spawn_container: Node2D
var spawned_bodies: Array[RigidBody2D] = []
var flow_paths: Array[FlowPath] = []
var flow_velocity: Vector2 = Vector2.ZERO
var spawn_exclusion_global_position: Vector2
var spawn_exclusion_polygon: PackedVector2Array
var spawnable_scenes: Array[PackedScene] = [
    load("res://lymphocyte.tscn"),
    load("res://red_blood_cell.tscn"),
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


func find_closest_point_outside_spawn_exclusion(curve: Curve2D, from_position: Vector2, offset: float):
    var is_start: bool = true
    var point: Vector2
    while offset > 0:
        point = from_position + curve.sample_baked(offset)
        if not Geometry2D.is_point_in_polygon(point, spawn_exclusion_polygon):
            if is_start:
                # The path is not even in view.
                # Do not use it as a candidate for spawning.
                return "outside"
            return point
        offset -= PATH_SEARCH_OFFSET_INTERVAL
        is_start = false
    return null


func get_spawn_position(paths: Array, initial: bool = false):
    if initial:
        # TODO: Implement and call this on program start.
        pass
    # Take a path randomly.
    paths.shuffle()
    for path in paths:
        var curve = path.curve
        var point = find_closest_point_outside_spawn_exclusion(
            curve,
            path.global_position,
            curve.get_closest_offset(spawn_exclusion_global_position),
        )
        if point is String and point == "outside":
            # The path is not even in view, skip to the next path.
            continue
        if point == null:
            # Start from the end, in case the curve was looping.
            point = find_closest_point_outside_spawn_exclusion(
                curve,
                path.global_position,
                curve.get_baked_length(),  # End offset.
            )
        return point


func spawn_random(paths: Array, initial: bool = false):
    if spawned_bodies.size() >= MAX_SPAWNED:
        return

    var spawn_position = get_spawn_position(paths, initial)
    if spawn_position == null:
        return

    var spawned = Math.choice(spawnable_scenes, spawnable_probabilities).instantiate()
    spawned.rotation = randf_range(-PI, PI)
    spawned.linear_velocity = flow_velocity * VELOCITY_MULTIPLIER
    spawn_container.add_child.call_deferred(spawned)
    spawned.set_deferred("global_position", spawn_position)


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
    var visible_paths = flow_paths.filter(
        func (flow_path: FlowPath): return flow_path.is_visible()
    ).map(func (flow_path: FlowPath): return flow_path.path)

    spawn_random(visible_paths)
    move_bodies_in_flow(visible_paths)
