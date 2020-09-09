#!/usr/bin/env zsh -f
# Purpose: Put the battery level of Magic Trackpad and Magic Keyboard in Menu Bar _IFF_ under 20%
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2020-08-29


NAME="$0:t:r"

if [ -e "$HOME/.path" ]
then
	source "$HOME/.path"
else
	PATH=/usr/local/scripts:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin
fi

	# how low (percentage) can your keyboard battery get before you get a warning?
KEYBOARD_WARNING_LEVEL='10'

	# how low (percentage) can your trackpad battery get before you get a warning?
TRACKPAD_WARNING_LEVEL='15'

	# what color do you want the menu bar text to be in?
COLOR='black'

	# how large do you want the font to be?
FONT_SIZE='12'

## NOTE: If this does not work for you, run this command by itself in Terminal.app:
##
##		ioreg -r -k "BatteryPercent" | egrep '"Product"|"BatteryPercent"'
##
## and see if it says anything about battery life. Chances are good that if it
## does NOT work, the reason is that your keyboard may not have the word 'Keyboard'
## in the name, and your Trackpad may not have the word 'Trackpad' in the name.

INFO=$(ioreg -r -k "BatteryPercent" \
		| egrep '"Product"|"BatteryPercent"' \
		| perl -p -e 's#"\n#" #' \
		| sed 	-e 's#^ *"Product" = ##g' \
				-e 's#  "BatteryPercent" = #	#g')

KEYBOARD_BATTERY_PERCENT=$(echo "${INFO}" | awk -F'	' '/Keyboard/{print $NF}')

TRACKPAD_BATTERY_PERCENT=$(echo "${INFO}" | awk -F'	' '/Trackpad/{print $NF}')

	## if both of these are above 20% then don't output anything
if [ "${KEYBOARD_BATTERY_PERCENT}" -gt "${KEYBOARD_WARNING_LEVEL}" \
	-a \
	"${TRACKPAD_BATTERY_PERCENT}" -gt "${TRACKPAD_WARNING_LEVEL}" ]
then
		# both devices are over 20% so neither needs to be shown in menu bar
	exit 0

elif [ "${KEYBOARD_BATTERY_PERCENT}" -le "${KEYBOARD_WARNING_LEVEL}" \
		-a \
		"${TRACKPAD_BATTERY_PERCENT}" -le "${TRACKPAD_WARNING_LEVEL}" ]
then
		## BOTH devices are UNDER 20% so BOTH need to be shown in menu bar
		## I use 'KBD' and 'TrkPad' so they don't take up TOO much space in the menu bar
	echo "KBD: ${KEYBOARD_BATTERY_PERCENT}% TrkPad: ${TRACKPAD_BATTERY_PERCENT}% | color=${COLOR} size=${FONT_SIZE}"

elif  [ "${KEYBOARD_BATTERY_PERCENT}" -le "${KEYBOARD_WARNING_LEVEL}" \
		-a \
		"${TRACKPAD_BATTERY_PERCENT}" -gt "${TRACKPAD_WARNING_LEVEL}" ]
then
		## KBD is low but TrackPad is OK
		## I use 'KBD' and 'TrkPad' so they don't take up TOO much space in the menu bar
	echo "KBD: ${KEYBOARD_BATTERY_PERCENT}% | color=${COLOR} size=${FONT_SIZE}"

elif  [ "${KEYBOARD_BATTERY_PERCENT}" -gt "${KEYBOARD_WARNING_LEVEL}" \
		-a \
		"${TRACKPAD_BATTERY_PERCENT}" -le "${TRACKPAD_WARNING_LEVEL}" ]
then
		## TrackPad is low but Keyboard is OK
		## I use 'KBD' and 'TrkPad' so they don't take up TOO much space in the menu bar
	echo "TrkPad: ${TRACKPAD_BATTERY_PERCENT}% | color=${COLOR} size=${FONT_SIZE}"
fi


exit 0
#
#EOF
