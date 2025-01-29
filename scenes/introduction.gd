extends CanvasLayer

const CHAR_READ_RATE = 0.05

@onready var textbox_container = $IntroContainer
@onready var start_symbol = $IntroContainer/MarginContainer/HBoxContainer/Start
@onready var end_symbol = $IntroContainer/MarginContainer/HBoxContainer/End
@onready var label = $IntroContainer/MarginContainer/HBoxContainer/Label
@onready var dark_overlay = $ColorRect
@onready var enter_label = $Label2
@onready var beeping = $AudioStreamPlayer2D

var text_to_display = ""
var current_text = ""
var timer: Timer = null
var visibility_timer : Timer = null

enum State {
	READY,
	READING,
	FINISHED
}

var current_state = State.READY
var text_queue = []
var max_text = 4
var curr_text = 0


func _ready():
	print("Starting state: State.READY")
	enter_label.visible = false
	beeping.stream_paused = false
	print("Enter label exists: ", enter_label != null)
	hide_textbox()
	hide_enter_label()
	queue_text("Greetings, traveler! This world was once a haven of clarity, purity, and orderliness. It was full of life and diversity as Mother Earth can support the life of every organism. With the crystal-clear water, fresh air, and lush lands, this place was a paradise.")
	queue_text("But… humans neglected Mother Earth, and she became lost and in demise. The paradise is now polluted with different kinds of waste. The once haven of cleanliness becomes a mess due to irresponsibility and disorderliness. However… ")
	queue_text("The five guardians of this world unite to save Mother Earth! Ignis, Tsuchiruz, Ixiol, Luxanna, and Avalciel gather to restore the world, but they need support. You, traveler, explore the world and be part of its restoration, bring it back to its original beauty, and discover the mystery behind wastes. ")


func _process(delta):
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				display_text()
				beeping.stream_paused = false
				_on_label_2_visibility_changed()
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				beeping.stream_paused = true
				label.text = text_to_display
				current_text = text_to_display  
				if timer:
					timer.stop()
					end_symbol.text = "..." 
					change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				change_state(State.READY)
				beeping.stream_paused = true
				hide_textbox()
				hide_enter_label()


func queue_text(next_text):
	text_queue.push_back(next_text)
	
func hide_textbox():
	start_symbol.text = ""
	end_symbol.text = ""
	label.text = ""
	textbox_container.hide()
	if text_queue.is_empty():
		dark_overlay.visible = false
		enter_label.visible = false
#	get_tree().paused = false
	
func show_textbox():
	if !textbox_container.visible:
		textbox_container.show()
		dark_overlay.visible = true
#	start_symbol.text = ""
#	textbox_container.show()
#	dark_overlay.visible = true
#	get_tree().paused = true

func display_text():
	var next_text = text_queue.pop_front()
	text_to_display = next_text
	current_text = ""
	show_textbox() 
	change_state(State.READING)
	if timer:
		timer.stop() 
	timer = Timer.new()
	add_child(timer)  # Add the timer to the scene
	timer.wait_time = CHAR_READ_RATE  # Time between each character reveal
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.start()

func _on_timer_timeout() -> void:
	if current_text.length() < text_to_display.length():
		current_text += text_to_display[current_text.length()]
		label.text = current_text
#		print("Displaying text: ", current_text)
	else:
		end_symbol.text = "..."
		change_state(State.FINISHED)
		timer.stop()  # Stop the timer when all text is revealed.

func change_state(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			print("Changing the state to state: State.READY")
		State.READING:
			print("Changing the state to state: State.READING")
		State.FINISHED:
			print("Changing the state to state: State.FINISHED")
			


func _on_label_2_visibility_changed() -> void:
	if not enter_label:
		print("Error: enter_label is null")
		return
	
	if !text_queue.is_empty():
		if visibility_timer == null:
			var visibility_timer = Timer.new()
			visibility_timer.wait_time = 1.0
			visibility_timer.one_shot = true
			add_child(visibility_timer)
		
			visibility_timer.connect("timeout", Callable(self, "_show_enter_label"))
			visibility_timer.start()
		
			print("Timer started!")
	else:
		if visibility_timer != null:
			print("Stop")
			visibility_timer.stop()
			visibility_timer = null
			


func _show_enter_label() -> void:
	if not enter_label:
		print("Error: enter label is null. show enter label")
		return
	
	enter_label.visible = true
	enter_label.z_index = 100 
	print("Enter label visibility before: ", enter_label.visible)
	print("Enter label is now visible")
	var parent = enter_label.get_parent()
	print("Parent visibility: ", parent.visible)

func hide_enter_label():
	if enter_label:
		enter_label.visible = false
		enter_label.z_index = 100 
		print("Enter label is now hidden")
	curr_text += 1
	print("curr_text: ", curr_text)
	if curr_text == max_text:
		get_tree().change_scene_to_file("res://scenes/virethariel.tscn")
	else:
		pass
	
