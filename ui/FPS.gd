extends Label


func _process(delta):
    text = "%s FPS" % round(1.0/delta)
