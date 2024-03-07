extends Area2D


signal damage_dealt(earned_food: float)

@export var damage: float = 1.0


func _process(_delta):
    for body in get_overlapping_bodies():
        if body.has_method("take_damage"):
            damage_dealt.emit(body.take_damage(damage))
            break
