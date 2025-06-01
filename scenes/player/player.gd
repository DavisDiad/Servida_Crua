extends CharacterBody2D

@export var speed = 180
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var max_scale : float = 1.0

var target_position: Vector2 = Vector2.ZERO
var idle_timer := 0.0
var scared_interval := 15.0
var is_playing_idle_scared := false

func _ready():
	target_position = position
	anim.play("idle")
	PlayerHealth.can_move = true
	

func _process(delta: float):
	
	if is_playing_idle_scared or velocity.length() > 0 or PlayerHealth.can_move == false:
		return # ignora se estiver assustado OU a mover-se

	idle_timer += delta
	if idle_timer >= scared_interval:
		is_playing_idle_scared = true
		idle_timer = 0.0
		anim.play("idle_scared")
		anim.connect("animation_finished", Callable(self, "_on_idle_scared_finished"), CONNECT_ONE_SHOT)


func _on_idle_scared_finished():
	anim.play("idle")
	is_playing_idle_scared = false

func _input(event: InputEvent):
	if Input.is_action_just_pressed("left_click") and PlayerHealth.can_move == true:
		target_position = get_global_mouse_position()
		anim.play("walkcycle")

func _physics_process(delta: float):
	var direction = target_position - position
	if direction.length() > 2:
		direction = direction.normalized()
		velocity = direction * speed

		# Inverter sprite se andar para a esquerda
		if direction.x < 0:
			anim.flip_h = true
		elif direction.x > 0:
			anim.flip_h = false

		if anim.animation != "walkcycle":
			anim.play("walkcycle")
	else:
		velocity = Vector2.ZERO
		if anim.animation == "walkcycle":
			anim.play("idle")

	move_and_slide()
