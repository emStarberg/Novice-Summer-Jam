extends Node

class_name Level

var loadin:=true

@onready var loading_screen: TextureRect = %loadingscreen
@onready var spawnables: Node = %level_spawnables

@onready var tilemap: TileMapLayer = %tilemap
@onready var tile_size: int = tilemap.tile_set.tile_size.x

@export var max_x: int = 50
@export var max_y: int = 50

@export var noise: FastNoiseLite
@export var offset: GradientTexture2D

@export var wall_terrain: int
const floor_terrain := 0

@export_range(0.1, 1, 0.01) var noise_threshold: float

@onready var good_tiles: Array[Vector2i] = [Vector2i(max_x / 2, max_y / 2)]

func _ready() -> void:
	offset.width = max_x
	offset.height = max_y
	generate()
	loading_screen.visible = false
	loadin = false

func loading() -> bool:
	return loadin

func index(x: int, y: int) -> float:
	return ((noise.get_noise_2d(x, y) + 1.0) * 0.5) * \
	offset.get_image().get_pixel(x, y).get_luminance()

func get_good_coord() -> Vector2i:
	var tile : Variant = good_tiles.pick_random()
	good_tiles.erase(tile)
	return tile * tile_size

func generate() -> void:
	noise.seed = randi()
	
	var all_cells : Array[Vector2i]
	for x in max_x:
		for y in max_y:
				#tilemap.set_cell(Vector2i(x, y), 1, Vector2i(10, 1), 1)
			all_cells.append(Vector2i(x, y))
	
	tilemap.set_cells_terrain_connect(all_cells, 0, wall_terrain)
	
	for x in max_x:
		for y in max_y:
			if index(x, y) > noise_threshold:
				tilemap.set_cells_terrain_connect([Vector2i(x, y)], 0, floor_terrain)
			else: # Can break paths
				tilemap.set_cells_terrain_connect([Vector2i(x, y)], 0, wall_terrain)
	
	tilemap.set_cells_terrain_connect([Vector2i(max_x / 2, max_y / 2)], 0, floor_terrain)
	
	good_tiles = find_connected(Vector2i(max_x / 2, max_y / 2))
	
	for child: Node2D in spawnables.get_children():
		child.position = get_good_coord()


func neighboring(start: Vector2i) -> Array[Vector2i]:
	return [start + Vector2i(0, -1),
			start + Vector2i(-1, 0),
			start + Vector2i(0, 1),
			start + Vector2i(1, 0)]

func find_connected(start: Vector2i) -> Array:
	var tile := tilemap.get_cell_atlas_coords(start)
	var result: Array[Vector2i] = [start]
	var search: Array[Vector2i] = [start]
	
	while search.size() != 0:
		for neighbor in neighboring(search.front() as Vector2i):
			if tilemap.get_cell_atlas_coords(neighbor) != tile || result.has(neighbor):
				continue
			result.push_back(neighbor)
			search.push_back(neighbor)
		search.remove_at(0)
	
	return result
