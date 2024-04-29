--------------------------------------------------------
--  DDL for Package Body BIS_BIA_RSG_INDEX_MGMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BIA_RSG_INDEX_MGMT" AS
/* $Header: BISBRIMB.pls 120.2 2006/01/24 09:32:33 aguwalan noship $ */

procedure setTimer(
    p_log_timstamp in out NOCOPY date)
  IS
  BEGIN
    p_log_timstamp := sysdate;
  END;

PROCEDURE WRITELOG(P_TEXT VARCHAR2)
  IS
  L_TEXT VARCHAR2(255);
  BEGIN
    BIS_COLLECTION_UTILITIES.put_line(P_TEXT);
    BIS_COLLECTION_UTILITIES.put_line(' ');
/*    if(length(P_TEXT)>255) then
      L_TEXT :=substr(P_TEXT, 0, 254);
    else
      L_TEXT := P_TEXT ;
    end if;
    DBMS_OUTPUT.PUT_LINE(L_TEXT);
    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE(' ');   */
  END;

FUNCTION duration(
	p_duration		number) return VARCHAR2 IS
  BEGIN
    return(to_char(floor(p_duration)) ||' Days '||
           to_char(mod(floor(p_duration*24), 24))||':'||
           to_char(mod(floor(p_duration*24*60), 60))||':'||
           to_char(mod(floor(p_duration*24*60*60), 60)));
  END duration;

PROCEDURE logTime(
    p_process        varchar2,
    p_log_timstamp   date)
  IS
    -- modified for GSCC
    l_duration     number ;
  BEGIN
    l_duration := sysdate - p_log_timstamp;
    WRITELOG('Process Time for '|| p_process || ' : ' || duration(l_duration));
  END;


Function form_triplet( att1 varchar2,
                       att2 varchar2,
                       att3 varchar2  ) return varchar2
  IS
    --- modified for GSCC and decrease the size of the variable as it
    --- was unneccessary
    l_result varchar2(200) ;
  BEGIN
    l_result := '( ' || att1 || ', ' || att2 || ', ' || att3 || ') ';
    return l_result;
  END;


function is_index_mgmnt_profile_set
  return boolean
  is
  begin
    IF (fnd_profile.value('BIS_BIA_MV_INDEX_ENABLE') = 'Y') THEN
      return true;
    ELSE
      WRITELOG('Runtime BIA MV Log Management feature is off');
      return false;
    END IF;
  end;



function is_Index_Mgmt_Enabled(p_mv_name in varchar2, p_mv_schema in varchar2) return varchar2 -- p_mv_schema is no more used after bug 4186097
is
  TYPE curType IS REF CURSOR;
  c_index_mgmt_flag curType;
  l_stmt varchar2(1000);
  -- modified to remove GSCC warning  File.Sql.35
  l_index_mgmt_enabled varchar2(1);
  begin
    l_index_mgmt_enabled := 'N';
    l_stmt := 'select Drop_create_index_flag from bis_obj_properties where OBJECT_TYPE=''MV'' and OBJECT_NAME=:1'; --bug 4186097. removed p_mv_schema check, because p_mv_schema gives the Schema in which
                                                                                                                                    --the MV is created, whereas OBJECT_OWNER is a product short name to whom the MV belongs.
    open c_index_mgmt_flag for l_stmt using p_mv_name;
    fetch c_index_mgmt_flag into l_index_mgmt_enabled;
    close c_index_mgmt_flag;
    if (l_index_mgmt_enabled = 'Y' or l_index_mgmt_enabled = 'y') then --bug 4186097
      return 'Y';
    else
      return 'N';
    end if;
  end;



PROCEDURE drop_mv_index(p_index_name in varchar2, p_index_schema in varchar2)
is
  l_time date;
  l_dur  number;
  -- modified to remove GSCC File.Sql.35, decreased the length of the variable to 200 from 1000 also
  l_stmt varchar2(200);

BEGIN
  l_stmt := 'DROP INDEX ' || p_index_schema||'.'||p_index_name;
  setTimer(l_time);
  WRITELOG('Executing ' || l_stmt);
  execute immediate l_stmt;
  logTime( 'Successfuly dropped mv index of ' || form_triplet(p_index_name, P_index_schema, null) , l_time);
  WRITELOG('************************************');

EXCEPTION WHEN OTHERS THEN
    WRITELOG('In procedure drop_mv_index, failed droping ' ||  p_index_schema||'.'||p_index_name || sqlerrm);
    raise;
end;


procedure Capture_and_drop_index_by_mv(p_mv_name in varchar2, p_mv_schema in varchar2)
is
  -- modified to remove GSCC warning File.Sql.35
  l_mv_index_handle clob;
  l_time date;
  l_length number;
  l_stmt varchar2(32767);
  TYPE curType IS REF CURSOR ;
  c_all_index_details	curType;
  l_index_name bis_obj_indexes.index_name%type;
  l_schema all_indexes.owner%type;
  l_ddl clob;
begin
  -- added to remove GSCC warning File.Sql.35
  l_mv_index_handle := null;
  l_length          := 0;
  l_stmt            := null;

  if(NOT is_index_mgmnt_profile_set) then
    WRITELOG('No further action performed!');
    return;
  end if;


  setTimer(l_time);

  WRITELOG('Capturing MV Index for ' || form_triplet(p_mv_name, p_mv_schema, null));
  -- bug#4704403
  --l_mv_index_handle := sys.ad_dbms_metadata.get_dependent_ddl('INDEX',p_mv_name, p_mv_schema);

    l_stmt := 'SELECT INDEX_NAME, OWNER, TO_CHAR(sys.ad_dbms_metadata.GET_DDL(''INDEX'',INDEX_NAME,OWNER)) FROM '||
    '(select index_name , OWNER from all_indexes where table_name = :1 and owner = :2)';

  open c_all_index_details for l_stmt using p_mv_name, p_mv_schema;
    loop
      fetch c_all_index_details	into l_index_name, l_schema, l_ddl;
      exit when c_all_index_details%NOTFOUND;

      if l_ddl is not null or l_ddl <> '' then
        update bis_obj_indexes  set  INDEX_SQL = l_ddl,  LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.User_id,  LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID where OBJECT_NAME=p_mv_name and OBJECT_TYPE='MV' and INDEX_NAME=l_index_name;
        IF SQL%NOTFOUND THEN
          INSERT INTO bis_obj_indexes( OBJECT_NAME, OBJECT_TYPE, INDEX_NAME, INDEX_SQL, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
          		values(p_mv_name, 'MV', l_index_name, l_ddl, sysdate, FND_GLOBAL.User_id, sysdate, FND_GLOBAL.User_id, fnd_global.LOGIN_ID);
        END IF;
        COMMIT;
        drop_mv_index(l_index_name, p_mv_schema);
      end if;
    end loop;
  close c_all_index_details	;

  logTime( 'Dropping mv index of ' || form_triplet(p_mv_name, p_mv_schema, l_index_name) , l_time);
  WRITELOG('************************************');



EXCEPTION WHEN OTHERS THEN
    WRITELOG('In procedure Capture_and_drop_index_by_mv, failed capturing MV Index for ' ||  form_triplet(p_mv_name, p_mv_schema, l_index_name) || ', ' ||sqlerrm);
    raise;


end;



procedure recreate_indexes_by_mv(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY VARCHAR2, p_mv_name in varchar2,P_mv_schema in varchar2)
is
  l_stmt varchar2(300);
  TYPE curType IS REF CURSOR ;
  c_index_sql	curType;
  l_index_name varchar2(30);
  l_index_ddl varchar2(32767);--clob;
  temp_index_ddl varchar2(32767);--clob;
  l_time date;
  count_created Number; -- bug 4284095
  count_exists  Number; -- bug 4284095
  l_program_status boolean; -- bug 4284095

  --bug 4312072
  l_mv_name varchar2(30);
  l_mv_schema varchar2(30);
begin
  ERRBUF:= NULL;
  RETCODE:= '0';

  if(NOT is_index_mgmnt_profile_set) then
    WRITELOG('Index management Profile is False! No further action performed!');
    return;
  end if;

  --code added for bug 4284095
  if(p_mv_name is null or P_mv_schema is null) then
    WRITELOG('Warning!! Program will exit as parameters are NULL');
    l_program_status := fnd_concurrent.set_completion_status('WARNING' ,NULL);
    RETCODE := 2;
    return ;
  end if;

  --added for bug 4312072
  l_mv_name   := upper(p_mv_name);
  l_mv_schema := upper(P_mv_schema);

  -- added for bug 4284188
  -- this API can be run directly when user run concurrent program 'Recreate MV index Management', that time we
  -- need to check seperately if the flag set or not.
  if (is_Index_Mgmt_Enabled(l_mv_name,l_mv_schema) = 'N')then
       WRITELOG('The MV '||l_mv_name||' is not seeded in RSG or MV Index management is disabled for MV ' ||l_mv_name||'.  No further action performed!');
       return ;
  end if;

  count_created :=0; -- this counter will be used created indexes -- bug 4284095
  count_exists  :=0;  -- bug 4284095

  setTimer(l_time);
  WRITELOG('Recreating MV Index for ' || form_triplet(l_mv_name, l_mv_schema, null));

  -- bug 4312072
  l_stmt := 'select INDEX_NAME, INDEX_SQL from BIS_OBJ_INDEXES where OBJECT_NAME='''
            ||l_mv_name||
	    ''' and OBJECT_TYPE=''MV'' and INDEX_SQL is not null';

  open c_index_sql for l_stmt;
  loop
    fetch c_index_sql into l_index_name, l_index_ddl;
    exit when c_index_sql%NOTFOUND;
    logTime( form_triplet(l_mv_name, l_mv_schema, l_index_name) , l_time);
    if l_index_ddl is not null /*and l_index_ddl <> ''*/ then
      BEGIN
      logTime( 'Checking for existence of ' || l_index_name, l_time);
      -- bug#4704403
      temp_index_ddl:= to_char(sys.ad_dbms_metadata.get_ddl('INDEX',l_index_name));
      logTime( 'Index exists ' || l_index_name, l_time);
      count_exists := count_exists + 1;   -- bug 4284095
      EXCEPTION WHEN OTHERS THEN --Index doesnt exists already . We can recreate now without ORA error.
        logTime( 'index does not exist, recreating index ' || l_index_name, l_time);
        execute immediate l_index_ddl;
	count_created := count_created + 1;   -- bug 4284095
        logTime( 'recreated index ' || l_index_name, l_time);
      END;
    end if;
  end loop;
  close c_index_sql;

  --code for bug 4284095
  If(count_created =0 and count_exists =0) then
    WRITELOG('No Index has been created, As there is no index associated for');
    WRITELOG(' given MV '|| l_mv_name);
  else If (count_exists >0 and count_created =0) then
         WRITELOG('All indexes for the MV '||l_mv_name||' already existed in the system');
	 WRITELOG('so no indexes were recreated');
       end if;
  end if;
  WRITELOG('************************************');

EXCEPTION WHEN OTHERS THEN
    WRITELOG('In recreate_indexes_by_mv, failed recreating MV Index for ' ||  form_triplet(l_mv_name, l_mv_schema, l_index_name) || 'due to ' ||sqlerrm);

    ERRBUF:=SQLERRM;
    RETCODE:=SQLCODE;

    raise;

end;

procedure recreate_indexes_by_mv_wrapper(p_mv_name in varchar2,P_mv_schema in varchar2) is
ERRBUF VARCHAR2(2000);
RETCODE VARCHAR2(2000);
begin

  if(NOT is_index_mgmnt_profile_set) then
    WRITELOG('No further action performed!');
    return;
  end if;

  recreate_indexes_by_mv(ERRBUF, RETCODE, p_mv_name, P_mv_schema);
end;


procedure enable_index_mgmt(p_mv_name in varchar2,P_mv_schema in varchar2)
is
  begin
  update bis_obj_properties set DROP_CREATE_INDEX_FLAG='Y', LAST_UPDATED_BY= FND_GLOBAL.User_id, LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID, LAST_UPDATE_DATE = sysdate  where OBJECT_NAME=p_mv_name and OBJECT_OWNER=p_mv_schema and OBJECT_TYPE='MV';
  COMMIT;

  EXCEPTION WHEN OTHERS THEN
    WRITELOG('In procedure enable_index_mgmt, failed enabling index mgmt flag' ||  form_triplet(p_mv_name, p_mv_schema, null) || ', ' ||sqlerrm);
    raise;

  end;


procedure disable_index_mgmt(p_mv_name in varchar2,P_mv_schema in varchar2)
is
  begin
  update bis_obj_properties set DROP_CREATE_INDEX_FLAG='N', LAST_UPDATED_BY= FND_GLOBAL.User_id, LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID, LAST_UPDATE_DATE = sysdate  where OBJECT_NAME=p_mv_name and OBJECT_OWNER=p_mv_schema and OBJECT_TYPE='MV';
  COMMIT;

  EXCEPTION WHEN OTHERS THEN
    WRITELOG('In procedure disable_index_mgmt, failed enabling index mgmt flag' ||  form_triplet(p_mv_name, p_mv_schema, null) || ', ' ||sqlerrm);
    raise;

  end;


END;



/
