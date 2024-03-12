extends CanvasLayer


func _on_game_over():
    %PauseButton.disabled = true


func _on_game_restart():
    %PauseButton.disabled = false


func _ready():
    PlayerData.game_over.connect(_on_game_over)
    PlayerData.game_restart.connect(_on_game_restart)


func _on_pause_button_pressed():
    get_parent().trigger_pause()
