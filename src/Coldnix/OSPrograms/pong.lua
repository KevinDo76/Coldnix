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
local maxPaddle=2
local accerelation=1
local updatePercision=0.5
--game state
local score=0
local running=true
local gameStage="main"
local pad1y=1
local pad1vel=0
local ballX=math.floor(x/2)
local ballY=math.floor(y/2)
local ballVelX=-2
local ballVelY=0
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
            pad1vel=pad1vel-(pad1vel/math.abs(pad1vel))*accerelation/2
        end

        local ballUpdateFound=false
        local paddleUpdate=true
        local velMustCalc=math.sqrt(ballVelX*ballVelX+ballVelY*ballVelY)
        local lvecX = ballVelX/velMustCalc*updatePercision
        local lvecY = ballVelY/velMustCalc*updatePercision
        gpu.setBackground(0x000000)
        gpu.setForeground(0xFFFFFF)
        gpu.set(1,1,string.rep(" ",x))
        gpu.set(1,1,"Score: "..tostring(score))
        for i=1,100,1 do
            --update 
            if ballUpdateFound or velMustCalc<=0 then
                break
            end
            velMustCalc=velMustCalc-updatePercision
            gpu.setBackground(0x000000)
            gpu.setForeground(0x000000)
            gpu.set(ballX,ballY," ")
            if paddleUpdate then
                gpu.fill(1,pad1y,1,padSize," ")
                pad1y=math.clamp(pad1y+pad1vel,1,y-padSize+1)
            end
            
            ballX=ballX+lvecX
            ballY=ballY-lvecY

            if ballX<=2 then
                if ballY-pad1y>=0 and ballY-pad1y<=5 then
                    local ballSpace=(ballY-pad1y-2)/2
                    local angle=ballSpace*-40
                    ballVelX=math.cos(math.rad(angle))*2.5
                    ballVelY=math.sin(math.rad(angle))*2.5
                    ballUpdateFound=true
                    score=score+1
                    ballX=2
                else
                    ballX=math.floor(x/2)
                    ballY=math.floor(y/2)
                    local angle=math.random(150,210)
                    ballVelX=math.cos(math.rad(angle))*2
                    ballVelY=math.sin(math.rad(angle))*2
                end
            end

            if ballY<2 then
                ballVelY=ballVelY*-1
                ballUpdateFound=true
            end

            if ballY>=y then
                ballVelY=ballVelY*-1
                ballUpdateFound=true
            end

            if ballX>=x then
                ballVelX=ballVelX*-1
                ballUpdateFound=true
            end
            gpu.setBackground(0xffffff)
            gpu.setForeground(0xffffff)
            gpu.set(ballX,ballY," ")
            if paddleUpdate then
                gpu.fill(1,pad1y,1,padSize," ")
            end
            paddleUpdate=false
        end
    end
end

--exit routine
EventManager.removeListener("pongTermination")
EventManager.removeListener("pongKeyboardUp")
EventManager.removeListener("pongKeyboardDown")
terminal.resumeProcess()
print("Exited Pong")