local module = {}
    module.id=14
    module.name="testimg"
    module.description="AttemptConnect"
    module.func = function (rawText)
        print("Rendering image with subpixel render test")
        local subpixel = require("subpixel")
        local bufferIndx = BOOTGPUPROXY.allocateBuffer(160,50)
        BOOTGPUPROXY.setActiveBuffer(bufferIndx)
        subpixel.renderSubPixelImageFromDisk("boot:/Coldnix/Data/Images/test.ocimg",1,1)
        terminal.stopProcess()
        BOOTGPUPROXY.bitblt()
        BOOTGPUPROXY.setActiveBuffer(0)
        BOOTGPUPROXY.freeBuffer(bufferIndx)
    end
return module