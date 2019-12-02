function	fish_prompt --description 'Set fish prompt'
	set s $status
	if [ $s -eq 0 ]
		set_color normal
	else
		set_color red
	end
	printf "%-3d> " $s
	set_color normal
end
