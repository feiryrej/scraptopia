extends Control

# variables
@onready var settings = load("res://scenes/settings_panel.tscn")
@onready var almanac = load("res://scenes/almanac.tscn")
@onready var settings_instance = settings.instantiate()
@onready var almanac_instance = almanac.instantiate()

@onready var escape_sound: AudioStreamPlayer2D = $EscSound
@onready var cancel_sound: AudioStreamPlayer2D = $CancelSound
@onready var select_sound: AudioStreamPlayer2D = $SelectSound

func _ready():
	add_child(settings_instance)
	add_child(almanac_instance)
	visible = false
	$Blur.play("RESET")

func resume():
	get_tree().paused = false
	visible = false
	almanac_instance.visible = false
	$Blur.play("RESET")

func pause():
	settings_instance.visible = false
	almanac_instance.visible = false
	get_tree().paused = true
	visible = true
	$Blur.stop() 
	$Blur.play("blur")
	
func _input(event):
	if event.is_action_pressed("escape"):
		if get_tree().paused:
			$CancelSound.play()
			resume()
		else:
			$EscSound.play()
			pause()
			

func _on_resume_pressed():
	$SelectSound.play()
	resume()
	
func _on_restart_pressed():
	get_tree().paused = false
	Global.total_waste = Global.all_waste
	visible = false
	await get_tree().process_frame
	get_tree().reload_current_scene()
	$SelectSound.play()

func _on_quit_pressed():
	get_tree().quit()

func _on_settings_pressed() -> void:
	$SelectSound.play()
	settings_instance.visible = true
	print("settings pressed")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		almanac_instance.visible = false


func _on_settings_btn_pressed() -> void:
	if get_tree().paused:
		resume()
	else:
		$EscSound.play()
		pause()
			
