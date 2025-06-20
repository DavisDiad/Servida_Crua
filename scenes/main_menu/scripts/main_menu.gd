extends CanvasLayer


func _ready() -> void:
	Transition.fade_in()


func _on_button_pressed() -> void:
	GameReset.reset_all()
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/cutscene/cutscene_1.tscn")


func _on_button_2_pressed() -> void:
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().quit()
