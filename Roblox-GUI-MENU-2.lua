--[[
    CUSTOM SOCIAL / PAUSE GUI V2 — Integrated recovery edition
    Roblox LocalScript

    Placement: StarterPlayer > StarterPlayerScripts

    Controls:
        P  = show / hide the custom interface
        R  = refresh the player list while the interface is open
        F8 = emergency recovery: disable this custom GUI and restore PlayerList

    Notes:
        - This is a client-only custom interface; it does not replace Roblox's
          internal Escape/CoreGui menu.
        - CoreScript-dependent actions are called through pcall(), because they
          can be unavailable during loading or in some Roblox contexts.
        - The recovery GUI is created BEFORE the main GUI. F8 never depends on
          the main panel, pages, styles, or player-list construction succeeding.
]]

--// SERVICES
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local SocialService = game:GetService("SocialService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--// PLAYER REFERENCES
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// NAMES
local GUI_NAME = "CustomSocialPauseGUI_V2"
local RECOVERY_GUI_NAME = "CustomSocialPauseGUI_Recovery"

--// SMALL SAFE API HELPERS
local function safeSetCore(name, value)
    return pcall(function()
        StarterGui:SetCore(name, value)
    end)
end

local function safeSetCoreGuiEnabled(coreGuiType, enabled)
    return pcall(function()
        StarterGui:SetCoreGuiEnabled(coreGuiType, enabled)
    end)
end

local function restorePlayerList()
    safeSetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
end

--// =========================================================
--// INDEPENDENT EMERGENCY RECOVERY SYSTEM (CREATED FIRST)
--// =========================================================
local oldRecoveryGui = PlayerGui:FindFirstChild(RECOVERY_GUI_NAME)
if oldRecoveryGui then
    oldRecoveryGui:Destroy()
end

local RecoveryGui = Instance.new("ScreenGui")
RecoveryGui.Name = RECOVERY_GUI_NAME
RecoveryGui.ResetOnSpawn = false
RecoveryGui.IgnoreGuiInset = true
RecoveryGui.DisplayOrder = 10000
RecoveryGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
RecoveryGui.Parent = PlayerGui

local RecoveryButton = Instance.new("TextButton")
RecoveryButton.Name = "EmergencyButton"
RecoveryButton.AnchorPoint = Vector2.new(1, 1)
RecoveryButton.Position = UDim2.new(1, -18, 1, -18)
RecoveryButton.Size = UDim2.fromOffset(216, 46)
RecoveryButton.BackgroundColor3 = Color3.fromRGB(175, 38, 57)
RecoveryButton.BackgroundTransparency = 0.06
RecoveryButton.BorderSizePixel = 0
RecoveryButton.Text = "F8  ·  RECUPERAR GUI"
RecoveryButton.TextColor3 = Color3.new(1, 1, 1)
RecoveryButton.TextSize = 14
RecoveryButton.Font = Enum.Font.GothamBold
RecoveryButton.AutoButtonColor = true
RecoveryButton.Visible = false
RecoveryButton.Parent = RecoveryGui

local recoveryCorner = Instance.new("UICorner")
recoveryCorner.CornerRadius = UDim.new(0, 10)
recoveryCorner.Parent = RecoveryButton

local recoveryStroke = Instance.new("UIStroke")
recoveryStroke.Color = Color3.fromRGB(255, 115, 133)
recoveryStroke.Thickness = 1
recoveryStroke.Parent = RecoveryButton

local function emergencyDisableCustomGui()
    local mainGui = PlayerGui:FindFirstChild(GUI_NAME)
    if mainGui then
        mainGui.Enabled = false
    end

    -- Hide the recovery surface after the user explicitly recovers.
    RecoveryGui.Enabled = false
    restorePlayerList()
end

local function showRecovery()
    RecoveryGui.Enabled = true
    RecoveryButton.Visible = true
end

local function hideRecovery()
    RecoveryButton.Visible = false
end

RecoveryButton.Activated:Connect(emergencyDisableCustomGui)

-- This connection deliberately has no dependency on the main GUI.
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F8 then
        emergencyDisableCustomGui()
    end
end)

--// =========================================================
--// MAIN GUI CONSTRUCTION
--// =========================================================
local buildOk, buildError = pcall(function()
    local oldGui = PlayerGui:FindFirstChild(GUI_NAME)
    if oldGui then
        oldGui:Destroy()
    end

    local Settings = {
        OpenOnStart = false,
        HideLocalPlayerList = true,
        Animations = true,
        Theme = "Neon",
    }

    local Themes = {
        Neon = {
            Background = Color3.fromRGB(5, 8, 15),
            Panel = Color3.fromRGB(10, 15, 25),
            Card = Color3.fromRGB(15, 23, 37),
            CardHover = Color3.fromRGB(23, 35, 54),
            Text = Color3.fromRGB(245, 248, 255),
            Muted = Color3.fromRGB(158, 172, 194),
            Border = Color3.fromRGB(52, 71, 105),
            Accent = Color3.fromRGB(73, 145, 255),
            Accent2 = Color3.fromRGB(148, 79, 255),
            Success = Color3.fromRGB(72, 224, 126),
            Warning = Color3.fromRGB(245, 184, 69),
            Danger = Color3.fromRGB(255, 83, 131),
        },
        Midnight = {
            Background = Color3.fromRGB(7, 7, 11),
            Panel = Color3.fromRGB(14, 14, 21),
            Card = Color3.fromRGB(22, 22, 31),
            CardHover = Color3.fromRGB(34, 34, 47),
            Text = Color3.fromRGB(244, 244, 248),
            Muted = Color3.fromRGB(166, 166, 180),
            Border = Color3.fromRGB(62, 62, 82),
            Accent = Color3.fromRGB(183, 112, 255),
            Accent2 = Color3.fromRGB(87, 90, 255),
            Success = Color3.fromRGB(75, 217, 126),
            Warning = Color3.fromRGB(239, 176, 67),
            Danger = Color3.fromRGB(255, 88, 118),
        },
        Aurora = {
            Background = Color3.fromRGB(4, 13, 17),
            Panel = Color3.fromRGB(7, 23, 28),
            Card = Color3.fromRGB(10, 34, 40),
            CardHover = Color3.fromRGB(14, 50, 56),
            Text = Color3.fromRGB(236, 255, 253),
            Muted = Color3.fromRGB(146, 188, 187),
            Border = Color3.fromRGB(34, 85, 87),
            Accent = Color3.fromRGB(38, 219, 205),
            Accent2 = Color3.fromRGB(90, 151, 255),
            Success = Color3.fromRGB(69, 235, 148),
            Warning = Color3.fromRGB(237, 189, 73),
            Danger = Color3.fromRGB(255, 93, 142),
        },
        Crimson = {
            Background = Color3.fromRGB(14, 6, 10),
            Panel = Color3.fromRGB(25, 9, 16),
            Card = Color3.fromRGB(38, 14, 24),
            CardHover = Color3.fromRGB(56, 20, 34),
            Text = Color3.fromRGB(255, 242, 247),
            Muted = Color3.fromRGB(192, 158, 171),
            Border = Color3.fromRGB(91, 39, 58),
            Accent = Color3.fromRGB(255, 75, 120),
            Accent2 = Color3.fromRGB(178, 67, 255),
            Success = Color3.fromRGB(70, 226, 132),
            Warning = Color3.fromRGB(240, 176, 62),
            Danger = Color3.fromRGB(255, 92, 93),
        },
    }

    local theme = Themes[Settings.Theme]
    local selectedPlayer = nil
    local selectedInfo = nil
    local isOpen = Settings.OpenOnStart
    local currentTab = "Personas"
    local tabButtons = {}
    local pages = {}

    local function create(className, properties, parent)
        local object = Instance.new(className)
        for property, value in pairs(properties or {}) do
            object[property] = value
        end
        object.Parent = parent
        return object
    end

    local function addCorner(parent, radius)
        return create("UICorner", { CornerRadius = UDim.new(0, radius or 12) }, parent)
    end

    local function addStroke(parent, color, transparency, thickness)
        return create("UIStroke", {
            Color = color or theme.Border,
            Transparency = transparency == nil and 0.15 or transparency,
            Thickness = thickness or 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, parent)
    end

    local function tween(object, properties, duration)
        if not object or not object.Parent then
            return
        end
        if not Settings.Animations then
            for property, value in pairs(properties) do
                object[property] = value
            end
            return
        end
        TweenService:Create(object, TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties):Play()
    end

    local GUI = create("ScreenGui", {
        Name = GUI_NAME,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 200,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Enabled = true,
    }, PlayerGui)

    local Backdrop = create("Frame", {
        Name = "Backdrop",
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = 0.06,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Visible = isOpen,
    }, GUI)

    local MainPanel = create("Frame", {
        Name = "MainPanel",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0.92, 0, 0.86, 0),
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
        Visible = isOpen,
    }, Backdrop)
    addCorner(MainPanel, 18)
    addStroke(MainPanel, theme.Border, 0.06, 1)

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(22, 13),
        Size = UDim2.new(1, -44, 0, 32),
        Text = "CUSTOM SOCIAL / PAUSE",
        TextColor3 = theme.Text,
        TextSize = 21,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, MainPanel)

    local subtitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(23, 44),
        Size = UDim2.new(1, -46, 0, 20),
        Text = "Interfaz local · P para abrir/cerrar · F8 para recuperar",
        TextColor3 = theme.Muted,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, MainPanel)

    local tabBar = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(20, 76),
        Size = UDim2.new(1, -40, 0, 42),
    }, MainPanel)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 7),
        VerticalAlignment = Enum.VerticalAlignment.Center,
    }, tabBar)

    local content = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(20, 128),
        Size = UDim2.new(1, -40, 1, -202),
    }, MainPanel)

    local footer = create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 20, 1, -17),
        Size = UDim2.new(1, -40, 0, 48),
    }, MainPanel)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 8),
    }, footer)

    local ToastHolder = create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.fromOffset(330, 180),
    }, GUI)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 6),
    }, ToastHolder)

    local function showToast(message, kind)
        local color = theme.Accent
        if kind == "success" then color = theme.Success end
        if kind == "warning" then color = theme.Warning end
        if kind == "danger" then color = theme.Danger end

        local toast = create("Frame", {
            BackgroundColor3 = theme.Card,
            BackgroundTransparency = 0.02,
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(330, 52),
        }, ToastHolder)
        addCorner(toast, 10)
        addStroke(toast, color, 0.05, 1)
        local stripe = create("Frame", {
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 4, 1, 0),
        }, toast)
        local messageLabel = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(15, 0),
            Size = UDim2.new(1, -24, 1, 0),
            Text = message,
            TextColor3 = theme.Text,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, toast)
        task.delay(3, function()
            if toast.Parent then toast:Destroy() end
        end)
    end

    local function makeButton(parent, text, size, color)
        local button = create("TextButton", {
            BackgroundColor3 = color or theme.Card,
            BackgroundTransparency = 0.03,
            BorderSizePixel = 0,
            Size = size,
            Text = text,
            TextColor3 = theme.Text,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
        }, parent)
        addCorner(button, 10)
        addStroke(button, color or theme.Border, 0.20, 1)
        button.MouseEnter:Connect(function()
            tween(button, { BackgroundColor3 = theme.CardHover }, 0.12)
        end)
        button.MouseLeave:Connect(function()
            tween(button, { BackgroundColor3 = color or theme.Card }, 0.12)
        end)
        return button
    end

    local function makePage(name)
        local page = create("Frame", {
            Name = name .. "Page",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Visible = false,
        }, content)
        pages[name] = page
        return page
    end

    local PersonasPage = makePage("Personas")
    local ConfigPage = makePage("Configuración")
    local GalleryPage = makePage("Galería")
    local ReportPage = makePage("Denunciar")
    local HelpPage = makePage("Ayuda")

    local function setTab(name)
        currentTab = name
        for pageName, page in pairs(pages) do
            page.Visible = pageName == name
        end
        for tabName, button in pairs(tabButtons) do
            local active = tabName == name
            button.BackgroundColor3 = active and theme.CardHover or theme.Panel
            button.TextColor3 = active and theme.Text or theme.Muted
        end
    end

    for _, tabName in ipairs({ "Personas", "Configuración", "Galería", "Denunciar", "Ayuda" }) do
        local tab = makeButton(tabBar, tabName, UDim2.fromOffset(tabName == "Configuración" and 135 or 112, 40), theme.Panel)
        tab.TextColor3 = theme.Muted
        tab.Activated:Connect(function() setTab(tabName) end)
        tabButtons[tabName] = tab
    end

    -- Personas page
    local playerTitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Text = "Jugadores de esta experiencia",
        TextColor3 = theme.Text,
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, PersonasPage)

    local refreshButton = makeButton(PersonasPage, "↻  Actualizar (R)", UDim2.fromOffset(140, 32), theme.Card)
    refreshButton.AnchorPoint = Vector2.new(1, 0)
    refreshButton.Position = UDim2.new(1, 0, 0, 0)

    local playerList = create("ScrollingFrame", {
        Name = "PlayerList",
        BackgroundColor3 = theme.Card,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 39),
        Size = UDim2.new(1, 0, 1, -39),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = theme.Accent,
    }, PersonasPage)
    addCorner(playerList, 12)
    addStroke(playerList, theme.Border, 0.18, 1)
    create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, playerList)
    create("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }, playerList)

    local function clearPlayerRows()
        for _, child in ipairs(playerList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
    end

    local function selectPlayer(player)
        selectedPlayer = player
        if selectedInfo then
            selectedInfo.Text = "Jugador seleccionado: " .. player.DisplayName .. " (@" .. player.Name .. ")"
            selectedInfo.TextColor3 = theme.Text
        end
        showToast("Seleccionado: " .. player.DisplayName, "success")
    end

    local function makePlayerRow(player, order)
        local row = create("Frame", {
            LayoutOrder = order,
            BackgroundColor3 = theme.Panel,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 68),
        }, playerList)
        addCorner(row, 10)
        addStroke(row, theme.Border, 0.34, 1)

        local avatar = create("ImageLabel", {
            BackgroundColor3 = theme.Card,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(9, 9),
            Size = UDim2.fromOffset(50, 50),
            Image = "",
        }, row)
        addCorner(avatar, 25)

        task.spawn(function()
            local ok, image = pcall(function()
                return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if ok and avatar.Parent then avatar.Image = image end
        end)

        local display = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(71, 10),
            Size = UDim2.new(1, -300, 0, 23),
            Text = player.DisplayName .. (player == LocalPlayer and "  (Tú)" or ""),
            TextColor3 = theme.Text,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        local username = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(71, 34),
            Size = UDim2.new(1, -300, 0, 19),
            Text = "@" .. player.Name,
            TextColor3 = theme.Muted,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local select = makeButton(row, "Seleccionar", UDim2.fromOffset(104, 36), theme.Card)
        select.AnchorPoint = Vector2.new(1, 0.5)
        select.Position = UDim2.new(1, -10, 0.5, 0)
        select.Activated:Connect(function() selectPlayer(player) end)
    end

    local function rebuildPlayerList()
        clearPlayerRows()
        local players = Players:GetPlayers()
        table.sort(players, function(a, b) return a.Name:lower() < b.Name:lower() end)
        for index, player in ipairs(players) do
            makePlayerRow(player, index)
        end
    end

    refreshButton.Activated:Connect(function()
        rebuildPlayerList()
        showToast("Lista de jugadores actualizada.", "success")
    end)

    -- Configuration page
    local configTitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        Text = "Configuración local",
        TextColor3 = theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, ConfigPage)

    local configCard = create("Frame", {
        BackgroundColor3 = theme.Card,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 42),
        Size = UDim2.new(1, 0, 0, 152),
    }, ConfigPage)
    addCorner(configCard, 12)
    addStroke(configCard, theme.Border, 0.2, 1)

    local configText = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(17, 12),
        Size = UDim2.new(1, -34, 1, -24),
        Text = "Estas opciones solo afectan a esta interfaz local.\n\nOcultar PlayerList nativo: " .. (Settings.HideLocalPlayerList and "activado" or "desactivado") .. "\nAnimaciones: " .. (Settings.Animations and "activadas" or "desactivadas"),
        TextColor3 = theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }, configCard)

    local playerListToggle = makeButton(ConfigPage, "Alternar PlayerList nativo", UDim2.fromOffset(210, 38), theme.Card)
    playerListToggle.Position = UDim2.fromOffset(0, 208)
    playerListToggle.Activated:Connect(function()
        Settings.HideLocalPlayerList = not Settings.HideLocalPlayerList
        safeSetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not Settings.HideLocalPlayerList)
        configText.Text = "Estas opciones solo afectan a esta interfaz local.\n\nOcultar PlayerList nativo: " .. (Settings.HideLocalPlayerList and "activado" or "desactivado") .. "\nAnimaciones: " .. (Settings.Animations and "activadas" or "desactivadas")
    end)

    -- Gallery page
    local galleryText = create("TextLabel", {
        BackgroundColor3 = theme.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "Galería\n\nEsta versión no carga contenido externo.\nPuedes usar esta página para añadir tus propios botones o colecciones locales.",
        TextColor3 = theme.Text,
        TextSize = 16,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
    }, GalleryPage)
    addCorner(galleryText, 12)
    addStroke(galleryText, theme.Border, 0.2, 1)

    -- Report / social actions page
    local reportTitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        Text = "Acciones sociales oficiales",
        TextColor3 = theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, ReportPage)

    selectedInfo = create("TextLabel", {
        BackgroundColor3 = theme.Card,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 42),
        Size = UDim2.new(1, 0, 0, 68),
        Text = "Selecciona una persona desde la pestaña Personas.",
        TextColor3 = theme.Muted,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
    }, ReportPage)
    addCorner(selectedInfo, 12)
    addStroke(selectedInfo, theme.Border, 0.20, 1)

    local actions = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 124),
        Size = UDim2.new(1, 0, 0, 92),
    }, ReportPage)
    create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8) }, actions)

    local friendButton = makeButton(actions, "Añadir amistad", UDim2.fromOffset(150, 42), theme.Card)
    local reportButton = makeButton(actions, "Denunciar", UDim2.fromOffset(115, 42), theme.Warning)
    local blockButton = makeButton(actions, "Bloquear", UDim2.fromOffset(115, 42), theme.Danger)

    local function getSelectedOtherPlayer()
        if not selectedPlayer then
            showToast("Primero selecciona un jugador en Personas.", "warning")
            return nil
        end
        if selectedPlayer == LocalPlayer then
            showToast("Esta acción no está disponible para tu propio jugador.", "warning")
            return nil
        end
        return selectedPlayer
    end

    friendButton.Activated:Connect(function()
        local player = getSelectedOtherPlayer()
        if not player then return end
        local ok = safeSetCore("PromptSendFriendRequest", player)
        if ok then
            showToast("Se abrió el aviso oficial de solicitud de amistad.", "success")
        else
            showToast("Roblox no pudo abrir la solicitud de amistad ahora.", "warning")
        end
    end)

    reportButton.Activated:Connect(function()
        local player = getSelectedOtherPlayer()
        if not player then return end
        local ok = safeSetCore("PromptReportPlayer", player)
        if ok then
            showToast("Se abrió el aviso oficial de denuncia.", "success")
        else
            showToast("El aviso de denuncia no está disponible en este contexto.", "warning")
        end
    end)

    blockButton.Activated:Connect(function()
        local player = getSelectedOtherPlayer()
        if not player then return end
        local ok = safeSetCore("PromptBlockPlayer", player)
        if ok then
            showToast("Se abrió el aviso oficial de bloqueo.", "success")
        else
            showToast("El aviso de bloqueo no está disponible en este contexto.", "warning")
        end
    end)

    -- Help page
    local help = create("TextLabel", {
        BackgroundColor3 = theme.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "AYUDA\n\nP   → Mostrar u ocultar esta interfaz.\nR   → Actualizar la lista de jugadores cuando la interfaz está abierta.\nF8  → Emergencia: desactiva la GUI personalizada y restaura el PlayerList nativo.\n\nRegenerar usa LoadCharacterAsync(). Las acciones de amistad, denuncia y bloqueo intentan abrir los avisos oficiales de Roblox mediante StarterGui:SetCore(), protegidos para que un fallo no rompa la interfaz.\n\nSalir intenta game:Shutdown() dentro de pcall(). Si no está disponible, se desactiva esta GUI y se restaura el PlayerList.",
        TextColor3 = theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }, HelpPage)
    addCorner(help, 12)
    addStroke(help, theme.Border, 0.2, 1)
    create("UIPadding", { PaddingTop = UDim.new(0, 18), PaddingBottom = UDim.new(0, 18), PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18) }, help)

    -- Footer controls
    local resumeButton = makeButton(footer, "Reanudar · P", UDim2.fromOffset(138, 43), theme.Accent)
    local respawnButton = makeButton(footer, "Regenerar", UDim2.fromOffset(116, 43), theme.Card)
    local exitButton = makeButton(footer, "Salir", UDim2.fromOffset(92, 43), theme.Danger)

    local function setOpen(open)
        isOpen = open
        if not GUI.Enabled then return end
        Backdrop.Visible = open
        MainPanel.Visible = open
        if open then
            rebuildPlayerList()
        end
    end

    resumeButton.Activated:Connect(function() setOpen(false) end)

    respawnButton.Activated:Connect(function()
        local ok, err = pcall(function()
            LocalPlayer:LoadCharacterAsync()
        end)
        if ok then
            showToast("Regenerando personaje…", "success")
        else
            warn("CustomSocialPauseGUI: LoadCharacterAsync failed:", err)
            showToast("No se pudo regenerar el personaje.", "warning")
        end
    end)

    exitButton.Activated:Connect(function()
        -- Requested test only: if unavailable, the safe fallback below is used.
        local ok, err = pcall(function()
            game:Shutdown()
        end)
        if not ok then
            warn("CustomSocialPauseGUI: game:Shutdown() failed:", err)
            showToast("No se pudo cerrar; se activó el modo de recuperación.", "warning")
            emergencyDisableCustomGui()
        end
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.P then
            setOpen(not isOpen)
        elseif input.KeyCode == Enum.KeyCode.R and isOpen then
            rebuildPlayerList()
            showToast("Lista de jugadores actualizada.", "success")
        end
    end)

    Players.PlayerAdded:Connect(function()
        if isOpen then rebuildPlayerList() end
    end)
    Players.PlayerRemoving:Connect(function()
        if isOpen then task.defer(rebuildPlayerList) end
    end)

    if Settings.HideLocalPlayerList then
        safeSetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    end

    rebuildPlayerList()
    setTab("Personas")
end)

if buildOk then
    hideRecovery()
else
    warn("CustomSocialPauseGUI: main GUI build failed:", buildError)
    showRecovery()
end
