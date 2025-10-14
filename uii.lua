-- UI Script for Astralis using LinoriaLib
local library = loadstring(
    game:HttpGet(
        'https://raw.githubusercontent.com/randomahhnamecauseimtoolazy/chat/refs/heads/main/lib.lua'
    )
)()

-- Access global Settings and functions from the main script
local Settings = getgenv().Settings
if not Settings then
    error('Settings table not found. Ensure the main script is loaded first.')
end

-- Create Window
local Window = Library:CreateWindow({
    Title = 'Astralis',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2,
})

-- Define Tabs
local Tabs = {
    Main = Window:AddTab('Main'),
    Mods = Window:AddTab('Mods'),
    Visuals = Window:AddTab('Visuals'),
    Player = Window:AddTab('Player'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Gun Modifications Section
local GunModsGroup = Tabs.Mods:AddLeftGroupbox('Gun Modifications')
GunModsGroup:AddSlider('NoRecoil', {
    Text = 'Recoil Reduction %',
    Default = Settings.GunMods.NoRecoil,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(v)
        Settings.GunMods.NoRecoil = v
    end,
})

GunModsGroup:AddToggle('NoSpread', {
    Text = 'No Spread',
    Default = Settings.GunMods.NoSpread,
    Callback = function(s)
        Settings.GunMods.NoSpread = s
    end,
})

GunModsGroup:AddToggle('NoSway', {
    Text = 'No Gun Sway',
    Default = Settings.GunMods.NoSway,
    Callback = function(s)
        Settings.GunMods.NoSway = s
    end,
})

GunModsGroup:AddToggle('NoSniperScope', {
    Text = 'No Sniper Scope',
    Default = Settings.GunMods.NoSniperScope,
    Callback = function(s)
        Settings.GunMods.NoSniperScope = s
    end,
})

GunModsGroup:AddToggle('InstantReload', {
    Text = 'Instant Reload',
    Default = Settings.GunMods.InstantReload,
    Callback = function(s)
        Settings.GunMods.InstantReload = s
    end,
})

GunModsGroup:AddToggle('AutoReload', {
    Text = 'No Reload',
    Default = Settings.GunMods.AutoReload,
    Callback = function(s)
        Settings.GunMods.AutoReload = s
    end,
})

GunModsGroup:AddToggle('NoWalkSway', {
    Text = 'No Walk Sway',
    Default = Settings.GunMods.NoWalkSway,
    Callback = function(s)
        Settings.GunMods.NoWalkSway = s
    end,
})

-- Camera Modifications Section
local CamModsGroup = Tabs.Mods:AddRightGroupbox('Camera Modifications')
CamModsGroup:AddToggle('NoCameraBob', {
    Text = 'No Camera Bob',
    Default = Settings.GunMods.NoCameraBob,
    Callback = function(s)
        Settings.GunMods.NoCameraBob = s
    end,
})

-- Crosshair Section
local CrosshairGroup = Tabs.Misc:AddLeftGroupbox('Crosshair')
CrosshairGroup:AddToggle('CrosshairEnabled', {
    Text = 'Enabled',
    Default = Settings.Crosshair.Enabled,
    Callback = function(s)
        Settings.Crosshair.Enabled = s
        getgenv().toggleCrosshair(s)
    end,
})

CrosshairGroup:AddDropdown('CrosshairStyle', {
    Text = 'Style',
    Values = { 'Default', 'Plus' },
    Default = Settings.Crosshair.TStyle,
    Callback = function(v)
        Settings.Crosshair.TStyle = v
    end,
})

CrosshairGroup:AddToggle('CrosshairDot', {
    Text = 'Center Dot',
    Default = Settings.Crosshair.Dot,
    Callback = function(s)
        Settings.Crosshair.Dot = s
    end,
})

CrosshairGroup:AddSlider('CrosshairSize', {
    Text = 'Size',
    Default = Settings.Crosshair.Size,
    Min = 1,
    Max = 30,
    Rounding = 0,
    Callback = function(v)
        Settings.Crosshair.Size = v
    end,
})

CrosshairGroup:AddSlider('CrosshairThickness', {
    Text = 'Thickness',
    Default = Settings.Crosshair.Thickness,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Callback = function(v)
        Settings.Crosshair.Thickness = v
    end,
})

CrosshairGroup:AddSlider('CrosshairGap', {
    Text = 'Gap',
    Default = Settings.Crosshair.Gap,
    Min = 0,
    Max = 20,
    Rounding = 0,
    Callback = function(v)
        Settings.Crosshair.Gap = v
    end,
})

CrosshairGroup:AddLabel('Color'):AddColorPicker('CrosshairColor', {
    Default = Settings.Crosshair.Color,
    Transparency = 0,
    Callback = function(v)
        Settings.Crosshair.Color = v
    end,
})

CrosshairGroup:AddSlider('CrosshairTransparency', {
    Text = 'Transparency',
    Default = Settings.Crosshair.Transparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(v)
        Settings.Crosshair.Transparency = v
    end,
})

-- Third Person Section
local ThirdPersonGroup = Tabs.Player:AddLeftGroupbox('Third Person')
ThirdPersonGroup:AddToggle('ThirdPersonEnabled', {
    Text = 'Enabled',
    Default = Settings.ThirdPerson.Enabled,
    Callback = function(s)
        Settings.ThirdPerson.Enabled = s
        if charInterface.isAlive() and Settings.ThirdPerson.ShowCharacter then
            if s then
                started = true
            else
                fakeRepObject:despawn()
                if currentObj then
                    currentObj:Destroy()
                    currentObj = nil
                    lastPos = nil
                end
            end
        end
    end,
})

ThirdPersonGroup:AddToggle('ThirdPersonShowCharacter', {
    Text = 'Show Character',
    Default = Settings.ThirdPerson.ShowCharacter,
    Callback = function(s)
        Settings.ThirdPerson.ShowCharacter = s
        if
            getgenv().charInterface
            and getgenv().charInterface.isAlive()
            and Settings.ThirdPerson.Enabled
        then
            if s then
                getgenv().started = true
            else
                getgenv().fakeRepObject:despawn()
                if getgenv().currentObj then
                    getgenv().currentObj:Destroy()
                    getgenv().currentObj = nil
                    getgenv().lastPos = nil
                end
            end
        end
    end,
})

ThirdPersonGroup:AddToggle('ThirdPersonShowCharacterWhileAiming', {
    Text = 'Show Character While Aiming',
    Default = Settings.ThirdPerson.ShowCharacterWhileAiming,
    Callback = function(s)
        Settings.ThirdPerson.ShowCharacterWhileAiming = s
    end,
})

ThirdPersonGroup:AddToggle('ThirdPersonCameraOffsetAlwaysVisible', {
    Text = 'Camera Offset Always Visible',
    Default = Settings.ThirdPerson.CameraOffsetAlwaysVisible,
    Callback = function(s)
        Settings.ThirdPerson.CameraOffsetAlwaysVisible = s
    end,
})

ThirdPersonGroup:AddToggle('ThirdPersonHideViewmodel', {
    Text = 'Hide Viewmodel',
    Default = Settings.ThirdPerson.HideViewmodel,
    Callback = function(s)
        Settings.ThirdPerson.HideViewmodel = s
    end,
})

ThirdPersonGroup:AddSlider('ThirdPersonCameraOffsetX', {
    Text = 'Camera Offset X',
    Default = Settings.ThirdPerson.CameraOffsetX,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Callback = function(v)
        Settings.ThirdPerson.CameraOffsetX = v
    end,
})

ThirdPersonGroup:AddSlider('ThirdPersonCameraOffsetY', {
    Text = 'Camera Offset Y',
    Default = Settings.ThirdPerson.CameraOffsetY,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Callback = function(v)
        Settings.ThirdPerson.CameraOffsetY = v
    end,
})

ThirdPersonGroup:AddSlider('ThirdPersonCameraOffsetZ', {
    Text = 'Camera Offset Z',
    Default = Settings.ThirdPerson.CameraOffsetZ,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Callback = function(v)
        Settings.ThirdPerson.CameraOffsetZ = v
    end,
})

-- Aimbot Section
local AimbotGroup = Tabs.Main:AddLeftGroupbox('Aimbot')
AimbotGroup:AddToggle('AimbotEnabled', {
    Text = 'Enabled',
    Default = Settings.Aimbot.Enabled,
    Callback = function(s)
        Settings.Aimbot.Enabled = s
        if s then
            getgenv().startMousePreload()
            getgenv().State.InputBeganConnection = getgenv().UserInputService.InputBegan:Connect(
                function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton2 then
                        getgenv().State.IsRightClickHeld = true
                        getgenv().State.TargetPart = getgenv().getClosestPlayer(
                            nil,
                            Settings.Aimbot.HitPart
                        )
                    end
                end
            )
            getgenv().State.InputEndedConnection = getgenv().UserInputService.InputEnded:Connect(
                function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton2 then
                        getgenv().State.IsRightClickHeld = false
                        getgenv().State.TargetPart = nil
                    end
                end
            )
            getgenv().State.RenderSteppedConnection = getgenv().RunService.RenderStepped:Connect(
                function()
                    if
                        getgenv().State.IsRightClickHeld
                        and getgenv().State.TargetPart
                    then
                        if Settings.Aimbot.WallCheck then
                            if
                                getgenv().isVisible(
                                    getgenv().State.TargetPart,
                                    true
                                )
                            then
                                getgenv().aimAt()
                            end
                        else
                            getgenv().aimAt()
                        end
                    end
                end
            )
        else
            getgenv().stopMousePreload()
            if getgenv().State.InputBeganConnection then
                getgenv().State.InputBeganConnection:Disconnect()
            end
            if getgenv().State.InputEndedConnection then
                getgenv().State.InputEndedConnection:Disconnect()
            end
            if getgenv().State.RenderSteppedConnection then
                getgenv().State.RenderSteppedConnection:Disconnect()
            end
        end
    end,
})

AimbotGroup:AddDropdown('AimbotHitPart', {
    Text = 'Hit Part',
    Values = { 'Head', 'Torso', 'Closest Part' },
    Default = Settings.Aimbot.HitPart,
    Callback = function(v)
        Settings.Aimbot.HitPart = v
    end,
})

AimbotGroup:AddToggle('AimbotWallCheck', {
    Text = 'Wall Check',
    Default = Settings.Aimbot.WallCheck,
    Callback = function(s)
        Settings.Aimbot.WallCheck = s
    end,
})

AimbotGroup:AddToggle('AimbotAutoTargetSwitch', {
    Text = 'Auto Target Switch',
    Default = Settings.Aimbot.AutoTargetSwitch,
    Callback = function(s)
        Settings.Aimbot.AutoTargetSwitch = s
    end,
})

AimbotGroup:AddToggle('AimbotMaxDistanceEnabled', {
    Text = 'Use Max Distance',
    Default = Settings.Aimbot.MaxDistance.Enabled,
    Callback = function(s)
        Settings.Aimbot.MaxDistance.Enabled = s
    end,
})

AimbotGroup:AddSlider('AimbotMaxDistance', {
    Text = 'Max Distance',
    Default = Settings.Aimbot.MaxDistance.Value,
    Min = 10,
    Max = 1000,
    Rounding = 0,
    Callback = function(v)
        Settings.Aimbot.MaxDistance.Value = v
    end,
})

AimbotGroup:AddSlider('AimbotEasingStrength', {
    Text = 'Strength',
    Default = Settings.Aimbot.Easing.Strength,
    Min = 0.1,
    Max = 1.5,
    Rounding = 1,
    Callback = function(v)
        Settings.Aimbot.Easing.Strength = v
        getgenv().updateSensitivity(v)
    end,
})

-- Silent Aim Section
local SilentAimGroup = Tabs.Main:AddLeftGroupbox('Silent Aim')
SilentAimGroup:AddToggle('SilentAimEnabled', {
    Text = 'Enabled',
    Default = Settings.SilentAim.Enabled,
    Callback = function(s)
        Settings.SilentAim.Enabled = s
        if s then
            getgenv().initializeSilentAim()
        end
    end,
})

SilentAimGroup:AddDropdown('SilentAimHitPart', {
    Text = 'Hit Part',
    Values = { 'Head', 'Torso', 'Closest Part' },
    Default = Settings.SilentAim.HitPart,
    Callback = function(v)
        Settings.SilentAim.HitPart = v
    end,
})

SilentAimGroup:AddSlider('SilentAimHitChance', {
    Text = 'Hit Chance',
    Default = Settings.SilentAim.HitChance,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(v)
        Settings.SilentAim.HitChance = v
    end,
})

SilentAimGroup:AddToggle('SilentAimUseFOV', {
    Text = 'Use FOV',
    Default = Settings.SilentAim.UseFOV,
    Callback = function(s)
        Settings.SilentAim.UseFOV = s
    end,
})

SilentAimGroup:AddToggle('SilentAimWallCheck', {
    Text = 'Wall Check',
    Default = Settings.SilentAim.WallCheck,
    Callback = function(s)
        Settings.SilentAim.WallCheck = s
    end,
})

SilentAimGroup:AddToggle('SnaplineEnabled', {
    Text = 'Snaplines',
    Default = Settings.Snapline.Enabled,
    Callback = function(s)
        Settings.Snapline.Enabled = s
        if s then
            getgenv().State.SnaplineUpdate =
                getgenv().RunService.RenderStepped:Connect(
                    getgenv().updateSnapline
                )
        else
            if getgenv().State.SnaplineUpdate then
                getgenv().State.SnaplineUpdate:Disconnect()
                getgenv().State.SnaplineUpdate = nil
            end
            Settings.Snapline.Line.Visible = false
        end
    end,
})

-- Force Hit Section
local ForceHitGroup = Tabs.Main:AddLeftGroupbox('Force Hit')
ForceHitGroup:AddToggle('ForceHitEnabled', {
    Text = 'Enabled',
    Default = Settings.ForceHit.Enabled,
    Callback = function(s)
        Settings.ForceHit.Enabled = s
    end,
})

ForceHitGroup:AddDropdown('ForceHitHitPart', {
    Text = 'Hit Part',
    Values = { 'Closest Part', 'Head' },
    Default = Settings.ForceHit.HitPart,
    Callback = function(v)
        Settings.ForceHit.HitPart = v
    end,
})

ForceHitGroup:AddToggle('ForceHitUseFOV', {
    Text = 'Use FOV',
    Default = Settings.ForceHit.UseFOV,
    Callback = function(s)
        Settings.ForceHit.UseFOV = s
    end,
})

-- ESP Section
local ESPGroup = Tabs.Visuals:AddLeftGroupbox('ESP')
ESPGroup:AddToggle('ESPEnabled', {
    Text = 'Enabled',
    Default = Settings.ESP.Enabled,
    Callback = function(s)
        Settings.ESP.Enabled = s
        if s then
            getgenv().initializeESP()
            getgenv().State.PlayerCacheUpdate =
                getgenv().RunService.Heartbeat:Connect(
                    getgenv().updatePlayerCache
                )
            local last = tick()
            local interval = 1 / 240
            getgenv().State.ESPLoop = getgenv().RunService.Heartbeat:Connect(
                function()
                    local now = tick()
                    if now - last >= interval then
                        getgenv().renderESP()
                        last = now
                    end
                end
            )
        else
            if getgenv().State.PlayerCacheUpdate then
                getgenv().State.PlayerCacheUpdate:Disconnect()
            end
            if getgenv().State.ESPLoop then
                getgenv().State.ESPLoop:Disconnect()
            end
            for p in getgenv().State.Storage.ESPCache do
                getgenv().uncacheObject(p)
            end
            getgenv().State.PlayersToDraw = {}
            getgenv().State.CachedProperties = {}
        end
    end,
})

local function updateESPFeature(f, s)
    Settings.ESP.Features[f].Enabled = s
    getgenv().updateESPFeature(f, s)
end

ESPGroup:AddToggle('ESPBox', {
    Text = 'Box',
    Default = Settings.ESP.Features.Box.Enabled,
    Callback = function(s)
        updateESPFeature('Box', s)
    end,
})

ESPGroup:AddToggle('ESPTracer', {
    Text = 'Tracer',
    Default = Settings.ESP.Features.Tracer.Enabled,
    Callback = function(s)
        updateESPFeature('Tracer', s)
    end,
})

ESPGroup:AddToggle('ESPHeadDot', {
    Text = 'Head Dot',
    Default = Settings.ESP.Features.HeadDot.Enabled,
    Callback = function(s)
        updateESPFeature('HeadDot', s)
    end,
})

ESPGroup:AddToggle('ESPDistance', {
    Text = 'Distance',
    Default = Settings.ESP.Features.DistanceText.Enabled,
    Callback = function(s)
        updateESPFeature('DistanceText', s)
    end,
})

ESPGroup:AddToggle('ESPName', {
    Text = 'Name',
    Default = Settings.ESP.Features.Name.Enabled,
    Callback = function(s)
        updateESPFeature('Name', s)
    end,
})

ESPGroup:AddToggle('ESPVisibilityCheck', {
    Text = 'Wall Check',
    Default = Settings.ESP.VisibilityCheck,
    Callback = function(s)
        Settings.ESP.VisibilityCheck = s
    end,
})

-- ESP Colors Section
local ESPCustomization = Tabs.Visuals:AddRightGroupbox('ESP Colors')
local function updateESPColor(f, c)
    Settings.ESP.Features[f].Color = c
    for _, cache in getgenv().State.Storage.ESPCache do
        if f == 'Box' then
            cache.BoxSquare.Color = c
        elseif f == 'Tracer' then
            cache.TracerLine.Color = c
        elseif f == 'HeadDot' then
            cache.HeadDot.Color = c
        elseif f == 'DistanceText' then
            cache.DistanceLabel.Color = c
        elseif f == 'Name' then
            cache.NameLabel.Color = c
        end
    end
end

ESPCustomization:AddLabel('Box Color'):AddColorPicker('ESPBoxColor', {
    Default = Settings.ESP.Features.Box.Color,
    Callback = function(v)
        updateESPColor('Box', v)
    end,
})

ESPCustomization:AddLabel('Tracer Color'):AddColorPicker('ESPTracerColor', {
    Default = Settings.ESP.Features.Tracer.Color,
    Callback = function(v)
        updateESPColor('Tracer', v)
    end,
})

ESPCustomization:AddLabel('Distance Color'):AddColorPicker('ESPDistanceColor', {
    Default = Settings.ESP.Features.DistanceText.Color,
    Callback = function(v)
        updateESPColor('DistanceText', v)
    end,
})

ESPCustomization:AddLabel('Head Dot Color'):AddColorPicker('ESPHeadDotColor', {
    Default = Settings.ESP.Features.HeadDot.Color,
    Callback = function(v)
        updateESPColor('HeadDot', v)
    end,
})

ESPCustomization:AddLabel('Name Color'):AddColorPicker('ESPNameColor', {
    Default = Settings.ESP.Features.Name.Color,
    Callback = function(v)
        updateESPColor('Name', v)
    end,
})

ESPGroup:AddToggle('ESPHealthBar', {
    Text = 'Health Bar',
    Default = Settings.ESP.Features.HealthBar.Enabled,
    Callback = function(s)
        Settings.ESP.Features.HealthBar.Enabled = s
        for _, c in getgenv().State.Storage.ESPCache do
            if c.HealthBarBackground then
                c.HealthBarBackground.Visible = s
            end
            if c.HealthBarForeground then
                c.HealthBarForeground.Visible = s
            end
        end
    end,
})

ESPCustomization:AddLabel('Health Bar Color')
    :AddColorPicker('ESPHealthBarColor', {
        Default = Settings.ESP.Features.HealthBar.Color,
        Callback = function(v)
            Settings.ESP.Features.HealthBar.Color = v
            for _, cache in getgenv().State.Storage.ESPCache do
                if cache.HealthBarForeground then
                    cache.HealthBarForeground.Color = v
                end
            end
        end,
    })

ESPCustomization:AddLabel('Health Bar Background')
    :AddColorPicker('ESPHealthBarBG', {
        Default = Settings.ESP.Features.HealthBar.BackgroundColor,
        Callback = function(v)
            Settings.ESP.Features.HealthBar.BackgroundColor = v
            for _, cache in getgenv().State.Storage.ESPCache do
                if cache.HealthBarBackground then
                    cache.HealthBarBackground.Color = v
                end
            end
        end,
    })

ESPCustomization:AddLabel('Snapline Color'):AddColorPicker('SnaplineColor', {
    Default = Settings.Snapline.Color,
    Transparency = Settings.Snapline.Transparency,
    Callback = function(v)
        Settings.Snapline.Color = v
        Settings.Snapline.Line.Color = v
    end,
})

ESPCustomization:AddSlider('SnaplineThickness', {
    Text = 'Snapline Thickness',
    Default = Settings.Snapline.Thickness,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Callback = function(v)
        Settings.Snapline.Thickness = v
        Settings.Snapline.Line.Thickness = v
    end,
})

ESPCustomization:AddSlider('SnaplineTransparency', {
    Text = 'Snapline Transparency',
    Default = Settings.Snapline.Transparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(v)
        Settings.Snapline.Transparency = v
        Settings.Snapline.Line.Transparency = v
    end,
})

-- Health Bar Settings Section
local HealthBarCustomization =
    Tabs.Visuals:AddRightGroupbox('Health Bar Settings')
HealthBarCustomization:AddSlider('ESPHealthBarWidth', {
    Text = 'Width',
    Default = Settings.ESP.Features.HealthBar.Width,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Callback = function(v)
        Settings.ESP.Features.HealthBar.Width = v
    end,
})

HealthBarCustomization:AddSlider('ESPHealthBarHeight', {
    Text = 'Height',
    Default = Settings.ESP.Features.HealthBar.Height,
    Min = 10,
    Max = 80,
    Rounding = 0,
    Callback = function(v)
        Settings.ESP.Features.HealthBar.Height = v
    end,
})

HealthBarCustomization:AddLabel('Outline Color')
    :AddColorPicker('ESPHealthBarOutlineColor', {
        Default = Settings.ESP.Features.HealthBar.OutlineColor,
        Transparency = 0.7,
        Callback = function(v)
            Settings.ESP.Features.HealthBar.OutlineColor = v
            for _, cache in getgenv().State.Storage.ESPCache do
                if cache.HealthBarOutline then
                    cache.HealthBarOutline.Color = v
                end
            end
        end,
    })

-- Distance Settings Section
local DistanceCustomization = Tabs.Visuals:AddRightGroupbox('Distance Settings')
DistanceCustomization:AddToggle('ESPMaxDistanceEnabled', {
    Text = 'Use Max Distance',
    Default = Settings.ESP.MaxDistance.Enabled,
    Callback = function(s)
        Settings.ESP.MaxDistance.Enabled = s
        getgenv().refreshPlayerCache()
    end,
})

DistanceCustomization:AddSlider('ESPMaxDistance', {
    Text = 'Max Distance',
    Default = Settings.ESP.MaxDistance.Value,
    Min = 50,
    Max = 1000,
    Rounding = 0,
    Callback = function(v)
        Settings.ESP.MaxDistance.Value = v
        getgenv().refreshPlayerCache()
    end,
})

-- FOV Section
local FOVGroup = Tabs.Main:AddRightGroupbox('FOV')
FOVGroup:AddToggle('FOVEnabled', {
    Text = 'Show FOV Circle',
    Default = Settings.FOV.Enabled,
    Callback = function(s)
        Settings.FOV.Enabled = s
        Settings.FOV.Circle.Visible = s
        Settings.FOV.OutlineCircle.Visible = s
    end,
})

FOVGroup:AddToggle('FOVFollowGun', {
    Text = 'Follow Gun',
    Default = Settings.FOV.FollowGun,
    Callback = function(s)
        Settings.FOV.FollowGun = s
    end,
})

FOVGroup:AddToggle('FOVFilled', {
    Text = 'Fill FOV Circle',
    Default = Settings.FOV.Filled,
    Callback = function(s)
        Settings.FOV.Filled = s
        Settings.FOV.Circle.Filled = s
        Settings.FOV.Circle.Color = s and Settings.FOV.FillColor
            or Settings.FOV.OutlineColor
        Settings.FOV.Circle.Transparency = s and Settings.FOV.FillTransparency
            or Settings.FOV.OutlineTransparency
        Settings.FOV.Circle.Thickness = s and 0 or 1
        if Settings.FOV.Enabled then
            Settings.FOV.Circle.Visible = true
        end
    end,
})

FOVGroup:AddLabel('Inline Color'):AddColorPicker('FOVFillColor', {
    Default = Settings.FOV.FillColor,
    Transparency = Settings.FOV.FillTransparency,
    Callback = function(v)
        Settings.FOV.FillColor = v
        if Settings.FOV.Filled then
            Settings.FOV.Circle.Color = v
        end
    end,
})

FOVGroup:AddSlider('FOVFillTransparency', {
    Text = 'Inline Transparency',
    Default = Settings.FOV.FillTransparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(v)
        Settings.FOV.FillTransparency = v
        if Settings.FOV.Filled then
            Settings.FOV.Circle.Transparency = v
        end
    end,
})

FOVGroup:AddLabel('Outline Color'):AddColorPicker('FOVOutlineColor', {
    Default = Settings.FOV.OutlineColor,
    Transparency = Settings.FOV.OutlineTransparency,
    Callback = function(v)
        Settings.FOV.OutlineColor = v
        Settings.FOV.OutlineCircle.Color = v
        if not Settings.FOV.Filled then
            Settings.FOV.Circle.Color = v
        end
    end,
})

FOVGroup:AddSlider('FOVOutlineTransparency', {
    Text = 'Outline Transparency',
    Default = Settings.FOV.OutlineTransparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(v)
        Settings.FOV.OutlineTransparency = v
        Settings.FOV.OutlineCircle.Transparency = v
        if not Settings.FOV.Filled then
            Settings.FOV.Circle.Transparency = v
        end
    end,
})

FOVGroup:AddSlider('FOVRadius', {
    Text = 'FOV Radius',
    Default = Settings.FOV.Radius,
    Min = 5,
    Max = 1000,
    Rounding = 0,
    Callback = function(v)
        Settings.FOV.Radius = v
        Settings.FOV.Circle.Radius = v
        Settings.FOV.OutlineCircle.Radius = v
        getgenv().State.ogRadius = { v, v, v }
    end,
})

FOVGroup:AddToggle('FOVDynamic', {
    Text = 'Dynamic FOV',
    Default = Settings.FOV.Dynamic,
    Callback = function(s)
        Settings.FOV.Dynamic = s
    end,
})

-- Chams Section
local ChamsGroup = Tabs.Visuals:AddLeftGroupbox('Chams')
ChamsGroup:AddToggle('ChamsEnabled', {
    Text = 'Enabled',
    Default = Settings.Chams.Enabled,
    Callback = function(s)
        Settings.Chams.Enabled = s
        if s then
            getgenv().State.ChamsUpdateConnection =
                getgenv().RunService.RenderStepped:Connect(
                    getgenv().updateChams
                )
        else
            if getgenv().State.ChamsUpdateConnection then
                getgenv().State.ChamsUpdateConnection:Disconnect()
                getgenv().State.ChamsUpdateConnection = nil
            end
            for p in getgenv().State.Highlights do
                getgenv().removeHighlight(p)
            end
        end
    end,
})

ChamsGroup:AddLabel('Fill Color'):AddColorPicker('ChamsFillColor', {
    Default = Settings.Chams.Fill.Color,
    Transparency = Settings.Chams.Fill.Transparency,
    Callback = function(v)
        Settings.Chams.Fill.Color = v
        for _, h in getgenv().State.Highlights do
            h.FillColor = v
        end
    end,
})

ChamsGroup:AddLabel('Outline Color'):AddColorPicker('ChamsOutlineColor', {
    Default = Settings.Chams.Outline.Color,
    Transparency = Settings.Chams.Outline.Transparency,
    Callback = function(v)
        Settings.Chams.Outline.Color = v
        for _, h in getgenv().State.Highlights do
            h.OutlineColor = v
        end
    end,
})

ChamsGroup:AddSlider('ChamsFillTransparency', {
    Text = 'Fill Transparency',
    Default = Settings.Chams.Fill.Transparency,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Callback = function(v)
        Settings.Chams.Fill.Transparency = v
        for _, h in getgenv().State.Highlights do
            h.FillTransparency = v
        end
    end,
})

ChamsGroup:AddSlider('ChamsOutlineTransparency', {
    Text = 'Outline Transparency',
    Default = Settings.Chams.Outline.Transparency,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Callback = function(v)
        Settings.Chams.Outline.Transparency = v
        for _, h in getgenv().State.Highlights do
            h.OutlineTransparency = v
        end
    end,
})

-- Player Section
local PlayerGroup = Tabs.Player:AddLeftGroupbox('Player')
PlayerGroup:AddToggle('BhopEnabled', {
    Text = 'Bunny Hop',
    Default = Settings.Player.Bhop.Enabled,
    Callback = function(s)
        Settings.Player.Bhop.Enabled = s
    end,
})

PlayerGroup:AddToggle('WalkSpeedEnabled', {
    Text = 'Walk Speed',
    Default = Settings.Player.WalkSpeed.Enabled,
    Callback = function(s)
        Settings.Player.WalkSpeed.Enabled = s
        getgenv().callbackList['Player%%WalkSpeed'](s)
    end,
})

PlayerGroup:AddSlider('WalkSpeedValue', {
    Text = 'Walk Speed Value',
    Default = Settings.Player.WalkSpeed.Value,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(v)
        Settings.Player.WalkSpeed.Value = v
        if Settings.Player.WalkSpeed.Enabled then
            getgenv().callbackList['Player%%WalkSpeedValue'](v)
        end
    end,
})

PlayerGroup:AddToggle('JumpPowerEnabled', {
    Text = 'Jump Power',
    Default = Settings.Player.JumpPower.Enabled,
    Callback = function(s)
        Settings.Player.JumpPower.Enabled = s
    end,
})

PlayerGroup:AddSlider('JumpPowerValue', {
    Text = 'Jump Height Addition',
    Default = Settings.Player.JumpPower.Value,
    Min = 0,
    Max = 20,
    Rounding = 0,
    Callback = function(v)
        Settings.Player.JumpPower.Value = v
    end,
})

-- Anti-Aim Section
local AntiAimGroup = Tabs.Player:AddRightGroupbox('Anti-Aim')
AntiAimGroup:AddToggle('AntiAimEnabled', {
    Text = 'Enabled',
    Default = Settings.AntiAim.Enabled,
    Callback = function(s)
        Settings.AntiAim.Enabled = s
        getgenv().startTime = os.clock()
        getgenv().lastFrameTime = nil
        if s then
            getgenv().State.AntiAimConnection = getgenv().RunService.Heartbeat:Connect(
                function()
                    if
                        Settings.AntiAim.Enabled
                        and getgenv().charInterface.isAlive()
                    then
                        local currentCharObject =
                            getgenv().charInterface.getCharacterObject()
                        if currentCharObject then
                            local rootPart = currentCharObject:getRealRootPart()
                            if rootPart then
                                local angles = getgenv().cameraInterface
                                    :getActiveCamera()
                                    :getAngles()
                                local modifiedAngles =
                                    getgenv().applyAAAngles(angles)
                            end
                        end
                    end
                end
            )
        else
            if getgenv().State.AntiAimConnection then
                getgenv().State.AntiAimConnection:Disconnect()
                getgenv().State.AntiAimConnection = nil
            end
            local currentCharObject =
                getgenv().charInterface.getCharacterObject()
            if currentCharObject then
                currentCharObject:setStance('stand')
                getgenv().network:send('stance', 'stand')
                if Settings.ThirdPerson.Enabled and getgenv().currentObj then
                    getgenv().currentObj:setStance('stand')
                end
            end
        end
    end,
})

AntiAimGroup:AddDropdown('AntiAimMode', {
    Text = 'Mode',
    Values = { 'Spin', 'Jitter', 'Static', 'Hide' },
    Default = Settings.AntiAim.Mode,
    Callback = function(v)
        Settings.AntiAim.Mode = v
    end,
})

AntiAimGroup:AddSlider('AntiAimSpinSpeed', {
    Text = 'Spin Speed',
    Default = Settings.AntiAim.SpinSpeed,
    Min = 10,
    Max = 5000,
    Rounding = 0,
    Callback = function(v)
        Settings.AntiAim.SpinSpeed = v
    end,
})

AntiAimGroup:AddSlider('AntiAimJitterAngle', {
    Text = 'Jitter Angle',
    Default = Settings.AntiAim.JitterAngle,
    Min = 10,
    Max = 180,
    Rounding = 0,
    Callback = function(v)
        Settings.AntiAim.JitterAngle = v
    end,
})

AntiAimGroup:AddSlider('AntiAimStaticAngle', {
    Text = 'Static Angle',
    Default = Settings.AntiAim.StaticAngle,
    Min = -180,
    Max = 180,
    Rounding = 0,
    Callback = function(v)
        Settings.AntiAim.StaticAngle = v
    end,
})

AntiAimGroup:AddDropdown('AntiAimPitchMode', {
    Text = 'Pitch Mode',
    Values = { 'None', 'Up', 'Down', 'Random' },
    Default = Settings.AntiAim.PitchMode,
    Callback = function(v)
        Settings.AntiAim.PitchMode = v
    end,
})

AntiAimGroup:AddSlider('AntiAimPitchAngle', {
    Text = 'Pitch Angle',
    Default = Settings.AntiAim.PitchAngle,
    Min = 0,
    Max = 89,
    Rounding = 0,
    Callback = function(v)
        Settings.AntiAim.PitchAngle = v
    end,
})

-- Rage Bot Section
local RageBotGroup = Tabs.Main:AddRightGroupbox('Rage Bot')
RageBotGroup:AddToggle('RageBotEnabled', {
    Text = 'Enabled',
    Default = Settings.RageBot.Enabled,
    Callback = function(s)
        Settings.RageBot.Enabled = s
    end,
})

RageBotGroup:AddToggle('RageBotFireRateBypass', {
    Text = 'Fire Rate Bypass',
    Default = Settings.RageBot.FireRateBypass,
    Callback = function(s)
        Settings.RageBot.FireRateBypass = s
    end,
})

RageBotGroup:AddToggle('RageBotShootEffects', {
    Text = 'Shoot Effects',
    Default = Settings.RageBot.ShootEffects,
    Callback = function(s)
        Settings.RageBot.ShootEffects = s
    end,
})

RageBotGroup:AddToggle('RageBotFirePositionScanning', {
    Text = 'Fire Position Scanning',
    Default = Settings.RageBot.FirePositionScanning,
    Callback = function(s)
        Settings.RageBot.FirePositionScanning = s
    end,
})

RageBotGroup:AddSlider('RageBotFirePositionOffset', {
    Text = 'Fire Position Offset',
    Default = Settings.RageBot.FirePositionOffset,
    Min = 0.1,
    Max = 2.0,
    Rounding = 1,
    Callback = function(v)
        Settings.RageBot.FirePositionOffset = v
    end,
})

RageBotGroup:AddToggle('RageBotHitPositionScanning', {
    Text = 'Hit Position Scanning',
    Default = Settings.RageBot.HitPositionScanning,
    Callback = function(s)
        Settings.RageBot.HitPositionScanning = s
    end,
})

RageBotGroup:AddSlider('RageBotHitPositionOffset', {
    Text = 'Hit Position Offset',
    Default = Settings.RageBot.HitPositionOffset,
    Min = 0.1,
    Max = 2.0,
    Rounding = 1,
    Callback = function(v)
        Settings.RageBot.HitPositionOffset = v
    end,
})

-- Miscellaneous Section
local Optimizations = Tabs.Misc:AddLeftGroupbox('Miscellaneous')
Optimizations:AddToggle('MiscTextures', {
    Text = 'Toggle Textures',
    Default = Settings.Misc.Textures,
    Callback = function(s)
        Settings.Misc.Textures = s
        if s then
            getgenv().optimizeMap()
        else
            getgenv().revertMap()
        end
    end,
})

-- Safety Section
local Safety = Tabs.Misc:AddRightGroupbox('Safety')
Safety:AddToggle('VotekickRejoiner', {
    Text = 'Rejoin on Votekick',
    Default = Settings.Misc.VotekickRejoiner,
    Callback = function(s)
        Settings.Misc.VotekickRejoiner = s
        if s then
            getgenv().initializeVotekickRejoiner()
        end
    end,
})

Safety:AddButton({
    Text = 'Rejoin',
    Func = function()
        getgenv().kickAndRejoin()
    end,
})

-- ViewModel Chams Section
local ViewModelChams = Tabs.Misc:AddRightGroupbox('ViewModel Chams')
ViewModelChams:AddToggle('ViewModelChamsArmsEnabled', {
    Text = 'Arms Enabled',
    Default = Settings.ViewModelChams.Arms.Enabled,
    Callback = function(enabled)
        Settings.ViewModelChams.Arms.Enabled = enabled
        getgenv().updateViewModelChams()
    end,
})

ViewModelChams:AddLabel('Arms Color')
    :AddColorPicker('ViewModelChamsArmsColor', {
        Default = Settings.ViewModelChams.Arms.Color,
        Callback = function(color)
            Settings.ViewModelChams.Arms.Color = color
            getgenv().updateViewModelChams()
        end,
    })

ViewModelChams:AddDropdown('ViewModelChamsArmsMaterial', {
    Text = 'Arms Material',
    Values = { 'SmoothPlastic', 'ForceField', 'Neon', 'Glass', 'Fabric' },
    Default = tostring(Settings.ViewModelChams.Arms.Material),
    Callback = function(material)
        Settings.ViewModelChams.Arms.Material = Enum.Material[material]
        getgenv().updateViewModelChams()
    end,
})

ViewModelChams:AddSlider('ViewModelChamsArmsTransparency', {
    Text = 'Arms Transparency',
    Default = Settings.ViewModelChams.Arms.Transparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        Settings.ViewModelChams.Arms.Transparency = value
        getgenv().updateViewModelChams()
    end,
})

ViewModelChams:AddToggle('ViewModelChamsWeaponsEnabled', {
    Text = 'Weapon Enabled',
    Default = Settings.ViewModelChams.Weapons.Enabled,
    Callback = function(enabled)
        Settings.ViewModelChams.Weapons.Enabled = enabled
        getgenv().updateViewModelChams()
    end,
})

ViewModelChams:AddLabel('Weapon Color')
    :AddColorPicker('ViewModelChamsWeaponsColor', {
        Default = Settings.ViewModelChams.Weapons.Color,
        Callback = function(color)
            Settings.ViewModelChams.Weapons.Color = color
            getgenv().updateViewModelChams()
        end,
    })

ViewModelChams:AddDropdown('ViewModelChamsWeaponsMaterial', {
    Text = 'Weapon Material',
    Values = { 'SmoothPlastic', 'ForceField', 'Neon', 'Glass', 'Fabric' },
    Default = tostring(Settings.ViewModelChams.Weapons.Material),
    Callback = function(material)
        Settings.ViewModelChams.Weapons.Material = Enum.Material[material]
        getgenv().updateViewModelChams()
    end,
})

ViewModelChams:AddSlider('ViewModelChamsWeaponsTransparency', {
    Text = 'Weapon Transparency',
    Default = Settings.ViewModelChams.Weapons.Transparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        Settings.ViewModelChams.Weapons.Transparency = value
        getgenv().updateViewModelChams()
    end,
})

ViewModelChams:AddToggle('ViewModelChamsTexturesEnabled', {
    Text = 'Texture Chams Enabled',
    Default = Settings.ViewModelChams.Textures.Enabled,
    Callback = function(enabled)
        Settings.ViewModelChams.Textures.Enabled = enabled
        getgenv().updateViewModelChams()
    end,
})

ViewModelChams:AddToggle('ViewModelChamsTexturesRemove', {
    Text = 'Remove Textures',
    Default = Settings.ViewModelChams.Textures.RemoveTextures,
    Callback = function(enabled)
        Settings.ViewModelChams.Textures.RemoveTextures = enabled
        getgenv().updateViewModelChams()
    end,
})

ViewModelChams:AddDropdown('ViewModelChamsTexturesMaterial', {
    Text = 'Texture Material',
    Values = { 'SmoothPlastic', 'ForceField', 'Neon', 'Glass', 'Fabric' },
    Default = tostring(Settings.ViewModelChams.Textures.Material),
    Callback = function(material)
        Settings.ViewModelChams.Textures.Material = Enum.Material[material]
        getgenv().updateViewModelChams()
    end,
})

ViewModelChams:AddLabel('Texture Color')
    :AddColorPicker('ViewModelChamsTexturesColor', {
        Default = Settings.ViewModelChams.Textures.Color,
        Callback = function(color)
            Settings.ViewModelChams.Textures.Color = color
            getgenv().updateViewModelChams()
        end,
    })

ViewModelChams:AddSlider('ViewModelChamsTexturesTransparency', {
    Text = 'Texture Transparency',
    Default = Settings.ViewModelChams.Textures.Transparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        Settings.ViewModelChams.Textures.Transparency = value
        getgenv().updateViewModelChams()
    end,
})

-- Lighting Section
local LightingSec = Tabs.Misc:AddLeftGroupbox('Lighting')
LightingSec:AddToggle('AmbientEnabled', {
    Text = 'Ambient Enabled',
    Default = Settings.Lighting.Ambient.Enabled,
    Callback = function(enabled)
        Settings.Lighting.Ambient.Enabled = enabled
        getgenv().UpdateLighting()
    end,
})

LightingSec:AddLabel('Ambient Color'):AddColorPicker('AmbientColor', {
    Default = Settings.Lighting.Ambient.Color,
    Callback = function(color)
        Settings.Lighting.Ambient.Color = color
        getgenv().UpdateLighting()
    end,
})

LightingSec:AddToggle('OutdoorAmbientEnabled', {
    Text = 'Outdoor Ambient Enabled',
    Default = Settings.Lighting.OutdoorAmbient.Enabled,
    Callback = function(enabled)
        Settings.Lighting.OutdoorAmbient.Enabled = enabled
        getgenv().UpdateLighting()
    end,
})

LightingSec:AddLabel('Outdoor Ambient Color')
    :AddColorPicker('OutdoorAmbientColor', {
        Default = Settings.Lighting.OutdoorAmbient.Color,
        Callback = function(color)
            Settings.Lighting.OutdoorAmbient.Color = color
            getgenv().UpdateLighting()
        end,
    })

LightingSec:AddToggle('ClockTimeEnabled', {
    Text = 'Clock Time Enabled',
    Default = Settings.Lighting.ClockTime.Enabled,
    Callback = function(enabled)
        Settings.Lighting.ClockTime.Enabled = enabled
        getgenv().UpdateLighting()
    end,
})

LightingSec:AddSlider('ClockTime', {
    Text = 'Clock Time',
    Default = Settings.Lighting.ClockTime.Time,
    Min = 0,
    Max = 24,
    Rounding = 2,
    Callback = function(value)
        Settings.Lighting.ClockTime.Time = value
        getgenv().UpdateLighting()
    end,
})

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton({
    Text = 'Unload',
    Func = function()
        Library:Unload()
    end,
})

MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = 'Menu keybind',
    Callback = function(Value)
        print('[cb] Menu keybind clicked!', Value)
    end,
    ChangedCallback = function(New)
        print('[cb] Menu keybind changed!', New)
    end,
})

Library.ToggleKeybind = Options.MenuKeybind

-- Watermark and FPS
Library:SetWatermarkVisibility(true)
local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

local WatermarkConnection = game:GetService('RunService').RenderStepped
    :Connect(function()
        FrameCounter += 1
        if (tick() - FrameTimer) >= 1 then
            FPS = FrameCounter
            FrameTimer = tick()
            FrameCounter = 0
        end
        Library:SetWatermark(
            ('%s ms | %s fps | Astralis'):format(
                math.floor(FPS),
                math.floor(
                    game:GetService('Stats').Network.ServerStatsItem['Data Ping']
                        :GetValue()
                )
            )
        )
    end)

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    Library.Unloaded = true
end)

SaveManager:SetLibrary(Library)
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
SaveManager:SetFolder('Astralis')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
