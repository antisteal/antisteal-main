local UI = loadstring(game:HttpGet('https://raw.githubusercontent.com/antisteal/antisteal-main/master/ui.lua', true))()

local Players = game:GetService'Players'
local LocalPlayer = Players.LocalPlayer

local HttpService = game:GetService'HttpService'

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

local Sync = function(Time)
    for _, Object in next, LocalPlayer.Character:GetDescendants() do
        if Object:IsA'Sound' then
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
                    if Object:IsA'Sound' and Object.TimeLength > 0 then
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

local Duping = false
local Dupe = function()
    Duping = not Duping

    if Duping then
        local Tools = {}

        local Character = LocalPlayer.Character
        if not Character then
            return
        end

        local Humanoid = Character:WaitForChild('Humanoid', 6)
        if not Humanoid then
            return
        end

        local Root = Character:WaitForChild('HumanoidRootPart', 6)
        if not Root then
            return
        end

        local RCF = Root.CFrame

        repeat
            Humanoid:UnequipTools()

            local FoundTools = {}; do
                for _, Tool in next, LocalPlayer.Backpack:GetChildren() do
                    if Tool.Name:lower():match'boombox' then
                        FoundTools[#FoundTools+1] = Tool
                    end
                end
            end

            Root.CFrame = CFrame.new(NextInt(Rand, -2e4, 2e4), 2e4, NextInt(Rand, -2e4, 2e4))
            
            wait(.2)

            Root.Anchored = true

            wait(.2)

            for _, Tool in next, FoundTools do
                Tool.Parent = Character
            end

            wait(.2)

            for _, Tool in next, FoundTools do
                Tool.Parent = workspace
                Tool.Handle.Anchored = true
                Tools[#Tools+1] = Tool
            end

            wait(.2)

            Character:BreakJoints()

            Character = LocalPlayer.CharacterAdded:Wait()
            Humanoid = Character:WaitForChild'Humanoid'
            Root = Character:WaitForChild'HumanoidRootPart'

            wait(.2)
        until not Duping

        if #Tools < 1 then
            return
        end

        Root.CFrame = RCF

        wait(.2)

        for _, Tool in next, Tools do
            Tool.Handle.Anchored = false
            Tool.Handle.CFrame = Root.CFrame
            wait()
        end
    end
end

return UI:new({
    Name = 'antisteal - release v7',
    Tab = {
        Text = 'Main',
        Section1 = {
            SectionText = 'Anti-Log',
            Box = {
                'Set Asset Id',
                function(AssetId)
                    Settings.AssetId = AssetId
                end
            },
            Toggle = {
                'Encode Baits',
                Settings.Encode,
                'Encode',
                function(Bool)
                    Settings.Encode = Bool
                    SaveSettings()
                end
            },
            Toggle2 = {
                'Hex',
                Settings.Hex,
                'Hex',
                function(Bool)
                    Settings.Hex = Bool
                    SaveSettings()
                end
            },
            Box2 = {
                'Custom Message',
                function(Message)
                    Settings.Message = Message
                end
            },
            Button = {
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
                                    Remote:FireServer(RemoteArg, EncodedId)
                                end
                            end
                        end
                    end
                end
            }
        },
        Section2 = {
            SectionText = 'Other',
            Toggle3 = {
                'Dupe',
                false,
                'dupe',
                Dupe
            },
            Box3 = {
                'Time Position',
                function(Time)
                    if tonumber(Time) then
                        Sync(Time)
                    end
                end
            },
            Button2 = {
                'Mass Play',
                function()
                    MassPlay(Settings.AssetId)
                end
            },
        }
    }
})
