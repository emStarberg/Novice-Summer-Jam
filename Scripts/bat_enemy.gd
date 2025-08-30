extends CharacterBody2D

@export var speed: float = 100.0
@export var change_direction_time: float = 5.0
@export var screen_size: Vector2 = Vector2(1152, 648)
@export var chase_range: float = 200.0  # pixels

var direction: Vector2 = Vector2.ZERO

@onready var direction_timer: Timer = Timer.new()
@onready var player: Node2D = null

func _ready() -> void:
	randomize()
	# get the player (assumes player is in group "player")
	player = get_tree().get_first_node_in_group("player")
	
	direction_timer.wait_time = change_direction_time
	direction_timer.autostart = true
	direction_timer.one_shot = false
	add_child(direction_timer)
	direction_timer.timeout.connect(_on_change_direction)
	_on_change_direction()

func _physics_process(delta: float) -> void:
	if player and global_position.distance_to(player.global_position) <= chase_range:
		# chase the player
		direction = (player.global_position - global_position).normalized()

	velocity = direction * speed
	move_and_slide()

	# keep inside screen
	var new_pos: Vector2 = global_position
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
	var angle: float = randf() * TAU
	direction = Vector2(cos(angle), sin(angle)).normalized()
