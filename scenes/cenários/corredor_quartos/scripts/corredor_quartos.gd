extends Node2D

var entered_avo = false


func _on_button_corredor_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/cenários/corredor/corredor.tscn")
