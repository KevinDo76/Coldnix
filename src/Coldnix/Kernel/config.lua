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
HELPCOMMANDPERPAGE=5
OSDRIVENAMELENGTH=4
LOADCOMMANDSASKERNEL=0
]==]
--simplefileoperation
local writefile = function (path,data,drive)
    drive = drive or BOOTDRIVEPROXY
    if not drive.isReadOnly() then
        local file=drive.open(path,"w")
        return drive.write(file,data)
    else
        print("System File Operation Error, Drive is read only")
    end
end

local readfile = function(path,driveproxy)
    driveproxy=driveproxy or BOOTDRIVEPROXY
    if driveproxy.exists(path) and not driveproxy.isDirectory(path) then
        local file=driveproxy.open(path)
        local finalEx=""
        repeat 
            local currentLoad=driveproxy.read(file,math.huge)
            finalEx=finalEx..(currentLoad or "")
        until not currentLoad
        return finalEx,true
    else
        return "",false
    end
end
--functions
_G.config.reflashConfig = function ()
    writefile(configLocation,defaultConfigFile)
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
local configFile,succ=readfile(configLocation)
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

