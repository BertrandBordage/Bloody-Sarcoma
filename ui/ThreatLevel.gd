extends HBoxContainer


@onready var textures: Array[Node] = get_children()


func set_texture_transparent(texture: CanvasItem):
    texture.modulate.a = 0.5


func set_texture_opaque(texture: CanvasItem):
    texture.modulate.a = 1.0


func animate_texture(texture: CanvasItem, raised: bool = true):
    var tween: Tween = create_tween().set_loops(6).set_ease(Tween.EASE_OUT)
    tween.tween_callback(set_texture_opaque.bind(texture)).set_delay(0.5)
    tween.tween_callback(set_texture_transparent.bind(texture)).set_delay(0.5)
    if raised:
        tween.connect("finished", set_texture_opaque.bind(texture))


func set_textures_alpha(threat_level: int, raised: bool = true):
    for i in range(textures.size()):
        var texture: CanvasItem = textures[i]
        if i < threat_level:
            if raised:
                animate_texture(texture, true)
            else:
                set_texture_opaque(texture)
        elif i == threat_level and not raised:
            animate_texture(texture, false)
        else:
            set_texture_transparent(texture)


func _ready():
    PlayerData.connect("threat_level_raised", set_textures_alpha.bind(true))
    PlayerData.connect("threat_level_decreased", set_textures_alpha.bind(false))
