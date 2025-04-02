extends Node2D

@export var right_leg_wound_texture : Texture

# Dictionary to store the wounds of each body part
var wounds = {
	"head": 0,
	"torso": 0,
	"left_arm": 0,
	"right_arm": 0,
	"right_leg": 0
}

# Wound limits before a body part is dismembered
var wound_limits = {
	"head": 3,
	"torso": 4,
	"left_arm": 2,
	"right_arm": 2,
	"right_leg": 3
}

# Function called when a body part takes damage
func take_damage(body_part):
	if body_part in wounds:
		wounds[body_part] += 1  # Increase the wounds
		print(body_part + " took damage")

		# Check if the body part should be removed
		if wounds[body_part] >= wound_limits[body_part]:
			var sprite = get_node(body_part)  # Get the corresponding sprite
			if sprite:
				if body_part == "right_leg":
					change_right_leg_texture(sprite)
				else:
					sprite.visible = false  # Hide the body part
			print(body_part + " was dismembered!")

			# If head or torso is dismembered, hide all body part sprites
			if body_part == "torso":
				hide_all_body_parts()

func change_right_leg_texture(sprite):
	if right_leg_wound_texture:
		sprite.texture = right_leg_wound_texture  # Change the sprite texture to the new texture
		print("Right leg texture changed!")

# Function to hide all body parts
func hide_all_body_parts():
	var body_parts = ["head", "torso", "left_arm", "right_arm", "right_leg"]
	for part in body_parts:
		var sprite = get_node(part)
		if sprite:
			sprite.visible = false  # Hide each body part sprite
