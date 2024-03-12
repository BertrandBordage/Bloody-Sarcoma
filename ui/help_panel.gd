extends PanelContainer


signal closed

var drag_velocity: Vector2 = Vector2.ZERO


func _ready():
    %CloseButton.grab_focus()
    %Controls.text = "Controls
[font_size=12px]Gamepad left joystick [font_size=9px]or[/font_size] move mouse/finger around cluster [font_size=9px]or[/font_size] arrow keys [font_size=9px]or[/font_size] %s%s%s%s keys.[/font_size]" % [
    Utils.get_key_name("up", 2),
    Utils.get_key_name("left", 2),
    Utils.get_key_name("down", 2),
    Utils.get_key_name("right", 2),
]


func _input(event):
    if event is InputEventScreenDrag and event.index == 0:
        drag_velocity = event.velocity
    elif event is InputEventScreenTouch and event.index == 0 and not event.pressed:
        drag_velocity = Vector2.ZERO


func _physics_process(delta):
    %ScrollContainer.scroll_vertical += Input.get_axis("up", "down") * delta * 200
    %ScrollContainer.scroll_vertical -= drag_velocity.y * delta


func _on_close_button_pressed():
    queue_free()
    closed.emit()
