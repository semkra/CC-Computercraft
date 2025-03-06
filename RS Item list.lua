-- Laden der notwendigen Peripheriegeräte
local rsBridge = peripheral.find("rsBridge")
local monitor = peripheral.find("monitor")
 
if not rsBridge then
  error("RS Bridge nicht gefunden. Bitte überprüfen Sie die Konfiguration.")
end
 
if not monitor then
  error("Monitor nicht gefunden. Bitte überprüfen Sie die Konfiguration.")
end
 
monitor.setTextScale(0.5)  -- Anpassen je nach Monitorgröße
 
local page = 1
local itemsPerPage = 10
 
-- Funktion zum Zeichnen der Navbar
local function drawNavbar()
  monitor.setCursorPos(1, 1)
  monitor.write("<< Zurueck | Vor >> | Aktualisieren")
end
 
-- Hilfsfunktion zum Sortieren der Items nach ihrer Anzahl
local function sortItemsByAmount(items)
  table.sort(items, function(a, b) return a.amount > b.amount end)
  return items
end
 
-- Funktion zum Anzeigen von Items auf dem Bildschirm
local function displayItems()
  local items = rsBridge.listItems()
  items = sortItemsByAmount(items)  -- Sortieren der Items nach Menge
  local startItem = (page - 1) * itemsPerPage + 1
  local endItem = startItem + itemsPerPage - 1
 
  monitor.clear()
  drawNavbar()
  monitor.setCursorPos(1, 2)
 
  if #items == 0 then
    monitor.write("Keine Items im Lager")
  else
    for i = startItem, math.min(endItem, #items) do
      if items[i] then
        local displayName = items[i].displayName or items[i].name  -- Fallback auf den 'name', falls 'displayName' nicht vorhanden ist
        monitor.setCursorPos(1, i - startItem + 3)
        monitor.write(displayName .. " - " .. items[i].amount)
      end
    end
  end
end
 
-- Funktion zum Wechseln der Seiten
local function changePage(dir)
  if dir == "next" and (page * itemsPerPage < #rsBridge.listItems()) then
    page = page + 1
  elseif dir == "prev" and page > 1 then
    page = page - 1
  end
  displayItems()
end
 
-- Hauptfunktion, die auf Touch-Ereignisse des Monitors reagiert
local function main()
  displayItems()
  while true do
    local event, side, x, y = os.pullEvent("monitor_touch")
    if y == 1 then
      if x >= 1 and x <= 10 then
        changePage("prev")
      elseif x >= 13 and x <= 21 then
        changePage("next")
      elseif x >= 24 and x <= 37 then
        page = 1 -- Zurücksetzen auf die erste Seite bei Aktualisierung
        displayItems()
      end
    end
  end
end
 
-- Starten des Hauptprogramms
main()