extends Button


func _on_pressed() -> void:
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
