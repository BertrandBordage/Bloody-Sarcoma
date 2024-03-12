extends CanvasLayer


func _ready():
    PlayerData.game_over = true
    %RestartButton.grab_focus()
    %NewHighScore.visible = PlayerData.score >= PlayerData.high_score
    %HighScoreForScreenshot.text = "%s" % PlayerData.score


func _on_game_over_restart_button_pressed():
    queue_free()
    PlayerData.restart()


func _on_publish_high_score_meta_clicked(meta):
    OS.shell_open(meta)
