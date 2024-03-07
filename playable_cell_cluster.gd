extends Node2D

const ACCELERATION = 1.0
const ZOOM_SMOOTHING = 0.995  # 0 < and < 1.
const MIN_ZOOM = Vector2(0.5, 0.5)
const MAX_ZOOM = Vector2(3.0, 3.0)
@onready var initial_zoom = %Camera2D.zoom
@onready var smoothed_zoom: Vector2 = initial_zoom
@onready var spawn_exclusion_global_transform: Transform2D
@onready var spawn_exclusion_polygon: PackedVector2Array


func _process(_delta):
    spawn_exclusion_global_transform = %SpawnExclusionShape.global_transform
    spawn_exclusion_polygon = spawn_exclusion_global_transform * %SpawnExclusionShape.polygon


func _physics_process(_delta):
    if Input.is_action_just_pressed("ui_accept"):
        %CancerCellCluster.add_cell()
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    %CancerCellCluster.movement_force = ACCELERATION * direction
    var smoothed_position = %CancerCellCluster.smoothed_position
    var viewport = get_viewport()
    var viewport_size = viewport.get_visible_rect().size
    %CancerCellCluster.rotation_vector = (
        (viewport.get_mouse_position() - viewport_size / 2) / viewport_size
    ).normalized()
    %Camera2D.position = smoothed_position
    smoothed_zoom = (
        ZOOM_SMOOTHING * smoothed_zoom
        + (1.0 - ZOOM_SMOOTHING) * (
            initial_zoom / (1.0 + %CancerCellCluster.movement_force.length())).clamp(MIN_ZOOM, MAX_ZOOM)
    )
    %Camera2D.zoom = smoothed_zoom
    %SpawningPath.scale = initial_zoom / smoothed_zoom
    %SpawnExclusionShape.scale = initial_zoom / smoothed_zoom


func _on_loaded_area_body_exited(body):
    body.queue_free()
