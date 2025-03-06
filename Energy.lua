-- monitor_energy_single_bars_with_y_axis.lua
-- Zeigt einen Live-Balkengraph für den aktuellen Energieverbrauch (Output)
-- eines Energy Detectors auf einem Advanced Monitor, inklusive Y-Achse.
 
-- ========== Konfiguration ==========
local ENERGY_DETECTOR_SIDE = "top"       -- Energy Detector oben
local POLL_INTERVAL        = 1           -- Wie oft (Sekunden) aktualisieren
local HISTORY_LENGTH       = 50          -- Wie viele Messwerte im Graph?
 
-- Breite der Y-Achse (in Zeichen)
local yAxisWidth          = 6
 
-- Anzahl der Skalen-Ticks (z.B. 5 = 0, 25%, 50%, 75%, 100%)
local TICK_COUNT          = 5
 
--------------------------------------
 
-- Peripherals einbinden
local energyDetector = peripheral.wrap(ENERGY_DETECTOR_SIDE)
if not energyDetector then
  error("Kein Energy Detector auf Seite '" .. ENERGY_DETECTOR_SIDE .. "' gefunden!")
end
 
-- Monitor suchen (alternativ: peripheral.wrap('right') o.Ä., falls man weiß, wo er ist)
local monitor = peripheral.find("monitor")
if not monitor then
  error("Kein Monitor gefunden!")
end
 
-- Monitor vorbereiten
term.redirect(monitor)
monitor.setTextScale(0.5)
monitor.clear()
monitor.setCursorPos(1, 1)
 
-- Geschichte der Verbrauchswerte (Output)
local usageHistory = {}
 
-- Funktion zum Zeichnen des Graphen
local function drawGraph()
  monitor.clear()
  local w, h = monitor.getSize()
 
  -- 1. Zeile oben bleibt für Überschrift/Aktuellen Wert
  monitor.setCursorPos(1, 1)
  local latestUsage = usageHistory[#usageHistory] or 0
  monitor.write(("Verbrauch: %.2f FE/t"):format(latestUsage))
 
  -- Platz für den Graphen beginnt ab Zeile 2
  local graphOriginY    = 2
  local graphOriginX    = yAxisWidth + 1     -- +1, damit wir nach der Y-Achse beginnen
  local availableWidth  = w - yAxisWidth     -- Gesamte Breite minus Achsen-Breite
  local availableHeight = h - (graphOriginY - 1)
 
  -- Falls das aus irgendeinem Grund zu knapp wird, hier Abbruch:
  if availableWidth < 1 or availableHeight < 1 then
    return -- Kein Platz zum Zeichnen
  end
 
  -- Maximalwert ermitteln, um die Skalierung zu bestimmen
  local maxVal = 0
  for i = 1, #usageHistory do
    if usageHistory[i] > maxVal then
      maxVal = usageHistory[i]
    end
  end
  if maxVal < 1 then
    maxVal = 1
  end
 
  -- -------------- Y-Achse (Skalierung) ---------------
  -- Wir machen TICK_COUNT Zwischen-Schritte (z.B. 0..5),
  -- damit 0% und 100% mit drin sind.
  for i = 0, TICK_COUNT do
    -- Skalar von 0.0 bis 1.0
    local scale = i / TICK_COUNT
 
    -- Entspricht in FE:
    local val = maxVal * scale
 
    -- Y-Position für den Tick:
    -- Wir zählen von unten nach oben (0 -> unten).
    local tickY = (graphOriginY + availableHeight - 1)
                  - math.floor(scale * (availableHeight - 1))
 
    -- Cursor links an der Achse setzen
    monitor.setCursorPos(1, tickY)
    monitor.setTextColor(colors.white)
    -- Kurzer Check, damit wir nicht in Zeile 1 schreiben (da ist Überschrift)
    if tickY >= 2 then
      -- Z.B. auf gerundete Werte wie 500, 1000:
      monitor.write(string.format("%4d", math.floor(val + 0.5)))
    end
  end
 
  -- -------------- Balken-Graph ---------------
  for i = 1, #usageHistory do
    local usageVal = usageHistory[i]
 
    -- X-Position für die Spalte berechnen
    local x = math.floor(((i - 1) / (HISTORY_LENGTH - 1)) * (availableWidth - 1))
              + graphOriginX
    if x > (graphOriginX + availableWidth - 1) then
      x = graphOriginX + availableWidth - 1
    end
 
    -- Höhe der Balken ermitteln
    local valScaled = math.floor((usageVal / maxVal) * availableHeight)
    if valScaled > availableHeight then
      valScaled = availableHeight
    end
 
    monitor.setTextColor(colors.red)
    -- Balken von unten nach oben zeichnen
    for barLevel = 1, valScaled do
      local drawY = (graphOriginY + availableHeight - barLevel)
      monitor.setCursorPos(x, drawY)
      monitor.write("∎")
    end
  end
 
  monitor.setTextColor(colors.white)
end
 
-- Haupt-Schleife
while true do
  -- Energie-Raten holen
  local rates = energyDetector.getTransferRate()
  local currentOutput = rates or 0  
 
  -- Neuen Messwert ablegen
  table.insert(usageHistory, currentOutput)
 
  -- Alte Werte entfernen, wenn die Liste zu groß wird
  if #usageHistory > HISTORY_LENGTH then
    table.remove(usageHistory, 1)
  end
 
  -- Neuzeichnen
  drawGraph()
 
  -- Warten
  sleep(POLL_INTERVAL)
end