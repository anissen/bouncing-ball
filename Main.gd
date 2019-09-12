extends Node2D

var score := 0
var swipes := 0
var elapsed_seconds := 0
var is_swiped := false

onready var explosion_scene = preload("res://Explosion.tscn")

func _input(event :InputEvent):
	if $Ball == null: return
	if event is InputEventScreenDrag:
		$Ball.apply_central_impulse(event.relative * 10)
		is_swiped = true
	if event.is_action_released("ui_touch") and is_swiped:
		is_swiped = false
		swipes += 1
		update_label()

	if event.is_action_released("restart"):
		restart()

func restart():
	get_tree().reload_current_scene()

func update_label():
	var time_left = 30 - elapsed_seconds;
	if time_left < 0: time_left = 0
	var time_color = "blue" if time_left > 0 else "red"
	var swipes_left = 5 - swipes
	if swipes_left < 0: swipes_left = 0
	var swipes_color = "blue" if swipes_left > 0 else "red"
	$ObjectiveLabel.bbcode_text = "[center]Time: [color=" + time_color + "]" + str(time_left) + "[/color] / Swipes: [color=" + swipes_color + "]" + str(swipes_left) + "[/color][/center]"

func _on_Ball_block_hit(block):
	if !$Ball: return
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
