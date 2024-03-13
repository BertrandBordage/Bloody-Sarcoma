extends CanvasLayer


func _on_game_over():
    %PauseButton.disabled = true


func _on_game_restart():
    %PauseButton.disabled = false


func show_region_name(region_name: String):
    %RegionName.text = region_name
    var tween = create_tween()
    tween.tween_property(%RegionName, "modulate:a", 1.0, 0.3)
    tween.tween_property(%RegionName, "modulate:a", 0.0, 0.3).set_delay(5.0)


func _ready():
    PlayerData.game_over.connect(_on_game_over)
    PlayerData.game_restart.connect(_on_game_restart)
    Ui.region_change.connect(show_region_name)


func _on_pause_button_pressed():
    get_parent().trigger_pause()
