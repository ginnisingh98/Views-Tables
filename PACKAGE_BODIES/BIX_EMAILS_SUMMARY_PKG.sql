--------------------------------------------------------
--  DDL for Package Body BIX_EMAILS_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_EMAILS_SUMMARY_PKG" AS
/*$Header: bixemlsb.plb 120.6 2006/08/17 08:50:08 pubalasu noship $ */

  g_request_id                  NUMBER;
  g_program_appl_id             NUMBER;
  g_program_id                  NUMBER;
  g_user_id                     NUMBER;
  g_collect_start_date          DATE;
  g_collect_end_date            DATE;
  g_no_of_jobs                  NUMBER := 0;
  g_commit_chunk_size           NUMBER;
  g_rows_ins_upd                NUMBER;
  g_sysdate                     DATE;
  g_bix_schema                  VARCHAR2(30) := 'BIX';
  g_debug_flag                  VARCHAR2(1)  := 'N';

  MAX_LOOP CONSTANT             NUMBER := 180;

  G_PARAM_MISMATCH              EXCEPTION;
  G_TIME_DIM_MISSING            EXCEPTION;
  G_CHILD_PROCESS_ISSUE         EXCEPTION;

  TYPE WorkerList is table of NUMBER index by binary_integer;
  g_worker WorkerList;

  TYPE g_media_id_tab IS TABLE OF jtf_ih_media_items.media_id%TYPE;
  TYPE g_email_account_id_tab IS TABLE OF jtf_ih_media_items.source_id%TYPE;
  TYPE g_email_classification_id_tab IS TABLE OF iem_route_classifications.route_classification_id%TYPE;
  TYPE g_resource_id_tab IS TABLE OF bix_email_details_f.agent_id%TYPE;
  TYPE g_start_date_time_tab IS TABLE OF jtf_ih_media_item_lc_segs.start_date_time%TYPE;
  TYPE g_end_date_time_tab IS TABLE OF jtf_ih_media_item_lc_segs.end_date_time%TYPE;
  TYPE g_media_start_date_time_tab IS TABLE OF jtf_ih_media_items.start_date_time%TYPE;

G_PROCESSING NUMBER;
G_REPLY NUMBER;
G_A_REPLY NUMBER;
G_FETCH NUMBER;
G_OPEN NUMBER;
G_TRANSFER NUMBER;
G_TRANSFERRED NUMBER;
G_ASSIGN_OPEN NUMBER;
G_ASSIGNED NUMBER;
G_A_ROUTED NUMBER;
G_A_UPDATED_SR NUMBER;
G_ESCALATED NUMBER;
G_DELETED NUMBER;
G_A_DELETED NUMBER;
G_A_REDIRECTED NUMBER;
G_RESOLVED NUMBER;
G_REROUTED_CLASS NUMBER;
G_REROUTED_ACCT NUMBER;
G_REQUEUED NUMBER;
G_COMPOSE NUMBER;




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

  IF (BIS_COLLECTION_UTILITIES.SETUP('BIX_EMAIL_DETAILS_F') = FALSE) THEN
    RAISE_APPLICATION_ERROR(-20000, 'BIS_COLLECTION_UTILITIES.setup has failed');
  END IF;

  write_log('Start of the procedure init at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  write_log('Initializing global variables');

  g_request_id         := FND_GLOBAL.CONC_REQUEST_ID();
  g_program_appl_id    := FND_GLOBAL.PROG_APPL_ID();
  g_program_id         := FND_GLOBAL.CONC_PROGRAM_ID();
  g_user_id            := FND_GLOBAL.USER_ID();
  g_sysdate            := SYSDATE;
  g_commit_chunk_size  := 10000;
  g_rows_ins_upd       := 0;

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

  write_log('Getting schema information');

  IF(FND_INSTALLATION.GET_APP_INFO('BIX', l_status, l_industry, g_bix_schema)) THEN
     NULL;
  END IF;

  write_log('BIX Schema : ' || g_bix_schema);
  write_log('Finished procedure init at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

 /* Truncate_Table('BIX_EMAIL_DETAILS_STG'); */

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in init : Error : ' || sqlerrm);
    RAISE;
END init;


/*

This procedure inserts  rows into BIX_WORKER_JOBS  depening on no of workers and number of days the program need
to collect data.

*/

PROCEDURE register_jobs IS

  l_start_date_range DATE;
  l_end_date_range   DATE;
  l_count            NUMBER := 0;

BEGIN
  write_log('Start of the procedure register_jobs at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* No of jobs to be submitted = Number of 4 hours buckets for which we need to collect data */
  SELECT ceil(g_collect_end_date - g_collect_start_date)
  INTO   l_count
  FROM   dual;

  g_no_of_jobs := l_count;

  write_log('Number of workers that need to be instantiated : ' || to_char(l_count));

  Delete BIX_WORKER_JOBS WHERE OBJECT_NAME = 'BIX_EMAIL_DETAILS_F';

  IF (l_count > 0) THEN
    l_start_date_range := g_collect_start_date;

    /* Register a job for each day of the collection date range */
    FOR i IN 1..l_count
    LOOP
      IF (l_start_date_range > g_collect_end_date) THEN
        EXIT;
      END IF;

      /* End date range is l_start_date_range + (4 hours - 1sec) */
      l_end_date_range := trunc(l_start_date_range) + 86399/86400;

      IF (l_end_date_range > g_collect_end_date) THEN
        l_end_date_range := g_collect_end_date;
      END IF;

      INSERT INTO BIX_WORKER_JOBS(OBJECT_NAME
                                , START_DATE_RANGE
                                , END_DATE_RANGE
                                , WORKER_NUMBER
                                , STATUS)
                            VALUES (
                                 'BIX_EMAIL_DETAILS_F'
                                , l_start_date_range
                                , l_end_date_range
                                , l_count
                                , 'UNASSIGNED');

      l_start_date_range := l_end_date_range + 1/86400;
    END LOOP;
  END IF;

  COMMIT;

  write_log('Finished procedure register_jobs at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in register_jobs : Error : ' || sqlerrm);
    RAISE;
END REGISTER_JOBS;

/*

This function launches  concurrent request which is child job  collects data for one day.
*/

FUNCTION launch_worker(p_worker_no in NUMBER) RETURN NUMBER IS

  l_request_id NUMBER;

BEGIN

  write_log('Start of the procedure launch_worker at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* Submit the parallel concurrent request */
  l_request_id := FND_REQUEST.SUBMIT_REQUEST('BIX',
                                             'BIX_EMAIL_SUMMARY_SUBWORKER',
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

PROCEDURE get_curr_prev_depth(p_interaction_id IN NUMBER,
                              p_curr_depth OUT NOCOPY NUMBER,
                              p_prev_depth OUT NOCOPY NUMBER,
                              p_intr_thread OUT NOCOPY NUMBER)
IS
p_parent_depth integer;
BEGIN

  write_log('Start of the procedure get_curr_prev_depth at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* Get the depth of the interaction that is present in ICI summary table */
  BEGIN

    --
    --If an entry is not there in this table then it means
    --the interaction has not been collected yet - hence, the number
    --of interaction thread can be hardcode to 1 since the query is based on
    --the root interaction_id.
    --If an entry is found in this table then the number of interaction threads
    --is set to zero - because it means the data was already collected and
    --the root interaction count for this root interaction has already been accounted for.
    --
    SELECT depth
    INTO   p_prev_depth
    FROM   bix_interactions_temp
    WHERE  interaction_id = p_interaction_id
    FOR UPDATE OF depth;

   p_intr_thread := 0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      write_log('No Data found. Defaulting prev and curr depth');
	 p_prev_depth := 0;
      p_intr_thread := 1;
    WHEN OTHERS THEN
      RAISE;
  END;

  write_log('The previous depth of the interaction : ' || to_char(p_interaction_id) || ' is ' || to_char(p_prev_depth));

  BEGIN
    /* Get the current depth of the interaction                            */
    /* if the interaction is a new one with no child , then the depth is 1 */
    SELECT /*+ ordered */
      1
    INTO   p_curr_depth
    FROM jtf_ih_activities actv,
         jtf_ih_media_items imtm,
         jtf_ih_media_item_lc_segs mseg,
         jtf_ih_media_itm_lc_seg_tys mtys
    WHERE actv.interaction_id = p_interaction_id
    AND   imtm.media_id = actv.media_id
    AND   mseg.media_id = imtm.media_id
    AND   mtys.milcs_type_id = mseg.milcs_type_id
    AND   mtys.milcs_code IN ('EMAIL_REPLY','EMAIL_AUTO_REPLY')
    AND   NOT EXISTS (
            SELECT 1
            FROM   jtf_ih_interaction_inters inter
            WHERE  inter.interact_interaction_idrelates = actv.interaction_id )
    AND   rownum <= 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      BEGIN
        /* Else get the depth from the table where the thread is maintained */

		 SELECT
		 --nvl(max(decode(milcs_code,'EMAIL_REPLY',depth,'EMAIL_AUTO_REPLY',depth,0)),0) depth
		 count(distinct media_id) depth
		 into p_curr_depth
		 FROM
		 (
		  SELECT inv2.interaction_id,
          mseg.media_id media_id,
		  --first_Value(milcs_code) over (partition by mseg.media_id order by mseg.start_Date_time desc) milcs_code,
           depth
           FROM
           (SELECT
                interact_interaction_id interaction_id /* Child interaction*/,
                level depth
              FROM
                jtf_ih_interaction_inters
              START WITH interact_interaction_idrelates = p_interaction_id
              CONNECT BY interact_interaction_idrelates = PRIOR interact_interaction_id
              ORDER BY creation_date DESC) inv2,      jtf_ih_activities actv,
             jtf_ih_media_items mitm,
             jtf_ih_media_item_lc_segs mseg,
             jtf_ih_media_itm_lc_seg_tys mtys
           WHERE actv.interaction_id = inv2.interaction_id
           AND   mitm.media_id = actv.media_id
           AND   mitm.media_id = mseg.media_id
           AND   mseg.milcs_type_id = mtys.milcs_type_id
           AND 	 mitm.direction='INBOUND' and mitm.media_item_type='EMAIL'
		   AND   milcs_code in ('EMAIL_REPLY','EMAIL_AUTO_REPLY')
		);
		/* Check the parent..if it has reply/auto reply , increment the current depth by 1 */
         p_parent_depth:=0;
			 BEGIN
				  SELECT /*+ ordered */
					  1
					INTO   p_parent_depth
					FROM jtf_ih_activities actv,
						 jtf_ih_media_items imtm,
						 jtf_ih_media_item_lc_segs mseg,
						 jtf_ih_media_itm_lc_seg_tys mtys
					WHERE actv.interaction_id = p_interaction_id
					AND   imtm.media_id = actv.media_id
					AND   mseg.media_id = imtm.media_id
					AND   mtys.milcs_type_id = mseg.milcs_type_id
					AND   mtys.milcs_code IN ('EMAIL_REPLY','EMAIL_AUTO_REPLY')
					AND   rownum <= 1;
			  EXCEPTION
			  WHEN NO_DATA_FOUND THEN
			  /* parent interaction does not have reply or auto reply and  so...make parent depth as 0 */
			   p_parent_depth:=0;
			  END;
         p_curr_depth:=p_curr_depth+p_parent_depth;


      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_curr_depth := 0;
		WHEN OTHERS THEN
          RAISE;
      END;
    WHEN OTHERS THEN
      RAISE;
  END;

  write_log('The current depth of the interaction : ' || to_char(p_interaction_id) || ' is ' || to_char(p_curr_depth));
  write_log('Finished procedure get_curr_prev_depth at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure get_curr_prev_depth : Error : ' || sqlerrm);
    RAISE;
END get_curr_prev_depth;


/* This procedure collects One, two , three and Four done resolutiions.  Email center keeps the threads of email
interactions in jtf_ih_interaction_inters table. If the customer reply back to the agent response then the entry will
be created in the above table with old and new interaction.   This table stores both parent and child interaction id.

We can find the depth of thread from this table.  If the table does not have entry in this
table for replied email, then the email interaction is one and done ,
if the depth is 1 then it is two and done and so on.

First the root interaction_id values and the depths are stored.
Using these, the corresponding dimensions are figured out. For these dimensions,
the time_ids are found out and updated using a sinle MERGE. We do not use a ROLLUP here.

*/

PROCEDURE collect_resolutions IS

  CURSOR all_root_interactions IS
  SELECT DISTINCT interaction_id from
  (
  SELECT
    incr.interaction_id
  FROM    jtf_ih_interactions incr,
          jtf_ih_activities   actv,
          jtf_ih_media_items  imtm
  WHERE incr.start_date_time between g_collect_start_date and g_collect_end_date
  AND   actv.interaction_id = incr.interaction_id
  AND   imtm.media_id = actv.media_id
  AND   imtm.media_item_type = 'EMAIL'
  AND   imtm.direction = 'INBOUND'
  AND   NOT EXISTS (
    SELECT 1
    FROM   jtf_ih_interaction_inters inter
    WHERE
           --?????? comment out???
           inter.INTERACT_INTERACTION_IDRELATES = incr.interaction_id
           OR
            inter.interact_interaction_id = incr.interaction_id
                    )
  AND NOT EXISTS (
    SELECT 1
    FROM   jtf_ih_media_item_lc_segs mseg1,
           jtf_ih_media_itm_lc_seg_tys mtys1
    WHERE mseg1.media_id = imtm.media_id
    AND   mseg1.milcs_type_id = mtys1.milcs_type_id
    AND   mtys1.milcs_code IN ( 'EMAIL_REPLY','EMAIL_AUTO_REPLY') )
  UNION ALL
  SELECT
    incr.interaction_id
  FROM   jtf_ih_interactions          incr,
         jtf_ih_activities            actv,
         jtf_ih_media_items           imtm,
         jtf_ih_media_item_lc_segs    mseg,
         jtf_ih_media_itm_lc_seg_tys  mtys
  WHERE actv.interaction_id = incr.interaction_id
  AND   imtm.media_id = actv.media_id
  AND   imtm.media_item_type = 'EMAIL'
  AND   imtm.direction = 'INBOUND'
  AND   mseg.media_id = imtm.media_id
  AND   mtys.milcs_type_id = mseg.milcs_type_id
  AND   mtys.milcs_code IN ( 'EMAIL_REPLY','EMAIL_AUTO_REPLY')
  AND   mseg.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
  AND   NOT EXISTS (
    SELECT 1
    FROM   jtf_ih_interaction_inters inter
    WHERE  inter.INTERACT_INTERACTION_IDRELATES = incr.interaction_id
    OR     inter.interact_interaction_id = incr.interaction_id)
  UNION ALL
  SELECT interact_interaction_idrelates
  FROM (
    SELECT interact_interaction_idrelates
    FROM   jtf_ih_interaction_inters
    START WITH interact_interaction_id IN
                        (SELECT
                           intr.interact_interaction_id
                         FROM    jtf_ih_interaction_inters intr,
                                 jtf_ih_activities actv,
                                 jtf_ih_media_items imtm
                         WHERE intr.creation_date between g_collect_start_date and g_collect_end_date
                         AND   actv.interaction_id = intr.interact_interaction_id
                         AND   imtm.media_id = actv.media_id
                         AND   imtm.media_item_type = 'EMAIL'
                         AND   imtm.direction = 'INBOUND'
                         AND   NOT EXISTS (
                           SELECT 1
                           FROM   jtf_ih_interaction_inters inter
                           WHERE  inter.INTERACT_INTERACTION_IDRELATES = intr.interact_interaction_id)
                         UNION
                         SELECT
                           intr.interact_interaction_id
                         FROM   jtf_ih_interaction_inters    intr,
                                jtf_ih_activities            actv,
                                jtf_ih_media_items           imtm,
                                jtf_ih_media_item_lc_segs    mseg,
                                jtf_ih_media_itm_lc_seg_tys  mtys
                         WHERE actv.interaction_id = intr.interact_interaction_id
                         AND   imtm.media_id = actv.media_id
                         AND   mseg.media_id = imtm.media_id
                         AND   mtys.milcs_type_id = mseg.milcs_type_id
                         AND   mtys.milcs_code IN ( 'EMAIL_REPLY','EMAIL_AUTO_REPLY')
                         AND   mseg.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
                         AND   NOT EXISTS (
                           SELECT 1
                           FROM   jtf_ih_interaction_inters inter
                           WHERE  inter.INTERACT_INTERACTION_IDRELATES = intr.interact_interaction_id))
    CONNECT BY PRIOR interact_interaction_idrelates = interact_interaction_id ) inv2
  WHERE NOT EXISTS (
    SELECT 1 FROM jtf_ih_interaction_inters intr
    WHERE intr.interact_interaction_id = inv2.interact_interaction_idrelates)
  AND EXISTS (
    SELECT 1
    FROM   jtf_ih_activities actv,
           jtf_ih_media_items imtm
    WHERE  actv.interaction_id = inv2.interact_interaction_idrelates
    AND    actv.media_id = imtm.media_id
    AND   imtm.media_item_type = 'EMAIL'
    AND   imtm.direction = 'INBOUND')
    )
    ;

  TYPE root_interaction_id_tab IS TABLE OF jtf_ih_interactions.interaction_id%TYPE;
  TYPE agent_id_tab IS TABLE OF jtf_ih_interactions.resource_id%TYPE;
  TYPE party_id_tab IS TABLE OF jtf_ih_interactions.party_id%TYPE;
  TYPE start_date_time_tab IS TABLE OF jtf_ih_interactions.start_date_time%TYPE;
  TYPE source_id_tab IS TABLE OF jtf_ih_media_items.source_id%TYPE;
  TYPE route_classification_id_tab IS TABLE OF iem_route_classifications.route_classification_id%TYPE;
  TYPE one_done_rsln_tab IS TABLE OF bix_email_details_f.one_rsln_in_period%TYPE;
  TYPE two_done_rsln_tab IS TABLE OF bix_email_details_f.two_rsln_in_period%TYPE;
  TYPE three_done_rsln_tab IS TABLE OF bix_email_details_f.three_rsln_in_period%TYPE;
  TYPE four_done_rsln_tab IS TABLE OF bix_email_details_f.four_rsln_in_period%TYPE;
  TYPE intr_thread_tab IS TABLE OF bix_email_details_f.interaction_threads_in_period%TYPE;
  TYPE week_id_tab IS TABLE OF fii_time_day.week_id%TYPE;
  TYPE ent_period_id_tab IS TABLE OF fii_time_day.ent_period_id%TYPE;
  TYPE ent_qtr_id_tab IS TABLE OF fii_time_day.ent_qtr_id%TYPE;
  TYPE ent_year_id_tab IS TABLE OF fii_time_day.ent_year_id%TYPE;
  TYPE week_start_date_tab IS TABLE OF fii_time_day.week_start_date%TYPE;
  TYPE ent_period_start_date_tab IS TABLE OF fii_time_day.ent_period_start_date%TYPE;
  TYPE ent_qtr_start_date_tab IS TABLE OF fii_time_day.ent_qtr_start_date%TYPE;
  TYPE ent_year_start_date_tab IS TABLE OF fii_time_day.ent_year_start_date%TYPE;
  TYPE curr_depth_tab IS TABLE OF bix_email_details_f.one_rsln_in_period%TYPE;

  l_root_interaction_id root_interaction_id_tab;
  l_agent_id agent_id_tab;
  l_party_id party_id_tab;
  l_start_date_time start_date_time_tab;
  l_email_account_id source_id_tab;
  l_classification_id route_classification_id_tab;
  l_one_done_rsln one_done_rsln_tab;
  l_two_done_rsln two_done_rsln_tab;
  l_three_done_rsln three_done_rsln_tab;
  l_four_done_rsln four_done_rsln_tab;
  l_intr_thread intr_thread_tab;
  l_week_id week_id_tab;
  l_ent_period_id ent_period_id_tab;
  l_ent_qtr_id ent_qtr_id_tab;
  l_ent_year_id ent_year_id_tab;
  l_week_start_date week_start_date_tab;
  l_ent_period_start_date ent_period_start_date_tab;
  l_ent_qtr_start_date ent_qtr_start_date_tab;
  l_ent_year_start_date ent_year_start_date_tab;
  l_curr_depth curr_depth_tab;

  l_prev_depth NUMBER;
  l_no_of_records NUMBER;
  l_ond_day NUMBER;
BEGIN

  write_log('Start of the procedure collect_resolutions at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* Initialize the variables */
  l_agent_id := agent_id_tab();
  l_party_id := party_id_tab();
  l_start_date_time := start_date_time_tab();
  l_email_account_id := source_id_tab();
  l_classification_id := route_classification_id_tab();
  l_one_done_rsln := one_done_rsln_tab();
  l_two_done_rsln := two_done_rsln_tab();
  l_three_done_rsln := three_done_rsln_tab();
  l_four_done_rsln := four_done_rsln_tab();
  l_intr_thread := intr_thread_tab();
  l_week_id := week_id_tab();
  l_ent_period_id := ent_period_id_tab();
  l_ent_qtr_id := ent_qtr_id_tab();
  l_ent_year_id := ent_year_id_tab();
  l_week_start_date := week_start_date_tab();
  l_ent_period_start_date := ent_period_start_date_tab();
  l_ent_qtr_start_date := ent_qtr_start_date_tab();
  l_ent_year_start_date := ent_year_start_date_tab();
  l_curr_depth := curr_depth_tab();

  OPEN all_root_interactions;

  LOOP

    /* fetch all leaf interactions that have been created in the collection date range */
    /* or a reply has been given within the collection date range for the interaction  */
    FETCH all_root_interactions BULK COLLECT INTO
      l_root_interaction_id
    LIMIT g_commit_chunk_size;

    IF (l_root_interaction_id.COUNT > 0) THEN

      l_no_of_records := l_root_interaction_id.COUNT;

      /* Make place for all the interactions */
      l_agent_id.EXTEND(l_no_of_records);
      l_party_id.EXTEND(l_no_of_records);
      l_start_date_time.EXTEND(l_no_of_records);
      l_email_account_id.EXTEND(l_no_of_records);
      l_classification_id.EXTEND(l_no_of_records);
      l_one_done_rsln.EXTEND(l_no_of_records);
      l_two_done_rsln.EXTEND(l_no_of_records);
      l_three_done_rsln.EXTEND(l_no_of_records);
      l_four_done_rsln.EXTEND(l_no_of_records);
      l_intr_thread.EXTEND(l_no_of_records);
      l_week_id.EXTEND(l_no_of_records);
      l_ent_period_id.EXTEND(l_no_of_records);
      l_ent_qtr_id.EXTEND(l_no_of_records);
      l_ent_year_id.EXTEND(l_no_of_records);
      l_week_start_date.EXTEND(l_no_of_records);
      l_ent_period_start_date.EXTEND(l_no_of_records);
      l_ent_qtr_start_date.EXTEND(l_no_of_records);
      l_ent_year_start_date.EXTEND(l_no_of_records);
      l_curr_depth.EXTEND(l_no_of_records);

      FOR i IN l_root_interaction_id.FIRST .. l_root_interaction_id.LAST
      LOOP
        /* For each interaction , get the associated dimensions */
        SELECT
          nvl(intr.resource_id, -1),
          nvl(intr.party_id, -1),
          trunc(intr.start_date_time),
          nvl(mitm.source_id, -1),
          nvl(irc.route_classification_id, -1)
        INTO
          l_agent_id(i),
          l_party_id(i),
          l_start_date_time(i),
          l_email_account_id(i),
          l_classification_id(i)
        FROM
           jtf_ih_interactions intr,
           jtf_ih_activities actv,
           jtf_ih_media_items mitm,
    --
    --Changes for R12
    --
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) irc
        WHERE intr.interaction_id = l_root_interaction_id(i)
        AND actv.interaction_id = intr.interaction_id
        AND mitm.media_id = actv.media_id
        AND mitm.direction = 'INBOUND'
        AND mitm.media_item_type = 'EMAIL'
        AND mitm.classification = irc.name(+)
        AND rownum <= 1;

        l_one_done_rsln(i) := 0;
        l_two_done_rsln(i) := 0;
        l_three_done_rsln(i) := 0;
        l_four_done_rsln(i) := 0;
        l_intr_thread(i) := 0;

        /* Get the current and previous depth of the root interaction */
        get_curr_prev_depth(l_root_interaction_id(i), l_curr_depth(i), l_prev_depth, l_intr_thread(i));


        /* Get the time ids from time diemnsion corresponding to interaction start date time */
        SELECT
          week_id,
          week_start_date,
          ent_period_id,
          ent_period_start_date,
          ent_qtr_id,
          ent_qtr_start_date,
          ent_year_id,
          ent_year_start_date
        INTO
          l_week_id(i),
          l_week_start_date(i),
          l_ent_period_id(i),
          l_ent_period_start_date(i),
          l_ent_qtr_id(i),
          l_ent_qtr_start_date(i),
          l_ent_year_id(i),
          l_ent_year_start_date(i)
        FROM
          fii_time_day
        WHERE report_date = trunc(l_start_date_time(i));


        IF (l_curr_depth(i) = 1) THEN l_one_done_rsln(i) :=1;
        ELSIF (l_curr_depth(i) = 2) THEN l_two_done_rsln(i) := 1;
        ELSIF (l_curr_depth(i) = 3) THEN l_three_done_rsln(i) := 1;
        ELSIF (l_curr_depth(i) = 4) THEN l_four_done_rsln(i) := 1;
        END IF;

	IF (l_prev_depth = 1)     THEN l_one_done_rsln(i) := l_one_done_rsln(i) - 1;
        ELSIF (l_prev_depth = 2)  THEN l_two_done_rsln(i) := l_two_done_rsln(i) - 1;
        ELSIF (l_prev_depth = 3)  THEN l_three_done_rsln(i) := l_three_done_rsln(i) - 1;
        ELSIF (l_prev_depth = 4)  THEN l_four_done_rsln(i) := l_four_done_rsln(i) - 1;
        END IF;



        write_log('For this interaction one and done is'||to_char(l_one_done_rsln(i)));
--
--??Need to review this section of code to make sure for deletes
--If curr_depth = priro_depth which might happen if data is being re-collected then do not
--subtract the prior depth
/***************
        IF (l_prev_depth = 1)    AND l_curr_depth(i) <> 1 THEN l_one_done_rsln(i) := l_one_done_rsln(i) - 1;
        ELSIF (l_prev_depth = 2) AND l_curr_depth(i) <> 2 THEN l_two_done_rsln(i) := l_two_done_rsln(i) - 1;
        ELSIF (l_prev_depth = 3) AND l_curr_depth(i) <> 3 THEN l_three_done_rsln(i) := l_three_done_rsln(i) - 1;
        ELSIF (l_prev_depth = 4) AND l_curr_depth(i) <> 4 THEN l_four_done_rsln(i) := l_four_done_rsln(i) - 1;
        END IF;
****************/

      END LOOP;

      /* Update the half-hour, day, week, month, quarter and year rows of ICI summary table */
      /*
	 For period type id =1 (day level), we delete the records before arriving at this procedure,
	 so one and done becomes 0.. */

	 FORALL i IN l_root_interaction_id.FIRST .. l_root_interaction_id.LAST

	MERGE INTO bix_email_details_f bed
	 USING (
  		  SELECT
		   l_agent_id(i) agent_id
		  ,l_email_account_id(i) email_account_id
		  ,l_classification_id(i) email_classification_id
		  ,l_party_id(i) party_id
		  ,to_number(to_char(l_start_date_time(i), 'J')) time_id
		  ,1  period_type_id
		  ,trunc(l_start_date_time(i)) period_start_date
		  ,'00:00' period_start_time
            ,l_one_done_rsln(i) one_rsln_in_period
		  ,l_two_done_rsln(i) two_rsln_in_period
		  ,l_three_done_rsln(i) three_rsln_in_period
		  ,l_four_done_rsln(i) four_rsln_in_period
		  ,l_intr_thread(i) interaction_threads_in_period
	     FROM DUAL
		UNION ALL
		SELECT
		   l_agent_id(i) agent_id
		  ,l_email_account_id(i) email_account_id
		  ,l_classification_id(i) email_classification_id
		  ,l_party_id(i) party_id
		  ,l_week_id(i) time_id
		  ,16  period_type_id
		  ,l_week_start_date(i) period_start_date
		  ,'00:00' period_start_time
            ,l_one_done_rsln(i) one_rsln_in_period
		  ,l_two_done_rsln(i) two_rsln_in_period
		  ,l_three_done_rsln(i) three_rsln_in_period
		  ,l_four_done_rsln(i) four_rsln_in_period
		  ,l_intr_thread(i) interaction_threads_in_period
	     FROM DUAL
		UNION ALL
		SELECT
		   l_agent_id(i) agent_id
		  ,l_email_account_id(i) email_account_id
		  ,l_classification_id(i) email_classification_id
		  ,l_party_id(i) party_id
		  ,l_ent_period_id(i) time_id
		  ,32  period_type_id
		  ,l_ent_period_start_date(i) period_start_date
		  ,'00:00' period_start_time
            ,l_one_done_rsln(i) one_rsln_in_period
		  ,l_two_done_rsln(i) two_rsln_in_period
		  ,l_three_done_rsln(i) three_rsln_in_period
		  ,l_four_done_rsln(i) four_rsln_in_period
		  ,l_intr_thread(i) interaction_threads_in_period
	     FROM DUAL
		UNION ALL
		SELECT
		   l_agent_id(i) agent_id
		  ,l_email_account_id(i) email_account_id
		  ,l_classification_id(i) email_classification_id
		  ,l_party_id(i) party_id
		  ,l_ent_qtr_id(i) time_id
		  ,64  period_type_id
		  ,l_ent_qtr_start_date(i) period_start_date
		  ,'00:00' period_start_time
            ,l_one_done_rsln(i) one_rsln_in_period
		  ,l_two_done_rsln(i) two_rsln_in_period
		  ,l_three_done_rsln(i) three_rsln_in_period
		  ,l_four_done_rsln(i) four_rsln_in_period
		  ,l_intr_thread(i) interaction_threads_in_period
	     FROM DUAL
		UNION ALL
		SELECT
		   l_agent_id(i) agent_id
		  ,l_email_account_id(i) email_account_id
		  ,l_classification_id(i) email_classification_id
		  ,l_party_id(i) party_id
		  ,l_ent_year_id(i) time_id
		  ,128  period_type_id
		  ,l_ent_year_start_date(i) period_start_date
		  ,'00:00' period_start_time
            ,l_one_done_rsln(i) one_rsln_in_period
		  ,l_two_done_rsln(i) two_rsln_in_period
		  ,l_three_done_rsln(i) three_rsln_in_period
		  ,l_four_done_rsln(i) four_rsln_in_period
		  ,l_intr_thread(i) interaction_threads_in_period
	     FROM DUAL) change
      ON (
         bed.agent_id = change.agent_id
         AND bed.party_id = change.party_id
         AND bed.email_account_id = change.email_account_id
         AND bed.email_classification_id = change.email_classification_id
         AND bed.time_id = change.time_id
         AND bed.period_start_time = change.period_start_time
         AND bed.period_start_date = change.period_start_date
         AND bed.period_type_id = change.period_type_id
         AND bed.outcome_id = -1 AND bed.result_id = -1 AND bed.reason_id = -1
         )
	 WHEN MATCHED THEN
      UPDATE
      SET    bed.one_rsln_in_period = decode(change.one_rsln_in_period, 0, bed.one_rsln_in_period,
                                     decode(nvl(bed.one_rsln_in_period, 0) + change.one_rsln_in_period, 0, to_number(null),
                                        nvl(bed.one_rsln_in_period, 0) + change.one_rsln_in_period))
             ,bed.two_rsln_in_period = decode(change.two_rsln_in_period, 0, bed.two_rsln_in_period,
                                     decode(nvl(bed.two_rsln_in_period, 0) + change.two_rsln_in_period, 0, to_number(null),
                                        nvl(bed.two_rsln_in_period, 0) + change.two_rsln_in_period))
             ,bed.three_rsln_in_period = decode(change.three_rsln_in_period, 0, bed.three_rsln_in_period,
                                     decode(nvl(bed.three_rsln_in_period, 0) + change.three_rsln_in_period, 0, to_number(null),
                                        nvl(bed.three_rsln_in_period, 0) + change.three_rsln_in_period))
             ,bed.four_rsln_in_period = decode(change.four_rsln_in_period, 0, bed.four_rsln_in_period,
                                     decode(nvl(bed.four_rsln_in_period, 0) + change.four_rsln_in_period, 0, to_number(null),
                                        nvl(bed.four_rsln_in_period, 0) + change.four_rsln_in_period))
             ,bed.interaction_threads_in_period = decode(change.interaction_threads_in_period, 0,
		                        bed.interaction_threads_in_period, decode(nvl(bed.interaction_threads_in_period, 0)
						    + change.interaction_threads_in_period, 0, to_number(null),
                                  nvl(bed.interaction_threads_in_period, 0) + change.interaction_threads_in_period))
             ,bed.last_updated_by = g_user_id
             ,bed.last_update_date = g_sysdate
	 WHEN NOT MATCHED THEN INSERT (
	        bed.agent_id
		   ,bed.party_id
		   ,bed.email_account_id
		   ,bed.email_classification_id
		   ,bed.time_id
		   ,bed.period_start_time
		   ,bed.period_start_date
		   ,bed.period_type_id
		   ,outcome_id
               ,result_id
               ,reason_id
		   ,bed.created_by
		   ,bed.creation_date
		   ,bed.last_updated_by
		   ,bed.last_update_date
		   ,bed.one_rsln_in_period
		   ,bed.two_rsln_in_period
		   ,bed.three_rsln_in_period
		   ,bed.four_rsln_in_period
		   ,bed.interaction_threads_in_period )
	 VALUES (
	        change.agent_id
		   ,change.party_id
		   ,change.email_account_id
		   ,change.email_classification_id
		   ,change.time_id
		   ,change.period_start_time
		   ,change.period_start_date
		   ,change.period_type_id
               ,-1
               ,-1
               ,-1
             ,g_user_id
             ,g_sysdate
             ,g_user_id
             ,g_sysdate
		   ,decode(change.one_rsln_in_period, 0, to_number(null), change.one_rsln_in_period)
		   ,decode(change.two_rsln_in_period, 0, to_number(null), change.two_rsln_in_period)
		   ,decode(change.three_rsln_in_period, 0, to_number(null), change.three_rsln_in_period)
		   ,decode(change.four_rsln_in_period, 0, to_number(null), change.four_rsln_in_period)
		   ,decode(change.interaction_threads_in_period, 0, to_number(null), change.interaction_threads_in_period));


      write_log('Total rows inserted/updated in bix_email_details_f for resolution : ' ||
      to_char(l_root_interaction_id.COUNT * 6));
      g_rows_ins_upd := g_rows_ins_upd + (l_root_interaction_id.COUNT * 6);

      /* Update the bix_interactions_temp table to keep track of depth by interaction */
      /* This table has an instead of insert trigger which updates/insert the row     */
      FORALL i IN l_root_interaction_id.FIRST .. l_root_interaction_id.LAST
        MERGE INTO bix_interactions_temp bit
        USING (
          SELECT
            l_root_interaction_id(i) interaction_id,
            l_curr_depth(i) depth
          FROM dual ) change
        ON (bit.interaction_id = change.interaction_id)
        WHEN MATCHED THEN
        UPDATE
          SET  bit.depth = change.depth,
               bit.last_updated_by = g_user_id,
               bit.last_update_date = g_sysdate
        WHEN NOT MATCHED THEN
        INSERT (
          bit.interaction_id,
          bit.created_by,
          bit.creation_date,
          bit.last_updated_by,
          bit.last_update_date,
          bit.depth,
          bit.request_id,
          bit.program_application_id,
          bit.program_id,
          bit.program_update_date )
        VALUES (
          l_root_interaction_id(i),
          g_user_id,
          g_sysdate,
          g_user_id,
          g_sysdate,
          l_curr_depth(i),
          g_request_id,
          g_program_appl_id,
          g_program_id,
          g_sysdate);

      write_log('Total rows inserted/updated in bix_interactions_temp : ' || to_char(l_root_interaction_id.COUNT));
      g_rows_ins_upd := g_rows_ins_upd + l_root_interaction_id.COUNT;

      l_agent_id.TRIM(l_no_of_records);
      l_party_id.TRIM(l_no_of_records);
      l_start_date_time.TRIM(l_no_of_records);
      l_email_account_id.TRIM(l_no_of_records);
      l_classification_id.TRIM(l_no_of_records);
      l_one_done_rsln.TRIM(l_no_of_records);
      l_two_done_rsln.TRIM(l_no_of_records);
      l_three_done_rsln.TRIM(l_no_of_records);
      l_four_done_rsln.TRIM(l_no_of_records);
      l_intr_thread.TRIM(l_no_of_records);
      l_week_id.TRIM(l_no_of_records);
      l_ent_period_id.TRIM(l_no_of_records);
      l_ent_qtr_id.TRIM(l_no_of_records);
      l_ent_year_id.TRIM(l_no_of_records);
      l_week_start_date.TRIM(l_no_of_records);
      l_ent_period_start_date.TRIM(l_no_of_records);
      l_ent_qtr_start_date.TRIM(l_no_of_records);
      l_ent_year_start_date.TRIM(l_no_of_records);
      l_curr_depth.TRIM(l_no_of_records);

      COMMIT;
    END IF;

    EXIT WHEN all_root_interactions%NOTFOUND;

  END LOOP;

  CLOSE all_root_interactions;

  write_log('Finished procedure collect_resolutions at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure collect_resolutions : Error : ' || sqlerrm);
    IF (all_root_interactions%ISOPEN) THEN
      CLOSE all_root_interactions;
    END IF;
    RAISE;
END collect_resolutions;

PROCEDURE clean_up IS

  l_total_rows_deleted NUMBER := 0;
  l_rows_deleted       NUMBER := 0;

BEGIN
  write_log('Start of the procedure clean_up at ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));

  /* rollback the uncommited changes */
  rollback;

  l_total_rows_deleted := 0;

  write_log('Deleting data from summary tables inserted from parallel workers');
  /* Delete all the rows inserted from subworkers */
  IF (g_worker.COUNT > 0) THEN
    FOR i IN g_worker.FIRST .. g_worker.LAST
    LOOP
      LOOP
        DELETE bix_email_details_f
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

  /* Delete the rows from eMail summary table inserted in the current run */
  write_log('Deleting data from summary tables inserted through this main program');
  LOOP
    DELETE bix_email_details_f
    WHERE  request_id = g_request_id
    AND    rownum <= g_commit_chunk_size ;

    l_rows_deleted := SQL%ROWCOUNT;
    l_total_rows_deleted := l_total_rows_deleted + l_rows_deleted;

    COMMIT;

    IF (l_rows_deleted < g_commit_chunk_size) THEN
      EXIT;
    END IF;
  END LOOP;

  write_log('Deleting data from bix_interactions_temp');
  LOOP
    DELETE bix_interactions_temp
    WHERE  request_id = g_request_id
    AND    rownum <= g_commit_chunk_size ;

    l_rows_deleted := SQL%ROWCOUNT;
    l_total_rows_deleted := l_total_rows_deleted + l_rows_deleted;

    COMMIT;

    IF (l_rows_deleted < g_commit_chunk_size) THEN
      EXIT;
    END IF;
  END LOOP;

  write_log('Total number of rows deleted : ' || to_char(l_total_rows_deleted));
  write_log('Finished procedure clean_up at ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in cleaning up the tables : Error : ' || sqlerrm);
    RAISE;
END CLEAN_UP;


/*
This procedure collects all the additive measures.
In this procedure we also collect all the measures including queue, open measures.
This is different from the way we do it in INITIAL LOAD.
*/


PROCEDURE COLLECT_EMAILS IS

  l_email_service_level NUMBER;

BEGIN

  write_log('Start of the procedure collect_emails at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  write_log('g_collect_start_date is ' || to_char(g_collect_start_date,'dd-mon-yyyy hh24:mi:ss'));
  write_log('g_collect_end_date is ' || to_char(g_collect_end_date,'dd-mon-yyyy hh24:mi:ss'));

  /* Get the service level for the whole email center : if not defined then 1 day is the default */
  /* Multiply the profile by 60 * 60 to convert from hour to seconds                             */
  IF (FND_PROFILE.DEFINED('BIX_EMAIL_GOAL')) THEN
     l_email_service_level := TO_NUMBER(FND_PROFILE.VALUE('BIX_EMAIL_GOAL')) * 60 * 60;
  ELSE
     l_email_service_level := 24 * 60 * 60;
  END IF;
  write_log('The service level for the whole email center : ' || to_char(l_email_service_level) || ' seconds');

  write_log('Merging additive measures into table bix_email_details_f');

  --
  --Merge additive measures into the staging table - staging table introduced
  --to avoid issues with ROLLUP
  --


MERGE INTO BIX_EMAIL_DETAILS_STG  fact
  USING
  (
  SELECT
      inv2.email_account_id
        email_account_id,
      inv2.email_classification_id
        email_classification_id,
      inv2.agent_id
        agent_id,
      inv2.party_id
        party_id,
      inv2.time_id
        time_id,
      1 period_type_id,
      inv2.period_start_date
        period_start_date,
      inv2.period_start_time
        period_start_time,
      inv2.outcome_id
        outcome_id,
      inv2.result_id
        result_id,
      inv2.reason_id
        reason_id,
      g_user_id
        created_by,
      g_sysdate
        creation_date,
      g_user_id
        last_updated_by,
      g_sysdate
        last_update_date,
      0  emails_offered_in_period,
      decode(sum(inv2.emails_fetched_in_period), 0, to_number(null), sum(inv2.emails_fetched_in_period))
        emails_fetched_in_period,
      decode(sum(inv2.emails_replied_in_period), 0, to_number(null), sum(inv2.emails_replied_in_period))
        emails_replied_in_period,
      decode(sum(inv2.emails_rpld_by_goal_in_period), 0, to_number(null), sum(inv2.emails_rpld_by_goal_in_period))
        emails_rpld_by_goal_in_period,
      decode(sum(inv2.AGENT_EMAILS_RPLD_BY_GOAL), 0, to_number(null), sum(inv2.AGENT_EMAILS_RPLD_BY_GOAL))
        AGENT_EMAILS_RPLD_BY_GOAL,
      decode(sum(inv2.emails_deleted_in_period), 0, to_number(null), sum(inv2.emails_deleted_in_period))
        emails_deleted_in_period,
      decode(sum(inv2.emails_trnsfrd_out_in_period), 0, to_number(null), sum(inv2.emails_trnsfrd_out_in_period))
        emails_trnsfrd_out_in_period,
      decode(sum(inv2.emails_trnsfrd_in_in_period), 0, to_number(null), sum(inv2.emails_trnsfrd_in_in_period))
        emails_trnsfrd_in_in_period,
      decode(sum(inv2.emails_assigned_in_period), 0, to_number(null), sum(inv2.emails_assigned_in_period))
        emails_assigned_in_period,
      decode(sum(inv2.emails_auto_routed_in_period), 0, to_number(null), sum(inv2.emails_auto_routed_in_period))
        emails_auto_routed_in_period,
      decode(sum(inv2.emails_auto_uptd_sr_in_period), 0, to_number(null), sum(inv2.emails_auto_uptd_sr_in_period))
        emails_auto_uptd_sr_in_period,
      decode(round(sum(inv2.email_resp_time_in_period)), 0, to_number(null), round(sum(inv2.email_resp_time_in_period)))
        email_resp_time_in_period,
      decode(round(sum(inv2.agent_resp_time_in_period)), 0, to_number(null), round(sum(inv2.agent_resp_time_in_period)))
        agent_resp_time_in_period,
       0   sr_created_in_period,
       0   emails_rsl_and_trfd_in_period,
      decode(sum(EMAILS_AUTO_REPLIED_IN_PERIOD), 0, to_number(null), sum(EMAILS_AUTO_REPLIED_IN_PERIOD))
        EMAILS_AUTO_REPLIED_IN_PERIOD,
      decode(sum(EMAILS_AUTO_DELETED_IN_PERIOD), 0, to_number(null), sum(EMAILS_AUTO_DELETED_IN_PERIOD))
        EMAILS_AUTO_DELETED_IN_PERIOD,
      decode(sum(EMAILS_AUTO_RESOLVED_IN_PERIOD), 0, to_number(null), sum(EMAILS_AUTO_RESOLVED_IN_PERIOD))
        EMAILS_AUTO_RESOLVED_IN_PERIOD,
     0    emails_composed_in_period,
     0   emails_orr_count_in_period,
     0   accumulated_open_emails,
     0   accumulated_emails_in_queue,
     0   accumulated_emails_one_day,
     0   accumulated_emails_three_days,
     0   accumulated_emails_week,
     0   accumulated_emails_week_plus,
     0   LEADS_CREATED_IN_PERIOD,
      decode(sum(EMAILS_REROUTED_IN_PERIOD), 0, to_number(null), sum(EMAILS_REROUTED_IN_PERIOD))
        EMAILS_REROUTED_IN_PERIOD,
      g_request_id
        request_id,
      g_program_appl_id
        program_application_id,
      g_program_id
        program_id,
      g_sysdate
        program_update_date
   FROM
    (
 /* Query 1 */
 SELECT
      EMAIL_ACCOUNT_ID,
      EMAIL_CLASSIFICATION_ID,
      AGENT_ID,
      PARTY_ID,
      PERIOD_START_DATE,
      TIME_ID,
      '00:00'                                              PERIOD_START_TIME,
      -1                                                   OUTCOME_ID,
      -1                                                   RESULT_ID,
      -1                                                   REASON_ID,
      0                                                      EMAILS_OFFERED_IN_PERIOD,
      sum(EMAILS_FETCHED_IN_PERIOD)    EMAILS_FETCHED_IN_PERIOD,
      sum(EMAILS_REPLIED_IN_PERIOD)     EMAILS_REPLIED_IN_PERIOD,
      sum(AGENT_RESP_TIME_IN_PERIOD)  AGENT_RESP_TIME_IN_PERIOD,
      sum(EMAILS_RPLD_BY_GOAL_IN_PERIOD)                                             EMAILS_RPLD_BY_GOAL_IN_PERIOD,
     sum(AGENT_EMAILS_RPLD_BY_GOAL)                                          AGENT_EMAILS_RPLD_BY_GOAL,
      sum(EMAILS_TRNSFRD_OUT_IN_PERIOD)   EMAILS_TRNSFRD_OUT_IN_PERIOD,
      sum(EMAILS_TRNSFRD_IN_IN_PERIOD)   EMAILS_TRNSFRD_IN_IN_PERIOD,
      sum(EMAILS_ASSIGNED_IN_PERIOD)   EMAILS_ASSIGNED_IN_PERIOD,
      sum(EMAILS_AUTO_ROUTED_IN_PERIOD)   EMAILS_AUTO_ROUTED_IN_PERIOD,
      sum(EMAILS_AUTO_UPTD_SR_IN_PERIOD)   EMAILS_AUTO_UPTD_SR_IN_PERIOD,
      sum(EMAILS_DELETED_IN_PERIOD)   EMAILS_DELETED_IN_PERIOD,
      sum(EMAIL_RESP_TIME_IN_PERIOD)   EMAIL_RESP_TIME_IN_PERIOD,
      0                                                    SR_CREATED_IN_PERIOD,
      0                                                    EMAILS_RSL_AND_TRFD_IN_PERIOD,
      sum(EMAILS_AUTO_REPLIED_IN_PERIOD)    EMAILS_AUTO_REPLIED_IN_PERIOD,
      sum(EMAILS_AUTO_DELETED_IN_PERIOD)  EMAILS_AUTO_DELETED_IN_PERIOD,
      sum(EMAILS_AUTO_RESOLVED_IN_PERIOD)      EMAILS_AUTO_RESOLVED_IN_PERIOD,
      0                                                    emails_composed_in_period,
      0                                                    emails_orr_count_in_period,
      0                                                    accumulated_open_emails,
      0                                                    accumulated_emails_in_queue,
      0                                                    accumulated_emails_one_day,
      0                                                    accumulated_emails_three_days,
      0                                                    accumulated_emails_week,
      0                                                    accumulated_emails_week_plus,
      sum(EMAILS_REROUTED_IN_PERIOD) EMAILS_REROUTED_IN_PERIOD,
      0                                                    LEADS_CREATED_IN_PERIOD
    FROM
	(
SELECT /*+ index (mseg jtf_ih_media_item_lc_segs_n3) use_nl(mseg mitm) */
      nvl(mitm.source_id, -1)                              EMAIL_ACCOUNT_ID,
      nvl(irc.route_classification_id, -1)                 EMAIL_CLASSIFICATION_ID,
      nvl(mseg.resource_id, -1)                            AGENT_ID,
      nvl((  SELECT
          distinct first_value(intr.party_id) over(order by actv.interaction_id desc) party_id
         FROM
           jtf_ih_activities actv,
           jtf_ih_interactions intr
         WHERE
         mitm.media_id = actv.media_id
        AND actv.interaction_id = intr.interaction_id
		), -1)                               PARTY_ID,
      trunc(mseg.start_date_time)                          PERIOD_START_DATE,
      to_number(to_char(mseg.start_date_time, 'J'))        TIME_ID,
      decode(mtyp.milcs_code,'EMAIL_FETCH',1)         EMAILS_FETCHED_IN_PERIOD,
      decode(mtyp.milcs_code,'EMAIL_REPLY',1)         EMAILS_REPLIED_IN_PERIOD,
      decode(mtyp.milcs_code,'EMAIL_REPLY', (mseg.start_date_time -
	  (
	  SELECT MAX(mseg2.start_date_time) start_date_time
         FROM
           jtf_ih_media_item_lc_segs mseg2,
           jtf_ih_media_itm_lc_seg_tys mtyp2
         WHERE  mseg.media_id      = mseg2.media_id
         AND   mseg2.milcs_type_id = mtyp2.milcs_type_id
         AND   mtyp2.milcs_code    IN  ('EMAIL_FETCH','EMAIL_TRANSFER', 'EMAIL_ASSIGN_OPEN', 'EMAIL_AUTO_ROUTED', 'EMAIL_ASSIGNED')
	  ) ) * 24 * 60 * 60)  AGENT_RESP_TIME_IN_PERIOD,
      decode(mtyp.milcs_code,'EMAIL_REPLY',
               decode(sign(l_email_service_level  - (mseg.start_date_time - mitm.start_date_time) * 24 * 60 * 60),-1,0,1)
                                , 'EMAIL_AUTO_REPLY',
               decode(sign(l_email_service_level  - (mseg.start_date_time - mitm.start_date_time) * 24 * 60 * 60),-1,0,1) )
                                                           EMAILS_RPLD_BY_GOAL_IN_PERIOD,
      decode(mtyp.milcs_code,'EMAIL_REPLY',
               decode(sign(l_email_service_level  - (mseg.start_date_time - mitm.start_date_time) * 24 * 60 * 60),-1,0,1)
                       )                                          AGENT_EMAILS_RPLD_BY_GOAL,
      decode(mtyp.milcs_code,'EMAIL_TRANSFERRED',1,'EMAIL_ESCALATED',1)   EMAILS_TRNSFRD_OUT_IN_PERIOD,
      decode(mtyp.milcs_code,'EMAIL_TRANSFER',1)     EMAILS_TRNSFRD_IN_IN_PERIOD,
      decode(mtyp.milcs_code,'EMAIL_ASSIGNED',1)      EMAILS_ASSIGNED_IN_PERIOD,
      decode(mtyp.milcs_code,'EMAIL_AUTO_ROUTED',1)   EMAILS_AUTO_ROUTED_IN_PERIOD,
      decode(mtyp.milcs_code,'EMAIL_AUTO_UPDATED_SR',1)
                                                    EMAILS_AUTO_UPTD_SR_IN_PERIOD,
      decode(mtyp.milcs_code,'EMAIL_DELETED',1)       EMAILS_DELETED_IN_PERIOD,
      decode(mtyp.milcs_code,'EMAIL_REPLY', (mseg.start_date_time - mitm.start_date_time) * 24 * 60 * 60,
                          'EMAIL_AUTO_REPLY',(mseg.start_date_time - mitm.start_date_time) * 24 * 60 * 60) EMAIL_RESP_TIME_IN_PERIOD,
      decode(mtyp.milcs_code,'EMAIL_AUTO_REPLY',1)    EMAILS_AUTO_REPLIED_IN_PERIOD,
      decode(mtyp.milcs_code,'EMAIL_AUTO_DELETED',1)  EMAILS_AUTO_DELETED_IN_PERIOD,
      decode(mtyp.milcs_code,'EMAIL_RESOLVED',1)      EMAILS_AUTO_RESOLVED_IN_PERIOD,
      decode(mtyp.milcs_code,'EMAIL_REROUTED_DIFF_CLASS',1,'EMAIL_REROUTED_DIFF_ACCT',1,'EMAIL_REQUEUED',1) EMAILS_REROUTED_IN_PERIOD
    FROM
      JTF_IH_MEDIA_ITEMS mitm,
      JTF_IH_MEDIA_ITEM_LC_SEGS mseg,
      JTF_IH_MEDIA_ITM_LC_SEG_TYS mtyp,
	  (
		select name, max(route_classification_id) route_classification_id
	    from iem_route_classifications
		group by name
	  ) irc
    WHERE mitm.MEDIA_ITEM_TYPE = 'EMAIL'
    AND   mitm.classification  = irc.name(+)
    AND   mitm.direction       = 'INBOUND'
    AND   mitm.MEDIA_ID        = mseg.MEDIA_ID
    AND   mseg.MILCS_TYPE_ID   = mtyp.MILCS_TYPE_ID
    AND   mseg.START_DATE_TIME BETWEEN  g_collect_start_date and g_collect_end_date
	)
    GROUP BY
	 EMAIL_ACCOUNT_ID,
      EMAIL_CLASSIFICATION_ID,
      AGENT_ID,
      PARTY_ID,
      PERIOD_START_DATE,
      TIME_ID
      ) inv2
      GROUP BY
      inv2.email_account_id,
      inv2.email_classification_id,
      inv2.agent_id,
      inv2.party_id,
      inv2.time_id,
      inv2.period_start_date,
      inv2.period_start_time,
      inv2.outcome_id,
      inv2.result_id,
      inv2.reason_id
      )  change
  ON (
      fact.email_account_id = change.email_account_id
      AND fact.email_classification_id = change.email_classification_id
      AND fact.agent_id = change.agent_id
      AND fact.party_id = change.party_id
      AND fact.time_id = change.time_id
      AND fact.period_type_id = change.period_type_id
      AND fact.period_start_date = change.period_start_date
      AND fact.period_start_time = change.period_start_time
      AND fact.outcome_id = change.outcome_id
      AND fact.result_id = change.result_id
      AND fact.reason_id = change.reason_id )
  WHEN MATCHED THEN
    UPDATE
      SET fact.emails_offered_in_period = DECODE(nvl(fact.emails_offered_in_period,0) + nvl(change.emails_offered_in_period,0),
             0, NULL, nvl(fact.emails_offered_in_period,0) + nvl(change.emails_offered_in_period,0))
      ,fact.emails_fetched_in_period = DECODE(nvl(fact.emails_fetched_in_period,0) + nvl(change.emails_fetched_in_period,0),
             0, NULL, nvl(fact.emails_fetched_in_period,0) + nvl(change.emails_fetched_in_period,0))
      ,fact.emails_replied_in_period = DECODE(nvl(fact.emails_replied_in_period,0) + nvl(change.emails_replied_in_period,0),
             0, NULL, nvl(fact.emails_replied_in_period,0) + nvl(change.emails_replied_in_period,0))
      ,fact.emails_rpld_by_goal_in_period = DECODE(nvl(fact.emails_rpld_by_goal_in_period,0) + nvl(change.emails_rpld_by_goal_in_period,
             0), 0, NULL, nvl(fact.emails_rpld_by_goal_in_period,0) + nvl(change.emails_rpld_by_goal_in_period,0))
      ,fact.AGENT_EMAILS_RPLD_BY_GOAL = DECODE(nvl(fact.AGENT_EMAILS_RPLD_BY_GOAL,0) + nvl(change.AGENT_EMAILS_RPLD_BY_GOAL,
                   0), 0, NULL, nvl(fact.AGENT_EMAILS_RPLD_BY_GOAL,0) + nvl(change.AGENT_EMAILS_RPLD_BY_GOAL,0))
      ,fact.emails_deleted_in_period = DECODE(nvl(fact.emails_deleted_in_period,0) + nvl(change.emails_deleted_in_period,0), 0, NULL,
             nvl(fact.emails_deleted_in_period,0) + nvl(change.emails_deleted_in_period,0))
      ,fact.emails_trnsfrd_out_in_period = DECODE(nvl(fact.emails_trnsfrd_out_in_period,0) + nvl(change.emails_trnsfrd_out_in_period,0),
             0, NULL, nvl(fact.emails_trnsfrd_out_in_period,0) + nvl(change.emails_trnsfrd_out_in_period,0))
      ,fact.emails_trnsfrd_in_in_period = DECODE(nvl(fact.emails_trnsfrd_in_in_period,0) + nvl(change.emails_trnsfrd_in_in_period,0),
             0, NULL, nvl(fact.emails_trnsfrd_in_in_period,0) + nvl(change.emails_trnsfrd_in_in_period,0))
      ,fact.emails_assigned_in_period = DECODE(nvl(fact.emails_assigned_in_period,0) + nvl(change.emails_assigned_in_period,0),
             0, NULL, nvl(fact.emails_assigned_in_period,0) + nvl(change.emails_assigned_in_period,0))
      ,fact.emails_auto_routed_in_period = DECODE(nvl(fact.emails_auto_routed_in_period,0) + nvl(change.emails_auto_routed_in_period,0),
             0, NULL, nvl(fact.emails_auto_routed_in_period,0) + nvl(change.emails_auto_routed_in_period,0))
      ,fact.emails_auto_uptd_sr_in_period = DECODE(nvl(fact.emails_auto_uptd_sr_in_period,0) + nvl(change.emails_auto_uptd_sr_in_period,0),
             0, NULL, nvl(fact.emails_auto_uptd_sr_in_period,0) + nvl(change.emails_auto_uptd_sr_in_period,0))
      ,fact.email_resp_time_in_period = DECODE(nvl(fact.email_resp_time_in_period,0) + nvl(change.email_resp_time_in_period,0),
             0, NULL, nvl(fact.email_resp_time_in_period,0) + nvl(change.email_resp_time_in_period,0))
      ,fact.agent_resp_time_in_period = DECODE(nvl(fact.agent_resp_time_in_period,0) + nvl(change.agent_resp_time_in_period,0),
             0, NULL, nvl(fact.agent_resp_time_in_period,0) + nvl(change.agent_resp_time_in_period,0))
      ,fact.sr_created_in_period = DECODE(nvl(fact.sr_created_in_period,0) + nvl(change.sr_created_in_period,0),
             0, NULL, nvl(fact.sr_created_in_period,0) + nvl(change.sr_created_in_period,0))
      ,fact.emails_rsl_and_trfd_in_period = DECODE(nvl(fact.emails_rsl_and_trfd_in_period,0) + nvl(change.emails_rsl_and_trfd_in_period,0),
             0, NULL, nvl(fact.emails_rsl_and_trfd_in_period,0) + nvl(change.emails_rsl_and_trfd_in_period,0))
      ,fact.emails_orr_count_in_period = DECODE(nvl(fact.emails_orr_count_in_period,0) + nvl(change.emails_orr_count_in_period,0),
             0, NULL, nvl(fact.emails_orr_count_in_period,0) + nvl(change.emails_orr_count_in_period,0))
      ,fact.EMAILS_AUTO_REPLIED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0),
             0, NULL, nvl(fact.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0))
      ,fact.EMAILS_AUTO_DELETED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_DELETED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_DELETED_IN_PERIOD,0),
             0, NULL, nvl(fact.EMAILS_AUTO_DELETED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_DELETED_IN_PERIOD,0))
      ,fact.EMAILS_AUTO_RESOLVED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,
             0), 0, NULL, nvl(fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,0))
      ,fact.emails_composed_in_period = DECODE(nvl(fact.emails_composed_in_period,0) + nvl(change.emails_composed_in_period,0),
             0, NULL, nvl(fact.emails_composed_in_period,0) + nvl(change.emails_composed_in_period,0))
--
--Note that accumulated measures are not added together - they are replaced by the new
--calculated value as they are not additive.
--
      ,fact.accumulated_open_emails = decode(change.accumulated_open_emails,0,to_number(NULL),change.accumulated_open_emails)
      ,fact.accumulated_emails_in_queue = decode(change.accumulated_emails_in_queue,0,to_number(NULL),change.accumulated_emails_in_queue)
      ,fact.accumulated_emails_one_day = decode(change.accumulated_emails_one_day,0,to_number(NULL),change.accumulated_emails_one_day)
      ,fact.accumulated_emails_three_days = decode(change.accumulated_emails_three_days,0,to_number(NULL),change.accumulated_emails_three_days)
      ,fact.accumulated_emails_week = decode(change.accumulated_emails_week,0,to_number(NULL),change.accumulated_emails_week)
      ,fact.accumulated_emails_week_plus = decode(change.accumulated_emails_week_plus,0,to_number(NULL),change.accumulated_emails_week_plus)
      ,fact.last_updated_by = change.last_updated_by
      ,fact.last_update_date = change.last_update_date
      ,fact.emails_rerouted_in_period = DECODE(nvl(fact.emails_rerouted_in_period,0) + nvl(change.emails_rerouted_in_period,0),
             0, NULL, nvl(fact.emails_rerouted_in_period,0) + nvl(change.emails_rerouted_in_period,0))
      ,fact.leads_created_in_period = DECODE(nvl(fact.leads_created_in_period,0) + nvl(change.leads_created_in_period,0),
             0, NULL, nvl(fact.leads_created_in_period,0) + nvl(change.leads_created_in_period,0))
  WHEN NOT MATCHED THEN
    INSERT (
      fact.email_account_id,
      fact.email_classification_id,
      fact.agent_id,
      fact.party_id,
      fact.time_id,
      fact.period_type_id,
      fact.period_start_date,
      fact.period_start_time,
      fact.outcome_id,
      fact.result_id,
      fact.reason_id,
      fact.created_by,
      fact.creation_date,
      fact.last_updated_by,
      fact.last_update_date,
      fact.emails_offered_in_period,
      fact.emails_fetched_in_period,
      fact.emails_replied_in_period,
      fact.emails_rpld_by_goal_in_period,
      fact.AGENT_EMAILS_RPLD_BY_GOAL,
      fact.emails_deleted_in_period,
      fact.emails_trnsfrd_out_in_period,
      fact.emails_trnsfrd_in_in_period,
      fact.emails_assigned_in_period,
      fact.emails_auto_routed_in_period,
      fact.emails_auto_uptd_sr_in_period,
      fact.email_resp_time_in_period,
      fact.agent_resp_time_in_period,
      fact.sr_created_in_period,
      fact.emails_rsl_and_trfd_in_period,
      fact.emails_orr_count_in_period,
      fact.EMAILS_AUTO_REPLIED_IN_PERIOD,
      fact.EMAILS_AUTO_DELETED_IN_PERIOD,
      fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,
      fact.emails_composed_in_period,
      fact.accumulated_open_emails,
      fact.accumulated_emails_in_queue,
      fact.accumulated_emails_one_day,
      fact.accumulated_emails_three_days,
      fact.accumulated_emails_week,
      fact.accumulated_emails_week_plus,
      fact.request_id,
      fact.program_application_id,
      fact.program_id,
      fact.program_update_date,
      fact.emails_rerouted_in_period,
      fact.leads_created_in_period )
    VALUES (
      change.email_account_id,
      change.email_classification_id,
      change.agent_id,
      change.party_id,
      change.time_id,
      change.period_type_id,
      change.period_start_date,
      change.period_start_time,
      change.outcome_id,
      change.result_id,
      change.reason_id,
      change.created_by,
      change.creation_date,
      change.last_updated_by,
      change.last_update_date,
      decode(change.emails_offered_in_period,0,to_number(null), change.emails_offered_in_period),
      decode(change.emails_fetched_in_period, 0,to_number(null),change.emails_fetched_in_period),
      decode(change.emails_replied_in_period, 0,to_number(null),change.emails_replied_in_period),
      decode(change.emails_rpld_by_goal_in_period, 0,to_number(null),change.emails_rpld_by_goal_in_period),
      decode(change.AGENT_EMAILS_RPLD_BY_GOAL, 0,to_number(null),change.AGENT_EMAILS_RPLD_BY_GOAL),
      decode(change.emails_deleted_in_period, 0,to_number(null),change.emails_deleted_in_period),
      decode(change.emails_trnsfrd_out_in_period, 0,to_number(null),change.emails_trnsfrd_out_in_period),
      decode(change.emails_trnsfrd_in_in_period, 0,to_number(null),change.emails_trnsfrd_in_in_period),
      decode(change.emails_assigned_in_period, 0,to_number(null),change.emails_assigned_in_period),
      decode(change.emails_auto_routed_in_period, 0,to_number(null),change.emails_auto_routed_in_period),
      decode(change.emails_auto_uptd_sr_in_period, 0,to_number(null),change.emails_auto_uptd_sr_in_period),
      decode(change.email_resp_time_in_period, 0,to_number(null),change.email_resp_time_in_period),
      decode(change.agent_resp_time_in_period, 0,to_number(null),change.agent_resp_time_in_period),
      decode(change.sr_created_in_period, 0,to_number(null),change.sr_created_in_period),
      decode(change.emails_rsl_and_trfd_in_period, 0,to_number(null),change.emails_rsl_and_trfd_in_period),
      decode(change.emails_orr_count_in_period, 0,to_number(null),change.emails_orr_count_in_period),
      decode(change.EMAILS_AUTO_REPLIED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_REPLIED_IN_PERIOD),
      decode(change.EMAILS_AUTO_DELETED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_DELETED_IN_PERIOD),
      decode(change.EMAILS_AUTO_RESOLVED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_RESOLVED_IN_PERIOD),
      decode(change.emails_composed_in_period, 0,to_number(null),change.emails_composed_in_period),
      decode(change.accumulated_open_emails, 0,to_number(null),change.accumulated_open_emails),
      decode(change.accumulated_emails_in_queue, 0,to_number(null),change.accumulated_emails_in_queue),
      decode(change.accumulated_emails_one_day, 0,to_number(null),change.accumulated_emails_one_day),
      decode(change.accumulated_emails_three_days, 0,to_number(null),change.accumulated_emails_three_days),
      decode(change.accumulated_emails_week, 0,to_number(null),change.accumulated_emails_week),
      decode(change.accumulated_emails_week_plus, 0,to_number(null),change.accumulated_emails_week_plus),
      change.request_id,
      change.program_application_id,
      change.program_id,
      change.program_update_date,
      decode(change.emails_rerouted_in_period, 0,to_number(null),change.emails_rerouted_in_period),
      decode(change.leads_created_in_period, 0,to_number(null),change.leads_created_in_period)
      );

  write_log('Number of rows updated in table bix_email_details_stg for Emails Fetched and Replied  ' || to_char(SQL%ROWCOUNT));



	  MERGE INTO BIX_EMAIL_DETAILS_STG  fact
	  USING
	  (SELECT
	      inv2.email_account_id
		email_account_id,
	      inv2.email_classification_id
		email_classification_id,
	      inv2.agent_id
		agent_id,
	      inv2.party_id
		party_id,
	      inv2.time_id
		time_id,
	      1 period_type_id,
	      inv2.period_start_date
		period_start_date,
	      inv2.period_start_time
		period_start_time,
	      inv2.outcome_id
		outcome_id,
	      inv2.result_id
		result_id,
	      inv2.reason_id
		reason_id,
	      g_user_id
		created_by,
	      g_sysdate
		creation_date,
	      g_user_id
		last_updated_by,
	      g_sysdate
		last_update_date,
	      decode(sum(inv2.emails_offered_in_period), 0, to_number(null), sum(inv2.emails_offered_in_period)) emails_offered_in_period,
		0  emails_fetched_in_period,
		0  emails_replied_in_period,
		0  emails_rpld_by_goal_in_period,
		0  AGENT_EMAILS_RPLD_BY_GOAL,
		0  emails_deleted_in_period,
		0  emails_trnsfrd_out_in_period,
		0  emails_trnsfrd_in_in_period,
		0  emails_assigned_in_period,
		0  emails_auto_routed_in_period,
		0  emails_auto_uptd_sr_in_period,
		0  email_resp_time_in_period,
		0  agent_resp_time_in_period,
		0  sr_created_in_period,
		0  emails_rsl_and_trfd_in_period,
		0  EMAILS_AUTO_REPLIED_IN_PERIOD,
		0  EMAILS_AUTO_DELETED_IN_PERIOD,
		0  EMAILS_AUTO_RESOLVED_IN_PERIOD,
		0  emails_composed_in_period,
		0  emails_orr_count_in_period,
		0  accumulated_open_emails,
		0  accumulated_emails_in_queue,
		0  accumulated_emails_one_day,
		0  accumulated_emails_three_days,
		0  accumulated_emails_week,
		0  accumulated_emails_week_plus,
		0  LEADS_CREATED_IN_PERIOD,
		0  EMAILS_REROUTED_IN_PERIOD,
	      g_request_id
		request_id,
	      g_program_appl_id
		program_application_id,
	      g_program_id
		program_id,
	      g_sysdate
		program_update_date
	   FROM
	    (
	/*Query 2*/
		SELECT
	     EMAIL_ACCOUNT_ID,
	      EMAIL_CLASSIFICATION_ID,
	      -1 AGENT_ID,
	      PARTY_ID,
	      PERIOD_START_DATE,
	      TIME_ID,
	       '00:00'                                              PERIOD_START_TIME,
	      -1                                                   OUTCOME_ID,
	      -1                                                   RESULT_ID,
	      -1                                                   REASON_ID,
	      COUNT(*)                                             EMAILS_OFFERED_IN_PERIOD,
	      0                                                    EMAILS_FETCHED_IN_PERIOD,
	      0                                                    EMAILS_REPLIED_IN_PERIOD,
	      0                                                    AGENT_RESP_TIME_IN_PERIOD,
	      0                                                    EMAILS_RPLD_BY_GOAL_IN_PERIOD,
	      0                                                    AGENT_EMAILS_RPLD_BY_GOAL,
	      0                                                    EMAILS_TRNSFRD_OUT_IN_PERIOD,
	      0                                                    EMAILS_TRNSFRD_IN_IN_PERIOD,
	      0                                                    EMAILS_ASSIGNED_IN_PERIOD,
	      0                                                    EMAILS_AUTO_ROUTED_IN_PERIOD,
	      0                                                    EMAILS_AUTO_UPTD_SR_IN_PERIOD,
	      0                                                    EMAILS_DELETED_IN_PERIOD,
	      0                                                    EMAIL_RESP_TIME_IN_PERIOD,
	      0                                                    SR_CREATED_IN_PERIOD,
	      0                                                    EMAILS_RSL_AND_TRFD_IN_PERIOD,
	      0                                                    EMAILS_AUTO_REPLIED_IN_PERIOD,
	      0                                                    EMAILS_AUTO_DELETED_IN_PERIOD,
	      0                                                    EMAILS_AUTO_RESOLVED_IN_PERIOD,
	      0                                                    emails_composed_in_period,
	      0                                                    emails_orr_count_in_period,
	      0                                                    accumulated_open_emails,
	      0                                                    accumulated_emails_in_queue,
	      0                                                    accumulated_emails_one_day,
	      0                                                    accumulated_emails_three_days,
	      0                                                    accumulated_emails_week,
	      0                                                    accumulated_emails_week_plus,
		 0                                                    EMAILS_REROUTED_IN_PERIOD,
		 0                                                    LEADS_CREATED_IN_PERIOD
	    FROM
	 (
		SELECT
	      nvl(mitm.source_id, -1)                              EMAIL_ACCOUNT_ID,
	      nvl(irc.route_classification_id, -1)                 EMAIL_CLASSIFICATION_ID,
	      -1                                                   AGENT_ID,
		  nvl((  SELECT
		  distinct first_value(intr.party_id) over(order by actv.interaction_id desc) party_id
		 FROM
		   jtf_ih_activities actv,
		   jtf_ih_interactions intr
		 WHERE
		 mitm.media_id = actv.media_id
		AND actv.interaction_id = intr.interaction_id
			), -1)                              PARTY_ID,
	      trunc(mitm.start_date_time)                          PERIOD_START_DATE,
	      to_number(to_char(mitm.start_date_time, 'J'))        TIME_ID
	       FROM
	      JTF_IH_MEDIA_ITEMS mitm,
	     (
	    select name, max(route_classification_id) route_classification_id
	    from iem_route_classifications
	    group by name
	    ) irc
	    WHERE mitm.MEDIA_ITEM_TYPE = 'EMAIL'
	    AND   mitm.DIRECTION       = 'INBOUND'
	    AND   mitm.classification  = irc.name(+)
	    AND   mitm.START_DATE_TIME BETWEEN  g_collect_start_date and g_collect_end_date
		)
	    GROUP BY
		 EMAIL_ACCOUNT_ID,
	      EMAIL_CLASSIFICATION_ID,
	      AGENT_ID,
	      PARTY_ID,
	      PERIOD_START_DATE,
	      TIME_ID
	      ) inv2
	      GROUP BY
	      inv2.email_account_id,
	      inv2.email_classification_id,
	      inv2.agent_id,
	      inv2.party_id,
	      inv2.time_id,
	      inv2.period_start_date,
	      inv2.period_start_time,
	      inv2.outcome_id,
	      inv2.result_id,
	      inv2.reason_id
	      )  change
	  ON (
	      fact.email_account_id = change.email_account_id
	      AND fact.email_classification_id = change.email_classification_id
	      AND fact.agent_id = change.agent_id
	      AND fact.party_id = change.party_id
	      AND fact.time_id = change.time_id
	      AND fact.period_type_id = change.period_type_id
	      AND fact.period_start_date = change.period_start_date
	      AND fact.period_start_time = change.period_start_time
	      AND fact.outcome_id = change.outcome_id
	      AND fact.result_id = change.result_id
	      AND fact.reason_id = change.reason_id )
	  WHEN MATCHED THEN
	    UPDATE
	      SET fact.emails_offered_in_period = DECODE(nvl(fact.emails_offered_in_period,0) + nvl(change.emails_offered_in_period,0),
		     0, NULL, nvl(fact.emails_offered_in_period,0) + nvl(change.emails_offered_in_period,0))
	      ,fact.emails_fetched_in_period = DECODE(nvl(fact.emails_fetched_in_period,0) + nvl(change.emails_fetched_in_period,0),
		     0, NULL, nvl(fact.emails_fetched_in_period,0) + nvl(change.emails_fetched_in_period,0))
	      ,fact.emails_replied_in_period = DECODE(nvl(fact.emails_replied_in_period,0) + nvl(change.emails_replied_in_period,0),
		     0, NULL, nvl(fact.emails_replied_in_period,0) + nvl(change.emails_replied_in_period,0))
	      ,fact.emails_rpld_by_goal_in_period = DECODE(nvl(fact.emails_rpld_by_goal_in_period,0) + nvl(change.emails_rpld_by_goal_in_period,
		     0), 0, NULL, nvl(fact.emails_rpld_by_goal_in_period,0) + nvl(change.emails_rpld_by_goal_in_period,0))
	      ,fact.AGENT_EMAILS_RPLD_BY_GOAL = DECODE(nvl(fact.AGENT_EMAILS_RPLD_BY_GOAL,0) + nvl(change.AGENT_EMAILS_RPLD_BY_GOAL,
			   0), 0, NULL, nvl(fact.AGENT_EMAILS_RPLD_BY_GOAL,0) + nvl(change.AGENT_EMAILS_RPLD_BY_GOAL,0))
	      ,fact.emails_deleted_in_period = DECODE(nvl(fact.emails_deleted_in_period,0) + nvl(change.emails_deleted_in_period,0), 0, NULL,
		     nvl(fact.emails_deleted_in_period,0) + nvl(change.emails_deleted_in_period,0))
	      ,fact.emails_trnsfrd_out_in_period = DECODE(nvl(fact.emails_trnsfrd_out_in_period,0) + nvl(change.emails_trnsfrd_out_in_period,0),
		     0, NULL, nvl(fact.emails_trnsfrd_out_in_period,0) + nvl(change.emails_trnsfrd_out_in_period,0))
	      ,fact.emails_trnsfrd_in_in_period = DECODE(nvl(fact.emails_trnsfrd_in_in_period,0) + nvl(change.emails_trnsfrd_in_in_period,0),
		     0, NULL, nvl(fact.emails_trnsfrd_in_in_period,0) + nvl(change.emails_trnsfrd_in_in_period,0))
	      ,fact.emails_assigned_in_period = DECODE(nvl(fact.emails_assigned_in_period,0) + nvl(change.emails_assigned_in_period,0),
		     0, NULL, nvl(fact.emails_assigned_in_period,0) + nvl(change.emails_assigned_in_period,0))
	      ,fact.emails_auto_routed_in_period = DECODE(nvl(fact.emails_auto_routed_in_period,0) + nvl(change.emails_auto_routed_in_period,0),
		     0, NULL, nvl(fact.emails_auto_routed_in_period,0) + nvl(change.emails_auto_routed_in_period,0))
	      ,fact.emails_auto_uptd_sr_in_period = DECODE(nvl(fact.emails_auto_uptd_sr_in_period,0) + nvl(change.emails_auto_uptd_sr_in_period,0),
		     0, NULL, nvl(fact.emails_auto_uptd_sr_in_period,0) + nvl(change.emails_auto_uptd_sr_in_period,0))
	      ,fact.email_resp_time_in_period = DECODE(nvl(fact.email_resp_time_in_period,0) + nvl(change.email_resp_time_in_period,0),
		     0, NULL, nvl(fact.email_resp_time_in_period,0) + nvl(change.email_resp_time_in_period,0))
	      ,fact.agent_resp_time_in_period = DECODE(nvl(fact.agent_resp_time_in_period,0) + nvl(change.agent_resp_time_in_period,0),
		     0, NULL, nvl(fact.agent_resp_time_in_period,0) + nvl(change.agent_resp_time_in_period,0))
	      ,fact.sr_created_in_period = DECODE(nvl(fact.sr_created_in_period,0) + nvl(change.sr_created_in_period,0),
		     0, NULL, nvl(fact.sr_created_in_period,0) + nvl(change.sr_created_in_period,0))
	      ,fact.emails_rsl_and_trfd_in_period = DECODE(nvl(fact.emails_rsl_and_trfd_in_period,0) + nvl(change.emails_rsl_and_trfd_in_period,0),
		     0, NULL, nvl(fact.emails_rsl_and_trfd_in_period,0) + nvl(change.emails_rsl_and_trfd_in_period,0))
	      ,fact.emails_orr_count_in_period = DECODE(nvl(fact.emails_orr_count_in_period,0) + nvl(change.emails_orr_count_in_period,0),
		     0, NULL, nvl(fact.emails_orr_count_in_period,0) + nvl(change.emails_orr_count_in_period,0))
	      ,fact.EMAILS_AUTO_REPLIED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0),
		     0, NULL, nvl(fact.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0))
	      ,fact.EMAILS_AUTO_DELETED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_DELETED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_DELETED_IN_PERIOD,0),
		     0, NULL, nvl(fact.EMAILS_AUTO_DELETED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_DELETED_IN_PERIOD,0))
	      ,fact.EMAILS_AUTO_RESOLVED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,
		     0), 0, NULL, nvl(fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,0))
	      ,fact.emails_composed_in_period = DECODE(nvl(fact.emails_composed_in_period,0) + nvl(change.emails_composed_in_period,0),
		     0, NULL, nvl(fact.emails_composed_in_period,0) + nvl(change.emails_composed_in_period,0))
	--
	--Note that accumulated measures are not added together - they are replaced by the new
	--calculated value as they are not additive.
	--
	      ,fact.accumulated_open_emails = decode(change.accumulated_open_emails,0,to_number(NULL),change.accumulated_open_emails)
	      ,fact.accumulated_emails_in_queue = decode(change.accumulated_emails_in_queue,0,to_number(NULL),change.accumulated_emails_in_queue)
	      ,fact.accumulated_emails_one_day = decode(change.accumulated_emails_one_day,0,to_number(NULL),change.accumulated_emails_one_day)
	      ,fact.accumulated_emails_three_days = decode(change.accumulated_emails_three_days,0,to_number(NULL),change.accumulated_emails_three_days)
	      ,fact.accumulated_emails_week = decode(change.accumulated_emails_week,0,to_number(NULL),change.accumulated_emails_week)
	      ,fact.accumulated_emails_week_plus = decode(change.accumulated_emails_week_plus,0,to_number(NULL),change.accumulated_emails_week_plus)
	      ,fact.last_updated_by = change.last_updated_by
	      ,fact.last_update_date = change.last_update_date
	      ,fact.emails_rerouted_in_period = DECODE(nvl(fact.emails_rerouted_in_period,0) + nvl(change.emails_rerouted_in_period,0),
		     0, NULL, nvl(fact.emails_rerouted_in_period,0) + nvl(change.emails_rerouted_in_period,0))
	      ,fact.leads_created_in_period = DECODE(nvl(fact.leads_created_in_period,0) + nvl(change.leads_created_in_period,0),
		     0, NULL, nvl(fact.leads_created_in_period,0) + nvl(change.leads_created_in_period,0))
	  WHEN NOT MATCHED THEN
	    INSERT (
	      fact.email_account_id,
	      fact.email_classification_id,
	      fact.agent_id,
	      fact.party_id,
	      fact.time_id,
	      fact.period_type_id,
	      fact.period_start_date,
	      fact.period_start_time,
	      fact.outcome_id,
	      fact.result_id,
	      fact.reason_id,
	      fact.created_by,
	      fact.creation_date,
	      fact.last_updated_by,
	      fact.last_update_date,
	      fact.emails_offered_in_period,
	      fact.emails_fetched_in_period,
	      fact.emails_replied_in_period,
	      fact.emails_rpld_by_goal_in_period,
	      fact.AGENT_EMAILS_RPLD_BY_GOAL,
	      fact.emails_deleted_in_period,
	      fact.emails_trnsfrd_out_in_period,
	      fact.emails_trnsfrd_in_in_period,
	      fact.emails_assigned_in_period,
	      fact.emails_auto_routed_in_period,
	      fact.emails_auto_uptd_sr_in_period,
	      fact.email_resp_time_in_period,
	      fact.agent_resp_time_in_period,
	      fact.sr_created_in_period,
	      fact.emails_rsl_and_trfd_in_period,
	      fact.emails_orr_count_in_period,
	      fact.EMAILS_AUTO_REPLIED_IN_PERIOD,
	      fact.EMAILS_AUTO_DELETED_IN_PERIOD,
	      fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,
	      fact.emails_composed_in_period,
	      fact.accumulated_open_emails,
	      fact.accumulated_emails_in_queue,
	      fact.accumulated_emails_one_day,
	      fact.accumulated_emails_three_days,
	      fact.accumulated_emails_week,
	      fact.accumulated_emails_week_plus,
	      fact.request_id,
	      fact.program_application_id,
	      fact.program_id,
	      fact.program_update_date,
	      fact.emails_rerouted_in_period,
	      fact.leads_created_in_period )
	    VALUES (
	      change.email_account_id,
	      change.email_classification_id,
	      change.agent_id,
	      change.party_id,
	      change.time_id,
	      change.period_type_id,
	      change.period_start_date,
	      change.period_start_time,
	      change.outcome_id,
	      change.result_id,
	      change.reason_id,
	      change.created_by,
	      change.creation_date,
	      change.last_updated_by,
	      change.last_update_date,
	      decode(change.emails_offered_in_period,0,to_number(null), change.emails_offered_in_period),
	      decode(change.emails_fetched_in_period, 0,to_number(null),change.emails_fetched_in_period),
	      decode(change.emails_replied_in_period, 0,to_number(null),change.emails_replied_in_period),
	      decode(change.emails_rpld_by_goal_in_period, 0,to_number(null),change.emails_rpld_by_goal_in_period),
	      decode(change.AGENT_EMAILS_RPLD_BY_GOAL, 0,to_number(null),change.AGENT_EMAILS_RPLD_BY_GOAL),
	      decode(change.emails_deleted_in_period, 0,to_number(null),change.emails_deleted_in_period),
	      decode(change.emails_trnsfrd_out_in_period, 0,to_number(null),change.emails_trnsfrd_out_in_period),
	      decode(change.emails_trnsfrd_in_in_period, 0,to_number(null),change.emails_trnsfrd_in_in_period),
	      decode(change.emails_assigned_in_period, 0,to_number(null),change.emails_assigned_in_period),
	      decode(change.emails_auto_routed_in_period, 0,to_number(null),change.emails_auto_routed_in_period),
	      decode(change.emails_auto_uptd_sr_in_period, 0,to_number(null),change.emails_auto_uptd_sr_in_period),
	      decode(change.email_resp_time_in_period, 0,to_number(null),change.email_resp_time_in_period),
	      decode(change.agent_resp_time_in_period, 0,to_number(null),change.agent_resp_time_in_period),
	      decode(change.sr_created_in_period, 0,to_number(null),change.sr_created_in_period),
	      decode(change.emails_rsl_and_trfd_in_period, 0,to_number(null),change.emails_rsl_and_trfd_in_period),
	      decode(change.emails_orr_count_in_period, 0,to_number(null),change.emails_orr_count_in_period),
	      decode(change.EMAILS_AUTO_REPLIED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_REPLIED_IN_PERIOD),
	      decode(change.EMAILS_AUTO_DELETED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_DELETED_IN_PERIOD),
	      decode(change.EMAILS_AUTO_RESOLVED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_RESOLVED_IN_PERIOD),
	      decode(change.emails_composed_in_period, 0,to_number(null),change.emails_composed_in_period),
	      decode(change.accumulated_open_emails, 0,to_number(null),change.accumulated_open_emails),
	      decode(change.accumulated_emails_in_queue, 0,to_number(null),change.accumulated_emails_in_queue),
	      decode(change.accumulated_emails_one_day, 0,to_number(null),change.accumulated_emails_one_day),
	      decode(change.accumulated_emails_three_days, 0,to_number(null),change.accumulated_emails_three_days),
	      decode(change.accumulated_emails_week, 0,to_number(null),change.accumulated_emails_week),
	      decode(change.accumulated_emails_week_plus, 0,to_number(null),change.accumulated_emails_week_plus),
	      change.request_id,
	      change.program_application_id,
	      change.program_id,
	      change.program_update_date,
	      decode(change.emails_rerouted_in_period, 0,to_number(null),change.emails_rerouted_in_period),
	      decode(change.leads_created_in_period, 0,to_number(null),change.leads_created_in_period)
	      );


write_log('Number of rows updated in table bix_email_details_stg for Emails Offered  ' || to_char(SQL%ROWCOUNT));


MERGE INTO BIX_EMAIL_DETAILS_STG  fact
  USING
  (SELECT
      inv2.email_account_id
        email_account_id,
      inv2.email_classification_id
        email_classification_id,
      inv2.agent_id
        agent_id,
      inv2.party_id
        party_id,
      inv2.time_id
        time_id,
      1 period_type_id,
      inv2.period_start_date
        period_start_date,
      inv2.period_start_time
        period_start_time,
      inv2.outcome_id
        outcome_id,
      inv2.result_id
        result_id,
      inv2.reason_id
        reason_id,
      g_user_id
        created_by,
      g_sysdate
        creation_date,
      g_user_id
        last_updated_by,
      g_sysdate
        last_update_date,
      0
        emails_offered_in_period,
      0
        emails_fetched_in_period,
      0
      emails_replied_in_period,
      0
        emails_rpld_by_goal_in_period,
      0
        AGENT_EMAILS_RPLD_BY_GOAL,
      0
        emails_deleted_in_period,
      0
        emails_trnsfrd_out_in_period,
      0
        emails_trnsfrd_in_in_period,
      0
        emails_assigned_in_period,
      0
        emails_auto_routed_in_period,
      0
        emails_auto_uptd_sr_in_period,
      0
        email_resp_time_in_period,
       0
        agent_resp_time_in_period,
      decode(sum(inv2.sr_created_in_period), 0, to_number(null), sum(inv2.sr_created_in_period))
        sr_created_in_period,
      0
        emails_rsl_and_trfd_in_period,
      0
        EMAILS_AUTO_REPLIED_IN_PERIOD,
      0
        EMAILS_AUTO_DELETED_IN_PERIOD,
      0
        EMAILS_AUTO_RESOLVED_IN_PERIOD,
      0
        emails_composed_in_period,
      0
        emails_orr_count_in_period,
      0
        accumulated_open_emails,
      0
        accumulated_emails_in_queue,
      0
        accumulated_emails_one_day,
      0
        accumulated_emails_three_days,
      0
        accumulated_emails_week,
      0
        accumulated_emails_week_plus,
      decode(sum(LEADS_CREATED_IN_PERIOD), 0, to_number(null), sum(LEADS_CREATED_IN_PERIOD))
       LEADS_CREATED_IN_PERIOD,
      0  EMAILS_REROUTED_IN_PERIOD,
      g_request_id
        request_id,
      g_program_appl_id
        program_application_id,
      g_program_id
        program_id,
      g_sysdate
        program_update_date
   FROM
    (
	/* Query 3 */
	   SELECT /*+ index(actv jtf_ih_activities_n11) */
      nvl(email_account_id, -1)                              EMAIL_ACCOUNT_ID,
      nvl(email_classification_id, -1)                 EMAIL_CLASSIFICATION_ID,
      nvl(agent_id, -1)                            AGENT_ID,
      nvl(party_id, -1)                               PARTY_ID,
      trunc(period_start_date)                          PERIOD_START_DATE,
      time_id        TIME_ID,
      '00:00'                                              PERIOD_START_TIME,
      -1                                                   OUTCOME_ID,
      -1                                                   RESULT_ID,
      -1                                                   REASON_ID,
      0                                                    EMAILS_OFFERED_IN_PERIOD,
      0                                                    EMAILS_FETCHED_IN_PERIOD,
      0                                                    EMAILS_REPLIED_IN_PERIOD,
      0                                                    AGENT_RESP_TIME_IN_PERIOD,
      0                                                    EMAILS_RPLD_BY_GOAL_IN_PERIOD,
      0                                                    AGENT_EMAILS_RPLD_BY_GOAL,
      0                                                    EMAILS_TRNSFRD_OUT_IN_PERIOD,
      0                                                    EMAILS_TRNSFRD_IN_IN_PERIOD,
      0                                                    EMAILS_ASSIGNED_IN_PERIOD,
      0                                                    EMAILS_AUTO_ROUTED_IN_PERIOD,
      0                                                    EMAILS_AUTO_UPTD_SR_IN_PERIOD,
      0                                                    EMAILS_DELETED_IN_PERIOD,
      0                                                    EMAIL_RESP_TIME_IN_PERIOD,
      SUM(DECODE(action_id,13,1))                     SR_CREATED_IN_PERIOD,
      0                                                    EMAILS_RSL_AND_TRFD_IN_PERIOD,
      0                                                    EMAILS_AUTO_REPLIED_IN_PERIOD,
      0                                                    EMAILS_AUTO_DELETED_IN_PERIOD,
      0                                                    EMAILS_AUTO_RESOLVED_IN_PERIOD,
      0                                                    emails_composed_in_period,
      0                                                    emails_orr_count_in_period,
      0                                                    accumulated_open_emails,
      0                                                    accumulated_emails_in_queue,
      0                                                    accumulated_emails_one_day,
      0                                                    accumulated_emails_three_days,
      0                                                    accumulated_emails_week,
	        0                                                    accumulated_emails_week_plus,
         0                                                    EMAILS_REROUTED_IN_PERIOD,
         SUM(DECODE(action_id,71,1))                      LEADS_CREATED_IN_PERIOD
	FROM
	(
	SELECT
  nvl(mitm.source_id, -1)                              EMAIL_ACCOUNT_ID,
      nvl(irc.route_classification_id, -1)                 EMAIL_CLASSIFICATION_ID,
      nvl(intr.resource_id, -1)                            AGENT_ID,
      first_value(party_id) over(partition by actv.media_id order by actv.interaction_id DESC) PARTY_ID,
      trunc(actv.start_date_time)                          PERIOD_START_DATE,
      to_number(to_char(actv.start_date_time, 'J'))        TIME_ID,
      actv.action_id                     ACTION_ID
    FROM
      JTF_IH_ACTIVITIES actv,
      JTF_IH_INTERACTIONS intr,
      JTF_IH_MEDIA_ITEMS mitm,
      (select /*+ index(actv jtf_ih_activities_n11) use_nl(actv actv1 mitm) */
         actv.interaction_id interaction_id,
         max(mitm.classification) classification
       from
         jtf_ih_activities actv,
         jtf_ih_media_items mitm
       where
	  actv.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
      and   actv.media_id = mitm.media_id
      and   mitm.direction = 'INBOUND'
      and   mitm.media_item_type = 'EMAIL'
       group by actv.interaction_id ) inv2,
    --
    --Changes for R12
    --
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) irc
    WHERE
    actv.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
    AND ( ( actv.action_id = 13 AND  actv.action_item_id = 17 ) OR
          ( actv.action_id = 71  AND  actv.action_item_id = 8  )
        )
    AND   actv.media_id = mitm.media_id
    AND   mitm.MEDIA_ITEM_TYPE = 'EMAIL'
    AND   inv2.classification  = irc.name(+)
    AND   actv.interaction_id = intr.interaction_id
    AND   actv.interaction_id = inv2.interaction_id(+)
	)
    GROUP BY
      nvl(email_account_id, -1),
      nvl(email_classification_id, -1),
      agent_id,
      nvl(party_id, -1),
	      trunc(period_start_date),
      time_id
)inv2
GROUP BY
      inv2.email_account_id,
      inv2.email_classification_id,
      inv2.agent_id,
      inv2.party_id,
      inv2.time_id,
      inv2.period_start_date,
      inv2.period_start_time,
      inv2.outcome_id,
      inv2.result_id,
      inv2.reason_id
)  change
  ON (
      fact.email_account_id = change.email_account_id
      AND fact.email_classification_id = change.email_classification_id
      AND fact.agent_id = change.agent_id
      AND fact.party_id = change.party_id
      AND fact.time_id = change.time_id
      AND fact.period_type_id = change.period_type_id
      AND fact.period_start_date = change.period_start_date
      AND fact.period_start_time = change.period_start_time
      AND fact.outcome_id = change.outcome_id
      AND fact.result_id = change.result_id
      AND fact.reason_id = change.reason_id )
  WHEN MATCHED THEN
    UPDATE
      SET fact.emails_offered_in_period = DECODE(nvl(fact.emails_offered_in_period,0) + nvl(change.emails_offered_in_period,0),
             0, NULL, nvl(fact.emails_offered_in_period,0) + nvl(change.emails_offered_in_period,0))
      ,fact.emails_fetched_in_period = DECODE(nvl(fact.emails_fetched_in_period,0) + nvl(change.emails_fetched_in_period,0),
             0, NULL, nvl(fact.emails_fetched_in_period,0) + nvl(change.emails_fetched_in_period,0))
      ,fact.emails_replied_in_period = DECODE(nvl(fact.emails_replied_in_period,0) + nvl(change.emails_replied_in_period,0),
             0, NULL, nvl(fact.emails_replied_in_period,0) + nvl(change.emails_replied_in_period,0))
      ,fact.emails_rpld_by_goal_in_period = DECODE(nvl(fact.emails_rpld_by_goal_in_period,0) + nvl(change.emails_rpld_by_goal_in_period,
             0), 0, NULL, nvl(fact.emails_rpld_by_goal_in_period,0) + nvl(change.emails_rpld_by_goal_in_period,0))
      ,fact.AGENT_EMAILS_RPLD_BY_GOAL = DECODE(nvl(fact.AGENT_EMAILS_RPLD_BY_GOAL,0) + nvl(change.AGENT_EMAILS_RPLD_BY_GOAL,
                   0), 0, NULL, nvl(fact.AGENT_EMAILS_RPLD_BY_GOAL,0) + nvl(change.AGENT_EMAILS_RPLD_BY_GOAL,0))
      ,fact.emails_deleted_in_period = DECODE(nvl(fact.emails_deleted_in_period,0) + nvl(change.emails_deleted_in_period,0), 0, NULL,
             nvl(fact.emails_deleted_in_period,0) + nvl(change.emails_deleted_in_period,0))
      ,fact.emails_trnsfrd_out_in_period = DECODE(nvl(fact.emails_trnsfrd_out_in_period,0) + nvl(change.emails_trnsfrd_out_in_period,0),
             0, NULL, nvl(fact.emails_trnsfrd_out_in_period,0) + nvl(change.emails_trnsfrd_out_in_period,0))
      ,fact.emails_trnsfrd_in_in_period = DECODE(nvl(fact.emails_trnsfrd_in_in_period,0) + nvl(change.emails_trnsfrd_in_in_period,0),
             0, NULL, nvl(fact.emails_trnsfrd_in_in_period,0) + nvl(change.emails_trnsfrd_in_in_period,0))
      ,fact.emails_assigned_in_period = DECODE(nvl(fact.emails_assigned_in_period,0) + nvl(change.emails_assigned_in_period,0),
             0, NULL, nvl(fact.emails_assigned_in_period,0) + nvl(change.emails_assigned_in_period,0))
      ,fact.emails_auto_routed_in_period = DECODE(nvl(fact.emails_auto_routed_in_period,0) + nvl(change.emails_auto_routed_in_period,0),
             0, NULL, nvl(fact.emails_auto_routed_in_period,0) + nvl(change.emails_auto_routed_in_period,0))
      ,fact.emails_auto_uptd_sr_in_period = DECODE(nvl(fact.emails_auto_uptd_sr_in_period,0) + nvl(change.emails_auto_uptd_sr_in_period,0),
             0, NULL, nvl(fact.emails_auto_uptd_sr_in_period,0) + nvl(change.emails_auto_uptd_sr_in_period,0))
      ,fact.email_resp_time_in_period = DECODE(nvl(fact.email_resp_time_in_period,0) + nvl(change.email_resp_time_in_period,0),
             0, NULL, nvl(fact.email_resp_time_in_period,0) + nvl(change.email_resp_time_in_period,0))
      ,fact.agent_resp_time_in_period = DECODE(nvl(fact.agent_resp_time_in_period,0) + nvl(change.agent_resp_time_in_period,0),
             0, NULL, nvl(fact.agent_resp_time_in_period,0) + nvl(change.agent_resp_time_in_period,0))
      ,fact.sr_created_in_period = DECODE(nvl(fact.sr_created_in_period,0) + nvl(change.sr_created_in_period,0),
             0, NULL, nvl(fact.sr_created_in_period,0) + nvl(change.sr_created_in_period,0))
      ,fact.emails_rsl_and_trfd_in_period = DECODE(nvl(fact.emails_rsl_and_trfd_in_period,0) + nvl(change.emails_rsl_and_trfd_in_period,0),
             0, NULL, nvl(fact.emails_rsl_and_trfd_in_period,0) + nvl(change.emails_rsl_and_trfd_in_period,0))
      ,fact.emails_orr_count_in_period = DECODE(nvl(fact.emails_orr_count_in_period,0) + nvl(change.emails_orr_count_in_period,0),
             0, NULL, nvl(fact.emails_orr_count_in_period,0) + nvl(change.emails_orr_count_in_period,0))
      ,fact.EMAILS_AUTO_REPLIED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0),
             0, NULL, nvl(fact.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0))
      ,fact.EMAILS_AUTO_DELETED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_DELETED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_DELETED_IN_PERIOD,0),
             0, NULL, nvl(fact.EMAILS_AUTO_DELETED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_DELETED_IN_PERIOD,0))
      ,fact.EMAILS_AUTO_RESOLVED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,
             0), 0, NULL, nvl(fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,0))
      ,fact.emails_composed_in_period = DECODE(nvl(fact.emails_composed_in_period,0) + nvl(change.emails_composed_in_period,0),
             0, NULL, nvl(fact.emails_composed_in_period,0) + nvl(change.emails_composed_in_period,0))
--
--Note that accumulated measures are not added together - they are replaced by the new
--calculated value as they are not additive.
--
      ,fact.accumulated_open_emails = decode(change.accumulated_open_emails,0,to_number(NULL),change.accumulated_open_emails)
      ,fact.accumulated_emails_in_queue = decode(change.accumulated_emails_in_queue,0,to_number(NULL),change.accumulated_emails_in_queue)
      ,fact.accumulated_emails_one_day = decode(change.accumulated_emails_one_day,0,to_number(NULL),change.accumulated_emails_one_day)
      ,fact.accumulated_emails_three_days = decode(change.accumulated_emails_three_days,0,to_number(NULL),change.accumulated_emails_three_days)
      ,fact.accumulated_emails_week = decode(change.accumulated_emails_week,0,to_number(NULL),change.accumulated_emails_week)
      ,fact.accumulated_emails_week_plus = decode(change.accumulated_emails_week_plus,0,to_number(NULL),change.accumulated_emails_week_plus)
      ,fact.last_updated_by = change.last_updated_by
      ,fact.last_update_date = change.last_update_date
      ,fact.emails_rerouted_in_period = DECODE(nvl(fact.emails_rerouted_in_period,0) + nvl(change.emails_rerouted_in_period,0),
             0, NULL, nvl(fact.emails_rerouted_in_period,0) + nvl(change.emails_rerouted_in_period,0))
      ,fact.leads_created_in_period = DECODE(nvl(fact.leads_created_in_period,0) + nvl(change.leads_created_in_period,0),
             0, NULL, nvl(fact.leads_created_in_period,0) + nvl(change.leads_created_in_period,0))
  WHEN NOT MATCHED THEN
    INSERT (
      fact.email_account_id,
      fact.email_classification_id,
      fact.agent_id,
      fact.party_id,
      fact.time_id,
      fact.period_type_id,
      fact.period_start_date,
      fact.period_start_time,
      fact.outcome_id,
      fact.result_id,
      fact.reason_id,
      fact.created_by,
      fact.creation_date,
      fact.last_updated_by,
      fact.last_update_date,
      fact.emails_offered_in_period,
      fact.emails_fetched_in_period,
      fact.emails_replied_in_period,
      fact.emails_rpld_by_goal_in_period,
      fact.AGENT_EMAILS_RPLD_BY_GOAL,
      fact.emails_deleted_in_period,
      fact.emails_trnsfrd_out_in_period,
      fact.emails_trnsfrd_in_in_period,
      fact.emails_assigned_in_period,
      fact.emails_auto_routed_in_period,
      fact.emails_auto_uptd_sr_in_period,
      fact.email_resp_time_in_period,
      fact.agent_resp_time_in_period,
      fact.sr_created_in_period,
      fact.emails_rsl_and_trfd_in_period,
      fact.emails_orr_count_in_period,
      fact.EMAILS_AUTO_REPLIED_IN_PERIOD,
      fact.EMAILS_AUTO_DELETED_IN_PERIOD,
      fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,
      fact.emails_composed_in_period,
      fact.accumulated_open_emails,
      fact.accumulated_emails_in_queue,
      fact.accumulated_emails_one_day,
      fact.accumulated_emails_three_days,
      fact.accumulated_emails_week,
      fact.accumulated_emails_week_plus,
      fact.request_id,
      fact.program_application_id,
      fact.program_id,
      fact.program_update_date,
      fact.emails_rerouted_in_period,
      fact.leads_created_in_period )
    VALUES (
      change.email_account_id,
      change.email_classification_id,
      change.agent_id,
      change.party_id,
      change.time_id,
      change.period_type_id,
      change.period_start_date,
      change.period_start_time,
      change.outcome_id,
      change.result_id,
      change.reason_id,
      change.created_by,
      change.creation_date,
      change.last_updated_by,
      change.last_update_date,
      decode(change.emails_offered_in_period,0,to_number(null), change.emails_offered_in_period),
      decode(change.emails_fetched_in_period, 0,to_number(null),change.emails_fetched_in_period),
      decode(change.emails_replied_in_period, 0,to_number(null),change.emails_replied_in_period),
      decode(change.emails_rpld_by_goal_in_period, 0,to_number(null),change.emails_rpld_by_goal_in_period),
      decode(change.AGENT_EMAILS_RPLD_BY_GOAL, 0,to_number(null),change.AGENT_EMAILS_RPLD_BY_GOAL),
      decode(change.emails_deleted_in_period, 0,to_number(null),change.emails_deleted_in_period),
      decode(change.emails_trnsfrd_out_in_period, 0,to_number(null),change.emails_trnsfrd_out_in_period),
      decode(change.emails_trnsfrd_in_in_period, 0,to_number(null),change.emails_trnsfrd_in_in_period),
      decode(change.emails_assigned_in_period, 0,to_number(null),change.emails_assigned_in_period),
      decode(change.emails_auto_routed_in_period, 0,to_number(null),change.emails_auto_routed_in_period),
      decode(change.emails_auto_uptd_sr_in_period, 0,to_number(null),change.emails_auto_uptd_sr_in_period),
      decode(change.email_resp_time_in_period, 0,to_number(null),change.email_resp_time_in_period),
      decode(change.agent_resp_time_in_period, 0,to_number(null),change.agent_resp_time_in_period),
      decode(change.sr_created_in_period, 0,to_number(null),change.sr_created_in_period),
      decode(change.emails_rsl_and_trfd_in_period, 0,to_number(null),change.emails_rsl_and_trfd_in_period),
      decode(change.emails_orr_count_in_period, 0,to_number(null),change.emails_orr_count_in_period),
      decode(change.EMAILS_AUTO_REPLIED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_REPLIED_IN_PERIOD),
      decode(change.EMAILS_AUTO_DELETED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_DELETED_IN_PERIOD),
      decode(change.EMAILS_AUTO_RESOLVED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_RESOLVED_IN_PERIOD),
      decode(change.emails_composed_in_period, 0,to_number(null),change.emails_composed_in_period),
      decode(change.accumulated_open_emails, 0,to_number(null),change.accumulated_open_emails),
      decode(change.accumulated_emails_in_queue, 0,to_number(null),change.accumulated_emails_in_queue),
      decode(change.accumulated_emails_one_day, 0,to_number(null),change.accumulated_emails_one_day),
      decode(change.accumulated_emails_three_days, 0,to_number(null),change.accumulated_emails_three_days),
      decode(change.accumulated_emails_week, 0,to_number(null),change.accumulated_emails_week),
      decode(change.accumulated_emails_week_plus, 0,to_number(null),change.accumulated_emails_week_plus),
      change.request_id,
      change.program_application_id,
      change.program_id,
      change.program_update_date,
      decode(change.emails_rerouted_in_period, 0,to_number(null),change.emails_rerouted_in_period),
      decode(change.leads_created_in_period, 0,to_number(null),change.leads_created_in_period)
      );

write_log('Number of rows updated in table bix_email_details_stg for SR and leads created ' || to_char(SQL%ROWCOUNT));


MERGE INTO BIX_EMAIL_DETAILS_STG  fact
  USING
  (SELECT
      inv2.email_account_id
        email_account_id,
      inv2.email_classification_id
        email_classification_id,
      inv2.agent_id
        agent_id,
      inv2.party_id
        party_id,
      inv2.time_id
        time_id,
      1 period_type_id,
      inv2.period_start_date
        period_start_date,
      inv2.period_start_time
        period_start_time,
      inv2.outcome_id
        outcome_id,
      inv2.result_id
        result_id,
      inv2.reason_id
        reason_id,
      g_user_id
        created_by,
      g_sysdate
        creation_date,
      g_user_id
        last_updated_by,
      g_sysdate
        last_update_date,
      0
        emails_offered_in_period,
      0
        emails_fetched_in_period,
      0
        emails_replied_in_period,
      0
        emails_rpld_by_goal_in_period,
      0
        AGENT_EMAILS_RPLD_BY_GOAL,
      0
        emails_deleted_in_period,
      0
        emails_trnsfrd_out_in_period,
      0
        emails_trnsfrd_in_in_period,
      0
        emails_assigned_in_period,
      0
        emails_auto_routed_in_period,
      0
        emails_auto_uptd_sr_in_period,
      0
        email_resp_time_in_period,
      0
        agent_resp_time_in_period,
      0
        sr_created_in_period,
      decode(sum(inv2.emails_rsl_and_trfd_in_period), 0, to_number(null), sum(inv2.emails_rsl_and_trfd_in_period))
        emails_rsl_and_trfd_in_period,
      0
        EMAILS_AUTO_REPLIED_IN_PERIOD,
      0
        EMAILS_AUTO_DELETED_IN_PERIOD,
      0
        EMAILS_AUTO_RESOLVED_IN_PERIOD,
      0
        emails_composed_in_period,
      0
        emails_orr_count_in_period,
      0
        accumulated_open_emails,
      0
        accumulated_emails_in_queue,
      0
        accumulated_emails_one_day,
      0
        accumulated_emails_three_days,
      0
        accumulated_emails_week,
      0
        accumulated_emails_week_plus,
      0
       LEADS_CREATED_IN_PERIOD,
      0
        EMAILS_REROUTED_IN_PERIOD,
      g_request_id
        request_id,
      g_program_appl_id
        program_application_id,
      g_program_id
        program_id,
      g_sysdate
        program_update_date
   FROM
    (

	/* Query 4 */
SELECT
   EMAIL_ACCOUNT_ID,
      EMAIL_CLASSIFICATION_ID,
      AGENT_ID,
      PARTY_ID,
      PERIOD_START_DATE,
      TIME_ID,
      '00:00'                                              PERIOD_START_TIME,
      -1                                                   OUTCOME_ID,
      -1                                                   RESULT_ID,
      -1                                                   REASON_ID,
      0                                                    EMAILS_OFFERED_IN_PERIOD,
      0                                                    EMAILS_FETCHED_IN_PERIOD,
      0                                                    EMAILS_REPLIED_IN_PERIOD,
      0                                                    AGENT_RESP_TIME_IN_PERIOD,
      0                                                    EMAILS_RPLD_BY_GOAL_IN_PERIOD,
      0                                                    AGENT_EMAILS_RPLD_BY_GOAL,
      0                                                    EMAILS_TRNSFRD_OUT_IN_PERIOD,
      0                                                    EMAILS_TRNSFRD_IN_IN_PERIOD,
      0                                                    EMAILS_ASSIGNED_IN_PERIOD,
      0                                                    EMAILS_AUTO_ROUTED_IN_PERIOD,
      0                                                    EMAILS_AUTO_UPTD_SR_IN_PERIOD,
      0                                                    EMAILS_DELETED_IN_PERIOD,
      0                                                    EMAIL_RESP_TIME_IN_PERIOD,
      0                                                    SR_CREATED_IN_PERIOD,
      count(*)                                             EMAILS_RSL_AND_TRFD_IN_PERIOD,
      0                                                    EMAILS_AUTO_REPLIED_IN_PERIOD,
      0                                                    EMAILS_AUTO_DELETED_IN_PERIOD,
      0                                                    EMAILS_AUTO_RESOLVED_IN_PERIOD,
      0                                                    emails_composed_in_period,
      0                                                    emails_orr_count_in_period,
      0                                                    accumulated_open_emails,
      0                                                    accumulated_emails_in_queue,
      0                                                    accumulated_emails_one_day,
      0                                                    accumulated_emails_three_days,
      0                                                    accumulated_emails_week,
      0                                                    accumulated_emails_week_plus,
	 0                                                    EMAILS_REROUTED_IN_PERIOD,
	 0                                                    LEADS_CREATED_IN_PERIOD
	 FROM
(SELECT /*+ index (mseg jtf_ih_media_item_lc_segs_n3) use_nl(mseg mitm) */
      nvl(mitm.source_id, -1)                              EMAIL_ACCOUNT_ID,
      nvl(irc.route_classification_id, -1)                 EMAIL_CLASSIFICATION_ID,
      nvl(mseg.resource_id, -1)                            AGENT_ID,
	nvl((  SELECT
          distinct first_value(intr.party_id) over(order by actv.interaction_id desc) party_id
         FROM
           jtf_ih_activities actv,
           jtf_ih_interactions intr
         WHERE
         mitm.media_id = actv.media_id
        AND actv.interaction_id = intr.interaction_id
	), -1)                                     PARTY_ID,
      trunc(mseg.start_date_time)                          PERIOD_START_DATE,
      to_number(to_char(mseg.start_date_time, 'J'))        TIME_ID
     FROM
       JTF_IH_MEDIA_ITEMS mitm,
      JTF_IH_MEDIA_ITEM_LC_SEGS mseg,
      JTF_IH_MEDIA_ITM_LC_SEG_TYS mtyp,
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) irc
    WHERE mitm.MEDIA_ITEM_TYPE = 'EMAIL'
    AND   mitm.DIRECTION       = 'INBOUND'
    AND   mitm.classification  = irc.name(+)
    AND   mitm.MEDIA_ID        = mseg.MEDIA_ID
    AND   mseg.MILCS_TYPE_ID   = mtyp.MILCS_TYPE_ID
    AND   mtyp.MILCS_CODE      IN ('EMAIL_REPLY', 'EMAIL_DELETED')
    AND   mseg.START_DATE_TIME BETWEEN  g_collect_start_date and g_collect_end_date
    AND   EXISTS (
            SELECT
                   1
            FROM
                   jtf_ih_media_item_lc_segs mseg1,
                   jtf_ih_media_itm_lc_seg_tys mtys1
            WHERE mseg1.media_id = mitm.media_id
            AND   mtys1.milcs_type_id = mseg1.milcs_type_id
            AND   mtys1.milcs_code IN ( 'EMAIL_TRANSFERRED','EMAIL_ESCALATED') )
	    )
  GROUP BY
	 EMAIL_ACCOUNT_ID,
      EMAIL_CLASSIFICATION_ID,
      AGENT_ID,
      PARTY_ID,
      PERIOD_START_DATE,
      TIME_ID
)inv2
GROUP BY
      inv2.email_account_id,
      inv2.email_classification_id,
      inv2.agent_id,
      inv2.party_id,
      inv2.time_id,
      inv2.period_start_date,
      inv2.period_start_time,
      inv2.outcome_id,
      inv2.result_id,
      inv2.reason_id
)  change
  ON (
      fact.email_account_id = change.email_account_id
      AND fact.email_classification_id = change.email_classification_id
      AND fact.agent_id = change.agent_id
      AND fact.party_id = change.party_id
      AND fact.time_id = change.time_id
      AND fact.period_type_id = change.period_type_id
      AND fact.period_start_date = change.period_start_date
      AND fact.period_start_time = change.period_start_time
      AND fact.outcome_id = change.outcome_id
      AND fact.result_id = change.result_id
      AND fact.reason_id = change.reason_id )
  WHEN MATCHED THEN
    UPDATE
      SET fact.emails_offered_in_period = DECODE(nvl(fact.emails_offered_in_period,0) + nvl(change.emails_offered_in_period,0),
             0, NULL, nvl(fact.emails_offered_in_period,0) + nvl(change.emails_offered_in_period,0))
      ,fact.emails_fetched_in_period = DECODE(nvl(fact.emails_fetched_in_period,0) + nvl(change.emails_fetched_in_period,0),
             0, NULL, nvl(fact.emails_fetched_in_period,0) + nvl(change.emails_fetched_in_period,0))
      ,fact.emails_replied_in_period = DECODE(nvl(fact.emails_replied_in_period,0) + nvl(change.emails_replied_in_period,0),
             0, NULL, nvl(fact.emails_replied_in_period,0) + nvl(change.emails_replied_in_period,0))
      ,fact.emails_rpld_by_goal_in_period = DECODE(nvl(fact.emails_rpld_by_goal_in_period,0) + nvl(change.emails_rpld_by_goal_in_period,
             0), 0, NULL, nvl(fact.emails_rpld_by_goal_in_period,0) + nvl(change.emails_rpld_by_goal_in_period,0))
      ,fact.AGENT_EMAILS_RPLD_BY_GOAL = DECODE(nvl(fact.AGENT_EMAILS_RPLD_BY_GOAL,0) + nvl(change.AGENT_EMAILS_RPLD_BY_GOAL,
                   0), 0, NULL, nvl(fact.AGENT_EMAILS_RPLD_BY_GOAL,0) + nvl(change.AGENT_EMAILS_RPLD_BY_GOAL,0))
      ,fact.emails_deleted_in_period = DECODE(nvl(fact.emails_deleted_in_period,0) + nvl(change.emails_deleted_in_period,0), 0, NULL,
             nvl(fact.emails_deleted_in_period,0) + nvl(change.emails_deleted_in_period,0))
      ,fact.emails_trnsfrd_out_in_period = DECODE(nvl(fact.emails_trnsfrd_out_in_period,0) + nvl(change.emails_trnsfrd_out_in_period,0),
             0, NULL, nvl(fact.emails_trnsfrd_out_in_period,0) + nvl(change.emails_trnsfrd_out_in_period,0))
      ,fact.emails_trnsfrd_in_in_period = DECODE(nvl(fact.emails_trnsfrd_in_in_period,0) + nvl(change.emails_trnsfrd_in_in_period,0),
             0, NULL, nvl(fact.emails_trnsfrd_in_in_period,0) + nvl(change.emails_trnsfrd_in_in_period,0))
      ,fact.emails_assigned_in_period = DECODE(nvl(fact.emails_assigned_in_period,0) + nvl(change.emails_assigned_in_period,0),
             0, NULL, nvl(fact.emails_assigned_in_period,0) + nvl(change.emails_assigned_in_period,0))
      ,fact.emails_auto_routed_in_period = DECODE(nvl(fact.emails_auto_routed_in_period,0) + nvl(change.emails_auto_routed_in_period,0),
             0, NULL, nvl(fact.emails_auto_routed_in_period,0) + nvl(change.emails_auto_routed_in_period,0))
      ,fact.emails_auto_uptd_sr_in_period = DECODE(nvl(fact.emails_auto_uptd_sr_in_period,0) + nvl(change.emails_auto_uptd_sr_in_period,0),
             0, NULL, nvl(fact.emails_auto_uptd_sr_in_period,0) + nvl(change.emails_auto_uptd_sr_in_period,0))
      ,fact.email_resp_time_in_period = DECODE(nvl(fact.email_resp_time_in_period,0) + nvl(change.email_resp_time_in_period,0),
             0, NULL, nvl(fact.email_resp_time_in_period,0) + nvl(change.email_resp_time_in_period,0))
      ,fact.agent_resp_time_in_period = DECODE(nvl(fact.agent_resp_time_in_period,0) + nvl(change.agent_resp_time_in_period,0),
             0, NULL, nvl(fact.agent_resp_time_in_period,0) + nvl(change.agent_resp_time_in_period,0))
      ,fact.sr_created_in_period = DECODE(nvl(fact.sr_created_in_period,0) + nvl(change.sr_created_in_period,0),
             0, NULL, nvl(fact.sr_created_in_period,0) + nvl(change.sr_created_in_period,0))
      ,fact.emails_rsl_and_trfd_in_period = DECODE(nvl(fact.emails_rsl_and_trfd_in_period,0) + nvl(change.emails_rsl_and_trfd_in_period,0),
             0, NULL, nvl(fact.emails_rsl_and_trfd_in_period,0) + nvl(change.emails_rsl_and_trfd_in_period,0))
      ,fact.emails_orr_count_in_period = DECODE(nvl(fact.emails_orr_count_in_period,0) + nvl(change.emails_orr_count_in_period,0),
             0, NULL, nvl(fact.emails_orr_count_in_period,0) + nvl(change.emails_orr_count_in_period,0))
      ,fact.EMAILS_AUTO_REPLIED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0),
             0, NULL, nvl(fact.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0))
      ,fact.EMAILS_AUTO_DELETED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_DELETED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_DELETED_IN_PERIOD,0),
             0, NULL, nvl(fact.EMAILS_AUTO_DELETED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_DELETED_IN_PERIOD,0))
      ,fact.EMAILS_AUTO_RESOLVED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,
             0), 0, NULL, nvl(fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,0))
      ,fact.emails_composed_in_period = DECODE(nvl(fact.emails_composed_in_period,0) + nvl(change.emails_composed_in_period,0),
             0, NULL, nvl(fact.emails_composed_in_period,0) + nvl(change.emails_composed_in_period,0))
--
--Note that accumulated measures are not added together - they are replaced by the new
--calculated value as they are not additive.
--
      ,fact.accumulated_open_emails = decode(change.accumulated_open_emails,0,to_number(NULL),change.accumulated_open_emails)
      ,fact.accumulated_emails_in_queue = decode(change.accumulated_emails_in_queue,0,to_number(NULL),change.accumulated_emails_in_queue)
      ,fact.accumulated_emails_one_day = decode(change.accumulated_emails_one_day,0,to_number(NULL),change.accumulated_emails_one_day)
      ,fact.accumulated_emails_three_days = decode(change.accumulated_emails_three_days,0,to_number(NULL),change.accumulated_emails_three_days)
      ,fact.accumulated_emails_week = decode(change.accumulated_emails_week,0,to_number(NULL),change.accumulated_emails_week)
      ,fact.accumulated_emails_week_plus = decode(change.accumulated_emails_week_plus,0,to_number(NULL),change.accumulated_emails_week_plus)
      ,fact.last_updated_by = change.last_updated_by
      ,fact.last_update_date = change.last_update_date
      ,fact.emails_rerouted_in_period = DECODE(nvl(fact.emails_rerouted_in_period,0) + nvl(change.emails_rerouted_in_period,0),
             0, NULL, nvl(fact.emails_rerouted_in_period,0) + nvl(change.emails_rerouted_in_period,0))
      ,fact.leads_created_in_period = DECODE(nvl(fact.leads_created_in_period,0) + nvl(change.leads_created_in_period,0),
             0, NULL, nvl(fact.leads_created_in_period,0) + nvl(change.leads_created_in_period,0))
  WHEN NOT MATCHED THEN
    INSERT (
      fact.email_account_id,
      fact.email_classification_id,
      fact.agent_id,
      fact.party_id,
      fact.time_id,
      fact.period_type_id,
      fact.period_start_date,
      fact.period_start_time,
      fact.outcome_id,
      fact.result_id,
      fact.reason_id,
      fact.created_by,
      fact.creation_date,
      fact.last_updated_by,
      fact.last_update_date,
      fact.emails_offered_in_period,
      fact.emails_fetched_in_period,
      fact.emails_replied_in_period,
      fact.emails_rpld_by_goal_in_period,
      fact.AGENT_EMAILS_RPLD_BY_GOAL,
      fact.emails_deleted_in_period,
      fact.emails_trnsfrd_out_in_period,
      fact.emails_trnsfrd_in_in_period,
      fact.emails_assigned_in_period,
      fact.emails_auto_routed_in_period,
      fact.emails_auto_uptd_sr_in_period,
      fact.email_resp_time_in_period,
      fact.agent_resp_time_in_period,
      fact.sr_created_in_period,
      fact.emails_rsl_and_trfd_in_period,
      fact.emails_orr_count_in_period,
      fact.EMAILS_AUTO_REPLIED_IN_PERIOD,
      fact.EMAILS_AUTO_DELETED_IN_PERIOD,
      fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,
      fact.emails_composed_in_period,
      fact.accumulated_open_emails,
      fact.accumulated_emails_in_queue,
      fact.accumulated_emails_one_day,
      fact.accumulated_emails_three_days,
      fact.accumulated_emails_week,
      fact.accumulated_emails_week_plus,
      fact.request_id,
      fact.program_application_id,
      fact.program_id,
      fact.program_update_date,
      fact.emails_rerouted_in_period,
      fact.leads_created_in_period )
    VALUES (
      change.email_account_id,
      change.email_classification_id,
      change.agent_id,
      change.party_id,
      change.time_id,
      change.period_type_id,
      change.period_start_date,
      change.period_start_time,
      change.outcome_id,
      change.result_id,
      change.reason_id,
      change.created_by,
      change.creation_date,
      change.last_updated_by,
      change.last_update_date,
      decode(change.emails_offered_in_period,0,to_number(null), change.emails_offered_in_period),
      decode(change.emails_fetched_in_period, 0,to_number(null),change.emails_fetched_in_period),
      decode(change.emails_replied_in_period, 0,to_number(null),change.emails_replied_in_period),
      decode(change.emails_rpld_by_goal_in_period, 0,to_number(null),change.emails_rpld_by_goal_in_period),
      decode(change.AGENT_EMAILS_RPLD_BY_GOAL, 0,to_number(null),change.AGENT_EMAILS_RPLD_BY_GOAL),
      decode(change.emails_deleted_in_period, 0,to_number(null),change.emails_deleted_in_period),
      decode(change.emails_trnsfrd_out_in_period, 0,to_number(null),change.emails_trnsfrd_out_in_period),
      decode(change.emails_trnsfrd_in_in_period, 0,to_number(null),change.emails_trnsfrd_in_in_period),
      decode(change.emails_assigned_in_period, 0,to_number(null),change.emails_assigned_in_period),
      decode(change.emails_auto_routed_in_period, 0,to_number(null),change.emails_auto_routed_in_period),
      decode(change.emails_auto_uptd_sr_in_period, 0,to_number(null),change.emails_auto_uptd_sr_in_period),
      decode(change.email_resp_time_in_period, 0,to_number(null),change.email_resp_time_in_period),
      decode(change.agent_resp_time_in_period, 0,to_number(null),change.agent_resp_time_in_period),
      decode(change.sr_created_in_period, 0,to_number(null),change.sr_created_in_period),
      decode(change.emails_rsl_and_trfd_in_period, 0,to_number(null),change.emails_rsl_and_trfd_in_period),
      decode(change.emails_orr_count_in_period, 0,to_number(null),change.emails_orr_count_in_period),
      decode(change.EMAILS_AUTO_REPLIED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_REPLIED_IN_PERIOD),
      decode(change.EMAILS_AUTO_DELETED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_DELETED_IN_PERIOD),
      decode(change.EMAILS_AUTO_RESOLVED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_RESOLVED_IN_PERIOD),
      decode(change.emails_composed_in_period, 0,to_number(null),change.emails_composed_in_period),
      decode(change.accumulated_open_emails, 0,to_number(null),change.accumulated_open_emails),
      decode(change.accumulated_emails_in_queue, 0,to_number(null),change.accumulated_emails_in_queue),
      decode(change.accumulated_emails_one_day, 0,to_number(null),change.accumulated_emails_one_day),
      decode(change.accumulated_emails_three_days, 0,to_number(null),change.accumulated_emails_three_days),
      decode(change.accumulated_emails_week, 0,to_number(null),change.accumulated_emails_week),
      decode(change.accumulated_emails_week_plus, 0,to_number(null),change.accumulated_emails_week_plus),
      change.request_id,
      change.program_application_id,
      change.program_id,
      change.program_update_date,
      decode(change.emails_rerouted_in_period, 0,to_number(null),change.emails_rerouted_in_period),
      decode(change.leads_created_in_period, 0,to_number(null),change.leads_created_in_period)
      );

write_log('Number of rows updated in table bix_email_details_stg for Emails Resolved and Transferred in period ' || to_char(SQL%ROWCOUNT));





MERGE INTO BIX_EMAIL_DETAILS_STG  fact
  USING
  (SELECT
      inv2.email_account_id
        email_account_id,
      inv2.email_classification_id
        email_classification_id,
      inv2.agent_id
        agent_id,
      inv2.party_id
        party_id,
      inv2.time_id
        time_id,
      1 period_type_id,
      inv2.period_start_date
        period_start_date,
      inv2.period_start_time
        period_start_time,
      inv2.outcome_id
        outcome_id,
      inv2.result_id
        result_id,
      inv2.reason_id
        reason_id,
      g_user_id
        created_by,
      g_sysdate
        creation_date,
      g_user_id
        last_updated_by,
      g_sysdate
        last_update_date,
   0
        emails_offered_in_period,
   0
        emails_fetched_in_period,
   0
        emails_replied_in_period,
   0
        emails_rpld_by_goal_in_period,
   0
        AGENT_EMAILS_RPLD_BY_GOAL,
   0
        emails_deleted_in_period,
   0
        emails_trnsfrd_out_in_period,
   0
        emails_trnsfrd_in_in_period,
   0
      emails_assigned_in_period,
   0
        emails_auto_routed_in_period,
   0
        emails_auto_uptd_sr_in_period,
   0
        email_resp_time_in_period,
   0
        agent_resp_time_in_period,
   0
        sr_created_in_period,
   0
        emails_rsl_and_trfd_in_period,
   0
        EMAILS_AUTO_REPLIED_IN_PERIOD,
   0
        EMAILS_AUTO_DELETED_IN_PERIOD,
   0
        EMAILS_AUTO_RESOLVED_IN_PERIOD,
   0
        emails_composed_in_period,
      decode(sum(emails_orr_count_in_period), 0, to_number(null), sum(emails_orr_count_in_period))
        emails_orr_count_in_period,
   0
        accumulated_open_emails,
   0
        accumulated_emails_in_queue,
   0
      accumulated_emails_one_day,
   0
        accumulated_emails_three_days,
   0
      accumulated_emails_week,
   0
        accumulated_emails_week_plus,
   0
       LEADS_CREATED_IN_PERIOD,
   0
        EMAILS_REROUTED_IN_PERIOD,
      g_request_id
        request_id,
      g_program_appl_id
        program_application_id,
      g_program_id
        program_id,
      g_sysdate
        program_update_date
   FROM
    (

/* Query 5 */
SELECT
      nvl(email_account_id, -1)                              EMAIL_ACCOUNT_ID,
      nvl(email_classification_id, -1)                 EMAIL_CLASSIFICATION_ID,
      nvl(agent_id, -1)                            AGENT_ID,
      nvl(party_id, -1)                               PARTY_ID,
      trunc(period_start_date)                         PERIOD_START_DATE,
      time_id        TIME_ID,
      '00:00'                                              PERIOD_START_TIME,
      NVL(outcome_id,-1)                              OUTCOME_ID,
      NVL(result_id,-1)                               RESULT_ID,
      NVL(reason_id,-1)                               REASON_ID,
      0                                                    EMAILS_OFFERED_IN_PERIOD,
      0                                                    EMAILS_FETCHED_IN_PERIOD,
      0                                                    EMAILS_REPLIED_IN_PERIOD,
      0                                                    AGENT_RESP_TIME_IN_PERIOD,
      0                                                    EMAILS_RPLD_BY_GOAL_IN_PERIOD,
      0                                                    AGENT_EMAILS_RPLD_BY_GOAL,
      0                                                    EMAILS_TRNSFRD_OUT_IN_PERIOD,
      0                                                    EMAILS_TRNSFRD_IN_IN_PERIOD,
      0                                                    EMAILS_ASSIGNED_IN_PERIOD,
      0                                                    EMAILS_AUTO_ROUTED_IN_PERIOD,
      0                                                    EMAILS_AUTO_UPTD_SR_IN_PERIOD,
      0                                                    EMAILS_DELETED_IN_PERIOD,
      0                                                    EMAIL_RESP_TIME_IN_PERIOD,
      0                                                    SR_CREATED_IN_PERIOD,
      0                                                    EMAILS_RSL_AND_TRFD_IN_PERIOD,
      0                                                    EMAILS_AUTO_REPLIED_IN_PERIOD,
      0                                                    EMAILS_AUTO_DELETED_IN_PERIOD,
      0                                                    EMAILS_AUTO_RESOLVED_IN_PERIOD,
      0                                                    emails_composed_in_period,
      COUNT(DISTINCT interaction_id)                  emails_orr_count_in_period,
      0                                                    accumulated_open_emails,
      0                                                    accumulated_emails_in_queue,
      0                                                    accumulated_emails_one_day,
      0                                                    accumulated_emails_three_days,
      0                                                    accumulated_emails_week,
      0                                                    accumulated_emails_week_plus,
         0                                                    EMAILS_REROUTED_IN_PERIOD,
         0                                                    LEADS_CREATED_IN_PERIOD
FROM
(
SELECT /*+ use_nl(intr,actv,mitm) */
nvl(mitm.source_id, -1)                              EMAIL_ACCOUNT_ID,
      nvl(irc.route_classification_id, -1)                 EMAIL_CLASSIFICATION_ID,
      nvl(intr.resource_id, -1)                            AGENT_ID,
      nvl(first_value(intr.party_id)
          over(partition by actv.media_id
               order by actv.interaction_id desc
              ),
          -1)                                              PARTY_ID,
      trunc(intr.last_update_date)                         PERIOD_START_DATE,
      to_number(to_char(intr.last_update_date, 'J'))       TIME_ID,
      NVL(intr.outcome_id,-1)                              OUTCOME_ID,
      NVL(intr.result_id,-1)                               RESULT_ID,
      NVL(intr.reason_id,-1)                               REASON_ID,
      intr.interaction_id                                  INTERACTION_ID
     FROM
      JTF_IH_MEDIA_ITEMS mitm,
      JTF_IH_ACTIVITIES actv,
      JTF_IH_INTERACTIONS intr,
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) irc
    WHERE mitm.MEDIA_ITEM_TYPE = 'EMAIL'
    AND   mitm.direction = 'INBOUND'
    AND   mitm.classification  = irc.name(+)
    AND   mitm.media_id        = actv.media_id
    AND   actv.interaction_id  = intr.interaction_id
    AND   intr.LAST_UPDATE_DATE BETWEEN  g_collect_start_date and g_collect_end_date
    AND   intr.outcome_id IS NOT NULL
)
    GROUP BY
      nvl(email_account_id, -1),
      nvl(email_classification_id, -1),
      nvl(agent_id, -1),
      nvl(party_id, -1),
      trunc(period_start_date),
      time_id,
      NVL(outcome_id,-1),
      NVL(result_id,-1),
      NVL(reason_id,-1)

)inv2
GROUP BY
      inv2.email_account_id,
      inv2.email_classification_id,
      inv2.agent_id,
      inv2.party_id,
      inv2.time_id,
      inv2.period_start_date,
      inv2.period_start_time,
      inv2.outcome_id,
      inv2.result_id,
      inv2.reason_id
)  change
  ON (
      fact.email_account_id = change.email_account_id
      AND fact.email_classification_id = change.email_classification_id
      AND fact.agent_id = change.agent_id
      AND fact.party_id = change.party_id
      AND fact.time_id = change.time_id
      AND fact.period_type_id = change.period_type_id
      AND fact.period_start_date = change.period_start_date
      AND fact.period_start_time = change.period_start_time
      AND fact.outcome_id = change.outcome_id
      AND fact.result_id = change.result_id
      AND fact.reason_id = change.reason_id )
  WHEN MATCHED THEN
    UPDATE
      SET fact.emails_offered_in_period = DECODE(nvl(fact.emails_offered_in_period,0) + nvl(change.emails_offered_in_period,0),
             0, NULL, nvl(fact.emails_offered_in_period,0) + nvl(change.emails_offered_in_period,0))
      ,fact.emails_fetched_in_period = DECODE(nvl(fact.emails_fetched_in_period,0) + nvl(change.emails_fetched_in_period,0),
             0, NULL, nvl(fact.emails_fetched_in_period,0) + nvl(change.emails_fetched_in_period,0))
      ,fact.emails_replied_in_period = DECODE(nvl(fact.emails_replied_in_period,0) + nvl(change.emails_replied_in_period,0),
             0, NULL, nvl(fact.emails_replied_in_period,0) + nvl(change.emails_replied_in_period,0))
      ,fact.emails_rpld_by_goal_in_period = DECODE(nvl(fact.emails_rpld_by_goal_in_period,0) + nvl(change.emails_rpld_by_goal_in_period,
             0), 0, NULL, nvl(fact.emails_rpld_by_goal_in_period,0) + nvl(change.emails_rpld_by_goal_in_period,0))
      ,fact.AGENT_EMAILS_RPLD_BY_GOAL = DECODE(nvl(fact.AGENT_EMAILS_RPLD_BY_GOAL,0) + nvl(change.AGENT_EMAILS_RPLD_BY_GOAL,
                   0), 0, NULL, nvl(fact.AGENT_EMAILS_RPLD_BY_GOAL,0) + nvl(change.AGENT_EMAILS_RPLD_BY_GOAL,0))
      ,fact.emails_deleted_in_period = DECODE(nvl(fact.emails_deleted_in_period,0) + nvl(change.emails_deleted_in_period,0), 0, NULL,
             nvl(fact.emails_deleted_in_period,0) + nvl(change.emails_deleted_in_period,0))
      ,fact.emails_trnsfrd_out_in_period = DECODE(nvl(fact.emails_trnsfrd_out_in_period,0) + nvl(change.emails_trnsfrd_out_in_period,0),
             0, NULL, nvl(fact.emails_trnsfrd_out_in_period,0) + nvl(change.emails_trnsfrd_out_in_period,0))
      ,fact.emails_trnsfrd_in_in_period = DECODE(nvl(fact.emails_trnsfrd_in_in_period,0) + nvl(change.emails_trnsfrd_in_in_period,0),
             0, NULL, nvl(fact.emails_trnsfrd_in_in_period,0) + nvl(change.emails_trnsfrd_in_in_period,0))
      ,fact.emails_assigned_in_period = DECODE(nvl(fact.emails_assigned_in_period,0) + nvl(change.emails_assigned_in_period,0),
             0, NULL, nvl(fact.emails_assigned_in_period,0) + nvl(change.emails_assigned_in_period,0))
      ,fact.emails_auto_routed_in_period = DECODE(nvl(fact.emails_auto_routed_in_period,0) + nvl(change.emails_auto_routed_in_period,0),
             0, NULL, nvl(fact.emails_auto_routed_in_period,0) + nvl(change.emails_auto_routed_in_period,0))
      ,fact.emails_auto_uptd_sr_in_period = DECODE(nvl(fact.emails_auto_uptd_sr_in_period,0) + nvl(change.emails_auto_uptd_sr_in_period,0),
             0, NULL, nvl(fact.emails_auto_uptd_sr_in_period,0) + nvl(change.emails_auto_uptd_sr_in_period,0))
      ,fact.email_resp_time_in_period = DECODE(nvl(fact.email_resp_time_in_period,0) + nvl(change.email_resp_time_in_period,0),
             0, NULL, nvl(fact.email_resp_time_in_period,0) + nvl(change.email_resp_time_in_period,0))
      ,fact.agent_resp_time_in_period = DECODE(nvl(fact.agent_resp_time_in_period,0) + nvl(change.agent_resp_time_in_period,0),
             0, NULL, nvl(fact.agent_resp_time_in_period,0) + nvl(change.agent_resp_time_in_period,0))
      ,fact.sr_created_in_period = DECODE(nvl(fact.sr_created_in_period,0) + nvl(change.sr_created_in_period,0),
             0, NULL, nvl(fact.sr_created_in_period,0) + nvl(change.sr_created_in_period,0))
      ,fact.emails_rsl_and_trfd_in_period = DECODE(nvl(fact.emails_rsl_and_trfd_in_period,0) + nvl(change.emails_rsl_and_trfd_in_period,0),
             0, NULL, nvl(fact.emails_rsl_and_trfd_in_period,0) + nvl(change.emails_rsl_and_trfd_in_period,0))
      ,fact.emails_orr_count_in_period = DECODE(nvl(fact.emails_orr_count_in_period,0) + nvl(change.emails_orr_count_in_period,0),
             0, NULL, nvl(fact.emails_orr_count_in_period,0) + nvl(change.emails_orr_count_in_period,0))
      ,fact.EMAILS_AUTO_REPLIED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0),
             0, NULL, nvl(fact.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0))
      ,fact.EMAILS_AUTO_DELETED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_DELETED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_DELETED_IN_PERIOD,0),
             0, NULL, nvl(fact.EMAILS_AUTO_DELETED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_DELETED_IN_PERIOD,0))
      ,fact.EMAILS_AUTO_RESOLVED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,
             0), 0, NULL, nvl(fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,0))
      ,fact.emails_composed_in_period = DECODE(nvl(fact.emails_composed_in_period,0) + nvl(change.emails_composed_in_period,0),
             0, NULL, nvl(fact.emails_composed_in_period,0) + nvl(change.emails_composed_in_period,0))
--
--Note that accumulated measures are not added together - they are replaced by the new
--calculated value as they are not additive.
--
      ,fact.accumulated_open_emails = decode(change.accumulated_open_emails,0,to_number(NULL),change.accumulated_open_emails)
      ,fact.accumulated_emails_in_queue = decode(change.accumulated_emails_in_queue,0,to_number(NULL),change.accumulated_emails_in_queue)
      ,fact.accumulated_emails_one_day = decode(change.accumulated_emails_one_day,0,to_number(NULL),change.accumulated_emails_one_day)
      ,fact.accumulated_emails_three_days = decode(change.accumulated_emails_three_days,0,to_number(NULL),change.accumulated_emails_three_days)
      ,fact.accumulated_emails_week = decode(change.accumulated_emails_week,0,to_number(NULL),change.accumulated_emails_week)
      ,fact.accumulated_emails_week_plus = decode(change.accumulated_emails_week_plus,0,to_number(NULL),change.accumulated_emails_week_plus)
      ,fact.last_updated_by = change.last_updated_by
      ,fact.last_update_date = change.last_update_date
      ,fact.emails_rerouted_in_period = DECODE(nvl(fact.emails_rerouted_in_period,0) + nvl(change.emails_rerouted_in_period,0),
             0, NULL, nvl(fact.emails_rerouted_in_period,0) + nvl(change.emails_rerouted_in_period,0))
      ,fact.leads_created_in_period = DECODE(nvl(fact.leads_created_in_period,0) + nvl(change.leads_created_in_period,0),
             0, NULL, nvl(fact.leads_created_in_period,0) + nvl(change.leads_created_in_period,0))
  WHEN NOT MATCHED THEN
    INSERT (
      fact.email_account_id,
      fact.email_classification_id,
      fact.agent_id,
      fact.party_id,
      fact.time_id,
      fact.period_type_id,
      fact.period_start_date,
      fact.period_start_time,
      fact.outcome_id,
      fact.result_id,
      fact.reason_id,
      fact.created_by,
      fact.creation_date,
      fact.last_updated_by,
      fact.last_update_date,
      fact.emails_offered_in_period,
      fact.emails_fetched_in_period,
      fact.emails_replied_in_period,
      fact.emails_rpld_by_goal_in_period,
      fact.AGENT_EMAILS_RPLD_BY_GOAL,
      fact.emails_deleted_in_period,
      fact.emails_trnsfrd_out_in_period,
      fact.emails_trnsfrd_in_in_period,
      fact.emails_assigned_in_period,
      fact.emails_auto_routed_in_period,
      fact.emails_auto_uptd_sr_in_period,
      fact.email_resp_time_in_period,
      fact.agent_resp_time_in_period,
      fact.sr_created_in_period,
      fact.emails_rsl_and_trfd_in_period,
      fact.emails_orr_count_in_period,
      fact.EMAILS_AUTO_REPLIED_IN_PERIOD,
      fact.EMAILS_AUTO_DELETED_IN_PERIOD,
      fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,
      fact.emails_composed_in_period,
      fact.accumulated_open_emails,
      fact.accumulated_emails_in_queue,
      fact.accumulated_emails_one_day,
      fact.accumulated_emails_three_days,
      fact.accumulated_emails_week,
      fact.accumulated_emails_week_plus,
      fact.request_id,
      fact.program_application_id,
      fact.program_id,
      fact.program_update_date,
      fact.emails_rerouted_in_period,
      fact.leads_created_in_period )
    VALUES (
      change.email_account_id,
      change.email_classification_id,
      change.agent_id,
      change.party_id,
      change.time_id,
      change.period_type_id,
      change.period_start_date,
      change.period_start_time,
      change.outcome_id,
      change.result_id,
      change.reason_id,
      change.created_by,
      change.creation_date,
      change.last_updated_by,
      change.last_update_date,
      decode(change.emails_offered_in_period,0,to_number(null), change.emails_offered_in_period),
      decode(change.emails_fetched_in_period, 0,to_number(null),change.emails_fetched_in_period),
      decode(change.emails_replied_in_period, 0,to_number(null),change.emails_replied_in_period),
      decode(change.emails_rpld_by_goal_in_period, 0,to_number(null),change.emails_rpld_by_goal_in_period),
      decode(change.AGENT_EMAILS_RPLD_BY_GOAL, 0,to_number(null),change.AGENT_EMAILS_RPLD_BY_GOAL),
      decode(change.emails_deleted_in_period, 0,to_number(null),change.emails_deleted_in_period),
      decode(change.emails_trnsfrd_out_in_period, 0,to_number(null),change.emails_trnsfrd_out_in_period),
      decode(change.emails_trnsfrd_in_in_period, 0,to_number(null),change.emails_trnsfrd_in_in_period),
      decode(change.emails_assigned_in_period, 0,to_number(null),change.emails_assigned_in_period),
      decode(change.emails_auto_routed_in_period, 0,to_number(null),change.emails_auto_routed_in_period),
      decode(change.emails_auto_uptd_sr_in_period, 0,to_number(null),change.emails_auto_uptd_sr_in_period),
      decode(change.email_resp_time_in_period, 0,to_number(null),change.email_resp_time_in_period),
      decode(change.agent_resp_time_in_period, 0,to_number(null),change.agent_resp_time_in_period),
      decode(change.sr_created_in_period, 0,to_number(null),change.sr_created_in_period),
      decode(change.emails_rsl_and_trfd_in_period, 0,to_number(null),change.emails_rsl_and_trfd_in_period),
      decode(change.emails_orr_count_in_period, 0,to_number(null),change.emails_orr_count_in_period),
      decode(change.EMAILS_AUTO_REPLIED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_REPLIED_IN_PERIOD),
      decode(change.EMAILS_AUTO_DELETED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_DELETED_IN_PERIOD),
      decode(change.EMAILS_AUTO_RESOLVED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_RESOLVED_IN_PERIOD),
      decode(change.emails_composed_in_period, 0,to_number(null),change.emails_composed_in_period),
      decode(change.accumulated_open_emails, 0,to_number(null),change.accumulated_open_emails),
      decode(change.accumulated_emails_in_queue, 0,to_number(null),change.accumulated_emails_in_queue),
      decode(change.accumulated_emails_one_day, 0,to_number(null),change.accumulated_emails_one_day),
      decode(change.accumulated_emails_three_days, 0,to_number(null),change.accumulated_emails_three_days),
      decode(change.accumulated_emails_week, 0,to_number(null),change.accumulated_emails_week),
      decode(change.accumulated_emails_week_plus, 0,to_number(null),change.accumulated_emails_week_plus),
      change.request_id,
      change.program_application_id,
      change.program_id,
      change.program_update_date,
      decode(change.emails_rerouted_in_period, 0,to_number(null),change.emails_rerouted_in_period),
      decode(change.leads_created_in_period, 0,to_number(null),change.leads_created_in_period)
      );

write_log('Number of rows updated in table bix_email_details_stg for Emails ORR count  ' || to_char(SQL%ROWCOUNT));



MERGE INTO BIX_EMAIL_DETAILS_STG  fact
  USING
  (SELECT
      inv2.email_account_id
        email_account_id,
      inv2.email_classification_id
        email_classification_id,
      inv2.agent_id
        agent_id,
      inv2.party_id
        party_id,
      inv2.time_id
        time_id,
      1 period_type_id,
      inv2.period_start_date
        period_start_date,
      inv2.period_start_time
        period_start_time,
      inv2.outcome_id
        outcome_id,
      inv2.result_id
        result_id,
      inv2.reason_id
        reason_id,
      g_user_id
        created_by,
      g_sysdate
        creation_date,
      g_user_id
        last_updated_by,
      g_sysdate
        last_update_date,
      decode(sum(inv2.emails_offered_in_period), 0, to_number(null), sum(inv2.emails_offered_in_period))
        emails_offered_in_period,
      decode(sum(inv2.emails_fetched_in_period), 0, to_number(null), sum(inv2.emails_fetched_in_period))
        emails_fetched_in_period,
      decode(sum(inv2.emails_replied_in_period), 0, to_number(null), sum(inv2.emails_replied_in_period))
        emails_replied_in_period,
      decode(sum(inv2.emails_rpld_by_goal_in_period), 0, to_number(null), sum(inv2.emails_rpld_by_goal_in_period))
        emails_rpld_by_goal_in_period,
      decode(sum(inv2.AGENT_EMAILS_RPLD_BY_GOAL), 0, to_number(null), sum(inv2.AGENT_EMAILS_RPLD_BY_GOAL))
        AGENT_EMAILS_RPLD_BY_GOAL,
      decode(sum(inv2.emails_deleted_in_period), 0, to_number(null), sum(inv2.emails_deleted_in_period))
        emails_deleted_in_period,
      decode(sum(inv2.emails_trnsfrd_out_in_period), 0, to_number(null), sum(inv2.emails_trnsfrd_out_in_period))
        emails_trnsfrd_out_in_period,
      decode(sum(inv2.emails_trnsfrd_in_in_period), 0, to_number(null), sum(inv2.emails_trnsfrd_in_in_period))
        emails_trnsfrd_in_in_period,
      decode(sum(inv2.emails_assigned_in_period), 0, to_number(null), sum(inv2.emails_assigned_in_period))
        emails_assigned_in_period,
      decode(sum(inv2.emails_auto_routed_in_period), 0, to_number(null), sum(inv2.emails_auto_routed_in_period))
        emails_auto_routed_in_period,
      decode(sum(inv2.emails_auto_uptd_sr_in_period), 0, to_number(null), sum(inv2.emails_auto_uptd_sr_in_period))
        emails_auto_uptd_sr_in_period,
      decode(round(sum(inv2.email_resp_time_in_period)), 0, to_number(null), round(sum(inv2.email_resp_time_in_period)))
        email_resp_time_in_period,
      decode(round(sum(inv2.agent_resp_time_in_period)), 0, to_number(null), round(sum(inv2.agent_resp_time_in_period)))
        agent_resp_time_in_period,
      decode(sum(inv2.sr_created_in_period), 0, to_number(null), sum(inv2.sr_created_in_period))
        sr_created_in_period,
      decode(sum(inv2.emails_rsl_and_trfd_in_period), 0, to_number(null), sum(inv2.emails_rsl_and_trfd_in_period))
        emails_rsl_and_trfd_in_period,
      decode(sum(EMAILS_AUTO_REPLIED_IN_PERIOD), 0, to_number(null), sum(EMAILS_AUTO_REPLIED_IN_PERIOD))
        EMAILS_AUTO_REPLIED_IN_PERIOD,
      decode(sum(EMAILS_AUTO_DELETED_IN_PERIOD), 0, to_number(null), sum(EMAILS_AUTO_DELETED_IN_PERIOD))
        EMAILS_AUTO_DELETED_IN_PERIOD,
      decode(sum(EMAILS_AUTO_RESOLVED_IN_PERIOD), 0, to_number(null), sum(EMAILS_AUTO_RESOLVED_IN_PERIOD))
        EMAILS_AUTO_RESOLVED_IN_PERIOD,
      decode(sum(emails_composed_in_period), 0, to_number(null), sum(emails_composed_in_period))
        emails_composed_in_period,
      decode(sum(emails_orr_count_in_period), 0, to_number(null), sum(emails_orr_count_in_period))
        emails_orr_count_in_period,
      decode(sum(accumulated_open_emails), 0, to_number(null), sum(accumulated_open_emails))
        accumulated_open_emails,
      decode(sum(accumulated_emails_in_queue), 0, to_number(null), sum(accumulated_emails_in_queue))
        accumulated_emails_in_queue,
      decode(sum(accumulated_emails_one_day), 0, to_number(null), sum(accumulated_emails_one_day))
        accumulated_emails_one_day,
      decode(sum(accumulated_emails_three_days), 0, to_number(null), sum(accumulated_emails_three_days))
        accumulated_emails_three_days,
      decode(sum(accumulated_emails_week), 0, to_number(null), sum(accumulated_emails_week))
        accumulated_emails_week,
      decode(sum(accumulated_emails_week_plus), 0, to_number(null), sum(accumulated_emails_week_plus))
        accumulated_emails_week_plus,
      decode(sum(LEADS_CREATED_IN_PERIOD), 0, to_number(null), sum(LEADS_CREATED_IN_PERIOD))
       LEADS_CREATED_IN_PERIOD,
      decode(sum(EMAILS_REROUTED_IN_PERIOD), 0, to_number(null), sum(EMAILS_REROUTED_IN_PERIOD))
        EMAILS_REROUTED_IN_PERIOD,
      g_request_id
        request_id,
      g_program_appl_id
        program_application_id,
      g_program_id
        program_id,
      g_sysdate
        program_update_date
   FROM
    (
	/* Query 6 */
    SELECT   /*+ use_nl(intr,actv,segs,mitm)  */
      nvl(mitm.source_id, -1)                              EMAIL_ACCOUNT_ID,
      nvl(irc.route_classification_id, -1)                 EMAIL_CLASSIFICATION_ID,
      nvl(intr.resource_id, -1)                            AGENT_ID,
      nvl(intr.party_id, -1)                               PARTY_ID,
      trunc(intr.last_update_date)                         PERIOD_START_DATE,
      to_number(to_char(intr.last_update_date, 'J'))       TIME_ID,
      '00:00'                                              PERIOD_START_TIME,
      NVL(intr.outcome_id,-1)                              OUTCOME_ID,
      NVL(intr.result_id,-1)                               RESULT_ID,
      NVL(intr.reason_id,-1)                               REASON_ID,
      0                                                    EMAILS_OFFERED_IN_PERIOD,
      0                                                    EMAILS_FETCHED_IN_PERIOD,
      0                                                    EMAILS_REPLIED_IN_PERIOD,
      0                                                    AGENT_RESP_TIME_IN_PERIOD,
      0                                                    EMAILS_RPLD_BY_GOAL_IN_PERIOD,
      0                                                    AGENT_EMAILS_RPLD_BY_GOAL,
      0                                                    EMAILS_TRNSFRD_OUT_IN_PERIOD,
      0                                                    EMAILS_TRNSFRD_IN_IN_PERIOD,
      0                                                    EMAILS_ASSIGNED_IN_PERIOD,
      0                                                    EMAILS_AUTO_ROUTED_IN_PERIOD,
      0                                                    EMAILS_AUTO_UPTD_SR_IN_PERIOD,
      0                                                    EMAILS_DELETED_IN_PERIOD,
      0                                                    EMAIL_RESP_TIME_IN_PERIOD,
      0                                                    SR_CREATED_IN_PERIOD,
      0                                                    EMAILS_RSL_AND_TRFD_IN_PERIOD,
      0                                                    EMAILS_AUTO_REPLIED_IN_PERIOD,
      0                                                    EMAILS_AUTO_DELETED_IN_PERIOD,
      0                                                    EMAILS_AUTO_RESOLVED_IN_PERIOD,
      COUNT(distinct mitm.media_id)                        emails_composed_in_period,
      COUNT(DISTINCT intr.interaction_id)                  emails_orr_count_in_period,
      0                                                    accumulated_open_emails,
      0                                                    accumulated_emails_in_queue,
      0                                                    accumulated_emails_one_day,
      0                                                    accumulated_emails_three_days,
      0                                                    accumulated_emails_week,
      0                                                    accumulated_emails_week_plus,
	 0                                                    EMAILS_REROUTED_IN_PERIOD,
	 0                                                    LEADS_CREATED_IN_PERIOD
    FROM
      JTF_IH_MEDIA_ITEMS mitm,
      JTF_IH_MEDIA_ITEM_LC_SEGS segs,
      JTF_IH_MEDIA_ITM_LC_SEG_TYS seg_type,
      JTF_IH_ACTIVITIES actv,
      JTF_IH_INTERACTIONS intr,
    --
    --Changes for R12
    --
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) irc
    WHERE mitm.MEDIA_ITEM_TYPE = 'EMAIL'
    AND   mitm.direction = 'OUTBOUND'
    AND   mitm.media_id = segs.media_id
    AND   segs.milcs_type_id = seg_type.milcs_type_id
    AND   seg_type.milcs_code = 'EMAIL_COMPOSE'
    AND   mitm.classification  = irc.name(+)
 --   AND   mitm.media_id        = actv.media_id
   AND   segs.media_id        = actv.media_id
    AND   actv.interaction_id  = intr.interaction_id
    AND   intr.LAST_UPDATE_DATE BETWEEN  g_collect_start_date and g_collect_end_date
    AND   intr.outcome_id IS NOT NULL
    GROUP BY
      nvl(mitm.source_id, -1),
      nvl(irc.route_classification_id, -1),
      nvl(intr.resource_id, -1),
      nvl(intr.party_id, -1),
      trunc(intr.last_update_date),
      to_number(to_char(intr.last_update_date, 'J')),
      NVL(intr.outcome_id,-1),
      NVL(intr.result_id,-1),
      NVL(intr.reason_id,-1)
)inv2
GROUP BY
      inv2.email_account_id,
      inv2.email_classification_id,
      inv2.agent_id,
      inv2.party_id,
      inv2.time_id,
      inv2.period_start_date,
      inv2.period_start_time,
      inv2.outcome_id,
      inv2.result_id,
      inv2.reason_id
)  change
  ON (
      fact.email_account_id = change.email_account_id
      AND fact.email_classification_id = change.email_classification_id
      AND fact.agent_id = change.agent_id
      AND fact.party_id = change.party_id
      AND fact.time_id = change.time_id
      AND fact.period_type_id = change.period_type_id
      AND fact.period_start_date = change.period_start_date
      AND fact.period_start_time = change.period_start_time
      AND fact.outcome_id = change.outcome_id
      AND fact.result_id = change.result_id
      AND fact.reason_id = change.reason_id )
  WHEN MATCHED THEN
    UPDATE
      SET fact.emails_offered_in_period = DECODE(nvl(fact.emails_offered_in_period,0) + nvl(change.emails_offered_in_period,0),
             0, NULL, nvl(fact.emails_offered_in_period,0) + nvl(change.emails_offered_in_period,0))
      ,fact.emails_fetched_in_period = DECODE(nvl(fact.emails_fetched_in_period,0) + nvl(change.emails_fetched_in_period,0),
             0, NULL, nvl(fact.emails_fetched_in_period,0) + nvl(change.emails_fetched_in_period,0))
      ,fact.emails_replied_in_period = DECODE(nvl(fact.emails_replied_in_period,0) + nvl(change.emails_replied_in_period,0),
             0, NULL, nvl(fact.emails_replied_in_period,0) + nvl(change.emails_replied_in_period,0))
      ,fact.emails_rpld_by_goal_in_period = DECODE(nvl(fact.emails_rpld_by_goal_in_period,0) + nvl(change.emails_rpld_by_goal_in_period,
             0), 0, NULL, nvl(fact.emails_rpld_by_goal_in_period,0) + nvl(change.emails_rpld_by_goal_in_period,0))
      ,fact.AGENT_EMAILS_RPLD_BY_GOAL = DECODE(nvl(fact.AGENT_EMAILS_RPLD_BY_GOAL,0) + nvl(change.AGENT_EMAILS_RPLD_BY_GOAL,
                   0), 0, NULL, nvl(fact.AGENT_EMAILS_RPLD_BY_GOAL,0) + nvl(change.AGENT_EMAILS_RPLD_BY_GOAL,0))
      ,fact.emails_deleted_in_period = DECODE(nvl(fact.emails_deleted_in_period,0) + nvl(change.emails_deleted_in_period,0), 0, NULL,
             nvl(fact.emails_deleted_in_period,0) + nvl(change.emails_deleted_in_period,0))
      ,fact.emails_trnsfrd_out_in_period = DECODE(nvl(fact.emails_trnsfrd_out_in_period,0) + nvl(change.emails_trnsfrd_out_in_period,0),
             0, NULL, nvl(fact.emails_trnsfrd_out_in_period,0) + nvl(change.emails_trnsfrd_out_in_period,0))
      ,fact.emails_trnsfrd_in_in_period = DECODE(nvl(fact.emails_trnsfrd_in_in_period,0) + nvl(change.emails_trnsfrd_in_in_period,0),
             0, NULL, nvl(fact.emails_trnsfrd_in_in_period,0) + nvl(change.emails_trnsfrd_in_in_period,0))
      ,fact.emails_assigned_in_period = DECODE(nvl(fact.emails_assigned_in_period,0) + nvl(change.emails_assigned_in_period,0),
             0, NULL, nvl(fact.emails_assigned_in_period,0) + nvl(change.emails_assigned_in_period,0))
      ,fact.emails_auto_routed_in_period = DECODE(nvl(fact.emails_auto_routed_in_period,0) + nvl(change.emails_auto_routed_in_period,0),
             0, NULL, nvl(fact.emails_auto_routed_in_period,0) + nvl(change.emails_auto_routed_in_period,0))
      ,fact.emails_auto_uptd_sr_in_period = DECODE(nvl(fact.emails_auto_uptd_sr_in_period,0) + nvl(change.emails_auto_uptd_sr_in_period,0),
             0, NULL, nvl(fact.emails_auto_uptd_sr_in_period,0) + nvl(change.emails_auto_uptd_sr_in_period,0))
      ,fact.email_resp_time_in_period = DECODE(nvl(fact.email_resp_time_in_period,0) + nvl(change.email_resp_time_in_period,0),
             0, NULL, nvl(fact.email_resp_time_in_period,0) + nvl(change.email_resp_time_in_period,0))
      ,fact.agent_resp_time_in_period = DECODE(nvl(fact.agent_resp_time_in_period,0) + nvl(change.agent_resp_time_in_period,0),
             0, NULL, nvl(fact.agent_resp_time_in_period,0) + nvl(change.agent_resp_time_in_period,0))
      ,fact.sr_created_in_period = DECODE(nvl(fact.sr_created_in_period,0) + nvl(change.sr_created_in_period,0),
             0, NULL, nvl(fact.sr_created_in_period,0) + nvl(change.sr_created_in_period,0))
      ,fact.emails_rsl_and_trfd_in_period = DECODE(nvl(fact.emails_rsl_and_trfd_in_period,0) + nvl(change.emails_rsl_and_trfd_in_period,0),
             0, NULL, nvl(fact.emails_rsl_and_trfd_in_period,0) + nvl(change.emails_rsl_and_trfd_in_period,0))
      ,fact.emails_orr_count_in_period = DECODE(nvl(fact.emails_orr_count_in_period,0) + nvl(change.emails_orr_count_in_period,0),
             0, NULL, nvl(fact.emails_orr_count_in_period,0) + nvl(change.emails_orr_count_in_period,0))
      ,fact.EMAILS_AUTO_REPLIED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0),
             0, NULL, nvl(fact.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0))
      ,fact.EMAILS_AUTO_DELETED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_DELETED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_DELETED_IN_PERIOD,0),
             0, NULL, nvl(fact.EMAILS_AUTO_DELETED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_DELETED_IN_PERIOD,0))
      ,fact.EMAILS_AUTO_RESOLVED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,
             0), 0, NULL, nvl(fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,0))
      ,fact.emails_composed_in_period = DECODE(nvl(fact.emails_composed_in_period,0) + nvl(change.emails_composed_in_period,0),
             0, NULL, nvl(fact.emails_composed_in_period,0) + nvl(change.emails_composed_in_period,0))
--
--Note that accumulated measures are not added together - they are replaced by the new
--calculated value as they are not additive.
--
      ,fact.accumulated_open_emails = decode(change.accumulated_open_emails,0,to_number(NULL),change.accumulated_open_emails)
      ,fact.accumulated_emails_in_queue = decode(change.accumulated_emails_in_queue,0,to_number(NULL),change.accumulated_emails_in_queue)
      ,fact.accumulated_emails_one_day = decode(change.accumulated_emails_one_day,0,to_number(NULL),change.accumulated_emails_one_day)
      ,fact.accumulated_emails_three_days = decode(change.accumulated_emails_three_days,0,to_number(NULL),change.accumulated_emails_three_days)
      ,fact.accumulated_emails_week = decode(change.accumulated_emails_week,0,to_number(NULL),change.accumulated_emails_week)
      ,fact.accumulated_emails_week_plus = decode(change.accumulated_emails_week_plus,0,to_number(NULL),change.accumulated_emails_week_plus)
      ,fact.last_updated_by = change.last_updated_by
      ,fact.last_update_date = change.last_update_date
      ,fact.emails_rerouted_in_period = DECODE(nvl(fact.emails_rerouted_in_period,0) + nvl(change.emails_rerouted_in_period,0),
             0, NULL, nvl(fact.emails_rerouted_in_period,0) + nvl(change.emails_rerouted_in_period,0))
      ,fact.leads_created_in_period = DECODE(nvl(fact.leads_created_in_period,0) + nvl(change.leads_created_in_period,0),
             0, NULL, nvl(fact.leads_created_in_period,0) + nvl(change.leads_created_in_period,0))
  WHEN NOT MATCHED THEN
    INSERT (
      fact.email_account_id,
      fact.email_classification_id,
      fact.agent_id,
      fact.party_id,
      fact.time_id,
      fact.period_type_id,
      fact.period_start_date,
      fact.period_start_time,
      fact.outcome_id,
      fact.result_id,
      fact.reason_id,
      fact.created_by,
      fact.creation_date,
      fact.last_updated_by,
      fact.last_update_date,
      fact.emails_offered_in_period,
      fact.emails_fetched_in_period,
      fact.emails_replied_in_period,
      fact.emails_rpld_by_goal_in_period,
      fact.AGENT_EMAILS_RPLD_BY_GOAL,
      fact.emails_deleted_in_period,
      fact.emails_trnsfrd_out_in_period,
      fact.emails_trnsfrd_in_in_period,
      fact.emails_assigned_in_period,
      fact.emails_auto_routed_in_period,
      fact.emails_auto_uptd_sr_in_period,
      fact.email_resp_time_in_period,
      fact.agent_resp_time_in_period,
      fact.sr_created_in_period,
      fact.emails_rsl_and_trfd_in_period,
      fact.emails_orr_count_in_period,
      fact.EMAILS_AUTO_REPLIED_IN_PERIOD,
      fact.EMAILS_AUTO_DELETED_IN_PERIOD,
      fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,
      fact.emails_composed_in_period,
      fact.accumulated_open_emails,
      fact.accumulated_emails_in_queue,
      fact.accumulated_emails_one_day,
      fact.accumulated_emails_three_days,
      fact.accumulated_emails_week,
      fact.accumulated_emails_week_plus,
      fact.request_id,
      fact.program_application_id,
      fact.program_id,
      fact.program_update_date,
      fact.emails_rerouted_in_period,
      fact.leads_created_in_period )
    VALUES (
      change.email_account_id,
      change.email_classification_id,
      change.agent_id,
      change.party_id,
      change.time_id,
      change.period_type_id,
      change.period_start_date,
      change.period_start_time,
      change.outcome_id,
      change.result_id,
      change.reason_id,
      change.created_by,
      change.creation_date,
      change.last_updated_by,
      change.last_update_date,
      decode(change.emails_offered_in_period,0,to_number(null), change.emails_offered_in_period),
      decode(change.emails_fetched_in_period, 0,to_number(null),change.emails_fetched_in_period),
      decode(change.emails_replied_in_period, 0,to_number(null),change.emails_replied_in_period),
      decode(change.emails_rpld_by_goal_in_period, 0,to_number(null),change.emails_rpld_by_goal_in_period),
      decode(change.AGENT_EMAILS_RPLD_BY_GOAL, 0,to_number(null),change.AGENT_EMAILS_RPLD_BY_GOAL),
      decode(change.emails_deleted_in_period, 0,to_number(null),change.emails_deleted_in_period),
      decode(change.emails_trnsfrd_out_in_period, 0,to_number(null),change.emails_trnsfrd_out_in_period),
      decode(change.emails_trnsfrd_in_in_period, 0,to_number(null),change.emails_trnsfrd_in_in_period),
      decode(change.emails_assigned_in_period, 0,to_number(null),change.emails_assigned_in_period),
      decode(change.emails_auto_routed_in_period, 0,to_number(null),change.emails_auto_routed_in_period),
      decode(change.emails_auto_uptd_sr_in_period, 0,to_number(null),change.emails_auto_uptd_sr_in_period),
      decode(change.email_resp_time_in_period, 0,to_number(null),change.email_resp_time_in_period),
      decode(change.agent_resp_time_in_period, 0,to_number(null),change.agent_resp_time_in_period),
      decode(change.sr_created_in_period, 0,to_number(null),change.sr_created_in_period),
      decode(change.emails_rsl_and_trfd_in_period, 0,to_number(null),change.emails_rsl_and_trfd_in_period),
      decode(change.emails_orr_count_in_period, 0,to_number(null),change.emails_orr_count_in_period),
      decode(change.EMAILS_AUTO_REPLIED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_REPLIED_IN_PERIOD),
      decode(change.EMAILS_AUTO_DELETED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_DELETED_IN_PERIOD),
      decode(change.EMAILS_AUTO_RESOLVED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_RESOLVED_IN_PERIOD),
      decode(change.emails_composed_in_period, 0,to_number(null),change.emails_composed_in_period),
      decode(change.accumulated_open_emails, 0,to_number(null),change.accumulated_open_emails),
      decode(change.accumulated_emails_in_queue, 0,to_number(null),change.accumulated_emails_in_queue),
      decode(change.accumulated_emails_one_day, 0,to_number(null),change.accumulated_emails_one_day),
      decode(change.accumulated_emails_three_days, 0,to_number(null),change.accumulated_emails_three_days),
      decode(change.accumulated_emails_week, 0,to_number(null),change.accumulated_emails_week),
      decode(change.accumulated_emails_week_plus, 0,to_number(null),change.accumulated_emails_week_plus),
      change.request_id,
      change.program_application_id,
      change.program_id,
      change.program_update_date,
      decode(change.emails_rerouted_in_period, 0,to_number(null),change.emails_rerouted_in_period),
      decode(change.leads_created_in_period, 0,to_number(null),change.leads_created_in_period)
      );

write_log('Number of rows updated in table bix_email_details_stg for Emails composed and ORR count  ' || to_char(SQL%ROWCOUNT));


MERGE INTO BIX_EMAIL_DETAILS_STG  fact
  USING
  (SELECT
      inv2.email_account_id
        email_account_id,
      inv2.email_classification_id
        email_classification_id,
      inv2.agent_id
        agent_id,
      inv2.party_id
        party_id,
      inv2.time_id
        time_id,
      1 period_type_id,
      inv2.period_start_date
        period_start_date,
      inv2.period_start_time
        period_start_time,
      inv2.outcome_id
        outcome_id,
      inv2.result_id
        result_id,
      inv2.reason_id
        reason_id,
      g_user_id
        created_by,
      g_sysdate
        creation_date,
      g_user_id
        last_updated_by,
      g_sysdate
        last_update_date,
      decode(sum(inv2.emails_offered_in_period), 0, to_number(null), sum(inv2.emails_offered_in_period))
        emails_offered_in_period,
      decode(sum(inv2.emails_fetched_in_period), 0, to_number(null), sum(inv2.emails_fetched_in_period))
        emails_fetched_in_period,
      decode(sum(inv2.emails_replied_in_period), 0, to_number(null), sum(inv2.emails_replied_in_period))
        emails_replied_in_period,
      decode(sum(inv2.emails_rpld_by_goal_in_period), 0, to_number(null), sum(inv2.emails_rpld_by_goal_in_period))
        emails_rpld_by_goal_in_period,
      decode(sum(inv2.AGENT_EMAILS_RPLD_BY_GOAL), 0, to_number(null), sum(inv2.AGENT_EMAILS_RPLD_BY_GOAL))
        AGENT_EMAILS_RPLD_BY_GOAL,
      decode(sum(inv2.emails_deleted_in_period), 0, to_number(null), sum(inv2.emails_deleted_in_period))
        emails_deleted_in_period,
      decode(sum(inv2.emails_trnsfrd_out_in_period), 0, to_number(null), sum(inv2.emails_trnsfrd_out_in_period))
        emails_trnsfrd_out_in_period,
      decode(sum(inv2.emails_trnsfrd_in_in_period), 0, to_number(null), sum(inv2.emails_trnsfrd_in_in_period))
        emails_trnsfrd_in_in_period,
      decode(sum(inv2.emails_assigned_in_period), 0, to_number(null), sum(inv2.emails_assigned_in_period))
        emails_assigned_in_period,
      decode(sum(inv2.emails_auto_routed_in_period), 0, to_number(null), sum(inv2.emails_auto_routed_in_period))
        emails_auto_routed_in_period,
      decode(sum(inv2.emails_auto_uptd_sr_in_period), 0, to_number(null), sum(inv2.emails_auto_uptd_sr_in_period))
        emails_auto_uptd_sr_in_period,
      decode(round(sum(inv2.email_resp_time_in_period)), 0, to_number(null), round(sum(inv2.email_resp_time_in_period)))
        email_resp_time_in_period,
      decode(round(sum(inv2.agent_resp_time_in_period)), 0, to_number(null), round(sum(inv2.agent_resp_time_in_period)))
        agent_resp_time_in_period,
      decode(sum(inv2.sr_created_in_period), 0, to_number(null), sum(inv2.sr_created_in_period))
        sr_created_in_period,
      decode(sum(inv2.emails_rsl_and_trfd_in_period), 0, to_number(null), sum(inv2.emails_rsl_and_trfd_in_period))
        emails_rsl_and_trfd_in_period,
      decode(sum(EMAILS_AUTO_REPLIED_IN_PERIOD), 0, to_number(null), sum(EMAILS_AUTO_REPLIED_IN_PERIOD))
        EMAILS_AUTO_REPLIED_IN_PERIOD,
      decode(sum(EMAILS_AUTO_DELETED_IN_PERIOD), 0, to_number(null), sum(EMAILS_AUTO_DELETED_IN_PERIOD))
        EMAILS_AUTO_DELETED_IN_PERIOD,
      decode(sum(EMAILS_AUTO_RESOLVED_IN_PERIOD), 0, to_number(null), sum(EMAILS_AUTO_RESOLVED_IN_PERIOD))
        EMAILS_AUTO_RESOLVED_IN_PERIOD,
      decode(sum(emails_composed_in_period), 0, to_number(null), sum(emails_composed_in_period))
        emails_composed_in_period,
      decode(sum(emails_orr_count_in_period), 0, to_number(null), sum(emails_orr_count_in_period))
        emails_orr_count_in_period,
      decode(sum(accumulated_open_emails), 0, to_number(null), sum(accumulated_open_emails))
        accumulated_open_emails,
      decode(sum(accumulated_emails_in_queue), 0, to_number(null), sum(accumulated_emails_in_queue))
        accumulated_emails_in_queue,
      decode(sum(accumulated_emails_one_day), 0, to_number(null), sum(accumulated_emails_one_day))
        accumulated_emails_one_day,
      decode(sum(accumulated_emails_three_days), 0, to_number(null), sum(accumulated_emails_three_days))
        accumulated_emails_three_days,
      decode(sum(accumulated_emails_week), 0, to_number(null), sum(accumulated_emails_week))
        accumulated_emails_week,
      decode(sum(accumulated_emails_week_plus), 0, to_number(null), sum(accumulated_emails_week_plus))
        accumulated_emails_week_plus,
      decode(sum(LEADS_CREATED_IN_PERIOD), 0, to_number(null), sum(LEADS_CREATED_IN_PERIOD))
       LEADS_CREATED_IN_PERIOD,
      decode(sum(EMAILS_REROUTED_IN_PERIOD), 0, to_number(null), sum(EMAILS_REROUTED_IN_PERIOD))
        EMAILS_REROUTED_IN_PERIOD,
      g_request_id
        request_id,
      g_program_appl_id
        program_application_id,
      g_program_id
        program_id,
      g_sysdate
        program_update_date
   FROM
    (
/* Query 7  -Part I*/
    SELECT
      nvl(iview.email_account_id, -1)          EMAIL_ACCOUNT_ID,
      nvl(iview.email_classification_id, -1)   EMAIL_CLASSIFICATION_ID,
      nvl(iview.resource_id, -1)               AGENT_ID,
      nvl(iview.party_id, -1)                  PARTY_ID,
      trunc(ftd.start_date)                    PERIOD_START_DATE,
      to_number(to_char(ftd.start_date, 'J'))  TIME_ID,
      '00:00'                                  PERIOD_START_TIME,
      -1                                       OUTCOME_ID,
      -1                                       RESULT_ID,
      -1                                       REASON_ID,
      0                                        EMAILS_OFFERED_IN_PERIOD,
      0                                        EMAILS_FETCHED_IN_PERIOD,
      0                                        EMAILS_REPLIED_IN_PERIOD,
      0                                        AGENT_RESP_TIME_IN_PERIOD,
      0                                        EMAILS_RPLD_BY_GOAL_IN_PERIOD,
      0                                        AGENT_EMAILS_RPLD_BY_GOAL,
      0                                        EMAILS_TRNSFRD_OUT_IN_PERIOD,
      0                                        EMAILS_TRNSFRD_IN_IN_PERIOD,
      0                                        EMAILS_ASSIGNED_IN_PERIOD,
      0                                        EMAILS_AUTO_ROUTED_IN_PERIOD,
      0                                        EMAILS_AUTO_UPTD_SR_IN_PERIOD,
      0                                        EMAILS_DELETED_IN_PERIOD,
      0                                        EMAIL_RESP_TIME_IN_PERIOD,
      0                                        SR_CREATED_IN_PERIOD,
      0                                        EMAILS_RSL_AND_TRFD_IN_PERIOD,
      0                                        EMAILS_AUTO_REPLIED_IN_PERIOD,
      0                                        EMAILS_AUTO_DELETED_IN_PERIOD,
      0                                        EMAILS_AUTO_RESOLVED_IN_PERIOD,
      0                                        emails_composed_in_period,
      0                                        emails_orr_count_in_period,
      sum(CASE WHEN ((iview.end_date_time - ftd.start_date) > 1) THEN 1
               WHEN (((iview.end_date_time - ftd.start_date) <= 1) AND (flag = 1)) THEN 1
               ELSE 0 END)                     accumulated_open_emails,
      0                                        accumulated_emails_in_queue,
    sum(CASE WHEN
          (decode(sign(iview.end_date_time - (ftd.start_date+1)), 1, ftd.start_date+1, iview.end_date_time) - media_start_date_time >= 0 AND
           decode(sign(iview.end_date_time - (ftd.start_date+1)), 1, ftd.start_date+1, iview.end_date_time) - media_start_date_time <= 1 AND
           decode(sign((iview.end_date_time - ftd.start_date) -1), 1, 1, decode(flag, 1, 1, 0)) = 1) THEN 1 else 0 END)
                                          accumulated_emails_one_day,
      sum(CASE WHEN
          (decode(sign(iview.end_date_time - (ftd.start_date+1)), 1, ftd.start_date+1, iview.end_date_time) - media_start_date_time > 1 AND
           decode(sign(iview.end_date_time - (ftd.start_date+1)), 1, ftd.start_date+1, iview.end_date_time) - media_start_date_time <= 3 AND
           decode(sign((iview.end_date_time - ftd.start_date) -1), 1, 1, decode(flag, 1, 1, 0)) = 1) THEN 1 else 0 END)
                                          accumulated_emails_three_days,
      sum(CASE WHEN
          (decode(sign(iview.end_date_time - (ftd.start_date+1)), 1, ftd.start_date+1, iview.end_date_time) - media_start_date_time > 3 AND
           decode(sign(iview.end_date_time - (ftd.start_date+1)), 1, ftd.start_date+1, iview.end_date_time) - media_start_date_time <= 7 AND
           decode(sign((iview.end_date_time - ftd.start_date) -1), 1, 1, decode(flag, 1, 1, 0)) = 1) THEN 1 else 0 END)
                                          accumulated_emails_week,
      sum(CASE WHEN
          (decode(sign(iview.end_date_time - (ftd.start_date+1)), 1, ftd.start_date+1, iview.end_date_time) - media_start_date_time > 7 AND
           decode(sign((iview.end_date_time - ftd.start_date) -1), 1, 1, decode(flag, 1, 1, 0)) = 1) THEN 1 else 0 END)
                                          accumulated_emails_week_plus,
	 0                                                    EMAILS_REROUTED_IN_PERIOD,
	 0                                                    LEADS_CREATED_IN_PERIOD
    FROM
      fii_time_day ftd,
(
/* Query 7  -Part I*/SELECT
        media_id                               MEDIA_ID,
        nvl(email_account_id, -1)              EMAIL_ACCOUNT_ID,
        nvl(email_classification_id, -1)       EMAIL_CLASSIFICATION_ID,
        nvl(resource_id,-1)                    RESOURCE_ID,
        nvl(party_id, -1)                      PARTY_ID,
        decode(sign(max(seg_start_date_time) - g_collect_start_date), 1, max(seg_start_date_time),g_collect_start_date)
                                               START_DATE_TIME,
        g_collect_end_date                     END_DATE_TIME,
	max(media_start_date_time)             MEDIA_START_DATE_TIME,
        1                                      FLAG
FROM
      (
      /* Query 7  -Part I*/
	  SELECT   /*+ ordered INDEX(MSEG JTF_IH_MEDIA_ITEM_LC_SEGS_N3) use_nl(mseg,mitm,act,int) */
        mitm.media_id                        MEDIA_ID,
	mseg.milcs_id                        MILCS_ID,
        nvl(mitm.source_id, -1)              EMAIL_ACCOUNT_ID,
        nvl(cls.route_classification_id, -1) EMAIL_CLASSIFICATION_ID,
        nvl(mseg.resource_id,-1)             RESOURCE_ID,
        first_value(int.party_id) over(partition by act.media_id order by act.interaction_id DESC) PARTY_ID,
        mseg.start_date_time                 SEG_START_DATE_TIME,
        mitm.start_date_time                 MEDIA_START_DATE_TIME
      FROM
        JTF_IH_MEDIA_ITEM_LC_SEGS mseg,
		JTF_IH_MEDIA_ITEMS mitm,
        JTF_IH_ACTIVITIES act,
        JTF_IH_INTERACTIONS int,
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) cls
      WHERE 1=1
	  --mitm.media_item_type = 'EMAIL'
      AND   mitm.media_id = act.media_id
      AND   int.interaction_id = act.interaction_id
      AND   mitm.direction = 'INBOUND'
      AND   mitm.classification = cls.name(+)
      AND   mitm.media_id = mseg.media_id
      AND   mseg.start_date_time < g_collect_end_date
      AND   mseg.milcs_type_id in (g_fetch,g_transfer,g_a_routed,g_assigned,g_assign_open)
      AND   NOT EXISTS
       (
        SELECT  1
        FROM JTF_IH_MEDIA_ITEM_LC_SEGS mseg1
        WHERE mseg.media_id = mseg1.media_id
	 /* Commenting this join out because the supervisor can perform some of the operations below.
	 Irrespective of which user did it, the email is not open any more */
       -- AND   mseg.resource_id = mseg1.resource_id
        AND   mseg1.milcs_type_id IN (g_deleted,g_transferred,g_reply,g_assigned,g_rerouted_acct,g_rerouted_class,g_Requeued,g_escalated)
        AND   mseg1.START_DATE_TIME >= mseg.START_DATE_TIME
        AND   mseg1.start_date_time < g_collect_end_date
        AND   mseg1.milcs_id <> mseg.milcs_id
       )
)
group by media_id, nvl(email_account_id, -1), nvl(email_classification_id, -1),
        nvl(resource_id,-1), nvl(party_id, -1), milcs_id
      UNION
	  	/* Query 7  -Part II*/
--Not open any more but was open in the past - note this does not need the interactions, activities
--merged into the same query, since act.start_date_time would fall into the collect start and end buckets
SELECT
MEDIA_ID,
EMAIL_ACCOUNT_ID,
EMAIL_CLASSIFICATION_ID,
RESOURCE_ID,
PARTY_ID,
START_DATE_TIME,
min(END_DATE_TIME)             END_DATE_TIME,
MEDIA_START_DATE_TIME,
0                                    FLAG
 FROM
 (
 SELECT /*+ ordered INDEX(MSEG JTF_IH_MEDIA_ITEM_LC_SEGS_N3) use_nl(mseg,mitm)*/
        mitm.media_id                        MEDIA_ID,
        nvl(mitm.source_id, -1)              EMAIL_ACCOUNT_ID,
        nvl(cls.route_classification_id, -1) EMAIL_CLASSIFICATION_ID,
        nvl(mseg.resource_id, -1)            RESOURCE_ID,
           nvl((  SELECT
          distinct first_value(intr.party_id) over(order by actv.interaction_id desc) party_id
         FROM
           jtf_ih_activities actv,
           jtf_ih_interactions intr
         WHERE
         mitm.media_id = actv.media_id
        AND actv.interaction_id = intr.interaction_id
		), -1)                       PARTY_ID,
        decode(sign(mseg.start_date_time - g_collect_start_date), 1, mseg.start_date_time, g_collect_start_date)
                                             START_DATE_TIME,
        inv2.start_date_time             END_DATE_TIME,
        mitm.start_date_time                 MEDIA_START_DATE_TIME
           FROM
		      JTF_IH_MEDIA_ITEM_LC_SEGS mseg,
		      JTF_IH_MEDIA_ITEMS mitm,
			   (
			select name, max(route_classification_id) route_classification_id
			from iem_route_classifications
			group by name
				) cls ,
				(
					SELECT  /*+  INDEX(MSEG1 JTF_IH_MEDIA_ITEM_LC_SEGS_N3) */
							mseg1.media_id         MEDIA_ID,
							mseg1.resource_id      RESOURCE_ID,
							mseg1.start_date_time  START_DATE_TIME
					FROM    JTF_IH_MEDIA_ITEM_LC_SEGS mseg1
					WHERE   mseg1.milcs_type_id IN (g_deleted,g_transferred,g_reply,g_assigned,g_rerouted_acct,g_rerouted_class,g_Requeued,g_escalated)
					  AND     mseg1.START_DATE_TIME < g_collect_end_date
				) inv2
      WHERE  mitm.media_id=mseg.media_id
      AND    inv2.media_id = mseg.media_id
--      AND    inv2.resource_id = mseg.resource_id
	    /* Commenting this join out because the supervisor  performs some  operations like delete and requeued.
	 Irrespective of which user did it, the email was not open. Lets say Email fetched by agent a, email transferred by a,
	 email transfer to b, email requeue to c. If we remove this condition, we anyways take min (inv2.start_date_time),
	 so a will get the email transferred start date time (done by him), b will get requeue start date time (done by c) */
      --AND    mitm.media_item_type = 'EMAIL'
      AND    mitm.direction = 'INBOUND'
      AND    mitm.classification = cls.name(+)
      AND    mseg.start_date_time < g_collect_end_date
      AND    mseg.milcs_type_id in ( g_fetch,g_transfer,g_a_routed,g_assigned,g_assign_open)
      AND    inv2.START_DATE_TIME >= mseg.START_DATE_TIME

)
GROUP BY
MEDIA_ID,
EMAIL_ACCOUNT_ID,
EMAIL_CLASSIFICATION_ID,
RESOURCE_ID,
PARTY_ID,
START_DATE_TIME,
MEDIA_START_DATE_TIME

		) iview
    WHERE ftd.start_date between trunc(iview.start_date_time) AND iview.end_date_time
    GROUP BY
      iview.email_account_id
      ,iview.email_classification_id
      ,iview.resource_id
      ,iview.party_id
      ,ftd.start_date
)inv2
GROUP BY
      inv2.email_account_id,
      inv2.email_classification_id,
      inv2.agent_id,
      inv2.party_id,
      inv2.time_id,
      inv2.period_start_date,
      inv2.period_start_time,
      inv2.outcome_id,
      inv2.result_id,
      inv2.reason_id
)  change
  ON (
      fact.email_account_id = change.email_account_id
      AND fact.email_classification_id = change.email_classification_id
      AND fact.agent_id = change.agent_id
      AND fact.party_id = change.party_id
      AND fact.time_id = change.time_id
      AND fact.period_type_id = change.period_type_id
      AND fact.period_start_date = change.period_start_date
      AND fact.period_start_time = change.period_start_time
      AND fact.outcome_id = change.outcome_id
      AND fact.result_id = change.result_id
      AND fact.reason_id = change.reason_id )
  WHEN MATCHED THEN
    UPDATE
      SET fact.emails_offered_in_period = DECODE(nvl(fact.emails_offered_in_period,0) + nvl(change.emails_offered_in_period,0),
             0, NULL, nvl(fact.emails_offered_in_period,0) + nvl(change.emails_offered_in_period,0))
      ,fact.emails_fetched_in_period = DECODE(nvl(fact.emails_fetched_in_period,0) + nvl(change.emails_fetched_in_period,0),
             0, NULL, nvl(fact.emails_fetched_in_period,0) + nvl(change.emails_fetched_in_period,0))
      ,fact.emails_replied_in_period = DECODE(nvl(fact.emails_replied_in_period,0) + nvl(change.emails_replied_in_period,0),
             0, NULL, nvl(fact.emails_replied_in_period,0) + nvl(change.emails_replied_in_period,0))
      ,fact.emails_rpld_by_goal_in_period = DECODE(nvl(fact.emails_rpld_by_goal_in_period,0) + nvl(change.emails_rpld_by_goal_in_period,
             0), 0, NULL, nvl(fact.emails_rpld_by_goal_in_period,0) + nvl(change.emails_rpld_by_goal_in_period,0))
      ,fact.AGENT_EMAILS_RPLD_BY_GOAL = DECODE(nvl(fact.AGENT_EMAILS_RPLD_BY_GOAL,0) + nvl(change.AGENT_EMAILS_RPLD_BY_GOAL,
                   0), 0, NULL, nvl(fact.AGENT_EMAILS_RPLD_BY_GOAL,0) + nvl(change.AGENT_EMAILS_RPLD_BY_GOAL,0))
      ,fact.emails_deleted_in_period = DECODE(nvl(fact.emails_deleted_in_period,0) + nvl(change.emails_deleted_in_period,0), 0, NULL,
             nvl(fact.emails_deleted_in_period,0) + nvl(change.emails_deleted_in_period,0))
      ,fact.emails_trnsfrd_out_in_period = DECODE(nvl(fact.emails_trnsfrd_out_in_period,0) + nvl(change.emails_trnsfrd_out_in_period,0),
             0, NULL, nvl(fact.emails_trnsfrd_out_in_period,0) + nvl(change.emails_trnsfrd_out_in_period,0))
      ,fact.emails_trnsfrd_in_in_period = DECODE(nvl(fact.emails_trnsfrd_in_in_period,0) + nvl(change.emails_trnsfrd_in_in_period,0),
             0, NULL, nvl(fact.emails_trnsfrd_in_in_period,0) + nvl(change.emails_trnsfrd_in_in_period,0))
      ,fact.emails_assigned_in_period = DECODE(nvl(fact.emails_assigned_in_period,0) + nvl(change.emails_assigned_in_period,0),
             0, NULL, nvl(fact.emails_assigned_in_period,0) + nvl(change.emails_assigned_in_period,0))
      ,fact.emails_auto_routed_in_period = DECODE(nvl(fact.emails_auto_routed_in_period,0) + nvl(change.emails_auto_routed_in_period,0),
             0, NULL, nvl(fact.emails_auto_routed_in_period,0) + nvl(change.emails_auto_routed_in_period,0))
      ,fact.emails_auto_uptd_sr_in_period = DECODE(nvl(fact.emails_auto_uptd_sr_in_period,0) + nvl(change.emails_auto_uptd_sr_in_period,0),
             0, NULL, nvl(fact.emails_auto_uptd_sr_in_period,0) + nvl(change.emails_auto_uptd_sr_in_period,0))
      ,fact.email_resp_time_in_period = DECODE(nvl(fact.email_resp_time_in_period,0) + nvl(change.email_resp_time_in_period,0),
             0, NULL, nvl(fact.email_resp_time_in_period,0) + nvl(change.email_resp_time_in_period,0))
      ,fact.agent_resp_time_in_period = DECODE(nvl(fact.agent_resp_time_in_period,0) + nvl(change.agent_resp_time_in_period,0),
             0, NULL, nvl(fact.agent_resp_time_in_period,0) + nvl(change.agent_resp_time_in_period,0))
      ,fact.sr_created_in_period = DECODE(nvl(fact.sr_created_in_period,0) + nvl(change.sr_created_in_period,0),
             0, NULL, nvl(fact.sr_created_in_period,0) + nvl(change.sr_created_in_period,0))
      ,fact.emails_rsl_and_trfd_in_period = DECODE(nvl(fact.emails_rsl_and_trfd_in_period,0) + nvl(change.emails_rsl_and_trfd_in_period,0),
             0, NULL, nvl(fact.emails_rsl_and_trfd_in_period,0) + nvl(change.emails_rsl_and_trfd_in_period,0))
      ,fact.emails_orr_count_in_period = DECODE(nvl(fact.emails_orr_count_in_period,0) + nvl(change.emails_orr_count_in_period,0),
             0, NULL, nvl(fact.emails_orr_count_in_period,0) + nvl(change.emails_orr_count_in_period,0))
      ,fact.EMAILS_AUTO_REPLIED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0),
             0, NULL, nvl(fact.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0))
      ,fact.EMAILS_AUTO_DELETED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_DELETED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_DELETED_IN_PERIOD,0),
             0, NULL, nvl(fact.EMAILS_AUTO_DELETED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_DELETED_IN_PERIOD,0))
      ,fact.EMAILS_AUTO_RESOLVED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,
             0), 0, NULL, nvl(fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,0))
      ,fact.emails_composed_in_period = DECODE(nvl(fact.emails_composed_in_period,0) + nvl(change.emails_composed_in_period,0),
             0, NULL, nvl(fact.emails_composed_in_period,0) + nvl(change.emails_composed_in_period,0))
--
--Note that accumulated measures are not added together - they are replaced by the new
--calculated value as they are not additive.
--
      ,fact.accumulated_open_emails = decode(change.accumulated_open_emails,0,to_number(NULL),change.accumulated_open_emails)
      ,fact.accumulated_emails_in_queue = decode(change.accumulated_emails_in_queue,0,to_number(NULL),change.accumulated_emails_in_queue)
      ,fact.accumulated_emails_one_day = decode(change.accumulated_emails_one_day,0,to_number(NULL),change.accumulated_emails_one_day)
      ,fact.accumulated_emails_three_days = decode(change.accumulated_emails_three_days,0,to_number(NULL),change.accumulated_emails_three_days)
      ,fact.accumulated_emails_week = decode(change.accumulated_emails_week,0,to_number(NULL),change.accumulated_emails_week)
      ,fact.accumulated_emails_week_plus = decode(change.accumulated_emails_week_plus,0,to_number(NULL),change.accumulated_emails_week_plus)
      ,fact.last_updated_by = change.last_updated_by
      ,fact.last_update_date = change.last_update_date
      ,fact.emails_rerouted_in_period = DECODE(nvl(fact.emails_rerouted_in_period,0) + nvl(change.emails_rerouted_in_period,0),
             0, NULL, nvl(fact.emails_rerouted_in_period,0) + nvl(change.emails_rerouted_in_period,0))
      ,fact.leads_created_in_period = DECODE(nvl(fact.leads_created_in_period,0) + nvl(change.leads_created_in_period,0),
             0, NULL, nvl(fact.leads_created_in_period,0) + nvl(change.leads_created_in_period,0))
  WHEN NOT MATCHED THEN
    INSERT (
      fact.email_account_id,
      fact.email_classification_id,
      fact.agent_id,
      fact.party_id,
      fact.time_id,
      fact.period_type_id,
      fact.period_start_date,
      fact.period_start_time,
      fact.outcome_id,
      fact.result_id,
      fact.reason_id,
      fact.created_by,
      fact.creation_date,
      fact.last_updated_by,
      fact.last_update_date,
      fact.emails_offered_in_period,
      fact.emails_fetched_in_period,
      fact.emails_replied_in_period,
      fact.emails_rpld_by_goal_in_period,
      fact.AGENT_EMAILS_RPLD_BY_GOAL,
      fact.emails_deleted_in_period,
      fact.emails_trnsfrd_out_in_period,
      fact.emails_trnsfrd_in_in_period,
      fact.emails_assigned_in_period,
      fact.emails_auto_routed_in_period,
      fact.emails_auto_uptd_sr_in_period,
      fact.email_resp_time_in_period,
      fact.agent_resp_time_in_period,
      fact.sr_created_in_period,
      fact.emails_rsl_and_trfd_in_period,
      fact.emails_orr_count_in_period,
      fact.EMAILS_AUTO_REPLIED_IN_PERIOD,
      fact.EMAILS_AUTO_DELETED_IN_PERIOD,
      fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,
      fact.emails_composed_in_period,
      fact.accumulated_open_emails,
      fact.accumulated_emails_in_queue,
      fact.accumulated_emails_one_day,
      fact.accumulated_emails_three_days,
      fact.accumulated_emails_week,
      fact.accumulated_emails_week_plus,
      fact.request_id,
      fact.program_application_id,
      fact.program_id,
      fact.program_update_date,
      fact.emails_rerouted_in_period,
      fact.leads_created_in_period )
    VALUES (
      change.email_account_id,
      change.email_classification_id,
      change.agent_id,
      change.party_id,
      change.time_id,
      change.period_type_id,
      change.period_start_date,
      change.period_start_time,
      change.outcome_id,
      change.result_id,
      change.reason_id,
      change.created_by,
      change.creation_date,
      change.last_updated_by,
      change.last_update_date,
      decode(change.emails_offered_in_period,0,to_number(null), change.emails_offered_in_period),
      decode(change.emails_fetched_in_period, 0,to_number(null),change.emails_fetched_in_period),
      decode(change.emails_replied_in_period, 0,to_number(null),change.emails_replied_in_period),
      decode(change.emails_rpld_by_goal_in_period, 0,to_number(null),change.emails_rpld_by_goal_in_period),
      decode(change.AGENT_EMAILS_RPLD_BY_GOAL, 0,to_number(null),change.AGENT_EMAILS_RPLD_BY_GOAL),
      decode(change.emails_deleted_in_period, 0,to_number(null),change.emails_deleted_in_period),
      decode(change.emails_trnsfrd_out_in_period, 0,to_number(null),change.emails_trnsfrd_out_in_period),
      decode(change.emails_trnsfrd_in_in_period, 0,to_number(null),change.emails_trnsfrd_in_in_period),
      decode(change.emails_assigned_in_period, 0,to_number(null),change.emails_assigned_in_period),
      decode(change.emails_auto_routed_in_period, 0,to_number(null),change.emails_auto_routed_in_period),
      decode(change.emails_auto_uptd_sr_in_period, 0,to_number(null),change.emails_auto_uptd_sr_in_period),
      decode(change.email_resp_time_in_period, 0,to_number(null),change.email_resp_time_in_period),
      decode(change.agent_resp_time_in_period, 0,to_number(null),change.agent_resp_time_in_period),
      decode(change.sr_created_in_period, 0,to_number(null),change.sr_created_in_period),
      decode(change.emails_rsl_and_trfd_in_period, 0,to_number(null),change.emails_rsl_and_trfd_in_period),
      decode(change.emails_orr_count_in_period, 0,to_number(null),change.emails_orr_count_in_period),
      decode(change.EMAILS_AUTO_REPLIED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_REPLIED_IN_PERIOD),
      decode(change.EMAILS_AUTO_DELETED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_DELETED_IN_PERIOD),
      decode(change.EMAILS_AUTO_RESOLVED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_RESOLVED_IN_PERIOD),
      decode(change.emails_composed_in_period, 0,to_number(null),change.emails_composed_in_period),
      decode(change.accumulated_open_emails, 0,to_number(null),change.accumulated_open_emails),
      decode(change.accumulated_emails_in_queue, 0,to_number(null),change.accumulated_emails_in_queue),
      decode(change.accumulated_emails_one_day, 0,to_number(null),change.accumulated_emails_one_day),
      decode(change.accumulated_emails_three_days, 0,to_number(null),change.accumulated_emails_three_days),
      decode(change.accumulated_emails_week, 0,to_number(null),change.accumulated_emails_week),
      decode(change.accumulated_emails_week_plus, 0,to_number(null),change.accumulated_emails_week_plus),
      change.request_id,
      change.program_application_id,
      change.program_id,
      change.program_update_date,
      decode(change.emails_rerouted_in_period, 0,to_number(null),change.emails_rerouted_in_period),
      decode(change.leads_created_in_period, 0,to_number(null),change.leads_created_in_period)
      );

write_log('Number of rows updated in table bix_email_details_stg for Emails Open  ' || to_char(SQL%ROWCOUNT));





MERGE INTO BIX_EMAIL_DETAILS_STG  fact
  USING
  (SELECT
      inv2.email_account_id
        email_account_id,
      inv2.email_classification_id
        email_classification_id,
      inv2.agent_id
        agent_id,
      inv2.party_id
        party_id,
      inv2.time_id
        time_id,
      1 period_type_id,
      inv2.period_start_date
        period_start_date,
      inv2.period_start_time
        period_start_time,
      inv2.outcome_id
        outcome_id,
      inv2.result_id
        result_id,
      inv2.reason_id
        reason_id,
      g_user_id
        created_by,
      g_sysdate
        creation_date,
      g_user_id
        last_updated_by,
      g_sysdate
        last_update_date,
      decode(sum(inv2.emails_offered_in_period), 0, to_number(null), sum(inv2.emails_offered_in_period))
        emails_offered_in_period,
      decode(sum(inv2.emails_fetched_in_period), 0, to_number(null), sum(inv2.emails_fetched_in_period))
        emails_fetched_in_period,
      decode(sum(inv2.emails_replied_in_period), 0, to_number(null), sum(inv2.emails_replied_in_period))
        emails_replied_in_period,
      decode(sum(inv2.emails_rpld_by_goal_in_period), 0, to_number(null), sum(inv2.emails_rpld_by_goal_in_period))
        emails_rpld_by_goal_in_period,
      decode(sum(inv2.AGENT_EMAILS_RPLD_BY_GOAL), 0, to_number(null), sum(inv2.AGENT_EMAILS_RPLD_BY_GOAL))
        AGENT_EMAILS_RPLD_BY_GOAL,
      decode(sum(inv2.emails_deleted_in_period), 0, to_number(null), sum(inv2.emails_deleted_in_period))
        emails_deleted_in_period,
      decode(sum(inv2.emails_trnsfrd_out_in_period), 0, to_number(null), sum(inv2.emails_trnsfrd_out_in_period))
        emails_trnsfrd_out_in_period,
      decode(sum(inv2.emails_trnsfrd_in_in_period), 0, to_number(null), sum(inv2.emails_trnsfrd_in_in_period))
        emails_trnsfrd_in_in_period,
      decode(sum(inv2.emails_assigned_in_period), 0, to_number(null), sum(inv2.emails_assigned_in_period))
        emails_assigned_in_period,
      decode(sum(inv2.emails_auto_routed_in_period), 0, to_number(null), sum(inv2.emails_auto_routed_in_period))
        emails_auto_routed_in_period,
      decode(sum(inv2.emails_auto_uptd_sr_in_period), 0, to_number(null), sum(inv2.emails_auto_uptd_sr_in_period))
        emails_auto_uptd_sr_in_period,
      decode(round(sum(inv2.email_resp_time_in_period)), 0, to_number(null), round(sum(inv2.email_resp_time_in_period)))
        email_resp_time_in_period,
      decode(round(sum(inv2.agent_resp_time_in_period)), 0, to_number(null), round(sum(inv2.agent_resp_time_in_period)))
        agent_resp_time_in_period,
      decode(sum(inv2.sr_created_in_period), 0, to_number(null), sum(inv2.sr_created_in_period))
        sr_created_in_period,
      decode(sum(inv2.emails_rsl_and_trfd_in_period), 0, to_number(null), sum(inv2.emails_rsl_and_trfd_in_period))
        emails_rsl_and_trfd_in_period,
      decode(sum(EMAILS_AUTO_REPLIED_IN_PERIOD), 0, to_number(null), sum(EMAILS_AUTO_REPLIED_IN_PERIOD))
        EMAILS_AUTO_REPLIED_IN_PERIOD,
      decode(sum(EMAILS_AUTO_DELETED_IN_PERIOD), 0, to_number(null), sum(EMAILS_AUTO_DELETED_IN_PERIOD))
        EMAILS_AUTO_DELETED_IN_PERIOD,
      decode(sum(EMAILS_AUTO_RESOLVED_IN_PERIOD), 0, to_number(null), sum(EMAILS_AUTO_RESOLVED_IN_PERIOD))
        EMAILS_AUTO_RESOLVED_IN_PERIOD,
      decode(sum(emails_composed_in_period), 0, to_number(null), sum(emails_composed_in_period))
        emails_composed_in_period,
      decode(sum(emails_orr_count_in_period), 0, to_number(null), sum(emails_orr_count_in_period))
        emails_orr_count_in_period,
      decode(sum(accumulated_open_emails), 0, to_number(null), sum(accumulated_open_emails))
        accumulated_open_emails,
      decode(sum(accumulated_emails_in_queue), 0, to_number(null), sum(accumulated_emails_in_queue))
        accumulated_emails_in_queue,
      decode(sum(accumulated_emails_one_day), 0, to_number(null), sum(accumulated_emails_one_day))
        accumulated_emails_one_day,
      decode(sum(accumulated_emails_three_days), 0, to_number(null), sum(accumulated_emails_three_days))
        accumulated_emails_three_days,
      decode(sum(accumulated_emails_week), 0, to_number(null), sum(accumulated_emails_week))
        accumulated_emails_week,
      decode(sum(accumulated_emails_week_plus), 0, to_number(null), sum(accumulated_emails_week_plus))
        accumulated_emails_week_plus,
      decode(sum(LEADS_CREATED_IN_PERIOD), 0, to_number(null), sum(LEADS_CREATED_IN_PERIOD))
       LEADS_CREATED_IN_PERIOD,
      decode(sum(EMAILS_REROUTED_IN_PERIOD), 0, to_number(null), sum(EMAILS_REROUTED_IN_PERIOD))
        EMAILS_REROUTED_IN_PERIOD,
      g_request_id
        request_id,
      g_program_appl_id
        program_application_id,
      g_program_id
        program_id,
      g_sysdate
        program_update_date
   FROM
    (

 SELECT
      nvl(iview.email_account_id, -1)          EMAIL_ACCOUNT_ID,
      nvl(iview.email_classification_id, -1)   EMAIL_CLASSIFICATION_ID,
      -1                                       AGENT_ID,
      nvl(iview.party_id, -1)                  PARTY_ID,
      trunc(ftd.start_date)                    PERIOD_START_DATE,
      to_number(to_char(ftd.start_date, 'J'))  TIME_ID,
      '00:00'                                  PERIOD_START_TIME,
	     -1                                       OUTCOME_ID,
      -1                                       RESULT_ID,
      -1                                       REASON_ID,
      0                                        EMAILS_OFFERED_IN_PERIOD,
      0                                        EMAILS_FETCHED_IN_PERIOD,
      0                                        EMAILS_REPLIED_IN_PERIOD,
      0                                        AGENT_RESP_TIME_IN_PERIOD,
      0                                        EMAILS_RPLD_BY_GOAL_IN_PERIOD,
      0                                        AGENT_EMAILS_RPLD_BY_GOAL,
      0                                        EMAILS_TRNSFRD_OUT_IN_PERIOD,
      0                                        EMAILS_TRNSFRD_IN_IN_PERIOD,
      0                                        EMAILS_ASSIGNED_IN_PERIOD,
      0                                        EMAILS_AUTO_ROUTED_IN_PERIOD,
      0                                        EMAILS_AUTO_UPTD_SR_IN_PERIOD,
      0                                        EMAILS_DELETED_IN_PERIOD,
      0                                        EMAIL_RESP_TIME_IN_PERIOD,
      0                                        SR_CREATED_IN_PERIOD,
      0                                        EMAILS_RSL_AND_TRFD_IN_PERIOD,
      0                                        EMAILS_AUTO_REPLIED_IN_PERIOD,
      0                                        EMAILS_AUTO_DELETED_IN_PERIOD,
      0                                        EMAILS_AUTO_RESOLVED_IN_PERIOD,
      0                                        emails_composed_in_period,
      0                                        emails_orr_count_in_period,
      0                                        accumulated_open_emails,
      sum(CASE WHEN ((iview.end_date_time - ftd.start_date) > 1) THEN 1
               WHEN (((iview.end_date_time - ftd.start_date) <= 1) AND (flag = 1)) THEN 1
               ELSE 0 END)                     accumulated_emails_in_queue,
      sum(CASE WHEN
          (decode(sign(iview.end_date_time - (ftd.start_date+1)), 1, ftd.start_date+1, iview.end_date_time) - media_start_date_time >= 0 AND
           decode(sign(iview.end_date_time - (ftd.start_date+1)), 1, ftd.start_date+1, iview.end_date_time) - media_start_date_time <= 1 AND
           decode(sign((iview.end_date_time - ftd.start_date) -1), 1, 1, decode(flag, 1, 1, 0)) = 1) THEN 1 else 0 END)
                                          accumulated_emails_one_day,
      sum(CASE WHEN
          (decode(sign(iview.end_date_time - (ftd.start_date+1)), 1, ftd.start_date+1, iview.end_date_time) - media_start_date_time > 1 AND
           decode(sign(iview.end_date_time - (ftd.start_date+1)), 1, ftd.start_date+1, iview.end_date_time) - media_start_date_time <= 3 AND
           decode(sign((iview.end_date_time - ftd.start_date) -1), 1, 1, decode(flag, 1, 1, 0)) = 1) THEN 1 else 0 END)
                                          accumulated_emails_three_days,
      sum(CASE WHEN
          (decode(sign(iview.end_date_time - (ftd.start_date+1)), 1, ftd.start_date+1, iview.end_date_time) - media_start_date_time > 3 AND
           decode(sign(iview.end_date_time - (ftd.start_date+1)), 1, ftd.start_date+1, iview.end_date_time) - media_start_date_time <= 7 AND
           decode(sign((iview.end_date_time - ftd.start_date) -1), 1, 1, decode(flag, 1, 1, 0)) = 1) THEN 1 else 0 END)
                                          accumulated_emails_week,
      sum(CASE WHEN
          (decode(sign(iview.end_date_time - (ftd.start_date+1)), 1, ftd.start_date+1, iview.end_date_time) - media_start_date_time > 7 AND
           decode(sign((iview.end_date_time - ftd.start_date) -1), 1, 1, decode(flag, 1, 1, 0)) = 1) THEN 1 else 0 END)
                                          accumulated_emails_week_plus,
	 0                                                    EMAILS_REROUTED_IN_PERIOD,
	 0                                                    LEADS_CREATED_IN_PERIOD
    FROM
      fii_time_day ftd,
--
--Currently in QUEUE or in QUEUE until collect end date
--
(
SELECT
         media_id                             MEDIA_ID,
         nvl(email_account_id, -1)            EMAIL_ACCOUNT_ID,
         nvl(email_classification_id, -1) EMAIL_CLASSIFICATION_ID,
         nvl(party_id, -1)                    PARTY_ID,
         decode(sign(max(seg_start_date_time) - g_collect_start_date), 1, max(seg_start_date_time), g_collect_start_date)
                                              START_DATE_TIME,
         g_collect_end_date                   END_DATE_TIME,
         max(media_start_date_time)           MEDIA_START_DATE_TIME,
         1                                    FLAG
FROM
   (
      SELECT  /*+ ordered index(mseg JTF_IH_MEDIA_ITEM_LC_SEGS_N3) use_nl(mseg,mitm,act,int)*/
         mitm.media_id                        MEDIA_ID,
         mseg.milcs_id                        MILCS_ID,
         nvl(mitm.source_id, -1)              EMAIL_ACCOUNT_ID,
         nvl(cls.route_classification_id, -1) EMAIL_CLASSIFICATION_ID,
         first_value(int.party_id) over(partition by act.media_id order by act.interaction_id DESC) PARTY_ID,
         mseg.start_date_time                 SEG_START_DATE_TIME,
         mitm.start_date_time                 MEDIA_START_DATE_TIME
       FROM
         JTF_IH_MEDIA_ITEM_LC_SEGS   mseg,
		 JTF_IH_MEDIA_ITEMS          mitm,
         JTF_IH_ACTIVITIES act,
         JTF_IH_INTERACTIONS int,
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) cls
       WHERE
	   --mitm.MEDIA_ITEM_TYPE = 'EMAIL' /* Is this necessary? Without it the unique filter is getting used*/
	   1=1
       AND   mitm.DIRECTION       = 'INBOUND'
       AND   int.interaction_id = act.interaction_id
       AND   act.media_id         = mitm.media_id
       AND   mitm.classification  = cls.name(+)
       AND   mitm.MEDIA_ID        = mseg.MEDIA_ID
       AND   mseg.START_DATE_TIME < g_collect_end_date
       AND   mseg.MILCS_TYPE_ID   = g_processing/* Requeued removed for bug 5337716*/
       AND   NOT EXISTS
        (
         SELECT
	         1
         FROM JTF_IH_MEDIA_ITEM_LC_SEGS   mseg1
         WHERE  mseg.MEDIA_ID       = mseg1.MEDIA_ID
         AND    mseg1.MILCS_TYPE_ID in (
		 G_FETCH, G_RESOLVED, G_A_REDIRECTED, G_A_DELETED, G_A_REPLY, G_OPEN, G_A_ROUTED, G_A_UPDATED_SR,
         G_ASSIGNED, G_ASSIGN_OPEN,G_DELETED)
         AND    mseg1.START_DATE_TIME >= mseg.START_DATE_TIME
         AND    mseg1.START_DATE_TIME < g_collect_end_date
        )
   )
GROUP BY media_id, milcs_id,nvl(email_account_id, -1), nvl(email_classification_id, -1) ,nvl(party_id, -1)
       UNION
       SELECT /*+ ordered  index(mseg2 JTF_IH_MEDIA_ITEM_LC_SEGS_N3) use_nl(mseg2,mitm2) */
         mitm2.media_id                        MEDIA_ID,
         nvl(mitm2.source_id, -1)              EMAIL_ACCOUNT_ID,
         nvl(cls2.route_classification_id, -1) EMAIL_CLASSIFICATION_ID,
         nvl(inv1.party_id, -1)                PARTY_ID,
         decode(sign(mseg2.start_date_time - g_collect_start_date), 1, mseg2.start_date_time, g_collect_start_date)
                                               START_DATE_TIME,
         min(inv2.start_date_time)              END_DATE_TIME,
         mitm2.start_date_time                 MEDIA_START_DATE_TIME,
         0                                     FLAG
       FROM
         JTF_IH_MEDIA_ITEM_LC_SEGS mseg2,
         JTF_IH_MEDIA_ITEMS mitm2,
	     (
		select name, max(route_classification_id) route_classification_id
	    from iem_route_classifications
	    group by name
		) cls2,
         (
             SELECT /*+ index(mseg3 JTF_IH_MEDIA_ITEM_LC_SEGS_N3) */
                    mseg3.media_id,
                    mseg3.resource_id,
                    mseg3.start_date_time
             FROM   JTF_IH_MEDIA_ITEM_LC_SEGS   mseg3
             WHERE  mseg3.milcs_type_id IN (G_FETCH,G_OPEN,G_A_ROUTED,G_RESOLVED,G_ASSIGNED,G_ASSIGN_OPEN,G_A_UPDATED_SR,G_A_REPLY,G_A_DELETED,G_A_REDIRECTED)
             AND    mseg3.START_DATE_TIME < g_collect_end_date
         ) inv2,
         (
			  SELECT /*+ ordered index(segs JTF_IH_MEDIA_ITEM_LC_SEGS_N3)  */
           distinct actv.media_id        media_id,
           first_value(intr.party_id)
           over(partition by actv.media_id order by actv.interaction_id desc) party_id
         FROM
           jtf_ih_media_item_lc_segs segs,
           jtf_ih_activities actv,
           jtf_ih_interactions intr
         WHERE segs.media_id = actv.media_id
         AND actv.interaction_id = intr.interaction_id
         AND segs.START_DATE_TIME BETWEEN g_collect_start_date AND g_collect_end_date
         AND segs.milcs_type_id IN (
		 G_FETCH, G_RESOLVED, G_A_REDIRECTED, G_A_DELETED, G_A_REPLY, G_OPEN, G_A_ROUTED, G_A_UPDATED_SR,
         G_ASSIGNED, G_ASSIGN_OPEN,G_DELETED )
         ) inv1
       WHERE
	   --mitm2.MEDIA_ITEM_TYPE = 'EMAIL'
	   1=1
       AND   mitm2.DIRECTION       = 'INBOUND'
       AND   mseg2.media_id        = mitm2.media_id
       AND   mitm2.classification  = cls2.name(+)
       AND   mitm2.MEDIA_ID        = inv2.MEDIA_ID
       AND   mitm2.media_id         = inv1.media_id
       AND   mseg2.START_DATE_TIME < g_collect_end_date
       AND   mseg2.MILCS_TYPE_ID   = g_processing
       AND   inv2.START_DATE_TIME   >= mseg2.START_DATE_TIME
       GROUP BY
         mitm2.media_id,
         nvl(mitm2.source_id, -1),
         nvl(cls2.route_classification_id, -1),
    inv1.party_id,
         mseg2.start_date_time,
         mitm2.start_date_time
	 ) iview
    WHERE ftd.start_date between trunc(iview.start_date_time) AND iview.end_date_time
    GROUP BY
      iview.email_account_id
      ,iview.email_classification_id
      ,iview.party_id
      ,ftd.start_date
)inv2
GROUP BY
      inv2.email_account_id,
      inv2.email_classification_id,
      inv2.agent_id,
      inv2.party_id,
      inv2.time_id,
      inv2.period_start_date,
      inv2.period_start_time,
      inv2.outcome_id,
      inv2.result_id,
      inv2.reason_id
)  change
  ON (
      fact.email_account_id = change.email_account_id
      AND fact.email_classification_id = change.email_classification_id
      AND fact.agent_id = change.agent_id
      AND fact.party_id = change.party_id
      AND fact.time_id = change.time_id
      AND fact.period_type_id = change.period_type_id
      AND fact.period_start_date = change.period_start_date
      AND fact.period_start_time = change.period_start_time
      AND fact.outcome_id = change.outcome_id
      AND fact.result_id = change.result_id
      AND fact.reason_id = change.reason_id )
  WHEN MATCHED THEN
    UPDATE
      SET fact.emails_offered_in_period = DECODE(nvl(fact.emails_offered_in_period,0) + nvl(change.emails_offered_in_period,0),
             0, NULL, nvl(fact.emails_offered_in_period,0) + nvl(change.emails_offered_in_period,0))
      ,fact.emails_fetched_in_period = DECODE(nvl(fact.emails_fetched_in_period,0) + nvl(change.emails_fetched_in_period,0),
             0, NULL, nvl(fact.emails_fetched_in_period,0) + nvl(change.emails_fetched_in_period,0))
      ,fact.emails_replied_in_period = DECODE(nvl(fact.emails_replied_in_period,0) + nvl(change.emails_replied_in_period,0),
             0, NULL, nvl(fact.emails_replied_in_period,0) + nvl(change.emails_replied_in_period,0))
      ,fact.emails_rpld_by_goal_in_period = DECODE(nvl(fact.emails_rpld_by_goal_in_period,0) + nvl(change.emails_rpld_by_goal_in_period,
             0), 0, NULL, nvl(fact.emails_rpld_by_goal_in_period,0) + nvl(change.emails_rpld_by_goal_in_period,0))
      ,fact.AGENT_EMAILS_RPLD_BY_GOAL = DECODE(nvl(fact.AGENT_EMAILS_RPLD_BY_GOAL,0) + nvl(change.AGENT_EMAILS_RPLD_BY_GOAL,
                   0), 0, NULL, nvl(fact.AGENT_EMAILS_RPLD_BY_GOAL,0) + nvl(change.AGENT_EMAILS_RPLD_BY_GOAL,0))
      ,fact.emails_deleted_in_period = DECODE(nvl(fact.emails_deleted_in_period,0) + nvl(change.emails_deleted_in_period,0), 0, NULL,
             nvl(fact.emails_deleted_in_period,0) + nvl(change.emails_deleted_in_period,0))
      ,fact.emails_trnsfrd_out_in_period = DECODE(nvl(fact.emails_trnsfrd_out_in_period,0) + nvl(change.emails_trnsfrd_out_in_period,0),
             0, NULL, nvl(fact.emails_trnsfrd_out_in_period,0) + nvl(change.emails_trnsfrd_out_in_period,0))
      ,fact.emails_trnsfrd_in_in_period = DECODE(nvl(fact.emails_trnsfrd_in_in_period,0) + nvl(change.emails_trnsfrd_in_in_period,0),
             0, NULL, nvl(fact.emails_trnsfrd_in_in_period,0) + nvl(change.emails_trnsfrd_in_in_period,0))
      ,fact.emails_assigned_in_period = DECODE(nvl(fact.emails_assigned_in_period,0) + nvl(change.emails_assigned_in_period,0),
             0, NULL, nvl(fact.emails_assigned_in_period,0) + nvl(change.emails_assigned_in_period,0))
      ,fact.emails_auto_routed_in_period = DECODE(nvl(fact.emails_auto_routed_in_period,0) + nvl(change.emails_auto_routed_in_period,0),
             0, NULL, nvl(fact.emails_auto_routed_in_period,0) + nvl(change.emails_auto_routed_in_period,0))
      ,fact.emails_auto_uptd_sr_in_period = DECODE(nvl(fact.emails_auto_uptd_sr_in_period,0) + nvl(change.emails_auto_uptd_sr_in_period,0),
             0, NULL, nvl(fact.emails_auto_uptd_sr_in_period,0) + nvl(change.emails_auto_uptd_sr_in_period,0))
      ,fact.email_resp_time_in_period = DECODE(nvl(fact.email_resp_time_in_period,0) + nvl(change.email_resp_time_in_period,0),
             0, NULL, nvl(fact.email_resp_time_in_period,0) + nvl(change.email_resp_time_in_period,0))
      ,fact.agent_resp_time_in_period = DECODE(nvl(fact.agent_resp_time_in_period,0) + nvl(change.agent_resp_time_in_period,0),
             0, NULL, nvl(fact.agent_resp_time_in_period,0) + nvl(change.agent_resp_time_in_period,0))
      ,fact.sr_created_in_period = DECODE(nvl(fact.sr_created_in_period,0) + nvl(change.sr_created_in_period,0),
             0, NULL, nvl(fact.sr_created_in_period,0) + nvl(change.sr_created_in_period,0))
      ,fact.emails_rsl_and_trfd_in_period = DECODE(nvl(fact.emails_rsl_and_trfd_in_period,0) + nvl(change.emails_rsl_and_trfd_in_period,0),
             0, NULL, nvl(fact.emails_rsl_and_trfd_in_period,0) + nvl(change.emails_rsl_and_trfd_in_period,0))
      ,fact.emails_orr_count_in_period = DECODE(nvl(fact.emails_orr_count_in_period,0) + nvl(change.emails_orr_count_in_period,0),
             0, NULL, nvl(fact.emails_orr_count_in_period,0) + nvl(change.emails_orr_count_in_period,0))
      ,fact.EMAILS_AUTO_REPLIED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0),
             0, NULL, nvl(fact.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0))
      ,fact.EMAILS_AUTO_DELETED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_DELETED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_DELETED_IN_PERIOD,0),
             0, NULL, nvl(fact.EMAILS_AUTO_DELETED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_DELETED_IN_PERIOD,0))
      ,fact.EMAILS_AUTO_RESOLVED_IN_PERIOD = DECODE(nvl(fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,
             0), 0, NULL, nvl(fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + nvl(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,0))
      ,fact.emails_composed_in_period = DECODE(nvl(fact.emails_composed_in_period,0) + nvl(change.emails_composed_in_period,0),
             0, NULL, nvl(fact.emails_composed_in_period,0) + nvl(change.emails_composed_in_period,0))
--
--Note that accumulated measures are not added together - they are replaced by the new
--calculated value as they are not additive.
--
      ,fact.accumulated_open_emails = decode(change.accumulated_open_emails,0,to_number(NULL),change.accumulated_open_emails)
      ,fact.accumulated_emails_in_queue = decode(change.accumulated_emails_in_queue,0,to_number(NULL),change.accumulated_emails_in_queue)
      ,fact.accumulated_emails_one_day = decode(change.accumulated_emails_one_day,0,to_number(NULL),change.accumulated_emails_one_day)
      ,fact.accumulated_emails_three_days = decode(change.accumulated_emails_three_days,0,to_number(NULL),change.accumulated_emails_three_days)
      ,fact.accumulated_emails_week = decode(change.accumulated_emails_week,0,to_number(NULL),change.accumulated_emails_week)
      ,fact.accumulated_emails_week_plus = decode(change.accumulated_emails_week_plus,0,to_number(NULL),change.accumulated_emails_week_plus)
      ,fact.last_updated_by = change.last_updated_by
      ,fact.last_update_date = change.last_update_date
      ,fact.emails_rerouted_in_period = DECODE(nvl(fact.emails_rerouted_in_period,0) + nvl(change.emails_rerouted_in_period,0),
             0, NULL, nvl(fact.emails_rerouted_in_period,0) + nvl(change.emails_rerouted_in_period,0))
      ,fact.leads_created_in_period = DECODE(nvl(fact.leads_created_in_period,0) + nvl(change.leads_created_in_period,0),
             0, NULL, nvl(fact.leads_created_in_period,0) + nvl(change.leads_created_in_period,0))
  WHEN NOT MATCHED THEN
    INSERT (
      fact.email_account_id,
      fact.email_classification_id,
      fact.agent_id,
      fact.party_id,
      fact.time_id,
      fact.period_type_id,
      fact.period_start_date,
      fact.period_start_time,
      fact.outcome_id,
      fact.result_id,
      fact.reason_id,
      fact.created_by,
      fact.creation_date,
      fact.last_updated_by,
      fact.last_update_date,
      fact.emails_offered_in_period,
      fact.emails_fetched_in_period,
      fact.emails_replied_in_period,
      fact.emails_rpld_by_goal_in_period,
      fact.AGENT_EMAILS_RPLD_BY_GOAL,
      fact.emails_deleted_in_period,
      fact.emails_trnsfrd_out_in_period,
      fact.emails_trnsfrd_in_in_period,
      fact.emails_assigned_in_period,
      fact.emails_auto_routed_in_period,
      fact.emails_auto_uptd_sr_in_period,
      fact.email_resp_time_in_period,
      fact.agent_resp_time_in_period,
      fact.sr_created_in_period,
      fact.emails_rsl_and_trfd_in_period,
      fact.emails_orr_count_in_period,
      fact.EMAILS_AUTO_REPLIED_IN_PERIOD,
      fact.EMAILS_AUTO_DELETED_IN_PERIOD,
      fact.EMAILS_AUTO_RESOLVED_IN_PERIOD,
      fact.emails_composed_in_period,
      fact.accumulated_open_emails,
      fact.accumulated_emails_in_queue,
      fact.accumulated_emails_one_day,
      fact.accumulated_emails_three_days,
      fact.accumulated_emails_week,
      fact.accumulated_emails_week_plus,
      fact.request_id,
      fact.program_application_id,
      fact.program_id,
      fact.program_update_date,
      fact.emails_rerouted_in_period,
      fact.leads_created_in_period )
    VALUES (
      change.email_account_id,
      change.email_classification_id,
      change.agent_id,
      change.party_id,
      change.time_id,
      change.period_type_id,
      change.period_start_date,
      change.period_start_time,
      change.outcome_id,
      change.result_id,
      change.reason_id,
      change.created_by,
      change.creation_date,
      change.last_updated_by,
      change.last_update_date,
      decode(change.emails_offered_in_period,0,to_number(null), change.emails_offered_in_period),
      decode(change.emails_fetched_in_period, 0,to_number(null),change.emails_fetched_in_period),
      decode(change.emails_replied_in_period, 0,to_number(null),change.emails_replied_in_period),
      decode(change.emails_rpld_by_goal_in_period, 0,to_number(null),change.emails_rpld_by_goal_in_period),
      decode(change.AGENT_EMAILS_RPLD_BY_GOAL, 0,to_number(null),change.AGENT_EMAILS_RPLD_BY_GOAL),
      decode(change.emails_deleted_in_period, 0,to_number(null),change.emails_deleted_in_period),
      decode(change.emails_trnsfrd_out_in_period, 0,to_number(null),change.emails_trnsfrd_out_in_period),
      decode(change.emails_trnsfrd_in_in_period, 0,to_number(null),change.emails_trnsfrd_in_in_period),
      decode(change.emails_assigned_in_period, 0,to_number(null),change.emails_assigned_in_period),
      decode(change.emails_auto_routed_in_period, 0,to_number(null),change.emails_auto_routed_in_period),
      decode(change.emails_auto_uptd_sr_in_period, 0,to_number(null),change.emails_auto_uptd_sr_in_period),
      decode(change.email_resp_time_in_period, 0,to_number(null),change.email_resp_time_in_period),
      decode(change.agent_resp_time_in_period, 0,to_number(null),change.agent_resp_time_in_period),
      decode(change.sr_created_in_period, 0,to_number(null),change.sr_created_in_period),
      decode(change.emails_rsl_and_trfd_in_period, 0,to_number(null),change.emails_rsl_and_trfd_in_period),
      decode(change.emails_orr_count_in_period, 0,to_number(null),change.emails_orr_count_in_period),
      decode(change.EMAILS_AUTO_REPLIED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_REPLIED_IN_PERIOD),
      decode(change.EMAILS_AUTO_DELETED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_DELETED_IN_PERIOD),
      decode(change.EMAILS_AUTO_RESOLVED_IN_PERIOD, 0,to_number(null),change.EMAILS_AUTO_RESOLVED_IN_PERIOD),
      decode(change.emails_composed_in_period, 0,to_number(null),change.emails_composed_in_period),
      decode(change.accumulated_open_emails, 0,to_number(null),change.accumulated_open_emails),
      decode(change.accumulated_emails_in_queue, 0,to_number(null),change.accumulated_emails_in_queue),
      decode(change.accumulated_emails_one_day, 0,to_number(null),change.accumulated_emails_one_day),
      decode(change.accumulated_emails_three_days, 0,to_number(null),change.accumulated_emails_three_days),
      decode(change.accumulated_emails_week, 0,to_number(null),change.accumulated_emails_week),
      decode(change.accumulated_emails_week_plus, 0,to_number(null),change.accumulated_emails_week_plus),
      change.request_id,
      change.program_application_id,
      change.program_id,
      change.program_update_date,
      decode(change.emails_rerouted_in_period, 0,to_number(null),change.emails_rerouted_in_period),
      decode(change.leads_created_in_period, 0,to_number(null),change.leads_created_in_period)
      );


write_log('Number of rows updated in table bix_email_details_stg for Emails in Queue  ' || to_char(SQL%ROWCOUNT));

 COMMIT;

  write_log('Number of rows updated in table bix_email_details_f : ' || to_char(SQL%ROWCOUNT));

  g_rows_ins_upd := g_rows_ins_upd + SQL%ROWCOUNT;

  write_log('Finished procedure collect_emails at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure collect_emails : Error : ' || sqlerrm);
    RAISE;
END collect_emails;


PROCEDURE rollup_negatives ( p_min_date IN DATE)  IS

BEGIN

  write_log('Start of the procedure rollup_negatives at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  write_log('Merging day rows to week, month, quarter, year bucket in table bix_email_details_f');

  /* Rollup half hour information to day, week, month, quarter, year time bucket for table bix_email_details_f */


  MERGE INTO bix_email_details_f bead
  USING (
  SELECT
    rlp.agent_id                                     agent_id,
    rlp.email_account_id                             email_account_id,
    rlp.email_classification_id                      email_classification_id,
    rlp.party_id                                     party_id,
    rlp.time_id                                      time_id,
    rlp.period_type_id                               period_type_id,
    rlp.period_start_date                            period_start_date,
    rlp.period_start_time                            period_start_time,
    rlp.outcome_id                                   outcome_id,
    rlp.result_id                                    result_id,
    rlp.reason_id                                    reason_id,
    (-1)*decode(sum(rlp.emails_offered_in_period), 0, to_number(null), sum(rlp.emails_offered_in_period))
                                                     emails_offered_in_period,
    (-1)*decode(sum(rlp.emails_fetched_in_period), 0, to_number(null), sum(rlp.emails_fetched_in_period))
                                                     emails_fetched_in_period,
    (-1)*decode(sum(rlp.emails_replied_in_period), 0, to_number(null), sum(rlp.emails_replied_in_period))
                                                     emails_replied_in_period,
    (-1)*decode(sum(rlp.emails_rpld_by_goal_in_period), 0, to_number(null), sum(rlp.emails_rpld_by_goal_in_period))
                                                     emails_rpld_by_goal_in_period,
    (-1)*decode(sum(rlp.AGENT_EMAILS_RPLD_BY_GOAL), 0, to_number(null), sum(rlp.AGENT_EMAILS_RPLD_BY_GOAL))
                                                         AGENT_EMAILS_RPLD_BY_GOAL,
    (-1)*decode(sum(rlp.emails_deleted_in_period), 0, to_number(null), sum(rlp.emails_deleted_in_period))
                                                     emails_deleted_in_period,
    (-1)*decode(sum(rlp.emails_trnsfrd_out_in_period), 0, to_number(null), sum(rlp.emails_trnsfrd_out_in_period))
                                                     emails_trnsfrd_out_in_period,
    (-1)*decode(sum(rlp.emails_trnsfrd_in_in_period), 0, to_number(null), sum(rlp.emails_trnsfrd_in_in_period))
                                                     emails_trnsfrd_in_in_period,
    (-1)*decode(sum(rlp.emails_rsl_and_trfd_in_period), 0, to_number(null), sum(rlp.emails_rsl_and_trfd_in_period))
                                                     emails_rsl_and_trfd_in_period,
    (-1)*decode(sum(rlp.emails_assigned_in_period), 0, to_number(null), sum(rlp.emails_assigned_in_period))
                                                     emails_assigned_in_period,
    (-1)*decode(sum(rlp.emails_auto_routed_in_period), 0, to_number(null), sum(rlp.emails_auto_routed_in_period))
                                                     emails_auto_routed_in_period,
    (-1)*decode(sum(rlp.emails_auto_uptd_sr_in_period), 0, to_number(null), sum(rlp.emails_auto_uptd_sr_in_period))
                                                     emails_auto_uptd_sr_in_period,
    (-1)*decode(sum(rlp.sr_created_in_period), 0, to_number(null), sum(rlp.sr_created_in_period))
                                                     sr_created_in_period,
    to_date(null)                                    oldest_email_open_date,
    to_date(null)                                    oldest_email_queue_date,
    (-1)*decode(sum(rlp.email_resp_time_in_period), 0, to_number(null), sum(rlp.email_resp_time_in_period))
                                                     email_resp_time_in_period,
    (-1)*decode(sum(rlp.agent_resp_time_in_period), 0, to_number(null), sum(rlp.agent_resp_time_in_period))
                                                     agent_resp_time_in_period,
    (-1)*min(rlp.acc_open_emails)                         acc_open_emails,
    to_number(null)                                  acc_open_age,
    (-1)*min(rlp.acc_emails_in_queue)                     acc_emails_in_queue,
    to_number(null)                                  acc_queue_time,
    (-1)*min(rlp.acc_emails_one_day)                      acc_emails_one_day,
    (-1)*min(rlp.acc_emails_three_days)                   acc_emails_three_days,
    (-1)*min(rlp.acc_emails_week)                         acc_emails_week,
    (-1)*min(rlp.acc_emails_week_plus)                    acc_emails_week_plus,
    (-1)*decode(sum(rlp.emails_orr_count_in_period),0,to_number(null),sum(emails_orr_count_in_period)) emails_orr_count_in_period,
    (-1)*decode(sum(rlp.EMAILS_AUTO_REPLIED_IN_PERIOD),0,to_number(null),sum(EMAILS_AUTO_REPLIED_IN_PERIOD)) EMAILS_AUTO_REPLIED_IN_PERIOD,
    (-1)*decode(sum(rlp.EMAILS_AUTO_DELETED_IN_PERIOD),0,to_number(null),sum(EMAILS_AUTO_DELETED_IN_PERIOD)) EMAILS_AUTO_DELETED_IN_PERIOD,
    (-1)*decode(sum(rlp.EMAILS_AUTO_RESOLVED_IN_PERIOD),0,to_number(null),sum(EMAILS_AUTO_RESOLVED_IN_PERIOD)) EMAILS_AUTO_RESOLVED_IN_PERIOD,
    (-1)*decode(sum(rlp.emails_composed_in_period),0,to_number(null),sum(emails_composed_in_period)) emails_composed_in_period,
    (-1)*decode(sum(rlp.emails_rerouted_in_period),0,to_number(null),sum(emails_rerouted_in_period)) emails_rerouted_in_period,
    (-1)*decode(sum(rlp.leads_created_in_period),0,to_number(null),sum(leads_created_in_period)) leads_created_in_period ,
    (-1)*decode(sum(rlp.ONE_RSLN_IN_PERIOD),0,to_number(null),sum(ONE_RSLN_IN_PERIOD)) ONE_RSLN_IN_PERIOD,
    (-1)*decode(sum(rlp.TWO_RSLN_IN_PERIOD),0,to_number(null),sum(TWO_RSLN_IN_PERIOD)) TWO_RSLN_IN_PERIOD,
    (-1)*decode(sum(rlp.THREE_RSLN_IN_PERIOD),0,to_number(null),sum(THREE_RSLN_IN_PERIOD)) THREE_RSLN_IN_PERIOD,
    (-1)*decode(sum(rlp.FOUR_RSLN_IN_PERIOD),0,to_number(null),sum(FOUR_RSLN_IN_PERIOD)) FOUR_RSLN_IN_PERIOD,
    (-1)*decode(sum(rlp.INTERACTION_THREADS_IN_PERIOD),0,to_number(null),sum(INTERACTION_THREADS_IN_PERIOD)) INTERACTION_THREADS_IN_PERIOD
  FROM (
    SELECT
      inv2.agent_id agent_id,
      inv2.email_account_id email_account_id,
      inv2.email_classification_id email_classification_id,
      inv2.party_id party_id,
      inv2.outcome_id outcome_id,
      inv2.result_id result_id,
      inv2.reason_id reason_id,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), inv2.ent_year_id),
              inv2.ent_qtr_id), inv2.ent_period_id), inv2.week_id) time_id,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null),
              128), 64), 32), 16) period_type_id,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_date(null), min(inv2.ent_year_start_date)),
              min(inv2.ent_qtr_start_date)), min(inv2.ent_period_start_date)), min(inv2.week_start_date)) period_start_date,
      '00:00' period_start_time,
      sum(inv2.emails_offered_in_period) emails_offered_in_period,
      sum(inv2.emails_fetched_in_period) emails_fetched_in_period,
      sum(inv2.emails_replied_in_period) emails_replied_in_period,
      sum(inv2.emails_rpld_by_goal_in_period) emails_rpld_by_goal_in_period,
      sum(inv2.AGENT_EMAILS_RPLD_BY_GOAL) AGENT_EMAILS_RPLD_BY_GOAL,
      sum(inv2.emails_deleted_in_period) emails_deleted_in_period,
      sum(inv2.emails_trnsfrd_out_in_period) emails_trnsfrd_out_in_period,
      sum(inv2.emails_trnsfrd_in_in_period) emails_trnsfrd_in_in_period,
      sum(inv2.emails_rsl_and_trfd_in_period) emails_rsl_and_trfd_in_period,
      sum(inv2.emails_assigned_in_period) emails_assigned_in_period,
      sum(inv2.emails_auto_routed_in_period) emails_auto_routed_in_period,
      sum(inv2.emails_auto_uptd_sr_in_period) emails_auto_uptd_sr_in_period,
      sum(inv2.sr_created_in_period) sr_created_in_period,
      sum(inv2.email_resp_time_in_period) email_resp_time_in_period,
      sum(inv2.agent_resp_time_in_period) agent_resp_time_in_period,
      sum(inv2.emails_orr_count_in_period) emails_orr_count_in_period,
      sum(inv2.EMAILS_AUTO_REPLIED_IN_PERIOD) EMAILS_AUTO_REPLIED_IN_PERIOD,
      sum(inv2.EMAILS_AUTO_DELETED_IN_PERIOD) EMAILS_AUTO_DELETED_IN_PERIOD,
      sum(inv2.EMAILS_AUTO_RESOLVED_IN_PERIOD) EMAILS_AUTO_RESOLVED_IN_PERIOD,
      sum(inv2.emails_composed_in_period) emails_composed_in_period,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_open_emails)),
              min(inv2.qtr_acc_open_emails)), min(inv2.period_acc_open_emails)), min(inv2.week_acc_open_emails)) acc_open_emails,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_emails_in_queue)),
              min(inv2.qtr_acc_emails_in_queue)), min(inv2.period_acc_emails_in_queue)), min(inv2.week_acc_emails_in_queue))
         acc_emails_in_queue,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_emails_one_day)),
              min(inv2.qtr_acc_emails_one_day)), min(inv2.period_acc_emails_one_day)), min(inv2.week_acc_emails_one_day)) acc_emails_one_day,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_emails_three_days)),
              min(inv2.qtr_acc_emails_three_days)), min(inv2.period_acc_emails_three_days)),
                min(inv2.week_acc_emails_three_days))            acc_emails_three_days,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_emails_week)),
              min(inv2.qtr_acc_emails_week)), min(inv2.period_acc_emails_week)), min(inv2.week_acc_emails_week)) acc_emails_week,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_emails_week_plus)),
              min(inv2.qtr_acc_emails_week_plus)), min(inv2.period_acc_emails_week_plus)),
                min(inv2.week_acc_emails_week_plus))  acc_emails_week_plus,
      sum(inv2.EMAILS_REROUTED_IN_PERIOD) EMAILS_REROUTED_IN_PERIOD,
      sum(inv2.LEADS_CREATED_IN_PERIOD) LEADS_CREATED_IN_PERIOD,
      sum(inv2.ONE_RSLN_IN_PERIOD) ONE_RSLN_IN_PERIOD,
      sum(inv2.TWO_RSLN_IN_PERIOD) TWO_RSLN_IN_PERIOD,
      sum(inv2.THREE_RSLN_IN_PERIOD) THREE_RSLN_IN_PERIOD,
      sum(inv2.FOUR_RSLN_IN_PERIOD) FOUR_RSLN_IN_PERIOD,
      sum(inv2.INTERACTION_THREADS_IN_PERIOD) INTERACTION_THREADS_IN_PERIOD
    FROM
      (SELECT /*+ index(bead BIX_EMAIL_DETAILS_F_N1) */
         bead.agent_id agent_id,
         bead.email_account_id email_account_id,
         bead.email_classification_id email_classification_id,
         bead.party_id party_id,
         bead.outcome_id,
         bead.result_id,
         bead.reason_id,
         ftd.ent_year_id ent_year_id,
         ftd.ent_year_start_date ent_year_start_date,
         ftd.ent_qtr_id ent_qtr_id,
         ftd.ent_qtr_start_date ent_qtr_start_date,
         ftd.ent_period_id ent_period_id,
         ftd.ent_period_start_date ent_period_start_date,
         ftd.week_id  week_id,
         ftd.week_start_date week_start_date,
         bead.period_start_date period_start_date,
         bead.emails_offered_in_period emails_offered_in_period,
         bead.emails_fetched_in_period emails_fetched_in_period,
         bead.emails_replied_in_period emails_replied_in_period,
         bead.emails_rpld_by_goal_in_period emails_rpld_by_goal_in_period,
         bead.AGENT_EMAILS_RPLD_BY_GOAL AGENT_EMAILS_RPLD_BY_GOAL,
         bead.emails_deleted_in_period emails_deleted_in_period,
         bead.emails_trnsfrd_out_in_period emails_trnsfrd_out_in_period,
         bead.emails_trnsfrd_in_in_period emails_trnsfrd_in_in_period,
         bead.emails_rsl_and_trfd_in_period emails_rsl_and_trfd_in_period,
         bead.emails_assigned_in_period emails_assigned_in_period,
         bead.emails_auto_routed_in_period emails_auto_routed_in_period,
         bead.emails_auto_uptd_sr_in_period emails_auto_uptd_sr_in_period,
         bead.sr_created_in_period sr_created_in_period,
         bead.email_resp_time_in_period email_resp_time_in_period,
         bead.agent_resp_time_in_period agent_resp_time_in_period,
         bead.emails_orr_count_in_period emails_orr_count_in_period,
         bead.EMAILS_AUTO_REPLIED_IN_PERIOD EMAILS_AUTO_REPLIED_IN_PERIOD,
         bead.EMAILS_AUTO_DELETED_IN_PERIOD EMAILS_AUTO_DELETED_IN_PERIOD,
         bead.EMAILS_AUTO_RESOLVED_IN_PERIOD EMAILS_AUTO_RESOLVED_IN_PERIOD,
         bead.emails_composed_in_period emails_composed_in_period,
	    bead.emails_rerouted_in_period emails_rerouted_in_period,
	    bead.leads_created_in_period leads_created_in_period,
         bead.ONE_RSLN_IN_PERIOD ONE_RSLN_IN_PERIOD,
         bead.TWO_RSLN_IN_PERIOD TWO_RSLN_IN_PERIOD,
         bead.THREE_RSLN_IN_PERIOD THREE_RSLN_IN_PERIOD,
         bead.FOUR_RSLN_IN_PERIOD FOUR_RSLN_IN_PERIOD,
         bead.INTERACTION_THREADS_IN_PERIOD INTERACTION_THREADS_IN_PERIOD,
         first_value(bead.accumulated_open_emails)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.week_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_open_emails,
         first_value(bead.accumulated_open_emails)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_period_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_open_emails,
         first_value(bead.accumulated_open_emails)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_qtr_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_open_emails,
         first_value(bead.accumulated_open_emails)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_year_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_open_emails,
         first_value(bead.accumulated_emails_in_queue)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.week_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_emails_in_queue,
         first_value(bead.accumulated_emails_in_queue)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_period_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_emails_in_queue,
         first_value(bead.accumulated_emails_in_queue)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_qtr_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_emails_in_queue,
         first_value(bead.accumulated_emails_in_queue)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_year_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_emails_in_queue,
         first_value(bead.accumulated_emails_one_day)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.week_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_emails_one_day,
         first_value(bead.accumulated_emails_one_day)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_period_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_emails_one_day,
         first_value(bead.accumulated_emails_one_day)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_qtr_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_emails_one_day,
         first_value(bead.accumulated_emails_one_day)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_year_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_emails_one_day,
         first_value(bead.accumulated_emails_three_days)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.week_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_emails_three_days,
         first_value(bead.accumulated_emails_three_days)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_period_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                       lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_emails_three_days,
         first_value(bead.accumulated_emails_three_days)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_qtr_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_emails_three_days,
         first_value(bead.accumulated_emails_three_days)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_year_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_emails_three_days,
         first_value(bead.accumulated_emails_week)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.week_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_emails_week,
         first_value(bead.accumulated_emails_week)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_period_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_emails_week,
         first_value(bead.accumulated_emails_week)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_qtr_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_emails_week,
         first_value(bead.accumulated_emails_week)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_year_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_emails_week,
         first_value(bead.accumulated_emails_week_plus)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.week_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_emails_week_plus,
         first_value(bead.accumulated_emails_week_plus)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_period_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_emails_week_plus,
         first_value(bead.accumulated_emails_week_plus)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_qtr_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_emails_week_plus,
         first_value(bead.accumulated_emails_week_plus)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
		       bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_year_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_emails_week_plus
       FROM bix_email_details_f bead,
            fii_time_day ftd
       WHERE bead.time_id = ftd.report_date_julian
       AND   bead.period_type_id = 1
       --AND   bead.period_start_date >= p_min_date     --DOES NOT PERFORM INDEX SCAN IF USING PERIOD_START_DATE
	  AND bead.time_id >= to_number( to_char(p_min_date,'J'))
	  ) inv2
    GROUP BY
         inv2.agent_id,
         inv2.email_account_id,
         inv2.email_classification_id,
         inv2.party_id,
         inv2.outcome_id,
    inv2.result_id,
    inv2.reason_id,
    ROLLUP(
         inv2.ent_year_id,
         inv2.ent_qtr_id,
         inv2.ent_period_id,
         inv2.week_id)
    HAVING
         decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
                  decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null),
                         128), 64), 32), 16) IS NOT NULL) rlp
  GROUP BY
    rlp.agent_id,
    rlp.email_account_id,
    rlp.email_classification_id,
    rlp.party_id,
    rlp.time_id,
    rlp.period_type_id,
    rlp.period_start_date,
    rlp.period_start_time,
    rlp.outcome_id,
    rlp.result_id,
    rlp.reason_id) change
  ON (  bead.agent_id = change.agent_id
    AND bead.email_account_id = change.email_account_id
    AND bead.email_classification_id = change.email_classification_id
    AND bead.party_id = change.party_id
    AND bead.time_id  = change.time_id
    AND bead.period_type_id = change.period_type_id
    AND bead.period_start_date = change.period_start_date
    AND bead.period_start_time = change.period_start_time
    AND bead.outcome_id        = change.outcome_id
    AND bead.result_id         = change.result_id
    AND bead.reason_id         = change.reason_id )
  WHEN MATCHED THEN
  UPDATE SET
    bead.emails_offered_in_period =
        decode(change.emails_offered_in_period, to_number(null), bead.emails_offered_in_period,
           nvl(bead.emails_offered_in_period,0) + change.emails_offered_in_period),
    bead.emails_fetched_in_period =
        decode(change.emails_fetched_in_period, to_number(null), bead.emails_fetched_in_period,
           nvl(bead.emails_fetched_in_period,0) + change.emails_fetched_in_period),
    bead.emails_replied_in_period =
        decode(change.emails_replied_in_period, to_number(null), bead.emails_replied_in_period,
           nvl(bead.emails_replied_in_period,0) + change.emails_replied_in_period),
    bead.emails_rpld_by_goal_in_period =
        decode(change.emails_rpld_by_goal_in_period, to_number(null), bead.emails_rpld_by_goal_in_period,
             nvl(bead.emails_rpld_by_goal_in_period,0) + change.emails_rpld_by_goal_in_period),
    bead.AGENT_EMAILS_RPLD_BY_GOAL =
            decode(change.AGENT_EMAILS_RPLD_BY_GOAL, to_number(null), bead.AGENT_EMAILS_RPLD_BY_GOAL,
                 nvl(bead.AGENT_EMAILS_RPLD_BY_GOAL,0) + change.AGENT_EMAILS_RPLD_BY_GOAL),
    bead.emails_deleted_in_period =
        decode(change.emails_deleted_in_period, to_number(null), bead.emails_deleted_in_period,
           nvl(bead.emails_deleted_in_period,0) + change.emails_deleted_in_period),
    bead.emails_trnsfrd_out_in_period =
        decode(change.emails_trnsfrd_out_in_period, to_number(null), bead.emails_trnsfrd_out_in_period,
           nvl(bead.emails_trnsfrd_out_in_period,0) + change.emails_trnsfrd_out_in_period),
    bead.emails_trnsfrd_in_in_period =
        decode(change.emails_trnsfrd_in_in_period, to_number(null), bead.emails_trnsfrd_in_in_period,
           nvl(bead.emails_trnsfrd_in_in_period,0) + change.emails_trnsfrd_in_in_period),
    bead.emails_rsl_and_trfd_in_period =
        decode(change.emails_rsl_and_trfd_in_period,to_number(null),bead.emails_rsl_and_trfd_in_period,
           nvl(bead.emails_rsl_and_trfd_in_period,0) + change.emails_rsl_and_trfd_in_period),
    bead.emails_assigned_in_period =
        decode(change.emails_assigned_in_period, to_number(null), bead.emails_assigned_in_period,
           nvl(bead.emails_assigned_in_period,0) + change.emails_assigned_in_period),
    bead.emails_auto_routed_in_period =
        decode(change.emails_auto_routed_in_period, to_number(null), bead.emails_auto_routed_in_period,
           nvl(bead.emails_auto_routed_in_period,0) + change.emails_auto_routed_in_period),
    bead.emails_auto_uptd_sr_in_period =
        decode(change.emails_auto_uptd_sr_in_period, to_number(null), bead.emails_auto_uptd_sr_in_period,
           nvl(bead.emails_auto_uptd_sr_in_period,0) + change.emails_auto_uptd_sr_in_period),
    bead.sr_created_in_period = decode(change.sr_created_in_period, to_number(null), bead.sr_created_in_period,
           nvl(bead.sr_created_in_period,0) + change.sr_created_in_period),
    bead.oldest_email_open_date =
           decode(change.oldest_email_open_date,NULL,bead.oldest_email_open_date,
               decode(bead.oldest_email_open_date,NULL,change.oldest_email_open_date,
                 decode(sign(bead.oldest_email_open_date - change.oldest_email_open_date),
                    -1,bead.oldest_email_open_date, change.oldest_email_open_date))),
    bead.oldest_email_queue_date =
           decode(change.oldest_email_queue_date,NULL,bead.oldest_email_queue_date,
               decode(bead.oldest_email_queue_date,NULL,change.oldest_email_queue_date,
                 decode(sign(bead.oldest_email_queue_date - change.oldest_email_queue_date),
                    -1,bead.oldest_email_queue_date, change.oldest_email_queue_date))),
    bead.email_resp_time_in_period =
        decode(change.email_resp_time_in_period, to_number(null), bead.email_resp_time_in_period,
           nvl(bead.email_resp_time_in_period,0) + change.email_resp_time_in_period),
    bead.agent_resp_time_in_period =
        decode(change.agent_resp_time_in_period, to_number(null), bead.agent_resp_time_in_period,
           nvl(bead.agent_resp_time_in_period,0) + change.agent_resp_time_in_period),
   bead.accumulated_open_emails =  decode(
                                      nvl(bead.accumulated_open_emails,0)+nvl(change.acc_open_emails,0),
                                      0,to_number(NULL),
                                      nvl(bead.accumulated_open_emails,0)+nvl(change.acc_open_emails,0)
                                       ),
    bead.accumulated_open_age =  decode(
                                      nvl(bead.accumulated_open_age,0)+nvl(change.acc_open_age,0),
                                      0,to_number(NULL),
                                      nvl(bead.accumulated_open_age,0)+nvl(change.acc_open_age,0)
                                      ),
    bead.accumulated_emails_in_queue = decode(
                                      nvl(bead.accumulated_emails_in_queue,0)+nvl(change.acc_emails_in_queue,0),
                                      0,to_number(null),
                                      nvl(bead.accumulated_emails_in_queue,0)+nvl(change.acc_emails_in_queue,0)
                                      ),
    bead.accumulated_queue_time = decode(
                                      nvl(bead.accumulated_queue_time,0)+nvl(change.acc_queue_time,0),
                                      0,to_number(null),
                                      nvl(bead.accumulated_queue_time,0)+nvl(change.acc_queue_time,0)
                                      ),
    bead.accumulated_emails_one_day = decode(
                                      nvl(bead.accumulated_emails_one_day,0)+nvl(change.acc_emails_one_day,0),
                                      0,to_number(null),
                                      nvl(bead.accumulated_emails_one_day,0)+nvl(change.acc_emails_one_day,0)
                                      ),
    bead.accumulated_emails_three_days = decode(
                                   nvl(bead.accumulated_emails_three_days,0)+nvl(change.acc_emails_three_days,0),
                                   0,to_number(null),
                                   nvl(bead.accumulated_emails_three_days,0)+nvl(change.acc_emails_three_days,0)
                                   ),
    bead.accumulated_emails_week =  decode(
                                      nvl(bead.accumulated_emails_week,0)+nvl(change.acc_emails_week,0),
                                      0,to_number(null),
                                      nvl(bead.accumulated_emails_week,0)+nvl(change.acc_emails_week,0)
                                      ),
    bead.accumulated_emails_week_plus = decode(
                                   nvl(bead.accumulated_emails_week_plus,0)+nvl(change.acc_emails_week_plus,0),
                                   0,to_number(null),
                                   nvl(bead.accumulated_emails_week_plus,0)+nvl(change.acc_emails_week_plus,0)
                                      ),
    bead.emails_orr_count_in_period  = decode(change.emails_orr_count_in_period,to_number(null), bead.emails_orr_count_in_period ,
      nvl(bead.emails_orr_count_in_period,0) + change.emails_orr_count_in_period),
    bead.EMAILS_AUTO_REPLIED_IN_PERIOD = decode(change.EMAILS_AUTO_REPLIED_IN_PERIOD,to_number(null),bead.EMAILS_AUTO_REPLIED_IN_PERIOD,
       nvl(bead.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + change.EMAILS_AUTO_REPLIED_IN_PERIOD),
    bead.EMAILS_AUTO_DELETED_IN_PERIOD = decode(change.EMAILS_AUTO_DELETED_IN_PERIOD,to_number(null),bead.EMAILS_AUTO_DELETED_IN_PERIOD,
      nvl(bead.EMAILS_AUTO_DELETED_IN_PERIOD,0) + change.EMAILS_AUTO_DELETED_IN_PERIOD),
    bead.EMAILS_AUTO_RESOLVED_IN_PERIOD = decode(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,to_number(null),bead.EMAILS_AUTO_RESOLVED_IN_PERIOD,
      nvl(bead.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + change.EMAILS_AUTO_RESOLVED_IN_PERIOD),
    bead.emails_composed_in_period = decode(change.emails_composed_in_period,to_number(null),bead.emails_composed_in_period,
                                            nvl(bead.emails_composed_in_period,0) + change.emails_composed_in_period),
    bead.emails_rerouted_in_period = decode(change.emails_rerouted_in_period,to_number(null),bead.emails_rerouted_in_period,
                                            nvl(bead.emails_rerouted_in_period,0) + change.emails_rerouted_in_period ),
    bead.leads_created_in_period = decode(change.leads_created_in_period,to_number(null),bead.leads_created_in_period,
                                          nvl(bead.leads_created_in_period,0) + change.leads_created_in_period ),
    bead.ONE_RSLN_IN_PERIOD =  decode(
    							nvl(bead.ONE_RSLN_IN_PERIOD ,0)+nvl(change.ONE_RSLN_IN_PERIOD ,0),
    							0,to_number(null),
   							 nvl(bead.ONE_RSLN_IN_PERIOD ,0)+nvl(change.ONE_RSLN_IN_PERIOD ,0)
   						 ),
    bead.TWO_RSLN_IN_PERIOD =  decode(
 							 nvl(bead.TWO_RSLN_IN_PERIOD ,0)+nvl(change.TWO_RSLN_IN_PERIOD ,0),
   							 0,to_number(null),
 							   nvl(bead.TWO_RSLN_IN_PERIOD ,0)+nvl(change.TWO_RSLN_IN_PERIOD ,0)
  						  ),
    bead.THREE_RSLN_IN_PERIOD =  decode(
						    nvl(bead.THREE_RSLN_IN_PERIOD ,0)+nvl(change.THREE_RSLN_IN_PERIOD ,0),
						    0,to_number(null),
						    nvl(bead.THREE_RSLN_IN_PERIOD ,0)+nvl(change.THREE_RSLN_IN_PERIOD ,0)
   						 ),
    bead.FOUR_RSLN_IN_PERIOD =  decode(
 						   nvl(bead.FOUR_RSLN_IN_PERIOD ,0)+nvl(change.FOUR_RSLN_IN_PERIOD ,0),
						    0,to_number(null),
  						  nvl(bead.FOUR_RSLN_IN_PERIOD ,0)+nvl(change.FOUR_RSLN_IN_PERIOD ,0)
   						 ),
    bead.INTERACTION_THREADS_IN_PERIOD =  decode(
    								nvl(bead.INTERACTION_THREADS_IN_PERIOD,0)+nvl(change.INTERACTION_THREADS_IN_PERIOD,0),
 								   0,to_number(null),
  								  nvl(bead.INTERACTION_THREADS_IN_PERIOD,0)+nvl(change.INTERACTION_THREADS_IN_PERIOD,0)
   						 ),
    bead.last_update_date = g_sysdate,
    bead.last_updated_by  = g_user_id,
    bead.program_update_date = g_sysdate
  WHEN NOT MATCHED THEN INSERT
     (agent_id,
      email_account_id,
      email_classification_id,
      party_id,
      outcome_id,
      result_id,
      reason_id,
      time_id,
      period_type_id,
      period_start_date,
      period_start_time,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      emails_offered_in_period,
      emails_fetched_in_period,
      emails_replied_in_period,
      emails_rpld_by_goal_in_period,
      AGENT_EMAILS_RPLD_BY_GOAL,
      emails_deleted_in_period,
      emails_trnsfrd_out_in_period,
      emails_trnsfrd_in_in_period,
      emails_rsl_and_trfd_in_period,
      emails_assigned_in_period,
      emails_auto_routed_in_period,
      emails_auto_uptd_sr_in_period,
      sr_created_in_period,
      oldest_email_open_date,
      oldest_email_queue_date,
      email_resp_time_in_period,
      agent_resp_time_in_period,
      accumulated_open_emails,
      accumulated_open_age,
      accumulated_emails_in_queue,
      accumulated_queue_time,
      accumulated_emails_one_day,
      accumulated_emails_three_days,
      accumulated_emails_week,
      accumulated_emails_week_plus,
      emails_orr_count_in_period,
      EMAILS_AUTO_REPLIED_IN_PERIOD,
      EMAILS_AUTO_DELETED_IN_PERIOD,
      EMAILS_AUTO_RESOLVED_IN_PERIOD,
      emails_composed_in_period,
	 emails_rerouted_in_period,
	 leads_created_in_period,
      ONE_RSLN_IN_PERIOD,
      TWO_RSLN_IN_PERIOD,
      THREE_RSLN_IN_PERIOD,
      FOUR_RSLN_IN_PERIOD,
	 INTERACTION_THREADS_IN_PERIOD,
      request_id,
      program_application_id,
      program_id,
      program_update_date )
    VALUES (
      change.agent_id,
      change.email_account_id,
      change.email_classification_id,
      change.party_id,
      change.outcome_id,
      change.result_id,
      change.reason_id,
      change.time_id,
      change.period_type_id,
      change.period_start_date,
      change.period_start_time,
      g_user_id,
      g_sysdate,
      g_user_id,
      g_sysdate,
      decode(change.emails_offered_in_period, 0, to_number(null), change.emails_offered_in_period),
      decode(change.emails_fetched_in_period, 0, to_number(null), change.emails_fetched_in_period),
      decode(change.emails_replied_in_period, 0, to_number(null), change.emails_replied_in_period),
      decode(change.emails_rpld_by_goal_in_period, 0, to_number(null), change.emails_rpld_by_goal_in_period),
      decode(change.AGENT_EMAILS_RPLD_BY_GOAL, 0, to_number(null), change.AGENT_EMAILS_RPLD_BY_GOAL),
      decode(change.emails_deleted_in_period, 0, to_number(null), change.emails_deleted_in_period),
      decode(change.emails_trnsfrd_out_in_period, 0, to_number(null), change.emails_trnsfrd_out_in_period),
      decode(change.emails_trnsfrd_in_in_period, 0, to_number(null), change.emails_trnsfrd_in_in_period),
      decode(change.emails_rsl_and_trfd_in_period, 0, to_number(null), change.emails_rsl_and_trfd_in_period),
      decode(change.emails_assigned_in_period, 0, to_number(null), change.emails_assigned_in_period),
      decode(change.emails_auto_routed_in_period, 0, to_number(null), change.emails_auto_routed_in_period),
      decode(change.emails_auto_uptd_sr_in_period, 0, to_number(null), change.emails_auto_uptd_sr_in_period),
      decode(change.sr_created_in_period, 0, to_number(null), change.sr_created_in_period),
      change.oldest_email_open_date,
      change.oldest_email_queue_date,
      decode(change.email_resp_time_in_period, 0, to_number(null), change.email_resp_time_in_period),
      decode(change.agent_resp_time_in_period, 0, to_number(null), change.agent_resp_time_in_period),
      decode(change.acc_open_emails, 0, to_number(null), change.acc_open_emails),
      decode(change.acc_open_age, 0, to_number(null), change.acc_open_age),
      decode(change.acc_emails_in_queue, 0, to_number(null), change.acc_emails_in_queue),
      decode(change.acc_queue_time, 0, to_number(null), change.acc_queue_time),
      decode(change.acc_emails_one_day, 0, to_number(null), change.acc_emails_one_day),
      decode(change.acc_emails_three_days, 0, to_number(null), change.acc_emails_three_days),
      decode(change.acc_emails_week, 0, to_number(null), change.acc_emails_week),
      decode(change.acc_emails_week_plus, 0, to_number(null), change.acc_emails_week_plus),
      decode(change.emails_orr_count_in_period,0,to_number(null),change.emails_orr_count_in_period),
      decode(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0,to_number(null),change.EMAILS_AUTO_REPLIED_IN_PERIOD),
      decode(change.EMAILS_AUTO_DELETED_IN_PERIOD,0,to_number(null),change.EMAILS_AUTO_DELETED_IN_PERIOD),
      decode(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,0,to_number(null),change.EMAILS_AUTO_RESOLVED_IN_PERIOD),
      decode(change.emails_composed_in_period,0,to_number(null),change.emails_composed_in_period),
	 decode(change.emails_rerouted_in_period,0,to_number(null),change.emails_rerouted_in_period),
	 decode(change.leads_created_in_period,0,to_number(null),change.leads_created_in_period),
      decode(change.ONE_RSLN_IN_PERIOD,0,to_number(null),change.ONE_RSLN_IN_PERIOD),
	 decode(change.TWO_RSLN_IN_PERIOD,0,to_number(null),change.TWO_RSLN_IN_PERIOD),
	 decode(change.THREE_RSLN_IN_PERIOD,0,to_number(null),change.THREE_RSLN_IN_PERIOD),
	 decode(change.FOUR_RSLN_IN_PERIOD,0,to_number(null),change.FOUR_RSLN_IN_PERIOD),
	 decode(change.INTERACTION_THREADS_IN_PERIOD,0,to_number(null),change.INTERACTION_THREADS_IN_PERIOD),
	 g_request_id,
	 g_program_appl_id,
	 g_program_id,
      g_sysdate);

  g_rows_ins_upd := g_rows_ins_upd + SQL%ROWCOUNT;

  COMMIT;

  write_log('Finished procedure rollup_negatives at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure rollup_negatives : Error : ' || sqlerrm);
    RAISE;
END rollup_negatives;


/*====================================================================

This procedure summarizes  day level rows to week, period, Quarter and Year.

=======================================================================*/

PROCEDURE summarize_data IS

BEGIN

  write_log('Start of the procedure summarize_data at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  write_log('Merging day rows to week, month, quarter, year bucket in table bix_email_details_f');

  /* Rollup half hour informations to day, week, month, quarter, year time bucket for table bix_email_details_f */
  MERGE INTO bix_email_details_stg bead
  USING (
  SELECT
    rlp.agent_id                                     agent_id,
    rlp.email_account_id                             email_account_id,
    rlp.email_classification_id                      email_classification_id,
    rlp.party_id                                     party_id,
    rlp.time_id                                      time_id,
    rlp.period_type_id                               period_type_id,
    rlp.period_start_date                            period_start_date,
    rlp.period_start_time                            period_start_time,
    rlp.outcome_id                                   outcome_id,
    rlp.result_id                                    result_id,
    rlp.reason_id                                    reason_id,
    decode(sum(rlp.emails_offered_in_period), 0, to_number(null), sum(rlp.emails_offered_in_period))
                                                     emails_offered_in_period,
    decode(sum(rlp.emails_fetched_in_period), 0, to_number(null), sum(rlp.emails_fetched_in_period))
                                                     emails_fetched_in_period,
    decode(sum(rlp.emails_replied_in_period), 0, to_number(null), sum(rlp.emails_replied_in_period))
                                                     emails_replied_in_period,
    decode(sum(rlp.emails_rpld_by_goal_in_period), 0, to_number(null), sum(rlp.emails_rpld_by_goal_in_period))
                                                     emails_rpld_by_goal_in_period,
    decode(sum(rlp.AGENT_EMAILS_RPLD_BY_GOAL), 0, to_number(null), sum(rlp.AGENT_EMAILS_RPLD_BY_GOAL))
                                                         AGENT_EMAILS_RPLD_BY_GOAL,
    decode(sum(rlp.emails_deleted_in_period), 0, to_number(null), sum(rlp.emails_deleted_in_period))
                                                     emails_deleted_in_period,
    decode(sum(rlp.emails_trnsfrd_out_in_period), 0, to_number(null), sum(rlp.emails_trnsfrd_out_in_period))
                                                     emails_trnsfrd_out_in_period,
    decode(sum(rlp.emails_trnsfrd_in_in_period), 0, to_number(null), sum(rlp.emails_trnsfrd_in_in_period))
                                                     emails_trnsfrd_in_in_period,
    decode(sum(rlp.emails_rsl_and_trfd_in_period), 0, to_number(null), sum(rlp.emails_rsl_and_trfd_in_period))
                                                     emails_rsl_and_trfd_in_period,
    decode(sum(rlp.emails_assigned_in_period), 0, to_number(null), sum(rlp.emails_assigned_in_period))
                                                     emails_assigned_in_period,
    decode(sum(rlp.emails_auto_routed_in_period), 0, to_number(null), sum(rlp.emails_auto_routed_in_period))
                                                     emails_auto_routed_in_period,
    decode(sum(rlp.emails_auto_uptd_sr_in_period), 0, to_number(null), sum(rlp.emails_auto_uptd_sr_in_period))
                                                     emails_auto_uptd_sr_in_period,
    decode(sum(rlp.sr_created_in_period), 0, to_number(null), sum(rlp.sr_created_in_period))
                                                     sr_created_in_period,
    to_date(null)                                    oldest_email_open_date,
    to_date(null)                                    oldest_email_queue_date,
    decode(sum(rlp.email_resp_time_in_period), 0, to_number(null), sum(rlp.email_resp_time_in_period))
                                                     email_resp_time_in_period,
    decode(sum(rlp.agent_resp_time_in_period), 0, to_number(null), sum(rlp.agent_resp_time_in_period))
                                                     agent_resp_time_in_period,
    min(rlp.acc_open_emails)                         acc_open_emails,
    to_number(null)                                  acc_open_age,
    min(rlp.acc_emails_in_queue)                     acc_emails_in_queue,
    to_number(null)                                  acc_queue_time,
    min(rlp.acc_emails_one_day)                      acc_emails_one_day,
    min(rlp.acc_emails_three_days)                   acc_emails_three_days,
    min(rlp.acc_emails_week)                         acc_emails_week,
    min(rlp.acc_emails_week_plus)                    acc_emails_week_plus,
    decode(sum(rlp.emails_orr_count_in_period),0,to_number(null),sum(emails_orr_count_in_period)) emails_orr_count_in_period,
    decode(sum(rlp.EMAILS_AUTO_REPLIED_IN_PERIOD),0,to_number(null),sum(EMAILS_AUTO_REPLIED_IN_PERIOD)) EMAILS_AUTO_REPLIED_IN_PERIOD,
    decode(sum(rlp.EMAILS_AUTO_DELETED_IN_PERIOD),0,to_number(null),sum(EMAILS_AUTO_DELETED_IN_PERIOD)) EMAILS_AUTO_DELETED_IN_PERIOD,
    decode(sum(rlp.EMAILS_AUTO_RESOLVED_IN_PERIOD),0,to_number(null),sum(EMAILS_AUTO_RESOLVED_IN_PERIOD)) EMAILS_AUTO_RESOLVED_IN_PERIOD,
    decode(sum(rlp.emails_composed_in_period),0,to_number(null),sum(emails_composed_in_period)) emails_composed_in_period,
    decode(sum(rlp.emails_rerouted_in_period),0,to_number(null),sum(emails_rerouted_in_period)) emails_rerouted_in_period,
    decode(sum(rlp.leads_created_in_period),0,to_number(null),sum(leads_created_in_period)) leads_created_in_period
  FROM (
    SELECT
      inv2.agent_id agent_id,
      inv2.email_account_id email_account_id,
      inv2.email_classification_id email_classification_id,
      inv2.party_id party_id,
      inv2.outcome_id outcome_id,
      inv2.result_id result_id,
      inv2.reason_id reason_id,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), inv2.ent_year_id),
              inv2.ent_qtr_id), inv2.ent_period_id), inv2.week_id) time_id,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null),
              128), 64), 32), 16) period_type_id,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_date(null), min(inv2.ent_year_start_date)),
              min(inv2.ent_qtr_start_date)), min(inv2.ent_period_start_date)), min(inv2.week_start_date)) period_start_date,
      '00:00' period_start_time,
      sum(inv2.emails_offered_in_period) emails_offered_in_period,
      sum(inv2.emails_fetched_in_period) emails_fetched_in_period,
      sum(inv2.emails_replied_in_period) emails_replied_in_period,
      sum(inv2.emails_rpld_by_goal_in_period) emails_rpld_by_goal_in_period,
      sum(inv2.AGENT_EMAILS_RPLD_BY_GOAL) AGENT_EMAILS_RPLD_BY_GOAL,
      sum(inv2.emails_deleted_in_period) emails_deleted_in_period,
      sum(inv2.emails_trnsfrd_out_in_period) emails_trnsfrd_out_in_period,
      sum(inv2.emails_trnsfrd_in_in_period) emails_trnsfrd_in_in_period,
      sum(inv2.emails_rsl_and_trfd_in_period) emails_rsl_and_trfd_in_period,
      sum(inv2.emails_assigned_in_period) emails_assigned_in_period,
      sum(inv2.emails_auto_routed_in_period) emails_auto_routed_in_period,
      sum(inv2.emails_auto_uptd_sr_in_period) emails_auto_uptd_sr_in_period,
      sum(inv2.sr_created_in_period) sr_created_in_period,
      sum(inv2.email_resp_time_in_period) email_resp_time_in_period,
      sum(inv2.agent_resp_time_in_period) agent_resp_time_in_period,
      sum(inv2.emails_orr_count_in_period) emails_orr_count_in_period,
      sum(inv2.EMAILS_AUTO_REPLIED_IN_PERIOD) EMAILS_AUTO_REPLIED_IN_PERIOD,
      sum(inv2.EMAILS_AUTO_DELETED_IN_PERIOD) EMAILS_AUTO_DELETED_IN_PERIOD,
      sum(inv2.EMAILS_AUTO_RESOLVED_IN_PERIOD) EMAILS_AUTO_RESOLVED_IN_PERIOD,
      sum(inv2.emails_composed_in_period) emails_composed_in_period,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_open_emails)),
              min(inv2.qtr_acc_open_emails)), min(inv2.period_acc_open_emails)), min(inv2.week_acc_open_emails)) acc_open_emails,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_emails_in_queue)),
              min(inv2.qtr_acc_emails_in_queue)), min(inv2.period_acc_emails_in_queue)), min(inv2.week_acc_emails_in_queue))
         acc_emails_in_queue,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_emails_one_day)),
              min(inv2.qtr_acc_emails_one_day)), min(inv2.period_acc_emails_one_day)), min(inv2.week_acc_emails_one_day)) acc_emails_one_day,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_emails_three_days)),
              min(inv2.qtr_acc_emails_three_days)), min(inv2.period_acc_emails_three_days)),
                min(inv2.week_acc_emails_three_days))            acc_emails_three_days,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_emails_week)),
              min(inv2.qtr_acc_emails_week)), min(inv2.period_acc_emails_week)), min(inv2.week_acc_emails_week)) acc_emails_week,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_emails_week_plus)),
              min(inv2.qtr_acc_emails_week_plus)), min(inv2.period_acc_emails_week_plus)),
                min(inv2.week_acc_emails_week_plus))  acc_emails_week_plus,
      sum(inv2.EMAILS_REROUTED_IN_PERIOD) EMAILS_REROUTED_IN_PERIOD,
      sum(inv2.LEADS_CREATED_IN_PERIOD) LEADS_CREATED_IN_PERIOD
    FROM
      (SELECT /*+ index(bead BIX_EMAIL_DETAILS_F_N1) */
         bead.agent_id agent_id,
         bead.email_account_id email_account_id,
         bead.email_classification_id email_classification_id,
         bead.party_id party_id,
         bead.outcome_id,
         bead.result_id,
         bead.reason_id,
         ftd.ent_year_id ent_year_id,
         ftd.ent_year_start_date ent_year_start_date,
         ftd.ent_qtr_id ent_qtr_id,
         ftd.ent_qtr_start_date ent_qtr_start_date,
         ftd.ent_period_id ent_period_id,
         ftd.ent_period_start_date ent_period_start_date,
         ftd.week_id  week_id,
         ftd.week_start_date week_start_date,
         bead.period_start_date period_start_date,
         bead.emails_offered_in_period emails_offered_in_period,
         bead.emails_fetched_in_period emails_fetched_in_period,
         bead.emails_replied_in_period emails_replied_in_period,
         bead.emails_rpld_by_goal_in_period emails_rpld_by_goal_in_period,
         bead.AGENT_EMAILS_RPLD_BY_GOAL AGENT_EMAILS_RPLD_BY_GOAL,
         bead.emails_deleted_in_period emails_deleted_in_period,
         bead.emails_trnsfrd_out_in_period emails_trnsfrd_out_in_period,
         bead.emails_trnsfrd_in_in_period emails_trnsfrd_in_in_period,
         bead.emails_rsl_and_trfd_in_period emails_rsl_and_trfd_in_period,
         bead.emails_assigned_in_period emails_assigned_in_period,
         bead.emails_auto_routed_in_period emails_auto_routed_in_period,
         bead.emails_auto_uptd_sr_in_period emails_auto_uptd_sr_in_period,
         bead.sr_created_in_period sr_created_in_period,
         bead.email_resp_time_in_period email_resp_time_in_period,
         bead.agent_resp_time_in_period agent_resp_time_in_period,
         bead.emails_orr_count_in_period emails_orr_count_in_period,
         bead.EMAILS_AUTO_REPLIED_IN_PERIOD EMAILS_AUTO_REPLIED_IN_PERIOD,
         bead.EMAILS_AUTO_DELETED_IN_PERIOD EMAILS_AUTO_DELETED_IN_PERIOD,
         bead.EMAILS_AUTO_RESOLVED_IN_PERIOD EMAILS_AUTO_RESOLVED_IN_PERIOD,
         bead.emails_composed_in_period emails_composed_in_period,
	    bead.emails_rerouted_in_period emails_rerouted_in_period,
	    bead.leads_created_in_period leads_created_in_period,
         first_value(bead.accumulated_open_emails)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.week_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_open_emails,
         first_value(bead.accumulated_open_emails)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_period_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_open_emails,
         first_value(bead.accumulated_open_emails)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_qtr_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_open_emails,
         first_value(bead.accumulated_open_emails)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_year_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_open_emails,
         first_value(bead.accumulated_emails_in_queue)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.week_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_emails_in_queue,
         first_value(bead.accumulated_emails_in_queue)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_period_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_emails_in_queue,
         first_value(bead.accumulated_emails_in_queue)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_qtr_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_emails_in_queue,
         first_value(bead.accumulated_emails_in_queue)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_year_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_emails_in_queue,
         first_value(bead.accumulated_emails_one_day)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.week_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_emails_one_day,
         first_value(bead.accumulated_emails_one_day)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_period_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_emails_one_day,
         first_value(bead.accumulated_emails_one_day)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_qtr_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_emails_one_day,
         first_value(bead.accumulated_emails_one_day)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_year_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_emails_one_day,
         first_value(bead.accumulated_emails_three_days)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.week_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_emails_three_days,
         first_value(bead.accumulated_emails_three_days)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_period_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                       lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_emails_three_days,
         first_value(bead.accumulated_emails_three_days)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_qtr_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_emails_three_days,
         first_value(bead.accumulated_emails_three_days)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_year_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_emails_three_days,
         first_value(bead.accumulated_emails_week)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.week_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_emails_week,
         first_value(bead.accumulated_emails_week)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_period_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_emails_week,
         first_value(bead.accumulated_emails_week)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_qtr_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_emails_week,
         first_value(bead.accumulated_emails_week)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_year_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_emails_week,
         first_value(bead.accumulated_emails_week_plus)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.week_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_emails_week_plus,
         first_value(bead.accumulated_emails_week_plus)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_period_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_emails_week_plus,
         first_value(bead.accumulated_emails_week_plus)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_qtr_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                        lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_emails_week_plus,
         first_value(bead.accumulated_emails_week_plus)
           over (partition by bead.agent_id, bead.email_account_id, bead.email_classification_id, bead.party_id,
                 bead.outcome_id, bead.result_id, bead.reason_id,
                 ftd.ent_year_id
                    order by to_date(to_char(bead.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bead.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_emails_week_plus
       FROM bix_email_details_stg bead,
            fii_time_day ftd
       WHERE bead.time_id = ftd.report_date_julian
       AND   bead.period_type_id = 1
       --AND   bead.request_id = g_request_id
       ) inv2
    GROUP BY
         inv2.agent_id,
         inv2.email_account_id,
         inv2.email_classification_id,
         inv2.party_id,
         inv2.outcome_id,
    inv2.result_id,
    inv2.reason_id,
    ROLLUP(
         inv2.ent_year_id,
         inv2.ent_qtr_id,
         inv2.ent_period_id,
         inv2.week_id)
    HAVING
         decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
                  decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null),
                         128), 64), 32), 16) IS NOT NULL) rlp
  GROUP BY
    rlp.agent_id,
    rlp.email_account_id,
    rlp.email_classification_id,
    rlp.party_id,
    rlp.time_id,
    rlp.period_type_id,
    rlp.period_start_date,
    rlp.period_start_time,
    rlp.outcome_id,
    rlp.result_id,
    rlp.reason_id) change
  ON (  bead.agent_id = change.agent_id
    AND bead.email_account_id = change.email_account_id
    AND bead.email_classification_id = change.email_classification_id
    AND bead.party_id = change.party_id
    AND bead.time_id  = change.time_id
    AND bead.period_type_id = change.period_type_id
    AND bead.period_start_date = change.period_start_date
    AND bead.period_start_time = change.period_start_time
    AND bead.outcome_id        = change.outcome_id
    AND bead.result_id         = change.result_id
    AND bead.reason_id         = change.reason_id )
  WHEN MATCHED THEN
  UPDATE SET
    bead.emails_offered_in_period =
        decode(change.emails_offered_in_period, to_number(null), bead.emails_offered_in_period,
           nvl(bead.emails_offered_in_period,0) + change.emails_offered_in_period),
    bead.emails_fetched_in_period =
        decode(change.emails_fetched_in_period, to_number(null), bead.emails_fetched_in_period,
           nvl(bead.emails_fetched_in_period,0) + change.emails_fetched_in_period),
    bead.emails_replied_in_period =
        decode(change.emails_replied_in_period, to_number(null), bead.emails_replied_in_period,
           nvl(bead.emails_replied_in_period,0) + change.emails_replied_in_period),
    bead.emails_rpld_by_goal_in_period =
        decode(change.emails_rpld_by_goal_in_period, to_number(null), bead.emails_rpld_by_goal_in_period,
             nvl(bead.emails_rpld_by_goal_in_period,0) + change.emails_rpld_by_goal_in_period),
    bead.AGENT_EMAILS_RPLD_BY_GOAL =
            decode(change.AGENT_EMAILS_RPLD_BY_GOAL, to_number(null), bead.AGENT_EMAILS_RPLD_BY_GOAL,
                 nvl(bead.AGENT_EMAILS_RPLD_BY_GOAL,0) + change.AGENT_EMAILS_RPLD_BY_GOAL),
    bead.emails_deleted_in_period =
        decode(change.emails_deleted_in_period, to_number(null), bead.emails_deleted_in_period,
           nvl(bead.emails_deleted_in_period,0) + change.emails_deleted_in_period),
    bead.emails_trnsfrd_out_in_period =
        decode(change.emails_trnsfrd_out_in_period, to_number(null), bead.emails_trnsfrd_out_in_period,
           nvl(bead.emails_trnsfrd_out_in_period,0) + change.emails_trnsfrd_out_in_period),
    bead.emails_trnsfrd_in_in_period =
        decode(change.emails_trnsfrd_in_in_period, to_number(null), bead.emails_trnsfrd_in_in_period,
           nvl(bead.emails_trnsfrd_in_in_period,0) + change.emails_trnsfrd_in_in_period),
    bead.emails_rsl_and_trfd_in_period =
        decode(change.emails_rsl_and_trfd_in_period,to_number(null),bead.emails_rsl_and_trfd_in_period,
           nvl(bead.emails_rsl_and_trfd_in_period,0) + change.emails_rsl_and_trfd_in_period),
    bead.emails_assigned_in_period =
        decode(change.emails_assigned_in_period, to_number(null), bead.emails_assigned_in_period,
           nvl(bead.emails_assigned_in_period,0) + change.emails_assigned_in_period),
    bead.emails_auto_routed_in_period =
        decode(change.emails_auto_routed_in_period, to_number(null), bead.emails_auto_routed_in_period,
           nvl(bead.emails_auto_routed_in_period,0) + change.emails_auto_routed_in_period),
    bead.emails_auto_uptd_sr_in_period =
        decode(change.emails_auto_uptd_sr_in_period, to_number(null), bead.emails_auto_uptd_sr_in_period,
           nvl(bead.emails_auto_uptd_sr_in_period,0) + change.emails_auto_uptd_sr_in_period),
    bead.sr_created_in_period = decode(change.sr_created_in_period, to_number(null), bead.sr_created_in_period,
           nvl(bead.sr_created_in_period,0) + change.sr_created_in_period),
    bead.oldest_email_open_date =
           decode(change.oldest_email_open_date,NULL,bead.oldest_email_open_date,
               decode(bead.oldest_email_open_date,NULL,change.oldest_email_open_date,
                 decode(sign(bead.oldest_email_open_date - change.oldest_email_open_date),
                    -1,bead.oldest_email_open_date, change.oldest_email_open_date))),
    bead.oldest_email_queue_date =
           decode(change.oldest_email_queue_date,NULL,bead.oldest_email_queue_date,
               decode(bead.oldest_email_queue_date,NULL,change.oldest_email_queue_date,
                 decode(sign(bead.oldest_email_queue_date - change.oldest_email_queue_date),
                    -1,bead.oldest_email_queue_date, change.oldest_email_queue_date))),
    bead.email_resp_time_in_period =
        decode(change.email_resp_time_in_period, to_number(null), bead.email_resp_time_in_period,
           nvl(bead.email_resp_time_in_period,0) + change.email_resp_time_in_period),
    bead.agent_resp_time_in_period =
        decode(change.agent_resp_time_in_period, to_number(null), bead.agent_resp_time_in_period,
           nvl(bead.agent_resp_time_in_period,0) + change.agent_resp_time_in_period),
    bead.accumulated_open_emails = change.acc_open_emails,
    bead.accumulated_open_age = change.acc_open_age,
    bead.accumulated_emails_in_queue = change.acc_emails_in_queue,
    bead.accumulated_queue_time = change.acc_queue_time,
    bead.accumulated_emails_one_day = change.acc_emails_one_day,
    bead.accumulated_emails_three_days = change.acc_emails_three_days,
    bead.accumulated_emails_week = change.acc_emails_week,
    bead.accumulated_emails_week_plus = change.acc_emails_week_plus,
    bead.emails_orr_count_in_period  = decode(change.emails_orr_count_in_period,to_number(null), bead.emails_orr_count_in_period ,
      nvl(bead.emails_orr_count_in_period,0) + change.emails_orr_count_in_period),
    bead.EMAILS_AUTO_REPLIED_IN_PERIOD = decode(change.EMAILS_AUTO_REPLIED_IN_PERIOD,to_number(null),bead.EMAILS_AUTO_REPLIED_IN_PERIOD,
       nvl(bead.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + change.EMAILS_AUTO_REPLIED_IN_PERIOD),
    bead.EMAILS_AUTO_DELETED_IN_PERIOD = decode(change.EMAILS_AUTO_DELETED_IN_PERIOD,to_number(null),bead.EMAILS_AUTO_DELETED_IN_PERIOD,
      nvl(bead.EMAILS_AUTO_DELETED_IN_PERIOD,0) + change.EMAILS_AUTO_DELETED_IN_PERIOD),
    bead.EMAILS_AUTO_RESOLVED_IN_PERIOD = decode(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,to_number(null),bead.EMAILS_AUTO_RESOLVED_IN_PERIOD,
      nvl(bead.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + change.EMAILS_AUTO_RESOLVED_IN_PERIOD),
    bead.emails_composed_in_period = decode(change.emails_composed_in_period,to_number(null),bead.emails_composed_in_period,
                                            nvl(bead.emails_composed_in_period,0) + change.emails_composed_in_period),
    bead.emails_rerouted_in_period = decode(change.emails_rerouted_in_period,to_number(null),bead.emails_rerouted_in_period,
                                            nvl(bead.emails_rerouted_in_period,0) + change.emails_rerouted_in_period ),
    bead.leads_created_in_period = decode(change.leads_created_in_period,to_number(null),bead.leads_created_in_period,
                                          nvl(bead.leads_created_in_period,0) + change.leads_created_in_period ),
    bead.last_update_date = g_sysdate,
    bead.last_updated_by  = g_user_id,
    bead.program_update_date = g_sysdate
  WHEN NOT MATCHED THEN INSERT
     (agent_id,
      email_account_id,
      email_classification_id,
      party_id,
      outcome_id,
      result_id,
      reason_id,
      time_id,
      period_type_id,
      period_start_date,
      period_start_time,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      emails_offered_in_period,
      emails_fetched_in_period,
      emails_replied_in_period,
      emails_rpld_by_goal_in_period,
      AGENT_EMAILS_RPLD_BY_GOAL,
      emails_deleted_in_period,
      emails_trnsfrd_out_in_period,
      emails_trnsfrd_in_in_period,
      emails_rsl_and_trfd_in_period,
      emails_assigned_in_period,
      emails_auto_routed_in_period,
      emails_auto_uptd_sr_in_period,
      sr_created_in_period,
      oldest_email_open_date,
      oldest_email_queue_date,
      email_resp_time_in_period,
      agent_resp_time_in_period,
      accumulated_open_emails,
      accumulated_open_age,
      accumulated_emails_in_queue,
      accumulated_queue_time,
      accumulated_emails_one_day,
      accumulated_emails_three_days,
      accumulated_emails_week,
      accumulated_emails_week_plus,
      emails_orr_count_in_period,
      EMAILS_AUTO_REPLIED_IN_PERIOD,
      EMAILS_AUTO_DELETED_IN_PERIOD,
      EMAILS_AUTO_RESOLVED_IN_PERIOD,
      emails_composed_in_period,
	 emails_rerouted_in_period,
	 leads_created_in_period,
      request_id,
      program_application_id,
      program_id,
      program_update_date )
    VALUES (
      change.agent_id,
      change.email_account_id,
      change.email_classification_id,
      change.party_id,
      change.outcome_id,
      change.result_id,
      change.reason_id,
      change.time_id,
      change.period_type_id,
      change.period_start_date,
      change.period_start_time,
      g_user_id,
      g_sysdate,
      g_user_id,
      g_sysdate,
      decode(change.emails_offered_in_period, 0, to_number(null), change.emails_offered_in_period),
      decode(change.emails_fetched_in_period, 0, to_number(null), change.emails_fetched_in_period),
      decode(change.emails_replied_in_period, 0, to_number(null), change.emails_replied_in_period),
      decode(change.emails_rpld_by_goal_in_period, 0, to_number(null), change.emails_rpld_by_goal_in_period),
      decode(change.AGENT_EMAILS_RPLD_BY_GOAL, 0, to_number(null), change.AGENT_EMAILS_RPLD_BY_GOAL),
      decode(change.emails_deleted_in_period, 0, to_number(null), change.emails_deleted_in_period),
      decode(change.emails_trnsfrd_out_in_period, 0, to_number(null), change.emails_trnsfrd_out_in_period),
      decode(change.emails_trnsfrd_in_in_period, 0, to_number(null), change.emails_trnsfrd_in_in_period),
      decode(change.emails_rsl_and_trfd_in_period, 0, to_number(null), change.emails_rsl_and_trfd_in_period),
      decode(change.emails_assigned_in_period, 0, to_number(null), change.emails_assigned_in_period),
      decode(change.emails_auto_routed_in_period, 0, to_number(null), change.emails_auto_routed_in_period),
      decode(change.emails_auto_uptd_sr_in_period, 0, to_number(null), change.emails_auto_uptd_sr_in_period),
      decode(change.sr_created_in_period, 0, to_number(null), change.sr_created_in_period),
      change.oldest_email_open_date,
      change.oldest_email_queue_date,
      decode(change.email_resp_time_in_period, 0, to_number(null), change.email_resp_time_in_period),
      decode(change.agent_resp_time_in_period, 0, to_number(null), change.agent_resp_time_in_period),
      decode(change.acc_open_emails, 0, to_number(null), change.acc_open_emails),
      decode(change.acc_open_age, 0, to_number(null), change.acc_open_age),
      decode(change.acc_emails_in_queue, 0, to_number(null), change.acc_emails_in_queue),
      decode(change.acc_queue_time, 0, to_number(null), change.acc_queue_time),
      decode(change.acc_emails_one_day, 0, to_number(null), change.acc_emails_one_day),
      decode(change.acc_emails_three_days, 0, to_number(null), change.acc_emails_three_days),
      decode(change.acc_emails_week, 0, to_number(null), change.acc_emails_week),
      decode(change.acc_emails_week_plus, 0, to_number(null), change.acc_emails_week_plus),
      decode(change.emails_orr_count_in_period,0,to_number(null),change.emails_orr_count_in_period),
      decode(change.EMAILS_AUTO_REPLIED_IN_PERIOD,0,to_number(null),change.EMAILS_AUTO_REPLIED_IN_PERIOD),
      decode(change.EMAILS_AUTO_DELETED_IN_PERIOD,0,to_number(null),change.EMAILS_AUTO_DELETED_IN_PERIOD),
      decode(change.EMAILS_AUTO_RESOLVED_IN_PERIOD,0,to_number(null),change.EMAILS_AUTO_RESOLVED_IN_PERIOD),
      decode(change.emails_composed_in_period,0,to_number(null),change.emails_composed_in_period),
	 decode(change.emails_rerouted_in_period,0,to_number(null),change.emails_rerouted_in_period),
	 decode(change.leads_created_in_period,0,to_number(null),change.leads_created_in_period),
      g_request_id,
      g_program_appl_id,
      g_program_id,
      g_sysdate);

  g_rows_ins_upd := g_rows_ins_upd + SQL%ROWCOUNT;

  COMMIT;

  write_log('Finished procedure summarize_data at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure summarize_data : Error : ' || sqlerrm);
    RAISE;
END summarize_data;

---------------------------------------------------------------------------

PROCEDURE move_stg_to_fact
IS

BEGIN

MERGE INTO BIX_EMAIL_DETAILS_F summ
USING
(
SELECT
 AGENT_ID,
 EMAIL_ACCOUNT_ID,
 EMAIL_CLASSIFICATION_ID,
 PARTY_ID,
 TIME_ID,
 PERIOD_TYPE_ID,
 PERIOD_START_DATE,
 PERIOD_START_TIME,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN,
 nvl(EMAILS_OFFERED_IN_PERIOD,0) EMAILS_OFFERED_IN_PERIOD,
 nvl(EMAILS_FETCHED_IN_PERIOD,0) EMAILS_FETCHED_IN_PERIOD,
 nvl(EMAILS_REPLIED_IN_PERIOD,0) EMAILS_REPLIED_IN_PERIOD,
 nvl(EMAILS_RPLD_BY_GOAL_IN_PERIOD,0) EMAILS_RPLD_BY_GOAL_IN_PERIOD,
 nvl(AGENT_EMAILS_RPLD_BY_GOAL,0) AGENT_EMAILS_RPLD_BY_GOAL,
 nvl(EMAILS_DELETED_IN_PERIOD,0) EMAILS_DELETED_IN_PERIOD,
 nvl(EMAILS_TRNSFRD_OUT_IN_PERIOD,0) EMAILS_TRNSFRD_OUT_IN_PERIOD,
 nvl(EMAILS_TRNSFRD_IN_IN_PERIOD,0) EMAILS_TRNSFRD_IN_IN_PERIOD,
 nvl(EMAILS_RSL_AND_TRFD_IN_PERIOD,0) EMAILS_RSL_AND_TRFD_IN_PERIOD,
 nvl(EMAILS_ASSIGNED_IN_PERIOD,0) EMAILS_ASSIGNED_IN_PERIOD,
 nvl(EMAILS_AUTO_ROUTED_IN_PERIOD,0) EMAILS_AUTO_ROUTED_IN_PERIOD,
 nvl(EMAILS_AUTO_UPTD_SR_IN_PERIOD,0) EMAILS_AUTO_UPTD_SR_IN_PERIOD,
 nvl(SR_CREATED_IN_PERIOD,0) SR_CREATED_IN_PERIOD,
 nvl(ACCUMULATED_OPEN_EMAILS,0) ACCUMULATED_OPEN_EMAILS,
 NULL ACCUMULATED_OPEN_AGE,
 to_date(NULL) OLDEST_EMAIL_OPEN_DATE,
 nvl(ACCUMULATED_EMAILS_IN_QUEUE,0) ACCUMULATED_EMAILS_IN_QUEUE,
 NULL ACCUMULATED_QUEUE_TIME,
 to_date(NULL) OLDEST_EMAIL_QUEUE_DATE,
 nvl(EMAIL_RESP_TIME_IN_PERIOD,0) EMAIL_RESP_TIME_IN_PERIOD,
 nvl(AGENT_RESP_TIME_IN_PERIOD,0) AGENT_RESP_TIME_IN_PERIOD,
 nvl(ACCUMULATED_EMAILS_ONE_DAY,0) ACCUMULATED_EMAILS_ONE_DAY,
 nvl(ACCUMULATED_EMAILS_THREE_DAYS,0) ACCUMULATED_EMAILS_THREE_DAYS,
 nvl(ACCUMULATED_EMAILS_WEEK,0) ACCUMULATED_EMAILS_WEEK,
 nvl(ACCUMULATED_EMAILS_WEEK_PLUS,0) ACCUMULATED_EMAILS_WEEK_PLUS,
 nvl(ONE_RSLN_IN_PERIOD,0) ONE_RSLN_IN_PERIOD,
 nvl(TWO_RSLN_IN_PERIOD,0) TWO_RSLN_IN_PERIOD,
 nvl(THREE_RSLN_IN_PERIOD,0) THREE_RSLN_IN_PERIOD,
 nvl(FOUR_RSLN_IN_PERIOD,0) FOUR_RSLN_IN_PERIOD,
 nvl(INTERACTION_THREADS_IN_PERIOD,0) INTERACTION_THREADS_IN_PERIOD,
 OUTCOME_ID,
 RESULT_ID,
 REASON_ID,
 nvl(EMAILS_AUTO_REPLIED_IN_PERIOD,0) EMAILS_AUTO_REPLIED_IN_PERIOD,
 nvl(EMAILS_AUTO_DELETED_IN_PERIOD,0) EMAILS_AUTO_DELETED_IN_PERIOD,
 nvl(EMAILS_AUTO_RESOLVED_IN_PERIOD,0) EMAILS_AUTO_RESOLVED_IN_PERIOD,
 nvl(EMAILS_ORR_COUNT_IN_PERIOD,0) EMAILS_ORR_COUNT_IN_PERIOD,
 nvl(EMAILS_COMPOSED_IN_PERIOD,0) EMAILS_COMPOSED_IN_PERIOD,
 nvl(LEADS_CREATED_IN_PERIOD,0) LEADS_CREATED_IN_PERIOD,
 nvl(EMAILS_REROUTED_IN_PERIOD,0) EMAILS_REROUTED_IN_PERIOD
FROM BIX_EMAIL_DETAILS_STG
) STG
ON
(
summ.AGENT_ID = stg.AGENT_ID
AND summ.EMAIL_ACCOUNT_ID = stg.EMAIL_ACCOUNT_ID
AND summ.EMAIL_CLASSIFICATION_ID = stg.EMAIL_CLASSIFICATION_ID
AND summ.PARTY_ID = stg.PARTY_ID
AND summ.TIME_ID = stg.TIME_ID
AND summ.PERIOD_TYPE_ID = stg.PERIOD_TYPE_ID
AND summ.PERIOD_START_DATE = stg.PERIOD_START_DATE
AND summ.PERIOD_START_TIME = stg.PERIOD_START_TIME
AND summ.OUTCOME_ID = stg.OUTCOME_ID
AND summ.RESULT_ID = stg.RESULT_ID
AND summ.REASON_ID = stg.REASON_ID
)
WHEN MATCHED
THEN
UPDATE
SET
 EMAILS_OFFERED_IN_PERIOD  =
     decode (
     nvl(summ.EMAILS_OFFERED_IN_PERIOD,0) + stg.EMAILS_OFFERED_IN_PERIOD,0,NULL,
     nvl(summ.EMAILS_OFFERED_IN_PERIOD,0) + stg.EMAILS_OFFERED_IN_PERIOD
            ),
 EMAILS_FETCHED_IN_PERIOD =
     decode (
     nvl(summ.EMAILS_FETCHED_IN_PERIOD,0) + stg.EMAILS_FETCHED_IN_PERIOD ,0,NULL,
     nvl(summ.EMAILS_FETCHED_IN_PERIOD,0) + stg.EMAILS_FETCHED_IN_PERIOD
            ),
 EMAILS_REPLIED_IN_PERIOD =
     decode (
     nvl(summ.EMAILS_REPLIED_IN_PERIOD,0) + stg.EMAILS_REPLIED_IN_PERIOD ,0,NULL,
     nvl(summ.EMAILS_REPLIED_IN_PERIOD,0) + stg.EMAILS_REPLIED_IN_PERIOD
            ),
 EMAILS_RPLD_BY_GOAL_IN_PERIOD =
     decode (
     nvl(summ.EMAILS_RPLD_BY_GOAL_IN_PERIOD,0) + stg.EMAILS_RPLD_BY_GOAL_IN_PERIOD ,0,NULL,
     nvl(summ.EMAILS_RPLD_BY_GOAL_IN_PERIOD,0) + stg.EMAILS_RPLD_BY_GOAL_IN_PERIOD
            ),
 AGENT_EMAILS_RPLD_BY_GOAL =
      decode (
      nvl(summ.AGENT_EMAILS_RPLD_BY_GOAL,0) + stg.AGENT_EMAILS_RPLD_BY_GOAL ,0,NULL,
      nvl(summ.AGENT_EMAILS_RPLD_BY_GOAL,0) + stg.AGENT_EMAILS_RPLD_BY_GOAL
             ),
 EMAILS_DELETED_IN_PERIOD =
     decode (
     nvl(summ.EMAILS_DELETED_IN_PERIOD,0) + stg.EMAILS_DELETED_IN_PERIOD ,0,NULL,
     nvl(summ.EMAILS_DELETED_IN_PERIOD,0) + stg.EMAILS_DELETED_IN_PERIOD
            ),
 EMAILS_TRNSFRD_OUT_IN_PERIOD =
     decode (
     nvl(summ.EMAILS_TRNSFRD_OUT_IN_PERIOD,0) + stg.EMAILS_TRNSFRD_OUT_IN_PERIOD ,0,NULL,
     nvl(summ.EMAILS_TRNSFRD_OUT_IN_PERIOD,0) + stg.EMAILS_TRNSFRD_OUT_IN_PERIOD
            ),
 EMAILS_TRNSFRD_IN_IN_PERIOD =
     decode (
     nvl(summ.EMAILS_TRNSFRD_IN_IN_PERIOD,0) + stg.EMAILS_TRNSFRD_IN_IN_PERIOD ,0,NULL,
     nvl(summ.EMAILS_TRNSFRD_IN_IN_PERIOD,0) + stg.EMAILS_TRNSFRD_IN_IN_PERIOD
            ),
 EMAILS_RSL_AND_TRFD_IN_PERIOD =
     decode (
     nvl(summ.EMAILS_RSL_AND_TRFD_IN_PERIOD,0) + stg.EMAILS_RSL_AND_TRFD_IN_PERIOD ,0,NULL,
     nvl(summ.EMAILS_RSL_AND_TRFD_IN_PERIOD,0) + stg.EMAILS_RSL_AND_TRFD_IN_PERIOD
            ),
 EMAILS_ASSIGNED_IN_PERIOD =
     decode (
     nvl(summ.EMAILS_ASSIGNED_IN_PERIOD,0) + stg.EMAILS_ASSIGNED_IN_PERIOD ,0,NULL,
     nvl(summ.EMAILS_ASSIGNED_IN_PERIOD,0) + stg.EMAILS_ASSIGNED_IN_PERIOD
            ),
 EMAILS_AUTO_ROUTED_IN_PERIOD =
     decode (
     nvl(summ.EMAILS_AUTO_ROUTED_IN_PERIOD,0) + stg.EMAILS_AUTO_ROUTED_IN_PERIOD ,0,NULL,
     nvl(summ.EMAILS_AUTO_ROUTED_IN_PERIOD,0) + stg.EMAILS_AUTO_ROUTED_IN_PERIOD
            ),
 EMAILS_AUTO_UPTD_SR_IN_PERIOD =
     decode (
     nvl(summ.EMAILS_AUTO_UPTD_SR_IN_PERIOD,0) + stg.EMAILS_AUTO_UPTD_SR_IN_PERIOD ,0,NULL,
     nvl(summ.EMAILS_AUTO_UPTD_SR_IN_PERIOD,0) + stg.EMAILS_AUTO_UPTD_SR_IN_PERIOD
            ),
 SR_CREATED_IN_PERIOD =
     decode (
     nvl(summ.SR_CREATED_IN_PERIOD,0) + stg.SR_CREATED_IN_PERIOD ,0,NULL,
     nvl(summ.SR_CREATED_IN_PERIOD,0) + stg.SR_CREATED_IN_PERIOD
            ),
 ACCUMULATED_OPEN_EMAILS = stg.ACCUMULATED_OPEN_EMAILS,
 ACCUMULATED_EMAILS_IN_QUEUE = stg.ACCUMULATED_EMAILS_IN_QUEUE,
 EMAIL_RESP_TIME_IN_PERIOD =
     decode (
     nvl(summ.EMAIL_RESP_TIME_IN_PERIOD,0) + stg.EMAIL_RESP_TIME_IN_PERIOD ,0,NULL,
     nvl(summ.EMAIL_RESP_TIME_IN_PERIOD,0) + stg.EMAIL_RESP_TIME_IN_PERIOD
            ),
 AGENT_RESP_TIME_IN_PERIOD =
     decode (
     nvl(summ.AGENT_RESP_TIME_IN_PERIOD,0) + stg.AGENT_RESP_TIME_IN_PERIOD ,0,NULL,
     nvl(summ.AGENT_RESP_TIME_IN_PERIOD,0) + stg.AGENT_RESP_TIME_IN_PERIOD
            ),
 ACCUMULATED_EMAILS_ONE_DAY = decode(stg.ACCUMULATED_EMAILS_ONE_DAY,0,to_number(null),stg.ACCUMULATED_EMAILS_ONE_DAY),
 ACCUMULATED_EMAILS_THREE_DAYS = decode(stg.ACCUMULATED_EMAILS_THREE_DAYS,0,to_number(null),stg.ACCUMULATED_EMAILS_THREE_DAYS),
 ACCUMULATED_EMAILS_WEEK = decode(stg.ACCUMULATED_EMAILS_WEEK,0,to_number(null),stg.ACCUMULATED_EMAILS_WEEK),
 ACCUMULATED_EMAILS_WEEK_PLUS = decode(stg.ACCUMULATED_EMAILS_WEEK_PLUS,0,to_number(null),stg.ACCUMULATED_EMAILS_WEEK_PLUS),
 ONE_RSLN_IN_PERIOD =
     decode (
     nvl(summ.ONE_RSLN_IN_PERIOD,0) + stg.ONE_RSLN_IN_PERIOD ,0,NULL,
     nvl(summ.ONE_RSLN_IN_PERIOD,0) + stg.ONE_RSLN_IN_PERIOD
            ),
 TWO_RSLN_IN_PERIOD =
     decode (
     nvl(summ.TWO_RSLN_IN_PERIOD,0) + stg.TWO_RSLN_IN_PERIOD ,0,NULL,
     nvl(summ.TWO_RSLN_IN_PERIOD,0) + stg.TWO_RSLN_IN_PERIOD
            ),
 THREE_RSLN_IN_PERIOD =
     decode (
     nvl(summ.THREE_RSLN_IN_PERIOD,0) + stg.THREE_RSLN_IN_PERIOD ,0,NULL,
     nvl(summ.THREE_RSLN_IN_PERIOD,0) + stg.THREE_RSLN_IN_PERIOD
            ),
 FOUR_RSLN_IN_PERIOD =
     decode (
     nvl(summ.FOUR_RSLN_IN_PERIOD,0) + stg.FOUR_RSLN_IN_PERIOD ,0,NULL,
     nvl(summ.FOUR_RSLN_IN_PERIOD,0) + stg.FOUR_RSLN_IN_PERIOD
            ),
 INTERACTION_THREADS_IN_PERIOD =
     decode (
     nvl(summ.INTERACTION_THREADS_IN_PERIOD,0) + stg.INTERACTION_THREADS_IN_PERIOD ,0,NULL,
     nvl(summ.INTERACTION_THREADS_IN_PERIOD,0) + stg.INTERACTION_THREADS_IN_PERIOD
            ),
 EMAILS_AUTO_REPLIED_IN_PERIOD =
     decode (
     nvl(summ.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + stg.EMAILS_AUTO_REPLIED_IN_PERIOD ,0,NULL,
     nvl(summ.EMAILS_AUTO_REPLIED_IN_PERIOD,0) + stg.EMAILS_AUTO_REPLIED_IN_PERIOD
            ),
 EMAILS_AUTO_DELETED_IN_PERIOD =
     decode (
     nvl(summ.EMAILS_AUTO_DELETED_IN_PERIOD,0) + stg.EMAILS_AUTO_DELETED_IN_PERIOD ,0,NULL,
     nvl(summ.EMAILS_AUTO_DELETED_IN_PERIOD,0) + stg.EMAILS_AUTO_DELETED_IN_PERIOD
            ),
 EMAILS_AUTO_RESOLVED_IN_PERIOD =
     decode (
     nvl(summ.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + stg.EMAILS_AUTO_RESOLVED_IN_PERIOD ,0,NULL,
     nvl(summ.EMAILS_AUTO_RESOLVED_IN_PERIOD,0) + stg.EMAILS_AUTO_RESOLVED_IN_PERIOD
            ),
 EMAILS_ORR_COUNT_IN_PERIOD =
     decode (
     nvl(summ.EMAILS_ORR_COUNT_IN_PERIOD,0) + stg.EMAILS_ORR_COUNT_IN_PERIOD ,0,NULL,
     nvl(summ.EMAILS_ORR_COUNT_IN_PERIOD,0) + stg.EMAILS_ORR_COUNT_IN_PERIOD
            ),
 EMAILS_COMPOSED_IN_PERIOD =
     decode (
     nvl(summ.EMAILS_COMPOSED_IN_PERIOD,0) + stg.EMAILS_COMPOSED_IN_PERIOD ,0,NULL,
     nvl(summ.EMAILS_COMPOSED_IN_PERIOD,0) + stg.EMAILS_COMPOSED_IN_PERIOD
            ),
 LEADS_CREATED_IN_PERIOD =
     decode (
     nvl(summ.LEADS_CREATED_IN_PERIOD,0) + stg.LEADS_CREATED_IN_PERIOD ,0,NULL,
     nvl(summ.LEADS_CREATED_IN_PERIOD,0) + stg.LEADS_CREATED_IN_PERIOD
            ),
 EMAILS_REROUTED_IN_PERIOD =
     decode (
     nvl(summ.EMAILS_REROUTED_IN_PERIOD,0) + stg.EMAILS_REROUTED_IN_PERIOD ,0,NULL,
     nvl(summ.EMAILS_REROUTED_IN_PERIOD,0) + stg.EMAILS_REROUTED_IN_PERIOD
            )
WHEN NOT MATCHED
THEN
INSERT
(
 summ.AGENT_ID,
 summ.EMAIL_ACCOUNT_ID,
 summ.EMAIL_CLASSIFICATION_ID,
 summ.PARTY_ID,
 summ.TIME_ID,
 summ.PERIOD_TYPE_ID,
 summ.PERIOD_START_DATE,
 summ.PERIOD_START_TIME,
 summ.CREATED_BY,
 summ.CREATION_DATE,
 summ.LAST_UPDATED_BY,
 summ.LAST_UPDATE_DATE,
 summ.LAST_UPDATE_LOGIN,
 summ.EMAILS_OFFERED_IN_PERIOD,
 summ.EMAILS_FETCHED_IN_PERIOD,
 summ.EMAILS_REPLIED_IN_PERIOD,
 summ.EMAILS_RPLD_BY_GOAL_IN_PERIOD,
 summ.AGENT_EMAILS_RPLD_BY_GOAL,
 summ.EMAILS_DELETED_IN_PERIOD,
 summ.EMAILS_TRNSFRD_OUT_IN_PERIOD,
 summ.EMAILS_TRNSFRD_IN_IN_PERIOD,
 summ.EMAILS_RSL_AND_TRFD_IN_PERIOD,
 summ.EMAILS_ASSIGNED_IN_PERIOD,
 summ.EMAILS_AUTO_ROUTED_IN_PERIOD,
 summ.EMAILS_AUTO_UPTD_SR_IN_PERIOD,
 summ.SR_CREATED_IN_PERIOD,
 summ.ACCUMULATED_OPEN_EMAILS,
 summ.ACCUMULATED_OPEN_AGE,
 summ.OLDEST_EMAIL_OPEN_DATE,
 summ.ACCUMULATED_EMAILS_IN_QUEUE,
 summ.ACCUMULATED_QUEUE_TIME,
 summ.OLDEST_EMAIL_QUEUE_DATE,
 summ.EMAIL_RESP_TIME_IN_PERIOD,
 summ.AGENT_RESP_TIME_IN_PERIOD,
 summ.ACCUMULATED_EMAILS_ONE_DAY,
 summ.ACCUMULATED_EMAILS_THREE_DAYS,
 summ.ACCUMULATED_EMAILS_WEEK,
 summ.ACCUMULATED_EMAILS_WEEK_PLUS,
 summ.ONE_RSLN_IN_PERIOD,
 summ.TWO_RSLN_IN_PERIOD,
 summ.THREE_RSLN_IN_PERIOD,
 summ.FOUR_RSLN_IN_PERIOD,
 summ.INTERACTION_THREADS_IN_PERIOD,
 summ.OUTCOME_ID,
 summ.RESULT_ID,
 summ.REASON_ID,
 summ.EMAILS_AUTO_REPLIED_IN_PERIOD,
 summ.EMAILS_AUTO_DELETED_IN_PERIOD,
 summ.EMAILS_AUTO_RESOLVED_IN_PERIOD,
 summ.EMAILS_ORR_COUNT_IN_PERIOD,
 summ.EMAILS_COMPOSED_IN_PERIOD,
 summ.LEADS_CREATED_IN_PERIOD,
 summ.EMAILS_REROUTED_IN_PERIOD
)
values
(
 stg.AGENT_ID,
 stg.EMAIL_ACCOUNT_ID,
 stg.EMAIL_CLASSIFICATION_ID,
 stg.PARTY_ID,
 stg.TIME_ID,
 stg.PERIOD_TYPE_ID,
 stg.PERIOD_START_DATE,
 stg.PERIOD_START_TIME,
 stg.CREATED_BY,
 stg.CREATION_DATE,
 stg.LAST_UPDATED_BY,
 stg.LAST_UPDATE_DATE,
 stg.LAST_UPDATE_LOGIN,
 decode(stg.EMAILS_OFFERED_IN_PERIOD, 0,to_number(null),stg.EMAILS_OFFERED_IN_PERIOD),
 decode(stg.EMAILS_FETCHED_IN_PERIOD, 0,to_number(null),stg.EMAILS_FETCHED_IN_PERIOD),
 decode(stg.EMAILS_REPLIED_IN_PERIOD, 0,to_number(null),stg.EMAILS_REPLIED_IN_PERIOD),
 decode(stg.EMAILS_RPLD_BY_GOAL_IN_PERIOD, 0,to_number(null),stg.EMAILS_RPLD_BY_GOAL_IN_PERIOD),
 decode(stg.AGENT_EMAILS_RPLD_BY_GOAL, 0,to_number(null),stg.AGENT_EMAILS_RPLD_BY_GOAL),
 decode(stg.EMAILS_DELETED_IN_PERIOD, 0,to_number(null),stg.EMAILS_DELETED_IN_PERIOD),
 decode(stg.EMAILS_TRNSFRD_OUT_IN_PERIOD, 0,to_number(null),stg.EMAILS_TRNSFRD_OUT_IN_PERIOD),
 decode(stg.EMAILS_TRNSFRD_IN_IN_PERIOD, 0,to_number(null),stg.EMAILS_TRNSFRD_IN_IN_PERIOD),
 decode(stg.EMAILS_RSL_AND_TRFD_IN_PERIOD, 0,to_number(null),stg.EMAILS_RSL_AND_TRFD_IN_PERIOD),
 decode(stg.EMAILS_ASSIGNED_IN_PERIOD, 0,to_number(null),stg.EMAILS_ASSIGNED_IN_PERIOD),
 decode(stg.EMAILS_AUTO_ROUTED_IN_PERIOD, 0,to_number(null),stg.EMAILS_AUTO_ROUTED_IN_PERIOD),
 decode(stg.EMAILS_AUTO_UPTD_SR_IN_PERIOD, 0,to_number(null),stg.EMAILS_AUTO_UPTD_SR_IN_PERIOD),
 decode(stg.SR_CREATED_IN_PERIOD, 0,to_number(null),stg.SR_CREATED_IN_PERIOD),
 decode(stg.ACCUMULATED_OPEN_EMAILS, 0,to_number(null),stg.ACCUMULATED_OPEN_EMAILS),
 decode(stg.ACCUMULATED_OPEN_AGE, 0,to_number(null),stg.ACCUMULATED_OPEN_AGE),
 stg.OLDEST_EMAIL_OPEN_DATE,
 decode(stg.ACCUMULATED_EMAILS_IN_QUEUE, 0,to_number(null),stg.ACCUMULATED_EMAILS_IN_QUEUE),
 decode(stg.ACCUMULATED_QUEUE_TIME, 0,to_number(null),stg.ACCUMULATED_QUEUE_TIME),
 stg.OLDEST_EMAIL_QUEUE_DATE,
 decode(stg.EMAIL_RESP_TIME_IN_PERIOD, 0,to_number(null),stg.EMAIL_RESP_TIME_IN_PERIOD),
 decode(stg.AGENT_RESP_TIME_IN_PERIOD, 0,to_number(null),stg.AGENT_RESP_TIME_IN_PERIOD),
 decode(stg.ACCUMULATED_EMAILS_ONE_DAY, 0,to_number(null),stg.ACCUMULATED_EMAILS_ONE_DAY),
 decode(stg.ACCUMULATED_EMAILS_THREE_DAYS, 0,to_number(null),stg.ACCUMULATED_EMAILS_THREE_DAYS),
 decode(stg.ACCUMULATED_EMAILS_WEEK, 0,to_number(null),stg.ACCUMULATED_EMAILS_WEEK),
 decode(stg.ACCUMULATED_EMAILS_WEEK_PLUS, 0,to_number(null),stg.ACCUMULATED_EMAILS_WEEK_PLUS),
 decode(stg.ONE_RSLN_IN_PERIOD, 0,to_number(null),stg.ONE_RSLN_IN_PERIOD),
 decode(stg.TWO_RSLN_IN_PERIOD, 0,to_number(null),stg.TWO_RSLN_IN_PERIOD),
 decode(stg.THREE_RSLN_IN_PERIOD, 0,to_number(null),stg.THREE_RSLN_IN_PERIOD),
 decode(stg.FOUR_RSLN_IN_PERIOD, 0,to_number(null),stg.FOUR_RSLN_IN_PERIOD),
 decode(stg.INTERACTION_THREADS_IN_PERIOD, 0,to_number(null),stg.INTERACTION_THREADS_IN_PERIOD),
 stg.OUTCOME_ID,
 stg.RESULT_ID,
 stg.REASON_ID,
 decode(stg.EMAILS_AUTO_REPLIED_IN_PERIOD, 0,to_number(null),stg.EMAILS_AUTO_REPLIED_IN_PERIOD),
 decode(stg.EMAILS_AUTO_DELETED_IN_PERIOD, 0,to_number(null),stg.EMAILS_AUTO_DELETED_IN_PERIOD),
 decode(stg.EMAILS_AUTO_RESOLVED_IN_PERIOD, 0,to_number(null),stg.EMAILS_AUTO_RESOLVED_IN_PERIOD),
 decode(stg.EMAILS_ORR_COUNT_IN_PERIOD, 0,to_number(null),stg.EMAILS_ORR_COUNT_IN_PERIOD),
 decode(stg.EMAILS_COMPOSED_IN_PERIOD, 0,to_number(null),stg.EMAILS_COMPOSED_IN_PERIOD),
 decode(stg.LEADS_CREATED_IN_PERIOD, 0,to_number(null),stg.LEADS_CREATED_IN_PERIOD),
 decode(stg.EMAILS_REROUTED_IN_PERIOD, 0,to_number(null),stg.EMAILS_REROUTED_IN_PERIOD)
);

g_rows_ins_upd := g_rows_ins_upd + SQL%ROWCOUNT;
  --IF (g_debug_flag = 'Y') THEN
--write_log('Total rows moved into BIX_EMAIL_DETAILS_F : ' ||
                   --g_rows_ins_upd);
  --END IF;

COMMIT;

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure move_stg_to_fact : Error : ' || sqlerrm);
    RAISE;

END move_stg_to_fact;

---------------------------------------------------------------------------


/* This is the starting procedure called from worker Concurrent program */


PROCEDURE worker(errbuf      OUT   NOCOPY VARCHAR2,
                 retcode     OUT   NOCOPY VARCHAR2,
                 p_worker_no IN NUMBER) IS

  l_unassigned_cnt       NUMBER := 0;
  l_failed_cnt           NUMBER := 0;
  l_wip_cnt              NUMBER := 0;
  l_completed_cnt        NUMBER := 0;
  l_total_cnt            NUMBER := 0;
  l_count                NUMBER :=0;
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
    WHERE  object_name = 'BIX_EMAIL_DETAILS_F';

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
      write_log('Picking up an unassigned job');
      UPDATE BIX_WORKER_JOBS
      SET    status        = 'IN PROCESS',
             worker_number = p_worker_no
      WHERE  status = 'UNASSIGNED'
      AND    rownum < 2
      AND    object_name = 'BIX_EMAIL_DETAILS_F';

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
        AND   object_name   = 'BIX_EMAIL_DETAILS_F';

        g_collect_start_date := l_start_date_range;
        g_collect_end_date   := l_end_date_range;


        write_log('Calling procedure collect_emails from worker');
        collect_emails;
        write_log('End procedure collect_emails');

        /* Update the status of job to 'COMPLETED' */
        UPDATE BIX_WORKER_JOBS
        SET    status = 'COMPLETED'
        WHERE  status = 'IN PROCESS'
        AND    worker_number = p_worker_no
        AND    object_name = 'BIX_EMAIL_DETAILS_F';

        COMMIT;

      EXCEPTION
        WHEN OTHERS THEN
          retcode := -1;

          UPDATE BIX_WORKER_JOBS
          SET    status = 'FAILED'
          WHERE  worker_number = p_worker_no
          AND    status = 'IN PROCESS'
          AND    object_name = 'BIX_EMAIL_DETAILS_F';

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

/*

This procedure make use of worker archetecture to  collect the measures parallely for different days.
each worker loads data  1 day at a time.
if the collection date range is more than 1 day and user has specified to launch more than 1 worker ,
then launch parallel workers to do the collection of each day

Once the data is collected at day level, it summarizes the data by calling summarize_data procedure.

Resolution collection is done at the end after summarizing the data.
This is because if there was an interaction one and done some time back now
it is no longer one and done. It needs to be subtracted from one and done  and add to two or three or four done
depending on its current status in all rows  including all type of rows ( week, month, quarter and Year).

*/


PROCEDURE MAIN ( errbuf       OUT NOCOPY VARCHAR2,
                 retcode      OUT NOCOPY VARCHAR2,
                 p_start_date IN  VARCHAR2,
                 p_end_date   IN  VARCHAR2,
                 p_number_of_processes IN NUMBER) IS

  l_has_missing_date  BOOLEAN := FALSE;
  l_no_of_workers NUMBER;

BEGIN
  errbuf  := null;
  retcode := 0;

  write_log('Collection start date as specified by the user : ' || p_start_date);
  write_log('Collection end date as specified by the user : ' || p_end_date);

  /* get the collection date range */
  g_collect_start_date := TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
  g_collect_end_date   := TO_DATE(p_end_date, 'YYYY/MM/DD HH24:MI:SS');







  /* Check if the time dimension is populated for the collection date range ; if not exit */
  fii_time_api.check_missing_date(g_collect_start_date, g_collect_end_date, l_has_missing_date);
  IF (l_has_missing_date) THEN
    write_log('Time dimension is not populated for the entire collection date range');
    RAISE G_TIME_DIM_MISSING;
  END IF;

  /* if the collection date range is more than 1 day and user has specified to launch more than 1 worker , */
  /* then launch parallel workers to do the half hour collection of each day */
  IF (((g_collect_end_date - g_collect_start_date) > 1) AND
          (p_number_of_processes > 1)) THEN
    write_log('Calling procedure register_jobs');
    register_jobs;
    write_log('End procedure register_jobs');

    l_no_of_workers := least(g_no_of_jobs, p_number_of_processes);

    write_log('Launching Workers');
    /* Launch a parallel worker for each day of the collection date range or number of processes */
    /* user has requested for , whichever is less */
    FOR i IN 1 .. l_no_of_workers
    LOOP
      g_worker(i) := LAUNCH_WORKER(i);
    END LOOP;
    write_log('Number of Workers launched : ' || to_char(l_no_of_workers));

    COMMIT;

    write_log('Monitoring child processess .....');
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
        WHERE  OBJECT_NAME = 'BIX_EMAIL_DETAILS_F';

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
/*
        IF (l_cycle > MAX_LOOP) THEN
            RAISE G_CHILD_PROCESS_ISSUE;
        END IF;

		*/

        dbms_lock.sleep(60);

        l_last_unassigned_cnt := l_unassigned_cnt;
        l_last_completed_cnt := l_completed_cnt;
        l_last_wip_cnt := l_wip_cnt;

      END LOOP;

    END;   -- Monitor child process Ends here.
    write_log('Done monitoring child processes');
  ELSE
    /* if no child process , then collect the day's data for the entire date range */
    write_log('Calling procedure collect_emails');
    collect_emails;
    write_log('End procedure collect_emails');
  END IF;

  /* Summarize data to day, week, month, quater and year time buckets */
  write_log('Calling procedure summarize_data');
  summarize_data;

  --REMOVE COMMENTED ABOVE????????????????????????????

  write_log('End procedure summarize_data');

  write_log('Calling procedure move_stg_to_fact');
  move_stg_to_fact;

  write_log('Total Rows Inserted/Updated : ' || to_char(g_rows_ins_upd));

  /* Collect the resolutions measures */
    write_log('Calling procedure collect_resolutions');
      collect_resolutions;
	   write_log('End procedure collect_resolutions');






  /* Insert the status into collect log table */
  write_log('Calling procedure WRAPUP');
  bis_collection_utilities.wrapup(
      p_status      => TRUE,
      p_count       => g_rows_ins_upd,
      p_message     => NULL,
      p_period_from => g_collect_start_date,
      p_period_to   => g_collect_end_date);
  write_log('End Proceddure WRAPUP');

  write_log('Finished Procedure BIX_EMALS_SUMMARY_PKG with success at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN G_PARAM_MISMATCH THEN
    bis_collection_utilities.wrapup(
      p_status      => FALSE,
      p_count       => 0,
      p_message     => '0 rows collected : wait for at least half hour between two executions of this program',
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
END MAIN;


/*

This procedure is called from the Update Email Summary concurrent program.
This procedure calls init to do some initialization and calls  MAIN procedure with start and End Dates.

*/


PROCEDURE  load (errbuf                OUT  NOCOPY VARCHAR2,
                 retcode               OUT  NOCOPY VARCHAR2,
                 p_number_of_processes IN   NUMBER)
IS
  l_last_start_date  DATE;
  l_last_end_date    DATE;
  l_last_period_from DATE;
  l_last_period_to   DATE;
  l_end_date         DATE;
  l_min_media_date   DATE;
BEGIN



  init;
  write_log('End procedure init');


SELECT
MAX(Decode(milcs_code,'EMAIL_PROCESSING',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_REPLY',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_AUTO_REPLY',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_FETCH',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_OPEN',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_TRANSFER',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_TRANSFERRED',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_ASSIGN_OPEN',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_ASSIGNED',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_AUTO_ROUTED',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_AUTO_UPDATED_SR',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_ESCALATED',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_DELETED',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_AUTO_DELETED',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_AUTO_REDIRECTED',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_RESOLVED',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_REROUTED_DIFF_CLASS',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_REROUTED_DIFF_ACCT',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_REQUEUED',milcs_type_id)) ,
MAX(Decode(milcs_code,'EMAIL_COMPOSE',milcs_type_id))
INTO
G_PROCESSING,
G_REPLY,
G_A_REPLY,
G_FETCH,
G_OPEN,
G_TRANSFER,
G_TRANSFERRED,
G_ASSIGN_OPEN,
G_ASSIGNED,
G_A_ROUTED,
G_A_UPDATED_SR,
G_ESCALATED,
G_DELETED,
G_A_DELETED,
G_A_REDIRECTED,
G_RESOLVED,
G_REROUTED_CLASS,
G_REROUTED_ACCT,
G_REQUEUED,
G_COMPOSE
FROM jtf_ih_media_itm_lc_seg_tys
WHERE milcs_code IN
(
'EMAIL_PROCESSING'
,'EMAIL_REPLY','EMAIL_AUTO_REPLY'
,'EMAIL_FETCH'
,'EMAIL_OPEN'
,'EMAIL_TRANSFER','EMAIL_TRANSFERRED'
,'EMAIL_ASSIGN_OPEN','EMAIL_ASSIGNED'
,'EMAIL_AUTO_ROUTED', 'EMAIL_AUTO_UPDATED_SR'
,'EMAIL_ESCALATED'
,'EMAIL_DELETED','EMAIL_AUTO_DELETED' ,'EMAIL_AUTO_REDIRECTED'
,'EMAIL_RESOLVED'
,'EMAIL_REROUTED_DIFF_CLASS','EMAIL_REROUTED_DIFF_ACCT','EMAIL_REQUEUED'
,'EMAIL_COMPOSE'
);





  BIS_COLLECTION_UTILITIES.get_last_refresh_dates('BIX_EMAIL_DETAILS_F',
                                                   l_last_start_date,
                                                   l_last_end_date,
                                                   l_last_period_from,
                                                   l_last_period_to);


  IF l_last_period_to IS NULL THEN
    l_last_period_to := to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'),'MM/DD/YYYY');
  END IF;
  l_last_period_to := l_last_period_to + 1/86400;

  --
  --Go back 5 mins so that all the data commits etc would be done
  --
  --l_end_date := sysdate - 5/(60*24);
  l_end_date := sysdate;

    Truncate_Table('BIX_EMAIL_DETAILS_STG');
  -- ?? Need code review for date logic - do we need TRUNC etc
  --Check to see if the media or interaction table was updated after the last time the ICI program
  --was run.  If so, store the date so that we go back and recollect those dates to get the latest
  --information. This will happen in case of re-routes where the ACCOUNT/CLASSIFICATION on
  --JTF_IH_MEDIA_ITEMS changes or it can happen when the PARTY_ID changes.
  --

  SELECT min(med.start_date_time)
  INTO l_min_media_date
  FROM jtf_ih_media_items med, jtf_ih_interactions int, jtf_ih_activities act,
        jtf_ih_media_item_lc_segs segs, jtf_ih_media_itm_lc_seg_tys tys
  WHERE med.media_item_type = 'EMAIL'
  AND int.interaction_id = act.interaction_id
  AND med.media_id = act.media_id
  AND med.media_id = segs.media_id
  AND segs.milcs_type_id = tys.milcs_type_id
  AND (
        (med.last_update_date BETWEEN l_last_period_to AND l_end_date
         --AND milcs_code in ('EMAIL_REROUTED_DIFF_ACCT', 'EMAIL_REROUTED_DIFF_CLASS')
         )
        OR int.last_update_date BETWEEN l_last_period_to AND l_end_date
       );

  IF l_min_media_date >= l_last_period_to OR l_min_media_date IS NULL   THEN
     --
	--This means there were no medias or interactions which got changed after ICI
	--collected them.
	--
	write_log('No updates to media or interaction which have already been collected');
     write_log('l_min_media_date ' || l_min_media_date || ' greater than last_period_to ' ||
                to_char(l_last_period_to,'DD-MON-YYYY HH24:MI:SS'));
     NULL;
  ELSIF l_min_media_date < l_last_period_to
  THEN


    write_log('l_min_media_date ' || l_min_media_date || ' less than last_period_to ' ||
                to_char(l_last_period_to,'DD-MON-YYYY HH24:MI:SS'));

     --
	--Using the values which are going to be deleted, ROLLUP as negative values
	--so that the higher level period types get subtracted. This is needed since we cannot
	--do FIRST_VALUE in MV. Hence ROLLUP cannot be moved into the MV layer.
	--
	--?????
	--we are changing the original ROLLUP and forcing to do a SUM even for the queue measures so
	--that they will cancel out with the newly added negative numbers. Is this okay to do??
	--also, what to do about oldest open age and oldest open date etc?
	--???
	--
 rollup_negatives(trunc(l_min_media_date));
 write_log ('FInished rolling up negative values');

     --
	--This means there are some old medias or old interactions which changed after ICI
	--collected them.
	--


/*
	DELETE BIX_EMAIL_DETAILS_F
	WHERE period_start_date >= trunc(l_min_media_date)
	AND period_type_id = 1;
  */
    --Update all the measures to 0 except the onedone,twodone resolution measures and interaction threads
update bix_email_details_f
set
LAST_UPDATED_BY                 =g_user_id,
LAST_UPDATE_DATE                =g_sysdate,
EMAILS_OFFERED_IN_PERIOD        =null,
EMAILS_FETCHED_IN_PERIOD        =null,
EMAILS_REPLIED_IN_PERIOD        =null,
EMAILS_RPLD_BY_GOAL_IN_PERIOD   =null,
AGENT_EMAILS_RPLD_BY_GOAL	=null,
EMAILS_DELETED_IN_PERIOD        =null,
EMAILS_TRNSFRD_OUT_IN_PERIOD    =null,
EMAILS_TRNSFRD_IN_IN_PERIOD     =null,
EMAILS_RSL_AND_TRFD_IN_PERIOD   =null,
EMAILS_ASSIGNED_IN_PERIOD       =null,
EMAILS_AUTO_ROUTED_IN_PERIOD    =null,
EMAILS_AUTO_UPTD_SR_IN_PERIOD   =null,
SR_CREATED_IN_PERIOD            =null,
ACCUMULATED_OPEN_EMAILS         =null,
ACCUMULATED_OPEN_AGE            =null,
OLDEST_EMAIL_OPEN_DATE          =to_date(null),
ACCUMULATED_EMAILS_IN_QUEUE     =null,
ACCUMULATED_QUEUE_TIME          =null,
OLDEST_EMAIL_QUEUE_DATE         =to_date(null),
EMAIL_RESP_TIME_IN_PERIOD       =null,
AGENT_RESP_TIME_IN_PERIOD       =null,
ACCUMULATED_EMAILS_ONE_DAY      =null,
ACCUMULATED_EMAILS_THREE_DAYS   =null,
ACCUMULATED_EMAILS_WEEK         =null,
ACCUMULATED_EMAILS_WEEK_PLUS    =null,
EMAILS_AUTO_REPLIED_IN_PERIOD   =null,
EMAILS_AUTO_DELETED_IN_PERIOD   =null,
EMAILS_AUTO_RESOLVED_IN_PERIOD  =null,
EMAILS_ORR_COUNT_IN_PERIOD      =null,
EMAILS_COMPOSED_IN_PERIOD       =null,
LEADS_CREATED_IN_PERIOD       	=null,
EMAILS_REROUTED_IN_PERIOD       =null,
ONE_RSLN_IN_PERIOD              =null,
TWO_RSLN_IN_PERIOD              =null,
THREE_RSLN_IN_PERIOD            =null,
FOUR_RSLN_IN_PERIOD             =null,
INTERACTION_THREADS_IN_PERIOD   =null,
REQUEST_ID=g_request_id
--WHERE period_start_date >= trunc(l_min_media_date)
WHERE time_id >= to_number(to_char(trunc(l_min_media_date),'J'))
AND period_type_id = 1;


--
--??SHOULD WE DELETE OR JUST UPDATE TO ALL ZERO VALUES - LATTER MIGHT
--PERFORM BETTER
--

	COMMIT;
	write_log ('Finished deleting bix_email_details_f');

     DELETE BIX_INTERACTIONS_TEMP BIXTEMP
	WHERE EXISTS
	      (
		 SELECT INTERACTION_ID
		 FROM JTF_IH_INTERACTIONS INT
		 WHERE START_DATE_TIME >= trunc(l_min_media_date)
		 AND INT.INTERACTION_ID = BIXTEMP.INTERACTION_ID
		 );

     COMMIT;

	write_log ('Finished deleting bix_interactions_temp');

     --
     --Set l_last_period_to to l_min_media_date to recollect the days
     --it might turn out that even days which werent affected need to be recollected - but the most frequent
     --case where this happens is the change of the default customer which should happen
     --within a few days of the email coming in, it should not have a signifcant performance impact.
     --
     l_last_period_to := trunc(l_min_media_date);

   END IF;


--l_last_period_to:=to_date('25/7/2004','dd/mm/yyyy');
--l_end_date:=to_date('07/19/2004 01:00','mm/dd/yyyy hh24:mi');

  write_log ('Calling MAIN with start date ' || l_last_period_to || ' l_end_date ' || l_end_date);
  Main(errbuf,
       retcode,
       TO_CHAR(l_last_period_to, 'YYYY/MM/DD HH24:MI:SS'),
       TO_CHAR(l_end_date, 'YYYY/MM/DD HH24:MI:SS'),
       p_number_of_processes);
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END load;

END BIX_EMAILS_SUMMARY_PKG;

/
