#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; !^r::
; msgbox Reloading
; reload
; return

global switch
switch = 1

$Numpad0::
if switch = 0
{
	Send {Numpad0}
}
else
{
	Send {Escape}
}
return

$Numpad1::
if switch = 0
{
	Send {Numpad1}
}
else
{
	Send {Volume_Down}
}
return

$Numpad2::
if switch = 0
{
	Send {Numpad2}
}
else
{
	Send {Volume_Mute}
}
return

$Numpad3::
if switch = 0
{
	Send {Numpad3}
}
else
{
	Send {Volume_Up}
}
return

NumpadIns::
if switch = 0
{
	switch = 1
}
else
{
	switch = 0
}
return

$Numpad4::
if switch = 0
{
	Send {Numpad4}
}
else
{
	Send {Media_Prev}
}
return

$Numpad5::
if switch = 0
{
	Send {Numpad5}
}
else
{
	Send {Media_Play_Pause}
}
return

$Numpad6::
if switch = 0
{
	Send {Numpad6}
}
else
{
	Send {Media_Next}
}
return
