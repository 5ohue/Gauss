extends Panel

func _ready():
	var os = OS
#	os.set_min_window_size(Vector2(500,300)) 

func _on_Canvasdrawer_gui_input(event):
	if event is InputEventMouseMotion:
		var inp = $UI/PanelContainer/Canvas_drawer.screenspace_to_coords(event.position) 
		$UI/left_panel/VBoxContainer/coords_text.text = str(inp)
