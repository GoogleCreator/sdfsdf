local jj = false
local tweening = false
local prem = false
local hives = workspace.Honeycombs:GetChildren()

for i = #hives, 1, -1 do
	local v = hives[i]
	if v.Owner.Value == nil then
		game:GetService("ReplicatedStorage").Events.ClaimHive:FireServer(v.HiveID.Value)
	end
end

print("All hives processed.")

local floatpad = Instance.new("Part", game:GetService("Workspace"))
floatpad.CanCollide = false
floatpad.Anchored = true
floatpad.Transparency = 1
floatpad.Name = "daddy"

local tog = {
	Farm = false,
	Dig = false,
	Field = "Ant Field",
	Tokens = false,
	TokenSpeedT = true,
	TokenSpeed = 50,
	Convert = false,
	Converting = false,
	Sprinklers = false,
	Mob = false,
    TweenSpeed = 7.5,
    Float = false,
}

--// Vars
local tp = false
local player = game.Players.LocalPlayer
local Fields = workspace:FindFirstChild("FlowerZones"):GetChildren()

function rtsg() tab = game.ReplicatedStorage.Events.RetrievePlayerStats:InvokeServer() return tab end

function makeSprinklers()
	sprinkler = rtsg().EquippedSprinkler
	e = 1

	if sprinkler == "Basic Sprinkler" or sprinkler == "The Supreme Saturator" then
		e = 1
	elseif sprinkler == "Silver Soakers" then
		e = 2
	elseif sprinkler == "Golden Gushers" then
		e = 3
	elseif sprinkler == "Diamond Drenchers" then
		e = 4
	end

	for i = 1, e do
		k = player.Character:WaitForChild("Humanoid").JumpPower

		if e ~= 1 then
			player.Character:WaitForChild("Humanoid").JumpPower = 70
			player.Character:WaitForChild("Humanoid").Jump = true
			task.wait(.2)
		end

		game.ReplicatedStorage.Events.PlayerActivesCommand:FireServer({
			["Name"] = "Sprinkler Builder"
		})

		if e ~= 1 then
			player.Character:WaitForChild("Humanoid").JumpPower = k
			task.wait(1)
		end
	end
end

function avoidMob()
	for i,v in next, game:GetService("Workspace").Monsters:GetChildren() do
		if v:FindFirstChild("Head") then
			if tog.Mob and (v.Head.Position-player.Character.HumanoidRootPart.Position).magnitude < 30 and player.Character:WaitForChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Freefall then
				player.Character:WaitForChild("Humanoid").Jump = true
			end
		end
	end
end

local function getFlowerZoneNames()
	local names = {}
	for _, v in ipairs(Fields) do
		if v.Name == "Blue Brick Field" or v.Name == "Red Brick Field" or v.Name == "Mixed Brick Field" or v.Name == "White Brick Field" then
			warn("Blacklisted dumbass brick fields! :)")
		else
			table.insert(names, v.Name)
			v.Size += Vector3.new(0, 70, 0)
			v.Color = Color3.fromRGB(255,0,0)
			v.CastShadow = false
		end
	end

	table.sort(names)

	return names
end

local fieldNames = getFlowerZoneNames()

local function farm()
	if tog.Farm and not tog.Converting then
		local field = workspace.FlowerZones:FindFirstChild(tog.Field)
		local fieldPosition = field.Position
		local fieldSize = field.Size
		local playerPosition = player.Character.HumanoidRootPart.Position

		local fieldMin = fieldPosition - fieldSize / 2
		local fieldMax = fieldPosition + fieldSize / 2

		if playerPosition.X >= fieldMin.X and playerPosition.X <= fieldMax.X and
			playerPosition.Y >= fieldMin.Y and playerPosition.Y <= fieldMax.Y and
			playerPosition.Z >= fieldMin.Z and playerPosition.Z <= fieldMax.Z then
			tp = false
			task.wait(.5)
			if tog.Sprinklers and not jj then
				makeSprinklers()
				jj = true
			end
		else
			local tween = game:GetService("TweenService"):Create(
				player.Character.HumanoidRootPart, 
				TweenInfo.new(tog.TweenSpeed, Enum.EasingStyle.Linear),
				{CFrame = field.CFrame + Vector3.new(0, 2, 0)}
			)

            if not tweening then
		        tween:Play()
                tweening = true
                tog.Float = true
                tween.Completed:Wait()
                tweening = false
                tog.Float = false
            end
		end
	end
end

local function autosell()
	local core = player.CoreStats
	local capacity = core.Capacity.Value
	local pollen = core.Pollen.Value
	local SpawnPos = player.SpawnPos.Value
	local buttonText = player.PlayerGui.ScreenGui.ActivateButton.TextBox

	if tog.Convert and pollen >= capacity then
		tog.Converting = true
		local TweenService = game:GetService("TweenService")
		local target = CFrame.new(SpawnPos.Position + Vector3.new(0, 2, 9))
		local tween = game:GetService("TweenService"):Create(
			player.Character.HumanoidRootPart, 
			TweenInfo.new(tog.TweenSpeed, Enum.EasingStyle.Linear), 
			{CFrame = target}
		)

        if not tweening then
		    tween:Play()
            tweening = true
            tog.Float = true
            player.Character.Humanoid.BodyTypeScale.Value = 0
            tween.Completed:Wait()
            tweening = false
            tog.Float = false
        end
		task.wait(.3)

		if buttonText.Text ~= "Stop Making Honey" then
			game:GetService("ReplicatedStorage").Events.PlayerHiveCommand:FireServer("ToggleHoneyMaking")
			dg = true
		end
	end
end

local function isPointInRegion3(point, region)
	return point.x >= region.CFrame.Position.x - region.Size.x / 2 and
		point.x <= region.CFrame.Position.x + region.Size.x / 2 and
		point.y >= region.CFrame.Position.y - region.Size.y / 2 and
		point.y <= region.CFrame.Position.y + region.Size.y / 2 and
		point.z >= region.CFrame.Position.z - region.Size.z / 2 and
		point.z <= region.CFrame.Position.z + region.Size.z / 2
end

local function getCurrentField()
	local character = player.Character
	if not character then return nil end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end

	local position = humanoidRootPart.Position
	for _, field in ipairs(workspace.FlowerZones:GetChildren()) do
		if field:IsA("BasePart") then
			local size = field.Size
			local region = Region3.new(field.Position - size / 2, field.Position + size / 2)
			if isPointInRegion3(position, region) then
				return field
			end
		end
	end
	return nil
end

local t = false

local baseWs = game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed

local visitedCoins = {}

local function tokenCollection()
	if tog.Tokens then
		local field = getCurrentField()

		if field then
			local fieldSize = field.Size
			local region = Region3.new(field.Position - fieldSize / 2, field.Position + fieldSize / 2)

			local tokens = workspace.Collectibles:GetChildren()

			if not t then
				for _, v in ipairs(tokens) do
					if v.Name == "C" and v.Transparency ~= 699999988079071 and not tog.Converting then
						if isPointInRegion3(v.Position, region) then
							if not visitedCoins[v] then
								visitedCoins[v] = true 
								player.Character:WaitForChild("Humanoid"):MoveTo(v.Position)
								player.Character:WaitForChild("Humanoid").MoveToFinished:Wait()
							end
						end
					end
				end
			end
		end
	end
end

local function dig()
	if tog.Dig then
		game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ToolCollect"):FireServer()
	end
end

local function fetchStickers()
	for i,v in next, workspace.HiddenStickers:GetChildren() do
		v.CanCollide = false
		v.Transparency = 0
		v.CFrame = CFrame.new(game:GetService("Players").LocalPlayer.Character.Head.Position)
	end
end

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/Shaman.lua'))()
local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))();
local Notify = AkaliNotif.Notify;

local Window = Library:Window({
    Text = "Zencros | BSS 🐝 | v1.00"
})

local Tab = Window:Tab({
    Text = "Home"
})

local Tab2 = Window:Tab({
    Text = "Farming"
})

local s1 = Tab2:Section({
    Text = "Farming"
})

local dropdown = s1:Dropdown({
    Text = "Field",
    List = fieldNames,
    Callback = function(v)
        tog.Field = v
    end
})

s1:Toggle({
    Text = "Farm ⚙️",
    Default = false,
    Callback = function(v)
        tog.Farm = v
    end
})

s1:Toggle({
    Text = "Auto Dig",
    Default = false,
    Callback = function(v)
        tog.Dig = v
    end
})

s1:Toggle({
    Text = "Auto Convert",
    Default = false,
    Callback = function(v)
        tog.Convert = v
    end
})

s1:Toggle({
    Text = "Auto Collect Tokens",
    Default = false,
    Callback = function(v)
        tog.Tokens = v
    end
})

s1:Toggle({
    Text = "Auto Sprinkler",
    Default = true,
    Callback = function(v)
        tog.Sprinklers = v

	    if not v then
		    jj = false
	    end
    end
})

s1:Toggle({
    Text = "Avoid Mobs",
    Default = false,
    Callback = function(v)
        tog.Mob = v
    end
})

local s2 = Tab2:Section({
    Text = "Dispensers",
    Side = "Right"
})

local s3 = Tab2:Section({
    Text = "Beesmas 🎁"
})

local s4 = Tab2:Section({
    Text = "Settings ⚙️",
    Side = "Right"
})

s4:Toggle({
    Text = "Token Collection Speed",
    Default = false,
    Callback = function(v)
        tog.TokenSpeedT = v
    end
})

s4:Slider({
    Text = "Tween Speed",
    Default = 7.5,
    Minimum = 5,
    Maximum = 10,
    Callback = function(v)
        tog.TweenSpeed = v
    end
})

local Tab3 = Window:Tab({
    Text = "Combat"
})

local Tab5 = Window:Tab({
    Text = "Zencros Premium ⭐"
})


--// initiate

spawn(function()
    tog.Float = false
	--Afk
	local vu = game:GetService("VirtualUser")
	game:GetService("Players").LocalPlayer.Idled:connect(function() vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)task.wait(1)vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	end)

    game:GetService("RunService").Heartbeat:Connect(function()
if tog.Float then
    player.Character.Humanoid.BodyTypeScale.Value = 0 
    floatpad.CanCollide = true 
    floatpad.CFrame = CFrame.new(
        player.Character.HumanoidRootPart.Position.X,
        player.Character.HumanoidRootPart.Position.Y - 3.75,
        player.Character.HumanoidRootPart.Position.Z
    )
else
    floatpad.CanCollide = false
end
    end)

	coroutine.wrap(function()
		while task.wait() do
			dig()
			farm()
			autosell()
			avoidMob()

			if tog.Tokens then
				if tog.TokenSpeedT then
					player.Character:WaitForChild("Humanoid").WalkSpeed = 70
				else
					player.Character:WaitForChild("Humanoid").WalkSpeed = baseWs
				end
			end

			local core = player.CoreStats
			local capacity = core.Capacity.Value
			local pollen = core.Pollen.Value
			local SpawnPos = player.SpawnPos.Value

			if pollen == 0 and tog.Converting then
				tog.Converting = false
				jj = false
			end

		end
	end)()

	while task.wait() do
		tokenCollection()
	end
end)

spawn(function()
	player.CharacterAdded:Connect(function()
		while task.wait() do
			tokenCollection()
		end
	end)
end)

--//extra

local function premiumIdentifier()
    try = ""
    if prem == false then
    try = "❌"
    else
    try = "✅"
    end
    return try
end

Notify({
Description = "Welcome, "..player.Name.."!";
Title = "Premium: "..premiumIdentifier();
Duration = 5;
});

local fieldDecos = workspace:FindFirstChild("FieldDecos")

if fieldDecos then
	for _, part in ipairs(fieldDecos:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
			part.Transparency = part.Transparency < 0.5 and 0.5 or part.Transparency
			task.wait()
		end
	end
end

local decorations = workspace:FindFirstChild("Decorations")

if decorations then
	for _, part in ipairs(decorations:GetDescendants()) do
		if part:IsA("BasePart") and (part.Parent.Name == "Bush" or part.Parent.Name == "Blue Flower") then
			part.CanCollide = false
			part.Transparency = part.Transparency < 0.5 and 0.5 or part.Transparency
			task.wait()
		end
	end
end

local miscDecorations = workspace:FindFirstChild("Decorations") and workspace.Decorations:FindFirstChild("Misc")

if miscDecorations then
	for _, v in ipairs(miscDecorations:GetDescendants()) do
		if v.Parent.Name == "Mushroom" then
			v.CanCollide = false
			v.Transparency = 0.5
		end
	end
end
