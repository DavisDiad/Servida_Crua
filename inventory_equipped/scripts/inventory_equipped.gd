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
	update.emit()
