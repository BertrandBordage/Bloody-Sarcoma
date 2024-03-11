extends CanvasLayer


func toggle_pause():
    if %GameOver.visible:
        return
    visible = not visible
    get_tree().paused = visible
    if visible:
        %ResumeButton.grab_focus()


func _input(_event):
    if Input.is_action_just_pressed("pause"):
        toggle_pause()


func _on_resume_button_pressed():
    toggle_pause()


func _on_restart_button_pressed():
    toggle_pause()
    PlayerData.restart()
