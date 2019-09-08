extends Node2D

#var mouse_down := false
#var drag_position :Vector2 = null
#var drag_start_time

var score := 0

func _input(event :InputEvent):
	if event is InputEventScreenDrag:
		$Ball.apply_central_impulse(event.relative * 10)

	#if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.is_pressed():
		#print(event.global_position - $Ball.global_position)
	#	$Ball.apply_central_impulse(event.global_position - $Ball.global_position)

	if event.is_action_released("restart"):
		get_tree().reload_current_scene()


func _on_Ball_block_hit(block):
	score += 1
	print("Score: " + str(score))
	block.queue_free()
