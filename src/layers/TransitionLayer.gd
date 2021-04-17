extends CanvasLayer
class_name TransitionLayer

onready var transition_tween: Tween = $Transition_Tween
onready var black_transition: ColorRect = $BlackTransition

func _ready():
	GameController.transition_layer = self


func make_transition_black_in():
	
	transition_black_show()
	
	var _err1 = transition_tween.interpolate_property(black_transition, 
										"self_modulate",
										Color(1, 1, 1, 0),
										Color(1, 1, 1, 1),
										0.5,
										Tween.TRANS_LINEAR, 
										Tween.EASE_IN_OUT,
										0)
	


	var _err_start = transition_tween.start()
	
	return transition_tween


func make_transition_black_out():
	
	var _err1 = transition_tween.interpolate_property(black_transition, 
										"self_modulate",
										Color(1, 1, 1, 1),
										Color(1, 1, 1, 0),
										0.5,
										Tween.TRANS_LINEAR, 
										Tween.EASE_IN_OUT,
										0)
	
	var _err_start = transition_tween.start()
	
	
	return transition_tween


func transition_black_hide():
	$BlackTransition.hide()


func transition_black_show():
	$BlackTransition.show()
