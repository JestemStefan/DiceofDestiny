extends ReferenceRect

export(String) var BusName = ""
onready var bus_index = AudioServer.get_bus_index(BusName)

onready var volume_bar = get_node("ProgressBar")

# target value is used for graphical lerping
var target_value = 0.0

func _ready():
	var value_db = AudioServer.get_bus_volume_db(bus_index)
	set_value(db2linear(value_db))

func _process(delta):
	if abs(target_value - volume_bar.value) < 0.01:
		volume_bar.value = target_value
	else:
		volume_bar.value = lerp(float(volume_bar.value), target_value, 10.0*delta)

func _on_ProgressBar_gui_input(event):
	if (
		(event is InputEventMouseButton) or (event is InputEventScreenTouch)
	) and (event.pressed):
		
		var value_normalized = event.position.x / volume_bar.rect_size.x
		
		set_value(value_normalized)
		
		
func set_value(value_normalized):
		
		# If value  is close to the edges, round it
		if value_normalized < 0.05:
			value_normalized = 0.0
		if value_normalized > 0.95:
			value_normalized = 1.0
		
		# Update UI
		target_value = value_normalized * 100.0
		
		# Update audio bus
		if value_normalized == 0:
			AudioServer.set_bus_mute(bus_index, true)
		else:
			AudioServer.set_bus_mute(bus_index, false)
			var value_db = linear2db(value_normalized)
			AudioServer.set_bus_volume_db(bus_index, value_db)
