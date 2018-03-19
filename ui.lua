function drawUI()
  toolBar()
  panels()
  faders()
  menuDialog()
end

function toolBar()
  love.graphics.setColor(38,50,56,255)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(230, 230, 230, 255)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 20)
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.print("File", 10, 5)
  love.graphics.print("Page ("..page_number .. ")", 50, 5)
end

function faders()
  for i = 1,4 do
    love.graphics.setColor(44, 58, 65, 255)
    love.graphics.rectangle("fill", (i*10) + ((i-1)* (love.graphics.getWidth() - 50) / 4), love.graphics.getHeight() - 210, (love.graphics.getWidth() - 50) / 4, 200)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(label[i]:sub(1,10), 5 + (i * 10) + ((i-1)* (love.graphics.getWidth() - 50) / 4), love.graphics.getHeight() - 15, 3*math.pi/2, 2, 2)
    if i ~= 1 then
      love.graphics.draw(colourButtonSmall, (i*10) + ((i-1)* (love.graphics.getWidth() - 50) / 4) + (love.graphics.getWidth() - 50)/4 - 90, love.graphics.getHeight() - 200,0,0.16,0.16)
    end
  end

  for i = 1,8 do
    if i/2 ~= math.floor(i/2) then
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.draw(faderBackground, 60 + (math.ceil(i/2)*10) + ((math.ceil(i/2)-1)* (love.graphics.getWidth() - 50) / 4), love.graphics.getHeight() - 200,0,1,0.9)
      love.graphics.setColor(38,50,56,255)
      love.graphics.rectangle("fill", 38 + (math.ceil(i/2)*10) + ((math.ceil(i/2)-1)* (love.graphics.getWidth() - 50) / 4), love.graphics.getHeight() - faderHeight[i], 50, 20)
    else
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.draw(faderBackground2, 60 + (i/2*10) + ((i/2-1)* (love.graphics.getWidth() - 50) / 4) + 90, love.graphics.getHeight() - 200,0,1,0.9)
      love.graphics.setColor(38,50,56,255)
      love.graphics.rectangle("fill", 38 + (i/2*10) + ((i/2-1)* (love.graphics.getWidth() - 50) / 4) + 90, love.graphics.getHeight() - faderHeight[i], 50, 20)
    end
  end
end

function panels()
  for i = 1, #soundData do
    if i < x_limit + 1 then
      y = 0
      x = i
    else
      y = math.floor(i/x_limit)
      if i/x_limit == math.floor(i/x_limit) then
        x = x_limit
        y = y -1
      else
        x = i - y*x_limit
      end
    end
    if colour[i] == 1 then
      love.graphics.setColor(44, 58, 65, 255)
    elseif colour[i] == 2 then
      love.graphics.setColor(224, 108, 117, 255)
    elseif colour[i] == 3 then
      love.graphics.setColor(209, 154, 86, 255)
    elseif colour[i] == 4 then
      love.graphics.setColor(220, 165, 86, 255)
    elseif colour[i] == 5 then
      love.graphics.setColor(152, 195, 118, 255)
    elseif colour[i] == 6 then
      love.graphics.setColor(115, 201, 144, 255)
    elseif colour[i] == 7 then
      love.graphics.setColor(88, 175, 239, 255)
    elseif colour[i] == 8 then
      love.graphics.setColor(198, 117, 215, 255)
    end
    if y - panel_offset <= y_limit - 1 and y - panel_offset > -1 then
      love.graphics.rectangle("fill", (10 * x) + ((x-1) * 201.5), 20 + (10*((y-panel_offset)+1) + (150 * (y-panel_offset))), 201.5, 150)
      love.graphics.setColor(255, 255, 255, 255)
      if files[i]:len() <= 21 then
        love.graphics.print(files[i], (10 * x) + ((x-1) * 201.5) + 5, 20 + (10*((y-panel_offset)+1)) + (150 * (y-panel_offset)) + 5,0,1.25,1.25)
      else
        love.graphics.print(files[i]:sub(1, 18) .. "...", (10 * x) + ((x-1) * 201.5) + 5, 20 + (10*((y-panel_offset)+1)) + (150 * (y-panel_offset)) + 5,0,1.25,1.25)
      end
      if UpdateSpectrum then
        max = 0
        for bar = 1, #spectrum[i]/2 do
          if spectrum[i][bar]:abs() > max then
            max = spectrum[i][bar]:abs()
          end
        end
        love.graphics.setColor(0, 255, 0, 255)
        if max / -3 >= -110 then
          love.graphics.rectangle("fill", 180 + (x * 10) + ((x-1) * 201.5), 20 + (10*((y-panel_offset)+1) + (150 * (y-panel_offset))) + 130, 10, max / -3)
        else
          love.graphics.rectangle("fill", 180 + (x * 10) + ((x-1) * 201.5), 20 + (10*((y-panel_offset)+1) + (150 * (y-panel_offset))) + 130, 10, -110)
        end
      end
    end
  end
end

function menuDialog()
  if menu["file"] == true then
    love.graphics.setColor(230, 230, 230, 255)
    love.graphics.rectangle("fill", 0, 20, 250, 35)
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.rectangle("line", 0, 20, 250, 35)
    love.graphics.print("Search for track files", 20, 30)
  elseif menu["page"] == true then
    love.graphics.setColor(230, 230, 230, 255)
    love.graphics.rectangle("fill", 40, 20, 250, 55)
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.rectangle("line", 40, 20, 250, 55)
    love.graphics.print("Previous Page", 60, 30)
    love.graphics.print("Next Page", 60, 55)
  end
end
