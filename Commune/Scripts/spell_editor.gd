extends CanvasLayer

@onready var text_box = $Background/TextEdit
@onready var button = $Background/Button

func _ready():
	text_box.grab_focus()


func _on_button_pressed():
	emit_signal("spell_entered", text_box.text)

signal spell_entered
