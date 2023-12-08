local args = {...}
local driveAddress=args[1]
local drive = component.proxy(driveAddress)
local editorFilePath = args[2]
local filetxt=System.readfile(editorFilePath,drive)
local yoffset=1
local x,y=BOOTGPUPROXY.getResolution()
local gpu=BOOTGPUPROXY
local rx,ry = gpu.getResolution()
local cursorSymbol = "⎸"
local lineChunk = {}
BOOTGPUPROXY.set(1,1,"loading")
_G.controlDown=false
_G.running=true
_G.cstate=true --Cursor blink state
--------------------------------
local lastcx=1
local lastcy=1
local cx=1 --Cursor real x Position, start at 1
local cy=1 --Cursor real y Position, start at 1

local renderx=0
local rendery=0

if args[3] then
    cursorSymbol="☭" --great joke
end 
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

--textbox movement check functions
local function checkRenderxBound()
    local currentX=math.clamp(cx,1,#(lineChunk[cy] or "")+1)-renderx
    if (currentX>x or currentX-3<1) then
        if renderx+3>#lineChunk[cy] then
            renderx = math.max(0,#lineChunk[cy]-3)
        elseif cx+1>renderx+x then
            renderx = math.min(cx+1-x,#lineChunk[cy]-3)
        end
    end
end

local function cursorBlink()
    _G.cstate = not _G.cstate
end

local function inputHandle(componentId,asciiNum,keyboardcode)
    if keyboardcode==208 then
        cy=math.clamp(cy,1,#lineChunk) --clamp before move
        cy=math.clamp(cy+1,1,#lineChunk) --clamp after move
        checkRenderxBound()
        
    elseif keyboardcode==200 then
        cy=math.clamp(cy,1,#lineChunk)
        cy=math.clamp(cy-1,1,#lineChunk)
        checkRenderxBound()
    elseif keyboardcode==205 then
        cx=math.clamp(cx,1,#lineChunk[cy]+1)
        if cx - renderx + 1>x then
            renderx = renderx + 1
        end
        if cx>#lineChunk[cy] then
            cy=math.clamp(cy+1,1,#lineChunk)
            cx=0
            renderx = 0
        end
        cx=math.clamp(cx+1,1,#lineChunk[cy]+1)
    elseif keyboardcode==203 then
        cx=math.clamp(cx,1,#lineChunk[cy]+1)
        if cx-2<renderx then
            renderx = math.max(renderx - 1,0)
        end
        if cx==1 then
            if cy-1~=0 then
                cx=#lineChunk[cy-1]+2
                renderx = math.max(cx-x-1,0)
            end
            cy=math.clamp(cy-1,1,#lineChunk)

        end
        cx=math.clamp(cx-1,1,#lineChunk[cy]+1)
    end
end

local function render()
    --window line breaking 
    BOOTGPUPROXY.setBackground(0x000000)
    BOOTGPUPROXY.setForeground(0xffffff)
    gpu.fill(1,1,x,y," ")
    gpu.set(1,1,tostring(renderx+x).." "..tostring(cx).." "..tostring(cy))
    

    if cy+yoffset-rendery>y then
        rendery = rendery + 1
    end
    if cy+yoffset-rendery<yoffset+1 then
        rendery = rendery - 1
    end

    for i=1,y do
        gpu.set(1,i+yoffset,string.sub(lineChunk[i+rendery] or "",renderx+1,renderx+1+rx))
    end

    if cstate then
        gpu.setBackground(0xffffff)
        gpu.setForeground(0x000000)
    else
        gpu.setBackground(0x000000)
        gpu.setForeground(0xffffff)
    end

    local controlledcx=math.clamp(cx,1,#(lineChunk[cy] or "")+1)-renderx
    local txt=gpu.get(controlledcx,math.clamp(cy+yoffset-rendery,1,y))
    gpu.set(controlledcx,math.clamp(cy+yoffset-rendery,1+yoffset,y), (cstate and (txt or "x")) or cursorSymbol)
    if lastcx~=cx or lastcy~=cy then
        lastcx=cx
        lastcy=cy
    end
end

--event registering
TaskScheduler.addTask("TextEditoCursorBlink",cursorBlink,0.2)

eventManager.regsisterListener("editdown","key_down",inputHandle)

eventManager.regsisterListener("editTermination","SIGTERM",function() _G.running=false end)

--main loop
lineChunk = parse(filetxt)--chopping the text file into lines stored in multiple index
while running do
    wait()
    render()
end
TaskScheduler.removeTask("TextEditoCursorBlink")
_G.controlDown=nil
_G.running=nil
_G.cstate=nil
eventManager.removeListener("editdown")
eventManager.removeListener("editup")
computer.beep(1000,0.1)
print("Closed")