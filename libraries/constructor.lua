type connectionobject = {
    Disconnect: (connectionobject) -> (),
    Enable: (connectionobject) -> (),
    Disable: (connectionobject) -> (),
    Callback: (any) -> any,
    Connected: boolean
};

type connectionconstructor = {
    Connect: (connectionconstructor, (...any) -> ...any) -> connectionobject,
    Once: (connectionconstructor, (...any) -> ...any) -> connectionobject,
    listconnections: () -> table
};

type runtimeobject = {
    waitforevent: (runtimeobject, string, number | nil) -> (),
    events: table
};

type tagobject = {
    text: string,
    hex: string
};

type httprequestrargs = {
    headers: table,
    path: string,
    subdomain: string | nil,
    method: string | nil,
    params: table | nil,
    body: string | nil,
    json: table | nil
};

type httpresponseobject = {
    headers: table,
    status: number,
    time: number,
    body: string,
    statustype: string,
    ok: boolean,
    json: () -> any
};

type httpobject = {
    request: (httpobject, httprequestrargs) -> httpresponseobject,
    getdiscord: (httpobject, boolean | nil, string | nil) -> table?
};

type whitelistattributes = {
    rank: string,
    attackable: boolean,
    priority: number,
    tagtext: string,
    tagcolor: string,
    taghidden: boolean,
    autokick: boolean,
    account: string | nil,
    prefix: string
};

type whitelistobject = {
    get: (whitelistobject, number | nil, Player | nil) -> any
};

type constructorobject = {
    runtime: runtimeobject,
    http: httpobject,
    whitelist: whitelistobject,
    uninject: (constructorobject) -> (),
    tagplayer: (constructorobject, Player | nil, string, string) -> tagobject,
    getplayertag: (constructorobject, Player | nil) -> tagobject,
    removeplayertag: (constructorobject, Player | nil) -> (),
};

local lib: constructorobject = setmetatable({}, {});
local constructor: table = getmetatable(lib);

local clonefunction = clonefunction or clonefunc or function(func: () -> any): () -> (() -> any) 
    return func;
end;

local cloneref: (Instance) -> Instance = clonefunction(cloneref or function(...) return (...) end);
local getservice: (string) -> Instance = function(service) return cloneref(game:FindService(service)) end;
local request: ({Headers: table | nil, Method: string | nil, Body: string | nil, Url: string}) -> table = clonefunction(request or http and http.request or http_request or function(...) return getservice('HttpService'):RequestAsync(...) end);
local executor: string = clonefunction(identifyexecutor or getexecutorname or identify_executor or get_executor_name or function() return 'poopsploit' end)();
local executescript: (string, string) -> (() -> any) = clonefunction(loadstring);
local oldwritefile: (string, string) -> () = clonefunction(writefile);
local isfunchooked: ((...any) -> (...any)) -> (boolean) = clonefunction(isfunctionhooked or function() return false end);
local iscclosure: ((...any) -> (...any)) -> (boolean) = clonefunction(iscclosure or function() return true end);
local hookfunction: ((...any) -> (...any)) -> ((...any) -> (...any)) = clonefunction(hookfunction or function(old, new) end);
local blanktable: table = {};
local checkcaller: () -> boolean = clonefunction(checkcaller or function()
    return true;
end);

local gethwid: () -> string = clonefunction(gethwid or function() 
    local analytics = getservice('RbxAnalyticsService');
    return clonefunction(analytics.GetClientId)(analytics)
end);

local httpservice: HttpService = getservice('HttpService');
local players: Players = getservice('Players');
local tween: Tween = getservice('TweenService');
local startergui: StarterGui = getservice('StarterGui');
local textchat: TextChatService = getservice('TextChatService');
local lplr: Player = players.LocalPlayer;

local newcclosure: ((...any) -> (...any)) -> ((...any) -> (...any)) = clonefunction(newcclosure or function(func)
    return clonefunction(func);
end);

local encoded: table = clonefunction(httpservice.JSONDecode)(httpservice, [[{"A": "8E98344E0F", "a": "821563E632", "B": "04D2721E44", "b": "8CD746A289", "C": "15D6587BB3", "c": "8711027A9E", "D": "7AE2050EA9", "d": "3F2DA4F48A", "E": "BD68D1BA8C", "e": "8E839A25FF", "F": "B19EBE9608", "f": "048E4987E4", "G": "205ED9F9AC", "g": "0B4CC2FD18", "H": "D1F07E3862", "h": "A8CEBD5C87", "I": "FB777392FB", "i": "C7E406BF2C", "J": "A79AA2F824", "j": "7F74C0BEC6", "K": "5EF1E54A1D", "k": "071C3B5920", "L": "7F9689A639", "l": "64789050D6", "M": "730CDE4050", "m": "9A1BB4BED0", "N": "2A8653B3F0", "n": "FDF1670638", "O": "7AE2DD8A23", "o": "1F46EBECCF", "P": "20EF8024E4", "p": "4B12498EBF", "Q": "59BF022087", "q": "B59A70B75E", "R": "C98F07A1DB", "r": "3948F9C560", "S": "DD5286D213", "s": "DBAAC71633", "T": "4D861B53EB", "t": "E8FB75A581", "U": "0510FE0E33", "u": "B67A2DE277", "W": "1B974228F8", "w": "057E975391", "X": "99DC91BE20", "x": "DD559CA3D0", "Y": "38D9AB61ED", "y": "BEDF66DFF1", "Z": "5463DD99E1", "z": "E454082DD2", " ": "F0BFFD93EB"}]]);
local createConstructorClass: (table | nil, boolean?) -> table = function(tab, nolock: boolean?)
    local protectedTab: table = setmetatable(tab or {}, {});
    getmetatable(protectedTab).__iter = function() return next, {new = function() end} end;
    getmetatable(protectedTab).__tostring = function() return '⚠️ Render constructed table.' end;
    if not nolock then 
        getmetatable(protectedTab).__metatable = {new = function() end};
    end;
    return protectedTab
end;

local addconnection = function(event: string, func: () -> any): (number, {callback: (...any) -> (...any), enabled: boolean})
    local list = constructor.cache.connections[event] or {};
    local tab: table = {callback = func, enabled = true};
    local pos: number = table.insert(list, tab)
    constructor.cache.connections[event] = list;
    return pos, tab
end;

local getplayer: (string | number) -> (Player | nil) = function(data)
    for i: number, v: Player in players:GetPlayers() do 
        if v.UserId == tonumber(data) or v.Name:lower() == tostring(data):lower() then 
            return v
        end
    end;
end;

local betterwritefile: (string, string) -> () = function(file, contents)
    local folderstring: string = '';
    for i: number, v: string in file:split('/') do 
        if i ~= #file:split('/') then 
            folderstring = `{folderstring}{v}/`;
            makefolder(folderstring)
        else 
            oldwritefile(file, contents)
        end
    end
end;

constructor.__index = createConstructorClass({
    runtime = createConstructorClass({events = createConstructorClass({}, true)}),
    whitelist = createConstructorClass({
        state = 0,
        ranks = createConstructorClass({
            BASIC = 1,
            GUEST = 2,
            PREMIUM = 3,
            INF = 4,
            OWNER = 5
        })
    }),
    http = createConstructorClass(),
});

pcall(function()
    getrawmetatable(lib.whitelist.ranks).__newindex = function(...)
        return nil
    end;
end);

if not iscclosure(identifyexecutor or getexecutorname or function() end) then 
    iscclosure = function(): (boolean)
        return true
    end;
end;

constructor.__index.uninject = function(self: constructorobject)
    table.clear(constructor.cache.connections);
    getgenv().writefile = oldwritefile;
    addconnection = function() end;
    for i: number, v: thread in constructor.cache.threads do 
        pcall(task.cancel, v);
        constructor.cache.threads[i] = nil;
    end;
    table.clear(constructor);
end;

constructor.cache = {};
constructor.cache.threads = {};
constructor.cache.tags = {};
constructor.cache.whitelist = {};
constructor.commands = {};
constructor.cache.pendingrequests = 0;
constructor.cache.connections = setmetatable({}, {
    __index = function(self: table, index: string)
        local list: table | nil = rawget(self, index);
        if list == nil then 
            self[index] = {};
            return self[index]
        end;
        return list
    end
});

constructor.fireconnections = function(self: table, event: string, ...): ()
    for i: number, v: {callback: (...any) -> (...any), enabled: boolean} in (constructor.cache.connections[event] or {}) do 
        if v.enabled then 
            task.spawn(v.callback, ...)
        end
    end;
end;

constructor.filecrashreport = function(self: constructorobject, message: string, id: number | string): ()
    local timedata: {min: number, hour: number} = os.date('*t');
    local hour: number = ((timedata.hour - 1) % 12 + 1);
    betterwritefile(`rendervape/crashlogs/{math.random(1, 1e3)}_{math.random(1, 50)}.log`, `ERROR: {message}\nID: {id}\nTICK: {tick()}\nTIME: {hour}:{timedata.min}`)
end;

constructor.announce = function(text: string, duration: number): Frame
    local gui: ScreenGui = shared.rendervape and shared.rendervape.MainGui or gethui and gethui():FindFirstChild('RobloxGui') or lplr.PlayerGui:FindFirstChildOfClass('ScreenGui');
    local anncframe: Frame = Instance.new('Frame', gui);
    local annctext: TextLabel = Instance.new('TextLabel', anncframe);
    local rendericon: ImageLabel = Instance.new('ImageLabel', anncframe);
    local anncstroke: UIStroke = Instance.new('UIStroke', anncframe);
    anncframe.Size = UDim2.new(0.766, 0, 0.077, 0);
    anncframe.Position = UDim2.new(0.116, 0, -5, 0);
    anncframe.BackgroundColor3 = Color3.fromRGB(18, 18, 18);
    rendericon.Position = UDim2.new(0.016, 0, 0.213, 0);
    rendericon.Size = UDim2.new(0, 42, 0, 42);
    rendericon.BackgroundTransparency = 1;
    rendericon.Image = 'rbxassetid://16852575555';
    annctext.Text = text;
    annctext.TextSize = 22;
    annctext.RichText = true;
    annctext.BackgroundTransparency = 1;
    annctext.Position = UDim2.new(0.045, 0, 0, 0);
    annctext.Size = UDim2.new(0.954, 0, 1, 0);
    annctext.TextColor3 = Color3.new(1, 1, 1);
    annctext.FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold);
    anncstroke.Color = Color3.new(1, 1, 1);
    anncstroke.Thickness = 2;
    Instance.new('UITextSizeConstraint', annctext).MaxTextSize = 22;
    Instance.new('UICorner', anncframe).CornerRadius = UDim.new(0, 15);
    task.spawn(function()
        local postween: Tween = tween:Create(anncframe, TweenInfo.new(0.5), {Position = UDim2.new(0.116, 0, 0.065, 0)});
        postween:Play();
        postween.Completed:Wait();
        task.wait(duration);
        local outttween: Tween = tween:Create(anncframe, TweenInfo.new(0.5), {Position = UDim2.new(0.116, 0, -5, 0)});
        outttween:Play();
        outttween.Completed:Wait();
        anncframe:Destroy()
    end);
    return anncframe
end;

constructor.decrypt = function(data: string): (string)
    for i: number, v: string in encoded do 
        data = data:gsub(v, i);
    end
    return data;
end;

constructor.events = {
    'RequestResponseReceived',
    'RequestResponsePending',
    'WhitelistRefreshRequest',
    'PlayerTagCreated',
    'PlayerTagRemoved',
    'StartupDataFetched',
    'AuthenticationRequest'
};

getmetatable(lib.runtime.events).__index = function(self: runtimeobject, index: string)
    assert(table.find(constructor.events, index), `❌ [Render Constructor] self.events - {index} is not a valid event.`);
    local eventTab = setmetatable({}, {
        __index = {
            Connect = function(self: table, callback: (any...) -> (...any))
                local pos: number, connectionTab: table = addconnection(index, callback);
                return setmetatable({}, {
                    __index = {
                        Disconnect = function(self: connectionobject)
                            self.Connected = false;
                            table.remove(constructor.cache.connections[index], pos)
                        end,
                        Disable = function(self: connectionobject)
                            connectionTab.enabled = false;
                        end,
                        Enable = function(self: connectionobject)
                            connectionTab.enabled = true;
                        end,
                        Connected = true,
                        callback = callback
                    }
                })
            end
        }
    });
    getmetatable(eventTab).__index.Once = function(self: table, callback: (...any) -> (...any))
        local connection: connectionobject; connection = eventTab:Connect(function(...)
            connection:Disconnect();
            callback(...);
        end);
        return connection
    end;
    return eventTab
end;

getmetatable(lib.runtime.events).__metatable = {};

lib.tagplayer = function(self: constructorobject, player: Player | nil, text: string, color: string | nil): tagobject
    assert(pcall(Color3.fromHex, color or 'FFFFFF'), `❌ [Render Constructor] self.tagplayer - Failed to extract color from hex (argument #2)`);
    constructor.cache.tags[player.UserId] = {
        text = text,
        hex = color or 'FFFFFF'
    };
    constructor:fireconnections('PlayerTagCreated', player, text, color or 'FFFFFF');
    return constructor.cache.tags[player.UserId]
end;

lib.removeplayertag = function(self: constructorobject, plr: Player | nil)
    local player: Player = typeof(plr) == 'Instance' and plr.ClassName == 'Player' and plr or lplr;
    constructor.cache.tags[player.UserId] = nil;
    constructor:fireconnections('PlayerTagRemoved', plr);
end;

lib.getplayertag = function(self: constructorobject, plr: Player | nil)
    local player: Player = typeof(plr) == 'Instance' and plr.ClassName == 'Player' and plr or lplr;
    return constructor.cache.tags[player.UserId]
end;

lib.http.request = function(self: httpobject, args: httprequestrargs): (httpresponseobject)
    assert(args.headers == nil or typeof(args.headers) == 'table', `❌ [Render Constructor] self.http.request - (table or nil) expected for args.headers, got {typeof(args.headers)}.`);
    assert(args.method == nil or typeof(args.headers) == 'table', `❌ [Render Constructor] self.http.request - (string or nil) expected for args.method, got {typeof(args.headers)}.`);

    local sent: number = tick();
    local url: string = `https://{args.subdomain or 'api'}.renderintents.lol/{args.path or ''}`;
    local querystring: string = '';
    local headers: table = args.headers or {};
    if args.params then 
        for i: number, v: string in args.params do 
            if typeof(v) ~= 'table' or v.name == nil or v.value == nil then 
                return error(`❌ [Render Constructor] self.http.request - Failed to parse params.`, 2)
            end;
            querystring = `{querystring}{i == 1 and '?' or '&'}{v.name}={v.value}`
        end;
        url = `{url}{querystring}`
    end;
    headers['X-AUTH-RIA'] = tostring(getgenv().ria or 'lol');
    repeat 
        assert(constructor.cache.pendingrequests < 8 or args.path == 'authenticate', '❌ [Render Constructor] You are currently exceeding the pending request limit of 8.');
        constructor.cache.pendingrequests += 1;
        constructor:fireconnections('RequestResponsePending', args);
        local clonedheaders: table = table.clone(headers);
        local _: boolean, response: table | string = pcall(function()
            return request({Url = url, Method = (args.method or 'GET'):upper(),Body = args.json and httpservice:JSONEncode(args.json) or args.body, Headers = setmetatable(headers, {
                __iter = newcclosure(function()
                    if checkcaller() then 
                        clonedheaders['X-AUTH-RIA'] = nil;
                        clonedheaders['Authorization'] = 'render vape';
                        return next, clonedheaders
                    end;
                end),
                __metatable = {},
            })});
        end);
        constructor.cache.pendingrequests -= 1;
        if typeof(response) ~= 'table' then 
            response = {
                Headers = {},
                StatusCode = 500,
                Body = ''
            }
        end;
        if tostring(response.StatusCode) ~= '429' then 
            local response = setmetatable({}, {
                __index = {
                    headers = response.Headers,
                    status = tonumber(response.StatusCode),
                    time = tick() - sent,
                    ok = tonumber(response.StatusCode) < 400,
                    body = response.Body,
                    statustype = tonumber(response.StatusCode) < 300 and 'OK' or tonumber(response.StatusCode) < 400 and 'REDIRECT' or tonumber(response.StatusCode) < 500 and 'AUTHENTICATION ERROR' or 'ERROR',
                    json = function()
                        local _: boolean, parsed: string = pcall(function()
                            return httpservice:JSONDecode(response.Body)
                        end);
                        return _ and parsed or error(`❌ [Render Constructor] self.http.request (json) - Failed to parse JSON.`, 3)
                    end
                }
            });
            constructor:fireconnections('RequestResponseReceived', response);
            return response;
        end;
        task.wait(11)
    until false
end;

lib.http.publishtocloud = function(self: httpobject, files: table): (number)
    assert(typeof(files), `table expected for argument #1, got {typeof(files)}`);
    local successrate: number = 0;
    for i: number?, v: ({name: string, contents: string}) in files do 
        assert(typeof(v) == 'table' and v.name and v.contents, `Failed to parse data for "array" pos {i}`);
        local response: httpresponseobject = self:request({
            subdomain = 'cloud',
            path = 'updatecloudfile',
            method = 'POST',
            headers = {file = tostring(v.name)},
            body = tostring(v.contents)
        });
        if response.ok then 
            successrate += 1;
        end;
    end;
    return successrate;
end;

lib.http.getdiscord = function(self: httpobject, full: boolean?, key: string?): table
    local res: httpresponseobject = self:request({
        path = 'newria',
        headers = {ria = key or ria},
        params = {{name = 'includediscordprofile', value = 'yes'}}
    });
    assert(res.ok, 'Failed to get discord information on this ria key.');
    assert(#res.json().result.discordprofiles > 0, 'Failed to get discord information on this ria key.');
    return full and res.json().result.discordprofiles or res.json().result.discordprofiles[1];
end;

lib.runtime.waitforevent = function(self: runtimeobject, event: string, timeout: number | nil)
    assert(typeof(event) == 'string', `❌ [Render Constructor] self.runtime.waitforevent - string expected for argument #1, got {typeof(event)}.`);
    assert(tonumber(timeout or ''), `❌ [Render Constructor] self.runtime.waitforevent - Failed to convert argument #2 to number.`);
    local resdata: table = nil;
    local requestedAt: number = tick();
    lib.runtime.events[event]:Once(function(...) resdata = {...} end);
    repeat task.wait() until (resdata or tonumber(timeout) and (tick() - requestedAt) > timeout);
    if not resdata then 
        return nil;
    end;
    return unpack(resdata);
end;

lib.whitelist.get = function(self: whitelistobject, attribute: number | nil, plr: Player | nil): (any)
    local player: Player = typeof(plr) == 'Instance' and plr.ClassName == 'Player' and plr or lplr;
    local whitelistdata: whitelistattributes = constructor.cache.whitelist[player.UserId] or {
        rank = 'BASIC',
        attackable = true,
        priority = 1,
        tagtext = '',
        tagcolor = 'FFFFFF',
        taghidden = true,
        autokick = false,
        prefix = ';'
    };
    local whitelistattributes: table = {
        [1] = 'rank',
        [2] = 'attackable',
        [3] = 'priority',
        [4] = 'tagtext',
        [5] = 'tagcolor',
        [6] = 'taghidden',
        [7] = 'autokick',
        [8] = 'prefix'
    };
    local attribute: string = whitelistattributes[attribute] or 'rank';
    if whitelistdata[attribute or 1] == nil then 
        return 'BASIC';
    end;
    return whitelistdata[attribute or 1];
end;

lib.whitelist.registercommand = function(self: whitelistobject, name: string, free: boolean, func: () -> any)
    if typeof(func) == 'function' then 
        constructor.commands[name or ''] = {callback = func, free = free};
    end;
end;

constructor.refreshwhitelist = function(): (boolean)
    local _: boolean, whitelist: table | string = pcall(function()
        local res: httpresponseobject = lib.http:request({path = 'whitelist/json'});
        if res.body:find('worker') == nil and res.body:find('exception') == nil then 
            local gotheader: boolean = false;
            for i: string in res.headers do 
                if i:upper() == 'X-RES-HASH' then 
                    gotheader = true;
                end;
            end;
            if not gotheader then 
                task.spawn(constructor.filecrashreport, constructor, 'TAINTED AUTHENTICATION', 298);
                task.wait();
                while true do end;
            end;
        end;
        return res.json();
    end);
    if typeof(whitelist) == 'table' then 
        for i: number, v: whitelistattributes in whitelist do
            if v.account == nil then 
                continue;
            end;
            local player: Player = getplayer(v.account);
            if player then 
                lib:removeplayertag(player);
                v.account = nil;
                v.priority = lib.whitelist.ranks[v.rank or 'BASIC'] or 1;
                constructor.cache.whitelist[player.UserId] = v;
                if player ~= lplr and v.autokick then 
                    task.spawn(lplr.Kick, lplr, `A render {(v.rank or 'premium'):lower()} member has requested a client disconnect.`);
                end;
                if not v.taghidden then 
                    task.spawn(function()
                        repeat task.wait() until shared.VapeFullyLoaded;
                        pcall(lib.tagplayer, lib, player, v.tagtext, v.tagcolor)
                    end)
                end;
            end;
        end;
        lib.whitelist.state = 1;
    end;
    return _
end;

constructor.getexecutorID = function(): (number)
    local _: boolean, platform: EnumItem | string = pcall(function()
        return getservice('UserInputService'):GetPlatform();
    end);
    if executor:lower():find('solara') then 
        return 1 
    end;
    if executor:lower():find('fluxus') then 
        return 2
    end;
    if executor:lower():find('codex') then 
        return 3 
    end;
    if executor:lower():find('arceus') then 
        return 4 
    end;
    if executor:lower():find('delta') then
        if _ then 
            if platform == Enum.Platform.IOS then 
                return 11 
            end;
            return 5;
        end;
    end;
    if executor:lower():find('hydrogen') then 
        if platform == Enum.Platform.OSX then 
            return 7 
        end;
        return 6    
    end;
    if executor:lower():find('vega') then 
        return 8 
    end;
    if executor:lower():find('wave') or executor:lower():find('ocean') then 
        return 9
    end;
    if executor:lower():find('macsploit') then 
        return 10 
    end;
    if executor:lower():find('cubix') then 
        if platform == Enum.Platform.IOS then 
            return 12 
        end;
        return 13
    end;
    if executor:lower():find('appleware') then 
        return 14
    end;
    if executor:lower():find('synapse z') then 
        return 15
    end;
    if executor:lower():find('rebel') then 
        return 16
    end;
    if executor:find('nezur') then 
        return 17
    end;
    if executor:find('salad') then 
        return 18;
    end;
    return 0;
end;

lib.http.getfile = function(self: httpobject, file: string, online: boolean): string
    local response: httpresponseobject = isfile(`rendervape/{file}`) and (not online) and {ok = true, body = readfile(`rendervape/{file}`)} or self:request({
        path = file, 
        subdomain = 'storage'
    });
    if not response.ok then 
        return error(`❌ [Render Constructor] - Failed to download {file} ({response.status})`)
    end;
    betterwritefile(`rendervape/{file}`, response.body);
    return response.body
end;

getgenv().writefile = newcclosure(function(path: string, contents: string): ()
    if contents:lower():find('shared.rendervape') then
        contents = 'error("Failed to intiate local configuration (3)")';
    end;
    return oldwritefile(path, contents);
end);

if getrawmetatable then 
    local oldrawmeta: ((table) -> (table | nil)) = clonefunction(getrawmetatable);
    getgenv().getrawmetatable = newcclosure(function(tab: table): (table | nil)
        if tab == lib or tostring(tab) == '⚠️ Render constructed table.' then 
            return blanktable;
        end;
        return oldrawmeta(tab);
    end);
end;

pcall(function()
    local oldtableforeach: (tab: table, func: (any, any) -> (...any)) -> ();
    oldtableforeach = hookfunction(table.foreach, newcclosure(function(tab: table, func: (any, any) -> (...any))
        if tostring(tab) == '⚠️ Render constructed table.' then 
            func('new', getmetatable(tab).new or function() end);
            return;
        end;
        return oldtableforeach(tab, func);
    end));
end);

table.insert(constructor.cache.threads, task.spawn(function()
    repeat
        local successful: boolean, result: boolean | string = pcall(constructor.refreshwhitelist);
        print(successful)
        constructor:fireconnections('WhitelistRefreshRequest', successful and result or nil);
        task.wait(15)
    until false
end));

table.insert(constructor.cache.threads, task.spawn(function()
    repeat task.wait() until getgenv().render;
    repeat
        task.spawn(pcall, function()
            local signint: string = tostring(Random.new():NextNumber(1, 1e3));
            local res: httpresponseobject = lib.http:request({
                path = 'authenticate',
                headers = {key = signint, op = tostring(Random.new():NextNumber(1, 10))},
                params = {
                    {name = 'ria', value = getgenv().ria or 'lol'},
                    {name = 'account', value = lplr.UserId},
                    {name = 'agent', value = constructor.getexecutorID()},
                    {name = 'hwid', value = gethwid()},
                    {name = 'gameplay', value = game.JobId},
                    {name = 'game', value = game.PlaceId}
                }
            });
           if not pcall(function()
                local gotheader: boolean = false;
                for i: string, v: string in res.headers do 
                    if i:upper() == 'X-RES-HASH' and v == signint then 
                        gotheader = true;
                    end;
                end;
                if not gotheader then 
                    task.spawn(constructor.filecrashreport, constructor, 'TAINTED AUTHENTICATION', 291);
                    task.wait();
                    while true do end;
                end;
                return true;
            end) then while true do end end;
            executescript(res.body:gsub('shared.GuiLibrary', 'shared.rendervape'))();
            lib.authenticated = true;
            constructor:fireconnections('AuthenticationRequest');
        end)
        task.wait(13)
    until (not getgenv().render)
end));

table.insert(constructor.cache.threads, task.spawn(function()
    repeat task.wait() until getgenv().render;
    repeat 
        local player: Player, message: string = render.events.message.Event:Wait();
        local args: table = message:split(' ');
        local args2: table = {};
        for i: number, v: string in args do 
           if i > 2 then 
              args2[i] = v;
           end;
        end;
        if args[1] == `{lib.whitelist:get(8)}cmds` and lib.whitelist:get(3) > 1 and player == lplr then 
            for i: string in constructor.commands do 
                pcall(function()
                    if textchat.ChatVersion == Enum.ChatVersion.TextChatService then 
                        textchat.TextChannels.RBXGeneral:DisplaySystemMessage(i);
                    else
                        startergui:SetCore('ChatMakeSystemMessage', {Text = i, Font = Enum.Font.GothamMedium, FontSize = Enum.FontSize.Size18, Color = Color3.new(1, 1, 1)});
                    end;
                end);
            end;
            continue;
        end;
        for i: string, v: {callback: () -> any, free: boolean?} in constructor.commands do 
            if args[1] == `{lib.whitelist:get(8, player)}{i:lower()}` and lib.whitelist:get(3, player) > lib.whitelist:get(3) and not v.free then 
                task.spawn(v.callback, args2)
            end;
            if v.free and args[1] == `{lib.whitelist:get(8, player)}{i:lower()}` and player == lplr then 
                task.spawn(v.callback, args2)
            end
        end;
    until false
end));

table.insert(constructor.cache.threads, task.spawn(function()
    repeat
        local success: boolean, response: table | string = pcall(function()
            return lib.http:request({path = 'startup'}).json()
        end);
        if success then
            constructor:fireconnections('StartupDataFetched', success and response or nil);
        end;
        if success and response.announcement and response.announcement.ID ~= ({pcall(readfile, 'rendervape/configuration/lastAnnouncement.rvc')})[2] then 
            if pcall(constructor.announce, response.announcement.text:gsub('{name}', lplr.DisplayName), response.announcement.duration) then 
                betterwritefile('rendervape/configuration/lastAnnouncement.rvc', response.announcement.ID)
            end;
        end;
        if success and response.disabled then 
            print('disabled')
        end;
        task.wait(25);
    until false
end));

table.insert(constructor.cache.threads, task.spawn(function()
    local oldwhitelistfunc: (number?, Player?) -> (any) = lib.whitelist.get;
    local oldrequestfunc: (httprequestrargs) -> (httpresponseobject) = lib.http.request;
    repeat
        if isfunchooked(oldwhitelistfunc) or tostring(lib.whitelist) ~= '⚠️ Render constructed table.' or lib.whitelist.get ~= oldwhitelistfunc then 
            task.spawn(constructor.filecrashreport, constructor, 'TAINTED CONSTURCTOR', 432);
            task.wait();
            while true do end;
        end;
        if isfunchooked(oldrequestfunc) or tostring(lib.http) ~= '⚠️ Render constructed table.' or lib.http.request ~= oldrequestfunc then 
            task.spawn(constructor.filecrashreport, constructor, 'TAINTED CONSTURCTOR', 431);
            task.wait();
            while true do end;
        end;
        if not iscclosure(request) then 
            task.spawn(constructor.filecrashreport, constructor, 'TAINTED GLOBAL FUNCS', 430);
            task.wait();
            getgenv().httprequest = function() end;
            while true do end;
        end;
        if not iscclosure(gethwid) then 
            task.spawn(constructor.filecrashreport, constructor, 'TAINTED GLOBAL FUNCS', 302);
            task.wait();
            while true do end;
        end;
        if getrawmetatable and not iscclosure(getrawmetatable) then 
            task.spawn(constructor.filecrashreport, constructor, 'TAINTED GLOBAL FUNCS', 302);
            task.wait();
            while true do end;
        end;
        task.wait();
    until false;
end));

task.spawn(function()
    repeat 
        if shared.VapeFullyLoaded then 
            getgenv().httprequest = function(url: string): (string)
                return game:HttpGet(url)
            end;
            break;
        end;
        task.wait();
    until false;
end);

constructor.__metatable = {new = function() end};
return lib;
