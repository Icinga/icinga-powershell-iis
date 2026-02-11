# Icinga PowerShell IIS CHANGELOG

**The latest release announcements are available on [https://icinga.com/blog/](https://icinga.com/blog/).**

Please read the [upgrading](https://icinga.com/docs/windows/latest/iis/doc/30-Upgrading-Plugins)
documentation before upgrading to a new release.

Released closed milestones can be found on [GitHub](https://github.com/Icinga/icinga-powershell-iis/milestones?state=closed).

## 1.1.0 (2026-02-11)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-iis/milestone/2)

### Bugfixes

* [#3](https://github.com/Icinga/icinga-powershell-iis/pull/3) Fixes detection if IIS installed by using `W3SVC` as service name instead
* [#5](https://github.com/Icinga/icinga-powershell-iis/pull/5) Fixes the App Pool health check by removing the WMI dependency for `root/Webadministrator` to ensure IIS-Tools are not required

## 1.0.0 (2025-01-31)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-iis/milestone/1)

### Enhancements

* Adds new plugin `Invoke-IcingaCheckIISAppPoolHealth` to check IIS App-Pools
* Adds new plugin `Invoke-IcingaCheckIISHealth` to check for the installation of IIS and the current health
