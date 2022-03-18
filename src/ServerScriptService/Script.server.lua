
--Template Wedge
local wedge = Instance.new("WedgePart");
wedge.Anchored = true;
wedge.TopSurface = Enum.SurfaceType.Smooth;
wedge.BottomSurface = Enum.SurfaceType.Smooth;

wedge.Material = Enum.Material.SmoothPlastic 
wedge.CastShadow = false

local function draw3dTriangle(a, b, c, parent) -- Shamelessly Stolen from @EgoMoose. Source: https://github.com/EgoMoose/Articles/blob/master/3d%20triangles/3D%20triangles.md#triangle-decomposition
	local edges = {
		{longest = (c - a), other = (b - a), origin = a},
		{longest = (a - b), other = (c - b), origin = b},
		{longest = (b - c), other = (a - c), origin = c}
	};

	local edge = edges[1];
	for i = 2, #edges do
		if (edges[i].longest.magnitude > edge.longest.magnitude) then
			edge = edges[i];
		end
	end

	local theta = math.acos(edge.longest.unit:Dot(edge.other.unit));
	local w1 = math.cos(theta) * edge.other.magnitude;
	local w2 = edge.longest.magnitude - w1;
	local h = math.sin(theta) * edge.other.magnitude;

	local p1 = edge.origin + edge.other * 0.5;
	local p2 = edge.origin + edge.longest + (edge.other - edge.longest) * 0.5;

	local right = edge.longest:Cross(edge.other).unit;
	local up = right:Cross(edge.longest).unit;
	local back = edge.longest.unit;

	local cf1 = CFrame.new(
		p1.x, p1.y, p1.z,
		-right.x, up.x, back.x,
		-right.y, up.y, back.y,
		-right.z, up.z, back.z
	);

	local cf2 = CFrame.new(
		p2.x, p2.y, p2.z,
		right.x, up.x, -back.x,
		right.y, up.y, -back.y,
		right.z, up.z, -back.z
	);

	-- put it all together by creating the wedges

	local wedge1 = wedge:Clone();
	wedge1.Size = Vector3.new(0.2, h, w1);
	wedge1.CFrame = cf1;
	wedge1.Parent = parent;


	local wedge2 = wedge:Clone();
	wedge2.Size = Vector3.new(0.2, h, w2);
	wedge2.CFrame = cf2;
	wedge2.Parent = parent;

	wedge1.Name = z or "1"
	wedge2.Name = z or "2"


	return wedge1,wedge2
end


draw3dTriangle(Vector3.new(0,0,0),Vector3.new(0,1,0),Vector3.new(0,0,1),workspace)


local function Skinify(path)
	local r = 10
	local polySides = 5
	local dTheta = 2*math.pi/polySides
	local sideLength = 2*math.tan(dTheta/2)*r
	
	
	for i, m0 in pairs(path) do
		local m1 = path[i+1]
		if m1 then
			local dm = m1-m0
			
			for theta = 0, 2*math.pi, dTheta do		
				local sM = m0+Vector3.new(r*math.sin(theta),0,r*math.cos(theta))
				--C-----D
				--|     |
				--|     |
				--A-----B

				
				local A = sM - sideLength/2*Vector3.new(math.sin(theta+math.pi/2),0,math.cos(theta+math.pi/2))
				local B = sM + sideLength/2*Vector3.new(math.sin(theta+math.pi/2),0,math.cos(theta+math.pi/2))
				local C = A + dm
				local D = B + dm
				
				--local part = Instance.new("Part")
				--part.Anchored = true
				--part.Size = Vector3.new(.5,.5,.5)
				--part.Parent = workspace
				--part.Position = A
				--local part = Instance.new("Part")
				--part.Anchored = true
				--part.Size = Vector3.new(.5,.5,.5)
				--part.Parent = workspace
				--part.Position = B 
				--local part = Instance.new("Part")
				--part.Anchored = true
				--part.Size = Vector3.new(.5,.5,.5)
				--part.Parent = workspace
				--part.Position = C 
				--local part = Instance.new("Part")
				--part.Anchored = true
				--part.Size = Vector3.new(.5,.5,.5)
				--part.Parent = workspace
				--part.Position = D 	
				
				local T1 = draw3dTriangle(D,C,A,workspace)
				local T2 = draw3dTriangle(A,B,D,workspace)
				
				
				
			end
		end
	end
	
end

local path = {
	Vector3.new(0,0,0),
	Vector3.new(0,10,0),
	Vector3.new(20,30,0)
}
Skinify(path)