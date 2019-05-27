# Build Status

|Build Status|Branch|
|---|---|
|[![Build status](https://ci.appveyor.com/api/projects/status/b2pge2fex23sf2yi?svg=true)](https://ci.appveyor.com/project/mczerniawski/weftools)|master|
|[![Build status](https://ci.appveyor.com/api/projects/status/b2pge2fex23sf2yi/branch/master?svg=true)](https://ci.appveyor.com/project/mczerniawski/weftools/branch/dev)|dev|

## What is WEFTools

This module:

1. automates set up of Windows Event Collector service with subscriptions based on Palantir's [Windows-Event-Forwarding](https://github.com/palantir/windows-event-forwarding)
2. allows to send specific events based on [definitions](/WEFTools/Configuration/Definitions)
3. > This module relies on [PSWinReporting](https://github.com/EvotecIT/PSWinReporting) to query EventLogs for specific events.

## HowTo

Make sure your:

- WEC sever is properly [deployed](docs/Deploy.md),
- GPO in AD is [created](docs/GPO_prepare.md),
- Azure Workspace is [prepared](docs/Deploy-AzureLog-Workspace.md)

Then review [examples](docs/Run.md) and choose your style.

Finally set a schedule task on a server of your choice - it can be `WEC server` itself or `any other management server` with access to both Azure subcription and WEC server