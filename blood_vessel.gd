extends Node2D


const MAX_SPAWNED = 500
const VELOCITY_MULTIPLIER = 100.0
const PATH_SEARCH_OFFSET_INTERVAL: float = 10.0
@export var spawnable_scenes: Array[PackedScene]
@export var spawnable_probabilities: Array[float]
@onready var paths: Array[Node] = %Paths.get_children()
var lymphocyte_probability: float:
    get:
        return spawnable_probabilities[0]
    set(value):
        spawnable_probabilities[0] = value

# TODO: Spawn cells all AFTER the path as well. Ideally make the before/after decision based on current velocity.
# TODO: Spawn non-player cancer cells depending on how many were dropped in a given area.


func find_closest_point_outside_spawn_exclusion(curve: Curve2D, from_position: Vector2, offset: float):
    var is_start: bool = true
    var point: Vector2
    while offset > 0:
        point = from_position + curve.sample_baked(offset)
        if not Geometry2D.is_point_in_polygon(point, SpawnedFlow.spawn_exclusion_polygon):
            if is_start:
                # The path is not even in view.
                # Do not use it as a candidate for spawning.
                return "outside"
            return point
        offset -= PATH_SEARCH_OFFSET_INTERVAL
        is_start = false
    return null


func get_spawn_position(initial: bool = false):
    if initial:
        # FIXME: Rewrite this and call it in `_ready`.
        var area_size: Vector2 = %LoadedAreaShape.shape.get_rect().size
        return (
            %LoadedAreaShape.global_position
            + Vector2(randf() - 0.5, randf() - 0.5) * area_size
        )
    # Take a path randomly.
    paths.shuffle()
    for path in paths:
        var curve = path.curve
        var point = find_closest_point_outside_spawn_exclusion(
            curve,
            path.global_position,
            curve.get_closest_offset(SpawnedFlow.spawn_exclusion_global_position),
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


func spawn_random(initial: bool = false):
    if %Spawned.get_child_count() >= MAX_SPAWNED:
        return

    var spawn_position = get_spawn_position(initial)
    if spawn_position == null:
        return

    var spawned = Math.choice(spawnable_scenes, spawnable_probabilities).instantiate()
    spawned.rotation = randf_range(-PI, PI)
    spawned.linear_velocity = SpawnedFlow.flow_velocity * VELOCITY_MULTIPLIER
    %Spawned.add_child.call_deferred(spawned)
    spawned.set_deferred("global_position", spawn_position)


func _ready():
    create_tween().tween_property(self, "lymphocyte_probability", 4.0, 240).set_delay(20)


func _process(_delta):
    spawn_random()

    for body in SpawnedFlow.spawned_bodies:
        var closest_curve: Curve2D
        var closest_point: Vector2
        var closest_distance: float = INF

        for path in paths:
            var point = path.global_position + path.curve.get_closest_point(body.global_position)
            var distance = (point - body.global_position).length()
            if distance < closest_distance:
                closest_point = point
                closest_curve = path.curve
                closest_distance = distance

        var offset = closest_curve.get_closest_offset(body.global_position)
        var flow_rotation: float = closest_curve.sample_baked_with_rotation(offset).get_rotation()
        body.apply_force(
            Heartbeat.blood_pressure * Vector2.UP.rotated(flow_rotation)
        )
