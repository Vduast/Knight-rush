extends Control

func _on_jugar_pressed():
	get_tree().change_scene_to_file("res://ui/level_select.tscn")
	print("Botón presionado")


func _on_salir_pressed():
	get_tree().quit()
