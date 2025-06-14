extends TextureButton

var next_spawn = Vector2(513.0,326.0)

func _on_pressed() -> void:
	PlayerHealth.spawn = next_spawn
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/cenários/entrada_principal/entrada_principal.tscn")
