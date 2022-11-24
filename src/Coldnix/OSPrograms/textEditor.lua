print('opening "'..editorFilePath..'"')
local filetxt=System.readfile(editorFilePath)
local yoffset=1
local x,y=BOOTGPUPROXY.getResolution()
local gpu=BOOTGPUPROXY
terminal.stopProcess()
BOOTGPUPROXY.setBackground(0x000000)
BOOTGPUPROXY.setForeground(0xffffff)
BOOTGPUPROXY.fill(1,1,x,y," ")
_G.controlDown=false
_G.exit=false
--event registering
EventManager.regsisterListener("editdown","key_down",function(componentId,asciiNum,keyboardcode)
    if keyboardcode==29 then
        ControlDown=true
    elseif keyboardcode==46 and ControlDown then
        _G.exit=true 
    end
end)

EventManager.regsisterListener("editup","key_up",function(componentId,asciiNum,keyboardcode)
    if keyboardcode==29 then
        ControlDown=false
    end
end)
--functions
local function render()
    --window line breaking 
    local lineChunk=string.split(filetxt,"\r\n")
    local tempChunk={}
    --\n line breaking
    for i,v in ipairs(lineChunk) do
        local temp=string.split(v,"\n")
        for ii,vv in ipairs(temp) do
            tempChunk[#tempChunk+1] = vv
        end
    end
    for i,v in ipairs(lineChunk) do
        gpu.set(1,i+yoffset,lineChunk[i])
    end
end
--main loop
while not exit do
    wait(0.01)
    render()
end
computer.beep(1000,0.1)
terminal.resumeProcess()