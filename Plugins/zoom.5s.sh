#!/usr/bin/env zsh -f
# Purpose: If Zoom is running, show how much CPU it is using.
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2020-09-06

NAME="$0:t:r"

if [ -e "$HOME/.path" ]
then
	source "$HOME/.path"
else
	PATH=/usr/local/scripts:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin
fi

	## ps auxwww - shows all of the information for all processes
	## first `fgrep` - limits output to zoom.us.app
	## second `fgrep` - makes sure we don't match first `fgrep`
	## awk - just show me the CPU usage

USAGE=$(ps auxwww \
		| fgrep '/Applications/zoom.us.app/Contents/MacOS/zoom.us' \
		| fgrep -v fgrep \
		| awk '{print $3}')

	# if Zoom is not running, no output
[[ "$USAGE" == "" ]] && exit 0

echo "Zoom: ${USAGE}%"

exit 0
#
#EOF
