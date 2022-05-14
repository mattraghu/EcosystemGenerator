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
while (Time < 10000) do

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
    for y = -0, 90, 10*3 do
        -- wait()

        PlantGen.SetNodeOrientation(Node,"Y",y)
        for x = 0, 360, 10*3 do
            PlantGen.SetNodeOrientation(Node,"X",x)
            
            for z = 0, 360, 30*3 do
                
                PlantGen.RotateNode(Node,"Z",10)
                -- PlantGen.GeneratePlantNodes(Plant)
                -- PlantGen.DisplayBoundries(Plant)
                -- PlantGen.DrawBranches(Plant)

                -- print(PlantGen.Orientation(Node))
                local s = tick()
                local Weight = PlantGen.GetIntersectingWeight(Module.Nodes,PlantGen.GetNodes(Plant))
                print("Apple:"..tick()-s)
                if Weight < BestWeight then
                    BestWeight = Weight
                    BestOrientation = Vector3.new(x,y,0)
                end
            end 
        end
            
        -- wait(3)
    end
 
    PlantGen.SetNodeOrientation(Node,"Y",BestOrientation.Y)
    PlantGen.SetNodeOrientation(Node,"X",BestOrientation.X)

    local bestZ = 0
    local bestWeight = 0
    for z = 0, 360, 10 do
        PlantGen.RotateNode(Node,"Z",10)
        local Weight = PlantGen.GetIntersectingWeight(Module.Nodes,PlantGen.GetNodes(Plant))
        if Weight > bestWeight then
            bestWeight = Weight
            bestZ = z
        end
    end


    PlantGen.RotateNode(Node,"Z",bestZ)



    for _, Node in pairs(Module.Nodes) do
        local y = Node.Position.Y
        if y > height then
            height = y 
        end

    end

    -- print("Apple:" .. height)
	
-- 	-- local Node = Module2.Nodes[2] 
-- 	-- local ParentOrient = Orientation(Node.Parent)
-- 	-- print(ParentOrient)
-- 	-- SetNodeOrientation(Node,"Y",ParentOrient.Y)
-- 	-- SetNodeOrientation(Node,"X",ParentOrient.X)
	

    Time = Time + dt

--     -- PlantGen.GeneratePlantNodes(Plant)
    if tick() - timer > 7 then
        timer = tick()
        wait()
    end
    wait(.1)
    PlantGen.GeneratePlantNodes(Plant)
    PlantGen.DisplayBoundries(Plant)
    PlantGen.DrawBranches(Plant)
end



PlantGen.GeneratePlantNodes(Plant)
PlantGen.DisplayBoundries(Plant)
PlantGen.DrawBranches(Plant)

print("Simulation Finished!")