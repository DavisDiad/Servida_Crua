extends Area2D

var entered = false


func _on_body_entered(body: Node2D) -> void:
	entered = true


func _on_body_exited(body: Node2D) -> void:
	entered = false


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click") and entered == true:
		get_tree().change_scene_to_file("res://scenes/WC/wc.tscn")
