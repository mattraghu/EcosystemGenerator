--!!Ecosystem Management Script!!--

--//Vars\\--

--Services 
local SSS = game:GetService("ServerScriptService")

--Modules
local PlantGen = require(SSS:WaitForChild("PlantGen"))

--Ecosystem Variables
local time = 0 --Current Simulation Time
local dt = 1

--//Execution\\--


local Plant = PlantGen.createPlant(.5,Vector3.new(10,07,0))
while (time < 100) do


    dt = dt + 20
end

local Node = Plant.Modules[2].Nodes[1]
local Node2 = Plant.Modules[2].Nodes[3]
PlantGen.GeneratePlantNodes(Plant)
print(PlantGen.GetEndNodes(Plant))

