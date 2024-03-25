local module = {}
    module.id=17
    module.name="vid"
    module.description="video test"
    module.func = function (rawText)
        vid = require("videoEngine")
        System.utility.loadAsGraphicalApp(
            vid.playVideo,
            "boot:/Coldnix/Data/nevergonnagiveyouup.txt"
        )
    end
return module