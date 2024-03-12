extends CanvasLayer


@export var help_panel_scene: PackedScene


func _ready():
    get_tree().paused = true
    %ResumeButton.grab_focus()


func unpause():
    get_tree().paused = false
    queue_free()


func _input(event):
    if event is InputEventKey and event.is_action_pressed("pause"):
        # We defer the pause to prevent the game
        # from triggering pause again when we unpause with ESC.
        await get_tree().create_timer(0.01).timeout
        unpause()


func _on_resume_button_pressed():
    unpause()


func _on_restart_button_pressed():
    unpause()
    PlayerData.restart()


func _on_help_button_pressed():
    var help_panel = help_panel_scene.instantiate()
    help_panel.closed.connect(func (): %HelpButton.grab_focus())
    add_child(help_panel)
