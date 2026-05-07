-- QLab 5 — Sort the cues inside the SELECTED group alphabetically
-- (A–Z first, then digits/symbols).
-- Requires exactly ONE selected cue, and it MUST be a Group.
--
-- Usage:
--   1. In QLab, select a single Group cue.
--   2. Run this script (from a Script cue, Script Editor, or hotkey).
--   3. The group's immediate children are reordered alphabetically by q name.
--      Nested groups are left in place; their internal contents are untouched.

tell application id "com.figure53.QLab.5"
	tell front workspace
		set sel to (selected as list)
		
		if (count of sel) is 0 then
			display dialog "Select a Group cue first." ¬
				buttons {"OK"} default button 1
			return
		end if
		
		if (count of sel) > 1 then
			display dialog "Select only ONE Group cue." ¬
				buttons {"OK"} default button 1
			return
		end if
		
		set targetGroup to item 1 of sel
		if q type of targetGroup is not "Group" then
			display dialog "The selected cue is not a Group. Select a Group cue and try again." ¬
				buttons {"OK"} default button 1
			return
		end if
		
		set kids to every cue of targetGroup
		if (count of kids) < 2 then return
		
		-- Build "<class>\t<name>\t<uniqueID>\n" lines for shell sort.
		-- class 0 = name starts with a letter (so letters sort first),
		-- class 1 = name starts with a digit / symbol / is empty.
		set lf to ASCII character 10
		set tb to ASCII character 9
		set buf to ""
		repeat with c in kids
			set nm to q name of c
			if nm is missing value then set nm to ""
			set cls to "1"
			if (count of nm) > 0 then
				set fc to character 1 of nm
				if (fc ≥ "A" and fc ≤ "Z") or (fc ≥ "a" and fc ≤ "z") then ¬
					set cls to "0"
			end if
			set buf to buf & cls & tb & nm & tb & (uniqueID of c) & lf
		end repeat
		
		set sortedText to do shell script ¬
			"printf %s " & quoted form of buf & ¬
			" | LC_ALL=en_US.UTF-8 sort -f -t \"$(printf '\\t')\" -k1,1 -k2,2"
		
		set currentTIDs to AppleScript's text item delimiters
		set AppleScript's text item delimiters to lf
		set sortedLines to text items of sortedText
		set AppleScript's text item delimiters to currentTIDs
		
		repeat with ln in sortedLines
			set lnText to ln as text
			if lnText is not "" then
				set AppleScript's text item delimiters to tb
				set parts to text items of lnText
				set AppleScript's text item delimiters to currentTIDs
				set cid to item 3 of parts
				move cue id cid of targetGroup to end of targetGroup
			end if
		end repeat
	end tell
end tell
