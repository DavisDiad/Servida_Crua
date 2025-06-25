extends Area2D

@export var item: InvItem
@onready var container := get_parent()

var mouse_hover = preload("res://placeholders/mouse_hover.png")
var default = preload("res://placeholders/cursor.png")

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click") and GameState.frigideira_collected == false:
		container.collect(item)
		GameState.frigideira_collected = true


func _on_mouse_entered() -> void:
	if GameState.frigideira_collected == false:
		Input.set_custom_mouse_cursor(mouse_hover, Input.CURSOR_ARROW)


func _on_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(default, Input.CURSOR_ARROW)
