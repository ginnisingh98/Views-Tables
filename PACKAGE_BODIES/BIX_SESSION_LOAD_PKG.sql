--------------------------------------------------------
--  DDL for Package Body BIX_SESSION_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_SESSION_LOAD_PKG" AS
/*$Header: bixagtlb.plb 120.1 2006/03/28 22:34:53 pubalasu noship $ */

  g_request_id                  NUMBER;
  g_program_appl_id             NUMBER;
  g_program_id                  NUMBER;
  g_user_id                     NUMBER;
  g_bix_schema                  VARCHAR2(30) := 'BIX';
  g_commit_chunk_size           NUMBER;
  g_rows_ins_upd                NUMBER;
  g_collect_start_date          DATE;
  g_collect_end_date            DATE;
  g_sysdate                     DATE;
  g_debug_flag                  VARCHAR2(1)  := 'N';
  g_agent_cost                  NUMBER;

  g_errbuf                      VARCHAR2(1000);
  g_retcode                     VARCHAR2(10) := 'S';

  G_OLTP_CLEANUP_ISSUE          EXCEPTION;
  G_TIME_DIM_MISSING            EXCEPTION;

  TYPE g_session_id_tab IS TABLE OF ieu_sh_sessions.session_id%TYPE;
  TYPE g_activity_id_tab IS TABLE OF ieu_sh_activities.activity_id%TYPE;
  TYPE g_resource_id_tab IS TABLE OF ieu_sh_sessions.resource_id%TYPE;
  TYPE g_begin_date_time_tab IS TABLE OF ieu_sh_sessions.begin_date_time%TYPE;
  TYPE g_end_date_time_tab IS TABLE OF ieu_sh_sessions.end_date_time%TYPE;
  TYPE g_server_group_id_tab IS TABLE OF jtf_rs_resource_extns.server_group_id%TYPE;
  TYPE g_application_id_tab IS TABLE OF ieu_sh_sessions.application_id%TYPE;
  TYPE g_schedule_id_tab IS TABLE OF ams_campaign_schedules_b.schedule_id%TYPE;
  TYPE g_campaign_id_tab IS TABLE OF ams_campaign_schedules_b.campaign_id%TYPE;

PROCEDURE Write_Log (p_msg IN VARCHAR2) IS
BEGIN
  IF (g_debug_flag = 'Y') THEN
    BIS_COLLECTION_UTILITIES.log(p_msg);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Write_Log;

PROCEDURE truncate_table (p_table_name in varchar2) is

  l_stmt varchar2(400);
BEGIN
  write_log('Start of the procedure truncate_table at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  l_stmt:='truncate table '||g_bix_schema||'.'|| p_table_name;
  execute immediate l_stmt;

  write_log('Table ' || p_table_name || ' has been truncated');
  write_log('Finished procedure truncate_table at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in truncate_table : Error : ' || sqlerrm);
    RAISE;
END truncate_table;

PROCEDURE init
IS

  l_status   VARCHAR2(30);
  l_industry VARCHAR2(30);
BEGIN

  IF (BIS_COLLECTION_UTILITIES.SETUP('BIX_AGENT_SESSION_F') = FALSE) THEN
    RAISE_APPLICATION_ERROR(-20000, 'BIS_COLLECTION_UTILITIES.setup has failed');
  END IF;

  write_log('Start of the procedure init at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  write_log('Initializing global variables');
  g_request_id        := FND_GLOBAL.CONC_REQUEST_ID();
  g_program_appl_id   := FND_GLOBAL.PROG_APPL_ID();
  g_program_id        := FND_GLOBAL.CONC_PROGRAM_ID();
  g_user_id           := FND_GLOBAL.USER_ID();
  g_sysdate           := SYSDATE;
  g_commit_chunk_size := 10000;
  g_rows_ins_upd      := 0;
  g_agent_cost        := 0;

  write_log('Getting Commit Size');
  IF (FND_PROFILE.DEFINED('BIX_DM_DELETE_SIZE')) THEN
    g_commit_chunk_size := TO_NUMBER(FND_PROFILE.VALUE('BIX_DM_DELETE_SIZE'));
  END IF;
  write_log('Commit SIZE : ' || g_commit_chunk_size);

  write_log('Getting Debug Information');
  IF (FND_PROFILE.DEFINED('BIX_DBI_DEBUG')) THEN
    g_debug_flag := nvl(FND_PROFILE.VALUE('BIX_DBI_DEBUG'), 'N');
  END IF;
  write_log('Debug Flag : ' || g_debug_flag);

--
--Comment this out since it is not used - sometimes it causes character to number conversion error if it has decimals
--
  --write_log('Getting Agent Cost');
  --IF (FND_PROFILE.DEFINED('BIX_DM_AGENT_COST')) THEN
    --g_agent_cost := TO_NUMBER(FND_PROFILE.VALUE('BIX_DM_AGENT_COST')) / 3600;
  --END IF;

  write_log('Agent Cost : ' || g_agent_cost);

  write_log('Getting schema information');
  IF(FND_INSTALLATION.GET_APP_INFO('BIX', l_status, l_industry, g_bix_schema)) THEN
     NULL;
  END IF;
  write_log('BIX Schema : ' || g_bix_schema);

  write_log('Truncating tables');
  BIS_COLLECTION_UTILITIES.deleteLogForObject('BIX_AGENT_SESSION_F');
  Truncate_Table('BIX_AGENT_SESSION_F');
  Truncate_Table('BIX_SESSIONS');
  Truncate_Table('BIX_AGENT_SESSION_STG');


  write_log('Setting the sort and hash are size');
  execute immediate 'alter session set sort_area_size=1048576000';
  execute immediate 'alter session set hash_area_size=1048576000';

  write_log('Finished procedure init at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in init : Error : ' || sqlerrm);
    RAISE;
END init;

PROCEDURE clean_up IS

BEGIN
  write_log('Start of the procedure clean_up at ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));

  write_log('Truncating the tables');
  BIS_COLLECTION_UTILITIES.deleteLogForObject('BIX_AGENT_SESSION_F');
  Truncate_Table('BIX_AGENT_SESSION_F');
  Truncate_Table('BIX_SESSIONS');
  Truncate_Table('BIX_AGENT_SESSION_STG');

  write_log('Finished procedure clean_up at ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in cleaning up the tables : Error : ' || sqlerrm);
    RAISE;
END CLEAN_UP;

PROCEDURE collect_idle_time IS
BEGIN

  write_log('Start of the procedure collect_idle_time at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  INSERT /*+ append parallel(bss) */ INTO bix_agent_session_stg bss
     (bss.agent_id,
      bss.server_group_id,
      bss.schedule_id,
      bss.campaign_id,
      bss.application_id,
      bss.time_id,
      bss.period_type_id,
      bss.period_start_date,
      bss.period_start_time,
      bss.day_of_week,
      bss.created_by,
      bss.creation_date,
      bss.last_updated_by,
      bss.last_update_date,
      bss.idle_time,
      bss.request_id,
      bss.program_application_id,
      bss.program_id,
      bss.program_update_date )
  (SELECT /*+ parallel(bas) */
      bas.agent_id,
      bas.server_group_id,
      -1,
      -1,
      bas.application_id,
      bas.time_id,
      bas.period_type_id,
      bas.period_start_date,
      bas.period_start_time,
      bas.day_of_week,
      g_user_id,
      g_sysdate,
      g_user_id,
      g_sysdate,
      decode(nvl(sum(bas.login_time),0) - nvl(sum(bas.work_time), 0), 0, to_number(null),
                   nvl(sum(bas.login_time),0) - nvl(sum(bas.work_time), 0)),
      g_request_id,
      g_program_appl_id,
      g_program_id,
      g_sysdate
   FROM  bix_agent_session_stg bas
   WHERE bas.application_id = 696
   GROUP BY
      bas.agent_id,
      bas.server_group_id,
      bas.application_id,
      bas.time_id,
      bas.period_type_id,
      bas.period_start_date,
      bas.period_start_time,
      bas.day_of_week);

  COMMIT;

  write_log('Finished procedure collect_idle_time at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure collect_idle_time : Error : ' || sqlerrm);
    RAISE;
END collect_idle_time;

PROCEDURE insert_available_row(p_activity_id         in  g_activity_id_tab,
                               p_agent_id            in  g_resource_id_tab,
                               p_activity_begin_date in  g_begin_date_time_tab,
                               p_activity_end_date   in  g_end_date_time_tab,
                               p_server_group_id     in  g_server_group_id_tab,
                               p_application_id      in  g_application_id_tab,
                               p_schedule_id         in  g_schedule_id_tab,
                               p_campaign_id         in  g_campaign_id_tab)
IS
  TYPE available_time_tab is TABLE OF bix_agent_session_f.available_time%TYPE;

  l_agent_id g_resource_id_tab;
  l_period_start_date g_begin_date_time_tab;
  l_available_time available_time_tab;
  l_server_group_id g_server_group_id_tab;
  l_application_id g_application_id_tab;
  l_schedule_id g_schedule_id_tab;
  l_campaign_id g_campaign_id_tab;

  l_begin_date    DATE;
  l_end_date      DATE;
  l_period_start  DATE;
  l_row_counter   NUMBER;
  l_work_start    DATE;
  l_work_end      DATE;
  l_secs          NUMBER;
  j               NUMBER;
BEGIN
  write_log('Start of the procedure insert_available_row at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* Initialize all the variables */
  j := 0;
  l_agent_id := g_resource_id_tab();
  l_period_start_date := g_begin_date_time_tab();
  l_server_group_id := g_server_group_id_tab();
  l_application_id := g_application_id_tab();
  l_available_time := available_time_tab();
  l_schedule_id := g_schedule_id_tab();
  l_campaign_id := g_campaign_id_tab();

  /* Loop through all the activities rows returned by the cursor */
  FOR i in p_activity_id.FIRST .. p_activity_id.LAST LOOP
    l_begin_date := p_activity_begin_date(i);

    l_end_date := p_activity_end_date(i);

    IF (l_begin_date < l_end_date) THEN
      /* Get the half hour bucket of the session begin date time */
      SELECT trunc(l_begin_date)
      INTO l_period_start
      FROM DUAL;

      l_row_counter := 0; /* Variable to identify the first row of the session in the while loop */

      /* Loop through the session record and insert a record for each half hour bucket */
      WHILE ( l_period_start < l_end_date )
      LOOP
        j := j + 1;
        IF (l_row_counter = 0 )
        THEN
          l_work_start := l_begin_date;
        ELSE
          l_work_start := l_period_start;
        END IF;

        l_work_end := l_period_start + 1;
        IF ( l_work_end > l_end_date )
        THEN
          l_work_end := l_end_date ;
        END IF;

        l_secs := round((l_work_end - l_work_start) * 24 * 3600);

        l_agent_id.extend(1);
        l_period_start_date.extend(1);
        l_server_group_id.extend(1);
        l_application_id.extend(1);
        l_schedule_id.extend(1);
        l_campaign_id.extend(1);
        l_available_time.extend(1);

        l_agent_id(j) := p_agent_id(i);
        l_period_start_date(j) := l_period_start;
        l_server_group_id(j) := p_server_group_id(i);
        l_application_id(j) := p_application_id(i);
        l_schedule_id(j) := p_schedule_id(i);
        l_campaign_id(j) := p_campaign_id(i);
        l_available_time(j) := l_secs;

        l_row_counter := l_row_counter + 1;
        l_period_start := l_period_start + 1;

      END LOOP;  -- end of WHILE loop
    END IF; /* end if (l_begin_date > l_end_date) */
  END LOOP;

  /* Bulk insert all the rows in the staging area */
  IF (l_agent_id.COUNT > 0) THEN
    FORALL i IN l_agent_id.FIRST .. l_agent_id.LAST
    INSERT /*+ append */ INTO bix_agent_session_stg bas (
       bas.agent_id
      ,bas.server_group_id
      ,bas.schedule_id
      ,bas.campaign_id
      ,bas.application_id
      ,bas.time_id
      ,bas.period_type_id
      ,bas.period_start_date
      ,bas.period_start_time
      ,bas.day_of_week
      ,bas.last_update_date
      ,bas.last_updated_by
      ,bas.creation_date
      ,bas.created_by
      ,bas.last_update_login
      ,bas.available_time
      ,bas.request_id
      ,bas.program_application_id
      ,bas.program_id
      ,bas.program_update_date)
    VALUES (
       l_agent_id(i)
      ,l_server_group_id(i)
      ,l_schedule_id(i)
      ,l_campaign_id(i)
      ,l_application_id(i)
      ,to_number(to_char(l_period_start_date(i), 'J'))
      ,1
      ,TRUNC(l_period_start_date(i))
      ,'00:00'
      ,TO_CHAR(l_period_start_date(i),'D')
      ,g_sysdate
      ,g_user_id
      ,g_sysdate
      ,g_user_id
      ,g_user_id
      ,decode(l_available_time(i), 0, to_number(null), l_available_time(i))
      ,g_request_id
      ,g_program_appl_id
      ,g_program_id
      ,g_sysdate);
  END IF;

  write_log('Total rows inserted in the staging area for half hour time bucket : ' || to_char(l_agent_id.COUNT));

  write_log('Finished procedure insert_available_row at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in insert_available_row : Error : ' || sqlerrm);
    RAISE;
END insert_available_row;

PROCEDURE collect_available_time IS
  CURSOR get_available_time IS
  SELECT /*+ parallel(iss) parallel(isa1) parallel(isa2) parallel(bis1) parallel(res) parallel(csh)
             pq_distribute(iss hash,hash) pq_distribute(isa1 hash,hash)
             pq_distribute(isa2 hash,hash) pq_distribute(bis1 hash,hash)
             pq_distribute(res hash,hash) pq_distribute(csh hash,hash)
             use_hash(iss,isa1,isa2,bis1,res,csh) */
     isa1.activity_id                              activity_id
    ,iss.resource_id                               resource_id
    ,isa1.begin_date_time                          begin_date_time
    ,nvl(isa1.deliver_date_time, nvl(isa1.end_date_time, isa1.begin_date_time))
                                                   end_date_time
    ,nvl(res.server_group_id,-1)                   server_group_id
    ,iss.application_id                            application_id
    ,decode(isa2.category_type, 'CSCH', nvl(csh.schedule_id, -1), -1)
                                                   schedule_id
    ,decode(isa2.category_type, 'CSCH', nvl(csh.campaign_id, -1), -1)
                                                   campaign_id
  FROM
     ieu_sh_sessions iss
    ,ieu_sh_activities isa1
    ,ieu_sh_activities isa2
    ,jtf_rs_resource_extns res
    ,ams_campaign_schedules_b csh
  WHERE isa1.last_update_date > g_collect_start_date
  AND   isa1.last_update_date <= g_collect_end_date
  AND   iss.session_id = isa1.session_id
  AND   iss.application_id = 696
  AND   isa1.activity_type_code = 'MEDIA'
  AND   isa1.parent_cycle_id = isa2.activity_id
  AND   isa2.activity_type_code = 'MEDIA_CYCLE'
  AND   iss.resource_id = res.resource_id
  AND   decode(isa2.category_type, 'CSCH', to_number(nvl(isa2.category_value, -1)), -1) = csh.schedule_id(+);

  l_activity_id g_activity_id_tab;
  l_resource_id g_resource_id_tab;
  l_begin_date_time g_begin_date_time_tab;
  l_end_date_time g_end_date_time_tab;
  l_server_group_id g_server_group_id_tab;
  l_application_id g_application_id_tab;
  l_schedule_id g_schedule_id_tab;
  l_campaign_id g_campaign_id_tab;

  l_no_of_records  NUMBER;
BEGIN

  write_log('Start of the procedure collect_available_time at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  OPEN get_available_time;

  LOOP
    /* Fetch the activity rows in bulk and process them row by row */
    FETCH get_available_time BULK COLLECT INTO
      l_activity_id,
      l_resource_id,
      l_begin_date_time,
      l_end_date_time,
      l_server_group_id,
      l_application_id,
      l_schedule_id,
      l_campaign_id
    LIMIT g_commit_chunk_size;

    l_no_of_records := l_activity_id.COUNT;

    IF (l_no_of_records > 0) THEN
      insert_available_row(
        l_activity_id,
        l_resource_id,
        l_begin_date_time,
        l_end_date_time,
        l_server_group_id,
        l_application_id,
        l_schedule_id,
        l_campaign_id);

      l_activity_id.TRIM(l_no_of_records);
      l_resource_id.TRIM(l_no_of_records);
      l_begin_date_time.TRIM(l_no_of_records);
      l_end_date_time.TRIM(l_no_of_records);
      l_server_group_id.TRIM(l_no_of_records);
      l_application_id.TRIM(l_no_of_records);
      l_schedule_id.TRIM(l_no_of_records);
      l_campaign_id.TRIM(l_no_of_records);
    END IF;

    EXIT WHEN get_available_time%NOTFOUND;

  END LOOP;

  CLOSE get_available_time;

  COMMIT;

  write_log('Finished procedure collect_available_time at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure collect_available_time : Error : ' || sqlerrm);
    IF (get_available_time%ISOPEN) THEN
      CLOSE get_available_time;
    END IF;
    RAISE;
END collect_available_time;

PROCEDURE insert_work_row(p_activity_id         in  g_activity_id_tab,
                          p_agent_id            in  g_resource_id_tab,
                          p_activity_begin_date in  g_begin_date_time_tab,
                          p_activity_end_date   in  g_end_date_time_tab,
                          p_server_group_id     in  g_server_group_id_tab,
                          p_application_id      in  g_application_id_tab,
                          p_schedule_id         in  g_schedule_id_tab,
                          p_campaign_id         in  g_campaign_id_tab)
IS
  TYPE work_time_tab is TABLE OF bix_agent_session_f.work_time%TYPE;

  l_agent_id g_resource_id_tab;
  l_period_start_date g_begin_date_time_tab;
  l_work_time work_time_tab;
  l_server_group_id g_server_group_id_tab;
  l_application_id g_application_id_tab;
  l_schedule_id g_schedule_id_tab;
  l_campaign_id g_campaign_id_tab;

  l_begin_date    DATE;
  l_end_date      DATE;
  l_period_start  DATE;
  l_row_counter   NUMBER;
  l_work_start    DATE;
  l_work_end      DATE;
  l_secs          NUMBER;
  j               NUMBER;
BEGIN
  write_log('Start of the procedure insert_work_row at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* Initialize all the variables */
  j := 0;
  l_agent_id := g_resource_id_tab();
  l_period_start_date := g_begin_date_time_tab();
  l_server_group_id := g_server_group_id_tab();
  l_application_id := g_application_id_tab();
  l_work_time := work_time_tab();
  l_schedule_id := g_schedule_id_tab();
  l_campaign_id := g_campaign_id_tab();

  /* Loop through all the activities rows returned by the cursor */
  FOR i in p_activity_id.FIRST .. p_activity_id.LAST LOOP
    l_begin_date := p_activity_begin_date(i);

    l_end_date := p_activity_end_date(i);

    IF (l_begin_date < l_end_date) THEN
      /* Get the half hour bucket of the session begin date time */
      SELECT trunc(l_begin_date)
      INTO l_period_start
      FROM DUAL;

      l_row_counter := 0; /* Variable to identify the first row of the session in the while loop */

      /* Loop through the session record and insert a record for each half hour bucket */
      WHILE ( l_period_start < l_end_date )
      LOOP
        j := j + 1;
        IF (l_row_counter = 0 )
        THEN
          l_work_start := l_begin_date;
        ELSE
          l_work_start := l_period_start;
        END IF;

        l_work_end := l_period_start + 1;
        IF ( l_work_end > l_end_date )
        THEN
          l_work_end := l_end_date ;
        END IF;

        l_secs := round((l_work_end - l_work_start) * 24 * 3600);

        l_agent_id.extend(1);
        l_period_start_date.extend(1);
        l_server_group_id.extend(1);
        l_application_id.extend(1);
        l_schedule_id.extend(1);
        l_campaign_id.extend(1);
        l_work_time.extend(1);

        l_agent_id(j) := p_agent_id(i);
        l_period_start_date(j) := l_period_start;
        l_server_group_id(j) := p_server_group_id(i);
        l_application_id(j) := p_application_id(i);
        l_schedule_id(j) := p_schedule_id(i);
        l_campaign_id(j) := p_campaign_id(i);
        l_work_time(j) := l_secs;

        l_row_counter := l_row_counter + 1;
        l_period_start := l_period_start + 1;

      END LOOP;  -- end of WHILE loop
    END IF; /* end if (l_begin_date > l_end_date) */
  END LOOP;

  /* Bulk insert all the rows in the staging area */
  IF (l_agent_id.COUNT > 0) THEN
    FORALL i IN l_agent_id.FIRST .. l_agent_id.LAST
    INSERT /*+ append */ INTO bix_agent_session_stg bas (
       bas.agent_id
      ,bas.server_group_id
      ,bas.schedule_id
      ,bas.campaign_id
      ,bas.application_id
      ,bas.time_id
      ,bas.period_type_id
      ,bas.period_start_date
      ,bas.period_start_time
      ,bas.day_of_week
      ,bas.last_update_date
      ,bas.last_updated_by
      ,bas.creation_date
      ,bas.created_by
      ,bas.last_update_login
      ,bas.work_time
      ,bas.request_id
      ,bas.program_application_id
      ,bas.program_id
      ,bas.program_update_date)
    VALUES (
       l_agent_id(i)
      ,l_server_group_id(i)
      ,l_schedule_id(i)
      ,l_campaign_id(i)
      ,l_application_id(i)
      ,to_number(to_char(l_period_start_date(i), 'J'))
      ,1
      ,TRUNC(l_period_start_date(i))
      ,'00:00'
      ,TO_CHAR(l_period_start_date(i),'D')
      ,g_sysdate
      ,g_user_id
      ,g_sysdate
      ,g_user_id
      ,g_user_id
      ,decode(l_work_time(i), 0, to_number(null), l_work_time(i))
      ,g_request_id
      ,g_program_appl_id
      ,g_program_id
      ,g_sysdate);
  END IF;

  write_log('Total rows inserted in the staging area for half hour time bucket : ' || to_char(l_agent_id.COUNT));

  write_log('Finished procedure insert_work_row at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in insert_work_row : Error : ' || sqlerrm);
    RAISE;
END insert_work_row;

PROCEDURE collect_work_time IS
  CURSOR get_work_time IS
  SELECT /*+ parallel(iss) parallel(isa) parallel(isamed) parallel(res) parallel(csh)
             pq_distribute(iss hash,hash) pq_distribute(isa hash,hash)
             pq_distribute(isamed hash,hash) pq_distribute(res hash,hash)
             pq_distribute(csh hash,hash)
             use_hash(iss,isa,isamed,res,csh)*/
     isa.activity_id                               activity_id
    ,iss.resource_id                               resource_id
	,isa.begin_date_time						   begin_date_time
    ,nvl(isa.end_date_time, nvl(isamed.end_Date_time,isa.begin_Date_time)) end_date_time
	,nvl(res.server_group_id,-1)                   server_group_id
    ,iss.application_id                            application_id
    ,decode(isa.category_type, 'CSCH', nvl(csh.schedule_id, -1), -1)
                                                   schedule_id
    ,decode(isa.category_type, 'CSCH', nvl(csh.campaign_id, -1), -1)
                                                   campaign_id
  FROM
     ieu_sh_sessions iss
    ,ieu_sh_activities isa
    ,jtf_rs_resource_extns res
    ,ams_campaign_schedules_b csh
	,(select parent_cycle_id,max(isamed.end_Date_time) end_date_time from ieu_sh_Activities isamed,ieu_sh_sessions isamedsess
	  where activity_type_code='MEDIA'
	  and isamedsess.session_id=isamed.session_id
	  and isamedsess.application_id=696
	  group by parent_cycle_id) isamed
  WHERE isa.last_update_date > g_collect_start_date
  AND   isa.last_update_date <= g_collect_end_date
  AND   iss.session_id = isa.session_id
  AND   iss.application_id = 696
  AND   isa.activity_type_code = 'MEDIA_CYCLE'
  AND   isa.activity_id=isamed.parent_cycle_id(+)
  AND   iss.resource_id = res.resource_id
  AND   decode(isa.category_type, 'CSCH', to_number(nvl(isa.category_value, -1)), -1) = csh.schedule_id(+);

  l_activity_id g_activity_id_tab;
  l_resource_id g_resource_id_tab;
  l_begin_date_time g_begin_date_time_tab;
  l_end_date_time g_end_date_time_tab;
  l_server_group_id g_server_group_id_tab;
  l_application_id g_application_id_tab;
  l_schedule_id g_schedule_id_tab;
  l_campaign_id g_campaign_id_tab;

  l_no_of_records  NUMBER;
BEGIN

  write_log('Start of the procedure collect_work_time at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  OPEN get_work_time;

  LOOP
    /* Fetch the activity rows in bulk and process them row by row */
    FETCH get_work_time BULK COLLECT INTO
      l_activity_id,
      l_resource_id,
      l_begin_date_time,
      l_end_date_time,
      l_server_group_id,
      l_application_id,
      l_schedule_id,
      l_campaign_id
    LIMIT g_commit_chunk_size;

    l_no_of_records := l_activity_id.COUNT;

    IF (l_no_of_records > 0) THEN
     insert_work_row(
       l_activity_id,
       l_resource_id,
       l_begin_date_time,
       l_end_date_time,
       l_server_group_id,
       l_application_id,
       l_schedule_id,
       l_campaign_id);

     l_activity_id.TRIM(l_no_of_records);
     l_resource_id.TRIM(l_no_of_records);
     l_begin_date_time.TRIM(l_no_of_records);
     l_end_date_time.TRIM(l_no_of_records);
     l_server_group_id.TRIM(l_no_of_records);
     l_application_id.TRIM(l_no_of_records);
     l_schedule_id.TRIM(l_no_of_records);
     l_campaign_id.TRIM(l_no_of_records);
    END IF;

    EXIT WHEN get_work_time%NOTFOUND;

  END LOOP;

  CLOSE get_work_time;

  COMMIT;

  write_log('Finished procedure collect_work_time at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure collect_work_time : Error : ' || sqlerrm);
    IF (get_work_time%ISOPEN) THEN
      CLOSE get_work_time;
    END IF;
    RAISE;
END collect_work_time;

PROCEDURE insert_login_row(p_session_id         in  g_session_id_tab,
                           p_agent_id           in  g_resource_id_tab,
                           p_session_begin_date in  g_begin_date_time_tab,
                           p_session_end_date   in  g_end_date_time_tab,
                           p_server_group_id    in  g_server_group_id_tab,
                           p_application_id     in  g_application_id_tab)
IS
  TYPE login_time_tab is TABLE OF bix_agent_session_f.login_time%TYPE;
  TYPE session_id_tab is TABLE OF ieu_sh_sessions.session_id%TYPE;
  TYPE collect_date_tab is TABLE OF ieu_sh_sessions.end_date_time%TYPE;

  l_agent_id g_resource_id_tab;
  l_period_start_date g_begin_date_time_tab;
  l_login_time login_time_tab;
  l_server_group_id g_server_group_id_tab;
  l_application_id g_application_id_tab;

  l_session_id session_id_tab;
  l_collect_date collect_date_tab;

  l_begin_date    DATE;
  l_end_date      DATE;
  l_period_start  DATE;
  l_row_counter   NUMBER;
  l_login_start   DATE;
  l_login_end     DATE;
  l_secs          NUMBER;
  j               NUMBER;
  k               NUMBER;
BEGIN
  write_log('Start of the procedure insert_login_row at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* Initialize all the variables */
  j := 0;
  k := 0;
  l_agent_id := g_resource_id_tab();
  l_period_start_date := g_begin_date_time_tab();
  l_server_group_id := g_server_group_id_tab();
  l_application_id := g_application_id_tab();
  l_login_time := login_time_tab();
  l_session_id := session_id_tab();
  l_collect_date := collect_date_tab();

  /* Loop through all the session rows returned by the cursor */
  FOR i in p_session_id.FIRST .. p_session_id.LAST LOOP
    l_begin_date := p_session_begin_date(i);
    l_end_date := p_session_end_date(i);

    IF (l_begin_date < l_end_date) THEN
      k := k + 1;
      l_session_id.extend(1);
      l_collect_date.extend(1);

      l_session_id(k) := p_session_id(i);
      l_collect_date(k) := l_end_date;

      /* Get the half hour bucket of the session begin date time */
      SELECT trunc(l_begin_date)
      INTO l_period_start
      FROM DUAL;

      l_row_counter := 0; /* Variable to identify the first row of the session in the while loop */

      /* Loop through the session record and insert a record for each half hour bucket */
      WHILE ( l_period_start < l_end_date )
      LOOP
        j := j + 1;
        IF (l_row_counter = 0 )
        THEN
          l_login_start := l_begin_date;
        ELSE
          l_login_start := l_period_start;
        END IF;

        l_login_end := l_period_start + 1;
        IF ( l_login_end > l_end_date )
        THEN
          l_login_end := l_end_date ;
        END IF;

        l_secs := round((l_login_end - l_login_start) * 24 * 3600);

        l_agent_id.extend(1);
        l_period_start_date.extend(1);
        l_login_time.extend(1);
        l_server_group_id.extend(1);
        l_application_id.extend(1);

        l_agent_id(j) := p_agent_id(i);
        l_period_start_date(j) := l_period_start;
        l_login_time(j) := l_secs;
        l_server_group_id(j) := p_server_group_id(i);
        l_application_id(j) := p_application_id(i);

        l_row_counter := l_row_counter + 1;
        l_period_start := l_period_start + 1;

      END LOOP;  -- end of WHILE loop
    END IF; /* end if (l_begin_date > l_end_date) */
  END LOOP;

  /* Bulk insert all the rows in the staging area */
  IF (l_agent_id.COUNT > 0) THEN
    FORALL i IN l_agent_id.FIRST .. l_agent_id.LAST
    INSERT /*+ append */ INTO bix_agent_session_stg bas (
       bas.agent_id
      ,bas.server_group_id
      ,bas.schedule_id
      ,bas.campaign_id
      ,bas.application_id
      ,bas.time_id
      ,bas.period_type_id
      ,bas.period_start_date
      ,bas.period_start_time
      ,bas.day_of_week
      ,bas.last_update_date
      ,bas.last_updated_by
      ,bas.creation_date
      ,bas.created_by
      ,bas.last_update_login
      ,bas.login_time
      ,bas.request_id
      ,bas.program_application_id
      ,bas.program_id
      ,bas.program_update_date)
    VALUES (
      l_agent_id(i)
      ,l_server_group_id(i)
      ,-1
      ,-1
      ,l_application_id(i)
      ,to_number(to_char(l_period_start_date(i), 'J'))
      ,1
      ,TRUNC(l_period_start_date(i))
      ,'00:00'
      ,TO_CHAR(l_period_start_date(i),'D')
      ,g_sysdate
      ,g_user_id
      ,g_sysdate
      ,g_user_id
      ,g_user_id
      ,decode(l_login_time(i), 0, to_number(null), l_login_time(i))
      ,g_request_id
      ,g_program_appl_id
      ,g_program_id
      ,g_sysdate);
  END IF;

  write_log('Total rows inserted in the staging area for half hour time bucket : ' || to_char(l_agent_id.COUNT));

  IF (l_session_id.COUNT > 0) THEN
    FORALL i IN l_session_id.FIRST .. l_session_id.LAST
    INSERT /*+ append */ INTO bix_sessions bis1 (
        bis1.session_id,
        bis1.created_by,
        bis1.creation_date,
        bis1.last_updated_by,
        bis1.last_update_date,
        bis1.curr_collect_date,
        bis1.last_collect_date,
        bis1.request_id,
        bis1.program_application_id,
        bis1.program_id,
        bis1.program_update_date )
      VALUES (
        l_session_id(i),
        g_user_id,
        g_sysdate,
        g_user_id,
        g_sysdate,
        l_collect_date(i),
        l_collect_date(i),
        g_request_id,
        g_program_appl_id,
        g_program_id,
        g_sysdate);
  END IF;
  write_log('Finished procedure insert_login_row at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in insert_login_row : Error : ' || sqlerrm);
    RAISE;
END insert_login_row;

PROCEDURE collect_login_time IS
  CURSOR get_login_time IS
 select /*+ use_hash(res) parallel(res) parallel(inv) */ inv.session_id, inv.resource_id, inv.begin_date_time,
        nvl (inv.end_date_time, lead (inv.prevsd, 1, inv.maxval) over
	(partition by inv.resource_id order by begin_date_time)) end_date_time,
        nvl (res.server_group_id, -1) server_group_id,
	decode (inv.application_id, 696, 696, 680, 680, 0) application_id
   from jtf_rs_resource_extns res,
	(select /*+ parallel(x) */ type, resource_id, begin_date_time,
		end_date_time, session_id, application_id, lag (begin_date_time)
		over (partition by resource_id order by begin_date_time) prevsd,
		max (begin_date_time)
		over (partition by resource_id order by begin_date_time) maxval
	   from (
		 select /*+ parallel(sess1) */ 1 type, resource_id, begin_date_time, end_date_time,
			session_id, application_id
		   from ieu_sh_sessions sess1
                   WHERE  last_update_date > g_collect_start_date
                   AND    last_update_date <= g_collect_end_date
		  union all
		 select /*+ parallel(msegs) */ 2 type, resource_id,
			start_date_time begin_date_time, null end_date_time,
			null session_id, null application_id
		   from jtf_ih_media_item_lc_segs msegs,
			jtf_ih_media_itm_lc_seg_tys segs
		  where msegs.milcs_type_id = segs.milcs_type_id
		    and segs.milcs_code in ('EMAIL_FETCH', 'EMAIL_REPLY',
			'EMAIL_DELETED', 'EMAIL_OPEN', 'EMAIL_REQUEUED',
			'EMAIL_REROUTED_DIFF_CLASS', 'EMAIL_REROUTED_DIFF_ACCT',
			'EMAIL_SENT', 'EMAIL_TRANSFERRED', 'EMAIL_ASSIGN',
			'EMAIL_COMPOSE', 'WITH_AGENT', 'EMAIL_ESCALATED')) x) inv
  where inv.resource_id = res.resource_id
    and type = 1;

/**************************
    ,inv1.begin_date_time            begin_date_time
    ,decode(inv1.end_date_time, to_date(null), decode(max(mseg.start_date_time), to_date(null), inv1.begin_date_time,
                   max(mseg.start_date_time)), inv1.end_date_time)
                     end_date_time
    ,nvl(res.server_group_id,-1)    server_group_id
    ,decode(inv1.application_id, 696, 696, 680, 680, 0)
                                    application_id
  FROM
    ( SELECT + full(msegs)
     resource_id, start_date_time FROM jtf_ih_media_item_lc_segs msegs
    ,jtf_ih_media_itm_lc_seg_tys segs
	 WHERE msegs.milcs_type_id = segs.milcs_type_id
	 AND   segs.milcs_code IN
					('EMAIL_FETCH'
					,'EMAIL_REPLY'
					,'EMAIL_DELETED'
					,'EMAIL_OPEN'
					,'EMAIL_REQUEUED'
					,'EMAIL_REROUTED_DIFF_CLASS'
					,'EMAIL_REROUTED_DIFF_ACCT'
					,'EMAIL_SENT'
					,'EMAIL_TRANSFERRED'
					,'EMAIL_ASSIGN'
					,'EMAIL_COMPOSE'
					,'WITH_AGENT'
					,'EMAIL_ESCALATED'
					  )
       ) mseg
    ,jtf_rs_resource_extns res
    ,(
SELECT + full(sess1)  session_id, resource_id, application_id, begin_date_time, end_date_time,
       lead(begin_date_time, 1)
       over (partition by resource_id order by begin_date_time) next_sess_begin_date_time
       FROM ieu_sh_sessions sess1
       WHERE  last_update_date > g_collect_start_date
       AND    last_update_date <= g_collect_end_date
     ) inv1
  WHERE inv1.resource_id = res.resource_id
  AND   mseg.resource_id(+) = inv1.resource_id
  AND   mseg.start_date_time(+) >= inv1.begin_date_time
  AND   mseg.start_date_time(+) < nvl(inv1.next_sess_begin_date_time, g_sysdate)
  GROUP BY inv1.session_id, inv1.resource_id, inv1.begin_date_time, inv1.end_date_time, res.server_group_id, inv1.application_id;
**************************************************/

  l_session_id g_session_id_tab;
  l_resource_id g_resource_id_tab;
  l_begin_date_time g_begin_date_time_tab;
  l_end_date_time g_end_date_time_tab;
  l_server_group_id g_server_group_id_tab;
  l_application_id g_application_id_tab;

  l_no_of_records  NUMBER;
BEGIN

  write_log('Start of the procedure collect_login_time at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  OPEN get_login_time;

  LOOP

    /* Fetch the login rows in bulk and process them row by row */
    FETCH get_login_time BULK COLLECT INTO
      l_session_id,
      l_resource_id,
      l_begin_date_time,
      l_end_date_time,
      l_server_group_id,
      l_application_id
    LIMIT g_commit_chunk_size;

    l_no_of_records := l_session_id.COUNT;

    IF (l_no_of_records > 0) THEN
     insert_login_row(
       l_session_id,
       l_resource_id,
       l_begin_date_time,
       l_end_date_time,
       l_server_group_id,
       l_application_id);

       l_session_id.TRIM(l_no_of_records);
       l_resource_id.TRIM(l_no_of_records);
       l_begin_date_time.TRIM(l_no_of_records);
       l_end_date_time.TRIM(l_no_of_records);
       l_server_group_id.TRIM(l_no_of_records);
       l_application_id.TRIM(l_no_of_records);
    END IF;

    COMMIT;

    EXIT WHEN get_login_time%NOTFOUND;

  END LOOP;

  CLOSE get_login_time;

  COMMIT;

  write_log('Finished procedure collect_login_time at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure collect_login_time : Error : ' || sqlerrm);
    IF (get_login_time%ISOPEN) THEN
      CLOSE get_login_time;
    END IF;
    RAISE;
END collect_login_time;

PROCEDURE merge_data IS

BEGIN

  write_log('Start of the procedure merge_data at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* Move the data from the staging area to the summary table bix_agent_session_f */
  INSERT /*+ append parallel(bas) */ INTO bix_agent_session_f bas
     (bas.agent_id,
      bas.server_group_id,
      bas.schedule_id,
      bas.campaign_id,
      bas.application_id,
      bas.time_id,
      bas.period_type_id,
      bas.period_start_date,
      bas.period_start_time,
      bas.day_of_week,
      bas.created_by,
      bas.creation_date,
      bas.last_updated_by,
      bas.last_update_date,
      bas.login_time,
      bas.work_time,
      bas.available_time,
      bas.idle_time,
      bas.agent_cost,
      bas.request_id,
      bas.program_application_id,
      bas.program_id,
      bas.program_update_date )
  (SELECT /*+ parallel(bstg) */
      bstg.agent_id agent_id,
      bstg.server_group_id server_group_id,
      bstg.schedule_id schedule_id,
      bstg.campaign_id campaign_id,
      bstg.application_id application_id,
      bstg.time_id time_id,
      bstg.period_type_id period_type_id,
      bstg.period_start_date period_start_date,
      bstg.period_start_time period_start_time,
      bstg.day_of_week day_of_week,
      g_user_id,
      g_sysdate,
      g_user_id,
      g_sysdate,
      sum(bstg.login_time) login_time,
      sum(bstg.work_time) work_time,
      sum(bstg.available_time) available_time,
      sum(bstg.idle_time) idle_time,
      decode(nvl(sum(bstg.login_time),0) * g_agent_cost, 0, to_number(null),
                 nvl(sum(bstg.login_time),0) * g_agent_cost) agent_cost,
      g_request_id,
      g_program_appl_id,
      g_program_id,
      g_sysdate
    FROM  bix_agent_session_stg bstg
    GROUP BY
      bstg.agent_id,
      bstg.server_group_id,
      bstg.schedule_id,
      bstg.campaign_id,
      bstg.application_id,
      bstg.time_id,
      bstg.period_type_id,
      bstg.period_start_date,
      bstg.period_start_time,
      bstg.day_of_week);

  g_rows_ins_upd := g_rows_ins_upd + SQL%ROWCOUNT;
  write_log('Total rows merged in bix_agent_session_f : ' || to_char(g_rows_ins_upd));

  COMMIT;

  write_log('Finished procedure merge_data at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure merge_data : Error : ' || sqlerrm);
    RAISE;
END merge_data;


PROCEDURE collect_day IS
BEGIN
  write_log('Start of the procedure collect_day at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  write_log('Calling procedure collect_login_time');
  collect_login_time;
  write_log('End procedure collect_login_time');

  write_log('Calling procedure collect_work_time');
  collect_work_time;
  write_log('End procedure collect_work_time');

  write_log('Calling procedure collect_available_time');
  collect_available_time;
  write_log('End procedure collect_available_time');

  write_log('Calling procedure collect_idle_time');
  collect_idle_time;
  write_log('End procedure collect_idle_time');

  write_log('Calling procedure merge_data');
  merge_data;
  write_log('End procedure merge_data');

  write_log('Finished procedure collect_day at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure collect_day : Error : ' || sqlerrm);
    RAISE;
END collect_day;

PROCEDURE summarize_data IS
BEGIN

  write_log('Start of the procedure summarize_data at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* Rollup the half-hour information to day, week, month, quarter and year time bucket */
  /* An outer query is necessary after rolling up to day, week, month, quarter and year */
  /* as rollup function produces two rows for weeks spanning two months                 */
  INSERT /*+ APPEND PARALLEL(bea) */ INTO BIX_AGENT_SESSION_F bea
     (bea.agent_id,
      bea.server_group_id,
      bea.schedule_id,
      bea.campaign_id,
      bea.application_id,
      bea.time_id,
      bea.period_type_id,
      bea.period_start_date,
      bea.period_start_time,
      bea.day_of_week,
      bea.created_by,
      bea.creation_date,
      bea.last_updated_by,
      bea.last_update_date,
      bea.login_time,
      bea.work_time,
      bea.available_time,
      bea.idle_time,
      bea.agent_cost,
      bea.request_id,
      bea.program_application_id,
      bea.program_id,
      bea.program_update_date )
  (SELECT /*+ PARALLEL(inv1) */
      inv1.agent_id,
      inv1.server_group_id,
      inv1.schedule_id,
      inv1.campaign_id,
      inv1.application_id,
      inv1.time_id,
      inv1.period_type_id,
      inv1.period_start_date,
      '00:00',
      inv1.day_of_week,
      g_user_id,
      g_sysdate,
      g_user_id,
      g_sysdate,
      sum(inv1.login_time),
      sum(inv1.work_time),
      sum(inv1.available_time),
      sum(inv1.idle_time),
      sum(inv1.agent_cost),
      g_request_id,
      g_program_appl_id,
      g_program_id,
      g_sysdate
   FROM
     (SELECT /*+ parallel(bes) parallel(ftd)
             pq_distribute(bes hash,hash) pq_distribute(ftd hash,hash)
             use_hash(bes,ftd) */
        bes.agent_id agent_id,
        bes.server_group_id,
        bes.schedule_id schedule_id,
        bes.campaign_id campaign_id,
        bes.application_id application_id,
        bes.day_of_week day_of_week,
        decode(ftd.week_id, null, decode(ftd.ent_period_id, null, decode(ftd.ent_qtr_id, null, decode(ftd.ent_year_id, null,
	             to_number(null), ftd.ent_year_id), ftd.ent_qtr_id), ftd.ent_period_id), ftd.week_id)     time_id,
        decode(ftd.week_id, null, decode(ftd.ent_period_id, null, decode(ftd.ent_qtr_id, null, decode(ftd.ent_year_id, null,
	             to_number(null), 128), 64), 32), 16) period_type_id,
        decode(ftd.week_id, null, decode(ftd.ent_period_id, null,
          decode(ftd.ent_qtr_id, null, decode(ftd.ent_year_id, null, to_date(null), min(ftd.ent_year_start_date)),
            min(ftd.ent_qtr_start_date)), min(ftd.ent_period_start_date)), min(ftd.week_start_date))  period_start_date,
        sum(bes.login_time) login_time,
        sum(bes.work_time) work_time,
        sum(bes.available_time) available_time,
        sum(bes.idle_time) idle_time,
        sum(bes.agent_cost) agent_cost
      FROM  BIX_AGENT_SESSION_F bes,
            fii_time_day ftd
      WHERE bes.time_id = ftd.report_date_julian
      AND   bes.period_type_id = 1
      GROUP BY
        bes.agent_id,
        bes.server_group_id,
        bes.schedule_id,
        bes.campaign_id,
        bes.application_id,
        bes.day_of_week,
      ROLLUP (
        ftd.ent_year_id,
        ftd.ent_qtr_id,
        ftd.ent_period_id,
        ftd.week_id)
      HAVING
        decode(ftd.week_id, null, decode(ftd.ent_period_id, null, decode(ftd.ent_qtr_id, null, decode(ftd.ent_year_id, null,
	             to_number(null), 128), 64), 32), 16) IS NOT NULL) inv1
   GROUP BY
      inv1.agent_id,
      inv1.server_group_id,
      inv1.schedule_id,
      inv1.campaign_id,
      inv1.application_id,
      inv1.time_id,
      inv1.period_type_id,
      inv1.period_start_date,
      inv1.day_of_week);

  g_rows_ins_upd := g_rows_ins_upd + SQL%ROWCOUNT;

  COMMIT;

  write_log('Total rows inserted after rolling up in BIX_AGENT_SESSION_F : ' || to_char(g_rows_ins_upd));

  write_log('Finished procedure summarize_data at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure summarize_data : Error : ' || sqlerrm);
    RAISE;
END summarize_data;

PROCEDURE check_missing_date(p_start_date IN DATE,
                             p_end_date IN DATE,
                             p_has_missing_date OUT NOCOPY BOOLEAN) IS
  l_count1 NUMBER;
  l_count2 NUMBER;
BEGIN

  p_has_missing_date := FALSE;

  SELECT count(*)
  INTO   l_count1
  FROM   fii_time_day
  WHERE  report_date between trunc(p_start_date) and trunc(p_end_date);

  SELECT (trunc(p_end_date) - trunc(p_start_date)) + 1
  INTO   l_count2
  FROM   dual;

  IF (l_count1 < l_count2) THEN
    p_has_missing_date := TRUE;
  END IF;

  write_log('Finished procedure check_missing_date at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure check_missing_date : Error : ' || sqlerrm);
    RAISE;
END check_missing_date;


---Cleanup the  media/sessions

PROCEDURE cleanup_oltp
IS

BEGIN

--
--Close media items
--
BEGIN
   g_errbuf := NULL;
   g_retcode := 'S';
   CCT_CONCURRENT_PUB.CLOSE_MEDIA_ITEMS(g_errbuf, g_retcode);

   IF g_retcode <> 'S'
   THEN
      RAISE G_OLTP_CLEANUP_ISSUE;
   END IF;

EXCEPTION
WHEN OTHERS THEN
   write_log('Close Media Items exited with: ' ||g_retcode || ' error buffer is: ' || g_errbuf);
   RAISE G_OLTP_CLEANUP_ISSUE;
END;

--
--Time out media items - interval hardcoded to 24 hours for now
--
BEGIN
   g_errbuf := NULL;
   g_retcode := 'S';
   CCT_CONCURRENT_PUB.TIMEOUT_MEDIA_ITEMS_RS(g_errbuf, g_retcode,24);

   IF g_retcode <> 'S'
   THEN
      RAISE G_OLTP_CLEANUP_ISSUE;
   END IF;

EXCEPTION
WHEN OTHERS THEN
   write_log('Timeout Media Items exited with: ' ||g_retcode || ' error buffer is: ' || g_errbuf);
   RAISE G_OLTP_CLEANUP_ISSUE;
END;


--IEU Session History Cleanup

BEGIN
   g_errbuf := NULL;
   g_retcode := 'S';
   IEU_SH_CON_PVT.IEU_SH_END_IDLE_TRANS(g_errbuf, g_retcode,NULL,'3',8);

   IF g_retcode <> 'S'
   THEN
      RAISE G_OLTP_CLEANUP_ISSUE;
   END IF;

EXCEPTION
WHEN OTHERS THEN
   write_log('Timeout Media Items exited with: ' ||g_retcode || ' error buffer is: ' || g_errbuf);
   RAISE G_OLTP_CLEANUP_ISSUE;
END;

END cleanup_oltp;

PROCEDURE main(errbuf        OUT NOCOPY VARCHAR2,
               retcode       OUT NOCOPY VARCHAR2,
               p_start_date  IN  VARCHAR2,
               p_end_date    IN  VARCHAR2)
IS

  l_has_missing_date  BOOLEAN := FALSE;

BEGIN
  errbuf  := null;
  retcode := 0;

  write_log('Collection start date : ' || p_start_date);
  write_log('Collection end date : ' || p_end_date);


  cleanup_oltp;

  g_collect_start_date := TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
  g_collect_end_date   := TO_DATE(p_end_date, 'YYYY/MM/DD HH24:MI:SS');

  /* Check if the time dimension is populated for the collection date range ; if not exit */
  check_missing_date(g_collect_start_date, g_collect_end_date, l_has_missing_date);
  IF (l_has_missing_date) THEN
    write_log('Time dimension is not populated for the entire collection date range');
    RAISE G_TIME_DIM_MISSING;
  END IF;

  /* collect the half hour data for the entire date range */
  write_log('Calling procedure collect_day');
  collect_day;
  write_log('End procedure collect_day');

  /* Summarize data to day, week, month, quater and year time buckets */
  write_log('Calling procedure summarize_data');
  summarize_data;
  write_log('End procedure summarize_data');

  write_log('Truncating the table bix_agent_session_stg');
  Truncate_Table('BIX_AGENT_SESSION_STG');
  write_log('Done truncating the table bix_agent_session_stg');

  write_log('Finished Procedure BIX_SESSION_LOAD_PKG with success at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  write_log('Calling procedure WRAPUP');
  bis_collection_utilities.wrapup(
      p_status      => TRUE,
      p_count       => g_rows_ins_upd,
      p_message     => NULL,
      p_period_from => g_collect_start_date,
      p_period_to   => g_collect_end_date);

EXCEPTION
  WHEN G_TIME_DIM_MISSING THEN
    retcode := -1;
    errbuf := 'Time Dimension is not populated for the entire collection range';
    bis_collection_utilities.wrapup(
      p_status      => FALSE,
      p_count       => 0,
      p_message     => 'eMail summary package failed : Error : Time dimension is not populated',
      p_period_from => g_collect_start_date,
      p_period_to   => g_collect_end_date);
  WHEN OTHERS THEN
    clean_up;
    retcode := SQLCODE;
    errbuf := SQLERRM;
    bis_collection_utilities.wrapup(
      p_status      => FALSE,
      p_count       => 0,
      p_message     => 'eMail summary package failed : error : ' || sqlerrm,
      p_period_from => g_collect_start_date,
      p_period_to   => g_collect_end_date);
END main;

PROCEDURE  load (errbuf   OUT  NOCOPY VARCHAR2,
                 retcode  OUT  NOCOPY VARCHAR2)
IS
  l_start_date DATE;
BEGIN
  init;
  write_log('End procedure init');

  /* Get the global start date */
  l_start_date := to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'),'MM/DD/YYYY');


  Main(errbuf,
       retcode,
       TO_CHAR(l_start_date, 'YYYY/MM/DD HH24:MI:SS'),
       TO_CHAR(g_sysdate,'YYYY/MM/DD HH24:MI:SS'));

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END load;

END BIX_SESSION_LOAD_PKG;

/
