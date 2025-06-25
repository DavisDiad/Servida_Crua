extends Node

signal battle_completed(battle_number)

var current_battle := 0

var cat_dead := false
var friend_dead := false
var grandpa_dead := false
var boss_dead := false

var laminas_collected := false
var bau_collected := false
var frigideira_collected := false
var po_collected := false
var perfume_collected := false
var tumor_collected := false

var can_equip:= true

var cutscene_played :=false

var text_introduction := false

func reset():
	current_battle = 0
	cat_dead = false
	friend_dead = false
	grandpa_dead = false
	boss_dead = false
	laminas_collected = false
	bau_collected = false
	frigideira_collected = false
	po_collected = false
	perfume_collected = false
	tumor_collected = false
	can_equip = true
	cutscene_played = false
	text_introduction = false
