# sqlcmdcli

sqlcmdcli utility is a command-line utility for ad hoc, interactive execution of commands to

* Simulate specific workloads
* Anonymize sensitive data 
* ...and much more.

sqlcmdcli is written in Delphi RAD Studio and lets you connect to a [SQL Server](https://docs.microsoft.com/en-us/sql/sql-server/?WT.mc_id=DP-MVP-4029181) instance and run specific commands. It was born in July of 2021 during a case study on queries regression in production environments using [SQL Server Query Store](https://docs.microsoft.com/en-us/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store?WT.mc_id=DP-MVP-4029181).

sqlcmdcli uses [VSoft.CommandLineParser](https://github.com/VSoftTechnologies/VSoft.CommandLineParser) by VSoftTechnologies, the Simple Command Line Options Parser spawned from the DUnitX Project.

The utility uses both ADO and FireDAC queries to execute Transact-SQL batches.
