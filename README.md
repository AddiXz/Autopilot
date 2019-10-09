# Autopilot
A more automated way of retrieving the Autopilot information from your device(s).

### notes
This script has been created for **Dell** machines. I currently can not guarantee that it will also work for other vendors.

The default actions the script will run, don’t need any adjustments when:
- The target device has only a C:\ drive
- The USB drive has the files listed under "Preparation" in the root folder.

## Preparation.
- Retrieve the get-windowsautopilotinfo.ps1 script at
> https://www.powershellgallery.com/packages/Get-WindowsAutoPilotInfo/1.6

- Copy both the Autopilot.ps1 and get-windowsautopilotinfo.ps1 to a USB drive.
 
## Before running the script.
- Take the machine out of its box and connect it to AC Power.
- Insert the USB drive.

## Running the script.
1.	Start the machine from which you wish to retrieve the information.
2.	Make sure the machine boots into the OOBE environment.
3.	Press Shift+F10 to bring up a CMD screen.
4.	Enter: 
```cmd
powershell.exe
```
```diff
4. a) In most cases when you want to run the script PowerShell will throw an error like the following: 
- Autopilot.ps1 cannot be loaded because running scripts is disabled on this system.
To resolve this; enter the following:"
```
```posh
Set-ExecutionPolicy Bypass 
```

5.	Enter: 
```posh
D:\Autopilot.ps1
```
```
Let the script run. This will take about 10 seconds. 
Once you see: “Shutting down the device. You can now safely remove the USB drive.” You can remove the USB drive.
The machine will shut down on its own.
Now the machine can be put back into the original box.
```

## Using the Parameters.
For ease of use, some parameters have been added to the script to be used when running it.

To use the parameters add them to your initial command in PowerShell to run the script. For example to run the script with:
- a different output filename 
- a different USB drive letter
- No shutdown
- Appending to the same file for multiple machines

Enter:
```posh
D:\Autopilot.ps1 -OutputFile 'NewName.csv' -SecDrive 'E:\' -NoShutDown -Append
```

-OutputFile 
```posh
-Outputfile ‘filename.csv’
```
- Change the name of the output file. 
- Make sure to add ‘.csv’ at the end of the name.


-SName 
```posh
-SName ‘get-WindowsAutoPilotInfo.ps1’
```
- Change the name of the Autopilot script from Microsoft that this script should look for.
- Only change this if the script name differs from the default.


-PrimDrive 
```posh
-PrimDrive ‘C:\’
```
- Change the Primary Drive (OS drive) Letter to use.
- Make sure to write it in the following format:  “C:\


-TempFol 
```posh
-TempFol ‘FolderName\’
```
- Change the temporary folder name used on the local machine.

-SecDrive 
```posh
-SecDrive ‘E:\’
```
- Change the USB drive letter to use.
- Make sure to write it in the following format:  “C:\”


-ScrF 
```posh
-ScrF ‘FolderName\’
```
- Change the names of the subfolder(s) on the USB drive to use, containing the scripts.


-OutFol 
```posh
-OutFol ‘FolderName\’
```
- Change the folder name on the USB drive for the output file.


-Append 
```posh
-Append
```
- Turn on appending a file on the USB drive or single file output.
- ***Please note; when the above parameters have been changed only on the current device, the append will not work. It will look for existing files based on the above parameters.***


-NoShutdown 
```posh
-NoShutdown
```
- Prevent shutting down the device when done.


 
## Manually adjusting the default parameters for future use.

If you are going to use the script more often, and there are certain parameters you feel you need to change every time, then you can adjust the default parameters where necessary: 
 
```posh
$OutputFile = "Name of the output file for an appended run. Don’t forget to keep “.csv” after the name."
$SName = "Name of the Autopilot script from Microsoft."
$PrimDrive = "Primary Drive (OS drive) on the local machine to run the script from."
$TempFol = "Temporary Folder used on the local machine."
$SecDrive = "Secondary drive. This should be the USB drive."
$ScrF = "Subfolder(s) on the Secondary (USB) drive containing the scripts."
$OutFol = "Location for the output files."
$Append = "Switch between appended or single file output."
$NoShutdown = "Switch to shut down the device or not when done."
