# Azure Blob Storage API

Open Source App to reproduce the [Azure Blob Storage REST API](https://docs.microsoft.com/en-us/rest/api/storageservices/blob-service-rest-api) in AL for Microsoft Dynamics 365 Business Central.

## Description

This App reproduces the [Azure Blob Storage REST API](https://docs.microsoft.com/en-us/rest/api/storageservices/blob-service-rest-api) in AL for Microsoft Dynamics 365 Business Central. It comes with some basic UI-functionality, but of course you don't need to use these. Besides the `"AZBSA Blob Storage Connection"` table all others are temporary.

Contributions are welcome. Feel free to create a Pull Request. The current version might still be subject to refactoring, depending on requirements when adding new features.

You should really check out the [wiki](https://github.com/cosmoconsult/D365BC-Blob-Storage-API/wiki). Besides others, there you'll find information to:
* [API Coverage Status](https://github.com/cosmoconsult/D365BC-Blob-Storage-API/wiki/API-Coverage-Status) (![69%](https://progress-bar.dev/69) (29 out of 42))
* [Authorization Methods](https://github.com/cosmoconsult/D365BC-Blob-Storage-API/wiki/Authorization-Methods)
* [Examples](https://github.com/cosmoconsult/D365BC-Blob-Storage-API/wiki/Examples-Overview)

There you'll also find out how to use optional [URI Parameters](https://github.com/cosmoconsult/D365BC-Blob-Storage-API/wiki/Optional-URI-Parameters) and [Request Headers](https://github.com/cosmoconsult/D365BC-Blob-Storage-API/wiki/Optional-Request-Headers)

**Please note**: This is a work in progress. I can't guarantee full functionality or no errors. Please report any problems you encounter.

## To-Do List

These topics are currently on the to-do list:
- ~~Create first API draft~~
- ~~Create "**Request Test**"-page (draft)~~
- ~~Add handling for optional **URI Parameters** (draft)~~
- ~~Add handling for optional **Request Headers** (draft)~~
- Make "**Request Test**"-page more robust
- Extend handling for optional **URI parameters**
   - Validate DateTime-format
- Extend handling for optional **Request Headers**
- Add support/restrictions for different API Versions
- Add events for external extensibility
- Reproduce further API functions
- Create better documentation (Wiki?) (Started)
- Add Tooltipps / Rework UI
- Add Helper for ACL definitions
- Add Helper for Service Properties