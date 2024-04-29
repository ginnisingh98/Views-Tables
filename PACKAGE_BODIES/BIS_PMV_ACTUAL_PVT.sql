--------------------------------------------------------
--  DDL for Package Body BIS_PMV_ACTUAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_ACTUAL_PVT" as
/* $Header: BISVACLB.pls 120.1 2006/03/28 12:52:27 nbarik noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.48=120.1):~PROD:~PATH:~FILE

g_debug_on boolean := false;

PROCEDURE GET_ACTUAL_VALUE
(p_region_code              IN  VARCHAR2
,p_function_name            IN  VARCHAR2 DEFAULT NULL
,p_user_id                  IN  VARCHAR2 DEFAULT NULL
,p_responsibility_id        IN  VARCHAR2 DEFAULT NULL
,p_time_parameter           IN  BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE
,p_parameters               IN  BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
,p_param_ids                IN  VARCHAR2 DEFAULT 'N'
,p_actual_attribute_code    IN  VARCHAR2
,p_compareto_attribute_code IN  VARCHAR2 DEFAULT NULL
,x_actual_value             OUT NOCOPY VARCHAR2
,x_compareto_value          OUT NOCOPY VARCHAR2
,x_return_status            OUT NOCOPY VARCHAR2
,x_msg_count                OUT NOCOPY NUMBER
,x_msg_data                 OUT NOCOPY VARCHAR2
) IS
 l_function_name varchar2(2000);
 l_user_id varchar2(2000);
 l_session_id varchar2(2000);
 l_return_status varchar2(2000);
 l_msg_count number;
 l_msg_data varchar2(32000);
 l_debug_msg varchar2(32000);
BEGIN
  /*
  if fnd_profile.value('BIS_SQL_TRACE')= 'Y' then
     g_debug_on := true;
  else
     g_debug_on := false;

  end if;
  */
  if p_function_name is null then
     l_function_name := p_region_code;
  else
     l_function_name := p_function_name;
  end if;

  if p_user_id is null then
    l_user_id := 'PMV_ACTUAL';
  else
    l_user_id := p_user_id;
  end if;

  select 'ACTUAL_'||bis_notification_id_s.nextval into l_session_id from dual;

    STORE_PARAMETERS(p_region_code => p_region_code
                    ,p_function_name => l_function_name
                    ,p_user_id       => l_user_id
                    ,p_session_id    => l_session_id
                    ,p_Responsibility_id => p_responsibility_id
                    ,p_time_parameter   => p_time_parameter
                    ,p_parameters        => p_parameters
                    ,p_param_ids         => p_param_ids
                    ,x_return_Status     => l_return_Status
                    ,x_msg_count         => l_msg_count
                    ,x_msg_data          => l_msg_data
                    );

    if g_debug_on then
       l_debug_msg := l_debug_msg || 'BIS_PMV_ACTUAL_PVT.STORE_PARAMETERS: '||l_return_status||'*'||l_msg_data;
/*
       FND_MSG_PUB.Add_Exc_Msg(p_pkg_name => 'BIS_PMV_ACTUAL_PVT',
                               p_procedure_name => 'STORE_PARAMETERS',
                               p_error_text => 'status and msg: '||l_return_status||'*'|| l_msg_data);
*/
    end if;

    BIS_PMV_ACTUAL_PVT.GET_ACTUAL_VALUE_PLSQL
    (p_region_code      => p_region_code
	,p_function_name  => l_function_name
	,p_user_id        => l_user_id
	,p_responsibility_id => p_responsibility_id
	,p_session_id       => l_session_id
	,p_actual_attribute_code => p_actual_Attribute_code
	,p_compare_to_attribute_code  => p_compareto_Attribute_code
	,x_actual_value      => x_actual_value
	,x_compareto_value   => x_compareto_value
	,x_return_Status     => x_return_Status
	,x_msg_count         => x_msg_count
	,x_msg_data          => x_msg_data
    );

    if g_debug_on then
/*
       FND_MSG_PUB.Add_Exc_Msg(p_pkg_name => 'BIS_PMV_ACTUAL_PVT',
                               p_procedure_name => 'GET_ACTUAL_VALUE_PLSQL',
                               p_error_text => 'status and msg: '||x_return_status||'*'|| x_msg_data);
*/
       x_msg_data := l_debug_msg || 'BIS_PMV_ACTUAL_PVT.GET_ACTUAL_PLSQL: '||x_return_status||'*'||x_msg_data;
    end if;

END GET_ACTUAL_VALUE;

PROCEDURE GET_ACTUAL_VALUE_PLSQL
(p_region_code     IN VARCHAR2
,p_function_name   IN VARCHAR2
,p_user_id         IN VARCHAR2
,p_responsibility_id IN VARCHAR2
,p_session_id        IN VARCHAR2
,p_actual_attribute_code IN VARCHAR2
,p_compare_to_attribute_code IN VARCHAR2
,x_actual_value             OUT NOCOPY VARCHAR2
,x_compareto_value           OUT NOCOPY VARCHAR2
,x_return_Status             OUT NOCOPY VARCHAR2
,x_msg_count                 OUT NOCOPY NUMBER
,x_msg_data                  OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_plsql IS
  SELECT attribute8 plsql_function
  from ak_Regions
  where region_code = p_region_Code;

  CURSOR base_column_cursor(cpAttributeCode varchar2) IS
  SELECT attribute3 base_column
    FROM ak_region_items
   WHERE region_code = p_region_code
     AND attribute_code = cpAttributeCode;

  CURSOR column_items_cursor IS
  SELECT attribute_code, attribute3 base_column
    FROM ak_region_items
   WHERE region_code = p_region_code
     AND nested_region_code is null
     AND (   (attribute1 = 'MEASURE')
          or (attribute1 = 'MEASURE_NOTARGET')
          or (attribute1 is null and node_query_flag = 'N')
          or (attribute1 is null and node_display_flag = 'Y')
         );

  TYPE query_cur_type IS REF CURSOR;
  query_cursor   query_cur_type;

  l_query_string      VARCHAR2(32000);
  l_viewby_table     VARCHAR2(32000);
  l_target_alias     VARCHAR2(50);
  l_has_target       VARCHAR2(1);
  l_cursor           integer;
  l_desc_tab         dbms_sql.desc_tab;
  l_attr_codes       BISVIEWER.t_char;
  l_attr_values      BISVIEWER.t_char;
  l_actual_value     varchar2(2000);
  l_compareto_value  varchar2(2000);
  l_actual_val_cnt   number := 0;
  l_compareto_val_cnt  number:=0;
  l_col_count          integer;
  ignore               integer;
  l_row_found         integer := 0;
  l_bind_variables    varchar2(32000);
  l_plsql_bind_variables    varchar2(32000);
  l_bind_var_tbl      BISVIEWER.t_char;
  l_bind_indexes      varchar2(32000);
  --l_bind_index_tbl    BISVIEWER.t_char;

  l_startIndex        NUMBER;
  l_endIndex          NUMBER;
  l_bind_var          VARCHAR2(32000);
  l_tab_index       NUMBER := 1;
  l_bind_col          VARCHAR2(2000);

  l_actual_base_column varchar2(2000);
  l_compareto_base_column varchar2(2000);
  l_actual_formula varchar2(2000);
  --l_temp_actual_formula varchar2(2000);
  l_compareto_formula varchar2(2000);
  --l_temp_compareto_formula varchar2(2000);
  l_sql varchar2(2000);
  l_base_columns BISVIEWER.t_char;
  l_actual_attr_codes BISVIEWER.t_char;
  l_compareto_attr_codes BISVIEWER.t_char;
  l_actual_base_columns BISVIEWER.t_char;
  l_compareto_base_columns BISVIEWER.t_char;
  l_sorted_actual_base_columns BISVIEWER.t_char;
  l_sorted_compare_base_columns BISVIEWER.t_char;
  l_actual_values BISVIEWER.t_char;
  l_compareto_values BISVIEWER.t_char;
  l_calculate_actual boolean := false;
  l_calculate_compareto boolean := false;
  l_actual_count number;
  l_compareto_count number;
  l_actual_col_index BISVIEWER.t_num;
  l_compareto_col_index BISVIEWER.t_num;

  l_temp_viewby_value   varchar2(32000);
  l_debug_msg varchar2(32000);
  l_plsql_function varchar2(2000);
  l_bind_datatypes varchar2(32000);
BEGIN

   if (c_plsql%ISOPEN) THEN
      CLOSE c_plsql;
   end if;
   OPEN c_plsql;
   FETCH c_plsql INTO l_plsql_function;
   CLOSE c_plsql;

   -- get the base column definitions
   if base_column_cursor%ISOPEN then
      close base_column_cursor;
   end if;

   open base_column_cursor(p_actual_attribute_code);
   fetch base_column_cursor into l_actual_base_column;
   close base_column_cursor;
   --dbms_output.put_line('l_actual_base_column:'||l_actual_base_column);

   open base_column_cursor(p_compare_to_attribute_code);
   fetch base_column_cursor into l_compareto_base_column;
   close base_column_cursor;
   --dbms_output.put_line('l_compareto_base_column:'||l_compareto_base_column);

   -- check to see if it's a calculation measure
   if (substr(l_actual_base_column,1,1)='"'
   and (l_plsql_function is not null or
        (l_plsql_function is null and instr(l_actual_base_column,'/') > 0))) then
   --if (substr(l_actual_base_column,1,1)='"' and instr(l_actual_base_column,'/') > 0) then
      l_calculate_actual := true;
      --dbms_output.put_line('actual is calcalation measure');
      l_actual_formula := substr(l_actual_base_column, 2, length(l_actual_base_column)-2);
   end if;

   if (substr(l_compareto_base_column,1,1)='"'
   and (l_plsql_function is not null or
        (l_plsql_function is null and instr(l_compareto_base_column,'/') > 0))) then
   --if (substr(l_compareto_base_column,1,1)='"' and instr(l_compareto_base_column,'/') > 0) then
      l_calculate_compareto := true;
      --dbms_output.put_line('compareto is calcalation measure');
      l_compareto_formula := substr(l_compareto_base_column, 2, length(l_compareto_base_column)-2);
   end if;

   -- set up corresponding info if it's a calculation measure
   if ((l_calculate_actual) or (l_calculate_compareto)) then

      -- get all of the table column attribute codes and base column definitions
      if column_items_cursor%ISOPEN then
         close column_items_cursor;
      end if;
      open column_items_cursor;
      fetch column_items_cursor bulk collect into l_attr_codes, l_base_columns;
      close column_items_cursor;

      -- sort the base columns in descending orders along with the attribute codes
      BIS_PMV_UTIL.sortAttributeCode
      (p_attributeCode_tbl => l_base_columns
      ,p_attributeValue_tbl => l_attr_codes
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data
      );

      if g_debug_on then
         l_debug_msg := l_debug_msg || 'BIS_PMV_UTIL.sortAttributeCode: '||x_return_status||'*'||x_msg_data;
/*
         FND_MSG_PUB.Add_Exc_Msg(p_pkg_name => 'BIS_PMV_UTIL',
                                 p_procedure_name => 'sortAttributeCode',
                                 p_error_text => 'status and msg: '||x_return_status||'*'|| x_msg_data);
*/
      end if;

      -- find out which attribute codes are used in the calculation formula
      l_actual_count := 0;
      l_compareto_count := 0;
      if (l_base_columns.COUNT > 0) then
      for i in l_base_columns.FIRST..l_base_columns.LAST loop
          --dbms_output.put_line('attr_code'||i||': '||l_attr_codes(i));
          --dbms_output.put_line('base_column'||i||': '||l_base_columns(i));
          -- for actual calculation
          if (l_calculate_actual) then
              if (l_actual_base_column <> l_base_columns(i)) then
                  if (instr(l_actual_base_column, l_base_columns(i)) > 0) then
                      l_actual_count := l_actual_count + 1;
                      l_actual_base_columns(l_actual_count) := l_base_columns(i);
                      l_actual_attr_codes(l_actual_count) := l_attr_codes(i);
                      l_actual_base_column := replace(l_actual_base_column, l_base_columns(i));
                  end if;
              end if;
          end if;
          -- for compareto calculation
          if (l_calculate_compareto) then
              if (l_compareto_base_column <> l_base_columns(i)) then
                  if (instr(l_compareto_base_column, l_base_columns(i)) > 0) then
                      l_compareto_count := l_compareto_count + 1;
                      l_compareto_base_columns(l_compareto_count) := l_base_columns(i);
                      l_compareto_attr_codes(l_compareto_count) := l_attr_codes(i);
                      l_compareto_base_column := replace(l_compareto_base_column, l_base_columns(i));
                  end if;
              end if;
          end if;
      end loop;
     end if;
   end if; -- end of setting up calculation measure infos

   x_return_Status := FND_API.G_RET_STS_SUCCESS;
   -- get main query
   BIS_PMV_QUERY_PVT.getQuerySql(
   p_Region_Code => p_region_code,
   p_function_name  => p_function_name,
   p_user_id => p_user_id ,
   p_session_id => p_session_id,
   p_resp_id => p_responsibility_id,
   p_page_id => null,
   p_schedule_id => null,
   p_sort_attribute => null,
   p_sort_direction => null,
   p_source        => 'ACTUAL',
   x_sql => l_query_string,
   x_target_alias => l_target_alias,
   x_has_target  => l_has_target,
   x_viewby_table => l_viewby_table,
   x_return_status => x_return_status,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data,
   x_bind_variables => l_bind_variables,
   x_plsql_bind_variables => l_plsql_bind_variables,
   x_bind_indexes => l_bind_indexes,
   x_bind_datatypes => l_bind_Datatypes,
   x_view_by_value => l_temp_viewby_Value);

   l_query_String := replace(l_query_String, ':', ':x');

   if g_debug_on then
      l_debug_msg := l_debug_msg ||'BIS_PMV_QUERY_PVT.getQuerySql: '||x_return_status||'*'||x_msg_data
                                 ||' sql:'||l_query_string||' bind variables:'||l_plsql_bind_variables
                                 ||' bind indexes:'||l_bind_indexes;
/*
      FND_MSG_PUB.Add_Exc_Msg(p_pkg_name => 'BIS_PMV_QUERY_PVT',
                              p_procedure_name => 'getQuerySql',
                              p_error_text => 'status and msg: '||x_return_status||'*'|| x_msg_data
                                            ||' sql:'||l_query_string||' bind variables:'||l_plsql_bind_variables
);
*/
   end if;

   -- get bind variables in a table.
   if (length(l_plsql_bind_variables) > 0) then
      SETUP_BIND_VARIABLES(
      p_bind_variables => l_plsql_bind_variables,
      x_bind_var_tbl => l_bind_var_tbl);
   end if;

/*
   -- get bind indexes in a table.
   if (length(l_bind_indexes) > 0) then
      SETUP_BIND_VARIABLES(
      p_bind_variables => l_bind_indexes,
      x_bind_var_tbl => l_bind_index_tbl);
   end if;
*/

   l_cursor := dbms_sql.open_cursor;
   dbms_sql.parse(l_cursor, l_query_string, DBMS_SQL.native);

   -- set up bind variables for cursor
   if (l_bind_var_tbl.COUNT > 0) then   --Added the if for Bug Fix 2394713
   for i in l_bind_var_tbl.FIRST..l_bind_var_tbl.LAST loop
       l_bind_col := ':x'|| i;
       if (l_bind_var_tbl(i) is null or length(l_bind_Var_Tbl(i)) = 0) then
          l_bind_var := null;
       else
          if (substr(l_bind_var_tbl(i),1,1) = '''' and substr(l_bind_var_tbl(i), length(l_bind_Var_tbl(i)),1) = '''') then
             l_bind_var := substr(l_bind_Var_tbl(i),2, length(l_bind_Var_tbl(i))-2);
          else
             l_bind_Var := l_bind_Var_tbl(i);
          end if;
       end if;
       commit;
       dbms_sql.bind_variable(l_cursor, l_bind_col, l_bind_var);
   end loop;
   end if;

   -- find out column indexes of the main query for all the needed attribute codes
   dbms_sql.describe_columns(l_cursor, l_col_count, l_desc_tab);
   l_actual_count := 0;
   l_compareto_count := 0;
   for i in 1..l_col_count loop
      --dbms_output.put_line('alias: '||l_desc_tab(i).col_name);
      if (l_calculate_actual) then
        if (l_actual_attr_codes.COUNT > 0) then
        for j in l_actual_attr_codes.FIRST..l_actual_attr_codes.LAST loop
           if (l_desc_tab(i).col_name = l_actual_attr_codes(j)) then
             l_actual_count := l_actual_count + 1;
             l_actual_col_index(l_actual_count) := i;
             l_sorted_actual_base_columns(l_actual_count) := l_actual_base_columns(j);
           end if;
        end loop;
        end if;
      else
        if (l_desc_tab(i).col_name = p_actual_attribute_code) then
             l_Actual_val_cnt := i;
        end if;
      end if;

      if (l_calculate_compareto) then
        if (l_Compareto_attr_codes.COUNT > 0) then
        for j in l_compareto_attr_codes.FIRST..l_compareto_attr_codes.LAST loop
           if (l_desc_tab(i).col_name = l_compareto_attr_codes(j)) then
             l_compareto_count := l_compareto_count + 1;
             l_compareto_col_index(l_compareto_count) := i;
             l_sorted_compare_base_columns(l_compareto_count) := l_compareto_base_columns(j);
           end if;
        end loop;
        end if;
      else
        if (l_desc_tab(i).col_name = p_compare_to_attribute_code) then
             l_compareto_val_cnt := i;
        end if;
      end if;
   end loop;

   -- define columns for cursor
   if (l_calculate_actual) then
      SORTBY_BASE_COLUMN_LENGTH(p_table1 => l_sorted_actual_base_columns
                               ,p_table2 => l_actual_attr_codes
                               ,p_table3 => l_actual_col_index
                               ,x_return_status => x_return_status
                               ,x_msg_count => x_msg_count
                               ,x_msg_data => x_msg_data
                               );

      for i in 1..l_actual_count loop
          dbms_sql.define_column(l_cursor, l_actual_col_index(i), l_actual_value, 200);
      end loop;
   else
      if (l_actual_val_cnt > 0) then
          dbms_sql.define_column(l_cursor, l_actual_val_cnt, l_actual_value, 200);
      end if;
   end if;

   if (l_calculate_compareto) then
      SORTBY_BASE_COLUMN_LENGTH(p_table1 => l_sorted_compare_base_columns
                               ,p_table2 => l_compareto_attr_codes
                               ,p_table3 => l_compareto_col_index
                               ,x_return_status => x_return_status
                               ,x_msg_count => x_msg_count
                               ,x_msg_data => x_msg_data
                               );

      for i in 1..l_compareto_count loop
        dbms_sql.define_column(l_cursor, l_compareto_col_index(i), l_compareto_value, 200);
      end loop;
   else
      if (l_compareto_val_cnt > 0) then
         dbms_sql.define_column(l_cursor, l_compareto_val_cnt, l_compareto_value, 200);
      end if;
   end if;

   --dbms_output.put_line('before executing the cursor');
   -- execute the cursor and get the values
   ignore := dbms_sql.execute(l_cursor);
   --dbms_output.put_line('after executing the cursor');
   loop
      if (dbms_sql.fetch_rows(l_cursor) = 0) then
          exit;
      end if;
      l_row_found := l_row_found+1;

      if (l_calculate_actual) then
         --l_temp_actual_formula := l_actual_formula;
         for i in 1..l_actual_count loop
            dbms_sql.column_value(l_cursor, l_actual_col_index(i), l_actual_values(i));
         end loop;

          GET_CALCULATED_VALUE
         (p_formula => l_Actual_formula
         ,p_measure_base_columns => l_sorted_actual_base_columns
         ,p_measure_values => l_actual_values
         ,x_calculated_value => l_actual_value
         );

/*
          for i in 1..l_actual_count loop
             l_temp_actual_formula := replace(l_temp_actual_formula, l_actual_base_columns(i), l_actual_values(i));
          end loop;
          l_sql := 'select '||l_temp_actual_formula||' from dual';
          begin
            execute immediate l_sql into l_actual_value;
          exception
          when others then
            l_actual_value := '0';
          end;
*/
      else
         if (l_actual_val_cnt > 0) then
            dbms_sql.column_value(l_cursor, l_actual_val_cnt, l_actual_value);
         end if;
      end if;

      if (l_calculate_compareto) then
          --l_temp_compareto_formula := l_compareto_formula;
         for i in 1..l_compareto_count loop
            dbms_sql.column_value(l_cursor, l_compareto_col_index(i), l_compareto_values(i));
         end loop;

          GET_CALCULATED_VALUE
         (p_formula => l_compareto_formula
         ,p_measure_base_columns => l_sorted_compare_base_columns
         ,p_measure_values => l_compareto_values
         ,x_calculated_value => l_compareto_value
         );

/*
          for i in 1..l_compareto_count loop
             l_temp_compareto_formula := replace(l_temp_compareto_formula, l_compareto_base_columns(i), l_compareto_values(i));
          end loop;
          l_sql := 'select '||l_temp_compareto_formula||' from dual';
          begin
            execute immediate l_sql into l_compareto_value;
          exception
          when others then
            l_compareto_value := '0';
          end;
*/
      else
         if (l_compareto_val_cnt > 0) then
            dbms_sql.column_value(l_cursor, l_compareto_val_cnt, l_compareto_value);
         end if;
      end if;

    end loop;
    dbms_sql.close_cursor(l_cursor);

    if (l_row_found <= 0) then
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_msg_data := 'NO DATA FOUND';
    end if;

    if (l_actual_val_cnt <=0) and not(l_calculate_actual) then
       x_return_Status := FND_API.G_RET_STS_ERROR;
       x_msg_data := 'Invalid attribute code';
    end if;

    x_msg_data := l_debug_msg || x_msg_data;

    x_actual_value := l_actual_value;
    x_compareto_value := l_compareto_value;
exception
when others then
     if (dbms_sql.IS_OPEN(l_cursor)) then
         dbms_sql.close_cursor(l_cursor);
     end if;
     x_return_status := FND_API.G_RET_STS_ERROR;
END;
-- Overloaded procedure to return a table of records for SONAR KPI portlet
PROCEDURE GET_ACTUAL_VALUE
(p_region_code              IN  VARCHAR2
,p_function_name            IN  VARCHAR2 DEFAULT NULL
,p_user_id                  IN  VARCHAR2 DEFAULT NULL
,p_page_id                  IN  VARCHAR2 DEFAULT NULL
,p_responsibility_id        IN  VARCHAR2 DEFAULT NULL
,p_time_parameter           IN  BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE
,p_parameters               IN  BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
,p_param_ids                IN  VARCHAR2 DEFAULT 'N'
,p_actual_attribute_code    IN  VARCHAR2
,p_compareto_attribute_code IN  VARCHAR2 DEFAULT NULL
,p_ranking_level            IN  VARCHAR2
,x_actual_value             OUT NOCOPY BIS_PMV_ACTUAL_PVT.ACTUAL_VALUE_TBL_TYPE
,x_return_status            OUT NOCOPY VARCHAR2
,x_msg_count                OUT NOCOPY NUMBER
,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
  l_query_string           VARCHAR2(32000);
  l_viewby_table           VARCHAR2(32000);
  l_target_alias           VARCHAR2(50);
  l_has_target             VARCHAR2(1);
  l_cursor                 integer;
  l_desc_tab               dbms_sql.desc_tab;
  l_attr_codes             BISVIEWER.t_char;
  l_attr_values            BISVIEWER.t_char;
  l_actual_value           varchar2(2000);
  l_compareto_value        varchar2(2000);
  l_actual_val_cnt         number := 0;
  l_compareto_val_cnt      number:=0;
  l_viewby_val_cnt         number := 0;
  l_viewby_id_cnt          number := 0;
  l_col_count              integer;
  ignore                   integer;
  l_row_found              integer := 0;
  l_bind_variables         varchar2(32000);
  l_plsql_bind_variables   varchar2(32000);
  l_bind_var_tbl           BISVIEWER.t_char;
  l_bind_indexes           varchar2(32000);
  --l_bind_index_tbl         BISVIEWER.t_char;
  l_startIndex             NUMBER;
  l_endIndex               NUMBER;
  l_bind_var               VARCHAR2(32000);
  l_tab_index              NUMBER := 1;
  l_bind_col               VARCHAR2(2000);
  l_viewby_tbl             dbms_sql.varchar2_table;
  l_actual_tbl             dbms_sql.number_table;
  l_compareto_tbl          dbms_sql.number_table;
  l_viewbyid_tbl           dbms_sql.varchar2_table;
  l_indx                   number := 1;
  l_actual_rec             BIS_PMV_ACTUAL_PVT.ACTUAL_VALUE_REC_TYPE;
  l_function_name          VARCHAr2(2000);
  l_session_id             VARCHAR2(2000);
  l_user_id                VARCHAR2(2000);
  l_num_of_rows_fetched    NUMBER;
  l_resp_id                NUMBER;
  l_disable_viewby         VARCHAR2(20);
  l_viewby_name            VARCHAR2(2000);
  l_paramregion_code       VARCHAR2(2000);
  l_paramfunc_name         VARCHAR2(2000);
  l_parameters             BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE;
  l_parameter_rec          BIS_PMV_ACTUAL_PVT.PARAMETER_REC_TYPE;
  l_ranking_attr           varchar2(2000);
  l_ranking_dim            varchar2(2000);
  l_count                  number := 0;
  l_plsql_function         varchar2(2000);
  CURSOR c_viewby IS
  SELECT attribute1 disable_viewby, attribute8 plsql_function
  from ak_Regions
  where region_code = p_region_Code;
  CURSOR c_rankparam(pRegionCode in varchar2)  IS
  SELECT attribute_code, attribute2 from ak_region_items
  WHERE display_Sequence = (select min(display_sequence)
  from ak_region_items where region_code = pregioncode
  and attribute_code <> 'AS_OF_DATE') and region_code = pregioncode;

  CURSOR base_column_cursor(cpAttributeCode varchar2) IS
  SELECT attribute3 base_column
    FROM ak_region_items
   WHERE region_code = p_region_code
     AND attribute_code = cpAttributeCode;

  CURSOR column_items_cursor IS
  SELECT attribute_code, attribute3 base_column
    FROM ak_region_items
   WHERE region_code = p_region_code
     AND nested_region_code is null
     AND (   (attribute1 = 'MEASURE')
          or (attribute1 = 'MEASURE_NOTARGET')
          or (attribute1 is null and node_query_flag = 'N')
          or (attribute1 is null and node_display_flag = 'Y')
         );
  --Cursor for getting the attribute code for grand total
  l_grand_total  varchar2(2000) := 'GRAND_TOTAL';
  CURSOR c_grandattrib(p_attrib_code IN VARCHAR2) IS
  SELECT attribute_code
         FROM ak_region_items
  WHERE region_code = p_region_code
  and attribute2 = p_attrib_code
  and attribute1 = l_grand_total;
  l_actual_base_column varchar2(2000);
  l_compareto_base_column varchar2(2000);
  l_actual_formula varchar2(2000);
  --l_temp_actual_formula varchar2(2000);
  l_compareto_formula varchar2(2000);
  --l_temp_compareto_formula varchar2(2000);
  l_sql varchar2(2000);
  l_base_columns BISVIEWER.t_char;
  l_actual_attr_codes BISVIEWER.t_char;
  l_compareto_attr_codes BISVIEWER.t_char;
  l_actual_base_columns BISVIEWER.t_char;
  l_compareto_base_columns BISVIEWER.t_char;
  l_sorted_actual_base_columns BISVIEWER.t_char;
  l_sorted_compare_base_columns BISVIEWER.t_char;
  l_actual_values BISVIEWER.t_char;
  l_compareto_values BISVIEWER.t_char;
  l_calculate_actual boolean := false;
  l_calculate_compareto boolean := false;
  l_actual_count number;
  l_compareto_count number;
  l_actual_col_index BISVIEWER.t_num;
  l_compareto_col_index BISVIEWER.t_num;
  l_viewby_value varchar2(2000);
  l_viewbyid_value varchar2(2000);
  l_temp_viewby_value varchar2(32000);
  l_debug_msg varchar2(32000);
  l_actual_gt_values  dbms_sql.number_table;
  l_compareto_gt_values  dbms_sql.number_table;
  l_actual_gt_value  varchar2(2000);
  l_compareto_gt_value  varchar2(2000);
  l_actual_gt_attrib varchar2(32000);
  l_compareto_gt_attrib varchar2(32000);
  l_actual_gt_ct  number;
  l_compareto_gt_ct number;
  l_bind_datatypes varchar2(32000);
BEGIN
  /*
  if fnd_profile.value('BIS_SQL_TRACE')= 'Y' then
     g_debug_on := true;
  else
     g_debug_on := false;
  end if;
  */
  l_resp_id := p_responsibility_id;

  if p_function_name is null then
     l_function_name := p_region_code;
  else
     l_function_name := p_function_name;
  end if;

  if p_user_id is null then
    l_user_id := 'PMV_ACTUAL';
  else
    l_user_id := p_user_id;
  end if;

  select 'ACTUAL_'||bis_notification_id_s.nextval into l_session_id from dual;
  --dbms_output.put_line ('Session id '|| l_session_id);
   -- Determine if this is a view by or non-view by report
   if (c_viewby%ISOPEN) THEN
      CLOSE c_viewby;
   end if;
   l_parameters := p_parameters;
   OPEN c_viewby;
   FETCH c_viewby INTO l_disable_viewby, l_plsql_function;
   CLOSE c_viewby;

   --dbms_output.put_line ('l disable view by'|| l_disable_viewby);
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'l disable view by:'|| l_disable_viewby;
   end if;

   begin
   select attribute_code  into l_ranking_attr
   from ak_region_items
   where region_code = p_region_code and
         attribute2 = p_ranking_level;
   exception
       when others then null;
   end;
   --dbms_output.put_line ('l_ranking_dim '|| p_ranking_level);
   --dbms_output.put_line ('l_ranking_attr '|| l_ranking_attr);
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'l_ranking_attr:'|| l_ranking_attr;
   end if;

   IF (l_disable_viewby = 'Y') then
      l_viewby_name := l_ranking_attr;
   ELSE
      l_parameter_rec.parameter_name := 'VIEW_BY';
      l_parameter_rec.parameter_value := p_ranking_level;
      l_count := l_parameters.COUNT;
      l_parameters(l_COUNT+1) := l_parameter_rec;
      l_viewby_name := 'VIEWBY';
   END IF;


    STORE_PARAMETERS(p_region_code => p_region_code
                    ,p_function_name => l_function_name
                    ,p_user_id       => l_user_id
                    ,p_session_id    => l_session_id
                    ,p_Responsibility_id => l_resp_id
                    ,p_time_parameter   => p_time_parameter
                    ,p_parameters        => l_parameters
                    ,p_param_ids         => p_param_ids
                    ,x_return_Status     => x_return_Status
                    ,x_msg_count         => x_msg_count
                    ,x_msg_data          => x_msg_data
                    );

   if g_debug_on then
      l_debug_msg := l_debug_msg || 'BIS_PMV_ACTUAL_PVT.STORE_PARAMETERS: '||x_return_status||'*'||x_msg_data;
/*
      FND_MSG_PUB.Add_Exc_Msg(p_pkg_name => 'BIS_PMV_ACTUAL_PVT',
                              p_procedure_name => 'STORE_PARAMETERS',
                              p_error_text => 'status and msg: '||x_return_status||'*'|| x_msg_data);
*/
   end if;

   if g_debug_on then
      l_debug_msg := l_debug_msg || 'Successfully stored the parameters...';
   end if;
    -- get the base column definitions
   if base_column_cursor%ISOPEN then
      close base_column_cursor;
   end if;

   open base_column_cursor(p_actual_attribute_code);
   fetch base_column_cursor into l_actual_base_column;
   close base_column_cursor;
   --dbms_output.put_line('l_actual_base_column:'||l_actual_base_column);
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'l_actual_base_column:'||l_actual_base_column;
   end if;

   open base_column_cursor(p_compareto_attribute_code);
   fetch base_column_cursor into l_compareto_base_column;
   close base_column_cursor;
   --dbms_output.put_line('l_compareto_base_column:'||l_compareto_base_column);
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'l_compareto_base_column:'||l_compareto_base_column;
   end if;

   -- check to see if it's a calculation measure
   if (substr(l_actual_base_column,1,1)='"'
   and (l_plsql_function is not null or
        (l_plsql_function is null and instr(l_actual_base_column,'/') > 0))) then
   --if (substr(l_actual_base_column,1,1)='"' and instr(l_actual_base_column,'/') > 0) then
      l_calculate_actual := true;
      --dbms_output.put_line('actual is calcalation measure');
      l_actual_formula := substr(l_actual_base_column, 2, length(l_actual_base_column)-2);
   end if;

   if (substr(l_compareto_base_column,1,1)='"'
   and (l_plsql_function is not null or
        (l_plsql_function is null and instr(l_compareto_base_column,'/') > 0))) then
   --if (substr(l_compareto_base_column,1,1)='"' and instr(l_compareto_base_column,'/') > 0) then
      l_calculate_compareto := true;
      --dbms_output.put_line('compareto is calcalation measure');
      l_compareto_formula := substr(l_compareto_base_column, 2, length(l_compareto_base_column)-2);
   end if;

   -- set up corresponding info if it's a calculation measure
   if ((l_calculate_actual) or (l_calculate_compareto)) then

      -- get all of the table column attribute codes and base column definitions
      if column_items_cursor%ISOPEN then
         close column_items_cursor;
      end if;
      open column_items_cursor;
      fetch column_items_cursor bulk collect into l_attr_codes, l_base_columns;
      close column_items_cursor;

      -- sort the base columns in descending orders along with the attribute codes
      BIS_PMV_UTIL.sortAttributeCode
      (p_attributeCode_tbl => l_base_columns
      ,p_attributeValue_tbl => l_attr_codes
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data
      );

     if g_debug_on then
      l_debug_msg := l_debug_msg || 'BIS_PMV_UTIL.sortAttributeCode: '||x_return_status||'*'||x_msg_data;
/*
      FND_MSG_PUB.Add_Exc_Msg(p_pkg_name => 'BIS_PMV_UTIL',
                              p_procedure_name => 'sortAttributeCode',
                              p_error_text => 'status and msg: '||x_return_status||'*'|| x_msg_data);
*/
     end if;

      -- find out which attribute codes are used in the calculation formula
      l_actual_count := 0;
      l_compareto_count := 0;
      if (l_base_columns.COUNT > 0) then
      for i in l_base_columns.FIRST..l_base_columns.LAST loop
          --dbms_output.put_line('attr_code'||i||': '||l_attr_codes(i));
          --dbms_output.put_line('base_column'||i||': '||l_base_columns(i));
          if g_debug_on then
             l_debug_msg := l_debug_msg || ' attr_code'||i||': '||l_attr_codes(i)
                                        || ' base_column'||i||': '||l_base_columns(i);
          end if;

          -- for actual calculation
          if (l_calculate_actual) then
              if (l_actual_base_column <> l_base_columns(i)) then
                  if (instr(l_actual_base_column, l_base_columns(i)) > 0) then
                      l_actual_count := l_actual_count + 1;
                      l_actual_base_columns(l_actual_count) := l_base_columns(i);
                      l_actual_attr_codes(l_actual_count) := l_attr_codes(i);
                      l_actual_base_column := replace(l_actual_base_column, l_base_columns(i));
                  end if;
              end if;
          end if;
          -- for compareto calculation
          if (l_calculate_compareto) then
              if (l_compareto_base_column <> l_base_columns(i)) then
                  if (instr(l_compareto_base_column, l_base_columns(i)) > 0) then
                      l_compareto_count := l_compareto_count + 1;
                      l_compareto_base_columns(l_compareto_count) := l_base_columns(i);
                      l_compareto_attr_codes(l_compareto_count) := l_attr_codes(i);
                      l_compareto_base_column := replace(l_compareto_base_column, l_base_columns(i));
                  end if;
              end if;
          end if;
      end loop;
      end if;
   end if; -- end of setting up calculation measure infos


   --Now execute the query and get the values back.
   x_return_Status := FND_API.G_RET_STS_SUCCESS;
   --dbms_output.put_line ('About to execute the query');
   BIS_PMV_QUERY_PVT.getQuerySql(
   p_Region_Code => p_region_code,
   p_function_name  => l_function_name,
   p_user_id => l_user_id ,
   p_session_id => l_session_id,
   p_resp_id => l_resp_id,
   p_page_id => p_page_id,
   p_schedule_id => null,
   p_sort_attribute => null,
   p_sort_direction => null,
   p_source        => 'ACTUAL_FOR_KPI',
   x_sql => l_query_string,
   x_target_alias => l_target_alias,
   x_has_target  => l_has_target,
   x_viewby_table => l_viewby_table,
   x_return_status => x_return_status,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data,
   x_bind_variables => l_bind_variables,
   x_plsql_bind_variables => l_plsql_bind_variables,
   x_bind_indexes => l_bind_indexes,
   x_bind_datatypes => l_bind_datatypes,
   x_view_by_Value => l_temp_viewby_value);

/*
   dbms_output.put_line ('The query is '|| substr(l_query_String,1,200));
   dbms_output.put_line (substr(l_query_String,201,200));
   dbms_output.put_line (substr(l_query_String,401,200));
   dbms_output.put_line (substr(l_query_String,601,200));
   dbms_output.put_line (substr(l_query_String,801,200));
   dbms_output.put_line (substr(l_query_String,1001,200));
   dbms_output.put_line (substr(l_query_String,1201,200));
   dbms_output.put_line (substr(l_query_String,1401,200));
*/

   l_query_String := replace(l_query_String, ':', ':x');

   if g_debug_on then
      l_debug_msg := l_debug_msg || 'BIS_PMV_QUERY_PVT.getQuerySql: '||x_return_status||'*'||x_msg_data
                                 ||' sql:'||l_query_string||' bind variables:'||l_plsql_bind_variables
                                 ||' bind indexes:'||l_bind_indexes;
/*
      FND_MSG_PUB.Add_Exc_Msg(p_pkg_name => 'BIS_PMV_QUERY_PVT',
                              p_procedure_name => 'getQuerySql',
                              p_error_text => 'status and msg: '||x_return_status||'*'|| x_msg_data
                                            ||' sql:'||l_query_string||' bind variables:'||l_plsql_bind_variables
);
*/
   end if;

   --dbms_output.put_line('bind string: '||l_plsql_bind_variables);
   --Get the bind variables in a table.
   if (length(l_bind_variables) > 0) then
      SETUP_BIND_VARIABLES(
      p_bind_variables => l_plsql_bind_variables,
      x_bind_var_tbl => l_bind_var_tbl);
   end if;

/*
   --Get the bind indexes in a table.
   if (length(l_bind_indexes) > 0) then
      SETUP_BIND_VARIABLES(
      p_bind_variables => l_bind_indexes,
      x_bind_var_tbl => l_bind_index_tbl);
   end if;
*/

   --Find out if the actual and compare to attribute codes have grand totals defined for them.
   IF (p_actual_attribute_code IS NOT NULL) then
       IF (c_grandattrib%ISOPEN) THEN
           CLOSE c_grandattrib;
       END IF;
       OPEN c_grandattrib(p_actual_attribute_code);
       FETCH c_grandattrib INTO l_actual_gt_attrib;
       IF (c_grandattrib%NOTFOUND) THEN
          l_actual_gt_attrib := null;
       END IF;
       CLOSE c_grandattrib;
       --dbms_output.put_line ('The actual gt attrib is '|| l_actual_gt_attrib);
   END IF;
   IF (p_compareto_attribute_code IS NOT NULL) then
       IF (c_grandattrib%ISOPEN) THEN
           CLOSE c_grandattrib;
       END IF;
       OPEN c_grandattrib(p_compareto_attribute_code);
       FETCH c_grandattrib INTO l_compareto_gt_attrib;
       IF (c_grandattrib%NOTFOUND) THEN
          l_compareto_gt_attrib := null;
       END IF;
       CLOSE c_grandattrib;
       --dbms_output.put_line ('The compareto gt attrib is '|| l_compareto_gt_attrib);
   END IF;
   l_cursor := dbms_sql.open_cursor;
   dbms_sql.parse(l_cursor, l_query_string, DBMS_SQL.native);
   if (l_bind_var_tbl.COUNT > 0) then
    for i in l_bind_var_tbl.FIRST..l_bind_var_tbl.LAST loop
       l_bind_col := ':x'|| i;

       if (l_bind_var_tbl(i) is null or length(l_bind_Var_Tbl(i)) = 0) then
          l_bind_var := null;
       else
          if (substr(l_bind_var_tbl(i),1,1) = '''' and
              substr(l_bind_var_tbl(i), length(l_bind_Var_tbl(i)),1) = '''') then
             l_bind_var := substr(l_bind_Var_tbl(i),2, length(l_bind_Var_tbl(i))-2);
          else
             l_bind_Var := l_bind_Var_tbl(i);
          end if;
       end if;
       --dbms_output.put_line ('bind var '||(i)||':'|| l_bind_var);
       dbms_sql.bind_variable(l_cursor, l_bind_col, l_bind_var);
    end loop;
   end if;

   --dbms_output.put_line ('before describe columns');
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'before describe columns';
   end if;

   dbms_sql.describe_columns(l_cursor, l_col_count, l_desc_tab);
   l_actual_count := 0;
   l_compareto_count := 0;
   for i in 1..l_col_count loop
     --dbms_output.put_line('alias: '||l_desc_tab(i).col_name);
     if g_debug_on then
        l_debug_msg := l_debug_msg || ' alias: '||l_desc_tab(i).col_name;
     end if;

      if (l_calculate_actual) then
        if (l_actual_attr_codes.COUNT > 0) then
        for j in l_actual_attr_codes.FIRST..l_actual_attr_codes.LAST loop
           if (l_desc_tab(i).col_name = l_actual_attr_codes(j)) then
             l_actual_count := l_actual_count + 1;
             l_actual_col_index(l_actual_count) := i;
             l_sorted_actual_base_columns(l_actual_count) := l_actual_base_columns(j);
           end if;
        end loop;
        end if;
      else
        if (l_desc_tab(i).col_name = p_actual_attribute_code) then
             l_Actual_val_cnt := i;
             --dbms_output.put_line ('l_actual_val_cnt:'||i);
             if g_debug_on then
                l_debug_msg := l_debug_msg || ' l_actual_val_cnt:'||i;
             end if;
        end if;
      end if;

      if (l_calculate_compareto) then
        if (l_compareto_attr_codes.COUNT > 0) then
        for j in l_compareto_attr_codes.FIRST..l_compareto_attr_codes.LAST loop
           if (l_desc_tab(i).col_name = l_compareto_attr_codes(j)) then
             l_compareto_count := l_compareto_count + 1;
             l_compareto_col_index(l_compareto_count) := i;
             l_sorted_compare_base_columns(l_compareto_count) := l_compareto_base_columns(j);
             --dbms_output.put_line ('l_compareto_col_index'||l_compareto_count||':'||i);
           end if;
        end loop;
        end if;
      else
        if (l_desc_tab(i).col_name = p_compareto_attribute_code) then
             l_compareto_val_cnt := i;
        end if;
      end if;

      if (l_desc_tab(i).col_name = l_viewby_name) then
          l_viewby_val_cnt := i;
          --dbms_output.put_line ('l_viewby_val_cnt:'||i);
          if g_debug_on then
             l_debug_msg := l_debug_msg || ' l_viewby_val_cnt:'||i;
          end if;
      end if;

      if (l_desc_tab(i).col_name = 'VIEWBYID') then
          l_viewby_id_cnt := i;
          --dbms_output.put_line ('l_viewby_id_cnt:'||i);
          if g_debug_on then
             l_debug_msg := l_debug_msg || ' l_viewby_id_cnt:'||i;
          end if;
      end if;
      if (l_actual_gt_attrib is not null) then
         if (l_desc_tab(i).col_name = l_actual_gt_attrib) then
             l_actual_gt_ct := i;
             --dbms_output.put_line ('l_actual_gt_ct:'||i);
             if g_debug_on then
                l_debug_msg := l_debug_msg || ' l_actual_gt_ct:'||i;
             end if;
         end if;
      end if;
      if (l_compareto_gt_attrib is not null) then
         if (l_desc_tab(i).col_name = l_compareto_gt_attrib) then
             l_compareto_gt_ct := i;
             --dbms_output.put_line ('l_compareto_gt_ct:'||i);
             if g_debug_on then
                l_debug_msg := l_debug_msg || ' l_compareto_gt_ct:'||i;
             end if;
          end if;
      end if;
   end loop;

   --dbms_output.put_line ('before defining columns');
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'before defining columns';
   end if;

   if (l_calculate_actual) or (l_calculate_compareto) then
   --dbms_output.put_line ('before difining actual columns');
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'before defining actual columns';
   end if;

     if (l_calculate_actual) then
      SORTBY_BASE_COLUMN_LENGTH(p_table1 => l_sorted_actual_base_columns
                               ,p_table2 => l_actual_attr_codes
                               ,p_table3 => l_actual_col_index
                               ,x_return_status => x_return_status
                               ,x_msg_count => x_msg_count
                               ,x_msg_data => x_msg_data
                               );

       for i in 1..l_actual_count loop
         dbms_sql.define_column(l_cursor, l_actual_col_index(i), l_actual_value, 200);
       end loop;
     else
       if (l_actual_val_cnt > 0) then
         dbms_sql.define_column(l_cursor, l_actual_val_cnt, l_actual_value, 200);
       end if;
     end if;

   --dbms_output.put_line ('before defining compareto columns');
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'before defining compareto columns';
   end if;

     if (l_calculate_compareto) then
      SORTBY_BASE_COLUMN_LENGTH(p_table1 => l_sorted_compare_base_columns
                               ,p_table2 => l_compareto_attr_codes
                               ,p_table3 => l_compareto_col_index
                               ,x_return_status => x_return_status
                               ,x_msg_count => x_msg_count
                               ,x_msg_data => x_msg_data
                               );

       --dbms_output.put_line('compareto_count:'||l_compareto_count);
       for i in 1..l_compareto_count loop
         --dbms_output.put_line ('l_compareto_col_index'||i||':'||l_compareto_col_index(i));
         dbms_sql.define_column(l_cursor, l_compareto_col_index(i), l_compareto_value, 200);
       end loop;
     else
       if (l_compareto_val_cnt > 0) then
         dbms_sql.define_column(l_cursor, l_compareto_val_cnt, l_compareto_value, 200);
       end if;
     end if;

   --dbms_output.put_line ('before defining viewby columns');
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'before defining viewby columns';
   end if;

      if (l_viewby_val_cnt > 0) then
        dbms_sql.define_column(l_cursor, l_viewby_val_cnt, l_viewby_value, 200);
      end if;

   --dbms_output.put_line ('before defining viewbyid columns');
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'before defining viewbyid columns';
   end if;

      if (l_viewby_id_cnt > 0) then
        dbms_sql.define_column(l_cursor, l_viewby_id_cnt, l_viewbyid_value, 200);
      end if;

      if (l_Actual_gt_ct > 0) then
        dbms_sql.define_column(l_cursor,l_actual_gt_ct, l_actual_gt_value, 200);
      end if;

      if (l_compareto_gt_ct > 0) then
        dbms_sql.define_column(l_cursor,l_compareto_gt_ct, l_compareto_gt_value, 200);
      end if;

   else
      if (l_Actual_val_cnt > 0) then
         dbms_sql.define_array(l_cursor, l_Actual_val_cnt, l_actual_tbl, 10, 1);
      end if;
      if (l_compareto_val_cnt > 0) then
        dbms_sql.define_array(l_cursor, l_compareto_val_cnt, l_compareto_tbl, 10, 1);
      end if;
      if (l_viewby_val_cnt > 0) then
        dbms_sql.define_array(l_cursor, l_viewby_val_cnt, l_viewby_tbl, 10, 1);
      end if;
      if (l_viewby_id_cnt > 0) then
        dbms_sql.define_array(l_cursor, l_viewby_id_cnt, l_viewbyid_tbl, 10, 1);
      end if;
      if (l_Actual_gt_ct > 0) then
        dbms_sql.define_array(l_cursor,l_actual_gt_ct, l_actual_gt_values,10,1);
      end if;
      if (l_compareto_gt_ct > 0) then
        dbms_sql.define_array(l_cursor,l_compareto_gt_ct, l_compareto_gt_values,10,1);
      end if;
   end if;

   --dbms_output.put_line ('before executing cursor');
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'before executing cursor';
   end if;

   ignore := dbms_sql.execute(l_cursor);

   --dbms_output.put_line ('after executing cursor:'||ignore);
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'after executing cursor:' || ignore;
   end if;

   loop
       l_num_of_rows_fetched := dbms_sql.fetch_rows(l_cursor);
       --dbms_output.put_line('row fetched:'||l_num_of_rows_fetched);
       if g_debug_on then
          l_debug_msg := l_debug_msg || 'row fetched:'||l_num_of_rows_fetched;
       end if;

       l_row_found := l_row_found+1;
       --dbms_output.put_line ('row found:'||l_row_found);

       if (l_calculate_actual) or (l_calculate_compareto) then

        exit when l_num_of_rows_fetched = 0;

        if (l_calculate_actual) then
          --l_temp_actual_formula := l_Actual_formula;
          for i in 1..l_actual_count loop
            dbms_sql.column_value(l_cursor, l_actual_col_index(i), l_actual_values(i));
          end loop;

          GET_CALCULATED_VALUE
         (p_formula => l_Actual_formula
         ,p_measure_base_columns => l_sorted_actual_base_columns
         ,p_measure_values => l_actual_values
         ,x_calculated_value => l_actual_value
         );

/*
          for i in 1..l_actual_count loop
             l_temp_actual_formula := replace(l_temp_actual_formula, l_actual_base_columns(i), l_actual_values(i));
          end loop;
          l_sql := 'select '||l_temp_actual_formula||' from dual';
          begin
            execute immediate l_sql into l_actual_value;
          exception
          when others then
            l_actual_value := '0';
          end;
*/
        else
          if (l_actual_val_cnt > 0) then
            --dbms_output.put_line('l_actual_val_cnt:'||l_actual_val_cnt);
            if g_debug_on then
               l_debug_msg := l_debug_msg || 'l_actual_val_cnt:'||l_actual_val_cnt;
            end if;

            dbms_sql.column_value(l_cursor, l_actual_val_cnt, l_actual_value);
          end if;
        end if;
        l_actual_tbl(l_row_found) := l_actual_value;
        --dbms_output.put_line ('actual'||l_row_found||':'||l_actual_tbl(l_row_found));
        if g_debug_on then
           l_debug_msg := l_debug_msg ||'actual:'||l_row_found||':'||l_actual_tbl(l_row_found);
        end if;

        if (l_calculate_compareto) then
          --l_temp_compareto_formula := l_compareto_formula;
          for i in 1..l_compareto_count loop
            dbms_sql.column_value(l_cursor, l_compareto_col_index(i), l_compareto_values(i));
            --dbms_output.put_line ('compareto'||i||':'||l_compareto_values(i));
            if g_debug_on then
               l_debug_msg := l_debug_msg || 'compareto'||i||':'||l_compareto_values(i);
            end if;

          end loop;

          GET_CALCULATED_VALUE
         (p_formula => l_compareto_formula
         ,p_measure_base_columns => l_sorted_compare_base_columns
         ,p_measure_values => l_compareto_values
         ,x_calculated_value => l_compareto_value
         );

/*
          for i in 1..l_compareto_count loop
             l_temp_compareto_formula := replace(l_temp_compareto_formula, l_compareto_base_columns(i), l_compareto_values(i));
          end loop;
          l_sql := 'select '||l_temp_compareto_formula||' from dual';
          --dbms_output.put_line('sql: '||l_sql);
          if g_debug_on then
             l_debug_msg := l_debug_msg || ' sql: '||l_sql;
          end if;

          begin
            execute immediate l_sql into l_compareto_value;
          exception
          when others then
            l_compareto_value := '0';
          end;
*/
        else
          if (l_compareto_val_cnt > 0) then
            dbms_sql.column_value(l_cursor, l_compareto_val_cnt, l_compareto_value);
          end if;
        end if;
        l_compareto_tbl(l_row_found) := l_compareto_value;
        --dbms_output.put_line ('compareto'||l_row_found||':'||l_compareto_tbl(l_row_found));
        if g_debug_on then
           l_debug_msg := l_debug_msg || 'compareto'||l_row_found||':'||l_compareto_tbl(l_row_found);
        end if;

        if (l_viewby_val_cnt > 0) then
           dbms_sql.column_value (l_cursor, l_viewby_val_cnt, l_viewby_tbl(l_row_found));
        end if;

        if (l_viewby_id_cnt > 0) then
           dbms_sql.column_value (l_cursor, l_viewby_id_cnt, l_viewbyid_tbl(l_row_found));
        end if;

        if (l_actual_gt_ct > 0) then
            --dbms_output.put_line ('Getting the actual gt value');
            dbms_sql.column_value (l_cursor, l_actual_gt_ct, l_actual_gt_value);
            l_actual_gt_values(l_row_found) := l_actual_gt_value;
        end if;
        if (l_compareto_gt_ct > 0) then
            --dbms_output.put_line ('Getting the compareto gt value');
            dbms_sql.column_value (l_cursor, l_compareto_gt_ct, l_compareto_gt_value);
            l_compareto_gt_values(l_row_found) := l_compareto_gt_value;
        end if;

      else
        if (l_Actual_val_cnt > 0) then
            dbms_sql.column_Value (l_cursor, l_actual_val_cnt, l_actual_tbl);
        end if;
        if (l_compareto_val_cnt > 0) then
            dbms_sql.column_value (l_cursor, l_compareto_val_cnt, l_compareto_tbl);
        end if;
        if (l_viewby_val_cnt > 0) then
            dbms_sql.column_value (l_cursor, l_viewby_val_cnt, l_viewby_tbl);
        end if;
        if (l_viewby_id_cnt > 0) then
            dbms_sql.column_value (l_cursor, l_viewby_id_cnt, l_viewbyid_tbl);
        end if;
        if (l_actual_gt_ct > 0) then
            --dbms_output.put_line ('Getting the actual gt value');
            dbms_sql.column_value (l_cursor, l_actual_gt_ct, l_actual_gt_values);
        end if;
        if (l_compareto_gt_ct > 0) then
            --dbms_output.put_line ('Getting the compareto gt value');
            dbms_sql.column_value (l_cursor, l_compareto_gt_ct, l_compareto_gt_values);
        end if;
        exit;
      end if;
    end loop;
    --Now populare the return record --
    l_indx := 1;
    if l_actual_tbl.COUNT > 0 then
    for i in l_actual_tbl.FIRST..l_actual_tbl.LAST loop
        --l_actual_rec.view_by_value := l_actual_tbl(i);
        if (l_actual_tbl.EXISTS(i)) then
            l_actual_rec.actual_value := l_actual_tbl(i);
        end if;
        if (l_compareto_tbl.EXISTS(i)) then
            l_actual_rec.compare_to_value := l_compareto_tbl(i);
        end if;
        if (l_viewbyid_tbl.EXISTS(i)) then
            l_actual_rec.view_by_id := l_viewbyid_tbl(i);
        end if;
        if (l_viewby_tbl.EXISTS(i)) then
            l_actual_rec.view_by_value := l_viewby_tbl(i);
        end if;
        if (l_actual_gt_values.EXISTS(i)) then
            l_actual_rec.actual_grandtotal_value := l_actual_gt_values(i);
        end if;
        if (l_compareto_gt_values.EXISTS(i)) then
            l_actual_rec.compareto_grandtotal_value := l_compareto_gt_values(i);
        end if;
        x_actual_value(l_indx) := l_actual_rec;
        l_indx := l_indx+1;
     end loop;
     end if;
     dbms_sql.close_cursor(l_cursor);
     if (l_row_found <= 0) then
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_data := 'NO DATA FOUND';
     end if;
     if (l_actual_val_cnt <=0) and not(l_calculate_actual) then
        x_return_Status := FND_API.G_RET_STS_ERROR;
        x_msg_data := 'Invalid attribute code';
     end if;
     x_msg_data := l_debug_msg || x_msg_data;
EXCEPTION
   when others then
     if (dbms_sql.IS_OPEN(l_cursor)) then
         dbms_sql.close_cursor(l_cursor);
     end if;
     x_return_status := FND_API.G_RET_STS_ERROR;
    -- x_return_status := SQLERRM;
     --dbms_output.put_line ('The err 2 is '|| x_return_Status);

END;
PROCEDURE STORE_PARAMETERS
(p_region_code              IN  VARCHAR2
,p_function_name            IN  VARCHAR2 DEFAULT NULL
,p_session_id               IN  VARCHAR2 DEFAULT NULL
,p_user_id                  IN  VARCHAR2 DEFAULT NULL
,p_responsibility_id        IN  VARCHAR2 DEFAULT NULL
,p_time_parameter           IN  BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE
,p_parameters               IN  BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
,p_param_ids                IN  VARCHAR2 DEFAULT 'N'
,x_return_status            OUT NOCOPY VARCHAR2
,x_msg_count                OUT NOCOPY NUMBER
,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
 l_parameter1 varchar2(2000);
 l_parameter2 varchar2(2000);
 l_parameter3 varchar2(2000);
 l_parameter4 varchar2(2000);
 l_parameter5 varchar2(2000);
 l_parameter6 varchar2(2000);
 l_parameter7 varchar2(2000);
 l_parameter8 varchar2(2000);
 l_parameter9 varchar2(2000);
 l_parameter10 varchar2(2000);
 l_parameter11 varchar2(2000);
 l_parameter12 varchar2(2000);
 l_parameter13 varchar2(2000);
 l_parameter14 varchar2(2000);
 l_parameter_value1 varchar2(2000);
 l_parameter_value2 varchar2(2000);
 l_parameter_value3 varchar2(2000);
 l_parameter_value4 varchar2(2000);
 l_parameter_value5 varchar2(2000);
 l_parameter_value6 varchar2(2000);
 l_parameter_value7 varchar2(2000);
 l_parameter_value8 varchar2(2000);
 l_parameter_value9 varchar2(2000);
 l_parameter_value10 varchar2(2000);
 l_parameter_value11 varchar2(2000);
 l_parameter_value12 varchar2(2000);
 l_parameter_value13 varchar2(2000);
 l_parameter_value14 varchar2(2000);
 l_time_parameter varchar2(2000);
 l_time_from_value varchar2(2000);
 l_time_to_value varchar2(2000);
 l_function_name varchar2(2000);
 l_user_id varchar2(2000);
 l_session_id varchar2(2000);
 l_count     number;
 l_return_status varchar2(2000);
 l_msg_count number;
 l_msg_data varchar2(2000);
 l_index number;
 l_index2 number;
 l_error_code varchar2(10);
 l_separator varchar2(10) := '*^]';
 l_actual varchar2(2000);
 l_separator1 varchar2(100) := '^~]*';
 p_parameter_id  varchar2(32000);
 l_AsOfDateValue varchar2(2000);
 l_viewby varchar2(2000);
BEGIN
  l_session_id := p_session_id;
  l_user_id  := p_user_id;
  l_function_name := p_function_name;
  --setup parameters for saving
  l_time_parameter := p_time_parameter.time_parameter_name;
  if (p_param_ids = 'Y') then
     l_time_from_value := p_time_parameter.time_From_id;
     l_time_to_value := p_time_parameter.time_to_id;
  else
     l_time_from_value := p_time_parameter.time_from_value;
     l_time_to_value := p_time_parameter.time_to_value;
   end if;

  l_count := 1;
  IF p_parameters.COUNT > 0 THEN
  FOR i IN p_parameters.FIRST..p_parameters.LAST
  LOOP
    exit when l_count > 14;
    if (p_param_ids = 'Y') then
        if (upper(p_parameters(i).parameter_id) = 'ALL') then
            p_parameter_id := null;
        else
            p_parameter_id := p_parameters(i).parameter_id;
        end if;
    end if;

  if p_parameters(i).parameter_name = 'AS_OF_DATE' then
     l_AsOfDateValue := p_parameters(i).parameter_value;
     l_time_from_value := 'DBC_TIME';
     l_time_to_value := 'DBC_TIME';
  elsif p_parameters(i).parameter_name = 'VIEW_BY' then
     l_viewby := p_parameters(i).parameter_value;
  else

    if l_count = 1 then
      l_parameter1 := p_parameters(i).parameter_name;
      if p_param_ids = 'Y' and
         (substr(l_parameter1,1,length('TIME_COMPARISON_TYPE')) <> 'TIME_COMPARISON_TYPE') then
         l_parameter_value1 := p_parameter_id || l_separator1|| p_parameters(i).parameter_value;
      else
         l_parameter_value1 := p_parameters(i).parameter_value;
      end if;
    elsif l_count = 2 then
      l_parameter2 := p_parameters(i).parameter_name;
      if p_param_ids = 'Y' and
         (substr(l_parameter2,1,length('TIME_COMPARISON_TYPE')) <> 'TIME_COMPARISON_TYPE') then
         l_parameter_value2 := p_parameter_id || l_separator1|| p_parameters(i).parameter_value;
      else
         l_parameter_value2 := p_parameters(i).parameter_value;
      end if;
    elsif l_count = 3 then
      l_parameter3 := p_parameters(i).parameter_name;
      if p_param_ids = 'Y' and
         (substr(l_parameter3,1,length('TIME_COMPARISON_TYPE')) <> 'TIME_COMPARISON_TYPE') then
         l_parameter_value3 := p_parameter_id|| l_separator1 || p_parameters(i).parameter_value;
      else
         l_parameter_value3 := p_parameters(i).parameter_value;
      end if;
    elsif l_count = 4 then
      l_parameter4 := p_parameters(i).parameter_name;
      if p_param_ids = 'Y' and
         (substr(l_parameter4,1,length('TIME_COMPARISON_TYPE')) <> 'TIME_COMPARISON_TYPE') then
         l_parameter_value4 := p_parameter_id|| l_separator1 || p_parameters(i).parameter_value;
      else
         l_parameter_value4 := p_parameters(i).parameter_value;
      end if;
    elsif l_count = 5 then
      l_parameter5 := p_parameters(i).parameter_name;
      if p_param_ids = 'Y' and
         (substr(l_parameter5,1,length('TIME_COMPARISON_TYPE')) <> 'TIME_COMPARISON_TYPE') then
         l_parameter_value5 := p_parameter_id|| l_separator1 || p_parameters(i).parameter_value;
      else
         l_parameter_value5 := p_parameters(i).parameter_value;
      end if;
    elsif l_count = 6 then
      l_parameter6 := p_parameters(i).parameter_name;
      if p_param_ids = 'Y' and
         (substr(l_parameter6,1,length('TIME_COMPARISON_TYPE')) <> 'TIME_COMPARISON_TYPE') then
         l_parameter_value6 := p_parameter_id|| l_separator1 || p_parameters(i).parameter_value;
      else
         l_parameter_value6 := p_parameters(i).parameter_value;
      end if;
    elsif l_count = 7 then
      l_parameter7 := p_parameters(i).parameter_name;
      if p_param_ids = 'Y' and
         (substr(l_parameter7,1,length('TIME_COMPARISON_TYPE')) <> 'TIME_COMPARISON_TYPE') then
         l_parameter_value7 := p_parameter_id|| l_separator1 || p_parameters(i).parameter_value;
      else
         l_parameter_value7 := p_parameters(i).parameter_value;
      end if;
    elsif l_count = 8 then
      l_parameter8 := p_parameters(i).parameter_name;
      if p_param_ids = 'Y' and
         (substr(l_parameter8,1,length('TIME_COMPARISON_TYPE')) <> 'TIME_COMPARISON_TYPE') then
         l_parameter_value8 := p_parameter_id|| l_separator1 || p_parameters(i).parameter_value;
      else
         l_parameter_value8 := p_parameters(i).parameter_value;
      end if;
    elsif l_count = 9 then
      l_parameter9 := p_parameters(i).parameter_name;
      if p_param_ids = 'Y' and
         (substr(l_parameter9,1,length('TIME_COMPARISON_TYPE')) <> 'TIME_COMPARISON_TYPE') then
         l_parameter_value9 := p_parameter_id|| l_separator1 || p_parameters(i).parameter_value;
      else
         l_parameter_value9 := p_parameters(i).parameter_value;
      end if;
    elsif l_count = 10 then
      l_parameter10 := p_parameters(i).parameter_name;
      if p_param_ids = 'Y' and
         (substr(l_parameter10,1,length('TIME_COMPARISON_TYPE')) <> 'TIME_COMPARISON_TYPE') then
         l_parameter_value10 := p_parameter_id|| l_separator1 || p_parameters(i).parameter_value;
      else
         l_parameter_value10 := p_parameters(i).parameter_value;
      end if;
    elsif l_count = 11 then
      l_parameter11 := p_parameters(i).parameter_name;
      if p_param_ids = 'Y' and
         (substr(l_parameter11,1,length('TIME_COMPARISON_TYPE')) <> 'TIME_COMPARISON_TYPE') then
         l_parameter_value11 := p_parameter_id|| l_separator1 || p_parameters(i).parameter_value;
      else
         l_parameter_value11 := p_parameters(i).parameter_value;
      end if;
    elsif l_count = 12 then
      l_parameter12 := p_parameters(i).parameter_name;
      if p_param_ids = 'Y' and
         (substr(l_parameter12,1,length('TIME_COMPARISON_TYPE')) <> 'TIME_COMPARISON_TYPE') then
         l_parameter_value12 := p_parameter_id|| l_separator1 || p_parameters(i).parameter_value;
      else
         l_parameter_value12 := p_parameters(i).parameter_value;
      end if;
    elsif l_count = 13 then
      l_parameter13 := p_parameters(i).parameter_name;
      if p_param_ids = 'Y' and
         (substr(l_parameter13,1,length('TIME_COMPARISON_TYPE')) <> 'TIME_COMPARISON_TYPE') then
         l_parameter_value13 := p_parameter_id|| l_separator1 || p_parameters(i).parameter_value;
      else
         l_parameter_value13 := p_parameters(i).parameter_value;
      end if;
    else
      l_parameter14 := p_parameters(i).parameter_name;
      if p_param_ids = 'Y' and
         (substr(l_parameter14,1,length('TIME_COMPARISON_TYPE')) <> 'TIME_COMPARISON_TYPE') then
         l_parameter_value14 := p_parameter_id|| l_separator1 || p_parameters(i).parameter_value;
      else
         l_parameter_value14 := p_parameters(i).parameter_value;
      end if;
    end if;
    l_count := l_count + 1;
   end if;
  END LOOP;
  END IF;

  --save the passing parameters to bis_user_attributes
  BIS_PMV_PARAMETERS_PVT.saveParameters
   (pRegionCode       => p_region_code,
    pFunctionName     => l_function_name,
    pSessionId        => l_session_id,
    pUserId           => l_user_id,
    pResponsibilityId => p_responsibility_id,
    pParameter1       => l_parameter1,
    pParameterValue1  => l_parameter_value1,
    pParameter2       => l_parameter2,
    pParameterValue2  => l_parameter_value2,
    pParameter3       => l_parameter3,
    pParameterValue3  => l_parameter_value3,
    pParameter4       => l_parameter4,
    pParameterValue4  => l_parameter_value4,
    pParameter5       => l_parameter5,
    pParameterValue5  => l_parameter_value5,
    pParameter6       => l_parameter6,
    pParameterValue6  => l_parameter_value6,
    pParameter7       => l_parameter7,
    pParameterValue7  => l_parameter_value7,
    pParameter8       => l_parameter8,
    pParameterValue8  => l_parameter_value8,
    pParameter9       => l_parameter9,
    pParameterValue9  => l_parameter_value9,
    pParameter10      => l_parameter10,
    pParameterValue10 => l_parameter_value10,
    pParameter11      => l_parameter11,
    pParameterValue11 => l_parameter_value11,
    pParameter12      => l_parameter12,
    pParameterValue12 => l_parameter_value12,
    pParameter13      => l_parameter13,
    pParameterValue13 => l_parameter_value13,
    pParameter14      => l_parameter14,
    pParameterValue14 => l_parameter_value14,
    pTimeParameter    => l_time_parameter,
    pTimeFromParameter=> l_time_from_value,
    pTimeToParameter  => l_time_to_value,
    pAsOfDateValue    => l_AsOfDateValue,
    pViewByValue      => l_viewby,
    pAddToDefault     => 'N',
    pSaveByIds        => p_param_ids,
    x_return_status   => x_return_status,
    x_msg_count	      => x_msg_count,
    x_msg_data        => x_msg_data
    );
END STORE_PARAMETERS;

PROCEDURE SETUP_BIND_VARIABLES
(p_bind_variables in varchar2,
 x_bind_var_tbl  out NOCOPY BISVIEWER.t_char)
is
  l_startIndex        NUMBER;
  l_endIndex          NUMBER;
  l_bind_var          VARCHAR2(32000);
  l_tab_index       NUMBER := 1;
  l_bind_col          VARCHAR2(2000);
Begin
      l_startIndex := 2;
      loop
         if (instr(p_bind_variables, '~', l_startIndex , 1) > 0) then
             l_endIndex := instr(p_bind_variables,'~', l_startIndex, 1);
         else
             l_endIndex := length(p_bind_variables)+1;
         end if;
         l_bind_var := substr(p_bind_variables, l_startIndex, l_endIndex-l_startIndex);
         x_bind_var_tbl(l_tab_index) := l_bind_var;
         l_tab_index := l_tab_index +1;
         l_startIndex := l_endIndex+1;
         if (l_startIndex > length(p_bind_variables) or
             l_endIndex <= 1 )  then
            exit;
         end if;
         --Extra Precaution
         if (l_tab_index > 1500) then
            exit;
         end if;
      end loop;
      if (substr(p_bind_variables,length(p_bind_variables),1) = '~' and
          length(p_bind_variables) > 1)
      then
          --l_tab_index := l_tab_index+1;
          x_bind_var_tbl(l_tab_index) := null;
      end if;
END SETUP_BIND_VARIABLES;

PROCEDURE GET_ACTUAL_VALUE
(p_region_code              IN  VARCHAR2
,p_function_name            IN  VARCHAR2 DEFAULT NULL
,p_user_id                  IN  VARCHAR2 DEFAULT NULL
,p_page_id                  IN  VARCHAR2 DEFAULT NULL
,p_responsibility_id        IN  VARCHAR2 DEFAULT NULL
,p_time_parameter           IN  BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE
,p_parameters               IN  BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
,p_param_ids                IN  VARCHAR2 DEFAULT 'N'
,p_measure_attribute_codes  IN  BIS_PMV_ACTUAL_PVT.MEASURE_ATTR_CODES_TYPE
,p_ranking_level            IN  VARCHAR2
,x_measure_tbl              OUT NOCOPY BIS_PMV_ACTUAL_PVT.ACTUAL_VALUE_TBL_TYPE
,x_return_status            OUT NOCOPY VARCHAR2
,x_msg_count                OUT NOCOPY NUMBER
,x_msg_data                 OUT NOCOPY VARCHAR2
) IS

  CURSOR c_viewby IS
  SELECT attribute1 disable_viewby, attribute8 plsql_function
  from ak_Regions
  where region_code = p_region_Code;

  CURSOR c_rankparam(pRegionCode in varchar2)  IS
  SELECT attribute_code, attribute2 from ak_region_items
  WHERE display_Sequence = (select min(display_sequence)
  from ak_region_items where region_code = pregioncode
  and attribute_code <> 'AS_OF_DATE') and region_code = pregioncode;

  CURSOR base_column_cursor(cpAttributeCode varchar2) IS
  SELECT attribute3 base_column
    FROM ak_region_items
   WHERE region_code = p_region_code
     AND attribute_code = cpAttributeCode;

  CURSOR column_items_cursor IS
  SELECT attribute_code, attribute3 base_column
    FROM ak_region_items
   WHERE region_code = p_region_code
     AND nested_region_code is null
     AND (   (attribute1 = 'MEASURE')
          or (attribute1 = 'MEASURE_NOTARGET')
          or (attribute1 is null and node_query_flag = 'N')
          or (attribute1 is null and node_display_flag = 'Y')
         );

  --Cursor for getting the attribute code for grand total
  l_grand_total  varchar2(2000) := 'GRAND_TOTAL';
  CURSOR c_grandattrib(p_attrib_code IN VARCHAR2) IS
  SELECT attribute_code
         FROM ak_region_items
  WHERE region_code = p_region_code
  and attribute2 = p_attrib_code
  and attribute1 = l_grand_total;

  l_query_string           VARCHAR2(32000);
  l_viewby_table           VARCHAR2(32000);
  l_target_alias           VARCHAR2(50);
  l_has_target             VARCHAR2(1);
  l_cursor                 integer;
  l_desc_tab               dbms_sql.desc_tab;
  l_viewby_val_cnt         number := 0;
  l_viewby_id_cnt          number := 0;
  l_col_count              integer;
  ignore                   integer;
  l_row_found              integer := 0;
  l_bind_variables         varchar2(32000);
  l_plsql_bind_variables   varchar2(32000);
  l_bind_var_tbl           BISVIEWER.t_char;
  l_bind_indexes           varchar2(32000);
  l_bind_var               VARCHAR2(32000);
  l_tab_index              NUMBER := 1;
  l_bind_col               VARCHAR2(2000);
  l_indx                   number := 1;
  l_actual_rec             BIS_PMV_ACTUAL_PVT.ACTUAL_VALUE_REC_TYPE;
  l_function_name          VARCHAr2(2000);
  l_session_id             VARCHAR2(2000);
  l_user_id                VARCHAR2(2000);
  l_num_of_rows_fetched    NUMBER;
  l_resp_id                NUMBER;
  l_disable_viewby         VARCHAR2(20);
  l_viewby_name            VARCHAR2(2000);
  l_paramregion_code       VARCHAR2(2000);
  l_paramfunc_name         VARCHAR2(2000);
  l_parameters             BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE;
  l_parameter_rec          BIS_PMV_ACTUAL_PVT.PARAMETER_REC_TYPE;
  l_ranking_attr           varchar2(2000);
  l_ranking_dim            varchar2(2000);
  l_count                  number := 0;

  l_measure_attr_codes BISVIEWER.t_char;
  l_measure_base_columns BISVIEWER.t_char;
  l_selected_attr_codes BISVIEWER.t_char;
  l_selected_base_columns BISVIEWER.t_char;
  l_selected_base_columns2 BISVIEWER.t_char;
  l_selected_measure_values BISVIEWER.t_char;
  l_selected_gt_values BISVIEWER.t_char;
  l_selected_col_index BISVIEWER.t_num;
  l_selected_gt_index BISVIEWER.t_num;
  l_gt_index BISVIEWER.t_num;
  l_gt_attr_code varchar2(2000);
  l_measure_value varchar2(2000);
  l_gt_value varchar2(2000);
  l_viewby_id varchar2(2000);
  l_measure_count number;
  l_gt_count number;
  l_rec_count number;
  hasCalculationMeasure boolean := false;

  l_sql varchar2(2000);
  l_viewby_value varchar2(2000);
  l_viewbyid_value varchar2(2000);
  l_temp_viewby_value varchar2(32000);
  l_debug_msg varchar2(32000);

  l_plsql_function varchar2(2000);
  l_bind_datatypes varchar2(32000);
BEGIN
  /*
  if fnd_profile.value('BIS_SQL_TRACE')= 'Y' then
     g_debug_on := true;
  else
     g_debug_on := false;
  end if;
  */
  l_resp_id := p_responsibility_id;

  if p_function_name is null then
     l_function_name := p_region_code;
  else
     l_function_name := p_function_name;
  end if;

  if p_user_id is null then
    l_user_id := 'PMV_ACTUAL';
  else
    l_user_id := p_user_id;
  end if;

  l_parameters := p_parameters;

  select 'ACTUAL_'||bis_notification_id_s.nextval into l_session_id from dual;
  --dbms_output.put_line ('Session id '|| l_session_id);

   -- Determine if this is a view by or non-view by report
   if (c_viewby%ISOPEN) THEN
      CLOSE c_viewby;
   end if;
   OPEN c_viewby;
   FETCH c_viewby INTO l_disable_viewby, l_plsql_function;
   CLOSE c_viewby;

   --dbms_output.put_line ('l disable view by'|| l_disable_viewby);
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'l disable view by:'|| l_disable_viewby;
   end if;

   begin
   select attribute_code  into l_ranking_attr
   from ak_region_items
   where region_code = p_region_code and
         attribute2 = p_ranking_level;
   exception
       when others then null;
   end;

   --dbms_output.put_line ('l_ranking_dim '|| p_ranking_level);
   --dbms_output.put_line ('l_ranking_attr '|| l_ranking_attr);
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'l_ranking_attr:'|| l_ranking_attr;
   end if;

   IF (l_disable_viewby = 'Y') then
      l_viewby_name := l_ranking_attr;
   ELSE
      l_parameter_rec.parameter_name := 'VIEW_BY';
      l_parameter_rec.parameter_value := p_ranking_level;
      l_count := l_parameters.COUNT;
      l_parameters(l_COUNT+1) := l_parameter_rec;
      l_viewby_name := 'VIEWBY';
   END IF;

    STORE_PARAMETERS(p_region_code => p_region_code
                    ,p_function_name => l_function_name
                    ,p_user_id       => l_user_id
                    ,p_session_id    => l_session_id
                    ,p_Responsibility_id => l_resp_id
                    ,p_time_parameter   => p_time_parameter
                    ,p_parameters        => l_parameters
                    ,p_param_ids         => p_param_ids
                    ,x_return_Status     => x_return_Status
                    ,x_msg_count         => x_msg_count
                    ,x_msg_data          => x_msg_data
                    );

   if g_debug_on then
      l_debug_msg := l_debug_msg || 'BIS_PMV_ACTUAL_PVT.STORE_PARAMETERS: '||x_return_status||'*'||x_msg_data;
   end if;

   if g_debug_on then
      l_debug_msg := l_debug_msg || 'Successfully stored the parameters...';
   end if;

   --Now execute the query and get the values back.
   x_return_Status := FND_API.G_RET_STS_SUCCESS;
   --dbms_output.put_line ('About to execute the query');
   BIS_PMV_QUERY_PVT.getQuerySql(
   p_Region_Code => p_region_code,
   p_function_name  => l_function_name,
   p_user_id => l_user_id ,
   p_session_id => l_session_id,
   p_resp_id => l_resp_id,
   p_page_id => p_page_id,
   p_schedule_id => null,
   p_sort_attribute => null,
   p_sort_direction => null,
   p_source        => 'ACTUAL_FOR_KPI',
   x_sql => l_query_string,
   x_target_alias => l_target_alias,
   x_has_target  => l_has_target,
   x_viewby_table => l_viewby_table,
   x_return_status => x_return_status,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data,
   x_bind_variables => l_bind_variables,
   x_plsql_bind_variables => l_plsql_bind_variables,
   x_bind_indexes => l_bind_indexes,
   x_bind_datatypes => l_bind_datatypes,
   x_view_by_Value => l_temp_viewby_value);

/*
   dbms_output.put_line ('The query is '|| substr(l_query_String,1,200));
   dbms_output.put_line (substr(l_query_String,201,200));
   dbms_output.put_line (substr(l_query_String,401,200));
   dbms_output.put_line (substr(l_query_String,601,200));
   dbms_output.put_line (substr(l_query_String,801,200));
   dbms_output.put_line (substr(l_query_String,1001,200));
   dbms_output.put_line (substr(l_query_String,1201,200));
   dbms_output.put_line (substr(l_query_String,1401,200));
*/

   l_query_String := replace(l_query_String, ':', ':x');

   if g_debug_on then
      l_debug_msg := l_debug_msg || 'BIS_PMV_QUERY_PVT.getQuerySql: '||x_return_status||'*'||x_msg_data
                                 ||' sql:'||l_query_string||' bind variables:'||l_plsql_bind_variables
                                 ||' bind indexes:'||l_bind_indexes;
   end if;

   --Get the bind variables in a table.
   if (length(l_plsql_bind_variables) > 0) then
      SETUP_BIND_VARIABLES(
      p_bind_variables => l_plsql_bind_variables,
      x_bind_var_tbl => l_bind_var_tbl);
   end if;

   l_cursor := dbms_sql.open_cursor;
   dbms_sql.parse(l_cursor, l_query_string, DBMS_SQL.native);

   if (l_bind_var_tbl.COUNT > 0) then
    for i in l_bind_var_tbl.FIRST..l_bind_var_tbl.LAST loop
       l_bind_col := ':x'|| i;

       if (l_bind_var_tbl(i) is null or length(l_bind_Var_Tbl(i)) = 0) then
          l_bind_var := null;
       else
          if (substr(l_bind_var_tbl(i),1,1) = '''' and
              substr(l_bind_var_tbl(i), length(l_bind_Var_tbl(i)),1) = '''') then
             l_bind_var := substr(l_bind_Var_tbl(i),2, length(l_bind_Var_tbl(i))-2);
          else
             l_bind_Var := l_bind_Var_tbl(i);
          end if;
       end if;
       --dbms_output.put_line ('bind var '||(i)||':'|| l_bind_var);
       dbms_sql.bind_variable(l_cursor, l_bind_col, l_bind_var);
    end loop;
   end if;

   --dbms_output.put_line ('before describe columns');
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'before describe columns';
   end if;

   dbms_sql.describe_columns(l_cursor, l_col_count, l_desc_tab);

   -- get all of the table column attribute codes and base column definitions
   -- it includes regular measures and calculation measures
   if column_items_cursor%ISOPEN then
      close column_items_cursor;
   end if;
   open column_items_cursor;
   fetch column_items_cursor bulk collect into l_measure_attr_codes, l_measure_base_columns;
   close column_items_cursor;

   for i in p_measure_attribute_codes.FIRST..p_measure_attribute_codes.LAST loop
      for j in l_measure_attr_codes.FIRST..l_measure_attr_codes.LAST loop
          if p_measure_attribute_codes(i) = l_measure_attr_codes(j) then
             if (substr(l_measure_base_columns(j),1,1)='"'
             and (l_plsql_function is not null or
                  (l_plsql_function is null and instr(l_measure_base_columns(j),'/') > 0))) then
                    hasCalculationMeasure := true;
                    exit;
             end if;
          end if;
      end loop;
      if hasCalculationMeasure then
         exit;
      end if;
   end loop;

   l_measure_count := 0;
   for i in 1..l_col_count loop
     --dbms_output.put_line('alias: '||l_desc_tab(i).col_name);
     if g_debug_on then
        l_debug_msg := l_debug_msg || ' alias: '||l_desc_tab(i).col_name;
     end if;

     -- l_selected_attr_codes are only for regular non-calculation measures
     if (l_measure_attr_codes.COUNT > 0) then
        for j in l_measure_attr_codes.FIRST..l_measure_attr_codes.LAST loop
           if (l_desc_tab(i).col_name = l_measure_attr_codes(j)) then
             l_measure_count := l_measure_count + 1;
             l_selected_col_index(l_measure_count) := i;
             l_selected_attr_codes(l_measure_count) := l_measure_attr_codes(j);
             l_selected_base_columns(l_measure_count) := l_measure_base_columns(j);
             exit;
           end if;
        end loop;
     end if;

     if (l_desc_tab(i).col_name = l_viewby_name) then
        l_viewby_val_cnt := i;
        --dbms_output.put_line ('l_viewby_val_cnt:'||i);
        if g_debug_on then
           l_debug_msg := l_debug_msg || ' l_viewby_val_cnt:'||i;
        end if;
     end if;

     if (l_desc_tab(i).col_name = 'VIEWBYID') then
        l_viewby_id_cnt := i;
        --dbms_output.put_line ('l_viewby_id_cnt:'||i);
        if g_debug_on then
           l_debug_msg := l_debug_msg || ' l_viewby_id_cnt:'||i;
        end if;
     end if;

   end loop;

   -- sort the base columns in descending orders along with the attribute codes
   -- for regular non-calculation measures
   if hasCalculationMeasure then
      SORTBY_BASE_COLUMN_LENGTH(p_table1 => l_selected_base_columns
                               ,p_table2 => l_selected_attr_codes
                               ,p_table3 => l_selected_col_index
                               ,x_return_status => x_return_status
                               ,x_msg_count => x_msg_count
                               ,x_msg_data => x_msg_data
                               );
   end if;

   if g_debug_on then
      l_debug_msg := l_debug_msg || 'BIS_PMV_UTIL.sortAttributeCode: '||x_return_status||'*'||x_msg_data;
   end if;

   --if (l_selected_attr_codes.COUNT > 0) then
     l_gt_count := 0;
     --for i in 1..l_measure_count loop
     for i in l_measure_attr_codes.FIRST..l_measure_attr_codes.LAST loop
       --Find out if the selected attribute codes have grand totals defined for them.
       l_gt_attr_code := null;
       IF (c_grandattrib%ISOPEN) THEN
           CLOSE c_grandattrib;
       END IF;

       --OPEN c_grandattrib(l_selected_attr_codes(i));
       OPEN c_grandattrib(l_measure_attr_codes(i));
       FETCH c_grandattrib INTO l_gt_attr_code;
       IF (c_grandattrib%NOTFOUND) THEN
          l_gt_attr_code := null;
       END IF;
       CLOSE c_grandattrib;

       if l_gt_attr_code is not null then
          l_gt_count := l_gt_count + 1;
          l_selected_gt_index(l_gt_count) := i;
          for j in 1..l_col_count loop
            if (l_desc_tab(j).col_name = l_gt_attr_code) then
              l_gt_index(l_gt_count) := j;
              exit;
            end if;
          end loop;
       end if;
     end loop;
   --end if;

   --dbms_output.put_line ('before defining measure columns');
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'before defining measure columns';
   end if;

   if l_measure_count > 0 then
    for i in 1..l_measure_count loop
      dbms_sql.define_column(l_cursor, l_selected_col_index(i), l_measure_value, 200);
    end loop;
   end if;

   --dbms_output.put_line ('before defining grand total columns');
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'before defining grand total columns';
   end if;

   if l_gt_count > 0 then
    for i in 1..l_gt_count loop
      if (l_gt_index(i) is not null and l_gt_index(i) > 0) then
         dbms_sql.define_column(l_cursor, l_gt_index(i), l_gt_value, 200);
      end if;
    end loop;
   end if;

   --dbms_output.put_line ('before defining viewby columns');
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'before defining viewby columns';
   end if;

   if (l_viewby_val_cnt > 0) then
      dbms_sql.define_column(l_cursor, l_viewby_val_cnt, l_viewby_value, 200);
   end if;

   --dbms_output.put_line ('before defining viewbyid columns');
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'before defining viewbyid columns';
   end if;

   if (l_viewby_id_cnt > 0) then
      dbms_sql.define_column(l_cursor, l_viewby_id_cnt, l_viewbyid_value, 200);
   end if;

   --dbms_output.put_line ('before executing cursor');
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'before executing cursor';
   end if;

   ignore := dbms_sql.execute(l_cursor);

   --dbms_output.put_line ('after executing cursor:'||ignore);
   if g_debug_on then
      l_debug_msg := l_debug_msg || 'after executing cursor:' || ignore;
   end if;

   l_rec_count := 0;
   loop
       l_num_of_rows_fetched := dbms_sql.fetch_rows(l_cursor);
       exit when l_num_of_rows_fetched = 0;

       --dbms_output.put_line('row fetched:'||l_num_of_rows_fetched);
       if g_debug_on then
          l_debug_msg := l_debug_msg || 'row fetched:'||l_num_of_rows_fetched;
       end if;

       if (l_viewby_val_cnt > 0) then
           dbms_sql.column_value (l_cursor, l_viewby_val_cnt, l_viewby_value);
       end if;

       if (l_viewby_id_cnt > 0) then
           dbms_sql.column_value (l_cursor, l_viewby_id_cnt, l_viewby_id);
       end if;

       if l_measure_count > 0 then
         for i in 1..l_measure_count loop
           dbms_sql.column_value(l_cursor, l_selected_col_index(i), l_selected_measure_values(i));
         end loop;
       end if;

       if l_gt_count > 0 then
         for i in 1..l_gt_count loop
           if (l_gt_index(i) is not null and l_gt_index(i) > 0) then
              dbms_sql.column_value(l_cursor, l_gt_index(i), l_selected_gt_values(i));
           end if;
         end loop;
       end if;

       for i in 1..p_measure_attribute_codes.COUNT loop
          l_measure_value := null;
          for j in 1..l_measure_attr_codes.COUNT loop
             if p_measure_attribute_codes(i) = l_measure_attr_codes(j) then
                l_Actual_rec.measure_attribute_code := null;
                l_Actual_Rec.view_by_Value := null;
                l_Actual_rec.view_by_id := null;
                l_actual_rec.actual_grandtotal_Value := null;
                l_actual_rec.measure_attribute_code := p_measure_attribute_codes(i);
                l_actual_rec.view_by_value := l_viewby_value;
                l_actual_rec.view_by_id := l_viewby_id;
                if (substr(l_measure_base_columns(j),1,1)='"'
                and (l_plsql_function is not null or
                     (l_plsql_function is null and instr(l_measure_base_columns(j),'/') > 0))) then
                   GET_CALCULATED_VALUE(p_formula => l_measure_base_columns(j)
                                       ,p_measure_base_columns => l_selected_base_columns
                                       ,p_measure_values => l_selected_measure_values
                                       ,x_calculated_value => l_measure_value);
                else
                   for k in 1..l_selected_attr_codes.COUNT loop
                      if p_measure_attribute_codes(i) = l_selected_attr_codes(k) then
                         l_measure_value := l_selected_measure_values(k);
                         exit;
                      end if;
                   end loop;
/*
                   if l_gt_count > 0 then
                      for n in 1..l_gt_count loop
                        --if p_measure_attribute_codes(i) = l_selected_attr_codes(l_selected_gt_index(n)) then
                        if p_measure_attribute_codes(i) = l_measure_attr_codes(l_selected_gt_index(n)) then
                           l_actual_rec.actual_grandtotal_value := l_selected_gt_values(n);
                        exit;
                        end if;
                      end loop;
                   end if;
*/
                end if;

                if l_gt_count > 0 then
                   for n in 1..l_gt_count loop
                      --if p_measure_attribute_codes(i) = l_selected_attr_codes(l_selected_gt_index(n)) then
                      if p_measure_attribute_codes(i) = l_measure_attr_codes(l_selected_gt_index(n)) then
                           l_actual_rec.actual_grandtotal_value := l_selected_gt_values(n);
                         exit;
                      end if;
                   end loop;
                end if;

                l_actual_rec.actual_value := l_measure_value;
                exit;
             end if;
         end loop;
         l_rec_count := l_rec_count + 1;
         x_measure_tbl(l_rec_count) := l_actual_rec;
       end loop;

       l_row_found := l_row_found+1;
       --dbms_output.put_line ('row found:'||l_row_found);
   end loop;

   dbms_sql.close_cursor(l_cursor);

   if (l_row_found <= 0) then
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_data := 'NO DATA FOUND';
   end if;

   x_msg_data := l_debug_msg || x_msg_data;

EXCEPTION
   when others then
     if (dbms_sql.IS_OPEN(l_cursor)) then
         dbms_sql.close_cursor(l_cursor);
     end if;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- x_return_status := SQLERRM;
     --dbms_output.put_line ('The err 2 is '|| x_return_Status);
END GET_ACTUAL_VALUE;

PROCEDURE GET_CALCULATED_VALUE
(p_formula in varchar2
,p_measure_base_columns in BISVIEWER.t_char
,p_measure_values in BISVIEWER.t_char
,x_calculated_value out NOCOPY number
) IS
 l_formula varchar2(32000) := p_formula;
 l_sql varchar2(32000);
 l_bind_count number := 0;
 l_bind_values BISVIEWER.t_char;
 l_bind_col varchar2(2000);
 l_cursor integer;
 ignore integer;
BEGIN

  if substr(l_formula, 1, 1) = '"' then
     l_formula := substr(l_formula,2,length(l_formula)-2);
  end if;

  --dbms_output.put_line ('input formula is: '|| l_formula);

  for i in p_measure_base_columns.FIRST..p_measure_base_columns.LAST loop
    --l_formula := replace(l_formula, p_measure_base_columns(i), p_measure_values(i));
    if instr(l_formula, p_measure_base_columns(i))>0 then
     l_bind_count := l_bind_count + 1;
     l_formula := replace(l_formula, p_measure_base_columns(i), ':x'||l_bind_count);
     l_bind_values(l_bind_count) := p_measure_values(i);
    end if;
  end loop;

  --dbms_output.put_line ('new formula is: '|| l_formula);

  l_sql := 'select '||l_formula||' from dual';
  --dbms_output.put_line('sql: '||l_sql);

   l_cursor := dbms_sql.open_cursor;
   dbms_sql.parse(l_cursor, l_sql, DBMS_SQL.native);

   --dbms_output.put_line ('before binding');

   if (l_bind_count > 0) then
    for i in 1..l_bind_count loop
       l_bind_col := ':x'|| i;
       dbms_sql.bind_variable(l_cursor, l_bind_col, l_bind_values(i));
       --dbms_output.put_line('l_bind_col:'||l_bind_col);
       --dbms_output.put_line('l_bind_value:'||l_bind_values(i));
    end loop;
   end if;

   --dbms_output.put_line ('after binding');

   dbms_sql.define_column(l_cursor, 1, x_calculated_value);

   ignore := dbms_sql.execute_and_fetch(l_cursor);

   --dbms_output.put_line ('after executing');

   dbms_sql.column_value (l_cursor, 1, x_calculated_value);

   --dbms_output.put_line ('before closing cursor');

   dbms_sql.close_cursor(l_cursor);

exception
when others then
   x_calculated_value := null;
   dbms_sql.close_cursor(l_cursor);
END GET_CALCULATED_VALUE;

PROCEDURE SORTBY_BASE_COLUMN_LENGTH
(p_table1    in OUT    NOCOPY BISVIEWER.t_char
,p_table2    in OUT    NOCOPY BISVIEWER.t_char
,p_table3    in OUT    NOCOPY BISVIEWER.t_num
,x_return_status        OUT       NOCOPY VARCHAR2
,x_msg_count            OUT       NOCOPY NUMBER
,x_msg_data             OUT       NOCOPY VARCHAR2
)
IS
   l_count                  NUMBER;
   l_length_tbl             BISVIEWER.t_num;
   l_temp1                  VARCHAR2(32000);
   l_temp2                  VARCHAR2(32000);
   l_temp3                  NUMBER;
   l_temp_length            NUMBER;
BEGIN
   --First get the lengths of all the attribute codes in an array.
   --This is what we will be sorting in descending order.
   IF (p_table1.COUNT > 0) THEN
      FOR l_count IN 1..p_table1.COUNT LOOP
          l_length_tbl(l_count) := length(p_table1(l_count));
      END LOOP;
   END IF;
   --Now that we have the lengths, let's sort them in descending order
   FOR i IN l_length_tbl.FIRST+1..l_length_Tbl.LAST LOOP
         l_temp1 := p_table1(i);
         l_temp2 := p_table2(i);
         l_temp3 := p_table3(i);
         l_temp_length := l_length_tbl(i);
       FOR j IN REVERSE l_length_Tbl.FIRST..(i-1) LOOP
          if l_length_tbl(j) < l_temp_length THEN
             l_length_tbl(j+1) := l_length_tbl(j);
             l_length_tbl(j) := l_temp_length;
             p_table1(j+1) := p_table1(j);
             p_table1(j) := l_temp1;
             p_table2(j+1) := p_table2(j);
             p_table2(j) := l_temp2;
             p_table3(j+1) := p_table3(j);
             p_table3(j) := l_temp3;
          end if;
       END LOOP;
   END LOOP;
END SORTBY_BASE_COLUMN_LENGTH;

END BIS_PMV_ACTUAL_PVT;

/
