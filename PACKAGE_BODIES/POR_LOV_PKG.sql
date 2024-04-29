--------------------------------------------------------
--  DDL for Package Body POR_LOV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_LOV_PKG" AS
/* $Header: PORLOVB.pls 115.6 2002/11/22 06:42:17 ssuri ship $ */

PROCEDURE REMOVE_QUERY_RESULT(
p_session_id IN NUMBER
) is

BEGIN

DELETE FROM POR_LOV_DISPLAY_RESULTS WHERE SESSION_ID = p_session_id;
COMMIT;

DELETE FROM POR_LOV_RESULT_VALUES WHERE SESSION_ID = p_session_id;
COMMIT;


EXCEPTION
        WHEN OTHERS THEN
        RAISE;
END REMOVE_QUERY_RESULT;


PROCEDURE EXEC_AK_QUERY(
	p_session_id IN NUMBER,
	p_region_app_id IN NUMBER,
	p_region_code IN VARCHAR2,
	p_attribute_app_id IN NUMBER,
	p_attribute_code IN VARCHAR2,
	p_query_column IN VARCHAR2 default null,
	p_query_text IN VARCHAR2 default null,
	c_1 in varchar2 default 'DSTART',
	p_where_clause IN VARCHAR2 default null,
	p_js_where_clause IN VARCHAR2 default null,
	p_start_row in number default 1,
	p_end_row in number default null,
	p_case_sensitive IN VARCHAR2 default 'off',
	p_display_column OUT NOCOPY NUMBER,
	p_value_column OUT NOCOPY NUMBER,
	p_total_row OUT NOCOPY NUMBER
) is



l_responsibility_id number;
l_responsibility_app_id number;
l_user_id number;
l_LOV_foreign_key_name varchar2(30);
l_LOV_region_id number;
l_LOV_region varchar2(30);

l_query_binds         ak_query_pkg.bind_tab;
l_where_clause        varchar2(2000);
l_order_clause        varchar2(2000);
c_where_clause        varchar2(2000);

l_cursor number;
l_result_row_table icx_util.char240_table;
l_display_column number;

l_insert_values varchar2(4000);
l_column_names varchar2(2000);

l_query_size number;
l_max_rows   number;
l_end_row    number;

where_clause        varchar2(2000);
tmp_string varchar2(2000);
tmp_num number;
i number;
j number;
temp_column             varchar2(30);
temp_attribute          varchar2(50);
temp_type               varchar2(1);


cursor lov_query_columns  is
        select  d.COLUMN_NAME,b.ATTRIBUTE_LABEL_LONG,
                substr(a.DATA_TYPE,1,1)
        from    AK_ATTRIBUTES a,
                AK_REGION_ITEMS_VL b,
                AK_REGIONS c,
                AK_OBJECT_ATTRIBUTES d
        where   b.REGION_APPLICATION_ID = l_LOV_region_id
        and     b.REGION_CODE = l_LOV_region
        and     b.NODE_QUERY_FLAG = 'Y'
        and     b.ATTRIBUTE_APPLICATION_ID = d.ATTRIBUTE_APPLICATION_ID
        and     b.ATTRIBUTE_CODE = d.ATTRIBUTE_CODE
        and     b.REGION_APPLICATION_ID = c.REGION_APPLICATION_ID
        and     b.REGION_CODE = c.REGION_CODE
        and     c.DATABASE_OBJECT_NAME = d.DATABASE_OBJECT_NAME
        and     d.ATTRIBUTE_APPLICATION_ID = b.ATTRIBUTE_APPLICATION_ID
        and     d.ATTRIBUTE_CODE = b.ATTRIBUTE_CODE
        and     d.ATTRIBUTE_APPLICATION_ID = a.ATTRIBUTE_APPLICATION_ID
        and     d.ATTRIBUTE_CODE = a.ATTRIBUTE_CODE
        order by b.DISPLAY_SEQUENCE;


BEGIN

DELETE FROM POR_LOV_DISPLAY_RESULTS WHERE SESSION_ID = p_session_id;
COMMIT;

DELETE FROM POR_LOV_RESULT_VALUES WHERE SESSION_ID = p_session_id;
COMMIT;


  select USER_ID, RESPONSIBILITY_ID, RESPONSIBILITY_APPLICATION_ID
  into l_user_id, l_responsibility_id, l_responsibility_app_id
  from ICX_SESSIONS
  where SESSION_ID = p_session_id;

 fnd_global.APPS_INITIALIZE(l_user_id, l_responsibility_id, l_responsibility_app_id);

  -- Look up the LOV region being called
  select LOV_FOREIGN_KEY_NAME, LOV_REGION_APPLICATION_ID, LOV_REGION_CODE
  into  l_LOV_foreign_key_name, l_LOV_region_id, l_LOV_region
  from  AK_REGION_ITEMS
  where REGION_APPLICATION_ID = p_region_app_id
  and   REGION_CODE = p_region_code
  and   ATTRIBUTE_APPLICATION_ID = p_attribute_app_id
  and   ATTRIBUTE_CODE = p_attribute_code;


    -- Look up the number of rows to display
    select QUERY_SET, MAX_ROWS
    into l_query_size, l_max_rows
    from ICX_PARAMETERS;
/* Added session_id to icx_call wrto bug 2675309 **/
/* suggested by Neal **/
/* This avoids any mod_sql commands when invoked from java **/

  -- Combine two where clauses
  if p_where_clause is not null then
    if p_js_where_clause is not null then
      c_where_clause := icx_call.encrypt2(icx_call.decrypt2(p_where_clause,p_session_id)||' and '||replace(p_js_where_clause,'^@~^',' '),p_session_id);
    else
      c_where_clause := c_where_clause;
    end if;
  else
    if p_js_where_clause is not null then
      c_where_clause := icx_call.encrypt2(replace(p_js_where_clause,'^@~^',' '),p_session_id);
    end if;
  end if;

 -- Perform Object Navigator query

        -- Call whereSegment to construct where clause
        if p_case_sensitive = 'on' then
          where_clause := icx_on_utilities.whereSegment
                                (a_1  =>  p_query_column,
                                 c_1  =>  c_1,
                                 i_1  =>  p_query_text,
                                 m    =>  p_case_sensitive);
        else
          where_clause := icx_on_utilities.whereSegment
                                (a_1  =>  p_query_column,
                                 c_1  =>  c_1,
                                 i_1  =>  p_query_text);
        end if;


        -- unpack where clause to use bind variables
        icx_on_utilities.unpack_whereSegment(where_clause,l_where_clause,l_query_binds);

/* Added session_id to icx_call wrto bug 2675309 **/
/* suggested by Neal **/
/* This avoids any mod_sql commands when invoked from java **/

        -- Add where clause LOV parameter to generated where clause
        if c_where_clause is not null then
          if l_where_clause is null then
            l_where_clause := icx_call.decrypt2(c_where_clause,p_session_id);
 else
            l_where_clause := l_where_clause||' and '||icx_call.decrypt2(c_where_clause,p_session_id);
          end if;
        end if;

        -- Create order clause
        open lov_query_columns;
        i := 0;
        loop

            fetch lov_query_columns into temp_column, temp_attribute, temp_type;

            exit when lov_query_columns%NOTFOUND;
            i := i + 1;
            if substr(p_query_column,2,31) = temp_column then
                l_order_clause := i;
                exit;
            end if;
        end loop;
        close lov_query_columns;

        -- figure end row value to display */
        if p_end_row is null then
            l_end_row := l_query_size;
        else
            l_end_row := p_end_row;
        end if;



        ak_query_pkg.exec_query (
             P_PARENT_REGION_APPL_ID => l_LOV_region_id         ,
             P_PARENT_REGION_CODE    => l_LOV_region            ,
             P_WHERE_CLAUSE          => l_where_clause          ,
             P_WHERE_BINDS           => l_query_binds           ,
             P_ORDER_BY_CLAUSE       => l_order_clause            ,
             P_RESPONSIBILITY_ID     => l_responsibility_id     ,
             P_USER_ID               => l_user_id               ,
             P_RETURN_PARENTS        => 'T'                     ,
             P_RETURN_CHILDREN       => 'F'                     ,
             P_RANGE_LOW             => p_start_row               ,
             P_RANGE_HIGH            => l_end_row               ,
             P_MAX_ROWS              => 1000);


p_total_row := ak_query_pkg.g_regions_table(0).total_result_count;

l_insert_values := '';
l_column_names := '';
l_display_column := 0;
j := 0;
for j in 0..ak_query_pkg.g_items_table.COUNT-1 loop

                if (l_display_column=0) then
                        l_insert_values := l_insert_values ||
                                ':VALUE' || to_char(j+1);
                        l_column_names := l_column_names || 'VALUE' || to_char(j+1);
                else
                        l_insert_values := l_insert_values || ', ' ||
                                ':VALUE' || to_char(j+1);
                        l_column_names := l_column_names ||', ' || 'VALUE' || to_char(j+1);
                end if;
                l_display_column := l_display_column + 1;
end loop;

        l_column_names := '(SESSION_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE, TYPE,' || l_column_names || ')';
        l_insert_values := '(:SESSION_ID, :LAST_UPDATED_BY, :LAST_UPDATE_DATE, :TYPE, ' || l_insert_values || ')';
        tmp_string := 'INSERT INTO POR_LOV_RESULT_VALUES ' || l_column_names ||' VALUES ' || l_insert_values;

        l_cursor := dbms_sql.open_cursor;
        dbms_sql.parse(l_cursor, tmp_string, dbms_sql.v7);

	dbms_sql.bind_variable(l_cursor, ':SESSION_ID', p_session_id);
	dbms_sql.bind_variable(l_cursor, ':LAST_UPDATED_BY', l_user_id);
	dbms_sql.bind_variable(l_cursor, ':LAST_UPDATE_DATE', sysdate);
	dbms_sql.bind_variable(l_cursor, ':TYPE', 'CODE');
	for j in 0..ak_query_pkg.g_items_table.COUNT-1 loop
		dbms_sql.bind_variable(l_cursor, ':VALUE'|| to_char(j+1) , ak_query_pkg.g_items_table(j).attribute_code );
	end loop;

        tmp_num := dbms_sql.execute(l_cursor);
	dbms_sql.close_cursor(l_cursor);



i := 0;
j := 0;
for i in 0..ak_query_pkg.g_results_table.COUNT-1 loop
        icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(i), l_result_row_table);
        l_insert_values := '';
        l_column_names := '';
        l_display_column := 0;
        for j in 0..ak_query_pkg.g_items_table.COUNT-1 loop

                        if (l_display_column=0) then
                                l_insert_values := l_insert_values || ':VALUE' || to_char(j+1);
                                l_column_names := l_column_names || 'VALUE' || to_char(j+1);
                        else
                                l_insert_values := l_insert_values || ', ' || ':VALUE' || to_char(j+1);
                                l_column_names := l_column_names ||', ' || 'VALUE' || to_char(j+1);

                        end if;

                        l_display_column := l_display_column + 1;
        end loop;

        l_column_names := '(SESSION_ID, SEQUENCE, LAST_UPDATED_BY, LAST_UPDATE_DATE, TYPE, ' || l_column_names || ')';
        l_insert_values := '(:SESSION_ID, :SEQUENCE, :LAST_UPDATED_BY, :LAST_UPDATE_DATE, :TYPE,' || l_insert_values ||')';
        tmp_string := 'INSERT INTO POR_LOV_RESULT_VALUES ' || l_column_names ||' VALUES ' || l_insert_values;

        l_cursor := dbms_sql.open_cursor;
        dbms_sql.parse(l_cursor, tmp_string, dbms_sql.v7);

	dbms_sql.bind_variable(l_cursor, ':SESSION_ID', p_session_id);
	dbms_sql.bind_variable(l_cursor, ':SEQUENCE', i);
	dbms_sql.bind_variable(l_cursor, ':LAST_UPDATED_BY', l_user_id);
	dbms_sql.bind_variable(l_cursor, ':LAST_UPDATE_DATE', sysdate);
	dbms_sql.bind_variable(l_cursor, ':TYPE', 'VALUE');
	for j in 0..ak_query_pkg.g_items_table.COUNT-1 loop
		dbms_sql.bind_variable(l_cursor, ':VALUE' || to_char(j+1), l_result_row_table(ak_query_pkg.g_items_table(j).value_id));
	end loop;

        tmp_num := dbms_sql.execute(l_cursor);
	dbms_sql.close_cursor(l_cursor);

end loop;

p_value_column := l_display_column;

l_insert_values := '';
l_column_names := '';
l_display_column := 0;
j := 0;
for j in 0..ak_query_pkg.g_items_table.COUNT-1 loop
	if ak_query_pkg.g_items_table(j).secured_column = 'F' and
	   ak_query_pkg.g_items_table(j).node_display_flag = 'Y' then

		if (l_display_column=0) then
			l_insert_values := l_insert_values || ':VALUE' || to_char(j+1);
			l_column_names := l_column_names || 'VALUE' || to_char(j+1);
		else
			l_insert_values := l_insert_values || ', ' || ':VALUE' || to_char(j+1);
			l_column_names := l_column_names ||', ' || 'VALUE' || to_char(j+1);
		end if;
		l_display_column := l_display_column + 1;
	end if;
end loop;

        l_column_names := '(SESSION_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE, TYPE, ' || l_column_names || ')';
        l_insert_values := '(:SESSION_ID, :LAST_UPDATED_BY, :LAST_UPDATE_DATE, :TYPE, ' || l_insert_values || ')';
        tmp_string := 'INSERT INTO POR_LOV_DISPLAY_RESULTS ' || l_column_names ||' VALUES ' || l_insert_values;

        l_cursor := dbms_sql.open_cursor;
        dbms_sql.parse(l_cursor, tmp_string, dbms_sql.v7);

	dbms_sql.bind_variable(l_cursor, ':SESSION_ID', p_session_id);
        dbms_sql.bind_variable(l_cursor, ':LAST_UPDATED_BY', l_user_id);
        dbms_sql.bind_variable(l_cursor, ':LAST_UPDATE_DATE', sysdate);
        dbms_sql.bind_variable(l_cursor, ':TYPE', 'TITLE');

	for j in 0..ak_query_pkg.g_items_table.COUNT-1 loop
		if ak_query_pkg.g_items_table(j).secured_column = 'F' and
	   		ak_query_pkg.g_items_table(j).node_display_flag = 'Y' then
                dbms_sql.bind_variable(l_cursor, ':VALUE' || to_char(j+1), ak_query_pkg.g_items_table(j).attribute_label_long);
		end if;
        end loop;

        tmp_num := dbms_sql.execute(l_cursor);
	dbms_sql.close_cursor(l_cursor);

i := 0;
j := 0;
for i in 0..ak_query_pkg.g_results_table.COUNT-1 loop
        icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(i), l_result_row_table);
        l_insert_values := '';
        l_column_names := '';
        l_display_column := 0;
        for j in 0..ak_query_pkg.g_items_table.COUNT-1 loop
                if ak_query_pkg.g_items_table(j).secured_column = 'F' and
                   ak_query_pkg.g_items_table(j).node_display_flag = 'Y' then

                        if (l_display_column=0) then
                                l_insert_values := l_insert_values || ':VALUE' || to_char(j+1);
                                l_column_names := l_column_names || 'VALUE' || to_char(j+1);
                        else
                                l_insert_values := l_insert_values || ', ' || ':VALUE' || to_char(j+1);
                                l_column_names := l_column_names ||', ' || 'VALUE' || to_char(j+1);

                        end if;

                        l_display_column := l_display_column + 1;
                end if;
        end loop;

        l_column_names := '(SESSION_ID, SEQUENCE, LAST_UPDATED_BY, LAST_UPDATE_DATE, TYPE, ' || l_column_names || ')';
        l_insert_values := '(:SESSION_ID, :SEQUENCE, :LAST_UPDATED_BY, :LAST_UPDATE_DATE, :TYPE, ' || l_insert_values || ')';
        tmp_string := 'INSERT INTO POR_LOV_DISPLAY_RESULTS ' || l_column_names ||' VALUES ' || l_insert_values;

        l_cursor := dbms_sql.open_cursor;
        dbms_sql.parse(l_cursor, tmp_string, dbms_sql.v7);

	dbms_sql.bind_variable(l_cursor, ':SESSION_ID', p_session_id);
	dbms_sql.bind_variable(l_cursor, ':SEQUENCE', i);
        dbms_sql.bind_variable(l_cursor, ':LAST_UPDATED_BY', l_user_id);
        dbms_sql.bind_variable(l_cursor, ':LAST_UPDATE_DATE', sysdate);
        dbms_sql.bind_variable(l_cursor, ':TYPE', 'VALUE');

	for j in 0..ak_query_pkg.g_items_table.COUNT-1 loop
                if ak_query_pkg.g_items_table(j).secured_column = 'F' and
                   ak_query_pkg.g_items_table(j).node_display_flag = 'Y' then
			dbms_sql.bind_variable(l_cursor, ':VALUE' || to_char(j+1),l_result_row_table(ak_query_pkg.g_items_table(j).value_id));
		end if;
	end loop;

        tmp_num := dbms_sql.execute(l_cursor);
	dbms_sql.close_cursor(l_cursor);

end loop;

	p_display_column := l_display_column;

EXCEPTION
        WHEN OTHERS THEN
        RAISE;
END EXEC_AK_QUERY;


END POR_LOV_PKG;

/
