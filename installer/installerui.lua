    --[[

    $$$$$$$\                            $$\                           $$$$$$\                       $$\               $$\ $$\                            $$$$$$\  $$\   $$\ $$$$$$\ 
    $$  __$$\                           $$ |                          \_$$  _|                      $$ |              $$ |$$ |                          $$  __$$\ $$ |  $$ |\_$$  _|
    $$ |  $$ | $$$$$$\  $$$$$$$\   $$$$$$$ | $$$$$$\   $$$$$$\          $$ |  $$$$$$$\   $$$$$$$\ $$$$$$\    $$$$$$\  $$ |$$ | $$$$$$\   $$$$$$\        $$ /  \__|$$ |  $$ |  $$ |  
    $$$$$$$  |$$  __$$\ $$  __$$\ $$  __$$ |$$  __$$\ $$  __$$\         $$ |  $$  __$$\ $$  _____|\_$$  _|   \____$$\ $$ |$$ |$$  __$$\ $$  __$$\       $$ |$$$$\ $$ |  $$ |  $$ |  
    $$  __$$< $$$$$$$$ |$$ |  $$ |$$ /  $$ |$$$$$$$$ |$$ |  \__|        $$ |  $$ |  $$ |\$$$$$$\    $$ |     $$$$$$$ |$$ |$$ |$$$$$$$$ |$$ |  \__|      $$ |\_$$ |$$ |  $$ |  $$ |  
    $$ |  $$ |$$   ____|$$ |  $$ |$$ |  $$ |$$   ____|$$ |              $$ |  $$ |  $$ | \____$$\   $$ |$$\ $$  __$$ |$$ |$$ |$$   ____|$$ |            $$ |  $$ |$$ |  $$ |  $$ |  
    $$ |  $$ |\$$$$$$$\ $$ |  $$ |\$$$$$$$ |\$$$$$$$\ $$ |            $$$$$$\ $$ |  $$ |$$$$$$$  |  \$$$$  |\$$$$$$$ |$$ |$$ |\$$$$$$$\ $$ |            \$$$$$$  |\$$$$$$  |$$$$$$\ 
    \__|  \__| \_______|\__|  \__| \_______| \_______|\__|            \______|\__|  \__|\_______/    \____/  \_______|\__|\__| \_______|\__|             \______/  \______/ \______|
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
    ]]


    local cloneref = (cloneref or function(data) return data end)
    local tween = game.FindService(game, 'TweenService')
    local inputservice = game.FindService(game, 'UserInputService')
    local httpservice = ({pcall(game.FindService, game, 'HttpService')})[2]
    local coregui = ({pcall(game.FindService, game, 'CoreGui')})[2]
    local ria = 'RIA-TEST'
    local runservice = game.FindService(game, 'RunService')
    local players = game.FindService(game, 'Players')
    local getenv = (getgenv or function() return _G end)
    local exploit = (runservice:IsStudio() and 'Roblox Studio' or identifyexecutor and identifyexecutor() or getexecutorname and getexecutorname() or 'poopsploit')
    local setmetatable = (setmetatable or function(tab) return tab end)
    local Color = Color3

    local api = {
        events = {}, 
        uninjected = Instance.new('BindableEvent'),
        theme = 'DEFAULT'
    };

    if getenv().renderinstaller and getenv().renderinstaller.window then 
        getenv().renderinstaller.window.Instance:Remove()
    end

    local creategradient = function(pos, color, pos2, color2)
        return ColorSequence.new({ColorSequenceKeypoint.new(pos, color), ColorSequenceKeypoint.new(pos2, color2)})
    end

    local createdraggable = function(ui: Instance)
        ui.Archivable = true 
        ui.Draggable = true
    end

    pcall(function()
        httpservice = cloneref(httpservice)
        players = cloneref(players)
        tween = cloneref(tween)
        inputservice = cloneref(inputservice)
        coregui = cloneref(gethui and gethui() or coregui)
    end)    

    function api:cleartab() 
        for i,v in next, api.window.recycle do 
            v:Remove()
        end
        table.clear(api.window.recycle)
    end

    function api:makedrag(ui: Instance, speed: number, uninjectbypass: boolean, openflag: boolean)
        local dragging
        local draginput
        local dragstart
        local startpos
        local dragfunc = function(input)
            local delta = input.Position - dragstart;
            tween:Create(ui, TweenInfo.new(tonumber(speed or '') or 0.05), {Position = UDim2.new(startpos.X.Scale, startpos.X.Offset + delta.X, startpos.Y.Scale, startpos.Y.Offset + delta.Y)}):Play()
        end
        ui.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragstart = input.Position
                startpos = ui.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        ui.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                draginput = input
            end
        end)
        runservice:BindToRenderStep('Drag', Enum.RenderPriority.Input.Value, function()
            if dragging then
                dragfunc(draginput)
            end
        end)
    end

    function api:switchtab(tab: table, animation: boolean, noclear: boolean)
        local switched = false
        local selected
        for i,v in next, api.window.tabs do
            if v.Selected and tostring(v) ~= tab then 
                v.Selected = false
                v.Instance.TextColor3 = Color.fromRGB(106, 106, 106)
                local out = tween:Create(v.Instance.Frame, TweenInfo.new(animation and 0.21 or 0.001, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 0, -2)})
                out:Play()
                task.spawn(function()
                    out.Completed:Wait()
                    v.Instance.Frame.Visible = false
                end)
                if typeof(v.callback) == 'function' then 
                    task.spawn(v.callback, false, v)
                end
            end 
            if tostring(v) == tab and not v.Selected then
                selected = tab 
                v.Selected = true
                v.Instance.TextColor3 = Color.fromRGB(191, 191, 191)
                v.Instance.Frame.Visible = true
                v.Instance.Frame.Size = UDim2.new(0, 0, 0, -2)
                tween:Create(v.Instance.Frame, TweenInfo.new(animation and 0.2 or 0.001, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 60, 0, -2)}):Play()
                switched = true
                if not noclear then 
                    api:cleartab()
                end
                if typeof(v.callback) == 'function' then 
                    task.spawn(v.callback, true, v)
                end
            end
        end
        return switched
    end

    function api:destroy()
        if api.window then 
            api.window.Instance:Destroy()
        end
        api.uninjected:Fire()
        for i,v in next, api.window.buttons do 
            if v.enabled then 
                pcall(v.toggle, v)
            end
        end
        for i,v in next, api.events do 
            pcall(v.Disconnect, v)
        end
        table.clear(api)
        api = nil
        getenv().renderinstaller = nil
    end

    function api:exploitcheck()
        local request = (request or http and http.request or http_request or syn and syn.request)
        local sanityfuncs = {'writefile', 'readfile', 'listfiles', 'delfile', 'delfolder', 'makefolder', 'getmetatable', 'setmetatable'}
        local httpfuncs = {'HttpGet', 'HttpGetAsync'}
        for i,v in next, sanityfuncs do 
            if typeof(getenv()[v]) ~= 'function' then 
                return false
            end
        end
        local contents = tostring(math.random(1, 31213131))
        pcall(writefile, 'INSTALLER-TEST.TXT', contents)
        local suc, res = pcall(readfile, 'INSTALLER-TEST.TXT')
        if res ~= contents then 
            return false 
        end
        local suc2 = pcall(delfile, 'INSTALLER-TEST.TXT')
        if not suc2 then 
            return false 
        end
        local suc3, res3 = pcall(function()
            local garbage = setmetatable({}, {__tostring = function() return 'failed' end})
            getmetatable(garbage).__tostring = function()
                return 'worked'
            end
            return tostring(garbage)
        end)
        if res3 ~= 'worked' then 
            return false 
            end
            for i,v in next, httpfuncs do 
                local suc4, res4 = pcall(game[v], game, 'https://example.com')
                if res4:find('Example Domain') == nil then 
                   return false 
                end
            end
            local suc5, res5 = pcall(function() return loadstring('return true')() end) 
            if res5 ~= true then 
                return false 
            end
            pcall(writefile, 'INSTALLER-TEST.TXT', 'return true')
            local suc6, res6 = pcall(function() return loadfile('INSTALLER-TEST.TXT')() end) 
            if res6 ~= true then 
                return false 
            end
            task.wait()
            pcall(delfile, 'INSTALLER-TEST.TXT') 
            local suc7 = pcall(makefolder, 'renderinstaller')   
            if not suc7 then 
                return false 
            end
            pcall(writefile, 'renderinstaller/INSTALLER-TEST.TXT', 'true')
            local suc8, res8 = pcall(readfile, 'renderinstaller/INSTALLER-TEST.TXT')
            if not suc8 then 
                return false 
            end
            if res8 ~= 'true' then 
                return false 
            end
            local suc9 = pcall(delfolder, 'renderinstaller')
            if not suc9 then 
                return false 
            end
            if typeof(request) ~= 'function' then 
                return false 
            end
            return true
        end
        function api:install(steptab: table)
            local installapi = setmetatable({}, {__tostring = function() return 'Render Installation API' end})
            local hidden = 0
            local steps = {}
            for i,v in next, api.window.Instance.Frame:GetDescendants() do 
                if v ~= api.window.definitions.top and v ~= api.window.definitions.topicon and (v.ClassName:lower():find('label') or v.ClassName:lower():find('button') or v.ClassName == 'Frame') then 
                    task.spawn(function()
                        local invis = tween:Create(v, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
                        pcall(function() tween:Create(v, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {ImageColor3 = 1}):Play() end)
                        pcall(function() tween:Create(v, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play() end)
                        pcall(function() tween:Create(v, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {ImageTransparency = 1}):Play() end)
                        pcall(function() tween:Create(v, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {Transparency = 1}):Play() end)
                        invis:Play()
                        invis.Completed:Wait()
                        v:Remove()
                    end)
                end
            end
            for i,v in next, (steptab or {}) do 
                if typeof(v) == 'function' then 
                    table.insert(steps, v)
                end
            end
            task.wait(hidden > 0 and 0.3 or 0)
            tween:Create(api.window.Instance.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Size = UDim2.new(0, 449, 0, 211)}):Play()
            tween:Create(api.window.definitions.topicon, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Position = UDim2.new(0.082, 0, 0.082, 0)}):Play()
            task.wait(0.5)
            local installtype = Instance.new('TextLabel', api.window.Instance.Frame)
            local installaction
            local installerbar = Instance.new('Frame', api.window.Instance.Frame)
            local installerbargradient = Instance.new('UIGradient')
            local installerbar2
            local installerest
            installtype.Text = 'Booting functions'
            installtype.TextColor3 = Color.fromRGB(255, 255, 255)
            installtype.TextSize = 25 
            installtype.Size = UDim2.new(0, 320, 0, 50)
            installtype.Position = UDim2.new(0.147, 0, 0.256, 0)
            installtype.Font = Enum.Font.GothamBold
            installtype.BackgroundTransparency = 1
            installtype.ZIndex = 2
            installerest = installtype:Clone()
            installerest.Text = 'this is just the start, please be patient.'
            installerest.TextSize = 14
            installerest.ZIndex = 2
            installerest.Position = UDim2.new(0.134, 0, 0.422, 0)
            installerest.Parent = api.window.Instance.Frame
            installerbar.Position = UDim2.new(0.114, 0, 0.659, 0)
            installerbar.Size = UDim2.new(0, 349, 0, 16)
            installerbar.ZIndex = 2
            installerbar.BackgroundColor3 = Color.fromRGB(6, 1, 25)
            installerbar2 = installerbar:Clone()
            installerbar2.ZIndex = 3
            installerbar2.Size = UDim2.new(0, 0, 0, 16)
            installerbar2.Position = UDim2.new(-0.043, 0, -0.024, 0)
            installerbar2.BackgroundColor3 = Color.fromRGB(255, 255, 255)
            installerbar2.Parent = installerbar
            installerbargradient.Color = creategradient(0, Color.fromRGB(44, 16, 127), 1, Color.fromRGB(36, 6, 116))
            installerbargradient.Rotation = 90.472
            installerbargradient.Parent = installerbar2
            installaction = installerest:Clone()
            installaction.Size = UDim2.new(0, 385, 0, 50)
            installaction.Position = UDim2.new(0.056, 0, 0.73, 0)
            installaction.TextSize = 13
            installaction.TextColor3 = Color.fromRGB(115, 115, 115)
            installaction.Text = ''
            installaction.Parent = api.window.Instance.Frame
            for i,v in next, ({installerbar, installerbar2}) do 
                Instance.new('UICorner', v).CornerRadius = UDim.new(0, 6)
            end
            function installapi:addstep(func)
                return table.insert(steps, func)
            end
            function installapi:updatetitle(text)
                installtype.Text = tostring(text)
            end
            function installapi:updatedesc(text)
                installerest.Text = tostring(text)
            end
            function installapi:updatestatus(text)
                installaction.Text = tostring(text)
            end
            function installapi:start()
                for i, func in next, steps do 
                    local success, res = pcall(func)
                    tween:Create(installerbar2, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Size = UDim2.new(0, (#steps - i) <= 0 and 364 or 364 / (#steps - i), 0, 16)}):Play()
                    if not success then 
                        installapi:exception('Installation Error', 'An error has been detected in the code.', res)
                    end
                end
                installapi:updatetitle('Installation complete')
                installapi:updatedesc('enjoy using render!')
                installapi:updatestatus('The installer will close in 3.8 seconds')
                task.delay(3.8, function()
                    api:destroy()
                end)
            end
            function installapi:exception(title: string, desc: string, state: string)
                installtype.Text = title
                if desc then 
                    installerest.Text = desc
                end
                if state then 
                    installaction.Text = state
                end
                installerbargradient.Color = creategradient(0, Color.fromRGB(127, 0, 2), 1, Color.fromRGB(144, 0, 5))
                for i,v in next, steps do 
                    steps[i] = function() task.wait(9e9) end 
                end
                task.delay(5, function()
                    api:destroy()
                end)
                return task.wait(9e9)
            end
            return installapi
        end

    function api:createwindow(userdata: table)
        if typeof(userdata or '') ~= 'table' then 
            userdata = {}
        end
        local guiapi = setmetatable({tabs = {}, buttons = {}, definitions = {}, settings = {}, recycle = {}, type = 'window'}, {__tostring = function() return 'Render Installer main window' end})
        local gui = Instance.new('ScreenGui', runservice:IsStudio() and players.LocalPlayer.PlayerGui or coregui)
        local mainframe = Instance.new('Frame', gui)
        local mainround = Instance.new('UICorner', mainframe)
        local themebutton = Instance.new('ImageButton', mainframe)
        local maingradient = Instance.new('UIGradient', mainframe)
        local mainoutline = Instance.new('UIStroke', mainframe)
        local toplistframe = Instance.new('Frame', mainframe)
        local toplist = Instance.new('UIListLayout', toplistframe)
        local rendertopicon = Instance.new('ImageLabel', mainframe)
        local mainshadow = Instance.new('ImageLabel', mainframe)
        local circle = Instance.new('Frame', mainframe)
        local circle2 = Instance.new('Frame', mainframe)
        local circle3 = Instance.new('Frame', mainframe)
        local circle4 = Instance.new('Frame', mainframe)
        local circles = {circle, circle2, circle3, circle4}
        local top = Instance.new('Frame', mainframe)
        local topround = Instance.new('UICorner', top)
        gui.Name = 'Render Installer'
        mainframe.Size = UDim2.new(0, 449, 0, 372)
        mainframe.Position = UDim2.new(0.438, 0, 0.167, 0)
        mainframe.BackgroundColor3 = Color.fromRGB(255, 255, 255)
        mainround.CornerRadius = UDim.new(0, 15)
        mainframe.ClipsDescendants = true
        maingradient.Color = creategradient(0, Color.fromRGB(38, 10, 130), 1, Color.fromRGB(17, 5, 54))
        maingradient.Rotation = 90.472
        mainoutline.Color = Color.fromRGB(48, 9, 166)
        mainoutline.Thickness = 2
        top.Position = UDim2.new(0.05, 0, 0.043, 0)
        top.BackgroundColor3 = Color.fromRGB(25, 4, 83)
        top.Size = UDim2.new(0, 404, 0, 40)
        top.ZIndex = 2
        topround.CornerRadius = UDim.new(0, 11)
        themebutton.Size = UDim2.new(0, 20, 0, 20)
        themebutton.Position = UDim2.new(0.848, 0, 0.067, 0)
        themebutton.BackgroundTransparency = 1
        themebutton.Image = 'rbxassetid://14906289364'
        themebutton.ZIndex = 3
        rendertopicon.Size = UDim2.new(0, 30, 0, 23)
        rendertopicon.ScaleType = Enum.ScaleType.Fit
        rendertopicon.Position = UDim2.new(0.084, 0, 0.068, 0)
        rendertopicon.BackgroundTransparency = 1 
        rendertopicon.Image = 'rbxassetid://16852575555'
        rendertopicon.ZIndex = 3
        toplistframe.Size = UDim2.new(0, 325, 0, -45)
        toplistframe.Position = UDim2.new(0.223, 0, 0.19, 0)
        toplistframe.BackgroundTransparency = 1
        toplist.Padding = UDim.new(0, 5)
        toplist.FillDirection = Enum.FillDirection.Horizontal
        toplist.HorizontalAlignment = Enum.HorizontalAlignment.Left
        toplist.VerticalAlignment = Enum.VerticalAlignment.Top
        mainshadow.BackgroundTransparency = 1
        mainshadow.Position = UDim2.new(-0.174, 0, 0.82, 0)
        mainshadow.Size = UDim2.new(0, 625, 0, 94)
        mainshadow.Image = 'rbxassetid://8992238178'
        mainshadow.ImageColor3 = Color.fromRGB(30, 2, 90)
        circle.Size = UDim2.new(0, 400, 0, 400)
        circle.Position = UDim2.new(0.274, 0, 0.467, 0)
        circle2.Size = UDim2.new(0, 300, 0, 300)
        circle2.Position = UDim2.new(0.462, 0, 0.599, 0)
        circle3.Size = UDim2.new(0, 350, 0, 350)
        circle3.Position = UDim2.new(0.368, 0, 0.533, 0)
        circle4.Size = UDim2.new(0, 250, 0, 250)
        circle4.Position = UDim2.new(0.556, 0, 0.666, 0)
        for i,v in next, circles do
            v.BackgroundTransparency = 1 
            Instance.new('UICorner', v).CornerRadius = UDim.new(1, 0)
            local stroke = Instance.new('UIStroke', v)
            stroke.Thickness = 1
            stroke.Color = Color.fromRGB(42, 47, 63)
        end
        gui.ResetOnSpawn = false
        guiapi.Instance = gui
        guiapi.definitions.top = top
        guiapi.definitions.topicon = rendertopicon
        api.window = guiapi
        guiapi.createtab = function(self, tabdata)
            if typeof(tabdata) ~= 'table' then 
                tabdata = {}
            end
            local tabapi = setmetatable({Selected = false, type = 'tab', name = tabdata.name or 'tab_'..(#tabs + 1), definitions = {}}, {__tostring = function() return tabdata.name or 'tab_'..(#tabs + 1) end})
            local buttonmain = Instance.new('TextButton')
            local enabledframe = Instance.new('Frame', buttonmain)
            buttonmain.TextColor3 = Color.fromRGB(191, 191, 191)
            buttonmain.BackgroundTransparency = 1 
            buttonmain.TextSize = 14
            buttonmain.Font = Enum.Font.GothamBold
            buttonmain.Position = UDim2.new(0.197, 0, 0.225, 0)
            buttonmain.Text = (tabdata.name or 'tab')
            buttonmain.Size = UDim2.new(0, 57, 0, 21)
            buttonmain.ZIndex = 5
            buttonmain.TextColor3 = Color.fromRGB(106, 106, 106)
            enabledframe.ZIndex = 4
            enabledframe.Size = UDim2.new(0, 60, 0, -2)
            enabledframe.Position = UDim2.new(-0.035, 0, 1.476, 0)
            enabledframe.BackgroundColor3 = Color.fromRGB(154, 176, 191)
            enabledframe.Visible = false
            buttonmain.Parent = toplistframe
            tabapi.Instance = buttonmain
            buttonmain.MouseButton1Click:Connect(function() api:switchtab(tabapi.name, true) end)
            if typeof(tabdata.callback) == 'function' then  
                tabapi.callback = tabdata.callback    
            end
            table.insert(guiapi.tabs, tabapi)
            createdraggable(mainframe)
            return tabapi
        end
        api:makedrag(mainframe)
        return guiapi
    end

    function api:createbutton(userdata: table)
        if typeof(userdata) ~= 'table' then 
            userdata = {}
        end
        local buttonapi = setmetatable({enabled = false, definitions = {}, type = 'button'}, {__tostring = function() return 'Render Installer button component' end})
        local button = Instance.new('ImageButton', typeof(userdata.parent) == 'Instance' and userdata.parent)
        local buttontext = Instance.new('TextLabel', button)
        local buttonicon = Instance.new('ImageLabel', button)
        button.MouseButton1Click:Connect(function()
            if userdata.manual then 
                return 
            end
            if buttonapi.enabled then 
                buttonapi:toggle()
            else
                buttonapi:toggle(true)
            end
        end)
        button.BackgroundColor3 = Color.fromRGB(10, 0, 43)
        button.Size = UDim2.new(0, 127, 0, 35)
        button.AutoButtonColor = false
        button.Image = ''
        buttonicon.ImageColor3 = Color.fromRGB(255, 255, 255)
        buttonicon.Position = UDim2.new(0.039, 0, 0.143, 0) 
        buttonicon.Size = UDim2.new(0, 25, 0, 25)
        buttonicon.BackgroundTransparency = 1
        buttonicon.Image = ''
        if typeof(userdata.icon) == 'string' then 
            buttonicon.Image = userdata.icon
        end
        buttontext.Text = (typeof(userdata.name) == 'string' and userdata.name or 'button_'..math.random(1, 20))
        buttontext.TextColor3 = Color.fromRGB(255, 255, 255)
        buttontext.TextSize = 14 
        buttontext.TextScaled = true 
        buttontext.Size = UDim2.new(0, 77, 0, 17)
        buttontext.Position = UDim2.new(0.11, 0, 0.238, 0)
        buttontext.Font = Enum.Font.GothamBold
        buttontext.BackgroundTransparency = 1
        task.spawn(function()
            if (not userdata.noimageyield) and (not buttonicon.IsLoaded) then 
                repeat task.wait() until buttonicon.IsLoaded 
            end
            buttontext.Position = UDim2.new(0.236, 0, 0.267, 0)
        end)
        function buttonapi:toggle(mode: boolean)
            buttonapi.enabled = (mode and true or false)
            api.window.settings[buttontext.Text] = buttonapi.enabled
            if buttonapi.enabled then 
                tween:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color.fromRGB(10, 0, 43)}):Play()
                tween:Create(buttontext, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {TextColor3 = Color.fromRGB(255, 255, 255)}):Play()
                tween:Create(buttonicon, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {ImageColor3 = Color.new(255, 255, 255)}):Play()
            else 
                tween:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color.fromRGB(255, 255, 255)}):Play()
                tween:Create(buttonicon, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {ImageColor3 = Color.new()}):Play()
                tween:Create(buttontext, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {TextColor3 = Color.new()}):Play()
            end
            if typeof(userdata.callback) == 'function' then 
                userdata.callback(buttonapi.enabled, buttonapi)
            end
        end
        if api.window.settings[buttontext.Text] ~= nil and not userdata.nosave then 
            buttonapi:toggle(api.window.settings[buttontext.Text])
        end
        buttonapi.Instance = button
        Instance.new('UICorner', button).CornerRadius = UDim.new(0, 10)
        table.insert(api.window.buttons, buttonapi)
        return buttonapi
    end
    

    getenv().renderinstaller = api 
    return api

    