extends Node2D

#var mouse_down := false
#var drag_position :Vector2 = null
#var drag_start_time

func _input(event :InputEvent):
	if event is InputEventScreenDrag:
		$Ball.apply_central_impulse(event.relative * 10)

	#if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.is_pressed():
		#print(event.global_position - $Ball.global_position)
	#	$Ball.apply_central_impulse(event.global_position - $Ball.global_position)
