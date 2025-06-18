extends Node

signal battle_completed(battle_number)

var current_battle := 0

func reset():
	current_battle = 0
