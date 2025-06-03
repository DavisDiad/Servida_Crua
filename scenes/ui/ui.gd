extends CanvasLayer

@onready var inv: Inv = preload("res://inventory/playerinv.tres")
@onready var slots: Array = $GridContainer.get_children()


func _ready() -> void:
	inv.update.connect(update_slots)
	update_slots()


func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])
	

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
