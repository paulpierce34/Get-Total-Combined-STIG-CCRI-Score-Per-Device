# Get-Total-Combined-STIG-CCRI-Score-Per-Device
This script is used to calculate the total CCRI STIG score per device, from STIG checklist (.ckl) files in a directory. For example, if you have numerous devices with numerous STIGs applied to each of them in the given directory, the script will combine all the scores per device and then calculate the CCRI score (out of 100%) per device.



** NOTE **:  This script expects you to have a specific naming convention for your STIG checklists. The naming convention is very much similar to default DISA style. 

Example name from DISA:
U_MOZ_Firefox_STIG_V6R1.ckl

Expected name in script (without the escape characters):
 `Myhostname_U_MOZ_Firefox_STIG_V6$1.ckl`

The reason this is needed is because this is how all of the applied STIGs per device are combined, by hostname.
