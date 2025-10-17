extends Control

func _ready():
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5) # fade in al aparecer

func close_menu():
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	queue_free()
func _on_reintentar_pressed() -> void:
	var current_scene := get_tree().current_scene.scene_file_path
	await Transition.fade_to_scene(current_scene)

func _on_menu_pressed():
	await Transition.fade_to_scene("res://ui/MainMenu.tscn")
