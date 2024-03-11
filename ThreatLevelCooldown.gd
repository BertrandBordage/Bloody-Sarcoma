extends Timer


func _on_timeout():
    PlayerData.decrease_threat_level()
