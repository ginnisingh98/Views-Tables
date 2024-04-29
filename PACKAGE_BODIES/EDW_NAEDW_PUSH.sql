--------------------------------------------------------
--  DDL for Package Body EDW_NAEDW_PUSH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_NAEDW_PUSH" AS
/*$Header: EDWNAEDB.pls 115.29 2004/02/13 05:08:51 smulye ship $*/

g_debug boolean:=false;

cursor c0 is
select dim.dim_name,
       dim.dim_id
from   edw_dimensions_md_v dim
where dim_name not like 'EDW_GL_ACCT%_M'
and dim_name <> 'EDW_NA'
order by dim.dim_name;

cursor c0_0(p_dim varchar2) is
select dim.dim_name,dim.dim_id
from
edw_dimensions_md_v dim
where dim_long_name=p_dim;

cursor c00(p_dim_id number) is
select level_name||'_LTC'
from edw_levels_md_v
where dim_id=p_dim_id;

cursor c1(p_dim_id number) is
select distinct
    lvl_child.level_name||'_LTC',
    lvl_parent.level_name||'_LTC'
from
    edw_levels_md_v lvl_child,
    edw_levels_md_v lvl_parent,
    edw_pvt_level_relation_md_v lvl_rel,
    edw_hierarchies_md_v hier
where
    hier.dim_id=p_dim_id
and lvl_rel.hierarchy_id=hier.hier_id
and lvl_child.level_id=lvl_rel.child_level_id
and lvl_parent.level_id=lvl_rel.parent_level_id;

cursor c2(p_dim_id number) is
select
    relation.name,
    item.column_name,
    item.data_type,
    'FK',
    parent.name
from
    edw_levels_md_v lvl,
    edw_tables_md_v relation,
    edw_pvt_columns_md_v item,
    edw_foreign_keys_md_v fk,
    edw_pvt_key_columns_md_v isu,
    edw_unique_keys_md_v pk,
    edw_tables_md_v parent
where
    lvl.dim_id=p_dim_id
and relation.name=lvl.level_name||'_LTC'
and item.parent_object_id=relation.elementid
and fk.entity_id=relation.elementid
and isu.key_id=fk.foreign_key_id
and item.column_id=isu.column_id
and pk.key_id=fk.key_id
and parent.elementid=pk.entity_id
union all
select
    relation.name,
    item.column_name,
    item.data_type,
    'PK',
    null
from
    edw_levels_md_v lvl,
    edw_tables_md_v relation,
    edw_pvt_columns_md_v item,
    edw_unique_keys_md_v pk,
    edw_pvt_key_columns_md_v isu
where
    lvl.dim_id=p_dim_id
and relation.name=lvl.level_name||'_LTC'
and item.parent_object_id=relation.elementid
and pk.entity_id=relation.elementid
and isu.key_id=pk.key_id
and item.column_id=isu.column_id;

--all other cols
cursor c3(p_dim_id number,p_owner varchar2) is
select
    relation.name,
    item.column_name,
    item.length,
    item.data_type
from
    edw_tables_md_v relation,
    edw_pvt_columns_md_v item
where
     relation.name in (select level_name||'_LTC' from edw_levels_md_v where dim_id=p_dim_id)
and item.parent_object_id=relation.elementid
and item.column_name in ('NAME');

cursor c3_II(p_dim_id number,p_owner varchar2) is
select
    all_tab.table_name,
    all_tab.column_name,
    all_tab.data_length,
    all_tab.data_type
from
    all_tab_columns all_tab,
    all_tables tab
where
    all_tab.nullable in ('N')
and all_tab.table_name in (select level_name||'_LTC' from edw_levels_md_v where dim_id=p_dim_id)
and tab.table_name=all_tab.table_name
and tab.owner=p_owner
and all_tab.owner= p_owner

and all_tab.column_name not in ('NAME');

PROCEDURE PUSH (Errbuf out NOCOPY varchar2,
		retcode out NOCOPY varchar2) IS

Begin

retcode:='0';
g_debug:=null;
Init_all;
write_to_log_file_n('In PUSH for all Dimensions');
if g_status=false then
  errbuf:=g_status_message;
  retcode:='2';
  return;
end if;

write_to_log_file_n('START PUSH NAEDW for all dimensions, Start time '||get_time);

Read_Metadata;
if g_status=false then
  write_to_log_file_n('Error in Read Metadata '||g_status_message||get_time);
  errbuf:=g_status_message;
  retcode:='2';
  return;
end if;
write_to_log_file_n('Read Metadata done...'||get_time);
Execute_insert_stmt;
write_to_log_file_n('Executed all insert '||get_time);

--special case for edw_na

write_to_log_file_n('Executed all populate_edw_na..End of NAEDW push '||get_time);
if g_all_dims_ok=false or g_status=false then
  retcode:='1';
  errbuf:='Please check log file for problems.';
end if;
finish_all(true);

Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  errbuf:=g_status_message;
  retcode:='2';
  finish_all(false);
End;--PROCEDURE PUSH

/*
called from the conc manager for a specific dimension
*/
PROCEDURE PUSH(Errbuf out NOCOPY varchar2,
		retcode out NOCOPY varchar2,
        p_dim_string in varchar2) IS
Begin
retcode:='0';
g_debug:=null;
Init_all;
write_to_log_file_n('In PUSH with dim name passed');
if g_status=false then
  errbuf:=g_status_message;
  retcode:='2';
  return;
end if;
if g_debug then
  write_to_log_file_n('Debug flag turned ON');
else
  write_to_log_file_n('Debug flag turned OFF');
end if;
if g_debug then
  write_to_log_file_n('p_dim_string ='||p_dim_string);
end if;

if p_dim_string is null then
  write_to_log_file_n('NA_EDW for all dimensions'||get_time);
  PUSH(errbuf, retcode);
  return;
else
  write_to_log_file_n('NAEDW for specific dimension '||p_dim_string||get_time);
  g_dim_string_flag:=true;
  --Parse_dim_names(p_dim_string);--instead of read metadata
  if get_one_dim_name(p_dim_string,'LONGNAME') = false then
    errbuf:=g_status_message;
    retcode:='2';
    return;
  end if;
  Execute_insert_stmt;
  if g_all_dims_ok=false  or g_status=false then
    retcode:='2';
    errbuf:=g_status_message;
    finish_all(false);
    return;
  end if;
  finish_all(true);
end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  errbuf:=g_status_message;
  retcode:='2';
  finish_all(false);
End;--PROCEDURE PUSH with dim string

/*
called from collection engine for a specific dimension
*/
PROCEDURE PUSH(Errbuf out NOCOPY varchar2,
		retcode out NOCOPY varchar2,
        p_dim_string in varchar2,
        p_debug boolean) IS
Begin
  retcode:='0';
  g_debug:=p_debug;
  Init_all;
  g_coll_engine_call:=true;
  write_to_log_file_n('In PUSH with dim name passed');
  if g_status=false then
    errbuf:=g_status_message;
    retcode:='2';
    return;
  end if;
  if g_debug then
    write_to_log_file_n('Debug flag turned ON');
  else
    write_to_log_file_n('Debug flag turned OFF');
  end if;
  if g_debug then
    write_to_log_file_n('p_dim_string ='||p_dim_string);
  end if;
  if get_dim_pk(p_dim_string) =false then
    errbuf:=g_status_message;
    retcode:='2';
    return;
  end if;
  --if there is a row in the star table, no need to check the levels either
  if naedw_in_star(p_dim_string)=true then
    g_naedw_in :=true;
    write_to_log_file('NA_EDW row already in star table.');
  else
    g_naedw_in :=false;
    write_to_log_file('NA_EDW row not present in star table');
  end if;
  if err_in_star(p_dim_string)=true then
    g_err_in :=true;
    write_to_log_file('ERR row already in star table.');
  else
    g_err_in :=false;
    write_to_log_file('ERR row not present in star table');
  end if;
  if g_err_in=true and g_naedw_in=true then
    write_to_log_file_n('Both NAEDW and ERROR rows in the star table');
    return;
  end if;

  g_dim_string_flag:=true;
  --Parse_dim_names(p_dim_string);--instead of read metadata
  if get_one_dim_name(p_dim_string,'NAME') = false then
    errbuf:=g_status_message;
    retcode:='2';
    return;
  end if;
  Execute_insert_stmt;
  if g_all_dims_ok=false  or g_status=false then
    retcode:='2';
    errbuf:=g_status_message;
    finish_all(false);
    return;
  end if;
  finish_all(true);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  errbuf:=g_status_message;
  retcode:='2';
  finish_all(false);
End;


function get_status_message return varchar2 is
begin
 return g_status_message;
End;--function get_status_message return varchar2 is

PROCEDURE Read_Metadata IS

Begin
open c0;
g_number_dims:=1;
loop
  fetch c0 into g_dim_name(g_number_dims),
                g_dim_id(g_number_dims);
  exit when c0%NOTFOUND;
  g_number_dims:=g_number_dims+1;
end loop;
g_number_dims:=g_number_dims-1;

close c0;
--dbms_output.put_line('number of dime='||g_number_dims);

Exception when others then
  if c0%isopen then
    close c0;
  end if;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;--PROCEDURE Read_Metadata IS

function get_one_dim_name(p_dim_string varchar2,p_type varchar2) return boolean IS
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(1000);
begin
  if g_debug then
    write_to_log_file_n('In get_one_dim_name, dim ='||p_dim_string);
  end if;
  g_number_dims:=1;
  g_dim_name(g_number_dims):=null;
  g_dim_id(g_number_dims):=null;
  if p_type='LONGNAME' then
    l_stmt:='select dim_name,dim_id from edw_dimensions_md_v where dim_long_name=:s';
  else
    l_stmt:='select dim_name,dim_id from edw_dimensions_md_v where dim_name=:s';
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute ');
    write_to_log_file(l_stmt);
  end if;
  open cv for l_stmt using p_dim_string;
  fetch cv into g_dim_name(g_number_dims),g_dim_id(g_number_dims);
  close cv;
  write_to_log_file_n('Dimension='||g_dim_name(g_number_dims)||' and id='||g_dim_id(g_number_dims));
  if g_dim_id(g_number_dims) is null then
    return false;
  else
    return true;
  end if;
Exception when others then
  write_to_log_file_n('Error in get_one_dim_name '||sqlerrm||get_time);
  g_status_message:=sqlerrm;
  g_status:=false;
  return false;
End;--PROCEDURE parse_dim_names(p_dim_string varchar2) IS


PROCEDURE parse_dim_names(p_dim_string varchar2) IS
l_start number;
l_end number;
l_str varchar2(300);
l_len number;
l_dim_name EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_dim_id EDW_OWB_COLLECTION_UTIL.numberTableType;
l_dim_number number:=1;
Begin
l_start:=1;
l_end:=1;
l_len:=length(p_dim_string);
loop
  l_end:=instr(p_dim_string,':',l_start);
  if l_end = -1 then
   exit;
  end if;
  g_number_dims:=g_number_dims+1;
  g_dim_name(g_number_dims):=substr(p_dim_string,l_start,l_end-l_start);
  l_start:=l_end+1;
  if l_start >= l_len then
    exit;
  end if;
end loop;
--get the ids
open c0;
loop
  fetch c0 into
    l_dim_name(l_dim_number),
    l_dim_id(l_dim_number);
  exit when c0%notfound;
  l_dim_number:=l_dim_number+1;
end loop;
close c0;
l_dim_number:=l_dim_number-1;
for i in 1..g_number_dims loop
  for j in 1..l_dim_number loop
    if g_dim_name(i)=l_dim_name(j) then
      g_dim_id(i):=l_dim_id(j);
      exit;
    end if;
  end loop;
end loop;
Exception when others then
  if c0%isopen then
    close c0;
  end if;
  write_to_log_file_n('Error in parse dim names '||sqlerrm||get_time);
  g_status_message:=sqlerrm;
  g_status:=false;
End;--PROCEDURE parse_dim_names(p_dim_string varchar2) IS

PROCEDURE Parse_Metadata(p_dim_index number) IS

l_parent EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_child EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_parent_level varchar2(400);
l_number number:=1;
l_found boolean;
Begin
  g_all_level:=null;
  Begin
    g_number_levels:=1;
    open c00(g_dim_id(p_dim_index));
    loop
      fetch c00 into g_levels(g_number_levels);
      exit when c00%NOTFOUND;
      g_number_levels:=g_number_levels+1;
    end loop;
    close c00;
    g_number_levels:=g_number_levels-1;
  Exception when others then
  if c00%isopen then
    close c00;
  end if;
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    g_status:=false;
    return;
  end;

  Begin
   open c1(g_dim_id(p_dim_index));
   loop
    fetch c1 into
       l_child(l_number), l_parent(l_number);
    exit when c1%NOTFOUND;
    l_number:=l_number+1;
   end loop;
   l_number:=l_number-1;
   close c1;
  Exception when others then
  if c1%isopen then
    close c1;
  end if;
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    g_status:=false;
  end;

  --process the results here. first get the parent
  for i in 1..g_number_levels loop
    l_found:=false;
    for j in 1..l_number loop
      if g_levels(i)=l_child(j) then
        l_found:=true;
        exit;
      end if;
    end loop;
    if l_found=false then
      if  g_levels(i) = substr(g_dim_name(p_dim_index),1,instr(g_dim_name(p_dim_index),'_M',-1)-1)||'_A_LTC' then
        l_parent_level:=g_levels(i);
        g_level_status(i):='P';
        g_all_level:=g_levels(i);
      else
        g_level_status(i):='C';
      end if;
      exit;
    end if;
  end loop;

  --assign the child status
  for i in 1..g_number_levels loop
    for j in 1..l_number loop
      if l_child(j)=g_levels(i) then
        if l_parent(j)=l_parent_level then
          g_level_status(i):='CP';
        else
          g_level_status(i):='C';
        end if;
        exit;
      end if;
    end loop;
  end loop;

Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;--PROCEDURE Parse_Metadata IS

PROCEDURE Make_insert_stmt(p_level_index number) IS
Begin
  g_check_stmt:='select 1 from '||g_levels(p_level_index)||' where '||
  g_level_pk(g_varchar_pk_index)||' = '||''''||g_naedw_varchar2||''''||' or '||
  g_level_pk(g_varchar_pk_index)||' = '||''''||g_all_varchar2||'''';

  g_err_check_stmt:='select 1 from '||g_levels(p_level_index)||' where '||
  g_level_pk(g_varchar_pk_index)||' = '||''''||g_err_varchar2||'''';

  g_insert_stmt:='insert into '||g_levels(p_level_index)||' ( ';
  make_body_insert_update_stmt(p_level_index,true);
  if g_status=false then
   return;
  end if;
  g_insert_stmt:=g_insert_stmt||g_body_insert_update_stmt;
  g_err_insert_stmt:='insert into '||g_levels(p_level_index)||' ( ';
  make_err_body_insert_stmt(p_level_index,true);
  if g_status=false then
   return;
  end if;
  g_err_insert_stmt:=g_err_insert_stmt||g_err_body_insert_update_stmt;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in make_insert_stmt for level '||g_levels(p_level_index)||' '||
    g_status_message||get_time);
  g_status:=false;
End;--PROCEDURE Make_insert_stmt IS

PROCEDURE Make_Update_Stmt(p_level_index number) IS
first_find boolean :=true;
l_pk_stmt varchar2(4000);
l_fk_stmt varchar2(4000);
Begin
  g_update_stmt:='update  '||g_levels(p_level_index)||' set ( ';
  make_body_insert_update_stmt(p_level_index,false);
  if g_status=false then
   return;
  end if;
  g_update_stmt:=g_update_stmt||g_body_insert_update_stmt;
  g_err_update_stmt:='update  '||g_levels(p_level_index)||' set ( ';
  make_err_body_insert_stmt(p_level_index,false);
  if g_status=false then
   return;
  end if;
  g_err_update_stmt:=g_err_update_stmt||g_err_body_insert_update_stmt;
Exception when others then
g_status_message:=sqlerrm;
write_to_log_file_n('Error in make_update_stmt for level '||g_levels(p_level_index)||' '||
    g_status_message||get_time);
g_status:=false;
End;--PROCEDURE Make_Update_Stmt(p_level_index number) IS

PROCEDURE make_body_insert_update_stmt(p_level_index number, p_insert_flag boolean) IS
first_find boolean:=true;
l_pk_stmt varchar2(4000);
l_fk_stmt varchar2(4000);
l_pk_num number;--which is the number pk
Begin
  l_pk_num:=1;
  g_body_insert_update_stmt:='';
  for i in 1..g_level_pk_number loop
    if first_find then
      g_body_insert_update_stmt:=g_body_insert_update_stmt||' '||g_level_pk(i);
      first_find:=false;
    else
      g_body_insert_update_stmt:=g_body_insert_update_stmt||','||g_level_pk(i);
    end if;
  end loop;

  for i in 1..g_level_fk_number loop
    g_body_insert_update_stmt:=g_body_insert_update_stmt||','||g_level_fk(i);
  end loop;

  for i in 1..g_level_col_number loop
    if g_level_cols_datatype(i) = 'VARCHAR2' then
      if g_level_status(p_level_index)='P' then
        if g_level_cols_length(i) > g_all_varchar2_mesg_length then
          g_body_insert_update_stmt:=g_body_insert_update_stmt||','||g_level_cols(i);
        end if;
      else
        if g_level_cols_length(i) > g_unassigned_length then
          g_body_insert_update_stmt:=g_body_insert_update_stmt||','||g_level_cols(i);
        end if;
      end if;
    else
      if g_level_cols(i) <> 'CREATION_DATE' and g_level_cols(i) <> 'LAST_UPDATE_DATE' then
        g_body_insert_update_stmt:=g_body_insert_update_stmt||','||g_level_cols(i);
      end if;
    end if;
  end loop;
  if p_insert_flag then
    --if g_level_status(p_level_index)<>'P' then
      g_body_insert_update_stmt:=g_body_insert_update_stmt||',CREATION_DATE, LAST_UPDATE_DATE)';
    --else
      --g_body_insert_update_stmt:=g_body_insert_update_stmt||')';
    --end if;
    g_body_insert_update_stmt:=g_body_insert_update_stmt||' values (';
  else
    --if g_level_status(p_level_index)<>'P' then
      g_body_insert_update_stmt:=g_body_insert_update_stmt||',LAST_UPDATE_DATE)';
    --else
      --g_body_insert_update_stmt:=g_body_insert_update_stmt||')';
    --end if;
    g_body_insert_update_stmt:=g_body_insert_update_stmt||'= (select ';
  end if;
  first_find:=true;

  for i in 1..g_level_pk_number loop
    if g_level_pk_datatype(i)='VARCHAR2' then
      if g_level_status(p_level_index)='P' then
        l_pk_stmt:=''''||g_all_varchar2||'''';
      else
        l_pk_stmt:=''''||g_naedw_varchar2||'''';
      end if;
    elsif g_level_pk_datatype(i)='NUMBER' then
      l_pk_num:=i;
      if g_level_status(p_level_index)='P' then
        l_pk_stmt:=g_all_number;
      else
        l_pk_stmt:=g_naedw_number;
      end if;
    elsif g_level_pk_datatype(i)='DATE' then
      l_pk_stmt:=g_naedw_date;
    else
      l_pk_stmt:=''''||g_naedw_varchar2||'''';
    end if;
    if first_find then
      g_body_insert_update_stmt:=g_body_insert_update_stmt||' '||l_pk_stmt;
      first_find:=false;
    else
      g_body_insert_update_stmt:=g_body_insert_update_stmt||','||l_pk_stmt;
    end if;
  end loop;
  for i in 1..g_level_fk_number loop
    --if g_level_status(p_level_index)='P' OR g_level_status(p_level_index)='CP' then
    if g_level_fk_parent(i)=g_all_level then
      if g_level_fk_datatype(i)='VARCHAR2' then
        l_fk_stmt:=''''||g_all_varchar2||'''';
      elsif g_level_fk_datatype(i)='DATE' then
        l_fk_stmt:=''''||g_all_date||'''';
      elsif g_level_fk_datatype(i)='NUMBER' then
        l_fk_stmt:=g_all_number;
      else
        l_fk_stmt:=''''||g_all_varchar2||'''';
      end if;
    else
      if g_level_fk_datatype(i)='VARCHAR2' then
        l_fk_stmt:=''''||g_naedw_varchar2||'''';
      elsif g_level_fk_datatype(i)='DATE' then
        l_fk_stmt:=''''||g_naedw_date||'''';
      elsif g_level_fk_datatype(i)='NUMBER' then
        l_fk_stmt:=g_naedw_number;
      else
        l_fk_stmt:=''''||g_naedw_varchar2||'''';
      end if;
    end if;
    g_body_insert_update_stmt:=g_body_insert_update_stmt||','||l_fk_stmt;
  end loop;

  for i in 1..g_level_col_number loop
    if g_level_cols_datatype(i) = 'VARCHAR2' then
      if g_level_status(p_level_index)='P' then
        if g_level_cols_length(i) > g_all_varchar2_mesg_length then
          g_body_insert_update_stmt:=g_body_insert_update_stmt||','||''''||g_all_varchar2_mesg||'''';
        end if;
      else
        if g_level_cols_length(i) > g_unassigned_length then
          g_body_insert_update_stmt:=g_body_insert_update_stmt||','||''''||g_unassigned||'''';
        end if;
      end if;
    elsif g_level_cols_datatype(i) = 'DATE' then
      if g_level_cols(i) <> 'CREATION_DATE' and g_level_cols(i) <> 'LAST_UPDATE_DATE' then
        g_body_insert_update_stmt:=g_body_insert_update_stmt||','||'null';
      end if;
    elsif g_level_cols_datatype(i) = 'NUMBER' then
      g_body_insert_update_stmt:=g_body_insert_update_stmt||','||g_naedw_number;
    end if;
  end loop;
  if p_insert_flag then
    --if g_level_status(p_level_index)<>'P' then
      g_body_insert_update_stmt:=g_body_insert_update_stmt||',SYSDATE,SYSDATE)';
    --else
      --g_body_insert_update_stmt:=g_body_insert_update_stmt||')';
    --end if;
  else
    --if g_level_status(p_level_index)<>'P' then
      g_body_insert_update_stmt:=g_body_insert_update_stmt||',SYSDATE ';
    --end if;
    g_body_insert_update_stmt:=g_body_insert_update_stmt||' from dual) where '||
       g_level_pk(l_pk_num)||'=';
    if g_level_status(p_level_index)='P' then
       g_body_insert_update_stmt:=g_body_insert_update_stmt||g_all_number||' ';
    else
       g_body_insert_update_stmt:=g_body_insert_update_stmt||g_naedw_number||' ';
    end if;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in make_body_insert_update_stmt for level '||g_levels(p_level_index)||' '||
    g_status_message||get_time);
  g_status:=false;
End;--make_body_insert_update_stmt(p_level_index number) IS

PROCEDURE make_err_body_insert_stmt(p_level_index number, p_insert_flag boolean) IS
first_find boolean:=true;
l_pk_stmt varchar2(4000);
l_fk_stmt varchar2(4000);
l_pk_num number;--which is the number pk
Begin
  l_pk_num:=1;
  g_err_body_insert_update_stmt:='';
  for i in 1..g_level_pk_number loop
    if first_find then
      g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||' '||g_level_pk(i);
      first_find:=false;
    else
      g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||','||g_level_pk(i);
    end if;
  end loop;

  for i in 1..g_level_fk_number loop
    g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||','||g_level_fk(i);
  end loop;

  for i in 1..g_level_col_number loop
    if g_level_cols_datatype(i) = 'VARCHAR2' then
      if g_level_status(p_level_index)='P' then
        if g_level_cols_length(i) > g_all_varchar2_mesg_length then
          g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||','||g_level_cols(i);
        end if;
      else
        if g_level_cols_length(i) > g_invalid_length then
          g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||','||g_level_cols(i);
        end if;
      end if;
    else
      if g_level_cols(i) <> 'CREATION_DATE' and g_level_cols(i) <> 'LAST_UPDATE_DATE' then
        g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||','||g_level_cols(i);
      end if;
    end if;
  end loop;
  if p_insert_flag then
    --if g_level_status(p_level_index)<>'P' then
      g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||',CREATION_DATE, LAST_UPDATE_DATE)';
    --else
      --g_body_insert_update_stmt:=g_body_insert_update_stmt||')';
    --end if;
    g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||' values (';
  else
    --if g_level_status(p_level_index)<>'P' then
      g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||',LAST_UPDATE_DATE)';
    --else
      --g_body_insert_update_stmt:=g_body_insert_update_stmt||')';
    --end if;
    g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||'= (select ';
  end if;
  first_find:=true;

  for i in 1..g_level_pk_number loop
    if g_level_pk_datatype(i)='VARCHAR2' then
      if g_level_status(p_level_index)='P' then
        l_pk_stmt:=''''||g_all_varchar2||'''';
      else
        l_pk_stmt:=''''||g_err_varchar2||'''';
      end if;
    elsif g_level_pk_datatype(i)='NUMBER' then
      l_pk_num:=i;
      if g_level_status(p_level_index)='P' then
        l_pk_stmt:=g_all_number;
      else
        l_pk_stmt:=g_err_number;
      end if;
    elsif g_level_pk_datatype(i)='DATE' then
      l_pk_stmt:=g_naedw_date;
    else
      l_pk_stmt:=''''||g_err_varchar2||'''';
    end if;
    if first_find then
      g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||' '||l_pk_stmt;
      first_find:=false;
    else
      g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||','||l_pk_stmt;
    end if;
  end loop;
  for i in 1..g_level_fk_number loop
    --if g_level_status(p_level_index)='P' OR g_level_status(p_level_index)='CP' then
    if g_level_fk_parent(i)=g_all_level then
      if g_level_fk_datatype(i)='VARCHAR2' then
        l_fk_stmt:=''''||g_all_varchar2||'''';
      elsif g_level_fk_datatype(i)='DATE' then
        l_fk_stmt:=''''||g_all_date||'''';
      elsif g_level_fk_datatype(i)='NUMBER' then
        l_fk_stmt:=g_all_number;
      else
        l_fk_stmt:=''''||g_all_varchar2||'''';
      end if;
    else
      if g_level_fk_datatype(i)='VARCHAR2' then
        l_fk_stmt:=''''||g_err_varchar2||'''';
      elsif g_level_fk_datatype(i)='DATE' then
        l_fk_stmt:=''''||g_naedw_date||'''';
      elsif g_level_fk_datatype(i)='NUMBER' then
        l_fk_stmt:=g_err_number;
      else
        l_fk_stmt:=''''||g_err_varchar2||'''';
      end if;
    end if;
    g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||','||l_fk_stmt;
  end loop;

  for i in 1..g_level_col_number loop
    if g_level_cols_datatype(i) = 'VARCHAR2' then
      if g_level_status(p_level_index)='P' then
        if g_level_cols_length(i) > g_all_varchar2_mesg_length then
          g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||','||''''||g_all_varchar2_mesg||'''';
        end if;
      else
        if g_level_cols_length(i) > g_invalid_length then
          g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||','||''''||g_invalid||'''';
        end if;
      end if;
    elsif g_level_cols_datatype(i) = 'DATE' then
      if g_level_cols(i) <> 'CREATION_DATE' and g_level_cols(i) <> 'LAST_UPDATE_DATE' then
        g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||','||'null';
      end if;
    elsif g_level_cols_datatype(i) = 'NUMBER' then
      g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||','||g_err_number;
    end if;
  end loop;
  if p_insert_flag then
    --if g_level_status(p_level_index)<>'P' then
      g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||',SYSDATE,SYSDATE)';
    --else
      --g_body_insert_update_stmt:=g_body_insert_update_stmt||')';
    --end if;
  else
    --if g_level_status(p_level_index)<>'P' then
      g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||',SYSDATE ';
    --end if;
    g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||' from dual) where '||
       g_level_pk(l_pk_num)||'=';
    if g_level_status(p_level_index)='P' then
       g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||g_all_number||' ';
    else
       g_err_body_insert_update_stmt:=g_err_body_insert_update_stmt||g_err_number||' ';
    end if;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in make_err_body_insert_update_stmt for level '||g_levels(p_level_index)||' '||
    g_status_message||get_time);
  g_status:=false;
End;

PROCEDURE Execute_insert_stmt_level(p_level_index number) IS
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
v_int number:=null;
l_insert boolean:=true;
l_stmt varchar2(10000);
Begin
  if g_exec_flag= false then
    return;
  end if;
  Begin
    if g_debug then
      write_to_log_file_n('Going to execute ');
      write_to_log_file(g_check_stmt);
    end if;
    open cv for g_check_stmt;
    fetch cv into v_int;
    close cv;
    if v_int is null then
      l_insert:=true;
      write_to_log_file_n('Need to insert NAEDW or ALL for '||g_levels(p_level_index));
    else
      l_insert:=false;
      write_to_log_file_n('NAEDW or ALL already present for '||g_levels(p_level_index));
      return ;
    end if;
  Exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message||get_time);
    write_to_log_file('Problem statement '||g_check_stmt);
    g_status:=false;
    return;
  end;
  if l_insert then
   l_stmt:=g_insert_stmt;
  else
   if g_coll_engine_call=false then
     l_stmt:=g_update_stmt;
   else
     return ;
   end if;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute ');
    write_to_log_file(l_stmt);
  end if;
  Begin
    execute immediate l_stmt;
    write_to_log_file_n('Processed '||sql%rowcount||' rows');
  Exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message||get_time);
    write_to_log_file('Problem stmt '||l_stmt);
    g_status:=false;
  end;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message||get_time);
  g_status:=false;
End;--PROCEDURE Execute_insert_stmt_level(p_level_index number) IS

PROCEDURE Execute_err_insert_stmt_level(p_level_index number) IS
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
v_int number:=null;
l_insert boolean:=true;
l_stmt varchar2(10000);
Begin
  if g_exec_flag= false then
    return;
  end if;
  Begin
    if g_debug then
      write_to_log_file_n('Going to execute ');
      write_to_log_file(g_err_check_stmt);
    end if;
    open cv for g_err_check_stmt;
    fetch cv into v_int;
    close cv;
    if v_int is null then
      l_insert:=true;
      write_to_log_file_n('Need to insert ERR  for '||g_levels(p_level_index));
    else
      l_insert:=false;
      write_to_log_file_n('ERR already present for '||g_levels(p_level_index));
      return ;
    end if;
  Exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message||get_time);
    write_to_log_file('Problem statement '||g_err_check_stmt);
    g_status:=false;
    return;
  end;
  if l_insert then
   l_stmt:=g_err_insert_stmt;
  else
    if g_coll_engine_call=false then
      l_stmt:=g_err_update_stmt;
    else
      return;
    end if;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute ');
    write_to_log_file(l_stmt);
  end if;
  Begin
    execute immediate l_stmt;
    write_to_log_file_n('Processed '||sql%rowcount||' rows');
  Exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message||get_time);
    write_to_log_file('Problem stmt '||l_stmt);
    g_status:=false;
  end;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message||get_time);
  g_status:=false;
End;

PROCEDURE Get_all_cols(p_index number) IS
l_relation_key EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_item_key EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_data_key EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_type_key EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_key number:=1;
l_relation EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_item EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_item_length EDW_OWB_COLLECTION_UTIL.numberTableType;
l_data EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_type EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_parent EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number number:=1;
l_found boolean;
l_owner varchar2(400);
Begin

 Begin
  open c2(g_dim_id(p_index));
  loop
   fetch c2 into
	l_relation_key(l_number_key),
	l_item_key(l_number_key),
	l_data_key(l_number_key),
	l_type_key(l_number_key),
    l_parent(l_number_key);
    exit when c2%notfound;
    l_number_key:=l_number_key+1;
   end loop;
   l_number_key:=l_number_key-1;
   close c2;
 exception when others then
  if c2%isopen then
    close c2;
  end if;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in cursor c2 Get_all_cols for '||g_dim_name(p_index)||' '||
    g_status_message||get_time);
  g_status:=false;
  return;
 end;
 Begin
  --get the table owner
  l_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(g_dim_name(p_index));
  if g_debug then
    write_to_log_file_n('The owner for '||g_dim_name(p_index)||' is '||l_owner);
  end if;
  if l_owner is null then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    g_status:=false;
    return;
  end if;
  open c3(g_dim_id(p_index),l_owner);
  loop
   fetch c3 into
    l_relation(l_number),
    l_item(l_number),
    l_item_length(l_number),
    l_data(l_number);
    exit when c3%notfound;
    l_number:=l_number+1;
   end loop;
   --l_number:=l_number-1;
   close c3;
 exception when others then
  if c3%isopen then
    close c3;
  end if;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in cursor c3 Get_all_cols for '||g_dim_name(p_index)||' '||
    g_status_message||get_time);
  g_status:=false;
 end;
 begin
   open c3_II(g_dim_id(p_index),l_owner);
   loop
   fetch c3_II into
    l_relation(l_number),
    l_item(l_number),
    l_item_length(l_number),
    l_data(l_number);
    exit when c3_II%notfound;
    l_number:=l_number+1;
   end loop;
   l_number:=l_number-1;
   close c3_II;
 exception when others then
   g_status_message:=sqlerrm;
   write_to_log_file_n('Error in cursor c3_II Get_all_cols for '||g_dim_name(p_index)||' '||
   g_status_message||get_time);
   g_status:=false;
 end ;
 --assign the pk and fk to the levels
 --for each level, we also make the dml stmt
 for i in 1..g_number_levels loop
   g_level_fk_number:=0;
   g_level_pk_number:=0;
   g_level_col_number:=0;
   g_varchar_pk_index:=0;
   for j in 1..l_number_key loop
     if l_relation_key(j)=g_levels(i) then
       if l_type_key(j)='PK' then
         g_level_pk_number:=g_level_pk_number+1;
         g_level_pk(g_level_pk_number):=l_item_key(j);
         g_level_pk_datatype(g_level_pk_number):=l_data_key(j);
         if l_data_key(j) = 'VARCHAR2' then
           g_varchar_pk_index:=g_level_pk_number;
         end if;
       elsif l_type_key(j)='FK' then
         g_level_fk_number:=g_level_fk_number+1;
         g_level_fk(g_level_fk_number):=l_item_key(j);
         g_level_fk_datatype(g_level_fk_number):=l_data_key(j);
         g_level_fk_parent(g_level_fk_number):=l_parent(j);
       end if;
     end if;
   end loop;
   if g_debug then
     write_to_log_file_n('Level '||g_levels(i)||' , the unique keys and data type ');
     for j in 1..g_level_pk_number loop
       write_to_log_file(g_level_pk(j)||'     '||g_level_pk_datatype(j));
     end loop;
     write_to_log_file_n('Level '||g_levels(i)||' , the foreign keys and data type ');
     for j in 1..g_level_fk_number loop
       write_to_log_file(g_level_fk(j)||'     '||g_level_fk_datatype(j)||' '||g_level_fk_parent(j));
     end loop;
   end if;
   for j in 1..l_number loop
     if l_relation(j)=g_levels(i) then
       l_found:=false;
       for k in 1..g_level_pk_number loop
         if g_level_pk(k)=l_item(j) then
           l_found:=true;
 	       exit;
         end if;
       end loop;
       if l_found=false then
         for k in 1..g_level_fk_number loop
           if g_level_fk(k)=l_item(j) then
             l_found:=true;
 	         exit;
           end if;
         end loop;
         if l_found=false then
           g_level_col_number:=g_level_col_number+1;
           g_level_cols(g_level_col_number):=l_item(j);
           g_level_cols_length(g_level_col_number):=l_item_length(j);
           g_level_cols_datatype(g_level_col_number):=l_data(j);
         end if;
       end if;
     end if;
   end loop;
   if g_debug then
     write_to_log_file_n('Level '||g_levels(i)||', the columns and datatype and length ');
     for j in 1..g_level_col_number loop
       write_to_log_file(g_level_cols(j)||'       '||
        g_level_cols_datatype(j)||'    '||g_level_cols_length(j));
     end loop;
   end if;
   --make the stmt
   Make_insert_stmt(i);      --pass the level index
   --EDW_OWB_COLLECTION_UTIL.print_stmt(g_insert_stmt);
   if g_status = false then
     return;
   end if;
   --we dont need to make update anymore. no updates at all..if the row is there, just skip the level
   if g_coll_engine_call=false then
     Make_update_stmt(i);      --pass the level index
     if g_status = false then
       return;
     end if;
   end if;
   Execute_insert_stmt_level(i);
   if g_status = false then
     return;
   end if;
   if g_level_status(i) <> 'P' then --no need for all level
     Execute_err_insert_stmt_level(i);
     if g_status = false then
       return;
     end if;
   end if;
 end loop;
 Exception when others then
   g_status_message:=sqlerrm;
   write_to_log_file_n('Error in Get_all_cols for '||g_dim_name(p_index)||' '||
    g_status_message||get_time);
   g_status:=false;
End;--PROCEDURE Get_all_cols(p_index number)

PROCEDURE Execute_insert_stmt IS
Begin

for i in 1..g_number_dims loop
  g_status:=true;
  Parse_Metadata(i);
  if g_status then
    Get_all_cols(i);
  else
    g_all_dims_ok:=false;
    write_to_log_file_n('Error in Dimension '||g_dim_name(i)||' '||
        g_status_message||get_time);
  end if;
  if g_status=true then
    write_to_log_file_n('Finished Dimension '||g_dim_name(i)||get_time);
  else
    write_to_log_file_n('Error in Dimension '||g_dim_name(i)||' '||
        g_status_message||get_time);
    g_all_dims_ok:=false;
  end if;
end loop;

End;--PROCEDURE Execute_insert_stmt IS

PROCEDURE Init_All IS
Begin
g_conc_program_name:='EDW_NAEDW_PUSH';
EDW_OWB_COLLECTION_UTIL.init_all(g_conc_program_name,null,'bis.edw.loader');
write_to_log_file_n('Finished setting up the log file');
if g_debug is null then
  if fnd_profile.value('EDW_DEBUG')='Y' then
    g_debug:=true;--look at the profile value for this
  else
    g_debug:=false;
  end if;
end if;
g_coll_engine_call:=false;
g_status:=true;
g_status_message:=' ';
g_exec_flag:=true;
g_all_dims_ok:=true;
g_number_dims:=0;
g_dim_string_flag:=false;--user specifies the list of dims
g_level_fk_number:=0;
g_level_col_number:=0;
FND_MESSAGE.SET_NAME('BIS','EDW_UNASSIGNED');
g_unassigned:=FND_MESSAGE.GET;
g_unassigned:=replace(g_unassigned,'''','''''');
FND_MESSAGE.SET_NAME('BIS','EDW_INVALID');
g_invalid:=FND_MESSAGE.GET;
g_invalid:=replace(g_invalid,'''','''''');
if g_debug then
  write_to_log_file_n('Unassigned is '||g_unassigned);
  write_to_log_file_n('Invalid Record is '||g_invalid);
end if;
g_unassigned_length:=length(g_invalid);
g_invalid_length:=length(g_unassigned);
write_to_log_file_n('Finished assigning g_unassigned');
g_naedw_varchar2:='NA_EDW';
g_err_varchar2:='NA_ERR';
g_naedw_date:='to_date(''01/01/1000'',''MM/DD/YYYY'')';
g_naedw_number:='0';
g_err_number:='-1';
g_all_varchar2:='ALL';
FND_MESSAGE.SET_NAME('BIS','EDW_ALL');
g_all_varchar2_mesg:=FND_MESSAGE.GET;
g_all_varchar2_mesg:=replace(g_all_varchar2_mesg,'''','''''');
g_all_varchar2_mesg_length:=length(g_all_varchar2_mesg);
if g_debug then
  write_to_log_file_n('All is '||g_all_varchar2_mesg);
end if;
write_to_log_file_n('Finished assigning g_all');
g_all_number:='1';
g_all_date:='to_date(''01/01/1000'',''MM/DD/YYYY'')';
g_conc_program_id:=FND_GLOBAL.Conc_request_id;--my conc id
write_to_log_file_n('Concurrent request ID '||g_conc_program_id);
Exception when others then
 write_to_log_file_n('Error in Init '||sqlerrm||get_time);
 g_status_message:=sqlerrm;
 g_status:=false;
End;--PROCEDURE Init_All;

procedure finish_all(p_flag boolean) is
begin
  if p_flag=true then
    EDW_OWB_COLLECTION_UTIL.commit_conc_program_log;--this issues a commit
  else
    rollback;
    EDW_OWB_COLLECTION_UTIL.commit_conc_program_log;
  end if;
End;--procedure finish_all(p_flag boolean) is


function get_time return varchar2 is
begin
  return ' '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS');
Exception when others then
  write_to_log_file_n('Error in get_time '||sqlerrm);

End;

procedure write_to_log_file(p_message varchar2) is
begin
 EDW_OWB_COLLECTION_UTIL.write_to_log_file(p_message);
Exception when others then
 null;
End;

procedure write_to_log_file_n(p_message varchar2) is
begin
 write_to_log_file('   ');
 write_to_log_file(p_message);
Exception when others then
 null;
End;

function get_dim_pk(p_dim varchar2) return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_stmt:='select pk_item.column_name from edw_dimensions_md_v rel , edw_unique_keys_md_v pk, '||
  'edw_pvt_key_columns_md_v isu,edw_pvt_columns_md_v pk_item where rel.dim_name=:a '||
  'and pk.entity_id=rel.dim_id and pk.primarykey=1  '||
  'and isu.key_id=pk.key_id and pk_item.column_id=isu.column_id ';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  open cv for l_stmt using p_dim;
  fetch cv into g_dim_pk;
  close cv;
  if g_debug then
    write_to_log_file_n('Dim pk is '||g_dim_pk);
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function naedw_in_star(p_dim varchar2) return boolean is
Begin
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(p_dim,g_dim_pk||'=0')=2 then
    return true;
  else
    return false;
  end if;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function err_in_star(p_dim varchar2) return boolean is
Begin
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(p_dim,g_dim_pk||'=-1')=2 then
    return true;
  else
    return false;
  end if;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;


END EDW_NAEDW_PUSH;

/
