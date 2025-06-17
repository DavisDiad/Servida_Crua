extends Panel

signal equipment_clicked(item: InvItem, slot_ref: InvEquSlot)

@onready var item_equ_visual: Sprite2D = $CenterContainer/Panel/item_equ_display

var slotequ: InvEquSlot = null  # Referência ao slot

func update(slot_to_display: InvEquSlot):
	slotequ = slot_to_display
	if not slotequ or not slotequ.item:
		item_equ_visual.visible = false
	else:
		item_equ_visual.visible = true
		item_equ_visual.texture = slotequ.item.texture

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if slotequ and slotequ.item:
			emit_signal("equipment_clicked", slotequ.item, slotequ)
