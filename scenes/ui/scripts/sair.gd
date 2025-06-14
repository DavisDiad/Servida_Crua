extends Button


func _on_pressed() -> void:
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().quit()
