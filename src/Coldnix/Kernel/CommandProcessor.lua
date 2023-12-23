--all commands code are stored in lua file udner the %commandDir% folder that's going to be check and loaded on start up
_G.commandAPI={}
commandAPI.noCommandProcess=false
local commandDir="/Coldnix/Commands"
local keepinmem=tonumber(config.configList.LOADCOMMANDCODEINTOMEM)
local commandDirList=BOOTDRIVEPROXY.list(commandDir) or {}
local validCommands={}
local exeEnv = _G 
if config.configList.LOADCOMMANDSASKERNEL == "0" then exeEnv=SandBox end
for i=1,#commandDirList do
    local file=loadfile(commandDir.."/"..commandDirList[i],true,BOOTDRIVEPROXY,exeEnv)()
    if file.name and file.description and file.name and file.id then
        Log.writeLog("Valid command: "..file.name)
        if keepinmem==1 then
            validCommands[file.name]={file.name,file.description,file,file.id}
        else
            validCommands[file.name]={file.name,file.description,commandDirList[i],file.id}
        end
        print("[  " .. string.format( "%.2f", tostring (computer.uptime())) .."s  ] loaded \""..commandDir.."/"..commandDirList[i].."\"")
    else
        print("failed to load "..commandDir.."/"..commandDirList[i])
        Log.writeLog("failed to load "..commandDir.."/"..commandDirList[i])
    end
    commandAPI.validCommands=validCommands
end
local function response(rawText)
    terminal.CursorState = false
    terminal.typingEnable = false
    terminal.updateCursor()
    if not commandAPI.noCommandProcess and rawText~="^C" and rawText~="^X" then
        local splitText=string.split(rawText," ")
        local commandName=splitText[1]
        if commandName~=nil then
            print(string.rep("^",math.min(#rawText+#terminal.prefix,terminal.width)))
            if validCommands[commandName] then
                --registered event before execution
                local beforeEvent={}

                for i,v in pairs(eventManager.eventsList) do
                    beforeEvent[#beforeEvent+1] = i
                end
                --execution
                if keepinmem==1 then
                    local status = xpcall(
                        validCommands[commandName][3].func,
                        recordTraceback,
                        rawText
                    )
                    if not status then
                        KernelPanic(lastError,currentTraceback,true)
                    end
                else
                    local metadata=validCommands[commandName]
                    local file=loadfile(commandDir.."/"..metadata[3],true,BOOTDRIVEPROXY,exeEnv)()
                    local status = xpcall(file.func, recordTraceback, rawText)
                    if not status then
                        KernelPanic(lastError,currentTraceback,true)
                    end
                end

                for currentEvent,_ in pairs(eventManager.eventsList) do
                    if table.getIndex(beforeEvent, currentEvent)==-1 then
                        eventManager.removeListener(currentEvent)
                        print("Stray events removed:",currentEvent)
                    end
                end 

            else 
                print("Unknown command \""..commandName.."\", use \"help\" for a list of avaliable commands")
            end
        end
    end
    terminal.typingEnable = true
    terminal.CursorFlashFreeze=computer.uptime()+0.5
    terminal.updateCursor(true)
end
if terminal then
    terminal.commandProcessor = response
end