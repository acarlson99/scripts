g_loop = 0

s::
if g_loop
{
	MsgBox, Stopping
	g_loop = 0
}
else
{
	MsgBox, Terminating script
	ExitApp
}
return

#IfWinActive Hearthstone
a::
g_loop = 1
while g_loop
{
	Send, {Space}
	sleep, 0
}
return
