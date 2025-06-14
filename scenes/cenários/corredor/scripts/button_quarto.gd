extends TextureButton

var next_spawn = Vector2(510.0,498.0)

func _on_pressed() -> void:
	PlayerHealth.spawn = next_spawn
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/cenários/corredor_quarto/corredor_quarto.tscn")
