extends Control

# variables
@onready var settings = load("res://scenes/settings_panel.tscn")
@onready var almanac = load("res://scenes/almanac.tscn")
@onready var settings_instance = settings.instantiate()
@onready var almanac_instance = almanac.instantiate()

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
			resume()
		else:
			pause()
			

func _on_resume_pressed():
	resume()
	
func _on_restart_pressed():
	get_tree().paused = false
	visible = false
	await get_tree().process_frame
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()

func _on_settings_pressed() -> void:
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
		pause()
			
