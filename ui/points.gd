extends Node2D


var value: int = 1
var velocity: Vector2 = Vector2.ZERO


func start_tween():
    %Label.text = "%s" % value
    var tween: Tween = create_tween().set_parallel()
    tween.tween_property(self, "global_position:y", global_position.y - 10.0, 0.5)
    tween.tween_property(self, "modulate:a", 0.0, 0.5)
    tween.finished.connect(queue_free)


func _physics_process(delta):
    position += velocity * delta
