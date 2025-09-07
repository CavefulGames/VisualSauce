local roblox = require("@lune/roblox")
local fs = require("@lune/fs")
local process = require("@lune/process")

if not fs.isDir("build") then
	fs.writeDir("build")
end

local is_dev_build = table.find(process.args, "--dev")
local build_file_name = is_dev_build and "DevVisualSauce" or "VisualSauce"
local project_json_name = is_dev_build and "dev.project.json" or "default.project.json"
local rbxl_file_name = build_file_name .. ".rbxl"

if fs.isFile("build/" .. rbxl_file_name) then
	fs.removeFile("build/VisualSauce.rbxl")
end
local build_process = process.create("rojo", { "build", project_json_name, "--output", "build/" .. rbxl_file_name })

if not build_process:status().ok then
	print(build_process.stderr:read())
	return
end

fs.writeFile(
	"build/" .. rbxl_file_name,
	if is_dev_build then
		roblox.serializeModel({
			(roblox.deserializeModel(fs.readFile("build/DevVisualSauce.rbxl"))[1] :: any)
			:FindFirstChild("DevVisualSauce"),
		})
	else
		roblox.serializeModel({
			(roblox.deserializeModel(fs.readFile("build/" .. rbxl_file_name))[1] :: any)
				:FindFirstChild("Packages")
				:FindFirstChild("VisualSauce"),
		})
)
