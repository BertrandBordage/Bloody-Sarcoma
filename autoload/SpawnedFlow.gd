extends Node


var spawned_bodies: Array[RigidBody2D] = []
var flow_velocity: Vector2 = Vector2.ZERO
var spawn_exclusion_global_position: Vector2
var spawn_exclusion_polygon: PackedVector2Array
