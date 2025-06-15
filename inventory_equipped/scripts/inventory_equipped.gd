extends Resource

class_name InvEqu

signal update

@export var weapon: InvEquSlot
@export var object: InvEquSlot
@export var accessory: InvEquSlot

func insert(itemeq: InvEquItem):
	match itemeq.type:
		"weapon":
			if weapon == null:
				weapon = InvEquSlot.new()
			weapon.itemequ = itemeq
		"object":
			if object == null:
				object = InvEquSlot.new()
			object.itemequ = itemeq
		"accessory":
			if accessory == null:
				accessory = InvEquSlot.new()
			accessory.itemequ = itemeq

	# Aplicar os efeitos no player após equipar
	apply_item_stats(itemeq)
	
func apply_item_stats(item: InvEquItem):
	PlayerHealth.min_damage += item.min_damage
	PlayerHealth.max_damage += item.max_damage
	PlayerHealth.base_accuracy += item.accuracy
	
	# Adicionar evasão — exemplo genérico (você pode adaptar melhor):
	for part in PlayerHealth.evasion_per_part.keys():
		PlayerHealth.evasion_per_part[part] += item.evasion
	
	# Adicionar ferimentos máximos:
	for part in PlayerHealth.wound_limits.keys():
		PlayerHealth.wound_limits[part] += item.max_wounds
