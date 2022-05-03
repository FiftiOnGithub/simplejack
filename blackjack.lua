function printCentered(sText)
    local w, h = term.getSize()
    local x, y = term.getCursorPos()
    x = math.max(math.floor((w / 2) - (#sText / 2) + 1), 0)
    term.setCursorPos(x, y)
    print(sText)
end

this = peripheral.wrap("top")
term.redirect(this)
this.setTextScale(0.5)
term.setBackgroundColor(colors.green)
term.clear()
unknowncard = paintutils.loadImage("blackjack/unknowncard")
colortemplate = paintutils.loadImage("blackjack/colortemplate")
tx_you = paintutils.loadImage("blackjack/you")
button_hit = paintutils.loadImage("blackjack/hit")
button_stand = paintutils.loadImage("blackjack/stand")
tx_dealer = paintutils.loadImage("blackjack/dealer")
tx_questionmark = paintutils.loadImage("blackjack/questionmark")
cards = {}
for i = 1, 11, 1 do
  cards[tostring(i)] = paintutils.loadImage("blackjack/"..i)
end
cards["J"] = paintutils.loadImage("blackjack/J")
cards["K"] = paintutils.loadImage("blackjack/K")
cards["A"] = paintutils.loadImage("blackjack/A")
cards["0"] = paintutils.loadImage("blackjack/zero")
function recolor(image, colorfrom, colorto)
  newimage = {}
  for k,v in pairs(image) do
    newimage[k] = {}
    for ik,iv in pairs(v) do
      if iv == colorfrom then
        newimage[k][ik] = colorto
      else
        newimage[k][ik] = iv
      end
    end
  end
  return newimage
end


function drawCard(card, x, y)
  bgc = term.getBackgroundColor()
  if card.unknown then
    paintutils.drawImage(unknowncard,x,y)
    return
  end
  paintutils.drawFilledBox(x,y,x+7,y+8,colors.white)
  if card.color == colors.red then 
    paintutils.drawImage(colortemplate,x,y)
  else
    paintutils.drawImage(recolor(colortemplate,colors.red,colors.black),x,y)
  end
  paintutils.drawImage(recolor(cards[card.character],colors.white,card.color),x+2,y+2)
  term.setBackgroundColor(bgc)
end

function strsplit(str)
  local result = {}
  for letter in str:gmatch(".") do table.insert(result, letter) end
  return result
end

function randomCard(unknown) 
  local card = {}
  card.character = math.random(1,12)
  if card.character == 12 then card.character = "J" end
  if card.character == 11 then card.character = "K" end
  if card.character == 1 then card.character = "A" end
  card.value = card.character
  if type(card.character) == "string" then
    if card.character ~= "A" then
      card.value = 10
    else
      card.value = 11
    end
  end
  if math.random(1,2) == 2 then
    card.color = colors.red
  else
    card.color = colors.black
  end
  card.character = tostring(card.character)
  if unknown then card.unknown = true else card.unknown = false end
  return card
end

function calculateValue(hand)
  value = 0
  hasunknown = false
  for k,v in pairs(hand) do
    value = value + v.value
    if v.unknown then hasunknown = true end
  end
  return value,hasunknown
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end


while true do
  dealer = {}
  player = {}
  dealerturn = false
  -- Dealer's cards
  table.insert(dealer,randomCard(false))
  table.insert(dealer,randomCard(true))
  --  Player's cards
  table.insert(player,randomCard(false))
  table.insert(player,randomCard(false))
  while true do
    skip = false
    this.setTextScale(0.5)
    term.setBackgroundColor(colors.green)
    term.clear()
    paintutils.drawImage(tx_dealer,2,2)
    paintutils.drawImage(tx_you, 2,14)
    for i = 1, tablelength(dealer), 1 do
      --if i ~= tablelength(dealer) and i ~= 1 then drawCard(dealer[i],28+((i-1)*3),2) else drawCard(dealer[i],28+((i-1)*3)+6,2) end
      if i == 1 then
        drawCard(dealer[i],28,2)
      elseif i == tablelength(dealer) then
        drawCard(dealer[i],28 + ((i-1) * 4) + 6, 2)
      else
        drawCard(dealer[i],28 + ((i-1) * 4), 2)
      end
    end
    for i = 1, tablelength(player), 1 do
      --if i ~= tablelength(player) and i ~= 1 then drawCard(player[i],17+((i-1)*10 - 6),14) else drawCard(player[i],17+((i-1)*10),14) end
      
      if i == 1 then
        drawCard(player[i],17,14)
      elseif i == tablelength(player) then
        drawCard(player[i],17 + ((i-1) * 4) + 6, 14)
      else
        drawCard(player[i],17 + ((i-1) * 4), 14)
      end
    end
    if not dealerturn then
      paintutils.drawImage(button_hit,46,17)
      paintutils.drawImage(button_stand,52,17)
    end
    paintutils.drawLine(1,12,term.getSize(),12,colors.black)
    
    dealertotal,unknown = calculateValue(dealer)
    if not unknown then
      numbers = strsplit(tostring(dealertotal))
      num = 0
      for _,v in pairs(numbers) do
        paintutils.drawImage(recolor(cards[v],colors.white,colors.gray),2+(num*5),7)
          num = num + 1
      end
    else
      paintutils.drawImage(recolor(tx_questionmark,colors.white,colors.gray),2,7)
    end
    
    playertotal = calculateValue(player)
    numbers = strsplit(tostring(playertotal))
    num = 0
    for _,v in pairs(numbers) do
      paintutils.drawImage(recolor(cards[v],colors.white,colors.gray),2+(num*5),19)
        num = num + 1
    end


    if calculateValue(player) > 21 then
      foundace = false
      for k,v in pairs(player) do
        if v.value == 11 then
          v.value = 1
          foundace = true
          skip = true
        end
      end
      if not foundace then 
        sleep(1)
        this.setTextScale(1)
        w,h = term.getSize()
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,h/2)
        printCentered(" You went over 21 and busted!")
        sleep(1)
        break
      end
    end
    if calculateValue(dealer) > 21 then
      foundace = false
      for k,v in pairs(dealer) do
        if v.value == 11 then
          v.value = 1
          foundace = true
          skip = true
        end
      end
      if not foundace then 
        sleep(1)
        this.setTextScale(1)
        w,h = term.getSize()
        term.setBackgroundColor(colors.lime)
        term.clear()
        term.setCursorPos(1,h/2)
        printCentered(" You won! Dealer busted!")
        sleep(1)
        break
      end
    end
    if calculateValue(dealer) > 16 and dealerturn then
      sleep(1)
      this.setTextScale(1)
      w,h = term.getSize()
      term.setCursorPos(1,h/2)
      
      
      if calculateValue(player) > calculateValue(dealer) then
        term.setBackgroundColor(colors.lime)
        term.clear()
        printCentered(" You won! Higher cards!")
      else
        term.setBackgroundColor(colors.black)
        term.clear()
        printCentered(" You lost. Dealer got more.")
      end
      sleep(1)
      break
    end
    
    if dealerturn and not skip then
      sleep(1)
      table.insert(dealer,randomCard(false))
    end
    if skip or dealerturn then 
      sleep(0.5)
    else 
      _, _, x, y = os.pullEvent("monitor_touch")
      if y < 16 or y > 25 or x < 45 then else
        if x < 51 then
          -- HIT
          table.insert(player,randomCard(false))
          sleep(0.15)
          
        else
          -- STAND
          dealer[2].unknown = false
          dealerturn = true
        end
      end
    end
  end
end
