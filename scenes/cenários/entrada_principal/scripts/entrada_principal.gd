extends Node2D

@onready var change_sprite = preload("res://scenes/cenários/entrada_principal/sprites/entrada_principal_amaldiçoada.JPG")

func _ready() -> void:
	if GameState.friend_dead == true or GameState.cat_dead == true or GameState.grandpa_dead == true:
		$TextureRect.texture = change_sprite
