extends RigidBody2D


const TYPE: String = "RedBloodCell"


func take_damage(damage: float):
    return %HealthComponent.take_damage(damage)


func _on_health_component_died():
    queue_free()
