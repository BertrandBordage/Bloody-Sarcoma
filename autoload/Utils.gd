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
