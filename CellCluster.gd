extends Node2D


const COHESION: float = 100.0


@export var cell_scene: PackedScene
var cells: Array[RigidBody2D] = []


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
    var first_cell = cell_scene.instantiate()
    first_cell.sibling_created.connect(on_cell_created)
    first_cell.animation = "Idle"
    add_child(first_cell)
    cells.append(first_cell)


func _process(delta):
    if Input.is_action_just_pressed("ui_accept"):
        add_cell()


func _physics_process(delta):
    for cell in cells:
        cell.apply_force(-cell.position * COHESION)


func get_average_position():
    return cells.map(func (cell): return cell.global_position).reduce(func (a, b): return a + b) / len(cells)
