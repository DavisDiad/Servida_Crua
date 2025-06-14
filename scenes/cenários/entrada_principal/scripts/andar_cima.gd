extends Area2D

var entered = false

var clicked = false

var next_spawn = Vector2(974.0,500.0)

func _on_body_entered(body: Node2D) -> void:
	entered = true


func _on_body_exited(body: Node2D) -> void:
	entered = false


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click") and entered == true and clicked == false:
		clicked = true
		PlayerHealth.spawn = next_spawn
		Transition.transition()
		await Transition.on_transition_finished
		get_tree().change_scene_to_file("res://scenes/cenários/corredor/corredor.tscn")
