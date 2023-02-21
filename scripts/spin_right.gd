extends SpinBox

func _on_spin_right_value_changed(value):
	if (value < get_node("..").get_parent().get_node("left/spin_left").value): 
		get_node("..").get_parent().get_node("left/spin_left").value = value - 0.1
