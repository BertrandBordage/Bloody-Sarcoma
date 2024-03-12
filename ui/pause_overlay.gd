extends CanvasLayer


@export var help_panel_scene: PackedScene


func _ready():
    get_tree().paused = true
    %ResumeButton.grab_focus()
    if OS.get_name() == "Web":
        %QuitButton.queue_free()


func _exit_tree():
    get_parent().pause_overlay = null
    get_tree().paused = false


func _input(event):
    if event.is_action_pressed("pause"):
        queue_free()


func _on_resume_button_pressed():
    queue_free()


func _on_restart_button_pressed():
    queue_free()
    PlayerData.restart()


func _on_help_button_pressed():
    var help_panel = help_panel_scene.instantiate()
    help_panel.closed.connect(func (): %HelpButton.grab_focus())
    add_child(help_panel)


func _on_quit_button_pressed():
    get_tree().quit()


func _on_show_fps_toggled(toggled_on):
    PlayerData.show_fps = toggled_on
