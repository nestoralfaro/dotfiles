# C:\Users\{username}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

Set-PSReadlineOption -EditMode vi
function prompt {
    $NEWLINE = "`n"
    $ESC = [char]27  # ANSI escape character
    $GREEN = "$ESC[48;5;28m"  # Green color for TIME
    $CYAN = "$ESC[48;5;18m"   # Cyan color for LOCATION
    $RESET = "$ESC[0m"   # Reset color

    $TIME = Get-Date -Format "HH:mm:ss"
    $USER = $env:USERNAME
    $LOCATION = Get-Location

    "${GREEN}${TIME}${RESET}@${CYAN}${LOCATION}${RESET}${NEWLINE}> "
}

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
