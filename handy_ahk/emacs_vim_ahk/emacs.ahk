#UseHook, On

^b::
send {left}
return

^n::
send {down}
return

^p::
send {up}
return

^f::
send {right}
return

^a::
send {home}
return

^e::
send {end}
return

^v::
send {pgdn}
return

!v::
send {pgup}
return

^m::
send {return}
return

^o::
send {return}
send {left}
return

^d::
send {del}
return

^y::
send ^v
return

^k::
send +{end}
send ^x
return

^/::
send ^z
return
