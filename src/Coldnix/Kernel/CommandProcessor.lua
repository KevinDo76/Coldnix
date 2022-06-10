--all commands code are stored in lua file udner the %commandDir% folder that's going to be check and loaded on start up
local commandDir="/Coldnix/Commands"
local keepinmem=config.configList.LOADCOMMANDCODEINTOMEM
local commandDirList=BOOTDRIVEPROXY.list(commandDir) or {}
local validCommands={}
for i=1,#commandDirList do
    
end
local function response(rawText)
    
end

terminal.commandProcessor = response