------------------------------------------------------------------------
-- Project:      sqlcmdcli                                             -
--               https://github.com/segovoni/sqlcmdcli                 -
--                                                                     -
-- File:         Obfuscating function sqlcmdcli_fn_string_scrambler    -
-- Author:       Sergio Govoni https://www.linkedin.com/in/sgovoni/    -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [tempdb];
GO

IF OBJECT_ID('dbo.sqlcmdcli_fn_string_scrambler', 'FN') IS NOT NULL
  DROP FUNCTION dbo.sqlcmdcli_fn_string_scrambler;
GO

CREATE FUNCTION dbo.sqlcmdcli_fn_string_scrambler
(
  @AValue VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
WITH ENCRYPTION
AS
BEGIN
  DECLARE @Res VARCHAR(MAX) = '';
  
  -- "abcd" --> "dbca"
  IF (LEN(@AValue) > 2)
    SET @Res = RIGHT(@AValue, 1) + SUBSTRING(@AValue, 2, LEN(@AValue)-2) + LEFT(@AValue, 1)
  ELSE IF (LEN(@AValue) = 2)
    SET @Res = REVERSE(@AValue)
  ELSE
    SET @Res = @AValue
  RETURN @Res
END
GO

SELECT dbo.sqlcmdcli_fn_string_scrambler('Hello World!');
GO