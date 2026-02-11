# Invoke-IcingaCheckIISAppPoolHealth

## Description

This plugin will check the health and resource usage of IIS Application Pools.

This function checks the health of IIS Application Pools by evaluating their status, CPU usage, memory usage, and worker process status.
It generates a check package with detailed information and performance data for each application pool.

## Permissions

To execute this plugin you will require to grant the following user permissions.

### WMI Permissions

* Win32_PerfFormattedData_PerfProc_Process

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| CPUWarning | Object | false |  | The CPU usage percentage that triggers a warning state. |
| CPUCritical | Object | false |  | The CPU usage percentage that triggers a critical state. |
| MemoryWarning | Object | false |  | The memory usage that triggers a warning state. Supports the % to compare the current<br /> memory usage against a configured limit of the AppPool. |
| MemoryCritical | Object | false |  | The memory usage that triggers a critical state. Supports the % to compare the current<br /> memory usage against a configured limit of the AppPool. |
| ThreadCountWarning | Object | false |  | The thread count that triggers a warning state for the AppPools |
| ThreadCountCritical | Object | false |  | The thread count that triggers a critical state for the AppPools |
| PageFileWarning | Object | false |  | The page file usage that triggers a warning state for the AppPools |
| PageFileCritical | Object | false |  | The page file usage that triggers a critical state for the AppPools |
| IncludeAppPools | Array | false | @() | An array of application pool names to include in the check. |
| ExcludeAppPools | Array | false | @() | An array of application pool names to exclude from the check. |
| OverrideNoWorker | String | false | Critical | The state to set if no worker process is found for an application pool. Valid values are 'Ok', 'Warning', 'Critical', 'Unknown'. Default is 'Critical'. |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed:<br /> 0 (default): Only service checks/packages with state not OK will be printed<br /> 1: Only services with not OK will be printed including OK checks of affected check packages including Package config<br /> 2: Everything will be printed regardless of the check state<br /> 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckIISAppPoolHealth -MemoryWarning '25MiB';
```

### Example Output 1

```powershell
[CRITICAL] IIS AppPools: 2 Critical 1 Warning [CRITICAL] .NET v4.5, .NET v4.5 Classic [WARNING] DefaultAppPool
\_ [CRITICAL] .NET v4.5
    \_ [CRITICAL] WorkerProcess: No worker process found for this AppPool
\_ [CRITICAL] .NET v4.5 Classic
    \_ [CRITICAL] WorkerProcess: No worker process found for this AppPool
\_ [WARNING] DefaultAppPool
    \_ [WARNING] Memory: 35.46MiB is greater than threshold 25MiB
| 'defaultapppool::ifw_iisapppoolhealth::apppoolprocess'=4308;; 'defaultapppool::ifw_iisapppoolhealth::apppoolmemory'=37179390B;26214400;;0;0 'defaultapppool::ifw_iisapppoolhealth::apppoolcpu'=0%;;;0;100 'netv45classic::ifw_iisapppoolhealth::apppoolcpu'=0%;;;0;100 'netv45classic::ifw_iisapppoolhealth::apppoolmemory'=0B;26214400;;0;0 'netv45::ifw_iisapppoolhealth::apppoolcpu'=0%;;;0;100 'netv45::ifw_iisapppoolhealth::apppoolmemory'=0B;26214400;;0;0    
```

### Example Command 2

```powershell
Invoke-IcingaCheckIISAppPoolHealth  -MemoryWarning '25MiB' -IncludeAppPool '*Default*';
```

### Example Output 2

```powershell
[WARNING] IIS AppPools: 1 Warning [WARNING] DefaultAppPool
\_ [WARNING] DefaultAppPool
    \_ [WARNING] Memory: 35.44MiB is greater than threshold 25MiB
| 'defaultapppool::ifw_iisapppoolhealth::apppoolcpu'=0%;;;0;100 'defaultapppool::ifw_iisapppoolhealth::apppoolprocess'=4308;; 'defaultapppool::ifw_iisapppoolhealth::apppoolmemory'=37163010B;26214400;;0;0    
```

### Example Command 3

```powershell
Invoke-IcingaCheckIISAppPoolHealth  -verbosity 3 -OverrideNoWorker 'Warning' -MemoryWarning '10MiB';
```

### Example Output 3

```powershell
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
```


