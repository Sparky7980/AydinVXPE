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
   lib/loadui.lua - (SystemXVoid/BlankedVoid & Outer)           
   https://renderintents.xyz                                                                                                                                                                                                                                                                     
]]

local cloneref = cloneref or function(ref: userdata) return ref end;
local guiconnections = {};
local getservice = function(service: string)
    return cloneref(game:FindService(service))
end;
local creategradient = function(pos, color, pos2, color2)
    return ColorSequence.new({ColorSequenceKeypoint.new(pos, color), ColorSequenceKeypoint.new(pos2, color2)})
end;
local loaderapi = setmetatable({}, {
    __tostring = function()
        return 'Render Loader API'
    end
});

local tween = getservice('TweenService');
local httpservice = getservice('HttpService');
local runservice = getservice('RunService');
local lplr = getservice('Players').LocalPlayer;
local loaded = tick();

local gui = Instance.new('ScreenGui');
gui.Name = httpservice:GenerateGUID(false):gsub('-', '');
loaderapi.instance = gui;
xpcall(function() gui.Parent = gethui and gethui() or getservice('CoreGui') end, function() gui.Parent = lplr.PlayerGui end);

guiconnections[1] = gui.DescendantAdded:Connect(function(object: Instance)
    object.Name = httpservice:GenerateGUID(false):gsub('-', '');
end);   

gui.Destroying:Once(function()
    for i,v in guiconnections do 
        pcall(v.Disconnect, v)
    end
end);

local mainframe = Instance.new('Frame', gui);
mainframe.Size = UDim2.new(0, 559, 0, 291);
mainframe.Position = UDim2.new(0.5, 0, 1.01999998, 0);
mainframe.BackgroundColor3 = Color3.fromRGB(34, 13, 103);
mainframe.Transparency = 0.5;

local barbackground = Instance.new('Frame', mainframe);
barbackground.Size = UDim2.new(0, 478, 0, 11);
barbackground.Position = UDim2.new(0.088, 0, 0.481, 0);
barbackground.BackgroundColor3 = Color3.fromRGB(255, 255, 255);

local barmain = barbackground:Clone();
barmain.Parent = barbackground;
barmain.Size = UDim2.new(0, 0, 0, 11);
barmain.Position = UDim2.new(-0.002, 0, 0, 0);

local shadowbox = Instance.new('ImageLabel', mainframe);
shadowbox.Size = UDim2.new(1.004, 47, 1.01, 47);
shadowbox.Position = UDim2.new(0.504, 0, 0.502, 0);
shadowbox.ImageColor3 = Color3.fromRGB(255, 255, 255);
shadowbox.AnchorPoint = Vector2.new(0.5, 0.5);
shadowbox.ImageTransparency = 0.23;
shadowbox.ScaleType = Enum.ScaleType.Slice;
shadowbox.SliceCenter = Rect.new(49, 49, 450, 450);
shadowbox.BackgroundTransparency = 1;
shadowbox.Image = 'rbxassetid://6015897843';

local renderlogo = Instance.new('ImageLabel', mainframe);
renderlogo.Size = UDim2.new(0, 81, 0, 75);
renderlogo.Position = UDim2.new(0.438, 0, 0.072, 0);
renderlogo.Image = 'rbxassetid://18488550582';
renderlogo.BackgroundTransparency = 1;
renderlogo.ImageColor3 = Color3.fromRGB(105, 67, 255);

local statustext = Instance.new('TextLabel', mainframe);
statustext.Size = UDim2.new(0, 463, 0, 23);
statustext.Position = UDim2.new(0.086, 0, 0.351, 0);
statustext.TextColor3 = Color3.fromRGB(255, 255, 255);
statustext.BackgroundTransparency = 1;
statustext.FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold);
statustext.TextSize = 18;
statustext.Text = '';

local etatext = statustext:Clone();
etatext.Text = 'ETA: 0';
etatext.Parent = mainframe;
etatext.Size = UDim2.new(0, 463, 0, 50);
etatext.Position = UDim2.new(0.086, 0, 0.533, 0);

local infotext = etatext:Clone();
infotext.TextSize = 16;
infotext.Parent = mainframe;
infotext.Size = UDim2.new(0, 463, 0, 23);
infotext.Position = UDim2.new(0.1, 0, 0.68, 0);
infotext.Text = '';

function loaderapi:setprogress(min: number, max: number?, step: string?, info: string?)
    tween:Create(barmain, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, math.max(478 / ((max or min) / min)), 0, 11)}):Play();
    if step then 
        statustext.Text = tostring(step);
    end;
    if info then 
        infotext.Text = tostring(info);
    end;
end;

function loaderapi:init()
    tween:Create(mainframe, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
end;

guiconnections[2] = runservice.Heartbeat:Connect(function()
    etatext.Text = `ETA: {math.floor(tick() - loaded)}`
end)

Instance.new('UIGradient', barbackground).Color = creategradient(0, Color3.fromRGB(33, 3, 71), 1, Color3.fromRGB(19, 2, 106));
Instance.new('UIGradient', shadowbox).Color = creategradient(0, Color3.fromRGB(121, 12, 255), 1, Color3.fromRGB(47, 5, 255));
Instance.new('UIGradient', barmain).Color = creategradient(0, Color3.fromRGB(80, 5, 184), 1, Color3.fromRGB(86, 2, 255));
Instance.new('UIAspectRatioConstraint', mainframe).AspectRatio = 1.921;
Instance.new('UICorner', mainframe);
Instance.new('UICorner', shadowbox);
Instance.new('UICorner', barmain).CornerRadius = UDim.new(0, 30);
Instance.new('UICorner', barbackground).CornerRadius = UDim.new(0, 30);

return loaderapi;