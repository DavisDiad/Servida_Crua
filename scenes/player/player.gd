extends CharacterBody2D

@export var speed = 180
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var max_scale : float = 1.0

@export var inv: Inv

var target_position: Vector2 = Vector2.ZERO
var idle_timer := 0.0
var scared_interval := 15.0
var is_playing_idle_scared := false

func _ready():
	target_position = position
	play_action_animation("idle")
	PlayerHealth.can_move = true


func _process(delta: float):
	if is_playing_idle_scared or velocity.length() > 0 or PlayerHealth.can_move == false:
		return # ignora se estiver assustado OU a mover-se

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
		target_position = get_global_mouse_position()
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

	var direction = target_position - position
	if direction.length() > 2:
		direction = direction.normalized()
		velocity = direction * speed

		if direction.x < 0:
			anim.flip_h = true
		elif direction.x > 0:
			anim.flip_h = false

		if not anim.animation.begins_with("walkcycle"):
			play_action_animation("walkcycle")
	else:
		velocity = Vector2.ZERO
		if anim.animation.begins_with("walkcycle"):
			play_action_animation("idle")

	move_and_slide()


func collect(item):
	inv.insert(item)


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
	
