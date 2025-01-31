@{
    ModuleVersion     = '1.0.0'
    GUID              = '8499369e-d98b-414e-93fd-ef771a545993'
    Author            = 'Lord Hepipud'
    CompanyName       = 'Icinga GmbH'
    Copyright         = '(c) 2025 Icinga GmbH | GPLv2'
    Description       = 'Icinga for Windows plugin collection for monitoring Microsoft IIS'
    PowerShellVersion = '4.0'
    RequiredModules   = @(
        @{ ModuleName = 'icinga-powershell-framework'; ModuleVersion = '1.12.0'; },
        @{ ModuleName = 'icinga-powershell-plugins'; ModuleVersion = '1.12.0'; }
    )
    NestedModules     = @(
        '.\compiled\icinga-powershell-iis.ifw_compilation.psm1'
    )
    FunctionsToExport     = @(
        'Import-IcingaPowerShellComponentIis',
        'Invoke-IcingaCheckIISHealth',
        'Invoke-IcingaCheckIISAppPoolHealth',
        'New-IcingaProviderFilterDataIIS',
        'Get-IcingaProviderDataValuesIIS'
    )
    CmdletsToExport     = @(
    )
    VariablesToExport     = @(
    )
    AliasesToExport     = @(
    )
    PrivateData       = @{
        PSData   = @{
            Tags         = @( 'icinga', 'icinga2', 'icingawindows', 'iis', 'windowsplugins', 'icingaforwindows' )
            LicenseUri   = 'https://github.com/Icinga/icinga-powershell-iis/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/Icinga/icinga-powershell-iis'
            ReleaseNotes = 'https://github.com/Icinga/icinga-powershell-iis/releases'
        };
        Version  = 'v1.0.0'
        Name     = 'Windows IIS';
        Type     = 'plugins';
        Function = '';
        Endpoint = '';
    }
    HelpInfoURI       = 'https://github.com/Icinga/icinga-powershell-iis'
}

