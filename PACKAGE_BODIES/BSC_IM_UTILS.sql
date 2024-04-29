--------------------------------------------------------
--  DDL for Package Body BSC_IM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_IM_UTILS" AS
/*$Header: BSCOLUTB.pls 120.9 2006/07/10 07:54:19 rkumar ship $*/

-- Start of apis added by arun for bug 3876730
-- from s or sb table name, parse the indicator number
-- assumed to be of the form BSC_S_3005_0_0_1 or BSC_S_4885_0_2_PT
-- or BSC_SB_4885_0_2_1
FUNCTION getParsedIndicNumber(p_Stable IN VARCHAR2) RETURN VARCHAR2
IS
cursor cIndicator is
select substr(p_Stable,  instr(p_Stable, '_',1, 2)+1,
   instr(p_Stable, '_', 1, 3)- (instr(p_Stable, '_',1, 2)+1))
from dual;
l_indicator NUMBER;
BEGIN
  OPEN cIndicator;
  FETCH cIndicator INTO l_indicator;
  CLOSE cIndicator;
  return l_indicator;
  exception when others then
     write_to_log_file('Exception in getParsedIndicNumber for table name = '||p_Stable);
     raise;
END;

-- given a MV's fk, tell
-- whether zero code is needed or not

function needs_zero_code_mv(
p_mv_name varchar2,
p_kpi varchar2,
p_fk varchar2)
return boolean is
--------------------------------------------------------------------
cursor cZeroCode is
select count(1)from bsc_db_calculations calc
where calc.calculation_type = 4
and calc.table_name =
  (select table_name
   from bsc_kpi_data_tables data
   where
   data.indicator = p_kpi
   and data.mv_name = p_mv_name
   and rownum=1)
and calc.parameter1 = p_fk;
--------------------------------------------------------------------
l_count number;
begin
  l_count := 0;
  open cZeroCode;
  fetch cZeroCode into l_count;
  close cZeroCode;
  if (l_count=0) then
    return false;
  else
    return true;
  end if;
    exception when others then
     write_to_log_file('Exception in needs_zero_code_mv for mv name = '||p_mv_name ||', p_kpi = '||p_kpi||', fk ='||p_fk);
     raise;

end;

-- given a Base or Projection table's fk, tell
-- whether zero code is needed or not
function needs_zero_code_b_pt(
p_b_pt_table_name varchar2,
p_fk varchar2)
return boolean is
--------------------------------------------
cursor cSTableNameForB is
select table_name from bsc_db_tables_rels
where table_name like 'BSC_S%'
connect by source_table_name = prior table_name
start with source_table_name = p_b_pt_table_name;
--------------------------------------------
cursor cSTableNameForPT(p_kpi number) is
select projection_data from bsc_kpi_data_tables
where indicator = p_kpi
and projection_data = p_b_pt_table_name;
--------------------------------------------
cursor cZeroCode(p_sTable IN VARCHAR2) is
select count(1) from bsc_db_calculations calc
where calc.calculation_type = 4
and calc.table_name = p_sTable
and calc.parameter1 = p_fk;
--------------------------------------------
l_count number;
l_sTable VARCHAR2(100);
--------------------------------------------
l_indicator number;
begin
  l_count := 0;

  if (p_b_pt_table_name like 'BSC_S%PT') then -- pt table
    l_indicator := getParsedIndicNumber(p_b_pt_table_name);
    open cSTableNameForPT(l_indicator);
    fetch cSTableNameForPT into l_sTable;
    close cSTableNameForPT;
  else
    open cSTableNameForB;
    fetch cSTableNameForB into l_sTable;
    close cSTableNameForB;
  end if;

  IF (l_sTable is null) then
  	return false;
  END IF;

  open cZeroCode(l_sTable);
  fetch cZeroCode into l_count;
  close cZeroCode;

  if (l_count=0) then
    return false;
  else
    return true;
  end if;
  exception when others then
    write_to_log_file('Exception in reorder_index'||sqlerrm);
    write_to_log_file('table name = '||p_b_pt_table_name||', fk = '||p_fk);
    raise;
end;

-- given a list of columns for the index
-- reorder them for bug 3876730
function reorder_index(p_b_pt_table_name IN varchar2, colColumns IN varchar_tabletype) return varchar2 is
l_periodicity_id_exists boolean;
l_year_exists boolean;
l_period_exists boolean;
l_type_exists boolean;
l_stmt varchar2(1000);
l_zero_code_cols varchar2(1000) ;
i number :=0;
begin

  i := colColumns.first;
  loop
    EXIT WHEN colColumns.count = 0;
    if (colColumns(i) = 'PERIODICITY_ID') then
        l_periodicity_id_exists := true;
    elsif (colColumns(i) = 'YEAR') then
        l_year_exists := true;
    elsif (colColumns(i) = 'PERIOD') then
        l_period_exists := true;
    elsif (colColumns(i) = 'TYPE') then
        l_type_exists := true;
    end if;
    exit when i=colColumns.last;
    i := colColumns.next(i);
  end loop;

  -- bug 3876730, add in the following order
  -- 'PERIODICITY_ID', 'YEAR', 'PERIOD', 'TYPE'
  l_stmt := null;
  if (l_periodicity_id_exists) then
    l_stmt := l_stmt||'PERIODICITY_ID,';
  end if;
  if (l_year_exists) then
    l_stmt := l_stmt||'YEAR,';
  end if;
  if (l_period_exists) then
    l_stmt := l_stmt||'PERIOD,';
  end if;
  if (l_type_exists) then
    l_stmt := l_stmt||'TYPE,';
  end if;

  l_zero_code_cols := null;
  i := colColumns.first;
  LOOP
    EXIT WHEN colColumns.count = 0;
    if (colColumns(i) not in ('PERIODICITY_ID', 'YEAR', 'PERIOD', 'TYPE')) then
      if(BSC_IM_UTILS.needs_zero_code_b_pt(p_b_pt_table_name, colColumns(i))) then
        l_zero_code_cols := l_zero_code_cols||colColumns(i)||',';
      else
        l_stmt:=l_stmt||colColumns(i)||',';
      end if;
    end if;
    exit when i = colColumns.last;
    i := colColumns.next(i);
  end loop;

  if (l_zero_code_cols is not null) then
    l_stmt := l_stmt ||l_zero_code_cols;
  end if;
  if (l_stmt is not null) then
     l_stmt := substr(l_stmt, 1, length(l_stmt)-1);
  end if;

  return l_stmt;
  exception when others then
    write_to_log_file('Exception in reorder_index'||sqlerrm);
    write_to_log_file('Table name = '||p_b_pt_table_name );
    raise;
end;

-- end of apis added by arun for bug 3876730

procedure open_file(p_object_name varchar2) is
l_dir varchar2(200);
Begin
  l_dir:=null;
  l_dir:=fnd_profile.value('UTL_FILE_LOG');
  if l_dir is  null then
    l_dir:=fnd_profile.value('EDW_LOGFILE_DIR');
  end if;
  if l_dir is null then
    l_dir:='/sqlcom/log';
  end if;
  FND_FILE.PUT_NAMES(p_object_name||'.log',p_object_name||'.out',l_dir);
Exception when others then
  null;
End;

procedure write_to_file(p_type varchar2,p_message varchar2,p_new_line boolean) is
l_len number;
l_start number:=1;
l_end number:=1;
last_reached boolean:=false;
Begin
  if p_message is null or p_message='' then
    return;
  end if;
  l_len:=nvl(length(p_message),0);
  if l_len <=0 then
    return;
  end if;
  while true loop
   l_end:=l_start+250;
   if l_end >= l_len then
    l_end:=l_len;
    last_reached:=true;
   end if;
   if p_new_line then
     if p_type='LOG' then
       FND_FILE.PUT_LINE(FND_FILE.LOG,substr(p_message, l_start, 250));
     else
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,substr(p_message, l_start, 250));
     end if;
   else
     if p_type='LOG' then
       FND_FILE.PUT(FND_FILE.LOG,substr(p_message, l_start, 250)||' ');
     else
       FND_FILE.PUT(FND_FILE.OUTPUT,substr(p_message, l_start, 250)||' ');
     end if;
   end if;
   l_start:=l_start+250;
   if last_reached then
    exit;
   end if;
  end loop;
Exception when others then
  null;
End;

procedure write_to_log(p_message varchar2,p_new_line boolean) is
Begin
  write_to_file('LOG',p_message,p_new_line);
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  null;
End;

procedure write_to_log_file(p_message varchar2) is
begin
  write_to_log(p_message,true);
Exception when others then
  null;
end;

procedure write_to_log_file_s(p_message varchar2) is
begin
  write_to_log(p_message,false);
Exception when others then
  null;
end;

procedure write_to_log_file_n(p_message varchar2) is
begin
  write_to_log_file('  ');
  write_to_log_file(p_message);
Exception when others then
  null;
end;

procedure write_to_debug_n(p_message varchar2) is
begin
  if g_debug then
    write_to_log_file_n(p_message);
  end if;
Exception when others then
  null;
end;

procedure write_to_debug(p_message varchar2) is
begin
  if g_debug then
    write_to_log_file(p_message);
  end if;
Exception when others then
  null;
end;

procedure write_to_out_file(p_message varchar2) is
begin
  write_to_file('OUT',p_message,true);
Exception when others then
  null;
end;

procedure write_to_out_file_s(p_message varchar2) is
begin
  write_to_file('OUT',p_message,false);
Exception when others then
  null;
end;

procedure write_to_out_file_n(p_message varchar2) is
begin
  write_to_out_file('  ');
  write_to_out_file(p_message);
Exception when others then
  null;
end;

function get_time return varchar2 is
begin
  return ' '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS');
Exception when others then
  null;
End;

function is_column_in_object(p_object varchar2,p_column varchar2) return boolean is
Begin
  g_stmt:='select '||p_column||' from '||p_object||' where rownum=1';
  write_to_debug_n(g_stmt);
  execute immediate g_stmt;
  return true;
Exception when others then
  if sqlcode=-00904 then
    write_to_debug_n('Column '||p_column||' does not exist in '||p_object);
    return false;
  end if;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in is_column_in_object '||sqlerrm);
  return false;
End;

function in_array(p_table varchar_tabletype,p_number_table number,p_value varchar2) return boolean is
Begin
  for i in 1..p_number_table loop
    if lower(p_table(i))=lower(p_value) then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in in_array '||sqlerrm);
  return false;
End;

function in_array(p_table number_tabletype,p_number_table number,p_value number) return boolean is
Begin
  for i in 1..p_number_table loop
    if p_table(i)=p_value then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in in_array '||sqlerrm);
  return false;
End;

function in_array(p_table number_tabletype, p_table2 varchar_tabletype,
p_number_table number,p_value number,p_value2 varchar2) return boolean is
Begin
  for i in 1..p_number_table loop
    if p_table(i)=p_value and lower(p_table2(i))=lower(p_value2) then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in in_array '||sqlerrm);
  return false;
End;

function in_array(p_table number_tabletype, p_table2 number_tabletype,
p_number_table number,p_value number,p_value2 number) return boolean is
Begin
  for i in 1..p_number_table loop
    if p_table(i)=p_value and p_table2(i)=p_value2 then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in in_array '||sqlerrm);
  return false;
End;

function in_array(p_table varchar_tabletype, p_table2 varchar_tabletype,
p_number_table number,p_value varchar2,p_value2 varchar2) return boolean is
Begin
  for i in 1..p_number_table loop
    if lower(p_table(i))=lower(p_value) and lower(p_table2(i))=lower(p_value2) then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in in_array '||sqlerrm);
  return false;
End;

function in_array(p_table1 number_tabletype, p_table2 number_tabletype,
p_table3 number_tabletype,p_number_table number,p_value1 number,
p_value2 number,p_value3 number) return boolean is
Begin
  for i in 1..p_number_table loop
    if p_table1(i)=p_value1 and p_table2(i)=p_value2 and p_table3(i)=p_value3 then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in in_array '||sqlerrm);
  return false;
End;

function add_distinct_values_to_table(
p_table in out nocopy varchar_tabletype,
p_number_table in out nocopy number,
p_values_table varchar_tabletype,
p_number_values_table number,
p_options varchar2) return boolean is
l_found boolean;
l_table varchar_tabletype;
l_number_table number:=0;
Begin
  for i in 1..p_number_values_table loop
    l_found:=false;
    for j in 1..p_number_table loop
      if p_options = 'case' then
        if p_table(j)=p_values_table(i) then
          l_found:=true;
          exit;
        end if;
      else
        if lower(p_table(j))=lower(p_values_table(i)) then
          l_found:=true;
          exit;
        end if;
      end if;
    end loop;
    if l_found=false then
      l_number_table:=l_number_table+1;
      l_table(l_number_table):=p_values_table(i);
    end if;
  end loop;
  if g_debug then
    write_to_debug_n('The additional values');
    for i in 1..l_number_table loop
      write_to_debug(l_table(i));
    end loop;
  end if;
  for i in 1..l_number_table loop
    p_number_table:=p_number_table+1;
    p_table(p_number_table):=l_table(i);
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in add_distinct_values_to_table '||sqlerrm);
  return false;
End;

function add_distinct_values_to_table(
p_table in out nocopy varchar_tabletype,
p_number_table in out nocopy number,
p_value varchar2,
p_options varchar2) return boolean is
l_found boolean:=false;
Begin
  for j in 1..p_number_table loop
    if p_options = 'case' then
      if p_table(j)=p_value then
        l_found:=true;
        exit;
      end if;
    else
      if lower(p_table(j))=lower(p_value) then
        l_found:=true;
        exit;
      end if;
    end if;
  end loop;
  if l_found=false then
    write_to_debug_n('Adding the value '||p_value);
    p_number_table:=p_number_table+1;
    p_table(p_number_table):=p_value;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in add_distinct_values_to_table '||sqlerrm);
  return false;
End;

procedure set_globals(p_debug boolean) is
Begin
  g_debug:=p_debug;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  null;
End;

function get_db_user(
p_product varchar2,
p_db_user out nocopy varchar2
)return boolean is
l_dummy1 varchar2(2000);
l_dummy2 varchar2(2000);
l_db_user varchar2(200);
Begin

  p_db_user:=bsc_apps.get_user_schema(p_product);
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_db_user '||sqlerrm);
  return false;
End;

function read_global return number is
Begin
  if g_id is null then
    g_id:=1;
  end if;
  g_id:=g_id+1;
  return g_id;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in read_global '||sqlerrm);
  return -1;
End;

function read_sequence(p_seq varchar) return number is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_id number;
Begin
  g_stmt:='select '||p_seq||'.nextval from dual';
  write_to_debug_n(g_stmt);
  execute immediate g_stmt into l_id;
  return l_id;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in read_sequence '||sqlerrm);
  return -1;
End;

function sort_number_array(
p_list number_tabletype,
p_number_list number,
p_direction varchar2,
p_sorted_list out nocopy number_tabletype) return boolean is
l_temp number;
Begin
  if g_debug then
    write_to_log_file_n('In sort_number_array '||p_direction);
  end if;
  p_sorted_list:=p_list;
  if g_debug then
    write_to_debug_n('Before sort');
    for i in 1..p_number_list loop
      write_to_debug(p_sorted_list(i));
    end loop;
  end if;
  if p_direction='ASC' then
    for i in 1..p_number_list-1 loop
      for j in 1..(p_number_list-i) loop
        if p_sorted_list(j) > p_sorted_list(j+1) then
          l_temp:= p_sorted_list(j+1);
          p_sorted_list(j+1):=p_sorted_list(j);
          p_sorted_list(j):=l_temp;
        end if;
      end loop;
    end loop;
  else
    for i in 1..p_number_list-1 loop
      for j in 1..(p_number_list-i) loop
        if p_sorted_list(j) < p_sorted_list(j+1) then
          l_temp:= p_sorted_list(j+1);
          p_sorted_list(j+1):=p_sorted_list(j);
          p_sorted_list(j):=l_temp;
        end if;
      end loop;
    end loop;
  end if;
  if g_debug then
    write_to_debug_n('After sort');
    for i in 1..p_number_list loop
      write_to_debug(p_sorted_list(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in sort_number_array '||sqlerrm);
  return false;
End;

function get_index(p_table varchar_tabletype,p_number_table number,p_value varchar2) return number is
Begin
  for i in 1..p_number_table loop
    if lower(p_table(i))=lower(p_value) then
      return i;
    end if;
  end loop;
  return 0;
Exception when others then
  write_to_log_file_n('Error in get_index '||sqlerrm);
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  return -1;
End;

function get_index(p_table number_tabletype,p_number_table number,p_value number) return number is
Begin
  for i in 1..p_number_table loop
    if p_table(i)=p_value then
      return i;
    end if;
  end loop;
  return 0;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_index '||sqlerrm);
  return -1;
End;

function get_index(
p_table_1 varchar_tabletype,
p_table_2 number_tabletype,
p_number_table number,
p_value_1 varchar2,
p_value_2 number
) return number is
Begin
  for i in 1..p_number_table loop
    if lower(p_table_1(i))=lower(p_value_1) and p_table_2(i)=p_value_2 then
      return i;
    end if;
  end loop;
  return 0;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_index '||sqlerrm);
  return -1;
End;

function get_index(
p_table_1 varchar_tabletype,
p_table_2 varchar_tabletype,
p_number_table number,
p_value_1 varchar2,
p_value_2 varchar2
) return number is
Begin
  for i in 1..p_number_table loop
    if lower(p_table_1(i))=lower(p_value_1) and lower(p_table_2(i))=lower(p_value_2) then
      return i;
    end if;
  end loop;
  return 0;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_index '||sqlerrm);
  return -1;
End;

function get_rank(
p_parent_array varchar_tabletype,
p_child_array varchar_tabletype,
p_number_array number,
p_rep_array out nocopy varchar_tabletype,
p_rep_rank out nocopy number_tabletype,
p_number_rep_array out nocopy number,
p_max_rank out nocopy number
) return boolean is
l_seed_child varchar_tabletype;
l_number_seed_child number;
l_rep_array varchar_tabletype;
l_rep_rank number_tabletype;
l_number_rep_array number;
l_index number;
p_rank number; --rkumar: bug 5335536
Begin
  if g_debug then
    write_to_log_file_n('In get_rank');
    write_to_log_file('---------------------------------------------');
  end if;
  p_number_rep_array:=0;
  l_number_seed_child:=0;
  p_max_rank:=0;
  if p_number_array is null or p_number_array<=0 then
    return true;
  end if;
  --seed child contains all the children that are not parent
  for i in 1..p_number_array loop
    if in_array(p_parent_array,p_number_array,p_child_array(i))=false then
      l_number_seed_child:=l_number_seed_child+1;
      l_seed_child(l_number_seed_child):=p_child_array(i);
    end if;
  end loop;
  if l_number_seed_child=0 then
    if g_debug then
      write_to_log_file_n('seed child not found. Error ');
    end if;
    return false;
  else
    if g_debug then
      write_to_log_file_n('The seed tables ');
      for i in 1..l_number_seed_child loop
        write_to_log_file(l_seed_child(i));
      end loop;
    end if;
  end if;
  l_number_rep_array:=0;
  -- filled rep_array with all the unique elements from parent_array and set the rank to 0
  for i in 1..p_number_array loop
    if in_array(l_rep_array,l_number_rep_array,p_parent_array(i))=false then
      l_number_rep_array:=l_number_rep_array+1;
      l_rep_array(l_number_rep_array):=p_parent_array(i);
      l_rep_rank(l_number_rep_array):=0;
    end if;
  end loop;
  --filled rep_array with all the unique elements from chld_array and set the rank to 0
  for i in 1..p_number_array loop
    if in_array(l_rep_array,l_number_rep_array,p_child_array(i))=false then
      l_number_rep_array:=l_number_rep_array+1;
      l_rep_array(l_number_rep_array):=p_child_array(i);
      if substr(p_child_array(i),1,7)='BSC_SB_' then   --rkumar:bug5335536
        l_rep_rank(l_number_rep_array):= -1;
      else
        l_rep_rank(l_number_rep_array):=0;
      end if;
    end if;
  end loop;
  for i in 1..l_number_seed_child loop
     --rkumar: bug5335536 Here check for l_seed_child(i) if it matches _SB_ call the set rank with p_rank as -1
    if substr(l_seed_child(i),1,7)='BSC_SB_' then
      p_rank:= -1;
    else
      p_rank:=0;
    end if;

    if set_rank(
      p_parent_array,
      p_child_array,
      p_number_array,
      l_seed_child(i),
      p_rank,
      l_rep_array,
      l_rep_rank,
      l_number_rep_array)=false then
      return false;
    end if;
  end loop;
  for i in 1..l_number_rep_array loop
    if p_max_rank<l_rep_rank(i) then
      p_max_rank:=l_rep_rank(i);
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The rep tables and their rank p_max_rank='||p_max_rank);
    for i in 1..l_number_rep_array loop
      write_to_log_file(l_rep_array(i)||' '||l_rep_rank(i));
    end loop;
    write_to_log_file('---------------------------------------------');
  end if;
  p_rep_array:=l_rep_array;
  p_rep_rank:=l_rep_rank;
  p_number_rep_array:=l_number_rep_array;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_rank '||sqlerrm);
  return false;
End;

function set_rank(
p_parent_array varchar_tabletype,
p_child_array varchar_tabletype,
p_number_array number,
p_child_level varchar2,
p_rank number,
p_rep_array in out nocopy varchar_tabletype,
p_rep_rank in out nocopy number_tabletype,
p_number_rep_array in out nocopy number
) return boolean is
l_index number;
l_rank number;
Begin
  --if g_debug then
    --write_to_log_file_n('In set_rank for child='||p_child_level||' rank='||p_rank||' seed='||p_child_level);
  --end if;
  l_index:=get_index(p_rep_array,p_number_rep_array,p_child_level);
  if l_index>0 then
    if p_rep_rank(l_index)<p_rank then
      p_rep_rank(l_index):=p_rank;
    end if;
  end if;
  for i in 1..p_number_array loop
    if p_child_array(i)=p_child_level then
      l_rank:=p_rank+1;
      if set_rank(p_parent_array,p_child_array,p_number_array,p_parent_array(i),l_rank,p_rep_array,p_rep_rank,
        p_number_rep_array)=false then
        return false;
      end if;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in set_rank '||sqlerrm);
  return false;
End;

function get_distinct_list(
p_input varchar_tabletype,
p_number_input number,
p_dist_list out nocopy varchar_tabletype,
p_number_dist_list out nocopy number
) return boolean is
Begin
  p_number_dist_list:=0;
  for i in 1..p_number_input loop
    if in_array(p_dist_list,p_number_dist_list,p_input(i))=false then
      p_number_dist_list:=p_number_dist_list+1;
      p_dist_list(p_number_dist_list):=p_input(i);
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_distinct_list '||sqlerrm);
  return false;
End;

function get_distinct_list(
p_input number_tabletype,
p_number_input number,
p_dist_list out nocopy number_tabletype,
p_number_dist_list out nocopy number
) return boolean is
Begin
  p_number_dist_list:=0;
  for i in 1..p_number_input loop
    if in_array(p_dist_list,p_number_dist_list,p_input(i))=false then
      p_number_dist_list:=p_number_dist_list+1;
      p_dist_list(p_number_dist_list):=p_input(i);
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_distinct_list '||sqlerrm);
  return false;
End;

function parse_values(
p_list varchar2,
p_separator varchar2,
p_names out nocopy number_tabletype,
p_number_names out nocopy number) return boolean is
l_names varchar_tabletype;
Begin
  if parse_values(p_list,p_separator,l_names,p_number_names)=false then
    return false;
  end if;
  for i in 1..p_number_names loop
    p_names(i):=l_names(i);
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
 write_to_log_file_n('Error in parse_values '||sqlerrm);
 return false;
End;
--------
function parse_values(
p_list varchar2,
p_separator varchar2,
p_names out nocopy varchar_tabletype,
p_number_names out nocopy number) return boolean is
l_start number;
l_end number;
l_len number;
Begin
  p_number_names:=0;
  if p_list is null then
    return true;
  end if;
  l_len:=length(p_list);
  if l_len<=0 then
    return true;
  end if;
  if instr(p_list,p_separator)=0 then
    p_number_names:=1;
    p_names(p_number_names):=ltrim(rtrim(p_list));
    return true;
  end if;
  l_start:=1;
  loop
    l_end:=instr(p_list,p_separator,l_start);
    if l_end=0 then
      l_end:=l_len+1;
    end if;
    p_number_names:=p_number_names+1;
    p_names(p_number_names):=ltrim(rtrim(substr(p_list,l_start,(l_end-l_start))));
    l_start:=l_end+1;
    if l_end>=l_len then
      exit;
    end if;
  end loop;
  /*
  if g_debug then
    write_to_log_file_n('The input string '||p_list);
    write_to_log_file('Parsed values');
    for i in 1..p_number_names loop
      write_to_log_file(p_names(i));
    end loop;
  end if;*/
  return true;
Exception when others then
  g_status_message:=sqlerrm;
 write_to_log_file_n('Error in parse_values '||sqlerrm);
 return false;
End;

function parse_and_find(
p_list varchar2,
p_separator varchar2,
p_string  varchar2
)return boolean is
l_array varchar_tabletype;
l_number_array number;
Begin
  if parse_values(p_list,p_separator,l_array,l_number_array)=false then
    return false;
  end if;
  for i in 1..l_number_array loop
    if l_array(i)=p_string then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in parse_and_find '||sqlerrm);
  return false;
End;

function get_value(
p_list varchar_tabletype,
p_list_values varchar_tabletype,
p_number_list number,
p_list_name varchar2
)return varchar2 is
l_index number;
l_list_value varchar2(4000);
Begin
  l_list_value:=null;
  l_index:=get_index(p_list,p_number_list,p_list_name);
  if l_index >0 then
    l_list_value:=p_list_values(l_index);
  end if;
  return l_list_value;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_value '||sqlerrm);
  return null;
End;

/*
given a set of levels, return an ordered set of them
*/
function get_ordered_levels(
p_dim_name varchar2,
p_apps_origin varchar2,
p_levels varchar_tabletype,
p_number_levels number,
p_ordered_levels out nocopy varchar_tabletype,
p_number_children out nocopy number_tabletype
)return boolean is
l_count number;
l_index number;
l_levels varchar_tabletype;
l_level_number_children number_tabletype;
l_number_levels number;
l_ordered_levels varchar_tabletype;
l_number_children number_tabletype;
l_min number:=1000000;
l_looked_at number_tabletype;
l_number_looked_at number:=0;
l_min_index number;
l_description varchar_tabletype;
l_property varchar_tabletype;
Begin
  if BSC_IM_INT_MD.get_level(
    p_dim_name,
    p_apps_origin,
    l_levels,
    l_level_number_children,
    l_description,
    l_property,
    l_number_levels)=false then
    return false;
  end if;
  l_count:=0;
  for i in 1..p_number_levels loop
    l_index:=0;
    l_index:=get_index(l_levels,l_number_levels,p_levels(i));
    if l_index>0 then
      l_count:=l_count+1;
      l_ordered_levels(l_count):=l_levels(l_index);
      l_number_children(l_count):=l_level_number_children(l_index);
    end if;
  end loop;
  for i in 1..l_count loop
    l_min:=1000000;
    for j in 1..l_count loop
      if l_number_children(j)<l_min then
        if in_array(l_looked_at,l_number_looked_at,j)=false then
          l_min_index:=j;
          l_min:=l_number_children(j);
        end if;
      end if;
    end loop;
    l_number_looked_at:=l_number_looked_at+1;
    l_looked_at(l_number_looked_at):=l_min_index;
    p_ordered_levels(i):=l_ordered_levels(l_min_index);
    p_number_children(i):=l_number_children(l_min_index);
  end loop;
  if g_debug then
    write_to_debug_n('Results');
    for i in 1..l_count loop
      write_to_debug(p_ordered_levels(i)||' '||p_number_children(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
 write_to_log_file_n('Error in get_ordered_levels '||sqlerrm);
 return false;
End;

function get_ordered_levels(
p_levels varchar_tabletype,
p_level_number_children number_tabletype,
p_number_levels number,
p_ordered_levels out nocopy varchar_tabletype) return boolean is
l_sorted_list number_tabletype;
l_last number;
l_count number:=0;
Begin
  if sort_number_array(p_level_number_children,p_number_levels,
    'DSC',l_sorted_list)=false then
    return false;
  end if;
  l_last:=-1;
  for i in 1..p_number_levels loop
    if l_sorted_list(i)<>l_last then
      l_last:=l_sorted_list(i);
      for j in 1..p_number_levels loop
        if p_level_number_children(j)=l_last then
          l_count:=l_count+1;
          p_ordered_levels(l_count):=p_levels(j);
        end if;
      end loop;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_ordered_levels '||sqlerrm);
  return false;
End;

function get_seq_nextval(p_seq varchar2) return number is
Begin
  if p_seq is null then
    return read_global;
  else
    return read_sequence(p_seq);
  end if;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  return -1;
End;

function drop_db_object(p_object varchar2,p_type varchar2,p_owner varchar2) return boolean is
l_stmt varchar2(1000);
Begin
  if p_owner is null then
    l_stmt:='drop '||p_type||' '||p_object;
  else
    l_stmt:='drop '||p_type||p_owner||'.'||p_object;
  end if;
  write_to_debug_n(l_stmt);
  execute immediate l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
 write_to_log_file_n('Error in drop_db_object '||sqlerrm);
 return false;
End;

function set_global_dimensions return boolean is
Begin
  g_global_dimension(1):='PERIODICITY_ID';
  g_global_dimension(2):='YEAR';
  g_global_dimension(3):='PERIOD';
  g_global_dimension(4):='TYPE';
  g_number_global_dimension:=4;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in set_global_dimensions '||sqlerrm);
  return false;
End;

function get_global_dimensions(
p_global_dimensions out nocopy varchar_tabletype,
p_number_global_dimensions out nocopy number
) return boolean is
Begin
  p_global_dimensions:=g_global_dimension;
  p_number_global_dimensions:=g_number_global_dimension;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_global_dimensions '||sqlerrm);
  return false;
End;

function is_global_dimension(
p_column varchar2
)return boolean is
Begin
  for i in 1..g_number_global_dimension loop
    if g_global_dimension(i)=p_column then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in is_global_dimension '||sqlerrm);
  return false;
End;

function check_package(p_package varchar2) return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number;
Begin
  --changed from all_source to user_source
  l_stmt:= 'SELECT 1 FROM USER_SOURCE WHERE NAME=:1 AND TYPE=:2 ';
  write_to_debug_n(l_stmt||' '||p_package);
  open cv for l_stmt using p_package, 'PACKAGE';
  fetch cv into l_res;
  close cv;
  if l_res=1 then
    write_to_debug('Found!');
    return true;
  else
    write_to_debug('NOT Found!');
    return false;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in check_package '||sqlerrm);
  return false;
End;

function get_table_owner(p_table varchar2) return varchar2 is
l_owner varchar2(400);
l_stmt  varchar2(4000);
cursor c1(p_table varchar2) is select table_owner from user_synonyms where synonym_name=p_table;
-----------------------------------
Begin
  if g_debug then
    write_to_log_file_n('In get_table_owner'||get_time);
  end if;
  if instr(p_table,'.')<>0 then
    l_owner:=substr(p_table,1,instr(p_table,'.')-1);
    return l_owner;
  end if;
  open c1(p_table);
  fetch c1 into l_owner;
  close c1;
  if l_owner is null then
    -- owner is apps return apps schema name
    if g_debug then
            write_to_log_file_n('going to get apps owner '||get_time);
    end if;
    l_owner := BSC_APPS.get_user_schema('APPS');
    if g_debug then
            write_to_log_file_n('After get apps owner '||get_time);
    end if;
  end if;
  if g_debug then
    write_to_log_file_n('Owner for '||p_table||' is '||l_owner);
  end if;
  return l_owner;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_table_owner '||sqlerrm);
  return null;
End;

function get_object_owner(p_object varchar2) return varchar2 is
l_owner varchar2(400);
l_stmt  varchar2(4000);
cursor c1(p_table varchar2) is select table_owner from user_synonyms where synonym_name=p_table;
Begin
  if g_debug then
    write_to_log_file_n('In get_object_owner '||p_object);
  end if;
  if instr(p_object,'.')<>0 then
    l_owner:=substr(p_object,1,instr(p_object,'.')-1);
    return l_owner;
  end if;
  open c1(p_object);
  fetch c1 into l_owner;
  close c1;
  if l_owner is null then
    -- owner is apps return apps schema name
    l_owner := BSC_APPS.get_user_schema('APPS');
  end if;
  if g_debug then
    write_to_log_file_n('Owner for '||p_object||' is '||l_owner);
  end if;
  return l_owner;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_object_owner '||sqlerrm);
  return null;
End;

function get_object_type(
p_object varchar2,
p_owner varchar2
) return varchar2 is
l_type varchar2(400);
l_stmt  varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_owner varchar2(400);
l_object varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In get_object_type '||p_object);
  end if;
  l_owner:=p_owner;
  l_object:=p_object;
  if instr(p_object,'.')<>0 then
    l_owner:=substr(p_object,1,instr(p_object,'.')-1);
    l_object:=substr(p_object,instr(p_object,'.')+1);
  else
    if l_owner is null then
      l_owner:=get_object_owner(l_object);
    end if;
  end if;
  --first see if this is a mview
  if is_mview(l_object,l_owner) then
    l_type:='MATERIALIZED VIEW';
  else
    l_stmt:='select object_type from all_objects where object_name=:1 and owner=:2';
    if g_debug then
      write_to_log_file_n(l_stmt||' '||l_object||','||l_owner);
    end if;
    open cv for l_stmt using l_object,l_owner;
    loop
      fetch cv into l_type;
      --MV always gives 2 rows, 1 saying table and the other saying MV
      if l_type='MATERIALIZED VIEW' then
        exit;
      end if;
      exit when cv%notfound;
    end loop;
    close cv;
  end if;
  if g_debug then
    write_to_log_file_n('object type '||l_type);
  end if;
  return l_type;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_object_type '||sqlerrm);
  return null;
End;

function get_table_constraints(
p_table_name varchar2,
p_table_owner varchar2,
p_constraint_name out nocopy varchar_tabletype,
p_constraint_type out nocopy varchar_tabletype,
p_status out nocopy varchar_tabletype,
p_validated out nocopy varchar_tabletype,
p_index_name out nocopy varchar_tabletype,
p_number_constraints out nocopy number
)return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_table_owner varchar2(200);
Begin
  p_number_constraints:=0;
  l_table_owner:=p_table_owner;
  if l_table_owner is null then
    l_table_owner:=get_table_owner(p_table_name);
  end if;
  g_stmt:='select constraint_name,constraint_type,status,validated,index_name from all_constraints '||
  'where table_name=:a and owner=:b';
  write_to_debug_n(g_stmt||' using '||p_table_name||' '||p_table_owner);
  open cv for g_stmt using p_table_name,p_table_owner;
  loop
    fetch cv into p_constraint_name(p_number_constraints),p_constraint_type(p_number_constraints),
    p_status(p_number_constraints),p_validated(p_number_constraints),p_index_name(p_number_constraints);
    exit when cv%notfound;
    p_number_constraints:=p_number_constraints+1;
  end loop;
  --Fix bug#3899842: Close cursor
  close cv;
  p_number_constraints:=p_number_constraints-1;
  if g_debug then
    write_to_log_file_n('Results');
    for i in 1..p_number_constraints loop
      write_to_log_file(p_constraint_name(i)||' '||p_constraint_type(i)||' '||p_status(i)||' '||
      p_validated(i)||' '||p_index_name(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_table_constraints '||sqlerrm);
  return false;
End;

function get_partition_clause return varchar2 is
l_num_partitions number;
begin
  l_num_partitions := bsc_dbgen_metadata_reader.get_max_partitions;
  if (l_num_partitions > 1) then
    return ' partition by hash(periodicity_id, year, period) partitions '||l_num_partitions;
  else
    return null;
  end if;
end;

function create_mv_log_on_table(
p_table_name varchar2,
p_table_owner varchar2,
p_options varchar_tabletype,
p_number_options number,
p_uk_columns varchar_tabletype,
p_numbet_uk_columns number,
p_columns varchar_tabletype,
p_number_columns number,
p_snplog_creates out nocopy boolean
)return boolean is
l_table_owner varchar2(200);
l_object_type varchar2(200);
------------------------------------
l_tablespace varchar2(200);
l_storage varchar2(200);
------------------------------------
Begin
  --p_table_name may be a table, MV, view etc.
  if g_debug then
    write_to_log_file_n('In util.create_mv_log_on_table '||p_table_name||' '||p_table_owner);
  end if;
  l_table_owner:=p_table_owner;
  p_snplog_creates:=false;
  if l_table_owner is null then
    l_table_owner:=get_table_owner(p_table_name);
    if l_table_owner is null then
      l_table_owner:=get_object_owner(p_table_name);
    end if;
  end if;
  if l_table_owner is null then
    return false;
  end if;
  l_object_type:=get_object_type(p_table_name,l_table_owner);
  if l_object_type<>'TABLE' and l_object_type<>'MATERIALIZED VIEW' then
    return true;
  end if;
  if get_option_value(p_options,p_number_options,'RECREATE')='Y' then
    --if drop_constraint(p_table_name,l_table_owner,p_table_name||'_pk')=false then
      --null;
    --end if;
    --if drop_mv_log(p_table_name,l_table_owner)=false then
      --null;
    --end if;
    null;
  else
    if check_snapshot_log(p_table_name,l_table_owner) then
      write_to_debug_n('The snapshot log already exists');
      return true;
    end if;
  end if;
  l_tablespace:=get_option_value(p_options,p_number_options,'TABLESPACE');
  l_storage:=get_option_value(p_options,p_number_options,'STORAGE');
  if l_tablespace is not null then
    if instr(lower(l_tablespace),'tablespace')<=0 then
      l_tablespace:=' tablespace '||l_tablespace;
    end if;
  end if;
  if l_storage is not null then
    if instr(lower(l_storage),'storage')<=0 then
      l_storage:=' storage '||l_storage;
    end if;
  end if;
  --first create the constraint
  -- removed 11/18/2005 by arun, instead of creating constraint use this in the rowid clause
  /*if p_numbet_uk_columns>0 then
    g_stmt := reorder_index(p_table_name, p_uk_columns);
    g_stmt:='alter table '||l_table_owner||'.'||p_table_name||' add constraint '||p_table_name||'_pk '||
    'primary key ('||g_stmt;
    g_stmt:=g_stmt||') rely enable novalidate';
    if g_debug then
      write_to_log_file_n(g_stmt||get_time);
    end if;
    begin
      execute immediate g_stmt;
    exception when others then
      BSC_IM_UTILS.g_status_message:=sqlerrm;
      write_to_log_file_n('Error in creating primary key constraint '||sqlerrm);
    end;
  end if;  */

  g_stmt:='create MATERIALIZED VIEW log on '||l_table_owner||'.'||p_table_name||' '||l_tablespace||
  ' INITRANS 4 MAXTRANS 255 '||l_storage;

  if (p_table_name like 'BSC_B_%') then
    g_stmt := g_stmt|| get_partition_clause;
  end if;
  g_stmt:= g_stmt||  ' with ';
  if get_db_version='9i' then
    g_stmt:=g_stmt||'sequence,';
  end if;
  --if p_numbet_uk_columns>0 then
  --  g_stmt:=g_stmt||'primary key,';
  --end if;
  g_stmt:=g_stmt||'rowid';
  if p_number_columns>0 or p_numbet_uk_columns>0 then
    g_stmt:=g_stmt||'(';
    for i in 1..p_numbet_uk_columns loop
      g_stmt:=g_stmt||p_uk_columns(i)||',';
    end loop;
    for i in 1..p_number_columns loop
      g_stmt:=g_stmt||p_columns(i)||',';
    end loop;
    g_stmt:=substr(g_stmt,1,length(g_stmt)-1);
    g_stmt:=g_stmt||')';
  end if;
  g_stmt:=g_stmt||' including new values';
  write_to_debug_n(g_stmt);
  begin
    execute immediate g_stmt;
    p_snplog_creates:=true;
  exception when others then
    BSC_IM_UTILS.g_status_message:=sqlerrm;
    write_to_log_file_n('Error in creating mv log '||sqlerrm);
  end;
  return true;
Exception when others then
  if sqlcode=-00942 then
    if g_debug then
      write_to_log_file_n('Error in util create_mv_log_on_table '||sqlerrm);
      write_to_log_file('You cannot create materialized view log on this object '||l_table_owner||'.'||
      p_table_name);
    end if;
    return true;
  else
    g_status_message:=sqlerrm;
    write_to_log_file_n('Error in util create_mv_log_on_table '||sqlerrm);
    return false;
  end if;
End;

function drop_constraint(
p_table_name varchar2,
p_table_owner varchar2,
p_constraint varchar2
)return boolean is
l_table_owner varchar2(200);
Begin
  l_table_owner:=p_table_owner;
  if l_table_owner is null then
    l_table_owner:=get_table_owner(p_table_name);
  end if;
  g_stmt:='alter table '||l_table_owner||'.'||p_table_name||' drop constraint '||p_constraint;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_constraint '||sqlerrm);
  return false;
End;

function drop_mv_log(
p_table_name varchar2,
p_table_owner varchar2
)return boolean is
l_table_owner varchar2(200);
Begin
  l_table_owner:=p_table_owner;
  if l_table_owner is null then
    l_table_owner:=get_table_owner(p_table_name);
  end if;
  g_stmt:='drop materialized view log on '||l_table_owner||'.'||p_table_name;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_mv_log '||sqlerrm);
  return false;
End;

function drop_mv(
p_mv varchar2,
p_mv_owner varchar2
)return boolean is
l_table_owner varchar2(200);
Begin
  l_table_owner:=p_mv_owner;
  if l_table_owner is null and instr(p_mv,'.')<>0 then
    l_table_owner:=substr(p_mv,1,instr(p_mv,'.')-1);
  end if;
  if l_table_owner is null then
    l_table_owner:=get_table_owner(p_mv);
  end if;
  /*
  have to use ad_mv api pre-req patch 3050839
  ad_mv.drop_mv(<MV NAME>, 'DROP MATERIALIZED VIEW <MV NAME>');
  */
  g_stmt:='drop materialized view '||l_table_owner||'.'||p_mv;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_mv '||sqlerrm);
  return false;
End;

function drop_view(
p_view varchar2,
p_view_owner varchar2
)return boolean is
Begin
  if p_view_owner is not null then
    g_stmt:='drop view '||p_view_owner||'.'||p_view;
  else
    g_stmt:='drop view '||p_view;
  end if;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_view '||sqlerrm);
  return false;
End;

function check_snapshot_log(
p_table_name varchar2,
p_table_owner varchar2
)return boolean is
l_table_owner varchar2(200);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number;
Begin
  l_table_owner:=p_table_owner;
  if l_table_owner is null then
    l_table_owner:=get_table_owner(p_table_name);
  end if;
  g_stmt:='select 1 from all_snapshot_logs where MASTER=:a and log_owner=:b';
  write_to_debug_n(g_stmt||' using '||p_table_name||' '||l_table_owner);
  open cv for g_stmt using p_table_name,l_table_owner;
  fetch cv into l_res;
  close cv;
  if l_res=1 then
    write_to_debug('Found!');
    return true;
  else
    write_to_debug('NOT Found!');
    return false;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in check_snapshot_log '||sqlerrm);
  return false;
End;

function get_snapshot_log(
p_table_name varchar2,
p_table_owner varchar2,
p_snplog out nocopy varchar2
)return boolean is
l_table_owner varchar2(200);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number;
Begin
  l_table_owner:=p_table_owner;
  if l_table_owner is null then
    l_table_owner:=get_table_owner(p_table_name);
  end if;
  g_stmt:='select log_table from all_snapshot_logs where MASTER=:a and log_owner=:b';
  write_to_debug_n(g_stmt||' using '||p_table_name||' '||l_table_owner);
  open cv for g_stmt using p_table_name,l_table_owner;
  fetch cv into p_snplog;
  close cv;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_snapshot_log '||sqlerrm);
  return false;
End;

function get_mv_owner(p_mv_name varchar2) return varchar2 is
Begin
  return get_table_owner(p_mv_name);
  -- RETURN BSC SCHEMA NAME
  --return BSC_APPS.get_user_schema;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_mv_owner '||sqlerrm);
  return null;
End;

function get_mv_properties(
p_mv_name varchar2,
p_mv_owner in out nocopy varchar2,
p_refresh_mode out nocopy varchar2,
p_refresh_method out nocopy varchar2,
p_build_mode out nocopy varchar2,
p_last_refresh_type out nocopy varchar2,
p_last_refresh_date out nocopy date,
p_staleness out nocopy varchar2
)return boolean is
l_mv_owner varchar2(200);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_mv_owner:=p_mv_owner;
  if l_mv_owner is null then
    l_mv_owner:=get_mv_owner(p_mv_name);
    p_mv_owner:=l_mv_owner;
  end if;
  g_stmt:='select refresh_mode,refresh_method,build_mode,last_refresh_type,last_refresh_date, '||
  'staleness from all_mviews where mview_name=:a and owner=:b';
  write_to_debug_n(g_stmt||' using '||p_mv_name||' '||l_mv_owner);
  open cv for g_stmt using p_mv_name,l_mv_owner;
  fetch cv into p_refresh_mode,p_refresh_method,p_build_mode,p_last_refresh_type,
  p_last_refresh_date,p_staleness;
  --Fix bug#3899842: Close cursor
  close cv;
  write_to_debug_n(p_refresh_mode||', '||p_refresh_method||', '||p_build_mode||', '||
  p_last_refresh_type||', '||p_last_refresh_date||', '||p_staleness);
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_mv_properties '||sqlerrm);
  return false;
End;

function drop_materialized_view(p_mview varchar2,p_owner varchar2) return boolean is
l_owner varchar2(200);
Begin
  l_owner:=p_owner;
  if l_owner is null then
    l_owner:=get_mv_owner(p_mview);
  end if;
  g_stmt:='drop MATERIALIZED VIEW '||l_owner||'.'||p_mview;
  write_to_debug_n(g_stmt);
  execute immediate g_stmt;
  write_to_debug_n('Dropped MV');
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_materialized_view '||sqlerrm);
  return false;
End;

function check_mv(
p_mv_name varchar2,
p_mv_owner varchar2
)return boolean is
l_mv_owner varchar2(200);
l_res number;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_mv_owner:=p_mv_owner;
  if l_mv_owner is null then
    l_mv_owner:=get_mv_owner(p_mv_name);
  end if;
  g_stmt:='select 1 from all_mviews where mview_name=:a and owner=:b';
  write_to_debug_n(g_stmt||' using '||p_mv_name||' '||l_mv_owner);
  open cv for g_stmt using p_mv_name,l_mv_owner;
  fetch cv into l_res;
  --Fix bug#3899842: close cursor
  close cv;
  if l_res=1 then
    write_to_debug('Found!');
    return true;
  else
    write_to_debug('NOT Found!');
    return false;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in check_mv '||sqlerrm);
  return false;
End;

function check_view(
p_view_name varchar2,
p_view_owner varchar2
)return boolean is
l_mv_owner varchar2(200);
l_res number;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if p_view_owner is null then
    g_stmt:='select 1 from user_views where view_name=:a';
    write_to_debug_n(g_stmt||' using '||p_view_name);
    open cv for g_stmt using p_view_name;
  else
    g_stmt:='select 1 from all_views where view_name=:a and owner=:b';
    write_to_debug_n(g_stmt||' using '||p_view_name||' '||p_view_owner);
    open cv for g_stmt using p_view_name,p_view_owner;
  end if;
  fetch cv into l_res;
  --Fix bug#3899842: close cursor
  close cv;
  if l_res=1 then
    write_to_debug('Found!');
    return true;
  else
    write_to_debug('NOT Found!');
    return false;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in check_view '||sqlerrm);
  return false;
End;

function refresh_mv(
p_mv_name varchar2,
p_mv_owner varchar2,
p_kpi varchar2,
p_options varchar_tabletype,
p_number_options number
)return boolean is
--------------------
l_method varchar2(40);
l_parallel number;
l_drop_index varchar2(40);
--------------------
l_start_time varchar2(100);
l_end_time varchar2(100);
--------------------
l_index varchar_tabletype;
l_uniqueness varchar_tabletype;
l_tablespace varchar_tabletype;
l_initial_extent number_tabletype;
l_next_extent number_tabletype;
l_max_extents number_tabletype;
l_pct_increase  number_tabletype;
l_number_index number;
------
l_ind_name varchar_tabletype;
l_ind_col varchar_tabletype;
l_number_ind_col number;
--------------------
l_stmt varchar2(32000);
--------------------
l_index_tablespace varchar2(320);
l_index_storage varchar2(3000);
--------------------
l_snp_log varchar2(100);
--------------------
l_mv_owner varchar2(200);
l_refresh_mode varchar2(200);
l_refresh_method varchar2(200);
l_build_mode varchar2(200);
l_last_refresh_type varchar2(200);
l_last_refresh_date date;
l_staleness varchar2(200);
--------------------
Begin
  if g_debug then
    write_to_log_file_n('In BSC_IM_UTILS.refresh_mv '||p_mv_owner||'.'||p_mv_name||' kpi='||p_kpi||get_time);
    write_to_log_file('Options:-');
    for i in 1..p_number_options loop
      write_to_log_file(p_options(i));
    end loop;
  end if;
  if p_mv_owner is null then
    l_mv_owner:=get_table_owner(p_mv_name);
  else
    l_mv_owner:=p_mv_owner;
  end if;
  if is_mview(p_mv_name,l_mv_owner)=false then
    if g_debug then
      write_to_log_file_n('Not an MV. Cannot do MV refresh');
    end if;
    return true;
  end if;
  l_method:=get_option_value(p_options,p_number_options,'FULL REFRESH');
  if l_method='Y' then
    l_method:='c';
  else
    if get_mv_properties(
      p_mv_name,
      l_mv_owner,
      l_refresh_mode,
      l_refresh_method,
      l_build_mode,
      l_last_refresh_type,
      l_last_refresh_date,
      l_staleness)=false then
      l_method:='c';
    end if;
    if l_refresh_method='FAST' then
      l_method:='f';
    else
      l_method:='c';
    end if;
  end if;
  l_parallel:=get_option_value(p_options,p_number_options,'PARALLEL');
  l_drop_index:=get_option_value(p_options,p_number_options,'DROP INDEX');
  -----------------
  l_index_tablespace:=BSC_IM_UTILS.get_option_value(p_options,p_number_options,'INDEX TABLESPACE');
  l_index_storage:=BSC_IM_UTILS.get_option_value(p_options,p_number_options,'INDEX STORAGE');
  if l_index_tablespace is not null then
    if instr(lower(l_index_tablespace),'tablespace')<=0 then
      l_index_tablespace:=' tablespace '||l_index_tablespace;
    end if;
  end if;
  if l_index_storage is not null then
    if instr(lower(l_index_storage),'storage')<=0 then
      l_index_storage:=' storage '||l_index_storage;
    end if;
  end if;
  -----------------
  <<start_mv_refresh>>
  if g_debug then
    write_to_log_file_n('Method='||l_method||', parallel='||l_parallel||', drop index='||l_drop_index);
  end if;
  if l_drop_index='Y' then
    if g_debug then
      write_to_log_file_n('Drop Index specified. Will drop the indexes ONLY if the refresh is complete refresh');
    end if;
    if l_method='c' then
      if get_table_indexes(
        p_mv_name,
        l_mv_owner,
        l_index,
        l_uniqueness,
        l_tablespace,
        l_initial_extent,
        l_next_extent,
        l_max_extents,
        l_pct_increase,
        l_number_index
        )=false then
        return false;
      end if;
      if l_number_index>0 then
        if l_index_tablespace is null then
          l_index_tablespace:=' tablespace '||l_tablespace(1);
        end if;
        if l_index_storage is null then
          l_index_storage:=' storage (initial '||l_initial_extent(1)||' next '||l_next_extent(1)||
          ' minextents 1 maxextents '||l_max_extents(1)||' pctincrease '||l_pct_increase(1)||') ';
        end if;
      end if;
      for i in 1..l_number_index loop
        if g_debug then
          write_to_log_file('Dropping index '||l_mv_owner||'.'||l_index(i));
        end if;
        if execute_immediate('drop index '||l_mv_owner||'.'||l_index(i),null)=false then
          null;
        end if;
        if g_debug then
          write_to_log_file('Dropped index');
        end if;
      end loop;
    end if;
  end if;
  l_start_time:=get_time;
  if g_debug then
    write_to_log_file_n('Going to refresh MV '||l_mv_owner||'.'||p_mv_name||get_time);
  end if;
  --Enh#4239064: parallelism
  if l_method='c' then
    execute immediate 'alter session force parallel query';
    execute immediate 'alter session enable parallel dml';
    execute immediate 'alter table '||l_mv_owner||'.'||p_mv_name||' parallel';
  end if;
  begin
    DBMS_MVIEW.REFRESH(
    list=>l_mv_owner||'.'||p_mv_name,
    method=>l_method);
    --Enh#4239064: in Venu's doc it does not use parallelism paramenter
    --PARALLELISM=>l_parallel);
    if g_debug then
      write_to_log_file('Refresh complete '||get_time);
    end if;
  exception when others then
    --Enh#4239064: add commit here
    commit;
    BSC_IM_UTILS.g_status_message:=sqlerrm;
    if g_debug then
      write_to_log_file_n('Could not refresh MV '||sqlerrm);
    end if;
    if l_method='f' then
      if g_debug then
        write_to_log_file_n('One more try with full refresh');
      end if;
      l_method:='c';
      goto start_mv_refresh;
    end if;
    --error
    write_to_out_file('Error refreshing '||p_mv_name||' '||BSC_IM_UTILS.g_status_message);
    return false;
  end;
  --Enh#4239064: add commit here
  commit;
  l_end_time:=get_time;
  write_to_out_file('-----------------------------------------------');
  if l_method='f' then
    write_to_out_file('Refreshed '||p_mv_name||' FAST REFRESH '||
    ' Start time ->'||l_start_time||' End time->'||l_end_time);
  else
    write_to_out_file('Refreshed '||p_mv_name||' FULL REFRESH '||
    ' Start time ->'||l_start_time||' End time->'||l_end_time);
  end if;
  l_start_time:=get_time;
  if l_drop_index='Y' then
    if l_method='c' then
      if g_debug then
        write_to_log_file_n('Going to recreate the indexes that were dropped');
      end if;
      if BSC_MV_ADAPTER.create_mv_index(
        p_mv_name,
        l_mv_owner,
        p_kpi,
        'BSC',
        l_index_tablespace,
        l_index_storage,
        null,
        true)=false then
        return false;
      end if;
      l_end_time:=get_time;
      write_to_out_file('Recreated Indexes for '||p_mv_name||
      ' Start time ->'||l_start_time||' End time->'||l_end_time);
    end if;
  end if;
  --Enh#4239064: add commit here
  commit;
  if BSC_IM_UTILS.get_option_value(p_options,p_number_options,'ANALYZE')='Y' then
    l_start_time:=get_time;
    analyze_object(p_mv_name,l_mv_owner,null,l_parallel,null);
    --Enh#4239064: add commit here
    commit;
    if g_debug then
      write_to_log_file_n('Analyzed the MV'||get_time);
    end if;
    --analyze the mv log also if present
    if get_snapshot_log(p_mv_name,l_mv_owner,l_snp_log)=false then
      null;
    end if;
    if l_snp_log is not null then
      analyze_object(l_snp_log,l_mv_owner,null,l_parallel,null);
    end if;
    l_end_time:=get_time;
    write_to_out_file('Analyzed '||p_mv_name||' Start time ->'||l_start_time||' End time->'||l_end_time);
  end if;
  --Enh#4239064: add commit here and disable parallelism
  commit;
  if l_method='c' then
    execute immediate 'alter session disable parallel query';
    execute immediate 'alter session disable parallel dml';
    execute immediate 'alter table '||l_mv_owner||'.'||p_mv_name||' noparallel';
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in refresh_mv '||sqlerrm);
  return false;
End;

function create_index(
p_table_name varchar2,
p_table_owner varchar2,
p_index varchar_tabletype,
p_uniqueness varchar_tabletype,
p_tablespace varchar_tabletype,
p_initial_extent number_tabletype,
p_next_extent number_tabletype,
p_max_extents number_tabletype,
p_pct_increase  number_tabletype,
p_number_index number,
------
p_ind_name varchar_tabletype,
p_ind_col varchar_tabletype,
p_number_ind_col number
)return boolean is
l_stmt varchar2(32000);
Begin
  if g_debug then
    write_to_log_file_n('In create_index for '||p_table_owner||'.'||p_table_name||get_time);
  end if;
  for i in 1..p_number_index loop
    if g_debug then
      write_to_log_file_n('Going to create index '||p_table_owner||'.'||p_index(i));
    end if;
    l_stmt:='create ';
    if p_uniqueness(i)='UNIQUE' then
      l_stmt:=l_stmt||' unique ';
    end if;
    l_stmt:=l_stmt||'index '||p_table_owner||'.'||p_index(i)||' on '||p_table_owner||'.'||p_table_name||'(';
    for j in 1..p_number_ind_col loop
      if p_ind_name(j)=p_index(i) then
        l_stmt:=l_stmt||p_ind_col(j)||',';
      end if;
    end loop;
    l_stmt:=substr(l_stmt,1,length(l_stmt)-1)||')';
    l_stmt:=l_stmt||' tablespace '||p_tablespace(i)||' storage(INITIAL '||p_initial_extent(i)||' NEXT '||
    p_next_extent(i)||' MINEXTENTS 1 MAXEXTENTS '||p_max_extents(i)||' PCTINCREASE '||p_pct_increase(i)||')';
    if create_index(l_stmt,null)=false then
      return false;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_index '||sqlerrm);
  return false;
End;

function create_index(
p_stmt varchar2,
p_options varchar2
)return boolean is
Begin
  if g_debug then
    write_to_log_file_n(p_stmt||get_time);
  end if;
  begin
    execute immediate p_stmt;
  exception when others then
    if g_debug then
      write_to_log_file_n(sqlerrm);
    end if;
    if sqlcode=-01408 or sqlcode=-00955 then
      if g_debug then
        write_to_log_file_n('Ignore this error');
      end if;
    else
      g_status_message:=sqlerrm;
      return false;
    end if;
  end;
  if g_debug then
    write_to_log_file_n('Index created '||get_time);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_index '||sqlerrm);
  return false;
End;


function drop_table(p_table varchar2,p_owner varchar2) return boolean is
l_owner varchar2(200);
Begin
  l_owner:=p_owner;
  if l_owner is null then
    l_owner:=get_table_owner(p_table);
  end if;
  if instr(p_table,'.')<>0 then
    g_stmt:='drop table '||p_table;
  else
    g_stmt:='drop table '||l_owner||'.'||p_table;
  end if;
  write_to_debug_n(g_stmt);
  execute immediate g_stmt;
  write_to_debug_n('Dropped table');
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_table '||sqlerrm);
  return false;
End;

function get_table_properties(
p_table varchar2,
p_owner varchar2,
p_columns out nocopy varchar_tabletype,
p_columns_data_type out nocopy varchar_tabletype,
p_number_columns out nocopy number
)return boolean is
l_owner varchar2(200);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_owner:=p_owner;
  p_number_columns:=1;
  if l_owner is null then
    l_owner:=get_table_owner(p_table);
  end if;
  g_stmt:='select '||
  'column_name, '||
  'decode(data_type,:1, data_type||''(''||data_length||'')'',data_type) date_type '||
  'from all_tab_columns '||
  'where table_name=:a '||
  'and owner=:b ';
  write_to_debug_n(g_stmt||' '||p_table||' '||l_owner);
  open cv for g_stmt using 'VARCHAR2', p_table,l_owner;
  loop
    fetch cv into p_columns(p_number_columns),p_columns_data_type(p_number_columns);
    exit when cv%notfound;
    p_number_columns:=p_number_columns+1;
  end loop;
  --Fix bug#3899842: close cursor
  close cv;
  p_number_columns:=p_number_columns-1;
  if g_debug then
    write_to_debug_n('The columns');
    for i in 1..p_number_columns loop
      write_to_debug(p_columns(i)||' '||p_columns_data_type(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_table_properties '||sqlerrm);
  return false;
End;

function drop_synonym(p_syn_name varchar2) return boolean is
Begin
  g_stmt:='drop synonym '||p_syn_name;
  write_to_debug_n(g_stmt);
  execute immediate g_stmt;
  write_to_debug('Dropped');
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  -- Dont display synonym does not exist error
  if (sqlcode<>-1434) then
    write_to_log_file_n('Error in drop_synonym '||sqlerrm);
  end if;
  return false;
End;

--get all the levels between 2 given levels in a dimension
function get_all_levels_between(
p_dim_name varchar2,
p_apps_origin varchar2,
p_level_1 varchar2,
p_level_2 varchar2,
p_child_level out nocopy varchar_tabletype,
p_child_level_fk out nocopy varchar_tabletype,
p_parent_level out nocopy varchar_tabletype,
p_parent_level_pk out nocopy varchar_tabletype,
p_hier out nocopy varchar_tabletype,
p_number_hier out nocopy number
)return boolean is
-------------------------------------------------------------
l_child_level varchar_tabletype;
l_parent_level varchar_tabletype;
l_child_fk varchar_tabletype;
l_parent_pk varchar_tabletype;
l_hier_rel varchar_tabletype;
l_number_rels number;
-------------------------------------------------------------
l_hier_1 varchar_tabletype;
l_number_hier_1 number;
l_hier_2 varchar_tabletype;
l_number_hier_2 number;
l_hier_common varchar_tabletype;
l_number_hier_common number;
-------------------------------------------------------------
ll_child_level varchar_tabletype;
ll_child_level_fk varchar_tabletype;
ll_parent_level varchar_tabletype;
ll_parent_level_pk varchar_tabletype;
ll_hier varchar_tabletype;
ll_number_hier number;
-------------------------------------------------------------
l_description varchar_tabletype;
l_property varchar_tabletype;
Begin
  write_to_debug_n('In get_all_levels_between for '||p_dim_name||' level 1='||p_level_1||', level 2='||p_level_2);
  p_number_hier:=0;
  if p_level_1=p_level_2 then
    return true;
  end if;
  if BSC_IM_INT_MD.get_level_relation(
    p_dim_name,
    p_apps_origin,
    l_child_level,
    l_parent_level,
    l_child_fk,
    l_parent_pk,
    l_hier_rel,
    l_property,
    l_number_rels)=false then
    return false;
  end if;
  --find all hier that have these levels
  l_number_hier_1:=0;
  l_number_hier_2:=0;
  l_number_hier_common:=0;
  for i in 1..l_number_rels loop
    if l_child_level(i)=p_level_1 or l_parent_level(i)=p_level_1 then
      if in_array(l_hier_1,l_number_hier_1,l_hier_rel(i))=false then
        l_number_hier_1:=l_number_hier_1+1;
        l_hier_1(l_number_hier_1):=l_hier_rel(i);
      end if;
    end if;
  end loop;
  for i in 1..l_number_rels loop
    if l_child_level(i)=p_level_2 or l_parent_level(i)=p_level_2 then
      if in_array(l_hier_2,l_number_hier_2,l_hier_rel(i))=false then
        l_number_hier_2:=l_number_hier_2+1;
        l_hier_2(l_number_hier_2):=l_hier_rel(i);
      end if;
    end if;
  end loop;
  --find the common
  for i in 1..l_number_hier_1 loop
    if in_array(l_hier_2,l_number_hier_2,l_hier_1(i)) then
      l_number_hier_common:=l_number_hier_common+1;
      l_hier_common(l_number_hier_common):=l_hier_1(i);
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The common hier');
    for i in 1..l_number_hier_common loop
      write_to_log_file(l_hier_common(i));
    end loop;
  end if;
  --for each of the hier, loop and see in which all both the level appear
  for i in 1..l_number_hier_common loop
    if get_all_levels_between(
      p_level_1,
      p_level_2,
      l_hier_common(i),
      l_child_level,
      l_parent_level,
      l_child_fk,
      l_parent_pk,
      l_hier_rel,
      l_number_rels,
      ll_child_level,
      ll_child_level_fk,
      ll_parent_level,
      ll_parent_level_pk,
      ll_hier,
      ll_number_hier)=false then
      return false;
    end if;
    for i in 1..ll_number_hier loop
      p_number_hier:=p_number_hier+1;
      p_child_level(p_number_hier):=ll_child_level(i);
      p_child_level_fk(p_number_hier):=ll_child_level_fk(i);
      p_parent_level(p_number_hier):=ll_parent_level(i);
      p_parent_level_pk(p_number_hier):=ll_parent_level_pk(i);
      p_hier(p_number_hier):=ll_hier(i);
    end loop;
  end loop;
  if g_debug then
    write_to_log_file_n('The levels in between '||p_level_1||' and '||p_level_2);
    for i in 1..p_number_hier loop
      write_to_log_file(p_child_level(i)||' '||p_child_level_fk(i)||' '||p_parent_level(i)||' '||
      p_parent_level_pk(i)||' '||p_hier(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_all_levels_between '||sqlerrm);
  return false;
End;

--given 2 levels and the hier, get all the levels in between and the relation
function get_all_levels_between(
p_level_1 varchar2,
p_level_2 varchar2,
p_hier varchar2,
p_child_level varchar_tabletype,
p_parent_level varchar_tabletype,
p_child_fk varchar_tabletype,
p_parent_pk varchar_tabletype,
p_hier_rel varchar_tabletype,
p_number_rels number,
po_child_level out nocopy varchar_tabletype,
po_child_level_fk out nocopy varchar_tabletype,
po_parent_level out nocopy varchar_tabletype,
po_parent_level_pk out nocopy varchar_tabletype,
po_hier out nocopy varchar_tabletype,
po_number_hier out nocopy number
)return boolean is
l_found boolean;
l_exit boolean;
l_child_level varchar2(200);
l_parent_level varchar2(200);
l_mark boolean_tabletype;
Begin
  --we dont know if level 1 is child or level 2 is child
  po_number_hier:=0;
  l_child_level:=p_level_1;
  l_parent_level:=p_level_2;
  for m in 1..2 loop
    for i in 1..p_number_rels loop
      l_mark(i):=false;
    end loop;
    l_found:=false;
    l_exit:=false;
    loop
      l_exit:=true;
      for i in 1..p_number_rels loop
        if p_hier_rel(i)=p_hier and p_child_level(i)=l_child_level then
          l_exit:=false;
          l_mark(i):=true;
          l_child_level:=p_parent_level(i);
          if l_child_level=l_parent_level then
            l_exit:=true;
            l_found:=true;
          end if;
          exit;
        end if;
      end loop;
      if l_exit then
        exit;
      end if;
    end loop;
    if l_found then
      exit;
    else
      l_child_level:=p_level_2; --try with these
      l_parent_level:=p_level_1;
    end if;
  end loop;
  if l_found=false then
    write_to_debug_n('Could never find the levels in between '||p_level_1||' '||p_level_2||
    ' in hier '||p_hier);
    return false;
  end if;
  for i in 1..p_number_rels loop
    if l_mark(i) then
      po_number_hier:=po_number_hier+1;
      po_child_level(po_number_hier):=p_child_level(i);
      po_child_level_fk(po_number_hier):=p_child_fk(i);
      po_parent_level(po_number_hier):=p_parent_level(i);
      po_parent_level_pk(po_number_hier):=p_parent_pk(i);
      po_hier(po_number_hier):=p_hier_rel(i);
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_all_levels_between '||sqlerrm);
  return false;
End;

function get_option_value(
p_options varchar_tabletype,
p_number_options number,
p_check_option varchar2
)return varchar2 is
l_length number;
l_value varchar2(20000);
Begin
  if p_number_options is null or p_number_options=0 then
    return null;
  end if;
  l_value:=null;
  l_length:=length(p_check_option);
  for i in 1..p_number_options loop
    if substr(p_options(i),1,l_length)=p_check_option then
      if substr(p_options(i),1,l_length+1)=p_check_option||'=' then
        l_value:=substr(p_options(i),l_length+2);
      else
        l_value:='Y';
        exit;
      end if;
    end if;
  end loop;
  if g_debug then
    write_to_log_file(p_check_option||'='||l_value);
  end if;
  return l_value;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_option_value '||sqlerrm);
  return null;
End;

function get_option_value(
p_options varchar2,
p_separator varchar2,
p_check_option varchar2
)return varchar2 is
l_array varchar_tabletype;
l_number_array number;
l_value varchar2(20000);
Begin
  if parse_values(p_options,p_separator,l_array,l_number_array)=false then
    return null;
  end if;
  l_value:=get_option_value(l_array,l_number_array,p_check_option);
  return l_value;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_option_value '||sqlerrm);
  return null;
End;

function get_table_storage(
p_table varchar2,
p_owner varchar2,
p_table_space out nocopy varchar2,
p_initial_extent out nocopy number,
p_next_extent out nocopy number,
p_pct_free out nocopy number,
p_pct_used out nocopy number,
p_pct_increase out nocopy number,
p_max_extents out nocopy number,
p_avg_row_len out nocopy number
) return boolean is
l_stmt varchar2(2000);
l_owner varchar2(100);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_owner:=p_owner;
  if l_owner is null then
    l_owner:=get_table_owner(p_table);
  end if;
  l_stmt:='select tablespace_name,initial_extent,next_extent,pct_free,pct_used,pct_increase,max_extents,'||
  'avg_row_len from '||
  'all_tables where table_name=:a and owner=:b';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_table||','||l_owner);
  end if;
  open cv for l_stmt using p_table,l_owner;
  fetch cv into p_table_space,p_initial_extent,p_next_extent,p_pct_free,p_pct_used,p_pct_increase,p_max_extents,
  p_avg_row_len;
  close cv;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_table_storage '||sqlerrm);
  return false;
End;

function get_table_indexes(
p_table_name varchar2,
p_table_owner varchar2,
p_index out nocopy varchar_tabletype,
p_uniqueness out nocopy varchar_tabletype,
p_tablespace out nocopy varchar_tabletype,
p_initial_extent out nocopy number_tabletype,
p_next_extent out nocopy number_tabletype,
p_max_extents out nocopy number_tabletype,
p_pct_increase  out nocopy number_tabletype,
p_number_index out nocopy number
) return boolean is
l_stmt varchar2(2000);
l_owner varchar2(100);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_owner:=p_table_owner;
  p_number_index:=0;
  if l_owner is null then
    l_owner:=get_table_owner(p_table_name);
  end if;
  l_stmt:='select index_name,uniqueness,tablespace_name,initial_extent,next_extent,max_extents,pct_increase '||
  'from all_indexes where table_name=:1 and table_owner=:2';
  if g_debug then
    write_to_log_file_n(l_stmt||' '||p_table_name||' '||l_owner);
  end if;
  p_number_index:=1;
  open cv for l_stmt using p_table_name,l_owner;
  loop
    fetch cv into
      p_index(p_number_index),
      p_uniqueness(p_number_index),
      p_tablespace(p_number_index),
      p_initial_extent(p_number_index),
      p_next_extent(p_number_index),
      p_max_extents(p_number_index),
      p_pct_increase(p_number_index);
    exit when cv%notfound;
    p_number_index:=p_number_index+1;
  end loop;
  p_number_index:=p_number_index-1;
  close cv;
  if g_debug then
    write_to_log_file_n('Result');
    for i in 1..p_number_index loop
      write_to_log_file(p_index(i)||' '||p_uniqueness(i)||' '||p_tablespace(i)||' '||p_initial_extent(i)||' '||
      p_next_extent(i)||' '||p_max_extents(i)||' '||p_pct_increase(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_table_indexes '||sqlerrm);
  return false;
End;

function get_table_indexes(
p_table_name varchar2,
p_table_owner varchar2,
p_index out nocopy varchar_tabletype,
p_uniqueness out nocopy varchar_tabletype,
p_tablespace out nocopy varchar_tabletype,
p_initial_extent out nocopy number_tabletype,
p_next_extent out nocopy number_tabletype,
p_max_extents out nocopy number_tabletype,
p_pct_increase  out nocopy number_tabletype,
p_number_index out nocopy number,
p_ind_name out nocopy varchar_tabletype,
p_ind_col out nocopy varchar_tabletype,
p_number_ind_col out nocopy number
) return boolean is
l_stmt varchar2(2000);
l_owner varchar2(100);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_owner:=p_table_owner;
  p_number_index:=0;
  if l_owner is null then
    l_owner:=get_table_owner(p_table_name);
  end if;
  if get_table_indexes(
    p_table_name,
    l_owner,
    p_index,
    p_uniqueness,
    p_tablespace,
    p_initial_extent,
    p_next_extent,
    p_max_extents,
    p_pct_increase,
    p_number_index)=false then
    return false;
  end if;
  p_number_ind_col:=1;
  l_stmt:='select index_name,column_name from all_ind_columns where index_name=:1 and index_owner=:2 '||
  'order by column_position';
  for i in 1..p_number_index loop
    if g_debug then
      write_to_log_file_n(l_stmt||' '||p_index(i));
    end if;
    open cv for l_stmt using p_index(i),l_owner;
    loop
      fetch cv into p_ind_name(p_number_ind_col),p_ind_col(p_number_ind_col);
      exit when cv%notfound;
      p_number_ind_col:=p_number_ind_col+1;
    end loop;
    --Fix bug#3899842: close cursor
    close cv;
  end loop;
  p_number_ind_col:=p_number_ind_col-1;
  if g_debug then
    write_to_log_file_n('Result');
    for i in 1..p_number_ind_col loop
      write_to_log_file(p_ind_name(i)||' '||p_ind_col(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_table_indexes '||sqlerrm);
  return false;
End;

function get_synonym_property(
p_synonym varchar2,
p_syn_owner out nocopy varchar2,
p_syn_object out nocopy varchar2
)return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  g_stmt:='select TABLE_NAME,TABLE_OWNER from user_synonyms where synonym_name=:1';
  if g_debug then
    write_to_log_file_n(g_stmt||' '||p_synonym);
  end if;
  open cv for g_stmt using p_synonym;
  fetch cv into p_syn_object,p_syn_owner;
  if g_debug then
    write_to_log_file(p_syn_owner||' '||p_syn_object);
  end if;
  close cv;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_synonym_property '||sqlerrm);
  return false;
End;

function create_synonym(
p_synonym varchar2,
p_syn_owner varchar2,
p_syn_object varchar2
)return boolean is
Begin
  --if the synonym exists, drop it first
  if drop_synonym(p_synonym)=false then
    null;
  end if;
  g_stmt:='create synonym '||p_synonym||' for '||p_syn_owner||'.'||p_syn_object;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_synonym '||sqlerrm);
  return false;
End;

procedure set_trace is
Begin
  execute immediate 'alter session set sql_trace=true';
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in set_trace '||sqlerrm);
End;

procedure analyze_object(
p_object varchar2,
p_owner varchar2,
p_sample number,
p_parallel number,
p_partname varchar2
) is
l_owner varchar2(200);
l_errbuf varchar2(2000);
l_retcode varchar2(2000);
Begin
  l_owner:=p_owner;
  if l_owner is null then
    l_owner:=get_table_owner(p_object);
  end if;
  if g_debug then
    write_to_log_file_n('Analyze '||l_owner||'.'||p_object);
  end if;
  FND_STATS.GATHER_TABLE_STATS(l_errbuf,l_retcode,l_owner,p_object,null,null,p_partname);
  if g_debug then
    write_to_log_file_n('Completed Analyzing '||l_owner||'.'||p_object);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in analyze_object '||sqlerrm);
End;

function get_object_name(p_object_name varchar2) return varchar2 is
Begin
  return substr(p_object_name,instr(p_object_name,'.')+1);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_object_name '||sqlerrm);
  return null;
End;

function get_corrected_map_table(
p_map_table varchar2,--could be sql stmt
p_map_table_list varchar2,
p_options varchar_tabletype,
p_number_options number,
p_apps_src varchar2,
p_olap_target varchar2,
p_corr_table_name out nocopy varchar2,
p_corr_table_list out nocopy varchar_tabletype,
p_original_table_list out nocopy varchar_tabletype,
p_number_corr_table out nocopy number
)return boolean is
-----------------------------------------------------------
l_table_list varchar_tabletype;
-----------------------------------------------------------
Begin
  if g_debug then
    write_to_log_file_n('In get_corrected_map_table '||p_apps_src||' '||p_olap_target);
  end if;
  if p_apps_src='BSC' and p_olap_target='MV' then
    return get_corrected_map_table_bsc_mv(p_map_table,p_map_table_list,p_options,p_number_options,
    p_corr_table_name,p_corr_table_list,p_original_table_list,p_number_corr_table);
  else
    p_corr_table_name:=p_map_table;
    if parse_values(p_map_table_list,',',p_corr_table_list,p_number_corr_table)=false then
      return false;
    end if;
    for i in 1..p_number_corr_table loop
      p_original_table_list(i):=p_corr_table_list(i);
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_corrected_map_table '||sqlerrm);
  return false;
End;

function get_corrected_map_table_bsc_mv(
p_map_table varchar2,--could be sql stmt
p_map_table_list varchar2,
p_options varchar_tabletype,
p_number_options number,
p_corr_table_name out nocopy varchar2,
p_corr_table_list out nocopy varchar_tabletype,
p_original_table_list out nocopy varchar_tabletype,
p_number_corr_table out nocopy number
)return boolean is
l_table_list varchar_tabletype;
l_append_string varchar2(200);
l_syn_owner varchar2(200);
l_syn_object varchar2(200);
l_object_type varchar2(200);
Begin
  if g_debug then
    write_to_log_file_n('In get_corrected_map_table_bsc_mv');
  end if;
  p_number_corr_table:=0;
  if parse_values(p_map_table_list,',',l_table_list,p_number_corr_table)=false then
    return false;
  end if;
  p_corr_table_name:=p_map_table;
  l_append_string:=BSC_IM_UTILS.get_option_value(p_options,p_number_options,'MV NAME APPEND');
  for i in 1..p_number_corr_table loop
    p_corr_table_list(i):=l_table_list(i);
    p_original_table_list(i):=l_table_list(i);
    if get_synonym_property(l_table_list(i),l_syn_owner,l_syn_object) then
      l_object_type:=get_object_type(l_syn_object,l_syn_owner);
      if l_object_type='MATERIALIZED VIEW' then
        p_corr_table_list(i):=l_syn_owner||'.'||l_syn_object;
      else
        l_object_type:=get_object_type(l_syn_object||l_append_string,l_syn_owner);
        if l_object_type='MATERIALIZED VIEW' then
          p_corr_table_list(i):=l_syn_owner||'.'||l_syn_object||l_append_string;
        end if;
      end if;
    end if;
    if  p_corr_table_list(i)<>l_table_list(i) then
      p_corr_table_name:=replace(p_corr_table_name,l_table_list(i),p_corr_table_list(i));
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('p_corr_table_name='||p_corr_table_name);
    for i in 1..p_number_corr_table loop
      write_to_log_file(p_corr_table_list(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_corrected_map_table_bsc_mv '||sqlerrm);
  return false;
End;

function get_db_version return varchar2 is
l_compatibility varchar2(200);
l_ver number;
Begin
  if g_db_version is null then
    DBMS_UTILITY.DB_VERSION(g_db_version,l_compatibility);
    l_ver := to_number(substr(g_db_version,1,instr(g_db_version,'.'))||replace(substr(g_db_version,instr(g_db_version,'.')+1),'.'));
    if g_debug then
      write_to_log_file(g_db_version);
    end if;
    if l_ver>=9 then
      g_db_version:='9i';
    else
      g_db_version:='8i';
    end if;
  end if;
  if g_debug then
    write_to_log_file('DB version='||g_db_version);
  end if;
  return g_db_version;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_db_version '||sqlerrm);
  return null;
End;

function drop_object(
p_object varchar2,
p_owner varchar2
) return boolean is
l_object_type varchar2(200);
l_owner varchar2(200);
l_object varchar2(200);
Begin
  l_owner:=p_owner;
  l_object:=p_object;
  if instr(p_object,'.')<>0 then
    l_owner:=substr(p_object,1,instr(p_object,'.')-1);
    l_object:=substr(p_object,instr(p_object,'.')+1);
  else
    if l_owner is null then
      l_owner:=get_object_owner(l_object);
    end if;
  end if;
  l_object_type:=get_object_type(l_object,l_owner);
  g_stmt:='drop '||l_object_type||' '||l_owner||'.'||l_object;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_object '||sqlerrm);
  return false;
End;

FUNCTION is_mview(
p_mview VARCHAR2,
p_owner VARCHAR2
)RETURN BOOLEAN is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_val NUMBER;
l_owner VARCHAR2(256);

BEGIN
  l_owner := p_owner;
  IF(l_owner IS NULL) THEN
    l_owner := get_mv_owner(p_mview);
  END IF;
  g_stmt:='select 1 from all_mviews where mview_name=:1 and owner=:2';
  IF g_debug THEN
    write_to_log_file_n(g_stmt||' '||p_mview||' '||l_owner);
  END IF;
  OPEN cv FOR g_stmt USING p_mview,l_owner;
  FETCH cv INTO l_val;
  CLOSE cv;
  IF l_val=1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
EXCEPTION WHEN others THEN
  g_status_message:=SQLERRM;
  write_to_log_file_n('Error in is_mview '||SQLERRM);
  RETURN FALSE;
END;

/*
-1 : error
1 : no data
2 : data
*/
function does_table_have_data(p_table varchar2, p_where varchar2) return number is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number:=null;
Begin
  if g_debug then
    write_to_log_file_n('In does_table_have_data , table is '||p_table||' and where clause is '||p_where);
  end if;
  if p_where is null then
    l_stmt:='select 1 from '||p_table||' where rownum=1';
  else
    l_stmt:='select 1 from '||p_table||' where '||p_where||' and rownum=1';
  end if;
  open cv for l_stmt;
  fetch cv into l_res;
  close cv;
  if l_res is null then
    if g_debug then
      write_to_log_file('No');
    end if;
    return 1;
  end if;
  if g_debug then
    write_to_log_file('Yes');
  end if;
  return 2;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in does_table_have_data '||sqlerrm);
  return -1;
End;

--with bind variables
function does_table_have_data(p_table varchar2, p_where varchar2,p_bind varchar2) return boolean is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number:=null;
Begin
  l_stmt:='select 1 from '||p_table||' where '||p_where||' and rownum=1';
  open cv for l_stmt using p_bind;
  fetch cv into l_res;
  close cv;
  if l_res is null then
    if g_debug then
      write_to_log_file('No');
    end if;
    return false;
  end if;
  if g_debug then
    write_to_log_file('Yes');
  end if;
  return true;
Exception when others then
  write_to_log_file_n('Error in does_table_have_data '||sqlerrm);
  raise;
End;

function truncate_table(p_table varchar2, p_owner varchar2) return boolean is
l_stmt varchar2(1000);
l_owner varchar2(200);
Begin
  if g_debug then
    write_to_log_file_n('In truncate_table, p_table='||p_table||', p_owner='||p_owner);
  end if;
  if p_owner is null or instr(p_table,'.')<>0 then
  --if p_owner is null then
    if instr(p_table,'.')<>0 then
      l_stmt:='truncate table '||p_table;
    else
      l_owner:=get_table_owner(p_table);
      l_stmt:='truncate table '||l_owner||'.'||p_table;
    end if;
  else
    l_stmt:='truncate table '||p_owner||'.'||p_table;
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in truncate_table '||sqlerrm);
  return false;
End;


--===========================================================================+
--
--   Name:      IsNumber
--   Description:   Returns true if the string is a number
--   Parameters:
--============================================================================*/
FUNCTION IsNumber (str IN VARCHAR2) RETURN BOOLEAN IS
l_temp NUMBER := -1;
BEGIN
	l_temp:= to_number(str);
	return true;
	exception when others then
		return false;
END;

-- added by ARSANTHA, for bug 3906968

Function get_measures_in_formula(p_measures IN OUT NOCOPY varchar_tabletype,
Expresion IN VARCHAR2) return NUMBER IS
    i NUMBER;
    p_num_measures number;
    l_fields dbms_sql.varchar2_table;
    l_num_fields NUMBER;
    l_formula VARCHAR2(1000);
    cursor cReservedFunctions IS
    SELECT WORD FROM BSC_DB_RESERVED_WORDS WHERE WORD IS NOT NULL AND TYPE = 1;
    cursor cReservedOperators IS
    SELECT WORD FROM BSC_DB_RESERVED_WORDS WHERE WORD IS NOT NULL AND TYPE = 2;
    l_reserved VARCHAR2(100);
    l_reserved_functions varchar_tabletype;
BEGIN
  l_formula := Expresion;
  --Replace the operators by ' '
  open cReservedOperators ;
  LOOP
    fetch cReservedOperators into l_reserved;
    exit when cReservedOperators%notfound;
    l_formula := Replace(l_formula, l_reserved, ' ');
  END LOOP;
  close cReservedOperators ;
  open cReservedFunctions ;
  LOOP
    fetch cReservedFunctions into l_reserved;
    exit when cReservedFunctions%notfound;
    l_reserved_functions(l_reserved_functions.count+1) := l_reserved;
  END LOOP;
  close cReservedFunctions ;
  --Break down the expression which is separated by ' '
  l_num_fields := BSC_MO_HELPER_PKG.DecomposeString(l_formula, ' ', l_fields);
  l_num_fields := l_fields.count;
  p_num_measures := 0;
  i:= l_fields.first;
  LOOP
    EXIT WHEN l_fields.count = 0;
    If l_fields(i) IS NOT NULL Then
      If in_array(l_Reserved_Functions, l_Reserved_Functions.count, l_fields(i)) = false Then
      --The word l_fields(i) is not a reserved function
        If UPPER(l_fields(i)) <> 'NULL' Then
        --the word is not 'NULL'
          If Not  BSC_MO_HELPER_PKG.IsNumber(l_fields(i)) Then
          --the word is not a constant
            p_num_measures := p_num_measures + 1;
            p_measures(p_num_measures) := l_fields(i);
          END IF;
        END IF;
      END IF;
    END IF;
    EXIT WHEN i = l_fields.last;
    i := l_fields.next(i);
  END LOOP;

  for i in 1..p_measures.count loop
    write_to_log_file_n(i||' '||p_measures(i));
  end loop;
  return p_num_measures;

  EXCEPTION WHEN OTHERS THEN
    write_to_log_file_n('Exception in get_measures_in_formula:'||sqlerrm);
    raise;
End;

-- changed by ARSANTHA, for bug 3906968
function find_aggregation_columns(
p_formula varchar2,
p_columns out nocopy varchar_tabletype,
p_number_columns out nocopy number
)return boolean is
--------------------------------------
Begin
  p_number_columns:=0;
  p_number_columns:=get_measures_in_formula(p_columns, p_formula);
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in find_aggregation_columns '||sqlerrm);
  return false;
End;

function get_bsc_owner return varchar2 is
l_bsc_owner varchar2(200);
Begin
  if BSC_IM_UTILS.get_db_user('BSC',l_bsc_owner)=false then
    l_bsc_owner:='BSC';
  end if;
  if l_bsc_owner is null then
    l_bsc_owner:='BSC';
  end if;
  return l_bsc_owner;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  raise;
End;

function get_lang return varchar2 is
Begin
  return userenv('LANG');
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  raise;
End;

function is_like(p_string varchar2,p_comp_string varchar2) return boolean is
l_length number;
Begin
  if p_comp_string is null or p_string is null then
    return false;
  end if;
  l_length:=length(p_comp_string);
  if l_length=0 then
    return false;
  end if;
  if l_length>length(p_string) then
    return false;
  end if;
  if substr(p_string,1,l_length)=p_comp_string then
    return true;
  else
    return false;
  end if;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  raise;
End;

function execute_immediate(
p_stmt varchar2,
p_options varchar2
)return boolean is
Begin
  execute immediate p_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in execute_immediate '||sqlerrm);
  return false;
End;

/*
if p_cube is null, then see if any cube is present
else check for the particular cube
*/
function is_cube_present(
p_cube varchar2,
p_apps_origin varchar2
)return boolean is
l_cube_id number;
l_cube_periodicity varchar2(2000);
l_description varchar2(2000);
l_property varchar2(20000);
l_present boolean;
Begin
  if g_debug then
    write_to_log_file_n('In is_cube_present '||p_cube||' '||p_apps_origin);
  end if;
  l_present:=false;
  if p_cube is null then
    if BSC_IM_INT_MD.get_cube_count>0 then
      l_present:=true;
    else
      l_present:=false;
    end if;
  else
    if BSC_IM_INT_MD.get_cube(p_cube,p_apps_origin,l_cube_id,l_cube_periodicity,l_description,l_property)=false then
      l_present:=false;
    end if;
    if l_cube_id is not null then
      l_present:=true;
    else
      l_present:=false;
    end if;
  end if;
  if g_debug then
    if l_present then
      write_to_log_file('Yes');
    else
      write_to_log_file('No');
    end if;
  end if;
  return l_present;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in is_cube_present '||sqlerrm);
  return false;
End;

function is_view_present(p_view_like varchar2) return boolean is
l_present boolean;
l_res number;
---------------------------
cursor c1(p_view varchar2) is select 1 from user_views where view_name like p_view;
---------------------------
Begin
  if g_debug then
    write_to_log_file_n('select 1 from user_views where view_name like '||p_view_like);
  end if;
  open c1(p_view_like);
  fetch c1 into l_res;
  close c1;
  if l_res=1 then
    if g_debug then
      write_to_log_file('View Present');
    end if;
    l_present:=true;
  else
    if g_debug then
      write_to_log_file('View NOT Present');
    end if;
    l_present:=false;
  end if;
  return l_present;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in is_cube_present '||sqlerrm);
  return false;
End;

/*
given a table or mv, returns the parent mv for the same
*/
function get_parent_mv(
p_mv varchar2,
p_parent_mv out nocopy varchar_tabletype,
p_number_parent_mv out nocopy number
)return boolean is
----------------------------
cursor c1 (p_mv varchar2,p_owner varchar2)
is select mview_name from all_mview_detail_relations where detailobj_name=p_mv and owner=p_owner;
----------------------------
l_owner varchar2(200);
Begin
  l_owner:=get_table_owner(p_mv);
  p_number_parent_mv:=1;
  open c1(p_mv,l_owner);
  loop
    fetch c1 into p_parent_mv(p_number_parent_mv);
    exit when c1%notfound;
    p_number_parent_mv:=p_number_parent_mv+1;
  end loop;
  close c1;
  p_number_parent_mv:=p_number_parent_mv-1;
  if g_debug then
    write_to_log_file('Results');
    for i in 1..p_number_parent_mv loop
      write_to_log_file(p_parent_mv(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_parent_mv '||sqlerrm);
  return false;
End;

/*
given a mv, returns the child objects for the same
*/
function get_child_mv(
p_mv varchar2,
p_child_mv out nocopy varchar_tabletype,
p_number_child_mv out nocopy number
)return boolean is
----------------------------
cursor c1 (p_mv varchar2,p_owner varchar2)
is select detailobj_name from all_mview_detail_relations where mview_name=p_mv and owner=p_owner;
----------------------------
l_owner varchar2(200);
Begin
  l_owner:=get_table_owner(p_mv);
  p_number_child_mv:=1;
  open c1(p_mv,l_owner);
  loop
    fetch c1 into p_child_mv(p_number_child_mv);
    exit when c1%notfound;
    p_number_child_mv:=p_number_child_mv+1;
  end loop;
  close c1;
  p_number_child_mv:=p_number_child_mv-1;
  if g_debug then
    write_to_log_file('Results');
    for i in 1..p_number_child_mv loop
      write_to_log_file(p_child_mv(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_child_mv '||sqlerrm);
  return false;
End;

function is_parent_of_type_present(
p_object varchar2,
p_parent_type varchar2
)return boolean is
----------------------------
--cursor c1 (p_object varchar2,p_parent_type varchar2)
--is select 1 from all_dependencies where referenced_name=p_object and type=p_parent_type and
--owner=g_apps_owner;

cursor cHigherLevel(p_lower_level varchar2) is
select distinct substr(rels.table_name, 1, instr(rels.table_name, '_', -1))||'MV' from
bsc_db_Tables_rels rels
where rels.source_table_name like p_lower_level
and rels.table_name  not like p_lower_level
and rels.table_name  like 'BSC_S%';

cursor cView(p_higher_level varchar2) is
select 1 from user_objects where object_name = p_higher_level and object_type='VIEW';
----------------------------
l_res number;
l_higher_level varchar2(100);
Begin
  if g_apps_owner is null then
    g_apps_owner:=get_apps_owner;
  end if;

  open cHigherLevel(substr(p_object, 1, instr(p_object, '_', -1))||'%');
  fetch cHigherLevel into l_higher_level;
  close cHigherLevel;

  open cView(l_higher_level);
  fetch cView into l_res;
  close cView;

  if l_res=1 then
    if g_debug then
      write_to_log_file('View is parent');
    end if;
    return true;
  else
    if g_debug then
      write_to_log_file('View is NOT parent');
    end if;
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in is_parent_of_type_present '||sqlerrm);
  return false;
End;

function get_apps_owner return varchar2 is
Begin
  return bsc_apps.get_user_schema('APPS');
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_apps_owner '||sqlerrm);
  return null;
End;

END BSC_IM_UTILS;

/
