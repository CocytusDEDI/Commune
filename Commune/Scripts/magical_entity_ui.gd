extends Node2D

@onready var control_bar = $ControlBar
@onready var energy_charged_bar = $EnergyChargedBar
@onready var energy_selected_bar = $EnergySelectedBar
@onready var focus_bar = $FocusBar
@onready var change_to_indicator = $ChargeToIndicator

# Called when the node enters the scene tree for the first time.
func _ready():
	control_bar.max_value = get_parent().get_max_control()
	energy_charged_bar.max_value = get_parent().get_max_control()
	energy_selected_bar.max_value = get_parent().get_max_control()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	control_bar.value = get_parent().get_control()
	energy_charged_bar.value = get_parent().energy_charged
	energy_selected_bar.value = get_parent().get_energy_selected() * energy_charged_bar.value
	focus_bar.value = get_parent().get_focus()
	change_to_indicator.position.x = get_parent().get_charge_to() * energy_charged_bar.size.x - 2
