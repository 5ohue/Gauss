extends ColorRect

var line_raw = PackedVector2Array()
var line_coords_1 = PackedVector2Array()
var line_coords_2 = PackedVector2Array()

var x_lrange = -5.0
var x_rrange = 5.0
var y_range = 5.0

var x_margin = 15
var y_margin = 15

var A = 0.0
var sigm = 1.0

var integral = false

var curve_color = Color(1,0,0)
signal recalculated(peak)

#avoiding zero division
func not_zero(number: float) -> float:
	if (number):
		return number
	else:
		return 0.01

#this function converts real coordinates to screen space
func coords_to_screenspace(i: Vector2) -> Vector2:
	var a = Vector2()
	var canv_size = get_rect().size
	a.x = (i.x - x_lrange) * (canv_size.x - 2 * x_margin) / \
		not_zero(x_rrange - x_lrange) + x_margin
	a.y = canv_size.y - (i.y + y_range/50) * (canv_size.y - \
		2 * y_margin) / (y_range + y_range/50) - y_margin
	return a

#previous function reversed
func screenspace_to_coords(i: Vector2) -> Vector2:
	var a = Vector2()
	var canv_size = get_rect().size
	
	a.x = (i.x - x_margin) * not_zero(x_rrange - x_lrange) / \
		(canv_size.x - 2 * x_margin) + x_lrange
	a.x = snapped(a.x, 0.0001)
	
	a.y = (canv_size.y - i.y - y_margin) * (y_range + y_range/50) / \
		(canv_size.y - 2 * y_margin) - y_range/50
	a.y = snapped(a.y, 0.0001)
	return a

#recalculating curve
func calc_gauss():
	line_raw.resize(0)
	
	var i = x_lrange # variable running through x
	var prefix = 0.39894228 / sigm # 1/sqrt(2*pi)*sigm but 0.398... is 1/sqrt(2*pi)
	var rev_sigm_sq = 1 / (2 * sigm * sigm)
	
	emit_signal("recalculated", prefix)
	
	if !integral:
		var step = not_zero(x_rrange - x_lrange)/500
		while (i <= x_rrange):
			var G = Vector2()
			G.x = i
			G.y = prefix * exp( - (i - A) * (i - A) * rev_sigm_sq)
			line_raw.append(G)
			i += step
	else:
		var integ = 0
		i = -50
		while (i <= x_lrange):
			integ += prefix * exp( - (i - A) * (i - A) * rev_sigm_sq) * 0.01
			i += 0.01
		
		i = x_lrange
		var step = not_zero(x_rrange - x_lrange)/500
		
		while (i <= x_rrange):
			var G = Vector2()
			G.x = i
			G.y = integ
			G.y += prefix * exp( - (i - A) * (i - A) * rev_sigm_sq) * step
			line_raw.append(G)
			integ = G.y
			i += step

#making curve screenspace
func mk_curve():
	line_coords_1.resize(0)
	line_coords_2.resize(0)
	
	var been_over_the_TOP = false #avoiding going over the top
	
	for point in line_raw:
		var ss_point = coords_to_screenspace(point)
		
		if (ss_point.y < y_margin):
			been_over_the_TOP = true
		else:
			if been_over_the_TOP:
				line_coords_2.append(coords_to_screenspace(point))
			else:
				line_coords_1.append(coords_to_screenspace(point))

#initial curve calculation at start
func _ready():
	calc_gauss()

#drawing function
func _draw():
	#grid
	for i in range(x_lrange,x_rrange+1):
		var s = coords_to_screenspace(Vector2(i,-y_range/50))
		var f = coords_to_screenspace(Vector2(i,y_range))
		draw_line(s,f,Color(0.4,0.4,0.4),1)
	for j in range(1,y_range+1):
		var s = coords_to_screenspace(Vector2(x_lrange,j))
		var f = coords_to_screenspace(Vector2(x_rrange,j))
		draw_line(s,f,Color(0.4,0.4,0.4),1)
	
	#drawing numbers
	var font = load("res://fonts/Ubuntu-Regular.ttf")#("res://fonts/font.tres")
	
	for i in range(10):
		var vec = coords_to_screenspace(Vector2(x_lrange + (x_rrange - x_lrange) * i / 10, 1))
		vec.y = get_rect().size.y - 6
		
		var txt = str(snappedf(x_lrange + (x_rrange - x_lrange) * i / 10, 0.01))
		
		draw_string(SystemFont.new(), vec, 
		txt,
		HORIZONTAL_ALIGNMENT_CENTER,
		-1,
		16,
		Color.BLACK)
	for i in range(1,10):
		var vec = coords_to_screenspace(Vector2(1,y_range*i/10))
		vec.x = 5
		
		var txt = str(snappedf(y_range * i / 10, 0.01))
		
		draw_string(SystemFont.new(), vec, 
		txt,
		HORIZONTAL_ALIGNMENT_CENTER,
		-1,
		16,
		Color.BLACK)
	#drawing axis1
	#y axis
	var s = coords_to_screenspace(Vector2(0,-y_range/50))
	var f = coords_to_screenspace(Vector2(0,y_range))
	draw_line(s,f,Color(0,0,0),2)
	
	#arrows 
	var x_arr = not_zero(x_rrange - x_lrange) * 0.025/2
	var y_arr = (y_range + y_range/50) * 0.025
	
	var tip = PackedVector2Array(
		[coords_to_screenspace(Vector2(-x_arr,y_range-y_arr)), 
		coords_to_screenspace(Vector2(0,y_range)), 
		coords_to_screenspace(Vector2(x_arr,y_range-y_arr))])
	draw_polyline(tip, Color(0,0,0),2, true)
	
	#x axis
	s = coords_to_screenspace(Vector2(x_lrange,0))
	f = coords_to_screenspace(Vector2(x_rrange,0))
	draw_line(s,f,Color(0,0,0),2)
	
	#arrows 
	tip = PackedVector2Array(
		[coords_to_screenspace(Vector2(x_rrange-x_arr,y_arr)), 
		coords_to_screenspace(Vector2(x_rrange,0)), 
		coords_to_screenspace(Vector2(x_rrange-x_arr,-y_arr))])
	draw_polyline(tip, Color(0,0,0),2, true)
	
	#drawing the curve
	mk_curve()
	draw_polyline(line_coords_1, curve_color,2, true)
	draw_polyline(line_coords_2, curve_color,2, true)

#processing spinbox changes
func _on_spin_left_value_changed(value):
	x_lrange = value
	calc_gauss()
	queue_redraw()

func _on_spin_right_value_changed(value):
	x_rrange = value
	calc_gauss()
	queue_redraw()

func _on_spin_up_value_changed(value):
	y_range = value
	calc_gauss()
	queue_redraw()

func _on_spinA_value_changed(value):
	A = value
	calc_gauss()
	queue_redraw()

func _on_spinsigm_value_changed(value):
	sigm = value
	calc_gauss()
	queue_redraw()

func _on_integral_toggle_toggled(button_pressed):
	integral = !integral
	calc_gauss()
	queue_redraw()


func _on_ColorPicker_color_changed(color):
	curve_color = color
	queue_redraw()
