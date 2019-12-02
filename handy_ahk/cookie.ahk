g_loop = 0

s::
if g_loop
{
	MsgBox, Done
	g_loop = 0
}
else
{
	MsgBox, Terminating
	ExitApp
}
return

a::
g_loop = 1
while g_loop
{
	MouseClick
	sleep, 0
}
return
