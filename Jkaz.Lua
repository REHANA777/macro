local player = game.Players.LocalPlayer
local Lighting = game:GetService("Lighting")

-- STATE
local recording = false
local playing = false
local path = {}
local recordInterval = 0.15

-- TOGGLES
local tpEnabled = true
local lowPower = false

-- CHECKPOINT
local checkpoint = nil

-- CHARACTER
local function getChar()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local hrp = char:WaitForChild("HumanoidRootPart")
	return char, hum, hrp
end

-- DETECT
local function detectAndHold()
	local _, _, hrp = getChar()

	for _, p in pairs(workspace:GetDescendants()) do
		if p:IsA("ProximityPrompt") then
			local part = p.Parent
			if part and part:IsA("BasePart") then
				if (part.Position - hrp.Position).Magnitude < 10 then
					fireproximityprompt(p, p.HoldDuration)
				end
			end
		end
	end
end

-- RECORD
local function startRecord()
	path = {}

	task.spawn(function()
		while recording do
			local _, _, hrp = getChar()
			table.insert(path, hrp.Position)
			task.wait(recordInterval)
		end
	end)
end

-- WALK
local function walkTo(pos)
	local _, hum = getChar()

	local start = tick()
	while (hum.Parent.HumanoidRootPart.Position - pos).Magnitude > 2 do
		if tick() - start > 2 then break end
		hum:MoveTo(pos)
		task.wait(0.1)
	end
end

-- TP
local function tp(pos)
	local _, _, hrp = getChar()
	hrp.CFrame = CFrame.new(pos)
end

-- DEFAULT TP POINTS (3 FIX + 1 CHECKPOINT DINAMIS)
local tpPoints = {
	Vector3.new(-197.9, 17.4, -235.0),
	Vector3.new(-134.6, 12.8, -233.0),
	Vector3.new(-257.6, 14.5, -236.9),
}

-- GUI (DIBESARIN)
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,420,0,320)
frame.Position = UDim2.new(0,20,0,100)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true

-- BUTTON
local function btn(txt,y)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(1,-20,0,35)
	b.Position = UDim2.new(0,10,0,y)
	b.Text = txt
	b.BackgroundColor3 = Color3.fromRGB(70,70,70)
	b.TextColor3 = Color3.new(1,1,1)
	return b
end

local recBtn = btn("RECORD",10)
local playBtn = btn("PLAY",50)
local delBtn = btn("DELETE",90)
local tpBtn = btn("TP ON/OFF",130)
local cpBtn = btn("SET CHECKPOINT",170)
local delCpBtn = btn("DELETE CHECKPOINT",210)
local batBtn = btn("HEMAT OFF",250)

-- RECORD
recBtn.MouseButton1Click:Connect(function()
	recording = not recording
	recBtn.Text = recording and "STOP" or "RECORD"
	if recording then startRecord() end
end)

-- PLAY
playBtn.MouseButton1Click:Connect(function()
	playing = not playing
	playBtn.Text = playing and "STOP" or "PLAY"

	if playing then
		task.spawn(function()
			while playing do

				-- MACRO
				for _,pos in ipairs(path) do
					if not playing then break end
					walkTo(pos)
					detectAndHold()
				end

				-- TP FINAL (STATIC + CHECKPOINT)
				if tpEnabled then
					for _,pos in ipairs(tpPoints) do
						if not playing then break end
						tp(pos)
						task.wait(0.8)
					end

					if checkpoint then
						tp(checkpoint)
						task.wait(1)
					end
				end

			end
		end)
	end
end)

-- DELETE RECORD
delBtn.MouseButton1Click:Connect(function()
	recording = false
	playing = false
	path = {}

	recBtn.Text = "RECORD"
	playBtn.Text = "PLAY"
end)

-- TP TOGGLE
tpBtn.MouseButton1Click:Connect(function()
	tpEnabled = not tpEnabled
	tpBtn.Text = tpEnabled and "TP ON" or "TP OFF"
end)

-- CHECKPOINT SET
cpBtn.MouseButton1Click:Connect(function()
	local _, _, hrp = getChar()
	checkpoint = hrp.Position
	cpBtn.Text = "CHECKPOINT SET"
end)

-- DELETE CHECKPOINT
delCpBtn.MouseButton1Click:Connect(function()
	checkpoint = nil
	cpBtn.Text = "SET CHECKPOINT"
end)

-- HEMAT MODE
batBtn.MouseButton1Click:Connect(function()
	lowPower = not lowPower
	batBtn.Text = lowPower and "HEMAT ON" or "HEMAT OFF"

	if lowPower then
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 100
	else
		Lighting.GlobalShadows = true
		Lighting.FogEnd = 100000
	end
end)

-- PASSIVE
task.spawn(function()
	while true do
		detectAndHold()
		task.wait(0.3)
	end
end)
