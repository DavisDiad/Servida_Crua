extends Node2D

@onready var change_sprite = preload("res://scenes/cenários/corredor_quarto/sprites/quarto_amaldicoado.PNG")

var mouse_hover = preload("res://placeholders/mouse_hover.png")
var default = preload("res://placeholders/cursor.png")

func _ready() -> void:
	if GameState.grandpa_dead == true:
		$TextureRect.texture = change_sprite


func _on_quarto_helena_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(mouse_hover, Input.CURSOR_ARROW)


func _on_quarto_helena_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(default, Input.CURSOR_ARROW)
