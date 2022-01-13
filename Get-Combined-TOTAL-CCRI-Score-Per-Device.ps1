## The purpose of this script is to combine CCRI scores from numerous checklist applied to the same device, and roll them into a total device CCRI score


## MAKE CHANGES HERE IF NEEDED ##

$DirPath = "C:\temp\QuickTEST" #"C:\temp\Testlocation"  ## Provide the directory of checklists to look through

$OutPath = "C:\temp\QuickTEST\" ## Output PATH

## END MAKE CHANGES SECTION ##












## Variables ##
$TodayDate = Get-Date -Format yyyy-MM-dd


$CombinedOut = $OutPath + $TodayDate + "Combined_CCRI_Scores.csv"

$RawDataOut = $OutPath + $TodayDate + "Raw_CCRI_Scores_by_STIG.csv"


$AllChecklists = Get-Childitem -Path $DirPath | Where {$_.Name -like "*.ckl*"} | Sort-Object -Property Name

## The combined output into a csv 
$CCRIObj = @()


## Each individual device totals
$ServerObj = @()

## Name comparison
$NameObj = @()


## END VARIABLES SECTION #####



## BEGIN SCRIPT ##

Foreach ($Checklist in $Allchecklists){

## Replaces the name of checklist with hostname, better for matching up into the same object output
$Newname = $Checklist -replace '_U_.*', ''

$NameObj += $NewName


## Let user know which ckl you're working on
write-host -Foregroundcolor Cyan "Working on $Checklist..."


## Convert checklist into an XML object
[XML]$CKLdata = Get-Content $Checklist.FullName # Convert file to XML object


## Dig into each vulnerability to eventually access the Status
$Eachvuln = $CKLData.Checklist.STIGs.iSTIG.VULN

## Total vulns, total opens
$ChecklistCatIII = 0
$ChecklistCatII = 0
$ChecklistCatI = 0
$ChecklistCatIIIOpen = 0
$ChecklistCatIIOpen = 0
$ChecklistCatIOpen = 0


## Iterate through the vulnerability so we can pull some more info!
foreach ($Diffvuln in $Eachvuln){

$Childnodes = $DiffVuln.ChildNodes

$VulnSeverity = $Childnodes.Item(1).Attribute_Data ##Pull vulnerability severity high/medium/low

$StigRef = $Childnodes[22].Attribute_Data

if ($VulnSeverity -eq "Low"){
$ChecklistCatIII += 1
}

if ($VulnSeverity -eq "Medium"){
$ChecklistCatII += 1
}

if ($VulnSeverity -eq "High"){
$ChecklistCatI += 1
}

## IF OPEN STATUS
if ($DiffVuln.Status -eq "Open"){

if ($VulnSeverity -eq "Low"){
$ChecklistCatIIIOpen += 1
}

if ($VulnSeverity -eq "Medium"){
$ChecklistCatIIOpen += 1
}

if ($VulnSeverity -eq "High"){
$ChecklistCatIOpen += 1
}

} ## END OF IF OPEN

} ## end of Foreach different vulnerability





#### CCRI LOGIC CALCULATIONS BEGIN - for not dividing by zeros and calculating CCRI score


if ($ChecklistCatI -eq 0 -and $ChecklistCatII -ne 0 -and $ChecklistCatIII -ne 0){
$ChecklistCatIOpen = 0

$CCRIScore = (($ChecklistCatIIIOpen/$ChecklistCatIII*1*100/15)+($ChecklistCatIIOpen/$ChecklistCatII*4*100/15))


}
if ($ChecklistCatII -eq 0 -and $ChecklistCatI -ne 0 -and $ChecklistCatIII -ne 0){
$ChecklistCatIIOpen = 0

$CCRIScore = (($ChecklistCatIIIOpen/$ChecklistCatIII*1*100/15)+($ChecklistCatIOpen/$ChecklistCatI*10*100/15))

}
if ($ChecklistCatIII -eq 0 -and $ChecklistCatI -ne 0 -and $ChecklistCatII -ne 0){
$ChecklistCatIIIOpen = 0

$CCRIScore = (($ChecklistCatIIOpen/$ChecklistCatII*4*100/15)+($ChecklistCatIOpen/$ChecklistCatI*10*100/15))

}



if ($ChecklistCatI -eq 0 -and $ChecklistCatII -eq 0){
$ChecklistCatIOpen = 0
$ChecklistIIOpen = 0

$CCRIScore = (($ChecklistCatIIIOpen/$ChecklistCatIII*1*100/15))


}
if ($ChecklistCatI -eq 0 -and $ChecklistCatIII -eq 0){
$ChecklistCatIOpen = 0
$ChecklistCatIIIOpen = 0

$CCRIScore = (($ChecklistCatIIOpen/$ChecklistCatII*4*100/15))



}
if ($ChecklistCatII -eq 0 -and $ChecklistCatIII -eq 0){

$ChecklistCatIIOpen = 0
$ChecklistCatIIIOpen = 0

$CCRIScore = (($ChecklistCatIOpen/$ChecklistCatI*10*100/15))


}



if ($ChecklistCatI -ne 0 -and $ChecklistCatII -ne 0 -and $ChecklistCatIII -ne 0){

$CCRIScore = (($ChecklistCatIIIOpen/$ChecklistCatIII*1*100/15)+($ChecklistCatIIOpen/$ChecklistCatII*4*100/15)+($ChecklistCatIOpen/$ChecklistCatI*10*100/15))

}

#### CCRI LOGIC CALCULATIONS OVER

write-host -Foregroundcolor Yellow "CCRI SCORE: $CCRIScore"

foreach ($Name in $NameObj){

if ($Checklist -like "*$Name*"){


write-host "$Checklist is like $Name"

$ServerObj += New-Object PSObject -Property @{


Hostname = $Name;
Cat_I = $ChecklistCatI;
Cat_I_Open = $ChecklistCatIOpen;
Cat_II = $ChecklistCatII;
Cat_II_Open = $ChecklistCatIIOpen;
Cat_III = $ChecklistCatIII;
Cat_III_Open = $ChecklistCatIIIOpen;
STIGRef = $StigRef
CCRI_Score = $CCRIScore

} ## end property builder


} ## if checklist matches with name object


} ## end of foreach name in nameobj


$NameObj = $Null

} ## end of foreach checklist


$CCRITotal = @() ## Declare empty object for use below

$ServerObj | Select-Object Hostname, Cat_I, Cat_I_Open, Cat_II, Cat_II_Open, Cat_III, Cat_III_Open, CCRI_Score, StigRef | Sort-Object Hostname, Cat_I, Cat_I_Open, Cat_II, Cat_II_Open, Cat_III, Cat_III_Open, CCRI_Score, StigRef | Export-csv -Path $RawDataOut -Notypeinformation -Append

$GroupingTotals = $ServerObj | Group-Object Hostname

#$CombinedScores = $GroupingTotals | Select-Object Name, @{ n='CCRI_Score'; e={ (($_.Group | Measure-Object CCRI_Score -Sum).Sum) / 5 } }    ### See that 5? That needs to change to a variable that represents the count of the grouped object to divide by the total amount of checklists applied to each hostname

foreach ($Thingy in $GroupingTotals){

$CombinedScores = $Thingy | Select-Object Name, @{ n='CCRI_Score'; e={ (($_.Group | Measure-Object CCRI_Score -Sum).Sum) / $Thingy.Count } }

$CCRITotal += New-Object PSObject -Property @{

Name = $Thingy.Name;
Combined_CCRI_Score = $CombinedScores.CCRI_Score;
STIGS_Applied = $Thingy.Count;

}

}

$CCRITotal | Select-Object Name, Combined_CCRI_Score, STIGS_Applied | Sort-Object Name, Combined_CCRI_Score, STIGS_Applied | Export-Csv -Path $CombinedOut -NoTypeInformation -Append

if ((Test-path -Path $RawDataOut) -and (Test-Path -Path $CombinedOut)){

write-host -Foregroundcolor Green "Successfully created output files here:  $RawDataOut"
write-host -Foregroundcolor Green "Successfully created output files here:  $CombinedOut"

}





## $Grouping[1].Group.CCRI_Score   to access the CCRI_Score property from the grouped object

<#
Foreach ($Server in $ServerObj){








if ($Server.Hostname -match $Server.Hostname){

$NewCCRI = (($Server.CCRI_Score + $Server.CCRI_Score)/2)


} ## end if hostname match hostname





} ## end of foreach
#>








### Check out the $NameObj | Group-Object    output 

### $Grouping = $NameObj | Group-Object
###  $Grouping[1].Name    to access the name 



<#
for ($i=0; $i -lt $GroupingTotals.Count; $i += 1){

write-host $GroupingTotals[$i].Count
$CombinedScores = $GroupingTotals | Select-Object Name, @{ n='CCRI_Score'; e={ (($_.Group | Measure-Object CCRI_Score -Sum).Sum) / $GroupingTotals[$i].Count } }


}

#>