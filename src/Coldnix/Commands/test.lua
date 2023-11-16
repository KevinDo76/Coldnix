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
            print(os.clock()*100)
            --count=math.min(count,1000000)
        end
    end
return module