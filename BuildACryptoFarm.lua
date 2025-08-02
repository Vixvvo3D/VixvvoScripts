-- Standalone Auto Crypto Farm GUI
-- This is a complete script that includes all modules in a single file
-- Modern Draggable Tabbed UI: Auto Collect + Auto Sell + Auto Buy + Settings + Minimize + Close
-- Fully functional, draggable UI with Save/Load config and persistent states

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Events")

-- ========================
-- CONFIG MODULE
-- ========================
local Config = {}

-- Config file
Config.CONFIG_FILE = "AutoCryptoConfig.json"
Config.canFile = writefile and isfile and readfile

-- State tables
Config.autoCollect = {}   -- [uuid] = bool
Config.autoSell = false   -- bool
Config.autoBuy = {}       -- [machineName] = bool

-- For UI tracking
Config.collectUI = {}     -- [uuid] = true

-- Machine names
Config.machineNames = {
    "Retro Crypto Miner", "Classic Crypto Miner", "CryptoByte", "Crypto Desktop",
    "Crypto Master", "Crypto Farm Mini", "Plasma Maker", "Gamer Mini",
    "Crypto Vault", "Graphics Miner", "Crypto Generator", "Super Generator",
    "Mega Miner", "Quantum Miner", "Crypto Tower", "Omega Miner"
}

-- Initialize auto buy settings
for _, name in ipairs(Config.machineNames) do 
    Config.autoBuy[name] = false 
end

-- Save/Load config functions
function Config.save()
    if not Config.canFile then return end
    local data = {
        collect = Config.autoCollect, 
        sell = Config.autoSell, 
        buy = Config.autoBuy
    }
    local ok, json = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then 
        pcall(writefile, Config.CONFIG_FILE, json) 
    end
end

function Config.load()
    if not Config.canFile or not isfile(Config.CONFIG_FILE) then return end
    local ok, raw = pcall(readfile, Config.CONFIG_FILE)
    if not ok then return end
    local success, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not success or type(data) ~= "table" then return end
    
    Config.autoCollect = data.collect or {}
    Config.autoSell = data.sell or false
    for k, v in pairs(data.buy or {}) do 
        Config.autoBuy[k] = v 
    end
end

-- Initialize config
Config.load()

-- ========================
-- UI MANAGER MODULE
-- ========================
local UIManager = {}

-- UI variables
UIManager.gui = nil
UIManager.main = nil
UIManager.shadow = nil
UIManager.tabButtons = {}
UIManager.frames = {}
UIManager.currentTab = "Collect"
UIManager.minimized = false
UIManager.originalSize = nil

function UIManager.init()
    -- Create main GUI
    UIManager.gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    UIManager.gui.Name = "AutoCryptoGUI"
    UIManager.gui.ResetOnSpawn = false

    -- Main container with modern styling
    UIManager.main = Instance.new("Frame", UIManager.gui)
    UIManager.main.Size = UDim2.new(0, 480, 0, 600)
    UIManager.main.Position = UDim2.new(0.5, -240, 0.5, -300)
    UIManager.main.BackgroundColor3 = Color3.fromRGB(47, 49, 54)  -- Discord-like dark color
    UIManager.main.Active = true
    UIManager.main.Draggable = false  -- We'll handle dragging manually
    UIManager.main.BorderSizePixel = 0
    
    -- Modern rounded corners
    local corner = Instance.new("UICorner", UIManager.main)
    corner.CornerRadius = UDim.new(0, 8)
    
    -- Subtle drop shadow effect (child of main so it moves together)
    local shadow = Instance.new("Frame", UIManager.main)
    shadow.Size = UDim2.new(1, 8, 1, 8)
    shadow.Position = UDim2.new(0, -4, 0, -4)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.ZIndex = UIManager.main.ZIndex - 1
    shadow.BorderSizePixel = 0
    local shadowCorner = Instance.new("UICorner", shadow)
    shadowCorner.CornerRadius = UDim.new(0, 12)
    
    UIManager.shadow = shadow  -- Store reference for minimize function
    
    -- Title bar
    local titleBar = Instance.new("Frame", UIManager.main)
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
    titleBar.BorderSizePixel = 0
    titleBar.Active = true  -- Make title bar active for dragging
    local titleCorner = Instance.new("UICorner", titleBar)
    titleCorner.CornerRadius = UDim.new(0, 8)
    
    -- Title text
    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🚀 Auto Crypto Farm"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Add draggable cursor hint
    titleBar.MouseEnter:Connect(function()
        titleBar.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
    end)
    titleBar.MouseLeave:Connect(function()
        titleBar.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
    end)
    
    UIManager.originalSize = UIManager.main.Size
    UIManager.titleBar = titleBar
    
    -- Set up dragging functionality
    UIManager.setupDragging(titleBar)
    
    UIManager.createControlButtons()
    UIManager.createTabs()
end

-- Dragging functionality
function UIManager.setupDragging(dragFrame)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = UIManager.main.Position

            local connection
            connection = UserInputService.InputChanged:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                    local delta = input2.Position - dragStart
                    UIManager.main.Position = UDim2.new(
                        startPos.X.Scale,
                        startPos.X.Offset + delta.X,
                        startPos.Y.Scale,
                        startPos.Y.Offset + delta.Y
                    )
                end
            end)

            -- Clean up when dragging stops
            local releaseConnection
            releaseConnection = UserInputService.InputEnded:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    connection:Disconnect()
                    releaseConnection:Disconnect()
                end
            end)
        end
    end)
end

function UIManager.createControlButtons()
    -- Minimize button with modern styling
    local minimize = Instance.new("TextButton", UIManager.titleBar)
    minimize.Size = UDim2.new(0, 25, 0, 25)
    minimize.Position = UDim2.new(1, -65, 0, 7.5)
    minimize.Text = "─"
    minimize.Font = Enum.Font.GothamBold
    minimize.TextScaled = true
    minimize.BackgroundColor3 = Color3.fromRGB(88, 101, 242)  -- Discord blue
    minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimize.BorderSizePixel = 0
    
    local minimizeCorner = Instance.new("UICorner", minimize)
    minimizeCorner.CornerRadius = UDim.new(0, 4)
    
    -- Hover effect for minimize
    minimize.MouseEnter:Connect(function()
        minimize.BackgroundColor3 = Color3.fromRGB(114, 118, 125)
    end)
    minimize.MouseLeave:Connect(function()
        minimize.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    end)

    -- Close button with modern styling
    local close = Instance.new("TextButton", UIManager.titleBar)
    close.Size = UDim2.new(0, 25, 0, 25)
    close.Position = UDim2.new(1, -35, 0, 7.5)
    close.Text = "✕"
    close.Font = Enum.Font.GothamBold
    close.TextScaled = true
    close.BackgroundColor3 = Color3.fromRGB(237, 66, 69)  -- Discord red
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.BorderSizePixel = 0
    
    local closeCorner = Instance.new("UICorner", close)
    closeCorner.CornerRadius = UDim.new(0, 4)
    
    -- Hover effect for close
    close.MouseEnter:Connect(function()
        close.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    end)
    close.MouseLeave:Connect(function()
        close.BackgroundColor3 = Color3.fromRGB(237, 66, 69)
    end)

    -- Event connections
    close.MouseButton1Click:Connect(function() 
        UIManager.gui:Destroy() 
    end)

    minimize.MouseButton1Click:Connect(function()
        UIManager.toggleMinimize()
    end)
end

function UIManager.createTabs()
    -- Tab container
    local tabContainer = Instance.new("Frame", UIManager.main)
    tabContainer.Size = UDim2.new(1, -20, 0, 50)
    tabContainer.Position = UDim2.new(0, 10, 0, 50)
    tabContainer.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
    tabContainer.BorderSizePixel = 0
    local tabContainerCorner = Instance.new("UICorner", tabContainer)
    tabContainerCorner.CornerRadius = UDim.new(0, 6)
    
    local tabLayout = Instance.new("UIListLayout", tabContainer)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 5)
    
    for i, name in ipairs({"Collect", "Sell", "Buy", "Settings"}) do
        -- Tab button with modern styling
        local btn = Instance.new("TextButton", tabContainer)
        btn.Size = UDim2.new(0, 100, 0, 35)
        btn.Text = name
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.TextColor3 = Color3.fromRGB(185, 187, 190)
        btn.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        
        -- Add icons to tabs
        local icons = {Collect = "💰", Sell = "💸", Buy = "🛒", Settings = "⚙️"}
        btn.Text = icons[name] .. " " .. name
        
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 4)
        
        -- Active tab styling
        if name == UIManager.currentTab then
            btn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        
        -- Hover effects
        btn.MouseEnter:Connect(function()
            if UIManager.currentTab ~= name then
                btn.BackgroundColor3 = Color3.fromRGB(79, 84, 92)
            end
        end)
        btn.MouseLeave:Connect(function()
            if UIManager.currentTab ~= name then
                btn.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
            end
        end)
        
        UIManager.tabButtons[name] = btn

        -- Tab frame with modern container
        local fr = Instance.new("Frame", UIManager.main)
        fr.Size = UDim2.new(1, -30, 1, -130)
        fr.Position = UDim2.new(0, 15, 0, 115)
        fr.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
        fr.BorderSizePixel = 0
        fr.Visible = (name == UIManager.currentTab)
        local frCorner = Instance.new("UICorner", fr)
        frCorner.CornerRadius = UDim.new(0, 6)
        
        UIManager.frames[name] = fr

        -- Button click event with visual feedback
        btn.MouseButton1Click:Connect(function()
            -- Update all tabs
            for tabName, tabBtn in pairs(UIManager.tabButtons) do
                if tabName == name then
                    tabBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
                    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    tabBtn.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
                    tabBtn.TextColor3 = Color3.fromRGB(185, 187, 190)
                end
            end
            UIManager.currentTab = name
            UIManager.show(name)
        end)
    end
end

function UIManager.show(tab)
    for name, fr in pairs(UIManager.frames) do 
        fr.Visible = (name == tab) 
    end
end

function UIManager.toggleMinimize()
    if UIManager.minimized then
        -- Restore to full size
        UIManager.main.Size = UIManager.originalSize

        -- Update shadow size to match
        if UIManager.shadow then
            UIManager.shadow.Size = UDim2.new(1, 8, 1, 8)
        end

        -- Show all UI elements
        for _, frame in pairs(UIManager.frames) do
            frame.Visible = false  -- Hide all first
        end
        UIManager.show(UIManager.currentTab)  -- Show the last active tab

        -- Show tab container and other elements
        for _, child in pairs(UIManager.main:GetChildren()) do
            if child.Name ~= "UICorner" and child ~= UIManager.titleBar and child ~= UIManager.shadow then
                child.Visible = true
            end
        end

        UIManager.minimized = false
    else
        -- Minimize to title bar only
        UIManager.main.Size = UDim2.new(0, 480, 0, 40)

        -- Update shadow size to match minimized state
        if UIManager.shadow then
            UIManager.shadow.Size = UDim2.new(1, 8, 1, 8)
        end

        -- Hide all content except title bar and shadow
        for _, child in pairs(UIManager.main:GetChildren()) do
            if child.Name ~= "UICorner" and child ~= UIManager.titleBar and child ~= UIManager.shadow then
                child.Visible = false
            end
        end

        UIManager.minimized = true
    end
end

-- ========================
-- COLLECT TAB MODULE
-- ========================
local CollectTab = {}

function CollectTab.init(frame)
    -- Header
    local header = Instance.new("TextLabel", frame)
    header.Size = UDim2.new(1, -20, 0, 30)
    header.Position = UDim2.new(0, 10, 0, 10)
    header.BackgroundTransparency = 1
    header.Text = "💰 Auto Collection Manager"
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 16
    header.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Create scrolling frame for collect items
    local collectScroll = Instance.new("ScrollingFrame", frame)
    collectScroll.Size = UDim2.new(1, -20, 1, -60)
    collectScroll.Position = UDim2.new(0, 10, 0, 50)
    collectScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    collectScroll.ScrollBarThickness = 4
    collectScroll.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
    collectScroll.BorderSizePixel = 0
    collectScroll.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)
    
    local scrollCorner = Instance.new("UICorner", collectScroll)
    scrollCorner.CornerRadius = UDim.new(0, 4)
    
    local collectLayout = Instance.new("UIListLayout", collectScroll)
    collectLayout.SortOrder = Enum.SortOrder.LayoutOrder
    collectLayout.Padding = UDim.new(0, 8)
    
    -- Add padding
    local padding = Instance.new("UIPadding", collectScroll)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    
    CollectTab.collectScroll = collectScroll
    CollectTab.collectLayout = collectLayout
    
    -- Populate pre-saved collects
    for uuid, _ in pairs(Config.autoCollect) do 
        CollectTab.addUUID(uuid) 
    end
end

function CollectTab.addUUID(uuid)
    if Config.collectUI[uuid] then return end
    Config.collectUI[uuid] = true
    
    if Config.autoCollect[uuid] == nil then 
        Config.autoCollect[uuid] = false 
    end
    
    local item = Instance.new("Frame", CollectTab.collectScroll)
    item.Size = UDim2.new(1, -20, 0, 40)
    item.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
    item.BorderSizePixel = 0
    
    local itemCorner = Instance.new("UICorner", item)
    itemCorner.CornerRadius = UDim.new(0, 4)
    
    -- UUID display with better formatting
    local lbl = Instance.new("TextLabel", item)
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = "🔑 " .. string.sub(uuid, 1, 20) .. "..."
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(220, 221, 222)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Modern toggle button
    local chk = Instance.new("TextButton", item)
    chk.Size = UDim2.new(0, 80, 0, 25)
    chk.Position = UDim2.new(1, -90, 0.5, -12.5)
    chk.Font = Enum.Font.GothamSemibold
    chk.TextSize = 11
    chk.BorderSizePixel = 0
    chk.AutoButtonColor = false
    
    local chkCorner = Instance.new("UICorner", chk)
    chkCorner.CornerRadius = UDim.new(0, 12)
    
    local function updateText() 
        if Config.autoCollect[uuid] then
            chk.Text = "✓ ON"
            chk.BackgroundColor3 = Color3.fromRGB(67, 181, 129)  -- Green
            chk.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            chk.Text = "OFF"
            chk.BackgroundColor3 = Color3.fromRGB(114, 118, 125)  -- Gray
            chk.TextColor3 = Color3.fromRGB(185, 187, 190)
        end
    end
    updateText()
    
    -- Hover effects
    chk.MouseEnter:Connect(function()
        if Config.autoCollect[uuid] then
            chk.BackgroundColor3 = Color3.fromRGB(85, 195, 143)
        else
            chk.BackgroundColor3 = Color3.fromRGB(130, 134, 141)
        end
    end)
    chk.MouseLeave:Connect(function()
        updateText()
    end)
    
    chk.MouseButton1Click:Connect(function()
        Config.autoCollect[uuid] = not Config.autoCollect[uuid]
        updateText()
    end)
    
    CollectTab.collectScroll.CanvasSize = UDim2.new(0, 0, 0, CollectTab.collectLayout.AbsoluteContentSize.Y + 20)
end

-- ========================
-- SELL TAB MODULE
-- ========================
local SellTab = {}

function SellTab.init(frame)
    -- Header
    local header = Instance.new("TextLabel", frame)
    header.Size = UDim2.new(1, -20, 0, 30)
    header.Position = UDim2.new(0, 10, 0, 10)
    header.BackgroundTransparency = 1
    header.Text = "💸 Auto Sell Manager"
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 16
    header.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Main sell button container
    local container = Instance.new("Frame", frame)
    container.Size = UDim2.new(1, -20, 0, 80)
    container.Position = UDim2.new(0, 10, 0, 60)
    container.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
    container.BorderSizePixel = 0
    local containerCorner = Instance.new("UICorner", container)
    containerCorner.CornerRadius = UDim.new(0, 6)
    
    local sellBtn = Instance.new("TextButton", container)
    sellBtn.Size = UDim2.new(1, -20, 0, 50)
    sellBtn.Position = UDim2.new(0, 10, 0, 15)
    sellBtn.Font = Enum.Font.GothamBold
    sellBtn.TextSize = 16
    sellBtn.BorderSizePixel = 0
    sellBtn.AutoButtonColor = false
    
    local sellCorner = Instance.new("UICorner", sellBtn)
    sellCorner.CornerRadius = UDim.new(0, 6)
    
    local function updateSellText() 
        if Config.autoSell then
            sellBtn.Text = "✓ Auto Sell Enabled"
            sellBtn.BackgroundColor3 = Color3.fromRGB(67, 181, 129)
            sellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            sellBtn.Text = "❌ Auto Sell Disabled"
            sellBtn.BackgroundColor3 = Color3.fromRGB(114, 118, 125)
            sellBtn.TextColor3 = Color3.fromRGB(185, 187, 190)
        end
    end
    updateSellText()
    
    -- Hover effects
    sellBtn.MouseEnter:Connect(function()
        if Config.autoSell then
            sellBtn.BackgroundColor3 = Color3.fromRGB(85, 195, 143)
        else
            sellBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
            sellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
    sellBtn.MouseLeave:Connect(function()
        updateSellText()
    end)
    
    sellBtn.MouseButton1Click:Connect(function()
        Config.autoSell = not Config.autoSell
        updateSellText()
    end)
end

-- ========================
-- BUY TAB MODULE
-- ========================
local BuyTab = {}

function BuyTab.init(frame)
    -- Header for Auto Buy Crypto
    local headerCrypto = Instance.new("TextLabel", frame)
    headerCrypto.Size = UDim2.new(1, -20, 0, 30)
    headerCrypto.Position = UDim2.new(0, 10, 0, 10)
    headerCrypto.BackgroundTransparency = 1
    headerCrypto.Text = "🛒 Auto Purchase Crypto"
    headerCrypto.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerCrypto.Font = Enum.Font.GothamBold
    headerCrypto.TextSize = 16
    headerCrypto.TextXAlignment = Enum.TextXAlignment.Left

    local buyScrollCrypto = Instance.new("ScrollingFrame", frame)
    buyScrollCrypto.Size = UDim2.new(1, -20, 0.4, -60)
    buyScrollCrypto.Position = UDim2.new(0, 10, 0, 50)
    buyScrollCrypto.CanvasSize = UDim2.new(0, 0, 0, 0)
    buyScrollCrypto.ScrollBarThickness = 4
    buyScrollCrypto.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
    buyScrollCrypto.BorderSizePixel = 0
    buyScrollCrypto.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)

    local scrollCornerCrypto = Instance.new("UICorner", buyScrollCrypto)
    scrollCornerCrypto.CornerRadius = UDim.new(0, 4)

    local buyLayoutCrypto = Instance.new("UIListLayout", buyScrollCrypto)
    buyLayoutCrypto.SortOrder = Enum.SortOrder.LayoutOrder
    buyLayoutCrypto.Padding = UDim.new(0, 8)

    -- Add padding
    local paddingCrypto = Instance.new("UIPadding", buyScrollCrypto)
    paddingCrypto.PaddingTop = UDim.new(0, 10)
    paddingCrypto.PaddingBottom = UDim.new(0, 10)
    paddingCrypto.PaddingLeft = UDim.new(0, 10)
    paddingCrypto.PaddingRight = UDim.new(0, 10)

    for i, name in ipairs(Config.machineNames) do
        local item = Instance.new("Frame", buyScrollCrypto)
        item.Size = UDim2.new(1, -20, 0, 40)
        item.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
        item.BorderSizePixel = 0

        local itemCorner = Instance.new("UICorner", item)
        itemCorner.CornerRadius = UDim.new(0, 4)

        -- Machine name with icon
        local lbl = Instance.new("TextLabel", item)
        lbl.Size = UDim2.new(0.65, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.Text = "⚡ " .. name
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(220, 221, 222)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        -- Modern toggle button
        local chk = Instance.new("TextButton", item)
        chk.Size = UDim2.new(0, 80, 0, 25)
        chk.Position = UDim2.new(1, -90, 0.5, -12.5)
        chk.Font = Enum.Font.GothamSemibold
        chk.TextSize = 11
        chk.BorderSizePixel = 0
        chk.AutoButtonColor = false

        local chkCorner = Instance.new("UICorner", chk)
        chkCorner.CornerRadius = UDim.new(0, 12)

        local function updateBuyText() 
            if Config.autoBuy[name] then
                chk.Text = "✓ ON"
                chk.BackgroundColor3 = Color3.fromRGB(67, 181, 129)
                chk.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                chk.Text = "OFF"
                chk.BackgroundColor3 = Color3.fromRGB(114, 118, 125)
                chk.TextColor3 = Color3.fromRGB(185, 187, 190)
            end
        end
        updateBuyText()

        -- Hover effects
        chk.MouseEnter:Connect(function()
            if Config.autoBuy[name] then
                chk.BackgroundColor3 = Color3.fromRGB(85, 195, 143)
            else
                chk.BackgroundColor3 = Color3.fromRGB(130, 134, 141)
            end
        end)
        chk.MouseLeave:Connect(function()
            updateBuyText()
        end)

        chk.MouseButton1Click:Connect(function()
            Config.autoBuy[name] = not Config.autoBuy[name]
            updateBuyText()
        end)

        buyScrollCrypto.CanvasSize = UDim2.new(0, 0, 0, buyLayoutCrypto.AbsoluteContentSize.Y + 20)
    end

    -- Header for Auto Buy Gear
    local headerGear = Instance.new("TextLabel", frame)
    headerGear.Size = UDim2.new(1, -20, 0, 30)
    headerGear.Position = UDim2.new(0, 10, 0.5, 10)
    headerGear.BackgroundTransparency = 1
    headerGear.Text = "🛠️ Auto Purchase Gear"
    headerGear.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerGear.Font = Enum.Font.GothamBold
    headerGear.TextSize = 16
    headerGear.TextXAlignment = Enum.TextXAlignment.Left

    local buyScrollGear = Instance.new("ScrollingFrame", frame)
    buyScrollGear.Size = UDim2.new(1, -20, 0.4, -60)
    buyScrollGear.Position = UDim2.new(0, 10, 0.55, 50)
    buyScrollGear.CanvasSize = UDim2.new(0, 0, 0, 0)
    buyScrollGear.ScrollBarThickness = 4
    buyScrollGear.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
    buyScrollGear.BorderSizePixel = 0
    buyScrollGear.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)

    local scrollCornerGear = Instance.new("UICorner", buyScrollGear)
    scrollCornerGear.CornerRadius = UDim.new(0, 4)

    local buyLayoutGear = Instance.new("UIListLayout", buyScrollGear)
    buyLayoutGear.SortOrder = Enum.SortOrder.LayoutOrder
    buyLayoutGear.Padding = UDim.new(0, 8)

    -- Add padding
    local paddingGear = Instance.new("UIPadding", buyScrollGear)
    paddingGear.PaddingTop = UDim.new(0, 10)
    paddingGear.PaddingBottom = UDim.new(0, 10)
    paddingGear.PaddingLeft = UDim.new(0, 10)
    paddingGear.PaddingRight = UDim.new(0, 10)

    local gearItems = {
        "BasicLuckFlag",
        "BasicSpeedFlag",
        "BasicCryptoFlag",
        "AdvancedLuckFlag",
        "SuperSpeaker"
    }

    for _, gear in ipairs(gearItems) do
        local item = Instance.new("Frame", buyScrollGear)
        item.Size = UDim2.new(1, -20, 0, 40)
        item.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
        item.BorderSizePixel = 0

        local itemCorner = Instance.new("UICorner", item)
        itemCorner.CornerRadius = UDim.new(0, 4)

        -- Gear name with icon
        local lbl = Instance.new("TextLabel", item)
        lbl.Size = UDim2.new(0.65, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.Text = "🔧 " .. gear
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(220, 221, 222)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        -- Modern toggle button
        local chk = Instance.new("TextButton", item)
        chk.Size = UDim2.new(0, 80, 0, 25)
        chk.Position = UDim2.new(1, -90, 0.5, -12.5)
        chk.Font = Enum.Font.GothamSemibold
        chk.TextSize = 11
        chk.BorderSizePixel = 0
        chk.AutoButtonColor = false

        local chkCorner = Instance.new("UICorner", chk)
        chkCorner.CornerRadius = UDim.new(0, 12)

        local function updateGearText() 
            if Config.autoBuy[gear] then
                chk.Text = "✓ ON"
                chk.BackgroundColor3 = Color3.fromRGB(67, 181, 129)
                chk.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                chk.Text = "OFF"
                chk.BackgroundColor3 = Color3.fromRGB(114, 118, 125)
                chk.TextColor3 = Color3.fromRGB(185, 187, 190)
            end
        end
        updateGearText()

        -- Hover effects
        chk.MouseEnter:Connect(function()
            if Config.autoBuy[gear] then
                chk.BackgroundColor3 = Color3.fromRGB(85, 195, 143)
            else
                chk.BackgroundColor3 = Color3.fromRGB(130, 134, 141)
            end
        end)
        chk.MouseLeave:Connect(function()
            updateGearText()
        end)

        chk.MouseButton1Click:Connect(function()
            Config.autoBuy[gear] = not Config.autoBuy[gear]
            updateGearText()
        end)

        buyScrollGear.CanvasSize = UDim2.new(0, 0, 0, buyLayoutGear.AbsoluteContentSize.Y + 20)
    end
end

-- ========================
-- SETTINGS TAB MODULE
-- ========================
local SettingsTab = {}

function SettingsTab.init(frame)
    -- Header
    local header = Instance.new("TextLabel", frame)
    header.Size = UDim2.new(1, -20, 0, 30)
    header.Position = UDim2.new(0, 10, 0, 10)
    header.BackgroundTransparency = 1
    header.Text = "⚙️ Settings & Configuration"
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 16
    header.TextXAlignment = Enum.TextXAlignment.Left

    -- Settings container
    local container = Instance.new("Frame", frame)
    container.Size = UDim2.new(1, -20, 0, 280)
    container.Position = UDim2.new(0, 10, 0, 60)
    container.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
    container.BorderSizePixel = 0
    local containerCorner = Instance.new("UICorner", container)
    containerCorner.CornerRadius = UDim.new(0, 6)

    -- Save Configuration button
    local saveBtn = Instance.new("TextButton", container)
    saveBtn.Size = UDim2.new(1, -20, 0, 50)
    saveBtn.Position = UDim2.new(0, 10, 0, 15)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 14
    saveBtn.BorderSizePixel = 0
    saveBtn.AutoButtonColor = false

    local saveCorner = Instance.new("UICorner", saveBtn)
    saveCorner.CornerRadius = UDim.new(0, 6)

    -- Status indicator
    local statusLabel = Instance.new("TextLabel", container)
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 0, 80)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 11
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center

    if Config.canFile then
        saveBtn.Text = "💾 Save Configuration"
        saveBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        statusLabel.Text = "✅ File system access available"
        statusLabel.TextColor3 = Color3.fromRGB(67, 181, 129)
        
        -- Hover effect
        saveBtn.MouseEnter:Connect(function()
            saveBtn.BackgroundColor3 = Color3.fromRGB(104, 117, 255)
        end)
        saveBtn.MouseLeave:Connect(function()
            saveBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        end)
        
        saveBtn.MouseButton1Click:Connect(function()
            Config.save()
            saveBtn.Text = "✅ Configuration Saved!"
            saveBtn.BackgroundColor3 = Color3.fromRGB(67, 181, 129)
            task.wait(2)
            saveBtn.Text = "💾 Save Configuration"
            saveBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        end)
    else
        saveBtn.Text = "🚫 File System Unavailable"
        saveBtn.BackgroundColor3 = Color3.fromRGB(114, 118, 125)
        saveBtn.TextColor3 = Color3.fromRGB(185, 187, 190)
        statusLabel.Text = "❌ Executor doesn't support file operations"
        statusLabel.TextColor3 = Color3.fromRGB(240, 71, 71)
    end
    
end

-- ========================
-- REMOTE SPY MODULE
-- ========================
local RemoteSpy = {}

function RemoteSpy.init()
    -- Spy ClaimCrypto to collect UUIDs
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNC = mt.__namecall
    
    mt.__namecall = newcclosure(function(self, ...)
        if getnamecallmethod() == "FireServer" and tostring(self):find("ClaimCrypto") then
            local u = (...)
            if typeof(u) == "string" and u:match("{[%w%-]+}") then 
                CollectTab.addUUID(u) 
            end
        end
        return oldNC(self, ...)
    end)
end

-- ========================
-- AUTOMATION LOOPS MODULE
-- ========================
local AutomationLoops = {}

function AutomationLoops.start()
    -- Auto-collect and auto-sell loop
    spawn(function()
        while UIManager.gui and UIManager.gui.Parent do
            -- Auto collect
            for u, ok in pairs(Config.autoCollect) do 
                if ok then 
                    pcall(function() 
                        remotes.ClaimCrypto:FireServer(u) 
                    end) 
                end 
            end
            
            -- Auto sell
            if Config.autoSell then 
                pcall(function() 
                    remotes.SellCrypto:FireServer("All") 
                end) 
            end
            
            task.wait(1)
        end
    end)
    
    -- Auto-buy loop
    spawn(function()
        local interval = 0.5
        while UIManager.gui and UIManager.gui.Parent do
            for i, name in ipairs(Config.machineNames) do 
                if Config.autoBuy[name] then 
                    pcall(function() 
                        remotes.PurchaseMachine:FireServer("Machine_" .. i) 
                    end) 
                end 
            end
            task.wait(interval)
        end
    end)

    -- Auto-buy gear loop
    spawn(function()
        local interval = 0.5
        while UIManager.gui and UIManager.gui.Parent do
            -- Auto-buy gear loop
            local gearItems = {
                "BasicLuckFlag",
                "BasicSpeedFlag",
                "BasicCryptoFlag",
                "AdvancedLuckFlag",
                "SuperSpeaker"
            }

            for _, gear in ipairs(gearItems) do
                if Config.autoBuy[gear] then
                    pcall(function()
                        remotes.PurchaseGear:FireServer(gear)
                    end)
                end
            end

            task.wait(interval)
        end
    end)
end

-- ========================
-- MAIN APPLICATION
-- ========================
local function main()
    -- Initialize UI
    UIManager.init()
    
    -- Initialize tabs
    CollectTab.init(UIManager.frames.Collect)
    SellTab.init(UIManager.frames.Sell)
    BuyTab.init(UIManager.frames.Buy)
    SettingsTab.init(UIManager.frames.Settings)
    
    -- Set up automation
    RemoteSpy.init()
    AutomationLoops.start()
end

-- Start the application
main()
