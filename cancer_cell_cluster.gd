extends Node2D


const COHESION: float = 0.1
const MOVEMENT_SMOOTHING: float = 0.1  # 0 < and < 1.
const ROTATION_SMOOTHING: float = 0.99  # 0 < and < 1.
const TORQUE_STRENGTH: float = 500.0


@export var cell_scene: PackedScene
@onready var first_cell: RigidBody2D = %FirstCell
@onready var smoothed_position: Vector2 = position
var movement_force: Vector2 = Vector2.ZERO
var rotation_vector: Vector2 = Vector2.UP


func get_cells_average_position():
    return Math.avg(get_children().map(func (cell): return cell.position))


func get_exponential_moving_average_position(new_smoothed_position):
    if new_smoothed_position == null:
        return smoothed_position
    return (
        MOVEMENT_SMOOTHING * smoothed_position
        + (1.0 - MOVEMENT_SMOOTHING) * new_smoothed_position
    )


func on_cell_created(new_cell: RigidBody2D, from_cell: RigidBody2D):
    new_cell.sibling_created.connect(on_cell_created)
    new_cell.has_bottom_flagellum = from_cell.has_bottom_flagellum
    from_cell.has_bottom_flagellum = false


func _ready():
    first_cell.animation = "Idle"


func _physics_process(_delta):
    var average_position = get_cells_average_position()
    smoothed_position = get_exponential_moving_average_position(average_position)
    for cell in get_children():
        var total_movement = movement_force + COHESION * (average_position - (position + cell.position))
        cell.apply_force(total_movement)
        cell.set_animation_for_movement(total_movement)
        cell.apply_torque(
            ROTATION_SMOOTHING * cell.constant_torque
            + (1.0 - ROTATION_SMOOTHING) * TORQUE_STRENGTH * (
                Vector2.RIGHT.rotated(cell.rotation).dot(rotation_vector)
            )
        )
