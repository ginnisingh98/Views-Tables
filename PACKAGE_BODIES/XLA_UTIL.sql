--------------------------------------------------------
--  DDL for Package Body XLA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_UTIL" AS
/* $Header: xlautil.pkb 120.0 2003/11/22 02:29:05 weshen noship $ */

/*===========================================================================*/
/* PRIVATE VARIABLES
/*===========================================================================*/
debug_flag		BOOLEAN := FALSE;
file_debug_flag		BOOLEAN := FALSE;
pg_fp           	utl_file.file_type;

pg_query_context      	VARCHAR2(100) := NULL;

/*===========================================================================*/
/* PRIVATE PROCEDURES/FUNCTIONS
/*===========================================================================*/

PROCEDURE file_debug( text in varchar2 ) is
BEGIN
  if file_debug_flag then
    utl_file.put_line(pg_fp, text);
    utl_file.fflush(pg_fp);
  end if;
END;


/*===========================================================================*/
/* PUBLIC PROCEDURES/FUNCTIONS
/*===========================================================================*/

PROCEDURE enable_debug is
BEGIN
  debug_flag := TRUE;
  dbms_output.enable;
END enable_debug;

PROCEDURE enable_debug(buffer_size	NUMBER) is
BEGIN
  debug_flag := TRUE;
  dbms_output.enable( buffer_size );
END;

PROCEDURE enable_debug(path_name in varchar2,
                       file_name in varchar2 default 'DEFAULT') IS
BEGIN
  if not file_debug_flag then	-- Ignore multiple calls to enable_debug
    pg_fp := utl_file.fopen(path_name, file_name||'.dbg', 'w');
    file_debug_flag := TRUE;
  end if;
EXCEPTION
  when utl_file.invalid_path then
	-- fnd_message.set_name('AR', 'GENERIC_MESSAGE');
	-- fnd_message.set_token('GENERIC_TEXT', 'Invalid path: '||path_name);
	app_exception.raise_exception;
  when utl_file.invalid_mode then
	-- fnd_message.set_name('AR', 'GENERIC_MESSAGE');
	-- fnd_message.set_token('GENERIC_TEXT', 'Cannot open file '||file_name||
--				 ' in write mode.');
	app_exception.raise_exception;
END enable_debug;

PROCEDURE disable_debug is
BEGIN
  debug_flag := FALSE;

  if file_debug_flag then
    file_debug_flag := FALSE;
    utl_file.fclose(pg_fp);
  end if;
END disable_debug;

PROCEDURE debug(text	IN VARCHAR2) is
  rest varchar2(32767);
  buffer_overflow exception;
  pragma exception_init(buffer_overflow, -20000);
BEGIN

  if file_debug_flag then
    file_debug(text);
  else
    if debug_flag then
        rest := text;
        loop
            if( rest is null ) then
                exit;
            else
                dbms_output.put_line(substrb(rest, 1, 255));
                rest := substrb(rest, 256);
            end if;

        end loop;
    end if;
  end if;
EXCEPTION
  when buffer_overflow then
      null;  -- buffer overflow, ignore
  when others then
      raise;
END debug;

PROCEDURE set_query_context (
		p_context       IN  VARCHAR2) IS
BEGIN
 pg_query_context := p_context;
END;

FUNCTION get_query_context RETURN VARCHAR2 IS
BEGIN
  RETURN ( pg_query_context );
END;

-- lgandhi bug 2969915 Created a new function to check the the existence of the function in the data base.
-- Its a wrapper over  FND_FUNCTION.GET_FUNCTION_ID
-- returns: the function id, or NULL if it can't be found.


FUNCTION get_function_id(p_function_name in varchar2  ) RETURN NUMBER IS
BEGIN
  RETURN (fnd_function.get_function_id (p_function_name));
END;


END XLA_UTIL;

/
