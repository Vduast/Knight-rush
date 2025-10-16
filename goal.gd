extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		_open_goal_menu()

func _open_goal_menu():
	var goal_menu = load("res://ui/goalmenu.tscn").instantiate()
	get_tree().current_scene.add_child(goal_menu)
	get_tree().current_scene.move_child(goal_menu, get_tree().current_scene.get_child_count() - 1)
