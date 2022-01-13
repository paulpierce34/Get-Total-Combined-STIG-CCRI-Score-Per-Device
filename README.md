# Get-Total-Combined-STIG-CCRI-Score-Per-Device
This script is used to calculate the total CCRI STIG score per device, from STIG checklist (.ckl) files in a directory. For example, if you have numerous devices with numerous STIGs applied to each of them in the given directory, the script will combine all the scores per device and then calculate the CCRI score (out of 100%) per device.



** NOTE **:  This script expects you to have a specific naming convention for your STIG checklists. The naming convention is very much similar to default DISA style. 

Example name from DISA:
`_U_MOZ_Firefox_STIG_V6R1.ckl`

Expected name in script:
 `Myhostname_U_MOZ_Firefox_STIG_V6R1.ckl`

Replace the <Myhostname> section above with the hostname of your device when naming the checklist files. The reason this is needed is because this is how all of the applied STIGs per device are combined, by hostname.

 REQUIREMENTS:
 - A directory of STIG checklists (or just one checklist)
 - Powershell ISE
 
 HOW TO USE:
 - Open script in Powershell ISE
 - Make changes in the 'Make Changes' section (as always :D)
 - You will need to provide values for the following variables:
 1.) Directory of STIG checklists to look through (Variable name: $Dirpath)
 2.) Output filepath (without filename) (Variable name: $Outpath)
