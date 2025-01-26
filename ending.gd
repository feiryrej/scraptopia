extends CanvasLayer

const CHAR_READ_RATE = 0.05

@onready var textbox_container = $IntroContainer
@onready var start_symbol = $IntroContainer/MarginContainer/HBoxContainer/Start
@onready var end_symbol = $IntroContainer/MarginContainer/HBoxContainer/End
@onready var label = $IntroContainer/MarginContainer/HBoxContainer/Label
@onready var dark_overlay = $ColorRect

var text_to_display = ""
var current_text = ""
var timer: Timer = null

enum State {
	READY,
	READING,
	FINISHED
}

var current_state = State.READY
var text_queue = []


func _ready():
	print("Starting state: State.READY")
	hide_textbox()
	queue_text("Congratulations! You have successfully sorted all the waste into the correct bins to save Mother Earth! But, your journey doesn’t end here—go forth, traveler, and inspire others to join in protecting and restoring our planet!")


func _process(delta):
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				display_text()
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				label.text = text_to_display
				current_text = text_to_display  
				if timer:
					timer.stop()
					end_symbol.text = "..." 
					change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				change_state(State.READY)
				hide_textbox()

func queue_text(next_text):
	text_queue.push_back(next_text)
	
func hide_textbox():
	start_symbol.text = ""
	end_symbol.text = ""
	label.text = ""
	textbox_container.hide()
	if text_queue.is_empty():
		dark_overlay.visible = false
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
