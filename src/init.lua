--Coldnix bootloader
local BOOTDRIVEADDRESS=computer.getBootAddress()
local BOOTDRIVEPROXY=component.proxy(BOOTDRIVEADDRESS)
local initFilePath = "/boot.lua"
local waitForSelection = false
local avaliableFileSystem = {}
local selectedDrive = 1
local timeoffset = 0
local halted = false
--localize functions, these are meant for bootloader operations only
keyResponse = function(code) end
local wait = function(time)
    local endTime=computer.uptime()+time
    while computer.uptime()<endTime do
        local name,_,_,code=computer.pullSignal(endTime-computer.uptime())
        if name == "key_down" then
            keyResponse(code)
        end
    end
    return true
end

avaliables = function(type)
    local attached=component.list()
    for i,v in pairs(attached) do
        if v==type then
            return i
        end
    end
    return false
end

local loadstring=function (str)
    local func,errorm=load(str,"=COLDNIX_BOOT_LOADER","bt",_G)
    if func then
        return func
    else
        error(errorm)
    end
end

local readfile = function(path,driveproxy)
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

local loadfile=function(filepath,drive)
    drive=drive or BOOTDRIVEPROXY 
    local file=drive.open(filepath)
    local finalEx=""
    repeat 
        local currentLoad=drive.read(file,math.huge)
        finalEx=finalEx..(currentLoad or "")
    until not currentLoad
    drive.close(file)
    return loadstring(finalEx)
end

keyResponse = function(keyID)
    if keyID == 208 and selectedDrive<#avaliableFileSystem then
        selectedDrive=selectedDrive+1
        timeoffset = computer.uptime()
    elseif keyID == 200 and selectedDrive>1 then
        selectedDrive=selectedDrive-1
        timeoffset = computer.uptime()
    elseif keyID == 28 then
        waitForSelection = false
        if halted then computer.shutdown(true) end
        if selectedDrive~=1 then
            initFilePath = "/init.lua"
            BOOTDRIVEADDRESS = avaliableFileSystem[selectedDrive]
            BOOTDRIVEPROXY = component.proxy(BOOTDRIVEADDRESS)
            computer.getBootAddress = load("return '"..BOOTDRIVEADDRESS.."'","=COLDNIX_BOOT_LOADER","bt",_G)
            computer.setBootAddress = function() end
        end
    end
end
--getting GPU
local BOOTGPUADDRESS=avaliables("gpu")
local BOOTGPUPROXY=component.proxy(BOOTGPUADDRESS)
--setting up screen
local rx,ry=BOOTGPUPROXY.getResolution()
BOOTGPUPROXY.setBackground(0x000000)
BOOTGPUPROXY.setForeground(0xffffff)
BOOTGPUPROXY.fill(1,1,rx,ry," ")
BOOTGPUPROXY.set(1,1,"Coldnix Boot Loader")
BOOTGPUPROXY.set(1,2,"Multiple bootable drives detected")
BOOTGPUPROXY.set(1,3,string.rep("═",rx))
table.insert(avaliableFileSystem,BOOTDRIVEADDRESS)
for i,v in pairs(component.list()) do
    if v == "filesystem" and i~=BOOTDRIVEADDRESS then
        if component.proxy(i).exists("/init.lua") and not component.proxy(i).isDirectory("/init.lua") then
            table.insert(avaliableFileSystem,i)
        end
    end
end

if #avaliableFileSystem>1 then
    waitForSelection=true
end

while waitForSelection do
    wait(0.025)
    for i,v in pairs(avaliableFileSystem) do
        BOOTGPUPROXY.setBackground(0x000000)
        BOOTGPUPROXY.setForeground(0xffffff)
        local text = "("..i.."): "..v.." | "..(component.proxy(v).getLabel() or "no label").." | "..tostring(math.floor(component.proxy(v).spaceUsed()/1024)).."KB/"..tostring(math.floor(component.proxy(v).spaceTotal()/1024)).."KB"
        if i==selectedDrive then
            BOOTGPUPROXY.setBackground(0xffffff)
            BOOTGPUPROXY.setForeground(0x000000)
            if #text-rx>0 then
                text = " "..text.." "
                local maxShift = math.max(#text-rx,0)
                local scrollForShiftshift = math.floor((computer.uptime()-timeoffset)*8)%(maxShift*2)
                local scrollBackShift = math.max(scrollForShiftshift-maxShift,0)
                local shift = math.min(scrollForShiftshift,maxShift)-scrollBackShift
                text = string.sub(text,shift+1,rx+shift+1)     
            end
        end
        BOOTGPUPROXY.set(1,i+3,text)
    end
end

BOOTGPUPROXY.setBackground(0x000000)
BOOTGPUPROXY.setForeground(0xffffff)
BOOTGPUPROXY.fill(1,1,rx,ry," ")
_G.trueUpTime = computer.uptime
--starting the selected OS
local osInit = loadfile(initFilePath,BOOTDRIVEPROXY)
if osInit then
    computer.uptime = load("return _G.trueUpTime()-'".._G.trueUpTime().."'","=COLDNIX_BOOT_LOADER","bt",_G) --this reset the default uptime function to 0 on real system start
    osInit()
end
halted = true
BOOTGPUPROXY.set(1,1,"OS HALTED OR ENCOUNTERED AN ERROR WHILE COMPILING")

while true do
    wait(1)
end