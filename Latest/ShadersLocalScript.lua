-- Made By @H4ShiraTeam

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local connections = {}
local tracked = {}
local updateQueue = {}
local animatedSet = {}
local lightRegistry = {}
local emitterRegistry = {}
local engine = {
	name = "H4S Visual Intelligence Engine",
	version = "1.0.0",
	signature = {},
	zoneMemory = {},
	priorityMemory = {},
	lastProfileUpdate = 0,
	hardware = {
		gpuQuality = 1,
		cpuQuality = 1,
		cpuTime = 0,
		frameTime = 1 / 60,
	},
}
local scene = {
	style = "balanced",
	styleConfidence = 0,
	averageSaturation = 0,
	averageBrightness = 0,
	warmth = 0,
	neonRatio = 0,
	materialConfidence = 0,
	correctionStrength = 0.22,
	preserve = 0.78,
	analyzed = false,
}

local CONFIG = {
	ScanInterval = 2.2,
	ScanBatchSize = 180,
	UpdateInterval = 0.12,
	MaterialUpdateInterval = 0.18,
	MaxTrackedParts = 4200,
	MaxAnimatedParts = 700,
	SceneSampleSize = 900,
	EnableSceneInterpretation = true,
	EnableMaterialIntelligence = true,
	EnableDynamicExposure = true,
	EnableAdaptiveAtmosphere = true,
	EnableCinematicDepth = true,
	EnableBloom = true,
	EnableSunRays = true,
	EnableSurfaceResponse = true,
	WaterTint = Color3.fromRGB(42, 112, 132),
	NightBrightness = 1.05,
	DayBrightness = 2.15,
	PreserveOriginalColor = 0.82,
	PreserveOriginalMaterial = 0.9,
	TargetFrameTime = 1 / 60,
	MinimumRenderQuality = 0.58,
	MaximumRenderQuality = 1,
	EnableAdaptiveQuality = true,
	EnableLightBudget = true,
	EnableParticleBudget = true,
	LightDistance = 220,
	ParticleDistance = 180,
	EnableProprietaryEngine = true,
	PerceptualRange = 260,
	SignatureSampleSize = 1200,
	CPUFrameBudget = 0.0035,
	EnableHardwareBudget = true,
}

local reconstruction = {
	quality = 1,
	frameTime = CONFIG.TargetFrameTime,
	stableFrameTime = CONFIG.TargetFrameTime,
}

local function getOrCreate(className, name)
	local object = Lighting:FindFirstChild(name)
	if object and object:IsA(className) then
		return object
	end
	object = Instance.new(className)
	object.Name = name
	object.Parent = Lighting
	return object
end

local colorGrade = getOrCreate("ColorCorrectionEffect", "H4S_CinematicGrade")
local bloom = getOrCreate("BloomEffect", "H4S_RealBloom")
local sunRays = getOrCreate("SunRaysEffect", "H4S_VolumetricSun")
local depthOfField = getOrCreate("DepthOfFieldEffect", "H4S_CinematicDepth")
local atmosphere = getOrCreate("Atmosphere", "H4S_PhysicalAtmosphere")

local function safeSet(object, property, value)
	pcall(function()
		object[property] = value
	end)
end

local function updateReconstruction(deltaTime)
	if not CONFIG.EnableAdaptiveQuality then
		return
	end
	local measured = math.clamp(deltaTime, 1 / 240, 0.12)
	reconstruction.frameTime = reconstruction.frameTime + (measured - reconstruction.frameTime) * 0.12
	reconstruction.stableFrameTime = reconstruction.stableFrameTime + (reconstruction.frameTime - reconstruction.stableFrameTime) * 0.035
	local target = CONFIG.TargetFrameTime
	local pressure = math.clamp((reconstruction.stableFrameTime - target) / target, -0.45, 1.2)
	local desired = math.clamp(1 - pressure * 0.38, CONFIG.MinimumRenderQuality, CONFIG.MaximumRenderQuality)
	local response = desired < reconstruction.quality and 0.12 or 0.025
	reconstruction.quality += (desired - reconstruction.quality) * response
	engine.hardware.frameTime = reconstruction.stableFrameTime
	engine.hardware.gpuQuality = reconstruction.quality
end

local function updateCPUQuality(cpuTime)
	if not CONFIG.EnableHardwareBudget then
		return
	end
	local budget = CONFIG.CPUFrameBudget
	local pressure = math.clamp((cpuTime - budget) / budget, -0.5, 1.5)
	local target = math.clamp(1 - pressure * 0.42, 0.5, 1)
	local response = target < engine.hardware.cpuQuality and 0.18 or 0.035
	engine.hardware.cpuQuality += (target - engine.hardware.cpuQuality) * response
	engine.hardware.cpuTime = cpuTime
end

safeSet(Lighting, "Technology", Enum.Technology.Future)
safeSet(Lighting, "GlobalShadows", true)
safeSet(Lighting, "ShadowSoftness", 0.2)
safeSet(Lighting, "EnvironmentDiffuseScale", 0.58)
safeSet(Lighting, "EnvironmentSpecularScale", 0.92)
safeSet(colorGrade, "Brightness", 0.01)
safeSet(colorGrade, "Contrast", 0.12)
safeSet(colorGrade, "Saturation", -0.02)
safeSet(colorGrade, "TintColor", Color3.fromRGB(255, 249, 239))
safeSet(bloom, "Intensity", 0.14)
safeSet(bloom, "Size", 24)
safeSet(bloom, "Threshold", 1.2)
safeSet(sunRays, "Intensity", 0.04)
safeSet(sunRays, "Spread", 0.82)
safeSet(depthOfField, "Enabled", false)
safeSet(depthOfField, "FarIntensity", 0.06)
safeSet(depthOfField, "InFocusRadius", 44)
safeSet(depthOfField, "NearIntensity", 0.02)
safeSet(atmosphere, "Density", 0.24)
safeSet(atmosphere, "Offset", 0.1)
safeSet(atmosphere, "Color", Color3.fromRGB(199, 212, 226))
safeSet(atmosphere, "Decay", Color3.fromRGB(88, 101, 119))
safeSet(atmosphere, "Glare", 0.14)
safeSet(atmosphere, "Haze", 0.92)

local function getWorldPosition(object)
	if object:IsA("Attachment") then
		return object.WorldPosition
	end
	if object:IsA("BasePart") then
		return object.Position
	end
	local parent = object.Parent
	while parent do
		if parent:IsA("Attachment") then
			return parent.WorldPosition
		end
		if parent:IsA("BasePart") then
			return parent.Position
		end
		parent = parent.Parent
	end
	return nil
end

local function scanNativeRenderObjects()
	lightRegistry = {}
	emitterRegistry = {}
	for _, object in ipairs(Workspace:GetDescendants()) do
		if object:IsA("PointLight") or object:IsA("SpotLight") or object:IsA("SurfaceLight") then
			if object:GetAttribute("H4S_KeepLight") ~= true and not CollectionService:HasTag(object, "H4S_KeepLight") then
				lightRegistry[#lightRegistry + 1] = {object = object, enabled = object.Enabled}
			end
		elseif object:IsA("ParticleEmitter") then
			if object:GetAttribute("H4S_KeepParticles") ~= true and not CollectionService:HasTag(object, "H4S_KeepParticles") then
				emitterRegistry[#emitterRegistry + 1] = {object = object, enabled = object.Enabled, rate = object.Rate}
			end
		end
	end
	if Terrain then
		safeSet(Terrain, "WaterColor", CONFIG.WaterTint)
		safeSet(Terrain, "WaterReflectance", 0.42)
		safeSet(Terrain, "WaterTransparency", 0.18)
		safeSet(Terrain, "WaterWaveSize", 0.18)
		safeSet(Terrain, "WaterWaveSpeed", 8)
	end
end

local function updateNativeBudgets()
	if not camera then
		return
	end
	local quality = math.min(reconstruction.quality, engine.hardware.cpuQuality)
	if CONFIG.EnableLightBudget then
		local lightDistance = CONFIG.LightDistance * (0.72 + quality * 0.28)
		for index = #lightRegistry, 1, -1 do
			local record = lightRegistry[index]
			local object = record.object
			if not object or not object.Parent then
				table.remove(lightRegistry, index)
			else
				local position = getWorldPosition(object)
				local visible = position and (position - camera.CFrame.Position).Magnitude <= lightDistance
				object.Enabled = record.enabled and visible
			end
		end
	end
	if CONFIG.EnableParticleBudget then
		local particleDistance = CONFIG.ParticleDistance * (0.68 + quality * 0.32)
		for index = #emitterRegistry, 1, -1 do
			local record = emitterRegistry[index]
			local object = record.object
			if not object or not object.Parent then
				table.remove(emitterRegistry, index)
			else
				local position = getWorldPosition(object)
				local visible = position and (position - camera.CFrame.Position).Magnitude <= particleDistance
				object.Enabled = record.enabled and visible
				object.Rate = record.rate * quality
			end
		end
	end
end

local materialProfiles = {
	[Enum.Material.Grass] = {color = Color3.fromRGB(83, 116, 63), reflectance = 0.005, roughness = 0.94},
	[Enum.Material.LeafyGrass] = {color = Color3.fromRGB(66, 106, 52), reflectance = 0.008, roughness = 0.88},
	[Enum.Material.Ground] = {color = Color3.fromRGB(112, 91, 67), reflectance = 0, roughness = 0.98},
	[Enum.Material.Mud] = {color = Color3.fromRGB(83, 63, 48), reflectance = 0, roughness = 0.98},
	[Enum.Material.Sand] = {color = Color3.fromRGB(202, 177, 126), reflectance = 0.01, roughness = 0.91},
	[Enum.Material.Snow] = {color = Color3.fromRGB(227, 234, 239), reflectance = 0.035, roughness = 0.64},
	[Enum.Material.Rock] = {color = Color3.fromRGB(91, 95, 94), reflectance = 0.01, roughness = 0.96},
	[Enum.Material.Slate] = {color = Color3.fromRGB(74, 78, 82), reflectance = 0.02, roughness = 0.83},
	[Enum.Material.Basalt] = {color = Color3.fromRGB(54, 56, 59), reflectance = 0.015, roughness = 0.87},
	[Enum.Material.Concrete] = {color = Color3.fromRGB(157, 158, 151), reflectance = 0.015, roughness = 0.89},
	[Enum.Material.Brick] = {color = Color3.fromRGB(141, 74, 59), reflectance = 0.008, roughness = 0.91},
	[Enum.Material.Cobblestone] = {color = Color3.fromRGB(109, 107, 99), reflectance = 0.018, roughness = 0.86},
	[Enum.Material.Wood] = {color = Color3.fromRGB(127, 83, 49), reflectance = 0.025, roughness = 0.7},
	[Enum.Material.WoodPlanks] = {color = Color3.fromRGB(156, 104, 60), reflectance = 0.024, roughness = 0.68},
	[Enum.Material.Metal] = {color = Color3.fromRGB(122, 128, 132), reflectance = 0.42, roughness = 0.27},
	[Enum.Material.DiamondPlate] = {color = Color3.fromRGB(134, 141, 145), reflectance = 0.5, roughness = 0.23},
	[Enum.Material.CorrodedMetal] = {color = Color3.fromRGB(113, 83, 63), reflectance = 0.15, roughness = 0.76},
	[Enum.Material.Glass] = {color = Color3.fromRGB(176, 214, 220), reflectance = 0.6, roughness = 0.08},
	[Enum.Material.Neon] = {color = Color3.fromRGB(241, 247, 255), reflectance = 0.12, roughness = 0.15},
	[Enum.Material.Marble] = {color = Color3.fromRGB(203, 201, 192), reflectance = 0.25, roughness = 0.3},
	[Enum.Material.Pebble] = {color = Color3.fromRGB(117, 116, 108), reflectance = 0.01, roughness = 0.92},
	[Enum.Material.Foil] = {color = Color3.fromRGB(176, 180, 182), reflectance = 0.72, roughness = 0.19},
	[Enum.Material.Ice] = {color = Color3.fromRGB(177, 225, 239), reflectance = 0.5, roughness = 0.13},
	[Enum.Material.Water] = {color = CONFIG.WaterTint, reflectance = 0.72, roughness = 0.08},
}

local keywordProfiles = {
	water = {material = Enum.Material.Water, color = CONFIG.WaterTint, priority = 1},
	glass = {material = Enum.Material.Glass, color = Color3.fromRGB(176, 214, 220), priority = 1},
	metal = {material = Enum.Material.Metal, color = Color3.fromRGB(122, 128, 132), priority = 1},
	steel = {material = Enum.Material.Metal, color = Color3.fromRGB(122, 128, 132), priority = 1},
	wood = {material = Enum.Material.WoodPlanks, color = Color3.fromRGB(156, 104, 60), priority = 1},
	foliage = {material = Enum.Material.LeafyGrass, color = Color3.fromRGB(66, 106, 52), priority = 1},
	leaf = {material = Enum.Material.LeafyGrass, color = Color3.fromRGB(66, 106, 52), priority = 1},
	grass = {material = Enum.Material.Grass, color = Color3.fromRGB(83, 116, 63), priority = 1},
	rock = {material = Enum.Material.Rock, color = Color3.fromRGB(91, 95, 94), priority = 1},
	stone = {material = Enum.Material.Slate, color = Color3.fromRGB(74, 78, 82), priority = 1},
	concrete = {material = Enum.Material.Concrete, color = Color3.fromRGB(157, 158, 151), priority = 1},
	brick = {material = Enum.Material.Brick, color = Color3.fromRGB(141, 74, 59), priority = 1},
	neon = {material = Enum.Material.Neon, color = Color3.fromRGB(241, 247, 255), priority = 1},
}

local styleKeywords = {
	stylized = true,
	cartoon = true,
	lowpoly = true,
	low_poly = true,
	fantasy = true,
	anime = true,
	realistic = false,
	realism = false,
	cinematic = false,
	photoreal = false,
}

local function clamp01(value)
	return math.clamp(value, 0, 1)
end

local function lower(value)
	return string.lower(tostring(value))
end

local function colorMetrics(color)
	local r, g, b = color.R, color.G, color.B
	local maximum = math.max(r, g, b)
	local minimum = math.min(r, g, b)
	local brightness = (maximum + minimum) * 0.5
	local saturation = maximum == minimum and 0 or (maximum - minimum) / math.max(1 - math.abs(maximum + minimum - 1), 0.001)
	local warmth = (r - b + (r - g) * 0.35) * 0.5
	return clamp01(saturation), clamp01(brightness), math.clamp(warmth, -1, 1)
end

local function getManualStyle()
	local value = Workspace:GetAttribute("H4S_ArtStyle") or Lighting:GetAttribute("H4S_ArtStyle")
	if typeof(value) == "string" then
		value = lower(value)
		if value == "stylized" or value == "realistic" or value == "cinematic" or value == "balanced" then
			return value
		end
	end
	return nil
end

local function getZoneKey(part)
	local parent = part.Parent
	local depth = 0
	while parent and depth < 5 do
		if parent:IsA("Folder") or parent:IsA("Model") then
			local name = lower(parent.Name)
			if name ~= "workspace" and name ~= "camera" then
				return name
			end
		end
		parent = parent.Parent
		depth += 1
	end
	return "global"
end

local function getPerceptualPriority(part)
	if not camera then
		return 0.35
	end
	local distance = (part.Position - camera.CFrame.Position).Magnitude
	local projectedPresence = part.Size.Magnitude / math.max(distance, 1)
	local centrality = camera.CFrame.LookVector:Dot((part.Position - camera.CFrame.Position).Unit)
	local visibility = clamp01((centrality + 0.35) / 1.35)
	local proximity = 1 - clamp01(distance / CONFIG.PerceptualRange)
	return clamp01(projectedPresence * 0.55 + visibility * 0.25 + proximity * 0.2)
end

local function buildArtisticSignature()
	if not CONFIG.EnableProprietaryEngine then
		return
	end
	local signature = {}
	local count = 0
	for _, item in ipairs(Workspace:GetDescendants()) do
		if count >= CONFIG.SignatureSampleSize then
			break
		end
		if item:IsA("BasePart") and item.Transparency < 1 then
			local saturation, brightness, warmth = colorMetrics(item.Color)
			local material = tostring(item.Material)
			signature[material] = signature[material] or {count = 0, saturation = 0, brightness = 0, warmth = 0}
			local bucket = signature[material]
			bucket.count += 1
			bucket.saturation += saturation
			bucket.brightness += brightness
			bucket.warmth += warmth
			count += 1
		end
	end
	for _, bucket in pairs(signature) do
		bucket.saturation /= bucket.count
		bucket.brightness /= bucket.count
		bucket.warmth /= bucket.count
	end
	engine.signature = signature
	engine.lastProfileUpdate = os.clock()
end

local function getContextualIntent(part, profile, keywordProfile)
	local zone = getZoneKey(part)
	local zoneName = lower(zone)
	local intent = keywordProfile and 0.86 or 0.42
	if string.find(zoneName, "interior", 1, true) or string.find(zoneName, "room", 1, true) or string.find(zoneName, "cave", 1, true) then
		intent += 0.08
	end
	if string.find(zoneName, "forest", 1, true) or string.find(zoneName, "nature", 1, true) then
		intent += part.Material == Enum.Material.Grass and 0.1 or 0
	end
	if string.find(zoneName, "city", 1, true) or string.find(zoneName, "industrial", 1, true) then
		intent += part.Material == Enum.Material.Metal and 0.1 or 0
	end
	local priority = getPerceptualPriority(part)
	engine.zoneMemory[zone] = (engine.zoneMemory[zone] or 0) + priority * 0.01
	return clamp01(intent), priority, zone
end

local function inferSceneIntent()
	if not CONFIG.EnableSceneInterpretation then
		return
	end
	local manualStyle = getManualStyle()
	local sampleCount = 0
	local saturationTotal = 0
	local brightnessTotal = 0
	local warmthTotal = 0
	local neonCount = 0
	local materialCount = 0
	local recognizedMaterials = 0
	local styleVotes = {stylized = 0, realistic = 0, cinematic = 0}
	for _, item in ipairs(Workspace:GetDescendants()) do
		if sampleCount >= CONFIG.SceneSampleSize then
			break
		end
		if item:IsA("BasePart") and item.Transparency < 1 then
			local saturation, brightness, warmth = colorMetrics(item.Color)
			saturationTotal += saturation
			brightnessTotal += brightness
			warmthTotal += warmth
			materialCount += 1
			if materialProfiles[item.Material] then
				recognizedMaterials += 1
			end
			if item.Material == Enum.Material.Neon then
				neonCount += 1
			end
			local name = lower(item:GetFullName())
			for keyword, stylized in pairs(styleKeywords) do
				if string.find(name, keyword, 1, true) then
					if stylized == true then
						styleVotes.stylized += 1
					else
						styleVotes.realistic += 1
					end
				end
			end
			sampleCount += 1
		end
	end
	if sampleCount == 0 then
		return
	end
	scene.averageSaturation = saturationTotal / sampleCount
	scene.averageBrightness = brightnessTotal / sampleCount
	scene.warmth = warmthTotal / sampleCount
	scene.neonRatio = neonCount / sampleCount
	scene.materialConfidence = clamp01(recognizedMaterials / math.max(materialCount, 1))
	local existingContrast = math.abs(Lighting.Brightness - 2)
	local style = manualStyle
	if not style then
		if styleVotes.stylized >= 4 and styleVotes.stylized > styleVotes.realistic then
			style = "stylized"
		elseif styleVotes.realistic >= 4 and styleVotes.realistic > styleVotes.stylized then
			style = "realistic"
		elseif scene.averageSaturation > 0.48 or scene.neonRatio > 0.08 then
			style = "stylized"
		elseif scene.averageSaturation < 0.23 and existingContrast > 0.55 then
			style = "cinematic"
		else
			style = "balanced"
		end
	end
	scene.style = style
	scene.styleConfidence = manualStyle and 1 or clamp01(0.35 + math.abs(scene.averageSaturation - 0.32) * 1.5 + math.max(styleVotes.stylized, styleVotes.realistic) / math.max(sampleCount, 1))	
	if style == "stylized" then
		scene.correctionStrength = 0.1
		scene.preserve = 0.93
	elseif style == "cinematic" then
		scene.correctionStrength = 0.2
		scene.preserve = 0.84
	elseif style == "realistic" then
		scene.correctionStrength = 0.34
		scene.preserve = 0.72
	else
		scene.correctionStrength = 0.22
		scene.preserve = 0.82
	end
	local preserveAttribute = Workspace:GetAttribute("H4S_PreserveAesthetic")
	if typeof(preserveAttribute) == "number" then
		scene.preserve = clamp01(preserveAttribute)
		scene.correctionStrength *= 1 - scene.preserve * 0.35
	end
	buildArtisticSignature()
	scene.analyzed = true
end

local function getKeywordProfile(part)
	local name = lower(part.Name)
	local selected
	for keyword, profile in pairs(keywordProfiles) do
		if string.find(name, keyword, 1, true) then
			if not selected or profile.priority > selected.priority then
				selected = profile
			end
		end
	end
	return selected
end

local function isEligible(part)
	return part:IsA("BasePart") and part.Transparency < 1 and part.Size.Magnitude > 0.15
end

local function shouldPreserve(part)
	return part:GetAttribute("H4S_KeepMaterial") == true
		or part:GetAttribute("H4S_Preserve") == true
		or CollectionService:HasTag(part, "H4S_KeepMaterial")
		or CollectionService:HasTag(part, "H4S_Preserve")
end

local function getCorrectionNeed(part, profile, keywordProfile)
	local saturation, brightness = colorMetrics(part.Color)
	local targetSaturation = profile and select(1, colorMetrics(profile.color)) or saturation
	local colorMismatch = profile and (math.abs(saturation - targetSaturation) * 0.55 + math.abs(brightness - select(2, colorMetrics(profile.color))) * 0.45) or 0
	local materialMismatch = keywordProfile and (part.Material == keywordProfile.material and 0 or 0.9) or 0
	local reflectanceMismatch = profile and math.abs(part.Reflectance - profile.reflectance) or 0
	local need = colorMismatch * 0.55 + materialMismatch * 0.28 + reflectanceMismatch * 0.17
	local signature = engine.signature[tostring(part.Material)]
	if signature then
		local signatureDeviation = math.abs(saturation - signature.saturation) * 0.35
			+ math.abs(brightness - signature.brightness) * 0.35
			+ math.abs(select(3, colorMetrics(part.Color)) - signature.warmth) * 0.3
		need += signatureDeviation * 0.12
	end
	local intent, priority, zone = getContextualIntent(part, profile, keywordProfile)
	engine.priorityMemory[part] = priority
	engine.zoneMemory[zone] = (engine.zoneMemory[zone] or 0) + intent * 0.005
	need *= (0.42 + priority * 0.58) * (0.72 + intent * 0.28)
	if part.Material == Enum.Material.Neon or part.Material == Enum.Material.Glass then
		need *= scene.style == "stylized" and 0.3 or 0.7
	end
	return clamp01(need)
end

local function applyMaterialIntelligence(part)
	if not CONFIG.EnableMaterialIntelligence or not isEligible(part) or shouldPreserve(part) then
		return
	end
	local original = tracked[part]
	if not original then
		original = {
			baseColor = part.Color,
			baseMaterial = part.Material,
			baseReflectance = part.Reflectance,
			baseTransparency = part.Transparency,
			phase = math.random() * math.pi * 2,
			lastPosition = part.Position,
			profile = materialProfiles[part.Material],
			keywordProfile = getKeywordProfile(part),
			animated = false,
		}
		original.profile = original.keywordProfile or original.profile
		tracked[part] = original
	end
	local profile = original.profile
	local keywordProfile = original.keywordProfile
	if not profile and not keywordProfile then
		return
	end
	local targetColor = (keywordProfile and keywordProfile.color) or (profile and profile.color) or original.baseColor
	local targetMaterial = keywordProfile and keywordProfile.material or original.baseMaterial
	local need = getCorrectionNeed(part, profile, keywordProfile)
	local keywordBoost = keywordProfile and 0.22 or 0
	local strength = clamp01(scene.correctionStrength * (0.35 + need * 1.1) + keywordBoost)
	strength *= 1 - scene.preserve * 0.28
	if part:GetAttribute("H4S_ForceRealism") == true or CollectionService:HasTag(part, "H4S_ForceRealism") then
		strength = math.max(strength, 0.7)
	end
	local customColor = part:GetAttribute("H4S_CustomColor")
	if typeof(customColor) == "Color3" then
		targetColor = customColor
	end
	part.Color = original.baseColor:Lerp(targetColor, strength * (1 - CONFIG.PreserveOriginalColor * 0.5))
	if keywordProfile and strength > 0.28 then
		part.Material = targetMaterial
	elseif not keywordProfile and strength > 0.6 then
		part.Material = original.baseMaterial
	end
	local targetReflectance = profile and profile.reflectance or original.baseReflectance
	part.Reflectance = math.clamp(original.baseReflectance + (targetReflectance - original.baseReflectance) * strength * 0.72, 0, 0.92)
	if targetMaterial == Enum.Material.Glass and original.baseTransparency < 0.45 then
		part.Transparency = math.max(original.baseTransparency, 0.06 * strength)
	end
	original.animated = part.Material == Enum.Material.Neon or part.Material == Enum.Material.Water
	if original.animated and not animatedSet[part] and #updateQueue < CONFIG.MaxAnimatedParts then
		animatedSet[part] = true
		updateQueue[#updateQueue + 1] = part
	end
end

local scanCursor = 1
local worldParts = {}
local function rebuildWorldList()
	worldParts = {}
	for _, item in ipairs(Workspace:GetDescendants()) do
		if isEligible(item) then
			worldParts[#worldParts + 1] = item
			if #worldParts >= CONFIG.MaxTrackedParts then
				break
			end
		end
	end
	scanCursor = 1
end

local function processScanBatch()
	if #worldParts == 0 then
		return
	end
	local combinedQuality = math.min(reconstruction.quality, engine.hardware.cpuQuality)
	local budget = math.max(48, math.floor(CONFIG.ScanBatchSize * (0.5 + combinedQuality * 0.5)))
	local processed = 0
	while processed < budget and scanCursor <= #worldParts do
		local part = worldParts[scanCursor]
		if part and part.Parent then
			applyMaterialIntelligence(part)
		end
		scanCursor += 1
		processed += 1
	end
	if scanCursor > #worldParts then
		scanCursor = 1
		for part in pairs(tracked) do
			if not part.Parent then
				tracked[part] = nil
			end
		end
	end
end

local function getClockData()
	local minutes = Lighting:GetMinutesAfterMidnight()
	local normalized = (minutes % 1440) / 1440
	local sunHeight = math.sin((normalized - 0.25) * math.pi * 2)
	local daylight = clamp01((sunHeight + 0.22) / 1.22)
	return normalized, daylight
end

local function updateAtmosphere(daylight, normalized)
	if not CONFIG.EnableAdaptiveAtmosphere then
		return
	end
	local night = 1 - daylight
	local styleFactor = scene.style == "stylized" and 0.55 or 1
	local haze = (0.7 + night * 1.08) * styleFactor
	local density = (0.19 + night * 0.09) * styleFactor
	local glare = 0.09 + daylight * 0.16
	local skyColor = Color3.fromRGB(198, 213, 231):Lerp(Color3.fromRGB(42, 53, 77), night * 0.72)
	local decayColor = Color3.fromRGB(97, 111, 129):Lerp(Color3.fromRGB(25, 31, 50), night * 0.68)
	atmosphere.Haze = haze
	atmosphere.Density = density
	atmosphere.Glare = glare
	atmosphere.Color = skyColor
	atmosphere.Decay = decayColor
	colorGrade.TintColor = Color3.fromRGB(255, 247, 231):Lerp(Color3.fromRGB(190, 211, 255), night * 0.86)
	colorGrade.Saturation = scene.style == "stylized" and 0.025 or (-0.035 + daylight * 0.05)
	colorGrade.Contrast = (scene.style == "cinematic" and 0.18 or 0.11) + daylight * 0.065
	local quality = reconstruction.quality
	bloom.Intensity = CONFIG.EnableBloom and (0.07 + daylight * 0.1 + scene.neonRatio * 0.22) * (0.7 + quality * 0.3) or 0
	bloom.Size = 18 + math.floor(quality * 10)
	sunRays.Intensity = CONFIG.EnableSunRays and (0.012 + daylight * 0.06) * (0.72 + quality * 0.28) or 0
	Lighting.Brightness = CONFIG.NightBrightness + daylight * (CONFIG.DayBrightness - CONFIG.NightBrightness)
	if normalized > 0.79 or normalized < 0.21 then
		Lighting.OutdoorAmbient = Color3.fromRGB(63, 70, 87)
	else
		Lighting.OutdoorAmbient = Color3.fromRGB(104, 112, 122)
	end
end

local function updateExposure()
	if not CONFIG.EnableDynamicExposure or not camera then
		return
	end
	local _, daylight = getClockData()
	local origin = camera.CFrame.Position
	local direction = camera.CFrame.LookVector * 180
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {player.Character}
	local hit = Workspace:Raycast(origin, direction, params)
	local obstruction = hit and 1 or 0
	local target = -0.1 + daylight * 0.14 - obstruction * 0.06
	local current = Lighting.ExposureCompensation
	local response = 0.045 * (0.72 + reconstruction.quality * 0.28)
	Lighting.ExposureCompensation = current + (target - current) * response
	if CONFIG.EnableCinematicDepth and scene.style ~= "stylized" then
		local distance = hit and (hit.Position - origin).Magnitude or 140
		depthOfField.FocusDistance = math.clamp(distance, 30, 140)
		depthOfField.Enabled = camera.FieldOfView <= 78 and reconstruction.quality > 0.64
	else
		depthOfField.Enabled = false
	end
end

local function updateSurfaceResponse(now)
	if not CONFIG.EnableSurfaceResponse then
		return
	end
	for index = #updateQueue, 1, -1 do
		local part = updateQueue[index]
		local data = tracked[part]
		if not part or not part.Parent or not data then
			animatedSet[part] = nil
			table.remove(updateQueue, index)
		else
			if part.Material == Enum.Material.Neon then
				local pulse = 0.985 + math.sin(now * 1.6 + data.phase) * 0.015
				part.Color = part.Color:Lerp(Color3.new(1, 1, 1), math.max(0, pulse - 0.985) * 1.2)
			elseif part.Material == Enum.Material.Water then
				part.Reflectance = math.clamp(0.64 + math.sin(now * 0.55 + data.phase) * 0.025, 0, 0.92)
			end
		end
	end
end

local elapsed = 0
local scanElapsed = CONFIG.ScanInterval
local materialElapsed = 0
local nativeElapsed = 0
local lastIntentRefresh = 0

inferSceneIntent()
rebuildWorldList()
scanNativeRenderObjects()

connections[#connections + 1] = RunService.RenderStepped:Connect(function(deltaTime)
	updateReconstruction(deltaTime)
	local cpuStart = os.clock()
	elapsed += deltaTime
	scanElapsed += deltaTime
	materialElapsed += deltaTime
	nativeElapsed += deltaTime
	if scanElapsed >= CONFIG.ScanInterval then
		scanElapsed = 0
		rebuildWorldList()
	end
	if materialElapsed >= CONFIG.MaterialUpdateInterval then
		materialElapsed = 0
		processScanBatch()
		updateSurfaceResponse(os.clock())
	end
	if nativeElapsed >= 0.3 then
		nativeElapsed = 0
		updateNativeBudgets()
	end
	if elapsed >= CONFIG.UpdateInterval then
		elapsed = 0
		if os.clock() - lastIntentRefresh > 12 then
			lastIntentRefresh = os.clock()
			inferSceneIntent()
		end
		local normalized, daylight = getClockData()
			updateAtmosphere(daylight, normalized)
			updateExposure()
		end
		updateCPUQuality(os.clock() - cpuStart)
	end)

connections[#connections + 1] = player.CharacterAdded:Connect(function()
	task.wait(1)
	camera = Workspace.CurrentCamera
	inferSceneIntent()
	rebuildWorldList()
	scanNativeRenderObjects()
end)

connections[#connections + 1] = Workspace.DescendantAdded:Connect(function(descendant)
	if isEligible(descendant) then
		worldParts[#worldParts + 1] = descendant
		if #worldParts > CONFIG.MaxTrackedParts then
			table.remove(worldParts, 1)
		end
		task.defer(applyMaterialIntelligence, descendant)
	end
	if descendant:IsA("PointLight") or descendant:IsA("SpotLight") or descendant:IsA("SurfaceLight") or descendant:IsA("ParticleEmitter") then
		scanNativeRenderObjects()
	end
end)

connections[#connections + 1] = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	camera = Workspace.CurrentCamera
end)
