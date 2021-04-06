local UI = loadstring(game:HttpGet('https://raw.githubusercontent.com/antisteal/antisteal-main/master/ui.lua', true))()

local Players = game:GetService'Players'
local LocalPlayer = Players.LocalPlayer

local HttpService = game:GetService'HttpService'
local IsA, WaitForChild = game.IsA, game.WaitForChild

local RunService = game:GetService'RunService'

local Rand = Random.new()
local NextInt = Rand.NextInteger

local Settings = {
    Encode = true,
    Hex = true,
    Message = 'i am cool (me: ' .. LocalPlayer.Name .. ')',
    AssetId = ''
}

local SaveSettings = function()
    writefile('AntistealSettings.json', HttpService:JSONEncode(Settings))
end

if not isfile('AntistealSettings.json') then
    SaveSettings()
end

Settings = HttpService:JSONDecode(readfile('AntistealSettings.json'))

local RemoteArg = (game.PlaceId == 455366377 or game.PlaceId == 4669040 and 'play') or 'PlaySong'

local Encode = function(AssetId)
    Settings.AssetId = AssetId
    return game:HttpPost('https://dot-mp4.dev/free/anti-steal.php', HttpService:JSONEncode(Settings))
end

local SyncTime = 0
local Sync = function(Time)
    Time = Time or 0

    local Objects = LocalPlayer.Character:GetDescendants()
    for I = 1, #Objects do
        local Object = Objects[I]
        if IsA(Object, 'Sound') then
            Object.TimePosition = Time
        end
    end
end

local MassPlay = function(AssetId)
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildOfClass('Humanoid')
        if Humanoid then
            Humanoid:UnequipTools()
            
            local EncodedId = Encode(AssetId)

            local Tools = {}; do
                for _, Tool in next, LocalPlayer.Backpack:GetChildren() do
                    if Tool.Name:lower():match('boombox') then
                        Tools[#Tools+1] = Tool
                    end
                end
            end

            local Selected = Tools[1]

            for _, Tool in next, Tools do
                Tool.Parent = Character
            end

            wait(.2)

            for _, Tool in next, Tools do
                local Remote = Tool:FindFirstChildOfClass('RemoteEvent')
                if Remote then
                    Remote:FireServer(RemoteArg, EncodedId)
                end
            end

            local Sound = nil;
            repeat
                for _, Object in next, Selected:GetDescendants() do
                    if IsA(Object, 'Sound') and Object.TimeLength > 0 then
                        Sound = Object
                        break
                    end
                end
                wait(.06)
            until Sound

            local Time = math.round(Sound.TimePosition) - .5

            Sync(Time)
        end
    end
end

local Duping, DupeAmount = false, 8

local Dupe = function(Amount)
    UI.Notify:new('Dupe', ('Amount: %s'):format(Amount))

    Duping = true

    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid = WaitForChild(Character, 'Humanoid', 10)

    if not Humanoid then
        return UI.Notify:new('Warning', 'No compatible humanoid found.')
    end

    local Root = WaitForChild(Character, 'HumanoidRootPart', 10)

    if not Root then
        return UI.Notify:new('Warning', 'No root found.')
    end

    do
        local FoundTools = {}
        Humanoid:UnequipTools()

        for _, Tool in next, LocalPlayer.Backpack:GetChildren() do
            if Tool.Name:lower():match('boombox') then
                table.insert(FoundTools, Tool)
            end
        end

        if #FoundTools < 1 then
            return UI.Notify:new('Error', 'You do not have any compatible tools to dupe.')
        end
    end

    local FoundTools = {}

    for IDX = 1, Amount do
        if not Duping then
            break
        end

        UI.Notify:new('Dupe Index', tostring(IDX) .. ' out of ' .. tostring(Amount))
        Humanoid:UnequipTools()

        for _, Tool in next, LocalPlayer.Backpack:GetChildren() do
            if Tool.Name:lower():match('boombox') then
                if not table.find(FoundTools, Tool) then
                    table.insert(FoundTools, Tool)
                    Tool.Parent = Character
                end
            end
        end

        wait(0.5)

        Root.CFrame = CFrame.new(NextInt(Rand, -2e4, 2e4), 2e4, NextInt(Rand, -2e4, 2e4))

        wait(0.2)

        Root.Anchored = true

        wait(0.2)

        for _, Tool in next, FoundTools do
            Tool.Handle.Anchored = true
            Tool.Parent = workspace
        end

        Character:BreakJoints()

        Character = LocalPlayer.CharacterAdded:Wait()
        Humanoid = WaitForChild(Character, 'Humanoid')
        Root = WaitForChild(Character, 'HumanoidRootPart')
    end

    UI.Notify:new('Dupe complete.', ('Finished with %s tools. %s of them were stolen.'):format(#FoundTools, (function() 
        local StolenTools = {}
        
        for _, Tool in next, FoundTools do
            if Tool.Parent ~= workspace and Tool.Parent ~= Character and Tool.Parent ~= LocalPlayer.Backpack then
                table.insert(StolenTools, Tool)
            end
        end

        if #StolenTools == #FoundTools then
            return 'All'
        end

        return #StolenTools
    end)()))

    for _, Tool in next, FoundTools do
        Tool.Handle.CFrame = Root.CFrame
        Tool.Handle.Anchored = false
        firetouchinterest(Root, Tool.Handle, 0)
        wait()
    end
end

local antisteal = UI:new({
    Name = 'antisteal - release v7.33',
    Tab = {
        Text = 'Main',
        Section2 = {
            SectionText = 'Other',
            MassPlayButton = {
                'Mass Play',
                function()
                    MassPlay(Settings.AssetId)
                end
            },
            DupeAmountBox = {
                'Dupe Amount [D: 8]',
                function(Amount)
                    DupeAmount = tonumber(Amount) or 8
                end
            },
            DupeButton = {
                'Dupe',
                function()
                    Dupe(DupeAmount)
                end
            },
            CDupeButton = {
                'Cancel Dupe',
                function()
                    Duping = false
                end
            },
            SyncTimeBox = {
                'Sync Time [D: 0]',
                function(Time)
                    SyncTime = tonumber(Time) or 0
                end
            },
            SyncButton = {
                'Sync',
                function()
                    Sync(SyncTime)
                end
            }
        },
        Section1 = {
            SectionText = 'Anti-Log',
            AssetBox = {
                'Set Asset Id',
                function(AssetId)
                    UI.Notify:new('antisteal', 'Your selected AssetId has been set to "' .. AssetId .. '"', 5)
                    Settings.AssetId = AssetId
                end
            },
            EncodeToggle = {
                'Encode Baits',
                Settings.Encode,
                'Encode',
                function(Bool)
                    Settings.Encode = Bool
                    SaveSettings()
                end
            },
            HexToggle = {
                'Hex',
                Settings.Hex,
                'Hex',
                function(Bool)
                    Settings.Hex = Bool
                    SaveSettings()
                end
            },
            MessageBox = {
                'Custom Message',
                function(Message)
                    Settings.Message = Message
                end
            },
            PlayButton = {
                'Play',
                function()
                    local Character = LocalPlayer.Character
                    if Character then
                        local Radio = Character:FindFirstChildOfClass'Tool' or (function() 
                            for _, Tool in next, LocalPlayer.Backpack:GetChildren() do
                                if Tool.Name:lower():match'boombox' then
                                    return Tool
                                end
                            end
                        end)()

                        if Radio then
                            Radio.Parent = Character
                            local Remote = Radio:FindFirstChildOfClass'RemoteEvent'
                            if Remote then
                                local EncodedId = Encode(Settings.AssetId)

                                if EncodedId then
                                    return Remote:FireServer(RemoteArg, EncodedId)
                                end

                                return UI.Notify:new('Failed', 'Your audio didnt encode properly.')
                            end

                            return UI.Notify:new('Failed', 'Your radio is incompatible.')
                        end

                        return UI.Notify:new('Failed', 'Your radio is incompatible or none have been found.')
                    end
                end
            }
        }
    }
})

local UserInputService = game:GetService'UserInputService'

UserInputService.InputBegan:Connect(function(InputObject)
    if not UserInputService:GetFocusedTextBox() then
        if InputObject.KeyCode == Enum.KeyCode.J then
            UI.Enabled = not UI.Enabled 
        end
    end
end)
