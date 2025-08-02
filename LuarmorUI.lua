-- LuArmor Key System UI with API Integration
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- LuArmor Configuration
local SCRIPT_ID = "ff94fa97eae530cd18a209e57d352d3e"
local KEY_LINK = "https://ads.luarmor.net/get_key?for=Build_A_Crypto_Farm-DlxkrNFibHnl"
local SCRIPT_URL = "https://api.luarmor.net/files/v3/loaders/" .. SCRIPT_ID .. ".lua"
-- Removed VALIDATION_URL as we're using GET with parameters

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LuArmorKeySystem"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 420, 0, 320)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add corner radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

-- Add stroke
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 60, 80)
stroke.Thickness = 1
stroke.Parent = mainFrame

-- Header Frame
local headerFrame = Instance.new("Frame")
headerFrame.Name = "HeaderFrame"
headerFrame.Size = UDim2.new(1, 0, 0, 70)
headerFrame.Position = UDim2.new(0, 0, 0, 0)
headerFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
headerFrame.BorderSizePixel = 0
headerFrame.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 15)
headerCorner.Parent = headerFrame

-- Fix header bottom corners
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 15)
headerFix.Position = UDim2.new(0, 0, 1, -15)
headerFix.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
headerFix.BorderSizePixel = 0
headerFix.Parent = headerFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🛡️ Key System"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = headerFrame

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 35, 0, 35)
closeButton.Position = UDim2.new(1, -50, 0, 17.5)
closeButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
closeButton.BorderSizePixel = 0
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = headerFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -40, 0, 25)
statusLabel.Position = UDim2.new(0, 20, 0, 90)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Enter your key below or click 'Get Key' to obtain one"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = mainFrame

-- Key Input Frame
local inputFrame = Instance.new("Frame")
inputFrame.Name = "InputFrame"
inputFrame.Size = UDim2.new(1, -40, 0, 45)
inputFrame.Position = UDim2.new(0, 20, 0, 125)
inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
inputFrame.BorderSizePixel = 0
inputFrame.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 10)
inputCorner.Parent = inputFrame

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(70, 70, 90)
inputStroke.Thickness = 1
inputStroke.Parent = inputFrame

-- Key Input
local keyInput = Instance.new("TextBox")
keyInput.Name = "KeyInput"
keyInput.Size = UDim2.new(1, -20, 1, -10)
keyInput.Position = UDim2.new(0, 10, 0, 5)
keyInput.BackgroundTransparency = 1
keyInput.PlaceholderText = "Enter your key here..."
keyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
keyInput.Text = ""
keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
keyInput.TextSize = 14
keyInput.Font = Enum.Font.Gotham
keyInput.TextXAlignment = Enum.TextXAlignment.Center
keyInput.ClearTextOnFocus = false
keyInput.Parent = inputFrame

-- Buttons Frame
local buttonsFrame = Instance.new("Frame")
buttonsFrame.Name = "ButtonsFrame"
buttonsFrame.Size = UDim2.new(1, -40, 0, 50)
buttonsFrame.Position = UDim2.new(0, 20, 0, 190)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Parent = mainFrame

-- Get Key Button
local getKeyButton = Instance.new("TextButton")
getKeyButton.Name = "GetKeyButton"
getKeyButton.Size = UDim2.new(0.48, 0, 1, 0)
getKeyButton.Position = UDim2.new(0, 0, 0, 0)
getKeyButton.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
getKeyButton.BorderSizePixel = 0
getKeyButton.Text = "🔑 Get Key"
getKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
getKeyButton.TextSize = 14
getKeyButton.Font = Enum.Font.GothamBold
getKeyButton.Parent = buttonsFrame

local getKeyCorner = Instance.new("UICorner")
getKeyCorner.CornerRadius = UDim.new(0, 10)
getKeyCorner.Parent = getKeyButton

-- Redeem Key Button
local redeemButton = Instance.new("TextButton")
redeemButton.Name = "RedeemButton"
redeemButton.Size = UDim2.new(0.48, 0, 1, 0)
redeemButton.Position = UDim2.new(0.52, 0, 0, 0)
redeemButton.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
redeemButton.BorderSizePixel = 0
redeemButton.Text = "✓ Redeem Key"
redeemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
redeemButton.TextSize = 14
redeemButton.Font = Enum.Font.GothamBold
redeemButton.Parent = buttonsFrame

local redeemCorner = Instance.new("UICorner")
redeemCorner.CornerRadius = UDim.new(0, 10)
redeemCorner.Parent = redeemButton

-- Progress Bar Frame
local progressFrame = Instance.new("Frame")
progressFrame.Name = "ProgressFrame"
progressFrame.Size = UDim2.new(1, -40, 0, 8)
progressFrame.Position = UDim2.new(0, 20, 0, 260)
progressFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
progressFrame.BorderSizePixel = 0
progressFrame.Visible = false
progressFrame.Parent = mainFrame

local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(0, 4)
progressCorner.Parent = progressFrame

local progressBar = Instance.new("Frame")
progressBar.Name = "ProgressBar"
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.Position = UDim2.new(0, 0, 0, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
progressBar.BorderSizePixel = 0
progressBar.Parent = progressFrame

local progressBarCorner = Instance.new("UICorner")
progressBarCorner.CornerRadius = UDim.new(0, 4)
progressBarCorner.Parent = progressBar

-- Footer
local footer = Instance.new("TextLabel")
footer.Name = "Footer"
footer.Size = UDim2.new(1, -40, 0, 20)
footer.Position = UDim2.new(0, 20, 1, -35)
footer.BackgroundTransparency = 1
footer.Text = "Powered by Vixvvo"
footer.TextColor3 = Color3.fromRGB(100, 100, 110)
footer.TextSize = 12
footer.Font = Enum.Font.Gotham
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.Parent = mainFrame

-- Utility Functions
local function updateStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color or Color3.fromRGB(180, 180, 190)
end

local function showProgress()
    progressFrame.Visible = true
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    
    local tween = TweenService:Create(progressBar, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {
        Size = UDim2.new(1, 0, 1, 0)
    })
    tween:Play()
end

local function hideProgress()
    progressFrame.Visible = false
end

local function animateButton(button, hover)
    local scale = hover and 1.05 or 1
    local transparency = hover and 0.8 or 1
    
    -- Store original size if not already stored
    if not button:GetAttribute("OriginalSizeX") then
        button:SetAttribute("OriginalSizeX", button.Size.X.Scale)
        button:SetAttribute("OriginalSizeY", button.Size.Y.Scale)
        button:SetAttribute("OriginalOffsetX", button.Size.X.Offset)
        button:SetAttribute("OriginalOffsetY", button.Size.Y.Offset)
    end
    
    local originalSizeX = button:GetAttribute("OriginalSizeX")
    local originalSizeY = button:GetAttribute("OriginalSizeY")
    local originalOffsetX = button:GetAttribute("OriginalOffsetX")
    local originalOffsetY = button:GetAttribute("OriginalOffsetY")
    
    TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = UDim2.new(originalSizeX * scale, originalOffsetX * scale, originalSizeY * scale, originalOffsetY * scale),
        BackgroundTransparency = 1 - transparency
    }):Play()
end

-- LuArmor Key Validation Function
local function validateKey(key)
    -- For LuArmor scripts, the key validation is handled by the script itself
    -- We just need to set the key in the environment and try to load the script
    local success, result = pcall(function()
        -- Set the key in the global environment for LuArmor to read
        getgenv().script_key = key
        _G.script_key = key
        
        -- Try to load the script
        local scriptContent = game:HttpGet(SCRIPT_URL)
        local scriptFunc = loadstring(scriptContent)
        if scriptFunc then
            -- Execute the script in a separate thread so UI can close
            spawn(function()
                scriptFunc()
            end)
            return true
        else
            return false
        end
    end)
    
    if success and result then
        return true, "Key validated successfully"
    else
        -- Clear the invalid key silently
        pcall(function()
            if getgenv then getgenv().script_key = nil end
            _G.script_key = nil
        end)
        
        -- Always return "Invalid code" for any validation failure
        return false, "Invalid code"
    end
end

-- Button Events
getKeyButton.MouseButton1Click:Connect(function()
    updateStatus("Opening key link...", Color3.fromRGB(70, 130, 220))
    
    -- Copy to clipboard if available
    if setclipboard then
        setclipboard(KEY_LINK)
        updateStatus("Key link copied to clipboard!", Color3.fromRGB(70, 180, 70))
    end
    
    -- Try to open browser
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow(KEY_LINK)
    end)
    
    wait(2)
    updateStatus("Complete the steps and return with your key", Color3.fromRGB(180, 180, 190))
end)

redeemButton.MouseButton1Click:Connect(function()
    local key = keyInput.Text:gsub("%s+", "")
    
    if key == "" or #key < 10 then
        updateStatus("❌ Please enter a valid key!", Color3.fromRGB(220, 60, 60))
        return
    end
    
    updateStatus("🔍 Validating key...", Color3.fromRGB(255, 165, 0))
    showProgress()
    
    -- Validate key by trying to load the script
    spawn(function()
        local isValid, message = validateKey(key)
        
        hideProgress()
        
        if isValid then
            updateStatus("✅ Key validated! Loading script...", Color3.fromRGB(70, 180, 70))
            
            -- Close UI immediately when script loads successfully
            local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
            closeTween:Play()
            
            closeTween.Completed:Connect(function()
                screenGui:Destroy()
            end)
        else
            updateStatus("❌ " .. message, Color3.fromRGB(220, 60, 60))
        end
    end)
end)

closeButton.MouseButton1Click:Connect(function()
    local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    closeTween:Play()
    
    closeTween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end)

-- Enter key support
keyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        redeemButton.MouseButton1Click:Fire()
    end
end)

-- Button hover effects
for _, button in pairs({getKeyButton, redeemButton, closeButton}) do
    button.MouseEnter:Connect(function()
        animateButton(button, true)
    end)
    
    button.MouseLeave:Connect(function()
        animateButton(button, false)
    end)
end

-- Input focus effects
keyInput.Focused:Connect(function()
    inputStroke.Color = Color3.fromRGB(70, 130, 220)
    inputStroke.Thickness = 2
end)

keyInput.FocusLost:Connect(function()
    inputStroke.Color = Color3.fromRGB(70, 70, 90)
    inputStroke.Thickness = 1
end)

-- Make draggable
local dragging = false
local dragStart, startPos

headerFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Entrance animation
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

local entranceTween = TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 420, 0, 320),
    Position = UDim2.new(0.5, -210, 0.5, -160)
})
entranceTween:Play()

-- Welcome message
wait(0.5)
updateStatus("Welcome! Get your key or enter an existing one below.", Color3.fromRGB(70, 180, 70))
