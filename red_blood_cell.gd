extends RigidBody2D


func _ready():
    SpawnedFlow.spawned_bodies.append(self)


func _exit_tree():
    SpawnedFlow.spawned_bodies.erase(self)


func take_damage(damage: float):
    return %HealthComponent.take_damage(damage)


func _on_health_component_died():
    queue_free()
