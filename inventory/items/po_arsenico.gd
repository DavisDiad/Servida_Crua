extends Area2D

@export var item: InvItem
@onready var player = get_node("/root/Fight/player")

var collected = false

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click") and $"../UI/ActionsPanel".visible == true and collected == false:
		player.collect(item)
		collected = true
