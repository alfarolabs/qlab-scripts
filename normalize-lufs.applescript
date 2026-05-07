-- QLab 5 — Normalize the main fader of selected Audio cues to a target LUFS.
--
-- For each selected Audio cue, this script:
--   1. Measures the file's integrated loudness using r128x-cli.
--   2. Computes the dB adjustment needed to hit your reference LUFS.
--   3. Sets the cue's main fader (row 0, column 0) to that adjustment,
--      offset by your preferred fader level.
--   4. Stores the measured LUFS and applied adjustment in the cue's notes.
--
-- Requirements:
--   - r128x-cli installed at /usr/local/bin/r128x-cli
--     (https://github.com/manuelnaudin/r128x — `brew install r128x` or build from source)
--   - QLab 5
--
-- Configure the two values below to taste:

set theReferenceLevel to -14 -- target integrated LUFS
set thefaderLevel to 0 -- fader level (dB) for cues already AT the reference LUFS

-- 2024 version: works in regions regardless of the decimal separator in use.

set currentTIDs to AppleScript's text item delimiters

tell application id "com.figure53.QLab.5" to tell front workspace
	display dialog "WARNING: This will change the main levels of all selected cues" & return & return & "A dialog will signal when the level setting is complete." & return & return & "PROCEED?"
	try
		set theselected to the selected as list
		if (count of items of theselected) > 0 then
			repeat with eachcue in theselected
				if q type of eachcue is "audio" then
					set currentFileTarget to quoted form of POSIX path of (file target of eachcue as alias)
					set theLUFS to (do shell script "/usr/local/bin/r128x-cli" & " " & currentFileTarget as string)
					--parse theLUFS to extract the actual LUFS from a very long string
					--replace every occurrence of "+" with "plus"
					set AppleScript's text item delimiters to "+"
					set the item_list to every text item of theLUFS
					set AppleScript's text item delimiters to "plus"
					set theLUFS to the item_list as string
					--replace every occurrence of "-" with "minus"
					set AppleScript's text item delimiters to "-"
					set the item_list to every text item of theLUFS
					set AppleScript's text item delimiters to "minus"
					set theLUFS to the item_list as string
					set AppleScript's text item delimiters to currentTIDs
					--get the third word from the end
					set the theLUFS to word -3 of theLUFS
					--replace the string "minus" in theLUFS with "-"
					if character 1 of theLUFS = "m" then
						set theLUFS to "-" & characters 6 thru -1 of theLUFS
					else
						--replace the string "plus" in theLUFS with "+"
						set theLUFS to "+" & characters 5 thru -1 of theLUFS
					end if
					-- check for decimal localisation and convert to comma separator if neccesary
					set o to (offset of "." in theLUFS)
					if ((o > 0) and (0.0 as text is "0,0")) then set theLUFS to (text 1 thru (o - 1) of theLUFS & "," & text (o + 1) thru -1 of theLUFS)
					set theadjustment to (theReferenceLevel - theLUFS) + thefaderLevel
					set the notes of eachcue to theLUFS & " " & theadjustment
					eachcue setLevel row 0 column 0 db theadjustment
				end if
			end repeat
			display dialog "Level Setting Complete" buttons "OK" default button "OK"
		end if
	end try
end tell
