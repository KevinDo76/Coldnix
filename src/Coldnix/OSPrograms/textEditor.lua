local args = {...}
local driveAddress=args[1]
local drive = component.proxy(driveAddress)
local editorFilePath = args[2]
print('opening "'..System.filesystem.getPrefixWorkingDir(driveAddress)..System.filesystem.sanitizePath(editorFilePath)..'"')
local filetxt=System.readfile(editorFilePath,drive)
local yoffset=1
local x,y=BOOTGPUPROXY.getResolution()
local gpu=BOOTGPUPROXY
terminal.stopProcess()
BOOTGPUPROXY.setBackground(0x000000)
BOOTGPUPROXY.setForeground(0xffffff)
BOOTGPUPROXY.fill(1,1,x,y," ")
_G.controlDown=false
_G.exit=false
--------------------------------
local lastcx=1
local lastcy=1
local cx=1
local cy=1
local cstate=true

local renderx=0
local rendery=0
--functions
local function parse(txt)
    local lineChunk=string.split(txt,"\r\n")
    local final={}
    --\n line breaking
    for i,v in ipairs(lineChunk) do
        local temp=string.split(v,"\n")
        for ii,vv in ipairs(temp) do
            final[#final+1] = vv
        end
    end
    return final
end

local lineChunk = parse(filetxt)--chopping the text file into lines stored in multiple index
--event registering
EventManager.regsisterListener("editdown","key_down",function(componentId,asciiNum,keyboardcode)
    if keyboardcode==29 then
        ControlDown=true
    elseif keyboardcode==46 and ControlDown then
        _G.exit=true 
    elseif keyboardcode==208 then
        cy=math.clamp(cy+1,0,y-1-yoffset)
    elseif keyboardcode==200 then
        cy=math.clamp(cy-1,0,y-1-yoffset)
    elseif keyboardcode==205 then
        cx=math.clamp(cx+1,0,#lineChunk[rendery+1+cy]+1)
    elseif keyboardcode==203 then
        cx=math.clamp(cx-1,0,#lineChunk[rendery+1+cy]+1)
    end
end)

EventManager.regsisterListener("editup","key_up",function(componentId,asciiNum,keyboardcode)
    if keyboardcode==29 then
        ControlDown=false
    end
end)

local function render()
    --window line breaking 
    BOOTGPUPROXY.setBackground(0x000000)
    BOOTGPUPROXY.setForeground(0xffffff)
    gpu.fill(1,1,x,y," ")
    for i=1,y do
        gpu.set(1,i+yoffset,lineChunk[i+rendery] or "")
    end
    if cstate then
        gpu.setBackground(0xffffff)
        gpu.setForeground(0x000000)
    else
        gpu.setBackground(0x000000)
        gpu.setForeground(0xffffff)
    end
    local controlledcx=math.clamp(cx,0,#lineChunk[rendery+1+cy]+1)
    local txt=gpu.get(controlledcx,cy+1+yoffset)
    gpu.set(controlledcx,cy+yoffset+1,txt)
    if lastcx~=cx or lastcy~=cy then
        lastcx=cx
        lastcy=cy
    end
end
--main loop
while not exit do
    wait()
    render()
end
EventManager.removeListener("editdown")
EventManager.removeListener("editup")
computer.beep(1000,0.1)
terminal.resumeProcess()