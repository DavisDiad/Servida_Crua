extends Node2D

@export var inv: Inv

var next_spawn = Vector2(1243.0,502.0)

func collect(item):
	inv.insert(item)


func _on_texture_button_pressed() -> void:
	PlayerHealth.spawn = next_spawn
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/cenários/corredor_quartos/corredor_quartos.tscn")
