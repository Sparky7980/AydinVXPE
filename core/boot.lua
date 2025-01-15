local getgenv: () -> () = getgenv or function()
	return shared;
end;

local cloneref: (Instance) -> (Instance) = cloneref or function(instance)
	return instance;
end;

assert(request, '❌ Render Bootstrapper - "request" function is missing, please try another executor.');

local clonefunction: ((...any) -> (...any)) -> ((...any) -> (...any)) = clonefunction or function(func)
    return func;
end;

local encoded: table = cloneref(game:FindService('HttpService')):JSONDecode([[{"A": "8E98344E0F", "a": "821563E632", "B": "04D2721E44", "b": "8CD746A289", "C": "15D6587BB3", "c": "8711027A9E", "D": "7AE2050EA9", "d": "3F2DA4F48A", "E": "BD68D1BA8C", "e": "8E839A25FF", "F": "B19EBE9608", "f": "048E4987E4", "G": "205ED9F9AC", "g": "0B4CC2FD18", "H": "D1F07E3862", "h": "A8CEBD5C87", "I": "FB777392FB", "i": "C7E406BF2C", "J": "A79AA2F824", "j": "7F74C0BEC6", "K": "5EF1E54A1D", "k": "071C3B5920", "L": "7F9689A639", "l": "64789050D6", "M": "730CDE4050", "m": "9A1BB4BED0", "N": "2A8653B3F0", "n": "FDF1670638", "O": "7AE2DD8A23", "o": "1F46EBECCF", "P": "20EF8024E4", "p": "4B12498EBF", "Q": "59BF022087", "q": "B59A70B75E", "R": "C98F07A1DB", "r": "3948F9C560", "S": "DD5286D213", "s": "DBAAC71633", "T": "4D861B53EB", "t": "E8FB75A581", "U": "0510FE0E33", "u": "B67A2DE277", "W": "1B974228F8", "w": "057E975391", "X": "99DC91BE20", "x": "DD559CA3D0", "Y": "38D9AB61ED", "y": "BEDF66DFF1", "Z": "5463DD99E1", "z": "E454082DD2", " ": "F0BFFD93EB"}]])

local decrypt = function(data: string): (string)
    for i: number, v: string in encoded do 
        data = data:gsub(v, i);
    end;
    return data;
end;

local players: Players = cloneref(game:FindService('Players'));
local executescript = clonefunction(loadstring);
local corefiles: table = {
	'rendervape/core/initiate.lua',
	'rendervape/core/universal.lua',
	'rendervape/core/gui.lua',
	'rendervape/libraries/constructor.lua',
	'ria.ren'
};

for i: number, v: string in corefiles do 
	if not isfile(v) then 
		return error(`❌ Render Bootstrapper - {v:gsub('rendervape', '')} is missing/corrupt. Please reinstall render.`)
	end;
end;

if players.LocalPlayer == nil then 
	players:GetPropertyChangedSignal('LocalPlayer'):Wait();
end;

repeat task.wait() until players.LocalPlayer:FindFirstChildOfClass('PlayerScripts') and players.LocalPlayer:FindFirstChildOfClass('PlayerGui');

local renderlib: table = RenderLibrary or loadfile('rendervape/libraries/constructor.lua')();
shared.renderconstructor = renderlib;

getgenv().ria = readfile('ria.ren')

getgenv().requirefile = function(url: string): string
	local code: string = renderlib.http:request({subdomain = 'storage', path = url:gsub('https://storage.renderintents.lol/', ''):gsub('http://storage.renderintents.lol/', ''):gsub('rendervape/', '')}).body;
    return executescript(decrypt(code))();    
end;

return loadfile('rendervape/core/initiate.lua')();
