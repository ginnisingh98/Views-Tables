--------------------------------------------------------
--  DDL for Package Body PNP_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNP_DEBUG_PKG" As
  -- $Header: PNDEBUGB.pls 115.12 2003/11/18 02:25:18 mmisra ship $

--
--
  pg_file_name    VARCHAR2(100)         := NULL;
  pg_path_name    VARCHAR2(100)         := NULL;
  pg_fp           utl_file.file_type;

PROCEDURE enable_file_debug (
                              path_name in varchar2,
			      file_name in varchar2
                            ) IS
BEGIN

  if (pg_file_name is null) THEN

    pg_fp        := utl_file.fopen(path_name, file_name, 'w');
    pg_file_name := file_name;
    pg_path_name := path_name;

  end if;

  EXCEPTION

    when utl_file.invalid_path then
      app_exception.raise_exception;
    when utl_file.invalid_mode then
      app_exception.raise_exception;

END ;
--
--
PROCEDURE disable_file_debug is
BEGIN

  if (pg_file_name is not null) THEN
    pg_file_name := NULL;
    pg_path_name := NULL;
    utl_file.fclose(pg_fp);
  end if;

END;
--
--
PROCEDURE debug( line in varchar2 ) is

  rest varchar2(32767);
  buffer_overflow exception;
  pragma exception_init(buffer_overflow, -20000);

BEGIN

    IF (pg_file_name IS NOT NULL) THEN

      utl_file.put_line(pg_fp, line);
      utl_file.fflush(pg_fp);

    END IF;

EXCEPTION

  when buffer_overflow then
      null;  -- buffer overflow, ignore
  when others then
      raise;
END;
--
--
PROCEDURE put_log_msg(status_string  VarChar2 )is

BEGIN

  Fnd_File.Put_Line ( Fnd_File.Log,  status_string );
  Fnd_File.Put_Line ( Fnd_File.OutPut,  status_string );

EXCEPTION
  When Others Then Raise;

END put_log_msg;

--
--
PROCEDURE log(status_string  VarChar2 )is

BEGIN

  Fnd_File.Put_Line ( Fnd_File.Log,  status_string );

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'PN' , status_string );
  END IF;

EXCEPTION
  When Others Then Raise;

END log;

END PNP_DEBUG_PKG;

/
