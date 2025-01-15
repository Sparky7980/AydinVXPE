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
   CustomModules/6872274481.lua (bedwars) - SystemXVoid/BlankedVoid and Maxlasertech            
   https://renderintents.lol                                                                                                                                                                                                                                                                     
]]
   
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

type invitemobject = {
	itemType: string,
	tool: Instance
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

type rendertarget = {
    Player: Player | nil,
    Humanoid: Humanoid | nil,
    RootPart: BasePart | nil,
    NPC: boolean | nil
};

local vape = shared.rendervape;
local cloneref = cloneref or function(data) return data end;
local getservice = function(service)
	return cloneref(game:FindService(service))
end;

local players = getservice('Players');
local textservice = getservice('TextService');
local lighting = getservice('Lighting');
local textchat = getservice('TextChatService');
local inputservice = getservice('UserInputService');
local runservice = getservice('RunService');
local teleport = getservice('TeleportService');
local tween = getservice('TweenService');
local collection = getservice('CollectionService');
local httpservice = getservice('HttpService');
local contextaction: ContextActionService = getservice('ContextActionService');
local replicatedstorage = getservice('ReplicatedStorage');
local fakecam = Instance.new('Camera');
local camera = workspace.CurrentCamera;
local lplr = players.LocalPlayer;
local vapeConnections = {};
local vapeCachedAssets = {};
local vapeEvents = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new('BindableEvent')
		return self[index]
	end
});
local vapeTargetInfo = shared.VapeTargetInfo;
local vapeInjected = true;

local render = render;
local renderperformance = shared.renderperformance;
local bedwars = {};
local store = {
	attackReach = 0,
	attackReachUpdate = tick(),
	blocks = {},
	blockPlacer = {},
	blockPlace = tick(),
	raycast = RaycastParams.new(),
	equippedKit = 'none',
	forgeMasteryPoints = 0,
	forgeUpgrades = {},
	grapple = tick(),
	inventories = {},
	localInventory = {
		inventory = {
			items = {},
			armor = {}
		},
		hotbar = {}
	},
	localHand = {},
	matchState = 0,
	matchStateChanged = tick(),
	pots = {},
	queueType = 'bedwars_test',
	scythe = tick(),
	lastdamage = tick(),
	statistics = {
		beds = 0,
		kills = 0,
		lagbacks = 0,
		lagbackEvent = Instance.new('BindableEvent'),
		reported = 0,
		universalLagbacks = 0
	},
	whitelist = {
		chatStrings1 = {helloimusinginhaler = 'vape'},
		chatStrings2 = {vape = 'helloimusinginhaler'},
		clientUsers = {},
		oldChatFunctions = {}
	},
	zephyrOrb = 0,
	auraAttacks = 0,
	switchdelay = tick()
};
store.raycast.FilterType = Enum.RaycastFilterType.Include;

local combat = vape.ObjectsThatCanBeSaved.CombatWindow;
local blatant = vape.ObjectsThatCanBeSaved.BlatantWindow;
local visual = vape.ObjectsThatCanBeSaved.RenderWindow;
local exploit = vape.ObjectsThatCanBeSaved.ExploitWindow;
local utility = vape.ObjectsThatCanBeSaved.UtilityWindow;
local world = vape.ObjectsThatCanBeSaved.WorldWindow;
local hudwindow = vape.ObjectsThatCanBeSaved.TargetHUDWindow;

for i,v in render.utils do
	getfenv()[i] = v;
end

task.spawn(function()
	repeat 
		camera = workspace.CurrentCamera or fakecam;
		task.wait()
	until (not vapeInjected)
end);

local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end;

local networkownerswitch = tick()
--ME WHEN THE MOBILE EXPLOITS ADD A DISFUNCTIONAL ISNETWORKOWNER (its for compatability I swear!!)
local isnetworkowner = function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, 'NetworkOwnershipRule') end)
	if suc and res == Enum.NetworkOwnership.Manual then
		sethiddenproperty(part, 'NetworkOwnershipRule', Enum.NetworkOwnership.Automatic)
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end;

local getcustomasset = getsynasset or getcustomasset or function(location) return 'rbxasset://'..location end
local queueonteleport = syn and syn.queue_on_teleport or queue_on_teleport or void
local synapsev3 = syn and syn.toast_notification and 'V3' or ''
local worldtoscreenpoint = function(pos)
	if synapsev3 == 'V3' then
		local scr = worldtoscreen({pos})
		return scr[1] - Vector3.new(0, 36, 0), scr[1].Z > 0
	end
	return camera.WorldToScreenPoint(camera, pos)
end
local worldtoviewportpoint = function(pos)
	if synapsev3 == 'V3' then
		local scr = worldtoscreen({pos})
		return scr[1], scr[1].Z > 0
	end
	return camera.WorldToViewportPoint(camera, pos)
end

local function vapeGithubRequest(scripturl)
	if not isfile('rendervape/'..scripturl) then
		local suc, res = pcall(function() return game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/'..readfile('rendervape/commithash.txt')..'/'..scripturl, true) end)
		assert(suc, res)
		assert(res ~= '404: Not Found', res)
		if scripturl:find('.lua') then res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n'..res end
		writefile('rendervape/'..scripturl, res)
	end
	return readfile('rendervape/'..scripturl)
end

local function downloadVapeAsset(path)
	if not isfile(path) then
		task.spawn(function()
			local textlabel = Instance.new('TextLabel')
			textlabel.Size = UDim2.new(1, 0, 0, 36)
			textlabel.Text = 'Downloading '..path
			textlabel.BackgroundTransparency = 12
			textlabel.TextStrokeTransparency = 0
			textlabel.TextSize = 30
			textlabel.Font = Enum.Font.SourceSans
			textlabel.TextColor3 = Color3.new(1, 1, 1)
			textlabel.Position = UDim2.new(0, 0, 0, -36)
			textlabel.Parent = vape.MainGui
			repeat task.wait() until isfile(path)
			textlabel:Destroy()
		end)
		local suc, req = pcall(function() return vapeGithubRequest(path:gsub('rendervape/assets', 'assets')) end)
		if suc and req then
			writefile(path, req)
		else
			return ''
		end
	end
	if not vapeCachedAssets[path] then vapeCachedAssets[path] = getcustomasset(path) end
	return vapeCachedAssets[path]
end;

local function run(func) pcall(func) end;

local function isFriend(plr, recolor)
	if vape.ObjectsThatCanBeSaved['Use FriendsToggle'].Api.Enabled then
		local friend = table.find(vape.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectList, plr.Name)
		friend = friend and vape.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectListEnabled[friend]
		if recolor then
			friend = friend and vape.ObjectsThatCanBeSaved['Recolor visualsToggle'].Api.Enabled
		end
		return friend
	end
	return nil
end

local function isTarget(plr)
	local friend = table.find(vape.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectList, plr.Name)
	friend = friend and vape.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectListEnabled[friend]
	return friend
end

local function isVulnerable(plr)
	return plr.Humanoid.Health > 0 and not plr.Character.FindFirstChildWhichIsA(plr.Character, 'ForceField')
end

local function getPlayerColor(plr)
	if isFriend(plr, true) then
		return Color3.fromHSV(vape.ObjectsThatCanBeSaved['Friends ColorSliderColor'].Api.Hue, vape.ObjectsThatCanBeSaved['Friends ColorSliderColor'].Api.Sat, vape.ObjectsThatCanBeSaved['Friends ColorSliderColor'].Api.Value)
	end
	return tostring(plr.TeamColor) ~= 'White' and plr.TeamColor.Color
end

local function LaunchAngle(v, g, d, h, higherArc)
	local v2 = v * v
	local v4 = v2 * v2
	local root = -math.sqrt(v4 - g*(g*d*d + 2*h*v2))
	return math.atan((v2 + root) / (g * d))
end

local function LaunchDirection(start, target, v, g)
	local horizontal = Vector3.new(target.X - start.X, 0, target.Z - start.Z)
	local h = target.Y - start.Y
	local d = horizontal.Magnitude
	local a = LaunchAngle(v, g, d, h)

	if a ~= a then
		return g == 0 and (target - start).Unit * v
	end

	local vec = horizontal.Unit * v
	local rotAxis = Vector3.new(-horizontal.Z, 0, horizontal.X)
	return CFrame.fromAxisAngle(rotAxis, a) * vec
end

local physicsUpdate = 1 / 60

local function predictGravity(playerPosition, vel, bulletTime, targetPart, Gravity)
	local estimatedVelocity = vel.Y
	local rootSize = (targetPart.Humanoid.HipHeight + (targetPart.RootPart.Size.Y / 2))
	local velocityCheck = (tick() - targetPart.JumpTick) < 0.2
	vel = vel * physicsUpdate

	for i = 1, math.ceil(bulletTime / physicsUpdate) do
		if velocityCheck then
			estimatedVelocity = estimatedVelocity - (Gravity * physicsUpdate)
		else
			estimatedVelocity = 0
			playerPosition = playerPosition + Vector3.new(0, -0.03, 0) -- bw hitreg is so bad that I have to add this LOL
			rootSize = rootSize - 0.03
		end

		local floorDetection = workspace:Raycast(playerPosition, Vector3.new(vel.X, (estimatedVelocity * physicsUpdate) - rootSize, vel.Z), store.raycast)
		if floorDetection then
			playerPosition = Vector3.new(playerPosition.X, floorDetection.Position.Y + rootSize, playerPosition.Z)
			local bouncepad = floorDetection.Instance:FindFirstAncestor('gumdrop_bounce_pad')
			if bouncepad and bouncepad:GetAttribute('PlacedByUserId') == targetPart.Player.UserId then
				estimatedVelocity = 130 - (Gravity * physicsUpdate)
				velocityCheck = true
			else
				estimatedVelocity = targetPart.Humanoid.JumpPower - (Gravity * physicsUpdate)
				velocityCheck = targetPart.Jumping
			end
		end

		playerPosition = playerPosition + Vector3.new(vel.X, velocityCheck and estimatedVelocity * physicsUpdate or 0, vel.Z)
	end

	return playerPosition, Vector3.new(0, 0, 0)
end

local entityLibrary = shared.vapeentity
local whitelist = shared.vapewhitelist
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

vape.SelfDestructEvent.Event:Once(function()
	vapeInjected = false
	for i, v in (vapeConnections) do
		if v.Disconnect then pcall(function() v:Disconnect() end) continue end
		if v.disconnect then pcall(function() v:disconnect() end) continue end
	end
	if bedwars.disable then 
		bedwars:disable();
	end;
    for i,v in store do 
        if typeof(v) == 'table' then 
            if v.shutdown then 
                v:shutdown()
            end;
            --table.clear(v)
        end
    end;
	getgenv().bedwars = nil;
	getgenv().bedwarsStore = nil;
	table.clear(vapeConnections)
end);

local function getItem(itemName, inv)
	for slot, item in (inv or store.localInventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot
		end
	end
	return nil
end

local getserverhand: (Player | nil) -> (table | nil) = function(player)
	local player: Player = player or lplr;
	local hand: Instance | nil = player.Character and player.Character:FindFirstChild('HandInvItem');
	return hand and getItem(tostring(hand.Value))
end;

local function getItemNear(itemName, inv)
	for slot, item in (inv or store.localInventory.inventory.items) do
		if item.itemType == itemName or item.itemType:find(itemName) then
			return item, slot
		end
	end
	return nil
end

local function getHotbarSlot(itemName)
	for slotNumber, slotTable in (store.localInventory.hotbar) do
		if slotTable.item and slotTable.item.itemType == itemName then
			return slotNumber - 1
		end
	end
	return nil
end

local function getShieldAttribute(char)
	local returnedShield = 0
	for attributeName, attributeValue in (char:GetAttributes()) do
		if attributeName:find('Shield') and type(attributeValue) == 'number' then
			returnedShield = returnedShield + attributeValue
		end
	end
	return returnedShield
end

local function getPickaxe()
	return getItemNear('pick')
end

local function getAxe()
	local bestAxe, bestAxeSlot = nil, nil
	for slot, item in (store.localInventory.inventory.items) do
		if item.itemType:find('axe') and item.itemType:find('pickaxe') == nil and item.itemType:find('void') == nil then
			bextAxe, bextAxeSlot = item, slot
		end
	end
	return bestAxe, bestAxeSlot
end

local function getSword()
	local bestSword, bestSwordSlot, bestSwordDamage = nil, nil, 0
	for slot, item in (store.localInventory.inventory.items) do
		local swordMeta = bedwars.ItemTable[item.itemType].sword
		if swordMeta then
			local swordDamage = swordMeta.damage or 0
			if swordDamage > bestSwordDamage then
				bestSword, bestSwordSlot, bestSwordDamage = item, slot, swordDamage
			end
		end
	end
	return bestSword, bestSwordSlot
end

local function getBow()
	local bestBow, bestBowSlot, bestBowStrength = nil, nil, 0
	for slot, item in (store.localInventory.inventory.items) do
		if item.itemType:find('bow') then
			local tab = bedwars.ItemTable[item.itemType].projectileSource
			local ammo = tab.projectileType('arrow')
			local dmg = bedwars.ProjectileMeta[ammo].combat.damage
			if dmg > bestBowStrength then
				bestBow, bestBowSlot, bestBowStrength = item, slot, dmg
			end
		end
	end
	return bestBow, bestBowSlot
end

local function getWool()
	local wool = getItemNear('wool')
	return wool and wool.itemType, wool and wool.amount
end

local function getBlock()
	for slot, item in (store.localInventory.inventory.items) do
		if bedwars.ItemTable[item.itemType].block then
			return item.itemType, item.amount
		end
	end
end

local function attackValue(vec)
	return {value = vec}
end

local function getSpeed(): (number)
	local speed = 0
	if lplr.Character then
		local SpeedDamageBoost = lplr.Character:GetAttribute('SpeedBoost')
		if SpeedDamageBoost and SpeedDamageBoost > 1 then
			speed += (8 * (SpeedDamageBoost - 1))
			if isEnabled('Desync') and render.clone.new then 
				speed += 10;
			end;
		end
		if store.grapple > tick() then
			speed += 90
		end
		if store.scythe > tick() then
			speed += (isEnabled('Desync') and render.clone.new and 58 or 17.3)
		end
		if lplr.Character:GetAttribute('GrimReaperChannel') then
			speed += 20
		end
		local armor = store.localInventory.inventory.armor[3]
		if type(armor) ~= 'table' then armor = {itemType = ''} end
		if armor.itemType == 'speed_boots' then
			speed += 12
		end
		if store.zephyrOrb ~= 0 then
			speed += 25
		end;
		if store.beastmode then 
			speed += 40
		end;
		if store.lastdamage > tick() and isEnabled('DamageBoost') and not isEnabled('LongJump') then 
			speed += 32.5
		end;
		if isEnabled('LongJump') and isEnabled('Desync') and render.clone.new then
			speed += 30;
		end;
		if render.clone.old and not isnetworkowner(render.clone.old) then 
			speed = 0;
		end;
	end
	return speed
end;

local Reach = {Enabled = false}
local blacklistedblocks = {
	bed = true,
	ceramic = true
}
local cachedNormalSides = {}
for i,v in (Enum.NormalId:GetEnumItems()) do if v.Name ~= 'Bottom' then table.insert(cachedNormalSides, v) end end
local updateitem = Instance.new('BindableEvent')
table.insert(vapeConnections, updateitem.Event:Connect(function(inputObj)
	if inputservice:IsMouseButtonPressed(0) then
		getservice('ContextActionService'):CallFunction('block-break', Enum.UserInputState.Begin, newproxy(true))
	end
end))

local function getPlacedBlock(pos)
	local roundedPosition = bedwars.BlockController:getBlockPosition(pos)
	return bedwars.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition
end

local oldpos = Vector3.zero

local function getScaffold(vec, diagonaltoggle)
	local realvec = Vector3.new(math.floor((vec.X / 3) + 0.5) * 3, math.floor((vec.Y / 3) + 0.5) * 3, math.floor((vec.Z / 3) + 0.5) * 3)
	local speedCFrame = (oldpos - realvec)
	local returedpos = realvec
	if entityLibrary.isAlive then
		local angle = math.deg(math.atan2(-entityLibrary.character.Humanoid.MoveDirection.X, -entityLibrary.character.Humanoid.MoveDirection.Z))
		local goingdiagonal = (angle >= 130 and angle <= 150) or (angle <= -35 and angle >= -50) or (angle >= 35 and angle <= 50) or (angle <= -130 and angle >= -150)
		if goingdiagonal and ((speedCFrame.X == 0 and speedCFrame.Z ~= 0) or (speedCFrame.X ~= 0 and speedCFrame.Z == 0)) and diagonaltoggle then
			return oldpos
		end
	end
	return realvec
end

local function getBestTool(block)
	local tool = nil
	local blockmeta = bedwars.ItemTable[block]
	local blockType = blockmeta.block and blockmeta.block.breakType
	if blockType then
		local best = 0
		for i,v in (store.localInventory.inventory.items) do
			local meta = bedwars.ItemTable[v.itemType]
			if meta.breakBlock and meta.breakBlock[blockType] and meta.breakBlock[blockType] >= best then
				best = meta.breakBlock[blockType]
				tool = v
			end
		end
	end
	return tool
end;

local function switchItem(tool)
	if lplr.Character == nil or lplr.Character:FindFirstChild('HandInvItem') == nil then 
		return 
	end;
	if lplr.Character.HandInvItem.Value ~= tool then
		bedwars.Client:Get(bedwars.EquipItemRemote):CallServerAsync({
			hand = tool
		})
		local started = tick()
		repeat task.wait() until (tick() - started) > 0.3 or lplr.Character.HandInvItem.Value == tool
	end
end;

local getserverhand = function()
	if lplr.Character and lplr.Character:FindFirstChild('HandInvItem') then 
		return getItem(tostring(lplr.Character.HandInvItem.Value));
	end
end;

local function switchToAndUseTool(block, legit)
	local tool = getBestTool(block.Name)
	if tool and (entityLibrary.isAlive and lplr.Character:FindFirstChild('HandInvItem') and lplr.Character.HandInvItem.Value ~= tool.tool) then
		if legit then
			if getHotbarSlot(tool.itemType) then
				bedwars.ClientStoreHandler:dispatch({
					type = 'InventorySelectHotbarSlot',
					slot = getHotbarSlot(tool.itemType)
				})
				vapeEvents.InventoryChanged.Event:Wait()
				updateitem:Fire(inputobj)
				return true
			else
				return false
			end
		end
		switchItem(tool.tool)
	end
end

local function isBlockCovered(pos)
	local coveredsides = 0
	for i, v in (cachedNormalSides) do
		local blockpos = (pos + (Vector3.FromNormalId(v) * 3))
		local block = getPlacedBlock(blockpos)
		if block then
			coveredsides = coveredsides + 1
		end
	end
	return coveredsides == #cachedNormalSides
end

local function GetPlacedBlocksNear(pos, normal)
	local blocks = {}
	local lastfound = nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) and (not blacklistedblocks[extrablock.Name]) then
				table.insert(blocks, extrablock.Name)
			end
			lastfound = extrablock
			if not covered then
				break
			end
		else
			break
		end
	end
	return blocks
end

local function getLastCovered(pos, normal)
	local lastfound, lastpos = nil, nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock, extrablockpos = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			lastfound, lastpos = extrablock, extrablockpos
			if not covered then
				break
			end
		else
			break
		end
	end
	return lastfound, lastpos
end

local function getBestBreakSide(pos)
	local softest, softestside = 9e9, Enum.NormalId.Top
	for i,v in (cachedNormalSides) do
		local sidehardness = 0
		for i2,v2 in (GetPlacedBlocksNear(pos, v)) do
			local blockmeta = bedwars.ItemTable[v2] and bedwars.ItemTable[v2].block;
			sidehardness += blockmeta and blockmeta.health or 10;
			if blockmeta then
				local tool = getBestTool(v2)
				if tool then
					sidehardness = sidehardness - bedwars.ItemTable[tool.itemType].breakBlock[blockmeta.breakType]
				end
			end
		end
		if sidehardness <= softest then
			softest = sidehardness
			softestside = v
		end
	end
	return softestside, softest
end

local function EntityNearPosition(distance, ignore, overridepos)
	local closestEntity, closestMagnitude = nil, distance
	if entityLibrary.isAlive then
		for i, v in (entityLibrary.entityList) do
			if not v.Targetable then continue end
			if isVulnerable(v) then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.RootPart.Position).magnitude
				if overridepos and mag > distance then
					mag = (overridepos - v.RootPart.Position).magnitude
				end
				if mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, mag
				end
			end
		end
		if not ignore then
			for i, v in (collection:GetTagged('Monster')) do
				if v.PrimaryPart and v:GetAttribute('Team') ~= lplr:GetAttribute('Team') then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = v.Name, UserId = (v.Name == 'Duck' and 2020831224 or 1443379645)}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in (collection:GetTagged('DiamondGuardian')) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = 'DiamondGuardian', UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in (collection:GetTagged('GolemBoss')) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = 'GolemBoss', UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in (collection:GetTagged('Drone')) do
				if v.PrimaryPart and tonumber(v:GetAttribute('PlayerUserId')) ~= lplr.UserId then
					local droneplr = players:GetPlayerByUserId(v:GetAttribute('PlayerUserId'))
					if droneplr and droneplr.Team == lplr.Team then continue end
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then -- magcheck
						closestEntity, closestMagnitude = {Player = {Name = 'Drone', UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
		end
	end
	return closestEntity
end

local function EntityNearMouse(distance)
	local closestEntity, closestMagnitude = nil, distance
	if entityLibrary.isAlive then
		local mousepos = inputservice.GetMouseLocation(inputservice)
		for i, v in (entityLibrary.entityList) do
			if not v.Targetable then continue end
			if isVulnerable(v) then
				local vec, vis = worldtoscreenpoint(v.RootPart.Position)
				local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
				if vis and mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, v.Target and -1 or mag
				end
			end
		end
	end
	return closestEntity
end

local function AllNearPosition(distance, amount, sortfunction, prediction)
	local returnedplayer = {}
	local currentamount = 0
	if entityLibrary.isAlive then
		local sortedentities = {}
		for i, v in (entityLibrary.entityList) do
			if not v.Targetable then continue end
			if isVulnerable(v) then
				local playerPosition = v.RootPart.Position
				local mag = (entityLibrary.character.HumanoidRootPart.Position - playerPosition).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - playerPosition).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, v)
				end
			end
		end
		for i, v in (collection:GetTagged('Monster')) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					if v:GetAttribute('Team') == lplr:GetAttribute('Team') then continue end
					table.insert(sortedentities, {Player = {Name = v.Name, UserId = (v.Name == 'Duck' and 2020831224 or 1443379645), GetAttribute = function() return 'none' end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i, v in (collection:GetTagged('DiamondGuardian')) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, {Player = {Name = 'DiamondGuardian', UserId = 1443379645, GetAttribute = function() return 'none' end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i, v in (collection:GetTagged('GolemBoss')) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, {Player = {Name = 'GolemBoss', UserId = 1443379645, GetAttribute = function() return 'none' end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i, v in (collection:GetTagged('Drone')) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					if tonumber(v:GetAttribute('PlayerUserId')) == lplr.UserId then continue end
					local droneplr = players:GetPlayerByUserId(v:GetAttribute('PlayerUserId'))
					if droneplr and droneplr.Team == lplr.Team then continue end
					table.insert(sortedentities, {Player = {Name = 'Drone', UserId = 1443379645}, GetAttribute = function() return 'none' end, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i, v in (store.pots) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, {Player = {Name = 'Pot', UserId = 1443379645, GetAttribute = function() return 'none' end}, Character = v, RootPart = v.PrimaryPart, Humanoid = {Health = 100, MaxHealth = 100}})
				end
			end
		end
		if sortfunction then
			table.sort(sortedentities, sortfunction)
		end
		for i,v in (sortedentities) do
			table.insert(returnedplayer, v)
			currentamount = currentamount + 1
			if currentamount >= amount then break end
		end
	end
	return returnedplayer
end

--pasted from old source since gui code is hard
local function CreateAutoHotbarGUI(children2, argstable)
	local buttonapi = {}
	buttonapi['Hotbars'] = {}
	buttonapi['CurrentlySelected'] = 1
	local currentanim
	local amount = #children2:GetChildren()
	local sortableitems = {
		{itemType = 'swords', itemDisplayType = 'diamond_sword'},
		{itemType = 'pickaxes', itemDisplayType = 'diamond_pickaxe'},
		{itemType = 'axes', itemDisplayType = 'diamond_axe'},
		{itemType = 'shears', itemDisplayType = 'shears'},
		{itemType = 'wool', itemDisplayType = 'wool_white'},
		{itemType = 'iron', itemDisplayType = 'iron'},
		{itemType = 'diamond', itemDisplayType = 'diamond'},
		{itemType = 'emerald', itemDisplayType = 'emerald'},
		{itemType = 'bows', itemDisplayType = 'wood_bow'},
	}
	local items = bedwars.ItemTable
	if items then
		for i2,v2 in (items) do
			if (i2:find('axe') == nil or i2:find('void')) and i2:find('bow') == nil and i2:find('shears') == nil and i2:find('wool') == nil and v2.sword == nil and v2.armor == nil and v2['dontGiveItem'] == nil and bedwars.ItemTable[i2] and bedwars.ItemTable[i2].image then
				table.insert(sortableitems, {itemType = i2, itemDisplayType = i2})
			end
		end
	end
	local buttontext = Instance.new('TextButton')
	buttontext.AutoButtonColor = false
	buttontext.BackgroundTransparency = 1
	buttontext.Name = 'ButtonText'
	buttontext.Text = ''
	buttontext.Name = argstable['Name']
	buttontext.LayoutOrder = 1
	buttontext.Size = UDim2.new(1, 0, 0, 40)
	buttontext.Active = false
	buttontext.TextColor3 = Color3.fromRGB(162, 162, 162)
	buttontext.TextSize = 17
	buttontext.Font = Enum.Font.SourceSans
	buttontext.Position = UDim2.new(0, 0, 0, 0)
	buttontext.Parent = children2
	local toggleframe2 = Instance.new('Frame')
	toggleframe2.Size = UDim2.new(0, 200, 0, 31)
	toggleframe2.Position = UDim2.new(0, 10, 0, 4)
	toggleframe2.BackgroundColor3 = Color3.fromRGB(38, 37, 38)
	toggleframe2.Name = 'ToggleFrame2'
	toggleframe2.Parent = buttontext
	local toggleframe1 = Instance.new('Frame')
	toggleframe1.Size = UDim2.new(0, 198, 0, 29)
	toggleframe1.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	toggleframe1.BorderSizePixel = 0
	toggleframe1.Name = 'ToggleFrame1'
	toggleframe1.Position = UDim2.new(0, 1, 0, 1)
	toggleframe1.Parent = toggleframe2
	local addbutton = Instance.new('ImageLabel')
	addbutton.BackgroundTransparency = 1
	addbutton.Name = 'AddButton'
	addbutton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	addbutton.Position = UDim2.new(0, 93, 0, 9)
	addbutton.Size = UDim2.new(0, 12, 0, 12)
	addbutton.ImageColor3 = Color3.fromRGB(5, 133, 104)
	addbutton.Image = downloadVapeAsset('rendervape/assets/AddItem.png')
	addbutton.Parent = toggleframe1
	local children3 = Instance.new('Frame')
	children3.Name = argstable['Name']..'Children'
	children3.BackgroundTransparency = 1
	children3.LayoutOrder = amount
	children3.Size = UDim2.new(0, 220, 0, 0)
	children3.Parent = children2
	local uilistlayout = Instance.new('UIListLayout')
	uilistlayout.Parent = children3
	uilistlayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		children3.Size = UDim2.new(1, 0, 0, uilistlayout.AbsoluteContentSize.Y)
	end)
	local uicorner = Instance.new('UICorner')
	uicorner.CornerRadius = UDim.new(0, 5)
	uicorner.Parent = toggleframe1
	local uicorner2 = Instance.new('UICorner')
	uicorner2.CornerRadius = UDim.new(0, 5)
	uicorner2.Parent = toggleframe2
	buttontext.MouseEnter:Connect(function()
		tween:Create(toggleframe2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(79, 78, 79)}):Play()
	end)
	buttontext.MouseLeave:Connect(function()
		tween:Create(toggleframe2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(38, 37, 38)}):Play()
	end)
	local ItemListBigFrame = Instance.new('Frame')
	ItemListBigFrame.Size = UDim2.new(1, 0, 1, 0)
	ItemListBigFrame.Name = 'ItemList'
	ItemListBigFrame.BackgroundTransparency = 1
	ItemListBigFrame.Visible = false
	ItemListBigFrame.Parent = vape.MainGui
	local ItemListFrame = Instance.new('Frame')
	ItemListFrame.Size = UDim2.new(0, 660, 0, 445)
	ItemListFrame.Position = UDim2.new(0.5, -330, 0.5, -223)
	ItemListFrame.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	ItemListFrame.Parent = ItemListBigFrame
	local ItemListExitButton = Instance.new('ImageButton')
	ItemListExitButton.Name = 'ItemListExitButton'
	ItemListExitButton.ImageColor3 = Color3.fromRGB(121, 121, 121)
	ItemListExitButton.Size = UDim2.new(0, 24, 0, 24)
	ItemListExitButton.AutoButtonColor = false
	ItemListExitButton.Image = downloadVapeAsset('rendervape/assets/ExitIcon1.png')
	ItemListExitButton.Visible = true
	ItemListExitButton.Position = UDim2.new(1, -31, 0, 8)
	ItemListExitButton.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	ItemListExitButton.Parent = ItemListFrame
	local ItemListExitButtonround = Instance.new('UICorner')
	ItemListExitButtonround.CornerRadius = UDim.new(0, 16)
	ItemListExitButtonround.Parent = ItemListExitButton
	ItemListExitButton.MouseEnter:Connect(function()
		tween:Create(ItemListExitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(60, 60, 60), ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end)
	ItemListExitButton.MouseLeave:Connect(function()
		tween:Create(ItemListExitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(26, 25, 26), ImageColor3 = Color3.fromRGB(121, 121, 121)}):Play()
	end)
	ItemListExitButton.MouseButton1Click:Connect(function()
		ItemListBigFrame.Visible = false
		vape.MainGui.ScaledGui.ClickGui.Visible = true
	end)
	local ItemListFrameShadow = Instance.new('ImageLabel')
	ItemListFrameShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	ItemListFrameShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	ItemListFrameShadow.Image = downloadVapeAsset('rendervape/assets/WindowBlur.png')
	ItemListFrameShadow.BackgroundTransparency = 1
	ItemListFrameShadow.ZIndex = -1
	ItemListFrameShadow.Size = UDim2.new(1, 6, 1, 6)
	ItemListFrameShadow.ImageColor3 = Color3.new(0, 0, 0)
	ItemListFrameShadow.ScaleType = Enum.ScaleType.Slice
	ItemListFrameShadow.SliceCenter = Rect.new(10, 10, 118, 118)
	ItemListFrameShadow.Parent = ItemListFrame
	local ItemListFrameText = Instance.new('TextLabel')
	ItemListFrameText.Size = UDim2.new(1, 0, 0, 41)
	ItemListFrameText.BackgroundTransparency = 1
	ItemListFrameText.Name = 'WindowTitle'
	ItemListFrameText.Position = UDim2.new(0, 0, 0, 0)
	ItemListFrameText.TextXAlignment = Enum.TextXAlignment.Left
	ItemListFrameText.Font = Enum.Font.SourceSans
	ItemListFrameText.TextSize = 17
	ItemListFrameText.Text = '	New AutoHotbar'
	ItemListFrameText.TextColor3 = Color3.fromRGB(201, 201, 201)
	ItemListFrameText.Parent = ItemListFrame
	local ItemListBorder1 = Instance.new('Frame')
	ItemListBorder1.BackgroundColor3 = Color3.fromRGB(40, 39, 40)
	ItemListBorder1.BorderSizePixel = 0
	ItemListBorder1.Size = UDim2.new(1, 0, 0, 1)
	ItemListBorder1.Position = UDim2.new(0, 0, 0, 41)
	ItemListBorder1.Parent = ItemListFrame
	local ItemListFrameCorner = Instance.new('UICorner')
	ItemListFrameCorner.CornerRadius = UDim.new(0, 4)
	ItemListFrameCorner.Parent = ItemListFrame
	local ItemListFrame1 = Instance.new('Frame')
	ItemListFrame1.Size = UDim2.new(0, 112, 0, 113)
	ItemListFrame1.Position = UDim2.new(0, 10, 0, 71)
	ItemListFrame1.BackgroundColor3 = Color3.fromRGB(38, 37, 38)
	ItemListFrame1.Name = 'ItemListFrame1'
	ItemListFrame1.Parent = ItemListFrame
	local ItemListFrame2 = Instance.new('Frame')
	ItemListFrame2.Size = UDim2.new(0, 110, 0, 111)
	ItemListFrame2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ItemListFrame2.BorderSizePixel = 0
	ItemListFrame2.Name = 'ItemListFrame2'
	ItemListFrame2.Position = UDim2.new(0, 1, 0, 1)
	ItemListFrame2.Parent = ItemListFrame1
	local ItemListFramePicker = Instance.new('ScrollingFrame')
	ItemListFramePicker.Size = UDim2.new(0, 495, 0, 220)
	ItemListFramePicker.Position = UDim2.new(0, 144, 0, 122)
	ItemListFramePicker.BorderSizePixel = 0
	ItemListFramePicker.ScrollBarThickness = 3
	ItemListFramePicker.ScrollBarImageTransparency = 0.8
	ItemListFramePicker.VerticalScrollBarInset = Enum.ScrollBarInset.None
	ItemListFramePicker.BackgroundTransparency = 1
	ItemListFramePicker.Parent = ItemListFrame
	local ItemListFramePickerGrid = Instance.new('UIGridLayout')
	ItemListFramePickerGrid.CellPadding = UDim2.new(0, 4, 0, 3)
	ItemListFramePickerGrid.CellSize = UDim2.new(0, 51, 0, 52)
	ItemListFramePickerGrid.Parent = ItemListFramePicker
	ItemListFramePickerGrid:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		ItemListFramePicker.CanvasSize = UDim2.new(0, 0, 0, ItemListFramePickerGrid.AbsoluteContentSize.Y * (1 / vape['MainRescale'].Scale))
	end)
	local ItemListcorner = Instance.new('UICorner')
	ItemListcorner.CornerRadius = UDim.new(0, 5)
	ItemListcorner.Parent = ItemListFrame1
	local ItemListcorner2 = Instance.new('UICorner')
	ItemListcorner2.CornerRadius = UDim.new(0, 5)
	ItemListcorner2.Parent = ItemListFrame2
	local selectedslot = 1
	local hoveredslot = 0

	local refreshslots
	local refreshList
	refreshslots = function()
		local startnum = 144
		local oldhovered = hoveredslot
		for i2,v2 in (ItemListFrame:GetChildren()) do
			if v2.Name:find('ItemSlot') then
				v2:Remove()
			end
		end
		for i3,v3 in (ItemListFramePicker:GetChildren()) do
			if v3:IsA('TextButton') then
				v3:Remove()
			end
		end
		for i4,v4 in (sortableitems) do
			local ItemFrame = Instance.new('TextButton')
			ItemFrame.Text = ''
			ItemFrame.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
			ItemFrame.Parent = ItemListFramePicker
			ItemFrame.AutoButtonColor = false
			local ItemFrameIcon = Instance.new('ImageLabel')
			ItemFrameIcon.Size = UDim2.new(0, 32, 0, 32)
			ItemFrameIcon.Image = bedwars.getIcon({itemType = v4.itemDisplayType}, true)
			ItemFrameIcon.ResampleMode = (bedwars.getIcon({itemType = v4.itemDisplayType}, true):find('rbxasset://') and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			ItemFrameIcon.Position = UDim2.new(0, 10, 0, 10)
			ItemFrameIcon.BackgroundTransparency = 1
			ItemFrameIcon.Parent = ItemFrame
			local ItemFramecorner = Instance.new('UICorner')
			ItemFramecorner.CornerRadius = UDim.new(0, 5)
			ItemFramecorner.Parent = ItemFrame
			ItemFrame.MouseButton1Click:Connect(function()
				for i5,v5 in (buttonapi['Hotbars'][buttonapi['CurrentlySelected']]['Items']) do
					if v5.itemType == v4.itemType then
						buttonapi['Hotbars'][buttonapi['CurrentlySelected']]['Items'][tostring(i5)] = nil
					end
				end
				buttonapi['Hotbars'][buttonapi['CurrentlySelected']]['Items'][tostring(selectedslot)] = v4
				refreshslots()
				refreshList()
			end)
		end
		for i = 1, 9 do
			local item = buttonapi['Hotbars'][buttonapi['CurrentlySelected']]['Items'][tostring(i)]
			local ItemListFrame3 = Instance.new('Frame')
			ItemListFrame3.Size = UDim2.new(0, 55, 0, 56)
			ItemListFrame3.Position = UDim2.new(0, startnum - 2, 0, 380)
			ItemListFrame3.BackgroundTransparency = (selectedslot == i and 0 or 1)
			ItemListFrame3.BackgroundColor3 = Color3.fromRGB(35, 34, 35)
			ItemListFrame3.Name = 'ItemSlot'
			ItemListFrame3.Parent = ItemListFrame
			local ItemListFrame4 = Instance.new('TextButton')
			ItemListFrame4.Size = UDim2.new(0, 51, 0, 52)
			ItemListFrame4.BackgroundColor3 = (oldhovered == i and Color3.fromRGB(31, 30, 31) or Color3.fromRGB(20, 20, 20))
			ItemListFrame4.BorderSizePixel = 0
			ItemListFrame4.AutoButtonColor = false
			ItemListFrame4.Text = ''
			ItemListFrame4.Name = 'ItemListFrame4'
			ItemListFrame4.Position = UDim2.new(0, 2, 0, 2)
			ItemListFrame4.Parent = ItemListFrame3
			local ItemListImage = Instance.new('ImageLabel')
			ItemListImage.Size = UDim2.new(0, 32, 0, 32)
			ItemListImage.BackgroundTransparency = 1
			local img = (item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or '')
			ItemListImage.Image = img
			ItemListImage.ResampleMode = (img:find('rbxasset://') and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			ItemListImage.Position = UDim2.new(0, 10, 0, 10)
			ItemListImage.Parent = ItemListFrame4
			local ItemListcorner3 = Instance.new('UICorner')
			ItemListcorner3.CornerRadius = UDim.new(0, 5)
			ItemListcorner3.Parent = ItemListFrame3
			local ItemListcorner4 = Instance.new('UICorner')
			ItemListcorner4.CornerRadius = UDim.new(0, 5)
			ItemListcorner4.Parent = ItemListFrame4
			ItemListFrame4.MouseEnter:Connect(function()
				ItemListFrame4.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
				hoveredslot = i
			end)
			ItemListFrame4.MouseLeave:Connect(function()
				ItemListFrame4.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				hoveredslot = 0
			end)
			ItemListFrame4.MouseButton1Click:Connect(function()
				selectedslot = i
				refreshslots()
			end)
			ItemListFrame4.MouseButton2Click:Connect(function()
				buttonapi['Hotbars'][buttonapi['CurrentlySelected']]['Items'][tostring(i)] = nil
				refreshslots()
				refreshList()
			end)
			startnum = startnum + 55
		end
	end

	local function createHotbarButton(num, items)
		num = tonumber(num) or #buttonapi['Hotbars'] + 1
		local hotbarbutton = Instance.new('TextButton')
		hotbarbutton.Size = UDim2.new(1, 0, 0, 30)
		hotbarbutton.BackgroundTransparency = 1
		hotbarbutton.LayoutOrder = num
		hotbarbutton.AutoButtonColor = false
		hotbarbutton.Text = ''
		hotbarbutton.Parent = children3
		buttonapi['Hotbars'][num] = {['Items'] = items or {}, Object = hotbarbutton, ['Number'] = num}
		local hotbarframe = Instance.new('Frame')
		hotbarframe.BackgroundColor3 = (num == buttonapi['CurrentlySelected'] and Color3.fromRGB(54, 53, 54) or Color3.fromRGB(31, 30, 31))
		hotbarframe.Size = UDim2.new(0, 200, 0, 27)
		hotbarframe.Position = UDim2.new(0, 10, 0, 1)
		hotbarframe.Parent = hotbarbutton
		local uicorner3 = Instance.new('UICorner')
		uicorner3.CornerRadius = UDim.new(0, 5)
		uicorner3.Parent = hotbarframe
		local startpos = 11
		for i = 1, 9 do
			local item = buttonapi['Hotbars'][num]['Items'][tostring(i)]
			local hotbarbox = Instance.new('ImageLabel')
			hotbarbox.Name = i
			hotbarbox.Size = UDim2.new(0, 17, 0, 18)
			hotbarbox.Position = UDim2.new(0, startpos, 0, 5)
			hotbarbox.BorderSizePixel = 0
			hotbarbox.Image = (item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or '')
			hotbarbox.ResampleMode = ((item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or ''):find('rbxasset://') and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			hotbarbox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			hotbarbox.Parent = hotbarframe
			startpos = startpos + 18
		end
		hotbarbutton.MouseButton1Click:Connect(function()
			if buttonapi['CurrentlySelected'] == num then
				ItemListBigFrame.Visible = true
				vape.MainGui.ScaledGui.ClickGui.Visible = false
				refreshslots()
			end
			buttonapi['CurrentlySelected'] = num
			refreshList()
		end)
		hotbarbutton.MouseButton2Click:Connect(function()
			if buttonapi['CurrentlySelected'] == num then
				buttonapi['CurrentlySelected'] = (num == 2 and 0 or 1)
			end
			table.remove(buttonapi['Hotbars'], num)
			refreshList()
		end)
	end

	refreshList = function()
		local newnum = 0
		local newtab = {}
		for i3,v3 in (buttonapi['Hotbars']) do
			newnum = newnum + 1
			newtab[newnum] = v3
		end
		buttonapi['Hotbars'] = newtab
		for i,v in (children3:GetChildren()) do
			if v:IsA('TextButton') then
				v:Remove()
			end
		end
		for i2,v2 in (buttonapi['Hotbars']) do
			createHotbarButton(i2, v2['Items'])
		end
		vape['Settings'][children2.Name..argstable['Name']..'ItemList'] = {['Type'] = 'ItemList', ['Items'] = buttonapi['Hotbars'], ['CurrentlySelected'] = buttonapi['CurrentlySelected']}
	end
	buttonapi['RefreshList'] = refreshList

	buttontext.MouseButton1Click:Connect(function()
		createHotbarButton()
	end)

	vape['Settings'][children2.Name..argstable['Name']..'ItemList'] = {['Type'] = 'ItemList', ['Items'] = buttonapi['Hotbars'], ['CurrentlySelected'] = buttonapi['CurrentlySelected']}
	vape.ObjectsThatCanBeSaved[children2.Name..argstable['Name']..'ItemList'] = {['Type'] = 'ItemList', ['Items'] = buttonapi['Hotbars'], ['Api'] = buttonapi, Object = buttontext}

	return buttonapi
end

vape.LoadSettingsEvent.Event:Connect(function(res)
	for i,v in (res) do
		local obj = vape.ObjectsThatCanBeSaved[i]
		if obj and v.Type == 'ItemList' and obj.Api then
			obj.Api.Hotbars = v.Items
			obj.Api.CurrentlySelected = v.CurrentlySelected
			obj.Api.RefreshList()
		end
	end
end)

run(function()
	local function isWhitelistedBed(bed)
		if bed and bed.Name == 'bed' then
			for i, v in (players:GetPlayers()) do
				if bed:GetAttribute('Team'..(v:GetAttribute('Team') or 0)..'NoBreak') and not ({whitelist:get(v)})[2] then
					return true
				end
			end
		end
		return false
	end

	local function dumpRemote(tab)
		for i,v in (tab) do
			if v == 'Client' then
				return tab[i + 1]
			end
		end
		return ''
	end

	local KnitGotten, KnitClient
	local cheatenginetrash; loadcheatenginemodule = function()
		local successful, result = pcall(function() return loadfile('rendervape/libraries/guardianrewrite.lua')() end);
		if typeof(result) ~= 'table' then 
			task.spawn(error, `❌ Failed to load cheat engine module, very likely a {identifyexecutor and identifyexecutor() or 'shit executor'} issue --> {result}`)
			return task.wait(9e9)
		end;
		return result
	end

	repeat task.wait() until lplr.PlayerScripts:FindFirstChild('TS') and lplr.PlayerScripts.TS:FindFirstChild('knit')

	getgenv().bedwarsStore = store;

	for i = 1, 5 do 
		KnitGotten, KnitClient = pcall(function()
			return debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
		end);
		if KnitClient then 
			break;
		else
			task.wait(0.8)
		end
	end;

	if not KnitGotten then 
		cheatenginetrash = true;
		getgenv().cheatenginetrash = true 
	end;

	if cheatenginetrash then 
		isnetworkowner = function(): (boolean)
			return true;
		end;
	end;

	local Flamework = ({pcall(function() return require(replicatedstorage['rbxts_include']['node_modules']['@flamework'].core.out).Flamework end)})[2]
	local Client = ({pcall(function() return require(replicatedstorage.TS.remotes).default.Client end)})[2]
	local InventoryUtil = ({pcall(function() return require(replicatedstorage.TS.inventory['inventory-util']).InventoryUtil end)})[2]
	local OldGet = ({pcall(function() return getmetatable(Client).Get end)})[2]
	local OldBreak

    pcall(function()
        repeat task.wait() until Flamework.isInitialized;
    end);

	bedwars = (cheatenginetrash and loadcheatenginemodule() or setmetatable({
		AnimationType = require(replicatedstorage.TS.animation['animation-type']).AnimationType,
		AnimationUtil = require(replicatedstorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out['shared'].util['animation-util']).AnimationUtil,
		AppController = require(replicatedstorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out.client.controllers['app-controller']).AppController,
		AbilityController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController'),
		AbilityUIController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/ability/ability-ui-controller@AbilityUIController'),
		AttackRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.SwordController.sendServerRequest)),
		BalanceFile = require(replicatedstorage.TS.balance['balance-file']).BalanceFile,
		BatteryRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.BatteryController.KnitStart, 1), 1))),
		BlockBreaker = KnitClient.Controllers.BlockBreakController.blockBreaker,
		BlockController = require(replicatedstorage['rbxts_include']['node_modules']['@easy-games']['block-engine'].out).BlockEngine,
		BlockPlacer = require(replicatedstorage['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.client.placement['block-placer']).BlockPlacer,
		BlockEngine = require(lplr.PlayerScripts.TS.lib['block-engine']['client-block-engine']).ClientBlockEngine,
		BlockEngineClientEvents = require(replicatedstorage['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.client['block-engine-client-events']).BlockEngineClientEvents,
		BowConstantsTable = debug.getupvalue(KnitClient.Controllers.ProjectileController.enableBeam, 6),
		CannonAimRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.CannonController.startAiming, 5))),
		CannonLaunchRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.CannonHandController.launchSelf)),
		ClickHold = require(replicatedstorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out.client.ui.lib.util['click-hold']).ClickHold,
		Client = Client,
		ClientConstructor = require(replicatedstorage['rbxts_include']['node_modules']['@rbxts'].net.out.client),
		ClientDamageBlock = require(replicatedstorage['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.shared.remotes).BlockEngineRemotes.Client,
		ClientStoreHandler = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
		CombatConstant = require(replicatedstorage.TS.combat['combat-constant']).CombatConstant,
		ConstantManager = require(replicatedstorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out['shared'].constant['constant-manager']).ConstantManager,
		ConsumeSoulRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.GrimReaperController.consumeSoul)),
		CooldownController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/cooldown/cooldown-controller@CooldownController'),
		DamageIndicator = KnitClient.Controllers.DamageIndicatorController.spawnDamageIndicator,
		DefaultKillEffect = require(lplr.PlayerScripts.TS.controllers.game.locker['kill-effect'].effects['default-kill-effect']),
		DropItem = KnitClient.Controllers.ItemDropController.dropItemInHand,
		DropItemRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.ItemDropController.dropItemInHand)),
		DragonRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.DragonSlayerController.KnitStart, 2), 1))),
		EatRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.ConsumeController.onEnable, 1))),
		EquipItemRemote = dumpRemote(debug.getconstants(debug.getproto(require(replicatedstorage.TS.entity.entities['inventory-entity']).InventoryEntity.equipItem, 3))),
		EmoteMeta = require(replicatedstorage.TS.locker.emote['emote-meta']).EmoteMeta,
		ForgeConstants = debug.getupvalue(KnitClient.Controllers.ForgeController.getPurchaseableForgeUpgrades, 2),
		ForgeUtil = debug.getupvalue(KnitClient.Controllers.ForgeController.getPurchaseableForgeUpgrades, 5),
		GameAnimationUtil = require(replicatedstorage.TS.animation['animation-util']).GameAnimationUtil,
		EntityUtil = require(replicatedstorage.TS.entity['entity-util']).EntityUtil,
		getIcon = function(item, showinv)
			local itemmeta = bedwars.ItemTable[item.itemType]
			if itemmeta and showinv then
				return itemmeta.image or ''
			end
			return ''
		end,
		getInventory = function(plr)
			local suc, result = pcall(function()
				return InventoryUtil.getInventory(plr)
			end)
			return (suc and result or {
				items = {},
				armor = {},
				hand = nil
			})
		end,
		GuitarHealRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.GuitarController.performHeal)),
		ItemTable = debug.getupvalue(require(replicatedstorage.TS.item['item-meta']).getItemMeta, 1),
		KillEffectMeta = require(replicatedstorage.TS.locker['kill-effect']['kill-effect-meta']).KillEffectMeta,
		KnockbackUtil = require(replicatedstorage.TS.damage['knockback-util']).KnockbackUtil,
		MatchEndScreenController = Flamework.resolveDependency('client/controllers/game/match/match-end-screen-controller@MatchEndScreenController'),
		MageRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.MageController.registerTomeInteraction, 1))),
		MageKitUtil = require(replicatedstorage.TS.games.bedwars.kit.kits.mage['mage-kit-util']).MageKitUtil,
		NotificationController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/notification-controller@NotificationController');
		PickupMetalRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.MetalDetectorController.KnitStart, 1), 2))),
		PickupRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.ItemDropController.checkForPickup)),
		PermissionController = KnitClient.Controllers.PermissionController,
		PinataRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.PiggyBankController.KnitStart, 2), 5))),
		ProjectileMeta = require(replicatedstorage.TS.projectile['projectile-meta']).ProjectileMeta,
		ProjectileRemote = dumpRemote(debug.getconstants(debug.getupvalue(KnitClient.Controllers.ProjectileController.launchProjectileWithValues, 2))),
		QueryUtil = require(replicatedstorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out).GameQueryUtil,
		QueueController = Flamework.resolveDependency('@easy-games/lobby:client/controllers/lobby-queue-controller@LobbyQueueController'),
		QueueCard = require(lplr.PlayerScripts.TS.controllers.global.queue.ui['queue-card']).QueueCard,
		QueueMeta = require(replicatedstorage.TS.game['queue-meta']).QueueMeta,
		ReportRemote = dumpRemote(debug.getconstants(require(lplr.PlayerScripts.TS.controllers.global.report['report-controller']).default.reportPlayer)),
		ResetRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.ResetController.createBindable, 1))),
		Roact = require(replicatedstorage['rbxts_include']['node_modules']['@rbxts']['roact'].src),
		RuntimeLib = require(replicatedstorage['rbxts_include'].RuntimeLib),
		Shop = require(replicatedstorage.TS.games.bedwars.shop['bedwars-shop']).BedwarsShop,
		ShopItems = debug.getupvalue(debug.getupvalue(require(replicatedstorage.TS.games.bedwars.shop['bedwars-shop']).BedwarsShop.getShopItem, 1), 3),
		SoundList = require(replicatedstorage.TS.sound['game-sound']).GameSound,
		SoundManager = require(replicatedstorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out).SoundManager,
		SpawnRavenRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.RavenController.spawnRaven)),
		TreeRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.BigmanController.KnitStart, 1), 2))),
		TrinityRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.AngelController.onKitEnabled, 1))),
		UILayers = require(replicatedstorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out).UILayers,
		WeldTable = require(replicatedstorage.TS.util['weld-util']).WeldUtil
	}, {
		__index = function(self, ind)
			rawset(self, ind, KnitClient.Controllers[ind])
			return rawget(self, ind)
		end
	}))

	getgenv().bedwars = bedwars; 

	OldBreak = bedwars.BlockController.isBlockBreakable


	pcall(function()
		getmetatable(Client).Get = function(self, remoteName)
			if not vapeInjected then return OldGet(self, remoteName) end
			local originalRemote = OldGet(self, remoteName)
			if remoteName == bedwars.AttackRemote then
				return {
					instance = originalRemote.instance,
					SendToServer = function(self, attackTable, ...)
						local suc, plr = pcall(function() return players:GetPlayerFromCharacter(attackTable.entityInstance) end)
						if suc and plr then
							if not ({whitelist:get(plr)})[2] then return end
							if Reach.Enabled then
								local attackMagnitude = ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - attackTable.validate.targetPosition.value).magnitude
								if attackMagnitude > 18 then
									return nil
								end
								attackTable.validate.selfPosition = attackValue(attackTable.validate.selfPosition.value + (attackMagnitude > 14.4 and (CFrame.lookAt(attackTable.validate.selfPosition.value, attackTable.validate.targetPosition.value).lookVector * 4) or Vector3.zero))
							end
							store.attackReach = math.floor((attackTable.validate.selfPosition.value - attackTable.validate.targetPosition.value).magnitude * 100) / 100
							store.attackReachUpdate = tick() + 1
						end
						return originalRemote:SendToServer(attackTable, ...)
					end
				}
			end
			return originalRemote
		end
	end)

	bedwars.BlockController.isBlockBreakable = function(self, breakTable, plr)
		local obj = bedwars.BlockController:getStore():getBlockAt(breakTable.blockPosition)
		if isWhitelistedBed(obj) then return false end
		return OldBreak(self, breakTable, plr)
	end

	store.blockPlacer = bedwars.BlockPlacer.new(bedwars.BlockEngine, 'wool_white')
	bedwars.placeBlock = function(speedCFrame, customblock)
		if getItem(customblock) then
			store.blockPlacer.blockType = customblock
			return store.blockPlacer:placeBlock(Vector3.new(speedCFrame.X / 3, speedCFrame.Y / 3, speedCFrame.Z / 3))
		end
	end

	local healthbarblocktable = {
		blockHealth = -1,
		breakingBlockPosition = Vector3.zero
	}

	local failedBreak = 0
	bedwars.breakBlock = function(pos, effects, normal, bypass, anim)
		if lplr:GetAttribute('DenyBlockBreak') then
			return
		end
		local block, blockpos = nil, nil
		if not bypass then block, blockpos = getLastCovered(pos, normal) end
		if not block then block, blockpos = getPlacedBlock(pos) end
		if blockpos and block then
			local blockhealthbarpos = {blockPosition = Vector3.zero}
			local blockdmg = 0
			if block and block.Parent and block.Parent.ClassName == 'Part' and cheatenginetrash then 
				block = block.Parent;
			end;
			if block and block.Parent ~= nil then
				store.blockPlace = tick() + 0.1
				pcall(switchToAndUseTool, block)
				blockhealthbarpos = {
					blockPosition = blockpos
				}
				task.spawn(function()
					bedwars.ClientDamageBlock:Get('DamageBlock'):CallServerAsync({
						blockRef = blockhealthbarpos,
						hitPosition = blockpos * 3,
						hitNormal = Vector3.FromNormalId(normal)
					}):andThen(function(result)
						if result ~= 'failed' then
							failedBreak = 0
							if healthbarblocktable.blockHealth == -1 or blockhealthbarpos.blockPosition ~= healthbarblocktable.breakingBlockPosition then
								local blockdata = bedwars.BlockController:getStore():getBlockData(blockhealthbarpos.blockPosition)
								local blockhealth = blockdata and (blockdata:GetAttribute('Health') or blockdata:GetAttribute('1') or blockdata:GetAttribute(lplr.Name .. '_Health')) or block:GetAttribute('Health') or block:GetAttribute('1');
								healthbarblocktable.blockHealth = blockhealth
								healthbarblocktable.breakingBlockPosition = blockhealthbarpos.blockPosition
							end
							healthbarblocktable.blockHealth = result == 'destroyed' and 0 or healthbarblocktable.blockHealth
							blockdmg = bedwars.BlockController:calculateBlockDamage(lplr, blockhealthbarpos)
							healthbarblocktable.blockHealth = math.max(healthbarblocktable.blockHealth - blockdmg, 0)
							if effects then
								bedwars.BlockBreaker:updateHealthbar(blockhealthbarpos, healthbarblocktable.blockHealth, block:GetAttribute('MaxHealth'), blockdmg, block)
								if healthbarblocktable.blockHealth <= 0 then
									bedwars.BlockBreaker.breakEffect:playBreak(block.Name, blockhealthbarpos.blockPosition, lplr)
									bedwars.BlockBreaker.healthbarMaid:DoCleaning()
									healthbarblocktable.breakingBlockPosition = Vector3.zero
								else
									bedwars.BlockBreaker.breakEffect:playHit(block.Name, blockhealthbarpos.blockPosition, lplr)
								end
							end
							local animation
							if anim then
								animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(1))
								bedwars.ViewmodelController:playAnimation(15)
							end
							task.wait(0.3)
							if animation ~= nil then
								animation:Stop()
								animation:Destroy()
							end
						else
							failedBreak = failedBreak + 1
						end
					end)
				end)
				task.wait(physicsUpdate)
			end
		end
	end

	local oldgamestore
	local function updateStore(newStore, oldStore)
		if newStore.Game ~= oldStore.Game then
			store.matchState = newStore.Game.matchState
			store.queueType = newStore.Game.queueType or 'bedwars_test'
			store.forgeMasteryPoints = newStore.Game.forgeMasteryPoints
			store.forgeUpgrades = newStore.Game.forgeUpgrades
		end
		if newStore.Bedwars ~= oldStore.Bedwars then
			store.equippedKit = newStore.Bedwars.kit ~= 'none' and newStore.Bedwars.kit or ''
		end
		if newStore.Inventory ~= oldStore.Inventory then
			local newInventory = (newStore.Inventory and newStore.Inventory.observedInventory or {inventory = {}})
			local oldInventory = (oldStore.Inventory and oldStore.Inventory.observedInventory or {inventory = {}})
			store.localInventory = newStore.Inventory.observedInventory
			if newInventory ~= oldInventory then
				vapeEvents.InventoryChanged:Fire()
			end
			if newInventory.inventory.items ~= oldInventory.inventory.items then
				vapeEvents.InventoryAmountChanged:Fire()
			end
			if newInventory.inventory.hand ~= oldInventory.inventory.hand then
				local currentHand = newStore.Inventory.observedInventory.inventory.hand
				local handType = ''
				if currentHand then
					local handData = bedwars.ItemTable[currentHand.itemType]
					handType = handData.sword and 'sword' or handData.block and 'block' or currentHand.itemType:find('bow') and 'bow'
				end
				store.localHand = {tool = currentHand and currentHand.tool, Type = handType, amount = currentHand and currentHand.amount or 0}
			end
		end
	end

	store.blocks = Performance.new(setmetatable({
        jobdelay = 5, 
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
	}));

	store.blocks.oncleanevent:Connect(function()	
		store.raycast.FilterDescendantsInstances = {store.blocks:getplainarray()};
	end);

	for i: number, v: Part? in collection:GetTagged('block') do 
		table.insert(store.blocks, v)
	end;

    store.blocks:setcleanermode(2);
	store.raycast.FilterDescendantsInstances = {store.blocks:getplainarray()};

	table.insert(vapeConnections, collection:GetInstanceAddedSignal('block'):Connect(function(block)
		table.insert(store.blocks, block)
		store.raycast.FilterDescendantsInstances = {store.blocks:getplainarray()}
	end))
	table.insert(vapeConnections, collection:GetInstanceRemovedSignal('block'):Connect(function(block)
		block = table.find(store.blocks, block)
		if block then
			table.remove(store.blocks, block)
			store.raycast.FilterDescendantsInstances = {store.blocks:getplainarray()}
		end
	end))
	for _, ent in (collection:GetTagged('entity')) do
		if ent.Name == 'DesertPotEntity' then
			table.insert(store.pots, ent)
		end
	end
	table.insert(vapeConnections, collection:GetInstanceAddedSignal('entity'):Connect(function(ent)
		if ent.Name == 'DesertPotEntity' then
			table.insert(store.pots, ent)
		end
	end))
	table.insert(vapeConnections, collection:GetInstanceRemovedSignal('entity'):Connect(function(ent)
		ent = table.find(store.pots, ent)
		if ent then
			table.remove(store.pots, ent)
		end
	end))

	if cheatenginetrash then 
		updateStore(bedwars.updateGameStore(lplr.Character), bedwars.updateGameStore(lplr.Character))
	else
		updateStore(bedwars.ClientStoreHandler:getState(), {})
	end
	
	table.insert(vapeConnections, bedwars.ClientStoreHandler.changed:connect(updateStore))

	for i, v in ({'MatchEndEvent', 'EntityDeathEvent', 'EntityDamageEvent', 'BedwarsBedBreak', 'BalloonPopped', 'AngelProgress', 'ActivateBeast'}) do
		bedwars.Client:WaitFor(v):andThen(function(connection)
			table.insert(vapeConnections, connection:Connect(function(...)
				vapeEvents[v]:Fire(...)
			end))
		end)
	end
	for i, v in ({'PlaceBlockEvent', 'BreakBlockEvent'}) do
		bedwars.ClientDamageBlock:WaitFor(v):andThen(function(connection)
			table.insert(vapeConnections, connection:Connect(function(...)
				vapeEvents[v]:Fire(...)
			end))
		end)
	end

	local oldZephyrUpdate = bedwars.WindWalkerController.updateJump
	bedwars.WindWalkerController.updateJump = function(self, orb, ...)
		store.zephyrOrb = lplr.Character and lplr.Character:GetAttribute('Health') > 0 and orb or 0
		return oldZephyrUpdate(self, orb, ...)
	end

	vape.SelfDestructEvent.Event:Once(function()
		bedwars.WindWalkerController.updateJump = oldZephyrUpdate
		--getmetatable(bedwars.Client).Get = OldGet
		bedwars.BlockController.isBlockBreakable = OldBreak
		store.blockPlacer:disable()
	end)

	local teleportedServers = false
	table.insert(vapeConnections, lplr.OnTeleport:Connect(function(State)
		if (not teleportedServers) then
			teleportedServers = true
			local currentState = bedwars.ClientStoreHandler and bedwars.ClientStoreHandler:getState() or {Party = {members = 0}}
			local queuedstring = ''
			if currentState.Party and currentState.Party.members and #currentState.Party.members > 0 then
				queuedstring = queuedstring..'shared.vapeteammembers = '..#currentState.Party.members..'\n'
			end
			if store.TPString then
				queuedstring = queuedstring..'shared.vapeoverlay = "'..store.TPString..'"\n'
			end
			queueonteleport(queuedstring)
		end
	end))
end)

do
	entityLibrary.animationCache = {}
	entityLibrary.groundTick = tick()
	entityLibrary.selfDestruct()
	entityLibrary.isPlayerTargetable = function(plr)
		return lplr:GetAttribute('Team') ~= plr:GetAttribute('Team') and not isFriend(plr) and ({whitelist:get(plr)})[2]
	end
	entityLibrary.characterAdded = function(plr, char, localcheck)
		local id = getservice('HttpService'):GenerateGUID(true)
		entityLibrary.entityIds[plr.Name] = id
		if char then
			task.spawn(function()
				local humrootpart = char:WaitForChild('HumanoidRootPart', 10)
				local head = char:WaitForChild('Head', 10)
				local hum = char:WaitForChild('Humanoid', 10)
				if entityLibrary.entityIds[plr.Name] ~= id then return end
				if humrootpart and hum and head then
					local childremoved
					local newent
					if localcheck then
						entityLibrary.isAlive = true
						entityLibrary.character.Head = head
						entityLibrary.character.Humanoid = hum
						entityLibrary.character.HumanoidRootPart = humrootpart
						table.insert(entityLibrary.entityConnections, char.AttributeChanged:Connect(function(...)
							vapeEvents.AttributeChanged:Fire(...)
						end))
					else
						newent = {
							Player = plr,
							Character = char,
							HumanoidRootPart = humrootpart,
							RootPart = humrootpart,
							Head = head,
							Humanoid = hum,
							Targetable = entityLibrary.isPlayerTargetable(plr),
							Team = plr.Team,
							Connections = {},
							Jumping = false,
							Jumps = 0,
							JumpTick = tick()
						}
						local inv = char:WaitForChild('InventoryFolder', 5)
						if inv then
							local armorobj1 = char:WaitForChild('ArmorInvItem_0', 5)
							local armorobj2 = char:WaitForChild('ArmorInvItem_1', 5)
							local armorobj3 = char:WaitForChild('ArmorInvItem_2', 5)
							local handobj = char:WaitForChild('HandInvItem', 5)
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							if armorobj1 then
								table.insert(newent.Connections, armorobj1.Changed:Connect(function()
									task.delay(0.3, function()
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										store.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if armorobj2 then
								table.insert(newent.Connections, armorobj2.Changed:Connect(function()
									task.delay(0.3, function()
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										store.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if armorobj3 then
								table.insert(newent.Connections, armorobj3.Changed:Connect(function()
									task.delay(0.3, function()
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										store.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if handobj then
								table.insert(newent.Connections, handobj.Changed:Connect(function()
									task.delay(0.3, function()
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										store.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
						end
						if entityLibrary.entityIds[plr.Name] ~= id then return end
						task.delay(0.3, function()
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							store.inventories[plr] = bedwars.getInventory(plr)
							entityLibrary.entityUpdatedEvent:Fire(newent)
						end)
						table.insert(newent.Connections, hum:GetPropertyChangedSignal('Health'):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum:GetPropertyChangedSignal('MaxHealth'):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum.AnimationPlayed:Connect(function(state)
							local animnum = tonumber(({state.Animation.AnimationId:gsub('%D+', '')})[1])
							if animnum then
								if not entityLibrary.animationCache[state.Animation.AnimationId] then
									pcall(function() entityLibrary.animationCache[state.Animation.AnimationId] = getservice('MarketplaceService'):GetProductInfo(animnum) end)
								end
								if entityLibrary.animationCache[state.Animation.AnimationId] and entityLibrary.animationCache[state.Animation.AnimationId].Name:lower():find('jump') then
									newent.Jumps = newent.Jumps + 1
								end
							end
						end))
						table.insert(newent.Connections, char.AttributeChanged:Connect(function(attr) if attr:find('Shield') then entityLibrary.entityUpdatedEvent:Fire(newent) end end))
						table.insert(entityLibrary.entityList, newent)
						entityLibrary.entityAddedEvent:Fire(newent)
					end
					if entityLibrary.entityIds[plr.Name] ~= id then return end
					childremoved = char.ChildRemoved:Connect(function(part)
						if part.Name == 'HumanoidRootPart' or part.Name == 'Head' or part.Name == 'Humanoid' then
							if localcheck then
								if char == lplr.Character then
									if part.Name == 'HumanoidRootPart' then
										entityLibrary.isAlive = false
										local root = char:FindFirstChild('HumanoidRootPart')
										if not root then
											root = char:WaitForChild('HumanoidRootPart', 3)
										end
										if root then
											entityLibrary.character.HumanoidRootPart = root
											entityLibrary.isAlive = true
										end
									else
										entityLibrary.isAlive = false
									end
								end
							else
								childremoved:Disconnect()
								entityLibrary.removeEntity(plr)
							end
						end
					end)
					if newent then
						table.insert(newent.Connections, childremoved)
					end
					table.insert(entityLibrary.entityConnections, childremoved)
				end
			end)
		end
	end
	entityLibrary.entityAdded = function(plr, localcheck, custom)
		table.insert(entityLibrary.entityConnections, plr:GetPropertyChangedSignal('Character'):Connect(function()
			if plr.Character then
				entityLibrary.refreshEntity(plr, localcheck)
			else
				if localcheck then
					entityLibrary.isAlive = false
				else
					entityLibrary.removeEntity(plr)
				end
			end
		end))
		table.insert(entityLibrary.entityConnections, plr:GetAttributeChangedSignal('Team'):Connect(function()
			local tab = {}
			for i,v in entityLibrary.entityList do
				if v.Targetable ~= entityLibrary.isPlayerTargetable(v.Player) then
					table.insert(tab, v)
				end
			end
			for i,v in tab do
				entityLibrary.refreshEntity(v.Player)
			end
			if localcheck then
				entityLibrary.fullEntityRefresh()
			else
				entityLibrary.refreshEntity(plr, localcheck)
			end
		end))
		if plr.Character then
			task.spawn(entityLibrary.refreshEntity, plr, localcheck)
		end
	end
	entityLibrary.fullEntityRefresh()
	task.spawn(function()
		repeat
			task.wait()
			if isAlive(lplr, true) then
				entityLibrary.groundTick = lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air and tick() or entityLibrary.groundTick
			end
			for i,v in (entityLibrary.entityList) do
				local state = v.Humanoid:GetState()
				v.JumpTick = (state ~= Enum.HumanoidStateType.Running and state ~= Enum.HumanoidStateType.Landed) and tick() or v.JumpTick
				v.Jumping = (tick() - v.JumpTick) < 0.2 and v.Jumps > 1
				if (tick() - v.JumpTick) > 0.2 then
					v.Jumps = 0
				end
			end
		until not vapeInjected
	end)
end

run(function()
	local handsquare = Instance.new('ImageLabel')
	handsquare.Size = UDim2.new(0, 26, 0, 27)
	handsquare.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	handsquare.Position = UDim2.new(0, 72, 0, 44)
	handsquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local handround = Instance.new('UICorner')
	handround.CornerRadius = UDim.new(0, 4)
	handround.Parent = handsquare
	local helmetsquare = handsquare:Clone()
	helmetsquare.Position = UDim2.new(0, 100, 0, 44)
	helmetsquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local chestplatesquare = handsquare:Clone()
	chestplatesquare.Position = UDim2.new(0, 127, 0, 44)
	chestplatesquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local bootssquare = handsquare:Clone()
	bootssquare.Position = UDim2.new(0, 155, 0, 44)
	bootssquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local uselesssquare = handsquare:Clone()
	uselesssquare.Position = UDim2.new(0, 182, 0, 44)
	uselesssquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local oldupdate = vapeTargetInfo.UpdateInfo
	vapeTargetInfo.UpdateInfo = function(tab, targetsize)
		local bkgcheck = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo.BackgroundTransparency == 1
		handsquare.BackgroundTransparency = bkgcheck and 1 or 0
		helmetsquare.BackgroundTransparency = bkgcheck and 1 or 0
		chestplatesquare.BackgroundTransparency = bkgcheck and 1 or 0
		bootssquare.BackgroundTransparency = bkgcheck and 1 or 0
		uselesssquare.BackgroundTransparency = bkgcheck and 1 or 0
		pcall(function()
			for i,v in (shared.VapeTargetInfo.Targets) do
				local inventory = store.inventories[v.Player] or {}
					if inventory.hand then
						handsquare.Image = bedwars.getIcon(inventory.hand, true)
					else
						handsquare.Image = ''
					end
					if inventory.armor[4] then
						helmetsquare.Image = bedwars.getIcon(inventory.armor[4], true)
					else
						helmetsquare.Image = ''
					end
					if inventory.armor[5] then
						chestplatesquare.Image = bedwars.getIcon(inventory.armor[5], true)
					else
						chestplatesquare.Image = ''
					end
					if inventory.armor[6] then
						bootssquare.Image = bedwars.getIcon(inventory.armor[6], true)
					else
						bootssquare.Image = ''
					end
				break
			end
		end)
		return oldupdate(tab, targetsize)
	end
end)

vape.RemoveObject('SilentAimOptionsButton')
vape.RemoveObject('ReachOptionsButton')
vape.RemoveObject('MouseTPOptionsButton')
vape.RemoveObject('PhaseOptionsButton')
vape.RemoveObject('AutoClickerOptionsButton')
vape.RemoveObject('SpiderOptionsButton')
vape.RemoveObject('LongJumpOptionsButton')
vape.RemoveObject('HitBoxesOptionsButton')
vape.RemoveObject('KillauraOptionsButton')
vape.RemoveObject('TriggerBotOptionsButton')
vape.RemoveObject('AutoLeaveOptionsButton')
vape.RemoveObject('SpeedOptionsButton')
vape.RemoveObject('FlyOptionsButton')
vape.RemoveObject('ClientKickDisablerOptionsButton')
vape.RemoveObject('NameTagsOptionsButton')
vape.RemoveObject('SafeWalkOptionsButton')
vape.RemoveObject('BlinkOptionsButton')
vape.RemoveObject('FOVChangerOptionsButton')
vape.RemoveObject('AntiVoidOptionsButton')
vape.RemoveObject('SongBeatsOptionsButton')
vape.RemoveObject('TargetStrafeOptionsButton')

run(function()
	local AimAssist = {Enabled = false}
	local AimAssistClickAim = {Enabled = false}
	local AimAssistStrafe = {Enabled = false}
	local AimSpeed = {Value = 1}
	local AimAssistTargetFrame = {Players = {Enabled = false}}
	AimAssist = vape.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'AimAssist',
		Function = function(callback)
			if callback then
				RunLoops:BindToRenderStep('AimAssist', function(dt)
					vapeTargetInfo.Targets.AimAssist = nil
					if ((not AimAssistClickAim.Enabled) or cheatenginetrash and inputservice:IsMouseButtonPressed(0) or (tick() - bedwars.SwordController.lastSwing) < 0.4) then
						local plr = GetTarget({radius = 18})
						if plr.RootPart then
							vapeTargetInfo.Targets.AimAssist = {
								Humanoid = {
									Health = (plr.Player.Character:GetAttribute('Health') or plr.Humanoid.Health) + getShieldAttribute(plr.Player.Character),
									MaxHealth = plr.Player.Character:GetAttribute('MaxHealth') or plr.MaxHealth
								},
								Player = plr.Player
							}
							if store.localHand.Type == 'sword' or cheatenginetrash and lplr.Character and lplr.Character:FindFirstChild('HandInvItem') and tostring(lplr.Character.HandInvItem.Value):find('sword') then
								if vape.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then
									if store.matchState == 0 then return end
								end
								if AimAssistTargetFrame.Walls.Enabled then
									if not bedwars.SwordController:canSee({instance = plr.Player.Character, player = plr.Player, getInstance = function() return plr.Player.Character end}) then return end
								end
								camera.CFrame = camera.CFrame:lerp(CFrame.new(camera.CFrame.p, plr.RootPart.Position), ((1 / AimSpeed.Value) + (AimAssistStrafe.Enabled and (inputservice:IsKeyDown(Enum.KeyCode.A) or inputservice:IsKeyDown(Enum.KeyCode.D)) and 0.01 or 0)))
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromRenderStep('AimAssist')
				vapeTargetInfo.Targets.AimAssist = nil
			end
		end,
		HoverText = 'Smoothly aims to closest valid target with sword'
	})
	AimAssistTargetFrame = AimAssist.CreateTargetWindow({Default3 = true})
	AimAssistClickAim = AimAssist.CreateToggle({
		Name = 'Click Aim',
		Function = void,
		Default = true,
		HoverText = 'Only aim while mouse is down'
	})
	AimAssistStrafe = AimAssist.CreateToggle({
		Name = 'Strafe increase',
		Function = void,
		HoverText = 'Increase speed while strafing away from target'
	})
	AimSpeed = AimAssist.CreateSlider({
		Name = 'Smoothness',
		Min = 1,
		Max = 100,
		Function = function(val) end,
		Default = 50
	})
end)

run(function()
	local autoclicker = {Enabled = false}
	local noclickdelay = {Enabled = false}
	local autoclickercps = {GetRandomValue = function() return 1 end}
	local autoclickerblocks = {Enabled = false}
	local AutoClickerThread

	local function isNotHoveringOverGui()
		local mousepos = inputservice:GetMouseLocation() - Vector2.new(0, 36)
		for i,v in (lplr.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do
			if v.Active then
				return false
			end
		end
		for i,v in (getservice('CoreGui'):GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do
			if v.Parent:IsA('ScreenGui') and v.Parent.Enabled then
				if v.Active then
					return false
				end
			end
		end
		return true
	end

	local function AutoClick()
		local firstClick = tick() + 0.1
		AutoClickerThread = task.spawn(function()
			repeat
				task.wait()
				if entityLibrary.isAlive then
					if not autoclicker.Enabled then break end
					if not isNotHoveringOverGui() then continue end
					if bedwars.AppController:isLayerOpen(bedwars.UILayers.MAIN) then continue end
					if vape.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then
						if store.matchState == 0 then continue end
					end
					if store.localHand.Type == 'sword' then
						if bedwars.DaoController.chargingMaid == nil then
							task.spawn(function()
								if firstClick <= tick() then
									bedwars.SwordController:swingSwordAtMouse()
								else
									firstClick = tick()
								end
							end)
							task.wait(math.max((1 / autoclickercps.GetRandomValue()), noclickdelay.Enabled and 0 or 0.142))
						end
					elseif store.localHand.Type == 'block' then
						if autoclickerblocks.Enabled and bedwars.BlockPlacementController.blockPlacer and firstClick <= tick() then
							if (workspace:GetServerTimeNow() - bedwars.BlockCpsController.lastPlaceTimestamp) > ((1 / 12) * 0.5) then
								local mouseinfo = bedwars.BlockPlacementController.blockPlacer.clientManager:getBlockSelector():getMouseInfo(0)
								if mouseinfo then
									task.spawn(function()
										if mouseinfo.placementPosition == mouseinfo.placementPosition then
											bedwars.BlockPlacementController.blockPlacer:placeBlock(mouseinfo.placementPosition)
										end
									end)
								end
								task.wait((1 / autoclickercps.GetRandomValue()))
							end
						end
					end
				end
			until not autoclicker.Enabled
		end)
	end

	autoclicker = vape.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'AutoClicker',
		Function = function(callback)
			if callback then
				if inputservice.TouchEnabled then
					pcall(function()
						table.insert(autoclicker.Connections, lplr.PlayerGui.MobileUI['2'].MouseButton1Down:Connect(AutoClick))
						table.insert(autoclicker.Connections, lplr.PlayerGui.MobileUI['2'].MouseButton1Up:Connect(function()
							if AutoClickerThread then
								task.cancel(AutoClickerThread)
								AutoClickerThread = nil
							end
						end))
					end)
				end
				table.insert(autoclicker.Connections, inputservice.InputBegan:Connect(function(input, gameProcessed)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then AutoClick() end
				end))
				table.insert(autoclicker.Connections, inputservice.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and AutoClickerThread then
						task.cancel(AutoClickerThread)
						AutoClickerThread = nil
					end
				end))
			end
		end,
		HoverText = 'Hold attack button to automatically click'
	})
	autoclickercps = autoclicker.CreateTwoSlider({
		Name = 'CPS',
		Min = 1,
		Max = 20,
		Function = function(val) end,
		Default = 8,
		Default2 = 12
	})
	autoclickerblocks = autoclicker.CreateToggle({
		Name = 'Place Blocks',
		Function = void,
		Default = true,
		HoverText = 'Automatically places blocks when left click is held.'
	})

	local noclickfunc
	noclickdelay = vape.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'NoClickDelay',
		Function = function(callback)
			if callback then
				noclickfunc = bedwars.SwordController.isClickingTooFast
				bedwars.SwordController.isClickingTooFast = function(self)
					self.lastSwing = tick()
					return false
				end
			else
				bedwars.SwordController.isClickingTooFast = noclickfunc
			end
		end,
		HoverText = 'Remove the CPS cap'
	})
end)

run(function()
	local ReachValue = {Value = 14}

	Reach = vape.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'Reach',
		Function = function(callback)
			bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = callback and ReachValue.Value + 2 or 14.4
		end,
		HoverText = 'Extends attack reach'
	})
	ReachValue = Reach.CreateSlider({
		Name = 'Reach',
		Min = 0,
		Max = 18,
		Function = function(val)
			if Reach.Enabled then
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = val + 2
			end
		end,
		Default = 18
	})
end)

run(function()
	local Sprint = {Enabled = false}
	local oldSprintFunction
	Sprint = vape.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'Sprint',
		Function = function(callback)
			if callback then
				if inputservice.TouchEnabled then
					pcall(function() lplr.PlayerGui.MobileUI['4'].Visible = false end)
				end
				oldSprintFunction = bedwars.SprintController.stopSprinting
				bedwars.SprintController.stopSprinting = function(...)
					local originalCall = oldSprintFunction(...)
					bedwars.SprintController:startSprinting()
					return originalCall
				end
				table.insert(Sprint.Connections, lplr.CharacterAdded:Connect(function(char)
					char:WaitForChild('Humanoid', 9e9)
					task.wait(0.5)
					bedwars.SprintController:stopSprinting()
				end))
				task.spawn(function()
					bedwars.SprintController:startSprinting()
				end)
			else
				if inputservice.TouchEnabled then
					pcall(function() lplr.PlayerGui.MobileUI['4'].Visible = true end)
				end
				bedwars.SprintController.stopSprinting = oldSprintFunction
				bedwars.SprintController:stopSprinting()
			end
		end,
		HoverText = 'Sets your sprinting to true.'
	})
end)

run(function()
	local Velocity = {Enabled = false}
	local VelocityHorizontal = {Value = 100}
	local VelocityVertical = {Value = 100}
	local applyKnockback
	Velocity = vape.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'Velocity',
		Function = function(callback)
			if callback then
				applyKnockback = bedwars.KnockbackUtil.applyKnockback
				bedwars.KnockbackUtil.applyKnockback = function(root, mass, dir, knockback, ...)
					knockback = knockback or {}
					if VelocityHorizontal.Value == 0 and VelocityVertical.Value == 0 then return end
					knockback.horizontal = (knockback.horizontal or 1) * (VelocityHorizontal.Value / 100)
					knockback.vertical = (knockback.vertical or 1) * (VelocityVertical.Value / 100)
					return applyKnockback(root, mass, dir, knockback, ...)
				end
			else
				bedwars.KnockbackUtil.applyKnockback = applyKnockback
			end
		end,
		HoverText = 'Reduces knockback taken'
	})
	VelocityHorizontal = Velocity.CreateSlider({
		Name = 'Horizontal',
		Min = 0,
		Max = 100,
		Percent = true,
		Function = function(val) end,
		Default = 0
	})
	VelocityVertical = Velocity.CreateSlider({
		Name = 'Vertical',
		Min = 0,
		Max = 100,
		Percent = true,
		Function = function(val) end,
		Default = 0
	})
end)

run(function()
	local oldclickhold
	local oldclickhold2
	local roact
	local FastConsume = vape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'FastConsume',
		Function = function(callback)
			if callback then
				oldclickhold = bedwars.ClickHold.startClick
				oldclickhold2 = bedwars.ClickHold.showProgress
				bedwars.ClickHold.showProgress = function(p5)
					local roact = debug.getupvalue(oldclickhold2, 1)
					local countdown = roact.mount(roact.createElement('ScreenGui', {}, { roact.createElement('Frame', {
						[roact.Ref] = p5.wrapperRef,
						Size = UDim2.new(0, 0, 0, 0),
						Position = UDim2.new(0.5, 0, 0.55, 0),
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						BackgroundTransparency = 0.8
					}, { roact.createElement('Frame', {
							[roact.Ref] = p5.progressRef,
							Size = UDim2.new(0, 0, 1, 0),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 0.5
						}) }) }), lplr:FindFirstChild('PlayerGui'))
					p5.handle = countdown
					local sizetween = tween:Create(p5.wrapperRef:getValue(), TweenInfo.new(0.1), {
						Size = UDim2.new(0.11, 0, 0.005, 0)
					})
					table.insert(p5.tweens, sizetween)
					sizetween:Play()
					local countdowntween = tween:Create(p5.progressRef:getValue(), TweenInfo.new(p5.durationSeconds * (FastConsumeVal.Value / 40), Enum.EasingStyle.Linear), {
						Size = UDim2.new(1, 0, 1, 0)
					})
					table.insert(p5.tweens, countdowntween)
					countdowntween:Play()
					return countdown
				end
				bedwars.ClickHold.startClick = function(p4)
					p4.startedClickTime = tick()
					local u2 = p4:showProgress()
					local clicktime = p4.startedClickTime
					bedwars.RuntimeLib.Promise.defer(function()
						task.wait(p4.durationSeconds * (FastConsumeVal.Value / 40))
						if u2 == p4.handle and clicktime == p4.startedClickTime and p4.closeOnComplete then
							p4:hideProgress()
							if p4.onComplete ~= nil then
								p4.onComplete()
							end
							if p4.onPartialComplete ~= nil then
								p4.onPartialComplete(1)
							end
							p4.startedClickTime = -1
						end
					end)
				end
			else
				bedwars.ClickHold.startClick = oldclickhold
				bedwars.ClickHold.showProgress = oldclickhold2
				oldclickhold = nil
				oldclickhold2 = nil
			end
		end,
		HoverText = 'Use/Consume items quicker.'
	})
	FastConsumeVal = FastConsume.CreateSlider({
		Name = 'Ticks',
		Min = 0,
		Max = 40,
		Default = 0,
		Function = void
	})
end)

local autobankballoon = false
run(function()
	local Fly = {Enabled = false}
	local FlyMode = {Value = 'CFrame'}
	local FlyVerticalSpeed = {Value = 40}
	local FlyVertical = {Enabled = true}
	local FlyAutoPop = {Enabled = true}
	local FlyAnyway = {Enabled = false}
	local FlyAnywayProgressBar = {Enabled = false}
	local FlyDamageAnimation = {Enabled = false}
	local FlyTP = {Enabled = false}
	local FlyAnywayProgressBarFrame
	local olddeflate
	local FlyUp = false
	local FlyDown = false
	local FlyCoroutine
	local groundtime = tick()
	local onground = false
	local lastonground = false;
	local alternatelist = {'Normal', 'AntiCheat A', 'AntiCheat B'}

	local function inflateBalloon()
		if not Fly.Enabled then return end
		if isAlive(lplr, true) and (lplr.Character:GetAttribute('InflatedBalloons') or 0) < 1 then
			autobankballoon = true
			if getItem('balloon') then
				bedwars.BalloonController:inflateBalloon()
				return true
			end
		end
		return false
	end

	Fly = vape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Fly',
		Function = function(callback)
			if callback then
				olddeflate = bedwars.BalloonController.deflateBalloon
				bedwars.BalloonController.deflateBalloon = void

				table.insert(Fly.Connections, inputservice.InputBegan:Connect(function(input1)
					if FlyVertical.Enabled and inputservice:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							FlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							FlyDown = true
						end
					end
				end))
				table.insert(Fly.Connections, inputservice.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						FlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						FlyDown = false
					end
				end))
				if inputservice.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(Fly.Connections, jumpButton:GetPropertyChangedSignal('ImageRectOffset'):Connect(function()
							FlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						FlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
				table.insert(Fly.Connections, vapeEvents.BalloonPopped.Event:Connect(function(poppedTable)
					if poppedTable.inflatedBalloon and poppedTable.inflatedBalloon:GetAttribute('BalloonOwner') == lplr.UserId then
						lastonground = not onground
						repeat task.wait() until (lplr.Character:GetAttribute('InflatedBalloons') or 0) <= 0 or not Fly.Enabled
						inflateBalloon()
					end
				end))
				table.insert(Fly.Connections, vapeEvents.AutoBankBalloon.Event:Connect(function()
					repeat task.wait() until getItem('balloon')
					inflateBalloon()
				end))

				local balloons
				if isAlive(lplr, true) and (not store.queueType:find('mega')) then
					balloons = inflateBalloon()
				end
				local megacheck = store.queueType:find('mega') or store.queueType == 'winter_event'

				task.spawn(function()
					repeat task.wait() until store.queueType ~= 'bedwars_test' or (not Fly.Enabled)
					if not Fly.Enabled then return end
					megacheck = store.queueType:find('mega') or store.queueType == 'winter_event'
				end)

				local flyAllowed = isAlive(lplr, true) and ((lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') > 0) or store.matchState == 2 or megacheck) and 1 or 0
				if flyAllowed <= 0 and shared.damageanim and (not balloons) then
					shared.damageanim()
					bedwars.SoundManager:playSound(bedwars.SoundList['DAMAGE_'..math.random(1, 3)])
				end

				if FlyAnywayProgressBarFrame and flyAllowed <= 0 and (not balloons) then
					FlyAnywayProgressBarFrame.Visible = true
					FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
				end

				groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
				FlyCoroutine = coroutine.create(function()
					repeat
						repeat task.wait() until (groundtime - tick()) < 0.6 and not onground
						flyAllowed = ((lplr.Character and lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') > 0) or store.matchState == 2 or megacheck) and 1 or 0
						if (not Fly.Enabled) then break end
						local Flytppos = -99999
						if flyAllowed <= 0 and FlyTP.Enabled and isAlive(lplr, true) then
							local ray = workspace:Raycast(lplr.Character.PrimaryPart.Position, Vector3.new(0, -1000, 0), store.raycast)
							if ray then
								Flytppos = lplr.Character.PrimaryPart.Position.Y
								local args = {lplr.Character.PrimaryPart.CFrame:GetComponents()}
								args[2] = ray.Position.Y + (lplr.Character.PrimaryPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight
								lplr.Character.PrimaryPart.CFrame = CFrame.new(unpack(args))
								task.wait(0.12)
								if (not Fly.Enabled) then break end
								flyAllowed = ((lplr.Character and lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') > 0) or store.matchState == 2 or megacheck) and 1 or 0
								if flyAllowed <= 0 and Flytppos ~= -99999 and isAlive(lplr, true) then
									local args = {lplr.Character.PrimaryPart.CFrame:GetComponents()}
									args[2] = Flytppos
									lplr.Character.PrimaryPart.CFrame = CFrame.new(unpack(args))
								end
							end
						end
					until (not Fly.Enabled)
				end)
				coroutine.resume(FlyCoroutine)

				RunLoops:BindToHeartbeat('Fly', function(delta)
					if vape.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then
						if bedwars.matchState == 0 then return end;
					end;
					if render.clone.old and not isnetworkowner(render.clone.old) then 
						return;
					end;
					if isAlive(lplr, true) then
						local playerMass = (lplr.Character.PrimaryPart:GetMass() - 1.4) * (delta * 100)
						flyAllowed = ((lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') > 0) or store.matchState == 2 or megacheck) and 1 or 0
						playerMass = playerMass + (flyAllowed > 0 and 4 or 0) * (tick() % 0.4 < 0.2 and -1 or 1)

						if FlyAnywayProgressBarFrame then
							FlyAnywayProgressBarFrame.Visible = flyAllowed <= 0
							FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.fromHSV(vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
							FlyAnywayProgressBarFrame.Frame.BackgroundColor3 = Color3.fromHSV(vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
						end

						if flyAllowed <= 0 then
							local newray = getPlacedBlock(lplr.Character.PrimaryPart.Position + Vector3.new(0, (entityLibrary.character.Humanoid.HipHeight * -2) - 1, 0))
							onground = newray and true or false
							if lastonground ~= onground then
								if (not onground) then
									groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
									if FlyAnywayProgressBarFrame then
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, groundtime - tick(), true)
									end
								else
									if FlyAnywayProgressBarFrame then
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
									end
								end
							end
							if FlyAnywayProgressBarFrame then
								FlyAnywayProgressBarFrame.TextLabel.Text = math.max(onground and 2.5 or math.floor((groundtime - tick()) * 10) / 10, 0)..'s'
							end
							lastonground = onground
						else
							onground = true
							lastonground = true
						end

						local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (FlyMode.Value == 'Normal' and FlySpeed.Value or 20)
						lplr.Character.PrimaryPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (FlyUp and FlyVerticalSpeed.Value or 0) + (FlyDown and -FlyVerticalSpeed.Value or 0), 0))
						if FlyMode.Value ~= 'Normal' then
							lplr.Character.PrimaryPart.CFrame = lplr.Character.PrimaryPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((FlySpeed.Value + getSpeed()) - 20)) * delta
						end
					end
				end)
			else
				pcall(function() coroutine.close(FlyCoroutine) end)
				autobankballoon = false
				waitingforballoon = false
				lastonground = nil
				FlyUp = false
				FlyDown = false
				RunLoops:UnbindFromHeartbeat('Fly')
				if FlyAnywayProgressBarFrame then
					FlyAnywayProgressBarFrame.Visible = false
				end
				if FlyAutoPop.Enabled then
					if isAlive(lplr, true) and lplr.Character:GetAttribute('InflatedBalloons') then
						for i = 1, lplr.Character:GetAttribute('InflatedBalloons') do
							olddeflate()
						end
					end
				end
				bedwars.BalloonController.deflateBalloon = olddeflate
				olddeflate = nil
			end
		end,
		HoverText = 'Makes you go zoom (longer Fly discovered by exelys and Cqded)',
		ExtraText = function()
			return 'Heatseeker'
		end
	})
	FlySpeed = Fly.CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	FlyVerticalSpeed = Fly.CreateSlider({
		Name = 'Vertical Speed',
		Min = 1,
		Max = 100,
		Function = function(val) end,
		Default = 44
	})
	FlyVertical = Fly.CreateToggle({
		Name = 'Y Level',
		Function = void,
		Default = true
	})
	FlyAutoPop = Fly.CreateToggle({
		Name = 'Pop Balloon',
		Function = void,
		HoverText = 'Pops balloons when Fly is disabled.'
	})
	local oldcamupdate
	local camcontrol
	local Flydamagecamera = {Enabled = false}
	FlyDamageAnimation = Fly.CreateToggle({
		Name = 'Damage Animation',
		Function = function(callback)
			if Flydamagecamera.Object then
				Flydamagecamera.Object.Visible = callback
			end
			if callback then
				task.spawn(function()
					if cheatenginetrash then 
						return;
					end;
					repeat
						task.wait(0.1)
						for i,v in (getconnections(camera:GetPropertyChangedSignal('CameraType'))) do
							if v.Function then
								camcontrol = debug.getupvalue(v.Function, 1)
							end
						end
					until camcontrol
					local caminput = require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput)
					local num = Instance.new('IntValue')
					local numanim
					shared.damageanim = function()
						if numanim then numanim:Cancel() end
						if Flydamagecamera.Enabled then
							num.Value = 1000
							numanim = tween:Create(num, TweenInfo.new(0.5), {Value = 0})
							numanim:Play()
						end
					end
					oldcamupdate = camcontrol.Update
					camcontrol.Update = function(self, dt)
						if camcontrol.activeCameraController then
							camcontrol.activeCameraController:UpdateMouseBehavior()
							local newCameraCFrame, newCameraFocus = camcontrol.activeCameraController:Update(dt)
							camera.CFrame = newCameraCFrame * CFrame.Angles(0, 0, math.rad(num.Value / 100))
							camera.Focus = newCameraFocus
							if camcontrol.activeTransparencyController then
								camcontrol.activeTransparencyController:Update(dt)
							end
							if caminput.getInputEnabled() then
								caminput.resetInputForFrameEnd()
							end
						end
					end
				end)
			else
				shared.damageanim = nil
				if camcontrol then
					camcontrol.Update = oldcamupdate
				end
			end
		end
	})
	Flydamagecamera = Fly.CreateToggle({
		Name = 'Camera Animation',
		Function = void,
		Default = true
	})
	Flydamagecamera.Object.BorderSizePixel = 0
	Flydamagecamera.Object.BackgroundTransparency = 0
	Flydamagecamera.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Flydamagecamera.Object.Visible = false
	FlyAnywayProgressBar = Fly.CreateToggle({
		Name = 'Progress Bar',
		Function = function(callback)
			if callback then
				FlyAnywayProgressBarFrame = Instance.new('Frame')
				FlyAnywayProgressBarFrame.AnchorPoint = Vector2.new(0.5, 0)
				FlyAnywayProgressBarFrame.Position = UDim2.new(0.5, 0, 1, -200)
				FlyAnywayProgressBarFrame.Size = UDim2.new(0.2, 0, 0, 20)
				FlyAnywayProgressBarFrame.BackgroundTransparency = 0.5
				FlyAnywayProgressBarFrame.BorderSizePixel = 0
				FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				FlyAnywayProgressBarFrame.Visible = Fly.Enabled
				FlyAnywayProgressBarFrame.Parent = vape.MainGui
				local FlyAnywayProgressBarFrame2 = FlyAnywayProgressBarFrame:Clone()
				FlyAnywayProgressBarFrame2.AnchorPoint = Vector2.new(0, 0)
				FlyAnywayProgressBarFrame2.Position = UDim2.new(0, 0, 0, 0)
				FlyAnywayProgressBarFrame2.Size = UDim2.new(1, 0, 0, 20)
				FlyAnywayProgressBarFrame2.BackgroundTransparency = 0
				FlyAnywayProgressBarFrame2.Visible = true
				FlyAnywayProgressBarFrame2.Parent = FlyAnywayProgressBarFrame
				local FlyAnywayProgressBartext = Instance.new('TextLabel')
				FlyAnywayProgressBartext.Text = '2s'
				FlyAnywayProgressBartext.Font = Enum.Font.Gotham
				FlyAnywayProgressBartext.TextStrokeTransparency = 0
				FlyAnywayProgressBartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
				FlyAnywayProgressBartext.TextSize = 20
				FlyAnywayProgressBartext.Size = UDim2.new(1, 0, 1, 0)
				FlyAnywayProgressBartext.BackgroundTransparency = 1
				FlyAnywayProgressBartext.Position = UDim2.new(0, 0, -1, 0)
				FlyAnywayProgressBartext.Parent = FlyAnywayProgressBarFrame
			else
				if FlyAnywayProgressBarFrame then FlyAnywayProgressBarFrame:Destroy() FlyAnywayProgressBarFrame = nil end
			end
		end,
		HoverText = 'show amount of Fly time',
		Default = true
	})
	FlyTP = Fly.CreateToggle({
		Name = 'TP Down',
		Function = void,
		Default = true
	})
end)

run(function()
	local GrappleExploit = {Enabled = false}
	local GrappleExploitMode = {Value = 'Normal'}
	local GrappleExploitVerticalSpeed = {Value = 40}
	local GrappleExploitVertical = {Enabled = true}
	local GrappleExploitUp = false
	local GrappleExploitDown = false
	local alternatelist = {'Normal', 'AntiCheat A', 'AntiCheat B'}
	local projectileRemote = bedwars.Client:Get(bedwars.ProjectileRemote)

	--me when I have to fix bw code omegalol
	bedwars.Client:Get('GrapplingHookFunctions'):Connect(function(p4)
		if p4.hookFunction == 'PLAYER_IN_TRANSIT' then
			bedwars.CooldownController:setOnCooldown('grappling_hook', 3.5)
		end
	end)

	GrappleExploit = vape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'GrappleExploit',
		Function = function(callback)
			if callback then
				local grappleHooked = false
				table.insert(GrappleExploit.Connections, bedwars.Client:Get('GrapplingHookFunctions'):Connect(function(p4)
					if p4.hookFunction == 'PLAYER_IN_TRANSIT' then
						store.grapple = tick() + 1.8
						grappleHooked = true
						GrappleExploit.ToggleButton(false)
					end
				end))

				local fireball = getItem('grappling_hook')
				if fireball then
					task.spawn(function()
						repeat task.wait() until bedwars.CooldownController:getRemainingCooldown('grappling_hook') == 0 or (not GrappleExploit.Enabled)
						if (not GrappleExploit.Enabled) then return end
						switchItem(fireball.tool)
						local pos = entityLibrary.character.HumanoidRootPart.CFrame.p
						local offsetshootpos = CFrame.new(pos, pos + Vector3.new(0, -60, 0))
						projectileRemote:CallServerAsync(fireball['tool'], nil, 'grappling_hook_projectile', offsetshootpos, pos, Vector3.new(0, -60, 0), getservice('HttpService'):GenerateGUID(true), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045)
					end)
				else
					warningNotification('GrappleExploit', 'missing grapple hook', 3)
					GrappleExploit.ToggleButton(false)
					return
				end

				local startCFrame = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.CFrame
				RunLoops:BindToHeartbeat('GrappleExploit', function(delta)
					if vape.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then
						if bedwars.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						entityLibrary.character.HumanoidRootPart.Velocity = Vector3.zero
						entityLibrary.character.HumanoidRootPart.CFrame = startCFrame
					end
				end)
			else
				GrappleExploitUp = false
				GrappleExploitDown = false
				RunLoops:UnbindFromHeartbeat('GrappleExploit')
			end
		end,
		HoverText = 'Makes you go zoom (longer GrappleExploit discovered by exelys and Cqded)',
		ExtraText = function()
			if vape.ObjectsThatCanBeSaved['Text GUIAlternate TextToggle']['Api'].Enabled then
				return alternatelist[table.find(GrappleExploitMode['List'], GrappleExploitMode.Value)]
			end
			return GrappleExploitMode.Value
		end
	})
end)

run(function()
	local InfiniteFly = {Enabled = false}
	local InfiniteFlyMode = {Value = 'CFrame'}
	local InfiniteFlySpeed = {Value = 23}
	local InfiniteFlyVerticalSpeed = {Value = 40}
	local InfiniteFlyVertical = {Enabled = true}
	local InfiniteFlyUp = false
	local InfiniteFlyDown = false
	local alternatelist = {'Normal', 'AntiCheat A', 'AntiCheat B'}
	local clonesuccess = false
	local disabledproper = true
	local oldcloneroot
	local cloned
	local clone
	local bodyvelo
	local FlyOverlap = OverlapParams.new()
	FlyOverlap.MaxParts = 9e9
	FlyOverlap.FilterDescendantsInstances = {}
	FlyOverlap.RespectCanCollide = true;
	local antihitEnabled;

	local function disablefunc()
		if bodyvelo then bodyvelo:Destroy() end
		RunLoops:UnbindFromHeartbeat('InfiniteFlyOff')
		disabledproper = true
		if not oldcloneroot or not oldcloneroot.Parent then return end
		lplr.Character.Parent = game
		oldcloneroot.Parent = lplr.Character
		lplr.Character.PrimaryPart = oldcloneroot
		lplr.Character.Parent = workspace
		oldcloneroot.CanCollide = true
		pcall(function()
			for i,v in (lplr.Character:GetDescendants()) do
				if v:IsA('Weld') or v:IsA('Motor6D') then
					if v.Part0 == clone then v.Part0 = oldcloneroot end
					if v.Part1 == clone then v.Part1 = oldcloneroot end
				end
				if v:IsA('BodyVelocity') then
					v:Destroy()
				end
			end
			for i,v in (oldcloneroot:GetChildren()) do
				if v:IsA('BodyVelocity') then
					v:Destroy()
				end
			end
		end)
		local oldclonepos = clone.Position.Y
		if clone then
			clone:Destroy()
			clone = nil
		end
		lplr.Character.Humanoid.HipHeight = hip or 2
		local origcf = {oldcloneroot.CFrame:GetComponents()}
		origcf[2] = oldclonepos
		oldcloneroot.CFrame = CFrame.new(unpack(origcf))
		oldcloneroot = nil
		warningNotification('InfiniteFly', 'Landed!', 3)
		if antihitEnabled then 
			antihitEnabled = false;
			if not isEnabled('AntiHit') then 
				task.wait(0.3)
				vape.ObjectsThatCanBeSaved.AntiHitOptionsButton.Api.ToggleButton();
			end
		end
	end

	InfiniteFly = vape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'InfiniteFly',
		Function = function(callback)
			if callback then
				if not entityLibrary.isAlive then
					disabledproper = true
				end
				if not disabledproper then
					warningNotification('InfiniteFly', 'Wait for the last fly to finish', 3)
					InfiniteFly.ToggleButton(false)
					return
				end
				table.insert(InfiniteFly.Connections, inputservice.InputBegan:Connect(function(input1)
					if InfiniteFlyVertical.Enabled and inputservice:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							InfiniteFlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							InfiniteFlyDown = true
						end
					end
				end))
				table.insert(InfiniteFly.Connections, inputservice.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						InfiniteFlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						InfiniteFlyDown = false
					end
				end))
				if inputservice.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(InfiniteFly.Connections, jumpButton:GetPropertyChangedSignal('ImageRectOffset'):Connect(function()
							InfiniteFlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						InfiniteFlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
				clonesuccess = false
				if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) then
					cloned = lplr.Character
					oldcloneroot = entityLibrary.character.HumanoidRootPart
					if not lplr.Character.Parent then
						InfiniteFly.ToggleButton(false)
						return
					end;
					antihitEnabled = isEnabled('AntiHit');
					if antihitEnabled then 
						vape.ObjectsThatCanBeSaved.AntiHitOptionsButton.Api.ToggleButton();
						task.wait()
					end;
					lplr.Character.Parent = game
					clone = oldcloneroot:Clone()
					clone.Parent = lplr.Character
					oldcloneroot.Parent = camera
					bedwars.QueryUtil:setQueryIgnored(oldcloneroot, true)
					clone.CFrame = oldcloneroot.CFrame
					lplr.Character.PrimaryPart = clone
					lplr.Character.Parent = workspace
					pcall(function()
						for i,v in (lplr.Character:GetDescendants()) do
							if v:IsA('Weld') or v:IsA('Motor6D') then
								if v.Part0 == oldcloneroot then v.Part0 = clone end
								if v.Part1 == oldcloneroot then v.Part1 = clone end
							end
							if v:IsA('BodyVelocity') then
								v:Destroy()
							end
						end
						for i,v in (oldcloneroot:GetChildren()) do
							if v:IsA('BodyVelocity') then
								v:Destroy()
							end
						end
					end)
					if hip then
						lplr.Character.Humanoid.HipHeight = hip
					end
					hip = lplr.Character.Humanoid.HipHeight
					clonesuccess = true
				end
				if not clonesuccess then
					warningNotification('InfiniteFly', 'Character missing', 3)
					InfiniteFly.ToggleButton(false)
					return
				end
				local goneup = false
				RunLoops:BindToHeartbeat('InfiniteFly', function(delta)
					if vape.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then
						if store.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						if isnetworkowner(oldcloneroot) then
							local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)

							local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (InfiniteFlyMode.Value == 'Normal' and InfiniteFlySpeed.Value or 20)
							entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (InfiniteFlyUp and InfiniteFlyVerticalSpeed.Value or 0) + (InfiniteFlyDown and -InfiniteFlyVerticalSpeed.Value or 0), 0))
							if InfiniteFlyMode.Value ~= 'Normal' then
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((InfiniteFlySpeed.Value + getSpeed()) - 20)) * delta
							end

							local speedCFrame = {oldcloneroot.CFrame:GetComponents()}
							speedCFrame[1] = clone.CFrame.X
							if speedCFrame[2] < 1000 or (not goneup) then
								task.spawn(warningNotification, 'InfiniteFly', 'Teleported Up', 3)
								speedCFrame[2] = 100000
								goneup = true
							end
							speedCFrame[3] = clone.CFrame.Z
							oldcloneroot.CFrame = CFrame.new(unpack(speedCFrame))
							oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, oldcloneroot.Velocity.Y, clone.Velocity.Z)
						else
							InfiniteFly.ToggleButton(false)
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat('InfiniteFly')
				if clonesuccess and oldcloneroot and clone and lplr.Character.Parent == workspace and oldcloneroot.Parent ~= nil and disabledproper and cloned == lplr.Character then
					local rayparams = RaycastParams.new()
					rayparams.FilterDescendantsInstances = {lplr.Character, camera}
					rayparams.RespectCanCollide = true
					local ray = workspace:Raycast(Vector3.new(oldcloneroot.Position.X, clone.CFrame.p.Y, oldcloneroot.Position.Z), Vector3.new(0, -1000, 0), rayparams)
					local origcf = {clone.CFrame:GetComponents()}
					origcf[1] = oldcloneroot.Position.X
					origcf[2] = ray and ray.Position.Y + (entityLibrary.character.Humanoid.HipHeight + (oldcloneroot.Size.Y / 2)) or clone.CFrame.p.Y
					origcf[3] = oldcloneroot.Position.Z
					oldcloneroot.CanCollide = true
					bodyvelo = Instance.new('BodyVelocity')
					bodyvelo.MaxForce = Vector3.new(0, 9e9, 0)
					bodyvelo.Velocity = Vector3.new(0, -1, 0)
					bodyvelo.Parent = oldcloneroot
					oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, -1, clone.Velocity.Z)
					RunLoops:BindToHeartbeat('InfiniteFlyOff', function(dt)
						if oldcloneroot then
							oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, -1, clone.Velocity.Z)
							local bruh = {clone.CFrame:GetComponents()}
							bruh[2] = oldcloneroot.CFrame.Y
							local newcf = CFrame.new(unpack(bruh))
							FlyOverlap.FilterDescendantsInstances = {lplr.Character, camera}
							local allowed = true
							for i,v in (workspace:GetPartBoundsInRadius(newcf.p, 2, FlyOverlap)) do
								if (v.Position.Y + (v.Size.Y / 2)) > (newcf.p.Y + 0.5) then
									allowed = false
									break
								end
							end
							if allowed then
								oldcloneroot.CFrame = newcf
							end
						end
					end)
					oldcloneroot.CFrame = CFrame.new(unpack(origcf))
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
					disabledproper = false
					if isnetworkowner(oldcloneroot) then
						warningNotification('InfiniteFly', 'Waiting 1.1s to not flag', 3)
						task.delay(1.1, disablefunc)
					else
						disablefunc()
					end
				end
				InfiniteFlyUp = false
				InfiniteFlyDown = false
			end
		end,
		HoverText = 'Makes you go zoom',
		ExtraText = function()
			return 'Heatseeker'
		end
	})
	InfiniteFlySpeed = InfiniteFly.CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	InfiniteFlyVerticalSpeed = InfiniteFly.CreateSlider({
		Name = 'Vertical Speed',
		Min = 1,
		Max = 100,
		Function = function(val) end,
		Default = 44
	})
	InfiniteFlyVertical = InfiniteFly.CreateToggle({
		Name = 'Y Level',
		Function = void,
		Default = true
	})
end)

local killauraNearPlayer;
run(function()
	local killauraboxes: table = Performance.new();
	local killauratargetframe = {Players = {Enabled = false}}
	local killaurasortmethod = {Value = 'Distance'}
	local killaurarealremote = bedwars.Client:Get(bedwars.AttackRemote).instance
	local killauramethod = {Value = 'Normal'}
	local killauraothermethod = {Value = 'Normal'}
	local killauraanimmethod = {Value = 'Normal'}
	local killaurarange = {Value = 14}
	local killauraangle = {Value = 360}
	local killauratargets = {Value = 10}
	local killauraautoblock = {Enabled = false}
	local killauramouse = {Enabled = false}
	local killauracframe = {Enabled = false}
	local killauragui = {Enabled = false}
	local killauratarget = {Enabled = false}
	local killaurasound = {Enabled = false}
	local killauraswing = {Enabled = false}
	local killaurasync = {Enabled = false}
	local killaurahandcheck = {Enabled = false}
	local killauraanimation = {Enabled = false}
	local killauraanimationtween = {Enabled = false}
	local killauraparticleicon = {Value = ''};
	local killauraboxtransparency = {Value = 7};
	local killauraboxmaterial = {Value = 'Plastic'};
	local killauraparticlecolor = newcolor();
	local killauraparticlecolor2 = newcolor();
	local killauracolor = {Value = 0.44};
	local killauratweenoutspeed = {Value = 1.8};
	local killauranovape = {Enabled = false}
	local killauratargethighlight = {Enabled = false}
	local killaurarangecircle = {Enabled = false}
	local killaurarangecirclepart
	local killauraaimcircle = {Enabled = false}
	local killauraaimcirclepart
	local killauraparticle = {Enabled = false}
	local killauraparticlepart
	local Killauranear = false
	local killauraplaying = false
	local oldViewmodelAnimation = void
	local oldPlaySound = void
	local originalArmC0 = nil
	local killauracurrentanim
	local animationdelay = tick()

	local function getStrength(plr)
		local inv = store.inventories[plr.Player]
		local strength = 0
		local strongestsword = 0
		if inv then
			for i,v in (inv.items) do
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.sword and itemmeta.sword.damage > strongestsword then
					strongestsword = itemmeta.sword.damage / 100
				end
			end
			strength = strength + strongestsword
			for i,v in (inv.armor) do
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.armor then
					strength = strength + (itemmeta.armor.damageReductionMultiplier or 0)
				end
			end
			strength = strength
		end
		return strength
	end

	local kitpriolist = {
		hannah = 5,
		spirit_assassin = 4,
		dasher = 3,
		jade = 2,
		regent = 1
	}

	local killaurasortmethods = {
		Distance = function(a, b)
			return (a.RootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude < (b.RootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
		end,
		Health = function(a, b) 
			return a.Player.Character:GetAttribute('Health') < b.Player.Character:GetAttribute('Health')
		end,
		Threat = function(a, b) 
			return getStrength(a) > getStrength(b)
		end,
		Kit = function(a, b)
			return (kitpriolist[a.Player:GetAttribute('PlayingAsKit')] or 0) > (kitpriolist[b.Player:GetAttribute('PlayingAsKit')] or 0)
		end,
		Switch = false -- :omegalol:
	}

	local originalNeckC0
	local originalRootC0
	local anims = {
		Normal = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
		},
		Slow = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15}
		},
		New = {
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.12},
			{CFrame = CFrame.new(0.74, -0.92, 0.88) * CFrame.Angles(math.rad(147), math.rad(71), math.rad(53)), Time = 0.12}
		},
		Latest = {
			{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
			{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1}
		},
		['Vertical Spin'] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}
		},
		Exhibition = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		['Exhibition Old'] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
		},
		Funny = {
			{CFrame = CFrame.new(0, 0, 1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.15},
			{CFrame = CFrame.new(0, 0, -1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-55), math.rad(0), math.rad(0)), Time = 0.15}
		},
		FunnyFuture = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)),Time = 0.25},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25}
		},
		Goofy = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.25},
			{CFrame = CFrame.new(-1, -1, 1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(-33)),Time = 0.25}
		},
		Future = {
			{CFrame = CFrame.new(0.69, -0.7, 0.10) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.20},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25}
		},
		Pop = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-30), math.rad(80), math.rad(-90)), Time = 0.35},
			{CFrame = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.35}
		},
		FunnyV2 = {
			{CFrame = CFrame.new(0.10, -0.5, -1) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(300)), Time = 0.45},
			{CFrame = CFrame.new(-5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.45},
			{CFrame = CFrame.new(5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.45},
		},
		Smooth = {
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(60)), Time = 0.25},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(100), math.rad(60)), Time = 0.25},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(60), math.rad(60)), Time = 0.25},
		},
		FasterSmooth = {
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(60)), Time = 0.11},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(100), math.rad(60)), Time = 0.11},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(60), math.rad(60)), Time = 0.11},
		},
		PopV2 = {
			{CFrame = CFrame.new(0.10, -0.3, -0.30) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(290)), Time = 0.09},
			{CFrame = CFrame.new(0.10, 0.10, -1) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(300)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
		},
		Bob = {
			{CFrame = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(-0.7, -2.5, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		Knife = {
			{CFrame = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(1, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(4, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		},
		FunnyExhibition = {
			{CFrame = CFrame.new(-1.5, -0.50, 0.20) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.10},
			{CFrame = CFrame.new(-0.55, -0.20, 1.5) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		},
		Remake = {
			{CFrame = CFrame.new(-0.10, -0.45, -0.20) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-50)), Time = 0.01},
			{CFrame = CFrame.new(0.7, -0.71, -1) * CFrame.Angles(math.rad(-90), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(0.63, -0.1, 1.50) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
		},
		PopV3 = {
			{CFrame = CFrame.new(0.69, -0.10, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -2, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1}
		},
		PopV4 = {
			{CFrame = CFrame.new(0.69, -0.10, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.01},
			{CFrame = CFrame.new(0.7, -0.30, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.01},
			{CFrame = CFrame.new(0.69, -2, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.01}
		},
		Shake = {
			{CFrame = CFrame.new(0.69, -0.8, 0.6) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-35)), Time = 0.05},
			{CFrame = CFrame.new(0.8, -0.71, 0.30) * CFrame.Angles(math.rad(-60), math.rad(39), math.rad(-55)), Time = 0.02},
			{CFrame = CFrame.new(0.8, -2, 0.45) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-55)), Time = 0.03}
		},
		Idk = {
			{CFrame = CFrame.new(0, -0.1, -0.30) * CFrame.Angles(math.rad(-20), math.rad(20), math.rad(0)), Time = 0.30},
			{CFrame = CFrame.new(0, -0.50, -0.30) * CFrame.Angles(math.rad(-40), math.rad(41), math.rad(0)), Time = 0.32},
			{CFrame = CFrame.new(0, -0.1, -0.30) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)), Time = 0.32}
		},
		Block = {
			{CFrame = CFrame.new(1, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(45), math.rad(0), math.rad(0)), Time = 0.2},
			{CFrame = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)), Time = 0.2},
			{CFrame = CFrame.new(0.3, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		BingChilling = {
			{CFrame = CFrame.new(0.07, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		['Womp Womp'] = {
			{CFrame = CFrame.new(0.07, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(15), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		['Yomp Yomp'] = {
			{CFrame = CFrame.new(0.07, -0.7, 0.6) * CFrame.Angles(math.rad(0), math.rad(15), math.rad(-20)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		FunnyV3 = {
			{CFrame = CFrame.new(0.8, 10.7, 3.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.1},
			{CFrame = CFrame.new(5.7, -1.7, 5.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.15},
			{CFrame = CFrame.new(2.95, -5.06, -6.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
		},
		["Lunar Old"] = {
			{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.15},
			{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.15}
		},
		["Lunar New"] = {
			{CFrame = CFrame.new(0.86, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.17},
			{CFrame = CFrame.new(0.73, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.17}
		},
		["Lunar Fast"] = {
			{CFrame = CFrame.new(0.95, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.15},
			{CFrame = CFrame.new(0.40, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.15}
		},
		["Liquid Bounce"] = {
			{CFrame = CFrame.new(-0.01, -0.3, -1.01) * CFrame.Angles(math.rad(-35), math.rad(90), math.rad(-90)), Time = 0.45},
			{CFrame = CFrame.new(-0.01, -0.3, -1.01) * CFrame.Angles(math.rad(-35), math.rad(70), math.rad(-90)), Time = 0.45},
			{CFrame = CFrame.new(-0.01, -0.3, 0.4) * CFrame.Angles(math.rad(-35), math.rad(70), math.rad(-90)), Time = 0.32}
		},
		["Auto Block"] = {
			{CFrame = CFrame.new(-0.6, -0.2, 0.3) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(65)), Time = 0.15},
			{CFrame = CFrame.new(-0.6, -0.2, 0.3) * CFrame.Angles(math.rad(0), math.rad(110), math.rad(65)), Time = 0.15},
			{CFrame = CFrame.new(-0.6, -0.2, 0.3) * CFrame.Angles(math.rad(0), math.rad(65), math.rad(65)), Time = 0.15}
		},
		Meteor = {
			{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.15},
			{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.15}
		},
		Switch = {
			{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
			{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1}
		},
		Sideways = {
			{CFrame = CFrame.new(5, -3, 2) * CFrame.Angles(math.rad(120), math.rad(160), math.rad(140)), Time = 0.12},
			{CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.12},
			{CFrame = CFrame.new(5, -3.4, -3.3) * CFrame.Angles(math.rad(45), math.rad(160), math.rad(190)), Time = 0.12},
			{CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.12}
		},
		Stand = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1}
		},
		Astral = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.15},
			{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
		},
		Render = {
			{CFrame = CFrame.new(0.2, 0, -1.3) * CFrame.Angles(math.rad(130), math.rad(130), math.rad(130)), Time = 0.16},
			{CFrame = CFrame.new(0, -0.2, -1.7) * CFrame.Angles(math.rad(30), math.rad(130), math.rad(190)), Time = 0.13}
		},
		BetterSmooth = {
			{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.28},
			{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-180), math.rad(54), math.rad(33)), Time = 0.25}
		},
	}

	local function closestpos(block, pos)
		local blockpos = block:GetRenderCFrame()
		local startpos = (blockpos * CFrame.new(-(block.Size / 2))).p
		local endpos = (blockpos * CFrame.new((block.Size / 2))).p
		local speedCFrame = block.Position + (pos - block.Position)
		local x = startpos.X > endpos.X and endpos.X or startpos.X
		local y = startpos.Y > endpos.Y and endpos.Y or startpos.Y
		local z = startpos.Z > endpos.Z and endpos.Z or startpos.Z
		local x2 = startpos.X < endpos.X and endpos.X or startpos.X
		local y2 = startpos.Y < endpos.Y and endpos.Y or startpos.Y
		local z2 = startpos.Z < endpos.Z and endpos.Z or startpos.Z
		return Vector3.new(math.clamp(speedCFrame.X, x, x2), math.clamp(speedCFrame.Y, y, y2), math.clamp(speedCFrame.Z, z, z2))
	end

	local function getAttackData()
		if vape.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then
			if store.matchState == 0 then return false end
		end
		if killauramouse.Enabled then
			if not inputservice:IsMouseButtonPressed(0) then return false end
		end
		if killauragui.Enabled then
			if bedwars.AppController:isLayerOpen(bedwars.UILayers.MAIN) then return false end
		end
		local sword = killaurahandcheck.Enabled and store.localHand or getSword()
		if not sword or not sword.tool then return false end
		local swordmeta = bedwars.ItemTable[sword.tool.Name]
		if killaurahandcheck.Enabled then
			if store.localHand.Type ~= 'sword' or bedwars.DaoController.chargingMaid then return false end
		end
		return sword, swordmeta
	end

	local function autoBlockLoop()
		if not killauraautoblock.Enabled or not Killaura.Enabled then return end
		repeat
			if store.blockPlace < tick() and entityLibrary.isAlive then
				local shield = getItem('infernal_shield')
				if shield then
					switchItem(shield.tool)
					if not lplr.Character:GetAttribute('InfernalShieldRaised') then
						bedwars.InfernalShieldController:raiseShield()
					end
				end
			end
			task.wait()
		until (not Killaura.Enabled) or (not killauraautoblock.Enabled)
	end

	Killaura = vape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Killaura',
		Function = function(callback)
			if callback then
				if killauraaimcirclepart then killauraaimcirclepart.Parent = camera end
				if killaurarangecirclepart then killaurarangecirclepart.Parent = camera end
				if killauraparticlepart then killauraparticlepart.Parent = camera end

				task.spawn(function()
					local oldNearPlayer
					repeat
						task.wait()
						if (killauraanimation.Enabled) then
							if killauraNearPlayer then
								pcall(function()
									if originalArmC0 == nil then
										originalArmC0 = camera.Viewmodel.RightHand.RightWrist.C0
									end
									if killauraplaying == false then
										killauraplaying = true
										for i,v in (anims[killauraanimmethod.Value]) do
											if (not Killaura.Enabled) or (not killauraNearPlayer) then break end
											if not oldNearPlayer and killauraanimationtween.Enabled then
												camera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0 * v.CFrame
												continue
											end
											killauracurrentanim = tween:Create(camera.Viewmodel.RightHand.RightWrist, TweenInfo.new(v.Time), {C0 = originalArmC0 * v.CFrame})
											killauracurrentanim:Play()
											task.wait(v.Time - 0.01)
										end
										killauraplaying = false
									end
								end)
							end
							oldNearPlayer = killauraNearPlayer
						end
					until Killaura.Enabled == false
				end)

				oldViewmodelAnimation = oldViewmodelAnimation or bedwars.ViewmodelController.playAnimation;
				oldPlaySound = oldPlaySound or bedwars.SoundManager.playSound;
				bedwars.SoundManager.playSound = function(tab, soundid, ...)
					if (soundid == bedwars.SoundList.SWORD_SWING_1 or soundid == bedwars.SoundList.SWORD_SWING_2) and Killaura.Enabled and killaurasound.Enabled and killauraNearPlayer then
						return nil
					end
					return oldPlaySound(tab, soundid, ...)
				end
				
				--[[bedwars.ViewmodelController.playAnimation = shared.risegui and oldViewmodelAnimation or function(Self, id, ...)
					if id == 15 and killauraNearPlayer and killauraswing.Enabled and entityLibrary.isAlive then
						return nil
					end
					if id == 15 and killauraNearPlayer and killauraanimation.Enabled and entityLibrary.isAlive then
						return nil
					end
					return oldViewmodelAnimation(Self, id, ...)
				end]]

				local targetedPlayer
				RunLoops:BindToHeartbeat('Killaura', function()
					if entityLibrary.isAlive then
						if killauraaimcirclepart then
							killauraaimcirclepart.Position = targetedPlayer and closestpos(targetedPlayer.RootPart, entityLibrary.character.HumanoidRootPart.Position) or Vector3.new(99999, 99999, 99999)
						end
						if killauraparticlepart then
							killauraparticlepart.Position = targetedPlayer and targetedPlayer.RootPart.Position or Vector3.new(99999, 99999, 99999)
						end
						local Root = entityLibrary.character.HumanoidRootPart
						if Root then
							if killaurarangecirclepart then
								killaurarangecirclepart.Position = Root.Position - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)
							end
							local Neck = entityLibrary.character.Head:FindFirstChild('Neck')
							local LowerTorso = Root.Parent and Root.Parent:FindFirstChild('LowerTorso')
							local RootC0 = LowerTorso and LowerTorso:FindFirstChild('Root')
							if Neck and RootC0 then
								if originalNeckC0 == nil then
									originalNeckC0 = Neck.C0.p
								end
								if originalRootC0 == nil then
									originalRootC0 = RootC0.C0.p
								end
								if originalRootC0 and killauracframe.Enabled then
									if targetedPlayer ~= nil then
										local targetPos = targetedPlayer.RootPart.Position + Vector3.new(0, 2, 0)
										local direction = (Vector3.new(targetPos.X, targetPos.Y, targetPos.Z) - entityLibrary.character.Head.Position).Unit
										local direction2 = (Vector3.new(targetPos.X, Root.Position.Y, targetPos.Z) - Root.Position).Unit
										local lookCFrame = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction)))
										local lookCFrame2 = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction2)))
										Neck.C0 = CFrame.new(originalNeckC0) * CFrame.Angles(lookCFrame.LookVector.Unit.y, 0, 0)
										RootC0.C0 = lookCFrame2 + originalRootC0
									else
										Neck.C0 = CFrame.new(originalNeckC0)
										RootC0.C0 = CFrame.new(originalRootC0)
									end
								end
							end
						end
					end
				end)
				if killauraautoblock.Enabled then
					task.spawn(autoBlockLoop)
				end
				task.spawn(function()
					repeat
						task.wait()
						if not Killaura.Enabled then break end
						render.targets:updatehuds();
						vapeTargetInfo.Targets.Killaura = nil
						local plrs = GetAllTargets(killaurarange.Value, true, killaurasortmethods[killaurasortmethod.Value])
						local firstPlayerNear
						if #plrs > 0 then
							local sword, swordmeta = getAttackData()
							if sword then
								task.spawn(switchItem, sword.tool)
								for i, plr in (plrs) do
									local root = plr.RootPart
									if not root then
										continue
									end
									local localfacing = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
									local vec = (plr.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).unit
									local angle = math.acos(localfacing:Dot(vec))
									if angle >= (math.rad(killauraangle.Value) / 2) then
										continue
									end
									local selfrootpos = entityLibrary.character.HumanoidRootPart.Position
									if killauratargetframe.Walls.Enabled then
										if not bedwars.SwordController:canSee({player = plr.Player, getInstance = function() return plr.Character end}) then continue end
									end
									if killauranovape.Enabled and store.whitelist.clientUsers[plr.Player.Name] then
										continue
									end;
									for i,v in killauraboxes do 
										if i ~= root then 
											tween:Create(v, TweenInfo.new(0.15), {Transparency = 1}):Play()
											v:Destroy()
										end
									end;
									if killauratarget.Enabled then 
										local box: Part = killauraboxes[root] or Instance.new('Part', workspace);
										box.Transparency = 0.1 * killauraboxtransparency.Value;
										box.Material = Enum.Material[killauraboxmaterial.Value];
										box.Color = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value);
										box.Size = root.Size + Vector3.new(3, 5, 3);
										box.Position = root.Position;
										box.Anchored = true;
										box.CanCollide = false;
										if killauraboxes[root] == nil then 
											box.Transparency = 1;
											tween:Create(box, TweenInfo.new(0.1), {Transparency = (0.1 * killauraboxtransparency.Value)}):Play()
										end;
										killauraboxes[root] = box;
									end;
									if not firstPlayerNear then
										firstPlayerNear = true
										killauraNearPlayer = true
										targetedPlayer = plr
										vapeTargetInfo.Targets.Killaura = {
											RootPart = root,
											Humanoid = {
												Health = (plr.Player.Character:GetAttribute('Health') or plr.Humanoid.Health) + getShieldAttribute(plr.Player.Character),
												MaxHealth = plr.Player.Character:GetAttribute('MaxHealth') or plr.Humanoid.MaxHealth
											},
											Player = plr.Player
										};
										render.targets:updatehuds(vapeTargetInfo.Targets.Killaura);
										if animationdelay <= tick() then
											animationdelay = tick() + (swordmeta.sword.respectAttackSpeedForEffects and swordmeta.sword.attackSpeed or (killaurasync.Enabled and 0.24 or 0.14))
											if shared.risegui or not killauraswing.Enabled then
												bedwars.SwordController:playSwordEffect(swordmeta, false)
											end
											if swordmeta.displayName:find(' Scythe') then
												--bedwars.ScytheController:playLocalAnimation()
											end
										end
									end
									if (workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) < 0.02 then
										break
									end
									local selfpos = selfrootpos + (killaurarange.Value > 14 and (selfrootpos - root.Position).magnitude > 14.4 and (CFrame.lookAt(selfrootpos, root.Position).lookVector * ((selfrootpos - root.Position).magnitude - 12)) or Vector3.zero)
									bedwars.SwordController.lastAttack = workspace:GetServerTimeNow()
									store.attackReach = math.floor((selfrootpos - root.Position).magnitude * 100) / 100
									store.attackReachUpdate = tick() + 1
									killaurarealremote:FireServer({
										weapon = sword.tool,
										chargedAttack = {chargeRatio = swordmeta.sword.chargedAttack and not swordmeta.sword.chargedAttack.disableOnGrounded and 0.999 or 0},
										entityInstance = plr.Player.Character,
										validate = {
											raycast = {
												cameraPosition = attackValue(root.Position),
												cursorDirection = attackValue(Ray.new(camera.CFrame.Position, lplr:GetMouse().Hit.Position).Unit.Direction)
											},
											targetPosition = attackValue(CFrame.lookAt(root.Position, selfpos).Position),
											selfPosition = attackValue(selfpos)
										}
									})
									break
								end
							end
						else 
							killauraboxes:clear(function(box: Instance)
								local fadeout: Tween = tween:Create(box, TweenInfo.new(0.15), {Transparency = 1});
								fadeout:Play();
								fadeout.Completed:Wait();
								box:Destroy()
							end)
						end
						if not firstPlayerNear then
							targetedPlayer = nil
							killauraNearPlayer = false
							pcall(function()
								if originalArmC0 == nil then
									originalArmC0 = camera.Viewmodel.RightHand.RightWrist.C0
								end
								if camera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
									pcall(function()
										killauracurrentanim:Cancel()
									end)
									if killauraanimationtween.Enabled then
										camera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
									else
										killauracurrentanim = tween:Create(camera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.2 * killauratweenoutspeed.Value), {C0 = originalArmC0})
										killauracurrentanim:Play()
									end
								end
							end)
						end
					until (not Killaura.Enabled)
				end)
			else
				vapeTargetInfo.Targets.Killaura = nil;
				render.targets:updatehuds();
				killauraboxes:clear(game.Destroy);
				RunLoops:UnbindFromHeartbeat('Killaura')
				killauraNearPlayer = false
				if killauraaimcirclepart then killauraaimcirclepart.Parent = nil end
				if killaurarangecirclepart then killaurarangecirclepart.Parent = nil end
				if killauraparticlepart then killauraparticlepart.Parent = nil end
				bedwars.ViewmodelController.playAnimation = oldViewmodelAnimation
				bedwars.SoundManager.playSound = oldPlaySound
				oldViewmodelAnimation = nil
				pcall(function()
					if entityLibrary.isAlive then
						local Root = entityLibrary.character.HumanoidRootPart
						if Root then
							local Neck = Root.Parent.Head.Neck
							if originalNeckC0 and originalRootC0 then
								Neck.C0 = CFrame.new(originalNeckC0)
								Root.Parent.LowerTorso.Root.C0 = CFrame.new(originalRootC0)
							end
						end
					end
					if originalArmC0 == nil then
						originalArmC0 = camera.Viewmodel.RightHand.RightWrist.C0
					end
					if camera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
						pcall(function()
							killauracurrentanim:Cancel()
						end)
						if killauraanimationtween.Enabled then
							camera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
						else
							killauracurrentanim = tween:Create(camera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.2 * killauratweenoutspeed.Value), {C0 = originalArmC0})
							killauracurrentanim:Play()
						end
					end
				end)
			end
		end,
		HoverText = 'Attack players around you\nwithout aiming at them.'
	})
	killauratargetframe = Killaura.CreateTargetWindow({})
	local sortmethods = {'Distance'}
	for i,v in (killaurasortmethods) do if i ~= 'Distance' then table.insert(sortmethods, i) end end
	killaurasortmethod = Killaura.CreateDropdown({
		Name = 'Sort',
		Function = void,
		List = sortmethods
	})
	killaurarange = Killaura.CreateSlider({
		Name = 'Attack range',
		Min = 1,
		Max = 18,
		Function = function(val)
			if killaurarangecirclepart then
				killaurarangecirclepart.Size = Vector3.new(val * 0.7, 0.01, val * 0.7)
			end
		end,
		Default = 18
	})
	killauraangle = Killaura.CreateSlider({
		Name = 'Max angle',
		Min = 1,
		Max = 360,
		Function = function(val) end,
		Default = 360
	})
	killauratweenoutspeed = Killaura.CreateSlider({
		Name = 'Tween Out Speed',
		Min = 0,
		Max = 5,
		Default = 1.8,
		Function = void
	})
	local animmethods = {}
	for i,v in (anims) do table.insert(animmethods, i) end
	killauraanimmethod = Killaura.CreateDropdown({
		Name = 'Animation',
		List = animmethods,
		Function = function(val) end
	})
	local oldviewmodel
	local oldraise
	local oldeffect
	killauraautoblock = Killaura.CreateToggle({
		Name = 'AutoBlock',
		Function = function(callback)
			if callback then
				oldviewmodel = oldviewmodel or bedwars.ViewmodelController.setHeldItem;
				bedwars.ViewmodelController.setHeldItem = shared.risegui and oldviewmodel or function(self, newItem, ...)
					if newItem and newItem.Name == 'infernal_shield' then
						return
					end
					return oldviewmodel(self, newItem)
				end
				oldraise = oldraise or bedwars.InfernalShieldController.raiseShield;
				bedwars.InfernalShieldController.raiseShield = function(self)
					if os.clock() - self.lastShieldRaised < 0.4 or shared.risegui then
						return
					end
					self.lastShieldRaised = os.clock()
					self.infernalShieldState:SendToServer({raised = true})
					self.raisedMaid:GiveTask(function()
						self.infernalShieldState:SendToServer({raised = false})
					end)
				end
				oldeffect = bedwars.InfernalShieldController.playEffect
				bedwars.InfernalShieldController.playEffect = function()
					return
				end
				if bedwars.ViewmodelController.heldItem and bedwars.ViewmodelController.heldItem.Name == 'infernal_shield' then
					local sword, swordmeta = getSword()
					if sword then
						bedwars.ViewmodelController:setHeldItem(sword.tool)
					end
				end
				task.spawn(autoBlockLoop)
			else
				bedwars.ViewmodelController.setHeldItem = oldviewmodel
				bedwars.InfernalShieldController.raiseShield = oldraise
				bedwars.InfernalShieldController.playEffect = oldeffect
			end
		end,
		Default = true
	})
	killauramouse = Killaura.CreateToggle({
		Name = 'Require mouse down',
		Function = void,
		HoverText = 'Only attacks when left click is held.',
		Default = false
	})
	killauragui = Killaura.CreateToggle({
		Name = 'GUI Check',
		Function = void,
		HoverText = 'Attacks when you are not in a GUI.'
	})
	killauratarget = Killaura.CreateToggle({
		Name = 'Show target',
		Function = function(callback)
			if killauratargethighlight.Object then
				killauratargethighlight.Object.Visible = callback
			end
		end,
		HoverText = 'Shows a red box over the opponent.'
	});
	killauraboxmaterial = Killaura.CreateDropdown({
		Name = 'Material',
		List = GetEnumItems('Material'),
		Function = void
	});
	killauraboxtransparency = Killaura.CreateSlider({
		Name = 'Invisibility',
		Min = 0,
		Max = 9,
		Default = 7
	});
	killauratargethighlight = Killaura.CreateToggle({
		Name = 'Use New Highlight',
		Function = void
	})
	killauratargethighlight.Object.BorderSizePixel = 0
	killauratargethighlight.Object.BackgroundTransparency = 0
	killauratargethighlight.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	killauratargethighlight.Object.Visible = false
	killauracolor = Killaura.CreateColorSlider({
		Name = 'Target Color',
		Function = function(hue, sat, val)
			if killauraaimcirclepart then
				killauraaimcirclepart.Color = Color3.fromHSV(hue, sat, val)
			end
			if killaurarangecirclepart then
				killaurarangecirclepart.Color = Color3.fromHSV(hue, sat, val)
			end
		end,
		Default = 1
	})
	killauraparticlecolor = Killaura.CreateColorSlider({
		Name = 'Crit Part Color',
		Function = void
	})
	killauraparticlecolor2 = Killaura.CreateColorSlider({
		Name = 'Crit Part Color 2',
		Function = void
	})
	killauraparticleicon = Killaura.CreateTextBox({
		Name = 'Crit Part Icon',
		TempText = 'criticle part icon',
		FocusLost = void
	})
	killauracframe = Killaura.CreateToggle({
		Name = 'Face target',
		Function = void,
		HoverText = 'Makes your character face the opponent.'
	})
	killaurarangecircle = Killaura.CreateToggle({
		Name = 'Range Visualizer',
		Function = function(callback)
			if callback then
				local success = pcall(function()
					killaurarangecirclepart = Instance.new('MeshPart', Killaura.Enabled and camera or game)
					killaurarangecirclepart.MeshId = 'rbxassetid://3726303797'
					killaurarangecirclepart.Color = Color3.fromHSV(killauracolor['Hue'], killauracolor['Sat'], killauracolor.Value)
					killaurarangecirclepart.CanCollide = false
					killaurarangecirclepart.Anchored = true
					killaurarangecirclepart.Material = Enum.Material.Neon
					killaurarangecirclepart.Size = Vector3.new(killaurarange.Value * 0.7, 0.01, killaurarange.Value * 0.7)
					bedwars.QueryUtil:setQueryIgnored(killaurarangecirclepart, true)
				end)
				if killaurarangecirclepart and not success then 
					pcall(function() killaurarangecirclepart:Destroy() end);
					killaurarangecirclepart = nil;
				end
			else
				if killaurarangecirclepart then
					killaurarangecirclepart:Destroy()
					killaurarangecirclepart = nil
				end
			end
		end
	})
	killauraaimcircle = Killaura.CreateToggle({
		Name = 'Aim Visualizer',
		Function = function(callback)
			if callback then
				killauraaimcirclepart = Instance.new('Part')
				killauraaimcirclepart.Shape = Enum.PartType.Ball
				killauraaimcirclepart.Color = Color3.fromHSV(killauracolor['Hue'], killauracolor['Sat'], killauracolor.Value)
				killauraaimcirclepart.CanCollide = false
				killauraaimcirclepart.Anchored = true
				killauraaimcirclepart.Material = Enum.Material.Neon
				killauraaimcirclepart.Size = Vector3.new(0.5, 0.5, 0.5)
				if Killaura.Enabled then
					killauraaimcirclepart.Parent = camera
				end
				bedwars.QueryUtil:setQueryIgnored(killauraaimcirclepart, true)
			else
				if killauraaimcirclepart then
					killauraaimcirclepart:Destroy()
					killauraaimcirclepart = nil
				end
			end
		end
	})
	killauraparticle = Killaura.CreateToggle({
		Name = 'Crit Particle',
		Function = function(callback)
			killauraparticlecolor.Object.Visible = callback;
			killauraparticlecolor2.Object.Visible = callback;
			killauraparticleicon.Object.Visible = callback;
			if callback then
				killauraparticlepart = Instance.new('Part')
				killauraparticlepart.Transparency = 1
				killauraparticlepart.CanCollide = false
				killauraparticlepart.Anchored = true
				killauraparticlepart.Size = Vector3.new(3, 6, 3)
				killauraparticlepart.Parent = camera
				bedwars.QueryUtil:setQueryIgnored(killauraparticlepart, true)
				local particle = Instance.new('ParticleEmitter')
				local oldtexture = particle.Texture;
				particle.Lifetime = NumberRange.new(0.5)
				particle.Rate = 500
				particle.Speed = NumberRange.new(0)
				particle.RotSpeed = NumberRange.new(180)
				particle.Enabled = true
				particle.Size = NumberSequence.new(0.3)
				particle.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(67, 10, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 98, 255))})
				particle.Parent = killauraparticlepart
				task.spawn(function()
					repeat 
						local color, color2 = killauraparticlecolor, killauraparticlecolor2;
						pcall(function() 
							particle.Texture = `rbxassetid://97275025184464`
						end);
						pcall(function() particle.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(color.Hue, color.Sat, color.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(color2.Hue, color2.Sat, color2.Value))}) end); 
						task.wait()
					until (not killauraparticle.Enabled)
				end)
			else
				if killauraparticlepart then
					killauraparticlepart:Destroy()
					killauraparticlepart = nil
				end
			end
		end
	})
	killaurasound = Killaura.CreateToggle({
		Name = 'No Swing Sound',
		Function = void,
		HoverText = 'Removes the swinging sound.'
	})
	killauraswing = Killaura.CreateToggle({
		Name = 'No Swing',
		Function = void,
		HoverText = 'Removes the swinging animation.'
	})
	killaurahandcheck = Killaura.CreateToggle({
		Name = 'Limit to items',
		Function = void,
		HoverText = 'Only attacks when your sword is held.'
	})
	killauraanimation = Killaura.CreateToggle({
		Name = 'Custom Animation',
		Function = function(callback)
			if killauraanimationtween.Object then killauraanimationtween.Object.Visible = callback end
		end,
		HoverText = 'Uses a custom animation for swinging'
	})
	killauraanimationtween = Killaura.CreateToggle({
		Name = 'No Tween',
		HoverText = 'Disable\'s the in and out ease',
		Function = function(calling)
			pcall(function()
				killauratweenoutspeed.Object.Visible = not calling;
			end);
		end
	})
	killauraanimationtween.Object.Visible = false
	killaurasync = Killaura.CreateToggle({
		Name = 'Synced Animation',
		Function = void,
		HoverText = 'Times animation with hit attempt'
	})
	killauranovape = Killaura.CreateToggle({
		Name = 'No Vape',
		Function = void,
		HoverText = 'no hit vape user'
	})
	killauranovape.Object.Visible = false;
	killauratweenoutspeed.Object.Visible = false;
	killauraparticlecolor.Object.Visible = false;
	killauraparticlecolor2.Object.Visible = false;
	killauraparticleicon.Object.Visible = false;
end)

local LongJump = {Enabled = false}
run(function()
	local damagetimer = 0
	local damagetimertick = 0
	local directionvec
	local LongJumpSpeed = {Value = 1.5};
	local projectileRemote = bedwars.Client:Get(bedwars.ProjectileRemote)

	local function calculatepos(vec)
		local returned = vec
		if entityLibrary.isAlive then
			local newray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, returned, store.raycast)
			if newray then returned = (newray.Position - entityLibrary.character.HumanoidRootPart.Position) end
		end
		return returned
	end

	local damagemethods = {
		fireball = function(fireball, pos)
			if not LongJump.Enabled then return end
			pos = pos - (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 0.2)
			if cheatenginetrash == nil and not (getPlacedBlock(pos - Vector3.new(0, 3, 0)) or getPlacedBlock(pos - Vector3.new(0, 6, 0))) then
				local sound = Instance.new('Sound')
				sound.SoundId = 'rbxassetid://4809574295'
				sound.Parent = workspace
				sound.Ended:Connect(function()
					sound:Destroy()
				end)
				sound:Play()
			end
			local origpos = pos
			local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)))
			local ray = workspace:Raycast(pos, Vector3.new(0, -30, 0), store.raycast)
			if ray then
				pos = ray.Position
				offsetshootpos = pos
			end
			task.spawn(function()
				switchItem(fireball.tool)
				bedwars.ProjectileController:createLocalProjectile(bedwars.ProjectileMeta.fireball, 'fireball', 'fireball', offsetshootpos, '', Vector3.new(0, -60, 0), {drawDurationSeconds = 1})
				projectileRemote:CallServerAsync(fireball.tool, 'fireball', 'fireball', offsetshootpos, pos, Vector3.new(0, -60, 0), getservice('HttpService'):GenerateGUID(true), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045)
			end)
		end,
		tnt = function(tnt, pos2)
			if not LongJump.Enabled then return end
			local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
			local block = bedwars.placeBlock(pos, 'tnt')
		end,
		cannon = function(tnt, pos2)
			task.spawn(function()
				local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
				local block = bedwars.placeBlock(pos, 'cannon')
				task.delay(0.1, function()
					local block, pos2 = getPlacedBlock(pos)
					if block and block.Name == 'cannon' and (entityLibrary.character.HumanoidRootPart.CFrame.p - block.Position).Magnitude < 20 then
						switchToAndUseTool(block)
						local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
						local damage = bedwars.BlockController:calculateBlockDamage(lplr, {
							blockPosition = pos2
						})
						bedwars.Client:Get(bedwars.CannonAimRemote):SendToServer({
							cannonBlockPos = pos2,
							lookVector = vec
						})
						local broken = 0.1
						if damage < block:GetAttribute('Health') then
							task.spawn(function()
								broken = 0.4
								bedwars.breakBlock(block.Position, true, getBestBreakSide(block.Position), true, true)
							end)
						end
						task.delay(broken, function()
							for i = 1, 3 do
								local call = bedwars.Client:Get(bedwars.CannonLaunchRemote):CallServer({cannonBlockPos = bedwars.BlockController:getBlockPosition(block.Position)})
								if call then
									bedwars.breakBlock(block.Position, true, getBestBreakSide(block.Position), true, true)
									task.delay(0.1, function()
										damagetimer = LongJumpSpeed.Value * 5
										damagetimertick = tick() + 2.5
										directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
									end)
									break
								end
								task.wait(0.1)
							end
						end)
					end
				end)
			end)
		end,
		wood_dao = function(tnt, pos2)
			task.spawn(function()
				switchItem(tnt.tool)
				if not (not lplr.Character:GetAttribute('CanDashNext') or lplr.Character:GetAttribute('CanDashNext') < workspace:GetServerTimeNow()) then
					repeat task.wait() until (not lplr.Character:GetAttribute('CanDashNext') or lplr.Character:GetAttribute('CanDashNext') < workspace:GetServerTimeNow()) or not LongJump.Enabled
				end
				if LongJump.Enabled then
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					replicatedstorage['events-@easy-games/game-core:shared/game-core-networking@getEvents.Events'].useAbility:FireServer('dash', {
						direction = vec,
						origin = entityLibrary.character.HumanoidRootPart.CFrame.p,
						weapon = tnt.itemType
					})
					damagetimer = LongJumpSpeed.Value * 3.5
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		jade_hammer = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility('jade_hammer_jump') then
					repeat task.wait() until bedwars.AbilityController:canUseAbility('jade_hammer_jump') or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility('jade_hammer_jump') and LongJump.Enabled then
					bedwars.AbilityController:useAbility('jade_hammer_jump')
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		void_axe = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility('void_axe_jump') then
					repeat task.wait() until bedwars.AbilityController:canUseAbility('void_axe_jump') or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility('void_axe_jump') and LongJump.Enabled then
					bedwars.AbilityController:useAbility('void_axe_jump')
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end
	}
	damagemethods.stone_dao = damagemethods.wood_dao
	damagemethods.iron_dao = damagemethods.wood_dao
	damagemethods.diamond_dao = damagemethods.wood_dao
	damagemethods.emerald_dao = damagemethods.wood_dao

	local oldgrav
	local LongJumpacprogressbarframe = Instance.new('Frame')
	LongJumpacprogressbarframe.AnchorPoint = Vector2.new(0.5, 0)
	LongJumpacprogressbarframe.Position = UDim2.new(0.5, 0, 1, -200)
	LongJumpacprogressbarframe.Size = UDim2.new(0.2, 0, 0, 20)
	LongJumpacprogressbarframe.BackgroundTransparency = 0.5
	LongJumpacprogressbarframe.BorderSizePixel = 0
	LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
	LongJumpacprogressbarframe.Visible = LongJump.Enabled
	LongJumpacprogressbarframe.Parent = vape.MainGui
	local LongJumpacprogressbarframe2 = LongJumpacprogressbarframe:Clone()
	LongJumpacprogressbarframe2.AnchorPoint = Vector2.new(0, 0)
	LongJumpacprogressbarframe2.Position = UDim2.new(0, 0, 0, 0)
	LongJumpacprogressbarframe2.Size = UDim2.new(1, 0, 0, 20)
	LongJumpacprogressbarframe2.BackgroundTransparency = 0
	LongJumpacprogressbarframe2.Visible = true
	LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
	LongJumpacprogressbarframe2.Parent = LongJumpacprogressbarframe
	local LongJumpacprogressbartext = Instance.new('TextLabel')
	LongJumpacprogressbartext.Text = '2.5s'
	LongJumpacprogressbartext.Font = Enum.Font.Gotham
	LongJumpacprogressbartext.TextStrokeTransparency = 0
	LongJumpacprogressbartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
	LongJumpacprogressbartext.TextSize = 20
	LongJumpacprogressbartext.Size = UDim2.new(1, 0, 1, 0)
	LongJumpacprogressbartext.BackgroundTransparency = 1
	LongJumpacprogressbartext.Position = UDim2.new(0, 0, -1, 0)
	LongJumpacprogressbartext.Parent = LongJumpacprogressbarframe
	LongJump = vape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'LongJump',
		Function = function(callback)
			if callback then
				table.insert(LongJump.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (not damageTable.knockbackMultiplier or not damageTable.knockbackMultiplier.disabled) then
						local knockbackBoost = damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal and damageTable.knockbackMultiplier.horizontal * LongJumpSpeed.Value or LongJumpSpeed.Value
						if damagetimertick < tick() or knockbackBoost >= damagetimer then
							damagetimer = knockbackBoost
							damagetimertick = tick() + 2.5
							local newDirection = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
							directionvec = Vector3.new(newDirection.X, 0, newDirection.Z).Unit
						end
					end
				end))
				task.spawn(function()
					task.spawn(function()
						repeat
							task.wait()
							if LongJumpacprogressbarframe then
								LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
								LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
							end
						until (not LongJump.Enabled)
					end)
					local LongJumpOrigin = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.Position
					local tntcheck
					for i,v in (damagemethods) do
						local item = getItem(i)
						if item then
							if i == 'tnt' then
								local pos = getScaffold(LongJumpOrigin)
								tntcheck = Vector3.new(pos.X, LongJumpOrigin.Y, pos.Z)
								v(item, pos)
							else
								v(item, LongJumpOrigin)
							end
							break
						end
					end
					local changecheck
					LongJumpacprogressbarframe.Visible = true
					RunLoops:BindToHeartbeat('LongJump', function(dt)
						if entityLibrary.isAlive then
							if entityLibrary.character.Humanoid.Health <= 0 then
								LongJump.ToggleButton(false)
								return
							end
							if not LongJumpOrigin then
								LongJumpOrigin = entityLibrary.character.HumanoidRootPart.Position
							end
							local newval = damagetimer ~= 0
							if changecheck ~= newval then
								if newval then
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 2.5, true)
								else
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
								end
								changecheck = newval
							end
							if newval then
								local newnum = math.max(math.floor((damagetimertick - tick()) * 10) / 10, 0)
								if LongJumpacprogressbartext then
									LongJumpacprogressbartext.Text = newnum..'s'
								end
								if directionvec == nil then
									directionvec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
								end
								local longJumpCFrame = Vector3.new(directionvec.X, 0, directionvec.Z)
								local newvelo = longJumpCFrame.Unit == longJumpCFrame.Unit and longJumpCFrame.Unit * (newnum > 1 and damagetimer or 20) or Vector3.zero
								newvelo = Vector3.new(newvelo.X, 0, newvelo.Z)
								longJumpCFrame = longJumpCFrame * (getSpeed() + 3) * dt
								local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, longJumpCFrame, store.raycast)
								if ray then
									longJumpCFrame = Vector3.zero
									newvelo = Vector3.zero
								end

								entityLibrary.character.HumanoidRootPart.Velocity = newvelo
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + longJumpCFrame
							else
								LongJumpacprogressbartext.Text = '2.5s'
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(LongJumpOrigin, LongJumpOrigin + entityLibrary.character.HumanoidRootPart.CFrame.lookVector)
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
								if tntcheck then
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(tntcheck + entityLibrary.character.HumanoidRootPart.CFrame.lookVector, tntcheck + (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 2))
								end
							end
						else
							if LongJumpacprogressbartext then
								LongJumpacprogressbartext.Text = '2.5s'
							end
							LongJumpOrigin = nil
							tntcheck = nil
						end
					end)
				end)
			else
				LongJumpacprogressbarframe.Visible = false
				RunLoops:UnbindFromHeartbeat('LongJump')
				directionvec = nil
				tntcheck = nil
				LongJumpOrigin = nil
				damagetimer = 0
				damagetimertick = 0
			end
		end,
		HoverText = 'Lets you jump farther (Not landing on same level & Spamming can lead to lagbacks)'
	})
	LongJumpSpeed = LongJump.CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 52,
		Function = void,
		Default = 52
	})
end)

run(function()
	local NoFall = {Enabled = false}
	local oldfall
	NoFall = vape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'NoFall',
		Function = function(callback)
			if callback then
				bedwars.Client:Get('GroundHit'):SendToServer()
			end
		end,
		HoverText = 'Prevents taking fall damage.'
	})
end)

run(function()
	local NoSlowdown = {Enabled = false}
	local OldSetSpeedFunc
	NoSlowdown = vape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'NoSlowdown',
		Function = function(callback)
			if callback then
				OldSetSpeedFunc = OldSetSpeedFunc or bedwars.SprintController.setSpeed
				bedwars.SprintController.setSpeed = function(tab1, val1)
					local hum = entityLibrary.character.Humanoid
					if hum then
						hum.WalkSpeed = math.max(20 * tab1.moveSpeedMultiplier, 20)
					end
				end
				bedwars.SprintController:setSpeed(20)
			else
				bedwars.SprintController.setSpeed = OldSetSpeedFunc
				bedwars.SprintController:setSpeed(20)
			end
		end,
		HoverText = 'Prevents slowing down when using items.'
	})
end)

local spiderActive = false
local holdingshift = false
run(function()
	local activatePhase = false
	local oldActivatePhase = false
	local PhaseDelay = tick()
	local Phase = {Enabled = false}
	local PhaseStudLimit = {Value = 1}
	local PhaseModifiedParts = {}
	local raycastparameters = RaycastParams.new()
	raycastparameters.RespectCanCollide = true
	raycastparameters.FilterType = Enum.RaycastFilterType.Whitelist
	local overlapparams = OverlapParams.new()
	overlapparams.RespectCanCollide = true

	local function isPointInMapOccupied(p)
		overlapparams.FilterDescendantsInstances = {lplr.Character, camera}
		local possible = workspace:GetPartBoundsInBox(CFrame.new(p), Vector3.new(1, 2, 1), overlapparams)
		return (#possible == 0)
	end

	Phase = vape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Phase',
		Function = function(callback)
			if callback then
				RunLoops:BindToHeartbeat('Phase', function()
					if entityLibrary.isAlive and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero and (not vape.ObjectsThatCanBeSaved.SpiderOptionsButton.Api.Enabled or holdingshift) then
						if PhaseDelay <= tick() then
							raycastparameters.FilterDescendantsInstances = {store.blocks, collection:GetTagged('spawn-cage'), workspace:FindFirstChild('SpectatorPlatform')}
							local PhaseRayCheck = workspace:Raycast(entityLibrary.character.Head.CFrame.p, entityLibrary.character.Humanoid.MoveDirection * 1.15, raycastparameters)
							if PhaseRayCheck then
								local PhaseDirection = (PhaseRayCheck.Normal.Z ~= 0 or not PhaseRayCheck.Instance:GetAttribute('GreedyBlock')) and 'Z' or 'X'
								if PhaseRayCheck.Instance.Size[PhaseDirection] <= PhaseStudLimit.Value * 3 and PhaseRayCheck.Instance.CanCollide and PhaseRayCheck.Normal.Y == 0 then
									local PhaseDestination = entityLibrary.character.HumanoidRootPart.CFrame + (PhaseRayCheck.Normal * (-(PhaseRayCheck.Instance.Size[PhaseDirection]) - (entityLibrary.character.HumanoidRootPart.Size.X / 1.5)))
									if isPointInMapOccupied(PhaseDestination.p) then
										PhaseDelay = tick() + 1
										entityLibrary.character.HumanoidRootPart.CFrame = PhaseDestination
									end
								end
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat('Phase')
			end
		end,
		HoverText = 'Lets you Phase/Clip through walls. (Hold shift to use Phase over spider)'
	})
	PhaseStudLimit = Phase.CreateSlider({
		Name = 'Blocks',
		Min = 1,
		Max = 3,
		Function = void
	})
end)

run(function()
	local oldCalculateAim
	local BowAimbotProjectiles = {Enabled = false}
	local BowAimbotPart = {Value = 'HumanoidRootPart'}
	local BowAimbotFOV = {Value = 1000}
	local BowAimbot = vape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'ProjectileAimbot',
		Function = function(callback)
			if callback then
				oldCalculateAim = bedwars.ProjectileController.calculateImportantLaunchValues
				bedwars.ProjectileController.calculateImportantLaunchValues = function(self, projmeta, worldmeta, shootpospart, ...)
					local plr = EntityNearMouse(BowAimbotFOV.Value)
					if plr then
						local startPos = self:getLaunchPosition(shootpospart)
						if not startPos then
							return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
						end

						if (not BowAimbotProjectiles.Enabled) and projmeta.projectile:find('arrow') == nil then
							return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
						end

						local projmetatab = projmeta:getProjectileMeta()
						local projectilePrediction = (worldmeta and projmetatab.predictionLifetimeSec or projmetatab.lifetimeSec or 3)
						local projectileSpeed = (projmetatab.launchVelocity or 100)
						local gravity = (projmetatab.gravitationalAcceleration or 196.2)
						local projectileGravity = gravity * projmeta.gravityMultiplier
						local offsetStartPos = startPos + projmeta.fromPositionOffset
						local pos = plr.Character[BowAimbotPart.Value].Position
						local playerGravity = workspace.Gravity
						local balloons = plr.Character:GetAttribute('InflatedBalloons')

						if balloons and balloons > 0 then
							playerGravity = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
						end

						if plr.Character.PrimaryPart:FindFirstChild('rbxassetid://8200754399') then
							playerGravity = (workspace.Gravity * 0.3)
						end

						local shootpos, shootvelo = predictGravity(pos, plr.Character.HumanoidRootPart.Velocity, (pos - offsetStartPos).Magnitude / projectileSpeed, plr, playerGravity)
						if projmeta.projectile == 'telepearl' then
							shootpos = pos
							shootvelo = Vector3.zero
						end

						local newlook = CFrame.new(offsetStartPos, shootpos)
						shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
						local calculated = LaunchDirection(offsetStartPos, shootpos, projectileSpeed, projectileGravity, false)
						oldmove = plr.Character.Humanoid.MoveDirection
						if calculated then
							return {
								initialVelocity = calculated,
								positionFrom = offsetStartPos,
								deltaT = projectilePrediction,
								gravitationalAcceleration = projectileGravity,
								drawDurationSeconds = 5
							}
						end
					end
					return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
				end
			else
				bedwars.ProjectileController.calculateImportantLaunchValues = oldCalculateAim
			end
		end
	})
	BowAimbotPart = BowAimbot.CreateDropdown({
		Name = 'Part',
		List = {'HumanoidRootPart', 'Head'},
		Function = void
	})
	BowAimbotFOV = BowAimbot.CreateSlider({
		Name = 'FOV',
		Function = void,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
	BowAimbotProjectiles = BowAimbot.CreateToggle({
		Name = 'Other Projectiles',
		Function = void,
		Default = true
	})
end)

local Scaffold = {Enabled = false}
run(function()
	local scaffoldtext = Instance.new('TextLabel')
	scaffoldtext.Font = Enum.Font.SourceSans
	scaffoldtext.TextSize = 20
	scaffoldtext.BackgroundTransparency = 1
	scaffoldtext.TextColor3 = Color3.fromRGB(255, 0, 0)
	scaffoldtext.Size = UDim2.new(0, 0, 0, 0)
	scaffoldtext.Position = UDim2.new(0.5, 0, 0.5, 30)
	scaffoldtext.Text = '0'
	scaffoldtext.Visible = false
	scaffoldtext.Parent = vape.MainGui
	local ScaffoldExpand = {Value = 1}
	local ScaffoldDiagonal = {Enabled = false}
	local ScaffoldTower = {Enabled = false}
	local ScaffoldDownwards = {Enabled = false}
	local ScaffoldStopMotion = {Enabled = false}
	local ScaffoldBlockCount = {Enabled = false}
	local ScaffoldHandCheck = {Enabled = false}
	local ScaffoldMouseCheck = {Enabled = false}
	local ScaffoldAnimation = {Enabled = false}
	local ScaffoldHighlight = {};
	local ScaffoldHighlightInvis = {Value = 1};
	local ScaffoldHighlightTweenSpeed = {Value = 8};
	local ScaffoldHighlightColor = newcolor();
	local scaffoldstopmotionval = false
	local scaffoldposcheck = tick()
	local scaffoldstopmotionpos = Vector3.zero
	local scaffoldposchecklist = {};
	local scaffoldlasthighlight;
	task.spawn(function()
		for x = -3, 3, 3 do
			for y = -3, 3, 3 do
				for z = -3, 3, 3 do
					if Vector3.new(x, y, z) ~= Vector3.new(0, 0, 0) then
						table.insert(scaffoldposchecklist, Vector3.new(x, y, z))
					end
				end
			end
		end
	end)

	local function checkblocks(pos)
		for i,v in (scaffoldposchecklist) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function closestpos(block, pos)
		local startpos = block.Position - (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local speedCFrame = block.Position + (pos - block.Position)
		return Vector3.new(math.clamp(speedCFrame.X, startpos.X, endpos.X), math.clamp(speedCFrame.Y, startpos.Y, endpos.Y), math.clamp(speedCFrame.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag, pos)
		local closest, closestmag = pos, newmag * 3
		if entityLibrary.isAlive then
			for i,v in (store.blocks) do
				local close = closestpos(v, pos)
				local mag = (close - pos).magnitude
				if mag <= closestmag then
					closest = close
					closestmag = mag
				end
			end
		end
		return closest
	end

	local processhighlight = function(block: Part): ()
		if not ScaffoldHighlight.Enabled then 
			return;
		end;
		if block:GetAttribute('PlacedByUserId') ~= lplr.UserId then 
			return;
		end;
		if scaffoldlasthighlight then 
			local oldhighlight: Highlight = scaffoldlasthighlight;
			local fade: Tween = tween:Create(oldhighlight, TweenInfo.new(0.1 * ScaffoldHighlightTweenSpeed.Value), {FillTransparency = 1});
			fade:Play();
			fade.Completed:Once(function()
				oldhighlight:Destroy();
			end);
		end;
		local highlight: Highlight = Instance.new('Highlight', block);
		highlight.FillColor = Color3.fromHSV(ScaffoldHighlightColor.Hue, ScaffoldHighlightColor.Sat, ScaffoldHighlightColor.Value);
		highlight.FillTransparency = 0.1 * ScaffoldHighlightInvis.Value;
		highlight.OutlineTransparency = 1;
		highlight.Adornee = block;
		scaffoldlasthighlight = highlight;
		task.delay((0.1 * ScaffoldHighlightTweenSpeed.Value) + 0.2, function()
			if highlight.Parent == nil then 
				return;
			end;
			local fade: Tween = tween:Create(highlight, TweenInfo.new(0.1 * ScaffoldHighlightTweenSpeed.Value), {FillTransparency = 1});
			fade:Play()
			fade.Completed:Wait();
			if scaffoldlasthighlight == highlight then 
				scaffoldlasthighlight = nil;
			end;
			highlight:Destroy();
		end);
	end;

	local oldspeed
	Scaffold = vape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Scaffold',
		Function = function(callback)
			if callback then
				scaffoldtext.Visible = ScaffoldBlockCount.Enabled
				if entityLibrary.isAlive then
					scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
				end;
				table.insert(Scaffold.Connections, collection:GetInstanceAddedSignal('block'):Connect(processhighlight));
				task.spawn(function()
					repeat
						task.wait()
						if ScaffoldHandCheck.Enabled then
							if store.localHand.Type ~= 'block' then continue end
						end
						if ScaffoldMouseCheck.Enabled then
							if not inputservice:IsMouseButtonPressed(0) then continue end
						end
						if entityLibrary.isAlive then
							local wool, woolamount = getWool()
							if store.localHand.Type == 'block' then
								wool = store.localHand.tool.Name
								woolamount = getItem(store.localHand.tool.Name).amount or 0
							elseif (not wool) then
								wool, woolamount = getBlock()
							end

							scaffoldtext.Text = (woolamount and tostring(woolamount) or '0')
							scaffoldtext.TextColor3 = woolamount and (woolamount >= 128 and Color3.fromRGB(9, 255, 198) or woolamount >= 64 and Color3.fromRGB(255, 249, 18)) or Color3.fromRGB(255, 0, 0)
							if not wool then continue end

							local towering = ScaffoldTower.Enabled and inputservice:IsKeyDown(Enum.KeyCode.Space) and inputservice:GetFocusedTextBox() == nil
							if towering then
								if (not scaffoldstopmotionval) and ScaffoldStopMotion.Enabled then
									scaffoldstopmotionval = true
									scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
								end
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 28, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								if ScaffoldStopMotion.Enabled and scaffoldstopmotionval then
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(scaffoldstopmotionpos.X, entityLibrary.character.HumanoidRootPart.CFrame.p.Y, scaffoldstopmotionpos.Z))
								end
							else
								scaffoldstopmotionval = false
							end

							for i = 1, ScaffoldExpand.Value do
								local speedCFrame = getScaffold((entityLibrary.character.HumanoidRootPart.Position + ((scaffoldstopmotionval and Vector3.zero or entityLibrary.character.Humanoid.MoveDirection) * (i * 3.5))) + Vector3.new(0, -((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight + (inputservice:IsKeyDown(Enum.KeyCode.LeftShift) and ScaffoldDownwards.Enabled and 4.5 or 1.5))), 0)
								speedCFrame = Vector3.new(speedCFrame.X, speedCFrame.Y - (towering and 4 or 0), speedCFrame.Z)
								if speedCFrame ~= oldpos then
									if not checkblocks(speedCFrame) then
										local oldspeedCFrame = speedCFrame
										speedCFrame = getScaffold(getclosesttop(20, speedCFrame))
										if getPlacedBlock(speedCFrame) then speedCFrame = oldspeedCFrame end
									end
									if ScaffoldAnimation.Enabled then
										if not getPlacedBlock(speedCFrame) then
										bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
										end
									end
									task.spawn(bedwars.placeBlock, speedCFrame, wool, ScaffoldAnimation.Enabled)
									if ScaffoldExpand.Value > 1 then
										task.wait()
									end
									oldpos = speedCFrame
								end
							end
						end
					until (not Scaffold.Enabled)
				end)
			else
				scaffoldtext.Visible = false
				oldpos = Vector3.zero
				oldpos2 = Vector3.zero
			end
		end,
		HoverText = 'Helps you make bridges/scaffold walk.'
	})
	ScaffoldExpand = Scaffold.CreateSlider({
		Name = 'Expand',
		Min = 1,
		Max = 8,
		Function = function(val) end,
		Default = 1,
		HoverText = 'Build range'
	})
	ScaffoldDiagonal = Scaffold.CreateToggle({
		Name = 'Diagonal',
		Function = function(callback) end,
		Default = true
	})
	ScaffoldTower = Scaffold.CreateToggle({
		Name = 'Tower',
		Function = function(callback)
			if ScaffoldStopMotion.Object then
				ScaffoldTower.Object.ToggleArrow.Visible = callback
				ScaffoldStopMotion.Object.Visible = callback
			end
		end
	})
	ScaffoldMouseCheck = Scaffold.CreateToggle({
		Name = 'Require mouse down',
		Function = function(callback) end,
		HoverText = 'Only places when left click is held.',
	})
	ScaffoldDownwards  = Scaffold.CreateToggle({
		Name = 'Downwards',
		Function = function(callback) end,
		HoverText = 'Goes down when left shift is held.'
	})
	ScaffoldStopMotion = Scaffold.CreateToggle({
		Name = 'Stop Motion',
		Function = void,
		HoverText = 'Stops your movement when going up'
	})
	ScaffoldStopMotion.Object.BackgroundTransparency = 0
	ScaffoldStopMotion.Object.BorderSizePixel = 0
	ScaffoldStopMotion.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ScaffoldStopMotion.Object.Visible = ScaffoldTower.Enabled
	ScaffoldBlockCount = Scaffold.CreateToggle({
		Name = 'Block Count',
		Function = function(callback)
			if Scaffold.Enabled then
				scaffoldtext.Visible = callback
			end
		end,
		HoverText = 'Shows the amount of blocks in the middle.'
	})
	ScaffoldHandCheck = Scaffold.CreateToggle({
		Name = 'Whitelist Only',
		Function = void,
		HoverText = 'Only builds with blocks in your hand.'
	})
	ScaffoldAnimation = Scaffold.CreateToggle({
		Name = 'Animation',
		Function = void
	});
	ScaffoldHighlight = Scaffold.CreateToggle({
		Name = 'Highlight',
		Function = function(calling: boolean): ()
			ScaffoldHighlightColor.Object.Visible = calling;
			ScaffoldHighlightInvis.Object.Visible = calling;
			ScaffoldHighlightTweenSpeed.Object.Visible = calling;
		end
	});
	ScaffoldHighlightColor = Scaffold.CreateColorSlider({
		Name = 'Color',
		Function = function(): ()
			if scaffoldlasthighlight then 
				scaffoldlasthighlight.FillColor = Color3.fromHSV(ScaffoldHighlightColor.Hue, ScaffoldHighlightColor.Sat, ScaffoldHighlightColor.Value);
			end;
		end
	});
	ScaffoldHighlightInvis = Scaffold.CreateSlider({
		Name = 'Transparency',
		Min = 0,
		Max = 9,
		Default = 4,
		Function = void
	});
	ScaffoldHighlightTweenSpeed = Scaffold.CreateSlider({
		Name = 'Fade Delay',
		Min = 0,
		Max = 9,
		Default = 4,
		Function = void
	});
	ScaffoldHighlightColor.Object.Visible = false;
	ScaffoldHighlightInvis.Object.Visible = false;
	ScaffoldHighlightTweenSpeed.Object.Visible = false;
end);

local antivoidvelo
run(function()
	local Speed = {Enabled = false}
	local SpeedMode = {Value = 'CFrame'}
	local SpeedValue = {Value = 1}
	local SpeedValueLarge = {Value = 1}
	local SpeedJump = {Enabled = false}
	local SpeedJumpHeight = {Value = 20}
	local SpeedJumpAlways = {Enabled = false}
	local SpeedJumpSound = {Enabled = false}
	local SpeedJumpVanilla = {Enabled = false}
	local SpeedAnimation = {Enabled = false}
	local raycastparameters = RaycastParams.new()

	local alternatelist = {'Normal', 'AntiCheat A', 'AntiCheat B'}
	Speed = vape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Speed',
		Function = function(callback)
			if callback then
				RunLoops:BindToHeartbeat('Speed', function(delta)
					if vape.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then
						if store.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						if not (isnetworkowner(entityLibrary.character.HumanoidRootPart) and entityLibrary.character.Humanoid:GetState() ~= Enum.HumanoidStateType.Climbing and (not spiderActive) and (not vape.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled) and (not vape.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled)) then return end
						if vape.ObjectsThatCanBeSaved.GrappleExploitOptionsButton and vape.ObjectsThatCanBeSaved.GrappleExploitOptionsButton.Api.Enabled then return end
						if LongJump.Enabled then return end
						if SpeedAnimation.Enabled then
							for i, v in (entityLibrary.character.Humanoid:GetPlayingAnimationTracks()) do
								if v.Name == 'WalkAnim' or v.Name == 'RunAnim' then
									v:AdjustSpeed(entityLibrary.character.Humanoid.WalkSpeed / 16)
								end
							end
						end

						local speedValue = SpeedValue.Value + getSpeed()
						local speedVelocity = entityLibrary.character.Humanoid.MoveDirection * (SpeedMode.Value == 'Normal' and SpeedValue.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = antivoidvelo or Vector3.new(speedVelocity.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, speedVelocity.Z)
						if SpeedMode.Value ~= 'Normal' then
							local speedCFrame = entityLibrary.character.Humanoid.MoveDirection * (speedValue - 20) * delta
							raycastparameters.FilterDescendantsInstances = {lplr.Character}
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, speedCFrame, raycastparameters)
							if ray then speedCFrame = (ray.Position - entityLibrary.character.HumanoidRootPart.Position) end
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + speedCFrame
						end

						if SpeedJump.Enabled and (not Scaffold.Enabled) and (SpeedJumpAlways.Enabled or killauraNearPlayer) then
							if (entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air) and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero then
								if SpeedJumpSound.Enabled then
									pcall(function() entityLibrary.character.HumanoidRootPart.Jumping:Play() end)
								end
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
				RunLoops:UnbindFromHeartbeat('Speed')
			end
		end,
		HoverText = 'Increases your movement.',
		ExtraText = function()
			return 'Heatseeker'
		end
	})
	SpeedValue = Speed.CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	SpeedValueLarge = Speed.CreateSlider({
		Name = 'Big Mode Speed',
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	SpeedJump = Speed.CreateToggle({
		Name = 'AutoJump',
		Function = function(callback)
			if SpeedJumpHeight.Object then SpeedJumpHeight.Object.Visible = callback end
			if SpeedJumpAlways.Object then
				SpeedJump.Object.ToggleArrow.Visible = callback
				SpeedJumpAlways.Object.Visible = callback
			end
			if SpeedJumpSound.Object then SpeedJumpSound.Object.Visible = callback end
			if SpeedJumpVanilla.Object then SpeedJumpVanilla.Object.Visible = callback end
		end,
		Default = true
	})
	SpeedJumpHeight = Speed.CreateSlider({
		Name = 'Jump Height',
		Min = 0,
		Max = 30,
		Default = 25,
		Function = void
	})
	SpeedJumpAlways = Speed.CreateToggle({
		Name = 'Always Jump',
		Function = void
	})
	SpeedJumpSound = Speed.CreateToggle({
		Name = 'Jump Sound',
		Function = void
	})
	SpeedJumpVanilla = Speed.CreateToggle({
		Name = 'Real Jump',
		Function = void
	})
	SpeedAnimation = Speed.CreateToggle({
		Name = 'Slowdown Anim',
		Function = void
	})
end)

run(function()
	local function roundpos(dir, pos, size)
		local suc, res = pcall(function() return Vector3.new(math.clamp(dir.X, pos.X - (size.X / 2), pos.X + (size.X / 2)), math.clamp(dir.Y, pos.Y - (size.Y / 2), pos.Y + (size.Y / 2)), math.clamp(dir.Z, pos.Z - (size.Z / 2), pos.Z + (size.Z / 2))) end)
		return suc and res or Vector3.zero
	end

	local Spider = {Enabled = false}
	local SpiderSpeed = {Value = 0}
	local SpiderMode = {Value = 'Normal'}
	local SpiderPart
	Spider = vape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Spider',
		Function = function(callback)
			if callback then
				table.insert(Spider.Connections, inputservice.InputBegan:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then
						holdingshift = true
					end
				end))
				table.insert(Spider.Connections, inputservice.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then
						holdingshift = false
					end
				end))
				RunLoops:BindToHeartbeat('Spider', function()
					if entityLibrary.isAlive and (vape.ObjectsThatCanBeSaved.PhaseOptionsButton.Api.Enabled == false or holdingshift == false) then
						if SpiderMode.Value == 'Normal' then
							local vec = entityLibrary.character.Humanoid.MoveDirection * 2
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec + Vector3.new(0, 0.1, 0)))
							local newray2 = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)))
							if newray and (not newray.CanCollide) then newray = nil end
							if newray2 and (not newray2.CanCollide) then newray2 = nil end
							if spiderActive and (not newray) and (not newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 0, entityLibrary.character.HumanoidRootPart.Velocity.Z)
							end
							spiderActive = ((newray or newray2) and true or false)
							if (newray or newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.X or 0, SpiderSpeed.Value, newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.Z or 0)
							end
						else
							if not SpiderPart then
								SpiderPart = Instance.new('TrussPart')
								SpiderPart.Size = Vector3.new(2, 2, 2)
								SpiderPart.Transparency = 1
								SpiderPart.Anchored = true
								SpiderPart.Parent = camera
							end
							local newray2, newray2pos = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + ((entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 1.5) - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)))
							if newray2 and (not newray2.CanCollide) then newray2 = nil end
							spiderActive = (newray2 and true or false)
							if newray2 then
								newray2pos = newray2pos * 3
								local newpos = roundpos(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(newray2pos.X, math.min(entityLibrary.character.HumanoidRootPart.Position.Y, newray2pos.Y), newray2pos.Z), Vector3.new(1.1, 1.1, 1.1))
								SpiderPart.Position = newpos
							else
								SpiderPart.Position = Vector3.zero
							end
						end
					end
				end)
			else
				if SpiderPart then SpiderPart:Destroy() end
				RunLoops:UnbindFromHeartbeat('Spider')
				holdingshift = false
			end
		end,
		HoverText = 'Lets you climb up walls'
	})
	SpiderMode = Spider.CreateDropdown({
		Name = 'Mode',
		List = {'Normal', 'Classic'},
		Function = function()
			if SpiderPart then SpiderPart:Destroy() end
		end
	})
	SpiderSpeed = Spider.CreateSlider({
		Name = 'Speed',
		Min = 0,
		Max = 40,
		Function = void,
		Default = 40
	})
end)

run(function()
	local TargetStrafe = {Enabled = false}
	local TargetStrafeRange = {Value = 18}
	local oldmove
	local controlmodule
	local block
	TargetStrafe = vape.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'TargetStrafe',
		Function = function(callback)
			if callback then
				task.spawn(function()
					if not controlmodule then
						local suc = pcall(function() controlmodule = require(lplr.PlayerScripts.PlayerModule).controls end)
						if not suc then controlmodule = {} end
					end
					oldmove = controlmodule.moveFunction
					local ang = 0
					local oldplr
					block = Instance.new('Part')
					block.Anchored = true
					block.CanCollide = false
					block.Parent = camera
					controlmodule.moveFunction = function(Self, vec, facecam, ...)
						if entityLibrary.isAlive then
							local plr = AllNearPosition(TargetStrafeRange.Value + 5, 10)[1]
							plr = plr and (not workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, (plr.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position), store.raycast)) and workspace:Raycast(plr.RootPart.Position, Vector3.new(0, -70, 0), store.raycast) and plr or nil
							if plr ~= oldplr then
								if plr then
									local x, y, z = CFrame.new(plr.RootPart.Position, entityLibrary.character.HumanoidRootPart.Position):ToEulerAnglesXYZ()
									ang = math.deg(z)
								end
								oldplr = plr
							end
							if plr then
								facecam = false
								local localPos = CFrame.new(plr.RootPart.Position)
								local ray = workspace:Blockcast(localPos, Vector3.new(3, 3, 3), CFrame.Angles(0, math.rad(ang), 0).lookVector * TargetStrafeRange.Value, store.raycast)
								local newPos = localPos + (CFrame.Angles(0, math.rad(ang), 0).lookVector * (ray and ray.Distance - 1 or TargetStrafeRange.Value))
								local factor = getSpeed() > 0 and 6 or 4
								if not workspace:Raycast(newPos.p, Vector3.new(0, -70, 0), store.raycast) then
									newPos = localPos
									factor = 40
								end
								if ((entityLibrary.character.HumanoidRootPart.Position * Vector3.new(1, 0, 1)) - (newPos.p * Vector3.new(1, 0, 1))).Magnitude < 4 or ray then
									ang = ang + factor % 360
								end
								block.Position = newPos.p
								vec = (newPos.p - entityLibrary.character.HumanoidRootPart.Position) * Vector3.new(1, 0, 1)
							end
						end
						return oldmove(Self, vec, facecam, ...)
					end
				end)
			else
				block:Destroy()
				controlmodule.moveFunction = oldmove
			end
		end
	})
	TargetStrafeRange = TargetStrafe.CreateSlider({
		Name = 'Range',
		Min = 0,
		Max = 18,
		Function = void
	})
end)

run(function()
	local BedESP = {Enabled = false}
	local BedESPFolder = Instance.new('Folder')
	BedESPFolder.Name = 'BedESPFolder'
	BedESPFolder.Parent = vape.MainGui
	local BedESPTable = {}
	local BedESPColor = {Value = 0.44}
	local BedESPTransparency = {Value = 1}
	local BedESPOnTop = {Enabled = true}
	BedESP = vape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'BedESP',
		Function = function(callback)
			if callback then
				table.insert(BedESP.Connections, collection:GetInstanceAddedSignal('bed'):Connect(function(bed)
					task.wait(0.2)
					if not BedESP.Enabled then return end
					local BedFolder = Instance.new('Folder')
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in (bed:GetChildren()) do
						if bedesppart.Name ~= 'Bed' then continue end
						local boxhandle = Instance.new('BoxHandleAdornment')
						boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
						boxhandle.AlwaysOnTop = true
						boxhandle.ZIndex = (bedesppart.Name == 'Covers' and 10 or 0)
						boxhandle.Visible = true
						boxhandle.Adornee = bedesppart
						boxhandle.Color3 = bedesppart.Color
						boxhandle.Name = bedespnumber
						boxhandle.Parent = BedFolder
					end
				end))
				table.insert(BedESP.Connections, collection:GetInstanceRemovedSignal('bed'):Connect(function(bed)
					if BedESPTable[bed] then
						BedESPTable[bed]:Destroy()
						BedESPTable[bed] = nil
					end
				end))
				for i, bed in (collection:GetTagged('bed')) do
					local BedFolder = Instance.new('Folder')
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in (bed:GetChildren()) do
						if bedesppart:IsA('BasePart') then
							local boxhandle = Instance.new('BoxHandleAdornment')
							boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
							boxhandle.AlwaysOnTop = true
							boxhandle.ZIndex = (bedesppart.Name == 'Covers' and 10 or 0)
							boxhandle.Visible = true
							boxhandle.Adornee = bedesppart
							boxhandle.Color3 = bedesppart.Color
							boxhandle.Parent = BedFolder
						end
					end
				end
			else
				BedESPFolder:ClearAllChildren()
				table.clear(BedESPTable)
			end
		end,
		HoverText = 'Render Beds through walls'
	})
end)

run(function()
	local function getallblocks2(pos, normal)
		local blocks = {}
		local lastfound = nil
		for i = 1, 20 do
			local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
			local extrablock = getPlacedBlock(blockpos)
			local covered = true
			if extrablock and extrablock.Parent ~= nil then
				if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) then
					table.insert(blocks, extrablock:GetAttribute('NoBreak') and 'unbreakable' or extrablock.Name)
				else
					table.insert(blocks, 'unbreakable')
					break
				end
				lastfound = extrablock
				if covered == false then
					break
				end
			else
				break
			end
		end
		return blocks
	end

	local function getallbedblocks(pos)
		local blocks = {}
		for i,v in (cachedNormalSides) do
			for i2,v2 in (getallblocks2(pos, v)) do
				if table.find(blocks, v2) == nil and v2 ~= 'bed' then
					table.insert(blocks, v2)
				end
			end
			for i2,v2 in (getallblocks2(pos + Vector3.new(0, 0, 3), v)) do
				if table.find(blocks, v2) == nil and v2 ~= 'bed' then
					table.insert(blocks, v2)
				end
			end
		end
		return blocks
	end

	local function refreshAdornee(v)
		local bedblocks = getallbedblocks(v.Adornee.Position)
		for i2,v2 in (v.Frame:GetChildren()) do
			if v2:IsA('ImageLabel') then
				v2:Remove()
			end
		end
		for i3,v3 in (bedblocks) do
			local blockimage = Instance.new('ImageLabel')
			blockimage.Size = UDim2.new(0, 32, 0, 32)
			blockimage.BackgroundTransparency = 1
			blockimage.Image = bedwars.getIcon({itemType = v3}, true)
			blockimage.Parent = v.Frame
		end
	end

	local BedPlatesFolder = Instance.new('Folder')
	BedPlatesFolder.Name = 'BedPlatesFolder'
	BedPlatesFolder.Parent = vape.MainGui
	local BedPlatesTable = {}
	local BedPlates = {Enabled = false}

	local function addBed(v)
		local billboard = Instance.new('BillboardGui')
		billboard.Parent = BedPlatesFolder
		billboard.Name = 'bed'
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 42, 0, 42)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		BedPlatesTable[v] = billboard
		local frame = Instance.new('Frame')
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BackgroundTransparency = 0.5
		frame.Parent = billboard
		local uilistlayout = Instance.new('UIListLayout')
		uilistlayout.FillDirection = Enum.FillDirection.Horizontal
		uilistlayout.Padding = UDim.new(0, 4)
		uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uilistlayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
		end)
		uilistlayout.Parent = frame
		local uicorner = Instance.new('UICorner')
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = frame
		refreshAdornee(billboard)
	end

	BedPlates = vape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'BedPlates',
		Function = function(callback)
			if callback then
				table.insert(BedPlates.Connections, vapeEvents.PlaceBlockEvent.Event:Connect(function(p5)
					for i, v in (BedPlatesFolder:GetChildren()) do
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				table.insert(BedPlates.Connections, vapeEvents.BreakBlockEvent.Event:Connect(function(p5)
					for i, v in (BedPlatesFolder:GetChildren()) do
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				table.insert(BedPlates.Connections, collection:GetInstanceAddedSignal('bed'):Connect(function(v)
					addBed(v)
				end))
				table.insert(BedPlates.Connections, collection:GetInstanceRemovedSignal('bed'):Connect(function(v)
					if BedPlatesTable[v] then
						BedPlatesTable[v]:Destroy()
						BedPlatesTable[v] = nil
					end
				end))
				for i, v in (collection:GetTagged('bed')) do
					addBed(v)
				end
			else
				BedPlatesFolder:ClearAllChildren()
			end
		end
	})
end)

run(function()
	local ChestESPList = {ObjectList = {}, RefreshList = void}
	local function nearchestitem(item)
		for i,v in (ChestESPList.ObjectList) do
			if item:find(v) then return v end
		end
	end
	local function refreshAdornee(v)
		local chest = v:FindFirstChild('ChestFolderValue')
		chest = chest and chest.Value or nil
		if not chest then return end
		local chestitems = chest and chest:GetChildren() or {}
		for i2,v2 in (v.Frame:GetChildren()) do
			if v2:IsA('ImageLabel') then
				v2:Remove()
			end
		end
		v.Enabled = false
		local alreadygot = {}
		for itemNumber, item in (chestitems) do
			if alreadygot[item.Name] == nil and (table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name)) then
				alreadygot[item.Name] = true
				v.Enabled = true
				local blockimage = Instance.new('ImageLabel')
				blockimage.Size = UDim2.new(0, 32, 0, 32)
				blockimage.BackgroundTransparency = 1
				blockimage.Image = bedwars.getIcon({itemType = item.Name}, true)
				blockimage.Parent = v.Frame
			end
		end
	end

	local ChestESPFolder = Instance.new('Folder')
	ChestESPFolder.Name = 'ChestESPFolder'
	ChestESPFolder.Parent = vape.MainGui
	local ChestESP = {Enabled = false}
	local ChestESPBackground = {Enabled = true}

	local function chestfunc(v)
		task.spawn(function()
			local chest = v:FindFirstChild('ChestFolderValue')
			chest = chest and chest.Value or nil
			if not chest then return end
			local billboard = Instance.new('BillboardGui')
			billboard.Parent = ChestESPFolder
			billboard.Name = 'chest'
			billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
			billboard.Size = UDim2.new(0, 42, 0, 42)
			billboard.AlwaysOnTop = true
			billboard.Adornee = v
			local frame = Instance.new('Frame')
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BackgroundTransparency = ChestESPBackground.Enabled and 0.5 or 1
			frame.Parent = billboard
			local uilistlayout = Instance.new('UIListLayout')
			uilistlayout.FillDirection = Enum.FillDirection.Horizontal
			uilistlayout.Padding = UDim.new(0, 4)
			uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uilistlayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
				billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
			end)
			uilistlayout.Parent = frame
			local uicorner = Instance.new('UICorner')
			uicorner.CornerRadius = UDim.new(0, 4)
			uicorner.Parent = frame
			if chest then
				table.insert(ChestESP.Connections, chest.ChildAdded:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then
						refreshAdornee(billboard)
					end
				end))
				table.insert(ChestESP.Connections, chest.ChildRemoved:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then
						refreshAdornee(billboard)
					end
				end))
				refreshAdornee(billboard)
			end
		end)
	end

	ChestESP = vape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'ChestESP',
		Function = function(callback)
			if callback then
				task.spawn(function()
					table.insert(ChestESP.Connections, collection:GetInstanceAddedSignal('chest'):Connect(chestfunc))
					for i,v in (collection:GetTagged('chest')) do chestfunc(v) end
				end)
			else
				ChestESPFolder:ClearAllChildren()
			end
		end
	})
	ChestESPList = ChestESP.CreateTextList({
		Name = 'ItemList',
		TempText = 'item or part of item',
		AddFunction = function()
			if ChestESP.Enabled then
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end,
		RemoveFunction = function()
			if ChestESP.Enabled then
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end
	})
	ChestESPBackground = ChestESP.CreateToggle({
		Name = 'Background',
		Function = function()
			if ChestESP.Enabled then
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end,
		Default = true
	})
end)

run(function()
	local FieldOfViewValue = {Value = 70}
	local oldfov
	local oldfov2
	local FieldOfView = {Enabled = false}
	local FieldOfViewZoom = {Enabled = false}
	FieldOfView = vape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'FOVChanger',
		Function = function(callback)
			if callback then
				if FieldOfViewZoom.Enabled then
					task.spawn(function()
						repeat
							task.wait()
						until not inputservice:IsKeyDown(Enum.KeyCode[FieldOfView.Keybind ~= '' and FieldOfView.Keybind or 'C'])
						if FieldOfView.Enabled then
							FieldOfView.ToggleButton(false)
						end
					end)
				end
				oldfov = bedwars.FovController.setFOV
				oldfov2 = bedwars.FovController.getFOV
				bedwars.FovController.setFOV = function(self, fov) return oldfov(self, FieldOfViewValue.Value) end
				bedwars.FovController.getFOV = function(self, fov) return FieldOfViewValue.Value end
			else
				bedwars.FovController.setFOV = oldfov
				bedwars.FovController.getFOV = oldfov2
			end
			bedwars.FovController:setFOV(bedwars.ClientStoreHandler:getState().Settings.fov)
		end
	})
	FieldOfViewValue = FieldOfView.CreateSlider({
		Name = 'FOV',
		Min = 30,
		Max = 120,
		Function = function(val)
			if FieldOfView.Enabled then
				bedwars.FovController:setFOV(bedwars.ClientStoreHandler:getState().Settings.fov)
			end
		end
	})
	FieldOfViewZoom = FieldOfView.CreateToggle({
		Name = 'Zoom',
		Function = void,
		HoverText = 'optifine zoom lol'
	})
end)

--[[run(function()
	local old
	local old2
	local oldhitpart
	local FPSBoost = {Enabled = false}
	local removetextures = {Enabled = false}
	local removetexturessmooth = {Enabled = false}
	local fpsboostdamageindicator = {Enabled = false}
	local fpsboostdamageeffect = {Enabled = false}
	local fpsboostkilleffect = {Enabled = false}
	local originaltextures = {}
	local originaleffects = {}

	local function fpsboosttextures()
		task.spawn(function()
			repeat task.wait() until store.matchState ~= 0
			for i,v in (store.blocks) do
				if v:GetAttribute('PlacedByUserId') == 0 then
					v.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find('glass') and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
					originaltextures[v] = originaltextures[v] or v.MaterialVariant
					v.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and '' or originaltextures[v]
					for i2,v2 in (v:GetChildren()) do
						pcall(function()
							v2.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find('glass') and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
							originaltextures[v2] = originaltextures[v2] or v2.MaterialVariant
							v2.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and '' or originaltextures[v2]
						end)
					end
				end
			end
		end)
	end

	FPSBoost = vape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'FPSBoost',
		Function = function(callback)
			local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
			if callback then
				wasenabled = true
				fpsboosttextures()
				if fpsboostdamageindicator.Enabled then
					damagetab.strokeThickness = 0
					damagetab.textSize = 0
					damagetab.blowUpDuration = 0
					damagetab.blowUpSize = 0
				end
				if fpsboostkilleffect.Enabled then
					for i,v in (bedwars.KillEffectController.killEffects) do
						originaleffects[i] = v
						bedwars.KillEffectController.killEffects[i] = {new = function(char) return {onKill = void, isPlayDefaultKillEffect = function() return char == lplr.Character end} end}
					end
				end
				if fpsboostdamageeffect.Enabled then
					oldhitpart = bedwars.DamageIndicatorController.hitEffectPart
					bedwars.DamageIndicatorController.hitEffectPart = nil
				end
				old = bedwars.EntityHighlightController.highlight
				old2 = getmetatable(bedwars.StopwatchController).tweenOutGhost
				local highlighttable = {}
				getmetatable(bedwars.StopwatchController).tweenOutGhost = function(p17, p18)
					p18:Destroy()
				end
				bedwars.EntityHighlightController.highlight = void
			else
				for i,v in (originaleffects) do
					bedwars.KillEffectController.killEffects[i] = v
				end
				fpsboosttextures()
				if oldhitpart then
					bedwars.DamageIndicatorController.hitEffectPart = oldhitpart
				end
				debug.setupvalue(bedwars.KillEffectController.KnitStart, 2, require(lplr.PlayerScripts.TS['client-sync-events']).ClientSyncEvents)
				damagetab.strokeThickness = 1.5
				damagetab.textSize = 28
				damagetab.blowUpDuration = 0.125
				damagetab.blowUpSize = 76
				debug.setupvalue(bedwars.DamageIndicator, 10, tween)
				if bedwars.DamageIndicatorController.hitEffectPart then
					bedwars.DamageIndicatorController.hitEffectPart.Attachment.Cubes.Enabled = true
					bedwars.DamageIndicatorController.hitEffectPart.Attachment.Shards.Enabled = true
				end
				bedwars.EntityHighlightController.highlight = old
				getmetatable(bedwars.StopwatchController).tweenOutGhost = old2
				old = nil
				old2 = nil
			end
		end
	})
	removetextures = FPSBoost.CreateToggle({
		Name = 'Remove Textures',
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostdamageindicator = FPSBoost.CreateToggle({
		Name = 'Remove Damage Indicator',
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostdamageeffect = FPSBoost.CreateToggle({
		Name = 'Remove Damage Effect',
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostkilleffect = FPSBoost.CreateToggle({
		Name = 'Remove Kill Effect',
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
end)]]

run(function()
	local GameFixer = {Enabled = false}
	local GameFixerHit = {Enabled = false}
	GameFixer = vape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'GameFixer',
		Function = function(callback)
			debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, callback and 'raycast' or 'Raycast')
			debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, callback and bedwars.QueryUtil or workspace)
		end,
		HoverText = 'Fixes game bugs'
	})
end)

run(function()
	local transformed = false
	local GameTheme = {Enabled = false}
	local GameThemeMode = {Value = 'GameTheme'}

	local themefunctions = {
		Old = function()
			task.spawn(function()
				local oldbedwarstabofimages = '{"clay_orange":"rbxassetid://7017703219","iron":"rbxassetid://6850537969","glass":"rbxassetid://6909521321","log_spruce":"rbxassetid://6874161124","ice":"rbxassetid://6874651262","marble":"rbxassetid://6594536339","zipline_base":"rbxassetid://7051148904","iron_helmet":"rbxassetid://6874272559","marble_pillar":"rbxassetid://6909323822","clay_dark_green":"rbxassetid://6763635916","wood_plank_birch":"rbxassetid://6768647328","watering_can":"rbxassetid://6915423754","emerald_helmet":"rbxassetid://6931675766","pie":"rbxassetid://6985761399","wood_plank_spruce":"rbxassetid://6768615964","diamond_chestplate":"rbxassetid://6874272898","wool_pink":"rbxassetid://6910479863","wool_blue":"rbxassetid://6910480234","wood_plank_oak":"rbxassetid://6910418127","diamond_boots":"rbxassetid://6874272964","clay_yellow":"rbxassetid://4991097283","tnt":"rbxassetid://6856168996","lasso":"rbxassetid://7192710930","clay_purple":"rbxassetid://6856099740","melon_seeds":"rbxassetid://6956387796","apple":"rbxassetid://6985765179","carrot_seeds":"rbxassetid://6956387835","log_oak":"rbxassetid://6763678414","emerald_chestplate":"rbxassetid://6931675868","wool_yellow":"rbxassetid://6910479606","emerald_boots":"rbxassetid://6931675942","clay_light_brown":"rbxassetid://6874651634","balloon":"rbxassetid://7122143895","cannon":"rbxassetid://7121221753","leather_boots":"rbxassetid://6855466456","melon":"rbxassetid://6915428682","wool_white":"rbxassetid://6910387332","log_birch":"rbxassetid://6763678414","clay_pink":"rbxassetid://6856283410","grass":"rbxassetid://6773447725","obsidian":"rbxassetid://6910443317","shield":"rbxassetid://7051149149","red_sandstone":"rbxassetid://6708703895","diamond_helmet":"rbxassetid://6874272793","wool_orange":"rbxassetid://6910479956","log_hickory":"rbxassetid://7017706899","guitar":"rbxassetid://7085044606","wool_purple":"rbxassetid://6910479777","diamond":"rbxassetid://6850538161","iron_chestplate":"rbxassetid://6874272631","slime_block":"rbxassetid://6869284566","stone_brick":"rbxassetid://6910394475","hammer":"rbxassetid://6955848801","ceramic":"rbxassetid://6910426690","wood_plank_maple":"rbxassetid://6768632085","leather_helmet":"rbxassetid://6855466216","stone":"rbxassetid://6763635916","slate_brick":"rbxassetid://6708836267","sandstone":"rbxassetid://6708657090","snow":"rbxassetid://6874651192","wool_red":"rbxassetid://6910479695","leather_chestplate":"rbxassetid://6876833204","clay_red":"rbxassetid://6856283323","wool_green":"rbxassetid://6910480050","clay_white":"rbxassetid://7017705325","wool_cyan":"rbxassetid://6910480152","clay_black":"rbxassetid://5890435474","sand":"rbxassetid://6187018940","clay_light_green":"rbxassetid://6856099550","clay_dark_brown":"rbxassetid://6874651325","carrot":"rbxassetid://3677675280","clay":"rbxassetid://6856190168","iron_boots":"rbxassetid://6874272718","emerald":"rbxassetid://6850538075","zipline":"rbxassetid://7051148904"}'
				local oldbedwarsicontab = getservice('HttpService'):JSONDecode(oldbedwarstabofimages)
				local oldbedwarssoundtable = {
					['QUEUE_JOIN'] = 'rbxassetid://6691735519',
					['QUEUE_MATCH_FOUND'] = 'rbxassetid://6768247187',
					['UI_CLICK'] = 'rbxassetid://6732690176',
					['UI_OPEN'] = 'rbxassetid://6732607930',
					['BEDWARS_UPGRADE_SUCCESS'] = 'rbxassetid://6760677364',
					['BEDWARS_PURCHASE_ITEM'] = 'rbxassetid://6760677364',
					['SWORD_SWING_1'] = 'rbxassetid://6760544639',
					['SWORD_SWING_2'] = 'rbxassetid://6760544595',
					['DAMAGE_1'] = 'rbxassetid://6765457325',
					['DAMAGE_2'] = 'rbxassetid://6765470975',
					['DAMAGE_3'] = 'rbxassetid://6765470941',
					['CROP_HARVEST'] = 'rbxassetid://4864122196',
					['CROP_PLANT_1'] = 'rbxassetid://5483943277',
					['CROP_PLANT_2'] = 'rbxassetid://5483943479',
					['CROP_PLANT_3'] = 'rbxassetid://5483943723',
					['ARMOR_EQUIP'] = 'rbxassetid://6760627839',
					['ARMOR_UNEQUIP'] = 'rbxassetid://6760625788',
					['PICKUP_ITEM_DROP'] = 'rbxassetid://6768578304',
					['PARTY_INCOMING_INVITE'] = 'rbxassetid://6732495464',
					['ERROR_NOTIFICATION'] = 'rbxassetid://6732495464',
					['INFO_NOTIFICATION'] = 'rbxassetid://6732495464',
					['END_GAME'] = 'rbxassetid://6246476959',
					['GENERIC_BLOCK_PLACE'] = 'rbxassetid://4842910664',
					['GENERIC_BLOCK_BREAK'] = 'rbxassetid://4819966893',
					['GRASS_BREAK'] = 'rbxassetid://5282847153',
					['WOOD_BREAK'] = 'rbxassetid://4819966893',
					['STONE_BREAK'] = 'rbxassetid://6328287211',
					['WOOL_BREAK'] = 'rbxassetid://4842910664',
					['TNT_EXPLODE_1'] = 'rbxassetid://7192313632',
					['TNT_HISS_1'] = 'rbxassetid://7192313423',
					['FIREBALL_EXPLODE'] = 'rbxassetid://6855723746',
					['SLIME_BLOCK_BOUNCE'] = 'rbxassetid://6857999096',
					['SLIME_BLOCK_BREAK'] = 'rbxassetid://6857999170',
					['SLIME_BLOCK_HIT'] = 'rbxassetid://6857999148',
					['SLIME_BLOCK_PLACE'] = 'rbxassetid://6857999119',
					['BOW_DRAW'] = 'rbxassetid://6866062236',
					['BOW_FIRE'] = 'rbxassetid://6866062104',
					['ARROW_HIT'] = 'rbxassetid://6866062188',
					['ARROW_IMPACT'] = 'rbxassetid://6866062148',
					['TELEPEARL_THROW'] = 'rbxassetid://6866223756',
					['TELEPEARL_LAND'] = 'rbxassetid://6866223798',
					['CROSSBOW_RELOAD'] = 'rbxassetid://6869254094',
					['VOICE_1'] = 'rbxassetid://5283866929',
					['VOICE_2'] = 'rbxassetid://5283867710',
					['VOICE_HONK'] = 'rbxassetid://5283872555',
					['FORTIFY_BLOCK'] = 'rbxassetid://6955762535',
					['EAT_FOOD_1'] = 'rbxassetid://4968170636',
					['KILL'] = 'rbxassetid://7013482008',
					['ZIPLINE_TRAVEL'] = 'rbxassetid://7047882304',
					['ZIPLINE_LATCH'] = 'rbxassetid://7047882233',
					['ZIPLINE_UNLATCH'] = 'rbxassetid://7047882265',
					['SHIELD_BLOCKED'] = 'rbxassetid://6955762535',
					['GUITAR_LOOP'] = 'rbxassetid://7084168540',
					['GUITAR_HEAL_1'] = 'rbxassetid://7084168458',
					['CANNON_MOVE'] = 'rbxassetid://7118668472',
					['CANNON_FIRE'] = 'rbxassetid://7121064180',
					['BALLOON_INFLATE'] = 'rbxassetid://7118657911',
					['BALLOON_POP'] = 'rbxassetid://7118657873',
					['FIREBALL_THROW'] = 'rbxassetid://7192289445',
					['LASSO_HIT'] = 'rbxassetid://7192289603',
					['LASSO_SWING'] = 'rbxassetid://7192289504',
					['LASSO_THROW'] = 'rbxassetid://7192289548',
					['GRIM_REAPER_CONSUME'] = 'rbxassetid://7225389554',
					['GRIM_REAPER_CHANNEL'] = 'rbxassetid://7225389512',
					['TV_STATIC'] = "rbxassetid://7256209920",
					['TURRET_ON'] = 'rbxassetid://7290176291',
					['TURRET_OFF'] = 'rbxassetid://7290176380',
					['TURRET_ROTATE'] = 'rbxassetid://7290176421',
					['TURRET_SHOOT'] = 'rbxassetid://7290187805',
					['WIZARD_LIGHTNING_CAST'] = 'rbxassetid://7262989886',
					['WIZARD_LIGHTNING_LAND'] = 'rbxassetid://7263165647',
					['WIZARD_LIGHTNING_STRIKE'] = 'rbxassetid://7263165347',
					['WIZARD_ORB_CAST'] = 'rbxassetid://7263165448',
					['WIZARD_ORB_TRAVEL_LOOP'] = 'rbxassetid://7263165579',
					['WIZARD_ORB_CONTACT_LOOP'] = 'rbxassetid://7263165647',
					['BATTLE_PASS_PROGRESS_LEVEL_UP'] = 'rbxassetid://7331597283',
					['BATTLE_PASS_PROGRESS_EXP_GAIN'] = 'rbxassetid://7331597220',
					['FLAMETHROWER_UPGRADE'] = 'rbxassetid://7310273053',
					['FLAMETHROWER_USE'] = 'rbxassetid://7310273125',
					['BRITTLE_HIT'] = 'rbxassetid://7310273179',
					['EXTINGUISH'] = 'rbxassetid://7310273015',
					['RAVEN_SPACE_AMBIENT'] = 'rbxassetid://7341443286',
					['RAVEN_WING_FLAP'] = 'rbxassetid://7341443378',
					['RAVEN_CAW'] = 'rbxassetid://7341443447',
					['JADE_HAMMER_THUD'] = 'rbxassetid://7342299402',
					['STATUE'] = 'rbxassetid://7344166851',
					['CONFETTI'] = 'rbxassetid://7344278405',
					['HEART'] = 'rbxassetid://7345120916',
					['SPRAY'] = 'rbxassetid://7361499529',
					['BEEHIVE_PRODUCE'] = 'rbxassetid://7378100183',
					['DEPOSIT_BEE'] = 'rbxassetid://7378100250',
					['CATCH_BEE'] = 'rbxassetid://7378100305',
					['BEE_NET_SWING'] = 'rbxassetid://7378100350',
					['ASCEND'] = 'rbxassetid://7378387334',
					['BED_ALARM'] = 'rbxassetid://7396762708',
					['BOUNTY_CLAIMED'] = 'rbxassetid://7396751941',
					['BOUNTY_ASSIGNED'] = 'rbxassetid://7396752155',
					['BAGUETTE_HIT'] = 'rbxassetid://7396760547',
					['BAGUETTE_SWING'] = 'rbxassetid://7396760496',
					['TESLA_ZAP'] = 'rbxassetid://7497477336',
					['SPIRIT_TRIGGERED'] = 'rbxassetid://7498107251',
					['SPIRIT_EXPLODE'] = 'rbxassetid://7498107327',
					['ANGEL_LIGHT_ORB_CREATE'] = 'rbxassetid://7552134231',
					['ANGEL_LIGHT_ORB_HEAL'] = 'rbxassetid://7552134868',
					['ANGEL_VOID_ORB_CREATE'] = 'rbxassetid://7552135942',
					['ANGEL_VOID_ORB_HEAL'] = 'rbxassetid://7552136927',
					['DODO_BIRD_JUMP'] = 'rbxassetid://7618085391',
					['DODO_BIRD_DOUBLE_JUMP'] = 'rbxassetid://7618085771',
					['DODO_BIRD_MOUNT'] = 'rbxassetid://7618085486',
					['DODO_BIRD_DISMOUNT'] = 'rbxassetid://7618085571',
					['DODO_BIRD_SQUAWK_1'] = 'rbxassetid://7618085870',
					['DODO_BIRD_SQUAWK_2'] = 'rbxassetid://7618085657',
					['SHIELD_CHARGE_START'] = 'rbxassetid://7730842884',
					['SHIELD_CHARGE_LOOP'] = 'rbxassetid://7730843006',
					['SHIELD_CHARGE_BASH'] = 'rbxassetid://7730843142',
					['ROCKET_LAUNCHER_FIRE'] = 'rbxassetid://7681584765',
					['ROCKET_LAUNCHER_FLYING_LOOP'] = 'rbxassetid://7681584906',
					['SMOKE_GRENADE_POP'] = 'rbxassetid://7681276062',
					['SMOKE_GRENADE_EMIT_LOOP'] = 'rbxassetid://7681276135',
					['GOO_SPIT'] = 'rbxassetid://7807271610',
					['GOO_SPLAT'] = 'rbxassetid://7807272724',
					['GOO_EAT'] = 'rbxassetid://7813484049',
					['LUCKY_BLOCK_BREAK'] = 'rbxassetid://7682005357',
					['AXOLOTL_SWITCH_TARGETS'] = 'rbxassetid://7344278405',
					['HALLOWEEN_MUSIC'] = 'rbxassetid://7775602786',
					['SNAP_TRAP_SETUP'] = 'rbxassetid://7796078515',
					['SNAP_TRAP_CLOSE'] = 'rbxassetid://7796078695',
					['SNAP_TRAP_CONSUME_MARK'] = 'rbxassetid://7796078825',
					['GHOST_VACUUM_SUCKING_LOOP'] = 'rbxassetid://7814995865',
					['GHOST_VACUUM_SHOOT'] = 'rbxassetid://7806060367',
					['GHOST_VACUUM_CATCH'] = 'rbxassetid://7815151688',
					['FISHERMAN_GAME_START'] = 'rbxassetid://7806060544',
					['FISHERMAN_GAME_PULLING_LOOP'] = 'rbxassetid://7806060638',
					['FISHERMAN_GAME_PROGRESS_INCREASE'] = 'rbxassetid://7806060745',
					['FISHERMAN_GAME_FISH_MOVE'] = 'rbxassetid://7806060863',
					['FISHERMAN_GAME_LOOP'] = 'rbxassetid://7806061057',
					['FISHING_ROD_CAST'] = 'rbxassetid://7806060976',
					['FISHING_ROD_SPLASH'] = 'rbxassetid://7806061193',
					['SPEAR_HIT'] = 'rbxassetid://7807270398',
					['SPEAR_THROW'] = 'rbxassetid://7813485044',
				}
				for i,v in (bedwars.CombatController.killSounds) do
					bedwars.CombatController.killSounds[i] = oldbedwarssoundtable.KILL
				end
				for i,v in (bedwars.CombatController.multiKillLoops) do
					bedwars.CombatController.multiKillLoops[i] = ''
				end
				for i,v in (bedwars.ItemTable) do
					if oldbedwarsicontab[i] then
						v.image = oldbedwarsicontab[i]
					end
				end
				for i,v in (oldbedwarssoundtable) do
					local item = bedwars.SoundList[i]
					if item then
						bedwars.SoundList[i] = v
					end
				end
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(214, 0, 0)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.ViewmodelController.show, 37, '')
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, 'Enabled')
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tween:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(1, 1, 1))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tween:Create(obj, ...)
					end
				})
				sethiddenproperty(lighting, 'Technology', 'ShadowMap')
				lighting.Ambient = Color3.fromRGB(69, 69, 69)
				lighting.Brightness = 3
				lighting.EnvironmentDiffuseScale = 1
				lighting.EnvironmentSpecularScale = 1
				lighting.OutdoorAmbient = Color3.fromRGB(69, 69, 69)
				lighting.Atmosphere.Density = 0.1
				lighting.Atmosphere.Offset = 0.25
				lighting.Atmosphere.Color = Color3.fromRGB(198, 198, 198)
				lighting.Atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				lighting.Atmosphere.Glare = 0
				lighting.Atmosphere.Haze = 0
				lighting.ClockTime = 13
				lighting.GeographicLatitude = 0
				lighting.GlobalShadows = false
				lighting.TimeOfDay = '13:00:00'
				lighting.Sky.SkyboxBk = 'rbxassetid://7018684000'
				lighting.Sky.SkyboxDn = 'rbxassetid://6334928194'
				lighting.Sky.SkyboxFt = 'rbxassetid://7018684000'
				lighting.Sky.SkyboxLf = 'rbxassetid://7018684000'
				lighting.Sky.SkyboxRt = 'rbxassetid://7018684000'
				lighting.Sky.SkyboxUp = 'rbxassetid://7018689553'
			end)
		end,
		Winter = function()
			task.spawn(function()
				for i,v in (lighting:GetChildren()) do
					if v:IsA('Atmosphere') or v:IsA('Sky') or v:IsA('PostEffect') then
						v:Remove()
					end
				end
				local sky = Instance.new('Sky')
				sky.StarCount = 5000
				sky.SkyboxUp = 'rbxassetid://8139676647'
				sky.SkyboxLf = 'rbxassetid://8139676988'
				sky.SkyboxFt = 'rbxassetid://8139677111'
				sky.SkyboxBk = 'rbxassetid://8139677359'
				sky.SkyboxDn = 'rbxassetid://8139677253'
				sky.SkyboxRt = 'rbxassetid://8139676842'
				sky.SunTextureId = 'rbxassetid://6196665106'
				sky.SunAngularSize = 11
				sky.MoonTextureId = 'rbxassetid://8139665943'
				sky.MoonAngularSize = 30
				sky.Parent = lighting
				local sunray = Instance.new('SunRaysEffect')
				sunray.Intensity = 0.03
				sunray.Parent = lighting
				local bloom = Instance.new('BloomEffect')
				bloom.Threshold = 2
				bloom.Intensity = 1
				bloom.Size = 2
				bloom.Parent = lighting
				local atmosphere = Instance.new('Atmosphere')
				atmosphere.Density = 0.3
				atmosphere.Offset = 0.25
				atmosphere.Color = Color3.fromRGB(198, 198, 198)
				atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				atmosphere.Glare = 0
				atmosphere.Haze = 0
				atmosphere.Parent = lighting
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(70, 255, 255)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, 'Enabled')
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tween:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(1, 1, 1) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tween:Create(obj, ...)
					end
				})
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar['hotbar-healthbar']).HotbarHealthbar.render, 16, 4653055)
			end)
			task.spawn(function()
				local snowpart = Instance.new('Part')
				snowpart.Size = Vector3.new(240, 0.5, 240)
				snowpart.Name = 'SnowParticle'
				snowpart.Transparency = 1
				snowpart.CanCollide = false
				snowpart.Position = Vector3.new(0, 120, 286)
				snowpart.Anchored = true
				snowpart.Parent = workspace
				local snow = Instance.new('ParticleEmitter')
				snow.RotSpeed = NumberRange.new(300)
				snow.VelocitySpread = 35
				snow.Rate = 28
				snow.Texture = 'rbxassetid://8158344433'
				snow.Rotation = NumberRange.new(110)
				snow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				snow.Lifetime = NumberRange.new(8,14)
				snow.Speed = NumberRange.new(8,18)
				snow.EmissionDirection = Enum.NormalId.Bottom
				snow.SpreadAngle = Vector2.new(35,35)
				snow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				snow.Parent = snowpart
				local windsnow = Instance.new('ParticleEmitter')
				windsnow.Acceleration = Vector3.new(0,0,1)
				windsnow.RotSpeed = NumberRange.new(100)
				windsnow.VelocitySpread = 35
				windsnow.Rate = 28
				windsnow.Texture = 'rbxassetid://8158344433'
				windsnow.EmissionDirection = Enum.NormalId.Bottom
				windsnow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				windsnow.Lifetime = NumberRange.new(8,14)
				windsnow.Speed = NumberRange.new(8,18)
				windsnow.Rotation = NumberRange.new(110)
				windsnow.SpreadAngle = Vector2.new(35,35)
				windsnow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				windsnow.Parent = snowpart
				repeat
					task.wait()
					if entityLibrary.isAlive then
						snowpart.Position = entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, 100, 0)
					end
				until not vapeInjected
			end)
		end,
		Halloween = function()
			task.spawn(function()
				for i,v in (lighting:GetChildren()) do
					if v:IsA('Atmosphere') or v:IsA('Sky') or v:IsA('PostEffect') then
						v:Remove()
					end
				end
				lighting.TimeOfDay = '00:00:00'
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 100, 0)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, 'Enabled')
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tween:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tween:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new('ColorCorrectionEffect')
				colorcorrection.TintColor = Color3.fromRGB(255, 185, 81)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lighting
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar['hotbar-healthbar']).HotbarHealthbar.render, 16, 16737280)
			end)
		end,
		Valentines = function()
			task.spawn(function()
				for i,v in (lighting:GetChildren()) do
					if v:IsA('Atmosphere') or v:IsA('Sky') or v:IsA('PostEffect') then
						v:Remove()
					end
				end
				local sky = Instance.new('Sky')
				sky.SkyboxBk = 'rbxassetid://1546230803'
				sky.SkyboxDn = 'rbxassetid://1546231143'
				sky.SkyboxFt = 'rbxassetid://1546230803'
				sky.SkyboxLf = 'rbxassetid://1546230803'
				sky.SkyboxRt = 'rbxassetid://1546230803'
				sky.SkyboxUp = 'rbxassetid://1546230451'
				sky.Parent = lighting
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 132, 178)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, 'Enabled')
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tween:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tween:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new('ColorCorrectionEffect')
				colorcorrection.TintColor = Color3.fromRGB(255, 199, 220)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lighting
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar['hotbar-healthbar']).HotbarHealthbar.render, 16, 16745650)
			end)
		end
	}

	GameTheme = vape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'GameTheme',
		Function = function(callback)
			if callback then
				if not transformed then
					transformed = true
					themefunctions[GameThemeMode.Value]()
				else
					GameTheme.ToggleButton(false)
				end
			else
				warningNotification('GameTheme', 'Disabled Next Game', 10)
			end
		end,
		ExtraText = function()
			return GameThemeMode.Value
		end
	})
	GameThemeMode = GameTheme.CreateDropdown({
		Name = 'Theme',
		Function = void,
		List = {'Old', 'Winter', 'Halloween', 'Valentines'}
	})
end)

run(function()
	local oldkilleffect
	local KillEffectMode = {Value = 'Gravity'}
	local KillEffectList = {Value = 'None'}
	local KillEffectName2 = {}
	local killeffects = {
		Gravity = function(p3, p4, p5, p6)
			p5:BreakJoints()
			task.spawn(function()
				local partvelo = {}
				for i,v in (p5:GetDescendants()) do
					if v:IsA('BasePart') then
						partvelo[v.Name] = v.Velocity * 3
					end
				end
				p5.Archivable = true
				local clone = p5:Clone()
				clone.Humanoid.Health = 100
				clone.Parent = workspace
				local nametag = clone:FindFirstChild('Nametag', true)
				if nametag then nametag:Destroy() end
				getservice('Debris'):AddItem(clone, 30)
				p5:Destroy()
				task.wait(0.01)
				clone.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				clone:BreakJoints()
				task.wait(0.01)
				for i,v in (clone:GetDescendants()) do
					if v:IsA('BasePart') then
						local bodyforce = Instance.new('BodyForce')
						bodyforce.Force = Vector3.new(0, (workspace.Gravity - 10) * v:GetMass(), 0)
						bodyforce.Parent = v
						v.CanCollide = true
						v.Velocity = partvelo[v.Name] or Vector3.zero
					end
				end
			end)
		end,
		Lightning = function(p3, p4, p5, p6)
			p5:BreakJoints()
			local startpos = 1125
			local startcf = p5.PrimaryPart.CFrame.p - Vector3.new(0, 8, 0)
			local newpos = Vector3.new((math.random(1, 10) - 5) * 2, startpos, (math.random(1, 10) - 5) * 2)
			for i = startpos - 75, 0, -75 do
				local newpos2 = Vector3.new((math.random(1, 10) - 5) * 2, i, (math.random(1, 10) - 5) * 2)
				if i == 0 then
					newpos2 = Vector3.zero
				end
				local part = Instance.new('Part')
				part.Size = Vector3.new(1.5, 1.5, 77)
				part.Material = Enum.Material.SmoothPlastic
				part.Anchored = true
				part.Material = Enum.Material.Neon
				part.CanCollide = false
				part.CFrame = CFrame.new(startcf + newpos + ((newpos2 - newpos) * 0.5), startcf + newpos2)
				part.Parent = workspace
				local part2 = part:Clone()
				part2.Size = Vector3.new(3, 3, 78)
				part2.Color = Color3.new(0.7, 0.7, 0.7)
				part2.Transparency = 0.7
				part2.Material = Enum.Material.SmoothPlastic
				part2.Parent = workspace
				getservice('Debris'):AddItem(part, 0.5)
				getservice('Debris'):AddItem(part2, 0.5)
				bedwars.QueryUtil:setQueryIgnored(part, true)
				bedwars.QueryUtil:setQueryIgnored(part2, true)
				if i == 0 then
					local soundpart = Instance.new('Part')
					soundpart.Transparency = 1
					soundpart.Anchored = true
					soundpart.Size = Vector3.zero
					soundpart.Position = startcf
					soundpart.Parent = workspace
					bedwars.QueryUtil:setQueryIgnored(soundpart, true)
					local sound = Instance.new('Sound')
					sound.SoundId = 'rbxassetid://6993372814'
					sound.Volume = 2
					sound.Pitch = 0.5 + (math.random(1, 3) / 10)
					sound.Parent = soundpart
					sound:Play()
					sound.Ended:Connect(function()
						soundpart:Destroy()
					end)
				end
				newpos = newpos2
			end
		end
	}
	local KillEffectName = {}
	for i,v in (bedwars.KillEffectMeta) do
		table.insert(KillEffectName, v.name)
		KillEffectName[v.name] = i
	end
	table.sort(KillEffectName, function(a, b) return a:lower() < b:lower() end)
	local KillEffect = {Enabled = false}
	KillEffect = vape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'KillEffect',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until store.matchState ~= 0 or not KillEffect.Enabled
					if KillEffect.Enabled then
						lplr:SetAttribute('KillEffectType', 'none')
						if KillEffectMode.Value == 'Bedwars' then
							lplr:SetAttribute('KillEffectType', KillEffectName[KillEffectList.Value])
						end
					end
				end)
				oldkilleffect = bedwars.DefaultKillEffect.onKill
				bedwars.DefaultKillEffect.onKill = function(p3, p4, p5, p6)
					killeffects[KillEffectMode.Value](p3, p4, p5, p6)
				end
			else
				bedwars.DefaultKillEffect.onKill = oldkilleffect
			end
		end
	})
	local modes = {'Bedwars'}
	for i,v in (killeffects) do
		table.insert(modes, i)
	end
	KillEffectMode = KillEffect.CreateDropdown({
		Name = 'Mode',
		Function = function()
			if KillEffect.Enabled then
				KillEffect.ToggleButton(false)
				KillEffect.ToggleButton(false)
			end
		end,
		List = modes
	})
	KillEffectList = KillEffect.CreateDropdown({
		Name = 'Bedwars',
		Function = function()
			if KillEffect.Enabled then
				KillEffect.ToggleButton(false)
				KillEffect.ToggleButton(false)
			end
		end,
		List = KillEffectName
	})
end)

run(function()
	local KitESP = {Enabled = false}
	local espobjs = {}
	local espfold = Instance.new('Folder')
	espfold.Parent = vape.MainGui

	local function espadd(v, icon)
		local billboard = Instance.new('BillboardGui')
		billboard.Parent = espfold
		billboard.Name = 'iron'
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 32, 0, 32)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		local image = Instance.new('ImageLabel')
		image.BackgroundTransparency = 0.5
		image.BorderSizePixel = 0
		image.Image = bedwars.getIcon({itemType = icon}, true)
		image.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		image.Size = UDim2.new(0, 32, 0, 32)
		image.AnchorPoint = Vector2.new(0.5, 0.5)
		image.Parent = billboard
		local uicorner = Instance.new('UICorner')
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = image
		espobjs[v] = billboard
	end

	local function addKit(tag, icon)
		table.insert(KitESP.Connections, collection:GetInstanceAddedSignal(tag):Connect(function(v)
			espadd(v.PrimaryPart, icon)
		end))
		table.insert(KitESP.Connections, collection:GetInstanceRemovedSignal(tag):Connect(function(v)
			if espobjs[v.PrimaryPart] then
				espobjs[v.PrimaryPart]:Destroy()
				espobjs[v.PrimaryPart] = nil
			end
		end))
		for i,v in (collection:GetTagged(tag)) do
			espadd(v.PrimaryPart, icon)
		end
	end

	KitESP = vape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'KitESP',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until store.equippedKit ~= ''
					if KitESP.Enabled then
						if store.equippedKit == 'metal_detector' then
							addKit('hidden-metal', 'iron')
						elseif store.equippedKit == 'beekeeper' then
							addKit('bee', 'bee')
						elseif store.equippedKit == 'bigman' then
							addKit('treeOrb', 'natures_essence_1')
						end
					end
				end)
			else
				espfold:ClearAllChildren()
				table.clear(espobjs)
			end
		end
	})
end)

run(function()
	local function floorNameTagPosition(pos)
		return Vector2.new(math.floor(pos.X), math.floor(pos.Y))
	end

	local function removeTags(str)
		str = str:gsub('<br%s*/>', '\n')
		return (str:gsub('<[^<>]->', ''))
	end

	local NameTagsFolder = Instance.new('Folder')
	NameTagsFolder.Name = 'NameTagsFolder'
	NameTagsFolder.Parent = vape.MainGui
	local nametagsfolderdrawing = {}
	local NameTagsColor = {Value = 0.44}
	local NameTagsDisplayName = {Enabled = false}
	local NameTagsHealth = {Enabled = false}
	local NameTagsDistance = {Enabled = false}
	local NameTagsBackground = {Enabled = true}
	local NameTagsScale = {Value = 10}
	local NameTagsFont = {Value = 'SourceSans'}
	local NameTagsTeammates = {Enabled = true}
	local NameTagsShowInventory = {Enabled = false}
	local NameTagsRangeLimit = {Value = 0}
	local fontitems = {'SourceSans'}
	local nametagstrs = {}
	local nametagsizes = {}
	local kititems = {
		jade = 'jade_hammer',
		archer = 'tactical_crossbow',
		angel = '',
		cowgirl = 'lasso',
		dasher = 'wood_dao',
		axolotl = 'axolotl',
		yeti = 'snowball',
		smoke = 'smoke_block',
		trapper = 'snap_trap',
		pyro = 'flamethrower',
		davey = 'cannon',
		regent = 'void_axe',
		baker = 'apple',
		builder = 'builder_hammer',
		farmer_cletus = 'carrot_seeds',
		melody = 'guitar',
		barbarian = 'rageblade',
		gingerbread_man = 'gumdrop_bounce_pad',
		spirit_catcher = 'spirit',
		fisherman = 'fishing_rod',
		oil_man = 'oil_consumable',
		santa = 'tnt',
		miner = 'miner_pickaxe',
		sheep_herder = 'crook',
		beast = 'speed_potion',
		metal_detector = 'metal_detector',
		cyber = 'drone',
		vesta = 'damage_banner',
		lumen = 'light_sword',
		ember = 'infernal_saber',
		queen_bee = 'bee'
	}

	local nametagfuncs1 = {
		Normal = function(plr)
			if NameTagsTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = Instance.new('TextLabel')
			thing.BackgroundColor3 = Color3.new()
			thing.BorderSizePixel = 0
			thing.Visible = false
			thing.RichText = true
			thing.AnchorPoint = Vector2.new(0.5, 1)
			thing.Name = plr.Player.Name
			thing.Font = Enum.Font[NameTagsFont.Value]
			thing.TextSize = 14 * (NameTagsScale.Value / 10)
			thing.BackgroundTransparency = NameTagsBackground.Enabled and 0.5 or 1
			nametagstrs[plr.Player] = whitelist:tag(plr.Player, true)..(NameTagsDisplayName.Enabled and plr.Player.DisplayName or plr.Player.Name)
			if NameTagsHealth.Enabled then
				local color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				nametagstrs[plr.Player] = nametagstrs[plr.Player].." <font color='rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')'>'..math.round(plr.Humanoid.Health)..'</font>"
			end
			if NameTagsDistance.Enabled then
				nametagstrs[plr.Player] = "<font color='rgb(85, 255, 85)'>[</font><font color='rgb(255, 255, 255)'>%s</font><font color='rgb(85, 255, 85)'>]</font> "..nametagstrs[plr.Player]
			end
			local nametagSize = textservice:GetTextSize(removeTags(nametagstrs[plr.Player]), thing.TextSize, thing.Font, Vector2.new(100000, 100000))
			thing.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
			thing.Text = nametagstrs[plr.Player]
			thing.TextColor3 = getPlayerColor(plr.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			thing.Parent = NameTagsFolder
			local hand = Instance.new('ImageLabel')
			hand.Size = UDim2.new(0, 30, 0, 30)
			hand.Name = 'Hand'
			hand.BackgroundTransparency = 1
			hand.Position = UDim2.new(0, -30, 0, -30)
			hand.Image = ''
			hand.Parent = thing
			local helmet = hand:Clone()
			helmet.Name = 'Helmet'
			helmet.Position = UDim2.new(0, 5, 0, -30)
			helmet.Parent = thing
			local chest = hand:Clone()
			chest.Name = 'Chestplate'
			chest.Position = UDim2.new(0, 35, 0, -30)
			chest.Parent = thing
			local boots = hand:Clone()
			boots.Name = 'Boots'
			boots.Position = UDim2.new(0, 65, 0, -30)
			boots.Parent = thing
			local kit = hand:Clone()
			kit.Name = 'Kit'
			task.spawn(function()
				repeat task.wait() until plr.Player:GetAttribute('PlayingAsKit') ~= ''
				if kit then
					kit.Image = kititems[plr.Player:GetAttribute('PlayingAsKit')] and bedwars.getIcon({itemType = kititems[plr.Player:GetAttribute('PlayingAsKit')]}, NameTagsShowInventory.Enabled) or ''
				end
			end)
			kit.Position = UDim2.new(0, -30, 0, -65)
			kit.Parent = thing
			nametagsfolderdrawing[plr.Player] = {entity = plr, Main = thing}
		end,
		Drawing = function(plr)
			if NameTagsTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = {Main = {}, entity = plr}
			thing.Main.Text = Drawing.new('Text')
			thing.Main.Text.Size = 17 * (NameTagsScale.Value / 10)
			thing.Main.Text.Font = (math.clamp((table.find(fontitems, NameTagsFont.Value) or 1) - 1, 0, 3))
			thing.Main.Text.ZIndex = 2
			thing.Main.BG = Drawing.new('Square')
			thing.Main.BG.Filled = true
			thing.Main.BG.Transparency = 0.5
			thing.Main.BG.Visible = NameTagsBackground.Enabled
			thing.Main.BG.Color = Color3.new()
			thing.Main.BG.ZIndex = 1
			nametagstrs[plr.Player] = whitelist:tag(plr.Player, true)..(NameTagsDisplayName.Enabled and plr.Player.DisplayName or plr.Player.Name)
			if NameTagsHealth.Enabled then
				local color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				nametagstrs[plr.Player] = nametagstrs[plr.Player]..' '..math.round(plr.Humanoid.Health)
			end
			if NameTagsDistance.Enabled then
				nametagstrs[plr.Player] = '[%s] '..nametagstrs[plr.Player]
			end
			thing.Main.Text.Text = nametagstrs[plr.Player]
			thing.Main.BG.Size = Vector2.new(thing.Main.Text.TextBounds.X + 4, thing.Main.Text.TextBounds.Y)
			thing.Main.Text.Color = getPlayerColor(plr.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			nametagsfolderdrawing[plr.Player] = thing
		end
	}

	local nametagfuncs2 = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then
				v.Main:Destroy()
			end
		end,
		Drawing = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then
				for i2,v2 in (v.Main) do
					pcall(function() v2.Visible = false v2:Remove() end)
				end
			end
		end
	}

	local nametagupdatefuncs = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent.Player]
			if v then
				nametagstrs[ent.Player] = whitelist:tag(ent.Player, true)..(NameTagsDisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name)
				if NameTagsHealth.Enabled then
					local color = Color3.fromHSV(math.clamp(ent.Humanoid.Health / ent.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(ent.Humanoid.Health).."</font>"
				end
				if NameTagsDistance.Enabled then
					nametagstrs[ent.Player] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..nametagstrs[ent.Player]
				end
				if NameTagsShowInventory.Enabled then
					local inventory = store.inventories[ent.Player] or {armor = {}}
					if inventory.hand then
						v.Main.Hand.Image = bedwars.getIcon(inventory.hand, NameTagsShowInventory.Enabled)
						if v.Main.Hand.Image:find('rbxasset://') then
							v.Main.Hand.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Hand.Image = ''
					end
					if inventory.armor[4] then
						v.Main.Helmet.Image = bedwars.getIcon(inventory.armor[4], NameTagsShowInventory.Enabled)
						if v.Main.Helmet.Image:find('rbxasset://') then
							v.Main.Helmet.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Helmet.Image = ''
					end
					if inventory.armor[5] then
						v.Main.Chestplate.Image = bedwars.getIcon(inventory.armor[5], NameTagsShowInventory.Enabled)
						if v.Main.Chestplate.Image:find('rbxasset://') then
							v.Main.Chestplate.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Chestplate.Image = ''
					end
					if inventory.armor[6] then
						v.Main.Boots.Image = bedwars.getIcon(inventory.armor[6], NameTagsShowInventory.Enabled)
						if v.Main.Boots.Image:find('rbxasset://') then
							v.Main.Boots.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Boots.Image = ''
					end
				end
				local nametagSize = textservice:GetTextSize(removeTags(nametagstrs[ent.Player]), v.Main.TextSize, v.Main.Font, Vector2.new(100000, 100000))
				v.Main.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
				v.Main.Text = nametagstrs[ent.Player]
			end
		end,
		Drawing = function(ent)
			local v = nametagsfolderdrawing[ent.Player]
			if v then
				nametagstrs[ent.Player] = whitelist:tag(ent.Player, true)..(NameTagsDisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name)
				if NameTagsHealth.Enabled then
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' '..math.round(ent.Humanoid.Health)
				end
				if NameTagsDistance.Enabled then
					nametagstrs[ent.Player] = '[%s] '..nametagstrs[ent.Player]
					v.Main.Text.Text = entityLibrary.isAlive and string.format(nametagstrs[ent.Player], math.floor((entityLibrary.character.HumanoidRootPart.Position - ent.RootPart.Position).Magnitude)) or nametagstrs[ent.Player]
				else
					v.Main.Text.Text = nametagstrs[ent.Player]
				end
				v.Main.BG.Size = Vector2.new(v.Main.Text.TextBounds.X + 4, v.Main.Text.TextBounds.Y)
				v.Main.Text.Color = getPlayerColor(ent.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			end
		end
	}

	local nametagcolorfuncs = {
		Normal = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in (nametagsfolderdrawing) do
				v.Main.TextColor3 = getPlayerColor(v.entity.Player) or color
			end
		end,
		Drawing = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in (nametagsfolderdrawing) do
				v.Main.Text.Color = getPlayerColor(v.entity.Player) or color
			end
		end
	}

	local nametagloop = {
		Normal = function()
			for i,v in (nametagsfolderdrawing) do
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then
					v.Main.Visible = false
					continue
				end
				local mag = entityLibrary.isAlive and math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude) or 0
				if NameTagsRangeLimit.Value ~= 0 and mag > NameTagsRangeLimit.Value then
					v.Main.Visible = false
					continue
				end
				if NameTagsDistance.Enabled then
					local stringsize = tostring(mag):len()
					if nametagsizes[v.entity.Player] ~= stringsize then
						local nametagSize = textservice:GetTextSize(removeTags(string.format(nametagstrs[v.entity.Player], mag)), v.Main.TextSize, v.Main.Font, Vector2.new(100000, 100000))
						v.Main.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
					end
					nametagsizes[v.entity.Player] = stringsize
					v.Main.Text = string.format(nametagstrs[v.entity.Player], mag)
				end
				v.Main.Position = UDim2.new(0, headPos.X, 0, headPos.Y)
				v.Main.Visible = true
			end
		end,
		Drawing = function()
			for i,v in (nametagsfolderdrawing) do
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				local mag = entityLibrary.isAlive and math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude) or 0
				if NameTagsRangeLimit.Value ~= 0 and mag > NameTagsRangeLimit.Value then
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				if NameTagsDistance.Enabled then
					local stringsize = tostring(mag):len()
					v.Main.Text.Text = string.format(nametagstrs[v.entity.Player], mag)
					if nametagsizes[v.entity.Player] ~= stringsize then
						v.Main.BG.Size = Vector2.new(v.Main.Text.TextBounds.X + 4, v.Main.Text.TextBounds.Y)
					end
					nametagsizes[v.entity.Player] = stringsize
				end
				v.Main.BG.Position = Vector2.new(headPos.X - (v.Main.BG.Size.X / 2), (headPos.Y + v.Main.BG.Size.Y))
				v.Main.Text.Position = v.Main.BG.Position + Vector2.new(2, 0)
				v.Main.Text.Visible = true
				v.Main.BG.Visible = NameTagsBackground.Enabled
			end
		end
	}

	local methodused

	local NameTags = {Enabled = false}
	NameTags = vape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'NameTags',
		Function = function(callback)
			if callback then
				methodused = NameTagsDrawing.Enabled and 'Drawing' or 'Normal'
				if nametagfuncs2[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityRemovedEvent:Connect(nametagfuncs2[methodused]))
				end
				if nametagfuncs1[methodused] then
					local addfunc = nametagfuncs1[methodused]
					for i,v in (entityLibrary.entityList) do
						if nametagsfolderdrawing[v.Player] then nametagfuncs2[methodused](v.Player) end
						addfunc(v)
					end
					table.insert(NameTags.Connections, entityLibrary.entityAddedEvent:Connect(function(ent)
						if nametagsfolderdrawing[ent.Player] then nametagfuncs2[methodused](ent.Player) end
						addfunc(ent)
					end))
				end
				if nametagupdatefuncs[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityUpdatedEvent:Connect(nametagupdatefuncs[methodused]))
					for i,v in (entityLibrary.entityList) do
						nametagupdatefuncs[methodused](v)
					end
				end
				if nametagcolorfuncs[methodused] then
					table.insert(NameTags.Connections, vape.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.FriendColorRefresh.Event:Connect(function()
						nametagcolorfuncs[methodused](NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
					end))
				end
				if nametagloop[methodused] then
					RunLoops:BindToRenderStep('NameTags', nametagloop[methodused])
				end
			else
				RunLoops:UnbindFromRenderStep('NameTags')
				if nametagfuncs2[methodused] then
					for i,v in (nametagsfolderdrawing) do
						nametagfuncs2[methodused](i)
					end
				end
			end
		end,
		HoverText = 'Renders nametags on entities through walls.'
	})
	for i,v in (Enum.Font:GetEnumItems()) do
		if v.Name ~= 'SourceSans' then
			table.insert(fontitems, v.Name)
		end
	end
	NameTagsFont = NameTags.CreateDropdown({
		Name = 'Font',
		List = fontitems,
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
	})
	NameTagsColor = NameTags.CreateColorSlider({
		Name = 'Player Color',
		Function = function(hue, sat, val)
			if NameTags.Enabled and nametagcolorfuncs[methodused] then
				nametagcolorfuncs[methodused](hue, sat, val)
			end
		end
	})
	NameTagsScale = NameTags.CreateSlider({
		Name = 'Scale',
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = 10,
		Min = 1,
		Max = 50
	})
	NameTagsRangeLimit = NameTags.CreateSlider({
		Name = 'Range',
		Function = void,
		Min = 0,
		Max = 1000,
		Default = 0
	})
	NameTagsBackground = NameTags.CreateToggle({
		Name = 'Background',
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsDisplayName = NameTags.CreateToggle({
		Name = 'Use Display Name',
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsHealth = NameTags.CreateToggle({
		Name = 'Health',
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end
	})
	NameTagsDistance = NameTags.CreateToggle({
		Name = 'Distance',
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end
	})
	NameTagsShowInventory = NameTags.CreateToggle({
		Name = 'Equipment',
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsTeammates = NameTags.CreateToggle({
		Name = 'Teammates',
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsDrawing = NameTags.CreateToggle({
		Name = 'Drawing',
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
	})
end)

run(function()
	local nobobdepth = {Value = 8}
	local nobobhorizontal = {Value = 8}
	local nobobvertical = {Value = -2}
	local rotationx = {Value = 0}
	local rotationy = {Value = 0}
	local rotationz = {Value = 0}
	local oldc1
	local oldfunc
	local nobob = vape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'NoBob',
		Function = function(callback)
			local viewmodel = camera:FindFirstChild('Viewmodel')
			if viewmodel then
				if callback then
					oldfunc = oldfunc or bedwars.ViewmodelController.playAnimation;
					if not shared.VapeFullyLoaded then 
						repeat task.wait() until shared.VapeFullyLoaded;
						task.wait(0.1);
					end;
					bedwars.ViewmodelController.playAnimation = function(self, animid, details)
						if animid == bedwars.AnimationType.FP_WALK then
							return
						end
						return oldfunc(self, animid, details)
					end
					bedwars.ViewmodelController:setHeldItem(lplr.Character and lplr.Character:FindFirstChild('HandInvItem') and lplr.Character.HandInvItem.Value and lplr.Character.HandInvItem.Value:Clone())
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', -(nobobdepth.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', (nobobhorizontal.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', (nobobvertical.Value / 10))
					oldc1 = viewmodel.RightHand.RightWrist.C1
					viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
				else
					bedwars.ViewmodelController.playAnimation = oldfunc
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', 0)
					viewmodel.RightHand.RightWrist.C1 = oldc1
				end
			end
		end,
		HoverText = 'Removes the ugly bobbing when you move and makes sword farther'
	})
	nobobdepth = nobob.CreateSlider({
		Name = 'Depth',
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', -(val / 10))
			end
		end
	})
	nobobhorizontal = nobob.CreateSlider({
		Name = 'Horizontal',
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', (val / 10))
			end
		end
	})
	nobobvertical= nobob.CreateSlider({
		Name = 'Vertical',
		Min = 0,
		Max = 24,
		Default = -2,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', (val / 10))
			end
		end
	})
	rotationx = nobob.CreateSlider({
		Name = 'RotX',
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				camera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationy = nobob.CreateSlider({
		Name = 'RotY',
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				camera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationz = nobob.CreateSlider({
		Name = 'RotZ',
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				camera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
end)

run(function()
	local SongBeats = {Enabled = false}
	local SongBeatsList = {ObjectList = {}}
	local SongBeatsIntensity = {Value = 5}
	local SongTween
	local SongAudio

	local function PlaySong(arg)
		local args = arg:split(':')
		local song = isfile(args[1]) and getcustomasset(args[1]) or tonumber(args[1]) and 'rbxassetid://'..args[1]
		if not song then
			warningNotification('SongBeats', 'missing music file '..args[1], 5)
			SongBeats.ToggleButton(false)
			return
		end
		local bpm = 1 / (args[2] / 60)
		SongAudio = Instance.new('Sound')
		SongAudio.SoundId = song
		SongAudio.Parent = workspace
		SongAudio:Play()
		repeat
			repeat task.wait() until SongAudio.IsLoaded or (not SongBeats.Enabled)
			if (not SongBeats.Enabled) then break end
			local newfov = math.min(bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1), 120)
			camera.FieldOfView = newfov - SongBeatsIntensity.Value
			if SongTween then SongTween:Cancel() end
			SongTween = tween:Create(camera, TweenInfo.new(0.2), {FieldOfView = newfov})
			SongTween:Play()
			task.wait(bpm)
		until (not SongBeats.Enabled) or SongAudio.IsPaused
	end

	SongBeats = vape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'SongBeats',
		Function = function(callback)
			if callback then
				task.spawn(function()
					if #SongBeatsList.ObjectList <= 0 then
						warningNotification('SongBeats', 'no songs', 5)
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
				camera.FieldOfView = bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1)
			end
		end
	})
	SongBeatsList = SongBeats.CreateTextList({
		Name = 'SongList',
		TempText = 'songpath:bpm'
	})
	SongBeatsIntensity = SongBeats.CreateSlider({
		Name = 'Intensity',
		Function = void,
		Min = 1,
		Max = 10,
		Default = 5
	})
end)

run(function()
	local performed = false
	vape.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'UICleanup',
		Function = function(callback)
			if callback and not performed then
				performed = true
				task.spawn(function()
					local hotbar = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-app']).HotbarApp
					local hotbaropeninv = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-open-inventory']).HotbarOpenInventory
					local topbarbutton = require(replicatedstorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out).TopBarButton
					local gametheme = require(replicatedstorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out.shared.ui['game-theme']).GameTheme
					bedwars.AppController:closeApp('TopBarApp')
					local oldrender = topbarbutton.render
					topbarbutton.render = function(self)
						local res = oldrender(self)
						if not self.props.Text then
							return bedwars.Roact.createElement('TextButton', {Visible = false}, {})
						end
						return res
					end
					hotbaropeninv.render = function(self)
						return bedwars.Roact.createElement('TextButton', {Visible = false}, {})
					end
					--[[debug.setconstant(hotbar.render, 52, 0.9975)
					debug.setconstant(hotbar.render, 73, 100)
					debug.setconstant(hotbar.render, 89, 1)
					debug.setconstant(hotbar.render, 90, 0.04)
					debug.setconstant(hotbar.render, 91, -0.03)
					debug.setconstant(hotbar.render, 109, 1.35)
					debug.setconstant(hotbar.render, 110, 0)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 30, 1)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 31, 0.175)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 33, -0.101)
					debug.setconstant(debug.getupvalue(hotbar.render, 18).render, 71, 0)
					debug.setconstant(debug.getupvalue(hotbar.render, 18).tweenPosition, 16, 0)]]
					gametheme.topBarBGTransparency = 0.5
					bedwars.TopBarController:mountHud()
					getservice('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
					bedwars.AbilityUIController.abilityButtonsScreenGui.Visible = false
					bedwars.MatchEndScreenController.waitUntilDisplay = function() return false end
					task.spawn(function()
						repeat
							task.wait()
							local gui = lplr.PlayerGui:FindFirstChild('StatusEffectHudScreen')
							if gui then gui.Enabled = false break end
						until false
					end)
					task.spawn(function()
						repeat task.wait() until store.matchState ~= 0
						if bedwars.ClientStoreHandler:getState().Game.customMatch == nil then
							debug.setconstant(bedwars.QueueCard.render, 15, 0.1)
						end
					end)
					local slot = bedwars.ClientStoreHandler:getState().Inventory.observedInventory.hotbarSlot
					bedwars.ClientStoreHandler:dispatch({
						type = 'InventorySelectHotbarSlot',
						slot = slot + 1 % 8
					})
					bedwars.ClientStoreHandler:dispatch({
						type = 'InventorySelectHotbarSlot',
						slot = slot
					})
				end)
			end
		end
	})
end)

run(function()
	local AntiAFK = {Enabled = false}
	AntiAFK = vape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AntiAFK',
		Function = function(callback)
			if callback then
				bedwars.Client:Get('AfkInfo'):SendToServer({
					afk = false
				})
			end
		end
	})
end)

run(function()
	local AutoBalloonPart
	local AutoBalloonConnection
	local AutoBalloonDelay = {Value = 10}
	local AutoBalloonLegit = {Enabled = false}
	local AutoBalloonypos = 0
	local balloondebounce = false
	local AutoBalloon = {Enabled = false}
	AutoBalloon = vape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoBalloon',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until store.matchState ~= 0 or  not vapeInjected
					if vapeInjected and AutoBalloonypos == 0 and AutoBalloon.Enabled then
						local lowestypos = 99999
						for i,v in (store.blocks) do
							local newray = workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), store.raycast)
							if i % 200 == 0 then
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						AutoBalloonypos = lowestypos - 8
					end
				end)
				task.spawn(function()
					repeat task.wait() until AutoBalloonypos ~= 0
					if AutoBalloon.Enabled then
						AutoBalloonPart = Instance.new('Part')
						AutoBalloonPart.CanCollide = false
						AutoBalloonPart.Size = Vector3.new(10000, 1, 10000)
						AutoBalloonPart.Anchored = true
						AutoBalloonPart.Transparency = 1
						AutoBalloonPart.Material = Enum.Material.Neon
						AutoBalloonPart.Color = Color3.fromRGB(135, 29, 139)
						AutoBalloonPart.Position = Vector3.new(0, AutoBalloonypos - 50, 0)
						AutoBalloonConnection = AutoBalloonPart.Touched:Connect(function(touchedpart)
							if entityLibrary.isAlive and touchedpart:IsDescendantOf(lplr.Character) and balloondebounce == false then
								autobankballoon = true
								balloondebounce = true
								local oldtool = store.localHand.tool
								for i = 1, 3 do
									if getItem('balloon') and (AutoBalloonLegit.Enabled and getHotbarSlot('balloon') or AutoBalloonLegit.Enabled == false) and (lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') < 3 or lplr.Character:GetAttribute('InflatedBalloons') == nil) then
										if AutoBalloonLegit.Enabled then
											if getHotbarSlot('balloon') then
												bedwars.ClientStoreHandler:dispatch({
													type = 'InventorySelectHotbarSlot',
													slot = getHotbarSlot('balloon')
												})
												task.wait(AutoBalloonDelay.Value / 100)
												bedwars.BalloonController:inflateBalloon()
											end
										else
											task.wait(AutoBalloonDelay.Value / 100)
											bedwars.BalloonController:inflateBalloon()
										end
									end
								end
								if AutoBalloonLegit.Enabled and oldtool and getHotbarSlot(oldtool.Name) then
									task.wait(0.2)
									bedwars.ClientStoreHandler:dispatch({
										type = 'InventorySelectHotbarSlot',
										slot = (getHotbarSlot(oldtool.Name) or 0)
									})
								end
								balloondebounce = false
								autobankballoon = false
							end
						end)
						AutoBalloonPart.Parent = workspace
					end
				end)
			else
				if AutoBalloonConnection then AutoBalloonConnection:Disconnect() end
				if AutoBalloonPart then
					AutoBalloonPart:Remove()
				end
			end
		end,
		HoverText = 'Automatically Inflates Balloons'
	})
	AutoBalloonDelay = AutoBalloon.CreateSlider({
		Name = 'Delay',
		Min = 1,
		Max = 50,
		Default = 20,
		Function = void,
		HoverText = 'Delay to inflate balloons.'
	})
	AutoBalloonLegit = AutoBalloon.CreateToggle({
		Name = 'Legit Mode',
		Function = void,
		HoverText = 'Switches to balloons in hotbar and inflates them.'
	})
end)

local autobankapple = false
run(function()
	local AutoBuy = {Enabled = false}
	local AutoBuyArmor = {Enabled = false}
	local AutoBuySword = {Enabled = false}
	local AutoBuyGen = {Enabled = false}
	local AutoBuyProt = {Enabled = false}
	local AutoBuySharp = {Enabled = false}
	local AutoBuyDestruction = {Enabled = false}
	local AutoBuyDiamond = {Enabled = false}
	local AutoBuyAlarm = {Enabled = false}
	local AutoBuyGui = {Enabled = false}
	local AutoBuyTierSkip = {Enabled = true}
	local AutoBuyRange = {Value = 20}
	local AutoBuyCustom = {ObjectList = {}, RefreshList = void}
	local AutoBankUIToggle = {Enabled = false}
	local AutoBankDeath = {Enabled = false}
	local AutoBankStay = {Enabled = false}
	local buyingthing = false
	local shoothook
	local bedwarsshopnpcs = {}
	local id
	local armors = {
		[1] = 'leather_chestplate',
		[2] = 'iron_chestplate',
		[3] = 'diamond_chestplate',
		[4] = 'emerald_chestplate'
	}

	local swords = {
		[1] = 'wood_sword',
		[2] = 'stone_sword',
		[3] = 'iron_sword',
		[4] = 'diamond_sword',
		[5] = 'emerald_sword'
	}

	local axes = {
		[1] = 'wood_axe',
		[2] = 'stone_axe',
		[3] = 'iron_axe',
		[4] = 'diamond_axe'
	}

	local pickaxes = {
		[1] = 'wood_pickaxe',
		[2] = 'stone_pickaxe',
		[3] = 'iron_pickaxe',
		[4] = 'diamond_pickaxe'
	}

	task.spawn(function()
		repeat task.wait() until store.matchState ~= 0 or not vapeInjected
		for i,v in (collection:GetTagged('BedwarsItemShop')) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = true, Id = v.Name})
		end
		for i,v in (collection:GetTagged('TeamUpgradeShopkeeper')) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = false, Id = v.Name})
		end
	end)

	local function nearNPC(range)
		local npc, npccheck, enchant, newid = nil, false, false, nil
		if entityLibrary.isAlive then
			local enchanttab = {}
			for i,v in (collection:GetTagged('broken-enchant-table')) do
				table.insert(enchanttab, v)
			end
			for i,v in (collection:GetTagged('enchant-table')) do
				table.insert(enchanttab, v)
			end
			for i,v in (enchanttab) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= 6 then
					if ((not v:GetAttribute('Team')) or v:GetAttribute('Team') == lplr:GetAttribute('Team')) then
						npc, npccheck, enchant = true, true, true
					end
				end
			end
			for i, v in (bedwarsshopnpcs) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= (range or 20) then
					npc, npccheck, enchant = true, (v.TeamUpgradeNPC or npccheck), false
					newid = v.TeamUpgradeNPC and v.Id or newid
				end
			end
			local suc, res = pcall(function() return lplr.leaderstats.Bed.Value == '✅'  end)
			if AutoBankDeath.Enabled and (workspace:GetServerTimeNow() - lplr.Character:GetAttribute('LastDamageTakenTime')) < 2 and suc and res then
				return nil, false, false
			end
			if AutoBankStay.Enabled then
				return nil, false, false
			end
		end
		return npc, not npccheck, enchant, newid
	end

	local function buyItem(itemtab, waitdelay)
		if not id then return end
		local res
		bedwars.Client:Get('BedwarsPurchaseItem'):CallServerAsync({
			shopItem = itemtab,
			shopId = id
		}):andThen(function(p11)
			if p11 then
				bedwars.SoundManager:playSound(bedwars.SoundList.BEDWARS_PURCHASE_ITEM)
				bedwars.ClientStoreHandler:dispatch({
					type = 'BedwarsAddItemPurchased',
					itemType = itemtab.itemType
				})
			end
			res = p11
		end)
		if waitdelay then
			repeat task.wait() until res ~= nil
		end
	end

	local function getAxeNear(inv)
		for i5, v5 in (inv or store.localInventory.inventory.items) do
			if v5.itemType:find('axe') and v5.itemType:find('pickaxe') == nil then
				return v5.itemType
			end
		end
		return nil
	end

	local function getPickaxeNear(inv)
		for i5, v5 in (inv or store.localInventory.inventory.items) do
			if v5.itemType:find('pickaxe') then
				return v5.itemType
			end
		end
		return nil
	end

	local function getShopItem(itemType)
		if itemType == 'axe' then
			itemType = getAxeNear() or 'wood_axe'
			itemType = axes[table.find(axes, itemType) + 1] or itemType
		end
		if itemType == 'pickaxe' then
			itemType = getPickaxeNear() or 'wood_pickaxe'
			itemType = pickaxes[table.find(pickaxes, itemType) + 1] or itemType
		end
		for i,v in (bedwars.ShopItems) do
			if v.itemType == itemType then return v end
		end
		return nil
	end

	local buyfunctions = {
		Armor = function(inv, upgrades, shoptype)
			if AutoBuyArmor.Enabled == false or shoptype ~= 'item' then return end
			local currentarmor = (typeof(inv.armor[2]) == 'table' and inv.armor[2].itemType:find('chestplate') ~= nil) and inv.armor[2] or nil
			local armorindex = (currentarmor and table.find(armors, currentarmor.itemType) or 0) + 1
			if armors[armorindex] == nil then return end
			local highestbuyable = nil
			for i = armorindex, #armors, 1 do
				local shopitem = getShopItem(armors[i])
				if shopitem and i == armorindex then
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price then
						highestbuyable = shopitem
						bedwars.ClientStoreHandler:dispatch({
							type = 'BedwarsAddItemPurchased',
							itemType = shopitem.itemType
						})
					end
				end
			end
			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, store.equippedKit) == nil) then
				buyItem(highestbuyable)
			end
		end,
		Sword = function(inv, upgrades, shoptype)
			if AutoBuySword.Enabled == false or shoptype ~= 'item' then return end
			local currentsword = getItemNear('sword', inv.items)
			local swordindex = (currentsword and table.find(swords, currentsword.itemType) or 0) + 1
			if currentsword ~= nil and table.find(swords, currentsword.itemType) == nil then return end
			local highestbuyable = nil
			for i = swordindex, #swords, 1 do
				local shopitem = getShopItem(swords[i])
				if shopitem and i == swordindex then
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price and (shopitem.category ~= 'Armory' or chestenginetrash or upgrades.armory) then
						highestbuyable = shopitem
						bedwars.ClientStoreHandler:dispatch({
							type = 'BedwarsAddItemPurchased',
							itemType = shopitem.itemType
						})
					end
				end
			end
			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, store.equippedKit) == nil) then
				buyItem(highestbuyable)
			end
		end
	}

	AutoBuy = vape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoBuy',
		Function = function(callback)
			if callback then
				buyingthing = false
				task.spawn(function()
					repeat
						task.wait()
						local found, npctype, enchant, newid = nearNPC(AutoBuyRange.Value)
						id = newid
						if found then
							local inv = store.localInventory.inventory
							local currentupgrades = cheatenginetrash == nil and bedwars.ClientStoreHandler:getState().Bedwars.teamUpgrades;
							if store.equippedKit == 'dasher' then
								swords = {
									[1] = 'wood_dao',
									[2] = 'stone_dao',
									[3] = 'iron_dao',
									[4] = 'diamond_dao',
									[5] = 'emerald_dao'
								}
							elseif store.equippedKit == 'ice_queen' then
								swords[5] = 'ice_sword'
							elseif store.equippedKit == 'ember' then
								swords[5] = 'infernal_saber'
							elseif store.equippedKit == 'lumen' then
								swords[5] = 'light_sword'
							end
							if (AutoBuyGui.Enabled == false or (bedwars.AppController:isAppOpen('BedwarsItemShopApp') or bedwars.AppController:isAppOpen('BedwarsTeamUpgradeApp'))) and (not enchant) then
								for i,v in (AutoBuyCustom.ObjectList) do
									local autobuyitem = v:split('/')
									if #autobuyitem >= 3 and autobuyitem[4] ~= 'true' then
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == 'wool_white' and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
								for i,v in (buyfunctions) do v(inv, currentupgrades, npctype and 'upgrade' or 'item') end
								for i,v in (AutoBuyCustom.ObjectList) do
									local autobuyitem = v:split('/')
									if #autobuyitem >= 3 and autobuyitem[4] == 'true' then
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == 'wool_white' and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
							end
						end
					until (not AutoBuy.Enabled)
				end)
			end
		end,
		HoverText = 'Automatically Buys Swords, Armor, and Team Upgrades\nwhen you walk near the NPC'
	})
	AutoBuyRange = AutoBuy.CreateSlider({
		Name = 'Range',
		Function = void,
		Min = 1,
		Max = 20,
		Default = 20
	})
	AutoBuyArmor = AutoBuy.CreateToggle({
		Name = 'Buy Armor',
		Function = void,
		Default = true
	})
	AutoBuySword = AutoBuy.CreateToggle({
		Name = 'Buy Sword',
		Function = void,
		Default = true
	})
	AutoBuyGui = AutoBuy.CreateToggle({
		Name = 'Shop GUI Check',
		Function = void,
	})
	AutoBuyTierSkip = AutoBuy.CreateToggle({
		Name = 'Tier Skip',
		Function = void,
		Default = true
	})
	AutoBuyCustom = AutoBuy.CreateTextList({
		Name = 'BuyList',
		TempText = 'item/amount/priority/after',
		SortFunction = function(a, b)
			local amount1 = a:split('/')
			local amount2 = b:split('/')
			amount1 = #amount1 and tonumber(amount1[3]) or 1
			amount2 = #amount2 and tonumber(amount2[3]) or 1
			return amount1 < amount2
		end
	})
	AutoBuyCustom.Object.AddBoxBKG.AddBox.TextSize = 14
end)

run(function()
	local AutoConsume = {Enabled = false}
	local AutoConsumeHealth = {Value = 100}
	local AutoConsumeSpeed = {Enabled = true}
	local AutoConsumeDelay = tick()

	local function AutoConsumeFunc()
		if entityLibrary.isAlive then
			local speedpotion = getItem('speed_potion')
			if lplr.Character:GetAttribute('Health') <= (lplr.Character:GetAttribute('MaxHealth') - (100 - AutoConsumeHealth.Value)) then
				autobankapple = true
				local item = getItem('apple')
				local pot = getItem('heal_splash_potion')
				if (item or pot) and AutoConsumeDelay <= tick() then
					if item then
						bedwars.Client:Get(bedwars.EatRemote):CallServerAsync({
							item = item.tool
						})
						AutoConsumeDelay = tick() + 0.6
					else
						local newray = workspace:Raycast((oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -76, 0), store.raycast)
						if newray ~= nil then
							bedwars.Client:Get(bedwars.ProjectileRemote):CallServerAsync(pot.tool, 'heal_splash_potion', 'heal_splash_potion', (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -70, 0), getservice('HttpService'):GenerateGUID(), {drawDurationSeconds = 1})
						end
					end
				end
			else
				autobankapple = false
			end
			if speedpotion and (not lplr.Character:GetAttribute('StatusEffect_speed')) and AutoConsumeSpeed.Enabled then
				bedwars.Client:Get(bedwars.EatRemote):CallServerAsync({
					item = speedpotion.tool
				})
			end
			if lplr.Character:GetAttribute('Shield_POTION') and ((not lplr.Character:GetAttribute('Shield_POTION')) or lplr.Character:GetAttribute('Shield_POTION') == 0) then
				local shield = getItem('big_shield') or getItem('mini_shield')
				if shield then
					bedwars.Client:Get(bedwars.EatRemote):CallServerAsync({
						item = shield.tool
					})
				end
			end
		end
	end

	AutoConsume = vape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoConsume',
		Function = function(callback)
			if callback then
				table.insert(AutoConsume.Connections, vapeEvents.InventoryAmountChanged.Event:Connect(AutoConsumeFunc))
				table.insert(AutoConsume.Connections, vapeEvents.AttributeChanged.Event:Connect(function(changed)
					if changed:find('Shield') or changed:find('Health') or changed:find('speed') then
						AutoConsumeFunc()
					end
				end))
				AutoConsumeFunc()
			end
		end,
		HoverText = 'Automatically heals for you when health or shield is under threshold.'
	})
	AutoConsumeHealth = AutoConsume.CreateSlider({
		Name = 'Health',
		Min = 1,
		Max = 99,
		Default = 70,
		Function = void
	})
	AutoConsumeSpeed = AutoConsume.CreateToggle({
		Name = 'Speed Potions',
		Function = void,
		Default = true
	})
end)

run(function()
	local AutoHotbarList = {Hotbars = {}, CurrentlySelected = 1}
	local AutoHotbarMode = {Value = 'Toggle'}
	local AutoHotbarClear = {Enabled = false}
	local AutoHotbar = {Enabled = false}
	local AutoHotbarActive = false

	local function getCustomItem(v2)
		local realitem = v2.itemType
		if realitem == 'swords' then
			local sword = getSword()
			realitem = sword and sword.itemType or 'wood_sword'
		elseif realitem == 'pickaxes' then
			local pickaxe = getPickaxe()
			realitem = pickaxe and pickaxe.itemType or 'wood_pickaxe'
		elseif realitem == 'axes' then
			local axe = getAxe()
			realitem = axe and axe.itemType or 'wood_axe'
		elseif realitem == 'bows' then
			local bow = getBow()
			realitem = bow and bow.itemType or 'wood_bow'
		elseif realitem == 'wool' then
			realitem = getWool() or 'wool_white'
		end
		return realitem
	end

	local function findItemInTable(tab, item)
		for i, v in (tab) do
			if v and v.itemType then
				if item.itemType == getCustomItem(v) then
					return i
				end
			end
		end
		return nil
	end

	local function findinhotbar(item)
		for i,v in (store.localInventory.hotbar) do
			if v.item and v.item.itemType == item.itemType then
				return i, v.item
			end
		end
	end

	local function findininventory(item)
		for i,v in (store.localInventory.inventory.items) do
			if v.itemType == item.itemType then
				return v
			end
		end
	end

	local function AutoHotbarSort()
		task.spawn(function()
			if AutoHotbarActive then return end
			AutoHotbarActive = true
			local items = (AutoHotbarList.Hotbars[AutoHotbarList.CurrentlySelected] and AutoHotbarList.Hotbars[AutoHotbarList.CurrentlySelected].Items or {})
			for i, v in (store.localInventory.inventory.items) do
				local customItem
				local hotbarslot = findItemInTable(items, v)
				if hotbarslot then
					local oldhotbaritem = store.localInventory.hotbar[tonumber(hotbarslot)]
					if oldhotbaritem.item and oldhotbaritem.item.itemType == v.itemType then continue end
					if oldhotbaritem.item then
						bedwars.ClientStoreHandler:dispatch({
							type = 'InventoryRemoveFromHotbar',
							slot = tonumber(hotbarslot) - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					local newhotbaritemslot, newhotbaritem = findinhotbar(v)
					if newhotbaritemslot then
						bedwars.ClientStoreHandler:dispatch({
							type = 'InventoryRemoveFromHotbar',
							slot = newhotbaritemslot - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					if oldhotbaritem.item and newhotbaritemslot then
						local nextitem1, nextitem1num = findininventory(oldhotbaritem.item)
						bedwars.ClientStoreHandler:dispatch({
							type = 'InventoryAddToHotbar',
							item = nextitem1,
							slot = newhotbaritemslot - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					local nextitem2, nextitem2num = findininventory(v)
					bedwars.ClientStoreHandler:dispatch({
						type = 'InventoryAddToHotbar',
						item = nextitem2,
						slot = tonumber(hotbarslot) - 1
					})
					vapeEvents.InventoryChanged.Event:Wait()
				else
					if AutoHotbarClear.Enabled then
						local newhotbaritemslot, newhotbaritem = findinhotbar(v)
						if newhotbaritemslot then
							bedwars.ClientStoreHandler:dispatch({
								type = 'InventoryRemoveFromHotbar',
								slot = newhotbaritemslot - 1
							})
							vapeEvents.InventoryChanged.Event:Wait()
						end
					end
				end
			end
			AutoHotbarActive = false
		end)
	end

	AutoHotbar = vape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoHotbar',
		Function = function(callback)
			if callback then
				AutoHotbarSort()
				if AutoHotbarMode.Value == 'On Key' then
					if AutoHotbar.Enabled then
						AutoHotbar.ToggleButton(false)
					end
				else
					table.insert(AutoHotbar.Connections, vapeEvents.InventoryAmountChanged.Event:Connect(function()
						if not AutoHotbar.Enabled then return end
						AutoHotbarSort()
					end))
				end
			end
		end,
		HoverText = 'Automatically arranges hotbar to your liking.'
	})
	AutoHotbarMode = AutoHotbar.CreateDropdown({
		Name = 'Activation',
		List = {'On Key', 'Toggle'},
		Function = function(val)
			if AutoHotbar.Enabled then
				AutoHotbar.ToggleButton(false)
				AutoHotbar.ToggleButton(false)
			end
		end
	})
	AutoHotbarList = CreateAutoHotbarGUI(AutoHotbar.Children, {
		Name = 'lol'
	})
	AutoHotbarClear = AutoHotbar.CreateToggle({
		Name = 'Clear Hotbar',
		Function = void
	})
end)

run(function()
	local AutoKit = {}
	local HannahExploitCheck = {}
	local HannahExploitRange = {Value = 50}
	local EvelynnExploitRange = {Value = 50}
	local AutoKitToggles = {}
	local healtick = tick()
	local function lowestTeamate()
		local health, lowest = math.huge, nil
		for i,v in players:GetPlayers() do 
			if v ~= lplr and v:GetAttribute('Team') == lplr:GetAttribute('Team') and isAlive(v) then 
				local h = v.Character:GetAttribute('Health') 
				local max = v.Character:GetAttribute('MaxHealth')
				local magnitude = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
				if h < max and h < health and magnitude < 30 then 
					health = h 
					lowest = v
				end
			end
		end
		return lowest
	end
	local function getTeamate()
		local magnitude, teamate = math.huge, nil
		for i,v in players:GetPlayers() do 
			if v ~= lplr and v:GetAttribute('Team') == lplr:GetAttribute('Team') and isAlive(v) then 
				local m = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude 
				if m < magnitude and mag < 45 then 
					magnitude = m 
					teamate = v
				end
			end
		end
		return teamate
	end
	local betterkitnames = {
		melody = 'Melody',
		bigman = 'Elder Tree',
		metal_detector = 'Metal Detector',
		battery = 'Cobalt',
		grim_reaper = 'Grim Reaper',
		farmer_cletus = 'Farmer Cletus',
		dragon_slayer = 'Kaliyah',
		mage = 'Whim',
		angel = 'Trinity',
		miner = 'Miner',
		hannah = 'Hannah',
		jailor = 'Warden',
		warlock = 'Eldric',
		necromancer = 'Crypt',
		pinata = 'Lucia',
		spirit_assassin = 'Evelynn'
	}
	local autokitstuff = {
		melody = function()
			repeat
				task.wait(0.1)
				if getItem('guitar') then
					local plr = lowestTeamate()
					if plr and healtick <= tick() then 
						bedwars.Client:Get(bedwars.GuitarHealRemote):SendToServer({
							healTarget = plr.Character
						})
						healtick = tick() + 2
					end
				end
			until not AutoKit.Enabled
		end,
		bigman = function() 
			repeat
				task.wait()
				for i,v in collection:GetTagged('treeOrb') do
					if isAlive(lplr, true) and v:FindFirstChild('Spirit') and (lplr.Character.HumanoidRootPart.Position - v.Spirit.Position).Magnitude <= 20 then
						if bedwars.Client:Get(bedwars.TreeRemote):CallServer({treeOrbSecret = v:GetAttribute('TreeOrbSecret')}) then
							v:Destroy()
							collection:RemoveTag(v, 'treeOrb')
						end
					end
				end
			until not AutoKit.Enabled
		end,
		metal_detector = function()
			repeat
				task.wait()
				for i,v in collection:GetTagged('hidden-metal') do
					if isAlive(lplr, true) and v.PrimaryPart and (lplr.Character.HumanoidRootPart.Position - v.PrimaryPart.Position).Magnitude <= 20 then
						bedwars.Client:Get(bedwars.PickupMetalRemote):SendToServer({
							id = v:GetAttribute('Id')
						}) 
					end
				end
			until not AutoKit.Enabled
		end,
		battery = function()
			repeat
				task.wait()
				for i,v in bedwars.BatteryEffectController.liveBatteries do
					if isAlive(lplr, true) and (lplr.Character.HumanoidRootPart.Position - v.position).Magnitude <= 10 then
						bedwars.Client:Get(bedwars.BatteryRemote):SendToServer({
							batteryId = i
						})
					end
				end
			until not AutoKit.Enabled
		end, 
		grim_reaper = function()
			repeat
				task.wait()
				for i,v in bedwars.GrimReaperController.soulsByPosition do
					if isAlive(lplr, true) and lplr.Character:GetAttribute('Health') <= (lplr.Character:GetAttribute('MaxHealth') - 10) and v.PrimaryPart and (lplr.Character.HumanoidRootPart.Position - v.PrimaryPart.Position).Magnitude <= 120 and (not lplr.Character:GetAttribute('GrimReaperChannel')) and not isEnabled('InfiniteFly') then
						bedwars.Client:Get(bedwars.ConsumeSoulRemote):CallServer({
							secret = v:GetAttribute('GrimReaperSoulSecret')
						})
						v:Destroy()
					end
				end
			until not AutoKit.Enabled
		end,
		farmer_cletus = function()
			repeat
				task.wait()
				for i,v in collection:GetTagged('BedwarsHarvestableCrop') do
					if isAlive(lplr, true) and (lplr.Character.HumanoidRootPart.Position - v.Position).Magnitude <= 10 then
						bedwars.Client:Get('BedwarsHarvestCrop'):CallServerAsync({
							position = bedwars.BlockController:getBlockPosition(v.Position)
						}):andThen(function(suc)
							if suc then
								bedwars.GameAnimationUtil.playAnimation(lplr.Character, 1)
								bedwars.SoundManager:playSound(bedwars.SoundList.CROP_HARVEST)
							end
						end)
					end
				end
			until not AutoKit.Enabled
		end,
		dragon_slayer = function()
			repeat
				task.wait(0.1)
				if isAlive(lplr, true) then
					for i,v in bedwars.DragonSlayerController.dragonEmblems do 
						if v.stackCount >= 3 then 
							bedwars.DragonSlayerController:deleteEmblem(i)
							local localPos = lplr.Character:GetPrimaryPartCFrame().Position
							local punchCFrame = CFrame.new(localPos, (i:GetPrimaryPartCFrame().Position * Vector3.new(1, 0, 1)) + Vector3.new(0, localPos.Y, 0))
							lplr.Character:SetPrimaryPartCFrame(punchCFrame)
							bedwars.DragonSlayerController:playPunchAnimation(punchCFrame - punchCFrame.Position)
							bedwars.Client:Get(bedwars.DragonRemote):SendToServer({
								target = i
							})
						end
					end
				end
			until not AutoKit.Enabled
		end,
		mage = function()
			repeat
				task.wait(0.1)
				if isAlive(lplr, true) then
					for i, v in collection:GetTagged('TomeGuidingBeam') do 
						local obj = v.Parent and v.Parent.Parent and v.Parent.Parent.Parent
						if obj and (lplr.Character.HumanoidRootPart.Position - obj.PrimaryPart.Position).Magnitude < 5 and obj:GetAttribute('TomeSecret') then
							local res = bedwars.Client:Get(bedwars.MageRemote):CallServer({secret = obj:GetAttribute('TomeSecret')})
							if res.success and res.element then 
								bedwars.GameAnimationUtil.playAnimation(lplr, bedwars.AnimationType.PUNCH)
								bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
								bedwars.MageController:destroyTomeGuidingBeam()
								bedwars.MageController:playLearnLightBeamEffect(lplr, obj)
								local sound = bedwars.MageKitUtil.MageElementVisualizations[res.element].learnSound
								if sound and sound ~= '' then 
									bedwars.SoundManager:playSound(sound)
								end
								task.delay(bedwars.BalanceFile.LEARN_TOME_DURATION, function()
									bedwars.MageController:fadeOutTome(obj)
									if lplr.Character and res.element then
										bedwars.MageKitUtil.changeMageKitAppearance(lplr, lplr.Character, res.element)	
									end
								end)
							end
						end
					end
				end
			until not AutoKit.Enabled
		end,
		angel = function()
			table.insert(AutoKit.Connections, vapeEvents.AngelProgress.Event:Connect(function()
				task.wait(0.5)
				if not AutoKit.Enabled then return end
				local objectTable = AutoKitToggles.angel.Objects
				local ability = 'Void'
				for i,v in objectTable do 
					if i:find('Ability') then 
						ability = v.Value 
						break
					end
				end
				if bedwars.ClientStoreHandler:getState().Kit.angelProgress >= 1 and lplr.Character:GetAttribute('AngelType') == nil then
					bedwars.Client:Get(bedwars.TrinityRemote):SendToServer({
						angel = ability
					})
				end
			end))
		end,
		miner = function()
			repeat
				task.wait(0.1)
				if isAlive(lplr, true) then
					for i,v in collection:GetTagged('petrified-player') do 
						bedwars.Client:Get(bedwars.MinerRemote):SendToServer({
							petrifyId = v:GetAttribute('PetrifyId')
						})
					end
				end
			until not AutoKit.Enabled
		end,
		hannah = function()
			repeat 
				for i,v in collection:GetTagged('HannahExecuteInteraction') do 
					local successful, player = pcall(players.GetPlayerFromCharacter, players, v);
					if successful then 
						if RenderLibrary.whitelist:get(2, player) then 
							task.spawn(function()
								bedwars.Client:Get('HannahPromptTrigger'):CallServerAsync({
									user = lplr, 
									victimEntity = v
								});
							end)
						end
					end
				end
				task.wait(0.1)
			until (not AutoKit.Enabled)
		end,
		jailor = function()
			table.insert(AutoKit.Connections, workspace.DescendantAdded:Connect(function(v)
				if tostring(v.Parent) ~= 'JailorSoul' or not v:IsA('ProximityPrompt') or not isAlive() then 
					return 
				end
				local soul = v.Parent:GetAttribute('Id')
				repeat 
					bedwars.Client:Get('CollectCollectableEntity'):SendToServer({id = soul, collectableName = 'JailorSoul'}) 
					task.wait(0.1)
				until v.Parent == nil or not isAlive() or not AutoKit.Enabled
			end))
		end,
		necromancer = function()
			repeat 
				for i,v in collection:GetTagged('Gravestone') do
					if v.PrimaryPart and isAlive() and not isEnabled('InfiniteFly') then
						local magnitude = (lplr.Character.HumanoidRootPart.Position - v.PrimaryPart.Position).Magnitude 
						local plr = players:GetPlayerByUserId(v:GetAttribute('GravestonePlayerUserId')) 
						if plr and not RenderLibrary.whitelist:get(2, plr) or magnitude > 17 then 
							continue
						end
						bedwars.Client:Get('ActivateGravestone'):CallServer({
							skeletonData = {
								armorType = v:GetAttribute('ArmorType'),
								weaponType = v:GetAttribute('SwordType'),
								associatedPlayerUserId = v:GetAttribute('GravestonePlayerUserId')
							},
							position = v:GetAttribute('GravestonePosition'),
							secret = v:GetAttribute('GravestoneSecret')
						})
					end
				end 
				task.wait(0.1) 
			until not AutoKit.Enabled
		end,
		pinata = function()
			repeat 
				for i,v in collection:GetTagged(lplr.Name..':pinata') do 
					if getItem('candy') then 
						bedwars.Client:Get('DepositCoins'):CallServer(v)
					end
				end
				task.wait(0.1)
			until not AutoKit.Enabled
		end,
		spirit_assassin = function()
			repeat 
				for i,v in collection:GetTagged('EvelynnSoul') do 
					if isAlive(lplr, true) and not isEnabled('InfiniteFly') then 
						if bedwars.Client:Get('UseSpirit'):CallServer({secret = v:GetAttribute('SpiritSecret')}) then 
							collection:RemoveTag(v, 'EvelynnSoul') 
							v:Destroy()
						end
					end
				end
				task.wait(0.1)
			until not AutoKit.Enabled
		end
	}
	local function autoKitCreateObject(args)
		local objectTable = AutoKitToggles[args.Kit].Objects
		task.spawn(function()
			repeat 
				local kit = store.equippedKit
				if vapeInjected and kit ~= 'none' then
					local object = AutoKit[args.Method](args)
					objectTable[object.Object.Name] = object
					break 
				end
				task.wait()
			until not vapeInjected 
		end)
	end
	AutoKit = vape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoKit',
		ExtraText = function()
			local kit = lplr:GetAttribute('PlayingAsKit') or store.equippedKit or 'none';
			if autokitstuff[kit] and AutoKitToggles[kit].MainToggle.Enabled then 
				return betterkitnames[kit] or kit 
			end
			return 'none'
		end,
		HoverText = 'Automatically uses kit abilities',
		Function = function(calling)
			if calling then 
				repeat
					local kit = lplr:GetAttribute('PlayingAsKit') or store.equippedKit or 'none';
					if AutoKit.Enabled and autokitstuff[kit] and kit ~= 'none' then 
						if AutoKitToggles[kit].MainToggle.Enabled then 
							task.spawn(autokitstuff[kit])
						end
						break 
					end
					task.wait()
				until not AutoKit.Enabled
			end
		end
	})
	for i,v in autokitstuff do 
		AutoKitToggles[i] = {Objects = {}}
		AutoKitToggles[i].MainToggle = AutoKit.CreateToggle({
			Name = betterkitnames[i] or i,
			HoverText = 'Toggle for AutoKit to use this kit.',
			Default = true,
			Function = function(calling)
				task.delay(calling and 0.001 or 1, function()
					if AutoKit.Enabled then
						AutoKit.ToggleButton()
						AutoKit.ToggleButton()
					end 
				end)
			end 
		})
		task.spawn(function()
			repeat task.wait() until shared.VapeFullyLoaded
			repeat
				local kit = lplr:GetAttribute('PlayingAsKit') or store.equippedKit or 'none';
				if vapeInjected and kit ~= 'none' and AutoKitToggles[i] then 
					AutoKitToggles[i].MainToggle.Object.Visible = (kit == i)  
					for i2, v2 in AutoKitToggles[i].Objects do 
						if v2.Object.Visible then 
							v2.Object.Visible = (kit == i)   
						end
					end
					break 
				end
				task.wait()
			until not vapeInjected
		end)
	end
	HannahExploitCheck = autoKitCreateObject({
		Name = 'Range Check',
		Method = 'CreateToggle',
		Kit = 'hannah',
		Default = true,
		Function = function(calling) 
			pcall(function() HannahExploitRange.Object.Visible = calling end)
		end
	})
	HannahExploitRange = autoKitCreateObject({
		Name = 'Range',
		Method = 'CreateSlider',
		Kit = 'hannah',
		Min = 10,
		Max = 100, 
		Default = 50,
		Function = function() end
	})
end)

--[[run(function()
	local AutoForge = {Enabled = false}
	local AutoForgeWeapon = {Value = 'Sword'}
	local AutoForgeBow = {Enabled = false}
	local AutoForgeArmor = {Enabled = false}
	local AutoForgeSword = {Enabled = false}
	local AutoForgeBuyAfter = {Enabled = false}
	local AutoForgeNotification = {Enabled = true}

	local function buyForge(i)
		if not store.forgeUpgrades[i] or store.forgeUpgrades[i] < 6 then
			local cost = bedwars.ForgeUtil:getUpgradeCost(1, store.forgeUpgrades[i] or 0)
			if store.forgeMasteryPoints >= cost then
				if AutoForgeNotification.Enabled then
					local forgeType = 'none'
					for name,v in (bedwars.ForgeConstants) do
						if v == i then forgeType = name:lower() end
					end
					warningNotification('AutoForge', 'Purchasing '..forgeType..'.', bedwars.ForgeUtil.FORGE_DURATION_SEC)
				end
				bedwars.Client:Get('ForgePurchaseUpgrade'):SendToServer(i)
				task.wait(bedwars.ForgeUtil.FORGE_DURATION_SEC + 0.2)
			end
		end
	end

	AutoForge = vape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoForge',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if store.matchState == 1 and entityLibrary.isAlive then
							if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
							if AutoForgeArmor.Enabled then buyForge(bedwars.ForgeConstants.ARMOR) end
							if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
							if AutoForgeBow.Enabled then buyForge(bedwars.ForgeConstants.RANGED) end
							if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
							if AutoForgeSword.Enabled then
								if AutoForgeBuyAfter.Enabled then
									if not store.forgeUpgrades[bedwars.ForgeConstants.ARMOR] or store.forgeUpgrades[bedwars.ForgeConstants.ARMOR] < 6 then continue end
								end
								local weapon = bedwars.ForgeConstants[AutoForgeWeapon.Value:upper()]
								if weapon then buyForge(weapon) end
							end
						end
					until (not AutoForge.Enabled)
				end)
			end
		end
	})
	AutoForgeWeapon = AutoForge.CreateDropdown({
		Name = 'Weapon',
		Function = void,
		List = {'Sword', 'Dagger', 'Scythe', 'Great_Hammer', 'Gauntlets'}
	})
	AutoForgeArmor = AutoForge.CreateToggle({
		Name = 'Armor',
		Function = void,
		Default = true
	})
	AutoForgeSword = AutoForge.CreateToggle({
		Name = 'Weapon',
		Function = void
	})
	AutoForgeBow = AutoForge.CreateToggle({
		Name = 'Bow',
		Function = void
	})
	AutoForgeBuyAfter = AutoForge.CreateToggle({
		Name = 'Buy After',
		Function = void,
		HoverText = 'buy a weapon after armor is maxed'
	})
	AutoForgeNotification = AutoForge.CreateToggle({
		Name = 'Notification',
		Function = void,
		Default = true
	})
end)]]	

run(function()
	local alreadyreportedlist = {};
	local AutoReportV2 = {Enabled = false};
	local AutoReportV2Notify = {Enabled = false};
	local olderror
	AutoReportV2 = vape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoReportV2',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						for i,v in (players:GetPlayers()) do
							if v ~= lplr and alreadyreportedlist[v] == nil and v:GetAttribute('PlayerConnected') and whitelist:get(v) == 0 then
								task.wait(1)
								alreadyreportedlist[v] = true
								olderror = getmetatable(bedwars.NotificationController).sendErrorNotification;
								getmetatable(bedwars.NotificationController).sendErrorNotification = function(self, args, ...)
									if typeof(args) == 'table' and args.message and args.message:lower():find('player') then 
										return 
									end;
									return olderror(self, args, ...)
								end;
								bedwars.Client:Get(bedwars.ReportRemote):SendToServer(v.UserId)
								store.statistics.reported = store.statistics.reported + 1
								if AutoReportV2Notify.Enabled then
									warningNotification('AutoReportV2', 'Reported '..v.Name, 15)
								end;
							end
						end
					until (not AutoReportV2.Enabled)
				end)
			else 
				getmetatable(bedwars.NotificationController).sendErrorNotification = olderror;
			end
		end,
		HoverText = 'dv mald'
	})
	AutoReportV2Notify = AutoReportV2.CreateToggle({
		Name = 'Notify',
		Function = void
	})
end)

run(function()
	local justsaid = ''
	local leavesaid = false
	local alreadyreported = {}

	local function removerepeat(str)
		local newstr = ''
		local lastlet = ''
		for i,v in next, (str:split('')) do 
			if v ~= lastlet then
				newstr = newstr..v 
				lastlet = v
			end
		end
		return newstr
	end

	local reporttable = {
		gay = 'Bullying',
		gae = 'Bullying',
		gey = 'Bullying',
		hack = 'Scamming',
		exploit = 'Scamming',
		cheat = 'Scamming',
		hecker = 'Scamming',
		haxker = 'Scamming',
		hacer = 'Scamming',
		report = 'Bullying',
		fat = 'Bullying',
		black = 'Bullying',
		getalife = 'Bullying',
		fatherless = 'Bullying',
		report = 'Bullying',
		fatherless = 'Bullying',
		disco = 'Offsite Links',
		yt = 'Offsite Links',
		dizcourde = 'Offsite Links',
		retard = 'Swearing',
		bad = 'Bullying',
		trash = 'Bullying',
		nolife = 'Bullying',
		nolife = 'Bullying',
		loser = 'Bullying',
		killyour = 'Bullying',
		kys = 'Bullying',
		hacktowin = 'Bullying',
		bozo = 'Bullying',
		kid = 'Bullying',
		adopted = 'Bullying',
		linlife = 'Bullying',
		commitnotalive = 'Bullying',
		vape = 'Offsite Links',
		futureclient = 'Offsite Links',
		download = 'Offsite Links',
		youtube = 'Offsite Links',
		die = 'Bullying',
		lobby = 'Bullying',
		ban = 'Bullying',
		wizard = 'Bullying',
		wisard = 'Bullying',
		witch = 'Bullying',
		magic = 'Bullying',
	}
	local reporttableexact = {
		L = 'Bullying',
	}

	local rendermessages = {
		[1] = {'cry me a river <name>', 'boo hooo <name>', 'womp womp <name>', 'I could care less <name>.'}
	}

	local function findreport(msg)
		local checkstr = removerepeat(msg:gsub('%W+', ''):lower())
		for i,v in next, (reporttable) do 
			if checkstr:find(i) then 
				return v, i
			end
		end
		for i,v in next, (reporttableexact) do 
			if checkstr == i then 
				return v, i
			end
		end
		for i,v in next, (AutoToxicPhrases5.ObjectList) do 
			if checkstr:find(v) then 
				return 'Bullying', v
			end
		end
		return nil
	end

	AutoToxic = vape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoToxic',
		Function = function(calling)
			if calling then 
				table.insert(AutoToxic.Connections, render.events.message.Event:Connect(function(plr, text)
					if AutoToxicRespond.Enabled then
						local args = text:split(' ')
						if plr and plr ~= lplr and not alreadyreported[plr] then
							local reportreason, reportedmatch = findreport(text)
							if reportreason then 
								alreadyreported[plr] = true
								local custommsg = #AutoToxicPhrases4.ObjectList > 0 and AutoToxicPhrases4.ObjectList[math.random(1, #AutoToxicPhrases4.ObjectList)]
								if custommsg then
									custommsg = custommsg:gsub('<name>', (plr.DisplayName or plr.Name))
								end
								local msg = (custommsg or getrandomvalue(rendermessages[1]):gsub('<name>', plr.DisplayName)..' | renderintents.lol')
								sendmessage(msg)
							end
						end
					end
				end));
				table.insert(AutoToxic.Connections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if AutoToxicBedDestroyed.Enabled and bedTable.brokenBedTeam.id == lplr:GetAttribute('Team') then
						local custommsg = #AutoToxicPhrases6.ObjectList > 0 and AutoToxicPhrases6.ObjectList[math.random(1, #AutoToxicPhrases6.ObjectList)] or 'Who needs a bed when you got Render <name>? | renderintents.lol'
						if custommsg then
							custommsg = custommsg:gsub('<name>', (bedTable.player.DisplayName or bedTable.player.Name))
						end
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
					elseif AutoToxicBedBreak.Enabled and bedTable.player.UserId == lplr.UserId then
						local custommsg = #AutoToxicPhrases7.ObjectList > 0 and AutoToxicPhrases7.ObjectList[math.random(1, #AutoToxicPhrases7.ObjectList)] or 'Your bed has been sent to the abyss <teamname>! | renderintents.lol'
						if custommsg then
							local team = bedwars.QueueMeta[bedwarsStore.queueType].teams[tonumber(bedTable.brokenBedTeam.id)]
							local teamname = team and team.displayName:lower() or 'white'
							custommsg = custommsg:gsub('<teamname>', teamname)
						end
						sendmessage(custommsg)
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = players:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = players:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed == lplr then 
							if (not leavesaid) and killer ~= lplr and AutoToxicDeath.Enabled then
								leavesaid = true
								local custommsg = #AutoToxicPhrases3.ObjectList > 0 and AutoToxicPhrases3.ObjectList[math.random(1, #AutoToxicPhrases3.ObjectList)] or 'I was too laggy <name>. That\'s why you won. | renderintents.lol'
								if custommsg then
									custommsg = custommsg:gsub('<name>', (killer.DisplayName or killer.Name))
								end
								sendmessage(custommsg)
							end
						else
							if killer == lplr and AutoToxicFinalKill.Enabled then 
								local custommsg = #AutoToxicPhrases2.ObjectList > 0 and AutoToxicPhrases2.ObjectList[math.random(1, #AutoToxicPhrases2.ObjectList)] or '<name> things could have ended for you so differently, if you\'ve used Render. | renderintents.lol'
								if custommsg == lastsaid then
									custommsg = #AutoToxicPhrases2.ObjectList > 0 and AutoToxicPhrases2.ObjectList[math.random(1, #AutoToxicPhrases2.ObjectList)] or '<name> things could have ended for you so differently, if you\'ve used Render. | renderintents.lol'
								else
									lastsaid = custommsg
								end
								if custommsg then
									custommsg = custommsg:gsub('<name>', (killed.DisplayName or killed.Name))
								end
								sendmessage(custommsg)
							end
						end
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						if AutoToxicGG.Enabled then
							sendmessage('gg')
						end
						if AutoToxicWin.Enabled then
							sendmessage(#AutoToxicPhrases.ObjectList > 0 and AutoToxicPhrases.ObjectList[math.random(1, #AutoToxicPhrases.ObjectList)] or 'Render is simply better everyone. | renderintents.lol')
						end
					end
				end))
			end
		end
	})
	AutoToxicGG = AutoToxic.CreateToggle({
		Name = 'AutoGG',
		Function = function() end, 
		Default = true
	})
	AutoToxicWin = AutoToxic.CreateToggle({
		Name = 'Win',
		Function = function() end, 
		Default = true
	})
	AutoToxicDeath = AutoToxic.CreateToggle({
		Name = 'Death',
		Function = function() end, 
		Default = true
	})
	AutoToxicBedBreak = AutoToxic.CreateToggle({
		Name = 'Bed Break',
		Function = function() end, 
		Default = true
	})
	AutoToxicBedDestroyed = AutoToxic.CreateToggle({
		Name = 'Bed Destroyed',
		Function = function() end, 
		Default = true
	})
	AutoToxicRespond = AutoToxic.CreateToggle({
		Name = 'Respond',
		Function = function() end, 
		Default = true
	})
	AutoToxicFinalKill = AutoToxic.CreateToggle({
		Name = 'Final Kill',
		Function = function() end, 
		Default = true
	})
	AutoToxicTeam = AutoToxic.CreateToggle({
		Name = 'Teammates',
		Function = function() end, 
	})
	AutoToxicPhrases = AutoToxic.CreateTextList({
		Name = 'ToxicList',
		TempText = 'phrase (win)',
	})
	AutoToxicPhrases2 = AutoToxic.CreateTextList({
		Name = 'ToxicList2',
		TempText = 'phrase (kill) <name>',
	})
	AutoToxicPhrases3 = AutoToxic.CreateTextList({
		Name = 'ToxicList3',
		TempText = 'phrase (death) <name>',
	})
	AutoToxicPhrases7 = AutoToxic.CreateTextList({
		Name = 'ToxicList7',
		TempText = 'phrase (bed break) <teamname>',
	})
	AutoToxicPhrases7.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases6 = AutoToxic.CreateTextList({
		Name = 'ToxicList6',
		TempText = 'phrase (bed destroyed) <name>',
	})
	AutoToxicPhrases6.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases4 = AutoToxic.CreateTextList({
		Name = 'ToxicList4',
		TempText = 'phrase (text to respond with) <name>',
	})
	AutoToxicPhrases4.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases5 = AutoToxic.CreateTextList({
		Name = 'ToxicList5',
		TempText = 'phrase (text to respond to)',
	})
	AutoToxicPhrases5.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases8 = AutoToxic.CreateTextList({
		Name = 'ToxicList8',
		TempText = 'phrase (lagback) <name>',
	})
	AutoToxicPhrases8.Object.AddBoxBKG.AddBox.TextSize = 12
end)

run(function()
	local ChestStealer = {Enabled = false}
	local ChestStealerDistance = {Value = 1}
	local ChestStealerDelay = {Value = 1}
	local ChestStealerOpen = {Enabled = false}
	local ChestStealerSkywars = {Enabled = true}
	local cheststealerdelays = {}
	local cheststealerfuncs = {
		Open = function()
			if bedwars.AppController:isAppOpen('ChestApp') then
				local chest = lplr.Character:FindFirstChild('ObservedChestFolder')
				local chestitems = chest and chest.Value and chest.Value:GetChildren() or {}
				if #chestitems > 0 then
					for i3,v3 in (chestitems) do
						if (cheststealerdelays[v3] == nil or cheststealerdelays[v3] < tick()) then
							task.spawn(function()
								pcall(function()
									cheststealerdelays[v3] = tick() + 0.2
									bedwars.Client:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(chest.Value, v3)
								end)
							end)
							task.wait(ChestStealerDelay.Value / 100)
						end
					end
				end
			end
		end,
		Closed = function()
			for i, v in (collection:GetTagged('chest')) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= ChestStealerDistance.Value then
					local chest = v:FindFirstChild('ChestFolderValue')
					chest = chest and chest.Value or nil
					local chestitems = chest and chest:GetChildren() or {}
					if #chestitems > 0 then
						bedwars.Client:GetNamespace('Inventory'):Get('SetObservedChest'):SendToServer(chest)
						for i3,v3 in (chestitems) do
							if v3:IsA('Accessory') then
								task.spawn(function()
									pcall(function()
										bedwars.Client:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(v.ChestFolderValue.Value, v3)
									end)
								end)
								task.wait(ChestStealerDelay.Value / 100)
							end
						end
						bedwars.Client:GetNamespace('Inventory'):Get('SetObservedChest'):SendToServer(nil)
					end
				end
			end
		end
	}

	ChestStealer = vape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'ChestStealer',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until store.queueType ~= 'bedwars_test'
					if (not ChestStealerSkywars.Enabled) or store.queueType:find('skywars') then
						repeat
							task.wait(0.1)
							if entityLibrary.isAlive then
								cheststealerfuncs[ChestStealerOpen.Enabled and 'Open' or 'Closed']()
							end
						until (not ChestStealer.Enabled)
					end
				end)
			end
		end,
		HoverText = 'Grabs items from near chests.'
	})
	ChestStealerDistance = ChestStealer.CreateSlider({
		Name = 'Range',
		Min = 0,
		Max = 18,
		Function = void,
		Default = 18
	})
	ChestStealerDelay = ChestStealer.CreateSlider({
		Name = 'Delay',
		Min = 1,
		Max = 50,
		Function = void,
		Default = 1,
		Double = 100
	})
	ChestStealerOpen = ChestStealer.CreateToggle({
		Name = 'GUI Check',
		Function = void
	})
	ChestStealerSkywars = ChestStealer.CreateToggle({
		Name = 'Only Skywars',
		Function = void,
		Default = true
	})
end)

run(function()
	local FastDrop = {Enabled = false}
	FastDrop = vape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'FastDrop',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if entityLibrary.isAlive and (not store.localInventory.opened) and (inputservice:IsKeyDown(Enum.KeyCode.Q) or inputservice:IsKeyDown(Enum.KeyCode.Backspace)) and inputservice:GetFocusedTextBox() == nil then
							task.spawn(bedwars.DropItem)
						end
					until (not FastDrop.Enabled)
				end)
			end
		end,
		HoverText = 'Drops items fast when you hold Q'
	})
end)

run(function()
	local MissileTP = {Enabled = false}
	local MissileTeleportDelaySlider = {Value = 30}
	MissileTP = vape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'MissileTP',
		Function = function(callback)
			if callback then
				task.spawn(function()
					if getItem('guided_missile') then
						local plr = EntityNearMouse(1000)
						if plr then
							local projectile = bedwars.RuntimeLib.await(bedwars.GuidedProjectileController.fireGuidedProjectile:CallServerAsync('guided_missile'))
							if projectile then
								local projectilemodel = projectile.model
								if not projectilemodel.PrimaryPart then
									projectilemodel:GetPropertyChangedSignal('PrimaryPart'):Wait()
								end;
								local bodyforce = Instance.new('BodyForce')
								bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * workspace.Gravity, 0)
								bodyforce.Name = 'AntiGravity'
								bodyforce.Parent = projectilemodel.PrimaryPart

								repeat
									task.wait()
									if projectile.model then
										if plr then
											projectile.model:SetPrimaryPartCFrame(CFrame.new(plr.RootPart.CFrame.p, plr.RootPart.CFrame.p + camera.CFrame.lookVector))
										else
											warningNotification('MissileTP', 'Player died before it could TP.', 3)
											break
										end
									end
								until projectile.model.Parent == nil
							else
								warningNotification('MissileTP', 'Missile on cooldown.', 3)
							end
						else
							warningNotification('MissileTP', 'Player not found.', 3)
						end
					else
						warningNotification('MissileTP', 'Missile not found.', 3)
					end
				end)
				MissileTP.ToggleButton(true)
			end
		end,
		HoverText = 'Spawns and teleports a missile to a player\nnear your mouse.'
	})
end)

run(function()
	local PickupRangeRange = {Value = 1}
	local PickupRange = {Enabled = false}
	PickupRange = vape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'PickupRange',
		Function = function(callback)
			if callback then
				local pickedup = {}
				task.spawn(function()
					repeat
						local itemdrops = collection:GetTagged('ItemDrop')
						for i,v in (itemdrops) do
							if entityLibrary.isAlive and (v:GetAttribute('ClientDropTime') and tick() - v:GetAttribute('ClientDropTime') > 2 or v:GetAttribute('ClientDropTime') == nil) then
								if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= PickupRangeRange.Value and (pickedup[v] == nil or pickedup[v] <= tick()) then
									task.spawn(function()
										pickedup[v] = tick() + 0.2
										bedwars.Client:Get(bedwars.PickupRemote):CallServerAsync({
											itemDrop = v
										}):andThen(function(suc)
											if suc then
												bedwars.SoundManager:playSound(bedwars.SoundList.PICKUP_ITEM_DROP)
											end
										end)
									end)
								end
							end
						end
						task.wait()
					until (not PickupRange.Enabled)
				end)
			end
		end
	})
	PickupRangeRange = PickupRange.CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 10,
		Function = void,
		Default = 10
	})
end)

--[[run(function()
	local BowExploit = {Enabled = false}
	local BowExploitTarget = {Value = 'Mouse'}
	local BowExploitAutoShootFOV = {Value = 1000}
	local oldrealremote
	local noveloproj = {
		'fireball',
		'telepearl'
	}

	BowExploit = vape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'ProjectileExploit',
		Function = function(callback)
			if callback then
				oldrealremote = bedwars.ClientConstructor.Function.new
				bedwars.ClientConstructor.Function.new = function(self, ind, ...)
					local res = oldrealremote(self, ind, ...)
					local oldRemote = res.instance
					if oldRemote and oldRemote.Name == bedwars.ProjectileRemote then
						res.instance = {InvokeServer = function(self, shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...)
							local plr
							if BowExploitTarget.Value == 'Mouse' then
								plr = EntityNearMouse(10000)
							else
								plr = EntityNearPosition(BowExploitAutoShootFOV.Value, true)
							end
							if plr then
								tab1.drawDurationSeconds = 1
								repeat
									task.wait(0.03)
									local offsetStartPos = plr.RootPart.CFrame.p - plr.RootPart.CFrame.lookVector
									local pos = plr.RootPart.Position
									local playergrav = workspace.Gravity
									local balloons = plr.Character:GetAttribute('InflatedBalloons')
									if balloons and balloons > 0 then
										playergrav = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
									end
									if plr.Character.PrimaryPart:FindFirstChild('rbxassetid://8200754399') then
										playergrav = (workspace.Gravity * 0.3)
									end
									local newLaunchVelo = bedwars.ProjectileMeta[proj2].launchVelocity
									local shootpos, shootvelo = predictGravity(pos, plr.RootPart.Velocity, (pos - offsetStartPos).Magnitude / newLaunchVelo, plr, playergrav)
									if proj2 == 'telepearl' then
										shootpos = pos
										shootvelo = Vector3.zero
									end
									local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))
									shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
									local calculated = LaunchDirection(offsetStartPos, shootpos, newLaunchVelo, workspace.Gravity, false)
									if calculated then
										launchvelo = calculated
										launchpos1 = offsetStartPos
										launchpos2 = offsetStartPos
										tab1.drawDurationSeconds = 1
									else
										break
									end
									if oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, workspace:GetServerTimeNow() - 0.045) then break end
								until false
							else
								return oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...)
							end
						end}
					end
					return res
				end
			else
				bedwars.ClientConstructor.Function.new = oldrealremote
				oldrealremote = nil
			end
		end
	})
	BowExploitTarget = BowExploit.CreateDropdown({
		Name = 'Mode',
		List = {'Mouse', 'Range'},
		Function = void
	})
	BowExploitAutoShootFOV = BowExploit.CreateSlider({
		Name = 'FOV',
		Function = void,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
end)]]

run(function()
	local RavenTP = {Enabled = false}
	RavenTP = vape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'RavenTP',
		Function = function(callback)
			if callback then
				task.spawn(function()
					if getItem('raven') then
						local plr = EntityNearMouse(1000)
						if plr then
							local projectile = bedwars.Client:Get(bedwars.SpawnRavenRemote):CallServerAsync():andThen(function(projectile)
								if projectile then
									local projectilemodel = projectile
									if not projectilemodel then
										projectilemodel:GetPropertyChangedSignal('PrimaryPart'):Wait()
									end
									local bodyforce = Instance.new('BodyForce')
									bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * workspace.Gravity, 0)
									bodyforce.Name = 'AntiGravity'
									bodyforce.Parent = projectilemodel.PrimaryPart

									if plr then
										projectilemodel:SetPrimaryPartCFrame(CFrame.new(plr.RootPart.CFrame.p, plr.RootPart.CFrame.p + camera.CFrame.lookVector))
										task.wait(0.3)
										bedwars.RavenController:detonateRaven()
									else
										warningNotification('RavenTP', 'Player died before it could TP.', 3)
									end
								else
									warningNotification('RavenTP', 'Raven on cooldown.', 3)
								end
							end)
						else
							warningNotification('RavenTP', 'Player not found.', 3)
						end
					else
						warningNotification('RavenTP', 'Raven not found.', 3)
					end
				end)
				RavenTP.ToggleButton(true)
			end
		end,
		HoverText = 'Spawns and teleports a raven to a player\nnear your mouse.'
	})
end)

run(function()
	local tiered = {}
	local nexttier = {}

	for i,v in (bedwars.ShopItems) do
		if type(v) == 'table' then
			if v.tiered then
				tiered[v.itemType] = v.tiered
			end
			if v.nextTier then
				nexttier[v.itemType] = v.nextTier
			end
		end
	end

	vape.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'ShopTierBypass',
		Function = function(callback)
			if callback then
				for i,v in (bedwars.ShopItems) do
					if type(v) == 'table' then
						v.tiered = nil
						v.nextTier = nil
					end
				end
			else
				for i,v in (bedwars.ShopItems) do
					if type(v) == 'table' then
						if tiered[v.itemType] then
							v.tiered = tiered[v.itemType]
						end
						if nexttier[v.itemType] then
							v.nextTier = nexttier[v.itemType]
						end
					end
				end
			end
		end,
		HoverText = 'Allows you to access tiered items early.'
	})
end)

local lagbackedaftertouch = false
run(function()
	local AntiVoidPart
	local AntiVoidConnection
	local AntiVoidMode = {Value = 'Normal'}
	local AntiVoidMoveMode = {Value = 'Normal'}
	local AntiVoid = {Enabled = false}
	local AntiVoidTransparent = {Value = 50}
	local AntiVoidColor = {Hue = 1, Sat = 1, Value = 0.55}
	local lastvalidpos

	local function closestpos(block)
		local startpos = block.Position - (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local newpos = block.Position + (entityLibrary.character.HumanoidRootPart.Position - block.Position)
		return Vector3.new(math.clamp(newpos.X, startpos.X, endpos.X), endpos.Y + 3, math.clamp(newpos.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag)
		local closest, closestmag = nil, newmag * 3
		if entityLibrary.isAlive then
			local tops = {}
			for i,v in (store.blocks) do
				local close = getScaffold(closestpos(v), false)
				if getPlacedBlock(close) then continue end
				if close.Y < entityLibrary.character.HumanoidRootPart.Position.Y then continue end
				if (close - entityLibrary.character.HumanoidRootPart.Position).magnitude <= newmag * 3 then
					table.insert(tops, close)
				end
			end
			for i,v in (tops) do
				local mag = (v - entityLibrary.character.HumanoidRootPart.Position).magnitude
				if mag <= closestmag then
					closest = v
					closestmag = mag
				end
			end
		end
		return closest
	end

	local antivoidypos = 0
	local antivoiding = false
	AntiVoid = vape.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'AntiVoid',
		Function = function(callback)
			if callback then
				task.spawn(function()
					AntiVoidPart = Instance.new('Part')
					AntiVoidPart.CanCollide = AntiVoidMode.Value == 'Collide'
					AntiVoidPart.Size = Vector3.new(10000, 1, 10000)
					AntiVoidPart.Anchored = true
					AntiVoidPart.Material = Enum.Material.Neon
					AntiVoidPart.Color = Color3.fromHSV(AntiVoidColor.Hue, AntiVoidColor.Sat, AntiVoidColor.Value)
					AntiVoidPart.Transparency = 1 - (AntiVoidTransparent.Value / 100)
					AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
					AntiVoidPart.Parent = workspace
					if AntiVoidMoveMode.Value == 'Classic' and antivoidypos == 0 then
						AntiVoidPart.Parent = nil
					end
					AntiVoidConnection = AntiVoidPart.Touched:Connect(function(touchedpart)
						if touchedpart.Parent == lplr.Character and entityLibrary.isAlive then
							if (not antivoiding) and (not vape.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) and entityLibrary.character.Humanoid.Health > 0 and AntiVoidMode.Value ~= 'Collide' then
								if AntiVoidMode.Value == 'Velocity' then
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 100, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								else
									antivoiding = true
									local pos = getclosesttop(1000)
									if pos then
										local lastTeleport = lplr:GetAttribute('LastTeleported')
										RunLoops:BindToHeartbeat('AntiVoid', function(dt)
											if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) and (entityLibrary.character.HumanoidRootPart.Position - pos).Magnitude > 1 and AntiVoid.Enabled and lplr:GetAttribute('LastTeleported') == lastTeleport then
												local hori1 = Vector3.new(entityLibrary.character.HumanoidRootPart.Position.X, 0, entityLibrary.character.HumanoidRootPart.Position.Z)
												local hori2 = Vector3.new(pos.X, 0, pos.Z)
												local newpos = (hori2 - hori1).Unit
												local realnewpos = CFrame.new(newpos == newpos and entityLibrary.character.HumanoidRootPart.CFrame.p + (newpos * ((3 + getSpeed()) * dt)) or Vector3.zero)
												entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(realnewpos.p.X, pos.Y, realnewpos.p.Z)
												antivoidvelo = newpos == newpos and newpos * 20 or Vector3.zero
												entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(antivoidvelo.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, antivoidvelo.Z)
												if getPlacedBlock((entityLibrary.character.HumanoidRootPart.CFrame.p - Vector3.new(0, 1, 0)) + entityLibrary.character.HumanoidRootPart.Velocity.Unit) or getPlacedBlock(entityLibrary.character.HumanoidRootPart.CFrame.p + Vector3.new(0, 3)) then
													pos = pos + Vector3.new(0, 1, 0)
												end
											else
												RunLoops:UnbindFromHeartbeat('AntiVoid')
												antivoidvelo = nil
												antivoiding = false
											end
										end)
									else
										entityLibrary.character.HumanoidRootPart.CFrame += Vector3.new(0, 100000, 0)
										antivoiding = false
									end
								end
							end
						end
					end)
					repeat
						if entityLibrary.isAlive and AntiVoidMoveMode.Value == 'Normal' then
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), store.raycast)
							if ray or vape.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled or vape.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then
								AntiVoidPart.Position = entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, 21, 0)
							end
						end
						task.wait()
					until (not AntiVoid.Enabled)
				end)
			else
				if AntiVoidConnection then AntiVoidConnection:Disconnect() end
				if AntiVoidPart then
					AntiVoidPart:Destroy()
				end
			end
		end,
		HoverText = 'Gives you a chance to get on land (Bouncing Twice, abusing, or bad luck will lead to lagbacks)'
	})
	AntiVoidMoveMode = AntiVoid.CreateDropdown({
		Name = 'Position Mode',
		Function = function(val)
			if val == 'Classic' then
				task.spawn(function()
					repeat task.wait() until store.matchState ~= 0 or not vapeInjected
					if vapeInjected and AntiVoidMoveMode.Value == 'Classic' and antivoidypos == 0 and AntiVoid.Enabled then
						local lowestypos = 99999
						for i,v in (store.blocks) do
							local newray = workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), store.raycast)
							if i % 200 == 0 then
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						antivoidypos = lowestypos - 8
					end
					if AntiVoidPart then
						AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
						AntiVoidPart.Parent = workspace
					end
				end)
			end
		end,
		List = {'Normal', 'Classic'}
	})
	AntiVoidMode = AntiVoid.CreateDropdown({
		Name = 'Move Mode',
		Function = function(val)
			if AntiVoidPart then
				AntiVoidPart.CanCollide = val == 'Collide'
			end
		end,
		List = {'Normal', 'Collide', 'Velocity'}
	})
	AntiVoidTransparent = AntiVoid.CreateSlider({
		Name = 'Invisible',
		Min = 1,
		Max = 100,
		Default = 50,
		Function = function(val)
			if AntiVoidPart then
				AntiVoidPart.Transparency = 1 - (val / 100)
			end
		end,
	})
	AntiVoidColor = AntiVoid.CreateColorSlider({
		Name = 'Color',
		Function = function(h, s, v)
			if AntiVoidPart then
				AntiVoidPart.Color = Color3.fromHSV(h, s, v)
			end
		end
	})
end)

run(function()
	local oldhitblock

	local AutoTool = vape.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'AutoTool',
		Function = function(callback)
			if callback then
				oldhitblock = bedwars.BlockBreaker.hitBlock
				bedwars.BlockBreaker.hitBlock = function(self, maid, raycastparams, ...)
					if (vape.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled == false or store.matchState ~= 0) then
						local block = self.clientManager:getBlockSelector():getMouseInfo(1, {ray = raycastparams})
						if block and block.target and not block.target.blockInstance:GetAttribute('NoBreak') and not block.target.blockInstance:GetAttribute('Team'..(lplr:GetAttribute('Team') or 0)..'NoBreak') then
							if switchToAndUseTool(block.target.blockInstance, true) then return end
						end
					end
					return oldhitblock(self, maid, raycastparams, ...)
				end
			else
				bedwars.BlockBreaker.hitBlock = oldhitblock
				oldhitblock = nil
			end
		end,
		HoverText = 'Automatically swaps your hand to the appropriate tool.'
	})
end)

run(function()
	local BedProtector = {Enabled = false}
	local bedprotector1stlayer = {
		Vector3.new(0, 3, 0),
		Vector3.new(0, 3, 3),
		Vector3.new(3, 0, 0),
		Vector3.new(3, 0, 3),
		Vector3.new(-3, 0, 0),
		Vector3.new(-3, 0, 3),
		Vector3.new(0, 0, 6),
		Vector3.new(0, 0, -3)
	}
	local bedprotector2ndlayer = {
		Vector3.new(0, 6, 0),
		Vector3.new(0, 6, 3),
		Vector3.new(0, 3, 6),
		Vector3.new(0, 3, -3),
		Vector3.new(0, 0, -6),
		Vector3.new(0, 0, 9),
		Vector3.new(3, 3, 0),
		Vector3.new(3, 3, 3),
		Vector3.new(3, 0, 6),
		Vector3.new(3, 0, -3),
		Vector3.new(6, 0, 3),
		Vector3.new(6, 0, 0),
		Vector3.new(-3, 3, 3),
		Vector3.new(-3, 3, 0),
		Vector3.new(-6, 0, 3),
		Vector3.new(-6, 0, 0),
		Vector3.new(-3, 0, 6),
		Vector3.new(-3, 0, -3),
	}

	local function getItemFromList(list)
		local selecteditem
		for i3,v3 in (list) do
			local item = getItem(v3)
			if item then
				selecteditem = item
				break
			end
		end
		return selecteditem
	end

	local function placelayer(layertab, obj, selecteditems)
		for i2,v2 in (layertab) do
			local selecteditem = getItemFromList(selecteditems)
			if selecteditem then
				bedwars.placeBlock(obj.Position + v2, selecteditem.itemType)
			else
				return false
			end
		end
		return true
	end

	local bedprotectorrange = {Value = 1}
	BedProtector = vape.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'BedProtector',
		Function = function(callback)
			if callback then
				task.spawn(function()
					for i, obj in (collection:GetTagged('bed')) do
						if entityLibrary.isAlive and obj:GetAttribute('Team'..(lplr:GetAttribute('Team') or 0)..'NoBreak') and obj.Parent ~= nil then
							if (entityLibrary.character.HumanoidRootPart.Position - obj.Position).magnitude <= bedprotectorrange.Value then
								local firstlayerplaced = placelayer(bedprotector1stlayer, obj, {'obsidian', 'stone_brick', 'plank_oak', getWool()})
								if firstlayerplaced then
									placelayer(bedprotector2ndlayer, obj, {getWool()})
								end
							end
							break
						end
					end
					BedProtector.ToggleButton(false)
				end)
			end
		end,
		HoverText = 'Automatically places a bed defense (Toggle)'
	})
	bedprotectorrange = BedProtector.CreateSlider({
		Name = 'Place range',
		Min = 1,
		Max = 20,
		Function = function(val) end,
		Default = 20
	})
end)

run(function()
	local Nuker = {Enabled = false}
	local nukerboxes: table = Performance.new();
	local nukerrange = {Value = 1}
	local nukereffects = {Enabled = false}
	local nukeranimation = {Enabled = false}
	local nukernofly = {Enabled = false}
	local nukerlegit = {Enabled = false}
	local nukerown = {Enabled = false}
	local nukerluckyblock = {Enabled = false}
	local nukerironore = {Enabled = false}
	local nukerbeds = {Enabled = false}
	local nukercustom = {RefreshValues = void, ObjectList = {}}
	local luckyblocktable = {}

	Nuker = vape.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'Nuker',
		Function = function(callback)
			if callback then
				for i,v in (store.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) or (nukerironore.Enabled and v.Name == 'iron_ore') then
						table.insert(luckyblocktable, v)
					end
				end
				table.insert(Nuker.Connections, collection:GetInstanceAddedSignal('block'):Connect(function(v)
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) or (nukerironore.Enabled and v.Name == 'iron_ore') then
						table.insert(luckyblocktable, v)
					end
				end))
				table.insert(Nuker.Connections, collection:GetInstanceRemovedSignal('block'):Connect(function(v)
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) or (nukerironore.Enabled and v.Name == 'iron_ore') then
						table.remove(luckyblocktable, table.find(luckyblocktable, v))
					end
				end))
				task.spawn(function()
					repeat
						if (not nukernofly.Enabled or not vape.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) then
							local broke = not entityLibrary.isAlive
							local tool = (not nukerlegit.Enabled) and {Name = 'wood_axe'} or store.localHand.tool
							if nukerbeds.Enabled then
								for i, obj in (collection:GetTagged('bed')) do
									if broke then break end
									if obj.Parent ~= nil then
										if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												local res, amount = getBestBreakSide(obj.Position)
												local res2, amount2 = getBestBreakSide(obj.Position + Vector3.new(0, 0, 3))
												broke = true
												bedwars.breakBlock((amount < amount2 and obj.Position or obj.Position + Vector3.new(0, 0, 3)), nukereffects.Enabled, (amount < amount2 and res or res2), false, nukeranimation.Enabled)
												break
											end
										end
									end
								end
							end
							broke = broke and not entityLibrary.isAlive
							for i, obj in (luckyblocktable) do
								if broke then break end
								if entityLibrary.isAlive then
									if obj and obj.Parent ~= nil then
										if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value and (nukerown.Enabled or obj:GetAttribute('PlacedByUserId') ~= lplr.UserId) then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												bedwars.ClientDamageBlock:Get('DamageBlock'):CallServerAsync({
													blockRef = blockhealthbarpos,
													hitPosition = blockpos * 3,
													hitNormal = Vector3.FromNormalId(normal)
												})
												bedwars.breakBlock(obj.Position, nukereffects.Enabled, getBestBreakSide(obj.Position), true, nukeranimation.Enabled)
												break
											end
										end
									end
								end
							end
						end
						task.wait()
					until (not Nuker.Enabled)
				end)
			else
				luckyblocktable = {}
			end
		end,
		HoverText = 'Automatically destroys beds & luckyblocks around you.'
	})
	nukerrange = Nuker.CreateSlider({
		Name = 'Break range',
		Min = 1,
		Max = 30,
		Function = function(val) end,
		Default = 30
	})
	nukerlegit = Nuker.CreateToggle({
		Name = 'Hand Check',
		Function = void
	})
	nukereffects = Nuker.CreateToggle({
		Name = 'Show HealthBar & Effects',
		Function = function(callback)
			if not callback then
				bedwars.BlockBreaker.healthbarMaid:DoCleaning()
			end
		 end,
		Default = true
	})
	nukeranimation = Nuker.CreateToggle({
		Name = 'Break Animation',
		Function = void
	})
	nukerown = Nuker.CreateToggle({
		Name = 'Self Break',
		Function = void,
	})
	nukerbeds = Nuker.CreateToggle({
		Name = 'Break Beds',
		Function = function(callback) end,
		Default = true
	})
	nukernofly = Nuker.CreateToggle({
		Name = 'Fly Disable',
		Function = void
	})
	nukerluckyblock = Nuker.CreateToggle({
		Name = 'Break LuckyBlocks',
		Function = function(callback)
			if callback then
				luckyblocktable = {}
				for i,v in (store.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) or (nukerironore.Enabled and v.Name == 'iron_ore') then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		 end,
		Default = true
	})
	nukerironore = Nuker.CreateToggle({
		Name = 'Break IronOre',
		Function = function(callback)
			if callback then
				luckyblocktable = {}
				for i,v in (store.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) or (nukerironore.Enabled and v.Name == 'iron_ore') then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		end
	})
	nukercustom = Nuker.CreateTextList({
		Name = 'NukerList',
		TempText = 'block (tesla_trap)',
		AddFunction = function()
			luckyblocktable = {}
			for i,v in (store.blocks) do
				if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) then
					table.insert(luckyblocktable, v)
				end
			end
		end
	})
end)


run(function()
	local controlmodule = require(lplr.PlayerScripts.PlayerModule).controls
	local oldmove
	local SafeWalk = {Enabled = false}
	local SafeWalkMode = {Value = 'Optimized'}
	SafeWalk = vape.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'SafeWalk',
		Function = function(callback)
			if callback then
				oldmove = controlmodule.moveFunction
				controlmodule.moveFunction = function(Self, vec, facecam)
					if entityLibrary.isAlive and (not Scaffold.Enabled) and (not vape.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) then
						if SafeWalkMode.Value == 'Optimized' then
							local newpos = (entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight * 2, 0))
							local ray = getPlacedBlock(newpos + Vector3.new(0, -6, 0) + vec)
							for i = 1, 50 do
								if ray then break end
								ray = getPlacedBlock(newpos + Vector3.new(0, -i * 6, 0) + vec)
							end
							local ray2 = getPlacedBlock(newpos)
							if ray == nil and ray2 then
								local ray3 = getPlacedBlock(newpos + vec) or getPlacedBlock(newpos + (vec * 1.5))
								if ray3 == nil then
									vec = Vector3.zero
								end
							end
						else
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position + vec, Vector3.new(0, -1000, 0), store.raycast)
							local ray2 = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -entityLibrary.character.Humanoid.HipHeight * 2, 0), store.raycast)
							if ray == nil and ray2 then
								local ray3 = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position + (vec * 1.8), Vector3.new(0, -1000, 0), store.raycast)
								if ray3 == nil then
									vec = Vector3.zero
								end
							end
						end
					end
					return oldmove(Self, vec, facecam)
				end
			else
				controlmodule.moveFunction = oldmove
			end
		end,
		HoverText = 'lets you not walk off because you are bad'
	})
	SafeWalkMode = SafeWalk.CreateDropdown({
		Name = 'Mode',
		List = {'Optimized', 'Accurate'},
		Function = void
	})
end)

run(function()
	local Schematica = {Enabled = false}
	local SchematicaBox = {Value = ''}
	local SchematicaTransparency = {Value = 30}
	local positions = {}
	local tempfolder
	local tempgui
	local aroundpos = {
		[1] = Vector3.new(0, 3, 0),
		[2] = Vector3.new(-3, 3, 0),
		[3] = Vector3.new(-3, -0, 0),
		[4] = Vector3.new(-3, -3, 0),
		[5] = Vector3.new(0, -3, 0),
		[6] = Vector3.new(3, -3, 0),
		[7] = Vector3.new(3, -0, 0),
		[8] = Vector3.new(3, 3, 0),
		[9] = Vector3.new(0, 3, -3),
		[10] = Vector3.new(-3, 3, -3),
		[11] = Vector3.new(-3, -0, -3),
		[12] = Vector3.new(-3, -3, -3),
		[13] = Vector3.new(0, -3, -3),
		[14] = Vector3.new(3, -3, -3),
		[15] = Vector3.new(3, -0, -3),
		[16] = Vector3.new(3, 3, -3),
		[17] = Vector3.new(0, 3, 3),
		[18] = Vector3.new(-3, 3, 3),
		[19] = Vector3.new(-3, -0, 3),
		[20] = Vector3.new(-3, -3, 3),
		[21] = Vector3.new(0, -3, 3),
		[22] = Vector3.new(3, -3, 3),
		[23] = Vector3.new(3, -0, 3),
		[24] = Vector3.new(3, 3, 3),
		[25] = Vector3.new(0, -0, 3),
		[26] = Vector3.new(0, -0, -3)
	}

	local function isNearBlock(pos)
		for i,v in (aroundpos) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function gethighlightboxatpos(pos)
		if tempfolder then
			for i,v in (tempfolder:GetChildren()) do
				if v.Position == pos then
					return v
				end
			end
		end
		return nil
	end

	local function removeduplicates(tab)
		local actualpositions = {}
		for i,v in (tab) do
			if table.find(actualpositions, Vector3.new(v.X, v.Y, v.Z)) == nil then
				table.insert(actualpositions, Vector3.new(v.X, v.Y, v.Z))
			else
				table.remove(tab, i)
			end
			if v.blockType == 'start_block' then
				table.remove(tab, i)
			end
		end
	end

	local function rotate(tab)
		for i,v in (tab) do
			local radvec, radius = entityLibrary.character.HumanoidRootPart.CFrame:ToAxisAngle()
			radius = (radius * 57.2957795)
			radius = math.round(radius / 90) * 90
			if radvec == Vector3.new(0, -1, 0) and radius == 90 then
				radius = 270
			end
			local rot = CFrame.new() * CFrame.fromAxisAngle(Vector3.new(0, 1, 0), math.rad(radius))
			local newpos = CFrame.new(0, 0, 0) * rot * CFrame.new(Vector3.new(v.X, v.Y, v.Z))
			v.X = math.round(newpos.p.X)
			v.Y = math.round(newpos.p.Y)
			v.Z = math.round(newpos.p.Z)
		end
	end

	local function getmaterials(tab)
		local materials = {}
		for i,v in (tab) do
			materials[v.blockType] = (materials[v.blockType] and materials[v.blockType] + 1 or 1)
		end
		return materials
	end

	local function schemplaceblock(pos, blocktype, removefunc)
		local fail = false
		local ok = bedwars.RuntimeLib.try(function()
			bedwars.ClientDamageBlock:Get('PlaceBlock'):CallServer({
				blockType = blocktype or getWool(),
				position = bedwars.BlockController:getBlockPosition(pos)
			})
		end, function(thing)
			fail = true
		end)
		if (not fail) and bedwars.BlockController:getStore():getBlockAt(bedwars.BlockController:getBlockPosition(pos)) then
			removefunc()
		end
	end

	Schematica = vape.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'Schematica',
		Function = function(callback)
			if callback then
				local mouseinfo = bedwars.BlockEngine:getBlockSelector():getMouseInfo(0)
				if mouseinfo and isfile(SchematicaBox.Value) then
					tempfolder = Instance.new('Folder')
					tempfolder.Parent = workspace
					local newpos = mouseinfo.placementPosition * 3
					positions = getservice('HttpService'):JSONDecode(readfile(SchematicaBox.Value))
					if positions.blocks == nil then
						positions = {blocks = positions}
					end
					rotate(positions.blocks)
					removeduplicates(positions.blocks)
					if positions['start_block'] == nil then
						bedwars.placeBlock(newpos)
					end
					for i2,v2 in (positions.blocks) do
						local texturetxt = bedwars.ItemTable[(v2.blockType == 'wool_white' and getWool() or v2.blockType)].block.greedyMesh.textures[1]
						local newerpos = (newpos + Vector3.new(v2.X, v2.Y, v2.Z))
						local block = Instance.new('Part')
						block.Position = newerpos
						block.Size = Vector3.new(3, 3, 3)
						block.CanCollide = false
						block.Transparency = (SchematicaTransparency.Value == 10 and 0 or 1)
						block.Anchored = true
						block.Parent = tempfolder
						for i3,v3 in (Enum.NormalId:GetEnumItems()) do
							local texture = Instance.new('Texture')
							texture.Face = v3
							texture.Texture = texturetxt
							texture.Name = tostring(v3)
							texture.Transparency = (SchematicaTransparency.Value == 10 and 0 or (1 / SchematicaTransparency.Value))
							texture.Parent = block
						end
					end
					task.spawn(function()
						repeat
							task.wait(.1)
							if not Schematica.Enabled then break end
							for i,v in (positions.blocks) do
								local newerpos = (newpos + Vector3.new(v.X, v.Y, v.Z))
								if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - newerpos).magnitude <= 30 and isNearBlock(newerpos) and bedwars.BlockController:isAllowedPlacement(lplr, getWool(), newerpos / 3, 0) then
									schemplaceblock(newerpos, (v.blockType == 'wool_white' and getWool() or v.blockType), function()
										table.remove(positions.blocks, i)
										if gethighlightboxatpos(newerpos) then
											gethighlightboxatpos(newerpos):Remove()
										end
									end)
								end
							end
						until #positions.blocks == 0 or (not Schematica.Enabled)
						if Schematica.Enabled then
							Schematica.ToggleButton(false)
							warningNotification('Schematica', 'Finished Placing Blocks', 4)
						end
					end)
				end
			else
				positions = {}
				if tempfolder then
					tempfolder:Remove()
				end
			end
		end,
		HoverText = 'Automatically places structure at mouse position.'
	})
	SchematicaBox = Schematica.CreateTextBox({
		Name = 'File',
		TempText = 'File (location in workspace)',
		FocusLost = function(enter)
			local suc, res = pcall(function() return getservice('HttpService'):JSONDecode(readfile(SchematicaBox.Value)) end)
			if tempgui then
				tempgui:Remove()
			end
			if suc then
				if res.blocks == nil then
					res = {blocks = res}
				end
				removeduplicates(res.blocks)
				tempgui = Instance.new('Frame')
				tempgui.Name = 'SchematicListOfBlocks'
				tempgui.BackgroundTransparency = 1
				tempgui.LayoutOrder = 9999
				tempgui.Parent = SchematicaBox.Object.Parent
				local uilistlayoutschmatica = Instance.new('UIListLayout')
				uilistlayoutschmatica.Parent = tempgui
				uilistlayoutschmatica:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
					tempgui.Size = UDim2.new(0, 220, 0, uilistlayoutschmatica.AbsoluteContentSize.Y)
				end)
				for i4,v4 in (getmaterials(res.blocks)) do
					local testframe = Instance.new('Frame')
					testframe.Size = UDim2.new(0, 220, 0, 40)
					testframe.BackgroundTransparency = 1
					testframe.Parent = tempgui
					local testimage = Instance.new('ImageLabel')
					testimage.Size = UDim2.new(0, 40, 0, 40)
					testimage.Position = UDim2.new(0, 3, 0, 0)
					testimage.BackgroundTransparency = 1
					testimage.Image = bedwars.getIcon({itemType = i4}, true)
					testimage.Parent = testframe
					local testtext = Instance.new('TextLabel')
					testtext.Size = UDim2.new(1, -50, 0, 40)
					testtext.Position = UDim2.new(0, 50, 0, 0)
					testtext.TextSize = 20
					testtext.Text = v4
					testtext.Font = Enum.Font.SourceSans
					testtext.TextXAlignment = Enum.TextXAlignment.Left
					testtext.TextColor3 = Color3.new(1, 1, 1)
					testtext.BackgroundTransparency = 1
					testtext.Parent = testframe
				end
			end
		end
	})
	SchematicaTransparency = Schematica.CreateSlider({
		Name = 'Transparency',
		Min = 0,
		Max = 10,
		Default = 7,
		Function = function()
			if tempfolder then
				for i2,v2 in (tempfolder:GetChildren()) do
					v2.Transparency = (SchematicaTransparency.Value == 10 and 0 or 1)
					for i3,v3 in (v2:GetChildren()) do
						v3.Transparency = (SchematicaTransparency.Value == 10 and 0 or (1 / SchematicaTransparency.Value))
					end
				end
			end
		end
	})
end)

run(function()
	store.TPString = shared.vapeoverlay or nil
	local origtpstring = store.TPString
	local Overlay = vape.CreateCustomWindow({
		Name = 'Overlay',
		Icon = 'rendervape/assets/TargetIcon1.png',
		IconSize = 16
	})
	local overlayframe = Instance.new('Frame')
	overlayframe.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlayframe.Size = UDim2.new(0, 200, 0, 120)
	overlayframe.Position = UDim2.new(0, 0, 0, 5)
	overlayframe.Parent = Overlay.GetCustomChildren()
	local overlayframe2 = Instance.new('Frame')
	overlayframe2.Size = UDim2.new(1, 0, 0, 10)
	overlayframe2.Position = UDim2.new(0, 0, 0, -5)
	overlayframe2.Parent = overlayframe
	local overlayframe3 = Instance.new('Frame')
	overlayframe3.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlayframe3.Size = UDim2.new(1, 0, 0, 6)
	overlayframe3.Position = UDim2.new(0, 0, 0, 6)
	overlayframe3.BorderSizePixel = 0
	overlayframe3.Parent = overlayframe2
	local oldguiupdate = vape.UpdateUI
	vape.UpdateUI = function(h, s, v, ...)
		overlayframe2.BackgroundColor3 = Color3.fromHSV(h, s, v)
		return oldguiupdate(h, s, v, ...)
	end
	local framecorner1 = Instance.new('UICorner')
	framecorner1.CornerRadius = UDim.new(0, 5)
	framecorner1.Parent = overlayframe
	local framecorner2 = Instance.new('UICorner')
	framecorner2.CornerRadius = UDim.new(0, 5)
	framecorner2.Parent = overlayframe2
	local label = Instance.new('TextLabel')
	label.Size = UDim2.new(1, -7, 1, -5)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Font = Enum.Font.Arial
	label.LineHeight = 1.2
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	label.TextSize = 16
	label.Text = ''
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Position = UDim2.new(0, 7, 0, 5)
	label.Parent = overlayframe
	local OverlayFonts = {'Arial'}
	for i,v in (Enum.Font:GetEnumItems()) do
		if v.Name ~= 'Arial' then
			table.insert(OverlayFonts, v.Name)
		end
	end
	local OverlayFont = Overlay.CreateDropdown({
		Name = 'Font',
		List = OverlayFonts,
		Function = function(val)
			label.Font = Enum.Font[val]
		end
	})
	OverlayFont.Bypass = true
	Overlay.Bypass = true
	local overlayconnections = {}
	local oldnetworkowner
	local teleported = {}
	local teleported2 = {}
	local teleportedability = {}
	local teleportconnections = {}
	local pinglist = {}
	local fpslist = {}
	local matchstatechanged = 0
	local mapname = 'Unknown'
	local overlayenabled = false

	task.spawn(function()
		pcall(function()
			mapname = workspace:WaitForChild('Map'):WaitForChild('Worlds'):GetChildren()[1].Name
			mapname = string.gsub(string.split(mapname, '_')[2] or mapname, '-', '') or 'Blank'
		end)
	end)

	local function didpingspike()
		local currentpingcheck = pinglist[1] or math.floor(tonumber(getservice('Stats'):FindFirstChild('PerformanceStats').Ping:GetValue()))
		for i,v in (pinglist) do
			if v ~= currentpingcheck and math.abs(v - currentpingcheck) >= 100 then
				return currentpingcheck..' => '..v..' ping'
			else
				currentpingcheck = v
			end
		end
		return nil
	end

	local function notlasso()
		for i,v in (collection:GetTagged('LassoHooked')) do
			if v == lplr.Character then
				return false
			end
		end
		return true
	end
	local matchstatetick = tick()

	vape.ObjectsThatCanBeSaved.GUIWindow.Api.CreateCustomToggle({
		Name = 'Overlay',
		Icon = 'rendervape/assets/TargetIcon1.png',
		Function = function(callback)
			overlayenabled = callback
			Overlay.SetVisible(callback)
			if callback then
				table.insert(overlayconnections, bedwars.Client:OnEvent('ProjectileImpact', function(p3)
					if not vapeInjected then return end
					if p3.projectile == 'telepearl' then
						teleported[p3.shooterPlayer] = true
					elseif p3.projectile == 'swap_ball' then
						if p3.hitEntity then
							teleported[p3.shooterPlayer] = true
							local plr = players:GetPlayerFromCharacter(p3.hitEntity)
							if plr then teleported[plr] = true end
						end
					end
				end))

				table.insert(overlayconnections, replicatedstorage['events-@easy-games/game-core:shared/game-core-networking@getEvents.Events'].abilityUsed.OnClientEvent:Connect(function(char, ability)
					if ability == 'recall' or ability == 'hatter_teleport' or ability == 'spirit_assassin_teleport' or ability == 'hannah_execute' then
						local plr = players:GetPlayerFromCharacter(char)
						if plr then
							teleportedability[plr] = tick() + (ability == 'recall' and 12 or 1)
						end
					end
				end))

				table.insert(overlayconnections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if bedTable.player.UserId == lplr.UserId then
						store.statistics.beds = store.statistics.beds + 1
					end
				end))

				local victorysaid = false
				table.insert(overlayconnections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						victorysaid = true
					end
				end))

				table.insert(overlayconnections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = players:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = players:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed ~= lplr and killer == lplr then
							store.statistics.kills = store.statistics.kills + 1
						end
					end
				end))

				task.spawn(function()
					repeat
						local ping = math.floor(tonumber(getservice('Stats'):FindFirstChild('PerformanceStats').Ping:GetValue()))
						if #pinglist >= 10 then
							table.remove(pinglist, 1)
						end
						table.insert(pinglist, ping)
						task.wait(1)
						if store.matchState ~= matchstatechanged then
							if store.matchState == 1 then
								matchstatetick = tick() + 3
							end
							matchstatechanged = store.matchState
						end
						if not store.TPString then
							store.TPString = tick()..'/'..store.statistics.kills..'/'..store.statistics.beds..'/'..(victorysaid and 1 or 0)..'/'..(1)..'/'..(0)..'/'..(0)..'/'..(0)
							origtpstring = store.TPString
						end
						if entityLibrary.isAlive and (not oldcloneroot) then
							local newnetworkowner = isnetworkowner(entityLibrary.character.HumanoidRootPart)
							if oldnetworkowner ~= nil and oldnetworkowner ~= newnetworkowner and newnetworkowner == false and notlasso() then
								local respawnflag = math.abs(lplr:GetAttribute('SpawnTime') - lplr:GetAttribute('LastTeleported')) > 3
								if (not teleported[lplr]) and respawnflag then
									task.delay(1, function()
										local falseflag = didpingspike()
										if not falseflag then
											store.statistics.lagbacks = store.statistics.lagbacks + 1
										end
									end)
								end
							end
							oldnetworkowner = newnetworkowner
						else
							oldnetworkowner = nil
						end
						teleported[lplr] = nil
						for i, v in (entityLibrary.entityList) do
							if teleportconnections[v.Player.Name..'1'] then continue end
							teleportconnections[v.Player.Name..'1'] = v.Player:GetAttributeChangedSignal('LastTeleported'):Connect(function()
								if not vapeInjected then return end
								for i = 1, 15 do
									task.wait(0.1)
									if teleported[v.Player] or teleported2[v.Player] or matchstatetick > tick() or math.abs(v.Player:GetAttribute('SpawnTime') - v.Player:GetAttribute('LastTeleported')) < 3 or (teleportedability[v.Player] or tick() - 1) > tick() then break end
								end
								if v.Player ~= nil and (not v.Player.Neutral) and teleported[v.Player] == nil and teleported2[v.Player] == nil and (teleportedability[v.Player] or tick() - 1) < tick() and math.abs(v.Player:GetAttribute('SpawnTime') - v.Player:GetAttribute('LastTeleported')) > 3 and matchstatetick <= tick() then
									store.statistics.universalLagbacks = store.statistics.universalLagbacks + 1
									vapeEvents.LagbackEvent:Fire(v.Player)
								end
								teleported[v.Player] = nil
							end)
							teleportconnections[v.Player.Name..'2'] = v.Player:GetAttributeChangedSignal('PlayerConnected'):Connect(function()
								teleported2[v.Player] = true
								task.delay(5, function()
									teleported2[v.Player] = nil
								end)
							end)
						end
						local splitted = origtpstring:split('/')
						label.Text = 'Session Info\nTime Played : '..os.date('!%X',math.floor(tick() - splitted[1]))..'\nKills : '..(splitted[2] + store.statistics.kills)..'\nBeds : '..(splitted[3] + store.statistics.beds)..'\nWins : '..(splitted[4] + (victorysaid and 1 or 0))..'\nGames : '..splitted[5]..'\nLagbacks : '..(splitted[6] + store.statistics.lagbacks)..'\nUniversal Lagbacks : '..(splitted[7] + store.statistics.universalLagbacks)..'\nReported : '..(splitted[8] + store.statistics.reported)..'\nMap : '..mapname
						local textsize = textservice:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(9e9, 9e9))
						overlayframe.Size = UDim2.new(0, math.max(textsize.X + 19, 200), 0, (textsize.Y * 1.2) + 6)
						store.TPString = splitted[1]..'/'..(splitted[2] + store.statistics.kills)..'/'..(splitted[3] + store.statistics.beds)..'/'..(splitted[4] + (victorysaid and 1 or 0))..'/'..(splitted[5] + 1)..'/'..(splitted[6] + store.statistics.lagbacks)..'/'..(splitted[7] + store.statistics.universalLagbacks)..'/'..(splitted[8] + store.statistics.reported)
					until not overlayenabled
				end)
			else
				for i, v in (overlayconnections) do
					if v.Disconnect then pcall(function() v:Disconnect() end) continue end
					if v.disconnect then pcall(function() v:disconnect() end) continue end
				end
				table.clear(overlayconnections)
			end
		end,
		Priority = 2
	})
end)

run(function()
	local ReachDisplay = {}
	local ReachLabel
	ReachDisplay = vape.CreateLegitModule({
		Name = 'Reach Display',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait(0.4)
						ReachLabel.Text = store.attackReachUpdate > tick() and store.attackReach..' studs' or '0.00 studs'
					until (not ReachDisplay.Enabled)
				end)
			end
		end
	})
	ReachLabel = Instance.new('TextLabel')
	ReachLabel.Size = UDim2.new(0, 100, 0, 41)
	ReachLabel.BackgroundTransparency = 0.5
	ReachLabel.TextSize = 15
	ReachLabel.Font = Enum.Font.Gotham
	ReachLabel.Text = '0.00 studs'
	ReachLabel.TextColor3 = Color3.new(1, 1, 1)
	ReachLabel.BackgroundColor3 = Color3.new()
	ReachLabel.Parent = ReachDisplay.GetCustomChildren()
	local ReachCorner = Instance.new('UICorner')
	ReachCorner.CornerRadius = UDim.new(0, 4)
	ReachCorner.Parent = ReachLabel
end);

table.insert(renderconnections, vapeEvents.ActivateBeast.Event:Once(function()
	store.beastmode = true;
end));

table.insert(renderconnections, vapeEvents.EntityDamageEvent.Event:Connect(function(damagedata: table)
	if lplr.Character and damagedata.entityInstance == lplr.Character then
		store.lastdamage = tick() + 0.5;
	end;
end));

pcall(function()
	local oldentity: (Player?) -> (table) = bedwars.EntityUtil.getEntity;
	bedwars.EntityUtil.getEntity = function(self: table, plr: Player?, ...)
		local res: {getInstance: (table) -> (Model?)} = oldentity(self, plr, ...);
		if res then 
			res.getInstance = res.getInstance or function(self: table): (Model?)
				return plr.Character;
			end;
		end;
		return res;
	end;
end)

pcall(function()
	local oldconzstructor: (Instance, ...any) -> (...any); oldconstructor = hookmetamethod(game, '__namecall', function(self: Instance, ...)
		if getnamecallmethod() == 'BindAction' and vapeInjected and ({identifyexecutor()})[1] == 'Wave' then 
			return;
		end;
		return oldconstructor(self, ...);
	end);
end);

task.spawn(function()
	repeat task.wait() until render.button;
	if render.button.isNewUI == false then 
		render.button.instance.Parent = lplr.PlayerGui:WaitForChild('TopBarAppGui'):WaitForChild('TopBarApp');
		render.button.instance.LayoutOrder = 100;
	else
		render.button.Visible = (render.platform ~= Enum.Platform.Windows and render.platform ~= Enum.Platform.OSX);
	end
end);

task.spawn(function()
    repeat 
        if cheatenginetrash then 
            pcall(function() store.zephyrOrb = tonumber(lplr.PlayerGui.StatusEffectHudScreen.StatusEffectHud.WindWalkerEffect.EffectStack.Text) end);
        end;
		if renderperformance.reducelag and not cheatenginetrash then 
			break
		end;
        pcall(function()
            local zephyrimage = lplr.PlayerGui.StatusEffectHudScreen.StatusEffectHud.WindWalkerEffect.EffectImage;
            local color = Color3.fromHSV(vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, vape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value);
            if store.zephyrOrb > 0 and (isEnabled('Speed') or isflying()) then 
                tween:Create(zephyrimage, TweenInfo.new(0.27, Enum.EasingStyle.Quad), {ImageColor3 = color}):Play();
            else
                tween:Create(zephyrimage, TweenInfo.new(0.27, Enum.EasingStyle.Quad), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play();
            end;
        end);
        task.wait();
    until (not vapeInjected);
end);

local getTargetBed = function(args: table?)
	args = typeof(args) == 'table' and args or {};
	local start = typeof(args.pos) == 'Vector3' or args.pos or isAlive(lplr, true) and lplr.Character.PrimaryPart.Position or Vector3.zero;
	local distance = typeof(args.distance) == 'number' and args.radius or math.huge;
	local best, bed = distance, nil; 
	for i,v in collection:GetTagged('bed') do 
		local magnitude = (start - v.Position).Magnitude;
		if magnitude < best and v:GetAttribute('id') ~= tostring(lplr:GetAttribute('Team'))..'_bed' then 
			if args.nobedshield and v:GetAttribute('BedShieldEndTime') and v:GetAttribute('BedShieldEndTime') > workspace:GetServerTimeNow() then 
				continue
			end
			magnitude = best;
			bed = v;
		end
	end;
	return bed
end;

local getTargetItemDrop = function(args: table?)
	local best, drop = distance or math.huge, nil;
	args = typeof(args) == 'table' and args or {};
	local start = typeof(args.pos) == 'Vector3' or args.pos or isAlive(lplr, true) and lplr.Character.PrimaryPart.Position or Vector3.zero;
	local distance = typeof(args.distance) == 'number' and args.radius or math.huge;
	for i,v in collection:GetTagged('ItemDrop') do 
		local magnitude = (start - v.Position).Magnitude;
		if magnitude < best and (args.type == v.Name or args.type == nil) then 
			magnitude = best;
			drop = v;
		end
	end	
	return drop
end;

run(function() -- pasted from old render once again
	local HotbarVisuals: vapemodule = {};
	local HotbarRounding: vapeminimodule = {};
	local HotbarHighlight: vapeminimodule = {};
	local HotbarColorToggle: vapeminimodule = {};
	local HotbarHideSlotIcons: vapeminimodule = {};
	local HotbarSlotNumberColorToggle: vapemodule = {};
	local HotbarSpacing: vapeslider = {Value = 0};
	local HotbarInvisibility: vapeslider = {Value = 4};
	local HotbarRoundRadius: vapeslider = {Value = 3};
	local HotbarAnimations: vapeminimodule = {};
	local HotbarColor: vapeminimodule = {};
	local HotbarHighlightColor: vapeminimodule = {};
	local HotbarSlotNumberColor: vapeminimodule = {};
	local hotbarcoloricons: securetable = Performance.new();
	local hotbarsloticons: securetable = Performance.new();
	local hotbarobjects: securetable = Performance.new();
	local HotbarVisualsGradient: vapeminimodule = {};
	local hotbarslotgradients: securetable = Performance.new();
	local HotbarMinimumRotation: vapeslider = {Value = 0};
	local HotbarMaximumRotation: vapeslider = {Value = 60};
	local HotbarAnimationSpeed: vapeslider = {Value = 8};
	local HotbarVisualsHighlightSize: vapeslider = {Value = 0};
	local HotbarVisualsGradientColor: vapecolorslider = {};
	local HotbarVisualsGradientColor2: vapecolorslider = {};
	local HotbarAnimationThreads: securetable = Performance.new();
	local inventoryiconobj;
	local hotbarFunction = function()
		local inventoryicons = ({pcall(function() return lplr.PlayerGui.hotbar['1'].ItemsHotbar end)})[2]
		if inventoryicons and type(inventoryicons) == 'userdata' then
			inventoryiconobj = inventoryicons;
			pcall(function() inventoryicons:FindFirstChildOfClass('UIListLayout').Padding = UDim.new(0, HotbarSpacing.Value) end);
			for i,v in inventoryicons:GetChildren() do 
				local sloticon = ({pcall(function() return v:FindFirstChildWhichIsA('ImageButton'):FindFirstChildWhichIsA('TextLabel') end)})[2]
				if type(sloticon) ~= 'userdata' then 
					continue
				end
				table.insert(hotbarcoloricons, sloticon.Parent);
				sloticon.Parent.Transparency = (0.1 * HotbarInvisibility.Value);
				if HotbarColorToggle.Enabled and not HotbarVisualsGradient.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value)
				end
				local gradient;
				if HotbarVisualsGradient.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					if sloticon.Parent:FindFirstChildWhichIsA('UIGradient') == nil then 
						gradient = Instance.new('UIGradient') 
						local color = Color3.fromHSV(HotbarVisualsGradientColor.Hue, HotbarVisualsGradientColor.Sat, HotbarVisualsGradientColor.Value)
						local color2 = Color3.fromHSV(HotbarVisualsGradientColor2.Hue, HotbarVisualsGradientColor2.Sat, HotbarVisualsGradientColor2.Value)
						gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color2)})
						gradient.Parent = sloticon.Parent
						table.insert(hotbarslotgradients, gradient)
						table.insert(hotbarcoloricons, sloticon.Parent) 
					end;
					if gradient then 
						HotbarAnimationThreads[gradient] = task.spawn(function()
							repeat
								task.wait();
								if not HotbarAnimations.Enabled then 
									continue;
								end;
								local integers: table = {
									[1] = HotbarMinimumRotation.Value + math.random(1, 15),
									[2] = HotbarMaximumRotation.Value - math.random(1, 14)
								};
								for i: number, v: number in integers do 
									local rotationtween: Tween = tween:Create(gradient, TweenInfo.new(0.1 * HotbarAnimationSpeed.Value), {Rotation = v});
									rotationtween:Play();
									rotationtween.Completed:Wait();
									task.wait(0.3);
								end;
							until (not HotbarVisuals.Enabled)
						end);
					end;
				end
				if HotbarRounding.Enabled then 
					local uicorner = Instance.new('UICorner')
					uicorner.Parent = sloticon.Parent
					uicorner.CornerRadius = UDim.new(0, HotbarRoundRadius.Value)
					table.insert(hotbarobjects, uicorner)
				end
				if HotbarHighlight.Enabled then
					local highlight = Instance.new('UIStroke')
					highlight.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value)
					highlight.Thickness = 1.3 + (0.1 * HotbarVisualsHighlightSize.Value);
					highlight.Parent = sloticon.Parent
					table.insert(hotbarobjects, highlight)
				end
				if HotbarHideSlotIcons.Enabled then 
					sloticon.Visible = false 
				end
				table.insert(hotbarsloticons, sloticon)
			end 
		end
	end
	HotbarVisuals = visual.Api.CreateOptionsButton({
		Name = 'HotbarVisuals',
		HoverText = 'Add customization to your hotbar.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					table.insert(HotbarVisuals.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(v)
						if v.Name == 'hotbar' then
							hotbarFunction()
						end
					end))
					hotbarFunction()
				end)
				table.insert(HotbarVisuals.Connections, runservice.RenderStepped:Connect(function()
					for i,v in hotbarcoloricons do 
						pcall(function() v.Transparency = (0.1 * HotbarInvisibility.Value) end); 
					end	
				end))
			else
				HotbarAnimationThreads:clear(task.cancel);
				for i,v in hotbarsloticons do 
					pcall(function() v.Visible = true end)
				end
				for i,v in hotbarcoloricons do 
					pcall(function() v.BackgroundColor3 = Color3.fromRGB(29, 36, 46) end)
				end
				for i,v in hotbarobjects do
					pcall(function() v:Destroy() end)
				end
				for i,v in hotbarslotgradients do 
					pcall(function() v:Destroy() end)
				end
				table.clear(hotbarobjects)
				table.clear(hotbarsloticons)
				table.clear(hotbarcoloricons)
			end
		end
	})
	HotbarColorToggle = HotbarVisuals.CreateToggle({
		Name = 'Slot Color',
		Function = function(calling)
			pcall(function() HotbarColor.Object.Visible = calling end)
			pcall(function() HotbarColorToggle.Object.Visible = calling end)
			if HotbarVisuals.Enabled then 
				HotbarVisuals.ToggleButton(false)
				HotbarVisuals.ToggleButton(false)
			end
		end
	})
	HotbarVisualsGradient = HotbarVisuals.CreateToggle({
		Name = 'Gradient Slot Color',
		Function = function(calling)
			pcall(function() HotbarVisualsGradientColor.Object.Visible = calling end)
			pcall(function() HotbarVisualsGradientColor2.Object.Visible = calling end)
			HotbarMinimumRotation.Object.Visible = calling and HotbarAnimations.Enabled;
			HotbarMaximumRotation.Object.Visible = calling and HotbarAnimations.Enabled;
			HotbarAnimationSpeed.Object.Visible = calling and HotbarAnimations.Enabled;
			if HotbarVisuals.Enabled then 
				HotbarVisuals.ToggleButton(false)
				HotbarVisuals.ToggleButton(false)
			end
		end
	})
	HotbarVisualsGradientColor = HotbarVisuals.CreateColorSlider({
		Name = 'Gradient Color',
		Function = function(h, s, v)
			for i,v in hotbarslotgradients do 
				pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarVisualsGradientColor.Hue, HotbarVisualsGradientColor.Sat, HotbarVisualsGradientColor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarVisualsGradientColor2.Hue, HotbarVisualsGradientColor2.Sat, HotbarVisualsGradientColor2.Value))}) end)
			end
		end
	});
	HotbarAnimations = HotbarVisuals.CreateToggle({
		Name = 'Animations',
		HoverText = 'Animates hotbar gradient rotation.',
		Function = function(calling: boolean)
			HotbarMinimumRotation.Object.Visible = calling;
			HotbarMaximumRotation.Object.Visible = calling;
			HotbarAnimationSpeed.Object.Visible = calling;
		end
	});
	HotbarVisualsGradientColor2 = HotbarVisuals.CreateColorSlider({
		Name = 'Gradient Color 2',
		Function = function(h, s, v)
			for i,v in hotbarslotgradients do 
				pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarVisualsGradientColor.Hue, HotbarVisualsGradientColor.Sat, HotbarVisualsGradientColor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarVisualsGradientColor2.Hue, HotbarVisualsGradientColor2.Sat, HotbarVisualsGradientColor2.Value))}) end)
			end
		end
	});
	HotbarMinimumRotation = HotbarVisuals.CreateSlider({
		Name = 'Minimum',
		Min = 0,
		Max = 75,
		Function = void
	});
	HotbarMaximumRotation = HotbarVisuals.CreateSlider({
		Name = 'Maximum',
		Min = 10,
		Max = 100,
		Function = void
	});
	HotbarAnimationSpeed = HotbarVisuals.CreateSlider({
		Name = 'Speed',
		Min = 0,
		Max = 15,
		Default = 8,
		Function = void
	});
	HotbarColor = HotbarVisuals.CreateColorSlider({
		Name = 'Slot Color',
		Function = function(h, s, v)
			for i,v in hotbarcoloricons do
				if HotbarColorToggle.Enabled then
					pcall(function() v.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value) end) -- for some reason the 'h, s, v' didn't work :(
				end
			end
		end
	})
	HotbarRounding = HotbarVisuals.CreateToggle({
		Name = 'Rounding',
		Function = function(calling)
			pcall(function() HotbarRoundRadius.Object.Visible = calling end)
			if HotbarVisuals.Enabled then 
				HotbarVisuals.ToggleButton(false)
				HotbarVisuals.ToggleButton(false)
			end
		end
	})
	HotbarRoundRadius = HotbarVisuals.CreateSlider({
		Name = 'Corner Radius',
		Min = 1,
		Max = 20,
		Function = function(calling)
			for i,v in hotbarobjects do 
				pcall(function() v.CornerRadius = UDim.new(0, calling) end)
			end
		end
	});
	HotbarHighlight = HotbarVisuals.CreateToggle({
		Name = 'Outline Highlight',
		Function = function(calling)
			pcall(function() HotbarHighlightColor.Object.Visible = calling end)
			pcall(function() HotbarVisualsHighlightSize.Object.Visible = calling end);
			if HotbarVisuals.Enabled then 
				HotbarVisuals.ToggleButton(false)
				HotbarVisuals.ToggleButton(false)
			end
		end
	})
	HotbarHighlightColor = HotbarVisuals.CreateColorSlider({
		Name = 'Highlight Color',
		Function = function(h, s, v)
			for i,v in hotbarobjects do 
				if v:IsA('UIStroke') and HotbarHighlight.Enabled then 
					pcall(function() v.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value) end)
				end
			end
		end
	});
	HotbarVisualsHighlightSize = HotbarVisuals.CreateSlider({
		Name = 'Highlight Size',
		Min = 0,
		Max = 8,
		Function = function(value: number)
			for i: number, v: UIStroke? in hotbarobjects do 
				if v.ClassName == 'UIStroke' and HotbarHighlight.Enabled then 
					pcall(function() v.Thickness = 1.3 + (0.1 * value) end)
				end
			end
		end
	});
	HotbarHideSlotIcons = HotbarVisuals.CreateToggle({
		Name = 'No Slot Numbers',
		Function = function()
			if HotbarVisuals.Enabled then 
				HotbarVisuals.ToggleButton(false)
				HotbarVisuals.ToggleButton(false)
			end
		end
	})
	HotbarInvisibility = HotbarVisuals.CreateSlider({
		Name = 'Invisibility',
		Min = 0,
		Max = 10,
		Default = 4,
		Function = function(value)
			for i,v in hotbarcoloricons do 
				pcall(function() v.Transparency = (0.1 * value) end); 
			end
		end
	})
	HotbarSpacing = HotbarVisuals.CreateSlider({
		Name = 'Spacing',
		Min = 0,
		Max = 5,
		Function = function(value)
			if HotbarVisuals.Enabled then 
				pcall(function() inventoryiconobj:FindFirstChildOfClass('UIListLayout').Padding = UDim.new(0, value) end)
			end
		end
	});

	HotbarAnimationThreads.oncleanevent:Connect(task.cancel);
	HotbarColor.Object.Visible = false;
	HotbarRoundRadius.Object.Visible = false;
	HotbarHighlightColor.Object.Visible = false;
	HotbarMinimumRotation.Object.Visible = false;
	HotbarMaximumRotation.Object.Visible = false;
	HotbarAnimationSpeed.Object.Visible = false;
end);

run(function()
	local HealthbarVisuals = {};
	local HealthbarRound = {};
	local HealthbarColorToggle = {};
	local HealthbarGradientToggle = {};
	local HealthbarGradientColor = {};
	local HealthbarHighlight = {};
	local HealthbarHighlightColor = newcolor();
	local HealthbarGradientRotation = {Value = 0};
	local HealthbarTextToggle = {};
	local HealthbarFontToggle = {};
	local HealthbarTextColorToggle = {};
	local HealthbarBackgroundToggle = {};
	local HealthbarText = {ObjectList = {}};
	local HealthbarInvis = {Value = 0};
	local HealthbarRoundSize = {Value = 4};
	local HealthbarFont = {value = 'LuckiestGuy'};
	local HealthbarColor = newcolor();
	local HealthbarBackground = newcolor();
	local HealthbarTextColor = newcolor();
	local healthbarobjects = Performance.new();
	local oldhealthbar;
	local healthbarhighlight;
	local textconnection;
	local function healthbarFunction()
		if not HealthbarVisuals.Enabled then 
			return 
		end
		local healthbar = ({pcall(function() return lplr.PlayerGui.hotbar['1'].HotbarHealthbarContainer.HealthbarProgressWrapper['1'] end)})[2]
		if healthbar and type(healthbar) == 'userdata' then 
			oldhealthbar = healthbar;
			healthbar.Transparency = (0.1 * HealthbarInvis.Value);
			healthbar.BackgroundColor3 = (HealthbarColorToggle.Enabled and Color3.fromHSV(HealthbarColor.Hue, HealthbarColor.Sat, HealthbarColor.Value) or healthbar.BackgroundColor3)
			if HealthbarGradientToggle.Enabled then 
				healthbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				local gradient = (healthbar:FindFirstChildWhichIsA('UIGradient') or Instance.new('UIGradient', healthbar))
				gradient.Color = creategradient(0, Color3.fromHSV(HealthbarColor.Hue, HealthbarColor.Sat, HealthbarColor.Value), 1, Color3.fromHSV(HealthbarGradientColor.Hue, HealthbarGradientColor.Sat, HealthbarGradientColor.Value))
				gradient.Rotation = HealthbarGradientRotation.Value
				table.insert(healthbarobjects, gradient)
			end
			for i,v in healthbar.Parent:GetChildren() do 
				if v:IsA('Frame') and v:FindFirstChildWhichIsA('UICorner') == nil and HealthbarRound.Enabled then
					local corner = Instance.new('UICorner', v);
					corner.CornerRadius = UDim.new(0, HealthbarRoundSize.Value);
					table.insert(healthbarobjects, corner)
				end
			end
			local healthbarbackground = ({pcall(function() return healthbar.Parent.Parent end)})[2]
			if healthbarbackground and type(healthbarbackground) == 'userdata' then
				healthbar.Transparency = (0.1 * HealthbarInvis.Value);
				if HealthbarHighlight.Enabled then 
					local highlight = Instance.new('UIStroke', healthbarbackground);
					highlight.Color = Color3.fromHSV(HealthbarHighlightColor.Hue, HealthbarHighlightColor.Sat, HealthbarHighlightColor.Value);
					highlight.Thickness = 1.6; 
					healthbarhighlight = highlight
				end
				if healthbar.Parent.Parent:FindFirstChildWhichIsA('UICorner') == nil and HealthbarRound.Enabled then 
					local corner = Instance.new('UICorner', healthbar.Parent.Parent);
					corner.CornerRadius = UDim.new(0, HealthbarRoundSize.Value);
					table.insert(healthbarobjects, corner)
				end 
				if HealthbarBackgroundToggle.Enabled then
					healthbarbackground.BackgroundColor3 = Color3.fromHSV(HealthbarBackground.Hue, HealthbarBackground.Sat, HealthbarBackground.Value)
				end
			end
			local healthbartext = ({pcall(function() return healthbar.Parent.Parent['1'] end)})[2]
			if healthbartext and type(healthbartext) == 'userdata' then 
				local randomtext = getrandomvalue(HealthbarText.ObjectList)
				if HealthbarTextColorToggle.Enabled then
					healthbartext.TextColor3 = Color3.fromHSV(HealthbarTextColor.Hue, HealthbarTextColor.Sat, HealthbarTextColor.Value)
				end
				if HealthbarFontToggle.Enabled then 
					healthbartext.Font = Enum.Font[HealthbarFont.Value]
				end
				if randomtext ~= '' and HealthbarTextToggle.Enabled then 
					healthbartext.Text = randomtext:gsub('<health>', isAlive(lplr, true) and tostring(math.round(lplr.Character:GetAttribute('Health') or 0)) or '0')
				else
					pcall(function() healthbartext.Text = tostring(lplr.Character:GetAttribute('Health')) end)
				end
				if not textconnection then 
					textconnection = healthbartext:GetPropertyChangedSignal('Text'):Connect(function()
						local randomtext = getrandomvalue(HealthbarText.ObjectList)
						if randomtext ~= '' then 
							healthbartext.Text = randomtext:gsub('<health>', isAlive() and tostring(math.floor(lplr.Character:GetAttribute('Health') or 0)) or '0')
						else
							pcall(function() healthbartext.Text = tostring(math.floor(lplr.Character:GetAttribute('Health'))) end)
						end
					end)
				end
			end
		end
	end
	HealthbarVisuals = visual.Api.CreateOptionsButton({
		Name = 'HealthbarVisuals',
		HoverText = 'Customize the color of your healthbar.\nAdd \'<health>\' to your custom text dropdown (if custom text enabled) to insert your health.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					table.insert(HealthbarVisuals.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(v)
						if v.Name == 'HotbarHealthbarContainer' and v.Parent and v.Parent.Parent and v.Parent.Parent.Name == 'hotbar' then
							healthbarFunction()
						end
					end))
					healthbarFunction()
				end)
			else
				pcall(function() textconnection:Disconnect() end)
				pcall(function() oldhealthbar.Parent.Parent.BackgroundColor3 = Color3.fromRGB(41, 51, 65) end)
				pcall(function() oldhealthbar.BackgroundColor3 = Color3.fromRGB(203, 54, 36) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].Text = tostring(lplr.Character:GetAttribute('Health')) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].TextColor3 = Color3.fromRGB(255, 255, 255) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].Font = Enum.Font.LuckiestGuy end)
				oldhealthbar = nil
				textconnection = nil
				for i,v in healthbarobjects do 
					pcall(function() v:Destroy() end)
				end
				table.clear(healthbarobjects);
				pcall(function() healthbarhighlight:Destroy() end);
				healthbarhighlight = nil;
			end
		end
	})
	HealthbarColorToggle = HealthbarVisuals.CreateToggle({
		Name = 'Main Color',
		Default = true,
		Function = function(calling)
			pcall(function() HealthbarColor.Object.Visible = calling end)
			pcall(function() HealthbarGradientToggle.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end 
	})
	HealthbarGradientToggle = HealthbarVisuals.CreateToggle({
		Name = 'Gradient',
		Function = function(calling)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end
	})
	HealthbarColor = HealthbarVisuals.CreateColorSlider({
		Name = 'Main Color',
		Function = function()
			task.spawn(healthbarFunction)
		end
	})
	HealthbarGradientColor = HealthbarVisuals.CreateColorSlider({
		Name = 'Secondary Color',
		Function = function(calling)
			if HealthbarGradientToggle.Enabled then 
				task.spawn(healthbarFunction)
			end
		end
	})
	HealthbarBackgroundToggle = HealthbarVisuals.CreateToggle({
		Name = 'Background Color',
		Function = function(calling)
			pcall(function() HealthbarBackground.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end 
	})
	HealthbarBackground = HealthbarVisuals.CreateColorSlider({
		Name = 'Background Color',
		Function = function() 
			task.spawn(healthbarFunction)
		end
	})
	HealthbarTextToggle = HealthbarVisuals.CreateToggle({
		Name = 'Text',
		Function = function(calling)
			pcall(function() HealthbarText.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end 
	})
	HealthbarText = HealthbarVisuals.CreateTextList({
		Name = 'Text',
		TempText = 'Healthbar Text',
		AddFunction = function()
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end,
		RemoveFunction = function()
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end
	})
	HealthbarTextColorToggle = HealthbarVisuals.CreateToggle({
		Name = 'Text Color',
		Function = function(calling)
			pcall(function() HealthbarTextColor.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end 
	})
	HealthbarTextColor = HealthbarVisuals.CreateColorSlider({
		Name = 'Text Color',
		Function = function() 
			task.spawn(healthbarFunction)
		end
	})
	HealthbarFontToggle = HealthbarVisuals.CreateToggle({
		Name = 'Text Font',
		Function = function(calling)
			pcall(function() HealthbarFont.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end 
	})
	HealthbarFont = HealthbarVisuals.CreateDropdown({
		Name = 'Text Font',
		List = GetEnumItems('Font'),
		Function = function(calling)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end
	})
	HealthbarRound = HealthbarVisuals.CreateToggle({
		Name = 'Round',
		Function = function(calling)
			pcall(function() HealthbarRoundSize.Object.Visible = calling end);
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end
	})
	HealthbarRoundSize = HealthbarVisuals.CreateSlider({
		Name = 'Corner Size',
		Min = 1,
		Max = 20,
		Default = 5,
		Function = function(value)
			if HealthbarVisuals.Enabled then 
				pcall(function() 
					oldhealthbar.Parent:FindFirstChildOfClass('UICorner').CornerRadius = UDim.new(0, value);
					oldhealthbar.Parent.Parent:FindFirstChildOfClass('UICorner').CornerRadius = UDim.new(0, value)  
				end)
			end
		end
	})
	HealthbarHighlight = HealthbarVisuals.CreateToggle({
		Name = 'Highlight',
		Function = function(calling)
			pcall(function() HealthbarHighlightColor.Object.Visible = calling end);
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end
	})
	HealthbarHighlightColor = HealthbarVisuals.CreateColorSlider({
		Name = 'Highlight Color',
		Function = function()
			if HealthbarVisuals.Enabled then 
				pcall(function() healthbarhighlight.Color = Color3.fromHSV(HealthbarHighlightColor.Hue, HealthbarHighlightColor.Sat, HealthbarHighlightColor.Value) end)
			end
		end
	})
	HealthbarInvis = HealthbarVisuals.CreateSlider({
		Name = 'Invisibility',
		Min = 0,
		Max = 10,
		Function = function(value)
			pcall(function() 
				oldhealthbar.Transparency = (0.1 * value);
				oldhealthbar.Parent.Parent.Transparency = (0.1 * HealthbarInvis.Value); 
			end)
		end
	})
	HealthbarBackground.Object.Visible = false;
	HealthbarText.Object.Visible = false;
	HealthbarTextColor.Object.Visible = false;
	HealthbarFont.Object.Visible = false;
	HealthbarRoundSize.Object.Visible = false;
	HealthbarHighlightColor.Object.Visible = false;
end)


run(function()
	local clandetector = {};
	local clandetectorclans = {Objectlist = {}};
	local detectedplayers = Performance.new();
	local clanloops = function(player: Player)
		if detectedplayers[player] then return end 
		repeat 
			local clan = tostring(player:GetAttribute('ClanTag'));
			for i,v in clandetectorclans.ObjectList do 
				if v:lower() == clan:lower() then 
					detectedplayers[player] = clan;
					return warningNotification('ClanDetector', `{player.DisplayName} is in the {clan:upper()} clan!`, 15)
				end
			end
			task.wait(1)
		until (not clandetector.Enabled)
	end;
	clandetector = utility.Api.CreateOptionsButton({
		Name = 'ClanDetector',
		HoverText = 'Notifies you when players are in\ncertain clans.',
		Function = function(calling)
			if calling then 
				for i,v in players:GetPlayers() do 
					if v ~= lplr then 
						task.spawn(clanloops, v)
					end
				end
				table.insert(clandetector.Connections, players.PlayerAdded:Connect(clanloops))
			end
		end
	})
	clandetectorclans = clandetector.CreateTextList({
		Name = 'Clans',
		TempText = 'clan tags',
		Function = void
	})
end)

run(function()
	local bedtp = {};
	local bedtpmethod = {Value = 'Respawn'};
	local bedtptween = {Value = 'Linear'};
	local bedtptween2 = {Value = 'None'};
	local bedtpbedshield = {};
	local bedtpautospeed = {};
	local bedtptweenspeed = {Value = 100};
	local bedtask;
	local bedtween;
	local bedtpfuncs = {
		Respawn = function(bed: Part)
			if isAlive(lplr, true) then 
				local hum = lplr.Character:FindFirstChildOfClass('Humanoid');
				hum.Health = 0;
				hum:ChangeState(Enum.HumanoidStateType.Dead);
			end
			lplr.CharacterAdded:Wait();
			repeat task.wait() until isAlive(lplr, true)
			task.wait(0.1);
			local tweenspeed = (bedtpautospeed.Enabled and (bed.Position - lplr.Character.PrimaryPart.Position).Magnitude / 1000) + 0.001 * (math.random(5, 30)) or (bedtptweenspeed.Value / 1000) + 0.1;
			local tweenstyle = bedtpautospeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[bedtptween.Value];
			bedtween = tween:Create(lplr.Character.PrimaryPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = bed.CFrame + Vector3.new(0, 5, 0)});
			bedtween:Play();
			bedtween.Completed:Wait();
			task.delay(0.8, function()
				if isAlive(lplr, true) and not isnetworkowner(lplr.Character.PrimaryPart) then 
					errorNotification('BedTP', `Failed to teleport due to lagback. Ping --> {render.ping}`, 10)
				end
			end)
		end,
		Recall = function(bed: Part)
			if isAlive(lplr, true) == false or not bedwars.AbilityController:canUseAbility('recall') then 
				return bedtp.ToggleButton();
			end;
			bedwars.AbilityController:useAbility('recall');
			lplr:GetAttributeChangedSignal('LastTeleported'):Wait();
			task.wait(0.1)
			if bedwars.AbilityController:canUseAbility('recall') then 
				local tweenspeed = (bedtpautospeed.Enabled and (bed.Position - lplr.Character.PrimaryPart.Position).Magnitude / 1000) + 0.001 * (math.random(5, 30)) or (bedtptweenspeed.Value / 1000) + 0.1;
				local tweenstyle = bedtpautospeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[bedtptween.Value];
				bedtween = tween:Create(lplr.Character.PrimaryPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = bed.CFrame + Vector3.new(0, 5, 0)});
				bedtween:Play();
				bedtween.Completed:Wait();
				task.delay(0.8, function()
					if isAlive(lplr, true) and not isnetworkowner(lplr.Character.PrimaryPart) then 
						errorNotification('BedTP', `Failed to teleport due to lagback. Ping --> {render.ping}`, 10)
					end
				end)
			end
		end,
		Telepearl = function(bed: Part, pearl: table)
			if isAlive(lplr, true) then 
				switchItem(pearl.tool);
				bedwars.Client:Get(bedwars.ProjectileRemote):CallServerAsync(pearl.tool, tostring(pearl.tool), tostring(pearl.tool), bed.Position + Vector3.new(0, 5, 0), bed.Position + Vector3.new(0, 3, 0), Vector3.new(0, -1, 0), httpservice:GenerateGUID(), {drawDurationSeconds = 1}, workspace:GetServerTimeNow());
			end
		end
	}
	bedtp = world.Api.CreateOptionsButton({
		Name = 'BedTP',
		HoverText = 'Teleport to an enemy\'s bed.',
		Function = function(calling)
			if calling then 
				if cheatenginetrash then 
					return bedtp.ToggleButton();
				end
				local bedobj = getTargetBed({nobedshield = (not bedtpbedshield.Value)});
				local telepearl = getItem('telepearl');
				if bedobj == nil then 
					return bedtp.ToggleButton();
				end
				bedtask = task.spawn(function()
					local success = pcall(telepearl and bedtpfuncs.Telepearl or bedtpfuncs[bedtpmethod.Value], bedobj, telepearl);
					if not success then 
						errorNotification('BedTP', 'An error occured.', 7);
					end
					if bedtp.Enabled then 
						bedtp.ToggleButton();
					end
				end)
			else
				pcall(task.cancel, bedtask);
				pcall(function() bedtween:Cancel() end)
			end
		end
	})
	bedtpautospeed = bedtp.CreateToggle({
		Name = 'Auto Speed',
		HoverText = 'Automatic tween speed based on distance.',
		Default = true,
		Function = function(calling)
			pcall(function() bedtptweenspeed.Object.Visible = not calling; end)
		end
	})
	bedtpbedshield = bedtp.CreateToggle({
		Name = 'No Bed Shield',
		Default = true,
		Function = void
	})
	bedtptweenspeed = bedtp.CreateSlider({
		Name = 'Tween Speed',
		Min = 50,
		Max = 150,
		Default = 100,
		Function = void
	})
	bedtpmethod = bedtp.CreateDropdown({
		Name = 'Teleport Method', 
		List = {'Recall', 'Respawn'},
		Function = void
	})
	bedtptween = bedtp.CreateDropdown({
		Name = 'Tween Method',
		List = GetEnumItems('EasingStyle'),
		Function = void
	})
	bedtptweenspeed.Object.Visible = false;
end)

run(function()
	local playertp = {};
	local playertpmethod = {Value = 'Recall'};
	local playertptween = {Value = 'Linear'};
	local playertpautospeed = {Enabled = true};
	local playertptweenspeed = {Value = 100};
	local playertask;
	local playertween;
	local playertpfuncs = {
		Respawn = function(target: table)
			if isAlive(lplr, true) then 
				local hum = lplr.Character:FindFirstChildOfClass('Humanoid');
				hum.Health = 0;
				hum:ChangeState(Enum.HumanoidStateType.Dead);
			end
			lplr.CharacterAdded:Wait();
			task.wait(0.1);
			if target.RootPart.Parent == nil then 
				return
			end
			local tweenspeed = (playertpautospeed.Enabled and (target.RootPart.Position - lplr.Character.PrimaryPart.Position).Magnitude / 1000) + 0.001 * (math.random(5, 30)) or (playertptweenspeed.Value / 1000) + 0.1;
			local tweenstyle = playertpautospeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[playertptween.Value];
			playertween = tween:Create(lplr.Character.PrimaryPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = target.RootPart.CFrame + Vector3.new(0, 5, 0)});
			playertween:Play();
			playertween.Completed:Wait();
			task.delay(0.8, function()
				if isAlive(lplr, true) and not isnetworkowner(lplr.Character.PrimaryPart) then 
					errorNotification('PlayerTP', `Failed to teleport to {target.Player.DisplayName} due to lagback. Ping --> {render.ping}`, 10)
				end
			end)
		end,
		Recall = function(target: table)
			if isAlive(lplr, true) == false or not bedwars.AbilityController:canUseAbility('recall') then 
				return
			end;
			bedwars.AbilityController:useAbility('recall');
			lplr:GetAttributeChangedSignal('LastTeleported'):Wait();
			task.wait(0.1)
			if target.RootPart.Parent == nil then 
				return
			end
			local tweenspeed = (playertpautospeed.Enabled and (target.RootPart.Position - lplr.Character.PrimaryPart.Position).Magnitude / 1000) + 0.001 * (math.random(5, 30)) or (playertptweenspeed.Value / 1000) + 0.1;
			local tweenstyle = playertpautospeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[playertptween.Value];
			playertween = tween:Create(lplr.Character.PrimaryPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = target.RootPart.CFrame + Vector3.new(0, 5, 0)});
			playertween:Play();
			playertween.Completed:Wait();
			task.delay(0.8, function()
				if isAlive(lplr, true) and not isnetworkowner(lplr.Character.PrimaryPart) then 
					errorNotification('PlayerTP', `Failed to teleport to {target.Player.DisplayName} due to lagback. Ping --> {render.ping}`, 10)
				end
			end)
		end,
		Telepearl = function(target: table, pearl: table)
			if isAlive(lplr, true) then 
				switchItem(pearl.tool);
				bedwars.Client:Get(bedwars.ProjectileRemote):CallServerAsync(pearl.tool, tostring(pearl.tool), tostring(pearl.tool), target.RootPart.Position + Vector3.new(0, 5, 0), target.RootPart.Position + Vector3.new(0, 3, 0), Vector3.new(0, -1, 0), httpservice:GenerateGUID(), {drawDurationSeconds = 1}, workspace:GetServerTimeNow());
			end
		end
	}
	playertp = world.Api.CreateOptionsButton({
		Name = 'PlayerTP',
		HoverText = 'Teleports you to players.',
		Function = function(calling)
			if calling then
				local ent = GetTarget();
				local telepearl = getItem('telepearl');
				if ent.RootPart == nil then 
					return playertp.ToggleButton();
				end
				playertask = task.spawn(function()
					local success, result = pcall(telepearl and playertpfuncs.Telepearl or playertpfuncs[playertpmethod.Value], ent, telepearl);
					if not success then 
						errorNotification('PlayerTP', `An error occured while teleporting to {ent.Player.DisplayName}.`, 7);
					end
					if playertp.Enabled then 
						playertp.ToggleButton();
					end
				end)
			else
				pcall(task.cancel, playertween);
				pcall(function() playertween:Cancel() end)
			end
		end
	})
	if cheatenginetrash == nil then 
		playertpautospeed = playertp.CreateToggle({
			Name = 'Auto Speed',
			HoverText = 'Automatic tween speed based on distance.',
			Default = true,
			Function = function(calling)
				pcall(function() bedtptweenspeed.Object.Visible = not calling; end)
			end
		})
	end
	playertptween = playertp.CreateSlider({
		Name = 'Tween Speed',
		Min = 50,
		Max = 150,
		Default = 100,
		Function = void
	})
	playertpmethod = playertp.CreateDropdown({
		Name = 'Teleport Method', 
		List = {'Recall', 'Respawn'},
		Function = void
	})
	playertptween = playertp.CreateDropdown({
		Name = 'Tween Method',
		List = GetEnumItems('EasingStyle'),
		Function = void
	})
	pcall(function() playertpautospeed.Object.Visible = cheatenginetrash == nil; end)
end)

run(function()
	local diamondtp = {};
	local diamondtpmethod = {Value = 'Recall'};
	local diamondtptween = {Value = 'Linear'};
	local diamondtpautospeed = {};
	local diamondtptweenspeed = {Value = 100};
	local diamondtask;
	local diamondtween;
	local diamondtpfuncs = {
		Respawn = function(drop: Part)
			if not isAlive(lplr, true) then 
				local hum = lplr.Character:FindFirstChildOfClass('Humanoid');
				hum.Health = 0;
				hum:ChangeState(Enum.HumanoidStateType.Dead);
			end
			lplr.CharacterAdded:Wait();
			repeat task.wait() until isAlive(lplr, true);
			task.wait(0.1);
			if drop.Parent == nil then 
				return
			end
			local tweenspeed = (diamondtpautospeed.Enabled and (drop.Position - lplr.Character.PrimaryPart.Position).Magnitude / 1000) + 0.001 * (math.random(5, 30)) or (diamondtptweenspeed.Value / 1000) + 0.1;
			local tweenstyle = diamondtpautospeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[diamondtptween.Value];
			diamondtween = tween:Create(lplr.Character.PrimaryPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = drop.CFrame + Vector3.new(0, 5, 0)});
			diamondtween:Play();
			diamondtween.Completed:Wait();
			task.delay(0.8, function()
				if isAlive(lplr, true) and not isnetworkowner(lplr.Character.PrimaryPart) then 
					errorNotification('DiamondTP', `Failed to teleport due to lagback. Ping --> {render.ping}`, 10)
				end
			end)
		end,
		Recall = function(drop: Part)
			if isAlive(lplr, true) == false or not bedwars.AbilityController:canUseAbility('recall') then 
				return
			end;
			bedwars.AbilityController:useAbility('recall');
			lplr:GetAttributeChangedSignal('LastTeleported'):Wait();
			task.wait(0.1)
			if drop.Parent == nil then 
				return
			end
			local tweenspeed = (diamondtpautospeed.Enabled and (drop.Position - lplr.Character.PrimaryPart.Position).Magnitude / 1000) + 0.001 * (math.random(5, 30)) or (diamondtptweenspeed.Value / 1000) + 0.1;
			local tweenstyle = diamondtpautospeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[diamondtptween.Value];
			diamondtween = tween:Create(lplr.Character.PrimaryPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = drop.CFrame + Vector3.new(0, 5, 0)});
			diamondtween:Play();
			diamondtween.Completed:Wait();
			task.delay(0.8, function()
				if isAlive(lplr, true) and not isnetworkowner(lplr.Character.PrimaryPart) then 
					errorNotification('DiamondTP', `Failed to teleport due to lagback. Ping --> {render.ping}`, 10)
				end
			end)
		end,
		Telepearl = function(drop: Part, pearl: table)
			if isAlive(lplr, true) then 
				switchItem(drop.tool);
				bedwars.Client:Get(bedwars.ProjectileRemote):CallServerAsync(drop.tool, tostring(pearl.tool), tostring(pearl.tool), drop.Position + Vector3.new(0, 5, 0), drop.Position + Vector3.new(0, 3, 0), Vector3.new(0, -1, 0), httpservice:GenerateGUID(), {drawDurationSeconds = 1}, workspace:GetServerTimeNow());
			end
		end
	}
	diamondtp = world.Api.CreateOptionsButton({
		Name = 'DiamondTP',
		HoverText = 'Teleport to the nearest diamond drop',
		Function = function(calling)
			if calling then 
				if cheatenginetrash then 
					return diamondtp.ToggleButton()
				end
				local diamond = getTargetItemDrop({type = 'diamond'});
				local telepearl = getItem('telepearl');
				if diamond == nil then 
					return diamondtp.ToggleButton()
				end;
				diamondtask = task.spawn(function()
					local success, result = pcall(telepearl and diamondtpfuncs.Telepearl or diamondtpfuncs[diamondtpmethod.Value], diamond, telepearl);
					if not success then 
						errorNotification('DiamondTP', `An error occured while teleporting.`, 7);
					end
				end)
			end
		end
	})
	diamondtpautospeed = diamondtp.CreateToggle({	
		Name = 'Auto Speed',
		HoverText = 'Automatic tween speed based on distance.',
		Default = true,
		Function = function(calling)
			pcall(function() diamondtptweenspeed.Object.Visible = not calling; end)
		end
	})
	diamondtptweenspeed = diamondtp.CreateSlider({
		Name = 'Tween Speed',
		Min = 50,
		Max = 150,
		Default = 100,
		Function = void
	})
	diamondtpmethod = diamondtp.CreateDropdown({
		Name = 'Teleport Method', 
		List = {'Recall', 'Respawn'},
		Function = void
	})
	diamondtptween = diamondtp.CreateDropdown({
		Name = 'Tween Method',
		List = GetEnumItems('EasingStyle'),
		Function = void
	})
	diamondtpautospeed.Object.Visible = false;
end)

run(function()
	local diamondtp = {};
	local diamondtpmethod = {Value = 'Recall'};
	local diamondtptween = {Value = 'Linear'};
	local diamondtpautospeed = {};
	local diamondtptweenspeed = {Value = 100};
	local diamondtask;
	local diamondtween;
	local diamondtpfuncs = {
		Respawn = function(drop: Part)
			if not isAlive(lplr, true) then 
				local hum = lplr.Character:FindFirstChildOfClass('Humanoid');
				hum.Health = 0;
				hum:ChangeState(Enum.HumanoidStateType.Dead);
			end
			lplr.CharacterAdded:Wait();
			repeat task.wait() until isAlive(lplr, true);
			task.wait(0.1);
			if drop.Parent == nil then 
				return
			end
			local tweenspeed = (diamondtpautospeed.Enabled and (drop.Position - lplr.Character.PrimaryPart.Position).Magnitude / 1000) + 0.001 * (math.random(5, 30)) or (diamondtptweenspeed.Value / 1000) + 0.1;
			local tweenstyle = diamondtpautospeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[diamondtptween.Value];
			diamondtween = tween:Create(lplr.Character.PrimaryPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = v.CFrame + Vector3.new(0, 5, 0)});
			diamondtween:Play();
			diamondtween.Completed:Wait();
			task.delay(0.8, function()
				if isAlive(lplr, true) and not isnetworkowner(lplr.Character.PrimaryPart) then 
					errorNotification('DiamondTP', `Failed to teleport due to lagback. Ping --> {render.ping}`, 10)
				end
			end)
		end,
		Recall = function(drop: Part)
			if isAlive(lplr, true) == false or not bedwars.AbilityController:canUseAbility('recall') then 
				return
			end;
			bedwars.AbilityController:useAbility('recall');
			lplr:GetAttributeChangedSignal('LastTeleported'):Wait();
			task.wait(0.1)
			if drop.Parent == nil then 
				return
			end
			local tweenspeed = (diamondtpautospeed.Enabled and (drop.Position - lplr.Character.PrimaryPart.Position).Magnitude / 1000) + 0.001 * (math.random(5, 30)) or (diamondtptweenspeed.Value / 1000) + 0.1;
			local tweenstyle = diamondtpautospeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[diamondtptween.Value];
			diamondtween = tween:Create(lplr.Character.PrimaryPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = v.CFrame + Vector3.new(0, 5, 0)});
			diamondtween:Play();
			diamondtween.Completed:Wait();
			task.delay(0.8, function()
				if isAlive(lplr, true) and not isnetworkowner(lplr.Character.PrimaryPart) then 
					errorNotification('DiamondTP', `Failed to teleport due to lagback. Ping --> {render.ping}`, 10)
				end
			end)
		end,
		Telepearl = function(drop: Part, pearl: table)
			if isAlive(lplr, true) then 
				switchItem(drop.tool);
				bedwars.Client:Get(bedwars.ProjectileRemote):CallServerAsync(drop.tool, tostring(pearl.tool), tostring(pearl.tool), drop.Position + Vector3.new(0, 5, 0), drop.Position + Vector3.new(0, 3, 0), Vector3.new(0, -1, 0), httpservice:GenerateGUID(), {drawDurationSeconds = 1}, workspace:GetServerTimeNow());
			end
		end
	}
	diamondtp = world.Api.CreateOptionsButton({
		Name = 'DiamondTP',
		HoverText = 'Teleport to the nearest diamond drop',
		Function = function(calling)
			if calling then 
				if cheatenginetrash then 
					return diamondtp.ToggleButton()
				end
				local diamond = getTargetItemDrop({type = 'diamond'});
				local telepearl = getItem('telepearl');
				if diamond == nil then 
					return diamondtp.ToggleButton()
				end;
				diamondtask = task.spawn(function()
					local success, result = pcall(telepearl and diamondtpfuncs.Telepearl or diamondtpfuncs[diamondtpmethod.Value], diamond, telepearl);
					if not success then 
						errorNotification('DiamondTP', `An error occured while teleporting.`, 7);
					end
				end)
			end
		end
	})
	diamondtpautospeed = diamondtp.CreateToggle({	
		Name = 'Auto Speed',
		HoverText = 'Automatic tween speed based on distance.',
		Default = true,
		Function = function(calling)
			pcall(function() diamondtptweenspeed.Object.Visible = not calling; end)
		end
	})
	diamondtptweenspeed = diamondtp.CreateSlider({
		Name = 'Tween Speed',
		Min = 50,
		Max = 150,
		Default = 100,
		Function = void
	})
	diamondtpmethod = diamondtp.CreateDropdown({
		Name = 'Teleport Method', 
		List = {'Recall', 'Respawn'},
		Function = void
	})
	diamondtptween = diamondtp.CreateDropdown({
		Name = 'Tween Method',
		List = GetEnumItems('EasingStyle'),
		Function = void
	})
	diamondtpautospeed.Object.Visible = false;
end)

run(function()
	local emeraldtp = {};
	local emeraldtpmethod = {Value = 'Recall'};
	local emeraldtptween = {Value = 'Linear'};
	local emeraldtpautospeed = {};
	local emeraldtptweenspeed = {Value = 100};
	local emeraldtask;
	local emeraldtween;
	local emeraldtpfuncs = {
		Respawn = function(drop: Part)
			if not isAlive(lplr, true) then 
				local hum = lplr.Character:FindFirstChildOfClass('Humanoid');
				hum.Health = 0;
				hum:ChangeState(Enum.HumanoidStateType.Dead);
			end
			lplr.CharacterAdded:Wait();
			repeat task.wait() until isAlive(lplr, true);
			task.wait(0.1);
			if drop.Parent == nil then 
				return
			end
			local tweenspeed = (emeraldtpautospeed.Enabled and (drop.Position - lplr.Character.PrimaryPart.Position).Magnitude / 1000) + 0.001 * (math.random(5, 30)) or (emeraldtptweenspeed.Value / 1000) + 0.1;
			local tweenstyle = emeraldtpautospeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[emeraldtptween.Value];
			emeraldtween = tween:Create(lplr.Character.PrimaryPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = drop.CFrame + Vector3.new(0, 5, 0)});
			emeraldtween:Play();
			emeraldtween.Completed:Wait();
			task.delay(0.8, function()
				if isAlive(lplr, true) and not isnetworkowner(lplr.Character.PrimaryPart) then 
					errorNotification('EmeraldTP', `Failed to teleport due to lagback. Ping --> {render.ping}`, 10)
				end
			end)
		end,
		Recall = function(drop: Part)
			if isAlive(lplr, true) == false or not bedwars.AbilityController:canUseAbility('recall') then 
				return
			end;
			bedwars.AbilityController:useAbility('recall');
			lplr:GetAttributeChangedSignal('LastTeleported'):Wait();
			task.wait(0.1)
			if drop.Parent == nil then 
				return
			end
			local tweenspeed = (emeraldtpautospeed.Enabled and (drop.Position - lplr.Character.PrimaryPart.Position).Magnitude / 1000) + 0.001 * (math.random(5, 30)) or (emeraldtptweenspeed.Value / 1000) + 0.1;
			local tweenstyle = emeraldtpautospeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[emeraldtptween.Value];
			emeraldtween = tween:Create(lplr.Character.PrimaryPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = drop.CFrame + Vector3.new(0, 5, 0)});
			emeraldtween:Play();
			emeraldtween.Completed:Wait();
			task.delay(0.8, function()
				if isAlive(lplr, true) and not isnetworkowner(lplr.Character.PrimaryPart) then 
					errorNotification('EmeraldTP', `Failed to teleport due to lagback. Ping --> {render.ping}`, 10)
				end
			end)
		end,
		Telepearl = function(drop: Part, pearl: table)
			if isAlive(lplr, true) then 
				switchItem(drop.tool);
				bedwars.Client:Get(bedwars.ProjectileRemote):CallServerAsync(drop.tool, tostring(pearl.tool), tostring(pearl.tool), drop.Position + Vector3.new(0, 5, 0), drop.Position + Vector3.new(0, 3, 0), Vector3.new(0, -1, 0), httpservice:GenerateGUID(), {drawDurationSeconds = 1}, workspace:GetServerTimeNow());
			end
		end
	}
	emeraldtp = world.Api.CreateOptionsButton({
		Name = 'EmeraldTP',
		HoverText = 'Teleport to the nearest emerald drop',
		Function = function(calling)
			if calling then 
				if cheatenginetrash then 
					return emeraldtp.ToggleButton()
				end
				local emerald = getTargetItemDrop({type = 'emerald'});
				local telepearl = getItem('telepearl');
				if emerald == nil then 
					return emeraldtp.ToggleButton()
				end;
				emeraldtask = task.spawn(function()
					local success, result = pcall(telepearl and emeraldtpfuncs.Telepearl or emeraldtpfuncs[emeraldtpmethod.Value], emerald, telepearl);
					if not success then 
						errorNotification('EmeraldTP', `An error occured while teleporting.`, 7);
					end
				end)
			end
		end
	})
	emeraldtpautospeed = emeraldtp.CreateToggle({	
		Name = 'Auto Speed',
		HoverText = 'Automatic tween speed based on distance.',
		Default = true,
		Function = function(calling)
			pcall(function() emeraldtptweenspeed.Object.Visible = not calling; end)
		end
	})
	emeraldtptweenspeed = emeraldtp.CreateSlider({
		Name = 'Tween Speed',
		Min = 50,
		Max = 150,
		Default = 100,
		Function = void
	})
	emeraldtpmethod = emeraldtp.CreateDropdown({
		Name = 'Teleport Method', 
		List = {'Recall', 'Respawn'},
		Function = void
	})
	emeraldtptween = emeraldtp.CreateDropdown({
		Name = 'Tween Method',
		List = GetEnumItems('EasingStyle'),
		Function = void
	})
	emeraldtpautospeed.Object.Visible = false;
end)

run(function()
	local cloudmods = {};
	local cloudmodsneon = {};
	local cloudmodscolor = newcolor();
	local updatecloud = function(cloud: Part) 
		pcall(function()
			cloud.Color = Color3.fromHSV(cloudmodscolor.Hue, cloudmodscolor.Sat, cloudmodscolor.Value);
			cloud.Material = cloudmodsneon.Enabled and Enum.Material.Neon or Enum.Material.SmoothPlastic;
		end)
	end;
	cloudmods = visual.Api.CreateOptionsButton({
		Name = 'CloudMods',
		HoverText = 'Changes the color of the clouds.',
		Function = function(calling)
			if calling then 
				for i,v in workspace:WaitForChild('Clouds', 9e9):GetChildren() do 
					task.spawn(updatecloud, v);
				end;
				table.insert(cloudmods.Connections, workspace.Clouds.ChildAdded:Connect(updatecloud));
			else 
				if workspace:FindFirstChild('Clouds') then 
					for i,v in workspace.Clouds:GetChildren() do 
						v.Color = Color3.fromRGB(255, 255, 255);
				        v.Material = Enum.Material.SmoothPlastic;
					end
				end
			end
		end
	})
	cloudmodscolor = cloudmods.CreateColorSlider({
		Name = 'Color',
		Function = function()
			local clouds = cloudmods.Enabled and workspace:FindFirstChild('Clouds');
			if clouds then 
				for i,v in clouds:GetChildren() do 
					task.spawn(updatecloud, v);
				end
			end
		end
	})
	cloudmodsneon = cloudmods.CreateToggle({
		Name = 'Neon',
		Function = function()
			local clouds = cloudmods.Enabled and workspace:FindFirstChild('Clouds');
			if clouds then 
				for i,v in clouds:GetChildren() do 
					task.spawn(updatecloud, v);
				end
			end
		end
	})
end)

run(function()
	local invis = {};
	local invisbaseparts = Performance.new({jobdelay = 0.1});
	local invisroot = {};
	local invisrootcolor = newcolor();
	local invisanim = Instance.new('Animation');
	local invisrenderstep;
	local invistask;
	local invishumanim;
	local invisFunction = function()
		repeat task.wait() until isAlive(lplr, true);
		pcall(task.cancel, invistask);
		pcall(function() invisrenderstep:Disconnect() end);
		for i,v in lplr.Character:GetDescendants() do 
			pcall(function()
				if v.CanCollide and v ~= lplr.Character.PrimaryPart then 
					v.CanCollide = false;
					table.insert(invisbaseparts, v);
				end
			end)
		end;
		table.insert(invis.Connections, lplr.Character.DescendantAdded:Connect(function(v: BasePart?)
			pcall(function()
				if v.CanCollide and v ~= lplr.Character.HumanoidRootPart then 
					v.CanCollide = false;
					table.insert(invisbaseparts, v);
				end
			end)
		end));
		invisrenderstep = runservice.Stepped:Connect(function()
			for i,v in invisbaseparts do 
				v.CanCollide = false;
			end
		end);
		table.insert(invis.Connections, invisrenderstep);
		invisanim.AnimationId = 'rbxassetid://11335949902';
		local anim = lplr.Character.Humanoid:WaitForChild('Animator', 9e9):LoadAnimation(invisanim);
		invishumanim = anim;
		repeat 
			task.wait()
			if vape.ObjectsThatCanBeSaved.AnimationPlayerOptionsButton.Api.Enabled then 
				vape.ObjectsThatCanBeSaved.AnimationPlayerOptionsButton.Api.ToggleButton();
			end
			if isAlive(lplr, true) == false or not isnetworkowner(lplr.Character.PrimaryPart) or not invis.Enabled then 
				pcall(function() 
					anim:AdjustSpeed(0);
					anim:Stop() 
				end);
				continue
			end;
			lplr.Character.PrimaryPart.Transparency = invisroot.Enabled and 0.6 or 1;
			lplr.Character.PrimaryPart.Color = Color3.fromHSV(invisrootcolor.Hue, invisrootcolor.Sat, invisrootcolor.Value);
			anim:Play(0.1, 9e9, 0.1);
		until (not invis.Enabled)
	end;
	invis = visual.Api.CreateOptionsButton({
		Name = 'Invisibility',
		HoverText = 'Plays an animation which makes it harder\nfor targets to see you.',
		Function = function(calling)
			if calling then 
				invistask = task.spawn(invisFunction);
				table.insert(invis.Connections, lplr.CharacterAdded:Connect(invisFunction))
			else 
				pcall(function()
					invishumanim:AdjustSpeed(0);
					invishumanim:Stop();
				end);
				pcall(task.cancel, invistask)
			end
		end
	})
	invisroot = invis.CreateToggle({
		Name = 'Show Root',
		Default = true,
		Function = function(calling)
			pcall(function() invisrootcolor.Object.Visible = calling; end)
		end
	})
	invisrootcolor = invis.CreateColorSlider({
		Name = 'Root Color',
		Function = void
	})
end)

run(function()
	local melodyexploit = {};
	local melodytick = tick();
	local getguitar = function()
		for i,v in replicatedstorage.Inventories:GetChildren() do 
			if v.Name == lplr.Name and v:FindFirstChild('guitar') then 
				return {tool = v.guitar, itemType = 'guitar'};
			end
		end
	end
	melodyexploit = exploit.Api.CreateOptionsButton({
		Name = 'MelodyExploit',
		HoverText = 'Regen 50+ HP every 2 seconds.',
		Function = function(calling)
			if calling then 
				repeat 
					if isAlive(lplr, true) and tick() > melodytick and getguitar() and lplr.Character:GetAttribute('Health') < lplr.Character:GetAttribute('MaxHealth') then 
						bedwars.Client:Get('PlayGuitar'):SendToServer({healTarget = lplr});
						bedwars.Client:Get('StopPlayingGuitar'):SendToServer();
						melodytick = tick() + 0.45;
					end
					task.wait()
				until (not melodyexploit.Enabled)
			end
		end
	})
end);

run(function()
	local projectileaura = {};
	local projauraextra = {ObjectList = {}};
	local projaurablacklist = {ObjectList = {}};
	local projauranpc = {};
	local projaurarangeoption = {};
	local projaurakillauradisable = {};
	local projauraswitchdelay = {Value = 0};
	local projaurasort = {Value = 'Distance'};
	local projaurarange = {Value = 2000};
	local projectileaurathread;
	local mobdisabledprojectiles = {'spear'};
	local crackerdelay = tick();
	local lastfired = setmetatable({}, {
		__index = function(self, index)
			return rawget(self, index) or tick() - 1e1;
		end
	});
	local customprojectiles = {
		rainbow_bow = 'rainbow_arrow',
		orions_belt_bow = 'star',
		fireball = 'fireball',
		frosted_snowball = 'frosted_snowball',
		snowball = 'snowball',
		spear = 'spear',
		carrot_cannon = 'carrot_rocket',
		light_sword = 'sword_wave1',
		firecrackers = 'firecrackers'
	};
	local projaurasortfuncs = {
		Distance = function()
			local bestdistance: number, target: rendertarget = math.huge, nil;
			for i: number, v: rendertarget in GetAllTargets() do 	
				local distance: number = ((render.clone.old and render.clone.old.Position or entityLibrary.LocalPosition) - v.RootPart.Position).Magnitude;
				if distance < bestdistance and distance <= projaurarange.Value and bedwars.SwordController:canSee({instance = v.RootPart.Parent, player = v.Player, getInstance = function() return v.RootPart.Parent end}) then 
					if v.RootPart.Parent:FindFirstChildOfClass('ForceField') then 
						continue;
					end;
					bestdistance = distance;
					target = v;
				end;
			end;
			return target;
		end
	}
	local getarrow = function()
		for i,v in store.localInventory.inventory.items do  
			if v.itemType:find('arrow') then 
				return v;
			end
		end
	end;
	local getammo = function(item: table)
		local special = customprojectiles[item.itemType];
		if (item.itemType:find('bow') or item.itemType:find('headhunter')) and special == nil then 
			return getarrow() or {}; 
		end;
		if item.itemType:find('ninja_chakram') then 
			return getItem(item.itemType);
		end;
		if item.itemType == 'light_sword' then 
			return {tool = 'sword_wave1'} 
		end;
		for i,v in projaurablacklist.ObjectList do 
			if item.itemType:find(v:lower()) then 
				return {};
			end 
		end;
		if special then 
			return getItem(special) or {};
		end;
		for i,v in projauraextra.ObjectList do 
			local args = v:split(':')
			if args[1] and args[1]:find(item.itemType) then 
				for i2, v2 in store.localInventory.inventory.items do 
					if v2.itemType:find(args[2] or args[1]) then 
						return v2;
					end
				end
			end
		end
		return {};
	end;
	local betterswitch = function(item: Accessory)
		if item.Name == 'firecrackers' then 
			if crackerdelay > tick() then 
				return;
			else 
				crackerdelay = tick() + 3.5;
			end 
		end;
		if tick() > store.switchdelay then 
			switchItem(item); 
		end;
		local oldval = projauraswitchdelay.Value;
		local oldtime = tick() + (0.1 * oldval);
		repeat task.wait() until tick() > oldtime or projauraswitchdelay.Value ~= oldval;
	end;
	projectileaura = blatant.Api.CreateOptionsButton({
		Name = 'ProjectileAura',
		HoverText = 'Automatically shoots projectiles and\nnearby targets.',
		Function = function(calling)
			if calling then 
				if renderperformance.reducelag then 
					return 
				end;
				projectileaurathread = task.spawn(function()
					repeat 
						task.wait(0.1);
						if vapeTargetInfo.Targets.Killaura then 
							continue 
						end;
						for i,v in store.localInventory.inventory.items do 
							local target = projaurasortfuncs[projaurasort.Value]();
							local projdata = bedwars.ItemTable[v.itemType] and bedwars.ItemTable[v.itemType].projectileSource;
							if target then 
								if target.npc and table.find(mobdisabledprojectiles, v.itemType) then 
									continue
								end;
								if projaurakillauradisable.Enabled and killauraNearPlayer then 
									continue
								end;
								local ammo = getammo(v);
								if store.matchState ~= 0 and (lplr:GetAttribute('PlayingAsKit') or store.equippedKit) == 'dragon_sword' then 
									bedwars.Client:Get('DragonSwordFire'):SendToServer({target = target.RootPart.Parent});
								end
								if ammo.tool then 
									if projdata and projdata.fireDelaySec and (tick() - lastfired[v.itemType]) < projdata.fireDelaySec then 
										continue
									else 
										task.wait(0.02)
									end;
									betterswitch(v.tool);
                                    projdata = projdata or {};
                                    local selfpos = lplr.Character.PrimaryPart.Position;
                                    local shootpos: Vector3 = predictGravity(target.RootPart.Position, target.RootPart.Velocity, (target.RootPart.Position - (selfpos + Vector3.new(0, 2, 0))).Magnitude / (projdata.launchVelocity or 100), target, workspace.Gravity * (projdata.gravityMultiplier or 1));
                                    --local predicted = LaunchDirection(selfpos + Vector3.new(0, 2, 0), shootpos, projdata.launchVelocity or 100, projdata.gravitationalAcceleration or 196.2, false);
									local predicted = LaunchDirection(selfpos + Vector3.new(0, 2, 0), shootpos, 100, 196.2, false);
                                    if predicted then 
                                        task.spawn(function() 
                                            bedwars.Client:Get(bedwars.ProjectileRemote):CallServerAsync(v.tool, tostring(ammo.tool), tostring(ammo.tool), selfpos + Vector3.new(0, 2, 0), selfpos, predicted, getservice('HttpService'):GenerateGUID(), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045, true)
                                            lastfired[v.itemType] = tick();
                                        end);
                                    end
								end
							end;
						end;
					until (not projectileaura.Enabled)
				end)
			else 
				task.cancel(projectileaurathread)
			end
		end
	})
	projaurarangeoption = projectileaura.CreateToggle({
		Name = 'Custom Range',
		Function = function(calling)
			pcall(function() projaurarange.Object.Visible = calling end);
		end
	})
	projauranpc = projectileaura.CreateToggle({
		Name = 'NPC',
		HoverText = 'Targets NPCs too',
		Function = void
	})
	projaurakillauradisable = projectileaura.CreateToggle({
		Name = 'No Killaura',
		Default = true,
		Function = void
	})
	projauraswitchdelay = projectileaura.CreateSlider({
		Name = 'Switch Delay', 
		Min = 0,
		Max = 30,
		Function = void
	})
	projaurarange = projectileaura.CreateSlider({
		Name = 'Range',
		Min = 10,
		Max = 100,
		Default = 30,
		Function = void
	})
	projauraextra = projectileaura.CreateTextList({
		Name = 'Extra Projectiles',
		TempText = 'custom eg. (gun:ammo)',
		AddFunction = void
	})
	projaurablacklist = projectileaura.CreateTextList({
		Name = 'Blacklist',
		TempText = 'blacklisted projectiles',
		AddFunction = void
	})
end)

run(function()
	local autoqueue = {};
	local autoqueuerandom = {};
	local isteamalive = function()
		for i,v in players:GetPlayers() do 
			if v:GetAttribute('Team') == lplr:GetAttribute('Team') and not v:GetAttribute('Spectator') then 
				return true;
			end;
		end;
		return false;
	end;
	local dumpmeta = function()
		local queuemeta = {}
		for i,v in bedwars.QueueMeta do 
			if v.title ~= 'Sandbox' and i ~= 'training_room' and not v.disabled and not v.ranked then 
				table.insert(queuemeta, i) 
			end 
		end 
		return queuemeta
	end;
	autoqueue = utility.Api.CreateOptionsButton({
		Name = 'AutoQueue',
		HoverText = 'Automatically starts a new match\nwhen you die/game ends',
		Function = function(calling)
			if calling then 
				repeat 
					if store.matchState == 2 or store.matchState ~= 0 and isteamalive() == false then 
						if autoqueuerandom.Enabled then 
							bedwars.QueueController:joinQueue(getrandomvalue(dumpmeta()));
						else
							bedwars.QueueController:joinQueue(store.queueType);
						end
						break;
					end
					task.wait()
				until (not autoqueue.Enabled)
			end
		end
	});
	autoqueuerandom = autoqueue.CreateToggle({
		Name = 'Random',
		HoverText = 'Chooses a random queue.',
		Function = void
	})
end)

run(function()
	local staffdetector = {};
	local staffdetectoraction = {Value = 'Uninject'};
	local staffdetectorfamous = {};
	local staffconfig = {staffaccounts = {}};
	local knownstaff = {};
	local staffdetectorinitiated;
	local staffdetectorthreads: securetable = Performance.new();
	local staffdetectorconnections: securetable = Performance.new();
	local staffdetectorplayeradded: securetable = Performance.new();
	local staffdetectorfriendscache: securetable = Performance.new();
	local staffdetectionfuncs = setmetatable({}, {
		__newindex = function(self, index, func)
			local newfunc = function(...)
				staffdetectorinitiated = true;
				task.spawn(pcall, function() bedwars.QueueController:leaveParty() end);
				return func(...);
			end;
			if self[index] == nil then 
				return rawset(self, index, newfunc); 
			end
		end
	})
	staffdetectionfuncs.Notify = void;
	staffdetectionfuncs.Uninject = vape.SelfDestruct;
	staffdetectionfuncs.Lobby = function() teleport:Teleport(6872265039) end;
	staffdetectionfuncs.Config = function()
		for i,v in vape.ObjectsThatCanBeSaved do 
			if v.Type == 'OptionsButton' and table.find(staffconfig.legitmodules, i:gsub('OptionsButton', '')) == nil then 
					vape.SaveSettings = function() end;
					if v.Api.Enabled then
						v.Api.ToggleButton();
					end
					vape.RemoveObject(i);
				end
			end
		end;
		local savestaffdata = function(plr: Player, detection: string)
			local success, json = pcall(function() 
				return httpservice:JSONDecode(readfile('rendervape/cache/staffdata.json'))
			end);
			if not success then 
				json = {};
			end;
			table.insert(json, {Username = plr.Name, DisplayName = plr.DisplayName, Detection = detection, Tick = tick()});
			if isfolder('rendervape') then 
				writefile('rendervape/cache/staffdata.json', httpservice:JSONEncode(json));
			end
		end;
		local matchtag = function(tag: StringValue?)
			if tag.ClassName ~= 'StringValue' or tag.Value:find(tag.Parent.Parent:GetAttribute('ClanTag')) then 
				return; 
			end
			if tag.Value:lower():find('mod') or tag.Value:lower():find('dev') or tag.Value:lower():find('owner') then 
				return true;
			end
			if staffdetectorfamous.Enabled and tag.Value:lower():find('famous') then 
				return true;
			end
		end;
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
		local friendingame: (Player) -> boolean = function(plr)
			for i: number, v: Player in players:GetPlayers() do
				local friends: table = staffdetectorfriendscache[plr] or getfriends(v);
				staffdetectorfriendscache[plr] = friends;  
				if table.find(friends, plr.UserId) then 
					return true 
				end
			end;
			return false
		end;
		local staffdetectorLoop = function(player: Player, connections: table, threads: table)
			local newconnection: RBXScriptConnection;
			if bedwars.PermissionController:isStaffMember(player) then 
				savestaffdata(player, 'GROUP');
				errorNotification('StaffDetector', `A special player has been detected in your match (@{player.DisplayName} [{v.Value:upper()}]).`, 60);
				return staffdetectionfuncs[staffdetectoraction.Value]();
			end;
			local tags: Folder = player:WaitForChild('Tags', math.huge)
			for i: number, v: StringValue in tags:GetChildren() do 
				local match = matchtag(v);
				if match then
					savestaffdata(player, 'TAG');
					errorNotification('StaffDetector', `A special player has been detected in your match (@{player.DisplayName} [{v.Value:upper()}]).`, 60);
					return staffdetectionfuncs[staffdetectoraction.Value]();
				end
			end;
			newconnection = tags.ChildAdded:Connect(function(v)
				local match = matchtag(v);
				if match then
					errorNotification('StaffDetector', `A special player has been detected in your match (@{player.DisplayName} [{v.Value:upper()}]).`, 60);
					savestaffdata(player, 'TAG');
					newconnection:Disconnect();
					staffdetectionfuncs[staffdetectoraction.Value]();
				end
			end);
			table.insert(connections, newconnection)
		end;
		staffdetector = utility.Api.CreateOptionsButton({
			Name = 'StaffDetector',
			HoverText = 'Automatically takes action on staff join.',
			Function = function(calling)
				if calling then 
					if staffdetectorinitiated then return end;
					for i: number, v: Player in players:GetPlayers() do 
						if v ~= lplr then 
							local connections: table = staffdetectorconnections[v] or {};
							local threads: table = staffdetectorthreads[v] or {};
							staffdetectorplayeradded[v] = staffdetectorplayeradded[v] or tick();
							staffdetectorthreads[#staffdetectorthreads + 1] = task.spawn(staffdetectorLoop, v, connections, threads);
							staffdetectorconnections[v] = connections;
						end
					end;
					table.insert(staffdetector.Connections, players.PlayerAdded:Connect(function(v: Player)
						--v:GetAttributeChangedSignal('PlayerConnected'):Wait();
						local connections: table = staffdetectorconnections[v] or {};
						local threads: table = staffdetectorthreads[v] or {};
						staffdetectorplayeradded[v] = tick();
						staffdetectorthreads[#staffdetectorthreads + 1] = task.spawn(staffdetectorLoop, v, connections, threads);
						staffdetectorconnections[v] = connections;
						staffdetectorthreads[v] = threads;
					end));
					staffdetectorthreads.oncleanevent:Connect(function(threads: table)
						for i: number, v: thread in threads do 
							pcall(task.cancel, v)
						end;
						table.clear(threads)
					end)
				else 
					staffdetectorconnections:clear(function(connections: table)
						for i,v in connections do 
							v:Disconnect();
						end;
						table.clear(connections)
					end);
					staffdetectorthreads:clear(function(threads: table)
						for i: number, v: thread in threads do 
							pcall(task.cancel, v)
						end;
						table.clear(threads)
					end);
				end
			end
		})
		staffdetectoraction = staffdetector.CreateDropdown({
			Name = 'Action',
			List = {'Uninject', 'Lobby', 'Config', 'Notify'},
			Function = void
		})
		staffdetectorfamous = staffdetector.CreateToggle({
			Name = 'Famous',
			HoverText = 'Detects famous people in bw comm too.',
			Function = void
		})
	end);

	run(function()
		local DamageIndicator = {}
		local DamageIndicatorText = {}
		local DamageIndicatorHideStroke = {}
		local DamageIndicatorFont = {}
		local DamageIndicatorStroke = {}
		local DamageIndicatorSize = {Value = 32}
		local DamageIndicatorTextList = {ObjectList = {}}
		local DamageIndicatorFontVal = 'GothamBlack'
		local DamageIndicatorColor = {}
		local DamageIndicatorGradient = {}
		local DamageIndicatorStrokeColor = newcolor()
		local DamageIndicatorColorVal = newcolor()
		local DamageIndicatorColorVal2 = newcolor()
		local indicatorlabels = Performance.new({jobdelay = 0.1});
		local indicatorgradients = Performance.new({jobdelay = 0.1});
		local oldindicatorsize = (debug.getupvalue(bedwars.DamageIndicator, 2).textSize or 32)
		local oldstrokevisible = (debug.getupvalue(bedwars.DamageIndicator, 2).strokeThickness or 1.5)
		local oldtweencreate = tween.Create;
		local defaultindcatortext = {
			'renderintents.lol',
			'render is just better',
			'render > aether',
			'discord.gg/renderintents',
			'9e9'
		}
		local indicatorFunction = function(self, instance, ...)
			local tweendata = tween:Create(instance, ...)
			pcall(function()
				debug.getupvalue(bedwars.DamageIndicator, 2).textSize = DamageIndicatorSize.Value
				debug.getupvalue(bedwars.DamageIndicator, 2).strokeThickness = (DamageIndicatorHideStroke.Enabled or oldstrokevisible)
				local indicator = instance.Parent 
				table.insert(indicatorlabels, indicator)
				if DamageIndicatorColor.Enabled then 
					indicator.TextColor3 = Color3.fromHSV(DamageIndicatorColorVal.Hue, DamageIndicatorColorVal.Sat, DamageIndicatorColorVal.Value)
				end
				if DamageIndicatorFont.Enabled then 
					indicator.Font = DamageIndicatorFontVal.Value
				end
				if DamageIndicatorText.Enabled then 
					indicator.Text = (#DamageIndicatorTextList.ObjectList > 0 and getrandomvalue(DamageIndicatorTextList.ObjectList) or getrandomvalue(defaultindcatortext))
				end
				if DamageIndicatorColor.Enabled and DamageIndicatorGradient.Enabled then 
					indicator.TextColor3 = Color3.fromRGB(255, 255, 255)
					local gradient = Instance.new('UIGradient', indicator)
					gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHSV(DamageIndicatorColorVal.Hue, DamageIndicatorColorVal.Sat, DamageIndicatorColorVal.Value)), 
						ColorSequenceKeypoint.new(1, Color3.fromHSV(DamageIndicatorColorVal2.Hue, DamageIndicatorColorVal2.Sat, DamageIndicatorColorVal2.Value))
					})
					table.insert(indicatorgradients, gradient)
				end
				if DamageIndicatorStroke.Enabled then 
					pcall(function() indicator:FindFirstChildWhichIsA('UIStroke').Color = Color3.fromHSV(DamageIndicatorStrokeColor.Hue, DamageIndicatorStrokeColor.Sat, DamageIndicatorStrokeColor.Value) end)
				end
			end)
			return tweendata
		end
		DamageIndicator = visual.Api.CreateOptionsButton({
			Name = 'DamageIndicator',
			HoverText = 'change your damage indicator.',
			Function = function(calling)
				if calling then 
					repeat 
						debug.setupvalue(bedwars.DamageIndicator, 10, setmetatable({Create = indicatorFunction}, {
							__index = function(self, index)
								local data = rawget(self, index);
								if data == nil or not DamageIndicator.Enabled then 
									return tween[index]
								end
								return data
							end
						}))
						task.wait(1) 
					until (not DamageIndicator.Enabled)
				else
					debug.setupvalue(bedwars.DamageIndicator, 10, tween.Create)
					debug.getupvalue(bedwars.DamageIndicator, 2).textSize = oldindicatorsize
					debug.getupvalue(bedwars.DamageIndicator, 2).strokeThickness = oldstrokevisible
				end
			end
		})
		DamageIndicatorColor = DamageIndicator.CreateToggle({
			Name = 'Indicator Coloring',
			Default = true,
			Function = function(calling)
				pcall(function() DamageIndicatorColorVal.Object.Visible = calling end)
				pcall(function() DamageIndicatorGradient.Object.Visible = calling end)
				pcall(function() DamageIndicatorColorVal2.Object.Visible = (calling and DamageIndicatorGradient.Enabled) end)
			end
		})
		DamageIndicatorGradient = DamageIndicator.CreateToggle({
			Name = 'Indicator Gradient',
			Function = function(calling)
				pcall(function() DamageIndicatorColorVal.Object.Visible = (calling and DamageIndicatorColor.Enabled) end)
				pcall(function() DamageIndicatorColorVal2.Object.Visible = (calling and DamageIndicatorColor.Enabled) end)
			end
		})
		DamageIndicatorColorVal = DamageIndicator.CreateColorSlider({
			Name = 'Color',
			Function = function()
				if DamageIndicator.Enabled and DamageIndicatorColor.Enabled and not DamageIndicatorGradient.Enabled then 
					for i,v in indicatorlabels do 
						pcall(function() v.TextColor3 = Color3.fromHSV(DamageIndicatorColorVal.Hue, DamageIndicatorColorVal.Sat, DamageIndicatorColorVal.Value) end)
					end
				end
			end
		})
		DamageIndicatorColorVal2 = DamageIndicator.CreateColorSlider({
			Name = 'Color 2',
			Function = function()
				if DamageIndicator.Enabled and DamageIndicatorColor.Enabled and DamageIndicatorGradient.Enabled then 
					for i,v in indicatorlabels do 
						pcall(function() 
							v.TextColor3 = Color3.fromRGB(255, 255, 255)
							v.UIGradient.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromHSV(DamageIndicatorColorVal.Hue, DamageIndicatorColorVal.Sat, DamageIndicatorColorVal.Value)), 
								ColorSequenceKeypoint.new(1, Color3.fromHSV(DamageIndicatorColorVal2.Hue, DamageIndicatorColorVal2.Sat, DamageIndicatorColorVal2.Value))
							})
						end)
					end
				end
			end
		})
		DamageIndicatorSize = DamageIndicator.CreateSlider({
			Name = 'Indicator Size',
			Min = 5,
			Max = 0,
			Default = 32,
			Function = function(size) 
				if DamageIndicator.Enabled then 
					debug.getupvalue(bedwars.DamageIndicator, 2).textSize = size
				end
			end
		})
		DamageIndicatorStroke = DamageIndicator.CreateToggle({
			Name = 'Indicator Stroke Color',
			Function = function(calling)
				pcall(function() DamageIndicatorStrokeColor.Object.Visible = (calling and DamageIndicatorHideStroke.Enabled == false) end)
			end
		})
		DamageIndicatorStrokeColor = DamageIndicator.CreateColorSlider({
			Name = 'Stroke Color',
			Function = function()
				if DamageIndicator.Enabled and DamageIndicatorStroke.Enabled then 
					for i,v in indicatorlabels do 
						pcall(function() v:FindFirstChildWhichIsA('UIStroke').Color = Color3.fromHSV(DamageIndicatorStrokeColor.Hue, DamageIndicatorStrokeColor.Sat, DamageIndicatorStrokeColor.Value) end)
					end
				end
			end
		})
		DamageIndicatorHideStroke = DamageIndicator.CreateToggle({
			Name = 'Hide Indicator Stroke',
			Function = function(calling)
				if DamageIndicator.Enabled then 
					pcall(function() DamageIndicatorStroke.Object.Visible = (calling and DamageIndicatorStrokeColor.Object.Visible) end)
					pcall(function() DamageIndicatorStrokeColor.Object.Visible = (calling and DamageIndicatorStrokeColor.Object.Visible) end)
					debug.getupvalue(bedwars.DamageIndicator, 2).strokeThickness = (calling or oldstrokevisible)
				end
			end
		})
		DamageIndicatorFont = DamageIndicator.CreateToggle({
			Name = 'Custom Indicator Font',
			Function = function(calling)
				pcall(function() DamageIndicatorFontVal.Object.Visible = calling end)
			end
		})
		DamageIndicatorFontVal = DamageIndicator.CreateDropdown({
			Name = 'Font',
			List = dumplist(GetEnumItems('Font'), true, function(a: string, b: string) return a == 'GothamBlack' end),
			Function = function(font)
				if DamageIndicator.Enabled and DamageIndicatorFont.Enabled then 
					for i,v in indicatorlabels do 
						pcall(function() v.Font = font end)
					end
				end
			end
		})
		DamageIndicatorText = DamageIndicator.CreateToggle({
			Name = 'Custom Indicator Text',
			Function = function(calling) 
				pcall(function() DamageIndicatorTextList.Object.Visible = calling end)
			end
		})
		DamageIndicatorTextList = DamageIndicator.CreateTextList({
			Name = 'Text',
			TempText = 'custom text',
			AddFunction = function() end
		})
		DamageIndicatorColorVal.Object.Visible = false
		DamageIndicatorColorVal2.Object.Visible = false
		DamageIndicatorFontVal.Object.Visible = false 
		DamageIndicatorTextList.Object.Visible = false
		DamageIndicatorStrokeColor.Object.Visible = false
	end);

run(function()
	local damagehighlightvisuals = {};
	local highlightcolor = newcolor();
	local highlightinvis = {Value = 4};
	damagehighlightvisuals = visual.Api.CreateOptionsButton({
		Name = 'HighlightVisuals',
		HoverText = 'Changes the color of the damage highlight.',
		Function = function(calling)
			if calling then 
				table.insert(damagehighlightvisuals.Connections, workspace.DescendantAdded:Connect(function(indicator)
					if indicator.Name == '_DamageHighlight_' and indicator.ClassName == 'Highlight' then 
						repeat 
							indicator.FillColor = Color3.fromHSV(highlightcolor.Hue, highlightcolor.Sat, highlightcolor.Value);
							indicator.FillTransparency = (0.1 * highlightinvis.Value);
							task.wait()
						until (indicator.Parent == nil)
					end;
				end))
			end
		end
	})
	highlightcolor = damagehighlightvisuals.CreateColorSlider({
		Name = 'Color',
		Function = void
	})
	highlightinvis = damagehighlightvisuals.CreateSlider({
		Name = 'Invisibility',
		Min = 0,
		Max = 10,
		Default = 4,
		Function = void
	})
end);

run(function()
	local antihit = {};
	local antihitboost = {};
	local oldclone = {};
	local newclone = {};
	local bouncedelay = tick();
	local notificationTick = tick();
	local bounceskytime = {Value = 4};
	local createclone = function()
		repeat task.wait() until isAlive(lplr, true) and store.matchState ~= 0 or antihit.Enabled == false;
		task.wait(0.2);
		if not antihit.Enabled then return end;
		lplr.Character.Parent = game;
		oldroot = render.clone.new or lplr.Character.HumanoidRootPart; 
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
				if root and root.Parent == lplr.Character then 
					return root
				end;
			end
		});
	end;
	local destructclone = function()
		if isEnabled('InfiniteFly') then 
			return 
		end;
		lplr.Character.Parent = game;
		oldroot.Parent = lplr.Character;
		newroot.Parent = workspace;
		lplr.Character.PrimaryPart = oldroot;
		lplr.Character.Parent = workspace;
		entityLibrary.character.HumanoidRootPart = oldroot;
		newroot:Destroy();
		newroot = {}; 
		oldroot = {};
		render.clone = {};
	end;
	antihit = blatant.Api.CreateOptionsButton({
		Name = 'AntiHit',
		HoverText = 'Makes it harder for your opp to hit you.',
		Function = function(calling)
			if calling then 
				createclone();
				table.insert(antihit.Connections, lplr.CharacterAdded:Connect(createclone));
				table.insert(antihit.Connections, runservice.RenderStepped:Connect(function()
					if isEnabled('InfiniteFly') then return end;
					if isAlive(lplr, true) and (lplr.Character.PrimaryPart == newroot and tick() >= bouncedelay) then 
						oldroot.Velocity = Vector3.zero;
						oldroot.CFrame = newroot.CFrame;
					end
				end));
				repeat 
					if killauraNearPlayer then 
						if tick() > bouncedelay and isAlive(lplr, true) and lplr.Character.PrimaryPart == newroot then 
							bouncedelay = tick() + 0.4;
							for i = 1, 5 do 
								if isEnabled('InfiniteFly') or not killauraNearPlayer then 
									bouncedelay = tick();
									break 
								end;
								oldroot.CFrame += Vector3.new(0, 1000, 0);
								local oldval = bounceskytime.Value;
								local start = tick() + (0.01 * bounceskytime.Value);
								repeat task.wait() until (oldval ~= bounceskytime.Value or tick() >= start);
								pcall(function() oldroot.Velocity = Vector3.new(newroot.Velocity.X, -1, newroot.Velocity.Z) end);
								oldroot.CFrame = newroot.CFrame;
							end
						end
					end
					task.wait()
				until (not antihit.Enabled)
			else 
				pcall(destructclone)
			end
		end
	})
	bounceskytime = antihit.CreateSlider({
		Name = 'Dodge Delay',
		Min = 1,
		Max = 6,
		Default = 4,
		Function = void
	})
end);

run(function()
	local mousetp = {};
	local mousetpautospeed = {Enabled = true};
	local mousetpteleport = {Value = 'Recall'};
	local mousetptweenmethod = {Value = 'Linear'};
	local mousetptweenspeed = {Value = 100};
	local mousetptween;
	local mousetpthread;
	local mousetpfuncs = {
		Recall = function(block: Part)
			if isAlive(lplr, true) == false or not bedwars.AbilityController:canUseAbility('recall') then 
				return;
			end;
			bedwars.AbilityController:useAbility('recall');
			lplr:GetAttributeChangedSignal('LastTeleported'):Wait();
			task.wait(0.1);
			if bedwars.AbilityController:canUseAbility('recall') then
				local tweenspeed = (mousetpautospeed.Enabled and (block.Position - lplr.Character.PrimaryPart.Position).Magnitude / 1000) + 0.001 * (math.random(5, 30)) or (mousetptweenspeed.Value / 1000) + 0.1;
				local tweenstyle = mousetpautospeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[mousetptweenmethod.Value];
				mousetptween = tween:Create(lplr.Character.PrimaryPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = block.CFrame + Vector3.new(0, 5, 0)});
				mousetptween:Play();
				mousetptween.Completed:Wait();
				task.delay(0.8, function()
					if isAlive(lplr, true) and not isnetworkowner(lplr.Character.PrimaryPart) then 
						errorNotification('MouseTP', `Failed to teleport due to lagback. Ping --> {math.floor(render.ping)}`, 10)
					end
				end)
			end;
		end,
		Respawn = function(block: Part)
			if isAlive(lplr, true) then 
				local hum = lplr.Character:FindFirstChildOfClass('Humanoid');
				hum.Health = 0;
				hum:ChangeState(Enum.HumanoidStateType.Dead);
			end;
			lplr.CharacterAdded:Wait();
			repeat task.wait() until isAlive(lplr, true);
			task.wait(0.1);
			local tweenspeed = (mousetpautospeed.Enabled and (block.Position - lplr.Character.PrimaryPart.Position).Magnitude / 1000) + 0.001 * (math.random(5, 30)) or (mousetptweenspeed.Value / 1000) + 0.1;
			local tweenstyle = mousetpautospeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[mousetptweenmethod.Value];
			mousetptween = tween:Create(lplr.Character.PrimaryPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = block.CFrame + Vector3.new(0, 5, 0)});
			mousetptween:Play();
			mousetptween.Completed:Wait();
			task.delay(0.8, function()
				if isAlive(lplr, true) and not isnetworkowner(lplr.Character.PrimaryPart) then 
					errorNotification('MouseTP', `Failed to teleport due to lagback. Ping --> {math.floor(render.ping)}`, 10)
				end
			end)
		end
	}
	mousetp = world.Api.CreateOptionsButton({
		Name = 'MouseTP',
		HoverText = 'Teleports to the block nearest to\nyour mouse position.',
		Function = function(calling: boolean)
			if calling then 
				local block = workspace:Raycast(camera.CFrame.Position, lplr:GetMouse().UnitRay.Direction * 1e4, store.raycast);
				if block then 
					mousetpthread = task.spawn(function()
						local successful, result = pcall(isAlive() == false and mousetpfuncs.Respawn or mousetpfuncs[mousetpteleport.Value], block.Instance)
						mousetp.ToggleButton();
						if not successful then
							errorNotification('MouseTP', `An error occured{RenderDebug and ' ---> '..result or '.'} `, 7); 
						end
					end)
				end;
			else 
				pcall(task.cancel, mousetpthread)
			end
		end
	})
end);

run(function()
	local AutoExcalibur: vapemodule = {};
	AutoExcalibur = utility.Api.CreateOptionsButton({
		Name = 'AutoExcalibur',
		HoverText = 'Automatically picks up the excalibur diamond sword.',
		Function = function(calling: boolean)
			if calling then 
				repeat 
					task.wait(0.1)
					if not isAlive(lplr, true) then 
						continue 
					end;
					for i,v in collection:GetTagged('Excalibur') do 
						local distance: Vector3 = (lplr.Character.PrimaryPart.Position - v.Position).Magnitude;
						if distance <= 5 then 
							bedwars.Client:Get('RequestExcaliburSword'):CallServer({excalibur = v})
						end;
					end
				until (not AutoExcalibur.Enabled)
			end
		end
	})
end);

run(function()
	local hackerdetector: vapemodule = {};
	local hackerdetectornuker: vapeminimodule = {};
	local hackerdetectordatabase: vapeminimodule = {};
	local hackerdetectorinvisiblity: vapeminimodule = {};
	local hackerdetectorinfinitefly: vapeminimodule = {};
	local hackerdetectorconnections: securetable = Performance.new();
	local hackerdetectorthreads: securetable = Performance.new();
	local cheaterdatabase: table = {};
	local cheaterdatabaseEnums: table = {
		[1] = 'Voidware',
		[2] = 'Skid Vape',
		[3] = 'Cat V5',
		[4] = 'Galaxy Guard'
	};
	local hackerdetectormethods: table = {
		Nuker = function(player: Player, connections: table)
			local blockbreakevent: RemoteEvent = replicatedstorage.rbxts_include.node_modules['@easy-games']['block-engine'].node_modules['@rbxts'].net.out._NetManaged.BreakBlockEvent;
			local breakconnection; breakconnection = blockbreakevent.OnClientEvent:Connect(function(blockdata: table)
				if blockdata.player == player and player.Character then 
					local hand: ObjectValue | nil = player.Character:FindFirstChild('HandInvItem');
					if hand == nil or (tostring(hand.Value):find('_pickaxe') == nil and tostring(hand.Value):find('_axe') == nil and tostring(hand.Value) ~= 'shears') then 
						breakconnection:Disconnect();
						RenderLibrary:tagplayer(player, 'CHEATER', 'FF0000');
						return InfoNotification('HackerDetector', `{player.DisplayName} is using Nuker!`, 30);
					end;
				end
			end);
			table.insert(connections, breakconnection)
		end,
		Database = function(player: Player)
			repeat
				for i: number, v: {name: string, type: number, hashed: boolean} in cheaterdatabase do 
					if v.name == player.Name or v.name == tostring(player.UserId) or v.name == whitelist:hash(player.Name..player.UserId) then
						RenderLibrary:tagplayer(player, 'CHEATER', 'FF0000');
						return InfoNotification('HackerDetector', `{player.DisplayName} is on the {cheaterdatabaseEnums[v.type] or v.type} whitelist!`, 30) 
					end
				end
				task.wait(1)
			until (not hackerdetector.Enabled)
		end,
		InfiniteFly = function(player: Player)
			repeat 
				if isAlive(player, true) then 
					local uplevel = (player.Character.PrimaryPart.Position - entityLibrary.LocalPosition).Y;
					if uplevel >= 5000 and workspace:Raycast(entityLibrary.LocalPosition, Vector3.new(0, -100, 0), store.raycast) then
						RenderLibrary:tagplayer(player, 'CHEATER', 'FF0000');
						return InfoNotification('HackerDetector', `{player.DisplayName} is using InfiniteFly!`, 30) 
					end
				end
				task.wait()
			until (not hackerdetector.Enabled)
		end,
		Invisibility = function(player: Player)
			repeat
				if isAlive(player) then 
					local animator: Animator? = player.Character:FindFirstChildOfClass('Humanoid'):FindFirstChildOfClass('Animator');
					if animator then 
						for i: number, v: AnimationTrack in animator:GetPlayingAnimationTracks() do 
							if v.Animation.AnimationId == 'rbxassetid://11335949902' then 
								RenderLibrary:tagplayer(player, 'CHEATER', 'FF0000');
						        return InfoNotification('HackerDetector', `{player.DisplayName} is using Invisibility!`, 30) 
							end;
						end; 
					end;
				end;
				task.wait(0.1);
			until (not hackerdetector.Enabled)
		end
	};
	local bootdetection: (Player) -> () = function(plr)
		local detectionfuncs: table = {
			[hackerdetectornuker] = hackerdetectormethods.Nuker,
			[hackerdetectordatabase] = hackerdetectormethods.Database,
			[hackerdetectorinfinitefly] = hackerdetectormethods.InfiniteFly,
			[hackerdetectorinvisiblity] = hackerdetectormethods.Invisibility
		};
		for i: vapeminimodule, v: () -> any in detectionfuncs do 
			if i.Enabled then 
				local threads: table = hackerdetectorthreads[plr] or {};
				local connectiontab: table = hackerdetectorconnections[plr] or {};
				table.insert(threads, task.spawn(v, plr, connectiontab));
				hackerdetectorthreads[plr] = threads;
				hackerdetectorconnections[plr] = connectiontab;
			end
		end
	end;
	hackerdetector = utility.Api.CreateOptionsButton({
		Name = 'HackerDetector',
		HoverText = 'Detects cheaters in game.',
		Function = function(calling: boolean)
			if calling then 
				for i,v in players:GetPlayers() do 
					if v ~= lplr then 
						bootdetection(v)
					end
				end;
				table.insert(hackerdetector.Connections, players.PlayerAdded:Connect(bootdetection))
			else
				hackerdetectorthreads:clear(function(threads: table)
					for i: number, v: thread in threads do 
						pcall(task.cancel, threads);
					end;
					table.clear(threads)
				end);

				hackerdetectorconnections:clear(function(connections: table)
					for i: number, v: RBXScriptConnection in connections do 
						v:Disconnect();
					end;
					table.clear(connections);
				end)
			end
		end
	});

	hackerdetectorinfinitefly = hackerdetector.CreateToggle({
		Name = 'InfiniteFly',
		Default = true,
		Function = function(calling: boolean)
			if hackerdetector.Enabled then 
				hackerdetector.ToggleButton();
				hackerdetector.ToggleButton();
			end;
		end
	});
	hackerdetectormethods = hackerdetector.CreateToggle({
		Name = 'Invisibility',
		Default = true,
		Function = function(calling: boolean)
			if hackerdetector.Enabled then 
				hackerdetector.ToggleButton();
				hackerdetector.ToggleButton();
			end;
		end
	});
	hackerdetectornuker = hackerdetector.CreateToggle({
		Name = 'Nuker',
		Default = true,
		Function = function(calling: boolean)
			if hackerdetector.Enabled then 
				hackerdetector.ToggleButton();
				hackerdetector.ToggleButton();
			end;
		end
	});
	hackerdetectordatabase = hackerdetector.CreateToggle({
		Name = 'Exploit Databases',
		HoverText = 'Checks whitelists of certain exploits.',
		Default = true,
		Function = function(calling: boolean)
			if hackerdetector.Enabled then 
				hackerdetector.ToggleButton();
				hackerdetector.ToggleButton();
			end;
		end
	});

	hackerdetectorthreads.oncleanevent:Connect(function(threads: table)
		for i: number, v: thread in threads do 
			pcall(task.cancel, threads);
		end;
		table.clear(threads)
	end);

	hackerdetectorconnections.oncleanevent:Connect(function(connections: table)
		for i: number, v: RBXScriptConnection in connections do 
			v:Disconnect();
		end;
		table.clear(connections);
	end);

	table.insert(renderconnections, task.spawn(function()
		repeat 
			pcall(function() cheaterdatabase = RenderLibrary.http:request({path = 'getcheaters'}).json().result end);
			task.wait(60)
		until (not getgenv().render)
	end));

end);

run(function()
	local antideath: vapemodule = {};
	local antideathmin: vapeslider = {Value = 50};
	local antideathtpheight: vapeslider = {Value = 8};
	local antideathmethod: vapedropdown = {Value = 'InfiniteFly'};
	local antideathtriggered: boolean = false;
	local antideathfuncs: table = {
		InfiniteFly = function()
			if not isEnabled('InfiniteFly') then 
				vape.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.ToggleButton()
			end;
		end,
		CFrame = function()
			lplr.Character.PrimaryPart.CFrame += Vector3.new(0, 100 * antideathtpheight.Value, 0)
		end,
		Bounce = function()
			lplr.Character.PrimaryPart.Velocity += Vector3.new(0, 100 * antideathtpheight.Value, 0)
		end
	};
	antideath = blatant.Api.CreateOptionsButton({
		Name = 'AntiDeath',
		HoverText = 'Automatically takes action when your health\nreaches threshold.',
		Function = function(calling: boolean)
			if calling then 
				table.insert(antideath.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damagedata: table)
					if lplr.Character and damagedata.entityInstance == lplr.Character and isAlive() then
						local comparison: number = lplr.Character:GetAttribute('MaxHealth') - lplr.Character:GetAttribute('Health');
						if comparison >= antideathmin.Value and isnetworkowner(lplr.Character.PrimaryPart) and not antideathtriggered then 
							InfoNotification('AntiDeath', 'Threshold reach, you\'ve been sent into the air.', 7);
							antideathtriggered = true;
							pcall(antideathfuncs[antideathmethod.Value])
						end;
						if comparison < antideathmin.Value then 
							antideathtriggered = false;
						end;
					end
				end))
			end
		end
	});
	antideathmin = antideath.CreateSlider({
		Name = 'Threshold',
		Min = 15,
		Max = 80,
		Default = 45,
		Function = void
	});
	antideathmethod = antideath.CreateDropdown({
		Name = 'Method',
		List = dumplist(antideathfuncs, nil, function(a: string, b: string) 
			return (a == 'InfiniteFly') 
		end),
		Function = function(value: boolean)
			antideathtpheight.Object.Visible = (value ~= 'InfiniteFly');
		end
	});
	antideathtpheight = antideath.CreateSlider({
		Name = 'Height',
		Min = 1,
		Max = 10,
		Default = 5,
		Function = void
	});
	antideathtpheight.Object.Visible = false;
end);

run(function()
	local funnyexploit: vapemodule = {};
	local funnyexploitconfetti: vapeminimodule = {};
	local funnyexploitdragon: vapeminimodule = {};
	local funnyexploitkillaura: vapeminimodule = {}; 
	local funnyexploitbeam: vapeminimodule = {};
	local funnyexploitdelay: vapeslider = {Value = 1};
	local funnyexploitbeamMethod: vapedropdown = {Value = 'Target'};
	local funnyexploitbeamX: vapeslider = {Value = 0};
	local funnyexploitbeamY: vapeslider = {Value = 0};
	local funnyexploitbeamZ: vapeslider = {Value = 0};
	local oldconfettisound: string = bedwars.SoundList.CONFETTI_POPPER;
	local funnyexploitThread: thread;
	funnyexploit = exploit.Api.CreateOptionsButton({
		Name = 'FunnyExploit',
		HoverText = 'Plays effects on the serverside to annoy players.',
		Function = function(calling: boolean)
			if calling then 
				funnyexploitThread = task.spawn(function()
					if renderperformance.reducelag then 
						return
					end;
					repeat 
						task.wait();
						if render.ping > 500 then 
							continue 
						end;
						if funnyexploitkillaura.Enabled and not vapeTargetInfo.Targets.Killaura then 
							continue
						end;
						if funnyexploitconfetti.Enabled and bedwars.AbilityController:canUseAbility('PARTY_POPPER') then 
							bedwars.AbilityController:useAbility('PARTY_POPPER');
						end;
						if funnyexploitdragon.Enabled then 
							bedwars.Client:Get('DragonBreath'):SendToServer({player = lplr})
						end;
						local sentAt: number = tick();
						local delay: number = funnyexploitdelay.Value;
						repeat task.wait() until (vapeTargetInfo.Targets.Killaura and funnyexploitkillaura.Enabled or delay ~= funnyexploitdelay.Value or (tick() - sentAt) >= (0.1 * funnyexploitdelay.Value))
					until (not funnyexploit.Enabled)
				end)
			else
				pcall(task.cancel, funnyexploitThread);
				bedwars.SoundList.CONFETTI_POPPER = oldconfettisound;
			end
		end
	});
	funnyexploitdelay = funnyexploit.CreateSlider({
		Name = 'Delay',
		Min = 0,
		Max = 30,
		Default = 3,
		Function = void
	});
	funnyexploitconfetti = funnyexploit.CreateToggle({
		Name = 'Confetti',
		Default = true,
		Function = void
	});
	funnyexploitdragon = funnyexploit.CreateToggle({
		Name = 'Dragon Breathe',
		Default = true,
		Function = void
	});
	funnyexploitkillaura = funnyexploit.CreateToggle({
		Name = 'Killaura Check',
		HoverText = 'Only runs if killaura is attacking.',
		Function = void
	});
	funnyexploit.CreateToggle({
		Name = 'Silent Confetti',
		HoverText = 'Disables the confetti\'s sound.',
		Function = function(calling: boolean)
			if funnyexploit.Enabled then 
				bedwars.SoundList.CONFETTI_POPPER = calling and '' or oldconfettisound;
			end;
		end
	});
end);

run(function()
	local viewmodelvisuals: vapemodule = {};
	local viewmodelvisualscolor: vapecolorslider = newcolor();
	local viewmodelvisualstweendelay: vapeslider = {Value = 3};
	local viewmodelvisualsSecondColor: vapecolorslider = newcolor();
	local viewmodelsecondcolortoggle: vapeminimodule = {};
	local viewmodelhighlightstroke: vapeminimodule = {};
	local viewmodelhighlightstrokecolor: vapecolorslider = newcolor();
	local viewmodelcolortype: vapedropdown = {Value = 'Highlight'};
	local viewmodelhighlightinvis: vapeslider = {Value = 0};
	local oldviewmodeldata;
	local viewmodeltweens: securetable = Performance.new();
	local viewmodelhighlightThreads: securetable = Performance.new();
	local viewmodelfuncs: table = { 
		None = void,
		Highlight = function(tool: Accessory)
			local highlight: Highlight = tool:FindFirstChildOfClass('Highlight') or Instance.new('Highlight', tool);
			highlight.Adornee = tool;
			highlight.FillColor = Color3.fromHSV(viewmodelvisualscolor.Hue, viewmodelvisualscolor.Sat, viewmodelvisualscolor.Value);
			highlight.FillTransparency = 0.1 * viewmodelhighlightinvis.Value;
			highlight.OutlineTransparency = viewmodelhighlightstroke.Enabled and 0 or 1;
			highlight.OutlineColor = Color3.fromHSV(viewmodelhighlightstrokecolor.Hue, viewmodelhighlightstrokecolor.Sat, viewmodelhighlightstrokecolor.Value);
			pcall(task.cancel, viewmodelhighlightThreads[highlight]);
			oldviewmodeldata = {tool = tool};
			viewmodelhighlightThreads[highlight] = task.spawn(function()
				repeat
					if not viewmodelsecondcolortoggle.Enabled then 
						break 
					end;
					local colors: table = {
						[1] = Color3.fromHSV(viewmodelvisualscolor.Hue, viewmodelvisualscolor.Sat, viewmodelvisualscolor.Value),
						[2] = Color3.fromHSV(viewmodelvisualsSecondColor.Hue, viewmodelvisualsSecondColor.Sat, viewmodelvisualsSecondColor.Value)
					};
					for i: number, v: Color3 in colors do 
						local colortween: Tween = tween:Create(highlight, TweenInfo.new(viewmodelvisualstweendelay.Value), {FillColor = v});
						colortween:Play();
						viewmodeltweens[highlight] = colortween;
						colortween.Completed:Wait();
						viewmodeltweens[highlight] = colortween;
						task.wait(0.15);
					end;
				until (not viewmodelvisuals.Enabled)
			end)
		end,
		Normal = function(tool: Accessory)
			local handle: Part = tool:WaitForChild('Handle', math.huge);
			handle.Color = Color3.fromHSV(viewmodelvisualscolor.Hue, viewmodelvisualscolor.Sat, viewmodelvisualscolor.Value);
			oldviewmodeldata = {oldtexture = handle.TextureID, tool = tool};
			handle.TextureID = '';
			pcall(task.cancel, viewmodelhighlightThreads[handle]);
			viewmodelhighlightThreads[handle] = task.spawn(function()
				repeat
					if not viewmodelsecondcolortoggle.Enabled then 
						break 
					end;
					local colors: table = {
						[1] = Color3.fromHSV(viewmodelvisualscolor.Hue, viewmodelvisualscolor.Sat, viewmodelvisualscolor.Value),
						[2] = Color3.fromHSV(viewmodelvisualsSecondColor.Hue, viewmodelvisualsSecondColor.Sat, viewmodelvisualsSecondColor.Value)
					};
					for i: number, v: Color3 in colors do 
						local colortween: Tween = tween:Create(handle, TweenInfo.new(viewmodelvisualstweendelay.Value), {Color = v});
						colortween:Play();
						viewmodeltweens[handle] = colortween;
						colortween.Completed:Wait();
						viewmodeltweens[handle] = nil;
						task.wait(0.15);
					end;
				until (not viewmodelvisuals.Enabled)
			end)
		end
	};
	viewmodelvisuals = visual.Api.CreateOptionsButton({
		Name = 'ViewmodelVisuals',
		HoverText = 'Customize your first person item.',
		Function = function(calling: boolean)
			if calling then 
				local viewmodel: Model = camera:WaitForChild('Viewmodel', 9e9);
				local currentTool: Accessory = viewmodel:GetChildren()[1];
				if currentTool then 
					task.spawn(pcall, viewmodelfuncs[viewmodelcolortype.Value], currentTool);
				end;
				table.insert(viewmodelvisuals.Connections, viewmodel.ChildAdded:Connect(function(object: Accessory?)
					if object.ClassName == 'Accessory' then 
						viewmodelfuncs[viewmodelcolortype.Value](object)
					end
				end))
			else
				viewmodeltweens:clear(function(tween: Tween) tween:Cancel() end);
				pcall(function() oldviewmodeldata.tool.TextureID = oldviewmodeldata.oldtexture end);
				pcall(function() oldviewmodeldata.tool:FindFirstChildOfClass('Highlight'):Destroy() end);
				oldviewmodeldata = nil;
			end
		end
	});
	viewmodelcolortype = viewmodelvisuals.CreateDropdown({
		Name = 'Color Type',
		List = dumplist(viewmodelfuncs, nil, function(a: string, b: string) return a == 'None' end),
		Function = function(value: string)
			viewmodelvisualscolor.Object.Visible = (value ~= 'None');
			viewmodelsecondcolortoggle.Object.Visible = (value ~= 'None');
			viewmodelhighlightinvis.Object.Visible = (value == 'Highlight');
			viewmodelhighlightstroke.Object.Visible = (value ~= 'None');
			viewmodelvisualsSecondColor.Object.Visible = (value ~= 'None' and viewmodelsecondcolortoggle.Enabled);
			viewmodelhighlightstrokecolor.Object.Visible = (value == 'Highlight' and viewmodelhighlightstroke.Enabled);
			pcall(function() viewmodelfuncs[value](camera.Viewmodel:FindFirstChildOfClass('Accessory') or error()) end);
		end
	});
	viewmodelvisualscolor = viewmodelvisuals.CreateColorSlider({
		Name = 'Color',
		Function = function()
			pcall(function()
				if oldviewmodeldata.oldtexture then 
					oldviewmodeldata.tool.Handle.Color = Color3.fromHSV(viewmodelvisualscolor.Hue, viewmodelvisualscolor.Sat, viewmodelvisualscolor.Value)
				end;
				oldviewmodeldata.tool:FindFirstChildOfClass('Highlight').FillColor = Color3.fromHSV(viewmodelvisualscolor.Hue, viewmodelvisualscolor.Sat, viewmodelvisualscolor.Value)
			end)
		end
	});
	viewmodelsecondcolortoggle = viewmodelvisuals.CreateToggle({
		Name = 'Secondary Color',
		Function = function(calling: boolean)
			if viewmodelvisuals.Enabled then 
				viewmodelvisuals.ToggleButton();
				viewmodelvisuals.ToggleButton();
			end
		end
	});
	viewmodelvisualsSecondColor = viewmodelvisuals.CreateColorSlider({
		Name = 'Color 2',
		Function = void
	});
	viewmodelhighlightinvis = viewmodelvisuals.CreateSlider({
		Name = 'Transparency',
		Min = 0,
		Max = 10,
		Default = 2,
		Function = function(value: number)
			pcall(function()
				oldviewmodeldata.tool:FindFirstChildOfClass('Highlight').Transparency = 0.1 * value;
			end)
		end
	});
	viewmodelhighlightstroke = viewmodelvisuals.CreateToggle({
		Name = 'Stroke',
		Function = void
	});
	viewmodelhighlightstrokecolor = viewmodelvisuals.CreateColorSlider({
		Name = 'Stroke Color',
		Function = function()
			pcall(function()
				oldviewmodeldata.tool:FindFirstChildOfClass('Highlight').FillColor = Color3.fromHSV(viewmodelhighlightstrokecolor.Hue, viewmodelhighlightstrokecolor.Sat, viewmodelhighlightstrokecolor.Value)
			end)
		end
	});

	viewmodelhighlightThreads.oncleanevent:Connect(task.cancel);
end);

run(function()
	local autorewind: vapemodule = {};
	local autorewindteleportmode: vapedropdown = {Value = 'Block'};
	local autorewindautospeed: vapeminimodule = {};
	local autorewindspeed: vapeslider = {Value = 4.9};	
	local lastposition: Vector3 = nil;
	local istweening: boolean = false;
	autorewind = utility.Api.CreateOptionsButton({
		Name = 'AutoRewind',
		HoverText = 'Automatically teleports you back on death.',
		Function = function(calling: boolean)
			if calling then 
				table.insert(autorewind.Connections, runservice.Heartbeat:Connect(function()
					local block: RaycastParams = workspace:Raycast(entityLibrary.LocalPosition, Vector3.new(0, -1e4, 0), store.blockRacyast);
					if block and workspace:Raycast(block.Position, Vector3.new(0, -5, 0), store.blockRaycast) and not istweening then 
						lastposition = block.Position
					end;
				end));
				table.insert(autorewind.Connections, lplr.CharacterAdded:Connect(function(character: Model)
					if not lastposition then return end;
					istweening = true;
					repeat task.wait() until isAlive(lplr, true);
					task.wait(0.08);
					local pos: Vector3 = character.PrimaryPart.Position;
					if autorewindteleportmode.Value == 'Target' then 
						local target: rendertarget = GetTarget();
						if target.RootPart then 
							lastposition = target.RootPart.Position;
						end;
					end;
					local tweenspeed: number = (autorewindautospeed.Enabled and (((pos - lastposition).Magnitude / 1e3)) or (0.1 * autorewindspeed.Value))
					local rewindtween: Tween = tween:Create(lplr.Character.PrimaryPart, TweenInfo.new(tweenspeed), {Position = lastposition});
					lastposition = nil;
					rewindtween:Play();
					rewindtween.Completed:Wait();
					istweening = false;
				end))
			end
		end
	});
	autorewindteleportmode = autorewind.CreateDropdown({
		Name = 'Teleport Method',
		List = {'Block', 'Target'},
		Function = void
	});
	autorewindautospeed = autorewind.CreateToggle({
		Name = 'Auto Speed',
		Function = function(calling: boolean)
			autorewindspeed.Object.Visible = (not calling);
		end
	});
	autorewindspeed = autorewind.CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 6,
		Default = 4,
		Function = void
	})
end);

run(function()
	local queuecardvisuals: vapemodule = {};
	local queucardvisualsgradientoption: vapemodule = {};
	local queuecardvisualhighlight: vapeminimodule = {};
	local queuecardmodshighlightcolor: vapecolorslider = newcolor();
	local queuecardvisualscolor: vapecolorslider = newcolor();
	local queuecardvisualscolor2: vapecolorslider = newcolor();
	local queuecardobjects: securetable = Performance.new();
	local queuecardvisualsround: vapeslider = {Value = 4};
	local queuecardfunc: () -> () = function()
		if not lplr.PlayerGui:FindFirstChild('QueueApp') then return end;
		if not queuecardvisuals.Enabled then return end;
		local card: Frame = lplr.PlayerGui.QueueApp:WaitForChild('1', math.huge);
		local cardcorner: UICorner = card:FindFirstChildOfClass('UICorner') or Instance.new('UICorner', card);
		card.BackgroundColor3 = Color3.fromHSV(queuecardvisualscolor.Hue, queuecardvisualscolor.Sat, queuecardvisualscolor.Value);
		cardcorner.CornerRadius = queuecardvisualsround.Value;
		if table.find(queuecardobjects, cardcorner) == nil then 
			table.insert(queuecardobjects, cardcorner);
		end;
		if queucardvisualsgradientoption.Enabled then 
			card.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			local gradient = card:FindFirstChildWhichIsA('UIGradient') or Instance.new('UIGradient', card);
			gradient.Color = ColorSequence.new({
				[1] = ColorSequenceKeypoint.new(0, Color3.fromHSV(queuecardvisualscolor.Hue, queuecardvisualscolor.Sat, queuecardvisualscolor.Value)), 
				[2] = ColorSequenceKeypoint.new(1, Color3.fromHSV(queuecardvisualscolor2.Hue, queuecardvisualscolor2.Sat, queuecardvisualscolor2.Value))
			});
			if table.find(queuecardobjects, gradient) == nil then
				table.insert(queuecardobjects, gradient);
			end;
		end;
		if queuecardvisualhighlight.Enabled then 
			local highlight: UIStroke? = card:FindFirstChildOfClass('UIStroke') or Instance.new('UIStroke', card);
			highlight.Thickness = 1.7;
			highlight.Color = Color3.fromHSV(queuecardmodshighlightcolor.Hue, queuecardmodshighlightcolor.Sat, queuecardmodshighlightcolor.Value);
			if table.find(queuecardobjects, highlight) == nil then
				table.insert(queuecardobjects, highlight);
			end;
		else
			pcall(function() card:FindFirstChildOfClass('UIStroke'):Destroy() end)
		end;
	end;
	queuecardvisuals = visual.Api.CreateOptionsButton({
		Name = 'QueueCardVisuals',
		Function = function(calling: boolean)
			if calling then 
				pcall(queuecardfunc);
				table.insert(queuecardvisuals.Connections, lplr.PlayerGui.ChildAdded:Connect(queuecardfunc));
			else
				queuecardobjects:clear(game.Destroy)
			end
		end
	});
	queucardvisualsgradientoption = queuecardvisuals.CreateToggle({
		Name = 'Gradient',
		Function = function(calling)
			pcall(function() queuecardvisualscolor2.Object.Visible = calling end) 
		end
	});
	queuecardvisualsround = queuecardvisuals.CreateSlider({
		Name = 'Rounding',
		Min = 0,
		Max = 20,
		Default = 4,
		Function = function(value: number): ()
			for i: number, v: UICorner? in queuecardobjects do 
				if v.ClassName == 'UICorner' then 
					v.CornerRadius = value;
				end;
			end
		end
	})
	queuecardvisualscolor = queuecardvisuals.CreateColorSlider({
		Name = 'Color',
		Function = function()
			task.spawn(pcall, queuecardfunc)
		end
	});
	queuecardvisualscolor2 = queuecardvisuals.CreateColorSlider({
		Name = 'Color 2',
		Function = function()
			task.spawn(pcall, queuecardfunc)
		end
	});
	queuecardvisualhighlight = queuecardvisuals.CreateToggle({
		Name = 'Highlight',
		Function = function()
			task.spawn(pcall, queuecardfunc)
		end
	});
	queuecardmodshighlightcolor = queuecardvisuals.CreateColorSlider({
		Name = 'Highlight Color',
		Function = function()
			task.spawn(pcall, queuecardfunc)
		end;
	});
end);

--[[run(function()
	local spawnscythe: vapemodule = {};
	local spawnscythethread: thread;
	local getshopnpc = function(): Part?
		local closest: number, target: Part = math.huge, nil;
		for i: number, v: Part in collection:GetTagged('BedwarsItemShop') do
			local distance = (lplr.Character.PrimaryPart.Position - v.Position).Magnitude;
			if distance < closest then 
				closest = distance;
				target = v;
			end;
		end;
		return target;
	end;
	local getscytheshopitem = function(): (invitemobject?)
		if cheatenginetrash then
			return `2_item_shop_{Random.new():NextInteger(1, 4)}`;
		end;
		local bestscythe: invitemobject, bestcurrency: number = nil, 0;
		for i: number, v: invitemobject in bedwars.ShopItems do 
			if v.itemType:find('_scythe') then
				local item: invitemobject? = getItem(v.currency);
				if item and item.amount > bestcurrency then 
					bestcurrency = item.amount;
					bestscythe = v;
				end
			end;
		end;
		return bestscythe;
	end;
	spawnscythe = exploit.Api.CreateOptionsButton({
		Name = 'AutoScythe',
		HoverText = 'Automatically spawns the scythe.',
		Function = function(calling: boolean): ()
			if calling then 
				spawnscythethread = task.spawn(function()
					repeat task.wait() until store.matchState ~= 0;
					repeat
						local scythe, shopitem: invitemobject? = getItemNear('_scythe'), getscytheshopitem();
						if isAlive(lplr, true) and shopitem and not scythe and store.queueType then 
							local npc: Part? = getshopnpc();
							bedwars.Client:Get('BedwarsPurchaseItem'):CallServer({
								shopItem = shopitem,
								shopId = npc and npc.Name or '2_item_shop_1'
							})
						end
					    task.wait()
				    until (not spawnscythe.Enabled)
				end)
			else
				pcall(task.cancel, spawnscythethread)
			end
		end
	});	
end);]]

run(function()
    local desync: vapemodule = {};
	local desyncvisual: vapeminimodule = {};
	local desyncvisualcolor: vapecolorslider = newcolor();
    local desyncdelay: vapeslider = {Value = 1};
	local desyncupvelo: vapeslider = {Value = 1};
	local desynctweendelay: vapeslider = {Value = 0};
    local desyncspeedonly: vapeminimodule = {};
    local desyncmaxheartbeat: vapeslider = {Value = 1e4};
	local desyncpulseslowdown: vapeslider = {Value = 7.5};
    local lastTeleport: number = tick();
    local newroot: BasePart = {};
    local oldroot: BasePart = {};
    local oldconstructor: (RemoteFunction, ...any) -> (...any);
	local projectileremote: {instance: RemoteFunction, CallServerAsync: (table, ...any) -> (...any)} = bedwars.Client:Get(bedwars.ProjectileRemote);
	local lastTelepearlHitPos: table = {};
	local lastTelepearlHitIDS: table = {};
	local oldtween: Tween;
	local desyncpulses: number = 0;
    local desyncthread: thread;
	local desyncmotiontick: number = tick();
    local createclone = function(): ()
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
                        if store.matchState == 0 then 
                            task.wait(0.25);
                            continue;
                        end;
                        if isAlive(lplr, true) then
                            oldroot.Velocity = Vector3.zero;
							oldroot.Transparency = desyncvisual.Enabled and 0.5 or 1;
							oldroot.Color = Color3.fromHSV(desyncvisualcolor.Hue, desyncvisualcolor.Sat, desyncvisualcolor.Value);
                            if newroot.Parent ~= lplr.Character then 
                                lastTeleport = tick();
                                createclone();
                            end;
                            local lastTeleportSeconds: number = tick() - lastTeleport;
							if desyncpulses > desyncmaxheartbeat.Value and workspace:Raycast(oldroot.Position, Vector3.new(0, 1, 0), store.blockRaycast) == nil and (getSpeed() > 0 or not desyncspeedonly.Enabled) then 
								task.wait(0.1 * desyncpulseslowdown.Value);
								desyncpulses = 0;
							end;
							if store.scythe > tick() and lplr:GetAttribute('ScytheSpinning') then 
								desyncmotiontick = tick() + 0.2;
							end;
							if store.scythe > tick() and tick() > desyncmotiontick then 
								continue;
							end;
                            if lastTeleportSeconds >= (0.1 * desyncdelay.Value) or desyncspeedonly.Enabled and getSpeed() <= 0 or store.lastdamage > tick() or not isnetworkowner(oldroot) and task.wait() then 
                                lastTeleport = tick();
								oldtween = tween:Create(oldroot, TweenInfo.new(desyncspeedonly.Enabled and getSpeed() <= 0 and 0.01 or 0.1 * desynctweendelay.Value, Enum.EasingStyle.Linear), {CFrame = (newroot.CFrame + Vector3.new(0, desyncupvelo.Value, 0))});
								oldtween:Play();
								oldtween.Completed:Wait();
								desyncpulses += 1;
                            end
                        end
                    until (not desync.Enabled)
                end);

                table.insert(desync.Connections, lplr:GetAttributeChangedSignal('LastTeleported'):Connect(function()
                    newroot.CFrame = oldroot.CFrame;
                end));
            else 
				desyncpulses = 0;
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
    desyncspeedonly = desync.CreateToggle({
        Name = 'Boost Only',
        HoverText = 'Only runs when an active speed boost method\nin avaliable.',
        Default = true,
        Function = void
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
	desyncmaxheartbeat = desync.CreateSlider({
		Name = 'Max Pulses',
		Min = 15,
		Max = 100,
		Default = math.huge,
		Function = void
	});
	desyncpulseslowdown = desync.CreateSlider({
		Name = 'Pulse Cooldown Speed',
		Min = 1,
		Max = 15,
		Default = 7.5,
		Function = void
	});
	desyncupvelo = desync.CreateSlider({
		Name = 'Velocity',
		Min = 0,
		Max = 3,
		Function = void
	});

	table.insert(renderconnections, task.spawn(function()
		repeat
			if desync.Enabled and render.clone.old and not isnetworkowner(render.clone.old) then 
				warningNotification('Desync', 'Network ownership disowned, slowing down speed for possibly 8 seconds.', 9);
				render.clone.new.CFrame = render.clone.old.CFrame;
				repeat task.wait() until (render.clone.old == nil or isnetworkowner(render.clone.old) or not desync.Enabled);
			end;
			task.wait();
		until false;
	end));
	
	desyncvisualcolor.Object.Visible = false;
end);

run(function()
	utility.Api.CreateOptionsButton({
		Name = 'DamageBoost',
		HoverText = 'Increases Speed/Fly speed on damage.',
		Function = void
	});
end);
