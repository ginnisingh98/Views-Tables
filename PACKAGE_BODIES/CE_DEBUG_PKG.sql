--------------------------------------------------------
--  DDL for Package Body CE_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_DEBUG_PKG" AS
/* $Header: cedebugb.pls 120.0 2002/08/24 02:33:15 appldev noship $ */

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

    pg_fp        := utl_file.fopen(path_name, file_name, 'a');
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

END CE_DEBUG_PKG;

/
