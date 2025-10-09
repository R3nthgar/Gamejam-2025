extends Node
@onready var coinLabel: Label = $"../CanvasLayer/Coins"

var coins = 0

func add_point():
	coins+=1
	coinLabel.text="Coins: "+str(coins)
