tool
extends StaticBody2D

export var texture :Texture setget set_texture, get_texture

enum Type {
	NORMAL,
	EXPLOSIVE
}

export var destructable :bool = true
export (Type) var type = Type.NORMAL

func set_texture(texture :Texture):
	if texture == null: return
	$Image.texture = texture
	var newShape :RectangleShape2D = $CollisionShape2D.shape.duplicate()
	newShape.extents = texture.get_size() / 2
	$CollisionShape2D.shape = newShape

func get_texture():
	return $Image.texture
