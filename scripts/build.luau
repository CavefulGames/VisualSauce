local roblox = require("@lune/roblox")
local fs = require("@lune/fs")
local process = require("@lune/process")

if not fs.isDir("build") then
	fs.writeDir("build")
end

if fs.isFile("build/VisualSauce.rbxl") then
	fs.removeFile("build/VisualSauce.rbxl")
end
local build_process = process.create("rojo", { "build", "--output", "build/VisualSauce.rbxl" })

if not build_process:status().ok then
	print(build_process.stderr:read())
	return
end

fs.writeFile(
	"build/VisualSauce.rbxm",
	roblox.serializeModel({
		(roblox.deserializeModel(fs.readFile("build/VisualSauce.rbxl"))[1] :: any)
			:FindFirstChild("Packages")
			:FindFirstChild("VisualSauce"),
	})
)
