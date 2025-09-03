extends Sprite2D

const LightTexture = preload("res://Assets/Light.png")
const GRID_SIZE = 16

@onready var player: Node2D = %Player

var display_width:int = ProjectSettings.get("display/window/size/viewport_width")
var display_height:int = ProjectSettings.get("display/window/size/viewport_height")

var fogImage:Image = Image.new()
var fogTexture:ImageTexture = ImageTexture.new()
var lightImage:Image = LightTexture.get_image()
var light_offset:Vector2 = Vector2(LightTexture.get_width()/2,LightTexture.get_height()/2)

func _ready() -> void:
	var fog_image_width:int = display_width/GRID_SIZE
	var fog_Image_height:int = display_height/GRID_SIZE
	fogImage = Image.create(fog_image_width, fog_Image_height, false, Image.FORMAT_RGBAH)
	fogImage.fill(Color.BLACK)
	lightImage.convert(Image.FORMAT_RGBAH)
	scale *= GRID_SIZE
	update_fog((player as Node2D).position / GRID_SIZE)

func update_fog(new_grid_position:Vector2) -> void:
	
	var light_rect:Rect2 = Rect2(Vector2.ZERO, Vector2(lightImage.get_width(), lightImage.get_height()))
	fogImage.blend_rect(lightImage, light_rect, new_grid_position - light_offset)
	
	update_fog_image_texture()

func update_fog_image_texture() -> void:
	fogTexture = ImageTexture.create_from_image(fogImage)
	texture = fogTexture

func _input(event:InputEvent) -> void:
	update_fog((player as Node2D).position/GRID_SIZE)
