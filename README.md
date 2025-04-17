# POSH-RaritanPXAPI

This module aims to close the gap between Raritan's useless documentation and their complete ignorance of Powershell. 

The source for this module is pain, suffering and [this awful website](https://help.raritan.com/json-rpc/pdu/v3.4.0/index.html).

## What we need to do

We need to take the [list of "Well-Known-URIs"](https://help.raritan.com/json-rpc/pdu/v3.4.0/Well-Known-URIs.txt) and make something vaguely usable. We should also really log and handle credentials in a not-plain-text way, I guess.

## Build Trajectory
| Feature | Status | Priority | Notes |
| --- | --- | --- | --- |
| Enable-RPXAPILogging | ![In Testing](https://img.shields.io/badge/status-Testing-violet) | ![HIGH](https://img.shields.io/badge/HIGH-ff0000) | Enable logging to /Logs |
| Disable-RPXAPILogging | ![In Testing](https://img.shields.io/badge/status-Testing-violet) | ![HIGH](https://img.shields.io/badge/HIGH-ff0000) | Disable logging to /Logs |
| Write-RPXAPILog | ![In Testing](https://img.shields.io/badge/status-Testing-violet) | ![HIGH](https://img.shields.io/badge/HIGH-ff0000) | Write to the file in /Logs |
| Get-RPXAPILogPath | ![In Testing](https://img.shields.io/badge/status-Testing-violet) | ![HIGH](https://img.shields.io/badge/HIGH-ff0000) | Verify /Logs path|
| Set-RPXAPICredential | ![In Testing](https://img.shields.io/badge/status-Testing-violet) | ![HIGH](https://img.shields.io/badge/HIGH-ff0000) | Create a credential |
| Get-RPXAPICredential | ![In Testing](https://img.shields.io/badge/status-Testing-violet) | ![HIGH](https://img.shields.io/badge/HIGH-ff0000) | Retrieve a credential for piped / later use|
| Remove-RPXAPICredential | ![In Testing](https://img.shields.io/badge/status-Testing-violet) | ![HIGH](https://img.shields.io/badge/HIGH-ff0000) | Remove a stored credential |
| Get-RPXAPICredentialList | ![In Testing](https://img.shields.io/badge/status-Testing-violet) | ![HIGH](https://img.shields.io/badge/HIGH-ff0000) | Retrieve a list of available credentials|
| Get-RPXAPIToken | ![In Testing](https://img.shields.io/badge/status-Testing-violet) | ![HIGH](https://img.shields.io/badge/HIGH-ff0000) | REST to get an auth token for piped / later use |
| Test-RPXAPIToken | ![In Testing](https://img.shields.io/badge/status-Testing-violet) | ![HIGH](https://img.shields.io/badge/HIGH-ff0000) | Test connection to device|
|Get-RPXModel         | ![In Progress](https://img.shields.io/badge/status-IN%20PROGRESS-green) | ![HIGH](https://img.shields.io/badge/HIGH-ff0000) | |
|Get-RPXOutletCount   | ![Planned](https://img.shields.io/badge/status-planned-blue) | ![HIGH](https://img.shields.io/badge/HIGH-ff0000) | | 
|Get-RPXOutletStatus  | ![Planned](https://img.shields.io/badge/status-planned-blue) | ![HIGH](https://img.shields.io/badge/HIGH-ff0000) | |

## Functionality and Usage
