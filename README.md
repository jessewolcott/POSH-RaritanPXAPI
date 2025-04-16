# POSH-RaritanPXAPI

This module aims to close the gap between Raritan's useless documentation and their complete ignorance of Powershell. 

The source for this module is pain, suffering and [this awful website](https://help.raritan.com/json-rpc/pdu/v3.4.0/index.html).

## What we need to do

We need to take the [list of "Well-Known-URIs"](https://help.raritan.com/json-rpc/pdu/v3.4.0/Well-Known-URIs.txt) and make something vaguely usable. We should also really log and handle credentials in a not-plain-text way, I guess.

## Build 
| Feature | Status | Priority |
| --- | --- | --- | 
|Get-RPXModel         | ![Planned](https://img.shields.io/badge/status-IN%20PROGRESS-green) | ![HIGH](https://img.shields.io/badge/HIGH-ff0000) |
|Get-RPXOutletCount   | ![Planned](https://img.shields.io/badge/status-planned-blue) | ![HIGH](https://img.shields.io/badge/HIGH-ff0000) |
|Get-RPXOutletStatus  | ![Planned](https://img.shields.io/badge/status-planned-blue) | ![HIGH](https://img.shields.io/badge/HIGH-ff0000) |