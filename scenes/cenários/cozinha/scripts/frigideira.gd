extends Area2D

@export var item: InvItem
@onready var container := get_parent()



func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click") and GameState.frigideira_collected == false:
		container.collect(item)
		GameState.frigideira_collected = true
