local module = {}
    module.name="test"
    module.description="this is a test program, very nice"
    module.func = function (rawText)
        print("this is a test command")
        print("name: "..module.name)
        print("description: "..module.description)
        local f={}
        while true do
            wait(0.01)
            for i=1,100 do
                f[#f+1]="joe"
            end
        end
    end
return module