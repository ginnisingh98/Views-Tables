--------------------------------------------------------
--  DDL for Package Body EDW_CLEAN_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_CLEAN_OBJECT" as
/*$Header: EDWOCLNB.pls 120.1 2006/03/28 01:45:12 rkumar noship $*/

procedure clean_up_object(
Errbuf out NOCOPY varchar2,
Retcode out NOCOPY varchar2,
p_object_name in varchar2,
p_truncate_stg in varchar2) IS
Begin
  retcode:='0';

  g_object_name:=get_short_name_for_long(p_object_name);
  if g_object_name is null then
    errbuf:=g_status_message;
    retcode:='2';
    return;
  end if;
  g_truncate_stg:=p_truncate_stg;
  EDW_OWB_COLLECTION_UTIL.setup_conc_program_log(g_object_name);
  write_to_log_file('g_object_name='||g_object_name||',g_truncate_stg='||g_truncate_stg);
  init_all;
  if is_dimension(g_object_name) then
    if clean_up_dimension(g_object_name)=false then
      errbuf:=g_status_message;
      retcode:='2';
      return;
    end if;
  else
    if clean_up_fact(g_object_name)=false then
      errbuf:=g_status_message;
      retcode:='2';
      return;
    end if;
  end if;
Exception when others then
  errbuf:=sqlerrm;
  retcode:='2';
End;

function clean_up_dimension(p_dim varchar2) return boolean is
Begin
  if read_metadata(p_dim)=false then
    return false;
  end if;
  if clean_dim_objects=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  return false;
End;


function read_metadata(p_dim varchar2) return boolean is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_table varchar2(400);
l_table_owner varchar2(30); --bug#4905343
l_level_tag varchar2(30);   --bug#4905343
Begin
  g_dim:=p_dim;
  g_bis_owner:=EDW_OWB_COLLECTION_UTIL.get_db_user('BIS');
  g_dim_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(g_dim);

  l_level_tag:='_LTC';

  l_stmt:='select syn.table_owner '||
          ' from user_synonyms syn, edw_dimensions_md_v dim, edw_levels_md_v lvl'||
  	  ' where dim.dim_name=:a and lvl.dim_id=dim.dim_id and syn.table_name=lvl.level_name||:b'; ----bug#4905343

  open cv for l_stmt using g_dim,l_level_tag;	  --bug#4905343
  fetch cv into l_table_owner;
  close cv;

  l_stmt:='select ltc.name,lstg.name,snplog.log_table from edw_tables_md_v ltc, edw_dimensions_md_v dim, '||
   'edw_levels_md_v lvl, edw_tables_md_v lstg,all_snapshot_logs snplog,edw_pvt_map_properties_md_v map, '||
   'user_synonyms syn '||
   'where dim.dim_name=:a '||
   'and lvl.dim_id=dim.dim_id and ltc.name=lvl.level_name||:b '|| --bug#4905343
   'and map.primary_target(+)=ltc.elementid and map.primary_source=lstg.elementid(+) '||
   'and snplog.master=ltc.name and snplog.log_owner=:c';

  write_to_log_file('going to execute '||l_stmt);
  open cv for l_stmt using g_dim, l_level_tag,l_table_owner; --bug#4905343
  g_number_ltc:=1;
  loop
    fetch cv into g_ltc_tables(g_number_ltc),g_lstg_tables(g_number_ltc),g_ltc_snplogs(g_number_ltc);
    exit when cv%notfound;
    g_number_ltc:=g_number_ltc+1;
  end loop;
  g_number_ltc:=g_number_ltc-1;
  g_number_op_tables:=0;
  for i in 1..g_number_ltc loop
    g_number_op_tables:=g_number_op_tables+1;
    l_table:=substr(g_ltc_tables(i),1,26);
    g_op_tables(g_number_op_tables):=l_table||'OK';
  end loop;
  g_dim_ilog:=g_dim||'IL';
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  return false;
End;

function clean_dim_objects return boolean is
l_stmt varchar2(4000);
l_count number;
Begin
  l_stmt:='truncate table '||g_dim_owner||'.'||g_dim;
  write_to_log_file(l_stmt);
  if execute_stmt(l_stmt)=false then
    null;
  end if;
  for i in 1..g_number_ltc loop
    l_stmt:='truncate table '||g_dim_owner||'.'||g_ltc_tables(i);
    write_to_log_file(l_stmt);
    if execute_stmt(l_stmt)=false then
      null;
    end if;
  end loop;
  if g_truncate_stg='Y' then
    for i in 1..g_number_ltc loop
      if g_lstg_tables(i) is not null then
        l_stmt:='truncate table '||g_dim_owner||'.'||g_lstg_tables(i);
        write_to_log_file(l_stmt);
        if execute_stmt(l_stmt)=false then
          null;
        end if;
      end if;
    end loop;
  else
    for i in 1..g_number_ltc loop
      if g_lstg_tables(i) is not null then
        l_stmt:='update '||g_lstg_tables(i)||' set collection_status=''READY'' where collection_status<>''READY'' '||
        ' and rownum<=100000';
        write_to_log_file(l_stmt);
        loop
          execute immediate l_stmt;
          l_count:=sql%rowcount;
          commit;
          if l_count <100000 then
            exit;
          end if;
        end loop;
      end if;
    end loop;
  end if;

  for i in 1..g_number_ltc loop
    if g_ltc_snplogs(i) is not null then
      l_stmt:='truncate table '||g_dim_owner||'.'||g_ltc_snplogs(i);
      write_to_log_file(l_stmt);
      if execute_stmt(l_stmt)=false then
        null;
      end if;
    end if;
  end loop;
  l_stmt:='drop table '||g_bis_owner||'.'||g_dim_ilog;
  write_to_log_file(l_stmt);
  if execute_stmt(l_stmt)=false then
    null;
  end if;
  for i in 1..g_number_op_tables loop
    l_stmt:='drop table '||g_bis_owner||'.'||g_op_tables(i);
    write_to_log_file(l_stmt);
    if execute_stmt(l_stmt)=false then
      null;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  return false;
End;

procedure write_to_log_file(p_message varchar2) is
Begin
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(p_message);
Exception when others then
  null;
End;

function execute_stmt(p_stmt varchar2) return boolean is
Begin
  execute immediate p_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  return false;
End;

procedure init_all is
begin
 g_status:=true;
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

function read_fact_metadata(p_fact varchar2) return boolean is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_owner varchar2(400);
Begin
  g_bis_owner:=EDW_OWB_COLLECTION_UTIL.get_db_user('BIS');
  g_dim_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(p_fact);
  l_stmt:='select rel.name from edw_tables_md_v rel,edw_pvt_map_properties_md_v map,edw_facts_md_v tgt '||
  'where tgt.fact_name=:a and map.primary_target=tgt.fact_id '||
  'and rel.elementid=map.primary_source ';
  write_to_log_file(l_stmt);
  open cv for l_stmt using p_fact;
  fetch cv into g_fstg_table;
  close cv;
  g_fact_snplog :=EDW_OWB_COLLECTION_UTIL.get_table_snapshot_log(p_fact);
  g_fact_dlog:=EDW_OWB_COLLECTION_UTIL.get_log_for_table(p_fact,'Delete Log');
  if g_fact_dlog is null then
    g_fact_dlog:=g_bis_owner||'.'||substr(g_object_name,1,26)||'DLG';
  else
    l_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(g_fact_dlog);
    g_fact_dlog:=l_owner||'.'||g_fact_dlog;
  end if;
  g_fact_ilog:=g_bis_owner||'.'||substr(p_fact,1,26)||'OK';
  l_stmt:='select distinct cube_src.fact_id||''_''||cube.fact_id from edw_facts_md_v cube,edw_facts_md_v cube_src, '||
   'edw_pvt_map_properties_md_v map where map.primary_target=cube.fact_id and map.primary_source=cube_src.fact_id  '||
   'and cube_src.fact_name=:a';
  g_number_ilog:=1;
  write_to_log_file(l_stmt);
  open cv for l_stmt using p_fact;
  loop
    fetch cv into g_base_fact_ilog(g_number_ilog);
    exit when cv%notfound;
    g_number_ilog:=g_number_ilog+1;
  end loop;
  g_number_ilog:=g_number_ilog-1;
  close cv;
  for i in 1..g_number_ilog loop
    g_base_fact_dlog(i):=g_bis_owner||'.D'||g_base_fact_ilog(i);
    g_base_fact_ilog(i):=g_bis_owner||'.I'||g_base_fact_ilog(i);
  end loop;
  l_stmt:='select distinct cube_src.fact_id||''_''||cube.fact_id from edw_facts_md_v cube,edw_facts_md_v '||
  'cube_src, edw_pvt_map_properties_md_v map where map.primary_source=cube.fact_id and '||
  'map.primary_target=cube_src.fact_id  '||
  'and cube_src.fact_name=:a';
  g_derv_number_ilog:=1;
  write_to_log_file(l_stmt);
  open cv for l_stmt using p_fact;
  loop
    fetch cv into g_derv_fact_ilog(g_derv_number_ilog);
    exit when cv%notfound;
    g_derv_number_ilog:=g_derv_number_ilog+1;
  end loop;
  g_derv_number_ilog:=g_derv_number_ilog-1;
  close cv;
  for i in 1..g_derv_number_ilog loop
    g_derv_fact_dlog(i):=g_bis_owner||'.D'||g_derv_fact_ilog(i);
    g_derv_fact_ilog(i):=g_bis_owner||'.I'||g_derv_fact_ilog(i);
  end loop;

  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  return false;
End;

function clean_fact_objects return boolean is
l_stmt varchar2(10000);
l_count number;
Begin
  l_stmt:='truncate table '||g_dim_owner||'.'||g_object_name;
  write_to_log_file(l_stmt);
  if execute_stmt(l_stmt)=false then
    null;
  end if;
  if g_fact_snplog is not null then
    l_stmt:='truncate table '||g_dim_owner||'.'||g_fact_snplog;
    write_to_log_file(l_stmt);
    if execute_stmt(l_stmt)=false then
      null;
    end if;
  end if;
  if g_fact_dlog is not null then
    l_stmt:='truncate table '||g_fact_dlog;
    write_to_log_file(l_stmt);
    if execute_stmt(l_stmt)=false then
      null;
    end if;
  end if;
  l_stmt:='drop table '||g_fact_ilog;
  write_to_log_file(l_stmt);
  if execute_stmt(l_stmt)=false then
    null;
  end if;
  for i in 1..g_number_ilog loop
    l_stmt:='drop table '||g_base_fact_dlog(i);
    write_to_log_file(l_stmt);
    if execute_stmt(l_stmt)=false then
      null;
    end if;
    l_stmt:='drop table '||g_base_fact_ilog(i);
    write_to_log_file(l_stmt);
    if execute_stmt(l_stmt)=false then
      null;
    end if;
  end loop;
  for i in 1..g_derv_number_ilog loop
    l_stmt:='drop table '||g_derv_fact_dlog(i);
    write_to_log_file(l_stmt);
    if execute_stmt(l_stmt)=false then
      null;
    end if;
    l_stmt:='drop table '||g_derv_fact_ilog(i);
    write_to_log_file(l_stmt);
    if execute_stmt(l_stmt)=false then
      null;
    end if;
  end loop;
  if g_fstg_table is not null then
    if g_truncate_stg='Y' then
      l_stmt:='truncate table '||g_dim_owner||'.'||g_fstg_table;
      write_to_log_file(l_stmt);
      if execute_stmt(l_stmt)=false then
        null;
      end if;
    else
      l_stmt:='update '||g_fstg_table||' set collection_status=''READY'' where collection_status<>''READY'' '||
      ' and rownum<=100000';
      write_to_log_file(l_stmt);
      loop
        execute immediate l_stmt;
        l_count:=sql%rowcount;
        commit;
        if l_count <100000 then
          exit;
        end if;
      end loop;
    end if;
  end if;

  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  return false;
End;


function clean_up_fact(p_fact varchar2) return boolean is
Begin
  if read_fact_metadata(p_fact)=false then
    return false;
  end if;
  if clean_fact_objects=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  return false;
End;

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



END EDW_CLEAN_OBJECT;

/
