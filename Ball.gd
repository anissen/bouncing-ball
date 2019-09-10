extends RigidBody2D

signal block_hit(block)

func _on_Ball_body_entered(body :Node):
	if body.is_in_group("Blocks"):
		if body.destructable:
			$hitBlockSound.play()
		else:
			$hitStoneBlockSound.play()
		emit_signal("block_hit", body)
	if body.is_in_group("Border"):
		$hitBorderSound.play()
