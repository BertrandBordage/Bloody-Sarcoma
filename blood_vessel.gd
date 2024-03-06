extends Area2D


var entered_bodies = []
var in_membrane_bodies = []


func _process(_delta):
    var curve: Curve2D = $Path2D.curve
    for body in get_overlapping_bodies():
        if body is RigidBody2D:
            if body not in in_membrane_bodies:
                body.collision_mask |= 0b10
            var offset = curve.get_closest_offset(body.global_position)
            var rotation: float = curve.sample_baked_with_rotation(offset).get_rotation()
            body.apply_force(Heartbeat.blood_pressure * Vector2.UP.rotated(rotation))


func _on_body_exited(body):
    if body is RigidBody2D:
        body.collision_mask &= ~0b10


func _on_membrane_area_body_entered(body):
    if body is RigidBody2D and body not in in_membrane_bodies:
        in_membrane_bodies.append(body)


func _on_membrane_area_body_exited(body):
    if body in in_membrane_bodies:
        in_membrane_bodies.erase(body)
