extends Node

signal threat_level_raised(threat_level: int)
signal threat_level_decreased(threat_level: int)

const MAX_THREAT_LEVEL: float = 5.0
# TODO: Remove available_mutations, we now get mutations from eating.
var available_mutations: int = 0
var threat_level: float = 0.0
var cooldown_timer: Timer


func raise_threat_level(amount: float):
    if threat_level >= MAX_THREAT_LEVEL:
        return
    var previous_threat_level = threat_level
    threat_level += amount
    if floor(threat_level) == floor(previous_threat_level):
        return
    threat_level = floor(threat_level)
    threat_level_raised.emit(threat_level)
    create_tween().tween_property(
        SpawnedFlow, "lymphocyte_probability",
        PlayerData.threat_level,
        30,
    )
    cooldown_timer.start()


func decrease_threat_level():
    threat_level = max(floor(threat_level) - 1, 0)
    threat_level_decreased.emit(threat_level)
    SpawnedFlow.lymphocyte_probability = threat_level

    if threat_level > 0:
        cooldown_timer.start()
