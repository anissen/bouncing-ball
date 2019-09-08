extends RigidBody2D

signal block_hit(block)

func _on_Ball_body_entered(body :Node):
	if body.is_in_group("Blocks"):
		emit_signal("block_hit", body)
