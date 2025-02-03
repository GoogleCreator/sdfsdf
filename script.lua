local jj = false
local hives = workspace.Honeycombs:GetChildren()

for i = #hives, 1, -1 do
	local v = hives[i]
	if v.Owner.Value == nil then
		game:GetService("ReplicatedStorage").Events.ClaimHive:FireServer(v.HiveID.Value)
	end
end

print("All hives processed.")

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/IScriptCoolThings/Bracket-V2/main/onion.lua"))()

local Window, MainGUI = Library:CreateWindow("Papaya Macros | v1.00")

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
}

local Tab1 = Window:CreateTab("Farms")

local e = Tab1:CreateGroupbox("Farming", "Left")

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
--// socials
local ExampleToggle = e:CreateToggle("Farm Field", function(v)
	tog.Farm = v
end)
ExampleToggle:CreateKeyBind()

local ExampleToggle = e:CreateToggle("Auto Dig", function(v)
	tog.Dig = v
end)
ExampleToggle:CreateKeyBind()

local ExampleToggle = e:CreateToggle("Auto Collect Tokens", function(v)
	tog.Tokens = v
end)
ExampleToggle:CreateKeyBind()

local ExampleToggle = e:CreateToggle("Auto Convert", function(v)
	tog.Convert = v
end)
ExampleToggle:CreateKeyBind()

local ExampleToggle = e:CreateToggle("Auto Sprinkler", function(v)
	tog.Sprinklers = v

    if not v then
        jj = false
    end
end)
ExampleToggle:CreateKeyBind()

local ExampleToggle = e:CreateToggle("Avoid Mobs", function(v)
	tog.Mob = v
end)
ExampleToggle:CreateKeyBind()


local e2 = Tab1:CreateGroupbox("Extra Farms", "Left")


local ExampleToggle = e2:CreateToggle("Farm Snowflakes", function(v)
	
end)
ExampleToggle:CreateKeyBind()


local e3 = Tab1:CreateGroupbox("Field Boosters", "Left")


local ExampleToggle = e3:CreateToggle("Auto Mountain Top Booster", function(v)
	while v and task.wait() do
		game.ReplicatedStorage.Events.ToyEvent:FireServer("Field Booster") 
	end
end)
ExampleToggle:CreateKeyBind()

local ExampleToggle = e3:CreateToggle("Auto Red Field Booster", function(v)
	while v and task.wait() do
		game.ReplicatedStorage.Events.ToyEvent:FireServer("Red Field Booster") 
	end
end)
ExampleToggle:CreateKeyBind()

local ExampleToggle = e3:CreateToggle("Auto Blue Field Booster", function(v)
	while v and task.wait() do
		game.ReplicatedStorage.Events.ToyEvent:FireServer("Blue Field Booster") 
	end
end)
ExampleToggle:CreateKeyBind()


local e4 = Tab1:CreateGroupbox("⚙️ Configuration", "Right")


local ExampleDropdown = e4:CreateDropdown("Field To Farm", fieldNames, function(v)
	tog.Field = v
end)

local ExampleToggle = e4:CreateToggle("Token Collection Speed", function(v)
	tog.TokenSpeedT = v
end)
ExampleToggle:CreateKeyBind()

local ExampleSlider2 = e4:CreateSlider("Token Collection Speed", 50, 70, 60, function(v)
	tog.TokenSpeed = v
end)

--// Misc

--Functions
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
			TweenInfo.new(0, Enum.EasingStyle.Linear), 
			{CFrame = field.CFrame}
		)
        tween:Play()
			task.wait(.5)
        	if tog.Sprinklers and not jj then
		        makeSprinklers()
		        jj = true
	        end
            jj = false
            
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
		local TweenService = game:GetService("TweenService")
		local target = CFrame.new(SpawnPos.Position + Vector3.new(0, 2, 9))
        local tween = game:GetService("TweenService"):Create(
			player.Character.HumanoidRootPart, 
			TweenInfo.new(0, Enum.EasingStyle.Linear), 
			{CFrame = target}
		)
        tween:Play()
		task.wait(1)

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

--// initiate

spawn(function()
	--Afk
	local vu = game:GetService("VirtualUser")
	game:GetService("Players").LocalPlayer.Idled:connect(function() vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)task.wait(1)vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	end)

	coroutine.wrap(function()
    while task.wait() do
		dig()
		farm()
		autosell()
        avoidMob()

		if tog.Tokens then
			if tog.TokenSpeedT then
				player.Character:WaitForChild("Humanoid").WalkSpeed = tog.TokenSpeed
			else
				player.Character:WaitForChild("Humanoid").WalkSpeed = baseWs
			end
		end

		local core = player.CoreStats
		local capacity = core.Capacity.Value
		local pollen = core.Pollen.Value
		local SpawnPos = player.SpawnPos.Value

		if tog.Convert and pollen >= capacity then
			tog.Converting = true
		elseif pollen == 0 and tog.Convert then
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
