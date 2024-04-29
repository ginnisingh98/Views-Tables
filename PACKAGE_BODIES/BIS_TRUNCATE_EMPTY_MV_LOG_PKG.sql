--------------------------------------------------------
--  DDL for Package Body BIS_TRUNCATE_EMPTY_MV_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_TRUNCATE_EMPTY_MV_LOG_PKG" AS
/*$Header: BISTEMLB.pls 120.1 2006/02/09 05:43 aguwalan noship $*/

/****************************************************************************
--  Is_Refresh_Pgm_running
--  DESCRIPTION:
--    Checks if any Refrest program is running in the system.
--    Returns 1 if there is any refresh request set running
--            2 if there is any MV refresh program running
--            3 if there is any MV being refreshed
--            0 if none of the above condition is true
--****************************************************************************/
FUNCTION Check_Refresh_Prog_running
return number
IS
  CURSOR rs_running IS
    select distinct bis.request_set_name Name, cr.phase_code Phase, cr.request_id request, cr.requested_start_date s_date
    from bis_request_set_objects bis, fnd_request_sets fnd , fnd_concurrent_requests cr
    where bis.request_set_name = fnd.request_set_name
      and bis.set_app_id = fnd.application_id
      and cr.phase_code = 'R'
      and to_char(fnd.application_id) = cr.argument1
      and to_char(fnd.request_set_id) = cr.argument2
      and cr.argument4 is null;
  rs_running_rec rs_running%rowtype;

  CURSOR mv_refresh_prog IS
    SELECT obj.object_name Name, req.request_id request
    FROM fnd_concurrent_programs prog, fnd_concurrent_requests req, bis_obj_properties obj
    WHERE (prog.concurrent_program_name = 'BIS_MV_REFRESH_STANDALONE' OR prog.concurrent_program_name = 'BIS_MV_REFRESH')
     AND prog.application_id = 191
     AND prog.concurrent_program_id = req.concurrent_program_id
     AND req.phase_code = 'R'
	 AND obj.object_type = 'MV'
	 AND req.argument2 = obj.object_name;
  mv_refresh_prog_rec mv_refresh_prog%rowtype;

  CURSOR mv_refresh IS
    SELECT currmvname name
    FROM v$mvrefresh mv,  bis_obj_properties obj
    WHERE obj.object_name = currmvname;
  mv_refresh_rec mv_refresh%rowtype;

  prog_running number;
  l_program_status  boolean  :=true;

BEGIN
  prog_running := 0;
  OPEN rs_running;
  BIS_COLLECTION_UTILITIES.put_line('Checking if DBI Refresh Request Sets are running ...');
  BIS_COLLECTION_UTILITIES.put_line(' ');
  LOOP
    FETCH rs_running INTO rs_running_rec;
    EXIT WHEN rs_running%NOTFOUND;
    prog_running := 1;
    BIS_COLLECTION_UTILITIES.put_line(' - ' || rs_running_rec.Name||'(Req. Id:'||rs_running_rec.request||') Phase:'|| rs_running_rec.Phase || ' Started:' ||  to_char(rs_running_rec.s_Date,'DD-MON-YY HH24:MI:SS'));
  END LOOP;

  IF (prog_running <> 0) THEN
    RETURN prog_running;
  END IF;

  BIS_COLLECTION_UTILITIES.put_line('Checking if MV Refresh Program are running ...');
  BIS_COLLECTION_UTILITIES.put_line(' ');
  OPEN mv_refresh_prog;
  LOOP
    FETCH mv_refresh_prog INTO mv_refresh_prog_rec;
    EXIT WHEN mv_refresh_prog%NOTFOUND;
    prog_running := 2;
    BIS_COLLECTION_UTILITIES.put_line(' - ' || mv_refresh_prog_rec.Name||'(Req. Id:'||mv_refresh_prog_rec.request||') - Getting Refreshed');
  END LOOP;
  CLOSE mv_refresh_prog;

  IF (prog_running <> 0) THEN
    RETURN prog_running;
  END IF;

  BIS_COLLECTION_UTILITIES.put_line('Checking if any MV being refreshed ...');
  BIS_COLLECTION_UTILITIES.put_line(' ');
  OPEN mv_refresh;
  LOOP
    FETCH mv_refresh INTO mv_refresh_rec;
    EXIT WHEN mv_refresh%NOTFOUND;
    prog_running := 3;
    BIS_COLLECTION_UTILITIES.put_line(' - ' || mv_refresh_rec.Name ||' - Getting Refreshed');
  END LOOP;
  CLOSE mv_refresh;

  RETURN prog_running;
EXCEPTION
  WHEN OTHERS THEN
    BIS_COLLECTION_UTILITIES.put_line('Error in Check_Refresh_Prog_running '|| sqlerrm);
    l_program_status := fnd_concurrent.set_completion_status('Error' ,NULL);
END;


/****************************************************************************
--  getMVLogSize
--  DESCRIPTION:
--   Gets the space occupied by the MV Log in Bytes
--****************************************************************************/
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

/****************************************************************************
--  Truncate_Empty_MV_Log
--  DESCRIPTION:
--    Truncates Empty MV Logs to improve performance issues of Refresh
--    programs
--****************************************************************************/
PROCEDURE Truncate_Empty_MV_Log( errbuf   OUT  NOCOPY VARCHAR2
                                ,retcode  OUT  NOCOPY VARCHAR
                                ,threshold IN  NUMBER)
IS
  TYPE curType IS REF CURSOR ;
  cursor impl_tables is
    select object_name, BIS_CREATE_REQUESTSET.get_object_owner(object_name, object_type) obj_owner
    from bis_obj_properties
    where (object_type = 'TABLE' OR object_type = 'MV');
  impl_tables_rec impl_tables%rowtype;

  cursor log_table(obj_name varchar2, obj_owner varchar2) is
    select log_table, log_owner
    from All_SNAPSHOT_LOGS LOG
    where log.master = obj_name
    and log.log_owner = obj_owner;
  log_table_rec log_table%rowtype;

  l_stmt varchar2(1000);
  l_flag number;
  c1 curType;
  e_refresh_prog_running EXCEPTION;
  l_program_status  boolean := true;
  l_refresh_progs number;
  l_threshold_bytes number;
  default_threshold number := 80;
BEGIN
  BIS_COLLECTION_UTILITIES.put_line('Starting Truncate Empty MV Logs');
  BIS_COLLECTION_UTILITIES.put_line(' ');
  l_refresh_progs := Check_Refresh_Prog_running;
  if(l_refresh_progs <> 0) then
    raise e_refresh_prog_running;
  end if;

  if (threshold is null) then
    l_threshold_bytes := default_threshold * 1024 * 1024;
    BIS_COLLECTION_UTILITIES.put_line('Threshold for Empty MV Logs (by default) = ' || to_char(default_threshold) || 'MB');
  else
    l_threshold_bytes := threshold * 1024 * 1024;
    BIS_COLLECTION_UTILITIES.put_line('Threshold for Empty MV Logs = ' || to_char(threshold) || 'MB');
  end if;

  open impl_tables;
  BIS_COLLECTION_UTILITIES.put_line(RPAD('Object Name',35,' ') || RPAD('Owner',10,' ') || RPAD('Log table name',35,' ')  ||'  Action');
  loop
    fetch impl_tables into impl_tables_rec;
    exit when impl_tables%notfound;
    if(impl_tables_rec.obj_owner = 'NOTFOUND' ) then
      impl_tables_rec.obj_owner := 'APPS';
    end if;
    open log_table(impl_tables_rec.object_name,impl_tables_rec.obj_owner);
    loop
      fetch log_table into log_table_rec;
      exit when log_table%notfound;
      begin
        l_stmt := 'select /*+ FIRST_ROWS */ 1 from '|| log_table_rec.log_owner ||'.'|| log_table_rec.log_table ||' where rownum=1';
        open c1 for l_stmt;
        fetch c1 into l_flag;
        if (c1%NotFound) then
          if (get_Table_size(impl_tables_rec.obj_owner,log_table_rec.log_table) >= l_threshold_bytes) then
            l_stmt := 'TRUNCATE TABLE '|| impl_tables_rec.obj_owner || '.' ||log_table_rec.log_table;
            execute immediate l_stmt;
            BIS_COLLECTION_UTILITIES.put_line(RPAD(impl_tables_rec.object_name,35,' ') || RPAD(impl_tables_rec.obj_owner,10,' ') || RPAD(log_table_rec.log_table,35,' ') ||'  Truncated');
          else
            BIS_COLLECTION_UTILITIES.put_line(RPAD(impl_tables_rec.object_name,35,' ') || RPAD(impl_tables_rec.obj_owner,10,' ') || RPAD(log_table_rec.log_table,35,' ') ||'  Empty under threshold');
          end if;
        else
          BIS_COLLECTION_UTILITIES.put_line(RPAD(impl_tables_rec.object_name,35,' ') || RPAD(impl_tables_rec.obj_owner,10,' ') || RPAD(log_table_rec.log_table,35,' ') ||'  Not Empty');
        end if;
        close c1;
      exception
        when others then
          BIS_COLLECTION_UTILITIES.put_line(RPAD(impl_tables_rec.object_name,35,' ') || RPAD(impl_tables_rec.obj_owner,10,' ') ||  'Exception while accessing ' ||log_table_rec.log_table || ': ' || sqlerrm);
          if (c1%isopen) then
            close c1;
          end if;
        end;
    end loop;
    close log_table;
  end loop;
  close impl_tables;
  BIS_COLLECTION_UTILITIES.put_line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Completing Truncate Empty MV Logs');

EXCEPTION
  WHEN e_refresh_prog_running THEN
    BIS_COLLECTION_UTILITIES.put_line(' ');
    IF (l_refresh_progs = 1) THEN
      BIS_COLLECTION_UTILITIES.put_line('Error in Truncate Empty MV Logs - DBI Refresh program is running' );
    ELSE
      BIS_COLLECTION_UTILITIES.put_line('Error in Truncate Empty MV Logs - MV is being refreshed' );
    END IF;
    BIS_COLLECTION_UTILITIES.put_line('Please run Truncate Empty MV Logs when there are no Refresh request-set/programs running');
    l_program_status := fnd_concurrent.set_completion_status('Error' ,NULL);
    errbuf := 'DBI Refresh Program Running';
  WHEN OTHERS THEN
    BIS_COLLECTION_UTILITIES.put_line('Error in Truncate Empty MV Logs '|| sqlerrm);
    l_program_status := fnd_concurrent.set_completion_status('Error' ,NULL);
    errbuf := sqlerrm;
    retcode := sqlcode;
END;

END BIS_TRUNCATE_EMPTY_MV_LOG_PKG;

/
