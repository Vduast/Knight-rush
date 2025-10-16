extends Control

	


func _on_nivel_1_pressed() -> void:
	get_tree().change_scene_to_file("res://niveles/LEvel.tscn")


func _on_nivel_2_pressed() -> void:
	get_tree().change_scene_to_file("res://niveles/LEVEL2.tscn")
