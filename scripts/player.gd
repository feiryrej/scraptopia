extends CharacterBody2D

# References
@onready var item_drop = load("res://scenes/item_drop.tscn")
@onready var menu = load("res://scenes/menu.tscn")
@onready var human_spr = $human_spr
@onready var item_spr = $item_spr
@onready var correct_spr = $correct_spr
@onready var wrong_spr = $wrong_spr

@onready var sense: AnimatedSprite2D = $"%Sense"
@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound
@onready var drop_sound: AudioStreamPlayer2D = $DropSound
@onready var correct_sound: AudioStreamPlayer2D = $CorrectSound
@onready var wrong_sound: AudioStreamPlayer2D = $WrongSound
@onready var trash_sound: AudioStreamPlayer2D = $TrashSound
@onready var footstep_sound: AudioStreamPlayer2D = $FootstepSound

# Variables
var speed = 100
var movement_velocity = Vector2.ZERO
var dir = Vector2.DOWN
var tile_size = 16
var movement_speed = 120
var is_moving = false
var movement_queue = Vector2.ZERO

var ending_triggered = false
var carrying_item = false
var drop_pos: Vector2
var items_in_range: Array = []
var bins_in_range = []

var small_scale = Vector2(0.62, 0.62)
var curr_waste_type = null

var male_arms_down_frames = preload("res://frames/male_arms_down.tres")
var male_arms_up_frames = preload("res://frames/male_arms_up.tres")
var female_arms_down_frames = preload("res://frames/female_arms_down.tres")
var female_arms_up_frames = preload("res://frames/female_arms_up.tres")

enum Gender { MALE, FEMALE }
var curr_gender = Gender.MALE

enum States { IDLE, MOVE }
var current_state = States.IDLE


func _ready():
	item_spr.hide()
	update_spritesheet()
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(Callable(self, "_on_timer_timeout"))
	
	
	# wastes list     |     position   |      frame      |     scale
	spawn_item(Vector2(984, 615), Vector2i(0, 7), Vector2(0.62, 0.62), "BIO")          # banana
	spawn_item(Vector2(983, 455), Vector2i(2, 0), Vector2(0.62, 0.62), "BIO")          # pencil
	spawn_item(Vector2(1159, 391), Vector2i(9, 0), Vector2(0.62, 0.62), "BIO")         # withered planks
	spawn_item(Vector2(999, -73), Vector2i(10, 4), Vector2(0.62, 0.62), "BIO")         # ship wood
	spawn_item(Vector2(681, 25), Vector2i(11, 4), Vector2(0.62, 0.62), "BIO")          # watermelon
	spawn_item(Vector2(537, -8), Vector2i(10, 5), Vector2(0.62, 0.62), "BIO")          # wilted feather
	spawn_item(Vector2(407, -70), Vector2i(9, 5), Vector2(0.62, 0.62), "BIO")          # withered rose garlands
	spawn_item(Vector2(761, -199), Vector2i(2, 6), Vector2(0.62, 0.62), "BIO")         # broken clay pots
	spawn_item(Vector2(440, 504), Vector2i(8, 1), Vector2(0.62, 0.62), "BIO")          # dead maple leaf
	spawn_item(Vector2(360, 602), Vector2i(1, 1), Vector2(0.62, 0.62), "BIO")          # rotten fruits
	spawn_item(Vector2(-71, 313), Vector2i(11, 2), Vector2(1, 1), "BIO")               # rope
	spawn_item(Vector2(69, -104), Vector2i(7, 1), Vector2(0.62, 0.62), "BIO")          # leather
	spawn_item(Vector2(74, -281), Vector2i(0, 1), Vector2(0.62, 0.62), "BIO")          # animal bone
	spawn_item(Vector2(-74, -311), Vector2i(9, 1), Vector2(0.8, 0.8), "BIO")           # log
	spawn_item(Vector2(967, -330), Vector2i(6, 6), Vector2(0.62, 0.62), "BIO")         # palm leaf fan

	spawn_item(Vector2(807, 652), Vector2i(7, 4), Vector2(0.62, 0.62), "NONBIO")       # plastic bag
	spawn_item(Vector2(1062, 358), Vector2i(8, 4), Vector2(0.62, 0.62), "NONBIO")      # rusty nail
	spawn_item(Vector2(614, -74), Vector2i(0, 5), Vector2(0.62, 0.62), "NONBIO")       # broken pocket watch
	spawn_item(Vector2(456, -184), Vector2i(7, 5), Vector2(0.62, 0.62), "NONBIO")      # broken brass gears
	spawn_item(Vector2(502, 118), Vector2i(5, 5), Vector2(0.62, 0.62), "NONBIO")       # worn leather straps
	spawn_item(Vector2(1080, -184), Vector2i(3, 6), Vector2(0.62, 0.62), "NONBIO")     # obsidian shards
	spawn_item(Vector2(1320, -281), Vector2i(4, 6), Vector2(0.62, 0.62), "NONBIO")     # shattered temple tile
	spawn_item(Vector2(39, 232), Vector2i(0, 2), Vector2(0.62, 0.62), "NONBIO")        # boots
	spawn_item(Vector2(-74, 58), Vector2i(12, 2), Vector2(0.4, 0.4), "NONBIO")         # gloves
	spawn_item(Vector2(-25, 138), Vector2i(2, 2), Vector2(1, 1), "NONBIO")             # satellite
	
	spawn_item(Vector2(1032, 151), Vector2i(1, 5), Vector2(1, 1), "RECYCLABLE")        # silk parasols
	spawn_item(Vector2(1128, 72), Vector2i(3, 0), Vector2(0.62, 0.62), "RECYCLABLE")   # glass shards
	spawn_item(Vector2(855, 56), Vector2i(4, 0), Vector2(0.62, 0.62), "RECYCLABLE")    # stainless steel
	spawn_item(Vector2(1161, -266), Vector2i(7, 6), Vector2(0.62, 0.62), "RECYCLABLE") # ritual mask fragment
	spawn_item(Vector2(423, 294), Vector2i(8, 3), Vector2(0.62, 0.62), "RECYCLABLE")   # pizza box
	spawn_item(Vector2(281, 425), Vector2i(6, 3), Vector2(0.62, 0.62), "RECYCLABLE")   # metal can
	spawn_item(Vector2(183, 552), Vector2i(12, 4), Vector2(0.62, 0.62), "RECYCLABLE")  # map
	spawn_item(Vector2(-69, 646), Vector2i(4, 0), Vector2(0.62, 0.62), "RECYCLABLE")   # broken bottle
	spawn_item(Vector2(-42, 521), Vector2i(4, 4), Vector2(0.62, 0.62), "RECYCLABLE")   # plastic bottle
	spawn_item(Vector2(99, 119), Vector2i(7, 2), Vector2(0.62, 0.62), "RECYCLABLE")    # copper
	spawn_item(Vector2(-88, -197), Vector2i(9, 2), Vector2(0.62, 0.62), "RECYCLABLE")  # glass flask
	
	spawn_item(Vector2(1065, 775), Vector2i(1, 7), Vector2(0.62, 0.62), "HAZARD")      # facemask
	spawn_item(Vector2(1079, 280), Vector2i(1, 0), Vector2(1, 1), "HAZARD")            # mechanical component
	spawn_item(Vector2(1111, 183), Vector2i(1, 2), Vector2(0.62, 0.62), "HAZARD")      # battery
	spawn_item(Vector2(1160, 169), Vector2i(6, 0), Vector2(1, 1), "HAZARD")            # uranium fuel rod
	spawn_item(Vector2(887, -246), Vector2i(0, 6), Vector2(0.62, 0.62), "HAZARD")      # ritual oil jar
	spawn_item(Vector2(72, 652), Vector2i(3, 4), Vector2(1, 1), "HAZARD")              # black barrel
	spawn_item(Vector2(-138, 408), Vector2i(4, 2), Vector2(0.62, 0.62), "HAZARD")      # syringe

# for spawning wastes
func spawn_item(position: Vector2, frame_coords: Vector2i, scale_factor: Vector2, waste_type):
	var new_item = item_drop.instantiate()
	print("Instantiating item_drop at position: ", position)

	new_item.position = position
	new_item.frame_coords = frame_coords
	new_item.scale = scale_factor
	new_item.waste_type = waste_type
	
	new_item.set_meta("original_scale", scale_factor)
	new_item.set_meta("waste_type", waste_type)

	var item_sprite = new_item.get_node("Sprite2D")
	if item_sprite:
		item_sprite.scale = small_scale
		item_sprite.z_index = 0
	get_parent().get_node("waste_spawner").add_child(new_item)

	print("Item added to parent at position: ", new_item.position)

	
func _physics_process(delta):
	handle_state_transitions()
	perform_state_actions(delta)
	move_and_slide()
	
	 
func handle_state_transitions():
	if Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down"):
		current_state = States.MOVE
		is_moving = true
	else:
		current_state = States.IDLE
		is_moving = false



func perform_state_actions(delta):
		match current_state:
			States.MOVE:
				if $FootstepTimer.time_left <=0:
					$FootstepSound.pitch_scale = randf_range(0.8, 1.2)
					$FootstepSound.play()
					$FootstepTimer.start(0.25)
				var horizontal_input = Input.get_axis("left", "right")
				var vertical_input = Input.get_axis("up", "down")
				
				dir = Vector2(horizontal_input, vertical_input).normalized()
				velocity = dir * speed
				
				if dir.x < 0:
					human_spr.play("w-walk")
					item_spr.flip_h = true
					item_spr.position.x = 8
				elif dir.x > 0:
					human_spr.play("e-walk")
					item_spr.flip_h = false
					item_spr.position.x = 8
				elif dir.y > 0:
					human_spr.play("s-walk")
				elif dir.y < 0:
					human_spr.play("n-walk")
			States.IDLE:
				velocity = Vector2.ZERO

				if dir.y > 0:
					human_spr.play("s-idle")
				elif dir.y < 0:
					human_spr.play("n-idle")
				elif dir.x > 0:
					human_spr.play("e-idle")
				elif dir.x < 0:
					human_spr.play("w-idle")

func update_spritesheet():
	if curr_gender == Gender.MALE:
		if carrying_item == true:
			human_spr.frames = male_arms_up_frames
		else:
			human_spr.frames = male_arms_down_frames
	if curr_gender == Gender.FEMALE:
		if carrying_item == true:
			human_spr.frames = female_arms_up_frames
		else:
			human_spr.frames = female_arms_down_frames



func _on_switch_gender_pressed():
	if curr_gender == Gender.MALE:
		curr_gender = Gender.FEMALE
		print(curr_gender)
	else:
		curr_gender = Gender.MALE
		print(curr_gender)
	update_spritesheet()



func _input(event):
	if event.is_action_pressed("pickupthrow"):
		if carrying_item:
			
			# checks if player is within the bin's range
			if Global.is_near_bin and Global.near_bin_type != null: 
				dispose_item(Global.near_bin_type, Global.near_bin_node)
			else:
				drop_item()
		else:
			if !items_in_range.is_empty():
				for item in items_in_range:
					if is_facing_item(item):
						pickup_item(item)
						break



func is_facing_item(item: Area2D) -> bool:

	var item_dir = (item.global_position - global_position).normalized()
	
	if dir == Vector2.RIGHT and item_dir.dot(Vector2.RIGHT) > 0.6:
		return true
	elif dir == Vector2.LEFT and item_dir.dot(Vector2.LEFT) > 0.6:
		return true
	elif dir == Vector2.UP and item_dir.dot(Vector2.UP) > 0.6:
		return true
	elif dir == Vector2.DOWN and item_dir.dot(Vector2.DOWN) > 0.6:
		return true
	
	return false



func adjust_item_z_index(item_sprite: Sprite2D, is_picking_up: bool):
	if item_sprite:
		item_sprite.z_index = -2
		human_spr.z_index = 0 if is_picking_up else 1
	else:
		print("Item sprite not found")



func pickup_item(item: Area2D):
	var original_scale = item.get_meta("original_scale") if item.has_meta("original_scale") else Vector2(0.62, 0.62)
	
	# Force the waste type to be an integer
	curr_waste_type = item.get_meta("waste_type")
	print("Picked up a " + str(curr_waste_type) + " waste.")  # Now printing it as an integer
	
	item.queue_free()
	carrying_item = true
	print("Carrying item: ", carrying_item)
	update_spritesheet()
	pickup_sound.play()

	item_spr.show()
	var item_sprite = item.get_node("Sprite2D")
	if item_sprite:
		item_spr.texture = item_sprite.texture
		item_spr.frame_coords = item_sprite.frame_coords
		
		item_spr.set_meta("original_scale", original_scale)
		print("Item texture and frame updated.")
	else:
		print("Error: Sprite2D not found in item.")

	# writes frame_coords and scale to item_spr metadata
	item_spr.set_meta("frame_coords", item_sprite.frame_coords)
	item_spr.set_meta("initial_scale", item_sprite.scale)




func drop_item():
	item_spr.hide()
	var item = item_drop.instantiate()

	var adjusted_position = global_position - get_parent().position
	var player_tile_position = adjusted_position / tile_size
	var drop_tile_position = player_tile_position.floor() + dir
	var original_drop_position = (player_tile_position + dir) * tile_size + Vector2(tile_size / 2, tile_size / 2)
	item.position = original_drop_position


	if item_spr.has_meta("frame_coords"):
		item.frame_coords = item_spr.get_meta("frame_coords")
	else:
		print("No frame_coords metadata found") # for debugging purposes

	if item_spr.has_meta("original_scale"):
		item.scale = item_spr.get_meta("original_scale")
	else:
		print("No initial_scale metadata found.") # for debugging purposes
		item.scale = Vector2(0.62, 0.62)

	item.set_meta("waste_type", curr_waste_type)
	
	#get_parent().add_child(item)
	get_parent().get_node("waste_spawner").add_child(item)
	item.visible = true

	var item_sprite = item.get_node("Sprite2D")
	item_sprite.z_index = 0

	carrying_item = false
	update_spritesheet()
	drop_sound.play()



func dispose_item(bin_type: String, bin: Node2D):
	if carrying_item:
		if bin_type == curr_waste_type:
			carrying_item = false
			item_spr.hide()
			update_spritesheet()
			
			get_parent().get_node("Tutorial2").hide()
			
			wrong_spr.hide()
			correct_spr.show()
			correct_spr.play("correct")
			correct_sound.play()
			
			Global.total_waste -= 1
			
			if Global.lives == 5:
				Global.lives = 5
			else:
				Global.lives += 1
				
			var interface = $"../lives"
			interface.update_lives()
			trash_sound.play()
			
			bin.play_boink_animation()
			print("Correctly placed item in bin: ", bin_type)
			
			if correct_spr.visible:				
				await get_tree().create_timer(2.0).timeout
				correct_spr.hide()
			
			if Global.total_waste == 0 and not ending_triggered:
				ending_triggered = true 
				await get_tree().create_timer(0.5).timeout 
				call_deferred("end_scene") 
			else:
				print("Keep going!")
				
			
		else:		
			Global.lives -= 1
			Global.camera.shake(0.2, 1)
			
			if Global.lives <= 0:
				restart_game()
			
			var interface = $"../lives"
			interface.update_lives()
			
			correct_spr.hide()
			wrong_spr.show()
			wrong_spr.play("wrong")
			wrong_sound.play()

			await get_tree().create_timer(1.0).timeout
			wrong_spr.hide()

func end_scene():
	# Add a guard clause at the start
	if get_tree().root.has_node("ending"):
		return
		
	var ending_scene = load("res://scenes/ending.tscn").instantiate()
	get_tree().root.add_child(ending_scene)
	if ending_scene is CanvasLayer:
		ending_scene.layer = 200
	
	var fog = get_tree().get_current_scene().get_node_or_null("%Fog")
	var env = get_tree().get_current_scene().get_node_or_null("%EnvFilter")
	var bg_music1 = get_tree().get_current_scene().get_node_or_null("bgmusic1")
	var bg_music2 = get_tree().get_current_scene().get_node_or_null("bgmusic2")
	

	fog.hide()
	env.environment.adjustment_saturation = 1
	bg_music1.stop()
	bg_music2.play()



func restart_game():
	Global.lives = 5
	Global.total_waste = Global.all_waste
	var menu_instance = menu.instantiate()
	add_child(menu_instance)
	if menu:
		menu_instance._on_restart_pressed()
	else:
		print("NO HERE")


func _on_pickup_range_area_entered(area: Area2D):
	if area.is_in_group("item_drop"):
		sense.show()
		items_in_range.append(area)
		print(items_in_range)


func _on_pickup_range_area_exited(area: Area2D):
	if area.is_in_group("item_drop"):
		sense.hide()
		items_in_range.erase(area)
		print(items_in_range)
