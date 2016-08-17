#!/bin/bash

function p_version {
	echo 'pminify 1.0'
	echo 'This software is based on Andrew Chilton minifier <http://chilts.org/>'
	echo 'Licence GPLv3+: <http://gnu.org/licenses/gpl.html>'

	exit 0
}

function p_help {
	echo "Usage: pminify <option> <archive | directory>"
	echo -e "Minify CSS and JS files\n"
	echo " -c	minify ONE CSS file"
	echo " -j	minify ONE JS file"
	echo " -r	minify many CSS/JS files (it doesn't matter)"
	echo " -v	show information about version and finish"
	echo " -h	show this help and finish"
	echo -e "\nExamples:\n"
	echo " pminify -c file.css"
	echo " pminify -j file.js"
	echo " pminify -r directory/"
	echo " pminify -r . (for many files in current directory)"

	exit 0
}

function unknow {
	printf "\n\n*** %s unknow ***\n\n\n" $1
	return 1
}

function new_name {
	local archive=$1
	local name
	local extension
	local min=".min."

	archive=$(echo $archive | sed "s/^.*\///g")
	
	if [ $? -eq 0 ];then
		name=$(echo $archive | cut -d "." -f 1)
		extension=$(echo $archive | cut -d "." -f 2)
		mv minifying $name$min$extension
	fi
	
	if [ $? -eq 0 ];then
		return 0
	else
		printf "\narchive '%s' minified but its not named (verify archive 'minifying')" $archive
		return 1
	fi
}

function css {
	local archive=$1

	file $archive | grep -w css: &> /dev/null

	if [ $? -eq 0 ];then
		curl -X POST --data-urlencode 'input@'$archive https://cssminifier.com/raw > minifying
		
		if [ $? -eq 0 ];then
			new_name $archive
		else
			printf "\nImpossible to minify the file '%s'\n" $archive
			return 1
		fi
	else
		return 1
	fi
}

function js {
	local archive=$1

	file $archive | grep -w js: &> /dev/null

	if [ $? -eq 0 ];then
		curl -X POST --data-urlencode 'input@'$archive https://javascript-minifier.com/raw > minifying

		if [ $? -eq 0 ];then
			new_name $archive
		else
			printf "\nImpossible to minify the file '%s'\n" $archive
			return 1
		fi
	else
		return 1
	fi
}

function recursive {
	local directory=$1
	local archive

	cd $directory &> /dev/null

	if [ $? -eq 0 ];then
		for arq in $(pwd)/*;do
			archive=$(echo $arq | rev | cut -d / -f 1 | rev)
			css $archive || js $archive || unknow $archive
		done
	else
		printf "'%s' is not a directory\n" $directory
		return 1
	fi
}

while getopts ":c:j:r:vh" arq;do
	case $arq in
		c)
			css $2;;

		j)
			js $2;;

		r)
			recursive $2;;

		h)
			p_help;;

		v)
			p_version;;

		\?)
			echo "invalid option"
			exit 1;;
	esac
done
