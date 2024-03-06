extends RigidBody2D


const SPEED = 1000.0
const JUMP_VELOCITY = -400.0


func _physics_process(_delta):
    apply_force(SPEED * Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down"))
