#!/bin/bash

#echo "usage: program *.bedunion"
#echo "converts coverage values in file represented in a form with exp to decimal form"

if [ "$#" -ne 1 ]; then
echo "Wrong number of arguments"
  exit 1
fi

if [ ! -f "$1" ]; then
	echo "file $1 not found."
	exit;
fi

header_line=1
while read var1 var2 var3 var4 var5
do

	if [[ "$header_line" = 1 ]]; then
		printf "$var1	$var2	$var3	$var4	$var5\n"
		header_line=0;
	else
		printf "%s\t%d\t%d\t%.0f\t%.0f\n" $var1 $var2 $var3 $var4 $var5
	fi

done < $1
