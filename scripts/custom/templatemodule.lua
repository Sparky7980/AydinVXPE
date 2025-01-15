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
   This is a template for a custom render module.             
   https://renderintents.lol                                                                                                                                                                                                                                                                     
]]

type vapemain = {
    ObjectsThatCanBeSaved: table,
    objects: table
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

local gui: vapemain = shared.rendervape;
local render: table = render or warn('❌ Failed to fetch the render main table.') or {};

for i: (any), v: (...any) -> (...any) in render.utils do --> sideloads all render global utility functions from libraries/utils.lua
    getfenv()[i] = v;
end;

--> defining mostly used (by most people) variables

local vape: vapemain = gui;
local GuiLibrary: vapemain = gui;
local runFunction: (() -> (any)) -> () = run;
local runcode: (() -> (any)) -> () = run;
local store: table = getgenv().bedwarsStore;
local bedwars: table = getgenv().bedwars;
local bedwarsStore: table = store;

--> my favorite variables

local cloneref = cloneref or function(data) return data end;
local getservice = function(service)
	return cloneref(game:FindService(service))
end;

local players: Players = getservice('Players');
local textservice: TextService = getservice('TextService');
local lighting: Lighting = getservice('Lighting');
local textchat: TextChatService = getservice('TextChatService');
local inputservice: UserInputService = getservice('UserInputService');
local runservice: RunService = getservice('RunService');
local teleport: TeleportService = getservice('TeleportService');
local tween: TweenService = getservice('TweenService');
local collection: CollectionService = getservice('CollectionService');
local httpservice: HttpService = getservice('HttpService');
local replicatedstorage: ReplicatedStorage = getservice('ReplicatedStorage');
local fakecam: Camera = Instance.new('Camera');
local camera: Camera? = workspace.CurrentCamera;
local lplr: Player = players.LocalPlayer;
local vapeConnections: table = {};
local vapeCachedAssets: table = {};
local vapeEvents: table = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new('BindableEvent')
		return self[index]
	end
});
local vapeTargetInfo: table = shared.VapeTargetInfo;
local vapeInjected: boolean = true;

--> normal vape service variable

local playersService: Players = players;
local textService: TextService = textservice;
local lightingService: Lighting = lighting;
local textChatService: TextChatService = textchat;
local inputService: UserInputService = inputservice;
local runService: RunService = runservice;
local tweenService: TweenService = tween;
local collectionService: CollectionService = collection;
local replicatedStorage: ReplicatedStorage = replicatedstorage;
local gameCamera = camera;