--------------------------------------------------------
--  DDL for Package Body FND_FLEX_UPD_FMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_UPD_FMT" AS
/* $Header: AFFFUPFB.pls 115.0 99/07/16 23:20:04 porting ship $ */

/* START_PUBLIC */
bad_parameter EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_parameter, -06501);
/* END_PUBLIC */


debug_mode_on BOOLEAN := FALSE;

PROCEDURE debug_on IS
BEGIN
   debug_mode_on := TRUE;
END;

PROCEDURE debug_off IS
BEGIN
   debug_mode_on := FALSE;
END;

PROCEDURE println(msg IN VARCHAR2) IS
BEGIN
   IF(debug_mode_on) THEN
      dbms_output.enable;
      dbms_output.put_line(msg);
   END IF;
END;


/* START_PUBLIC */

/*  Change the date format in the specified column of the
  specified table to conform to the new date and time standards.
  The new_format_type is one of Date, DateTime, or Time.
  If the old format is not specified (as a format string
  in the to_char format), then the old standard conrresponding
  to the new format type is used.
 */
  /* old 'standard' formats
  old_date_fmt     := 'DD-MON-YY HH24:MI:SS';
  old_datetime_fmt := 'DD-MON-YY HH24:MI:SS';
  old_time_fmt     := 'HH24:MI:SS';
  */

PROCEDURE convert_date(table_name      IN VARCHAR2,
		       column_name     IN VARCHAR2,
		       new_format_type IN VARCHAR2,
		       old_format      IN VARCHAR2 DEFAULT null)
     IS
	/* new standard formats */
     std_date_fmt VARCHAR2(100) := 'YYYY/MM/DD HH24:MI:SS';
     std_datetime_fmt VARCHAR2(100) := 'YYYY/MM/DD HH24:MI:SS';
     std_time_fmt VARCHAR2(100) := 'HH24:MI:SS';
     /* old 'standard' formats */
     old_date_fmt VARCHAR2(100) := 'DD-MON-YY HH24:MI:SS';
     old_datetime_fmt VARCHAR2(100) := 'DD-MON-YY HH24:MI:SS';
     old_time_fmt VARCHAR2(100) := 'HH24:MI:SS';
     cursor_handle INTEGER;
     format_type VARCHAR2(100);
     sqlstmt VARCHAR2(1000);
     newfmt VARCHAR2(100);
     oldfmt VARCHAR2(100);
     num_lines NUMBER;
BEGIN
   format_type := Upper(new_format_type);
   IF(format_type = 'DATE') THEN
      oldfmt := old_date_fmt;
      newfmt := std_date_fmt;
    ELSIF(format_type = 'DATETIME') THEN
      oldfmt := old_datetime_fmt;
      newfmt := std_datetime_fmt;
    ELSIF(format_type = 'TIME') THEN
      oldfmt := old_time_fmt;
      newfmt := std_time_fmt;
     ELSE
      println('bad format type:'||format_type);
      RAISE bad_parameter;
   END IF;

   IF(old_format IS NOT NULL) THEN
      oldfmt := old_format;
   END IF;

   -- make sure there are no quotes to mess things up
   IF((Instr(oldfmt, '''') > 0) OR
      (Instr(newfmt, '''') > 0)) THEN
      println('detected single quote in format string');
      RAISE bad_parameter;
   END IF;


--   sqlstmt := 'UPDATE :table_name  ' ||
--     'SET :column_name = To_char(To_date(:column_name, :oldfmt), :newfmt)';

   sqlstmt := 'UPDATE ' || table_name ||
     ' SET ' || column_name ||
     ' = To_char(To_date('||column_name||  ',''' || oldfmt ||
     '''), ''' || newfmt || ''')';

   println('table name:'||table_name);
   println('sql:'||sqlstmt);

   cursor_handle := dbms_sql.open_cursor;
   dbms_sql.parse(cursor_handle, sqlstmt, dbms_sql.v7);
--   dbms_sql.bind_variable(cursor_handle, 'table_name', table_name);
--   dbms_sql.bind_variable(cursor_handle, 'column_name', column_name);
--   dbms_sql.bind_variable(cursor_handle, 'oldfmt', oldfmt);
--   dbms_sql.bind_variable(cursor_handle, 'newfmt', newfmt);
   num_lines := dbms_sql.execute(cursor_handle);
   dbms_sql.close_cursor(cursor_handle);
   println('updated:' || To_char(num_lines));
EXCEPTION
   WHEN OTHERS THEN
      dbms_sql.close_cursor(cursor_handle);
      println(Sqlerrm);
      RAISE bad_parameter;
END;


/* END_PUBLIC */

END fnd_flex_upd_fmt;

/
