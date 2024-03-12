extends Label


var last_frames: Array[float] = []


func _process(delta):
    if PlayerData.show_fps:
        visible = true
        last_frames.append(delta)
        if last_frames.size() > 60:
            last_frames.remove_at(0)
        text = "%s FPS" % round(1.0/Math.avg(last_frames))
    else:
        visible = false
        last_frames.clear()
