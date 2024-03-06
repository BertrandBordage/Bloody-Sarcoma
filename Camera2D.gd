extends Camera2D


func _process(delta):
    zoom = Vector2.ONE * (3.0 + Heartbeat.blood_pressure / 10000.0)
