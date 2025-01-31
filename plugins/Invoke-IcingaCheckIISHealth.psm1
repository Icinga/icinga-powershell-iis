<#
.SYNOPSIS
    Checks the installation status of the IIS feature and the status of the IIS service.
.DESCRIPTION
    This function checks the installation status of the IIS feature and the status of the IIS service.
    If the IIS feature is not installed, the function will return 'UNKNOWN'.
    If the IIS service is not running, the function will return 'CRITICAL'.
    Otherwise, the function will return 'OK'.
    The function will also return performance data about the IIS service.
.FUNCTIONALITY
    This plugin will check the IIS service status.
.ROLE
    ### WMI Permissions

    * Root\WebAdministration
    * Win32_PerfFormattedData_PerfProc_Process
.EXAMPLE
    PS> Invoke-IcingaCheckIISHealth

    [UNKNOWN] IIS Health [UNKNOWN] IIS Service
    \_ [UNKNOWN] IIS Service: The IIS feature is not installed
.EXAMPLE
    PS> Invoke-IcingaCheckIISHealth

    [OK] IIS Health
    | 'icingaiisdemo::ifw_iishealth::iishealth'=4;;4
.EXAMPLE
    PS> Invoke-IcingaCheckIISHealth

    [CRITICAL] IIS Health: 1 Critical [CRITICAL] IIS Service (Stopped)
    \_ [CRITICAL] IIS Service: Stopped is not matching threshold Running
    | 'icingaiisdemo::ifw_iishealth::iishealth'=1;;4
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.INPUTS
    System.Array
.OUTPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-iis
.NOTES
#>

function Invoke-IcingaCheckIISHealth()
{
    param (
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity     = 0,
        [switch]$NoPerfData = $FALSE
    );

    $IISData         = New-IcingaProviderFilterDataIIS;
    $IISCheckPackage = New-IcingaCheckPackage -Name 'IIS Health' -OperatorAnd -Verbose $Verbosity -AddSummaryHeader;

    $IISStatus = New-IcingaCheck `
        -Name 'IIS Service' `
        -Value $ProviderEnums.ServiceStatus.([string]$IISData.Metrics.IISStatus) `
        -Translation $ProviderEnums.ServiceStatusName `
        -MetricIndex $IISData.Metadata.IISHost `
        -MetricName 'iishealth';

    if ($IISData.FeatureInstalled -eq $FALSE) {
        $IISStatus.SetUnknown($IISData.IISErrors, $TRUE) | Out-Null;
    } else {
        $IISStatus.CritIfNotMatch($ProviderEnums.ServiceStatus.Running) | Out-Null;
    }

    $IISCheckPackage.AddCheck($IISStatus) | Out-Null;

    return (New-IcingaCheckResult -Check $IISCheckPackage -NoPerfData $NoPerfData -Compile);
}
