extends CanvasLayer


func _on_game_over_restart_button_pressed():
    %GameOver.visible = false
    %GameOver.process_mode = PROCESS_MODE_DISABLED
    PlayerData.restart()


func _on_publish_high_score_meta_clicked(meta):
    if OS.get_name() != "HTML5":
        OS.shell_open(meta)
