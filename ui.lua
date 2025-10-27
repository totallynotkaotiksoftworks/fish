-- Simple Roblox UI Library
local SimpleUI = {}

-- Create main window
function SimpleUI:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Container = Instance.new("Frame")
    local UIListLayout = Instance.new("UIListLayout")
    
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.Name = "SimpleUI_" .. tostring(math.random(1, 10000))
    
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.Gotham
    Title.Text = title or "Simple UI"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    
    Container.Name = "Container"
    Container.Parent = MainFrame
    Container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0, 0, 0, 30)
    Container.Size = UDim2.new(1, 0, 1, -30)
    
    UIListLayout.Parent = Container
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    
    local tab = {}
    
    function tab:CreateButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.Parent = Container
        Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(0.9, 0, 0, 35)
        Button.Font = Enum.Font.Gotham
        Button.Text = text or "Button"
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 14
        Button.AutoButtonColor = true
        
        if callback then
            Button.MouseButton1Click:Connect(callback)
        end
        
        return Button
    end
    
    function tab:CreateToggle(text, default, callback)
        local ToggleFrame = Instance.new("Frame")
        local ToggleButton = Instance.new("TextButton")
        local ToggleLabel = Instance.new("TextLabel")
        local ToggleState = Instance.new("Frame")
        
        ToggleFrame.Name = "ToggleFrame"
        ToggleFrame.Parent = Container
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Size = UDim2.new(0.9, 0, 0, 30)
        
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = ToggleFrame
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(0, 0, 0, 0)
        ToggleButton.Size = UDim2.new(0, 30, 0, 30)
        ToggleButton.Font = Enum.Font.SourceSans
        ToggleButton.Text = ""
        ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ToggleButton.TextSize = 14
        
        ToggleLabel.Name = "ToggleLabel"
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ToggleLabel.BorderSizePixel = 0
        ToggleLabel.Position = UDim2.new(0, 35, 0, 0)
        ToggleLabel.Size = UDim2.new(1, -35, 1, 0)
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.Text = text or "Toggle"
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.TextSize = 14
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        ToggleState.Name = "ToggleState"
        ToggleState.Parent = ToggleButton
        ToggleState.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        ToggleState.BorderSizePixel = 0
        ToggleState.Position = UDim2.new(0.1, 0, 0.1, 0)
        ToggleState.Size = UDim2.new(0.8, 0, 0.8, 0)
        
        local state = default or false
        
        local function updateToggle()
            if state then
                ToggleState.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            else
                ToggleState.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            end
            if callback then
                callback(state)
            end
        end
        
        ToggleButton.MouseButton1Click:Connect(function()
            state = not state
            updateToggle()
        end)
        
        updateToggle()
        
        return {
            Set = function(newState)
                state = newState
                updateToggle()
            end,
            Get = function()
                return state
            end
        }
    end
    
    function tab:CreateLabel(text)
        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Parent = Container
        Label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Label.BorderSizePixel = 0
        Label.Size = UDim2.new(0.9, 0, 0, 25)
        Label.Font = Enum.Font.Gotham
        Label.Text = text or "Label"
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 14
        
        return Label
    end
    
    function tab:CreateSlider(text, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        local SliderLabel = Instance.new("TextLabel")
        local SliderBar = Instance.new("Frame")
        local SliderFill = Instance.new("Frame")
        local SliderButton = Instance.new("TextButton")
        local ValueLabel = Instance.new("TextLabel")
        
        SliderFrame.Name = "SliderFrame"
        SliderFrame.Parent = Container
        SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Size = UDim2.new(0.9, 0, 0, 50)
        
        SliderLabel.Name = "SliderLabel"
        SliderLabel.Parent = SliderFrame
        SliderLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        SliderLabel.BorderSizePixel = 0
        SliderLabel.Size = UDim2.new(1, 0, 0, 20)
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.Text = text or "Slider"
        SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderLabel.TextSize = 14
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        SliderBar.Name = "SliderBar"
        SliderBar.Parent = SliderFrame
        SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        SliderBar.BorderSizePixel = 0
        SliderBar.Position = UDim2.new(0, 0, 0, 25)
        SliderBar.Size = UDim2.new(1, 0, 0, 10)
        
        SliderFill.Name = "SliderFill"
        SliderFill.Parent = SliderBar
        SliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        SliderFill.BorderSizePixel = 0
        SliderFill.Size = UDim2.new(0, 0, 1, 0)
        
        SliderButton.Name = "SliderButton"
        SliderButton.Parent = SliderBar
        SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderButton.BorderSizePixel = 0
        SliderButton.Size = UDim2.new(0, 15, 2, 0)
        SliderButton.Position = UDim2.new(0, 0, -0.5, 0)
        SliderButton.Font = Enum.Font.SourceSans
        SliderButton.Text = ""
        SliderButton.ZIndex = 2
        
        ValueLabel.Name = "ValueLabel"
        ValueLabel.Parent = SliderFrame
        ValueLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ValueLabel.BorderSizePixel = 0
        ValueLabel.Position = UDim2.new(0.8, 0, 0, 0)
        ValueLabel.Size = UDim2.new(0.2, 0, 0, 20)
        ValueLabel.Font = Enum.Font.Gotham
        ValueLabel.Text = tostring(default or min)
        ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ValueLabel.TextSize = 14
        
        min = min or 0
        max = max or 100
        default = default or min
        local value = default
        
        local function updateSlider()
            local percent = (value - min) / (max - min)
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            SliderButton.Position = UDim2.new(percent, -7, -0.5, 0)
            ValueLabel.Text = tostring(math.floor(value))
            if callback then
                callback(value)
            end
        end
        
        local dragging = false
        
        SliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relativeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * relativeX)
                updateSlider()
            end
        end)
        
        updateSlider()
        
        return {
            Set = function(newValue)
                value = math.clamp(newValue, min, max)
                updateSlider()
            end,
            Get = function()
                return value
            end
        }
    end
    
    function tab:Destroy()
        ScreenGui:Destroy()
    end
    
    return tab
end

return SimpleUI
