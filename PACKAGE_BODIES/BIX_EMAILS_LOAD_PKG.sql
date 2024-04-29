--------------------------------------------------------
--  DDL for Package Body BIX_EMAILS_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_EMAILS_LOAD_PKG" AS
/*$Header: bixemllb.plb 120.6 2006/08/04 11:09:38 pubalasu noship $ */

  g_request_id                  NUMBER;
  g_program_appl_id             NUMBER;
  g_program_id                  NUMBER;
  g_user_id                     NUMBER;
  g_collect_start_date          DATE;
  g_collect_end_date            DATE;
  g_commit_chunk_size           NUMBER;
  g_rows_ins_upd                NUMBER;
  g_sysdate                     DATE;
  g_bix_schema                  VARCHAR2(30) := 'BIX';
  g_debug_flag                  VARCHAR2(1)  := 'N';

  G_TIME_DIM_MISSING            EXCEPTION;

  TYPE g_media_id_tab IS TABLE OF jtf_ih_media_items.media_id%TYPE;
  TYPE g_email_account_id_tab IS TABLE OF jtf_ih_media_items.source_id%TYPE;
  TYPE g_email_classification_id_tab IS TABLE OF iem_route_classifications.route_classification_id%TYPE;
  TYPE g_resource_id_tab IS TABLE OF bix_email_details_f.agent_id%TYPE;
  TYPE g_party_id_tab IS TABLE OF bix_email_details_f.party_id%TYPE;
  TYPE g_start_date_time_tab IS TABLE OF jtf_ih_media_item_lc_segs.start_date_time%TYPE;
  TYPE g_end_date_time_tab IS TABLE OF jtf_ih_media_item_lc_segs.end_date_time%TYPE;
  TYPE g_media_start_date_time_tab IS TABLE OF jtf_ih_media_items.start_date_time%TYPE;
  TYPE g_period_start_date_tab IS TABLE OF bix_email_details_f.period_start_date%TYPE;

  TYPE g_emails_open_tab IS TABLE OF bix_email_details_f.accumulated_open_emails%TYPE;
  TYPE g_total_open_age_tab IS TABLE OF bix_email_details_f.accumulated_open_age%TYPE;
  TYPE g_oldest_open_message_tab IS TABLE OF bix_email_details_f.oldest_email_open_date%TYPE;
  TYPE g_emails_in_queue_tab IS TABLE OF bix_email_details_f.accumulated_emails_in_queue%TYPE;
  TYPE g_total_queue_time_tab IS TABLE OF bix_email_details_f.accumulated_queue_time%TYPE;
  TYPE g_oldest_message_in_queue_tab IS TABLE OF bix_email_details_f.oldest_email_queue_date%TYPE;
  TYPE g_acc_emails_one_day_tab IS TABLE OF bix_email_details_f.accumulated_emails_one_day%TYPE;
  TYPE g_acc_emails_three_days_tab IS TABLE OF bix_email_details_f.accumulated_emails_three_days%TYPE;
  TYPE g_acc_emails_week_tab IS TABLE OF bix_email_details_f.accumulated_emails_week%TYPE;
  TYPE g_acc_emails_week_plus_tab IS TABLE OF bix_email_details_f.accumulated_emails_week_plus%TYPE;

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

  write_log('Truncating the table bix_email_details_f and bix_interactions_temp');
  BIS_COLLECTION_UTILITIES.deleteLogForObject('BIX_EMAIL_DETAILS_F');
  Truncate_Table('BIX_EMAIL_DETAILS_F');
  Truncate_Table('BIX_INTERACTIONS_TEMP');
  write_log('Done truncating the table bix_email_details_f and bix_interactions_temp');

  write_log('Setting the sore and hash are size');
  execute immediate 'alter session set sort_area_size=104857600';
  execute immediate 'alter session set hash_area_size=104857600';

  write_log('Finished procedure init at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in init : Error : ' || sqlerrm);
    RAISE;
END init;


/* This procedure collects One, two , three and Four done resolutiions.  Email center keeps the threads of email
interactions in jtf_ih_interaction_inters table. If the customer reply back to the agent response then the entry will
be created in the above table with old and new interaction.   This table stores both parent and child interaction id.

We can find the depth of thread from this table.  If the table does not have entry in this
table for replied email, then the email interaction is one and done ,
if the depth is 1 then it is two and done and so on.

jtf_ih_interaction_inters:
This table gets an entry the moment the customer replies to an email.  If it doesnt have an entry it
means it is ONE AND DONE provided there is a reply.

INTERACT_INTERACTION_IDRELATES is the parent interaction
INTERACT_INTERACTION_ID        is the child interaction

START WITH and CONNECT BY are used to determine the depth.  The depth is needed
for 2-done, 3-done, 4-done.  It is not needed for 1-done.

In reports, only ONE_DONE is used - other DONES are for future use.

*/



PROCEDURE collect_resolutions IS

  CURSOR all_root_interactions IS
  SELECT /*+ ordered full(intr) full(actv) full(mitm) use_hash(mitm,actv,intr,) +*/
    intr.interaction_id interaction_id,
    max(nvl(intr.resource_id, -1)) resource_id,
    max(nvl(intr.party_id, -1)) party_id,
    max(intr.start_date_time) start_date_time,
    max(nvl(mitm.source_id, -1)) source_id,
    max(nvl(irc.route_classification_id, -1)) route_classification_id,
    max(nvl(iview.depth, 0)) depth
  FROM
    jtf_ih_media_items mitm,
    jtf_ih_activities actv,
    jtf_ih_interactions intr,
    --
    --Changes for R12
    --
    (
    select /*+ full(im) +*/  name, max(route_classification_id) route_classification_id
    from iem_route_classifications im
    group by name
    ) irc,
    (
	select
	interaction_id,
	sum(depth) depth
	from
	(
	   /* This returns the parent level interactions and hardcoded depth as 1 for email replies-auto replies */
       SELECT
			  actv.interaction_id interaction_id,
              1 depth
       FROM jtf_ih_activities actv,
          /*  jtf_ih_media_items imtm,*/
		    jtf_ih_media_item_lc_segs mseg,
            jtf_ih_media_itm_lc_seg_tys mtys
       WHERE  actv.media_id = mseg.media_id
       AND   mtys.milcs_type_id = mseg.milcs_type_id
       AND   mtys.milcs_code IN ('EMAIL_AUTO_REPLY','EMAIL_REPLY')
	   GROUP BY actv.interaction_id
        UNION ALL
	 /* This will count the no of replies that the interaction tree has. If there is no
	 child interaction that has a reply ,we need to go to the parent interaction level
	 and check if that has a reply, if so increment by 1 or leave it as is*/
	 SELECT 	root_interaction_id ,
	 /*NVL(max(decode(milcs_code,'EMAIL_REPLY',DEPTH,'EMAIL_AUTO_REPLY',DEPTH,NULL)),0)+1 DEPTH*/
	 count(distinct media_id)
	FROM
	(
		SELECT  /*+ ordered */
		   root_interaction_id,
		        parent,
			child,
			depth,
			mseg.media_id
			/* Added */
			--,
			--first_value(milcs_code) over (partition  by mseg.media_id order by mseg.start_Date_time desc) milcs_code
		FROM
		jtf_ih_media_itm_lc_seg_tys mtys,
		jtf_ih_media_item_lc_segs mseg,
		jtf_ih_media_items mitm,
		jtf_ih_activities actv ,
		(
			SELECT   to_number(decode(instr(sys_connect_by_path(intr3.interact_interaction_idrelates, ':'), ':', 2), 0,
			                substr(sys_connect_by_path(intr3.interact_interaction_idrelates, ':'), 2),
					substr(sys_connect_by_path(intr3.interact_interaction_idrelates, ':'), 2,
					instr(sys_connect_by_path(intr3.interact_interaction_idrelates, ':'), ':', 2)-2)))  root_interaction_id,
					intr3.interact_interaction_idrelates  parent,
		                intr3.interact_interaction_id child,
				        level        depth
	                 FROM  jtf_ih_interaction_inters intr3
		         START WITH intr3.interact_interaction_idrelates in
				(select
			          intr2.interact_interaction_idrelates
		                  from jtf_ih_interaction_inters intr2
                                  where intr2.interact_interaction_idrelates not in
				  (
		                      select
				      intr1.interact_interaction_id
		                      from jtf_ih_interaction_inters intr1
				   )
				 )
	                 CONNECT BY intr3.interact_interaction_idrelates = PRIOR intr3.interact_interaction_id
		) intr
		WHERE actv.interaction_id =intr.child
		AND   mitm.media_id = actv.media_id
		AND   mitm.media_id = mseg.media_id
		AND   mseg.milcs_type_id = mtys.milcs_type_id
		AND mitm.direction='INBOUND' AND mitm.media_item_type='EMAIL'
	    /* Added */ AND mtys.milcs_code in ('EMAIL_REPLY','EMAIL_AUTO_REPLY')

	) GROUP BY ROOT_INTERACTION_ID
	) iview/* Added */
	WHERE NOT EXISTS (
	select 1 from jtf_ih_interaction_inters inter
	WHERE iview.interaction_id =  inter.interact_interaction_id
	)
	group by interaction_id
  ) iview
  WHERE  intr.start_date_time between g_collect_start_date and g_collect_end_date
  AND
  intr.interaction_id = actv.interaction_id
  AND   intr.interaction_id = iview.interaction_id(+)
  AND   mitm.media_id = actv.media_id
  AND   mitm.direction = 'INBOUND'
  AND   mitm.media_item_type = 'EMAIL'
  AND   mitm.classification = irc.name(+)
  AND   intr.interaction_id NOT IN (
           SELECT
             inter.interact_interaction_id
           FROM   jtf_ih_interaction_inters inter)
  GROUP BY intr.interaction_id;




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
  l_curr_depth curr_depth_tab;

  l_no_of_records NUMBER;

BEGIN

  write_log('Start of the procedure collect_resolutions at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* Initialize the variables */
  l_one_done_rsln := one_done_rsln_tab();
  l_two_done_rsln := two_done_rsln_tab();
  l_three_done_rsln := three_done_rsln_tab();
  l_four_done_rsln := four_done_rsln_tab();
  l_intr_thread := intr_thread_tab();

  OPEN all_root_interactions;

  LOOP

    /* fetch all root interactions that have been created in the collection date range */
    /* or a reply has been given within the collection date range for the interaction  */
    FETCH all_root_interactions BULK COLLECT INTO
      l_root_interaction_id,
      l_agent_id,
      l_party_id,
      l_start_date_time,
      l_email_account_id,
      l_classification_id,
      l_curr_depth
    LIMIT g_commit_chunk_size;

    IF (l_root_interaction_id.COUNT > 0) THEN

      l_no_of_records := l_root_interaction_id.COUNT;

      /* Make place for all the interactions */
      l_one_done_rsln.EXTEND(l_no_of_records);
      l_two_done_rsln.EXTEND(l_no_of_records);
      l_three_done_rsln.EXTEND(l_no_of_records);
      l_four_done_rsln.EXTEND(l_no_of_records);
      l_intr_thread.EXTEND(l_no_of_records);

      FOR i IN l_root_interaction_id.FIRST .. l_root_interaction_id.LAST
      LOOP
        l_one_done_rsln(i) := 0;
        l_two_done_rsln(i) := 0;
        l_three_done_rsln(i) := 0;
        l_four_done_rsln(i) := 0;
        l_intr_thread(i) := 0;

        l_intr_thread(i) := 1;

        IF (l_curr_depth(i) = 1) THEN l_one_done_rsln(i) := 1;
        ELSIF (l_curr_depth(i) = 2) THEN l_two_done_rsln(i) := 1;
        ELSIF (l_curr_depth(i) = 3) THEN l_three_done_rsln(i) := 1;
        ELSIF (l_curr_depth(i) = 4) THEN l_four_done_rsln(i) := 1;
        END IF;

      END LOOP;

      /* Update the half-hour rows of ICI summary table with the resolution measures */
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

	 COMMIT;

      write_log('Total rows inserted/updated in bix_email_details_f for resolution : ' ||
                                                                      to_char(l_root_interaction_id.COUNT));
      g_rows_ins_upd := g_rows_ins_upd + (l_root_interaction_id.COUNT);

      /* Update the bix_interactions_temp table to keep track of depth by interaction */
--
--BIX_INTERACTION_TEMP is used for UPDATE program. This is used to keep track of
--whet we need to subtract - example yesterday an email might have been ONE AND DONE.
--Today the customer replies to it and it is no longer DONE.  So we need to go back and subtract
--yesterday's ONE AND DONE
--
      FORALL i IN l_root_interaction_id.FIRST .. l_root_interaction_id.LAST
        INSERT INTO BIX_INTERACTIONS_TEMP bit (
          interaction_id,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          depth,
          request_id,
          program_application_id,
          program_id,
          program_update_date )
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

	 COMMIT;

      write_log('Total rows inserted/updated in bix_interactions_temp : ' || to_char(l_root_interaction_id.COUNT));
      g_rows_ins_upd := g_rows_ins_upd + l_root_interaction_id.COUNT;

      l_one_done_rsln.TRIM(l_no_of_records);
      l_two_done_rsln.TRIM(l_no_of_records);
      l_three_done_rsln.TRIM(l_no_of_records);
      l_four_done_rsln.TRIM(l_no_of_records);
      l_intr_thread.TRIM(l_no_of_records);

    END IF;

    EXIT WHEN all_root_interactions%NOTFOUND;

  END LOOP;

  write_log('Finished procedure collect_resolutions at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure collect_resolutions : Error : ' || sqlerrm);
    RAISE;
END collect_resolutions;

PROCEDURE clean_up IS

  l_total_rows_deleted NUMBER := 0;
  l_rows_deleted       NUMBER := 0;

BEGIN
  write_log('Start of the procedure clean_up at ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));

  write_log('Truncating the table bix_email_details_f and bix_interactions_temp');
  BIS_COLLECTION_UTILITIES.deleteLogForObject('BIX_EMAIL_DETAILS_F');
  Truncate_Table('BIX_EMAIL_DETAILS_F');
  Truncate_Table('BIX_INTERACTIONS_TEMP');
  write_log('Done truncating the table bix_email_details_f and bix_interactions_temp');

  write_log('Finished procedure clean_up at ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in cleaning up the tables : Error : ' || sqlerrm);
    RAISE;
END CLEAN_UP;


/*
This procedure collects all the additive measures. In this procedure we collect all the measures except queue, open and resolution measures.
*/



PROCEDURE COLLECT_EMAILS IS

  l_email_service_level NUMBER;

BEGIN

  write_log('Start of the procedure collect_emails at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* Get the service level for the whole email center : if not defined then 1 day is the default */
  /* Multiply the profile by 60 * 60 to convert from hour to seconds                             */
  IF (FND_PROFILE.DEFINED('BIX_EMAIL_GOAL')) THEN
     l_email_service_level := TO_NUMBER(FND_PROFILE.VALUE('BIX_EMAIL_GOAL')) * 60 * 60;
  ELSE
     l_email_service_level := 24 * 60 * 60;
  END IF;
  write_log('The service level for the whole email center : ' || to_char(l_email_service_level) || ' seconds');

  write_log('Merging additive measures into table bix_email_details_f');

  /* Insert / Update additive measures to summary table bix_email_details_f */
  INSERT /*+ APPEND PARALLEL(bed) */ INTO BIX_EMAIL_DETAILS_F bed
     (email_account_id,
      email_classification_id,
      agent_id,
      party_id,
      time_id,
      period_type_id,
      period_start_date,
      period_start_time,
	 outcome_id,
	 result_id,
	 reason_id,
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
      emails_assigned_in_period,
      emails_auto_routed_in_period,
      emails_auto_uptd_sr_in_period,
      email_resp_time_in_period,
      agent_resp_time_in_period,
      sr_created_in_period,
      emails_rsl_and_trfd_in_period,
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
      program_update_date)
  (SELECT /*+ PARALLEL(inv2) */
      inv2.email_account_id,
      inv2.email_classification_id,
      inv2.agent_id,
      inv2.party_id,
      inv2.time_id,
      --1/2hr changed period_type_id to 1 from -1
      1,
      inv2.period_start_date,
      inv2.period_start_time,
	 inv2.outcome_id,
	 inv2.result_id,
	 inv2.reason_id,
      g_user_id,
      g_sysdate,
      g_user_id,
      g_sysdate,
      decode(sum(emails_offered_in_period), 0, to_number(null), sum(emails_offered_in_period)),
      decode(sum(emails_fetched_in_period), 0, to_number(null), sum(emails_fetched_in_period)),
      decode(sum(emails_replied_in_period), 0, to_number(null), sum(emails_replied_in_period)),
      decode(sum(emails_rpld_by_goal_in_period), 0, to_number(null), sum(emails_rpld_by_goal_in_period)),
      decode(sum(AGENT_EMAILS_RPLD_BY_GOAL), 0, to_number(null), sum(AGENT_EMAILS_RPLD_BY_GOAL)),
      decode(sum(emails_deleted_in_period), 0, to_number(null), sum(emails_deleted_in_period)),
      decode(sum(emails_trnsfrd_out_in_period), 0, to_number(null), sum(emails_trnsfrd_out_in_period)),
      decode(sum(emails_trnsfrd_in_in_period), 0, to_number(null), sum(emails_trnsfrd_in_in_period)),
      decode(sum(emails_assigned_in_period), 0, to_number(null), sum(emails_assigned_in_period)),
      decode(sum(emails_auto_routed_in_period), 0, to_number(null), sum(emails_auto_routed_in_period)),
      decode(sum(emails_auto_uptd_sr_in_period), 0, to_number(null), sum(emails_auto_uptd_sr_in_period)),
      decode(round(sum(email_resp_time_in_period)), 0, to_number(null), round(sum(email_resp_time_in_period))),
      decode(round(sum(agent_resp_time_in_period)), 0, to_number(null), round(sum(agent_resp_time_in_period))),
      decode(sum(sr_created_in_period), 0, to_number(null), sum(sr_created_in_period)),
      decode(sum(emails_rsl_and_trfd_in_period), 0, to_number(null), sum(emails_rsl_and_trfd_in_period)),
	 decode(sum(emails_orr_count_in_period), 0, to_number(null), sum(emails_orr_count_in_period)),
	 decode(sum(EMAILS_AUTO_REPLIED_IN_PERIOD), 0, to_number(null), sum(EMAILS_AUTO_REPLIED_IN_PERIOD)),
	 decode(sum(EMAILS_AUTO_DELETED_IN_PERIOD), 0, to_number(null), sum(EMAILS_AUTO_DELETED_IN_PERIOD)),
	 decode(sum(EMAILS_AUTO_RESOLVED_IN_PERIOD), 0, to_number(null), sum(EMAILS_AUTO_RESOLVED_IN_PERIOD)),
	 decode(sum(emails_composed_in_period), 0, to_number(null), sum(emails_composed_in_period)),
	 decode(sum(EMAILS_REROUTED_IN_PERIOD), 0, to_number(null), sum(EMAILS_REROUTED_IN_PERIOD)),
	 decode(sum(leads_created_in_period), 0, to_number(null), sum(leads_created_in_period)),
      g_request_id,
      g_program_appl_id,
      g_program_id,
      g_sysdate
   FROM  --This sql fetches the count of a whole bunch of pure email measures like fetched, replied etc
    (SELECT /*+ use_hash(mitm) use_hash(mseg) use_hash(inv2) use_hash(inv1) use_hash(mtyp) use_hash(irc)
                PARALLEL(mitm) PARALLEL(mseg) PARALLEL(inv2) PARALLEL(inv1) PARALLEL(mtyp) PARALLEL(irc) */
      nvl(mitm.source_id, -1)                              EMAIL_ACCOUNT_ID,
      nvl(irc.route_classification_id, -1)                 EMAIL_CLASSIFICATION_ID,
      nvl(mseg.resource_id, -1)                            AGENT_ID,
      nvl(inv1.party_id, -1)                               PARTY_ID,
      trunc(mseg.start_date_time)                          PERIOD_START_DATE,
      to_number(to_char(mseg.start_date_time, 'J'))        TIME_ID,
      --1/2hr
      --nvl(lpad(to_char(mseg.start_date_time,'HH24:'),3,'0') ||
      --  decode(sign(to_number(to_char(mseg.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'00:00')
      '00:00'
                                                           PERIOD_START_TIME,
      -1                                                   OUTCOME_ID,
      -1                                                   RESULT_ID,
      -1                                                   REASON_ID,
      0                                                    EMAILS_OFFERED_IN_PERIOD,
      sum(decode(mtyp.milcs_code,'EMAIL_FETCH',1))         EMAILS_FETCHED_IN_PERIOD,
      sum(decode(mtyp.milcs_code,'EMAIL_REPLY',1))         EMAILS_REPLIED_IN_PERIOD,

      sum(decode(mtyp.milcs_code,'EMAIL_REPLY', (mseg.start_date_time - inv2.start_date_time) * 24 * 60 * 60))
                                                           AGENT_RESP_TIME_IN_PERIOD,
      sum(decode(mtyp.milcs_code,'EMAIL_REPLY',
               decode(sign(l_email_service_level  - (mseg.start_date_time - mitm.start_date_time) * 24 * 60 * 60),-1,0,1)
			, 'EMAIL_AUTO_REPLY',
			 decode(sign(l_email_service_level  - (mseg.start_date_time - mitm.start_date_time) * 24 * 60 * 60),-1,0,1) ))
                                                           EMAILS_RPLD_BY_GOAL_IN_PERIOD,
      sum(decode(mtyp.milcs_code,'EMAIL_REPLY',
                     decode(sign(l_email_service_level  - (mseg.start_date_time - mitm.start_date_time) * 24 * 60 * 60),-1,0,1)
      			 ))
                                                                 AGENT_EMAILS_RPLD_BY_GOAL,
      sum(decode(mtyp.milcs_code,'EMAIL_TRANSFERRED',1,'EMAIL_ESCALATED',1))   EMAILS_TRNSFRD_OUT_IN_PERIOD,
      sum(decode(mtyp.milcs_code,'EMAIL_TRANSFER',1))      EMAILS_TRNSFRD_IN_IN_PERIOD,
      sum(decode(mtyp.milcs_code,'EMAIL_ASSIGNED',1))      EMAILS_ASSIGNED_IN_PERIOD,
      sum(decode(mtyp.milcs_code,'EMAIL_AUTO_ROUTED',1))   EMAILS_AUTO_ROUTED_IN_PERIOD,
      sum(decode(mtyp.milcs_code,'EMAIL_AUTO_UPDATED_SR',1))
                                                           EMAILS_AUTO_UPTD_SR_IN_PERIOD,
      sum(decode(mtyp.milcs_code,'EMAIL_DELETED',1))       EMAILS_DELETED_IN_PERIOD,
      sum(decode(mtyp.milcs_code,'EMAIL_REPLY', (mseg.start_date_time - mitm.start_date_time) * 24 * 60 * 60,
	                       'EMAIL_AUTO_REPLY',(mseg.start_date_time - mitm.start_date_time) * 24 * 60 * 60))
                                                           EMAIL_RESP_TIME_IN_PERIOD,
      0                                                    SR_CREATED_IN_PERIOD,
      0                                                    EMAILS_RSL_AND_TRFD_IN_PERIOD,
      sum(decode(mtyp.milcs_code,'EMAIL_AUTO_REPLY',1))    EMAILS_AUTO_REPLIED_IN_PERIOD,
      sum(decode(mtyp.milcs_code,'EMAIL_AUTO_DELETED',1))  EMAILS_AUTO_DELETED_IN_PERIOD,
      sum(decode(mtyp.milcs_code,'EMAIL_RESOLVED',1))      EMAILS_AUTO_RESOLVED_IN_PERIOD,
      0                                                    emails_composed_in_period,
	 0                                                    emails_orr_count_in_period,
	 sum(decode(mtyp.milcs_code,'EMAIL_REROUTED_DIFF_CLASS',1,
	                            'EMAIL_REROUTED_DIFF_ACCT',1,
						   'EMAIL_REQUEUED',1 )) EMAILS_REROUTED_IN_PERIOD,
      0                                                    LEADS_CREATED_IN_PERIOD
    FROM
      JTF_IH_MEDIA_ITEMS mitm,
      JTF_IH_MEDIA_ITEM_LC_SEGS mseg,
      (
         SELECT /*+ use_hash(mseg1) use_hash(mtyp1) use_hash(mseg2) use_hash(mtyp2)
                    PARALLEL(mseg1) PARALLEL(mtyp1) PARALLEL(mseg2) PARALLEL(mtyp2) */
           mseg1.media_id             media_id,
           MAX(mseg2.start_date_time) start_date_time
         FROM
           jtf_ih_media_item_lc_segs mseg1,
           jtf_ih_media_itm_lc_seg_tys mtyp1,
           jtf_ih_media_item_lc_segs mseg2,
           jtf_ih_media_itm_lc_seg_tys mtyp2
         WHERE mseg1.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
         AND   mseg1.milcs_type_id = mtyp1.milcs_type_id
         AND   mtyp1.milcs_code    = 'EMAIL_REPLY'
         AND   mseg1.media_id      = mseg2.media_id
         AND   mseg2.milcs_type_id = mtyp2.milcs_type_id
         AND   mtyp2.milcs_code    IN ('EMAIL_FETCH','EMAIL_TRANSFER', 'EMAIL_ASSIGN_OPEN', 'EMAIL_AUTO_ROUTED', 'EMAIL_ASSIGNED')
         GROUP BY mseg1.media_id
      ) inv2,
      (
         SELECT /*+ use_hash(actv) use_hash(intr) PARALLEL(actv) PARALLEL(intr) */
           actv.media_id        media_id,
           min(intr.party_id)   party_id
         FROM
           jtf_ih_activities actv,
           jtf_ih_interactions intr
         WHERE actv.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
         AND   actv.interaction_id = intr.interaction_id
         GROUP BY actv.media_id
      ) inv1,
      JTF_IH_MEDIA_ITM_LC_SEG_TYS mtyp,
    --
    --Changes for R12
    --
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) irc
    WHERE mitm.media_item_type = 'EMAIL'
    AND   mitm.direction = 'INBOUND'
    AND   mitm.classification  = irc.name(+)
    AND   mitm.media_id        = inv2.media_id(+)
    AND   mitm.media_id        = inv1.media_id(+)
    AND   mitm.MEDIA_ID        = mseg.MEDIA_ID
    AND   mseg.MILCS_TYPE_ID   = mtyp.MILCS_TYPE_ID
    AND   mseg.START_DATE_TIME BETWEEN  g_collect_start_date and g_collect_end_date
    GROUP BY
      nvl(mitm.source_id, -1),
      nvl(irc.route_classification_id, -1),
      mseg.resource_id,
      nvl(inv1.party_id, -1),
      trunc(mseg.start_date_time),
      to_number(to_char(mseg.start_date_time, 'J'))
      --1/2hr
      --nvl(lpad(to_char(mseg.start_date_time,'HH24:'),3,'0') ||
      --  decode(sign(to_number(to_char(mseg.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'00:00')
    UNION ALL --This sql counts the number of emails offered in the given period grouped together by day
    SELECT /*+ use_hash(mitm) use_hash(inv1) use_hash(irc) PARALLEL(mitm) PARALLEL(inv1) PARALLEL(irc) */
      nvl(mitm.source_id, -1)                              EMAIL_ACCOUNT_ID,
      nvl(irc.route_classification_id, -1)                 EMAIL_CLASSIFICATION_ID,
      -1                                                   AGENT_ID,
      nvl(inv1.party_id, -1)                               PARTY_ID,
      trunc(mitm.start_date_time)                          PERIOD_START_DATE,
      to_number(to_char(mitm.start_date_time, 'J'))        TIME_ID,
      --1/2hr
      --nvl(lpad(to_char(mitm.start_date_time,'HH24:'),3,'0') ||
      --  decode(sign(to_number(to_char(mitm.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'00:00')
      '00:00'
                                                           PERIOD_START_TIME,
      -1                                                   OUTCOME_ID,
      -1                                                   RESULT_ID,
      -1                                                   REASON_ID,
      COUNT(*)                                             EMAILS_OFFERED_IN_PERIOD,
      0                                                    EMAILS_FETCHED_IN_PERIOD,
      0                                                    EMAILS_REPLIED_IN_PERIOD,
      0                                                    AGENT_RESP_TIME_IN_PERIOD,
      0                                                    EMAILS_RPLD_BY_GOAL_IN_PERIOD,
      0							   AGENT_EMAILS_RPLD_BY_GOAL,
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
      0                                                    EMAILS_REROUTED_IN_PERIOD,
      0                                                    LEADS_CREATED_IN_PERIOD
    FROM
      JTF_IH_MEDIA_ITEMS mitm,
      (
         SELECT /*+ use_hash(actv) use_hash(intr) PARALLEL(actv) PARALLEL(intr) */
           actv.media_id        media_id,
           min(intr.party_id)   party_id
         FROM
           jtf_ih_activities actv,
           jtf_ih_interactions intr
         WHERE actv.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
         AND   actv.interaction_id = intr.interaction_id
         GROUP BY actv.media_id
      ) inv1,
    --
    --Changes for R12
    --
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) irc
    WHERE mitm.MEDIA_ITEM_TYPE = 'EMAIL'
    AND   mitm.DIRECTION       = 'INBOUND'
    AND   mitm.classification  = irc.name(+)
    AND   mitm.media_id        = inv1.media_id(+)
    AND   mitm.START_DATE_TIME BETWEEN  g_collect_start_date and g_collect_end_date
    GROUP BY
      nvl(mitm.source_id, -1),
      nvl(irc.route_classification_id, -1),
      nvl(inv1.party_id, -1),
      trunc(mitm.start_date_time),
      to_number(to_char(mitm.start_date_time, 'J'))
      --1/2hr
      --nvl(lpad(to_char(mitm.start_date_time,'HH24:'),3,'0') ||
      --  decode(sign(to_number(to_char(mitm.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'00:00')
    UNION ALL -- This sql segment counts the number of emails/SR created
    SELECT /*+ use_hash(actv) use_hash(intr) use_hash(mitm) use_hash(irc)
			PARALLEL(actv) PARALLEL(intr) PARALLEL(mitm) PARALLEL(irc) */
      nvl(mitm.source_id, -1)                              EMAIL_ACCOUNT_ID,
      nvl(irc.route_classification_id, -1)                 EMAIL_CLASSIFICATION_ID,
      nvl(intr.resource_id, -1)                            AGENT_ID,
      nvl(intr.party_id, -1)                               PARTY_ID,
      trunc(actv.start_date_time)                          PERIOD_START_DATE,
      to_number(to_char(actv.start_date_time, 'J'))        TIME_ID,
      --1/2hr
      --nvl(lpad(to_char(actv.start_date_time,'HH24:'),3,'0') ||
      --  decode(sign(to_number(to_char(actv.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'00:00')
      '00:00'
                                                           PERIOD_START_TIME,
      -1                                                   OUTCOME_ID,
      -1                                                   RESULT_ID,
      -1                                                   REASON_ID,
      0                                                    EMAILS_OFFERED_IN_PERIOD,
      0                                                    EMAILS_FETCHED_IN_PERIOD,
      0                                                    EMAILS_REPLIED_IN_PERIOD,
      0                                                    AGENT_RESP_TIME_IN_PERIOD,
      0                                                    EMAILS_RPLD_BY_GOAL_IN_PERIOD,
      0							   AGENT_EMAILS_RPLD_BY_GOAL,
      0                                                    EMAILS_TRNSFRD_OUT_IN_PERIOD,
      0                                                    EMAILS_TRNSFRD_IN_IN_PERIOD,
      0                                                    EMAILS_ASSIGNED_IN_PERIOD,
      0                                                    EMAILS_AUTO_ROUTED_IN_PERIOD,
      0                                                    EMAILS_AUTO_UPTD_SR_IN_PERIOD,
      0                                                    EMAILS_DELETED_IN_PERIOD,
      0                                                    EMAIL_RESP_TIME_IN_PERIOD,
      SUM(DECODE(actv.action_id,13,1))                     SR_CREATED_IN_PERIOD,
      0                                                    EMAILS_RSL_AND_TRFD_IN_PERIOD,
	 0                                                    EMAILS_AUTO_REPLIED_IN_PERIOD,
	 0                                                    EMAILS_AUTO_DELETED_IN_PERIOD,
	 0                                                    EMAILS_AUTO_RESOLVED_IN_PERIOD,
      0                                                    emails_composed_in_period,
	 0                                                    emails_orr_count_in_period,
      0                                                    EMAILS_REROUTED_IN_PERIOD,
      SUM(DECODE(actv.action_id,71,1))                       LEADS_CREATED_IN_PERIOD
    FROM
      JTF_IH_ACTIVITIES actv,
      JTF_IH_INTERACTIONS intr,
      JTF_IH_MEDIA_ITEMS mitm,
	 (select
	    actv.interaction_id interaction_id,
	    max(mitm.classification) classification
       from
	    jtf_ih_activities actv,
	    jtf_ih_activities actv1,
	    jtf_ih_media_items mitm
       where actv.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
	  and   actv.interaction_id = actv1.interaction_id
	  and   actv1.media_id = mitm.media_id
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
    WHERE actv.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
    AND ( ( actv.action_id = 13 AND  actv.action_item_id = 17  ) OR
          ( actv.action_id = 71  AND  actv.action_item_id = 8 )
        )
    AND   actv.media_id = mitm.media_id
    AND   mitm.MEDIA_ITEM_TYPE = 'EMAIL'
    AND   inv2.classification  = irc.name(+)
    AND   actv.interaction_id = intr.interaction_id
    AND   actv.interaction_id = inv2.interaction_id(+)
    GROUP BY
      nvl(mitm.source_id, -1),
      nvl(irc.route_classification_id, -1),
      intr.resource_id,
      nvl(intr.party_id, -1),
      trunc(actv.start_date_time),
      to_number(to_char(actv.start_date_time, 'J'))
      --1/2hr
      --nvl(lpad(to_char(actv.start_date_time,'HH24:'),3,'0') ||
      --  decode(sign(to_number(to_char(actv.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'00:00')
    UNION ALL -- This sql counts the number of emails resolved and transferred within the period grouped together by a day
    SELECT /*+ use_hash(inv2) use_hash(mitm) use_hash(mseg) use_hash(mtyp) use_hash(irc)
			PARALLEL(inv2) PARALLEL(mitm) PARALLEL(mseg) PARALLEL(mtyp) PARALLEL(irc) */
      nvl(mitm.source_id, -1)                              EMAIL_ACCOUNT_ID,
      nvl(irc.route_classification_id, -1)                 EMAIL_CLASSIFICATION_ID,
      nvl(mseg.resource_id, -1)                            AGENT_ID,
      nvl(inv2.party_id, -1)                                PARTY_ID,
      trunc(mseg.start_date_time)                          PERIOD_START_DATE,
      to_number(to_char(mseg.start_date_time, 'J'))        TIME_ID,
      --1/2hr
      --nvl(lpad(to_char(mseg.start_date_time,'HH24:'),3,'0') ||
      --  decode(sign(to_number(to_char(mseg.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'00:00')
      '00:00'
                                                           PERIOD_START_TIME,
      -1                                                   OUTCOME_ID,
      -1                                                   RESULT_ID,
      -1                                                   REASON_ID,
      0                                                    EMAILS_OFFERED_IN_PERIOD,
      0                                                    EMAILS_FETCHED_IN_PERIOD,
      0                                                    EMAILS_REPLIED_IN_PERIOD,
      0                                                    AGENT_RESP_TIME_IN_PERIOD,
      0                                                    EMAILS_RPLD_BY_GOAL_IN_PERIOD,
      0							   AGENT_EMAILS_RPLD_BY_GOAL,
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
      0                                                    EMAILS_REROUTED_IN_PERIOD,
      0                                                    LEADS_CREATED_IN_PERIOD
    FROM
      (
         SELECT /*+ use_hash(actv) use_hash(intr) PARALLEL(actv) PARALLEL(intr) */
           actv.media_id        media_id,
           min(intr.party_id)   party_id
         FROM
           jtf_ih_activities actv,
           jtf_ih_interactions intr
         WHERE actv.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
         AND   actv.interaction_id = intr.interaction_id
         GROUP BY actv.media_id
      ) inv2,
      JTF_IH_MEDIA_ITEMS mitm,
      JTF_IH_MEDIA_ITEM_LC_SEGS mseg,
      JTF_IH_MEDIA_ITM_LC_SEG_TYS mtyp,
    --
    --Changes for R12
    --
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) irc
    WHERE mitm.MEDIA_ITEM_TYPE = 'EMAIL'
    AND   mitm.DIRECTION       = 'INBOUND'
    AND   mitm.classification  = irc.name(+)
    AND   mitm.media_id        = inv2.media_id(+)
    AND   mitm.MEDIA_ID        = mseg.MEDIA_ID
    AND   mseg.MILCS_TYPE_ID   = mtyp.MILCS_TYPE_ID
    AND   mtyp.MILCS_CODE      IN ('EMAIL_REPLY', 'EMAIL_DELETED')
    AND   mseg.START_DATE_TIME BETWEEN  g_collect_start_date and g_collect_end_date
    AND   EXISTS (
            SELECT /*+ use_hash(mseg1) use_hash(mtys1) PARALLEL(mseg1) PARALLEL(mtys1) */
                   1
            FROM
                   jtf_ih_media_item_lc_segs mseg1,
                   jtf_ih_media_itm_lc_seg_tys mtys1
            WHERE mseg1.media_id = mitm.media_id
            AND   mtys1.milcs_type_id = mseg1.milcs_type_id
            AND   mtys1.milcs_code IN ( 'EMAIL_TRANSFERRED','EMAIL_ESCALATED') )
    GROUP BY
      nvl(mitm.source_id, -1),
      nvl(irc.route_classification_id, -1),
      nvl(mseg.resource_id, -1),
      nvl(inv2.party_id, -1),
      trunc(mseg.start_date_time),
      to_number(to_char(mseg.start_date_time, 'J'))
      --1/2hr
      --nvl(lpad(to_char(mseg.start_date_time,'HH24:'),3,'0') ||
      --  decode(sign(to_number(to_char(mseg.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'00:00')
    UNION ALL	  -- This sql segment collects inbound email outcome count
    SELECT /*+ use_hash(inv2) use_hash(mitm) use_hash(mseg) use_hash(mtyp) use_hash(irc)
			PARALLEL(inv2) PARALLEL(mitm) PARALLEL(mseg) PARALLEL(mtyp) PARALLEL(irc)
			use_hash(actv) use_hash(intr) PARALLEL(actv) PARALLEL(intr)  */
      nvl(mitm.source_id, -1)                              EMAIL_ACCOUNT_ID,
      nvl(irc.route_classification_id, -1)                 EMAIL_CLASSIFICATION_ID,
      nvl(intr.resource_id, -1)                             AGENT_ID,
      nvl(intr.party_id, -1)                                PARTY_ID,
      trunc(intr.last_update_date)                          PERIOD_START_DATE,
      to_number(to_char(intr.last_update_date, 'J'))        TIME_ID,
      --1/2hr
      --nvl(lpad(to_char(intr.last_update_date,'HH24:'),3,'0') ||
      --  decode(sign(to_number(to_char(intr.last_update_date,'MI'))-29),0,'00',1,'30',-1,'00'),'00:00')
      --Replacing with 00:00 since we are going to ignore 1/2 hr segments
	  '00:00'                                                     PERIOD_START_TIME,
      NVL(intr.outcome_id,-1)                              OUTCOME_ID,
      NVL(intr.result_id,-1)                               RESULT_ID,
      NVL(intr.reason_id,-1)                               REASON_ID,
      0                                                    EMAILS_OFFERED_IN_PERIOD,
      0                                                    EMAILS_FETCHED_IN_PERIOD,
      0                                                    EMAILS_REPLIED_IN_PERIOD,
      0                                                    AGENT_RESP_TIME_IN_PERIOD,
      0                                                    EMAILS_RPLD_BY_GOAL_IN_PERIOD,
      0							   AGENT_EMAILS_RPLD_BY_GOAL,
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
	 COUNT(DISTINCT intr.interaction_id)                  emails_orr_count_in_period,
      0                                                    EMAILS_REROUTED_IN_PERIOD,
      0                                                    LEADS_CREATED_IN_PERIOD
    FROM
      JTF_IH_MEDIA_ITEMS mitm,
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
    AND   mitm.direction = 'INBOUND'
    AND   mitm.classification  = irc.name(+)
    AND   mitm.media_id        = actv.media_id
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
      --1/2hr
      --nvl(lpad(to_char(intr.last_update_date,'HH24:'),3,'0') ||
      --decode(sign(to_number(to_char(intr.last_update_date,'MI'))-29),0,'00',1,'30',-1,'00'),'00:00'),
      NVL(intr.outcome_id,-1),
      NVL(intr.result_id,-1),
      NVL(intr.reason_id,-1)
    UNION ALL	   -- This sql segment collects outbound email outcome count
    SELECT /*+ use_hash(inv2) use_hash(mitm) use_hash(mseg) use_hash(mtyp) use_hash(irc)
			PARALLEL(inv2) PARALLEL(mitm) PARALLEL(mseg) PARALLEL(mtyp) PARALLEL(irc)
			use_hash(actv) use_hash(intr) PARALLEL(actv) PARALLEL(intr)  */
      nvl(mitm.source_id, -1)                              EMAIL_ACCOUNT_ID,
      nvl(irc.route_classification_id, -1)                 EMAIL_CLASSIFICATION_ID,
      nvl(intr.resource_id, -1)                             AGENT_ID,
      nvl(intr.party_id, -1)                                PARTY_ID,
      trunc(intr.last_update_date)                          PERIOD_START_DATE,
      to_number(to_char(intr.last_update_date, 'J'))        TIME_ID,
      --1/2hr
      --nvl(lpad(to_char(intr.last_update_date,'HH24:'),3,'0') ||
      --  decode(sign(to_number(to_char(intr.last_update_date,'MI'))-29),0,'00',1,'30',-1,'00'),'00:00')
      '00:00'                                                     PERIOD_START_TIME,
      NVL(intr.outcome_id,-1)                              OUTCOME_ID,
      NVL(intr.result_id,-1)                               RESULT_ID,
      NVL(intr.reason_id,-1)                               REASON_ID,
      0                                                    EMAILS_OFFERED_IN_PERIOD,
      0                                                    EMAILS_FETCHED_IN_PERIOD,
      0                                                    EMAILS_REPLIED_IN_PERIOD,
      0                                                    AGENT_RESP_TIME_IN_PERIOD,
      0                                                    EMAILS_RPLD_BY_GOAL_IN_PERIOD,
      0							   AGENT_EMAILS_RPLD_BY_GOAL,
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
    AND   mitm.media_id        = actv.media_id
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
      --1/2hr
      --nvl(lpad(to_char(intr.last_update_date,'HH24:'),3,'0') ||
      --decode(sign(to_number(to_char(intr.last_update_date,'MI'))-29),0,'00',1,'30',-1,'00'),'00:00'),
      NVL(intr.outcome_id,-1),
      NVL(intr.result_id,-1),
      NVL(intr.reason_id,-1)
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
	 inv2.reason_id);

  COMMIT;

  write_log('Number of rows inserted in table bix_email_details_f : ' || to_char(SQL%ROWCOUNT));

  g_rows_ins_upd := g_rows_ins_upd + SQL%ROWCOUNT;

  /* Estimating statistics as we are going to update these rows for the open measures */
  DBMS_STATS.gather_table_stats(ownname => g_bix_schema,
                                tabName => 'BIX_EMAIL_DETAILS_F',
                                cascade => TRUE,
                                degree => bis_common_parameters.get_degree_of_parallelism,
                                estimate_percent => 10,
                                granularity => 'GLOBAL');

  write_log('Finished procedure collect_emails at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure collect_emails : Error : ' || sqlerrm);
    RAISE;
END collect_emails;

PROCEDURE update_queue_measure (p_email_account_id IN OUT NOCOPY g_email_account_id_tab,
                                p_email_classification_id IN OUT NOCOPY g_email_classification_id_tab,
                                p_party_id IN OUT NOCOPY g_party_id_tab,
                                p_period_start_date IN OUT NOCOPY g_period_start_date_tab,
                                p_emails_in_queue IN OUT NOCOPY g_emails_in_queue_tab,
                                p_total_queue_time IN OUT NOCOPY g_total_queue_time_tab,
                                p_oldest_message_in_queue IN OUT NOCOPY g_oldest_message_in_queue_tab,
                                p_acc_emails_one_day IN OUT NOCOPY g_acc_emails_one_day_tab,
                                p_acc_emails_three_days IN OUT NOCOPY g_acc_emails_three_days_tab,
                                p_acc_emails_week IN OUT NOCOPY g_acc_emails_week_tab,
                                p_acc_emails_week_plus IN OUT NOCOPY g_acc_emails_week_plus_tab) IS
BEGIN

  write_log('Start of the procedure update_queue_measure at ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));

  /* Update ICI summary table for the queue measures */
  FORALL i in p_email_account_id.FIRST .. p_email_account_id.LAST
  MERGE INTO bix_email_details_f bed
  USING (
    SELECT
      p_email_account_id(i) email_account_id,
      p_email_classification_id(i) email_classification_id,
      -1 agent_id,
      p_party_id(i) party_id,
      to_number(to_char(p_period_start_date(i), 'J')) time_id,
      --1/2hr change the period type id to 1 from -1
      1 period_type_id,
      trunc(p_period_start_date(i)) period_start_date,
      LPAD(TO_CHAR(p_period_start_date(i),'HH24:MI'), 5, '0') period_start_time,
      nvl(p_emails_in_queue(i),0) accumulated_emails_in_queue,
      nvl(p_total_queue_time(i),0) accumulated_queue_time,
      p_oldest_message_in_queue(i) oldest_email_queue_date,
      nvl(p_acc_emails_one_day(i),0) accumulated_emails_one_day,
      nvl(p_acc_emails_three_days(i),0) accumulated_emails_three_days,
      nvl(p_acc_emails_week(i),0) accumulated_emails_week,
      nvl(p_acc_emails_week_plus(i),0) accumulated_emails_week_plus
    FROM dual) change
  ON (bed.email_account_id = change.email_account_id
    AND bed.email_classification_id = change.email_classification_id
    AND bed.agent_id = change.agent_id
    AND bed.party_id = change.party_id
    AND bed.time_id = change.time_id
    AND bed.period_type_id = change.period_type_id
    AND bed.period_start_date = change.period_start_date
    AND bed.period_start_time = change.period_start_time
    AND bed.outcome_id = -1 AND bed.result_id = -1 AND bed.reason_id = -1 )
  WHEN MATCHED THEN
    UPDATE
    SET
      bed.accumulated_emails_in_queue = decode(change.accumulated_emails_in_queue, 0, bed.accumulated_emails_in_queue,
                           NVL(bed.accumulated_emails_in_queue, 0) + change.accumulated_emails_in_queue),
      bed.accumulated_queue_time = decode(change.accumulated_queue_time, 0, bed.accumulated_queue_time,
                           NVL(bed.accumulated_queue_time, 0) + change.accumulated_queue_time),
      bed.accumulated_emails_one_day = decode(change.accumulated_emails_one_day, 0, bed.accumulated_emails_one_day,
                           NVL(bed.accumulated_emails_one_day, 0) + change.accumulated_emails_one_day),
      bed.accumulated_emails_three_days = decode(change.accumulated_emails_three_days, 0, bed.accumulated_emails_three_days,
                           NVL(bed.accumulated_emails_three_days, 0) + change.accumulated_emails_three_days),
      bed.accumulated_emails_week = decode(change.accumulated_emails_week, 0, bed.accumulated_emails_week,
                           NVL(bed.accumulated_emails_week, 0) + change.accumulated_emails_week),
      bed.accumulated_emails_week_plus = decode(change.accumulated_emails_week_plus, 0, bed.accumulated_emails_week_plus,
                           NVL(bed.accumulated_emails_week_plus, 0) + change.accumulated_emails_week_plus),
      bed.oldest_email_queue_date =
             DECODE(change.oldest_email_queue_date,NULL,bed.oldest_email_queue_date,
               DECODE(bed.oldest_email_queue_date,NULL,change.oldest_email_queue_date,
                 DECODE(SIGN(bed.oldest_email_queue_date - change.oldest_email_queue_date),
                    -1,bed.oldest_email_queue_date, change.oldest_email_queue_date))),
        bed.last_update_date =  g_sysdate,
        bed.last_updated_by = g_user_id
  WHEN NOT MATCHED THEN INSERT (
        bed.email_account_id,
        bed.email_classification_id,
        bed.agent_id,
        bed.party_id,
	   bed.outcome_id,
	   bed.result_id,
	   bed.reason_id,
        bed.time_id,
        bed.period_type_id,
        bed.period_start_date,
        bed.period_start_time,
        bed.created_by,
        bed.creation_date,
        bed.last_updated_by,
        bed.last_update_date,
        bed.accumulated_emails_in_queue,
        bed.accumulated_queue_time,
        bed.oldest_email_queue_date,
        bed.accumulated_emails_one_day,
        bed.accumulated_emails_three_days,
        bed.accumulated_emails_week,
        bed.accumulated_emails_week_plus,
        bed.request_id,
        bed.program_application_id,
        bed.program_id,
        bed.program_update_date)
      VALUES (
        change.email_account_id,
        change.email_classification_id,
        change.agent_id,
        change.party_id,
	   -1,
	   -1,
	   -1,
        change.time_id,
        change.period_type_id,
        change.period_start_date,
        change.period_start_time,
        g_user_id,
        g_sysdate,
        g_user_id,
        g_sysdate,
        decode(change.accumulated_emails_in_queue, 0, to_number(null), change.accumulated_emails_in_queue),
        decode(change.accumulated_queue_time, 0, to_number(null), change.accumulated_queue_time),
        change.oldest_email_queue_date,
        decode(change.accumulated_emails_one_day, 0, to_number(null), change.accumulated_emails_one_day),
        decode(change.accumulated_emails_three_days, 0, to_number(null), change.accumulated_emails_three_days),
        decode(change.accumulated_emails_week, 0, to_number(null), change.accumulated_emails_week),
        decode(change.accumulated_emails_week_plus, 0, to_number(null), change.accumulated_emails_week_plus),
        g_request_id,
        g_program_appl_id,
        g_program_id,
        g_sysdate);

  COMMIT;

  g_rows_ins_upd := g_rows_ins_upd + p_email_account_id.COUNT;

  write_log('Finished procedure update_queue_measure at ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in update_queue_measure : Error : ' || sqlerrm);
    RAISE;
END update_queue_measure;

/***
This splits the data to mutliple time buckets.  Then it calls update_queue_measures
which does the actual MERGE of the data
***/

PROCEDURE process_queue_measure_row(p_media_id IN OUT NOCOPY g_media_id_tab,
                                    p_email_account_id IN OUT NOCOPY g_email_account_id_tab,
                                    p_email_classification_id IN OUT NOCOPY g_email_classification_id_tab,
                                    p_party_id IN OUT NOCOPY g_party_id_tab,
                                    p_start_date_time IN OUT NOCOPY g_start_date_time_tab,
                                    p_end_date_time IN OUT NOCOPY g_end_date_time_tab,
                                    p_media_start_date_time IN OUT NOCOPY g_media_start_date_time_tab,
                                    p_period_start_date_time IN OUT NOCOPY g_start_date_time_tab,
                                    p_period_end_date_time IN OUT NOCOPY g_end_date_time_tab)
IS

  l_email_account_id g_email_account_id_tab;
  l_email_classification_id g_email_classification_id_tab;
  l_party_id g_party_id_tab;
  l_period_start_date g_period_start_date_tab;
  l_emails_in_queue g_emails_in_queue_tab;
  l_total_queue_time g_total_queue_time_tab;
  l_oldest_message_in_queue g_oldest_message_in_queue_tab;
  l_acc_emails_one_day g_acc_emails_one_day_tab;
  l_acc_emails_three_days g_acc_emails_three_days_tab;
  l_acc_emails_week g_acc_emails_week_tab;
  l_acc_emails_week_plus g_acc_emails_week_plus_tab;

  l_temp_date DATE;
  l_begin_bucket_date DATE;
  l_end_bucket_date DATE;
  j NUMBER;
  l_party_id_temp NUMBER;
  l_diff_time NUMBER;

BEGIN

  write_log('Start of the procedure process_queue_measure_row at ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));

  /* Initialize the variables */
  j := 0;
  l_email_account_id :=  g_email_account_id_tab();
  l_email_classification_id := g_email_classification_id_tab();
  l_party_id := g_party_id_tab();
  l_period_start_date := g_period_start_date_tab();
  l_emails_in_queue := g_emails_in_queue_tab();
  l_total_queue_time := g_total_queue_time_tab();
  l_oldest_message_in_queue := g_oldest_message_in_queue_tab();
  l_acc_emails_one_day := g_acc_emails_one_day_tab();
  l_acc_emails_three_days := g_acc_emails_three_days_tab();
  l_acc_emails_week := g_acc_emails_week_tab();
  l_acc_emails_week_plus := g_acc_emails_week_plus_tab();

  /* Loop through all the media returned by the cursor */
  FOR i IN p_media_id.FIRST .. p_media_id.LAST
  LOOP

    l_begin_bucket_date := NULL;
    l_end_bucket_date   := NULL;
    l_temp_date         := NULL;

    /* Get the start and the end bucket of time where the queue measures will be sliced into     */
    /* if segment start date < collection start date , then start bucket = collection start date */
    /* else start bucket = time bucket of segment start date time                                */
    l_begin_bucket_date := p_period_start_date_time(i);

    --1/2hr changed the addition to 1 from 1/48
    l_temp_date := l_begin_bucket_date + 1;

    /* if segment end date > collection end date , then end bucket = collection end date */
    /* else end bucket = time bucket of segment end date time                            */
    l_end_bucket_date := p_period_end_date_time(i);

    /* loop through the time range and slice the queue measures into appropiate 1/2 hr bucket */
    WHILE(l_begin_bucket_date <=  l_end_bucket_date)  LOOP

      j := j + 1;

      l_email_account_id.extend(1);
      l_email_classification_id.extend(1);
      l_party_id.extend(1);
      l_period_start_date.extend(1);
      l_emails_in_queue.extend(1);
      l_total_queue_time.extend(1);
      l_oldest_message_in_queue.extend(1);
      l_acc_emails_one_day.extend(1);
      l_acc_emails_three_days.extend(1);
      l_acc_emails_week.extend(1);
      l_acc_emails_week_plus.extend(1);

      l_email_account_id(j) := p_email_account_id(i);
      l_email_classification_id(j) := p_email_classification_id(i);
      l_party_id(j) := p_party_id(i);
      l_period_start_date(j) := l_begin_bucket_date;
      l_emails_in_queue(j) := 0;
      l_total_queue_time(j) := 0;
      l_oldest_message_in_queue(j) := NULL;
      l_acc_emails_one_day(j) := 0;
      l_acc_emails_three_days(j) := 0;
      l_acc_emails_week(j) := 0;
      l_acc_emails_week_plus(j) := 0;

      IF(p_end_date_time(i) BETWEEN l_begin_bucket_date AND l_temp_date
                 AND p_end_date_time(i) <> g_collect_end_date ) THEN
        /* control reaching here means that the email has been removed from the queue in this time bucket */
        l_total_queue_time(j) := round((p_end_date_time(i) - p_start_date_time(i) ) * 24 * 60 * 60);
      ELSE
        /* control reaching here means that the email remains in queue at the end of time bucket */
        l_total_queue_time(j) := round((l_temp_date - p_start_date_time(i)) * 24 * 60 * 60);
        l_emails_in_queue(j) := 1;
        l_oldest_message_in_queue(j) := p_start_date_time(i);

        /* Determine if the email is in the queue for 1 day , 3 days, a week or more than that */
        l_diff_time := l_temp_date - p_media_start_date_time(i);

        IF (l_diff_time <= 1) THEN
          l_acc_emails_one_day(j) := 1;
        ELSIF (l_diff_time <= 3) THEN
          l_acc_emails_three_days(j) := 1;
        ELSIF (l_diff_time <= 7) THEN
          l_acc_emails_week(j) := 1;
        ELSE
          l_acc_emails_week_plus(j) := 1;
        END IF;
      END IF;
      --1/2hr changed from 1/48 to 1
      l_begin_bucket_date := l_begin_bucket_date + 1;
      --1/2hr changed from 1/48 to 1
      l_temp_date := l_temp_date + 1;

      IF (j >= g_commit_chunk_size) THEN
        update_queue_measure (l_email_account_id,
                              l_email_classification_id,
                              l_party_id,
                              l_period_start_date,
                              l_emails_in_queue,
                              l_total_queue_time,
                              l_oldest_message_in_queue,
                              l_acc_emails_one_day,
                              l_acc_emails_three_days,
                              l_acc_emails_week,
                              l_acc_emails_week_plus);

        l_email_account_id.TRIM(j);
        l_email_classification_id.TRIM(j);
        l_party_id.TRIM(j);
        l_period_start_date.TRIM(j);
        l_emails_in_queue.TRIM(j);
        l_total_queue_time.TRIM(j);
        l_oldest_message_in_queue.TRIM(j);
        l_acc_emails_one_day.TRIM(j);
        l_acc_emails_three_days.TRIM(j);
        l_acc_emails_week.TRIM(j);
        l_acc_emails_week_plus.TRIM(j);

        j := 0;
      END IF;

    END LOOP;-- End of inner While loop

  END LOOP;

  IF (l_email_account_id.COUNT >= 1) THEN
    update_queue_measure (l_email_account_id,
                          l_email_classification_id,
                          l_party_id,
                          l_period_start_date,
                          l_emails_in_queue,
                          l_total_queue_time,
                          l_oldest_message_in_queue,
                          l_acc_emails_one_day,
                          l_acc_emails_three_days,
                          l_acc_emails_week,
                          l_acc_emails_week_plus);

    l_email_account_id.TRIM(j);
    l_email_classification_id.TRIM(j);
    l_party_id.TRIM(j);
    l_period_start_date.TRIM(j);
    l_emails_in_queue.TRIM(j);
    l_total_queue_time.TRIM(j);
    l_oldest_message_in_queue.TRIM(j);
    l_acc_emails_one_day.TRIM(j);
    l_acc_emails_three_days.TRIM(j);
    l_acc_emails_week.TRIM(j);
    l_acc_emails_week_plus.TRIM(j);

  END IF;

  write_log('Finished procedure process_queue_measure_row at ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in process_queue_measure_row : Error : ' || sqlerrm);
    RAISE;
END process_queue_measure_row;

/*====================================================================+

This procedure collects Queue measures.  The queue cursor has two parts with union.
The first part collects all the emails which are still in queue now.
The second part of SQL collects all the emails which was in queue for some time and
now they are no longer in queue .

Each eamil can be in queue for several days.  Each email translates to multiple rows
in summary table.  for example if one emaiil is in queue for 2 days then two rows will
be inserted one for each day with accumulated_emails_in_queue as 1 for both days.

If there is no emails in queue for particular combination dimensions
this procedure populates null.

====================================================================+*/



PROCEDURE collect_queue_measures AS

  CURSOR queue_measures IS
--
--This is the query for collecting emails which are still in system queue
--PERIOD START DATE will be either global start date or the start of the media segment
--PERIOD END DATE will be the g_collect_end_date since the emails are still in
--QUEUE.
--
  SELECT /*+ use_hash(mitm) use_hash(mseg) use_hash(mtys) use_hash(cls) use_hash(inv2) */
    mitm.media_id                        MEDIA_ID,
    nvl(mitm.source_id, -1)              EMAIL_ACCOUNT_ID,
    nvl(cls.route_classification_id, -1) EMAIL_CLASSIFICATION_ID,
    nvl(inv2.party_id, -1)                PARTY_ID,
    mseg.start_date_time                 START_DATE_TIME,
    g_collect_end_date                   END_DATE_TIME,
    mitm.start_date_time                 MEDIA_START_DATE_TIME,
    --1/2hr
    decode(sign(mseg.start_date_time - g_collect_start_date), -1, g_collect_start_date,
             to_date(to_char(mseg.start_date_time ,'YYYY/MM/DD ')|| '00:'
               || '00',
                 'YYYY/MM/DD HH24:MI')) PERIOD_START_DATE_TIME,
    --1/2hr do we need to modify the collect end data to capture data upto the second?
    g_collect_end_date -- - (( 29 * 60 + 59 )/(24*60*60))
                                        PERIOD_END_DATE_TIME
  FROM
    JTF_IH_MEDIA_ITEMS          mitm,
    JTF_IH_MEDIA_ITEM_LC_SEGS   mseg,
    JTF_IH_MEDIA_ITM_LC_SEG_TYS mtys,
    --
    --Changes for R12
    --
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) cls,
    (
        --????Changed for party_id
         --SELECT /*+ use_hash(actv) use_hash(intr) */
           --actv.media_id        media_id,
           --min(intr.party_id)   party_id
         --FROM
           --jtf_ih_activities actv,
           --jtf_ih_interactions intr
         --WHERE actv.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
         --AND   actv.interaction_id = intr.interaction_id
         --GROUP BY actv.media_id
         SELECT /*+ use_hash(actv) use_hash(intr) */
           distinct actv.media_id        media_id,
           first_value(intr.party_id)
           over(partition by actv.media_id order by actv.interaction_id desc) party_id
         FROM
           jtf_ih_activities actv,
           jtf_ih_interactions intr
         WHERE actv.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
         AND   actv.interaction_id = intr.interaction_id
    ) inv2
  WHERE mitm.MEDIA_ITEM_TYPE = 'EMAIL'
  AND   mitm.DIRECTION       = 'INBOUND'
  AND   mitm.classification  = cls.name(+)
  AND   mitm.MEDIA_ID        = mseg.MEDIA_ID
  AND   mseg.START_DATE_TIME < g_collect_end_date
  AND   mseg.MILCS_TYPE_ID   = mtys.MILCS_TYPE_ID
  AND   mtys.MILCS_CODE IN ('EMAIL_PROCESSING') /* Requeued segment removed for bug 5337716 */
  AND   mitm.media_id        = inv2.media_id
  AND   NOT EXISTS
   (
    SELECT /*+ use_hash(mseg1) use_hash(mtys1) */
         1
    FROM JTF_IH_MEDIA_ITEM_LC_SEGS   mseg1,
         JTF_IH_MEDIA_ITM_LC_SEG_TYS mtys1
    WHERE  mseg.MEDIA_ID       = mseg1.MEDIA_ID
    AND    mseg1.MILCS_TYPE_ID = mtys1.MILCS_TYPE_ID
    AND    mtys1.MILCS_CODE  IN
             ('EMAIL_FETCH', 'EMAIL_RESOLVED', 'EMAIL_AUTO_REDIRECTED', 'EMAIL_AUTO_DELETED',
              'EMAIL_AUTO_REPLY', 'EMAIL_OPEN', 'EMAIL_AUTO_ROUTED', 'EMAIL_AUTO_UPDATED_SR',
              'EMAIL_ASSIGNED', 'EMAIL_ASSIGN_OPEN','EMAIL_DELETED')
--
--This condition is required since the email might have been fetched once but
--then re-queued.  In this case the email is still in QUEUE and wihout the following
--condition will miss the record
--
    AND    mseg1.START_DATE_TIME >= mseg.START_DATE_TIME
    AND    mseg1.START_DATE_TIME < g_collect_end_date
   )
  UNION
--
--This query is for emails which were in QUEUE for some time but are no longer in QUEUE
--
  SELECT /*+ use_hash(mitm2) use_hash(inv2) use_hash(inv1) use_hash(mseg2) use_hash(mtys2) use_hash(cls2) */
    mitm2.media_id                        MEDIA_ID,
    nvl(mitm2.source_id, -1)              EMAIL_ACCOUNT_ID,
    nvl(cls2.route_classification_id, -1) EMAIL_CLASSIFICATION_ID,
    nvl(inv1.party_id, -1)                PARTY_ID,
    mseg2.start_date_time                 START_DATE_TIME,
    min(inv2.start_date_time)              END_DATE_TIME,
    mitm2.start_date_time                 MEDIA_START_DATE_TIME,
    --1/2hr
    decode(sign(mseg2.start_date_time - g_collect_start_date), -1, g_collect_start_date,
             to_date(to_char(mseg2.start_date_time ,'YYYY/MM/DD ')|| '00:'
               || '00',
                 'YYYY/MM/DD HH24:MI'))   PERIOD_START_DATE_TIME,
    --1/2hr removed 1/2 hr lag in collect time
    decode(sign(g_collect_end_date - min(inv2.start_date_time)), -1, g_collect_end_date, -- - (( 29 * 60 + 59 )/(24*60*60))
           to_date(to_char(min(inv2.start_date_time) ,'YYYY/MM/DD ')|| '00:'
               || '00',
                 'YYYY/MM/DD HH24:MI'))   PERIOD_END_DATE_TIME
  FROM
    JTF_IH_MEDIA_ITEMS mitm2,
    (
        SELECT /*+ use_hash(mseg3) use_hash(mtys3) */
               mseg3.media_id,
               mseg3.resource_id,
               mseg3.start_date_time
        FROM   JTF_IH_MEDIA_ITEM_LC_SEGS   mseg3,
               JTF_IH_MEDIA_ITM_LC_SEG_TYS mtys3
        WHERE  mseg3.MILCS_TYPE_ID = mtys3.MILCS_TYPE_ID
        AND    mtys3.MILCS_CODE  IN
                 ('EMAIL_FETCH', 'EMAIL_RESOLVED', 'EMAIL_AUTO_REDIRECTED', 'EMAIL_AUTO_DELETED',
                  'EMAIL_AUTO_REPLY', 'EMAIL_OPEN', 'EMAIL_AUTO_ROUTED', 'EMAIL_AUTO_UPDATED_SR',
                  'EMAIL_ASSIGNED', 'EMAIL_ASSIGN_OPEN','EMAIL_DELETED')
        AND    mseg3.START_DATE_TIME BETWEEN g_collect_start_date AND g_collect_end_date
    ) inv2,
    (
        --????Change for party_id
         --SELECT /*+ use_hash(actv) use_hash(intr) */
           --actv.media_id        media_id,
           --min(intr.party_id)   party_id
         --FROM
           --jtf_ih_activities actv,
           --jtf_ih_interactions intr
         --WHERE actv.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
         --AND   actv.interaction_id = intr.interaction_id
         --GROUP BY actv.media_id
         SELECT /*+ use_hash(actv) use_hash(intr) */
           distinct actv.media_id        media_id,
           first_value(intr.party_id)
           over(partition by actv.media_id order by actv.interaction_id desc) party_id
         FROM
           jtf_ih_activities actv,
           jtf_ih_interactions intr
         WHERE actv.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
         AND   actv.interaction_id = intr.interaction_id
    ) inv1,
    JTF_IH_MEDIA_ITEM_LC_SEGS mseg2,
    JTF_IH_MEDIA_ITM_LC_SEG_TYS mtys2,
    --
    --Changes for R12
    --
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) cls2
  WHERE mitm2.MEDIA_ITEM_TYPE = 'EMAIL'
  AND   mitm2.DIRECTION       = 'INBOUND'
  AND   mitm2.classification  = cls2.name(+)
  AND   mitm2.MEDIA_ID        = inv2.MEDIA_ID
  AND   inv2.MEDIA_ID          = mseg2.MEDIA_ID
  AND   mseg2.START_DATE_TIME < g_collect_end_date
  AND   mseg2.MILCS_TYPE_ID   = mtys2.MILCS_TYPE_ID
  AND   inv2.START_DATE_TIME   >= mseg2.START_DATE_TIME
  AND   mitm2.media_id        = inv1.media_id  --???test with outer join removed here
  AND   mtys2.MILCS_CODE IN ('EMAIL_PROCESSING')/* Requeued segment removed for bug 5337716 */
  GROUP BY
    mitm2.media_id,
    nvl(mitm2.source_id, -1),
    nvl(cls2.route_classification_id, -1),
    nvl(inv1.party_id, -1),
    mseg2.start_date_time,
    mitm2.start_date_time;

  l_media_id g_media_id_tab;
  l_email_account_id g_email_account_id_tab;
  l_email_classification_id g_email_classification_id_tab;
  l_party_id g_party_id_tab;
  l_start_date_time g_start_date_time_tab;
  l_end_date_time g_end_date_time_tab;
  l_media_start_date_time g_media_start_date_time_tab;
  l_period_start_date_time g_start_date_time_tab;
  l_period_end_date_time g_end_date_time_tab;

  l_no_of_records  NUMBER;
BEGIN

  write_log('Start of the procedure collect_queue_measures at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  OPEN queue_measures;

  LOOP

    /* Bulk collect queue information from OLTP tables and process them row by row */
    FETCH queue_measures BULK COLLECT INTO
      l_media_id,
      l_email_account_id,
      l_email_classification_id,
      l_party_id,
      l_start_date_time,
      l_end_date_time,
      l_media_start_date_time,
      l_period_start_date_time,
      l_period_end_date_time
    LIMIT g_commit_chunk_size;

    l_no_of_records := l_media_id.COUNT;

    IF (l_no_of_records > 0) THEN
      process_queue_measure_row(
        l_media_id,
        l_email_account_id,
        l_email_classification_id,
        l_party_id,
        l_start_date_time,
        l_end_date_time,
        l_media_start_date_time,
        l_period_start_date_time,
        l_period_end_date_time);

      l_media_id.TRIM(l_no_of_records);
      l_email_account_id.TRIM(l_no_of_records);
      l_email_classification_id.TRIM(l_no_of_records);
      l_party_id.TRIM(l_no_of_records);
      l_start_date_time.TRIM(l_no_of_records);
      l_end_date_time.TRIM(l_no_of_records);
      l_media_start_date_time.TRIM(l_no_of_records);
      l_period_start_date_time.TRIM(l_no_of_records);
      l_period_end_date_time.TRIM(l_no_of_records);
    END IF;

    EXIT WHEN queue_measures%NOTFOUND;

  END LOOP;

  CLOSE queue_measures;

  /* Again estimating statistics here as these rows will be updated by open and resolution measures */
  DBMS_STATS.gather_table_stats(ownname => g_bix_schema,
                                tabName => 'BIX_EMAIL_DETAILS_F',
                                cascade => TRUE,
                                degree => bis_common_parameters.get_degree_of_parallelism,
                                estimate_percent => 10,
                                granularity => 'GLOBAL');

  write_log('Finished procedure collect_queue_measures at : ' ||
                                                  to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure collect_queue_measures : Error : ' || sqlerrm);
    IF (queue_measures%ISOPEN) THEN
      CLOSE queue_measures;
    END IF;
    RAISE;
END collect_queue_measures;

PROCEDURE update_open_measure (p_email_account_id IN OUT NOCOPY g_email_account_id_tab,
                               p_email_classification_id IN OUT NOCOPY g_email_classification_id_tab,
                               p_party_id IN OUT NOCOPY g_party_id_tab,
                               p_agent_id IN OUT NOCOPY g_resource_id_tab,
                               p_period_start_date IN OUT NOCOPY g_period_start_date_tab,
                               p_emails_open IN OUT NOCOPY g_emails_open_tab,
                               p_total_open_age IN OUT NOCOPY g_total_open_age_tab,
                               p_oldest_open_message IN OUT NOCOPY g_oldest_open_message_tab,
                               p_acc_emails_one_day IN OUT NOCOPY g_acc_emails_one_day_tab,
                               p_acc_emails_three_days IN OUT NOCOPY g_acc_emails_three_days_tab,
                               p_acc_emails_week IN OUT NOCOPY g_acc_emails_week_tab,
                               p_acc_emails_week_plus IN OUT NOCOPY g_acc_emails_week_plus_tab) IS
BEGIN

  write_log('Start of the procedure update_open_measure at ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));

  /* Update ICI summary table with open measure */
  FORALL i in p_email_account_id.FIRST .. p_email_account_id.LAST
  MERGE INTO bix_email_details_f bed
  USING (
    SELECT
      p_email_account_id(i) email_account_id,
      p_email_classification_id(i) email_classification_id,
      p_agent_id(i) agent_id,
      p_party_id(i) party_id,
      to_number(to_char(p_period_start_date(i), 'J')) time_id,
      --1/2hr changed period type id to 1 from -1
      1 period_type_id,
      trunc(p_period_start_date(i)) period_start_date,
      LPAD(TO_CHAR(p_period_start_date(i),'HH24:MI'), 5, '0') period_start_time,
      nvl(p_emails_open(i),0) accumulated_open_emails,
      nvl(p_total_open_age(i),0) accumulated_open_age,
      p_oldest_open_message(i) oldest_email_open_date,
      nvl(p_acc_emails_one_day(i),0) accumulated_emails_one_day,
      nvl(p_acc_emails_three_days(i),0) accumulated_emails_three_days,
      nvl(p_acc_emails_week(i),0) accumulated_emails_week,
      nvl(p_acc_emails_week_plus(i),0) accumulated_emails_week_plus
    FROM dual) change
  ON (bed.email_account_id = change.email_account_id
    AND bed.email_classification_id = change.email_classification_id
    AND bed.agent_id = change.agent_id
    AND bed.party_id = change.party_id
    AND bed.time_id = change.time_id
    AND bed.period_type_id = change.period_type_id
    AND bed.period_start_date = change.period_start_date
    AND bed.period_start_time = change.period_start_time
    AND bed.outcome_id = -1 AND bed.result_id = -1 AND bed.reason_id = -1 )
  WHEN MATCHED THEN
    UPDATE
    SET
      bed.accumulated_open_emails = decode(change.accumulated_open_emails, 0, bed.accumulated_open_emails,
                           NVL(bed.accumulated_open_emails, 0) + change.accumulated_open_emails),
      bed.accumulated_open_age = decode(change.accumulated_open_age, 0, bed.accumulated_open_age,
                           NVL(bed.accumulated_open_age, 0) + change.accumulated_open_age),
      bed.accumulated_emails_one_day = decode(change.accumulated_emails_one_day, 0, bed.accumulated_emails_one_day,
                           NVL(bed.accumulated_emails_one_day, 0) + change.accumulated_emails_one_day),
      bed.accumulated_emails_three_days = decode(change.accumulated_emails_three_days, 0, bed.accumulated_emails_three_days,
                           NVL(bed.accumulated_emails_three_days, 0) + change.accumulated_emails_three_days),
      bed.accumulated_emails_week = decode(change.accumulated_emails_week, 0, bed.accumulated_emails_week,
                           NVL(bed.accumulated_emails_week, 0) + change.accumulated_emails_week),
      bed.accumulated_emails_week_plus = decode(change.accumulated_emails_week_plus, 0, bed.accumulated_emails_week_plus,
                           NVL(bed.accumulated_emails_week_plus, 0) + change.accumulated_emails_week_plus),
      bed.oldest_email_open_date =
             DECODE(change.oldest_email_open_date,NULL,bed.oldest_email_open_date,
               DECODE(bed.oldest_email_open_date,NULL,change.oldest_email_open_date,
                 DECODE(SIGN(bed.oldest_email_open_date - change.oldest_email_open_date),
                    -1,bed.oldest_email_open_date, change.oldest_email_open_date))),
        bed.last_update_date =  g_sysdate,
        bed.last_updated_by = g_user_id
  WHEN NOT MATCHED THEN INSERT (
        bed.email_account_id,
        bed.email_classification_id,
        bed.agent_id,
        bed.party_id,
	   bed.outcome_id,
	   bed.result_id,
	   bed.reason_id,
        bed.time_id,
        bed.period_type_id,
        bed.period_start_date,
        bed.period_start_time,
        bed.created_by,
        bed.creation_date,
        bed.last_updated_by,
        bed.last_update_date,
        bed.accumulated_open_emails,
        bed.accumulated_open_age,
        bed.oldest_email_open_date,
        bed.accumulated_emails_one_day,
        bed.accumulated_emails_three_days,
        bed.accumulated_emails_week,
        bed.accumulated_emails_week_plus,
        bed.request_id,
        bed.program_application_id,
        bed.program_id,
        bed.program_update_date)
      VALUES (
        change.email_account_id,
        change.email_classification_id,
        change.agent_id,
        change.party_id,
	   -1,
	   -1,
	   -1,
        change.time_id,
        change.period_type_id,
        change.period_start_date,
        change.period_start_time,
        g_user_id,
        g_sysdate,
        g_user_id,
        g_sysdate,
        decode(change.accumulated_open_emails, 0, to_number(null), change.accumulated_open_emails),
        decode(change.accumulated_open_age, 0, to_number(null), change.accumulated_open_age),
        change.oldest_email_open_date,
        decode(change.accumulated_emails_one_day, 0, to_number(null), change.accumulated_emails_one_day),
        decode(change.accumulated_emails_three_days, 0, to_number(null), change.accumulated_emails_three_days),
        decode(change.accumulated_emails_week, 0, to_number(null), change.accumulated_emails_week),
        decode(change.accumulated_emails_week_plus, 0, to_number(null), change.accumulated_emails_week_plus),
        g_request_id,
        g_program_appl_id,
        g_program_id,
        g_sysdate);

  COMMIT;

  g_rows_ins_upd := g_rows_ins_upd + p_email_account_id.COUNT;

  write_log('Finished procedure update_open_measure at ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in update_open_measure : Error : ' || sqlerrm);
    RAISE;
END update_open_measure;

/* This procedure collects all the open related measures
This splits the data to mutliple time buckets.  Then it calls update_open_measures
which does the actual MERGE of the data
*/
PROCEDURE process_open_measure_row(p_media_id IN OUT NOCOPY g_media_id_tab,
                                   p_email_account_id IN OUT NOCOPY g_email_account_id_tab,
                                   p_email_classification_id IN OUT NOCOPY g_email_classification_id_tab,
                                   p_resource_id IN OUT NOCOPY g_resource_id_tab,
                                   p_party_id IN OUT NOCOPY g_party_id_tab,
                                   p_start_date_time IN OUT NOCOPY g_start_date_time_tab,
                                   p_end_date_time IN OUT NOCOPY g_end_date_time_tab,
                                   p_media_start_date_time IN OUT NOCOPY g_media_start_date_time_tab,
                                   p_period_start_date_time IN OUT NOCOPY g_start_date_time_tab,
                                   p_period_end_date_time IN OUT NOCOPY g_end_date_time_tab) IS

  l_email_account_id g_email_account_id_tab;
  l_email_classification_id g_email_classification_id_tab;
  l_party_id g_party_id_tab;
  l_agent_id g_resource_id_tab;
  l_period_start_date g_period_start_date_tab;
  l_emails_open g_emails_open_tab;
  l_total_open_age g_total_open_age_tab;
  l_oldest_open_message g_oldest_open_message_tab;
  l_acc_emails_one_day g_acc_emails_one_day_tab;
  l_acc_emails_three_days g_acc_emails_three_days_tab;
  l_acc_emails_week g_acc_emails_week_tab;
  l_acc_emails_week_plus g_acc_emails_week_plus_tab;

  l_temp_date DATE;
  l_begin_bucket_date DATE;
  l_end_bucket_date DATE;
  l_next_seg_start_date DATE;
  l_party_id_temp NUMBER;
  j NUMBER;
  l_diff_time NUMBER;

BEGIN

  write_log('Start of the procedure process_open_measure_row at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* Initialize the variables */
  j := 0;
  l_email_account_id := g_email_account_id_tab();
  l_email_classification_id := g_email_classification_id_tab();
  l_party_id := g_party_id_tab();
  l_agent_id := g_resource_id_tab();
  l_period_start_date := g_period_start_date_tab();
  l_emails_open := g_emails_open_tab();
  l_total_open_age := g_total_open_age_tab();
  l_oldest_open_message := g_oldest_open_message_tab();
  l_acc_emails_one_day := g_acc_emails_one_day_tab();
  l_acc_emails_three_days := g_acc_emails_three_days_tab();
  l_acc_emails_week := g_acc_emails_week_tab();
  l_acc_emails_week_plus := g_acc_emails_week_plus_tab();

  /* Loop through all the media returned by the cursor */
  FOR i IN p_media_id.FIRST .. p_media_id.LAST
  LOOP
    l_begin_bucket_date := NULL;
    l_end_bucket_date   := NULL;
    l_temp_date         := NULL;

    /* Get the start and the end bucket of time where the open measures will be sliced into      */
    /* if segment start date < collection start date , then start bucket = collection start date */
    /* else start bucket = time bucket of segment start date time                                */
    l_begin_bucket_date := p_period_start_date_time(i);
    --1/2hr changed increment to 1 from 1/48
    --l_temp_date := l_begin_bucket_date + 1/48;
    l_temp_date := l_begin_bucket_date + 1;
    l_next_seg_start_date := p_end_date_time(i);

    /* if segment end date > collection end date , then end bucket = collection end date */
    /* else end bucket = time bucket of segment end date time                            */
    l_end_bucket_date := p_period_end_date_time(i);

    /* loop through the time range and slice the open measures into appropiate 1/2 hr bucket */
    WHILE(l_begin_bucket_date <=  l_end_bucket_date)  LOOP

      j := j + 1;

      l_email_account_id.extend(1);
      l_email_classification_id.extend(1);
      l_party_id.extend(1);
      l_agent_id.extend(1);
      l_period_start_date.extend(1);
      l_emails_open.extend(1);
      l_total_open_age.extend(1);
      l_oldest_open_message.extend(1);
      l_acc_emails_one_day.extend(1);
      l_acc_emails_three_days.extend(1);
      l_acc_emails_week.extend(1);
      l_acc_emails_week_plus.extend(1);

      l_email_account_id(j) := p_email_account_id(i);
      l_email_classification_id(j) := p_email_classification_id(i);
      l_party_id(j) := p_party_id(i);
      l_agent_id(j) := p_resource_id(i);
      l_period_start_date(j) := l_begin_bucket_date;
      l_emails_open(j) := 0;
      l_total_open_age(j) := 0;
      l_oldest_open_message(j) := NULL;
      l_acc_emails_one_day(j) := 0;
      l_acc_emails_three_days(j) := 0;
      l_acc_emails_week(j) := 0;
      l_acc_emails_week_plus(j) := 0;

      IF (l_next_seg_start_date BETWEEN l_begin_bucket_date AND l_temp_date
               AND l_next_seg_start_date <> g_collect_end_date ) THEN
        /* control reaching here means that the email is no longer open at the end of this time bucket */
        l_total_open_age(j) := round((l_next_seg_start_date - p_start_date_time(i) ) * 24 * 60 * 60);
      ELSE
        /* control reaching here means that the email is still open at the end of this time bucket */
        l_total_open_age(j)  := round((l_temp_date - p_start_date_time(i)) * 24 * 60 * 60);
        l_emails_open(j) := 1;
        l_oldest_open_message(j) := p_start_date_time(i);

        /* Determine if the email is in the queue for 1 day , 3 days, a week or more than that */
        l_diff_time := l_temp_date - p_media_start_date_time(i);

        IF (l_diff_time <= 1) THEN
          l_acc_emails_one_day(j) := 1;
        ELSIF (l_diff_time <= 3) THEN
          l_acc_emails_three_days(j) := 1;
        ELSIF (l_diff_time <= 7) THEN
          l_acc_emails_week(j) := 1;
        ELSE
          l_acc_emails_week_plus(j) := 1;
        END IF;

      END IF;

      IF (j >= g_commit_chunk_size) THEN
        update_open_measure (l_email_account_id,
                             l_email_classification_id,
                             l_party_id,
                             l_agent_id,
                             l_period_start_date,
                             l_emails_open,
                             l_total_open_age,
                             l_oldest_open_message,
                             l_acc_emails_one_day,
                             l_acc_emails_three_days,
                             l_acc_emails_week,
                             l_acc_emails_week_plus);

        l_email_account_id.TRIM(j);
        l_email_classification_id.TRIM(j);
        l_party_id.TRIM(j);
        l_agent_id.TRIM(j);
        l_period_start_date.TRIM(j);
        l_emails_open.TRIM(j);
        l_total_open_age.TRIM(j);
        l_oldest_open_message.TRIM(j);
        l_acc_emails_one_day.TRIM(j);
        l_acc_emails_three_days.TRIM(j);
        l_acc_emails_week.TRIM(j);
        l_acc_emails_week_plus.TRIM(j);

        j := 0;
      END IF;
      --1/2hr changed increment to 1 from 1/48
      --l_begin_bucket_date := l_begin_bucket_date + 1/48;
      l_begin_bucket_date := l_begin_bucket_date + 1;
      --1/2hr changed increment to 1 from 1/48
      --l_temp_date := l_temp_date + 1/48;
      l_temp_date := l_temp_date + 1;
    END LOOP;-- End of inner While loop

  END LOOP;

  IF (l_email_account_id.COUNT >= 1) THEN
    update_open_measure (l_email_account_id,
                         l_email_classification_id,
                         l_party_id,
                         l_agent_id,
                         l_period_start_date,
                         l_emails_open,
                         l_total_open_age,
                         l_oldest_open_message,
                         l_acc_emails_one_day,
                         l_acc_emails_three_days,
                         l_acc_emails_week,
                         l_acc_emails_week_plus);

    l_email_account_id.TRIM(j);
    l_email_classification_id.TRIM(j);
    l_party_id.TRIM(j);
    l_agent_id.TRIM(j);
    l_period_start_date.TRIM(j);
    l_emails_open.TRIM(j);
    l_total_open_age.TRIM(j);
    l_oldest_open_message.TRIM(j);
    l_acc_emails_one_day.TRIM(j);
    l_acc_emails_three_days.TRIM(j);
    l_acc_emails_week.TRIM(j);
    l_acc_emails_week_plus.TRIM(j);

  END IF;

  write_log('Finished procedure process_open_measure_row at ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in process_open_measure_row : Error : ' || sqlerrm);
    RAISE;
END process_open_measure_row;

/*============================================================================================+

This procedure collects all the open related  measures.  The queue cursor has two parts with union.
The first part collects all the emails whIch are still  Open (in Agent inbox) now.
The second part of SQL collects all the emails which was open  for some time and
now they are no longer open.

Each eamil can be sitting in agent inbox for several days.  Each email translates to multiple rows
in summary table.  for example if one emaiil is in agent inbox for 2 days then two rows will
be inserted one for each day with accumulated_open_emails as 1 for both days.

================================================================================================*/

PROCEDURE collect_open_measures AS

  CURSOR open_measures IS
  SELECT /*+ use_hash(mitm) use_hash(mseg) use_hash(mtys) use_hash(cls) use_hash(inv2) */
    mitm.media_id                        MEDIA_ID,
    nvl(mitm.source_id, -1)              EMAIL_ACCOUNT_ID,
    nvl(cls.route_classification_id, -1) EMAIL_CLASSIFICATION_ID,
    nvl(mseg.resource_id,-1)             RESOURCE_ID,
    nvl(inv2.party_id, -1)                PARTY_ID,
    mseg.start_date_time                 START_DATE_TIME,
    g_collect_end_date                   END_DATE_TIME,
    mitm.start_date_time                 MEDIA_START_DATE_TIME,
    --1/2hr
    decode(sign(mseg.start_date_time - g_collect_start_date), -1, g_collect_start_date,
              to_date(to_char(mseg.start_date_time ,'YYYY/MM/DD ')|| '00:'
               || '00',
                 'YYYY/MM/DD HH24:MI')) PERIOD_START_DATE_TIME,
    --1/2hr
    g_collect_end_date
                                          PERIOD_END_DATE_TIME
  FROM
    JTF_IH_MEDIA_ITEMS mitm,
    JTF_IH_MEDIA_ITEM_LC_SEGS mseg,
    JTF_IH_MEDIA_ITM_LC_SEG_TYS mtys,
    --
    --Changes for R12
    --
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) cls,
    (
        --???Changed for party
         --SELECT /*+ use_hash(actv) use_hash(intr) */
           --actv.media_id        media_id,
           --min(intr.party_id)   party_id
         --FROM
           --jtf_ih_activities actv,
           --jtf_ih_interactions intr
         --WHERE actv.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
         --AND   actv.interaction_id = intr.interaction_id
         --GROUP BY actv.media_id
         SELECT /*+ use_hash(actv) use_hash(intr) */
           distinct actv.media_id        media_id,
           first_value(intr.party_id)
           over(partition by actv.media_id order by actv.interaction_id desc) party_id
         FROM
           jtf_ih_activities actv,
           jtf_ih_interactions intr
         WHERE actv.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
         AND   actv.interaction_id = intr.interaction_id
    ) inv2
  WHERE mitm.media_item_type = 'EMAIL'
  AND   mitm.direction = 'INBOUND'
  AND   mitm.classification = cls.name(+)
  AND   mitm.media_id = mseg.media_id
  AND   mseg.start_date_time < g_collect_end_date
  AND   mseg.milcs_type_id = mtys.milcs_type_id
  AND   mtys.milcs_code IN ('EMAIL_FETCH','EMAIL_TRANSFER', 'EMAIL_ASSIGN_OPEN', 'EMAIL_AUTO_ROUTED', 'EMAIL_ASSIGNED')
  AND   mitm.media_id = inv2.media_id --??? test with outer join removed here
  AND   NOT EXISTS
   (
    SELECT  /*+ use_hash(mseg1) use_hash(mtys1) */
      1
    FROM JTF_IH_MEDIA_ITEM_LC_SEGS mseg1,
         JTF_IH_MEDIA_ITM_LC_SEG_TYS mtys1
    WHERE mseg.media_id = mseg1.media_id
--    AND   mseg.resource_id = mseg1.resource_id
 /* Commenting this join out because the supervisor can perform some of the operations below.
	 Irrespective of which user did it, the email is not open any more */
    AND   mseg1.milcs_type_id = mtys1.milcs_type_id
    AND   mtys1.milcs_code  IN ('EMAIL_REPLY','EMAIL_DELETED','EMAIL_TRANSFERRED', 'EMAIL_ESCALATED', 'EMAIL_REQUEUED',
                                'EMAIL_ASSIGNED','EMAIL_REROUTED_DIFF_ACCT', 'EMAIL_REROUTED_DIFF_CLASS')
    AND   mseg1.START_DATE_TIME >= mseg.START_DATE_TIME
    AND   mseg1.start_date_time < g_collect_end_date
    AND   mseg1.milcs_id <> mseg.milcs_id
   )
  UNION
  SELECT /*+ use_hash(mitm) use_hash(inv2) use_hash(inv1) use_hash(mseg) use_hash(mtys) use_hash(cls) */
    mitm.media_id                        MEDIA_ID,
    nvl(mitm.source_id, -1)              EMAIL_ACCOUNT_ID,
    nvl(cls.route_classification_id, -1) EMAIL_CLASSIFICATION_ID,
    nvl(mseg.resource_id, -1)            RESOURCE_ID,
    nvl(inv1.party_id, -1)               PARTY_ID,
    mseg.start_date_time                 START_DATE_TIME,
    min(inv2.start_date_time)             END_DATE_TIME,
    mitm.start_date_time                 MEDIA_START_DATE_TIME,
    --1/2hr
    decode(sign(mseg.start_date_time - g_collect_start_date), -1, g_collect_start_date,
             to_date(to_char(mseg.start_date_time ,'YYYY/MM/DD ')|| '00:'
               || '00',
                 'YYYY/MM/DD HH24:MI'))  PERIOD_START_DATE_TIME,
    decode(sign(g_collect_end_date - min(inv2.start_date_time)), -1, g_collect_end_date - (( 29 * 60 + 59 )/(24*60*60)),
             to_date(to_char(min(inv2.start_date_time) ,'YYYY/MM/DD ')|| '00:'
               || '00',
                'YYYY/MM/DD HH24:MI'))   PERIOD_END_DATE_TIME
  FROM
    JTF_IH_MEDIA_ITEMS mitm,
    (
        SELECT  /*+ use_hash(mseg1) use_hash(mtys1) */
                mseg1.media_id         MEDIA_ID,
                mseg1.resource_id      RESOURCE_ID,
                mseg1.start_date_time  START_DATE_TIME
        FROM    JTF_IH_MEDIA_ITEM_LC_SEGS mseg1,
                JTF_IH_MEDIA_ITM_LC_SEG_TYS mtys1
        WHERE   mseg1.MILCS_TYPE_ID = mtys1.MILCS_TYPE_ID
        AND     mtys1.MILCS_CODE  IN ('EMAIL_REPLY','EMAIL_DELETED','EMAIL_TRANSFERRED', 'EMAIL_ESCALATED',
                   'EMAIL_ASSIGNED','EMAIL_REQUEUED', 'EMAIL_REROUTED_DIFF_ACCT', 'EMAIL_REROUTED_DIFF_CLASS')
        AND     mseg1.START_DATE_TIME BETWEEN g_collect_start_date AND  g_collect_end_date
    ) inv2,
    (
         --????Change for party_id
         --SELECT /*+ use_hash(actv) use_hash(intr) */
           --actv.media_id        media_id,
           --min(intr.party_id)   party_id
         --FROM
           --jtf_ih_activities actv,
           --jtf_ih_interactions intr
         --WHERE actv.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
         --AND   actv.interaction_id = intr.interaction_id
         --GROUP BY actv.media_id
         SELECT /*+ use_hash(actv) use_hash(intr) */
           distinct actv.media_id        media_id,
           first_value(intr.party_id)
           over(partition by actv.media_id order by actv.interaction_id desc) party_id
         FROM
           jtf_ih_activities actv,
           jtf_ih_interactions intr
         WHERE actv.start_date_time BETWEEN g_collect_start_date AND g_collect_end_date
         AND   actv.interaction_id = intr.interaction_id
    ) inv1,
    JTF_IH_MEDIA_ITEM_LC_SEGS mseg,
    JTF_IH_MEDIA_ITM_LC_SEG_TYS mtys,
    --
    --Changes for R12
    --
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) cls
  WHERE  mitm.media_id = inv2.media_id
  AND    inv2.media_id = mseg.media_id
  -- AND    inv2.resource_id = mseg.resource_id
/* Commenting this join out because the supervisor  performs some  operations like delete and requeued.
	 Irrespective of which user did it, the email was not open. Lets say Email fetched by agent a, email transferred by a,
	 email transfer to b, email requeue to c. If we remove this condition, we anyways take min (inv2.start_date_time),
	 so a will get the email transferred start date time (done by him), b will get requeue start date time (done by c) */
  AND    mitm.media_item_type = 'EMAIL'
  AND    mitm.direction = 'INBOUND'
  AND    mitm.classification = cls.name(+)
  AND    mseg.start_date_time < g_collect_end_date
  AND    mseg.milcs_type_id = mtys.milcs_type_id
  AND    inv2.START_DATE_TIME >= mseg.START_DATE_TIME
  AND    mtys.milcs_code IN ('EMAIL_FETCH','EMAIL_TRANSFER', 'EMAIL_ASSIGN_OPEN', 'EMAIL_AUTO_ROUTED')
  AND    mitm.media_id = inv1.media_id --???test with outer join removed here
  GROUP BY
    mitm.media_id,
    nvl(mitm.source_id, -1),
    nvl(cls.route_classification_id, -1),
    nvl(mseg.resource_id, -1),
    nvl(inv1.party_id, -1),
    mseg.start_date_time,
    mitm.start_date_time;

  l_media_id g_media_id_tab;
  l_email_account_id g_email_account_id_tab;
  l_email_classification_id g_email_classification_id_tab;
  l_resource_id g_resource_id_tab;
  l_party_id g_party_id_tab;
  l_start_date_time g_start_date_time_tab;
  l_end_date_time g_end_date_time_tab;
  l_media_start_date_time g_media_start_date_time_tab;
  l_period_start_date_time g_start_date_time_tab;
  l_period_end_date_time g_end_date_time_tab;

  l_no_of_records  NUMBER;
BEGIN

  write_log('Start of the procedure collect_open_measures at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  OPEN open_measures;

  LOOP

    /* Bulk collect open information and process them row by row */
    FETCH open_measures BULK COLLECT INTO
      l_media_id,
      l_email_account_id,
      l_email_classification_id,
      l_resource_id,
      l_party_id,
      l_start_date_time,
      l_end_date_time,
      l_media_start_date_time,
      l_period_start_date_time,
      l_period_end_date_time
    LIMIT g_commit_chunk_size;

    l_no_of_records := l_media_id.COUNT;

    IF (l_no_of_records > 0) THEN
      process_open_measure_row(
        l_media_id,
        l_email_account_id,
        l_email_classification_id,
        l_resource_id,
        l_party_id,
        l_start_date_time,
        l_end_date_time,
        l_media_start_date_time,
        l_period_start_date_time,
        l_period_end_date_time);

      l_media_id.TRIM(l_no_of_records);
      l_email_account_id.TRIM(l_no_of_records);
      l_email_classification_id.TRIM(l_no_of_records);
      l_resource_id.TRIM(l_no_of_records);
      l_party_id.TRIM(l_no_of_records);
      l_start_date_time.TRIM(l_no_of_records);
      l_end_date_time.TRIM(l_no_of_records);
      l_media_start_date_time.TRIM(l_no_of_records);
      l_period_start_date_time.TRIM(l_no_of_records);
      l_period_end_date_time.TRIM(l_no_of_records);
    END IF;

    EXIT WHEN open_measures%NOTFOUND;

  END LOOP;

  CLOSE open_measures;

  /* Estimating statistics as these rows will be updated by resolution measures */
  DBMS_STATS.gather_table_stats(ownname => g_bix_schema,
                                tabName => 'BIX_EMAIL_DETAILS_F',
                                cascade => TRUE,
                                degree => bis_common_parameters.get_degree_of_parallelism,
                                estimate_percent => 10,
                                granularity => 'GLOBAL');

  write_log('Finished procedure collect_open_measures at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure collect_open_measures : Error : ' || sqlerrm);
    IF (open_measures%ISOPEN) THEN
      CLOSE open_measures;
    END IF;
    RAISE;
END collect_open_measures;

/*
This procedure collect all data by Day. This procedure inturn calls serveral other procedures
to collect different measures. It calls the following procedures .

collect_emails: This procedure collects all additive mesaues like fetched, replied etc.
collect_queue_measures : This procedure collects Queue Measures
collect_open_measures :  This procedure collects Open measures
collect_resolutions:     This procedure collects One  Done resolution measures.
*/

PROCEDURE collect_day IS
BEGIN

  write_log('Start of the procedure collect_half_hour at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  /* collects all the Email additive measures from oltp tables */
  write_log('Calling procedure collect_emails');
  collect_emails;
  write_log('End procedure collect_emails');

  /* collect queue informations like queue time */
  write_log('Calling procedure collect_queue_measures');
  collect_queue_measures;
  write_log('End procedure collect_queue_measures');

  /* collect open informations like # of emails open at end of time bucket */
  write_log('Calling procedure collect_open_measures');
  collect_open_measures;
  write_log('End procedure collect_open_measures');

  /* Collect the resolutions measures */
  write_log('Calling procedure collect_resolutions');
  collect_resolutions;
  write_log('End procedure collect_resolutions');

  write_log('Finished procedure collect_half_hour at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error in procedure collect_half_hour : Error : ' || sqlerrm);
    RAISE;
END collect_day;


/*====================================================================

This procedure summarizes  day level rows to week, period, Quarter and Year.

NOTE:
For accumulated measures we need to go to the end of the time bucket.  Example
the last day of the week or month and use the acumulated measures from that time
for the ROLLUP.  FOr this we use FIRST_VALUE clause.

=======================================================================*/

PROCEDURE summarize_data IS

BEGIN

  write_log('Start of the procedure summarize_data at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  write_log('Merging half hour rows to day, week, month, quarter, year bucket in table bix_email_details_f');

  /* Rollup half hour informations to day, week, month, quarter, year time bucket for table bix_email_details_f  */
  /* An outer group by sql is required after rollup as rollup produces two rows for weeks spanning tow months    */
  /* the rollup of oldess_email_open_date, oldest_email_queue_date, accumulated_open_age, accumulated_queue_time */
  /* are not calculated as simple min or sum will produce the wrong result ; we have to fix in the future rlease */

  INSERT /*+ append */ INTO bix_email_details_f (
    agent_id,
    email_account_id,
    email_classification_id,
    party_id,
    time_id,
    period_type_id,
    period_start_date,
    period_start_time,
    outcome_id,
    result_id,
    reason_id,
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
    one_rsln_in_period,
    two_rsln_in_period,
    three_rsln_in_period,
    four_rsln_in_period,
    interaction_threads_in_period,
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
  (SELECT
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
    g_user_id                                        created_by,
    g_sysdate                                        creation_date,
    g_user_id                                        last_updated_by,
    g_sysdate                                        last_update_date,
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
    min(rlp.oldest_email_open_date)                  oldest_email_open_date,
    min(rlp.oldest_email_queue_date)                 oldest_email_queue_date,
    decode(sum(rlp.email_resp_time_in_period), 0, to_number(null), sum(rlp.email_resp_time_in_period))
                                                     email_resp_time_in_period,
    decode(sum(rlp.agent_resp_time_in_period), 0, to_number(null), sum(rlp.agent_resp_time_in_period))
                                                     agent_resp_time_in_period,
    min(rlp.acc_open_emails)                         acc_open_emails,
    min(rlp.acc_open_age)                            acc_open_age,
    min(rlp.acc_emails_in_queue)                     acc_emails_in_queue,
    min(rlp.acc_queue_time)                          acc_queue_time,
    min(rlp.acc_emails_one_day)                      acc_emails_one_day,
    min(rlp.acc_emails_three_days)                   acc_emails_three_days,
    min(rlp.acc_emails_week)                         acc_emails_week,
    min(rlp.acc_emails_week_plus)                    acc_emails_week_plus,
    decode(sum(rlp.one_rsln_in_period), 0, to_number(null), sum(rlp.one_rsln_in_period))
                                                     one_rsln_in_period,
    decode(sum(rlp.two_rsln_in_period), 0, to_number(null), sum(rlp.two_rsln_in_period))
                                                     two_rsln_in_period,
    decode(sum(rlp.three_rsln_in_period), 0, to_number(null), sum(rlp.three_rsln_in_period))
                                                     three_rsln_in_period,
    decode(sum(rlp.four_rsln_in_period), 0, to_number(null), sum(rlp.four_rsln_in_period))
                                                     four_rsln_in_period,
    decode(sum(rlp.interaction_threads_in_period), 0, to_number(null), sum(rlp.interaction_threads_in_period))
                                                     interaction_threads_in_period,
    decode(sum(rlp.emails_orr_count_in_period),0,to_number(null),sum(emails_orr_count_in_period)) emails_orr_count_in_period,
    decode(sum(rlp.EMAILS_AUTO_REPLIED_IN_PERIOD),0,to_number(null),sum(EMAILS_AUTO_REPLIED_IN_PERIOD)) EMAILS_AUTO_REPLIED_IN_PERIOD,
    decode(sum(rlp.EMAILS_AUTO_DELETED_IN_PERIOD),0,to_number(null),sum(EMAILS_AUTO_DELETED_IN_PERIOD)) EMAILS_AUTO_DELETED_IN_PERIOD,
    decode(sum(rlp.EMAILS_AUTO_RESOLVED_IN_PERIOD),0,to_number(null),sum(EMAILS_AUTO_RESOLVED_IN_PERIOD)) EMAILS_AUTO_RESOLVED_IN_PERIOD,
    decode(sum(rlp.emails_composed_in_period),0,to_number(null),sum(emails_composed_in_period)) emails_composed_in_period,
    decode(sum(rlp.EMAILS_REROUTED_IN_PERIOD),0,to_number(null),sum(EMAILS_REROUTED_IN_PERIOD)) EMAILS_REROUTED_IN_PERIOD,
    decode(sum(rlp.leads_created_in_period),0,to_number(null),sum(leads_created_in_period)) leads_created_in_period,
    g_request_id                                     request_id,
    g_program_appl_id                                program_application_id,
    g_program_id                                     program_id,
    g_sysdate                                        program_update_date
  FROM (
    SELECT
      inv2.agent_id agent_id,
      inv2.email_account_id email_account_id,
      inv2.email_classification_id email_classification_id,
      inv2.party_id party_id,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), inv2.ent_year_id),
              inv2.ent_qtr_id), inv2.ent_period_id), inv2.week_id) time_id,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null),
              128), 64), 32), 16) period_type_id,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_date(null), min(inv2.ent_year_start_date)),
              min(inv2.ent_qtr_start_date)), min(inv2.ent_period_start_date)), min(inv2.week_start_date))
                   period_start_date,
      '00:00' period_start_time,
	 inv2.outcome_id,
	 inv2.result_id,
	 inv2.reason_id,
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
      to_date(null) oldest_email_open_date,
      to_date(null) oldest_email_queue_date,
      sum(inv2.email_resp_time_in_period) email_resp_time_in_period,
      sum(inv2.agent_resp_time_in_period) agent_resp_time_in_period,
      sum(inv2.one_rsln_in_period) one_rsln_in_period,
      sum(inv2.two_rsln_in_period) two_rsln_in_period,
      sum(inv2.three_rsln_in_period) three_rsln_in_period,
      sum(inv2.four_rsln_in_period) four_rsln_in_period,
      sum(inv2.interaction_threads_in_period) interaction_threads_in_period,
      sum(inv2.emails_orr_count_in_period) emails_orr_count_in_period,
      sum(inv2.EMAILS_AUTO_REPLIED_IN_PERIOD) EMAILS_AUTO_REPLIED_IN_PERIOD,
      sum(inv2.EMAILS_AUTO_DELETED_IN_PERIOD) EMAILS_AUTO_DELETED_IN_PERIOD,
      sum(inv2.EMAILS_AUTO_RESOLVED_IN_PERIOD) EMAILS_AUTO_RESOLVED_IN_PERIOD,
      sum(inv2.emails_composed_in_period) emails_composed_in_period,
      sum(inv2.emails_rerouted_in_period) emails_rerouted_in_period,
      sum(inv2.leads_created_in_period) leads_created_in_period,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_open_emails)),
              min(inv2.qtr_acc_open_emails)), min(inv2.period_acc_open_emails)), min(inv2.week_acc_open_emails))
                                                                       acc_open_emails,
      to_number(null)                                                                                acc_open_age,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_emails_in_queue)),
              min(inv2.qtr_acc_emails_in_queue)), min(inv2.period_acc_emails_in_queue)), min(inv2.week_acc_emails_in_queue))
                                                                  acc_emails_in_queue,
      to_number(null)                                                                                acc_queue_time,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_emails_one_day)),
              min(inv2.qtr_acc_emails_one_day)), min(inv2.period_acc_emails_one_day)), min(inv2.week_acc_emails_one_day))
                                                                    acc_emails_one_day,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_emails_three_days)),
              min(inv2.qtr_acc_emails_three_days)), min(inv2.period_acc_emails_three_days)),
                min(inv2.week_acc_emails_three_days))            acc_emails_three_days,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_emails_week)),
              min(inv2.qtr_acc_emails_week)), min(inv2.period_acc_emails_week)), min(inv2.week_acc_emails_week))
                                                                      acc_emails_week,
      decode(inv2.week_id, null, decode(inv2.ent_period_id, null,
          decode(inv2.ent_qtr_id, null, decode(inv2.ent_year_id, null, to_number(null), min(inv2.year_acc_emails_week_plus)),
              min(inv2.qtr_acc_emails_week_plus)), min(inv2.period_acc_emails_week_plus)),
                min(inv2.week_acc_emails_week_plus))              acc_emails_week_plus
    FROM
      (SELECT /*+ use_hash(bed) use_hash(ftd) */
         bed.agent_id agent_id,
         bed.email_account_id email_account_id,
         bed.email_classification_id email_classification_id,
         bed.party_id party_id,
	    bed.outcome_id,
	    bed.result_id,
	    bed.reason_id,
         ftd.ent_year_id ent_year_id,
         ftd.ent_year_start_date ent_year_start_date,
         ftd.ent_qtr_id ent_qtr_id,
         ftd.ent_qtr_start_date ent_qtr_start_date,
         ftd.ent_period_id ent_period_id,
         ftd.ent_period_start_date ent_period_start_date,
         ftd.week_id  week_id,
         ftd.week_start_date week_start_date,
         ftd.report_date_julian report_date_julian,
         bed.period_start_date period_start_date,
         bed.emails_offered_in_period emails_offered_in_period,
         bed.emails_fetched_in_period emails_fetched_in_period,
         bed.emails_replied_in_period emails_replied_in_period,
         bed.emails_rpld_by_goal_in_period emails_rpld_by_goal_in_period,
         bed.AGENT_EMAILS_RPLD_BY_GOAL AGENT_EMAILS_RPLD_BY_GOAL,
         bed.emails_deleted_in_period emails_deleted_in_period,
         bed.emails_trnsfrd_out_in_period emails_trnsfrd_out_in_period,
         bed.emails_trnsfrd_in_in_period emails_trnsfrd_in_in_period,
         bed.emails_rsl_and_trfd_in_period emails_rsl_and_trfd_in_period,
         bed.emails_assigned_in_period emails_assigned_in_period,
         bed.emails_auto_routed_in_period emails_auto_routed_in_period,
         bed.emails_auto_uptd_sr_in_period emails_auto_uptd_sr_in_period,
         bed.sr_created_in_period sr_created_in_period,
         bed.email_resp_time_in_period email_resp_time_in_period,
         bed.agent_resp_time_in_period agent_resp_time_in_period,
         bed.one_rsln_in_period one_rsln_in_period,
         bed.two_rsln_in_period two_rsln_in_period,
         bed.three_rsln_in_period three_rsln_in_period,
         bed.four_rsln_in_period four_rsln_in_period,
         bed.interaction_threads_in_period interaction_threads_in_period,
	    bed.emails_orr_count_in_period emails_orr_count_in_period,
	    bed.EMAILS_AUTO_REPLIED_IN_PERIOD EMAILS_AUTO_REPLIED_IN_PERIOD,
	    bed.EMAILS_AUTO_DELETED_IN_PERIOD EMAILS_AUTO_DELETED_IN_PERIOD,
	    bed.EMAILS_AUTO_RESOLVED_IN_PERIOD EMAILS_AUTO_RESOLVED_IN_PERIOD,
	    bed.emails_composed_in_period emails_composed_in_period,
	    bed.emails_rerouted_in_period emails_rerouted_in_period,
	    bed.leads_created_in_period leads_created_in_period,
	    --1/2hr removing day measures since they have already been done
        -- first_value(bed.accumulated_open_emails)
        --   over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
        --         ftd.report_date_julian
        --           order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
        --             lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) day_acc_open_emails,
         first_value(bed.accumulated_open_emails)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.week_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_open_emails,
         first_value(bed.accumulated_open_emails)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_period_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_open_emails,
         first_value(bed.accumulated_open_emails)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_qtr_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_open_emails,
         first_value(bed.accumulated_open_emails)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_year_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_open_emails,
	    --1/2hr removing day measures since they have already been done
         --first_value(bed.accumulated_emails_in_queue)
         --  over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
         --        ftd.report_date_julian
         --          order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
         --            lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) day_acc_emails_in_queue,
         first_value(bed.accumulated_emails_in_queue)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.week_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_emails_in_queue,
         first_value(bed.accumulated_emails_in_queue)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_period_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_emails_in_queue,
         first_value(bed.accumulated_emails_in_queue)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_qtr_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_emails_in_queue,
         first_value(bed.accumulated_emails_in_queue)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_year_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_emails_in_queue,
	    --1/2hr removing day measures since they have already been done
        -- first_value(bed.accumulated_emails_one_day)
        --   over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
        --         ftd.report_date_julian
        --           order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
        --             lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) day_acc_emails_one_day,
         first_value(bed.accumulated_emails_one_day)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.week_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_emails_one_day,
         first_value(bed.accumulated_emails_one_day)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_period_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                      lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_emails_one_day,
         first_value(bed.accumulated_emails_one_day)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_qtr_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_emails_one_day,
         first_value(bed.accumulated_emails_one_day)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_year_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_emails_one_day,
	    --1/2hr removing day measures since they have already been done
         --first_value(bed.accumulated_emails_three_days)
         --  over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
         --        ftd.report_date_julian
         --          order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
         --            lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) day_acc_emails_three_days,
         first_value(bed.accumulated_emails_three_days)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.week_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_emails_three_days,
         first_value(bed.accumulated_emails_three_days)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_period_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_emails_three_days,
         first_value(bed.accumulated_emails_three_days)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_qtr_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_emails_three_days,
         first_value(bed.accumulated_emails_three_days)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_year_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_emails_three_days,
	    --1/2hr removing day measures since they have already been done
         --first_value(bed.accumulated_emails_week)
        --   over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
        --         ftd.report_date_julian
        --           order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
        --             lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) day_acc_emails_week,
         first_value(bed.accumulated_emails_week)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.week_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_emails_week,
         first_value(bed.accumulated_emails_week)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_period_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_emails_week,
         first_value(bed.accumulated_emails_week)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_qtr_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_emails_week,
         first_value(bed.accumulated_emails_week)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_year_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_emails_week,
	    --1/2hr removing day measures since they have already been done
         --first_value(bed.accumulated_emails_week_plus)
         --  over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
         --        ftd.report_date_julian
         --          order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
         --            lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) day_acc_emails_week_plus,
         first_value(bed.accumulated_emails_week_plus)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.week_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) week_acc_emails_week_plus,
         first_value(bed.accumulated_emails_week_plus)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_period_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) period_acc_emails_week_plus,
         first_value(bed.accumulated_emails_week_plus)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_qtr_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) qtr_acc_emails_week_plus,
         first_value(bed.accumulated_emails_week_plus)
           over (partition by bed.agent_id, bed.email_account_id, bed.email_classification_id, bed.party_id,
		 outcome_id, result_id, reason_id,
                 ftd.ent_year_id
                   order by to_date(to_char(bed.period_start_date, 'dd/mm/yyyy ') ||
                     lpad(bed.period_start_time, 5, '0'), 'dd/mm/yyyy hh24:mi') desc) year_acc_emails_week_plus
       FROM bix_email_details_f bed,
            fii_time_day ftd
       WHERE bed.time_id = ftd.report_date_julian
       --1/2hr changed period_Type_id to 1 from -1
       --AND   bed.period_type_id = -1) inv2
       AND   bed.period_type_id = 1) inv2
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
    rlp.reason_id);

  g_rows_ins_upd := g_rows_ins_upd + SQL%ROWCOUNT;

  COMMIT;

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

/*
This procedure  Calls the following procedures
1. Collect_day :  which collects all the email center measures by day
2. summarise_data :  This procedure summarizes the data to Week, Month , Quarter and Year from Day rows collected in
				 collect_day procedure.
*/



PROCEDURE MAIN ( errbuf       OUT NOCOPY VARCHAR2,
                 retcode      OUT NOCOPY VARCHAR2,
                 p_start_date IN  VARCHAR2,
                 p_end_date   IN  VARCHAR2) IS

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
  check_missing_date(g_collect_start_date, g_collect_end_date, l_has_missing_date);
  IF (l_has_missing_date) THEN
    write_log('Time dimension is not populated for the entire collection date range');
    RAISE G_TIME_DIM_MISSING;
  END IF;

  write_log('Force Enabling parallel query and parallel dml');
  EXECUTE IMMEDIATE ' Alter Session force parallel query';
  EXECUTE IMMEDIATE ' Alter Session enable parallel DML';


  write_log('Calling procedure collect_day');
  collect_day;
  write_log('End procedure collect_day');

  /* Summarize data to day, week, month, quater and year time buckets */
  write_log('Calling procedure summarize_data');
  summarize_data;
  write_log('End procedure summarize_data');

  write_log('Total Rows Inserted/Updated : ' || to_char(g_rows_ins_upd));

  DBMS_STATS.gather_table_stats(ownname => g_bix_schema,
                                tabName => 'BIX_EMAIL_DETAILS_F',
                                cascade => TRUE,
                                degree => bis_common_parameters.get_degree_of_parallelism,
                                estimate_percent => 10,
                                granularity => 'GLOBAL');

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
END MAIN;

/* This is the procedure called from concurrent program. The data is collected from  BIS Global start Date to current date. This procedure calls MAIN with start date and End date.
*/


PROCEDURE  load (errbuf   OUT  NOCOPY VARCHAR2,
                 retcode  OUT  NOCOPY VARCHAR2)
IS
  l_start_date DATE;
  l_end_date   DATE;

BEGIN

  init;
  write_log('End procedure init');

  /* Get the global start date */
  l_start_date := to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'),'MM/DD/YYYY');


  /* Round the start date to the nearest half hour , less than start date */
  SELECT
    TO_DATE(TO_CHAR(l_start_date,'YYYY/MM/DD') || ' ' ||
                        LPAD(TO_CHAR(l_start_date,'HH24:'),3,'0') ||
                           DECODE(SIGN(TO_NUMBER(TO_CHAR(l_start_date,'MI'))-29),0,'00:00',1,'30:00',-1,'00:00'),
                              'YYYY/MM/DD HH24:MI:SS')
  INTO
    l_start_date
  FROM DUAL;

  l_end_date := sysdate;



  /* Round the end date to the nearest half hour , less than end date */
  SELECT
    TO_DATE(TO_CHAR(l_end_date,'YYYY/MM/DD') || ' ' ||
                        LPAD(TO_CHAR(l_end_date,'HH24:'),3,'0') ||
                           DECODE(SIGN(TO_NUMBER(TO_CHAR(l_end_date,'MI'))-29),0,'00:00',1,'30:00',-1,'00:00'),
                              'YYYY/MM/DD HH24:MI:SS') - 1/86400
  INTO
    l_end_date
  FROM DUAL;

--???? For Debugging Purposes
--l_end_date := sysdate;

  Main(errbuf,
       retcode,
       TO_CHAR(l_start_date, 'YYYY/MM/DD HH24:MI:SS'),
       TO_CHAR(l_end_date, 'YYYY/MM/DD HH24:MI:SS'));
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END load;

END BIX_EMAILS_LOAD_PKG;

/
