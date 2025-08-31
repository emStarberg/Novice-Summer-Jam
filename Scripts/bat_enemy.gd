extends CharacterBody2D

# --- Enemy parameters ---
@export var speed: float = 64.0              # Pixels per second, same as player
@export var move_distance: float = 16.0      # One tile per turn
@export var screen_size: Vector2 = Vector2(1152, 648)

# --- Movement state ---
var direction: Vector2 = Vector2.ZERO        # Current moving direction
var last_direction: Vector2 = Vector2(0, 1) # Last move direction for idle facing
var move_target: Vector2 = Vector2.ZERO      # Target position for smooth movement
var is_moving: bool = false                  # Currently moving

# --- Player detection ---
var player_chase: bool = false
var player: CharacterBody2D = null
@onready var detection_area: Area2D = $DetectionArea

# --- Sprites ---
@onready var idle_sprite: AnimatedSprite2D = $Animations/Idle
@onready var movement_sprite: AnimatedSprite2D = $Animations/Movement

func _ready() -> void:
	randomize()
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	# Connect detection signals
	if not detection_area.is_connected("body_entered", Callable(self, "_on_detection_area_body_entered")):
		detection_area.body_entered.connect(Callable(self, "_on_detection_area_body_entered"))

	if not detection_area.is_connected("body_exited", Callable(self, "_on_detection_area_body_exited")):
		detection_area.body_exited.connect(Callable(self, "_on_detection_area_body_exited"))

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

	_update_sprite()

# --- Called by TurnManager when it is the enemy's turn ---
func TakeTurn() -> void:
	if is_moving:
		return # Wait until current move finishes

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
	else:
		idle_sprite.animation = dir_str
		idle_sprite.visible = true
		idle_sprite.play()
		movement_sprite.visible = false


# --- Detection area signals ---
func _on_detection_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body as CharacterBody2D
		player_chase = true

func _on_detection_area_body_exited(body: Node) -> void:
	if body == player:
		player_chase = false
		player = null
