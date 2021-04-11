extends Area2D
class_name Dice

enum State{FREE, DRAG, USED}
var current_state: int = State.FREE

var dice_value: int = 1

var initial_position: Vector2

var interaction_box: InteractionBox = null

signal dice_used

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
			global_position = interaction_box.transform.origin


func _process(delta):
	match current_state:
		State.FREE: 
			pass
		
		State.DRAG:
			global_position = get_viewport().get_mouse_position()


func set_dice_value(value: int):
	dice_value = value
	$Dice_Sprite.frame = value - 1


func _on_Dice_input_event(viewport, event, shape_idx):
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			
			match event.button_index:
				1:
					enter_state(State.DRAG)
		
		else:
			match event.button_index:
				1:
					if interaction_box != null:
						enter_state(State.USED)
						interaction_box.use_dice(dice_value)
						
						emit_signal("dice_used")
						call_deferred("free")
						
					else:
						enter_state(State.FREE)


func _on_Dice_area_entered(area):
	
	if area is InteractionBox:
		#print(area)
		interaction_box = area


func _on_Dice_area_exited(area):
	interaction_box = null
