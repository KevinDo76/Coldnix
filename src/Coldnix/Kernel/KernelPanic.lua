--this will replace the built in blue screen for most case because it's cringe
--this program will have no dependency other than init.lua
--right now only catch error that happen immediately after start
--currently useless
local function a(err)
    local rx,ry=BOOTGPUPROXY.getResolution()
    BOOTGPUPROXY.fill(1,1,rx,ry," ")
    local txtChunk={}
    local width=rx-6
    repeat
        txtChunk[#txtChunk+1] = string.sub(err,1,width)
        err=string.sub(err,width+1,#err)
    until #err<1
    for i,v in ipairs(txtChunk) do
        BOOTGPUPROXY.set(4,i,v)
    end
    local function ewait(sec)
        local endTime=computer.uptime()+sec
        while computer.uptime()<endTime do
            computer.pullSignal(endTime-computer.uptime())
        end
        return true
    end
    while true do
        ewait(0.5)
        computer.beep(1000,0.1)
    end
end

_G.KernelPanic=a
