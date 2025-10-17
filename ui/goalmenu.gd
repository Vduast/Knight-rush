extends Control

func _ready():

	$VBoxContainer/NextLevelButton.text = "Siguiente Nivel"
	$VBoxContainer/LevelSelectButton.text = "Selección de Nivel"
	$VBoxContainer/MainMenuButton.text = "Menú Principal"

	$VBoxContainer/NextLevelButton.pressed.connect(_on_next_level_button_pressed)
	$VBoxContainer/LevelSelectButton.pressed.connect(_on_level_select_button_pressed)
	$VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_button_pressed)

	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5) # fade in al aparecer
func close_menu():
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	queue_free()
func _on_next_level_button_pressed() -> void:
	get_tree().paused = false
	LevelManager.load_next_level()  # usa tu sistema dinámico de niveles


func _on_level_select_button_pressed() -> void:
	get_tree().paused = false
	await Transition.fade_to_scene("res://ui/level_select.tscn")


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	await Transition.fade_to_scene("res://ui/MainMenu.tscn")
