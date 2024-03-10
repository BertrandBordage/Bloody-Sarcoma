extends Node2D


@onready var paths: Array[Node] = %Paths.get_children()

# TODO: Spawn cells all AFTER the path as well. Ideally make the before/after decision based on current velocity.
# TODO: Spawn non-player cancer cells depending on how many were dropped in a given area.


func _process(_delta):
    SpawnedFlow.spawn_random(paths)

    for body in SpawnedFlow.spawned_bodies:
        var closest_curve: Curve2D
        var closest_distance: float = INF

        for path in paths:
            var point = path.global_position + path.curve.get_closest_point(body.global_position)
            var distance = (point - body.global_position).length()
            if distance < closest_distance:
                closest_curve = path.curve
                closest_distance = distance

        var offset = closest_curve.get_closest_offset(body.global_position)
        var flow_rotation: float = closest_curve.sample_baked_with_rotation(offset).get_rotation()
        body.apply_force(
            Heartbeat.blood_pressure * Vector2.UP.rotated(flow_rotation)
        )
