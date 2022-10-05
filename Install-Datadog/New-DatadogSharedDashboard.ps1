Param(
    [Parameter(ValueFromPipeline=$True)]
    $newdashboardJSON
)

# This script must be called from Install-Datadog.ps1
Function CheckForParentScript {
    Set-Location -Path $PSScriptRoot
    if (!($DependencyCheck)) {
        .\Install-Datadog.ps1
    } #exit
} CheckForParentScript

#Had to add this line to get rid of "The underlying connection was closed: An unexpected error occurred on a send." error
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13  
    
$global:id = $new_Dashboard_Response | Select-Object -ExpandProperty id

Write-Host ""
Write-Host "Step 6"
Write-Host "Sharing the dashboard" -ForegroundColor Yellow
    
$shared_dashboardJSON = "{
    `"dashboard_id`": `"$($id)`",
    `"dashboard_type`": `"custom_screenboard`",
    `"global_time`": {
      `"live_span`": `"1h`"
    },
    `"global_time_selectable_enabled`": false,  
    `"selectable_template_vars`": [
      {
        `"default_value`": `"*`",
        `"name`": `"defaultName`",
        `"prefix`": `"defaultPrefix`",
        `"visible_tags`": [
          `"default`"
        ]
      }
    ],
    `"share_type`": `"open`"
    }"

    $shared_dashboardheaders = @{
        "DD-API-KEY" = $apikey
        "DD-APPLICATION-KEY" = $appkey
        "Content-Type" = "application/json"
    }

        $shared_dashboardparams = @{
        Uri = "https://api.datadoghq.com/api/v1/dashboard/public"
        Method = "POST"
        Headers = $shared_dashboardheaders
        Body = $shared_dashboardJSON
    }  
    
$global:new_SharedDashboard_Response = Invoke-RestMethod @shared_dashboardparams
$new_SharedDashboard_Response | Out-File .\Shared-Dashboard-Response.txt

Write-Host "Done" -ForegroundColor Cyan

$global:public_url = $new_SharedDashboard_Response | Where-Object {$_.dashboard_id -eq $id} | Select-Object -ExpandProperty public_url
$public_url | Set-Clipboard
   
Write-Host ""
Write-Host "URL has been copied to clipboard" -ForegroundColor Green
Write-Host ""
Write-Host "Launching shared dashboard"
#start $public_url
[Diagnostics.Process]::Start($public_url)
Start-Sleep -Seconds 30
exit
