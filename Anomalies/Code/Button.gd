extends Button




func _on_button_down():
	if $"..".visible:
		$"..".hide()
