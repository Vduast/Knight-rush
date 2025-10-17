extends Control

	


func _on_nivel_1_pressed() -> void:
	await Transition.fade_to_scene("res://niveles/LEvel.tscn")


func _on_nivel_2_pressed() -> void:
	await Transition.fade_to_scene("res://niveles/LEVEL2.tscn")
