print("Starting Pong!")
wait(0.1)
local x,y=BOOTGPUPROXY.getResolution()
local gpu=BOOTGPUPROXY
terminal.stopProcess()
gpu.setBackground(0x000000)
gpu.setForeground(0xffffff)
gpu.fill(1,1,x,y," ")
local x,y=gpu.getResolution()
--config
local padSize=5
local maxPaddle=1
local accerelation=1
--game state
local running=true
local gameStage="main"
local velocityDir=0
local pad1y=1
local pad1vel=0
local keyStatus={
    up=false,
    down=false
}

--eventRegistration
EventManager.regsisterListener("pongTermination","SIGTERM",function()
    running=false
end)

EventManager.regsisterListener("pongKeyboardDown","key_down",function(componentId,asciiNum,keyboardcode) 
    if asciiNum==115 then
        keyStatus.up=true
    elseif asciiNum==119 then
        keyStatus.down=true
    end
end)


EventManager.regsisterListener("pongKeyboardUp","key_up",function(componentId,asciiNum,keyboardcode) 
    if asciiNum==115 then
        keyStatus.up=false
    elseif asciiNum==119 then
        keyStatus.down=false
    end
end)

--main game loop
while running do
    wait()
    if gameStage=="main" then
        if keyStatus.up then
            pad1vel=math.clamp(pad1vel+accerelation,-maxPaddle,maxPaddle)
        elseif keyStatus.down then
            pad1vel=math.clamp(pad1vel-accerelation,-maxPaddle,maxPaddle)
        elseif pad1vel~=0 then 
            pad1vel=pad1vel-(pad1vel/math.abs(pad1vel))*accerelation
        end
        gpu.setBackground(0x000000)
        gpu.setForeground(0x000000)
        gpu.fill(1,pad1y,1,padSize," ")
        pad1y=math.clamp(pad1y+pad1vel,1,y-padSize)
        gpu.setBackground(0xffffff)
        gpu.setForeground(0xffffff)
        gpu.fill(1,pad1y,1,padSize," ")
    end
end

--exit routine
EventManager.removeListener("pongTermination")
EventManager.removeListener("pongKeyboardUp")
EventManager.removeListener("pongKeyboardDown")
terminal.resumeProcess()
print("Exited Pong")