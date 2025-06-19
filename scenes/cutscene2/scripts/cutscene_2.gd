extends Control

var next_spawn = Vector2(503.0,645.0)

func _on_video_stream_player_finished() -> void:
	PlayerHealth.spawn = next_spawn
	get_tree().change_scene_to_file("res://scenes/fight/fight4.tscn")
