extends Node
@onready var coinLabel: Label = $"../CanvasLayer/Coins"
var timercounting = true
var coins = 0
var time = 0.00
func _process(delta: float) -> void:
	if timercounting == true:
		time += delta
		coinLabel.text="time: "+str(time)
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
func add_point():
	coins+=1
	coinLabel.text="Coins: "+str(coins)
