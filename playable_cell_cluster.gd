extends Node2D

const ACCELERATION = 1.0
const ZOOM_SMOOTHING = 0.995  # 0 < and < 1.
const MIN_ZOOM = Vector2(0.5, 0.5)
const MAX_ZOOM = Vector2(3.0, 3.0)
@onready var initial_zoom = %Camera2D.zoom
@onready var smoothed_zoom: Vector2 = initial_zoom
@onready var spawn_exclusion_global_transform: Transform2D
@onready var spawn_exclusion_polygon: PackedVector2Array
var available_mutations: int = 0


func _process(_delta):
    spawn_exclusion_global_transform = %SpawnExclusionShape.global_transform
    spawn_exclusion_polygon = spawn_exclusion_global_transform * %SpawnExclusionShape.polygon
    var count: int = 0
    var needs_mouths: bool = false
    var needs_top_flagellums: bool = false
    var needs_bottom_flagellums: bool = false
    var needs_flow_controls: bool = false
    for cell in %CancerCellCluster.get_children():
        count += 1
        if not cell.has_mouth:
            needs_mouths = true
        if not cell.has_top_flagellum:
            needs_top_flagellums = true
        if not cell.has_bottom_flagellum:
            needs_bottom_flagellums = true
        if not cell.has_flow_control:
            needs_flow_controls = true
        if (
            count > 1
            and needs_mouths
            and needs_top_flagellums and needs_bottom_flagellums
            and needs_flow_controls
        ):
            break

    %SacrificeUI.visible = count > 1
    %MutateUI.visible = count > 0 and available_mutations > 0
    %MouthButton.disabled = not needs_mouths
    %TopFlagellumButton.disabled = not needs_top_flagellums
    %BottomFlagellumButton.disabled = not needs_bottom_flagellums
    %FlowControlButton.disabled = not needs_flow_controls

    var smoothed_position = %CancerCellCluster.smoothed_position
    %Camera2D.position = smoothed_position
    smoothed_zoom = (
        ZOOM_SMOOTHING * smoothed_zoom
        + (1.0 - ZOOM_SMOOTHING) * (
            initial_zoom / (1.0 + %CancerCellCluster.movement_force.length())
        ).clamp(MIN_ZOOM, MAX_ZOOM)
    )
    %Camera2D.zoom = smoothed_zoom
    %SpawningPath.scale = initial_zoom / smoothed_zoom
    %SpawnExclusionShape.scale = initial_zoom / smoothed_zoom


func _physics_process(_delta):
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    %CancerCellCluster.movement_force = ACCELERATION * direction
    var viewport = get_viewport()
    var viewport_size = viewport.get_visible_rect().size
    %CancerCellCluster.rotation_vector = (
        (viewport.get_mouse_position() - viewport_size / 2) / viewport_size
    ).normalized()


func _on_loaded_area_body_exited(body):
    body.queue_free()


func get_least_mutated_cell():
    var min_mutations: int = 100
    var candidate = null
    for cell in %CancerCellCluster.get_children():
        var mutations_count = cell.get_mutations_count()
        if mutations_count == 0:
            return cell
        if mutations_count < min_mutations:
            min_mutations = mutations_count
            candidate = cell
    return candidate


func _on_sacrifice_pressed():
    var cell = get_least_mutated_cell()
    if cell == null:
        return
    var sacrificed_cell = cell.duplicate()
    create_tween().tween_property(sacrificed_cell, "modulate:v", 0.75, 1.0)
    sacrificed_cell.animation = "Idle"
    %Spawned.add_child(sacrificed_cell)
    cell.queue_free()
    available_mutations += 1


func _on_top_flagellum_pressed():
    for cell in %CancerCellCluster.get_children():
        if not cell.has_top_flagellum:
            cell.has_top_flagellum = true
            available_mutations -= 1
            return


func _on_bottom_flagellum_pressed():
    for cell in %CancerCellCluster.get_children():
        if not cell.has_bottom_flagellum:
            cell.has_bottom_flagellum = true
            available_mutations -= 1
            return


func _on_mouth_pressed():
    for cell in %CancerCellCluster.get_children():
        if not cell.has_mouth:
            cell.has_mouth = true
            available_mutations -= 1
            return


func _on_flow_control_pressed():
    for cell in %CancerCellCluster.get_children():
        if not cell.has_flow_control:
            cell.has_flow_control = true
            available_mutations -= 1
            return
