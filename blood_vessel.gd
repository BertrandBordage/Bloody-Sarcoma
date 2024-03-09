extends Node2D


const MAX_SPAWNED = 500
const VELOCITY_MULTIPLIER = 100.0
@export var spawnable_scenes: Array[PackedScene]
@export var spawnable_probabilities: Array[float]
var spawn_exclusion_global_transform: Transform2D
var spawn_exclusion_polygon: PackedVector2Array
@onready var curve: Curve2D = %Path2D.curve


# TODO: Spawn cells all AFTER the path as well. Ideally make the before/after decision based on current velocity.
# TODO: Spawn non-player cancer cells depending on how many were dropped in a given area.


func get_spawn_position(initial: bool = false):
    var spawn_position: Vector2
    if initial:
        # FIXME: Rewrite this and call it in `_ready`.
        var area_size: Vector2 = %LoadedAreaShape.shape.get_rect().size
        spawn_position = (
            %LoadedAreaShape.global_position
            + Vector2(randf() - 0.5, randf() - 0.5) * area_size
        )
    else:
        var offset = curve.get_closest_offset(spawn_exclusion_global_transform.get_origin())
        var point: Vector2
        while offset > 0:
            point = %Path2D.global_position + curve.sample_baked(offset)
            if not Geometry2D.is_point_in_polygon(point, spawn_exclusion_polygon):
                break
            offset -= 10
        spawn_position = point
    return spawn_position


func spawn_random(initial: bool = false):
    if %Spawned.get_child_count() >= MAX_SPAWNED:
        return

    var spawned = Math.choice(spawnable_scenes, spawnable_probabilities).instantiate()
    spawned.rotation = randf_range(-PI, PI)
    spawned.linear_velocity = SpawnedFlow.flow_velocity * VELOCITY_MULTIPLIER
    %Spawned.add_child.call_deferred(spawned)
    spawned.set_deferred("global_position", get_spawn_position(initial))


func _process(_delta):
    spawn_random()

    for body in SpawnedFlow.spawned_bodies:
        if body is RigidBody2D:
            var offset = curve.get_closest_offset(body.global_position)
            var flow_rotation: float = curve.sample_baked_with_rotation(offset).get_rotation()
            body.apply_force(
                Heartbeat.blood_pressure * Vector2.UP.rotated(flow_rotation)
            )
