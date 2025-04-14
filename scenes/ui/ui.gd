extends CanvasLayer

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
