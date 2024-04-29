--------------------------------------------------------
--  DDL for Package Body APPS_ARRAY_DDL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."APPS_ARRAY_DDL" as
/* $Header: adaaddlb.pls 115.1 1999/11/09 16:51:00 pkm ship     $ */
procedure apps_array_ddl(lb           in integer,
                         ub           in integer,
                         newline_flag in varchar2 default 'FALSE')
is
 c 		integer;
 rows_processed integer;
 statement 	varchar2(1000);
begin
   c := dbms_sql.open_cursor;
   statement := 'declare l_c integer; l_rows_processed integer; '||
                'begin l_c := dbms_sql.open_cursor; '||
                'dbms_sql.parse(l_c,apps_array_ddl.glprogtext, '||
                to_char(lb)||','||to_char(ub)||', '||
                upper(newline_flag)||', dbms_sql.native); '||
                'l_rows_processed := dbms_sql.execute(l_c); '||
                'dbms_sql.close_cursor(l_c); end;';
   dbms_sql.parse(c,statement,dbms_sql.native);
   rows_processed := dbms_sql.execute(c);
   dbms_sql.close_cursor(c);
exception
  when others then
   dbms_sql.close_cursor(c);
   raise;
end apps_array_ddl;
end APPS_ARRAY_DDL;

/
