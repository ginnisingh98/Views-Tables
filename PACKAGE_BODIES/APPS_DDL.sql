--------------------------------------------------------
--  DDL for Package Body APPS_DDL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."APPS_DDL" as
/* $Header: adaddlb.pls 115.0 99/07/17 04:29:32 porting ship $ */
procedure apps_ddl (ddl_text in varchar2) is
  c			integer;
  rows_processed	integer;
begin
  c := dbms_sql.open_cursor;
  dbms_sql.parse(c, ddl_text, dbms_sql.native);
  rows_processed := dbms_sql.execute(c);
  dbms_sql.close_cursor(c);
exception
  when others then
    dbms_sql.close_cursor(c);
    raise;
end apps_ddl;
end APPS_DDL;

/

  GRANT EXECUTE ON "APPS"."APPS_DDL" TO "OKC";
