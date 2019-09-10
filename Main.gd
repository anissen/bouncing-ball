extends Node2D

#var mouse_down := false
#var drag_position :Vector2 = null
#var drag_start_time

var score := 0

onready var explosion_scene = preload("res://Explosion.tscn")

func _input(event :InputEvent):
	if $Ball == null: return
	if event is InputEventScreenDrag:
		$Ball.apply_central_impulse(event.relative * 10)

	#if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.is_pressed():
		#print(event.global_position - $Ball.global_position)
	#	$Ball.apply_central_impulse(event.global_position - $Ball.global_position)

	if event.is_action_released("restart"):
		restart()

func restart():
	get_tree().reload_current_scene()

func _on_Ball_block_hit(block):
	if !block.destructable: return
	if block.type == block.Type.EXPLOSIVE:
		$Ball.queue_free()
		get_tree().create_timer(1).connect("timeout", self, "restart")

	score += 1
	print("Score: " + str(score))
	block.queue_free()

	var explosion = explosion_scene.instance()
	add_child(explosion)
	explosion.position = block.position
	explosion.rotate(rand_range(0, PI * 2))
	explosion.play()
	yield(explosion, "animation_finished")
	explosion.queue_free()
