extends Node

# Lista de niveles en orden
var levels = [
	"res://niveles/LEvel.tscn",
	"res://niveles/LEVEL2.tscn",
]

var current_index: int = 0

func load_level(index: int):
	if index >= 0 and index < levels.size():
		current_index = index
		await Transition.fade_to_scene(levels[index])

func load_next_level():
	var next_index = current_index + 1
	if next_index < levels.size():
		load_level(next_index)
	else:
		# Si ya no hay más niveles, regresar al menú principal
		await Transition.fade_to_scene("res://ui/MainMenu.tscn")
