extends CharacterBody2D

@export var speed = 200 #velocidade da personagem
var target_position: Vector2 = position #armaneza a posição do destino

func _input(event: InputEvent) -> void: #é chamado quando há algum input de fora
	if Input.is_action_just_pressed("left_click"):
		target_position = get_global_mouse_position() #se o botão esquerdo do mouse for clicado, a posição do player passa a ser a posição atual do mouse
		
func _physics_process(delta: float) -> void: #é chamado a uma taxxa fixa de frames, para ter a certeza que a velocidade de movimentação do jogador é sempre a mesma, por exemplo.
	var direction = target_position - position #calcula a direção para o alvo subtraindo a posição inicial com a sua posição final
	
	if direction.length() > 2: # se a distância for maior que 2 pixels, continua a mover. Isso garante que o persongem pare no lugaar certo sem se tremer.
		direction = direction.normalized() #garante que a personagem mova-se a uma velocidade constante, independentemente da distância
		velocity = direction * speed #faz o personagem andar multiplicando a direção pela velocidade
	else:
		velocity = Vector2.ZERO #a personagem para ao alcançar o destino
		
	move_and_slide() #serve para aplicar a velocidade e fazer o jogador mover-se
