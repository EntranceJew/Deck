-- hail two satans
local deck = {
	_VERSION     = 'deck v1.0.0',
	_DESCRIPTION = 'Playlist Handling for LOVE',
	_URL         = 'https://github.com/EntranceJew/Deck',
}

-- == basic stuff
function deck:init()
	-- == state based vars
	-- what to do when we reach the end
	-- @WARNING: unused
	self.loopMode = 'none' --all, none
	-- this doesn't change unless we're told to, or the loopmode dictates it
	self.playState = 'stop' --stop, play, pause
	
	-- == internal data
	self.item = nil -- what Playlist Item we presently have loaded
	self.items = {} -- either file paths or pre-loaded sources (strings are probably best)
	self.itemIndex = -1 --which item we're peeping, -1 if we're stopped or we have no items
	
	-- == debug
	-- whether we want to make a mess of noise
	self.useDebugPrints = false
end

function deck:update(dt)
	if self.playState == 'play' then
		if self:isItemDone() then
			-- the item stopped, keep the beats running
			if self.itemIndex+1 <= #self.items then
				self:print("[debug]", "advancing item")
				self:next()
				return true
			else
				self:stop()
				self:print("[debug]", "end of the line")
				return false
			end
		end
	end
	return false
end

-- == useful api stuff here
function deck:getCurrentItem()
	self:print("[debug]", "reading current item", self.item)
	return self.item
end

function deck:insertItem(item, index)
	self:print("[debug]", "inserting item", item, index)
	if index then
		table.insert(self.items, index, item)
		
		-- update our item index so we don't get out of whack
		if index <= self.itemIndex then
			self.itemIndex = self.itemIndex + 1
		end
	else
		table.insert(self.items, item)
	end
end

function deck:insertDirectory(folderpath, index)
	-- no recursion, what are you, some kind of monster?
	local foundvids = love.filesystem.getDirectoryItems(folderpath)
	for k,v in ipairs(foundvids) do
		local abspath = folderpath .. "/" .. v
		if love.filesystem.isFile(abspath) then
			self:insertItem(abspath, index)
		end
	end
end

function deck:clear()
	self:destroyCurrentItem()
	self.items = {}
	self.itemIndex = -1
end

function deck:previous()
	self:print("[debug]", "previous doing, loadItem-1")
	return self:loadItem(self.itemIndex-1)
end

function deck:next()
	self:print("[debug]", "next doing, loadItem+1")
	return self:loadItem(self.itemIndex+1)
end

function deck:random()
	local max = #self.items
	local newIndex = love.math.random(1, max)
	
	self:loadItem(newIndex)
end

function deck:shuffle()
	-- from: https://coronalabs.com/blog/2014/09/30/tutorial-how-to-shuffle-table-items/
	local iterations = #self.items
	local j
	local curIndex = self.itemIndex

	for i = iterations, 2, -1 do
		j = love.math.random(1, i)
		self.items[i], self.items[j] = self.items[j], self.items[i]
		if curIndex == i then
			curIndex = j
		end
	end
	
	-- we're not where we used to be, so let's fix our internal state
	if curIndex ~= self.itemIndex then
		self:print("[debug]", "shuffle loadItem")
		deck:loadItem(curIndex)
	end
end

-- == PLAYER STATE MORE LIKE CELEBRATE
function deck:play()
	self.playState = 'play'
	
	-- should we load the item if it wasn't already?
	-- I mean, I guess; we don't do it anywhere else
	if not self.item then
		self:print("[debug]", "we had no item")
		-- we don't have a item index, shoot to kill
		if self.itemIndex == -1 then
			self:print("[debug]", "we also had no index")
			self.itemIndex = 1
		else
			self:print("[debug]", "we have an index though")
		end
		self:print("[debug]", "playload")
		self:loadItem(self.itemIndex)
	end
	
	self.item:play()
end

function deck:stop()
	self:print("[debug]", "stop the boats")
	self.playState = 'stop'
	self:destroyCurrentItem()
	self.itemIndex = -1
end

-- == INTERNAL ONLY YOU RUDE DUDES
function deck:loadItem(index)
	self:print("[debug]", "loadItem", index, self.items[index])
	self:destroyCurrentItem()
	self:print("[debug]", "postDestruction")
	
	if not self.items[index] then
		-- you gave me unstackable cups
		self:print("[error]", "tried to read from nonexistant item")
		return false
	end
	
	local success, item
	if type(self.items[index]) == "string" then
		self:print("[debug]", "item was string")
		success, item = pcall(love.audio.newSource, self.items[index])
		
		if success then
			self:print("[debug]", "item was a source")
			if love.video then
			
			
				self:print("[debug]", "is item also a video?")
				local suc2, vid = pcall(love.graphics._newVideo, self.items[index])
				if suc2 then
					self:print("[debug]", "item was also a video")
					vid:setSource(item)
					item = vid
				else
					self:print("[debug]", "item was not also a video")
				end
			end
		else
			self:print("[debug]", "No idea what "..self.items[index].." is meant to be.")
		end
		self:print("[debug]", "set item")
		self.item = item
	else
		self.item = self.item[index]
		self:print("[debug]", "item was not string")
	end
	
	self.itemIndex = index
	if self.playState == 'play' then
		self:print("[debug]", "resuming play")
		self.item:play()
	end
	self:print("[debug]", "loadItem play")
end

function deck:destroyCurrentItem()
	-- destroy the old item for it is a menace and will still play in the background
	if self.item then
		self:print("[debug]", "destroying item, hail satan")
		self.item:pause()
		self.item:rewind()
		self.item = nil
	else
		self:print("[debug]", "did not destroy item, had no reason")
	end
end

function deck:isItemDone()
	if not self.item then
		return true
	elseif self.item and self.item:isPlaying() then
		return false
	else
		return false
	end
end

function deck:print(...)
	if not self.useDebugPrints then return false end
	
	print(...)
end

return deck