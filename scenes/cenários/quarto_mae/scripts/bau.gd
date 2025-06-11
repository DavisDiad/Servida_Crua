extends Area2D

@export var item1: InvItem
@export var item2: InvItem
@export var item3: InvItem
@onready var container := get_parent() # Caminho até o Node2D com `collect()`

var collected = false

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click") and collected == false:
		if container.has_method("collect"):
			container.collect(item1)
			container.collect(item2)
			container.collect(item3)
			collected = true
