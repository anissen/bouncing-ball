extends Node2D

var swipes := 0
var elapsed_seconds := 0
var is_swiping := false

const TIME_BEFORE_RESTART = 1

onready var explosion_scene := preload("res://Explosion.tscn")
export (Array, PackedScene) var level_scenes
var game_over := false

func _ready() -> void:
	load_level()

func load_level():
	$GameStuff/Line2D.visible = false
	var level = Game.level
	if level < level_scenes.size():
		var level_scene = level_scenes[level].instance()
		add_child_below_node($Level, level_scene)
		update_label()
	else:
		$GameStuff/LevelWonMessage.bbcode_text = "[center]Game Won![/center]"
		$GameStuff/LevelWonMessage.show()

func _input(event :InputEvent):
	if !get_node_or_null("GameStuff/Ball"): return

	if event.is_action_pressed("ui_touch") and swipes < 5:
		is_swiping = true
		$GameStuff/Line2D.visible = true
		Engine.time_scale = 0.2
	elif event.is_action_released("ui_touch") and is_swiping:
		is_swiping = false
		swipes += 1
		Engine.time_scale = 1
		$GameStuff/Line2D.visible = false
		var diff = event.position - $GameStuff/Ball.position
		$GameStuff/Ball.apply_central_impulse(diff * 3)
		update_label()

	if event.is_action_released("restart"):
		get_tree().reload_current_scene()

func _process(delta):
	if !get_node_or_null("GameStuff/Ball"):
		$GameStuff/Line2D.visible = false
		return

	if is_swiping:
		$GameStuff/Line2D.set_point_position(0, get_global_mouse_position())
		$GameStuff/Line2D.set_point_position(1, $GameStuff/Ball.position)

func update_label():
	var time_left = 15 - elapsed_seconds
	if time_left < 0: time_left = 0
	var time_color = "#0074D9" if time_left > 0 else "#FF4136"
	var swipes_left = 5 - swipes
	if swipes_left < 0: swipes_left = 0
	var swipes_color = "#0074D9" if swipes_left > 0 else "#FF4136"
	$GameStuff/ObjectiveLabel.bbcode_text = "[center]Time: [color=" + time_color + "]" + str(time_left) + "[/color] / Swipes: [color=" + swipes_color + "]" + str(swipes_left) + "[/color][/center]"

	if time_left == 0 and swipes_left == 0:
		game_over(false)

func _on_Ball_block_hit(block):
	if !get_node_or_null("GameStuff/Ball"): return
	if !block.destructable: return

	block.queue_free()
	if block.type == block.Type.EXPLOSIVE: game_over(false)

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

	if has_won: game_over(true)

func _on_GameTimer_timeout():
	elapsed_seconds += 1
	update_label()

func game_over(won):
	if game_over: return
	game_over = true
	Engine.time_scale = 1
	if get_node_or_null("GameStuff/Ball"): $GameStuff/Ball.queue_free()
	if won: $GameStuff/LevelWonMessage.show()
	else: $GameStuff/LevelLostMessage.show()

	yield(get_tree().create_timer(TIME_BEFORE_RESTART), "timeout")

	if won: Game.level += 1
	get_tree().reload_current_scene()
