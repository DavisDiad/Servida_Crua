extends Panel

signal item_clicked(item: InvItem, index: int)

var item: InvItem = null
var index: int

@onready var item_visual : Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_text: Label = $CenterContainer/Panel/Label

func update(slot: InvSlot):
	if slot == null:
		item = null
		item_visual.visible = false
		amount_text.visible = false
		return
		
	item = slot.item  # <-- ISSO FALTAVA
	if !item:
		item_visual.visible = false
		amount_text.visible = false
	else:
		item_visual.visible = true
		item_visual.texture = item.texture
		if slot.amount > 1:
			amount_text.visible = true
			amount_text.text = str(slot.amount)
		else:
			amount_text.visible = false

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if item and item.equipable != null:
			emit_signal("item_clicked", item, index)
