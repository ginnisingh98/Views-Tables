--------------------------------------------------------
--  DDL for Package Body BIS_MV_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_MV_REFRESH" AS
/* $Header: BISMVRFB.pls 120.10.12000000.5 2007/10/10 10:13:30 phattarg ship $ */

  G_ERRBUF        VARCHAR2(2000)  := NULL;
  G_ERRCODE       NUMBER          := 0;
  g_program_status     boolean  :=true;
  g_program_status_var varchar2(100) := 'NORMAL';


  g_apps_schema_name varchar2(30);



  PROCEDURE DEBUG(P_TEXT VARCHAR2, P_IDENT NUMBER DEFAULT 0)
  IS
  BEGIN
    BIS_COLLECTION_UTILITIES.debug(P_TEXT, P_IDENT);
  END;

  procedure logmsg(P_TEXT in VARCHAR2) is
  begin

       BIS_COLLECTION_UTILITIES.put_line(P_TEXT);
    --  dbms_output.put_line(substr(P_TEXT,1,255));
  end;

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
    BIS_COLLECTION_UTILITIES.put_line('Process Time for '|| p_process || ' : ' || duration(l_duration));
    BIS_COLLECTION_UTILITIES.put_line('');
  END;

FUNCTION get_Table_size(p_obj_owner IN VARCHAR2
                     ,p_log_table IN VARCHAR2)
RETURN NUMBER
IS
 op1 NUMBER;
 total_bytes NUMBER;
 op3 NUMBER;
 op4 NUMBER;
 op5 NUMBER;
 op6 NUMBER;
 op7 NUMBER;
BEGIN
 total_bytes := 0;
 BEGIN
   Dbms_Space.Unused_Space(p_obj_owner, p_log_table, 'TABLE',op1,total_bytes,op3,op4,op5,op6,op7);
 EXCEPTION
   WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Error in get_Table_size('|| p_obj_owner || ',' || p_log_table || sqlerrm);
 END;
 return total_bytes;
END;

 FUNCTION get_apps_schema_name RETURN VARCHAR2 IS

     l_apps_schema_name VARCHAR2(30);

     CURSOR c_apps_schema_name IS
	SELECT oracle_username
	  FROM fnd_oracle_userid WHERE oracle_id
	  BETWEEN 900 AND 999 AND read_only_flag = 'U';
  BEGIN

     OPEN c_apps_schema_name;
     FETCH c_apps_schema_name INTO l_apps_schema_name;
     CLOSE c_apps_schema_name;
     RETURN l_apps_schema_name;

  EXCEPTION
     WHEN OTHERS THEN
	RETURN NULL;
  END get_apps_schema_name;

  PROCEDURE RECOMPILE_MV(
    P_MVNAME               IN VARCHAR2
  ) IS
    l_stmt   varchar2(2000);
    l_errbuf          varchar2(2000);
    l_retcode         number;
    l_compile_state  all_mviews.compile_state%type;

    CURSOR C_MV_CSTATE ( P_MVNAME bis_obj_dependency.object_name%TYPE, p_apps_schema_name varchar2 )
    IS
       select NVL(compile_state, 'NA')
	 from all_mviews
	 where mview_name = p_mvname
	 AND owner = p_apps_schema_name
       UNION ALL
       SELECT NVL(compile_state, 'NA')
	 FROM all_mviews mvs, user_synonyms s
	 WHERE mvs.owner = s.table_owner
	 AND mvs.mview_name = s.table_name
	 AND mview_name = p_mvname;

  BEGIN
    DEBUG('Compiling MV ' || P_MVNAME);
    l_stmt := 'alter materialized view ' ||  P_MVNAME || ' compile';
    execute immediate l_stmt;

    IF (g_apps_schema_name IS NULL) THEN
       g_apps_schema_name := get_apps_schema_name;
    END IF;

    OPEN C_MV_CSTATE(p_mvname, g_apps_schema_name);
    fetch C_MV_CSTATE into l_compile_state;
    CLOSE C_MV_CSTATE;
    BIS_COLLECTION_UTILITIES.put_line('MV compile state : ' || l_compile_state || '.');

  EXCEPTION WHEN OTHERS THEN
    l_errbuf :=sqlerrm;
    l_retcode:=sqlcode;
    DEBUG('Failed MV compiling, ' || l_errbuf);

  END;

  -- added for enhancement 3022739, MV threshold at runtime.
  FUNCTION GET_CUSTOMAPI (p_mvname VARCHAR2) RETURN VARCHAR2
  IS
    L_CUSTOM_API bis_obj_properties.custom_api%type := NULL;
    CURSOR C_CUSTOM_API ( P_MVNAME bis_obj_dependency.object_name%type )
    IS
      select CUSTOM_API from bis_obj_properties
      where object_name = p_mvname;
  BEGIN
    OPEN C_CUSTOM_API(p_mvname);
    fetch C_CUSTOM_API into L_CUSTOM_API;
    CLOSE C_CUSTOM_API;
    RETURN L_CUSTOM_API;
  END;

  -- added for enhancement 3022739, MV threshold at runtime.
  FUNCTION GET_MV_THRESHOLDED_AT_RUNTIME (p_mvname VARCHAR2) RETURN VARCHAR2
  IS
    l_rtnbuf VARCHAR2(32767);
    l_retcode VARCHAR2(32767);
    L_CUSTOM_API bis_obj_properties.custom_api%type := NULL;
  BEGIN
    L_CUSTOM_API:= GET_CUSTOMAPI (p_mvname);
    IF (L_CUSTOM_API is NOT NULL) THEN
      BIS_COLLECTION_UTILITIES.put_line('Before invoke custom API for MV threshold management: (' || p_mvname || ')');
      -- Now call the stored program
      l_rtnbuf:=BIS_BIA_RSG_CUSTOM_API_MGMNT.METHOD_FAST;--added for enhancement 4423644
      BIS_BIA_RSG_CUSTOM_API_MGMNT.INVOKE_CUSTOM_API(
       l_rtnbuf, l_retcode,
       L_CUSTOM_API, BIS_BIA_RSG_CUSTOM_API_MGMNT.TYPE_MV_THRESHOLD,
       p_mvname, 'MV', BIS_BIA_RSG_CUSTOM_API_MGMNT.MODE_BEFORE);
     --- BIS_BIA_RSG_CUSTOM_API_MGMNT.log( 'Got refresh threshold for ' || p_mvname || ': '|| l_rtnbuf);
      BIS_COLLECTION_UTILITIES.put_line('After invoke custom API for MV threshold management : (' || p_mvname ||','||l_rtnbuf|| ')');

      IF ( l_rtnbuf = BIS_BIA_RSG_CUSTOM_API_MGMNT.METHOD_COMPLETE) THEN
        RETURN 'INIT';
      ELSIF ( l_rtnbuf = BIS_BIA_RSG_CUSTOM_API_MGMNT.METHOD_FAST) THEN
        RETURN 'INCR';
      END IF;
      RETURN l_rtnbuf;
    ELSE
      RETURN NULL; -- meaning that no CUSTOME_API defined, and therefore no THRESHOLDING
    END IF;
  EXCEPTION WHEN OTHERS THEN
    BIS_COLLECTION_UTILITIES.put_line('Errored in BIS_MV_REFRESH.GET_MV_THRESHOLDED_AT_RUNTIME');
    RAISE;  -- raise whatever exceptions, and fails the process.
  END;

  -- added for enhancement 3034322, MV index management at runtime.
  PROCEDURE MV_INDEX_MANAGE(p_mvname VARCHAR2, p_mode VARCHAR2)
  IS
    l_rtnbuf VARCHAR2(32767);
    l_retcode VARCHAR2(32767);
    L_CUSTOM_API bis_obj_properties.custom_api%type := NULL;
  BEGIN
    L_CUSTOM_API:= GET_CUSTOMAPI (p_mvname);
    IF (L_CUSTOM_API is NOT NULL) THEN
      -- Now call the stored program
      BIS_COLLECTION_UTILITIES.put_line('Before invoke custom API for MV index management : (' || p_mvname || ', ' || p_mode || ')');
      l_rtnbuf:= BIS_BIA_RSG_CUSTOM_API_MGMNT.METHOD_COMPLETE;
      BIS_BIA_RSG_CUSTOM_API_MGMNT.INVOKE_CUSTOM_API(
       l_rtnbuf, l_retcode,
       L_CUSTOM_API, BIS_BIA_RSG_CUSTOM_API_MGMNT.TYPE_MV_INDEX_MGT,
       p_mvname, 'MV', p_mode);
      BIS_COLLECTION_UTILITIES.put_line('After invoke custom API for MV index management: (' || p_mvname || ', ' || p_mode || ')');
    END IF;
  EXCEPTION WHEN OTHERS THEN
    BIS_COLLECTION_UTILITIES.put_line('Errored in BIS_MV_REFRESH.MV_INDEX_MANAGE');
    RAISE;  -- raise whatever exceptions, and fails the process.
  END;


  -- added for enhancement 3748713, BIS MV Log Management at runtime.
  PROCEDURE MV_LOG_MANAGE(p_mvname VARCHAR2, p_mode VARCHAR2)
  IS
    l_root_request_id  INTEGER;
    l_rs_name   varchar2(500);
    l_is_force_full    varchar2(10) := null;
    l_schema    varchar2(500);
    cursor c_force_full(p_request_id INTEGER ) IS
    -- aguwalan
    select distinct
      sets.request_set_name,
      opt.option_value
    from
      fnd_run_requests req,
      fnd_request_sets sets,
      bis_request_set_options opt
    where
      req.parent_request_id = p_request_id
    and sets.request_set_id = req.request_set_id
    and sets.application_id = req.set_application_id
    /* remove the following predicates for the assumptin on
     * application id = 191 might not be true*/
    --and req.application_id = 191
    --and sets.application_id = 191
    --and req.application_id = sets.application_id
    and opt.request_set_name = sets.request_set_name
    and opt.option_name = 'FORCE_FULL';

  BEGIN
    l_root_request_id := FND_GLOBAL.CONC_PRIORITY_REQUEST;
    BIS_COLLECTION_UTILITIES.put_line('FND_GLOBAL.CONC_PRIORITY_REQUEST: ' || l_root_request_id);
    open c_force_full(l_root_request_id);
    fetch c_force_full into l_rs_name, l_is_force_full;
    close c_force_full;
    BIS_COLLECTION_UTILITIES.put_line('Request Set: ' || l_rs_name || ', ' || 'FORCE_FULL option: ' || l_is_force_full);
    l_schema := BIS_CREATE_REQUESTSET.get_object_owner(p_mvname, 'MV');

    if( p_mode = 'INIT' and l_is_force_full='Y' ) then
      BIS_BIA_RSG_LOG_MGMNT.create_mv_log(p_mvname, l_schema, 'MV');
    else
      BIS_COLLECTION_UTILITIES.put_line('No action for MV Log recreation.');
    end if;

  EXCEPTION WHEN OTHERS THEN
    close c_force_full;
    BIS_COLLECTION_UTILITIES.put_line('Errored in BIS_MV_REFRESH.MV_LOG_RECREATE');
    RAISE;  -- raise whatever exceptions, and fails the process.
  END;


  -- for 3761132
  -- l_atomic_refresh := false for 10g complete refresh only.
  FUNCTION IS_ATOMIC_REFRESH_BY_DBVERSION RETURN BOOLEAN
  IS
    db_versn varchar2(100);
    l_atomic_refresh boolean;
  BEGIN
    select version into db_versn from v$instance;
    BIS_COLLECTION_UTILITIES.put_line('DB Version: ' || db_versn);

    select substr(replace(substr(version,1,instr(version,'.',1,2)-1),'.'),1,2)
    into db_versn from v$instance;


    if (( db_versn > 80) and (db_versn < 90)) -- 8i
    then
      l_atomic_refresh := true;
      BIS_COLLECTION_UTILITIES.put_line('Atomic refresh: true');
    elsif ( db_versn >= 90 ) -- 9i
    then
      l_atomic_refresh := true;
      BIS_COLLECTION_UTILITIES.put_line('Atomic refresh: true');
    else -- 10g
      l_atomic_refresh := false;
      BIS_COLLECTION_UTILITIES.put_line('Atomic refresh: false');
    end if;
    return l_atomic_refresh;
  END;


   --------added for enhancement 4423644
   PROCEDURE custom_api_other(p_mvname VARCHAR2, p_mode VARCHAR2,p_mv_refresh_method varchar2)
  IS
    l_rtnbuf VARCHAR2(32767);
    l_retcode VARCHAR2(32767);
    L_CUSTOM_API bis_obj_properties.custom_api%type := NULL;
  BEGIN
    L_CUSTOM_API:= GET_CUSTOMAPI (p_mvname);
    IF (L_CUSTOM_API is NOT NULL) THEN
      -- Now call the stored program
      if p_mv_refresh_method='F' then
        l_rtnbuf:=BIS_BIA_RSG_CUSTOM_API_MGMNT.METHOD_FAST;
      else
        l_rtnbuf:=BIS_BIA_RSG_CUSTOM_API_MGMNT.METHOD_COMPLETE;
      end if;
       BIS_COLLECTION_UTILITIES.put_line('Before INVOKE_CUSTOM_API for other custom logic : (' || p_mvname || ', ' || p_mode || ','||l_rtnbuf||')');
      BIS_BIA_RSG_CUSTOM_API_MGMNT.INVOKE_CUSTOM_API(
       l_rtnbuf, l_retcode,
       L_CUSTOM_API, BIS_BIA_RSG_CUSTOM_API_MGMNT.TYPE_MV_OTHER_CUSTOM,
       p_mvname, 'MV', p_mode);
      BIS_COLLECTION_UTILITIES.put_line('After INVOKE_CUSTOM_API for other custom logic: (' || p_mvname || ', ' || p_mode ||','||l_rtnbuf||')');
    END IF;
  EXCEPTION WHEN OTHERS THEN
    BIS_COLLECTION_UTILITIES.put_line('Errored in BIS_MV_REFRESH.CUSTOM_API_OTHER');
    RAISE;  -- raise whatever exceptions, and fails the process.
  END;


  /*
   * For bug 3140731
   * Created to be published and used by product teams refresh programs..
   */
  PROCEDURE REFRESH_WRAPPER (
   mvname                 IN     VARCHAR2,
   method                 IN     VARCHAR2,
   parallelism            IN     BINARY_INTEGER := 0)
  IS
    l_stmt             varchar2(1000);
    l_atomic_refresh   boolean := true;
    l_method varchar2(20) := 'INCREMENTAL'; --Bug 3626375
    l_schema    varchar2(30);  --Bug 3999642
    l_index_flag varchar2(1);  --Bug 3999642
    -- Debug :: Performance Testing
    -- temp_start_refresh date;
    -- l_star_transformation varchar2(1000);
  BEGIN
    IF (method = 'C') THEN
      l_atomic_refresh := IS_ATOMIC_REFRESH_BY_DBVERSION;

      if (l_atomic_refresh) then -- NOT TO INVOKE MV_INDEX_MANAGE IN 10G
        MV_INDEX_MANAGE(mvname, BIS_BIA_RSG_CUSTOM_API_MGMNT.MODE_BEFORE);
        l_schema := BIS_CREATE_REQUESTSET.get_object_owner(mvname, 'MV');               --Bug 3999642
        l_index_flag := BIS_BIA_RSG_INDEX_MGMT.is_Index_Mgmt_Enabled(mvname, l_schema); --Bug 3999642
        if (l_index_flag = 'Y' or l_index_flag = 'y') then  							--Bug 3999642
          BIS_BIA_RSG_INDEX_MGMT.Capture_and_drop_index_by_mv(mvname, l_schema);
        end if;
      end if;
      l_stmt := 'alter session force parallel query';
      execute immediate l_stmt;
      l_stmt := 'alter session enable parallel dml';
      execute immediate l_stmt;
      ---bug 4149264
      l_stmt:='alter  table '||mvname||' parallel ';
      execute immediate l_stmt ;
	  BIS_COLLECTION_UTILITIES.put_line(mvname||' was altered to parallel');
      ----end of bug 4149264

      -- for bug 3668562, move before the alter session calls
      -- MV_INDEX_MANAGE(mvname, BIS_BIA_RSG_CUSTOM_API_MGMNT.MODE_BEFORE);

      l_method  := 'INITIAL'; --BUG 3626375
    ELSE
      IF (method = 'F') THEN
        l_stmt := 'ALTER SESSION SET star_transformation_enabled=TEMP_DISABLE ';
        execute immediate l_stmt;
        BIS_COLLECTION_UTILITIES.put_line('Setting star_transformation_enabled=TEMP_DISABLE');
      END IF;
    END IF;

    ---added for enhancement 4423644
     custom_api_other(mvname, BIS_BIA_RSG_CUSTOM_API_MGMNT.MODE_BEFORE,method);

    -- for bug3404338, never use the parallelism param for now.
    -- for bug3617762, SET ATOMIC_REFRESH TO FALSE ONLY FOR COMPLETE REFRESH

    -- Debug for performance check; remove after testing
    -- temp_start_refresh := sysdate;
    -- select value into l_star_transformation from v$parameter where name = 'star_transformation_enabled';
    -- BIS_COLLECTION_UTILITIES.put_line('TESTING :: Value of star_transformation_enabled in V$parameter = '|| l_star_transformation);
    DBMS_MVIEW.REFRESH(
                list => mvname,
                method => method,
                parallelism => 0,
                atomic_refresh => l_atomic_refresh);

    -- Debugging for performance check; remove after testing
    --logtime('TESTING :: Timing for MV Refresh With STAR_TRANSFORMATION_ENABLED='|| l_star_transformation,temp_start_refresh);

    -- Added for bug 3626375 Log Messages
    BIS_COLLECTION_UTILITIES.put_line(mvname||' was refreshed using '|| l_method || ' refresh method');
    -- code end for bug 3626375

	------added for enhancement 4423644
     custom_api_other(mvname, BIS_BIA_RSG_CUSTOM_API_MGMNT.MODE_AFTER,method);

    IF (method = 'C') THEN

	  ---bug 4149264
      l_stmt:='alter table  '||mvname||' noparallel ';
      execute immediate l_stmt;
   	  BIS_COLLECTION_UTILITIES.put_line(mvname||' was altered to nonparallel');
      ----end of bug 4149264

      l_stmt := 'alter session disable parallel query';
      execute immediate l_stmt;
      commit;
      l_stmt := 'alter session disable parallel dml';
      execute immediate l_stmt;
      MV_LOG_MANAGE(mvname, 'INIT');
      if (l_atomic_refresh) then -- NOT TO INVOKE MV_INDEX_MANAGE IN 10G
        MV_INDEX_MANAGE(mvname, BIS_BIA_RSG_CUSTOM_API_MGMNT.MODE_AFTER);
        if (l_index_flag = 'Y' or l_index_flag = 'y') then                              --Bug 3999642
          BIS_BIA_RSG_INDEX_MGMT.recreate_indexes_by_mv_wrapper(mvname, l_schema);
        end if;
      end if;
    ELSE
      IF (method = 'F') THEN
        l_stmt := 'ALTER SESSION SET star_transformation_enabled=FALSE ';
        execute immediate l_stmt;
        BIS_COLLECTION_UTILITIES.put_line('Resetting star_transformation_enabled=FALSE');
        -- Debug
        -- select value into l_star_transformation from v$parameter where name = 'star_transformation_enabled';
        -- BIS_COLLECTION_UTILITIES.put_line('TESTING :: Value of star_transformation_enabled in V$parameter = '|| l_star_transformation);
      END IF;
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF (method = 'C') THEN
      l_stmt := 'alter session disable parallel query';
      execute immediate l_stmt;
      commit;
      l_stmt := 'alter session disable parallel dml';
      execute immediate l_stmt;
     if (l_atomic_refresh) then -- NOT TO INVOKE MV_INDEX_MANAGE IN 10G
        MV_INDEX_MANAGE(mvname, BIS_BIA_RSG_CUSTOM_API_MGMNT.MODE_AFTER);
        if (l_index_flag = 'Y' or l_index_flag = 'y') then
           BIS_BIA_RSG_INDEX_MGMT.recreate_indexes_by_mv_wrapper(mvname, l_schema);
        end if;
     end if;
    ELSE
      IF (method = 'F') THEN
        l_stmt := 'ALTER SESSION SET star_transformation_enabled=FALSE ';
        execute immediate l_stmt;
        BIS_COLLECTION_UTILITIES.put_line('Resetting star_transformation_enabled=FALSE');
        -- Debug
        -- select value into l_star_transformation from v$parameter where name = 'star_transformation_enabled';
        -- BIS_COLLECTION_UTILITIES.put_line('TESTING :: Value of star_transformation_enabled in V$parameter = '|| l_star_transformation);
      END IF;
    END IF;
    RAISE;
  END REFRESH_WRAPPER;


  /*
   * For bug 3140731
   * call  REFRESH_WRAPPER
   */
  PROCEDURE REFRESH_WRAP(p_mvname VARCHAR2, p_method VARCHAR2, p_degree BINARY_INTEGER)
  IS
    l_time_stamp date;
    l_method     varchar2(100);
    l_stmt       varchar2(1000);
  BEGIN
    IF ( p_method = 'C') THEN
      l_method := 'complete';
    ELSIF ( p_method = 'F') THEN
      l_method := 'incremental';
    END IF;

    setTimer(l_time_stamp);
    REFRESH_WRAPPER( p_mvname, p_method, p_degree);
    logTime(p_mvname || ' ' || l_method || ' refreshing', l_time_stamp);
  END REFRESH_WRAP;


/*
  FUNCTION IS_BIS_FORCE_REFRESH RETURN BOOLEAN
  IS

  BEGIN
    if fnd_profile.value('BIS_MV_FORCE_REFRESH') = 'Y' then
      BIS_COLLECTION_UTILITIES.put_line('BIS Force Refresh is starting');
      BIS_COLLECTION_UTILITIES.put_line(' ');
      RETURN TRUE;
    else
      BIS_COLLECTION_UTILITIES.put_line('BIS Force Refresh will not start');
      BIS_COLLECTION_UTILITIES.put_line(' ');
      RETURN FALSE;
    end if;

  END IS_BIS_FORCE_REFRESH;
*/

  FUNCTION VALIDATE(P_MVNAME IN VARCHAR2)
  RETURN BOOLEAN IS
    l_count  integer := 0;
  BEGIN
    IF (g_apps_schema_name IS NULL) THEN
       g_apps_schema_name := get_apps_schema_name;
    END IF;
    SELECT count(*) INTO l_count FROM ALL_MVIEWS
    WHERE OWNER = g_apps_schema_name AND MVIEW_NAME = p_mvname;
    IF (l_count = 0) THEN
      -- G_ERRBUF := 'Not a valid MV Name: ' || P_MVNAME;
      -- G_ERRCODE := -1;
      BIS_COLLECTION_UTILITIES.put_line('Not a valid MV Name: ' || P_MVNAME);
      -- BIS_COLLECTION_UTILITIES.put_line(' ');
      return FALSE;
    ELSE
      return TRUE;
    END IF;
  END VALIDATE;


  FUNCTION IS_FAST_REFRESHABLE(P_MVNAME IN VARCHAR2)
  RETURN BOOLEAN IS
    l_fast_refreshable   VARCHAR2(100) := NULL;
    l_refresh_method     VARCHAR2(50) := NULL;

    BEGIN
     IF (g_apps_schema_name IS NULL) THEN
       g_apps_schema_name := get_apps_schema_name;
    END IF;

    SELECT FAST_REFRESHABLE, REFRESH_METHOD
    INTO l_fast_refreshable, l_refresh_method
    FROM ALL_MVIEWS
    WHERE OWNER = g_apps_schema_name AND MVIEW_NAME = p_mvname;

    IF( l_refresh_method = 'COMPLETE' OR l_fast_refreshable = 'NO' ) THEN
       BIS_COLLECTION_UTILITIES.put_line( p_mvname || ' is not Fast Refreshable!');
       BIS_COLLECTION_UTILITIES.put_line(' ');
      return FALSE;
    ELSE
       BIS_COLLECTION_UTILITIES.put_line(p_mvname || ' is Fast Refreshable!');
       BIS_COLLECTION_UTILITIES.put_line(' ');
      return TRUE;
    END IF;
  END IS_FAST_REFRESHABLE;


  -- Try Fast Refresh First,
  -- if fail due to ignorable exceptions, try complete refresh immediately.
  -- if fail due to in-ignorable exceptions, get profile option to determine if
  -- complete refresh is needed.
  FUNCTION BIS_FAST_REFRESH(p_mvname VARCHAR2, p_degree NUMBER)
  RETURN NUMBER IS
    l_errbuf          varchar2(2000);
    l_retcode         number;
  BEGIN

    BEGIN
      BIS_COLLECTION_UTILITIES.put_line('Performing Fast Refresh for ' || p_mvname ||', mode Incremental Loading');
      REFRESH_WRAP(  p_mvname, 'F', p_degree);
      BIS_COLLECTION_UTILITIES.put_line(' ');
      RETURN 1;
    EXCEPTION
      -- ignore the following exceptions,
      -- as they are proven to be able to be resolved by a COMPLETE REFRESH.
      WHEN OTHERS THEN
        l_errbuf :=sqlerrm;
        l_retcode:=sqlcode;
        IF( l_retcode = -12034 OR -- materialized view log on OWNER.MVIEW_NAME younger than last refresh
            l_retcode = -12057 OR -- materialized view OWNER.MVIEW_NAME is INVALID and must complete refresh
            l_retcode = -12004 OR -- "REFRESH FAST cannot be used for materialized view \"%s\".\"%s\""
	    l_retcode = -12033 OR -- "cannot use filter columns from materialized view log on \"%s\".\"%s\""
            l_retcode = -12034 OR -- "materialized view log on \"%s\".\"%s\" younger than last refresh"
	    l_retcode = -12035 OR -- "could not use materialized view log on  \"%s\".\"%s\""
            l_retcode = -12052 OR -- "cannot fast refresh materialized view %s.%s"
            l_retcode = -12057 OR -- "materialized view \"%s\".\"%s\" is INVALID and must complete refresh"
            l_retcode = -32313 OR -- "REFRESH FAST of \"%s\".\"%s\" unsupported after PMOPs"
            l_retcode = -32314 OR -- "REFRESH FAST of \"%s\".\"%s\" unsupported after deletes/updates"
            l_retcode = -32315 OR -- "REFRESH FAST of \"%s\".\"%s\" unsupported after mixed DML and Direct Load"
            l_retcode = -32316 OR -- "REFRESH FAST of \"%s\".\"%s\" unsupported after mixed DML"
            l_retcode = -32320 OR -- "REFRESH FAST of \"%s\".\"%s\" unsupported after cointainer table PMOPs"
            l_retcode = -32321 -- "REFRESH FAST of \"%s\".\"%s\" unsupported after detail table TRUNCATE"
           --l_retcode = -23413 -- table OWNER.TABLE_NAME does not have a materialized view log
        ) THEN
          BIS_COLLECTION_UTILITIES.put_line('Ignored the following error while fast-refreshing '|| p_mvname || ':');
          BIS_COLLECTION_UTILITIES.put_line(sqlerrm);
          BIS_COLLECTION_UTILITIES.put_line(' ');
          g_program_status_var := 'WARNING';
        ELSE
          BIS_COLLECTION_UTILITIES.put_line('The following error while fast-refreshing '|| p_mvname || ' is not ignorable: ');
          BIS_COLLECTION_UTILITIES.put_line(sqlerrm);
          BIS_COLLECTION_UTILITIES.put_line(' ');

          RAISE;
        END IF;
    END; -- END OF FIRST ROUND, FAST REFRESH
    BIS_COLLECTION_UTILITIES.put_line('Performing Complete Refresh for ' || p_mvname ||', mode Incremental Loading');
    REFRESH_WRAP( p_mvname, 'C', p_degree);
    BIS_COLLECTION_UTILITIES.put_line(' ');
    return 1;
  END BIS_FAST_REFRESH;


  FUNCTION REFRESH_MV(p_mvname				VARCHAR2,
		      p_refreshmode			VARCHAR2,
      		      p_final_refresh_mode OUT  NOCOPY	VARCHAR2)

  RETURN NUMBER IS
    l_row_count             NUMBER;
    l_sql_stmt              VARCHAR2(2000);
    l_degree                NUMBER := 0;
    l_refreshmode           VARCHAR2(100) := NULL;
  BEGIN

    -- for bug3404338.
    -- hardcode l_degree to be 0 for now; in the future it will be used again.
    --l_degree := bis_common_parameters.get_degree_of_parallelism;
    l_degree := 0;
    DEBUG('Degree of Parallelism ' || l_degree);
    -- added for enhancement 3022739, MV threshold at runtime.

    IF (p_refreshmode = 'INCR') THEN
      l_refreshmode := GET_MV_THRESHOLDED_AT_RUNTIME(p_mvname);
     --- BIS_COLLECTION_UTILITIES.put_line('Got refresh threshold for ' || p_mvname || ': ' || l_refreshmode );
      IF (l_refreshmode is NULL ) THEN
        l_refreshmode := p_refreshmode;
      END IF;
    ELSE
        l_refreshmode := p_refreshmode;
    END IF;

          --changed following code to get actual refresh mode enh #3473874
    -- 'INIT' LOADING MODE indicates initial loading,
    -- meaning a COMPLETE REFRESH is necessary.
    -- the other possible vaue is 'INCR'
    IF (l_refreshmode = 'INIT') THEN
      BIS_COLLECTION_UTILITIES.put_line('Performing Initial loading');
      REFRESH_WRAP(p_mvname, 'C', l_degree);
      	      p_final_refresh_mode := 'INIT';
      RETURN 1;
    END IF;

    -- INCREMENTAL LOADING LOGIC FOR NON_FAST_REFRESHABLES
    DEBUG('Try performing incremental loading');
    IF ( NOT IS_FAST_REFRESHABLE(p_mvname)) THEN
      BIS_COLLECTION_UTILITIES.put_line('Performing Complete Loading for ' || p_mvname );
      REFRESH_WRAP( p_mvname, 'C', l_degree);
           p_final_refresh_mode := 'INIT';

      RETURN 1;
    END IF;

    -- INCREMENTAL LOADING LOGIC FOR FAST_REFRESHABLES
      p_final_refresh_mode := 'INCR';
    RETURN BIS_FAST_REFRESH(p_mvname, l_degree);

  EXCEPTION
  WHEN OTHERS THEN
    g_errbuf := sqlerrm;
    g_errcode := sqlcode;
    RETURN(-1);
  END REFRESH_MV;

  PROCEDURE updCacheByTopPortlet(
    P_MVNAME               IN VARCHAR2
  ) IS
    l_portlet_name       bis_obj_dependency.object_name%type;
    l_function_id        fnd_form_functions.function_id%type;
    CURSOR C_PORTLETS ( P_MVNAME bis_obj_dependency.object_name%type )
    IS

    select distinct object_name, function_id
    from bis_obj_dependency, fnd_form_functions
    where depend_object_type = 'MV'
    and object_type = 'PORTLET'
    and function_name(+) = depend_object_name
    and depend_object_name = P_MVNAME;

/*
    select distinct object_name
    from bis_obj_dependency
    where depend_object_type = 'MV'
    and object_type = 'PORTLET'
    and depend_object_name = P_MVNAME;
*/


  BEGIN
    open C_PORTLETS(P_MVNAME);
    loop
      fetch C_PORTLETS into l_portlet_name, l_function_id;
      exit when C_PORTLETS%NOTFOUND;
      IF ( l_function_id is null) THEN
        DEBUG( 'No Form Function defined for ' || l_portlet_name || '
        , skip calling icx_portlet.updCacheByFuncName');
      ELSE
        DEBUG('Calling icx_portlet.updCacheByFuncName on ' || l_portlet_name);
        icx_portlet.updCacheByFuncName(l_portlet_name);
        DEBUG('Done icx_portlet.updCacheByFuncName on ' || l_portlet_name);
      END IF;
    end loop;
    close C_PORTLETS;

  END updCacheByTopPortlet;

  FUNCTION IS_IMPLEMENTED(
    P_MVNAME               IN VARCHAR2
  ) RETURN BOOLEAN
    IS
    l_impl_flag bis_obj_properties.implementation_flag%type;
    CURSOR C_IMPLEMENTATION_FLAG ( P_MVNAME bis_obj_dependency.object_name%type )
    IS
     select NVL( implementation_flag, 'N')
     from bis_obj_properties
     where object_type = 'MV'
     and object_name = P_MVNAME;
  BEGIN
    open C_IMPLEMENTATION_FLAG(P_MVNAME);
    fetch C_IMPLEMENTATION_FLAG into l_impl_flag;
    close C_IMPLEMENTATION_FLAG;
    BIS_COLLECTION_UTILITIES.put_line( P_MVNAME || ' implemented: ' || l_impl_flag);
    BIS_COLLECTION_UTILITIES.put_line( '');
    RETURN (l_impl_flag = 'Y');
  END;


  procedure purge_log (p_mview_id in number) is
  l_stmt varchar2(1000);
  l_prefix varchar2(30):='  ';
  begin
    l_stmt:=' begin dbms_mview.purge_mview_from_log(:1); end;';
--    logmsg(l_prefix||'Begin time '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
    execute immediate l_stmt using p_mview_id;
 --   logmsg(l_prefix||'End time '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
    EXCEPTION WHEN OTHERS THEN
      if( sqlcode = -23425 ) then
          logmsg(l_prefix||'This MV had already been dissociated from the MV log.');
      else
         logmsg(l_prefix||'Error happened for ' || to_char(p_mview_id) || ': ' || sqlerrm);
      end if;
  end;

/**
  function get_mv_name_by_id(p_mview_id in number) return varchar2
  is
  l_mv_name varchar2(30);
  begin
   IF (g_apps_schema_name IS NULL) THEN
       g_apps_schema_name := get_apps_schema_name;
  END IF;
   execute immediate ' select name from all_registered_mviews where owner=:1 and mview_id=:2' into l_mv_name using get_apps_schema_name,p_mview_id;
   return l_mv_name;
   exception
   when no_data_found then
--    return null;
      begin
       execute immediate 'select vname from sys.snap$ where snapid=:1' into l_mv_name using p_mview_id;
       return l_mv_name;
       exception
         when no_data_found then
           return null;
         when others then
          logmsg(sqlerrm);
       end;
    when others then
     logmsg(sqlerrm);
  end;
**/

  function check_dissociated(p_mview_name varchar2,p_mview_owner varchar2,p_master varchar2,p_master_owner varchar2) return varchar2
  is
  l_dummy varchar2(30);
  l_stmt varchar2(1000):='
  select ''Dissociated ''
  from dual
  where not exists
  (
    select ''Y''
    from all_registered_mviews a,
         all_base_table_mviews b
    where a.name=:1
    and a.owner=:2
    and a.mview_id=b.mview_id
    and b.master=:3
    and b.owner=:4)
  ';
  begin
    execute immediate   l_stmt into l_dummy using p_mview_name,p_mview_owner,p_master,p_master_owner;

     return l_dummy;
    exception
    when no_data_found then
      return null;
    when others then
      logmsg(sqlerrm);
	  return null;
  end;

function check_last_mv(p_mview_id number,p_master varchar2,p_master_owner varchar2) return varchar2 is
 l_stmt varchar2(1000):='
  select ''Y''
  from dual
  where not exists
  (
   select ''Y''
   from
   all_base_table_mviews
   where owner=:1
   and master=:2
   and mview_id<>:3 )
 ';
 l_dummy varchar2(1);
 begin
    execute immediate l_stmt into l_dummy using p_master_owner,p_master,p_mview_id;
    return l_dummy;
 exception
   when no_data_found then
      return 'N';
   when others then
     logmsg(sqlerrm);
 end;


 function get_root_req_id(p_prog_request_id number) return number is
  cursor c_root_req_id is
   select a.priority_request_id
   from fnd_concurrent_requests a
   where a.request_id =
   (select b.parent_request_id from fnd_concurrent_requests b where b.request_id=p_prog_request_id );
  l_root_req_id number;
  begin
    open c_root_req_id;
    fetch c_root_req_id into l_root_req_id;
    close c_root_req_id;
    return l_root_req_id;
exception
   when others then
    logmsg(sqlerrm);
    return null;
  end;

  procedure insert_into_history(p_mv_name varchar2,p_prog_req_id number)
  is
  l_root_req_id number;
  begin
     --   logmsg('Inserting '||p_mv_name|| ' into RSG history table');
       -- logmsg('p_prog_req_id '||p_prog_req_id);
        l_root_req_id:=get_root_req_id(p_prog_req_id);
       -- logmsg('l_root_req_id '||l_root_req_id);

     if (p_prog_req_id is not null and l_root_req_id is not null )then
       --Enh#4418520-aguwalan
       IF (BIS_CREATE_REQUESTSET.is_history_collect_on(l_root_req_id)) then
         BIS_COLL_RS_HISTORY.insert_program_object_data
	      (
		x_request_id   => p_prog_req_id,
		x_stage_req_id => null,
		x_object_name  => p_mv_name ,
		x_object_type   => 'MV',
		x_refresh_type  => 'CONSIDER_REFRESH',
		x_set_request_id =>l_root_req_id );
       ELSE
         BIS_COLLECTION_UTILITIES.put_line('------------------------------------------------------------------');
         BIS_COLLECTION_UTILITIES.put_line('Request Set History Collection Option is off for this Request Set.');
         BIS_COLLECTION_UTILITIES.put_line('No History Collection will happen for this request set.');
         BIS_COLLECTION_UTILITIES.put_line('------------------------------------------------------------------');
       END IF;
     end if;
  exception
    when others then
      logmsg('Error happened in BIS_COLL_RS_HISTORY.insert_program_object_data: '||sqlerrm);
  end;

---This procedure is added for bug 4406144
--It will compile MVs in RSG with status INVALID
procedure compile_mvs is
cursor c_mvs_from_bop is
	SELECT OBJECT_NAME from BIS_OBJ_PROPERTIES where OBJECT_TYPE = 'MV';
l_mv_rec_bop c_mvs_from_bop%ROWTYPE;
cursor c_mvs_to_compile(mvNameFromBOP varchar2)
is
select
 distinct
 c.object_name mview_name
 from
 all_objects c
where c.object_name=mvNameFromBOP
 and c.owner=g_apps_schema_name
 and c.object_type='MATERIALIZED VIEW'
 and c.status='INVALID';

l_mv_rec c_mvs_to_compile%rowtype;

begin
 bis_collection_utilities.put_line('     ');
 bis_collection_utilities.put_line('Re-compiling INVALID MVs in RSG');
 IF (g_apps_schema_name IS NULL) THEN
   g_apps_schema_name := get_apps_schema_name;
 END IF;
 for l_mv_rec_bop in c_mvs_from_bop  loop
   open c_mvs_to_compile(l_mv_rec_bop.object_name);
   fetch c_mvs_to_compile into l_mv_rec;
   execute immediate 'alter materialized view '||l_mv_rec.mview_name||' compile ';
   bis_collection_utilities.put_line('Compiled '||l_mv_rec.mview_name);
 end loop;
 bis_collection_utilities.put_line('Compiled all INVALID MVs in RSG');
 exception
 when others then
   bis_collection_utilities.put_line(sqlerrm);
   RAISE;
end;



  PROCEDURE CONSIDER_REFRESH(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR2
  ) IS


    TYPE curType IS REF CURSOR ;
    C_CONFREF_LOG_DETAIL curType;
    c_mv_log_for_unimpl_mvs  curType;
    c_mv_id curType;
    c_check_mv_in_rsg curType;
    c_check_mv_valid curType;


l_row_count number;
l_mv_name ALL_MVIEWS.MVIEW_NAME%type;
l_mv_owner ALL_MVIEWS.OWNER%type;
l_mv_last_refresh date;
l_mv_implementation_flag varchar2(1);

---this cursor fetches all MV logs that have
---at least one unimplemented MV on top
l_mv_log_for_unimpl_mvs varchar2(2000):='
select
distinct
l.log_table log_table,
l.log_owner log_owner,
l.master master_name
from
bis_obj_properties a,
all_mviews b,
all_mview_refresh_times t,
all_mview_logs l
where a.object_type=''MV''
and nvl(a.implementation_flag,''N'')=''N''
and a.object_name=b.mview_name
and b.owner=:1
and b.mview_name=t.name
and b.owner=t.owner
and t.master=l.master
and t.master_owner=l.log_owner
order by l.log_owner,l.log_table
';

l_master_name varchar2(30);

---this cursor fetches mview_ids from all_base_table_mviews
l_mv_id varchar2(2000):='
select distinct mview_id
from all_base_table_mviews
where owner=:1
and master=:2'
;

/**
---this cursor checks hanging MV
-- not using sys.snap$ because it is against apps standard
l_check_hanging_mv varchar2(2000):='
select ''Y''
from dual
where not exists
(select mview_id
 from all_registered_mviews
 where mview_id=:1
 and owner=:2)
OR not exists
(select snapid
from sys.snap$
where snapid =:3
and master=:4
and mowner=:5) '
;
**/



/**
l_check_hanging_mv varchar2(2000):='
select distinct a.name
from  all_registered_mviews a,
     all_dependencies  b
where a.mview_id=:1
and a.owner=:2
and a.name=b.name
and a.owner=b.owner
and b.type=''MATERIALIZED VIEW''
and b.REFERENCED_OWNER=:3
and b.REFERENCED_NAME=:4'
;
**/

---modify the cursor for bug 4704633 to improve performance
---in the past we use all_dependencies
l_check_mv_valid varchar2(2000):='
select distinct a.name
from  all_registered_mviews a,
       all_mview_refresh_times b
where a.mview_id=:1
and a.owner=:2
and a.name=b.name
and a.owner=b.owner
and b.master_owner=:3
and b.master=:4'
;

l_valid_mv varchar2(1);

---if the MV doesn't exist in RSG, we need to report it
---as required by BISREL in 4247289
l_check_mv_in_rsg varchar2(2000):='
select nvl(b.implementation_flag,''N'') impl_flag
from
bis_obj_properties b
where b.object_name =:1
and b.object_type=''MV'''
;

l_dummy number;
l_mview_name varchar2(30);


l_impl_flag varchar2(1);
l_log_table            ALL_SNAPSHOT_LOGS.LOG_TABLE%type;
l_log_owner          ALL_SNAPSHOT_LOGS.LOG_OWNER%TYPE;
l_mview_id number;
l_prefix varchar2(30):='  ';
l_prog_req_id number;


 BEGIN

    errbuf  := NULL;
    retcode := '0';
    IF (Not BIS_COLLECTION_UTILITIES.setup('BIS_MV_REFRESH.CONSIDER_REFRESH')) THEN
      RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || errbuf);
      return;
    END IF;

    l_prog_req_id:=fnd_global.CONC_REQUEST_ID;


    logmsg('This program is for RSG internal use only. ');
    logmsg('The purpose of this program is to make sure ');
    logmsg('that shared MV logs by unimplemented MVs can be cleaned up! ');
    logmsg('       ');
    logmsg('Please note that if a MV had already been dissociated from the MV log, it will not be processed again.');
    logmsg('       ');

    IF (g_apps_schema_name IS NULL) THEN
       g_apps_schema_name := get_apps_schema_name;
    END IF;

    open c_mv_log_for_unimpl_mvs for l_mv_log_for_unimpl_mvs using g_apps_schema_name;
    loop
     fetch    c_mv_log_for_unimpl_mvs into l_log_table, l_log_owner,l_master_name;
     exit when c_mv_log_for_unimpl_mvs%notfound;
     logmsg('***********MV log: '||l_log_owner||'.'||l_log_table||' Size: '||get_Table_size(l_log_owner,l_log_table)||' Bytes *******');
     logmsg(l_prefix||'==========Processing MVs ==============   ');

     /**
	 ----debug
	 execute immediate 'select count(*) from '|| l_log_owner||'.'||l_log_table into l_row_count;
     logmsg(l_prefix||'rows in mv log: '||to_char(l_row_count));
     -----end debug
     **/

     open c_mv_id for l_mv_id using l_log_owner,l_master_name;
     loop
        fetch c_mv_id into l_mview_id;
        exit when c_mv_id%notfound;
        logmsg(l_prefix||'mview_id: '||l_mview_id);
        l_dummy:=0;
	 	open c_check_mv_valid for l_check_mv_valid
         	using l_mview_id,g_apps_schema_name,l_log_owner,l_master_name;
	 	--	 using l_mview_id,g_apps_schema_name,l_mview_id,l_master_name,l_log_owner;
		loop
		  fetch c_check_mv_valid into l_mview_name;
		  exit when c_check_mv_valid%notfound;
		  l_dummy:=l_dummy+1;
		  begin
   	        execute immediate l_check_mv_in_rsg into  l_impl_flag using l_mview_name;
   	        if l_impl_flag ='Y' then
               logmsg(l_prefix||l_mview_name||'. Implemented. No action');
            else
               if check_last_mv(l_mview_id,l_master_name,l_log_owner)='Y' then
                 logmsg(l_prefix||'Last MV associated to the MV log.');
               end if;
              logmsg(l_prefix||l_mview_name||'. Unimplemented. Dissociating it');
              purge_log(l_mview_id);
              insert_into_history(l_mview_name,l_prog_req_id);
     	   end if;
   	      exception
   	        when no_data_found then
   	          logmsg(l_prefix||l_mview_name||'. Not in RSG. No action');
   	        when others then
   	          logmsg(l_prefix||sqlerrm);
   	      end;
		end loop;
		close c_check_mv_valid;

        if l_dummy=0 then --The given mview_id is not valid. It doesn't exist
        ------all_registered_mviews or it is defined on the given MV log.
          if check_last_mv(l_mview_id,l_master_name,l_log_owner)='Y' then
             logmsg(l_prefix||'Last MV associated to the MV log.');
         end if;
         logmsg(l_prefix||'No name found. Invalid MV. Dissociating it');
         purge_log(l_mview_id);
       end if;
     end loop;
	 close c_mv_id;
	 logmsg('         ');
    end loop;
    close c_mv_log_for_unimpl_mvs;

   ---added for bug 4406144
   --compile_mvs;        --bug fix 5750596
   g_program_status := fnd_concurrent.set_completion_status(g_program_status_var ,NULL);

  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    errbuf := sqlerrm;
    retcode := sqlcode;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Error occurred:');
    BIS_COLLECTION_UTILITIES.put_line(errbuf);
    g_program_status := fnd_concurrent.set_completion_status('ERROR' ,NULL);

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    0,
    errbuf,
    null,
    null
    );

  END;


   PROCEDURE LOG_DETAIL(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR2
  )
  is


    TYPE curType IS REF CURSOR ;
    C_CONFREF_LOG_DETAIL curType;
    c_mv_log_for_unimpl_mvs  curType;
    c_mv_id curType;
    c_check_mv_in_rsg curType;


l_cur_stmt_log_detail varchar2(2000):='
select
distinct
t.name,
t.owner,
t.last_refresh
from
all_mview_refresh_times t,
all_mview_logs l
where t.master=l.master
and t.master_owner=l.log_owner
and l.log_table=:1
and l.log_owner=:2
order by t.name,t.owner,t.last_refresh
';


l_row_count number;
l_mv_name ALL_MVIEWS.MVIEW_NAME%type;
l_mv_owner ALL_MVIEWS.OWNER%type;
l_mv_last_refresh date;
l_mv_implementation_flag varchar2(1);

---this cursor fetches all MV logs that have
---at least one unimplemented MV on top
l_mv_log_for_unimpl_mvs varchar2(2000):='
select
distinct
l.log_table log_table,
l.log_owner log_owner,
l.master master_name
from
bis_obj_properties a,
all_mviews b,
all_mview_refresh_times t,
all_mview_logs l
where a.object_type=''MV''
and nvl(a.implementation_flag,''N'')=''N''
and a.object_name=b.mview_name
and b.owner=:1
and b.mview_name=t.name
and b.owner=t.owner
and t.master=l.master
and t.master_owner=l.log_owner
order by l.log_owner,l.log_table
';

l_master_name varchar2(30);

---this cursor fetches mview_ids from all_base_table_mviews
l_mv_id varchar2(2000):='
select distinct a.mview_id
from all_base_table_mviews a,
     all_snapshot_logs b
where a.owner=:1
and a.master=b.master
and a.owner=b.LOG_OWNER
and b.log_table=:2'
;


l_dummy number;
l_mview_name varchar2(30);


l_impl_flag varchar2(1);
l_log_table            ALL_SNAPSHOT_LOGS.LOG_TABLE%type;
l_log_owner          ALL_SNAPSHOT_LOGS.LOG_OWNER%TYPE;
l_mview_id number;
l_prefix varchar2(30):='  ';
l_check_dissociated varchar2(30);
 BEGIN

    errbuf  := NULL;
    retcode := '0';
    IF (Not BIS_COLLECTION_UTILITIES.setup('BIS_MV_REFRESH.LOG_DETAIL')) THEN
      RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || errbuf);
      return;
    END IF;


    logmsg('This is a utility program to print out MV log size,MVs and last refresh time on top of MV logs that have unimplemented MVs on top.');
    logmsg('       ');

    IF (g_apps_schema_name IS NULL) THEN
       g_apps_schema_name := get_apps_schema_name;
    END IF;

    open c_mv_log_for_unimpl_mvs for l_mv_log_for_unimpl_mvs using g_apps_schema_name;
    loop
     fetch    c_mv_log_for_unimpl_mvs into l_log_table, l_log_owner,l_master_name;
     exit when c_mv_log_for_unimpl_mvs%notfound;
     logmsg('***********MV log: '||l_log_owner||'.'||l_log_table||'************');
     logmsg(l_prefix||l_log_owner||'.'||l_log_table||': '||get_Table_size(l_log_owner,l_log_table) || ' Bytes');
     open C_CONFREF_LOG_DETAIL for l_cur_stmt_log_detail using l_log_table,l_log_owner;
     loop
    	   fetch C_CONFREF_LOG_DETAIL into l_mv_name,l_mv_owner,l_mv_last_refresh;
	       exit when C_CONFREF_LOG_DETAIL%notfound;
           l_check_dissociated:=check_dissociated(l_mv_name,l_mv_owner,l_master_name, l_log_owner);
           logmsg(l_prefix||l_mv_owner||'.'||l_mv_name||'   '||to_char(l_mv_last_refresh,'DD-MON-YYYY HH24:MI:SS')||'  '||l_check_dissociated);
     end loop;
     close C_CONFREF_LOG_DETAIL;
	 logmsg('         ');
    end loop;
    close c_mv_log_for_unimpl_mvs;

   g_program_status := fnd_concurrent.set_completion_status(g_program_status_var ,NULL);

  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    errbuf := sqlerrm;
    retcode := sqlcode;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Error occurred:');
    BIS_COLLECTION_UTILITIES.put_line(errbuf);
    g_program_status := fnd_concurrent.set_completion_status('ERROR' ,NULL);

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    0,
    errbuf,
    null,
    null
    );

  END;




  PROCEDURE STANDALONE_REFRESH(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR2,
    P_REFRESHMODE          IN VARCHAR2,
    P_MVNAME               IN VARCHAR2
  ) IS
  BEGIN
    errbuf  := NULL;
    retcode := '0';

    DBMS_MVIEW.REFRESH(
                list => p_mvname,
                method => P_REFRESHMODE);

  EXCEPTION
    WHEN OTHERS THEN
      errbuf := sqlerrm;
      retcode := sqlcode;
      RAISE;
  END STANDALONE_REFRESH;



  PROCEDURE REFRESH(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR2,
    P_REFRESHMODE          IN VARCHAR2,
    P_MVNAME               IN VARCHAR2
  ) IS
    l_start                 DATE            := NULL;
    l_end                   DATE            := NULL;
    l_period_from           DATE            := NULL;
    l_from_date             DATE            := NULL;
    l_to_date               DATE            := NULL;
    l_failure               EXCEPTION;
    l_refresh               NUMBER          := 0;
    l_row_count             NUMBER          := 0;
    l_sql_stmt              VARCHAR2(200);

    prog_request_id         number ;
    l_mv_refresh_type       varchar2(30);
    p_final_refresh_mode    varchar2(30);
    l_request_id number;
  BEGIN
    errbuf  := NULL;
    retcode := '0';

     -- get current request id  information from FND to put in Summary report table.
	prog_request_id := FND_GLOBAL.conc_request_id;

    IF (Not BIS_COLLECTION_UTILITIES.setup(P_MVNAME)) THEN
      RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || sqlerrm);
      return;
    END IF;

    BIS_COLLECTION_UTILITIES.put_line('Start refreshing for ' || p_mvname || ', mode ' || P_REFRESHMODE);
    BIS_COLLECTION_UTILITIES.get_last_refresh_dates(
				p_mvname,
				l_start,
				l_end,
				l_period_from,
				l_from_date);
    l_to_date := sysdate;

    IF ( NOT VALIDATE(p_mvname)) THEN
      BIS_COLLECTION_UTILITIES.put_line('Skipped refreshing for ' || P_MVNAME);
    ELSE

   /** Comment out check implementation flag for bug 4532066
     IF( NOT IS_IMPLEMENTED(P_MVNAME)) THEN
        -- never call CONSIDER_REFRESH for individul MV,
        -- a batch task at the end of resquest set will do it for
        -- MVs not implemented.
        -- CONSIDER_REFRESH(P_MVNAME);
        -- Added for bug 3626375 Log Messages
        BIS_COLLECTION_UTILITIES.put_line(p_mvname||' was not refreshed because it was not implemented. It will be marked as refreshed');
        BIS_COLLECTION_UTILITIES.put_line('in ''BIS Materialized View Batch Refresh Program for MVs not to implement'' at the last stage of the request set.');
        -- code end for bug 3626375

    ----	l_mv_refresh_type := 'CONSIDER_REFRESH';

      ELSE      **/

        -- compile the MV before refresh logic,
        -- added for enhancement 2958485.
        RECOMPILE_MV( p_mvname);
        l_refresh := REFRESH_MV(p_mvname, p_refreshmode ,p_final_refresh_mode);
        IF (l_refresh = -1) THEN
          RAISE l_failure;
    	else
        	 l_mv_refresh_type := p_final_refresh_mode;

        END IF;

        -- for bug3724431, removing select count(*)
        -- and use 0 for l_row_count always.
        --l_sql_stmt := 'SELECT count(*) FROM ' || p_mvname ;
        --EXECUTE IMMEDIATE l_sql_stmt INTO l_row_count;
        l_row_count := 0;

        updCacheByTopPortlet(p_mvname);

        BIS_COLLECTION_UTILITIES.put_line('End refreshing for ' || p_mvname);

        -----Here we only record the MV refreshed by BIS MV refresh program
        -----For MVs processed by "BIS Materialized View Batch Refresh Program for MVs not to implement",
        -----we will record them to history table in procedure CONSIDER_REFRESH

        -- Enh#4418520-aguwalan
        IF (BIS_CREATE_REQUESTSET.is_history_collect_on(FND_GLOBAL.CONC_PRIORITY_REQUEST)) THEN
          BIS_COLL_RS_HISTORY.insert_program_object_data
	      (
		x_request_id   => prog_request_id,
		x_stage_req_id => null,
		x_object_name  => P_MVNAME ,
		x_object_type   => 'MV',
		x_refresh_type  => l_mv_refresh_type,
		x_set_request_id => FND_GLOBAL.CONC_PRIORITY_REQUEST);
        ELSE
           BIS_COLLECTION_UTILITIES.put_line('------------------------------------------------------------------');
           BIS_COLLECTION_UTILITIES.put_line('Request Set History Collection Option is off for this Request Set.');
           BIS_COLLECTION_UTILITIES.put_line('No History Collection will happen for this request set.');
           BIS_COLLECTION_UTILITIES.put_line('------------------------------------------------------------------');
        END IF;

     --- END IF; -- end NOT IS_IMPLEMENTED  comment out check for impl flag for bug 4532066
    END IF; -- end NOT VALIDATE

    g_program_status := fnd_concurrent.set_completion_status(g_program_status_var ,NULL);


    BIS_COLLECTION_UTILITIES.WRAPUP(
      TRUE,             -- status
      l_row_count,      -- count
      NULL,             -- message
      l_from_date,      -- period_from
      l_to_date);       -- period_to

    BIS_COLLECTION_UTILITIES.put_line(' ');

  EXCEPTION
  WHEN L_FAILURE THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Error occurred:');
    BIS_COLLECTION_UTILITIES.put_line(g_errbuf);
    retcode := to_char(g_errcode);
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    l_row_count,
    g_errbuf,
    l_from_date,
    l_to_date
    );

  WHEN OTHERS THEN
    ROLLBACK;
    errbuf := sqlerrm;
    retcode := sqlcode;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Error occurred:');
    BIS_COLLECTION_UTILITIES.put_line(errbuf);

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    l_row_count,
    errbuf,
    l_from_date,
    l_to_date
    );
  END REFRESH;
/*
  PROCEDURE collect_mv_refresh_info(
    errbuf            OUT NOCOPY VARCHAR2,
    retcode           OUT NOCOPY VARCHAR2,
    p_request_id      IN NUMBER,
    p_object_name     IN VARCHAR2,
    p_refresh_type    IN VARCHAR2,
    p_set_request_id  IN NUMBER
  )
  IS
  BEGIN
    BIS_COLLECTION_UTILITIES.put_line('Program to collect the data about MV refresh required by RSG Analysis Report');
    BIS_COLLECTION_UTILITIES.put_line('MV Refresh Program Request Id # '|| p_request_id);
    BIS_COLLECTION_UTILITIES.put_line('MV Name '|| p_object_name);
    BIS_COLLECTION_UTILITIES.put_line('Refresh Type '|| p_refresh_type);

    BIS_COLL_RS_HISTORY.insert_program_object_data(x_request_id     => p_request_id,
                                                   x_stage_req_id   => null,
                                                   x_object_name    => p_object_name ,
                                                   x_object_type    => 'MV',
                                                   x_refresh_type   => p_refresh_type,
                                                   x_set_request_id => p_set_request_id);

    BIS_COLLECTION_UTILITIES.put_line('Completed data collection about MV refresh required by RSG Analysis Report');
  EXCEPTION
    WHEN OTHERS THEN
      errbuf := sqlerrm;
      retcode := sqlcode;
      BIS_COLLECTION_UTILITIES.put_line('Exception in collect_mv_refresh_info :: '|| sqlcode || ' :: ' ||sqlerrm);
      RAISE;
  END;
*/
  PROCEDURE COMPILE_INVALID_MVS(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR2
  ) IS
    l_refresh_progs number;
    e_refresh_prog_running EXCEPTION;
    l_program_status  boolean := true;
  BEGIN
    BIS_COLLECTION_UTILITIES.put_line('Starting Compiling Invalid MVs');
    BIS_COLLECTION_UTILITIES.put_line(' ');
    l_refresh_progs := BIS_TRUNCATE_EMPTY_MV_LOG_PKG.Check_Refresh_Prog_running;
    if(l_refresh_progs <> 0) then
      raise e_refresh_prog_running;
    end if;
    compile_mvs;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Completing Compiling Invalid MVs');
  EXCEPTION
    WHEN e_refresh_prog_running THEN
      BIS_COLLECTION_UTILITIES.put_line(' ');
      IF (l_refresh_progs = 1) THEN
        BIS_COLLECTION_UTILITIES.put_line('Error in Compiling Invalid MVs- DBI Refresh program is running' );
      ELSE
        BIS_COLLECTION_UTILITIES.put_line('Error in Compiling Invalid MVs - MV is being refreshed' );
      END IF;
      BIS_COLLECTION_UTILITIES.put_line('Please run Compiling Invalid MVs when there are no Refresh request-set/programs running');
      l_program_status := fnd_concurrent.set_completion_status('Error' ,NULL);
      errbuf := 'DBI Refresh Program Running';
    WHEN OTHERS THEN
      BIS_COLLECTION_UTILITIES.put_line('Error in Compiling Invalid MVs '|| sqlerrm);
      l_program_status := fnd_concurrent.set_completion_status('Error' ,NULL);
      errbuf := sqlerrm;
      retcode := sqlcode;
  END;

END BIS_MV_REFRESH;

/
