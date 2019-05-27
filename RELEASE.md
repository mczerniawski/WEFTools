<!-- TOC -->
[#2019-05-27](#2019-05-27)
<!-- TOC -->

# 2019-05-27 - tag 0.2.3

## New features

- Definition name no longer required
    - if not provided will get all available definitions
    - if provided will run only specified definitions
    - uses [Get-WEDefinitionList.ps1](https://github.com/mczerniawski/WEFTools/blob/master/WEFTools/Public/GetDefinitions/Get-WEDefinitionList.ps1) to accomplish this
- Search times aligned with `PSWinReporting`
    - can provide simple names (using ValidateSet tips) instead of creating hashtable
    - if both `$time` and `$cachefile` provided - property from cache wins
    - uses [Set-WESearchTime.ps1](https://github.com/mczerniawski/WEFTools/blob/master/WEFTools/Public/SearchTime/Set-WESearchTime.ps1) to set proper hashtable required by `PSWinReporting - Find-Events`
- Get Cache content
    - initial version of [Get-WECacheData.ps1](https://github.com/mczerniawski/WEFTools/blob/master/WEFTools/Public/Cache/Get-WECacheData.ps1) to easily query current cache results
- New column `EventActionDetails`for definitions and using `Overwrite` feature of PSWinReporting to create simplified `Event Action` for specific events
    - [OSCrash](https://github.com/mczerniawski/WEFTools/blob/dev/WEFTools/Configuration/Definitions/OSCrash.json)
    - [OSStartupShutdownCrash](https://github.com/mczerniawski/WEFTools/blob/dev/WEFTools/Configuration/Definitions/OSStartupShutdownCrash.json)
    - [OSStartupShutdownDetailed](https://github.com/mczerniawski/WEFTools/blob/dev/WEFTools/Configuration/Definitions/OSStartupShutdownDetailed.json)


## Removed

- New-WEScheduleTask function as not yet implemented
- YourDefinitionNameHere as not yet implemented

# 2019-05-23 - tag [0.2.2.1](https://github.com/mczerniawski/WEFTools/releases/tag/0.2.2.1)

## Fixes

- Fixed definition for:
    - [LogClearSecurity](WEFTools/Configuration/Definitions/LogClearSecurity.json)
    - [LogClearSystem](WEFTools/Configuration/Definitions/LogClearSystem.json)

Fixed proper name translation for Find-Events

# 2019-05-16 - tag [0.2.1](https://github.com/mczerniawski/WEFTools/releases/tag/0.2.1)

## New features

- Added proper name translation for Find-Events in definitions:
    - [LogClearSecurity](WEFTools/Configuration/Definitions/LogClearSecurity.json)
    - [LogClearSystem](WEFTools/Configuration/Definitions/LogClearSystem.json)

-

