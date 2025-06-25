extends Node2D

@export var inv: Inv

var next_spawn = Vector2(1243.0,502.0)

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

func _ready() -> void:
	if GameState.tumor_collected == false:
		display_text("Ouço o som de sangue contra metal. Algo aqui quer ser encontrado por mim.")

func collect(item):
	inv.insert(item)


func _on_texture_button_pressed() -> void:
	PlayerHealth.spawn = next_spawn
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/cenários/corredor_quartos/corredor_quartos.tscn")


func _on_texture_button_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(mouse_hover, Input.CURSOR_ARROW)


func _on_texture_button_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(default, Input.CURSOR_ARROW)
