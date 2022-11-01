unit sqlcmdcli.ResourceStrings;

interface

resourcestring

  RS_CONNECTION_SUCCESSFULLY = 'Connection to %s establish successfully!';
  RS_SETUP_DATABASE_BEGIN = 'Setup database %s in progress...';
  RS_SETUP_DATABASE_CLEAR_QUERY_STORE = 'The contents of the Query Store for %s have been removed successfully!';
  RS_SETUP_DATABASE_PSP_QUERY_STORE_ENABLED = 'Parameter Sensitive Plan (PSP) Optimization workload enabled!';
  RS_SETUP_DATABASE_END = 'Setup database %s completed successfully!';
  RS_CMD_VERBOSE_INFO = 'It enables verbose information logging';
  RS_CMD_HELP_DESCRIPTION = 'It displays help about a command';
  RS_CMD_HELP_INFO = 'It displays information about how commands work and what ' +
    'options you can specify';
  RS_CMD_HELP_COMMANDINFO = 'Command for which help is required';

  RS_CMD_SERVERNAME_INFO = 'The name of SQL Server instance you want to connect to';
  RS_CMD_DATABASENAME_INFO = 'The name of the database you want to connect to';
  RS_CMD_USERNAME_INFO = 'Username';
  RS_CMD_PASSWORD_INFO = 'Password';

  RS_CMD_QSWORKLOAD_DESCRIPTION = 'It starts the execution of the workload';
  RS_CMD_QSWORKLOAD_INFO = 'It starts the execution of the workload that can ' +
    'simulate the regression of a sample query';
  RS_CMD_QSWORKLOAD_PSPINFO = 'Parameter Sensitive Plan (PSP) Optimization enabled';


  RS_CMD_STRESSDB_BEGIN = 'Let''s stress the database...';
  RS_CMD_STRESSDB_END = 'Stress database completed successfully!';
  RS_CMD_STRESSDB_DESCRIPTION = 'It performs a stress test on the database';
  RS_CMD_STRESSDB_INFO = 'It runs a data picker query for each table in the database';

  RS_CMD_ANONYMIZEDB_BEGIN = 'Let''s anonymize %s database...';
  RS_CMD_ANONYMIZEDB_END = 'Data anonymization of %s database completed successfully!';
  RS_CMD_ANONYMIZEDB_DESCRIPTION = 'It performs the data scramble for text ' +
    'columns. It''s a non-reversible operation!';
  RS_CMD_ANONYMIZEDB_INFO = 'Data anonymization is a type of information ' +
    'sanitization whose intent is privacy protection. It is the process of ' +
    'removing personally identifiable information from data sets, so that the ' +
    'people whom the data describe remain anonymous (source ' +
    'https://en.wikipedia.org/wiki/Data_anonymization)';
  RS_CMD_ANONYMIZEDB_SCHEMANAMEINFO = 'The name of the table schema';
  RS_CMD_ANONYMIZEDB_TABLENAMEINFO = 'The name of the table';
  RS_CMD_ANONYMIZEDB_COLUMNNAMEINFO = 'The name of the column you want to modify';

  RS_CMD_ANONYMIZEDB_DISABLE_FK_START = 'Disable foreign key constraints on %s...';
  RS_CMD_ANONYMIZEDB_DISABLE_FK_END = 'Foreign key constraints disabled successfully!';
  RS_CMD_ANONYMIZEDB_ENABLE_FK_START = 'Enable foreign key constraint on %s...';
  RS_CMD_ANONYMIZEDB_ENABLE_FK_END = 'Foreign key constraints enabled successfully!';

  RS_CMD_ANONYMIZEDB_DISABLE_TR_START = 'Disable triggers on %s...';
  RS_CMD_ANONYMIZEDB_DISABLE_TR_END = 'Triggers disabled successfully!';
  RS_CMD_ANONYMIZEDB_ENABLE_TR_START = 'Enable triggers on %s...';
  RS_CMD_ANONYMIZEDB_ENABLE_TR_END = 'Triggers enabled successfully!';

  RS_CMD_ANONYMIZEDB_DISABLE_CHK_START = 'Disable check constraints on %s...';
  RS_CMD_ANONYMIZEDB_DISABLE_CHK_END = 'Check constraints disabled successfully!';
  RS_CMD_ANONYMIZEDB_ENABLE_CHK_START = 'Enable check constraint on %s...';
  RS_CMD_ANONYMIZEDB_ENABLE_CHK_END = 'Check constraints enabled successfully!';

  RS_CMD_ALTERCOLUMN_BEGIN = 'Let''s alter %s column of the %s table in the %s database...';
  RS_CMD_ALTERCOLUMN_END = 'Column %s has been modified successfully!';
  RS_CMD_ALTERCOLUMN_DESCRIPTION = 'It is able to alter a column with ' +
    'dependencies in your SQL database';
  RS_CMD_ALTERCOLUMN_INFO = 'It is able to compose automatically the appropriate ' +
    'DROP and CREATE commands for each object connected to the column I want to ' +
    'modify. It uses the sp_alter_column stored procedure available here ' +
    'https://github.com/segovoni/sp_alter_column';
  RS_CMD_ALTERCOLUMN_SCHEMANAMEINFO = 'The name of the table schema';
  RS_CMD_ALTERCOLUMN_TABLENAMEINFO = 'The name of the table';
  RS_CMD_ALTERCOLUMN_COLUMNNAMEINFO = 'The name of the column you want to modify';
  RS_CMD_ALTERCOLUMN_COLUMNRENAMEINFO = 'The new name you want to assign to the column';
  RS_CMD_ALTERCOLUMN_DATATYPEINFO = 'The new type you want to assign to the column';

  RS_ERROR_COMMAND_UNKNOWN = 'The specified command does not exist: %s';

  RS_STATUS_PROCESS = #13'Processing %d of %d (%d%%)... ';
  RS_STATUS_PROCESS_TABLE = #13'Processing table %d of %d (%d%%)... ';
  RS_QRY_QUERYSTORE_REGRESSION = 'SELECT * FROM dbo.#Tab_A WHERE (Col1 = %d) AND (Col2 = %d)';

  RS_ERROR_SQL_SERVER_NATIVE_CLIENT = 'SQL Server Native Client %s is not installed! ' +
                                      'Check here to know how to install SQL ' +
                                      'Server Native Client: https://bit.ly/3wFVJXz';
  RS_THANKS_FOR_USING = 'Thanks for using sqlcmdcli https://github.com/segovoni/sqlcmdcli';
  RS_COMMIT_TRANSACTION = 'The transaction has been committed!';
  RS_ROLLBACK_TRANSACTION = 'The transaction has been rejected!';

implementation

end.
