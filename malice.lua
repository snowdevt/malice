local Malice = {}

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Console Storage
local consoleOutput = {}
local consoleEnabled = false
local consoleGui = nil
local debounceTable = {}

-- === UI Creation ===
function Malice.CreateButton(parent, text, size, position, color)
    local button = Instance.new("TextButton")
    button.Parent = parent or game.StarterGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui", game.StarterGui)
    button.Text = text or "Button"
    button.Size = size or UDim2.new(0.2, 0, 0.1, 0)
    button.Position = position or UDim2.new(0.5, -50, 0.5, -25)
    button.BackgroundColor3 = color or Color3.fromRGB(50, 150, 255)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.TextScaled = true
    button.AutoButtonColor = true

    local function onActivate()
        if debounceTable[button] then return end
        debounceTable[button] = true
        Malice.Log("Button activated: " .. text, "Event")
        task.wait(0.2)
        debounceTable[button] = nil
    end
    button.MouseButton1Click:Connect(onActivate)
    button.TouchTap:Connect(onActivate)
    return button
end

function Malice.CreateLabel(parent, text, size, position, color)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.Text = text or "Label"
    label.Size = size or UDim2.new(0.2, 0, 0.05, 0)
    label.Position = position or UDim2.new(0.5, -50, 0.3, -15)
    label.BackgroundColor3 = color or Color3.fromRGB(80, 80, 80)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextScaled = true
    return label
end

function Malice.CreateDropdown(parent, options, size, position, color)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = size or UDim2.new(0.2, 0, 0.1, 0)
    frame.Position = position or UDim2.new(0.5, -50, 0.5, -25)
    frame.BackgroundColor3 = color or Color3.fromRGB(50, 150, 255)
    frame.ClipsDescendants = true

    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Parent = frame
    selectedLabel.Size = UDim2.new(1, -30, 1, 0)
    selectedLabel.Text = options[1] or "Select"
    selectedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectedLabel.Font = Enum.Font.SourceSans
    selectedLabel.TextSize = 16
    selectedLabel.TextScaled = true

    local dropButton = Instance.new("TextButton")
    dropButton.Parent = frame
    dropButton.Size = UDim2.new(0, 30, 1, 0)
    dropButton.Position = UDim2.new(1, -30, 0, 0)
    dropButton.Text = "▼"
    dropButton.BackgroundColor3 = Color3.fromRGB(30, 100, 200)
    dropButton.TextColor3 = Color3.fromRGB(255, 255, 255)

    local listFrame = Instance.new("Frame")
    listFrame.Parent = frame
    listFrame.Size = UDim2.new(1, 0, 0, #options * 30)
    listFrame.Position = UDim2.new(0, 0, 1, 0)
    listFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    listFrame.Visible = false

    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Parent = listFrame
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 30)
        optionButton.Text = option
        optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionButton.MouseButton1Click:Connect(function()
            selectedLabel.Text = option
            listFrame.Visible = false
            Malice.Log("Dropdown selected: " .. option, "Event")
        end)
    end

    dropButton.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
    end)
    return frame
end

function Malice.CreateTextbox(parent, placeholder, size, position, color)
    local textbox = Instance.new("TextBox")
    textbox.Parent = parent
    textbox.PlaceholderText = placeholder or "Enter text..."
    textbox.Size = size or UDim2.new(0.2, 0, 0.1, 0)
    textbox.Position = position or UDim2.new(0.5, -50, 0.5, -25)
    textbox.BackgroundColor3 = color or Color3.fromRGB(50, 150, 255)
    textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textbox.Font = Enum.Font.SourceSans
    textbox.TextSize = 16
    textbox.TextScaled = true
    textbox.Text = ""
    textbox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            Malice.Log("Textbox input: " .. textbox.Text, "Event")
        end
    end)
    return textbox
end

function Malice.CreateToggle(parent, text, size, position, color)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = size or UDim2.new(0.2, 0, 0.1, 0)
    frame.Position = position or UDim2.new(0.5, -50, 0.5, -25)
    frame.BackgroundColor3 = color or Color3.fromRGB(50, 150, 255)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text or "Toggle"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextScaled = true

    local toggleButton = Instance.new("TextButton")
    toggleButton.Parent = frame
    toggleButton.Size = UDim2.new(0.3, 0, 1, 0)
    toggleButton.Position = UDim2.new(0.7, 0, 0, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    toggleButton.Text = "OFF"
    local isOn = false

    toggleButton.MouseButton1Click:Connect(function()
        isOn = not isOn
        toggleButton.Text = isOn and "ON" or "OFF"
        toggleButton.BackgroundColor3 = isOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 100)
        Malice.Log("Toggle " .. text .. ": " .. (isOn and "ON" or "OFF"), "Event")
    end)
    return frame
end

function Malice.CreateSlider(parent, min, max, default, size, position, color)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = size or UDim2.new(0.2, 0, 0.05, 0)
    frame.Position = position or UDim2.new(0.5, -50, 0.5, -25)
    frame.BackgroundColor3 = color or Color3.fromRGB(50, 150, 255)

    local slider = Instance.new("TextButton")
    slider.Parent = frame
    slider.Size = UDim2.new(1, 0, 0.5, 0)
    slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    slider.Text = ""

    local knob = Instance.new("Frame")
    knob.Parent = slider
    knob.Size = UDim2.new(0.1, 0, 1, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Position = UDim2.new((default - min) / (max - min), 0, 0, 0)

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = frame
    valueLabel.Size = UDim2.new(1, 0, 0.5, 0)
    valueLabel.Position = UDim2.new(0, 0, 0.5, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextScaled = true

    local dragging = false
    slider.MouseButton1Down:Connect(function()
        dragging = true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    slider.MouseMoved:Connect(function(x)
        if dragging then
            local relativeX = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            knob.Position = UDim2.new(relativeX, 0, 0, 0)
            local value = min + (max - min) * relativeX
            valueLabel.Text = tostring(math.floor(value))
            Malice.Log("Slider value: " .. valueLabel.Text, "Event")
        end
    end)
    return frame
end

function Malice.CreateFrame(parent, size, position, color)
    local frame = Instance.new("Frame")
    frame.Parent = parent or game.StarterGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui", game.StarterGui)
    frame.Size = size or UDim2.new(0.5, 0, 0.4, 0)
    frame.Position = position or UDim2.new(0.5, -100, 0.5, -75)
    frame.BackgroundColor3 = color or Color3.fromRGB(30, 30, 30)
    return frame
end

function Malice.DestroyUI(element)
    if element then
        element:Destroy()
        debounceTable[element] = nil
    end
end

-- === Effect Creation ===
function Malice.FadeIn(object, duration)
    if not object then return end
    object.Transparency = 1
    local tweenInfo = TweenInfo.new(duration or 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, {Transparency = 0})
    tween:Play()
    return tween
end

function Malice.FadeOut(object, duration)
    if not object then return end
    object.Transparency = 0
    local tweenInfo = TweenInfo.new(duration or 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, {Transparency = 1})
    tween:Play()
    return tween
end

function Malice.CreateParticleEffect(parent, color, lifetime)
    local particle = Instance.new("ParticleEmitter")
    particle.Parent = parent or game.Workspace
    particle.Color = ColorSequence.new(color or Color3.fromRGB(255, 0, 0))
    particle.Lifetime = NumberRange.new(lifetime or 1)
    particle.Rate = 30
    particle.Speed = NumberRange.new(3, 7)
    particle.Enabled = true
    
    RunService.RenderStepped:Connect(function()
        if not particle.Parent then
            particle:Destroy()
        end
    end)
    return particle
end

function Malice.DestroyEffect(effect)
    if effect then
        effect.Enabled = false
        task.delay(1, function() effect:Destroy() end)
    end
end

-- === Custom Console ===
function Malice.Log(message, level)
    level = level or "Info"
    local entry = {Level = level, Message = tostring(message), Time = os.time()}
    table.insert(consoleOutput, entry)
    print(string.format("[Malice %s] %s", level, message))
    if consoleEnabled and consoleGui then
        Malice.UpdateConsoleGui()
    end
end

function Malice.RunWithCheck(func)
    local success, result = pcall(func)
    if success then
        Malice.Log("Code executed successfully", "Success")
    else
        Malice.Log("Code failed: " .. tostring(result), "Error")
    end
    return success, result
end

function Malice.ToggleConsole(parent)
    if consoleEnabled then
        if consoleGui then consoleGui:Destroy() end
        consoleGui = nil
        consoleEnabled = false
        return
    end

    consoleEnabled = true
    consoleGui = Instance.new("ScreenGui")
    consoleGui.Parent = parent or game.Players.LocalPlayer:WaitForChild("PlayerGui")
    consoleGui.Name = "MaliceConsole"

    local frame = Malice.CreateFrame(consoleGui, UDim2.new(0.7, 0, 0.3, 0), UDim2.new(0, 10, 0, 10))
    frame.Name = "ConsoleFrame"
    frame.Draggable = true
    frame.Active = true

    local textBox = Instance.new("TextBox")
    textBox.Parent = frame
    textBox.Size = UDim2.new(1, -10, 1, -10)
    textBox.Position = UDim2.new(0, 5, 0, 5)
    textBox.BackgroundTransparency = 1
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Font = Enum.Font.Code
    textBox.TextSize = 14
    textBox.TextScaled = true
    textBox.TextWrapped = true
    textBox.TextYAlignment = Enum.TextYAlignment.Top
    textBox.Text = "Malice Console Initialized\n"
    textBox.ClearTextOnFocus = false
    textBox.MultiLine = true

    Malice.UpdateConsoleGui()
end

function Malice.UpdateConsoleGui()
    if not consoleGui or not consoleEnabled then return end
    local textBox = consoleGui.ConsoleFrame:FindFirstChild("TextBox")
    if not textBox then return end
    local text = ""
    for i = math.max(1, #consoleOutput - 20), #consoleOutput do
        local entry = consoleOutput[i]
        text = text .. string.format("[%s] %s\n", entry.Level, entry.Message)
    end
    textBox.Text = text
end

-- Initialization
Malice.Log("Malice Library Loaded with Mobile Support", "Info")

return Malice
