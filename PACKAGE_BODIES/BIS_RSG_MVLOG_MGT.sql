--------------------------------------------------------
--  DDL for Package Body BIS_RSG_MVLOG_MGT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RSG_MVLOG_MGT" AS
/*$Header: BISSNLMB.pls 120.0 2005/06/01 14:24:20 appldev noship $*/
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.7=120.0):~PROD:~PATH:~FILE

Procedure create_snp_log(Errbuf in out NOCOPY varchar2,
                         Retcode in out NOCOPY varchar2,
                         p_object_name in varchar2,
                         p_object_type in varchar2,
                         p_called_by in varchar2) is
begin
  null;
end;

/*
Procedure create_snp_log(Errbuf in out NOCOPY varchar2,
                         Retcode in out NOCOPY varchar2,
                         p_object_name in varchar2,
                         p_object_type in varchar2,
                         p_called_by in varchar2) is
cursor c_sql_stmt is
select
distinct
a.snapshot_log_sql,
a.FAST_REFRESH_FLAG,
a.object_name
from
bis_obj_properties a,
bis_obj_dependency e
where a.object_name=e.depend_object_name
and a.object_type=e.depend_object_type
and a.object_name=p_object_name
and a.object_type=p_object_type
and a.SNAPSHOT_LOG_SQL is not null;

cursor c_log_exist(p_master varchar2) is
select 'Y'
from dual
where exists (SELECT LOG_TABLE
	      from all_snapshot_logs
	      where master = p_master
	      AND log_owner IN (SELECT oracle_username
				FROM fnd_oracle_userid
				WHERE oracle_id BETWEEN 900 AND 999
				AND read_only_flag = 'U'))
     OR exists (SELECT logs.LOG_TABLE
	   from all_snapshot_logs logs, user_synonyms s
	   where logs.master = s.table_name
	   AND logs.log_owner = s.table_owner
	   AND s.synonym_name = p_master);




cursor c_mv is
SELECT MVIEW_NAME, OWNER
  FROM all_mviews
  WHERE MVIEW_NAME=p_object_name
  AND owner IN (SELECT oracle_username
		FROM fnd_oracle_userid
		WHERE oracle_id BETWEEN 900 AND 999
		AND read_only_flag = 'U')
UNION ALL
SELECT mview_name, owner
  FROM all_mviews mvs, user_synonyms s
  WHERE mvs.owner = s.table_owner
  AND mvs.mview_name = s.table_name
  AND mvs.mview_name = p_object_name;

l_sql_stmt_rec c_sql_stmt%rowtype;
l_sql varchar2(4000);
l_dummy varchar2(1);
l_mv_rec c_mv%rowtype;
l_log_created varchar2(1);

begin
 if p_called_by='RSG' then
   for l_sql_stmt_rec in c_sql_stmt loop
    l_log_created:='N';
    open  c_log_exist(l_sql_stmt_rec.object_name);
    fetch c_log_exist into l_dummy;
    if c_log_exist%notfound then
       write_log('Creating snapshot log because it doesn''t exist');
       write_log('executing '||l_sql_stmt_rec.snapshot_log_sql);
       if l_sql_stmt_rec.snapshot_log_sql is not null then
         execute immediate l_sql_stmt_rec.snapshot_log_sql;
         commit;
         l_log_created:='Y';
         write_log('Created snapshot log for object'||l_sql_stmt_rec.object_name);
       end if;
    else
        write_log('Snapshot log for '||l_sql_stmt_rec.object_name||' already exists. Not going to recreate');
    end if;---end if c_log_exist not found
    close c_log_exist;

    ---alter MV only when MV log is created by RSG
    if p_object_type='MV' and l_sql_stmt_rec.FAST_REFRESH_FLAG='Y' and l_log_created='Y' then
       for l_mv_rec in c_mv loop
         l_sql:='alter materialized view '||l_mv_rec.owner||'.'||l_mv_rec.mview_name|| ' refresh fast ';
         write_log('executing '||l_sql);
         execute immediate l_sql;
         commit;
          write_log('Altered MV '||l_mv_rec.owner||'.'||l_mv_rec.mview_name||' to be fast refresh ');
       end loop;
    end if;
  end loop;----end loop l_sql_stmt
*/
  /** The following code is commented out because full_refresh_complete is removed from design
  l_sql:='update bis_obj_properties set full_refresh_complete=''Y'' where object_name='||''''||p_object_name||''''||' and object_type='||''''||p_object_type||'''';
  write_log('executing '||l_sql);
  execute immediate l_sql;
  commit;
  write_log('Updated full_refresh_complete flag to ''Y''');
  **/
/*
 end if;---end if p_called_by='RSG'
 exception
  when others then
      Retcode:='2';
      Errbuf:=sqlerrm;
      write_log(sqlcode||' '||sqlerrm);
      return;
end;
*/

/** this concurrent program will not be delivered
----full_refresh_complete is removed from design
Procedure reset_complete_flag(Errbuf in out NOCOPY varchar2,
                         Retcode in out NOCOPY varchar2,
                         p_set_name in varchar2,
                         p_set_app in varchar2,
                         p_called_by in varchar2) is
cursor c_objects is
select
distinct
a.object_name,
a.object_type
from
bis_obj_prog_linkages a,
fnd_concurrent_programs b,
fnd_request_set_programs c,
fnd_request_sets d,
fnd_application e
where
a.CONC_APP_ID=b.application_id
and a.CONC_PROGRAM_NAME=b.CONCURRENT_PROGRAM_NAME
and b.APPLICATION_ID=c.PROGRAM_APPLICATION_ID
and b.CONCURRENT_PROGRAM_ID=c.CONCURRENT_PROGRAM_ID
and c.SET_APPLICATION_ID=d.application_id
and c.REQUEST_SET_ID=d.REQUEST_SET_ID
and d.REQUEST_SET_NAME=p_set_name
and d.application_id=e.application_id
and e.application_short_name=p_set_app;
l_object_rec c_objects%rowtype;
l_sql varchar2(4000);
begin
if p_called_by='RSG' then
  for l_object_rec in c_objects loop
   l_sql:='update bis_obj_properties set full_refresh_complete=''N'' where object_name='||''''||l_object_rec.object_name||''''||' and object_type='||''''||l_object_rec.object_type||'''';
   write_log('executing '||l_sql);
   execute immediate l_sql;
   commit;
   write_log('updated full_refresh_complete for '||l_object_rec.object_name);
  end loop;
end if;
exception
  when others then
      Retcode:='2';
      Errbuf:=sqlerrm;
      write_log(sqlcode||' '||sqlerrm);
      return;
end;
**/

PROCEDURE write_log(p_text in VARCHAR2) is
  l_len number;
 l_start number:=1;
 l_end number:=1;
 last_reached boolean:=false;
BEGIN
 if p_text is null or p_text='' then
   return;
 end if;
 l_len:=nvl(length(p_text),0);
 if l_len <=0 then
   return;
 end if;
 while true loop
  l_end:=l_start+250;
  if l_end >= l_len then
   l_end:=l_len;
   last_reached:=true;
  end if;
  FND_FILE.PUT_LINE(FND_FILE.LOG,substr(p_text, l_start, 250));
  l_start:=l_start+250;
  if last_reached then
   exit;
  end if;
 end loop;
END write_log;



END BIS_RSG_MVLOG_MGT;

/
