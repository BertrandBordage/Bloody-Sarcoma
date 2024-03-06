extends RigidBody2D


signal sibling_created(new_cell: RigidBody2D)


@export var has_light: bool = false:
    set(value):
        has_light = value
        %Light.visible = has_light
@export var has_mouth: bool = false:
    set(value):
        has_mouth = value
        %Mouth.visible = has_mouth
@export var has_flow_control: bool = false:
    set(value):
        has_flow_control = value
        %TopFlowControl.visible = has_flow_control and has_top_flagellum
        %BottomFlowControl.visible = has_flow_control and has_bottom_flagellum
@export var has_top_flagellum: bool = false:
    set(value):
        has_top_flagellum = value
        %TopFlagellum.visible = has_top_flagellum
        %TopFlowControl.visible = has_flow_control and has_top_flagellum
@export var has_bottom_flagellum: bool = false:
    set(value):
        has_bottom_flagellum = value
        %BottomFlagellum.visible = has_bottom_flagellum
        %BottomFlowControl.visible = has_flow_control and has_bottom_flagellum


var animation: String = "Bottom regrowing":
    set(value):
        animation = value
        %AnimationPlayer.current_animation = animation
var separating: bool = false
var growing: bool = false


func _ready():
    has_light = has_light
    has_mouth = has_mouth
    has_flow_control = has_flow_control
    has_top_flagellum = has_top_flagellum
    has_bottom_flagellum = has_bottom_flagellum
    animation = animation


func can_perform_mitosis():
    return not separating and not growing


func start_mitosis():
    if can_perform_mitosis():
        separating = true
        animation = "Mitosis"


func spawn_new_sibling():
    var new_cell: RigidBody2D = load("res://cell.tscn").instantiate()
    separating = false
    growing = true
    new_cell.growing = true
    animation = "Top regrowing"
    new_cell.position = position
    new_cell.rotation = rotation
    new_cell.linear_velocity = linear_velocity
    new_cell.angular_velocity = angular_velocity
    add_sibling(new_cell)
    sibling_created.emit(new_cell)


func set_random_mutations():
    has_light = randf() >= 0.5
    has_mouth = randf() >= 0.5
    has_flow_control = randf() >= 0.5
    has_top_flagellum = randf() >= 0.5
    has_bottom_flagellum = randf() >= 0.5


func _on_animation_player_animation_finished(anim_name):
    if anim_name == "Mitosis":
        spawn_new_sibling()
    if anim_name in ["Top regrowing", "Bottom regrowing"]:
        growing = false
        animation = "Idle"
