--------------------------------------------------------
--  DDL for Package Body EDW_DUPLICATE_CLEAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_DUPLICATE_CLEAN" AS
/*$Header: EDWDCLNB.pls 115.10 2003/11/18 07:00:40 smulye noship $*/

procedure clean_up_object(Errbuf out NOCOPY varchar2,Retcode out NOCOPY varchar2,p_object_name in varchar2) is
l_object_name varchar2(400);
Begin
  Errbuf:=null;
  Retcode:='0';
  l_object_name:=get_short_name_for_long(p_object_name);
  EDW_OWB_COLLECTION_UTIL.init_all(l_object_name,null,'bis.edw.duplicate_clean');
  init_all;
  if is_dimension(l_object_name) then
    if clean_dimension_duplicates(l_object_name)=false then
      errbuf:=g_status_message;
      retcode:='2';
      return;
    end if;
  else
    if clean_fact_duplicates(l_object_name)=false then
      errbuf:=g_status_message;
      retcode:='2';
      return;
    end if;
  end if;
Exception when others then
  g_status_message:='Error in clean_dimension_duplicates '||sqlerrm;
  g_status:=false;
End;


function clean_dimension_duplicates(p_dim_name varchar2) return boolean is
Begin
  g_dim_name:=p_dim_name;
  if clean_dimension_duplicates = false then
    rollback;
    return false;
  end if;
  write_to_log_file_n('Done');
  return true;
Exception when others then
  g_status_message:='Error in clean_dimension_duplicates '||sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
end;

function clean_fact_duplicates(p_fact_name varchar2) return boolean is
Begin
  g_fact_name:=p_fact_name;
  if clean_fact_duplicates = false then
    rollback;
    return false;
  end if;
  write_to_log_file_n('Done');
  return true;
Exception when others then
  g_status_message:='Error in clean_fact_duplicates '||sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
end;


function clean_dimension_duplicates return boolean is
Begin
  write_to_log_file_n('clean_dimension_duplicates');
  if get_dimension_pks=false then
    return false;
  end if;
  if get_ltc_tables=false then
    return false;
  end if;
  if get_ltc_pks=false then
    return false;
  end if;
  if delete_dim_duplicates=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:='Error in clean_dimension_duplicates function '||sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
end;

function clean_fact_duplicates return boolean is
Begin
  write_to_log_file_n('clean_fact_duplicates');
  if get_fact_pks=false then
    return false;
  end if;
  if delete_fact_duplicates=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:='Error in clean_fact_duplicates function '||sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
end;

function get_dimension_pks return boolean is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  write_to_log_file_n('get_dimension_pks');
  l_stmt:='select pk_item.column_name, substr(pk_item.column_name,1,instr(upper(pk_item.column_name),''_KEY'')-1) '||
  'from edw_dimensions_md_v rel ,  '||
  'edw_unique_keys_md_v pk,  '||
  'edw_pvt_key_columns_md_v isu,  '||
  'edw_pvt_columns_md_v pk_item  '||
  'where  '||
  'rel.dim_name=:a '||
  'and pk.entity_id=rel.dim_id '||
  'and pk.primarykey=1  '||
  'and isu.key_id=pk.key_id '||
  'and pk_item.column_id=isu.column_id';
  write_to_log_file_n(l_stmt);
  open cv for l_stmt using g_dim_name;
  fetch cv into g_dim_pk_key,g_dim_pk;
  close cv;
  write_to_log_file_n(g_dim_pk_key||'  '||g_dim_pk);
  return true;
Exception when others then
  g_status_message:='Error in get_dimension_pks function '||sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
end;

function get_fact_pks return boolean is
Begin
  write_to_log_file_n('get_fact_pks');
  if get_table_pks(g_fact_name,g_fact_pk,g_fact_pk_key,'FACT')=false then
    return false;
  end if;
  write_to_log_file_n('Fact PKs '||g_fact_pk||','||g_fact_pk_key);
  return true;
Exception when others then
  g_status_message:='Error in get_fact_pks function '||sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
end;



function get_ltc_tables return boolean is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  write_to_log_file_n('get_ltc_tables');
  l_stmt:=' select ltc.name '||
  'from '||
  'edw_tables_md_v ltc, '||
  'edw_dimensions_md_v dim, '||
  'edw_levels_md_v lvl '||
  'where dim.dim_name=:a '||
  'and lvl.dim_id=dim.dim_id '||
  'and ltc.name=lvl.level_name||''_LTC''';
  write_to_log_file_n(l_stmt);
  g_number_ltc:=1;
  open cv for l_stmt using g_dim_name;
  loop
    fetch cv into g_ltc_tables(g_number_ltc);
    exit when cv%notfound;
    g_number_ltc:=g_number_ltc+1;
  end loop;
  g_number_ltc:=g_number_ltc-1;
  for i in 1..g_number_ltc loop
    write_to_log_file(g_ltc_tables(i));
  end loop;
  return true;
Exception when others then
  g_status_message:='Error in get_ltc_tables function '||sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
end;

function get_ltc_pks  return boolean is
Begin
  write_to_log_file_n('get_ltc_pks');
  for i in 1..g_number_ltc loop
    write_to_log_file_n('Getting PKS for '||g_ltc_tables(i));
    if get_table_pks(g_ltc_tables(i),g_ltc_pk(i),g_ltc_pk_key(i),null)=false then
      return false;
    end if;
  end loop;
  write_to_log_file_n('ltc tables and pks');
  for i in 1..g_number_ltc loop
    write_to_log_file(g_ltc_tables(i)||'  '||g_ltc_pk(i)||'  '||g_ltc_pk_key(i));
  end loop;
  return true;
Exception when others then
  g_status_message:='Error in get_ltc_pks function '||sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
end;


function get_table_pks(p_table varchar2,p_pk out NOCOPY varchar2,p_pk_key out NOCOPY varchar2,
p_option varchar2) return boolean is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_col EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_data_type EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_keys number;
Begin
  if p_option='FACT' then
    --due to OWB issue where by the list of all fk is coming out NOCOPY as a UK
    l_stmt:='select pk_item.column_name, pk_item.data_type '||
    'from edw_relations_md_v rel ,  '||
    'edw_unique_keys_md_v pk,  '||
    'edw_pvt_key_columns_md_v isu,  '||
    'edw_pvt_columns_md_v pk_item '||
    'where  '||
    'rel.relation_name=:a  '||
    'and pk.entity_id=rel.relation_id '||
    'and isu.key_id=pk.key_id '||
    'and pk_item.column_id=isu.column_id '||
    'and pk_item.column_name like ''%_PK''';
  else
    l_stmt:='select pk_item.column_name, pk_item.data_type '||
    'from edw_relations_md_v rel ,  '||
    'edw_unique_keys_md_v pk,  '||
    'edw_pvt_key_columns_md_v isu,  '||
    'edw_pvt_columns_md_v pk_item '||
    'where  '||
    'rel.relation_name=:a  '||
    'and pk.entity_id=rel.relation_id '||
    'and isu.key_id=pk.key_id '||
    'and pk_item.column_id=isu.column_id ';
  end if;
  write_to_log_file_n(l_stmt||' using '||p_table);
  l_number_keys:=1;
  open cv for l_stmt using p_table;
  loop
    fetch cv into l_col(l_number_keys),l_data_type(l_number_keys);
    exit when cv%notfound;
    l_number_keys:=l_number_keys+1;
  end loop;
  l_number_keys:=l_number_keys-1;
  close cv;
  for i in 1..l_number_keys loop
    if l_data_type(i)='VARCHAR2' then
      p_pk:=l_col(i);
      p_pk_key:=p_pk||'_KEY';
      exit;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:='Error in get_table_pks function '||sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
end;

function delete_dim_duplicates return boolean is
Begin
  write_to_log_file_n('delete_dim_duplicates');
  /*
  back up the dimension duplicate keys and then if facts have those keys, replace them.
  */
  if delete_dim_duplicate_data(g_dim_name,g_dim_pk,g_dim_pk_key)=false then
    return false;
  end if;
  for i in 1..g_number_ltc loop
    if delete_table_duplicates(g_ltc_tables(i),g_ltc_pk(i),g_ltc_pk_key(i))=false then
      return false;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:='Error in delete_dim_duplicates function '||sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
end;

function delete_fact_duplicates return boolean is
Begin
  write_to_log_file_n('delete_fact_duplicates');
  if delete_table_duplicates(g_fact_name,g_fact_pk,g_fact_pk_key)=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:='Error in delete_fact_duplicates function '||sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
end;

function delete_table_duplicates(p_table varchar2,p_pk varchar2,p_pk_key varchar2) return boolean is
l_stmt varchar2(8000);
l_dup_value_table varchar2(400);
l_dup_table varchar2(400);
l_dup_max_table varchar2(400);
l_dup_max_rowid_table varchar2(400);
l_dup_rowid_table varchar2(400);
l_ok_table  varchar2(400);
l_name varchar2(400);
l_count number;
Begin
  write_to_log_file_n('delete_table_duplicates');
  l_name:=substr(p_table,1,26);
  write_to_log_file_n('BIS Owner is '||g_bis_owner);

  l_dup_value_table :=g_bis_owner||'.'||l_name||'A';
  l_dup_table :=g_bis_owner||'.'||l_name||'B';
  l_dup_max_table :=g_bis_owner||'.'||l_name||'C';
  l_dup_max_rowid_table :=g_bis_owner||'.'||l_name||'D';
  l_dup_rowid_table :=g_bis_owner||'.'||l_name||'E';
  l_ok_table:=g_bis_owner||'.'||l_name||'OK';
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_ok_table)=false then
    null;
  end if;
  l_stmt:='create table '||l_dup_value_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||p_table||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||p_pk||' from '||p_table||' having count('||p_pk||')>1 group by '||p_pk;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_value_table)=false then
    null;
  end if;
  write_to_log_file_n(l_stmt||get_time);
  execute immediate l_stmt;
  l_count:=sql%rowcount;
  write_to_log_file_n('Created '||l_dup_value_table||' with '||l_count||' rows '||get_time);
  if l_count=0 then
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_value_table)=false then
      null;
    end if;
    return true;
  end if;
  write_to_log_file_n('Created '||l_dup_value_table||' with '||l_count||' rows '||get_time);
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_dup_value_table,instr(l_dup_value_table,'.')+1,
  length(l_dup_value_table)),substr(l_dup_value_table,1,instr(l_dup_value_table,'.')-1));
  l_stmt:='create table '||l_dup_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||p_table||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||p_table||'.'||p_pk||','||p_table||'.'||p_pk_key||','||p_table||'.rowid row_id from '||
  l_dup_value_table||','||p_table||' where '||l_dup_value_table||'.'||p_pk||'='||p_table||'.'||p_pk;
  write_to_log_file_n(l_stmt||get_time);
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_table)=false then
    null;
  end if;
  execute immediate l_stmt;
  write_to_log_file_n('Created '||l_dup_table||' with '||sql%rowcount||' rows '||get_time);
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_dup_table,instr(l_dup_table,'.')+1,
  length(l_dup_table)),substr(l_dup_table,1,instr(l_dup_table,'.')-1));
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_value_table)=false then
    null;
  end if;
  l_stmt:='create table '||l_dup_max_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select max('||p_pk_key||') '||p_pk_key||' from '||l_dup_table||
  ' group by '||p_pk;
  write_to_log_file_n(l_stmt||get_time);
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_max_table)=false then
    null;
  end if;
  execute immediate l_stmt;
  write_to_log_file_n('Created '||l_dup_max_table||' with '||sql%rowcount||' rows '||get_time);
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_dup_max_table,instr(l_dup_max_table,'.')+1,
  length(l_dup_max_table)),substr(l_dup_max_table,1,instr(l_dup_max_table,'.')-1));
  l_stmt:='create table '||l_dup_max_rowid_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select /*+ORDERED*/ '||l_dup_table||'.row_id from '||l_dup_max_table||','||
  l_dup_table||' where '||l_dup_max_table||'.'||p_pk_key||'='||l_dup_table||'.'||p_pk_key;
  write_to_log_file_n(l_stmt||get_time);
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_max_rowid_table)=false then
    null;
  end if;
  execute immediate l_stmt;
  write_to_log_file_n('Created '||l_dup_max_rowid_table||' with '||sql%rowcount||' rows '||get_time);
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_dup_max_rowid_table,instr(l_dup_max_rowid_table,'.')+1,
  length(l_dup_max_rowid_table)),substr(l_dup_max_rowid_table,1,instr(l_dup_max_rowid_table,'.')-1));
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_max_table)=false then
    null;
  end if;
  l_stmt:='create table '||l_dup_rowid_table||'(row_id primary key) organization index '||
  ' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select row_id from '||l_dup_table||' MINUS select row_id from '||
  l_dup_max_rowid_table;
  write_to_log_file_n(l_stmt||get_time);
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_rowid_table)=false then
    null;
  end if;
  execute immediate l_stmt;
  write_to_log_file_n('Created '||l_dup_rowid_table||' with '||sql%rowcount||' rows '||get_time);
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_dup_rowid_table,instr(l_dup_rowid_table,'.')+1,
  length(l_dup_rowid_table)),substr(l_dup_rowid_table,1,instr(l_dup_rowid_table,'.')-1));
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_max_rowid_table)=false then
    null;
  end if;
  l_stmt:='delete /*+ORDERED USE_NL('||p_table||')*/ '||p_table||' where rowid in (select row_id from '||
  l_dup_rowid_table||')';
  write_to_log_file_n(l_stmt||get_time);
  execute immediate l_stmt;
  write_to_log_file_n('Deleted '||sql%rowcount||' rows '||get_time);
  commit;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_rowid_table)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:='Error in delete_table_duplicates function '||sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
end;

function delete_dim_duplicate_data(
p_dim_name varchar2,
p_dim_pk varchar2,
p_dim_pk_key varchar2
)return boolean is
-------
l_pk_table varchar2(200);
l_dup_table varchar2(200);
l_dup_max_table varchar2(200);
l_dup_update_table  varchar2(200);
l_name varchar2(200);
-------
l_stmt varchar2(8000);
l_count number;
------
l_fact EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_fact_fk EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_fact number;
------
l_found boolean;
------
Begin
  write_to_log_file_n('delete_dim_duplicate_data');
  l_name:=substr(p_dim_name,1,27);
  l_pk_table:=g_bis_owner||'.'||l_name||'P';
  l_dup_table:=g_bis_owner||'.'||l_name||'D';
  l_dup_max_table:=g_bis_owner||'.'||l_name||'DM';
  l_dup_update_table:=g_bis_owner||'.'||l_name||'U';
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_pk_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_max_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_update_table)=false then
    null;
  end if;
  l_stmt:='create table '||l_pk_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||p_dim_name||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||p_dim_pk||' from '||p_dim_name||' having count('||p_dim_pk||')>1 group by '||p_dim_pk;
  write_to_log_file_n(l_stmt||get_time);
  execute immediate l_stmt;
  l_count:=sql%rowcount;
  write_to_log_file_n('Created with '||l_count||' rows '||get_time);
  if l_count>0 then
    l_stmt:='create table '||l_dup_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL('||p_dim_name||','||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||'dim.rowid row_id,dim.'||p_dim_pk||',dim.'||p_dim_pk_key||' from '||l_pk_table||','||
    p_dim_name||' dim where dim.'||p_dim_pk||'='||l_pk_table||'.'||p_dim_pk;
    write_to_log_file_n(l_stmt||get_time);
    execute immediate l_stmt;
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    l_stmt:='create table '||l_dup_max_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select '||p_dim_pk||', max('||p_dim_pk_key||') '||p_dim_pk_key||' from '||l_dup_table||
    ' group by '||p_dim_pk;
    write_to_log_file_n(l_stmt||get_time);
    execute immediate l_stmt;
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    l_stmt:='create table '||l_dup_update_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select dup.row_id,dup.'||p_dim_pk_key||',max_dup.'||p_dim_pk_key||' max_'||p_dim_pk_key||
    ' from '||l_dup_max_table||' max_dup,'||l_dup_table||' dup '||
    'where dup.'||p_dim_pk||'=max_dup.'||p_dim_pk||' and dup.'||p_dim_pk_key||'<>'||
    'max_dup.'||p_dim_pk_key;
    write_to_log_file_n(l_stmt||get_time);
    execute immediate l_stmt;
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    l_stmt:='create unique index '||l_dup_update_table||'U1 on '||l_dup_update_table||'(row_id) '||
    'tablespace '||g_op_table_space;
    write_to_log_file_n(l_stmt||get_time);
    execute immediate l_stmt;
    l_stmt:='create unique index '||l_dup_update_table||'U2 on '||l_dup_update_table||'('||p_dim_pk_key||') '||
    'tablespace '||g_op_table_space;
    write_to_log_file_n(l_stmt||get_time);
    execute immediate l_stmt;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_dup_update_table,instr(l_dup_update_table,'.')+1,
    length(l_dup_update_table)),substr(l_dup_update_table,1,instr(l_dup_update_table,'.')-1));
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_pk_table)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_table)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_max_table)=false then
      null;
    end if;
    --update the facts
    if get_fact_fk_for_dim(p_dim_name,l_fact,l_fact_fk,l_number_fact)=false then
      return false;
    end if;
    for i in 1..l_number_fact loop
      l_stmt:='update ';
      l_found:=EDW_OWB_COLLECTION_UTIL.check_index_on_column(l_fact(i),
      EDW_OWB_COLLECTION_UTIL.get_table_owner(l_fact(i)),l_fact_fk(i));
      if l_found then
        l_stmt:=l_stmt||'/*+ORDERED USE_NL('||l_fact(i)||')*/ ';
      end if;
      l_stmt:=l_stmt||l_fact(i)||' set ('||l_fact_fk(i)||')=(select max_'||p_dim_pk_key||' from '||
      l_dup_update_table||' where '||l_dup_update_table||'.'||p_dim_pk_key||'='||l_fact(i)||'.'||l_fact_fk(i)||
      ') ';
      if l_found then
        l_stmt:=l_stmt||' where '||l_fact(i)||'.'||l_fact_fk(i)||' in (select '||p_dim_pk_key||' from '||
        l_dup_update_table||')';
      end if;
      write_to_log_file_n(l_stmt||get_time);
      begin
        execute immediate l_stmt;
        write_to_log_file_n('Updated '||sql%rowcount||' rows '||get_time);
        commit;
      exception when others then
        write_to_log_file_n(sqlerrm);
        if sqlcode=-00942 then
          write_to_log_file('This error can be ignored. Not all facts mentioned in metadata need to be '||
          'implemented');
        else
          g_status_message:=sqlerrm;
          return false;
        end if;
      end;
    end loop;
    --delete dim dup data
    l_stmt:='delete /*+ORDERED USE_NL('||p_dim_name||')*/ '||p_dim_name||' where rowid in (select row_id from '||
    l_dup_update_table||')';
    write_to_log_file_n(l_stmt||get_time);
    execute immediate l_stmt;
    write_to_log_file_n('Deleted '||sql%rowcount||' rows '||get_time);
    commit;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_update_table)=false then
      null;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:='Error in delete_dim_duplicate_data function '||sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
end;


function get_short_name_for_long(p_name varchar2) return varchar2 is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_name varchar2(400);
Begin
  l_stmt:='select relation_name from edw_relations_md_v where relation_long_name=:a';
  write_to_log_file(l_stmt);
  open cv for l_stmt using p_name;
  fetch cv into l_name;
  close cv;
  if l_name is null then
    l_name:=p_name;
  end if;
  return l_name;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  return null;
End;

procedure init_all is
check_tspace_exist varchar(1);
check_ts_mode varchar(1);
physical_tspace_name varchar2(100);

Begin
  g_status_message:=null;
  g_status:=true;
  g_bis_owner:=EDW_OWB_COLLECTION_UTIL.get_db_user('BIS');

  g_op_table_space:=fnd_profile.value('EDW_OP_TABLE_SPACE');

   if g_op_table_space is null then
	AD_TSPACE_UTIL.is_new_ts_mode (check_ts_mode);
	If check_ts_mode ='Y' then
		AD_TSPACE_UTIL.get_tablespace_name ('BIS', 'INTERFACE','Y',check_tspace_exist, physical_tspace_name);
		if check_tspace_exist='Y' and physical_tspace_name is not null then
			g_op_table_space :=  physical_tspace_name;
		end if;
	end if;
   end if;

  if g_op_table_space is null then
    g_op_table_space:=EDW_OWB_COLLECTION_UTIL.get_table_space(g_bis_owner);
  end if;

  write_to_log_file_n('Operation table space='||g_op_table_space);
  g_parallel:=fnd_profile.value('EDW_PARALLEL');
  write_to_log_file_n ('Degree of parallelism (null is default)='||g_parallel);
  if g_parallel=0 then
    g_parallel:=null;
  end if;
  null;
Exception when others then
  g_status_message:='Error in init_all '||sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
end;

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

function get_time return varchar2 is
begin
  return ' '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS');
Exception when others then
  write_to_log_file_n('Error in get_time '||sqlerrm);
End;

function is_dimension(p_object_name varchar2) return boolean is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number;
Begin
  l_stmt:='select 1 from edw_dimensions_md_v where dim_name=:a';
  write_to_log_file(l_stmt);
  open cv for l_stmt using p_object_name;
  fetch cv into l_res;
  close cv;
  if l_res=1 then
    return true;
  else
    return false;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  return false;
End;

function get_fact_fk_for_dim(
p_dim_name varchar2,
p_fact out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_fact_fk out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_fact_fk out nocopy number
)return boolean is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_stmt:='select '||
  'fact.fact_name,fk_col.column_name '||
  'from '||
  'edw_facts_md_v fact, '||
  'edw_foreign_keys_md_v fk, '||
  'EDW_PVT_KEY_COLUMNS_MD_V fku, '||
  'edw_pvt_columns_md_v fk_col, '||
  'edw_unique_keys_md_v pk, '||
  'edw_dimensions_md_v dim '||
  'where '||
  'fact.fact_id=fk.entity_id '||
  'and fk.foreign_key_id=fku.key_id '||
  'and fk_col.column_id=fku.column_id '||
  'and fk_col.parent_object_id=fact.fact_id '||
  'and pk.key_id=fk.key_id '||
  'and pk.entity_id=dim.dim_id '||
  'and dim.dim_name=:1 '||
  'order by fact.fact_name';
  p_number_fact_fk:=1;
  write_to_log_file(l_stmt);
  open cv for l_stmt using p_dim_name;
  loop
    fetch cv into p_fact(p_number_fact_fk),p_fact_fk(p_number_fact_fk);
    exit when cv%notfound;
    p_number_fact_fk:=p_number_fact_fk+1;
  end loop;
  close cv;
  p_number_fact_fk:=p_number_fact_fk-1;
  write_to_log_file('Results');
  for i in 1..p_number_fact_fk loop
    write_to_log_file(p_fact(i)||' '||p_fact_fk(i));
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_fact_fk_for_dim '||g_status_message);
  g_status:=false;
  return false;
End;

END EDW_DUPLICATE_CLEAN;

/
