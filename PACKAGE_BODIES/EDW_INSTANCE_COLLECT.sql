--------------------------------------------------------
--  DDL for Package Body EDW_INSTANCE_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_INSTANCE_COLLECT" AS
/*$Header: EDWCINSB.pls 115.10 2003/11/06 00:55:38 vsurendr ship $*/

PROCEDURE COLLECT_DIMENSION(errbuf out NOCOPY varchar2, retcode out NOCOPY varchar2, p_dim_name varchar2) is
Begin
  g_collection_start_date:=sysdate;
  g_dim_name:=p_dim_name;
  retcode:=0;
  errbuf:=' ';
  if p_dim_name is null then
    errbuf:='No dimension name specified';
    retcode:=2;
    return;
  end if;
  EDW_OWB_COLLECTION_UTIL.init_all(p_dim_name,null,'bis.edw.collect');
  init_all;
  write_to_log_file_n('EDW_INSTANCE_COLLECT.Collect  for '||p_dim_name||get_time);
  make_insert_stmt;
  if g_status =false then
    errbuf:=g_status_message;
    retcode:=2;
    return_with_error;
    return;
  else
    write_to_log_file_n('Made insert stmt for dimension '||p_dim_name||get_time);
  end if;
  execute_insert_stmt;
  if g_status =false then
    errbuf:=g_status_message;
    retcode:=2;
    return_with_error;
    return;
  else
    write_to_log_file_n('Executed insert stmt for dimension '||p_dim_name||get_time);
    write_to_log_file_n('Finished moving data from edw_source_instances to edw_instance_lstg,
        rows inserted '||g_number_rows_processed);
  end if;
  --call the main procedure
  call_main_collection(errbuf,retcode);
  if g_status =false then
    g_status_message:='Error in calling main collection for dimension '||p_dim_name||get_time;
    write_to_log_file_n(g_status_message);
    errbuf:=g_status_message;
    retcode:=2;
    return_with_error;
    return;
  else
    write_to_log_file_n('Finished calling main collection for dimension '||p_dim_name||get_time);
  end if;
  return_with_success;
Exception when others then
  g_status_message:='Error in COLLECT Instance Dimension '||g_dim_name||' '||sqlerrm||get_time;
  write_to_log_file_n(g_status_message);
  errbuf:=g_status_message;
  retcode:=2;
  g_status:=false;
  return_with_error;
End;

procedure Init_all is
Begin
  g_status:=true;
  g_insert_stmt :=null;
  g_conc_program_id:=FND_GLOBAL.Conc_request_id;--my conc id
  g_number_rows_processed :=0;
  G_CONC_PROGRAM_NAME:=g_dim_name||'_T';
  g_object_type:='DIMENSION';
  g_status_message:='  ';
 if fnd_profile.value('EDW_DEBUG')='Y' then
   g_debug:=true;--look at the profile value for this
 else
   g_debug:=false;
 end if;
End;

procedure make_insert_stmt is
begin
 if g_debug then
   write_to_log_file_n('In make_insert_stmt');
 end if;
 g_insert_stmt:='insert into EDW_INSTANCE_LSTG (
	INSTANCE_CODE,
	INSTANCE_PK,
	INSTANCE_DP,
	NAME,
	ALL_FK,
	DESCRIPTION,
	COLLECTION_STATUS,
	WAREHOUSE_TO_INSTANCE_LINK,
	CREATION_DATE,
	LAST_UPDATE_DATE)
	select
	INSTANCE_CODE,
	INSTANCE_CODE,
	INSTANCE_CODE,
	NAME,
	''ALL'',
	DESCRIPTION,
	''READY'',
	WAREHOUSE_TO_INSTANCE_LINK,
	CREATION_DATE,
	LAST_UPDATE_DATE
	from
	EDW_SOURCE_INSTANCES_VL ';

Exception when others then
  g_status_message:='Error in make_insert_stmt for Instance Dimension '||g_dim_name||' '||sqlerrm||get_time;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;

procedure execute_insert_stmt is
Begin
 if g_debug then
   write_to_log_file_n('In execute_insert_stmt');
 end if;

 delete EDW_INSTANCE_LSTG;
 if g_debug then
    write_to_log_file_n('Going to execute ');
    write_to_log_file(g_insert_stmt);
 end if;
 execute immediate  g_insert_stmt;
 g_number_rows_processed:=sql%rowcount;
 write_to_log_file_n('Inserted '||g_number_rows_processed||' rows into EDW_INSTANCE_LSTG');
Exception when others then
  g_status_message:='Error in execute_insert_stmt for Instance Dimension '||sqlerrm||get_time;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;

procedure return_with_success is
begin
 --write_to_push_log(true);
 commit;
End;

procedure return_with_error is
begin
 rollback;
 --write_to_push_log(false);
End;

procedure call_main_collection(errbuf out NOCOPY varchar2, retcode out NOCOPY varchar2) is
Begin
  if g_debug then
    write_to_log_file_n('In call_main_collection, dim name is '||g_dim_name);
  end if;
  EDW_ALL_COLLECT.Collect_Dimension(errbuf,retcode,g_dim_name);
Exception when others then
  g_status_message:='Error in call_main_collection for Instance Dimension '||sqlerrm||get_time;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;

procedure write_to_push_log(p_flag boolean) is
l_stmt varchar2(10000);
begin
  if g_debug then
    if p_flag then
      write_to_log_file_n('In write_to_push_log, TRUE');
    else
      write_to_log_file_n('In write_to_push_log, FALSE');
    end if;
  end if;
End;--procedure write_to_publish_log


procedure write_to_log_file(p_message varchar2) is
begin
  EDW_OWB_COLLECTION_UTIL.write_to_log_file(p_message);
Exception when others then
  null;
End;

procedure write_to_log_file_n(p_message varchar2) is
begin
  write_to_log_file('  ');
  write_to_log_file(p_message);
Exception when others then
  null;
End;

function get_time return varchar2 is
begin
 return '  oo'||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS');
Exception when others then
  write_to_log_file_n('Exception in  get_time '||sqlerrm);
  return null;
End;


END EDW_INSTANCE_COLLECT;

/
