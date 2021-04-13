extends ReferenceRect

signal clicked(object)

onready var anims = get_node("AnimationPlayer")

func _ready():
	# Starts faded out
	anims.play("FadeOut", -1, 1.0, true)
	anims.advance(0)

func _on_TextureButton_gui_input(event):
	if (
		(event is InputEventMouseButton) or (event is InputEventScreenTouch)
	) and (event.pressed):
		
		emit_signal("clicked", self)
		
func fade_in(use_yield = false):
	anims.play("FadeIn")

	if use_yield:
		yield(anims, "animation_finished")
	
func fade_out(use_yield = false):
	anims.play("FadeOut")

	if use_yield:
		yield(anims, "animation_finished")
