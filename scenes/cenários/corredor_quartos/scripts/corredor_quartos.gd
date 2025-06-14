extends Node2D

var entered_avo = false

var next_spawn = Vector2(513.0,476.0)

func _on_button_corredor_pressed() -> void:
	PlayerHealth.spawn = next_spawn
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/cenários/corredor/corredor.tscn")
