Textbox = {}
Textbox.mt =  {__index = Textbox}
local lg = love.graphics
local utf8 = require("utf8")
local base64 = require("base64")
local md5 = require("md5")

function Textbox:new(box)
  box = box or {}
  box.name = box.name or ""
  box.x = box.x or 0
  box.y = box.y or 0
  box.w = box.w or 0
  box.h = box.h or 0
  box.colors = {
    background = { 255, 255, 255, 255 },
    text = { 40, 40, 40, 255 }
  }
  box.text = ""
  box.displaytext = ""
  box.displaytextbar = "|"
  box.active = false
  box.timer = 0
  box.line = false
  box.charoffset = 0
  
  setmetatable(box, Textbox.mt)
  --table.insert(Textbox.actives, box)
  
  return box
end

TextboxPrivate = Textbox:new()
TextboxPrivate.mt =  {__index = TextboxPrivate}


local function addText(str, offset, text)
  local left = string.sub(str, 0, offset)
  local right = string.sub(str, offset + 1)
  return left .. text .. right
end

function TextboxPrivate:new(box)
  box = Textbox:new(box)
  setmetatable(box, TextboxPrivate.mt)
  box.base64 = ""
  box.stars = ""
  return box
end

function TextboxPrivate:setText(t)
  self.text = t
  self.base64 = base64.encode(md5sum(t))
  self:display()
end

function TextboxPrivate:setBase64(t)
  self.base64 = t
end

function TextboxPrivate:display()
  local s = 0
  local str = ""
  local i = #self.text
  while i > 0 do
    i = i - 1
    str = str .. "*"
  end
  repeat
    self.displaytext = string.sub(str .. "|", s, #str)
    s = s + 1
  local w, wt = fonts.robotosmall:getWrap(self.displaytext, self.w)
  until #wt <= 1
  self.displaytextbar = addText(self.displaytext, self.charoffset, "|")
end

function TextboxPrivate:click(x,y)
  if
    x >= self.x and
    x <= self.x + self.w and
    y >= self.y and 
    y <= self.y + self.h
  then
    self.active = true
    if self.faketext then self:clearText() end
  elseif self.active then
    self.active = false
  end
end

function Textbox:backspace()
  if not self:isActive() then return end
  local offset = math.max(self.charoffset - 1, 0)
  self.text = string.sub(self.text, 0, offset) .. string.sub(self.text, self.charoffset + 1)
  self.charoffset = offset
  self:display()
end

function Textbox:delete()
  if not self:isActive() then return end
    self.text = string.sub(self.text, 0, self.charoffset) .. string.sub(self.text, self.charoffset + 2)
  self:display()
end

function Textbox:setPos(x,y)
  self.x, self.y = x,y
  return self
end

function Textbox:setDimensions(w,h)
  self.w, self.h = w,h 
  return self
end

function Textbox:isActive()
  return self.active
end

function Textbox:getText()
  return self.text
end

function Textbox:display()
  local s = 0
  repeat
    self.displaytext = string.sub(self.text .. "|", s, #self.text)
    s = s + 1
  local w, wt = fonts.robotosmall:getWrap(self.displaytext, self.w)
  until #wt <= 1
  self.displaytextbar = addText(self.displaytext, self.charoffset, "|")
end

function Textbox:setText(t)
  self.text = t
  self:display()
end

function Textbox:moveLeft()
  self.charoffset = math.max(self.charoffset - 1, 0)
  self.displaytextbar = addText(self.displaytext, self.charoffset, "|")
end

function Textbox:moveRight()
  self.charoffset = math.min(self.charoffset + 1, #self.text)
  self.displaytextbar = addText(self.displaytext, self.charoffset, "|")
end


function Textbox:addText(t)
  self.charoffset = self.charoffset + 1
  self:setText(addText(self.text, self.charoffset, t))
end

function Textbox:setName(n)
  self.name = n
end

function Textbox:toggle()
  self.active = not self.active
  return self.active
end

function Textbox:update(dt)
  self.timer = self.timer + dt
  if self.timer > 0.5 then
    self.line = not self.line
    self.timer = self.timer - 0.5
  end
end

function Textbox:click(x,y)
  if
    x >= self.x and
    x <= self.x + self.w and
    y >= self.y and 
    y <= self.y + self.h
  then
    self.active = true
  elseif self.active then
    self.active = false
  end
end

function Textbox:draw()
  lg.setFont(fonts.robotosmall)
  love.graphics.setColor(unpack(self.colors.background))
  love.graphics.rectangle('line',
      self.x, self.y,
      self.w, self.h)
  local text = self.displaytext
  if self.line and self:isActive() then text = self.displaytextbar end
  love.graphics.setColor(unpack(self.colors.text))
  love.graphics.printf(text,
      self.x + 1, self.y,
      self.w, 'left')
  if self.name ~= "" then
    love.graphics.setColor(unpack(self.colors.text))
    love.graphics.printf(self.name,
        self.x, self.y - 20,
        self.w, 'left')
    end
  love.graphics.setColor(1,1,1)
end

function Textbox:clearText()
  self.text = ""
  self.displaytext = ""
  self.displaytextbar = "|"
  self.charoffset = 0
end
