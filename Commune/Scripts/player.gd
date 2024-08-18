extends MagicalEntity

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.02
const SCROLL_WHEEL_SENSITIVITY = 0.02

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera = $Camera3D

var player_menu = preload("res://Scenes/spell_editor.tscn")
var magical_entity_ui = preload("res://Scenes/magical_entity_ui.tscn")
var player_menu_up = false
var charge_selection = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var magical_entity_ui_instance = magical_entity_ui.instantiate()
	self.add_child(magical_entity_ui_instance)
	self.set_save_path("player")
	self.add_component("give_velocity")
	self.add_component("set_damage")
	self.add_component("recharge_to")
	self.add_component("get_time")
	self.add_component("anchor")
	self.add_component("undo_anchor")

func _process(delta):
	# Handles the changing of properties
	self.handle_magic(delta)
	
	# Deals with the menu
	if Input.is_action_just_pressed("player_menu"):
		if player_menu_up:
			self.get_node("Spell Editor").queue_free()
			player_menu_up = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			player_menu_up = true
			var player_menu_instance = player_menu.instantiate()
			self.add_child(player_menu_instance)
			player_menu_instance.connect("spell_entered", set_spell)
	# Allows players to cast spells if the menus not up
	if !player_menu_up:
		if Input.is_action_just_pressed("cast"):
			self.cast_spell()
		if Input.is_action_just_pressed("toggle_charge_selection"):
			if charge_selection:
				charge_selection = false
			else:
				charge_selection = true

func set_spell(text):
	# Attempts to translate the instructions into executable format
	var instructions_result = Spell.get_bytecode_instructions(text)

	# Splits instructions_result into a instructions variable and successful variable
	var instructions = instructions_result.get("instructions") # json list
	var successful = instructions_result.get("successful") # boolean
	var error_message = instructions_result.get("error_message") # string

	# Test to see if the player as access to the components they're trying to cast
	var allowed_to_cast_result = self.check_allowed_to_cast(instructions)

	# Splits the allowed_to_cast_result into an allowed_to_cast variable and denial_reason variable
	var allowed_to_cast = allowed_to_cast_result.get("allowed_to_cast") # boolean
	var denial_reason = allowed_to_cast_result.get("denial_reason") # denial reason

	# If spell was successfully translated and they're allowed to cast it
	if successful and allowed_to_cast:
		# Gives the spell the users instructions
		self.set_loaded_spell(instructions)

	# If spell translation was unsuccesful, do something
	else:
		if !successful:
			print(error_message)
		else:
			print(denial_reason)

func _unhandled_input(event):
	# Move head
	if event is InputEventMouseMotion:
		self.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	else:
		if !(event is InputEventMouseButton):
			return

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if charge_selection:
				self.change_energy_selected(SCROLL_WHEEL_SENSITIVITY)
			else:
				self.change_charge_to(SCROLL_WHEEL_SENSITIVITY)
		else:
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if charge_selection:
					self.change_energy_selected(-SCROLL_WHEEL_SENSITIVITY)
				else:
					self.change_charge_to(-SCROLL_WHEEL_SENSITIVITY)

var target_velocity = Vector3.ZERO

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	target_velocity = Vector3.ZERO
	
	# Handle jump.
	if !player_menu_up:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("left", "right", "forward", "backward")
		var direction = (self.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			target_velocity = direction * SPEED
		else:
			target_velocity = Vector3.ZERO
		
	self.velocity.x = move_toward(self.velocity.x, target_velocity.x, delta * 50)
	self.velocity.z = move_toward(self.velocity.z, target_velocity.z, delta * 50)

	move_and_slide()
