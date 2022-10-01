local module = {}
    module.name="test"
    module.description="this is a test program, very nice"
    module.func = function (rawText)
        _G.terminal={}
    end
return module