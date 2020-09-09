#!/usr/bin/env zsh -f
# Purpose: Time Machine current status when active
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2020-09-08


NAME="$0:t:r"


if [ -e "$HOME/.path" ]
then
	source "$HOME/.path"
else
	PATH="/usr/local/scripts:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin"
fi

if ((! $+commands[bytes2readable.sh] ))
then
		# note: if bytes2readable.sh is a function or alias, it will come back not found
	echo "$NAME: 'bytes2readable.sh' is required but not found in $PATH" >>/dev/stderr
	exit 1
fi

if ((! $+commands[commaformat.sh] ))
then

	# note: if commaformat.sh is a function or alias, it will come back not found

	echo "$NAME: 'commaformat.sh' is required but not found in $PATH" >>/dev/stderr
	exit 1

fi


PHASE=$(tmutil currentphase)

	# if Time Machine is not running, just quit
[[ "$PHASE" == "BackupNotRunning" ]] && exit 0



	# file where we store the entire output of the 'tmutil status' information
CURRENT_STATUS="$HOME/.$NAME.status.txt"

( tmutil status 2>&1 ) >| "$CURRENT_STATUS"

JUST_FILES=$(sed 's#^ *##g ; s#\;##g; s#"##g' "$CURRENT_STATUS" | awk -F' ' '/^files/{print $NF}')

	# Now we parse the local file for the info we want.
BYTES=$(sed 's#^ *##g ; s#\;##g; s#"##g' "$CURRENT_STATUS" | awk -F' ' '/^bytes/{print $NF}' || echo 0)
	SIZE_COPIED=$(bytes2readable.sh "$BYTES" | sed 's#\.[0-9][0-9] MB# MB#g')

TOTAL_BYTES=$(sed 's#^ *##g ; s#\;##g; s#"##g' "$CURRENT_STATUS" | awk -F' ' '/^totalBytes/{print $NF}' || echo 0)
	TOTAL_TO_COPY=$(bytes2readable.sh "$TOTAL_BYTES" | sed 's#\.[0-9][0-9] MB# MB#g')

	# now we calculate the byte info
if [ "$TOTAL_BYTES" != "" -a "$BYTES" != "" ]
then

	PERCENT_OF_BYTES=$(echo "scale=2 ; ($BYTES / $TOTAL_BYTES)" | bc | sed 's#\.##g ; s#$#%#g' || echo 0)

	BYTES_REMAINING=$(($TOTAL_BYTES - $BYTES))

		BYTES_REMAINING_READABLE=$(bytes2readable.sh "$BYTES_REMAINING" | sed 's#\.[0-9][0-9] MB# MB#g')

else

	PERCENT_OF_BYTES=""
	BYTES_REMAINING=""
	BYTES_REMAINING_READABLE=""

fi

	# get the current files count
CURRENT_FILES=$(sed 's#^ *##g ; s#\;##g; s#"##g' "$CURRENT_STATUS" | awk -F' ' '/^files/{print $NF}')

	# get the total files count
TOTAL_FILES=$(sed 's#^ *##g ; s#\;##g; s#"##g' "$CURRENT_STATUS" | awk -F' ' '/^totalFiles/{print $NF}')

TOTAL_FILES_READABLE=$(commaformat.sh "$TOTAL_FILES")

	# change the number to have commas in the right places
if [[ "$JUST_FILES" == "$TOTAL_FILES" ]]
then
	FILES_SO_FAR_READABLE=$(commaformat.sh "$JUST_FILES")
else

	JUST_FILES_READABLE=$(commaformat.sh "$JUST_FILES")


	FILES_SO_FAR_READABLE="$JUST_FILES_READABLE / $TOTAL_FILES_READABLE"
fi



echo "TM $PHASE
---
Current Files: $CURRENT_FILES 						| color=black
Files So Far: $FILES_SO_FAR_READABLE  				| color=black
Total Files Readable: $TOTAL_FILES_READABLE 		| color=black
~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 					| color=black
% of Bytes: ${PERCENT_OF_BYTES} 					| color=black
Bytes Remaining: $BYTES_REMAINING / ${BYTES_REMAINING_READABLE} | color=black
Bytes Done: $BYTES / $SIZE_COPIED 					| color=black
Total Bytes; $TOTAL_BYTES 							| color=black
Total to Copy: $TOTAL_TO_COPY 						| color=black
~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 					| color=black
~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 					| color=black

"


## if you want to see the raw output from `tmutil`, uncomment the next line
# cat "$CURRENT_STATUS"

exit 0


