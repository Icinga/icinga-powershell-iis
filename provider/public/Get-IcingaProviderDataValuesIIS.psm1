function Get-IcingaProviderDataValuesIIS()
{
    param (
        [array]$IncludeFilter      = @(),
        [array]$ExcludeFilter      = @(),
        [hashtable]$ProviderFilter = @{ },
        [switch]$IncludeDetails    = $FALSE
    );

    $IISData                 = New-IcingaProviderObject -Name 'IIS';
    [hashtable]$FilterObject = Get-IcingaProviderFilterData -ProviderName 'IIS' -ProviderFilter $ProviderFilter;

    $IISData.Metrics         = $FilterObject.IIS.Query.Metrics;
    $IISData.MetricsOverTime = $FilterObject.IIS.Query.MetricsOverTime;
    $IISData.Metadata        = $FilterObject.IIS.Query.Metadata;

    $FilterObject = $null;

    return $IISData;
}
