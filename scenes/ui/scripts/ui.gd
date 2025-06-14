extends CanvasLayer

@onready var inv: Inv = preload("res://inventory/playerinv.tres")
@onready var slots: Array = $GridContainer.get_children()

@onready var portrait_0 = preload("res://scenes/ui/sprites/expressoes_ui(1).png") 
@onready var portrait_1 = preload("res://scenes/ui/sprites/expressoes_ui2.png") 
@onready var portrait_2 = preload("res://scenes/ui/sprites/expressoes_ui3.png") 
@onready var portrait_3 = preload("res://scenes/ui/sprites/expressoes_ui4.png") 
@onready var portrait_4 = preload("res://scenes/ui/sprites/expressoes_ui5.png") 

@onready var portrait_sprite: TextureRect = $Portrait

var portraits: Array[Texture] = []

var mouse_default = preload("res://placeholders/cursor.png")

func _ready() -> void:
	Transition.fade_in()
	
	Input.set_custom_mouse_cursor(mouse_default, Input.CURSOR_ARROW)
	
	inv.update.connect(update_slots)
	update_slots()
	
	# Preenche a lista com os portraits exportados
	portraits = [portrait_0, portrait_1, portrait_2, portrait_3, portrait_4]
	
	# Conecta ao sinal global
	GameState.connect("battle_completed", _on_battle_completed)

	# Se necessário, mostra o retrato atual ao entrar numa nova cena
	update_portrait(GameState.current_battle)


func _on_battle_completed(battle_number: int):
	update_portrait(battle_number)

func update_portrait(index: int):
	if index >= 0 and index < portraits.size():
		portrait_sprite.texture = portraits[index]


func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])
	

func _process(delta: float) -> void:
	update_wound_display() 

func update_wound_display():
	for part in PlayerHealth.wounds.keys():
		var label = $WoundsPanel.get_node(part + "_label")
		
		if label:
			# Acesse o limite máximo de feridas para cada parte
			var max_wounds = PlayerHealth.wound_limits.get(part) 
			# Verifique se o número de feridas atingiu o limite máximo
			if PlayerHealth.wounds[part] >= max_wounds:
				label.text = "-"  # Se atingiu o limite, exibe "-"
			else:
				label.text = str(PlayerHealth.wounds[part])  # Caso contrário, exibe o número de feridas
				
		var left_leg_wounded = PlayerHealth.wounds["left_leg"] >= PlayerHealth.wound_limits["left_leg"]
		var right_leg_wounded = PlayerHealth.wounds["right_leg"] >= PlayerHealth.wound_limits["right_leg"]
		var left_arm_wounded = PlayerHealth.wounds["left_arm"] >= PlayerHealth.wound_limits["left_arm"]
		var right_arm_wounded = PlayerHealth.wounds["right_arm"] >= PlayerHealth.wound_limits["right_arm"]
		
		if left_leg_wounded:
			$left_leg.hide()
		if right_leg_wounded:
			$right_leg.hide()
		if left_arm_wounded:
			$left_arm.hide()
		if right_arm_wounded:
			$right_arm.hide()
