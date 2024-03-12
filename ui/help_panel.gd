extends PanelContainer


signal closed


func _ready():
    %CloseButton.grab_focus()
    %Controls.text = "Controls
[font_size=12px]Gamepad left joystick [font_size=9px]or[/font_size] move mouse/finger around cluster [font_size=9px]or[/font_size] arrow keys [font_size=9px]or[/font_size] %s%s%s%s keys.[/font_size]" % [
    Utils.get_key_name("up", 2),
    Utils.get_key_name("left", 2),
    Utils.get_key_name("down", 2),
    Utils.get_key_name("right", 2),
]


func _on_close_button_pressed():
    queue_free()
    closed.emit()
