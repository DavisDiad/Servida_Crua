extends Node2D

@export var right_leg_wound_texture : Texture
@export var enemy_data: EnemyData
var can_take_damage = false

# Dictionary to store the wounds for each body part
var wounds = {}

func _ready():
	# Inicializa as feridas de cada parte do corpo
	for part in enemy_data.body_parts:
		print("Part:", part.name, "Limit:", part.max_wounds)
		wounds[part.name] = 0

# Function called when a body part takes damage
func take_damage(body_part_name: String):
	if can_take_damage:
		# Itera sobre as partes definidas no resource
		for part in enemy_data.body_parts:
			if part.name == body_part_name:
				# Incrementa uma única ferida
				wounds[body_part_name] += 1
				print(body_part_name + " took damage. Total wounds: " + str(wounds[body_part_name]))
				
				# Se o número de feridas atingir ou ultrapassar o limite, desmembra a parte
				if wounds[body_part_name] >= part.max_wounds:
					print(body_part_name + " was dismembered!")
					
					# Se for o torso, esconde todas as partes do corpo
					if body_part_name == "torso":
						hide_all_body_parts()
					# Se for a right_leg, troca a textura
					elif body_part_name == "right_leg":
						var sprite = get_node_or_null(body_part_name)
						if sprite:
							change_right_leg_texture(sprite)
					# Para as outras partes, esconde apenas o sprite correspondente
					else:
						var sprite = get_node_or_null(body_part_name)
						if sprite:
							sprite.visible = false
				break  # Sai do loop após processar a parte

func change_right_leg_texture(sprite: Sprite2D):
	if right_leg_wound_texture:
		sprite.texture = right_leg_wound_texture
		print("Right leg texture changed!")

# Function to hide all body parts
func hide_all_body_parts():
	var parts = ["eye", "torso", "left_arm", "right_arm", "right_leg"]
	for part_name in parts:
		var sprite = get_node_or_null(part_name)
		if sprite:
			sprite.visible = false

func _on_fight_attacking() -> void:
	can_take_damage = true
