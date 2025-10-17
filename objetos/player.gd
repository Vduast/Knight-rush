extends CharacterBody2D

# --- Constantes de movimiento ---
const SPEED            = 600
const JUMP_FORCE       = 450
const GRAVITY          = 1200.0
const FAST_FALL_MULT   = 1.6

# --- Slide ---
const SLIDE_SPEED      = 700
const SLIDE_TIME       = 0.5

# --- Wall Jump ---
const WALL_JUMP_FORCE  = 600
const WALL_JUMP_ANGLE  = 65

# --- Wall Slide ---
const WALL_SLIDE_SPEED = 100.0

# --- Dash ---
const DASH_SPEED       = 600
const DASH_TIME        = 0.5

# --- Coyote Time & Jump Buffer ---
const COYOTE_TIME      = 0.12
const JUMP_BUFFER_TIME = 0.12
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

# --- Momentum ---
var momentum_multiplier: float = 1.0
const MOMENTUM_MAX = 1.4
const MOMENTUM_GAIN = 0.05
const MOMENTUM_DECAY = 0.02

# --- Estado ---
var sliding: bool = false
var slide_timer: float = 0.0
var slide_dir: int = 0

var dashing: bool = false
var dash_timer: float = 0.0
var dash_dir: int = 0
var can_dash: bool = true

var wall_sticking: bool = false

# --- Ataque ---
# --- Ataque ---
const ATTACK_COOLDOWN = 01
var attack_timer: float = 0.0
var attacking: bool = false

# --- Referencias ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D

# --- Tamaños de hitbox ---
var normal_extents: Vector2
var slide_extents: Vector2

# --- Ajuste visual al hacer flip ---
const FLIP_OFFSET = 8

func _ready():
	normal_extents = col_shape.shape.extents
	slide_extents = Vector2(normal_extents.x * 1.5, normal_extents.y * 0.5)
	anim.animation_finished.connect(_on_attack_finished)


func _physics_process(delta):
	
	
	# --- Ataque melee ---
	if attack_timer > 0:
		attack_timer -= delta

	# --- Ataque melee ---
	if attack_timer > 0:
		attack_timer -= delta

	if Input.is_action_just_pressed("attack") and attack_timer <= 0 and not attacking:
		if is_on_floor() and not sliding and not is_on_wall() and not wall_sticking:
			perform_attack()
	# --- Timers de coyote y jump buffer ---
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0)

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0)

	if is_on_floor():
		can_dash = true
		wall_sticking = false
		if dashing:
			end_dash()

	# --- Dash ---
	if dashing:
		dash_timer -= delta
		velocity.y = 0
		velocity.x = dash_dir * DASH_SPEED * momentum_multiplier
		if dash_timer <= 0.0:
			end_dash()
		momentum_multiplier = min(momentum_multiplier + MOMENTUM_GAIN, MOMENTUM_MAX)
		move_and_slide()
		play_animation()
		return

	# --- Gravedad ---
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		if Input.is_action_pressed("ui_down"):
			velocity.y += GRAVITY * (FAST_FALL_MULT - 1) * delta

	# --- Slide ---
	if sliding:
		slide_timer -= delta
		velocity.x = slide_dir * SLIDE_SPEED * momentum_multiplier
		if Input.is_action_just_pressed("jump"):
			end_slide()
			velocity.y = -JUMP_FORCE * 1.1 * momentum_multiplier
			velocity.x = slide_dir * SPEED * 1.4 * momentum_multiplier
			anim.play("jump")
			momentum_multiplier = min(momentum_multiplier + MOMENTUM_GAIN, MOMENTUM_MAX)
		if slide_timer <= 0.0:
			end_slide()
		move_and_slide()
		play_animation()
		return

	# --- Movimiento normal ---
	var dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if not wall_sticking and not attacking:
		velocity.x = dir * SPEED * momentum_multiplier
	else:
		velocity.x = 0

	if abs(dir) > 0 and is_on_floor():
		momentum_multiplier = min(momentum_multiplier + MOMENTUM_GAIN, MOMENTUM_MAX)

	# --- Salto (con coyote + buffer + momentum) ---
	if jump_buffer_timer > 0:
		if wall_sticking:
			var col = get_last_slide_collision()
			if col:
				var normal = col.get_normal()
				var angle = deg_to_rad(WALL_JUMP_ANGLE)
				var direction = normal.x
				velocity.x = cos(angle) * WALL_JUMP_FORCE * direction * momentum_multiplier
				velocity.y = -sin(angle) * WALL_JUMP_FORCE * momentum_multiplier
				anim.flip_h = direction < 0
				anim.offset.x = -2 if anim.flip_h else 2
				wall_sticking = false
				momentum_multiplier = min(momentum_multiplier + MOMENTUM_GAIN, MOMENTUM_MAX)
				jump_buffer_timer = 0
		elif is_on_floor() or coyote_timer > 0:
			velocity.y = -JUMP_FORCE * momentum_multiplier
			if abs(velocity.x) > SPEED * 0.5:
				velocity.x *= 1.1
			momentum_multiplier = min(momentum_multiplier + MOMENTUM_GAIN, MOMENTUM_MAX)
			jump_buffer_timer = 0

	# --- Slide desde suelo ---
	if is_on_floor() and Input.is_action_just_pressed("slide") and dir != 0:
		start_slide(dir)

	# --- Wall Grab automático (excepto en TileMapLayer3) ---
	if is_on_wall() and velocity.y > 0:
		var col = get_last_slide_collision()
		if col and col.get_collider() is TileMapLayer:
			var tilemap := col.get_collider() as TileMapLayer
			if tilemap.name == "TileMapLayer3":
				wall_sticking = false
			else:
				velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
				wall_sticking = true
				anim.play("wall")
				var normal = col.get_normal()
				anim.flip_h = normal.x < 0
				anim.offset = Vector2(-2 if anim.flip_h else 2, 0)
		else:
			wall_sticking = false
	else:
		wall_sticking = false

	# --- Dash en aire ---
	if Input.is_action_just_pressed("slide") and can_dash and not is_on_wall() and not sliding:
		start_dash()

	# --- Decaer momentum ---
	if abs(dir) == 0 and not sliding and not dashing and not is_on_wall():
		momentum_multiplier = max(momentum_multiplier - MOMENTUM_DECAY, 1.0)

	move_and_slide()
	play_animation()

# --- Animaciones ---
func play_animation():
	if attacking:
		if anim.animation != "attack":
			anim.play("attack")
		return
	if dashing:
		anim.play("dash")
	elif sliding:
		anim.play("slide")
	elif not is_on_floor():
		if velocity.y < 0:
			anim.play("jump")
		elif wall_sticking:
			anim.play("wall")
		else:
			anim.play("fall")
	else:
		if abs(velocity.x) > 10:
			anim.play("run")
		else:
			anim.play("idle")

	if not wall_sticking and not sliding and not dashing:
		if velocity.x != 0:
			var going_left = velocity.x < 0
			anim.flip_h = going_left
			anim.offset.x = -FLIP_OFFSET if going_left else FLIP_OFFSET
			var hitbox = $AttackArea
			hitbox.position.x = -120 if going_left else 120

# --- Slide ---
func start_slide(dir: int):
	sliding = true
	slide_timer = SLIDE_TIME
	slide_dir = dir
	col_shape.shape.extents = slide_extents
	col_shape.position.y += (normal_extents.y - slide_extents.y)

func end_slide():
	sliding = false
	col_shape.shape.extents = normal_extents
	col_shape.position.y -= (normal_extents.y - slide_extents.y)

# --- Dash ---
func start_dash():
	dashing = true
	dash_timer = DASH_TIME
	dash_dir = sign(velocity.x) if velocity.x != 0 else (-1 if anim.flip_h else 1)
	can_dash = false
	col_shape.shape.extents = slide_extents
	col_shape.position.y += (normal_extents.y - slide_extents.y)
	velocity.y = -JUMP_FORCE * 0.2


func end_dash():
	dashing = false
	col_shape.shape.extents = normal_extents
	col_shape.position.y -= (normal_extents.y - slide_extents.y)
	
func perform_attack():
	if attacking:
		return

	attacking = true
	attack_timer = ATTACK_COOLDOWN

	# Ajustar hitbox según flip
	var hitbox = $AttackArea
	

	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("enemies"):
			body.take_damage()
			
func _on_attack_finished():
	if attacking:
		attacking = false
# --- Muerte ---
func die():
	anim.play("death")
	set_physics_process(false)
	await anim.animation_finished

	var death_menu = load("res://ui/DeathMenu.tscn").instantiate()
	get_tree().current_scene.add_child(death_menu)
	get_tree().current_scene.move_child(death_menu, get_tree().current_scene.get_child_count() - 1)
