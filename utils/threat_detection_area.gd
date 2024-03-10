extends Area2D


signal threat_started
signal threat_ended

@export var speed: float = 1.0
@export var flee: bool = false
@onready var body: RigidBody2D = get_parent()
var threat_detected: bool = false


func _physics_process(_delta):
    var target_direction: Vector2 = Vector2.ZERO
    var target_distance: float = INF
    for detected_body in get_overlapping_bodies():
        var direction: Vector2 = detected_body.global_position - body.global_position
        var distance: float = direction.length()
        if distance < target_distance:
            target_direction = direction
            target_distance = distance
    if target_direction != Vector2.ZERO:
        if flee:
            target_direction = -target_direction
        body.apply_force(speed * target_direction.normalized())
        Utils.rotate_via_torque(body, target_direction)


func _on_body_entered(_body):
    if not threat_detected:
        threat_detected = true
        threat_started.emit()


func _on_body_exited(_body):
    if get_overlapping_bodies().is_empty():
        threat_detected = false
        threat_ended.emit()
