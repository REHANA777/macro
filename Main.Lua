local player = game.Players.LocalPlayer

-- STATE
local recording = false
local playing = false
local path = {}
local recordInterval = 0.15

-- CHARACTER
local function getChar()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local hrp = char:WaitForChild("HumanoidRootPart")
	return char, hum, hrp
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
	local _, hum, hrp = getChar()

	while (hrp.Position - pos).Magnitude > 2 do
		hum:MoveTo(pos)
		task.wait(0.1)
	end
end

-- TELEPORT
local function tp(pos)
	local _, _, hrp = getChar()
	hrp.CFrame = CFrame.new(pos)
end

-- TP END POINTS
local tpPoints = {
	Vector3.new(-197.9,17.4,-235.0),
	Vector3.new(-134.6,12.8,-233.0),
	Vector3.new(-257.6,14.5,-236.9)
}

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,250,0,160)
frame.Position = UDim2.new(0,20,0,100)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true

local function btn(txt,y)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(1,-20,0,40)
	b.Position = UDim2.new(0,10,0,y)
	b.Text = txt
	b.BackgroundColor3 = Color3.fromRGB(70,70,70)
	b.TextColor3 = Color3.new(1,1,1)
	return b
end

local recBtn = btn("RECORD",10)
local playBtn = btn("PLAY",60)
local delBtn = btn("DELETE",110)

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

				-- REPLAY MACRO
				for _,pos in ipairs(path) do
					if not playing then break end
					walkTo(pos)
				end

				-- 🔥 END TP (3 TITIK)
				for _,pos in ipairs(tpPoints) do
					if not playing then break end
					tp(pos)
					task.wait(0.5)
				end

			end
		end)
	end
end)

-- DELETE
delBtn.MouseButton1Click:Connect(function()
	recording = false
	playing = false
	path = {}

	recBtn.Text = "RECORD"
	playBtn.Text = "PLAY"
end)
