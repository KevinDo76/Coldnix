local module = {}
    module.id=6
    module.name="test"
    module.description="this is a test program, very nice"
    module.func = function (rawText)
        local count=2
        while (wait()) do
            for i=1,count do
                local a = 2
                local b = 2
                local c = a * b^2
            end
            count=count*1.2
            print(count)
        end
    end
return module