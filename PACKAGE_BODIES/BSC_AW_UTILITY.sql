--------------------------------------------------------
--  DDL for Package Body BSC_AW_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_AW_UTILITY" AS
/*$Header: BSCAWUTB.pls 120.34 2006/06/16 21:32:45 vsurendr ship $*/

function in_array(
p_array dbms_sql.varchar2_table,
p_value varchar2
) return boolean is
Begin
  for i in 1..p_array.count loop
    if p_array(i)=p_value then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  log('Exception in in_array '||sqlerrm);
  raise;
End;

function in_array(
p_array dbms_sql.number_table,
p_value number
) return boolean is
Begin
  for i in 1..p_array.count loop
    if p_array(i)=p_value then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  log('Exception in in_array '||sqlerrm);
  raise;
End;

function in_array(
p_array varchar2_table,
p_value varchar2
) return boolean is
l_val varchar2(200);
Begin
  l_val:=p_array(p_value);
  return true;
Exception when others then
  return false;
End;

function get_array_index(
p_array dbms_sql.varchar2_table,
p_value varchar2
) return number is
Begin
  for i in 1..p_array.count loop
    if p_array(i)=p_value then
      return i;
    end if;
  end loop;
  return null;
Exception when others then
  log('Exception in get_array_index '||sqlerrm);
  raise;
End;

function get_array_index(
p_array dbms_sql.number_table,
p_value number
) return number is
Begin
  for i in 1..p_array.count loop
    if p_array(i)=p_value then
      return i;
    end if;
  end loop;
  return null;
Exception when others then
  log('Exception in get_array_index '||sqlerrm);
  raise;
End;

/*
given a set of options in a string like DEBUG,LOG=N,TABLESPACE=USER_DATA etc, we will pass in DEBUG and this api will return the value of
the parameter back
if param=DEBUG, return Y
if param=TABLESPACE return USER_DATA
*/
function get_parameter_value(p_string varchar2,p_parameter varchar2,p_separator varchar2) return varchar2 is
l_length number;
l_start number;
l_end number;
--
l_values value_tb;
Begin
  parse_parameter_values(p_string,p_separator,l_values);
  return get_parameter_value(l_values,p_parameter);
Exception when others then
  log('Exception in get_parameter_value '||sqlerrm);
  raise;
End;

--this is the 2nd implementation...given a table of options, return the value
function get_parameter_value(p_options value_tb,p_parameter varchar2) return varchar2 is
Begin
  for i in 1..p_options.count loop
    if p_options(i).parameter=p_parameter then
      return p_options(i).value;
    end if;
  end loop;
  return null;
Exception when others then
  log('Exception in get_parameter_value '||sqlerrm);
  raise;
End;

function get_parameter_value(p_parameter varchar2) return varchar2 is
Begin
  return get_parameter_value(g_options,p_parameter);
Exception when others then
  log('Exception in get_parameter_value '||sqlerrm);
  raise;
End;


/*
this procedure will parse the option string and put the values into value_tb table
*/
procedure parse_parameter_values(
p_string varchar2,
p_separator varchar2,
p_values out nocopy value_tb
) is
--
l_parse_strings dbms_sql.varchar2_table;
Begin
  parse_parameter_values(p_string,p_separator,l_parse_strings);
  for i in 1..l_parse_strings.count loop
    resolve_into_value_r(l_parse_strings(i),p_values(p_values.count+1));
  end loop;
Exception when others then
  log('Exception in parse_parameter_values '||sqlerrm);
  raise;
End;

--given TABLESPACE=USER_DATA or DEBUG LOG it will resolve it into value_r record
procedure resolve_into_value_r(
p_string varchar2,
p_value out nocopy value_r) is
l_end number;
l_len number;
Begin
  l_end:=instr(p_string,'=');
  if l_end=0 then
    p_value.parameter:=p_string;
    p_value.value:='Y';
  else
    l_len:=length(p_string);
    p_value.parameter:=substr(p_string,1,l_end-1);
    --we can have lowest level,zero code=,. here l_end=l_len
    --open:do we have 'N' or null. we will keep null. the calling routine can interpret it as N
    if l_end=l_len then
      p_value.value:=null;
    else
      p_value.value:=substr(p_string,l_end+1,l_len-l_end);
    end if;
  end if;
Exception when others then
  log('Exception in resolve_into_value_r '||sqlerrm);
  raise;
End;

/*
earlier, we just had
parse_parameter_values(p_string,p_separator,l_values);
for i in 1..l_values.count loop
  p_values(p_values.count+1):=l_values(i).parameter;
end loop;
this will not do. parse_parameter_values(p_string,p_separator,l_values); breaks into parameter and value.
which means if it encounters an "=" sign, its split into a parameter + value. this will not do for us.
we have to strictly break up the string according to p_separator
*/
procedure parse_parameter_values(
p_string varchar2,
p_separator varchar2,
p_values out nocopy dbms_sql.varchar2_table
) is
--
l_start number;
l_end number;
l_len number;
Begin
  if p_string is null or p_string='' then
    return;
  end if;
  l_len:=length(p_string);
  if l_len<=0 then
    return;
  end if;
  l_start:=1;
  loop
    l_end:=instr(p_string,p_separator,l_start);
    if l_end=0 then
      l_end:=l_len+1;
    end if;
    if l_end>l_start then
      p_values(p_values.count+1):=ltrim(rtrim(substr(p_string,l_start,(l_end-l_start))));
    end if;
    l_start:=l_end+length(p_separator);
    --we could have p_string as "recursive,multi level," a comma at the end
    if l_end>=l_len or l_start>=l_len then
      exit;
    end if;
  end loop;
Exception when others then
  log('Exception in parse_parameter_values '||sqlerrm);
  raise;
End;

function get_min(num1 number,num2 number) return number is
Begin
  if num1<num2 then
    return num1;
  else
    return num2;
  end if;
Exception when others then
  log('Exception in get_min '||sqlerrm);
  raise;
End;

function contains(p_text varchar2,p_check varchar2) return boolean is
Begin
  if instr(p_text,p_check)>0 then
    return true;
  end if;
  return false;
Exception when others then
  log('Exception in contains '||sqlerrm);
  raise;
End;

--used to populate created by etc
function get_who return number is
Begin
  return 0;
Exception when others then
  log('Exception in get_who '||sqlerrm);
  raise;
End;

procedure delete_aw_object(p_object varchar2) is
Begin
  if p_object is not null then
    bsc_aw_dbms_aw.execute('delete '||p_object);
  end if;
Exception when others then
  null;--may try to delete an object that does not exist
End;

procedure execute_ddl_ne(p_stmt varchar2) is
Begin
  if g_debug then
    log(p_stmt);
  end if;
  execute immediate p_stmt;
Exception when others then
  log('Exception in execute_ddl_ne '||sqlerrm);
End;

procedure execute_ddl(p_stmt varchar2) is
Begin
  if g_debug then
    log(p_stmt);
  end if;
  execute immediate p_stmt;
Exception when others then
  log('Exception in execute_ddl '||sqlerrm);
  raise;
End;

procedure execute_stmt(p_stmt varchar2) is
Begin
  if g_debug then
    log_s('@ '||p_stmt||'(S:'||get_time);
  end if;
  execute immediate p_stmt;
  if g_debug then
    log(',E:'||get_time||') Processed '||sql%rowcount||' rows ');
  end if;
Exception when others then
  log('Exception in execute_stmt '||sqlerrm);
  raise;
End;

procedure execute_stmt_ne(p_stmt varchar2) is
Begin
  execute_stmt(p_stmt);
Exception when others then
  null;
End;

procedure delete_table(p_table varchar2,p_where varchar2) is
--
l_stmt varchar2(1000);
Begin
  if g_debug then
    log('delete '||p_table||' where '||p_where);
  end if;
  if p_where is null then
    l_stmt:='delete '||p_table;
  else
    l_stmt:='delete '||p_table||' where '||p_where;
  end if;
  if g_debug then
    log(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    log('Deleted '||sql%rowcount||' rows '||get_time);
  end if;
Exception when others then
  log('Exception in delete_table '||sqlerrm);
  raise;
End;

/*
this api will normalize a denorm relation. if the relation is already normalized,
no change will happen. so we can pass both denorm arrays and normal arrays
for each parent, check each of the children to see if the children have their
own children. if so, remove children's children from the list
parent  child
year     qtr,month,week,day
qtr      month,day
month    day
week     day
qtr has month and day as its children. so remove month and day from year...
*/
procedure normalize_denorm_relation(p_relation in out nocopy parent_child_tb) is
l_relation parent_child_tb;
l_count number;
Begin
  for i in 1..p_relation.count loop
    if p_relation(i).child is not null and p_relation(i).status is null then
      for j in 1..p_relation.count loop
        if p_relation(j).parent=p_relation(i).child and p_relation(j).status is null then
          for k in 1..p_relation.count loop
            if p_relation(k).parent=p_relation(i).parent and p_relation(k).child=p_relation(j).child then
              p_relation(k).status:='R'; --R means remove
              exit;
            end if;
          end loop;
        end if;
      end loop;
    end if;
  end loop;
  l_relation:=p_relation;
  p_relation.delete;
  l_count:=0;
  for i in 1..l_relation.count loop
    if l_relation(i).status is null then
      l_count:=l_count+1;
      p_relation(l_count):=l_relation(i);
    end if;
  end loop;
Exception when others then
  log('Exception in normalize_denorm_relation '||sqlerrm);
  raise;
End;

--p_type is 'program' or 'aggmap'
procedure make_stmt_for_aw(p_program varchar2,p_stmt in out nocopy varchar2,p_type varchar2) is
Begin
  p_stmt:=p_type||' joinlines(obj('||p_type||' '''||p_program||'''),'''||p_stmt||''')';
Exception when others then
  log('Exception in make_stmt_for_aw '||sqlerrm);
  raise;
End;

procedure add_g_commands(p_commands in out nocopy dbms_sql.varchar2_table,p_command varchar2) is
Begin
  p_commands(p_commands.count+1):=p_command;
Exception when others then
  log('Exception in add_g_commands '||sqlerrm);
  raise;
End;

function get_g_commands(p_commands dbms_sql.varchar2_table,p_index number) return varchar2 is
Begin
  if p_commands.count>0 then
    if p_index is null then --latest
      return p_commands(p_commands.count);
    else
      return p_commands(p_index);
    end if;
  else
    return null;
  end if;
Exception when others then
  log('Exception in get_g_commands '||sqlerrm);
  raise;
End;

procedure trim_g_commands(p_commands in out nocopy dbms_sql.varchar2_table,p_trim number,p_add varchar2) is
Begin
  p_commands(p_commands.count):=substr(p_commands(p_commands.count),1,length(p_commands(p_commands.count))-p_trim)||p_add;
Exception when others then
  log('Exception in trim_g_commands '||sqlerrm);
  raise;
End;

procedure exec_program_commands(p_program varchar2,p_commands dbms_sql.varchar2_table) is
Begin
  --the first stmt is 'dfn abc program' this does not have "joinlines"
  --first try and drop the programs if it exists.
  bsc_aw_dbms_aw.execute_ne('delete '||p_program);
  exec_aw_program_aggmap(p_program,p_commands,'program');
  bsc_aw_dbms_aw.execute('compile '||p_program);
Exception when others then
  log('Exception in exec_program_commands '||sqlerrm);
  raise;
End;

procedure exec_aggmap_commands(p_aggmap varchar2,p_commands dbms_sql.varchar2_table) is
Begin
  --the first stmt is 'dfn abc program' this does not have "joinlines"
  bsc_aw_dbms_aw.execute_ne('delete '||p_aggmap);
  exec_aw_program_aggmap(p_aggmap,p_commands,'aggmap');
  bsc_aw_dbms_aw.execute('compile '||p_aggmap);
Exception when others then
  log('Exception in exec_aggmap_commands '||sqlerrm);
  raise;
End;

--p_type is 'program' or 'aggmap'
procedure exec_aw_program_aggmap(p_name varchar2,p_commands dbms_sql.varchar2_table,p_type varchar2) is
l_commands varchar2(8000);
Begin
  bsc_aw_dbms_aw.execute(p_commands(1));
  for i in 2..p_commands.count loop
    l_commands:=p_commands(i);
    make_stmt_for_aw(p_name,l_commands,p_type);
    bsc_aw_dbms_aw.execute(l_commands);
  end loop;
Exception when others then
  log('Exception in exec_aw_program_aggmap '||sqlerrm);
  raise;
End;

procedure dmp_g_options(p_options value_tb) is
Begin
  log('Options :-');
  for i in 1..p_options.count loop
    log(p_options(i).parameter||'='||p_options(i).value);
  end loop;
Exception when others then
  log('Exception in dmp_g_options '||sqlerrm);
  raise;
End;

/*
called from bsc_aw_adapter_kpi.create_base_table_sql
this procedure strips out the aggregation functions from the formula.
the base table may have the same number of keys as the dim set in this case, there is no need to do the aggregation
when loading the cube from the base table. so we need to remove  the agg functions
bsc supports
Apply aggregation method to the each element of the formula, e.g.: SUM(source_column1)/SUM(source_column2)
Apply aggregation method to the overall formula, e.g.: SUM(source_column1/source_column2)
Formulas between 2 calculated Measures e.g.: SUM(source_col1/source_col2)/AVG(source_col3+source_col4)

for case II, we simply remove string till the first (

if the agg function is count(), we simply replace it with 1. since there is no group by, count() will anyway be returning 1.
this is not working. getting this error
ORA-34738: (NOUPDATE) A severe problem has been detected. Analytic workspace operations have been disabled.
ORA-06512: at "APPS.BSC_AW_UTILITY", line 466
ORA-06512: at "APPS.BSC_AW_LOAD", line 112
ORA-37666: ** SYSTEM ERROR xsSqlImport01 **
A severe problem has been detected. Please save your work via EXPORT or OUTFILE and exit as soon as possible.
As a safety measure, analytic workspace operations have been disabled. Call Oracle OLAP technical support.
ORA-06512: at line 7
somehow, hardcoded 1 is interpreted as true / false 1.
so we will see if count is in the formula. if yes, we will go for groupby
*/
procedure parse_out_agg_function(p_formula varchar2,p_noagg_formula out nocopy varchar2) is
--
l_agg_function varchar2(100);
Begin
  l_agg_function:=ltrim(rtrim(substr(p_formula,1,instr(p_formula,'(')-1)));
  if lower(l_agg_function)='count' then
    p_noagg_formula:='(1)';
  else
    p_noagg_formula:=substr(p_formula,instr(p_formula,'('));
  end if;
Exception when others then
  log('Exception in parse_out_agg_function '||sqlerrm);
  raise;
End;

/*
given a number array, get the max
*/
function get_max(p_array dbms_sql.number_table) return number is
l_max number;
Begin
  if p_array.count<=0 then
    return null;
  end if;
  l_max:=p_array(1);
  for i in 2..p_array.count loop
    if p_array(i)>l_max then
      l_max:=p_array(i);
    end if;
  end loop;
  return l_max;
Exception when others then
  log('Exception in get_max '||sqlerrm);
  raise;
End;


function does_table_have_data(p_table varchar2,p_where varchar2) return varchar2 is
--
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number;
Begin
  g_stmt:='select 1 from '||p_table;
  if p_where is not null then
    g_stmt:=g_stmt||' where '||p_where||' and rownum=1';
  else
    g_stmt:=g_stmt||' where rownum=1';
  end if;
  if g_debug then
    log(g_stmt);
  end if;
  open cv for g_stmt;
  fetch cv into l_res;
  close cv;
  if g_debug then
    log('result='||l_res);
  end if;
  if l_res=1 then
    return 'Y';
  else
    return 'N';
  end if;
Exception when others then
  log('Exception in does_table_have_data '||sqlerrm);
  raise;
End;

/*
this function is used to see if the aggregation is a simple aggregation or if this is a formula
its a formula when we have averaqge at the lowest level
*/
function is_std_aggregation_function(p_agg_formula varchar2) return varchar2 is
Begin
  if g_debug then
    log('In is_std_aggregation_function, p_agg_formula='||p_agg_formula);
  end if;
  if upper(p_agg_formula)='SUM' or upper(p_agg_formula)='AVERAGE' or upper(p_agg_formula)='MAX' or upper(p_agg_formula)='MIN' or
    upper(p_agg_formula)='COUNT' then
    if g_debug then
      log('Yes');
    end if;
    return 'Y';
  end if;
  if g_debug then
    log('No');
  end if;
  return 'N';
Exception when others then
  log('Exception in is_std_aggregation_function '||sqlerrm);
  raise;
End;

/*this sees if an aggregation formula can be safely partitioned even if there are aggregations */
function is_PT_aggregation_function(p_agg_formula varchar2) return varchar2 is
Begin
  if upper(p_agg_formula)='SUM' or upper(p_agg_formula)='MAX' or upper(p_agg_formula)='MIN' then
    return 'Y';
  end if;
  return 'N';
Exception when others then
  log('Exception in is_pt_aggregation_function '||sqlerrm);
  raise;
End;

/*currently, only sum has CC. not able to get aggcount to work ie create cube <...> with aggcount and then aggregate cube using aggmap */
function is_CC_aggregation_function(p_agg_formula varchar2) return varchar2 is
Begin
  if upper(p_agg_formula)='SUM' then
    return 'Y';
  end if;
  return 'N';
Exception when others then
  log('Exception in is_CC_aggregation_function '||sqlerrm);
  raise;
End;

/*
if we have non-std agg, we execute it as cube=formula. there is no aggmap
so we look for std agg : average
*/
function is_avg_aggregation_function(p_agg_formula varchar2) return varchar2 is
Begin
  if upper(p_agg_formula)='AVERAGE' or upper(p_agg_formula)='AVG' then
    return 'Y';
  else
    return 'N';
  end if;
Exception when others then
  log('Exception in is_avg_aggregation_function '||sqlerrm);
  raise;
End;

/*
this function is used by aggregation module to see if a measure is a part of an agg formula
the aggregtion module will then substitute the measure with the cube name

p_strng is the original  string
p_text thisis the text to search for
p_location a table of all locations in p_string where p_text occurs
*/
function is_string_present(
p_string varchar2,
p_text varchar2,
p_location out nocopy dbms_sql.number_table
) return boolean is
--
l_start number;
l_end number;
l_len number;
l_char varchar2(10);
l_flag boolean;
Begin
  --there can be multiple occurances of text in string
  l_start:=1;
  l_len:=length(p_string);
  loop
    l_start:=instr(p_string,p_text,l_start);
    if l_start=0 then
      exit;
    else --l_start>1
      l_flag:=true;
      l_end:=l_start+length(p_text);
      if l_start>1 then
        l_char:=substr(p_string,l_start-1,1);
        if is_ascii(l_char) then
          l_flag:=false;
        end if;
      end if;
      if l_flag and l_end<l_len then
        l_char:=substr(p_string,l_end,1);
        if is_ascii(l_char) then
          l_flag:=false;
        end if;
      end if;
      if l_flag then --we did find p_text in p_string
        p_location(p_location.count+1):=l_start;
      end if;
      l_start:=l_end;
    end if;
  end loop;
  if p_location.count>0 then
    return true;
  else
    return false;
  end if;
Exception when others then
  log('Exception in is_string_present '||sqlerrm);
  raise;
End;

/*
this fucntion sees if a character is a special char or a variable name continuing
example
sees if the char is between A and Z, 0 and 9 or _

p_char is one char
*/
function is_ascii(p_char varchar2) return boolean is
l_ascii_a number;
l_ascii_z number;
l_ascii_0 number;
l_ascii_9 number;
l_char number;
Begin
  l_ascii_a:=ascii('A');
  l_ascii_z:=ascii('Z');
  l_ascii_0:=ascii('0');
  l_ascii_9:=ascii('9');
  l_char:=ascii(upper(p_char));
  if p_char='_' then
    return true;
  elsif is_in_between(l_char,l_ascii_a,l_ascii_z) then
    return true;
  elsif is_in_between(l_char,l_ascii_0,l_ascii_9) then
    return true;
  else
    return false;
  end if;
Exception when others then
  log('Exception in is_ascii '||sqlerrm);
  raise;
End;

function is_in_between(p_input number,p_left number,p_right number) return boolean is
Begin
  if p_left>p_right then
    if p_input>=p_right and p_input<=p_left then
      return true;
    else
      return false;
    end if;
  else
    if p_input<=p_right and p_input>=p_left then
      return true;
    else
      return false;
    end if;
  end if;
Exception when others then
  log('Exception in is_in_between '||sqlerrm);
  raise;
End;

/*
this procedure is used by the agg module to replace the measure names with the cube names
database replace procedure does not support replacing the occurance of a string at a particular location. we cannot
blindly replace. example, we may have formula : cons_revenue / revenue + cost
if we have to replace revenue with "cube_revenue", we cannot do replace(agg_formula,'revenue','cube_revenue'). it will make
this cons_cube_revenue + cube_revenue + cost. this is wrong. so we have this procedure which will replace at the
secified locations

if a string is mm + abcd/123 + abcd/mnq
we need to relace abcd with cube_abcd
we will first break it into parts without abcd
l_string_parts(1):=mm +
l_string_parts(2):=/123 +
l_string_parts(3):=/mnq
then we simply put them together as
l_string_parts(1)||cube_abcd||l_string_parts(2)||cube_abcd||l_string_parts(3)
*/
procedure replace_string(
p_string in out nocopy varchar2,
p_old_text varchar2,
p_new_text varchar2,
p_start_array dbms_sql.number_table
) is
--
l_string_parts dbms_sql.varchar2_table;
l_start number;
l_len number;
l_length number;
Begin
  l_start:=1;
  l_len:=length(p_old_text);
  l_length:=length(p_string);
  for i in 1..p_start_array.count loop
    l_string_parts(l_string_parts.count+1):=substr(p_string,l_start,p_start_array(i)-l_start);
    l_start:=p_start_array(i)+l_len;
  end loop;
  --now we add the last part of the strin
  if l_start<l_length then
    l_string_parts(l_string_parts.count+1):=substr(p_string,l_start,l_length-l_start+1);
  else
    l_string_parts(l_string_parts.count+1):=null;
  end if;
  --now reform the string , this time with the new string
  p_string:=null;
  for i in 1..l_string_parts.count-1 loop
    p_string:=p_string||l_string_parts(i)||p_new_text;
  end loop;
  --append the last part
  p_string:=p_string||l_string_parts(l_string_parts.count);
Exception when others then
  log('Exception in replace_string '||sqlerrm);
  raise;
End;

function get_adv_sum_profile return number is
--
l_adv_sum_profile number;
Begin
  l_adv_sum_profile:=bsc_aw_utility.get_parameter_value(g_options,'SUMMARIZATION LEVEL');
  if l_adv_sum_profile is null or l_adv_sum_profile=0 then
    l_adv_sum_profile:=1000000;
  end if;
  return l_adv_sum_profile;
Exception when others then
  log('Exception in get_adv_sum_profile '||sqlerrm);
  raise;
End;
---------------------------

procedure truncate_table(p_table varchar2) is
--
l_owner varchar2(100);
l_stmt varchar2(1000);
Begin
  if instr(p_table,'.')>0 then
    l_stmt:='truncate table '||p_table;
  else
    l_owner:=get_table_owner(p_table);
    l_stmt:='truncate table '||l_owner||'.'||p_table;
  end if;
  if g_debug then
    log(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    log(get_time);
  end if;
Exception when others then
  log('Exception in truncate_table '||sqlerrm);
  raise;
End;

function get_table_owner(p_table varchar2) return varchar2 is
--
cursor c1 is select table_owner from user_synonyms where synonym_name=upper(p_table);
l_owner varchar2(100);
Begin
  if instr(p_table,'.')>0 then
    l_owner:=substr(p_table,1,instr(p_table,'.')-1);
    return l_owner;
  end if;
  open c1;
  fetch c1 into l_owner;
  close c1;
  if l_owner is null then
    l_owner:=get_apps_schema_name;
  end if;
  return l_owner;
Exception when others then
  log('Exception in get_table_owner '||sqlerrm);
  return null;
End;

FUNCTION get_apps_schema_name RETURN VARCHAR2 IS
  l_apps_schema_name VARCHAR2(30);
  CURSOR c_apps_schema_name IS
  SELECT oracle_username
  FROM fnd_oracle_userid WHERE oracle_id
  BETWEEN 900 AND 999 AND read_only_flag = 'U';
BEGIN
  OPEN c_apps_schema_name;
  FETCH c_apps_schema_name INTO l_apps_schema_name;
  CLOSE c_apps_schema_name;
  RETURN l_apps_schema_name;
EXCEPTION
  WHEN OTHERS THEN
  RETURN NULL;
END get_apps_schema_name;

---------------------------
procedure init_all(p_debug boolean) is
Begin
  g_debug:=p_debug;
  if nvl(get_parameter_value('TRACE'),'N')='Y' then
    set_aw_trace;
  end if;
Exception when others then
  raise;
End;

/*
this will init all procedures
this is useful if we dont need to worry about which all packs's init have been called.
useful for dbms jobs
*/
procedure init_all_procedures is
Begin
  if get_parameter_value(g_options,'DEBUG LOG')='Y'
  or bsc_aw_utility.g_log_level>=FND_LOG.G_CURRENT_RUNTIME_LEVEL then
    g_debug:=true;
  else
    g_debug:=false;
  end if;
  init_all(g_debug);
  bsc_aw_adapter_dim.init_all;
  bsc_aw_adapter_kpi.init_all;
  bsc_aw_bsc_metadata.init_all;
  bsc_metadata.init_all;
  bsc_aw_load_dim.init_all;
  bsc_aw_load_kpi.init_all;
  bsc_aw_dbms_aw.init_all;
  bsc_aw_md_api.init_all;
  bsc_aw_md_wrapper.init_all;
  bsc_aw_management.init_all;
  bsc_aw_calendar.init_all;
  bsc_aw_adapter.init_all;
  bsc_aw_load.init_all;
  bsc_aw_read.init_all;
Exception when others then
  raise;
End;


--write to same line
procedure log_s(p_message varchar2) is
Begin
  write_to_file('LOG',p_message,false);
Exception when others then
  null;
End;

procedure log(p_message varchar2) is
Begin
  write_to_file('LOG',p_message,true);
Exception when others then
  null;
End;

procedure log_n(p_message varchar2) is
Begin
  log('  ');
  log(p_message);
Exception when others then
  null;
End;

function get_time return varchar2 is
Begin
  return ' '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS')||' ';
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
  loop
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
  log_fnd(p_message,bsc_aw_utility.g_log_level);
Exception when others then
  null;
End;

procedure log_fnd(p_message varchar2,p_severity number) is
l_table dbms_sql.varchar2_table;
Begin
  if p_severity>=FND_LOG.G_CURRENT_RUNTIME_LEVEL then
    convert_varchar2_to_table(p_message,3990,l_table);
    for i in 1..l_table.count loop
      FND_LOG.STRING(p_severity,'BSC-AW',l_table(i));
    end loop;
  end if;
Exception when others then
  null;
End;

procedure open_file(p_object_name varchar2) is
l_dir varchar2(200);
Begin
  l_dir:=null;
  l_dir:=get_parameter_value('UTL_FILE_LOG');
  if l_dir is null then
    l_dir:=fnd_profile.value('UTL_FILE_LOG');
  end if;
  if l_dir is null then
    l_dir:='/sqlcom/log';
  end if;
  FND_FILE.PUT_NAMES(p_object_name||'.log',p_object_name||'.out',l_dir);
  log('File Directory is '||l_dir);
  if l_dir is null then
    log('Please set profile option UTL_FILE_LOG to point to a valid directory the database can write to. Only then can you see the log files');
    log('generated from parallel jobs(when Debug Mode is true) for load and aggregations');
  end if;
Exception when others then
  raise;
End;

procedure create_temp_tables is
Begin
  g_stmt:='create global temporary table bsc_aw_temp_vn (name varchar2(400),id number)';
  execute_ddl_ne(g_stmt);--execute_ddl_ne = ignore exception
  g_stmt:='create global temporary table bsc_aw_temp_pc(parent varchar2(300),child varchar2(300),id number)';
  execute_ddl_ne(g_stmt);--execute_ddl_ne = ignore exception
  g_stmt:='create global temporary table bsc_aw_temp_cv(change_vector_min_value number,change_vector_max_value number,change_vector_base_table varchar2(30))'; --for change vector
  execute_ddl_ne(g_stmt);--execute_ddl_ne = ignore exception
  --tables to normalize a denorm hierarchy
  --for parent, child, we can re-use bsc_aw_temp_pc
  --for count of each dim value, we can use bsc_aw_temp_vn
Exception when others then
  log_n('Exception in create_temp_tables '||sqlerrm);
  raise;
End;

/*5121276 bsc_aw_dim_delete needs to be created here too*/
procedure create_perm_tables is
table_columns bsc_update_util.t_array_temp_table_cols;
l_tablespace varchar2(300);
l_idx_tablespace varchar2(300);
all_tables all_tables_tb;
table_name varchar2(40);
stmt varchar2(2000);
flag boolean;
Begin
  /*use BSC api to do the creation same way as loader */
  table_name:='bsc_aw_dim_delete';
  BSC_APPS.Init_Bsc_Apps;
  l_tablespace:=BSC_APPS.Get_Tablespace_Name(BSC_APPS.dimension_table_tbs_type);
  l_idx_tablespace:=BSC_APPS.Get_Tablespace_Name(BSC_APPS.dimension_index_tbs_type);
  table_columns.delete;
  table_columns(table_columns.count+1).column_name:='DIM_LEVEL';
  table_columns(table_columns.count).data_type:='VARCHAR2';
  table_columns(table_columns.count).data_size:=300;
  table_columns(table_columns.count).add_to_index:='N';
  table_columns(table_columns.count+1).column_name:='DELETE_VALUE';
  table_columns(table_columns.count).data_type:='VARCHAR2';
  table_columns(table_columns.count).data_size:=400;
  table_columns(table_columns.count).add_to_index:='N';
  /* */
  flag:=false;
  all_tables:=get_db_table_parameters(table_name,get_table_owner(table_name));
  if all_tables.count>0 then
    if all_tables(1).TEMPORARY='Y' then
      /*this is old implementation. drop and recreate */
      log(table_name||' is Temp Table. Dropping to create as permanent');
      stmt:='drop table '||table_name;
      BSC_APPS.Do_DDL(stmt,AD_DDL.DROP_TABLE,table_name);
      flag:=true;
    end if;
  else
    flag:=true;
  end if;
  if flag then
    if bsc_update_util.Create_Permanent_Table(table_name,table_columns,table_columns.count,l_tablespace,l_idx_tablespace)=false then
      log_n('Exception in bsc_update_util.Create_Permanent_Table. For now, not raising this exception...');
    end if;
  end if;
Exception when others then
  log_n('Exception in create_perm_tables '||sqlerrm);
  raise;
End;

/*
9.204 for 9i
10.104 or 10.103 etc for 10g
*/
function get_db_version return number is
l_version varchar2(200);
l_compatibility varchar2(200);
counter number;
Begin
  if g_db_version is null then
    l_version:=get_parameter_value('DB VERSION');
    /*5335425. some languages have decimal representation as 10,2 instead od 10.2  */
    if l_version is null then
      dbms_utility.db_version(l_version,l_compatibility);
      l_version:=substr(l_version,1,instr(l_version,'.'))||replace(substr(l_version,instr(l_version,'.')+1),'.');
      l_version:=substr(l_version,1,instr(l_version,','))||replace(substr(l_version,instr(l_version,',')+1),',');
    end if;
    counter:=0;
    loop
      begin
        counter:=counter+1;
        if counter>=3 then
          log('get_db_version failed for attempts with , and .  could not derive db version info');
          raise g_exception;
        end if;
        g_db_version:=to_number(l_version);
        exit;
      exception when others then
        if sqlcode=-6502 then /*ORA-06502: PL/SQL: numeric or value error: character to number conversion error */
          if instr(l_version,'.')>0 then
            l_version:=replace(l_version,'.',',');
          elsif instr(l_version,',')>0 then
            l_version:=replace(l_version,',','.');
          else
            raise;
          end if;
        else
          raise;
        end if;
      end;
    end loop;
    if g_debug then
      log('DB Version='||g_db_version);
    end if;
  end if;
  return g_db_version;
Exception when others then
  log_n('Exception in get_db_version '||sqlerrm);
  raise;
End;

/*
procedure takes in a string upto 32000 characters and breaks it up to the specified length based on space " "
and creates varchar2 table
we need this to make the filter stmt.
say start =1, limit =1000. see 1001th character. is it " " ? if yes, end=end-1. break up string
if not, run backwards till we find " ". end=end-1. break up string
*/
procedure convert_varchar2_to_table(
p_string varchar2,
p_limit number,
p_table out nocopy dbms_sql.varchar2_table
) is
--
l_length number;
l_start number;
l_end number;
l_space_found boolean;
Begin
  if p_string is null then
    return;
  end if;
  l_length:=length(p_string);
  if l_length<=p_limit then
    p_table(1):=p_string;
    return;
  end if;
  --
  l_start:=1;
  loop
    l_end:=l_start+p_limit;
    if l_end>=l_length then
      l_end:=l_length;
      p_table(p_table.count+1):=substr(p_string,l_start,l_end-l_start+1);
      exit;
    else
      if substr(p_string,l_end,1) <> ' ' then
        --go backwards till we find ' '
        l_space_found:=false;
        for i in reverse l_start..l_end loop
          if substr(p_string,i,1)=' ' then
            l_end:=i;
            l_space_found:=true;
            exit;
          end if;
        end loop;
        --if we dont get a space, we cannot split the line. we have an exception
        if l_space_found=false then
          log('Could not find space to split line in convert_varchar2_to_table. Fatal...');
          raise no_data_found;
        end if;
        --
      end if;
      --split the line
      p_table(p_table.count+1):=substr(p_string,l_start,l_end-l_start);
      l_start:=l_end+1;
    end if;
  end loop;
Exception when others then
  log_n('Exception in convert_varchar2_to_table '||sqlerrm);
  log('String='||p_string);
  raise;
End;

procedure drop_db_object_ne(p_object varchar2,p_object_type varchar2) is
Begin
  drop_db_object(p_object,p_object_type);
Exception when others then
  null;
End;

procedure drop_db_object(p_object varchar2,p_object_type varchar2) is
Begin
  execute immediate 'drop '||p_object_type||' '||p_object;
Exception when others then
  log_n('Exception in drop_db_object '||sqlerrm);
  raise;
End;

/*
sleep_time=20 sec
random_time=10 sec
sleep for 20+random(1 to 10)
*/
procedure sleep(p_sleep_time integer,p_random_time integer) is
Begin
  dbms_lock.sleep(p_sleep_time);
  if p_random_time is not null and p_random_time>0 then
    dbms_lock.sleep(get_random_number(p_random_time));
  end if;
Exception when others then
  log_n('Exception in sleep '||sqlerrm);
  raise;
End;

function get_random_number(p_seed number) return number is
Begin
  return dbms_utility.get_hash_value(to_char(get_dbms_time),0,p_seed);
Exception when others then
  log_n('Exception in get_random_number '||sqlerrm);
  raise;
End;

procedure remove_array_element(p_array in out nocopy dbms_sql.varchar2_table,p_object varchar2) is
Begin
  for i in 1..p_array.count loop
    if p_array(i)=p_object then
      for j in i..p_array.count-1 loop
        p_array(j):=p_array(j+1);
      end loop;
      p_array.delete(p_array.count);
      exit;
    end if;
  end loop;
Exception when others then
  log_n('Exception in remove_array_element '||sqlerrm);
  raise;
End;

/*
handle dbms jobs for parallel loading and aggregations in 10g+
we will have a global table with info on all current jobs. procedure
wait on jobs will wait on jobs. jobs will communicate with the main process
using dbms_pipe
create job will add entries to the global table. clean job procedure will clean
up the table
p_process: will contain the string with the full procedure call and parameters.

*/
procedure start_job(
p_job_name varchar2,
p_run_id number,
p_process varchar2,
p_options varchar2
) is
PRAGMA AUTONOMOUS_TRANSACTION;  --we have a commit here to start dbms job
--
l_job_id integer;
l_parallel_job parallel_job_r;
Begin
  --should we have protection to make sure we do not launch the same job more than once? lets have it for now
  l_parallel_job:=get_parallel_job(p_job_name);
  if l_parallel_job.job_name is not null then
    if l_parallel_job.status <> 'success' and l_parallel_job.status <> 'error' then
      log_n('The same job '||p_job_name||' is currently running');
      raise bsc_aw_utility.g_exception;
    end if;
  end if;
  --create a pipe for communication
  create_pipe(p_job_name);
  if g_debug then
    log_n('dbms_job.submit('||p_process||')'||bsc_aw_utility.get_time);
  end if;
  dbms_job.submit(l_job_id,p_process);
  --add to the global array list
  g_parallel_jobs(g_parallel_jobs.count+1).job_name:=p_job_name;
  g_parallel_jobs(g_parallel_jobs.count).run_id:=p_run_id; --1,2, 3 etc
  g_parallel_jobs(g_parallel_jobs.count).job_id:=l_job_id;
  g_parallel_jobs(g_parallel_jobs.count).start_time:=get_time;
  g_parallel_jobs(g_parallel_jobs.count).status:='running';
  commit;
Exception when others then
  log_n('Exception in start_job '||sqlerrm);
  raise;
End;

function get_parallel_job(p_job_name varchar2) return parallel_job_r is
Begin
  for i in 1..g_parallel_jobs.count loop
    if g_parallel_jobs(i).job_name=p_job_name then
      return g_parallel_jobs(i);
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_parallel_job '||sqlerrm);
  raise;
End;

procedure wait_on_jobs(p_options varchar2,p_job_status out nocopy parallel_job_tb) is
Begin
  if g_debug then
    log('Wait on jobs >>'||get_time);
    dmp_parallel_jobs;
  end if;
  clean_up_jobs(null); --clean up done jobs
  if check_all_jobs_complete(g_parallel_jobs)=false then
    wait_on_jobs_sleep(p_options,p_job_status);
    /*looked at dbms_alert as a way to avoid active wait. but it looks like dbms_alert internally goes for active wait */
  end if;
  if g_debug then
    log_n('Wait on jobs Done >>'||get_time);
    dmp_parallel_jobs;
  end if;
  clean_up_jobs(null); --clean up done jobs
Exception when others then
  log_n('Exception in wait_on_jobs '||sqlerrm);
  raise;
End;

procedure wait_on_jobs_sleep(p_options varchar2,p_job_status out nocopy parallel_job_tb) is
--
l_prev_time number;
Begin
  if g_debug then
    log_n('wait_on_jobs_sleep');
  end if;
  loop
    if l_prev_time is null then
      l_prev_time:=g_job_wait_time_large;
    else
      l_prev_time:=g_job_wait_time_small;
    end if;
    sleep(l_prev_time,null);
    check_jobs(g_parallel_jobs);
    if check_all_jobs_complete(g_parallel_jobs) then
      exit;
    end if;
  end loop;
  p_job_status:=g_parallel_jobs;
Exception when others then
  log_n('Exception in wait_on_jobs_sleep '||sqlerrm);
  raise;
End;

procedure check_jobs(p_parallel_jobs in out nocopy parallel_job_tb) is
Begin
  for i in 1..p_parallel_jobs.count loop
    if p_parallel_jobs(i).status <> 'success' and p_parallel_jobs(i).status <> 'error' then
      if is_job_running(p_parallel_jobs(i).job_id)='N' then --mark this job as done
        update_job_status(p_parallel_jobs(i));--read from the pipe. then update the fields
      end if;
    end if;
  end loop;
Exception when others then
  log_n('Exception in check_jobs '||sqlerrm);
  raise;
End;

function check_all_jobs_complete(p_parallel_jobs parallel_job_tb) return boolean is
Begin
  for i in 1..p_parallel_jobs.count loop
    if p_parallel_jobs(i).status <> 'success' and p_parallel_jobs(i).status <> 'error' then
      return false;
    end if;
  end loop;
  return true;
Exception when others then
  log_n('Exception in check_all_jobs_complete '||sqlerrm);
  raise;
End;

procedure update_job_status(p_parallel_job in out nocopy parallel_job_r) is
--
l_pipe_message varchar2(2000);
Begin
  --get pipe message
  l_pipe_message:=get_pipe_message(p_parallel_job.job_name);
  if l_pipe_message is null then
    --the process core dumped without getting a chance to write to the pipe
    p_parallel_job.status:='error';
    p_parallel_job.sqlcode:=-20000;
    p_parallel_job.message:=null;
    p_parallel_job.end_time:=get_time;
  else
    p_parallel_job.status:=get_parameter_value(l_pipe_message,'status',',');
    p_parallel_job.sqlcode:=get_parameter_value(l_pipe_message,'sqlcode',','); --null for success
    p_parallel_job.message:=get_parameter_value(l_pipe_message,'message',','); --null for success
    p_parallel_job.end_time:=get_time;
  end if;
  remove_pipe(p_parallel_job.job_name);
Exception when others then
  log_n('Exception in update_job_status '||sqlerrm);
  raise;
End;

procedure create_pipe(p_pipe_name varchar2) is
l_status number;
Begin
  remove_pipe(p_pipe_name);
  l_status:=dbms_pipe.create_pipe(pipename=>p_pipe_name,private=>false);
Exception when others then
  if sqlcode=-23322 then --naming conflict
    if g_debug then
      log_n('Pipe with same name '||p_pipe_name||' exists');
    end if;
  else
    log_n('Exception in create_pipe '||sqlerrm);
    raise;
  end if;
End;

function get_pipe_message(p_pipe_name varchar2) return varchar2 is
--
l_status number;
l_message varchar2(2000);
Begin
  l_status:=dbms_pipe.receive_message(pipename=>p_pipe_name);
  if l_status=0 then
    dbms_pipe.unpack_message(l_message);
  end if;
  return l_message;
Exception when others then
  log_n('Exception in get_pipe_message '||sqlerrm);
  raise;
End;

procedure send_pipe_message(p_pipe_name varchar2,p_message varchar2) is
PRAGMA AUTONOMOUS_TRANSACTION;
--
l_status number;
Begin
  dbms_pipe.reset_buffer;
  dbms_pipe.pack_message(p_message);
  l_status:=dbms_pipe.send_message(pipename=>p_pipe_name);
  commit;
Exception when others then
  log_n('Exception in send_pipe_message '||sqlerrm);
  raise;
End;

procedure remove_pipe(p_pipe_name varchar2) is
--
l_status number;
Begin
  l_status:=dbms_pipe.remove_pipe(pipename=>p_pipe_name);
Exception when others then
  log_n('Exception in remove_pipe '||sqlerrm);
End;

/*
we look at all_jobs and dba_jobs_running because when a job is launched, it takes some time
for it to start.
*/
function is_job_running(p_job_id number) return varchar2 is
--
cursor c1 is select 1 from all_jobs where job=p_job_id;
l_status number;
Begin
  open c1;
  fetch c1 into l_status;
  close c1;
  if l_status=1 then
    return 'Y';
  else
    return 'N';
  end if;
Exception when others then
  log_n('Exception in is_job_running '||sqlerrm);
  raise;
End;

--for now, clean up all the jobs
procedure clean_up_jobs(p_options varchar2) is
l_parallel_jobs parallel_job_tb;
Begin
  if get_parameter_value(p_options,'all',',')='Y' then
    g_parallel_jobs.delete;
  else
    --clean up success and error
    for i in 1..g_parallel_jobs.count loop
      if g_parallel_jobs(i).status <> 'success' and g_parallel_jobs(i).status <> 'error' then
        l_parallel_jobs(l_parallel_jobs.count+1):=g_parallel_jobs(i);
      end if;
    end loop;
    g_parallel_jobs.delete;
    g_parallel_jobs:=l_parallel_jobs;
  end if;
Exception when others then
  log_n('Exception in clean_up_jobs '||sqlerrm);
  raise;
End;

procedure dmp_parallel_jobs is
Begin
  log_n('dmp parallel jobs >>');
  for i in 1..g_parallel_jobs.count loop
    log('job name='||g_parallel_jobs(i).job_name||',run id='||g_parallel_jobs(i).run_id||
    ',job id='||g_parallel_jobs(i).job_id||',status='||g_parallel_jobs(i).status||',sqlcode='||g_parallel_jobs(i).sqlcode||
    ',message='||g_parallel_jobs(i).message||'(S:'||g_parallel_jobs(i).start_time||' -> E:'||g_parallel_jobs(i).end_time||')');
  end loop;
  log_n('-------------');
Exception when others then
  log_n('Exception in dmp_parallel_jobs '||sqlerrm);
  raise;
End;

/*
to launch jobs, we need to make sure that
(job_queue_processes-count_jobs_running) > p_number_jobs
*/
function can_launch_jobs(p_number_jobs number) return varchar2 is
Begin
  /*we will enable parallel by default */
  if get_db_version>=10 and nvl(get_parameter_value('exclusive lock'),'N')='N'
  and nvl(get_parameter_value('NO PARALLEL'),'N')='N' then
    if p_number_jobs<=1 then
      return 'N';
    end if;
    return can_launch_dbms_job(p_number_jobs);
  end if;
  return 'N'; --if 9i, no jobs possible
Exception when others then
  log_n('Exception in can_launch_jobs '||sqlerrm);
  raise;
End;

function can_launch_dbms_job(p_number_jobs number) return varchar2 is
l_job_queue_processes number;
l_jobs_running number;
l_status varchar2(20);
Begin
  l_status:='Y';
  l_job_queue_processes:=to_number(get_vparameter('job_queue_processes'));
  l_jobs_running:=count_jobs_running;
  if g_debug then
    log_n('can_launch_jobs,l_job_queue_processes='||l_job_queue_processes||',l_jobs_running='||l_jobs_running||', p_number_jobs='||p_number_jobs);
  end if;
  if l_status='Y' then
    if l_job_queue_processes is null then
      l_status:='N';
    elsif (l_job_queue_processes-l_jobs_running)<=p_number_jobs then
      l_status:='N';
    end if;
  end if;
  if l_status='Y' then
    /*p_number_jobs is more than 2 times the cpu count, we disable jobs */
    if p_number_jobs>(2*get_cpu_count) then
      l_status:='N';
    end if;
  end if;
  return l_status;
Exception when others then
  log_n('Exception in can_launch_dbms_job '||sqlerrm);
  raise;
End;

function count_jobs_running return number is
--
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_count number;
Begin
  open cv for 'select count(*) from all_scheduler_running_jobs';
  fetch cv into l_count;
  close cv;
  return l_count;
Exception when others then
  if g_debug then
    log_n('Exception in count_jobs_running '||sqlerrm);
  end if;
  return 0;
End;

function get_vparameter(p_name varchar2) return varchar2 is
--
cursor c1 is select value from v$parameter param where name=p_name;
l_value varchar2(200);
Begin
  open c1;
  fetch c1 into l_value;
  return l_value;
Exception when others then
  log_n('Exception in get_vparameter '||sqlerrm);
  raise;
End;

--makes a string out of the options. for dbms jobs
function get_option_string return varchar2 is
l_string varchar2(4000);
Begin
  for i in 1..g_options.count loop
    l_string:=l_string||g_options(i).parameter;
    if g_options(i).value is not null then
      l_string:=l_string||'='||g_options(i).value;
    end if;
    l_string:=l_string||',';
  end loop;
  return l_string;
Exception when others then
  log_n('Exception in get_option_string '||sqlerrm);
  raise;
End;

function get_session_id return number is
l_sid number;
Begin
  select mystat.sid into l_sid from v$mystat mystat where rownum=1;
  return l_sid;
Exception when others then
  return userenv('SESSIONID');
End;

--used primarily as job_name in 10g multi threading to get a unique name
function get_dbms_time return number is
Begin
  return dbms_utility.get_time;
Exception when others then
  log_n('Exception in get_dbms_time '||sqlerrm);
  raise;
End;

function make_string_from_list(p_list dbms_sql.varchar2_table) return varchar2 is
Begin
  return make_string_from_list(p_list,',');
Exception when others then
  log_n('Exception in make_string_from_list '||sqlerrm);
  raise;
End;

function make_string_from_list(p_list dbms_sql.varchar2_table,p_separator varchar2) return varchar2 is
--
l_string varchar2(20000);
Begin
  l_string:=null;
  if p_list.count>0 then
    for i in 1..p_list.count loop
      l_string:=l_string||p_list(i)||p_separator;
    end loop;
    l_string:=substr(l_string,1,length(l_string)-1);
  end if;
  return l_string;
Exception when others then
  log_n('Exception in make_string_from_list '||sqlerrm);
  raise;
End;

/*
see if the options are part of g_options. if not, add them
if p_option_value is null, add all in p_options. else add p_option_value in p_options
this will also update the option value if already in g_options
*/
procedure add_option(p_options varchar2,p_option_value varchar2,p_separator varchar2) is
l_values value_tb;
l_found boolean;
Begin
  parse_parameter_values(p_options,p_separator,l_values);
  for i in 1..l_values.count loop
    if p_option_value is null or l_values(i).parameter=p_option_value then
      l_found:=false;
      for j in 1..g_options.count loop
        if g_options(j).parameter=l_values(i).parameter then
          l_found:=true;
          g_options(j):=l_values(i);
          exit;
        end if;
      end loop;
      if l_found=false then
        g_options(g_options.count+1):=l_values(i);
      end if;
    end if;
  end loop;
Exception when others then
  log_n('Exception in add_option '||sqlerrm);
  raise;
End;

procedure set_option(p_parameter varchar2,p_value varchar2) is
Begin
  for i in 1..g_options.count loop
    if g_options(i).parameter=p_parameter then
      g_options(i).value:=p_value;
      return;
    end if;
  end loop;
  g_options(g_options.count+1).parameter:=p_parameter;
  g_options(g_options.count).value:=p_value;
Exception when others then
  log_n('Exception in set_option '||sqlerrm);
  raise;
End;

function get_hash_value(p_string varchar2,p_start number,p_end number) return varchar2 is
l_hash_value number;
Begin
  l_hash_value:=dbms_utility.get_hash_value(p_string,p_start,p_end);
  return to_char(l_hash_value);
Exception when others then
  log_n('Exception in get_hash_value '||sqlerrm);
  raise;
End;

procedure merge_array(p_array in out nocopy dbms_sql.varchar2_table,p_values dbms_sql.varchar2_table) is
Begin
  for i in 1..p_values.count loop
    if in_array(p_array,p_values(i))=false then
      p_array(p_array.count+1):=p_values(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in merge_array '||sqlerrm);
  raise;
End;

procedure merge_value(p_array in out nocopy dbms_sql.varchar2_table,p_value varchar2) is
Begin
  if p_value is not null then
    if in_array(p_array,p_value)=false then
      p_array(p_array.count+1):=p_value;
    end if;
  end if;
Exception when others then
  log_n('Exception in merge_value '||sqlerrm);
  raise;
End;

procedure subtract_array(p_array in out nocopy dbms_sql.varchar2_table,p_values dbms_sql.varchar2_table) is
l_array dbms_sql.varchar2_table;
Begin
  if p_values.count>0 and p_array.count>0 then
    for i in 1..p_array.count loop
      l_array(i):=p_array(i);
    end loop;
    p_array.delete;
    for i in 1..l_array.count loop
      if in_array(p_values,l_array(i))=false then
        p_array(p_array.count+1):=l_array(i);
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in subtract_array '||sqlerrm);
  raise;
End;

procedure merge_array(p_array in out nocopy dbms_sql.number_table,p_values dbms_sql.number_table) is
Begin
  for i in 1..p_values.count loop
    if in_array(p_array,p_values(i))=false then
      p_array(p_array.count+1):=p_values(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in merge_array '||sqlerrm);
  raise;
End;

procedure merge_value(p_array in out nocopy dbms_sql.number_table,p_value number) is
Begin
  if p_value is not null then
    if in_array(p_array,p_value)=false then
      p_array(p_array.count+1):=p_value;
    end if;
  end if;
Exception when others then
  log_n('Exception in merge_value '||sqlerrm);
  raise;
End;

procedure set_aw_trace is
Begin
  if g_trace_set is null or g_trace_set=false then
    execute immediate 'alter session set sql_trace=true';
    execute immediate 'alter session set events=''10046 trace name context forever, level 12''';
    execute immediate 'alter session set events=''37395 trace name context forever, level 1''';
    bsc_aw_dbms_aw.execute('dotf tracefile');
    g_trace_set:=true;
  end if;
Exception when others then
  log_n('Exception in set_aw_trace '||sqlerrm);
  raise;
End;

procedure dmp_values(p_table dbms_sql.varchar2_table,p_text varchar2) is
Begin
  log('------');
  log(p_text);
  for i in 1..p_table.count loop
    log(p_table(i));
  end loop;
Exception when others then
  log_n('Exception in dmp_values '||sqlerrm);
  raise;
End;

function get_sqlerror(p_sqlcode number,p_action varchar2) return sqlerror_r is
Begin
  for i in 1..g_sqlerror.count loop
    if g_sqlerror(i).sql_code=p_sqlcode and g_sqlerror(i).action=p_action then
      return g_sqlerror(i);
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_sqlerror '||sqlerrm);
  raise;
End;

procedure add_sqlerror(p_sqlcode number,p_action varchar2,p_message varchar2) is
l_sqlerror sqlerror_r;
Begin
  l_sqlerror:=get_sqlerror(p_sqlcode,p_action);
  if l_sqlerror.sql_code is null then
    g_sqlerror(g_sqlerror.count+1).sql_code:=p_sqlcode;
    g_sqlerror(g_sqlerror.count).action:=p_action;
    g_sqlerror(g_sqlerror.count).message:=p_message;
  end if;
Exception when others then
  log_n('Exception in add_sqlerror '||sqlerrm);
  raise;
End;

procedure remove_sqlerror(p_sqlcode number,p_action varchar2) is
l_sqlerror sqlerror_tb;
Begin
  l_sqlerror:=g_sqlerror;
  g_sqlerror.delete;
  for i in 1..l_sqlerror.count loop
    if not(l_sqlerror(i).sql_code=p_sqlcode and l_sqlerror(i).action=p_action) then
      g_sqlerror(g_sqlerror.count+1):=l_sqlerror(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in remove_sqlerror '||sqlerrm);
  raise;
End;

procedure remove_all_sqlerror is --remove all sqlerror
Begin
  g_sqlerror.delete;
Exception when others then
  log_n('Exception in remove_all_sqlerror '||sqlerrm);
  raise;
End;

function is_sqlerror(p_sqlcode number,p_action varchar2) return boolean is
l_sqlerror sqlerror_r;
Begin
  l_sqlerror:=get_sqlerror(p_sqlcode,p_action);
  if l_sqlerror.sql_code is null then
    return false;
  else
    return true;
  end if;
Exception when others then
  log_n('Exception in is_sqlerror '||sqlerrm);
  raise;
End;

/*
-1 : 2 rel diff
0 : 2 rel same
1 : 1 is in 2
2: 2 is in 1
*/
function compare_pc_relations(p_pc_1 parent_child_tb,p_pc_2 parent_child_tb) return number is
--
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_1_minus_2 number;
l_2_minus_1 number;
l_temp1 varchar2(200);
l_temp2 varchar2(200);
l_return_code number;
Begin
  bsc_aw_utility.delete_table('bsc_aw_temp_pc',null);
  for i in 1..p_pc_1.count loop
    if p_pc_1(i).parent is not null and p_pc_1(i).child is not null then
      execute immediate 'insert into bsc_aw_temp_pc(parent,child,id) values (:1,:2,:3)' using nvl(p_pc_1(i).parent,'null'),
      nvl(p_pc_1(i).child,'null'),1;
    end if;
  end loop;
  for i in 1..p_pc_2.count loop
    if p_pc_2(i).parent is not null and p_pc_2(i).child is not null then
      execute immediate 'insert into bsc_aw_temp_pc(parent,child,id) values (:1,:2,:3)' using nvl(p_pc_2(i).parent,'null'),
      nvl(p_pc_2(i).child,'null'),2;
    end if;
  end loop;
  l_1_minus_2:=0;
  l_2_minus_1:=0;
  --
  l_temp1:=null;
  l_temp2:=null;
  open cv for 'select parent,child from bsc_aw_temp_pc where id=1 minus select parent,child from bsc_aw_temp_pc where id=2';
  fetch cv into l_temp1,l_temp2;
  close cv;
  if l_temp1 is not null then
    l_1_minus_2:=1;
  end if;
  if g_debug then
    log('1 minus 2 '||l_temp1||' '||l_temp2);
  end if;
  --
  l_temp1:=null;
  l_temp2:=null;
  open cv for 'select parent,child from bsc_aw_temp_pc where id=2 minus select parent,child from bsc_aw_temp_pc where id=1';
  fetch cv into l_temp1,l_temp2;
  close cv;
  if l_temp1 is not null then
    l_2_minus_1:=1;
  end if;
  if g_debug then
    log('2 minus 1 '||l_temp1||' '||l_temp2);
  end if;
  --
  if l_1_minus_2=0 and l_2_minus_1=0 then --same
    l_return_code:=0;
  elsif l_1_minus_2=0 and l_2_minus_1>0 then --1 is in 2
    l_return_code:=1;
  elsif l_1_minus_2>0 and l_2_minus_1=0 then --2 is in 1
    l_return_code:=2;
  elsif l_1_minus_2>0 and l_2_minus_1>0 then --not same
    l_return_code:=-1;
  end if;
  if g_debug then
    log('compare_pc_relations, Return code='||l_return_code);
  end if;
  return l_return_code;
Exception when others then
  log_n('Exception in compare_pc_relations '||sqlerrm);
  raise;
End;

procedure init_is_new_value is
Begin
  g_values.delete;
Exception when others then
  log_n('Exception in init_is_new_value '||sqlerrm);
  raise;
End;

procedure init_is_new_value(p_index number) is
Begin
  g_values(p_index).id:=p_index;
  g_values(p_index).new_values.delete;
Exception when others then
  log_n('Exception in init_is_new_value '||sqlerrm);
  raise;
End;

--goes hand in hand with init_is_new_value
function is_new_value(p_value varchar2,p_index number) return boolean is
l_flag boolean;
Begin
  l_flag:=in_array(g_values(p_index).new_values,p_value);
  if l_flag=false then
    g_values(p_index).new_values(g_values(p_index).new_values.count+1):=p_value;
  end if;
  return not(l_flag);
Exception when others then
  log_n('Exception in is_new_value '||sqlerrm);
  raise;
End;

--goes hand in hand with init_is_new_value
function is_new_value(p_value number,p_index number) return boolean is
Begin
  return is_new_value(to_char(p_value),p_index);
Exception when others then
  log_n('Exception in is_new_value '||sqlerrm);
  raise;
End;

function order_array(p_array dbms_sql.varchar2_table) return dbms_sql.varchar2_table is
l_array dbms_sql.varchar2_table;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if p_array.count>0 then
    delete_table('bsc_aw_temp_vn',null);
    forall i in 1..p_array.count
      execute immediate 'insert into bsc_aw_temp_vn(name) values (:1)' using p_array(i);
    open cv for 'select name from bsc_aw_temp_vn order by name';
    loop
      fetch cv into l_array(l_array.count+1);
      exit when cv%notfound;
    end loop;
  end if;
  return l_array;
Exception when others then
  log_n('Exception in order_array '||sqlerrm);
  raise;
End;

function make_upper(p_array dbms_sql.varchar2_table) return dbms_sql.varchar2_table is
l_array dbms_sql.varchar2_table;
Begin
  for i in 1..p_array.count loop
    l_array(i):=upper(p_array(i));
  end loop;
  return l_array;
Exception when others then
  log_n('Exception in make_upper '||sqlerrm);
  raise;
End;

/*
getting db locks. used for co-ordinating multiple MO sessions
for now, we do not implement this. in lock management, we already do spin wait. so 2 sessions cane be started, the 2nd will spin
and try to get the lock
*/
procedure get_db_lock(p_lock_name varchar2) is
l_lock_handle varchar2(200);
l_flag integer;
Begin
  l_lock_handle:=get_lock_handle(p_lock_name);
  l_flag:=dbms_lock.request(lockhandle=>l_lock_handle,timeout=>bsc_aw_utility.g_max_wait_time);
  if l_flag=1 then --timeout
    log('Timeout in dbms_lock.request('||p_lock_name||') ...');
    raise bsc_aw_utility.g_exception;
  end if;
Exception when others then
  log_n('Exception in get_db_lock '||sqlerrm);
  raise;
End;

procedure release_db_lock(p_lock_name varchar2) is
l_lock_handle varchar2(2000);
l_flag integer;
Begin
  l_lock_handle:=get_lock_handle(p_lock_name);
  l_flag:=dbms_lock.release(lockhandle=>l_lock_handle);
  if l_flag=3 or l_flag=5 then --error
    log('Exception in dbms_lock.release. Return flag='||l_flag);
    raise bsc_aw_utility.g_exception;
  end if;
Exception when others then
  log_n('Exception in release_db_lock '||sqlerrm);
  raise;
End;

function get_lock_handle(p_lock_name varchar2) return varchar2 is
l_lock_handle varchar2(2000);
Begin
  dbms_lock.allocate_unique(lockname=>p_lock_name,lockhandle=>l_lock_handle);
  return l_lock_handle;
Exception when others then
  log_n('Exception in get_lock_handle '||sqlerrm);
  raise;
End;

function get_closest_2_power_number(p_number number) return number is
l_num number;
Begin
  l_num:=1;
  if p_number is null or p_number<2 then
    return 0;
  end if;
  loop
    l_num:=l_num*2;
    if l_num>p_number then
      return l_num/2;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_closest_2_power '||sqlerrm);
  raise;
End;

procedure analyze_table(p_table varchar2,p_interval number) is
l_table varchar2(100);
l_owner varchar2(100);
l_all_tables all_tables_tb;
l_analyze boolean;
Begin
  l_table:=substr(p_table,instr(p_table,'.')+1);
  l_owner:=get_table_owner(p_table);
  l_analyze:=false;
  if p_interval is null or p_interval=0 then
    l_analyze:=true;
  else
    l_all_tables:=get_db_table_parameters(l_table,l_owner);
    if l_all_tables(1).last_analyzed is null then
      l_analyze:=true;
    else
      if (sysdate-l_all_tables(1).last_analyzed)>p_interval then
        l_analyze:=true;
      end if;
    end if;
  end if;
  if l_analyze then
    analyze_table(l_table,l_owner);
  end if;
Exception when others then
  log_n('Exception in analyze_table '||sqlerrm);
  raise;
End;

procedure analyze_table(p_table varchar2,p_owner varchar2) is
Begin
  if g_debug then
    log('Analyze '||p_owner||'.'||p_table||get_time);
  end if;
  dbms_stats.gather_table_stats(OWNNAME=>p_owner,TABNAME=>p_table);
  if g_debug then
    log('Done '||get_time);
  end if;
Exception when others then
  log_n('Exception in analyze_table '||sqlerrm);
  raise;
End;

function get_db_table_parameters(p_table varchar2,p_owner varchar2) return all_tables_tb is
l_tables all_tables_tb;
cursor c1 is select * from all_tables where table_name=upper(p_table) and owner=upper(p_owner);
Begin
  open c1;
  fetch c1 into l_tables(1);
  close c1;
  return l_tables;
Exception when others then
  log_n('Exception in get_db_table_parameters '||sqlerrm);
  raise;
End;

/*given a relation and a start value, get the trim hier with all upper values*/
procedure get_upper_trim_hier(p_parent_child parent_child_tb,p_seed varchar2,p_trim_parent_child in out nocopy parent_child_tb) is
l_parents parent_child_tb;
flag boolean;
Begin
  get_parent_values(p_parent_child,p_seed,l_parents);
  for i in 1..l_parents.count loop
    get_upper_trim_hier(p_parent_child,l_parents(i).parent,p_trim_parent_child);
  end loop;
  if l_parents.count>0 then
    for i in 1..l_parents.count loop
      flag:=false;
      for j in 1..p_trim_parent_child.count loop --add only distinct list
        if p_trim_parent_child(j).parent=l_parents(i).parent and p_trim_parent_child(j).child=l_parents(i).child then
          flag:=true;
          exit;
        end if;
      end loop;
      if flag=false then
        p_trim_parent_child(p_trim_parent_child.count+1):=l_parents(i);
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in get_upper_trim_hier '||sqlerrm);
  raise;
End;

/*given a relation and a start value, get the trim hier with all lower values*/
procedure get_lower_trim_hier(p_parent_child parent_child_tb,p_seed varchar2,p_trim_parent_child in out nocopy parent_child_tb) is
l_children parent_child_tb;
flag boolean;
Begin
  get_child_values(p_parent_child,p_seed,l_children);
  for i in 1..l_children.count loop
    get_lower_trim_hier(p_parent_child,l_children(i).child,p_trim_parent_child);
  end loop;
  if l_children.count>0 then
    for i in 1..l_children.count loop
      flag:=false;
      for j in 1..p_trim_parent_child.count loop --add only distinct list
        if p_trim_parent_child(j).parent=l_children(i).parent and p_trim_parent_child(j).child=l_children(i).child then
          flag:=true;
          exit;
        end if;
      end loop;
      if flag=false then
        p_trim_parent_child(p_trim_parent_child.count+1):=l_children(i);
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in get_lower_trim_hier '||sqlerrm);
  raise;
End;

procedure get_parent_values(p_parent_child parent_child_tb,p_child varchar2,p_parents out nocopy parent_child_tb) is
Begin
  for i in 1..p_parent_child.count loop
    if p_parent_child(i).child=p_child and p_parent_child(i).parent is not null then
      p_parents(p_parents.count+1):=p_parent_child(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_parent_values '||sqlerrm);
  raise;
End;

procedure get_child_values(p_parent_child parent_child_tb,p_parent varchar2,p_children out nocopy parent_child_tb) is
Begin
  for i in 1..p_parent_child.count loop
    if p_parent_child(i).parent=p_parent and p_parent_child(i).child is not null then
      p_children(p_children.count+1):=p_parent_child(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_child_values '||sqlerrm);
  raise;
End;

procedure get_all_parents(p_parent_child parent_child_tb,p_child varchar2,p_parents in out nocopy dbms_sql.varchar2_table) is
l_parents parent_child_tb;
Begin
  get_parent_values(p_parent_child,p_child,l_parents);
  for i in 1..l_parents.count loop
    get_all_parents(p_parent_child,l_parents(i).parent,p_parents);
  end loop;
  if l_parents.count>0 then
    for i in 1..l_parents.count loop
      if l_parents(i).parent is not null then
        merge_value(p_parents,l_parents(i).parent);
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in get_all_parents '||sqlerrm);
  raise;
End;

procedure get_all_children(p_parent_child parent_child_tb,p_parent varchar2,p_children in out nocopy dbms_sql.varchar2_table) is
l_children parent_child_tb;
Begin
  get_child_values(p_parent_child,p_parent,l_children);
  for i in 1..l_children.count loop
    get_all_children(p_parent_child,l_children(i).child,p_children);
  end loop;
  if l_children.count>0 then
    for i in 1..l_children.count loop
      if l_children(i).child is not null then
        merge_value(p_children,l_children(i).child);
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in get_all_children '||sqlerrm);
  raise;
End;

/*we have a string like property1=value1,property2,property3=value3
we pass new property and or new value like property2 value value2 or property 3 value 33 or property4 with value 4
we update p_string with the values*/
procedure update_property(p_string in out nocopy varchar2,p_parameter varchar2,p_value varchar2,p_separator varchar2) is
l_values dbms_sql.varchar2_table;
l_index number;
Begin
  parse_parameter_values(p_string,p_separator,l_values);
  for i in 1..l_values.count loop
    if l_values(i)=p_parameter or instr(l_values(i),p_parameter||'=')>0 then
      l_index:=i;
      exit;
    end if;
  end loop;
  if l_index is null then
    l_index:=l_values.count+1;
  end if;
  if p_value is null then
    l_values(l_index):=p_parameter;
  else
    l_values(l_index):=p_parameter||'='||p_value;
  end if;
  p_string:=make_string_from_list(l_values,p_separator);  /* trailing separator*/
Exception when others then
  log_n('Exception in update_property '||sqlerrm);
  raise;
End;

/* p_property_string contains prop1=value1,prop2=value2 etc*/
procedure merge_property(p_property in out nocopy property_tb,p_property_string varchar2,p_separator varchar2) is
l_values value_tb;
Begin
  if p_property_string is null then
    return;
  end if;
  parse_parameter_values(p_property_string,p_separator,l_values);
  for i in 1..l_values.count loop
    merge_property(p_property,l_values(i).parameter,null,l_values(i).value);
  end loop;
Exception when others then
  log_n('Exception in merge_property '||sqlerrm);
  raise;
End;

/*add/update property */
procedure merge_property(p_property in out nocopy property_tb,p_property_name varchar2,p_property_type varchar2,p_property_value varchar2) is
Begin
  for i in 1..p_property.count loop
    if p_property(i).property_name=p_property_name then
      p_property(i).property_type:=p_property_type;
      p_property(i).property_value:=p_property_value;
      exit;
    end if;
  end loop;
  p_property(p_property.count+1).property_name:=p_property_name;
  p_property(p_property.count).property_type:=p_property_type;
  p_property(p_property.count).property_value:=p_property_value;
Exception when others then
  log_n('Exception in merge_property '||sqlerrm);
  raise;
End;

procedure remove_property(p_property in out nocopy property_tb,p_property_name varchar2) is
l_property property_tb;
Begin
  for i in 1..p_property.count loop
    if p_property(i).property_name<>p_property_name then
      l_property(l_property.count+1):=p_property(i);
    end if;
  end loop;
  p_property:=l_property;
Exception when others then
  log_n('Exception in remove_property '||sqlerrm);
  raise;
End;

function get_property(p_property property_tb,p_property_name varchar2) return property_r is
l_property property_r;
Begin
  for i in 1..p_property.count loop
    if p_property(i).property_name=p_property_name then
      l_property:=p_property(i);
      exit;
    end if;
  end loop;
  return l_property;
Exception when others then
  log_n('Exception in get_property '||sqlerrm);
  raise;
End;

function get_property_string(p_property property_tb) return varchar2 is
l_string varchar2(8000);
Begin
  for i in 1..p_property.count loop
    if p_property(i).property_value is null then
      l_string:=l_string||p_property(i).property_name||',';
    else
      l_string:=l_string||p_property(i).property_name||'='||p_property(i).property_value||',';
    end if;
  end loop;
  if l_string is not null then
    l_string:=substr(l_string,1,length(l_string)-1);
  end if;
  return l_string;
Exception when others then
  log_n('Exception in get_property_string '||sqlerrm);
  raise;
End;

function get_cpu_count return number is
Begin
  return to_number(get_vparameter('cpu_count'));
Exception when others then
  log_n('Exception in get_cpu_count '||sqlerrm);
  raise;
End;

/*example load_stats('before load'); */
procedure load_stats(p_name varchar2,p_group varchar2) is
ig pls_integer;
Begin
  for i in 1..g_ssg.count loop
    if g_ssg(i).group_name=p_group then
      ig:=i;
      exit;
    end if;
  end loop;
  if ig is null then
    ig:=g_ssg.count+1;
  end if;
  --
  g_ssg(ig).group_name:=p_group;
  g_ssg(ig).session_stats(g_ssg(ig).session_stats.count+1).stats_name:=p_name;
  g_ssg(ig).session_stats(g_ssg(ig).session_stats.count).stats_time:=sysdate;
  load_session_stats(g_ssg(ig).session_stats(g_ssg(ig).session_stats.count).stats);
  load_session_waits(g_ssg(ig).session_stats(g_ssg(ig).session_stats.count).wait_events);
Exception when others then
  log_n('Exception in load_stats '||sqlerrm);
  raise;
End;

procedure load_session_stats(p_stats out nocopy stats_tb) is
cursor c1 is select statname.name, mystat.value from v$mystat mystat,v$statname statname where mystat.statistic#=statname.statistic#
order by statname.name;
Begin
  for r1 in c1 loop
    p_stats(p_stats.count+1).stats_name:=r1.name;
    p_stats(p_stats.count).value:=r1.value;
  end loop;
Exception when others then
  log_n('Exception in load_session_stats '||sqlerrm);
  raise;
End;

procedure load_session_waits(p_wait_events out nocopy wait_event_tb) is
cursor c1 is select event.event,event.total_waits,event.total_timeouts,round(event.time_waited) time_waited,
round(event.average_wait) average_wait,round(event.max_wait) max_wait
from v$session_event event where event.sid=get_session_id order by event.event;
Begin
  for r1 in c1 loop
    p_wait_events(p_wait_events.count+1).event_name:=r1.event;
    p_wait_events(p_wait_events.count).total_waits:=r1.total_waits;
    p_wait_events(p_wait_events.count).total_timeouts:=r1.total_timeouts;
    p_wait_events(p_wait_events.count).time_waited:=r1.time_waited;
    p_wait_events(p_wait_events.count).average_wait:=r1.average_wait;
    p_wait_events(p_wait_events.count).max_wait:=r1.max_wait;
  end loop;
Exception when others then
  log_n('Exception in load_session_waits '||sqlerrm);
  raise;
End;

/*only 1 group object per group name */
function get_session_stats_group(p_group varchar2) return session_stats_group_r is
l_ssg session_stats_group_r;
Begin
  for i in 1..g_ssg.count loop
    if g_ssg(i).group_name=p_group then
      l_ssg:=g_ssg(i);
      exit;
    end if;
  end loop;
  return l_ssg;
Exception when others then
  log_n('Exception in get_session_stats_group '||sqlerrm);
  raise;
End;

function get_ssg_index(p_group varchar2) return pls_integer is
Begin
  for i in 1..g_ssg.count loop
    if g_ssg(i).group_name=p_group then
      return i;
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_ssg_index '||sqlerrm);
  raise;
End;

/*printing cleans the stats */
procedure print_stats(p_group varchar2) is
l_ssg pls_integer;
Begin
  l_ssg:=get_ssg_index(p_group);
  if l_ssg is not null then
    diff_stats(g_ssg(l_ssg));
    diff_waits(g_ssg(l_ssg));
    print_stats(g_ssg(l_ssg));
    clean_stats(g_ssg(l_ssg));
  end if;
Exception when others then
  log_n('Exception in print_stats '||sqlerrm);
  raise;
End;

procedure clean_stats(p_group varchar2) is
l_ssg pls_integer;
Begin
  l_ssg:=get_ssg_index(p_group);
  if l_ssg is not null then
    clean_stats(g_ssg(l_ssg));
  end if;
Exception when others then
  log_n('Exception in clean_stats '||sqlerrm);
  raise;
End;

procedure clean_stats(p_ssg in out nocopy session_stats_group_r) is
Begin
  p_ssg.session_stats.delete;
Exception when others then
  log_n('Exception in clean_stats '||sqlerrm);
  raise;
End;

procedure print_stats(p_ssg session_stats_group_r) is
Begin
  if p_ssg.group_name is not null then
    log('===========================Stats=============================================================');
    log('Stats Group : '||p_ssg.group_name);
    for i in 2..p_ssg.session_stats.count loop
      print_stats(p_ssg.session_stats(i));
    end loop;
  end if;
Exception when others then
  log_n('Exception in print_stats '||sqlerrm);
  raise;
End;

procedure print_stats(p_session_stats session_stats_r) is
Begin
  log('.');
  log('Stats       : '||p_session_stats.stats_name);
  log('Stats Time  : '||to_char(p_session_stats.stats_time,'MM/DD/YYYY HH24:MI:SS'));
  print_session_stats(p_session_stats.stats);
  log('.');
  print_session_wait(p_session_stats.wait_events);
  log('.');
Exception when others then
  log_n('Exception in print_stats '||sqlerrm);
  raise;
End;

procedure print_session_stats(p_stats stats_tb) is
Begin
  log(rpad('Stats Name',64,'-')||'Value (Diff Value)');
  for i in 1..p_stats.count loop
    log(rpad(p_stats(i).stats_name,64,'-')||p_stats(i).value||' ('||p_stats(i).diff_value||')');
  end loop;
Exception when others then
  log_n('Exception in print_session_stats '||sqlerrm);
  raise;
End;

procedure print_session_wait(p_wait_events wait_event_tb) is
Begin
  log(rpad('Wait Event',52,'-')||rpad('Total Waited (Diff)',30,'-')||rpad('Total Waits (Diff)',30,'-')||rpad('Timeouts (Diff)',20));
  for i in 1..p_wait_events.count loop
    log(rpad(p_wait_events(i).event_name,52,'-')||rpad(p_wait_events(i).time_waited||'('||p_wait_events(i).diff_time_waited||')',30,'-')||
    rpad(p_wait_events(i).total_waits||'('||p_wait_events(i).diff_total_waits||')',30,'-')||
    rpad(p_wait_events(i).total_timeouts||'('||p_wait_events(i).diff_total_timeouts||')',20));
  end loop;
Exception when others then
  log_n('Exception in print_session_wait '||sqlerrm);
  raise;
End;

procedure diff_stats(p_ssg in out nocopy session_stats_group_r) is
Begin
  for i in 2..p_ssg.session_stats.count loop
    diff_session_stats(p_ssg.session_stats(i).stats,p_ssg.session_stats(i-1).stats);
  end loop;
Exception when others then
  log_n('Exception in diff_stats '||sqlerrm);
  raise;
End;

/*assumes stats is ordered by stats name */
procedure diff_session_stats(p_new_stats in out nocopy stats_tb,p_old_stats stats_tb) is
js pls_integer;
flag boolean;
Begin
  js:=1;
  for i in 1..p_new_stats.count loop
    flag:=false;
    for j in js..p_old_stats.count loop
      if p_old_stats(j).stats_name=p_new_stats(i).stats_name then
        flag:=true;
        js:=j+1;
        p_new_stats(i).diff_value:=p_new_stats(i).value-p_old_stats(j).value;
        exit;
      end if;
    end loop;
    if flag=false then
      js:=1;
    end if;
  end loop;
Exception when others then
  log_n('Exception in diff_session_stats '||sqlerrm);
  raise;
End;

/*assumes waits are ordered by event name */
procedure diff_waits(p_ssg in out nocopy session_stats_group_r) is
Begin
  for i in 2..p_ssg.session_stats.count loop
    diff_session_wait(p_ssg.session_stats(i).wait_events,p_ssg.session_stats(i-1).wait_events);
  end loop;
Exception when others then
  log_n('Exception in diff_waits '||sqlerrm);
  raise;
End;

procedure diff_session_wait(p_new_wait in out nocopy wait_event_tb,p_old_wait wait_event_tb) is
js pls_integer;
flag boolean;
Begin
  js:=1;
  for i in 1..p_new_wait.count loop
    flag:=false;
    for j in js..p_old_wait.count loop
      if p_new_wait(i).event_name=p_old_wait(j).event_name then
        flag:=true;
        js:=j+1;
        p_new_wait(i).diff_total_waits:=p_new_wait(i).total_waits-p_old_wait(j).total_waits;
        p_new_wait(i).diff_total_timeouts:=p_new_wait(i).total_timeouts-p_old_wait(j).total_timeouts;
        p_new_wait(i).diff_time_waited:=p_new_wait(i).time_waited-p_old_wait(j).time_waited;
      end if;
    end loop;
    if flag=false then
      js:=1;
    end if;
  end loop;
Exception when others then
  log_n('Exception in diff_session_wait '||sqlerrm);
  raise;
End;

procedure kill_session(p_sid number,p_serial number) is
Begin
  execute immediate 'alter system kill session '''||p_sid||','||p_serial||'''';
Exception when others then
  log_n('Exception in kill_session '||sqlerrm);
  raise;
End;

function get_table_count(p_table varchar2,p_where varchar2) return number is
stmt varchar2(4000);
TYPE RefCurTyp IS REF CURSOR;
cv RefCurTyp;
table_count number;
Begin
  stmt:='select count(*) from '||p_table;
  if p_where is not null then
    stmt:=stmt||' where '||p_where;
  end if;
  if g_debug then
    log(stmt||get_time);
  end if;
  open cv for stmt;
  fetch cv into table_count;
  close cv;
  if g_debug then
    log('Result='||table_count||get_time);
  end if;
  return table_count;
Exception when others then
  log_n('Exception in get_table_count '||sqlerrm);
  raise;
End;

function is_number(p_number varchar2) return boolean is
l_number number;
Begin
  l_number:=to_number(p_number);
  return true;
Exception when others then
  return false;
End;

END BSC_AW_UTILITY;

/
