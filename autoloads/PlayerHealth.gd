extends Node

@onready var inv_equ: InvEqu = preload("res://inventory_equipped/playerequinv.tres")
@onready var inv: Inv = preload("res://inventory/playerinv.tres")

var spawn = Vector2(974.0,559.0)

var min_damage = 1
var max_damage = 1
var base_accuracy = 65

var is_defending = false
var can_move = true

var evasion_per_part = {
	"head": 15,
	"torso": 5,
	"left_arm": 10,
	"right_arm": 10,
	"left_leg": 5,
	"right_leg": 5
}

var wounds = {
	"head": 0,
	"torso": 0,
	"left_arm": 0,
	"right_arm": 0,
	"left_leg": 0,
	"right_leg": 0
}

var wound_limits = {
	"head": 6,
	"torso": 8,
	"left_arm": 4,
	"right_arm": 4,
	"left_leg": 5,
	"right_leg": 5
}

# Controle de debuffs aplicados
var evasion_debuff_applied = {
	"left_arm": false,
	"right_arm": false,
	"left_leg": false,
	"right_leg": false,
	"legs_to_torso": 0, # de 0 a 2 (max 4)
	"torso": false,
	"head": false
}

var body_part_anim_players = {}

func register_animation_players():
	var base_path = "/root/Fight/UI/DamageAnimationPlayer"
	body_part_anim_players["head"] = get_node(base_path)
	body_part_anim_players["torso"] = get_node(base_path)
	body_part_anim_players["left_arm"] = get_node(base_path)
	body_part_anim_players["right_arm"] = get_node(base_path)
	body_part_anim_players["left_leg"] = get_node(base_path)
	body_part_anim_players["right_leg"] = get_node(base_path)

func get_arm_state() -> String:
	var left_gone = wounds["left_arm"] >= wound_limits["left_arm"]
	var right_gone = wounds["right_arm"] >= wound_limits["right_arm"]
	
	if left_gone and right_gone:
		return "no_arms"
	elif left_gone:
		return "right_only"
	elif right_gone:
		return "left_only"
	else:
		return "both_arms"

func add_wound(body_part: String, amount: int = 1) -> bool:
	var damage_applied = false
	if body_part in wounds:
		var final_amount = amount
		if is_defending:
			final_amount = max(0, amount - 1)
			is_defending = false
		wounds[body_part] += final_amount
		
		if wounds["right_arm"] >= wound_limits["right_arm"]:
			if inv_equ.weapon and inv_equ.weapon.item:
				inv_equ.force_unequip_and_return(inv_equ.weapon)
				print("Braço direito perdido. Arma desequipada.")

		if wounds["left_arm"] >= wound_limits["left_arm"]:
			if inv_equ.object and inv_equ.object.item:
				inv_equ.force_unequip_and_return(inv_equ.object)
				print("Braço esquerdo perdido. Objeto desequipado.")
		
		damage_applied = (final_amount > 0)
		if damage_applied:
			var anim_player = body_part_anim_players.get(body_part, null)
			if anim_player and anim_player.has_animation(body_part + "_damage"):
				
				await get_tree().create_timer(1.0).timeout
				anim_player.play(body_part + "_damage")
			else:
				print("n foi encontrado")
		
		if body_part in ["torso", "head"] and wounds[body_part] >= wound_limits[body_part]:
			Transition.transition()
			await Transition.on_transition_finished
			GameReset.reset_all()
			get_tree().change_scene_to_file("res://scenes/cutscene/cutscene_1.tscn")

		update_evasion_debuffs()
	return damage_applied


func update_evasion_debuffs():
	# Braços
	for arm in ["left_arm", "right_arm"]:
		if wounds[arm] >= wound_limits[arm] / 2.0 and not evasion_debuff_applied[arm]:
			evasion_per_part[arm] = max(5, evasion_per_part[arm] - 5)
			evasion_debuff_applied[arm] = true

	# Pernas
	for leg in ["left_leg", "right_leg"]:
		if wounds[leg] >= wound_limits[leg] / 2.0 and not evasion_debuff_applied[leg]:
			evasion_per_part[leg] = max(3, evasion_per_part[leg] - 2)
			evasion_debuff_applied[leg] = true

			if evasion_debuff_applied["legs_to_torso"] < 2:
				evasion_per_part["torso"] = max(1, evasion_per_part["torso"] - 2)
				evasion_debuff_applied["legs_to_torso"] += 1

	# Torso → afeta cabeça
	if wounds["torso"] >= wound_limits["torso"] / 2.0 and not evasion_debuff_applied["torso"]:
		evasion_per_part["head"] = max(5, evasion_per_part["head"] - 5)
		evasion_debuff_applied["torso"] = true

	# Print debug
	print("Evasão atual por parte do corpo da protagonista:")
	for part in evasion_per_part:
		print(part + ": " + str(evasion_per_part[part]))
		

func reset():
	# Reseta atributos básicos
	min_damage = 1
	max_damage = 2
	base_accuracy = 65
	is_defending = false
	can_move = true

	# Zera ferimentos
	for part in wounds.keys():
		wounds[part] = 0

	# Restaura evasões base
	evasion_per_part = {
		"head": 15,
		"torso": 5,
		"left_arm": 10,
		"right_arm": 10,
		"left_leg": 5,
		"right_leg": 5
	}

	# Reseta debuffs
	evasion_debuff_applied = {
		"left_arm": false,
		"right_arm": false,
		"left_leg": false,
		"right_leg": false,
		"legs_to_torso": 0,
		"torso": false,
		"head": false
	}

	# Reinstancia os slots equipados, se necessário
	if inv_equ.weapon == null:
		inv_equ.weapon = InvEquSlot.new()
	else:
		inv_equ.weapon.item = null

	if inv_equ.object == null:
		inv_equ.object = InvEquSlot.new()
	else:
		inv_equ.object.item = null

	if inv_equ.accessory == null:
		inv_equ.accessory = InvEquSlot.new()
	else:
		inv_equ.accessory.item = null
		
	inv.reset()
	spawn = Vector2(974.0,559.0)
