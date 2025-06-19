extends Node2D

@onready var change_sprite = preload("res://scenes/cenários/corredor_quarto/sprites/quarto_amaldicoado.PNG")

func _ready() -> void:
	if GameState.grandpa_dead == true:
		$TextureRect.texture = change_sprite
