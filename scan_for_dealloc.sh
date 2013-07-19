#!/bin/bash

find_files(){
	for file in "$1"/*
	do
		if [ -d "$file" ]; then
			# echo "dir: $file" 
			find_files "$file"
		elif [ -f "$file" ] && [[ "$file" == *.h ]]; then
			# echo "file: $file"
			check_dealloc "$file"
		fi
	done
}

check_dealloc(){
	cat $1 | while read line
	do
		if [[ "$line" == *@property*copy* ]] || [[ "$line" == *@property*retain* ]]; then
			raw_need_dealloc_field=`echo $line | sed -E 's/(.*);.*/\1/' | awk -F" " '{print $NF}'` 
			need_dealloc_field=`echo $raw_need_dealloc_field | sed -e 's/*//'`
			# echo $need_dealloc_field
			m_file=`echo $1 | sed 's/.h/.m/'`
			dealloc_lines=`cat $m_file | sed -n 'N; /dealloc\n*{/,/}/ { //d; p;}'`
			# echo $dealloc_lines
			if [[ $dealloc_lines == *$need_dealloc_field* ]]; then
				echo "dealloced: "$need_dealloc_field
			else
				echo "undealloced: "$need_dealloc_field
			fi
		fi
	done
}

find_files "your dir"
