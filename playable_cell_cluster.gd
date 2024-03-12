extends Node2D

const ACCELERATION = 2.0
@export var pause_overlay_scene: PackedScene
@export var game_over_scene: PackedScene
var pause_overlay: CanvasLayer
var touch_position
var touch_velocity: Vector2 = Vector2.ZERO


func _ready():
    SpawnedFlow.spawn_container = %Spawned
    PlayerData.cluster = %CancerCellCluster
    PlayerData.camera = %Camera2D
    PlayerData.initial_zoom = %Camera2D.zoom
    PlayerData.cooldown_timer = %ThreatLevelCooldown
    PlayerData.points_container = %PointsContainer
    PlayerData.initial_zoom_tween()


func trigger_pause():
    %TouchJoystick.visible = false
    if pause_overlay:
        pause_overlay.queue_free()
    else:
        if has_node("HelpNotification"):
            %HelpNotification.queue_free()
        pause_overlay = pause_overlay_scene.instantiate()
        add_child(pause_overlay)


func normalize_screen_velocity(
    screen_velocity: Vector2, speed_multiplier: float = 5.0
) -> Vector2:
    var viewport: Viewport = get_viewport()
    var viewport_size: Vector2 = viewport.get_visible_rect().size
    screen_velocity /= viewport_size
    # Multiply to make it possible to reach top speed
    # without going to the edge of the screen.
    return (screen_velocity * speed_multiplier).limit_length(1.0)


func _input(event):
    if event.is_action_pressed("pause"):
        trigger_pause()
    if event is InputEventScreenTouch and event.index == 0:
        if touch_position == null:
            if event.pressed:
                touch_position = event.position
                %TouchJoystick.visible = true
                %TouchJoystick.offset = touch_position
        elif not event.pressed:
            %TouchJoystick.visible = false
            touch_position = null
            touch_velocity = Vector2.ZERO
    elif event is InputEventScreenDrag and event.index == 0 and touch_position != null:
        touch_velocity = normalize_screen_velocity(
            event.position - touch_position,
            8.0,
        )
        %TouchJoystick.offset = (
            touch_position + touch_velocity * 40.0
        )


func _process(_delta):
    if Input.is_action_just_pressed("metastasize"):
        PlayerData.metastasize()

    var count = %CancerCellCluster.get_child_count()

    if count == 0 and not PlayerData.game_over:
        add_child(game_over_scene.instantiate())


    %MetastasizeUI.visible = PlayerData.can_metastasize()

    %Camera2D.position = %CancerCellCluster.smoothed_position
    %Camera2D.zoom = PlayerData.smoothed_zoom
    var areas_scale = PlayerData.initial_zoom / PlayerData.smoothed_zoom
    %LoadedArea.scale = areas_scale
    %SpawnExclusionShape.scale = areas_scale
    SpawnedFlow.spawn_exclusion_global_position = %SpawnExclusionShape.global_position
    SpawnedFlow.spawn_exclusion_polygon = %SpawnExclusionShape.global_transform * %SpawnExclusionShape.polygon

    var direction: Vector2
    if PlayerData.use_mouse:
        var viewport: Viewport = get_viewport()
        var viewport_size: Vector2 = viewport.get_visible_rect().size
        direction = normalize_screen_velocity(
            viewport.get_mouse_position() - viewport_size / 2,
        )
    elif PlayerData.use_touch:
        direction = touch_velocity
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
