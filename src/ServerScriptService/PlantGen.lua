--!!Plant Ecosystem Control. Based off of journal "Synthetic Silviculture: Multi-scale Modeling of Plant Ecosystems" https://storage.googleapis.com/pirk.io/papers/Makowski.etal-2019-Synthetic-Silviculture.pdf !!--
local PlantGen = {}


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

local function GetFirstNode(Plant)
	--Returns the first node of a plant (if existant)
	return Plant.Modules[1] and Plant.Modules[1].Nodes[1]
end
function PlantGen.GetEndNodes(Plant)
	--Get Upper All Upper Nodes of Node in Plant
	local UpperNodes = {}
	
	--Create a queue to process all upper nodes
	local childQueue = {} --Children Nodes to Be Processed (Basically Groups of Nodes {Node1,Node2},{Node3},..) 
	table.insert(childQueue,{GetFirstNode(Plant)})
	
	while (#childQueue > 0) do 
		wait()
		for _, node in pairs(childQueue[1]) do 
			
			if node.Children and #node.Children > 0 then
				table.insert(childQueue,node.Children)
			else
				table.insert(UpperNodes,node)
			end
		end
		
		table.remove(childQueue,1)
	end
	
	return UpperNodes
end


local function GetVectorRotation(Vect)
	--  local normal = Vect.Unit
	--  if (Vect.Magnitude == 0) then
	-- 	 normal = Vect
	--  end
	 local theta_y = math.deg(math.asin(Vect.Y/Vect.Magnitude))
	 local theta_x = math.deg(math.atan2(Vect.Z,Vect.X))

	 if Vect.Z < 0 then
		 theta_y = 180-theta_y 
	 end

	 return Vector2.new(theta_x,theta_y)
end

local function SetVectorRotation(Vect,direction,theta)
	--//Rotate a vector about the origin



	
	local xyz_1


	local xz_0 = Vector2.new(Vect.X,Vect.Z)

	local xzNormal 
	if (xz_0.Y == 0 and xz_0.X == 0 ) then
		xzNormal = Vector2.new(1,0)
	else
		xzNormal = xz_0.Unit
	end


	if direction == "Y" then
		
		--Get Current Rotation (To Know if We Should Add 180 to X)
		
		--Y
		local yMag_1 = math.sin(math.rad(theta))
		local xzMag_1 = math.cos(math.rad(theta))




		local xz_1 = xzNormal*math.abs(xzMag_1)
		
		xyz_1 = Vector3.new(xz_1.X,yMag_1,xz_1.Y)*Vect.Magnitude

		--Check if we need to reorientate x. 
		local orient_0 = GetVectorRotation(xyz_1)
		if (xzMag_1 < 0 and Vect.Z > 0) or (xzMag_1 > 0 and Vect.Z < 0) then
			xyz_1 = SetVectorRotation(xyz_1,"X",orient_0.X+180)
			
		end

	
	elseif direction == "X" then
		local xzMag = math.sqrt(Vect.Magnitude^2-Vect.Y^2)
		xyz_1 = Vector3.new(xzMag*math.cos(math.rad(theta)),Vect.Y,xzMag*math.sin(math.rad(theta)))

	end

	return xyz_1
	
	
end


local function RotateNode(Node,direction,theta)
	local pos = Node.Position
	local parentPos = Node.Parent.Position
	local look = CFrame.new(parentPos,pos)
	local look2 

	if direction == "Z" then
		look2 = look*CFrame.Angles(math.rad(0),math.rad(0),math.rad(theta))
	elseif direction == "Y" then
		local orient_0 = GetVectorRotation(look.LookVector) 
		local theta_1 = (theta+orient_0.Y)%360

		local xyz_1 = SetVectorRotation(look.LookVector,direction,theta_1)

		look2 = CFrame.new(parentPos,parentPos+xyz_1)

	elseif direction == "X" then 
		local orient_0 = GetVectorRotation(look.LookVector) 
		local theta_1 = (theta+orient_0.X)%360

		local xyz_1 = SetVectorRotation(look.LookVector,direction,theta_1)

		look2 = CFrame.new(parentPos,parentPos+xyz_1)


	end


	--Adjust Upper Nodes (Relative To Node)
	local UpperNodes = GetUpperNodes(Node)
	table.insert(UpperNodes,Node)
	for _, UpperNode in pairs(UpperNodes) do

		local x = look:Inverse()*UpperNode.Position
		-- local x = UpperNode.Position*look:Inverse()
		UpperNode.Position = look2*x


		
	end

end
local function SetNodeOrientation(Node,direction,theta)
	local xyz_0 = Node.Position-Node.Parent.Position
	local dist = xyz_0.Magnitude

	local xyz_1 = SetVectorRotation(xyz_0,direction,theta)
	


	local pos = Node.Position
	local parentPos = Node.Parent.Position
	local look = CFrame.new(parentPos,pos)
	
	local look2 = CFrame.new(parentPos,parentPos+xyz_1)
	




	
	
	--Adjust Upper Nodes (Relative To Node)
	local UpperNodes = GetUpperNodes(Node)
	table.insert(UpperNodes,Node)
	for _, UpperNode in pairs(UpperNodes) do

		local x = look:Inverse()*UpperNode.Position
		-- local x = UpperNode.Position*look:Inverse()
		UpperNode.Position = look2*x


		
	end



end

local function Orientation(Node)
	--Returns the Orientation of Node 
	local look = Node.Position-Node.Parent.Position
	return GetVectorRotation(look)
end


local Node_Temp = game:GetService("ServerStorage"):WaitForChild("Node") --For use in VVV 
function PlantGen.GeneratePlantNodes(Plant)
	--Create physicial parts to represent plant nodes (For Testing Purposes )
	Plant.Folder:ClearAllChildren()
	
	for ModuleID, Module in pairs(Plant.Modules) do
		local ModuleFolder = Instance.new("Folder")
		ModuleFolder.Name = ModuleID
		ModuleFolder.Parent = Plant.Folder
		
		for NodeID, Node in pairs(Module.Nodes) do 
			local nodePart = Node_Temp:Clone()
			nodePart.Position= Node.Position
			-- nodePart.Position= Node.CFrame.Position
			nodePart.Name = NodeID
			nodePart.Parent = ModuleFolder


			Node.Part = nodePart
		end
	end
	
end



function PlantGen.addModule(Plant, parentModuleID, parentNodeID,modulePrototypeName)
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

		local pos = protoNode.Position+PlacementPos
		newNode.CFrame = CFrame.new(pos,PlacementPos)
		
		newModule.Nodes[protoNodeID] = newNode
	end
	
	
	
	
	Plant.Modules[newModule.ID] = newModule
	
	--Assign Parent/Child Variables
	--if ParentNode then
	--	table.insert(ParentNode.Children,newModule)

	--end
	
	
	return newModule
	
end


function PlantGen.createPlant(AC, Pos)
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
	local Module = PlantGen.addModule(Plant,nil,nil,"A")
	local Module2 = PlantGen.addModule(Plant,1,3,"A")
	
	local Node = Module2.Nodes[2] 
	local ParentOrient = Orientation(Node.Parent)
	print(ParentOrient)
	SetNodeOrientation(Node,"Y",ParentOrient.Y)
	SetNodeOrientation(Node,"X",ParentOrient.X)
	
	
	return Plant
	
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
			i = i +  1
			
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


return PlantGen