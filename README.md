# oscdimg-automation
Build a bootable Windows ISO from a Rufus USB stick


How to use:

1) Use Rufus to make a bootable USB stick with your customizations (ie. local user, TPM bypass, etc).
2) Copy the USB stick to the hard drive (drag and drop).
3) Run the script against these files to make a new bootable ISO file (ie. .\Build-WindowsISO.ps1 -FilePath "C:\path\to\iso\files\from\rufus" -ISOPath "C:\path\to\target\rufus.iso")


This has been tested on Windows 11 24H2.


The files in the .\bin folder come from the Windows ADK (https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install). Install it with the Deployment Tools option selected. The files needed will be located at C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg.
