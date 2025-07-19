local roblox = require("@lune/roblox")
local fs = require("@lune/fs")
local process = require("@lune/process")

if not fs.isDir("build") then
	fs.writeDir("build")
end

if fs.isFile("build/DevVisualSauce.rbxl") then
	fs.removeFile("build/DevVisualSauce.rbxl")
end
local build_process = process.create("rojo", { "build", "dev.project.json", "--output", "build/DevVisualSauce.rbxl" })

if not build_process:status().ok then
	print(build_process.stderr:read())
	return
end

fs.writeFile(
	"build/DevVisualSauce.rbxm",
	roblox.serializeModel({
		(roblox.deserializeModel(fs.readFile("build/DevVisualSauce.rbxl"))[1] :: any):FindFirstChild("DevVisualSauce"),
	})
)
