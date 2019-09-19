extends Node2D

var score := 0
var swipes := 0
var elapsed_seconds := 0
var is_swiping := false

onready var explosion_scene = preload("res://Explosion.tscn")

func _input(event :InputEvent):
	if !get_node_or_null("Ball"): return

	if event.is_action_pressed("ui_touch"):
#		is_swiping = true
#		var tween = Tween.new()
#		tween.interpolate_property(Engine, "time_scale", Engine.time_scale, 0.1, 0.3, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
#		add_child(tween)
#		tween.start()
#		#yield(tween, "tween_completed")
		Engine.time_scale = 0.2
	elif event.is_action_released("ui_touch"):
		is_swiping = false
		swipes += 1
		Engine.time_scale = 1
		var diff = event.position - $Ball.position
		$Ball.apply_central_impulse(diff * 5)

	if event.is_action_released("restart"):
		restart()

func restart():
	get_tree().reload_current_scene()

func update_label():
	var time_left = 30 - elapsed_seconds;
	if time_left < 0: time_left = 0
	var time_color = "#0074D9" if time_left > 0 else "#FF4136"
	var swipes_left = 5 - swipes
	if swipes_left < 0: swipes_left = 0
	var swipes_color = "#0074D9" if swipes_left > 0 else "#FF4136"
	$ObjectiveLabel.bbcode_text = "[center]Time: [color=" + time_color + "]" + str(time_left) + "[/color] / Swipes: [color=" + swipes_color + "]" + str(swipes_left) + "[/color][/center]"

	if time_left == 0 and swipes_left == 0:
		$LevelLostMessage.show()
		get_tree().create_timer(1).connect("timeout", self, "restart")

func _on_Ball_block_hit(block):
	if !get_node_or_null("Ball"): return
	if !block.destructable: return
	if block.type == block.Type.EXPLOSIVE:
		Engine.time_scale = 1
		$Ball.queue_free()
		$LevelLostMessage.show()
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

	var has_won = true
	for b in get_tree().get_nodes_in_group("Blocks"):
		if b.destructable and b.type == b.Type.NORMAL:
			has_won = false
			break

	if has_won:
		$Ball.queue_free()
		$LevelWonMessage.show()

func _on_GameTimer_timeout():
	elapsed_seconds += 1
	update_label()
