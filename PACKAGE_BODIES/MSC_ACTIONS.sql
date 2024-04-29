--------------------------------------------------------
--  DDL for Package Body MSC_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ACTIONS" AS
/* $Header: MSCPACTB.pls 120.3 2007/10/03 21:40:26 eychen ship $ */

---------------------------------------------------------------
-- insert into msc_form_query the selected exception counts
---------------------------------------------------------------
PROCEDURE group_by(
        l_plan_node NUMBER,
	var_exception_id NUMBER,
	count_list VARCHAR2, count_list_mfq VARCHAR2,
 	where_clause VARCHAR2,
	p_plan_id NUMBER,
        p_inst_id NUMBER,
        p_org_id NUMBER,
        p_item_id NUMBER,
        p_planning_grp VARCHAR2,
        p_project_id NUMBER,
        p_task_id NUMBER,
        p_category_name varchar2,
        p_pf_id NUMBER,
        p_dept_id NUMBER,
        p_resource_id NUMBER,
        p_supplier_id NUMBER,
	p_version NUMBER,
	p_exc_grp_id NUMBER,
	p_exception_id NUMBER,
	p_dept_class VARCHAR2,
	p_res_group VARCHAR2) IS

   statement varchar2(20000);
   l_exc_grp_id		NUMBER := NULL;
   v_date date;
   v_days number:=0;
   v_cat_id number;

   CURSOR date_cur IS
    SELECT p.plan_start_date, p.plan_type, p.curr_cutoff_date
      FROM msc_plans p
     WHERE p.plan_id = p_plan_id;

   CURSOR cat_cur IS
     SELECT category_set_id
     FROM msc_category_sets
     WHERE default_flag = 1;

   CURSOR inst_c IS
     SELECT distinct sr_instance_id
       from msc_plan_organizations
      WHERE plan_id = p_plan_id;
   v_inst_list varchar2(3000);
   v_id number;
   v_plan_type number;
   ship_stat varchar2(3000);
   v_ship_cat_id number;
   startPos number;
   endPos number;
   a number :=0;
   l_len number;
   ship_count_list varchar2(3000);
   ship_list_mfq varchar2(3000);
   p_column varchar2(200);
   l_def_pref_id number;
   v_plan_end_date date;
BEGIN

   statement :=
	' INSERT INTO msc_form_query' ||
	'(query_id, ' ||
	'last_update_date, ' ||
	'last_updated_by, ' ||
        'last_update_login, ' ||
	'creation_date, ' ||
	'created_by, ' ||
	count_list_mfq || ' ,number16, number5, number13) ' ||
	' SELECT :query_id ' ||
	', TRUNC(SYSDATE),' ||
	'-1, -1,' ||
	'TRUNC(SYSDATE),' ||
	'-1, ' ||
	count_list || ' ,exception_group, sum(exception_count), sum(nvl(new_exception_count,exception_count)) ';

      l_def_pref_id := msc_get_name.get_default_pref_id(fnd_global.user_id);
      v_cat_id:= msc_get_name.GET_preference('CATEGORY_SET_ID',l_def_pref_id, v_plan_type);
      v_days := msc_get_name.get_preference('RECOMMENDATION_DAYS',l_def_pref_id, v_plan_type);

       v_ship_cat_id := v_cat_id;

       OPEN date_cur;
       FETCH date_cur INTO v_date, v_plan_type, v_plan_end_date;
       CLOSE date_cur;


       if v_days is null then
          v_days := 30;
       end if;

       if v_plan_type in (8,9) then
          v_date := v_plan_end_date;
       else
          v_date := v_date + v_days;
       end if;

       if v_cat_id is null then
          OPEN cat_cur;
          FETCH cat_cur INTO v_cat_id;
          CLOSE cat_cur;

       end if;

    if (l_plan_node = 1 or
          (p_dept_class is null and
           p_res_group is null ))
       and l_plan_node <>3
       and where_clause is null then

       if l_plan_node = 1 then
         v_cat_id := -1;
         statement := statement || ' FROM msc_item_exception_v1 '||
         ' WHERE 1=1 '||
         ' AND (schedule_date is null or '||
                            ' schedule_date <= :the_date) ' ||
         ' AND -1 = :v_cat_id '||
      	 ' AND plan_id = :plan_id ';
       else

         open inst_c;
         loop
            fetch inst_c into v_id;
            exit when inst_c%NOTFOUND;
            if v_inst_list is null then
               v_inst_list := v_id;
            else
               v_inst_list := v_inst_list || ','|| v_id;
            end if;
         end loop;
         close inst_c;

         if v_inst_list is not null then
            v_inst_list := 'AND sr_instance_id in ('||v_inst_list||')';
         end if;
         statement := statement || ' FROM msc_item_exception_v2 '||
         ' WHERE 1=1 '|| v_inst_list ||
         ' AND (schedule_date is null or '||
                            ' schedule_date <= :the_date) ' ||
         ' AND (category_set_id is null or '||
                            ' category_set_id = :v_cat_id) '||
      	 ' AND plan_id = :plan_id ';
       end if;

    else

       statement := statement || ' FROM msc_item_exception_v '||
                ' WHERE 1=1 '||where_clause ||
                ' AND trunc(sysdate) = :the_date ';

       v_date := trunc(sysdate);
       if instr(where_clause,'PLANNER_CODE') > 0 or
          instr(where_clause,'BUYER_NAME') > 0 or
          instr(where_clause,'ITEM_SEGMENTS') > 0 or
          instr(where_clause,'CATEGORY_NAME') > 0 or
          instr(where_clause,'SUPPLIER_NAME') > 0 then
          statement := statement ||
         ' AND category_set_id = :v_cat_id ';
       else
          statement := statement ||
         ' AND (category_set_id is null or '||
                            ' category_set_id = :v_cat_id) ';
       end if;
       statement := statement ||
              	' AND plan_id = :plan_id ';
    end if;

        IF p_org_id IS NOT NULL THEN
          statement := statement || ' AND organization_id = :org_id '||
		' AND sr_instance_id = :inst_id ';
          ship_stat := ' AND organization_id = '||p_org_id;
        ELSE
          statement := statement || ' AND NVL(:org_id,1) = 1 ' ||
		' AND NVL(:inst_id,1) = 1 ';
        END IF;
        IF p_item_id IS NOT NULL THEN
          statement := statement || ' AND inventory_item_id = :item_id ';
          ship_stat := ship_stat || ' AND inventory_item_id = '||p_item_id;
        ELSE
          statement := statement || ' AND NVL(:item_id,1) = 1 ';
        END IF;
        IF p_planning_grp = '''_COMMON''' THEN
          statement := statement || ' AND planning_group IS NULL '||
		' AND project_id IS NULL ' ||
		' AND rtrim(ltrim(:planning_grp,''''''''),'''''''') = ''_COMMON'' ';
        ELSIF p_planning_grp = '_NONE' THEN
          statement := statement || ' AND planning_group IS NULL '||
		' AND project_id IS NOT NULL ' ||
		' AND :planning_grp = ''_NONE'' ';
        ELSIF p_planning_grp IS NOT NULL THEN
          statement := statement || ' AND planning_group = rtrim(ltrim(:planning_grp,''''''''),'''''''') ';
        ELSE
          statement := statement || ' AND NVL(:planning_grp,''A'') = ''A'' ';
        END IF;
        IF p_project_id IS NOT NULL THEN
          statement := statement || ' AND project_id = :project_id ';
        ELSE
          statement := statement || ' AND NVL(:project_id,1) = 1 ';
        END IF;
        IF p_task_id IS NOT NULL THEN
          statement := statement || ' AND task_id = :task_id ';
        ELSE
          statement := statement || ' AND NVL(:task_id,1) = 1 ';
        END IF;
        IF p_category_name IS NOT NULL THEN
          statement := statement || ' AND category_name = :category_name ';
          ship_stat := ship_stat || ' AND category_name = '||'''||
                                                p_category_name||''';
        ELSE
          statement := statement || ' AND NVL(:category_name,''A'') = ''A'' ';
        END IF;
        IF p_pf_id IS NOT NULL THEN
          statement := statement || ' AND (product_family_id = :pf_id OR inventory_item_id = :pf_id) ';
        ELSE
          statement := statement || ' AND NVL(:pf_id,1) = 1 AND NVL(:pf_id,1) = 1';
        END IF;
        IF p_dept_id IS NOT NULL THEN
          statement := statement || ' AND department_id = :dept_id ';
        ELSE
          statement := statement || ' AND NVL(:dept_id,1) = 1 ';
        END IF;
        IF p_resource_id IS NOT NULL THEN
          statement := statement || ' AND resource_id = :resource_id ';
        ELSE
          statement := statement || ' AND NVL(:resource_id,1) = 1 ';
        END IF;
        IF p_supplier_id IS NOT NULL THEN
          statement := statement || ' AND supplier_id = :supplier_id ';
          ship_stat := ship_stat || ' AND supplier_id = '||p_supplier_id;
        ELSE
          statement := statement || ' AND NVL(:supplier_id,1) = 1 ';
        END IF;
        IF p_version IS NOT NULL THEN
          IF p_version = -1 THEN
            statement := statement || ' AND version IS NULL ' ||
		' AND :version = -1 ';
          ELSE
            statement := statement || ' AND version = :version ';
          END IF;
        ELSE
          statement := statement || ' AND NVL(:version,1) = 1 ';
        END IF;
        IF p_exception_id IS NOT NULL THEN
          IF p_exc_grp_id IS NULL THEN
            l_exc_grp_id := 10;
          ELSE
            l_exc_grp_id := p_exc_grp_id;
          END IF;
          statement := statement || ' AND exception_group = :exc_grp_id ' ||
		' AND exception_type = :exception_id ';
        ELSIF p_exc_grp_id IS NOT NULL THEN
          l_exc_grp_id := p_exc_grp_id;
          statement := statement || ' AND exception_group = :exc_grp_id '||
 		' AND NVL(:exception_id,1) = 1 ';
        ELSE
          statement := statement || ' AND NVL(:exc_grp_id,1) = 1 '||
 		' AND NVL(:exception_id,1) = 1 ';
        END IF;
        IF p_dept_class IN ('''@@@''', '@@@') THEN
        --IF p_dept_class = '''@@@''' THEN
          statement := statement || ' AND department_class IS NULL '||
		' AND rtrim(ltrim(:dept_class,''''''''),'''''''') = ''@@@'' '||
		' AND (department_id IS NOT NULL AND department_id <> -1 '||
		' AND resource_id <> -1 ) ';
        ELSIF p_dept_class IS NOT NULL THEN
          statement := statement || ' AND department_class = rtrim(ltrim(:dept_class,''''''''),'''''''') ';
        ELSE
          statement := statement || ' AND NVL(:dept_class,''A'') = ''A'' ';
        END IF;
        IF p_res_group = '''@@@''' THEN
          statement := statement || ' AND resource_group IS NULL '||
		' AND rtrim(ltrim(:res_group,''''''''),'''''''') = ''@@@'' '||
		' AND (department_id IS NOT NULL AND department_id <> -1 '||
		' AND resource_id <> -1 ) ';
        ELSIF p_res_group IS NOT NULL THEN
          statement := statement || ' AND resource_group = rtrim(ltrim(:res_group,''''''''),'''''''') ';
        ELSE
          statement := statement || ' AND NVL(:res_group,''A'') = ''A'' ';
        END IF;
       statement := statement ||
	' GROUP BY plan_id, exception_group,' ||
	 count_list || ',1';

   EXECUTE IMMEDIATE statement
	USING var_exception_id, v_date,v_cat_id,
                p_plan_id, p_org_id, p_inst_id, p_item_id,
		p_planning_grp, p_project_id, p_task_id, p_category_name,
		p_pf_id, p_pf_id, p_dept_id, p_resource_id, p_supplier_id,
		p_version, l_exc_grp_id, p_exception_id,
		p_dept_class, p_res_group;

  if v_plan_type = 5 then
     if count_list <> 'VERSION,EXCEPTION_TYPE,PLAN_ID' then
        a :=1;
        startPos :=1;
        endPos := instr(count_list||',', ',',1,a);
        while endPos >0 loop
           l_len := endPos - startPos;
           p_column := substr(count_list||',',startPos, l_len);
           if p_column in ('SR_INSTANCE_ID','ORGANIZATION_ID','PLANNER_CODE',
                           'BUYER_NAME','INVENTORY_ITEM_ID','CATEGORY_ID',
                           'CATEGORY_NAME','SUPPLIER_ID') then
                ship_count_list := ship_count_list ||','|| p_column;
                startPos := instr(count_list_mfq||',', ',',1,a-1)+1;
                l_len := instr(count_list_mfq||',', ',',1,a) - startPos;
                p_column := substr(count_list_mfq||',',startPos, l_len);
                ship_list_mfq := ship_list_mfq || ','|| p_column;
           end if;
           a := a+1;
           startPos := endPos+1;
           endPos := instr(count_list||',', ',',1,a);
        end loop;
     end if; -- if count_list <> 'VERSION,EXCEPTION_TYPE,PLAN_ID' then

     statement :=
      ' insert into msc_form_query (query_id, '||
        '  last_update_date, last_updated_by, '||
        '  creation_date, created_by, last_update_login, '||
        '  NUMBER2,NUMBER14, '||
        '  number16, number5, number13 '||ship_list_mfq ||') ' ||
   ' select :var_exception_id,trunc(sysdate),-1,trunc(sysdate),-1,-1, '||
          ' 100,PLAN_ID, 10, count(distinct shipment_id), count(distinct shipment_id) '||ship_count_list ||
          ' from msc_shipment_details_v '||
      ' where plan_id = :p_plan_id '||
        ' and category_set_id = :v_cat_id '||
         ship_stat ||
      '  group by plan_id '||ship_count_list;

   EXECUTE IMMEDIATE statement
	USING var_exception_id, p_plan_id, v_ship_cat_id;

  end if; -- if v_plan_type = 5 then

--   commit;

EXCEPTION
   when no_data_found
          then null;
   when others then
          raise_application_error(-20000,sqlerrm||':'||statement);
END;

PROCEDURE insert_exc_groups(var_exception_id NUMBER) IS

   statement varchar2(20000);

BEGIN
   -- The following SQL statement adds rows for exception group into
   -- the temp table.
   statement :=
	' INSERT INTO msc_form_query' ||
	'(query_id, ' ||
	'last_update_date, ' ||
	'last_updated_by, ' ||
        'last_update_login, ' ||
	'creation_date, ' ||
	'created_by, ' ||
--	'char1, ' || -- plan name
	'number14, ' || -- plan id
        'number1, ' ||  -- version
	'number2, ' ||  -- exception type
	'number16, ' || -- exception group
        'number5, ' ||   -- exception count
	'number3, ' || -- item id
	'number11, ' || -- pf id
	'number4, ' ||  -- org id
	'number15, ' || -- sr instance id
	'number6, ' ||  -- project id
	'number7, ' ||  -- task id
	'number8, ' ||  -- category id
        'number9, ' ||  -- dept id
        'number10, ' ||  -- res id
        'number12, ' ||  -- supplier id
        'number13, ' ||  -- new exception count
	'char2, ' || --planner code
	'char3, ' ||  -- dept class
	'char4, ' || -- planning group
	'char5, ' ||  -- item name
	'char6, ' || -- org code
	'char7, ' ||  -- dept code
        'char8, ' || -- res group
        'char9,  ' ||  -- buyer
        'char10,  ' || -- res code
        'char11,  ' || -- res type code
        'char12,  ' ||  --?
        'char13,  ' || -- version text
        'char14)  ' ||  -- category name
	' SELECT ' ||
	'query_id, ' ||
	'last_update_date, ' ||
	'last_updated_by, ' ||
        'last_update_login, ' ||
	'creation_date, ' ||
	'created_by, ' ||
--	'char1, ' ||
	'number14, ' ||
        'number1, ' ||
	'number16, ' ||
	'NULL, ' ||
        'sum(number5), '||
	'number3, ' ||
	'number11, ' ||
	'number4, ' ||
	'number15, ' ||
	'number6, ' ||
	'number7, ' ||
	'number8, ' ||
        'number9, ' ||
        'number10, ' ||
        'number12, ' ||
        'sum(number13), ' ||
	'char2, ' ||
	'char3, ' ||
	'char4, ' ||
	'char5, ' ||
	'char6, ' ||
	'char7, ' ||
        'char8,  ' ||
        'char9,  ' ||
        'char10,  ' ||
        'char11,  ' ||
        'char12,  ' ||
        'char13,  ' ||
        'char14  ' ||
	' FROM msc_form_query ' ||
	' WHERE query_id = :query_id '||
        ' GROUP BY query_id, last_update_login, last_updated_by, '||
        ' creation_date, created_by, last_update_date, ' ||
	' char1, number14, number1, number16, number3, number11, '||
	' number4, number15, number6, number7, number8, number9, number10, '||
	' number12, char2, char3, char4, char5, '||
	' char6, char7, char8, char9, char10, char11, char12, char13, char14 ';

   EXECUTE IMMEDIATE statement
	USING var_exception_id;
--   commit;

EXCEPTION
   when no_data_found
          then null;
   when others then
          raise_application_error(-20000,sqlerrm||':'||statement);
END;

---------------------------------------------------------------------
-- to save the current exception summary into msc_item_exceptions
---------------------------------------------------------------------
FUNCTION save_as(plan NUMBER) RETURN NUMBER IS
   version_id NUMBER;
BEGIN

   SELECT MAX(NVL(version,0))+1
   INTO version_id
   FROM msc_item_exceptions
   WHERE plan_id= plan;

   INSERT INTO msc_item_exceptions
         (exception_type, inventory_item_id, plan_id, sr_instance_id,
          organization_id, last_update_date, last_updated_by,
          creation_date, created_by, last_update_login, display, request_id,
          program_application_id, program_id,
          program_update_date, exception_count, project_id,
          task_id, version, planning_group,
	  department_id, resource_id, exception_group)
   SELECT exception_type, inventory_item_id, plan_id, sr_instance_id,
	organization_id, last_update_date, last_updated_by,
	creation_date, created_by, last_update_login, display, request_id,
	program_application_id, program_id,
	program_update_date, exception_count, project_Id,
	task_id, version_id, planning_group,
	department_id, resource_id, exception_group
	FROM  msc_item_exceptions
	WHERE version is null
        AND plan_id= plan;
   commit;
   Return version_id;
END save_as;

---------------------------------------------------------------------
-- update mrp-item-exceptions and msc_form_query tables
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

-- update msc_item_exceptions by the their rowid (stored as char8 in
-- msc_form_query) by applying the criteria on the second insert
-- of msc_form_query

    statement :=
        'update msc_item_exceptions
         set display = 2,
         last_update_login = :last_update_login,
         last_updated_by = :last_updated_by,
         last_update_date = sysdate
         where rowid in (
                select chartorowid(char8)
                from msc_form_query
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
-- to lock the row in msc_item_exceptions
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

-- lock the row in msc_item_exceptions by the their rowid (stored as char8 in
-- msc_form_query) by applying the criteria on the second insert
-- of msc_form_query

   statement :=
        'select display
         from  msc_item_exceptions
         where rowid in (
                select chartorowid(char8)
                from msc_form_query
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

END MSC_ACTIONS;

/
