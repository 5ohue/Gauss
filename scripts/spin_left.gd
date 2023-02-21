extends SpinBox

func _on_spin_left_value_changed(value):
	if (value > get_node("..").get_parent().get_node("right/spin_right").value): 
		get_node("..").get_parent().get_node("right/spin_right").value = value + 0.1
