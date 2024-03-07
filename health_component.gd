extends Node


signal died


@export var initial_health: float = 0.0
@export var sprite: CanvasItem
@export var flash_strength: float = 5
@export var invulnerability_duration: float = 0.2
var health: float = 0.0
var invulnerable: bool = false


func _ready():
    health = initial_health


func take_damage(damage: float) -> float:
    if invulnerable:
        return 0.0
    health -= damage
    if health > 0:
        invulnerable = true
        sprite.modulate.v = flash_strength
        var tween: Tween = create_tween()
        tween.tween_property(sprite, "modulate:v", 1, invulnerability_duration)
        tween.tween_callback(func (): invulnerable = false)
        return 0.0
    died.emit()
    return initial_health
