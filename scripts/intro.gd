extends Node2D

func _on_music_pressed() -> void:
	Music.switch()


func _on_begin_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
