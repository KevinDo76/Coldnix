--Build number 2 of this experimental OS thingy(Coldniximage.png)
--boot beep indication
for i=1,3 do
    computer.beep(1000,0.1)
end

--starting settings
local requiredHardwares={"gpu","screen","keyboard"}
local avaliableHardwaresFound={}
local systemFiles={
    "Coldnix/Kernel/System.lua",    
    "Coldnix/Kernel/config.lua",
    "Coldnix/Kernel/KernelPanic.lua",
    "Coldnix/Kernel/log.lua",
    "Coldnix/Kernel/TaskScheduler.lua",
    "Coldnix/Kernel/EventManager.lua",
    "Coldnix/Kernel/Terminal.lua",
    "Coldnix/Debug/GPUCommandLog.lua",
    "Coldnix/Kernel/systemStatus.lua",
    "Coldnix/Kernel/CommandProcessor.lua",
    "Coldnix/Debug/KeyboardInputTest.lua",
}

--getting the bootdrive
_G.BOOTDRIVEADDRESS=computer.getBootAddress()
_G.BOOTDRIVEPROXY=component.proxy(BOOTDRIVEADDRESS)
_G.WORKINGDRIVEADDRESS=BOOTDRIVEADDRESS
_G.WORKINGDRIVEPROXY=BOOTDRIVEPROXY
_G.currentWorkingDir = "/Coldnix"
--defining basic functions that's needed for the OS
    --adding component.avaliables to the OS because it's not included for reasons
    function component.avaliables(type)
        local attached=component.list()
        for i,v in pairs(attached) do
            if v==type then
                return i
            end
        end
        return false
    end
    --adding in string.split because that's pretty handy for many situations
    function string.split(str,sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        str:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
    end
    --adding in math.clamp because that's also not a thing for reasons
    function math.clamp(x,min,max)
        if x<min then
            return min
        elseif x>max then
            return max
        else
            return x
        end
    end
    --adding in wait(), it's going to get replaced with something else in when EventManager is loaded
    _G.wait = function(time)
        local endTime=computer.uptime()+time
        while computer.uptime()<endTime do
            computer.pullSignal(endTime-computer.uptime())
        end
        return true
    end
    --adding in loadstring, practically the most important function for the OS
    _G.loadstring=function (str,envname,errorOnFail)
        envname=envname or "loadstring_env"
        local func,errorm=load(str,"="..envname,"bt",_G)
        if func then
            return func
        else
            if errorOnFail then
                error(errorm)
            else
                return false,errorm
            end
        end
    end
    --adding in loadfile()
    _G.loadfile=function(filepath,errorOnFail,drive)
        drive=drive or BOOTDRIVEPROXY
        if errorOnFail==nil then  errorOnFail=true end --if erroronfail is not set, set it to true
        local file=drive.open(filepath)
        local finalEx=""
        repeat 
            local currentLoad=drive.read(file,math.huge)
            finalEx=finalEx..(currentLoad or "")
        until not currentLoad
        drive.close(file)
        return loadstring(finalEx,filepath,errorOnFail)
    end

--checking for hardware requirement
for i,v in pairs(requiredHardwares) do
    local result=component.avaliables(v)
    if not result then
        for c=1,i do
            computer.beep(200,0.2)
            wait(0.1)
        end
        error("Missing required hardware: "..v)
    end
    avaliableHardwaresFound[v]=result
end

--setting up the gpu and screens
_G.BOOTGPUADDRESS=avaliableHardwaresFound["gpu"]
_G.BOOTGPUPROXY=component.proxy(BOOTGPUADDRESS)
    --binding the gpu to the screen
    local success,err=BOOTGPUPROXY.bind(avaliableHardwaresFound["screen"], true)
    if not success then
        error("Failed to bind the gpu to the screen, error: "..err)
    end
    --clearing the screen
    local rx,ry=BOOTGPUPROXY.getResolution()
    BOOTGPUPROXY.fill(1,1,rx,ry," ")

--launching other operating system system files
for i,v in ipairs(systemFiles) do
    if Log then
        Log.writeLog(string.format('loading file "%s"',v))
    end
    local suc,err=pcall(function() loadfile(v)() end)
    if not suc then
        KernelPanic(err)
    end
    if Log then
        Log.writeLog(string.format('loaded file "%s"',v))
    end

    if print then
        print("loaded file \"/"..v.."\"")
    end
end
computer.ElapseT=0
print("done loading")
--main loops for the computer that keeps it running and run other programs
while true do
    local s,e = pcall(function ()
        wait(0.01)
    end)
    if not s then
        KernelPanic(e)
    end
end