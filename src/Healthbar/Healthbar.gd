extends Node2D

onready var start_hp_tile_texture: StreamTexture = preload("res://art/UI/UI_HP_Left.png")
onready var hp_tile_texture: StreamTexture = preload("res://art/UI/UI_HP_Middle.png")
onready var end_hp_tile_texture: StreamTexture = preload("res://art/UI/UI_HP_Right.png")

var defualt_size: float = 30
var tile_scale: float = 1
var tile_step: float = 2

var max_hp: float = 16

export var reverse_fill: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_hp_bar(defualt_size)
	update_healthbar(defualt_size)


func setup_hp_bar(hp_max: float):
	
	tile_scale = defualt_size/hp_max
	if reverse_fill:
		tile_step = -2
		$HP_Number.rect_position.x = -4
	else:
		tile_step = 2
		$HP_Number.rect_position.x = -18
	


func update_healthbar(new_hp: float):
	#delete old healthbar
	var old_healthbar = get_children()
	if len(old_healthbar) > 0:
		for tile in old_healthbar:
			if tile is Sprite:
				tile.call_deferred("free")
			
	
	$HP_Number.text = str(new_hp)
	
	if new_hp <= 0:
		pass
	
	
	elif new_hp == 1:
		#Add initial tile
		var pos_x: float = 0
		
		add_start_tile(pos_x)
		pos_x += tile_step * tile_scale
	
	
	elif new_hp == 2:
		#Add initial tile
		var pos_x: float = 0
		
		add_start_tile(pos_x)
		pos_x += tile_step * tile_scale
		
		# add end tile
		add_end_tile(pos_x)
	
	
	elif new_hp > 2:
		#Add initial tile
		var pos_x: float = 0
		
		add_start_tile(pos_x)
		pos_x += tile_step * tile_scale
		
		# fill the middle
		for _sprite in range(new_hp - 2):
			add_fill_tile(pos_x)
			pos_x += tile_step * tile_scale
		
		# add end tile
		add_end_tile(pos_x)


func add_start_tile(pos: float):
	var start_tile = Sprite.new()
	add_child(start_tile)
	
	if reverse_fill:
		start_tile.texture = end_hp_tile_texture
	else:
		start_tile.texture = start_hp_tile_texture
		
	start_tile.position.x = pos
	start_tile.scale.x = tile_scale


func add_fill_tile(pos: float):
	var hp_fill_tile = Sprite.new()
	add_child(hp_fill_tile)
	hp_fill_tile.texture = hp_tile_texture
	hp_fill_tile.position.x = pos
	hp_fill_tile.scale.x = tile_scale


func add_end_tile(pos: float):
	var end_tile = Sprite.new()
	add_child(end_tile)
	
	if reverse_fill:
		end_tile.texture = start_hp_tile_texture
	else:
		end_tile.texture = end_hp_tile_texture
		
	end_tile.position.x = pos
	end_tile.scale.x = tile_scale
