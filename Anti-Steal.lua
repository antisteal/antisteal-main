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
    local Character = LocalPlayer.Character
    if not Character then
        return UI.Notify:new('Warning', 'No Character.')
    end

    local Selected = Character:FindFirstChildOfClass'Tool'
    if not Selected then
        return UI.Notify:new('Warning', 'No tool to sync from found.')
    end

    local Sound; do
        repeat
            local SelectedDescendants = Selected:GetDescendants()
            for I = 1, #SelectedDescendants do
                local V = SelectedDescendants[I]
                if IsA(V, 'Sound') and V.IsLoaded and V.TimeLength > 0 and V.SoundId:match('DMakTbZ') then
                    Sound = V; break;
                end
            end
            wait(.06)
        until Sound
    end

    local CharacterDescendants = Character:GetDescendants()
    for I = 1, #CharacterDescendants do
        local V = CharacterDescendants[I]
        if IsA(V, 'Sound') then
            V.TimePosition = Time or (math.round(Sound.TimePosition) - .5)
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

            wait(2)

            Sync()
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

    local RCF = Root.CFrame

    local GrabTool = function(Tool)
        Tool.Handle.Anchored = false

        if type(firetouchinterest) ~= 'function' then
            coroutine.wrap(function()
                for I = 1, 5 do
                    Tool.Handle.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            end)()
        end

        pcall(firetouchinterest, Root, Tool.Handle, 0)
    end

    for IDX = 1, Amount do
        if not Duping then
            break
        end

        local CCF = CFrame.new(NextInt(Rand, -2e4, 2e4), 2e4, NextInt(Rand, -2e4, 2e4))

        wait(.2)

        Root.CFrame = CCF

        wait(.2)

        Root.Anchored = true
        
        wait(.2)

        for _, Tool in next, LocalPlayer.Backpack:GetChildren() do
            if Tool.Name:lower():match'boombox' then
                Tool.Parent = Character
                Tool.Handle.Anchored = true
                table.insert(FoundTools, Tool)
            end
        end

        wait(.2)

        for I = 1, #FoundTools do
            Root.CFrame = Root.CFrame
            FoundTools[I].Parent = workspace
        end

        wait(.2)

        Character:BreakJoints()

        Character = LocalPlayer.CharacterAdded:Wait()
        LocalPlayer.CharacterAppearanceLoaded:Wait()

        Root = WaitForChild(Character, 'HumanoidRootPart')
        Humanoid = WaitForChild(Character, 'Humanoid')
    end

    UI.Notify:new('Dupe complete.', ('Finished with %s tools. %s of them were stolen.'):format(#FoundTools, (function() 
        local StolenTools = 0
        
        for _, Tool in next, FoundTools do
            if Tool.Parent ~= workspace and Tool.Parent ~= Character and Tool.Parent ~= LocalPlayer.Backpack then
                StolenTools = StolenTools + 1
            end
        end

        if StolenTools == #FoundTools then
            return 'All'
        end

        if StolenTools == 0 then
            return 'None'
        end

        return tostring(StolenTools)
    end)()))

    for _, Tool in next, FoundTools do
        GrabTool(Tool)
    end

    Root.CFrame = RCF
end

local ASUI = UI:new({
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
                    SyncTime = tonumber(Time) or nil
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
                    UI.Notify:new('Success', 'Your selected AssetId has been set to "' .. AssetId .. '"', 5)
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
            ASUI.Enabled = not ASUI.Enabled 
        end
    end
end)
