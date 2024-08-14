extends Node2D

@onready var shield_bar = $ShieldBar
@onready var control_bar = $ControlBar
@onready var charged_energy_bar = $ChargedEnergyBar
@onready var energy_selected_bar = $EnergySelectedBar
@onready var focus_bar = $FocusBar

# Called when the node enters the scene tree for the first time.
func _ready():
	shield_bar.max_value = get_parent().get_max_shield()
	control_bar.max_value = get_parent().get_max_control()
	charged_energy_bar.max_value = get_parent().get_max_control()
	energy_selected_bar.max_value = get_parent().get_max_control()

func set_control(control):
	control_bar.value = control
	
func set_shield(shield):
	shield_bar.value = shield

func set_energy_charged(energy_charged):
	charged_energy_bar.value = energy_charged
	
func set_energy_selected(energy_selected): # energy_selected should be a range from 0 to 1
	energy_selected_bar.value = energy_selected * charged_energy_bar.value

func set_focus(focus):
	focus_bar.value = focus

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
