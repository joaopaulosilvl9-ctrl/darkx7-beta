-- -- DARK.X7 BETA - MOBILE FIX
local Library = {
    Theme = {
        ["Background"] = Color3.fromRGB(25, 25, 25),
        ["Border"] = Color3.fromRGB(45, 45, 45),
        ["Accent"] = Color3.fromRGB(242, 98, 34),
        ["Text"] = Color3.fromRGB(255, 255, 255),
        ["Inactive Text"] = Color3.fromRGB(160, 160, 160),
        ["Element"] = Color3.fromRGB(35, 35, 35),
        ["Inline"] = Color3.fromRGB(50, 50, 50)
    },
    Threads = {},
    Connections = {},
    ThemeItems = {},
    ThemeMap = {},
    Font = Enum.Font.GothamBold
}

local Config = {
    Title = "DARK.X7 BETA",
    Description = "Enter the 24h access key below to proceed",
    File = "darkx7_key.txt",
    Linkvertise = "https://linkvertise.com",
    Rinku = "https://rinku.com",
    Discord = "https://discord.gg",
    Shop = "https://shop.com"
}

local script_key = ""
local IsMobile = true

local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local MathFloor = math.floor
local MathClamp = math.clamp
local StringFormat = string.format
local TableInsert = table.insert
local Vector2New = Vector2.new
local UDim2New = UDim2.new
local UDimNew = UDim.new
local FromRGB = Color3.fromRGB

local function SafeGetUI()
    return game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local Instances = {
    Create = function(self, Class, Properties)
        local Obj = Instance.new(Class)
        for Prop, Val in pairs(Properties) do
            if Prop ~= "Parent" then Obj[Prop] = Val end
        end
        Obj.Parent = Properties.Parent
        
        local Wrapper = { Instance = Obj }
        function Wrapper:AddToTheme(Props)
            Library:AddToTheme(Obj, Props)
            return Wrapper
        end
        function Wrapper:Tween(Info, Props)
            TweenService:Create(Obj, Info, Props):Play()
            return Wrapper
        end
        function Wrapper:Clean()
            Obj:Destroy()
        end
        function Wrapper:Connect(Event, Callback)
            Obj[Event]:Connect(Callback)
            return Wrapper
        end
        return Wrapper
    end
}

Library.NotifHolder = Instances:Create("ScreenGui", {
    Parent = SafeGetUI(),
    Name = "\0",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 9999
})

Library.NotifHolder.Instance.Size = UDim2New(1, 0, 1, 0)
Library.NotifLayoutOrder = 0

Instances:Create("UIListLayout", {
	Parent = Library.NotifHolder.Instance,
	Name = "\0",
	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Padding = UDimNew(0, 20)
})

Instances:Create("UIPadding", {
	Parent = Library.NotifHolder.Instance,
	Name = "\0",
	PaddingLeft = UDimNew(0, 12),
	PaddingRight = UDimNew(0, 12),
	PaddingTop = UDimNew(0, 12),
	PaddingBottom = UDimNew(0, 12)
})

Library.Thread = function(self, Function)
	local NewThread = coroutine.create(Function)
	coroutine.wrap(function() coroutine.resume(NewThread) end)()
	TableInsert(self.Threads, NewThread)
	return NewThread
end

Library.Connect = function(self, Event, Callback)
	local NewConnection = {
		Event = Event,
		Callback = Callback,
		Name = StringFormat("conn_%s", HttpService:GenerateGUID(false)),
		Connection = nil
	}
	Library.Thread(self, function()
		NewConnection.Connection = Event:Connect(Callback)
	end)
	TableInsert(self.Connections, NewConnection)
	return NewConnection
end

Library.AddToTheme = function(self, Item, Properties)
	Item = Item.Instance or Item
	local ThemeData = { Item = Item, Properties = Properties }
	for Property, Value in pairs(ThemeData.Properties) do
		if type(Value) == "string" then
			Item[Property] = self.Theme[Value] or Value
		elseif type(Value) == "function" then
			Item[Property] = Value()
		end
	end
	TableInsert(self.ThemeItems, ThemeData)
	self.ThemeMap[Item] = ThemeData
end

Library.Notification = function(self, Data)
	wait()
	Library.NotifLayoutOrder = (Library.NotifLayoutOrder or 0) + 1
	local TitleText = Data.Title or Data.Name or "DARK.X7 BETA"
	local DescText = Data.Description or ""
	local Duration = Data.Duration or 5

	local PaddingH = 6
	local PaddingV = 5
	local Gap = 5
	local BarGap = 4
	local BarH = 3
	local MaxWidth = 330

	local TitleSize = TextService:GetTextSize(TitleText, 14, Library.Font, Vector2.new(MaxWidth, 10000))
	local DescSize = TextService:GetTextSize(DescText, 12, Library.Font, Vector2.new(MaxWidth - PaddingH * 2, 10000))

	local TitleH = math.max(math.ceil(TitleSize.Y), 15)
	local DescH = math.max(math.ceil(DescSize.Y), 14)
	if DescH < 28 then DescH = 28 end

	local ContentWidth = math.min(math.max(math.max(TitleSize.X, DescSize.X) + PaddingH * 2, 100), MaxWidth)
	local SizeY = PaddingV + TitleH + Gap + DescH + BarGap + BarH + PaddingV

	local Items = {} do
		Items["Notification"] = Instances:Create("Frame", {
			Parent = Library.NotifHolder.Instance,
			Name = "\0",
			BackgroundColor3 = Library.Theme["Background"],
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = Library.NotifLayoutOrder,
			Size = UDim2New(0, ContentWidth, 0, SizeY)
		}):AddToTheme({BackgroundColor3 = 'Background'})

		Instances:Create("UICorner", { Parent = Items["Notification"].Instance, CornerRadius = UDimNew(0, 5) })

		Items["Title"] = Instances:Create("TextLabel", {
			Parent = Items["Notification"].Instance,
			Size = UDim2New(1, 0, 0, TitleH),
			BackgroundTransparency = 1,
			Text = TitleText,
			TextColor3 = Library.Theme["Text"],
			TextSize = 14,
			FontFace = Library.Font,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 1
		}):AddToTheme({TextColor3 = 'Text'})

		Items["Description"] = Instances:Create("TextLabel", {
			Parent = Items["Notification"].Instance,
			Size = UDim2New(1, -PaddingH * 2, 0, DescH),
			Position = UDim2New(0, PaddingH, 0, TitleH + Gap),
			BackgroundTransparency = 1,
			Text = DescText,
			TextColor3 = Library.Theme["Text"],
			TextSize = 12,
			FontFace = Library.Font,
			TextTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true
		}):AddToTheme({TextColor3 = 'Text'})

		Items["Duration"] = Instances:Create("Frame", {
			Parent = Items["Notification"].Instance,
			Size = UDim2New(1, 0, 0, BarH),
			Position = UDim2New(0, 0, 0, TitleH + Gap + DescH + BarGap),
			BackgroundColor3 = Library.Theme["Inline"],
			BackgroundTransparency = 1,
			BorderSizePixel = 0
		}):AddToTheme({BackgroundColor3 = 'Inline'})

		Items["Accent"] = Instances:Create("Frame", {
			Parent = Items["Duration"].Instance,
			Size = UDim2New(1, 0, 1, 0),
			BackgroundColor3 = Data.Color or Library.Theme["Accent"],
			BorderSizePixel = 0
		})
	end

	local FadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local BarInfo = TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

	Library.Thread(Library, function()
		Items["Notification"]:Tween(FadeInfo, {BackgroundTransparency = 0})
		Items["Title"]:Tween(FadeInfo, {TextTransparency = 0})
		Items["Description"]:Tween(FadeInfo, {TextTransparency = 0.4})
		Items["Duration"]:Tween(FadeInfo, {BackgroundTransparency = 0})
		Items["Accent"]:Tween(BarInfo, {Size = UDim2New(0, 0, 1, 0)})

		wait(Duration)
		Items["Notification"]:Clean()
	end)
end

local BlurEffect = Instances:Create("BlurEffect", { Name = "\0", Size = 0, Parent = Lighting })

local Items = {} do
	Items["ScreenGui"] = Instances:Create("ScreenGui", {
		Parent = SafeGetUI(),
		Name = "\0",
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = 999,
		ResetOnSpawn = false,
		IgnoreGuiInset = true
	})

	Items["Overlay"] = Instances:Create("Frame", {
		Parent = Items["ScreenGui"].Instance,
		Size = UDim2New(1, 0, 1, 0),
		BackgroundColor3 = FromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 1
	})

	Items["MainFrame"] = Instances:Create("Frame", {
		Parent = Items["ScreenGui"].Instance,
		Size = UDim2New(0, 0, 0, 0),
		Position = UDim2New(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2New(0.5, 0.5),
		BackgroundColor3 = Library.Theme["Background"],
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		ZIndex = 2
	}):AddToTheme({BackgroundColor3 = 'Background'})

	Instances:Create("UICorner", { Parent = Items["MainFrame"].Instance, CornerRadius = UDimNew(0, 8) })

	Items["MainStroke"] = Instances:Create("UIStroke", {
		Parent = Items["MainFrame"].Instance,
		Color = Library.Theme["Border"],
		Thickness = 1,
		Transparency = 1
	}):AddToTheme({Color = 'Border'})

	Items["TitleLabel"] = Instances:Create("TextLabel", {
		Parent = Items["MainFrame"].Instance,
		Size = UDim2New(1, 0, 0, 40),
		Position = UDim2New(0, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = "DARK.X7 BETA",
		TextColor3 = Library.Theme["Accent"],
		TextSize = 24,
		FontFace = Library.Font,
		TextTransparency = 1,
		ZIndex = 2
	}):AddToTheme({TextColor3 = 'Accent'})

	Items["SubtitleLabel"] = Instances:Create("TextLabel", {
		Parent = Items["MainFrame"].Instance,
		Size = UDim2New(1, 0, 0, 20),
		Position = UDim2New(0, 0, 0, 65),
		BackgroundTransparency = 1,
		Text = Config.Description,
		TextColor3 = Library.Theme["Inactive Text"],
		TextSize = 12,
		FontFace = Library.Font,
		TextTransparency = 1,
		ZIndex = 2
	}):AddToTheme({TextColor3 = 'Inactive Text'})

	Items["Line"] = Instances:Create("Frame", {
		Parent = Items["MainFrame"].Instance,
		Size = UDim2New(0.84, 0, 0, 1),
		Position = UDim2New(0.08, 0, 0, 95),
		BackgroundColor3 = Library.Theme["Border"],
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2
	}):AddToTheme({BackgroundColor3 = 'Border'})

	Items["TextBoxContainer"] = Instances:Create("Frame", {
		Parent = Items["MainFrame"].Instance,
		Size = UDim2New(0, 340, 0, 45),
		Position = UDim2New(0.5, 0, 0, 115),
		AnchorPoint = Vector2New(0.5, 0),
		BackgroundColor3 = Library.Theme["Element"],
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2
	}):AddToTheme({BackgroundColor3 = 'Element'})

	Instances:Create("UICorner", { Parent = Items["TextBoxContainer"].Instance, CornerRadius = UDimNew(0, 5) })

	Items["TextBoxStroke"] = Instances:Create("UIStroke", {
		Parent = Items["TextBoxContainer"].Instance,
		Color = Library.Theme["Border"],
		Thickness = 1,
		Transparency = 1
	}):AddToTheme({Color = 'Border'})

	Items["KeyTextBox"] = Instances:Create("TextBox", {
		Parent = Items["TextBoxContainer"].Instance,
		Size = UDim2New(1, -24, 1, 0),
		Position = UDim2New(0, 12, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Text = "",
		TextColor3 = Library.Theme["Text"],
		TextSize = 14,
		FontFace = Library.Font,
		PlaceholderText = "Paste your key here...",
		PlaceholderColor3 = Library.Theme["Inactive Text"],
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTransparency = 1,
		ClearTextOnFocus = false
	}):AddToTheme({TextColor3 = 'Text', PlaceholderColor3 = 'Inactive Text'})

	Items["CloseButton"] = Instances:Create("TextButton", {
		Parent = Items["MainFrame"].Instance,
		Size = UDim2New(0, 30, 0, 30),
		Position = UDim2New(1, -40, 0, 10),
		BackgroundColor3 = Library.Theme["Element"],
		BackgroundTransparency = 1,
		Text = "X",
		TextColor3 = Library.Theme["Text"],
		TextSize = 16,
		FontFace = Library.Font,
		TextTransparency = 1,
		ZIndex = 2
	}):AddToTheme({BackgroundColor3 = 'Element', TextColor3 = 'Text'})

	Instances:Create("UICorner", { Parent = Items["CloseButton"].Instance, CornerRadius = UDimNew(0, 5) })
end

local Buttons = {}
local function CreateButton(Text, Position)
	local Button = Instances:Create("TextButton", {
		Parent = Items["MainFrame"].Instance,
		Size = UDim2New(0, 320, 0, 42),
		Position = Position,
		AnchorPoint = Vector2New(0.5, 0),
		BackgroundColor3 = Library.Theme["Element"],
		BackgroundTransparency = 1,
		Text = Text,
		TextColor3 = Library.Theme["Text"],
		TextSize = 13,
		FontFace = Library.Font,
		TextTransparency = 1,
		ZIndex = 2
	}):AddToTheme({BackgroundColor3 = 'Element', TextColor3 = 'Text'})

	Instances:Create("UICorner", { Parent = Button.Instance, CornerRadius = UDimNew(0, 5) })

	local bStroke = Instances:Create("UIStroke", {
		Parent = Button.Instance,
		Color = Library.Theme["Border"],
		Thickness = 1,
		Transparency = 1
	}):AddToTheme({Color = 'Border'})

	TableInsert(Buttons, {Button = Button, Stroke = bStroke})
	return Button
end

Items["Button1"] = CreateButton("Get Key (Linkvertise)", UDim2New(0.5, 0, 0, 180))
Items["Button2"] = CreateButton("Get Key (Rinku)", UDim2New(0.5, 0, 0, 230))
Items["Button3"] = CreateButton("Join Discord", UDim2New(0.5, 0, 0, 280))
Items["Button4"] = CreateButton("Buy Standard Key", UDim2New(0.5, 0, 0, 330))

local TweenData = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function CloseUI()
	BlurEffect:Tween(TweenData, {Size = 0})
	Items["Overlay"]:Tween(TweenData, {BackgroundTransparency = 1})
	Items["MainFrame"]:Tween(TweenData, {Size = UDim2New(0, 0, 0, 0)})
	wait(0.35)
	Items["ScreenGui"]:Clean()
end

local function ValidateKey(Key)
	local CleanedKey = Key:gsub("%s", "")
	if CleanedKey == "123" then
		Library:Notification({ Title = "DARK.X7 BETA", Description = "Key Approved! Access granted.", Color = Color3.fromRGB(0, 255, 100), Duration = 5 })
		wait(1.5)
		CloseUI()
		print("DARK.X7 Carregado com sucesso!")
		return true
	end
	Library:Notification({ Title = "DARK.X7 BETA", Description = "Incorrect Key!", Color = Color3.fromRGB(255, 50, 50), Duration = 5 })
	return false
end

Items["Button1"]:Connect("MouseButton1Click", function()
	if setclipboard then setclipboard(Config.Linkvertise) end
	Library:Notification({Title = "DARK.X7 BETA", Description = "Linkvertise copied", Duration = 3})
end)

Items["Button2"]:Connect("MouseButton1Click", function()
	if setclipboard then setclipboard(Config.Rinku) end
	Library:Notification({Title = "DARK.X7 BETA", Description = "Rinku copied", Duration = 3})
end)

Items["Button3"]:Connect("MouseButton1Click", function()
	if setclipboard then setclipboard(Config.Discord) end
	Library:Notification({Title = "DARK.X7 BETA", Description = "Discord copied", Duration = 3})
end)

Items["Button4"]:Connect("MouseButton1Click", function()
	if setclipboard then setclipboard(Config.Shop) end
	Library:Notification({Title = "DARK.X7 BETA", Description = "Shop copied", Duration = 3})
end)

Items["KeyTextBox"]:Connect("FocusLost", function(EnterPressed)
	if Items["KeyTextBox"].Instance.Text == "" then return end
	if not ValidateKey(Items["KeyTextBox"].Instance.Text) then
		Items["KeyTextBox"].Instance.Text = ""
	end
end)

Items["CloseButton"]:Connect("MouseButton1Click", function() CloseUI() end)

local TweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

BlurEffect:Tween(TweenData, {Size = 12})
Items["Overlay"]:Tween(TweenData, {BackgroundTransparency = 0.4})
Items["MainFrame"]:Tween(TweenData, {Size = UDim2New(0, 360, 0, 400)})

wait(0.3)

Items["TitleLabel"]:Tween(TweenInfo2, {TextTransparency = 0})
Items["SubtitleLabel"]:Tween(TweenInfo2, {TextTransparency = 0})
Items["Line"]:Tween(TweenInfo2, {BackgroundTransparency = 0})
Items["TextBoxContainer"]:Tween(TweenInfo2, {BackgroundTransparency = 0})
Items["TextBoxStroke"]:Tween(TweenInfo2, {Transparency = 0})
Items["KeyTextBox"]:Tween(TweenInfo2, {TextTransparency = 0})
Items["CloseButton"]:Tween(TweenInfo2, {BackgroundTransparency = 0, TextTransparency = 0})
Items["MainStroke"]:Tween(TweenInfo2, {Transparency = 0})

for _, bData in pairs(Buttons) do
	bData.Button:Tween(TweenInfo2, {BackgroundTransparency = 0, TextTransparency = 0})
	bData.Stroke:Tween(TweenInfo2, {Transparency = 0})
end BETA - COMPLETO COM SISTEMA DE KEY
local Library = {
    Theme = {
        ["Background"] = Color3.fromRGB(25, 25, 25),
        ["Border"] = Color3.fromRGB(45, 45, 45),
        ["Accent"] = Color3.fromRGB(242, 98, 34), -- Tema Tanjiro (Laranja/Sombra)
        ["Text"] = Color3.fromRGB(255, 255, 255),
        ["Inactive Text"] = Color3.fromRGB(160, 160, 160),
        ["Element"] = Color3.fromRGB(35, 35, 35),
        ["Inline"] = Color3.fromRGB(50, 50, 50)
    },
    Threads = {},
    Connections = {},
    ThemeItems = {},
    ThemeMap = {},
    Font = Enum.Font.GothamBold
}

local Config = {
    Title = "DARK.X7 BETA",
    Description = "Enter the 24h access key below to proceed",
    File = "darkx7_key.txt",
    Linkvertise = "https://linkvertise.com", -- Adicione seus links se quiser
    Rinku = "https://rinku.com",
    Discord = "https://discord.gg",
    Shop = "https://shop.com"
}

local script_key = ""
local IsMobile = true

local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local MathFloor = math.floor
local MathClamp = math.clamp
local StringFormat = string.format
local TableInsert = table.insert
local Vector2New = Vector2.new
local UDim2New = UDim2.new
local UDimNew = UDim.new
local FromRGB = Color3.fromRGB

local function RGBSequence(Positions)
    local Keypoints = {}
    for _, kp in pairs(Positions) do
        table.insert(Keypoints, ColorSequenceKeypoint.new(kp[1] or kp.Time, kp[2] or kp.Value))
    end
    return ColorSequence.new(Keypoints)
end

local function RGBSequenceKeypoint(Time, Color)
    return {Time = Time, Value = Color}
end

local function SafeGetUI()
    return game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local Instances = {
    Create = function(self, Class, Properties)
        local Obj = Instance.new(Class)
        for Prop, Val in pairs(Properties) do
            if Prop ~= "Parent" then Obj[Prop] = Val end
        }
        Obj.Parent = Properties.Parent
        
        local Wrapper = { Instance = Obj }
        function Wrapper:AddToTheme(Props)
            Library:AddToTheme(Obj, Props)
            return Wrapper
        end
        function Wrapper:Tween(Info, Props)
            TweenService:Create(Obj, Info, Props):Play()
            return Wrapper
        end
        function Wrapper:Clean()
            Obj:Destroy()
        end
        function Wrapper:Connect(Event, Callback)
            Obj[Event]:Connect(Callback)
            return Wrapper
        end
        return Wrapper
    end
}

Library.NotifHolder = Instances:Create("ScreenGui", {
    Parent = SafeGetUI(),
    Name = "\0",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 9999
})

Library.NotifHolder.Instance.Size = UDim2New(1, 0, 1, 0)

Library.NotifLayoutOrder = 0

Instances:Create("UIListLayout", {
	Parent = Library.NotifHolder.Instance,
	Name = "\0",
	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Padding = UDimNew(0, 20)
})

Instances:Create("UIPadding", {
	Parent = Library.NotifHolder.Instance,
	Name = "\0",
	PaddingLeft = UDimNew(0, 12),
	PaddingRight = UDimNew(0, 12),
	PaddingTop = UDimNew(0, 12),
	PaddingBottom = UDimNew(0, 12)
})

Library.Thread = function(self, Function)
	local NewThread = coroutine.create(Function)

	coroutine.wrap(function()
		coroutine.resume(NewThread)
	end)()

	TableInsert(self.Threads, NewThread)

	return NewThread
end

Library.Connect = function(self, Event, Callback)
	local NewConnection = {
		Event = Event,
		Callback = Callback,
		Name = StringFormat("conn_%s", HttpService:GenerateGUID(false)),
		Connection = nil
	}

	Library.Thread(self, function()
		NewConnection.Connection = Event:Connect(Callback)
	end)

	TableInsert(self.Connections, NewConnection)
	return NewConnection
end

Library.AddToTheme = function(self, Item, Properties)
	Item = Item.Instance or Item

	local ThemeData = {
		Item = Item,
		Properties = Properties,
	}

	for Property, Value in pairs(ThemeData.Properties) do
		if type(Value) == "string" then
			Item[Property] = self.Theme[Value] or Value
		elseif type(Value) == "function" then
			Item[Property] = Value()
		end
	end

	TableInsert(self.ThemeItems, ThemeData)

	self.ThemeMap[Item] = ThemeData
end

local function ToTime(a)
	if not a then
		return "No Key"
	elseif a < 0 then
		return "Lifetime"
	end

	local days = MathFloor(a / 86400)
	local hours = MathFloor((a % 86400) / 3600)
	local minutes = MathFloor((a % 3600) / 60)
	local seconds = a % 60

	if days > 0 then
		return StringFormat("%dd %dh %dm %ds", days, hours, minutes, seconds)
	elseif hours > 0 then
		return StringFormat("%dh %dm %ds", hours, minutes, seconds)
	elseif minutes > 0 then
		return StringFormat("%dm %ds", minutes, seconds)
	else
		return StringFormat("%ds", seconds)
	end
end

Library.Notification = function(self, Data)
	wait()
	Library.NotifLayoutOrder = (Library.NotifLayoutOrder or 0) + 1

	local TitleText = Data.Title or Data.Name or "DARK.X7 BETA"
	local DescText = Data.Description or ""
	local Duration = Data.Duration or 5

	local PaddingH = 6
	local PaddingV = 5
	local Gap = 5
	local BarGap = 4
	local BarH = 3
	local MaxWidth = 330

	local function GetTextSizeInternal(Text, FontSize, Width)
		local Font = Library.Font
		if typeof(Font) ~= "EnumItem" or Font.EnumType ~= Enum.Font then
			Font = Enum.Font.Gotham
		end
		if Width <= 0 then Width = 10000 end
		return TextService:GetTextSize(Text, FontSize, Font, Vector2.new(Width, 10000))
	end

	local TitleSize = GetTextSizeInternal(TitleText, 14, MaxWidth)
	local DescAvailableWidth = MaxWidth - PaddingH * 2
	local DescSize = DescText ~= "" and GetTextSizeInternal(DescText, 12, DescAvailableWidth) or Vector2.new(DescAvailableWidth, 28)

	local TitleH = math.max(math.ceil(math.max(TitleSize.Y, 1)), 15)
	local DescH = math.max(math.ceil(math.max(DescSize.Y, 1)), 14)

	if DescH < 28 then DescH = 28 end

	local ContentWidth = math.max(math.ceil(math.max(TitleSize.X, 1)), math.ceil(math.max(DescSize.X, 1)), 100)
	ContentWidth = math.min(math.max(ContentWidth + PaddingH * 2, 100), MaxWidth)

	local SizeY = PaddingV + TitleH + Gap + DescH + BarGap + BarH + PaddingV

	local Items = {} do
		Items["Notification"] = Instances:Create("Frame", {
			Parent = Library.NotifHolder.Instance,
			Name = "\0",
			BackgroundColor3 = Library.Theme["Background"],
			BackgroundTransparency = 1,
			BorderColor3 = FromRGB(0, 0, 0),
			BorderSizePixel = 0,
			LayoutOrder = Library.NotifLayoutOrder,
			Size = UDim2New(0, ContentWidth, 0, SizeY)
		}):AddToTheme({BackgroundColor3 = 'Background'})

		Instances:Create("UICorner", {
			Parent = Items["Notification"].Instance,
			Name = "\0",
			CornerRadius = UDimNew(0, 5)
		})

		Instances:Create("UIPadding", {
			Parent = Items["Notification"].Instance,
			Name = "\0",
			PaddingLeft = UDimNew(0, PaddingH),
			PaddingRight = UDimNew(0, PaddingH),
			PaddingTop = UDimNew(0, PaddingV),
			PaddingBottom = UDimNew(0, PaddingV)
		})

		Items["Title"] = Instances:Create("TextLabel", {
			Parent = Items["Notification"].Instance,
			Name = "\0",
			Size = UDim2New(1, 0, 0, TitleH),
			BackgroundTransparency = 1,
			BorderColor3 = FromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Text = TitleText,
			TextColor3 = Library.Theme["Text"],
			TextSize = 14,
			FontFace = Library.Font,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			TextTransparency = 1
		}):AddToTheme({TextColor3 = 'Text'})

		Items["Description"] = Instances:Create("TextLabel", {
			Parent = Items["Notification"].Instance,
			Name = "\0",
			Size = UDim2New(1, -PaddingH * 2, 0, DescH),
			Position = UDim2New(0, PaddingH, 0, TitleH + Gap),
			BackgroundTransparency = 1,
			BorderColor3 = FromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Text = DescText,
			TextColor3 = Library.Theme["Text"],
			TextSize = 12,
			FontFace = Library.Font,
			TextTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.None,
			RichText = false,
			TextScaled = false,
			AutomaticSize = Enum.AutomaticSize.Y
		}):AddToTheme({TextColor3 = 'Text'})

		Instances:Create("UITextSizeConstraint", {
			Parent = Items["Description"].Instance,
			Name = "\0",
			MinTextSize = 12,
			MaxTextSize = 12
		})

		Items["Duration"] = Instances:Create("Frame", {
			Parent = Items["Notification"].Instance,
			Name = "\0",
			Size = UDim2New(1, 0, 0, BarH),
			Position = UDim2New(0, 0, 0, TitleH + Gap + DescH + BarGap),
			BackgroundColor3 = Library.Theme["Inline"],
			BackgroundTransparency = 1,
			BorderColor3 = FromRGB(0, 0, 0),
			BorderSizePixel = 0
		}):AddToTheme({BackgroundColor3 = 'Inline'})

		Instances:Create("UICorner", {
			Parent = Items["Duration"].Instance,
			Name = "\0",
			CornerRadius = UDimNew(0, 5)
		})

		Items["Accent"] = Instances:Create("Frame", {
			Parent = Items["Duration"].Instance,
			Name = "\0",
			Size = UDim2New(1, 0, 1, 0),
			BackgroundColor3 = Data.Color or Library.Theme["Accent"],
			BorderColor3 = FromRGB(0, 0, 0),
			BorderSizePixel = 0
		})

		Instances:Create("UICorner", {
			Parent = Items["Accent"].Instance,
			Name = "\0",
			CornerRadius = UDimNew(0, 5)
		})
	end

	local FadeInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0)
	local BarInfo = TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

	local Frames = { Items["Notification"], Items["Duration"] }
	local TextLabels = { Items["Title"] }
	local DescLabel = Items["Description"]

	Library.Thread(Library, function()
		for _, Item in pairs(Frames) do
			Item:Tween(FadeInfo, {BackgroundTransparency = 0})
		end

		for _, Item in pairs(TextLabels) do
			Item:Tween(FadeInfo, {TextTransparency = 0})
		end

		DescLabel:Tween(FadeInfo, {TextTransparency = 0.4})

		Items["Notification"]:Tween(FadeInfo, {Size = UDim2New(0, ContentWidth, 0, SizeY)})
		Items["Accent"]:Tween(BarInfo, {Size = UDim2New(0, 0, 1, 0)})

		delay(Duration + 0.1, function()
			for _, Item in pairs(Frames) do
				Item:Tween(FadeInfo, {BackgroundTransparency = 1})
			end

			for _, Item in pairs(TextLabels) do
				Item:Tween(FadeInfo, {TextTransparency = 1})
			end

			DescLabel:Tween(FadeInfo, {TextTransparency = 1})

			Items["Notification"]:Tween(FadeInfo, {Size = UDim2New(0, 0, 0, SizeY)})
			wait(0.5)
			Items["Notification"]:Clean()
		end)
	end)
end

local BlurEffect = Instances:Create("BlurEffect", {
	Name = "\0",
	Size = 0,
	Parent = Lighting
})

local Items = { } do
	Items["ScreenGui"] = Instances:Create("ScreenGui", {
		Parent = SafeGetUI(),
		Name = "\0",
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = 999,
		ResetOnSpawn = false,
		IgnoreGuiInset = true
	})

	Items["Overlay"] = Instances:Create("Frame", {
		Parent = Items["ScreenGui"].Instance,
		Name = "\0",
		Size = UDim2New(1, 0, 1, 0),
		BackgroundColor3 = FromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 1
	})

	Items["MainFrame"] = Instances:Create("Frame", {
		Parent = Items["ScreenGui"].Instance,
		Name = "\0",
		Size = UDim2New(0, 0, 0, 0),
		Position = UDim2New(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2New(0.5, 0.5),
		BackgroundColor3 = Library.Theme["Background"],
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		ZIndex = 2
	}):AddToTheme({BackgroundColor3 = 'Background'})

	Instances:Create("UICorner", {
		Parent = Items["MainFrame"].Instance,
		Name = "\0",
		CornerRadius = UDimNew(0, 8)
	})

	Items["MainStroke"] = Instances:Create("UIStroke", {
		Parent = Items["MainFrame"].Instance,
		Name = "\0",
		Color = Library.Theme["Border"],
		Thickness = 1,
		Transparency = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}):AddToTheme({Color = 'Border'})

	Items["TitleLabel"] = Instances:Create("TextLabel", {
		Parent = Items["MainFrame"].Instance,
		Name = "\0",
		Size = UDim2New(1, 0, 0, 40),
		Position = UDim2New(0, 0, 0, 20),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "DARK.X7 BETA",
		TextColor3 = Library.Theme["Accent"],
		TextSize = 28,
		FontFace = Library.Font,
		TextTransparency = 1,
		ZIndex = 2
	}):AddToTheme({TextColor3 = 'Accent'})

	Items["SubtitleLabel"] = Instances:Create("TextLabel", {
		Parent = Items["MainFrame"].Instance,
		Name = "\0",
		Size = UDim2New(1, 0, 0, 20),
		Position = UDim2New(0, 0, 0, 65),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = Config.Description,
		TextColor3 = Library.Theme["Inactive Text"],
		TextSize = 13,
		FontFace = Library.Font,
		TextTransparency = 1,
		ZIndex = 2
	}):AddToTheme({TextColor3 = 'Inactive Text'})

	Items["Line"] = Instances:Create("Frame", {
		Parent = Items["MainFrame"].Instance,
		Name = "\0",
		Size = UDim2New(0.84, 0, 0, 1),
		Position = UDim2New(0.08, 0, 0, 95),
		BackgroundColor3 = Library.Theme["Border"],
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2
	}):AddToTheme({BackgroundColor3 = 'Border'})

	Items["TextBoxContainer"] = Instances:Create("Frame", {
		Parent = Items["MainFrame"].Instance,
		Name = "\0",
		Size = UDim2New(0, 480, 0, 50),
		Position = UDim2New(0.5, 0, 0, 115),
		AnchorPoint = Vector2New(0.5, 0),
		BackgroundColor3 = Library.Theme["Element"],
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2
	}):AddToTheme({BackgroundColor3 = 'Element'})

	Instances:Create("UICorner", {
		Parent = Items["TextBoxContainer"].Instance,
		Name = "\0",
		CornerRadius = UDimNew(0, 5)
	})

	Instances:Create("UIGradient", {
		Parent = Items["TextBoxContainer"].Instance,
		Name = "\0",
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, FromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, FromRGB(216, 216, 216))
		})
	})

	Items["TextBoxStroke"] = Instances:Create("UIStroke", {
		Parent = Items["TextBoxContainer"].Instance,
		Name = "\0",
		Color = Library.Theme["Border"],
		Thickness = 1,
		Transparency = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}):AddToTheme({Color = 'Border'})

	Items["KeyTextBox"] = Instances:Create("TextBox", {
		Parent = Items["TextBoxContainer"].Instance,
		Name = "\0",
		Size = UDim2New(1, -24, 1, 0),
		Position = UDim2New(0, 12, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2,
		Text = "",
		TextColor3 = Library.Theme["Text"],
		TextSize = 15,
		FontFace = Library.Font,
		PlaceholderText = "Paste your key here...",
		PlaceholderColor3 = Library.Theme["Inactive Text"],
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTransparency = 1,
		ClearTextOnFocus = false
	}):AddToTheme({TextColor3 = 'Text', PlaceholderColor3 = 'Inactive Text'})

	Items["CloseButton"] = Instances:Create("TextButton", {
		Parent = Items["MainFrame"].Instance,
		Name = "\0",
		Size = UDim2New(0, 30, 0, 30),
		Position = UDim2New(1, -40, 0, 10),
		BackgroundColor3 = Library.Theme["Element"],
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "X",
		TextColor3 = Library.Theme["Text"],
		TextSize = 18,
		FontFace = Library.Font,
		AutoButtonColor = false,
		TextTransparency = 1,
		ZIndex = 2
	}):AddToTheme({BackgroundColor3 = 'Element', TextColor3 = 'Text'})

	Instances:Create("UICorner", {
		Parent = Items["CloseButton"].Instance,
		Name = "\0",
		CornerRadius = UDimNew(0, 5)
	})

	Items["CloseStroke"] = Instances:Create("UIStroke", {
		Parent = Items["CloseButton"].Instance,
		Name = "\0",
		Color = Library.Theme["Border"],
		Thickness = 1,
		Transparency = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}):AddToTheme({Color = 'Border'})
end

local Buttons = { }

local function CreateButton(Text, Position)
	local Button = Instances:Create("TextButton", {
		Parent = Items["MainFrame"].Instance,
		Name = "\0",
		Size = UDim2New(0, 220, 0, 45),
		Position = Position,
		AnchorPoint = Vector2New(0.5, 0),
		BackgroundColor3 = Library.Theme["Element"],
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = Text,
		TextColor3 = Library.Theme["Text"],
		TextSize = IsMobile and 13 or 15,
		FontFace = Library.Font,
		AutoButtonColor = false,
		TextTransparency = 1,
		ZIndex = 2
	}):AddToTheme({BackgroundColor3 = 'Element', TextColor3 = 'Text'})

	Instances:Create("UICorner", {
		Parent = Button.Instance,
		Name = "\0",
		CornerRadius = UDimNew(0, 5)
	})

	Instances:Create("UIGradient", {
		Parent = Button.Instance,
		Name = "\0",
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, FromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, FromRGB(216, 216, 216))
		})
	})

	local bStroke = Instances:Create("UIStroke", {
		Parent = Button.Instance,
		Name = "\0",
		Color = Library.Theme["Border"],
		Thickness = 1,
		Transparency = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}):AddToTheme({Color = 'Border'})

	TableInsert(Buttons, {Button = Button, Stroke = bStroke})
	return Button
end

if IsMobile then
	Items["Button1"] = CreateButton("Get Key (Linkvertise)", UDim2New(0.5, 0, 0, 185))
	Items["Button2"] = CreateButton("Get Key (Rinku)", UDim2New(0.5, 0, 0, 240))
	Items["Button3"] = CreateButton("Join Discord", UDim2New(0.5, 0, 0, 295))
	Items["Button4"] = CreateButton("Buy Standard Key", UDim2New(0.5, 0, 0, 350))

	for _, bData do
		bData.Button.Instance.Size = UDim2New(0, 320, 0, 42)
	end
else
	Items["Button1"] = CreateButton("Get Key (Linkvertise)", UDim2New(0.25, 0, 0, 190))
	Items["Button2"] = CreateButton("Get Key (Rinku)", UDim2New(0.75, 0, 0, 190))
	Items["Button3"] = CreateButton("Join Discord", UDim2New(0.25, 0, 0, 255))
	Items["Button4"] = CreateButton("Buy Standard Key", UDim2New(0.75, 0, 0, 255))
end

local TweenData = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function CloseUI()
	BlurEffect:Tween(TweenData, {Size = 0})
	Items["Overlay"]:Tween(TweenData, {BackgroundTransparency = 1})

	Items["TitleLabel"]:Tween(TweenData, {TextTransparency = 1})
	Items["SubtitleLabel"]:Tween(TweenData, {TextTransparency = 1})
	Items["Line"]:Tween(TweenData, {BackgroundTransparency = 1})
	Items["TextBoxContainer"]:Tween(TweenData, {BackgroundTransparency = 1})
	Items["TextBoxStroke"]:Tween(TweenData, {Transparency = 1})
	Items["KeyTextBox"]:Tween(TweenData, {TextTransparency = 1})
	Items["CloseButton"]:Tween(TweenData, {BackgroundTransparency = 1, TextTransparency = 1})
	Items["CloseStroke"]:Tween(TweenData, {Transparency = 1})
	Items["MainStroke"]:Tween(TweenData, {Transparency = 1})

	for _, bData in pairs(Buttons) do
		bData.Button:Tween(TweenData, {BackgroundTransparency = 1, TextTransparency = 1})
		bData.Stroke:Tween(TweenData, {Transparency = 1})
	end

	Items["MainFrame"]:Tween(TweenData, {Size = UDim2New(0, 0, 0, 0)})
	wait(0.35)
	BlurEffect:Clean()
	Items["ScreenGui"]:Clean()
end

local function ValidateKey(Key)
	local CleanedKey = Key:gsub("%s", "")

	if CleanedKey == "123" then
		script_key = CleanedKey

		if not isfile(Config.File) then
			pcall(writefile, Config.File, CleanedKey)
		elseif readfile(Config.File) ~= CleanedKey then
			pcall(writefile, Config.File, CleanedKey)
		end

		getgenv().key = CleanedKey
		getgenv().key_expire = os.time() + 86400
		getgenv().key_note = "Custom Key"
		getgenv().key_executions = 1

		Library:Notification({
			Title = "DARK.X7 BETA",
			Description = "Key Approved! Access granted.",
			Color = Color3.fromRGB(0, 255, 100),
			Duration = 5
		})

		wait(1.5)
		CloseUI()

		-- AQUÍ EXECUTA SEU SCRIPT PRINCIPAL DEPOIS QUE ENTRA A SENHA
		print("DARK.X7 Carregado com sucesso!")
		return true
	end

	Library:Notification({
		Title = "DARK.X7 BETA",
		Description = "Incorrect Key! Please use the correct key.",
		Color = Color3.fromRGB(255, 50, 50),
		Duration = 5
	})
	return false
end

for _, bData in pairs(Buttons) do
	bData.Button:Connect("MouseEnter", function()
		bData.Button:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = IsMobile and UDim2New(0, 330, 0, 45) or UDim2New(0, 230, 0, 48)})
	end)
	bData.Button:Connect("MouseLeave", function()
		bData.Button:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = IsMobile and UDim2New(0, 320, 0, 42) or UDim2New(0, 220, 0, 45)})
	end)
	bData.Button:Connect("MouseButton1Down", function()
		bData.Button:Tween(TweenInfo.new(0.08), {Size = IsMobile and UDim2New(0, 310, 0, 40) or UDim2New(0, 210, 0, 42)})
	end)
	bData.Button:Connect("MouseButton1Up", function()
		bData.Button:Tween(TweenInfo.new(0.08), {Size = IsMobile and UDim2New(0, 320, 0, 42) or UDim2New(0, 220, 0, 45)})
	end)
end

Items["Button1"]:Connect("MouseButton1Click", function()
	if setclipboard then setclipboard(Config.Linkvertise) end
	Library:Notification({Title = "DARK.X7 BETA", Description = "Linkvertise link copied", Color = Color3.fromRGB(242, 98, 34), Duration = 5})
end)

Items["Button2"]:Connect("MouseButton1Click", function()
	if setclipboard then setclipboard(Config.Rinku) end
	Library:Notification({Title = "DARK.X7 BETA", Description = "Rinku link copied", Color = Color3.fromRGB(242, 98, 34), Duration = 5})
end)

Items["Button3"]:Connect("MouseButton1Click", function()
	if setclipboard then setclipboard(Config.Discord) end
	Library:Notification({Title = "DARK.X7 BETA", Description = "Discord invite copied", Color = Color3.fromRGB(242, 98, 34), Duration = 5})
end)

Items["Button4"]:Connect("MouseButton1Click", function()
	if setclipboard then setclipboard(Config.Shop) end
	Library:Notification({Title = "DARK.X7 BETA", Description = "Shop link copied", Color = Color3.fromRGB(242, 98, 34), Duration = 5})
end)

Items["KeyTextBox"]:Connect("FocusLost", function()
	if Items["KeyTextBox"].Instance.Text == "" then return end
	if not ValidateKey(Items["KeyTextBox"].Instance.Text) then
		Items["KeyTextBox"].Instance.Text = ""
	end
end)

Items["CloseButton"]:Connect("MouseButton1Click", function() CloseUI() end)

Items["MainFrame"]:MakeDraggable()

local UIScale = Instance.new("UIScale")
UIScale.Scale = 1
UIScale.Parent = Items["ScreenGui"].Instance

if IsMobile then
	Items["MainFrame"].Instance.Size = UDim2New(0, 380, 0, 440)
	Items["TitleLabel"].Instance.TextSize = 22
	Items["SubtitleLabel"].Instance.TextSize = 10
	Items["TextBoxContainer"].Instance.Size = UDim2New(0, 340, 0, 45)
    local Camera = Workspace.CurrentCamera
    local Viewport = (Camera and Camera.ViewportSize) or Vector2.new(1920, 1080)
    UIScale.Scale = MathClamp(Viewport.Y / 500, 0.5, 1.5)
end

local FinalSize = IsMobile and UDim2New(0, 380, 0, 440) or UDim2New(0, 580, 0, 340)
local TweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

BlurEffect:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 24})
Items["Overlay"]:Tween(TweenInfo.new(0.3), {BackgroundTransparency = 0.3})
Items["MainFrame"]:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = FinalSize})

wait(0.3)

Items["TitleLabel"]:Tween(TweenInfo2, {TextTransparency = 0})
Items["SubtitleLabel"]:Tween(TweenInfo2, {TextTransparency = 0})
Items["Line"]:Tween(TweenInfo2, {BackgroundTransparency = 0})
Items["TextBoxContainer"]:Tween(TweenInfo2, {BackgroundTransparency = 0})
Items["TextBoxStroke"]:Tween(TweenInfo2, {Transparency = 0})
Items["KeyTextBox"]:Tween(TweenInfo2, {TextTransparency = 0})
Items["CloseButton"]:Tween(TweenInfo2, {BackgroundTransparency = 0, TextTransparency = 0})
Items["CloseStroke"]:Tween(TweenInfo2, {Transparency = 0})
Items["MainStroke"]:Tween(TweenInfo2, {Transparency = 0})

for _, bData in pairs(Buttons) do
	bData.Button:Tween(TweenInfo2, {BackgroundTransparency = 0, TextTransparency = 0})
	bData.Stroke:Tween(TweenInfo2, {Transparency = 0})
end

coroutine.wrap(function()
	while wait(0.3) do
		local SavedKey = (isfile(Config.File) and readfile(Config.File)) or (script_key ~= "" and script_key) or nil
		if SavedKey and ValidateKey(SavedKey) then return end
	end
end)()
		if type(Value) == "string" then
			Item[Property] = self.Theme[Value] or Value
		elseif type(Value) == "function" then
			Item[Property] = Value()
		end
	end

	TableInsert(self.ThemeItems, ThemeData)

	self.ThemeMap[Item] = ThemeData
end

local function ToTime(a)
	if not a then
		return "No Key"
	elseif a < 0 then
		return "Lifetime"
	end

	local days = MathFloor(a / 86400)
	local hours = MathFloor((a % 86400) / 3600)
	local minutes = MathFloor((a % 3600) / 60)
	local seconds = a % 60

	if days > 0 then
		return StringFormat("%dd %dh %dm %ds", days, hours, minutes, seconds)
	elseif hours > 0 then
		return StringFormat("%dh %dm %ds", hours, minutes, seconds)
	elseif minutes > 0 then
		return StringFormat("%dm %ds", minutes, seconds)
	else
		return StringFormat("%ds", seconds)
	end
end

local function GetTextSize(Text, Width)
	local Success, Result = pcall(function()
		return TextService:GetTextSize(Text, 14, Library.Font, Vector2New(Width, 10000))
	end)

	if not Success or not Result then
		Result = TextService:GetTextSize(Text, 14, Enum.Font.SourceSans, Vector2New(Width, 10000))
	end

	return Result
end

Library.Notification = function(self, Data)
	wait()
	Library.NotifLayoutOrder = (Library.NotifLayoutOrder or 0) + 1

	local TitleText = Data.Title or Data.Name or "DARK.X7 BETA"
	local DescText = Data.Description or ""
	local Duration = Data.Duration or 5

	local PaddingH = 6
	local PaddingV = 5
	local Gap = 5
	local BarGap = 4
	local BarH = 3
	local MaxWidth = 330

	local function GetTextSize(Text, FontSize, Width)
		local Font = Library.Font

		if typeof(Font) ~= "EnumItem" or Font.EnumType ~= Enum.Font then
			Font = Enum.Font.Gotham
		end

		if Width <= 0 then
			Width = 10000
		end

		return TextService:GetTextSize(Text, FontSize, Font, Vector2.new(Width, 10000))
	end

	local TitleSize = GetTextSize(TitleText, 14, MaxWidth)
	local DescAvailableWidth = MaxWidth - PaddingH * 2
	local DescSize = DescText ~= "" and GetTextSize(DescText, 12, DescAvailableWidth) or Vector2.new(DescAvailableWidth, 28)

	local TitleH = math.max(math.ceil(math.max(TitleSize.Y, 1)), 15)
	local DescH = math.max(math.ceil(math.max(DescSize.Y, 1)), 14)

	if DescH < 28 then DescH = 28 end

	local ContentWidth = math.max(math.ceil(math.max(TitleSize.X, 1)), math.ceil(math.max(DescSize.X, 1)), 100)
	ContentWidth = math.min(math.max(ContentWidth + PaddingH * 2, 100), MaxWidth)

	local SizeY = PaddingV + TitleH + Gap + DescH + BarGap + BarH + PaddingV

	local Items = {} do
		Items["Notification"] = Instances:Create("Frame", {
			Parent = Library.NotifHolder.Instance,
			Name = "\0",
			BackgroundColor3 = Library.Theme["Background"],
			BackgroundTransparency = 1,
			BorderColor3 = FromRGB(0, 0, 0),
			BorderSizePixel = 0,
			LayoutOrder = Library.NotifLayoutOrder,
			Size = UDim2New(0, ContentWidth, 0, SizeY)
		}):AddToTheme({BackgroundColor3 = 'Background'})

		Instances:Create("UICorner", {
			Parent = Items["Notification"].Instance,
			Name = "\0",
			CornerRadius = UDimNew(0, 5)
		})

		Instances:Create("UIPadding", {
			Parent = Items["Notification"].Instance,
			Name = "\0",
			PaddingLeft = UDimNew(0, PaddingH),
			PaddingRight = UDimNew(0, PaddingH),
			PaddingTop = UDimNew(0, PaddingV),
			PaddingBottom = UDimNew(0, PaddingV)
		})

		Items["Title"] = Instances:Create("TextLabel", {
			Parent = Items["Notification"].Instance,
			Name = "\0",
			Size = UDim2New(1, 0, 0, TitleH),
			BackgroundTransparency = 1,
			BorderColor3 = FromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Text = TitleText,
			TextColor3 = Library.Theme["Text"],
			TextSize = 14,
			FontFace = Library.Font,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			TextTransparency = 1
		}):AddToTheme({TextColor3 = 'Text'})

		Items["Description"] = Instances:Create("TextLabel", {
			Parent = Items["Notification"].Instance,
			Name = "\0",
			Size = UDim2New(1, -PaddingH * 2, 0, DescH),
			Position = UDim2New(0, PaddingH, 0, TitleH + Gap),
			BackgroundTransparency = 1,
			BorderColor3 = FromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Text = DescText,
			TextColor3 = Library.Theme["Text"],
			TextSize = 12,
			FontFace = Library.Font,
			TextTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.None,
			RichText = false,
			TextScaled = false,
			AutomaticSize = Enum.AutomaticSize.Y
		}):AddToTheme({TextColor3 = 'Text'})

		Instances:Create("UITextSizeConstraint", {
			Parent = Items["Description"].Instance,
			Name = "\0",
			MinTextSize = 12,
			MaxTextSize = 12
		})

		Items["Duration"] = Instances:Create("Frame", {
			Parent = Items["Notification"].Instance,
			Name = "\0",
			Size = UDim2New(1, 0, 0, BarH),
			Position = UDim2New(0, 0, 0, TitleH + Gap + DescH + BarGap),
			BackgroundColor3 = Library.Theme["Inline"],
			BackgroundTransparency = 1,
			BorderColor3 = FromRGB(0, 0, 0),
			BorderSizePixel = 0
		}):AddToTheme({BackgroundColor3 = 'Inline'})

		Instances:Create("UICorner", {
			Parent = Items["Duration"].Instance,
			Name = "\0",
			CornerRadius = UDimNew(0, 5)
		})

		Items["Accent"] = Instances:Create("Frame", {
			Parent = Items["Duration"].Instance,
			Name = "\0",
			Size = UDim2New(1, 0, 1, 0),
			BackgroundColor3 = Data.Color,
			BorderColor3 = FromRGB(0, 0, 0),
			BorderSizePixel = 0
		})

		Instances:Create("UICorner", {
			Parent = Items["Accent"].Instance,
			Name = "\0",
			CornerRadius = UDimNew(0, 5)
		})
	end

	local FadeInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0)
	local BarInfo = TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

	local Frames = { Items["Notification"], Items["Duration"] }
	local TextLabels = { Items["Title"] }
	local DescLabel = Items["Description"]

	Library:Thread(function()
		for _, Item in Frames do
			Item:Tween(FadeInfo, {BackgroundTransparency = 0})
		end

		for _, Item in TextLabels do
			Item:Tween(FadeInfo, {TextTransparency = 0})
		end

		DescLabel:Tween(FadeInfo, {TextTransparency = 0.4})

		Items["Notification"]:Tween(FadeInfo, {Size = UDim2New(0, ContentWidth, 0, SizeY)})
		Items["Accent"]:Tween(BarInfo, {Size = UDim2New(0, 0, 1, 0)})

		delay(Duration + 0.1, function()
			for _, Item in Frames do
				Item:Tween(FadeInfo, {BackgroundTransparency = 1})
			end

			for _, Item in TextLabels do
				Item:Tween(FadeInfo, {TextTransparency = 1})
			end

			DescLabel:Tween(FadeInfo, {TextTransparency = 1})

			Items["Notification"]:Tween(FadeInfo, {Size = UDim2New(0, 0, 0, SizeY)})
			wait(0.5)
			Items["Notification"]:Clean()
		end)
	end)
end

local BlurEffect = Instances:Create("BlurEffect", {
	Name = "\0",
	Size = 0,
	Parent = Lighting
})

local Items = { } do
	Items["ScreenGui"] = Instances:Create("ScreenGui", {
		Parent = SafeGetUI(),
		Name = "\0",
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = 999,
		ResetOnSpawn = false,
		IgnoreGuiInset = true
	})

	Items["Overlay"] = Instances:Create("Frame", {
		Parent = Items["ScreenGui"].Instance,
		Name = "\0",
		Size = UDim2New(1, 0, 1, 0),
		BackgroundColor3 = FromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 1
	})

	Items["MainFrame"] = Instances:Create("Frame", {
		Parent = Items["ScreenGui"].Instance,
		Name = "\0",
		Size = UDim2New(0, 0, 0, 0),
		Position = UDim2New(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2New(0.5, 0.5),
		BackgroundColor3 = Library.Theme["Background"],
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		ZIndex = 2
	}):AddToTheme({BackgroundColor3 = 'Background'})

	Instances:Create("UICorner", {
		Parent = Items["MainFrame"].Instance,
		Name = "\0",
		CornerRadius = UDimNew(0, 8)
	})

	Items["MainStroke"] = Instances:Create("UIStroke", {
		Parent = Items["MainFrame"].Instance,
		Name = "\0",
		Color = Library.Theme["Border"],
		Thickness = 1,
		Transparency = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}):AddToTheme({Color = 'Border'})

	Items["TitleLabel"] = Instances:Create("TextLabel", {
		Parent = Items["MainFrame"].Instance,
		Name = "\0",
		Size = UDim2New(1, 0, 0, 40),
		Position = UDim2New(0, 0, 0, 20),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "DARK.X7 BETA",
		TextColor3 = Library.Theme["Accent"],
		TextSize = 28,
		FontFace = Library.Font,
		TextTransparency = 1,
		ZIndex = 2
	}):AddToTheme({TextColor3 = 'Accent'})

	Items["SubtitleLabel"] = Instances:Create("TextLabel", {
		Parent = Items["MainFrame"].Instance,
		Name = "\0",
		Size = UDim2New(1, 0, 0, 20),
		Position = UDim2New(0, 0, 0, 65),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = Config.Description,
		TextColor3 = Library.Theme["Inactive Text"],
		TextSize = 13,
		FontFace = Library.Font,
		TextTransparency = 1,
		ZIndex = 2
	}):AddToTheme({TextColor3 = 'Inactive Text'})

	Items["Line"] = Instances:Create("Frame", {
		Parent = Items["MainFrame"].Instance,
		Name = "\0",
		Size = UDim2New(0.84, 0, 0, 1),
		Position = UDim2New(0.08, 0, 0, 95),
		BackgroundColor3 = Library.Theme["Border"],
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2
	}):AddToTheme({BackgroundColor3 = 'Border'})

	Items["TextBoxContainer"] = Instances:Create("Frame", {
		Parent = Items["MainFrame"].Instance,
		Name = "\0",
		Size = UDim2New(0, 480, 0, 50),
		Position = UDim2New(0.5, 0, 0, 115),
		AnchorPoint = Vector2New(0.5, 0),
		BackgroundColor3 = Library.Theme["Element"],
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2
	}):AddToTheme({BackgroundColor3 = 'Element'})

	Instances:Create("UICorner", {
		Parent = Items["TextBoxContainer"].Instance,
		Name = "\0",
		CornerRadius = UDimNew(0, 5)
	})

	Instances:Create("UIGradient", {
		Parent = Items["TextBoxContainer"].Instance,
		Name = "\0",
		Rotation = 90,
		Color = RGBSequence({
			RGBSequenceKeypoint(0, FromRGB(255, 255, 255)),
			RGBSequenceKeypoint(1, FromRGB(216, 216, 216))
		})
	})

	Items["TextBoxStroke"] = Instances:Create("UIStroke", {
		Parent = Items["TextBoxContainer"].Instance,
		Name = "\0",
		Color = Library.Theme["Border"],
		Thickness = 1,
		Transparency = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}):AddToTheme({Color = 'Border'})

	Items["KeyTextBox"] = Instances:Create("TextBox", {
		Parent = Items["TextBoxContainer"].Instance,
		Name = "\0",
		Size = UDim2New(1, -24, 1, 0),
		Position = UDim2New(0, 12, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2,
		Text = "",
		TextColor3 = Library.Theme["Text"],
		TextSize = 15,
		FontFace = Library.Font,
		PlaceholderText = "Paste your key here...",
		PlaceholderColor3 = Library.Theme["Inactive Text"],
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTransparency = 1,
		CursorPosition = -1,
		ClearTextOnFocus = false
	}):AddToTheme({TextColor3 = 'Text', PlaceholderColor3 = 'Inactive Text'})

	Items["CloseButton"] = Instances:Create("TextButton", {
		Parent = Items["MainFrame"].Instance,
		Name = "\0",
		Size = UDim2New(0, 30, 0, 30),
		Position = UDim2New(1, -40, 0, 10),
		BackgroundColor3 = Library.Theme["Element"],
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "X",
		TextColor3 = Library.Theme["Text"],
		TextSize = 18,
		FontFace = Library.Font,
		AutoButtonColor = false,
		TextTransparency = 1,
		ZIndex = 2
	}):AddToTheme({BackgroundColor3 = 'Element', TextColor3 = 'Text'})

	Instances:Create("UICorner", {
		Parent = Items["CloseButton"].Instance,
		Name = "\0",
		CornerRadius = UDimNew(0, 5)
	})

	Items["CloseStroke"] = Instances:Create("UIStroke", {
		Parent = Items["CloseButton"].Instance,
		Name = "\0",
		Color = Library.Theme["Border"],
		Thickness = 1,
		Transparency = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}):AddToTheme({Color = 'Border'})
end

local Buttons = { }

local function CreateButton(Text, Position)
	local Button = Instances:Create("TextButton", {
		Parent = Items["MainFrame"].Instance,
		Name = "\0",
		Size = UDim2New(0, 220, 0, 45),
		Position = Position,
		AnchorPoint = Vector2New(0.5, 0),
		BackgroundColor3 = Library.Theme["Element"],
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = Text,
		TextColor3 = Library.Theme["Text"],
		TextSize = IsMobile and 13 or 15,
		FontFace = Library.Font,
		AutoButtonColor = false,
		TextTransparency = 1,
		ZIndex = 2
	}):AddToTheme({BackgroundColor3 = 'Element', TextColor3 = 'Text'})

	Instances:Create("UICorner", {
		Parent = Button.Instance,
		Name = "\0",
		CornerRadius = UDimNew(0, 5)
	})

	Instances:Create("UIGradient", {
		Parent = Button.Instance,
		Name = "\0",
		Rotation = 90,
		Color = RGBSequence({
			RGBSequenceKeypoint(0, FromRGB(255, 255, 255)),
			RGBSequenceKeypoint(1, FromRGB(216, 216, 216))
		})
	})

	Items["ButtonStroke"] = Instances:Create("UIStroke", {
		Parent = Button.Instance,
		Name = "\0",
		Color = Library.Theme["Border"],
		Thickness = 1,
		Transparency = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}):AddToTheme({Color = 'Border'})

	TableInsert(Buttons, {Button = Button, Stroke = Items["ButtonStroke"]})
	return Button
end

if IsMobile then
	Items["Button1"] = CreateButton("Get Key (Linkvertise)", UDim2New(0.5, 0, 0, 185))
	Items["Button2"] = CreateButton("Get Key (Rinku)", UDim2New(0.5, 0, 0, 240))
	Items["Button3"] = CreateButton("Join Discord", UDim2New(0.5, 0, 0, 295))
	Items["Button4"] = CreateButton("Buy Standard Key", UDim2New(0.5, 0, 0, 350))

	for _, Button in Buttons do
		Button.Button.Instance.Size = UDim2New(0, 320, 0, 42)
	end
else
	Items["Button1"] = CreateButton("Get Key (Linkvertise)", UDim2New(0.25, 0, 0, 190))
	Items["Button2"] = CreateButton("Get Key (Rinku)", UDim2New(0.75, 0, 0, 190))
	Items["Button3"] = CreateButton("Join Discord", UDim2New(0.25, 0, 0, 255))
	Items["Button4"] = CreateButton("Buy Standard Key", UDim2New(0.75, 0, 0, 255))
end

local TweenData = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function CloseUI()
	BlurEffect:Tween(TweenData, {Size = 0})
	Items["Overlay"]:Tween(TweenData, {BackgroundTransparency = 1})

	Items["TitleLabel"]:Tween(TweenData, {TextTransparency = 1})
	Items["SubtitleLabel"]:Tween(TweenData, {TextTransparency = 1})
	Items["Line"]:Tween(TweenData, {BackgroundTransparency = 1})
	Items["TextBoxContainer"]:Tween(TweenData, {BackgroundTransparency = 1})
	Items["TextBoxStroke"]:Tween(TweenData, {Transparency = 1})
	Items["KeyTextBox"]:Tween(TweenData, {TextTransparency = 1})
	Items["CloseButton"]:Tween(TweenData, {BackgroundTransparency = 1, TextTransparency = 1})
	Items["CloseStroke"]:Tween(TweenData, {Transparency = 1})
	Items["MainStroke"]:Tween(TweenData, {Transparency = 1})

	for _, Button in Buttons do
		Button.Button:Tween(TweenData, {BackgroundTransparency = 1, TextTransparency = 1})
		Button.Stroke:Tween(TweenData, {Transparency = 1})
	end

	Items["MainFrame"]:Tween(TweenData, {Size = UDim2New(0, 0, 0, 0)})
	wait(0.35)
	BlurEffect:Clean()
	Items["ScreenGui"]:Clean()
end

local function ValidateKey(Key)
	local CleanedKey = Key:gsub("%s", "")

	-- Sistema customizado: Se a key for igual a "123"
	if CleanedKey == "123" then
		script_key = CleanedKey

		if not isfile(Config.File) then
			pcall(writefile, Config.File, CleanedKey)
		elseif readfile(Config.File) ~= CleanedKey then
			pcall(writefile, Config.File, CleanedKey)
		end

		getgenv().key = CleanedKey
		getgenv().key_expire = os.time() + 86400 -- Simula 24 horas de duração
		getgenv().key_note = "Custom Key"
		getgenv().key_executions = 1

		Library:Notification({
			Title = "DARK.X7 BETA",
			Description = "Key Approved! Access granted.",
			Color = Color3.fromRGB(0, 255, 100),
			Duration = 5
		})

		wait(1.5)
		CloseUI()

		pcall(function()
			if LuarmorApi and LuarmorApi.load_script then
				LuarmorApi.load_script()
			end
		end)

		return true
	end

	-- Se a chave estiver errada
	Library:Notification({
		Title = "DARK.X7 BETA",
		Description = "Incorrect Key! Please use the correct key.",
		Color = Color3.fromRGB(255, 50, 50),
		Duration = 5
	})
	return false
end

for _, Button in Buttons do
	Button.Button:Connect("MouseEnter", function()
		Button.Button:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = IsMobile and UDim2New(0, 330, 0, 45) or UDim2New(0, 230, 0, 48)})
	end)
	Button.Button:Connect("MouseLeave", function()
		Button.Button:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = IsMobile and UDim2New(0, 320, 0, 42) or UDim2New(0, 220, 0, 45)})
	end)
	Button.Button:Connect("MouseButton1Down", function()
		Button.Button:Tween(TweenInfo.new(0.08), {Size = IsMobile and UDim2New(0, 310, 0, 40) or UDim2New(0, 210, 0, 42)})
	end)
	Button.Button:Connect("MouseButton1Up", function()
		Button.Button:Tween(TweenInfo.new(0.08), {Size = IsMobile and UDim2New(0, 320, 0, 42) or UDim2New(0, 220, 0, 45)})
	end)
end

Items["Button1"]:Connect("MouseButton1Click", function()
	if setclipboard then
		setclipboard(Config.Linkvertise)
	end
	Library:Notification({
		Title = "DARK.X7 BETA",
		Description = "Linkvertise link copied to clipboard",
		Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)),
		Duration = 5
	})
end)

Items["Button2"]:Connect("MouseButton1Click", function()
	if setclipboard then
		setclipboard(Config.Rinku)
	end
	Library:Notification({
		Title = "DARK.X7 BETA",
		Description = "Rinku link copied to clipboard",
		Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)),
		Duration = 5
	})
end)

Items["Button3"]:Connect("MouseButton1Click", function()
	if setclipboard then
		setclipboard(Config.Discord)
	end
	Library:Notification({
		Title = "DARK.X7 BETA",
		Description = "Discord invite copied to clipboard",
		Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)),
		Duration = 5
	})
end)

Items["Button4"]:Connect("MouseButton1Click", function()
	if setclipboard then
		setclipboard(Config.Shop)
	end
	Library:Notification({
		Title = "DARK.X7 BETA",
		Description = "Standard key shop link copied",
		Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)),
		Duration = 5
	})
end)

Items["KeyTextBox"]:Connect("FocusLost", function()
	if Items["KeyTextBox"].Instance.Text == "" then
		return
	end

	if not ValidateKey(Items["KeyTextBox"].Instance.Text) then
		Items["KeyTextBox"].Instance.Text = ""
	end
end)

Items["CloseButton"]:Connect("MouseButton1Click", function()
	CloseUI()
end)

Items["CloseButton"]:Connect("MouseEnter", function()
	Items["CloseButton"]:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2New(0, 35, 0, 35)})
end)

Items["CloseButton"]:Connect("MouseLeave", function()
	Items["CloseButton"]:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2New(0, 30, 0, 30)})
end)

Items["MainFrame"]:MakeDraggable()

local UIScale = InstanceNew("UIScale")
UIScale.Scale = 1
UIScale.Parent = Items["ScreenGui"].Instance

local function GetViewportSize()
	local Camera = Workspace.CurrentCamera
	return (Camera and Camera.ViewportSize) or Vector2.new(1920, 1080)
end

local function SetMobileScale()
	local Viewport = GetViewportSize()

	if IsMobile then
		local Scale = MathClamp(Viewport.Y / 500, 0.5, 1.5)
		UIScale.Scale = Scale
	else
		UIScale.Scale = 1
	end
end

if IsMobile then
	Items["MainFrame"].Instance.Size = UDim2New(0, 380, 0, 440)
	Items["TitleLabel"].Instance.TextSize = 22
	Items["SubtitleLabel"].Instance.TextSize = 10
	Items["TextBoxContainer"].Instance.Size = UDim2New(0, 340, 0, 45)
	SetMobileScale()
