extends Control

@onready var recyclable_popup = $Recyclable_NinePatchRect
@onready var hazardous_popup = $Hazardous_NinePatchRect
@onready var bio_popup = $Biodegradable_NinePatchRect
@onready var nonbio_popup = $Nonbiodegradable_NinePatchRect

# Called when the node enters the scene tree for the first time.
func _ready():
	# Ensure all panels are hidden at the start
	hide()
	hide_panels()
	
func hide_panels():
	recyclable_popup.hide()
	hazardous_popup.hide()
	bio_popup.hide()
	nonbio_popup.hide()
	
func toggle_almanac():
	if visible:
		hide()  # Hide the almanac
		$AnimationPlayer.play("RESET")
	else:
		show()  # Show the almanac
		$AnimationPlayer.play("blur")

func _input(event):
	if event.is_action_pressed("almanac"):
		toggle_almanac()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	visible = false

func _on_button_2_pressed() -> void:
	bio_popup.show()
	
func _on_button_3_pressed() -> void:
	hazardous_popup.show()
	
func _on_button_4_pressed() -> void:
	nonbio_popup.show()

func _on_button_5_pressed() -> void:
	recyclable_popup.show()


func _on_recyclable_exit_pressed() -> void:
	recyclable_popup.hide()
	
func _on_hazardous_exit_pressed() -> void:
	hazardous_popup.hide()

func _on_biodegradable_exit_pressed() -> void:
	bio_popup.hide()

func _on_nonbiodegradable_exit_pressed() -> void:
	nonbio_popup.hide()
