--------------------------------------------------------
--  DDL for Package Body BIX_DM_SESSBYCAMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_DM_SESSBYCAMP_PKG" AS
/*$Header: bixxsecb.pls 120.0.12010000.2 2010/01/28 09:39:51 prnedumk ship $ */

g_request_id          NUMBER := FND_GLOBAL.CONC_REQUEST_ID();
g_program_appl_id     NUMBER := FND_GLOBAL.PROG_APPL_ID();
g_program_id          NUMBER := FND_GLOBAL.CONC_PROGRAM_ID();
g_user_id             NUMBER := FND_GLOBAL.USER_ID();
g_login_id            NUMBER := FND_GLOBAL.LOGIN_ID();
g_insert_count        NUMBER := 0;
g_delete_count        NUMBER := 0;
g_update_count        NUMBER := 0;
g_message             VARCHAR2(4000);  --used to store log file messages
g_error_msg           VARCHAR2(4000);
g_status              VARCHAR2(10);    --used to store collection status
g_proc_name           VARCHAR2(100);   --used to store procedure being processed
g_table_name          VARCHAR2(100);   --used to store table being processed
g_collect_start_date  DATE;       --used to store start date parameter user gave
g_collect_end_date    DATE;       --used to store end date parameter user gave
g_rounded_collect_start_date  DATE; --used to store rounded start date parameter
g_rounded_collect_end_date    DATE; --used to store rounded end date parameter
g_run_start_date      DATE;     --used to store start time when program is run
g_run_end_date        DATE;     --used to store end time of the program run
g_commit_chunk_size   NUMBER;       --based on profile value
g_pkg_name            VARCHAR2(50) := 'BIX_DM_SESSBYCAMP_PKG' ;
g_debug_flag                  VARCHAR2(1)  := 'N';


PROCEDURE write_log(p_pkg_name  in VARCHAR2,
                    p_proc_name in VARCHAR2,
                    p_msg in VARCHAR2 )
IS
    l_proc_name VARCHAR2(20) := 'WRITE_LOG';
BEGIN
  IF (g_debug_flag = 'Y') THEN
    fnd_file.put_line(fnd_file.log,TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
		 ' : ' || p_proc_name || ' : '|| p_msg);
  END IF;
EXCEPTION
    WHEN OTHERS THEN
         RAISE;
END write_log;

PROCEDURE insert_log_table
IS
  l_proc_name VARCHAR2(20) := 'INSERT_LOG_TABLE';
BEGIN

/* Insert status into log table */
   INSERT INTO BIX_DM_COLLECT_LOG
        (
        collect_id,
        collect_concur_id,
        object_name,
        object_type,
        run_start_date,
        run_end_date,
        collect_start_date,
        collect_end_date,
        collect_status,
        collect_excep_mesg,
        rows_deleted,
        rows_inserted,
        rows_updated,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date
        )
  VALUES
        (
        BIX_DM_COLLECT_LOG_S.NEXTVAL,
        null,
        g_table_name,
        'TABLE',
        g_run_start_date,
        g_run_end_date,
        g_collect_start_date,
        g_collect_end_date,
        g_status,
        g_error_msg,
        g_delete_count,
        g_insert_count,
        g_update_count,
        sysdate,
        g_user_id,
        sysdate,
        g_user_id,
        g_login_id,
        g_request_id,
        g_program_appl_id,
        g_program_id,
        sysdate
        );
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END insert_log_table;


PROCEDURE delete_in_chunks(p_table_name    IN VARCHAR2,
                           p_type          IN NUMBER,
                           p_rows_deleted OUT nocopy NUMBER)
IS
  l_delete_statement   VARCHAR2(4000);
  l_where_clause       VARCHAR2(1000);
  l_rows_deleted       NUMBER;
  l_proc_name VARCHAR2(20) := 'DELETE_IN_CHUNKS';

  e_invalid_condition EXCEPTION;

BEGIN

  --IF p_type = 1
  --THEN
      --l_where_clause := ' period_start_date_time between to_date(''' ||
               --to_char(g_rounded_collect_start_date, 'YYYY/MM/DDHH24:MI:SS') ||
                     --''', ''YYYY/MM/DDHH24:MI:SS'') and to_date(''' ||
               --to_char(g_rounded_collect_end_date, 'YYYY/MM/DDHH24:MI:SS') ||
                    --''', ''YYYY/MM/DDHH24:MI:SS'')' ;
  --ELSE
      --l_where_clause :=  ' request_id =  ' || g_request_id  ;
  --END IF;

  --l_delete_statement := 'DELETE FROM '|| p_table_name ||
                          --' WHERE ' || l_where_clause ||
              	          --'   AND rownum <= ' || g_commit_chunk_size  ;
  l_rows_deleted := 0;

   --  dbms_output.put_line('SQL Statement: '||l_delete_statement);

  LOOP
      --EXECUTE IMMEDIATE l_delete_statement;

	 IF(p_type = 1 AND p_table_name = 'BIX_DM_AGENT_SESSBYCAMP_SUM') THEN
	 	DELETE FROM BIX_DM_AGENT_SESSBYCAMP_SUM
	     WHERE period_start_date_time between g_rounded_collect_start_date
		   AND g_rounded_collect_end_date
	     AND rownum <= g_commit_chunk_size;
	 ELSIF(p_type = 1 AND p_table_name = 'BIX_DM_GROUP_SESSBYCAMP_SUM') THEN
	     DELETE FROM BIX_DM_GROUP_SESSBYCAMP_SUM
	     WHERE period_start_date_time between g_rounded_collect_start_date
		   AND g_rounded_collect_end_date
	     AND rownum <= g_commit_chunk_size;
	 ELSIF(p_type = 2 AND  p_table_name = 'BIX_DM_AGENT_SESSBYCAMP_SUM') THEN
	     DELETE FROM BIX_DM_AGENT_SESSBYCAMP_SUM
	     WHERE request_id =  g_request_id
	     AND rownum <= g_commit_chunk_size;
	 ELSIF(p_type = 2 AND p_table_name = 'BIX_DM_GROUP_SESSBYCAMP_SUM') THEN
	     DELETE FROM BIX_DM_GROUP_SESSBYCAMP_SUM
          WHERE request_id =  g_request_id
	     AND rownum <= g_commit_chunk_size;
      ELSE
	    RAISE e_invalid_condition;
	 END IF;

      l_rows_deleted := l_rows_deleted + SQL%ROWCOUNT;

      IF SQL%ROWCOUNT < g_commit_chunk_size
      THEN
          COMMIT;
          EXIT;
      ELSE
          COMMIT;
      END IF;
  END LOOP;
  g_message := 'Deleted ' || l_rows_deleted || ' rows from table '
					 || p_table_name ;
  write_log(g_pkg_name, l_proc_name, g_message  );
  p_rows_deleted := l_rows_deleted;

EXCEPTION
	WHEN e_invalid_condition then
	    g_proc_name := 'BIX_DM_SESSBYCAMP_PKG.DELETE_IN_CHUNKS';
	    g_error_msg := 'Invalid IF condition in delete ';
            raise;
	WHEN OTHERS THEN
            RAISE;
END delete_in_chunks;


PROCEDURE INSERT_WORKTIME_ROW(p_resource_id in NUMBER,
						p_server_group_id in NUMBER,
						p_campaign_id in NUMBER,
						p_campaign_schedule_id in NUMBER,
                              p_start_date  in DATE,
                              p_secs        in NUMBER,
                              p_ddl_type OUT nocopy VARCHAR2)
IS
   l_proc_name VARCHAR2(20) := 'INSERT_WORKTIME_ROW';
   l_exists    VARCHAR2(1)  := 'N' ;
BEGIN
    g_proc_name := l_proc_name;

    BEGIN
        SELECT 'Y'
		INTO l_exists
		FROM BIX_DM_AGENT_SESSBYCAMP_SUM
         WHERE resource_id = p_resource_id
		 AND period_start_date_time = p_start_date
		 AND server_group_id = p_server_group_id
		 AND campaign_id = p_campaign_id
		 AND campaign_schedule_id = p_campaign_schedule_id;
    EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		   l_exists := 'N';
        WHEN OTHERS THEN
		   raise;
    END;

    IF l_exists = 'N'
    THEN
        INSERT INTO BIX_DM_AGENT_SESSBYCAMP_SUM
        ( agent_sessbycamp_sum_id
         ,resource_id
	    ,server_group_id
	    ,campaign_id
	    ,campaign_schedule_id
         ,period_start_date
         ,period_start_time
         ,period_start_date_time
         ,last_update_date
         ,last_updated_by
         ,creation_date
         ,created_by
         ,last_update_login
         ,work_time
         ,available_time
         ,request_id
         ,program_application_id
         ,program_id
         ,program_update_date
        ) VALUES
        ( BIX_DM_AGENT_SESSBYCAMP_SUM_S.NEXTVAL
         ,p_resource_id
	    ,p_server_group_id
	    ,p_campaign_id
	    ,p_campaign_schedule_id
         ,TRUNC(p_start_date)
         ,TO_CHAR(p_start_date,'HH24:MI')
         ,p_start_date
         ,SYSDATE
         ,g_user_id
         ,SYSDATE
         ,g_user_id
         ,g_user_id
         ,p_secs
         ,0
         ,g_request_id
         ,g_program_appl_id
         ,g_program_id
         ,SYSDATE );
         p_ddl_type := 'I' ;
   ELSE
	  UPDATE BIX_DM_AGENT_SESSBYCAMP_SUM
          SET work_time = work_time + p_secs,
		    last_update_date = SYSDATE,
		    last_updated_by  = g_user_id,
		    program_update_date = SYSDATE
	   WHERE resource_id = p_resource_id
	     AND period_start_date_time = p_start_date
		 AND server_group_id = p_server_group_id
		 AND campaign_schedule_id = p_campaign_schedule_id;

           p_ddl_type := 'U' ;
   END IF;
  EXCEPTION
      WHEN OTHERS THEN
            RAISE;
END INSERT_WORKTIME_ROW;

PROCEDURE collect_agent_work_time
IS
  l_end_Date DATE;
  l_begin_date DATE;
  l_period_start DATE;
  l_work_start  DATE;
  l_work_end    DATE;
  l_secs NUMBER;
  l_row_count NUMBER :=0;
  l_row_counter NUMBER := 0;
  l_agent_cost	NUMBER := 0;
  l_temp VARCHAR2(100);
  l_ddl_type VARCHAR2(1);
  l_proc_name VARCHAR2(25) := 'COLLECT_AGENT_WORK_TIME';

 CURSOR get_work_time IS
 SELECT sess.resource_id resource_id,
       campsch.campaign_id campaign_id,
       campsch.schedule_id campaign_schedule_id,
       res.server_group_id server_group_id,
       min(act.begin_date_time) begin_date_time,
       max(act.end_date_time) end_date_time
  FROM ieu_sh_sessions          sess,
       ieu_sh_activities        act,
       jtf_rs_resource_extns    res,
       ams_campaign_schedules_b campsch,
       jtf_ih_media_items       mditem,
       iec_g_list_subsets       iecsub,
       ams_act_lists            amslis
 WHERE sess.session_id = act.session_id
   AND sess.resource_id = res.resource_id
   AND sess.application_id = 696
   AND act.activity_type_code = 'MEDIA'
   AND act.category_type = 'CSCH'
   AND act.media_type_id = 10009
   AND mditem.source_item_id = iecsub.list_subset_id
   and iecsub.list_header_id = amslis.list_header_id
   and amslis.list_used_by_id = campsch.schedule_id
   and amslis.list_used_by = 'CSCH'
   and amslis.list_Act_type = 'TARGET'
   and act.media_id = mditem.media_id
   and mditem.direction = 'OUTBOUND'
   and mditem.media_item_type = 'TELEPHONE'
   AND sess.begin_date_time <= g_rounded_collect_end_date
   AND (sess.end_date_time >= g_rounded_collect_start_date OR
       sess.end_date_time is NULL)
 group by sess.resource_id,
          campsch.campaign_id,
          campsch.schedule_id,
          res.server_group_id,
          act.parent_cycle_id;

BEGIN

   g_proc_name := l_proc_name;
   g_message := 'Start collecting work time into BIX_DM_AGENT_SESSBYCAMP_SUM';
   write_log( g_pkg_name, l_proc_name, g_message );

   FOR work_time IN  get_work_time
   LOOP
        /* If the session started before the time window that the concurrent
		 program is running mark the begin date as collection start date
		 time of the time window */
        IF ( work_time.begin_date_time < g_rounded_collect_start_date )
        THEN
	     l_begin_date := g_rounded_collect_start_date;
	   ELSE
	     l_begin_date := work_time.begin_date_time;
        END IF;

        /* If the activity ended after the collection end date , mark the
		 end date as  collection end date */
        IF( work_time.end_date_time IS NULL OR
		  work_time.end_date_time > g_rounded_collect_end_date)
        THEN
            l_end_date := g_rounded_collect_end_date + (1/(24*3600));
	   ELSE
	      l_end_date := work_time.end_date_time;
	   END IF;

        /* get the nearest lowest time bucket for the begin date
		 to populate appropriate bucket */
	   SELECT TO_CHAR(l_begin_date,'YYYY/MM/DD')||
                       LPAD(TO_CHAR(l_begin_date,'HH24:'),3,'0')||
                DECODE(SIGN(TO_NUMBER(TO_CHAR(l_begin_date,'MI'))-29),
						 0,'00',1,'30',-1,'00')
          INTO l_temp FROM DUAL;

	   l_period_start := TO_DATE(l_temp,'YYYY/MM/DDHH24:MI');
        l_row_counter := 0;
        WHILE ( l_period_start < l_end_date )
        LOOP
            IF (l_row_counter = 0 )
            THEN
                l_work_start := l_begin_date;
            ELSE
                l_work_start := l_period_start;
            END IF;

            l_work_end := l_period_start + 1/48;
            IF ( l_work_end > l_end_date )
            THEN
                 l_work_end := l_end_date ;
            END IF;

            l_secs := round((l_work_end - l_work_start) * 24 * 3600);

            INSERT_WORKTIME_ROW(work_time.resource_id,
						  work_time.server_group_id,
						  work_time.campaign_id,
						  work_time.campaign_schedule_id,
						  l_period_start,
						  l_secs,
					       l_ddl_type);

            IF l_ddl_type = 'I'
            THEN
                l_row_count := l_row_count + 1;
            END IF;
            l_row_counter := l_row_counter + 1;
            l_period_start := l_period_start + 1/48;

            IF(MOD(l_row_count,g_commit_chunk_size)=0)
            THEN
	           COMMIT;
	       END IF;
        END LOOP;  -- end of WHILE loop

  END LOOP; -- End of FOR loop.

  COMMIT;
  g_message :=  'Finished collecting agent work time : Inserted ' ||
				l_row_count || ' rows into BIM_DM_AGENT_SESSBYCAMP_SUM' ;
  write_log(g_pkg_name, l_proc_name, g_message );

  g_insert_count := l_row_count;

  EXCEPTION
   WHEN OTHERS THEN
        RAISE;

END collect_agent_work_time;


PROCEDURE collect_agent_avail_time
AS
  l_end_Date DATE;
  l_begin_date DATE;
  l_period_start DATE;
  l_work_start  DATE;
  l_work_end    DATE;
  l_secs number;
  l_row_count NUMBER := 0;
  l_row_counter NUMBER := 0;
  l_temp VARCHAR2(100);
  l_proc_name VARCHAR2(25) := 'COLLECT_AGENT_AVAIL_TIME';

    CURSOR get_avail_time IS
            SELECT sess.resource_id       resource_id,
               res.server_group_id    server_group_id,
               campsch.campaign_id    campaign_id,
               campsch.schedule_id    campaign_schedule_id,
               act1.begin_date_time   begin_date_time,
               act1.deliver_date_time end_date_time
          FROM ieu_sh_sessions          sess,
               ieu_sh_activities        act1,
               jtf_rs_resource_extns    res,
               ams_campaign_schedules_b campsch,
               jtf_ih_media_items       mditem,
               iec_g_list_subsets       iecsub,
               ams_act_lists            amslis
         WHERE act1.begin_date_time <= g_rounded_collect_end_date
           AND (act1.deliver_date_time >= g_rounded_collect_start_date OR
               (act1.deliver_date_time is NULL AND act1.end_date_time IS NULL))
           AND sess.application_id = 696
           AND sess.session_id = act1.session_id
           AND sess.resource_id = res.resource_id
           AND act1.activity_type_code = 'MEDIA'
           AND act1.category_type = 'CSCH'
           AND act1.media_type_id = 10009 --outbound calls
           AND mditem.source_item_id = iecsub.list_subset_id
           and iecsub.list_header_id = amslis.list_header_id
           and amslis.list_used_by_id = campsch.schedule_id
           and amslis.list_used_by = 'CSCH'
           and amslis.list_Act_type = 'TARGET'
           and act1.media_id = mditem.media_id
           and mditem.direction = 'OUTBOUND'
           and mditem.media_item_type = 'TELEPHONE'

        UNION ALL

        SELECT sess.resource_id     resource_id,
               res.server_group_id  server_group_id,
               campsch.campaign_id  campaign_id,
               campsch.schedule_id  campaign_schedule_id,
               act1.begin_date_time begin_date_time,
               act1.end_date_time   end_date_time
          FROM ieu_sh_sessions          sess,
               ieu_sh_activities        act1,
               jtf_rs_resource_extns    res,
               ams_campaign_schedules_b campsch,
               jtf_ih_media_items mditem,
               iec_g_list_subsets       iecsub,
               ams_act_lists            amslis
         WHERE act1.begin_date_time <= g_rounded_collect_end_date
           AND act1.end_date_time >= g_rounded_collect_start_date
           AND act1.deliver_date_time IS NULL
           AND sess.application_id = 696
           AND sess.session_id = act1.session_id
           AND sess.resource_id = res.resource_id
           AND act1.activity_type_code = 'MEDIA'
           AND act1.category_type = 'CSCH'
           AND act1.media_type_id = 10009 --outbound calls
           AND mditem.source_item_id = iecsub.list_subset_id
           and iecsub.list_header_id = amslis.list_header_id
           and amslis.list_used_by_id = campsch.schedule_id
           and amslis.list_used_by = 'CSCH'
           and amslis.list_Act_type = 'TARGET'
           and act1.media_id = mditem.media_id
           and mditem.direction = 'OUTBOUND'
           and mditem.media_item_type = 'TELEPHONE';

BEGIN

  g_proc_name := l_proc_name ;
  g_message := 'Start collecting agent available time';
  write_log( g_pkg_name, l_proc_name, g_message);

  FOR avail_time IN get_avail_time
  LOOP

      /* If the Resource has been avilable before collection start date time
      mark the begin date as collection start date time of the time window */
      IF ( avail_time.begin_date_time < g_rounded_collect_start_date ) THEN
	    l_begin_date := g_rounded_collect_start_date;
	 ELSE
	    l_begin_date := avail_time.begin_date_time;
      END IF;

      /* If the Resource is continue to be avilable after the collection
	    end date, mark the end date as  collection end date */
      IF( avail_time.end_date_time IS NULL OR
		avail_time.end_date_time > g_rounded_collect_end_date) THEN
         l_end_date := g_rounded_collect_end_date + (1/(24*3600));
	 ELSE
	    l_end_date := avail_time.end_date_time;
	 END IF;

	 SELECT TO_CHAR(l_begin_date,'YYYY/MM/DD')||
               LPAD(TO_CHAR(l_begin_date,'HH24:'),3,'0') ||
               DECODE(SIGN(TO_NUMBER(TO_CHAR(l_begin_date,'MI'))-29),
			   0,'00',1,'30',-1,'00')
        INTO l_temp FROM DUAL;

       l_period_start := TO_DATE(l_temp,'YYYY/MM/DDHH24:MI');
       l_row_counter := 0;
       WHILE ( l_period_start < l_end_date )
       LOOP
            IF (l_row_counter = 0 )
            THEN
                l_work_start := l_begin_date;
            ELSE
                l_work_start := l_period_start;
            END IF;

            l_work_end := l_period_start + 1/48;
            IF ( l_work_end > l_end_date )
            THEN
                 l_work_end := l_end_date ;
            END IF;
            l_secs := round((l_work_end - l_work_start) * 24 * 3600);
    	       IF (l_secs > 0 )
            THEN

                UPDATE BIX_DM_AGENT_SESSBYCAMP_SUM
            	   SET available_time = nvl(available_time,0)+l_secs,
		            last_update_date = SYSDATE,
		            last_updated_by  = g_user_id,
				  program_update_date = SYSDATE
	           WHERE resource_id = avail_time.resource_id
			   AND server_group_id = avail_time.server_group_id
			   AND campaign_id = avail_time.campaign_id
			   AND campaign_schedule_id = avail_time.campaign_schedule_id
	             AND period_start_date_time = l_period_start;

                l_row_count := l_row_count + 1;
            END IF;

            l_row_counter := l_row_counter + 1;
	       l_period_start := l_period_start + 1/48;

            IF(MOD(l_row_count,g_commit_chunk_size)=0) THEN
	           COMMIT;
            END IF;

        END LOOP;  -- end of WHILE loop
  END LOOP; -- End of FOR loop.

  COMMIT;
  g_update_count := l_row_count;
  g_message := 'Finished collecting agent available time : Updated ' ||
			   l_row_count || ' rows in BIM_DM_AGENT_SESSBYCAMP_SUM' ;
   write_log(g_pkg_name, l_proc_name, g_message );

EXCEPTION
   WHEN OTHERS THEN
        RAISE;
END collect_agent_avail_time;


PROCEDURE populate_groups
IS

l_row_count NUMBER := 0;
l_proc_name VARCHAR2(20) := 'POPULATE_GROUPS';

CURSOR group_agents IS
    SELECT grp_denorm.parent_group_id group_id,
		 agt_sum.server_group_id server_group_id,
		 agt_sum.campaign_id campaign_id,
		 agt_sum.campaign_schedule_id campaign_schedule_id,
           agt_sum.period_start_date,
           agt_sum.period_start_time,
           agt_sum.period_start_date_time,
           SUM(agt_sum.available_time) available_time,
           SUM(agt_sum.work_time) work_time
      FROM BIX_DM_AGENT_SESSBYCAMP_sum agt_sum,
           jtf_rs_group_members     grp_mem,
           jtf_rs_groups_denorm     grp_denorm
     WHERE agt_sum.period_start_date_time  BETWEEN g_rounded_collect_start_date
				 AND g_rounded_collect_end_date
       AND agt_sum.resource_id = grp_mem.resource_id
       AND grp_mem.group_id    = grp_denorm.group_id
--
--add the following to take care of cases where
--agent belongs to two groups which roll up to the
--same parent group to avoid duplicating the values
--for the parent group
--
AND   NVL(grp_mem.delete_flag,'N') <> 'Y'
AND   agt_sum.period_start_date_time BETWEEN
NVL(grp_denorm.start_date_active,agt_sum.period_start_date_time)
AND NVL(grp_denorm.end_date_active,SYSDATE)
AND   grp_mem.group_member_id =
                  (select max(mem1.group_member_id)
                   from jtf_rs_group_members mem1
                   where mem1.group_id in
                     (select den1.group_id
                      from   jtf_rs_groups_denorm den1
                      where  den1.parent_group_id = grp_denorm.parent_group_id
                      AND    agt_sum.period_start_date_time BETWEEN
                             NVL(den1.start_date_active,agt_sum.period_start_date_time)
                             AND NVL(den1.end_date_active,SYSDATE)
                      )
                   AND mem1.resource_id = grp_mem.resource_id
                   AND nvl(mem1.delete_flag,'N') <> 'Y'
                   )
  GROUP BY grp_denorm.parent_group_id,
		 agt_sum.server_group_id,
		 agt_sum.campaign_id,
		 agt_sum.campaign_schedule_id,
           agt_sum.period_start_date_time,
           agt_sum.period_start_date,
           agt_sum.period_start_time;

BEGIN
    g_insert_count       := 0;
    g_delete_count       := 0;
    g_update_count       := 0;
    g_proc_name := l_proc_name ;
    g_table_name         := 'BIX_DM_GROUP_SESSBYCAMP_SUM';

    /* Delete data between these dates and re-compute */
    delete_in_chunks( 'BIX_DM_GROUP_SESSBYCAMP_SUM', 1, g_delete_count);

    g_message := 'Start Inserting  rows into BIX_DM_GROUP_SESSION_SUM table';
    write_log(g_pkg_name, l_proc_name, g_message );

    FOR groupinfo IN  group_agents
    LOOP
	  INSERT INTO BIX_DM_GROUP_SESSBYCAMP_SUM
	  ( group_sessbycamp_sum_id
         ,group_id
	    ,server_group_id
	    ,campaign_id
	    ,campaign_schedule_id
         ,period_start_date
         ,period_start_time
         ,period_start_date_time
         ,last_update_date
         ,last_updated_by
         ,creation_date
         ,created_by
         ,last_update_login
         ,available_time
         ,work_time
         ,request_id
         ,program_application_id
         ,program_id
         ,program_update_date )
       VALUES (
 	     BIX_DM_GROUP_CALL_SUM_S.NEXTVAL
          ,groupinfo.group_id
		,groupinfo.server_group_id
		,groupinfo.campaign_id
		,groupinfo.campaign_schedule_id
     	,groupinfo.period_start_date
	     ,groupinfo.period_start_time
	     ,groupinfo.period_start_date_time
	     ,SYSDATE
	     ,g_user_id
	     ,SYSDATE
	     ,g_user_id
	     ,g_user_id
	     ,groupinfo.available_time
	     ,groupinfo.work_time
	     ,g_request_id
	     ,g_program_appl_id
	     ,g_program_id
	     ,SYSDATE
         );

	   l_row_count := l_row_count + 1;
   	   IF(MOD(l_row_count,g_commit_chunk_size)=0) THEN
	       COMMIT;
	   END IF;

    END LOOP;

    g_message :=  'Finished inserting rows into BIX_DM_GROUP_SESSBYCAMP_SUM. Inserted ' || l_row_count || ' rows ';
    write_log(g_pkg_name, l_proc_name, g_message );

    g_insert_count := l_row_count;

    g_run_end_date := sysdate;
    g_status      := 'SUCCESS';
    insert_log_table;
    COMMIT;

 EXCEPTION
   WHEN OTHERS THEN
        g_message     := 'ERROR : '|| sqlerrm;
        g_error_msg     := 'Failed while executing ' || g_proc_name || ':'
		    || sqlcode ||':'|| sqlerrm;
        write_log(g_pkg_name, l_proc_name, g_message);

        g_message :='Start rolling back data in BIX_DM_GROUP_SESSBYCAMP_SUM table';
        write_log(g_pkg_name, l_proc_name, g_message );

        BEGIN
             delete_in_chunks('BIX_DM_GROUP_SESSBYCAMP_SUM', 2, l_row_count);
	        g_message := 'Finished rolling back data in BIX_DM_GROUP_SESSBYCAMP_SUM table';
             write_log(g_pkg_name, l_proc_name, g_message );
	   EXCEPTION
	       WHEN OTHERS THEN
               g_message := 'Failed to roll back data in BIX_DM_GROUP_SESSBYCAMP_SUM table ';
               write_log(g_pkg_name, l_proc_name, g_message );
	   END;

       g_message := 'Start rolling back data in BIX_DM_AGENT_SESSBYCAMP_SUM table';
       write_log(g_pkg_name, l_proc_name, g_message );

       BEGIN
          delete_in_chunks('BIX_DM_AGENT_SESSBYCAMP_SUM', 2, l_row_count);
	     g_message := 'Finished Rollling back data in BIX_DM_AGENT_SESSBYCAMP_SUM table ' ;
          write_log(g_pkg_name, l_proc_name, g_message );
	  EXCEPTION
	       WHEN OTHERS THEN
               g_message := 'Failed to roll back data in BIX_DM_AGENT_SESSBYCAMP_SUM table ';
               write_log(g_pkg_name, l_proc_name, g_message );
	  END;

       UPDATE BIX_DM_COLLECT_LOG
          SET collect_status  = 'FAILURE',
              rows_inserted = 0,
              rows_updated  = 0,
              collect_excep_mesg = g_error_msg
        WHERE request_id = g_request_id
          AND object_name = 'BIX_DM_GROUP_SESSBYCAMP_SUM';

        g_run_end_date := sysdate;
        g_status      := 'FAILURE';
        insert_log_table;

        RAISE;
END populate_groups;


PROCEDURE populate_agents
IS
  l_proc_name VARCHAR2(20) := 'POPULATE_AGENTS';
  l_delete_count  NUMBER   := 0;
BEGIN
    g_insert_count       := 0;
    g_delete_count       := 0;
    g_update_count       := 0;
    g_proc_name          := l_proc_name;
    g_table_name         := 'BIX_DM_AGENT_SESSBYCAMP_SUM';

   /* Delete data between these dates and re-compute */
   delete_in_chunks( 'BIX_DM_AGENT_SESSBYCAMP_SUM', 1, g_delete_count);

   /* Procedure collects Agent work time  from IEU_SH_SESSIONS table */
   collect_agent_work_time;

   /* Procedure collects Agent avialable time  from IEU_SH_SESSIONS
	 ,IEU_SH_ACTIVITIES tables */
   collect_agent_avail_time;

   /* Insert the status into BIX_DM_COLLECT_LOG table */
   g_run_end_date := sysdate;
   g_status      := 'SUCCESS';
   insert_log_table;

   COMMIT;  --commit after all rows are inserted in BIX_DM_AGENT_SESSBYCAMP_sum

EXCEPTION
   WHEN OTHERS THEN
        g_message := 'Failed while populating BIX_DM_AGENT_SESSBYCAMP_sum : '||
				  sqlerrm;
        write_log(g_pkg_name, l_proc_name, g_message);

        g_message :='Start rolling back data in BIX_DM_AGENT_SESSBYCAMP_SUM table';
        write_log(g_pkg_name, l_proc_name, g_message );

	   BEGIN
             delete_in_chunks('BIX_DM_AGENT_SESSBYCAMP_SUM', 2, l_delete_count);
	        g_message := 'Finished rolling back data in BIX_DM_AGENT_SESSBYCAMP_SUM table' ;
             write_log(g_pkg_name, l_proc_name, g_message );
        EXCEPTION
	       WHEN OTHERS THEN
               g_message := 'Failed to roll back data in BIX_DM_AGENT_SESSBYCAMP_SUM table ';
               write_log(g_pkg_name, l_proc_name, g_message );
	   END;

        g_run_end_date := sysdate;
        g_status      := 'FAILURE';
        g_insert_count := 0;
        g_update_count := 0;
        g_error_msg     := 'Failed while executing ' || g_proc_name
					    || ':' || sqlcode ||':'|| sqlerrm;
        insert_log_table;
        RAISE;

END populate_agents;

/*
  This procedure is the main procedure which is called from the concurrent
  program. It calls two other procedures to get the agent and group
  session information.
*/
PROCEDURE populate_all               ( errbuf        OUT nocopy VARCHAR2,
                                       retcode       OUT nocopy VARCHAR2,
                                       p_start_date  IN  VARCHAR2,
                                       p_end_date    IN  VARCHAR2 )
IS
  l_proc_name VARCHAR2(35) := 'POPULATE_SESSBYCAMP_SUM_TABLES';

BEGIN

   g_run_start_date     := sysdate;
   g_proc_name := l_proc_name;

   /* Determine value of commit size. If the profile is not defined,
	 assume 100 rows. */
   IF FND_PROFILE.DEFINED('BIX_DM_DELETE_SIZE')
   THEN
      g_commit_chunk_size := TO_NUMBER(FND_PROFILE.VALUE('BIX_DM_DELETE_SIZE'));
   ELSE
      g_commit_chunk_size := 100;
   END IF;

   IF (FND_PROFILE.DEFINED('BIX_DBI_DEBUG')) THEN
     g_debug_flag := nvl(FND_PROFILE.VALUE('BIX_DBI_DEBUG'), 'N');
   END IF;

   /* Concurrent program is passing date as YYYY/MM/DD HH24:MI:SS. */
   g_collect_start_date := TO_DATE(p_start_date,'YYYY/MM/DD HH24:MI:SS');
   g_collect_end_date := TO_DATE(p_end_date,'YYYY/MM/DD HH24:MI:SS');

   /* Round the collection start date to the nearest lower time bucket.
	 eg: if time is between 10:00 and 10:29 round it to 10:00.
   */
   SELECT TO_DATE(TO_CHAR(g_collect_start_date,'YYYY/MM/DD')||
	LPAD(TO_CHAR(g_collect_start_date,'HH24:'),3,'0')||
	DECODE(SIGN(TO_NUMBER(TO_CHAR(g_collect_start_date,'MI'))-29),
		   0,'00:00',1,'30:00',-1,'00:00'), 'YYYY/MM/DDHH24:MI:SS')
    INTO g_rounded_collect_start_date
    FROM DUAL;

    /* Round the collection end date to nearest higher time bucket.
	  eg: if time is between 10:00 and 10:29 round it to 10:29:59
    */
    SELECT TO_DATE(
	TO_CHAR(g_collect_end_date,'YYYY/MM/DD')||
	LPAD(TO_CHAR(g_collect_end_date,'HH24:'),3,'0')||
	DECODE(SIGN(TO_NUMBER(TO_CHAR(g_collect_end_date,'MI'))-29),
		0,'29:59',1,'59:59',-1,'29:59'), 'YYYY/MM/DDHH24:MI:SS')
     INTO g_rounded_collect_end_date
     FROM DUAL;

    g_message   := 'Collection Period : '||
       to_char(g_rounded_collect_start_date,'DD-MON-YYYY HH24:MI:SS') || ' to '
	         || to_char(g_rounded_collect_end_date, 'DD-MON-YYYY HH24:MI:SS');
    write_log(g_pkg_name, l_proc_name, g_message);

    g_message := '-----------------------------------------------------------';
    write_log(g_pkg_name, l_proc_name, g_message);

    g_message   := 'Start collecting agent session information';
    write_log(g_pkg_name, l_proc_name, g_message);

    populate_agents;

    g_message   := 'Finished collecting agent session information';
    write_log(g_pkg_name, l_proc_name, g_message);

    g_message := '----------------------------------------------------------';
    write_log(g_pkg_name, l_proc_name, g_message);

    g_message   := 'Start processing group session information';
    write_log(g_pkg_name, l_proc_name, g_message);

    populate_groups;

    g_message   := 'Finished processing group session information';
    write_log(g_pkg_name, l_proc_name, g_message);

    g_message := '--------------------------------------------------------';
    write_log(g_pkg_name, l_proc_name, g_message);

    /*
     Success log tables were already inserted, so just commit
    */
    COMMIT;

EXCEPTION
   WHEN OTHERS THEN
       retcode         := sqlcode;
       errbuf          := sqlerrm;
       g_status        := 'FAILURE';
       g_error_msg     := 'Failed while executing ' || g_proc_name || ':' ||
					  sqlcode ||':'|| sqlerrm;
       g_message       :=  'ERROR : ' || sqlerrm;
       write_log(g_pkg_name, g_proc_name, g_message);

       COMMIT;
END populate_all;

END BIX_DM_SESSBYCAMP_PKG;

/
