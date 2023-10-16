local module = {}
    module.id=14
    module.name="testimg"
    module.description="AttemptConnect"
    module.func = function (rawText)
        print("Rendering image with subpixel render test")
        local subpixel = require("subpixel")
        subpixel.renderSubPixelImageFromDisk("boot:/Coldnix/Data/Images/test.ocimg",1,1)
        terminal.stopProcess()

    end
return module