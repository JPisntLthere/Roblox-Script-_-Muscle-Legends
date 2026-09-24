-- Clean up any existing UI or background threads from previous executions
if getgenv().MuscleLegendsCleanup then
    getgenv().MuscleLegendsCleanup()
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

getgenv().AutoLiftRunning = false
getgenv().InfiniteJumpEnabled = false

-- Create ScreenGui (Using PlayerGui to ensure visibility)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MidnightPurpleMuscleGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Container Frame (Expanded height to 255 to properly fit all new elements)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 255)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 35) -- Deep midnight purple
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCornerMain = Instance.new("UICorner")
uiCornerMain.CornerRadius = UDim.new(0, 8)
uiCornerMain.Parent = mainFrame

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(200, 160, 255) -- Soft lavender accent
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "MUSCLE LEGENDS"
titleLabel.Parent = mainFrame

-- Auto-Lift Toggle Button (Y: 40)
local liftBtn = Instance.new("TextButton")
liftBtn.Size = UDim2.new(1, -20, 0, 30)
liftBtn.Position = UDim2.new(0, 10, 0, 40)
liftBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
liftBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
liftBtn.TextSize = 13
liftBtn.Font = Enum.Font.GothamSemibold
liftBtn.Text = "Auto-Lift: OFF"
liftBtn.Parent = mainFrame

local uiCornerLift = Instance.new("UICorner")
uiCornerLift.CornerRadius = UDim.new(0, 6)
uiCornerLift.Parent = liftBtn

-- Speed TextBox / Adjuster (Y: 78)
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -20, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 78)
speedBox.BackgroundColor3 = Color3.fromRGB(35, 28, 50)
speedBox.TextColor3 = Color3.fromRGB(240, 240, 240)
speedBox.PlaceholderColor3 = Color3.fromRGB(150, 130, 180)
speedBox.PlaceholderText = "Speed (Max 200)"
speedBox.TextSize = 12
speedBox.Font = Enum.Font.GothamSemibold
speedBox.Text = ""
speedBox.ClearTextOnFocus = false
speedBox.Parent = mainFrame

local uiCornerSpeed = Instance.new("UICorner")
uiCornerSpeed.CornerRadius = UDim.new(0, 6)
uiCornerSpeed.Parent = speedBox

-- Infinite Jump Toggle Button (Y: 116)
local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(1, -20, 0, 30)
jumpBtn.Position = UDim2.new(0, 10, 0, 116)
jumpBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
jumpBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
jumpBtn.TextSize = 13
jumpBtn.Font = Enum.Font.GothamSemibold
jumpBtn.Text = "Infinite Jump: OFF"
jumpBtn.Parent = mainFrame

local uiCornerJump = Instance.new("UICorner")
uiCornerJump.CornerRadius = UDim.new(0, 6)
uiCornerJump.Parent = jumpBtn

-- Kill / Destroy Button (Y: 165 - slightly spaced out for clear separation)
local killBtn = Instance.new("TextButton")
killBtn.Size = UDim2.new(1, -20, 0, 30)
killBtn.Position = UDim2.new(0, 10, 0, 165)
killBtn.BackgroundColor3 = Color3.fromRGB(65, 30, 45) -- Dark reddish purple for close/kill
killBtn.TextColor3 = Color3.fromRGB(255, 180, 180)
killBtn.TextSize = 13
killBtn.Font = Enum.Font.GothamSemibold
killBtn.Text = "Kill UI & Stop"
killBtn.Parent = mainFrame

local uiCornerKill = Instance.new("UICorner")
uiCornerKill.CornerRadius = UDim.new(0, 6)
uiCornerKill.Parent = killBtn

-- Function to find and equip a dumbbell from the backpack
local function equipDumbbell()
    local character = localPlayer.Character
    local backpack = localPlayer:FindFirstChildOfClass("Backpack")
    
    if character and character:FindFirstChildOfClass("Tool") then
        return
    end
    
    if backpack and character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    local nameLower = string.lower(item.Name)
                    if string.find(nameLower, "dumbbell") or string.find(nameLower, "weight") then
                        humanoid:EquipTool(item)
                        break
                    end
                end
            end
            
            if not character:FindFirstChildOfClass("Tool") then
                for _, item in ipairs(backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        humanoid:EquipTool(item)
                        break
                    end
                end
            end
        end
    end
end

-- Handle Auto-Lift State Change
liftBtn.MouseButton1Click:Connect(function()
    getgenv().AutoLiftRunning = not getgenv().AutoLiftRunning
    if getgenv().AutoLiftRunning then
        liftBtn.Text = "Auto-Lift: ON"
        liftBtn.BackgroundColor3 = Color3.fromRGB(90, 50, 140)
        equipDumbbell()
    else
        liftBtn.Text = "Auto-Lift: OFF"
        liftBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
    end
end)

-- Handle Speed Input (Capped at 200)
speedBox.FocusLost:Connect(function(enterPressed)
    local val = tonumber(speedBox.Text)
    if val then
        if val > 200 then
            val = 200
            speedBox.Text = "200"
        elseif val < 0 then
            val = 0
            speedBox.Text = "0"
        end
        
        local character = localPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = val
            end
        end
    else
        speedBox.Text = ""
    end
end)

-- Handle Infinite Jump Toggle
jumpBtn.MouseButton1Click:Connect(function()
    getgenv().InfiniteJumpEnabled = not getgenv().InfiniteJumpEnabled
    if getgenv().InfiniteJumpEnabled then
        jumpBtn.Text = "Infinite Jump: ON"
        jumpBtn.BackgroundColor3 = Color3.fromRGB(90, 50, 140)
    else
        jumpBtn.Text = "Infinite Jump: OFF"
        jumpBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
    end
end)

-- Infinite Jump Listener
local jumpConnection = UserInputService.JumpRequest:Connect(function()
    if getgenv().InfiniteJumpEnabled then
        local character = localPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidState.Jumping)
            end
        end
    end
end)

-- Cleanup Function
local activeConnection = true
getgenv().MuscleLegendsCleanup = function()
    activeConnection = false
    getgenv().AutoLiftRunning = false
    getgenv().InfiniteJumpEnabled = false
    if jumpConnection then
        jumpConnection:Disconnect()
    end
    if screenGui then
        screenGui:Destroy()
    end
end

-- Kill Button Action
killBtn.MouseButton1Click:Connect(function()
    getgenv().MuscleLegendsCleanup()
end)

-- Main Background Loop
task.spawn(function()
    while activeConnection do
        local character = localPlayer.Character
        if character then
            if getgenv().AutoLiftRunning then
                local tool = character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then
                    tool:Activate()
                else
                    equipDumbbell()
                end
            end
        end
        task.wait(0.1)
    end
end)