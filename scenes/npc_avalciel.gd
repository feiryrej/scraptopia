extends CharacterBody2D

@export var dialogue : Dialogue

const speed = 30
var current_state = SIDE_LEFT

var dir = Vector2.RIGHT
var start_pos

var is_roaming = true
var is_chatting = false

var player
var player_in_dialogue_zone = false

var last_direction = "s"

enum {
	IDLE,
	NEW_DIR,
	MOVE
}

func _ready():
	randomize()
	start_pos = position


func _process(delta):
	if current_state == 0 or current_state == 1:
		$human_spr.play(last_direction + "-idle")
	elif current_state == 2 and !is_chatting:
		if dir.x == -1:
			$human_spr.play("w-walk")
			last_direction = "w"
		elif dir.x == 1:
			$human_spr.play("e-walk")
			last_direction = "e"
		elif dir.y == -1:
			$human_spr.play("n-walk")
			last_direction = "n"
		elif dir.y == 1:
			$human_spr.play("s-walk")
			last_direction = "s"

	# Commenting out the roaming logic for now
	# if is_roaming:
	# 	match current_state:
	# 		IDLE:
	# 			pass
	# 		NEW_DIR:
	# 			dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])
	# 		MOVE:
	# 			move(delta)

	if Input.is_action_just_pressed("interact"):
		is_roaming = false
		is_chatting = true
		$human_spr.play("s-idle")

func choose(array):
	array.shuffle()
	return array.front()

# Commenting out the movement logic for now
# func move(delta):
# 	if !is_chatting:
# 		position += dir * speed * delta


func interact():
	DialogueManager.dialogue = dialogue
	DialogueManager.show_dialogue()


func _on_dialogue_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		player_in_dialogue_zone = true
		is_roaming = false


func _on_dialogue_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_dialogue_zone = false
		is_roaming = true


# Commenting out the timer-based state changes for now
# func _on_timer_timeout() -> void:
# 	$Timer.wait_time = choose([0.5, 1, 1.5])
# 	current_state = choose([IDLE, NEW_DIR, MOVE])


func _on_interaction_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
