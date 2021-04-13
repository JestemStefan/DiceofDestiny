extends Control

onready var anims = get_node("AnimationPlayer")

var done = false # flag used to prevent multiple calls
				 # since title_screen() is called from _input()

func _ready():
	anims.play("Splash")
	yield(anims, "animation_finished")
	
	title_screen()
	
func _input(event):
	if (
		(event is InputEventMouseButton) or (event is InputEventScreenTouch)
	) and (event.pressed):
		anims.stop()
		title_screen()


func title_screen():
	if done:
		return
		
	done = true
	
	get_tree().change_scene("res://scenes/title_menu/Title.tscn")
