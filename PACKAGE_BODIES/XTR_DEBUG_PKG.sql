--------------------------------------------------------
--  DDL for Package Body XTR_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_DEBUG_PKG" as
/* $Header: xtrdebgb.pls 115.8 2003/07/30 17:09:26 rvallams ship $ */
--
--
  pg_file_name    VARCHAR2(100)         := NULL;
  pg_path_name    VARCHAR2(100)         := NULL;
  pg_fp           utl_file.file_type;

--
--
--
--
PROCEDURE enable_file_debug (path_name in varchar2,
			     file_name in varchar2) IS

BEGIN

-- RV: Bug 3011847 --
   NULL;

/*
  if (pg_file_name is null) THEN

    IF not utl_file.is_open(pg_fp) THEN

       pg_fp := utl_file.fopen(path_name, file_name, 'w');
    END IF;

    pg_file_name := file_name;
    pg_path_name := path_name;
    xtr_risk_debug_pkg.set_filehandle(pg_fp);
  end if;

  EXCEPTION

    when utl_file.invalid_path then
       RAISE_APPLICATION_ERROR(-20001, path_name ||
				' is an invalid file path!!!!!!');
--      app_exception.raise_exception;
    when utl_file.invalid_mode then
      app_exception.raise_exception;
*/

END ;



--
--
--
--
PROCEDURE enable_file_debug  IS

BEGIN

-- RV: Bug 3011847 --
   NULL;

/*
 pg_sqlplus_enable_flag := 1;
 xtr_risk_debug_pkg.start_debug;
*/

END ;





--
--
--
--
PROCEDURE disable_file_debug is
BEGIN

-- RV: Bug 3011847 --
   NULL;

/*
  if (pg_file_name is not null) and pg_file_name <> '' THEN
    pg_file_name := NULL;
    pg_path_name := NULL;
    if utl_file.is_open(pg_fp) then
       utl_file.fclose(pg_fp);
    end if;
    xtr_risk_debug_pkg.stop_debug;
  end if;
*/

END;

--
--
--
--
PROCEDURE debug( line in varchar2 ) is

  rest varchar2(32767);
  buffer_overflow exception;
  pragma exception_init(buffer_overflow, -20000);

BEGIN

-- RV: Bug 3011847 --

  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        'xtr', line);
  end if;

/*
    IF (pg_file_name IS NOT NULL) or utl_file.is_open(pg_fp) THEN

      utl_file.put_line(pg_fp, line);
      utl_file.fflush(pg_fp);

    END IF;

   if ( pg_sqlplus_enable_flag = 1 ) then
    --dbms_output.put_line(line);
fnd_file.put_line(fnd_file.log, line);

   end if;

EXCEPTION

  when buffer_overflow then
      null;  -- buffer overflow, ignore
  when others then
      raise;
*/

END;



PROCEDURE set_filehandle (p_FileHandle utl_file.file_type := NULL) IS

BEGIN

-- RV: Bug 3011847 --
   NULL;

/*
  IF not utl_file.is_open(pg_fp) and utl_file.is_open(p_FileHandle) THEN

    pg_fp := p_FileHandle;
  END IF;
*/

END set_filehandle;

END XTR_DEBUG_PKG;

/
