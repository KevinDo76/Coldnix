local newGPULIST={}
local enabled=false
if enabled then
    TaskSchedular.pauseTask("CursorBlink")
    TaskSchedular.pauseTask("StatusBarUpdate")
    --TaskSchedular.pauseTask("StatusBarUpdate")
    for i,v in pairs(BOOTGPUPROXY) do
        local newFunc=loadstring(string.format([==[Log.writeLog("GPUCALL: %s("..(table.concat({...},","))..")") return component.proxy(BOOTGPUADDRESS).%s(...)]==],i,i),i)
        newGPULIST[i]=newFunc
    end
    BOOTGPUPROXY=newGPULIST
end