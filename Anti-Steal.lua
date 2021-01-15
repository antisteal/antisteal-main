local UI = game:GetObjects('rbxassetid://0&assetVersionId=0X001C1BC5A8F')[1]; UI.Parent = game:GetService'CoreGui'

local Main, Holder, Sidebar = UI.Main, UI.Main.Holder, UI.Main.Sidebar
Main.Selectable = true
Main.Active = true
Main.Draggable = true

local SideHolder = Sidebar.Holder

local Play, AssetBox, TimeBox = SideHolder.Play, SideHolder.ID, SideHolder.TimePos

local SaveFile, LoadFile, MessageBox = Holder['Save File'], Holder['Load File'], Holder.MessageFrame['Message Box']
local ReplayHolder = Holder.ReplayHolder
local Replays = {}
local SelectionExample = Instance.new'TextButton'
SelectionExample.Size = UDim2.new(1, 0, 0.009, 1)
SelectionExample.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
SelectionExample.TextWrapped = true
SelectionExample.BorderSizePixel = 0

local Debounce = false -- riptide literally forced me to add this (his specifically) (https://gyazo.com/6548c2808ff5975c2cdfc258e72b5b29)

local Tween = function(Obj,Time,Style,Direction,Table)
    game:GetService('TweenService'):Create(Obj,TweenInfo.new(Time,Enum.EasingStyle[Style],Enum.EasingDirection[Direction],0,false,0),Table):Play()
end

local Connections = {}

local Draggable = function(Frame)
	local DToggle, DInput, DStart, SPos
	local Upd = function(Input)
		if Debounce then
			Delta = Input['Position'] - DStart; Prime = UDim2.new(SPos['X'].Scale, SPos['X'].Offset + Delta['X'], SPos['Y'].Scale, SPos['Y'].Offset + Delta['Y'])
			Tween(Frame,.06,'Sine','Out',{Position = Prime})
		end
	end
	Connections[#Connections+1] = Frame['InputBegan']:Connect(function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
			DToggle = true
			DStart = Input.Position
			SPos = Frame.Position
			Connections[#Connections+1] = Input['Changed']:Connect(function()
				if (Input.UserInputState == Enum.UserInputState.End) then
					DToggle = false
				end
			end)
		end
	end)
	Connections[#Connections+1] = Frame['InputChanged']:Connect(function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			DInput = Input
		end
	end)
	Connections[#Connections+1] = game:GetService('UserInputService').InputChanged:Connect(function(Input)
		if (Input == DInput and DToggle) then
			Upd(Input)
		end
	end)
end

Draggable(Main)

local Player = game:GetService'Players'.LocalPlayer
local ReplicatedStorage = game:GetService'ReplicatedStorage'
local HttpService = game:GetService'HttpService'
local UserInputService = game:GetService'UserInputService'
local FindFirstChild, FindFirstClass = game.FindFirstChild, game.FindFirstChildOfClass

local Cache = {}

local LoadMessageFromFile, SaveMessageToFile = function()
    return ((pcall(readfile, 'AntistealCustomMessage.txt') and readfile'AntistealCustomMessage.txt') or ''):gsub('[%c%p]',function(C) return HttpService:UrlEncode(C) end)
end, function(Message)
    return writefile('AntistealCustomMessage.txt', Message)
end

local CustomMessage = LoadMessageFromFile()

SaveFile.MouseButton1Click:Connect(function()
    SaveMessageToFile(MessageBox.Text)
end)

LoadFile.MouseButton1Click:Connect(function()
    MessageBox.Text = LoadMessageFromFile()
end)

MessageBox.FocusLost:Connect(function()
    CustomMessage = MessageBox.Text
end)

local function Encrypt(AssetId)
    local s, Encrypted = pcall(game.HttpGet, game, ('http://whoisjack.000webhostapp.com/antisteal/anti-steal.php?assetId=' .. AssetId))
    CustomMessage = LoadMessageFromFile()
    if s then
        Encrypted = Encrypted:gsub('    ', ' ' .. CustomMessage:gsub('%%', '%%%%') .. ' ')
        return Encrypted
    end
    return s
end

local function SetTimePosition(Time)
    for _, Sound in next, Player.Character:GetDescendants() do
        if Sound:IsA'Sound' then
            Sound.TimePosition = Time
        end
    end
end

local Notify = function(Title, Text)
    game:GetService'StarterGui':SetCore('SendNotification', {
        Title = Title,
        Text = Text,
        Duration = 4
    })
end

Play.MouseButton1Click:Connect(function()
    local AssetId = AssetBox.Text
    if AssetId and AssetId ~= '' then
        local EncryptedId, IsCache = ((Cache[AssetId]) or (Encrypt(AssetId:gsub('.', {
            [' '] = '',
            ['\n'] = '',
            ['\r'] = '',
            ['\t'] = ''
        })))), ((Cache[AssetId] and true) or false)
        if EncryptedId then
            if not IsCache then 
                Cache[AssetId] = EncryptedId
            end
            local RemoteArg, BoomboxRemote = (FindFirstChild(ReplicatedStorage, 'MainEvent') and 'Boombox') or ((((game.PlaceId == 455366377 or game.PlaceId == 4669040) and 'play') or 'PlaySong')), (FindFirstChild(ReplicatedStorage, 'MainEvent') or ((FindFirstClass(Player.Character, 'Tool') and FindFirstClass(FindFirstClass(Player.Character, 'Tool'), 'RemoteEvent')) or (function()
                for _, Tool in next, Player.Backpack:GetChildren() do
                    if Tool.Name:lower():find('boombox') or Tool.Name:lower():find('radio') then
                        Tool.Parent = Player.Character
                        return FindFirstClass(Tool, 'RemoteEvent')
                    end
                end
            end)()))
            if not BoomboxRemote then
                return Notify('Error', 'Incompatible boombox.')
            end
            if RemoteArg == 'Boombox' then
                if not FindFirstChild(Player.Character, '[Boombox]') then
                    if FindFirstChild(Player.Backpack, '[Boombox]') then
                        Player.Backpack['[Boombox]'].Parent = Player.Character
                    end
                end
            end
            local Success, Error = pcall(function()
                BoomboxRemote:FireServer(RemoteArg, EncryptedId)
            end)
            if not Success then
                return print(Error), Notify('Error', 'Bad arguments (Most likely incompatible boombox).')
            end
            coroutine.resume(coroutine.create(function()
                wait(0.6)
                SetTimePosition(TimeBox.Text)
            end))
            return (function()
                Notify('Success', 'Successfully played ' .. AssetId .. '.')
                local NewReplay = SelectionExample:Clone()
                table.insert(Replays, NewReplay)
                NewReplay.Text = AssetId
                NewReplay.Parent = ReplayHolder
                if #Replays % 2 == 0 then
                    NewReplay.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
                end
                NewReplay.MouseButton1Click:Connect(function()
                    local RemoteArg, BoomboxRemote = (FindFirstChild(ReplicatedStorage, 'MainEvent') and 'Boombox') or ((((game.PlaceId == 455366377 or game.PlaceId == 4669040) and 'play') or 'PlaySong')), (FindFirstChild(ReplicatedStorage, 'MainEvent') or ((FindFirstClass(Player.Character, 'Tool') and FindFirstClass(FindFirstClass(Player.Character, 'Tool'), 'RemoteEvent')) or (function()
                        for _, Tool in next, Player.Backpack:GetChildren() do
                            if Tool.Name:lower():find('boombox') or Tool.Name:lower():find('radio') then
                                Tool.Parent = Player.Character
                                return FindFirstClass(Tool, 'RemoteEvent')
                            end
                        end
                    end)())) -- just incase the tool needs to be grabbed again
                    if not BoomboxRemote then
                        return Notify('Error', 'Incompatible boombox.')
                    end
                    if RemoteArg == 'Boombox' then
                        if not FindFirstChild(Player.Character, '[Boombox]') then
                            if FindFirstChild(Player.Backpack, '[Boombox]') then
                                Player.Backpack['[Boombox]'].Parent = Player.Character
                            end
                        end
                    end
                    local Success, Error = pcall(function()
                        BoomboxRemote:FireServer(RemoteArg, EncryptedId)
                    end)
                    if not Success then
                        return print(Error), Notify('Error', 'Bad arguments (Most likely incompatible boombox).')
                    end
                    coroutine.resume(coroutine.create(function()
                        wait(0.6)
                        SetTimePosition(TimeBox.Text)
                    end))
                    return Notify('Success', 'Succesfully replayed ' .. AssetId .. '.')
                end)
            end)()
        end
        return Notify('Error', 'Bad asset.')
    end
end)

UserInputService.InputBegan:Connect(function(InputObject)
    if not (UserInputService:GetFocusedTextBox()) then
        if InputObject.KeyCode == Enum.KeyCode.J then
            UI.Enabled = not UI.Enabled
        end
    end
end)
