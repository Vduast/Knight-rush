extends Control

func _on_jugar_pressed():
	await Transition.fade_to_scene("res://ui/level_select.tscn")
	print("Botón presionado")


func _on_salir_pressed():
	get_tree().quit()
