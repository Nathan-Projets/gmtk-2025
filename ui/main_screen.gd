extends CanvasLayer

@export var system: GameSystem = null

@onready var money_label: Label = $VBoxContainer/MoneyLabel

func _ready() -> void:
	Messenger.delivery_done.connect(_on_delivery_reached)
	
	if system == null:
		return
	update_money(system.purse)

func _on_delivery_reached(_reward):
	if system == null:
		return
	update_money(system.purse)

func update_money(new_amount: int):
	money_label.text = str("money: ", new_amount)
