on run
	set apptitle to "Export Albums to Folders"
	set sep to ":"
	
	# all or one album
	
	set fAll to true
	set theAlbum to "all albums"
	set dialogResult to display dialog "Album to export (leave empty for all)" default answer "" buttons {"Continue"} default button 1 giving up after 10 with title apptitle
	set theAlbum to text returned of dialogResult
	if theAlbum is "" then
		set fAll to true
		set theAlbum to "unspecified album"
	else
		set fAll to false
	end if
	my trace(apptitle, ("Album to export: " & fAll as string) & " - " & theAlbum, false)
	
	# replace or not 
	
	set fReplace to true
	set dialogResult to display dialog "Action on Albums" buttons {"Replace", "Update"} default button 1 giving up after 10 with title apptitle
	if not (gave up of dialogResult) then
		if button returned of dialogResult is "Update" then
			set fReplace to false
		end if
	end if
	my trace(apptitle, "Replace albums: " & fReplace as string, false)
	
	# destination folder
	
	set theDestinationRootFolder to "Volumes:photo"
	
	# set theDestinationRootFolder to (choose folder default location ((path to downloads folder as text) & "photo" as alias))
	
	# testing
	
	set theChoices to {"Yes", "No"}
	set theAction to choose from list theChoices with prompt "Execute?" default items {"No"}
	
	# set the scene
	
	if fReplace then
		set notif to "Replace "
	else
		set notif to "Update "
	end if
	
	if fAll then
		set notif to notif & "all albums in "
	else
		set notif to notif & theAlbum & " album in "
	end if
	
	my trace(apptitle, notif & theDestinationRootFolder, true)
	
	tell application "Photos"
		activate
		delay 10
		
		set cnt to 0
		set nb_photos to 0
		set nb_files to 0
		set nb_albums to (count of albums)
		
		set progress total steps to nb_albums
		set progress completed steps to 0
		set progress description to "Processing Images..."
		set progress additional description to "Preparing to process."
		
		repeat with eachAlbum in albums
			set nAlbum to get name of eachAlbum
			set pAlbum to theDestinationRootFolder & my MyPathToAlbumOrFolder(eachAlbum, false, sep) as text
			set cnt to cnt + 1
			
			my trace(apptitle, "Processing album " & nAlbum & " in folder " & pAlbum & " (" & cnt & "/" & nb_albums & ")", false)
			set progress additional description to "Processing " + (count of media items of eachAlbum) + " images ..."
			
			if (fAll is false and (":" & theAlbum & ":") is in (pAlbum & ":")) or (fAll is true) then
				
				if not ("Photos in" is in nAlbum) then
					
					set aAlbum to (count of media items of eachAlbum)
					
					if (theAction is "Yes") then
						if (exists pAlbum) and (fReplace is true) then
							do shell script "rm -fr " & quoted form of (POSIX path of pAlbum)
							delay 1
						end if
						do shell script "mkdir -p " & quoted form of (POSIX path of pAlbum)
						delay 1
						
						
						if exists pAlbum then
							set nb_files to (do shell script "find " & quoted form of POSIX path of pAlbum & " \\! -name '.*'  \\! -type d | wc -l") as integer
							my trace(apptitle, "Prepared folder " & pAlbum & " (" & (nb_files as string) & " files)", false)
							
							my trace(nAlbum, "(" & cnt & "/" & (count of albums) & ") Exporting " & (aAlbum as string) & " photos", true)
							
							set nb_photos to nb_photos + aAlbum
							
							set t_in to (time of (current date))
							
							try
								with timeout of 14400 seconds # 4 hours
									export (get media items of eachAlbum) to (pAlbum as alias) with using originals
								end timeout
							on error errStr number errorNumber
								my trace(nAlbum, "ERROR!!!! " & errStr & " [" & errorNumber & "] with the export command", true)
								display alert "Error " & errStr & " [" & errorNumber & "]" as critical buttons {"Continue"}
							end try
							
							set t_out to (time of (current date))
							
							set nb_files to (do shell script "find " & quoted form of POSIX path of pAlbum & " \\! -name '.*'  \\! -type d | wc -l") as integer
							if (nb_files < aAlbum) then
								my trace(nAlbum, "Missing files !!! " & nb_files & " in folder vs " & aAlbum & " in album" & nAlbum, true)
							end if
							
							my trace(nAlbum, "Exported " & aAlbum & " photos / " & nb_files & " files in " & pAlbum & " folder in " & (t_out - t_in) & " seconds", false)
						else
							my trace(nAlbum, "Cannot find " & pAlbum & " folder !!!", false)
						end if
					end if
				end if
			else
				my trace(apptitle, "Skipping (" & cnt & "/" & (count of albums) & "): " & nAlbum & " - " & pAlbum, false)
				
			end if
			set progress completed steps to cnt
		end repeat
		
		set nb_files to (do shell script "find " & quoted form of POSIX path of theDestinationRootFolder & " \\! -name '.*'  \\! -type d | wc -l") as integer
		my trace(apptitle, "Folders: " & cnt & ", Medias: " & nb_photos & ", Files: " & nb_files, true)
		delay 5
		
	end tell
end run

on trace(sTitle, sMessage, fNotification)
	set theFile to (path to downloads folder as text) & "exportalbumstofolders.txt"
	try
		set fp to open for access file theFile with write permission
	on error
		close access the file theFile
		set fp to open for access file theFile with write permission
	end try
	
	log sMessage
	write sMessage & return to fp as string starting at (get eof of fp) + 1
	if fNotification is true then
		display notification sMessage with title sTitle
	end if
	
	close access fp
end trace

on MyPathToAlbumOrFolder(targetObject, appendItemID, pathItemDelimiter)
	tell application "Photos"
		if not (exists targetObject) then
			error "The indicated item does not exist."
		end if
		if class of targetObject is album then
			set targetObjectName to the name of targetObject
		else if class of targetObject is folder then
			set targetObjectName to the name of targetObject
		else
			error "The indicated item must be a folder or album."
		end if
		if appendItemID is true then
			set targetObjectID to the id of targetObject
			set pathToObject to targetObjectName & space & "(" & targetObjectID & ")"
		else
			set pathToObject to targetObjectName
		end if
		repeat
			try
				if class of parent of targetObject is folder then
					set folderName to the name of parent of targetObject
					set pathToObject to folderName & pathItemDelimiter & pathToObject
					set thisID to id of parent of targetObject
					set targetObject to folder id thisID
				else if class of parent of targetObject is album then
					set albumName to the name of parent of targetObject
					set pathToObject to albumName & pathItemDelimiter & pathToObject
					set thisID to id of parent of targetObject
					set targetObject to album id thisID
				end if
			on error
				return pathToObject
			end try
		end repeat
	end tell
end MyPathToAlbumOrFolder

