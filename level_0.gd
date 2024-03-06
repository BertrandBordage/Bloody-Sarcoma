extends Node2D

const SPEED = 200.0

func _ready():
    Heartbeat.start()


func _physics_process(_delta):
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if direction == Vector2.ZERO:
        %Cell.animation = "Idle"
    elif abs(direction.y) >= abs(direction.x):
        %Cell.animation = "Forward" if direction.y > 0 else "Backwards"
    else:
        %Cell.animation = "Right" if direction.x > 0 else "Left"
    %CellCluster.position += SPEED * direction * _delta
    %Camera2D.position = %CellCluster.get_average_position()
