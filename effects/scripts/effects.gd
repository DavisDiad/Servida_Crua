extends Node2D


func _ready():
	var anim = $AnimatedSprite2D
	anim.connect("animation_finished", Callable(self, "_on_anim_end"))

func _on_anim_end():
	queue_free()
