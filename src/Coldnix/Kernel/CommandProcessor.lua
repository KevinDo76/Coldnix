--all commands code are stored in lua file udner the %commandDir% folder that's going to be check and loaded on start up
_G.commandAPI={}
commandAPI.noCommandProcess=false
local commandDir="/Coldnix/Commands"
local keepinmem=tonumber(config.configList.LOADCOMMANDCODEINTOMEM)
local commandDirList=BOOTDRIVEPROXY.list(commandDir) or {}
local validCommands={}
for i=1,#commandDirList do
    local file=loadfile(commandDir.."/"..commandDirList[i])()
    if file.name and file.description and file.name and file.id then
        Log.writeLog("Valid command: "..file.name)
        if keepinmem==1 then
            validCommands[file.name]={file.name,file.description,file,file.id}
        else
            validCommands[file.name]={file.name,file.description,commandDirList[i],file.id}
        end
        print("loaded \""..commandDir.."/"..file.name.."\"")
    else
        print("failed to load "..commandDir.."/"..commandDirList[i])
        Log.writeLog("failed to load "..commandDir.."/"..commandDirList[i])
    end
    commandAPI.validCommands=validCommands
end
local function response(rawText)
    if not commandAPI.noCommandProcess and rawText~="^C" and rawText~="^X" then
        local splitText=string.split(rawText," ")
        local commandName=splitText[1]
        if commandName~=nil then
            print(string.rep("^",math.min(#rawText+#terminal.prefix,terminal.width)))
            if validCommands[commandName] then
                if keepinmem==1 then
                    validCommands[commandName][3].func(rawText)
                else
                    local metadata=validCommands[commandName]
                    local file=loadfile(commandDir.."/"..metadata[3])()
                    file.func(rawText)
                end
            else 
                print('Unknown command "'..commandName..'", use "help" for a list of avaliable commands')
            end
        end
    end
end
if terminal then
    terminal.commandProcessor = response
end