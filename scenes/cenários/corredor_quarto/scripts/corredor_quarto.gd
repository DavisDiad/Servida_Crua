extends Node2D

@onready var change_sprite = preload("res://scenes/cenários/corredor_quarto/sprites/quarto_amaldicoado.PNG")

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
	if GameState.grandpa_dead == true:
		$TextureRect.texture = change_sprite


func _on_quarto_helena_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(mouse_hover, Input.CURSOR_ARROW)


func _on_quarto_helena_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(default, Input.CURSOR_ARROW)


func _on_quarto_helena_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		display_text("Está trancado.")
