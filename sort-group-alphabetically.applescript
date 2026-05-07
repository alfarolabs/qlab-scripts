-- QLab 5 -- Sort the cues inside the SELECTED group alphabetically
-- (A-Z first, then digits/symbols).
-- Requires exactly ONE selected cue, and it MUST be a Group.
--
-- Usage:
--   1. In QLab, select a single Group cue.
--   2. Run this script (from a Script cue, Script Editor, or hotkey).
--   3. The group's immediate children are reordered alphabetically by q name.
--      Nested groups are left in place; their internal contents are untouched.
--
-- NOTE: This file is intentionally pure ASCII (no smart quotes, em dashes,
-- line-continuation backslashes, or Unicode comparison operators) so it can
-- be pasted into QLab's Script cue editor without encoding corruption.

tell application id "com.figure53.QLab.5"
	tell front workspace
		set sel to (selected as list)
		
		if (count of sel) is 0 then
			display dialog "Select a Group cue first." buttons {"OK"} default button 1
			return
		end if
		
		if (count of sel) > 1 then
			display dialog "Select only ONE Group cue." buttons {"OK"} default button 1
			return
		end if
		
		set targetGroup to item 1 of sel
		if q type of targetGroup is not "Group" then
			display dialog "The selected cue is not a Group. Select a Group cue and try again." buttons {"OK"} default button 1
			return
		end if
		set kids to every cue of targetGroup
		if (count of kids) < 2 then return
		
		-- Build "<class>\t<name>\t<uniqueID>\n" lines for shell sort.
		-- class 0 = name starts with a letter (so letters sort first),
		-- class 1 = name starts with a digit / symbol / is empty.
		set lf to ASCII character 10
		set cr to ASCII character 13
		set tb to ASCII character 9
		set buf to ""
		repeat with c in kids
			set nm to q name of c
			if nm is missing value then set nm to ""
			-- Strip embedded tabs/newlines from cue names so they don't break
			-- the tab/newline-delimited record format the shell sort expects.
			set savedTIDs to AppleScript's text item delimiters
			repeat with badChar in {tb, lf, cr}
				set AppleScript's text item delimiters to badChar as text
				set nmParts to text items of nm
				set AppleScript's text item delimiters to " "
				set nm to nmParts as text
			end repeat
			set AppleScript's text item delimiters to savedTIDs
			set cls to "1"
			if (count of nm) > 0 then
				set fc to character 1 of nm
				if (fc >= "A" and fc <= "Z") or (fc >= "a" and fc <= "z") then set cls to "0"
			end if
			set buf to buf & cls & tb & nm & tb & (uniqueID of c) & lf
		end repeat
		
		set sortedText to do shell script "printf %s " & quoted form of buf & " | LC_ALL=en_US.UTF-8 sort -f -t \"$(printf '\\t')\" -k1,1 -k2,2"
		
		-- `do shell script` converts shell newlines (\n) to CR (\r) in the
		-- returned text, so we split on CR here, not LF.
		set currentTIDs to AppleScript's text item delimiters
		set AppleScript's text item delimiters to cr
		set sortedLines to text items of sortedText
		set AppleScript's text item delimiters to currentTIDs
		
		set sortedIDs to {}
		repeat with ln in sortedLines
			set lnText to ln as text
			if lnText is not "" then
				set AppleScript's text item delimiters to tb
				set parts to text items of lnText
				set AppleScript's text item delimiters to currentTIDs
				set end of sortedIDs to (item 3 of parts)
			end if
		end repeat
		
		-- Move each cue, in sorted order, to the end of the group.
		-- After the loop completes, every child has been re-appended in
		-- order, so the final order matches sortedIDs.
		tell targetGroup
			repeat with cid in sortedIDs
				set cidText to cid as text
				move cue id cidText to end of targetGroup
			end repeat
		end tell
	end tell
end tell
