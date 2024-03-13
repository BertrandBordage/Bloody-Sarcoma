extends Node


var beats_per_second: float = 2.0 / 3.0
var blood_pressure: float = 2.0
var blood_pressure_multiplier: float = 1.0


func start():
    var pulse_tween = create_tween().set_loops()
    pulse_tween.tween_property(
        self, "blood_pressure",
        -1.0 * blood_pressure_multiplier,
        0.20 / beats_per_second,
    )
    pulse_tween.tween_property(
        self, "blood_pressure",
        1.0 * blood_pressure_multiplier,
        0.13333333333 / beats_per_second,
    )
    pulse_tween.tween_property(
        self, "blood_pressure",
        -1.25 * blood_pressure_multiplier,
        0.46666666667 / beats_per_second,
    )
    pulse_tween.tween_property(
        self, "blood_pressure",
        2.0 * blood_pressure_multiplier,
        0.2 / beats_per_second,
    )
    #var beats_speed_tween = create_tween().set_loops()
    #beats_speed_tween.tween_property(self, "beats_per_second", 0.8, 20)
    #beats_speed_tween.tween_property(self, "beats_per_second", 2, 20)
    #beats_speed_tween.tween_property(self, "beats_per_second", 1, 20)
