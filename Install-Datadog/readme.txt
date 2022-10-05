Required files for agent install:
conf/ files
conf/modules files
datadog-agent.msi
Install-Datadog.ps1
New-DatadogDashboard.ps1
New-DatadogSharedDashboard.ps1

Required files for APM install:
datadog-dotnet-apm.msi
Install-DatadogAPM.ps1

1) Get an API and APP key (from Kenny most likely)
2) Right-click on "Install-Datadog.ps1" and run with PowerShell (script will force to run as admin)

This set of scripts will:
Install Datadog
Create a dashboard
Share the new dashboard and copy the URL to the clipboard

To install/configure APM:
1) Rick-click on "Install-DatadogAPM.ps1" and run with PowerShell (script will force to run as admin
