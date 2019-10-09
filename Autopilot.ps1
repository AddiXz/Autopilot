<# PSScript INFO

Automated Autopilot gathering v2.97
Created by Mauro Sahanaja


How to use : 
 
1. Start the machine from which you wish to retreive the information.
2. Make sure the machine boots into the OOBE environment.
3. Plug in the usb drive.
4. Press Shift+F10.
5. Type: D: and press enter.
6. Type: powershell.exe and press enter.
    6b) In most cases powershell might throw an error like the following:  
    Autopilot.ps1 cannot be loaded because running scripts is disabled on this system. 
    To resolve this type the following, and press enter:  
    Set-ExecutionPolicy Unrestricted  
7. Type: Autopilot.ps1 (or type Auto, press tab) and press enter.

Let the script run. This will take about 10 seconds. 

Once you see:
"Shutting down device. You can now safely remove the USB drive." 
there might be an error. Press continue and pull out the USB drive.

The machine will shutdown on it's own and can be put back into the original box. 
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $False)] [String] $OutputFile = 'Results.csv', 
    [Parameter(Mandatory = $False)] [String] $SName = 'get-windowsautopilotinfo.ps1', 
    [Parameter(Mandatory = $False)] [String] $PrimDrive = 'C:\', 
    [Parameter(Mandatory = $False)] [String] $TempFol = 'AutoPilot\', 
    [Parameter(Mandatory = $False)] [String] $SecDrive = 'D:\', 
    [Parameter(Mandatory = $False)] [String] $ScrF = '', 
    [Parameter(Mandatory = $False)] [String] $OutFol = 'Outputs\', 
    [Parameter(Mandatory = $False)] [Switch] $Append = $false,
    [Parameter(Mandatory = $False)] [Switch] $NoShutdown = $false
)

<# !! DO NOT EDIT ANYTHING BELOW THIS POINT !! #>

Begin {
    # Combining variables #
    $ScrDrive = $($SecDrive) + $($ScrF)
    $AutoPilot = $($SecDrive) + $($ScrF) + $($SName)
    $OutLoc = $($SecDrive) + $($OutFol)
    $PreLoc = $($SecDrive) + $($OutFol) + $($OutputFile)
    $NewLoc = $($PrimDrive) + $($TempFol)
    $NewScr = $($PrimDrive) + $($TempFol) + $($SName)
    $PostLoc = $($PrimDrive) + $($TempFol) + $($OutputFile)

    # Output Order
    $1 = "Device Serial Number"
    $2 = "Windows Product ID"
    $3 = "Hardware Hash"

    # Error catching & releasing file block #
    $erroractionPreference = "stop"
    dir $ScrDrive | Unblock-File


    # Get computer Serial number and create filename for single device use #
    $sn = Get-WmiObject win32_bios | select -expand serialnumber
    $filename = $sn + "_Autopilot.csv"

    # Get items 
    $ExecP = Get-ExecutionPolicy | where-object { $_ -eq "Restricted"}
    $script = Get-ChildItem $ScrDrive | where-object { $_.Name -eq $SName } | select Name

}


Process {
    # Change execution policy if necessary #
    if ($ExecP) {
        Set-ExecutionPolicy Unrestricted -Force
    }
    else {
        Write-Host "No need to change Policy."
    }

    # Create Temp Folder (if it doesn't exist) #
    if (!(Test-Path $NewLoc)) {
        Write-Host "Creating necessary folders"
        md $NewLoc
    }
    else {
        Write-Host "Temporary Folder already exists" -ForegroundColor Green
    }
    Start-Sleep -m 200

    # Create Outputs folder (if it doesn't exist) #
    if (!(Test-Path $OutLoc)) {
        Write-Host "Creating necessary folders"
        md $OutLoc
    }
    else {
        Write-Host "Output Folder already exists" -ForegroundColor Green
    }
    Start-Sleep -m 200


    # Change to new folder #
    Write-Host "Changing directory to new folders."
    Set-Location $NewLoc
    Start-Sleep -m 200

    # Copy script #
    if ($script) {
        Write-Host "Copying script."
        copy $AutoPilot $NewLoc
        Start-Sleep -m 200
    }
    else {
        Write-Host "Script wasn't found. Please make sure $SName is on $ScrDrive, and run the script again." -ForegroundColor Red
    }

    # Check if script was copied #
    $CopiedScript = Get-ChildItem $NewLoc | where-object { $_.Name -eq $SName } | select Name
    if ($CopiedScript) { 
    }
    else {
        Write-Host "Script was not copied correctly. Please try running the script again with administrator priveleges." -ErrorAction stop
        Start-Sleep -m 200
    }


    # If append - Check if file exists and copy or create where necessary #
    if ($Append) { 
        if (!(Test-Path $PreLoc)) { 
            write-host "Creating $Outputfile in $NewLoc"
            Set-Content "$($NewLoc)$($Outputfile)" -Value "$($1),$($2),$($3)"
            Start-Sleep -m 200
        }
        else {
            Write-Host "Copying $OutPutFile to $NewLoc."
            copy $PreLoc $NewLoc
            Start-Sleep -m 200
        }
    }
    # Else - Check if device file exists, and copy or create where necessary #
    else {
        $OldFilename = "$($OutLoc)$($filename)"

        if (!(Test-Path $OldFilename)) { 
            write-host "Creating $filename in $NewLoc"
            Set-Content "$filename" -Value "$($1),$($2),$($3)"
            Start-Sleep -m 200
        }
        else {
            
            Write-Host "Copying $filename to $NewLoc."
            copy $OldFilename $NewLoc
            Start-Sleep -m 200
        }
    }

    # Run AutoPilot #
    if ($Append) {
        Write-Host "Running script and parsing info to $OutPutFile" -ForegroundColor Yellow
        $Output = Invoke-Expression $NewScr
        $OFS = ","
        ($Output.GetEnumerator() | Sort-Object -Property $1, $2, $3  | % { $($_.Value) }) -join ',' | Out-File $PostLoc -Append
        Start-Sleep -m 200

        # Copy CSV to Secondary Drive #
        write-host "Copying $OutPutFile to $OutLoc"
        copy $PostLoc $OutLoc 
        Start-Sleep -m 200
        
        # Check if file exists #
        $FileCreated = Get-ChildItem $OutLoc | where-object { $_.Name -eq $OutputFile } | select Name
        if (!(test-path "$($OutLoc)$($FileCreated.Name)")) {
            Write-Host "$OutPutFile could'nt be found. Please run the script again" -ForegroundColor red
        }
        else {
            Write-Host "$OutPutFile copied succesfully!" -ForegroundColor Green
        }
    }
    else {
        try {
            write-host "Running script and parsing info to $filename" -ForegroundColor Yellow
            $Output = Invoke-Expression $NewScr
            $OFS = ","
            ($Output.GetEnumerator() | Sort-Object -Property $1, $2, $3  | % { $($_.Value) }) -join ',' | Out-File $filename -Append
            Start-Sleep -m 200

            # Copy CSV to Secondary Drive #
            write-host "Copying $filename to $OutLoc"
            copy $filename $OutLoc 
            Start-Sleep -m 200

            # Check if file exists #
            $FileCreated = Get-ChildItem $OutLoc | where-object { $_.Name -eq $filename } | select Name
            if (!(test-path "$($OutLoc)$($FileCreated.Name)")) {
                Write-Host "$filename could'nt be found. Please run the script again" -ForegroundColor red
            }
            else {
                Write-Host "$filename copied succesfully!" -ForegroundColor Green
            }

        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
        }
    }
    Start-Sleep -m 200
}


END {
    Set-Location $PrimDrive

    # Clear files #
    Write-Host "Clearing temporary files" 
    Get-ChildItem -Path $NewLoc |  Remove-Item -Force -Recurse
    start-sleep -s 2

    # Eject USB #
    Write-Host "Ejecting USB Drive."
    $Eject = New-Object -comObject Shell.Application
    $Eject.NameSpace(17).ParseName($SecDrive).InvokeVerb(“Eject”)

    # Shut Down #
    if ($NoShutdown){
        write-host "Done"
    }
    else {
        Write-Host "Shutting down device. You can now safely remove the USB drive." -ForegroundColor Magenta
        start-sleep -s 5
            #shutdown /s /t 5
    }
}