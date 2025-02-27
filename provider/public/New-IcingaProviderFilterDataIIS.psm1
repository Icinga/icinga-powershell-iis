<#
.ROLE
    Query
#>

function New-IcingaProviderFilterDataIIS()
{
    param (
        [array]$IncludeFilter   = @(),
        [array]$ExcludeFilter   = @(),
        [switch]$IncludeDetails = $FALSE
    );

    $IISData         = New-IcingaProviderObject                 -Name 'IIS';
    $IISService      = Get-Service -Name 'W3SVC'                -ErrorAction SilentlyContinue;
    $IISToolsPresent = Get-Command -Name 'Get-IISConfigSection' -ErrorAction SilentlyContinue;

    $IISData.Metadata | Add-Member -MemberType NoteProperty -Name 'IISHost'   -Value (Get-IcingaHostname);
    $IISData.Metrics  | Add-Member -MemberType NoteProperty -Name 'IISStatus' -Value 'Stopped';
    $IISData          | Add-Member -MemberType NoteProperty -Name 'IISErrors' -Value '';

    # Check if the IIS is installed. If not, we will simply return an empty object
    if ($null -eq $IISService -Or $null -eq $IISToolsPresent) {
        $IISData.FeatureInstalled = $FALSE;

        if ($null -eq $IISService) {
            $IISData.IISErrors = 'The IIS feature is not installed';
        } else {
            $IISData.IISErrors = 'The IIS tools are not installed';
        }

        return $IISData;
    }

    $IISData.Metrics  | Add-Member -MemberType NoteProperty -Name 'AppPools'  -Value (New-Object PSCustomObject);
    $IISData.Metrics.IISStatus = $IISService.Status;

    # Load the config from AppPools
    [array]$AppPools        = Get-IISAppPool;
    $ConfigSection          = Get-IISConfigSection -SectionPath "system.applicationHost/applicationPools";
    $SitesCollection        = Get-IISConfigCollection -ConfigElement $ConfigSection;
    [array]$AppPoolWorkers  = Get-IcingaWindowsInformation -Namespace 'root\WebAdministration' -ClassName 'WorkerProcess' | Select-Object 'AppPoolName', 'ProcessId';
    [array]$AppPoolPerfData = Get-IcingaWindowsInformation 'Win32_PerfFormattedData_PerfProc_Process' | Where-Object { $_.Name -Like '*w3wp*' };
    [array]$AppPoolPageFile = Get-IcingaWindowsInformation 'Win32_Process' | Where-Object { $_.Name -Like '*w3wp*' };

    foreach ($apppool in $AppPools) {
        [string]$AppPoolName = $apppool.Name;

        if ((Test-IcingaArrayFilter -InputObject $AppPoolName -Include $IncludeFilter -Exclude $ExcludeFilter) -eq $FALSE) {
            continue;
        }

        $IISData.Metrics.AppPools              | Add-Member -MemberType NoteProperty -Name $AppPoolName -Value (New-Object PSCustomObject);
        $IISData.Metrics.AppPools.$AppPoolName | Add-Member -MemberType NoteProperty -Name 'Status'     -Value $apppool.State;
        $IISData.Metrics.AppPools.$AppPoolName | Add-Member -MemberType NoteProperty -Name 'StartMode'  -Value $apppool.StartMode;
        $IISData.Metrics.AppPools.$AppPoolName | Add-Member -MemberType NoteProperty -Name 'ProcessId'  -Value -1;

        $Site            = Get-IISConfigCollectionElement -ConfigCollection $SitesCollection -ConfigAttribute @{ 'name' = $AppPoolName };
        $RecyclingData   = Get-IISConfigElement -ConfigElement $Site -ChildElementName "recycling";
        $AttributeData   = Get-IISConfigElement -ConfigElement $RecyclingData -ChildElementName "periodicRestart";

        # Get the actual attributes like private Memory
        $IISData.Metrics.AppPools.$AppPoolName | Add-Member -MemberType NoteProperty -Name 'MemoryLimit'  -Value $AttributeData.RawAttributes.privateMemory;
    }

    foreach ($worker in $AppPoolWorkers) {
        [string]$AppPoolName = $worker.AppPoolName;

        if (Test-PSCustomObjectMember -PSObject $IISData.Metrics.AppPools -Name $AppPoolName) {
            $IISData.Metrics.AppPools.$AppPoolName.ProcessId = $worker.ProcessId;

            foreach ($perfdata in $AppPoolPerfData) {
                if ($perfdata.IDProcess -eq $worker.ProcessId) {
                    $IISData.Metrics.AppPools.$AppPoolName | Add-Member -MemberType NoteProperty -Name 'CPUUsage'    -Value $perfdata.PercentProcessorTime;
                    $IISData.Metrics.AppPools.$AppPoolName | Add-Member -MemberType NoteProperty -Name 'MemoryUsage' -Value $perfdata.WorkingSetPrivate;
                    $IISData.Metrics.AppPools.$AppPoolName | Add-Member -MemberType NoteProperty -Name 'ThreadCount' -Value $perfdata.ThreadCount;
                    break;
                }
            }
            foreach ($perfdata in $AppPoolPageFile) {
                if ($perfdata.ProcessId -eq $worker.ProcessId) {
                    $IISData.Metrics.AppPools.$AppPoolName | Add-Member -MemberType NoteProperty -Name 'PageFileUsage' -Value $perfdata.PageFileUsage;
                    break;
                }
            }
        }
    }

    return $IISData;
}
