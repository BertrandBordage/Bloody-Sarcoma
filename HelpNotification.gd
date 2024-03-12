extends CanvasLayer


func _ready():
    var tween: Tween = create_tween()
    tween.tween_property(self, "offset:y", 50, 0.5).set_delay(7.0)
    tween.tween_callback(queue_free)
