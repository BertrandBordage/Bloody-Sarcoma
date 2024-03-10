extends Node


const MAX_SPAWNED = 600
const PATH_SEARCH_OFFSET_INTERVAL: float = 10.0
const VELOCITY_MULTIPLIER = 100.0
var spawn_container: Node2D
var spawned_bodies: Array[RigidBody2D] = []
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


func get_spawn_position(paths: Array[Node], initial: bool = false):
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


func spawn_random(paths: Array[Node], initial: bool = false):
    if spawned_bodies.size() >= MAX_SPAWNED:
        return

    var spawn_position = get_spawn_position(paths, initial)
    if spawn_position == null:
        return

    var spawned = Math.choice(spawnable_scenes, spawnable_probabilities).instantiate()
    spawned.rotation = randf_range(-PI, PI)
    spawned.linear_velocity = flow_velocity * VELOCITY_MULTIPLIER
    SpawnedFlow.spawn_container.add_child.call_deferred(spawned)
    spawned.set_deferred("global_position", spawn_position)
