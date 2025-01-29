extends CanvasLayer

@onready var waste_counter = %waste_counter
@onready var status_anim = %Status

func _ready() -> void:
	Global.connect("total_waste_updated", Callable(self, "on_total_waste_updated"))
	update_waste_display(Global.total_waste)

func update_waste_display(new_value: int = Global.total_waste):
	waste_counter.text = str(new_value)
	print("Global: ", new_value)
	print("Counter: ", waste_counter.text)

	if new_value <= 9:
		status_anim.play("100")
	elif new_value <= 17:
		status_anim.play("80")
	elif new_value <= 26:
		status_anim.play("60")
	elif new_value <= 34:
		status_anim.play("40")
	else:
		status_anim.play("20")

func on_total_waste_updated(new_value: int):
	update_waste_display(new_value)
