--------------------------------------------------------
--  DDL for Package Body HR_SUMMARY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SUMMARY_UTIL" as
/* $Header: hrbsutil.pkb 120.0 2005/05/30 23:06:11 appldev noship $ */
--
l_item_value_id number;
l_key_value_id number;
l_object_version_number number;
--
function create_other_kv(p_business_group_id number
                        ,p_key_type_id number) return boolean is
begin
   --
   hr_utility.set_location('Entering: hr_summary_util.create_other_kv', 10);
   --
   hr_summary_api.create_key_value(p_key_value_id          => l_key_value_id
                                  ,p_business_group_id     => p_business_group_id
                                  ,p_object_version_number => l_object_version_number
                                  ,p_key_type_id           => p_key_type_id
                                  ,p_item_value_id         => zero_item_value_id
                                  ,p_name                  => OTHER);
  --
  hr_utility.set_location('Leaving: hr_summary_util.create_other_kv', 20);
  --
  return TRUE;
end;
--
function get_lookup_values(p_lookup_type varchar2
                          ,p_db_column varchar2
                          ,p_key_type_id number) return varchar2 is
--
cursor c_lookup(p_lookup_type varchar2) is
select lookup_code
from   hr_lookups
where  lookup_type = p_lookup_type;
--
i number;
l_clause varchar2(32000);
--
begin
   --
   hr_utility.set_location('Entering: hr_summary_util.get_lookup_values', 10);
   --
   i := 0;
   for v in c_lookup(p_lookup_type) loop
       if i > 0 then
          l_clause := l_clause ||',';
       else
          l_clause := 'decode('||p_db_column||',';
       end if;
       --
       if v.lookup_code is not null then
           l_clause := l_clause || '''' ||
                        v.lookup_code||''','''||v.lookup_code|| '''';
   ---------------------------------------------------------------
   if store_data then
      --
      hr_summary_api.create_key_value(p_key_value_id          => l_key_value_id
                                     ,p_business_group_id     => g_business_group_id
                                     ,p_object_version_number => l_object_version_number
                                     ,p_key_type_id           => p_key_type_id
                                     ,p_item_value_id         => zero_item_value_id
                                     ,p_name                  => v.lookup_code);
      --
   end if;
   ---------------------------------------------------------------
       end if;
       --
       i := i + 1;
   end loop;
   --
   if l_clause is null then
      l_clause := '''GSP_OTHER''';
   else
      l_clause := l_clause ||',''GSP_OTHER'')';
   end if;
   ---------------------------------------------------------------
   --
   hr_utility.set_location('Leaving: hr_summary_util.get_lookup_values', 20);
   --
   return l_clause;
end get_lookup_values;
--
function get_alternate_values(p_table_name varchar2
                             ,p_column varchar2
                             ,p_db_column varchar2
                             ,p_key_type_id number) return varchar2 is
--
cursor c_user_table(p_table_name varchar2
                   ,p_column varchar2) is
select ur.ROW_LOW_RANGE_OR_NAME name
,      uci1.value value
from pay_user_column_instances_f uci1
,    pay_user_rows_f ur
,    pay_user_columns uc1
,    pay_user_tables t
where uci1.USER_ROW_ID = ur.USER_ROW_ID
and   sysdate between ur.effective_start_date and ur.effective_end_date
and   uci1.USER_COLUMN_ID = uc1.USER_COLUMN_ID
and   sysdate between uci1.effective_start_date and uci1.effective_end_date
and   uc1.USER_COLUMN_NAME = p_column
and   ur.user_table_id = t.user_table_id
and   uc1.user_table_id = t.user_table_id
and   t.USER_TABLE_NAME = p_table_name
and   uci1.value is not null
and   t.business_group_id = g_business_group_id;
--
i number;
l_clause varchar2(32000);
--
begin
   --
   hr_utility.set_location('Entering: hr_summary_util.get_alternate_values', 10);
   --
   i := 0;
   for v in c_user_table(p_table_name
                        ,p_column) loop
       if i > 0 then
          l_clause := l_clause ||',';
       else
          l_clause := 'decode('||p_db_column||',';
       end if;
       --
       if v.value is not null then
           l_clause := l_clause || '''' ||
                        v.name||''','''||v.value|| '''';
   ---------------------------------------------------------------
   if store_data then

      hr_summary_api.create_key_value(p_key_value_id          => l_key_value_id
                                     ,p_business_group_id     => g_business_group_id
                                     ,p_object_version_number => l_object_version_number
                                     ,p_key_type_id           => p_key_type_id
                                     ,p_item_value_id         => zero_item_value_id
                                     ,p_name                  => v.value);

   end if;
   ---------------------------------------------------------------
       end if;
       --
       i := i + 1;
   end loop;
   --
   if l_clause is null then
      l_clause := ''''||OTHER||'''';
   else
      l_clause := l_clause ||','||''''||OTHER||''''||')';
   end if;
   ---------------------------------------------------------------
   --
   hr_utility.set_location('Leaving: hr_summary_util.get_alternate_values', 20);
   --
   return l_clause;
end;
--
--
function get_band_values(p_table_name varchar2
                        ,p_low_column varchar2
                        ,p_high_column varchar2
                        ,p_db_column varchar2
                        ,p_key_type_id number) return varchar2 is
--
l_legislation_code per_business_groups.legislation_code%type;
--
cursor c_user_table(p_table_name varchar2
                   ,p_low_column varchar2
                   ,p_high_column varchar2) is
select ur.ROW_LOW_RANGE_OR_NAME name
,      uci1.value low_value
,      uci2.value high_value
,      ur.display_sequence
from pay_user_column_instances_f uci1
,    pay_user_column_instances_f uci2
,    pay_user_rows_f ur
,    pay_user_columns uc1
,    pay_user_columns uc2
,    pay_user_tables t
where uci1.USER_ROW_ID = ur.USER_ROW_ID
and   sysdate between ur.effective_start_date and ur.effective_end_date
and   uci1.USER_COLUMN_ID = uc1.USER_COLUMN_ID
and   sysdate between uci1.effective_start_date and uci1.effective_end_date
and   uci2.USER_ROW_ID = ur.USER_ROW_ID
and   uci2.USER_COLUMN_ID = uc2.USER_COLUMN_ID
and   sysdate between uci2.effective_start_date and uci2.effective_end_date
and   uc1.USER_COLUMN_NAME = p_low_column
and   uc2.USER_COLUMN_NAME = p_high_column
and   ur.user_table_id = t.user_table_id
and   uc1.user_table_id = t.user_table_id
and   uc2.user_table_id = t.user_table_id
and   t.USER_TABLE_NAME = p_table_name
and   nvl(to_char(t.business_group_id),t.legislation_code) = decode(t.business_group_id,null,l_legislation_code,to_char(g_business_group_id));
--
i number;
l_clause varchar2(32000);
--
begin
   --
   hr_utility.set_location('Entering: hr_summary_util.get_band_values', 10);
   --
   select legislation_code
     into l_legislation_code
     from per_business_groups
     where business_group_id = g_business_group_id;
   --
   i := 0;
   for v in c_user_table(p_table_name,p_low_column,p_high_column) loop
       if i > 0 then
          l_clause := l_clause ||',';
       else
          l_clause := 'decode(2,';
       end if;
       --
       l_clause := l_clause ||
   'decode(sign('||p_db_column||'-'||v.low_value||'),1,1,0,1,0) + '||
   'decode(sign('||v.high_value||'-'||p_db_column||'),1,1,0,1,0)'||
                           ','''||v.name||'''';
       --
       i := i + 1;
   ---------------------------------------------------------------
   if store_data then

      hr_summary_api.create_key_value(p_key_value_id          => l_key_value_id
                                     ,p_business_group_id     => g_business_group_id
                                     ,p_object_version_number => l_object_version_number
                                     ,p_key_type_id           => p_key_type_id
                                     ,p_item_value_id         => zero_item_value_id
                                     ,p_name                  => v.name);

   end if;
   ---------------------------------------------------------------
   end loop;
   --
   if l_clause is null then
      l_clause := ''''||OTHER||'''';
   else
      l_clause := l_clause || ','''||OTHER||''')';
   end if;
   --
   hr_utility.set_location('Leaving: hr_summary_util.get_band_values', 20);
   --
   return l_clause;
End;
--
procedure initialize_run(p_store_data boolean
                        ,p_business_group_id number
                        ,p_template_id number
                        ,p_process_run_name varchar2
                        ,p_process_type varchar2
                        ,p_parameters prmTabType) is
--
l_process_run_id number;
l_parameter_id number;
begin
  --
  hr_utility.set_location('Entering: hr_summary_util.initialize_run', 10);
  --
  if p_store_data then
     hr_summary_api.create_process_run (p_process_run_id         => l_process_run_id
                                       ,p_business_group_id      => p_business_group_id
                                       ,p_object_version_number  => l_object_version_number
                                       ,p_name                   => p_process_run_name
                                       ,p_template_id            => p_template_id
                                       ,p_process_type           => p_process_type);
     --
     if p_parameters.count > 0 then
        for i in p_parameters.first..p_parameters.last loop
            hr_summary_api.create_parameter (p_parameter_id           => l_parameter_id
                                            ,p_business_group_id      => p_business_group_id
                                            ,p_object_version_number  => l_object_version_number
                                            ,p_process_run_id         => l_process_run_id
                                            ,p_name                   => p_parameters(i).name
                                            ,p_value                  => p_parameters(i).value);
        end loop;
     end if;
     --
     process_run_id := l_process_run_id;
  end if;
  --
  g_business_group_id := p_business_group_id;
  --
  hr_utility.set_location('Leaving: hr_summary_util.initialize_run', 20);
  --
end;
  --
procedure initialize_procedure (p_business_group_id number) is
begin
   --
   hr_utility.set_location('Entering: hr_summary_util.initialize_procedure', 10);
   --
   if store_data then
      hr_summary_api.create_item_value(p_item_value_id         => zero_item_value_id
                                      ,p_business_group_id     => p_business_group_id
                                      ,p_object_version_number => l_object_version_number
                                      ,p_process_run_id        => process_run_id
                                      ,p_item_type_usage_id    => item_type_usage_id
                                      ,p_textvalue             => null
                                      ,p_numvalue1             => 0
                                      ,p_numvalue2             => null
                                      ,p_datevalue             => null);

   end if;
   --
   hr_utility.set_location('Leaving: hr_summary_util.initialize_procedure', 20);
   --
end;
--
procedure load_item_value(p_business_group_id number
                         ,p_value number) is
begin
   --
   hr_utility.set_location('Entering: hr_summary_util.load_item_value', 10);
   --
   hr_summary_api.create_item_value(p_item_value_id         => l_item_value_id
                                   ,p_business_group_id     => p_business_group_id
                                   ,p_object_version_number => l_object_version_number
                                   ,p_process_run_id        => process_run_id
                                   ,p_item_type_usage_id    => item_type_usage_id
                                   ,p_textvalue             => null
                                   ,p_numvalue1             => p_value
                                   ,p_numvalue2             => null
                                   ,p_datevalue             => null);
   --
   hr_utility.set_location('Leaving: hr_summary_util.load_item_value', 20);
   --
--dbms_output.put_line(l_item_value_id ||' '||item_type_usage_id||' '||p_value);
end load_item_value;
--
/*
procedure load_item_key_value(p_business_group_id number
                             ,p_key_type_id number
                             ,p_other_entry IN OUT boolean
                             ,p_value varchar2) is
begin
   hr_summary_api.create_key_value(p_key_value_id          => l_key_value_id
                                  ,p_business_group_id     => p_business_group_id
                                  ,p_object_version_number => l_object_version_number
                                  ,p_key_type_id           => p_key_type_id
                                  ,p_item_value_id         => l_item_value_id
                                  ,p_name                  => p_value);
   --
   if p_value = 'Other' and not p_other_entry then
      p_other_entry := create_other_kv(p_business_group_id
                                      ,p_key_type_id);
   end if;
end load_item_key_value;
*/
--
function get_cagr_values (p_key_type_id in number
                         ,p_db_column   in varchar2
                         ,p_table_name  in varchar2
                         ,p_column_name in varchar2) return varchar2 is
cursor csr_get_info is
select fsv.id_flex_num            id_flex_num
,      fsv.id_flex_structure_name structure_name
,      uci1.value                 segment_value
,      ur.display_sequence
from pay_user_column_instances_f uci1
,    pay_user_rows_f ur
,    pay_user_columns uc1
,    pay_user_tables t
,    fnd_id_flex_structures_vl fsv
where uci1.USER_ROW_ID = ur.USER_ROW_ID
and sysdate between ur.effective_start_date and ur.effective_end_date
and uci1.USER_COLUMN_ID = uc1.USER_COLUMN_ID
and sysdate between uci1.effective_start_date and uci1.effective_end_date
and uc1.USER_COLUMN_NAME = p_column_name
and ur.user_table_id = t.user_table_id
and uc1.user_table_id = t.user_table_id
and t.USER_TABLE_NAME = p_table_name
and ur.ROW_LOW_RANGE_OR_NAME = fsv.id_flex_structure_name
and fsv.id_flex_code = 'CAGR'
and fsv.application_id = 800
and t.business_group_id = g_business_group_id;
--
l_clause       varchar2(32000) :=NULL;
l_seg_string   varchar2(1000);
l_stmt         varchar2(32000);
l_key_value    hr_summary_key_value.name%type;
source_cursor  integer;
ignore         integer;
--
begin
  --
  hr_utility.set_location('Entering: hr_summary_util.get_cagr_values', 10);
  --
  for l_rec in csr_get_info loop
      l_seg_string := REPLACE(l_rec.segment_value,'SEGMENT','cagr_def.SEGMENT');
      l_seg_string := REPLACE(l_seg_string,',','||'' ''||');
      l_seg_string := l_rec.id_flex_num||'||'' ''||'||''''||l_rec.structure_name||''''||'||'' : ''||'||l_seg_string;
      if csr_get_info%rowcount = 1 then
           l_clause := 'decode('||p_db_column;
           l_clause := l_clause||','||l_rec.id_flex_num||','||l_seg_string;
      else
         l_clause := l_clause||','||l_rec.id_flex_num||','||l_seg_string;
      end if;
      --
      l_stmt := 'select distinct '||l_seg_string||
                ' from per_cagr_grades_def cagr_def '||
                ' ,    per_cagr_grades cgr'||
                ' ,    per_cagr_grade_structures cgs'||
                ' ,    per_collective_agreements cag'||
                ' where cgs.id_flex_num = '||l_rec.id_flex_num||
                ' and cagr_def.cagr_grade_def_id = cgr.cagr_grade_def_id'||
                ' and cgr.cagr_grade_structure_id = cgs.cagr_grade_structure_id'||
                ' and cgs.collective_agreement_id = cag.collective_agreement_id'||
                ' and cag.business_group_id = '||to_char(g_business_group_id);
      --
      source_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(source_cursor,l_stmt,dbms_sql.v7);
      dbms_sql.define_column(source_cursor,1,l_key_value,80);
      ignore := dbms_sql.execute(source_cursor);
      --
      loop
         if dbms_sql.fetch_rows(source_cursor) > 0 then
            dbms_sql.column_value(source_cursor,1,l_key_value);
            if store_data then
               hr_summary_api.create_key_value(p_key_value_id          => l_key_value_id
                                              ,p_business_group_id     => g_business_group_id
                                              ,p_object_version_number => l_object_version_number
                                              ,p_key_type_id           => p_key_type_id
                                              ,p_item_value_id         => zero_item_value_id
                                              ,p_name                  => l_key_value);
            end if;
         else
            exit;
         end if;
      end loop;
      dbms_sql.close_cursor(source_cursor);
--
  end loop;
--
  if l_clause is null then
     l_clause := ''''||OTHER||'''';
  else
     l_clause := l_clause ||','||''''||OTHER||''''||')';
  end if;
--
  hr_utility.set_location('Leaving: hr_summary_util.get_cagr_values', 20);
--
  return (l_clause);
--
end get_cagr_values;
--
function get_month (p_key_type_id in number
                   ,p_db_column   in varchar2) return varchar2 is
--
l_month        varchar2(100);
l_stmt         varchar2(1000);
source_cursor  integer;
ignore         integer;
l_key_value    hr_summary_key_value.name%type;
--
begin
  --
  hr_utility.set_location('Entering: hr_summary_util.get_month', 10);
  --
  l_month := 'to_char(to_date('||''''||'P_YEAR'||p_db_column||'01'||''''||',''YYYYMMDD''),''MON'')';
  --
  for i in 1..12 loop
      l_stmt := 'select to_char(to_date('||''''||'1999'||lpad(to_char(i),2,'0')||'01'||''''||',''YYYYMMDD''),''MON'') from dual';
      --
      source_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(source_cursor,l_stmt,dbms_sql.v7);
      dbms_sql.define_column(source_cursor,1,l_key_value,80);
      ignore := dbms_sql.execute(source_cursor);
      --
      if dbms_sql.fetch_rows(source_cursor) > 0 then
         dbms_sql.column_value(source_cursor,1,l_key_value);
      end if;
      if store_data then
         hr_summary_api.create_key_value(p_key_value_id          => l_key_value_id
                                        ,p_business_group_id     => g_business_group_id
                                        ,p_object_version_number => l_object_version_number
                                        ,p_key_type_id           => p_key_type_id
                                        ,p_item_value_id         => zero_item_value_id
                                        ,p_name                  => l_key_value);
      end if;
  end loop;
  dbms_sql.close_cursor(source_cursor);
  --
  hr_utility.set_location('Leaving: hr_summary_util.get_month', 20);
  --
  return l_month;
  --
end get_month;
end;

/
