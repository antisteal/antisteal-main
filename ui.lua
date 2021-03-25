local Library = {} -- coded this while jamming shinitai chan - jack @ 10:06AM PST, 3/24/2021 (took me 3 hrs 22 seconds (i had to recode it))
Library.flags = {}

local UDim2_new, Color3_new = UDim2.new, Color3.fromRGB

function Library:Create(Class, Properties)
    Properties = Properties or {}

    local Obj = Instance.new(Class)

    for K, V in next, Properties do
        local Success, _ = pcall(function()
            local I = Obj[K]
        end)

        if Success then
            Obj[K] = V;
        end
    end

    return Obj
end

local Colors = {
    Main = Color3_new(30, 30, 30),
    MainBorder = Color3_new(20, 20, 20),
    Mid = Color3_new(25, 25, 25),
    Border = Color3_new(40, 40, 40)
}

local AddSection = function(UI, Parameters)
    local Holder = UI.Background.Holder.Sections
        
    local Section = Library:Create('Frame', {
        Name = 'Section',
        BackgroundColor3 = Colors.MainBorder,
        BorderColor3 = Colors.Border,
        Parent = Holder
    }); Library:Create('ScrollingFrame', {
        Parent = Section,
        Name = 'Main',
        BorderSizePixel = 0,
        BackgroundColor3 = Colors.MainBorder,
        Position = UDim2_new(0, 0, 0.06, 0),
        Size = UDim2_new(1, 0, 0.94, 0),
        ClipsDescendants = true,
        BottomImage = 'http://www.roblox.com/asset/?id=58757773',
        MidImage = 'http://www.roblox.com/asset/?id=58757773',
        TopImage = 'http://www.roblox.com/asset/?id=58757773',
        ScrollBarImageColor3 = Color3_new(117, 117, 117),
        ScrollBarThickness = 5
    }); Library:Create('UIListLayout', {
        Parent = Section.Main,
        SortOrder = Enum.SortOrder.LayoutOrder
    }); Library:Create('TextLabel', {
        Parent = Section,
        Name = 'Text',
        TextSize = 14,
        TextColor3 = Color3_new(255, 255, 255),
        Font = Enum.Font.Code,
        BackgroundColor3 = Colors.MainBorder,
        BorderSizePixel = 0,
        Position = UDim2_new(0.075, 0, -0.03, 0),
        Size = UDim2_new(0, (8 * Parameters.SectionText:len()), 0, 15),
        Text = Parameters.SectionText
    })

    for Type, Info in next, Parameters do
        if Type:match('Toggle') then
            local Toggle = Library:Create('Frame', {
                Parent = Section.Main,
                Name = Type,
                Size = UDim2_new(1, 0, 0.069, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
            }); Library:Create('TextButton', {
                Parent = Toggle,
                Name = 'Button',
                BackgroundColor3 = (Info[2] and Color3_new(255, 255, 255)) or Colors.Mid,
                BorderColor3 = Colors.Border,
                BorderSizePixel = 1,
                Size = UDim2_new(0.12, 0, 0.8, 0),
                Position = UDim2_new(0.04, 0, 0.1, 0),
                Text = '',
                TextSize = 14
            }); Library:Create('UIGradient', {
                Parent = Toggle.Button,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3_new(202, 202, 202)),
                    ColorSequenceKeypoint.new(1, Color3_new(230, 230, 230))
                }),
                Rotation = 90,
                Enabled = Info[2]
            }); Library:Create('TextLabel', {
                Parent = Toggle,
                Name = 'Label',
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2_new(0.2, 0, 0.1, 0),
                Size = UDim2_new(0.7, 0, 0.8, 0),
                Text = Info[1] or 'Toggle',
                Font = Enum.Font.Code,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3_new(255, 255, 255)
            })
            
            local Flag = Info[3]
            Library.flags[Flag] = Info[2]
            
            Toggle.Button.MouseButton1Click:Connect(function()
                Library.flags[Flag] = not Library.flags[Flag]
                local Bool = Library.flags[Flag]
                
                Toggle.Button.UIGradient.Enabled = Bool
                if not Bool then
                    Toggle.Button.BackgroundColor3 = Colors.Mid
                else
                    Toggle.Button.BackgroundColor3 = Color3_new(255, 255, 255)
                end

                Info[4](Bool)
            end)
        elseif Type:match('Box') then
            local Box = Library:Create('Frame', {
                Parent = Section.Main,
                Name = Type,
                Size = UDim2_new(1, 0, 0.069, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
            }); Library:Create('TextBox', {
                Parent = Box,
                Position = UDim2_new(0.04, 0, 0.1, 0),
                Size = UDim2_new(0.9, 0, 0.8, 0),
                BackgroundColor3 = Colors.Mid,
                BorderColor3 = Colors.Border,
                Font = Enum.Font.Code,
                PlaceholderText = ' ' .. Info[1],
                Text = '',
                TextWrapped = true,
                TextSize = 14,
                TextColor3 = Color3_new(255, 255, 255),
            })
            
            Box.TextBox.FocusLost:Connect(function(Enter)
                -- if Enter then
                    Info[2](Box.TextBox.Text)
                -- end
            end)
        elseif Type:match('Button') then
            local Button = Library:Create('Frame', {
                Name = Type,
                Size = UDim2_new(1, 0, 0.069, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Section.Main
            }); Library:Create('TextButton', {
                Parent = Button,
                BackgroundColor3 = Colors.Mid,
                BorderColor3 = Colors.Border,
                Position = UDim2_new(0.04, 0, 0.1, 0),
                Size = UDim2_new(0.9, 0, 0.8, 0),
                Font = Enum.Font.Code,
                Text = Info[1],
                TextSize = 14,
                TextColor3 = Color3_new(255, 255, 255)
            })
            
            Button.TextButton.MouseButton1Click:Connect(Info[2])
        end
    end

    return Section
end

function Library:new(Parameters)
    Parameters = Parameters or {
        Name = 'dot_mp4 wuz here :D',
        Tab = {
            Text = 'stuffz',
            Section1 = {
                SectionText = 'sec',
                Toggle = {
                    'zup',
                    true,
                    'flag1',
                    function(bool)
                        print('zup toggle set to: ', bool)
                    end
                },
                Box = {
                    'print text',
                    function(str)
                        print(str)
                    end
                },
                Button = {
                    'balls',
                    function()
                        local Player = game:GetService'Players'.LocalPlayer
                        if Player.Character then
                            Player.Character:ClearAllChildren()
                        end
                    end
                }
            }
        }
    }

    local UI = self:Create('ScreenGui', {
        Name = 'UI',
        Parent = game:GetService'CoreGui'
    })
    local Background = self:Create('Frame', {
        Name = 'Background',
        Size = UDim2_new(0, 385, 0, 263),
        Position = UDim2_new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Colors.Main,
        BorderColor3 = Colors.MainBorder,
        BorderSizePixel = 2,
        Active = true,
        Selectable = true,
        Draggable = true,
        Parent = UI
    })

    local Topbar = self:Create('Frame', {
        Parent = Background,
        Name = 'Topbar',
        BackgroundColor3 = Color3_new(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2_new(0, 0, 0, 0),
        Size = UDim2_new(0, 385, 0, 25)
    }); self:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Colors.MainBorder),
            ColorSequenceKeypoint.new(0.356, Colors.MainBorder),
            ColorSequenceKeypoint.new(1, Colors.Main)
        }),
        Rotation = 90,
        Parent = Topbar
    }); self:Create('TextLabel', {
        Parent = Topbar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2_new(0, 200, 0, 25),
        Position = UDim2_new(0.018, 0, 0, 0),
        Font = Enum.Font.Code,
        Text = Parameters.Name,
        TextColor3 = Color3_new(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local Detail = self:Create('Frame', {
        Parent = Background,
        Name = 'Detail',
        Position = UDim2_new(1, -318, 0, 37),
        Size = UDim2_new(0, 293, 0, 15),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3_new(255, 255, 255),
    }); self:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Colors.MainBorder),
            ColorSequenceKeypoint.new(0.541, Colors.Mid),
            ColorSequenceKeypoint.new(1, Colors.Main)
        }),
        Rotation = -90,
        Parent = Detail
    })

    local Holder = self:Create('Frame', {
        Parent = Background,
        Name = 'Holder',
        BackgroundColor3 = Colors.MainBorder,
        BorderColor3 = Colors.Border,
        BorderSizePixel = 1,
        Size = UDim2_new(0, 371, 0, 205),
        Position = UDim2_new(0, 7, 1, -212)
    }); self:Create('Frame', {
        Parent = Holder,
        Name = 'Sections',
        Size = UDim2_new(0, 353, 0, 186),
        Position = UDim2_new(0.024, 0, 0.049, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = Colors.Mid
    }); self:Create('UIGridLayout', {
        Parent = Holder.Sections,
        CellSize = UDim2_new(0.493, 0, 1, 0)
    }); self:Create('TextButton', {
        Parent = Background,
        Name = 'Exit',
        Size = UDim2_new(0, 24, 0, 24),
        Position = UDim2_new(0.92, 0, 0.106, 0),
        BorderSizePixel = 1,
        BorderColor3 = Colors.Border,
        BackgroundColor3 = Colors.MainBorder,
        Text = 'X',
        TextColor3 = Color3_new(255, 255, 255),
        TextSize = 8
    }); self:Create('TextLabel', {
        Parent = Background,
        Name = 'Label',
        Size = UDim2_new(0, 60, 0, 22),
        Position = UDim2_new(0, 7, 0, 30),
        TextColor3 = Color3_new(255, 255, 255),
        BorderSizePixel = 1,
        BorderColor3 = Colors.Border,
        BackgroundColor3 = Colors.MainBorder,
        Text = Parameters.Tab.Text or 'Main',
        Font = Enum.Font.Code,
        TextSize = 14
    })

    self:Create('Frame', {
        Name = 'Connector',
        Parent = Background.Exit,
        BackgroundColor3 = Colors.MainBorder,
        BorderSizePixel = 0,
        ZIndex = 2,
        Size = UDim2_new(1.1, 0, 0.2, 0),
        Position = UDim2_new(-0.1, 0, 0.97, 0)
    }); self:Create('Frame', {
        Name = 'Connector',
        Parent = Background.Label,
        BackgroundColor3 = Colors.MainBorder,
        BorderSizePixel = 0,
        ZIndex = 2,
        Size = UDim2_new(1.1, 0, 0.2, 0),
        Position = UDim2_new(0, 0, 0.97, 0)
    })

    UI.Background.Exit.MouseButton1Click:Connect(function()
        UI:Destroy()
    end)

    local Sections = {}; do
        for Index, Info in next, Parameters.Tab do
            if Index:lower():match'section' and #Sections < 2 then
                Sections[#Sections+1] = Info
            end
        end
    end

    for _, Info in next, Sections do
        AddSection(UI, Info)
    end

    return UI
end

return Library
