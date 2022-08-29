------------------------------------------------
-- Settings Start: Change these as needed
global apptitle
set apptitle to "Export Albums and Folders to Disk"

global gDest
set allowUserToDest to false as boolean
set gDest to "/Volumes/media/photo" as POSIX file as text -- the destination folder (use a valid path)

global gSmartAlbum
set gSmartAlbum to "Photos in"

global gNoAction
set gNoAction to false as boolean

set allowUserToSelectAlbums to false as boolean

-- Settings End
------------------------------------------------

------------------------------------------------
-- my Functions Start

on MyPathToAlbumOrFolder(targetObject)
	-- retrive full path
	set theObject to targetObject
	set thePath to name of targetObject
	tell application "Photos"
		repeat
			try
				if class of parent of theObject is folder then
					set folderName to the name of parent of theObject
					set thePath to folderName & ":" & thePath
					set thisID to id of parent of theObject
					set theObject to folder id thisID
				else if class of parent of theObject is album then
					set albumName to the name of parent of theObject
					set thePath to albumName & ":" & thePath
					set thisID to id of parent of theObject
					set theObject to album id thisID
				end if
			on error
				set thePath to gDest & ":" & thePath
				return thePath
			end try
		end repeat
	end tell
end MyPathToAlbumOrFolder

on MyLogThis(theText)
	log theText --to console
	if not (theText starts with "#") then display notification theText with title apptitle
	set theFile to (path to downloads folder as text) & "exportalbumstofolders.txt"
	do shell script "echo " & quoted form of theText & " >> " & quoted form of (POSIX path of theFile)
end MyLogThis

-- my Functions End
------------------------------------------------

tell application "Photos"
	
	with timeout of 1120 seconds -- give 2 minutes ...
		activate
	end timeout
	
	my MyLogThis("#Start: " & (current date) as string)
	my MyLogThis("#NoAction: " & gNoAction)
	set nbPhotos to 0
	
	-- select the destination folder  --> theDestinationRootFolder
	if allowUserToDest then
		set result to choose folder with prompt "Select a destination folder to save the albums to" default location (gDest as alias)
		set gDest to ((the POSIX path of result) as text) as POSIX file as text
		set confFile to gDest & ":exportalbumstofolders.conf"
	end if
	my MyLogThis("#Destination folder: " & gDest)
	
	-- Display a dialog to select the albums
	set allAlbumNames to name of albums
	if allowUserToSelectAlbums then
		set albumNames to choose from list allAlbumNames with prompt "Select some albums" with multiple selections allowed
	else
		set albumNames to allAlbumNames
	end if
	
	-- Display a dialog to select update or replace --> fReplace
	set result to display dialog "Do you want to update or replace images?" buttons {"Replace", "Update"} default button 2 with icon 2 giving up after 10 with title apptitle
	set fReplace to (button returned of result is "Replace")
	my MyLogThis("#Replace: " & fReplace as text)
	
	if albumNames is not false then -- not cancelled
		
		set cnt to 0
		
		my MyLogThis("Processing " & ((length of albumNames) as text) & " albums")
		
		repeat with oneAlbum in albums
			
			set cnt to cnt + 1
			set albumName to name of oneAlbum
			
			if not (albumNames contains albumName) then
				
				my MyLogThis("#Album " & albumName & " not selected")
				
			else
				
				my MyLogThis("Processing " & albumName & " (" & (cnt as text) & "/" & ((count of albums) as text) & ")...")
				
				if not (albumName starts with gSmartAlbum) then
					
					-- Generate destination folder name
					set albumFolder to my MyPathToAlbumOrFolder(oneAlbum)
					
					my MyLogThis("#Managing the directory: " & albumFolder)
					set newFolder to false
					
					if not gNoAction then
						
						-- Create the destination folder
						tell application "Finder"
							if (exists albumFolder) and (fReplace is true) then
								my MyLogThis("#Removing directory: " & albumFolder)
								do shell script "rm -fr " & quoted form of (POSIX path of albumFolder) -- purge the folder in destination
								do shell script "mkdir -p " & quoted form of (POSIX path of albumFolder) -- create the folder in destination
								set newFolder to true
							end if
							if not (exists albumFolder) then
								my MyLogThis("#Creating directory: " & albumFolder)
								do shell script "mkdir -p " & quoted form of (POSIX path of albumFolder) -- create the folder in destination
								set newFolder to true
							else
								my MyLogThis("#Existing directory: " & albumFolder)
								
							end if
						end tell
					end if
					
					set allPhotos to (get media items of album albumName)
					
					-- Building the list of media not in destination folder
					if newFolder then
						my MyLogThis("#Exporting " & ((length of allPhotos) as text) & " items...")
						set mediaItemsToAttempt to allPhotos
					else
						my MyLogThis("#Checking " & ((length of allPhotos) as text) & " items...")
						set mediaItemsToAttempt to {}
						repeat with mediaItem in allPhotos
							set FilenameToCheck to albumFolder & ":" & (filename of mediaItem) as string
							tell application "Finder"
								if not (exists file FilenameToCheck) then
									my MyLogThis("#Checking file " & FilenameToCheck & ": does not exist")
									set end of mediaItemsToAttempt to mediaItem
								end if
							end tell
						end repeat
					end if
					
					-- Any work to do?
					if (count of mediaItemsToAttempt) = 0 then
						my MyLogThis("#No media to export from album name: " & albumName & " in directory: " & albumFolder)
					else
						if gNoAction then
							my MyLogThis("#Would export " & ((count of mediaItemsToAttempt) as text) & " photos from album name: " & albumName & " in directory: " & albumFolder)
						else
							with timeout of 14400 seconds -- give 4 hours instead of 2 minutes ...
								my MyLogThis("#Exporting " & (count of mediaItemsToAttempt) & " photos from album name: " & albumName & " in directory: " & albumFolder)
								export mediaItemsToAttempt to (albumFolder as alias) with using originals --  export the original versions
								set nbPhotos to nbPhotos + (count of mediaItemsToAttempt)
							end timeout
						end if
					end if
					
					-- Write status
					if not gNoAction then
						set theText to ((current date) as string) & " - " & ((count of mediaItemsToAttempt) as text) & " / " & ((length of allPhotos) as string)
						set theFile to albumFolder & ":status.txt" as string
						do shell script "echo " & quoted form of theText & " >> " & quoted form of (POSIX path of theFile)
					end if
					
				end if
			end if
		end repeat
	end if
	my MyLogThis(("#End: " & nbPhotos as string) & " at " & (current date) as string)
end tell


-- display destination folder in Finder
tell application "Finder"
	open (gDest as alias)
	return {"Done: "} & albumNames
end tell
