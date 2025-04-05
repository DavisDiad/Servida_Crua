extends Node

var damage = 1

var wounds = {
	"head": 0,
	"torso": 0,
	"left_arm": 0,
	"right_arm": 0,
	"left_leg": 0,
	"right_leg": 0
}

# Wound limits before a body part is dismembered
var wound_limits = {
	"head": 6,
	"torso": 8,
	"left_arm": 4,
	"right_arm": 4,
	"left_leg": 5,
	"right_leg": 5
}

func add_wound(body_part: String):
	if body_part in wounds:
		wounds[body_part] += 1
