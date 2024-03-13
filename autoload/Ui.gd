extends Node

signal region_change(new_value: String)
signal global_volume_changed(new_value: float)
signal music_volume_changed(new_value: float)
signal voice_volume_changed(new_value: float)

const GLOBAL_VOLUME_PATH: String = "user://global-volume.save"
const MUSIC_VOLUME_PATH: String = "user://music-volume.save"
const VOICE_VOLUME_PATH: String = "user://voice-volume.save"
var current_region_name: String
var global_volume: float
var music_volume: float
var voice_volume: float


func _ready():
    global_volume = Utils.read_float(GLOBAL_VOLUME_PATH, 1.0)
    music_volume = Utils.read_float(MUSIC_VOLUME_PATH, 0.6)
    voice_volume = Utils.read_float(VOICE_VOLUME_PATH, 1.0)


func _on_global_volume_changed(new_value: float):
    global_volume = new_value
    AudioServer.set_bus_volume_db(
        AudioServer.get_bus_index("Master"),
        linear_to_db(global_volume),
    )
    global_volume_changed.emit(new_value)
    Utils.write_float(GLOBAL_VOLUME_PATH, new_value)


func _on_music_volume_changed(new_value: float):
    music_volume = new_value
    music_volume_changed.emit(new_value)
    Utils.write_float(MUSIC_VOLUME_PATH, new_value)


func _on_voice_volume_changed(new_value: float):
    voice_volume = new_value
    voice_volume_changed.emit(new_value)
    Utils.write_float(VOICE_VOLUME_PATH, new_value)
