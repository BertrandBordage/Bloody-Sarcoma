extends Node


func toggle_node(node: Node2D, enabled: bool):
    node.visible = enabled
    node.process_mode = PROCESS_MODE_INHERIT if enabled else PROCESS_MODE_DISABLED


func rotate_via_torque(
    body: RigidBody2D,
    direction: Vector2,
    strength: float = 100.0,
    smoothing: float = 0.99,  # 0 < and < 1.
):
    body.apply_torque(
        smoothing * body.constant_torque
        + (1.0 - smoothing) * strength
        * Vector2.RIGHT.rotated(body.rotation).dot(direction)
    )


func get_key_name(action_name: String, event_index_in_action: int = 0) -> String:
    var event: InputEvent = InputMap.action_get_events(action_name)[event_index_in_action]
    if not (event is InputEventKey):
        return ""
    return OS.get_keycode_string(
        DisplayServer.keyboard_get_label_from_physical(
            event.physical_keycode
        )
    )


func read_float(path: String, default: float = 0.0):
    if FileAccess.file_exists(path):
        return FileAccess.open(
            path, FileAccess.READ,
        ).get_float()
    return default


func write_float(path: String, value: float):
    FileAccess.open(path, FileAccess.WRITE).store_float(value)
