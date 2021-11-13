[![Build Status](https://dev.azure.com/sgovoni/sqlcmdcli/_apis/build/status/Build-sqlcmdcli?branchName=master)](https://dev.azure.com/sgovoni/sqlcmdcli/_build/latest?definitionId=4&branchName=master)

# sqlcmdcli

sqlcmdcli utility is a command-line utility for ad hoc, interactive execution of commands on SQL Server to simulate specific workloads, anonymize sensitive data and much more.

sqlcmdcli is written in Delphi RAD Studio and lets you connect to a [SQL Server](https://docs.microsoft.com/en-us/sql/sql-server/?WT.mc_id=DP-MVP-4029181) instance and run specific commands. It was born in July of 2021 during a case study on queries regression in production environments using [SQL Server Query Store](https://docs.microsoft.com/en-us/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store?WT.mc_id=DP-MVP-4029181).

### Installation

sqlcmdcli uses [VSoft.CommandLineParser](https://github.com/VSoftTechnologies/VSoft.CommandLineParser) by VSoftTechnologies, the Simple Command Line Options Parser spawned from the DUnitX Project.

The utility uses both ADO and FireDAC queries to execute Transact-SQL batches.

### Available commands

The commands and related documentation are described in the [sqlcmdcli wiki](https://github.com/segovoni/sqlcmdcli/wiki).
