--------------------------------------------------------
--  DDL for Package Body MRP_EXCEPTION_SC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_EXCEPTION_SC" AS
/* $Header: MRPXSUMB.pls 120.2 2006/02/20 21:21:11 avjain noship $ */

---------------------------------------------------------------
-- insert into mrp_form_query the selected exception counts
---------------------------------------------------------------
FUNCTION group_by(
	var_exception_id NUMBER,
	planning_org NUMBER, planned_org NUMBER,
	count_list VARCHAR2, count_list_mfq VARCHAR2,
 	compile_designator VARCHAR2, where_clause_segment VARCHAR2,                all_orgs NUMBER DEFAULT NULL)
	       RETURN NUMBER IS

   c integer;
   n number :=1;
   statement varchar2(20000);
   exception_id NUMBER;
   rows_processed  integer;

BEGIN


   statement :=
	' INSERT INTO mrp_form_query' ||
	'(query_id, ' ||
	'last_update_date, ' ||
	'last_updated_by, ' ||
        'last_update_login, ' ||
	'creation_date, ' ||
	'created_by, ' ||
	'char1, ' ||
	count_list_mfq ||',' || 'number5, number13) ' ||
	' SELECT  /*+ CHOOSE */ '||
	':var_exception_id ' ||
	', TRUNC(SYSDATE),' ||
	'-1, -1,' ||
	'TRUNC(SYSDATE),' ||
	'-1, ' ||
	'compile_designator, ' ||
	count_list ||', ' ||
	'sum(exception_count), display ' ||
	' FROM mrp_item_exception_v ' ||
	' WHERE compile_designator = :compile_designator' ||
	' and organization_id= decode( :planning_org ,:planned_org,organization_id,:planned_org) '||
	' and organization_id= decode(:all_orgs, :n '||
	', organization_id,:planned_org )'||
	where_clause_segment ||
	'GROUP BY compile_designator, display, ' ||
        count_list;

   /*c := dbms_sql.open_cursor;
   dbms_sql.parse(c, statement, dbms_sql.native);
   rows_processed := dbms_sql.execute(c);
   dbms_sql.close_cursor(c);
*/
--bug 5022710

execute immediate statement using
var_exception_id,compile_designator,planning_org,
planned_org,planned_org,all_orgs,n,planned_org;

   SELECT mrp_form_query_s.NEXTVAL
	INTO exception_id
	FROM dual;

   statement :=
	' INSERT INTO mrp_form_query' ||
	'(query_id, ' ||
	'last_update_date, ' ||
	'last_updated_by, ' ||
        'last_update_login, ' ||
	'creation_date, ' ||
	'created_by, ' ||
	'char1, ' ||
        'number1, ' ||
	'number2, ' ||
	'number3, ' ||
	'number4, ' ||
	'number6, ' ||
	'number7, ' ||
	'number8, ' ||
        'number9, ' ||
        'number10, ' ||
        'number11, ' ||
        'number12, ' ||
        'number13, ' ||
	'char2, ' ||
	'char9, ' ||
	'char4, ' ||
        'char8 ) ' ||
	' SELECT /*+ CHOOSE*/ DISTINCT ' ||
	' :exception_id,' ||
	' TRUNC(SYSDATE),' ||
	'-1, -1,' ||
	'TRUNC(SYSDATE),' ||
	'-1, ' ||
	'compile_designator, ' ||
        'version, ' ||
	'exception_type, ' ||
	'inventory_item_id, ' ||
	'organization_id, ' ||
	'project_id, ' ||
	'task_id, ' ||
	'category_id, ' ||
        'department_id, ' ||
        'resource_id, ' ||
        'line_id, ' ||
        'resource_type, ' ||
        'display, ' ||
	'planner_code, ' ||
	'buyer_name, ' ||
	'planning_group, ' ||
        'row_id ' ||
	' FROM mrp_item_exception_v ' ||
	' WHERE compile_designator = :compile_designator' ||
	' and organization_id= decode(:planning_org,:planned_org ' ||
	', organization_id,:planned_org) '||
	' and organization_id= decode( :all_orgs '||
	', :n,organization_id,:planned_org ) '||
        ' and version is null ' ||
        where_clause_segment;

    /*c := dbms_sql.open_cursor;
    dbms_sql.parse(c, statement, dbms_sql.native);
    rows_processed := dbms_sql.execute(c);
    dbms_sql.close_cursor(c);
    */
    --5022710
    execute immediate statement using
    exception_id,compile_designator,planning_org,planned_org,planned_org,
    all_orgs,n,planned_org;

    return(exception_id);

EXCEPTION
   when no_data_found
          then null;
   when others then
          raise_application_error(-20000,sqlerrm||':'||statement);
END;

---------------------------------------------------------------------
-- to save the current exception summary into mrp_item_exceptions
---------------------------------------------------------------------
FUNCTION save_as(org_id number, plan VARCHAR2) RETURN NUMBER IS
   version_id NUMBER;
BEGIN

   SELECT MAX(NVL(version,0))+1
   INTO version_id
   FROM mrp_item_exceptions
   WHERE compile_designator= plan;

   INSERT INTO mrp_item_exceptions
         (exception_type, inventory_item_id, compile_designator,
          organization_id, last_update_date, last_updated_by,
          creation_date, created_by, last_update_login, display, request_id,
          program_application_id, program_id,
          program_update_date, updated, status, exception_count, project_id,
          task_id, version, planning_group,
	  department_id, resource_id, line_id)
   SELECT exception_type, inventory_item_id, compile_designator,
	organization_id, last_update_date, last_updated_by,
	creation_date, created_by, last_update_login, display, request_id,
	program_application_id, program_id,
	program_update_date, updated, status, exception_count, project_Id,
	task_id, version_id, planning_group,
	department_id, resource_id, line_id
	FROM  mrp_item_exceptions
	WHERE version is null
        AND compile_designator= plan;
   commit;
   Return version_id;
END save_as;

---------------------------------------------------------------------
-- update mrp-item-exceptions and mrp_form_query tables
---------------------------------------------------------------------
PROCEDURE update_row(p_exception_id number,
                        p_omit_list VARCHAR2,
                        p_row_id VARCHAR2,
                        p_last_update_login NUMBER,
                        p_last_updated_by NUMBER) IS
   c integer;
   statement varchar2(2000);
   rows_processed  integer;
BEGIN

-- update mrp_item_exceptions by the their rowid (stored as char8 in
-- mrp_form_query) by applying the criteria on the second insert
-- of mrp_form_query

    statement :=
        'update mrp_item_exceptions
         set display = 2,
         last_update_login = :last_update_login,
         last_updated_by = :last_updated_by,
         last_update_date = sysdate
         where rowid in (
                select chartorowid(char8)
                from mrp_form_query
                where ' ||p_omit_list||
                ' and query_id = :exception_id )';

     c := dbms_sql.open_cursor;
     dbms_sql.parse(c, statement, dbms_sql.native);
     dbms_sql.bind_variable(c,'last_update_login',p_last_update_login);
     dbms_sql.bind_variable(c,'last_updated_by',p_last_updated_by);
     dbms_sql.bind_variable(c,'exception_id',p_exception_id);
     rows_processed := dbms_sql.execute(c);
     dbms_sql.close_cursor(c);

Exception
        When no_data_found Then
        raise no_data_found;

END update_row;
---------------------------------------------------------------------
-- to lock the row in mrp_item_exceptions
-- if the row is deleted, return 1. if the data is changed, return 2.
-- if the row is locked successfully, return 3.
---------------------------------------------------------------------
FUNCTION lock_row(p_exception_id number, p_omit_list VARCHAR2)
                                                RETURN NUMBER IS
   c integer;
   statement varchar2(20000);
   rows_processed  integer;
   display_flag    NUMBER;
   counter NUMBER;
BEGIN

-- lock the row in mrp_item_exceptions by the their rowid (stored as char8 in
-- mrp_form_query) by applying the criteria on the second insert
-- of mrp_form_query

   statement :=
        'select display
         from  mrp_item_exceptions
         where rowid in (
                select chartorowid(char8)
                from mrp_form_query
                where ' ||p_omit_list||
                ' and query_id = :exception_id )'||
                ' for update of display nowait ';

   c := dbms_sql.open_cursor;
   dbms_sql.parse(c, statement, dbms_sql.native);
   dbms_sql.define_column(c, 1, display_flag);
   dbms_sql.bind_variable(c,'exception_id',p_exception_id);
   rows_processed := dbms_sql.execute(c);
   counter :=0;

   Loop
        IF (dbms_sql.fetch_rows(c) >0)  THEN
            dbms_sql.column_value(c, 1, display_flag);
           IF display_flag <> 1 THEN
           -- record already changed
                return 2;
           END IF;
           counter :=counter+1;
        ELSE
           exit;
        END IF;
   END Loop;
   dbms_sql.close_cursor(c);
   IF counter = 0 THEN
      -- no matching records , record already deleted
        return 1;
   ELSE
      -- with matching records, and the display flag is not changed yet
        return 3;
   END IF;


EXCEPTION
   WHEN others THEN
 --can not lock the record, because the record is locked by other users already
        IF dbms_sql.is_open(c) THEN
          dbms_sql.close_cursor(c);
        END IF;
        raise_application_error(-20020,sqlerrm||':'||statement);

END lock_row;

FUNCTION item_number(p_org_id number, p_inventory_item_id NUMBER) RETURN VARCHAR2
IS
  v_item_number mtl_item_flexfields.item_number%type;
BEGIN
IF p_inventory_item_id IS NOT NULL AND p_org_id IS NOT NULL THEN

  SELECT item_number INTO v_item_number
  FROM mtl_item_flexfields
  WHERE organization_id = p_org_id
  AND   inventory_item_id = p_inventory_item_id;

  RETURN(v_item_number);
ELSE
  RETURN(NULL);
END IF;
EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN(null);
END item_number;


FUNCTION supplier(arg_supplier_id IN NUMBER) return varchar2 IS
supplier_name varchar2(240);
BEGIN

  if arg_supplier_id is null then
     return null;
  end if;
   select vendor_name
   into supplier_name
   from po_vendors
   where
      vendor_id = arg_supplier_id;

   return supplier_name;

END supplier;


FUNCTION supplier_site(arg_supplier_site_id IN NUMBER) return varchar2 IS
supplier_site varchar2(240);
BEGIN

  if arg_supplier_site_id is null then
     return null;
  end if;
   select vendor_site_code
   into supplier_site
   from po_vendor_sites_all
   where
      vendor_site_id = arg_supplier_site_id;

   return supplier_site;

END supplier_site;


END;

/
