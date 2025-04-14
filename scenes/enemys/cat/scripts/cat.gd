extends Node2D

@export var right_leg_wound_texture : Texture #uma textura exportada usada para alterar a aparência da perna direita quando ela atingir o número máximo de feridas
@export var enemy_data: EnemyData #exporta um tres do inimigo, que neste caso é o cat. esse tres esta conectado com o resource EnemyData, que contem todas as informações do inimigo

var can_take_damage = false #serve para controlar quando o inimigo recebe dano

var skill_requirements = { #é um dicionário que atribui as haabilidaades às partes do corpo necesárias para usá-la.
	"claw": ["left_arm"],
	"infected_claw": ["right_arm"],
}

var wounds = {} #um dicionário que serve para armazenar o número de feridas do inimigo. ele será definido usando enemy_data.body_parts

func _ready():
	# para cada parte do corpo definida em enemy_data.body_parts (que é um array de recursos do tipo BodyPart) ele começaa a contar o número de feridas, começando em zero, para essa parte
	for part in enemy_data.body_parts: #"part" é uma variavel temporaria criada automaticamente pelo loop for. ela percorre cada body_part dentro do enemy_data
		wounds[part.name] = 0

func _on_fight_attacking() -> void: #esta função acontece quando o sinal attacking em fight é emitido.
	can_take_damage = true #ela permite que o inimigo possa receber dano


func take_damage(body_part_name: String):
	if can_take_damage:
		for part in enemy_data.body_parts:
			if part.name == body_part_name:
				var enemy_evasion = part.evasion
				var player_accuracy = PlayerHealth.base_accuracy

				var hit_quality = CombatCalculator.get_hit_value(player_accuracy, enemy_evasion)

				if hit_quality >= 0:
					# Novo cálculo de dano baseado na qualidade do acerto
					var damage = int(lerp(PlayerHealth.min_damage, PlayerHealth.max_damage, hit_quality))
					
					wounds[body_part_name] += damage
					print(body_part_name + " took %d damage (quality: %.2f). Total wounds: %d" % [damage, hit_quality, wounds[body_part_name]])
				else:
					print("O ataque do jogador errou %s!" % body_part_name)

				if wounds[body_part_name] >= part.max_wounds:
					print(body_part_name + " was dismembered!")

					# Desmembramento e aplicação de penalidade de evasão
					if body_part_name == "torso":
						hide_all_body_parts()
						
					elif body_part_name == "right_leg":
						var sprite = get_node_or_null(body_part_name)
						if sprite:
							change_right_leg_texture(sprite)
							$right_leg/Area2D.hide()
							
						apply_evasion_penalty_to_all(5)
						
					
						
					else:
						var sprite = get_node_or_null(body_part_name)
						if sprite:
							sprite.visible = false
						
						if body_part_name == "right_arm":
							apply_evasion_penalty_to_all(5)
						
						if body_part_name == "left_arm":
							apply_evasion_penalty_to_all(5)
				break

		can_take_damage = false
		perform_attack()

func can_use_skill(skill_name: String) -> bool:
	if not skill_requirements.has(skill_name):
		return true
	for part_name in skill_requirements[skill_name]:
		for part in enemy_data.body_parts:
			if part.name == part_name:
				if wounds.get(part_name, 0) >= part.max_wounds:
					return false
	return true

func perform_attack():
	# Define partes do corpo
	var body_parts = ["head", "torso", "left_arm", "right_arm", "left_leg", "right_leg"]
	var part_names_pt = {
		"head": "cabeça",
		"torso": "tronco",
		"left_arm": "braço esquerdo",
		"right_arm": "braço direito",
		"left_leg": "perna esquerda",
		"right_leg": "perna direita"
	}
	
	var part_articles = {
		"head": "a tua",  
		"torso": "o teu",  
		"left_arm": "o teu",  
		"right_arm": "o teu",  
		"left_leg": "a tua",   
		"right_leg": "a tua"  
	}
	
	var skill_translations = {
		"claw": "garra afiada",
		"infected_claw": "garra infectada",
		"bite": "mordida"
	}
	
	# Filtra partes do corpo que já atingiram o limite de feridas
	var available_parts = []
	for part in body_parts:
		if PlayerHealth.wounds[part] < PlayerHealth.wound_limits[part]:
			available_parts.append(part)
	
	# Se não houver partes disponíveis para atacar, não faz nada
	if available_parts.size() == 0:
		return

	# Lista de habilidades com suas probabilidades de uso
	var skill_probabilities = [
		{"name": "infected_claw", "chance": 0.7},
		{"name": "claw", "chance": 0.2},
		{"name": "bite", "chance": 0.1}
	]

	# Ordena da mais provável pra menos
	skill_probabilities.sort_custom(func(a, b): return b.chance < a.chance)

	# Escolhe com base em roleta ponderada
	var selected_skill_name = null
	var random_value = randf()

	var cumulative = 0.0
	for skill_data in skill_probabilities:
		cumulative += skill_data.chance
		if random_value <= cumulative:
			selected_skill_name = skill_data.name
			break

	# Se a habilidade não puder ser usada, tenta a próxima mais provável
	for skill_data in skill_probabilities:
		if selected_skill_name == null or not can_use_skill(selected_skill_name):
			selected_skill_name = skill_data.name
			if can_use_skill(selected_skill_name):
				break
		else:
			break

	# Busca a habilidade correspondente no resource
	var skill = null
	for s in enemy_data.skills:
		if s.name == selected_skill_name:
			skill = s
			break

	# Se nenhuma estiver disponível, não faz nada (evita travamento)
	if skill == null:
		return

	# Define a lógica de variação de partes do corpo com base na habilidade
	var part_probabilities = {
		"head": 0.1,   # chance padrão de atacar a cabeça
		"torso": 0.2,  # chance padrão de atacar o tronco
		"left_arm": 0.1, 
		"right_arm": 0.1, 
		"left_leg": 0.1,
		"right_leg": 0.1
	}

	# Alteração das probabilidades com base na habilidade
	if selected_skill_name == "infected_claw":
		part_probabilities["head"] = 0.3
		part_probabilities["torso"] = 0.3
		part_probabilities["left_arm"] = 0.1
		part_probabilities["right_arm"] = 0.1
		part_probabilities["left_leg"] = 0.1
		part_probabilities["right_leg"] = 0.1
	elif selected_skill_name == "claw":
		part_probabilities["head"] = 0.2
		part_probabilities["torso"] = 0.4
		part_probabilities["left_arm"] = 0.1
		part_probabilities["right_arm"] = 0.1
		part_probabilities["left_leg"] = 0.1
		part_probabilities["right_leg"] = 0.1
	elif selected_skill_name == "bite":
		part_probabilities["head"] = 0.1
		part_probabilities["torso"] = 0.1
		part_probabilities["left_arm"] = 0.2
		part_probabilities["right_arm"] = 0.2
		part_probabilities["left_leg"] = 0.2
		part_probabilities["right_leg"] = 0.2

	# Normaliza as probabilidades para garantir que somem 1
	var total_probability = 0.0
	for part in part_probabilities:
		total_probability += part_probabilities[part]
	
	for part in part_probabilities:
		part_probabilities[part] /= total_probability

	# Escolhe uma parte do corpo com base nas novas probabilidades
	var attacked_part = null
	var random_value_for_part = randf()
	var cumulative_part_probability = 0.0
	for part in part_probabilities:
		cumulative_part_probability += part_probabilities[part]
		if random_value_for_part <= cumulative_part_probability:
			attacked_part = part
			break

	# Aguarda 0.5s (pode servir para animação ou delay do ataque)
	await get_tree().create_timer(0.5).timeout
	
	# Aqui continuamos com a lógica de gerar o ataque e calcular o dano
	var player_evasion = PlayerHealth.evasion_per_part.get(attacked_part, 0)
	var enemy_accuracy = skill.accuracy 
	var hit_quality = CombatCalculator.get_hit_value(enemy_accuracy, player_evasion)

	var attack_result_text = ""
	
	if hit_quality >= 0:
		var dano = int(lerp(skill.min_damage, skill.max_damage, hit_quality))
		PlayerHealth.add_wound(attacked_part, dano)
		

		
		var ferimento_texto = "ferimento" if dano == 1 else "ferimentos"
		attack_result_text = "e causou [b]%d %s[/b]." % [dano, ferimento_texto]
		print("Damage:", dano, "Quality:", hit_quality)
	else:
		attack_result_text = "mas o ataque errou!"
		print("Attack missed, quality:", hit_quality)
	
	var ataque_texto = "O gato usou [b]%s[/b] n%s [b]%s[/b]" % [
		skill_translations.get(skill.name, skill.name),
		part_articles[attacked_part],
		part_names_pt[attacked_part]
	]
	
	get_node("/root/Fight").display_text("%s %s" % [ataque_texto, attack_result_text])
	await get_node("/root/Fight").textbox_closed
	get_node("/root/Fight/UI/ActionsPanel").show()
	


func _on_fight_defending() -> void:
	perform_attack()
	PlayerHealth.is_defending = true

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

func apply_evasion_penalty_to_all(penalty: int):
	for p in enemy_data.body_parts:
		p.evasion = max(0, p.evasion - penalty)
		print("Reduzida evasão de %s para %d" % [p.name, p.evasion])
