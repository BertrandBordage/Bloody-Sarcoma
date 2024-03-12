extends Node2D

const ACCELERATION = 2.0
@export var pause_overlay_scene: PackedScene
@export var game_over_scene: PackedScene
var pause_overlay: CanvasLayer


func _ready():
    SpawnedFlow.spawn_container = %Spawned
    PlayerData.cluster = %CancerCellCluster
    PlayerData.camera = %Camera2D
    PlayerData.initial_zoom = %Camera2D.zoom
    PlayerData.cooldown_timer = %ThreatLevelCooldown
    PlayerData.points_container = %PointsContainer
    PlayerData.initial_zoom_tween()


func trigger_pause():
    if pause_overlay:
        pause_overlay.queue_free()
    else:
        if %HelpNotification:
            %HelpNotification.queue_free()
        pause_overlay = pause_overlay_scene.instantiate()
        add_child(pause_overlay)


func _input(event):
    if event is InputEventKey and event.is_action_pressed("pause"):
        trigger_pause()


func _process(_delta):
    if Input.is_action_just_pressed("metastasize"):
        PlayerData.metastasize()

    var count = %CancerCellCluster.get_child_count()

    if count == 0 and not PlayerData.game_over:
        add_child(game_over_scene.instantiate())


    %MetastasizeUI.visible = count > 1

    %Camera2D.position = %CancerCellCluster.smoothed_position
    %Camera2D.zoom = PlayerData.smoothed_zoom
    var areas_scale = PlayerData.initial_zoom / PlayerData.smoothed_zoom
    %LoadedArea.scale = areas_scale
    %SpawnExclusionShape.scale = areas_scale
    SpawnedFlow.spawn_exclusion_global_position = %SpawnExclusionShape.global_position
    SpawnedFlow.spawn_exclusion_polygon = %SpawnExclusionShape.global_transform * %SpawnExclusionShape.polygon

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


func _on_save_timer_timeout():
    PlayerData.save_high_score()
