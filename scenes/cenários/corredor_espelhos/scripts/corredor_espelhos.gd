extends Node2D

var next_spawn1 = Vector2(518.0,537.0)
var next_spawn2 = Vector2(503.0,645.0)

var mouse_hover = preload("res://placeholders/mouse_hover.png")
var default = preload("res://placeholders/cursor.png")

func _on_button_corredor_pressed() -> void:
	PlayerHealth.spawn = next_spawn1
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/cenários/entrada_principal/entrada_principal.tscn")


func _on_button_cave_pressed() -> void:
	if GameState.tumor_collected == true:
		PlayerHealth.spawn = next_spawn2
		Transition.transition()
		await Transition.on_transition_finished
		get_tree().change_scene_to_file("res://scenes/cenários/cave/cave.tscn")


func _on_button_corredor_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(mouse_hover, Input.CURSOR_ARROW)


func _on_button_corredor_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(default, Input.CURSOR_ARROW)


func _on_button_cave_mouse_entered() -> void:
	if GameState.tumor_collected == true:
		Input.set_custom_mouse_cursor(mouse_hover, Input.CURSOR_ARROW)


func _on_button_cave_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(default, Input.CURSOR_ARROW)
