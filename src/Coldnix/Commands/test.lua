local module = {}
    module.name="test"
    module.description="this is a test program, very nice"
    module.func = function (rawText)
        print("this is a test command")
        print("name: "..module.name)
        print("description: "..module.description)
    end
return module