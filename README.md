# sqlcmdcli

sqlcmdcli utility is a command-line utility for ad hoc, interactive execution of commands to

* Simulate specific workloads
* Anonymize production databases
* ...and much more.

sqlcmdcli is written in Delphi RAD Studio and lets you connect to a SQL Server instance and run specific command. It was born in July of 2021 during a case study on queries regression in production environments.

sqlcmdcli uses [VSoft.CommandLineParser](https://github.com/VSoftTechnologies/VSoft.CommandLineParser) by VSoftTechnologies, the Simple Command Line Options Parser spawned from the DUnitX Project.

The utility uses both ADO and FireDAC queries to execute Transact-SQL batches.
