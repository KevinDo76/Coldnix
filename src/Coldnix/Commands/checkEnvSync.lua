local module = {}
    module.id=13
    module.name="synccheck"
    module.description="Check for application and kernel sync"
    module.func = function (rawText)
        print("Starting check")
        for i,v in pairs(SandBox) do
                if v~=_G[i] then
                    print(i,v,"application")
                    print(i,_G[i] or "nil","kernel")
                    print(" ")
            end
        end
    end
return module