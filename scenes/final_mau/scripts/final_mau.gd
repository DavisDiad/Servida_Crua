extends Control

func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
