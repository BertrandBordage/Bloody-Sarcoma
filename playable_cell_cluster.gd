extends Node2D

const ACCELERATION = 2.0
const ZOOM_SMOOTHING = 0.998  # 0 < and < 1.
const MIN_ZOOM = Vector2(1.5, 1.5)
const MAX_ZOOM = Vector2(3.0, 3.0)
@onready var initial_zoom = %Camera2D.zoom
@onready var smoothed_zoom: Vector2 = initial_zoom


func _ready():
    SpawnedFlow.spawn_container = %Spawned
    PlayerData.cluster = %CancerCellCluster
    PlayerData.cooldown_timer = %ThreatLevelCooldown


func _process(_delta):
    if Input.is_action_just_pressed("metastasize"):
        PlayerData.metastasize()

    %MetastasizeUI.visible = %CancerCellCluster.get_child_count() > 1

    var smoothed_position = %CancerCellCluster.smoothed_position
    %Camera2D.position = smoothed_position
    smoothed_zoom = (
        ZOOM_SMOOTHING * smoothed_zoom
        + (1.0 - ZOOM_SMOOTHING) * (
            initial_zoom / (1.0 + SpawnedFlow.player_speed)
        ).clamp(MIN_ZOOM, MAX_ZOOM)
    )
    %Camera2D.zoom = smoothed_zoom
    var areas_scale = initial_zoom / smoothed_zoom
    %LoadedArea.scale = areas_scale
    %SpawnExclusionShape.scale = areas_scale
    SpawnedFlow.spawn_exclusion_global_position = %SpawnExclusionShape.global_position
    SpawnedFlow.spawn_exclusion_polygon = %SpawnExclusionShape.global_transform * %SpawnExclusionShape.polygon


func _physics_process(_delta):
    var direction: Vector2
    if PlayerData.use_mouse:
        var viewport: Viewport = get_viewport()
        var viewport_size: Vector2 = viewport.get_visible_rect().size
        direction = (
            (viewport.get_mouse_position() - viewport_size / 2) / viewport_size
        )
        # Multiply by 5 to make it possible to reach top speed
        # without going to the edge of the screen.
        direction = (direction * 5).limit_length(1.0)
    else:
        direction = Input.get_vector("left", "right", "up", "down")

    if direction != Vector2.ZERO:
        %CancerCellCluster.movement_force = ACCELERATION * direction
        %CancerCellCluster.rotation_vector = direction


func _on_loaded_area_body_exited(body):
    SpawnedFlow.respawn_if_possible(body)


func _on_metastasize_button_pressed():
    PlayerData.metastasize()
