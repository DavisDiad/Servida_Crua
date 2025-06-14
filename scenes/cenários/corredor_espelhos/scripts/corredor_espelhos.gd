extends Node2D

var next_spawn1 = Vector2(518.0,537.0)
var next_spawn2 = Vector2(503.0,645.0)


func _on_button_corredor_pressed() -> void:
	PlayerHealth.spawn = next_spawn1
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/cenários/entrada_principal/entrada_principal.tscn")


func _on_button_cave_pressed() -> void:
	PlayerHealth.spawn = next_spawn2
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/cenários/cave/cave.tscn")
