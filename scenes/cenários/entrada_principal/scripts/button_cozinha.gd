extends TextureButton

var next_spawn = Vector2(503.0,645.0)

func _on_pressed() -> void:
	PlayerHealth.spawn = next_spawn
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/fight/fight.tscn")
