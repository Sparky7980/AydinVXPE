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
   CustomModules/17750024818.lua.lua (autistic version of bedwars) - SystemXVoid/BlankedVoid and relevant            
   https://renderintents.lol                                                                                                                                                                                                                                                                     
]]

for i,v in render.utils do 
    getfenv()[i] = v; 
end;

type vapeobjectsapi = {
    Api: table
};

type vapelegitmoduleargs = {
	Name: string,
	Function: (boolean) -> ()
};

type vapegui = {
    ObjectsThatCanBeSaved: vapeobjectsapi
};

type vapemoduleargs = {
    Name: string,
    HoverText: string | nil,
    ExtraText: (() -> string) | nil,
    Function: (boolean) -> any
};

type vapedropdownargs = {
    Name: string,
    List: table,
    Function: (string) -> any
};
   
type vapeminimodule = {
	Enabled: boolean,
	Object: Instance,
	ToggleButton: (boolean | nil, boolean | nil) -> ()
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

type vapelegitmodule = {
	GetCustomChildren: Instance,
	Object: Instance
};

type vapemodule = {
    Connections: table,
    Enabled: boolean,
    Object: Instance,
    ToggleButton: (boolean | nil, boolean | nil) -> (),
	CreateTextList: (table) -> vapetextlist,
	CreateColorSlider: (table) -> vapeslider,
	CreateToggle: (table) -> vapeminimodule,
	CreateDropdown: (vapedropdownargs) -> vapedropdown,
	CreateSlider: (table) -> vapeslider,
	CreateTextBox: (table) -> vapetextbox,
	GetCustomChildren: (table) -> vapecustomwindow,
    CreateLegitModule: (vapelegitmoduleargs) -> vapelegitmodule
};

type vapewindowapi = {
	CreateOptionsButton: (vapemoduleargs) -> vapemodule,
	SetVisible: (boolean | nil) -> ()
};

type vapewindow = {
    Api: vapewindowapi
};

type inventoryobject = {
    name: string,
    tool: Tool | nil,
    amount: number,
    class: string,
    slotType: string,
    rawmeta: table
}; 

type rendertarget = {
    RootPart: BasePart | Part | nil,
    Player: Player | Model | nil,
    Humanoid: Humanoid | nil,
    Human: boolean | nil,
    Distance: number?
};

type rendertable = {
    utils: table
};

type rendertag = {
    text: string,
    hex: string
};

local vape: table = shared.rendervape;
local combat: table = vape.ObjectsThatCanBeSaved.CombatWindow;
local blatant: table = vape.ObjectsThatCanBeSaved.BlatantWindow;
local visual: table = vape.ObjectsThatCanBeSaved.RenderWindow;
local exploit: table = vape.ObjectsThatCanBeSaved.ExploitWindow;
local utility: table = vape.ObjectsThatCanBeSaved.UtilityWindow;
local world: table = vape.ObjectsThatCanBeSaved.WorldWindow;
local hudwindow: table = vape.ObjectsThatCanBeSaved.TargetHUDWindow;
local RenderLibrary: table = RenderLibrary;
local render: table = render;

local replicatedstorage: ReplicatedStorage = getservice('ReplicatedStorage');
local httpservice: HttpService = getservice('HttpService');
local teleport: TeleportService = getservice('TeleportService');
local players: Players = getservice('Players');
local startergui: StarterGear = getservice('StarterGui');
local inputservice: UserInputService = getservice('UserInputService');
local runservice: RunService = getservice('RunService');
local collection: CollectionService = getservice('CollectionService');
local tween: TweenService = getservice('TweenService');
local fakecam: Camera = Instance.new('Camera');
local camera: Camera = workspace.CurrentCamera;
local lplr: Player = players.LocalPlayer;
local vapetarget: table = shared.VapeTargetInfo;
local entityLibrary: table = shared.vapeentity;

local renderloaded: boolean = true;

local store; store = setmetatable({
    blocks = Performance.new(setmetatable({
        jobdelay = 3, 
    }, {
		__index = function(self: table, index: string)
			if index == 'maxamount' then 
				return renderperformance.maxcacheable
			end;
			if index == 'purge' then 
				return renderperformance.purgeonthreshold
			end;
			return rawget(self, index)
		end
	})),
    constants = setmetatable({}, {
        __index = function(self: table, index: string)
            local valdata: StringValue? = lplr:FindFirstChild(index);
            if valdata and valdata.ClassName:find('Value') then 
                return valdata.Value 
            end
        end
    }),
    beds = setmetatable({}, {
        __index = function(self: table, index: string)
            local success: boolean, beds: table? = pcall(function()
                return workspace.Map.Beds:GetChildren() 
            end);
            if success then 
                return beds 
            end;
            return {}
        end,
        __iter = function()
            local success: boolean, beds: table? = pcall(function()
                return workspace.Map.Beds:GetChildren() 
            end);
            if success then 
                return next, beds 
            end;
            return next, {}
        end,
        __len = function()
            local len: number = 0;
            for i,v in store.beds do 
                len += 1;
            end;
            return len
        end
    }),
    luckyblocks = setmetatable({}, {
        __index = function(self: table, index: string)
            local success: boolean, blocks: table? = pcall(function()
                return workspace.Map.BlocksContainer['Lucky Block']:GetChildren()
            end);
            if success then 
                return next, blocks 
            end;
            return {}
        end,
        __iter = function()
            local success: boolean, blocks: table? = pcall(function()
                return workspace.Map.BlocksContainer['Lucky Block']:GetChildren()
            end);
            if success then 
                return next, blocks 
            end;
            return {}
        end,
        __len = function()
            local len: number = 0;
            for i,v in store.luckyblocks do 
                len += 1;
            end;
            return len
        end
    }),
    npcs = setmetatable({}, {
        __index = function()
            local success: boolean, npcs: table? = pcall(function()
                return workspace.NpcsContainer:GetChildren()
            end);
            if success then 
                return npcs 
            end;
            return {}
        end,
        __iter = function()
            local success: boolean, npcs: table? = pcall(function()
                return workspace.NpcsContainer:GetChildren()
            end);
            if success then 
                return next, npcs 
            end;
            return {}
        end,
        __len = function()
            local len: number = 0;
            for i,v in store.npcs do 
                len += 1;
            end;
            return len
        end
    }),
    items = {}
}, {
    __index = function(self: table, index: string?)
        if index == 'raycast' then 
            if rawget(self, index) == nil then 
                rawset(self, 'raycast', RaycastParams.new()) 
            end;
            rawget(self, 'raycast').FilterDescendantsInstances = {self.blocks:getplainarray()};
        end;
        return rawget(self, index)
    end
});

getgenv().bedwarz = store;

pcall(function()
    store.items = require(replicatedstorage.Modules.ItemsData);
end);

function store:getinventory(plr: Player): inventoryobject
    local player = plr or lplr;
    local inv: inventoryobject = {items = {}, hand = {}, armor = {}};
    if player:FindFirstChild('ServerInventoryFolder') then
        for i: number, v: StringValue? in player.ServerInventoryFolder:GetChildren() do 
            if v.ClassName == 'NumberValue' then 
                local tooldata: table = setmetatable({
                    name = v.Name, 
                    tool = lplr.Character and lplr.Character:FindFirstChild(v.Name) or player.Backpack:FindFirstChild(v.Name),
                    amount = v.Value,
                    class = v:GetAttribute('Class'),
                    slotType = v:GetAttribute('SlotType'),
                    rawmeta = store.items[v.Name]
                }, {
                    __index = function(self: table, index: string)
                        if index == 'amount' then 
                            return v.Value or 0
                        end
                    end
                });
                table.insert(inv.items, tooldata)
            end
        end 
    end;
    for i: number, v: table in inv.items do
        if lplr.Character and v.tool and v.tool.Parent == lplr.Character then 
            inv.hand = {
                name = v.name, 
                tool = v.tool,
                viewmodel = camera:FindFirstChild(v.name),
                class = v.class,
                meta = v
            };
        end
    end;
    return inv
end;

function store:getitem(tool: string, custominv: table?): table | nil
    for i,v in (custominv or self:getinventory()).items do 
        if v.name == tool then 
            return v
        end
    end
end;

function store:getitemfromclass(class: string, custominv: table | nil): table | nil 
    for i,v in (custominv or self:getinventory().items) do 
        if v.class == class then 
            return v 
        end
    end
end;

function store:itemfromMatch(match: string, custominv: table | nil): table | nil
    for i,v in (custominv or self:getinventory().items) do
        if v.name:find(match) then 
            return v 
        end
    end
end;

function store:getTeamFromColor(color: BrickColor): Team | nil
    for i: number, v: Team in getservice('Teams'):GetChildren() do 
        if v.TeamColor == color then 
            return v 
        end;
    end
end;

function store:getTeamates(team: Team | nil): table 
    local teamates: table = {};
    local team: Team = typeof(team) == 'Instance' and team.ClassName == 'Team' and team or lplr.Team;
    for i,v in players:GetPlayers() do 
        if v.Team == team then 
            table.insert(teamates, v)
        end
    end;
    return teamates
end;

function store:getnearestbed(range: number?, ignoreEmpty: boolean | nil): Model | nil
    if not isAlive(lplr, true) then 
        return nil
    end;
    local best: number, bed: Model? = range or math.huge, nil;
    for i,v in self.beds do 
        if v.PrimaryPart == nil then 
            continue 
        end;
        if v:GetAttribute('TeamName') == tostring(lplr.Team) or not v:GetAttribute('CanMine') then 
            continue
        end;
        local distance: number = ((render.clone.old or lplr.Character.PrimaryPart).Position - v.PrimaryPart.Position).Magnitude;
        if distance < best then 
            best = distance;
            bed = v;
        end;
    end;
    for i,v in (ignoreEmpty and self.beds or {}) do 
        if v.PrimaryPart == nil or bed == nil then 
            continue 
        end;
        if v:GetAttribute('TeamName') == tostring(lplr.Team) or not v:GetAttribute('CanMine') then 
            continue
        end;
        local oldteam: Team? = store:getTeamFromColor(bed.Mattress.BrickColor);
        local team: Team? = store:getTeamFromColor(v.Mattress.BrickColor);
        if oldteam and team and #store:getTeamates(oldteam) < 1 and #store:getTeamates(team) > 0 then 
            bed = v;
            break
        end;
    end;
    return bed
end;

function store:getluckyblock(range: number?): Model | nil 
    if not isAlive(lplr, true) then 
        return nil
    end;
    local best: number, block: Model? = range or math.huge, nil;
    pcall(function()
        for i,v in workspace.Map.BlocksContainer['Lucky Block']:GetChildren() do 
            local distance: number = ((render.clone.old or lplr.Character.PrimaryPart).Position - v.PrimaryPart.Position).Magnitude;
            if distance < best then 
                best = distance;
                block = v;
            end;
        end;
    end);
    return block
end;

function store:getplayerbed(player: Player)
    local player: Player = typeof(player) == 'Player' or player or lplr;
    for i,v in self.beds do 
        if v:FindFirstChild('Mattress') and v.Mattress.BrickColor == player.TeamColor then 
            return v 
        end
    end
end;

function store:shootprojectile(...): boolean
    local bow: inventoryobject? = self:getitemfromclass('Projectiles');
    local args: table = {...};
    local successful = pcall(function()
        bow.tool.ClientHandler.ShootArrow:FireServer(unpack(args))
    end);    
    return successful
end;

function store:switchitem(item: string): number
    local inv: table = store:getinventory();
    local switchrequest: number = tick();

    if inv.hand.name == item then 
        return 0 
    end;

    replicatedstorage.Remotes.EquipItem:FireServer(item);

    for i: number, v: table in inv.items do 
        if v.name == item and v.tool and lplr.Character:FindFirstChild(item) == nil then 
            if isAlive(lplr, true) then
                lplr.Character.Humanoid:EquipTool(v.tool);
            end;
        end
    end;

    return (tick() - switchrequest)
end;

function store:bindevent(remote: string, func: () -> any): RBXScriptConnection | nil
    local remote: RemoteEvent? = replicatedstorage.Remotes:FindFirstChild(remote);
    if remote and remote.ClassName == 'RemoteEvent' then 
        return remote.OnClientEvent:Connect(func)
    end;
end;

local refreshblockcache = function()
    store.blocks:clear();
    for i,v in workspace.Map.BlocksContainer:GetChildren() do 
        for i2, v2 in v:GetChildren() do 
            table.insert(store.blocks, v2)
        end
    end;
    table.insert(render.utils.renderconnections, workspace.Map.BlocksContainer.DescendantAdded:Connect(function(block: Part?)
        if block.ClassName:lower():find('part') then 
            table.insert(store.blocks, block)
        end
    end));
end;

render.utils.SetTargetValidation(function(plr: Player)
    return (isAlive(plr) and tostring(plr.Team) ~= 'Spectator')
end);

task.spawn(function()
	repeat 
		camera = workspace.CurrentCamera or fakecam;
		task.wait()
	until (not renderloaded)
end);

table.insert(renderconnections, task.spawn(function()
    repeat
        if isEnabled('Autowin') and not isAlive() then 
            camera.CameraSubject = nil;
        end;
        task.wait();
    until false;
end));  

task.spawn(function()
    repeat task.wait() until workspace:FindFirstChild('Map') and workspace.Map:FindFirstChild('BlocksContainer');
    refreshblockcache();
    table.insert(render.utils.renderconnections, workspace.DescendantAdded:Connect(function(instance: Folder?)
        if instance.Name == 'BlocksContainer' then 
            refreshblockcache()
        end
    end));
    table.insert(render.utils.renderconnections, workspace.DescendantRemoving:Connect(function(instance: Folder?)
        if instance.Name == 'BlocksContainer' then 
            store.blocks:clear();
        end
    end))
end);

store.raycast.FilterType = Enum.RaycastFilterType.Include;
store.raycast.FilterDescendantsInstances = {store.blocks:getplainarray()};

run(function()
	local playerThreads: securetable = Performance.new({jobdelay = 0.05});
	render.utils.renderconnections[#render.utils.renderconnections + 1] = RenderLibrary.runtime.events.PlayerTagCreated:Connect(function(player: Player, text: string, hex: string)
		pcall(task.cancel, playerThreads[player]);
		playerThreads[player] = task.spawn(function()
			repeat 
				pcall(function()
                    player.Character.NameDisplayGui.NameLabel.RichText = true;
					player.Character.NameDisplayGui.NameLabel.Text = "<font color='#"..hex.."'>["..text.."] </font> " ..player.DisplayName;
				end)
				task.wait()
			until (not getgenv().render)
		end);
	end);

	render.utils.renderconnections[#render.utils.renderconnections + 1] = RenderLibrary.runtime.events.PlayerTagRemoved:Connect(function(player: Player, text: string, hex: string)
		pcall(function()
            player.Character.NameDisplayGui.NameLabel.RichText = true;
			player.Character.NameDisplayGui.NameLabel.Text = player.DisplayName;
		end);
		pcall(task.cancel, playerThreads[player]);
	end);

	playerThreads.oncleanevent:Connect(task.cancel)
end);

local oldswordC0;
run(function() --> code sucks because had to remove GetAllTarget implementation from this.
    local killaura: vapemodule = {};
    local killauraboxes : table = Performance.new();
    local killaurahighlight: vapemodule = {};
    local killaurahighlightcolor: table = newcolor();
    local killaurarange: table = {Value = 30};
    local killauraAnimation: table = {Value = 'Charge'};
    local killaurasortmethod: table = {Value = 'Distance'};
    local killaurafacetarget: vapeminimodule = {};
    local killaurabanplayer: vapeminimodule = {};
    local killaurahandcheck: vapeminimodule = {};
    local bantargets = {};
    local killaurabox;
    local animtween;
    local killauraAnimationThread;
    local killauraplayinganim;
    local oldtarget;
    local getfriends = function(player: Player) 
        local friends = {};
        local success, page = pcall(players.GetFriendsAsync, players, player.UserId);
        if success then
            repeat
                for i,v in page:GetCurrentPage() do
                    table.insert(friends, v.UserId);
                end
                if not page.IsFinished then 
                    page:AdvanceToNextPageAsync();
                end
            until page.IsFinished
        end
        return friends;
    end;
    local killauraAnimations = {
        Charge = {
            {
                angles = (CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-50), math.rad(0), math.rad(0))),
                duration = 0.1,
            },
            {
                angles = (CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-58), math.rad(0), math.rad(0))),
                duration = 0.1,
            },
        },
        Render = {
            {
                angles = CFrame.new(0.2, 0, -1.3) * CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0)),
                duration = 0.16,
            },
            {
                angles = CFrame.new(0, -3, 1) * CFrame.Angles(math.rad(0), math.rad(-100), math.rad(0)),
                duration = 0.16,
            },
        }
    };
    local killaurasort: table = {
		Distance = function(a, b)
			local newmag = (a.RootPart.Position - lplr.Character.PrimaryPart.Position).Magnitude
			local oldmag = (a.RootPart.Position - b.RootPart.Position).Magnitude
			return (newmag < oldmag)
		end,
		Health = function(a, b)
			return (b.Humanoid.Health > a.Humanoid.Health)
		end,
		Switch = false
	};
    killaura = blatant.Api.CreateOptionsButton({
        Name = 'Killaura',
        HoverText = 'Automatically attacks players.',
        Function = function(calling: boolean)
            if calling then 
                killauraAnimationThread = task.spawn(function()
                    repeat 
                        pcall(function()
                            for i,v in (killauraAnimations[killauraAnimation.Value] or {}) do 
                                local inv = store:getinventory();
                                local suc: boolean, viewmodelhandle: Motor6D? = pcall(function()
                                    return camera:FindFirstChildOfClass('Model').PrimaryPart:FindFirstChildOfClass('Motor6D')
                                end);
                                if suc == false or viewmodelhandle == nil then 
                                    continue
                                end;
                                if viewmodelhandle and oldswordC0 == nil then 
                                    oldswordC0 = viewmodelhandle.C0;
                                end;
                                if vapetarget.Targets.Killaura == nil then 
                                    if killauraplayinganim then 
                                        animtween:Cancel();
                                        tween:Create(viewmodelhandle, TweenInfo.new(0.4), {C0 = oldswordC0}):Play()
                                        killauraplayinganim = false;
                                    end;
                                    continue
                                end;
                                local playedAt = tick();
                                animtween = tween:Create(viewmodelhandle, TweenInfo.new(v.duration), {C0 = oldswordC0 * v.angles});
                                animtween:Play();
                                killauraplayinganim = true;
                                repeat task.wait() until ((tick() - playedAt) >= v.duration or vapetarget.Targets.Killaura == nil or viewmodelhandle.Parent == nil);
                            end;
                        end)
                        task.wait()
                    until (not killaura.Enabled)
                end);
                table.insert(killaura.Connections, runservice.Heartbeat:Connect(function()
                    local target = isAlive(lplr, true) and tostring(lplr.Team) ~= 'Spectator' and GetTarget({
                        radius = killaurarange.Value,
                        pos = render.clone.old and render.clone.old.Position or lplr.Character.PrimaryPart.Position
                    });
                    if typeof(target) ~= 'table' or target.RootPart == nil then 
                        vapetarget.Targets.Killaura = nil;
                        render.targets:updatehuds();
                        for i: number, v: BoxHandleAdornment? in killauraboxes do 
                           pcall(function() v:Destroy() end);
                        end;
                        table.clear(killauraboxes);
                        return;
                    end;
                    for i: number, v: rendertarget in {target} do 
                        if oldtarget ~= v.Player.Character then 
                            for i: number, v: BoxHandleAdornment? in killauraboxes do 
                                pcall(function() v:Destroy() end);
                             end;
                             table.clear(killauraboxes);
                        end;
                        local sword: table = store:itemfromMatch('Hammer') or store:getitemfromclass('Swords');
                        if sword and tostring(lplr.Team) ~= 'Spectators' then
                            if killaurahandcheck.Enabled and store.hand.name ~= sword.name then 
                               return
                            end;
                            oldtarget = v.Player.Character; 
                            vapetarget.Targets.Killaura = v;
                            if killaurahighlight.Enabled and v.Player.Character and v.Player.Character:FindFirstChildOfClass('BoxHandleAdornment') == nil then 
                                local box: BoxHandleAdornment = killaurabox:Clone();
								box.Parent = v.Player.Character;
								box.Adornee = v.Player.Character;
								box.Color3 = Color3.fromHSV(killaurahighlightcolor.Hue, killaurahighlightcolor.Sat, killaurahighlightcolor.Value)
								table.insert(killauraboxes, box);
                            end;
                            local predictionvec: Vector3 = ({pcall(function() return Ray.new(camera.CFrame.Position, v.RootPart.Position).Unit.Direction end)})[2];
                            task.spawn(function()
                                store:switchitem(sword.name)
                            end);
                            task.spawn(pcall, function() replicatedstorage.Remotes.ItemRemotes.SwordAttack:FireServer(predictionvec, sword.name) end);
                            render.targets:updatehuds(v);
                            if killaurabanplayer.Enabled then 
                              --  banplayer(v.Player)
                            end;
                        end;
                    end
                end))
            else
                vapetarget.Targets.Killaura = nil;
                render.targets:updatehuds();
                for i: number, v: BoxHandleAdornment? in killauraboxes do
                    pcall(function() v:Destroy() end)
                end;
                table.clear(killauraboxes);
                pcall(task.cancel, killauraAnimationThread);
                pcall(function()
                    tween:Create(camera:FindFirstChildOfClass('Model').PrimaryPart:FindFirstChildOfClass('Motor6D'), TweenInfo.new(0.4), {C0 = oldswordC0}):Play()
                end)
            end 
        end
    });
    killaurarange = killaura.CreateSlider({
        Name = 'Range',
        Min = 1,
        Max = 22,
        Default = 22,
        Function = void
    });
    killaurahighlight = killaura.CreateToggle({
        Name = 'Target Box',
        HoverText = 'Adds a bounding box to the target.',
        Function = function(calling: boolean)
            if calling then 
				pcall(function() killaurahighlightcolor.Object.Visible = calling end);
				killaurabox = Instance.new('BoxHandleAdornment', vape.MainGui);
				killaurabox.Transparency = 0.85;
				killaurabox.Color3 = Color3.fromHSV(killaurahighlightcolor.Hue, killaurahighlightcolor.Sat, killaurahighlightcolor.Value);
				killaurabox.Size = Vector3.new(4.5, 6, 4.5);
				killaurabox.AlwaysOnTop = true;
				killaurabox.ZIndex = 9e9;
			else 
				pcall(function() killaurabox:Destroy() end);
				killaurabox = nil;
                for i: number, v: BoxHandleAdornment? in killauraboxes do  
                    pcall(function() v:Destroy() end)
                end;
                table.clear(killauraboxes)
			end
        end
    });
    killaurahighlightcolor = killaura.CreateColorSlider({
        Name = 'Box Color',
        Function = void
    });
    killaurafacetarget = killaura.CreateToggle({
        Name = 'Face Target',
        HoverText = 'looks at your opp.',
        Function = void
    });
    killaurahighlightcolor.Object.Visible = false;
end);

run(function()
    local staffdetector: table = {};
    local staffdetectoraction: table = {Value = 'ServerHop'};
    local staffdetected;
    local staffaltTable: table = {};
    local stafftable: table = httpservice:JSONDecode('["GameMaster4268","BedwarzAcMod","ohhiimnoobinarsenal2","llIIIlllllIIIIllII","doggy2918","Romansalt50","bubman920","minitoonfreind","Alexklysz2015","TanqrCletus","parham2020p","bedwarzontop1","BedwarzBlankMod","HamdanYTTVV","Tanpr_dom67","UseAsuraV4","GrumpyGravySeerp","Lordheaven_prime"]');
    local staffactions: table = {
        Uninject = function(plr: Player)
            startergui:SetCore('SendNotification', {
                Title = 'StaffDetector',
                Text = `{plr.DisplayName} (@{plr.Name}) is an active staff for Bedwarz.`,
                Duration = 60
            });
            return vape.SelfDestruct()
        end,
        ServerHop = function()
            vape.SaveSettings = void; 
            for i,v in vape.ObjectsThatCanBeSaved do 
                if v.Type == 'OptionsButton' and v.Api.Enabled then 
                    v.Api.ToggleButton()
                end
            end;
            getnewserver({sort = 'Players', place = game.PlaceId == 18836990947 and '17750024818'}):andThen(function(server: string)
                teleport:TeleportToPlaceInstance(game.PlaceId == 18836990947 and '17750024818' or game.PlaceId, server, lplr)
            end)         
        end,
        Notify = void
    };
    local staffdetection: () -> () = function(player: Player)
        if table.find(stafftable, player.Name) or table.find(staffaltTable, player.Name) then 
           errorNotification('StaffDetector', `{player.DisplayName} (@{player.Name}) is an active staff for Bedwarz.`, 60);
           if staffdetected then return end;
           staffdetected = true;
           return staffactions[staffdetectoraction.Value](player) 
        end
    end;
    staffdetector = utility.Api.CreateOptionsButton({
        Name = 'StaffDetector',
        HoverText = 'Alerts you when a staff is present.',
        Function = function(calling: boolean)
            if calling then 
                if replicatedstorage:FindFirstChild('Admins') then 
                    for i: number, v: StringValue in replicatedstorage.Admins:GetChildren() do 
                        if table.find(stafftable, v.Name) == nil then 
                            table.insert(stafftable, v.Name);
                        end;
                    end;
                end;
                for i: number, v: Player in players:GetPlayers() do 
                    task.spawn(staffdetection, v)
                end;
                table.insert(staffdetector.Connections, players.PlayerAdded:Connect(staffdetection))
            end
        end
    })
    staffdetectoraction = staffdetector.CreateDropdown({
        Name = 'Action',
        List = dumplist(staffactions, nil, function(a: string, b: string) return a == 'Uninject' end),
        Function = void
    })
end);

run(function()
    local bedesp: table = {};
    local bedesphighlights: securetable = Performance.new();
    bedesp = visual.Api.CreateOptionsButton({
        Name = 'BedESP',
        HoverText = 'Allows you to see beds through blocks.',
        Function = function(calling: boolean)
            if calling then 
                repeat 
                    for i: number, v: Model in store.beds do 
                        pcall(function()
                            if v:FindFirstChildOfClass('Highlight') == nil then 
                                local highlight: Highlight = Instance.new('Highlight');
                                highlight.FillColor = v.Mattress.Color;
                                highlight.OutlineTransparency = 1;
                                highlight.FillTransparency = 0;
                                highlight.Parent = v;
                                highlight.Adornee = v;
                                table.insert(bedesphighlights, highlight)
                            end
                        end)
                    end
                    task.wait(0.1)
                until (not bedesp.Enabled)
            else 
                bedesphighlights:clear(game.Destroy)
            end
        end
    })
end);

run(function()
    local bedfucker: table = {};
    local bedfuckerbox: table = {};
    local bedfuckercolormain: table = newcolor();
    local bedfuckercolorbreak: table = newcolor();
    local bedfuckerthread;
    local lasthighlight;
    local bedhighlight;
    local highlights = Performance.new();
    local lastblock;
    local lastnukerswitch: number = tick();
    local damageblock = function(bed: Model)
        if highlights[bed] and lastblock ~= bed then 
            pcall(function() highlights[bed]:Destroy() end);
        end;
        local box: BoxHandleAdornment = bed:FindFirstChildOfClass('BoxHandleAdornment') or Instance.new('BoxHandleAdornment');
        box.Transparency = box.Parent and box.Transparency or 1;
        box.Color3 = Color3.fromHSV(bedfuckercolormain.Hue, bedfuckercolormain.Sat, bedfuckercolormain.Value);
        box.Size = bed.PrimaryPart.Size + Vector3.new(2, 2, 2);
        box.AlwaysOnTop = true;
        box.ZIndex = 9e9;
        box.Adornee = bed;
        highlights[bed] = box;
        if box.Parent == nil then
            box.Parent = bedfuckerbox.Enabled and bed or nil;
            tween:Create(box, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Transparency = 0.55}):Play(); 
        end;
        lastblock = bed;
        local tool: table? = store:getitemfromclass('Axes') or store:getitemfromclass('Pickaxes');
        if tool and ((tick() - lastnukerswitch) > 0.25 or not render.targets.currentTarget) then 
            lastnukerswitch = tick();
            store:switchitem(tool.name);
        end;
        local s, successful: boolean? = pcall(function()
            return replicatedstorage.Remotes.DamageBlock:InvokeServer(bed, tool and tool.name)
        end);
        if s and successful then 
            local colortween: Tween = tween:Create(box, TweenInfo.new(0.25), {Color3 = Color3.fromHSV(bedfuckercolorbreak.Hue, bedfuckercolorbreak.Sat, bedfuckercolorbreak.Value)});
            colortween:Play();
            --colortween.Completed:Wait();
            task.delay(0.3, function()
                tween:Create(box, TweenInfo.new(0.3), {Color3 = Color3.fromHSV(bedfuckercolormain.Hue, bedfuckercolormain.Sat, bedfuckercolormain.Value)}):Play();
            end);
        end;
    end;
    bedfucker = world.Api.CreateOptionsButton({
        Name = 'Nuker',
        HoverText = 'Automatically breaks block(s) in a certain range.',
        Function = function(calling: boolean)
            if calling then 
                table.insert(bedfucker.Connections, runservice.Heartbeat:Connect(function()
                    local block: Model? = store:getnearestbed(25) or store:getluckyblock(25);
                    if block and tostring(lplr.Team) ~= 'Spectator' then 
                        damageblock(block);
                        return
                    else 
                        lastblock = nil;
                        highlights:clear(game.Destroy);
                    end; 
                end))
            else
                highlights:clear(game.Destroy);
            end
        end
    });
    bedfuckerbox = bedfucker.CreateToggle({
        Name = 'Box',
        HoverText = 'Highlights the target bed.',
        Default = true,
        Function = function(calling: boolean)
            pcall(function()    
                bedfuckercolormain.Object.Visible = calling;
                bedfuckercolorbreak.Object.Visible = calling;
            end)
        end
    });
    bedfuckercolormain = bedfucker.CreateColorSlider({
        Name = 'Main Color',
        Function = void
    });
    bedfuckercolorbreak = bedfucker.CreateColorSlider({
        Name = 'Break Color',
        Function = void
    });
    bedfuckercolormain.Object.Visible = false;
    bedfuckercolorbreak.Object.Visible = false;
end);

run(function()
    local detectiondisabler: table = {};
    local disablerhook: (...any) -> any;
    detectiondisabler = utility.Api.CreateOptionsButton({
        Name = 'AntiFlag',
        HoverText = 'Disables client side checks (95% percent of the checks)',
        Function = function(calling: boolean)
            if calling then 
                if not disablerhook then 
                    disablerhook = hookmetamethod(replicatedstorage, '__namecall', function(self: Instance, ...)
                        if detectiondisabler.Enabled and getnamecallmethod():find('Server') and (self == ({pcall(function() return replicatedstorage.Remotes.CheckAnticheat end)})[2] or tostring(self) == 'Suffocate') then
                            return ({Respond = void})
                        end;
                        return disablerhook(self, ...)
                    end);
                end;
            end
        end
    })
end);


run(function()
    local fastdrop: table = {};
    fastdrop = utility.Api.CreateOptionsButton({
        Name = 'FastDrop',
        HoverText = 'Drop items without delay when holding Q.',
        Function = function(calling: boolean)
            if calling then 
                repeat
                    task.spawn(function()
                        for i,v in store:getinventory().items do 
                            v = v.meta or v;
                            if v.rawmeta and not v.rawmeta.Droppable then 
                                continue 
                            end;
                            if v.tool == nil or v.tool.Parent ~= lplr.Character then 
                                continue 
                            end;
                            if inputservice:IsKeyDown(Enum.KeyCode.Q) then 
                                replicatedstorage.Remotes.DropItem:FireServer(v.name, 'One')
                            end;
                        end;
                    end);
                    task.wait()
                until (not fastdrop.Enabled) 
            end
        end
    })
end);

run(function()
    local autotoxic: vapemodule = {};
    local autotoxickill: vapeminimodule = {};
    local autotoxicwin: vapeminimodule = {};
    local autotoxiclose: vapeminimodule = {};
    local autotoxicyap: vapeminimodule = {};
    local autotoxickillmessages: vapetextlist = {ObjectList = {}};
    local autotoxicwinmessages: vapetextlist = {ObjectList = {}};
    local autotoxiclosemessages: vapetextlist = {ObjectList = {}};
    local autotoxicyapmessages: vapetextlist = {ObjectList = {}};
    local autotoxicyappers: table = {};
    local renderdomains: table = {
        'renderintents.xyz',
        'renderintents.lol'
    };
    local autotoxicdefault: table = {
        kill = {
            '<name> ΎØЏ\'ŘΕ ΒΑĐ, ЈЏŠΤ ЏŠΕ ŘΕΝĐΕŘ. | ŘΕΝĐΕŘİΝΤΕΝΤŠ.ΧΎΖ',
            'ΤΉİŠ ĜΑΜΕ ŠΤİĹĹ ΉΑŠΝ\'Τ ƑİΧΕĐ ΤΉΕİŘ ΑΝΤİСΉΕΑΤ :ŠØΒ: | ŘΕΝĐΕŘİΝΤΕΝΤŠ.ΧΎΖ',
            'ŘΕΝĐΕŘ İŠ ЏΝĐΕΤΕСΤΑΒĹΕ, ЏΝΤØЏСΉΑΒĹΕ ΑΝĐ ЏΝΡΑΤСΉΑΒĹΕ <name> ĹØĹ | ŘΕΝĐΕŘİΝΤΕΝΤŠ.ΧΎΖ'
        },
        win = {
            'ΤΉİŠ ĜΑΜΕ ШΑŠ ΕΑŠİĹΎ СŘЏΜΒĹΕĐ ΒΎ ŘΕΝĐΕŘ. | ŘΕΝĐΕŘİΝΤΕΝΤŠ.ΧΎΖ',
            'ΎØЏ ĜЏΎŠ ŠΉØЏĹĐ ØƑ ЏŠΕĐ ŘΕΝĐΕŘ. | ŘΕΝĐΕŘİΝΤΕΝΤŠ.ΧΎΖ',
        },
        lose = {
            'ΜΎ ŘΕΝĐΕŘΕŘ ШΑŠΝ\'Τ ŘΕΝĐΕŘİΝĜ, ΤΉΕŘΕƑØŘΕ İ ĹØŠΤ <name>.'
        },
        yap = {
            'ΎΑΡ ΑШΑΎ ƑØŘ ΜΕ <name> | ŘΕΝĐΕŘİΝΤΕΝΤŠ.ΧΎΖ',
            'СŘΎ ΜΕ Α ŘİṾΕŘ <name> | ŘΕΝĐΕŘİΝΤΕΝΤŠ.ΧΎΖ',
            'ØΜĜ ĜЏΎŠ ΉΑΚΕŘ!1!!1 | ŘΕΝĐΕŘİΝΤΕΝΤŠ.ΧΎΖ'
        }
    };
    local autotoxicphrases: table = {
        'hack',
        'L ',
        ' L',
        'skid',
        'cheater',
        'scripter',
        'script'
    };
    
    local sendtoxicmessage = function(type: string, messagetab: table, name: string)
        local message: string = getrandomvalue(messagetab.ObjectList) ~= '' and `{getrandomvalue(messagetab.ObjectList)} | ŘΕΝĐΕŘİΝΤΕΝΤŠ.ΧΎΖ` or getrandomvalue(autotoxicdefault[type]);
        return sendmessage(message:gsub('<name>', name))
    end;
    autotoxic = utility.Api.CreateOptionsButton({
        Name = 'AutoToxic',
        HoverText = 'Automatically acts toxic to enemies.',
        Function = function(calling: boolean)
            if calling then 
                table.insert(autotoxic.Connections, store:bindevent('KillFeed', function(killer: Player, victim: Player)
                    if killer == lplr and victim and victim ~= lplr and store:getplayerbed(victim) == nil and autotoxickill.Enabled then 
                        return sendtoxicmessage('kill', autotoxickillmessages, victim.DisplayName)
                    end;
                    if killer and killer ~= lplr and victim == lplr and store:getplayerbed() == nil and autotoxiclose.Enabled then 
                        return sendtoxicmessage('lose', autotoxiclosemessages, killer.DisplayName)
                    end;
                end));
                table.insert(autotoxic.Connections, store:bindevent('DisplayWinner', function(team: Team)
                    if team == tostring(lplr.Team) and autotoxicwin.Enabled then 
                        return sendtoxicmessage('win', autotoxicwinmessages, '')
                    end
                end));
                table.insert(autotoxic.Connections, render.events.message.Event:Connect(function(player: Player, message: string)
                    if autotoxicyap.Enabled and player ~= lplr and table.find(autotoxicyappers, player.UserId) == nil then 
                        for _: number, v: string in autotoxicphrases do 
                            if message:lower():find(v:lower()) then 
                                table.insert(autotoxicyappers, player.UserId);
                                return sendtoxicmessage('yap', autotoxicyapmessages, player.DisplayName)
                            end
                        end
                    end;
                end))
            end
        end
    });
    autotoxickill = autotoxic.CreateToggle({
        Name = 'Final Kill',
        Default = true,
        Function = void
    });
    autotoxicwinmessages = autotoxic.CreateToggle({
        Name = 'Win',
        Default = true,
        Function = void
    });
    autotoxiclose = autotoxic.CreateToggle({
        Name = 'Lose',
        Function = void
    });
    autotoxicyap = autotoxic.CreateToggle({
        Name = 'Complain',
        Default = true,
        Function = void
    });
    autotoxickillmessages = autotoxic.CreateTextList({
        Name = 'Kill Messages',
        TempText = 'kill messages',
        AddFunction = void
    });
    autotoxicwin = autotoxic.CreateTextList({
        Name = 'Kill Messages',
        TempText = 'win messages',
        AddFunction = void
    });
    autotoxiclose = autotoxic.CreateTextList({
        Name = 'Lose Messages',
        TempText = 'lose messages',
        AddFunction = void
    });
    autotoxicyapmessages = autotoxic.CreateTextList({
        Name = 'Yap Messages',
        TempText = 'complain messages',
        Function = void
    });
end);

run(function() --> works
	local projectileaura: vapemodule = {};
    local projectileauraswitch: vapeminimodule = {};
	projectileaura = blatant.Api.CreateOptionsButton({
		Name = 'ProjectileAura',
		HoverText = 'Automatically shoots projectile ammo.',
		Function = function(calling: boolean)
			if calling then 
				repeat
					local target: rendertarget = GetTarget();
                    local tool: table = store:getitemfromclass('Projectiles');
                    if target.RootPart and isAlive(lplr, true) and tool and not render.targets.currentTarget then 
                        if projectileauraswitch.Enabled then
                            store:switchitem(tool.name);
                        end;
                        store:shootprojectile(target.RootPart.Position, lplr.Character.PrimaryPart.Position, getrandomvalue({100, 200}))
                    end;
					task.wait()
				until (not projectileaura.Enabled)
			end
		end
	});
    projectileauraswitch = projectileaura.CreateToggle({
        Name = 'Switch',
        HoverText = 'Automatically switches to bow.',
        Function = void
    })
end);

run(function()
    local schematica: vapemodule = {};
    local schematicafile: vapetextbox = {Value = 'penis'};
    local schematicabuildtime: vapeslider = {Value = 0};
    local schematicathread;
    schematica = world.Api.CreateOptionsButton({
        Name = 'Schematica',
        HoverText = 'Automatically builds structure with blocks.',
        Function = function(calling: boolean)
            if calling then 
                schematicathread = task.spawn(function()
                    local tab: table? = ({pcall(function()
                        return httpservice:JSONDecode(readfile(`rendervape/configuration/schematica/{schematicafile.Value:gsub('.json', '')}.json`));
                    end)})[2];
                    
                    if typeof(tab) ~= 'table' then 
                        errorNotification('Schematica', `/configuration/schematica/{schematicafile.Value:gsub('.json', '')}.json is missing.`)
                        return schematica.ToggleButton()
                    end;
                    local block: table? = isAlive(lplr, true) and store:getitemfromclass('Blocks') or nil;
                    if block == nil then 
                        errorNotification('Schematica', `Block(s) missing/not supported.`)
                        return schematica.ToggleButton()
                    end;
                    local placepos = ((lplr.Character.HumanoidRootPart.CFrame + (lplr.Character.HumanoidRootPart.CFrame.LookVector * 2.5))).Position;
                    for i: number, v: table? in tab do 
                        if typeof(v) ~= 'table' then 
                            errorNotification('Schematica', `/configuration/schematica/{schematicafile.Value:gsub('.json', '')}.json contains a syntax error at pos {i}.`);
                            return schematica.ToggleButton();
                        end;
                        local packagedvec: table = {};
                        table.foreach(v, function(__: number?, int: number?)
                            if typeof(int) ~= 'number' then 
                                return errorNotification('Schematica', `/configuration/schematica/{schematicafile.Value:gsub('.json', '')}.json (in the {i} section) contains a syntax error at pos {__}.`);
                            end;
                            table.insert(packagedvec, int);
                        end);
                        if #packagedvec > 2 then
                            task.wait(0.1 * schematicabuildtime.Value);
                            task.spawn(replicatedstorage.Remotes.ItemRemotes.PlaceBlock.InvokeServer, replicatedstorage.Remotes.ItemRemotes.PlaceBlock, placepos + Vector3.new(unpack(packagedvec)), block.name);
                        end;
                    end;
                    if schematica.Enabled then 
                        schematica.ToggleButton();
                    end;
                    InfoNotification('Schematica', 'Finished placing structure.', 5)
                end);
            else
                pcall(task.cancel, schematicathread)
            end 
        end
    });
    schematicafile = schematica.CreateTextBox({
        Name = 'File',
        TempText = 'file (no extension)',
        FocusLost = void
    });
    schematicabuildtime = schematica.CreateSlider({
        Name = 'Delay',
        Min = 0,
        Max = 15,
        Function = void
    })
end);

run(function()
    local lootexploit: vapemodule = {};
    lootexploit = exploit.Api.CreateOptionsButton({
        Name = 'LootExploit',
        HoverText = 'Misscredits player kills to give you loot.',
        Function = function(calling: boolean)
            if calling then 
                repeat
                    for i: number, v: rendertarget in GetAllTargets() do 
                        replicatedstorage.Remotes.GiveTag:FireServer(v.Player.Character, 'Sword');
                    end;
                    task.wait(0.1);
                until (not lootexploit.Enabled)
            end
        end
    })
end);

run(function()
    local damageindicator: table = {};
    local damageindicatorcoloroption: table = {};
    local damageindicatorfontoption: table = {};
    local damageindicatorfontcustom: table = {};
    local damageindicatortextoption: table = {};
    local damageindicatorcolor2option: table = {};
    local damageindicatorcolor: table = newcolor();
    local damageindicatorcolor2: table = newcolor();
    local damageindicatorfontfile: table = {Value = ''};
    local damageindicatortextlist: table = {ObjectList = {}};
    local damageindicatorfont: table = {Value = 'GothamBold'};
    local indicatormessages = {
        '.gg/renderintents',
        'renderintents.lol',
        'renderintents.xyz',
        'render on top',
        'render >> tide paste'
    };
    damageindicator = visual.Api.CreateOptionsButton({
        Name = 'DamageIndicator',
        HoverText = 'Customize your damage indicator.',
        Function = function(calling: boolean)
            if calling then 
                table.insert(damageindicator.Connections, workspace.DamageIndicators.DescendantAdded:Connect(function(indicator: BillboardGui?)
                    if indicator.Name ~= 'DamageIndicatorGui' then return end;
                    pcall(function()
                        local label: TextLabel? = indicator:FindFirstChildOfClass('TextLabel');
                        local labelgradient: UIGradient = Instance.new('UIGradient', label);
                        local color: Color3 = Color3.fromHSV(damageindicatorcolor.Hue, damageindicatorcolor.Sat, damageindicatorcolor.Value);
                        local color2: Color3 = damageindicatorcolor2option.Enabled and Color3.fromHSV(damageindicatorcolor2.Hue, damageindicatorcolor2.Sat, damageindicatorcolor2.Value) or color;
                        labelgradient.Enabled = damageindicatorcoloroption.Enabled;
                        labelgradient.Color = ColorSequence.new({
                            [1] = ColorSequenceKeypoint.new(0, color),
                            [2] = ColorSequenceKeypoint.new(1, color2)
                        });
                        if labelgradient.Enabled then
                            label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        end;
                        if damageindicatorfontoption.Enabled then 
                            if damageindicatorfontcustom.Enabled then 
                                label.FontFace = Font.new(getcustomasset(damageindicatorfontfile.Value));
                            else
                                label.Font = damageindicatorfont.Value;
                            end;
                        end;
                        if damageindicatortextoption.Enabled then 
                            label.Text = getrandomvalue(damageindicatortextlist.ObjectList) ~= '' and getrandomvalue(damageindicatortextlist.ObjectList) or getrandomvalue(indicatormessages.ObjectList);
                        end;
                    end)
                end))
            end
        end
    });
    damageindicatorcoloroption = damageindicator.CreateToggle({
        Name = 'Color',
        Default = true,
        Function = function(calling: boolean)
            pcall(function() damageindicatorcolor.Object.Visible = calling end);
            pcall(function() damageindicatorcolor2option.Object.Visible = calling end);
            pcall(function() damageindicatorcolor2.Object.Visible = calling and damageindicatorcolor2option.Enabled end);
        end
    });
    damageindicatorcolor = damageindicator.CreateColorSlider({
        Name = 'Text Color',
        Function = void
    });
    damageindicatorcolor2option = damageindicator.CreateToggle({
        Name = 'Secondary Color',
        Default = true,
        Function = function(calling: boolean)
            pcall(function() damageindicatorcolor2.Object.Visible = calling end);
        end
    });
    damageindicatorcolor2 = damageindicator.CreateColorSlider({
        Name = 'Color 2',
        Function = void
    });
    damageindicatorfontoption = damageindicator.CreateToggle({
        Name = 'Text Font',
        Function = function(calling: boolean)
            pcall(function() damageindicatorfontcustom.Object.Visible = calling end);
            pcall(function() damageindicatorfont.Object.Visible = (calling and (not damageindicatorfontcustom.Enabled)) end);
            pcall(function() damageindicatorfontfile.Object.Visible = (calling and damageindicatorfontcustom.Enabled) end);
        end
    });
    damageindicatorfontcustom = damageindicator.CreateToggle({
        Name = 'Custom Font File',
        Function = function(calling: boolean)
            pcall(function() damageindicatorfontfile.Object.Visible = getcustomasset ~= nil and calling end);
            pcall(function() damageindicatorfont.Object.Visible = (not calling) end);
        end
    });
    damageindicatorfont = damageindicator.CreateDropdown({
        Name = 'Font',
        List = GetEnumItems('Font'),
        Function = void
    });
    damageindicatorfontfile = damageindicator.CreateTextBox({
        Name = 'Font File',
        TempText = 'font file (.tff)',
        FocusLost = void
    });
    damageindicatortextoption = damageindicator.CreateToggle({
        Name = 'Custom Text',
        Function = function(calling: boolean)
            pcall(function() damageindicatortextlist.Object.Visible = calling end);
        end
    });
    damageindicatortextlist = damageindicator.CreateTextList({
        Name = 'Text',
        TempText = 'messages',
        AddFunction = void
    });

    damageindicatorcolor.Object.Visible = false;
    damageindicatorcolor2option.Object.Visible = false;
    damageindicatorcolor2.Object.Visible = false;
    damageindicatorfontcustom.Object.Visible = false;
    damageindicatorfontfile.Object.Visible = false;
    damageindicatorfont.Object.Visible = false;
    damageindicatortextlist.Object.Visible = false;
end);

