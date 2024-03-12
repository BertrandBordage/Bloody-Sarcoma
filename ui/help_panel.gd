extends PanelContainer


signal closed


func _ready():
    %CloseButton.grab_focus()


func _on_close_button_pressed():
    queue_free()
    closed.emit()
