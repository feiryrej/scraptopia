extends Control

@onready var main_menu = $"../"
@onready var cancel_sound: AudioStreamPlayer2D = $CancelSound
@onready var select_sound: AudioStreamPlayer2D = $SelectSound

var music_bus = AudioServer.get_bus_index("Music")

func _ready():
	visible = false

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, value)	
	
	if value == -30:
		AudioServer.set_bus_mute(music_bus, true)
	else:
		AudioServer.set_bus_mute(music_bus, false)

func _on_mute_toggled(toggled_on: bool) -> void:
	$SelectSound.play()
	AudioServer.set_bus_mute(0,toggled_on)

func _on_resolutions_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(2880,1800))
			$SelectSound.play()
		1:
			DisplayServer.window_set_size(Vector2i(1920,1080))
			$SelectSound.play()
		2:
			DisplayServer.window_set_size(Vector2i(1600,900))
			$SelectSound.play()
		3:
			DisplayServer.window_set_size(Vector2i(1280,720))
			$SelectSound.play()


func _on_close_btn_pressed() -> void:
	$CancelSound.play()
	print("Exiting Settings")
	visible = false
