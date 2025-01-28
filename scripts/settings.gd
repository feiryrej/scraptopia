extends Control

@onready var main_menu = $"../"
var master_bus = AudioServer.get_bus_index("Master")

func _ready():
	visible = false

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, value)	
	
	if value == -30:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)

func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0,toggled_on)

func _on_resolutions_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(2880,1800))
		1:
			DisplayServer.window_set_size(Vector2i(1920,1080))
		2:
			DisplayServer.window_set_size(Vector2i(1600,900))
		3:
			DisplayServer.window_set_size(Vector2i(1280,720))


func _on_close_btn_pressed() -> void:
	print("Exiting Settings")
	visible = false
