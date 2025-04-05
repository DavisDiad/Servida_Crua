extends Node2D

signal textbox_closed #sinal que é emitido sempre que o texto é fechado
signal attacking
var can_attack = false

func _ready() -> void:
	
	$UI/ActionsPanel.hide() #a cena começa com os botoes escondidos
	$UI/TextBox.show() #a cena começa com o texto a aparecer
	$UI.update_wound_display()
	
	display_text("Um gato estranho bufa ao sentir a tua presença.") #chama a função que mostra texto
	
	
	await textbox_closed #o jogo está a espera que este sinal seja emitido para processar o codigo embaixo
	$UI/ActionsPanel.show() #quando o sinal é emitido, os botoes aparecem

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"): #ao clicar com o botão esquerdo com o texto ativo,
		$UI/TextBox.hide() #ele é escondido
		emit_signal("textbox_closed") # e o sinal é emitido para fazer os botoes aparecerem

func display_text(text): #esta função serve para fazer o texto aparecer
	$UI/ActionsPanel.hide()
	$UI/TextBox.show()
	$UI/TextBox/Label.text = text

func _on_attack_pressed() -> void:
	can_attack = true
	attack()
	

func attack():
	if can_attack == true:
		$UI/ActionsPanel.hide()
		emit_signal("attacking")
		
	else:
		can_attack = false
		return
		
func set_health():
	pass

	
