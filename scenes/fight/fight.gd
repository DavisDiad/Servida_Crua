extends Node2D

signal textbox_closed #sinal que é emitido sempre que o texto é fechado
signal attacking
signal defending
signal talked

var can_attack = false
var talking = false

var enemy_data: EnemyData

var is_cat_dead = false #usar esta função para definir que quando o gato morre e esta cena sai, é armazenado num script global que ele ta morto e ao abrir novament esta cena, ou seja na função ready, isto vai estar verdadeiro e vai aprecer a amiga em vez dele.


func _ready() -> void:
	PlayerHealth.can_move = false
	var player = get_node("player")
	var anim = player.get_node("AnimatedSprite2D")
	anim.play("idle_battle")
	
	$UI/ActionsPanel.hide() #a cena começa com os botoes escondidos
	$UI/TextBox.show() #a cena começa com o texto a aparecer
	
	display_text("Um gato estranho bufa ao sentir a tua presença.") #chama a função que mostra texto
	await textbox_closed
	$UI/ActionsPanel.show()
	


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click") and talking == true: #ao clicar com o botão esquerdo com o texto ativo,
		$UI/TextBox.hide() #ele é escondido
		emit_signal("textbox_closed") # e o sinal é emitido para fazer os botoes aparecerem

func display_text(text): #esta função serve para fazer o texto aparecer
	$UI/ActionsPanel.hide()
	$UI/TextBox.show()
	$UI/TextBox/Label.text = text
	
	talking = true
	
	await textbox_closed #o jogo está a espera que este sinal seja emitido para processar o codigo embaixo
	 #quando o sinal é emitido, os botoes aparecem
	talking = false

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


func _on_defend_pressed() -> void:
	$UI/ActionsPanel.hide()
	$UI/TextBox.show()
	display_text("Assumes uma posição defensiva")
	await textbox_closed
	
	
	PlayerHealth.is_defending = true
	emit_signal("defending")
	
	


func _on_talk_pressed() -> void:
	emit_signal("talked")
