extends Node2D


signal died


const MIN_COLOR_VALUE: float = 0.5
@export var initial_health: float = 0.0
@export var flash_strength: float = 3
@export var invulnerability_duration: float = 0.2
var health: float = 0.0
var invulnerable: bool = false


func _ready():
    health = initial_health


func get_color_value() -> float:
    return MIN_COLOR_VALUE + (1.0 - MIN_COLOR_VALUE) * health / initial_health


func end_of_invulnerability():
    invulnerable = false


func take_damage(damage: float) -> float:
    if invulnerable:
        return 0.0
    health -= damage
    if health > 0:
        invulnerable = true
        var tween: Tween = create_tween()
        tween.tween_property(self, "modulate:v", flash_strength, invulnerability_duration / 2.0)
        tween.tween_property(self, "modulate:v", get_color_value(), invulnerability_duration / 2.0)
        tween.tween_callback(end_of_invulnerability)
        return 0.0
    died.emit()
    return initial_health
