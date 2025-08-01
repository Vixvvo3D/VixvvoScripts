-- Modern Draggable Tabbed UI: Auto Collect + Auto Sell + Auto Buy + Settings + Minimize + Close
-- Fully functional, draggable UI with Save/Load config and persistent states

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Events")

-- Config file
local CONFIG_FILE = "AutoCryptoConfig.json"
local canFile = writefile and isfile and readfile

-- State tables
local autoCollect = {}   -- [uuid] = bool
local autoSell = false   -- bool
local autoBuy = {}       -- [machineName] = bool

-- For UI tracking
local collectUI = {}     -- [uuid] = true

-- Machine names
local machineNames = {"Retro Crypto Miner","Classic Crypto Miner","CryptoByte","Crypto Desktop",
    "Crypto Master","Crypto Farm Mini","Plasma Maker","Gamer Mini",
    "Crypto Vault","Graphics Miner","Crypto Generator","Super Generator",
    "Mega Miner","Quantum Miner","Crypto Tower","Omega Miner"}
for _,name in ipairs(machineNames) do autoBuy[name] = false end

-- Save/Load config
local function saveConfig()
    if not canFile then return end
    local data = {collect = autoCollect, sell = autoSell, buy = autoBuy}
    local ok, json = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then pcall(writefile, CONFIG_FILE, json) end
end
local function loadConfig()
    if not canFile or not isfile(CONFIG_FILE) then return end
    local ok, raw = pcall(readfile, CONFIG_FILE)
    if not ok then return end
    local success, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not success or type(data)~="table" then return end
    autoCollect = data.collect or {}
    autoSell = data.sell or false
    for k,v in pairs(data.buy or {}) do autoBuy[k] = v end
end
loadConfig()

-- UI Setup
gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AutoCryptoGUI"; gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,440,0,560)
main.Position = UDim2.new(0.5,-220,0.5,-280)
main.BackgroundColor3=Color3.fromRGB(30,30,30)
main.Active=true; main.Draggable=true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

-- Minimize & Close Buttons
local minimized = false
local originalSize = main.Size

local minimize = Instance.new("TextButton", main)
minimize.Size = UDim2.new(0,30,0,30)
minimize.Position = UDim2.new(1,-70,0,5)
minimize.Text = "_"
minimize.Font = Enum.Font.GothamBold
minimize.TextScaled = true
minimize.BackgroundColor3 = Color3.fromRGB(100,100,100)
minimize.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", minimize).CornerRadius = UDim.new(1,0)

local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,5)
close.Text = "✖"
close.Font = Enum.Font.GothamBold
close.TextScaled = true
close.BackgroundColor3 = Color3.fromRGB(200,60,60)
close.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", close).CornerRadius = UDim.new(1,0)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

minimize.MouseButton1Click:Connect(function()
    if minimized then
        main.Size = originalSize
        for _,btn in pairs(tabButtons) do btn.Visible = true end
        show(currentTab)
    else
        main.Size = UDim2.new(0,440,0,80)
        for _,btn in pairs(tabButtons) do btn.Visible = false end
        for _,fr in pairs(frames) do fr.Visible = false end
    end
    minimized = not minimized
end)

-- Tabs and Frames
tabButtons = {}
frames = {}
currentTab = "Collect"
for i, name in ipairs({"Collect","Sell","Buy","Settings"}) do
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0,100,0,30)
    btn.Position = UDim2.new(0,10+(i-1)*110,0,45)
    btn.Text = name; btn.Font=Enum.Font.GothamBold; btn.TextScaled=true
    btn.BackgroundColor3=Color3.fromRGB(50,50,50); btn.TextColor3=Color3.new(1,1,1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    tabButtons[name] = btn
    local fr = Instance.new("Frame", main)
    fr.Size = UDim2.new(1,-20,1,-100)
    fr.Position = UDim2.new(0,10,0,90)
    fr.BackgroundTransparency = 1
    fr.Visible = (name==currentTab)
    frames[name] = fr
    btn.MouseButton1Click:Connect(function()
        currentTab = name; show(name)
    end)
end

function show(tab)
    for name,fr in pairs(frames) do fr.Visible = (name==tab) end
end

-- Collect Tab UI
local collectScroll = Instance.new("ScrollingFrame", frames.Collect)
collectScroll.Size=UDim2.new(1,0,1,0); collectScroll.CanvasSize=UDim2.new(0,0,0,0)
collectScroll.ScrollBarThickness=6; collectScroll.BackgroundTransparency=1
local collectLayout = Instance.new("UIListLayout", collectScroll)
collectLayout.SortOrder=Enum.SortOrder.LayoutOrder; collectLayout.Padding=UDim.new(0,4)

function addUUID(uuid)
    if collectUI[uuid] then return end
    collectUI[uuid] = true
    if autoCollect[uuid] == nil then autoCollect[uuid] = false end
    local item = Instance.new("Frame", collectScroll)
    item.Size=UDim2.new(1,-10,0,30); item.BackgroundTransparency=1
    local lbl=Instance.new("TextLabel", item)
    lbl.Size=UDim2.new(0.7,0,1,0); lbl.Text=uuid; lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.new(1,1,1); lbl.Font=Enum.Font.Gotham; lbl.TextScaled=true
    local chk=Instance.new("TextButton", item)
    chk.Size=UDim2.new(0.3,0,1,0); chk.Position=UDim2.new(0.7,0,0,0)
    chk.Font=Enum.Font.GothamBold; chk.TextScaled=true
    chk.BackgroundColor3=Color3.fromRGB(60,60,60); chk.TextColor3=Color3.new(1,1,1)
    local function updateText() chk.Text = autoCollect[uuid] and "☑ Auto" or "☐ Auto" end
    updateText()
    chk.MouseButton1Click:Connect(function()
        autoCollect[uuid] = not autoCollect[uuid]
        updateText()
    end)
    collectScroll.CanvasSize=UDim2.new(0,0,0,collectLayout.AbsoluteContentSize.Y)
end

-- Populate pre-saved collects
for uuid,_ in pairs(autoCollect) do addUUID(uuid) end

-- Sell Tab UI
local sellBtn = Instance.new("TextButton", frames.Sell)
sellBtn.Size=UDim2.new(1,-20,0,40); sellBtn.Position=UDim2.new(0,10,0,5)
sellBtn.Font=Enum.Font.GothamBold; sellBtn.TextScaled=true
sellBtn.BackgroundColor3=Color3.fromRGB(60,60,60); sellBtn.TextColor3=Color3.new(1,1,1)
local function updateSellText() sellBtn.Text = autoSell and "☑ Auto Sell All" or "☐ Auto Sell All" end
updateSellText()
sellBtn.MouseButton1Click:Connect(function()
    autoSell = not autoSell; updateSellText()
end)

-- Buy Tab UI
local buyScroll = Instance.new("ScrollingFrame", frames.Buy)
buyScroll.Size=UDim2.new(1,0,1,0); buyScroll.CanvasSize=UDim2.new(0,0,0,0)
buyScroll.ScrollBarThickness=6; buyScroll.BackgroundTransparency=1
local buyLayout = Instance.new("UIListLayout", buyScroll)
buyLayout.SortOrder=Enum.SortOrder.LayoutOrder; buyLayout.Padding=UDim.new(0,4)
for i,name in ipairs(machineNames) do
    local item=Instance.new("Frame", buyScroll)
    item.Size=UDim2.new(1,-10,0,30); item.BackgroundTransparency=1
    local lbl=Instance.new("TextLabel", item)
    lbl.Size=UDim2.new(0.7,0,1,0); lbl.Text=name; lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.new(1,1,1); lbl.Font=Enum.Font.Gotham; lbl.TextScaled=true
    local chk=Instance.new("TextButton", item)
    chk.Size=UDim2.new(0.3,0,1,0); chk.Position=UDim2.new(0.7,0,0,0)
    chk.Font=Enum.Font.GothamBold; chk.TextScaled=true
    chk.BackgroundColor3=Color3.fromRGB(60,60,60); chk.TextColor3=Color3.new(1,1,1)
    local function updateBuyText() chk.Text = autoBuy[name] and "☑ Auto" or "☐ Auto" end
    updateBuyText()
    chk.MouseButton1Click:Connect(function()
        autoBuy[name] = not autoBuy[name]; updateBuyText()
    end)
    buyScroll.CanvasSize = UDim2.new(0,0,0,buyLayout.AbsoluteContentSize.Y)
end

-- Settings Tab UI
local saveBtn = Instance.new("TextButton", frames.Settings)
saveBtn.Size=UDim2.new(1,-20,0,50); saveBtn.Position=UDim2.new(0,10,0,5)
saveBtn.Font=Enum.Font.GothamBold; saveBtn.TextScaled=true
saveBtn.BackgroundColor3=Color3.fromRGB( canFile and 70 or 80, canFile and 130 or 80, canFile and 180 or 80)
saveBtn.TextColor3=Color3.new(1,1,1)
saveBtn.Text = canFile and "💾 Save Config" or "🚫 Save Unsupported"
saveBtn.AutoButtonColor = canFile and true or false
if canFile then saveBtn.MouseButton1Click:Connect(function()
    saveConfig(); saveBtn.Text="✅ Saved"; task.wait(1); saveBtn.Text="💾 Save Config"
end) end

-- Spy ClaimCrypto to collect UUIDs
local mt=getrawmetatable(game); setreadonly(mt,false)
local oldNC = mt.__namecall
mt.__namecall = newcclosure(function(self,...)
    if getnamecallmethod()=="FireServer" and tostring(self):find("ClaimCrypto") then
        local u=(...)
        if typeof(u)=="string" and u:match("{[%w%-]+}") then addUUID(u) end
    end
    return oldNC(self,...)
end)

-- Loops
spawn(function()
    while gui.Parent do
        for u,ok in pairs(autoCollect) do if ok then pcall(function() remotes.ClaimCrypto:FireServer(u) end) end end
        if autoSell then pcall(function() remotes.SellCrypto:FireServer("All") end) end
        task.wait(1)
    end
end)
spawn(function()
    local interval=0.5
    while gui.Parent do
        for i,name in ipairs(machineNames) do if autoBuy[name] then pcall(function() remotes.PurchaseMachine:FireServer("Machine_"..i) end) end end
        task.wait(interval)
    end
end)
