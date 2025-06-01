extends Node2D

@export var enemy_data: EnemyData #exporta um tres do inimigo, que neste caso é o cat. esse tres esta conectado com o resource EnemyData, que contem todas as informações do inimigo

var can_take_damage = false #serve para controlar quando o inimigo recebe dano
var has_been_attacked = false

var skill_requirements = { #é um dicionário que atribui as haabilidaades às partes do corpo necesárias para usá-la.
	"terrified_cry": ["head"],
	"hair_strangulation": ["right_hair","left_hair"],
	"silent_scream": ["head_men"],
	"human_hammer": ["right_men","left_men"]
}

var damage_animations = {
	"torso": "torso_damage",
	"left_arm": "left_arm_damage",
	"right_arm": "right_arm_damage",
	"right_leg": "right_leg_damage",
	"left_leg": "left_leg_damage",
	"head": "head_damage",
	"head_men": "head_men_damage",
	"right_hair": "right_hair_damage",
	"left_hair": "left_hair_damage",
	"right_men": "right_men_damage",
	"left_men": "left_men_damage"
}

var wounds = {} #um dicionário que serve para armazenar o número de feridas do inimigo. ele será definido usando enemy_data.body_parts

var interaction_step = 0
var is_talking = false

var player : Node = null
var anim : AnimatedSprite2D = null


func _ready():
	
	player = get_node("/root/Fight/player")
	anim = player.get_node("AnimatedSprite2D")
	
	# para cada parte do corpo definida em enemy_data.body_parts (que é um array de recursos do tipo BodyPart) ele começaa a contar o número de feridas, começando em zero, para essa parte
	for part in enemy_data.body_parts: #"part" é uma variavel temporaria criada automaticamente pelo loop for. ela percorre cada body_part dentro do enemy_data
		wounds[part.name] = 0
		
func _process(delta: float) -> void:
	if has_been_attacked == true and can_take_damage == false:
		$DamageAnimationPlayer.stop()
		$head/AnimationPlayer.stop()
		$right_arm/AnimationPlayer.stop()
		$left_arm/AnimationPlayer.stop()
		$torso/AnimationPlayer.stop()
		$right_leg/AnimationPlayer.stop()
		$left_leg/AnimationPlayer.stop()
		$head_men/AnimationPlayer.stop()
		$right_hair/AnimationPlayer.stop()
		$left_hair/AnimationPlayer.stop()
		$right_men/AnimationPlayer.stop()
		$left_men/AnimationPlayer.stop()

func _input(event: InputEvent) -> void:
	if is_talking == true and Input.is_action_just_pressed("left_click"): #ao clicar com o botão esquerdo com o texto ativo,
		_on_fight_talked()

func _on_fight_talked() -> void:
	is_talking = true
	match interaction_step:
		0: 
			get_node("/root/Fight/UI/ActionsPanel").hide()
			get_node("/root/Fight/UI/TextBox").show()
			get_node("/root/Fight/UI/TextBox/Label").text = "Tentas comunicar com o gato..."
			interaction_step += 1

		1: 
			get_node("/root/Fight/UI/TextBox").show()
			get_node("/root/Fight/UI/TextBox/Label").text = "Mas sem sucesso."
			interaction_step += 1

		2:
			get_node("/root/Fight/UI/TextBox").hide()
			is_talking = false # agora pode voltar a clicar normalmente
			perform_attack()
			interaction_step = 0


func _on_fight_attacking() -> void: #esta função acontece quando o sinal attacking em fight é emitido.
	can_take_damage = true #ela permite que o inimigo possa receber dano
	has_been_attacked = false

func _on_attack_finished():
	anim.play("idle_battle")

func take_damage(body_part_name: String):
	if can_take_damage:
		
		can_take_damage = false
		
		anim.play("attack")
		anim.connect("animation_finished", Callable(self, "_on_attack_finished"), CONNECT_ONE_SHOT)
		
		await anim.animation_finished
		
		
		for part in enemy_data.body_parts:
			if part.name == body_part_name:
				var enemy_evasion = part.evasion
				var player_accuracy = PlayerHealth.base_accuracy

				var hit_quality = CombatCalculator.get_hit_value(player_accuracy, enemy_evasion)

				if hit_quality >= 0:
					if damage_animations.has(body_part_name):
						$DamageAnimationPlayer.play(damage_animations[body_part_name])
						await $DamageAnimationPlayer.animation_finished
						
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
					
						
					else:
						var sprite = get_node_or_null(body_part_name)
						if sprite:
							sprite.visible = false
						
						if body_part_name == "right_arm":
							apply_evasion_penalty_to_all(5)
						
						if body_part_name == "left_arm":
							apply_evasion_penalty_to_all(5)
							
						if body_part_name == "right_leg":
							apply_evasion_penalty_to_all(5)
							
						if body_part_name == "left_leg":
							apply_evasion_penalty_to_all(5)
							
						if body_part_name == "head":
							apply_evasion_penalty_to_all(20)
						
						if body_part_name == "head_men":
							apply_evasion_penalty_to_all(10)
							
						if body_part_name == "right_hair":
							apply_evasion_penalty_to_all(30)
							
						if body_part_name == "left_hair":
							apply_evasion_penalty_to_all(30)
							
						if body_part_name == "right_men":
							apply_evasion_penalty_to_all(20)
							
						if body_part_name == "left_men":
							apply_evasion_penalty_to_all(20)
							
				break

		has_been_attacked = true
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
	
func all_skills_unavailable() -> bool:
	for skill_name in skill_requirements.keys():
		if can_use_skill(skill_name):
			return false
	return true

func perform_attack():
	
	if all_skills_unavailable():
		get_node("/root/Fight/UI/TextBox").show()
		get_node("/root/Fight").display_text("O inimigo está incapacitado e não ataca.")
		await get_node("/root/Fight").textbox_closed
		get_node("/root/Fight/UI/ActionsPanel").show()
		return
	
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
		"terrified_cry": "choro agonizante",
		"hair_strangulation": "estrangulamento com cabelo",
		"silent_scream": "grito silencioso",
		"human_hammer": "martelada humana"
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
		{"name": "terrified_cry", "chance": 0.3},
		{"name": "hair_strangulation", "chance": 0.2},
		{"name": "silent_scream", "chance": 0.2},
		{"name": "human_hammer", "chance": 0.3}
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
	if selected_skill_name == "terrified_cry":
		part_probabilities["head"] = 0.1
		part_probabilities["torso"] = 0.2
		part_probabilities["left_arm"] = 0.1
		part_probabilities["right_arm"] = 0.2
		part_probabilities["left_leg"] = 0.2
		part_probabilities["right_leg"] = 0.2
	elif selected_skill_name == "hair_strangulation":
		part_probabilities["head"] = 0.4
		part_probabilities["torso"] = 0.4
		part_probabilities["left_arm"] = 0.1
		part_probabilities["right_arm"] = 0.1
		part_probabilities["left_leg"] = 0.0
		part_probabilities["right_leg"] = 0.0
	elif selected_skill_name == "silent_scream":
		part_probabilities["head"] = 0.2
		part_probabilities["torso"] = 0.1
		part_probabilities["left_arm"] = 0.2
		part_probabilities["right_arm"] = 0.1
		part_probabilities["left_leg"] = 0.2
		part_probabilities["right_leg"] = 0.2
	elif selected_skill_name == "human_hammer":
		part_probabilities["head"] = 0.0
		part_probabilities["torso"] = 0.0
		part_probabilities["left_arm"] = 0.2
		part_probabilities["right_arm"] = 0.2
		part_probabilities["left_leg"] = 0.3
		part_probabilities["right_leg"] = 0.3

	for part in body_parts:
		if not available_parts.has(part):
			part_probabilities.erase(part)

	# Normaliza as probabilidades para garantir que somem 1
	var total_probability = 0.0
	for part in part_probabilities:
		total_probability += part_probabilities[part]
	
	for part in part_probabilities:
		part_probabilities[part] /= total_probability
		
	# Filtra as partes que ainda podem ser atacadas
	for part in part_probabilities.keys():
		if not available_parts.has(part):
			part_probabilities.erase(part)

	# Renormaliza novamente após a filtragem
	total_probability = 0.0
	for value in part_probabilities.values():
		total_probability += value

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


	
	# Aqui continuamos com a lógica de gerar o ataque e calcular o dano
	var player_evasion = PlayerHealth.evasion_per_part.get(attacked_part, 0)
	var enemy_accuracy = skill.accuracy 
	var hit_quality = CombatCalculator.get_hit_value(enemy_accuracy, player_evasion)

	var attack_result_text = ""
	
	var hit = true
	
	if hit_quality >= 0:
		hit = true
		
		var dano = int(lerp(skill.min_damage, skill.max_damage, hit_quality))
		PlayerHealth.add_wound(attacked_part, dano)
		
		
		var ferimento_texto = "ferimento" if dano == 1 else "ferimentos"
		attack_result_text = "e causou [b]%d %s[/b]." % [dano, ferimento_texto]
		print("Damage:", dano, "Quality:", hit_quality)
	else:
		hit = false
		
		attack_result_text = "mas o ataque errou!"
		print("Attack missed, quality:", hit_quality)
	
	var ataque_texto = "O gato usou [b]%s[/b] n%s [b]%s[/b]" % [
		skill_translations.get(skill.name, skill.name),
		part_articles[attacked_part],
		part_names_pt[attacked_part]
	]
	
	
	var final_text = "%s %s" % [ataque_texto, attack_result_text]

	if hit:
		# Toca a animação e só depois mostra o texto
		await get_tree().create_timer(0.1).timeout
		anim.play("attacked")
		await anim.animation_finished
		anim.play("idle_battle")
		get_node("/root/Fight").display_text(final_text)
	else:
		# Sem animação, mostra o texto imediatamente
		get_node("/root/Fight").display_text(final_text)

	# Espera o jogador fechar a caixa de texto
	await get_node("/root/Fight").textbox_closed

	# Mostra o painel de ações novamente
	get_node("/root/Fight/UI/ActionsPanel").show()
	
	


func _on_fight_defending() -> void:
	perform_attack()
	PlayerHealth.is_defending = true


# Function to hide all body parts
func hide_all_body_parts():
	var parts = ["head", "torso", "left_arm", "right_arm", "right_leg", "left_leg", "right_hair", "left_hair", "head_men", "right_men", "left_men"]
	for part_name in parts:
		var sprite = get_node_or_null(part_name)
		if sprite:
			sprite.visible = false

func apply_evasion_penalty_to_all(penalty: int):
	for p in enemy_data.body_parts:
		p.evasion = max(0, p.evasion - penalty)
		print("Reduzida evasão de %s para %d" % [p.name, p.evasion])



func _on_area_2d_torso_mouse_entered() -> void:
	if can_take_damage == true:
		$torso/AnimationPlayer.play("torso_over")


func _on_area_2d_torso_mouse_exited() -> void:
	$torso/AnimationPlayer.stop()

func _on_left_arm_area_2d_mouse_entered() -> void:
	if can_take_damage == true:
		$left_arm/AnimationPlayer.play("left_arm_over")


func _on_left_arm_area_2d_mouse_exited() -> void:
	$left_arm/AnimationPlayer.stop()


func _on_right_arm_area_2d_mouse_entered() -> void:
	if can_take_damage == true:
		$right_arm/AnimationPlayer.play("right_arm_over")


func _on_right_arm_area_2d_mouse_exited() -> void:
	$right_arm/AnimationPlayer.stop()


func _on_right_leg_area_2d_mouse_entered() -> void:
	if can_take_damage == true:
		$right_leg/AnimationPlayer.play("right_leg_over")


func _on_right_leg_area_2d_mouse_exited() -> void:
	$right_leg/AnimationPlayer.stop()


func _on_head_area_2d_mouse_entered() -> void:
	if can_take_damage == true:
		$head/AnimationPlayer.play("head_over")


func _on_head_area_2d_mouse_exited() -> void:
	$head/AnimationPlayer.stop()


func _on_head_men_area_2d_mouse_entered() -> void:
	if can_take_damage == true:
		$head_men/AnimationPlayer.play("head_men_over")


func _on_head_men_area_2d_mouse_exited() -> void:
	$head_men/AnimationPlayer.stop()


func _on_right_hair_area_2d_mouse_entered() -> void:
	if can_take_damage == true:
		$right_hair/AnimationPlayer.play("right_hair_over")


func _on_right_hair_area_2d_mouse_exited() -> void:
	$right_hair/AnimationPlayer.stop()


func _on_left_hair_area_2d_mouse_entered() -> void:
	if can_take_damage == true:
		$left_hair/AnimationPlayer.play("left_hair_over")


func _on_left_hair_area_2d_mouse_exited() -> void:
	$left_hair/AnimationPlayer.stop()


func _on_left_leg_area_2d_mouse_entered() -> void:
	if can_take_damage == true:
		$left_leg/AnimationPlayer.play("left_leg_over")


func _on_left_leg_area_2d_mouse_exited() -> void:
	$left_leg/AnimationPlayer.stop()


func _on_right_men_area_2d_mouse_entered() -> void:
	if can_take_damage == true:
		$right_men/AnimationPlayer.play("right_men_over")


func _on_right_men_area_2d_mouse_exited() -> void:
	$right_men/AnimationPlayer.stop()


func _on_left_men_area_2d_mouse_entered() -> void:
	if can_take_damage == true:
		$left_men/AnimationPlayer.play("left_men_over")


func _on_left_men_area_2d_mouse_exited() -> void:
	$left_men/AnimationPlayer.stop()
