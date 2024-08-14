extends Control

var user_arguments := OS.get_cmdline_user_args()

func _ready() -> void:
	var i := user_arguments.find("--open-project")
	if i > -1:
		if user_arguments.size() < i + 2:
			push_error("No project path provided with --open-project.")
		else:
			var project_path := user_arguments[i + 1]
			if DirAccess.dir_exists_absolute(project_path):
				Data.from_plugin = true
				load_project.call_deferred(project_path)
				return
			else:
				push_error("The project provided for --open-project does not exist.")
	
	i = user_arguments.find("--execute-routine")
	if i > -1:
		push_error("--execute-routine was provided, but no project was opened with --open-project.")
		get_tree().quit(1)
		return
	
	i = user_arguments.find("--exit")
	if i > -1:
		push_error("--exit argument provided, but no --execute-routine. It will be ignored.")
	
	var editor_data := OS.get_user_data_dir().get_base_dir().get_base_dir()
	var project_list := ConfigFile.new()
	project_list.load(editor_data.path_join("projects.cfg"))
	
	for project in project_list.get_sections():
		var project_entry := preload("res://Nodes/ProjectEntry.tscn").instantiate()
		$VBoxContainer.add_child(project_entry)
		project_entry.set_project(project, load_project)

func load_project(project: String):
	Data.load_project(project)
	
	var i := user_arguments.find("--execute-routine")
	if i > -1:
		var j := user_arguments.find("--exit")
		if j > -1:
			Data.auto_exit = true
		
		if user_arguments.size() < i + 2:
			print("No routine name provided for --execute-routine.")
			print_routines_and_exit()
			return
		else:
			var routine_name := user_arguments[i + 1]
			for routine in Data.routines:
				if routine["name"] == routine_name:
					Data.current_routine = routine
					get_tree().change_scene_to_file("res://Scenes/Execution.tscn")
					return
			
			push_error("The project provided for --execute-routine does not exist.")
			print_routines_and_exit()
			return
	
	i = user_arguments.find("--exit")
	if i > -1:
		push_error("--exit argument provided, but no --execute-routine. It will be ignored.")
	
	get_tree().change_scene_to_packed(Data.main)

func print_routines_and_exit():
	print("Available routines:")
	for routine in Data.routines:
		print(routine["name"])
	
	if Data.auto_exit:
		get_tree().quit(1)
