extends Node2D

var ui_scene = preload("res://scenes/ui.tscn")
var ui_instance
var actions_panel 
var label

func _ready() -> void:
	ui_instance = ui_scene.instantiate()
	add_child(ui_instance)
	
	actions_panel = ui_instance.get_node("TextureRect/ActionsPanel")
	label = ui_instance.get_node("TextureRect/TextBox/Label")
	actions_panel.visible = false
	
	display_text("Um gato bufa ao sentir a tua presença.")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click") and actions_panel.visible == false:
		actions_panel.visible = true

func display_text(text):
	label.text = text
