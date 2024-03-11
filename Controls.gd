extends RichTextLabel

func update_text():
    var controller = "your mouse"
    if PlayerData.use_gamepad:
        controller = "your left joystick"
    elif PlayerData.use_keyboard:
        controller = "arrow keys"
    elif PlayerData.use_touch:
        controller = "your finger"
    text = "[center][font_size=12]Move [b]%s[/b] to control the sarcoma[/font_size][/center]" % controller


func _ready():
    PlayerData.input_changed.connect(update_text)
