extends CanvasLayer


func _on_game_over_restart_button_pressed():
    print("game over restart")
    %GameOver.visible = false
    %GameOver.process_mode = PROCESS_MODE_DISABLED
    PlayerData.restart()