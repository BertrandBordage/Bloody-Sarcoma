extends Node2D

const ACCELERATION = 2.0


func _ready():
    SpawnedFlow.spawn_container = %Spawned
    PlayerData.cluster = %CancerCellCluster
    PlayerData.camera = %Camera2D
    PlayerData.initial_zoom = %Camera2D.zoom
    PlayerData.cooldown_timer = %ThreatLevelCooldown
    PlayerData.initial_zoom_tween()


func _process(_delta):
    if Input.is_action_just_pressed("metastasize"):
        PlayerData.metastasize()

    var count = %CancerCellCluster.get_child_count()

    if count == 0:
        %GameOver.visible = true
        %GameOver.process_mode = PROCESS_MODE_INHERIT
        %GameOverRestartButton.grab_focus()


    %MetastasizeUI.visible = count > 1

    %Camera2D.position = %CancerCellCluster.smoothed_position
    %Camera2D.zoom = PlayerData.smoothed_zoom
    var areas_scale = PlayerData.initial_zoom / PlayerData.smoothed_zoom
    %LoadedArea.scale = areas_scale
    %SpawnExclusionShape.scale = areas_scale
    SpawnedFlow.spawn_exclusion_global_position = %SpawnExclusionShape.global_position
    SpawnedFlow.spawn_exclusion_polygon = %SpawnExclusionShape.global_transform * %SpawnExclusionShape.polygon


func _physics_process(_delta):
    var direction: Vector2
    # TODO: Improve touch controls.
    if PlayerData.use_mouse or PlayerData.use_touch:
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

    %CancerCellCluster.movement_force = ACCELERATION * direction
    %CancerCellCluster.rotation_vector = direction


func _on_loaded_area_body_exited(body):
    SpawnedFlow.respawn_if_possible(body)


func _on_metastasize_button_pressed():
    PlayerData.metastasize()
