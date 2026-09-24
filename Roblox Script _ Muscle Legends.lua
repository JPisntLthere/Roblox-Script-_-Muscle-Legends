-- Clean up any existing UI or background threads from previous executions
if getgenv().MuscleLegendsCleanup then
    getgenv().MuscleLegendsCleanup()
end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer

getgenv().AutoLiftRunning = false

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MidnightPurpleMuscleGUI"
screenGui.Parent = CoreGui

-- Main Container Frame (Midnight Purple Theme)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 135)
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

-- Auto-Lift Toggle Button
local liftBtn = Instance.new("TextButton")
liftBtn.Size = UDim2.new(1, -20, 0, 35)
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

-- Kill / Destroy Button (Seperate)
local killBtn = Instance.new("TextButton")
killBtn.Size = UDim2.new(1, -20, 0, 35)
killBtn.Position = UDim2.new(0, 10, 0, 85)
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
    
    -- Check if already holding a tool
    if character and character:FindFirstChildOfClass("Tool") then
        return
    end
    
    if backpack and character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    -- Search for "dumbbell" or "weight" in the tool name (case-insensitive)
                    local nameLower = string.lower(item.Name)
                    if string.find(nameLower, "dumbbell") or string.find(nameLower, "weight") then
                        humanoid:EquipTool(item)
                        break
                    end
                end
            end
            
            -- Fallback: If no specific dumbbell is found, just equip the first available tool
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
        liftBtn.BackgroundColor3 = Color3.fromRGB(90, 50, 140) -- Brighter active purple
        equipDumbbell() -- Try to pull out the dumbbell immediately when turned on
    else
        liftBtn.Text = "Auto-Lift: OFF"
        liftBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
    end
end)

-- Cleanup Function
local activeConnection = true
getgenv().MuscleLegendsCleanup = function()
    activeConnection = false
    getgenv().AutoLiftRunning = false
    if screenGui then
        screenGui:Destroy()
    end
end

-- Kill Button Action (Wipes loop and UI completely)
killBtn.MouseButton1Click:Connect(function()
    getgenv().MuscleLegendsCleanup()
end)

-- Main Background Loop
task.spawn(function()
    while activeConnection do
        if getgenv().AutoLiftRunning then
            local character = localPlayer.Character
            if character then
                local tool = character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then
                    tool:Activate()
                else
                    -- If tool somehow got unequipped, try equipping it back
                    equipDumbbell()
                end
            end
        end
        task.wait(0.1)
    end
end)