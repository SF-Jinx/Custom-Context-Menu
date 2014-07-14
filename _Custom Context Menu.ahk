#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;;
;;INSTRUCTIONS:
;;
;;	The only necessary changes will be your "close" functions and the crawl directory.
;;	Rather than just have you dig for it, you can search for the directory below and 
;;	replace it with your own. It's only used twice.
;;
;;	C:\Users\jmancine\Desktop\Scripts
;;
;;	To close stuff, all you need is the script name, no directory or extension or anything
;;	


#SingleInstance force

;; Create an "Update" function for the General Menu
Menu, General Menu, Add, Update, 	MenuHandler

;; Create the "close script" submenu manually
Menu, Close, Add, Flash,		MenuHandler

;; Add a separator line to offset the sub-menu
Menu, General Menu, Add

;; Build menus based on folder names
CreateMenuFromAllFolders()

;; Create the close menu, since this is being handled manually for now
Menu, General Menu, Add, Close, :Close

return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MenuHandler:

; Create if-statements to react appropriately to
; menu selections

if (A_ThisMenuItem = "Update")
{
	;; Clear the menu
	Menu, Music, 		DeleteAll
	Menu, Ideas,		DeleteAll
	Menu, Close,		DeleteAll

	;; Build them again
	CreateMenuFromAllFolders()
}

else if (A_ThisMenu = "Close")
{
	;; Handling these manually for now
	;; It's possible to create a separate "close"
	;; folder and copy scripts into both, but
	;; that's a poop way to handle it.
	;; Can do better, just haven't yet.

	if (A_ThisMenuItem = "Flash")
	{
		DetectHiddenWindows, On
		Process, Close, FlashPlayerPlugin_11_9_900_117.exe
	}

	else
	{
		CloseScript(A_ThisMenuItem)
	}
}

else
{
	;; Use success check in case we want to monitor
	;; error levels later
	Success:=OpenScript(A_ThisMenuItem, A_ThisMenu)
}

return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Hold win & right-click to "Show" the menu
#RButton::Menu, General Menu, Show

#Esc::ExitApp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OpenScript(Name, FolderName)
{
	StringRight, Extension, Name, 4
	StringLeft, dot, Extension, 1
	if (dot != ".")
	{
		Extension = .ahk
	}

	else
	{
		Extension = ;
	}

	;; Pick directory to scan through
	Run "C:\Users\Jinx\HomeServer\Scripts\AHK\%FolderName%\%Name%%Extension%"
}



CloseScript(Name)
{
	;; AHK won't find scripts because they are "hidden" by default
	DetectHiddenWindows On

	;; Set win commands to regular expressions so they play nice w/ windows processes
	SetTitleMatchMode RegEx

	;; Check if it is currently open
	IfWinExist, i)%Name%.* ahk_class AutoHotkey
	{
		WinClose

		;; Check to see if there are errors while closing
		WinWaitClose, i)%Name%.* ahk_class AutoHotkey, , 2
		If ErrorLevel
		{
			MsgBox Unable to close "%Name%.ahk"
			return
		}
		else
		{
			return
		}
	}
	else
	{
		MsgBox "%Name%" not found
		return
	}
}

CreateMenuFromAllFolders()
{
	;; This function just exists as a single location to
	;; add a new crawl folder to
	;; Will become useful as there are more and more folders

	CreateMenuFromFolder("Music")
	CreateMenuFromFolder("Ideas")
}


CreateMenuFromFolder(FolderName)
{
	;; Initialize file list to be blank
	FileList =  ;
	
	;; Loop through given folder name to find scripts
	Loop C:\Users\Jinx\HomeServer\Scripts\AHK\%FolderName%\*.*
	{
   		FileList = %FileList%%A_LoopFileName%`n
	}
	
	;; Sort everything alphabetically because slight OCD
	Sort, FileList
	
	Loop, parse, FileList, `n
	{
  		if A_LoopField =  ; Ignore the blank item at the end of the list.
  			continue

		;; Add everything to a menu
		;; But trim it all first so it doesn't look messy :)

		;; Check to see if extension is Auto hotkey or not
		StringRight, Extension, A_LoopField, 4
		if (Extension = ".ahk")
		{
			;; Cut it off if it is
			StringTrimRight, LoopFieldTrimmed, A_LoopField, 4
			Menu, %FolderName%, Add, %LoopFieldTrimmed%, MenuHandler
		}
		
		;; If not, leave it
		else 
		{ 
			Menu, %FolderName%, Add, %A_LoopField%, MenuHandler 
		}
	
		Menu, Close, Add, %A_LoopField%, 	MenuHandler

			;;This is a good idea below but for later
			;;%FolderName% - %A_LoopField%, MenuHandler
	}

	;; Lastly, add the menu to the General Menu
	Menu, General Menu, Add, %FolderName%, 	:%FolderName%
	Menu, Close, Add ;
}
