extends CharacterBody2D

# --- Constantes ---
const SPEED = 80
const RUN_SPEED = 160   # 👈 velocidad al perseguir
const GRAVITY = 1200.0
const ATTACK_COOLDOWN = 1.0

# --- Estado ---
var health: int = 1
var attacking: bool = false
var attack_timer: float = 0.0
var direction: int = 1
var player_in_sight: bool = false
var player_in_attack: bool = false

# --- Referencias ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var vision_area: Area2D = $VisionArea
@onready var floor_check: RayCast2D = $FloorCheck
@onready var wall_check: RayCast2D = $WallCheck

func _ready():
	anim.animation_finished.connect(_on_animation_finished)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	vision_area.body_entered.connect(_on_vision_area_body_entered)
	vision_area.body_exited.connect(_on_vision_area_body_exited)
	_flip_direction_nodes()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			attacking = false
		move_and_slide()
		return

	if player_in_sight:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			direction = sign(player.global_position.x - global_position.x)
			if direction == 0:
				direction = 1
			velocity.x = direction * RUN_SPEED   # 👈 usa velocidad de correr
			_flip_direction_nodes()
			
		

			if player_in_attack and not attacking:
				perform_attack(player)
	else:
		velocity.x = direction * SPEED
		if not floor_check.is_colliding() or wall_check.is_colliding():
			flip_direction()

	move_and_slide()

	# --- Animaciones ---
	if attacking:
		if anim.animation != "attack":
			anim.play("attack")
	elif player_in_sight and abs(velocity.x) > 0:
		if anim.animation != "run":   # 👈 animación de correr
			anim.play("run")
	elif abs(velocity.x) > 0:
		if anim.animation != "walk":
			anim.play("walk")
	else:
		if anim.animation != "idle":
			anim.play("idle")

# --- Señales y helpers (igual que antes) ---
func _on_animation_finished():
	if anim.animation == "attack" and not attacking:
		anim.play("idle")
	elif anim.animation == "death":
		queue_free()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_attack = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_attack = false

func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_sight = true

func _on_vision_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_sight = false

func _flip_direction_nodes():
	anim.flip_h = direction < 0
	attack_area.position.x = 64 * direction
	vision_area.position.x = 128 * direction
	floor_check.position.x = 32 * direction
	wall_check.position.x = 32 * direction

func perform_attack(player):
	attacking = true
	attack_timer = ATTACK_COOLDOWN
	anim.play("attack")
	if player.has_method("die"):
		player.die()

func take_damage():
	health -= 1
	if health <= 0:
		die()

func die():
	anim.play("death")
	set_physics_process(false)

func flip_direction():
	direction *= -1
	_flip_direction_nodes()
