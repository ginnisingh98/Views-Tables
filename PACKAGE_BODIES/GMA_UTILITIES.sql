--------------------------------------------------------
--  DDL for Package Body GMA_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_UTILITIES" AS
/* $Header: GMAUTILB.pls 115.2 2002/05/15 12:16:02 pkm ship       $ */

  procedure do_sql(p_sql_stmt in varchar2) is
    cursor_id  integer;
    return_val integer;
    sql_stmt   varchar2(8192);
  begin
    -- set sql statement
    sql_stmt := p_sql_stmt;

    -- open a cursor
    cursor_id  := dbms_sql.open_cursor;

    -- parse sql statement
    dbms_sql.parse(cursor_id, sql_stmt, DBMS_SQL.V7);

    -- execute statement
    return_val := dbms_sql.execute(cursor_id);

    -- close cursor
    dbms_sql.close_cursor(cursor_id);
  end do_sql;

END GMA_UTILITIES;

/
