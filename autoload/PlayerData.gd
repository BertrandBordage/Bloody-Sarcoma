extends Node

signal threat_level_raised(threat_level: int)
signal threat_level_decreased(threat_level: int)
signal input_changed

const MAX_THREAT_LEVEL: float = 5.0
var threat_level: float = 0.0
var score: int = 0
var cluster: Node2D
var cooldown_timer: Timer
var use_mouse: bool = true
var use_gamepad: bool = false
var is_nintendo_gamepad: bool = false
var use_keyboard: bool = false


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
    create_tween().tween_property(
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


func drop_cell():
    if cluster.get_child_count() <= 1:
        return
    var cell = get_worst_cell()
    if cell == null:
        return
    var dropped_cell = cell.duplicate()
    create_tween().tween_property(dropped_cell, "modulate:a", 0.75, 1.0)
    dropped_cell.animation = "Idle"
    SpawnedFlow.spawn_container.add_child(dropped_cell)
    cell.queue_free()
    score += 100
