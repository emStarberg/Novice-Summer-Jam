extends Node

@onready var points: Node = %StuffThatNeedsToBePathable

@onready var loading_screen: TextureRect = %loadingscreen

@onready var tilemap: TileMapLayer = %tilemap
@onready var tile_size: int = tilemap.tile_set.tile_size.x
@onready var max_x: int = tilemap.get_used_rect().end.x
@onready var max_y: int = tilemap.get_used_rect().end.y

@export var noise: FastNoiseLite
@export_range(-1, 1, 0.01) var noise_threshold: float

func _ready() -> void:
	call_deferred("generate")
	loading_screen.visible = false

func generate() -> void:
	for child: Node2D in points.get_children():
		child.position = Vector2(randi_range(0, max_x) * tile_size, randi_range(0, max_y) * tile_size)
	
	noise.seed = randi()
	
	for x in max_x:
		for y in max_y:
			if noise.get_noise_2d(x, y) > noise_threshold:
				tilemap.set_cells_terrain_connect([Vector2i(x, y)], 0, 1)
			else: # Can break paths
				tilemap.set_cells_terrain_connect([Vector2i(x, y)], 0, 0)
	
	if !await all_connected():
		generate()

func all_connected() -> bool:
	for child: Node2D in points.get_children():
		if !await are_connected(child.position):
			return false
	return true

func are_connected(p: Vector2) -> bool:
	await NavigationServer2D.map_changed
	var closest_point := NavigationServer2D.map_get_closest_point(tilemap.get_navigation_map(), p)
	return (closest_point - p).is_zero_approx()
