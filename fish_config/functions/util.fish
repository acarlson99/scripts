function	make_author
	echo $USER > author
end

function	clone_libft
	echo "cloning libft"
	git clone $MY_LIBFT libft/ & rm -rf libft/.git libft/.gitignore
end

function	clone_gitignore
	echo "cloning .gitignore template"
	git clone $MY_GITIGNORE gitignore_dir
	cp gitignore_dir/.gitignore ./ & rm -rf gitignore_dir/
end
