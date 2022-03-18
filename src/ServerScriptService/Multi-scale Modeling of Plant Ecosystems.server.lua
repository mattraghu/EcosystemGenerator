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
local function SetNodeOrientation(Node,direction,theta)
	if direction == "Y" then
		local xyz_0 = Node.Position-Node.Parent.Position
		
		local look = CFrame.new(Node.Parent.Position,Node.Position)
		
		local dist = (xyz_0).Magnitude
		
		local normal = (xyz_0).Unit --Branch Direction With Respect to Parent
		
		local yMag_1 = math.sin(math.rad(theta))
		local xzMag_1 = math.cos(math.rad(theta))
		
		local xzNormal = Vector2.new(normal.X,normal.Z).Unit
		local xz_1 = xzNormal*xzMag_1
		
		local normal_1 = Vector3.new(xz_1.X,yMag_1,xz_1.Y)	
		
		
		local xyz_1 = normal_1*dist
		Node.Position = Node.Parent.Position+xyz_1
		
		
		--Adjust Upper Nodes (Relative To Node)
		local UpperNodes = GetUpperNodes(Node)
		for _, UpperNode in pairs(UpperNodes) do
			local offset = UpperNode.Position-Node.Parent.Position 
			local look2 = CFrame.new(Node.Parent.Position,Node.Position)
			
			local x = look:Inverse()*UpperNode.Position
			
			
			UpperNode.Position = look2*x
			
			
		end
		
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
	SetNodeOrientation(Module2.Nodes[2],"Y",45)
	--rotateModule(Module,90)
	--addModule(Plant,1,3,"A")
	--addModule(Plant,1,1,"A")
	GeneratePlantNodes(Plant)
	print(Plant.Modules)
	
	
	
end
createPlant(.5,Vector3.new(10,07,0))

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