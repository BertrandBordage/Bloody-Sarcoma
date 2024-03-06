extends Node2D

@export var spawnable_scenes: Array[PackedScene]
@export var spawnable_probabilities: Array[float]
const ACCELERATION = 1.0
const ZOOM_SMOOTHING = 0.995  # 0 < and < 1.
const MIN_ZOOM = Vector2(0.5, 0.5)
const MAX_ZOOM = Vector2(3.0, 3.0)
const MAX_SPAWNED = 500
@onready var initial_zoom = %Camera2D.zoom
@onready var smoothed_zoom: Vector2 = initial_zoom


func _process(delta):
    if %Spawned.get_child_count() < MAX_SPAWNED:
        %SpawnerPathFollow.progress_ratio = randf()
        var spawned = Math.choice(spawnable_scenes, spawnable_probabilities).instantiate()
        spawned.rotation = randf_range(-PI, PI)
        %Spawned.add_child(spawned)
        spawned.global_position = %SpawnerPathFollow.global_position


func _physics_process(_delta):
    if Input.is_action_just_pressed("ui_accept"):
        %CellCluster.add_cell()
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    %CellCluster.movement_force = ACCELERATION * direction
    var smoothed_position = %CellCluster.smoothed_position
    var viewport = get_viewport()
    var viewport_size = viewport.get_visible_rect().size
    %CellCluster.look_at = (
        (viewport.get_mouse_position() - viewport_size / 2) / viewport_size
    ).normalized()
    %Camera2D.position = smoothed_position
    smoothed_zoom = (
        ZOOM_SMOOTHING * smoothed_zoom
        + (1.0 - ZOOM_SMOOTHING) * (
            initial_zoom / (1.0 + %CellCluster.movement_force.length())).clamp(MIN_ZOOM, MAX_ZOOM)
    )
    %Camera2D.zoom = smoothed_zoom
    %SpawningPath.scale = initial_zoom / smoothed_zoom
    %LoadedArea.scale = initial_zoom / smoothed_zoom


func _on_loaded_area_body_exited(body):
    body.queue_free()
