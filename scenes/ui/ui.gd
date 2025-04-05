extends CanvasLayer

func update_wound_display():
	for part in PlayerHealth.wounds.keys():
		var label = $WoundsPanel.get_node(part + "_label")
		if label:
			label.text = str(PlayerHealth.wounds[part])
