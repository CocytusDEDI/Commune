extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.02

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera = $Head/Camera3D
@onready var head = $Head

# Variables used to make spells to decide how many spells to make, should be changed
var number_of_spells_to_make = 1
var number_of_spells = 0

# Dictionary used to record a players efficiency with each component of a spell, should be stored
var efficiencies_bytecode = {}

var example_instructions = "
when_created:
if 2 = 4 - 2 {
give_velocity(-1, 0, 0)
}
"

# Energy should be taken away from the player and given to the spell, but in this example we just give the spell energy
var example_spell_energy = 10.0

func _process(delta):
	# Just to make sure infinite spells are made. Replace with your own code that chooses when to cast a spell.
	if number_of_spells < number_of_spells_to_make:
		number_of_spells += 1

		# Creates the spell
		var spell = Spell.new()

		# Allows for efficiencies to be updated
		spell.connect_player(self)

		# Sets the spells inital energy
		spell.set_energy(example_spell_energy)

		# This line is optional. If not included, all components will be treated as at efficiency level 1
		spell.set_efficiency_levels(JSON.stringify(efficiencies_bytecode))

		# Attempts to translate the instructions into executable format
		var instructions_result = Spell.get_bytecode_instructions(example_instructions)

		# splits the result into a instructions variable and successful variable
		var instructions = instructions_result.get("instructions") # json list
		var successful = instructions_result.get("successful") # boolean
		var error_message = instructions_result.get("error_message") # string

		# If spell was successfully translated, create spell
		if successful:
			# Gives the spell the users instructions
			spell.set_instructions(instructions)

			# Sets the spells position to be the same as the players
			spell.set_position(self.global_position)

			# Put the spell into the game
			get_tree().root.add_child(spell)

			# If spell translation was unsuccesful, do something
		else:
			print(error_message)


# Used by the spell to update the component's efficiencies after they are used. Only used if you use .connect_player()
func update_component_efficiency(component, efficiency_increase):
	# If the component already exists in the dictionary, increase the efficiency, if it doesn't exist, make it exist
	if str(component) in efficiencies_bytecode:
		efficiencies_bytecode[str(component)] += efficiency_increase
	else:
		efficiencies_bytecode[str(component)] = 1 + efficiency_increase


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
