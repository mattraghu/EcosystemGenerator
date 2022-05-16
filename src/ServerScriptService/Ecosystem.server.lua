--!!Ecosystem Management Script!!--

--//Vars\\--

--Services 
local SSS = game:GetService("ServerScriptService")

--Modules
local PlantGen = require(SSS:WaitForChild("PlantGen"))

--Ecosystem Variables
local Time = 0 --Current Simulation Time
local dt = 1

--//Execution\\--


local Plant = PlantGen.createPlant(.5,Vector3.new(10,07,0))
local highestEndNode = 0

local timer = tick()
print("Starting Simulation...")
local Module = PlantGen.addModule(Plant,"A")







local height = 0

local function LogisticalGrowthRate(t,X_0,X_m,r)
    return X_m*r*(X_m/X_0-1)*math.exp(-r*t)/((1+(X_m/X_0-1)*math.exp(r*t))^2)
end

local function LogisticalGrowth(t,X_0,X_m,r)
    return X_m/(1+(X_m/X_0-1)*math.exp(-r*t))
end
while (Time < 10000) do
	local EndNodes = PlantGen.GetEndNodes(Plant)
    
    local branchSize = 12.5
    local X_m = 200
    local X_0 = 10
    local r = .001

    local theoreticalHeight = LogisticalGrowth(Time,X_0,X_m,r)

    while height < theoreticalHeight do
     

	    local EndNodes = PlantGen.GetEndNodes(Plant)
        
        for _, Node in pairs(EndNodes) do 
            if height > theoreticalHeight then
                break
            end
            --Add Module 
            local randEndNode = math.random(1,#EndNodes)

            wait(1)

            PlantGen.GeneratePlantNodes(Plant)
            PlantGen.DisplayBoundries(Plant)
            PlantGen.DrawBranches(Plant)



            PlantGen.addRotatedModule(Plant,Node) 


            --Get Height
            for _, Node in pairs(EndNodes) do
                local y = Node.Position.Y
                if y > height then
                    height = y 
                end

            end
        end

    end

    --Get Height
    for _, Node in pairs(EndNodes) do
        local y = Node.Position.Y
        if y > height then
            height = y 
        end

    end
    

    print("Apple: "..height)
    print(theoreticalHeight)

    Time = Time + dt

--     -- PlantGen.GeneratePlantNodes(Plant)
    if tick() - timer > 7 then
        timer = tick()
        wait()
    end
    -- wait(.1)
    -- PlantGen.GeneratePlantNodes(Plant)
    -- PlantGen.DisplayBoundries(Plant)
    -- PlantGen.DrawBranches(Plant)
end



PlantGen.GeneratePlantNodes(Plant)
PlantGen.DisplayBoundries(Plant)
PlantGen.DrawBranches(Plant)

print("Simulation Finished!")