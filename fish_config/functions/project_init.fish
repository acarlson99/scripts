function	init_dir
	if [ (count $argv) -eq 0 ]
		echo 'usage: init_dir repo_link'
		echo 'calls git init and pushes everything to supplied repo'
		return 1
	else if [ -d .git ]
		echo ".git folder already exists"
	else if [ (count $argv) -eq 0 ]
		echo "No argument provided"
	else
		git init
		echo "git init"
		git add .
		echo "git add ."
		git commit -m "First commit"
		echo 'git commit -m "First commit"'
		git remote add origin $argv[1]
		echo "git remote add origin $argv[1]"
		git push -u origin master
		echo "git push -u origin master"		
	end
end

function	start_project
	if [ (count $argv) -gt 0 ]
		if [ $argv[1] = '-h' ]
			echo 'usage: start_project [git_repo_link]'
			echo '	clones libft and gitignore template and makes author file'
			echo '	calls init_dir if git link is supplied'
			return 0
		else
			echo "calling git init on $argv[1]"
			init_dir $argv[1]
		end
	end
	if [ -d libft/ ]
		echo "libft/ is already a directory"
	else
		clone_libft
	end
	if [ -f .gitignore ] 
		echo ".gitignore is already a file"
	else
		clone_gitignore
	end
	if [ -f author ]
		echo "author is already a file"
	else
		echo "making author file"
	end
	make_author
end
