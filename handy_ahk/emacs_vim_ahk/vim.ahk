#NoEnv
;; #Warn
SendMode Input
SetWorkingDir %A_ScriptDir%
; #UseHook, On

; 0 = Normal mode
; 1 = Insert mode
; 2 = Visual mode
global g_mode := 0
global g_prefix_int := 0
global g_prefix_char := 0

$Escape::
g_mode := 0
return

$i::
if g_mode = 1
{
	Send i
}
else
{
	g_mode = 1
}
return

$h::
if g_mode = 1
{
	Send h
}
else
{
	g_prefix_int := max(g_prefix_int, 1)
	Send {left %g_prefix_int%}
	g_prefix_int := 0
}
return

$j::
if g_mode = 1
{
	Send j
}
else
{
	g_prefix_int := max(g_prefix_int, 1)
	Send {down %g_prefix_int%}
	g_prefix_int := 0
}
return

$k::
if g_mode = 1
{
	Send k
}
else
{
	g_prefix_int := max(g_prefix_int, 1)
	Send {up %g_prefix_int%}
	g_prefix_int := 0
}
return

$l::
if g_mode = 1
{
	Send l
}
else
{
	g_prefix_int := max(g_prefix_int, 1)
	Send {right %g_prefix_int%}
	g_prefix_int := 0
}
return

$a::
if g_mode = 1
{
	Send a
}
else
{
	Send {right}
	g_mode := 1
}
return

shift & a::
if g_mode = 1
{
	Send A
}
else
{
	Send {end}
	g_mode := 1
}
return

$o::
if g_mode = 1
{
	Send o
}
else
{
	Send {end} {Enter}
	g_mode := 1
}
return

shift & o::
if g_mode = 1
{
	Send O
}
else
{
	Send {up} {end} {Enter}
	g_mode := 1
}
return

$x::
if g_mode = 1
{
	Send x
}
else
{
	g_prefix_int := max(g_prefix_int, 1)
	Send {del %g_prefix_int%}
	g_prefix_int := 0
}
return

shift & x::
if g_mode = 1
{
	Send X
}
else
{
	g_prefix_int := max(g_prefix_int, 1)
	Send {backspace %g_prefix_int%}
	g_prefix_int := 0
}
return

$$::
if g_mode = 1
{
	Send $
}
else
{
	Send {end}
	g_prefix_int := 0
}
return

add_to_int_prefix(n)
{
	if g_mode = 1
	{
		Send %n%
	}
	else
	{
	g_prefix_int :=  g_prefix_int * 10 + n
	}
	return
}

$0::
if g_mode = 1
{
	Send 0
}
else if g_prefix_int != 0
{
	add_to_int_prefix(0)
}
else
{
	Send {home}
	g_prefix_int := 0
}
return

$1:: add_to_int_prefix(1)
$2:: add_to_int_prefix(2)
$3:: add_to_int_prefix(3)
$4:: add_to_int_prefix(4)
$5:: add_to_int_prefix(5)
$6:: add_to_int_prefix(6)
$7:: add_to_int_prefix(7)
$8:: add_to_int_prefix(8)
$9:: add_to_int_prefix(9)

g_macro := ""

; #UseHook, Off
$q::
if g_mode = 1
{
	Send q
}
else
{
	g_macro := ""
	ToolTip Recording Macro
	loop
	{
		Input, in, L1, q
		EL=%ErrorLevel%
		if EL = EndKey:q
		{
			if g_mode = 0
			{
				ToolTip Macro Recorded
				break
			}
		}
		Send %in%
		g_macro.=in
	}
}
return

shift & 2::
if g_mode = 1
{
	Send @
}
else
{
	g_prefix_int := max(g_prefix_int, 1)
	Loop
	{
		if g_prefix_int = 0
			break
		Send %g_macro%
		g_prefix_int := g_prefix_int - 1
	}
}
return
