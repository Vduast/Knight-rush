extends Control

func _on_reintentar_pressed():
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")
