extends Control

@onready var main_menu = $"../"

func _ready():
	visible = false

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)

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

func _on_button_pressed() -> void:
	print("Exiting Settings")
	visible = false
