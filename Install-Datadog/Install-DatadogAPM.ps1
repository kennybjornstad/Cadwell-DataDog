if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) 
{ 
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

Set-Location -Path $PSScriptRoot

[string] $global:clss = "CadLink Server Service"

function Set-APMRegistryValues {
    #[string] $DatadogVersion = Get-Package -Name "Datadog Agent" | Select-Object -ExpandProperty Version
    [string] $DatadogVersion = "7.36.1"
    [string[]] $global:Environmentvalues = @(
        "COR_ENABLE_PROFILING=1",
        "COR_PROFILER={846F5F1C-F9AE-4B07-969E-05C26BC060D8}"
        "DD_VERSION=$DatadogVersion"
    )
    
    Set-ItemProperty "HKLM:SYSTEM\CurrentControlSet\Services\$clss" -Name Environment -Value $Environmentvalues
    
    Restart-Service -Name 'CadLink Server Service'
}

function Get-APMRegistryValues {
    $DatadogAPM = Get-ItemProperty "HKLM:SYSTEM\CurrentControlSet\Services\$clss" | Select-Object -ExpandProperty Environment
    if (($DatadogAPM[0] -eq "COR_ENABLE_PROFILING=1") -and ($DatadogAPM[1] -eq "COR_PROFILER={846F5F1C-F9AE-4B07-969E-05C26BC060D8}")) {
            Write-Host "APM registry values correct" -ForegroundColor Green
        } else {
            Write-Host "APM registry values not correct, or access denied" -ForegroundColor Red
    }
}

function Remove-APMRegistryValues {
    Remove-ItemProperty "HKLM:SYSTEM\CurrentControlSet\Services\$clss" -Name Environment
    Restart-Service -Name 'CadLink Server Service'
}

function Install-APM {
    $msiexecAPMparams = @(
    '/i',
    'datadog-dotnet-apm.msi'
    '/qn'
    )
    
     Start-Process msiexec -Wait -ArgumentList $msiexecAPMparams

}

<#
Optional Environment Values. Not used at this time.
"DD_LOGS_INJECTION=true", # https://docs.datadoghq.com/tracing/connect_logs_and_traces/
"DD_TRACE_SAMPLE_RATE=1", # https://docs.datadoghq.com/tracing/trace_ingestion/mechanisms/
"DD_RUNTIME_METRICS_ENABLED=true", # https://docs.datadoghq.com/tracing/runtime_metrics/
"DD_PROFILING_ENABLED=true", # https://docs.datadoghq.com/tracing/profiler/enabling/dotnet
"DD_APPSEC_ENABLED=true" # Start detecting threats truly impacting your production systems
#>

Set-APMRegistryValues
Get-APMRegistryValues
Install-APM