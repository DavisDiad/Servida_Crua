extends Node


func get_hit_value(accuracy: int, evasion: int) -> float:
	# Calcula a chance bruta de acerto, forçando valores mínimos e máximos para evitar extremos.
	var chance = clamp(accuracy - evasion, 5, 95)
	# Gera um número aleatório entre 0 e 100
	var roll = randf() * 100.0
	# Debug: imprime os valores usados
	print("CombatCalculator.get_hit_value -> accuracy:", accuracy, " evasion:", evasion, " chance:", chance, " roll:", roll)
	
	# Se o roll estiver abaixo da chance, o ataque acerta
	if roll < chance:
		# Definindo a qualidade do acerto:
		# Quanto menor o roll comparado à chance, melhor (próximo de 1).
		var quality = 1.0 - (roll / chance)
		print("Hit! Quality:", quality)
		return quality
	else:
		print("Missed!")
		# Retorna -1 para indicar falha no ataque
		return -1.0
		
		
