extends Area2D


@export var region_name: String
@export var region_scene: PackedScene
var region: Node


func _on_area_entered(_area):
    if region:
        return

    region = region_scene.instantiate()
    add_child(region)
    Ui.region_change.emit(region_name)


func _on_area_exited(_area):
    %RecentlyExitedTimer.start()


func _on_recently_exited_timer_timeout():
    if region:
        region.queue_free()
        region = null
