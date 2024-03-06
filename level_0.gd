extends Node2D

const SPEED = 200.0

func _ready():
    Heartbeat.start()


func _process(_delta):
    %BloodVessel.spawn_exclusion_global_transform = %PlayableCellCluster.spawn_exclusion_global_transform
    %BloodVessel.spawn_exclusion_polygon = %PlayableCellCluster.spawn_exclusion_polygon
