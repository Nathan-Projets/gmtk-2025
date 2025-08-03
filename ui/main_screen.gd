extends CanvasLayer

@export var system: GameSystem = null

@onready var money_label: Label = $VBoxContainer/HBoxContainer/MoneyPanel/VBoxContainer/Label
@onready var temperature_label: Label = $VBoxContainer/HBoxContainer2/TemperaturePanel/VBoxContainer/Label

@onready var button_speed: Button = $VBoxContainer/HBoxContainer3/Button
@onready var button_defense: Button = $VBoxContainer/HBoxContainer4/Button

@onready var speed_label: Label = $VBoxContainer/HBoxContainer3/MoneyPanel/VBoxContainer/Label2
@onready var defense_label: Label = $VBoxContainer/HBoxContainer4/MoneyPanel/VBoxContainer/Label2

func _ready() -> void:
	Messenger.delivery_done.connect(_on_delivery_reached)
	Messenger.temperature_changed.connect(_on_temperature_changed)
	Messenger.bought_defense.connect(_on_defense_bought)
	Messenger.bought_speed.connect(_on_speed_bought)
	
	if system == null:
		return
	update_money(system.purse)

func _on_defense_bought(new_defense):
	if system == null:
		return
	update_money(system.purse)
	defense_label.text = str(new_defense)
	
func _on_speed_bought(new_speed):
	if system == null:
		return
	update_money(system.purse)
	speed_label.text = str(new_speed)

func _on_temperature_changed(percentage: float):
	temperature_label.text = str(floori(percentage * 100.0), "%")

func _on_delivery_reached(_reward):
	if system == null:
		return
	update_money(system.purse)

func update_money(new_amount: int):
	money_label.text = str(new_amount)

func _on_button_speed_pressed() -> void:
	Messenger.buy_speed.emit()

func _on_button_defense_pressed() -> void:
	Messenger.buy_defense.emit()
