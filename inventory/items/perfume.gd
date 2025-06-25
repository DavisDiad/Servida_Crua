extends Area2D

@export var item: InvItem
@onready var container := get_parent().get_parent() # Caminho até o Node2D com `collect()`

signal textbox_closed

var talking = false

var mouse_hover = preload("res://placeholders/mouse_hover.png")
var default = preload("res://placeholders/cursor.png")

func _ready() -> void:
	if GameState.perfume_collected == true:
		$"..".visible = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click") and talking == true: #ao clicar com o botão esquerdo com o texto ativo,
		$"../../UI/TextBox".hide() #ele é escondido
		emit_signal("textbox_closed") # e o sinal é emitido para fazer os botoes aparecerem


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click") and GameState.perfume_collected == false:
		if container.has_method("collect"):
			container.collect(item)
			$"..".visible = false
			GameState.perfume_collected = true
			display_text("(Um perfume que evoca uma nostalgia intensa em ti, como uma memória perdida.)")
			

func display_text(text): #esta função serve para fazer o texto aparecer
	$"../../UI/TextBox".show()
	$"../../UI/TextBox/Label".text = text
	
	talking = true
	
	await textbox_closed #o jogo está a espera que este sinal seja emitido para processar o codigo embaixo
	 #quando o sinal é emitido, os botoes aparecem
	talking = false


func _on_mouse_entered() -> void:
	if GameState.perfume_collected == false:
		Input.set_custom_mouse_cursor(mouse_hover, Input.CURSOR_ARROW)


func _on_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(default, Input.CURSOR_ARROW)
