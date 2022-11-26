local configLocation="/Coldnix/Data/config.txt"
_G.config={}
local defaultConfigFile=
[==[OSVERSION=0.0.1
OSNAME=Coldnix
TERMINALHOFF=-3
STATUSBARUPDATERATE=0.25
COMMANDSDIRECTORY=/OS/Commands
MAXUSERTYPEHISTORY=25
LOADCOMMANDCODEINTOMEM=1
HELPCOMMANDPERPAGE=5]==]
--functions
_G.config.reflashConfig = function ()
    System.writefile(configLocation,defaultConfigFile)
    for i=10,1,-1 do
        local x,y=BOOTGPUPROXY.getResolution()
        BOOTGPUPROXY.fill(1,1,x,y," ")
        BOOTGPUPROXY.set(1,1,"FAILED TO LOAD CONFIG FILE, IT'S EITHER MISSING OR CORRUPTED "..i.."..")
        computer.beep(1000,0.1)
        wait(0.9)
    end
    computer.shutdown(true)
end

local function decodeConfig(rawConfig)
    local splitStage1=string.split(rawConfig,"\n")
    local finalConfig={}
    for i,v in pairs(splitStage1) do
        local splitStage2=string.split(v,"=")
        finalConfig[splitStage2[1]]=splitStage2[2]
    end
    return finalConfig
end
--loading the config file for processing
local configFile,succ=System.readfile(configLocation)
if succ then
   _G.config.configList=decodeConfig(configFile)
   local corrupted=false
   for i,v in pairs(decodeConfig(defaultConfigFile)) do
        if _G.config.configList[i]==nil then
            config.reflashConfig()
        end
   end
else
    config.reflashConfig()
end

