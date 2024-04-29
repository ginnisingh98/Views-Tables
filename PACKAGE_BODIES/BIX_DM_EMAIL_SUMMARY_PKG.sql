--------------------------------------------------------
--  DDL for Package Body BIX_DM_EMAIL_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_DM_EMAIL_SUMMARY_PKG" AS
/*$Header: bixxemcb.plb 120.1 2005/10/12 22:01:57 anasubra noship $ */

  g_request_id       		NUMBER;
  g_program_appl_id  		NUMBER;
  g_program_id       		NUMBER;
  g_user_id          		NUMBER;
  g_program_start_date  		DATE;
  g_collect_start_date     	DATE;
  g_collect_end_date       	DATE;
  g_rounded_collect_start_date DATE;
  g_rounded_collect_end_date 	DATE;
  g_error_mesg     			VARCHAR2(4000);
  g_status	   			VARCHAR2(4000);
  g_proc_name	   			VARCHAR2(4000);
  g_commit_chunk_size 		NUMBER;
  g_debug_flag                VARCHAR2(1)  := 'N';

  G_DATE_MISMATCH             EXCEPTION;

/*===================================================================================================+
| INSERT_LOG procedure inserts collection concurrent program status into BIX_DM_COLLECT_LOG table     |
| It inserts a row with the following details :                                                       |
|                                                                                                     |
| COLLECT_STATUS column equals to  FAILED if the program failed otherwise SUCCESS                     |
| COLLECT_EXCEP_MESG as error message if the program failed otherwise NULL                            |
| RUN_START_DATE equals to start date time when  the collection program started runnning              |
| RUN_END_DATE  equals  end date time of the collection program finished                              |
| COLLECT_START_DATE Collection start date specified by the user in the cuncurrent program parameter  |
| COLLECT_END_DATE Collection end date specified by the user in the cuncurrent program parameter      |
====================================================================================================+*/

PROCEDURE Write_Log (p_msg IN VARCHAR2) IS
BEGIN
  IF (g_debug_flag = 'Y') THEN
    fnd_file.put_line(fnd_file.log, p_msg);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Write_Log;

PROCEDURE INSERT_LOG
AS
BEGIN
   	write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                       ' BIX_DM_EMAIL_SUMMARY_PKG.INSERT_LOG:' ||
				   'Start inserting collection status into BIX_DM_COLLECT_LOG table');

/* Insert status into log table */

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
	g_proc_name,
	'PL SQL PACKAGE',
	g_program_start_date,
	SYSDATE,
	g_collect_start_date,
     g_collect_end_date,
	g_status,
	g_error_mesg,
	SYSDATE,
	g_user_id,
	SYSDATE,
	g_user_id,
	g_user_id,
	g_request_id,
	g_program_appl_id,
	g_program_id,
	SYSDATE
	);
 COMMIT;

  write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
				' BIX_DM_EMAIL_SUMMARY_PKG.INSERT_LOG:'||
				'Finished inserting collection status into BIX_DM_COLLECT_LOG table');
  EXCEPTION
  WHEN OTHERS THEN
   write_log( TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
				 'BIX_DM_EMAIL_SUMMARY_PKG.INSERT_LOG:  ' ||
				 'Failed to insert rows into BIX_DM_COLLECT_LOG table: '||sqlerrm);
  RAISE;
  END INSERT_LOG;

/*===================================================================================================+
| CLEAN_UP procedure writes error message into FND log file,Rollback the data written into Email     |
| summary tables and also calls INSERT_LOG procedure to log error messge in BIX_DM_COLLECT_LOG table |
+===================================================================================================*/

PROCEDURE clean_up IS
l_delete_count NUMBER := 0;

	BEGIN
	write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||g_error_mesg);

/* Delete from Email summary table */

 LOOP
	DELETE bix_dm_email_sum
	WHERE  last_update_date > g_program_start_date
     AND  rownum <= g_commit_chunk_size ;

     IF(SQL%ROWCOUNT < g_commit_chunk_size) THEN
        COMMIT;
        EXIT;
     ELSE
	   COMMIT;
     END IF;

 END LOOP;

write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
			    ' BIX_DM_EMAIL_SUMMARY_PKG.CLEAN_UP: '||
			    ' Finished  Deleting rows in BIM_DM_EMAIL_SUM table: ' ||
				'Row Count:' || l_delete_count);

l_delete_count := 0;

/* Delete Email Agent Summary Table */

 LOOP
	DELETE bix_dm_email_agent_sum
	WHERE  last_update_date > g_program_start_date
     AND  rownum <= g_commit_chunk_size ;

     IF(SQL%ROWCOUNT < g_commit_chunk_size) THEN
        COMMIT;
        EXIT;
     ELSE
	   COMMIT;
     END IF;

 END LOOP;

write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
			    ' BIX_DM_EMAIL_SUMMARY_PKG.CLEAN_UP: '||
				' Finished  Deleting rows in BIM_DM_EMAIL_AGENT_SUM table: ' ||
				 'Row Count:' || l_delete_count);
l_delete_count := 0;

/* Delete from Email Group Summary tables */

 LOOP
        DELETE bix_dm_email_group_sum
        WHERE  last_update_date > g_program_start_date
     AND  rownum <= g_commit_chunk_size ;

     IF(SQL%ROWCOUNT < g_commit_chunk_size) THEN
        COMMIT;
        EXIT;
     ELSE
           COMMIT;
     END IF;

 END LOOP;

write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                            ' BIX_DM_EMAIL_SUMMARY_PKG.CLEAN_UP: '||
                                ' Finished  Deleting rows in BIM_DM_EMAIL_GROUP_SUM table: ' ||
                                 'Row Count:' || l_delete_count);
	EXCEPTION
	WHEN OTHERS THEN
	write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
				   'CLEAN_UP:  ERROR: '||  SQLERRM);
	RAISE;
END CLEAN_UP;

/*==========================================================================================+
| This procedure returns weather Email Center application is installed or not               |
===========================================================================================*/

FUNCTION is_emc_installed RETURN VARCHAR2 IS
l_emc_installed VARCHAR2(1);
BEGIN
SELECT  UPPER(application_installed) INTO l_emc_installed
FROM  bix_dm_apps_dependency
WHERE application_short_name = 'BIX_DM_EMC_INSTALLED';

 return l_emc_installed;

EXCEPTION
WHEN OTHERS THEN
write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                       ' BIX_DM_EMAIL_SUMMARY_PKG.IS_EMC_INSTALLED: ERROR ' || sqlerrm);
return 'N';
END;

/*===========================================================================================+
| This procedure collects additive     email reporting measures summarised by the following  |
| dimensions                                                                                 |
| 1. Email account id                                                                        |
| 2. Classification                                                                          |
| 3. Resource ID                                                                             |
| 4. Time bucket ( half hour). All the measures are summarized by half hour                  |
============================================================================================*/

PROCEDURE collect_emails
AS

  l_email_sum_delete_count NUMBER := 0 ;
  l_email_agent_sum_delete_count NUMBER := 0;
  l_email_sum_insert_count NUMBER := 0;
  l_email_agent_sum_insert_count NUMBER := 0;
  l_email_service_level NUMBER := 24 * 60 * 60;

 CURSOR all_emails IS
 SELECT NVL(ih_mitem.source_id,-1) EMAIL_ACCOUNT_ID,
        NVL(iem_r_c.ROUTE_CLASSIFICATION_ID,-1) CLASSIFICATION_ID,
        RESOURCE_ID,
       NVL(TRUNC(ih_lc_segs.start_date_time),TO_DATE('4012/01/01','YYYY/MM/DD')) PERIOD_START_DATE,
       NVL(LPAD(TO_CHAR(ih_lc_segs.start_date_time,'HH24:'),3,'0')||
       DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_lc_segs.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'00:00')
	  PERIOD_START_TIME,
       TO_DATE(NVL(TO_CHAR(ih_lc_segs.start_date_time,'YYYY/MM/DD '),'4012/01/01 ')||
               NVL(LPAD(TO_CHAR(ih_lc_segs.start_date_time,'HH24:'),3,'0')||
       DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_lc_segs.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'00:00'),
	  'YYYY/MM/DD HH24:MI') PERIOD_START_DATE_TIME,
	  --
	  --Make sure the media start date falls within date range
	  --as where condition is based on segment start time
	  --
       COUNT(DISTINCT(DECODE(SIGN(ih_mitem.start_date_time - g_rounded_collect_start_date), -1, null,
		             DECODE(SIGN(ih_mitem.start_date_time - g_rounded_collect_end_date), -1, ih_mitem.media_id, null))))
							   EMAILS_OFFERED,
       SUM(DECODE(ih_lc_seg_typs.MILCS_CODE,'EMAIL_FETCH',1)) EMAILS_FETCHED,
       SUM(DECODE(ih_lc_seg_typs.MILCS_CODE,'EMAIL_REPLY',1)) EMAILS_REPLIED,
       SUM(DECODE(ih_lc_seg_typs.MILCS_CODE,'EMAIL_REPLY',
                  (ih_lc_segs.start_date_time - email_fetch_time.start_date_time) * 24 * 60 * 60))
		 COMPLETE_AGENT_RESPONSE_TIME,
       SUM(DECODE(ih_lc_seg_typs.MILCS_CODE,'EMAIL_REPLY',
            DECODE(SIGN((NVL(goals.sl_for_replied_emails * 60 * 60,l_email_service_level))  -
		  (ih_lc_segs.start_date_time - email_fetch_time.start_date_time)
		                     * 24 * 60 * 60),-1,0,1))) EMAILS_REPLIED_WITHIN_GOAL,
       SUM(DECODE(ih_lc_seg_typs.MILCS_CODE,'EMAIL_TRANSFERRED',1)) EMAILS_TRANSFERRED,
       SUM(DECODE(ih_lc_seg_typs.MILCS_CODE,'EMAIL_DELETED',1)) EMAILS_DELETED,
       SUM(DECODE(ih_lc_seg_typs.MILCS_CODE,'EMAIL_REPLY',
	      (ih_lc_segs.start_date_time - ih_mitem.start_date_time) * 24 * 60 * 60)) EMC_RESPONSE_TIME
 FROM JTF_IH_MEDIA_ITEMS ih_mitem,
      JTF_IH_MEDIA_ITEM_LC_SEGS ih_lc_segs,
      (
	 --
	 --To calculate agent response time
	 --
       SELECT a.media_id media_id,
              MAX(c.start_date_time) start_date_time
       FROM jtf_ih_media_item_lc_segs a,
            jtf_ih_media_itm_lc_seg_tys b,
   	    jtf_ih_media_item_lc_segs c,
	    jtf_ih_media_itm_lc_seg_tys d
       WHERE a.start_date_time BETWEEN g_rounded_collect_start_date AND g_rounded_collect_end_date
       AND a.milcs_type_id = b.milcs_type_id
       AND b.milcs_code = 'EMAIL_REPLY'
       AND a.media_id =   c.media_id
       AND c.milcs_type_id = d.milcs_type_id
       AND d.milcs_code IN ('EMAIL_FETCH','EMAIL_TRANSFER')
       GROUP BY a.media_id
      ) email_fetch_time,
      JTF_IH_MEDIA_ITM_LC_SEG_TYS ih_lc_seg_typs,
      --iem_route_classifications iem_r_c,
    --
    --Changes for R12
    --
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) iem_r_c,
	 ( SELECT * FROM bix_dm_goals_emc
	   WHERE  end_date_active IS NULL) goals
 WHERE ih_mitem.MEDIA_ITEM_TYPE = 'EMAIL'
 AND   ih_mitem.DIRECTION = 'INBOUND'
 AND   ih_mitem.classification = iem_r_c.name(+)
 AND   iem_r_c.route_classification_id  = goals.classification_id(+)
 AND   ih_mitem.media_id =  email_fetch_time.media_id(+)
 AND   ih_mitem.MEDIA_ID = ih_lc_segs.MEDIA_ID
 AND   ih_lc_segs.MILCS_TYPE_ID = ih_lc_seg_typs.MILCS_TYPE_ID
 AND   ih_lc_segs.START_DATE_TIME BETWEEN  g_rounded_collect_start_date and g_rounded_collect_end_date
 GROUP BY NVL(ih_mitem.SOURCE_ID,-1),
          NVL(iem_r_c.ROUTE_CLASSIFICATION_ID,-1),
  	     RESOURCE_ID,
          NVL(TRUNC(ih_lc_segs.start_date_time),TO_DATE('4012/01/01','YYYY/MM/DD')),
          NVL(LPAD(TO_CHAR(ih_lc_segs.start_date_time,'HH24:'),3,'0')||
      DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_lc_segs.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'00:00'),
          TO_DATE(NVL(TO_CHAR(ih_lc_segs.start_date_time,'YYYY/MM/DD '),'4012/01/01 ')||
		NVL(LPAD(TO_CHAR(ih_lc_segs.start_date_time,'HH24:'),3,'0')||
          DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_lc_segs.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),
					    '00:00'),'YYYY/MM/DD HH24:MI');
 BEGIN

 /* Get the Service level for the whole email center . Use this service level if the service
    level is not defined for indivisual classification */

   BEGIN
   --
   --This is for cases where the goal is not defined and the default is used
   --
   SELECT sl_for_replied_emails * 60 * 60  INTO l_email_service_level
   FROM   bix_dm_goals_emc
   WHERE  classification_id = -999;
   EXCEPTION
   WHEN OTHERS THEN
	   l_email_service_level := 24 * 60 * 60;
   END;

 /* Delete from the Email summary table for the data range that the data need to be collected */

 --dbms_output.put_line('service level emc: '|| l_email_service_level );

 write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
			    ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_EMAIL :'||
			    'Start Deleting rows from Email summary tables');

/* Delete from BIX_DM_EMAIL_SUM table where last_update_date
   between g_rounded_collect_start_date and g_rounded_collect_end_date */

     l_email_sum_delete_count := 0;

   LOOP
	DELETE bix_dm_email_sum
	WHERE  period_start_date_time BETWEEN g_rounded_collect_start_date AND
								   g_rounded_collect_end_date
     AND  rownum <= g_commit_chunk_size ;

     l_email_sum_delete_count := l_email_sum_delete_count + SQL%ROWCOUNT;

	  IF(SQL%ROWCOUNT < g_commit_chunk_size) THEN
	   COMMIT;
        EXIT;
	  ELSE
	   COMMIT;
       END IF;
    END LOOP;

   LOOP
	DELETE bix_dm_email_agent_sum
	WHERE  period_start_date_time BETWEEN g_rounded_collect_start_date AND
								   g_rounded_collect_end_date
     AND  rownum <= g_commit_chunk_size ;

     l_email_agent_sum_delete_count := l_email_agent_sum_delete_count + SQL%ROWCOUNT;

	  IF(SQL%ROWCOUNT < g_commit_chunk_size) THEN
	   COMMIT;
        EXIT;
	  ELSE
	   COMMIT;
       END IF;
    END LOOP;

  --dbms_output.put_line('BIX_DM_EMAIL_SUM Delete Count : '|| l_email_sum_delete_count);

     write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
				   ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_EMAILS: '||
				   ' Finished  Deleting rows in BIM_DM_EMAIL_SUM table: ' ||
				   'Row Count:' || l_email_sum_delete_count);

  --dbms_output.put_line('BIX_DM_EMAIL_AGENT_SUM delete count :'|| l_email_agent_sum_delete_count);

     write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
				   ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_EMAILS: '||
				   ' Finished  Deleting rows in BIM_DM_EMAIL_AGENT_SUM table: ' ||
				   'Row Count:' || l_email_agent_sum_delete_count);

      write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
				   ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_EMAILS: '||
				   ' Start collecting information into Email summary tables');

        /*
        dbms_output.put_line('before for loop');
        dbms_output.put_line('Start Date: ' ||
	   to_char(g_rounded_collect_start_date,'YYYY/MM/DD HH24:MI:SS'));
        dbms_output.put_line('End   Date: ' ||
	   to_char(g_rounded_collect_end_date,'YYYY/MM/DD HH24:MI:SS'));
	*/

      FOR emails IN  all_emails LOOP

       -- dbms_output.put_line('inside for loop');
    IF( emails.resource_id IS NULL) THEN
        --dbms_output.put_line('inside email IF');
    /* insert the email summary information into the BIX_DM_EMAIL_SUM table */
    --
    --This might be a QUEUE rows OR a EMAILS_PROCESSING row or OFFERED.
    --
	INSERT INTO bix_dm_email_sum
	(
	email_summary_id,
	email_account_id,
	classification_id,
	period_start_date,
	period_start_time,
	period_start_date_time,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	emails_offered,
	request_id,
	program_application_id,
	program_id,
	program_update_date
	)
	VALUES
	(
	bix_dm_email_sum_s.nextval,
	emails.email_account_id,
	emails.classification_id,
	emails.period_start_date,
	emails.period_start_time,
	emails.period_start_date_time,
	SYSDATE,
	g_user_id,
	SYSDATE,
	g_user_id,
	emails.emails_offered,
	g_request_id,
	g_program_appl_id,
	g_program_id,
	SYSDATE
 	);
	l_email_sum_insert_count := l_email_sum_insert_count + 1;
    ELSE
	        --dbms_output.put_line('inside email Agent IF');
    --
    --This might be any of the agent events like REPLIED, DELETED etc
    --
     INSERT INTO bix_dm_email_agent_sum
	(
	email_agent_summary_id,
	email_account_id,
	classification_id,
	resource_id,
	period_start_date,
	period_start_time,
	period_start_date_time,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	emails_fetched,
	emails_replied,
        emails_replied_within_goal,
	emails_deleted,
	emails_transferred,
	emc_response_time,
        complete_agent_response_time,
	request_id,
	program_application_id,
	program_id,
	program_update_date
	)
	VALUES
	(
	bix_dm_email_agent_sum_s.nextval,
	emails.email_account_id,
	emails.classification_id,
	emails.resource_id,
	emails.period_start_date,
	emails.period_start_time,
	emails.period_start_date_time,
	SYSDATE,
	g_user_id,
	SYSDATE,
	g_user_id,
	emails.emails_fetched,
	emails.emails_replied,
	emails.emails_replied_within_goal,
	emails.emails_deleted,
	emails.emails_transferred,
	emails.emc_response_time,
	emails.complete_agent_response_time,
	g_request_id,
	g_program_appl_id,
	g_program_id,
	SYSDATE
	);
	l_email_agent_sum_insert_count := l_email_agent_sum_insert_count + 1;
   END IF;

/* commit the rows after every commit chunk size which is defined as profile */

	IF(MOD((l_email_sum_insert_count + l_email_agent_sum_insert_count),g_commit_chunk_size)=0) THEN
	COMMIT;
	END IF;

  END LOOP;

  COMMIT;

   write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
				 ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_EMAILS: '||
				 'Finished  Inserting rows into BIM_DM_EMAIL_SUM table ' );

   write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
				 ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_EMAILS: '||
				 'Finished  Inserting rows into BIM_DM_EMAIL_AGENT_SUM table ');

select count(*) into l_email_agent_sum_insert_count
from bix_dm_email_agent_sum;
--dbms_output.put_line('Inserted Count : ' || l_email_agent_sum_insert_count);

/*  If any error occurs delete all the rows inserted in this procedure
    and  raise an exception to outer calling procedure */

 EXCEPTION
   WHEN OTHERS THEN
	--dbms_output.put_line('Error'|| sqlerrm);
	g_error_mesg := 'COLLECT_CALLS: ERROR: ' || SQLERRM;
	clean_up;
        RAISE;
END COLLECT_EMAILS;



/*===========================================================================================+
| This procedure collects Queue measures.  The queue cursor has two parts with union.        |
| The first part collects all the emails which are still in queue now.                       |
| The second part of SQL collects all the emails which was in queue for some time and        |
| now they are no longer in queue .                                                          |
|                                                                                            |
| Each eamil can be in queue for several days.  Each email translates to multiple rows       |
| in summary table.  for example if one emaiil is in queue for 2 days then two rows will     |
| be inserted one for each day with accumulated_emails_in_queue as 1 for both days.          |
|                                                                                            |
| If there is no emails in queue for particular combination dimensions                       |
| this procedure populates null.                                                             |
============================================================================================*/

PROCEDURE COLLECT_QUEUE_MEASURES
AS
CURSOR queue_measures IS
SELECT  ih_mitem.media_id,
        NVL(ih_mitem.source_id,-1) EMAIL_ACCOUNT_ID,
        NVL(iem_r_c.ROUTE_CLASSIFICATION_ID,-1) CLASSIFICATION_ID,
        ih_lc_segs_fetch.START_DATE_TIME start_date_time,
        g_rounded_collect_end_date end_date_time
FROM JTF_IH_MEDIA_ITEMS ih_mitem,
     JTF_IH_MEDIA_ITEM_LC_SEGS ih_lc_segs_fetch,
     JTF_IH_MEDIA_ITM_LC_SEG_TYS ih_lc_seg_typs,
     --IEM_ROUTE_CLASSIFICATIONS iem_r_c
    --
    --Changes for R12
    --
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) iem_r_c
WHERE ih_mitem.MEDIA_ITEM_TYPE = 'EMAIL'
AND   ih_mitem.DIRECTION = 'INBOUND'
AND   ih_mitem.classification = iem_r_c.name(+)
AND   ih_mitem.MEDIA_ID = ih_lc_segs_fetch.MEDIA_ID
AND   ih_lc_segs_fetch.START_DATE_TIME < g_rounded_collect_end_date
AND   ih_lc_segs_fetch.MILCS_TYPE_ID = ih_lc_seg_typs.MILCS_TYPE_ID
AND   ih_lc_seg_typs.MILCS_CODE IN ('EMAIL_PROCESSING', 'EMAIL_REQUEUED')
AND   NOT EXISTS
   (
    SELECT  'DUMMY'
    FROM JTF_IH_MEDIA_ITEM_LC_SEGS B,
         JTF_IH_MEDIA_ITM_LC_SEG_TYS C
    WHERE  ih_lc_segs_fetch.MEDIA_ID = B.MEDIA_ID
    AND    B.MILCS_TYPE_ID = C.MILCS_TYPE_ID
    AND  C.MILCS_CODE  IN
		   ('EMAIL_FETCH', 'EMAIL_RESOLVED', 'EMAIL_AUTO_REDIRECTED', 'EMAIL_AUTO_DELETED',
		    'EMAIL_AUTO_REPLY', 'EMAIL_OPEN', 'EMAIL_AUTO_ROUTED', 'EMAIL_AUTO_UPDATED_SR',
		    'EMAIL_ASSIGN','EMAIL_AUTO_REDIRECTED_INTERNAL','EMAIL_AUTO_REDIRECTED_EXTERNAL','EMAIL_DELETED')
    AND B.START_DATE_TIME >= ih_lc_segs_fetch.START_DATE_TIME
    AND B.START_DATE_TIME < g_rounded_collect_end_date
   )
UNION
SELECT a.media_id,
       NVL(a.source_id,-1) EMAIL_ACCOUNT_ID,
       NVL(iem_r_c.ROUTE_CLASSIFICATION_ID,-1) CLASSIFICATION_ID,
       Y.START_DATE_TIME start_date_time,
       MIN(X.START_DATE_TIME) end_date_time
FROM   JTF_IH_MEDIA_ITEMS A,
       (
        SELECT  MEDIA_ID,
                RESOURCE_ID,
                START_DATE_TIME
        FROM    JTF_IH_MEDIA_ITEM_LC_SEGS B,
                JTF_IH_MEDIA_ITM_LC_SEG_TYS C
        WHERE   B.MILCS_TYPE_ID = C.MILCS_TYPE_ID
        AND  C.MILCS_CODE  IN
		   ('EMAIL_FETCH', 'EMAIL_RESOLVED', 'EMAIL_AUTO_REDIRECTED', 'EMAIL_AUTO_DELETED',
		    'EMAIL_AUTO_REPLY', 'EMAIL_OPEN', 'EMAIL_AUTO_ROUTED', 'EMAIL_AUTO_UPDATED_SR',
		    'EMAIL_ASSIGN','EMAIL_AUTO_REDIRECTED_INTERNAL','EMAIL_AUTO_REDIRECTED_EXTERNAL','EMAIL_DELETED')
        AND  B.START_DATE_TIME BETWEEN g_rounded_collect_start_date AND  g_rounded_collect_end_date
--
--it should have been closed within the collection date range
--
       ) X,
       JTF_IH_MEDIA_ITEM_LC_SEGS Y,
       JTF_IH_MEDIA_ITM_LC_SEG_TYS Z,
       --IEM_ROUTE_CLASSIFICATIONS iem_r_c
    --
    --Changes for R12
    --
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) iem_r_c
WHERE a.MEDIA_ITEM_TYPE = 'EMAIL'
AND   a.DIRECTION = 'INBOUND'
AND   a.classification = iem_r_c.name(+)
AND    A.MEDIA_ID = X.MEDIA_ID
AND    X.MEDIA_ID = Y.MEDIA_ID
AND    Y.START_DATE_TIME < g_rounded_collect_end_date --email arrival time should be less than collection end date
AND    Y.MILCS_TYPE_ID = Z.MILCS_TYPE_ID
AND    X.START_DATE_TIME >= Y.START_DATE_TIME --the delete/reply/resolved should have happened after the email arrival time
AND    Z.MILCS_CODE IN ('EMAIL_PROCESSING', 'EMAIL_REQUEUED')
GROUP BY
	  a.media_id,
       NVL(a.source_id,-1),
       NVL(iem_r_c.ROUTE_CLASSIFICATION_ID,-1),
       Y.START_DATE_TIME
;

--
--the above takes the minimum of date in order to take care of multiple cycles.
--for each cycle, the corresponding queu start and corresponding queue end will be taken
--
  l_temp_date DATE;
  l_begin_bucket_date DATE;
  l_end_bucket_date DATE;
  l_counter NUMBER :=0;
  l_emails_in_queue NUMBER;
  l_total_queue_time NUMBER;
  l_emails_queued NUMBER;
  l_oldest_message_in_queue DATE;

BEGIN


      write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
				   ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_QUEUE_MEASURES: '||
				   ' Start collecting Queue measures ');

 FOR q_measures IN queue_measures LOOP
	-- dbms_output.put_line('FOR LOOP media id:' || q_measures.media_id);
 	l_begin_bucket_date := NULL;
	l_end_bucket_date   := NULL;
	l_temp_date := NULL;

	IF(q_measures.start_date_time >= g_rounded_collect_start_date + 1/48) THEN
 	 	SELECT TO_DATE(TO_CHAR(q_measures.start_date_time ,'YYYY/MM/DD')||
        	       LPAD(TO_CHAR(q_measures.start_date_time ,'HH24:'),3,'0')||
                       DECODE(SIGN(TO_NUMBER(TO_CHAR(q_measures.start_date_time ,'MI'))-29),
				   0,'00',1,'30',-1,'00'),'YYYY/MM/DDHH24:MI')
                       INTO l_begin_bucket_date FROM DUAL;
	ELSE
	l_begin_bucket_date := 	g_rounded_collect_start_date;
	END IF;

	l_temp_date := l_begin_bucket_date + 1/48;

	IF ( q_measures.end_date_time < g_rounded_collect_end_date - (( 29 * 60 + 59 )/(24*60*60)) )  THEN
	 	       SELECT TO_DATE(TO_CHAR(q_measures.end_date_time ,'YYYY/MM/DD')||
        	       LPAD(TO_CHAR(q_measures.end_date_time ,'HH24:'),3,'0')||
                       DECODE(SIGN(TO_NUMBER(TO_CHAR(q_measures.end_date_time ,'MI'))-29),
				   0,'00',1,'30',-1,'00'),'YYYY/MM/DDHH24:MI')
                       INTO l_end_bucket_date FROM DUAL;
	ELSE
	 l_end_bucket_date := g_rounded_collect_end_date - (( 29 * 60 + 59 )/(24*60*60));
	END IF;

	--dbms_output.put_line('STart date:'|| l_begin_bucket_date);
	--dbms_output.put_line('End date:'|| l_end_bucket_date);

 	WHILE(l_temp_date <=  l_end_bucket_date + 1/48)  LOOP
	 --dbms_output.put_line('media id:' || q_measures.media_id);
	  l_emails_in_queue := 0;
	  l_total_queue_time := 0;
	  l_emails_queued := 0;
	  l_oldest_message_in_queue := NULL;


	  IF(q_measures.end_date_time BETWEEN l_begin_bucket_date AND l_temp_date
               AND q_measures.end_date_time <> g_rounded_collect_end_date ) THEN
	  l_total_queue_time := (q_measures.end_date_time - q_measures.start_date_time ) * 24 * 60 * 60;
		l_emails_queued := 1;
	  ELSE
		l_total_queue_time := (l_temp_date - q_measures.start_date_time) * 24 * 60 * 60;
		l_emails_queued := 1;
		l_emails_in_queue := 1;
                l_oldest_message_in_queue := q_measures.start_date_time;
	  END IF;

	l_counter := l_counter + 1;

	UPDATE bix_dm_email_sum
	SET emails_remaining_in_queue = NVL(emails_remaining_in_queue,0) + l_emails_in_queue,
	queue_time = NVL(queue_time,0) + l_total_queue_time,
	max_queue_time = DECODE(l_total_queue_time, NULL,max_queue_time,
			        DECODE(max_queue_time,NULL,l_total_queue_time,
				           DECODE(SIGN(NVL(l_total_queue_time,0) - NVL(max_queue_time,0)),
							   1,l_total_queue_time,max_queue_time))),
    emails_in_q_during_time_period = NVL(emails_in_q_during_time_period,0) + l_emails_queued,
    oldest_message_in_queue = DECODE(l_oldest_message_in_queue,NULL,oldest_message_in_queue,
                                     DECODE(oldest_message_in_queue,NULL,l_oldest_message_in_queue,
                                         DECODE(SIGN(oldest_message_in_queue - l_oldest_message_in_queue),
							 0,oldest_message_in_queue,-1,oldest_message_in_queue,1,
								 l_oldest_message_in_queue))),
        last_update_date =  SYSDATE,
        last_updated_by = g_user_id
	WHERE period_start_date_time = l_begin_bucket_date
	AND   email_account_id = q_measures.email_account_id
	AND   classification_id = q_measures.classification_id;

    IF ( SQL%ROWCOUNT = 0) THEN
	INSERT INTO bix_dm_email_sum
	(
	email_summary_id,
	email_account_id,
	classification_id,
	period_start_date,
	period_start_time,
	period_start_date_time,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	emails_remaining_in_queue,
	queue_time,
	max_queue_time,
	emails_in_q_during_time_period,
	oldest_message_in_queue,
	request_id,
	program_application_id,
	program_id,
	program_update_date
	)
	VALUES
	(
	bix_dm_email_sum_s.nextval,
	q_measures.email_account_id,
	q_measures.classification_id,
	TRUNC(l_begin_bucket_date),
	TO_CHAR(l_begin_bucket_date,'HH24:MI'),
	l_begin_bucket_date,
	SYSDATE,
	g_user_id,
	SYSDATE,
	g_user_id,
	l_emails_in_queue,
	l_total_queue_time,
	l_total_queue_time,
	l_emails_queued,
	l_oldest_message_in_queue,
	g_request_id,
	g_program_appl_id,
	g_program_id,
	SYSDATE
 	);
    END IF;

	IF(MOD(l_counter,g_commit_chunk_size)=0) THEN
	COMMIT;
	END IF;

	l_begin_bucket_date := l_begin_bucket_date + 1/48;
	l_temp_date := l_temp_date + 1/48;
 	END LOOP;	-- End of inner While loop
   END LOOP;	-- End of Cursor FOR LOOP
	COMMIT;


      write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
				   ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_QUEUE_MEASURES: '||
				   ' Finished collecting Queue Measures');

 EXCEPTION
   WHEN OTHERS THEN
        g_error_mesg := 'COLLECT_QUEUE_MEASURES: ERROR: '||sqlerrm;
        clean_up;
        RAISE;
END COLLECT_QUEUE_MEASURES;

/*=====================================================================================================+
| This procedure collects all the open related  measures.  The queue cursor has two parts with union.  |
| The first part collects all the emails whIch are still  Open (in Agent inbox) now.                   |
| The second part of SQL collects all the emails which was open  for some time and                     |
| now they are no longer open.                                                                         |
|                                                                                                      |
| Each eamil can be sitting in agent inbox for several days.  Each email translates to multiple rows   |
| in summary table.  for example if one emaiil is in agent inbox for 2 days then two rows will         |
| be inserted one for each day with accumulated_open_emails as 1 for both days.                        |
======================================================================================================*/

PROCEDURE collect_open_measures
AS
CURSOR open_measures IS
SELECT ih_mitem.media_id,
       NVL(ih_mitem.source_id,-1) email_account_id,
       NVL(iem_r_c.route_classification_id,-1) classification_id,
       ih_lc_seg_typs.MILCS_CODE LC_SEGMENT,
       NVL(ih_lc_segs_fetch.RESOURCE_ID,-999) RESOURCE_ID,
       ih_lc_segs_fetch.START_DATE_TIME start_date_time,  --open start time for this specific agent
	  g_rounded_collect_end_date end_date_time, --since it is still open at g_collect_end_time
       min(A.start_date_time) email_start_date_time --very first time that the email was open in ANY of the agents
FROM JTF_IH_MEDIA_ITEMS ih_mitem,
     JTF_IH_MEDIA_ITEM_LC_SEGS ih_lc_segs_fetch,
     jtf_ih_media_item_lc_segs A,
     JTF_IH_MEDIA_ITM_LC_SEG_TYS ih_lc_seg_typs,
     jtf_ih_media_itm_lc_seg_tys B,
     --IEM_ROUTE_CLASSIFICATIONS iem_r_c
    --
    --Changes for R12
    --
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) iem_r_c
WHERE ih_mitem.MEDIA_ITEM_TYPE = 'EMAIL'
AND   ih_mitem.DIRECTION = 'INBOUND'
AND   ih_mitem.classification = iem_r_c.name(+)
AND   ih_mitem.MEDIA_ID = ih_lc_segs_fetch.MEDIA_ID
AND   ih_mitem.media_id = A.media_id
AND   ih_lc_segs_fetch.START_DATE_TIME < g_rounded_collect_end_date
AND   A.START_DATE_TIME < g_rounded_collect_end_date
AND   ih_lc_segs_fetch.MILCS_TYPE_ID = ih_lc_seg_typs.MILCS_TYPE_ID
AND   A.milcs_type_id = B.milcs_type_id
--
--milcs codes by which an email ended up in agents inbox
--auto route goes directly to agents inbox
--
AND   ih_lc_seg_typs.MILCS_CODE IN ('EMAIL_FETCH','EMAIL_TRANSFER', 'EMAIL_ASSIGNED','EMAIL_AUTO_ROUTED')
AND   B.MILCS_CODE IN ('EMAIL_FETCH','EMAIL_TRANSFER', 'EMAIL_ASSIGNED','EMAIL_AUTO_ROUTED')
AND   NOT EXISTS
   (
    SELECT  'DUMMY'
    FROM JTF_IH_MEDIA_ITEM_LC_SEGS B,
         JTF_IH_MEDIA_ITM_LC_SEG_TYS C
    WHERE  ih_lc_segs_fetch.MEDIA_ID = B.MEDIA_ID
    --AND    ih_lc_segs_fetch.RESOURCE_ID = B.RESOURCE_ID -- comment out for 11.5.10 features
    AND    B.MILCS_TYPE_ID = C.MILCS_TYPE_ID
    AND  C.MILCS_CODE  IN ('EMAIL_REPLY','EMAIL_DELETED','EMAIL_TRANSFERRED', 'EMAIL_ESCALATED', 'EMAIL_REQUEUED',
					  'EMAIL_ASSIGN','EMAIL_REROUTED_DIFF_ACCT', 'EMAIL_REROUTED_DIFF_CLASS')
    AND B.START_DATE_TIME > ih_lc_segs_fetch.START_DATE_TIME
    AND B.START_DATE_TIME < g_rounded_collect_end_date
   )
group by ih_mitem.media_id,
       NVL(ih_mitem.source_id,-1),
       NVL(iem_r_c.route_classification_id,-1),
       ih_lc_seg_typs.MILCS_CODE,
       NVL(ih_lc_segs_fetch.RESOURCE_ID,-999),
       ih_lc_segs_fetch.START_DATE_TIME,
	  g_rounded_collect_end_date
UNION
SELECT a.media_id,
       NVL(a.source_id,-1) email_account_id,
       NVL(iem_r_c.route_classification_id,-1) classification_id,
       Z.MILCS_CODE LC_SEGMENT,
       NVL(Y.RESOURCE_ID,-999) RESOURCE_ID,
       Y.START_DATE_TIME start_date_time,
	  MIN(X.START_DATE_TIME) end_date_time, --to calculate open times
       min(Y1.start_date_time) email_start_date_time
FROM   JTF_IH_MEDIA_ITEMS A,
       (
        SELECT  MEDIA_ID,
                RESOURCE_ID,
                START_DATE_TIME
        FROM    JTF_IH_MEDIA_ITEM_LC_SEGS B,
                JTF_IH_MEDIA_ITM_LC_SEG_TYS C
        WHERE   B.MILCS_TYPE_ID = C.MILCS_TYPE_ID
        AND  C.MILCS_CODE  IN ('EMAIL_REPLY','EMAIL_DELETED','EMAIL_TRANSFERRED', 'EMAIL_ESCALATED', 'EMAIL_REQUEUED',
					  'EMAIL_ASSIGN','EMAIL_REROUTED_DIFF_ACCT', 'EMAIL_REROUTED_DIFF_CLASS')
        AND  B.START_DATE_TIME BETWEEN g_rounded_collect_start_date AND  g_rounded_collect_end_date
       ) X,
       JTF_IH_MEDIA_ITEM_LC_SEGS Y,
       jtf_ih_media_item_lc_segs Y1,
       JTF_IH_MEDIA_ITM_LC_SEG_TYS Z,
       JTF_IH_MEDIA_ITM_LC_SEG_TYS Z1,
       --IEM_ROUTE_CLASSIFICATIONS iem_r_c
    --
    --Changes for R12
    --
    (
    select name, max(route_classification_id) route_classification_id
    from iem_route_classifications
    group by name
    ) iem_r_c
WHERE  A.MEDIA_ID = X.MEDIA_ID
AND    X.MEDIA_ID = Y.MEDIA_ID
AND    X.media_id = Y1.media_id
--AND    X.RESOURCE_ID = Y.RESOURCE_ID -- comment this out for 11.5.10
AND    a.MEDIA_ITEM_TYPE = 'EMAIL'
AND    a.DIRECTION = 'INBOUND'
AND    a.classification = iem_r_c.name(+)
AND    Y.START_DATE_TIME < g_rounded_collect_end_date
AND    Y1.START_DATE_TIME < g_rounded_collect_end_date
AND    Y.MILCS_TYPE_ID = Z.MILCS_TYPE_ID
AND    Y1.MILCS_TYPE_ID = Z1.MILCS_TYPE_ID
AND    X.START_DATE_TIME >= Y.START_DATE_TIME
AND    X.START_DATE_TIME >= Y1.START_DATE_TIME
AND    Z.MILCS_CODE IN ('EMAIL_FETCH','EMAIL_TRANSFER', 'EMAIL_ASSIGNED','EMAIL_ASSIGN', 'EMAIL_AUTO_ROUTED')
AND    Z1.MILCS_CODE IN ('EMAIL_FETCH','EMAIL_TRANSFER', 'EMAIL_ASSIGNED', 'EMAIL_ASSIGN','EMAIL_AUTO_ROUTED')
GROUP BY
	  a.media_id,
       NVL(a.source_id,-1),
       NVL(iem_r_c.route_classification_id,-1),
       Z.MILCS_CODE,
       NVL(Y.RESOURCE_ID,-999),
       Y.START_DATE_TIME
;
  l_temp_date DATE;
  l_begin_bucket_date DATE;
  l_end_bucket_date DATE;
  l_counter NUMBER :=0;
  l_start_date DATE;
  l_media_id NUMBER;
  l_next_seg_start_date DATE;

  l_emails_open NUMBER;
  l_oldest_open_message DATE;
  l_oldest_open_age DATE;
  l_total_open_age NUMBER;
  l_emails_opend NUMBER;
  l_resource_id NUMBER;

 BEGIN


      write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
				   ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_OPEN_MEASURES: '||
				   ' Start collecting Open Measures ');

   FOR o_measures IN open_measures LOOP
	 --dbms_output.put_line('FOR LOOP media id:' || o_measures.media_id);

 	l_begin_bucket_date := NULL;
	l_end_bucket_date   := NULL;
	l_temp_date := NULL;

	IF(o_measures.start_date_time >= g_rounded_collect_start_date + 1/48) THEN
 	 	SELECT TO_DATE(TO_CHAR(o_measures.start_date_time ,'YYYY/MM/DD')||
        	       LPAD(TO_CHAR(o_measures.start_date_time ,'HH24:'),3,'0')||
                       DECODE(SIGN(TO_NUMBER(TO_CHAR(o_measures.start_date_time ,'MI'))-29),
				   0,'00',1,'30',-1,'00'),'YYYY/MM/DDHH24:MI')
                       INTO l_begin_bucket_date FROM DUAL;
	ELSE
	l_begin_bucket_date := 	g_rounded_collect_start_date;
	END IF;

	--dbms_output.put_line('Begin date :'|| l_begin_bucket_date);

	l_temp_date := l_begin_bucket_date + 1/48;

	l_next_seg_start_date := o_measures.end_date_time;
	l_resource_id :=  o_measures.resource_id;
     l_start_date := o_measures.start_date_time;

 /*
	l_start_date := o_measures.start_date_time;
	l_media_id := o_measures.media_id;
	l_resource_id := o_measures.resource_id;

	BEGIN
	SELECT  start_date_time INTO l_next_seg_start_date
 	FROM
	(
	SELECT  lc_segs.start_date_time start_date_time
	FROM   jtf_ih_media_item_lc_segs lc_segs,
	       jtf_ih_media_itm_lc_seg_tys lc_seg_typs
	WHERE  lc_segs.media_id = l_media_id
	AND    lc_segs.resource_id = l_resource_id
	AND    lc_segs.start_date_time > l_start_date
	AND    lc_segs.milcs_type_id = lc_seg_typs.milcs_type_id
	AND    lc_seg_typs.milcs_code IN ('EMAIL_REPLY','EMAIL_TRANSFERRED','EMAIL_DELETED')
        ORDER BY lc_segs.start_date_time ASC
	)
	WHERE ROWNUM = 1;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	l_next_seg_start_date := NULL;
	END;

	IF ( o_measures.lc_segment = 'EMAIL_FETCH' ) THEN
	 l_resource_id := o_measures.resource_id;
	END IF;
 */

/*
      dbms_output.put_line('Resource ID: '||
					   l_resource_id || '  '||'
					   end_date_time: '||
					   l_next_seg_start_date);
*/

	IF ( l_next_seg_start_date < g_rounded_collect_end_date - (( 29 * 60 + 59 )/(24*60*60)) )  THEN
	 	       SELECT TO_DATE(TO_CHAR(l_next_seg_start_date ,'YYYY/MM/DD')||
        	       LPAD(TO_CHAR(l_next_seg_start_date ,'HH24:'),3,'0')||
                       DECODE(SIGN(TO_NUMBER(TO_CHAR(l_next_seg_start_date ,'MI'))-29),
				   0,'00',1,'30',-1,'00'),'YYYY/MM/DDHH24:MI')
                       INTO l_end_bucket_date FROM DUAL;
	ELSE
	 l_end_bucket_date := g_rounded_collect_end_date - (( 29 * 60 + 59 )/(24*60*60));
	END IF;

	--dbms_output.put_line('End date:'|| l_end_bucket_date);

 	WHILE(l_temp_date <=  l_end_bucket_date + 1/48)  LOOP
	  l_emails_open := 0;
	  l_oldest_open_message := NULL;
	  l_oldest_open_age := NULL;
	  l_total_open_age := 0;
	  l_emails_opend := 0;

	  IF(l_next_seg_start_date BETWEEN l_begin_bucket_date AND l_temp_date
               AND l_next_seg_start_date <> g_rounded_collect_end_date ) THEN
		l_total_open_age := (l_next_seg_start_date - o_measures.start_date_time ) * 24 * 60 * 60;
		l_emails_opend := 1;
	  ELSE
		l_total_open_age  := (l_temp_date - o_measures.start_date_time) * 24 * 60 * 60;
		l_emails_opend := 1;
		l_emails_open := 1;
          l_oldest_open_message := o_measures.start_date_time;
          l_oldest_open_age := o_measures.email_start_date_time;
	  END IF;

	  /*
	   dbms_output.put_line('Open Age:'|| l_total_open_age/60 ||
						'Oldest Open Message :'|| l_oldest_open_message);

            dbms_output.put_line('Total: '||l_resource_id||' '||l_begin_bucket_date||'  '||
					   o_measures.email_account_id||' '|| o_measures.classification_id||'  '
				             ||l_emails_open||' '||round(l_total_open_age/60)|| ' '||
						   l_emails_opend || ' '||  l_oldest_open_message);
       */

	UPDATE bix_dm_email_agent_sum
	SET emails_open = NVL(emails_open,0) + l_emails_open,
	    open_age    = NVL(open_age,0) + l_total_open_age,
	    emails_open_during_time_period = NVL(emails_open_during_time_period,0) + l_emails_opend,
         oldest_open_message = DECODE(l_oldest_open_message,NULL,oldest_open_message,
                                      DECODE(oldest_open_message,NULL,l_oldest_open_message,
                                         DECODE(SIGN(oldest_open_message - l_oldest_open_message),0,
                                                oldest_open_message,-1,oldest_open_message,1,
									   l_oldest_open_message))),
         oldest_open_age = DECODE(l_oldest_open_age,NULL,oldest_open_age,
                                      DECODE(oldest_open_age,NULL,l_oldest_open_age,
                                         DECODE(SIGN(oldest_open_age - l_oldest_open_age),0,
                                                oldest_open_age,-1,oldest_open_age,1,
									   l_oldest_open_age))),
        last_update_date =  SYSDATE,
        last_updated_by = g_user_id
	WHERE period_start_date_time = l_begin_bucket_date
	AND   email_account_id = o_measures.email_account_id
	AND   classification_id = o_measures.classification_id
	AND   resource_id  = l_resource_id;

    IF ( SQL%ROWCOUNT = 0) THEN
	INSERT INTO bix_dm_email_agent_sum
	(
	email_agent_summary_id,
	email_account_id,
	classification_id,
	resource_id,
	period_start_date,
	period_start_time,
	period_start_date_time,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	emails_open,
	oldest_open_message,
	oldest_open_age,
	open_age,
	emails_open_during_time_period,
	request_id,
	program_application_id,
	program_id,
	program_update_date
	)
	VALUES
	(
	bix_dm_email_sum_s.nextval,
	o_measures.email_account_id,
	o_measures.classification_id,
     NVL(l_resource_id,-999),
	TRUNC(l_begin_bucket_date),
	TO_CHAR(l_begin_bucket_date,'HH24:MI'),
	l_begin_bucket_date,
	SYSDATE,
	g_user_id,
	SYSDATE,
	g_user_id,
	l_emails_open,
	l_oldest_open_message,
	l_oldest_open_age,
	l_total_open_age,
	l_emails_opend,
	g_request_id,
	g_program_appl_id,
	g_program_id,
	SYSDATE
	);
    END IF;

     l_counter := l_counter + 1;

     IF(MOD(l_counter,g_commit_chunk_size)=0) THEN
	COMMIT;
	END IF;

	l_begin_bucket_date := l_begin_bucket_date + 1/48;
	l_temp_date := l_temp_date + 1/48;
 	END LOOP;	-- End of inner While loop
 END LOOP; -- End of Cursor for loop
 COMMIT;

      write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
				   ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_OPEN_MEASURES: '||
				   'Finished Collecting Open Measures ');

 EXCEPTION
  WHEN OTHERS THEN
	g_error_mesg := 'COLLECT_OPEN_MEASURES: ERROR: '||sqlerrm;
	clean_up;
        RAISE;
   END collect_open_measures;


/*====================================================================+
| This procedure summarizes all the agent information to the groups.  |
| This procedure summarizes the agent information                     |
| to all the groups in the heirarchy till the root group.             |
======================================================================*/

PROCEDURE collect_group_summary
AS
CURSOR group_email_sum
IS
SELECT
EMAIL_ACCOUNT_ID,
CLASSIFICATION_ID,
group_denorm.parent_group_id GROUP_ID,
PERIOD_START_DATE,
PERIOD_START_TIME,
PERIOD_START_DATE_TIME,
SUM(EMAILS_FETCHED) emails_fetched,
SUM(EMAILS_REPLIED) emails_replied,
SUM(EMAILS_REPLIED_WITHIN_GOAL) emails_replied_within_goal,
SUM(EMAILS_DELETED) emails_deleted,
SUM(EMAILS_TRANSFERRED) emails_transferred,
SUM(EMAILS_OPEN) emails_open,
MIN(OLDEST_OPEN_MESSAGE) oldest_open_message,
MIN(OLDEST_OPEN_AGE) oldest_open_age,
SUM(OPEN_AGE) open_age,
SUM(EMAILS_OPEN_DURING_TIME_PERIOD) emails_open_during_time_period,
SUM(EMC_RESPONSE_TIME) emc_response_time,
SUM(COMPLETE_AGENT_RESPONSE_TIME) complete_agent_response_time
FROM bix_dm_email_agent_sum agt_sum,
      jtf_rs_group_members groups,
      jtf_rs_groups_denorm group_denorm
WHERE agt_sum.period_start_date_time  BETWEEN g_rounded_collect_start_date AND g_rounded_collect_end_date
AND   agt_sum.resource_id = groups.resource_id
AND   groups.group_id    = group_denorm.group_id
AND   NVL(groups.delete_flag,'N') <> 'Y'
AND   agt_sum.period_start_date_time BETWEEN NVL(group_denorm.start_date_active,agt_sum.period_start_date_time)
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
						AND NVL(den1.end_date_active,SYSDATE))
        and mem1.resource_id = groups.resource_id
	   and nvl(mem1.delete_flag,'N') <> 'Y')
GROUP BY EMAIL_ACCOUNT_ID,
	 CLASSIFICATION_ID,
         group_denorm.parent_group_id,
         PERIOD_START_DATE,
         PERIOD_START_TIME,
         PERIOD_START_DATE_TIME;

l_counter NUMBER := 0;

BEGIN
      write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                                   ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_GROUP_SUMMARY: '||
                                  ' Start collecting information into Agent Group Email summary table');

/* Delete the rows from Group summary table for the given date range and re collect the rows from
   Agent summary table.
*/


write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                                   ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_GROUP_SUMMARY: '||
                                  ' Start Deleting the rows from Agent Group Email summary table ');

   LOOP
        DELETE bix_dm_email_group_sum
        WHERE  period_start_date_time BETWEEN g_rounded_collect_start_date
                                      AND     g_rounded_collect_end_date
     AND  rownum <= g_commit_chunk_size ;

     l_counter:= l_counter + SQL%ROWCOUNT;

          IF(SQL%ROWCOUNT < g_commit_chunk_size) THEN
           COMMIT;
        EXIT;
          ELSE
           COMMIT;
       END IF;
    END LOOP;

write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                                   ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_GROUP_SUMMARY: '||
                                  ' finished Deleting the rows from Agent Group Email summary table '||
                                  'Row Count: '|| l_counter);

l_counter := 0;

FOR group_emails IN group_email_sum LOOP

     INSERT INTO bix_dm_email_group_sum
	(
	email_group_summary_id,
	email_account_id,
	classification_id,
	group_id,
	period_start_date,
	period_start_time,
	period_start_date_time,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	emails_fetched,
	emails_replied,
        emails_replied_within_goal,
	emails_deleted,
	emails_transferred,
	emails_open,
	oldest_open_message,
	oldest_open_age,
	open_age,
	emails_open_during_time_period,
	emc_response_time,
        complete_agent_response_time,
	request_id,
	program_application_id,
	program_id,
	program_update_date
	)
	VALUES
	(
	bix_dm_email_group_sum_s.nextval,
	group_emails.email_account_id,
	group_emails.classification_id,
	group_emails.group_id,
	group_emails.period_start_date,
	group_emails.period_start_time,
	group_emails.period_start_date_time,
	SYSDATE,
	g_user_id,
	SYSDATE,
	g_user_id,
	group_emails.emails_fetched,
	group_emails.emails_replied,
	group_emails.emails_replied_within_goal,
	group_emails.emails_deleted,
	group_emails.emails_transferred,
     group_emails.emails_open,
     group_emails.oldest_open_message,
     group_emails.oldest_open_age,
        group_emails.open_age,
        group_emails.emails_open_during_time_period,
	group_emails.emc_response_time,
	group_emails.complete_agent_response_time,
	g_request_id,
	g_program_appl_id,
	g_program_id,
	SYSDATE
	);
    l_counter := l_counter + 1;

        IF(MOD(l_counter,g_commit_chunk_size)=0) THEN
        COMMIT;
        END IF;

END LOOP; -- End of cursor for loop
COMMIT;

 write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                   ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_GROUP_SUMMARY: '||
                   ' finished collecting information into Agent Group Email summary table ' ||
                   'Row Count: '|| l_counter );

EXCEPTION
WHEN OTHERS THEN
g_error_mesg := 'COLLECT_GROUP_SUMMRY: ERROR: '||SQLERRM;
clean_up;
RAISE;
END collect_group_summary;


/*====================================================================+
| In this procedure BIX_DM_EMAIL_AGENT_SUM is summarized to all the   |
| dimensions other than resource and update the BIX_DM_EMAIL_SUM table|
======================================================================*/

PROCEDURE collect_agent_summary
AS
CURSOR agent_email_sum
IS
SELECT
--
--Just summarize everthing by dimensions EXCEPT resource_id
--
EMAIL_ACCOUNT_ID,
CLASSIFICATION_ID,
PERIOD_START_DATE,
PERIOD_START_TIME,
PERIOD_START_DATE_TIME,
SUM(EMAILS_FETCHED) emails_fetched,
SUM(EMAILS_REPLIED) emails_replied,
SUM(EMAILS_REPLIED_WITHIN_GOAL) emails_replied_within_goal,
SUM(EMAILS_DELETED) emails_deleted,
SUM(EMAILS_TRANSFERRED) emails_transferred,
SUM(EMAILS_OPEN) emails_open,
MIN(OLDEST_OPEN_MESSAGE) oldest_open_message,
MIN(OLDEST_OPEN_AGE) oldest_open_age,
SUM(OPEN_AGE) open_age,
SUM(EMAILS_OPEN_DURING_TIME_PERIOD) emails_open_during_time_period,
SUM(EMC_RESPONSE_TIME) emc_response_time,
SUM(COMPLETE_AGENT_RESPONSE_TIME) complete_agent_response_time
FROM bix_dm_email_agent_sum agt_sum
WHERE    agt_sum.period_start_date_time BETWEEN g_rounded_collect_start_date AND g_rounded_collect_end_date
GROUP BY EMAIL_ACCOUNT_ID,
	 CLASSIFICATION_ID,
         PERIOD_START_DATE,
         PERIOD_START_TIME,
         PERIOD_START_DATE_TIME;

l_counter NUMBER := 0;

BEGIN
      write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                                   ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_AGENT_SUMMARY: '||
                                  ' Start updating agent information into Email summary table');

l_counter := l_counter + 1;

FOR agent_sum IN agent_email_sum LOOP


    UPDATE bix_dm_email_sum
    SET emails_fetched = agent_sum.emails_fetched,
        emails_replied = agent_sum.emails_replied,
        emails_replied_within_goal = agent_sum.emails_replied_within_goal,
        emails_deleted = agent_sum.emails_deleted,
        emails_transferred = agent_sum.emails_transferred,
        emails_open = agent_sum.emails_open,
        oldest_open_message = agent_sum.oldest_open_message,
        oldest_open_age = agent_sum.oldest_open_age,
        open_age = agent_sum.open_age,
        emails_open_during_time_period = agent_sum.emails_open_during_time_period,
        emc_response_time = agent_sum.emc_response_time,
        complete_agent_response_time = agent_sum.complete_agent_response_time
    WHERE   email_account_id = agent_sum.email_account_id
    AND     classification_id = agent_sum.classification_id
    AND     period_start_date_time = agent_sum.period_start_date_time;

  IF(SQL%ROWCOUNT = 0) THEN

     INSERT INTO bix_dm_email_sum
	(
	email_summary_id,
	email_account_id,
	classification_id,
	period_start_date,
	period_start_time,
	period_start_date_time,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	emails_fetched,
	emails_replied,
        emails_replied_within_goal,
	emails_deleted,
	emails_transferred,
	emails_open,
	oldest_open_message,
	oldest_open_age,
	open_age,
	emails_open_during_time_period,
	emc_response_time,
        complete_agent_response_time,
	request_id,
	program_application_id,
	program_id,
	program_update_date
	)
	VALUES
	(
	bix_dm_email_sum_s.nextval,
	agent_sum.email_account_id,
	agent_sum.classification_id,
	agent_sum.period_start_date,
	agent_sum.period_start_time,
	agent_sum.period_start_date_time,
	SYSDATE,
	g_user_id,
	SYSDATE,
	g_user_id,
	agent_sum.emails_fetched,
	agent_sum.emails_replied,
	agent_sum.emails_replied_within_goal,
        agent_sum.emails_deleted,
	agent_sum.emails_transferred,
        agent_sum.emails_open,
        agent_sum.oldest_open_message,
        agent_sum.oldest_open_age,
        agent_sum.open_age,
        agent_sum.emails_open_during_time_period,
	agent_sum.emc_response_time,
	agent_sum.complete_agent_response_time,
	g_request_id,
	g_program_appl_id,
	g_program_id,
	SYSDATE
	);
    l_counter := l_counter + 1;
END IF;
        IF(MOD(l_counter,g_commit_chunk_size)=0) THEN
        COMMIT;
        END IF;

END LOOP; -- End of cursor for loop
COMMIT;

 write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                   ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_GROUP_SUMMARY: '||
                   ' finished updating agent information into Email summary table ' );

EXCEPTION
WHEN OTHERS THEN
g_error_mesg := 'COLLECT_AGENT_SUMMRY: ERROR: '||SQLERRM;
clean_up;
RAISE;
END collect_agent_summary;

/*==============================================================================================+
| COLLECT_EMAILS_SUMMARY procedure is main procedure calls other procedures to collect the data |
| The following procedures are invoked from this procedure to collect the data.                 |
| 1. COLLECT_EMAILS           : Which collects all the emails related information               |
| 2. COLLECT_QUEUE_MEASURES  : Collects Queue measures                                          |
| 3. COLLECT_OPEN_MEASURES   : Collects Open measures                                           |
| 4. COLLECT_GROUP_SUMMARY   : summarizes all the agent information to group                    |
| 5. COLLECT_AGENT_SUMMARY   : summarizes all the agent inforation to all the dimension other   |
|                              than resource and update the email table itself                  |
| 5. INSERT_LOG              : Insert the status into BIX_DM_COLLECT_LOG table.                 |
==============================================================================================+*/

PROCEDURE COLLECT_EMAILS_SUMMARY(p_start_date IN VARCHAR2, p_end_date IN VARCHAR2)
AS
l_emc_installed VARCHAR2(1);

BEGIN

l_emc_installed := is_emc_installed();

IF( l_emc_installed = 'Y') THEN

 /* intialize all global variables */

  g_request_id       := FND_GLOBAL.CONC_REQUEST_ID();
  g_program_appl_id  := FND_GLOBAL.PROG_APPL_ID();
  g_program_id       := FND_GLOBAL.CONC_PROGRAM_ID();
  g_user_id          := FND_GLOBAL.USER_ID();
  g_program_start_date := SYSDATE;
  g_error_mesg       := NULL;
  g_status	     := 'FAILED';
  g_proc_name := 'BIX_DM_EMAIL_SUMMARY_PKG';
  g_commit_chunk_size := 5;

  g_collect_start_date := TO_DATE(p_start_date,'YYYY/MM/DD HH24:MI:SS');
  g_collect_end_date   := TO_DATE(p_end_date,'YYYY/MM/DD HH24:MI:SS');

  IF (g_collect_start_date > SYSDATE) THEN
    g_collect_start_date := SYSDATE;
  END IF;

  IF (g_collect_end_date > SYSDATE) THEN
    g_collect_end_date := SYSDATE;
  END IF;

  IF (g_collect_start_date > g_collect_end_date) THEN
    RAISE G_DATE_MISMATCH;
  END IF;

/*
 Round the Collection start date nearest lower time bucket.
 ex: if time is between 10:00 and 10:29 round it to 10:00.
*/

SELECT TO_DATE(
	TO_CHAR(g_collect_start_date,'YYYY/MM/DD')||
	LPAD(TO_CHAR(g_collect_start_date,'HH24:'),3,'0')||
	DECODE(SIGN(TO_NUMBER(TO_CHAR(g_collect_start_date,'MI'))-29),0,'00:00',1,'30:00',-1,'00:00'),
	'YYYY/MM/DDHH24:MI:SS')
INTO g_rounded_collect_start_date
FROM DUAL;

/*
Round the Collection end date to nearest higher time bucket.
ex: if time is between 10:00 and 10:29 round it to 10:29:59
*/

SELECT TO_DATE(
	TO_CHAR(g_collect_end_date,'YYYY/MM/DD')||
	LPAD(TO_CHAR(g_collect_end_date,'HH24:'),3,'0')||
	DECODE(SIGN(TO_NUMBER(TO_CHAR(g_collect_end_date,'MI'))-29),0,'29:59',1,'59:59',-1,'29:59'),
	'YYYY/MM/DDHH24:MI:SS')
INTO g_rounded_collect_end_date
FROM DUAL;


/*
dbms_output.put_line('Collection End Date: ' ||
				   to_char(g_rounded_collect_end_date,'YYYY/MM/DD HH24:MI:SS'));
*/

/*
 Get the commit size from the profile value.
 if the profile is not defined assume commit size as 100
*/

/*
IF (FND_PROFILE.DEFINED('BIX_DM_DELETE_SIZE')) THEN
   g_commit_chunk_size := TO_NUMBER(FND_PROFILE.VALUE('BIX_DM_DELETE_SIZE'));
ELSE
   g_commit_chunk_size := 100;
END IF;
*/

IF (FND_PROFILE.DEFINED('BIX_DBI_DEBUG')) THEN
    g_debug_flag := nvl(FND_PROFILE.VALUE('BIX_DBI_DEBUG'), 'N');
END IF;

--dbms_output.put_line('Commit SIZE: '|| g_commit_chunk_size);

/* Procedure collects all the Email measures information from JTF_IH tables */

--dbms_output.put_line('before COLLECT_EMAILS');

  collect_emails;

--dbms_output.put_line('After COLLECT_EMAILS');

/* Collect Queue measures  */

 collect_queue_measures;

/* Collect Open Email measures  */

--dbms_output.put_line('Before COLLECT_OPEN_MEASURES');

collect_open_measures;

--dbms_output.put_line('After COLLECT_OPEN_MEASURES');

/* this procedure summarises agent related measures by resource group which they belong to  */

collect_group_summary;

/* Summarise all the measures in the agent table by all the dimensions
  except agent and update in email summary table */

collect_agent_summary;

/* Insert the status into BIX_DM_COLLECT_LOG table */

  g_status := 'SUCCESS';
  insert_log;
ELSE
  write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                       ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_EMAILS_SUMMARY : ' ||
     'Email Application is not installed. ');
END IF;
  EXCEPTION
  WHEN G_DATE_MISMATCH THEN
    write_log('Collect Start Date cannot be greater than collection end date');
  WHEN OTHERS THEN
        IF ( g_error_mesg IS NULL) THEN
	    g_error_mesg := 'COLLECT_EMAILS_SUMMRY: ERROR: '||SQLERRM;
	    clean_up;
            RAISE;
        ELSE
           RAISE;
        END IF;
END COLLECT_EMAILS_SUMMARY;

/*==============================================================================================+
| COLLECT_EMAILS_SUMMARY procedure is main procedure calls other procedures to collect the data |
| The following procedures are invoked from this procedure to collect the data.                 |
| 1. COLLECT_EMAILS           : Which collects all the emails related information               |
| 2. COLLECT_QUEUE_MEASURES  : Collects Queue measures                                          |
| 3. COLLECT_OPEN_MEASURES   : Collects Open measures                                           |
| 4. COLLECT_GROUP_SUMMARY   : summarizes all the agent information to group                    |
| 5. COLLECT_AGENT_SUMMARY   : summarizes all the agent inforation to all the dimension other   |
|                              than resource and update the email table itself                  |
| 5. INSERT_LOG              : Insert the status into BIX_DM_COLLECT_LOG table.                 |
==============================================================================================+*/


PROCEDURE COLLECT_EMAILS_SUMMARY(errbuf out nocopy varchar2,
						   retcode out nocopy varchar2,
						   p_start_date IN VARCHAR2,
						   p_end_date   IN VARCHAR2)
AS
l_emc_installed VARCHAR2(1);

  BEGIN

/* Check weather EMC Application is installed or not */

  l_emc_installed := is_emc_installed();

IF( l_emc_installed = 'Y') THEN

 /* intialize all global variables */

  g_request_id       := FND_GLOBAL.CONC_REQUEST_ID();
  g_program_appl_id  := FND_GLOBAL.PROG_APPL_ID();
  g_program_id       := FND_GLOBAL.CONC_PROGRAM_ID();
  g_user_id          := FND_GLOBAL.USER_ID();
  g_program_start_date := SYSDATE;
  g_error_mesg       := NULL;
  g_status	     := 'FAILED';
  g_proc_name := 'BIX_DM_EMAIL_SUMMARY_PKG';
  g_commit_chunk_size := 100;

  g_collect_start_date := TO_DATE(p_start_date,'YYYY/MM/DD HH24:MI:SS');
  g_collect_end_date   := TO_DATE(p_end_date,'YYYY/MM/DD HH24:MI:SS');

  IF (g_collect_start_date > SYSDATE) THEN
    g_collect_start_date := SYSDATE;
  END IF;

  IF (g_collect_end_date > SYSDATE) THEN
    g_collect_end_date := SYSDATE;
  END IF;

  IF (g_collect_start_date > g_collect_end_date) THEN
    RAISE G_DATE_MISMATCH;
  END IF;

/*
 Round the Collection start date nearest lower time bucket.
 ex: if time is between 10:00 and 10:29 round it to 10:00.
*/

SELECT TO_DATE(
	TO_CHAR(g_collect_start_date,'YYYY/MM/DD')||
	LPAD(TO_CHAR(g_collect_start_date,'HH24:'),3,'0')||
	DECODE(SIGN(TO_NUMBER(TO_CHAR(g_collect_start_date,'MI'))-29),0,'00:00',1,'30:00',-1,'00:00'),
	'YYYY/MM/DDHH24:MI:SS')
INTO g_rounded_collect_start_date
FROM DUAL;

/*
Round the Collection end date to nearest higher time bucket.
ex: if time is between 10:00 and 10:29 round it to 10:29:59
*/

SELECT TO_DATE(
	TO_CHAR(g_collect_end_date,'YYYY/MM/DD')||
	LPAD(TO_CHAR(g_collect_end_date,'HH24:'),3,'0')||
	DECODE(SIGN(TO_NUMBER(TO_CHAR(g_collect_end_date,'MI'))-29),0,'29:59',1,'59:59',-1,'29:59'),
	'YYYY/MM/DDHH24:MI:SS')
INTO g_rounded_collect_end_date
FROM DUAL;

/*
dbms_output.put_line('Collection End Date: ' ||
				    to_char(g_rounded_collect_end_date,'YYYY/MM/DD HH24:MI:SS'));
*/

/*
 Get the commit size from the profile value.
 if the profile is not defined assume commit size as 100
*/


IF (FND_PROFILE.DEFINED('BIX_DM_DELETE_SIZE')) THEN
   g_commit_chunk_size := TO_NUMBER(FND_PROFILE.VALUE('BIX_DM_DELETE_SIZE'));
ELSE
   g_commit_chunk_size := 100;
END IF;


IF (FND_PROFILE.DEFINED('BIX_DBI_DEBUG')) THEN
    g_debug_flag := nvl(FND_PROFILE.VALUE('BIX_DBI_DEBUG'), 'N');
END IF;

--dbms_output.put_line('Commit SIZE: '|| g_commit_chunk_size);

/* Procedure collects all the Email measures information from JTF_IH tables */

--dbms_output.put_line('before COLLECT_EMAILS');

  collect_emails;

--dbms_output.put_line('After COLLECT_EMAILS');

/* Collect Queue measures  */

  collect_queue_measures;

/* Collect Open Email measures  */

--dbms_output.put_line('Before COLLECT_OPEN_MEASURES');

  collect_open_measures;

--dbms_output.put_line('After COLLECT_OPEN_MEASURES');

/* this procedure summarises agent related measures by resource group which they belong to  */

collect_group_summary;

/* Summarise all the measures in the agent table by all the dimensions
  except agent and update in email summary table */

collect_agent_summary;

/* Insert the status into BIX_DM_COLLECT_LOG table */

  g_status := 'SUCCESS';
    insert_log;
  retcode := NULL;
  errbuf  := NULL;
ELSE
  write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                       ' BIX_DM_EMAIL_SUMMARY_PKG.COLLECT_EMAILS_SUMMARY : ' ||
     'Email Application is not installed. ');
END IF;

  EXCEPTION
  WHEN G_DATE_MISMATCH THEN
    retcode := -1;
    errbuf := 'Collect Start Date cannot be greater than collection end date';
    write_log('Collect Start Date cannot be greater than collection end date');
  WHEN OTHERS THEN
      IF ( g_error_mesg IS NULL) THEN
	retcode := SQLCODE;
	errbuf := SQLERRM;
	g_error_mesg := 'COLLECT_EMAILS_SUMMARY: ERROR: '||SQLERRM;
	clean_up;
        RAISE;
      ELSE
         RAISE;
      END IF;
END COLLECT_EMAILS_SUMMARY;

END BIX_DM_EMAIL_SUMMARY_PKG;

/
