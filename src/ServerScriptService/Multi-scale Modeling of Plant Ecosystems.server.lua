--!!Plant Ecosystem Control. Based off of journal "Synthetic Silviculture: Multi-scale Modeling of Plant Ecosystems" https://storage.googleapis.com/pirk.io/papers/Makowski.etal-2019-Synthetic-Silviculture.pdf !!--


--//Vars\\--
--Services
local SS = game:GetService("ServerStorage")
local SSS = game:GetService("ServerScriptService")

--Resources
local TerrainAssetsFolder = workspace:WaitForChild("TerrainAssets")
local ModulePrototypesFolder = SS:WaitForChild("ModulePrototypes")

local MathModules = SSS:WaitForChild("Math")

--Modules
local Matrix = require(MathModules:WaitForChild("Matrix"))


local p = Vector3.new(0,0,0)

local right = Vector3.new(1,0,0)
local up = Vector3.new(0,1,0)
local back = Vector3.new(0,0,1)

local cf = CFrame.new(p.X,p.Y,p.Z,right.X,up.X,back.X,right.Y,up.Y,back.Y,right.Z,up.Z,back.Z)
local m = Matrix.new{
	{right.X,up.X,back.X,p.X},
	{right.Y,up.Y,back.Y,p.Y},
	{right.Z,up.Z,back.Z,p.Z},
	{0,0,0,1}
}

local a = Matrix.new({{771},{7},{17},{1}})


--print(m*a)
--print(cf*Vector3.new(771,7,17))

--Tables 
local Plants = {} --[PlantID] = PlantTable

local ModulePrototypes = {
	["A"] = {
		Preset = ModulePrototypesFolder:WaitForChild("A"),
		Nodes = {
			[1] = {
				Children = {
					2
				}
			},
			[2] = {
				Children = {
					3,4
				}
			}
		}
		
	}
}

--Script Vars
local stepTime = 0




--//Init\\--
--Translate branch prototype builds into table form (Nodal Positions, Orientations)
local function developModulePrototypes()
	for _, ModulePrototype in pairs(ModulePrototypes) do
		
		local Nodes = ModulePrototype.Nodes
		local FirstNodePart
		
		for NodeID, Node in pairs(Nodes) do	
			--Apply Parent Identifiers to Children
			for _, childID in pairs(Node.Children or {}) do
				--Create Node Table For Child If Unexistant
				local childNode = Nodes[childID]
				if not childNode then
					childNode = {}
					Nodes[childID] = childNode
				end
				
				--Establish Parent
				childNode.Parent = NodeID
			end
			
			--Find node part in prototype preset
			for _, nodePart in pairs(ModulePrototype.Preset:GetDescendants()) do
				if tonumber(nodePart.Name) == NodeID then --Found!
					--Store First Node Part (All positions based relative to NP1)
					if NodeID == 1 then
						FirstNodePart = nodePart
					end
					--Create Spacial Information
					Node.Position = nodePart.Position-FirstNodePart.Position --Positions Relative to Node 1 (Calculated First). I.E. Node 1 at 0,0,0 

					
					break
				end
			end
		end
	end
end
developModulePrototypes()


--//Functions\\--



local function calculateNodeOrientation(Node)
	--Orientation Y And X. Z is Irrelavant. 
	local normal = (Node.Position-Node.Parent.Position).Unit --Branch Direction With Respect to Parent
	
	
	
	
	
	--Y Orientation
	Node.Orientation = {}
	Node.Orientation.Y = math.atan2(normal.Y,math.sqrt(normal.X^2+normal.Z^2))
	Node.Orientation.Y = math.asin(normal.Y/1)
	--Temp
	Node.Orientation.Y = math.deg(Node.Orientation.Y)

	--X Orientation
	Node.Orientation.X = math.atan2(normal.Z,normal.X)
	--Temp
	Node.Orientation.X = math.deg(Node.Orientation.X)
end


local function GetUpperNodes(Node)
	--Get Upper All Upper Nodes of Node in Plant
	local UpperNodes = {}
	
	--Create a queue to process all upper nodes
	local childQueue = {} --Children Nodes to Be Processed (Basically Groups of Nodes {Node1,Node2},{Node3},..) 
	table.insert(childQueue,Node.Children)
	
	while (#childQueue > 0) do 
		wait()
		for _, node in pairs(childQueue[1]) do 
			table.insert(UpperNodes,node)
			
			if node.Children then
				table.insert(childQueue,node.Children)
			end
		end
		
		table.remove(childQueue,1)
	end
	
	return UpperNodes
end


--May want to make this a meta table
local function SetNodeOrientation(Node,direction,theta,i)
	local xyz_0 = Node.Position-Node.Parent.Position
	local look = CFrame.new(Node.Parent.Position,Node.Position)
	local dist = (xyz_0).Magnitude
	local normal = (xyz_0).Unit --Branch Direction With Respect to Parent

	local xz_0 = Vector2.new(xyz_0.X,xyz_0.Z)
	local xzNormal = xz_0.Unit


	local xyz_1
	local normal_1

	if direction == "Y" then
		local yMag_1 = math.sin(math.rad(theta))
		local xzMag_1 = math.cos(math.rad(theta))
		
		xzNormal = Vector2.new(math.abs(xzNormal.X),math.abs(xzNormal.Y))
		local xz_1 = xzNormal*xzMag_1
		
		normal_1 = Vector3.new(xz_1.X,yMag_1,xz_1.Y)	 
		
		
		xyz_1 = normal_1*dist
		
		
	elseif direction == "X" then
		
		xyz_1 = Vector3.new(xz_0.Magnitude*math.cos(math.rad(theta)),xyz_0.Y,xz_0.Magnitude*math.sin(math.rad(theta)))

	
	end

	--Adjust Nodes 
	-- Node.Position = Node.Parent.Position+xyz_1
	-- local look2 = CFrame.new(Node.Parent.Position,Node.Position)
	local newPos = Node.Parent.Position+xyz_1
	local look2 = CFrame.new(Node.Parent.Position,newPos)*CFrame.Angles(math.rad(0),0,0)



	--Adjust Angles to Ensure Other Angles are Held Constant
	local x,y,z = look:ToEulerAnglesYXZ()

	--Actual Components
	--x -> y 
	local thetas_0  = Vector3.new(math.deg(x),math.deg(y),math.deg(z))



	local dTheta = theta-x --For testing, only change y (x)
	look2 = look*CFrame.Angles(math.rad(dTheta),0,0)

	-- look2 = CFrame.fromEulerAnglesXYZ(x,y,z)
	--Calculate New Vectors
	local R = look.RightVector
	local normal_1 = xyz_1.Unit
	local L = (normal_1).Unit
	local U = L:Cross(R).Unit
	
	--Flip Sign of U if sign mismatch
	if (look.UpVector.X < 0 and U.X > 0) or (look.UpVector.X > 0 and U.X < 0) then  
		U = -U 
	end 
	U = -U
	

	look2 = CFrame.fromMatrix(
		Node.Parent.Position,
		R,
		U,
		-L
	)
	



	local x,y,z = look2:ToEulerAnglesYXZ()
	local thetas_1  = Vector3.new(math.deg(x),math.deg(y),math.deg(z))
	--print(thetas_0)
	print("--------------------------------")
	print(thetas_1)
	

	-- local x,y,z = look:ToEulerAnglesYXZ()
	-- print(Vector3.new(math.deg(x),math.deg(y),math.deg(z)))


	--look2 = look2*CFrame.Angles(0,0,math.rad(90))

	
	
	--Adjust Upper Nodes (Relative To Node)
	local UpperNodes = GetUpperNodes(Node)
	table.insert(UpperNodes,Node)
	for _, UpperNode in pairs(UpperNodes) do

		local x = look:Inverse()*UpperNode.Position
		-- local x = UpperNode.Position*look:Inverse()
		UpperNode.Position = look2*x


		
	end



end


local Node_Temp = game:GetService("ServerStorage"):WaitForChild("Node") --For use in VVV 
local function GeneratePlantNodes(Plant)
	--Create physicial parts to represent plant nodes (For Testing Purposes )
	Plant.Folder:ClearAllChildren()
	
	for ModuleID, Module in pairs(Plant.Modules) do
		local ModuleFolder = Instance.new("Folder")
		ModuleFolder.Name = ModuleID
		ModuleFolder.Parent = Plant.Folder
		
		for NodeID, Node in pairs(Module.Nodes) do 
			local nodePart = Node_Temp:Clone()
			nodePart.Position= Node.Position
			nodePart.Name = NodeID
			nodePart.Parent = ModuleFolder
		end
	end
	
end



local function addModule(Plant, parentModuleID, parentNodeID,modulePrototypeName)
	--Add a prototype module onto the end node of a plant
	--Var Info
		--Plant = Plant Table Generated from createPlant Function
		--parentNodeID = NodeID of the endnode for which the module will be attached onto (Can be nil in which case will default to Plant.CFrame)
		--parentModuleID = ID of parent node (Can be nil)
	
	local ModulePrototype = ModulePrototypes[modulePrototypeName]
	local ParentModule = parentModuleID and Plant.Modules[parentModuleID]
	local ParentNode = ParentModule and ParentModule.Nodes[parentNodeID]
	
	--Create new Module
	local newModule = {}
	newModule.ID = #Plant.Modules+1
	newModule.Prototype = ModulePrototype
	
	
	--Generate Nodes
	newModule.Nodes = {}
	local PlacementPos = (ParentNode and ParentNode.Position) or Plant.Position
	
	for protoNodeID, protoNode in pairs(newModule.Prototype.Nodes) do
		local newNode = {}
		
		--Setup
		newNode.Children = {}
		
		--Set Parent
	--newNode.Parent = protoNode.Parent
		newNode.Parent = newModule.Nodes[protoNode.Parent] 
			
		--If there's no parent node (in this module), then it's the first node. 
		--This means that the parent should be set to the parent's parent 
		--And we should set the parent's parent child from the parent to the new node 
		if not newNode.Parent and ParentNode then
			newNode.Parent = ParentNode.Parent 
			
			
			local oldChild = table.find(ParentNode.Parent.Children,ParentNode)
			if oldChild then
				table.remove(ParentNode.Parent.Children,oldChild)
			end
			
			--Delete The Old Parent (Maybe later???)
			
		end
		
		if newNode.Parent then
			table.insert(newNode.Parent.Children,newNode)
		end
		
		--Set Position Relative To Parent (or plant pos)
		newNode.Position = protoNode.Position+PlacementPos
		
		newModule.Nodes[protoNodeID] = newNode
	end
	
	
	
	
	Plant.Modules[newModule.ID] = newModule
	
	--Assign Parent/Child Variables
	--if ParentNode then
	--	table.insert(ParentNode.Children,newModule)

	--end
	
	
	return newModule
	
end


local function createPlant(AC, Pos)
	--Create Empty Plant Container
	--Var Info:
		--AC = Apacial Control. Tendency For Apacial Node To Dominate (Higher Values Result in Skinnier Plants) 
		--Cpos = CFrame Position that plant will be placed at
	
	local Plant = {}
	Plant.Age = 0
	Plant.AC = AC
	Plant.Position = Pos
	Plant.ID = #Plants+1
	
	Plants[Plant.ID] = Plant
	
	
	Plant.Modules = {
		--Module Template
		--[ModuleID] = {
		--	Template = TemplateInfo
		--	Nodes = {
		--		[NodeID] = {
		--			Position = WorldPos
		--			Children = {ChildNodeInfo}
		--		}
		--	}
		--}
	}
	
	--Creation of workspace instances
	Plant.Folder = Instance.new("Folder")
	Plant.Folder.Name = Plant.ID
	
	local ModuleFolder = Instance.new("Folder")
	ModuleFolder.Name = "Modules"
	ModuleFolder.Parent = Plant.Folder
	
	
	Plant.Folder.Parent = TerrainAssetsFolder
	
	---TEST
	local Module = addModule(Plant,nil,nil,"A")
	local Module2 = addModule(Plant,1,3,"A")
	--print(Module.Nodes[2])
	-- local node = Module2.Nodes[1]
	-- local node2 = Module2.Nodes[2]
	-- calculateNodeOrientation(node2)
	-- print(node2.Orientation.Y)

	-- SetNodeOrientation(node,"Y",15)
	-- calculateNodeOrientation(node2)
	-- print(node2.Orientation.Y)

	GeneratePlantNodes(Plant)
	print(Plant.Modules)
	
	
	return Plant
	
end
local Plant = createPlant(.5,Vector3.new(10,07,0))

local i = 0
while (wait(1)) do
	i += 10.1
	if i > 360 then i = 0 end
	GeneratePlantNodes(Plant)
	SetNodeOrientation(Plant.Modules[2].Nodes[2],"Y",i,i)
end


local function ModuleVigors(Plant)
	--Calculate Branch Collision Volume
	--Var Info:
	--nodeA/B = Node IDS of branch endpoints. A<B
	
	
	local queue = {1}
	local currentNode = 1
	local i = 0 
	
	while #queue > 0 and i < 100 do
		for _, moduleID in pairs(queue) do
			i+=1
			
			local Module = Plant.Modules[moduleID]
			if Module then
				--Process Module
				 	
				
				table.remove(queue,1)
				
				--Append Any Child Modules 
				if Module.Children then
					for _, childModuleID in pairs(Module.Children) do
						table.insert(queue,childModuleID)
					end
				end
				
				

			end

		end
		
	end
	print(i)
	
end


local function updatePlant(Plant)
	
end