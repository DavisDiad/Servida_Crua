extends CharacterBody2D

@export var speed = 180
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var max_scale : float = 1.0

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

@export var inv: Inv
@export var invequ: InvEqu

var target_position: Vector2 = Vector2.ZERO
var idle_timer := 0.0
var scared_interval := 15.0
var is_playing_idle_scared := false

func _ready():
	global_position = PlayerHealth.spawn
	
	target_position = position
	play_action_animation("idle")
	PlayerHealth.can_move = true

	# Inicializa o NavigationAgent2D
	navigation_agent_2d.velocity_computed.connect(_on_velocity_computed)
	navigation_agent_2d.path_desired_distance = 4.0  # distância para considerar como "chegou"
	navigation_agent_2d.target_desired_distance = 4.0

func _process(delta: float):
	if is_playing_idle_scared or velocity.length() > 0 or PlayerHealth.can_move == false:
		return

	idle_timer += delta
	if idle_timer >= scared_interval:
		is_playing_idle_scared = true
		idle_timer = 0.0
		play_action_animation("idle_scared")
		anim.connect("animation_finished", Callable(self, "_on_idle_scared_finished"), CONNECT_ONE_SHOT)

func _on_idle_scared_finished():
	play_action_animation("idle")
	is_playing_idle_scared = false

func _input(event: InputEvent):
	if Input.is_action_just_pressed("left_click") and PlayerHealth.can_move == true:
		var click_position = get_global_mouse_position()
		navigation_agent_2d.set_target_position(click_position)
		play_action_animation("walkcycle")

func _physics_process(delta: float):
	# Atualizar velocidade com base nas feridas nas pernas
	var left_leg_wounded = PlayerHealth.wounds["left_leg"] >= PlayerHealth.wound_limits["left_leg"]
	var right_leg_wounded = PlayerHealth.wounds["right_leg"] >= PlayerHealth.wound_limits["right_leg"]

	if left_leg_wounded and right_leg_wounded:
		speed = 100
	elif left_leg_wounded or right_leg_wounded:
		speed = 140
	else:
		speed = 180

	# Movimento via NavigationAgent2D
	if navigation_agent_2d.is_navigation_finished():
		velocity = Vector2.ZERO
		if anim.animation.begins_with("walkcycle"):
			play_action_animation("idle")
	else:
		var next_position = navigation_agent_2d.get_next_path_position()
		var direction = (next_position - global_position).normalized()
		velocity = direction * speed

		if direction.x < 0:
			anim.flip_h = true
		elif direction.x > 0:
			anim.flip_h = false

		if not anim.animation.begins_with("walkcycle"):
			play_action_animation("walkcycle")

	move_and_slide()

func _on_velocity_computed(suggested_velocity: Vector2):
	# Opcional: usado se quiser usar NavigationAgent2D em modo "autônomo"
	pass

func collect(item):
	inv.insert(item)
	
func collect_equ(itemequ):
	invequ.insert(itemequ)

func play_action_animation(action: String):
	var arm_state = PlayerHealth.get_arm_state()
	var anim_name = action

	match arm_state:
		"no_arms":
			anim_name += "_desmemberd"
		"left_only":
			anim_name += "_without_r_a"
		"right_only":
			anim_name += "_without_l_a"
		"both_arms":
			pass

	anim.play(anim_name)
