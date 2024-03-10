extends RigidBody2D


const NAME = "Bacteria"


func _ready():
    SpawnedFlow.spawned_bodies.append(self)


func _exit_tree():
    SpawnedFlow.spawned_bodies.erase(self)


func take_damage(damage: float):
    return %HealthComponent.take_damage(damage)


func _on_health_component_died():
    SpawnedFlow.respawn_if_possible(self)


func _on_threat_detection_area_threat_started():
    %AnimationPlayer.current_animation = "Fleeing"


func _on_threat_detection_area_threat_ended():
    %AnimationPlayer.current_animation = "Idle"
