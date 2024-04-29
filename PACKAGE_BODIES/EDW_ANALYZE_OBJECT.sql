--------------------------------------------------------
--  DDL for Package Body EDW_ANALYZE_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_ANALYZE_OBJECT" AS
/*$Header: EDWANYZB.pls 115.6 2003/11/06 00:55:19 vsurendr noship $*/

procedure Analyze_Dimension(Errbuf out NOCOPY varchar2,Retcode out NOCOPY varchar2,
p_dim_name in varchar2,p_mode number) IS
Begin
  Retcode:='0';
  g_mode:=p_mode;
  if g_mode is null then
    g_mode:=0;--ltc and star 1 is lstg only
  end if;
  EDW_OWB_COLLECTION_UTIL.init_all('ANALYZE_OBJECTS',null,'bis.edw.analyze_object');
  EDW_OWB_COLLECTION_UTIL.set_debug(true);
  init_all;
  if analyze_dimension(p_dim_name)=false then
    Retcode:='2';
    Errbuf:=g_status_message;
    return;
  end if;
Exception when others then
  g_status_message:='Error in Analyze_Dimension '||sqlerrm;
  write_to_log_file_n(g_status_message);
  Retcode:='2';
  Errbuf:=g_status_message;
End;

procedure Analyze_Fact(Errbuf out NOCOPY varchar2,Retcode out NOCOPY varchar2,
p_fact_name in varchar2,p_mode number) IS
Begin
  Retcode:='0';
  g_mode:=p_mode;
  if g_mode is null then
    g_mode:=0;--fact 1 is fstg only
  end if;
  EDW_OWB_COLLECTION_UTIL.init_all('ANALYZE_OBJECTS',null,'bis.edw.analyze_object');
  EDW_OWB_COLLECTION_UTIL.set_debug(true);
  init_all;
  if analyze_fact(p_fact_name)=false then
    Retcode:='2';
    Errbuf:=g_status_message;
    return;
  end if;
Exception when others then
  g_status_message:='Error in Analyze_Fact '||sqlerrm;
  write_to_log_file_n(g_status_message);
  Retcode:='2';
  Errbuf:=g_status_message;
End;

function analyze_dimension(p_dim_name varchar2) return boolean is
Begin
  if get_dims(p_dim_name)=false then
    return false;
  end if;
  if g_mode=0 then
    if analyze_dims=false then
      return false;
    end if;
  else
    if analyze_dims_lstg=false then
      return false;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:='Error in analyze_dimension '||sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_dims(p_dim_name varchar2) return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  write_to_log_file_n('In get_dims');
  if p_dim_name is null then
    g_number_dim:=1;
    l_stmt:='select dim_name,dim_long_name from edw_dimensions_md_v';
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
    open cv for l_stmt;
    loop
      fetch cv into g_dim(g_number_dim),g_dim_long(g_number_dim);
      exit when cv%notfound;
      g_number_dim:=g_number_dim+1;
    end loop;
    g_number_dim:=g_number_dim-1;
    close cv;
  else
    g_number_dim:=1;
    l_stmt:='select dim_name from edw_dimensions_md_v where dim_long_name=:a';
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
    open cv for l_stmt using p_dim_name;
    fetch cv into g_dim(g_number_dim);
    close cv;
    g_dim_long(g_number_dim):=p_dim_name;
  end if;
  write_to_log_file_n('Dimensions to analyze ');
  for i in 1..g_number_dim loop
    write_to_log_file(g_dim_long(i)||'('||g_dim(i)||')');
  end loop;
  return true;
Exception when others then
  g_status_message:='Error in get_dims '||sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function analyze_dims return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_ltc EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_ltc_long EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_ltc_number number;
Begin
  write_to_log_file_n('In analyze_dims');
  for i in 1..g_number_dim loop
    write_to_log_file_n('Analyze '||g_dim(i)||' and ltc tables'||get_time);
    write_to_out_file_n('Analyze '||g_dim_long(i)||'('||g_dim(i)||')'||get_time);
    analyze_table(g_dim(i));
    l_stmt:='select ltc.name,ltc.long_name '||
    'from '||
    'edw_tables_md_v ltc, '||
    'edw_dimensions_md_v dim, '||
    'edw_levels_md_v lvl '||
    'where dim.dim_name=:a '||
    'and lvl.dim_id=dim.dim_id '||
    'and ltc.name=lvl.level_name||''_LTC''';
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
    l_ltc_number:=1;
    open cv for l_stmt using g_dim(i);
    loop
      fetch cv into l_ltc(l_ltc_number),l_ltc_long(l_ltc_number);
      exit when cv%notfound;
      l_ltc_number:=l_ltc_number+1;
    end loop;
    l_ltc_number:=l_ltc_number-1;
    write_to_log_file_n('LTC tables');
    for j in 1..l_ltc_number loop
      write_to_log_file(l_ltc_long(j)||'('||l_ltc(j)||')');
    end loop;
    for j in 1..l_ltc_number loop
      write_to_log_file_n('Analyze '||l_ltc(j)||get_time);
      write_to_out_file_n('Analyze '||l_ltc_long(j)||'('||l_ltc(j)||')'||get_time);
      analyze_table(l_ltc(j));
    end loop;
  end loop;
  return true;
Exception when others then
  g_status_message:='Error in analyze_dims '||sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function analyze_dims_lstg return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_lstg EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_lstg_long EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_lstg_number number;
Begin
  for i in 1..g_number_dim loop
    l_stmt:='select lstg.name,lstg.long_name '||
    'from '||
    'edw_tables_md_v ltc, '||
    'edw_tables_md_v lstg, '||
    'edw_pvt_map_properties_md_v map, '||
    'edw_dimensions_md_v dim, '||
    'edw_levels_md_v lvl '||
    'where dim.dim_name=:a '||
    'and lvl.dim_id=dim.dim_id '||
    'and ltc.name=lvl.level_name||''_LTC'' '||
    'and map.primary_target=ltc.elementid '||
    'and lstg.elementid=map.primary_source ';
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
    l_lstg_number:=1;
    open cv for l_stmt using g_dim(i);
    loop
      fetch cv into l_lstg(l_lstg_number),l_lstg_long(l_lstg_number);
      exit when cv%notfound;
      l_lstg_number:=l_lstg_number+1;
    end loop;
    l_lstg_number:=l_lstg_number-1;
    write_to_log_file_n('lstg tables');
    for j in 1..l_lstg_number loop
      write_to_log_file(l_lstg_long(j)||'('||l_lstg(j)||')');
    end loop;
    for j in 1..l_lstg_number loop
      write_to_log_file_n('Analyze '||l_lstg(j)||get_time);
      write_to_out_file_n('Analyze '||l_lstg_long(j)||'('||l_lstg(j)||')'||get_time);
      analyze_table(l_lstg(j));
    end loop;
  end loop;
  return true;
Exception when others then
  g_status_message:='Error in analyze_dims_lstg '||sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function analyze_fact(p_fact_name varchar2) return boolean is
Begin
  if get_facts(p_fact_name)=false then
    return false;
  end if;
  if g_mode=0 then
    if analyze_facts=false then
      return false;
    end if;
  else
    if analyze_facts_fstg=false then
      return false;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:='Error in analyze_fact '||sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_facts(p_fact_name varchar2) return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  write_to_log_file_n('In get_facts');
  if p_fact_name is null then
    g_number_fact:=1;
    l_stmt:='select fact_name,fact_longname from edw_facts_md_v';
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
    open cv for l_stmt;
    loop
      fetch cv into g_fact(g_number_fact),g_fact_long(g_number_fact);
      exit when cv%notfound;
      g_number_fact:=g_number_fact+1;
    end loop;
    g_number_fact:=g_number_fact-1;
    close cv;
  else
    g_number_fact:=1;
    l_stmt:='select fact_name from edw_facts_md_v where fact_longname=:a';
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
    open cv for l_stmt using p_fact_name;
    fetch cv into g_fact(g_number_fact);
    close cv;
    g_fact_long(g_number_fact):=p_fact_name;
  end if;
  write_to_log_file_n('Facts to analyze ');
  for i in 1..g_number_fact loop
    write_to_log_file(g_fact_long(i)||'('||g_fact(i)||')');
  end loop;
  return true;
Exception when others then
  g_status_message:='Error in get_facts '||sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function analyze_facts return boolean is
Begin
  write_to_log_file_n('In analyze_facts');
  for i in 1..g_number_fact loop
    write_to_log_file_n('Analyze '||g_fact(i)||get_time);
    write_to_out_file_n('Analyze '||g_fact_long(i)||'('||g_fact(i)||')'||get_time);
    analyze_table(g_fact(i));
  end loop;
  return true;
Exception when others then
  g_status_message:='Error in analyze_facts '||sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function analyze_facts_fstg return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_fstg varchar2(200);
l_fstg_long varchar2(400);
Begin
  write_to_log_file_n('In analyze_facts_fstg');
  for i in 1..g_number_fact loop
    l_stmt:='select fstg.name,fstg.long_name '||
    'from '||
    'edw_tables_md_v fstg, '||
    'edw_pvt_map_properties_md_v map, '||
    'edw_facts_md_v fact '||
    'where '||
    'fact.fact_name=:a '||
    'and map.primary_target=fact.fact_id '||
    'and fstg.elementid=map.primary_source ';
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
    open cv for l_stmt using g_fact(i);
    fetch cv into l_fstg,l_fstg_long;
    write_to_log_file_n('Analyze '||l_fstg||get_time);
    write_to_out_file_n('Analyze '||l_fstg_long||'('||l_fstg||')'||get_time);
    analyze_table(l_fstg);
  end loop;
  return true;
Exception when others then
  g_status_message:='Error in analyze_facts_fstg '||sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;


procedure analyze_table(p_object varchar2) is
Begin
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(p_object);
Exception when others then
  write_to_log_file_n('Error in analyze_table '||sqlerrm);
End;


procedure init_all is
Begin
  g_number_dim:=0;
  g_number_fact:=0;
  g_parallel:=fnd_profile.value('EDW_PARALLEL');
  write_to_log_file_n('g_parallel='||g_parallel);
  EDW_OWB_COLLECTION_UTIL.set_parallel(g_parallel);
Exception when others then
  g_status:=false;
  g_status_message:='Error in init_all '||sqlerrm;
  write_to_log_file_n(g_status_message);
End;

function get_time return varchar2 is
begin
 return ' '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS');
Exception when others then
  write_to_log_file_n('Exception in  get_time '||sqlerrm);
  return null;
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

procedure write_to_out_file(p_message varchar2) is
begin
  EDW_OWB_COLLECTION_UTIL.write_to_out_file(p_message);
Exception when others then
  null;
End;

procedure write_to_out_file_n(p_message varchar2) is
begin
  write_to_out_file('  ');
  write_to_out_file(p_message);
Exception when others then
  null;
End;

END EDW_ANALYZE_OBJECT;

/
