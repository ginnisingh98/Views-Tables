--------------------------------------------------------
--  DDL for Package Body GMA_LOCK_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_LOCK_RECORD" AS
/* $Header: GMALOCKB.pls 115.2 2003/05/07 14:11:18 appldev ship $ */
  FUNCTION lock_record(V_Table_name VARCHAR2,V_Column_name VARCHAR2,V_Column_val NUMBER,V_Last_update_date DATE) RETURN NUMBER IS

    X_Col_val varchar2(32);
    X_Cur_lock_hdr integer;
    X_Get_who_hdr integer;
    X_Rows_processed integer;
    X_Last_update_date DATE;
    X_Select_statement varchar2(200);

  BEGIN
    X_Select_statement := 'SELECT '||V_Column_name||' FROM '||V_Table_name || ' WHERE '||V_Column_name
                                   || ' = :V_Column_val '||' FOR UPDATE OF '|| V_Column_name ||' NOWAIT ';


    IF dbms_sql.is_open(X_Get_who_hdr) THEN
      dbms_sql.close_cursor(X_Get_who_hdr);
    END IF;

    BEGIN
      IF dbms_sql.is_open(X_Cur_lock_hdr) THEN
        dbms_sql.close_cursor(X_Cur_lock_hdr);
      END IF;

      X_Cur_lock_hdr:=dbms_sql.open_cursor;
      dbms_sql.parse(X_Cur_lock_hdr,X_Select_statement,0);
      dbms_sql.define_column(X_Cur_lock_hdr, 1, V_Column_name,32);

      --  Changing literals to bind variables as per coding standard.      |
      --  See detials in bug 2941580                                       |
      dbms_sql.bind_variable(X_Cur_lock_hdr, 'V_Column_val',to_char(V_Column_val));

      X_Rows_processed:=dbms_sql.execute(X_Cur_lock_hdr);
      IF dbms_sql.fetch_rows(X_Cur_lock_hdr) > 0 THEN
        Null;
      ELSE
        IF dbms_sql.is_open(X_Cur_lock_hdr) THEN
          dbms_sql.close_cursor(X_Cur_lock_hdr);
        END IF;
        ROLLBACK;
        RETURN(-1);
      END IF;
      dbms_sql.close_cursor(X_Cur_lock_hdr);

      X_Select_statement:='SELECT Last_update_date FROM '||V_Table_name||' WHERE '||V_Column_name || '=:V_Column_val';
      X_Get_who_hdr:=dbms_sql.open_cursor;
      dbms_sql.parse(X_Get_who_hdr,X_Select_statement,0);
      dbms_sql.define_column(X_Get_who_hdr, 1, V_Last_update_date);

      --  Changing literals to bind variables as per coding standard.      |
      --  See detials in bug 2941580                                       |
      dbms_sql.bind_variable(X_Get_who_hdr,'V_Column_val',to_char(V_Column_val));

      X_Rows_processed:=dbms_sql.execute(X_Get_who_hdr);
      IF dbms_sql.fetch_rows(X_Get_who_hdr) > 0 THEN
        dbms_sql.column_value(X_Get_who_hdr,1,X_Last_update_date);
      END IF;
      IF dbms_sql.is_open(X_Get_who_hdr) THEN
        dbms_sql.close_cursor(X_Get_who_hdr);
      END IF;
      IF X_Last_update_date <> V_Last_update_date THEN
        ROLLBACK;
        RETURN(-2);
      END IF;
      RETURN (1);
    EXCEPTION
      WHEN app_exceptions.record_lock_exception THEN
        IF dbms_sql.is_open(X_Get_who_hdr) THEN
          dbms_sql.close_cursor(X_Get_who_hdr);
        END IF;
        RETURN(0);
    END;
  END Lock_record;
END GMA_LOCK_RECORD;

/
