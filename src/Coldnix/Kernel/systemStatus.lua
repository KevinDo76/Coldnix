--changing the size of the terminal
if terminal then
    local tx,ty=terminal.width,terminal.height
    local sizeOffset=tonumber(config.configList.TERMINALHOFF)
    terminal.setSize(tx,ty+sizeOffset)
    local tx,ty=terminal.x,terminal.y
    terminal.setPosition(tx,ty-sizeOffset)
    --setting up status bar
    TaskScheduler.addTask("StatusBarUpdate",[==[
    local x,y=BOOTGPUPROXY.getResolution()
    BOOTGPUPROXY.setBackground(0x000000)
    BOOTGPUPROXY.setForeground(0xffffff)
    BOOTGPUPROXY.set(1,1,terminal.padText("║"..config.configList.OSNAME.." | V"..config.configList.OSVERSION.."    Yield Limit: "..System.utility.floatCut((computer.ElapseT/5)*100,3).."%",x-1).."  ║")
    local memoryText=terminal.padText("║Memory: "..(System.utility.floatCut(computer.freeMemory()/1024,3)).."kb/"..(computer.totalMemory()/1024).."kb".." "..x.." "..y,x-1).."  ║"
    BOOTGPUPROXY.set(1,2,memoryText)
    BOOTGPUPROXY.set(1,3,"╚"..string.rep("═",x-2).."╝")
    ]==],tonumber(config.configList.STATUSBARUPDATERATE))
end