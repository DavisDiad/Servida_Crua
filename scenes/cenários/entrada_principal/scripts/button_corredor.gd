extends TextureButton

var next_spawn = Vector2(1458.0,511.0)

func _on_pressed() -> void:
	if GameState.tumor_collected == true and GameState.cutscene_played == false:
		GameState.cutscene_played = true
		PlayerHealth.spawn = next_spawn
		Transition.transition()
		await Transition.on_transition_finished
		get_tree().change_scene_to_file("res://scenes/cutscene2/cutscene_2.tscn")
	else:
		PlayerHealth.spawn = next_spawn
		Transition.transition()
		await Transition.on_transition_finished
		get_tree().change_scene_to_file("res://scenes/cenários/corredor_espelhos/corredor_espelhos.tscn")
