extends Node

var levels := [preload("res://Scenes/level0.tscn")]
var level_number := 0

@onready var current_level: Level
@onready var player: CharacterBody2D = %Player

func _ready() -> void:
	current_level = (levels.get(level_number) as PackedScene).instantiate() as Level
	add_child(current_level)
	player.position = current_level.get_good_coord()
	

func next_level() -> void:
	current_level.queue_free()
	level_number += 1
	current_level = levels.get(level_number)
	add_child(current_level)
	move_child(current_level, 100)
	while current_level.loading(): pass
