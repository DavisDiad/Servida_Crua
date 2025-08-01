extends Area2D

@export var next_scene: String
@export var player: Node
@onready var anim: AnimatedSprite2D = player.get_node("AnimatedSprite2D")

var mouse_hover = preload("res://placeholders/mouse_hover.png")
var default = preload("res://placeholders/cursor.png")

var is_hovered := false
var is_player_inside := false
var is_transitioning := false
var clicked := false

var next_spawn = Vector2(503.0,645.0)

func _ready() -> void:
	var is_hovered := false
	var is_player_inside := false
	var is_transitioning := false

func _on_mouse_entered():
	is_hovered = true
	_check_move_lock()
	Input.set_custom_mouse_cursor(mouse_hover, Input.CURSOR_ARROW)

func _on_mouse_exited():
	is_hovered = false
	_check_move_lock()
	Input.set_custom_mouse_cursor(default, Input.CURSOR_ARROW)

func _on_body_entered(body):
	if body == player:
		is_player_inside = true
		_check_move_lock()

func _on_body_exited(body):
	if body == player:
		is_player_inside = false
		_check_move_lock()

func _check_move_lock():
	PlayerHealth.can_move = not (is_hovered and is_player_inside)

func _on_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("left_click") and is_hovered and is_player_inside and is_transitioning == false and clicked == false and player.velocity == Vector2.ZERO:
		is_transitioning = true
		anim.stop()
		play_action_animation("interaction")
		clicked = true
		Transition.transition()
		await anim.animation_finished
		await Transition.on_transition_finished
		PlayerHealth.spawn = next_spawn
		get_tree().change_scene_to_file(next_scene)

func play_action_animation(action: String):
	var arm_state = PlayerHealth.get_arm_state()
	var anim_name = action

	match arm_state:
		"no_arms":
			anim_name += "_desmemberd"
		"left_only":
			anim_name += "_without_r_a"
		"right_only":
			anim_name += "_without_l_a"
		"both_arms":
			pass

	anim.play(anim_name)
	
