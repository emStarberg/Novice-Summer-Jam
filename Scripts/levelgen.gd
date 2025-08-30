extends Node

# Pattern size to scan for in the sample image. Ideally should be 3. Cannot
# be negative.
@export var N: int = 3;

# The size of the outputted level, in NxN cells.
@export var output_size: Vector2i = Vector2i(20, 20);

# The input image to use for wave function collapse. Must be composed of N*N
# square patterns.
@export var input_image: TileMapLayer;

@onready var seed_layer: TileMapLayer = %SeedMap;
@onready var level_layer: TileMapLayer = %LevelLayer;

var patterns: Array[TileMapPattern];

func _ready() -> void:
	patterns = parse_patterns(seed_layer);
	var NbyNcells := output();

	for x in output_size.x:
		for y in output_size.y:
			level_layer.set_pattern(Vector2i(x * 3, y * 3), NbyNcells.get(Vector2i(x, y)) as TileMapPattern)
			
	seed_layer.visible = false;

func index_array(x_offset: int, y_offset: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = [];

	for x in N:
		for y in N:
			result.append(Vector2i(x + x_offset, y + y_offset));

	return result;

func null_array() -> Array[int]:
	var result: Array[int] = [];

	for x in N:
		var row: Array[int] = [];
		for y in N:
			result.append(null);
		result.append(row);

	return result;

func has_pattern(input: TileMapPattern) -> bool:
	for i in index_array(0, 0):
		if !input.has_cell(i):
			return false;
	return true;

func parse_patterns(input: TileMapLayer) -> Array[TileMapPattern]:
	var result: Array[TileMapPattern] = [];

	@warning_ignore("integer_division")
	for x_offset in input.get_used_rect().size.x:

		@warning_ignore("integer_division")
		for y_offset in input.get_used_rect().size.y:
			
			# continue if pattern is not correct dimensions
			if !has_pattern(input.get_pattern(index_array(x_offset, y_offset))):
				continue;
		   
			result.append(input.get_pattern(index_array(x_offset, y_offset)));
			# TODO: Add rotations and flips of the pattern here

			
	return result;

func output() -> Dictionary[Vector2i, TileMapPattern]:

	assert(patterns.size() > 0)
	
	var progress: Dictionary[Vector2i, Possibilities];

	for cellX in output_size.x:
		for cellY in output_size.y:
			progress.set(Vector2i(cellX, cellY), Possibilities.new(patterns))

			
	# Returns true if collapse was successful
	# Randomly collapses a fielxd and updates all neighbors.
	var collapse := func(coord: Vector2i) -> bool:
		if progress.get(coord) == null:
			return false;

		(progress.get(coord) as Possibilities).collapse()

		# May or may not be full depending on neighbors

		var get_neighbors := func(coord: Vector2i) -> Array:
			var top := Vector2i(coord.x, coord.y - 1)
			var bottom := Vector2i(coord.x, coord.y + 1)
			var left := Vector2i(coord.x - 1, coord.y)
			var right := Vector2i(coord.x + 1, coord.y)

			return [top, bottom, left, right].filter(func(a: Vector2i) -> bool:
				return 0 <= a.x && a.x <= output_size.x && a.x && a.x <= output_size.x)    

		var update_neighbors := func(coord: Vector2i) -> void:
			for neighbor_coord: Vector2i in get_neighbors.call(coord):
				var neighbor: Possibilities = progress.get(neighbor_coord);
				if neighbor == null || neighbor.collapsed():
					continue;

				var neighboring_possibilities: Array = \
				(get_neighbors.call(coord) as Array[Vector2i]).map(func(a: Vector2i) -> Possibilities:
					return progress.get(a) as Possibilities;
				).filter(func(a: Variant) -> bool: return a != null)
				

				neighbor.update(neighboring_possibilities);

		update_neighbors.call(coord);
	
		return false;
	
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
		assert((progress.get(best) as Possibilities).collapsed())
		push_error(best)
		
	for i in progress:
		# TODO: Assert they are all valid
		pass
	var finished := progress.values().map(func(p: Possibilities) -> TileMapPattern: return p.variants.get(0))

	# cant .map() a dictionary :(
	var result: Dictionary[Vector2i, TileMapPattern];
	for i in progress:
		result.set(i, (progress.get(i) as Possibilities).variants.get(0));
	return result;



class Possibilities extends Node:
	var variants: Array[TileMapPattern];

	# Returns the variant. Otherwise null.
	func collapsed() -> bool:
		return variants.size() == 1 && variants.get(0) != null
		
	@warning_ignore("shadowed_variable")
	func _init(variants: Array[TileMapPattern]) -> void:
		self.variants = variants;

	func new(posss: Array[TileMapPattern]) -> Possibilities:
		return Possibilities.new(posss);

	func collapse() -> void:
		assert(variants.size() != 0)
		variants = [variants.pick_random()];

	func entropy() -> int:
		if variants.size() == 1:
			return 9223372036854775807
		return variants.size();

	func update(other: Array) -> void:
		for possibilities: Possibilities in other:
			possibilities.variants.filter(func(pattern: TileMapPattern) -> bool: return other.has(pattern))
   

var CellNeighbors: Dictionary[TileMapPattern, ArrayOfPatterns]

class ArrayOfPatterns:
	var arr: Array[TileMapPattern]

	@warning_ignore("shadowed_variable")
	func _init(arr: Array[TileMapPattern]) -> void:
		self.arr = arr;
