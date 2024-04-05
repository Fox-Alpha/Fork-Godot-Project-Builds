extends SceneTree

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 3:
		printerr("Not enough arguments. Required 3 (source, destination, mode), received %d" % args.size())
		quit(ERR_INVALID_PARAMETER)
		return
	
	var source_path := args[0]
	var target_path := args[1]
	var folder_mode := args[2] != "file"
	var recursive := args[2].ends_with("recursive")
	
	var error: int = OK
	if folder_mode:
		error = copy_folder(source_path, target_path, recursive)
	else:
		if target_path.ends_with("/"):
			error = copy_file(source_path, target_path.path_join(source_path.get_file()))
		else:
			error = copy_file(source_path, target_path)
	
	if error == OK:
		print("Copying finished successfully.")
	else:
		printerr("Copying failed, check error code.")
	
	quit(error)

func copy_folder(source_path: String, target_path: String, recursive: bool) -> int:
	for file in DirAccess.get_files_at(source_path):
		var error := copy_file(source_path.path_join(file), target_path.path_join(file))
		if error != OK:
			return error
	
	if recursive:
		for dir in DirAccess.get_directories_at(source_path):
			var error := copy_folder(source_path.path_join(dir), target_path.path_join(dir), true)
			if error != OK:
				return error
	
	return OK

func copy_file(from: String, to: String) -> int:
	if from == to:
		printerr("Source and target file path are the same.")
		return ERR_INVALID_PARAMETER
	
	var error := DirAccess.make_dir_recursive_absolute(to.get_base_dir())
	if error != OK:
		return error
	
	return DirAccess.copy_absolute(from, to)