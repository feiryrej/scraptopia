extends Control

# variables
@onready var settings = load("res://scenes/settings_panel.tscn")

@onready var settings_instance = settings.instantiate()

func _ready():
	add_child(settings_instance)
	visible = false
	$AnimationPlayer.play("RESET")

func resume():
	get_tree().paused = false
	visible = false
	print("IT DEBLURS")
	$AnimationPlayer.play("RESET")

func pause():
	settings_instance.visible = false
	get_tree().paused = true
	visible = true
	$AnimationPlayer.stop() 
	$AnimationPlayer.play("blur")
	
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
