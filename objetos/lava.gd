extends Area2D
@export var rise_speed: float = 100.0
var active: bool = true

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.die()
		active = false  # detener lava cuando toca al jugador
