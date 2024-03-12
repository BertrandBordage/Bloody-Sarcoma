extends Label


func _process(_delta):
    text = "HIGH SCORE: %s\n%s" % [
        max(PlayerData.high_score, PlayerData.score),
        PlayerData.score,
    ]
