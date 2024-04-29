--------------------------------------------------------
--  DDL for Package Body BIS_BIA_RSG_LOG_MGMNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BIA_RSG_LOG_MGMNT" AS
/*$Header: BISBRLMB.pls 120.4 2006/05/09 13:47:43 aguwalan noship $*/

  PROCEDURE WRITELOG(P_TEXT VARCHAR2)
  IS
  BEGIN
    --FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, 'Bis.BIS_BIA_RSG_LOG_MGMNT', P_TEXT);
    BIS_COLLECTION_UTILITIES.put_line(P_TEXT);
 ---   dbms_output.put_line(substr(P_TEXT,1,250));
  END;

  FUNCTION duration(
	p_duration		number) return VARCHAR2 IS
  BEGIN
    return(to_char(floor(p_duration)) ||' Days '||
           to_char(mod(floor(p_duration*24), 24))||':'||
           to_char(mod(floor(p_duration*24*60), 60))||':'||
           to_char(mod(floor(p_duration*24*60*60), 60)));
  END duration;

  PROCEDURE setTimer(
    p_log_timstamp in out NOCOPY date)
  IS
  BEGIN
    p_log_timstamp := sysdate;
  END;


  PROCEDURE logTime(
    p_process        varchar2,
    p_log_timstamp   date)
  IS
    l_duration     number := null;
  BEGIN
    l_duration := sysdate - p_log_timstamp;
    WRITELOG('Process Time for '|| p_process || ' : ' || duration(l_duration));
  END;

  Function form_triplet( att1 varchar2,
                       att2 varchar2,
                       att3 varchar2  ) return varchar2
  IS
    l_result varchar2(32767) := '( ';
  BEGIN
    l_result := l_result || att1 || ', ' || att2 || ', ' || att3 || ') ';
    return l_result;
  END;


  Function is_mv_log_mangmnt_enabled
  return boolean
  is
  begin
    IF (fnd_profile.value('BIS_BIA_MVLOG_ENABLE') = 'Y') THEN
     return true;
    ELSE
     WRITELOG('Runtime BIA MV Log Management feature is off');
     return false;
    END IF;
  end;


PROCEDURE MV_LOG_API (
    ERRBUF              OUT NOCOPY VARCHAR2,
    RETCODE                 OUT NOCOPY VARCHAR2,
    P_API               IN      VARCHAR2,
    P_OBJ_NAME      IN  VARCHAR2,
    P_OBJ_TYPE      IN  VARCHAR2,
    P_MODE          IN  VARCHAR2
) IS
  l_parameter_tbl   BIS_BIA_RSG_PARAMETER_TBL := BIS_BIA_RSG_PARAMETER_TBL();
BEGIN
   BIS_BIA_RSG_CUSTOM_API_MGMNT.INVOKE_CUSTOM_API(
    ERRBUF, RETCODE,
    P_API, BIS_BIA_RSG_CUSTOM_API_MGMNT.TYPE_MV_LOG_MGT,
    P_OBJ_NAME, P_OBJ_TYPE, P_MODE);

END MV_LOG_API;


procedure build_statement
           (ddl_text in varchar2,
            row_num  in integer)
is
begin
  apps_array_ddl.glprogtext(row_num) := ddl_text;
exception
  when others then
    WRITELOG('error in build_statement('||ddl_text||', '||row_num||')');
    raise;
end build_statement;


procedure update_mv_log_sql(p_base_object_name in varchar2,
                            p_base_object_type in varchar2,
                            p_snapshot_log_sql in CLOB) is
begin
 update bis_obj_properties set snapshot_log_sql= p_snapshot_log_sql
 where object_name=p_base_object_name
 and object_type=p_base_object_type;
 commit;
 exception
  when others then
   raise;
end;


procedure update_mv_log_status(p_base_object_name in varchar2,
                            p_base_object_type in varchar2,
                            p_status  in varchar2) is
begin
 update bis_obj_properties
 set mv_log_status=p_status,
 status_time_stamp=sysdate
 where object_name=p_base_object_name
 and object_type=p_base_object_type;
 commit;
 exception
  when others then
   raise;
end;

function get_mv_creation_date_dd (p_base_object_name in varchar2,p_base_object_type in varchar2,p_base_object_schema in varchar2) return date is
cursor c_mv_creation_date_in_DD is
 SELECT created  mv_creation_date_dd
   FROM all_objects
   WHERE owner=p_base_object_schema
   and object_name = p_base_object_name
   and object_type=decode(p_base_object_type,'TABLE','TABLE','MV','MATERIALIZED VIEW') ;
l_date date;
begin
  open c_mv_creation_date_in_DD;
  fetch c_mv_creation_date_in_DD into l_date;
  close c_mv_creation_date_in_DD;
  return l_date;
 exception
   when others then
    raise;
end;

---this API check if  MV patch has been applied after
---last time the MV log being captured/dropped/created
----please note that this API can't handle MV logs attached to
---base summary tables, which are currently managed by individual
---product teams by calling BIA custom API

function check_obj_patch_applied(p_base_object_name in varchar2,p_base_object_type in varchar2) return varchar2 is

cursor c_mv_patch_applied is
 SELECT af.filename filename
       , MAX(acf.creation_date) file_creation_date
 FROM ad_check_files acf
      , ad_files af
 WHERE af.file_id = acf.file_id
       AND (
           filename =p_base_object_name || '.xdf'
        OR filename = LOWER(p_base_object_name) || '.xdf'
           )
        and acf.creation_date>
		 (select STATUS_TIME_STAMP
		   from bis_obj_properties
		   where object_name=upper(p_base_object_name)
		   and object_type=p_base_object_type)
 GROUP BY af.filename;

cursor c_log_patch_applied is
 SELECT af.filename filename
       , MAX(acf.creation_date) file_creation_date
 FROM ad_check_files acf
      , ad_files af
 WHERE af.file_id = acf.file_id
       AND (
           filename =upper(p_base_object_name)||'_MLOG' || '.xdf'
        OR filename = LOWER(p_base_object_name)||'_mlog'|| '.xdf'
           )
        and acf.creation_date>
		 (select STATUS_TIME_STAMP
		   from bis_obj_properties
		   where object_name=upper(p_base_object_name)
		   and object_type=p_base_object_type)
 GROUP BY af.filename;


l_file_name varchar2(100);
l_file_creation_date date;

begin
 if p_base_object_type='MV' then
  open c_mv_patch_applied;
  fetch c_mv_patch_applied into l_file_name,l_file_creation_date;
  close c_mv_patch_applied;
 else --'TABLE'
  open c_log_patch_applied;
  fetch c_log_patch_applied into l_file_name,l_file_creation_date;
  close c_log_patch_applied;
 end if;


  if l_file_name is not null and l_file_creation_date is not null then
    WRITELOG('Found patch being applied. File Name: '||l_file_name||'. File creation date '||to_char(l_file_creation_date,'DD-MON-YYYY HH24:MI:SS'));
    return 'Y';
  else
     return 'N';
  end if;
 exception
   when others then
    raise;
end;

---this api check if MV has been recreated after last
---time the MV log being captured
function check_obj_recreated (p_base_object_name in varchar2,p_base_object_type in varchar2,P_base_object_schema in varchar2) return varchar2 is

cursor c_mv_creation_date_in_rsg is
select OBJECT_CREATION_DATE
from bis_obj_properties
where object_name=p_base_object_name
and object_type=p_base_object_type;

l_mv_creation_date_dd date;
l_mv_creation_date_rsg date;

begin
 l_mv_creation_date_dd:=get_mv_creation_date_dd(p_base_object_name,p_base_object_type,p_base_object_schema);

 open c_mv_creation_date_in_rsg;
 fetch c_mv_creation_date_in_rsg into l_mv_creation_date_rsg;
 close c_mv_creation_date_in_rsg;

 WRITELOG('MV creation date in data dictionary '||to_char(l_mv_creation_date_dd,'DD-MON-YYYY HH24:MI:SS'));
 WRITELOG('MV creation date captured in RSG '||to_char(l_mv_creation_date_rsg,'DD-MON-YYYY HH24:MI:SS'));
 if  l_mv_creation_date_dd>l_mv_creation_date_rsg then
   return 'Y';
 else
   return 'N';
 end if;
 exception
  when others then
    raise;
end;


procedure update_obj_creation_date(p_base_object_name in varchar2,p_base_object_type in varchar2,p_base_object_schema in varchar2) is

begin
  update bis_obj_properties
  set OBJECT_CREATION_DATE=get_mv_creation_date_dd(p_base_object_name,p_base_object_type,p_base_object_schema)
  where object_type=p_base_object_type
  and object_name=p_base_object_name;

 exception
   when others then
    raise;
end;

/*
 *  Function to return the name of the MV Log if any on a given MV,
 *  returns NULL otherwise
 */
FUNCTION get_mview_log_name(p_mview_name IN VARCHAR2, p_object_schema IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR get_log_table IS
    SELECT log_table
    FROM All_SNAPSHOT_LOGS LOG
    WHERE log.master = p_mview_name
    AND log_owner = p_object_schema;
  log_table_name VARCHAR2(30);
BEGIN
  log_table_name := NULL;
  OPEN get_log_table;
  FETCH get_log_table INTO log_table_name;
  CLOSE get_log_table;
  RETURN log_table_name;
  EXCEPTION WHEN OTHERS THEN
    WRITELOG('Exception : get_mview_log_name ' || form_triplet(p_mview_name, p_object_schema, 'MVLog') );
    raise;
END;

--AGUWALAN :: bug#4898446 :: api to capture Indexes on MVs
procedure capture_mv_log_index(p_mv_log_name in varchar2,
                               P_mv_log_schema in varchar2)
IS
  l_stmt VARCHAR2(1000);
  TYPE curType IS REF CURSOR ;
  c_mv_log_index curType;
  l_index_name VARCHAR2(30);
  l_schema VARCHAR2(30);
  l_ddl CLOB;
  l_count NUMBER;
begin
  l_count := 0;
  l_stmt := 'SELECT INDEX_NAME, OWNER, TO_CHAR(sys.ad_dbms_metadata.GET_DDL(''INDEX'',INDEX_NAME,OWNER)) FROM '||
    '(select index_name , OWNER from all_indexes where table_name = :1 and owner = :2)';

  open c_mv_log_index for l_stmt USING p_mv_log_name, p_mv_log_schema;
  loop
    fetch c_mv_log_index into l_index_name, l_schema, l_ddl;
    exit when c_mv_log_index%NOTFOUND;

    if l_ddl is not null or l_ddl <> '' then
      l_count := l_count+1;
      update bis_obj_indexes  set  INDEX_SQL = l_ddl,  LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.User_id,  LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID where OBJECT_NAME=p_mv_log_name and OBJECT_TYPE='MVLOG' and INDEX_NAME=l_index_name;
      IF SQL%NOTFOUND THEN
        INSERT INTO bis_obj_indexes( OBJECT_NAME, OBJECT_TYPE, INDEX_NAME, INDEX_SQL, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
        values(p_mv_log_name, 'MVLOG', l_index_name, l_ddl, sysdate, FND_GLOBAL.User_id, sysdate, FND_GLOBAL.User_id, fnd_global.LOGIN_ID);
      END IF;
      COMMIT;
      WRITELOG('Captured Index '|| l_index_name || ' on MVLog ' || form_triplet(p_mv_log_name, P_mv_log_schema, 'MVLog') );
    end if;
  end loop;
  close c_mv_log_index;
  if (l_count = 0) then
    WRITELOG('No Index captured on MVLog ' || form_triplet(p_mv_log_name, P_mv_log_schema, 'MVLog') );
  else
    WRITELOG(to_char(l_count)||' Index(s) captured on MVLog ' || form_triplet(p_mv_log_name, P_mv_log_schema, 'MVLog') );
  end if;
end;

function capture_mv_log_sql(p_base_object_name in varchar2,
                             P_base_object_schema in varchar2,
                             P_base_object_type in varchar2)

RETURN NUMBER
IS
  l_snapshot_log_sql_handle clob := null;
  l_time date;
  l_length number := 0;
  --bug#4704403
  l_stmt varchar2(1000) := 'BEGIN
  :snapshot_log_sql_handle := sys.ad_dbms_metadata.get_dependent_ddl(
    ''MATERIALIZED_VIEW_LOG'',
    :p_base_object_name,
    :p_base_object_schema
    ); END;
  ';
  cursor c_obj_properties is
   select snapshot_log_sql,mv_log_status
   from bis_obj_properties
   where object_name=p_base_object_name
   and object_type=P_base_object_type;

   cursor log_exist is
     select 'Y'
    from dual
    where exists(
    select log_table
    from all_snapshot_logs
    where master=p_base_object_name
   and log_owner=p_base_object_schema);

  l_mv_log_status bis_obj_properties.mv_log_status%type;
  l_mv_log_sql_stored bis_obj_properties.snapshot_log_sql%type;
  l_program_status boolean:=true;
  l_log_exist varchar2(1);
  l_mv_log_name  VARCHAR2(30);

BEGIN

  open log_exist;
  fetch log_exist into l_log_exist;
  close log_exist;

  setTimer(l_time);

  WRITELOG('Capturing MV log for ' || form_triplet(p_base_object_name, P_base_object_schema, P_base_object_type) );
  if l_log_exist='Y' then
    execute immediate l_stmt
     using OUT l_snapshot_log_sql_handle, IN p_base_object_name, IN P_base_object_schema;
  end if;

  open c_obj_properties;
  fetch c_obj_properties into l_mv_log_sql_stored,l_mv_log_status;
  close   c_obj_properties;

  l_length := DBMS_LOB.getlength(l_snapshot_log_sql_handle);

  if (nvl(l_log_exist,'N')<>'Y' or l_snapshot_log_sql_handle is null or
      l_length = 0 ) then
    WRITELOG('No MV Log found for this object');

    if l_mv_log_sql_stored is null then
       ---either because first time capture or because last captured log is null
       ---the corresponding log status column in RSG is either null or 'NOLOG'
        update_mv_log_status(p_base_object_name ,
                            p_base_object_type ,
                            'NOLOG') ;
        WRITELOG('MV log definition for this object in RSG is also null. Only update status to ''NOLOG''');
    else ---RSG stored mv log is not null
        if l_mv_log_status='RECREATED' then
                 ---MV log had been recreated successfully
				 ---We can conclude that mv log is dropped by patch
                 ---So wipe out the mv log definition stored in RSG
		         update_mv_log_sql(p_base_object_name ,
                       p_base_object_type,
                       l_snapshot_log_sql_handle);

                 update_mv_log_status(p_base_object_name ,
                          p_base_object_type ,
                            'NOLOG') ;
           		 WRITELOG('Wipe out MV log definition in RSG because patch dropped mv log after it had been recreated by RSG. Set status to ''NOLOG''');
                 -- aguwalan: bug#4898446
                 l_mv_log_name := get_mview_log_name(p_base_object_name, P_base_object_schema);
                 DELETE bis_obj_indexes where OBJECT_NAME=l_mv_log_name and OBJECT_TYPE='MVLOG';
                 WRITELOG('Also wiped out definition of Indexes(if any) on the MV log.');
         else ---other status 'DROPPED','CAPTURED'

            ----We need to identify if the mv log is dropped by RSG or patch
            ----before we decide to wipe out mv log definition in RSG or not
            if check_obj_patch_applied(p_base_object_name,p_base_object_type)='Y' then
               if check_obj_recreated (p_base_object_name,p_base_object_type,P_base_object_schema) ='Y' then
                  ---we can conclude that mv log is dropped by patch after last failed run
                  ---so wipe out the mv log definition stored in RSG
                  ---please note that this should be a corner case
                  ---According to BISREL, customer should not apply any patch
                  ---if the last run is not successful
  		           update_mv_log_sql(p_base_object_name ,
                         p_base_object_type,
                         l_snapshot_log_sql_handle);

                   update_mv_log_status(p_base_object_name ,
                          p_base_object_type ,
                             'NOLOG') ;
            	   WRITELOG('Wipe out MV log definition in RSG because patch dropped mv log after last failed run. Set status to ''NOLOG''');
                   -- aguwalan: bug#4898446
                   l_mv_log_name := get_mview_log_name(p_base_object_name, P_base_object_schema);
                   DELETE bis_obj_indexes where OBJECT_NAME=l_mv_log_name and OBJECT_TYPE='MVLOG';
            	   WRITELOG('Also wiped out definition of Indexes(if any) on MV log.');
               else
			      --though mv patch being applied but not sure if the MV log is dropped by patch
				  ---report warning and keep MV log definition in RSG
			        update_mv_log_status(p_base_object_name ,
                           p_base_object_type ,
                           'NOT_OVERWRITE_WITH_NULL') ;
                    WRITELOG('Keep MV log definition in RSG because we are not sure if the mv log is dropped by RSG or by patch');
                    WRITELOG('Set status to ''NOT_OVERWRITE_WITH_NULL''');
                    WRITELOG ('Report this as warning. Please contact system administrator');
                    WRITELOG ('If the log is dropped by patch, MV log definition stored in RSG should be cleaned up by system administrator manually');
                    l_program_status := fnd_concurrent.set_completion_status('WARNING' ,NULL);

               end if; ---end if check_mv_recreated

            else
               ----we can conclude that MV log is dropped by RSG. So keep mv log definition
               ----in RSG.
                   update_mv_log_status(
				          p_base_object_name ,
                          p_base_object_type ,
                          'NOT_OVERWRITE_WITH_NULL') ;
                   WRITELOG('Keep MV log definition in RSG because the mv log is dropped by RSG');
                   WRITELOG('Set status to ''NOT_OVERWRITE_WITH_NULL''');
            end if; --end if mv patch being applied
        end if; ---end if mv log status is 'RECREATED'

    end if; ---end if rsg stored mv log is null

  else  ---captured MV log not null
     WRITELOG('MV Log length: ' || l_length);
     update_mv_log_sql(p_base_object_name ,
                       p_base_object_type,
                       l_snapshot_log_sql_handle);

     update_mv_log_status(p_base_object_name ,
                          p_base_object_type ,
                            'CAPTURED') ;

     WRITELOG('Captured MV log definition for '|| form_triplet(p_base_object_name, P_base_object_schema, P_base_object_type) || 'is not null');
	 WRITELOG('Update BIS_OBJ_PROPERTIES TABLE with captured MV log definition');
     -- aguwalan: bug#4898446 :Capture Index(if any) on MVLog
     l_mv_log_name := get_mview_log_name(p_base_object_name, P_base_object_schema);
     WRITELOG('Capturing Index on MV log '|| form_triplet(l_mv_log_name, P_base_object_schema, 'MVLog'));
     capture_mv_log_index(l_mv_log_name, P_base_object_schema);
  end if;  ---end if captured MV log is null or not

  logTime( 'Capturing MV Log for ' || form_triplet(p_base_object_name, P_base_object_schema, P_base_object_type) , l_time);

  update_obj_creation_date(p_base_object_name,p_base_object_type,p_base_object_schema);

  WRITELOG('************************************');
  return l_length;
EXCEPTION WHEN OTHERS THEN
    WRITELOG('Failed capturing MV Log for ' ||  form_triplet(p_base_object_name, P_base_object_schema, P_base_object_type) || ', ' ||sqlerrm);
    raise;
END;

PROCEDURE drop_mv_log(p_base_object_name in varchar2,
                      P_base_object_schema in varchar2)
IS
  l_time date;
  l_dur  number;
  l_stmt varchar2(1000) := 'DROP MATERIALIZED VIEW LOG ON ' || P_base_object_schema || '.' ||
     p_base_object_name;

BEGIN
  setTimer(l_time);
  WRITELOG('Executing ' || l_stmt);
  execute immediate l_stmt;
  logTime( 'Dropping mv log of ' || form_triplet(p_base_object_name, P_base_object_schema, null) , l_time);
  WRITELOG('************************************');
EXCEPTION WHEN OTHERS THEN
    WRITELOG('Failed droping ' ||  P_base_object_schema || '.' ||
     p_base_object_name || sqlerrm);
    raise;
END;

PROCEDURE capture_and_drop_log_by_name (
    P_OBJ_NAME      IN 	VARCHAR2,
    P_OBJ_TYPE      IN 	VARCHAR2,
    P_OBJ_OWNER     IN 	VARCHAR2
) IS
    l_length number;
BEGIN
    l_length:= capture_mv_log_sql(P_OBJ_NAME, P_OBJ_OWNER, P_OBJ_TYPE);
    if (l_length >0 ) then
        drop_mv_log(P_OBJ_NAME,P_OBJ_OWNER);
        update_mv_log_status(P_OBJ_NAME ,
                            P_OBJ_TYPE ,
                            'DROPPED') ;
    end if;
EXCEPTION WHEN OTHERS THEN
    WRITELOG('Error happened while capturing/dropping mv log for '
              || form_triplet(P_OBJ_NAME, P_OBJ_OWNER, P_OBJ_TYPE));
    RAISE;
END;

--aguwalan :: bug#4898446 :: api to recreate Indexes on MV Logs
PROCEDURE recreate_mv_log_index(p_mv_log_name in varchar2,
                        P_mv_log_schema in varchar2)
IS
  l_stmt VARCHAR2(1000);
  TYPE curType IS REF CURSOR ;
  c_mv_log_index curType;
  l_index_name VARCHAR2(30);
  l_schema VARCHAR2(30);
  l_index_ddl VARCHAR2(32767);
  temp_index_ddl VARCHAR2(32767);
  l_count NUMBER;
BEGIN
  l_stmt := 'select INDEX_NAME, INDEX_SQL from BIS_OBJ_INDEXES where OBJECT_NAME='''
            ||p_mv_log_name||
	    ''' and OBJECT_TYPE=''MVLOG'' and INDEX_SQL is not null';
  l_count := 0;
  open c_mv_log_index for l_stmt;
  loop
    fetch c_mv_log_index into l_index_name, l_index_ddl;
    exit when c_mv_log_index%NOTFOUND;
    IF (l_index_ddl IS NOT NULL) THEN
      BEGIN
        temp_index_ddl:= to_char(sys.ad_dbms_metadata.get_ddl('INDEX',l_index_name));
      EXCEPTION WHEN OTHERS THEN --Index doesnt exists already . We can recreate now without ORA error.
        execute immediate l_index_ddl;
	l_count := l_count + 1;
        WRITELOG('Recreated Index ' || l_index_name || ' on MVLog ' || form_triplet(p_mv_log_name, P_mv_log_schema, 'MVLog') );
      END;
    end if;
  end loop;
  close c_mv_log_index;
  if (l_count = 0) then
    WRITELOG('No Index Recreated on MVLog ' || form_triplet(p_mv_log_name, P_mv_log_schema, 'MVLog') );
  else
    WRITELOG(to_char(l_count)||' Index(s) re-created on MVLog ' || form_triplet(p_mv_log_name, P_mv_log_schema, 'MVLog') );
  end if;
END;


PROCEDURE create_mv_log(p_base_object_name in varchar2,
                        P_base_object_schema in varchar2,
                        P_base_object_type in varchar2,
						P_check_profile in varchar2 default 'Y')
IS
  l_count integer := 0;
  l_time date;
  l_dur  number;
  l_snapshot_log_sql_handle clob := null;
  l_amount  integer := 256;
  l_offset  integer := 1;
  l_output  varchar2(256);
  l_index   integer := 0;
  l_stmt varchar2(32767) := 'BEGIN
   select count(*) into :l_count
   from
     bis_obj_properties PRP,
     All_SNAPSHOT_LOGS LOG
   where
     log.master = PRP.object_name
   and OBJECT_TYPE = :P_base_object_type
   and OBJECT_NAME = :p_base_object_name
   and log.log_owner = :P_base_object_schema;
--       BIS_CREATE_REQUESTSET.get_object_owner(object_name, object_type);
   END;
  ';
  l_mv_log_name VARCHAR2(30);
BEGIN
 if P_check_profile='Y' then
   if ( NOT is_mv_log_mangmnt_enabled) then
     WRITELOG('No further action performed!');
     return;
  end if;
 end if;

 if P_base_object_schema='NOTFOUND' then
     WRITELOG('Base object '||p_base_object_name||' not exists.'||'No further action performed!');
     return;
 end if;

   --WRITELOG('Executed ' || l_stmt || ' with ' || form_triplet(l_count, P_base_object_type, p_base_object_name));
   execute immediate l_stmt
    using OUT l_count, IN P_base_object_type, IN p_base_object_name, IN P_base_object_schema;

   if(l_count > 0) then
     WRITELOG('MV log for ' || form_triplet(p_base_object_name, P_base_object_schema, P_base_object_type) || 'exists.
     Stop MV log recreating!');
     return;
   end if;

   setTimer(l_time);
   begin
     select snapshot_log_sql into  l_snapshot_log_sql_handle
     from bis_obj_properties
     where object_name = p_base_object_name
     and object_type = P_base_object_type;
   exception when no_data_found then
     WRITELOG(form_triplet(p_base_object_name, P_base_object_schema, P_base_object_type) || ' not seeded in RSG,
     skip MV log creating!!');
     return;
   end;

   if (l_snapshot_log_sql_handle is null or
      DBMS_LOB.getlength(l_snapshot_log_sql_handle) = 0 ) then
     WRITELOG('Found no MV Log defined for ' || form_triplet(p_base_object_name, P_base_object_schema, P_base_object_type)
            || ', not need to recreate.');
     return;
   else
     WRITELOG('building mv log sql statement array:');
     WHILE(l_offset< DBMS_LOB.getlength(l_snapshot_log_sql_handle)  )
     LOOP
       l_index := l_index + 1;
       DBMS_LOB.READ(l_snapshot_log_sql_handle, l_amount, l_offset, l_output);
       build_statement(l_output, l_index);
       l_offset := l_offset + l_amount;
       WRITELOG(l_output);
     END LOOP;

     WRITELOG('executing apps_array_ddl.apps_array_ddl');
     apps_array_ddl.apps_array_ddl(1, l_index);

     --aguwalan :: bug#4898446 :: Recreate Indexes, if any, on MVLog
     WRITELOG('Recreate Indexes, if any, on MVLog');
     l_mv_log_name := get_mview_log_name(p_base_object_name, P_base_object_schema);
     recreate_mv_log_index(l_mv_log_name, P_base_object_schema);

     logTime( 'Creating mv log for ' || form_triplet(p_base_object_name, P_base_object_schema, P_base_object_type) , l_time);

     update_mv_log_status(p_base_object_name ,
                          p_base_object_type ,
                        'RECREATED');
   end if;
EXCEPTION WHEN OTHERS THEN
    WRITELOG('Failed creating MV log for ' ||  P_base_object_schema || '.' ||
     p_base_object_name || ', ' ||sqlerrm);
     raise;
END;

function on_check_prog_linkage (
   p_object_name in varchar2,
   p_object_type in varchar2
) RETURN BOOLEAN
IS
  l_count   integer := 0;
BEGIN
  if ( p_object_type <> 'MV') then
     select count(*) into l_count
     from bis_obj_prog_linkages lkg
     where
       object_type <> 'MV'
     and lkg.enabled_flag = 'Y'
     and lkg.refresh_mode in ( 'INIT', 'INIT_INCR')
     and object_type = p_object_type
     and object_name = p_object_name;
     if (l_count > 0 ) then
       WRITELOG('Found comcplete refresh program for ' || p_object_name);
       return true;
     else
       WRITELOG('Found no comcplete refresh program for ' || p_object_name);
       return false;
     end if;
  else
    select count(*) into l_count
    from bis_obj_prog_linkages lkg
    where
      object_type = 'MV'
    and lkg.enabled_flag = 'Y'
    and lkg.refresh_mode in ( 'INIT', 'INIT_INCR')
    and conc_program_name <> 'BIS_MV_REFRESH'
    and object_type = p_object_type
    and object_name = p_object_name;
    if (l_count > 0 ) then
       WRITELOG('Found complete refresh program for MV ' || p_object_name||' hence do not perform capture and drop MV log.');
       return false;
     else
       WRITELOG('Found no complete refresh program for MV, ' || p_object_name);
       return true;
     end if;
  end if;
END;



PROCEDURE base_sum_mlog_recreate (
    P_OBJ_NAME      IN 	VARCHAR2
) IS
  l_parameter_tbl   BIS_BIA_RSG_PARAMETER_TBL := BIS_BIA_RSG_PARAMETER_TBL();
    l_root_request_id  INTEGER;
    l_rs_name   varchar2(500);
    l_is_force_full    varchar2(100) := null;
    l_refresh_mode     varchar2(100) := null;
    l_tmp              varchar2(100) := null;
    l_opt              varchar2(100) := null;
    l_schema    varchar2(500);
    cursor c_force_full(p_request_id INTEGER ) IS
    select distinct
      sets.request_set_name,
      opt.option_name,
      opt.option_value
    from
      fnd_run_requests req,
      fnd_request_sets sets,
      bis_request_set_options opt
    where
      req.parent_request_id = p_request_id
    and sets.request_set_id = req.request_set_id
    and req.application_id = 191
    and sets.application_id = 191
    and req.application_id = sets.application_id
    and opt.request_set_name = sets.request_set_name
    and opt.option_name IN ('FORCE_FULL', 'REFRESH_MODE');
    l_impl varchar2(10):= null;

BEGIN

   IF (Not BIS_COLLECTION_UTILITIES.setup(P_OBJ_NAME)) THEN
      RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || sqlerrm);
      return;
   END IF;

   if ( NOT is_mv_log_mangmnt_enabled) then
     WRITELOG('No further action performed!');
     return;
   end if;

   select implementation_flag into l_impl
   from bis_obj_properties
   where object_name = P_OBJ_NAME
   and object_type = 'TABLE';
   if (l_impl <> 'Y') then
     WRITELOG( P_OBJ_NAME || 'is not implemented, No further action performed!');
     return;
   end if;

   l_root_request_id := FND_GLOBAL.CONC_PRIORITY_REQUEST;
   BIS_COLLECTION_UTILITIES.put_line('FND_GLOBAL.CONC_PRIORITY_REQUEST: ' || l_root_request_id);
   open c_force_full(l_root_request_id);
   LOOP
     fetch c_force_full into l_rs_name, l_opt, l_tmp;
     exit when c_force_full%NOTFOUND;
     if ( l_opt = 'FORCE_FULL') then
       l_is_force_full := l_tmp;
     elsif ( l_opt = 'REFRESH_MODE') then
       l_refresh_mode := l_tmp;
     end if;
   END LOOP;
   close c_force_full;
   WRITELOG('Request Set: ' || l_rs_name
                                     || ', ' || 'FORCE_FULL option: ' || l_is_force_full
                                     || ', ' || 'REFRESH_MODE option: ' || l_refresh_mode
                                     );
   if (NOT
         ( l_is_force_full = 'Y' AND  l_refresh_mode = 'INIT')
      ) then
     WRITELOG('No action for MV Log recreation.');
     RETURN;
   end if;


   WRITELOG( 'BIS RUNTIME MV LOG MANAGEMENT for ' ||form_triplet(P_OBJ_NAME, 'TABLE', null) || ' Starts!');
   l_schema := BIS_CREATE_REQUESTSET.get_object_owner(P_OBJ_NAME, 'TABLE');
   WRITELOG('Schema info:' || l_schema);
   create_mv_log(P_OBJ_NAME,
                 l_schema,
                 'TABLE');

EXCEPTION WHEN OTHERS THEN
  close c_force_full;
  raise;
END base_sum_mlog_recreate;

PROCEDURE base_sum_mlog_capture_and_drop(
    P_OBJ_NAME      IN 	VARCHAR2 )
IS
  l_owner  varchar2(32767);
  l_impl varchar2(10):= null;
  l_exist number := 0;
BEGIN
   if ( NOT is_mv_log_mangmnt_enabled) then
     WRITELOG('No further action performed!');
     return;
   end if;

   select implementation_flag into l_impl
   from bis_obj_properties
   where object_name = P_OBJ_NAME
   and object_type = 'TABLE';
   if (l_impl <> 'Y') then
     WRITELOG( P_OBJ_NAME || 'is not implemented, no further action performed!');
     return;
   end if;

   l_owner := BIS_CREATE_REQUESTSET.get_object_owner(P_OBJ_NAME, 'TABLE');

/** commented out per enhancement 4222518
   select count(*) into l_exist
   from
     All_SNAPSHOT_LOGS LOG
   where
    log.master = P_OBJ_NAME
   and log.log_owner = l_owner;

  if(l_exist = 0 ) then
     WRITELOG( 'MV log for ' || P_OBJ_NAME || ' does not exist, no further action performed!');
     return;
  end if;
**/

  capture_and_drop_log_by_name ( P_OBJ_NAME, 'TABLE', l_owner);
END base_sum_mlog_capture_and_drop;



PROCEDURE capture_and_drop_log_by_set(
    ERRBUF  		   OUT NOCOPY VARCHAR2,
    RETCODE		       OUT NOCOPY VARCHAR2,
    p_request_set_name in varchar2)
IS
  TYPE curType IS REF CURSOR ;
  c_all_log_base_obj 	curType;
  /*
   * l_stmt was modified to consider MV type object only due to bug3901782
   * 23-Mar-2005 l_stmt is modified per enhancement 4222518. Not join with
   * all_snapshot_logs in this query
   */
  l_stmt varchar2(32767) := '
   select DISTINCT PRP.object_name, PRP.object_type,
    BIS_CREATE_REQUESTSET.get_object_owner(prp.object_name, prp.object_type) object_owner
    from (
         SELECT distinct DEPEND_OBJECT_TYPE OBJECT_TYPE
                      , DEPEND_OBJECT_NAME OBJECT_NAME
                      , DEPEND_OBJECT_OWNER OBJECT_OWNER
   	      FROM BIS_OBJ_DEPENDENCY
          WHERE DEPEND_OBJECT_TYPE = ''MV''
	      START WITH OBJECT_NAME in (
             select object_name from bis_request_set_objects
             where request_set_name = :p_request_set_name
             and object_type = ''PAGE''
            )
         and enabled_flag = ''Y''
   	    connect by object_name = prior depend_object_name
        and object_type = prior depend_object_type
       and enabled_flag = ''Y''
    ) PRP,
    BIS_OBJ_PROPERTIES P
    where prp.object_name = p.object_name
    and prp.object_type = p.object_type
    and p.implementation_flag = ''Y''
    order by PRP.object_type, PRP.object_name
    ';

  l_object_name  bis_obj_properties.object_name%type;
  l_object_type  bis_obj_properties.object_type%type;
  l_object_owner all_objects.owner%type;
BEGIN
    errbuf  := NULL;
    retcode := '0';
    IF (Not BIS_COLLECTION_UTILITIES.setup(p_request_set_name)) THEN
      RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || sqlerrm);
      return;
    END IF;

   if ( NOT is_mv_log_mangmnt_enabled) then
     WRITELOG('No further action performed!');
     return;
   end if;

    --OPEN c_all_log_base_obj(p_request_set_name);
    WRITELOG('Executing the following: ' || l_stmt || '; using ' || p_request_set_name);
    open c_all_log_base_obj for l_stmt using p_request_set_name;
    LOOP
      FETCH c_all_log_base_obj into l_object_name, l_object_type, l_object_owner;
      exit when c_all_log_base_obj%NOTFOUND;
      if(l_object_owner <> 'NOTFOUND') then
        if (on_check_prog_linkage(l_object_name, l_object_type )) then
          WRITELOG('Perform Capture and Drop MV Log');
          BEGIN
            capture_and_drop_log_by_name(l_object_name, l_object_type, l_object_owner);
          EXCEPTION WHEN OTHERS
             -- Mask out exception
             THEN NULL;
          END;
        else
          WRITELOG('not to Perform Capture and Drop MV Log');
          WRITELOG('************************************');
        end if; -- on_check_prog_linkage
      end if;  -- l_object_owner <> 'NOTFOUND'
     WRITELOG('  ');
    END LOOP;
    CLOSE c_all_log_base_obj;
EXCEPTION WHEN OTHERS THEN
    errbuf := sqlerrm;
    retcode := sqlcode;
    CLOSE c_all_log_base_obj;
    WRITELOG('Failed capture_all_mv_log_sql, ' || sqlerrm);
    Raise;
END;

procedure restore_by_set(
   ERRBUF  		   OUT NOCOPY VARCHAR2,
   RETCODE		       OUT NOCOPY VARCHAR2,
   p_request_set_name varchar2
)
IS
  TYPE curType IS REF CURSOR ;
  c_all_log_base_obj 	curType;
  l_stmt varchar2(32767) := '
    select DISTINCT object_name, object_type,
    BIS_CREATE_REQUESTSET.get_object_owner(object_name, object_type) object_owner
    from (
      	SELECT distinct DEPEND_OBJECT_TYPE OBJECT_TYPE
                      , DEPEND_OBJECT_NAME OBJECT_NAME
                      , DEPEND_OBJECT_OWNER OBJECT_OWNER
   	    FROM BIS_OBJ_DEPENDENCY
        WHERE DEPEND_OBJECT_TYPE = ''MV''
	    START WITH OBJECT_NAME in (
          select object_name from bis_request_set_objects
          where request_set_name = :p_request_set_name
          and object_type = ''PAGE''
        )
	    connect by object_name = prior depend_object_name
        and object_type = prior depend_object_type
    ) PRP
    order by object_type, object_name';

  l_object_name  bis_obj_properties.object_name%type;
  l_object_type  bis_obj_properties.object_type%type;
  l_object_owner all_objects.owner%type;
BEGIN
    --OPEN c_all_log_base_obj(p_request_set_name);
    WRITELOG('Executing the following: ' || l_stmt || '; using ' || p_request_set_name);
    OPEN c_all_log_base_obj for l_stmt using p_request_set_name;
    LOOP
      FETCH c_all_log_base_obj into l_object_name, l_object_type, l_object_owner;
      exit when c_all_log_base_obj%NOTFOUND;
      if(l_object_owner <> 'NOTFOUND') then
        BEGIN
          WRITELOG('Restoring MV log for ' || form_triplet(l_object_name, l_object_owner, l_object_type));
          create_mv_log(l_object_name,l_object_owner,l_object_type);
          WRITELOG('Restored MV log for ' || form_triplet(l_object_name, l_object_owner, l_object_type));
          WRITELOG('  ');
        EXCEPTION WHEN OTHERS THEN
          WRITELOG('Encountered issue on restoring MV log for ' || form_triplet(l_object_name, l_object_owner, l_object_type)
                   || ', '
                   || sqlerrm);
        END;
      end if;
    END LOOP;
    CLOSE c_all_log_base_obj;
EXCEPTION WHEN OTHERS THEN
    errbuf := sqlerrm;
    retcode := sqlcode;
    WRITELOG('Failed restoring MV logs ' || sqlerrm);
    CLOSE c_all_log_base_obj;
    raise;
END;

END; -- Package Body BIS_BIA_RSG_LOG_MGMNT

/
