extends Area2D

@export var item: InvItem
@onready var container := get_parent().get_parent() # Caminho até o Node2D com `collect()`

var next_spawn = Vector2(503.0,645.0)

var mouse_hover = preload("res://placeholders/mouse_hover.png")
var default = preload("res://placeholders/cursor.png")

func _ready() -> void:
	if GameState.laminas_collected == true:
		$"..".visible = false

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click") and GameState.laminas_collected == false:
		if container.has_method("collect"):
			container.collect(item)
			$"..".visible = false
		Transition.transition()
		await Transition.on_transition_finished
		PlayerHealth.spawn = next_spawn
		get_tree().change_scene_to_file("res://scenes/fight/fight2.tscn")
		GameState.laminas_collected = true


func _on_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(mouse_hover, Input.CURSOR_ARROW)


func _on_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(default, Input.CURSOR_ARROW)
