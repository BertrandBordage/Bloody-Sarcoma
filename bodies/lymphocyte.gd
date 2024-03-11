extends RigidBody2D


const NAME = "Lymphocyte"


func _ready():
    SpawnedFlow.spawned_bodies.append(self)


func _exit_tree():
    SpawnedFlow.spawned_bodies.erase(self)


func take_damage(damage: float):
    return %HealthComponent.take_damage(damage)


func reset_for_respawn():
    %HealthComponent.reset_for_respawn()


func _on_health_component_died():
    SpawnedFlow.respawn_if_possible(self)


func _on_presence_notifier_screen_entered():
    %Presence.play()


func _on_presence_notifier_screen_exited():
    %Presence.stop()
    %PresenceEnd.play()
