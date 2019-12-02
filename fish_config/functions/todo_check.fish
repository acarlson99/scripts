function	todo_check
	if [ (count $argv) -eq 0 ]
		egrep -R "TODO|FIXME" ./
	else if [ $argv[1] = '-h' ]
		echo 'usage: todo_check [files]'
		echo '	uses grep to check for TODO or FIXME messages'
		echo '	greps recursively if no arguments are given.  Otherwise only checks only files/dirs supplied as argument'
	else
		egrep -R "TODO|FIXME" $argv
	end
end
