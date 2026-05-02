--[[
    GHOST PROTOCOL V3 PRO - ULTIMATE
    Developed by: Yusufcan_Sudo
    License: MIT
    "Sudo is here, staff is clear. Even ghosts have standards."
]]

-- // Services
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- // Configuration
local GhostConfig = {
    SafeGroups = {123456, 1200769}, -- Buraya yetkili gruplarını ekleyebilirsin
    StaffRankThreshold = 100, 
    DangerDistance = 18, -- Kaç metre yakındakiler radar kapsamına girsin?
    ReportWaitTime = 4, -- Kaç saniye hareketsiz kalırsa raporladığını varsayalım?
    SpawnGracePeriod = 10, -- Oyuna girince ilk kaç saniye radar kapalı olsun?
    HopInsteadOfKick = true
}

local SuspiciousPlayers = {}
local GhostActive = false

-- // 0. MODÜL: Server Hop (Gelişmiş Kaçış)
local function SudoHop()
    local x = {}
    for _, v in pairs(game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            table.insert(x, v.id)
        end
    end
    if #x > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)])
    else
        LocalPlayer:Kick("SudoHop: Uygun server bulunamadı, güvenlik için çıkış yapıldı.")
    end
end

-- // 1. MODÜL: Anti-Staff (Hızlı Tespit)
local function checkPlayer(player)
    for _, groupId in ipairs(GhostConfig.SafeGroups) do
        pcall(function()
            if player:GetRankInGroup(groupId) >= GhostConfig.StaffRankThreshold then
                if GhostConfig.HopInsteadOfKick then SudoHop() else LocalPlayer:Kick("Staff Detected: " .. player.Name) end
            end
        end)
    end
end

Players.PlayerAdded:Connect(checkPlayer)

-- // 2. MODÜL: Kendi Menü Koruması
GuiService.MenuOpened:Connect(function()
    LocalPlayer:Kick("Ortion V3: Kendi menün açıldı, güvenlik için çıkıldı.")
end)

-- // 3. MODÜL: Ortion V3 Pro (Zaman Ayarlı Tahmini Koruma)
task.delay(GhostConfig.SpawnGracePeriod, function()
    GhostActive = true
    print("Ghost Protocol Radar Aktif. Yusufcan_Sudo koruması devrede.")
end)

RunService.Heartbeat:Connect(function(deltaTime)
    if not GhostActive then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            local dist = (targetRoot.Position - myPos).Magnitude
            
            -- Yakınlık ve Hareketsizlik Kontrolü
            if dist < GhostConfig.DangerDistance then
                if targetRoot.Velocity.Magnitude < 0.5 then
                    SuspiciousPlayers[player.Name] = (SuspiciousPlayers[player.Name] or 0) + deltaTime
                    
                    -- Eğer 4 saniye boyunca dibinde put gibi duruyorsa
                    if SuspiciousPlayers[player.Name] >= GhostConfig.ReportWaitTime then
                        SuspiciousPlayers = {} -- Listeyi temizle
                        if GhostConfig.HopInsteadOfKick then SudoHop() else LocalPlayer:Kick("Report Risk: " .. player.Name) end
                    end
                else
                    SuspiciousPlayers[player.Name] = 0 -- Hareket ederse süreyi sıfırla
                end
            else
                if SuspiciousPlayers[player.Name] then SuspiciousPlayers[player.Name] = 0 end
            end
        end
    end
end)

-- // Başlatma Bildirimi
game.StarterGui:SetCore("SendNotification", {
    Title = "GHOST V3 PRO LOADED",
    Text = "Sudo-Status: Invisible. Staff-Status: Clear.",
    Duration = 5
})
