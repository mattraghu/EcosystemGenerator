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


print(Plant.Modules)

local Node = Module.Nodes[1]
print(PlantGen.GetIntersectingWeight({Node},PlantGen.GetUpperNodes(Node)))

PlantGen.GeneratePlantNodes(Plant)
PlantGen.DisplayBoundries(Plant)



-- while (Time < 1000) do

-- 	--TEST
--     local EndNodes = PlantGen.GetEndNodes(Plant)

--     local randEndNode = math.random(1,#EndNodes)
    
--     if randEndNode > highestEndNode then
--         highestEndNode = randEndNode
--     end
--     print("Apple:" .. highestEndNode)
-- 	local Module2 = PlantGen.addModule(Plant,"A",EndNodes[randEndNode])
	
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
-- end


