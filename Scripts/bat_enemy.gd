extends CharacterBody2D

# --- Enemy parameters ---
@export var speed: float = 64.0              # Pixels per second, same as player
@export var move_distance: float = 16.0      # One tile per turn
@export var screen_size: Vector2 = Vector2(1152, 648)

# --- Movement state ---
var direction: Vector2 = Vector2.ZERO        # Current moving direction
var last_direction: Vector2 = Vector2(0, 1)  # Last move direction for idle facing
var move_target: Vector2 = Vector2.ZERO      # Target position for smooth movement
var is_moving: bool = false                  # Currently moving

# --- Player detection ---
var player_chase: bool = false
var player: CharacterBody2D = null
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea

# --- Attack state ---
var attack_cooldown: float = 5.0   # idle after attack (seconds)
var can_attack: bool = true
var is_attacking: bool = false
@onready var batAudio: AudioStreamPlayer2D = $AudioStreamPlayer2D

# --- Sprites ---
@onready var idle_sprite: AnimatedSprite2D = $Animations/Idle
@onready var movement_sprite: AnimatedSprite2D = $Animations/Movement
@onready var attack_sprite: AnimatedSprite2D = $Animations/Attack

# --- Setup ---
func _ready() -> void:
	randomize()
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	# Connect detection signals
	if not detection_area.is_connected("body_entered", Callable(self, "_on_detection_area_body_entered")):
		detection_area.body_entered.connect(Callable(self, "_on_detection_area_body_entered"))

	if not detection_area.is_connected("body_exited", Callable(self, "_on_detection_area_body_exited")):
		detection_area.body_exited.connect(Callable(self, "_on_detection_area_body_exited"))

	# Connect attack area
	if not attack_area.is_connected("body_entered", Callable(self, "_on_attack_area_body_entered")):
		attack_area.body_entered.connect(Callable(self, "_on_attack_area_body_entered"))

	# Connect attack animation end
	if not attack_sprite.is_connected("animation_finished", Callable(self, "_on_attack_anim_finished")):
		attack_sprite.animation_finished.connect(Callable(self, "_on_attack_anim_finished"))

# --- Movement ---
func _physics_process(delta: float) -> void:
	if is_moving:
		var distance: Vector2 = move_target - global_position
		var step: Vector2 = direction * speed * delta
		if step.length() >= distance.length():
			global_position = move_target
			is_moving = false
			last_direction = direction
			direction = Vector2.ZERO
		else:
			global_position += step

	if not is_attacking:
		_update_sprite()

# --- Called by TurnManager when it is the enemy's turn ---
func TakeTurn() -> void:
	if is_moving or is_attacking:
		return # Wait until current action finishes

	# Already close enough to attack?
	if player and attack_area.overlaps_body(player):
		_attack_player(player)
		return

	# Determine movement direction
	if player_chase and player:
		direction = (player.global_position - global_position).normalized()
	else:
		var directions: Array[Vector2] = [
			Vector2(-1, 0),  # left
			Vector2(1, 0),   # right
			Vector2(0, -1),  # up
			Vector2(0, 1)    # down
		]
		direction = directions[randi() % directions.size()]

	# Set target position one tile away
	move_target = global_position + direction * move_distance

	# Keep inside screen bounds
	move_target.x = clamp(move_target.x, 0, screen_size.x)
	move_target.y = clamp(move_target.y, 0, screen_size.y)

	is_moving = true

# --- Attacking ---
func _on_attack_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body is CharacterBody2D:
		_attack_player(body as CharacterBody2D)

func _attack_player(target: CharacterBody2D) -> void:
	if can_attack:
		is_attacking = true
		can_attack = false

		# Deal damage
		if target.has_method("Hurt"):
			target.call("Hurt", 10.0)

		# Play attack animation in correct direction
		var dir_str: String = "down"
		if last_direction.x < 0:
			dir_str = "left"
		elif last_direction.x > 0:
			dir_str = "right"
		elif last_direction.y < 0:
			dir_str = "up"
		elif last_direction.y > 0:
			dir_str = "down"

		attack_sprite.animation = dir_str
		attack_sprite.visible = true
		attack_sprite.play()
		idle_sprite.visible = false
		movement_sprite.visible = false

# --- After attack animation finishes ---
func _on_attack_anim_finished() -> void:
	attack_sprite.visible = false
	is_attacking = false

	# Go into idle state for cooldown
	_update_sprite()
	await get_tree().create_timer(attack_cooldown).timeout

	# Reset attack cooldown so it can attack again later
	can_attack = true

# --- Update sprites based on movement and direction ---
func _update_sprite() -> void:
	var dir_str: String = "down"
	var facing_dir: Vector2 = direction if is_moving else last_direction

	if facing_dir.x < 0:
		dir_str = "left"
	elif facing_dir.x > 0:
		dir_str = "right"
	elif facing_dir.y < 0:
		dir_str = "up"
	elif facing_dir.y > 0:
		dir_str = "down"

	if is_moving:
		movement_sprite.animation = dir_str
		movement_sprite.visible = true
		movement_sprite.play()
		idle_sprite.visible = false
		attack_sprite.visible = false
	else:
		idle_sprite.animation = dir_str
		idle_sprite.visible = true
		idle_sprite.play()
		movement_sprite.visible = false
		attack_sprite.visible = false

# --- Detection area signals ---
	
	new_pos += direction * speed * move_interval
	batAudio.play()

	if not player_chase:
		if new_pos.x < 0:
			new_pos.x = 0
			direction.x *= -1
		elif new_pos.x > screen_size.x:
			new_pos.x = screen_size.x
			direction.x *= -1

		if new_pos.y < 0:
			new_pos.y = 0
			direction.y *= -1
		elif new_pos.y > screen_size.y:
			new_pos.y = screen_size.y
			direction.y *= -1

	global_position = new_pos

func _on_change_direction() -> void:
	if not player_chase:
		var angle: float = randf() * TAU
		direction = Vector2(cos(angle), sin(angle)).normalized()
    
func _on_detection_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body is CharacterBody2D:
		player = body as CharacterBody2D
		player_chase = true

func _on_detection_area_body_exited(body: Node) -> void:
	if body == player:
		player_chase = false
		player = null
