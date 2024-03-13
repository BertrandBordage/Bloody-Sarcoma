extends Node


func update_volume(_new_value):
    %Instrumental.volume_db = linear_to_db(Ui.music_volume)
    var total_voice_volume = Ui.music_volume * Ui.voice_volume
    %Voice.volume_db = linear_to_db(total_voice_volume)
    %SubtitlesLayer.visible = total_voice_volume > 0.0


func _ready():
    update_volume(1.0)
    Ui.music_volume_changed.connect(update_volume)
    Ui.voice_volume_changed.connect(update_volume)
    var delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
    %Instrumental.play()
    %Voice.play()
    await get_tree().create_timer(delay).timeout
    %AnimationPlayer.current_animation = "Lyrics"
    Heartbeat.start()


func _on_instrumental_finished():
    queue_free()
