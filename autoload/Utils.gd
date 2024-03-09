extends Node


func toggle_node(node: Node2D, enabled: bool):
    node.visible = enabled
    node.process_mode = PROCESS_MODE_INHERIT if enabled else PROCESS_MODE_DISABLED
