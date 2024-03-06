extends Node2D


const COHESION: float = 100.0
const MOVEMENT_SMOOTHING: float = 0.1  # 0 < and < 1.


@export var cell_scene: PackedScene
@onready var first_cell: RigidBody2D = %FirstCell
@onready var cells: Array[RigidBody2D] = [first_cell]
@onready var smoothed_position: Vector2 = position
var movement_force: Vector2 = Vector2.ZERO


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


func set_cells_animation():
    var defaultAnimation: String
    if movement_force == Vector2.ZERO:
        defaultAnimation = "Idle"
    elif abs(movement_force.y) >= abs(movement_force.x):
        defaultAnimation = "Forward" if movement_force.y > 0 else "Backwards"
    else:
        defaultAnimation = "Right" if movement_force.x > 0 else "Left"
    for cell in cells:
        if cell.animation in ["Idle", "Forward", "Backwards", "Left", "Right"]:
            cell.animation = defaultAnimation


func _process(delta):
    set_cells_animation()


func _physics_process(delta):
    smoothed_position = get_exponential_moving_average_position()
    var average_position = get_cells_average_position()
    for cell in cells:
        cell.apply_force(movement_force)
        cell.apply_force(COHESION * (average_position - (position + cell.position)))
