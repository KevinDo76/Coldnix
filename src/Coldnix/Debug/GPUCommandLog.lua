local newGPULIST={}
local enabled=false
local profiling=true
_G.GPUCallTotal = 0
_G.GPUCallList = {}
if enabled then
    TaskScheduler.pauseTask("CursorBlink")
    TaskScheduler.pauseTask("StatusBarUpdate")
    --TaskSchedular.pauseTask("StatusBarUpdate")
    for i,v in pairs(BOOTGPUPROXY) do
        local newFunc=loadstring(string.format([==[Log.writeLog("GPUCALL: %s("..(table.concat({...},","))..")") return component.proxy(BOOTGPUADDRESS).%s(...)]==],i,i),i)
        newGPULIST[i]=newFunc
    end
    BOOTGPUPROXY=newGPULIST
end

if profiling and not enabled then
    print("GPU CALL PROFILLING ENABLED")
    for i,v in pairs(BOOTGPUPROXY) do
        GPUCallList[i]=0
        local newFunc=loadstring(string.format([==[GPUCallTotal=GPUCallTotal+1 GPUCallList.%s=GPUCallList.%s+1 return component.proxy(BOOTGPUADDRESS).%s(...)]==],i,i,i),i)
        newGPULIST[i]=newFunc
    end
    BOOTGPUPROXY=newGPULIST
    SandBox.BOOTGPUPROXY = newGPULIST
end