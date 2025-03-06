local detector = peripheral.find("playerDetector")

while true do
local event, username, dimension = os.pullEvent("playerJoin")
print("Player" .. username .. "joined the server  in the dimension " .. dimension)
local time = os.epoch("utc") / 1000
local day = os.date(day)
print(textutils.serialise(day))
end