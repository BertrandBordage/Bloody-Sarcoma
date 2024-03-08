extends RigidBody2D


signal sibling_created(new_cell: RigidBody2D, from_cell: RigidBody2D)

var cancer_cell_scene: PackedScene = load("res://cancer_cell.tscn")


func toggle_node(node: Node2D, enabled: bool):
    node.visible = enabled
    node.process_mode = PROCESS_MODE_INHERIT if enabled else PROCESS_MODE_DISABLED


@export var has_light: bool = false:
    set(value):
        has_light = value
        toggle_node(%Light, has_light)
@export var has_mouth: bool = false:
    set(value):
        has_mouth = value
        toggle_node(%Mouth, has_mouth)
        toggle_node(%AttackArea, has_mouth)
@export var has_flow_control: bool = false:
    set(value):
        has_flow_control = value
        toggle_node(%TopFlowControl, has_flow_control and has_top_flagellum)
        toggle_node(%BottomFlowControl, has_flow_control and has_bottom_flagellum)
@export var has_top_flagellum: bool = false:
    set(value):
        has_top_flagellum = value
        toggle_node(%TopFlagellum, has_top_flagellum)
        toggle_node(%TopFlowControl, has_flow_control and has_top_flagellum)
@export var has_bottom_flagellum: bool = false:
    set(value):
        has_bottom_flagellum = value
        toggle_node(%BottomFlagellum, has_bottom_flagellum)
        toggle_node(%BottomFlowControl, has_flow_control and has_bottom_flagellum)


const FOOD_FOR_MITOSIS: float = 10.0
var animation: String = "Bottom regrowing":
    set(value):
        animation = value
        %AnimationPlayer.current_animation = animation
var food: float = 0.0
var separating: bool = false
var growing: bool = false


func _ready():
    has_light = has_light
    has_mouth = has_mouth
    has_flow_control = has_flow_control
    has_top_flagellum = has_top_flagellum
    has_bottom_flagellum = has_bottom_flagellum
    animation = animation


func _process(_delta):
    if food >= FOOD_FOR_MITOSIS and can_perform_mitosis():
        food -= FOOD_FOR_MITOSIS
        start_mitosis()


func get_mutations_count() -> int:
    var count: int = 0
    if has_light:
        count += 1
    if has_mouth:
        count += 1
    if has_flow_control:
        count += 1
    if has_top_flagellum:
        count += 1
    if has_bottom_flagellum:
        count += 1
    return count



func set_animation_for_movement(movement: Vector2) -> void:
    if animation in ["Idle", "Forward", "Backwards", "Left", "Right"]:
        var relative_movement = movement.rotated(-rotation)
        if relative_movement == Vector2.ZERO:
            animation = "Idle"
        else:
            var angle = relative_movement.angle()
            if angle > -PI / 4 and angle <= PI / 4:
                animation = "Right"
            elif angle > PI / 4 and angle <= 3 * PI / 4:
                animation = "Backwards"
            elif angle > 3 * PI / 4 or angle < -3 * PI / 4:
                animation = "Left"
            else:
                animation = "Forward"


func can_perform_mitosis():
    return not separating and not growing


func start_mitosis():
    if can_perform_mitosis():
        separating = true
        animation = "Mitosis"


func spawn_new_sibling():
    var new_cell: RigidBody2D = cancer_cell_scene.instantiate()
    separating = false
    growing = true
    new_cell.growing = true
    animation = "Top regrowing"
    new_cell.position = position
    new_cell.rotation = rotation
    new_cell.linear_velocity = linear_velocity
    new_cell.angular_velocity = angular_velocity
    add_sibling(new_cell)
    sibling_created.emit(new_cell, self)


func _on_animation_player_animation_finished(anim_name):
    if anim_name == "Mitosis":
        spawn_new_sibling()
    if anim_name in ["Top regrowing", "Bottom regrowing"]:
        growing = false
        animation = "Idle"


func _on_attack_area_damage_dealt(earned_food):
    food += earned_food


func take_damage(damage: float) -> float:
    return %HealthComponent.take_damage(damage)


func _on_health_component_died():
    queue_free()
