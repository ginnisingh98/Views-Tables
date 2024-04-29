--------------------------------------------------------
--  DDL for Package Body BIX_DM_SESSIONINFO_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_DM_SESSIONINFO_SUMMARY_PKG" AS
/*$Header: bixxsagb.plb 120.0 2005/05/25 17:21:00 appldev noship $ */

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
g_pkg_name            VARCHAR2(50) := 'BIX_DM_SESSIONINFO_SUMMARY_PKG' ;
g_debug_flag                  VARCHAR2(1)  := 'N';

G_DATE_MISMATCH             EXCEPTION;

PROCEDURE write_log(p_pkg_name  VARCHAR2,
                    p_proc_name VARCHAR2,
                    p_msg VARCHAR2 )
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
  l_rows_deleted       NUMBER;
  l_proc_name VARCHAR2(20) := 'DELETE_IN_CHUNKS';

BEGIN

  l_rows_deleted := 0;

  LOOP

	 IF(p_type = 1 AND p_table_name = 'BIX_DM_AGENT_SESSION_SUM') THEN
	 	DELETE FROM BIX_DM_AGENT_SESSION_SUM
	     WHERE period_start_date_time between g_rounded_collect_start_date AND g_rounded_collect_end_date
	     AND rownum <= g_commit_chunk_size;
	 ELSIF(p_type = 1 AND p_table_name = 'BIX_DM_GROUP_SESSION_SUM') THEN
	     DELETE FROM BIX_DM_GROUP_SESSION_SUM
	     WHERE period_start_date_time between g_rounded_collect_start_date AND g_rounded_collect_end_date
	     AND rownum <= g_commit_chunk_size;
	 ELSIF(p_type = 2 AND  p_table_name = 'BIX_DM_AGENT_SESSION_SUM') THEN
	     DELETE FROM BIX_DM_AGENT_SESSION_SUM
	     WHERE request_id =  g_request_id
	     AND rownum <= g_commit_chunk_size;
	 ELSIF(p_type = 2 AND p_table_name = 'BIX_DM_GROUP_SESSION_SUM') THEN
	     DELETE FROM BIX_DM_GROUP_SESSION_SUM
          WHERE request_id =  g_request_id
	     AND rownum <= g_commit_chunk_size;
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
	WHEN OTHERS THEN
            RAISE;
END delete_in_chunks;


PROCEDURE insert_login_row(p_resource_id IN NUMBER,
                           p_start_date  IN DATE,
                           p_secs        IN NUMBER,
                           p_agent_cost  IN NUMBER,
                           p_ddl_type OUT nocopy VARCHAR2)
IS
   l_proc_name VARCHAR2(20) := 'INSERT_LOGIN_ROW';
   l_exists    VARCHAR2(1)  := 'N' ;
BEGIN
    g_proc_name := l_proc_name;

    BEGIN
        SELECT 'Y'
		INTO l_exists
		FROM BIX_DM_AGENT_SESSION_SUM
         WHERE resource_id = p_resource_id
		 AND period_start_date_time = p_start_date;
    EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		   l_exists := 'N';
        WHEN OTHERS THEN
		   raise;
    END;

    IF l_exists = 'N'
    THEN
        INSERT INTO BIX_DM_AGENT_SESSION_SUM
        ( agent_session_summary_id
         ,resource_id
         ,period_start_date
         ,period_start_time
         ,period_start_date_time
         ,last_update_date
         ,last_updated_by
         ,creation_date
         ,created_by
         ,last_update_login
         ,login_time
         ,available_time
	    ,idle_time
         ,agent_cost
         ,request_id
         ,program_application_id
         ,program_id
         ,program_update_date
        ) VALUES
        ( BIX_DM_AGENT_SESSION_SUM_S.NEXTVAL
         ,p_resource_id
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
	    ,0
         ,(p_secs/3600)* p_agent_cost
         ,g_request_id
         ,g_program_appl_id
         ,g_program_id
         ,SYSDATE );
         p_ddl_type := 'I' ;
   ELSE
	  UPDATE BIX_DM_AGENT_SESSION_SUM
          SET login_time = login_time + p_secs,
		    agent_cost = agent_cost + ((p_secs/3600) * p_agent_cost ),
		    last_update_date = SYSDATE,
		    last_updated_by  = g_user_id,
		    program_update_date = SYSDATE
	   WHERE resource_id = p_resource_id
	     AND period_start_date_time = p_start_date;
           p_ddl_type := 'U' ;
   END IF;
  EXCEPTION
      WHEN OTHERS THEN
            RAISE;
END insert_login_row;

PROCEDURE collect_agent_idle_time(l_session_id IN NUMBER,
						    l_resource_id IN NUMBER,
						    l_ses_begin_Date IN DATE,
						    l_ses_end_date IN DATE)
--
--Idle time is calculated as the time between each media cycle activity.
--For the very first meda cycle activity, it is cycle start time - login time.
--
IS
  l_end_Date DATE;
  l_begin_date DATE;
  l_period_start DATE;
  l_idle_start  DATE;
  l_idle_end    DATE;
  l_prev_mc_start_date DATE;
  l_prev_mc_end_date DATE;
  l_secs number;
  l_row_count NUMBER := 0;
  l_row_counter NUMBER := 0;
  l_temp VARCHAR2(100);
  l_proc_name VARCHAR2(25) := 'COLLECT_AGENT_IDLE_TIME';
  l_count NUMBER := 0;

  CURSOR get_media_cycle_time IS
  SELECT begin_date_time,end_date_time
  FROM ieu_sh_activities
  WHERE session_id = l_session_id
  AND   activity_type_code = 'MEDIA_CYCLE'
  ORDER BY begin_date_time;

BEGIN

  g_proc_name := l_proc_name ;
  g_message := 'Start collecting agent idle time';
  write_log( g_pkg_name, l_proc_name, g_message);

  FOR media_cycle_time IN get_media_cycle_time
  LOOP

      /* If the MEDIA_CYCLE activity has been started before collection start date time
      mark the begin date as collection start date time of the time window */

    /* if the current row is the first  media_cycle row, then we need to calculate the time agent was idle before
        he pressed get work.
    */

      IF l_count = 0 THEN
          l_begin_date := l_ses_begin_date;
      ELSE
          l_begin_date := l_prev_mc_end_date;
      END IF;

       l_count := l_count + 1;

      /* If the MEDIA_CYCLE activity is continue to be open after the collection
	    end date, mark the end date as  collection end date */

         IF (media_cycle_time.begin_date_time > g_rounded_collect_end_date) THEN
            l_end_date := g_rounded_collect_end_date + (1/(24*3600));
         ELSE
            l_end_date := media_cycle_time.begin_date_time;
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
                l_idle_start := l_begin_date;
            ELSE
                l_idle_start := l_period_start;
            END IF;

            l_idle_end := l_period_start + 1/48;
            IF ( l_idle_end > l_end_date )
            THEN
                 l_idle_end := l_end_date ;
            END IF;
            l_secs := round((l_idle_end - l_idle_start) * 24 * 3600);
    	       IF (l_secs > 0 )
            THEN
                UPDATE BIX_DM_AGENT_SESSION_SUM
            	   SET idle_time = nvl(idle_time,0)+l_secs,
		            last_update_date = SYSDATE,
		            last_updated_by  = g_user_id,
				  program_update_date = SYSDATE
	           WHERE resource_id = l_resource_id
	             AND period_start_date_time = l_period_start;
                l_row_count := l_row_count + 1;
            END IF;

            l_row_counter := l_row_counter + 1;
	       l_period_start := l_period_start + 1/48;

            IF(MOD(l_row_count,g_commit_chunk_size)=0) THEN
	           COMMIT;
            END IF;

        END LOOP;  -- end of WHILE loop

      l_prev_mc_start_date := media_cycle_time.begin_date_time;
      l_prev_mc_end_date := media_cycle_time.end_date_time;

      IF ( l_prev_mc_end_date IS NULL) THEN
         EXIT;
      END IF;
  END LOOP; -- End of FOR loop.


 /* Calculate the time the agent is logged into UWQ after he press stop work
  This is the time agent is idle before he log out and after he pressed stop media
  */

    IF(l_count = 0) THEN -- if agent logged in and never pressed getwork.No media cycle rows present in activity table.
    l_begin_date := l_ses_begin_date;
    l_end_date := l_ses_end_date;
    ELSIF(l_prev_mc_end_date IS NOT NULL) THEN -- do not calculate idle time ,  if the last media_cycle is not ended.

	 l_begin_date := l_prev_mc_end_date;
	 l_end_date := l_ses_end_date;
   END IF;

   IF(l_count = 0 OR l_prev_mc_end_date IS NOT NULL ) THEN
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
                l_idle_start := l_begin_date;
            ELSE
                l_idle_start := l_period_start;
            END IF;

            l_idle_end := l_period_start + 1/48;
            IF ( l_idle_end > l_end_date )
            THEN
                 l_idle_end := l_end_date ;
            END IF;
            l_secs := round((l_idle_end - l_idle_start) * 24 * 3600);
    	       IF (l_secs > 0 )
            THEN
                UPDATE BIX_DM_AGENT_SESSION_SUM
            	   SET idle_time = nvl(idle_time,0)+l_secs,
		            last_update_date = SYSDATE,
		            last_updated_by  = g_user_id,
				  program_update_date = SYSDATE
	           WHERE resource_id = l_resource_id
	             AND period_start_date_time = l_period_start;
                l_row_count := l_row_count + 1;
            END IF;

            l_row_counter := l_row_counter + 1;
	       l_period_start := l_period_start + 1/48;

            IF(MOD(l_row_count,g_commit_chunk_size)=0) THEN
	           COMMIT;
            END IF;

        END LOOP;  -- end of WHILE loop
     END IF;

  COMMIT;
  g_update_count := l_row_count;
  g_message := 'Finished collecting agent idle time : Updated ' ||
			   l_row_count || ' rows in BIM_DM_AGENT_SESSION_SUM' ;
   write_log(g_pkg_name, l_proc_name, g_message );
EXCEPTION
   WHEN OTHERS THEN
        RAISE;
END collect_agent_idle_time;

PROCEDURE collect_agent_login_time
IS
  l_end_Date DATE;
  l_begin_date DATE;
  l_period_start DATE;
  l_login_start  DATE;
  l_login_end    DATE;
  l_secs NUMBER;
  l_row_count NUMBER :=0;
  l_row_counter NUMBER := 0;
  l_agent_cost	NUMBER := 0;
  l_temp VARCHAR2(100);
  l_ddl_type VARCHAR2(1);
  l_proc_name VARCHAR2(25) := 'COLLECT_AGENT_LOGIN_TIME';
  l_counter NUMBER := 0;

  CURSOR get_login_time IS
  SELECT iss.session_id session_id,
         iss.resource_id     resource_id,
	   iss.begin_date_time begin_date_time,
         iss.end_date_time   end_date_time
  FROM   ieu_sh_sessions iss
  WHERE  iss.application_id = 696
    AND  iss.begin_date_time <=  g_rounded_collect_end_date
    AND (iss.end_date_time >= g_rounded_collect_start_date
		 OR iss.end_date_time is NULL ) ;
BEGIN

   g_proc_name := l_proc_name;

   BEGIN
       IF (FND_PROFILE.DEFINED('BIX_DM_AGENT_COST')) THEN
          l_agent_cost := TO_NUMBER(FND_PROFILE.VALUE('BIX_DM_AGENT_COST'));
       ELSE
          g_message := 'Agent cost is not defined. Agent Cost set to zero.';
          write_log( g_pkg_name, l_proc_name, g_message );
       END IF;
   EXCEPTION
       WHEN OTHERS THEN
            l_agent_cost := 0;
            g_message := 'Failed to get the Agent cost.';
            write_log( g_pkg_name, l_proc_name, g_message );
   END;

   g_message := 'Start collecting agent login time into BIX_DM_AGENT_SESSION_SUM';
   write_log( g_pkg_name, l_proc_name, g_message );

   FOR login_time IN  get_login_time
   LOOP
        /* If the session started before the time window that the concurrent
		 program is running mark the begin date as collection start date
		 time of the time window */
        IF ( login_time.begin_date_time < g_rounded_collect_start_date )
        THEN
	     l_begin_date := g_rounded_collect_start_date;
	   ELSE
	     l_begin_date := login_time.begin_date_time;
        END IF;

        /* If the session is ended after the collection end date , mark the
		 end date as  collection end date */
        IF( login_time.end_date_time IS NULL OR
		  login_time.end_date_time > g_rounded_collect_end_date)
        THEN
            l_end_date := g_rounded_collect_end_date + (1/(24*3600));
	   ELSE
	      l_end_date := login_time.end_date_time;
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
                l_login_start := l_begin_date;
            ELSE
                l_login_start := l_period_start;
            END IF;

            l_login_end := l_period_start + 1/48;
            IF ( l_login_end > l_end_date )
            THEN
                 l_login_end := l_end_date ;
            END IF;

            l_secs := round((l_login_end - l_login_start) * 24 * 3600);
            INSERT_LOGIN_ROW(login_time.resource_id,l_period_start,l_secs,
					    l_agent_cost, l_ddl_type);

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

   -- call the collect_agent_idle_time to collect agent idle time for this session.

        COLLECT_AGENT_IDLE_TIME(login_time.session_id,login_time.resource_id,l_begin_date,l_end_date);

  END LOOP; -- End of FOR loop.

  COMMIT;
  g_message :=  'Finished collecting agent login time : Inserted ' ||
				l_row_count || ' rows into BIM_DM_AGENT_SESSION_SUM' ;
  write_log(g_pkg_name, l_proc_name, g_message );

  g_insert_count := l_row_count;

EXCEPTION
   WHEN OTHERS THEN
        RAISE;
END collect_agent_login_time;

PROCEDURE collect_agent_avail_time
AS
  l_end_Date DATE;
  l_begin_date DATE;
  l_period_start DATE;
  l_login_start  DATE;
  l_login_end    DATE;
  l_secs number;
  l_row_count NUMBER := 0;
  l_row_counter NUMBER := 0;
  l_temp VARCHAR2(100);
  l_proc_name VARCHAR2(25) := 'COLLECT_AGENT_AVAIL_TIME';

CURSOR get_avail_time IS
  SELECT iss.resource_id       resource_id,
         isa.begin_date_time   begin_date_time,
         isa.deliver_date_time end_date_time
    FROM ieu_sh_sessions iss,
	    ieu_sh_activities isa
   WHERE isa.begin_date_time <=  g_rounded_collect_end_date
     AND (isa.deliver_date_time >= g_rounded_collect_start_date
		OR (isa.deliver_date_time is NULL AND isa.end_date_time IS NULL)
	    )
     AND iss.application_id  = 696
     AND iss.session_id  = isa.session_id
     AND isa.activity_type_code = 'MEDIA'
	   UNION ALL
  SELECT iss.resource_id     resource_id,
         isa.begin_date_time begin_date_time,
         isa.end_date_time   end_date_time
    FROM ieu_sh_sessions iss,
	    ieu_sh_activities isa
   WHERE isa.begin_date_time <=  g_rounded_collect_end_date
     AND isa.end_date_time >= g_rounded_collect_start_date
     AND isa.deliver_date_time IS NULL
     AND iss.application_id  = 696
     AND iss.session_id  = isa.session_id
     AND isa.activity_type_code = 'MEDIA';

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
                l_login_start := l_begin_date;
            ELSE
                l_login_start := l_period_start;
            END IF;

            l_login_end := l_period_start + 1/48;
            IF ( l_login_end > l_end_date )
            THEN
                 l_login_end := l_end_date ;
            END IF;
            l_secs := round((l_login_end - l_login_start) * 24 * 3600);
    	       IF (l_secs > 0 )
            THEN
                UPDATE BIX_DM_AGENT_SESSION_SUM
            	   SET available_time = nvl(available_time,0)+l_secs,
		            last_update_date = SYSDATE,
		            last_updated_by  = g_user_id,
				  program_update_date = SYSDATE
	           WHERE resource_id = avail_time.resource_id
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
			   l_row_count || ' rows in BIM_DM_AGENT_SESSION_SUM' ;
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
    SELECT group_denorm.parent_group_id group_id,
           agt_sum.period_start_date,
           agt_sum.period_start_time,
           agt_sum.period_start_date_time,
           SUM(agt_sum.available_time) available_time,
           SUM(agt_sum.login_time) login_time,
		 SUM(agt_sum.idle_time) idle_time,
           SUM(agt_sum.agent_cost) group_cost
      FROM bix_dm_agent_session_sum agt_sum,
           jtf_rs_group_members     groups,
           jtf_rs_groups_denorm     group_denorm
WHERE agt_sum.period_start_date_time  BETWEEN g_rounded_collect_start_date
                                              AND g_rounded_collect_end_date
AND   agt_sum.resource_id = groups.resource_id
AND   groups.group_id    = group_denorm.group_id
AND   NVL(groups.delete_flag,'N') <> 'Y'
AND   agt_sum.period_start_date_time BETWEEN
      NVL(group_denorm.start_date_active,agt_sum.period_start_date_time)
      AND NVL(group_denorm.end_date_active,SYSDATE)
AND   groups.group_member_id =
       (select max(mem1.group_member_id)
        from jtf_rs_group_members mem1
        where mem1.group_id in
               (select den1.group_id
                from   jtf_rs_groups_denorm den1
                where  den1.parent_group_id = group_denorm.parent_group_id
                AND    agt_sum.period_start_date_time BETWEEN
                       NVL(den1.start_date_active,agt_sum.period_start_date_time)
                AND NVL(den1.end_date_active,SYSDATE)
               )
         AND mem1.resource_id = groups.resource_id
         AND nvl(mem1.delete_flag,'N') <> 'Y'
      )
GROUP BY group_denorm.parent_group_id,
           agt_sum.period_start_date_time,
           agt_sum.period_start_date,
           agt_sum.period_start_time;

BEGIN
    g_insert_count       := 0;
    g_delete_count       := 0;
    g_update_count       := 0;
    g_proc_name := l_proc_name ;
    g_table_name         := 'BIX_DM_GROUP_SESSION_SUM';

    /* Delete data between these dates and re-compute */
    delete_in_chunks( 'BIX_DM_GROUP_SESSION_SUM', 1, g_delete_count);

    g_message := 'Start Inserting  rows into BIX_DM_GROUP_SESSION_SUM table';
    write_log(g_pkg_name, l_proc_name, g_message );

    FOR groupinfo IN  group_agents
    LOOP
	  INSERT INTO BIX_DM_GROUP_SESSION_SUM
	  ( group_session_summary_id
         ,group_id
         ,period_start_date
         ,period_start_time
         ,period_start_date_time
         ,last_update_date
         ,last_updated_by
         ,creation_date
         ,created_by
         ,last_update_login
         ,available_time
         ,login_time
	    ,idle_time
         ,group_cost
         ,request_id
         ,program_application_id
         ,program_id
         ,program_update_date )
       VALUES (
 	     BIX_DM_GROUP_CALL_SUM_S.NEXTVAL
          ,groupinfo.group_id
     	,groupinfo.period_start_date
	     ,groupinfo.period_start_time
	     ,groupinfo.period_start_date_time
	     ,SYSDATE
	     ,g_user_id
	     ,SYSDATE
	     ,g_user_id
	     ,g_user_id
	     ,groupinfo.available_time
	     ,groupinfo.login_time
		,groupinfo.idle_time
          ,groupinfo.group_cost
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

    g_message :=  'Finished inserting rows into BIX_DM_GROUP_SESSION_SUM. Inserted ' || l_row_count || ' rows ';
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

        g_message :='Start rolling back data in BIX_DM_GROUP_SESSION_SUM table';
        write_log(g_pkg_name, l_proc_name, g_message );

        BEGIN
             delete_in_chunks('BIX_DM_GROUP_SESSION_SUM', 2, l_row_count);
	        g_message := 'Finished rolling back data in BIX_DM_GROUP_SESSION_SUM table';
             write_log(g_pkg_name, l_proc_name, g_message );
	   EXCEPTION
	       WHEN OTHERS THEN
               g_message := 'Failed to roll back data in BIX_DM_GROUP_SESSION_SUM table ';
               write_log(g_pkg_name, l_proc_name, g_message );
	   END;

       g_message := 'Start rolling back data in BIX_DM_AGENT_SESSION_SUM table';
       write_log(g_pkg_name, l_proc_name, g_message );

       BEGIN
          delete_in_chunks('BIX_DM_AGENT_SESSION_SUM', 2, l_row_count);
	     g_message := 'Finished Rollling back data in BIX_DM_AGENT_SESSION_SUM table ' ;
          write_log(g_pkg_name, l_proc_name, g_message );
	  EXCEPTION
	       WHEN OTHERS THEN
               g_message := 'Failed to roll back data in BIX_DM_AGENT_SESSION_SUM table ';
               write_log(g_pkg_name, l_proc_name, g_message );
	  END;

       UPDATE BIX_DM_COLLECT_LOG
          SET collect_status  = 'FAILURE',
              rows_inserted = 0,
              rows_updated  = 0,
              collect_excep_mesg = g_error_msg
        WHERE request_id = g_request_id
          AND object_name = 'BIX_DM_AGENT_SESSION_SUM';

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
    g_table_name         := 'BIX_DM_AGENT_SESSION_SUM';

   /* Delete data between these dates and re-compute */
   delete_in_chunks( 'BIX_DM_AGENT_SESSION_SUM', 1, g_delete_count);

   /* Procedure collects Agent login time  from IEU_SH_SESSIONS table */
   collect_agent_login_time;

   /* Procedure collects Agent avialable time  from IEU_SH_SESSIONS
	 ,IEU_SH_ACTIVITIES tables */
   collect_agent_avail_time;

   /* Insert the status into BIX_DM_COLLECT_LOG table */
   g_run_end_date := sysdate;
   g_status      := 'SUCCESS';
   insert_log_table;

   COMMIT;  --commit after all rows are inserted in bix_dm_agent_session_sum

EXCEPTION
   WHEN OTHERS THEN
        g_message := 'Failed while populating bix_dm_agent_session_sum : '||
				  sqlerrm;
        write_log(g_pkg_name, l_proc_name, g_message);

        g_message :='Start rolling back data in BIX_DM_AGENT_SESSION_SUM table';
        write_log(g_pkg_name, l_proc_name, g_message );

	   BEGIN
             delete_in_chunks('BIX_DM_AGENT_SESSION_SUM', 2, l_delete_count);
	        g_message := 'Finished rolling back data in BIX_DM_AGENT_SESSION_SUM table' ;
             write_log(g_pkg_name, l_proc_name, g_message );
        EXCEPTION
	       WHEN OTHERS THEN
               g_message := 'Failed to roll back data in BIX_DM_AGENT_SESSION_SUM table ';
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
PROCEDURE populate_session_sum_tables( errbuf        OUT nocopy VARCHAR2,
                                       retcode       OUT nocopy VARCHAR2,
                                       p_start_date  IN  VARCHAR2,
                                       p_end_date    IN  VARCHAR2 )
IS
  l_proc_name VARCHAR2(35) := 'POPULATE_SESSION_SUMMARY_TABLES';

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

   IF (g_collect_start_date > SYSDATE) THEN
     g_collect_start_date := SYSDATE;
   END IF;

   IF (g_collect_end_date > SYSDATE) THEN
     g_collect_end_date := SYSDATE;
   END IF;

   IF (g_collect_start_date > g_collect_end_date) THEN
     RAISE G_DATE_MISMATCH;
   END IF;

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

    /*
	*CALL the procedure to populate the session by campaign tables
    */

    g_message   := 'Calling bix_dm_sessbycamp_pkg.populate_all ';
    write_log(g_pkg_name, l_proc_name, g_message);

    g_message := '--------------------------------------------------------';
    write_log(g_pkg_name, l_proc_name, g_message);

    BIX_DM_SESSBYCAMP_PKG.populate_all(errbuf,retcode, to_char(g_collect_start_date, 'YYYY/MM/DD HH24:MI:SS') ,
							    to_char(g_collect_end_date, 'YYYY/MM/DD HH24:MI:SS') );

    g_message   := 'Returned to BIX_DM_SESSIONINFO:Completed BIX_DM_SESSBYCAMP';
    write_log(g_pkg_name, l_proc_name, g_message);

    g_message := '--------------------------------------------------------';
    write_log(g_pkg_name, l_proc_name, g_message);

EXCEPTION
   WHEN G_DATE_MISMATCH THEN
     retcode := -1;
     errbuf := 'Collect Start Date cannot be greater than collection end date';
     write_log(g_pkg_name, l_proc_name, 'Collect Start Date cannot be greater than collection end date');
   WHEN OTHERS THEN
       retcode         := sqlcode;
       errbuf          := sqlerrm;
       g_status        := 'FAILURE';
       g_error_msg     := 'Failed while executing ' || g_proc_name || ':' ||
					  sqlcode ||':'|| sqlerrm;
       g_message       :=  'ERROR : ' || sqlerrm;
       write_log(g_pkg_name, g_proc_name, g_message);

       COMMIT;
END populate_session_sum_tables;

END BIX_DM_SESSIONINFO_SUMMARY_PKG;

/
