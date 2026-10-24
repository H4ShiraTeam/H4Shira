-- Made By @H4ShiraTeam

local Lighting=game:GetService("Lighting")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
local function ensure(className,name) local x=Lighting:FindFirstChild(name) or Instance.new(className); x.Name=name; x.Parent=Lighting; return x end
local function set(x,p,v) pcall(function() x[p]=v end) end
set(Lighting,"Technology",Enum.Technology.Future); set(Lighting,"GlobalShadows",true); set(Lighting,"ShadowSoftness",0.18); set(Lighting,"EnvironmentDiffuseScale",0.6); set(Lighting,"EnvironmentSpecularScale",0.95)
local grade=ensure("ColorCorrectionEffect","H4S_V2_Grade"); grade.Brightness=0.012; grade.Contrast=0.15; grade.Saturation=-0.025; grade.TintColor=Color3.fromRGB(255,248,235)
local bloom=ensure("BloomEffect","H4S_V2_Bloom"); bloom.Intensity=0.16; bloom.Size=26; bloom.Threshold=1.15
local rays=ensure("SunRaysEffect","H4S_V2_SunRays"); rays.Intensity=0.05; rays.Spread=0.8
local air=ensure("Atmosphere","H4S_V2_Atmosphere"); air.Density=0.25; air.Offset=0.1; air.Color=Color3.fromRGB(215,222,226); air.Decay=Color3.fromRGB(105,111,106); air.Glare=0.16; air.Haze=1
local terrain=Workspace:FindFirstChildOfClass("Terrain")
if terrain then set(terrain,"WaterColor",Color3.fromRGB(64,122,108)); set(terrain,"WaterReflectance",0.44); set(terrain,"WaterTransparency",0.16) end
local materials={Grass=Color3.fromRGB(83,116,63),Metal=Color3.fromRGB(122,128,132),Wood=Color3.fromRGB(156,104,60),Rock=Color3.fromRGB(91,95,94),Concrete=Color3.fromRGB(157,158,151)}
local function apply(part)
 if not part:IsA("BasePart") or part.Transparency>=1 or part:GetAttribute("H4S_KeepMaterial") then return end
 local target=materials[part.Material.Name]
 if target then part.Color=part.Color:Lerp(target,0.22) end
 if part.Material==Enum.Material.Metal then part.Reflectance=math.clamp(part.Reflectance+0.12,0,0.7) end
end
local function scan() for _,x in ipairs(Workspace:GetDescendants()) do apply(x) end end
scan()
local t=0
RunService.RenderStepped:Connect(function(dt) t+=dt; if t>2 then t=0; scan() end end)
