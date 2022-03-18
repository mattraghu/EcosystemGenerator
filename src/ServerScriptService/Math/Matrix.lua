local Matrix = {_type = "Matrix"}
local mt = {
	_index = Matrix
}


function mt.__mul(M1,M2)
	local prod = {}
	
	
	for y1, M1_row in pairs(M1) do
		if prod[y1] == nil then
			prod[y1] = {}
		end
		
		for x2 = 1, #M2[1] do
			prod[y1][x2] = 0
			
			for y2 = 1, #M2 do
				prod[y1][x2] += M1_row[y2]*M2[y2][x2]

			end
		end
	end
	
	--for y1 = 1, #M1[1] do 
	--	for x2 = 1, #M2 do
	--		if prod[x2] == nil then 
	--			prod[x2] = {}
	--		end
	--		prod[x2][y1] = 0
			
	--		for y2 = 1, #M2[1] do
	--			for x1 = 1, #M1[1] do
	--				prod[x2][y1] += M1[x1][y1]*M2[x2][y2]
	--			end
	--		end
	--	end	
	--end
	
	
	
	local prod_mt = setmetatable(prod,mt)
	return prod_mt
end

function Matrix.new(contents)
	--Creates matrix using contents table
	--Verify Contents
	local len = #contents[1]
	for _, row in pairs(contents) do
		--Size Mismatch 
		if #row ~= len then
			return
		end
		
		for _, value in pairs(row) do
			if type(value) ~= "number" then
				return
			end
		end
	end
	
	local self = setmetatable(contents,mt)

	return self
end

return Matrix
