extends Node


func update_volume(_new_value):
    %Instrumental.volume_db = linear_to_db(Ui.music_volume)
    var total_voice_volume = Ui.music_volume * Ui.voice_volume
    %Voice.volume_db = linear_to_db(total_voice_volume)
    %SubtitlesLayer.visible = total_voice_volume > 0.0


func _ready():
    update_volume(1.0)
    %Instrumental.play()
    %Voice.play()
    Ui.music_volume_changed.connect(update_volume)
    Ui.voice_volume_changed.connect(update_volume)


func _on_instrumental_finished():
    queue_free()
