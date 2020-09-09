#!/usr/bin/env zsh -f
# Purpose: Show Mounted Drives, if any, and offer to reveal them in Finder or eject them
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2020-09-09

NAME="$0:t:r"

if [[ -e "$HOME/.path" ]]
then
	source "$HOME/.path"
else
	PATH='/usr/local/scripts:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin'
fi

cd /Volumes/

COUNT=$(find * -type d -maxdepth 0 -print | egrep -vi '^Update$' | wc -l | tr -dc '[0-9]')

	# if nothing is mounted, quit
[[ "$COUNT" == "0" ]] && exit 0

echo "[ $COUNT ]
---"

find * -type d -maxdepth 0 -print \
| egrep -vi '^Update$' \
| while read line
do
		# it may be necessary to encode more than just spaces
	HREF_LINE=$(echo "$line" | sed 's# #%20#g')

	echo "$line [show]  | color=blackt href=file:///Volumes/${HREF_LINE}"
	echo "$line [eject] | color=red bash=/usr/sbin/diskutil param1=eject param2=\"/Volumes/${line}\" terminal=false"
	echo '~ ~ ~ ~ ~ '
done

## @TODO - ideally there would be a way to eject all at once.
## In practice I actually use 'Semulov' for this. Freely available at https://kainjow.com


exit 0
#EOF
