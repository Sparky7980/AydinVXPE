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
   lib/promise.lua - SystemXVoid/BlankedVoid         
   https://renderintents.xyz                                                                                                                                                                                                                                                                     
]]
   

type Promise = {
    andThen: (table) -> any,
    cancel: (table) -> (),
    sync: (table) -> ()
};

local Promise: table = {};

function Promise.new(func: () -> any, ...): Promise
    local args: table = {...};
    local resgotten: boolean, resdata: table = false, {};
    local promisethreads: table = {};
    local andthenfunc: () -> () = function() end;
    local promisecancelled: boolean = false;

    table.insert(promisethreads, task.spawn(function()
        resdata = {func(unpack(args))};
        resgotten = true;
        task.spawn(andthenfunc, unpack(resdata))
    end));

    return setmetatable({}, {
        __index = {
            andThen = function(self: table, func: () -> any)
                assert(func == nil or typeof(func) == 'function', `Promise expects function for the first argument, got {typeof(func)}.`)
                andthenfunc = func;
            end,
            cancel = function(self: table)
                for i,v in promisethreads do 
                    pcall(task.cancel, v);
                    promisethreads[i] = nil;
                end;
                for i: number, v: () -> any in self do 
                    print(i)
                    self[i] = function()
                        return error('This Promise has been cancelled and is not usable.')
                    end
                end
            end,
            sync = function(self: table)
                if not resgotten then 
                    repeat task.wait() until resgotten
                end;
                return unpack(resdata)
            end
        }
    })
end;

getgenv().Promise = promise;
return Promise