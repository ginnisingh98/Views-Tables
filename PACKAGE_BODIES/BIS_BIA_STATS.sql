--------------------------------------------------------
--  DDL for Package Body BIS_BIA_STATS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BIA_STATS" AS
/*$Header: BISGTSPB.pls 120.2 2006/09/07 14:34:46 aguwalan noship $*/

/**
* This is the wrapper around FND_STATS.gather_table_stats
* Object name will be the table name or MV name seeded in RSG,
* while object type is either 'MV' or 'TABLE'
* We will derive the object schema name , then
* call FND_STATS.gather_table_stats to analyze the object
**/

/**Changes for Enhancement 4378448. We have to review/rollback
the changes after ST fix the issue as mentioned in the enhancement.
Changes made:
 Call FND_STATS.SET_TABLE_STATS for the MV log if num_rows in all_tables
 for this log <>0. Otherwise, not to call FND_STATS.SET_TABLE_STATS for the MV log.
**/

procedure GATHER_TABLE_STATS(errbuf out NOCOPY varchar2,
                             retcode out NOCOPY varchar2,
							 objecttype in varchar2,
                             objectname  in varchar2,
                             percent  in number default null,
                             degree in number default null,
                             partname in varchar2 default null,
                             backup_flag in varchar2 default 'NOBACKUP',
                             granularity  in varchar2 default 'DEFAULT',
                              hmode in varchar2 default 'LASTRUN',
                              invalidate    in varchar2 default 'Y'
                            ) is
l_object_owner varchar2(30);
l_object_log varchar2(30);
l_request_id number;
l_root_request_id number;
l_stage_request_id number;
l_num_rows number;
begin
  l_request_id:=fnd_global.CONC_REQUEST_ID ;
  l_root_request_id:=FND_GLOBAL.CONC_PRIORITY_REQUEST;

  bis_collection_utilities.put_line('request id: '||l_request_id);

  begin
   l_object_owner:=bis_create_requestset.get_object_owner(objectname,objecttype);
   l_object_log:=bis_create_requestset.get_mv_log(objectname,l_object_owner);
    bis_collection_utilities.put_line('schema for '||objectname||':'||l_object_owner);
   bis_collection_utilities.put_line('MV log  for '||objectname||':'||l_object_log );
   exception
    when others then
      bis_collection_utilities.put_line('Error happened when get object schema and object mv log'||sqlcode||sqlerrm);
      raise;
  end;


   if nvl(l_object_owner,'NOTFOUND')<>'NOTFOUND' then
    begin
      bis_collection_utilities.put_line('Calling FND_STATS.GATHER_TABLE_STATS for object '||l_object_owner||','||objectname);
      FND_STATS.GATHER_TABLE_STATS(errbuf =>errbuf,
                             retcode =>retcode,
                             ownname =>l_object_owner,
                             tabname =>objectname,
                             percent =>percent,
                             degree  =>degree,
                             partname =>partname,
                             backup_flag =>backup_flag,
                             granularity =>granularity,
                              hmode =>hmode,
                              invalidate=>invalidate
                             );
    bis_collection_utilities.put_line(l_object_owner||','||objectname||' has been analyzed successfully');
  exception
   when others then
      bis_collection_utilities.put_line('Error happened inside FND_STATS.GATHER_TABLE_STATS '||sqlcode||sqlerrm);
      raise;
  end;
 end if;

  if l_object_log is not null then
   begin
    select num_rows
    into l_num_rows
    from all_tables
    where owner=l_object_owner
    and table_name=l_object_log;
   exception
    when no_data_found then
       l_num_rows:=0;
    when others then
      raise;
   end;
  end if;

  if l_object_log is not null and l_num_rows=0 then
         bis_collection_utilities.put_line('Not to call FND_STATS.SET_TABLE_STATS for '||l_object_owner||'.'||l_object_log||' because num_rows in all_tables for this MV log is already 0');
  end if;

  if l_object_log is not null and l_num_rows<>0  then
   begin
     bis_collection_utilities.put_line('Calling FND_STATS.SET_TABLE_STATS for object log '||l_object_owner||','||l_object_log);
      FND_STATS.SET_TABLE_STATS(OWNNAME=>l_object_owner,
                                TABNAME=>l_object_log,
                                NUMROWS=>0,
                                NUMBLKS=>0,
                                AVGRLEN=>0);
     bis_collection_utilities.put_line(l_object_owner||','||l_object_log||' statistics has been set successfully');
  exception
    when others then
      bis_collection_utilities.put_line('Error happened inside FND_STATS.SET_TABLE_STATS '||sqlcode||sqlerrm);
  raise;
  end;
 end if;
 --Enh#4418520-aguwalan
 IF(BIS_CREATE_REQUESTSET.is_history_collect_on(l_root_request_id)) THEN
   begin
     bis_collection_utilities.put_line('Calling BIS_COLL_RS_HISTORY.insert_program_object_data ');
     if nvl(l_object_owner,'NOTFOUND')<>'NOTFOUND' then
       BIS_COLL_RS_HISTORY.insert_program_object_data
                                     (x_request_id  => l_request_id,
                                     x_stage_req_id  =>null,
                                     x_object_name   =>objectname,
                                     x_object_type   =>objecttype,
                                     x_refresh_type  =>'ANALYZED',
                                     x_set_request_id =>l_root_request_id);
     end if;

     if l_object_log is not null and l_num_rows<>0 then
       BIS_COLL_RS_HISTORY.insert_program_object_data
                                     (x_request_id  => l_request_id,
                                     x_stage_req_id  =>null,
                                     x_object_name   =>l_object_log,
                                     x_object_type   =>'MV_LOG',
                                     x_refresh_type  =>'ANALYZED',
                                     x_set_request_id =>l_root_request_id);
     end if;

     bis_collection_utilities.put_line('Called BIS_COLL_RS_HISTORY.insert_program_object_data');
   exception
     when others then
       bis_collection_utilities.put_line('Error happened in BIS_COLL_RS_HISTORY.insert_program_object_data'||sqlcode||sqlerrm);
       raise;
   end;
  ELSE
    BIS_COLLECTION_UTILITIES.put_line('------------------------------------------------------------------');
    BIS_COLLECTION_UTILITIES.put_line('Request Set History Collection Option is off for this Request Set.');
    BIS_COLLECTION_UTILITIES.put_line('No History Collection will happen for this request set.');
    BIS_COLLECTION_UTILITIES.put_line('------------------------------------------------------------------');
  END IF;

exception
 when others then
  raise;

end;
END BIS_BIA_STATS;


/
