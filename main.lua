require "luafft"
require "ui"
function love.load()
  import = {}
  requiredSound = {}
  files = {}
  soundData = {}
  audio = {}
  colour = {}
  spectrum = {}
  UpdateSpectrum = {}
  menu = {}
  looping = {}
  faderChannel = {}
  faderControl = {}
  faderControl[1] = false
  faderControl[2] = false
  faderControl[3] = false
  faderControl[4] = false
  faderControl[5] = false
  faderControl[6] = false
  faderControl[7] = false
  faderControl[8] = false
  love.filesystem.createDirectory("music")
  time = 0
  UpdateSpectrum[1] = false
  max = 0
  menu["file"] = false
  menu["page"] = false
  faderBackground = love.graphics.newImage("FaderBackground.png")
  faderBackground2 = love.graphics.newImage("FaderBackground2.png")
  colourButtonSmall = love.graphics.newImage("button_setColour_small.png")
  colourButtonLarge = love.graphics.newImage("button_setColour_large.png")
  colourButton = love.graphics.newImage("ColourButton.png")
  importButton = love.graphics.newImage("button_Import.png")
  checkBox_false = love.graphics.newImage("checkBox_false.png")
  checkBox_true = love.graphics.newImage("checkBox_true.png")
  loopButton = love.graphics.newImage("LoopButton.png")
  faderHeight = {200,120,200,120,200,120,200,120}
  faderChannel[2] = 0
  faderChannel[3] = 0
  faderChannel[4] = 0
  highlightedTrack = 0
  label = {}
  label[1] = "MASTER"
  label[2] = "PRESET 1"
  label[3] = "PRESET 2"
  label[4] = "PRESET 3"
  x_limit = math.floor(love.graphics.getWidth() / 211.5)
  y_limit = math.floor((love.graphics.getHeight()-230)/160)
  page_number = 0
  panel_offset = 0
  roster_offset = 0
  displayRoster = false
  searching = false
  timeSStart = 0
end

function love.update(dt)
  for track = 1, #audio do
    if audio[track]:isPlaying() == true then
      SpectrumUpdate(dt, track)
    end
  end
  faderMove()
  if love.mouse.isDown(1) then
    controllingFader()
  end
  timeSStart = timeSStart + dt
end

function love.resize(w, h)
  x_limit = math.floor(love.graphics.getWidth() / 211.5)
  y_limit = math.floor((love.graphics.getHeight()-230)/160)
  panel_offset = page_number * y_limit
end

function love.draw()
  --[[if UpdateSpectrum then
    max = 0
    for bar = 1, #spectrum/2 do
      if spectrum[bar]:abs() > max then
        max = spectrum[bar]:abs()
      end
    end
    love.graphics.rectangle("fill", 10, love.graphics.getHeight()-20, 5, max * -5)
  end]]--
  drawUI()

  if highlightFaders == true then
    love.graphics.setColor(0, 0, 255, 50)
    for i = 2,4 do
      love.graphics.rectangle("fill", (i*10) + ((i-1)* (love.graphics.getWidth() - 50) / 4), love.graphics.getHeight() - 210, (love.graphics.getWidth() - 50) / 4, 200)
    end
  end
end

function SpectrumUpdate(dt, trackNo)
  time = time + dt                                                              --Advances time
  if time > 0.02 then
    MusicPosition = audio[trackNo]:tell("samples")                                       --Works out the sample currently playing
    MusicLength = soundData[trackNo]:getSampleCount()                                    --Gets the total number of smaples in the track

    if MusicPosition < MusicLength -1536 then

      List = {}                                                                   --A table to store sound data
      for sample = MusicPosition, MusicPosition + 1023 do                         --Loops through every value from the current sample number to the sample number + 1023 (so we can get all the frequencies)
        if soundData[trackNo]:getChannels() == 1 then                                      --Does some stuff to record the level of each frequency to a table
          List[#List + 1] = complex.new(soundData[trackNo]:getSample(sample),0)
        else
          List[#List + 1] = complex.new(soundData[trackNo]:getSample(sample * 2),0)
        end
      end

      spectrum[trackNo] = fft(List, false)                                                 --Passes our levels to an FFT function
      for i,v in ipairs(List) do
        List[i] = List[i] * 3                                                     --Multiplies everything in our list by 3
      end
      time = 0
      UpdateSpectrum = true
    end
  end
end

function love.mousereleased(x, y, button, isTouch)
  if displayRoster == true then
    if love.mouse.getX() >= love.graphics.getWidth()/2-180 and love.mouse.getX() <= love.graphics.getWidth()/2-143 then
      print("Mouse pressed")
      for b=1,13 do
        if love.mouse.getY() > (love.graphics.getHeight()/2-250) + (b-1)*37 and love.mouse.getY() <= (love.graphics.getHeight()/2-250) + (b)*37 then
          if requiredSound[b+roster_offset] == true then
            requiredSound[b+roster_offset] = false
          else
            requiredSound[b+roster_offset] = true
          end
        end
      end
    elseif x >= love.graphics.getWidth()/2 + 57 and x <= love.graphics.getWidth()/2 + 189.8 then
      if y >= love.graphics.getHeight()/2+250 and y <= love.graphics.getHeight()/2+293 then
        importTracks()
        displayRoster = false
      end
    end
  end
  if highlightFaders == true then
    for i=2,4 do
      if x >= (i*10) + ((i-1)* (love.graphics.getWidth() - 50) / 4) and x <= (i*10) + ((i-1)* (love.graphics.getWidth() - 50) / 4) + (love.graphics.getWidth() - 50) / 4 then
        if y >= love.graphics.getHeight() - 210 and y <= love.graphics.getHeight() - 10 then
          faderChannel[i] = highlightedTrack
          faderHeight[i*2 - 1] = (audio[highlightedTrack]:getVolume()*160)+40
          label[i] = files[highlightedTrack]
        end
      end
    end
    highlightFaders = false
  end
  for i=1,#soundData do
    if i < x_limit then
      tileY = 0
      tileX = i
    else
      tileY = math.floor(i/x_limit)
      if i/x_limit == math.floor(i/x_limit) then
        tileX = x_limit
        tileY = tileY -1
      else
        tileX = i - tileY*x_limit
      end
    end
    print(faderActive)
    if menu["file"] == false and menu["page"] == false and faderActive == false then
      if x >= (10 * tileX) + ((tileX-1) * 200) and x <= (10 * tileX) + ((tileX) * 200) then
        print("X is " .. tileX)
        if y >= 20 + (10*((tileY-panel_offset)+1) + (150 * (tileY-panel_offset))) and y <= 20 + (10*((tileY-panel_offset)+1) + (150 * (tileY-panel_offset))) + 150 then
          print("Y is " .. y)
          if tileY - panel_offset <= y_limit - 1 and tileY - panel_offset > -1 then
            if button == 1 then
              --X and Y check for loop button
              if x >= 5 + (10 * tileX) + ((tileX-1) * 201.5) + 5 and x <= 5 + (10 * tileX) + ((tileX-1) * 201.5) + 75 then
                if y >= 100 + (10*((tileY-panel_offset)+1)) + (150 * (tileY-panel_offset)) + 5 and y <= 100 + (10*((tileY-panel_offset)+1)) + (150 * (tileY-panel_offset)) + 61 then
                  if audio[i]:isLooping() == true then
                    audio[i]:setLooping(false)
                  else
                    audio[i]:setLooping(true)
                  end
                else
                  if audio[i]:isPlaying() then
                    audio[i]:stop()
                  else
                    love.audio.play(audio[i])
                  end
                  --Play/pause
                end
              else
                --Play/pause
                if audio[i]:isPlaying() then
                  audio[i]:stop()
                else
                  love.audio.play(audio[i])
                end
              end
            elseif button == 2 then
              highlightFaders = true
              highlightedTrack = i
            end
          end
        end
      end
    end
  end
  if menu["file"] == true then
    if x >= 0 and x <= 250 then
      if y >= 20 and y <= 60 then
        findTracks()
        timeASearch = timeSStart
      end
    end
  menu["file"] = false
  end

  if menu["page"] == true then
    if x >= 40 and x <= 290 then
      if y >= 20 and y <= 50 then
        page_number = page_number - 1
        panel_offset = page_number * y_limit
      elseif y >= 50 and y <= 100 then
        page_number = page_number + 1
        panel_offset = page_number * y_limit
      end
    end
  menu["page"] = false
  end

  if y >= 0 and y <= 20 then
    if x >= 0 and x <= 30 then
      menu["file"] = true
    elseif x >= 40 and x <= 110 then
      menu["page"] = true
    end
  end
  for i=2,4 do
    if love.graphics.getWidth() < 1400 then
      if x >= (i*10) + ((i-1)* (love.graphics.getWidth() - 50) / 4) + (love.graphics.getWidth() - 50)/4 - 90 and x <= (i*10) + ((i-1)* (love.graphics.getWidth() - 50) / 4) + (love.graphics.getWidth() - 50)/4 - 10 then
        if y >= love.graphics.getHeight() - 200 and y <= love.graphics.getHeight() - 156 then
          colour[faderChannel[i]] = colour[faderChannel[i]] + 1
          if colour[faderChannel[i]] > 8 then
            colour[faderChannel[i]] = 1
          end
        end
      end
    else
      if x >= (i*10) + ((i-1)* (love.graphics.getWidth() - 50) / 4) + (love.graphics.getWidth() - 50)/4 - 140 and x <= (i*10) + ((i-1)* (love.graphics.getWidth() - 50) / 4) + (love.graphics.getWidth() - 50)/4 - 12 then
        if y >= love.graphics.getHeight() - 200 and y <= love.graphics.getHeight() - 166 then
          colour[faderChannel[i]] = colour[faderChannel[i]] + 1
          if colour[faderChannel[i]] > 8 then
            colour[faderChannel[i]] = 1
          end
        end
      end
    end
  end
end

function love.mousepressed(x, y, button, isTouch)
  faderActive = false
end

function controllingFader()
  for i=1,8 do
    if faderControl[i] == true then
      faderActive = true
    end
  end
end

function findTracks()
  roster = love.filesystem.getDirectoryItems("music")
  for i=1,#roster do
    requiredSound[i] = true
  end
  displayRoster = true
end

function importTracks()
  for i=1,#roster do
    if requiredSound[i] == true then
      files[#files + 1] = roster[i]
    end
  end
  for key, value in pairs(files) do
    print(key .. ") " .. value)
    soundData[#soundData + 1] = love.sound.newSoundData("music/" .. value)
    audio[#soundData] = love.audio.newSource(soundData[#soundData], "stream")
    spectrum[#soundData] = {}
    colour[#soundData] = 1
    looping[#soundData] = false
  end
  searching = false
end

function faderMove()
  if love.mouse.isDown(1) and faderControl[4] ~= nil then
    for i=1,8 do
      if i / 2 ~= math.floor(i/2) then
        if love.mouse.getX() >= 35 + (math.ceil(i/2)*10) + ((math.ceil(i/2)-1)* (love.graphics.getWidth() - 50) / 4) and love.mouse.getX() <= 35 + (math.ceil(i/2)*10) + ((math.ceil(i/2)-1)* (love.graphics.getWidth() - 50) / 4) + 50 then
          if love.mouse.getY() >= love.graphics.getHeight() - faderHeight[i] and love.mouse.getY() <= love.graphics.getHeight() - faderHeight[i] + 20 then
            faderControl[i] = true
          else
            faderControl[i] = false
          end
        else
          faderControl[i] = false
        end
      else
        if love.mouse.getX() >= 35 + (i/2*10) + ((i/2-1)* (love.graphics.getWidth() - 50) / 4) + 90 and love.mouse.getX() <= 35 + (i/2*10) + ((i/2-1)* (love.graphics.getWidth() - 50) / 4) + 140 then
          if love.mouse.getY() >= love.graphics.getHeight() - faderHeight[i] and love.mouse.getY() <= love.graphics.getHeight() - faderHeight[i] + 20 then
            faderControl[i] = true
          else
            faderControl[i] = false
          end
        else
          faderControl[i] = false
        end
      end
    end
  end
end

function love.mousemoved(x, y, dx, dy)
  for i=1,8 do
    if faderControl[i] == true then
      if love.mouse.isDown(1) then
        faderHeight[i] = faderHeight[i] - dy
        if faderHeight[i] > 200 then
          faderHeight[i] = 200
        elseif faderHeight[i] < 40 then
          faderHeight[i] = 40
        end
      else
        faderControl[i] = false
      end
      love.audio.setVolume((faderHeight[1]-40)/160)
      if i>=2 and i<=8 then
        if i/2 ~= math.floor(i/2) then
          if faderChannel[math.ceil(i/2)] ~= 0 then
            audio[faderChannel[math.ceil(i/2)]]:setVolume((faderHeight[i]-40)/160)
            print("Setting the volume of : " .. faderChannel[math.ceil(i/2)])
          end
        else
          if faderChannel[i/2] ~= 0 then
            audio[faderChannel[i/2]]:setPitch((faderHeight[i]+60)/180)
            print("Setting the pitch of : " .. faderChannel[i/2])
          end
        end
      end
    end
  end
end

function love.wheelmoved(x, y)
  if displayRoster == true then
    print("Mouse wheel moving")
    if love.mouse.getX() > love.graphics.getWidth()/2-200 and love.mouse.getY() < love.graphics.getWidth()/2+200 then
      if love.mouse.getY() > love.graphics.getHeight()/2-300 and love.mouse.getY() < love.graphics.getHeight()/2+300 then
        print("Mouse is in right place")
        if y > 0 then
          if roster_offset > 0 then
            roster_offset = roster_offset - 1
          end
        else
          if roster_offset + 13 < #roster then
            roster_offset = roster_offset + 1
          end
        end
      end
    end
  end
end
