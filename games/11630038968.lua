local vape = shared.rendervape;
local vapetarget = shared.VapeTargetInfo;
local entityLibrary = shared.vapeentity;
local renderevents = {};
local renderloaded = true;
local render = render;

for i,v in render.utils do 
	getfenv()[i] = v;
end;

local knitfetched, knit = nil, {
	GetService = function(service: string) 
		return getmetatable({}, {
			__index = function(self)
				return {}
			end
		})
	end,
	GetController = function(service: string) 
		return getmetatable({}, {
			__index = function(self)
				return {}
			end
		})
	end
};

local combat = vape.ObjectsThatCanBeSaved.CombatWindow;
local blatant = vape.ObjectsThatCanBeSaved.BlatantWindow;
local visual = vape.ObjectsThatCanBeSaved.RenderWindow;
local exploit = vape.ObjectsThatCanBeSaved.ExploitWindow;
local utility = vape.ObjectsThatCanBeSaved.UtilityWindow;
local world = vape.ObjectsThatCanBeSaved.WorldWindow;
local hudwindow = vape.ObjectsThatCanBeSaved.TargetHUDWindow;


local replicatedstorage = getservice('ReplicatedStorage');
local players = getservice('Players');
local runservice = getservice('RunService');
local collection = getservice('CollectionService');
local tween = getservice('TweenService');
local camera = workspace.CurrentCamera;
local lplr = players.LocalPlayer;
local entityLibrary = shared.vapeentity;

vape.SelfDestructEvent.Event:Once(function()
	renderloaded = false;
	for i,v in renderevents do 
		pcall(v.Disconnect, v);
	end;
end)

if cheatenginetrash == nil then 
	repeat
		knitfetched, knit = pcall(function()
			return require(replicatedstorage.Packages.Knit.KnitClient);
		end);
		task.wait()
	until knitfetched and knit;
end;

local store = setmetatable({
	toolservice = knit.GetService('ToolService'),
	config = knit.GetService('SettingsService'),
	viewmodel = knit.GetController('ViewmodelController'),
	notification = knit.GetController('NotificationController'),
	blocks = collection:GetTagged('Blocks'),
    knit = knit,
    events = setmetatable({}, {
        __index =  function(self, index)
            if rawget(self, index) == nil then 
                self[index] = Instance.new('BindableEvent')
            end
            return rawget(self, index)
        end
    })
}, {
	__index = function(self, index)
		if index == 'blocks' then 
			rawget(self, 'raycast').FilterDescendantsInstances = {rawget(self, 'blocks')};
		end;
        return rawget(self, index)
	end
});

for i,v in replicatedstorage:GetDescendants() do 
    if v.ClassName == 'RemoteEvent' then 
        table.insert(renderevents, v.OnClientEvent:Connect(function(...)
            store.events[v.Name]:Fire(...)
        end))
    end
end

getgenv().bridgeduels = store;

local oldattack = store.toolservice.AttackPlayerWithSword;
store.toolservice.AttackPlayerWithSword = function(self, character, ...)
	local success, player = pcall(players.GetPlayerFromCharacter, players, character)
	if success and player and not RenderLibrary.whitelist:get(2, player) then 
		--return
	end
	return oldattack(self, character, ...)
end;

table.insert(renderevents, {
	Disconnect = function(self)
		store.toolservice.AttackPlayerWithSword = oldattack;
	end
});

table.insert(renderevents, collection:GetInstanceAddedSignal('Block'):Connect(function(block) table.insert(store.blocks, block) end));

--run(AddEntityMapTag, 'NPC');
task.spawn(function()
	repeat task.wait() until render.button;
	if render.button.isNewUI == false then 
		render.button.instance.Parent = lplr.PlayerGui:WaitForChild('TopbarStandard'):WaitForChild('Holders'):WaitForChild('Left');
		render.button.instance.LayoutOrder = 100;
	else
		render.button.Visible = not inputservice.KeyboardEnabled;
	end
end);

task.spawn(function()
	repeat 
		camera = workspace.CurrentCamera or fakecam;
		task.wait()
	until (not vapeInjected)
end);

local gethighestblock = function(position, smart, raycast, customvector)
	if not position then 
		return nil 
	end
	if raycast and not workspace:Raycast(position, Vector3.new(0, -2000, 0), render.raycast) then
		return nil
	end
	local lastblock
	for i = 1, 500 do 
		local newray = workspace:Raycast(lastblock and lastblock.Position or position, customvector or Vector3.new(0.55, 9e9, 0.55), render.raycast)
		local smartest = newray and smart and workspace:Raycast(lastblock and lastblock.Position or position, Vector3.new(0, 5.5, 0), render.raycast) or not smart
		if newray and smartest then
			lastblock = newray
		else
			break
		end
	end
	return lastblock
end;

function store:attackEntity(...)
	return replicatedstorage.Packages.Knit.Services.ToolService.RF.AttackPlayerWithSword:InvokeServer(...)
end;

function store:toggleblock(...)
    return replicatedstorage.Packages.Knit.Services.ToolService.RF.ToggleBlockSword:InvokeServer(...)
end;

function store:switchitem(item: string, single: boolean?, noholdlast: boolean?)
    local tool = lplr.Backpack:FindFirstChild(item);
    local oldtool = lplr.Character and lplr.Character:FindFirstChildOfClass('Tool');
    if isAlive(lplr, true) and tool and tool.ClassName == 'Tool' then 
        tool.Parent = lplr.Character;
        if single then 
            for i,v in lplr.Character:GetChildren() do 
                if v.ClassName == 'Tool' and v ~= tool and (v ~= oldtool or noholdlast) then 
                    v.Parent = lplr.Backpack;
                end;
            end
        end
        return true;
    end;
    return false;
end;

function store:getweapon()
	if lplr.Character then 
		for i,v in lplr.Character:GetChildren() do
			if v.ClassName == 'Tool' and v.Name:lower():find('sword') then 
				return v; 
			end 
		end
	end
end;

function store:gethelditem()
	return camera:FindFirstChild('Viewmodel') and camera.Viewmodel:GetChildren()[1]
end;

vape.RemoveObject('PlayerTPOptionsButton');
vape.RemoveObject('AutoRewindOptionsButton');
vape.RemoveObject('ClientKickDisablerOptionsButton');

run(function()
	local KillauraRange = {Value = 22}
	local KillauraCooldown = {Value = 10}
	local KillauraNoSwing = {}
	local KillauraAutoBlock = {};
	local KillauraHighlight = {};
    local KillauraAnimation = {Value = 'Slide2'};
	local KillauraHighlightColor = newcolor();
    local KillauraCriticals = {};
	local KillauraSortMethod = {Value = 'Health'};
	local animationdelay = tick();
	local killauraboxes = Performance.new();
	local killaurabox;
    local killauraplayinganim;
    local killauraanimthread;
    local oldviewmodelplay = store.viewmodel.PlayAnimation;
    local oldviewmodelblockplay = store.viewmodel.ToggleLoopedAnimation;
	local oldtarget;
    local sword;
    local oldswordC0;

	local KillauraSort = {
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
    local auratweens = {
        Testing = {
            {
                angles = CFrame.new(0.07, 0.7, 0.6) * CFrame.Angles(math.rad(-20), math.rad(360), math.rad(50)),
                duration = 0.25,
            },
            {
                angles = CFrame.new(0.07, 0.3, 0.6) * CFrame.Angles(math.rad(-280), math.rad(50), math.rad(50)),
                duration = 0.2,
            }
        },
		Slide2 = {
			{
				angles = CFrame.new(0, 0.25, 2.5) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(110)),
				duration = 0.08
			},
			{
				angles = CFrame.new(0,-1.25,2.5) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(170)),
				duration = 0.16,
			},
		},
		Original = {
			{
				angles = CFrame.new(0, 0.25, 2.5) * CFrame.Angles(math.rad(55), math.rad(342), math.rad(110)),
				duration = 0.08
			},
			{
				angles = CFrame.new(0,-1.25,2.5) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(170)),
				duration = 0.16,
			},
		},
        Slow = {
            {
                angles = CFrame.new(0,-0.25,2.5) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(160)),
                duration = 0.2,
            },
            {
                angles = CFrame.new(0, 0.65, 2.5) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(110)),
                duration = 0.3
            }
        },

    }
	Killaura = vape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Killaura',
		HoverText = 'Automatically attack nearby targets.',
		Function = function(calling)
			if calling then 
                killauraanimthread = task.spawn(function()
                    repeat 
                        pcall(function()
                            local viewmodelhandle = camera.Viewmodel[tostring(sword)].Handle.MainPart;
                            if sword and oldswordC0 == nil or KillauraAnimation.Value == 'Default' then 
                                pcall(store.viewmodel.ToggleLoopedAnimation, store.viewmodel, false);
                                oldswordC0 = viewmodelhandle.C0;
                            end;
                            for i,v in (auratweens[KillauraAnimation.Value] or {}) do 
                                if vapetarget.Targets.Killaura == nil then 
                                    if killauraplayinganim then
                                        tween:Create(viewmodelhandle, TweenInfo.new(0.2), {C0 = oldswordC0}):Play()
                                        store.viewmodel.PlayAnimation = oldviewmodelplay;
                                        store.viewmodel.ToggleLoopedAnimation = oldviewmodelblockplay;
                                        killauraplayinganim = false;
                                    end;
                                    continue
                                end;
                                store.viewmodel.PlayAnimation = void;
                                store.viewmodel.ToggleLoopedAnimation = void;
                                local playedAt = tick();
                                local animtween = tween:Create(viewmodelhandle, TweenInfo.new(v.duration), {C0 = oldswordC0 * v.angles});
                                animtween:Play();
                                killauraplayinganim = true;
                                repeat task.wait() until ((tick() - playedAt) >= v.duration or vapetarget.Targets.Killaura == nil);
                            end;
                        end)
                        task.wait()
                    until (not Killaura.Enabled)
                end);
				table.insert(renderevents, runservice.Heartbeat:Connect(function()
                    local targets = GetAllTargets(KillauraRange.Value, true, KillauraSort[KillauraSortMethod.Value]);
						sword = store:getweapon();
						if #targets == 0 or sword == nil then 
							render.targets:updatehuds()
							vapetarget.Targets.Killaura = nil
							if oldtarget then 
								for i,v in killauraboxes do 
									pcall(function() v:Destroy() end) 
								end;
								table.clear(killauraboxes)
								lplr:SetAttribute('Blocking', false)
								oldtarget = nil
							end;
						end
						for i,v in targets do 
							if replicatedstorage:FindFirstChild('ZonePlusReference') and not v.Player:GetAttribute('InPVPArena') then 
								--continue
							end;
							render.targets:updatehuds(v)
							oldtarget = true
							vapetarget.Targets.Killaura = v;
							if KillauraAutoBlock.Enabled then 
								store:toggleblock(true, tostring(sword))
							end;
							task.spawn(oldviewmodelplay, tostring(sword))
							if KillauraAnimation.Value ~= 'None' then 
								pcall(function() sword:Activate() end)
							end;
							store:switchitem('Sword', true);
							if killaurabox and v.Player.Character and v.Player.Character:FindFirstChildOfClass('BoxHandleAdornment') == nil then 
								local box = killaurabox:Clone();
								box.Parent = v.Player.Character;
								box.Adornee = v.Player.Character;
								box.Color3 = Color3.fromHSV(KillauraHighlightColor.Hue, KillauraHighlightColor.Sat, KillauraHighlightColor.Value)
								table.insert(killauraboxes, box);
							end
							task.spawn(store.attackEntity, store, v.Player.Character, KillauraCriticals.Enabled, tostring(sword));
							if KillauraSortMethod.Value ~= 'Switch' then 
								break
							end
						end
                end));
				repeat 
					if tick() > animationdelay and oldtarget and not KillauraNoSwing.Enabled then 
						store.viewmodel:PlayAnimation(tostring(sword))
						animationdelay = (tick() + (KillauraCooldown.Value / 10))
						continue
					end
					task.wait()
				until (not Killaura.Enabled)
			else 
				for i,v in killauraboxes do 
					pcall(function() v:Destroy() end) 
				end;
				table.clear(killauraboxes);
                task.cancel(killauraanimthread);
                if oldswordC0 then 
                    pcall(function() tween:Create(camera.Viewmodel[tostring(sword)].Handle.MainPart, TweenInfo.new(0.2), {C0 = oldswordC0}):Play() end);
                    oldswordC0 = nil;
                end;
                store.viewmodel.PlayAnimation = oldviewmodelplay;
                store.viewmodel.ToggleLoopedAnimation = oldviewmodelblockplay;
			end
		end
	})
	KillauraRange = Killaura.CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 20,
		Default = 20,
		Function = function() end
	})
	KillauraCooldown = Killaura.CreateSlider({
		Name = 'Animation Delay',
		Min = 1,
		Max = 100,
		Default = 3,
		Function = function() end
	})
	KillauraSortMethod = Killaura.CreateDropdown({
		Name = 'Sort',
		List = {'Distance', 'Health', 'Switch'},
		Function = function() end
	});
	KillauraAnimation = Killaura.CreateDropdown({
		Name = 'Animation',
		List = {'None', 'Default', 'Original', 'Slide2', 'Slow'},
		Function = void
	})
    KillauraCriticals = Killaura.CreateToggle({
        Name = 'Criticals',
        HoverText = 'Makes every hit a critical hit.',
        Default = true,
        Function = void
    })
	KillauraAutoBlock = Killaura.CreateToggle({
		Name = 'Block',
		Default = true,
		HoverText = 'Automatically blocks attacks',
		Function = function() end
	})
	KillauraHighlight = Killaura.CreateToggle({
		Name = 'Target Box',
		HoverText = 'Highlights your target(s)',
		Function = function(calling)
			if calling then 
				pcall(function() KillauraHighlightColor.Object.Visible = calling end);
				killaurabox = Instance.new('BoxHandleAdornment', vape.MainGui);
				killaurabox.Transparency = 0.5;
				killaurabox.Color3 = Color3.fromHSV(KillauraHighlightColor.Hue, KillauraHighlightColor.Sat, KillauraHighlightColor.Value);
				killaurabox.Size = Vector3.new(3, 6, 3);
				killaurabox.AlwaysOnTop = true;
				killaurabox.ZIndex = 9e9;
			else 
				pcall(function() killaurabox:Destroy() end);
				killaurabox = nil; 
			end
		end
	});
	KillauraHighlightColor = Killaura.CreateColorSlider({
		Name = 'Box Color',
		Function = function()
			pcall(function() killaurabox.Color3 = Color3.fromHSV(KillauraHighlightColor.Hue, KillauraHighlightColor.Sat, KillauraHighlightColor.Value) end);
			for i,v in killauraboxes do
				pcall(function() v.Color3 = Color3.fromHSV(KillauraHighlightColor.Hue, KillauraHighlightColor.Sat, KillauraHighlightColor.Value) end) 
			end
		end
	});
	KillauraHighlightColor.Object.Visible = false;
end);

run(function()
	local autoheal = {};
	autoheal = utility.Api.CreateOptionsButton({
		Name = 'AutoHeal',
		HoverText = 'Automatically consumes apple to heal without\nneeding to switch tools.',
		Function = function(calling)
			if calling then 
				repeat 
					if isAlive(lplr, true) and vapetarget.Targets.Killaura == nil and vapetarget.Targets.ProjectileAura == nil then 
						store:switchitem('GoldApple');
						if lplr.Character:FindFirstChild('GoldApple') then 
							task.wait(0.1);
							pcall(function()
								lplr.Character.GoldApple.__comm__.RF.Eat:InvokeServer(true);
							end)
						end;
					end
					task.wait()
				until (not autoheal.Enabled)
			end
		end
	})
end);

run(function()
	local partialdisabler = {};
	local oldgame;
	partialdisabler = utility.Api.CreateOptionsButton({
		Name = 'DetectionDisabler',
		HoverText = 'Disables client sided anti cheat checks fully\n(script detection, cps detection, etc.)',
		Function = function(calling)
			if calling then 
				if oldgame then return end;
				oldgame = hookmetamethod(game, '__namecall', function(self, ...)
					if checkcaller() then 
						return oldgame(self, ...)
					end;
					if partialdisabler.Enabled and getnamecallmethod():lower() == 'kick' then 
						return
					end;
					if partialdisabler.Enabled and typeof(self) == 'Instance' and self.ClassName:lower():find('remote') and (tostring(self):lower():find('tps') or tostring(self):lower():find('cps') or tostring(self):lower():find('head')) then 
						return
					end;
					return oldgame(self, ...)
				end);
				local oldwarn; oldwarn = hookfunction(warn, function(message, ...)
					if not checkcaller() then 
						return 
					end;
					return oldwarn(message, ...)
				end)
			else 
				if restorefunction then 
					restorefunction(warn)
				else
					hookfunction(warn, warn)
				end;
			end
		end
	})
end)

run(function()
    local autotoxic = {};
    local autotoxicmatch = {ObjectList = {}};
    local autotoxicmatch2 = {ObjectList = {}};
    local cachedusers = {};
    local autotoxicmatch = {
        'hack',
        'exploit',
        'hacker',
        'exploiter',
        'cheater',
        'cheat',
        'bad'
    }
    autotoxic = utility.Api.CreateOptionsButton({
        Name = 'AutoToxic',
        HoverText = 'Automatically insults players. (using <name> will basically say their name)',
        Function = function(calling)
            if calling then 
                table.insert(autotoxic.Connections, store.events.OnKill.Event:Connect(function(selfdata: table, data: table)
                    if typeof(data) == 'table' and data.Name and not data.IsNPC then 
                        local player = players:FindFirstChild(data.Name);
                        if player and player:GetAttribute('LastAttacker') == lplr.Name then 
                            local autotoxicstr = getrandomvalue(autotoxicmatch.ObjectList) ~= '' and getrandomvalue(autotoxicmatch.ObjectList) or `POV: You don't use render <name> | renderintents.lol`;
                            sendmessage(autotoxicstr:gsub('<name>', player.DisplayName))
                        end
                    end
                end));
                table.insert(autotoxic.Connections, render.events.message.Event:Connect(function(player: Player, message: string)
                    local matched; 
                    for i,v in autotoxicmatch do 
                        if message:lower() == v or message:lower():find(` {v}`) or message:lower():find(`{v} `) then 
                            matched = true; 
                            break 
                        end;
                    end;
                    if player ~= lplr and matched and table.find(cachedusers, player.UserId) == nil then 
                        local autotoxicstr = getrandomvalue(autotoxicmatch2.ObjectList) ~= '' and  getrandomvalue(autotoxicmatch2.ObjectList) or `cry me a river <name> or even better, use render! | renderintents.lol`;
                        sendmessage(autotoxicstr:gsub('<name>', player.DisplayName));
                        table.insert(cachedusers, player.UserId);
                    end
                end))
            end
        end
    });
	autotoxicmatch = autotoxic.CreateTextList({
		Name = 'Kill Messages',
		TempText = 'kill messages',
		AddFunction = void
	});
	autotoxicmatch2 = autotoxic.CreateTextList({
		Name = 'Complain Messages',
		TempText = 'complain messages',
		AddFunction = void
	})
end);

run(function()
    combat.Api.CreateOptionsButton({
        Name = 'Velocity',
        HoverText = 'Stops you from taking knockback',
        Function = function(calling)
            if calling then 
                for i,v in getconnections(replicatedstorage.Packages.Knit.Services.CombatService.RE.KnockBackApplied.OnClientEvent) do 
                    if table.find(renderevents, v) == nil then 
                        pcall(v.Disable, v)
                    end
                end; 
            else
                for i,v in getconnections(replicatedstorage.Packages.Knit.Services.CombatService.RE.KnockBackApplied.OnClientEvent) do 
                    pcall(v.Enable, v)
                end;
            end
        end
    })
end);

run(function()
	local oldtool;
	local projectileaura; projectileaura = blatant.Api.CreateOptionsButton({
		Name = 'ProjectileAura',
		HoverText = 'Automatically shoots at players',
		Function = function(calling)
			if calling then 
				table.insert(projectileaura.Connections, lplr.PlayerGui.MainGui.Notifications.ChildAdded:Connect(function(label)
					if label.ClassName == 'TextLabel' and label.Text:find('Failed to shoot bow!') then 
						label.Visible = false;
					end;
				end));
				repeat 
					pcall(function()
						local target = GetTarget();
						if lplr.Character then 
							oldtool = store:gethelditem()
						end;
						store:switchitem('DefaultBow');
						if target.RootPart and (replicatedstorage:FindFirstChild('ZonePlusReference') == nil or target.Player:GetAttribute('InPVPArena')) then 
							vapetarget.Targets.ProjectileAura = target;
							task.spawn(lplr.Character.DefaultBow.__comm__.RF.Fire.InvokeServer, lplr.Character.DefaultBow.__comm__.RF.Fire, target.RootPart.Position, 1)
						else 
							vapetarget.Targets.ProjectileAura = nil;
						end
					end)
					task.wait(1)
				until (not projectileaura.Enabled)
			end
		end
	})
end);

