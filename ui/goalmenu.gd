extends Control

func _ready():
	$VBoxContainer/NextLevelButton.text = "Siguiente Nivel"
	$VBoxContainer/LevelSelectButton.text = "Selección de Nivel"
	$VBoxContainer/MainMenuButton.text = "Menú Principal"

	$VBoxContainer/NextLevelButton.pressed.connect(_on_next_level_button_pressed)
	$VBoxContainer/LevelSelectButton.pressed.connect(_on_level_select_button_pressed)
	$VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_button_pressed)

	

func _on_next_level_button_pressed() -> void:
	get_tree().paused = false
	LevelManager.load_next_level()  # usa tu sistema dinámico de niveles


func _on_level_select_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/level_select.tscn")


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")
