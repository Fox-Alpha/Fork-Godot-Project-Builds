extends ScrollContainer

@onready var strings: HBoxContainer = %Strings

var string_prefab: PackedScene

signal changed

func _ready() -> void:
	#string_prefab = Prefab.create(%StringPrefab)
	pass

func _add_string() -> void:
	## Projekt liste filtern
	pass

func __add_string() -> LineEdit:
	var string: LineEdit = string_prefab.instantiate()
	string.gui_input.connect(string_gui_input.bind(string))
	string.text_changed.connect(emit_changed.unbind(1))
	strings.add_child(string)
	return string

func string_gui_input(event: InputEvent, edit: LineEdit):
	if not edit.editable:
		return
	
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_DELETE:
			edit.queue_free()
			edit.tree_exited.connect(emit_changed, CONNECT_DEFERRED)

func get_strings() -> PackedStringArray:
	return strings.get_children().map(func(line_edit: LineEdit) -> String: return line_edit.text)

func set_strings(strins: PackedStringArray):
	#for s in strins:
		#var strin := _add_string()
		#strin.text = s
	pass

func emit_changed(_new_text:String):
	changed.emit()
	#print(changed.get_connections())
