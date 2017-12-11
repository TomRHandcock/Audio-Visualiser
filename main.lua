require "luafft"
function love.load()
  love.filesystem.createDirectory("music")
  import = {}
  files = {}
  soundData = {}
  audio = {}
  spectrum = {}
  UpdateSpectrum = {}
  time = 0
  UpdateSpectrum[1] = false
  max = 0
  menu = {}
  menu["file"] = false
end

function love.update(dt)
  for track = 1, #audio do
    if audio[track]:isPlaying() == true then
      SpectrumUpdate(dt, track)
    end
  end
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
  love.graphics.setColor(38,50,56,255)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(230, 230, 230, 255)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 20)
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.print("File", 10, 5)

  for i = 1, #soundData do
    if i < 7 then
      y = 0
      x = i
    else
      y = math.floor(i/7)
      x = i - y*7
    end
    love.graphics.setColor(44, 58, 65, 255)
    love.graphics.rectangle("fill", (10 * x) + ((x-1) * 200), 20 + (10*(y+1) + (150 * y)), 200, 150)
    love.graphics.setColor(255, 255, 255, 255)
    if files[i]:len() <= 27 then
      love.graphics.print(files[i], (10 * x) + ((x-1) * 200) + 5, 20 + (15*(y+1)) + (150 * (y)))
    else
      love.graphics.print(files[i]:sub(1, 24) .. "...", (10 * x) + ((x-1) * 200) + 5, 20 + (15*(y+1)) + (150 * (y)))
    end
    if UpdateSpectrum then
      max = 0
      for bar = 1, #spectrum[i]/2 do
        if spectrum[i][bar]:abs() > max then
          max = spectrum[i][bar]:abs()
        end
      end
      love.graphics.setColor(0, 255, 0, 255)
      love.graphics.rectangle("fill", 180 + (x * 10) + ((x-1) * 200), 20 + (10*(y+1) + (150 * y)) + 130, 10, max / -3)
    end
  end
  drawUI()
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
  for i=1,#soundData do
    if i < 7 then
      tileY = 0
      tileX = i
    else
      tileY = math.floor(i/7)
      tileX = i - tileY*7
    end
    if x >= (10 * tileX) + ((tileX-1) * 200) and x <= (10 * tileX) + ((tileX) * 200) then
      print("X is " .. tileX)
      if y >= 20 + (10*(tileY+1) + (150 * tileY)) and y <= 20 + (10*(tileY+1) + (150 * tileY)) + 150 then
        print("Y is " .. y)
        love.audio.play(audio[i])
      end
    end
  end
  if menu["file"] == true then
    if x >= 0 and x <= 250 then
      if y >= 20 and y <= 60 then
        searchForTracks()
      end
    end
  menu["file"] = false
  end
  if x >= 0 and x <= 30 then
    if y >= 0 and y <= 20 then
      menu["file"] = true
    end
  end
end

function drawUI()
  if menu["file"] == true then
    love.graphics.setColor(230, 230, 230, 255)
    love.graphics.rectangle("fill", 0, 20, 250, 40)
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.rectangle("line", 0, 20, 250, 40)
    love.graphics.print("Search for track files", 20, 35)
  end
end

function searchForTracks()
  import = love.filesystem.getDirectoryItems("music")
  for i=1,#import do
    files[#files + 1] = import[i]
  end
  for key, value in pairs(import) do
    print(key .. ") " .. value)
    soundData[#soundData + 1] = love.sound.newSoundData("music/" .. value)
    audio[#soundData] = love.audio.newSource(soundData[#soundData], "stream")
    spectrum[#soundData] = {}
  end
end
