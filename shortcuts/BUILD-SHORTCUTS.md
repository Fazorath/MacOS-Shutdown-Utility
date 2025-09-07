# Build the Shortcuts (macOS)

This repo ships shell scripts. To create the Shortcuts UI:

## Schedule Shutdown
1. **Ask for Text** → Prompt: `Shutdown time (e.g., 11:25 PM or 23:25)`  
   - *Allow Multiple Lines*: **Off**
2. **Run Shell Script**
   - Shell: `bash`
   - Script: `/absolute/path/to/repo/scripts/schedule-shutdown.sh`
   - Input: **Ask for Text** (the blue token)
   - Pass Input: **as arguments**
3. **Show Notification**
   - Title: `Schedule Shutdown` (optional)
   - Text: **Shell Script Result** (the blue token)
   - Attachment: *(empty)*

## Cancel Shutdown
1. **Run Shell Script**
   - Shell: `bash`
   - Script: `/absolute/path/to/repo/scripts/cancel-shutdown.sh`
2. **Show Notification**
   - Text: **Shell Script Result**
