
local Element = {}
Element.__index = Element
Element.__type = "Toggle"

function Element:New(Idx, Config)
    assert(Config.Title, "Toggle - Missing Title")

    local Toggle = {
        Value = Config.Default or false,
        Callback = Config.Callback or function(Value) end,
        Type = "Toggle",
    }

    local ToggleFrame = Components.Element(Config.Title, Config.Description, self.Container, true, Config)
    ToggleFrame.DescLabel.Size = UDim2.new(1, -54, 0, 14)

    Toggle.SetTitle = ToggleFrame.SetTitle
    Toggle.SetDesc = ToggleFrame.SetDesc
    Toggle.Visible = ToggleFrame.Visible
    Toggle.Elements = ToggleFrame

    local ToggleCircle = New("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, 2, 0.5, 0),
        Image = "http://www.roblox.com/asset/?id=12266946128",
        ImageTransparency = 0.5,
        ThemeTag = {
            ImageColor3 = "ToggleSlider",
        },
    })

    local ToggleBorder = New("UIStroke", {
        Transparency = 0.5,
        ThemeTag = {
            Color = "ToggleSlider",
        },
    })

    local ToggleSlider = New("Frame", {
        Size = UDim2.fromOffset(36, 18),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Parent = ToggleFrame.Frame,
        BackgroundTransparency = 1,
        ThemeTag = {
            BackgroundColor3 = "Accent",
        },
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 9),
        }),
        ToggleBorder,
        ToggleCircle,
    })

    local positionMotor = Flipper.SingleMotor.new(Value and 19 or 2)
    local transparencyMotor = Flipper.SingleMotor.new(Value and 0.45 or 1)
    local imageTransparencyMotor = Flipper.SingleMotor.new(Value and 0 or 0.5)
    local colorMotor = Flipper.SingleMotor.new(0)

    positionMotor:onStep(function(pos)
        ToggleCircle.Position = UDim2.new(0, pos, 0.5, 0)
    end)

    transparencyMotor:onStep(function(trans)
        ToggleSlider.BackgroundTransparency = trans
    end)

    imageTransparencyMotor:onStep(function(imgTrans)
        ToggleCircle.ImageTransparency = imgTrans
    end)

    colorMotor:onStep(function(val)
        local fromColor = Creator.GetThemeProperty("ToggleSlider")
        local toColor = Creator.GetThemeProperty("Accent")
        local borderColor = Color3.new(fromColor.R + val * (toColor.R - fromColor.R), 
                                      fromColor.G + val * (toColor.G - fromColor.G), 
                                      fromColor.B + val * (toColor.B - fromColor.B))
        ToggleBorder.Color = borderColor
        ToggleCircle.ImageColor3 = val == 1 and Creator.GetThemeProperty("ToggleToggled") or fromColor
    end)

    function Toggle:OnChanged(Func)
        Toggle.Changed = Func
        Func(Toggle.Value)
    end

    function Toggle:SetValue(Value)
        Value = not not Value
        Toggle.Value = Value

        positionMotor:setGoal(Flipper.Spring.new(Value and 19 or 2, { frequency = 6, dampingRatio = 0.9 }))
        transparencyMotor:setGoal(Flipper.Spring.new(Value and 0.45 or 1, { frequency = 6, dampingRatio = 0.9 }))
        imageTransparencyMotor:setGoal(Flipper.Spring.new(Value and 0 or 0.5, { frequency = 6, dampingRatio = 0.9 }))
        colorMotor:setGoal(Flipper.Spring.new(Value and 1 or 0, { frequency = 6, dampingRatio = 0.9 }))

        Library:SafeCallback(Toggle.Callback, Toggle.Value)
        Library:SafeCallback(Toggle.Changed, Toggle.Value)
    end

    function Toggle:Destroy()
        ToggleFrame:Destroy()
        Library.Options[Idx] = nil
    end

    Creator.AddSignal(ToggleFrame.Frame.MouseButton1Click, function()
        Toggle:SetValue(not Toggle.Value)
    end)

    Toggle:SetValue(Toggle.Value)

    Library.Options[Idx] = Toggle
    return Toggle
end

return Element
