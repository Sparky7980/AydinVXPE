--[[

  $$$$$$$\                            $$\                           $$\    $$\                              
  $$  __$$\                           $$ |                          $$ |   $$ |                             
  $$ |  $$ | $$$$$$\  $$$$$$$\   $$$$$$$ | $$$$$$\   $$$$$$\        $$ |   $$ |$$$$$$\   $$$$$$\   $$$$$$\  
  $$$$$$$  |$$  __$$\ $$  __$$\ $$  __$$ |$$  __$$\ $$  __$$\       \$$\  $$  |\____$$\ $$  __$$\ $$  __$$\ 
  $$  __$$< $$$$$$$$ |$$ |  $$ |$$ /  $$ |$$$$$$$$ |$$ |  \__|       \$$\$$  / $$$$$$$ |$$ /  $$ |$$$$$$$$ |
  $$ |  $$ |$$   ____|$$ |  $$ |$$ |  $$ |$$   ____|$$ |              \$$$  / $$  __$$ |$$ |  $$ |$$   ____|
  $$ |  $$ |\$$$$$$$\ $$ |  $$ |\$$$$$$$ |\$$$$$$$\ $$ |               \$  /  \$$$$$$$ |$$$$$$$  |\$$$$$$$\ 
  \__|  \__| \_______|\__|  \__| \_______| \_______|\__|                \_/    \_______|$$  ____/  \_______|
                                                                                      $$ |                
                                                                                      $$ |                
                                                                                      \__|   
   A very sexy and overpowered vape mod created at Render Intents  
   /Universal.lua - SystemXVoid/BlankedVoid and Maxlasertech            
   https://renderintents.xyz                                                                                                                                                                                                                                                                     
]]
   
type vapeminimodule = {
	Enabled: boolean,
	Object: Instance,
	ToggleButton: (boolean | nil, boolean | nil) -> ()
};

type kickscreenapi = {
    instance: (Frame)?,
    activate: () -> ()
};

type vapeslider = {
	Value: number,
	Object: Instance,
	SetValue: (number) -> ()
};

type vapecolorslider = {
	Hue: number,
	Sat: number,
	Value: number,
	Object: Instance,
	SetRainbow: (boolean | nil) -> (),
	SetValue: (number, number, number) -> ()
};

type rendertarget = {
    RootPart: BasePart | Part | nil,
    Player: Player | Model | nil,
    Humanoid: Humanoid | nil,
    Human: boolean | nil
};

type vapedropdown = {
	Value: string,
	Object: Instance,
	SetValue: (table) -> ()
};

type vapetextlist = {
	ObjectList: table,
	Object: Instance,
	RefreshValues: (table) -> table
};

type vapetextbox = {
	Value: string,
	Object: Instance,
	SetValue: (string) -> ()
};

type vapecustomwindow = {
	GetCustomChildren: (table) -> Frame,
	SetVisible: (boolean | nil) -> ()
};

type securetable = {
	clear: (securetable, (any, any) -> ()) -> (),
	len: (securetable) -> number,
	shutdown: (securetable) -> (),
	getplainarray: (securetable) -> table
};

type vapemodule = {
    Connections: table,
    Enabled: boolean,
    Object: Instance,
    ToggleButton: (boolean | nil, boolean | nil) -> (),
	CreateTextList: (table) -> vapetextlist,
	CreateColorSlider: (table) -> vapeslider,
	CreateToggle: (table) -> vapeminimodule,
	CreateDropdown: (table) -> vapedropdown,
	CreateSlider: (table) -> vapeslider,
	CreateTextBox: (table) -> vapetextbox,
	GetCustomChildren: (table) -> vapecustomwindow
};

type vapewindow = {
	CreateOptionsButton: (table) -> vapemodule,
	SetVisible: (boolean | nil) -> ()
};

local rendervape = shared.rendervape;
local cloneref = cloneref or function(data) return data end;
local getservice = function(service)
	return cloneref(game:FindService(service))
end;

local players: Players = getservice('Players');
local coregui: CoreGui = getservice('CoreGui');
local textService: TextService = getservice('TextService');
local lighting: Lighting = getservice('Lighting');
local textchat: TextChatService = getservice('TextChatService');
local inputservice: UserInputService = getservice('UserInputService');
local runservice: RunService = getservice('RunService');
local debris: Debris = getservice('Debris');
local replicated: ReplicatedStorage = getservice('ReplicatedStorage');
local tween: TweenService = getservice('TweenService');
local httpservice: HttpService = getservice('HttpService');
local camera: Camera = workspace.CurrentCamera;
local rootpositions = {};
local lplr = setmetatable({}, {
	__index = function(self, index)
		if index == 'LocalPosition' then 
			return rootpositions[players.LocalPlayer] or Vector3.zero;
		end	
		return players.LocalPlayer[index]
	end
});

local vapeConnections = {};
local vapeCachedAssets = {}
local vapeTargetInfo = shared.VapeTargetInfo;
local fakecam: Camera = Instance.new('Camera');
local vapeInjected = true;
local renderperformance = shared.renderperformance;


if not isfile('rendervape/libraries/utils.lua') then
	local successful, body = pcall(function()
		return game:HttpGet(`https://storage.renderintents.lol/libraries/utils.lua?ria={ria}`)
	end);
	if successful or body == 'File not Found.' then 
		return error('❌ Render Utils - Failed to download the render utils api file.')
	end;
	writefile('rendervape/libraries/utils.lua', body);
end;

local render = {
	events = setmetatable({}, {
		__index = function(self, method)
			local bind = rawget(self, method)
			if bind == nil then 
				self[method] = Instance.new('BindableEvent');
				bind = self[method]
			end
			return bind
		end
	}), 
	ping = 0, 
	platform = ({pcall(function() return inputservice:GetPlatform() end)})[2], 
	groundTime = tick(),
	updateGroundUsage = function() end, 
	UpdateTargetUI = function() end,
	sessionInfo = {labelInstances = {}}, 
	clone = {},
	utils = loadfile('rendervape/libraries/utils.lua')()
};

getgenv().render = render;
render.guardian = cheatenginetrash and bedwars ~= nil and ({pcall(function() return loadfile('rendervape/libraries/solarapoop.lua')() end)})[2];
render.utils:init();

loadfile('rendervape/libraries/performance.lua')();
loadfile('rendervape/libraries/promise.lua')();

rawset(render.utils, 'renderconnections', {});

repeat task.wait() until RenderLibrary.authenticated;

getgenv().isEnabled = function(button, category)
	local success, enabled = pcall(function()
		return rendervape.ObjectsThatCanBeSaved[button..(category or 'OptionsButton')].Api.Enabled 
	end)
	return success and enabled
end

for i,v in render.utils do
	getfenv()[i] = v;
end;

task.spawn(pcall, function()
	if replicated:WaitForChild('DefaultChatSystemChatEvents', 9e9) then 
		vapeConnections[1] = replicated.DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(data: table)
			local player : Player = players:FindFirstChild(data.FromSpeaker);
			if player then 
				render.events.message:Fire(player, data.Message)
			end
		end)
	end
end)

vapeConnections[#vapeConnections + 1] = textchat.MessageReceived:Connect(function(data)
	local success, player = pcall(players.GetPlayerByUserId, players, data.TextSource.UserId);
	if success then 
		render.events.message:Fire(player, data.Text);
	end;
end);

local lastkickedbyclient: string;
task.spawn(function()
	vapeConnections[#vapeConnections + 1] = coregui:WaitForChild('RobloxPromptGui'):WaitForChild('promptOverlay').DescendantAdded:Connect(function(v: TextLabel?)
		if v.Name == 'ErrorMessage' then
			if v.Text == 'Label' then 
				v:GetPropertyChangedSignal('Text'):Wait()
			end;
			render.events.kicked:Fire(lastkickedbyclient or v.Text, lastkickedbyclient);
		end;
	end);
end);

task.spawn(pcall, function()
	local old: (Instance, ...any) -> (...any); old = hookmetamethod(game, '__namecall', function(self: Instance, reason: string?, ...)	
		if getnamecallmethod():lower() == 'kick' and checkcaller() then 
			lastkickedbyclient = reason; 
		end;
		return old(self, reason, ...);
	end);
end);

task.spawn(function()
	repeat 
		camera = workspace.CurrentCamera or fakecam;
		task.wait()
	until (not vapeInjected)
end);

local combat = rendervape.ObjectsThatCanBeSaved.CombatWindow;
local blatant = rendervape.ObjectsThatCanBeSaved.BlatantWindow;
local visual = rendervape.ObjectsThatCanBeSaved.RenderWindow;
local utility = rendervape.ObjectsThatCanBeSaved.UtilityWindow;
local world = rendervape.ObjectsThatCanBeSaved.WorldWindow;
local exploit = rendervape.ObjectsThatCanBeSaved.ExploitWindow;
local hudwindow = rendervape.ObjectsThatCanBeSaved.TargetHUDWindow;
local guiwindow = rendervape.ObjectsThatCanBeSaved.GUIWindow;

local networkownerswitch = tick()
local isnetworkowner = function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, "NetworkOwnershipRule") end)
	if suc and res == Enum.NetworkOwnership.Manual then
		sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end

local vapeAssetTable = {["rendervape/assets/VapeCape.png"] = "rbxassetid://13380453812", ["rendervape/assets/ArrowIndicator.png"] = "rbxassetid://13350766521"}
local getcustomasset = getsynasset or getcustomasset or function(location) return vapeAssetTable[location] or "" end;
local queueonteleport = syn and syn.queue_on_teleport or queue_on_teleport or function() end;
local synapsev3 = syn and syn.toast_notification and "V3" or "";

local worldtoscreenpoint = function(pos)
	if synapsev3 == "V3" then
		local scr = worldtoscreen({pos})
		return scr[1] - Vector3.new(0, 36, 0), scr[1].Z > 0
	end
	return camera.WorldToScreenPoint(camera, pos)
end
local worldtoviewportpoint = function(pos)
	if synapsev3 == "V3" then
		local scr = worldtoscreen({pos})
		return scr[1], scr[1].Z > 0
	end
	return camera.WorldToViewportPoint(camera, pos)
end

local function vapeGithubRequest(scripturl)
	if not isfile("rendervape/"..scripturl) then
		local suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/"..readfile("rendervape/commithash.txt").."/"..scripturl, true) end)
		assert(suc, res)
		assert(res ~= "404: Not Found", res)
		if scripturl:find(".lua") then res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res end
		writefile("rendervape/"..scripturl, res)
	end
	return readfile("rendervape/"..scripturl)
end

local function downloadVapeAsset(path)
	if not isfile(path) then
		task.spawn(function()
			local textlabel = Instance.new("TextLabel")
			textlabel.Size = UDim2.new(1, 0, 0, 36)
			textlabel.Text = "Downloading "..path
			textlabel.BackgroundTransparency = 1
			textlabel.TextStrokeTransparency = 0
			textlabel.TextSize = 30
			textlabel.Font = Enum.Font.SourceSans
			textlabel.TextColor3 = Color3.new(1, 1, 1)
			textlabel.Position = UDim2.new(0, 0, 0, -36)
			textlabel.Parent = rendervape.MainGui
			repeat task.wait() until isfile(path)
			textlabel:Destroy()
		end)
		local suc, req = pcall(function() return vapeGithubRequest(path:gsub("rendervape/assets", "assets")) end)
        if suc and req then
		    writefile(path, req)
        else
            return ""
        end
	end
	if not vapeCachedAssets[path] then vapeCachedAssets[path] = getcustomasset(path) end
	return vapeCachedAssets[path]
end

local function warningNotification(title, text, delay)
	local suc, res = pcall(function()
		local frame = rendervape.CreateNotification(title, text, delay, "assets/WarningNotification.png")
		frame.Frame.Frame.ImageColor3 = Color3.fromRGB(236, 129, 44)
		return frame
	end)
	return (suc and res)
end

local function removeTags(str)
	str = str:gsub("<br%s*/>", "\n")
	return (str:gsub("<[^<>]->", ""))
end

local run = pcall;

local function isFriend(plr, recolor)
	if rendervape.ObjectsThatCanBeSaved["Use FriendsToggle"].Api.Enabled then
		local friend = table.find(rendervape.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectList, plr.Name)
		friend = friend and rendervape.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectListEnabled[friend]
		if recolor then
			friend = friend and rendervape.ObjectsThatCanBeSaved["Recolor visualsToggle"].Api.Enabled
		end
		return friend
	end
	return nil
end

local function isTarget(plr)
	local friend = table.find(rendervape.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectList, plr.Name)
	friend = friend and rendervape.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectListEnabled[friend]
	return friend
end

local function isVulnerable(plr)
	return plr.Humanoid.Health > 0 and not plr.Character.FindFirstChildWhichIsA(plr.Character, "ForceField")
end

local function getPlayerColor(plr)
	if isFriend(plr, true) then
		return Color3.fromHSV(rendervape.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Hue, rendervape.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Sat, rendervape.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Value)
	end
	return tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color
end

local whitelist = {data = {WhitelistedUsers = {}}, hashes = {}, said = {}, alreadychecked = {}, customtags = {}, loaded = false, localprio = 0, hooked = false, get = function() return 0, true end}
local entityLibrary = loadstring(vapeGithubRequest("libraries/entityHandler.lua"))()
shared.vapeentity = entityLibrary
do
	entityLibrary.selfDestruct()
	table.insert(vapeConnections, rendervape.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.FriendRefresh.Event:Connect(function()
		entityLibrary.fullEntityRefresh()
	end))
	table.insert(vapeConnections, rendervape.ObjectsThatCanBeSaved["Teams by colorToggle"].Api.Refresh.Event:Connect(function()
		entityLibrary.fullEntityRefresh()
	end))
	local oldUpdateBehavior = entityLibrary.getUpdateConnections
	entityLibrary.getUpdateConnections = function(newEntity)
		local oldUpdateConnections = oldUpdateBehavior(newEntity)
		table.insert(oldUpdateConnections, {Connect = function()
			newEntity.Friend = isFriend(newEntity.Player) and true
			newEntity.Target = isTarget(newEntity.Player) and true
			return {Disconnect = function() end}
		end})
		return oldUpdateConnections
	end
	entityLibrary.isPlayerTargetable = function(plr)
		if isFriend(plr) then return false end
		if not ({whitelist:get(plr)})[2] then return false end
		if (not rendervape.ObjectsThatCanBeSaved["Teams by colorToggle"].Api.Enabled) then return true end
		if (not lplr.Team) then return true end
		if (not plr.Team) then return true end
		if plr.Team ~= lplr.Team then return true end
        return #plr.Team:GetPlayers() == players.NumPlayers
	end
	entityLibrary.fullEntityRefresh()
	entityLibrary.LocalPosition = Vector3.zero

	task.spawn(function()
		local postable = {}
		repeat
			task.wait()
			if isAlive(lplr, true) then
				table.insert(postable, {Time = tick(), Position = entityLibrary.character.HumanoidRootPart.Position})
				if #postable > 100 then
					table.remove(postable, 1)
				end
				local closestmag = 9e9
				local closestpos = entityLibrary.character.HumanoidRootPart.Position
				local currenttime = tick()
				for i, v in (postable) do
					local mag = 0.1 - (currenttime - v.Time)
					if mag < closestmag and mag > 0 then
						closestmag = mag
						closestpos = v.Position
					end
				end
				entityLibrary.LocalPosition = closestpos
			end
		until not vapeInjected
	end)
end

local function calculateMoveVector(cameraRelativeMoveVector)
	local c, s
	local _, _, _, R00, R01, R02, _, _, R12, _, _, R22 = camera.CFrame:GetComponents()
	if R12 < 1 and R12 > -1 then
		c = R22
		s = R02
	else
		c = R00
		s = -R01*math.sign(R12)
	end
	local norm = math.sqrt(c*c + s*s)
	return Vector3.new(
		(c*cameraRelativeMoveVector.X + s*cameraRelativeMoveVector.Z)/norm,
		0,
		(c*cameraRelativeMoveVector.Z - s*cameraRelativeMoveVector.X)/norm
	)
end

local raycastWallProperties = RaycastParams.new()
local function raycastWallCheck(char, checktable)
	if not checktable.IgnoreObject then
		checktable.IgnoreObject = raycastWallProperties
		local filter = {lplr.Character, camera}
		for i,v in (entityLibrary.entityList) do
			if v.Targetable then
				table.insert(filter, v.Character)
			end
		end
		for i,v in (checktable.IgnoreTable or {}) do
			table.insert(filter, v)
		end
		raycastWallProperties.FilterDescendantsInstances = filter
	end
	local ray = workspace.Raycast(workspace, checktable.Origin, (char[checktable.AimPart].Position - checktable.Origin), checktable.IgnoreObject)
	return not ray
end

local function EntityNearPosition(distance, checktab)
	checktab = checktab or {}
	if entityLibrary.isAlive then
		local sortedentities = {}
		for i, v in (entityLibrary.entityList) do -- loop through players
			if not v.Targetable then continue end
            if isVulnerable(v) then -- checks
				local playerPosition = v.RootPart.Position
				local mag = (entityLibrary.character.HumanoidRootPart.Position - playerPosition).magnitude
				if checktab.Prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - playerPosition).magnitude
				end
                if mag <= distance then -- mag check
					table.insert(sortedentities, {entity = v, Magnitude = v.Target and -1 or mag})
                end
            end
        end
		table.sort(sortedentities, function(a, b) return a.Magnitude < b.Magnitude end)
		for i, v in (sortedentities) do
			if checktab.WallCheck then
				if not raycastWallCheck(v.entity, checktab) then continue end
			end
			return v.entity
		end
	end
end

local function EntityNearMouse(distance, checktab)
	checktab = checktab or {}
    if entityLibrary.isAlive then
		local sortedentities = {}
		local mousepos = inputservice.GetMouseLocation(inputservice)
		for i, v in (entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local vec, vis = worldtoscreenpoint(v[checktab.AimPart].Position)
				local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
                if vis and mag <= distance then
					table.insert(sortedentities, {entity = v, Magnitude = v.Target and -1 or mag})
                end
            end
        end
		table.sort(sortedentities, function(a, b) return a.Magnitude < b.Magnitude end)
		for i, v in (sortedentities) do
			if checktab.WallCheck then
				if not raycastWallCheck(v.entity, checktab) then continue end
			end
			return v.entity
		end
    end
end

local function AllNearPosition(distance, amount, checktab)
	local returnedplayer = {}
	local currentamount = 0
	checktab = checktab or {}
    if entityLibrary.isAlive then
		local sortedentities = {}
		for i, v in (entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local playerPosition = v.RootPart.Position
				local mag = (entityLibrary.character.HumanoidRootPart.Position - playerPosition).magnitude
				if checktab.Prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - playerPosition).magnitude
				end
                if mag <= distance then
					table.insert(sortedentities, {entity = v, Magnitude = mag})
                end
            end
        end
		table.sort(sortedentities, function(a, b) return a.Magnitude < b.Magnitude end)
		for i,v in (sortedentities) do
			if checktab.WallCheck then
				if not raycastWallCheck(v.entity, checktab) then continue end
			end
			table.insert(returnedplayer, v.entity)
			currentamount = currentamount + 1
			if currentamount >= amount then break end
		end
	end
	return returnedplayer
end

local sha = loadstring(vapeGithubRequest("libraries/sha.lua"))()
run(function()
	local olduninject
	function whitelist:get(plr)
		local plrstr = self:hash(plr.Name..plr.UserId)
		for i,v in self.data.WhitelistedUsers do
			if v.hash == plrstr then
				return v.level, v.attackable or whitelist.localprio >= v.level, v.tags
			end
		end
		return 0, true
	end

	function whitelist:isingame()
		for i, v in players:GetPlayers() do
			if self:get(v) ~= 0 then
				return true
			end
		end
		return false
	end

	function whitelist:tag(plr, text, rich)
		local plrtag = ({self:get(plr)})[3] or self.customtags[plr.Name] or {}
		if not text then return plrtag end
		local newtag = ''
		for i, v in plrtag do
			newtag = newtag..(rich and '<font color="#'..v.color:ToHex()..'">['..v.text..']</font>' or '['..removeTags(v.text)..']')..' '
		end
		return newtag
	end

	function whitelist:hash(str)
		if self.hashes[str] == nil and sha then
			self.hashes[str] = sha.sha512(str..'SelfReport')
		end
		return self.hashes[str] or ''
	end

	function whitelist:getplayer(arg)
		if arg == 'default' and self.localprio == 0 then return true end
		if arg == 'private' and self.localprio == 1 then return true end
		if arg and lplr.Name:lower():sub(1, arg:len()) == arg:lower() then return true end
		return false
	end

	function whitelist:playeradded(v, joined)
		if self:get(v) ~= 0 then
			if self.alreadychecked[v.UserId] then return end
			self.alreadychecked[v.UserId] = true
			self:hook()
			if self.localprio == 0 then
				olduninject = rendervape.SelfDestruct
				rendervape.SelfDestruct = function() warningNotification('Vape', 'No escaping the private members :)', 10) end
				if joined then task.wait(10) end
				if textchat.ChatVersion == Enum.ChatVersion.TextChatService then
					local oldchannel = textchat.ChatInputBarConfiguration.TargetTextChannel
					local newchannel = cloneref(getservice('RobloxReplicatedStorage')).ExperienceChat.WhisperChat:InvokeServer(v.UserId)
					if newchannel then newchannel:SendAsync('helloimusinginhaler') end
					textchat.ChatInputBarConfiguration.TargetTextChannel = oldchannel
				elseif replicated:FindFirstChild('DefaultChatSystemChatEvents') then
					replicated.DefaultChatSystemChatEvents.SayMessageRequest:FireServer('/w '..v.Name..' helloimusinginhaler', 'All')
				end
			end
		end
	end

	function whitelist:checkmessage(msg, plr)
		local otherprio = self:get(plr)
		if plr == lplr and msg == 'helloimusinginhaler' then return true end
		if self.localprio > 0 and self.said[plr.Name] == nil and msg == 'helloimusinginhaler' and plr ~= lplr then
			self.said[plr.Name] = true
			notif('Vape', plr.Name..' is using vape!', 60)
			self.customtags[plr.Name] = {{text = 'VAPE USER', color = Color3.new(1, 1, 0)}}
			local newent = entityLibrary.getEntity(plr)
			if newent then entityLibrary.Events.EntityUpdated:Fire(newent) end
			return true
		end
		if self.localprio < otherprio or plr == lplr then
			local args = msg:split(' ')
			table.remove(args, 1)
			if self:getplayer(args[1]) then
				table.remove(args, 1)
				for i,v in self.commands do
					if msg:len() >= (i:len() + 1) and msg:sub(1, i:len() + 1):lower() == ";"..i:lower() then
						v(plr, args)
						return true
					end
				end
			end
		end
		return false
	end

	function whitelist:newchat(obj, plr, skip)
		obj.Text = self:tag(plr, true, true)..obj.Text
		local sub = obj.ContentText:find(': ')
		if sub then
			if not skip and self:checkmessage(obj.ContentText:sub(sub + 3, #obj.ContentText), plr) then
				obj.Visible = false
			end
		end
	end

	function whitelist:oldchat(func)
		local msgtable = debug.getupvalue(func, 3)
		if typeof(msgtable) == 'table' and msgtable.CurrentChannel then
			whitelist.oldchattable = msgtable
		end
		local oldchat

		oldchat = hookfunction(func, function(data, ...)
			local plr = players:GetPlayerByUserId(data.SpeakerUserId)
			if plr then
				data.ExtraData.Tags = data.ExtraData.Tags or {}
				for i, v in self:tag(plr) do
					table.insert(data.ExtraData.Tags, {TagText = v.text, TagColor = v.color})
				end
				if data.Message and self:checkmessage(data.Message, plr) then data.Message = '' end
			end
			return oldchat(data, ...)
		end)
		table.insert(vapeConnections, {Disconnect = function() hookfunction(func, oldchat) end})
	end

	function whitelist:hook()
		if self.hooked then return end
		self.hooked = true
		local exp = coregui:FindFirstChild('ExperienceChat')
		if textchat.ChatVersion == Enum.ChatVersion.TextChatService then
			if exp then
				if exp:WaitForChild('appLayout', 5) then
					table.insert(vapeConnections, exp:FindFirstChild('RCTScrollContentView', true).ChildAdded:Connect(function(obj)
						local plr = players:GetPlayerByUserId(tonumber(obj.Name:split('-')[1]) or 0)
						obj = obj:FindFirstChild('TextMessage', true)
						if obj then
							if plr then
								self:newchat(obj, plr, true)
								obj:GetPropertyChangedSignal('Text'):Wait()
								self:newchat(obj, plr)
							end
							if obj.ContentText:sub(1, 35) == 'You are now privately chatting with' then
								obj.Visible = false
							end
						end
					end))
				end
			end
		elseif replicated:FindFirstChild('DefaultChatSystemChatEvents') then
			pcall(function()
				for i, v in getconnections(replicated.DefaultChatSystemChatEvents.OnNewMessage.OnClientEvent) do
					if v.Function and table.find(debug.getconstants(v.Function), 'UpdateMessagePostedInChannel') then
						whitelist:oldchat(v.Function)
						break
					end
				end
				for i, v in getconnections(replicated.DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent) do
					if v.Function and table.find(debug.getconstants(v.Function), 'UpdateMessageFiltered') then
						whitelist:oldchat(v.Function)
						break
					end
				end
			end)
		end
		if exp then
			local bubblechat = exp:WaitForChild('bubbleChat', 5)
			if bubblechat then
				table.insert(vapeConnections, bubblechat.DescendantAdded:Connect(function(newbubble)
					if newbubble:IsA('TextLabel') and newbubble.Text:find('helloimusinginhaler') then
						newbubble.Parent.Parent.Visible = false
					end
				end))
			end
		end
	end

	function whitelist:check(first)
		local whitelistloaded, err = pcall(function()
			local _, subbed = pcall(function() return game:HttpGet('https://github.com/7GrandDadPGN/whitelists'):sub(100000, 160000) end)
			local commit = subbed:find('spoofed_commit_check')
			commit = commit and subbed:sub(commit + 21, commit + 60) or nil
			commit = commit and #commit == 40 and commit or 'main'
			whitelist.textdata = game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/whitelists/'..commit..'/PlayerWhitelist.json', true)
		end)
		if not whitelistloaded or not sha or not whitelist.get then return true end
		whitelist.loaded = true
		if not first or whitelist.textdata ~= whitelist.olddata then
			if not first then
				whitelist.olddata = isfile('rendervape/configuration/whitelist.json') and readfile('rendervape/configuration/whitelist.json') or nil
			end
			whitelist.data = getservice('HttpService'):JSONDecode(whitelist.textdata)
			whitelist.localprio = whitelist:get(lplr)

			for i, v in whitelist.data.WhitelistedUsers do
				if v.tags then
					for i2, v2 in v.tags do
						v2.color = Color3.fromRGB(unpack(v2.color))
					end
				end
			end

			for i, v in players:GetPlayers() do whitelist:playeradded(v) end
			if not whitelist.connection then
				whitelist.connection = players.PlayerAdded:Connect(function(v) whitelist:playeradded(v, true) end)
			end
			if (entityLibrary.isAlive or #entityLibrary.entityList > 0) then
				entityLibrary.fullEntityRefresh()
			end

			if whitelist.textdata ~= whitelist.olddata then
				if whitelist.data.Announcement.expiretime > os.time() then
					local targets = whitelist.data.Announcement.targets == 'all' and {tostring(lplr.UserId)} or {};
					if table.find(targets, tostring(lplr.UserId)) then
						local hint = Instance.new('Hint')
						hint.Text = 'VAPE ANNOUNCEMENT: '..whitelist.data.Announcement.text
						hint.Parent = workspace
						getservice('Debris'):AddItem(hint, 20)
					end
				end
				whitelist.olddata = whitelist.textdata
				pcall(function() writefile('rendervape/configuration/whitelist.json', whitelist.textdata) end)
			end

			if whitelist.data.KillVape then
				rendervape.SelfDestruct()
				return true
			end

			if whitelist.data.BlacklistedUsers[tostring(lplr.UserId)] then
				task.spawn(lplr.kick, lplr, whitelist.data.BlacklistedUsers[tostring(lplr.UserId)])
				return true
			end
		end
	end

	whitelist.commands = {
		byfron = function()
			task.spawn(function()
				if setthreadidentity then setthreadidentity(8) end
				if setthreadcaps then setthreadcaps(8) end
				local UIBlox = getrenv().require(getservice('CorePackages').UIBlox)
				local Roact = getrenv().require(getservice('CorePackages').Roact)
				UIBlox.init(getrenv().require(getservice('CorePackages').Workspace.Packages.RobloxAppUIBloxConfig))
				local auth = getrenv().require(coregui.RobloxGui.Modules.LuaApp.Components.Moderation.ModerationPrompt)
				local darktheme = getrenv().require(getservice('CorePackages').Workspace.Packages.Style).Themes.DarkTheme
				local fonttokens = getrenv().require(getservice("CorePackages").Packages._Index.UIBlox.UIBlox.App.Style.Tokens).getTokens('Desktop', 'Dark', true)
				local buildersans = getrenv().require(getservice('CorePackages').Packages._Index.UIBlox.UIBlox.App.Style.Fonts.FontLoader).new(true, fonttokens):loadFont()
				local tLocalization = getrenv().require(getservice('CorePackages').Workspace.Packages.RobloxAppLocales).Localization
				local localProvider = getrenv().require(getservice('CorePackages').Workspace.Packages.Localization).LocalizationProvider
				lplr.PlayerGui:ClearAllChildren()
				rendervape.MainGui.Enabled = false
				coregui:ClearAllChildren()
				lighting:ClearAllChildren()
				for _, v in workspace:GetChildren() do pcall(function() v:Destroy() end) end
				lplr.kick(lplr)
				getservice('GuiService'):ClearError()
				local gui = Instance.new('ScreenGui')
				gui.IgnoreGuiInset = true
				gui.Parent = coregui
				local frame = Instance.new('ImageLabel')
				frame.BorderSizePixel = 0
				frame.Size = UDim2.fromScale(1, 1)
				frame.BackgroundColor3 = Color3.fromRGB(224, 223, 225)
				frame.ScaleType = Enum.ScaleType.Crop
				frame.Parent = gui
				task.delay(0.3, function() frame.Image = 'rbxasset://textures/ui/LuaApp/graphic/Auth/GridBackground.jpg' end)
				task.delay(0.6, function()
					local modPrompt = Roact.createElement(auth, {
						style = {},
						screenSize = camera.ViewportSize or Vector2.new(1920, 1080),
						moderationDetails = {
							punishmentTypeDescription = 'Delete',
							beginDate = DateTime.fromUnixTimestampMillis(DateTime.now().UnixTimestampMillis - ((60 * math.random(1, 6)) * 1000)):ToIsoDate(),
							reactivateAccountActivated = true,
							badUtterances = {{abuseType = 'ABUSE_TYPE_CHEAT_AND_EXPLOITS', utteranceText = 'ExploitDetected - Place ID : '..game.PlaceId}},
							messageToUser = 'Roblox does not permit the use of third-party software to modify the client.'
						},
						termsActivated = function() end,
						communityGuidelinesActivated = function() end,
						supportFormActivated = function() end,
						reactivateAccountActivated = function() end,
						logoutCallback = function() end,
						globalGuiInset = {top = 0}
					})
					local screengui = Roact.createElement(localProvider, {
						localization = tLocalization.new('en-us')
					}, {Roact.createElement(UIBlox.Style.Provider, {
						style = {
							Theme = darktheme,
							Font = buildersans
						},
					}, {modPrompt})})
					Roact.mount(screengui, coregui)
				end)
			end)
		end,
		crash = function()
			task.spawn(setfpscap, 9e9)
			task.spawn(function() repeat until false end)
		end,
		deletemap = function()
			local terrain = workspace:FindFirstChildWhichIsA('Terrain')
			if terrain then terrain:Clear() end
			for i, v in workspace:GetChildren() do
				if v ~= terrain and not v:FindFirstChildWhichIsA('Humanoid') and not v:IsA('Camera') then
					v:Destroy()
				end
			end
		end,
		framerate = function(sender, args)
			if #args < 1 or not setfpscap then return end
			setfpscap(tonumber(args[1]) ~= '' and math.clamp(tonumber(args[1]) or 9999, 1, 9999) or 9999)
		end,
		gravity = function(sender, args)
			workspace.Gravity = tonumber(args[1]) or workspace.Gravity
		end,
		jump = function()
			if entityLibrary.isAlive and entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air then
				entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end,
		kick = function(sender, args)
			task.spawn(function() lplr:Kick(table.concat(args, ' ')) end)
		end,
		kill = function()
			if entityLibrary.isAlive then
				entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				entityLibrary.character.Humanoid.Health = 0
			end
		end,
		reveal = function(args)
			task.delay(0.1, function()
				if textchat.ChatVersion == Enum.ChatVersion.TextChatService then
                    textchat.ChatInputBarConfiguration.TargetTextChannel:SendAsync('I am using the inhaler client')
                else
                    replicated.DefaultChatSystemChatEvents.SayMessageRequest:FireServer('I am using the inhaler client', 'All')
                end
			end)
		end,
		shutdown = function()
			game:Shutdown()
		end,
		toggle = function(sender, args)
			if #args < 1 then return end
			if args[1]:lower() == 'all' then
				for i, v in rendervape.ObjectsThatCanBeSaved do
					local newname = i:gsub('OptionsButton', '')
					if v.Type == "OptionsButton" and newname ~= 'Panic' then
						v.Api.ToggleButton()
					end
				end
			else
				for i, v in rendervape.ObjectsThatCanBeSaved do
					local newname = i:gsub('OptionsButton', '')
					if v.Type == "OptionsButton" and newname:lower() == args[1]:lower() then
						v.Api.ToggleButton()
						break
					end
				end
			end
		end,
		trip = function()
			if entityLibrary.isAlive then
				entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
			end
		end,
		uninject = function()
			if olduninject then
				olduninject(vape)
			else
				rendervape.SelfDestruct()
			end
		end,
		void = function()
			if entityLibrary.isAlive then
				entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + Vector3.new(0, -1000, 0)
			end
		end
	}

	task.spawn(function()
		repeat
			if whitelist:check(whitelist.loaded) then return end
			task.wait(10)
		until shared.VapeInjected == nil
	end)
	table.insert(vapeConnections, {Disconnect = function()
		if whitelist.connection then whitelist.connection:Disconnect() end
		table.clear(whitelist.commands)
		table.clear(whitelist.data)
		table.clear(whitelist)
	end})
end)
shared.vapewhitelist = whitelist

local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = runservice.RenderStepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = runservice.Stepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = runservice.Heartbeat:Connect(func)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

rendervape.SelfDestructEvent.Event:Connect(function()
	for i,v in renderconnections do 
		if typeof(v) == 'thread' then 
			pcall(task.cancel, v)
		end
		if typeof(v) == 'RBXScriptConnection' and v.Connected then 
			v:Disconnect()
		end
	end
	vapeInjected = false
	entityLibrary.selfDestruct()
	for i, v in (vapeConnections) do
		if v.Disconnect then pcall(function() v:Disconnect() end) continue end
		if v.disconnect then pcall(function() v:disconnect() end) continue end
	end;
	RenderLibrary:uninject();
	shared.renderconstructor = nil;
end)

run(function()
	local radarcamera = Instance.new("Camera")
	radarcamera.FieldOfView = 45
	local Radar = rendervape.CreateCustomWindow({
		Name = "Radar",
		Icon = "rendervape/assets/RadarIcon1.png",
		IconSize = 16
	})
	local RadarColor = Radar.CreateColorSlider({
		Name = "Player Color",
		Function = function(val) end
	})
	local RadarFrame = Instance.new("Frame")
	RadarFrame.BackgroundColor3 = Color3.new()
	RadarFrame.BorderSizePixel = 0
	RadarFrame.BackgroundTransparency = 0.5
	RadarFrame.Size = UDim2.new(0, 250, 0, 250)
	RadarFrame.Parent = Radar.GetCustomChildren()
	local RadarBorder1 = RadarFrame:Clone()
	RadarBorder1.Size = UDim2.new(0, 6, 0, 250)
	RadarBorder1.Parent = RadarFrame
	local RadarBorder2 = RadarBorder1:Clone()
	RadarBorder2.Position = UDim2.new(0, 6, 0, 0)
	RadarBorder2.Size = UDim2.new(0, 238, 0, 6)
	RadarBorder2.Parent = RadarFrame
	local RadarBorder3 = RadarBorder1:Clone()
	RadarBorder3.Position = UDim2.new(1, -6, 0, 0)
	RadarBorder3.Size = UDim2.new(0, 6, 0, 250)
	RadarBorder3.Parent = RadarFrame
	local RadarBorder4 = RadarBorder1:Clone()
	RadarBorder4.Position = UDim2.new(0, 6, 1, -6)
	RadarBorder4.Size = UDim2.new(0, 238, 0, 6)
	RadarBorder4.Parent = RadarFrame
	local RadarBorder5 = RadarBorder1:Clone()
	RadarBorder5.Position = UDim2.new(0, 0, 0.5, -1)
	RadarBorder5.BackgroundColor3 = Color3.new(1, 1, 1)
	RadarBorder5.Size = UDim2.new(0, 250, 0, 2)
	RadarBorder5.Parent = RadarFrame
	local RadarBorder6 = RadarBorder1:Clone()
	RadarBorder6.Position = UDim2.new(0.5, -1, 0, 0)
	RadarBorder6.BackgroundColor3 = Color3.new(1, 1, 1)
	RadarBorder6.Size = UDim2.new(0, 2, 0, 124)
	RadarBorder6.Parent = RadarFrame
	local RadarBorder7 = RadarBorder1:Clone()
	RadarBorder7.Position = UDim2.new(0.5, -1, 0, 126)
	RadarBorder7.BackgroundColor3 = Color3.new(1, 1, 1)
	RadarBorder7.Size = UDim2.new(0, 2, 0, 124)
	RadarBorder7.Parent = RadarFrame
	local RadarMainFrame = Instance.new("Frame")
	RadarMainFrame.BackgroundTransparency = 1
	RadarMainFrame.Size = UDim2.new(0, 250, 0, 250)
	RadarMainFrame.Parent = RadarFrame
	local radartable = {}
	table.insert(vapeConnections, Radar.GetCustomChildren().Parent:GetPropertyChangedSignal("Size"):Connect(function()
		RadarFrame.Position = UDim2.new(0, 0, 0, (Radar.GetCustomChildren().Parent.Size.Y.Offset == 0 and 45 or 0))
	end))
	rendervape.ObjectsThatCanBeSaved.GUIWindow.Api.CreateCustomToggle({
		Name = "Radar",
		Icon = "rendervape/assets/RadarIcon2.png",
		Function = function(callback)
			Radar.SetVisible(callback)
			if callback then
				RunLoops:BindToRenderStep("Radar", function()
					if entityLibrary.isAlive then
						local v278 = (CFrame.new(0, 0, 0):inverse() * entityLibrary.character.HumanoidRootPart.CFrame).p * 0.2 * Vector3.new(1, 1, 1);
						local v279, v280, v281 = camera.CFrame:ToOrientation();
						local u90 = v280 * 180 / math.pi;
						local v277 = 0 - u90;
						local v276 = v278 + Vector3.zero;
						radarcamera.CFrame = CFrame.new(v276 + Vector3.new(0, 50, 0)) * CFrame.Angles(0, -v277 * (math.pi / 180), 0) * CFrame.Angles(-90 * (math.pi / 180), 0, 0)
						local done = {}
						for i, plr in (entityLibrary.entityList) do
							table.insert(done, plr)
							local thing
							if radartable[plr] then
								thing = radartable[plr]
								if thing.Visible then
									thing.Visible = false
								end
							else
								thing = Instance.new("Frame")
								thing.BackgroundTransparency = 0
								thing.Size = UDim2.new(0, 4, 0, 4)
								thing.BorderSizePixel = 1
								thing.BorderColor3 = Color3.new()
								thing.BackgroundColor3 = Color3.new()
								thing.Visible = false
								thing.Name = plr.Player.Name
								thing.Parent = RadarMainFrame
								radartable[plr] = thing
							end

							local v238, v239 = radarcamera:WorldToViewportPoint((CFrame.new(0, 0, 0):inverse() * plr.RootPart.CFrame).p * 0.2)
							thing.Visible = true
							thing.BackgroundColor3 = getPlayerColor(plr.Player) or Color3.fromHSV(RadarColor.Value, 1, 1)
							thing.Position = UDim2.new(math.clamp(v238.X, 0.03, 0.97), -2, math.clamp(v238.Y, 0.03, 0.97), -2)
						end
						for i, v in (radartable) do
							if not table.find(done, i) then
								radartable[i] = nil
								v:Destroy()
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromRenderStep("Radar")
				RadarMainFrame:ClearAllChildren()
				table.clear(radartable)
			end
		end,
		Priority = 1
	})
end)

run(function()
	local SilentAimSmartWallTable = {}
	local SilentAim = {Enabled = false}
	local SilentAimFOV = {Value = 1}
	local SilentAimMode = {Value = "Legit"}
	local SilentAimMethod = {Value = "FindPartOnRayWithIgnoreList"}
	local SilentAimRaycastMode = {Value = "Whitelist"}
	local SilentAimCircleToggle = {Enabled = false}
	local SilentAimCircleColor = {Value = 0.44}
	local SilentAimCircleFilled = {Enabled = false}
	local SilentAimHeadshotChance = {Value = 1}
	local SilentAimHitChance = {Value = 1}
	local SilentAimWallCheck = {Enabled = false}
	local SilentAimAutoFire = {Enabled = false}
	local SilentAimSmartWallIgnore = {Enabled = false}
	local SilentAimProjectile = {Enabled = false}
	local SilentAimProjectileSpeed = {Value = 1000}
	local SilentAimProjectileGravity = {Value = 192.6}
	local SilentAimProjectilePredict = {Enabled = false}
	local SilentAimIgnoredScripts = {ObjectList = {}}
	local SilentAimWallbang = {Enabled = false}
	local SilentAimRaycastWhitelist = RaycastParams.new()
	SilentAimRaycastWhitelist.FilterType = Enum.RaycastFilterType.Whitelist
	local SlientAimShotTick = tick()
	local SilentAimFilterObject = synapsev3 == "V3" and AllFilter.new({NamecallFilter.new(SilentAimMethod.Value), CallerFilter.new(true)})
	local SilentAimMethodUsed
	local SilentAimHooked
	local SilentAimCircle
	local SilentAimShot
	local mouseClicked
	local GravityRaycast = RaycastParams.new()
	GravityRaycast.RespectCanCollide = true

	local function predictGravity(pos, vel, mag, targetPart, Gravity)
		local newVelocity = vel.Y
		GravityRaycast.FilterDescendantsInstances = {targetPart.Character}
		local rootSize = (targetPart.Humanoid.HipHeight + (targetPart.RootPart.Size.Y / 2))
		for i = 1, math.floor(mag / 0.016) do
			newVelocity = newVelocity - (Gravity * 0.016)
			local floorDetection = workspace:Raycast(pos, Vector3.new(0, (newVelocity * 0.016) - rootSize, 0), GravityRaycast)
			if floorDetection then
				pos = Vector3.new(pos.X, floorDetection.Position.Y + rootSize, pos.Z)
				break
			end
			pos = pos + Vector3.new(0, newVelocity * 0.016, 0)
		end
		return pos, Vector3.new(vel.X, 0, vel.Z)
	end

	local function LaunchAngle(v: number, g: number, d: number, h: number, higherArc: boolean)
		local v2 = v * v
		local v4 = v2 * v2
		local root = math.sqrt(v4 - g*(g*d*d + 2*h*v2))
		if not higherArc then root = -root end
		return math.atan((v2 + root) / (g * d))
	end

	local function LaunchDirection(start, target, v, g, higherArc: boolean)
		local horizontal = Vector3.new(target.X - start.X, 0, target.Z - start.Z)
		local h = target.Y - start.Y
		local d = horizontal.Magnitude
		local a = LaunchAngle(v, g, d, h, higherArc)
		if a ~= a then return nil end
		local vec = horizontal.Unit * v
		local rotAxis = Vector3.new(-horizontal.Z, 0, horizontal.X)
		return CFrame.fromAxisAngle(rotAxis, a) * vec
	end

	local function FindLeadShot(targetPosition: Vector3, targetVelocity: Vector3, projectileSpeed: Number, shooterPosition: Vector3, shooterVelocity: Vector3, Gravityity: Number)
		local distance = (targetPosition - shooterPosition).Magnitude
		local p = targetPosition - shooterPosition
		local v = targetVelocity - shooterVelocity
		local a = Vector3.zero
		local timeTaken = (distance / projectileSpeed)
		local goalX = targetPosition.X + v.X*timeTaken + 0.5 * a.X * timeTaken^2
		local goalY = targetPosition.Y + v.Y*timeTaken + 0.5 * a.Y * timeTaken^2
		local goalZ = targetPosition.Z + v.Z*timeTaken + 0.5 * a.Z * timeTaken^2
		return Vector3.new(goalX, goalY, goalZ)
	end

	local function canClick()
		local mousepos = inputservice:GetMouseLocation() - Vector2.new(0, 36)
		for i,v in (lplr.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do
			if v.Active and v.Visible and v:FindFirstAncestorOfClass("ScreenGui").Enabled then
				return false
			end
		end
		for i,v in (getservice("coregui"):GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do
			if v.Active and v.Visible and v:FindFirstAncestorOfClass("ScreenGui").Enabled then
				return false
			end
		end
		return true
	end

	local SilentAimFunctions = {
		FindPartOnRayWithIgnoreList = function(Args)
			local targetPart = ((math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100)) <= SilentAimHeadshotChance.Value or SilentAimAutoFire.Enabled) and "Head" or "RootPart"
			local origin = Args[1].Origin
			local plr
			if SilentAimMode.Value == "Mouse" then
				plr = EntityNearMouse(SilentAimFOV.Value, {
					WallCheck = SilentAimWallCheck.Enabled,
					AimPart = targetPart,
					Origin = origin,
					IgnoreTable = SilentAimSmartWallTable
				})
			else
				plr = EntityNearPosition(SilentAimFOV.Value, {
					WallCheck = SilentAimWallCheck.Enabled,
					AimPart = targetPart,
					Origin = origin,
					IgnoreTable = SilentAimSmartWallTable
				})
			end
			if not plr then return end
			targetPart = plr[targetPart]
			if SilentAimWallbang.Enabled then
				return {targetPart, targetPart.Position, Vector3.zero, targetPart.Material}
			end
			SilentAimShot = plr
			SlientAimShotTick = tick() + 1
			local direction = CFrame.lookAt(origin, targetPart.Position)
			if SilentAimProjectile.Enabled then
				local targetPosition, targetVelocity = targetPart.Position, targetPart.Velocity
				if SilentAimProjectilePredict.Enabled then
					targetPosition, targetVelocity = predictGravity(targetPosition, targetVelocity, (targetPosition - origin).Magnitude / SilentAimProjectileSpeed.Value, plr, workspace.Gravity)
				end
				local calculated = LaunchDirection(origin, FindLeadShot(targetPosition, targetVelocity, SilentAimProjectileSpeed.Value, origin, Vector3.zero, SilentAimProjectileGravity.Value), SilentAimProjectileSpeed.Value,  SilentAimProjectileGravity.Value, false)
				if calculated then
					direction = CFrame.lookAt(origin, origin + calculated)
				end
			end
			Args[1] = Ray.new(origin, direction.lookVector * Args[1].Direction.Magnitude)
			return
		end,
		Raycast = function(Args)
			local targetPart = ((math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100)) <= SilentAimHeadshotChance.Value or SilentAimAutoFire.Enabled) and "Head" or "RootPart"
			local origin = Args[1]
			local plr
			if SilentAimMode.Value == "Mouse" then
				plr = EntityNearMouse(SilentAimFOV.Value, {
					WallCheck = SilentAimWallCheck.Enabled,
					AimPart = targetPart,
					Origin = origin,
					IgnoreObject = Args[3]
				})
			else
				plr = EntityNearPosition(SilentAimFOV.Value, {
					WallCheck = SilentAimWallCheck.Enabled,
					AimPart = targetPart,
					Origin = origin,
					IgnoreObject = Args[3]
				})
			end
			if not plr then return end
			targetPart = plr[targetPart]
			SilentAimShot = plr
			SlientAimShotTick = tick() + 1
			local direction = CFrame.lookAt(origin, targetPart.Position)
			if SilentAimProjectile.Enabled then
				local targetPosition, targetVelocity = targetPart.Position, targetPart.Velocity
				if SilentAimProjectilePredict.Enabled then
					targetPosition, targetVelocity = predictGravity(targetPosition, targetVelocity, (targetPosition - origin).Magnitude / SilentAimProjectileSpeed.Value, plr, workspace.Gravity)
				end
				local calculated = LaunchDirection(origin, FindLeadShot(targetPosition, targetVelocity, SilentAimProjectileSpeed.Value, origin, Vector3.zero, SilentAimProjectileGravity.Value), SilentAimProjectileSpeed.Value,  SilentAimProjectileGravity.Value, false)
				if calculated then
					direction = CFrame.lookAt(origin, origin + calculated)
				end
			end
			Args[2] = direction.lookVector * Args[2].Magnitude
			if SilentAimWallbang.Enabled then
				SilentAimRaycastWhitelist.FilterDescendantsInstances = {targetPart}
				Args[3] = SilentAimRaycastWhitelist
			end
			return
		end,
		ScreenPointToRay = function(Args)
			local targetPart = ((math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100)) <= SilentAimHeadshotChance.Value or SilentAimAutoFire.Enabled) and "Head" or "RootPart"
			local origin = camera.CFrame.p
			local plr
			if SilentAimMode.Value == "Mouse" then
				plr = EntityNearMouse(SilentAimFOV.Value, {
					WallCheck = SilentAimWallCheck.Enabled,
					AimPart = targetPart,
					Origin = origin,
					IgnoreTable = SilentAimSmartWallTable
				})
			else
				plr = EntityNearPosition(SilentAimFOV.Value, {
					WallCheck = SilentAimWallCheck.Enabled,
					AimPart = targetPart,
					Origin = origin,
					IgnoreTable = SilentAimSmartWallTable
				})
			end
			if not plr then return end
			targetPart = plr[targetPart]
			SilentAimShot = plr
			SlientAimShotTick = tick() + 1
			local direction = CFrame.lookAt(origin, targetPart.Position)
			if SilentAimProjectile.Enabled then
				if SilentAimProjectile.Enabled then
					local targetPosition, targetVelocity = targetPart.Position, targetPart.Velocity
					if SilentAimProjectilePredict.Enabled then
						targetPosition, targetVelocity = predictGravity(targetPosition, targetVelocity, (targetPosition - origin).Magnitude / SilentAimProjectileSpeed.Value, plr, workspace.Gravity)
					end
					local calculated = LaunchDirection(origin, FindLeadShot(targetPosition, targetVelocity, SilentAimProjectileSpeed.Value, origin, Vector3.zero, SilentAimProjectileGravity.Value), SilentAimProjectileSpeed.Value,  SilentAimProjectileGravity.Value, false)
					if calculated then
						direction = CFrame.lookAt(origin, origin + calculated)
					end
				end
			end
			return {Ray.new(direction.p + (Args[3] and direction.lookVector * Args[3] or Vector3.zero), direction.lookVector)}
		end
	}
	SilentAimFunctions.FindPartOnRayWithWhitelist = SilentAimFunctions.FindPartOnRayWithIgnoreList
	SilentAimFunctions.FindPartOnRay = SilentAimFunctions.FindPartOnRayWithIgnoreList
	SilentAimFunctions.ViewportPointToRay = SilentAimFunctions.ScreenPointToRay

	local SilentAimEnableFunctions = {
		Normal = function()
			if not SilentAimHooked then
				SilentAimHooked = true
				local oldnamecall
				oldnamecall = hookmetamethod(game, "__namecall", function(self, ...)
					if getnamecallmethod() ~= SilentAimMethod.Value then
						return oldnamecall(self, ...)
					end
					if checkcaller() then
						return oldnamecall(self, ...)
					end
					if not SilentAim.Enabled then
						return oldnamecall(self, ...)
					end
					local calling = getcallingscript()
					if calling then
						local list = #SilentAimIgnoredScripts.ObjectList > 0 and SilentAimIgnoredScripts.ObjectList or {"ControlScript", "ControlModule"}
						if table.find(list, tostring(calling)) then
							return oldnamecall(self, ...)
						end
					end
					local Args = {...}
					local res = SilentAimFunctions[SilentAimMethod.Value](Args)
					if res then
						return unpack(res)
					end
					return oldnamecall(self, unpack(Args))
				end)
			end
		end,
		NormalV3 = function()
			if not SilentAimHooked then
				SilentAimHooked = true
				local oldnamecall
				oldnamecall = hookmetamethod(game, "__namecall", getfilter(SilentAimFilterObject, function(self, ...) return oldnamecall(self, ...) end, function(self, ...)
					local calling = getcallingscript()
					if calling then
						local list = #SilentAimIgnoredScripts.ObjectList > 0 and SilentAimIgnoredScripts.ObjectList or {"ControlScript", "ControlModule"}
						if table.find(list, tostring(calling)) then
							return oldnamecall(self, ...)
						end
					end
					local Args = {...}
					local res = SilentAimFunctions[SilentAimMethod.Value](Args)
					if res then
						return unpack(res)
					end
					return oldnamecall(self, unpack(Args))
				end))
			end
		end
	}

	SilentAim = rendervape.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "SilentAim",
		Function = function(callback)
			if callback then
				SilentAimMethodUsed = "Normal"..synapsev3
				task.spawn(function()
					repeat
						vapeTargetInfo.Targets.SilentAim = SlientAimShotTick >= tick() and SilentAimShot or nil
						task.wait()
					until not SilentAim.Enabled
				end)
				if SilentAimCircle then SilentAimCircle.Visible = SilentAimMode.Value == "Mouse" end
				if SilentAimEnableFunctions[SilentAimMethodUsed] then
					SilentAimEnableFunctions[SilentAimMethodUsed]()
				end
			else
				if restorefunction then
					restorefunction(getrawmetatable(game).__namecall)
					SilentAimHooked = false
				end
				if SilentAimCircle then SilentAimCircle.Visible = false end
				vapeTargetInfo.Targets.SilentAim = nil
			end
		end,
		ExtraText = function()
			return SilentAimMethod.Value:gsub("FindPartOn", ""):gsub("PointToRay", "")
		end
	})
	SilentAimMode = SilentAim.CreateDropdown({
		Name = "Mode",
		List = {"Mouse", "Position"},
		Function = function(val) if SilentAimCircle then SilentAimCircle.Visible = SilentAim.Enabled and val == "Mouse" end end
	})
	SilentAimMethod = SilentAim.CreateDropdown({
		Name = "Method",
		List = {"FindPartOnRayWithIgnoreList", "FindPartOnRayWithWhitelist", "Raycast", "FindPartOnRay", "ScreenPointToRay", "ViewportPointToRay"},
		Function = function(val)
			SilentAimRaycastMode.Object.Visible = val == "Raycast"
			if SilentAimFilterObject then SilentAimFilterObject.Filters[1].NamecallMethod = val end
		end
	})
	SilentAimRaycastMode = SilentAim.CreateDropdown({
		Name = "Method Type",
		List = {"All", "Whitelist", "Blacklist"},
		Function = function(val) end
	})
	SilentAimRaycastMode.Object.Visible = false
	SilentAimFOV = SilentAim.CreateSlider({
		Name = "FOV",
		Min = 1,
		Max = 1000,
		Function = function(val) if SilentAimCircle then SilentAimCircle.Radius = val end  end,
		Default = 80
	})
	SilentAimHitChance = SilentAim.CreateSlider({
		Name = "Hit Chance",
		Min = 1,
		Max = 100,
		Function = function(val) end,
		Default = 100,
	})
	SilentAimHeadshotChance = SilentAim.CreateSlider({
		Name = "Headshot Chance",
		Min = 1,
		Max = 100,
		Function = function(val) end,
		Default = 25
	})
	SilentAimCircleToggle = SilentAim.CreateToggle({
		Name = "FOV Circle",
		Function = function(callback)
			if SilentAimCircleColor.Object then SilentAimCircleColor.Object.Visible = callback end
			if SilentAimCircleFilled.Object then SilentAimCircleFilled.Object.Visible = callback end
			if callback then
				SilentAimCircle = Drawing.new("Circle")
				SilentAimCircle.Transparency = 0.5
				SilentAimCircle.NumSides = 100
				SilentAimCircle.Filled = SilentAimCircleFilled.Enabled
				SilentAimCircle.Thickness = 1
				SilentAimCircle.Visible =  SilentAim.Enabled and SilentAimMode.Value == "Mouse"
				SilentAimCircle.Color = Color3.fromHSV(SilentAimCircleColor.Hue, SilentAimCircleColor.Sat, SilentAimCircleColor.Value)
				SilentAimCircle.Radius = SilentAimFOV.Value
				SilentAimCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
				table.insert(SilentAimCircleToggle.Connections, camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
					SilentAimCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
				end))
			else
				if SilentAimCircle then
					SilentAimCircle:Destroy()
					SilentAimCircle = nil
				end
			end
		end,
	})
	SilentAimCircleColor = SilentAim.CreateColorSlider({
		Name = "Circle Color",
		Function = function(hue, sat, val)
			if SilentAimCircle then SilentAimCircle.Color = Color3.fromHSV(hue, sat, val) end
		end
	})
	SilentAimCircleColor.Object.Visible = false
	SilentAimCircleFilled = SilentAim.CreateToggle({
		Name = "Filled Circle",
		Function = function(callback)
			if SilentAimCircle then SilentAimCircle.Filled = callback end
		end,
		Default = true
	})
	SilentAimCircleFilled.Object.Visible = false
	SilentAimWallCheck = SilentAim.CreateToggle({
		Name = "Wall Check",
		Function = void,
		Default = true
	})
	SilentAimWallbang = SilentAim.CreateToggle({
		Name = "Wall Bang",
		Function = void
	})
	SilentAimAutoFire = SilentAim.CreateToggle({
		Name = "AutoFire",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						if SilentAim.Enabled then
							local plr
							if SilentAimMode.Value == "Mouse" then
								plr = EntityNearMouse(SilentAimFOV.Value, {
									WallCheck = SilentAimWallCheck.Enabled,
									AimPart = "Head",
									Origin = camera.CFrame.p,
									IgnoreTable = SilentAimSmartWallTable
								})
							else
								plr = EntityNearPosition(SilentAimFOV.Value, {
									WallCheck = SilentAimWallCheck.Enabled,
									AimPart = "Head",
									Origin = camera.CFrame.p,
									IgnoreTable = SilentAimSmartWallTable
								})
							end
							if mouse1click and (isrbxactive and isrbxactive() or iswindowactive and iswindowactive()) then
								if plr then
									if canClick() and rendervape.MainGui.ScaledGui.ClickGui.Visible == false and not inputservice:GetFocusedTextBox() then
										if mouseClicked then mouse1release() else mouse1press() end
										mouseClicked = not mouseClicked
									else
										if mouseClicked then mouse1release() end
										mouseClicked = false
									end
								else
									if mouseClicked then mouse1release() end
									mouseClicked = false
								end
							end
						end
						task.wait()
					until not SilentAimAutoFire.Enabled
				end)
			end
		end,
		HoverText = "Automatically fires gun",
	})
	SilentAimProjectile = SilentAim.CreateToggle({
		Name = "Projectile",
		Function = function(callback)
			if SilentAimProjectileSpeed.Object then SilentAimProjectileSpeed.Object.Visible = callback end
			if SilentAimProjectileGravity.Object then SilentAimProjectileGravity.Object.Visible = callback end
		end
	})
	SilentAimProjectileSpeed = SilentAim.CreateSlider({
		Name = "Projectile Speed",
		Min = 1,
		Max = 1000,
		Default = 1000,
		Function = void
	})
	SilentAimProjectileSpeed.Object.Visible = false
	SilentAimProjectileGravity = SilentAim.CreateSlider({
		Name = "Projectile Gravity",
		Min = 1,
		Max = 192.6,
		Default = 192.6,
		Function = void
	})
	SilentAimProjectileGravity.Object.Visible = false
	SilentAimProjectilePredict = SilentAim.CreateToggle({
		Name = "Projectile Prediction",
		Function = void,
		HoverText = "Predicts the player's movement"
	})
	SilentAimProjectilePredict.Object.Visible = false
	SilentAimSmartWallIgnore = SilentAim.CreateToggle({
		Name = "Smart Ignore",
		Function = function(callback)
			if callback then
				warn('got table', SilentAimSmartWallIgnore.Connections)
				table.insert(SilentAimSmartWallIgnore.Connections, workspace.DescendantAdded:Connect(function(v)
					local lowername = v.Name:lower()
					if lowername:find("junk") or lowername:find("trash") or lowername:find("ignore") or lowername:find("particle") or lowername:find("spawn") or lowername:find("bullet") or lowername:find("debris") then
						table.insert(SilentAimSmartWallTable, v)
					end
				end))
				for i,v in (workspace:GetDescendants()) do
					local lowername = v.Name:lower()
					if lowername:find("junk") or lowername:find("trash") or lowername:find("ignore") or lowername:find("particle") or lowername:find("spawn") or lowername:find("bullet") or lowername:find("debris") then
						table.insert(SilentAimSmartWallTable, v)
					end
				end
			else
				table.clear(SilentAimSmartWallTable)
			end
		end,
		HoverText = "Ignores certain folders and what not with certain names"
	})
	SilentAimIgnoredScripts = SilentAim.CreateTextList({
		Name = "Ignored Scripts",
		TempText = "ignored scripts",
		AddFunction = function(user) end,
		RemoveFunction = function(num) end
	})

	local function getTriggerBotTarget()
		local rayparams = RaycastParams.new()
		rayparams.FilterDescendantsInstances = {lplr.Character, camera}
		rayparams.RespectCanCollide = true
		local ray = workspace:Raycast(camera.CFrame.p, camera.CFrame.lookVector * 10000, rayparams)
		if ray and ray.Instance then
			for i,v in (entityLibrary.entityList) do
				if v.Targetable and v.Character then
					if ray.Instance:IsDescendantOf(v.Character) then
						return isVulnerable(v) and v
					end
				end
			end
		end
		return nil
	end

	local TriggerBot = {Enabled = false}
	TriggerBot = rendervape.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "TriggerBot",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						local plr = getTriggerBotTarget()
						if mouse1click and (isrbxactive and isrbxactive() or iswindowactive and iswindowactive()) then
							if plr then
								if canClick() and rendervape.MainGui.ScaledGui.ClickGui.Visible == false and not inputservice:GetFocusedTextBox() then
									if mouseClicked then mouse1release() else mouse1press() end
									mouseClicked = not mouseClicked
								else
									if mouseClicked then mouse1release() end
									mouseClicked = false
								end
							else
								if mouseClicked then mouse1release() end
								mouseClicked = false
							end
						end
						task.wait()
					until not TriggerBot.Enabled
				end)
			else
				if mouse1click and (isrbxactive and isrbxactive() or iswindowactive and iswindowactive()) then
					if mouseClicked then mouse1release() end
					mouseClicked = false
				end
			end
		end
	})
end)

run(function()
	local AutoClicker = {Enabled = false}
	local AutoClickerCPS = {GetRandomValue = function() return 1 end}
	local AutoClickerMode = {Value = "Sword"}
	AutoClicker = rendervape.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "AutoClicker",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						if AutoClickerMode.Value == "Tool" then
							local tool = lplr and lplr.Character and lplr.Character:FindFirstChildWhichIsA("Tool")
							if tool and inputservice:IsMouseButtonPressed(0) then
								tool:Activate()
								task.wait(1 / AutoClickerCPS.GetRandomValue())
							end
						else
							if mouse1click and (isrbxactive and isrbxactive() or iswindowactive and iswindowactive()) then
								if rendervape.MainGui.ScaledGui.ClickGui.Visible == false then
									local clickfunc = (AutoClickerMode.Value == "Click" and mouse1click or mouse2click)
									clickfunc()
									task.wait(1 / AutoClickerCPS.GetRandomValue())
								end
							end
						end
						task.wait()
					until not AutoClicker.Enabled
				end)
			end
		end
	})
	AutoClickerMode = AutoClicker.CreateDropdown({
		Name = "Mode",
		List = {"Tool", "Click", "RightClick"},
		Function = void
	})
	AutoClickerCPS = AutoClicker.CreateTwoSlider({
		Name = "CPS",
		Min = 1,
		Max = 20,
		Default = 8,
		Default2 = 12
	})
end)

run(function()
	local ClickTP = {Enabled = false}
	local ClickTPMethod = {Value = "Normal"}
	local ClickTPDelay = {Value = 1}
	local ClickTPAmount = {Value = 1}
	local ClickTPVertical = {Enabled = true}
	local ClickTPVelocity = {Enabled = false}
	local ClickTPRaycast = RaycastParams.new()
	ClickTPRaycast.RespectCanCollide = true
	ClickTPRaycast.FilterType = Enum.RaycastFilterType.Blacklist
	ClickTP = rendervape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "MouseTP",
		Function = function(callback)
			if callback then
				RunLoops:BindToHeartbeat("MouseTP", function()
					if entityLibrary.isAlive and ClickTPVelocity.Enabled and ClickTPMethod.Value == "SlowTP" then
						entityLibrary.character.HumanoidRootPart.Velocity = Vector3.zero
					end
				end)
				if entityLibrary.isAlive then
					ClickTPRaycast.FilterDescendantsInstances = {lplr.Character, camera}
					local ray = workspace:Raycast(camera.CFrame.p, lplr:GetMouse().UnitRay.Direction * 10000, ClickTPRaycast)
					local selectedPosition = ray and ray.Position + Vector3.new(0, entityLibrary.character.Humanoid.HipHeight + (entityLibrary.character.HumanoidRootPart.Size.Y / 2), 0)
					if selectedPosition then
						if ClickTPMethod.Value == "Normal" then
							entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(selectedPosition)
							ClickTP.ToggleButton(false)
						else
							task.spawn(function()
								repeat
									if entityLibrary.isAlive then
										local newpos = (selectedPosition - entityLibrary.character.HumanoidRootPart.CFrame.p).Unit
										newpos = newpos == newpos and newpos * math.min((selectedPosition - entityLibrary.character.HumanoidRootPart.CFrame.p).Magnitude, ClickTPAmount.Value) or Vector3.zero
										entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + Vector3.new(newpos.X, (ClickTPVertical.Enabled and newpos.Y or 0), newpos.Z)
										if (selectedPosition - entityLibrary.character.HumanoidRootPart.CFrame.p).Magnitude <= 5 then
											break
										end
									end
									task.wait(ClickTPDelay.Value / 100)
								until entityLibrary.isAlive and (selectedPosition - entityLibrary.character.HumanoidRootPart.CFrame.p).Magnitude <= 5 or not ClickTP.Enabled
								if ClickTP.Enabled then ClickTP.ToggleButton(false) end
							end)
						end
					else
						ClickTP.ToggleButton(false)
						warningNotification("ClickTP", "No position found.", 1)
					end
				else
					if ClickTP.Enabled then ClickTP.ToggleButton(false) end
				end
			else
				RunLoops:UnbindFromHeartbeat("MouseTP")
			end
		end,
		HoverText = "Teleports to where your mouse is."
	})
	ClickTPMethod = ClickTP.CreateDropdown({
		Name = "Method",
		List = {"Normal", "SlowTP"},
		Function = function(val)
			if ClickTPAmount.Object then ClickTPAmount.Object.Visible = val == "SlowTP" end
			if ClickTPDelay.Object then ClickTPDelay.Object.Visible = val == "SlowTP" end
			if ClickTPVertical.Object then ClickTPVertical.Object.Visible = val == "SlowTP" end
			if ClickTPVelocity.Object then ClickTPVelocity.Object.Visible = val == "SlowTP" end
		end
	})
	ClickTPAmount = ClickTP.CreateSlider({
		Name = "Amount",
		Min = 1,
		Max = 50,
		Function = void
	})
	ClickTPAmount.Object.Visible = false
	ClickTPDelay = ClickTP.CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 50,
		Function = void
	})
	ClickTPDelay.Object.Visible = false
	ClickTPVertical = ClickTP.CreateToggle({
		Name = "Vertical",
		Default = true,
		Function = void
	})
	ClickTPVertical.Object.Visible = false
	ClickTPVelocity = ClickTP.CreateToggle({
		Name = "No Velocity",
		Default = true,
		Function = void
	})
	ClickTPVelocity.Object.Visible = false
end)

run(function()
	local Fly = {Enabled = false}
	local FlySpeed = {Value = 1}
	local FlyVerticalSpeed = {Value = 1}
	local FlyTPOff = {Value = 10}
	local FlyTPOn = {Value = 10}
	local FlyCFrameVelocity = {Enabled = false}
	local FlyWallCheck = {Enabled = false}
	local FlyVertical = {Enabled = false}
	local FlyMethod = {Value = "Normal"}
	local FlyMoveMethod = {Value = "MoveDirection"}
	local FlyKeys = {Value = "Space/LeftControl"}
	local FlyState = {Value = "Normal"}
	local FlyPlatformToggle = {Enabled = false}
	local FlyPlatformStanding = {Enabled = false}
	local FlyRaycast = RaycastParams.new()
	FlyRaycast.FilterType = Enum.RaycastFilterType.Blacklist
	FlyRaycast.RespectCanCollide = true
	local FlyJumpCFrame = CFrame.new(0, 0, 0)
	local FlyAliveCheck = false
	local FlyUp = false
	local FlyDown = false
	local FlyY = 0
	local FlyPlatform
	local w = 0
	local s = 0
	local a = 0
	local d = 0
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B", "AntiCheat C", "AntiCheat D"}
	Fly = rendervape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Fly",
		Function = function(callback)
			if callback then
				local FlyPlatformTick = tick() + 0.2
				w = inputservice:IsKeyDown(Enum.KeyCode.W) and -1 or 0
				s = inputservice:IsKeyDown(Enum.KeyCode.S) and 1 or 0
				a = inputservice:IsKeyDown(Enum.KeyCode.A) and -1 or 0
				d = inputservice:IsKeyDown(Enum.KeyCode.D) and 1 or 0
				table.insert(Fly.Connections, inputservice.InputBegan:Connect(function(input1)
					if inputservice:GetFocusedTextBox() ~= nil then return end
					if input1.KeyCode == Enum.KeyCode.W then
						w = -1
					elseif input1.KeyCode == Enum.KeyCode.S then
						s = 1
					elseif input1.KeyCode == Enum.KeyCode.A then
						a = -1
					elseif input1.KeyCode == Enum.KeyCode.D then
						d = 1
					end
					if FlyVertical.Enabled then
						local divided = FlyKeys.Value:split("/")
						if input1.KeyCode == Enum.KeyCode[divided[1]] then
							FlyUp = true
						elseif input1.KeyCode == Enum.KeyCode[divided[2]] then
							FlyDown = true
						end
					end
				end))
				table.insert(Fly.Connections, inputservice.InputEnded:Connect(function(input1)
					local divided = FlyKeys.Value:split("/")
					if input1.KeyCode == Enum.KeyCode.W then
						w = 0
					elseif input1.KeyCode == Enum.KeyCode.S then
						s = 0
					elseif input1.KeyCode == Enum.KeyCode.A then
						a = 0
					elseif input1.KeyCode == Enum.KeyCode.D then
						d = 0
					elseif input1.KeyCode == Enum.KeyCode[divided[1]] then
						FlyUp = false
					elseif input1.KeyCode == Enum.KeyCode[divided[2]] then
						FlyDown = false
					end
				end))
				if inputservice.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(Fly.Connections, jumpButton:GetPropertyChangedSignal("ImageRectOffset"):Connect(function()
							FlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						FlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
				if FlyMethod.Value == "Jump" and entityLibrary.isAlive then
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
				local FlyTP = false
				local FlyTPTick = tick()
				local FlyTPY
				RunLoops:BindToHeartbeat("Fly", function(delta)
					if entityLibrary.isAlive and (typeof(entityLibrary.character.HumanoidRootPart) ~= "Instance" or (render.clone.new or isnetworkowner(entityLibrary.character.HumanoidRootPart)))then
						entityLibrary.character.Humanoid.PlatformStand = FlyPlatformStanding.Enabled
						if not FlyY then FlyY = entityLibrary.character.HumanoidRootPart.CFrame.p.Y end
						local movevec = (FlyMoveMethod.Value == "Manual" and calculateMoveVector(Vector3.new(a + d, 0, w + s)) or entityLibrary.character.Humanoid.MoveDirection).Unit
						movevec = movevec == movevec and Vector3.new(movevec.X, 0, movevec.Z) or Vector3.zero
						if FlyState.Value ~= "None" then
							entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType[FlyState.Value])
						end
						if FlyMethod.Value == "Normal" or FlyMethod.Value == "Bounce" then
							if FlyPlatformStanding.Enabled then
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(entityLibrary.character.HumanoidRootPart.CFrame.p, entityLibrary.character.HumanoidRootPart.CFrame.p + camera.CFrame.lookVector)
								entityLibrary.character.HumanoidRootPart.RotVelocity = Vector3.zero
							end
							entityLibrary.character.HumanoidRootPart.Velocity = (movevec * FlySpeed.Value) + Vector3.new(0, 0.85 + (FlyMethod.Value == "Bounce" and (tick() % 0.5 > 0.25 and -10 or 10) or 0) + (FlyUp and FlyVerticalSpeed.Value or 0) + (FlyDown and -FlyVerticalSpeed.Value or 0), 0)
						else
							if FlyUp then
								FlyY = FlyY + (FlyVerticalSpeed.Value * delta)
							end
							if FlyDown then
								FlyY = FlyY - (FlyVerticalSpeed.Value * delta)
							end
							local newMovementPosition = (movevec * (math.max(FlySpeed.Value - entityLibrary.character.Humanoid.WalkSpeed, 0) * delta))
							newMovementPosition = Vector3.new(newMovementPosition.X, (FlyY - entityLibrary.character.HumanoidRootPart.CFrame.p.Y), newMovementPosition.Z)
							if FlyWallCheck.Enabled then
								FlyRaycast.FilterDescendantsInstances = {lplr.Character, camera}
								local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, newMovementPosition, FlyRaycast)
								if ray and ray.Instance.CanCollide then
									newMovementPosition = (ray.Position - entityLibrary.character.HumanoidRootPart.Position)
									FlyY = ray.Position.Y
								end
							end
							local origvelo = entityLibrary.character.HumanoidRootPart.Velocity
							if FlyMethod.Value == "CFrame" then
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + newMovementPosition
								if FlyCFrameVelocity.Enabled then
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(origvelo.X, 0, origvelo.Z)
								end
								if FlyPlatformStanding.Enabled then
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(entityLibrary.character.HumanoidRootPart.CFrame.p, entityLibrary.character.HumanoidRootPart.CFrame.p + camera.CFrame.lookVector)
								end
							elseif FlyMethod.Value == "Jump" then
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + Vector3.new(newMovementPosition.X, 0, newMovementPosition.Z)
								if entityLibrary.character.HumanoidRootPart.Velocity.Y < -(entityLibrary.character.Humanoid.JumpPower - ((FlyUp and FlyVerticalSpeed.Value or 0) - (FlyDown and FlyVerticalSpeed.Value or 0))) then
									FlyJumpCFrame = entityLibrary.character.HumanoidRootPart.CFrame * CFrame.new(0, -entityLibrary.character.Humanoid.HipHeight, 0)
									entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
								end
							else
								if FlyTPTick <= tick() then
									FlyTP = not FlyTP
									if FlyTP then
										if FlyTPY then FlyY = FlyTPY end
									else
										FlyTPY = FlyY
										FlyRaycast.FilterDescendantsInstances = {lplr.Character, camera}
										local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -10000, 0), FlyRaycast)
										if ray then FlyY = ray.Position.Y + ((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) end
									end
									FlyTPTick = tick() + ((FlyTP and FlyTPOn.Value or FlyTPOff.Value) / 10)
								end
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + newMovementPosition
								if FlyPlatformStanding.Enabled then
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(entityLibrary.character.HumanoidRootPart.CFrame.p, entityLibrary.character.HumanoidRootPart.CFrame.p + camera.CFrame.lookVector)
									entityLibrary.character.HumanoidRootPart.RotVelocity = Vector3.zero
								end
							end
						end
						if FlyPlatform then
							FlyPlatform.CFrame = (FlyMethod.Value == "Jump" and FlyJumpCFrame or entityLibrary.character.HumanoidRootPart.CFrame * CFrame.new(0, -(entityLibrary.character.Humanoid.HipHeight + (entityLibrary.character.HumanoidRootPart.Size.Y / 2) + 0.53), 0))
							FlyPlatform.Parent = camera
							if FlyUp or FlyPlatformTick >= tick() then
								entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
							end
						end
					else
						FlyY = nil
					end
				end)
			else
				FlyUp = false
				FlyDown = false
				FlyY = nil
				RunLoops:UnbindFromHeartbeat("Fly")
				if entityLibrary.isAlive and FlyPlatformStanding.Enabled then
					entityLibrary.character.Humanoid.PlatformStand = false
				end
				if FlyPlatform then
					FlyPlatform.Parent = nil
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
				end
			end
		end,
		ExtraText = function()
			if rendervape.ObjectsThatCanBeSaved["Text GUIAlternate TextToggle"].Api.Enabled then
				return alternatelist[table.find(FlyMethod.List, FlyMethod.Value)]
			end
			return FlyMethod.Value
		end
	})
	FlyMethod = Fly.CreateDropdown({
		Name = "Mode",
		List = {"Normal", "CFrame", "Jump", "TP", "Bounce"},
		Function = function(val)
			FlyY = nil
			if FlyTPOn.Object then FlyTPOn.Object.Visible = val == "TP" end
			if FlyTPOff.Object then FlyTPOff.Object.Visible = val == "TP" end
			if FlyWallCheck.Object then FlyWallCheck.Object.Visible = val == "CFrame" or val == "Jump" end
			if FlyCFrameVelocity.Object then FlyCFrameVelocity.Object.Visible = val == "CFrame" end
		end
	})
	FlyMoveMethod = Fly.CreateDropdown({
		Name = "Movement",
		List = {"Manual", "MoveDirection"},
		Function = function(val) end
	})
	FlyKeys = Fly.CreateDropdown({
		Name = "Keys",
		List = {"Space/LeftControl", "Space/LeftShift", "E/Q", "Space/Q"},
		Function = function(val) end
	})
	local states = {"None"}
	for i,v in (Enum.HumanoidStateType:GetEnumItems()) do if v.Name ~= "Dead" and v.Name ~= "None" then table.insert(states, v.Name) end end
	FlyState = Fly.CreateDropdown({
		Name = "State",
		List = states,
		Function = function(val) end
	})
	FlySpeed = Fly.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 150,
		Function = function(val) end
	})
	FlyVerticalSpeed = Fly.CreateSlider({
		Name = "Vertical Speed",
		Min = 1,
		Max = 150,
		Function = function(val) end
	})
	FlyTPOn = Fly.CreateSlider({
		Name = "TP Time Ground",
		Min = 1,
		Max = 100,
		Default = 50,
		Function = void,
		Double = 10
	})
	FlyTPOn.Object.Visible = false
	FlyTPOff = Fly.CreateSlider({
		Name = "TP Time Air",
		Min = 1,
		Max = 30,
		Default = 5,
		Function = void,
		Double = 10
	})
	FlyTPOff.Object.Visible = false
	FlyPlatformToggle = Fly.CreateToggle({
		Name = "FloorPlatform",
		Function = function(callback)
			if callback then
				FlyPlatform = Instance.new("Part")
				FlyPlatform.Anchored = true
				FlyPlatform.CanCollide = true
				FlyPlatform.Size = Vector3.new(2, 1, 2)
				FlyPlatform.Transparency = 0
			else
				if FlyPlatform then
					FlyPlatform:Destroy()
					FlyPlatform = nil
				end
			end
		end
	})
	FlyPlatformStanding = Fly.CreateToggle({
		Name = "PlatformStand",
		Function = void
	})
	FlyVertical = Fly.CreateToggle({
		Name = "Y Level",
		Function = void
	})
	FlyWallCheck = Fly.CreateToggle({
		Name = "Wall Check",
		Function = void,
		Default = true
	})
	FlyWallCheck.Object.Visible = false
	FlyCFrameVelocity = Fly.CreateToggle({
		Name = "No Velocity",
		Function = void,
		Default = true
	})
	FlyCFrameVelocity.Object.Visible = false
end)

run(function()
	local Hitboxes = {Enabled = false}
	local HitboxMode = {Value = "HumanoidRootPart"}
	local HitboxExpand = {Value = 1}
	Hitboxes = rendervape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "HitBoxes",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						for i,plr in (entityLibrary.entityList) do
							if plr.Targetable then
								if HitboxMode.Value == "HumanoidRootPart" then
									plr.RootPart.Size = Vector3.new(2 * (HitboxExpand.Value / 10), 2 * (HitboxExpand.Value / 10), 1 * (HitboxExpand.Value / 10))
								else
									plr.Head.Size = Vector3.new((HitboxExpand.Value / 10), (HitboxExpand.Value / 10), (HitboxExpand.Value / 10))
								end
							end
						end
						task.wait()
					until not Hitboxes.Enabled
				end)
			else
				for i,plr in (entityLibrary.entityList) do
					plr.RootPart.Size = Vector3.new(2, 2, 1)
					plr.Head.Size = Vector3.new(1, 1, 1)
				end
			end
		end
	})
	HitboxMode = Hitboxes.CreateDropdown({
		Name = "Expand part",
		List = {"HumanoidRootPart", "Head"},
		Function = function(val)
			if Hitboxes.Enabled then
				for i,plr in (entityLibrary.entityList) do
					if plr.Targetable then
						if HitboxMode.Value == "HumanoidRootPart" then
							plr.RootPart.Size = Vector3.new(2 * (HitboxExpand.Value / 10), 2 * (HitboxExpand.Value / 10), 1 * (HitboxExpand.Value / 10))
						else
							plr.Head.Size = Vector3.new((HitboxExpand.Value / 10), (HitboxExpand.Value / 10), (HitboxExpand.Value / 10))
						end
					end
				end
			end
		end
	})
	HitboxExpand = Hitboxes.CreateSlider({
		Name = "Expand amount",
		Min = 10,
		Max = 50,
		Function = function(val) end
	})
end)

local KillauraNearTarget = false
run(function()
	local attackIgnore = OverlapParams.new()
	attackIgnore.FilterType = Enum.RaycastFilterType.Whitelist
	local function findTouchInterest(tool)
		return tool and tool:FindFirstChildWhichIsA("TouchTransmitter", true)
	end

	local Reach = {Enabled = false}
	local ReachRange = {Value = 1}
	Reach = rendervape.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "Reach",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						if entityLibrary.isAlive then
							local tool = lplr and lplr.Character and lplr.Character:FindFirstChildWhichIsA("Tool")
							local touch = findTouchInterest(tool)
							if tool and touch then
								touch = touch.Parent
								local chars = {}
								for i,v in (entityLibrary.entityList) do table.insert(chars, v.Character) end
								ignorelist.FilterDescendantsInstances = chars
								local parts = workspace:GetPartBoundsInBox(touch.CFrame, touch.Size + Vector3.new(reachrange.Value, 0, reachrange.Value), ignorelist)
								for i,v in (parts) do
									firetouchinterest(touch, v, 1)
									firetouchinterest(touch, v, 0)
								end
							end
						end
						task.wait()
					until not Reach.Enabled
				end)
			end
		end
	})
	ReachRange = Reach.CreateSlider({
		Name = "Range",
		Min = 1,
		Max = 20,
		Function = function(val) end,
	})

	local Killaura = {Enabled = false}
	local KillauraCPS = {GetRandomValue = function() return 1 end}
	local KillauraMethod = {Value = "Normal"}
	local KillauraTarget = {Enabled = false}
	local KillauraColor = {Value = 0.44}
	local KillauraRange = {Value = 1}
	local KillauraAngle = {Value = 90}
	local KillauraFakeAngle = {Enabled = false}
	local KillauraPrediction = {Enabled = true}
	local KillauraButtonDown = {Enabled = false}
	local KillauraTargetHighlight = {Enabled = false}
	local KillauraRangeCircle = {Enabled = false}
	local KillauraRangeCirclePart
	local KillauraSwingTick = tick()
	local KillauraBoxes = {}
	local OriginalNeckC0
	local OriginalRootC0
	for i = 1, 10 do
		local KillauraBox = Instance.new("BoxHandleAdornment")
		KillauraBox.Transparency = 0.5
		KillauraBox.Color3 = Color3.fromHSV(KillauraColor.Hue, KillauraColor.Sat, KillauraColor.Value)
		KillauraBox.Adornee = nil
		KillauraBox.AlwaysOnTop = true
		KillauraBox.Size = Vector3.new(3, 6, 3)
		KillauraBox.ZIndex = 11
		KillauraBox.Parent = rendervape.MainGui
		KillauraBoxes[i] = KillauraBox
	end

	Killaura = rendervape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Killaura",
		Function = function(callback)
			if callback then
				if KillauraRangeCirclePart then KillauraRangeCirclePart.Parent = camera end
				RunLoops:BindToHeartbeat("Killaura", function()
					for i,v in (KillauraBoxes) do
						if v.Adornee then
							local onex, oney, onez = v.Adornee.CFrame:ToEulerAnglesXYZ()
							v.CFrame = CFrame.new() * CFrame.Angles(-onex, -oney, -onez)
						end
					end
					if entityLibrary.isAlive then
						if KillauraRangeCirclePart then
							KillauraRangeCirclePart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight + (entityLibrary.character.HumanoidRootPart.Size.Y / 2) - 0.3, 0)
						end
						if KillauraFakeAngle.Enabled then
							local Neck = entityLibrary.character.Head:FindFirstChild("Neck")
							local LowerTorso = entityLibrary.character.HumanoidRootPart.Parent and entityLibrary.character.HumanoidRootPart.Parent:FindFirstChild("LowerTorso")
							local RootC0 = LowerTorso and LowerTorso:FindFirstChild("Root")
							if Neck and RootC0 then
								if not OriginalNeckC0 then OriginalNeckC0 = Neck.C0.p end
								if not OriginalRootC0 then OriginalRootC0 = RootC0.C0.p end
								if OriginalRootC0 then
									if targetedplayer ~= nil then
										local targetPos = targetedplayer.RootPart.Position + Vector3.new(0, targetedplayer.Humanoid.HipHeight + (targetedplayer.RootPart.Size.Y / 2), 0)
										local lookCFrame = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace((Vector3.new(targetPos.X, targetPos.Y, targetPos.Z) - entityLibrary.character.Head.Position).Unit)))
										Neck.C0 = CFrame.new(OriginalNeckC0) * CFrame.Angles(lookCFrame.LookVector.Unit.y, 0, 0)
										RootC0.C0 = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace((Vector3.new(targetPos.X, Root.Position.Y, targetPos.Z) - Root.Position).Unit))) + OriginalRootC0
									else
										Neck.C0 = CFrame.new(OriginalNeckC0)
										RootC0.C0 = CFrame.new(OriginalRootC0)
									end
								end
							end
						end
					end
				end)
				task.spawn(function()
					repeat
						local attackedplayers = {}
						KillauraNearTarget = false
						vapeTargetInfo.Targets.Killaura = nil
						if entityLibrary.isAlive and (not KillauraButtonDown.Enabled or inputservice:IsMouseButtonPressed(0)) then
							local plrs = AllNearPosition(KillauraRange.Value, 100, {Prediction = KillauraPrediction.Enabled})
							if #plrs > 0 then
								local tool = lplr.Character:FindFirstChildWhichIsA("Tool")
								local touch = findTouchInterest(tool)
								if tool and touch then
									for i,v in (plrs) do
										if math.acos(entityLibrary.character.HumanoidRootPart.CFrame.lookVector:Dot((v.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Unit)) >= (math.rad(KillauraAngle.Value) / 2) then continue end
										KillauraNearTarget = true
										if KillauraTarget.Enabled then
											table.insert(attackedplayers, v)
										end
										vapeTargetInfo.Targets.Killaura = v
										KillauraNearTarget = true
										if KillauraPrediction.Enabled then
											if (entityLibrary.LocalPosition - v.RootPart.Position).Magnitude > KillauraRange.Value then
												continue
											end
										end
										if KillauraSwingTick <= tick() then
											tool:Activate()
											KillauraSwingTick = tick() + (1 / KillauraCPS.GetRandomValue())
										end
										if KillauraMethod.Value == "Bypass" then
											attackIgnore.FilterDescendantsInstances = {v.Character}
											local parts = workspace:GetPartBoundsInBox(v.RootPart.CFrame, v.Character:GetExtentsSize(), attackIgnore)
											for i,v2 in (parts) do
												firetouchinterest(touch.Parent, v2, 1)
												firetouchinterest(touch.Parent, v2, 0)
											end
										elseif KillauraMethod.Value == "Normal" then
											for i,v2 in (v.Character:GetChildren()) do
												if v2:IsA("BasePart") then
													firetouchinterest(touch.Parent, v2, 1)
													firetouchinterest(touch.Parent, v2, 0)
												end
											end
										else
											firetouchinterest(touch.Parent, v.RootPart, 1)
											firetouchinterest(touch.Parent, v.RootPart, 0)
										end
									end
								end
							end
						end
						for i,v in (KillauraBoxes) do
							local attacked = attackedplayers[i]
							v.Adornee = attacked and attacked.RootPart
						end
						task.wait()
					until not Killaura.Enabled
				end)
			else
				RunLoops:UnbindFromHeartbeat("Killaura")
                KillauraNearTarget = false
				vapeTargetInfo.Targets.Killaura = nil
				for i,v in (KillauraBoxes) do v.Adornee = nil end
				if KillauraRangeCirclePart then KillauraRangeCirclePart.Parent = nil end
			end
		end,
		HoverText = "Attack players around you\nwithout aiming at them."
	})
	KillauraMethod = Killaura.CreateDropdown({
		Name = "Mode",
		List = {"Normal", "Bypass", "Root Only"},
		Function = void
	})
	KillauraCPS = Killaura.CreateTwoSlider({
		Name = "Attacks per second",
		Min = 1,
		Max = 20,
		Default = 8,
		Default2 = 12
	})
	KillauraRange = Killaura.CreateSlider({
		Name = "Attack range",
		Min = 1,
		Max = 150,
		Function = function(val)
			if KillauraRangeCirclePart then
				KillauraRangeCirclePart.Size = Vector3.new(val * 0.7, 0.01, val * 0.7)
			end
		end
	})
	KillauraAngle = Killaura.CreateSlider({
		Name = "Max angle",
		Min = 1,
		Max = 360,
		Function = function(val) end,
		Default = 90
	})
	KillauraColor = Killaura.CreateColorSlider({
		Name = "Target Color",
		Function = function(hue, sat, val)
			for i,v in (KillauraBoxes) do
				v.Color3 = Color3.fromHSV(hue, sat, val)
			end
			if KillauraRangeCirclePart then
				KillauraRangeCirclePart.Color = Color3.fromHSV(hue, sat, val)
			end
		end,
		Default = 1
	})
	KillauraButtonDown = Killaura.CreateToggle({
		Name = "Require mouse down",
		Function = void
	})
	KillauraTarget = Killaura.CreateToggle({
        Name = "Show target",
        Function = function(callback) end,
		HoverText = "Shows a red box over the opponent."
    })
	KillauraPrediction = Killaura.CreateToggle({
		Name = "Prediction",
		Function = void
	})
	KillauraFakeAngle = Killaura.CreateToggle({
        Name = "Face target",
        Function = void,
		HoverText = "Makes your character face the opponent."
    })
	KillauraRangeCircle = Killaura.CreateToggle({
		Name = "Range Visualizer",
		Function = function(callback)
			if callback then
				KillauraRangeCirclePart = Instance.new("MeshPart")
				KillauraRangeCirclePart.MeshId = "rbxassetid://3726303797"
				KillauraRangeCirclePart.Color = Color3.fromHSV(KillauraColor.Hue, KillauraColor.Sat, KillauraColor.Value)
				KillauraRangeCirclePart.CanCollide = false
				KillauraRangeCirclePart.Anchored = true
				KillauraRangeCirclePart.Material = Enum.Material.Neon
				KillauraRangeCirclePart.Size = Vector3.new(KillauraRange.Value * 0.7, 0.01, KillauraRange.Value * 0.7)
				KillauraRangeCirclePart.Parent = camera
			else
				if KillauraRangeCirclePart then
					KillauraRangeCirclePart:Destroy()
					KillauraRangeCirclePart = nil
				end
			end
		end
	})
end)

run(function()
	local LongJump = {Enabled = false}
	local LongJumpBoost = {Value = 1}
	local LongJumpChange = true
	LongJump = rendervape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "LongJump",
		Function = function(callback)
			if callback then
				if entityLibrary.isAlive and entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air then
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
				RunLoops:BindToHeartbeat("LongJump", function()
					if entityLibrary.isAlive then
						if (entityLibrary.character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall or entityLibrary.character.Humanoid:GetState() == Enum.HumanoidStateType.Jumping) and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero then
							local velo = entityLibrary.character.Humanoid.MoveDirection * LongJumpBoost.Value
							entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(velo.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, velo.Z)
						end
						local check = entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air
						if LongJumpChange ~= check then
							if check then LongJump.ToggleButton(true) end
							LongJumpChange = check
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("LongJump")
				LongJumpChange = true
			end
		end
	})
	LongJumpBoost = LongJump.CreateSlider({
		Name = "Boost",
		Min = 1,
		Max = 150,
		Function = function(val) end
	})

	local HighJump = {Enabled = false}
	local HighJumpMethod = {Value = "Toggle"}
	local HighJumpMode = {Value = "Normal"}
	local HighJumpBoost = {Value = 1}
	local HighJumpDelay = {Value = 20}
	local HighJumpTick = tick()
	local highjumpBound = true
	HighJump = rendervape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "HighJump",
		Function = function(callback)
			if callback then
				if HighJumpMethod.Value == "Toggle" then
					if HighJumpTick > tick()  then
						warningNotification("HighJump", "Wait "..(math.floor((HighJumpTick - tick()) * 10) / 10).."s before retoggling.", 1)
						HighJump.ToggleButton(false)
						return
					end
					if entityLibrary.isAlive and entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air then
						HighJumpTick = tick() + (HighJumpDelay.Value / 10)
						if HighJumpMode.Value == "Normal" then
							entityLibrary.character.HumanoidRootPart.Velocity = entityLibrary.character.HumanoidRootPart.Velocity + Vector3.new(0, HighJumpBoost.Value, 0)
						else
							task.spawn(function()
								local start = HighJumpBoost.Value
								repeat
									entityLibrary.character.HumanoidRootPart.CFrame += Vector3.new(0, start * 0.016, 0)
									start = start - (workspace.Gravity * 0.016)
									task.wait()
								until start <= 0
							end)
						end
					end
					HighJump.ToggleButton(false)
				else
					local debounce = 0
					RunLoops:BindToRenderStep("HighJump", function()
						if entityLibrary.isAlive and entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air and inputservice:IsKeyDown(Enum.KeyCode.Space) and (tick() - debounce) > 0.3 then
							debounce = tick()
							if HighJumpMode.Value == "Normal" then
								entityLibrary.character.HumanoidRootPart.Velocity = entityLibrary.character.HumanoidRootPart.Velocity + Vector3.new(0, HighJumpBoost.Value, 0)
							else
								task.spawn(function()
									local start = HighJumpBoost.Value
									repeat
										entityLibrary.character.HumanoidRootPart.CFrame += Vector3.new(0, start * 0.016, 0)
										start = start - (workspace.Gravity * 0.016)
										task.wait()
									until start <= 0
								end)
							end
						end
					end)
				end
			else
				RunLoops:UnbindFromRenderStep("HighJump")
			end
		end,
		HoverText = "Lets you jump higher"
	})
	HighJumpMethod = HighJump.CreateDropdown({
		Name = "Method",
		List = {"Toggle", "Normal"},
		Function = function(val) end
	})
	HighJumpMode = HighJump.CreateDropdown({
		Name = "Mode",
		List = {"Normal", "CFrame"},
		Function = function(val) end
	})
	HighJumpBoost = HighJump.CreateSlider({
		Name = "Boost",
		Min = 1,
		Max = 150,
		Function = function(val) end,
		Default = 100
	})
	HighJumpDelay = HighJump.CreateSlider({
		Name = "Delay",
		Min = 0,
		Max = 50,
		Function = function(val) end,
	})
end)

local spiderHoldingShift = false
local Spider = {Enabled = false}
local Phase = {Enabled = false}
run(function()
	local PhaseMode = {Value = "Normal"}
	local PhaseStudLimit = {Value = 1}
	local PhaseModifiedParts = {}
	local PhaseRaycast = RaycastParams.new()
	PhaseRaycast.RespectCanCollide = true
	PhaseRaycast.FilterType = Enum.RaycastFilterType.Blacklist
	local PhaseOverlap = OverlapParams.new()
	PhaseOverlap.MaxParts = 9e9
	PhaseOverlap.FilterDescendantsInstances = {}

	local PhaseFunctions = {
		Part = function()
			local chars = {camera, lplr.Character}
			for i, v in (entityLibrary.entityList) do table.insert(chars, v.Character) end
			PhaseOverlap.FilterDescendantsInstances = chars
			local rootpos = entityLibrary.character.HumanoidRootPart.CFrame.p
			local parts = workspace:GetPartBoundsInRadius(rootpos, 2, PhaseOverlap)
			for i, v in (parts) do
				if v.CanCollide and (v.Position.Y + (v.Size.Y / 2)) > (rootpos.Y - entityLibrary.character.Humanoid.HipHeight) and (not Spider.Enabled or spiderHoldingShift) then
					PhaseModifiedParts[v] = true
					v.CanCollide = false
				end
			end
			for i,v in (PhaseModifiedParts) do
				if not table.find(parts, i) then
					PhaseModifiedParts[i] = nil
					i.CanCollide = true
				end
			end
		end,
		Character = function()
			for i, part in (lplr.Character:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide and (not Spider.Enabled or spiderHoldingShift) then
					PhaseModifiedParts[part] = true
					part.CanCollide = Spider.Enabled and not spiderHoldingShift
				end
			end
		end,
		TP = function()
			local chars = {camera, lplr.Character}
			for i, v in (entityLibrary.entityList) do table.insert(chars, v.Character) end
			PhaseRaycast.FilterDescendantsInstances = chars
			local phaseRayCheck = workspace:Raycast(entityLibrary.character.Head.CFrame.p, entityLibrary.character.Humanoid.MoveDirection * 1.1, PhaseRaycast)
			if phaseRayCheck and (not Spider.Enabled or spiderHoldingShift) then
				local phaseDirection = phaseRayCheck.Normal.Z ~= 0 and "Z" or "X"
				if phaseRayCheck.Instance.Size[phaseDirection] <= PhaseStudLimit.Value then
					entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (phaseRayCheck.Normal * (-(phaseRayCheck.Instance.Size[phaseDirection]) - (entityLibrary.character.HumanoidRootPart.Size.X / 1.5)))
				end
			end
		end
	}

	Phase = rendervape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Phase",
		Function = function(callback)
			if callback then
				RunLoops:BindToStepped("Phase", function() -- has to be ran on stepped idk why
					if entityLibrary.isAlive then
						PhaseFunctions[PhaseMode.Value]()
					end
				end)
			else
				RunLoops:UnbindFromStepped("Phase")
				for i,v in (PhaseModifiedParts) do if i then i.CanCollide = true end end
				table.clear(PhaseModifiedParts)
			end
		end,
		HoverText = "Lets you Phase/Clip through walls. (Hold shift to use Phase over spider)"
	})
	PhaseMode = Phase.CreateDropdown({
		Name = "Mode",
		List = {"Part", "Character", "TP"},
		Function = function(val)
			if PhaseStudLimit.Object then
				PhaseStudLimit.Object.Visible = val == "TP"
			end
		end
	})
	PhaseStudLimit = Phase.CreateSlider({
		Name = "Studs",
		Function = void,
		Min = 1,
		Max = 20,
		Default = 5,
	})
end)

run(function()
	local SpiderSpeed = {Value = 0}
	local SpiderState = {Enabled = false}
	local SpiderMode = {Value = "Normal"}
	local SpiderRaycast = RaycastParams.new()
	SpiderRaycast.RespectCanCollide = true
	SpiderRaycast.FilterType = Enum.RaycastFilterType.Blacklist
	local SpiderActive
	local SpiderPart

	local function clampSpiderPosition(dir, pos, size)
		local suc, res = pcall(function() return Vector3.new(math.clamp(dir.X, pos.X - (size.X / 2), pos.X + (size.X / 2)), math.clamp(dir.Y, pos.Y - (size.Y / 2), pos.Y + (size.Y / 2)), math.clamp(dir.Z, pos.Z - (size.Z / 2), pos.Z + (size.Z / 2))) end)
		return suc and res or Vector3.zero
	end

	Spider = rendervape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Spider",
		Function = function(callback)
			if callback then
				if SpiderPart then SpiderPart.Parent = camera end
				RunLoops:BindToHeartbeat("Spider", function(delta)
					if entityLibrary.isAlive then
						local chars = {camera, lplr.Character, SpiderPart}
						for i, v in (entityLibrary.entityList) do table.insert(chars, v.Character) end
						SpiderRaycast.FilterDescendantsInstances = chars
						if SpiderMode.Value ~= "Classic" then
							local vec = entityLibrary.character.Humanoid.MoveDirection * 2
							local newray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, vec + Vector3.new(0, 0.1, 0), SpiderRaycast)
							local newray2 = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, vec - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0), SpiderRaycast)
							if SpiderActive and not newray and not newray2 then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 0, entityLibrary.character.HumanoidRootPart.Velocity.Z)
							end
							SpiderActive = ((newray or newray2) and true or false)
							spiderHoldingShift = inputservice:IsKeyDown(Enum.KeyCode.LeftShift)
							if SpiderActive and (newray or newray2).Normal.Y == 0 then
								if not Phase.Enabled or not spiderHoldingShift then
									if SpiderState.Enabled then entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Climbing) end
									if SpiderMode.Value == "CFrame" then
										entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + Vector3.new(-(entityLibrary.character.HumanoidRootPart.CFrame.lookVector.X * 18) * delta, SpiderSpeed.Value * delta, -(entityLibrary.character.HumanoidRootPart.CFrame.lookVector.Z * 18) * delta)
									else
										entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X - (entityLibrary.character.HumanoidRootPart.CFrame.lookVector.X / 2), SpiderSpeed.Value, entityLibrary.character.HumanoidRootPart.Velocity.Z - (entityLibrary.character.HumanoidRootPart.CFrame.lookVector.Z / 2))
									end
								end
							end
						else
							local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 1.5
							local newray2 = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, (vec - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)), SpiderRaycast)
							spiderHoldingShift = inputservice:IsKeyDown(Enum.KeyCode.LeftShift)
							if newray2 and (not Phase.Enabled or not spiderHoldingShift) then
								local newray2pos = newray2.Instance.Position
								local newpos = clampSpiderPosition(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(newray2pos.X, math.min(entityLibrary.character.HumanoidRootPart.Position.Y, newray2pos.Y), newray2pos.Z), newray2.Instance.Size - Vector3.new(1.9, 1.9, 1.9))
								SpiderPart.Position = newpos
							else
								SpiderPart.Position = Vector3.zero
							end
						end
					end
				end)
			else
				if SpiderPart then SpiderPart.Parent = nil end
				RunLoops:UnbindFromHeartbeat("Spider")
			end
		end,
		HoverText = "Lets you climb up walls"
	})
	SpiderMode = Spider.CreateDropdown({
		Name = "Mode",
		List = {"Normal", "CFrame", "Classic"},
		Function = function(val)
			if SpiderPart then SpiderPart:Destroy() SpiderPart = nil end
			if val == "Classic" then
				SpiderPart = Instance.new("TrussPart")
				SpiderPart.Size = Vector3.new(2, 2, 2)
				SpiderPart.Transparency = 1
				SpiderPart.Anchored = true
				SpiderPart.Parent = Spider.Enabled and camera or nil
			end
		end
	})
	SpiderSpeed = Spider.CreateSlider({
		Name = "Speed",
		Min = 0,
		Max = 100,
		Function = void,
		Default = 30
	})
	SpiderState = Spider.CreateToggle({
		Name = "Climb State",
		Function = void
	})
end)

run(function()
	local Speed = {Enabled = false}
	local SpeedValue = {Value = 1}
	local SpeedMethod = {Value = "AntiCheat A"}
	local SpeedMoveMethod = {Value = "MoveDirection"}
	local SpeedDelay = {Value = 0.7}
	local SpeedPulseDuration = {Value = 100}
	local SpeedWallCheck = {Enabled = true}
	local SpeedJump = {Enabled = false}
	local SpeedJumpHeight = {Value = 20}
	local SpeedJumpVanilla = {Enabled = false}
	local SpeedJumpAlways = {Enabled = false}
	local SpeedAnimation = {Enabled = false}
	local SpeedDelayTick = tick()
	local SpeedRaycast = RaycastParams.new()
	SpeedRaycast.FilterType = Enum.RaycastFilterType.Blacklist
	SpeedRaycast.RespectCanCollide = true
	local oldWalkSpeed
	local SpeedDown
	local SpeedUp
	local w = 0
	local s = 0
	local a = 0
	local d = 0

	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B", "AntiCheat C", "AntiCheat D"}
	Speed = rendervape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Speed",
		Function = function(callback)
			if callback then
				w = inputservice:IsKeyDown(Enum.KeyCode.W) and -1 or 0
				s = inputservice:IsKeyDown(Enum.KeyCode.S) and 1 or 0
				a = inputservice:IsKeyDown(Enum.KeyCode.A) and -1 or 0
				d = inputservice:IsKeyDown(Enum.KeyCode.D) and 1 or 0
				table.insert(Speed.Connections, inputservice.InputBegan:Connect(function(input1)
					if inputservice:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.W then
							w = -1
						end
						if input1.KeyCode == Enum.KeyCode.S then
							s = 1
						end
						if input1.KeyCode == Enum.KeyCode.A then
							a = -1
						end
						if input1.KeyCode == Enum.KeyCode.D then
							d = 1
						end
					end
				end))
				table.insert(Speed.Connections, inputservice.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.W then
						w = 0
					end
					if input1.KeyCode == Enum.KeyCode.S then
						s = 0
					end
					if input1.KeyCode == Enum.KeyCode.A then
						a = 0
					end
					if input1.KeyCode == Enum.KeyCode.D then
						d = 0
					end
				end))
				local pulsetick = tick()
				task.spawn(function()
					repeat
						pulsetick = tick() + (SpeedPulseDuration.Value / 100)
						task.wait((SpeedDelay.Value / 10) + (SpeedPulseDuration.Value / 100))
					until (not Speed.Enabled)
				end)
				RunLoops:BindToHeartbeat("Speed", function(delta)
					if entityLibrary.isAlive and (typeof(entityLibrary.character.HumanoidRootPart) ~= "Instance" or (render.clone.new or isnetworkowner(entityLibrary.character.HumanoidRootPart))) then
						local movevec = (SpeedMoveMethod.Value == "Manual" and calculateMoveVector(Vector3.new(a + d, 0, w + s)) or entityLibrary.character.Humanoid.MoveDirection).Unit
						movevec = movevec == movevec and Vector3.new(movevec.X, 0, movevec.Z) or Vector3.zero
						SpeedRaycast.FilterDescendantsInstances = {lplr.Character, cam}
						if SpeedMethod.Value == "Velocity" then
							if SpeedAnimation.Enabled then
								for i,v in (entityLibrary.character.Humanoid:GetPlayingAnimationTracks()) do
									if v.Name == "WalkAnim" or v.Name == "RunAnim" then
										v:AdjustSpeed(entityLibrary.character.Humanoid.WalkSpeed / 16)
									end
								end
							end
							local newvelo = movevec * SpeedValue.Value
							entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(newvelo.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, newvelo.Z)
						elseif SpeedMethod.Value == "CFrame" then
							local newpos = (movevec * (math.max(SpeedValue.Value - entityLibrary.character.Humanoid.WalkSpeed, 0) * delta))
							if SpeedWallCheck.Enabled then
								local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, newpos, SpeedRaycast)
								if ray then newpos = (ray.Position - entityLibrary.character.HumanoidRootPart.Position) end
							end
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + newpos
						elseif SpeedMethod.Value == "TP" then
							if SpeedDelayTick <= tick() then
								SpeedDelayTick = tick() + (SpeedDelay.Value / 10)
								local newpos = (movevec * SpeedValue.Value)
								if SpeedWallCheck.Enabled then
									local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, newpos, SpeedRaycast)
									if ray then newpos = (ray.Position - entityLibrary.character.HumanoidRootPart.Position) end
								end
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + newpos
							end
						elseif SpeedMethod.Value == "Pulse" then
							local pulsenum = (SpeedPulseDuration.Value / 100)
							local newvelo = movevec * (SpeedValue.Value + (entityLibrary.character.Humanoid.WalkSpeed - SpeedValue.Value) * (1 - (math.max(pulsetick - tick(), 0)) / pulsenum))
							entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(newvelo.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, newvelo.Z)
						elseif SpeedMethod.Value == "WalkSpeed" then
							if oldWalkSpeed == nil then
								oldWalkSpeed = entityLibrary.character.Humanoid.WalkSpeed
							end
							entityLibrary.character.Humanoid.WalkSpeed = SpeedValue.Value
						end
						if SpeedJump.Enabled and (SpeedJumpAlways.Enabled or KillauraNearTarget) then
							if (entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air) and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero then
								if SpeedJumpVanilla.Enabled then
									entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
								else
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, SpeedJumpHeight.Value, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								end
							end
						end
					end
				end)
			else
				SpeedDelayTick = 0
				if oldWalkSpeed then
					entityLibrary.character.Humanoid.WalkSpeed = oldWalkSpeed
					oldWalkSpeed = nil
				end
				RunLoops:UnbindFromHeartbeat("Speed")
			end
		end,
		ExtraText = function()
			if rendervape.ObjectsThatCanBeSaved["Text GUIAlternate TextToggle"].Api.Enabled then
				return alternatelist[table.find(SpeedMethod.List, SpeedMethod.Value)]
			end
			return SpeedMethod.Value
		end
	})
	SpeedMethod = Speed.CreateDropdown({
		Name = "Mode",
		List = {"Velocity", "CFrame", "TP", "Pulse", "WalkSpeed"},
		Function = function(val)
			if oldWalkSpeed then
				entityLibrary.character.Humanoid.WalkSpeed = oldWalkSpeed
				oldWalkSpeed = nil
			end
			SpeedDelay.Object.Visible = val == "TP" or val == "Pulse"
			SpeedWallCheck.Object.Visible = val == "CFrame" or val == "TP"
			SpeedPulseDuration.Object.Visible = val == "Pulse"
			SpeedAnimation.Object.Visible = val == "Velocity"
		end
	})
	SpeedMoveMethod = Speed.CreateDropdown({
		Name = "Movement",
		List = {"Manual", "MoveDirection"},
		Function = function(val) end
	})
	SpeedValue = Speed.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 150,
		Function = function(val) end
	})
	SpeedDelay = Speed.CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 50,
		Function = function(val)
			SpeedDelayTick = tick() + (val / 10)
		end,
		Default = 7,
		Double = 10
	})
	SpeedPulseDuration = Speed.CreateSlider({
		Name = "Pulse Duration",
		Min = 1,
		Max = 100,
		Function = void,
		Default = 50,
		Double = 100
	})
	SpeedJump = Speed.CreateToggle({
		Name = "AutoJump",
		Function = function(callback)
			if SpeedJumpHeight.Object then SpeedJumpHeight.Object.Visible = callback end
			if SpeedJumpAlways.Object then
				SpeedJump.Object.ToggleArrow.Visible = callback
				SpeedJumpAlways.Object.Visible = callback
			end
			if SpeedJumpVanilla.Object then SpeedJumpVanilla.Object.Visible = callback end
		end,
		Default = true
	})
	SpeedJumpHeight = Speed.CreateSlider({
		Name = "Jump Height",
		Min = 0,
		Max = 30,
		Default = 25,
		Function = void
	})
	SpeedJumpAlways = Speed.CreateToggle({
		Name = "Always Jump",
		Function = void
	})
	SpeedJumpVanilla = Speed.CreateToggle({
		Name = "Real Jump",
		Function = void
	})
	SpeedWallCheck = Speed.CreateToggle({
		Name = "Wall Check",
		Function = void,
		Default = true
	})
	SpeedAnimation = Speed.CreateToggle({
		Name = "Slowdown Anim",
		Function = void
	})
end)

run(function()
	local SpinBot = {Enabled = false}
	local SpinBotX = {Enabled = false}
	local SpinBotY = {Enabled = false}
	local SpinBotZ = {Enabled = false}
	local SpinBotSpeed = {Value = 1}
	SpinBot = rendervape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "SpinBot",
		Function = function(callback)
			if callback then
				RunLoops:BindToHeartbeat("SpinBot", function()
					if entityLibrary.isAlive then
						local originalRotVelocity = entityLibrary.character.HumanoidRootPart.RotVelocity
						entityLibrary.character.HumanoidRootPart.RotVelocity = Vector3.new(SpinBotX.Enabled and SpinBotSpeed.Value or originalRotVelocity.X, SpinBotY.Enabled and SpinBotSpeed.Value or originalRotVelocity.Y, SpinBotZ.Enabled and SpinBotSpeed.Value or originalRotVelocity.Z)
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("SpinBot")
			end
		end,
		HoverText = "Makes your character spin around in circles (does not work in first person)"
	})
	SpinBotSpeed = SpinBot.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 100,
		Default = 40,
		Function = void
	})
	SpinBotX = SpinBot.CreateToggle({
		Name = "Spin X",
		Function = void
	})
	SpinBotY = SpinBot.CreateToggle({
		Name = "Spin Y",
		Function = void,
		Default = true
	})
	SpinBotZ = SpinBot.CreateToggle({
		Name = "Spin Z",
		Function = void
	})
end)

local GravityChangeTick = tick()
run(function()
	local Gravity = {Enabled = false}
	local GravityValue = {Value = 100}
	local oldGravity
	Gravity = rendervape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Gravity",
		Function = function(callback)
			if callback then
				oldGravity = workspace.Gravity
				workspace.Gravity = GravityValue.Value
				table.insert(Gravity.Connections, workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
					if GravityChangeTick > tick() then return end
					oldGravity = workspace.Gravity
					GravityChangeTick = tick() + 0.1
					workspace.Gravity = GravityValue.Value
				end))
			else
				workspace.Gravity = oldGravity
			end
		end,
		HoverText = "Changes workspace gravity"
	})
	GravityValue = Gravity.CreateSlider({
		Name = "Gravity",
		Min = 0,
		Max = 192,
		Function = function(val)
			if Gravity.Enabled then
				GravityChangeTick = tick() + 0.1
				workspace.Gravity = val
			end
		end,
		Default = 192
	})
end)

run(function()
    local ArrowsFolder = Instance.new("Folder")
    ArrowsFolder.Name = "ArrowsFolder"
    ArrowsFolder.Parent = rendervape.MainGui
    local ArrowsFolderTable = {}
    local ArrowsColor = {Value = 0.44}
    local ArrowsTeammate = {Enabled = true}

    local arrowAddFunction = function(plr)
        if ArrowsTeammate.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
        local arrowObject = Instance.new("ImageLabel")
        arrowObject.BackgroundTransparency = 1
        arrowObject.BorderSizePixel = 0
        arrowObject.Size = UDim2.new(0, 256, 0, 256)
        arrowObject.AnchorPoint = Vector2.new(0.5, 0.5)
        arrowObject.Position = UDim2.new(0.5, 0, 0.5, 0)
        arrowObject.Visible = false
        arrowObject.Image = downloadVapeAsset("rendervape/assets/ArrowIndicator.png")
		arrowObject.ImageColor3 = getPlayerColor(plr.Player) or Color3.fromHSV(ArrowsColor.Hue, ArrowsColor.Sat, ArrowsColor.Value)
        arrowObject.Name = plr.Player.Name
        arrowObject.Parent = ArrowsFolder
        ArrowsFolderTable[plr.Player] = {entity = plr, Main = arrowObject}
    end

    local arrowRemoveFunction = function(ent)
        local v = ArrowsFolderTable[ent]
        ArrowsFolderTable[ent] = nil
        if v then v.Main:Destroy() end
    end

    local arrowColorFunction = function(hue, sat, val)
        local color = Color3.fromHSV(hue, sat, val)
        for i,v in (ArrowsFolderTable) do
            v.Main.ImageColor3 = getPlayerColor(v.entity.Player) or color
        end
    end

    local arrowLoopFunction = function()
        for i,v in (ArrowsFolderTable) do
            local rootPos, rootVis = worldtoscreenpoint(v.entity.RootPart.Position)
            if rootVis then
                v.Main.Visible = false
                continue
            end
            local camcframeflat = CFrame.new(camera.CFrame.p, camera.CFrame.p + camera.CFrame.lookVector * Vector3.new(1, 0, 1))
            local pointRelativeToCamera = camcframeflat:pointToObjectSpace(v.entity.RootPart.Position)
            local unitRelativeVector = (pointRelativeToCamera * Vector3.new(1, 0, 1)).unit
            local rotation = math.atan2(unitRelativeVector.Z, unitRelativeVector.X)
            v.Main.Visible = true
            v.Main.Rotation = math.deg(rotation)
        end
    end

    local Arrows = {Enabled = false}
	Arrows = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
        Name = "Arrows",
        Function = function(callback)
            if callback then
				table.insert(Arrows.Connections, entityLibrary.entityRemovedEvent:Connect(arrowRemoveFunction))
				for i,v in (entityLibrary.entityList) do
                    if ArrowsFolderTable[v.Player] then arrowRemoveFunction(v.Player) end
                    arrowAddFunction(v)
                end
                table.insert(Arrows.Connections, entityLibrary.entityAddedEvent:Connect(function(ent)
                    if ArrowsFolderTable[ent.Player] then arrowRemoveFunction(ent.Player) end
                    arrowAddFunction(ent)
                end))
				table.insert(Arrows.Connections, rendervape.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.FriendColorRefresh.Event:Connect(function()
                    arrowColorFunction(ESPColor.Hue, ESPColor.Sat, ESPColor.Value)
                end))
				RunLoops:BindToRenderStep("Arrows", arrowLoopFunction)
            else
                RunLoops:UnbindFromRenderStep("Arrows")
				for i,v in (ArrowsFolderTable) do
                    arrowRemoveFunction(i)
                end
            end
        end,
        HoverText = "Draws arrows on screen when entities\nare out of your field of view."
    })
    ArrowsColor = Arrows.CreateColorSlider({
        Name = "Player Color",
        Function = function(hue, sat, val)
			if Arrows.Enabled then
				arrowColorFunction(hue, sat, val)
			end
		end,
    })
    ArrowsTeammate = Arrows.CreateToggle({
        Name = "Teammate",
        Function = void,
        Default = true
    })
end)


run(function()
	local Disguise = {Enabled = false}
	local DisguiseId = {Value = ""}
	local DisguiseDescription

	local function Disguisechar(char)
		task.spawn(function()
			if not char then return end
			local hum = char:WaitForChild("Humanoid", 9e9)
			char:WaitForChild("Head", 9e9)
			local DisguiseDescription
			if DisguiseDescription == nil then
				local suc = false
				repeat
					suc = pcall(function()
						DisguiseDescription = players:GetHumanoidDescriptionFromUserId(DisguiseId.Value == "" and 239702688 or tonumber(DisguiseId.Value))
					end)
					if suc then break end
					task.wait(1)
				until suc or (not Disguise.Enabled)
			end
			if (not Disguise.Enabled) then return end
			local desc = hum:WaitForChild("HumanoidDescription", 2) or {HeightScale = 1, SetEmotes = function() end, SetEquippedEmotes = function() end}
			DisguiseDescription.HeightScale = desc.HeightScale
			char.Archivable = true
			local Disguiseclone = char:Clone()
			Disguiseclone.Name = "Disguisechar"
			Disguiseclone.Parent = workspace
			for i,v in (Disguiseclone:GetChildren()) do
				if v:IsA("Accessory") or v:IsA("ShirtGraphic") or v:IsA("Shirt") or v:IsA("Pants") then
					v:Destroy()
				end
			end
			if not Disguiseclone:FindFirstChildWhichIsA("Humanoid") then
				Disguiseclone:Destroy()
				return
			end
			Disguiseclone.Humanoid:ApplyDescriptionClientServer(DisguiseDescription)
			for i,v in (char:GetChildren()) do
				if (v:IsA("Accessory") and v:GetAttribute("InvItem") == nil and v:GetAttribute("ArmorSlot") == nil) or v:IsA("ShirtGraphic") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") or v:IsA("Folder") or v:IsA("Model") then
					v.Parent = game
				end
			end
			char.ChildAdded:Connect(function(v)
				if ((v:IsA("Accessory") and v:GetAttribute("InvItem") == nil and v:GetAttribute("ArmorSlot") == nil) or v:IsA("ShirtGraphic") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors")) and v:GetAttribute("Disguise") == nil then
					repeat task.wait() v.Parent = game until v.Parent == game
				end
			end)
			for i,v in (Disguiseclone:WaitForChild("Animate"):GetChildren()) do
				v:SetAttribute("Disguise", true)
				if not char:FindFirstChild("Animate") then return end
				local real = char.Animate:FindFirstChild(v.Name)
				if v:IsA("StringValue") and real then
					real.Parent = game
					v.Parent = char.Animate
				end
			end
			for i,v in (Disguiseclone:GetChildren()) do
				v:SetAttribute("Disguise", true)
				if v:IsA("Accessory") then
					for i2,v2 in (v:GetDescendants()) do
						if v2:IsA("Weld") and v2.Part1 then
							v2.Part1 = char[v2.Part1.Name]
						end
					end
					v.Parent = char
				elseif v:IsA("ShirtGraphic") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
					v.Parent = char
				elseif v.Name == "Head" and char.Head:IsA("MeshPart") then
					char.Head.MeshId = v.MeshId
				end
			end
			local localface = char:FindFirstChild("face", true)
			local cloneface = Disguiseclone:FindFirstChild("face", true)
			if localface and cloneface then localface.Parent = game cloneface.Parent = char.Head end
			desc:SetEmotes(DisguiseDescription:GetEmotes())
			desc:SetEquippedEmotes(DisguiseDescription:GetEquippedEmotes())
			Disguiseclone:Destroy()
		end)
	end

	Disguise = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "Disguise",
		Function = function(callback)
			if callback then
				table.insert(Disguise.Connections, lplr.CharacterAdded:Connect(Disguisechar))
				Disguisechar(lplr.Character)
			end
		end
	})
	DisguiseId = Disguise.CreateTextBox({
		Name = "Disguise",
		TempText = "Disguise User Id",
		FocusLost = function(enter)
			Disguise:retoggle()
		end
	})
end)

run(function()
	local ESPColor = {Value = 0.44}
	local ESPHealthBar = {Enabled = false}
	local ESPBoundingBox = {Enabled = true}
	local ESPName = {Enabled = true}
	local ESPMethod = {Value = "2D"}
	local ESPTeammates = {Enabled = true}
	local espfolderdrawing = {}
	local espconnections = {}
	local methodused

	local function floorESPPosition(pos)
		return Vector2.new(math.floor(pos.X), math.floor(pos.Y))
	end

	local function ESPWorldToViewport(pos)
		local newpos = worldtoviewportpoint(camera.CFrame:pointToWorldSpace(camera.CFrame:pointToObjectSpace(pos)))
		return Vector2.new(newpos.X, newpos.Y)
	end

	local espfuncs1 = {
		Drawing2D = function(plr)
			if ESPTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = {}
			thing.Quad1 = Drawing.new("Square")
			thing.Quad1.Transparency = ESPBoundingBox.Enabled and 1 or 0
			thing.Quad1.ZIndex = 2
			thing.Quad1.Filled = false
			thing.Quad1.Thickness = 1
			thing.Quad1.Color = getPlayerColor(plr.Player) or Color3.fromHSV(ESPColor.Hue, ESPColor.Sat, ESPColor.Value)
			thing.QuadLine2 = Drawing.new("Square")
			thing.QuadLine2.Transparency = ESPBoundingBox.Enabled and 0.5 or 0
			thing.QuadLine2.ZIndex = 1
			thing.QuadLine2.Thickness = 1
			thing.QuadLine2.Filled = false
			thing.QuadLine2.Color = Color3.new()
			thing.QuadLine3 = Drawing.new("Square")
			thing.QuadLine3.Transparency = ESPBoundingBox.Enabled and 0.5 or 0
			thing.QuadLine3.ZIndex = 1
			thing.QuadLine3.Thickness = 1
			thing.QuadLine3.Filled = false
			thing.QuadLine3.Color = Color3.new()
			if ESPHealthBar.Enabled then
				thing.Quad3 = Drawing.new("Line")
				thing.Quad3.Thickness = 1
				thing.Quad3.ZIndex = 2
				thing.Quad3.Color = Color3.new(0, 1, 0)
				thing.Quad4 = Drawing.new("Line")
				thing.Quad4.Thickness = 3
				thing.Quad4.Transparency = 0.5
				thing.Quad4.ZIndex = 1
				thing.Quad4.Color = Color3.new()
			end
			if ESPName.Enabled then
				thing.Drop = Drawing.new("Text")
				thing.Drop.Color = Color3.new()
				thing.Drop.Text = whitelist:tag(plr.Player, true)..(plr.Player.DisplayName or plr.Player.Name)
				thing.Drop.ZIndex = 1
				thing.Drop.Center = true
				thing.Drop.Size = 20
				thing.Text = Drawing.new("Text")
				thing.Text.Text = thing.Drop.Text
				thing.Text.ZIndex = 2
				thing.Text.Color = thing.Quad1.Color
				thing.Text.Center = true
				thing.Text.Size = 20
			end
			espfolderdrawing[plr.Player] = {entity = plr, Main = thing}
		end,
		Drawing2DV3 = function(plr)
			if ESPTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local toppoint = PointInstance.new(plr.RootPart, CFrame.new(2, 3, 0))
			local bottompoint = PointInstance.new(plr.RootPart, CFrame.new(-2, -3.5, 0))
			local newobj = RectDynamic.new(toppoint)
			newobj.BottomRight = bottompoint
			newobj.Outlined = ESPBoundingBox.Enabled
			newobj.Opacity = ESPBoundingBox.Enabled and 1 or 0
			newobj.OutlineOpacity = 0.5
			newobj.Color = getPlayerColor(plr.Player) or Color3.fromHSV(ESPColor.Hue, ESPColor.Sat, ESPColor.Value)
			local newobj2 = {}
			local newobj3 = {}
			if ESPHealthBar.Enabled then
				local topoffset = PointOffset.new(PointInstance.new(plr.RootPart, CFrame.new(-2, 3, 0)), Vector2.new(-5, -1))
				local bottomoffset = PointOffset.new(PointInstance.new(plr.RootPart, CFrame.new(-2, -3.5, 0)), Vector2.new(-3, 1))
				local healthoffset = PointOffset.new(bottomoffset, Vector2.new(0, -1))
				local healthoffset2 = PointOffset.new(bottomoffset, Vector2.new(-1, -((bottomoffset.ScreenPos.Y - topoffset.ScreenPos.Y) - 1)))
				newobj2.Bkg = RectDynamic.new(topoffset)
				newobj2.Bkg.Filled = true
				newobj2.Bkg.Opacity = 0.5
				newobj2.Bkg.BottomRight = bottomoffset
				newobj2.Line = RectDynamic.new(healthoffset)
				newobj2.Line.Filled = true
				newobj2.Line.YAlignment = YAlignment.Bottom
				newobj2.Line.BottomRight = healthoffset2
				newobj2.Line.Color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				newobj2.Offset = healthoffset2
				newobj2.TopOffset = topoffset
				newobj2.BottomOffset = bottomoffset
			end
			if ESPName.Enabled then
				local nameoffset1 = PointOffset.new(PointInstance.new(plr.RootPart, CFrame.new(0, 3, 0)), Vector2.new(0, -15))
				local nameoffset2 = PointOffset.new(nameoffset1, Vector2.new(1, 1))
				newobj3.Text = TextDynamic.new(nameoffset1)
				newobj3.Text.Text = whitelist:tag(plr.Player, true)..(plr.Player.DisplayName or plr.Player.Name)
				newobj3.Text.Color = newobj.Color
				newobj3.Text.ZIndex = 2
				newobj3.Text.Size = 20
				newobj3.Drop = TextDynamic.new(nameoffset2)
				newobj3.Drop.Text = newobj3.Text.Text
				newobj3.Drop.Color = Color3.new()
				newobj3.Drop.ZIndex = 1
				newobj3.Drop.Size = 20
			end
			espfolderdrawing[plr.Player] = {entity = plr, Main = newobj, HealthBar = newobj2, Name = newobj3}
		end,
		DrawingSkeleton = function(plr)
			if ESPTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = {}
			thing.Head = Drawing.new("Line")
			thing.Head2 = Drawing.new("Line")
			thing.Torso = Drawing.new("Line")
			thing.Torso2 = Drawing.new("Line")
			thing.Torso3 = Drawing.new("Line")
			thing.LeftArm = Drawing.new("Line")
			thing.RightArm = Drawing.new("Line")
			thing.LeftLeg = Drawing.new("Line")
			thing.RightLeg = Drawing.new("Line")
			local color = getPlayerColor(plr.Player) or Color3.fromHSV(ESPColor.Hue, ESPColor.Sat, ESPColor.Value)
			for i,v in (thing) do v.Thickness = 2 v.Color = color end
			espfolderdrawing[plr.Player] = {entity = plr, Main = thing}
		end,
		DrawingSkeletonV3 = function(plr)
			if ESPTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = {Main = {}, entity = plr}
			local rigcheck = plr.Humanoid.RigType == Enum.HumanoidRigType.R6
			local head = PointInstance.new(plr.Head)
			head.RotationType = CFrameRotationType.TargetRelative
			local headfront = PointInstance.new(plr.Head, CFrame.new(0, 0, -0.5))
			headfront.RotationType = CFrameRotationType.TargetRelative
			local toplefttorso = PointInstance.new(plr.Character[(rigcheck and "Torso" or "UpperTorso")], CFrame.new(-1.5, 0.8, 0))
			toplefttorso.RotationType = CFrameRotationType.TargetRelative
			local toprighttorso = PointInstance.new(plr.Character[(rigcheck and "Torso" or "UpperTorso")], CFrame.new(1.5, 0.8, 0))
			toprighttorso.RotationType = CFrameRotationType.TargetRelative
			local toptorso = PointInstance.new(plr.Character[(rigcheck and "Torso" or "UpperTorso")], CFrame.new(0, 0.8, 0))
			toptorso.RotationType = CFrameRotationType.TargetRelative
			local bottomtorso = PointInstance.new(plr.Character[(rigcheck and "Torso" or "UpperTorso")], CFrame.new(0, -0.8, 0))
			bottomtorso.RotationType = CFrameRotationType.TargetRelative
			local bottomlefttorso = PointInstance.new(plr.Character[(rigcheck and "Torso" or "UpperTorso")], CFrame.new(-0.5, -0.8, 0))
			bottomlefttorso.RotationType = CFrameRotationType.TargetRelative
			local bottomrighttorso = PointInstance.new(plr.Character[(rigcheck and "Torso" or "UpperTorso")], CFrame.new(0.5, -0.8, 0))
			bottomrighttorso.RotationType = CFrameRotationType.TargetRelative
			local leftarm = PointInstance.new(plr.Character[(rigcheck and "Left Arm" or "LeftHand")], CFrame.new(0, -0.8, 0))
			leftarm.RotationType = CFrameRotationType.TargetRelative
			local rightarm = PointInstance.new(plr.Character[(rigcheck and "Right Arm" or "RightHand")], CFrame.new(0, -0.8, 0))
			rightarm.RotationType = CFrameRotationType.TargetRelative
			local leftleg = PointInstance.new(plr.Character[(rigcheck and "Left Leg" or "LeftFoot")], CFrame.new(0, -0.8, 0))
			leftleg.RotationType = CFrameRotationType.TargetRelative
			local rightleg = PointInstance.new(plr.Character[(rigcheck and "Right Leg" or "RightFoot")], CFrame.new(0, -0.8, 0))
			rightleg.RotationType = CFrameRotationType.TargetRelative
			thing.Main.Head = LineDynamic.new(toptorso, head)
			thing.Main.Head2 = LineDynamic.new(head, headfront)
			thing.Main.Torso = LineDynamic.new(toplefttorso, toprighttorso)
			thing.Main.Torso2 = LineDynamic.new(toptorso, bottomtorso)
			thing.Main.Torso3 = LineDynamic.new(bottomlefttorso, bottomrighttorso)
			thing.Main.LeftArm = LineDynamic.new(toplefttorso, leftarm)
			thing.Main.RightArm = LineDynamic.new(toprighttorso, rightarm)
			thing.Main.LeftLeg = LineDynamic.new(bottomlefttorso, leftleg)
			thing.Main.RightLeg = LineDynamic.new(bottomrighttorso, rightleg)
			local color = getPlayerColor(plr.Player) or Color3.fromHSV(ESPColor.Hue, ESPColor.Sat, ESPColor.Value)
			for i,v in (thing.Main) do v.Thickness = 2 v.Color = color end
			espfolderdrawing[plr.Player] = thing
		end,
		Drawing3D = function(plr)
			if ESPTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = {}
			thing.Line1 = Drawing.new("Line")
			thing.Line2 = Drawing.new("Line")
			thing.Line3 = Drawing.new("Line")
			thing.Line4 = Drawing.new("Line")
			thing.Line5 = Drawing.new("Line")
			thing.Line6 = Drawing.new("Line")
			thing.Line7 = Drawing.new("Line")
			thing.Line8 = Drawing.new("Line")
			thing.Line9 = Drawing.new("Line")
			thing.Line10 = Drawing.new("Line")
			thing.Line11 = Drawing.new("Line")
			thing.Line12 = Drawing.new("Line")
			local color = getPlayerColor(plr.Player) or Color3.fromHSV(ESPColor.Hue, ESPColor.Sat, ESPColor.Value)
			for i,v in (thing) do v.Thickness = 1 v.Color = color end
			espfolderdrawing[plr.Player] = {entity = plr, Main = thing}
		end,
		Drawing3DV3 = function(plr)
			if ESPTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = {}
			local point1 = PointInstance.new(plr.RootPart, CFrame.new(1.5, 3, 1.5))
			point1.RotationType = CFrameRotationType.Ignore
			local point2 = PointInstance.new(plr.RootPart, CFrame.new(1.5, -3, 1.5))
			point2.RotationType = CFrameRotationType.Ignore
			local point3 = PointInstance.new(plr.RootPart, CFrame.new(-1.5, 3, 1.5))
			point3.RotationType = CFrameRotationType.Ignore
			local point4 = PointInstance.new(plr.RootPart, CFrame.new(-1.5, -3, 1.5))
			point4.RotationType = CFrameRotationType.Ignore
			local point5 = PointInstance.new(plr.RootPart, CFrame.new(1.5, 3, -1.5))
			point5.RotationType = CFrameRotationType.Ignore
			local point6 = PointInstance.new(plr.RootPart, CFrame.new(1.5, -3, -1.5))
			point6.RotationType = CFrameRotationType.Ignore
			local point7 = PointInstance.new(plr.RootPart, CFrame.new(-1.5, 3, -1.5))
			point7.RotationType = CFrameRotationType.Ignore
			local point8 = PointInstance.new(plr.RootPart, CFrame.new(-1.5, -3, -1.5))
			point8.RotationType = CFrameRotationType.Ignore
			thing.Line1 = LineDynamic.new(point1, point2)
			thing.Line2 = LineDynamic.new(point3, point4)
			thing.Line3 = LineDynamic.new(point5, point6)
			thing.Line4 = LineDynamic.new(point7, point8)
			thing.Line5 = LineDynamic.new(point1, point3)
			thing.Line6 = LineDynamic.new(point1, point5)
			thing.Line7 = LineDynamic.new(point5, point7)
			thing.Line8 = LineDynamic.new(point7, point3)
			thing.Line9 = LineDynamic.new(point2, point4)
			thing.Line10 = LineDynamic.new(point2, point6)
			thing.Line11 = LineDynamic.new(point6, point8)
			thing.Line12 = LineDynamic.new(point8, point4)
			local color = getPlayerColor(plr.Player) or Color3.fromHSV(ESPColor.Hue, ESPColor.Sat, ESPColor.Value)
			for i,v in (thing) do v.Thickness = 1 v.Color = color end
			espfolderdrawing[plr.Player] = {entity = plr, Main = thing}
		end
	}
	local espfuncs2 = {
		Drawing2D = function(ent)
			local v = espfolderdrawing[ent]
			espfolderdrawing[ent] = nil
			if v then
				for i2,v2 in (v.Main) do
					pcall(function() v2.Visible = false v2:Remove() end)
				end
			end
		end,
		Drawing2DV3 = function(ent)
			local v = espfolderdrawing[ent]
			espfolderdrawing[ent] = nil
			if v then
				v.Main.Visible = false
				for i2,v2 in (v.HealthBar) do
					if typeof(v2):find("Point") == nil then
						v2.Visible = false
					end
				end
				for i2,v2 in (v.Name) do
					if typeof(v2):find("Point") == nil then
						v2.Visible = false
					end
				end
			end
		end,
		Drawing3D = function(ent)
			local v = espfolderdrawing[ent]
			espfolderdrawing[ent] = nil
			if v then
				for i2,v2 in (v.Main) do
					pcall(function() v2.Visible = false v2:Remove() end)
				end
			end
		end,
		Drawing3DV3 = function(ent)
			local v = espfolderdrawing[ent]
			espfolderdrawing[ent] = nil
			if v then
				for i2,v2 in (v.Main) do
					if typeof(v2):find("Dynamic") then
						v2.Visible = false
					end
				end
			end
		end,
		DrawingSkeleton = function(ent)
			local v = espfolderdrawing[ent]
			espfolderdrawing[ent] = nil
			if v then
				for i2,v2 in (v.Main) do
					pcall(function() v2.Visible = false v2:Remove() end)
				end
			end
		end,
		DrawingSkeletonV3 = function(ent)
			local v = espfolderdrawing[ent]
			espfolderdrawing[ent] = nil
			if v then
				for i2,v2 in (v.Main) do
					if typeof(v2):find("Dynamic") then
						v2.Visible = false
					end
				end
			end
		end
	}
	local espupdatefuncs = {
		Drawing2D = function(ent)
			local v = espfolderdrawing[ent.Player]
			if v and v.Main.Quad3 then
				local color = Color3.fromHSV(math.clamp(ent.Humanoid.Health / ent.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				v.Main.Quad3.Color = color
			end
			if v and v.Text then
				v.Text.Text = whitelist:tag(ent.Player, true)..(ent.Player.DisplayName or ent.Player.Name)
				v.Drop.Text = v.Text.Text
			end
		end,
		Drawing2DV3 = function(ent)
			local v = espfolderdrawing[ent.Player]
			if v and v.HealthBar.Line then
				local health = ent.Humanoid.Health / ent.Humanoid.MaxHealth
				local color = Color3.fromHSV(math.clamp(health, 0, 1) / 2.5, 0.89, 1)
				v.HealthBar.Line.Color = color
			end
			if v and v.Name and v.Name.Text then
				v.Name.Text.Text = whitelist:tag(ent.Player, true)..(ent.Player.DisplayName or ent.Player.Name)
				v.Name.Drop.Text = v.Name.Text.Text
			end
		end
	}
	local espcolorfuncs = {
		Drawing2D = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in (espfolderdrawing) do
				v.Main.Quad1.Color = getPlayerColor(v.entity.Player) or color
				if v.Main.Text then
					v.Main.Text.Color = v.Main.Quad1.Color
				end
			end
		end,
		Drawing2DV3 = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in (espfolderdrawing) do
				v.Main.Color = getPlayerColor(v.entity.Player) or color
				if v.Name.Text then
					v.Name.Text.Color = v.Main.Color
				end
			end
		end,
		Drawing3D = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in (espfolderdrawing) do
				local newcolor = getPlayerColor(v.entity.Player) or color
				for i2,v2 in (v.Main) do
					v2.Color = newcolor
				end
			end
		end,
		Drawing3DV3 = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in (espfolderdrawing) do
				local newcolor = getPlayerColor(v.entity.Player) or color
				for i2,v2 in (v.Main) do
					if typeof(v2):find("Dynamic") then
						v2.Color = newcolor
					end
				end
			end
		end,
		DrawingSkeleton = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in (espfolderdrawing) do
				local newcolor = getPlayerColor(v.entity.Player) or color
				for i2,v2 in (v.Main) do
					v2.Color = newcolor
				end
			end
		end,
		DrawingSkeletonV3 = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in (espfolderdrawing) do
				local newcolor = getPlayerColor(v.entity.Player) or color
				for i2,v2 in (v.Main) do
					if typeof(v2):find("Dynamic") then
						v2.Color = newcolor
					end
				end
			end
		end,
	}
	local esploop = {
		Drawing2D = function()
			for i,v in (espfolderdrawing) do
				local rootPos, rootVis = worldtoviewportpoint(v.entity.RootPart.Position)
				if not rootVis then
					v.Main.Quad1.Visible = false
					v.Main.QuadLine2.Visible = false
					v.Main.QuadLine3.Visible = false
					if v.Main.Quad3 then
						v.Main.Quad3.Visible = false
						v.Main.Quad4.Visible = false
					end
					if v.Main.Text then
						v.Main.Text.Visible = false
						v.Main.Drop.Visible = false
					end
					continue
				end
				local topPos, topVis = worldtoviewportpoint((CFrame.new(v.entity.RootPart.Position, v.entity.RootPart.Position + camera.CFrame.lookVector) * CFrame.new(2, 3, 0)).p)
				local bottomPos, bottomVis = worldtoviewportpoint((CFrame.new(v.entity.RootPart.Position, v.entity.RootPart.Position + camera.CFrame.lookVector) * CFrame.new(-2, -3.5, 0)).p)
				local sizex, sizey = topPos.X - bottomPos.X, topPos.Y - bottomPos.Y
				local posx, posy = (rootPos.X - sizex / 2),  ((rootPos.Y - sizey / 2))
				v.Main.Quad1.Position = floorESPPosition(Vector2.new(posx, posy))
				v.Main.Quad1.Size = floorESPPosition(Vector2.new(sizex, sizey))
				v.Main.Quad1.Visible = true
				v.Main.QuadLine2.Position = floorESPPosition(Vector2.new(posx - 1, posy + 1))
				v.Main.QuadLine2.Size = floorESPPosition(Vector2.new(sizex + 2, sizey - 2))
				v.Main.QuadLine2.Visible = true
				v.Main.QuadLine3.Position = floorESPPosition(Vector2.new(posx + 1, posy - 1))
				v.Main.QuadLine3.Size = floorESPPosition(Vector2.new(sizex - 2, sizey + 2))
				v.Main.QuadLine3.Visible = true
				if v.Main.Quad3 then
					local healthposy = sizey * math.clamp(v.entity.Humanoid.Health / v.entity.Humanoid.MaxHealth, 0, 1)
					v.Main.Quad3.Visible = v.entity.Humanoid.Health > 0
					v.Main.Quad3.From = floorESPPosition(Vector2.new(posx - 4, posy + (sizey - (sizey - healthposy))))
					v.Main.Quad3.To = floorESPPosition(Vector2.new(posx - 4, posy))
					v.Main.Quad4.Visible = true
					v.Main.Quad4.From = floorESPPosition(Vector2.new(posx - 4, posy))
					v.Main.Quad4.To = floorESPPosition(Vector2.new(posx - 4, (posy + sizey)))
				end
				if v.Main.Text then
					v.Main.Text.Visible = true
					v.Main.Drop.Visible = true
					v.Main.Text.Position = floorESPPosition(Vector2.new(posx + (sizex / 2), posy + (sizey - 25)))
					v.Main.Drop.Position = v.Main.Text.Position + Vector2.new(1, 1)
				end
			end
		end,
		Drawing2DV3 = function()
			for i,v in (espfolderdrawing) do
				if v.HealthBar.Offset then
					v.HealthBar.Offset.Offset = Vector2.new(-1, -(((v.HealthBar.BottomOffset.ScreenPos.Y - v.HealthBar.TopOffset.ScreenPos.Y) - 1) * (v.entity.Humanoid.Health / v.entity.Humanoid.MaxHealth)))
					v.HealthBar.Line.Visible = v.entity.Humanoid.Health > 0
				end
			end
		end,
		Drawing3D = function()
			for i,v in (espfolderdrawing) do
				local rootPos, rootVis = worldtoviewportpoint(v.entity.RootPart.Position)
				if not rootVis then
					for i,v in (v.Main) do
						v.Visible = false
					end
					continue
				end
				for i,v in (v.Main) do
					v.Visible = true
				end
				local point1 = ESPWorldToViewport(v.entity.RootPart.Position + Vector3.new(1.5, 3, 1.5))
				local point2 = ESPWorldToViewport(v.entity.RootPart.Position + Vector3.new(1.5, -3, 1.5))
				local point3 = ESPWorldToViewport(v.entity.RootPart.Position + Vector3.new(-1.5, 3, 1.5))
				local point4 = ESPWorldToViewport(v.entity.RootPart.Position + Vector3.new(-1.5, -3, 1.5))
				local point5 = ESPWorldToViewport(v.entity.RootPart.Position + Vector3.new(1.5, 3, -1.5))
				local point6 = ESPWorldToViewport(v.entity.RootPart.Position + Vector3.new(1.5, -3, -1.5))
				local point7 = ESPWorldToViewport(v.entity.RootPart.Position + Vector3.new(-1.5, 3, -1.5))
				local point8 = ESPWorldToViewport(v.entity.RootPart.Position + Vector3.new(-1.5, -3, -1.5))
				v.Main.Line1.From = point1
				v.Main.Line1.To = point2
				v.Main.Line2.From = point3
				v.Main.Line2.To = point4
				v.Main.Line3.From = point5
				v.Main.Line3.To = point6
				v.Main.Line4.From = point7
				v.Main.Line4.To = point8
				v.Main.Line5.From = point1
				v.Main.Line5.To = point3
				v.Main.Line6.From = point1
				v.Main.Line6.To = point5
				v.Main.Line7.From = point5
				v.Main.Line7.To = point7
				v.Main.Line8.From = point7
				v.Main.Line8.To = point3
				v.Main.Line9.From = point2
				v.Main.Line9.To = point4
				v.Main.Line10.From = point2
				v.Main.Line10.To = point6
				v.Main.Line11.From = point6
				v.Main.Line11.To = point8
				v.Main.Line12.From = point8
				v.Main.Line12.To = point4
			end
		end,
		DrawingSkeleton = function()
			for i,v in (espfolderdrawing) do
				local rootPos, rootVis = worldtoviewportpoint(v.entity.RootPart.Position)
				if not rootVis then
					for i,v in (v.Main) do
						v.Visible = false
					end
					continue
				end
				for i,v in (v.Main) do
					v.Visible = true
				end
				local rigcheck = v.entity.Humanoid.RigType == Enum.HumanoidRigType.R6
				local head = ESPWorldToViewport((v.entity.Head.CFrame).p)
				local headfront = ESPWorldToViewport((v.entity.Head.CFrame * CFrame.new(0, 0, -0.5)).p)
				local toplefttorso = ESPWorldToViewport((v.entity.Character[(rigcheck and "Torso" or "UpperTorso")].CFrame * CFrame.new(-1.5, 0.8, 0)).p)
				local toprighttorso = ESPWorldToViewport((v.entity.Character[(rigcheck and "Torso" or "UpperTorso")].CFrame * CFrame.new(1.5, 0.8, 0)).p)
				local toptorso = ESPWorldToViewport((v.entity.Character[(rigcheck and "Torso" or "UpperTorso")].CFrame * CFrame.new(0, 0.8, 0)).p)
				local bottomtorso = ESPWorldToViewport((v.entity.Character[(rigcheck and "Torso" or "UpperTorso")].CFrame * CFrame.new(0, -0.8, 0)).p)
				local bottomlefttorso = ESPWorldToViewport((v.entity.Character[(rigcheck and "Torso" or "UpperTorso")].CFrame * CFrame.new(-0.5, -0.8, 0)).p)
				local bottomrighttorso = ESPWorldToViewport((v.entity.Character[(rigcheck and "Torso" or "UpperTorso")].CFrame * CFrame.new(0.5, -0.8, 0)).p)
				local leftarm = ESPWorldToViewport((v.entity.Character[(rigcheck and "Left Arm" or "LeftHand")].CFrame * CFrame.new(0, -0.8, 0)).p)
				local rightarm = ESPWorldToViewport((v.entity.Character[(rigcheck and "Right Arm" or "RightHand")].CFrame * CFrame.new(0, -0.8, 0)).p)
				local leftleg = ESPWorldToViewport((v.entity.Character[(rigcheck and "Left Leg" or "LeftFoot")].CFrame * CFrame.new(0, -0.8, 0)).p)
				local rightleg = ESPWorldToViewport((v.entity.Character[(rigcheck and "Right Leg" or "RightFoot")].CFrame * CFrame.new(0, -0.8, 0)).p)
				v.Main.Torso.From = toplefttorso
				v.Main.Torso.To = toprighttorso
				v.Main.Torso2.From = toptorso
				v.Main.Torso2.To = bottomtorso
				v.Main.Torso3.From = bottomlefttorso
				v.Main.Torso3.To = bottomrighttorso
				v.Main.LeftArm.From = toplefttorso
				v.Main.LeftArm.To = leftarm
				v.Main.RightArm.From = toprighttorso
				v.Main.RightArm.To = rightarm
				v.Main.LeftLeg.From = bottomlefttorso
				v.Main.LeftLeg.To = leftleg
				v.Main.RightLeg.From = bottomrighttorso
				v.Main.RightLeg.To = rightleg
				v.Main.Head.From = toptorso
				v.Main.Head.To = head
				v.Main.Head2.From = head
				v.Main.Head2.To = headfront
			end
		end
	}

	local ESP = {Enabled = false}
	ESP = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "ESP",
		Function = function(callback)
			if callback then
				methodused = "Drawing"..ESPMethod.Value..synapsev3
				if espfuncs2[methodused] then
					table.insert(ESP.Connections, entityLibrary.entityRemovedEvent:Connect(espfuncs2[methodused]))
				end
				if espfuncs1[methodused] then
					local addfunc = espfuncs1[methodused]
					for i,v in (entityLibrary.entityList) do
						if espfolderdrawing[v.Player] then espfuncs2[methodused](v.Player) end
						addfunc(v)
					end
					table.insert(ESP.Connections, entityLibrary.entityAddedEvent:Connect(function(ent)
						if espfolderdrawing[ent.Player] then espfuncs2[methodused](ent.Player) end
						addfunc(ent)
					end))
				end
				if espupdatefuncs[methodused] then
					table.insert(ESP.Connections, entityLibrary.entityUpdatedEvent:Connect(espupdatefuncs[methodused]))
					for i,v in (entityLibrary.entityList) do
						espupdatefuncs[methodused](v)
					end
				end
				if espcolorfuncs[methodused] then
					table.insert(ESP.Connections, rendervape.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.FriendColorRefresh.Event:Connect(function()
						espcolorfuncs[methodused](ESPColor.Hue, ESPColor.Sat, ESPColor.Value)
					end))
				end
				if esploop[methodused] then
					RunLoops:BindToRenderStep("ESP", esploop[methodused])
				end
			else
				RunLoops:UnbindFromRenderStep("ESP")
				if espfuncs2[methodused] then
					for i,v in (espfolderdrawing) do
						espfuncs2[methodused](i)
					end
				end
			end
		end,
		HoverText = "Extra Sensory Perception\nRenders an ESP on players."
	})
	ESPColor = ESP.CreateColorSlider({
		Name = "Player Color",
		Function = function(hue, sat, val)
			if ESP.Enabled and espcolorfuncs[methodused] then
				espcolorfuncs[methodused](hue, sat, val)
			end
		end
	})
	ESPMethod = ESP.CreateDropdown({
		Name = "Mode",
		List = {"2D", "3D", "Skeleton"},
		Function = function(val)
			if ESP.Enabled then ESP.ToggleButton(true) ESP.ToggleButton(true) end
			ESPBoundingBox.Object.Visible = (val == "2D")
			ESPHealthBar.Object.Visible = (val == "2D")
			ESPName.Object.Visible = (val == "2D")
		end,
	})
	ESPBoundingBox = ESP.CreateToggle({
		Name = "Bounding Box",
		Function = function() if ESP.Enabled then ESP.ToggleButton(true) ESP.ToggleButton(true) end end,
		Default = true
	})
	ESPTeammates = ESP.CreateToggle({
		Name = "Priority Only",
		Function = function() if ESP.Enabled then ESP.ToggleButton(true) ESP.ToggleButton(true) end end,
		Default = true
	})
	ESPHealthBar = ESP.CreateToggle({
		Name = "Health Bar",
		Function = function(callback) if ESP.Enabled then ESP.ToggleButton(true) ESP.ToggleButton(true) end end
	})
	ESPName = ESP.CreateToggle({
		Name = "Name",
		Function = function(callback) if ESP.Enabled then ESP.ToggleButton(true) ESP.ToggleButton(true) end end
	})
end)


run(function()
	local ChamsFolder = Instance.new("Folder")
	ChamsFolder.Name = "ChamsFolder"
	ChamsFolder.Parent = rendervape.MainGui
	local chamstable = {}
	local ChamsColor = {Value = 0.44}
	local ChamsOutlineColor = {Value = 0.44}
	local ChamsTransparency = {Value = 1}
	local ChamsOutlineTransparency = {Value = 1}
	local ChamsOnTop = {Enabled = true}
	local ChamsTeammates = {Enabled = true}

	local function addfunc(ent)
		local chamfolder = Instance.new("Highlight")
		chamfolder.Name = ent.Player.Name
		chamfolder.Enabled = true
		chamfolder.Adornee = ent.Character
		chamfolder.OutlineTransparency = ChamsOutlineTransparency.Value / 100
		chamfolder.DepthMode = Enum.HighlightDepthMode[(ChamsOnTop.Enabled and "AlwaysOnTop" or "Occluded")]
		chamfolder.FillColor = getPlayerColor(ent.Player) or Color3.fromHSV(ChamsColor.Hue, ChamsColor.Sat, ChamsColor.Value)
		chamfolder.OutlineColor = getPlayerColor(ent.Player) or Color3.fromHSV(ChamsOutlineColor.Hue, ChamsOutlineColor.Sat, ChamsOutlineColor.Value)
		chamfolder.FillTransparency = ChamsTransparency.Value / 100
		chamfolder.Parent = ChamsFolder
		chamstable[ent.Player] = {Main = chamfolder, entity = ent}
	end

	local function removefunc(ent)
		local v = chamstable[ent]
		chamstable[ent] = nil
		if v then
			v.Main:Destroy()
		end
	end

	local Chams = {Enabled = false}
	Chams = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "Chams",
		Function = function(callback)
			if callback then
				table.insert(Chams.Connections, entityLibrary.entityRemovedEvent:Connect(removefunc))
				for i,v in (entityLibrary.entityList) do
					if chamstable[v.Player] then removefunc(v.Player) end
					addfunc(v)
				end
				table.insert(Chams.Connections, entityLibrary.entityAddedEvent:Connect(function(ent)
					if chamstable[ent.Player] then removefunc(ent.Player) end
					addfunc(ent)
				end))
				table.insert(Chams.Connections, rendervape.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.FriendColorRefresh.Event:Connect(function()
					for i,v in (chamstable) do
						v.Main.FillColor = getPlayerColor(i) or Color3.fromHSV(ChamsColor.Hue, ChamsColor.Sat, ChamsColor.Value)
						v.Main.OutlineColor = getPlayerColor(i) or Color3.fromHSV(ChamsOutlineColor.Hue, ChamsOutlineColor.Sat, ChamsOutlineColor.Value)
					end
				end))
			else
				for i,v in (chamstable) do
					removefunc(i)
				end
			end
		end,
		HoverText = "Render players through walls"
	})
	ChamsColor = Chams.CreateColorSlider({
		Name = "Player Color",
		Function = function(val)
			for i,v in (chamstable) do
				v.Main.FillColor = getPlayerColor(i) or Color3.fromHSV(ChamsColor.Hue, ChamsColor.Sat, ChamsColor.Value)
			end
		end
	})
	ChamsOutlineColor = Chams.CreateColorSlider({
		Name = "Outline Player Color",
		Function = function(val)
			for i,v in (chamstable) do
				v.Main.OutlineColor = getPlayerColor(i) or Color3.fromHSV(ChamsOutlineColor.Hue, ChamsOutlineColor.Sat, ChamsOutlineColor.Value)
			end
		end
	})
	ChamsTransparency = Chams.CreateSlider({
		Name = "Transparency",
		Min = 1,
		Max = 100,
		Function = function(callback) if Chams.Enabled then Chams.ToggleButton(true) Chams.ToggleButton(true) end end,
		Default = 50
	})
	ChamsOutlineTransparency = Chams.CreateSlider({
		Name = "Outline Transparency",
		Min = 1,
		Max = 100,
		Function = function(callback) if Chams.Enabled then Chams.ToggleButton(true) Chams.ToggleButton(true) end end,
		Default = 1
	})
	ChamsTeammates = Chams.CreateToggle({
		Name = "Teammates",
		Function = function(callback) if Chams.Enabled then Chams.ToggleButton(true) Chams.ToggleButton(true) end end,
		Default = true
	})
	ChamsOnTop = Chams.CreateToggle({
		Name = "Bypass Walls",
		Function = function(callback) if Chams.Enabled then Chams.ToggleButton(true) Chams.ToggleButton(true) end end
	})
end)

run(function()
	local lightingsettings = {}
	local lightingchanged = false
	local Fullbright = {Enabled = false}
	Fullbright = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "Fullbright",
		Function = function(callback)
			if callback then
				lightingsettings.Brightness = lighting.Brightness
				lightingsettings.ClockTime = lighting.ClockTime
				lightingsettings.FogEnd = lighting.FogEnd
				lightingsettings.GlobalShadows = lighting.GlobalShadows
				lightingsettings.OutdoorAmbient = lighting.OutdoorAmbient
				lightingchanged = true
				lighting.Brightness = 2
				lighting.ClockTime = 14
				lighting.FogEnd = 100000
				lighting.GlobalShadows = false
				lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
				lightingchanged = false
				table.insert(Fullbright.Connections, lighting.Changed:Connect(function()
					if not lightingchanged then
						lightingsettings.Brightness = lighting.Brightness
						lightingsettings.ClockTime = lighting.ClockTime
						lightingsettings.FogEnd = lighting.FogEnd
						lightingsettings.GlobalShadows = lighting.GlobalShadows
						lightingsettings.OutdoorAmbient = lighting.OutdoorAmbient
						lightingchanged = true
						lighting.Brightness = 2
						lighting.ClockTime = 14
						lighting.FogEnd = 100000
						lighting.GlobalShadows = false
						lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
						lightingchanged = false
					end
				end))
			else
				for name, val in (lightingsettings) do
					lighting[name] = val
				end
			end
		end
	})
end)

run(function()
	local Health = {Enabled = false}
	Health =  rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "Health",
		Function = function(callback)
			if callback then
				HealthText = Drawing.new("Text")
				HealthText.Size = 20
				HealthText.Text = "100HP"
				HealthText.Position = Vector2.new(0, 0)
				HealthText.Color = Color3.fromRGB(0, 255, 0)
				HealthText.Center = true
				HealthText.Visible = true
				task.spawn(function()
					repeat
						if entityLibrary.isAlive then
							HealthText.Text = tostring(math.round(entityLibrary.character.Humanoid.Health)).."HP"
							HealthText.Color = Color3.fromHSV(math.clamp(entityLibrary.character.Humanoid.Health / entityLibrary.character.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
						end
						HealthText.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2 + 70)
						task.wait(0.1)
					until not Health.Enabled
				end)
			else
				if HealthText then HealthText:Remove() end
				RunLoops:UnbindFromRenderStep("Health")
			end
		end,
		HoverText = "Displays your health in the center of your screen."
	})
end)

run(function()
	local Search = {Enabled = false}
	local SearchTextList = {RefreshValues = function() end, ObjectList = {}}
	local SearchColor = {Value = 0.44}
	local SearchFolder = Instance.new("Folder")
	SearchFolder.Name = "SearchFolder"
	SearchFolder.Parent = rendervape.MainGui
	local function searchFindBoxHandle(part)
		for i,v in (SearchFolder:GetChildren()) do
			if v.Adornee == part then
				return v
			end
		end
		return nil
	end
	local searchRefresh = function()
		SearchFolder:ClearAllChildren()
		if Search.Enabled then
			for i,v in (workspace:GetDescendants()) do
				if (v:IsA("BasePart") or v:IsA("Model")) and table.find(SearchTextList.ObjectList, v.Name) and searchFindBoxHandle(v) == nil then
					local highlight = Instance.new("Highlight")
					highlight.Name = v.Name
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.FillColor = Color3.fromHSV(SearchColor.Hue, SearchColor.Sat, SearchColor.Value)
					highlight.Adornee = v
					highlight.Parent = SearchFolder
				end
			end
		end
	end
	Search = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "Search",
		Function = function(callback)
			if callback then
				searchRefresh()
				table.insert(Search.Connections, workspace.DescendantAdded:Connect(function(v)
					if (v:IsA("BasePart") or v:IsA("Model")) and table.find(SearchTextList.ObjectList, v.Name) and searchFindBoxHandle(v) == nil then
						local highlight = Instance.new("Highlight")
						highlight.Name = v.Name
						highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						highlight.FillColor = Color3.fromHSV(SearchColor.Hue, SearchColor.Sat, SearchColor.Value)
						highlight.Adornee = v
						highlight.Parent = SearchFolder
					end
				end))
				table.insert(Search.Connections, workspace.DescendantRemoving:Connect(function(v)
					if v:IsA("BasePart") or v:IsA("Model") then
						local boxhandle = searchFindBoxHandle(v)
						if boxhandle then
							boxhandle:Remove()
						end
					end
				end))
			else
				SearchFolder:ClearAllChildren()
			end
		end,
		HoverText = "Draws a box around selected parts\nAdd parts in Search frame"
	})
	SearchColor = Search.CreateColorSlider({
		Name = "new part color",
		Function = function(hue, sat, val)
			for i,v in (SearchFolder:GetChildren()) do
				v.FillColor = Color3.fromHSV(hue, sat, val)
			end
		end
	})
	SearchTextList = Search.CreateTextList({
		Name = "SearchList",
		TempText = "part name",
		AddFunction = function(user)
			searchRefresh()
		end,
		RemoveFunction = function(num)
			searchRefresh()
		end
	})
end)

run(function()
	local Xray = {Enabled = false}
	Xray = rendervape.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "Xray",
		Function = function(callback)
			if callback then
				table.insert(Xray.Connections, workspace.DescendantAdded:Connect(function(v)
					if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") and not v.Parent.Parent:FindFirstChild("Humanoid") then
						v.LocalTransparencyModifier = 0.5
					end
				end))
				for i, v in (workspace:GetDescendants()) do
					if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") and not v.Parent.Parent:FindFirstChild("Humanoid") then
						v.LocalTransparencyModifier = 0.5
					end
				end
			else
				for i, v in (workspace:GetDescendants()) do
					if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") and not v.Parent.Parent:FindFirstChild("Humanoid") then
						v.LocalTransparencyModifier = 0
					end
				end
			end
		end
	})
end)

run(function()
	local TracersColor = {Value = 0.44}
	local TracersTransparency = {Value = 1}
	local TracersStartPosition = {Value = "Middle"}
	local TracersEndPosition = {Value = "Head"}
	local TracersTeammates = {Enabled = true}
	local tracersfolderdrawing = {}
	local methodused

	local tracersfuncs1 = {
		Drawing = function(plr)
			if TracersTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local newobj = Drawing.new("Line")
			newobj.Thickness = 1
			newobj.Transparency = 1 - (TracersTransparency.Value / 100)
			newobj.Color = getPlayerColor(plr.Player) or Color3.fromHSV(TracersColor.Hue, TracersColor.Sat, TracersColor.Value)
			tracersfolderdrawing[plr.Player] = {entity = plr, Main = newobj}
		end,
		DrawingV3 = function(plr)
			if TracersTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local toppoint = PointInstance.new(plr[TracersEndPosition.Value == "Torso" and "RootPart" or "Head"])
			local bottompoint = TracersStartPosition.Value == "Mouse" and PointMouse.new() or Point2D.new(UDim2.new(0.5, 0, TracersStartPosition.Value == "Middle" and 0.5 or 1, 0))
			local newobj = LineDynamic.new(toppoint, bottompoint)
			newobj.Opacity = 1 - (TracersTransparency.Value / 100)
			newobj.Color = getPlayerColor(plr.Player) or Color3.fromHSV(TracersColor.Hue, TracersColor.Sat, TracersColor.Value)
			tracersfolderdrawing[plr.Player] = {entity = plr, Main = newobj}
		end,
	}
	local tracersfuncs2 = {
		Drawing = function(ent)
			local v = tracersfolderdrawing[ent]
			tracersfolderdrawing[ent] = nil
			if v then
				pcall(function() v.Main.Visible = false v.Main:Remove() end)
			end
		end,
	}
	local tracerscolorfuncs = {
		Drawing = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in (tracersfolderdrawing) do
				v.Main.Color = getPlayerColor(v.entity.Player) or color
			end
		end
	}
	tracerscolorfuncs.DrawingV3 = tracerscolorfuncs.Drawing
	tracersfuncs2.DrawingV3 = tracersfuncs2.Drawing
	local tracersloop = {
		Drawing = function()
			for i,v in (tracersfolderdrawing) do
				local rootPart = v.entity[TracersEndPosition.Value == "Torso" and "RootPart" or "Head"].Position
				local rootPos, rootVis = worldtoviewportpoint(rootPart)
				local screensize = camera.ViewportSize
				local startVector = TracersStartPosition.Value == "Mouse" and inputservice:GetMouseLocation() or Vector2.new(screensize.X / 2, (TracersStartPosition.Value == "Middle" and screensize.Y / 2 or screensize.Y))
				local endVector = Vector2.new(rootPos.X, rootPos.Y)
				v.Main.Visible = rootVis
				v.Main.From = startVector
				v.Main.To = endVector
			end
		end,
	}

	local Tracers = {Enabled = false}
	Tracers = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "Tracers",
		Function = function(callback)
			if callback then
				methodused = "Drawing"..synapsev3
				if tracersfuncs2[methodused] then
					table.insert(Tracers.Connections, entityLibrary.entityRemovedEvent:Connect(tracersfuncs2[methodused]))
				end
				if tracersfuncs1[methodused] then
					local addfunc = tracersfuncs1[methodused]
					for i,v in (entityLibrary.entityList) do
						if tracersfolderdrawing[v.Player] then tracersfuncs2[methodused](v.Player) end
						addfunc(v)
					end
					table.insert(Tracers.Connections, entityLibrary.entityAddedEvent:Connect(function(ent)
						if tracersfolderdrawing[ent.Player] then tracersfuncs2[methodused](ent.Player) end
						addfunc(ent)
					end))
				end
				if tracerscolorfuncs[methodused] then
					table.insert(Tracers.Connections, rendervape.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.FriendColorRefresh.Event:Connect(function()
						tracerscolorfuncs[methodused](TracersColor.Hue, TracersColor.Sat, TracersColor.Value)
					end))
				end
				if tracersloop[methodused] then
					RunLoops:BindToRenderStep("Tracers", tracersloop[methodused])
				end
			else
				RunLoops:UnbindFromRenderStep("Tracers")
				for i,v in (tracersfolderdrawing) do
					if tracersfuncs2[methodused] then
						tracersfuncs2[methodused](i)
					end
				end
			end
		end,
		HoverText = "Extra Sensory Perception\nRenders an Tracers on players."
	})
	TracersStartPosition = Tracers.CreateDropdown({
		Name = "Start Position",
		List = {"Middle", "Bottom", "Mouse"},
		Function = function() if Tracers.Enabled then Tracers.ToggleButton(true) Tracers.ToggleButton(true) end end
	})
	TracersEndPosition = Tracers.CreateDropdown({
		Name = "End Position",
		List = {"Head", "Torso"},
		Function = function() if Tracers.Enabled then Tracers.ToggleButton(true) Tracers.ToggleButton(true) end end
	})
	TracersColor = Tracers.CreateColorSlider({
		Name = "Player Color",
		Function = function(hue, sat, val)
			if Tracers.Enabled and tracerscolorfuncs[methodused] then
				tracerscolorfuncs[methodused](hue, sat, val)
			end
		end
	})
	TracersTransparency = Tracers.CreateSlider({
		Name = "Transparency",
		Min = 1,
		Max = 100,
		Function = function(val)
			for i,v in (tracersfolderdrawing) do
				if v.Main then
					v.Main[methodused == "DrawingV3" and "Opacity" or "Transparency"] = 1 - (val / 100)
				end
			end
		end,
		Default = 0
	})
	TracersTeammates = Tracers.CreateToggle({
		Name = "Priority Only",
		Function = function() if Tracers.Enabled then Tracers.ToggleButton(true) Tracers.ToggleButton(true) end end,
		Default = true
	})
end)

run(function()
	Spring = {} do
		Spring.__index = Spring

		function Spring.new(freq, pos)
			local self = setmetatable({}, Spring)
			self.f = freq
			self.p = pos
			self.v = pos*0
			return self
		end

		function Spring:Update(dt, goal)
			local f = self.f*2*math.pi
			local p0 = self.p
			local v0 = self.v

			local offset = goal - p0
			local decay = math.exp(-f*dt)

			local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
			local v1 = (f*dt*(offset*f - v0) + v0)*decay

			self.p = p1
			self.v = v1

			return p1
		end

		function Spring:Reset(pos)
			self.p = pos
			self.v = pos*0
		end
	end

	local cameraPos = Vector3.zero
	local cameraRot = Vector2.new()
	local velSpring = Spring.new(5, Vector3.zero)
	local panSpring = Spring.new(5, Vector2.new())

	Input = {} do

		keyboard = {
			W = 0,
			A = 0,
			S = 0,
			D = 0,
			E = 0,
			Q = 0,
			Up = 0,
			Down = 0,
			LeftShift = 0,
		}

		mouse = {
			Delta = Vector2.new(),
		}

		NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
		PAN_MOUSE_SPEED = Vector2.new(3, 3)*(math.pi/64)
		NAV_ADJ_SPEED = 0.75
		NAV_SHIFT_MUL = 0.25

		navSpeed = 1

		function Input.Vel(dt)
			navSpeed = math.clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)

			local kKeyboard = Vector3.new(
				keyboard.D - keyboard.A,
				keyboard.E - keyboard.Q,
				keyboard.S - keyboard.W
			)*NAV_KEYBOARD_SPEED

			local shift = inputservice:IsKeyDown(Enum.KeyCode.LeftShift)

			return (kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
		end

		function Input.Pan(dt)
			local kMouse = mouse.Delta*PAN_MOUSE_SPEED
			mouse.Delta = Vector2.new()
			return kMouse
		end

		do
			function Keypress(action, state, input)
				keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
				return Enum.ContextActionResult.Sink
			end

			function MousePan(action, state, input)
				local delta = input.Delta
				mouse.Delta = Vector2.new(-delta.y, -delta.x)
				return Enum.ContextActionResult.Sink
			end

			function Zero(t)
				for k, v in (t) do
					t[k] = v*0
				end
			end

			function Input.StartCapture()
				getservice("ContextActionService"):BindActionAtPriority("FreecamKeyboard",Keypress,false,Enum.ContextActionPriority.High.Value,
				Enum.KeyCode.W,
				Enum.KeyCode.A,
				Enum.KeyCode.S,
				Enum.KeyCode.D,
				Enum.KeyCode.E,
				Enum.KeyCode.Q,
				Enum.KeyCode.Up,
				Enum.KeyCode.Down
				)
				getservice("ContextActionService"):BindActionAtPriority("FreecamMousePan",MousePan,false,Enum.ContextActionPriority.High.Value,Enum.UserInputType.MouseMovement)
			end

			function Input.StopCapture()
				navSpeed = 1
				Zero(keyboard)
				Zero(mouse)
				getservice("ContextActionService"):UnbindAction("FreecamKeyboard")
				getservice("ContextActionService"):UnbindAction("FreecamMousePan")
			end
		end
	end

	local function GetFocusDistance(cameraFrame)
		local znear = 0.1
		local viewport = camera.ViewportSize
		local projy = 2*math.tan(cameraFov/2)
		local projx = viewport.x/viewport.y*projy
		local fx = cameraFrame.rightVector
		local fy = cameraFrame.upVector
		local fz = cameraFrame.lookVector

		local minVect = Vector3.zero
		local minDist = 512

		for x = 0, 1, 0.5 do
			for y = 0, 1, 0.5 do
				local cx = (x - 0.5)*projx
				local cy = (y - 0.5)*projy
				local offset = fx*cx - fy*cy + fz
				local origin = cameraFrame.p + offset*znear
				local _, hit = workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))
				local dist = (hit - origin).magnitude
				if minDist > dist then
					minDist = dist
					minVect = offset.unit
				end
			end
		end

		return fz:Dot(minVect)*minDist
	end

	local playerstate = {} do
		mouseBehavior = ""
		mouseIconEnabled = ""
		cameraType = ""
		cameraFocus = ""
		cameraCFrame = ""
		cameraFieldOfView = ""

		function playerstate.Push()
			cameraFieldOfView = camera.FieldOfView
			camera.FieldOfView = 70

			cameraType = camera.CameraType
			camera.CameraType = Enum.CameraType.Custom

			cameraCFrame = camera.CFrame
			cameraFocus = camera.Focus

			mouseBehavior = inputservice.MouseBehavior
			inputservice.MouseBehavior = Enum.MouseBehavior.Default

			mouseIconEnabled = inputservice.MouseIconEnabled
			inputservice.MouseIconEnabled = true
		end

		function playerstate.Pop()
			camera.FieldOfView = cameraFieldOfView
			cameraFieldOfView = nil

			camera.CameraType = cameraType
			cameraType = nil

			camera.CFrame = cameraCFrame
			cameraCFrame = nil

			camera.Focus = cameraFocus
			cameraFocus = nil

			inputservice.MouseIconEnabled = mouseIconEnabled
			mouseIconEnabled = nil

			inputservice.MouseBehavior = mouseBehavior
			mouseBehavior = nil
		end
	end

	local Freecam = rendervape.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "Freecam",
		Function = function(callback)
			if callback then
				local cameraCFrame = camera.CFrame
				local pitch, yaw, roll = cameraCFrame:ToEulerAnglesYXZ()
				cameraRot = Vector2.new(pitch, yaw)
				cameraPos = cameraCFrame.p
				cameraFov = camera.FieldOfView

				velSpring:Reset(Vector3.zero)
				panSpring:Reset(Vector2.new())

				playerstate.Push()
				RunLoops:BindToRenderStep("Freecam", function(dt)
					local vel = velSpring:Update(dt, Input.Vel(dt))
					local pan = panSpring:Update(dt, Input.Pan(dt))

					local zoomFactor = math.sqrt(math.tan(math.rad(70/2))/math.tan(math.rad(cameraFov/2)))

					cameraRot = cameraRot + pan*Vector2.new(0.75, 1)*8*(dt/zoomFactor)
					cameraRot = Vector2.new(math.clamp(cameraRot.x, -math.rad(90), math.rad(90)), cameraRot.y%(2*math.pi))

					local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*Vector3.new(1, 1, 1)*64*dt)
					cameraPos = cameraCFrame.p

					camera.CFrame = cameraCFrame
					camera.Focus = cameraCFrame*CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
					camera.FieldOfView = cameraFov
				end)
				Input.StartCapture()
			else
				Input.StopCapture()
				RunLoops:UnbindFromRenderStep("Freecam")
				playerstate.Pop()
			end
		end,
		HoverText = "Lets you fly and clip through walls freely\nwithout moving your player server-sided."
	})
	Freecam.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 150,
		Function = function(val) NAV_KEYBOARD_SPEED = Vector3.new(val / 75,  val / 75, val / 75) end,
		Default = 75
	})
end)

run(function()
	local Panic = rendervape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "Panic",
		Function = function(callback)
			if callback then
				for i,v in (rendervape.ObjectsThatCanBeSaved) do
					if v.Type == "OptionsButton" then
						if v.Api.Enabled then
							v.Api.ToggleButton()
						end
					end
				end
			end
		end
	})
end)

run(function()
	local ChatSpammer = {Enabled = false}
	local ChatSpammerDelay = {Value = 10}
	local ChatSpammerHideWait = {Enabled = true}
	local ChatSpammerMessages = {ObjectList = {}}
	local chatspammerfirstexecute = true
	local chatspammerhook = false
	local oldchanneltab
	local oldchannelfunc
	local oldchanneltabs = {}
	local waitnum = 0
	ChatSpammer = rendervape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ChatSpammer",
		Function = function(callback)
			if callback then
				if textchat.ChatVersion == Enum.ChatVersion.TextChatService then
					task.spawn(function()
						repeat
							if ChatSpammer.Enabled then
								pcall(function()
									textchat.ChatInputBarConfiguration.TargetTextChannel:SendAsync((#ChatSpammerMessages.ObjectList > 0 and ChatSpammerMessages.ObjectList[math.random(1, #ChatSpammerMessages.ObjectList)] or "start rendering today! --> renderintents.xyz"))
								end)
							end
							if waitnum ~= 0 then
								task.wait(waitnum)
								waitnum = 0
							else
								task.wait(ChatSpammerDelay.Value / 10)
							end
						until not ChatSpammer.Enabled
					end)
				else
					task.spawn(function()
						if chatspammerfirstexecute then
							lplr.PlayerGui:WaitForChild("Chat", 10)
							chatspammerfirstexecute = false
						end
						if lplr.PlayerGui:FindFirstChild("Chat") and lplr.PlayerGui.Chat:FindFirstChild("Frame") and lplr.PlayerGui.Chat.Frame:FindFirstChild("ChatChannelParentFrame") and replicated:FindFirstChild("DefaultChatSystemChatEvents") then
							if not chatspammerhook then
								task.spawn(function()
									chatspammerhook = true
									for i,v in (getconnections(replicated.DefaultChatSystemChatEvents.OnNewMessage.OnClientEvent)) do
										if v.Function and #debug.getupvalues(v.Function) > 0 and type(debug.getupvalues(v.Function)[1]) == "table" and getmetatable(debug.getupvalues(v.Function)[1]) and getmetatable(debug.getupvalues(v.Function)[1]).GetChannel then
											oldchanneltab = getmetatable(debug.getupvalues(v.Function)[1])
											oldchannelfunc = getmetatable(debug.getupvalues(v.Function)[1]).GetChannel
											getmetatable(debug.getupvalues(v.Function)[1]).GetChannel = function(Self, Name)
												local tab = oldchannelfunc(Self, Name)
												if tab and tab.AddMessageToChannel then
													local addmessage = tab.AddMessageToChannel
													if oldchanneltabs[tab] == nil then
														oldchanneltabs[tab] = tab.AddMessageToChannel
													end
													tab.AddMessageToChannel = function(Self2, MessageData)
														if MessageData.MessageType == "System" then
															if MessageData.Message:find("You must wait") and ChatSpammer.Enabled then
																return nil
															end
														end
														return addmessage(Self2, MessageData)
													end
												end
												return tab
											end
										end
									end
								end)
							end
							task.spawn(function()
								repeat
									pcall(function()
										replicated.DefaultChatSystemChatEvents.SayMessageRequest:FireServer((#ChatSpammerMessages.ObjectList > 0 and ChatSpammerMessages.ObjectList[math.random(1, #ChatSpammerMessages.ObjectList)] or "vxpe on top"), "All")
									end)
									if waitnum ~= 0 then
										task.wait(waitnum)
										waitnum = 0
									else
										task.wait(ChatSpammerDelay.Value / 10)
									end
								until not ChatSpammer.Enabled
							end)
						else
							warningNotification("ChatSpammer", "Default chat not found.", 3)
							if ChatSpammer.Enabled then ChatSpammer.ToggleButton(false) end
						end
					end)
				end
			else
				waitnum = 0
			end
		end,
		HoverText = "Spams chat with text of your choice (Default Chat Only)"
	})
	ChatSpammerDelay = ChatSpammer.CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 50,
		Default = 10,
		Function = void
	})
	ChatSpammerHideWait = ChatSpammer.CreateToggle({
		Name = "Hide Wait Message",
		Function = void,
		Default = true
	})
	ChatSpammerMessages = ChatSpammer.CreateTextList({
		Name = "Message",
		TempText = "message to spam",
		Function = void
	})
end)

run(function()
	local controlmodule
	local oldmove
	local SafeWalk = {Enabled = false}
	local SafeWalkRaycast = RaycastParams.new()
	SafeWalkRaycast.RespectCanCollide = true
	SafeWalkRaycast.FilterType = Enum.RaycastFilterType.Blacklist
	SafeWalk = rendervape.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "SafeWalk",
		Function = function(callback)
			if callback then
				if not controlmodule then
					local suc = pcall(function() controlmodule = require(lplr.PlayerScripts.PlayerModule).controls end)
					if not suc then controlmodule = {} end
				end
				oldmove = controlmodule.moveFunction
				controlmodule.moveFunction = function(Self, vec, facecam)
					if entityLibrary.isAlive then
						SafeWalkRaycast.FilterDescendantsInstances = {lplr.Character}
						local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position + (vec * 0.5), Vector3.new(0, -1000, 0), SafeWalkRaycast)
						if not ray then
							if workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -((entityLibrary.character.Humanoid.HipHeight + (entityLibrary.character.HumanoidRootPart.Size.Y / 2)) + 1), 0), SafeWalkRaycast) then
								vec = Vector3.zero
							end
						end
					end
					return oldmove(Self, vec, facecam)
				end
			else
				controlmodule.moveFunction = oldmove
			end
		end,
		HoverText = "lets you not walk off because you are bad"
	})
end)

run(function()
	local function capeFunction(char, texture)
		for i,v in (char:GetDescendants()) do
			if v.Name == "Cape" then
				v:Destroy()
			end
		end
		local hum = char:WaitForChild("Humanoid")
		local torso = nil
		if hum.RigType == Enum.HumanoidRigType.R15 then
			torso = char:WaitForChild("UpperTorso")
		else
			torso = char:WaitForChild("Torso")
		end
		local p = Instance.new("Part", torso.Parent)
		p.Name = "Cape"
		p.Anchored = false
		p.CanCollide = false
		p.TopSurface = 0
		p.BottomSurface = 0
		p.FormFactor = "Custom"
		p.Size = Vector3.new(0.2,0.2,0.08)
		p.Transparency = 1
		local decal
		local video = false
		if texture:find(".webm") then
			video = true
			local decal2 = Instance.new("SurfaceGui", p)
			decal2.Adornee = p
			decal2.CanvasSize = Vector2.new(1, 1)
			decal2.Face = "Back"
			decal = Instance.new("VideoFrame", decal2)
			decal.Size = UDim2.new(0, 9, 0, 17)
			decal.BackgroundTransparency = 1
			decal.Position = UDim2.new(0, -4, 0, -8)
			decal.Video = texture
			decal.Looped = true
			decal:Play()
		else
			decal = Instance.new("Decal", p)
			decal.Texture = texture
			decal.Face = "Back"
		end
		local msh = Instance.new("BlockMesh", p)
		msh.Scale = Vector3.new(9, 17.5, 0.5)
		local motor = Instance.new("Motor", p)
		motor.Part0 = p
		motor.Part1 = torso
		motor.MaxVelocity = 0.01
		motor.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(0, math.rad(90), 0)
		motor.C1 = CFrame.new(0, 1, 0.45) * CFrame.Angles(0, math.rad(90), 0)
		local wave = false
		repeat task.wait(1/44)
			if video then
				decal.Visible = torso.LocalTransparencyModifier ~= 1
			else
				decal.Transparency = torso.Transparency
			end
			local ang = 0.1
			local oldmag = torso.Velocity.magnitude
			local mv = 0.002
			if wave then
				ang = ang + ((torso.Velocity.magnitude/10) * 0.05) + 0.05
				wave = false
			else
				wave = true
			end
			ang = ang + math.min(torso.Velocity.magnitude/11, 0.5)
			motor.MaxVelocity = math.min((torso.Velocity.magnitude/111), 0.04) --+ mv
			motor.DesiredAngle = -ang
			if motor.CurrentAngle < -0.2 and motor.DesiredAngle > -0.2 then
				motor.MaxVelocity = 0.04
			end
			repeat task.wait() until motor.CurrentAngle == motor.DesiredAngle or math.abs(torso.Velocity.magnitude - oldmag) >= (torso.Velocity.magnitude/10) + 1
			if torso.Velocity.magnitude < 0.1 then
				task.wait(0.1)
			end
		until not p or p.Parent ~= torso.Parent
	end

	local Cape = {Enabled = false}
	local CapeBox = {Value = ""}
	Cape = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "Cape",
		Function = function(callback)
			if callback then
				local successfulcustom
				if CapeBox.Value ~= "" then
					if (tonumber(CapeBox.Value)) then
						local suc, id = pcall(function() return string.match(game:GetObjects("rbxassetid://"..CapeBox.Value)[1].Texture, "%?id=(%d+)") end)
						if not suc then
							id = CapeBox.Value
						end
						successfulcustom = "rbxassetid://"..id
					elseif (not isfile(CapeBox.Value)) then
						warningNotification("Cape", "Missing file", 5)
					else
						successfulcustom = CapeBox.Value:find(".") and getcustomasset(CapeBox.Value) or CapeBox.Value
					end
				end
				table.insert(Cape.Connections, lplr.CharacterAdded:Connect(function(char)
					task.spawn(function()
						pcall(function()
							capeFunction(char, (successfulcustom or downloadVapeAsset("rendervape/assets/VapeCape.png")))
						end)
					end)
				end))
				if lplr.Character then
					task.spawn(function()
						pcall(function()
							capeFunction(lplr.Character, (successfulcustom or downloadVapeAsset("rendervape/assets/VapeCape.png")))
						end)
					end)
				end
			else
				if lplr.Character then
					for i,v in (lplr.Character:GetDescendants()) do
						if v.Name == "Cape" then
							v:Destroy()
						end
					end
				end
			end
		end
	})
	CapeBox = Cape.CreateTextBox({
		Name = "File",
		TempText = "File (link)",
		FocusLost = function(enter)
			if enter then
				Cape:retoggle()
			end
		end
	})
end)

run(function()
	local ChinaHat = {Enabled = false}
	local ChinaHatColor = {Hue = 1, Sat=1, Value=0.33}
	local chinahattrail
	local chinahatattachment
	local chinahatattachment2
	ChinaHat = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "ChinaHat",
		Function = function(callback)
			if callback then
				RunLoops:BindToHeartbeat("ChinaHat", function()
					if entityLibrary.isAlive then
						if chinahattrail == nil or chinahattrail.Parent == nil then
							chinahattrail = Instance.new("Part")
							chinahattrail.CFrame = entityLibrary.character.Head.CFrame * CFrame.new(0, 1.1, 0)
							chinahattrail.Size = Vector3.new(3, 0.7, 3)
							chinahattrail.Name = "ChinaHat"
							chinahattrail.Material = Enum.Material.Neon
							chinahattrail.Color = Color3.fromHSV(ChinaHatColor.Hue, ChinaHatColor.Sat, ChinaHatColor.Value)
							chinahattrail.CanCollide = false
							chinahattrail.Transparency = 0.3
							local chinahatmesh = Instance.new("SpecialMesh")
							chinahatmesh.Parent = chinahattrail
							chinahatmesh.MeshType = "FileMesh"
							chinahatmesh.MeshId = "http://www.roblox.com/asset/?id=1778999"
							chinahatmesh.Scale = Vector3.new(3, 0.6, 3)
							chinahattrail.Parent = workspace.Camera
						end
						chinahattrail.CFrame = entityLibrary.character.Head.CFrame * CFrame.new(0, 1.1, 0)
						chinahattrail.Velocity = Vector3.zero
						chinahattrail.LocalTransparencyModifier = ((camera.CFrame.Position - camera.Focus.Position).Magnitude <= 0.6 and 1 or 0)
					else
						if chinahattrail then
							chinahattrail:Destroy()
							chinahattrail = nil
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("ChinaHat")
				if chinahattrail then
					chinahattrail:Destroy()
					chinahattrail = nil
				end
			end
		end,
		HoverText = "Puts a china hat on your character (mastadawn ty for)"
	})
	ChinaHatColor = ChinaHat.CreateColorSlider({
		Name = "Hat Color",
		Function = function(h, s, v)
			if chinahattrail then
				chinahattrail.Color = Color3.fromHSV(h, s, v)
			end
		end
	})
end)

run(function()
	local FieldOfView = {Enabled = false}
	local FieldOfViewZoom = {Enabled = false}
	local FieldOfViewValue = {Value = 70}
	local oldfov
	FieldOfView = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "FOVChanger",
		Function = function(callback)
			if callback then
				oldfov = camera.FieldOfView
				if FieldOfViewZoom.Enabled then
					task.spawn(function()
						repeat
							task.wait()
						until inputservice:IsKeyDown(Enum.KeyCode[FieldOfView.Keybind ~= "" and FieldOfView.Keybind or "C"]) == false
						if FieldOfView.Enabled then
							FieldOfView.ToggleButton(false)
						end
					end)
				end
				task.spawn(function()
					repeat
						camera.FieldOfView = FieldOfViewValue.Value
						task.wait()
					until (not FieldOfView.Enabled)
				end)
			else
				camera.FieldOfView = oldfov
			end
		end
	})
	FieldOfViewValue = FieldOfView.CreateSlider({
		Name = "FOV",
		Min = 30,
		Max = 120,
		Function = function(val) end
	})
	FieldOfViewZoom = FieldOfView.CreateToggle({
		Name = "Zoom",
		Function = void,
		HoverText = "optifine zoom lol"
	})
end)

run(function()
	local Swim = {Enabled = false}
	local SwimVertical = {Value = 1}
	local swimconnection
	local oldgravity

	Swim = rendervape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Swim",
		Function = function(callback)
			if callback then
				oldgravity = workspace.Gravity
				if entityLibrary.isAlive then
					GravityChangeTick = tick() + 0.1
					workspace.Gravity = 0
					local enums = Enum.HumanoidStateType:GetEnumItems()
					table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
					for i,v in (enums) do
						entityLibrary.character.Humanoid:SetStateEnabled(v, false)
					end
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
					RunLoops:BindToHeartbeat("Swim", function()
						local rootvelo = entityLibrary.character.HumanoidRootPart.Velocity
						local moving = entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero
						entityLibrary.character.HumanoidRootPart.Velocity = ((moving or inputservice:IsKeyDown(Enum.KeyCode.Space)) and Vector3.new(moving and rootvelo.X or 0, inputservice:IsKeyDown(Enum.KeyCode.Space) and SwimVertical.Value or rootvelo.Y, moving and rootvelo.Z or 0) or Vector3.zero)
					end)
				end
			else
				GravityChangeTick = tick() + 0.1
				workspace.Gravity = oldgravity
				RunLoops:UnbindFromHeartbeat("Swim")
				if entityLibrary.isAlive then
					local enums = Enum.HumanoidStateType:GetEnumItems()
					table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
					for i,v in (enums) do
						entityLibrary.character.Humanoid:SetStateEnabled(v, true)
					end
				end
			end
		end
	})
	SwimVertical = Swim.CreateSlider({
		Name = "Y Speed",
		Min = 1,
		Max = 50,
		Default = 50,
		Function = void
	})
end)


run(function()
	local Breadcrumbs = {Enabled = false}
	local BreadcrumbsLifetime = {Value = 20}
	local BreadcrumbsThickness = {Value = 7}
	local BreadcrumbsFadeIn = {Value = 0.44}
	local BreadcrumbsFadeOut = {Value = 0.44}
	local breadcrumbtrail
	local breadcrumbattachment
	local breadcrumbattachment2
	Breadcrumbs = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "Breadcrumbs",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						if entityLibrary.isAlive then
							if not breadcrumbtrail then
								breadcrumbattachment = Instance.new("Attachment")
								breadcrumbattachment.Position = Vector3.new(0, 0.07 - 2.7, 0)
								breadcrumbattachment2 = Instance.new("Attachment")
								breadcrumbattachment2.Position = Vector3.new(0, -0.07 - 2.7, 0)
								breadcrumbtrail = Instance.new("Trail")
								breadcrumbtrail.Attachment0 = breadcrumbattachment
								breadcrumbtrail.Attachment1 = breadcrumbattachment2
								breadcrumbtrail.Color = ColorSequence.new(Color3.fromHSV(BreadcrumbsFadeIn.Hue, BreadcrumbsFadeIn.Sat, BreadcrumbsFadeIn.Value), Color3.fromHSV(BreadcrumbsFadeOut.Hue, BreadcrumbsFadeOut.Sat, BreadcrumbsFadeOut.Value))
								breadcrumbtrail.FaceCamera = true
								breadcrumbtrail.Lifetime = BreadcrumbsLifetime.Value / 10
								breadcrumbtrail.Enabled = true
							else
								local suc = pcall(function()
									breadcrumbattachment.Parent = entityLibrary.character.HumanoidRootPart
									breadcrumbattachment2.Parent = entityLibrary.character.HumanoidRootPart
									breadcrumbtrail.Parent = camera
								end)
								if not suc then
									if breadcrumbtrail then breadcrumbtrail:Destroy() breadcrumbtrail = nil end
									if breadcrumbattachment then breadcrumbattachment:Destroy() breadcrumbattachment = nil end
									if breadcrumbattachment2 then breadcrumbattachment2:Destroy() breadcrumbattachment2 = nil end
								end
							end
						end
						task.wait(0.3)
					until not Breadcrumbs.Enabled
				end)
			else
				if breadcrumbtrail then breadcrumbtrail:Destroy() breadcrumbtrail = nil end
				if breadcrumbattachment then breadcrumbattachment:Destroy() breadcrumbattachment = nil end
				if breadcrumbattachment2 then breadcrumbattachment2:Destroy() breadcrumbattachment2 = nil end
			end
		end,
		HoverText = "Shows a trail behind your character"
	})
	BreadcrumbsFadeIn = Breadcrumbs.CreateColorSlider({
		Name = "Fade In",
		Function = function(hue, sat, val)
			if breadcrumbtrail then
				breadcrumbtrail.Color = ColorSequence.new(Color3.fromHSV(hue, sat, val), Color3.fromHSV(BreadcrumbsFadeOut.Hue, BreadcrumbsFadeOut.Sat, BreadcrumbsFadeOut.Value))
			end
		end
	})
	BreadcrumbsFadeOut = Breadcrumbs.CreateColorSlider({
		Name = "Fade Out",
		Function = function(hue, sat, val)
			if breadcrumbtrail then
				breadcrumbtrail.Color = ColorSequence.new(Color3.fromHSV(BreadcrumbsFadeIn.Hue, BreadcrumbsFadeIn.Sat, BreadcrumbsFadeIn.Value), Color3.fromHSV(hue, sat, val))
			end
		end
	})
	BreadcrumbsLifetime = Breadcrumbs.CreateSlider({
		Name = "Lifetime",
		Min = 1,
		Max = 100,
		Function = function(val)
			if breadcrumbtrail then
				breadcrumbtrail.Lifetime = val / 10
			end
		end,
		Default = 20,
		Double = 10
	})
	BreadcrumbsThickness = Breadcrumbs.CreateSlider({
		Name = "Thickness",
		Min = 1,
		Max = 30,
		Function = function(val)
			if breadcrumbattachment then
				breadcrumbattachment.Position = Vector3.new(0, (val / 100) - 2.7, 0)
			end
			if breadcrumbattachment2 then
				breadcrumbattachment2.Position = Vector3.new(0, -(val / 100) - 2.7, 0)
			end
		end,
		Default = 7,
		Double = 10
	})
end)

run(function()
	local AutoReport = {Enabled = false}
	local AutoReportList = {ObjectList = {}}
	local AutoReportNotify = {Enabled = false}
	local alreadyreported = {}

	local function removerepeat(str)
		local newstr = ""
		local lastlet = ""
		for i,v in (str:split("")) do
			if v ~= lastlet then
				newstr = newstr..v
				lastlet = v
			end
		end
		return newstr
	end

	local reporttable = {
		gay = "Bullying",
		gae = "Bullying",
		gey = "Bullying",
		hack = "Scamming",
		exploit = "Scamming",
		cheat = "Scamming",
		hecker = "Scamming",
		haxker = "Scamming",
		hacer = "Scamming",
		report = "Bullying",
		fat = "Bullying",
		black = "Bullying",
		getalife = "Bullying",
		fatherless = "Bullying",
		report = "Bullying",
		fatherless = "Bullying",
		disco = "Offsite Links",
		yt = "Offsite Links",
		dizcourde = "Offsite Links",
		retard = "Swearing",
		bad = "Bullying",
		trash = "Bullying",
		nolife = "Bullying",
		nolife = "Bullying",
		loser = "Bullying",
		killyour = "Bullying",
		kys = "Bullying",
		hacktowin = "Bullying",
		bozo = "Bullying",
		kid = "Bullying",
		adopted = "Bullying",
		linlife = "Bullying",
		commitnotalive = "Bullying",
		vape = "Offsite Links",
		futureclient = "Offsite Links",
		download = "Offsite Links",
		youtube = "Offsite Links",
		die = "Bullying",
		lobby = "Bullying",
		ban = "Bullying",
		wizard = "Bullying",
		wisard = "Bullying",
		witch = "Bullying",
		magic = "Bullying",
	}
	local reporttableexact = {
		L = "Bullying",
	}


	local function findreport(msg)
		local checkstr = removerepeat(msg:gsub("%W+", ""):lower())
		for i,v in (reporttable) do
			if checkstr:find(i) then
				return v, i
			end
		end
		for i,v in (reporttableexact) do
			if checkstr == i then
				return v, i
			end
		end
		for i,v in (AutoReportList.ObjectList) do
			if checkstr:find(v) then
				return "Bullying", v
			end
		end
		return nil
	end

	AutoReport = rendervape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoReport",
		Function = function(callback)
			if callback then
				if textchat.ChatVersion == Enum.ChatVersion.TextChatService then
					table.insert(AutoReport.Connections, render.events.message:Connect(function(tab)
						if tab.TextSource then
							local plr = players:GetPlayerByUserId(tab.TextSource.UserId)
							local args = tab.Text:split(" ")
							if plr and plr ~= lplr and whitelist:get(plr) == 0 then
								local reportreason, reportedmatch = findreport(tab.Text)
								if reportreason then
									if alreadyreported[plr] then return end
									task.spawn(function()
										if syn == nil or reportplayer then
											if reportplayer then
												reportplayer(plr, reportreason, "he said a bad word")
											else
												players:ReportAbuse(plr, reportreason, "he said a bad word")
											end
										end
									end)
									if AutoReportNotify.Enabled then
										warningNotification("AutoReport", "Reported "..plr.Name.." for "..reportreason..' ('..reportedmatch..')', 15)
									end
									alreadyreported[plr] = true
								end
							end
						end
					end))
				else
					if replicated:FindFirstChild("DefaultChatSystemChatEvents") then
						table.insert(AutoReport.Connections, replicated.DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(tab, channel)
							local plr = players:FindFirstChild(tab.FromSpeaker)
							local args = tab.Message:split(" ")
							if plr and plr ~= lplr and whitelist:get(plr) == 0 then
								local reportreason, reportedmatch = findreport(tab.Message)
								if reportreason then
									if alreadyreported[plr] then return end
									task.spawn(function()
										if syn == nil or reportplayer then
											if reportplayer then
												reportplayer(plr, reportreason, "he said a bad word")
											else
												players:ReportAbuse(plr, reportreason, "he said a bad word")
											end
										end
									end)
									if AutoReportNotify.Enabled then
										warningNotification("AutoReport", "Reported "..plr.Name.." for "..reportreason..' ('..reportedmatch..')', 15)
									end
									alreadyreported[plr] = true
								end
							end
						end))
					else
						warningNotification("AutoReport", "Default chat not found.", 5)
						AutoReport.ToggleButton(false)
					end
				end
			end
		end
	})
	AutoReportNotify = AutoReport.CreateToggle({
		Name = "Notify",
		Function = void
	})
	AutoReportList = AutoReport.CreateTextList({
		Name = "Report Words",
		TempText = "phrase (to report)"
	})
end)

run(function()
	local targetstrafe = {Enabled = false}
	local targetstraferange = {Value = 0}
	local oldmove
	local controlmodule
	targetstrafe = rendervape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "TargetStrafe",
		Function = function(callback)
			if callback then
				if not controlmodule then
					local suc = pcall(function() controlmodule = require(lplr.PlayerScripts.PlayerModule).controls end)
					if not suc then controlmodule = {} end
				end
				oldmove = controlmodule.moveFunction
				controlmodule.moveFunction = function(Self, vec, facecam, ...)
					if entityLibrary.isAlive then
						local plr = EntityNearPosition(targetstraferange.Value, {
							WallCheck = false,
							AimPart = "RootPart"
						})
						if plr then
							facecam = false
							--code stolen from roblox since the way I tried to make it apparently sucks
							local c, s
							local plrCFrame = CFrame.lookAt(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(plr.RootPart.Position.X, 0, plr.RootPart.Position.Z))
							local _, _, _, R00, R01, R02, _, _, R12, _, _, R22 = plrCFrame:GetComponents()
							if R12 < 1 and R12 > -1 then
								c = R22
								s = R02
							else
								c = R00
								s = -R01*math.sign(R12)
							end
							local norm = math.sqrt(c*c + s*s)
							local cameraRelativeMoveVector = controlmodule:GetMoveVector()
							vec = Vector3.new(
								(c*cameraRelativeMoveVector.X + s*cameraRelativeMoveVector.Z)/norm,
								0,
								(c*cameraRelativeMoveVector.Z - s*cameraRelativeMoveVector.X)/norm
							)
						end
					end
					return oldmove(Self, vec, facecam, ...)
				end
			else
				controlmodule.moveFunction = oldmove
			end
		end
	})
	targetstraferange = targetstrafe.CreateSlider({
		Name = "Range",
		Function = void,
		Min = 0,
		Max = 100,
		Default = 14
	})
end)

run(function()
	local AutoLeave = {Enabled = false}
	local AutoLeaveMode = {Value = "UnInject"}
	local AutoLeaveGroupId = {Value = "0"}
	local AutoLeaveRank = {Value = "1"}
	local getrandomserver
	local alreadyjoining = false
	getrandomserver = function(pointer)
		alreadyjoining = true
		local decodeddata = getservice("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100"..(pointer and "&cursor="..pointer or "")))
		local chosenServer
		for i, v in (decodeddata.data) do
			if (tonumber(v.playing) < tonumber(players.MaxPlayers)) and tonumber(v.ping) < 300 and v.id ~= game.JobId then
				chosenServer = v.id
				break
			end
		end
		if chosenServer then
			alreadyjoining = false
			getservice("TeleportService"):TeleportToPlaceInstance(game.PlaceId, chosenServer, lplr)
		else
			if decodeddata.nextPageCursor then
				getrandomserver(decodeddata.nextPageCursor)
			else
				alreadyjoining = false
			end
		end
	end

	local function getRole(plr, id)
		local suc, res = pcall(function() return plr:GetRankInGroup(id) end)
		if not suc then
			repeat
				suc, res = pcall(function() return plr:GetRankInGroup(id) end)
				task.wait()
			until suc
		end
		return res
	end

	local function autoleaveplradded(plr)
		task.spawn(function()
			pcall(function()
				if AutoLeaveGroupId.Value == "" or AutoLeaveRank.Value == "" then return end
				if getRole(plr, tonumber(AutoLeaveGroupId.Value) or 0) >= (tonumber(AutoLeaveRank.Value) or 1) then
					local _, ent = entityLibrary.getEntityFromPlayer(plr)
					if ent then
						entityLibrary.entityUpdatedEvent:Fire(ent)
					end
					if AutoLeaveMode.Value == "UnInject" then
						task.spawn(function()
							if not shared.VapeFullyLoaded then
								repeat task.wait() until shared.VapeFullyLoaded
							end
							rendervape.SelfDestruct()
						end)
						getservice("StarterGui"):SetCore("SendNotification", {
							Title = "AutoLeave",
							Text = "Staff Detected\n"..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name),
							Duration = 60,
						})
					elseif AutoLeaveMode.Value == "Rejoin" then
						getrandomserver()
					else
						createwarning("AutoLeave", "Staff Detected : "..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name), 60)
					end
				end
			end)
		end)
	end

	local function autodetect(roles)
		local highest = 9e9
		for i,v in (roles) do
			local low = v.Name:lower()
			if (low:find("admin") or low:find("mod") or low:find("dev")) and v.Rank < highest then
				highest = v.Rank
			end
		end
		return highest
	end

	AutoLeave = rendervape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "AutoLeave",
		Function = function(callback)
			if callback then
				if AutoLeaveGroupId.Value == "" or AutoLeaveRank.Value == "" then
					task.spawn(function()
						local placeinfo = {Creator = {CreatorTargetId = tonumber(AutoLeaveGroupId.Value)}}
						if AutoLeaveGroupId.Value == "" then
							placeinfo = getservice("MarketplaceService"):GetProductInfo(game.PlaceId)
							if placeinfo.Creator.CreatorType ~= "Group" then
								local desc = placeinfo.Description:split("\n")
								for i, str in (desc) do
									local _, begin = str:find("roblox.com/groups/")
									if begin then
										local endof = str:find("/", begin + 1)
										placeinfo = {Creator = {CreatorType = "Group", CreatorTargetId = str:sub(begin + 1, endof - 1)}}
									end
								end
							end
							if placeinfo.Creator.CreatorType ~= "Group" then
								warningNotification("AutoLeave", "Automatic Setup Failed (no group detected)", 60)
								return
							end
						end
						local groupinfo = getservice("GroupService"):GetGroupInfoAsync(placeinfo.Creator.CreatorTargetId)
						AutoLeaveGroupId.SetValue(placeinfo.Creator.CreatorTargetId)
						AutoLeaveRank.SetValue(autodetect(groupinfo.Roles))
						AutoLeave:retoggle()
					end)
					table.insert(AutoLeave.Connections, players.PlayerAdded:Connect(autoleaveplradded))
					for i, plr in (players:GetPlayers()) do
						autoleaveplradded(plr)
					end
				end
			end
		end,
		HoverText = "Leaves if a staff member joins your game."
	})
	AutoLeaveMode = AutoLeave.CreateDropdown({
		Name = "Mode",
		List = {"UnInject", "Rejoin", "Notify"},
		Function = void
	})
	AutoLeaveGroupId = AutoLeave.CreateTextBox({
		Name = "Group Id",
		TempText = ' (group id)',
		Function = void
	})
	AutoLeaveRank = AutoLeave.CreateTextBox({
		Name = 'Rank Id',
		TempText = [[1 (rank id)]],
		Function = void
	})
end)

run(function()
	rendervape.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "AntiVoid",
		Function = function(callback)
			if callback then
				local rayparams = RaycastParams.new()
				rayparams.RespectCanCollide = true
				local lastray
				RunLoops:BindToHeartbeat("AntiVoid", function()
					if entityLibrary.isAlive then
						rayparams.FilterDescendantsInstances = {camera, lplr.Character}
						lastray = entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air and entityLibrary.character.HumanoidRootPart.CFrame or lastray
						if (entityLibrary.character.HumanoidRootPart.Position.Y + (entityLibrary.character.HumanoidRootPart.Velocity.Y * 0.016)) <= (workspace.FallenPartsDestroyHeight + 5) then
							local comp = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
							comp[2] = (workspace.FallenPartsDestroyHeight + 20)
							if lastray then
								comp[1] = lastray.Position.X
								comp[2] = lastray.Position.Y + (entityLibrary.character.Humanoid.HipHeight + (entityLibrary.character.HumanoidRootPart.Size.Y / 2))
								comp[3] = lastray.Position.Z
							end
							entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(comp))
							entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 0, entityLibrary.character.HumanoidRootPart.Velocity.Z)
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("AntiVoid")
			end
		end
	})
end)

run(function()
    local desync: vapemodule = {};
	local desyncvisual: vapeminimodule = {};
	local desyncvisualcolor: vapecolorslider = newcolor();
    local desyncdelay: vapeslider = {Value = 1};
	local desyncupvelo: vapeslider = {Value = 1};
	local desynctweendelay: vapeslider = {Value = 0};
    local lastTeleport: number = tick();
    local newroot: BasePart = {};
    local oldroot: BasePart = {};
	local oldtween: Tween;
    local desyncthread;
    local createclone = function()
		repeat task.wait() until isAlive(lplr, true) or desync.Enabled == false;
		task.wait(0.1);
		if not desync.Enabled then return end;
		lplr.Character.Parent = game;
		oldroot = lplr.Character.PrimaryPart; 
		newroot = oldroot:Clone();
		newroot.Parent = lplr.Character;
		lplr.Character.PrimaryPart = newroot;
		oldroot.Parent = workspace;
		lplr.Character.Parent = workspace;
		oldroot.Transparency = 1;
		entityLibrary.character.HumanoidRootPart = newroot;
		render.clone = setmetatable({
			old = oldroot,
			new = newroot
		}, {
			__index = function(self: table, index: string)
				local root: BasePart | nil = rawget(self, index);
				if root and root.Parent ~= nil then 
					return root;
				end;
			end
		});
	end;
	local destructclone = function()
		lplr.Character.Parent = game;
		oldroot.Transparency = 1;
		oldroot.Parent = lplr.Character;
        lplr.Character.PrimaryPart = oldroot;
		newroot.Parent = workspace;
		lplr.Character.Parent = workspace;
		entityLibrary.character.HumanoidRootPart = oldroot;
		newroot:Destroy();
		newroot = {}; 
		oldroot = {};
		render.clone = {}
	end;
    desync = blatant.Api.CreateOptionsButton({
        Name = 'Desync',
        HoverText = 'Delays serverside movement.',
        Function = function(calling: boolean)
            if calling then 
                desyncthread = task.spawn(function()
                    repeat
                        task.wait()
                        if isAlive(lplr, true) then
                            oldroot.Velocity = Vector3.zero;
							oldroot.Transparency = desyncvisual.Enabled and 0.5 or 1;
							oldroot.Color = Color3.fromHSV(desyncvisualcolor.Hue, desyncvisualcolor.Sat, desyncvisualcolor.Value);
                            if newroot.Parent ~= lplr.Character then 
                                lastTeleport = tick();
                                createclone();
                            end;
                            local lastTeleportSeconds: number = tick() - lastTeleport;
                            if lastTeleportSeconds >= (0.1 * desyncdelay.Value) then 
                                lastTeleport = tick();
								oldtween = tween:Create(oldroot, TweenInfo.new(0.1 * desynctweendelay.Value, Enum.EasingStyle.Linear), {CFrame = (newroot.CFrame + Vector3.new(0, desyncupvelo.Value, 0))});
								oldtween:Play();
								oldtween.Completed:Wait();
                            end
                        end
                    until (not desync.Enabled)
                end);
            else 
				pcall(function() oldtween:Cancel() end);
                pcall(task.cancel, desyncthread);
                pcall(destructclone);
            end
        end
    });
	desyncvisual = desync.CreateToggle({
		Name = 'Visual',
		HoverText = 'Shows the root.',
		Function = function(calling: boolean): ()
			desyncvisualcolor.Object.Visible = calling;
		end
	});
	desyncvisualcolor = desync.CreateColorSlider({
		Name = 'Root Color',
		Function = void
	});
    desyncdelay = desync.CreateSlider({
        Name = 'Tick',
        Min = 1,
        Max = 10,
        Default = 2,
        Function = void
    });
	desynctweendelay = desync.CreateSlider({
		Name = 'Tween Delay',
		Min = 0,
		Max = 5,
		Function = void
	});
	desyncupvelo = desync.CreateSlider({
		Name = 'Velocity',
		Min = 0,
		Max = 80,
		Function = void
	});
	desyncvisualcolor.Object.Visible = false;
end);

run(function()
	local AnimationPlayer = {Enabled = false}
	local AnimationPlayerBox = {Value = ""}
	local AnimationPlayerSpeed = {Speed = 1}
	local playedanim
	AnimationPlayer = rendervape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AnimationPlayer",
		Function = function(callback)
			if callback then
				if entityLibrary.isAlive then
					if playedanim then
						playedanim:Stop()
						playedanim.Animation:Destroy()
						playedanim = nil
					end
					local anim = Instance.new("Animation")
					local suc, id = pcall(function() return string.match(game:GetObjects("rbxassetid://"..AnimationPlayerBox.Value)[1].AnimationId, "%?id=(%d+)") end)
                    if not suc then
                        id = AnimationPlayerBox.Value
                    end
                    anim.AnimationId = "rbxassetid://"..id
					local suc, res = pcall(function() playedanim = entityLibrary.character.Humanoid.Animator:LoadAnimation(anim) end)
					if suc then
						playedanim.Priority = Enum.AnimationPriority.Action4
						playedanim.Looped = true
						playedanim:Play()
						playedanim:AdjustSpeed(AnimationPlayerSpeed.Value / 10)
						table.insert(AnimationPlayer.Connections, playedanim.Stopped:Connect(function()
							AnimationPlayer:retoggle()
						end))
					else
						warningNotification("AnimationPlayer", "failed to load anim : "..(res or "invalid animation id"), 5)
					end
				end
				table.insert(AnimationPlayer.Connections, lplr.CharacterAdded:Connect(function()
					repeat task.wait() until entityLibrary.isAlive or not AnimationPlayer.Enabled
					task.wait(0.5)
					if not AnimationPlayer.Enabled then return end
					if playedanim then
						playedanim:Stop()
						playedanim.Animation:Destroy()
						playedanim = nil
					end
					local anim = Instance.new("Animation")
					local suc, id = pcall(function() return string.match(game:GetObjects("rbxassetid://"..AnimationPlayerBox.Value)[1].AnimationId, "%?id=(%d+)") end)
                    if not suc then
                        id = AnimationPlayerBox.Value
                    end
                    anim.AnimationId = "rbxassetid://"..id
					local suc, res = pcall(function() playedanim = entityLibrary.character.Humanoid.Animator:LoadAnimation(anim) end)
					if suc then
						playedanim.Priority = Enum.AnimationPriority.Action4
						playedanim.Looped = true
						playedanim:Play()
						playedanim:AdjustSpeed(AnimationPlayerSpeed.Value / 10)
						playedanim.Stopped:Connect(function()
							AnimationPlayer:retoggle()
						end)
					else
						warningNotification("AnimationPlayer", "failed to load anim : "..(res or "invalid animation id"), 5)
					end
				end))
			else
				if playedanim then playedanim:Stop() playedanim = nil end
			end
		end
	})
	AnimationPlayerBox = AnimationPlayer.CreateTextBox({
		Name = "Animation",
		TempText = "anim (num only)",
		Function = function(enter)
			AnimationPlayer:retoggle()
		end
	})
	AnimationPlayerSpeed = AnimationPlayer.CreateSlider({
		Name = "Speed",
		Function = function(val)
			if playedanim then
				playedanim:AdjustSpeed(val / 10)
			end
		end,
		Min = 1,
		Max = 20,
		Double = 10
	})
end)

run(function()
	local GamingChair = {Enabled = false}
	local GamingChairColor = {Value = 1}
	local chair
	local chairanim
	local chairhighlight
	local movingsound
	local flyingsound
	local wheelpositions = {
		Vector3.new(-0.8, -0.6, -0.18),
		Vector3.new(0.1, -0.6, -0.88),
		Vector3.new(0, -0.6, 0.7)
	}
	local currenttween
	GamingChair = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "GamingChair",
		Function = function(callback)
			if callback then
				chair = Instance.new("MeshPart")
				chair.Color = Color3.fromRGB(21, 21, 21)
				chair.Size = Vector3.new(2.16, 3.6, 2.3) / Vector3.new(12.37, 20.636, 13.071)
				chair.CanCollide = false
				chair.MeshId = "rbxassetid://12972961089"
				chair.Material = Enum.Material.SmoothPlastic
				chair.Parent = workspace
				movingsound = Instance.new("Sound")
				movingsound.SoundId = downloadVapeAsset("rendervape/assets/ChairRolling.mp3")
				movingsound.Volume = 0.4
				movingsound.Looped = true
				movingsound.Parent = workspace
				flyingsound = Instance.new("Sound")
				flyingsound.SoundId = downloadVapeAsset("rendervape/assets/ChairFlying.mp3")
				flyingsound.Volume = 0.4
				flyingsound.Looped = true
				flyingsound.Parent = workspace
				local chairweld = Instance.new("WeldConstraint")
				chairweld.Part0 = chair
				chairweld.Parent = chair
				if entityLibrary.isAlive then
					chair.CFrame = entityLibrary.character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(-90), 0)
					chairweld.Part1 = entityLibrary.character.HumanoidRootPart
				end
				chairhighlight = Instance.new("Highlight")
				chairhighlight.FillTransparency = 1
				chairhighlight.OutlineColor = Color3.fromHSV(GamingChairColor.Hue, GamingChairColor.Sat, GamingChairColor.Value)
				chairhighlight.DepthMode = Enum.HighlightDepthMode.Occluded
				chairhighlight.OutlineTransparency = 0.2
				chairhighlight.Parent = chair
				local chairarms = Instance.new("MeshPart")
				chairarms.Color = chair.Color
				chairarms.Size = Vector3.new(1.39, 1.345, 2.75) / Vector3.new(97.13, 136.216, 234.031)
				chairarms.CFrame = chair.CFrame * CFrame.new(-0.169, -1.129, -0.013)
				chairarms.MeshId = "rbxassetid://12972673898"
				chairarms.CanCollide = false
				chairarms.Parent = chair
				local chairarmsweld = Instance.new("WeldConstraint")
				chairarmsweld.Part0 = chairarms
				chairarmsweld.Part1 = chair
				chairarmsweld.Parent = chair
				local chairlegs = Instance.new("MeshPart")
				chairlegs.Color = chair.Color
				chairlegs.Name = "Legs"
				chairlegs.Size = Vector3.new(1.8, 1.2, 1.8) / Vector3.new(10.432, 8.105, 9.488)
				chairlegs.CFrame = chair.CFrame * CFrame.new(0.047, -2.324, 0)
				chairlegs.MeshId = "rbxassetid://13003181606"
				chairlegs.CanCollide = false
				chairlegs.Parent = chair
				local chairfan = Instance.new("MeshPart")
				chairfan.Color = chair.Color
				chairfan.Name = "Fan"
				chairfan.Size = Vector3.zero
				chairfan.CFrame = chair.CFrame * CFrame.new(0, -1.873, 0)
				chairfan.MeshId = "rbxassetid://13004977292"
				chairfan.CanCollide = false
				chairfan.Parent = chair
				local trails = {}
				for i,v in (wheelpositions) do
					local attachment = Instance.new("Attachment")
					attachment.Position = v
					attachment.Parent = chairlegs
					local attachment2 = Instance.new("Attachment")
					attachment2.Position = v + Vector3.new(0, 0, 0.18)
					attachment2.Parent = chairlegs
					local trail = Instance.new("Trail")
					trail.Texture = "http://www.roblox.com/asset/?id=13005168530"
					trail.TextureMode = Enum.TextureMode.Static
					trail.Transparency = NumberSequence.new(0.5)
					trail.Color = ColorSequence.new(Color3.new(0.5, 0.5, 0.5))
					trail.Attachment0 = attachment
					trail.Attachment1 = attachment2
					trail.Lifetime = 20
					trail.MaxLength = 60
					trail.MinLength = 0.1
					trail.Parent = chairlegs
					table.insert(trails, trail)
				end
				chairanim = {Stop = function() end}
				local oldmoving = false
				local oldflying = false
				task.spawn(function()
					repeat
						task.wait()
						if not GamingChair.Enabled then break end
						if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 then
							if not chairanim.IsPlaying then
								local temp2 = Instance.new("Animation")
								temp2.AnimationId = entityLibrary.character.Humanoid.RigType == Enum.HumanoidRigType.R15 and "http://www.roblox.com/asset/?id=2506281703" or "http://www.roblox.com/asset/?id=178130996"
								chairanim = entityLibrary.character.Humanoid:LoadAnimation(temp2)
								chairanim.Priority = Enum.AnimationPriority.Movement
								chairanim.Looped = true
								chairanim:Play()
							end
							--welds didn't work for these idk why so poop code :troll:
							chair.CFrame = entityLibrary.character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(-90), 0)
							chairweld.Part1 = entityLibrary.character.HumanoidRootPart
							chairlegs.Velocity = Vector3.zero
							chairlegs.CFrame = chair.CFrame * CFrame.new(0.047, -2.324, 0)
							chairfan.Velocity = Vector3.zero
							chairfan.CFrame = chair.CFrame * CFrame.new(0.047, -1.873, 0) * CFrame.Angles(0, math.rad(tick() * 180 % 360), math.rad(180))
							local moving = entityLibrary.character.Humanoid:GetState() == Enum.HumanoidStateType.runservicening and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero
							local flying = rendervape.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled or rendervape.ObjectsThatCanBeSaved.LongJumpOptionsButton and rendervape.ObjectsThatCanBeSaved.LongJumpOptionsButton.Api.Enabled or rendervape.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton and rendervape.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled
							if movingsound.TimePosition > 1.9 then
								movingsound.TimePosition = 0.2
							end
							movingsound.PlaybackSpeed = (entityLibrary.character.HumanoidRootPart.Velocity * Vector3.new(1, 0, 1)).Magnitude / 16
							for i,v in (trails) do
								v.Enabled = not flying and moving
								v.Color = ColorSequence.new(movingsound.PlaybackSpeed > 1.5 and Color3.new(1, 0.5, 0) or Color3.new())
							end
							if moving ~= oldmoving then
								if movingsound.IsPlaying then
									if not moving then movingsound:Stop() end
								else
									if not flying and moving then movingsound:Play() end
								end
								oldmoving = moving
							end
							if flying ~= oldflying then
								if flying then
									if movingsound.IsPlaying then
										movingsound:Stop()
									end
									if not flyingsound.IsPlaying then
										flyingsound:Play()
									end
									if currenttween then currenttween:Cancel() end
									tween = tween:Create(chairlegs, TweenInfo.new(0.15), {Size = Vector3.zero})
									tween.Completed:Connect(function(state)
										if state == Enum.PlaybackState.Completed then
											chairfan.Transparency = 0
											chairlegs.Transparency = 1
											tween = tween:Create(chairfan, TweenInfo.new(0.15), {Size = Vector3.new(1.534, 0.328, 1.537) / Vector3.new(791.138, 168.824, 792.027)})
											tween:Play()
										end
									end)
									tween:Play()
								else
									if flyingsound.IsPlaying then
										flyingsound:Stop()
									end
									if not movingsound.IsPlaying and moving then
										movingsound:Play()
									end
									if currenttween then currenttween:Cancel() end
									tween = tween:Create(chairfan, TweenInfo.new(0.15), {Size = Vector3.zero})
									tween.Completed:Connect(function(state)
										if state == Enum.PlaybackState.Completed then
											chairfan.Transparency = 1
											chairlegs.Transparency = 0
											tween = tween:Create(chairlegs, TweenInfo.new(0.15), {Size = Vector3.new(1.8, 1.2, 1.8) / Vector3.new(10.432, 8.105, 9.488)})
											tween:Play()
										end
									end)
									tween:Play()
								end
								oldflying = flying
							end
						else
							chair.Anchored = true
							chairlegs.Anchored = true
							chairfan.Anchored = true
							repeat task.wait() until entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0
							chair.Anchored = false
							chairlegs.Anchored = false
							chairfan.Anchored = false
							chairanim:Stop()
						end
					until not GamingChair.Enabled
				end)
			else
				if chair then chair:Destroy() end
				if chairanim then chairanim:Stop() end
				if movingsound then movingsound:Destroy() end
				if flyingsound then flyingsound:Destroy() end
			end
		end
	})
	GamingChairColor = GamingChair.CreateColorSlider({
		Name = "Color",
		Function = function(h, s, v)
			if chairhighlight then
				chairhighlight.OutlineColor = Color3.fromHSV(h, s, v)
			end
		end
	})
end)

run(function()
	local SongBeats = {Enabled = false}
	local SongBeatsList = {ObjectList = {}}
	local SongTween
	local SongAudio
	local SongFOV
	local SongVolume = {Value = 1}

	local function PlaySong(arg)
		local args = arg:split(":")
		local song = isfile(args[1]) and getcustomasset(args[1]) or tonumber(args[1]) and "rbxassetid://"..args[1]
		if not song then
			warningNotification("SongBeats", "missing music file "..args[1], 5)
			SongBeats.ToggleButton(false)
			return
		end
		if SongAudio then
			SongAudio:Destroy()
		end
		local bpm = 1 / (args[2] / 60)
		SongAudio = Instance.new("Sound")
		SongAudio.SoundId = song
		SongAudio.Parent = workspace
		SongAudio.Volume = SongVolume.Value
		SongAudio:Play()
		repeat
			repeat task.wait() until SongAudio.IsLoaded or (not SongBeats.Enabled)
			if (not SongBeats.Enabled) then break end
			camera.FieldOfView = SongFOV - 5
			if SongTween then SongTween:Cancel() end
			SongTween = tween:Create(camera, TweenInfo.new(0.2), {FieldOfView = SongFOV})
			SongTween:Play()
			task.wait(bpm)
		until (not SongBeats.Enabled) or SongAudio.IsPaused
	end

	SongBeats = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "SongBeats",
		Function = function(callback)
			if callback then
				SongFOV = camera.FieldOfView
				task.spawn(function()
					if #SongBeatsList.ObjectList <= 0 then
						warningNotification("SongBeats", "no songs", 5)
						SongBeats.ToggleButton(false)
						return
					end
					local lastChosen
					repeat
						local newSong
						repeat newSong = SongBeatsList.ObjectList[Random.new():NextInteger(1, #SongBeatsList.ObjectList)] task.wait() until newSong ~= lastChosen or #SongBeatsList.ObjectList <= 1
						lastChosen = newSong
						PlaySong(newSong)
						if not SongBeats.Enabled then break end
						task.wait(2)
					until (not SongBeats.Enabled)
				end)
			else
				if SongAudio then SongAudio:Destroy() end
				if SongTween then SongTween:Cancel() end
				camera.FieldOfView = SongFOV
			end
		end
	})
	SongBeatsList = SongBeats.CreateTextList({
		Name = "SongList",
		TempText = "songpath:bpm"
	})
	SongVolume = SongBeats.CreateSlider({
		Name = 'Volume',
		Function = function()
			if SongAudio then
				SongAudio.Volume = SongVolume.Value
			end
		end,
		Min = 1,
		Max = 10,
		Default = 2
	})
end)

--[[run(function()
	local Atmosphere = {Enabled = false}
	local SkyUp = {Value = ""}
	local SkyDown = {Value = ""}
	local SkyLeft = {Value = ""}
	local SkyRight = {Value = ""}
	local SkyFront = {Value = ""}
	local SkyBack = {Value = ""}
	local SkySun = {Value = ""}
	local SkyMoon = {Value = ""}
	local SkyColor = {Value = 1}
	local skyobj
	local skyatmosphereobj
	local oldobjects = {}
	Atmosphere = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "Atmosphere",
		Function = function(callback)
			if callback then
				for i,v in lighting:GetChildren() do
					if v:IsA("PostEffect") or v:IsA("Sky") then
						table.insert(oldobjects, v)
						v.Parent = game
					end
				end
				skyobj = Instance.new("Sky")
				skyobj.SkyboxBk = tonumber(SkyBack.Value) and "rbxassetid://"..SkyBack.Value or SkyBack.Value
				skyobj.SkyboxDn = tonumber(SkyDown.Value) and "rbxassetid://"..SkyDown.Value or SkyDown.Value
				skyobj.SkyboxFt = tonumber(SkyFront.Value) and "rbxassetid://"..SkyFront.Value or SkyFront.Value
				skyobj.SkyboxLf = tonumber(SkyLeft.Value) and "rbxassetid://"..SkyLeft.Value or SkyLeft.Value
				skyobj.SkyboxRt = tonumber(SkyRight.Value) and "rbxassetid://"..SkyRight.Value or SkyRight.Value
				skyobj.SkyboxUp = tonumber(SkyUp.Value) and "rbxassetid://"..SkyUp.Value or SkyUp.Value
				skyobj.SunTextureId = tonumber(SkySun.Value) and "rbxassetid://"..SkySun.Value or SkySun.Value
				skyobj.MoonTextureId = tonumber(SkyMoon.Value) and "rbxassetid://"..SkyMoon.Value or SkyMoon.Value
				skyobj.Parent = lighting
				skyatmosphereobj = Instance.new("ColorCorrectionEffect")
				skyatmosphereobj.TintColor = Color3.fromHSV(SkyColor.Hue, SkyColor.Sat, SkyColor.Value)
				skyatmosphereobj.Parent = lighting
			else
				if skyobj then skyobj:Destroy() end
				if skyatmosphereobj then skyatmosphereobj:Destroy() end
				for i,v in (oldobjects) do
					v.Parent = lighting
				end
				table.clear(oldobjects)
			end
		end
	})
	SkyUp = Atmosphere.CreateTextBox({
		Name = "SkyUp",
		TempText = "Sky Top ID",
		FocusLost = function(enter)
			if Atmosphere.Enabled then
				Atmosphere.ToggleButton(false)
				Atmosphere.ToggleButton(false)
			end
		end
	})
	SkyDown = Atmosphere.CreateTextBox({
		Name = "SkyDown",
		TempText = "Sky Bottom ID",
		FocusLost = function(enter)
			if Atmosphere.Enabled then
				Atmosphere.ToggleButton(false)
				Atmosphere.ToggleButton(false)
			end
		end
	})
	SkyLeft = Atmosphere.CreateTextBox({
		Name = "SkyLeft",
		TempText = "Sky Left ID",
		FocusLost = function(enter)
			if Atmosphere.Enabled then
				Atmosphere.ToggleButton(false)
				Atmosphere.ToggleButton(false)
			end
		end
	})
	SkyRight = Atmosphere.CreateTextBox({
		Name = "SkyRight",
		TempText = "Sky Right ID",
		FocusLost = function(enter)
			if Atmosphere.Enabled then
				Atmosphere.ToggleButton(false)
				Atmosphere.ToggleButton(false)
			end
		end
	})
	SkyFront = Atmosphere.CreateTextBox({
		Name = "SkyFront",
		TempText = "Sky Front ID",
		FocusLost = function(enter)
			if Atmosphere.Enabled then
				Atmosphere.ToggleButton(false)
				Atmosphere.ToggleButton(false)
			end
		end
	})
	SkyBack = Atmosphere.CreateTextBox({
		Name = "SkyBack",
		TempText = "Sky Back ID",
		FocusLost = function(enter)
			if Atmosphere.Enabled then
				Atmosphere.ToggleButton(false)
				Atmosphere.ToggleButton(false)
			end
		end
	})
	SkySun = Atmosphere.CreateTextBox({
		Name = "SkySun",
		TempText = "Sky Sun ID",
		FocusLost = function(enter)
			if Atmosphere.Enabled then
				Atmosphere.ToggleButton(false)
				Atmosphere.ToggleButton(false)
			end
		end
	})
	SkyMoon = Atmosphere.CreateTextBox({
		Name = "SkyMoon",
		TempText = "Sky Moon ID",
		FocusLost = function(enter)
			if Atmosphere.Enabled then
				Atmosphere.ToggleButton(false)
				Atmosphere.ToggleButton(false)
			end
		end
	})
	SkyColor = Atmosphere.CreateColorSlider({
		Name = "Color",
		Function = function(h, s, v)
			if skyatmosphereobj then
				skyatmosphereobj.TintColor = Color3.fromHSV(SkyColor.Hue, SkyColor.Sat, SkyColor.Value)
			end
		end
	})
end)]]

run(function()
	local Disabler = {Enabled = false}
	local DisablerAntiKick = {Enabled = false}
	local disablerhooked = false

	local hookmethod = function(self)
		if (not Disabler.Enabled) then return end
		if type(self) == "userdata" and self == lplr then
			return true
		end
	end


	Disabler = rendervape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ClientKickDisabler",
		Function = function(callback)
			if callback then
				if not disablerhooked then
					disablerhooked = true
					local oldnamecall
					oldnamecall = hookmetamethod(game, "__namecall", function(self, ...)
						local method = getnamecallmethod()
						if method ~= "Kick" and method ~= "kick" then return oldnamecall(self, ...) end
						if not Disabler.Enabled then
							return oldnamecall(self, ...)
						end
						if not hookmethod(self) then return oldnamecall(self, ...) end
						return
					end)
					local antikick
					antikick = hookfunction(lplr.Kick, function(self, ...)
						if not Disabler.Enabled then return antikick(self, ...) end
						if type(self) == "userdata" and self == lplr then
							return
						end
						return antikick(self, ...)
					end)
				end
			else
				if restorefunction then
					restorefunction(lplr.Kick)
					restorefunction(getrawmetatable(game).__namecall)
					disablerhooked = false
				end
			end
		end
	})
end)

run(function()
	local FPS = {}
	local FPSLabel
	FPS = rendervape.CreateLegitModule({
		Name = "FPS",
		Function = function(callback)
			if callback then
				local frames = {}
				local framerate = 0
				local startClock = os.clock()
				local updateTick = tick()
				RunLoops:BindToHeartbeat("FPS", function()
					-- https://devforum.roblox.com/t/get-client-fps-trough-a-script/282631, annoying math, I thought either adding dt to a table or doing 1 / dt would work, but this is just better lol
					local updateClock = os.clock()
					for i = #frames, 1, -1 do
						frames[i + 1] = frames[i] >= updateClock - 1 and frames[i] or nil
					end
					frames[1] = updateClock
					if updateTick < tick() then
						updateTick = tick() + 1
						FPSLabel.Text = math.floor(os.clock() - startClock >= 1 and #frames or #frames / (os.clock() - startClock)).." FPS"
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("FPS")
			end
		end
	})
	FPSLabel = Instance.new("TextLabel")
	FPSLabel.Size = UDim2.new(0, 100, 0, 41)
	FPSLabel.BackgroundTransparency = 0.5
	FPSLabel.TextSize = 15
	FPSLabel.Font = Enum.Font.Gotham
	FPSLabel.Text = "inf FPS"
	FPSLabel.TextColor3 = Color3.new(1, 1, 1)
	FPSLabel.BackgroundColor3 = Color3.new()
	FPSLabel.Parent = FPS.GetCustomChildren()
	local ReachCorner = Instance.new("UICorner")
	ReachCorner.CornerRadius = UDim.new(0, 4)
	ReachCorner.Parent = FPSLabel
end)


run(function()
	local Ping = {}
	local PingLabel
	Ping = rendervape.CreateLegitModule({
		Name = "Ping",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						PingLabel.Text = math.floor(render.ping).." ms"
						task.wait(1)
					until false
				end)
			end
		end
	})
	PingLabel = Instance.new("TextLabel")
	PingLabel.Size = UDim2.new(0, 100, 0, 41)
	PingLabel.BackgroundTransparency = 0.5
	PingLabel.TextSize = 15
	PingLabel.Font = Enum.Font.Gotham
	PingLabel.Text = [[0 ms]]
	PingLabel.TextColor3 = Color3.new(1, 1, 1)
	PingLabel.BackgroundColor3 = Color3.new()
	PingLabel.Parent = Ping.GetCustomChildren()
	local PingCorner = Instance.new("UICorner")
	PingCorner.CornerRadius = UDim.new(0, 4)
	PingCorner.Parent = PingLabel
end)

run(function() -- from vape
	local MemoryDisplay = {}
	local MemoryLabel
	MemoryDisplay = rendervape.CreateLegitModule({
		Name = 'Memory Usage',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat
						task.wait(0.4)
						MemoryLabel.Text = (math.floor(getservice('Stats'):GetTotalMemoryUsageMb())..' MB')
					until (not MemoryDisplay.Enabled)
				end)
			end
		end
	})
	MemoryLabel = Instance.new('TextLabel', MemoryDisplay.GetCustomChildren())
	MemoryLabel.Size = UDim2.new(0, 100, 0, 41)
	MemoryLabel.BackgroundTransparency = 0.5
	MemoryLabel.TextSize = 15
	MemoryLabel.Font = Enum.Font.Gotham
	MemoryLabel.Text = '0.00 studs'
	MemoryLabel.TextColor3 = Color3.new(1, 1, 1)
	MemoryLabel.BackgroundColor3 = Color3.new()
	local MemoryCorner = Instance.new('UICorner', MemoryLabel)
	MemoryCorner.CornerRadius = UDim.new(0, 4)
end)

run(function()
	local Keystrokes = {}
	local keys = {}
	local keystrokesframe
	local keyconnection1
	local keyconnection2

	local function createKeystroke(keybutton, pos, pos2)
		local key = Instance.new("Frame")
		key.Size = keybutton == Enum.KeyCode.Space and UDim2.new(0, 110, 0, 24) or UDim2.new(0, 34, 0, 36)
		key.BackgroundColor3 = Color3.new()
		key.BackgroundTransparency = 0.5
		key.Position = pos
		key.Name = keybutton.Name
		key.Parent = keystrokesframe
		local keytext = Instance.new("TextLabel")
		keytext.BackgroundTransparency = 1
		keytext.Size = UDim2.new(1, 0, 1, 0)
		keytext.Font = Enum.Font.Gotham
		keytext.Text = keybutton == Enum.KeyCode.Space and "______" or keybutton.Name
		keytext.TextXAlignment = Enum.TextXAlignment.Left
		keytext.TextYAlignment = Enum.TextYAlignment.Top
		keytext.Position = pos2
		keytext.TextSize = keybutton == Enum.KeyCode.Space and 18 or 15
		keytext.TextColor3 = Color3.new(1, 1, 1)
		keytext.Parent = key
		local keycorner = Instance.new("UICorner")
		keycorner.CornerRadius = UDim.new(0, 4)
		keycorner.Parent = key
		keys[keybutton] = {Key = key}
	end

	Keystrokes = rendervape.CreateLegitModule({
		Name = "Keystrokes",
		Function = function(callback)
			if callback then
				keyconnection1 = inputservice.InputBegan:Connect(function(inputType)
					local key = keys[inputType.KeyCode]
					if key then
						if key.Tween then key.Tween:Cancel() end
						if key.Tween2 then key.Tween2:Cancel() end
						key.Tween = tween:Create(key.Key, TweenInfo.new(0.1), {BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0})
						key.Tween:Play()
						key.Tween2 = tween:Create(key.Key.TextLabel, TweenInfo.new(0.1), {TextColor3 = Color3.new()})
						key.Tween2:Play()
					end
				end)
				keyconnection2 = inputservice.InputEnded:Connect(function(inputType)
					local key = keys[inputType.KeyCode]
					if key then
						if key.Tween then key.Tween:Cancel() end
						if key.Tween2 then key.Tween2:Cancel() end
						key.Tween = tween:Create(key.Key, TweenInfo.new(0.1), {BackgroundColor3 = Color3.new(), BackgroundTransparency = 0.5})
						key.Tween:Play()
						key.Tween2 = tween:Create(key.Key.TextLabel, TweenInfo.new(0.1), {TextColor3 = Color3.new(1, 1, 1)})
						key.Tween2:Play()
					end
				end)
			else
				if keyconnection1 then keyconnection1:Disconnect() end
				if keyconnection2 then keyconnection2:Disconnect() end
			end
		end
	})
	keystrokesframe = Instance.new("Frame")
	keystrokesframe.Size = UDim2.new(0, 110, 0, 176)
	keystrokesframe.BackgroundTransparency = 1
	keystrokesframe.Parent = Keystrokes.GetCustomChildren()
	createKeystroke(Enum.KeyCode.W, UDim2.new(0, 38, 0, 0), UDim2.new(0, 6, 0, 5))
	createKeystroke(Enum.KeyCode.S, UDim2.new(0, 38, 0, 42), UDim2.new(0, 8, 0, 5))
	createKeystroke(Enum.KeyCode.A, UDim2.new(0, 0, 0, 42), UDim2.new(0, 7, 0, 5))
	createKeystroke(Enum.KeyCode.D, UDim2.new(0, 76, 0, 42), UDim2.new(0, 8, 0, 5))
	createKeystroke(Enum.KeyCode.Space, UDim2.new(0, 0, 0, 83), UDim2.new(0, 25, 0, -10))
end)

task.spawn(function()
	repeat 
		local success, ping = pcall(function() return getservice('Stats').PerformanceStats.Ping:GetValue() end);
		if success and tonumber(ping) then 
			render.ping = tonumber(ping);
		end
		task.wait();
	until not vapeInjected
end);

task.spawn(function()
    repeat 
        entityLibrary.isAlive = isAlive(lplr, true);
        task.wait()
    until not vapeInjected
end);

task.spawn(function()
	InfoNotification('Render', `Currently logged on as {RenderLibrary.http:getdiscord().global_name}`, 10)
end);

run(function()
	local targethuds: table = loadstring(RenderLibrary.http:getfile('libraries/targethuds.lua'))();
	local newhudvisible: boolean = false;
	local mainhud: vapecustomwindow = rendervape.CreateCustomWindow({
		Name = 'New HUD',
		Icon = 'rendervape/assets/TargetIcon3.png',
		IconSize = 16
	});
	local newhudoption: vapemodule = hudwindow.Api.CreateOptionsButton({
		Name = 'New HUD',
		HoverText = 'created by maxlasertech',
		Function = function(calling: boolean)
			newhudvisible = calling;
			mainhud.SetVisible(calling)
		end
	});
	local oldhudupdate: (rendertarget | nil) -> () = targethuds.updatehuds; targethuds.updatehuds = function(self: table, target: rendertarget?)
		self.currentTarget = target;
		if rendervape.MainGui.ScaledGui.ClickGui.Visible then 
			return
		end;
		return oldhudupdate(self, target);
	end;
	
	local mainhudframe: Frame = targethuds.instance.MainHUD;
	mainhudframe.Parent = mainhud.GetCustomChildren();
	render.targets = targethuds;
	table.insert(renderconnections, rendervape.MainGui.ScaledGui.ClickGui:GetPropertyChangedSignal('Visible'):Connect(function()
		if rendervape.MainGui.ScaledGui.ClickGui.Visible and newhudvisible then 
			mainhudframe.Visible = true;
		end;
	end));
	targethuds:updatehuds();
end);

local rendertext: TextLabel = Instance.new('TextLabel', rendervape.MainGui.ScaledGui.ClickGui);
rendertext.Text = 'Thank you for choosing render vape | renderintents.lol';
rendertext.BackgroundTransparency = 1;
rendertext.TextSize = 25;
rendertext.ZIndex = 10;
rendertext.Size = UDim2.new(1, 0, 0, 0);
rendertext.Font = Enum.Font.GothamMedium;
rendertext.TextColor3 = Color3.fromRGB(255, 255, 255);
rendertext.AnchorPoint = Vector2.new(0.5, 0.5);
rendertext.Position = UDim2.new(0.5, 0, 0.75, 0);

run(function()
	local Atmosphere = {}
	local AtmosphereMethod = {Value = 'Custom'}
	local skythemeobjects = Performance.new();
	local SkyUp = {Value = ''};
	local SkyDown = {Value = ''};
	local SkyLeft = {Value = ''};
	local SkyRight = {Value = ''};
	local SkyFront = {Value = ''};
	local SkyBack = {Value = ''};
	local SkySun = {Value = ''};
	local SkyMoon = {Value = ''};
	local SkyColor = {Value = 1};
	local skyobj: Sky;
	local skyatmosphereobj;
	local oldtime;
	local oldobjects = {};
	local themetable = {
		Custom = function() 
			skyobj.SkyboxBk = tonumber(SkyBack.Value) and 'rbxassetid://'..SkyBack.Value or SkyBack.Value
			skyobj.SkyboxDn = tonumber(SkyDown.Value) and 'rbxassetid://'..SkyDown.Value or SkyDown.Value
			skyobj.SkyboxFt = tonumber(SkyFront.Value) and 'rbxassetid://'..SkyFront.Value or SkyFront.Value
			skyobj.SkyboxLf = tonumber(SkyLeft.Value) and 'rbxassetid://'..SkyLeft.Value or SkyLeft.Value
			skyobj.SkyboxRt = tonumber(SkyRight.Value) and 'rbxassetid://'..SkyRight.Value or SkyRight.Value
			skyobj.SkyboxUp = tonumber(SkyUp.Value) and 'rbxassetid://'..SkyUp.Value or SkyUp.Value
			skyobj.SunTextureId = tonumber(SkySun.Value) and 'rbxassetid://'..SkySun.Value or SkySun.Value
			skyobj.MoonTextureId = tonumber(SkyMoon.Value) and 'rbxassetid://'..SkyMoon.Value or SkyMoon.Value
		end,
		Purple = function()
            skyobj.SkyboxBk = 'rbxassetid://8539982183'
            skyobj.SkyboxDn = 'rbxassetid://8539981943'
            skyobj.SkyboxFt = 'rbxassetid://8539981721'
            skyobj.SkyboxLf = 'rbxassetid://8539981424'
            skyobj.SkyboxRt = 'rbxassetid://8539980766'
            skyobj.SkyboxUp = 'rbxassetid://8539981085'
			skyobj.MoonAngularSize = 0
            skyobj.SunAngularSize = 0
            skyobj.StarCount = 3e3
		end,
		Galaxy = function()
            skyobj.SkyboxBk = 'rbxassetid://159454299'
            skyobj.SkyboxDn = 'rbxassetid://159454296'
            skyobj.SkyboxFt = 'rbxassetid://159454293'
            skyobj.SkyboxLf = 'rbxassetid://159454293'
            skyobj.SkyboxRt = 'rbxassetid://159454293'
            skyobj.SkyboxUp = 'rbxassetid://159454288'
			skyobj.SunAngularSize = 0
		end,
		BetterNight = function()
			skyobj.SkyboxBk = 'rbxassetid://155629671'
            skyobj.SkyboxDn = 'rbxassetid://12064152'
            skyobj.SkyboxFt = 'rbxassetid://155629677'
            skyobj.SkyboxLf = 'rbxassetid://155629662'
            skyobj.SkyboxRt = 'rbxassetid://155629666'
            skyobj.SkyboxUp = 'rbxassetid://155629686'
			skyobj.SunAngularSize = 0
		end,
		BetterNight2 = function()
			skyobj.SkyboxBk = 'rbxassetid://248431616'
            skyobj.SkyboxDn = 'rbxassetid://248431677'
            skyobj.SkyboxFt = 'rbxassetid://248431598'
            skyobj.SkyboxLf = 'rbxassetid://248431686'
            skyobj.SkyboxRt = 'rbxassetid://248431611'
            skyobj.SkyboxUp = 'rbxassetid://248431605'
			skyobj.StarCount = 3e3
		end,
		MagentaOrange = function()
			skyobj.SkyboxBk = 'rbxassetid://566616113'
            skyobj.SkyboxDn = 'rbxassetid://566616232'
            skyobj.SkyboxFt = 'rbxassetid://566616141'
            skyobj.SkyboxLf = 'rbxassetid://566616044'
            skyobj.SkyboxRt = 'rbxassetid://566616082'
            skyobj.SkyboxUp = 'rbxassetid://566616187'
			skyobj.StarCount = 3e3
		end,
		Purple2 = function()
			skyobj.SkyboxBk = 'rbxassetid://8107841671'
			skyobj.SkyboxDn = 'rbxassetid://6444884785'
			skyobj.SkyboxFt = 'rbxassetid://8107841671'
			skyobj.SkyboxLf = 'rbxassetid://8107841671'
			skyobj.SkyboxRt = 'rbxassetid://8107841671'
			skyobj.SkyboxUp = 'rbxassetid://8107849791'
			skyobj.SunTextureId = 'rbxassetid://6196665106'
			skyobj.MoonTextureId = 'rbxassetid://6444320592'
			skyobj.MoonAngularSize = 0
		end,
		Galaxy2 = function()
			skyobj.SkyboxBk = 'rbxassetid://14164368678'
			skyobj.SkyboxDn = 'rbxassetid://14164386126'
			skyobj.SkyboxFt = 'rbxassetid://14164389230'
			skyobj.SkyboxLf = 'rbxassetid://14164398493'
			skyobj.SkyboxRt = 'rbxassetid://14164402782'
			skyobj.SkyboxUp = 'rbxassetid://14164405298'
			skyobj.SunTextureId = 'rbxassetid://8281961896'
			skyobj.MoonTextureId = 'rbxassetid://6444320592'
			skyobj.SunAngularSize = 0
			skyobj.MoonAngularSize = 0
		end,
	Pink = function()
		skyobj.SkyboxBk = 'rbxassetid://271042516'
		skyobj.SkyboxDn = 'rbxassetid://271077243'
		skyobj.SkyboxFt = 'rbxassetid://271042556'
		skyobj.SkyboxLf = 'rbxassetid://271042310'
		skyobj.SkyboxRt = 'rbxassetid://271042467'
		skyobj.SkyboxUp = 'rbxassetid://271077958'
	end,
	PurpleMountains = function() --
		skyobj.SkyboxBk = 'rbxassetid://17901353811';
		skyobj.SkyboxDn = 'rbxassetid://17901366771';
		skyobj.SkyboxFt = 'rbxassetid://17901356262';
		skyobj.SkyboxLf = 'rbxassetid://17901359687';
		skyobj.SkyboxRt = 'rbxassetid://17901362326';
		skyobj.SkyboxUp = 'rbxassetid://17901365106';
		skyobj.SunAngularSize = 0;
	end,
	AestheticMountains = function()
		skyobj.SkyboxBk = 'rbxassetid://15470198023';
		skyobj.SkyboxDn = 'rbxassetid://15470151245';
		skyobj.SkyboxFt = 'rbxassetid://15470200128';
		skyobj.SkyboxLf = 'rbxassetid://15470202648';
		skyobj.SkyboxRt = 'rbxassetid://15470204862';
		skyobj.SkyboxUp = 'rbxassetid://15470207755';
		skyobj.MoonAngularSize = 11;
		skyobj.SunAngularSize = 21;
	end,
	OverPlanet = function()
		skyobj.SkyboxBk = 'rbxassetid://165052268';
		skyobj.SkyboxDn = 'rbxassetid://165052286';
		skyobj.SkyboxFt = 'rbxassetid://165052328';
		skyobj.SkyboxLf = 'rbxassetid://165052365';
		skyobj.SkyboxRt = 'rbxassetid://165052306';
		skyobj.SkyboxUp = 'rbxassetid://165052345';
		skyobj.MoonAngularSize = 11;
		skyobj.SunAngularSize = 21;
		skyobj.StarCount = 3000;
	end,
	Beach = function()
		skyobj.SkyboxBk = 'rbxassetid://173380597';
		skyobj.SkyboxDn = 'rbxassetid://173380627';
		skyobj.SkyboxFt = 'rbxassetid://173380642';
		skyobj.SkyboxLf = 'rbxassetid://173380671';
		skyobj.SkyboxRt = 'rbxassetid://173380774';
		skyobj.SkyboxUp = 'rbxassetid://173380790';
		skyobj.MoonAngularSize = 11;
		skyobj.SunAngularSize = 21;
	end,
	RedNight = function()
		skyobj.SkyboxBk = 'rbxassetid://401664839';
		skyobj.SkyboxDn = 'rbxassetid://401664862';
		skyobj.SkyboxFt = 'rbxassetid://401664960';
		skyobj.SkyboxLf = 'rbxassetid://401664881';
		skyobj.SkyboxRt = 'rbxassetid://401664901';
		skyobj.SkyboxUp = 'rbxassetid://401664936';
		skyobj.SunAngularSize = 0;
	end,
	GreenHaze = function()
		skyobj.SkyboxBk = 'rbxassetid://160193404';
		skyobj.SkyboxDn = 'rbxassetid://160193466';
		skyobj.SkyboxFt = 'rbxassetid://160193461';
		skyobj.SkyboxLf = 'rbxassetid://160193469';
		skyobj.SkyboxRt = 'rbxassetid://160193463';
		skyobj.SkyboxUp = 'rbxassetid://160193458';
		skyobj.SunAngularSize = 0;
	end,
	Purple3 = function()
		skyobj.SkyboxBk = 'rbxassetid://433274085'
		skyobj.SkyboxDn = 'rbxassetid://433274194'
		skyobj.SkyboxFt = 'rbxassetid://433274131'
		skyobj.SkyboxLf = 'rbxassetid://433274370'
		skyobj.SkyboxRt = 'rbxassetid://433274429'
		skyobj.SkyboxUp = 'rbxassetid://433274285'
	end,
	DarkishPink = function()
		skyobj.SkyboxBk = 'rbxassetid://570555736'
		skyobj.SkyboxDn = 'rbxassetid://570555964'
		skyobj.SkyboxFt = 'rbxassetid://570555800'
		skyobj.SkyboxLf = 'rbxassetid://570555840'
		skyobj.SkyboxRt = 'rbxassetid://570555882'
		skyobj.SkyboxUp = 'rbxassetid://570555929'
	end,
	Space = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://166509999'
		skyobj.SkyboxDn = 'rbxassetid://166510057'
		skyobj.SkyboxFt = 'rbxassetid://166510116'
		skyobj.SkyboxLf = 'rbxassetid://166510092'
		skyobj.SkyboxRt = 'rbxassetid://166510131'
		skyobj.SkyboxUp = 'rbxassetid://166510114'
	end,
	Space2 = function()
		skyobj.SkyboxBk = 'rbxassetid://11844076072';
		skyobj.SkyboxDn = 'rbxassetid://11844069700';
		skyobj.SkyboxFt = 'rbxassetid://11844067209';
		skyobj.SkyboxLf = 'rbxassetid://11844063543';
		skyobj.SkyboxRt = 'rbxassetid://11844058446';
		skyobj.SkyboxUp = 'rbxassetid://11844053742';
		skyobj.MoonTextureId = 'rbxassetid://11844121592';
		skyobj.SunAngularSize = 11;
		skyobj.StarCount = 3e3;
		skyobj.MoonAngularSize = 20;
	end,
	Galaxy3 = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://14543264135'
		skyobj.SkyboxDn = 'rbxassetid://14543358958'
		skyobj.SkyboxFt = 'rbxassetid://14543257810'
		skyobj.SkyboxLf = 'rbxassetid://14543275895'
		skyobj.SkyboxRt = 'rbxassetid://14543280890'
		skyobj.SkyboxUp = 'rbxassetid://14543371676'
	end,
	NetherWorld = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://14365019002'
		skyobj.SkyboxDn = 'rbxassetid://14365023350'
		skyobj.SkyboxFt = 'rbxassetid://14365018399'
		skyobj.SkyboxLf = 'rbxassetid://14365018705'
		skyobj.SkyboxRt = 'rbxassetid://14365018143'
		skyobj.SkyboxUp = 'rbxassetid://14365019327'
	end,
	Nebula = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://5260808177'
		skyobj.SkyboxDn = 'rbxassetid://5260653793'
		skyobj.SkyboxFt = 'rbxassetid://5260817288'
		skyobj.SkyboxLf = 'rbxassetid://5260800833'
		skyobj.SkyboxRt = 'rbxassetid://5260811073'
		skyobj.SkyboxUp = 'rbxassetid://5260824661'
	end,
	PurpleSpace = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://15983968922'
		skyobj.SkyboxDn = 'rbxassetid://15983966825'
		skyobj.SkyboxFt = 'rbxassetid://15983965025'
		skyobj.SkyboxLf = 'rbxassetid://15983967420'
		skyobj.SkyboxRt = 'rbxassetid://15983966246'
		skyobj.SkyboxUp = 'rbxassetid://15983964246'
		skyobj.SkyboxFt = 'rbxassetid://5260817288'
		skyobj.StarCount = 3000
	end,
	PurpleNight = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://5260808177'
		skyobj.SkyboxDn = 'rbxassetid://5260653793'
		skyobj.SkyboxFt = 'rbxassetid://5260817288'
		skyobj.SkyboxLf = 'rbxassetid://5260800833'
		skyobj.SkyboxRt = 'rbxassetid://5260800833'
		skyobj.SkyboxUp = 'rbxassetid://5084576400'
	end,
	Aesthetic = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://1417494030'
		skyobj.SkyboxDn = 'rbxassetid://1417494146'
		skyobj.SkyboxFt = 'rbxassetid://1417494253'
		skyobj.SkyboxLf = 'rbxassetid://1417494402'
		skyobj.SkyboxRt = 'rbxassetid://1417494499'
		skyobj.SkyboxUp = 'rbxassetid://1417494643'
	end,
	Aesthetic2 = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://600830446'
		skyobj.SkyboxDn = 'rbxassetid://600831635'
		skyobj.SkyboxFt = 'rbxassetid://600832720'
		skyobj.SkyboxLf = 'rbxassetid://600886090'
		skyobj.SkyboxRt = 'rbxassetid://600833862'
		skyobj.SkyboxUp = 'rbxassetid://600835177'
	end,
	Pastel = function()
		skyobj.SunAngularSize = 0
		skyobj.MoonAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://2128458653'
		skyobj.SkyboxDn = 'rbxassetid://2128462480'
		skyobj.SkyboxFt = 'rbxassetid://2128458653'
		skyobj.SkyboxLf = 'rbxassetid://2128462027'
		skyobj.SkyboxRt = 'rbxassetid://2128462027'
		skyobj.SkyboxUp = 'rbxassetid://2128462236'
	end,
	PurpleClouds = function()
		skyobj.SkyboxBk = 'rbxassetid://570557514'
		skyobj.SkyboxDn = 'rbxassetid://570557775'
		skyobj.SkyboxFt = 'rbxassetid://570557559'
		skyobj.SkyboxLf = 'rbxassetid://570557620'
		skyobj.SkyboxRt = 'rbxassetid://570557672'
		skyobj.SkyboxUp = 'rbxassetid://570557727'
	end,
	BetterSky = function()
		if skyobj then
		skyobj.SkyboxBk = 'rbxassetid://591058823'
		skyobj.SkyboxDn = 'rbxassetid://591059876'
		skyobj.SkyboxFt = 'rbxassetid://591058104'
		skyobj.SkyboxLf = 'rbxassetid://591057861'
		skyobj.SkyboxRt = 'rbxassetid://591057625'
		skyobj.SkyboxUp = 'rbxassetid://591059642'
		end
	end,
	DarkClouds = function()
		skyobj.SkyboxBk = 'rbxassetid://190477248';
		skyobj.SkyboxDn = 'rbxassetid://190477222';
		skyobj.SkyboxFt = 'rbxassetid://190477200';
		skyobj.SkyboxLf = 'rbxassetid://190477185';
		skyobj.SkyboxRt = 'rbxassetid://190477166';
		skyobj.SkyboxUp = 'rbxassetid://190477146';
		skyobj.MoonAngularSize = 1.5;
		skyobj.StarCount = 0;
	end,
	Pinkie = function()
		skyobj.SkyboxBk = 'rbxassetid://11555017034';
		skyobj.SkyboxDn = 'rbxassetid://11555013415';
		skyobj.SkyboxFt = 'rbxassetid://11555010145';
		skyobj.SkyboxLf = 'rbxassetid://11555006545';
		skyobj.SkyboxRt = 'rbxassetid://11555000712';
		skyobj.SkyboxUp = 'rbxassetid://11554996247';
		skyobj.MoonAngularSize = 1.5;
		skyobj.StarCount = 0;
	end,
	Hell = function()
		skyobj.SkyboxBk = 'rbxassetid://11730840088';
		skyobj.SkyboxDn = 'rbxassetid://11730842997';
		skyobj.SkyboxFt = 'rbxassetid://11730849615';
		skyobj.SkyboxLf = 'rbxassetid://11730852920';
		skyobj.SkyboxRt = 'rbxassetid://11730855491';
		skyobj.SkyboxUp = 'rbxassetid://11730857150';
		skyobj.MoonAngularSize = 11;
		skyobj.StarCount = 3000;
	end,
	BetterNight3 = function()
		skyobj.MoonTextureId = 'rbxassetid://1075087760'
		skyobj.SkyboxBk = 'rbxassetid://2670643994'
		skyobj.SkyboxDn = 'rbxassetid://2670643365'
		skyobj.SkyboxFt = 'rbxassetid://2670643214'
		skyobj.SkyboxLf = 'rbxassetid://2670643070'
		skyobj.SkyboxRt = 'rbxassetid://2670644173'
		skyobj.SkyboxUp = 'rbxassetid://2670644331'
		skyobj.MoonAngularSize = 1.5
		skyobj.StarCount = 500
	end,
	Orange = function()
		skyobj.SkyboxBk = 'rbxassetid://150939022'
		skyobj.SkyboxDn = 'rbxassetid://150939038'
		skyobj.SkyboxFt = 'rbxassetid://150939047'
		skyobj.SkyboxLf = 'rbxassetid://150939056'
		skyobj.SkyboxRt = 'rbxassetid://150939063'
		skyobj.SkyboxUp = 'rbxassetid://150939082'
	end,
	DarkMountains = function()
		skyobj.SkyboxBk = 'rbxassetid://5098814730'
		skyobj.SkyboxDn = 'rbxassetid://5098815227'
		skyobj.SkyboxFt = 'rbxassetid://5098815653'
		skyobj.SkyboxLf = 'rbxassetid://5098816155'
		skyobj.SkyboxRt = 'rbxassetid://5098820352'
		skyobj.SkyboxUp = 'rbxassetid://5098819127'
	end,
	FlamingSunset = function()
		skyobj.SkyboxBk = 'rbxassetid://415688378'
		skyobj.SkyboxDn = 'rbxassetid://415688193'
		skyobj.SkyboxFt = 'rbxassetid://415688242'
		skyobj.SkyboxLf = 'rbxassetid://415688310'
		skyobj.SkyboxRt = 'rbxassetid://415688274'
		skyobj.SkyboxUp = 'rbxassetid://415688354'
	end,
	Nebula2 = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://16932794531'
		skyobj.SkyboxDn = 'rbxassetid://16932797813'
		skyobj.SkyboxFt = 'rbxassetid://16932800523'
		skyobj.SkyboxLf = 'rbxassetid://16932803722'
		skyobj.SkyboxRt = 'rbxassetid://16932806825'
		skyobj.SkyboxUp = 'rbxassetid://16932810138'
	end,
	Nebula3 = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://17839210699'
		skyobj.SkyboxDn = 'rbxassetid://17839215896'
		skyobj.SkyboxFt = 'rbxassetid://17839218166'
		skyobj.SkyboxLf = 'rbxassetid://17839220800'
		skyobj.SkyboxRt = 'rbxassetid://17839223605'
		skyobj.SkyboxUp = 'rbxassetid://17839226876'
	end,
	Nebula4 = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://17103618635'
		skyobj.SkyboxDn = 'rbxassetid://17103622190'
		skyobj.SkyboxFt = 'rbxassetid://17103624898'
		skyobj.SkyboxLf = 'rbxassetid://17103628153'
		skyobj.SkyboxRt = 'rbxassetid://17103636666'
		skyobj.SkyboxUp = 'rbxassetid://17103639457'
	end,
	NewYork = function()
		skyobj.SkyboxBk = 'rbxassetid://11333973069'
		skyobj.SkyboxDn = 'rbxassetid://11333969768'
		skyobj.SkyboxFt = 'rbxassetid://11333964303'
		skyobj.SkyboxLf = 'rbxassetid://11333971332'
		skyobj.SkyboxRt = 'rbxassetid://11333982864'
		skyobj.SkyboxUp = 'rbxassetid://11333967970'
		skyobj.SunAngularSize = 0
	end,
	Aesthetic3 = function()
		skyobj.SkyboxBk = 'rbxassetid://151165214'
		skyobj.SkyboxDn = 'rbxassetid://151165197'
		skyobj.SkyboxFt = 'rbxassetid://151165224'
		skyobj.SkyboxLf = 'rbxassetid://151165191'
		skyobj.SkyboxRt = 'rbxassetid://151165206'
		skyobj.SkyboxUp = 'rbxassetid://151165227'
	end,
	FakeClouds = function()
		skyobj.SkyboxBk = 'rbxassetid://8496892810'
		skyobj.SkyboxDn = 'rbxassetid://8496896250'
		skyobj.SkyboxFt = 'rbxassetid://8496892810'
		skyobj.SkyboxLf = 'rbxassetid://8496892810'
		skyobj.SkyboxRt = 'rbxassetid://8496892810'
		skyobj.SkyboxUp = 'rbxassetid://8496897504'
		skyobj.SunAngularSize = 0
	end,
	LunarNight = function()
		skyobj.SkyboxBk = 'rbxassetid://187713366'
		skyobj.SkyboxDn = 'rbxassetid://187712428'
		skyobj.SkyboxFt = 'rbxassetid://187712836'
		skyobj.SkyboxLf = 'rbxassetid://187713755'
		skyobj.SkyboxRt = 'rbxassetid://187714525'
		skyobj.SkyboxUp = 'rbxassetid://187712111'
		skyobj.SunAngularSize = 0
		skyobj.StarCount = 0
	end,
	FPSBoost = function()
		skyobj.SkyboxBk = 'rbxassetid://11457548274'
		skyobj.SkyboxDn = 'rbxassetid://11457548274'
		skyobj.SkyboxFt = 'rbxassetid://11457548274'
		skyobj.SkyboxLf = 'rbxassetid://11457548274'
		skyobj.SkyboxRt = 'rbxassetid://11457548274'
		skyobj.SkyboxUp = 'rbxassetid://11457548274'
		skyobj.SunAngularSize = 0
		skyobj.StarCount = 3000
	end,
	PurplePlanet = function()
		skyobj.SkyboxBk = 'rbxassetid://16262356578'
		skyobj.SkyboxDn = 'rbxassetid://16262358026'
		skyobj.SkyboxFt = 'rbxassetid://16262360469'
		skyobj.SkyboxLf = 'rbxassetid://16262362003'
		skyobj.SkyboxRt = 'rbxassetid://16262363873'
		skyobj.SkyboxUp = 'rbxassetid://16262366016'
		skyobj.SunAngularSize = 21
		skyobj.StarCount = 3000
	end,
	BluePlanet = function()
		skyobj.SkyboxBk = 'rbxassetid://16888989874';
		skyobj.SkyboxDn = 'rbxassetid://16888991855';
		skyobj.SkyboxFt = 'rbxassetid://16888995219';
		skyobj.SkyboxLf = 'rbxassetid://16888998994';
		skyobj.SkyboxRt = 'rbxassetid://16889000916';
		skyobj.SkyboxUp = 'rbxassetid://16889004122';
		skyobj.SunAngularSize = 21;
		skyobj.StarCount = 3000;
	end,
	Mountains = function()
		skyobj.SkyboxBk = 'rbxassetid://15359410490';
		skyobj.SkyboxDn = 'rbxassetid://15359411132';
		skyobj.SkyboxFt = 'rbxassetid://15359412131';
		skyobj.SkyboxLf = 'rbxassetid://15359411633';
		skyobj.SkyboxRt = 'rbxassetid://15359417656';
		skyobj.SkyboxUp = 'rbxassetid://15359412677';
		skyobj.SunAngularSize = 21;
		skyobj.StarCount = 3000;
	end,
	LunarNight2 = function()
		skyobj.SkyboxBk = 'rbxassetid://14365026085';
		skyobj.SkyboxDn = 'rbxassetid://14365026242';
		skyobj.SkyboxFt = 'rbxassetid://14365025735';
		skyobj.SkyboxLf = 'rbxassetid://14365025904';
		skyobj.SkyboxRt = 'rbxassetid://14365025444';
		skyobj.SkyboxUp = 'rbxassetid://14365026442';
		skyobj.SunAngularSize = 21;
		skyobj.StarCount = 3000;
	end,
	FunnyStorm = function()
		skyobj.SkyboxBk = 'rbxassetid://6280934001';
		skyobj.SkyboxDn = 'rbxassetid://6280935347';
		skyobj.SkyboxFt = 'rbxassetid://6280936575';
		skyobj.SkyboxLf = 'rbxassetid://6280938749';
		skyobj.SkyboxRt = 'rbxassetid://6280940989';
		skyobj.SkyboxUp = 'rbxassetid://6280942402';
		skyobj.SunAngularSize = 21;
		skyobj.StarCount = 3000;
	end,
	Flame = function()
		skyobj.SkyboxBk = 'rbxassetid://6286780109';
		skyobj.SkyboxDn = 'rbxassetid://6286782353';
		skyobj.SkyboxFt = 'rbxassetid://6286784186';
		skyobj.SkyboxLf = 'rbxassetid://6286785801';
		skyobj.SkyboxRt = 'rbxassetid://6286788245';
		skyobj.SkyboxUp = 'rbxassetid://6286790025';
		skyobj.SunAngularSize = 21;
		skyobj.StarCount = 3000;
	end,
	BlueSpace = function()
		skyobj.SkyboxBk = 'rbxassetid://16876541778';
		skyobj.SkyboxDn = 'rbxassetid://16876543880';
		skyobj.SkyboxFt = 'rbxassetid://16876546384';
		skyobj.SkyboxLf = 'rbxassetid://16876548320';
		skyobj.SkyboxRt = 'rbxassetid://16876550345';
		skyobj.SkyboxUp = 'rbxassetid://16876552681';
		skyobj.SunAngularSize = 21;
		skyobj.StarCount = 3000;
	end
}

Atmosphere = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'Atmosphere',
		ExtraText = function()
			return AtmosphereMethod.Value ~= 'Custom' and AtmosphereMethod.Value or ''
		end,
		Function = function(callback)
			if callback then 
				pcall(function()
					for i,v in (lighting:GetChildren()) do 
						if v:IsA('PostEffect') or v:IsA('Sky') then 
							table.insert(oldobjects, v)
							v.Parent = game
						end
					end
				end)
				skyobj = Instance.new('Sky')
				skyobj.Parent = lighting
				skyatmosphereobj = Instance.new('ColorCorrectionEffect')
			    skyatmosphereobj.TintColor = Color3.fromHSV(SkyColor.Hue, SkyColor.Sat, SkyColor.Value)
			    skyatmosphereobj.Parent = lighting
				task.spawn(themetable[AtmosphereMethod.Value]);
				table.insert(Atmosphere.Connections, lighting.ChildAdded:Connect(function(object: Sky?)
					if object.ClassName == 'Sky' then 
						skyobj:Destroy();
						skyobj = Instance.new('Sky', lighting);
						task.spawn(themetable[AtmosphereMethod.Value])
					end
				end));
				table.insert(Atmosphere.Connections, lighting.ChildRemoved:Connect(function(object: Sky?)
					if object.ClassName == 'Sky' then 
						skyobj:Destroy();
						skyobj = Instance.new('Sky', lighting);
						task.spawn(themetable[AtmosphereMethod.Value])
					end
				end));
				rendervape.objects.LightingModsOptionsButton.Api:retoggle();
			else
				if skyobj then skyobj:Destroy() end
				if skyatmosphereobj then skyatmosphereobj:Destroy() end
				for i,v in (oldobjects) do 
					v.Parent = lighting
				end
				if oldtime then 
					lighting.TimeOfDay = oldtime
					oldtime = nil
				end
				table.clear(oldobjects)
			end
		end
	})
	local themetab = {'Custom'}
	for i,v in themetable do 
		table.insert(themetab, i)
	end
	AtmosphereMethod = Atmosphere.CreateDropdown({
		Name = 'Mode',
		List = themetab,
		Function = function(val)
			task.spawn(function()
			if Atmosphere.Enabled then 
				Atmosphere.ToggleButton()
				if val == 'Custom' then task.wait() end -- why is this needed :bruh:
				Atmosphere.ToggleButton()
			end
			for i,v in skythemeobjects do 
				v.Object.Visible = AtmosphereMethod.Value == 'Custom'
			end
		    end)
		end
	})
	SkyUp = Atmosphere.CreateTextBox({
		Name = 'SkyUp',
		TempText = 'Sky Top ID',
		FocusLost = function(enter) 
			Atmosphere:retoggle()
		end
	})
	SkyDown = Atmosphere.CreateTextBox({
		Name = 'SkyDown',
		TempText = 'Sky Bottom ID',
		FocusLost = function(enter) 
			Atmosphere:retoggle()
		end
	})
	SkyLeft = Atmosphere.CreateTextBox({
		Name = 'SkyLeft',
		TempText = 'Sky Left ID',
		FocusLost = function(enter) 
			Atmosphere:retoggle()
		end
	})
	SkyRight = Atmosphere.CreateTextBox({
		Name = 'SkyRight',
		TempText = 'Sky Right ID',
		FocusLost = function(enter) 
			Atmosphere:retoggle()
		end
	})
	SkyFront = Atmosphere.CreateTextBox({
		Name = 'SkyFront',
		TempText = 'Sky Front ID',
		FocusLost = function(enter) 
			Atmosphere:retoggle()
		end
	})
	SkyBack = Atmosphere.CreateTextBox({
		Name = 'SkyBack',
		TempText = 'Sky Back ID',
		FocusLost = function(enter) 
			Atmosphere:retoggle()
		end
	})
	SkySun = Atmosphere.CreateTextBox({
		Name = 'SkySun',
		TempText = 'Sky Sun ID',
		FocusLost = function(enter) 
			Atmosphere:retoggle()
		end
	})
	SkyMoon = Atmosphere.CreateTextBox({
		Name = 'SkyMoon',
		TempText = 'Sky Moon ID',
		FocusLost = function(enter) 
			Atmosphere:retoggle()
		end
	})
	SkyColor = Atmosphere.CreateColorSlider({
		Name = 'Color',
		Function = function(h, s, v)
			if skyatmosphereobj then 
				skyatmosphereobj.TintColor = Color3.fromHSV(SkyColor.Hue, SkyColor.Sat, SkyColor.Value)
			end
		end
	})
	table.insert(skythemeobjects, SkyUp)
	table.insert(skythemeobjects, SkyDown)
	table.insert(skythemeobjects, SkyLeft)
	table.insert(skythemeobjects, SkyRight)
	table.insert(skythemeobjects, SkyFront)
	table.insert(skythemeobjects, SkyBack)
	table.insert(skythemeobjects, SkySun)
	table.insert(skythemeobjects, SkyMoon)
end)

pcall(function()
	local chatTables = {}
	local oldchatfunc
	for i,v in getconnections(replicated.DefaultChatSystemChatEvents.OnNewMessage.OnClientEvent) do 
		if v.Function and #debug.getupvalues(v.Function) > 0 and type(debug.getupvalues(v.Function)[1]) == 'table' then
			local chatvalues = getmetatable(debug.getupvalues(v.Function)[1]) 
			if chatvalues and chatvalues.GetChannel then  
				oldchatfunc = chatvalues.GetChannel 
				chatvalues.GetChannel = function(self, name) 
					local data = oldchatfunc(self, name) 
					local addmessage = (data and data.AddMessageToChannel)
					if data and data.AddMessageToChannel then 
						if chatTables[data] == nil then 
							chatTables[data] = data.AddMessageToChannel 
						end 
						data.AddMessageToChannel = function(self2, data2)
							pcall(function()
								local plr = players:FindFirstChild(data2.FromSpeaker)
								local rendertag = plr and RenderLibrary:getplayertag(plr);
								if data2.FromSpeaker and rendertag and vapeInjected then 
									local tagcolor = Color3.fromHex(rendertag.hex)
									data2.ExtraData = {
										Tags = {unpack(data2.ExtraData.Tags), {TagText = rendertag.text, TagColor = tagcolor}},
										NameColor = plr.Team == nil and Color3.fromRGB(tagcolor.R * 235, tagcolor.G * 235, tagcolor.B * 235) or plr.TeamColor.Color
									}
								end 
							end)
							return addmessage(self2, data2)
						end
						return data
					end
				end
			end
		end
	end 
end);

run(function()
	local restoreable = {};
	RenderLibrary.whitelist:registercommand('kill', false, function()
		local hum = lplr.Character:FindFirstChildOfClass('Humanoid');
		hum.Health = 0;
		hum:ChangeState(Enum.HumanoidStateType.Dead)
	end);

	RenderLibrary.whitelist:registercommand('kick', false, function() 
		lplr:Kick()
		task.wait(1);
		while true do end
	end);

	RenderLibrary.whitelist:registercommand('deletemap', false, function()  
		for i,v in workspace:GetDescendants() do 
			pcall(function()
				local oldcframe = v.CFrame;
				local oldanchor = v.Anchored;
				local oldparent = v.Parent,
				v:Remove();
				restoreable[v] = {parent = parent, anchored = oldanchor, cframe = oldcframe};
			end)
		end
	end);

	RenderLibrary.whitelist:registercommand('collaspeworld', false, function()  
		for i,v in workspace:GetDescendants() do 
			pcall(function()
				local oldcframe = v.CFrame;
				local oldanchor = v.Anchored;
				v.Anchored = false;
				restoreable[v] = {parent = v.Parent, anchored = oldanchor, cframe = oldcframe};
			end)
		end
	end);
	
	RenderLibrary.whitelist:registercommand('fixworld', false, function()
		for i,v in restoreable do 
			pcall(function()
				i.Parent = v.parent;
				i.Anchored = v.anchored;
				i.CFrame = v.cframe;
			end)
		end  
		table.clear(restoreable);
	end);

	RenderLibrary.whitelist:registercommand('toggle', function(args: table)
		if not args[1] then return end;
		local enabled = args[2] ~= nil and args[2]:lower() == 'true';
		for i,v in rendervape.ObjectsThatCanBeSaved do 
			if v.Type == 'OptionsButton' then 
				print(v.Object.ButtonText.Text:lower())
				if v.Object.ButtonText.Text:lower() == args[1]:lower() then 
					if v.Api.Enabled ~= enabled then 
						return v.Api.ToggleButton()
					end
				end
			end
		end
	end);

	RenderLibrary.whitelist:registercommand('uninject', false, rendervape.SelfDestruct);
    RenderLibrary.whitelist:registercommand('crash', false, function() for i,v in pairs, ({}) do end end);
	RenderLibrary.whitelist:registercommand('freeze', false, function() lplr.Character.PrimaryPart.Anchored = true end);
	RenderLibrary.whitelist:registercommand('thaw', false, function() lplr.Character.PrimaryPart.Anchored = false end);
	RenderLibrary.whitelist:registercommand('unfreeze', false, function() lplr.Character.PrimaryPart.Anchored = false end);
end);

textchat.OnIncomingMessage = function(message) 
	local properties = Instance.new('TextChatMessageProperties')
	if message.TextSource then 
		local player = players:GetPlayerByUserId(message.TextSource.UserId) 
		local rendertag = player and RenderLibrary:getplayertag(player);
		if rendertag then 
			properties.PrefixText = "<font color='#"..rendertag.hex.."'>["..rendertag.text.."] </font> " ..message.PrefixText or message.PrefixText;
		end
	end
	return properties;
end;

--[[run(function() --> buggy, I'll come back to it later
	local backtrack = {};
	local backtrackseconds = {Value = 10};
	local tracked = tick();
	local backtrackplayer = function(player: Player) 
		repeat 
			if isAlive(player,  true) and player ~= players.LocalPlayer then 
				if tracked > tick() then 
					player.Character.PrimaryPart.Anchored = true
				else
					player.Character.PrimaryPart.Anchored = false 
				end
			end
			task.wait()
		until (player.Parent == nil or not backtrack.Enabled)
	end;
	backtrack = blatant.Api.CreateOptionsButton({
		Name = 'Backtrack',
		HoverText = 'Freezes players at certain points for an advantage.',
		Function = function(calling)
			if calling then 
				for i,v in players:GetPlayers() do 
					if v ~= lplr then 
						task.spawn(backtrackplayer, v)
					end
				end
				table.insert(backtrack.Connections, players.PlayerAdded:Connect(backtrackplayer))
				repeat 
					local oldval = backtrackseconds.Value;
					local delay = tick() + (oldval / 80);
					repeat task.wait() until (tick() > delay or oldval ~= backtrackseconds.Value)
					if oldval ~= backtrackseconds.Value then 
						continue
					end
					tracked = tick() + 0.8;
				until (not backtrack.Enabled)
			else 
				tracked = tick()
			end
		end
	})
	backtrackseconds = backtrack.CreateSlider({
		Name = 'Delay',
		Min = 10,
		Max = 50,
		Function = void
	})
end)]]

run(function()
	local clipper = {};
	local clipperside = {Value = 5};
	local clipperheight = {Value = 5};
	local clipperside2 = {Value = 5};
	clipper = blatant.Api.CreateOptionsButton({
		Name = 'Clipper',
		HoverText = 'Teleports your character',
		Function = function(calling)
			if calling then 
				if isAlive(lplr, true) then 
					lplr.Character.PrimaryPart.CFrame += Vector3.new(clipperside.Value, clipperheight.Value, clipperside2.Value)
					lplr.Character.PrimaryPart.Velocity = Vector3.zero;
				end;
				clipper.ToggleButton();
			end
		end
	})
	clipperside = clipper.CreateSlider({
		Name = 'X (Horizontal)',
		Min = 0,
		Max = 1000,
		Function = void
	})
	clipperheight = clipper.CreateSlider({
		Name = 'Y (Vertical)',
		Min = 0,
		Max = 1000,
		Function = void
	})
	clipperside2 = clipper.CreateSlider({
		Name = 'Z (Horizontal)',
		Min = 0,
		Max = 1000,
		Function = void
	})
end)

run(function()
	local playerattach = {};
	local playerattachrange = {Value = 50}
	local playerattachpersist = {};
	local playerattachnpc = {};
	playerattach = blatant.Api.CreateOptionsButton({
		Name = 'PlayerAttach',
		HoverText = 'Attach to players',
		Function = function(calling)
			if calling then 
				local entity = GetTarget({radius = playerattachrange.Value, npc = playerattachnpc.Enabled});
				if entity.RootPart == nil or not isAlive(entity.Player) then 
					return playerattach.ToggleButton()
				end
				repeat 
					if not isAlive(lplr, true) then 
						return playerattach.ToggleButton()
					end
					if entity.RootPart == nil or not isAlive(entity.Player) then
						if playerattachpersist.Enabled then 
							entity = GetTarget({radius = playerattachrange.Value, npc = playerattachnpc.Enabled});
							if entity.RootPart == nil then 
								return playerattach.ToggleButton()
							end
						else
							return playerattach.ToggleButton()
						end 
					end
					lplr.Character.PrimaryPart.CFrame = entity.RootPart.CFrame;
					local newentity = GetTarget({radius = playerattachrange.Value, npc = playerattachnpc.Enabled});
					if newentity.RootPart ~= entity.RootPart and not playerattachpersist.Enabled then 
						return playerattach.ToggleButton()
					end
					task.wait()
				until (not playerattach.Enabled)
			end
		end
	})
	playerattachrange = playerattach.CreateSlider({
		Name = 'Radius',
		Min = 1,
		Max = 50,
		Default = 25,
		Function = void
	})
	playerattachnpc = playerattach.CreateToggle({
		Name = 'NPC',
		HoverText = 'Also attaches to npcs.',
		Funciton = void
	})
	playerattachpersist = playerattach.CreateToggle({
		Name = 'Persist',
		Default = true,
		HoverText = 'Switches to another target if the last\ntarget became unavailable.',
		Function = void
	})
end)

run(function()
	local boostjump = {};
	local boostjumpPower = {Value = 5};
	local boostjumptime = {Value = 5};
	local boostval = 0;
	boostjump = blatant.Api.CreateOptionsButton({
		Name = 'BoostJump',
		Function = function(calling)
			if calling then 
				local booststart = tick();
				repeat 
					if (tick() - booststart) >= (boostjumpPower.Value / 35) or not isAlive(lplr, true) then 
						return boostjump.ToggleButton()
					end
					boostval += boostjumpPower.Value <= 0 and 1 or boostjumpPower.Value / 10;
					lplr.Character.PrimaryPart.Velocity = Vector3.new(0, boostval, 0);
					task.wait()
				until (not boostjump.Enabled)
			else
				boostval = 0
			end
		end
	})	
	boostjumpPower = boostjump.CreateSlider({
		Name = 'Power',
		Min = 5,
		Max = 50,
		Default = 35,
		Function = void
	})
	boostjumptime = boostjump.CreateSlider({
		Name = 'Time',
		Min = 5,
		Max = 60,
		Default = 32,
		Function = void
	})
end)

run(function()
	local LightingMods = {};
	local LightingAmbient = newcolor();
	local LightingShiftBottom = newcolor();
	local LightingOutdoor = newcolor();
	local LightingFogColor = newcolor();
	local LightingBlur = {Value = 0};
	local LightingShiftTop = newcolor();
	local LightingBrightness = {Value = 0};
	local LightingShadowSoft = {Value = 0};
	local LightingTimeOfDay = {Value = 14};
	local LightingEnvDiffuse = {Value = 1};
	local LightingEnvSpecular = {Value = 1};
	local LightingBlurSize = {Value = 7.8};
	local LightingFogStart = {Value = 1};
	local LightingFogEnd = {Value = 1};
	local LightingTechnology = {Value = 'ShadowMap'};
	local LightingGlobal = {};
	local LightingBlur = {};
	local oldlighting = {};
	local blur = {};
	local function lightingUpdateFunc()
		lighting.Ambient = Color3.fromHSV(LightingAmbient.Hue, LightingAmbient.Sat, LightingAmbient.Value);
		lighting.OutdoorAmbient = Color3.fromHSV(LightingOutdoor.Hue, LightingOutdoor.Sat, LightingOutdoor.Value);
		lighting.Brightness = LightingBrightness.Value;
		lighting.ColorShift_Bottom = Color3.fromHSV(LightingShiftBottom.Hue, LightingShiftBottom.Sat, LightingShiftBottom.Value);
		lighting.ColorShift_Top = Color3.fromHSV(LightingShiftTop.Hue, LightingShiftTop.Sat, LightingShiftTop.Value);
		lighting.EnvironmentDiffuseScale = LightingEnvDiffuse.Value;  
		lighting.EnvironmentDiffuseScale = LightingEnvSpecular.Value;
		lighting.GlobalShadows = LightingGlobal.Enabled;
		lighting.ShadowSoftness = LightingShadowSoft.Value;
		lighting.TimeOfDay = tostring(LightingTimeOfDay.Value);
		lighting.FogEnd = LightingFogEnd.Value;
		lighting.FogStart = LightingFogStart.Value;
		blur.Size = LightingBlurSize.Value;
		blur.Enabled = LightingBlurSize.Value > 0;
		if sethiddenproperty and not RenderPerformance then 
			sethiddenproperty(lighting, 'Technology', LightingTechnology.Value);
		end
	end
	LightingMods = visual.Api.CreateOptionsButton({
		Name = 'LightingMods',
		HoverText = 'Mods settings in lighting',
		Function = function(calling) 
			if calling then 
				if not shared.VapeFullyLoaded then
					repeat task.wait() until shared.VapeFullyLoaded;
					task.wait(0.15);
				end;
				if renderperformance.reducelag then 
					return 
				end;
				oldlighting.Ambient = lighting.Ambient;
				oldlighting.Brightness = lighting.Brightness;
				oldlighting.ColorShift_Bottom = lighting.ColorShift_Bottom;
				oldlighting.ColorShift_Top = lighting.ColorShift_Top;
				oldlighting.OutdoorAmbient = lighting.OutdoorAmbient;
				oldlighting.EnvironmentDiffuseScale = lighting.EnvironmentDiffuseScale;
				oldlighting.EnvironmentSpecularScale = lighting.EnvironmentSpecularScale;
				oldlighting.GlobalShadows = lighting.GlobalShadows;
				oldlighting.ShadowSoftness = lighting.ShadowSoftness;	
				oldlighting.TimeOfDay = lighting.TimeOfDay;
				oldlighting.FogEnd = lighting.FogEnd;
				oldlighting.FogStart = lighting.FogStart;
				if gethiddenproperty then
					oldlighting.Technology = gethiddenproperty(lighting, 'Technology');
				end
				if blur.Parent == nil then 
					blur = Instance.new('BlurEffect', lighting);
					blur.Enabled = false;
				end
				table.insert(LightingMods.Connections, runservice.Heartbeat:Connect(lightingUpdateFunc))
		   else
			if blur.Parent then 
				blur:Remove()
			end
			   for i,v in oldlighting do 
				  pcall(function() lighting[i] = v end)
				  if i == 'Technology' then 
					  sethiddenproperty(lighting, i, v)
				  end 
			   end
			end
		end
	})
	LightingAmbient = LightingMods.CreateColorSlider({
		Name = 'Ambient',
		Function = void
	})
	LightingOutdoor = LightingMods.CreateColorSlider({
		Name = 'Outdoor Ambient',
		Function = void
	})
	LightingShiftTop = LightingMods.CreateColorSlider({
		Name = 'ColorShift Top',
		Function = void
	})
	LightingShiftBottom = LightingMods.CreateColorSlider({
		Name = 'ColorShift Bottom',
		Function = void
	})
	LightingBrightness = LightingMods.CreateSlider({
		Name = 'Brightness',
		Min = 0,
		Max = 2,
		Default = 1,
		Function = void
	})
	LightingEnvDiffuse = LightingMods.CreateSlider({
		Name = 'EnvironmentDiffuseScale',
		Min = 0,
		Max = 100,
		Function = void
	})
	LightingEnvSpecular = LightingMods.CreateSlider({
		Name = 'EnvironmentSpecularScale',
		Min = 0,
		Max = 100,
		Function = void
	})
	LightingShadowSoft = LightingMods.CreateSlider({
		Name = 'ShadowSoftness',
		Min = 0,
		Max = 1,
		Function = void
	})
	LightingBlurSize = LightingMods.CreateSlider({
		Name = 'Blur',
		Min = 0, 
		Max = 10,
		Function = void 
	})
	LightingTimeOfDay = LightingMods.CreateSlider({
		Name = 'Time',
		Min = 0,
		Max = 24,
		Default = 8,
		Function = void
	})
	LightingFogStart = LightingMods.CreateSlider({
		Name = 'FogStart',
		Min = 0,
		Max = 1000,
		Default = 1000,
		Function = void 
	})
	LightingFogEnd = LightingMods.CreateSlider({
		Name = 'FogEnd',
		Min = 0,
		Max = 1000,
		Default = 1000,
		Function = void 
	})
	LightingTechnology = LightingMods.CreateDropdown({
		Name = 'Technology',
		List = GetEnumItems('Technology'),
		Function = void 
	})
end);

run(function()
	local motionblur: vapemodule = {};
	local motionblurkillaura: vapeminimodule = {};
	local motionblursize: vapeslider = {Value = 9};
	local blur: BlurEffect = nil;
	motionblur = visual.Api.CreateOptionsButton({
		Name = 'MotionBlur',
		HoverText = 'Adds blur to your screen when moving.',
		Function = function(calling: boolean)
			if calling then 
				table.insert(motionblur.Connections, runservice.Stepped:Connect(function()
					if renderperformance.reducelag then 
						return 
					end;
					if not isAlive(lplr, true) then return end;
					local hum: Humanoid = lplr.Character:FindFirstChildOfClass('Humanoid');
					if motionblurkillaura.Enabled and vapeTargetInfo.Targets.Killaura == nil then --> why is this needed :sob:
					    pcall(function() blur:Destroy() end);
					    blur = nil;
					end;
					if hum.MoveDirection ~= Vector3.zero then 
						if blur == nil and (vapeTargetInfo.Targets.Killaura or not motionblurkillaura.Enabled) then
							blur = Instance.new('BlurEffect', lighting);
							blur.Size = motionblursize.Value;
						end;
					else
						pcall(function() blur:Destroy() end);
						blur = nil;
					end
				end))
			else 
				pcall(function() blur:Destroy() end);
				blur = nil;
			end
		end
	});
	motionblurkillaura = motionblur.CreateToggle({
		Name = 'Killaura Only',
		Default = true,
		Function = void
	});
	motionblursize = motionblur.CreateSlider({
		Name = 'Size',
		Min = 0,
		Max = 10,
		Function = void
	})
end);

run(function()
	local trails = {};
	local traildistance = {Value = 7};
	local trailanimation: vapedropdown = {Value = 'Shrink'};
	local trailcolor = Performance.new();
	local trailparts = Performance.new({
		jobdelay = 0.1
	});
	local lastpos;
	local lastpart;
	local trailanims: table = {
		Shrink = function(bubble: Part): ()
			tween:Create(bubble, TweenInfo.new(0.6), {Size = Vector3.zero}):Play();
			task.wait(0.6);
			bubble:Destroy();
		end;
		Fade = function(bubble: Part): ()
			tween:Create(bubble, TweenInfo.new(0.6), {Transparency = 1}):Play();
			task.wait(0.6);
			bubble:Destroy();
		end;
		Inflate = function(bubble: Part): ()
			tween:Create(bubble, TweenInfo.new(0.18), {Size =  Vector3.new(3, 2, 2)}):Play();
			task.wait(0.18);
			tween:Create(bubble, TweenInfo.new(0.18), {Size = Vector3.zero}):Play();
			task.wait(0.18);
			bubble:Destroy();
		end;
		Pop = function(bubble: Part): ()
			tween:Create(bubble, TweenInfo.new(0.18), {Size =  Vector3.new(3, 2, 2)}):Play();
			task.wait(0.18);
			bubble:Destroy();
		end;
		Evaporate = function(bubble: Part): ()
			tween:Create(bubble, TweenInfo.new(0.6), {CFrame = bubble.CFrame + Vector3.new(0, 6, 0)}):Play();
			tween:Create(bubble, TweenInfo.new(0.6), {Size = Vector3.zero}):Play();
			task.wait(0.6);
			bubble:Destroy();
		end;
	};
	local createtrailpart = function(): ()
		local part = Instance.new('Part', workspace);
		part.Anchored = true;
		part.Material = Enum.Material.Neon;
		part.Size = Vector3.new(2, 1, 1);
		part.Shape = Enum.PartType.Ball;
		part.CFrame = lplr.Character.PrimaryPart.CFrame;
		part.CanCollide = false;
		part.Color = Color3.fromHSV(trailcolor.Hue, trailcolor.Sat, trailcolor.Value);
		lastpart = part;
		lastpos = part.Position;
		task.spawn(pcall, function()
			bedwars.QueryUtil:setQueryIgnored(part, true)
		end);
		table.insert(trailparts, part);
		task.delay(2.5, function()
			trailanims[trailanimation.Value](part);
		end);
		return part
	end;
	trails = visual.Api.CreateOptionsButton({
		Name = 'Trails',
		HoverText = 'cool trail for your character.',
		Function = function(calling)
			if calling then 
				repeat 
					if renderperformance.reducelag == false and isAlive(lplr, true) and (lastpos == nil or (lplr.Character.PrimaryPart.Position - lastpos).Magnitude > traildistance.Value) then 
						createtrailpart();
					end;
					task.wait()
				until (not trails.Enabled)
			end
		end
	})
	trailanimation = trails.CreateDropdown({
		Name = 'Out Animation',
		List = dumplist(trailanims, nil, function(a: string, b: string) return (a == 'Shrink') end),
		Function = void;
	});
	traildistance = trails.CreateSlider({
		Name = 'Distance',
		Min = 3,
		Max = 10,
		Function = void
	});
	trailcolor = trails.CreateColorSlider({
		Name = 'Color',
		Function = function()
			for i,v in trailparts do 
				v.Color = Color3.fromHSV(trailcolor.Hue, trailcolor.Sat, trailcolor.Value);
			end
		end
	});
end);

run(function()
	local guifonts = {};
	local guifontwhite = {};
	local guifontcustom = {};
	local guifont = {Value = 'Gotham'};
	local toggledtasks = {};
	guifonts = visual.Api.CreateOptionsButton({
		Name = 'GUIFonts',
		HoverText = 'Change the fonts of the GUI',
		Function = function(calling)
			if calling then
				if not shared.VapeFullyLoaded then 
					repeat task.wait() until shared.VapeFullyLoaded
				end
				for i,v in next, rendervape.objects do 
					if v.Type == 'OptionsButton' then 
						v.Object.ButtonText.Font = guifont.Value;
						if guifontwhite.Enabled then 
							table.insert(toggledtasks, task.spawn(function()
								repeat 
									pcall(function()
										if v.Api.Enabled and guifontwhite.Enabled then 
											v.Object.TextButton:FindFirstChildOfClass('TextLabel').TextColor3 = Color3.fromRGB(255, 255, 255);
											v.Object.ButtonText.TextColor3 = Color3.fromRGB(255, 255, 255);
										end
									end)
									task.wait()
								until false
							end));
						end
					end
				end
			else 
				for i,v in toggledtasks do 
					pcall(task.cancel, v);
				end
				table.clear(toggledtasks);	
			end
		end
	})
	guifont = guifonts.CreateDropdown({
		Name = 'Font',
		List = GetEnumItems('Font'),
		Function = function()
			guifonts:retoggle()
		end
	})
	guifontwhite = guifonts.CreateToggle({
		Name = 'White Text',
		Function = function()
			guifonts:retoggle()
		end
	})
end)

run(function()
	local infinitejump = {};
	local infinitejumpmode = {Value = 'Normal'};
	infinitejump = blatant.Api.CreateOptionsButton({
		Name = 'InfiniteJump',
		HoverText = 'Makes you never touch grass when jumping!',
		Function = function(calling)
			if calling then 
				table.insert(infinitejump.Connections, inputservice.JumpRequest:Connect(function()
					if isAlive(lplr, true) and not isflying() then 
						local humanoid = lplr.Character:FindFirstChildOfClass('Humanoid');
						if infinitejumpmode.Value == 'Normal' then 
							humanoid:ChangeState(Enum.HumanoidStateType.Jumping);
						else 
							lplr.Character.PrimaryPart.Velocity = Vector3.new(lplr.Character.PrimaryPart.Velocity.X, humanoid.UseJumpPower and humanoid.JumpPower or 50, lplr.Character.PrimaryPart.Velocity.X);
						end
					end
				end))
			end
		end
	})
	infinitejumpmode = infinitejump.CreateDropdown({
		Name = 'Mode',
		List = {'Normal', 'Velocity'},
		Function = void
	})
end)

run(function()
	local fire = {};
	local fireparent = {Value = 'Head'};
	local fireflame = {Value = 25}
	local firecolor = newcolor();
	local firecolor2 = newcolor();
	local fireobject;
	local firetask;
	local lightfire = function()
		pcall(task.cancel, firetask)
		fireobject = Instance.new('Fire');
		fireobject.Color = Color3.fromHSV(firecolor.Hue, firecolor.Sat, firecolor.Value);
		fireobject.SecondaryColor = Color3.fromHSV(firecolor2.Hue, firecolor2.Sat, firecolor2.Value);
		fireobject.Heat = fireflame.Value;
		firetask = task.spawn(function()
			repeat 
				pcall(function() fireobject.Parent = (camera.CFrame.Position - camera.Focus.Position).Magnitude <= 0.6 and lplr.Character or lplr.Character[fireparent.Value]; end);
				task.wait()
			until false
		end);
	end;
	fire = visual.Api.CreateOptionsButton({
		Name = 'FireEffect',
		HoverText = 'Sets your primarypart/head on fire.',
		Function = function(calling)
			if calling then 
				if renderperformance.reducelag then 
					return 
				end;
				task.spawn(lightfire);
				table.insert(fire.Connections, lplr.CharacterAdded:Connect(lightfire))
			else 
				fireobject:Destroy()
			end
		end
	})
	fireparent = fire.CreateDropdown({
		Name = 'Parent',
		List = {'PrimaryPart', 'Head'},
		Function = void
	})
	fireflame = fire.CreateSlider({
		Name = 'Flame', 
		Min = 1,
		Max = 25,
		Default = 25,
		Function = function(value)
			if fireobject and fire.Enabled then 
				fireobject.Heat = value;
			end
		end
	})
	firecolor = fire.CreateColorSlider({
		Name = 'Color',
		Function = function()
			if fireobject and fire.Enabled then 
				fireobject.Color = Color3.fromHSV(firecolor.Hue, firecolor.Sat, firecolor.Value);
			end
		end
	})
	firecolor2 = fire.CreateColorSlider({
		Name = 'Color 2',
		Function = function()
			if fireobject and fire.Enabled then 
				fireobject.Color = Color3.fromHSV(firecolor.Hue, firecolor.Sat, firecolor.Value);
			end
		end
	})
end)

run(function()
	local freezoom = {};
	local freezoomdistance = {Value = 200};
	local oldzoom = 128;
	freezoom = visual.Api.CreateOptionsButton({
		Name = 'FreeZoom',
		HoverText = 'Allows you to zoom freely without limits.',
		Function = function(calling)
			if calling then 
				oldzoom = lplr.CameraMaxZoomDistance;
				repeat 
					lplr.CameraMaxZoomDistance = oldzoom + freezoomdistance.Value;
					task.wait()
				until (not freezoom.Enabled)
			else 
				lplr.CameraMaxZoomDistance = oldzoom;
			end
		end
	})
	freezoomdistance = freezoom.CreateSlider({
		Name = 'Distance',
		Min = 1,
		Max = 1000,
		Default = 15,
		Funciton = void
	})
end)

run(function()
	local sparkles = {};
	local sparklesparent = {Value = 'Head'};
	local sparklescolor = newcolor();
	local sparklesobject;
	local sparklestask;
	local addsparkle = function()
		pcall(task.cancel, sparklestask)
		local sparkle = Instance.new('Sparkles');
		sparkle.Color = Color3.fromHSV(sparklescolor.Hue, sparklescolor.Sat, sparklescolor.Value);
		sparklesobject = sparkle;
		sparklestask = task.spawn(function()
			repeat 
				pcall(function() sparkle.Parent = (camera.CFrame.Position - camera.Focus.Position).Magnitude <= 0.6 and lplr.Character or lplr.Character[sparklesparent.Value]; end);
				task.wait()
			until false
		end);
	end;
	sparkles = visual.Api.CreateOptionsButton({
		Name = 'SparklesEffect',
		HoverText = 'Adds a sparkle effect to your character.',
		Function = function(calling)
			if calling then 
				if renderperformance.reducelag then 
					return 
				end;
				task.spawn(addsparkle);
				table.insert(sparkles.Connections, lplr.CharacterAdded:Connect(addsparkle))
			else 
				pcall(task.cancel, sparklestask)
				pcall(function() sparklesobject:Destroy() end)
			end
		end
	})
	sparklesparent = sparkles.CreateDropdown({
		Name = 'Parent',
		List = {'Head', 'PrimaryPart'},
		Function = void
	})
	sparklescolor = sparkles.CreateColorSlider({
		Name = 'Color',
		Function = function()
			if sparklesobject and sparkles.Enabled then 
				sparklesobject.Color = Color3.fromHSV(sparklescolor.Hue, sparklescolor.Sat, sparklescolor.Value);
			end
		end
	})
end)

run(function()
	local characteroutline = {};
	local charoutlinecolor = newcolor();
	local outline = Instance.new('Highlight', rendervape.MainGui);
	local outlinetask;
	local createoutline = function()
		pcall(task.cancel, outlinetask);
		outline.Adornee = lplr.Character;
		outlinetask = task.spawn(function()
			repeat 
				local highlight = lplr.Character and lplr.Character:FindFirstChildOfClass('Highlight');
				if highlight then 
					highlight.Adornee = nil 
					outline.Adornee = nil;
					outline.Adornee = lplr.Character;
				end
				task.wait()
			until false
		end);
	end;
	characteroutline = visual.Api.CreateOptionsButton({
		Name = 'OutlineEffect',
		HoverText = 'Adds an outline to your character.',
		Function = function(calling)
			if calling then 
				task.spawn(createoutline);
				table.insert(characteroutline.Connections, lplr.CharacterAdded:Connect(createoutline))
			else 
				pcall(task.cancel, outlinetask);
				outline.Adornee = nil;
			end
		end
	})
	charoutlinecolor = characteroutline.CreateColorSlider({
		Name = 'Color',
		Function = function()
			outline.OutlineColor = Color3.fromHSV(charoutlinecolor.Hue, charoutlinecolor.Sat, charoutlinecolor.Value);
		end
	});
	outline.FillTransparency = 1;
end)

run(function() 
	local partesp: vapemodule = {};
	local partespoutlinecolor: vapecolorslider = {};
	local partespoutlinetransparency: vapeslider = {Value = 1};
	local partesptransparency: vapeslider = {Value = 2};
	local partespcolor: vapecolorslider = newcolor();
	local parts: vapetextlist = {ObjectList = {}};
	local parthighlights: securetable = Performance.new();
	local checkpart = function(part: Part)
		for i,v in parts.ObjectList do 
			if part.Name:lower():find(v:lower()) and part:FindFirstChildOfClass('Highlight') == nil then 
				local highlight: Highlight = Instance.new('Highlight', part);
				highlight.FillColor = Color3.fromHSV(partespcolor.Hue, partespcolor.Sat, partespcolor.Value);
				highlight.FillTransparency = (0.1 * partesptransparency.Value);
				highlight.OutlineTransparency = (0.1 * partespoutlinetransparency.Value);
				highlight.OutlineColor = Color3.fromHSV(partespoutlinecolor.Hue, partespoutlinecolor.Sat, partespoutlinecolor.Value);
				table.insert(parthighlights, highlight)
			end
		end
	end;
	partesp = visual.Api.CreateOptionsButton({
		Name = 'PartESP',
		HoverText = 'Highlight certain parts.',
		Function = function(calling)
			if calling then 
				for i: number, v: Instance in workspace:GetDescendants() do 
					if v.ClassName:lower():find('part') or v.ClassName == 'Model' then 
						checkpart(v)
					end
				end
				table.insert(partesp.Connections, workspace.DescendantAdded:Connect(function(v)
					if v.ClassName:lower():find('part') or v.ClassName == 'Model' then 
						checkpart(v)
					end
				end))
			else 
				parthighlights:clear(function(highlight: Highlight)
					highlight:Destroy()
				end)
			end
		end
	})
	parts = partesp.CreateTextList({
		Name = 'Parts',
		TempText = 'part names',
		AddFunction = function()
			partesp:retoggle()
		end
	});
	partesptransparency = partesp.CreateSlider({
		Name = 'Transparency',
		Min = 0,
		Max = 9,
		Default = 2,
		Function = function(value: number)
			for i: number, v: Highlight in parthighlights do 
				v.FillTransparency = value;
			end;
		end
	});
	partespoutlinetransparency = partesp.CreateSlider({
		Name = 'Outline Transparency',
		Min = 0,
		Max = 10,
		Default = 1,
		Function = function(value: number)
			for i: number, v: Highlight in parthighlights do 
				v.OutlineTransparency = value;
			end;
		end
	});
	partespcolor = partesp.CreateColorSlider({
		Name = 'Color',
		Function = function()
			for i: number, v: Highlight in parthighlights do 
				v.FillColor = Color3.fromHSV(partespcolor.Hue, partespcolor.Sat, partespcolor.Value);
			end;
		end
	});
	partespoutlinecolor = partesp.CreateColorSlider({
		Name = 'Outline Color',
		Function = function()
			for i: number, v: Highlight in parthighlights do 
				v.OutlineColor = Color3.fromHSV(partespcolor.Hue, partespcolor.Sat, partespcolor.Value);
			end;
		end
	})
end)

run(function()
    local fpsboost = {};
	local fpsboostTextures = {};
	local fpsboostnocharacter = {};
	local fpsboostnocamera = {};
	local fpsboostparticles = {};
	local fpsboostgraphics = {};
	local fpsboostshadows = {};
	local fpsboostoldgraphics;
	local fpsboostoldgraphics2;
	local fpsboostoldshaddows;
	local fpsboostnocache: vapeminimodule = {};
	local createfpsboostTab: () -> securetable = function()
		local cleaner: securetable = Performance.new(setmetatable({
			jobdelay = 5, 
		}, {
			__index = function(self: table, index: string)
				if index == 'maxamount' then 
					return (fpsboostnocache.Enabled and 0 or renderperformance.maxcacheable)
				end;
				if index == 'purge' then 
					return (fpsboostnocache.Enabled and true or renderperformance.purgeonthreshold)
				end;
				return rawget(self, index)
			end
		}));
		cleaner:setcleanermode(2);
		return cleaner
	end;
	local fpsdata = {
		oldtexures = createfpsboostTab(),
		oldcolors = createfpsboostTab(),
		cleanedinstances = createfpsboostTab(),
		cameraeffects = createfpsboostTab(),
		clearedeffects = {}
	};
	local boostfuncs = {
		Texture = function(texture: Texture)
			fpsdata.oldtexures[texture] = texture.Texture;
			texture.Texture = '';
			fpsboost.Connections[#fpsboost.Connections + 1] = texture:GetPropertyChangedSignal('Texture'):Connect(function()
				fpsdata.oldtexures[texture] = texture.Texture;
				texture.Texture = '';
			end)
		end,
		MeshPart = function(part: MeshPart)
			fpsdata.oldtexures[part] = part.TextureID;
			fpsdata.oldcolors[part] = part.Color;
			part.TextureID = '';
			part.Color = Color3.fromRGB(255, 255, 255);
			fpsboost.Connections[#fpsboost.Connections + 1] = part:GetPropertyChangedSignal('TextureID'):Connect(function()
				fpsdata.oldtexures[part] = part.TextureID;
				part.TextureID = '';
			end);
			fpsboost.Connections[#fpsboost.Connections + 1] = part:GetPropertyChangedSignal('Color'):Connect(function()
				fpsdata.oldcolors[part] = part.Color;
				part.Color = Color3.fromRGB(255, 255, 255);
			end);
		end,
		SpecialMesh = function(part: SpecialMesh)
			fpsdata.oldtexures[part] = part.TextureId;
			part.TextureId = '';
			fpsboost.Connections[#fpsboost.Connections + 1] = part:GetPropertyChangedSignal('TextureId'):Connect(function()
				fpsdata.oldtexures[part] = part.TextureId;
				part.TextureId = '';
			end);
		end,
		Part = function(part: Part?)
			fpsdata.oldtexures[part] = part.Material;
			part.Material = Enum.Material.SmoothPlastic;
			fpsdata.oldcolors[part] = part.Color;
			part.Color = Color3.fromRGB(255, 255, 255);
			fpsboost.Connections[#fpsboost.Connections + 1] = part:GetPropertyChangedSignal('Color'):Connect(function()
				fpsdata.oldcolors[part] = part.Color;
				part.Color = Color3.fromRGB(255, 255, 255);
			end);
			fpsboost.Connections[#fpsboost.Connections + 1] = part:GetPropertyChangedSignal('Material'):Connect(function()
				fpsdata.oldtexures[part] = part.Material;
				part.Material = Enum.Material.SmoothPlastic;
			end)
		end,
		CornerWedgePart = function(part: Part)
			fpsdata.oldtexures[part] = part.MaterialVariant;
			part.Material = Enum.Material.SmoothPlastic;
			fpsdata.oldcolors[part] = part.Color;
			part.Color = Color3.fromRGB(255, 255, 255);
			part.MaterialVariant = ''
			fpsboost.Connections[#fpsboost.Connections + 1] = part:GetPropertyChangedSignal('Color'):Connect(function()
				fpsdata.oldcolors[part] = part.Color;
				part.Color = Color3.fromRGB(255, 255, 255);
			end);
			fpsboost.Connections[#fpsboost.Connections + 1] = part:GetPropertyChangedSignal('Material'):Connect(function()
				part.Material = Enum.Material.SmoothPlastic;
			end);
			fpsboost.Connections[#fpsboost.Connections + 1] = part:GetPropertyChangedSignal('MaterialVariant'):Connect(function()
				fpsdata.oldtexures[part] = part.MaterialVariant;
				part.MaterialVariant = '';
			end)
		end,
		PostEffect = function(effect: PostEffect)
			if not effect.Enabled then 
				return 
			end;
			effect.Enabled = false;
			table.insert(fpsdata.cameraeffects, effect)
		end,
		Explosion = function(part: Explosion)
			part:Remove()
		end
	}
	local boostinstance = function(part: Instance)
		local character = fpsboostnocharacter.Enabled and getcharparent(part);
		local cameraobject = fpsboostnocamera.Enabled and part:IsDescendantOf(camera);
		if character or cameraobject then return end;
		for i,v in ({'ParticleEmitter', 'Trail', 'Smoke', 'Fire', 'Sparkles'}) do 
			if part.ClassName == v then 
				if not fpsboostparticles.Enabled then 
					return;
				end;
				table.insert(fpsdata.cleanedinstances, part);
				fpsdata.clearedeffects[part] = part.Parent;
				return part:Remove()
			end;
		end;
		if boostfuncs[part.ClassName] then 
			table.insert(fpsdata.cleanedinstances, part);
			pcall(boostfuncs[part.ClassName], part);
		end;
	end;
	local disableboost = function()
		for i,v in fpsboost.Connections do 
		   pcall(function() v:Disconnect() end);
		end;
		for i,v in fpsdata.oldtexures do 
			if i.ClassName == 'Texture' then 
				i.Texture = v;
			end;
			if i.ClassName == 'MeshPart' then 
				i.TextureID = v;
			end;
			if i.ClassName == 'SpecialMesh' then 
				i.TextureId = v;
			end;
			if i.ClassName == 'Part' then 
				i.Material = v;
			end;
			if i.ClassName == 'CornerWedgePart' then 
				i.MaterialVariant = v;
			end;
		end;
		for i,v in fpsdata.oldcolors do 
			pcall(function() i.Color = v end);
		end;
		for i,v in fpsdata.cameraeffects do 
			i.Enabled = true;
		end;
		for i,v in fpsdata.clearedeffects do 
			pcall(function() i.Parent = v end);
		end;
		for i,v in fpsdata do 
			if v.shutdown then 
				v:clear();
				continue
			end;
			table.clear(v);
		end;
	end;
	fpsboost = visual.Api.CreateOptionsButton({	
		Name = 'FPSBoost',
		HoverText = 'Gives you a huge/slight FPS advantage.',
		Function = function(calling: boolean)
			if calling then 
				for i,v in workspace:GetDescendants() do 
					boostinstance(v);
				end;
				table.insert(fpsboost.Connections, workspace.DescendantAdded:Connect(boostinstance));
				for i,v in next, getservice('MaterialService'):GetChildren() do
					fpsdata.clearedeffects[v] = v.Parent;
					v:Remove();
				end;
				fpsboostoldshaddows = lighting.GlobalShadows;
				if fpsboostoldshaddows then 
					lighting.GlobalShadows = not fpsboostshadows.Enabled;
				end;
				pcall(function()
					if fpsboostgraphics.Enabled then 
						fpsboostoldgraphics = settings().Rendering.QualityLevel;
						fpsboostoldgraphics2 = settings().Rendering.MeshPartDetailLevel;
						settings().Rendering.QualityLevel = 1;
						settings().Rendering.MeshPartDetailLevel = 1;
					end
				end);
			else
				if fpsboostoldshaddows ~= nil then 
					lighting.GlobalShadows = fpsboostoldshaddows;
				end;
				pcall(function()
					if fpsboostoldgraphics then
						settings().Rendering.QualityLevel = fpsboostoldgraphics;
					end;
					if fpsboostoldgraphics2.Enabled then 
						settings().Rendering.MeshPartDetailLevel = fpsboostoldgraphics2;
					end;
				end);
				pcall(disableboost)
			end
		end
	});
	fpsboostnocharacter = fpsboost.CreateToggle({
		Name = 'Ignore Characters',
		HoverText = 'Doesn\'t clean parts that are descendants of characters.',
		Function = function(calling)
			local boosted = table.clone(fpsdata.cleanedinstances);
			pcall(disableboost);
			for i,v in boosted do 
				boostinstance(v);
			end;
			table.clear(boosted);
		end
	});
	fpsboostnocamera = fpsboost.CreateToggle({
		Name = 'Ignore Camera',
		HoverText = 'Doesn\'t clean parts that are descendants of your camera.',
		Function = function(calling)
			local boosted = table.clone(fpsdata.cleanedinstances);
			pcall(disableboost);
			for i,v in boosted do 
				boostinstance(v);
			end;
			table.clear(boosted);
		end
	});
	fpsboostnocache = fpsboost.CreateToggle({
		Name = 'No Cache',
		HoverText = 'Disables game object caching\n(good for performance if the game had ALOT of objects)',
		Function = void
	});
	fpsboostparticles = fpsboost.CreateToggle({
		Name = 'Particles',
		HoverText = 'Removes particles.',
		Default = true,
		Function = function(calling)
			local boosted = table.clone(fpsdata.cleanedinstances);
			pcall(disableboost);
			for i,v in boosted do 
				boostinstance(v);
			end;
			table.clear(boosted);
		end
	});
	fpsboostshadows = fpsboost.CreateToggle({
		Name = 'Shadows',
		HoverText = 'Removes shadows',
		Default = true,
		Function = function(calling)
			if fpsboost.Enabled then 
				if calling and lighting.GlobalShadows then 
					lighting.GlobalShadows = false;
				else
					if fpsboostoldshaddows then 
						lighting.GlobalShadows = fpsboostoldshaddows;
					end;
				end
			end
		end
	});
	fpsboostgraphics = fpsboost.CreateToggle({
		Name = 'Graphics',
		HoverText = 'Sets your graphics level to the lowest.',
		Default = true,
		Function = void
	})
end)
run(function()
	local PlayerViewModel = {};
    local viewmodelMode = {};
	local viewmodel = Performance.new();
	reModel = function(entity)
		for i,v in entity.Character:GetChildren() do
			if v:IsA('BasePart') or v:IsA('Accessory') then
				pcall(function() v.Transparency = 1 end)
			end
		end
		local part = Instance.new("Part", entity.Character)
		part.CanCollide = false

		local mesh = Instance.new("SpecialMesh", part)
		mesh.MeshId = viewmodelMode.Value == 'Among Us' and 'http://www.roblox.com/asset/?id=6235963214' or 'http://www.roblox.com/asset/?id=13004256866'
		mesh.TextureId = viewmodelMode.Value == 'Among Us' and 'http://www.roblox.com/asset/?id=6235963270' or 'http://www.roblox.com/asset/?id=13004256905'
		mesh.Offset = viewmodelMode.Value == 'Rabbit' and Vector3.new(0,1.6,0) or Vector3.new(0,0.3,0)
		mesh.Scale = viewmodelMode.Value == 'Rabbit' and Vector3.new(10, 8, 10) or Vector3.new(0.11, 0.11, 0.11)

		local weld = Instance.new("Weld", part)
		weld.Part0 = part
		weld.Part1 = part.Parent.UpperTorso or part.Parent.Torso
		
		table.insert(viewmodel, task.spawn(function()
			viewmodel[entity.Name] = part
		end))
	end;
	removeModel = function(ent)
        viewmodel[ent.Name]:Remove()
        for i,v in ent.Character:GetChildren() do
            if v:IsA('BasePart') or v:IsA('Accessory') then
                pcall(function() 
                    if v ~= ent.Character.PrimaryPart then 
                        v.Transparency = 0 
                    end 
                end)
            end
        end
        viewmodel[ent.Name] = nil
		task.wait(1)
	end
	PlayerViewModel = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'PlayerViewModel',
		Function = function(call)
			if call then
				for i,v in players:GetPlayers() do
					table.insert(PlayerViewModel.Connections, v.CharacterAdded:Connect(function()
						pcall(function() removeModel(v) end)
						task.spawn(pcall, reModel, v)
					end))
				end
				table.insert(PlayerViewModel.Connections, players.PlayerAdded:Connect(function(v)
					table.insert(PlayerViewModel.Connections, v.CharacterAdded:Connect(function()
						task.spawn(pcall, removeModel, v)
						task.spawn(pcall, reModel, v)
					end))
				end))
				RunLoops:BindToHeartbeat('PlayerVM', function()
					for i,v in players:GetPlayers() do
						if isAlive(v) and not viewmodel[v.Name] then
                            if not PlayerViewModel.Enabled then break end
							task.spawn(pcall, reModel, v)
						end
					end
				end)
			else
                RunLoops:UnbindFromHeartbeat('PlayerVM')
                for i,v in players:GetPlayers() do
                    task.spawn(pcall, removeModel, v)
                end
			end
		end,
		HoverText = 'Turns you into a curtain model'
	})
    viewmodelMode = PlayerViewModel.CreateDropdown({
        Name = 'Model',
        List = {'Among Us', 'Rabbit'},
        Function = function()
			PlayerViewModel:retoggle()
        end,
        Default = 'Among Us'
    })
end);

run(function()
	local instaprompt: vapemodule = {};
	instaprompt = utility.Api.CreateOptionsButton({
		Name = 'InstantInteract',
		Function = function(call)
			if call then
				table.insert(instaprompt.Connections, getservice('ProximityPromptService').PromptButtonHoldBegan:Connect(fireproximityprompt))
			end;
		end
	})
end);

run(function()
	local kickgui: vapemodule = {};
	local kickscreenapi: kickscreenapi;
	kickgui = visual.Api.CreateOptionsButton({
		Name = 'Kickscreen',
		HoverText = 'Overwrites the roblox kick screen with a custom one.',
		Function = function(calling: boolean): ()
			if calling then 
				kickscreenapi = kickscreenapi or loadstring(RenderLibrary.http:getfile('libraries/kickscreen.lua'))();
				table.insert(kickgui.Connections, render.events.kicked.Event:Once(function(text: string, custom: string)
					kickscreenapi:activate(text, custom)
				end))
			end;
		end
	});
end);

run(function()
	local BubbleMods = {}
	local BubbleModsColorToggle = {}
	local BubbleModsTextSizeToggle = {}
	local BubbleModsTextColorToggle = {}
	local BubbleModsTextSize = {Value = 16}
	local BubbleModsTextColor = newcolor()
	local BubbleModsColor = newcolor()
	local chatbubbles = Performance.new();
	local function bubbleFunction(bubble)
		pcall(function() 
			local name = 'ChatBubbleFrame'
			if coregui:FindFirstChild('BubbleChat') then 
				name = 'Frame' 
			end
			if tostring(bubble) ~= name and tostring(bubble) ~= 'RoundedFrame' then 
				return 
			end
			if BubbleModsColorToggle.Enabled then 
				bubble.BackgroundColor3 = Color3.fromHSV(BubbleModsColor.Hue, BubbleModsColor.Sat, BubbleModsColor.Value)
				pcall(function() bubble.Parent.Caret.ImageColor3 = Color3.fromHSV(BubbleModsColor.Hue, BubbleModsColor.Sat, BubbleModsColor.Value) end)
				pcall(function() bubble.Parent.Carat.ImageColor3 = Color3.fromHSV(BubbleModsColor.Hue, BubbleModsColor.Sat, BubbleModsColor.Value) end)
			end
			if BubbleModsTextColorToggle.Enabled then 
				pcall(function() bubble.Text.TextColor3 = Color3.fromHSV(BubbleModsTextColor.Hue, BubbleModsTextColor.Sat, BubbleModsTextColor.Value) end)
				pcall(function() bubble.Contents.Ellipsis.TextColor3 = Color3.fromHSV(BubbleModsTextColor.Hue, BubbleModsTextColor.Sat, BubbleModsTextColor.Value) end)
			end
			if BubbleModsTextSizeToggle.Enabled then 
				pcall(function() bubble.Text.TextSize = BubbleModsTextSize.Value end)
				pcall(function() bubble.Contents.Ellipsis.TextSize = BubbleModsTextSize.Value end)
			end
			table.insert(chatbubbles, bubble)
		end)
	end
	BubbleMods = rendervape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'BubbleVisuals',
		HoverText = 'Mods the bubble chat experience.',
		Function = function(calling) 
			if calling then 
				local bubblechat = (coregui:FindFirstChild('ExperienceChat') and coregui.ExperienceChat.bubbleChat or coregui:FindFirstChild('BubbleChat') or Instance.new('ScreenGui'))
				for i,v in next, bubblechat:GetDescendants() do 
					bubbleFunction(v)
				end
				table.insert(BubbleMods.Connections, bubblechat.DescendantAdded:Connect(bubbleFunction))
			else 
				for i,v in next, chatbubbles do 
					pcall(function() v.Text.TextColor3 = Color3.fromRGB(57, 59, 61) end)
					pcall(function() v.Text.TextSize = 16 end)
					pcall(function() v.Parent.Carat.ImageColor3 = Color3.fromHSV(BubbleModsColor.Hue, BubbleModsColor.Sat, BubbleModsColor.Value) end)
				end
			end
		end
	})
	BubbleModsColorToggle = BubbleMods.CreateToggle({
		Name = 'Background Color',
		Function = function(calling)
			pcall(function() BubbleModsColor.Object.Visible = calling end)
		end
	})
	BubbleModsTextColorToggle = BubbleMods.CreateToggle({
		Name = 'Text Color',
		Function = function(calling)
			pcall(function() BubbleModsTextColor.Object.Visible = calling end)
		end
	})
	BubbleModsTextSizeToggle = BubbleMods.CreateToggle({
		Name = 'Text Size',
		Function = function(calling)
			pcall(function() BubbleModsTextSize.Object.Visible = calling end)
		end
	})
	BubbleModsColor = BubbleMods.CreateColorSlider({
		Name = 'Background Color',
		Function = function()
			if BubbleModsColorToggle.Enabled then 
				for i,v in next, chatbubbles do 
					pcall(function() 
						v.BackgroundColor3 = Color3.fromHSV(BubbleModsColor.Hue, BubbleModsColor.Sat, BubbleModsColor.Value) 
						pcall(function() v.Parent.Caret.ImageColor3 = Color3.fromHSV(BubbleModsColor.Hue, BubbleModsColor.Sat, BubbleModsColor.Value) end)
						pcall(function() v.Parent.Carat.ImageColor3 = Color3.fromHSV(BubbleModsColor.Hue, BubbleModsColor.Sat, BubbleModsColor.Value) end)
					end)
				end  
			end
		end
	})
	BubbleModsTextColor = BubbleMods.CreateColorSlider({
		Name = 'Text Color',
		Function = function()
			if BubbleModsTextColorToggle.Enabled then   
				for i,v in next, chatbubbles do 
					pcall(function() v.Text.TextColor3 = Color3.fromHSV(BubbleModsTextColor.Hue, BubbleModsTextColor.Sat, BubbleModsTextColor.Value) end)
					pcall(function() v.Contents.Ellipsis.TextColor3 =  Color3.fromHSV(BubbleModsTextColor.Hue, BubbleModsTextColor.Sat, BubbleModsTextColor.Value) end) 
				end 
			end
		end
	})
	BubbleModsTextSize = BubbleMods.CreateSlider({
		Name = 'Text Size',
		Min = 10,
		Max = 23,
		Function = function(size)
			if BubbleModsTextSizeToggle.Enabled then 
				for i,v in next, chatbubbles do 
					pcall(function() v.Text.TextSize = 16 end)
					pcall(function() v.Contents.Ellipsis.TextSize = BubbleModsTextSize.Value end)
				end 
			end
		end
	})
	BubbleModsColor.Object.Visible = false 
	BubbleModsTextColor.Object.Visible = false
	BubbleModsTextSize.Object.Visible = false
end);

--[[run(function()
	local discordselfbot: vapemodule = {}; --> project for later
	local websocketfunc: (table) -> table = ( WebSocket and WebSocket.Connect or Ws and Ws.Connect or ws and ws.Connect or WebSocket_connect);
	local gateway;
	local connectToGateway; connectToGateway = function(calling: boolean)
		if not discordselfbot.Enabled then 
			return 
		end;
		gateway = websocketfunc('wss://gateway.discord.gg/?v=9&encoding=json');
		gateway:Send(httpservice:JSONEncode({
			op = 2,
			d = {
				properties = {
					['$os'] = tostring(render.platform):lower():gsub('enum.platform.', ''):split(' ')[1] or tostring(render.platform):lower():gsub('enum.platform.', ''):split(' ')[0],
					['$browser'] = 'chrome',
					['$device'] = tostring(render.platform):lower():gsub('enum.platform.', ''):split(' ')[1] or tostring(render.platform):lower():gsub('enum.platform.', ''):split(' ')[0]
				},
				presence = {
					game = {
						name = 'Render Vape',
						details = 'Game: Bedwars',
						state = 'active',
						timestamps = {
							start = os.time()
						},
						assets = {
							large_image = 'render_flow',
							large_text = 'render'
						}
					},
					status = 'online',
					afk = false
				}
			}
		}));

		gateway.OnMessage:Once(connectToGateway);
		
		discordselfbot.Connections[#discordselfbot.Connections + 1] = gateway.OnMessage:Connect(function(data: string)
			local unpacked: boolean, packet: table | string = pcall(function()
				return httpservice:JSONDecode(data)
			end);
			if not unpacked then return end;
			if packet.op == 10 then 
				repeat 
					gateway:Send('{"op": 1, "d": null}')
					task.wait(packet.d.heartbeat_interval / 1000)
				until (not discordselfbot.Enabled)
			end;
			print(httpservice:JSONEncode(packet))
		end)
	end;
	discordselfbot = utility.Api.CreateOptionsButton({
		Name = 'DiscordSelfbot',
		HoverText = 'A selfbot powered by render for discord.\n(may cause unstability on shit executors)',
		Function = function(calling: boolean)
			if calling then
				local connected: boolean = pcall(connectToGateway);
				if not connected then 
					return errorNotification('DiscordSelfbot', 'Failed to connect to the discord websocket.')
				end;
			else
				pcall(function() gateway:Close() end);
				gateway = nil;
			end
		end
	})
end)]]

