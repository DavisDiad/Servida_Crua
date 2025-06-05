extends Node2D

@export var inv: Inv

func collect(item):
	inv.insert(item)


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/cenários/corredor_quartos/corredor_quartos.tscn")
