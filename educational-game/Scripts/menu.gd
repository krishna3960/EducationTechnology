extends Control

const GAME_SCENE: String = "res://Scenes/game.tscn"


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_settings_pressed() -> void:
	# TODO: open settings scene
	print("Settings pressed")


func _on_quit_pressed() -> void:
	get_tree().quit()
