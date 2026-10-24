-- Made By @H4ShiraTeam

local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local RunService=game:GetService("RunService")
local Workspace=game:GetService("Workspace")
local CollectionService=game:GetService("CollectionService")
local player=Players.LocalPlayer
local camera=Workspace.CurrentCamera
local tracked={}
local function get(className,name) local x=Lighting:FindFirstChild(name); if x and x:IsA(className) then return x end; x=Instance.new(className); x.Name=name; x.Parent=Lighting; return x end
local grade=get("ColorCorrectionEffect","H4S_V3_Grade"); local bloom=get("BloomEffect","H4S_V3_Bloom"); local rays=get("SunRaysEffect","H4S_V3_Rays"); local air=get("Atmosphere","H4S_V3_Atmosphere")
Lighting.Technology=Enum.Technology.Future; Lighting.GlobalShadows=true; Lighting.EnvironmentDiffuseScale=0.58; Lighting.EnvironmentSpecularScale=0.95
grade.Brightness=0.01; grade.Contrast=0.15; grade.Saturation=-0.03; grade.TintColor=Color3.fromRGB(255,249,239)
bloom.Intensity=0.15; bloom.Size=24; bloom.Threshold=1.18; rays.Intensity=0.045; rays.Spread=0.82
air.Density=0.23; air.Haze=0.9; air.Glare=0.14; air.Color=Color3.fromRGB(199,212,226); air.Decay=Color3.fromRGB(88,101,119)
local profiles={[Enum.Material.Grass]={c=Color3.fromRGB(83,116,63),r=0.005},[Enum.Material.Metal]={c=Color3.fromRGB(122,128,132),r=0.42},[Enum.Material.WoodPlanks]={c=Color3.fromRGB(156,104,60),r=0.024},[Enum.Material.Rock]={c=Color3.fromRGB(91,95,94),r=0.01},[Enum.Material.Concrete]={c=Color3.fromRGB(157,158,151),r=0.015}}
local function priority(part) if not camera then return 0.3 end; local d=(part.Position-camera.CFrame.Position).Magnitude; local center=camera.CFrame.LookVector:Dot((part.Position-camera.CFrame.Position).Unit); return math.clamp((1-d/240)*0.25+(center+0.35)/1.35*0.35+part.Size.Magnitude/math.max(d,1)*0.4,0.12,1) end
local function apply(part) if not part:IsA("BasePart") or part.Transparency>=1 or part:GetAttribute("H4S_KeepMaterial") or CollectionService:HasTag(part,"H4S_Preserve") then return end; local p=profiles[part.Material]; if not p then return end; if not tracked[part] then tracked[part]={c=part.Color,r=part.Reflectance} end; local w=0.18+priority(part)*0.3; part.Color=tracked[part].c:Lerp(p.c,w); part.Reflectance=math.clamp(tracked[part].r+(p.r-tracked[part].r)*w,0,0.9) end
local function scan() for _,x in ipairs(Workspace:GetDescendants()) do apply(x) end end
scan()
local elapsed=0
RunService.RenderStepped:Connect(function(dt) elapsed+=dt; if elapsed>1.5 then elapsed=0; scan() end; local minutes=Lighting:GetMinutesAfterMidnight(); local day=math.clamp((math.sin((minutes/1440-0.25)*math.pi*2)+0.22)/1.22,0,1); Lighting.Brightness=1.05+day*1.1; air.Haze=0.7+(1-day)*1.05; bloom.Intensity=0.08+day*0.12 end)
