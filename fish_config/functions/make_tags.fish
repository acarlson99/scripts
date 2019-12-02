function make_tags --description 'Generate TAGS file using etags'
	if [ (count $argv) -ne 1 ]
		echo "usage: make_tags language"
		echo "currently supported: c cpp go el(isp) py(thon)"
		return 1
	end
	switch $argv[1]
		case c
			find . -type f -iname "*.[ch]" | etags -
		case cpp
			find . -type f -iname "*.[cht]pp" | etags -
		case go
			find . -type f -iname "*.go" | etags -
		case py python
			find . -type f -iname "*.py" | etags -
		case el elisp
			find . -type f -iname "*.el" | etags -
		case '*'
			echo "usage: make_tags language"
			echo "currently supported: c cpp go el(isp) py(thon)"
			return 1
	end
end
