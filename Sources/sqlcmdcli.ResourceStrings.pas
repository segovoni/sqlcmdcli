unit sqlcmdcli.ResourceStrings;

interface

resourcestring

  RS_CONNECTION_SUCCESSFULLY = 'Connection to %s establish successfully';
  RS_SETUP_DATABASE_BEGIN = 'Setup database %s in progress...';
  RS_SETUP_DATABASE_CLEAR_QUERY_STORE = 'The contents of the Query Store for %s have been removed';
  RS_SETUP_DATABASE_END = 'Setup database %s completed successfully';
  RS_CMD_VERBOSE_INFO = 'It enables verbose information logging';
  RS_CMD_HELP_DESCRIPTION = 'It displays help about a command';
  RS_CMD_HELP_INFO = 'It displays information about how commands work and what options you can specify';
  RS_CMD_HELP_COMMANDINFO = 'Command for which help is required';

  RS_CMD_SERVERNAME_INFO = 'The name of SQL Server instance you want to connect to';
  RS_CMD_DATABASENAME_INFO = 'The name of the database you want to connect to';
  RS_CMD_USERNAME_INFO = 'Username';
  RS_CMD_PASSWORD_INFO = 'Password';

  RS_CMD_QSWORKLOAD_DESCRIPTION = 'It starts the execution of the workload';
  RS_CMD_QSWORKLOAD_INFO = 'It starts the execution of the workload that can simulate the regression of a sample query';

  RS_CMD_STRESSDB_BEGIN = 'Let''s stress the database...';
  RS_CMD_STRESSDB_END = 'Stress database completed successfully';
  RS_CMD_STRESSDB_DESCRIPTION = 'It performs a stress test on the database';
  RS_CMD_STRESSDB_INFO = 'It runs a data picker query for each table in the database';


  RS_ERROR_COMMAND_UNKNOWN = 'The specified command does not exist: %s';

  RS_STATUS_MSG = #13'Processing %d of %d (%d%%)... ';
  RS_QRY_QUERYSTORE_REGRESSION = 'SELECT * FROM dbo.#Tab_A WHERE (Col1 = %d) AND (Col2 = %d)';

implementation

end.
