extends Node2D

var next_spawn1 = Vector2(518.0,537.0)
var next_spawn2 = Vector2(503.0,645.0)

var mouse_hover = preload("res://placeholders/mouse_hover.png")
var default = preload("res://placeholders/cursor.png")

signal textbox_closed
var talking = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click") and talking == true: #ao clicar com o botão esquerdo com o texto ativo,
		$UI/TextBox.hide() #ele é escondido
		emit_signal("textbox_closed") # e o sinal é emitido para fazer os botoes aparecerem
		
func display_text(text): #esta função serve para fazer o texto aparecer
	$UI/TextBox.show()
	$UI/TextBox/Label.text = text
	
	talking = true
	
	await textbox_closed #o jogo está a espera que este sinal seja emitido para processar o codigo embaixo
	 #quando o sinal é emitido, os botoes aparecem
	talking = false

func _on_button_corredor_pressed() -> void:
	PlayerHealth.spawn = next_spawn1
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/cenários/entrada_principal/entrada_principal.tscn")


func _on_button_cave_pressed() -> void:
	if GameState.tumor_collected == true:
		PlayerHealth.spawn = next_spawn2
		Transition.transition()
		await Transition.on_transition_finished
		get_tree().change_scene_to_file("res://scenes/cenários/cave/cave.tscn")
	else:
		display_text("Está trancado...")


func _on_button_corredor_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(mouse_hover, Input.CURSOR_ARROW)


func _on_button_corredor_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(default, Input.CURSOR_ARROW)


func _on_button_cave_mouse_entered() -> void:
	if GameState.tumor_collected == true:
		Input.set_custom_mouse_cursor(mouse_hover, Input.CURSOR_ARROW)


func _on_button_cave_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(default, Input.CURSOR_ARROW)
