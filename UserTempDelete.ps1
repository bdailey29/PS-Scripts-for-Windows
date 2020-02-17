# This script will delete files older than 7 days, and create a log file. If there are files that are unable to delete because of the file name being too long, the script will rename the files and then delete the files based on all conditions/
# Script uses a log-it function b/c I like logging functions with powershell rather than writing to file name
# Script also contains test variable path to use for testing of the script functionality 

$LogFileDir          = "C:\"
$TargetDir           = "\\*"
#$TestTargetDir       = "\\?\\temp\temp\temp\temp\*"
$LogFilePath         = "C:\" + $FileDateTime + "_log.txt"
$fileDateTime        = (Get-Date -Format "yyyy-MM-dd_H-mm-ss")
$limit               = (Get-Date).AddDays(-7)
$loglimit            = (Get-Date).AddDays(-7)

# Create the log file for the delete job 
New-Item $logFilePath -type file

# logging function
function Log-It
{
    Add-Content $logFilePath ("$(Get-Date) " + $args[0])
}
Log-It ("Creating log file " + $logFilePath) 


# Delete User directory \temp\temp file older than 7 days 
#Get-ChildItem -Path $TestTargetDir -Recurse -Force `
Get-ChildItem -Path $targetDir -Recurse -Force ` ### Testing to get content
    | Where-Object { $_.LastWriteTime -lt $limit } `
        | ForEach-Object {
        $file = $_
        try {
            Log-It ("Deleting files older than 7 days in the \\temp\temp: " + $file.FullName)
            # Get-ChildItem -Path $LogFileDir -Recurse -Force ### Testing to get content
            Remove-Item $file.fullname -Recurse -Force -Confirm:$false -ErrorAction Stop
        } catch {
            Log-It ("Error deleting file: $file, $_")
        }
    }

# Delete log files older than 7 Days.
Get-ChildItem -Path $LogFileDir -Recurse -Force `
    | Where-Object { $_.LastWriteTime -lt $loglimit } `
        | ForEach-Object {
         $file = $_
            try {
                Write-Host $_.LastWriteTime
                Log-It ("Deleting backups log file(s) older than 7 days: " + $file.FullName)
                #Get-ChildItem -Path $LogFileDir -Recurse -Force ### Testing to get content
                Remove-Item $file.FullName -Recurse -Force -Confirm:$false -ErrorAction Stop
            } catch {
                Log-it $LogFilePath ("Error deleting backups log file: $file, $_")
            }
        }

Log-It ("Deleting of the user directory is complete!")
