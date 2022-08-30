# Asynchronous My Summer Car Save Game Files Backup
PowerShell script that monitors changes to the save game files and backs up said files. This helps to reduce lost progress when death occurs or some other issue occurs.

Tested but no error checking so YMMV. Could be modified for other games, files, or apps.

To use:

1. Change 'SaveFilesPath', 'SaveGameDirName', and 'BackupFilesPath' accordingly.

2. Create text file 'items.txt' and add files (and paths) you want to monitor.

3. Decide if you want to monitor subdirectoriees with 'IncludeSubdirectories'

4. To test, uncomment 'global:all' line

5. Once all above are complete then run the PS script in a PS terminal.

6. <CTRL+C> will terminate process.

7. Enjoy being scummy! (Or, How I Learned to Not Lose So Much Progress.)
