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
   /libraries/kickscreen.lua - SystemXVoid/BlankedVoid and Maxlasertech            
   https://renderintents.lol                                                                                                                                                                                                                                                                     
]]
   
type kickscreenapi = {
    instance: (Frame)?,
    activate: () -> ()
};

local cloneref: (Instance) -> (Instance) = cloneref or function(instance: Instance) return instance end;
local activated: boolean = false;
local runservice: RunService = cloneref(game:FindService('RunService'));
local coregui: CoreGui = cloneref(game:FindService('CoreGui'));
local players: Players = cloneref(game:FindService('Players'));
local teleport: TeleportService = cloneref(game:FindService('TeleportService'));
local lplr: Player = players.LocalPlayer;
local api: kickscreenapi; api = setmetatable({}, {
    __tostring = function() 
        return 'Render Kickscreen API'
    end
});

function api:activate(message: string?, customreason: string?): ()
    for i: number, v: ScreenGui? in lplr:FindFirstChildOfClass('PlayerGui'):GetChildren() do 
        if v.ClassName == 'ScreenGui' then 
            v.Enabled = false;
        end;
    end;
    for i: number, v: ScreenGui? in players:GetPlayers() do 
        if v ~= lplr then 
            v:Destroy();
        end;
    end;

    pcall(function()
        coregui.RobloxPromptGui.Parent = nil;
        runservice:SetRobloxGuiFocused(false)
    end);
    
    api.instance.Parent = Instance.new('ScreenGui', coregui);
    api.instance.Parent.IgnoreGuiInset = true;
    local message: string = (message and tostring(message) or 'client kicked'):lower();
    if customreason then 
        api.instance.reason.Text = customreason;
        api.instance.errorcode.Text = 'Error Code: 0';
    end;
    if message:find('idle') then 
        api.instance.icon.Image = 'http://www.roblox.com/asset/?id=128158617618937';
        api.instance.title.Text = `You've been <font color="rgb(0, 0, 255)"><b>Disconnected</b></font>`;
        api.instance.reason.Text = 'This kick was triggered due to you being idle for too long (pass 20 minutes).';
        api.instance.errorcode.Text = 'Error Code: 3';
    end;
    if message:find('banned') and not customreason then 
        api.instance.reason.Text = `A game moderator has banned you for exploiting.`;
        api.instance.title.Text = `     You've been <font color="rgb(255, 0, 0)"><b>Banned</b></font>          `;
        api.instance.buttons.rejoin:Destroy();
        if message:find('anti') or message:find('adonis') then
            api.instance.reason.Text = 'This kick may have been triggered by an automated anticheat system. (report to the discord if so)';
        end;
        api.instance.errorcode.Text = 'Error Code: 2';
    end;
    if message:find('internet') and customreason then 
        api.instance.icon.Image = 'http://www.roblox.com/asset/?id=93681699189510';
        api.instance.title.Text = `You've been <font color="rgb(0, 0, 255)"><b>Disconnected</b></font>`;
        api.instance.reason.Text = 'This could happen if your connection is unstable/gone, please check ur internet connection and rejoin.';
        api.instance.errorcode.Text = 'Error Code: 1';
    end;
    
end;

local kickscreenframe: Frame = Instance.new('Frame');
local kickscreenbuttonholder: Frame = Instance.new('Frame', kickscreenframe);
local kickscreenbuttonlayout: UIListLayout = Instance.new('UIListLayout', kickscreenbuttonholder);
local kickscreenrendericon: ImageLabel = Instance.new('ImageLabel', kickscreenframe);
local kickscreenicon: ImageLabel = Instance.new('ImageLabel', kickscreenframe);
local kickscreentitle: TextLabel = Instance.new('TextLabel', kickscreenframe);
local kickscreenerrorcode: TextLabel = Instance.new('TextLabel', kickscreenframe);
local kickscreenexitbutton: TextButton = Instance.new('TextButton', kickscreenbuttonholder);
local kickscreenrejoinbutton: TextButton;
local kickscreenreason: TextLabel;

kickscreenframe.Name = 'main';
kickscreenframe.Size = UDim2.new(1, 0, 1, 0);
kickscreenframe.BackgroundColor3 = Color3.new();

kickscreenicon.Name = 'icon';
kickscreenicon.BackgroundTransparency = 1;
kickscreenicon.Size = UDim2.new(0, 131, 0, 121);
kickscreenicon.Position = UDim2.new(0.440, 0, 0.19, 0);
kickscreenicon.Image = 'http://www.roblox.com/asset/?id=107268824649487';

kickscreentitle.Name = 'title';
kickscreentitle.BackgroundTransparency = 1;
kickscreentitle.Position = UDim2.new(0.242, 0, 0.315, 0);
kickscreentitle.Size = UDim2.new(0.493, 0, 0.063, 0);
kickscreentitle.FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Bold);
kickscreentitle.Text = `You've been kicked from the experience`;
kickscreentitle.TextColor3 = Color3.fromRGB(255, 255, 255);
kickscreentitle.TextSize = 35;
kickscreentitle.RichText = true;

kickscreenreason = kickscreentitle:Clone();
kickscreenreason.Name = 'reason';
kickscreenreason.FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Medium);
kickscreenreason.Position = UDim2.new(0.2, 0, 0.36, 0);
kickscreenreason.Size = UDim2.new(0.566, 0, 0.063, 0);
kickscreenreason.Text = `This may have been an automated game detection.`;
kickscreenreason.Parent = kickscreenframe;
kickscreenreason.TextSize = 20;

kickscreenerrorcode = kickscreenreason:Clone();
kickscreenerrorcode.Name = 'errorcode';
kickscreenerrorcode.Text = 'Error Code: 0';
kickscreenerrorcode.FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Medium);
kickscreenerrorcode.Size = UDim2.new(0, 124, 0, 28);
kickscreenerrorcode.Position = UDim2.new(0.45, 0, 0.418, 0);
kickscreenerrorcode.Parent = kickscreenframe;
kickscreenerrorcode.TextSize = 17;

kickscreenrendericon.BackgroundTransparency = 1;
kickscreenrendericon.Image = 'rbxassetid://16852575555';
kickscreenrendericon.Name = 'rendericon';
kickscreenrendericon.BackgroundTransparency = 1;
kickscreenrendericon.Size = UDim2.new(0, 45, 0, 45);
kickscreenrendericon.Position = UDim2.new(0.016, 0, 0.916, 0);

kickscreenbuttonholder.Name = 'buttons';
kickscreenbuttonholder.Size = UDim2.new(0.978, 0, 0.019, 0);
kickscreenbuttonholder.Position = UDim2.new(-0.004, 0, 0.5, 0);
kickscreenbuttonholder.BackgroundTransparency = 1;

kickscreenbuttonlayout.Padding = UDim.new(0, 15);
kickscreenbuttonlayout.FillDirection = Enum.FillDirection.Horizontal;
kickscreenbuttonlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;

kickscreenexitbutton.Name = 'exit';
kickscreenexitbutton.Size = UDim2.new(0, 194, 0, 42);
kickscreenexitbutton.BackgroundColor3 = Color3.fromRGB(254, 47, 50);
kickscreenexitbutton.TextColor3 = Color3.fromRGB(255, 255, 255);
kickscreenexitbutton.Font = Enum.Font.Ubuntu;
kickscreenexitbutton.Text = 'Leave';
kickscreenexitbutton.TextSize = 20;

kickscreenrejoinbutton = kickscreenexitbutton:Clone();
kickscreenrejoinbutton.Name = 'rejoin';
kickscreenrejoinbutton.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
kickscreenrejoinbutton.TextColor3 = Color3.new();
kickscreenrejoinbutton.Text = 'Rejoin';
kickscreenrejoinbutton.Parent = kickscreenbuttonholder;

kickscreenexitbutton.MouseButton1Click:Once(function()
    game:Shutdown();
end);

kickscreenrejoinbutton.MouseButton1Click:Once(function()
    teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, lplr);
end);

Instance.new('UIAspectRatioConstraint', kickscreenicon).AspectRatio = 1.083;
Instance.new('UICorner', kickscreenexitbutton);
Instance.new('UICorner', kickscreenrejoinbutton);

api.instance = kickscreenframe;
return api;