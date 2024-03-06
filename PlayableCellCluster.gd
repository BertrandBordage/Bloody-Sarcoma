extends Node2D


const ACCELERATION = 500.0


func _physics_process(_delta):
    if Input.is_action_just_pressed("ui_accept"):
        %CellCluster.add_cell()
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    %CellCluster.movement_force = ACCELERATION * direction
    %Camera2D.position = %CellCluster.smoothed_position
