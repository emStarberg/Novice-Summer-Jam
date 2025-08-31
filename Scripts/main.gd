extends Node

var levels := [preload("res://Scenes/level0.tscn"), preload("res://Scenes/level1.tscn")]
var level_number := 0

@onready var current_level: Level
@onready var player: CharacterBody2D = %Player

func _ready() -> void:
	current_level = (levels.get(level_number) as PackedScene).instantiate() as Level
	add_child(current_level)
	player.position = current_level.get_good_coord()
	Signalbus.connect("transition", next_level)
	#Signalbus.emit_signal("transition")

func next_level() -> void:
	if level_number == 1:
		return
	current_level.queue_free()
	level_number += 1
	current_level = levels.get(level_number).instantiate() as Level
	if current_level.get_parent():
		current_level.get_parent().remove_child(current_level)
	#call_deferred("add_child", current_level)
	print_stack()
	add_child(current_level)
	#move_child(current_level, 100)
	player.position = current_level.get_good_coord()
	player.position = current_level.get_good_coord()
	player.position = current_level.get_good_coord()
