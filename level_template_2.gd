extends Node

@onready var tilemap: TileMapLayer = %tilemap
@onready var max_x: int = tilemap.get_used_rect().end.x
@onready var max_y: int = tilemap.get_used_rect().end.y

@export var noise: FastNoiseLite
@export var noise_threshold: float

func _ready() -> void:
	noise.seed = randi()
	
	for x in max_x:
		for y in max_y:
			if noise.get_noise_2d(x, y) > noise_threshold:
				tilemap.set_cells_terrain_connect([Vector2i(x, y)], 0, 1)
			#else:
			#	tilemap.set_cells_terrain_connect([Vector2i(x, y)], 0, 0)
