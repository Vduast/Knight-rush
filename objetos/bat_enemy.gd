extends CharacterBody2D

const SPEED = 200
const GRAVITY = 1200.0

enum State { SLEEP, WAKEUP, ATTACK, DEAD }
var state: State = State.SLEEP
var target: Node2D = null
var health: int = 1

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var hitbox: Area2D = $Hitbox

func _ready():
	add_to_group("enemy")
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	anim.play("sleep")

func _physics_process(delta):
	match state:
		State.SLEEP:
			velocity = Vector2.ZERO

		State.WAKEUP:
			velocity = Vector2.ZERO

		State.ATTACK:
			if target and is_instance_valid(target):
				var dir = (target.global_position - global_position).normalized()
				velocity = dir * SPEED
			else:
				state = State.SLEEP
				anim.play("sleep")
				velocity = Vector2.ZERO

		State.DEAD:
			# Solo gravedad al morir
			if not is_on_floor():
				velocity.y += GRAVITY * delta
			else:
				velocity = Vector2.ZERO

	move_and_slide()

# --- Detección del jugador ---
func _on_detection_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and state == State.SLEEP:
		target = body
		state = State.WAKEUP
		anim.play("wakeup")
		anim.animation_finished.connect(_on_wakeup_finished, Object.CONNECT_ONE_SHOT)

func _on_wakeup_finished() -> void:
	if state == State.WAKEUP:
		state = State.ATTACK
		anim.play("fly")

# --- Colisión con jugador ---
func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("player") and state != State.DEAD:
		if body.has_method("die"):
			body.die()

# --- Daño recibido ---
func take_damage():
	if state != State.DEAD:
		health -= 1
		if health <= 0:
			die()

# --- Muerte ---
func die():
	if state == State.DEAD:
		return

	state = State.DEAD
	health = 0

	# reproducir animación de muerte si existe
	
	anim.play("death")
	

	# conectar eliminación al terminar la animación
	if not anim.animation_finished.is_connected(_on_death_animation_finished):
		anim.animation_finished.connect(_on_death_animation_finished, Object.CONNECT_ONE_SHOT)

func _on_death_animation_finished():
	if anim.animation == "death":
		queue_free()
