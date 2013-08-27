/*:VRX         Main
*/
/* 
  INI Assistent: Save INI entries to REXX-.CMD files
  Copyright (C) 1999 - 2000 Herwig Bauernfeind
  
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/
/*  Main
*/
Main:
/*  Process the arguments.
    Get the parent window.
*/
    parse source . calledAs .
    parent = ""
    argCount = arg()
    argOff = 0
    if( calledAs \= "COMMAND" )then do
        if argCount >= 1 then do
            parent = arg(1)
            argCount = argCount - 1
            argOff = 1
        end
    end; else do
        call VROptions 'ImplicitNames'
        call VROptions 'NoEchoQuit'
    end
    InitArgs.0 = argCount
    if( argCount > 0 )then do i = 1 to argCount
        InitArgs.i = arg( i + argOff )
    end
    drop calledAs argCount argOff

/*  Load the windows
*/
    call VRInit
    parse source . . spec
    _VREPrimaryWindowPath = ,
        VRParseFileName( spec, "dpn" ) || ".VRW"
    _VREPrimaryWindow = ,
        VRLoad( parent, _VREPrimaryWindowPath )
    drop parent spec
    if( _VREPrimaryWindow == "" )then do
        call VRMessage "", "Cannot load window:" VRError(), ,
            "Error!"
        _VREReturnValue = 32000
        signal _VRELeaveMain
    end

/*  Process events
*/
    call Init
    signal on halt
    do while( \ VRGet( _VREPrimaryWindow, "Shutdown" ) )
        _VREEvent = VREvent()
        interpret _VREEvent
    end
_VREHalt:
    _VREReturnValue = Fini()
    call VRDestroy _VREPrimaryWindow
_VRELeaveMain:
    call VRFini
exit _VREReturnValue

VRLoadSecondary:
    __vrlsWait = abbrev( 'WAIT', translate(arg(2)), 1 )
    if __vrlsWait then do
        call VRFlush
    end
    __vrlsHWnd = VRLoad( VRWindow(), VRWindowPath(), arg(1) )
    if __vrlsHWnd = '' then signal __vrlsDone
    if __vrlsWait \= 1 then signal __vrlsDone
    call VRSet __vrlsHWnd, 'WindowMode', 'Modal' 
    __vrlsTmp = __vrlsWindows.0
    if( DataType(__vrlsTmp) \= 'NUM' ) then do
        __vrlsTmp = 1
    end
    else do
        __vrlsTmp = __vrlsTmp + 1
    end
    __vrlsWindows.__vrlsTmp = VRWindow( __vrlsHWnd )
    __vrlsWindows.0 = __vrlsTmp
    do while( VRIsValidObject( VRWindow() ) = 1 )
        __vrlsEvent = VREvent()
        interpret __vrlsEvent
    end
    __vrlsTmp = __vrlsWindows.0
    __vrlsWindows.0 = __vrlsTmp - 1
    call VRWindow __vrlsWindows.__vrlsTmp 
    __vrlsHWnd = ''
__vrlsDone:
return __vrlsHWnd

/*:VRX         _ReadINI
*/
_ReadINI: 
    call SysIni INIFile, 'All:', 'Anwd'
    ok = VRSet("EF_TargetINIFile","Value",INIFile)
    ok = VRSet("Apps","Hinttext",INIFile" | Application entries. Click right mouse button for context menu.")
    ok = VRSet("Keys","Hinttext",INIFile" | Key entries")
    ok = VRMethod( "Apps", "Reset")
    ok = VRMethod( "Apps", "AddStringList", "Anwd.",  )
    ok = VRSet( "Apps", "Selected", 1)
    CurrentApp = Anwd.1
    call Apps_Click CurrentApp 
return

/*:VRX         Apps_Click
*/
Apps_Click: 
    parse arg OurApp
    if OurApp = '' then Anwend = VRGet( "Apps", "SelectedString" )
                   else Anwend = OurApp
    ok = SysIni( INIFIle, Anwend, 'All:', 'Schl')
    CurrentKey = Schl.1
    ok = VRMethod( "Keys", "Clear" )
    ok = VRMethod( "Keys", "AddStringList", "Schl." )
    call Keys_Click CurrentKey
return

/*:VRX         Apps_ContextMenu
*/
Apps_ContextMenu: 
    call Apps_Click
    ok = VRMethod( "Menu_PopUpApp", "Popup", , , "", "" )
return

/*:VRX         Fini
*/
Fini:
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
return 0

/*:VRX         Halt
*/
Halt:
    signal _VREHalt
return

/*:VRX         INIGetMain_Close
*/
INIGetMain_Close:
    call Quit
return

/*:VRX         INIGetMain_Create
*/
INIGetMain_Create: 
    INIFile = 'USER'
    call _ReadINI
return

/*:VRX         Init
*/
Init:
    window = VRWindow()
    call VRMethod window, "CenterWindow"
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
    drop window
return

/*:VRX         Keys_Click
*/
Keys_Click: 
    parse arg OurKey
    if OurApp = '' then Anwend = VRGet( "Apps", "SelectedString" )
                   else Anwend = OurApp
    if OurKey = '' then Schlussel = VRGet( "Keys", "SelectedString" )
                   else Schlussel = OurKey
    KeyValue = SysIni( INIFile,Anwend , Schlussel)
    ok = VRSet("EF_Value",    "Value", translate(KeyValue,' ',x2c('00')))
    ok = VRSet("EF_ValueHex", "Value", c2x(KeyValue))
return
/*:VRX         Menu_File_Choose_Click
*/
Menu_File_Choose_Click: 
    INIFile = VRFileDialog( VRWindow(), "Choose INI File", "Open", "*.INI", , ,  )
    call _ReadINI
return

/*:VRX         Menu_File_exit_Click
*/
Menu_File_exit_Click: 
    call Quit
return

/*:VRX         Menu_File_LSSHAREINI_Click
*/
Menu_File_LSSHAREINI_Click: 
    INIFIle = SysBootDrive()'\IBMLAN\LSSHARE.INI'
    call _ReadINI
return

/*:VRX         Menu_File_LSUSEINI_Click
*/
Menu_File_LSUSEINI_Click: 
    INIFIle = SysBootDrive()'\IBMLAN\LSUSE.INI'
    call _ReadINI
return

/*:VRX         Menu_File_NETGUIINI_Click
*/
Menu_File_NETGUIINI_Click: 
    INIFIle = SysBootDrive()'\IBMLAN\NETPROG\NETGUI.INI'
    call _ReadINI
return

/*:VRX         Menu_File_NSCPINI_Click
*/
Menu_File_NSCPINI_Click: 
    INIFIle = SysBootDrive()'\OS2\NSCP.INI'
    call _ReadINI
return

/*:VRX         Menu_File_SYSTEMINI_Click
*/
Menu_File_SYSTEMINI_Click: 
    INIFIle = 'SYSTEM'
    call _ReadINI
return

/*:VRX         Menu_File_TCPOS2INI_Click
*/
Menu_File_TCPOS2INI_Click: 
    INIFIle = value('ETC',,'OS2ENVIRONMENT')'\TCPOS2.INI'
    call _ReadINI
return

/*:VRX         Menu_File_USERINI_Click
*/
Menu_File_USERINI_Click: 
    INIFIle = 'USER'
    call _ReadINI
return

/*:VRX         Menu_Help_About_Click
*/
Menu_Help_About_Click: 
    Lines.1 = "INI Assistant Version 0.0.7"
    Lines.2 = "(c) 1999 - 2000 Herwig Bauernfeind"
    Lines.3 = ""
    Lines.4 = "Freeware under GNU Public License"
    Lines.0 = 4
    Buttons.1 = "OK"
    Buttons.0 = 1
    id = VRMessageStem( VRWindow(), "Lines.", "About this program", "None", "Buttons.", OK, OK )
return

/*:VRX         Menu_Help_General_Click
*/
Menu_Help_General_Click: 
    Lines.1 = "INI Assistant is a little tool for exactly one job: It creates a REXX script from an application's INI entry in an OS/2 INI file, in order to reproduce"
    Lines.2 = "the same INI file entry on a different machine, a different file or as a backup."
    Lines.0 = 2
    Buttons.1 = "OK"
    Buttons.0 = 1
    id = VRMessageStem( VRWindow(), "Lines.", "General help", "Information", "Buttons.", Buttons.1, Buttons.1 )

return

/*:VRX         Menu_Mode_ASCII_Click
*/
Menu_Mode_ASCII_Click: 
    ok = VRSet("Menu_Mode_Hex","Checked",\VRGet("Menu_Mode_Hex","Checked"))
    ok = VRSet("Menu_Mode_ASCII","Checked",\VRGet("Menu_Mode_ASCII","Checked"))
return

/*:VRX         Menu_Mode_Hex_Click
*/
Menu_Mode_Hex_Click: 
    ok = VRGet("Menu_Mode_Hex","Checked",\VRGet("Menu_Mode_Hex","Checked"))
    ok = VRGet("Menu_Mode_ASCII","Checked",\VRGet("Menu_Mode_ASCII","Checked"))
return

/*:VRX         Menu_PopUpApp_create_Click
*/
Menu_PopUpApp_create_Click: 
    call PB_REXXit_Click
return

/*:VRX         Menu_PopUpApp_delete_Click
*/
Menu_PopUpApp_delete_Click: 
    Buttons.1 = "OK"
    Buttons.2 = "Cancel"
    Buttons.0 = 2
    id = VRMessage( VRWindow(), "Really delete application """Anwend""" from """INIFile""" ?", "INI Assistant", "Q", "Buttons.", 2 , 2 )
    if id = 1 then do
        ok = SysIni(inifile, anwend, 'DELETE:')
        call _ReadINI
    end
return

/*:VRX         PB_RexxIt_Click
*/
PB_RexxIt_Click: 
    ok = VRSEt("PB_RexxIt","Enabled", 0)
    FileName = VRFileDialog( VRWindow(), "Specify a filename", "Save", strip(left(Anwend,8))'.CMD', , ,  )
    if FileName = '' then return
    HexMode = VRGet("Menu_Mode_Hex","Checked")
    call SysFileDelete(Filename)
    call lineout Filename, '/* Recreate INI entries of "'Anwend'". Built on 'date('E')' at 'time()'.'
    call lineout Filename, ' *'
    call lineout Filename, ' * Generated by INI Assistant 'VRGet( "INIGetMain", "HintText" )'.'
    call lineout Filename, ' */'
    call lineout Filename, ' '
    call lineout Filename, 'call RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"'
    call lineout Filename, 'call SysLoadFuncs'
    call lineout Filename, ' '
    call lineout Filename, 'INIFile = "'VRGet("EF_TargetINIFile","Value")'" /* Modify if other target desired */'
    call lineout Filename, 'App     = "'Anwend'" /* Modify if other application name is desired */'
    call lineout Filename, ' '
    call lineout Filename, 'say "Recreating application 'Anwend'..."'
    call lineout Filename, ' '
    Indent = copies(' ',10)
    MaxLen = 60
    do i = 1 to schl.0
        KeyValue = SysIni( INIFile ,Anwend , Schl.I)    
        call lineout Filename, 'say "Writing key 'Schl.I'"'
        call lineout Filename, 'call SysINI INIFile, App, "'Schl.I'",,'
        if HexMode then Zeile = 'x2c("'c2x(KeyValue)'")'
                   else Zeile = '"'strip(KeyValue,,x2c("00"))'"x2c("00")'
        if length(Zeile) < MaxLen
        then call lineout Filename, Indent''Zeile
        else do 
            call lineout Filename, Indent''left(Zeile,MaxLen)'" ||,'
            Zeile = strip(substr(Zeile,MaxLen+1,))
            do while length(Zeile) > MaxLen
                call lineout Filename, Indent'"'strip(left(Zeile,MaxLen-1))'" ||,'
                Zeile = strip(substr(Zeile,min(MaxLen,length(Zeile)),))
            end
            call lineout Filename, Indent'"'Zeile
        end
    end
    call lineout Filename, ' '
    call lineout Filename, 'say "Done."'
    call lineout Filename
    Buttons.1 = "OK"
    Buttons.0 = 1
    id = VRMessage( VRWindow(), "Rexx script "Filename" successfully created.", "INI Assistant", "Information", "Buttons.", OK, OK )
    ok = VRSEt("PB_RexxIt","Enabled", 1)
return
/*:VRX         Quit
*/
Quit:
    window = VRWindow()
    call VRSet window, "Shutdown", 1
    drop window
return

