--------------------------------------------------------
--  DDL for Package Body EDW_SRC_DANG_RECOVERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SRC_DANG_RECOVERY" as
/*$Header: EDWSRDTB.pls 115.6 2004/02/13 05:10:17 smulye noship $*/

/*will be called from setup in collection util
if p_db_link is null, then it assumes that source and warehouse are the same
*/
function get_dangling_keys(p_dim_name varchar2,p_db_link varchar2,
p_pk_view varchar2,p_missing_key_view varchar2) return boolean is
Begin
  g_object_name:=p_dim_name;
  g_db_link:=p_db_link;
  if p_missing_key_view is null then
    write_to_log_file_n('Missing key view not specified for '||p_dim_name);
    return true;
  end if;
  --if EDW_COLLECTION_UTIL.SOURCE_SAME_AS_TARGET then
  if g_db_link is null then
    g_src_same_wh_flag:=true;
    g_db_link_stmt:=null;
    write_to_log_file_n('Source and warehouse same');
  else
    g_src_same_wh_flag:=false;
    g_db_link_stmt:='@'||g_db_link;
    write_to_log_file_n('Source and warehouse different');
  end if;
  g_object_id:=get_dim_id(g_object_name);
  g_missing_key_view:=p_missing_key_view;
  g_pk_view:=p_pk_view;
  write_to_log_file_n('Object name='||g_object_name||', ID='||g_object_id||', DB link='||g_db_link);
  write_to_log_file_n('DB Link stmt '||g_db_link_stmt);
  write_to_log_file('Missing Key view='||g_missing_key_view||',PK View='||g_pk_view);
  if init_all=false then
    return false;
  end if;
  if g_auto_dang_flag=false then
    return true;
  end if;
  if get_dangling_keys=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_dangling_keys return boolean is
Begin
  if check_table(g_wh_dang_table||g_db_link_stmt)=false then
    if g_debug then
      write_to_log_file_n('Remote '||g_wh_dang_table||' does not exist. No dangling processing to do!');
    end if;
    return true;
  end if;
  if get_ll_keys_from_wh=false then
    return false;
  end if;
  if get_hl_keys_from_view=false then
    return false;
  end if;
  if create_missing_key_view=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_ll_keys_from_wh return boolean is
l_stmt varchar2(20000);
l_table varchar2(200);
l_table2 varchar2(200);
l_table3 varchar2(200);
l_db_columns varcharTableType;
l_number_db_columns number;
l_found boolean;
Begin
  if drop_table(g_level_table)=false then
    null;
  end if;
  l_stmt:='create table '||g_level_table||' tablespace '||g_src_op_table_space;
  l_stmt:=l_stmt||' as select upper(ltc.name) name,ltc.elementid id,upper(lvl.LEVEL_PREFIX) prefix from ';
  l_stmt:=l_stmt||' edw_tables_md_v'||g_db_link_stmt||' ltc,edw_levels_md_v'||g_db_link_stmt||' lvl '||
  'where lvl.DIM_ID='||g_object_id||' and lvl.LEVEL_TABLE_NAME=ltc.name';
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  analyze_table_stats(substr(g_level_table,instr(g_level_table,'.')+1,
  length(g_level_table)),substr(g_level_table,1,instr(g_level_table,'.')-1));
  if g_err_rec_flag then
    l_table:=g_dang_table||'1';
  else
    l_table:=g_dang_table;
  end if;
  if drop_table(l_table)=false then
    null;
  end if;
  if g_number_pk_cols>0 then
    l_stmt:='create table '||l_table||' tablespace '||g_src_op_table_space;
    l_stmt:=l_stmt||' as select * from '||g_wh_dang_table||g_db_link_stmt||
    ' where 1=2';
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    l_number_db_columns:=0;
    if get_db_columns_for_table(substr(l_table,instr(l_table,'.')+1),
      l_db_columns,l_number_db_columns,g_src_bis_owner)=false then
      null;
    end if;
    for i in 1..g_number_pk_cols loop
      if value_in_table(l_db_columns,l_number_db_columns,g_pk_cols(i))=false then
        if g_debug then
          write_to_log_file_n('The remote table '||g_wh_dang_table||g_db_link_stmt||' does not have column ');
          write_to_log_file(g_pk_cols(i)||'. So using value and PK. Cannot use columns listed in profile options');
        end if;
        g_number_pk_cols:=0;
        g_number_profile_options:=0;
        exit;
      end if;
    end loop;
    l_number_db_columns:=0;
    if drop_table(l_table)=false then
      null;
    end if;
  end if;
  l_stmt:='create table '||l_table||' tablespace '||g_src_op_table_space;
  if g_src_parallel is not null then
    l_stmt:=l_stmt||' parallel(degree '||g_src_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select distinct level_table,value';
  for i in 1..g_number_pk_cols loop
    l_stmt:=l_stmt||','||g_pk_cols(i);
  end loop;
  l_stmt:=l_stmt||' from '||g_wh_dang_table||g_db_link_stmt;
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  g_dang_table_count:=sql%rowcount;
  if g_debug then
    write_to_log_file_n('Created with '||g_dang_table_count||' rows '||get_time);
  end if;
  --truncate the remote table
  if g_debug then
    write_to_log_file_n('Going to truncate table '||g_wh_dang_table||' at '||g_db_link_stmt);
  end if;
  l_stmt:='begin EDW_OWB_COLLECTION_UTIL.truncate_table'||g_db_link_stmt||'('''||g_wh_dang_table||''');end;';
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  commit;
  --if src is different from the warehouse, look at the source also for g_wh_dang_table on the src.
  if g_src_same_wh_flag=false then
    if does_table_have_data(g_wh_dang_table)=2 then
      l_table2:=g_dang_table||'2';
      l_table3:=g_dang_table||'3';
      if drop_table(l_table2)=false then
        null;
      end if;
      if drop_table(l_table3)=false then
        null;
      end if;
      l_stmt:='create table '||l_table2||' tablespace '||g_src_op_table_space;
      if g_src_parallel is not null then
        l_stmt:=l_stmt||' parallel(degree '||g_src_parallel||') ';
      end if;
      l_stmt:=l_stmt||' as select distinct level_table,value';
      for i in 1..g_number_pk_cols loop
        l_stmt:=l_stmt||','||g_pk_cols(i);
      end loop;
      l_stmt:=l_stmt||' from '||g_wh_dang_table;
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
      end if;
      l_stmt:='create table '||l_table3||' tablespace '||g_src_op_table_space;
      if g_src_parallel is not null then
        l_stmt:=l_stmt||' parallel(degree '||g_src_parallel||') ';
      end if;
      l_stmt:=l_stmt||' as select * from '||l_table;
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
      end if;
      if drop_table(l_table)=false then
        null;
      end if;
      l_stmt:='create table '||l_table||' tablespace '||g_src_op_table_space;
      if g_src_parallel is not null then
        l_stmt:=l_stmt||' parallel(degree '||g_src_parallel||') ';
      end if;
      l_stmt:=l_stmt||' as select level_table,value';
      for i in 1..g_number_pk_cols loop
        l_stmt:=l_stmt||','||g_pk_cols(i);
      end loop;
      l_stmt:=l_stmt||' from '||l_table2||' UNION  select level_table,value';
      for i in 1..g_number_pk_cols loop
        l_stmt:=l_stmt||','||g_pk_cols(i);
      end loop;
      l_stmt:=l_stmt||' from '||l_table3;
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      g_dang_table_count:=sql%rowcount;
      if g_debug then
        write_to_log_file_n('Created with '||g_dang_table_count||' rows '||get_time);
      end if;
      if drop_table(l_table2)=false then
        null;
      end if;
      if drop_table(l_table3)=false then
        null;
      end if;
    end if;
  end if;
  if get_db_columns_for_table(substr(l_table,instr(l_table,'.')+1),
    g_wh_dang_table_cols,g_number_wh_dang_table_cols,g_src_bis_owner)=false then
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('DB columns for '||l_table);
    for i in 1..g_number_wh_dang_table_cols loop
      write_to_log_file(g_wh_dang_table_cols(i));
    end loop;
  end if;
  if g_err_rec_flag then
    l_number_db_columns:=0;
    l_found:=true;
    if get_db_columns_for_table(substr(g_dang_table,instr(g_dang_table,'.')+1),
      l_db_columns,l_number_db_columns,g_src_bis_owner)=false then
      if get_db_columns_for_table(substr(g_dang_table,instr(g_dang_table,'.')+1),
        l_db_columns,l_number_db_columns,null)=false then
        return false;
      end if;
    end if;
    for i in 1..g_number_wh_dang_table_cols loop
      if value_in_table(l_db_columns,l_number_db_columns,g_wh_dang_table_cols(i))=false then
        if g_debug then
          write_to_log_file_n('Column '||g_wh_dang_table_cols(i)||' not found in dang table '||g_dang_table);
        end if;
        l_found:=false;
        exit;
      end if;
    end loop;
    if l_found=false then
      --a very rare occurance. if someone changed the pk structure in the middle of an error recovery
      if drop_table(g_dang_table)=false then
        null;
      end if;
      l_stmt:='create table '||g_dang_table||' tablespace '||g_src_op_table_space;
      if g_src_parallel is not null then
        l_stmt:=l_stmt||' parallel(degree '||g_src_parallel||') ';
      end if;
      l_stmt:=l_stmt||' as select * from '||l_table;
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
      end if;
      g_err_rec_flag:=false;
    else
      l_table2:=g_dang_table||'2';
      l_table3:=g_dang_table||'3';
      l_stmt:='create table '||l_table2||' tablespace '||g_src_op_table_space;
      if g_src_parallel is not null then
        l_stmt:=l_stmt||' parallel(degree '||g_src_parallel||') ';
      end if;
      l_stmt:=l_stmt||' as select A.rowid row_id from '||l_table||' A,'||g_dang_table||' B '||
      ' where ';
      for i in 1..g_number_wh_dang_table_cols loop
        if g_wh_dang_table_cols(i)<>'LEVEL_TABLE' then
          l_stmt:=l_stmt||'nvl(A.'||g_wh_dang_table_cols(i)||',''null'')='||
          'nvl(B.'||g_wh_dang_table_cols(i)||',''null'') and ';
        else
          l_stmt:=l_stmt||'A.'||g_wh_dang_table_cols(i)||'='||
          'B.'||g_wh_dang_table_cols(i)||' and ';
        end if;
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
      if drop_table(l_table2)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
      end if;
      l_stmt:='create table '||l_table3||' tablespace '||g_src_op_table_space;
      if g_src_parallel is not null then
        l_stmt:=l_stmt||' parallel(degree '||g_src_parallel||') ';
      end if;
      l_stmt:=l_stmt||' as select rowid row_id from '||l_table||' MINUS select row_id from '||l_table2;
      if drop_table(l_table3)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
      end if;
      l_stmt:='insert into '||g_dang_table||'(';
      for i in 1..g_number_wh_dang_table_cols loop
        l_stmt:=l_stmt||g_wh_dang_table_cols(i)||',';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
      l_stmt:=l_stmt||') select ';
      for i in 1..g_number_wh_dang_table_cols loop
        l_stmt:=l_stmt||'B.'||g_wh_dang_table_cols(i)||',';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
      l_stmt:=l_stmt||' from '||l_table3||' A, '||l_table||' B where A.row_id=B.rowid';
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Inserted '||sql%rowcount||' rows '||get_time);
      end if;
      commit;
    end if;
    if drop_table(l_table)=false then
      null;
    end if;
    if drop_table(l_table2)=false then
      null;
    end if;
    if drop_table(l_table3)=false then
      null;
    end if;
  end if;
  analyze_table_stats(substr(g_dang_table,instr(g_dang_table,'.')+1,
  length(g_dang_table)),substr(g_dang_table,1,instr(g_dang_table,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_hl_keys_from_view return boolean is
l_stmt varchar2(20000);
l_stmt1 varchar2(20000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_level varcharTableType;
l_level_id numberTableType;
l_level_prefix varcharTableType;
l_number_level number;
l_table varchar2(400);
l_table2 varchar2(400);
l_table3 varchar2(400);
l_table4 varchar2(400);
l_lowest_level varchar2(400);
l_lowest_level_id number;
l_lowest_level_prefix varchar2(400);
l_lowest_level_pk varchar2(400);
l_level_pk varchar2(200);
Begin
  if g_debug then
    write_to_log_file_n('In get_hl_keys_from_view'||get_time);
  end if;
  l_table:=g_dang_table||'1';
  if check_table(g_pk_view)=false then
    if g_debug then
      write_to_log_file_n('PK View '||g_pk_view||' not found. Cannot find higher level keys');
    end if;
    return true;
  end if;
  if get_db_columns_for_table(g_pk_view,g_pk_view_cols,g_number_pk_view_cols)=false then
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('The DB columns of the view '||g_pk_view);
    for i in 1..g_number_pk_view_cols loop
      write_to_log_file(g_pk_view_cols(i));
    end loop;
  end if;
  l_stmt:='select name,id,prefix from '||g_level_table;
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  l_number_level:=1;
  open cv for l_stmt;
  loop
    fetch cv into l_level(l_number_level),l_level_id(l_number_level),l_level_prefix(l_number_level);
    exit when cv%notfound;
    l_number_level:=l_number_level+1;
  end loop;
  l_number_level:=l_number_level-1;
  close cv;
  if g_debug then
    write_to_log_file_n('Level and prefix');
    for i in 1..l_number_level loop
      write_to_log_file(l_level(i)||' ('||l_level_id(i)||') ('||l_level_prefix(i)||')');
    end loop;
  end if;
  l_stmt:='select EDW_OWB_COLLECTION_UTIL.get_lowest_level_table'||g_db_link_stmt||'(null,'||g_object_id||
  ') from dual';
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  open cv for l_stmt;
  fetch cv into l_lowest_level;
  close cv;
  for i in 1..l_number_level loop
    if l_level(i)=l_lowest_level then
      l_lowest_level_prefix:=l_level_prefix(i);
      l_lowest_level_id:=l_level_id(i);
      exit;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('Lowest level '||l_lowest_level||'('||l_lowest_level_id||') '||l_lowest_level_prefix);
  end if;
  --l_lowest_level_pk
  l_stmt:='select EDW_OWB_COLLECTION_UTIL.get_dim_pk'||g_db_link_stmt||'(null,'||g_object_id||
  ') from dual';
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  open cv for l_stmt;
  fetch cv into l_lowest_level_pk;
  close cv;
  l_lowest_level_pk:=substr(l_lowest_level_pk,1,instr(l_lowest_level_pk,'_KEY',-1)-1);
  if g_debug then
    write_to_log_file_n('Lowest level PK '||l_lowest_level_pk);
  end if;
  l_stmt:='create table '||l_table||' tablespace '||g_src_op_table_space;
  if g_src_parallel is not null then
    l_stmt:=l_stmt||' parallel(degree '||g_src_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select ';
  for i in 1..g_number_pk_view_cols loop
    if g_pk_view_cols(i)<>l_lowest_level_pk and value_in_table(g_pk_cols,g_number_pk_cols,
      g_pk_view_cols(i))=false then
      l_stmt:=l_stmt||'B.'||g_pk_view_cols(i)||',';
    end if;
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||' from '||g_pk_view||' B where 1=2';
  if drop_table(l_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  l_stmt1:='insert ';
  if g_src_parallel is not null then
    l_stmt1:=l_stmt1||'/*+parallel(AA,'||g_src_parallel||')*/ ';
  end if;
  l_stmt1:=l_stmt1||' into '||l_table||' AA (';
  for i in 1..g_number_pk_view_cols loop
    if g_pk_view_cols(i)<>l_lowest_level_pk and value_in_table(g_pk_cols,g_number_pk_cols,
      g_pk_view_cols(i))=false then
      l_stmt1:=l_stmt1||g_pk_view_cols(i)||',';
    end if;
  end loop;
  l_stmt1:=substr(l_stmt1,1,length(l_stmt1)-1);
  l_stmt1:=l_stmt1||') select ';
  for i in 1..g_number_pk_view_cols loop
    if g_pk_view_cols(i)<>l_lowest_level_pk and value_in_table(g_pk_cols,g_number_pk_cols,
      g_pk_view_cols(i))=false then
      l_stmt1:=l_stmt1||'B.'||g_pk_view_cols(i)||',';
    end if;
  end loop;
  l_stmt1:=substr(l_stmt1,1,length(l_stmt1)-1);
  l_stmt1:=l_stmt1||' from '||g_dang_table||' A,'||g_pk_view||' B where ';
  if g_number_profile_options>0 then
    for k in 1..g_number_profile_options loop
      l_stmt:=l_stmt1;
      for i in 1..g_number_pk_cols loop
        if g_pk_porfile_number(i)=k then
          l_stmt:=l_stmt||' B.'||g_pk_cols(i)||'=A.'||g_pk_cols(i)||' and ';
        end if;
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
      if g_err_rec_flag then
        l_stmt:=l_stmt||' and A.level_table='||l_lowest_level_id;
      end if;
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Inserted '||sql%rowcount||' rows '||get_time);
      end if;
      commit;
    end loop;
  else
    l_stmt:=l_stmt1;
    l_stmt:=l_stmt||' A.value=B.'||l_lowest_level_pk;
    if g_err_rec_flag then
      l_stmt:=l_stmt||' and A.level_table='||l_lowest_level_id;
    end if;
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Inserted '||sql%rowcount||' rows '||get_time);
    end if;
    commit;
  end if;
  --insert into g_wh_dang_table
  for i in 1..l_number_level loop
    if l_level(i)<>l_lowest_level then
      l_level_pk:=get_pk_for_level(l_level_prefix(i));
      if l_level_pk is not null then
        l_table2:=g_dang_table||'2';
        l_stmt:='create table '||l_table2||' tablespace '||g_src_op_table_space;
        if g_src_parallel is not null then
          l_stmt:=l_stmt||' parallel(degree '||g_src_parallel||') ';
        end if;
        l_stmt:=l_stmt||' as select distinct '||l_level_pk||' from '||l_table;
        if drop_table(l_table2)=false then
          null;
        end if;
        if g_debug then
          write_to_log_file_n(l_stmt||get_time);
        end if;
        execute immediate l_stmt;
        if g_debug then
          write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
        end if;
        if g_err_rec_flag then
          l_table3:=g_dang_table||'3';
          l_stmt:='create table '||l_table3||' tablespace '||g_src_op_table_space;
          if g_src_parallel is not null then
            l_stmt:=l_stmt||' parallel(degree '||g_src_parallel||') ';
          end if;
          l_stmt:=l_stmt||' as select value '||l_level_pk||' from '||g_dang_table||
          ' where level_table='||l_level_id(i);
          if drop_table(l_table3)=false then
            null;
          end if;
          if g_debug then
            write_to_log_file_n(l_stmt||get_time);
          end if;
          execute immediate l_stmt;
          if g_debug then
            write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
          end if;
          l_table4:=g_dang_table||'4';
          l_stmt:='create table '||l_table4||' tablespace '||g_src_op_table_space;
          if g_src_parallel is not null then
            l_stmt:=l_stmt||' parallel(degree '||g_src_parallel||') ';
          end if;
          l_stmt:=l_stmt||' as select '||l_level_pk||' from '||l_table2||' MINUS select '||
          l_level_pk||' from '||l_table3;
          if drop_table(l_table4)=false then
            null;
          end if;
          if g_debug then
            write_to_log_file_n(l_stmt||get_time);
          end if;
          execute immediate l_stmt;
          if g_debug then
            write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
          end if;
          if drop_table(l_table2)=false then
            null;
          end if;
          if drop_table(l_table3)=false then
            null;
          end if;
        else
          l_table4:=l_table2;
        end if;
        l_stmt:='insert into '||g_dang_table||'(level_table,value) select '||l_level_id(i)||','||l_level_pk||
        ' from '||l_table4;
        if g_debug then
          write_to_log_file_n(l_stmt||get_time);
        end if;
        execute immediate l_stmt;
        if g_debug then
          write_to_log_file_n('Inserted '||sql%rowcount||' rows '||get_time);
        end if;
        commit;
        if drop_table(l_table4)=false then
          null;
        end if;
      else
        if g_debug then
          write_to_log_file_n('No pk found for level '||l_level(i)||' in PK view ');
        end if;
      end if;
    end if;
  end loop;
  if drop_table(l_table)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function init_all return boolean is
Begin
  g_status_message:=null;
  g_read_cfig_options:=false;
  g_src_bis_owner:=get_db_user('BIS');
  g_instance:=get_this_instance;
  if g_instance is null then
    write_to_log_file_n('No local instance found');
    return false;
  end if;
  g_dang_table:=g_src_bis_owner||'.SADR_'||g_object_id||'_'||g_instance;
  g_wh_dang_table:='EDW_ADR_'||g_object_id||'_'||g_instance;--view name
  g_level_table:=g_src_bis_owner||'.SLID_'||g_object_id||'_'||g_instance;
  g_number_pk_view_cols:=0;
  g_number_wh_dang_table_cols:=0;
  g_err_rec_flag:=false;
  if g_read_cfig_options then
    if read_cfig_options=false then
      return false;
    end if;
  else
    if read_profile_options=false then
      return false;
    end if;
  end if;
  g_debug:=true;
  if g_debug then
    write_to_log_file_n('Check for table '||g_dang_table||' for error recovery');
  end if;
  if does_table_have_data(g_dang_table)=2 then
    g_err_rec_flag:=true;
  end if;
  if g_auto_dang_flag=false then
    write_to_log_file_n('Auto Dangling Recovery NOT Implemented');
    return true;
  end if;
  if get_pk_structure=false then
    return false;
  end if;
  write_to_log_file_n('The option values');
  write_to_log_file('g_src_bis_owner='||g_src_bis_owner);
  write_to_log_file('g_instance='||g_instance);
  write_to_log_file('g_src_op_table_space='||g_src_op_table_space);
  write_to_log_file('g_src_parallel='||g_src_parallel);
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_dim_id(p_object_name varchar2) return number is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_object_id number;
Begin
  l_stmt:='select DIM_ID from edw_dimensions_md_v'||g_db_link_stmt||' where DIM_NAME=:a';
  open cv for l_stmt using p_object_name;
  fetch cv into l_object_id;
  close cv;
  return l_object_id;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function get_db_user(p_product varchar2) return varchar2 is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_dummy1 varchar2(2000);
l_dummy2 varchar2(2000);
l_schema varchar2(400);
Begin
  if FND_INSTALLATION.GET_APP_INFO(p_product,l_dummy1, l_dummy2,l_schema) = false then
    write_to_log_file_n('FND_INSTALLATION.GET_APP_INFO returned with error');
    return null;
  end if;
  return l_schema;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function get_this_instance return varchar2 is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_instance varchar2(400);
Begin
  l_stmt:='select instance_code from edw_local_instance';
  open cv for l_stmt;
  fetch cv into l_instance;
  close cv;
  return l_instance;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function get_default_tablespace return varchar2 is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(4000);
l_op_table_space varchar2(400);
Begin
  l_stmt:='select default_tablespace from dba_users where username=:a';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||g_src_bis_owner);
  end if;
  open cv for l_stmt using g_src_bis_owner;
  fetch cv into l_op_table_space;
  close cv;
  return l_op_table_space;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function read_profile_options return boolean is
l_value varchar2(400);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(4000);
l_res number;
check_tspace_exist varchar(1);
check_ts_mode varchar(1);
physical_tspace_name varchar2(100);
Begin
  l_value:=fnd_profile.value('EDW_DEBUG');
  g_debug:=false;
  if l_value='Y' then
    g_debug:=true;
  end if;
  if g_debug then
    write_to_log_file_n('Debug turned ON');
  else
    write_to_log_file_n('Debug turned OFF');
  end if;
  g_auto_dang_flag:=true;
  l_stmt:='select 1 from edw_attribute_sets_md_v'||g_db_link_stmt||' sis where '||
  'sis.ATTRIBUTE_GROUP_NAME=''AUTO_DANGLING_RECOVERY'' '||
  'and sis.ENTITY_ID=:b';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open cv for l_stmt using g_object_id;
  fetch cv into l_res;
  close cv;
  if l_res=1 then
    g_auto_dang_flag:=false;
  end if;
  if g_auto_dang_flag=false then
    return true;
  end if;

  g_src_op_table_space:=fnd_profile.value('EDW_OP_TABLE_SPACE');

    if g_src_op_table_space is null then
	AD_TSPACE_UTIL.is_new_ts_mode (check_ts_mode);
	If check_ts_mode ='Y' then
		AD_TSPACE_UTIL.get_tablespace_name ('BIS', 'INTERFACE','Y',check_tspace_exist, physical_tspace_name);
		if check_tspace_exist='Y' and physical_tspace_name is not null then
			g_src_op_table_space :=  physical_tspace_name;
		end if;
	end if;
   end if;
  if g_src_op_table_space is null then
    g_src_op_table_space:=get_default_tablespace;
  end if;

  g_src_parallel:=fnd_profile.value('EDW_PARALLEL');
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function read_cfig_options return boolean is
l_option_value varchar2(20);
Begin
  l_option_value:=get_src_option('DEBUG');
  if l_option_value='Y' then
    write_to_log_file_n('Debug turned ON');
    g_debug:=true;
  else
    write_to_log_file_n('Debug turned OFF');
    g_debug:=false;
  end if;
  l_option_value:=null;
  l_option_value:=get_src_option('AUTODANG');
  if l_option_value='N' then
    g_auto_dang_flag:=false;
  else
    g_auto_dang_flag:=true;
  end if;
  if g_auto_dang_flag=false then
    return true;
  end if;
  l_option_value:=null;
  l_option_value:=get_src_option('PARALLELISM');
  if l_option_value is not null then
    g_src_parallel:=to_number(l_option_value);
    if g_src_parallel=0 then
      g_src_parallel:=null;
    end if;
  else
    g_src_parallel:=null;
  end if;
  if g_src_parallel is not null then
    execute immediate 'alter session enable parallel dml';
  end if;
  g_src_op_table_space:=get_src_option('OPTABLESPACE');
  if g_src_op_table_space is null then
    g_src_op_table_space:=get_default_tablespace;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_src_option(p_option_code varchar2) return varchar2 is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(4000);
l_option_value varchar2(400);
Begin
  l_stmt:='select EDW_OPTION.get_source_option'||g_db_link_stmt||'(null,'||g_object_id||','''||
  p_option_code||''','''||g_instance||''') from dual';
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  open cv for l_stmt;
  fetch cv into l_option_value;
  close cv;
  return l_option_value;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;


function get_time return varchar2 is
begin
 return ' '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS');
End;


procedure write_to_log_file(p_message varchar2) is
 l_len number;
 l_start number:=1;
 l_end number:=1;
 last_reached boolean:=false;
 begin
 if p_message is null or p_message='' then
   return;
 end if;
 l_len:=nvl(length(p_message),0);
 if l_len <=0 then
   return;
 end if;
 fnd_file.new_line(FND_FILE.LOG,1);
 while true loop
  l_end:=l_start+250;
  if l_end >= l_len then
   l_end:=l_len;
   last_reached:=true;
  end if;
  FND_FILE.PUT(FND_FILE.LOG,substr(p_message,l_start,250));
  l_start:=l_start+250;
  if last_reached then
   exit;
  end if;
 end loop;
Exception when others then
  null;
End;

procedure write_to_log_file_n(p_message varchar2) is
begin
  write_to_log_file('  ');
  write_to_log_file(p_message);
Exception when others then
  g_status_message:=sqlerrm;
  null;
end;

function drop_table(p_table_name varchar2,p_owner varchar2) return boolean is
l_stmt varchar2(4000);
Begin
  if g_debug then
    write_to_log_file_n('In drop_table '||p_table_name||' owner '||p_owner);
  end if;
  if p_owner is null then
    l_stmt:='drop table '||p_table_name;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt);
    end if;
    execute immediate l_stmt;
  else
    l_stmt:='drop table '||p_owner||'.'||p_table_name;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt);
    end if;
    execute immediate l_stmt;
  end if;
  return  true;
Exception when others then
  write_to_log_file_n('Could not drop table '||sqlerrm);
  return false;
End;

function check_table(p_table varchar2, p_owner varchar2) return boolean is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In check_table for '||p_table||' and owner '||p_owner);
  end if;
  begin
    if p_owner is null then
      l_stmt:='select 1 from '||p_table||' where rownum=1';
    else
      l_stmt:='select 1 from '||p_owner||'.'||p_table||' where rownum=1';
    end if;
    open cv for l_stmt;
    close cv;
    if g_debug then
      write_to_log_file('Table found');
    end if;
    return true;
  exception when others then
    g_status_message:=sqlerrm;
    if g_debug then
      write_to_log_file('Table NOT found');
    end if;
    return false;
  end;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in  check_table '||sqlerrm||' '||get_time);
  return false;
End;

function get_db_columns_for_table(
    p_table varchar2,
    p_columns OUT NOCOPY varcharTableType,
    p_number_columns OUT NOCOPY number,
    p_owner varchar2) return boolean is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In get_db_columns_for_table, Input params is '||p_table||
    ' and owner '||p_owner);
  end if;
  p_number_columns:=1;

  if p_owner is not null then
    l_stmt:='select column_name from all_tab_columns where table_name=:a and owner=:b order by column_id';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt);
    end if;
    open cv for l_stmt using p_table,p_owner;
  else
    l_stmt:='select tab.column_name from all_tab_columns tab, user_synonyms syn where
    tab.table_name=:a and tab.table_name=syn.table_name and tab.owner=syn.table_owner order by tab.column_id';

    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt);
    end if;
    open cv for l_stmt using p_table;
  end if;

  loop
    fetch cv into p_columns(p_number_columns);
    exit when cv%notfound;
    p_number_columns:=p_number_columns+1;
  end loop;
  close cv;
  p_number_columns:=p_number_columns-1;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  p_number_columns:=0;
  return false;
End;

procedure analyze_table_stats(p_table varchar2, p_owner varchar2) is
errbuf varchar2(2000);
retcode varchar2(200);
l_owner varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In analyze_table_stats. table is '||p_table||' and p_owner is '||p_owner);
  end if;
  l_owner:=p_owner;
  if g_src_parallel is null then
    FND_STATS.GATHER_TABLE_STATS (errbuf, retcode, l_owner, p_table,null,1);
  else
    FND_STATS.GATHER_TABLE_STATS (errbuf, retcode, l_owner, p_table,null,g_src_parallel);
  end if;
  if retcode <> '0' then
    write_to_log_file_n('FND_STATS.GATHER_TABLE_STATS status message is '||errbuf);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in analyze_table_stats '||sqlerrm);
End;

function get_pk_structure return boolean is
l_start number;
l_end number;
l_length number;
l_col varchar2(200);
l_pk_structure varchar2(800);
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_stmt:='select profile_option_name from fnd_profile_options where profile_option_name '||
  ' like '''||g_object_name||'_PS%''';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  g_number_profile_options:=1;
  open cv for l_stmt;
  loop
    fetch cv into g_profile_options(g_number_profile_options);
    exit when cv%notfound;
    g_number_profile_options:=g_number_profile_options+1;
  end loop;
  g_number_profile_options:=g_number_profile_options-1;
  g_number_pk_cols:=0;
  for i in 1..g_number_profile_options loop
    if g_debug then
      write_to_log_file_n('Looking at '||g_profile_options(i));
    end if;
    l_pk_structure:=null;
    l_pk_structure:=fnd_profile.value(g_profile_options(i));
    if l_pk_structure is not null then
      l_start:=1;
      l_end:=1;
      l_length:=length(l_pk_structure);
      loop
        l_end:=instr(l_pk_structure,'-',l_start);
        if l_end=0 then
          l_end:=l_length+1;
        end if;
        l_col:=substr(l_pk_structure,l_start,(l_end-l_start));
        if l_col<>'INST' then
          g_number_pk_cols:=g_number_pk_cols+1;
          g_pk_cols(g_number_pk_cols):=l_col;
          g_pk_porfile_number(g_number_pk_cols):=i;
        end if;
        if l_end>l_length then
          exit;
        end if;
        l_start:=l_end+1;
      end loop;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('All the columns paresed from pk structure ');
    for i in 1..g_number_pk_cols loop
      write_to_log_file(g_pk_porfile_number(i)||' '||g_pk_cols(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_pk_structure '||g_status_message);
  return false;
End;

function value_in_table(
    p_table varcharTableType,
    l_number_table number,
    p_value varchar2) return boolean is
Begin
  if p_value is null or l_number_table <=0 then
    return false;
  end if;
  for i in 1..l_number_table loop
    if p_table(i)=p_value then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in value_in_table '||sqlerrm);
  return false;
End;

function get_pk_for_level(p_level_prefix varchar2) return varchar2 is
Begin
  for i in 1..g_number_pk_view_cols loop
    if instr(g_pk_view_cols(i),p_level_prefix||'_',1)=1 then
      if value_in_table(g_pk_cols,g_number_pk_cols,g_pk_view_cols(i))=false then
        return g_pk_view_cols(i);
      end if;
    end if;
  end loop;
  return null;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_pk_for_level '||sqlerrm);
  return null;
End;

/*
does_table_have_data :
0 : Error
1: no data
2: data present
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
  return 0;
End;

function create_missing_key_view return boolean is
l_stmt varchar2(2000);
Begin
  if g_debug then
    write_to_log_file_n('In create_missing_key_view'||get_time);
  end if;
  l_stmt:='create or replace view '||g_missing_key_view||' as select '''||g_object_name||''' dimension_name,'||
  'A.name level_table,B.value value';
  for i in 1..g_number_pk_cols loop
    l_stmt:=l_stmt||',B.'||g_pk_cols(i)||' '||g_pk_cols(i);
  end loop;
  l_stmt:=l_stmt||' from '||g_level_table||' A,'||g_dang_table||' B where A.id=B.level_table';
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created view '||get_time);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in create_missing_key_view '||sqlerrm);
  return false;
End;

--will be called from wrap_up in collection util
procedure truncate_dang_table is
Begin
  execute immediate 'truncate table '||g_dang_table;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in truncate_dang_table '||sqlerrm);
End;

END EDW_SRC_DANG_RECOVERY;

/
