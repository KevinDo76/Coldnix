--provide the basic terminal/commandlines
--the "terminal" is going to be resizeable and moveable to allow flexibility in the future?
local rx,ry=BOOTGPUPROXY.getResolution()
_G.terminal={}
terminal.x=1
terminal.y=1
terminal.width=rx
terminal.height=ry
terminal.prefix="boot:"..currentWorkingDir..": "
terminal.screenHistory={}
terminal.CursorX=0
terminal.CursorState=false
terminal.CursorFlashFreeze=computer.uptime()
terminal.typeBarYOffset=0
terminal.typingEnable = true
terminal.commandProcessor = function (rawText) end
local processing=true
local moveDB=computer.uptime()
local typeBuffer=""
local typeHistory={}
local typeHisIndex=1
local maxHistorySize=terminal.height+200
local lastoffset=0
local pageScroll=0
local waitingForTextInput=false
--clearScreen
local rx,ry=BOOTGPUPROXY.getResolution()
BOOTGPUPROXY.fill(1,1,rx,ry," ")
--spacePadding to fill in the rest of the empty space with text to makes sure it overwrite the last line
terminal.padText = function(text,length)
    while #text<length do
        text=text.." "
    end
    return text
end
--internal print
local function lowPrint(text)
    if processing then
        text=terminal.padText(string.sub(text,1,terminal.width),terminal.width)
        local gpu=BOOTGPUPROXY
        gpu.setBackground(0x000000)
        gpu.setForeground(0xffffff)
        if terminal.y+terminal.height-2-terminal.typeBarYOffset>=terminal.y then
            gpu.copy(terminal.x,terminal.y+1,terminal.width,terminal.height-2-terminal.typeBarYOffset,0,-1)
            gpu.set(terminal.x,terminal.y+terminal.height-2-terminal.typeBarYOffset,text)
        end
    end
end
--print specifically for re rendering the screen
--global print
_G.print = function(...)
    CheckYield()
    local txt=""
    local args={...}
    if #args>0 then
        for i,v in pairs(args) do
            txt=txt..tostring(v).." "
        end
    else
        txt="nil "
    end
    while (string.find(txt,"\9")~=nil) do txt=string.gsub(txt,"\9","    ") end --replace all horizontal tab with spaces
    txt=string.sub(txt,1,#txt-1)
    local textChunk={}
    local finalChunk={}
    --linebreak
    textChunk=string.split(txt,"\n")
    
    for i,v in ipairs(textChunk) do
        repeat
            finalChunk[#finalChunk+1] = string.sub(v,1,terminal.width)
            v=string.sub(v,terminal.width+1,#v)
        until #v<1 
    end

    for i,v in ipairs(finalChunk) do
        --the inputted text might be too long to be displayed on the same line
        --chopping it up is needed
        terminal.screenHistory[#terminal.screenHistory+1] = v
        if #terminal.screenHistory>maxHistorySize then
            table.remove(terminal.screenHistory,1)
        end
        lowPrint(v)
    end
end
terminal.clearScreen = function()
    typeBuffer=""
    --typeHistory={}
    typeHisIndex=1
    terminal.CursorX=0
    terminal.screenHistory={}
    terminal.reload()
end
--terminal.reload() will clear out the terminal and force a re-render of everything
terminal.reload = function()
    if processing then
        local gpu=BOOTGPUPROXY
        local yoff=0
        gpu.setBackground(0x000000)
        gpu.setForeground(0xffffff)
        gpu.fill(terminal.x,terminal.y,terminal.width,terminal.height," ")
        local startp=#terminal.screenHistory
        local endp=#terminal.screenHistory-terminal.height+terminal.typeBarYOffset+2
        for i=startp,endp,-1 do
            if terminal.screenHistory[i]~=nil then
                --lowPrint(terminal.screenHistory[i])
                gpu.set(terminal.x,terminal.y+terminal.height-2-terminal.typeBarYOffset-yoff,terminal.screenHistory[i-pageScroll] or "")
                yoff=yoff+1
            end
        end
        terminal.CursorFlashFreeze=computer.uptime()+0.5
        terminal.updateTypeBar()
        terminal.updateCursor(true)
    end
end
--functions for changing sizes and position of the terminal
terminal.setSize = function (x,y)
    if processing then
        BOOTGPUPROXY.setBackground(0x000000)
        BOOTGPUPROXY.setForeground(0xffffff)
        BOOTGPUPROXY.fill(terminal.x,terminal.y,terminal.width,terminal.height," ")
        terminal.width=x
        terminal.height=math.max(y,2)
        terminal.reload()
    end
end

terminal.setPosition = function (x,y)
    if processing then
        BOOTGPUPROXY.setBackground(0x000000)
        BOOTGPUPROXY.setForeground(0xffffff)
        BOOTGPUPROXY.fill(terminal.x,terminal.y,terminal.width,terminal.height," ")
        terminal.x=x
        terminal.y=y
        terminal.reload()
    end
end

terminal.resumeProcess = function()
    processing = true
    TaskScheduler.resumeTask("StatusBarUpdate")
    TaskScheduler.resumeTask("CursorBlink")
    eventManager.resumeListener("TerminalInput")
    eventManager.resumeListener("TerminalClipboard")
    eventManager.resumeListener("TerminalScroll")
    terminal.reload()
end

terminal.stopProcess = function(clearScreen)
    processing = false
    TaskScheduler.pauseTask("StatusBarUpdate")
    TaskScheduler.pauseTask("CursorBlink")
    eventManager.pauseListener("TerminalInput")
    eventManager.pauseListener("TerminalClipboard")
    eventManager.pauseListener("TerminalScroll")
    if clearScreen then
        BOOTGPUPROXY.fill(terminal.x,terminal.y,terminal.width,terminal.height," ")
    end
end

terminal.getProcessState = function() 
    return processing
end

terminal.PanicReset = function(class)
    commandAPI.noCommandProcess=false
    waitingForTextInput = false
    terminal.prefix=System.filesystem.getPrefixWorkingDir()..currentWorkingDir..": "
    terminal.resumeProcess()
    if class==0 then
        Log.writeLog(">>>Terminal panic reloaded<<<")
        print(">>>Terminal panic reloaded<<<")
    elseif class==1 then
        print(">>>Task force terminated<<<")
    end
end

----------------------------------
--this part down here will handle keyboards event for the terminal
--function for typing
terminal.updateTypeBar = function ()
    if processing then
        local gpu=BOOTGPUPROXY
        local txt=terminal.prefix..typeBuffer
        local lineCount=math.max(math.floor((#txt)/terminal.width),0)
        if lineCount~=lastoffset then
            terminal.typeBarYOffset=lineCount
            lastoffset=lineCount
            terminal.ChangeTypeArea(lineCount)
        end
        local textChunk={}
        repeat
            textChunk[#textChunk+1] = string.sub(txt,1,terminal.width)
            txt=string.sub(txt,terminal.width+1,#txt)
        until #txt<1
        gpu.setBackground(0x000000)
        gpu.setForeground(0xffffff)
        for i=math.max(terminal.typeBarYOffset-terminal.height+2,1),terminal.typeBarYOffset+1 do
            gpu.set(terminal.x,terminal.y+terminal.height-1-terminal.typeBarYOffset+(i-1),terminal.padText(textChunk[i] or "",terminal.width))
        end
    end
end

terminal.updateCursor = function (state)
    if processing then
        terminal.CursorState=state
        local gpu=BOOTGPUPROXY
        gpu.setBackground(0x000000)
        gpu.setForeground(0xffffff)
        local cursorPos=terminal.CursorX+#terminal.prefix
        local lineOffset=math.floor(((cursorPos)/terminal.width))
        local lineOx=cursorPos-(lineOffset*terminal.width)
        local cx=math.clamp(lineOx+terminal.x,terminal.x,terminal.x-1+terminal.width)
        local cy=math.clamp(terminal.y+terminal.height-1-terminal.typeBarYOffset+lineOffset,terminal.y,ry)
        local text=gpu.get(cx,cy)
        --local text=" "
        if state and terminal.typingEnable then
            gpu.setBackground(0xffffff)
            gpu.setForeground(0x000000)
        end
        gpu.set(cx,cy,text)
    end
end

terminal.type = function (txt)
    if terminal.typingEnable then
        typeBuffer=string.sub(typeBuffer,1,terminal.CursorX)..txt..string.sub(typeBuffer,terminal.CursorX+1,#typeBuffer)
        terminal.CursorX=terminal.CursorX+#txt
        terminal.CursorFlashFreeze=computer.uptime()+0.5
        terminal.updateTypeBar()
        terminal.updateCursor(true)
    end
end

terminal.delete = function()
    if terminal.CursorX>0 then
        typeBuffer=string.sub(typeBuffer,1,terminal.CursorX-1)..string.sub(typeBuffer,terminal.CursorX+1,#typeBuffer)
    end
    terminal.updateCursor(false)
    terminal.CursorX=math.max(terminal.CursorX-1,0)
    terminal.CursorFlashFreeze=computer.uptime()+0.5
    terminal.updateTypeBar()
    terminal.updateCursor(true)
end

terminal.clearType = function()
    typeBuffer=""
    terminal.updateTypeBar()
    terminal.CursorFlashFreeze=computer.uptime()+0.5
    terminal.updateCursor(true)
end

terminal.input = function (prefix)
    if processing then
        waitingForTextInput = true
        local previousTypingState = terminal.typingEnable
        local previousPrefix=terminal.prefix
        terminal.prefix=prefix or ""
        terminal.updateTypeBar()
        terminal.typingEnable = true
        terminal.CursorFlashFreeze=computer.uptime()+0.5
        terminal.updateCursor(true)
        while wait(0.01) do
            if waitingForTextInput==false then
                break
            end
        end
        terminal.prefix=previousPrefix
        terminal.updateTypeBar()
        terminal.CursorFlashFreeze=computer.uptime()+0.5
        terminal.updateCursor(true)
        terminal.typingEnable = previousTypingState
        return typeHistory[#typeHistory]
    else
        return ""
    end
end

terminal.enter = function()
    local t=typeBuffer
    typeBuffer=""
    print(terminal.prefix..t)
    if pageScroll>0 then
        pageScroll=0
        terminal.reload()
    end
    terminal.CursorX=0
    terminal.updateTypeBar()
    terminal.updateCursor(true)
    typeHistory[#typeHistory+1]=t
    if #typeHistory>20 then
        table.remove(typeHistory,1)
    end
    typeHisIndex=#typeHistory+1
    if not waitingForTextInput then
        terminal.commandProcessor(t)
    else
        waitingForTextInput=false
    end
end

terminal.moveCursor = function (offset)
    local beforeState=terminal.CursorState
    terminal.updateCursor(false)
    terminal.CursorX=math.clamp(terminal.CursorX+offset,0,#typeBuffer)
    terminal.updateCursor(beforeState)
end

terminal.ChangeTypeArea = function (num)
    terminal.typeBarYOffset = num
    terminal.reload()
end
--setting up a task for blinking cursor
local function cursorBlink()
    if computer.uptime()>=terminal.CursorFlashFreeze then
        terminal.updateCursor(not terminal.CursorState)
    end
end
--adding task
TaskScheduler.addTask("CursorBlink",cursorBlink,0.2)
--regsistering keyboard event
eventManager.regsisterListener("TerminalInputTermination","SIGTERM",function() 
    waitingForTextInput=false
end)

eventManager.regsisterListener("TerminalInputForceTermination","SIGKILL",function() 
    waitingForTextInput=false
end)

eventManager.regsisterListener("TerminalScroll","scroll",function(componentId,x,y,direction)
    if direction>0 then
        if pageScroll<#terminal.screenHistory-terminal.height+1+terminal.typeBarYOffset then
            pageScroll=pageScroll+1
            terminal.reload()
        end
    else
        if pageScroll>0 then
            pageScroll=pageScroll-1
            terminal.reload()
        end
    end
end)

eventManager.regsisterListener("TerminalInput","key_down",function(componentId,asciiNum,keyboardcode)
    if asciiNum>=32 and asciiNum<=126 then
        terminal.type(string.char(asciiNum))
    end
    if keyboardcode==14 then
        terminal.delete()
    end
    if keyboardcode==205 then
        if moveDB<=computer.uptime() then
            moveDB=computer.uptime()+0.02
            terminal.CursorFlashFreeze=computer.uptime()+0.5
            terminal.updateCursor(true)
            terminal.moveCursor(1)
        end
    end
    if keyboardcode==203 then
        if moveDB<=computer.uptime() then
            moveDB=computer.uptime()+0.02
            terminal.CursorFlashFreeze=computer.uptime()+0.5
            terminal.updateCursor(true)
            terminal.moveCursor(-1)
        end
    end
    if keyboardcode==28 then
        terminal.enter()
    end
    if keyboardcode==200 then
        if #typeHistory>0 and typeHisIndex>1 then
            typeHisIndex=math.max(typeHisIndex-1,1)
            local text=typeHistory[typeHisIndex]
            terminal.clearType()
            terminal.type(text or "")
            terminal.updateCursor(false)
            terminal.CursorX=#text
            terminal.CursorFlashFreeze=computer.uptime()+0.5
            terminal.updateCursor(true)
        end
    end
    if keyboardcode==208 then
        if #typeHistory>0 and typeHisIndex<#typeHistory then
            typeHisIndex=math.min(typeHisIndex+1,#typeHistory)
            local text=typeHistory[typeHisIndex]
            terminal.clearType()
            terminal.type(text or "")
            terminal.updateCursor(false)
            terminal.CursorX=#text
            terminal.CursorFlashFreeze=computer.uptime()+0.5
            terminal.updateCursor(true)
        end
    end
    if keyboardcode==199 then
        terminal.updateCursor(false)
        terminal.CursorX=0
        terminal.CursorFlashFreeze=computer.uptime()+0.5
        terminal.updateCursor(true)
    end
    if keyboardcode==207 then
        terminal.updateCursor(false)
        terminal.CursorX=#typeBuffer
        terminal.CursorFlashFreeze=computer.uptime()+0.5
        terminal.updateCursor(true)
    end
    if keyboardcode==201 then
        if pageScroll<#terminal.screenHistory-terminal.height+1+terminal.typeBarYOffset then
            pageScroll=pageScroll+1
            terminal.reload()
        end
    end
    if keyboardcode==209 then
        if pageScroll>0 then
            pageScroll=pageScroll-1
            terminal.reload()
        end
    end

    if keyboardcode==15 then
        local commandChunk = System.utility.getArgs(typeBuffer)
        local attemptLookUpChunk = commandChunk[#commandChunk]

        --local driveAddress,filepath,driveSearchSucc,drivelookup = System.filesystem.resolveDriveLookup()
    end
end)

eventManager.regsisterListener("TerminalClipboard","clipboard", function(_,text) 
    terminal.type(text)
end)
--final init 
terminal.updateTypeBar()
terminal.updateCursor()
print("Boot Terminal Removed")
print("Main Terminal Started")

--terminal.setPosition(1,10)
--terminal.setSize(80,7)
