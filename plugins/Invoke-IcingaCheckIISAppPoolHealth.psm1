<#
.SYNOPSIS
    This plugin will check the health and resource usage of IIS Application Pools.
.DESCRIPTION
    This function checks the health of IIS Application Pools by evaluating their status, CPU usage, memory usage, and worker process status.
    It generates a check package with detailed information and performance data for each application pool.
.ROLE
    ### WMI Permissions

    * Root\WebAdministration
    * Win32_PerfFormattedData_PerfProc_Process
.PARAMETER CPUWarning
    The CPU usage percentage that triggers a warning state.
.PARAMETER CPUCritical
    The CPU usage percentage that triggers a critical state.
.PARAMETER MemoryWarning
    The memory usage that triggers a warning state. Supports the % to compare the current
    memory usage against a configured limit of the AppPool.
.PARAMETER MemoryCritical
    The memory usage that triggers a critical state. Supports the % to compare the current
    memory usage against a configured limit of the AppPool.
.PARAMETER ThreadCountWarning
    The thread count that triggers a warning state for the AppPools
.PARAMETER ThreadCountCritical
    The thread count that triggers a critical state for the AppPools
.PARAMETER PageFileWarning
    The page file usage that triggers a warning state for the AppPools
.PARAMETER PageFileCritical
    The page file usage that triggers a critical state for the AppPools
.PARAMETER IncludeAppPools
    An array of application pool names to include in the check.
.PARAMETER ExcludeAppPools
    An array of application pool names to exclude from the check.
.PARAMETER OverrideNoWorker
    The state to set if no worker process is found for an application pool. Valid values are 'Ok', 'Warning', 'Critical', 'Unknown'. Default is 'Critical'.
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.EXAMPLE
    PS> Invoke-IcingaCheckIISAppPoolHealth -MemoryWarning '25MiB';

    [CRITICAL] IIS AppPools: 2 Critical 1 Warning [CRITICAL] .NET v4.5, .NET v4.5 Classic [WARNING] DefaultAppPool
    \_ [CRITICAL] .NET v4.5
        \_ [CRITICAL] WorkerProcess: No worker process found for this AppPool
    \_ [CRITICAL] .NET v4.5 Classic
        \_ [CRITICAL] WorkerProcess: No worker process found for this AppPool
    \_ [WARNING] DefaultAppPool
        \_ [WARNING] Memory: 35.46MiB is greater than threshold 25MiB
    | 'defaultapppool::ifw_iisapppoolhealth::apppoolprocess'=4308;; 'defaultapppool::ifw_iisapppoolhealth::apppoolmemory'=37179390B;26214400;;0;0 'defaultapppool::ifw_iisapppoolhealth::apppoolcpu'=0%;;;0;100 'netv45classic::ifw_iisapppoolhealth::apppoolcpu'=0%;;;0;100 'netv45classic::ifw_iisapppoolhealth::apppoolmemory'=0B;26214400;;0;0 'netv45::ifw_iisapppoolhealth::apppoolcpu'=0%;;;0;100 'netv45::ifw_iisapppoolhealth::apppoolmemory'=0B;26214400;;0;0
.EXAMPLE
    PS> Invoke-IcingaCheckIISAppPoolHealth  -MemoryWarning '25MiB' -IncludeAppPool '*Default*';

    [WARNING] IIS AppPools: 1 Warning [WARNING] DefaultAppPool
    \_ [WARNING] DefaultAppPool
        \_ [WARNING] Memory: 35.44MiB is greater than threshold 25MiB
    | 'defaultapppool::ifw_iisapppoolhealth::apppoolcpu'=0%;;;0;100 'defaultapppool::ifw_iisapppoolhealth::apppoolprocess'=4308;; 'defaultapppool::ifw_iisapppoolhealth::apppoolmemory'=37163010B;26214400;;0;0
.EXAMPLE
    PS> Invoke-IcingaCheckIISAppPoolHealth  -verbosity 3 -OverrideNoWorker 'Warning' -MemoryWarning '10MiB';

    [WARNING] IIS AppPools: 3 Warning [WARNING] .NET v4.5, .NET v4.5 Classic, DefaultAppPool (All must be [OK])
    \_ [WARNING] .NET v4.5 (All must be [OK])
        \_ [OK] CPU: 0%
        \_ [OK] Health: Started
        \_ [OK] Memory: 0B
        \_ [WARNING] WorkerProcess: No worker process found for this AppPool
    \_ [WARNING] .NET v4.5 Classic (All must be [OK])
        \_ [OK] CPU: 0%
        \_ [OK] Health: Started
        \_ [OK] Memory: 0B
        \_ [WARNING] WorkerProcess: No worker process found for this AppPool
    \_ [WARNING] DefaultAppPool (All must be [OK])
        \_ [OK] CPU: 0%
        \_ [OK] Health: Started
        \_ [WARNING] Memory: 35.48MiB is greater than threshold 10MiB
        \_ [OK] WorkerProcess: 4308
    | 'defaultapppool::ifw_iisapppoolhealth::apppoolprocess'=4308;; 'defaultapppool::ifw_iisapppoolhealth::apppoolmemory'=37203970B;10485760;;0 'defaultapppool::ifw_iisapppoolhealth::apppoolcpu'=0%;;;0;100 'netv45classic::ifw_iisapppoolhealth::apppoolcpu'=0%;;;0;100 'netv45classic::ifw_iisapppoolhealth::apppoolmemory'=0B;10485760;;0 'netv45::ifw_iisapppoolhealth::apppoolcpu'=0%;;;0;100 'netv45::ifw_iisapppoolhealth::apppoolmemory'=0B;10485760;;0
.NOTES
    This function requires the Icinga PowerShell Framework and the Icinga PowerShell IIS module.

#>

function Invoke-IcingaCheckIISAppPoolHealth()
{
    param (
        $CPUWarning               = '',
        $CPUCritical              = '',
        $MemoryWarning            = '',
        $MemoryCritical           = '',
        $ThreadCountWarning       = '',
        $ThreadCountCritical      = '',
        $PageFileWarning          = '',
        $PageFileCritical         = '',
        [array]$IncludeAppPools   = @(),
        [array]$ExcludeAppPools   = @(),
        [ValidateSet('Ok', 'Warning', 'Critical', 'Unknown')]
        [string]$OverrideNoWorker = 'Critical',
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity           = 0,
        [switch]$NoPerfData       = $FALSE
    );

    $IISData         = New-IcingaProviderFilterDataIIS -IncludeFilter $IncludeAppPools -ExcludeFilter $ExcludeAppPools;
    $IISCheckPackage = New-IcingaCheckPackage -Name 'IIS AppPools' -OperatorAnd -Verbose $Verbosity -AddSummaryHeader -IgnoreEmptyPackage;

    if ($IISData.FeatureInstalled) {
        foreach ($apppool in (Get-IcingaProviderElement $IISData.Metrics.AppPools)) {
            [string]$AppPoolName = $apppool.Name;

            $IISAppPoolPackage = New-IcingaCheckPackage -Name $AppPoolName -OperatorAnd -Verbose $Verbosity;

            $IISAppPoolStatus = New-IcingaCheck `
                -Name 'Health' `
                -Value $apppool.Value.Status `
                -MetricIndex $AppPoolName `
                -MetricName 'apppoolhealth' `
                -NoPerfData;

            $IISAppPoolStatus.CritIfNotMatch('Started') | Out-Null;

            $IISWorkerProcess = New-IcingaCheck `
                -Name 'WorkerProcess' `
                -Value $apppool.Value.ProcessId `
                -MetricIndex $AppPoolName `
                -MetricName 'apppoolprocess';

            if ($apppool.Value.ProcessId -eq -1) {
                switch ($OverrideNoWorker.ToLower()) {
                    'ok' {
                        $IISWorkerProcess.SetOk('No worker process found for this AppPool', $TRUE) | Out-Null;
                        break;
                    };
                    'warning' {
                        $IISWorkerProcess.SetWarning('No worker process found for this AppPool', $TRUE) | Out-Null;
                        break;
                    };
                    'critical' {
                        $IISWorkerProcess.SetCritical('No worker process found for this AppPool', $TRUE) | Out-Null;
                        break;
                    };
                    default {
                        $IISWorkerProcess.SetUnknown('No worker process found for this AppPool', $TRUE) | Out-Null;
                        break;
                    };
                }
            }

            $IISAppPoolCPU = New-IcingaCheck `
                -Name 'CPU' `
                -Value $apppool.Value.CPUUsage `
                -Unit '%' `
                -MetricIndex $AppPoolName `
                -MetricName 'apppoolcpu';

            $IISAppPoolCPU.WarnOutOfRange($CPUWarning).CritOutOfRange($CPUCritical) | Out-Null;

            $IISAppPoolMemory = New-IcingaCheck `
                -Name 'Memory' `
                -Value $apppool.Value.MemoryUsage `
                -BaseValue $apppool.Value.MemoryLimit `
                -Unit 'B' `
                -MetricIndex $AppPoolName `
                -MetricName 'apppoolmemory' `
                -Minimum 0 `
                -Maximum $apppool.Value.MemoryLimit;

            $IISAppPoolMemory.WarnOutOfRange($MemoryWarning).CritOutOfRange($MemoryCritical) | Out-Null;

            $IISAppPoolThreads = New-IcingaCheck `
                -Name 'Threads' `
                -Value $apppool.Value.ThreadCount `
                -Unit 'c' `
                -MetricIndex $AppPoolName `
                -MetricName 'apppoolthreads';

            $IISAppPoolThreads.WarnOutOfRange($ThreadCountWarning).CritOutOfRange($ThreadCountCritical) | Out-Null;

            $IISAppPoolPageFile = New-IcingaCheck `
                -Name 'Page File' `
                -Value $apppool.Value.PageFileUsage `
                -Unit 'B' `
                -MetricIndex $AppPoolName `
                -MetricName 'apppoolpagefile';

            $IISAppPoolPageFile.WarnOutOfRange($PageFileWarning).CritOutOfRange($PageFileCritical) | Out-Null;

            $IISAppPoolPackage.AddCheck($IISAppPoolStatus);
            $IISAppPoolPackage.AddCheck($IISWorkerProcess);
            $IISAppPoolPackage.AddCheck($IISAppPoolCPU);
            $IISAppPoolPackage.AddCheck($IISAppPoolMemory);
            $IISAppPoolPackage.AddCheck($IISAppPoolThreads);
            $IISAppPoolPackage.AddCheck($IISAppPoolPageFile);

            $IISCheckPackage.AddCheck($IISAppPoolPackage);
        }
    }

    return (New-IcingaCheckResult -Check $IISCheckPackage -NoPerfData $NoPerfData -Compile);
}
