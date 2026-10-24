-- Made By @H4ShiraTeam

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local function make(className, name)
 local item = Lighting:FindFirstChild(name) or Instance.new(className)
 item.Name = name
 item.Parent = Lighting
 return item
end
pcall(function()
 Lighting.Technology = Enum.Technology.Future
 Lighting.GlobalShadows = true
 Lighting.ShadowSoftness = 0.2
 Lighting.EnvironmentDiffuseScale = 0.58
 Lighting.EnvironmentSpecularScale = 0.9
 Lighting.Brightness = 2
 Lighting.ExposureCompensation = 0.05
 Lighting.Ambient = Color3.fromRGB(38,43,49)
 Lighting.OutdoorAmbient = Color3.fromRGB(104,112,122)
end)
local grade=make("ColorCorrectionEffect","H4S_V1_ColorGrade")
grade.Brightness=0.01
grade.Contrast=0.14
grade.Saturation=-0.025
grade.TintColor=Color3.fromRGB(255,249,239)
local bloom=make("BloomEffect","H4S_V1_Bloom")
bloom.Intensity=0.14
bloom.Size=24
bloom.Threshold=1.2
local rays=make("SunRaysEffect","H4S_V1_SunRays")
rays.Intensity=0.045
rays.Spread=0.82
local air=make("Atmosphere","H4S_V1_Atmosphere")
air.Density=0.24
air.Offset=0.1
air.Color=Color3.fromRGB(199,212,226)
air.Decay=Color3.fromRGB(88,101,119)
air.Glare=0.14
air.Haze=0.92
local terrain=Workspace:FindFirstChildOfClass("Terrain")
if terrain then
 terrain.WaterColor=Color3.fromRGB(42,112,132)
 terrain.WaterReflectance=0.42
 terrain.WaterTransparency=0.18
 terrain.WaterWaveSize=0.18
 terrain.WaterWaveSpeed=8
end
