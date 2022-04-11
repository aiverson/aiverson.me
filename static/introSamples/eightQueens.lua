--solve the n-queens problem by dfs

local function checkvalid(pos, n)
  for i = 1, n-1 do
    if pos[n] == pos[i] or math.abs(n - i) == math.abs(pos[n] - pos[i]) then
      return false
    end
  end
  return true
end

local function printPos(pos)
  for x, y in ipairs(pos) do
    print("x:", x-1, "y:", y-1)
  end
end

local function genPosibilites(pos, i, n, res)
  if i == n+1 then
    table.insert(res, {unpack(pos)})
  end
  for j = 1, n do
    pos[i] = j
    if checkvalid(pos, i) then
      genPosibilites(pos, i+1, n, res)
    end
  end
end

function nQueens(n)
  local res = {}
  genPosibilites({}, 1, n, res)
  print(#res)
  --[=[for i, pos in ipairs(res) do
    print(("Solution %d:"):format(i))
    printPos(pos)
  end]=]
end

nQueens(11)
io.flush()