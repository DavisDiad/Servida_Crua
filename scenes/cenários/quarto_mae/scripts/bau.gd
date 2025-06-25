extends Area2D

@export var item1: InvItem
@export var item2: InvItem
@export var item3: InvItem
@export var item4: InvItem
@onready var container := get_parent() # Caminho até o Node2D com `collect()`

var mouse_hover = preload("res://placeholders/mouse_hover.png")
var default = preload("res://placeholders/cursor.png")

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click") and GameState.bau_collected == false:
		if container.has_method("collect"):
			container.collect(item1)
			container.collect(item2)
			container.collect(item3)
			container.collect(item4)
			GameState.bau_collected = true


func _on_mouse_entered() -> void:
	if GameState.bau_collected == false:
		Input.set_custom_mouse_cursor(mouse_hover, Input.CURSOR_ARROW)


func _on_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(default, Input.CURSOR_ARROW)
