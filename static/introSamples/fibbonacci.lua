--fibbonacci

function fib(n)
  local a, b = 1, 1
  for i = 1, n-1 do
    a, b = b, a + b
  end
  return a
end

print(fib(6))


for i = 10, 1, -1 do
  print(i)
end
