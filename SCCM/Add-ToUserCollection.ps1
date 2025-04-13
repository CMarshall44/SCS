Param([string]$collection, [string]$user)

# Import SCCM module
Import-Module "$executingScriptDirectory\SCCM" -DisableNameChecking

# Copy the environment variables to their parameters
if (test-path env:\SNC_collection) {
   $collection  = $env:SNC_collection
   $user = $env:SNC_user
}

SNCLog-ParameterInfo @("Running AddToUserCollection", $collection, $user)

function Add-ToUserCollection() {
   Import-Module -Name "$(split-path $Env:SMS_ADMIN_UI_PATH)\ConfigurationManager.psd1"
   Set-Location -path "$(Get-PSDrive -PSProvider CMSite):\"

   $collection = $args[0]
   $username = "*\" + $args[1] + " *"

   $id = (Get-CMUser -Name $username).ResourceID

   $coll = Get-CMCollection -name $collection;
   #Get by ID
   if($coll -eq $null){
       $coll = Get-CMCollection -Id $collection;
    }
   if($coll -eq $null)
     {
       Write-Error "No object corresponds to the specified parameters."
     }
   else {
      Add-CMUserCollectionDirectMembershipRule -InputObject $coll -ResourceId $id
}
}

$session = Create-PSSession -sccmServerName $computer -credential $cred
try {
    SNCLog-DebugInfo "`tInvoking Invoke-Command -ScriptBlock `$'{function:Add-ToUserCollection}' -ArgumentList $collection, $user"
    Invoke-Command -Session $session -ScriptBlock ${function:Add-ToUserCollection} -ArgumentList $collection, $user
} finally {
    Remove-PSSession -session $session
}