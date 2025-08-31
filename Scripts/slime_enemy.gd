extends CharacterBody2D

# --- Enemy parameters ---
@export var speed: float = 64.0              # Pixels per second, same as player
@export var move_distance: float = 16.0      # One tile per turn
var screen_size: Vector2 = Vector2(ProjectSettings.get("display/window/size/viewport_width") as float, ProjectSettings.get("display/window/size/viewport_height") as float)
@export var max_hits: int = 3

# --- Movement state ---
var direction: Vector2 = Vector2.ZERO        # Current moving direction
var last_direction: Vector2 = Vector2(0, 1)  # Last move direction for idle facing
var move_target: Vector2 = Vector2.ZERO      # Target position for smooth movement
var is_moving: bool = false                  # Currently moving

var move_interval: float = 1.0
var new_pos: Vector2 = Vector2.ZERO

# --- Player detection ---
var player_chase: bool = false
var player: CharacterBody2D = null
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea

# --- Attack state ---
var attack_cooldown: float = 5.0   # idle after attack (seconds)
var can_attack: bool = true
var is_attacking: bool = false

# --- Hit tracking ---
var current_hits: int = 0

# --- Collisions ---
@onready var cast_left: RayCast2D = $Raycasts/Left
@onready var cast_right: RayCast2D = $Raycasts/Right
@onready var cast_up: RayCast2D = $Raycasts/Up
@onready var cast_down: RayCast2D = $Raycasts/Down

# --- Sprites ---
@onready var idle_sprite: AnimatedSprite2D = $Animations/Idle
@onready var movement_sprite: AnimatedSprite2D = $Animations/Movement
@onready var attack_sprite: AnimatedSprite2D = $Animations/Attack
@onready var hurt_sprite: AnimatedSprite2D = $Animations/Hurt
@onready var death_sprite: AnimatedSprite2D = $Animations/Death

@onready var turn_manager: Node = get_parent().get_parent().get_parent().get_node("Turn Manager") # Get turn manager as Node2D


# --- Setup ---
func _ready() -> void:
	turn_manager.connect("EnemyTurn", Callable(self, "TakeTurn"))
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

	# Connect attack animation finished
	if not attack_sprite.is_connected("animation_finished", Callable(self, "_on_attack_anim_finished")):
		attack_sprite.animation_finished.connect(Callable(self, "_on_attack_anim_finished"))

# --- Physics / Movement ---
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

	if not is_attacking and current_hits < max_hits:
		_update_sprite()

# --- Enemy turn ---
func TakeTurn() -> void:
	if is_moving or is_attacking or current_hits >= max_hits:
		return # Wait until current action finishes or dead

	# Already close enough to attack?
	if player and attack_area.overlaps_body(player):
		_attack_player(player)
		return

	# Determine movement direction
	var directions: Array[Vector2] = []
	if not cast_left.is_colliding():
		directions.append(Vector2(-1, 0))
	if not cast_right.is_colliding():
		directions.append(Vector2(1, 0))
	if not cast_up.is_colliding():
		directions.append(Vector2(0, -1))
	if not cast_down.is_colliding():
		directions.append(Vector2(0, 1))

	if player_chase and player:
		var chase_dir: Vector2 = (player.global_position - global_position).normalized()
		# Only chase if the direction is not blocked
		if chase_dir.x < 0 and not cast_left.is_colliding():
			direction = Vector2(-1, 0)
		elif chase_dir.x > 0 and not cast_right.is_colliding():
			direction = Vector2(1, 0)
		elif chase_dir.y < 0 and not cast_up.is_colliding():
			direction = Vector2(0, -1)
		elif chase_dir.y > 0 and not cast_down.is_colliding():
			direction = Vector2(0, 1)
		else:
			if directions.size() > 0:
				direction = directions[randi() % directions.size()]
			else:
				direction = Vector2.ZERO
	else:
		if directions.size() > 0:
			direction = directions[randi() % directions.size()]
		else:
			direction = Vector2.ZERO

	move_target = global_position + direction * move_distance
	move_target.x = clamp(move_target.x, 0, screen_size.x)
	move_target.y = clamp(move_target.y, 0, screen_size.y)
	is_moving = direction != Vector2.ZERO

# --- Attack player ---
func _on_attack_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body is CharacterBody2D:
		_attack_player(body as CharacterBody2D)

func _attack_player(target: CharacterBody2D) -> void:
	if can_attack:
		is_attacking = true
		can_attack = false

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
		_play_animation(attack_sprite)

# --- After attack animation ---
func _on_attack_anim_finished() -> void:
	attack_sprite.visible = false
	is_attacking = false
	_update_sprite()
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

# --- Take hit / hurt / die ---
func TakeHit() -> void:
	current_hits += 1
	print("Enemy hit! Total hits: ", current_hits)

	if current_hits < max_hits:
		_play_animation(hurt_sprite)
	else:
		_play_animation(death_sprite)
		await death_sprite.animation_finished
		Die()

func _play_animation(anim: AnimatedSprite2D) -> void:
	idle_sprite.visible = false
	movement_sprite.visible = false
	attack_sprite.visible = false
	hurt_sprite.visible = false
	death_sprite.visible = false

	anim.visible = true
	anim.play()

func Die() -> void:
	queue_free()

# --- Update movement/idle sprites ---
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
		_play_animation(movement_sprite)
	else:
		idle_sprite.animation = dir_str
		_play_animation(idle_sprite)

# --- Detection area signals ---
func _on_detection_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body is CharacterBody2D:
		player = body as CharacterBody2D
		player_chase = true

func _on_detection_area_body_exited(body: Node) -> void:
	if body == player:
		player_chase = false
		player = null
