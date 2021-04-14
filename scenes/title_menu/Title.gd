extends Control

var is_during_animation = false

onready var fade_anims = get_node("FadeRect/AnimationPlayer")
onready var transition_anims = get_node("AnimationPlayer")

onready var buttons_mainmenu = get_node("MainMenu/VBox").get_children()
onready var buttons_options = [
	get_node("Options/BtnBack")
]

func _ready():
	# Make sure we start with the screen faded out
	fade_anims.play("FadeOut", -1, 1.0, true) # Move animation to end
	fade_anims.advance(0)                     # force update
	transition_anims.play("MainMenu_Out", -1, 1.0, true)
	transition_anims.play("Options_Out", -1, 1.0, true)

	yield(get_tree().create_timer(0.3), "timeout")
	
	# Fade screen in
	fade_anims.play("FadeIn")
	yield(fade_anims, "animation_finished")
	transition_anims.play("MainMenu_In")
	yield(transition_anims, "animation_finished")
	yield(fade_in_all(buttons_mainmenu), "completed")
	
	
# Fades buttons out, selected one as last
func fade_out_selected(button_list, selected_button):
	# Fades out all non-selected buttons
	# If size() == 1, we only have the selected_button
	if button_list.size() > 1:
		for obj in button_list:
			if obj != selected_button:
				obj.fade_out()
		
		# Dephase the selected by 0.3s
		yield(get_tree().create_timer(0.3), "timeout")
	
	# Fade out selected button
	yield(selected_button.fade_out(true), "completed") # use_yield=true waits for animation

# Fades buttons in, sequentially
func fade_in_all(button_list):
	for obj in button_list:
		yield(obj.fade_in(true), "completed")

# ==============================================================================
# MAIN MENU

func _on_BtnStartGame_clicked(button_object):
	if not is_during_animation:
		is_during_animation = true
		yield(fade_out_selected(buttons_mainmenu, button_object), "completed")
		fade_anims.play("FadeOut")
		yield(fade_anims, "animation_finished")
		
		is_during_animation = false
		get_tree().change_scene("res://scenes/Testing/GameWorld.tscn")


func _on_BtnOptions_clicked(button_object):
	if not is_during_animation:
		is_during_animation = true

		yield(fade_out_selected(buttons_mainmenu, button_object), "completed")
		transition_anims.play("MainMenu_Out")
		yield(transition_anims, "animation_finished")
		
		transition_anims.play("Options_In")
		yield(transition_anims, "animation_finished")
		yield(fade_in_all(buttons_options), "completed")
		
		is_during_animation = false


func _on_BtnCredits_clicked(button_object):
	if not is_during_animation:
		pass # Replace with function body.

# ==============================================================================
# OPTIONS

func _on_Options_BtnBack_clicked(button_object):
	if not is_during_animation:
		is_during_animation = true

		yield(fade_out_selected(buttons_options, button_object), "completed")
		transition_anims.play("Options_Out")
		yield(transition_anims, "animation_finished")
		
		transition_anims.play("MainMenu_In")
		yield(transition_anims, "animation_finished")
		yield(fade_in_all(buttons_mainmenu), "completed")
		
		is_during_animation = false
