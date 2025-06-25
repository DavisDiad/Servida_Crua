extends Node2D

@onready var change_sprite = preload("res://scenes/cenários/corredor_quartos/sprites/IMG_0092.PNG")

var entered_avo = false

var next_spawn = Vector2(513.0,476.0)

var mouse_hover = preload("res://placeholders/mouse_hover.png")
var default = preload("res://placeholders/cursor.png")

func _on_button_corredor_pressed() -> void:
	PlayerHealth.spawn = next_spawn
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/cenários/corredor/corredor.tscn")



func _ready() -> void:
	if GameState.grandpa_dead == true:
		$TextureRect.texture = change_sprite


func _on_button_corredor_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(mouse_hover, Input.CURSOR_ARROW)


func _on_button_corredor_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(default, Input.CURSOR_ARROW)
