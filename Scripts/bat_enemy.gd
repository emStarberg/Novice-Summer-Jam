extends CharacterBody2D

@export var speed: float = 100.0
@export var change_direction_time: float = 5.0
@export var screen_size: Vector2 = Vector2(1152, 648)
@export var move_interval: float = 0.5

var direction: Vector2 = Vector2.ZERO
var player_chase: bool = false
var player: CharacterBody2D = null  # player reference

@onready var direction_timer: Timer = Timer.new()
@onready var move_timer: Timer = Timer.new()
@onready var detection_area: Area2D = $DetectionArea

func _ready() -> void:
	randomize()

	player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	# Roaming direction timer
	direction_timer.wait_time = change_direction_time
	direction_timer.autostart = true
	direction_timer.one_shot = false
	add_child(direction_timer)
	direction_timer.timeout.connect(_on_change_direction)
	_on_change_direction()

	# Step movement timer
	move_timer.wait_time = move_interval
	move_timer.autostart = true
	move_timer.one_shot = false
	add_child(move_timer)
	move_timer.timeout.connect(_on_move)

	# Detection signals
	if not detection_area.is_connected("body_entered", Callable(self, "_on_detection_area_body_entered")):
		detection_area.body_entered.connect(Callable(self, "_on_detection_area_body_entered"))

	if not detection_area.is_connected("body_exited", Callable(self, "_on_detection_area_body_exited")):
		detection_area.body_exited.connect(Callable(self, "_on_detection_area_body_exited"))

func _on_move() -> void:
	var new_pos: Vector2 = global_position

	if player_chase and player:
		# Move toward player using step movement
		direction = (player.global_position - global_position).normalized()
	
	new_pos += direction * speed * move_interval

	# Keep inside screen & bounce (only affects roaming direction)
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
	# Only change direction when roaming
	if not player_chase:
		var angle: float = randf() * TAU
		direction = Vector2(cos(angle), sin(angle)).normalized()

# --- Detection by group ---
func _on_detection_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body as CharacterBody2D
		player_chase = true

func _on_detection_area_body_exited(body: Node) -> void:
	if body == player:
		player_chase = false
		player = null
		_on_change_direction()
