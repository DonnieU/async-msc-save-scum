<#
  Wanna be a scumbag for 'My Summer Car'? This is your ticket
  to backup those precious saves! 

  - Monitors "items.txt" in the 'My Summer Car' dir and if it
    is modified then it copies files to a save game dir delineated
    by a timestap.

  - This is Asynchronous so one needn't worry about missing a
    save to scum with!

  - Gracefully exits with <CTRL>+C and unregisters (i.e. terminates) events.

  - This could be modified to monitor other files and/or directories.

  ** NOT thoroughly tested, nor is there any error checking! **
#>

################################################
#### CHANGE <User> TO APPROPRIATELY FIRST!! ####
################################################

# specify the path to the folder you want to monitor:
# source game saves dir
#### CHANGE <User> TO APPROPRIATE USER ####
$global:SaveFilesPath = "C:\Users\<User>\AppData\LocalLow\Amistech\My` Summer` Car"
# Used in concantenating paths
$global:SaveGameDirName = "My` Summer` Car"
# Parent directory of save game backups
$global:BackupFilesPath = "C:\game-saves\msc"

# specify which file(s) you want to monitor
# "items.txt" is a known constant for identifying a new save
$FileFilter = "items.txt"  

# specify whether you want to monitor subdirectories as well:
$IncludeSubdirectories = $False

# Get available colors for console
# $Colors = [Enum]::GetValues([System.ConsoleColor])
# ehhh...decided to go with a static list of colors
$Colors = @("Gray","DarkGray","Blue","Green","Cyan","Red","Magenta","Yellow","White")

# This gets the actual upper bound index number instead of doing a '-1' with Length
$ColorsUpperBound = $Colors.GetUpperBound(0)

# specify the file or folder properties you want to monitor:
$AttributeFilter = [IO.NotifyFilters]::FileName, [IO.NotifyFilters]::LastWrite 

try
{
  $Watcher = New-Object -TypeName System.IO.FileSystemWatcher -Property @{
    Path = $SaveFilesPath
    Filter = $FileFilter
    IncludeSubdirectories = $IncludeSubdirectories
    NotifyFilter = $AttributeFilter
  }

  # define the code that should execute when a change occurs:
  $Action = {
    # the code is receiving this to work with:
    
    # change type information:
    $Details = $Event.SourceEventArgs
    $Name = $Details.Name
    $FullPath = $Details.FullPath
    $OldFullPath = $Details.OldFullPath
    $OldName = $Details.OldName
    
    # type of change:
    $ChangeType = $Details.ChangeType
    
    # when the change occured:
    $Timestamp = $Event.TimeGenerated | Get-Date -f "yyyy/MM/dd @ HHmm"
    
    # save information to a global variable for testing purposes
    # so you can examine it later
    # MAKE SURE YOU REMOVE THIS IN PRODUCTION!
    #$global:all = $details
    
    # Message describing the change
    $Text = "{0} was {1} at {2}hrs" -f $FullPath, $ChangeType, $Timestamp
    Write-Host ""
    Write-Host $Text -ForegroundColor DarkYellow
    
    if ($ChangeType -eq "Changed")
    {
      $TimestampForDir = $Event.TimeGenerated | Get-Date -f "yyyyMMdd_HHmm"
      # Easy way to concantenate paths
      $BackupTimestampDir = Join-Path -Path $BackupFilesPath -ChildPath $TimestampForDir
      $FinalDest = Join-Path -Path $BackupTimestampDir -ChildPath $SaveGameDirName

      New-Item -Path $FinalDest -ItemType Directory
      Copy-Item -Path $($SaveFilesPath+'\*') -Destination $FinalDest

      Write-Host "Backup for scum made to" $FinalDest -ForegroundColor "Magenta"
    }
  }

  # subscribe your event handler to all event types that are
  # important to you. Do this as a scriptblock so all returned
  # event handlers can be easily stored in $handlers:
  $Handlers = . {
    Register-ObjectEvent -InputObject $Watcher -EventName Changed  -Action $Action 
    Register-ObjectEvent -InputObject $Watcher -EventName Created  -Action $Action 
    Register-ObjectEvent -InputObject $Watcher -EventName Deleted  -Action $Action 
    Register-ObjectEvent -InputObject $Watcher -EventName Renamed  -Action $Action 
  }

  # monitoring starts now:
  $Watcher.EnableRaisingEvents = $True

  Write-Host ""
  Write-Host "Watching for changes to $($SaveFilesPath + '\' + $FileFilter)" -ForegroundColor Green
  Write-Host ""
  Write-Host "Press <CTRL> + C to quit and unregister events" -ForegroundColor Green
  Write-Host "i.e. clean up after the save scummer. lol" -ForegroundColor Green
  Write-Host ""

  # For indexing $Colors
  $Color = 0

  # since the FileSystemWatcher is no longer blocking PowerShell
  # we need a way to pause PowerShell while being responsive to
  # incoming events. Use an endless loop to keep PowerShell busy:
  do
  {
    # Wait-Event waits for a second and stays responsive to events
    # Start-Sleep in contrast would NOT work and ignore incoming events
    Wait-Event -Timeout 1

    # write a dot to indicate we are still monitoring (w/ pretty colors!):
    Write-Host "." -NoNewline -ForegroundColor $Colors[$Color]
    $Color++
    if($Color -eq $ColorsUpperBound) { $Color = 0 }
        
  } while ($True)
}
finally
{
  # this gets executed when user presses CTRL+C:
  
  # stop monitoring
  $Watcher.EnableRaisingEvents = $False
  
  # remove the event handlers
  $Handlers | ForEach-Object {
    Unregister-Event -SourceIdentifier $_.Name
  }
  
  # event handlers are technically implemented as a special kind
  # of background job, so remove the jobs now:
  $Handlers | Remove-Job
  
  # properly dispose the FileSystemWatcher:
  $Watcher.Dispose()
 
  Write-Host ""
  Write-Warning "File monitoring ending and unregistering events."
  Write-Warning "Oh don't worry, you're still scummy..."
}