extends Area2D

@export var body_part: String  # Nome da parte do corpo
@export var enemy: Node        # Referência ao inimigo

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Clique registado em ", body_part)

		var parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
		parameters.position = event.position
		parameters.collide_with_areas = true
		
		var objects_clicked = get_world_2d().direct_space_state.intersect_point(parameters)
		var colliders = objects_clicked.map(func(dict): return dict.collider)

		# Ordena os colliders por z_index (se necessário)
		colliders.sort_custom(func(c1, c2): return c1.z_index < c2.z_index)

		# Só aplica o dano se este for o collider do topo
		if enemy and colliders.size() > 0 and colliders[-1] == self:
			enemy.take_damage(body_part)
