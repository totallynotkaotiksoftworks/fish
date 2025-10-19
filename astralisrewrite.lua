-- =============================================
-- CONFIGURATION
-- =============================================

local SETTINGS = {
    UI = {
        WindowTitle = 'Astralis',
        CenterWindow = true,
        AutoShow = true,
        TabPadding = 8,
        MenuFadeTime = 0.2,
        WatermarkText = 'Astralis | %s fps | %s ms',
        DefaultMenuKeybind = 'RightShift',
        ConfigFolder = 'Astralis/configs',
    },

    FOVCircle = {
        Enabled = false,
        Color = Color3.fromRGB(127, 0, 255),
        Thickness = 1,
        Radius = 150,
        Filled = false,
        Transparency = 1,
    },

    ESP = {
        Box = {
            Enabled = false,
            Color = Color3.fromRGB(127, 0, 255),
            Thickness = 1,
            Filled = false,
        },
        Tracer = {
            Enabled = false,
            Color = Color3.fromRGB(127, 0, 255),
            Thickness = 1,
            FromPosition = Vector2.new(0.5, 1),
        },
        Distance = {
            Enabled = false,
            Color = Color3.fromRGB(127, 0, 255),
            Size = 14,
            CenterText = true,
            Outline = true,
            Offset = 15,
        },
        Chams = {
            Mode = 'None', -- 'None', 'Highlight', 'Box'
            Highlight = {
                Enabled = false,
                Color = Color3.fromRGB(0, 0, 0),
                Transparency = 0.5,
                FillTransparency = 0.8,
                OutlineColor = Color3.fromRGB(127, 0, 255),
                OutlineTransparency = 0,
            },
            Box = {
                Enabled = false,
                Color = Color3.fromRGB(127, 0, 255),
                Transparency = 0.65,
                SizeMultiplier = 1,
            },
        },
        Scaling = {
            BaseScale = 80,
            DistanceFactor = 1000,
            BoxWidthMultiplier = 1.8,
            BoxHeightMultiplier = 3.3,
        },
        UseFOV = false,
    },

    BulletTracers = {
        Local = {
            Enabled = false,
            ColorStart = Color3.fromRGB(127, 0, 255),
            ColorEnd = Color3.fromRGB(127, 0, 255),
            Lifetime = 1,
            Texture = 'Default',
        },
        Enemy = {
            Enabled = false,
            ColorStart = Color3.fromRGB(255, 0, 0),
            ColorEnd = Color3.fromRGB(255, 0, 0),
            Lifetime = 1,
            Texture = 'Default',
        },
        UseThirdPersonMuzzle = false,
        UseNewOrigin = false,
        Textures = {
            ['Default'] = 'rbxassetid://446111271',
            ['Nothing'] = '',
        },
    },

    Viewmodel = {
        Offset = {
            Enabled = false,
            RemoveOnAim = false,
            X = 0,
            Y = 0,
            Z = 0,
        },
    },

    Aimbot = {
        Enabled = false,
        AimPart = 'Torso', -- "Head" or "Torso"
        Smoothness = 1,
        TriggerKey = Enum.UserInputType.MouseButton2,
        TargetStickiness = 2,
        TeamCheckCooldown = 1,
        UseFOV = false,
    },

    SilentAim = {
        Enabled = false,
        HeadshotChance = 0,
        HitChance = 75.5,
        TargetPart = 'Head', -- "Head" or "Torso"
        UseFOV = false,
        FOVRadius = 150,
    },

    Performance = {
        TeamCheckInterval = 1,
        CacheCleanup = true,
    },

    Game = {
        Teams = {
            'Phantoms',
            'Ghosts',
        },
        TeamColors = {
            Phantoms = 'Black',
            Ghosts = 'White',
        },
        PlayerFolder = 'Players',
        TargetMeshIds = {
            ['rbxassetid://4049240323'] = true, -- Arms
            ['rbxassetid://4049240209'] = true, -- Legs
            ['rbxassetid://4049240078'] = true, -- Torso
            ['rbxassetid://6179256256'] = true, -- Head
        },
    },

    ThirdPerson = {
        Enabled = false,
        ShowCharacter = false,
        ApplyAntiAimToCharacter = true,
        CameraOffsetAlwaysVisible = false,
        ShowCharacterWhileAiming = false,
        CameraOffsetX = 3,
        CameraOffsetY = 1,
        CameraOffsetZ = 4,
        HideViewmodel = false,
        AntiAim = {
            Enabled = false,
            Mode = 'Spin', -- Options: 'Spin', 'Jitter', 'Static'
            SpinSpeed = 50,
            JitterAngle = 45,
            StaticAngle = 90,
            PitchMode = 'None', -- Options: 'None', 'Up', 'Down', 'Random'
            PitchAngle = 45,
        },
    },
}

local SilentAim = {
    CurrentTarget = nil,
    ChanceFactor = nil,
    Velocity = nil,
    LastTarget = nil,
}

-- =============================================
-- SERVICES & INITIALIZATION
-- =============================================

local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService('UserInputService')
local CoreGui = game:GetService('CoreGui')
local RecieverRemote = game:GetService('ReplicatedStorage').RemoteEvent
local Reciever = RecieverRemote.OnClientEvent

local lib = loadstring(
    game:HttpGet(
        'https://raw.githubusercontent.com/randomahhnamecauseimtoolazy/chat/refs/heads/main/lib.lua'
    )
)()

-- =============================================
-- GAME MODULE REQUIRES
-- =============================================

local require = getrenv().shared and getrenv().shared.require
if not require then
    return game:GetService('Players').LocalPlayer
        :Kick('FFlagDebugRunParallelLuaOnMainThread not found')
end

local WeaponControllerInterface = require('WeaponControllerInterface')
local ReplicationInterface = require('ReplicationInterface')
local CharacterInterface = require('CharacterInterface')
local ReplicationObject = require('ReplicationObject')
local ThirdPersonObject = require('ThirdPersonObject')
local BulletInterface = require('BulletInterface')
local CameraInterface = require('CameraInterface')
local CharacterObject = require('CharacterObject')
local PublicSettings = require('PublicSettings')
local NetworkClient = require('NetworkClient')
local ScreenCull = require('ScreenCull')
local math_random = math.random

-- =============================================
-- GLOBAL VARIABLES & STORAGE
-- =============================================

local LocalPlayer = Players.LocalPlayer

local fakeRepObject = ReplicationObject.new(setmetatable({}, {
    __index = function(self, index)
        return LocalPlayer[index]
    end,
    __newindex = function(self, index, value)
        LocalPlayer[index] = value
    end,
}))

local Window = Library:CreateWindow({
    Title = SETTINGS.UI.WindowTitle,
    Center = SETTINGS.UI.CenterWindow,
    AutoShow = SETTINGS.UI.AutoShow,
    TabPadding = SETTINGS.UI.TabPadding,
    MenuFadeTime = SETTINGS.UI.MenuFadeTime,
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local OriginalOffsets = {}
local Storage = {
    esp_cache = {},
    ViewmodelProperties = {},
    highlight_chams = {},
    box_chams = {},
}
local Visuals = {
    Storage = workspace.Terrain,
    TracerBeams = {},
}

local ViewportSize = Camera.ViewportSize

local currentTeam = nil
local teamCheckCooldown = 0
local currentObj
local started = false
local lastPos = nil
local lastFrameTime = nil
local startTime = os.clock()
local newSpawnCache = {
    currentAddition = 0,
    latency = 0,
    updateDebt = 0,
    spawnTime = 0,
    spawned = false,
    lastUpdate = nil,
    lastUpdateTime = 0,
    walkSpeed = nil,
}
local playerModelToReplication = {}

local TargetMeshIds = SETTINGS.Game.TargetMeshIds

local isHoldingMouse2 = false
local currentTarget = nil
local targetLockTime = 0

local FOVCircle = Drawing.new('Circle')
FOVCircle.NumSides = 64
FOVCircle.Visible = false
FOVCircle.ZIndex = 10

-- =============================================
-- UI SETUP: MAIN TAB (AIMBOT & SILENT AIM)
-- =============================================

local AimbotSettings = SETTINGS.Aimbot

local AimbotGroupBox = Tabs.Main:AddLeftGroupbox('Aimbot Settings')

AimbotGroupBox:AddToggle('AimbotEnabled', {
    Text = 'Enable Aimbot',
    Default = AimbotSettings.Enabled,
    Callback = function(Value)
        AimbotSettings.Enabled = Value
    end,
})

AimbotGroupBox:AddToggle('AimbotUsesFOV', {
    Text = 'Use FOV',
    Default = AimbotSettings.UseFOV,
    Callback = function(Value)
        AimbotSettings.UseFOV = Value
    end,
})

AimbotGroupBox:AddDropdown('AimPart', {
    Text = 'Aim Part',
    Default = AimbotSettings.AimPart,
    Values = { 'Head', 'Torso' },
    Callback = function(Value)
        AimbotSettings.AimPart = Value
    end,
})

AimbotGroupBox:AddSlider('SmoothnessSlider', {
    Text = 'Smoothness',
    Default = AimbotSettings.Smoothness,
    Min = 0.1,
    Max = 1,
    Rounding = 1,
    Callback = function(Value)
        AimbotSettings.Smoothness = Value
    end,
})

local SilentAimGroupBox = Tabs.Main:AddLeftGroupbox('Silent Aim')

SilentAimGroupBox:AddToggle('SilentAimEnabled', {
    Text = 'Enable Silent Aim',
    Default = SETTINGS.SilentAim.Enabled,
    Callback = function(Value)
        SETTINGS.SilentAim.Enabled = Value
    end,
})

SilentAimGroupBox:AddToggle('SilentAimUsesFOV', {
    Text = 'Use FOV',
    Default = SETTINGS.SilentAim.UseFOV,
    Callback = function(Value)
        SETTINGS.SilentAim.UseFOV = Value
    end,
})

SilentAimGroupBox:AddDropdown('SilentAimTargetPart', {
    Text = 'Target Part',
    Default = SETTINGS.SilentAim.TargetPart,
    Values = { 'Head', 'Torso' },
    Callback = function(Value)
        SETTINGS.SilentAim.TargetPart = Value
    end,
})

SilentAimGroupBox:AddSlider('HeadshotChanceSlider', {
    Text = 'Headshot Chance %',
    Default = SETTINGS.SilentAim.HeadshotChance,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        SETTINGS.SilentAim.HeadshotChance = Value
    end,
})

SilentAimGroupBox:AddSlider('HitChanceSlider', {
    Text = 'Hit Chance %',
    Default = SETTINGS.SilentAim.HitChance,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        SETTINGS.SilentAim.HitChance = Value
    end,
})

SilentAimGroupBox:AddSlider('SilentAimFOVSlider', {
    Text = 'FOV Radius',
    Default = SETTINGS.SilentAim.FOVRadius,
    Min = 25,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        SETTINGS.SilentAim.FOVRadius = Value
    end,
})

-- =============================================
-- UI SETUP: VISUALS TAB (ESP & CHAMS)
-- =============================================

local ESPSettings = SETTINGS.ESP

local ESPGroupBox = Tabs.Visuals:AddLeftGroupbox('ESP Settings')

ESPGroupBox:AddToggle('BoxToggle', {
    Text = 'Enable Box',
    Default = ESPSettings.Box.Enabled,
    Callback = function(Value)
        ESPSettings.Box.Enabled = Value
    end,
})

ESPGroupBox:AddToggle('ESPUsesFOV', {
    Text = 'Use FOV',
    Default = ESPSettings.UseFOV,
    Callback = function(Value)
        ESPSettings.UseFOV = Value
    end,
})

ESPGroupBox:AddToggle('TracerToggle', {
    Text = 'Enable Tracer',
    Default = ESPSettings.Tracer.Enabled,
    Callback = function(Value)
        ESPSettings.Tracer.Enabled = Value
    end,
})

ESPGroupBox:AddToggle('DistanceToggle', {
    Text = 'Enable Distance Text',
    Default = ESPSettings.Distance.Enabled,
    Callback = function(Value)
        ESPSettings.Distance.Enabled = Value
    end,
})

local ChamsGroupBox = Tabs.Visuals:AddRightGroupbox('Chams Settings')

ChamsGroupBox:AddDropdown('ChamsMode', {
    Text = 'Chams Mode',
    Default = ESPSettings.Chams.Mode,
    Values = { 'None', 'Highlight', 'Box' },
    Callback = function(Value)
        ESPSettings.Chams.Mode = Value

        if Value == 'Highlight' then
            ESPSettings.Chams.Highlight.Enabled = true
            ESPSettings.Chams.Box.Enabled = false
            ClearBoxChams()
        elseif Value == 'Box' then
            ESPSettings.Chams.Highlight.Enabled = false
            ESPSettings.Chams.Box.Enabled = true
            ClearHighlightChams()
        else
            ESPSettings.Chams.Highlight.Enabled = false
            ESPSettings.Chams.Box.Enabled = false
            ClearHighlightChams()
            ClearBoxChams()
        end
    end,
})

local VisualCustomizationGroupBox =
    Tabs.Visuals:AddLeftGroupbox('ESP Customization')

VisualCustomizationGroupBox:AddLabel('Box Color')
    :AddColorPicker('BoxColorPicker', {
        Default = ESPSettings.Box.Color,
        Title = 'Box Color',
        Callback = function(Value)
            ESPSettings.Box.Color = Value
        end,
    })

VisualCustomizationGroupBox:AddSlider('BoxThicknessSlider', {
    Text = 'Box Thickness',
    Default = ESPSettings.Box.Thickness,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        ESPSettings.Box.Thickness = Value
    end,
})

VisualCustomizationGroupBox:AddLabel('Tracer Color')
    :AddColorPicker('TracerColorPicker', {
        Default = ESPSettings.Tracer.Color,
        Title = 'Tracer Color',
        Callback = function(Value)
            ESPSettings.Tracer.Color = Value
        end,
    })

VisualCustomizationGroupBox:AddSlider('TracerThicknessSlider', {
    Text = 'Tracer Thickness',
    Default = ESPSettings.Tracer.Thickness,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        ESPSettings.Tracer.Thickness = Value
    end,
})

VisualCustomizationGroupBox:AddLabel('Distance Color')
    :AddColorPicker('DistanceColorPicker', {
        Default = ESPSettings.Distance.Color,
        Title = 'Distance Color',
        Callback = function(Value)
            ESPSettings.Distance.Color = Value
        end,
    })

VisualCustomizationGroupBox:AddSlider('DistanceSizeSlider', {
    Text = 'Distance Text Size',
    Default = ESPSettings.Distance.Size,
    Min = 10,
    Max = 20,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        ESPSettings.Distance.Size = Value
    end,
})

local ChamsVisualsGroupBox =
    Tabs.Visuals:AddRightGroupbox('Chams Visual Customization')

ChamsVisualsGroupBox:AddLabel('Highlight Chams Color')
    :AddColorPicker('HighlightChamsColorPicker', {
        Default = ESPSettings.Chams.Highlight.Color,
        Title = 'Highlight Chams Color',
        Callback = function(Value)
            ESPSettings.Chams.Highlight.Color = Value
        end,
    })

ChamsVisualsGroupBox:AddLabel('Highlight Outline Color')
    :AddColorPicker('HighlightOutlineColorPicker', {
        Default = ESPSettings.Chams.Highlight.OutlineColor,
        Title = 'Highlight Outline Color',
        Callback = function(Value)
            ESPSettings.Chams.Highlight.OutlineColor = Value
        end,
    })

ChamsVisualsGroupBox:AddSlider('HighlightFillTransparency', {
    Text = 'Highlight Fill Transparency',
    Default = ESPSettings.Chams.Highlight.FillTransparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        ESPSettings.Chams.Highlight.FillTransparency = Value
    end,
})

ChamsVisualsGroupBox:AddLabel('Box Chams Color')
    :AddColorPicker('BoxChamsColorPicker', {
        Default = ESPSettings.Chams.Box.Color,
        Title = 'Box Chams Color',
        Callback = function(Value)
            ESPSettings.Chams.Box.Color = Value
        end,
    })

ChamsVisualsGroupBox:AddSlider('BoxChamsTransparency', {
    Text = 'Box Chams Transparency',
    Default = ESPSettings.Chams.Box.Transparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        ESPSettings.Chams.Box.Transparency = Value
    end,
})

ChamsVisualsGroupBox:AddSlider('BoxChamsSizeMultiplier', {
    Text = 'Box Chams Size Multiplier',
    Default = ESPSettings.Chams.Box.SizeMultiplier,
    Min = 1,
    Max = 2,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        ESPSettings.Chams.Box.SizeMultiplier = Value
    end,
})

-- =============================================
-- UI SETUP: VISUALS TAB (BULLET TRACERS)
-- =============================================

local BulletTracerGroup = Tabs.Visuals:AddRightGroupbox('Bullet Tracers')

BulletTracerGroup:AddToggle('LocalTracersToggle', {
    Text = 'Local Bullet Tracers',
    Default = SETTINGS.BulletTracers.Local.Enabled,
    Callback = function(Value)
        SETTINGS.BulletTracers.Local.Enabled = Value
    end,
})

BulletTracerGroup:AddLabel('Local Tracer Start Color')
    :AddColorPicker('LocalTracerStartColor', {
        Default = SETTINGS.BulletTracers.Local.ColorStart,
        Title = 'Local Tracer Start Color',
        Callback = function(Value)
            SETTINGS.BulletTracers.Local.ColorStart = Value
        end,
    })

BulletTracerGroup:AddLabel('Local Tracer End Color')
    :AddColorPicker('LocalTracerEndColor', {
        Default = SETTINGS.BulletTracers.Local.ColorEnd,
        Title = 'Local Tracer End Color',
        Callback = function(Value)
            SETTINGS.BulletTracers.Local.ColorEnd = Value
        end,
    })

BulletTracerGroup:AddToggle('EnemyTracersToggle', {
    Text = 'Enemy Bullet Tracers',
    Default = SETTINGS.BulletTracers.Enemy.Enabled,
    Callback = function(Value)
        SETTINGS.BulletTracers.Enemy.Enabled = Value
    end,
})

BulletTracerGroup:AddLabel('Enemy Tracer Start Color')
    :AddColorPicker('EnemyTracerStartColor', {
        Default = SETTINGS.BulletTracers.Enemy.ColorStart,
        Title = 'Enemy Tracer Start Color',
        Callback = function(Value)
            SETTINGS.BulletTracers.Enemy.ColorStart = Value
        end,
    })

BulletTracerGroup:AddLabel('Enemy Tracer End Color')
    :AddColorPicker('EnemyTracerEndColor', {
        Default = SETTINGS.BulletTracers.Enemy.ColorEnd,
        Title = 'Enemy Tracer End Color',
        Callback = function(Value)
            SETTINGS.BulletTracers.Enemy.ColorEnd = Value
        end,
    })

BulletTracerGroup:AddToggle('UseThirdPersonMuzzle', {
    Text = 'Use Third Person Muzzle',
    Default = SETTINGS.BulletTracers.UseThirdPersonMuzzle,
    Callback = function(Value)
        SETTINGS.BulletTracers.UseThirdPersonMuzzle = Value
    end,
})

BulletTracerGroup:AddToggle('UseNewOrigin', {
    Text = 'Use New Origin',
    Default = SETTINGS.BulletTracers.UseNewOrigin,
    Callback = function(Value)
        SETTINGS.BulletTracers.UseNewOrigin = Value
    end,
})

BulletTracerGroup:AddSlider('TracerLifetime', {
    Text = 'Tracer Lifetime',
    Default = SETTINGS.BulletTracers.Local.Lifetime,
    Min = 0.1,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        SETTINGS.BulletTracers.Local.Lifetime = Value
        SETTINGS.BulletTracers.Enemy.Lifetime = Value
    end,
})

BulletTracerGroup:AddDropdown('TracerTexture', {
    Text = 'Tracer Texture',
    Default = 'Default',
    Values = { 'Default', 'Nothing' },
    Callback = function(Value)
        SETTINGS.BulletTracers.Local.Texture = Value
        SETTINGS.BulletTracers.Enemy.Texture = Value
    end,
})

-- =============================================
-- UI SETUP: MAIN TAB (FOV SETTINGS)
-- =============================================

local FOVSettings = SETTINGS.FOVCircle
local FOVGroupBox = Tabs.Main:AddRightGroupbox('FOV Settings')

FOVGroupBox:AddToggle('FOVEnabled', {
    Text = 'Enable FOV Circle',
    Default = FOVSettings.Enabled,
    Callback = function(Value)
        FOVSettings.Enabled = Value
    end,
})

FOVGroupBox:AddSlider('FOVRadiusSlider', {
    Text = 'Radius',
    Default = FOVSettings.Radius,
    Min = 25,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        FOVSettings.Radius = Value
    end,
})

FOVGroupBox:AddSlider('FOVThicknessSlider', {
    Text = 'Thickness',
    Default = FOVSettings.Thickness,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(Value)
        FOVSettings.Thickness = Value
    end,
})

FOVGroupBox:AddLabel('FOV Circle Color'):AddColorPicker('FOVColorPicker', {
    Default = FOVSettings.Color,
    Title = 'FOV Circle Color',
    Callback = function(Value)
        FOVSettings.Color = Value
    end,
})

FOVGroupBox:AddToggle('FOVFilledToggle', {
    Text = 'Filled Circle',
    Default = FOVSettings.Filled,
    Callback = function(Value)
        FOVSettings.Filled = Value
    end,
})

FOVGroupBox:AddSlider('FOVTransparencySlider', {
    Text = 'Transparency',
    Default = FOVSettings.Transparency,
    Min = 0.1,
    Max = 1,
    Rounding = 1,
    Callback = function(Value)
        FOVSettings.Transparency = Value
    end,
})

-- =============================================
-- UI SETUP: MISC TAB (THIRD PERSON & ANTI-AIM)
-- =============================================

local ThirdPersonGroupBox = Tabs.Misc:AddLeftGroupbox('Third Person')

ThirdPersonGroupBox:AddToggle('ThirdPersonEnabled', {
    Text = 'Enable Third Person',
    Default = SETTINGS.ThirdPerson.Enabled,
    Callback = function(Value)
        SETTINGS.ThirdPerson.Enabled = Value
    end,
})

ThirdPersonGroupBox:AddToggle('ShowCharacter', {
    Text = 'Show Character',
    Default = SETTINGS.ThirdPerson.ShowCharacter,
    Callback = function(Value)
        SETTINGS.ThirdPerson.ShowCharacter = Value
    end,
})

ThirdPersonGroupBox:AddToggle('ApplyAntiAim', {
    Text = 'Apply Anti-Aim to Character',
    Default = SETTINGS.ThirdPerson.ApplyAntiAimToCharacter,
    Callback = function(Value)
        SETTINGS.ThirdPerson.ApplyAntiAimToCharacter = Value
    end,
})

ThirdPersonGroupBox:AddToggle('CameraOffsetAlwaysVisible', {
    Text = 'Camera Offset Always Visible',
    Default = SETTINGS.ThirdPerson.CameraOffsetAlwaysVisible,
    Callback = function(Value)
        SETTINGS.ThirdPerson.CameraOffsetAlwaysVisible = Value
    end,
})

ThirdPersonGroupBox:AddToggle('ShowCharacterWhileAiming', {
    Text = 'Show Character While Aiming',
    Default = SETTINGS.ThirdPerson.ShowCharacterWhileAiming,
    Callback = function(Value)
        SETTINGS.ThirdPerson.ShowCharacterWhileAiming = Value
    end,
})

ThirdPersonGroupBox:AddToggle('HideViewmodel', {
    Text = 'Hide Viewmodel',
    Default = SETTINGS.ThirdPerson.HideViewmodel,
    Callback = function(Value)
        SETTINGS.ThirdPerson.HideViewmodel = Value
    end,
})

ThirdPersonGroupBox:AddSlider('CameraOffsetX', {
    Text = 'Camera Offset X',
    Default = SETTINGS.ThirdPerson.CameraOffsetX,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        SETTINGS.ThirdPerson.CameraOffsetX = Value
    end,
})

ThirdPersonGroupBox:AddSlider('CameraOffsetY', {
    Text = 'Camera Offset Y',
    Default = SETTINGS.ThirdPerson.CameraOffsetY,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        SETTINGS.ThirdPerson.CameraOffsetY = Value
    end,
})

ThirdPersonGroupBox:AddSlider('CameraOffsetZ', {
    Text = 'Camera Offset Z',
    Default = SETTINGS.ThirdPerson.CameraOffsetZ,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        SETTINGS.ThirdPerson.CameraOffsetZ = Value
    end,
})

local AntiAimGroupBox = Tabs.Misc:AddRightGroupbox('Anti-Aim')

AntiAimGroupBox:AddToggle('AntiAimEnabled', {
    Text = 'Enable Anti-Aim',
    Default = SETTINGS.ThirdPerson.AntiAim.Enabled,
    Callback = function(Value)
        SETTINGS.ThirdPerson.AntiAim.Enabled = Value
    end,
})

AntiAimGroupBox:AddDropdown('AntiAimMode', {
    Text = 'Anti-Aim Mode',
    Default = SETTINGS.ThirdPerson.AntiAim.Mode,
    Values = { 'Spin', 'Jitter', 'Static' },
    Callback = function(Value)
        SETTINGS.ThirdPerson.AntiAim.Mode = Value
    end,
})

AntiAimGroupBox:AddSlider('SpinSpeed', {
    Text = 'Spin Speed',
    Default = SETTINGS.ThirdPerson.AntiAim.SpinSpeed,
    Min = 10,
    Max = 50000,
    Rounding = 0,
    Callback = function(Value)
        SETTINGS.ThirdPerson.AntiAim.SpinSpeed = Value
    end,
})

AntiAimGroupBox:AddSlider('JitterAngle', {
    Text = 'Jitter Angle',
    Default = SETTINGS.ThirdPerson.AntiAim.JitterAngle,
    Min = 0,
    Max = 180,
    Rounding = 0,
    Callback = function(Value)
        SETTINGS.ThirdPerson.AntiAim.JitterAngle = Value
    end,
})

AntiAimGroupBox:AddSlider('StaticAngle', {
    Text = 'Static Angle',
    Default = SETTINGS.ThirdPerson.AntiAim.StaticAngle,
    Min = 0,
    Max = 360,
    Rounding = 0,
    Callback = function(Value)
        SETTINGS.ThirdPerson.AntiAim.StaticAngle = Value
    end,
})

AntiAimGroupBox:AddDropdown('PitchMode', {
    Text = 'Pitch Mode',
    Default = SETTINGS.ThirdPerson.AntiAim.PitchMode,
    Values = { 'None', 'Up', 'Down', 'Random' },
    Callback = function(Value)
        SETTINGS.ThirdPerson.AntiAim.PitchMode = Value
    end,
})

AntiAimGroupBox:AddSlider('PitchAngle', {
    Text = 'Pitch Angle',
    Default = SETTINGS.ThirdPerson.AntiAim.PitchAngle,
    Min = 0,
    Max = 89,
    Rounding = 0,
    Callback = function(Value)
        SETTINGS.ThirdPerson.AntiAim.PitchAngle = Value
    end,
})

-- =============================================
-- UI SETUP: MISC TAB (VIEWMODEL OFFSET)
-- =============================================

local ViewmodelGroupBox = Tabs.Misc:AddLeftGroupbox('Viewmodel Offset')

ViewmodelGroupBox:AddToggle('ViewmodelOffsetEnabled', {
    Text = 'Enable Viewmodel Offset',
    Default = SETTINGS.Viewmodel.Offset.Enabled,
    Callback = function(Value)
        SETTINGS.Viewmodel.Offset.Enabled = Value
    end,
})

ViewmodelGroupBox:AddToggle('ViewmodelOffsetRemoveOnAim', {
    Text = 'Remove Offset When Aiming',
    Default = SETTINGS.Viewmodel.Offset.RemoveOnAim,
    Callback = function(Value)
        SETTINGS.Viewmodel.Offset.RemoveOnAim = Value
    end,
})

ViewmodelGroupBox:AddSlider('ViewmodelOffsetX', {
    Text = 'Offset X',
    Default = SETTINGS.Viewmodel.Offset.X,
    Min = -5,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        SETTINGS.Viewmodel.Offset.X = Value
    end,
})

ViewmodelGroupBox:AddSlider('ViewmodelOffsetY', {
    Text = 'Offset Y',
    Default = SETTINGS.Viewmodel.Offset.Y,
    Min = -5,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        SETTINGS.Viewmodel.Offset.Y = Value
    end,
})

ViewmodelGroupBox:AddSlider('ViewmodelOffsetZ', {
    Text = 'Offset Z',
    Default = SETTINGS.Viewmodel.Offset.Z,
    Min = -5,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        SETTINGS.Viewmodel.Offset.Z = Value
    end,
})

-- =============================================
-- CORE FUNCTIONS: PLAYER & TEAM HANDLING
-- =============================================

local function UpdateLocalTeam()
    if LocalPlayer and LocalPlayer.Team then
        currentTeam = LocalPlayer.Team
    end
end

UpdateLocalTeam()

LocalPlayer:GetPropertyChangedSignal('Team'):Connect(function()
    UpdateLocalTeam()
    for player in pairs(Storage.esp_cache) do
        UncacheObject(player)
    end
    ClearHighlightChams()
    ClearBoxChams()
end)

local function GetPlayers()
    local entity_list = {}
    local playersFolder = workspace[SETTINGS.Game.PlayerFolder]

    for _, team in ipairs(playersFolder:GetChildren()) do
        for _, player in ipairs(team:GetChildren()) do
            if player:IsA('Model') then
                entity_list[#entity_list + 1] = player
            end
        end
    end
    return entity_list
end

local function IsEnemy(player)
    if not currentTeam then
        UpdateLocalTeam()
        if not currentTeam then
            return false
        end
    end

    local playerTeamFolder = player.Parent
    if
        not playerTeamFolder
        or playerTeamFolder.Parent ~= workspace[SETTINGS.Game.PlayerFolder]
    then
        return false
    end

    if playerTeamFolder == currentTeam then
        return false
    end

    local helmetFolder = player:FindFirstChildWhichIsA('Folder')
    if helmetFolder then
        local helmet = helmetFolder:FindFirstChildOfClass('MeshPart')
        if helmet then
            local playerColor = helmet.BrickColor.Name
            local localTeamName = currentTeam.Name

            if playerColor == SETTINGS.Game.TeamColors.Phantoms then
                return localTeamName ~= 'Phantoms'
            else
                return localTeamName ~= 'Ghosts'
            end
        end
    end

    return true
end

local function GetBodyPart(player, part)
    if part == 'Head' then
        local head = player:FindFirstChild('Head')
        if head then
            return head
        end
    end

    for _, bodypart in ipairs(player:GetChildren()) do
        if bodypart:IsA('BasePart') then
            local mesh = bodypart:FindFirstChildOfClass('SpecialMesh')
            if mesh and TargetMeshIds[mesh.MeshId] then
                local meshId = mesh.MeshId
                if part == 'Head' and meshId == 'rbxassetid://6179256256' then
                    return bodypart
                elseif
                    part == 'Torso' and meshId == 'rbxassetid://4049240078'
                then
                    return bodypart
                end
            end
        end
    end

    return nil
end

-- =============================================
-- CORE FUNCTIONS: ESP CACHING
-- =============================================

local function CacheObject(object)
    if not Storage.esp_cache[object] then
        Storage.esp_cache[object] = {
            box_square = Drawing.new('Square'),
            tracer_line = Drawing.new('Line'),
            distance_label = Drawing.new('Text'),
        }

        local cache = Storage.esp_cache[object]
        cache.box_square.Filled = ESPSettings.Box.Filled
        cache.distance_label.Center = ESPSettings.Distance.CenterText
        cache.distance_label.Outline = ESPSettings.Distance.Outline
    end
end

local function UncacheObject(object)
    local cache = Storage.esp_cache[object]
    if cache then
        cache.box_square:Remove()
        cache.tracer_line:Remove()
        cache.distance_label:Remove()
        Storage.esp_cache[object] = nil
    end
end

-- =============================================
-- CORE FUNCTIONS: VIEWMODEL OFFSET
-- =============================================

local function UpdateViewmodelOffset()
    local Controller = WeaponControllerInterface.getActiveWeaponController()
    if not Controller then
        return
    end

    local weapon = Controller:getActiveWeapon()
    if not weapon then
        return
    end

    if not OriginalOffsets[weapon.weaponName] then
        OriginalOffsets[weapon.weaponName] = weapon._mainOffset
    end

    if SETTINGS.Viewmodel.Offset.Enabled then
        local X, Y, Z =
            SETTINGS.Viewmodel.Offset.X,
            SETTINGS.Viewmodel.Offset.Y,
            SETTINGS.Viewmodel.Offset.Z

        if weapon._aiming == nil then
            weapon._mainOffset = weapon._mainOffset:Lerp(
                OriginalOffsets[weapon.weaponName] * CFrame.new(X, Y, -Z),
                0.1
            )
        else
            if
                weapon._aiming == true
                and SETTINGS.Viewmodel.Offset.RemoveOnAim
            then
                weapon._mainOffset = weapon._mainOffset:Lerp(
                    OriginalOffsets[weapon.weaponName],
                    0.1
                )
            else
                weapon._mainOffset = weapon._mainOffset:Lerp(
                    OriginalOffsets[weapon.weaponName] * CFrame.new(X, Y, -Z),
                    0.1
                )
            end
        end
    else
        weapon._mainOffset =
            weapon._mainOffset:Lerp(OriginalOffsets[weapon.weaponName], 0.1)
    end
end

-- =============================================
-- CORE FUNCTIONS: HIGHLIGHT CHAMS
-- =============================================

function ClearHighlightChams()
    for player, highlight in pairs(Storage.highlight_chams) do
        if highlight and highlight:IsA('Highlight') then
            highlight:Destroy()
        end
    end
    Storage.highlight_chams = {}
end

function UpdateHighlightChams(player)
    local shouldEnable = (
        ESPSettings.Chams.Mode == 'Highlight'
        and ESPSettings.Chams.Highlight.Enabled
    )

    if not shouldEnable then
        if Storage.highlight_chams[player] then
            Storage.highlight_chams[player]:Destroy()
            Storage.highlight_chams[player] = nil
        end
        return
    end

    if not IsEnemy(player) then
        if Storage.highlight_chams[player] then
            Storage.highlight_chams[player]:Destroy()
            Storage.highlight_chams[player] = nil
        end
        return
    end

    if not Storage.highlight_chams[player] then
        local highlight = Instance.new('Highlight')
        highlight.Parent = CoreGui
        highlight.Adornee = player
        Storage.highlight_chams[player] = highlight

        task.wait(0.03)
    end

    local highlight = Storage.highlight_chams[player]
    if highlight and highlight:IsA('Highlight') then
        highlight.FillColor = ESPSettings.Chams.Highlight.Color
        highlight.OutlineColor = ESPSettings.Chams.Highlight.OutlineColor
        highlight.FillTransparency =
            ESPSettings.Chams.Highlight.FillTransparency
        highlight.OutlineTransparency =
            ESPSettings.Chams.Highlight.OutlineTransparency
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

        highlight.Parent = CoreGui
        highlight.Adornee = player
        highlight.Enabled = true
    end
end

-- =============================================
-- CORE FUNCTIONS: BOX CHAMS
-- =============================================

function ClearBoxChams()
    for player, boxData in pairs(Storage.box_chams) do
        if boxData and boxData.folder then
            boxData.folder:Destroy()
        end
    end
    Storage.box_chams = {}
end

function UpdateBoxChams(player)
    if not ESPSettings.Chams.Box.Enabled then
        if Storage.box_chams[player] then
            Storage.box_chams[player].folder:Destroy()
            Storage.box_chams[player] = nil
        end
        return
    end

    if not IsEnemy(player) then
        if Storage.box_chams[player] then
            Storage.box_chams[player].folder:Destroy()
            Storage.box_chams[player] = nil
        end
        return
    end

    local bodyParts = {
        Head = GetBodyPart(player, 'Head'),
        Torso = GetBodyPart(player, 'Torso'),
        LeftArm = nil,
        RightArm = nil,
        LeftLeg = nil,
        RightLeg = nil,
    }

    local foundArms = {}
    local foundLegs = {}

    for _, part in ipairs(player:GetChildren()) do
        if part:IsA('BasePart') then
            local mesh = part:FindFirstChildOfClass('SpecialMesh')
            if mesh and TargetMeshIds[mesh.MeshId] then
                local meshId = mesh.MeshId

                if meshId == 'rbxassetid://4049240323' then
                    table.insert(foundArms, part)
                elseif meshId == 'rbxassetid://4049240209' then
                    table.insert(foundLegs, part)
                end
            end
        end
    end

    if #foundArms >= 2 then
        table.sort(foundArms, function(a, b)
            return a.Position.X < b.Position.X
        end)
        bodyParts.LeftArm = foundArms[1]
        bodyParts.RightArm = foundArms[2]
    elseif #foundArms == 1 then
        if
            foundArms[1].Position.X
            < (bodyParts.Torso and bodyParts.Torso.Position.X or 0)
        then
            bodyParts.LeftArm = foundArms[1]
        else
            bodyParts.RightArm = foundArms[1]
        end
    end

    if #foundLegs >= 2 then
        table.sort(foundLegs, function(a, b)
            return a.Position.X < b.Position.X
        end)
        bodyParts.LeftLeg = foundLegs[1]
        bodyParts.RightLeg = foundLegs[2]
    elseif #foundLegs == 1 then
        if
            foundLegs[1].Position.X
            < (bodyParts.Torso and bodyParts.Torso.Position.X or 0)
        then
            bodyParts.LeftLeg = foundLegs[1]
        else
            bodyParts.RightLeg = foundLegs[1]
        end
    end

    if not bodyParts.Torso then
        if Storage.box_chams[player] then
            Storage.box_chams[player].folder:Destroy()
            Storage.box_chams[player] = nil
        end
        return
    end

    if not Storage.box_chams[player] then
        local folder = Instance.new('Folder')
        folder.Name = 'BoxChams_' .. player.Name
        folder.Parent = workspace.Ignore.Misc

        Storage.box_chams[player] = {
            folder = folder,
            parts = {},
        }
    end

    local boxData = Storage.box_chams[player]
    local folder = boxData.folder

    for partName, bodyPart in pairs(bodyParts) do
        if bodyPart and not boxData.parts[partName] then
            local boxAdornment = Instance.new('BoxHandleAdornment')
            boxAdornment.Name = 'BoxCham_' .. partName
            boxAdornment.Adornee = bodyPart
            boxAdornment.AlwaysOnTop = true
            boxAdornment.Size = bodyPart.Size
                * ESPSettings.Chams.Box.SizeMultiplier
            boxAdornment.Color3 = ESPSettings.Chams.Box.Color
            boxAdornment.Transparency = ESPSettings.Chams.Box.Transparency
            boxAdornment.ZIndex = 0
            boxAdornment.Parent = folder

            boxData.parts[partName] = boxAdornment
        elseif not bodyPart and boxData.parts[partName] then
            boxData.parts[partName]:Destroy()
            boxData.parts[partName] = nil
        end
    end

    for partName, bodyPart in pairs(bodyParts) do
        if bodyPart and boxData.parts[partName] then
            local boxAdornment = boxData.parts[partName]

            local sizeMultiplier = ESPSettings.Chams.Box.SizeMultiplier
            if partName == 'Head' then
                boxAdornment.Size = Vector3.new(1.2, 1, 1) * sizeMultiplier
            elseif partName == 'Torso' then
                boxAdornment.Size = Vector3.new(2, 2, 1) * sizeMultiplier
            elseif partName:find('Arm') then
                boxAdornment.Size = Vector3.new(1, 2, 1) * sizeMultiplier
            elseif partName:find('Leg') then
                boxAdornment.Size = Vector3.new(1, 2, 1) * sizeMultiplier
            else
                boxAdornment.Size = bodyPart.Size * sizeMultiplier
            end

            boxAdornment.Color3 = ESPSettings.Chams.Box.Color
            boxAdornment.Transparency = ESPSettings.Chams.Box.Transparency
            boxAdornment.Adornee = bodyPart
        end
    end
end

-- =============================================
-- CORE FUNCTIONS: BULLET TRACERS
-- =============================================

function Visuals:RenderBulletTracer(Origin, Target, Lifetime, Color, Color2)
    local BeamStorage = Instance.new('Folder')
    BeamStorage.Name = 'BulletTracer'
    BeamStorage.Parent = self.Storage

    local Start = Instance.new('Part')
    Start.Position = Origin
    Start.Parent = BeamStorage
    Start.Transparency = 1
    Start.CanCollide = false
    Start.Anchored = true
    Start.Size = Vector3.new(0, 0, 0)

    local End = Start:Clone()
    End.Parent = BeamStorage
    End.Position = Target

    local A0 = Instance.new('Attachment')
    A0.Parent = Start

    local A1 = Instance.new('Attachment')
    A1.Parent = End

    local TextureName = SETTINGS.BulletTracers.Local.Texture
    local BeamWidth = TextureName == 'Nothing' and 0.075 or 0.9

    local Beam = Instance.new('Beam')
    Beam.Parent = BeamStorage
    Beam.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color),
        ColorSequenceKeypoint.new(1, Color2),
    })
    Beam.Transparency = NumberSequence.new(1)
    Beam.Width0 = BeamWidth
    Beam.Width1 = BeamWidth
    Beam.Attachment0 = A0
    Beam.Attachment1 = A1
    Beam.FaceCamera = true
    Beam.Texture = SETTINGS.BulletTracers.Textures[TextureName]
    Beam.TextureSpeed = 1 + math.random()
    Beam.TextureLength = 4
    Beam.TextureMode = Enum.TextureMode.Static
    Beam.LightEmission = 10

    task.spawn(function()
        for Transparency = 1, 0, -1 / 30 do
            Beam.Transparency = NumberSequence.new(Transparency)
            task.wait()
        end
    end)

    task.delay(Lifetime, function()
        for Transparency = 0, 1, 1 / 60 do
            Beam.Transparency = NumberSequence.new(Transparency)
            task.wait()
        end
        BeamStorage:Destroy()
    end)

    table.insert(self.TracerBeams, BeamStorage)

    return Beam
end

task.spawn(function()
    while true do
        task.wait(10)
        local currentTime = tick()
        for i = #Visuals.TracerBeams, 1, -1 do
            local beam = Visuals.TracerBeams[i]
            if not beam or not beam.Parent then
                table.remove(Visuals.TracerBeams, i)
            end
        end
    end
end)

-- =============================================
-- CORE FUNCTIONS: THIRD PERSON & ANTI-AIM
-- =============================================

local function applyAAAngles(angles)
    local newAngles = angles
    local currentTime = os.clock()
    local deltaTime = currentTime - (lastFrameTime or currentTime)
    lastFrameTime = currentTime

    local x, y, z = angles.X, angles.Y, angles.Z

    if SETTINGS.ThirdPerson.AntiAim.Mode == 'Spin' then
        local spinRadians = (currentTime - startTime)
            * math.rad(SETTINGS.ThirdPerson.AntiAim.SpinSpeed)
        y = spinRadians
        newAngles = Vector3.new(x, y, z)
    elseif SETTINGS.ThirdPerson.AntiAim.Mode == 'Jitter' then
        local jitter = math.rad(
            math.random(
                -SETTINGS.ThirdPerson.AntiAim.JitterAngle,
                SETTINGS.ThirdPerson.AntiAim.JitterAngle
            )
        )
        newAngles = Vector3.new(x, y + jitter, z)
    elseif SETTINGS.ThirdPerson.AntiAim.Mode == 'Static' then
        newAngles = Vector3.new(
            x,
            math.rad(SETTINGS.ThirdPerson.AntiAim.StaticAngle),
            z
        )
    end

    if SETTINGS.ThirdPerson.AntiAim.PitchMode == 'Up' then
        x = math.clamp(
            x + math.rad(SETTINGS.ThirdPerson.AntiAim.PitchAngle),
            math.rad(-89),
            math.rad(89)
        )
    elseif SETTINGS.ThirdPerson.AntiAim.PitchMode == 'Down' then
        x = math.clamp(
            x - math.rad(SETTINGS.ThirdPerson.AntiAim.PitchAngle),
            math.rad(-89),
            math.rad(89)
        )
    elseif SETTINGS.ThirdPerson.AntiAim.PitchMode == 'Random' then
        x = math.clamp(
            math.rad(
                math.random(
                    -SETTINGS.ThirdPerson.AntiAim.PitchAngle,
                    SETTINGS.ThirdPerson.AntiAim.PitchAngle
                )
            ),
            math.rad(-89),
            math.rad(89)
        )
    end

    return Vector3.new(x, newAngles.Y, z)
end

local function updateViewModelChams()
    if
        SETTINGS.ThirdPerson.Enabled
        and SETTINGS.ThirdPerson.HideViewmodel
        and not SETTINGS.ThirdPerson.ShowCharacter
    then
        return
    end

    local armsModels = {}
    local weaponModels = {}
    for _, model in ipairs(workspace.Camera:GetChildren()) do
        if not model:IsA('Model') then
            continue
        end
        local isArmModel = false
        for _, descendant in ipairs(model:GetDescendants()) do
            local name = descendant.Name:lower()
            if
                string.find(name, 'arm')
                or string.find(name, 'sleeve')
                or string.find(name, 'hand')
            then
                isArmModel = true
                break
            end
        end

        if isArmModel then
            table.insert(armsModels, model)
        else
            table.insert(weaponModels, model)
        end
    end

    for _, armModel in ipairs(armsModels) do
        for _, part in ipairs(armModel:GetDescendants()) do
            if not (part:IsA('BasePart') or part:IsA('MeshPart')) then
                continue
            end
            if not Storage.ViewmodelProperties[part] then
                Storage.ViewmodelProperties[part] = {
                    Transparency = part.Transparency,
                    Material = part.Material or Enum.Material.SmoothPlastic,
                    Color = part.Color or Color3.fromRGB(127, 0, 255),
                    Blacklisted = part.Transparency > 0.9,
                    Textures = {},
                }
                for _, c in ipairs(part:GetChildren()) do
                    if c:IsA('Texture') or c:IsA('Decal') then
                        table.insert(
                            Storage.ViewmodelProperties[part].Textures,
                            c
                        )
                    end
                end
            end
        end
    end

    for _, weaponModel in ipairs(weaponModels) do
        for _, part in ipairs(weaponModel:GetDescendants()) do
            if not (part:IsA('BasePart') or part:IsA('MeshPart')) then
                continue
            end
            if not Storage.ViewmodelProperties[part] then
                Storage.ViewmodelProperties[part] = {
                    Transparency = part.Transparency,
                    Material = part.Material or Enum.Material.SmoothPlastic,
                    Color = part.Color or Color3.fromRGB(127, 0, 255),
                    Blacklisted = part.Transparency > 0.9,
                    Textures = {},
                }
                for _, c in ipairs(part:GetChildren()) do
                    if c:IsA('Texture') or c:IsA('Decal') then
                        table.insert(
                            Storage.ViewmodelProperties[part].Textures,
                            c
                        )
                    end
                end
            end
        end
    end
end

local originalScreenCullStep = ScreenCull.step
ScreenCull.step = function(...)
    originalScreenCullStep(...)
    if SETTINGS.ThirdPerson.Enabled then
        local controller = WeaponControllerInterface.getActiveWeaponController()
        if
            controller
            and (
                SETTINGS.ThirdPerson.ShowCharacterWhileAiming
                or not controller:getActiveWeapon()._aiming
            )
        then
            local cameraOffset = Vector3.new(
                SETTINGS.ThirdPerson.CameraOffsetX,
                SETTINGS.ThirdPerson.CameraOffsetY,
                SETTINGS.ThirdPerson.CameraOffsetZ
            )
            local didHit = false
            if SETTINGS.ThirdPerson.CameraOffsetAlwaysVisible then
                local oldPosition = Camera.CFrame.Position
                local newPosition = Camera.CFrame * cameraOffset
                local dir = newPosition - oldPosition
                local params = RaycastParams.new()
                params.IgnoreWater = true
                params.FilterDescendantsInstances = {
                    workspace.Terrain,
                    workspace.Ignore,
                    workspace.Players,
                    Camera,
                }
                params.FilterType = Enum.RaycastFilterType.Blacklist
                local result = workspace:Raycast(oldPosition, dir, params)
                if result then
                    Camera.CFrame = Camera.CFrame
                        * CFrame.new(
                            cameraOffset
                                * ((result.Position - oldPosition).Magnitude / cameraOffset.Magnitude)
                                * 0.99
                        )
                    didHit = true
                end
            end
            if not didHit then
                Camera.CFrame = Camera.CFrame * CFrame.new(cameraOffset)
            end
        end
    end
end

local originalSetCharacterRender = ThirdPersonObject.setCharacterRender
function ThirdPersonObject:setCharacterRender(render)
    if SETTINGS.ThirdPerson.Enabled then
        return originalSetCharacterRender(
            self,
            render
                or (
                    self._player ~= LocalPlayer
                    and Camera:WorldToViewportPoint(
                            self._replicationObject._receivedPosition
                                or self:getRootPart().Position
                        ).Z
                        > 0
                )
        )
    end
    return originalSetCharacterRender(self, render)
end

local originalNetworkSend = NetworkClient.send
function NetworkClient:send(name, ...)
    if SETTINGS.ThirdPerson.Enabled and SETTINGS.ThirdPerson.ShowCharacter then
        if name == 'spawn' then
            if not started then
                started = true
                newSpawnCache = {
                    currentAddition = 0,
                    latency = 0,
                    updateDebt = 0,
                    spawnTime = os.clock(),
                    spawned = true,
                    lastUpdate = nil,
                    lastUpdateTime = 0,
                }
                if not currentObj then
                    if fakeRepObject then
                        currentObj = CharacterInterface.getCharacterObject()
                        if not currentObj then
                            pcall(function()
                                currentObj =
                                    ThirdPersonObject.new(fakeRepObject)
                                if currentObj then
                                    currentObj:spawn()
                                end
                            end)
                        else
                            currentObj:spawn()
                        end
                    else
                        warn(
                            'fakeRepObject is nil, cannot initialize third-person character'
                        )
                    end
                end
            end
        elseif currentObj then
            if name == 'equip' then
                local slot = ...
                fakeRepObject:setActiveIndex(slot)
                if slot ~= 3 then
                    currentObj:equip(slot)
                else
                    currentObj:equipMelee()
                end
            elseif name == 'stab' then
                currentObj:stab()
            elseif name == 'aim' then
                local aiming = ...
                currentObj:setAim(aiming)
            elseif name == 'sprint' then
                local sprinting = ...
                currentObj:setSprint(sprinting)
            elseif name == 'stance' then
                local stance = ...
                currentObj:setStance(stance)
            elseif
                name == 'flaguser'
                or name == 'debug'
                or name == 'logmessage'
            then
                return
            end
        end
    end

    if name == 'repupdate' then
        local position, angles, angles2, time = ...
        if SETTINGS.ThirdPerson.AntiAim.Enabled then
            angles = applyAAAngles(angles)
            angles2 =
                Vector3.new(angles.X * 0.99, angles.Y * 0.99, angles.Z * 0.99)
        end
        return originalNetworkSend(self, name, position, angles, angles2, time)
    end

    return originalNetworkSend(self, name, ...)
end

local originalPreparePickUpFirearm =
    WeaponControllerInterface.preparePickUpFirearm
function WeaponControllerInterface:preparePickUpFirearm(
    slot,
    name,
    attachments,
    attData,
    camoData,
    magAmmo,
    spareAmmo,
    newId,
    wasClient,
    ...
)
    local wepData = {
        weaponName = name,
        weaponAttachments = attachments,
        weaponAttData = attData,
        weaponCamo = camoData,
    }
    fakeRepObject:setActiveIndex(slot)
    fakeRepObject:swapWeapon(slot, wepData)
    if currentObj then
        currentObj:buildWeapon(slot)
    end
    return originalPreparePickUpFirearm(
        self,
        slot,
        name,
        attachments,
        attData,
        camoData,
        magAmmo,
        spareAmmo,
        newId,
        wasClient,
        ...
    )
end

local originalPreparePickUpMelee = WeaponControllerInterface.preparePickUpMelee
function WeaponControllerInterface:preparePickUpMelee(slot, name, ...)
    fakeRepObject:setActiveIndex(slot)
    fakeRepObject:swapWeapon(slot, { weaponName = name })
    if currentObj then
        currentObj:buildWeapon(slot)
    end
    return originalPreparePickUpMelee(slot, name, ...)
end

-- =============================================
-- CORE FUNCTIONS: SILENT AIM
-- =============================================

local _getActiveWeaponController =
    WeaponControllerInterface.getActiveWeaponController
local function GetWeaponController()
    local Controller = _getActiveWeaponController()
    if not Controller then
        return
    end

    local Weapon = Controller:getActiveWeapon()
    if not Weapon then
        return
    end

    return Controller, Weapon
end

function SilentAim:GetClosestEntry(Origin)
    local ClosestEntry, CurrentDistance = nil, 9e9

    ReplicationInterface.operateOnAllEntries(function(Player, Entry)
        if Player.Team ~= LocalPlayer.Team then
            if Entry._alive and Entry._receivedPosition then
                local CharacterHash = Entry._thirdPersonObject
                CharacterHash = CharacterHash
                    and CharacterHash:getCharacterHash()
                if CharacterHash and CharacterHash.Head then
                    local ViewportPoint, OnScreen =
                        Camera:WorldToViewportPoint(Entry._receivedPosition)
                    ViewportPoint =
                        Vector2.new(ViewportPoint.X, ViewportPoint.Y)

                    local Distance = (ViewportPoint - Origin).Magnitude
                    if OnScreen and Distance <= CurrentDistance then
                        CurrentDistance = Distance
                        ClosestEntry = Entry
                    end
                end
            end
        end
    end)

    return ClosestEntry,
        ClosestEntry and ClosestEntry._thirdPersonObject:getCharacterHash(),
        CurrentDistance
end

function SilentAim:Prediction(Origin, Target, Velocity, BulletSpeed)
    local Distance = (Target - Origin).Magnitude
    local TravelTime = Distance / BulletSpeed
    local BulletDrop = 0.5 * workspace.Gravity * TravelTime ^ 2

    return (Velocity * TravelTime) + Vector3.new(0, BulletDrop, 0)
end

function SilentAim:GetTrajectory(Origin, Target, Acceleration, Speed)
    local NegativeAcceleration = -Acceleration
    local Displacement = Target - Origin
    local ForceDot = Displacement:Dot(NegativeAcceleration)
    local DisplacementDot = 4 * Displacement:Dot(Displacement)
    local IntermediateK = (
        4 * (NegativeAcceleration:Dot(Displacement) + Speed * Speed)
    ) / (2 * ForceDot)
    local Discriminant = (
        IntermediateK * IntermediateK - DisplacementDot / ForceDot
    ) ^ 0.5
    local Time1, Time2 =
        IntermediateK - Discriminant, IntermediateK + Discriminant

    local Time = Time1 < 0 and Time2 or Time1
    Time = Time ^ 0.5

    return NegativeAcceleration * Time / 2 + Displacement / Time, Time
end

-- =============================================
-- HOOKS: BULLET INTERFACE & NETWORK
-- =============================================

local _BInewBullet = BulletInterface.newBullet
function BulletInterface.newBullet(Data)
    if Data.ontouch and Data.extra then
        local VisualPosition = Data.visualorigin
        local FirePosition = Data.position
        local OriginalVelocity = Data.velocity

        local Controller, Weapon = GetWeaponController()
        if Controller and Weapon then
            local BulletSpeed = Weapon:getWeaponStat('bulletspeed') or 0

            local IsUsingSilentAim = false
            local SilentAimTarget = nil
            local ModifiedVelocity = nil

            local Acceleration = PublicSettings.bulletAcceleration
            if SETTINGS.SilentAim.Enabled and not Data.im_hacking then
                local MousePos = ViewportSize / 2
                local Entry, CharacterHash, DistanceFromMouse =
                    SilentAim:GetClosestEntry(MousePos)

                if
                    CharacterHash
                    and DistanceFromMouse
                        < (SETTINGS.SilentAim.UseFOV and SETTINGS.SilentAim.FOVRadius or 9e9)
                then
                    local HitPart =
                        CharacterHash[SETTINGS.SilentAim.TargetPart or 'Head']

                    if math_random(100) < SETTINGS.SilentAim.HeadshotChance then
                        HitPart = CharacterHash.Head
                    end

                    if HitPart then
                        local Prediction = SilentAim:Prediction(
                            FirePosition,
                            HitPart.Position,
                            Entry._velspring.t,
                            BulletSpeed
                        )
                        local Velocity = SilentAim:GetTrajectory(
                            FirePosition,
                            HitPart.Position + Prediction,
                            Acceleration,
                            BulletSpeed
                        )

                        if math_random(100) < SETTINGS.SilentAim.HitChance then
                            Velocity = Velocity
                                + Vector3.new(
                                        math_random(-100, 100) / 100,
                                        math_random(-100, 100) / 100,
                                        math_random(-100, 100) / 100
                                    )
                                    * 5
                        end

                        SilentAim.Velocity = Velocity
                        Data.velocity = Velocity
                        SilentAim.LastTarget = Entry._player

                        IsUsingSilentAim = true
                        SilentAimTarget = HitPart.Position + Prediction
                        ModifiedVelocity = Velocity
                    end
                end
            end

            if SETTINGS.BulletTracers.Local.Enabled then
                local Direction
                local FinalPosition

                if IsUsingSilentAim and ModifiedVelocity then
                    Direction = ModifiedVelocity.Unit
                        * (BulletSpeed > 0 and BulletSpeed or 1000)

                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {
                        workspace.Terrain,
                        workspace.Ignore,
                        workspace.Players,
                        Camera,
                    }
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

                    local RayResult = workspace:Raycast(
                        FirePosition,
                        Direction,
                        raycastParams
                    )
                    FinalPosition = RayResult and RayResult.Position
                        or (FirePosition + Direction)
                else
                    Direction = OriginalVelocity.Unit
                        * (BulletSpeed > 0 and BulletSpeed or 1000)

                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {
                        workspace.Terrain,
                        workspace.Ignore,
                        workspace.Players,
                        Camera,
                    }
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

                    local RayResult = workspace:Raycast(
                        FirePosition,
                        Direction,
                        raycastParams
                    )
                    FinalPosition = RayResult and RayResult.Position
                        or (FirePosition + Direction)
                end

                local TracerOrigin = FirePosition
                if
                    SETTINGS.BulletTracers.UseThirdPersonMuzzle
                    and SETTINGS.ThirdPerson.Enabled
                    and currentObj
                then
                    local Muzzle = currentObj._muzzlePart
                    if Muzzle then
                        TracerOrigin = Muzzle.Position
                    end
                end

                if SETTINGS.BulletTracers.UseNewOrigin then
                    TracerOrigin = Data.position
                end

                Visuals:RenderBulletTracer(
                    TracerOrigin,
                    FinalPosition,
                    SETTINGS.BulletTracers.Local.Lifetime,
                    SETTINGS.BulletTracers.Local.ColorStart,
                    SETTINGS.BulletTracers.Local.ColorEnd
                )
            end
        end

        Data.im_hacking = nil
    end

    return _BInewBullet(Data)
end

local originalNetworkSend = NetworkClient.send
function NetworkClient:send(name, ...)
    if name == 'newbullets' and rawget(SilentAim, 'Velocity') then
        local UniqueId, BulletData, ClockTime = ...
        for Index, Bullet in next, BulletData.bullets do
            Bullet[1] = rawget(SilentAim, 'Velocity')
        end

        rawset(SilentAim, 'Velocity', nil)
    end

    return originalNetworkSend(self, name, ...)
end

Reciever:Connect(function(Method, ...)
    if Method == 'newbullets' then
        local BulletData = ...

        local Shooter = BulletData.player
        if
            Shooter
            and Shooter.Team ~= LocalPlayer.Team
            and SETTINGS.BulletTracers.Enemy.Enabled
        then
            local FirePosition = BulletData.firepos

            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {
                workspace.Terrain,
                workspace.Ignore,
                workspace.Players,
                Camera,
            }
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

            for Index, Bullet in next, BulletData.bullets do
                local RayResult = workspace:Raycast(
                    FirePosition,
                    Bullet.velocity.Unit * 400,
                    raycastParams
                )

                local EndPosition = RayResult and RayResult.Position
                    or (FirePosition + Bullet.velocity.Unit * 400)

                Visuals:RenderBulletTracer(
                    FirePosition,
                    EndPosition,
                    SETTINGS.BulletTracers.Enemy.Lifetime,
                    SETTINGS.BulletTracers.Enemy.ColorStart,
                    SETTINGS.BulletTracers.Enemy.ColorEnd
                )
            end
        end
    end
end)

-- =============================================
-- CORE FUNCTIONS: AIMBOT
-- =============================================

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == AimbotSettings.TriggerKey then
        isHoldingMouse2 = true
        currentTarget = nil
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AimbotSettings.TriggerKey then
        isHoldingMouse2 = false
        currentTarget = nil
    end
end)

local function GetClosestTarget()
    if currentTarget and currentTarget.Parent then
        local playerModel = currentTarget.Parent
        if IsEnemy(playerModel) then
            local screenPos, onScreen =
                Camera:WorldToViewportPoint(currentTarget.Position)
            local mousePos = ViewportSize / 2
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

            if onScreen then
                if AimbotSettings.UseFOV then
                    if
                        distance
                        <= (
                            SETTINGS.FOVCircle.Radius
                            * AimbotSettings.TargetStickiness
                        )
                    then
                        return currentTarget
                    end
                else
                    return currentTarget
                end
            end
        end
    end

    local closestTarget = nil
    local shortestDistance = math.huge
    local mousePos = ViewportSize / 2

    for _, player in ipairs(GetPlayers()) do
        if player ~= LocalPlayer.Character and IsEnemy(player) then
            local targetPart = GetBodyPart(player, AimbotSettings.AimPart)
            if targetPart and targetPart.Parent then
                local screenPos, onScreen =
                    Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (
                        Vector2.new(screenPos.X, screenPos.Y) - mousePos
                    ).Magnitude

                    if AimbotSettings.UseFOV then
                        local maxAllowed = SETTINGS.FOVCircle.Radius
                            * AimbotSettings.TargetStickiness
                        if
                            distance <= maxAllowed
                            and distance < shortestDistance
                        then
                            shortestDistance = distance
                            closestTarget = targetPart
                        end
                    else
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestTarget = targetPart
                        end
                    end
                end
            end
        end
    end

    if closestTarget then
        currentTarget = closestTarget
        targetLockTime = tick()
    end

    return closestTarget
end

-- =============================================
-- MAIN UPDATE LOOPS: ESP, AIMBOT, FOV, THIRD PERSON
-- =============================================

function UpdateESP()
    ViewportSize = Camera.ViewportSize

    if tick() - teamCheckCooldown > SETTINGS.Performance.TeamCheckInterval then
        UpdateLocalTeam()
        teamCheckCooldown = tick()
    end

    local validPlayers = {}
    local playerList = GetPlayers()

    for i = 1, #playerList do
        local player = playerList[i]
        if IsEnemy(player) then
            validPlayers[player] = true
            CacheObject(player)

            if ESPSettings.Chams.Mode == 'Highlight' then
                UpdateHighlightChams(player)
                ClearBoxChams()
            elseif ESPSettings.Chams.Mode == 'Box' then
                UpdateBoxChams(player)
                ClearHighlightChams()
            else
                ClearHighlightChams()
                ClearBoxChams()
            end
        else
            if Storage.highlight_chams[player] then
                Storage.highlight_chams[player]:Destroy()
                Storage.highlight_chams[player] = nil
            end
            if Storage.box_chams[player] then
                Storage.box_chams[player].folder:Destroy()
                Storage.box_chams[player] = nil
            end
        end
    end

    if SETTINGS.Performance.CacheCleanup then
        for player in pairs(Storage.esp_cache) do
            if not validPlayers[player] then
                UncacheObject(player)
            end
        end

        for player in pairs(Storage.highlight_chams) do
            if not validPlayers[player] or not player.Parent then
                if Storage.highlight_chams[player] then
                    Storage.highlight_chams[player]:Destroy()
                end
                Storage.highlight_chams[player] = nil
            end
        end

        for player in pairs(Storage.box_chams) do
            if not validPlayers[player] or not player.Parent then
                if
                    Storage.box_chams[player]
                    and Storage.box_chams[player].folder
                then
                    Storage.box_chams[player].folder:Destroy()
                end
                Storage.box_chams[player] = nil
            end
        end
    end

    for player, cache in pairs(Storage.esp_cache) do
        if player.Parent then
            local torso = GetBodyPart(player, 'Torso')
            if torso then
                local w2s, onscreen =
                    Camera:WorldToViewportPoint(torso.Position)

                if onscreen then
                    local pixelDist = (
                        Vector2.new(w2s.X, w2s.Y) - (ViewportSize / 2)
                    ).Magnitude

                    if
                        ESPSettings.UseFOV
                        and pixelDist > SETTINGS.FOVCircle.Radius
                    then
                        cache.box_square.Visible = false
                        cache.tracer_line.Visible = false
                        cache.distance_label.Visible = false

                        if Storage.highlight_chams[player] then
                            Storage.highlight_chams[player].Enabled = false
                        end
                        if Storage.box_chams[player] then
                            for partName, boxPart in
                                pairs(Storage.box_chams[player].parts)
                            do
                                if boxPart then
                                    boxPart.Transparency = 1
                                end
                            end
                        end
                    else
                        local distance = (
                            Camera.CFrame.Position - torso.Position
                        ).Magnitude
                        local scale = ESPSettings.Scaling.DistanceFactor
                            / distance
                            * ESPSettings.Scaling.BaseScale
                            / Camera.FieldOfView
                        local box_scale = Vector2.new(
                            math.round(
                                ESPSettings.Scaling.BoxWidthMultiplier * scale
                            ),
                            math.round(
                                ESPSettings.Scaling.BoxHeightMultiplier * scale
                            )
                        )
                        local box_pos = Vector2.new(
                            w2s.X - box_scale.X * 0.5,
                            w2s.Y - box_scale.Y * 0.5
                        )

                        if ESPSettings.Box.Enabled then
                            cache.box_square.Visible = true
                            cache.box_square.Color = ESPSettings.Box.Color
                            cache.box_square.Thickness =
                                ESPSettings.Box.Thickness
                            cache.box_square.Position = box_pos
                            cache.box_square.Size = box_scale
                        else
                            cache.box_square.Visible = false
                        end

                        if ESPSettings.Tracer.Enabled then
                            cache.tracer_line.Visible = true
                            cache.tracer_line.Color = ESPSettings.Tracer.Color
                            cache.tracer_line.Thickness =
                                ESPSettings.Tracer.Thickness
                            cache.tracer_line.From = Vector2.new(
                                ViewportSize.X
                                    * ESPSettings.Tracer.FromPosition.X,
                                ViewportSize.Y
                                    * ESPSettings.Tracer.FromPosition.Y
                            )
                            cache.tracer_line.To = Vector2.new(w2s.X, w2s.Y)
                        else
                            cache.tracer_line.Visible = false
                        end

                        if ESPSettings.Distance.Enabled then
                            cache.distance_label.Visible = true
                            cache.distance_label.Text = math.floor(distance)
                                .. ' studs'
                            cache.distance_label.Size =
                                ESPSettings.Distance.Size
                            cache.distance_label.Color =
                                ESPSettings.Distance.Color
                            cache.distance_label.Position = Vector2.new(
                                box_pos.X + box_scale.X * 0.5,
                                box_pos.Y - ESPSettings.Distance.Offset
                            )
                        else
                            cache.distance_label.Visible = false
                        end

                        if Storage.highlight_chams[player] then
                            Storage.highlight_chams[player].Enabled = true
                        end
                        if Storage.box_chams[player] then
                            for partName, boxPart in
                                pairs(Storage.box_chams[player].parts)
                            do
                                if boxPart then
                                    boxPart.Transparency =
                                        ESPSettings.Chams.Box.Transparency
                                end
                            end
                        end
                    end
                else
                    cache.box_square.Visible = false
                    cache.tracer_line.Visible = false
                    cache.distance_label.Visible = false

                    if Storage.highlight_chams[player] then
                        Storage.highlight_chams[player].Enabled = false
                    end
                    if Storage.box_chams[player] then
                        for partName, boxPart in
                            pairs(Storage.box_chams[player].parts)
                        do
                            if boxPart then
                                boxPart.Transparency = 1
                            end
                        end
                    end
                end
            else
                UncacheObject(player)
                if Storage.highlight_chams[player] then
                    Storage.highlight_chams[player]:Destroy()
                    Storage.highlight_chams[player] = nil
                end
                if Storage.box_chams[player] then
                    Storage.box_chams[player].folder:Destroy()
                    Storage.box_chams[player] = nil
                end
            end
        else
            UncacheObject(player)
            if Storage.highlight_chams[player] then
                Storage.highlight_chams[player]:Destroy()
                Storage.highlight_chams[player] = nil
            end
            if Storage.box_chams[player] then
                Storage.box_chams[player].folder:Destroy()
                Storage.box_chams[player] = nil
            end
        end
    end
end

local function UpdateAimbot()
    if AimbotSettings.Enabled and isHoldingMouse2 then
        local target = GetClosestTarget()
        if target and target.Parent then
            local targetScreenPos = Camera:WorldToViewportPoint(target.Position)
            local center = ViewportSize / 2

            local deltaX = targetScreenPos.X - center.X
            local deltaY = targetScreenPos.Y - center.Y

            if AimbotSettings.Smoothness < 1 then
                deltaX = deltaX * AimbotSettings.Smoothness
                deltaY = deltaY * AimbotSettings.Smoothness
            end

            mousemoverel(deltaX, deltaY)
        end
    elseif not isHoldingMouse2 then
        currentTarget = nil
    end
end

local function UpdateFOVCircle()
    local FOV = SETTINGS.FOVCircle
    if not FOV.Enabled then
        FOVCircle.Visible = false
        return
    end

    ViewportSize = Camera.ViewportSize
    local center = ViewportSize / 2

    FOVCircle.Visible = true
    FOVCircle.Position = center
    FOVCircle.Radius = FOV.Radius
    FOVCircle.Color = FOV.Color
    FOVCircle.Thickness = FOV.Thickness
    FOVCircle.Filled = FOV.Filled
    FOVCircle.Transparency = FOV.Transparency
end

RunService.RenderStepped:Connect(UpdateESP)
RunService.RenderStepped:Connect(UpdateAimbot)
RunService.RenderStepped:Connect(UpdateFOVCircle)

RunService.Heartbeat:Connect(function(ndt)
    if SETTINGS.ThirdPerson.Enabled and SETTINGS.ThirdPerson.ShowCharacter then
        local currentCharObject = CharacterInterface.getCharacterObject()
        local rootPart = currentCharObject
            and currentCharObject:getRealRootPart()
        local deltaTime = ndt
        if rootPart then
            if currentObj == nil and not started then
                started = true
            end
            local position = rootPart.Position
            lastPos = lastPos or position
            local velocity = (position - lastPos) / deltaTime
            deltaTime = 0
            if currentObj or started then
                if started then
                    if not fakeRepObject then
                        warn('fakeRepObject is nil, reinitializing...')
                        pcall(function()
                            fakeRepObject =
                                ReplicationObject.new(setmetatable({}, {
                                    __index = function(self, index)
                                        return LocalPlayer[index]
                                    end,
                                    __newindex = function(self, index, value)
                                        LocalPlayer[index] = value
                                    end,
                                }))
                        end)
                        if not fakeRepObject then
                            warn(
                                'Failed to initialize fakeRepObject, disabling third-person character'
                            )
                            SETTINGS.ThirdPerson.ShowCharacter = false
                            return
                        end
                    end
                    local playerClient = require('PlayerDataClientInterface')
                    local classData =
                        playerClient.getPlayerData().settings.classdata
                    fakeRepObject._player = LocalPlayer
                    fakeRepObject:spawn(nil, classData[classData.curclass])
                    currentObj = fakeRepObject._thirdPersonObject
                    if not currentObj then
                        warn('Failed to create third-person object')
                        SETTINGS.ThirdPerson.ShowCharacter = false
                        return
                    end
                    fakeRepObject:setActiveIndex(1)
                    for i = 1, 3 do
                        if fakeRepObject:getWeaponObjects()[i] then
                            currentObj:buildWeapon(i)
                        end
                    end
                end
                local angles = CameraInterface:getActiveCamera():getAngles()
                if
                    SETTINGS.ThirdPerson.AntiAim.Enabled
                    and SETTINGS.ThirdPerson.ApplyAntiAimToCharacter
                then
                    angles = applyAAAngles(angles)
                end

                local clockTime = os.clock()
                local tickTime = tick()
                fakeRepObject._posspring.t = position
                fakeRepObject._posspring.p = position
                fakeRepObject._lookangles.t = angles
                fakeRepObject._lookangles.p = angles
                fakeRepObject._smoothReplication:receive(clockTime, tickTime, {
                    t = tickTime,
                    position = position,
                    velocity = velocity,
                    angles = angles,
                    barrelAngles = Vector3.zero,
                    breakcount = 0,
                }, true)
                fakeRepObject._updaterecieved = true
                fakeRepObject._receivedPosition = position
                fakeRepObject._receivedFrameTime = NetworkClient.getTime()
                fakeRepObject._lastPacketTime = clockTime
                fakeRepObject._lastBarrelAngles = Vector3.zero
                fakeRepObject:step(3, true)
                if currentObj then
                    currentObj.canRenderWeapon = true
                end
                started = false
                local controller =
                    WeaponControllerInterface.getActiveWeaponController()
                local aiming = controller
                    and controller:getActiveWeapon()
                    and controller:getActiveWeapon()._aiming
                if
                    not SETTINGS.ThirdPerson.ShowCharacterWhileAiming
                    and aiming
                then
                    ThirdPersonObject.setCharacterRender(currentObj, false)
                else
                    ThirdPersonObject.setCharacterRender(currentObj, true)
                end
            end
        elseif not started and currentObj then
            fakeRepObject:despawn()
            currentObj:Destroy()
            currentObj = nil
            lastPos = nil
        end
    else
        if currentObj then
            fakeRepObject:despawn()
            currentObj:Destroy()
            currentObj = nil
            lastPos = nil
            started = false
        end
        updateViewModelChams()
        UpdateViewmodelOffset()
    end
end)

RunService.Heartbeat:Connect(function()
    local controller = WeaponControllerInterface.getActiveWeaponController()
    local isAiming = controller
        and controller:getActiveWeapon()
        and controller:getActiveWeapon()._aiming
    local isScoped = controller
        and controller:getActiveWeapon()
        and controller:getActiveWeapon()._blackScoped
    local shouldHideViewmodel = SETTINGS.ThirdPerson.Enabled
        and SETTINGS.ThirdPerson.HideViewmodel
        and (SETTINGS.ThirdPerson.ShowCharacterWhileAiming or not isAiming)
    local CoreGui = game:GetService('CoreGui')

    if isAiming and isScoped then
        shouldHideViewmodel = true
    end -- bug fixesssssssss (no but srsly if you remove this it fucks scopes up)
    if shouldHideViewmodel then
        local gunTexFolder = CoreGui:FindFirstChild('guntex')
            or Instance.new('Folder', CoreGui)
        gunTexFolder.Name = 'guntex'
        for _, model in workspace.Camera:GetChildren() do
            if model:IsA('Model') and not model.Name:lower():find('arm') then
                for _, part in model:GetDescendants() do
                    if part:IsA('BasePart') or part:IsA('MeshPart') then
                        if not Storage.ViewmodelProperties[part] then
                            Storage.ViewmodelProperties[part] = {
                                Transparency = part.Transparency,
                                Textures = {},
                            }
                            for _, texture in part:GetChildren() do
                                if
                                    texture:IsA('Texture')
                                    or texture:IsA('Decal')
                                    or texture.Name == 'TextureId'
                                then
                                    table.insert(
                                        Storage.ViewmodelProperties[part].Textures,
                                        texture
                                    )
                                end
                            end
                        end
                        part.Transparency = 1
                        for _, texture in part:GetChildren() do
                            if
                                texture:IsA('Texture')
                                or texture:IsA('Decal')
                                or texture.Name == 'TextureId'
                            then
                                texture.Parent = gunTexFolder
                            end
                        end
                    end
                end
            end
        end
    else
        local gunTexFolder = CoreGui:FindFirstChild('guntex')
        if gunTexFolder then
            for _, texture in gunTexFolder:GetChildren() do
                for part, props in Storage.ViewmodelProperties do
                    for _, savedTexture in props.Textures do
                        if savedTexture == texture then
                            texture.Parent = part
                            break
                        end
                    end
                end
            end
            gunTexFolder:Destroy()
        end
        for part, props in Storage.ViewmodelProperties do
            if part:IsDescendantOf(workspace) then
                part.Transparency = props.Transparency
            end
        end
        Storage.ViewmodelProperties = {}
    end
end)

-- =============================================
-- UI & LIBRARY FINAL SETUP (WATERMARK, UNLOAD, CONFIGS)
-- =============================================

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
            SETTINGS.UI.WatermarkText:format(
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
    if SETTINGS.ThirdPerson.Enabled and SETTINGS.ThirdPerson.ShowCharacter then
        fakeRepObject:despawn()
        if currentObj then
            currentObj:Destroy()
            currentObj = nil
            lastPos = nil
        end
    end
    for part, props in Storage.ViewmodelProperties do
        if part:IsDescendantOf(workspace) then
            part.Transparency = props.Transparency
            for _, texture in props.Textures do
                if texture:IsDescendantOf(game.CoreGui) then
                    texture.Parent = part
                end
            end
        end
    end
    Storage.ViewmodelProperties = {}
    local gunTexFolder = game:GetService('CoreGui'):FindFirstChild('guntex')
    if gunTexFolder then
        gunTexFolder:Destroy()
    end
    ScreenCull.step = originalScreenCullStep
    ThirdPersonObject.setCharacterRender = originalSetCharacterRender
    NetworkClient.send = originalNetworkSend
    WeaponControllerInterface.preparePickUpFirearm =
        originalPreparePickUpFirearm
    WeaponControllerInterface.preparePickUpMelee = originalPreparePickUpMelee
    print('Unloaded!')
    Library.Unloaded = true
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function()
    Library:Unload()
end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = SETTINGS.UI.DefaultMenuKeybind,
    NoUI = true,
    Text = 'Menu keybind',
})

Library.ToggleKeybind = Options.MenuKeybind

SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

SaveManager:SetFolder(SETTINGS.UI.ConfigFolder)

SaveManager:BuildConfigSection(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()
