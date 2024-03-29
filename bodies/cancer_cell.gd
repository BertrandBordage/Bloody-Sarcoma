extends RigidBody2D


const NAME = "CancerCell"
var cancer_cell_scene: PackedScene = load("res://bodies/cancer_cell.tscn")


@export var has_light: bool = false:
    set(value):
        has_light = value
        Utils.toggle_node(%Light, has_light)
        update_worth()
@export var has_mouth: bool = false:
    set(value):
        has_mouth = value
        Utils.toggle_node(%Mouth, has_mouth)
        Utils.toggle_node(%AttackArea, has_mouth)
        update_worth()
@export var has_flow_control: bool = false:
    set(value):
        has_flow_control = value
        Utils.toggle_node(%TopFlowControl, has_flow_control and has_top_flagellum)
        Utils.toggle_node(%BottomFlowControl, has_flow_control and has_bottom_flagellum)
        update_worth()
@export var has_top_flagellum: bool = false:
    set(value):
        has_top_flagellum = value
        Utils.toggle_node(%TopFlagellum, has_top_flagellum)
        Utils.toggle_node(%TopFlowControl, has_flow_control and has_top_flagellum)
        update_worth()
@export var has_bottom_flagellum: bool = false:
    set(value):
        has_bottom_flagellum = value
        Utils.toggle_node(%BottomFlagellum, has_bottom_flagellum)
        Utils.toggle_node(%BottomFlowControl, has_flow_control and has_bottom_flagellum)
        update_worth()


const MAX_CELLS: int = 100
const FOOD_FOR_MITOSIS: float = 125.0
var animation: String = "Bottom regrowing":
    set(value):
        animation = value
        %AnimationPlayer.current_animation = animation
var food: float = 0.0
var separating: bool = false:
    set(value):
        separating = value
        update_worth()
var growing: bool = false:
    set(value):
        growing = value
        update_worth()
var detached: bool = false:
    set(value):
        detached = value
        update_worth()
var worth: float


func _ready():
    has_light = has_light
    has_mouth = has_mouth
    has_flow_control = has_flow_control
    has_top_flagellum = has_top_flagellum
    has_bottom_flagellum = has_bottom_flagellum
    animation = animation
    SpawnedFlow.spawned_bodies.append(self)


func _exit_tree():
    SpawnedFlow.spawned_bodies.erase(self)


func _process(_delta):
    start_mitosis_if_possible()


func update_worth():
    worth = 0.0
    if has_light:
        worth += 1.0
    if has_mouth:
        worth += 1.0
    if has_flow_control:
        worth += 1.0
    if has_top_flagellum:
        worth += 1.0
    if has_bottom_flagellum:
        worth += 1.0
    if separating:
        worth += 2.0
    if growing:
        # For an equal worth, penalize growing cells.
        # Doing this with 1.0 would not work, as it would downgrade
        # interesting growing cells like a cell with bottom flagellums.
        worth -= 0.5


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
    return not separating and not growing and food >= FOOD_FOR_MITOSIS


func start_mitosis_if_possible():
    if not can_perform_mitosis():
        return

    food -= FOOD_FOR_MITOSIS
    if get_parent().get_child_count() >= MAX_CELLS:
        PlayerData.metastasize()

    separating = true
    animation = "Mitosis"


func spawn_new_sibling():
    var new_cell: RigidBody2D = cancer_cell_scene.instantiate()
    separating = false
    growing = true
    animation = "Top regrowing"
    new_cell.growing = true
    new_cell.has_bottom_flagellum = has_bottom_flagellum
    has_bottom_flagellum = false
    new_cell.food = floor(food / 2.0)
    food = ceil(food / 2.0)
    new_cell.position = position
    new_cell.rotation = rotation
    new_cell.linear_velocity = linear_velocity
    new_cell.angular_velocity = angular_velocity
    add_sibling(new_cell)


func _on_animation_player_animation_finished(anim_name):
    if anim_name == "Mitosis":
        spawn_new_sibling()
    if anim_name in ["Top regrowing", "Bottom regrowing"]:
        growing = false
        animation = "Idle"


func _on_attack_area_damage_dealt(body: RigidBody2D, earned_food: float):
    food += earned_food
    if body.NAME == "RedBloodCell":
        %HealthComponent.health = min(
            %HealthComponent.health + earned_food,
            %HealthComponent.initial_health,
        )
    if detached:
        return
    if not %Bite.playing:
        %Bite.play()
    if earned_food == 0:
        return

    #
    # Kills
    #

    if body.NAME == "RedBloodCell":
        %RedBloodCellDead.play()
        PlayerData.add_points(1, body)
    elif body.NAME == "Lymphocyte":
        %LymphocyteDead.play()
        PlayerData.raise_threat_level(1.0)
        PlayerData.add_points(100, body)
    elif body.NAME == "Neutrophil":
        %NeutrophilDead.play()
        for sibling in get_parent().get_children():
            if not sibling.has_mouth:
                sibling.has_mouth = true
                break
        PlayerData.raise_threat_level(0.5)
        PlayerData.add_points(10, body)
    elif body.NAME == "Bacteria":
        %BacteriaDead.play()
        if has_bottom_flagellum:
            if has_top_flagellum:
                for sibling in get_parent().get_children():
                    if not sibling.has_bottom_flagellum:
                        sibling.has_bottom_flagellum = true
                        break
                    if not sibling.has_top_flagellum:
                        sibling.has_top_flagellum = true
                        break
            else:
                has_top_flagellum = true
        else:
            has_bottom_flagellum = true
        PlayerData.add_points(5, body)


func take_damage(damage: float):
    if not %Hurt.playing:
        %Hurt.play()
    return %HealthComponent.take_damage(damage)


func reset_for_respawn():
    %HealthComponent.reset_for_respawn()


func _on_health_component_died():
    if detached:
        return
    var audio = %Dead.duplicate()
    get_tree().root.add_child(audio)
    audio.global_position = global_position
    audio.play()
    queue_free()
