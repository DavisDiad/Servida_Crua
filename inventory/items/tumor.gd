extends Area2D

@export var item: InvItem
@onready var container := get_parent() # Caminho até o Node2D com `collect()`

var collected = false

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click") and collected == false:
		container.collect(item)
		collected = true
