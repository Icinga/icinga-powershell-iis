# Invoke-IcingaCheckIISHealth

## Description

Checks the installation status of the IIS feature and the status of the IIS service.

This function checks the installation status of the IIS feature and the status of the IIS service.
If the IIS feature is not installed, the function will return 'UNKNOWN'.
If the IIS service is not running, the function will return 'CRITICAL'.
Otherwise, the function will return 'OK'.
The function will also return performance data about the IIS service.

## Permissions

To execute this plugin you will require to grant the following user permissions.

### WMI Permissions

* Root\WebAdministration
* Win32_PerfFormattedData_PerfProc_Process

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed:<br /> 0 (default): Only service checks/packages with state not OK will be printed<br /> 1: Only services with not OK will be printed including OK checks of affected check packages including Package config<br /> 2: Everything will be printed regardless of the check state<br /> 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckIISHealth
```

### Example Output 1

```powershell
[UNKNOWN] IIS Health [UNKNOWN] IIS Service
\_ [UNKNOWN] IIS Service: The IIS feature is not installed    
```

### Example Command 2

```powershell
Invoke-IcingaCheckIISHealth
```

### Example Output 2

```powershell
[OK] IIS Health
| 'icingaiisdemo::ifw_iishealth::iishealth'=4;;4    
```

### Example Command 3

```powershell
Invoke-IcingaCheckIISHealth
```

### Example Output 3

```powershell
[CRITICAL] IIS Health: 1 Critical [CRITICAL] IIS Service (Stopped)
\_ [CRITICAL] IIS Service: Stopped is not matching threshold Running
| 'icingaiisdemo::ifw_iishealth::iishealth'=1;;4    
```


