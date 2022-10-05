if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) 
{ 
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

Set-Location -Path $PSScriptRoot

Write-Host "Current working directory: "$PSScriptRoot

#Created a bool value to prevent child scripts from being called individually
function ScopeCheck {
    [bool]$global:DependencyCheck = $True
} ScopeCheck

#Check for required files. If they don't exist, exit.
function TestForFiles {
    $conf = Test-Path -Path .\conf
    $dda = Test-Path -Path .\datadog-agent.msi
    if (!($dda) -or (!($conf))) {
        Write-Host "Required files not found! Exiting in 10 seconds." -ForegroundColor Red
        Start-Sleep -Seconds 10
        exit
    }
} TestForFiles

[string]$global:ServerName = [System.Net.Dns]::GetHostName()

function Install-DataDogAgent {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [ValidatePattern("^[C-c][0-9]{6}$")]
        [string]$global:customerNumber,
        [Parameter(Mandatory)]
        [string]$global:customerName,
        [Parameter(Mandatory)]
        [ValidatePattern("^[a-z0-9]{32}$")]
        [string]$global:apikey,
        [Parameter(Mandatory)]
        [ValidatePattern("^[a-z0-9]{40}$")]
        [string]$global:appkey
    )

    $global:UPPERCASEcustomerNumber = $customerNumber.ToUpper()
        
    $msiexecDDparams = @(
        "/i",
        "datadog-agent.msi",
        "/qn",
        "APIKEY=`"$apikey`"",
        "TAGS=`"customer_id:$($UPPERCASEcustomerNumber),env:prod,device_use:server`"",
        "REBOOT=ReallySuppress"
    )

    Write-Host ""
    Write-Host "Step 1"
    Write-Host "Installing DataDog" -ForegroundColor Yellow
    
    Start-Process msiexec -ArgumentList $msiexecDDparams -Wait
    
    Write-Host "Done" -ForegroundColor Cyan
    Write-Host ""

    $datadogsvc = Get-Service -Name datadogagent

    <#
    # I want to check to see if Datadog is installed or not, and write some output to a file. Progress logging to file.

    $agentInstalledandRunning = Get-Process -Name agent
    function ddInstallCheck {
        if (!($agentInstalledandRunning)) {
            Write-Output #to some file because agent is not running when it should be
            Write-Host "Datadog Agent is not running, which is not expected... Pausing the script"
            pause #the script to look through event viewer
        }   
    }
    #>

    function step2CopyFiles {
        Write-Host "Step 2"
        Write-Host "Copying configuration files" -ForegroundColor Yellow
        Copy-Item -Path ".\conf\system-probe.yaml" -Destination "C:\ProgramData\Datadog\system-probe.yaml" -Force
        Copy-Item -Path ".\conf\modules\wmi_check.yml" -Destination "C:\ProgramData\Datadog\conf.d\wmi_check.d\conf.yaml" -Force
        Copy-Item -Path ".\conf\modules\win32_event_log.yml" -Destination "C:\ProgramData\Datadog\conf.d\win32_event_log.d\conf.yaml" -Force
        Copy-Item -Path ".\conf\modules\process.yml" -Destination "C:\ProgramData\Datadog\conf.d\process.d\conf.yaml" -Force
        Copy-Item -Path ".\conf\modules\windows_service.yml" -Destination "C:\ProgramData\Datadog\conf.d\windows_service.d\conf.yaml" -Force
        Write-Host "Done" -ForegroundColor Cyan
        Write-Host ""
        <#
        # I need to create some "test-path" function that I can write to a file. Progress logging to file.
        #>
        
    } #End of step2CopyFiles

    function step3RestartDDSVC {
        Write-Host "Step 3"
        Write-Host "Restarting DataDog services" -ForegroundColor Yellow        
        & "$env:ProgramFiles\Datadog\Datadog Agent\bin\agent.exe" restart-service        
        Write-Host "Done" -ForegroundColor Cyan
        Write-Host ""
    } #End of step3RestartDDSVC

    function step4LaunchGUI {
        Write-Host "Step 4"
        Write-Host "Launcing DataDog Agent Manager" -ForegroundColor Yellow      
        & "$env:ProgramFiles\Datadog\Datadog Agent\bin\agent.exe" launch-gui        
        Write-Host "Done" -ForegroundColor Cyan
    } #End of step4LaunchGUI

    function TryFail {
        Write-Host "Datadog service is not running. Attempting to start Datadog service."             
        & "$env:ProgramFiles\Datadog\Datadog Agent\bin\agent.exe" "start-service"  
        Start-Sleep -Seconds 60    
    } #End of TryFail
    
    function CatchFail {
        Write-Host "Datadog service cannot be started. Exiting in 10 seconds"    
        Start-Sleep -Seconds 10       
        exit
    } #End of CatchFail

    if ($datadogsvc.Status -eq "Running") {

        step2CopyFiles

    } elseif (($datadogsvc.Status -eq "StartPending") -or ($datadogsvc.Status -eq "Starting")) {

        Start-Sleep -Seconds 60
        
        step2CopyFiles

    } elseif (($datadogsvc.Status -eq "Stopped") -or ($datadogsvc.Status -eq "Disabled")) {

        Try {
            
            TryFail

            step2CopyFiles
        
        } Catch {
            
            CatchFail
        
        }

    }

    if ($datadogsvc.Status -eq "Running") {

        step3RestartDDSVC

    } elseif (($datadogsvc.Status -eq "StartPending") -or ($datadogsvc.Status -eq "Starting")) {

        Start-Sleep -Seconds 60
        
        step3RestartDDSVC   

    } elseif (($datadogsvc.Status -eq "Stopped") -or ($datadogsvc.Status -eq "Disabled")) {

        Try {
            
            TryFail

            step3RestartDDSVC
        
        } Catch {
            
            CatchFail

        }

    }

    if ($datadogsvc.Status -eq "Running") {

        step4LaunchGUI

    } elseif (($datadogsvc.Status -eq "StartPending") -or ($datadogsvc.Status -eq "Starting")) {

        Start-Sleep -Seconds 60
        
        step4LaunchGUI

    } elseif (($datadogsvc.Status -eq "Stopped") -or ($datadogsvc.Status -eq "Disabled")) {

        Try {
            
            TryFail

            step4LaunchGUI
        
        } Catch {
            
            CatchFail

        }

    }
    
} #End of Install-DataDogAgent

Install-DataDogAgent #<--- Parent script
Sleep 5
.\New-DatadogDashboard.ps1 #<--- Child script
Sleep 5
.\New-DatadogSharedDashboard.ps1 #<--- Child script
