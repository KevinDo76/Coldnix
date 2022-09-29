--all commands code are stored in lua file udner the %commandDir% folder that's going to be check and loaded on start up
_G.commandAPI={}
local commandDir="/Coldnix/Commands"
local keepinmem=tonumber(config.configList.LOADCOMMANDCODEINTOMEM)
local commandDirList=BOOTDRIVEPROXY.list(commandDir) or {}
local validCommands={}
for i=1,#commandDirList do
    local file=loadfile(commandDir.."/"..commandDirList[i])()
    if file.name and file.description and file.name then
        Log.writeLog("Valid command: "..file.name)
        if keepinmem==1 then
            validCommands[file.name]=file
        else
            validCommands[file.name]={file.name,file.description,commandDirList[i]}
        end
    else
        print("failed to load "..commandDir.."/"..commandDirList[i])
        Log.writeLog("failed to load "..commandDir.."/"..commandDirList[i])
    end
    commandAPI.validCommands=validCommands
end
local function response(rawText)
    local splitText=string.split(rawText," ")
    local commandName=splitText[1]
    print(" ")
    if validCommands[commandName] then
        if keepinmem==1 then
            validCommands[commandName].func(rawText)
        else
            local metadata=validCommands[commandName]
            local file=loadfile(commandDir.."/"..metadata[3])()
            file.func(rawText)
        end
    end
end

terminal.commandProcessor = response