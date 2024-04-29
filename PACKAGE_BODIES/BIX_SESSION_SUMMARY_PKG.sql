--------------------------------------------------------
--  DDL for Package Body BIX_SESSION_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_SESSION_SUMMARY_PKG" AS
/*$Header: bixsessd.plb 120.2 2006/02/13 15:11:53 anasubra noship $ */

  g_request_id                  NUMBER;
  g_program_appl_id             NUMBER;
  g_program_id                  NUMBER;
  g_user_id                     NUMBER;
  g_bix_schema                  VARCHAR2(30) := 'BIX';
  g_rows_ins_upd                NUMBER;
  g_commit_chunk_size           NUMBER;
  g_no_of_jobs                  NUMBER := 0;
  g_collect_start_date          DATE;
  g_collect_end_date            DATE;
  g_sysdate                     DATE;
  g_debug_flag                  VARCHAR2(1)  := 'N';
  g_agent_cost                  NUMBER;

  g_errbuf                      VARCHAR2(1000);
  g_retcode                     VARCHAR2(10) := 'S';

  MAX_LOOP CONSTANT             NUMBER := 180;

  G_OLTP_CLEANUP_ISSUE          EXCEPTION;
  G_TIME_DIM_MISSING            EXCEPTION;
  G_CHILD_PROCESS_ISSUE         EXCEPTION;
  G_PARAM_MISMATCH              EXCEPTION;

  TYPE WorkerList is table of NUMBER index by binary_integer;
  g_worker WorkerList;

  TYPE g_session_id_tab IS TABLE OF ieu_sh_sessions.session_id%TYPE;
  TYPE g_activity_id_tab IS TABLE OF ieu_sh_activities.activity_id%TYPE;
  TYPE g_resource_id_tab IS TABLE OF ieu_sh_sessions.resource_id%TYPE;
  TYPE g_begin_date_time_tab IS TABLE OF ieu_sh_sessions.begin_date_time%TYPE;
  TYPE g_end_date_time_tab IS TABLE OF ieu_sh_sessions.end_date_time%TYPE;
  TYPE g_last_collect_date_tab IS TABLE OF bix_sessions.last_collect_date%TYPE;
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

PROCEDURE init IS

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

  write_log('Getting Agent Cost');

g_agent_cost := 0;
  --IF (FND_PROFILE.DEFINED('BIX_DM_AGENT_COST')) THEN
    --g_agent_cost := TO_NUMBER(FND_PROFILE.VALUE('BIX_DM_AGENT_COST')) / 3600;
  --END IF;

  write_log('Agent Cost : ' || g_agent_cost);

  write_log('Getting schema information');
  IF(FND_INSTALLATION.GET_APP_INFO('BIX', l_status, l_industry, g_bix_schema)) THEN
     NULL;
  END IF;
  write_log('BIX Schema : ' || g_bix_schema);

  write_log('Finished procedure init at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in init : Error : ' || sqlerrm);
    RAISE;
END init;

FUNCTION launch_worker(p_worker_no in NUMBER) RETURN NUMBER IS

  l_request_id NUMBER;
BEGIN

  write_log('Start of the procedure launch_worker at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* Submit the parallel concurrent request */
  l_request_id := FND_REQUEST.SUBMIT_REQUEST('BIX',
                                             'BIX_SESSION_SUBWORKER',
                                             NULL,
                                             NULL,
                                             FALSE,
                                             p_worker_no);

  write_log('Request ID of the concurrent request launched : ' || to_char(l_request_id));

  /* if the submission of the request fails , abort the program */
  IF (l_request_id = 0) THEN
     rollback;
     write_log('Error in launching child workers');
     RAISE G_CHILD_PROCESS_ISSUE;
  END IF;

  write_log('Finished procedure launch_worker at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  RETURN l_request_id;

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in launch_worker : Error : ' || sqlerrm);
    RAISE;
END LAUNCH_WORKER;

PROCEDURE register_jobs IS

  l_start_date_range DATE;
  l_end_date_range   DATE;
  l_count            NUMBER := 0;

BEGIN
  write_log('Start of the procedure register_jobs at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* No of jobs to be submitted = No of days for which we need to collect data */
  SELECT ceil(g_collect_end_date - g_collect_start_date)
  INTO   l_count
  FROM   dual;

  g_no_of_jobs := l_count;

  write_log('Number of workers that need to ne instantiated : ' || to_char(l_count));

  Delete BIX_WORKER_JOBS WHERE OBJECT_NAME = 'BIX_AGENT_SESSION_F';

  IF (l_count > 0) THEN
    l_start_date_range := g_collect_start_date;

    /* Register a job for each day of the collection date range */
    FOR i IN 1..l_count
    LOOP
      /* End date range is end of day of l_start_date_range */
      l_end_date_range := trunc(l_start_date_range) + 1;

      IF (l_start_date_range > g_collect_end_date) THEN
        EXIT;
      END IF;

      IF (l_end_date_range > g_collect_end_date) THEN
        l_end_date_range := g_collect_end_date;
      END IF;

      INSERT INTO BIX_WORKER_JOBS(OBJECT_NAME
                                , START_DATE_RANGE
                                , END_DATE_RANGE
                                , WORKER_NUMBER
                                , STATUS)
                            VALUES (
                                 'BIX_AGENT_SESSION_F'
                                , l_start_date_range
                                , l_end_date_range
                                , l_count
                                , 'UNASSIGNED');

      l_start_date_range := l_end_date_range;
    END LOOP;
  END IF;

  COMMIT;

  write_log('Finished procedure register_jobs at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in register_jobs : Error : ' || sqlerrm);
    RAISE;
END REGISTER_JOBS;

PROCEDURE clean_up IS

  l_total_rows_deleted NUMBER := 0;
  l_rows_deleted       NUMBER := 0;

BEGIN
  write_log('Start of the procedure clean_up at ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));

  rollback;

  write_log('Deleting data from bix_agent_session_f');

  /* Delete all the rows inserted from subworkers */
  IF (g_worker.COUNT > 0) THEN
    FOR i IN g_worker.FIRST .. g_worker.LAST
    LOOP
      LOOP
        DELETE bix_agent_session_f
        WHERE  request_id = g_worker(i)
        AND    rownum <= g_commit_chunk_size ;

        l_rows_deleted := SQL%ROWCOUNT;
        l_total_rows_deleted := l_total_rows_deleted + l_rows_deleted;

        COMMIT;

        IF (l_rows_deleted < g_commit_chunk_size) THEN
          EXIT;
        END IF;
      END LOOP;
    END LOOP;
  END IF;

  /* Deleting all rows inserted by this main program */
  LOOP

    DELETE bix_agent_session_f
    WHERE  request_id = g_request_id
    AND    rownum <= g_commit_chunk_size ;

    l_rows_deleted := SQL%ROWCOUNT;
    l_total_rows_deleted := l_total_rows_deleted + l_rows_deleted;

    COMMIT;

    IF (l_rows_deleted < g_commit_chunk_size) THEN
      EXIT;
    END IF;
  END LOOP;

  write_log('Number of rows deleted from bix_agent_session_f : ' || to_char(l_total_rows_deleted));

  write_log('Truncating the table bix_agent_session_stg');
  Truncate_Table('BIX_AGENT_SESSION_STG');
  write_log('Done truncating the table bix_agent_session_stg');

  write_log('Finished procedure clean_up at ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in cleaning up the tables : Error : ' || sqlerrm);
    RAISE;
END CLEAN_UP;

PROCEDURE insert_login_row(p_session_id         in  g_session_id_tab,
                           p_agent_id           in  g_resource_id_tab,
                           p_session_begin_date in  g_begin_date_time_tab,
                           p_session_end_date   in  g_end_date_time_tab,
                           p_last_collect_date  in  g_last_collect_date_tab,
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
    /* Collect from either session begin date or the date till which the session info has alreday been collected */
    l_begin_date := greatest(p_session_begin_date(i), nvl(p_last_collect_date(i), p_session_begin_date(i)));
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
    INSERT /*+ append */ INTO bix_agent_session_stg (
       agent_id
      ,server_group_id
      ,schedule_id
      ,campaign_id
      ,application_id
      ,time_id
      ,period_type_id
      ,period_start_date
      ,period_start_time
      ,day_of_week
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,login_time
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date)
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
      ,TO_NUMBER(TO_CHAR(l_period_start_date(i),'D'))
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
    MERGE INTO bix_sessions bis1
    USING (
      SELECT
        l_session_id(i) session_id,
        l_collect_date(i) curr_collect_date
      FROM  dual ) change
      ON (  bis1.session_id = change.session_id )
      WHEN MATCHED THEN
      UPDATE SET
         bis1.curr_collect_date = change.curr_collect_date
        ,bis1.last_update_date = g_sysdate
        ,bis1.last_updated_by  = g_user_id
        ,bis1.program_update_date = g_sysdate
      WHEN NOT MATCHED THEN INSERT (
        bis1.session_id,
        bis1.created_by,
        bis1.creation_date,
        bis1.last_updated_by,
        bis1.last_update_date,
        bis1.curr_collect_date,
        bis1.request_id,
        bis1.program_application_id,
        bis1.program_id,
        bis1.program_update_date )
      VALUES (
        change.session_id,
        g_user_id,
        g_sysdate,
        g_user_id,
        g_sysdate,
        change.curr_collect_date,
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
  SELECT
     iss.session_id                                     session_id
    ,iss.resource_id                                    resource_id
    ,iss.begin_date_time                                begin_date_time
    ,iss.end_date_time                                  end_date_time
    ,bis1.last_collect_date                              last_collect_date
    ,nvl(res.server_group_id,-1)                        server_group_id
    ,decode(iss.application_id, 696, 696, 680, 680, 0)  application_id
  FROM
     ieu_sh_sessions iss
    ,bix_sessions bis1
    ,jtf_rs_resource_extns res
  WHERE iss.last_update_date > g_collect_start_date
  AND   iss.last_update_date <= g_collect_end_date
  AND   iss.session_id = bis1.session_id(+)
  AND   iss.resource_id = res.resource_id
  AND   iss.end_date_time IS NOT NULL
  UNION ALL
  SELECT
     inv1.session_id                 session_id
    ,inv1.resource_id                resource_id
    ,inv1.begin_date_time            begin_date_time
    ,decode(max(mseg.start_date_time), to_date(null), inv1.begin_date_time, max(mseg.start_date_time))
                     end_date_time
    ,bis1.last_collect_date          last_collect_date
    ,nvl(res.server_group_id,-1)    server_group_id
    ,decode(inv1.application_id, 696, 696, 680, 680, 0)
                                    application_id
  FROM
     ( SELECT msegs.* FROM jtf_ih_media_item_lc_segs msegs
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
    ,bix_sessions bis1
    ,jtf_rs_resource_extns res
    ,(
       SELECT
           iss1.session_id           session_id
         , iss1.resource_id          resource_id
         , iss1.application_id       application_id
         , iss1.begin_date_time      begin_date_time
         , iss1.end_date_time        end_date_time
         , min(iss2.begin_date_time) next_sess_begin_date_time
       FROM
          ieu_sh_sessions iss1
         ,ieu_sh_sessions iss2
       WHERE  iss1.active_flag = 'T'
       AND    iss1.resource_id = iss2.resource_id(+)
       AND    iss2.begin_date_time(+) > iss1.begin_date_time
       GROUP BY iss1.session_id, iss1.resource_id, iss1.application_id, iss1.begin_date_time, iss1.end_date_time
     ) inv1
  WHERE inv1.resource_id = res.resource_id
  AND   mseg.resource_id(+) = inv1.resource_id
  AND   mseg.start_date_time(+) >= inv1.begin_date_time
  AND   mseg.start_date_time(+) < nvl(inv1.next_sess_begin_date_time, g_sysdate)
  AND   inv1.session_id = bis1.session_id(+)
  GROUP BY inv1.session_id, inv1.resource_id, inv1.begin_date_time, bis1.last_collect_date, res.server_group_id, inv1.application_id;

  l_session_id g_session_id_tab;
  l_resource_id g_resource_id_tab;
  l_begin_date_time g_begin_date_time_tab;
  l_end_date_time g_end_date_time_tab;
  l_last_collect_date g_last_collect_date_tab;
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
      l_last_collect_date,
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
       l_last_collect_date,
       l_server_group_id,
       l_application_id);

       l_session_id.TRIM(l_no_of_records);
       l_resource_id.TRIM(l_no_of_records);
       l_begin_date_time.TRIM(l_no_of_records);
       l_end_date_time.TRIM(l_no_of_records);
       l_last_collect_date.TRIM(l_no_of_records);
       l_server_group_id.TRIM(l_no_of_records);
       l_application_id.TRIM(l_no_of_records);
    END IF;

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

PROCEDURE insert_work_row(p_activity_id         in  g_activity_id_tab,
                          p_agent_id            in  g_resource_id_tab,
                          p_activity_begin_date in  g_begin_date_time_tab,
                          p_activity_end_date   in  g_end_date_time_tab,
                          p_last_collect_date   in  g_last_collect_date_tab,
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
    /* Collect from either activity begin date or the date till which the activity info has alreday been collected */
    l_begin_date := greatest(p_activity_begin_date(i), nvl(p_last_collect_date(i), p_activity_begin_date(i)));

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
    INSERT /*+ append */ INTO bix_agent_session_stg (
       agent_id
      ,server_group_id
      ,schedule_id
      ,campaign_id
      ,application_id
      ,time_id
      ,period_type_id
      ,period_start_date
      ,period_start_time
      ,day_of_week
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,work_time
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date)
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
  SELECT
     isa.activity_id                               activity_id
    ,iss.resource_id                               resource_id
    ,isa.begin_date_time                           begin_date_time
   /* ,nvl(isa.end_date_time, bis1.curr_collect_date) end_date_time*/
    ,nvl(isa.end_date_time, nvl(isamed.end_Date_time,isa.begin_Date_time)) end_date_time
    ,bis1.last_collect_date                         last_collect_date
    ,nvl(res.server_group_id,-1)                   server_group_id
    ,iss.application_id                            application_id
    ,decode(isa.category_type, 'CSCH', nvl(csh.schedule_id, -1), -1)
                                                   schedule_id
    ,decode(isa.category_type, 'CSCH', nvl(csh.campaign_id, -1), -1)
                                                   campaign_id
  FROM
     ieu_sh_sessions iss
    ,ieu_sh_activities isa
    ,bix_sessions bis1
    ,jtf_rs_resource_extns res
    ,ams_campaign_schedules_b csh
	,(select parent_cycle_id,max(isamed.end_Date_time) end_date_time from ieu_sh_Activities isamed,ieu_sh_sessions isamedsess
	  where activity_type_code='MEDIA'
	  and isamedsess.last_update_date > g_collect_start_date-2 --dummy filter to force index scan
	  and isamed.last_update_date > g_collect_start_date
	  AND   isamed.last_update_date <= g_collect_end_date
	  and isamedsess.session_id=isamed.session_id
	  and isamedsess.application_id=696
	  group by parent_cycle_id) isamed
  WHERE isa.last_update_date > g_collect_start_date
  AND   iss.last_update_date > g_collect_start_date-2
  AND   isa.last_update_date <= g_collect_end_date
  AND   isa.activity_id=isamed.parent_cycle_id(+)
  AND   iss.application_id = 696
  AND   iss.session_id = isa.session_id
  AND   isa.activity_type_code = 'MEDIA_CYCLE'
  AND   iss.session_id = bis1.session_id
  AND   iss.resource_id = res.resource_id
  AND   decode(isa.category_type, 'CSCH', to_number(nvl(isa.category_value, -1)), -1) = csh.schedule_id(+);

  l_activity_id g_activity_id_tab;
  l_resource_id g_resource_id_tab;
  l_begin_date_time g_begin_date_time_tab;
  l_end_date_time g_end_date_time_tab;
  l_last_collect_date g_last_collect_date_tab;
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
      l_last_collect_date,
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
       l_last_collect_date,
       l_server_group_id,
       l_application_id,
       l_schedule_id,
       l_campaign_id);

     l_activity_id.TRIM(l_no_of_records);
     l_resource_id.TRIM(l_no_of_records);
     l_begin_date_time.TRIM(l_no_of_records);
     l_end_date_time.TRIM(l_no_of_records);
     l_last_collect_date.TRIM(l_no_of_records);
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

PROCEDURE insert_available_row(p_activity_id         in  g_activity_id_tab,
                               p_agent_id            in  g_resource_id_tab,
                               p_activity_begin_date in  g_begin_date_time_tab,
                               p_activity_end_date   in  g_end_date_time_tab,
                               p_last_collect_date   in  g_last_collect_date_tab,
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
    /* Collect from either activity begin date or the date till which the activity info has alreday been collected */
    l_begin_date := greatest(p_activity_begin_date(i), nvl(p_last_collect_date(i), p_activity_begin_date(i)));

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
    INSERT /*+ append */ INTO bix_agent_session_stg (
       agent_id
      ,server_group_id
      ,schedule_id
      ,campaign_id
      ,application_id
      ,time_id
      ,period_type_id
      ,period_start_date
      ,period_start_time
      ,day_of_week
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,available_time
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date)
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
  SELECT
   /*+ parallel(iss) parallel(isa1) parallel(isa2) parallel(bis1) parallel(res) parallel(csh)
             pq_distribute(iss hash,hash) pq_distribute(isa1 hash,hash)
             pq_distribute(isa2 hash,hash) pq_distribute(bis1 hash,hash)
             pq_distribute(res hash,hash) pq_distribute(csh hash,hash)
             use_hash(iss,isa1,isa2,bis1,res,csh) */
     isa1.activity_id                              activity_id
    ,iss.resource_id                               resource_id
    ,isa1.begin_date_time                          begin_date_time
 /*   ,nvl(isa1.deliver_date_time, nvl(isa1.end_date_time, bis1.curr_collect_date)) */
   ,nvl(isa1.deliver_date_time, nvl(isa1.end_date_time, isa1.begin_date_time))
                                                   end_date_time
    ,bis1.last_collect_date                         last_collect_date
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
    ,bix_sessions bis1
    ,jtf_rs_resource_extns res
    ,ams_campaign_schedules_b csh
  WHERE isa1.last_update_date > g_collect_start_date
  AND   isa1.last_update_date <= g_collect_end_date
  AND   iss.application_id = 696
  AND   iss.session_id = isa1.session_id
  AND   isa1.activity_type_code = 'MEDIA'
  AND   isa1.parent_cycle_id = isa2.activity_id
  AND   isa2.activity_type_code = 'MEDIA_CYCLE'
  AND   iss.session_id = bis1.session_id
  AND   iss.resource_id = res.resource_id
  AND   decode(isa2.category_type, 'CSCH', to_number(nvl(isa2.category_value, -1)), -1) = csh.schedule_id(+);

  l_activity_id g_activity_id_tab;
  l_resource_id g_resource_id_tab;
  l_begin_date_time g_begin_date_time_tab;
  l_end_date_time g_end_date_time_tab;
  l_last_collect_date g_last_collect_date_tab;
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
      l_last_collect_date,
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
        l_last_collect_date,
        l_server_group_id,
        l_application_id,
        l_schedule_id,
        l_campaign_id);

      l_activity_id.TRIM(l_no_of_records);
      l_resource_id.TRIM(l_no_of_records);
      l_begin_date_time.TRIM(l_no_of_records);
      l_end_date_time.TRIM(l_no_of_records);
      l_last_collect_date.TRIM(l_no_of_records);
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

PROCEDURE collect_idle_time IS
BEGIN

  write_log('Start of the procedure collect_idle_time at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  INSERT /*+ append */ INTO bix_agent_session_stg
     (agent_id,
      server_group_id,
      schedule_id,
      campaign_id,
      application_id,
      time_id,
      period_type_id,
      period_start_date,
      period_start_time,
      day_of_week,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      idle_time,
      request_id,
      program_application_id,
      program_id,
      program_update_date )
  (SELECT
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

  write_log('Finished procedure collect_day at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure collect_day : Error : ' || sqlerrm);
    RAISE;
END collect_day;

PROCEDURE merge_data IS

BEGIN

  write_log('Start of the procedure merge_data at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* Update bix_sessions to set the last collection date with the current collection date */
  /* First update the rows inserted/updated from the workers */
  IF (g_worker.COUNT > 0) THEN
    FOR i IN g_worker.FIRST .. g_worker.LAST
    LOOP
      UPDATE bix_sessions
      SET last_collect_date = curr_collect_date
      WHERE  request_id = g_worker(i);
    END LOOP;
  END IF;

  /* Update all rows inserted/updated by this main program */
  UPDATE bix_sessions
  SET last_collect_date = curr_collect_date
  WHERE request_id = g_request_id;

  /* Move the data from the staging area to the summary table bix_agent_session_f */
  MERGE INTO bix_agent_session_f bas
  USING (
    SELECT
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
      sum(bstg.login_time) login_time,
      sum(bstg.work_time) work_time,
      sum(bstg.available_time) available_time,
      sum(bstg.idle_time) idle_time,
      nvl(sum(bstg.login_time), 0) * g_agent_cost agent_cost
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
      bstg.day_of_week) change
  ON (  bas.agent_id = change.agent_id
    AND bas.server_group_id = change.server_group_id
    AND bas.schedule_id = change.schedule_id
    AND bas.campaign_id = change.campaign_id
    AND bas.application_id = change.application_id
    AND bas.time_id  = change.time_id
    AND bas.period_type_id = change.period_type_id
    AND bas.period_start_date = change.period_start_date
    AND bas.period_start_time = change.period_start_time
    AND bas.day_of_week = change.day_of_week)
  WHEN MATCHED THEN
    UPDATE SET
       bas.login_time = decode(nvl(change.login_time,0), 0, bas.login_time, nvl(bas.login_time, 0) + change.login_time)
      ,bas.work_time = decode(nvl(change.work_time,0), 0, bas.work_time, nvl(bas.work_time, 0) + change.work_time)
      ,bas.available_time = decode(nvl(change.available_time,0), 0, bas.available_time, nvl(bas.available_time,0)
                  + change.available_time)
      ,bas.idle_time = decode(nvl(change.idle_time,0), 0, bas.idle_time, nvl(bas.idle_time, 0) + change.idle_time)
      ,bas.agent_cost = decode(nvl(change.agent_cost,0), 0, bas.agent_cost, nvl(bas.agent_cost, 0) + change.agent_cost)
      ,bas.last_update_date = g_sysdate
      ,bas.last_updated_by  = g_user_id
      ,bas.program_update_date = g_sysdate
  WHEN NOT MATCHED THEN INSERT
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
    VALUES (
      change.agent_id,
      change.server_group_id,
      change.schedule_id,
      change.campaign_id,
      change.application_id,
      change.time_id,
      change.period_type_id,
      change.period_start_date,
      change.period_start_time,
      change.day_of_week,
      g_user_id,
      g_sysdate,
      g_user_id,
      g_sysdate,
      decode(change.login_time, 0, to_number(null), change.login_time),
      decode(change.work_time, 0, to_number(null), change.work_time),
      decode(change.available_time, 0, to_number(null), change.available_time),
      decode(change.idle_time, 0, to_number(null), change.idle_time),
      decode(change.agent_cost, 0, to_number(null), change.agent_cost),
      g_request_id,
      g_program_appl_id,
      g_program_id,
      g_sysdate);

  g_rows_ins_upd := g_rows_ins_upd + SQL%ROWCOUNT;
  write_log('Total rows merged in bix_agent_session_f : ' || to_char(g_rows_ins_upd));

  COMMIT;

  write_log('Finished procedure merge_data at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure merge_data : Error : ' || sqlerrm);
    RAISE;
END merge_data;

PROCEDURE summarize_data IS

BEGIN

  write_log('Start of the procedure summarize_data at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* Rollup the half-hour information to day, week, month, quarter and year time bucket */
  INSERT /*+ append */ INTO bix_agent_session_stg
     (agent_id,
      server_group_id,
      schedule_id,
      campaign_id,
      application_id,
      time_id,
      period_type_id,
      period_start_date,
      period_start_time,
      day_of_week,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      login_time,
      work_time,
      available_time,
      idle_time,
      request_id,
      program_application_id,
      program_id,
      program_update_date )
  (SELECT
      bas.agent_id,
      bas.server_group_id,
      bas.schedule_id,
      bas.campaign_id,
      bas.application_id,
      decode(ftd.week_id, null, decode(ftd.ent_period_id, null,
        decode(ftd.ent_qtr_id, null, decode(ftd.ent_year_id, null, to_number(null), ftd.ent_year_id),
          ftd.ent_qtr_id), ftd.ent_period_id), ftd.week_id),
      decode(ftd.week_id, null, decode(ftd.ent_period_id, null,
        decode(ftd.ent_qtr_id, null, decode(ftd.ent_year_id, null, to_number(null), 128), 64), 32), 16),
      decode(ftd.week_id, null, decode(ftd.ent_period_id, null,
        decode(ftd.ent_qtr_id, null, decode(ftd.ent_year_id, null, to_date(null), min(ftd.ent_year_start_date)),
           min(ftd.ent_qtr_start_date)), min(ftd.ent_period_start_date)), min(ftd.week_start_date)),
      '00:00',
      bas.day_of_week,
      g_user_id,
      g_sysdate,
      g_user_id,
      g_sysdate,
      sum(bas.login_time),
      sum(bas.work_time),
      sum(bas.available_time),
      sum(bas.idle_time),
      g_request_id,
      g_program_appl_id,
      g_program_id,
      g_sysdate
   FROM  bix_agent_session_stg bas,
         fii_time_day ftd
   WHERE bas.time_id = ftd.report_date_julian
   AND   bas.period_type_id = 1
   GROUP BY
      bas.agent_id,
      bas.server_group_id,
      bas.schedule_id,
      bas.campaign_id,
      bas.application_id,
      bas.day_of_week,
   ROLLUP (
      ftd.ent_year_id,
      ftd.ent_qtr_id,
      ftd.ent_period_id,
      ftd.week_id)
   HAVING
      decode(ftd.week_id, null, decode(ftd.ent_period_id, null,
        decode(ftd.ent_qtr_id, null, decode(ftd.ent_year_id, null, to_number(null), 128), 64), 32), 16) IS NOT NULL);

  write_log('Total rows inserted in the staging area for day, month and year : ' || to_char(SQL%ROWCOUNT));

  COMMIT;

  write_log('Finished procedure summarize_data at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure summarize_data : Error : ' || sqlerrm);
    RAISE;
END summarize_data;

PROCEDURE worker(errbuf      OUT   NOCOPY VARCHAR2,
                 retcode     OUT   NOCOPY VARCHAR2,
                 p_worker_no IN NUMBER) IS

  l_unassigned_cnt       NUMBER := 0;
  l_failed_cnt           NUMBER := 0;
  l_wip_cnt              NUMBER := 0;
  l_completed_cnt        NUMBER := 0;
  l_total_cnt            NUMBER := 0;
  l_count                NUMBER := 0;
  l_start_date_range     DATE;
  l_end_date_range       DATE;

BEGIN

  write_log('Start of the procedure worker at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  errbuf  := NULL;
  retcode := 0;

  write_log('Calling procedure init');
  init;
  write_log('End procedure init');

  l_count:= 0;

  LOOP

    /* Get the status of all the jobs in BIX_WORKER_JOBS */
    SELECT NVL(sum(decode(status,'UNASSIGNED', 1, 0)),0),
           NVL(sum(decode(status,'FAILED', 1, 0)),0),
           NVL(sum(decode(status,'IN PROCESS', 1, 0)),0),
           NVL(sum(decode(status,'COMPLETED',1 , 0)),0),
           count(*)
    INTO   l_unassigned_cnt,
           l_failed_cnt,
           l_wip_cnt,
           l_completed_cnt,
           l_total_cnt
    FROM   BIX_WORKER_JOBS
    WHERE  object_name = 'BIX_AGENT_SESSION_F';

    write_log('Job status - Unassigned: '||l_unassigned_cnt||
                       ' In Process: '||l_wip_cnt||
                       ' Completed: '||l_completed_cnt||
                       ' Failed: '||l_failed_cnt||
                       ' Total: '|| l_total_cnt);

    IF (l_failed_cnt > 0) THEN
      write_log('Another worker have errored out.  Stop processing.');
      EXIT;
    ELSIF (l_unassigned_cnt = 0) THEN
      write_log('No more jobs left.  Terminating.');
      EXIT;
    ELSIF (l_completed_cnt = l_total_cnt) THEN
      write_log('All jobs completed, no more job.  Terminating');
      EXIT;
    ELSIF (l_unassigned_cnt > 0) THEN
      /* Pickup any one unassigned job to process */
      UPDATE BIX_WORKER_JOBS
      SET    status        = 'IN PROCESS',
             worker_number = p_worker_no
      WHERE  status = 'UNASSIGNED'
      AND    rownum < 2
      AND    object_name = 'BIX_AGENT_SESSION_F';

      l_count := sql%rowcount;
      COMMIT;
    END IF;

    -- -----------------------------------
    -- There could be rare situations where
    -- between Section 30 and Section 50
    -- the unassigned job gets taken by
    -- another worker.  So, if unassigned
    -- job no longer exist.  Do nothing.
    -- -----------------------------------

    IF (l_count > 0) THEN

      DECLARE
      BEGIN

        /* Collect data for half hour time buckets for the date range of the job */
        SELECT start_date_range, end_date_range
        INTO   l_start_date_range, l_end_date_range
        FROM   BIX_WORKER_JOBS
        WHERE worker_number = p_worker_no
        AND   status        = 'IN PROCESS'
        AND   object_name   = 'BIX_AGENT_SESSION_F';

        write_log('Calling procedure collect_day');
        g_collect_start_date := l_start_date_range;
        g_collect_end_date   := l_end_date_range;
        collect_day;
        write_log('End procedure collect_day');

        /* Update the status of job to 'COMPLETED' */
        UPDATE BIX_WORKER_JOBS
        SET    status = 'COMPLETED'
        WHERE  status = 'IN PROCESS'
        AND    worker_number = p_worker_no
        AND    object_name = 'BIX_AGENT_SESSION_F';

        COMMIT;

      EXCEPTION
        WHEN OTHERS THEN
          retcode := -1;

          UPDATE BIX_WORKER_JOBS
          SET    status = 'FAILED'
          WHERE  worker_number = p_worker_no
          AND    status = 'IN PROCESS'
          AND    object_name = 'BIX_AGENT_SESSION_F';

          COMMIT;
          write_log('Error in worker');
          RAISE G_CHILD_PROCESS_ISSUE;
      END;

    END IF; /* IF (l_count> 0) */

  END LOOP;

  write_log('Finished procedure worker at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
   WHEN OTHERS THEN
     write_log('Error in procedure worker : Error : ' || sqlerrm);
     RAISE;
END WORKER;

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
               p_end_date    IN  VARCHAR2,
               p_number_of_processes IN NUMBER)
IS

  l_has_missing_date  BOOLEAN := FALSE;
  l_no_of_workers NUMBER;

BEGIN

  errbuf  := null;
  retcode := 0;

  write_log('Truncating the table bix_agent_session_stg');
  Truncate_Table('BIX_AGENT_SESSION_STG');
  write_log('Done truncating the table bix_agent_session_stg');

  write_log('Collection start date : ' || p_start_date);
  write_log('Collection end date : ' || p_end_date);

  cleanup_oltp;

  g_collect_start_date := TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
  g_collect_end_date   := TO_DATE(p_end_date, 'YYYY/MM/DD HH24:MI:SS');




  /* Collection start date will be greater than collection end date  */
  /* if the program is executed more than once in the same half hour */
  IF (g_collect_start_date >= g_collect_end_date) THEN
    write_log('Collection start date cannot be greater than or equal to collection end date');
    RAISE G_PARAM_MISMATCH;
  END IF;

  /* Check if time dimension is populated for the collection date range */
  fii_time_api.check_missing_date(g_collect_start_date, g_collect_end_date, l_has_missing_date);
  IF (l_has_missing_date) THEN
    write_log('Time dimension is not populated for the entire collection date range');
    RAISE G_TIME_DIM_MISSING;
  END IF;

  /* if the collection date range is more than 1 day and user has specified to launch more than 1 worker , */
  /* then launch parallel workers to do the half hour collection of each day                               */
  IF (((g_collect_end_date - g_collect_start_date) > 1) AND
          (p_number_of_processes > 1)) THEN
    write_log('Calling procedure register_jobs');
    register_jobs;
    write_log('End procedure register_jobs');

    /* Launch a parallel worker for each day of the collection date range or number of processes */
    /* user has requested for , whichever is less */
    l_no_of_workers := least(g_no_of_jobs, p_number_of_processes);

    write_log('Launching Workers');
    FOR i IN 1 .. l_no_of_workers
    LOOP
      g_worker(i) := LAUNCH_WORKER(i);
    END LOOP;
    write_log('Number of Workers launched : ' || to_char(l_no_of_workers));

    COMMIT;

    /* Monitor child processes after launching them */
    DECLARE

      l_unassigned_cnt       NUMBER := 0;
      l_completed_cnt        NUMBER := 0;
      l_wip_cnt              NUMBER := 0;
      l_failed_cnt           NUMBER := 0;
      l_tot_cnt              NUMBER := 0;
      l_last_unassigned_cnt  NUMBER := 0;
      l_last_completed_cnt   NUMBER := 0;
      l_last_wip_cnt         NUMBER := 0;
      l_cycle                NUMBER := 0;

    BEGIN
      LOOP

        SELECT NVL(sum(decode(status,'UNASSIGNED',1,0)),0),
               NVL(sum(decode(status,'COMPLETED',1,0)),0),
               NVL(sum(decode(status,'IN PROCESS',1,0)),0),
               NVL(sum(decode(status,'FAILED',1,0)),0),
               count(*)
        INTO   l_unassigned_cnt,
               l_completed_cnt,
               l_wip_cnt,
               l_failed_cnt,
               l_tot_cnt
        FROM   BIX_WORKER_JOBS
        WHERE  OBJECT_NAME = 'BIX_AGENT_SESSION_F';

        IF (l_failed_cnt > 0) THEN
          RAISE G_CHILD_PROCESS_ISSUE;
        END IF;

        IF (l_tot_cnt = l_completed_cnt) THEN
             EXIT;
        END IF;

        IF (l_unassigned_cnt = l_last_unassigned_cnt AND
            l_completed_cnt = l_last_completed_cnt AND
            l_wip_cnt = l_last_wip_cnt) THEN
          l_cycle := l_cycle + 1;
        ELSE
          l_cycle := 1;
        END IF;

        IF (l_cycle > MAX_LOOP) THEN
            write_log('Infinite loop');
            RAISE G_CHILD_PROCESS_ISSUE;
        END IF;

        dbms_lock.sleep(60);

        l_last_unassigned_cnt := l_unassigned_cnt;
        l_last_completed_cnt := l_completed_cnt;
        l_last_wip_cnt := l_wip_cnt;

      END LOOP;

    END;   -- Monitor child process Ends here.
  ELSE
    /* if no child process , then collect the half hour data for the entire date range */
    write_log('Calling procedure collect_day');
    collect_day;
    write_log('End procedure collect_day');
  END IF;

  /* Summarize data to day, week, month, quater and year time buckets */
  write_log('Calling procedure summarize_data');
  summarize_data;
  write_log('End procedure summarize_data');

  /* Merge the data to the main summary table from staging area */
  write_log('Calling procedure merge_data');
  merge_data;
  write_log('End procedure merge_data');

  write_log('Total Rows Inserted/Updated : ' || to_char(g_rows_ins_upd));

  write_log('Finished Procedure BIX_SESSION_SUMMARY_PKG with success at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  write_log('Truncating the table bix_agent_session_stg');
  Truncate_Table('BIX_AGENT_SESSION_STG');
  write_log('Done truncating the table bix_agent_session_stg');

  write_log('Calling procedure WRAPUP');
  bis_collection_utilities.wrapup(
      p_status      => TRUE,
      p_count       => g_rows_ins_upd,
      p_message     => NULL,
      p_period_from => g_collect_start_date,
      p_period_to   => g_collect_end_date);

EXCEPTION
  WHEN G_PARAM_MISMATCH THEN
    bis_collection_utilities.wrapup(
      p_status      => FALSE,
      p_count       => 0,
      p_message     => '0 rows collected : collect start date cannot be greater than collection end date',
      p_period_from => g_collect_start_date,
      p_period_to   => g_collect_end_date);
  WHEN G_TIME_DIM_MISSING THEN
    retcode := -1;
    errbuf := 'Time Dimension is not populated for the entire collection range';
    bis_collection_utilities.wrapup(
      p_status      => FALSE,
      p_count       => 0,
      p_message     => 'eMail summary package failed : Error : Time dimension is not populated',
      p_period_from => g_collect_start_date,
      p_period_to   => g_collect_end_date);
  WHEN G_CHILD_PROCESS_ISSUE THEN
    clean_up;
    retcode := SQLCODE;
    errbuf := SQLERRM;
    bis_collection_utilities.wrapup(
      p_status      => FALSE,
      p_count       => 0,
      p_message     => 'eMail summary package failed : error : ' || sqlerrm,
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

PROCEDURE  load (errbuf                OUT  NOCOPY VARCHAR2,
                 retcode               OUT  NOCOPY VARCHAR2,
                 p_number_of_processes IN   NUMBER )
IS
  l_last_start_date  DATE;
  l_last_end_date    DATE;
  l_last_period_from DATE;
  l_last_period_to   DATE;
BEGIN
  init;
  write_log('End procedure init');

  BIS_COLLECTION_UTILITIES.get_last_refresh_dates('BIX_AGENT_SESSION_F',
                                                   l_last_start_date,
                                                   l_last_end_date,
                                                   l_last_period_from,
                                                   l_last_period_to);
  IF l_last_period_to IS NULL THEN
    l_last_period_to := to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'),'MM/DD/YYYY');
  END IF;

  Main(errbuf,
       retcode,
       TO_CHAR(l_last_period_to, 'YYYY/MM/DD HH24:MI:SS'),
       TO_CHAR(g_sysdate, 'YYYY/MM/DD HH24:MI:SS'),
       p_number_of_processes);

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END load;

END BIX_SESSION_SUMMARY_PKG;

/
