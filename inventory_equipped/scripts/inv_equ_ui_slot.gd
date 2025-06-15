extends Panel

@onready var item_equ_visual: Sprite2D = $CenterContainer/Panel/item_equ_display

func update(slotequ: InvEquSlot):
	if !slotequ.itemequ:
		item_equ_visual.visible = false
	else:
		item_equ_visual.visible = true
		item_equ_visual.texture = slotequ.itemequ.texture
