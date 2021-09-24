on idle
    set intnt to do shell script "ping -c 1 192.168.40.9; echo -n"
    set paras to number of paragraphs in intnt
    if paras < 5 then
    else
        set serverIP to "smb://192.168.40.9/osiris"
        set UserAccount to "dietpi"
        set ServerPassword to "Fra13941"
        set serverVolume to UserAccount
        tell application "Finder"
            try
                if disk serverVolume exists then
                else
                    mount volume serverIP as user name UserAccount with password ServerPassword
                end if
            end try
        end tell
    end if
    return 5
end idle
