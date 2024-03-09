extends Node


var beats_per_second: float = 1.0
var blood_pressure: float = 0.0


func start():
    var pulse_tween = create_tween().set_loops()
    pulse_tween.tween_property(self, "blood_pressure", 1, 0.25 / beats_per_second)
    pulse_tween.tween_property(self, "blood_pressure", 0, 0.3125 / beats_per_second)
    pulse_tween.tween_property(self, "blood_pressure", 0.25, 0.1875 / beats_per_second)
    pulse_tween.tween_property(self, "blood_pressure", 0, 0.5 / beats_per_second)
    var beats_speed_tween = create_tween().set_loops()
    beats_speed_tween.tween_property(self, "beats_per_second", 0.8, 20)
    beats_speed_tween.tween_property(self, "beats_per_second", 3, 20)
    beats_speed_tween.tween_property(self, "beats_per_second", 2, 20)
