extends Area2D

@export var player: Node
@onready var anim: AnimatedSprite2D = player.get_node("AnimatedSprite2D")

var mouse_hover = preload("res://placeholders/mouse_hover.png")
var default = preload("res://placeholders/cursor.png")

var is_hovered := false
var is_player_inside := false
var is_transitioning := false

var next_spawn = Vector2(503.0,645.0)

signal textbox_closed
var talking = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click") and talking == true: #ao clicar com o botão esquerdo com o texto ativo,
		$"../UI/TextBox".hide() #ele é escondido
		emit_signal("textbox_closed") # e o sinal é emitido para fazer os botoes aparecerem
		
func display_text(text): #esta função serve para fazer o texto aparecer
	$"../UI/TextBox".show()
	$"../UI/TextBox/Label".text = text
	
	talking = true
	
	await textbox_closed #o jogo está a espera que este sinal seja emitido para processar o codigo embaixo
	 #quando o sinal é emitido, os botoes aparecem
	talking = false

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
	if Input.is_action_just_pressed("left_click") and is_hovered and is_player_inside and is_transitioning == false and player.velocity == Vector2.ZERO and GameState.bau_collected == true:
		is_transitioning = true
		anim.stop()
		play_action_animation("interaction")
		Transition.transition()
		PlayerHealth.spawn = next_spawn
		await anim.animation_finished
		await Transition.on_transition_finished
		if GameState.grandpa_dead == false:
			get_tree().change_scene_to_file("res://scenes/fight/fight3.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/cenários/quarto_avo/quarto_avo.tscn")
	elif  Input.is_action_just_pressed("left_click") and is_hovered and is_player_inside and is_transitioning == false and player.velocity == Vector2.ZERO:
		display_text("Está trancado. Talvez possa encontrar algo para abrir.")
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
	
