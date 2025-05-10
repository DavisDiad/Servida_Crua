extends Node2D

@export var animator:AnimationPlayer;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func tocaperto(_ingnorar):
	animator.play("00");

func tocamedio(_ingnorar):
	animator.play("01");

func tocalonge(_ingnorar):
	animator.play("02");
	pass # Replace with function body.
