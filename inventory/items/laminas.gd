extends Area2D

@export var item: InvItem
@onready var container := get_parent().get_parent() # Caminho até o Node2D com `collect()`

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		if container.has_method("collect"):
			container.collect(item)
			$"..".visible = false
		await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_file("res://scenes/fight/fight2.tscn")
