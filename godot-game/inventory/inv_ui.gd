extends Control

var is_open = true


func close():
	visible = false
	is_open = false
	
func open():
	visible = true
	is_open = true
