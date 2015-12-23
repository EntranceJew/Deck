# Deck
This is a library written for LOVE to provide a playlist interface for a sequence of video or sound files. I have no idea what will happen if you run this without using a version of love built without support for love.video or even a version of love lesser than 0.10.0.

# Public API Functions
## deck:init()
Initialize Deck or use it as shorthand to wipe its state. If used to wipe its state, it may not stop the current video from playing, for that use `deck:stop()` or `deck:destroyCurrentItem()` before calling `deck:init()`.

## deck:update(dt)
Check if the current item is still playing, whether it should advance tracks or just stop.

## deck:getCurrentItem()
Get whatever is "active", be it a video or a source.

## deck:insertItem(item, index*)
* **item** `string/Object` either a file path or a usable love object.
* **index** `int` where to insert the items, leave nil to just put it on the end.
Add a file or Object to the playlist.

## deck:insertDirectory(folderpath, index*)
* **folderpath** `string` a directory to scan for files and insert.
* **index** `int` where to insert the items, leave nil to just put it on the end.
Add an entire directory to the playlist. Does not recurse. Uses `deck:insertItem()` internally. 
Since getDirectoryItems has no predictable order, it will insert the items in the reverse order they were found if an index is specified; otherwise it will add them in their found order to the end of the playlist.

## deck:clear()
Wipe the current playlist. Does not stop the playlist internally.

## deck:previous()
Move backwards in the playlist, doesn't verify that position exists.

## deck:next()
Move forwards in the playlist, doesn't verify that position exists.

## deck:random()
Load a random playlist index. This prepares the video by loading it into memory, so repeatedly calling this is not advisable.

## deck:shuffle()
Randomly reshuffle the playlist. If the current video index changes, it will load the video at its new position.

## deck:play()
Play the entire playlist. It will load an item from the playlist into memory if there is not one loaded at present.

## deck:stop()
Stop the entire playlist. Moves the playlist index back to the beginning. Unloads the active playlist item if there is any.

# Internal Functions
You shouldn't need these, but if you do, I won't blame you.

## deck:loadItem(index)
* **index** `int` which item in the playlist to load.
Load an item from the playlist at the specified index. If there is an active playlist item, it is unloaded. Returns false if the provided index is nil.
If the playlist item at the specified index is a string, it will attempt to create a Source from it. If that Source is created, it will then attempt to create a Video from it. If the Video is created, it assigns the Source to the Video to safely create a video from a file that could potentially be a video or and/or source.
It does all this because pcalling `love.graphics.newVideo` with or without the loadaudio flag may cause a crash if passed an mp3 or something it wasn't expecting AND because newSource will extract the audio portion of a video.

## deck:destroyCurrentItem()
Unloads the current item, pausing and rewinding it first to prevent Sources to continue to play in the background.

## deck:isItemDone()
Checks to see if the current playlist item has finished. This is used internally by the update function. This is mostly for easy expansion of what is considered a playlist item later on.

## deck:print(...)
A debug print function that wraps `print()`. If `deck.useDebugPrints` is set to true, it will spit out a bunch of status messages to determine the source of any love hardcrashes.
