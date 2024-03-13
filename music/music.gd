extends Node


func _ready():
    %Instrumental.play()
    %Voice.play()


func _on_instrumental_finished():
    queue_free()
