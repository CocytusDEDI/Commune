extends MagicalEntity

var instructions_example = "
about:
	color = [0, 0, 0]

when_created:
	give_velocity(1, 0, 0)
	set_damage(1)
"

func _ready():
	var spell = Spell.new()
	var result = Spell.get_bytecode_instructions(instructions_example)
	var instructions = result.get("instructions")
	spell.set_energy(100)
	spell.set_instructions(instructions)
	spell.top_level = true
	spell.position = self.position
	self.add_child(spell)

func _physics_process(delta: float) -> void:
	self.velocity.x = move_toward(self.velocity.x, 0, delta * 50)
	self.velocity.z = move_toward(self.velocity.z, 0, delta * 50)
	self.velocity.y = move_toward(self.velocity.y, 0, delta * 50)
	
	move_and_slide()
