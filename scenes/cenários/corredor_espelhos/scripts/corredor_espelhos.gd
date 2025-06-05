extends Node2D


func _on_button_corredor_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/cenários/entrada_principal/entrada_principal.tscn")


func _on_button_cave_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/cenários/cave/cave.tscn")
