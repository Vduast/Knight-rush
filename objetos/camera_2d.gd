extends Camera2D

# --- Configuración ---
@export var follow_speed: float = 8.0          # suavidad del seguimiento
@export var look_ahead_distance: float = 120.0 # cuánto se adelanta en horizontal
@export var vertical_look: float = 60.0        # cuánto se mueve en vertical
@export var shake_decay: float = 5.0           # velocidad con la que se disipa el shake

# --- Estado interno ---
var player: CharacterBody2D
var shake_strength: float = 0.0
var shake_offset: Vector2 = Vector2.ZERO

func _ready():
	# Como la cámara está dentro del Player, el padre es el Player
	player = get_parent()

func _process(delta):
	if not player:
		return

	# --- Look ahead dinámico ---
	var dir = sign(player.velocity.x)
	var look_ahead = Vector2(dir * look_ahead_distance, 0)

	# --- Ajuste vertical según velocidad ---
	var vertical_offset = Vector2.ZERO
	if player.velocity.y < -50: # subiendo
		vertical_offset.y = -vertical_look
	elif player.velocity.y > 50: # cayendo
		vertical_offset.y = vertical_look

	# --- Posición objetivo relativa al Player ---
	var target_offset = look_ahead + vertical_offset

	# --- Interpolación suave del offset ---
	offset = offset.lerp(target_offset + shake_offset, follow_speed * delta)

	# --- Screen shake ---
	if shake_strength > 0:
		shake_offset = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * shake_strength
		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
	else:
		shake_offset = Vector2.ZERO

# --- Función para activar shake desde el Player ---
func add_shake(strength: float):
	shake_strength = max(shake_strength, strength)
