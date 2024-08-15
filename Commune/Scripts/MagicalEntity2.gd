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
	var result = spell.get_bytecode_instructions(instructions_example)
	var instructions = result.get("instructions")
	spell.set_energy(100)
	spell.set_instructions(instructions)
	self.add_child(spell)
	
