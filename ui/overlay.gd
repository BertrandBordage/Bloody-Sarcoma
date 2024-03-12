extends CanvasLayer


func _on_pause_button_pressed():
    get_parent().trigger_pause()
