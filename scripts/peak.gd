extends Label

func _on_Canvas_drawer_recalculated(peak):
	text = "f(A) = " + str(snappedf(peak, 0.0001))
