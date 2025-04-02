extends Area2D

var is_mouse_over = false

@export var body_part: String  # Body part name (configured in the Inspector)
@export var enemy: Node  # Reference to the enemy in the Inspector


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		var parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
		parameters.position = event.position
		parameters.collide_with_areas = true
		
		var objects_clicked = get_world_2d().direct_space_state.intersect_point(parameters)
		var colliders = objects_clicked.map(
			func(dict):
				return dict.collider
		)
		
		colliders.sort_custom(
			func (c1, c2):
				return c1.z_index < c2.z_index
		)
		
		if enemy and colliders[-1] == self:
			enemy.take_damage(body_part)
