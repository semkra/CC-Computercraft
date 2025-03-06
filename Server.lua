local SERVER_ID = os.getComputerID()
rednet.open("top") -- Where the wireless / wired modem is
print("Server gestartet mit ID: " .. SERVER_ID)

while true do 
 local senderId, message, protocol = rednet.receive()
 print("Empfangen von " .. senderId .. ": " .. message)
 rednet.send(senderId, "Nachricht erhalten", protocol)
end