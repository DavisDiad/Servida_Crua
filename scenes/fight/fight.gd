extends Node2D

signal textbox_closed #sinal que é emitido sempre que o texto é fechado
signal attacking
signal defending

var can_attack = false

var enemy_data: EnemyData

func _ready() -> void:
	
	$UI/ActionsPanel.hide() #a cena começa com os botoes escondidos
	$UI/TextBox.show() #a cena começa com o texto a aparecer
	
	display_text("Um gato estranho bufa ao sentir a tua presença.") #chama a função que mostra texto
	await textbox_closed
	$UI/ActionsPanel.show()
	
	load_enemy("res://scenes/enemys/cat/cat.tres") #pode ser usado em qualquer lugar para chamar um inimigo diferente
	

func load_enemy(enemy_path: String) -> void: #função usada para carregar o inimigo quando load_enemy() é chamado
	var loaded_enemy = load(enemy_path)
	if loaded_enemy:
		enemy_data = loaded_enemy # Cria uma instância do resource EnemyData


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"): #ao clicar com o botão esquerdo com o texto ativo,
		$UI/TextBox.hide() #ele é escondido
		emit_signal("textbox_closed") # e o sinal é emitido para fazer os botoes aparecerem

func display_text(text): #esta função serve para fazer o texto aparecer
	$UI/ActionsPanel.hide()
	$UI/TextBox.show()
	$UI/TextBox/Label.text = text
	
	await textbox_closed #o jogo está a espera que este sinal seja emitido para processar o codigo embaixo
	 #quando o sinal é emitido, os botoes aparecem

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
	
	
