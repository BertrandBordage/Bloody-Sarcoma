extends Button


func update_text():
    if PlayerData.use_gamepad:
        text = "(%s) Metastasize" % (
            "B" if PlayerData.is_nintendo_gamepad else "A"
        )
    else:
        text = "[SPACE] Metastasize"


func _ready():
    PlayerData.input_changed.connect(update_text)
