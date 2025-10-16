extends CharacterBody2D

# --- Constantes ---
const SPEED = 80
const GRAVITY = 1200.0
const ATTACK_COOLDOWN = 1.0

# --- Estado ---
var health: int = 1
var attacking: bool = false
var attack_timer: float = 0.0
var direction: int = -1   # -1 = izquierda, 1 = derecha
var player_in_sight: bool = false

# --- Referencias ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var vision_area: Area2D = $VisionArea
@onready var floor_check: RayCast2D = $FloorCheck

func _ready():
	vision_area.body_entered.connect(_on_vision_entered)
	vision_area.body_exited.connect(_on_vision_exited)
	anim.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	# Gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Ataque en curso
	if attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			attacking = false
		move_and_slide()
		return

	# Si ve al jugador → moverse hacia él
	if player_in_sight:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			direction = sign(player.global_position.x - global_position.x)
			velocity.x = direction * SPEED
			_flip_direction_nodes()

			# Si está cerca → atacar
			if global_position.distance_to(player.global_position) < 60 and not attacking:
				perform_attack(player)
	else:
		# Patrulla simple
		velocity.x = direction * SPEED

		# --- Giro por pared o falta de suelo ---
		if is_on_wall() or not floor_check.is_colliding():
			flip_direction()

	move_and_slide()

	# Animaciones
	if attacking:
		if anim.animation != "attack":
			anim.play("attack")
	elif abs(velocity.x) > 0:
		if anim.animation != "walk":
			anim.play("walk")
	else:
		if anim.animation != "idle":
			anim.play("idle")

# --- Ataque ---
func perform_attack(player):
	attacking = true
	attack_timer = ATTACK_COOLDOWN
	anim.play("attack")
	if player.has_method("die"):
		player.die()

func _on_animation_finished():
	if anim.animation == "attack" and not attacking:
		anim.play("idle")
	elif anim.animation == "death":
		queue_free()

# --- Visión ---
func _on_vision_entered(body):
	if body.is_in_group("player"):
		player_in_sight = true

func _on_vision_exited(body):
	if body.is_in_group("player"):
		player_in_sight = false

# --- Daño ---
func take_damage():
	health -= 1
	if health <= 0:
		die()

func die():
	anim.play("death")
	set_physics_process(false)

# --- Volteo ---
func flip_direction():
	direction *= -1
	_flip_direction_nodes()

func _flip_direction_nodes():
	# Sprite siempre mira hacia la dirección actual
	anim.flip_h = direction > 0

	# Reposicionar nodos hijos al lado correcto
	attack_area.position.x = abs(attack_area.position.x) * direction
	vision_area.position.x = abs(vision_area.position.x) * direction
	floor_check.position.x = abs(floor_check.position.x) * direction
