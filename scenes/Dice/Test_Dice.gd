extends Area2D
class_name Dice

enum State{FREE, DRAG, USED}
var current_state: int = State.FREE

var dice_value: int = 1

var initial_position: Vector2
var last_position: Vector2

var interaction_box: ActionBox = null

onready var tween_size: Tween = $Tween_Size

signal dice_picked_up
signal dice_dropped

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func enter_state(new_state: int):
	current_state = new_state
	
	match current_state:
		State.FREE:
			global_position = initial_position
		
		State.DRAG:
			pass
		
		State.USED:
			global_position = last_position


func _process(_delta):
	match current_state:
		State.FREE: 
			pass
		
		State.DRAG:
			global_position = get_viewport().get_mouse_position()


func set_dice_value(value: int):
	dice_value = value
	$Dice_Sprite.frame = value - 1


func _on_Dice_input_event(_viewport, event, _shape_idx):
	
	if event is InputEventMouseButton and GameController.current_encounter.current_turn == GameController.current_encounter.Turn.PLAYER:
		if event.is_pressed():
			
			match event.button_index:
				1:
					enter_state(State.DRAG)
					emit_signal("dice_picked_up", self)
		
		else:
			match event.button_index:
				1:
					emit_signal("dice_dropped", self)


func _on_Dice_area_entered(_area):
	pass
	#if area is ActionBox:
	#	interaction_box = area


func _on_Dice_area_exited(_area):
	pass
	#if area == interaction_box:
		#interaction_box = null


func _on_Dice_mouse_entered():
	var _tween_err = tween_size.interpolate_property(self, "scale", Vector2.ONE, Vector2(1.2, 1.2), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	var _tween_start = tween_size.start()


func _on_Dice_mouse_exited():
	var _tween_err = tween_size.interpolate_property(self, "scale", null, Vector2.ONE, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	var _tween_start = tween_size.start()
