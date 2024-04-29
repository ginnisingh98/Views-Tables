--------------------------------------------------------
--  DDL for Package Body OKC_P_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_P_UTIL" AS
/* $Header: OKCPUTLB.pls 120.0 2005/05/26 09:27:03 appldev noship $ */
-- Sub-Program Units
/* Convert major and minor version numbers into a string for the veiws */
FUNCTION VERSION_STRING
 (P_MAJOR IN NUMBER
 ,P_MINOR IN NUMBER
 )
 RETURN VARCHAR2
 IS
 begin
    return ( ltrim(rtrim(to_char(p_major)||'.'||to_char(p_minor))));
end;

/* Convert raw value to number */
FUNCTION  RAW_TO_NUMBER
  (P_RAWID  IN  RAW
  )
  RETURN  NUMBER
  IS
v_raw_str     varchar2(100);
v_raw_int     number := 0;
 begin
  v_raw_str := rawtohex(p_rawid);
  for i in 1..length(v_raw_str) loop
    v_raw_int := v_raw_int * 16;
    v_raw_int := v_raw_int +
          instr('0123456789ABCDEF',substr(v_raw_str,i,1))+1;
  end loop;
  return(v_raw_int);
end;

/* Execute any sql via dynamic sql */
FUNCTION  EXECUTE_SQL
  (P_SQL  IN  VARCHAR2
  )
  RETURN  INTEGER
  IS
v_cursor               integer;                         -- the cursor
  v_error_text          varchar2(4000);           -- error message
  v_num_rows         integer;                         -- number of rows affected by sql

   begin
    -- create savepoint
    savepoint execute_sql_savept;

    -- create cursor
    v_cursor := dbms_sql.open_cursor;

    -- parse statement
    dbms_sql.parse(v_cursor, p_sql, DBMS_SQL.NATIVE);

    -- execute
    v_num_rows := dbms_sql.execute(v_cursor);

    -- close cursor
    dbms_sql.close_cursor(v_cursor);

    -- return success
    return v_num_rows;

  exception
    when others then
      -- capture error message
      v_error_text := sqlerrm;

      -- rollback to before statement
      rollback to execute_sql_savept;

      -- close cursor
      dbms_sql.close_cursor(v_cursor);

      -- take care of error
      --     do something here

      -- return failure
      return -1;
  end;

/* Logic to run in view instead of triggers */
PROCEDURE  INSTEAD_OF_TRG
  IS
 begin
  /* should call fnd_messages, but for now call raise_application_error */
  raise_application_error(-20000,'The API must be used for all inserts, updates, and deletes');
end;

-- PL/SQL Block
END  OKC_P_UTIL;


/
