extends MenuButton

func _ready():
	get_popup().connect("index_pressed",Callable(self,"menu_pressed"))

func menu_pressed(index):
	match index:
		0: 
			$"../../UI/left_panel/VBoxContainer/left/spin_left".value = -5
			$"../../UI/left_panel/VBoxContainer/right/spin_right".value = 5
			$"../../UI/left_panel/VBoxContainer/upper/spin_up".value = 5
			
			$"../../UI/left_panel/VBoxContainer/A/spin-A".value = 0
			$"../../UI/left_panel/VBoxContainer/sigma/spin-sigm".value = 1
			
			$"../../UI/left_panel/VBoxContainer/integral_toggle".button_pressed = false
			
			$Window/ColorPicker.set_pick_color(Color(1, 0, 0))
			$Window/ColorPicker.emit_signal("color_changed", Color(1, 0, 0))
		1: 
			$Window.popup()


func _on_window_close_requested():
	$Window.visible = false
