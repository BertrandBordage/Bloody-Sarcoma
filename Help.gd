extends CanvasLayer


func _ready():
    var tween: Tween = create_tween()
    tween.tween_property(self, "offset:y", 0, 0.5).set_delay(2.0)
    tween.tween_property(self, "offset:y", 200, 0.5).set_delay(10.0)
    tween.tween_callback(queue_free)
