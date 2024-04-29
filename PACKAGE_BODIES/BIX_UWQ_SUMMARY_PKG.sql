--------------------------------------------------------
--  DDL for Package Body BIX_UWQ_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_UWQ_SUMMARY_PKG" AS
/*$Header: bixxuwsb.pls 115.21 2003/08/19 21:34:18 djambula ship $ */

v_request_id          NUMBER := FND_GLOBAL.CONC_REQUEST_ID();
v_program_appl_id     NUMBER := FND_GLOBAL.PROG_APPL_ID();
v_program_id          NUMBER := FND_GLOBAL.CONC_PROGRAM_ID();
v_user_id             NUMBER := FND_GLOBAL.USER_ID();
v_insert_count        NUMBER := 0;
v_delete_count        NUMBER := 0;
v_message             VARCHAR2(4000);       --used for storing log file messages that need to be inserted
v_status              VARCHAR2(10);         --used for storing the status that needs to be inserted
v_proc_name           VARCHAR2(100);        --global variable to store the procedure being processed
v_table_name          VARCHAR2(100);        --global variable to store the table being processed
v_collect_start_date  DATE;                 --used for storing the start date parameter the user gave
v_collect_end_date    DATE;                 --used for storing the end date parameter the suer gave
v_run_start_date      DATE;                 --used for recording run statistics for each procedure
v_run_end_date        DATE;                 --used for recording run statistics for each procedure
v_sysdate             DATE := sysdate;      --used for deleting in case of errors
v_delete_size         NUMBER;               --based on profile value
g_debug_flag          VARCHAR2(1)  := 'N';

G_DATE_MISMATCH             EXCEPTION;

PROCEDURE populate_all
(
errbuf        OUT NOCOPY VARCHAR2,
retcode       OUT NOCOPY VARCHAR2,
p_start_date  IN  VARCHAR2,
p_end_date    IN  VARCHAR2
)

--
--This procedure is a "wrapper" procedure which sequentially calls two other procedures to
--populate the two tables.  First, we do a select to rab the max and min of begin_date_time
--between the date range specified by the user.  Then we loop through and populate the two tables
--for the dates between the max and min dates.
--
IS

v_min_date            DATE;
v_max_date            DATE;

BEGIN

  v_proc_name := 'POPULATE_ALL';

--
--Determine value of commit size, if profile not defined, assume 100 rows.
--

IF FND_PROFILE.DEFINED('BIX_DM_DELETE_SIZE')
THEN
   v_delete_size := TO_NUMBER(FND_PROFILE.VALUE('BIX_DM_DELETE_SIZE'));
ELSE
   v_delete_size := 100;
END IF;

IF (FND_PROFILE.DEFINED('BIX_DBI_DEBUG')) THEN
  g_debug_flag := nvl(FND_PROFILE.VALUE('BIX_DBI_DEBUG'), 'N');
END IF;

--
--Concurrent program is passing date as YYYY/MM/DD HH24:MI:SS.
--
   v_collect_start_date := to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS');
   v_collect_end_date   := to_date(p_end_date,  'YYYY/MM/DD HH24:MI:SS');

   IF (v_collect_start_date > SYSDATE) THEN
     v_collect_start_date := SYSDATE;
   END IF;

   IF (v_collect_end_date > SYSDATE) THEN
     v_collect_end_date := SYSDATE;
   END IF;

   IF (v_collect_start_date > v_collect_end_date) THEN
     RAISE G_DATE_MISMATCH;
   END IF;

--
--Select the max and min dates
--
   SELECT trunc(min(begin_date_time)), trunc(max(begin_date_time))
   INTO   v_min_date, v_max_date
   FROM   ieu_sh_sessions
   WHERE  (
		 last_update_date BETWEEN v_collect_start_date AND v_collect_end_date
		 OR ACTIVE_FLAG = 'T'
		 )
   AND    application_id = 696;


/* Even if there is no activity for specific day still record need to be inserted for each resource
   if they have logged into UWQ in the past 60 days.
   */

	 IF (v_min_date > TRUNC(v_collect_start_date) ) THEN
	     v_min_date := TRUNC(v_collect_start_date);
      END IF;


	 IF ( v_max_date < TRUNC(v_collect_end_date) ) THEN
	   v_max_date :=  TRUNC(v_collect_end_date) ;
	 END IF;

   v_message   := 'Started insert agents table on ';
   write_log(v_proc_name, v_message);


   populate_agents(v_min_date, v_max_date);

   v_message   := 'Completed insert agents table on  ';
   write_log(v_proc_name, v_message);

   v_message   := 'Started insert groups table on   ';
   write_log(v_proc_name, v_message);


   populate_groups(v_min_date, v_max_date);


   v_message   := 'Completed insert groups table on ';
   write_log(v_proc_name, v_message);

   --Success log tables were already inserted, so just commit.

   COMMIT;

EXCEPTION
   WHEN G_DATE_MISMATCH THEN
     retcode := -1;
     errbuf := 'Collect Start Date cannot be greater than collection end date';
     write_log(v_proc_name, 'Collect Start Date cannot be greater than collection end date');
WHEN OTHERS
THEN

   --
   --Exception occured: Delete all data which was inserted in this run
   --
   LOOP

	 DELETE FROM bix_dm_uwq_agent_sum
      WHERE last_update_date >= v_sysdate
	 AND rownum <= v_delete_size;

      IF SQL%ROWCOUNT >= v_delete_size   --this means we need to loop again
	 THEN
         COMMIT;
      ELSE                               --this means all rows deleted, exit loop
         COMMIT;
	    EXIT;
      END IF;

   END LOOP;

   LOOP

      DELETE FROM bix_dm_uwq_group_sum
      WHERE last_update_date >= v_sysdate
	 AND rownum <= v_delete_size;

      IF SQL%ROWCOUNT >= v_delete_size   --this means we need to loop again
	 THEN
         COMMIT;
      ELSE                               --this means all rows deleted, exit loop
         COMMIT;
	    EXIT;
      END IF;

   END LOOP;

   DELETE FROM bix_dm_collect_log
   WHERE last_update_date >= v_sysdate;

   COMMIT;

   retcode         := sqlcode;
   errbuf          := sqlerrm;
   v_status        := 'FAILURE';
   v_message       := 'Failed while executing ' || v_proc_name || ':' || sqlcode ||':'|| sqlerrm;

   write_log(v_proc_name, v_message);

   --Create error log table entry for agent summary
   v_table_name    := 'BIX_DM_UWQ_AGENT_SUM';
   v_insert_count  := 0;
   v_delete_count  := 0;
   insert_log_table;

   --Create error log table entry for group summary
   v_table_name    := 'BIX_DM_UWQ_GROUP_SUM';
   v_insert_count  := 0;
   v_delete_count  := 0;
   insert_log_table;

   COMMIT;

END populate_all;

PROCEDURE populate_agents
(
p_start_date  IN DATE,
p_end_date    IN DATE
)

--
--This procedure populates the BIX_DM_UWQ_AGENT_SUM table.
--
IS

v_insert_date             DATE;
v_week_start_date         DATE;
v_day_login               NUMBER;
v_day_duration            NUMBER;
v_prior_week_login        NUMBER;
v_prior_week_duration     NUMBER;
v_current_week_login      NUMBER;
v_current_week_duration   NUMBER;
v_prior_month_login       NUMBER;
v_prior_month_duration    NUMBER;
v_current_month_login     NUMBER;
v_current_month_duration  NUMBER;

--
--This cursor will select the resource_id, and using decode statements, calculate
--the login information for the required days.
--
CURSOR c_days(p_insert_date DATE)
IS
SELECT  ses.resource_id                                                   RESOURCE_ID,
        p_insert_date                                                     DAY,
        max(decode(trunc(begin_date_time), p_insert_date,1,0))            DAY_LOGIN,
        round((sum(decode(trunc(begin_date_time), p_insert_date,
                    (decode(end_date_time,NULL,sysdate,end_date_time)- begin_date_time)
                    ,0)))*24*3600)                                        DAY_DURATION,
        max(decode(trunc(begin_date_time), (p_insert_date-1),1,0))        DAY1_LOGIN,
        round((sum(decode(trunc(begin_date_time), trunc(p_insert_date-1),
                    (decode(end_date_time,NULL,sysdate,end_date_time)-begin_date_time)
                     ,0)))*24*3600)                                       DAY1_DURATION,
        max(decode(trunc(begin_date_time), (p_insert_date-2),1,0))        DAY2_LOGIN,
        round((sum(decode(trunc(begin_date_time), (p_insert_date-2),
                    (decode(end_date_time,NULL,sysdate,end_date_time)-begin_date_time)
                     ,0)))*24*3600)                                       DAY2_DURATION,
        max(decode(trunc(begin_date_time), (p_insert_date-3),1,0))        DAY3_LOGIN,
        round((sum(decode(trunc(begin_date_time), (p_insert_date-3),
              (decode(end_date_time,NULL,sysdate,end_date_time)-begin_date_time)
                     ,0)))*24*3600)                                       DAY3_DURATION,
        max(decode(trunc(begin_date_time), (p_insert_date-4),1,0))        DAY4_LOGIN,
        round((sum(decode(trunc(begin_date_time), (p_insert_date-4),
              (decode(end_date_time,NULL,sysdate,end_date_time)-begin_date_time)
                     ,0)))*24*3600)                                       DAY4_DURATION,
        max(decode(trunc(begin_date_time), (p_insert_date-5),1,0))        DAY5_LOGIN,
        round((sum(decode(trunc(begin_date_time), (p_insert_date-5),
              (decode(end_date_time,NULL,sysdate,end_date_time)-begin_date_time)
                     ,0)))*24*3600)                                       DAY5_DURATION,
        max(decode(trunc(begin_date_time), (p_insert_date-6),1,0))        DAY6_LOGIN,
        round((sum(decode(trunc(begin_date_time), (p_insert_date-6),
              (decode(end_date_time,NULL,sysdate,end_date_time)-begin_date_time)
                     ,0)))*24*3600)                                       DAY6_DURATION
from    ieu_sh_sessions ses
where   begin_date_time > p_insert_date-62
and     begin_date_time <  p_insert_date+1
and     application_id = 696
group by ses.resource_id, p_insert_date;

BEGIN

v_insert_date        := p_start_date;
v_insert_count       := 0;
v_delete_count       := 0;
v_proc_name          := 'POPULATE_AGENTS';
v_table_name         := 'BIX_DM_UWQ_AGENT_SUM';
v_run_start_date     := sysdate;

--
--Delete data between these dates and re-compute
--

   LOOP

      DELETE FROM bix_dm_uwq_agent_sum
      WHERE  day BETWEEN p_start_date AND p_end_date
	 AND rownum <= v_delete_size;

      IF SQL%ROWCOUNT >= v_delete_size   --this means we need to loop again
	 THEN
         COMMIT;
         v_delete_count :=  v_delete_count + sql%rowcount;
      ELSE                              --this means all rows deleted, exit loop
         COMMIT;
         v_delete_count :=  v_delete_count + sql%rowcount;
	    EXIT;
      END IF;

   END LOOP;

   v_message   := 'Deleted ' || v_delete_count ||' rows from bix_dm_uwq_agent on ';
   write_log(v_proc_name, v_message);

WHILE v_insert_date <= p_end_date
LOOP


--
--Determine the date of the Monday for the current week.
--An alternative is to use the "IW" date format, which is based on the ISO standard.
--The ISO standard is that a week is from Monday through Sunday. This is adopted here.
--

/*
SELECT NEXT_DAY(v_insert_date-7, 'MONDAY')
INTO   v_week_start_date
from dual;

*/

--
-- Using  NEXT_DAY(v_insert_date-7, 'MONDAY') causes translation issues in other languages.

SELECT TRUNC(v_insert_date,'IW')
INTO   v_week_start_date
from dual;


FOR rec_days IN c_days(v_insert_date)
LOOP


  INSERT INTO BIX_DM_UWQ_AGENT_SUM
  (
   RESOURCE_ID, DAY, DAY_LOGIN, DAY_DURATION, DAY1_LOGIN,
   DAY1_DURATION, DAY2_LOGIN, DAY2_DURATION, DAY3_LOGIN, DAY3_DURATION,
   DAY4_LOGIN, DAY4_DURATION, DAY5_LOGIN, DAY5_DURATION, DAY6_LOGIN,
   DAY6_DURATION, PRIOR_WEEK_LOGIN, PRIOR_WEEK_DURATION, CURRENT_WEEK_LOGIN,
   CURRENT_WEEK_DURATION, PRIOR_MONTH_LOGIN, PRIOR_MONTH_DURATION,
   CURRENT_MONTH_LOGIN, CURRENT_MONTH_DURATION,CREATED_BY, CREATION_DATE,
   LAST_UPDATED_BY,  LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
   REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE
  )
  VALUES
  (
  rec_days.resource_id, rec_days.day,rec_days.day_login,rec_days.day_duration,rec_days.day1_login,
  rec_days.day1_duration,rec_days.day2_login,rec_days.day2_duration,rec_days.day3_login,
  rec_days.day3_duration,rec_days.day4_login,rec_days.day4_duration,rec_days.day5_login,
  rec_days.day5_duration,rec_days.day6_login,rec_days.day6_duration,0,0,0,0,0,0,0,0,
  v_user_id, sysdate, v_user_id, sysdate, v_user_id, v_request_id, v_program_appl_id, v_program_id, sysdate
  );

v_insert_count := v_insert_count + sql%rowcount;
 commit;

--
--Prior week: If a record exists for the last day of the previous week then use that week's information
--

   BEGIN

   --
   --Select information for last week from summary table. If it doesnt exist, re-compute.
   --
   SELECT current_week_login, current_week_duration
   INTO   v_prior_week_login, v_prior_week_duration
   FROM   bix_dm_uwq_agent_sum
   WHERE  resource_id          = rec_days.resource_id
   AND    day                  = v_week_start_date-1;

   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      v_message   := 'Prior weeks info not found: Need to re-compute for ' || v_insert_date ||' on ';
      write_log(v_proc_name, v_message);

      SELECT count(*)
      INTO   v_prior_week_login
      FROM
      (
      SELECT DISTINCT resource_id, trunc(begin_date_time)
      FROM   ieu_sh_sessions
      WHERE  resource_id = rec_days.resource_id
      AND    begin_date_time BETWEEN v_week_start_date-7 AND v_week_start_date-1+.99998843
	 AND    application_id = 696
      );

      SELECT round(sum(decode(end_date_time,NULL,sysdate,end_date_time)-begin_date_time)*24*3600)
      INTO   v_prior_week_duration
      FROM   ieu_sh_sessions
      WHERE  resource_id = rec_days.resource_id
      AND    begin_date_time BETWEEN v_week_start_date-7 AND v_week_start_date-1+.99998843
	 AND    application_id = 696;

   END;

--
--Current week: Take the current days data and add to the previous values of the current week.
--This cannot be done if it is the beginning day of the week.
--

  IF v_insert_date <> v_week_start_date
  THEN

     BEGIN

     SELECT (rec_days.day_login+current_week_login), (rec_days.day_duration+current_week_duration)
     INTO   v_current_week_login, v_current_week_duration
     FROM   bix_dm_uwq_agent_sum
     WHERE  resource_id        = rec_days.resource_id
     AND    day                = trunc(rec_days.day)-1;

     EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
	--
	--This means current week information was not found in summary table.
	--Need to re-compute current week's information.
	--
        v_message   := 'Current weeks info not found: Need to re-compute for ' || v_insert_date ||' on ';
        write_log(v_proc_name, v_message);

      SELECT count(*)
      INTO   v_current_week_login
      FROM
      (
      SELECT DISTINCT resource_id, trunc(begin_date_time)
      FROM   ieu_sh_sessions
      WHERE  resource_id = rec_days.resource_id
      AND    begin_date_time BETWEEN v_week_start_date AND v_insert_date+.99998843
	 AND    application_id = 696
       );

      SELECT round(sum(decode(end_date_time,NULL,sysdate,end_date_time)-begin_date_time)*24*3600)
      INTO   v_current_week_duration
      FROM   ieu_sh_sessions
      WHERE  resource_id = rec_days.resource_id
      AND    begin_date_time BETWEEN v_week_start_date AND v_insert_date+.99998843
	 AND    application_id = 696
      ;

      END;

  ELSIF v_insert_date = v_week_start_date
  THEN

	--
	--First day of week, so just use information from cursor as we dont need to go back
	--to previous days of the week.
	--
     v_current_week_login      := rec_days.day_login;
     v_current_week_duration   := rec_days.day_duration;

  END IF;

--
--Calculate prior month information
--
   BEGIN

   --
   --If data exists for the last day of the previous month in the summary table, use that
   --
   SELECT current_month_login, current_month_duration
   INTO   v_prior_month_login, v_prior_month_duration
   FROM   bix_dm_uwq_agent_sum
   WHERE  resource_id = rec_days.resource_id
   AND    day         = last_day(add_months(v_insert_date,-1));

   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN

	 --
	 --This means last month information did not exist in the summary table.
	 --Re-compute.
	 --
      v_message   := 'Prior month info not found: Need to re-compute for ' || v_insert_date ||' on ';
      write_log(v_proc_name, v_message);

      SELECT count(*)
      INTO   v_prior_month_login
      FROM
      (
      SELECT DISTINCT resource_id, trunc(begin_date_time)
      FROM   ieu_sh_sessions
      WHERE  resource_id = rec_days.resource_id
      AND    to_char(begin_date_time,'MM/YYYY') = to_char(add_months(v_insert_date,-1), 'MM/YYYY')
	 AND    application_id = 696
       );

      SELECT round(sum(decode(end_date_time,NULL,sysdate,end_date_time)-begin_date_time)*24*3600)
      INTO   v_prior_month_duration
      FROM   ieu_sh_sessions
      WHERE  resource_id = rec_days.resource_id
      AND    to_char(begin_date_time,'MM/YYYY') = to_char(add_months(v_insert_date,-1), 'MM/YYYY')
	 AND    application_id = 696;

    END;
--
--Current month to date: Check if it is the first day of the month. If it is not, then
--add current days data to previous days information for the month. If it is the
--first day of the month, then assign the values directly.
--

IF v_insert_date <> last_day(add_months(v_insert_date,-1))+1
THEN

   BEGIN

   SELECT rec_days.day_login+current_month_login, rec_days.day_duration+current_month_duration
   INTO   v_current_month_login, v_current_month_duration
   FROM   bix_dm_uwq_agent_sum
   WHERE  resource_id = rec_days.resource_id
   AND    day         = v_insert_date-1;

   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN

	 --
	 --Current month info was not found in the summary table.
	 --Re-compute.
	 --
      v_message   := 'Current month info not found: Need to re-compute for ' || v_insert_date ||' on ';
      write_log(v_proc_name, v_message);

      SELECT count(*)
      INTO   v_current_month_login
      FROM
      (
      SELECT DISTINCT resource_id, trunc(begin_date_time)
      FROM   ieu_sh_sessions
      WHERE  resource_id = rec_days.resource_id
      AND    to_char(begin_date_time,'MM/YYYY') = to_char(v_insert_date, 'MM/YYYY')
	 AND    begin_date_time <= v_insert_date+.99998843
	 AND    application_id = 696
      )
      ;

      SELECT round(sum(decode(end_date_time,NULL,sysdate,end_date_time)-begin_date_time)*24*3600)
      INTO   v_current_month_duration
      FROM   ieu_sh_sessions
      WHERE  resource_id = rec_days.resource_id
      AND    to_char(begin_date_time,'MM/YYYY') = to_char(v_insert_date, 'MM/YYYY')
	 AND    begin_date_time <= v_insert_date+.99998843
	 AND    application_id = 696;

   END;

ELSIF v_insert_date = last_day(add_months(v_insert_date,-1))+1
THEN
   --
   --This means it is the first day of the current month
   --
   v_current_month_login    := rec_days.day_login;
   v_current_month_duration := rec_days.day_duration;

END IF;

   --
   --Update week and month information
   --

   UPDATE bix_dm_uwq_agent_sum
   SET    prior_week_login        = v_prior_week_login,
          prior_week_duration     = v_prior_week_duration,
          current_week_login      = v_current_week_login,
          current_week_duration   = v_current_week_duration,
          prior_month_login       = v_prior_month_login,
          prior_month_duration    = v_prior_month_duration,
          current_month_login     = v_current_month_login,
          current_month_duration  = v_current_month_duration,
          LAST_UPDATED_BY         = v_user_id,
          LAST_UPDATE_DATE        = sysdate,
          LAST_UPDATE_LOGIN       = v_user_id
   WHERE  resource_id             = rec_days.resource_id
   AND    day                     = rec_days.day;

   v_message   := 'Completed update of agents prior,current info for  ' || v_insert_date ||' on ';
   write_log(v_proc_name, v_message);


END LOOP;   -- for cursor


   v_message   := 'Completed loop for insert_date ' || v_insert_date ||' on ';
   write_log(v_proc_name, v_message);

   v_insert_date := v_insert_date + 1;

COMMIT;     -- commit is performed after rows are inserted for all resources for 1 day

END LOOP;   -- for date

   v_run_end_date := sysdate;
   v_status      := 'SUCCESS';
   v_message     := 'Successfully populated bix_dm_uwq_agent_sum';
   write_log(v_proc_name, v_message);
   insert_log_table;

   COMMIT;  --commit after all rows are inserted in bix_dm_uwq_agent_sum

EXCEPTION
WHEN OTHERS
THEN
   --
   --Exception occurred.
   --Raise exception and pass ccontrol to the calling procedure where we will perform the deletes.
   --
   v_status      := 'FAILURE';
   v_message     := 'Failed while populating bix_dm_uwq_agent_sum '|| sqlerrm;
   v_run_end_date := sysdate;
   write_log(v_proc_name, v_message);
   RAISE;

END populate_agents;

PROCEDURE populate_groups
(
p_start_date  IN DATE,
p_end_date    IN DATE
)

--
--This procedure populates the BIX_DM_UWQ_GROUP_SUM table.
--There is no need to go after the OLTP tables.  Instead, the
--calculations are based off the BIX_DM_UWQ_AGENT_SUM table.
--
IS

v_insert_date             DATE;
v_day_login               NUMBER;
v_day_duration            NUMBER;
v_day1_login               NUMBER;
v_day1_duration            NUMBER;
v_day2_login               NUMBER;
v_day2_duration            NUMBER;
v_day3_login               NUMBER;
v_day3_duration            NUMBER;
v_day4_login               NUMBER;
v_day4_duration            NUMBER;
v_day5_login               NUMBER;
v_day5_duration            NUMBER;
v_day6_login               NUMBER;
v_day6_duration            NUMBER;
v_prior_week_login        NUMBER;
v_prior_week_duration     NUMBER;
v_current_week_login      NUMBER;
v_current_week_duration   NUMBER;
v_prior_month_login       NUMBER;
v_prior_month_duration    NUMBER;
v_current_month_login     NUMBER;
v_current_month_duration  NUMBER;

--
--Cursor of all the groups that we need to capture in the summary table
--

CURSOR c_all_groups
IS
select DISTINCT denorm.parent_group_id group_id
from   jtf_rs_group_members mem, jtf_rs_groups_denorm denorm,
       bix_dm_uwq_agent_sum summ
where  mem.group_id             = denorm.group_id
and    summ.resource_id         = mem.resource_id;

BEGIN

v_insert_count       := 0;
v_delete_count       := 0;
v_proc_name          := 'POPULATE_GROUPS';
v_table_name         := 'BIX_DM_UWQ_GROUP_SUM';
v_run_start_date     := sysdate;

--
--Delete information for the date range and re-compute.
--
   LOOP

      DELETE FROM bix_dm_uwq_group_sum
      WHERE  day BETWEEN trunc(p_start_date) AND trunc(p_end_date)
	 AND rownum <= v_delete_size;

      IF SQL%ROWCOUNT >= v_delete_size   --this means we need to loop again
	 THEN
         COMMIT;
         v_delete_count :=  v_delete_count + sql%rowcount;
      ELSE                              --this means all rows deleted, exit loop
         COMMIT;
         v_delete_count :=  v_delete_count + sql%rowcount;
	    EXIT;
      END IF;

   END LOOP;

v_delete_count       := sql%rowcount;

FOR rec_groups IN c_all_groups
LOOP

v_insert_date        := trunc(p_start_date);

   WHILE v_insert_date <= p_end_date
   LOOP

   --
   --Insert zero rows
   --
   INSERT INTO bix_dm_uwq_group_sum
            (group_id, day,
             DAY_LOGIN, DAY_DURATION, DAY1_LOGIN,
             DAY1_DURATION, DAY2_LOGIN, DAY2_DURATION, DAY3_LOGIN, DAY3_DURATION,
             DAY4_LOGIN, DAY4_DURATION, DAY5_LOGIN, DAY5_DURATION, DAY6_LOGIN,
             DAY6_DURATION, PRIOR_WEEK_LOGIN, PRIOR_WEEK_DURATION, CURRENT_WEEK_LOGIN,
             CURRENT_WEEK_DURATION, PRIOR_MONTH_LOGIN, PRIOR_MONTH_DURATION,
             CURRENT_MONTH_LOGIN, CURRENT_MONTH_DURATION,
             CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,  LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
             REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE
             )
   VALUES    (rec_groups.group_id, trunc(v_insert_date),
              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
              v_user_id, sysdate, v_user_id, sysdate, v_user_id,
              v_request_id, v_program_appl_id, v_program_id, sysdate
             );

   COMMIT;

   v_insert_count := v_insert_count + sql%rowcount;

   --
   --Compute information using BIX_DM_UWQ_AGENT_SUM and store in variables.
   --
   SELECT sum(day_login),  sum(day_duration),  sum(day1_login), sum(day1_duration),
          sum(day2_login), sum(day2_duration), sum(day3_login), sum(day3_duration),
          sum(day4_login), sum(day4_duration), sum(day5_login), sum(day5_duration),
          sum(day6_login), sum(day6_duration),
          sum(prior_week_login),   sum(prior_week_duration),
          sum(current_week_login), sum(current_week_duration),
          sum(prior_month_login),  sum(prior_month_duration),
          sum(current_month_login), sum(current_month_duration)
   INTO   v_day_login,  v_day_duration,  v_day1_login, v_day1_duration,
          v_day2_login, v_day2_duration, v_day3_login, v_day3_duration,
          v_day4_login, v_day4_duration, v_day5_login, v_day5_duration,
          v_day6_login, v_day6_duration,
          v_prior_week_login, v_prior_week_duration,
          v_current_week_login, v_current_week_duration,
          v_prior_month_login, v_prior_month_duration,
          v_current_month_login, v_current_month_duration
   FROM   bix_dm_uwq_agent_sum agent
   WHERE  agent.resource_id IN (
                                select grp.resource_id
                                from   jtf_rs_groups_denorm denorm, jtf_rs_group_members grp
                                where  denorm.parent_group_id = rec_groups.group_id
                                and    denorm.group_id        = grp.group_id
                                )
   AND    agent.day = v_insert_date;

   --
   --Update BIX_DM_UWQ_GROUP_SUM table using the above values.
   --
   UPDATE bix_dm_uwq_group_sum
   SET    day_login              = v_day_login,
          day_duration           = v_day_duration,
          day1_login             = v_day1_login,
          day1_duration          = v_day1_duration,
          day2_login             = v_day2_login,
          day2_duration          = v_day2_duration,
          day3_login             = v_day3_login,
          day3_duration          = v_day3_duration,
          day4_login             = v_day4_login,
          day4_duration          = v_day4_duration,
          day5_login             = v_day5_login,
          day5_duration          = v_day5_duration,
          day6_login             = v_day6_login,
          day6_duration          = v_day6_duration,
          prior_week_login       = v_prior_week_login,
          prior_week_duration    = v_prior_week_duration,
          current_week_login     = v_current_week_login,
          current_week_duration  = v_current_week_duration,
          prior_month_login      = v_prior_month_login,
          prior_month_duration   = v_prior_month_duration,
          current_month_login    = v_current_month_login,
          current_month_duration = v_current_month_duration,
          LAST_UPDATED_BY        = v_user_id,
          LAST_UPDATE_DATE       = sysdate,
          LAST_UPDATE_LOGIN      = v_user_id
   WHERE  group_id               = rec_groups.group_id
   AND    day                    = v_insert_date;

   --
   --Increment the date and loop through again
   --
   v_insert_date := v_insert_date + 1;

   COMMIT;

   END LOOP;  -- date loop

END LOOP;     --groups cursor loop

   v_status      := 'SUCCESS';
   v_message     := 'Successfully populated bix_dm_uwq_group_sum';
   v_run_end_date := sysdate;
   write_log(v_proc_name, v_message);
   insert_log_table;
   COMMIT;

EXCEPTION
WHEN OTHERS
THEN

  --
  --Exception occurred.
  --Raise the exception to the calling procedure where we will perform the deletes.
  --

   v_status      := 'FAILURE';
   v_message     := 'Failed while populating bix_dm_uwq_agent_sum '|| sqlerrm;
   v_run_end_date := sysdate;
   write_log(v_proc_name, v_message);
   RAISE;

END populate_groups;

PROCEDURE write_log (p_proc_name IN VARCHAR2, p_message IN VARCHAR2)
--
--This procedure is used to write to the log file used by the concurrent program.
--
IS
BEGIN

  IF (g_debug_flag = 'Y') THEN
   FND_FILE.PUT_LINE(fnd_file.log,'BIX_UWQ_SUMMARY_PKG.' || v_proc_name || ':' || v_message || to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
  END IF;

END write_log;

PROCEDURE insert_log_table
--
--This procedure performs inserts into the BIX_DM_COLLECT_LOG table
--so that statistics about the collection run can be stored.
--
IS
BEGIN

   v_proc_name := 'insert_log_table';

   INSERT INTO BIX_DM_COLLECT_LOG
        (
        COLLECT_ID,
        COLLECT_CONCUR_ID,
        OBJECT_NAME,
        OBJECT_TYPE,
        RUN_START_DATE,
        RUN_END_DATE,
        COLLECT_START_DATE,
        COLLECT_END_DATE,
        COLLECT_STATUS,
        COLLECT_EXCEP_MESG,
        ROWS_DELETED,
        ROWS_INSERTED,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE
        )
  VALUES
        (
        BIX_DM_COLLECT_LOG_S.NEXTVAL,
        NULL,
        v_table_name,
        'TABLE',
        v_run_start_date,
        v_run_end_date,
        v_collect_start_date,
        v_collect_end_date,
        v_status,
        v_message,
        v_delete_count,
        v_insert_count,
        sysdate,
        v_user_id,
        sysdate,
        v_user_id,
        v_user_id,
        v_request_id,
        v_program_appl_id,
        v_program_id,
        sysdate
        );

EXCEPTION
WHEN OTHERS
THEN
   v_message := 'Error inserting log table on ';
   write_log(v_proc_name, v_message);
   RAISE;

END insert_log_table;

END bix_uwq_summary_pkg;

/
