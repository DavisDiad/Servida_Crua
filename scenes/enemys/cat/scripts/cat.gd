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
		print("Part:", part.name, "Limit:", part.max_wounds)
		wounds[part.name] = 0

func _on_fight_attacking() -> void: #esta função acontece quando o sinal attacking em fight é emitido.
	can_take_damage = true #ela permite que o inimigo possa receber dano


func take_damage(body_part_name: String):
	if can_take_damage: # a função só executa que can_take_damage é verdadeiro
		for part in enemy_data.body_parts: #cria a variavel part para o loop for para passar por todas as partes do corpo do inimigo
			if part.name == body_part_name: #se a variavel part enquato acessa name for igual ao parametro body part name
				wounds[body_part_name] += PlayerHealth.damage #incrementa as feridas naquela parte do corpo usando o valor damage presente em PlayerHealth
				print(body_part_name + " took damage. Total wounds: " + str(wounds[body_part_name]))
				
				if wounds[body_part_name] >= part.max_wounds:
					print(body_part_name + " was dismembered!")# Se o número de feridas atingir ou ultrapassar o limite, print que o membro foi desmembrado
					
					if body_part_name == "torso": # Se as feridas no torso forem maior que o eu máximo, chama a função hide_all_body_parts
						hide_all_body_parts()

					elif body_part_name == "right_leg": #se for a perna direita obtem o sprite correspondente atraves da variavel sprite e chama a função para mudar a textura
						var sprite = get_node_or_null(body_part_name)
						if sprite:
							change_right_leg_texture(sprite)
					# Para as outras partes, esconde apenas o sprite correspondente
					else:
						var sprite = get_node_or_null(body_part_name)
						if sprite:
							sprite.visible = false
				break  # Sai do loop após processar a parte
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
	
	var attacked_part = body_parts[randi() % body_parts.size()]
	
	await get_tree().create_timer(0.5).timeout
	
	var available_skills = enemy_data.skills.filter(
		func(skill):
			return can_use_skill(skill.name)
	)


	var skill = available_skills[randi() % available_skills.size()]
	var dano = randi_range(skill.min_damage, skill.max_damage)
	
	PlayerHealth.add_wound(attacked_part, dano)
	
	var ferimento_texto = "ferimento" if dano == 1 else "ferimentos"
	
	var ataque_texto = "O gato usou [b]%s[/b] n%s [b]%s[/b]" % [
		skill_translations.get(skill.name, skill.name),
		part_articles[attacked_part],
		part_names_pt[attacked_part]
	]
	
	var texto_ferimento = "e causou [b]%d %s[/b]." % [dano, ferimento_texto]
	
	get_node("/root/Fight").display_text("%s %s" % [ataque_texto, texto_ferimento])
	await get_node("/root/Fight").textbox_closed



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
