extends Node2D


@export var texture: Texture2D
@onready var shape = CapsuleShape2D.new()
var canvas_item: RID
var body: RID


func _body_moved(state: PhysicsDirectBodyState2D):
    RenderingServer.canvas_item_set_transform(canvas_item, state.transform.translated(-global_transform.origin))
    global_position = state.transform.origin


func _ready():
    shape.radius = 1.5
    shape.height = 8.0
    canvas_item = RenderingServer.canvas_item_create()
    RenderingServer.canvas_item_set_parent(canvas_item, get_canvas_item())
    RenderingServer.canvas_item_add_texture_rect(
        canvas_item, Rect2(texture.get_size() / 2, texture.get_size()), texture,
    )
    RenderingServer.canvas_item_set_transform(canvas_item, global_transform)

    #shape = PhysicsServer2D.capsule_shape_create()
    #PhysicsServer2D.shape_set_data(shape, Vector2(8.0, 1.5))

    body = PhysicsServer2D.body_create()
    PhysicsServer2D.body_set_space(body, get_world_2d().space)
    PhysicsServer2D.body_set_mode(body, PhysicsServer2D.BODY_MODE_RIGID)
    PhysicsServer2D.body_add_shape(body, shape, Transform2D().translated(Vector2(0.5, 0)))
    PhysicsServer2D.body_set_state(body, PhysicsServer2D.BODY_STATE_TRANSFORM, global_transform)
    #PhysicsServer2D.body_set_param(body, PhysicsServer2D.BODY_PARAM_MASS, 0.01)
    #PhysicsServer2D.body_set_collision_layer(body, 0b1000)
    #PhysicsServer2D.body_set_collision_mask(body, 0b1111)
    #PhysicsServer2D.body_set_force_integration_callback(body, self._body_moved)


func _physics_process(_delta):
    RenderingServer.canvas_item_set_transform(
        canvas_item,
        PhysicsServer2D.body_get_state(body, PhysicsServer2D.BODY_STATE_TRANSFORM),
    )


func _exit_tree():
    PhysicsServer2D.free_rid(body)
    #PhysicsServer2D.free_rid(shape)
    RenderingServer.canvas_item_clear(canvas_item)
