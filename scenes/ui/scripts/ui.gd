extends CanvasLayer

@onready var inv: Inv = preload("res://inventory/playerinv.tres")
@onready var slots: Array = $GridContainer.get_children()

@onready var inv_equ: InvEqu = preload("res://inventory_equipped/playerequinv.tres")
@onready var slots_equ: Array = $Control.get_children()

@onready var portrait_0 = preload("res://scenes/ui/sprites/expressoes_ui(1).png") 
@onready var portrait_1 = preload("res://scenes/ui/sprites/expressoes_ui2.png") 
@onready var portrait_2 = preload("res://scenes/ui/sprites/expressoes_ui3.png") 
@onready var portrait_3 = preload("res://scenes/ui/sprites/expressoes_ui4.png") 
@onready var portrait_4 = preload("res://scenes/ui/sprites/expressoes_ui5.png") 

@onready var portrait_sprite: TextureRect = $Portrait

var portraits: Array[Texture] = []

var mouse_default = preload("res://placeholders/cursor.png")

var selected_item: InvItem = null
var selected_slot_index: int = -1

var selected_equ_slot: InvEquSlot = null
var selected_equ_item: InvItem = null

func _ready() -> void:
	Transition.fade_in()
	
	Input.set_custom_mouse_cursor(mouse_default, Input.CURSOR_ARROW)
	
	inv_equ.inv_ref = inv
	
	inv.update.connect(update_slots)
	inv_equ.update.connect(update_equ_slots)
	update_slots()
	
	update_equ_slots()
	
	# Preenche a lista com os portraits exportados
	portraits = [portrait_0, portrait_1, portrait_2, portrait_3, portrait_4]
	
	# Conecta ao sinal global
	GameState.connect("battle_completed", _on_battle_completed)

	# Se necessário, mostra o retrato atual ao entrar numa nova cena
	update_portrait(GameState.current_battle)
	
	GameState.can_equip = true
	


func _on_battle_completed(battle_number: int):
	update_portrait(battle_number)

func update_portrait(index: int):
	if index >= 0 and index < portraits.size():
		portrait_sprite.texture = portraits[index]


func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].index = i
		slots[i].update(inv.slots[i])
		if not slots[i].is_connected("item_clicked", Callable(self, "_on_item_clicked")):
			slots[i].connect("item_clicked", Callable(self, "_on_item_clicked"))
	

func update_equ_slots():
	var item_map = {
		"weapon": inv_equ.weapon,
		"object": inv_equ.object,
		"accessory": inv_equ.accessory
	}

	for i in range(slots_equ.size()):
		var key = item_map.keys()[i]
		var slot_ui = slots_equ[i]
		slot_ui.update(item_map[key])
		
		if not slot_ui.is_connected("equipment_clicked", Callable(self, "_on_equipment_clicked")):
			slot_ui.connect("equipment_clicked", Callable(self, "_on_equipment_clicked"))


func _on_item_clicked(item: InvItem, index: int):
	selected_item = item
	selected_slot_index = index

	var actions_panel := get_node_or_null("ActionsPanel")
	if actions_panel:
		actions_panel.visible = false

	if item.is_equipable and GameState.can_equip == true:
		print("Painel de equipar visível")
		$EquipPanel.visible = true
	else:
		$EquipPanel.visible = false


func _on_equipment_clicked(item: InvItem, slot_ref: InvEquSlot):
	selected_equ_item = item
	selected_equ_slot = slot_ref

	var actions_panel := get_node_or_null("ActionsPanel")
	if actions_panel:
		actions_panel.visible = false
	
	if  GameState.can_equip == true:
		$DesequipPanel.visible = true

func _on_equip_pressed():
	if selected_item and selected_item.is_equipable:
		var success := inv_equ.insert(selected_item)

		if success:
			# Remover do inventário apenas se o item foi realmente equipado
			inv.slots[selected_slot_index] = InvSlot.new()
			update_slots()
			update_equ_slots()
			$EquipPanel.visible = false
			var actions_panel := get_node_or_null("ActionsPanel")
			if actions_panel:
				actions_panel.visible = true
		else:
			print("Não foi possível equipar. Membro ferido.")


func _on_desequip_pressed():
	if selected_equ_slot and selected_equ_slot.item:
		var base_item = selected_equ_slot.item
		var added = false

		# Adiciona de volta ao inventário
		for i in range(inv.slots.size()):
			if inv.slots[i].item == null:
				var new_slot = InvSlot.new()
				new_slot.item = base_item
				inv.slots[i] = new_slot
				added = true
				break

		if added:
			inv_equ.unequip_item(selected_equ_slot)
			update_slots()
			update_equ_slots()
			$DesequipPanel.visible = false
			var actions_panel := get_node_or_null("ActionsPanel")
			if actions_panel:
				actions_panel.visible = true
				
		else:
			print("Inventário cheio!")

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
