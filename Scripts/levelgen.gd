extends Node

# Pattern size to scan for in the sample image. Ideally should be 3. Cannot
# be negative.
@export var N: int = 3;

# The size of the outputted level, in NxN cells.
@export var output_size: Vector2i = Vector2i(10, 10);

# The input image to use for wave function collapse. Must be composed of N*N
# square patterns.
@export var input_image: TileMapLayer;

@onready var seed_layer: TileMapLayer = %SeedMap;
@onready var level_layer: TileMapLayer = %LevelLayer;

var patterns: Array[TileMapPattern];
var top_neighbors: Dictionary[TileMapPattern, ArrayOfTileMapPattern]
var bottom_neighbors: Dictionary[TileMapPattern, ArrayOfTileMapPattern]
var left_neighbors: Dictionary[TileMapPattern, ArrayOfTileMapPattern]
var right_neighbors: Dictionary[TileMapPattern, ArrayOfTileMapPattern]
var default_pattern: TileMapPattern

func _ready() -> void:
	patterns = parse_patterns(seed_layer);
	
	for a: Array[TileMapPattern] in [top_neighbors.keys(), bottom_neighbors.keys(), left_neighbors.keys(), right_neighbors.keys()]:
		for b in patterns:
			assert(a.has(b))
	
	seed_layer.visible = false;
	var a := top_neighbors
	var NbyNcells := await output();
	level_layer.set_pattern(Vector2i(0, 0), default_pattern)
	

func index_array(x_offset: int, y_offset: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = [];
	for x in N:
		for y in N:
			result.append(Vector2i(x + x_offset, y + y_offset));
	return result;

func has_pattern(input: TileMapPattern) -> bool:
	for i in index_array(0, 0):
		if !input.has_cell(i):
			return false;
	return true;

func parse_patterns(input: TileMapLayer) -> Array[TileMapPattern]:
	var result: Array[TileMapPattern] = [];
	default_pattern = input.get_pattern(index_array(-N, 0))
	for x_offset in input.get_used_rect().end.x - (N - 1):
		for y_offset in input.get_used_rect().end.y - (N - 1):
													  #^^^^^^^ dont even ask
			# continue if pattern is not correct dimensions
			var pattern := input.get_pattern(index_array(x_offset, y_offset))
			if !has_pattern(pattern):
				continue;
			
			var add_neighbor := func(neighbo: TileMapPattern, dict: Dictionary[TileMapPattern, ArrayOfTileMapPattern]) -> void:
				var neighbor := neighbo if has_pattern(neighbo) else default_pattern
				if dict.has(pattern):
					(dict.get(pattern) as ArrayOfTileMapPattern).data.append(neighbor)
				else:
					dict.set(pattern, ArrayOfTileMapPattern.new(neighbor))
					(dict.get(pattern) as ArrayOfTileMapPattern).data.append(default_pattern)
			
			add_neighbor.call(input.get_pattern(index_array(x_offset, y_offset - N)), top_neighbors)
			add_neighbor.call(input.get_pattern(index_array(x_offset, y_offset + N)), bottom_neighbors)
			add_neighbor.call(input.get_pattern(index_array(x_offset - N, y_offset)), left_neighbors)
			add_neighbor.call(input.get_pattern(index_array(x_offset + N, y_offset)), right_neighbors)
			
			result.append(pattern);
			# TODO: Add rotations and flips of the pattern here
	
	
	
	
	return result;

func output() -> Dictionary[Vector2i, TileMapPattern]:
	assert(patterns.size() > 0)
	
	var progress: Dictionary[Vector2i, Possibilities]
	
	var update_cell := func(coord: Vector2i) -> void:
		if !(0 <= coord.x && coord.x <= output_size.x && 0 <= coord.y && coord.y <= output_size.y):
			return
		
		var cell: Possibilities = progress.get(coord)
		
		if cell == null || cell.collapsed():
			return
		var oldvarnum : = cell.variants.size()
		
		var update_from_neighbor := func(coord: Vector2i, dict: Dictionary[TileMapPattern, ArrayOfTileMapPattern]) -> void:
			var neighbor: Possibilities = progress.get(coord) as Possibilities
			if neighbor == null || !neighbor.collapsed():
				return
			cell.update((dict.get(neighbor.variants.get(0) as TileMapPattern, ArrayOfTileMapPattern.new(default_pattern)) as ArrayOfTileMapPattern).data)
		
		update_from_neighbor.call(Vector2i(coord.x, coord.y - 1), top_neighbors)
		update_from_neighbor.call(Vector2i(coord.x, coord.y + 1), bottom_neighbors)
		update_from_neighbor.call(Vector2i(coord.x - 1, coord.y), left_neighbors)
		update_from_neighbor.call(Vector2i(coord.x + 1, coord.y), right_neighbors)
		
		if cell.variants.size() > oldvarnum:
			push_error("what the fuck?")
		if cell.variants.size() == oldvarnum:
			#push_warning("no change")
			pass
		if cell.variants.size() > oldvarnum:
			push_error("yayyy!!")
	
	for cellX in output_size.x:
		progress.set(Vector2i(cellX, -1), Possibilities.new([default_pattern]))
		progress.set(Vector2i(cellX, output_size.y + 1), Possibilities.new([default_pattern]))
	for cellY in output_size.y:
		progress.set(Vector2i(-1, cellY), Possibilities.new([default_pattern]))
		progress.set(Vector2i(output_size.x + 1, cellY), Possibilities.new([default_pattern]))
	
	for cellX in output_size.x:
		for cellY in output_size.y:
			progress.set(Vector2i(cellX, cellY), Possibilities.new(patterns))
	for cellX in output_size.x:
		for cellY in output_size.y:
			update_cell.call(Vector2i(cellX, cellY))
	
	# Randomly collapses a field and updates all neighbors.
	var collapse := func(coord: Vector2i) -> void:
		var cell: Possibilities = progress.get(coord)
		if cell == null:
			return
		
		cell.collapse(default_pattern)
		
		update_cell.call(Vector2i(coord.x, coord.y - 1))
		update_cell.call(Vector2i(coord.x, coord.y + 1))
		update_cell.call(Vector2i(coord.x - 1, coord.y))
		update_cell.call(Vector2i(coord.x + 1, coord.y))
		
		level_layer.set_pattern(coord * 3, cell.variants.get(0) as TileMapPattern)
	
	var cellX := randi_range(0, output_size.x - 1);
	var cellY := randi_range(0, output_size.y - 1);

	# Randomly collapse one to start
	collapse.call(Vector2i(cellX, cellY));    

	# TODO: Store cells in a priority queue to go faster
	while true:
		var best: Vector2i = progress.keys().get(0);
		for cell in progress:
			if (progress.get(cell) as Possibilities).entropy() < (progress.get(best) as Possibilities).entropy():
				best = cell;
		if (progress.get(best) as Possibilities).collapsed():
			break;
		collapse.call(best);
		await get_tree().create_timer(0.1).timeout;
		# HHH assert((progress.get(best) as Possibilities).collapsed())
		
	for i in progress:
		# TODO: Assert they are all valid
		pass
	
	# cant .map() a dictionary :(
	var result: Dictionary[Vector2i, TileMapPattern];
	for i in progress:
		result.set(i, (progress.get(i) as Possibilities).variants.get(0));
	return result;



class Possibilities extends Node:
	var variants: Array[TileMapPattern];

	# Returns the variant. Otherwise null.
	func collapsed() -> bool:
		return variants.size() == 1
		
	@warning_ignore("shadowed_variable")
	func _init(variants: Array[TileMapPattern]) -> void:
		self.variants = variants;

	func new(posss: Array[TileMapPattern]) -> Possibilities:
		return Possibilities.new(posss);

	func collapse(default: TileMapPattern) -> void:
		if variants.size() == 0:
			variants = [default]
			return
		variants = [variants.pick_random()];

	func entropy() -> int:
		if variants.size() == 1:
			return 9223372036854775807
		return variants.size();

	func update(other: Array) -> void:
		for pattern: TileMapPattern in other:
			variants = variants.filter(func(pattern: TileMapPattern) -> bool: return other.has(pattern))

class ArrayOfTileMapPattern:
	var data: Array[TileMapPattern]
	
	func _init(init: TileMapPattern) -> void:
		data = [init];
