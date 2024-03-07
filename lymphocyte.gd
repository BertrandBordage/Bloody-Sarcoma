extends RigidBody2D


const SPEED: float = 1.5


func take_damage(damage: float):
    return $HealthComponent.take_damage(damage)


func _on_health_component_died():
    queue_free()


func _physics_process(_delta):
    var target_direction: Vector2 = Vector2.ZERO
    var target_distance: float = INF
    for body in %ThreadDetectionArea.get_overlapping_bodies():
        var direction: Vector2 = body.global_position - global_position
        var distance: float = direction.length()
        if distance < target_distance:
            target_direction = direction
            target_distance = distance
    if target_direction != Vector2.ZERO:
        apply_force(SPEED * target_direction.normalized())
