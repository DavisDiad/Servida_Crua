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

signal textbox_closed
var talking := false

var portraits: Array[Texture] = []

var mouse_default = preload("res://placeholders/cursor.png")

var selected_item: InvItem = null
var selected_slot_index: int = -1

var selected_equ_slot: InvEquSlot = null
var selected_equ_item: InvItem = null

var analyze_sequences := {
	"anel": [
		"(Uma herança de sua mãe. Foi deixado para a filha como proteção. Um gesto de amor, de salvação, mesmo depois da morte. Mas este anel não é só memória. É como um abraço apertado da mãe...)",
		"(Dá +2 de vida a todas as partes do corpo. Além disso, pode recuperar membros perdidos depois de um tempo.)"
	],
	"perfume": [
		"(Cheiro doce, que até abafa as dores vividas… O que era sensação de leveza, oxigenou e virou doença. Há algo neste aroma que já não pertence a este corpo. Nem a este tempo.)",
		"(Aumenta o dano máximo em +2.)"
	],
	"olho": [
		"(Olho com entranhas de perseguição e culpa. Parecido com o que nascia. Quem o retirou tomou-o como troféu… ou repulsa? O que restou foi um silêncio e uma verdade servida crua.)",
		"(Aumenta a chance de acerto em +10.)"
	],
	"tumor": [
		"(Pintava com o que sangrava. Chamava-lhe arte. Mas tudo o que criava já nascia podre.)",
		"(Aumenta o dano máximo em +3.)"
	],
	"bandagens": [
		"(Usado para curar o corpo. Mas e para curar a alma?)",
		"(Cura entre 1 a 3 feridas em todas as partes do corpo.)"
	]
	
}

var current_analyze_sequence: Array = []
var analyze_index := 0
var analyzing := false

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
	
	if GameState.text_introduction == false:
		display_text("(Depois da morte da tua melhor amiga, tiveste de voltar à casa onde tudo começou. Mas algo aqui dentro não te esqueceu.)")
		await textbox_closed
		GameState.text_introduction = true


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
		$EquipPanel.visible = true
	elif not item.is_equipable and GameState.can_equip == true:
		$EquipPanel.visible = false
		$HealPanel.visible = true


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
			$EquipPanel.visible = false
			
			display_text("(Braço incapacitado.Não é possível equipar o item.)")
			await textbox_closed
			
			var actions_panel := get_node_or_null("ActionsPanel")
			if actions_panel:
				actions_panel.visible = true

func _on_analyze_pressed() -> void:
	print("clicado")
	if not selected_item:
		print("Nenhum item selecionado")
		return

	var item_name = selected_item.name.strip_edges().to_lower()
	print("Analisando item:", item_name)

	if not analyze_sequences.has(item_name):
		print("Item NÃO encontrado no dicionário!")
		return

	# Configura sequência
	current_analyze_sequence = analyze_sequences[item_name]
	analyze_index = 0
	analyzing = true

	# Esconde botões
	var actions_panel = get_node_or_null("ActionsPanel")
	if actions_panel:
		actions_panel.visible = false
	$EquipPanel.visible = false
	$HealPanel.visible = false
	$DesequipPanel.visible = false

	# Mostra textbox e primeira frase
	$TextureRect/TextBox.show()
	$TextureRect/TextBox/Label.text = current_analyze_sequence[analyze_index]
	talking = true

	# Espera que diálogo termine
	await textbox_closed

	# Ao terminar, reexibe botões
	analyzing = false
	talking = false
	current_analyze_sequence.clear()

	if actions_panel:
		actions_panel.visible = true


func _on_desequip_pressed():
	if selected_equ_slot and selected_equ_slot.item:
		var base_item = selected_equ_slot.item
		
		if base_item.name == "anel":
			$DesequipPanel.visible = false
			
			display_text("(Uma força sobrenatural prende o anel a ti.)")
			await textbox_closed
			
			var actions_panel := get_node_or_null("ActionsPanel")
			if actions_panel:
				actions_panel.visible = true
			return
		
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
			$DesequipPanel.visible = false
			var actions_panel := get_node_or_null("ActionsPanel")
			if actions_panel:
				actions_panel.visible = true

func _on_heal_pressed() -> void:
	for part in PlayerHealth.wounds.keys():
		var current_wounds = PlayerHealth.wounds[part]
		var max_wounds = PlayerHealth.wound_limits.get(part, 0)
		
		# Só cura se feridas > 0 e feridas < limite máximo (não está "morto"/inutilizável)
	var any_healed = false
	
	for part in PlayerHealth.wounds.keys():
		var current_wounds = PlayerHealth.wounds[part]
		var max_wounds = PlayerHealth.wound_limits.get(part, 0)
		
		# Só cura se feridas > 0 e feridas < limite máximo (não está "morto"/inutilizável)
		if current_wounds > 0 and current_wounds < max_wounds:
			var heal_amount = randi_range(1, 3)
			PlayerHealth.wounds[part] = max(0, current_wounds - heal_amount)
			any_healed = true
	
	if any_healed:
		# Atualiza a UI das feridas
		update_wound_display()

		# Reduz a stack de bandagens
		inv.slots[selected_slot_index].amount -= 1

		# Remove slot se acabar as bandagens
		if inv.slots[selected_slot_index].amount <= 0:
			inv.slots[selected_slot_index] = InvSlot.new()

		# Atualiza UI
		update_slots()
		$HealPanel.visible = false
		var actions_panel := get_node_or_null("ActionsPanel")
		if actions_panel:
			actions_panel.visible = true

	else:
		$HealPanel.visible = false
		var actions_panel := get_node_or_null("ActionsPanel")
		if actions_panel:
			actions_panel.visible = true

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

func display_text(text: String) -> void:
	$TextureRect/TextBox.show()
	$TextureRect/TextBox/Label.text = text
	talking = true
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		if talking and not analyzing:
			$TextureRect/TextBox.hide()
			talking = false
			emit_signal("textbox_closed")

		elif analyzing:
			analyze_index += 1
			if analyze_index < current_analyze_sequence.size():
				$TextureRect/TextBox/Label.text = current_analyze_sequence[analyze_index]
			else:
				$TextureRect/TextBox.hide()
				analyzing = false
				talking = false
				current_analyze_sequence = []
