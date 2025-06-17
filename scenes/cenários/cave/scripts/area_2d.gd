extends Area2D


var next_spawn = Vector2(503.0,645.0)
var clicked = false


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click") and clicked == false:
		clicked = true
		Transition.transition()
		await Transition.on_transition_finished
		PlayerHealth.spawn = next_spawn
		get_tree().change_scene_to_file("res://scenes/fight/fight4.tscn")
