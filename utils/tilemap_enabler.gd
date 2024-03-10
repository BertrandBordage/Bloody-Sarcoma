extends VisibleOnScreenNotifier2D


@onready var parent: TileMap = get_parent()


func toggle(enabled: bool):
    parent.process_mode = PROCESS_MODE_INHERIT if enabled else PROCESS_MODE_DISABLED
    for layer_index in range(parent.get_layers_count()):
        parent.set_layer_enabled(layer_index, enabled)


func _ready():
    _on_screen_exited()


func _on_screen_entered():
    toggle(true)


func _on_screen_exited():
    toggle(false)
