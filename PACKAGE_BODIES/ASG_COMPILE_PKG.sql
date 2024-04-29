--------------------------------------------------------
--  DDL for Package Body ASG_COMPILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_COMPILE_PKG" as
/* $Header: asgcompb.pls 120.1 2005/08/12 02:43:35 saradhak noship $ */

-- HISTORY

-- Dec 30, 2003  yazhang add overload method
-- JULY 24, 2002 ytian created.

 PROCEDURE compile_all_objects (schema_name in VARCHAR2) as

    -- compile package specifications first, then views, then bodies
    -- this is because a view could reference a package header
   cursor c1 is
     select object_name, object_type from all_objects
     where status = 'INVALID'
     and   object_type = 'PACKAGE'
     and owner=schema_name;

   cursor c2 is
     select object_name, object_type from all_objects
     where status = 'INVALID'
     and   object_type = 'VIEW'
     and owner=schema_name ;

 --
 -- The select statement here is more complicated because we
 -- have coded it to ignore disabled triggers (even if invalid)
 --
   cursor c3 is
     select decode(o.type#,9,1,2) dummy,
            o.name object_name,
            decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE',
                           3, 'CLUSTER',
                           4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                           7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                           11, 'PACKAGE BODY', 12, 'TRIGGER',
                           13, 'TYPE', 14, 'TYPE BODY',
                           19, 'TABLE PARTITION', 20, 'INDEX PARTITION',
                           22, 'LIBRARY', 23, 'DIRECTORY', 24, 'QUEUE',
                           28, 'JAVA SOURCE', 29, 'JAVA CLASS',
                           30, 'JAVA RESOURCE',
                           32, 'INDEXTYPE', 33, 'OPERATOR',
                           34, 'TABLE SUBPARTITION', 35, 'INDEX SUBPARTITION',
                           39, 'LOB PARTITION', 40, 'LOB SUBPARTITION',
                           43, 'DIMENSION',
                           44, 'CONTEXT', 47, 'RESOURCE PLAN',
                           48, 'CONSUMER GROUP',
                           51, 'SUBSCRIPTION', 52, 'LOCATION',
                          'UNDEFINED') object_type
     from sys.obj$ o, sys.user$ u
     where o.owner# = u.user#
       and u.name = schema_name

     and o.status <> 1 /* not valid status */
    -- and o.name like '%%'
     and o.type# not in (28, 29, 30,12) /* exclude Java stuff for now + trigger*/
     -- and not exists ( select 'x' from sys.trigger$ t
        --              where o.obj# = t.obj#
          --            and t.enabled = 0)
     order by 1;
   c                        integer;

   rows_processed           integer;
   statement                varchar2(100);
   object_type1             varchar2(30);
   object_type2             varchar2(30);

   success_with_comp_error exception;
   PRAGMA EXCEPTION_INIT(success_with_comp_error, -24344);
 begin
   -- first compile all invalid packages specifications
   for c1rec in c1 loop
     -- for each invalid object compile
     begin
       statement := 'ALTER PACKAGE '||schema_name ||'.' ||c1rec.object_name||
                    ' COMPILE SPECIFICATION';

       c := dbms_sql.open_cursor;
       dbms_sql.parse(c, statement, dbms_sql.native);
       rows_processed := dbms_sql.execute(c);
       dbms_sql.close_cursor(c);
     exception
       when success_with_comp_error then
 --
 -- Trap and ignore ORA-24344: success with compilation error
 -- This only happens on ORACLE 8
 --
         dbms_sql.close_cursor(c);
       when others then
         dbms_sql.close_cursor(c);
         raise;
     end;

   end loop;  -- loop over all invalid packages
   -- next compile all invalid views
   for c2rec in c2 loop
     -- for each invalid object compile
     begin
       statement := 'ALTER VIEW '||schema_name||'.'||c2rec.object_name||' COMPILE';

       c := dbms_sql.open_cursor;
       dbms_sql.parse(c, statement, dbms_sql.native);
       rows_processed := dbms_sql.execute(c);
       dbms_sql.close_cursor(c);
     exception
       when success_with_comp_error then
         dbms_sql.close_cursor(c);
       when others then
         dbms_sql.close_cursor(c);
         raise;
     end;
   end loop;  -- loop over all invalid views
   -- last, get all remaining invalid objects, which could be package bodies
   -- unpackaged procedures or functions, or triggers
   for c3rec in c3 loop
     -- for each invalid object compile
     begin
       object_type1 := c3rec.object_type;
       object_type2 := null;

       if object_type1 = 'PACKAGE BODY' then
         object_type1  := 'PACKAGE';
         object_type2 := 'BODY';
       elsif object_type1 = 'PACKAGE' then
         object_type1  := 'PACKAGE';
         object_type2 := 'SPECIFICATION';
       elsif object_type1 = 'TYPE' then
         object_type1  := 'TYPE';
         object_type2 := 'SPECIFICATION';
       elsif object_type1 = 'TYPE BODY' then
         object_type1  := 'TYPE';
         object_type2 := 'BODY';
       end if;

       statement := 'ALTER '||object_type1||' '||schema_name||'.'||c3rec.object_name||
                    ' COMPILE '||object_type2;

       if c3rec.object_type <> 'UNDEFINED' then
         c := dbms_sql.open_cursor;
         dbms_sql.parse(c, statement, dbms_sql.native);
         rows_processed := dbms_sql.execute(c);
         dbms_sql.close_cursor(c);
       end if;

     exception
       when success_with_comp_error then
         dbms_sql.close_cursor(c);
       when others then
         dbms_sql.close_cursor(c);
         raise;
     end;
   end loop;  -- loop over all remaining invalid objects
 end compile_all_objects;


 PROCEDURE compile_all_objects as

    -- compile package specifications first, then views, then bodies
    -- this is because a view could reference a package header
   cursor c1 is
     select object_name, object_type from user_objects
     where status = 'INVALID'
     and   object_type = 'PACKAGE' ;

   cursor c2 is
     select object_name, object_type from user_objects
     where status = 'INVALID'
     and   object_type = 'VIEW' ;

 --
 -- The select statement here is more complicated because we
 -- have coded it to ignore disabled triggers (even if invalid)
 --
   cursor c3 is
     select decode(o.type#,9,1,2) dummy,
            o.name object_name,
            decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE',
                           3, 'CLUSTER',
                           4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                           7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                           11, 'PACKAGE BODY', 12, 'TRIGGER',
                           13, 'TYPE', 14, 'TYPE BODY',
                           19, 'TABLE PARTITION', 20, 'INDEX PARTITION',
                           22, 'LIBRARY', 23, 'DIRECTORY', 24, 'QUEUE',
                           28, 'JAVA SOURCE', 29, 'JAVA CLASS',
                           30, 'JAVA RESOURCE',
                           32, 'INDEXTYPE', 33, 'OPERATOR',
                           34, 'TABLE SUBPARTITION', 35, 'INDEX SUBPARTITION',
                           39, 'LOB PARTITION', 40, 'LOB SUBPARTITION',
                           43, 'DIMENSION',
                           44, 'CONTEXT', 47, 'RESOURCE PLAN',
                           48, 'CONSUMER GROUP',
                           51, 'SUBSCRIPTION', 52, 'LOCATION',
                          'UNDEFINED') object_type
     from sys.obj$ o
     where o.owner# = userenv('SCHEMAID')
     and o.status <> 1 /* not valid status */
    -- and o.name like '%%'
     and o.type# not in (28, 29, 30,12) /* exclude Java stuff for now + trigger*/
     -- and not exists ( select 'x' from sys.trigger$ t
        --              where o.obj# = t.obj#
          --            and t.enabled = 0)
     order by 1;
   c                        integer;

   rows_processed           integer;
   statement                varchar2(100);
   object_type1             varchar2(30);
   object_type2             varchar2(30);

   success_with_comp_error exception;
   PRAGMA EXCEPTION_INIT(success_with_comp_error, -24344);
 begin
   -- first compile all invalid packages specifications
   for c1rec in c1 loop
     -- for each invalid object compile
     begin
       statement := 'ALTER PACKAGE '||c1rec.object_name||
                    ' COMPILE SPECIFICATION';

       c := dbms_sql.open_cursor;
       dbms_sql.parse(c, statement, dbms_sql.native);
       rows_processed := dbms_sql.execute(c);
       dbms_sql.close_cursor(c);
     exception
       when success_with_comp_error then
 --
 -- Trap and ignore ORA-24344: success with compilation error
 -- This only happens on ORACLE 8
 --
         dbms_sql.close_cursor(c);
       when others then
         dbms_sql.close_cursor(c);
         raise;
     end;
   end loop;  -- loop over all invalid packages
   -- next compile all invalid views
   for c2rec in c2 loop
     -- for each invalid object compile
     begin
       statement := 'ALTER VIEW '||c2rec.object_name||' COMPILE';

       c := dbms_sql.open_cursor;
       dbms_sql.parse(c, statement, dbms_sql.native);
       rows_processed := dbms_sql.execute(c);
       dbms_sql.close_cursor(c);
     exception
       when success_with_comp_error then
         dbms_sql.close_cursor(c);
       when others then
         dbms_sql.close_cursor(c);
         raise;
     end;
   end loop;  -- loop over all invalid views
   -- last, get all remaining invalid objects, which could be package bodies
   -- unpackaged procedures or functions, or triggers
   for c3rec in c3 loop
     -- for each invalid object compile
     begin
       object_type1 := c3rec.object_type;
       object_type2 := null;

       if object_type1 = 'PACKAGE BODY' then
         object_type1  := 'PACKAGE';
         object_type2 := 'BODY';
       elsif object_type1 = 'PACKAGE' then
         object_type1  := 'PACKAGE';
         object_type2 := 'SPECIFICATION';
       elsif object_type1 = 'TYPE' then
         object_type1  := 'TYPE';
         object_type2 := 'SPECIFICATION';
       elsif object_type1 = 'TYPE BODY' then
         object_type1  := 'TYPE';
         object_type2 := 'BODY';
       end if;

       statement := 'ALTER '||object_type1||' '||c3rec.object_name||
                    ' COMPILE '||object_type2;

       if c3rec.object_type <> 'UNDEFINED' then
         c := dbms_sql.open_cursor;
         dbms_sql.parse(c, statement, dbms_sql.native);
         rows_processed := dbms_sql.execute(c);
         dbms_sql.close_cursor(c);
       end if;

     exception
       when success_with_comp_error then
         dbms_sql.close_cursor(c);
       when others then
         dbms_sql.close_cursor(c);
         raise;
     end;
   end loop;  -- loop over all remaining invalid objects
 end compile_all_objects;


END ASG_COMPILE_PKG;

/
