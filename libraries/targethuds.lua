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
   lib/targethuds.lua - SystemXVoid/BlankedVoid and Maxlasertech         
   https://renderintents.xyz                                                                                                                                                                                                                                                                     
]]

type RenderTarget = {
    Player: Player | nil,
    Humanoid: Humanoid | nil,
    RootPart: BasePart | nil,
    NPC: boolean | nil
};

local api: table = {};
local cloneref = cloneref or function(data: string) return data end;
local getservice = function(service: string): Instance
	return cloneref(game:FindService(service))
end;

local players: Players = getservice('Players');
local tween: TweenService = getservice('TweenService');
local lplr: Player = players.LocalPlayer;

local getsafehui = function(): PlayerGui | CoreGui 
    local core : CoreGui? = gethui and cloneref(gethui()) or getservice('CoreGui');
    if pcall(tostring, core) then 
        return core 
    end;
    return lplr:FindFirstChildOfClass('PlayerGui')
end;

local gui: ScreenGui = Instance.new('ScreenGui', getsafehui());
gui.Enabled = false;
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global;

--> RENDER HUD 2024

local hudframe: Frame = Instance.new('Frame', gui);
local hudshadow: Frame = Instance.new('Frame', hudframe);
local hudumbrashadow: ImageLabel = Instance.new('ImageLabel', hudframe);
local hudumbragradient: UIGradient = Instance.new('UIGradient', hudumbrashadow);
local hudgradient: UIGradient = Instance.new('UIGradient', hudframe);
local hudstroke: UIStroke = Instance.new('UIStroke', hudframe);
local hudpenumbrashadow: ImageLabel = Instance.new('ImageLabel', hudshadow);
local hudpenumbragradient: UIGradient = Instance.new('UIGradient', hudpenumbrashadow);
local hudstrokegradient: UIGradient = Instance.new('UIGradient', hudstroke);
local targethudprofile: Frame = Instance.new('Frame', hudframe);
local targethudprofilestroke: UIStroke = Instance.new('UIStroke', targethudprofile);
local targethudprofilegradient: UIGradient = Instance.new('UIGradient', targethudprofile);
local targethudprofilestrokegradient: UIGradient = Instance.new('UIGradient', targethudprofilestroke);
local targethudprofilepicture: ImageLabel = Instance.new('ImageLabel', targethudprofile);
local targethudhealthbar: Frame = Instance.new('Frame', hudframe);
local targethudhealthbar2: Frame = Instance.new('Frame', targethudhealthbar);
local targethudtextinfo: TextLabel = Instance.new('TextLabel', targethudhealthbar);
local targethudhealthinfo: TextLabel = Instance.new('TextLabel', targethudhealthbar);
local targethudstatusinfo: TextLabel = Instance.new('TextLabel', hudframe);

hudframe.Name = 'MainHUD';
hudframe.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
hudframe.BackgroundTransparency = 0.15;
hudframe.BorderColor3 = Color3.fromRGB(0, 0, 0);
hudframe.BorderSizePixel = 0;
hudframe.Position = UDim2.new(0.34, 1, 0.5, 1);
hudframe.Size = UDim2.new(0, 326, 0, 114);
hudgradient.Color = ColorSequence.new({
    [1] = ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 0, 182)), 
    [2] = ColorSequenceKeypoint.new(0.52, Color3.fromRGB(135, 0, 188)), 
    [3] = ColorSequenceKeypoint.new(1, Color3.fromRGB(95, 0, 121))
});
hudgradient.Rotation = 122;
hudshadow.BackgroundTransparency = 1;
hudshadow.Position = UDim2.new(0, -6, 0, -5);
hudshadow.Size = UDim2.new(0, 340, 0, 185);
hudshadow.ZIndex = 0;
hudumbrashadow.Name = 'Umbra';
hudumbrashadow.AnchorPoint = Vector2.new(0.5, 0.5)
hudumbrashadow.BackgroundTransparency = 1.000
hudumbrashadow.Position = UDim2.new(0, 164, 0, 64);
hudumbrashadow.Size = UDim2.new(0, 333, 0, 129);
hudumbrashadow.ZIndex = 0;
hudumbrashadow.Image = 'rbxassetid://1316045217';
hudumbrashadow.ImageTransparency = 0.860;
hudumbrashadow.ScaleType = Enum.ScaleType.Slice;
hudumbrashadow.SliceCenter = Rect.new(10, 10, 118, 118);
hudumbragradient.Color = ColorSequence.new({
    [1] = ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 0, 182)), 
    [2] = ColorSequenceKeypoint.new(0.52, Color3.fromRGB(135, 0, 188)), 
    [3] = ColorSequenceKeypoint.new(1, Color3.fromRGB(95, 0, 121))
});
hudumbragradient.Offset = Vector2.new(0, 2);
hudumbragradient.Rotation = 122;
hudpenumbrashadow.AnchorPoint = Vector2.new(0.5, 0.5);
hudpenumbrashadow.BackgroundTransparency = 1;
hudpenumbrashadow.Position = UDim2.new(0, 164, 0, 64);
hudpenumbrashadow.Size = UDim2.new(0, 333, 0, 129);
hudpenumbrashadow.ZIndex = 0;
hudpenumbrashadow.Image = 'rbxassetid://1316045217';
hudpenumbrashadow.ImageTransparency = 0.88;
hudpenumbrashadow.ScaleType = Enum.ScaleType.Slice;
hudpenumbrashadow.SliceCenter = Rect.new(10, 10, 118, 118);
hudpenumbragradient.Color = ColorSequence.new({
    [1] = ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 0, 182)), 
    [2] = ColorSequenceKeypoint.new(0.52, Color3.fromRGB(135, 0, 188)), 
    [3] = ColorSequenceKeypoint.new(1, Color3.fromRGB(95, 0, 121))
});
hudpenumbragradient.Offset = Vector2.new(0, 2);
hudpenumbragradient.Rotation = 122;
hudstroke.Name = 'MainStroke';
hudstroke.Color = Color3.fromRGB(213, 213, 213);
hudstroke.Transparency = 0.34;
hudstrokegradient.Rotation = 122;
hudstrokegradient.Color = ColorSequence.new({
    [1] = ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 0, 182)), 
    [2] = ColorSequenceKeypoint.new(0.52, Color3.fromRGB(117, 0, 163)),
    [3] = ColorSequenceKeypoint.new(1, Color3.fromRGB(95, 0, 121))
});
targethudprofile.Name = 'ProfileBox';
targethudprofile.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
targethudprofile.BorderSizePixel = 0;
targethudprofile.Position = UDim2.new(0.037, 0, 0.16, 0);
targethudprofile.Size = UDim2.new(0, 77, 0, 76);
targethudprofilegradient.Rotation = 122;
targethudprofilegradient.Color = ColorSequence.new({
    [1] = ColorSequenceKeypoint.new(0, Color3.fromRGB(108, 0, 154)), 
    [2] = ColorSequenceKeypoint.new(0.35, Color3.fromRGB(97, 0, 139)), 
    [3] = ColorSequenceKeypoint.new(0.52, Color3.fromRGB(117, 0, 163)), 
    [4] = ColorSequenceKeypoint.new(0.67, Color3.fromRGB(117, 0, 163)), 
    [5] = ColorSequenceKeypoint.new(1, Color3.fromRGB(81, 0, 104))
});
targethudprofilestroke.Color = Color3.fromRGB(213, 213, 213);
targethudprofilestroke.Transparency = 0.1;
targethudprofilestrokegradient.Rotation = 122;
targethudprofilestrokegradient.Color = ColorSequence.new({
    [1] = ColorSequenceKeypoint.new(0, Color3.fromRGB(108, 0, 154)), 
    [2] = ColorSequenceKeypoint.new(0.35, Color3.fromRGB(97, 0, 139)), 
    [3] = ColorSequenceKeypoint.new(0.52, Color3.fromRGB(117, 0, 163)), 
    [4] = ColorSequenceKeypoint.new(0.67, Color3.fromRGB(117, 0, 163)), 
    [5] = ColorSequenceKeypoint.new(1, Color3.fromRGB(81, 0, 104))
});
targethudprofilepicture.Name = 'ProfilePicture';
targethudprofilepicture.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
targethudprofilepicture.BackgroundTransparency = 1;
targethudprofilepicture.BorderSizePixel = 0;
targethudprofilepicture.Position = UDim2.new(-0.03, 0, 0, 0);
targethudprofilepicture.Size = UDim2.new(0, 80, 0, 80);
targethudprofilepicture.Image = `rbxthumb://type=AvatarHeadShot&id={lplr.UserId}&w=420&h=420`;
targethudhealthbar.Name = 'Healthbar';
targethudhealthbar.BackgroundColor3 = Color3.fromRGB(92, 0, 120);
targethudhealthbar.BorderSizePixel = 0;
targethudhealthbar.Position = UDim2.new(0.295906126, 0, 0.508771956, 0);
targethudhealthbar.Size = UDim2.new(0, 218, 0, 7);
targethudhealthbar2.BackgroundColor3 = Color3.fromRGB(163, 0, 217);
targethudhealthbar2.BorderSizePixel = 0;
targethudhealthbar2.Position = UDim2.new(-0.000647451379, 0, -0.0162789486, 0);
targethudhealthbar2.Size = UDim2.new(0, 218, 0, 7);
targethudtextinfo.Name = 'TargetName'
targethudtextinfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
targethudtextinfo.BackgroundTransparency = 1;
targethudtextinfo.BorderSizePixel = 0;
targethudtextinfo.Position = UDim2.new(0, 0, -3.71428561, 0);
targethudtextinfo.Size = UDim2.new(0, 218, 0, 19);
targethudtextinfo.Font = Enum.Font.GothamBold;
targethudtextinfo.Text = lplr.DisplayName;
targethudtextinfo.TextColor3 = Color3.fromRGB(222, 222, 222);
targethudtextinfo.TextScaled = true;
targethudtextinfo.TextSize = 14;
targethudtextinfo.TextWrapped = true;
targethudtextinfo.TextXAlignment = Enum.TextXAlignment.Left;
targethudhealthinfo.Name = 'HealthStatus';
targethudhealthinfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
targethudhealthinfo.BackgroundTransparency = 1;
targethudhealthinfo.BorderSizePixel = 0;
targethudhealthinfo.Position = UDim2.new(0.74, 0, 1.57, 0);
targethudhealthinfo.Size = UDim2.new(0, 55, 0, 13);
targethudhealthinfo.Font = Enum.Font.GothamBold;
targethudhealthinfo.Text = '100';
targethudhealthinfo.TextColor3 = Color3.fromRGB(255, 255, 255);
targethudhealthinfo.TextScaled = true;
targethudhealthinfo.TextSize = 14;
targethudhealthinfo.TextWrapped = true;
targethudhealthinfo.TextXAlignment = Enum.TextXAlignment.Right;
targethudstatusinfo.Name = 'Status';
targethudstatusinfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
targethudstatusinfo.BackgroundTransparency = 1;
targethudstatusinfo.BorderSizePixel = 0;
targethudstatusinfo.Position = UDim2.new(0.294478536, 0, 0.675438583, 0);
targethudstatusinfo.Size = UDim2.new(0, 200, 0, 15);
targethudstatusinfo.Font = Enum.Font.GothamMedium;
targethudstatusinfo.Text = 'Status: Healthy';
targethudstatusinfo.TextColor3 = Color3.fromRGB(255, 255, 255);
targethudstatusinfo.TextScaled = true;
targethudstatusinfo.TextSize = 14;
targethudstatusinfo.TextTransparency = 0.3;
targethudstatusinfo.TextWrapped = true;
targethudstatusinfo.TextXAlignment = Enum.TextXAlignment.Left;

Instance.new('UICorner', targethudhealthbar2).CornerRadius = UDim.new(0, 4);
Instance.new('UICorner', targethudhealthbar).CornerRadius = UDim.new(0, 4);
Instance.new('UICorner', targethudprofile).CornerRadius = UDim.new(0, 13);
Instance.new('UICorner', hudframe).CornerRadius = UDim.new(0, 14);
Instance.new('UICorner', targethudprofilepicture).CornerRadius = UDim.new(0, 20);

function api:updatehuds(target: RenderTarget)
    assert(target == nil or typeof(target) == 'table', `❌ Render Target HUD API - table expected for argument #1, got {typeof(target)}.`);
    if target == nil or target.Player == nil or target.RootPart == nil then 
        hudframe.Visible = false;
        return
    end;
    hudframe.Visible = true;
    targethudprofilepicture.Image = `rbxthumb://type=AvatarHeadShot&id={target.Player.UserId}&w=420&h=420`;
    targethudtextinfo.Text = target.Player.DisplayName;
    targethudhealthinfo.Text = tostring(math.floor(target.Humanoid.Health));
    tween:Create(targethudhealthbar2, TweenInfo.new(0.15), {
        Size = UDim2.new(0, target.Humanoid.MaxHealth <= target.Humanoid.Health and 218 or 218 / (target.Humanoid.MaxHealth / target.Humanoid.Health), 0, 7)
    }):Play()
end;

api.instance = gui;

return api