param(
    [Parameter(Mandatory = $false)][string] $EnvironmentName = "AzureCloud",
    [Parameter(Mandatory = $false)][string] $SubscriptionId = "",
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is reqiured"),
    [Parameter(Mandatory = $true)][string] $LogicAppName = $(throw "Name of logic app is required"),
    [Parameter(Mandatory = $false)][string] $ApiVersion = "2016-06-01",
    [Parameter(Mandatory = $false)][string] $AccessToken = ""
)

try{
    if($SubscriptionId -eq "" -or $AccessToken -eq ""){
        # Request accessToken in case the script contains records
        $token = Get-AzCachedAccessToken

        $AccessToken = $token.AccessToken
        $SubscriptionId = $token.SubscriptionId
    }
    
    $fullUrl = . $PSScriptRoot\Get-AzLogicAppResourceManagementUrl.ps1 -EnvironmentName $EnvironmentName -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -ApiVersion $ApiVersion -Action enable
    
    Write-Verbose "Attempting to enable Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'..."
    $params = @{
        Method = 'Post'
        Headers = @{ 
            'authorization'="Bearer $AccessToken"
        }
        URI = $fullUrl
    }

    $web = Invoke-WebRequest @params -ErrorAction Stop
    Write-Host "Successfully enabled Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'" -ForegroundColor Green
}
catch {
    Write-Warning "Failed to enable Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'"
    $ErrorMessage = $_.Exception.Message
    Write-Debug "Error: $ErrorMessage"
} 
