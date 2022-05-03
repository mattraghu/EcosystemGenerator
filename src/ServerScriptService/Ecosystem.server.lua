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







while (Time < 1000) do

-- 	--TEST
    local EndNodes = PlantGen.GetEndNodes(Plant)

    local randEndNode = math.random(1,#EndNodes)
    
--     if randEndNode > highestEndNode then
--         highestEndNode = randEndNode
--     end
--     print("Apple:" .. highestEndNode)
	local Module = PlantGen.addModule(Plant,"A",EndNodes[randEndNode])
 

    --Calculate Best Orientation
    local Node = Module.OrientNode
	local ParentOrient = PlantGen.Orientation(Node.Parent)
	PlantGen.SetNodeOrientation(Node,"Y",ParentOrient.Y)
    
    local BestOrientation = {}
    local BestWeight = 7777777
    for y = 0, 90, 10 do
        PlantGen.SetNodeOrientation(Node,"Y",y)
        for x = 0, 360, 10 do
            PlantGen.GeneratePlantNodes(Plant)
            PlantGen.DisplayBoundries(Plant)

            Node.Part.Color = Color3.fromRGB(255,0,0)
            PlantGen.SetNodeOrientation(Node,"X",x)
            -- print(PlantGen.Orientation(Node))
            local Weight = PlantGen.GetIntersectingWeight(Module.Nodes,PlantGen.GetNodes(Plant))
            if Weight < BestWeight then
                BestWeight = Weight
                BestOrientation = Vector3.new(x,y,0)
            end
        end
            
        -- wait(3)
    end
 
    print(BestWeight)
    PlantGen.SetNodeOrientation(Node,"X",BestOrientation.X)
    PlantGen.SetNodeOrientation(Node,"Y",BestOrientation.Y)
	
-- 	-- local Node = Module2.Nodes[2] 
-- 	-- local ParentOrient = Orientation(Node.Parent)
-- 	-- print(ParentOrient)
-- 	-- SetNodeOrientation(Node,"Y",ParentOrient.Y)
-- 	-- SetNodeOrientation(Node,"X",ParentOrient.X)
	

--     Time = dt + 1

--     -- PlantGen.GeneratePlantNodes(Plant)
--     if tick() - timer > 7 then
--         timer = tick()
--         wait()
--     end
    wait(1)
end


