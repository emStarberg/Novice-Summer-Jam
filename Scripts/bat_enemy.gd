extends CharacterBody2D

@export var speed: float = 30.0
@export var roam_time_min: float = 1.0
@export var roam_time_max: float = 3.0
@export var idle_time_min: float = 0.5
@export var idle_time_max: float = 1.5

enum State { IDLE, ROAMING }

var current_state: State = State.IDLE
var target_direction: Vector2 = Vector2.ZERO

@onready var timer: Timer = $Timer

func _ready() -> void:
	set_new_state(State.ROAMING)

func _physics_process(delta: float) -> void:
	match current_state:
		State.ROAMING:
			velocity = target_direction * speed
			move_and_slide()
		State.IDLE:
			velocity = Vector2.ZERO
			move_and_slide()

func set_new_state(new_state: State) -> void:
	current_state = new_state
	match current_state:
		State.IDLE:
			timer.wait_time = randf_range(idle_time_min, idle_time_max)
			timer.start()
		State.ROAMING:
			target_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			timer.wait_time = randf_range(roam_time_min, roam_time_max)
			timer.start()

func _on_timer_timeout() -> void:
	if current_state == State.IDLE:
		set_new_state(State.ROAMING)
	elif current_state == State.ROAMING:
		set_new_state(State.IDLE)
