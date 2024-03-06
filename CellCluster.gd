extends Node2D


const COHESION: float = 0.1
const MOVEMENT_SMOOTHING: float = 0.1  # 0 < and < 1.
const ROTATION_SMOOTHING: float = 0.99  # 0 < and < 1.
const TORQUE_STRENGTH: float = 500.0


@export var cell_scene: PackedScene
@onready var first_cell: RigidBody2D = %FirstCell
@onready var cells: Array[RigidBody2D] = [first_cell]
@onready var smoothed_position: Vector2 = position
var movement_force: Vector2 = Vector2.ZERO
var look_at: Vector2 = Vector2.UP


func avg(values: Array):
    return values.reduce(func (a, b): return a + b) / len(cells)


func get_cells_average_position():
    return avg(
        cells.map(func (cell): return cell.position)
    )


func get_exponential_moving_average_position():
    var new_smoothed_position = get_cells_average_position()
    return (
        MOVEMENT_SMOOTHING * smoothed_position
        + (1.0 - MOVEMENT_SMOOTHING) * new_smoothed_position
    )


func on_cell_created(new_cell: RigidBody2D):
    new_cell.sibling_created.connect(on_cell_created)
    new_cell.set_random_mutations()
    cells.append(new_cell)


func add_cell():
    var candidate_cells = cells.filter(func (cell): return cell.can_perform_mitosis())
    if len(candidate_cells) == 0:
        return
    var cell = candidate_cells[randi_range(0, len(candidate_cells) - 1)]
    cell.start_mitosis()


func _ready():
    first_cell.animation = "Idle"


func _physics_process(_delta):
    smoothed_position = get_exponential_moving_average_position()
    var average_position = get_cells_average_position()
    var look_at_angle = 0 if look_at == Vector2.ZERO else look_at.angle() + PI / 2
    for cell in cells:
        var total_movement = movement_force + COHESION * (average_position - (position + cell.position))
        cell.apply_force(total_movement)
        cell.set_animation_for_movement(total_movement)
        cell.apply_torque(
            ROTATION_SMOOTHING * cell.constant_torque
            + (1.0 - ROTATION_SMOOTHING) * TORQUE_STRENGTH * (
                Vector2.RIGHT.rotated(cell.rotation).dot(look_at)
            )
        )
