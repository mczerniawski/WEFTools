# Build Status

[![Build status](https://ci.appveyor.com/api/projects/status/b2pge2fex23sf2yi?svg=true)](https://ci.appveyor.com/project/mczerniawski/weftools)

[![Build status](https://ci.appveyor.com/api/projects/status/b2pge2fex23sf2yi/branch/master?svg=true)](https://ci.appveyor.com/project/mczerniawski/weftools/branch/master)

## What is WEFTools

Tools to manage Palantir WEF and utilize Azure Monitor

Authored by Mateusz Czerniawski

## How to Run

1. Start with [Deploy](docs/Deploy.md) to deploy all components
2. Then [Deploy-AzureLog-Workspace](docs/Deploy-AzureLog-Workspace.md) to prepare Log Analytics Workspace
3. Make sure you've set up proper GPO with [GPO_prepare](docs/GPO_prepare.md)
4. Then Create desired Scheduled task on WEC server as in [Run](docs/Run.md) examples