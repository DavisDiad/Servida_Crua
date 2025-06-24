extends Resource
class_name InvEqu

signal update
var inv_ref: Inv
@export var weapon: InvEquSlot
@export var object: InvEquSlot
@export var accessory: InvEquSlot


func insert(item: InvItem) -> bool:
	var old_item: InvItem = null

	match item.type:
		"weapon":
			if PlayerHealth.wounds["right_arm"] >= PlayerHealth.wound_limits["right_arm"]:
				print("Braço direito inutilizado. Não é possível equipar armas.")
				return false

		"object":
			if PlayerHealth.wounds["left_arm"] >= PlayerHealth.wound_limits["left_arm"]:
				print("Braço esquerdo inutilizado. Não é possível equipar objetos.")
				return false

	# Verifica os slots normalmente
	match item.type:
		"weapon":
			if weapon == null:
				weapon = InvEquSlot.new()
			old_item = weapon.item
			if old_item:
				remove_item_stats(old_item)
				_return_item_to_inventory(old_item)
			weapon.item = item

		"object":
			if object == null:
				object = InvEquSlot.new()
			old_item = object.item
			if old_item:
				remove_item_stats(old_item)
				_return_item_to_inventory(old_item)
			object.item = item

		"accessory":
			if accessory == null:
				accessory = InvEquSlot.new()
			
			# ⚠️ Impede troca se o item atual for o "anel"
			if accessory.item and accessory.item.name == "anel":
				print("O anel não pode ser removido. Troca cancelada.")
				return false

			old_item = accessory.item
			if old_item:
				remove_item_stats(old_item)
				_return_item_to_inventory(old_item)
			
			accessory.item = item

	apply_item_stats(item)
	emit_signal("update")
	return true

func _return_item_to_inventory(item: InvItem) -> void:
	if inv_ref == null or inv_ref.slots == null:
		push_error("inv_ref está null ou mal atribuído. Não foi possível retornar item ao inventário.")
		return

	for slot in inv_ref.slots:
		if slot.item == null:
			slot.item = item
			print("Item retornado ao inventário:", item.name)
			return

	print("Inventário cheio! Item descartado:", item.name)

func apply_item_stats(item: InvItem):
	if item == null:
		return

	print("Aplicado:", item.name)
	print("Dano antes:", PlayerHealth.min_damage)
	PlayerHealth.min_damage += item.min_damage
	print("Dano depois:", PlayerHealth.min_damage)

	PlayerHealth.max_damage += item.max_damage
	PlayerHealth.base_accuracy += item.accuracy

	for part in PlayerHealth.evasion_per_part.keys():
		PlayerHealth.evasion_per_part[part] += item.evasion

	for part in PlayerHealth.wound_limits.keys():
		PlayerHealth.wound_limits[part] += item.max_wounds

func remove_item_stats(item: InvItem):
	if item == null:
		return

	PlayerHealth.min_damage -= item.min_damage
	PlayerHealth.max_damage -= item.max_damage
	PlayerHealth.base_accuracy -= item.accuracy

	for part in PlayerHealth.evasion_per_part.keys():
		PlayerHealth.evasion_per_part[part] -= item.evasion

	for part in PlayerHealth.wound_limits.keys():
		PlayerHealth.wound_limits[part] -= item.max_wounds

func unequip_item(slot: InvEquSlot):
	if slot != null and slot.item != null:
		remove_item_stats(slot.item)
		slot.item = null
		emit_signal("update") 

func force_unequip_and_return(slot: InvEquSlot) -> void:
	if slot.item:
		# Procura slot vazio no inventário
		for i in range(inv_ref.slots.size()):
			if inv_ref.slots[i].item == null:
				var new_slot = InvSlot.new()
				new_slot.item = slot.item
				inv_ref.slots[i] = new_slot
				slot.item = null
				emit_signal("update")
				inv_ref.emit_signal("update")
				return
		print("Inventário cheio! Item perdido.")
		slot.item = null
		emit_signal("update")
		inv_ref.emit_signal("update")
