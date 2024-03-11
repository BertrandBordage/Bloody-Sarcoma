extends Node

signal threat_level_raised(threat_level: int)
signal threat_level_decreased(threat_level: int)
signal input_changed

const MIN_ZOOM = Vector2(1.5, 1.5)
const MAX_ZOOM = Vector2(3.0, 3.0)
const MAX_THREAT_LEVEL: float = 5.0
const HIGH_SCORE_PATH: String = "user://high_score.save"
var threat_level: float = 0.0
var score: int = 0
var high_score: int = 0
var cluster: Node2D
var camera: Camera2D
var initial_zoom: Vector2
var zoom_smoothing: float  # 0 < and < 1.
var smoothed_zoom: Vector2
var cooldown_timer: Timer
var use_mouse: bool = true
var use_gamepad: bool = false
var is_nintendo_gamepad: bool = false
var use_keyboard: bool = false
var use_touch: bool = false


func initial_zoom_tween():
    smoothed_zoom = initial_zoom
    zoom_smoothing = 0.99
    create_tween().tween_property(self, "zoom_smoothing", 0.998, 5.0)


func restart():
    save_high_score()
    high_score = read_high_score()
    threat_level = 0.0
    if SpawnedFlow.lymphocyte_probability_tween:
        SpawnedFlow.lymphocyte_probability_tween.stop()
    SpawnedFlow.lymphocyte_probability = 0.0
    # -1 is a trick to not trigger the first threat level to blink.
    threat_level_decreased.emit(-1.0)
    score = 0
    for cell in cluster.get_children():
        cell.queue_free()
    var first_cell = cluster.first_cell_for_restart.duplicate()
    first_cell.animation = "Idle"
    cluster.add_child(first_cell)
    for spawned in SpawnedFlow.spawn_container.get_children():
        spawned.queue_free()

    camera.global_position = first_cell.global_position
    cluster.smoothed_position = camera.position
    initial_zoom_tween()
    cooldown_timer.stop()


func read_high_score():
    if FileAccess.file_exists(HIGH_SCORE_PATH):
        return FileAccess.open(
            HIGH_SCORE_PATH, FileAccess.READ,
        ).get_64()
    return 0


func save_high_score():
    if score > high_score:
        FileAccess.open(HIGH_SCORE_PATH, FileAccess.WRITE).store_64(score)


func _ready():
    high_score = read_high_score()


func _exit_tree():
    save_high_score()


func _process(_delta):
    smoothed_zoom = (
        zoom_smoothing * smoothed_zoom
        + (1.0 - zoom_smoothing) * (
            MIN_ZOOM / (1.0 + SpawnedFlow.player_speed)
        ).clamp(MIN_ZOOM, MAX_ZOOM)
    )


func _input(event):
    if event is InputEventJoypadMotion:
        is_nintendo_gamepad = Input.get_joy_name(
            event.device
        ).to_lower().contains("nintendo")
        if not use_gamepad:
            use_mouse = false
            use_gamepad = true
            use_keyboard = false
            input_changed.emit()
    elif event is InputEventKey and not use_keyboard:
        use_mouse = false
        use_gamepad = false
        use_keyboard = true
        input_changed.emit()
    elif event is InputEventScreenTouch and not use_touch:
        use_mouse = false
        use_touch = true
        use_gamepad = false
        use_keyboard = false
        input_changed.emit()
    elif event is InputEventMouseMotion and not use_mouse:
        use_mouse = true
        use_gamepad = false
        use_keyboard = false
        input_changed.emit()


func raise_threat_level(amount: float):
    if threat_level >= MAX_THREAT_LEVEL:
        return
    var previous_threat_level = threat_level
    threat_level += amount
    if floor(threat_level) == floor(previous_threat_level):
        return
    threat_level = floor(threat_level)
    threat_level_raised.emit(threat_level)
    if SpawnedFlow.lymphocyte_probability_tween:
        SpawnedFlow.lymphocyte_probability_tween.stop()
    SpawnedFlow.lymphocyte_probability_tween = create_tween()
    SpawnedFlow.lymphocyte_probability_tween.tween_property(
        SpawnedFlow, "lymphocyte_probability",
        PlayerData.threat_level,
        30,
    )
    cooldown_timer.start()


func decrease_threat_level():
    threat_level = max(floor(threat_level) - 1, 0)
    threat_level_decreased.emit(threat_level)
    SpawnedFlow.lymphocyte_probability = threat_level

    if threat_level > 0:
        cooldown_timer.start()


func get_worst_cell():
    var min_worth: int = 100
    var candidate = null
    for cell in cluster.get_children():
        var worth = cell.get_worth()
        if worth == 0:
            return cell
        if worth < min_worth:
            min_worth = worth
            candidate = cell
    return candidate


func metastasize():
    if cluster.get_child_count() <= 1:
        return
    var cell = get_worst_cell()
    if cell == null:
        return
    var dropped_cell = cell.duplicate()
    dropped_cell.detached = true
    create_tween().tween_property(dropped_cell, "modulate:a", 0.75, 1.0)
    dropped_cell.animation = "Idle"
    SpawnedFlow.spawn_container.add_child(dropped_cell)
    cell.queue_free()
    score += 100
