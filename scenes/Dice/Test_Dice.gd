extends Area2D
class_name Dice

enum State{FREE, DRAG, USED}
var current_state: int = State.FREE
var initial_position: Vector2

var interaction_box: Area2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_position = get_global_transform().origin

func enter_state(new_state: int):
	current_state = new_state
	
	match current_state:
		State.FREE:
			transform.origin = initial_position
		
		State.DRAG:
			pass
		
		State.USED:
			transform.origin = interaction_box.transform.origin

func _process(delta):
	match current_state:
		State.FREE: 
			pass
		
		State.DRAG:
			transform.origin = get_viewport().get_mouse_position()
			


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
						
					else:
						enter_state(State.FREE)


func _on_Dice_area_entered(area):
	if area is InteractionBox:
		interaction_box = area


func _on_Dice_area_exited(area):
	interaction_box = null
