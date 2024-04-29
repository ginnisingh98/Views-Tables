--------------------------------------------------------
--  DDL for Package Body BIX_POP_AO_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_POP_AO_SUM_PKG" AS
/* $Header: bixxaosb.plb 115.4 2003/01/09 20:20:20 achanda noship $ */

  g_request_id                  NUMBER := FND_GLOBAL.CONC_REQUEST_ID();
  g_program_appl_id             NUMBER := FND_GLOBAL.PROG_APPL_ID();
  g_program_id                  NUMBER := FND_GLOBAL.CONC_PROGRAM_ID();
  g_user_id                     NUMBER := FND_GLOBAL.USER_ID();
  g_program_start_date          DATE := SYSDATE;
  g_collect_start_date          DATE ;
  g_collect_end_date            DATE ;
  g_error_mesg                  VARCHAR2(4000)  := NULL;
  g_status                      VARCHAR2(50)  := 'FAILURE';
  g_commit_chunk_size           NUMBER := 100;
  g_ao_installed                CHAR;
  g_delete_count                NUMBER := 0;
  g_insert_count                NUMBER := 0;

/*===================================================================================================+
| INSERT_LOG procedure inserts collection concurrent program status into BIX_DM_COLLECT_LOG table     |
| It inserts a row with the following details :                                                       |
|                                                                                                     |
| COLLECT_STATUS column equals to  FAILURE if the program failed otherwise SUCCESS                    |
| COLLECT_EXCEP_MESG as error message if the program failed otherwise NULL                            |
| RUN_START_DATE equals to start date time when  the collection program started runnning              |
| RUN_END_DATE  equals  end date time of the collection program finished                              |
| COLLECT_START_DATE Collection start date specified by the user in the cuncurrent program parameter  |
| COLLECT_END_DATE Collection end date specified by the user in the cuncurrent program parameter      |
====================================================================================================+*/

PROCEDURE INSERT_LOG
AS
BEGIN
      fnd_file.put_line(fnd_file.log,TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                         ' BIX_POP_AO_SUM_PKG.INSERT_LOG:' ||
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
        ROWS_INSERTED,
        ROWS_DELETED,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE
        )
        VALUES
        (
        BIX_DM_COLLECT_LOG_S.NEXTVAL,
        NULL,
        'BIX_DM_ADVANCED_OUTBOUND_SUM',
        'TABLE',
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
        g_insert_count,
        g_delete_count,
        g_request_id,
        g_program_appl_id,
        g_program_id,
        SYSDATE
        );
 COMMIT;

  fnd_file.put_line(fnd_file.log,TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                     ' BIX_POP_AO_SUM_PKG.INSERT_LOG:'||
                     'Finished inserting collection status into BIX_DM_COLLECT_LOG table');
  EXCEPTION
  WHEN OTHERS THEN
   fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                      'BIX_POP_AO_SUM_PKG.INSERT_LOG:  ' ||
                      ' Failed to insert rows into BIX_DM_COLLECT_LOG table: '|| sqlerrm);
  RAISE;
  END INSERT_LOG;

/*===================================================================================================+
| CLEAN_UP procedure writes error message into FND log file,Rollback the data written into AO        |
| summary tables and also calls INSERT_LOG procedure to log error messge in BIX_DM_COLLECT_LOG table |
+===================================================================================================*/

PROCEDURE clean_up IS
	BEGIN
	fnd_file.put_line(fnd_file.log,TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||g_error_mesg);
        fnd_file.put_line(fnd_file.log,TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                          'Start rolling back from BIX_DM_ADVANCED_OUTBOUND_SUMtable ');

/* Delete from AO summary table */

  LOOP
	DELETE bix_dm_advanced_outbound_sum
	WHERE  last_update_date > g_program_start_date
        AND  rownum <= g_commit_chunk_size ;

     IF(SQL%ROWCOUNT < g_commit_chunk_size) THEN
        COMMIT;
        EXIT;
     ELSE
	   COMMIT;
     END IF;

 END LOOP;

    fnd_file.put_line(fnd_file.log,TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                 	    ' BIX_POP_AO_SUM_PKG.CLEAN_UP: '||
			    ' Finished  rollback from BIM_DM_AO_SUM table: ' );

   INSERT_LOG;

	EXCEPTION
	WHEN OTHERS THEN
	fnd_file.put_line(fnd_file.log,TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
			   'CLEAN_UP:  ERROR: '||  SQLERRM);
	RAISE;
END CLEAN_UP;


PROCEDURE populate(p_start_date_time in date, p_end_date_time in date) AS

   CURSOR ao_sum IS
    SELECT
       campaign_schedule_id,
       source_list_id ,
       sublist_id,
       period_start_date,
       period_start_time,
       period_start_date_time,
       COUNT(DISTINCT resource_id) agent_work_on,
       SUM(DECODE(row_type,'C',1,0)) DIALED,
       SUM(DECODE(outcome_id,7,1,0)) connected,
       SUM(DECODE(outcome_id,11,1,0)) abandoned,
       SUM(DECODE(outcome_id,2,1,0)) busy,
       SUM(DECODE(outcome_id,1,1,0)) ring_no_ansewr,
       SUM(DECODE(outcome_id,6,1,0)) answering_machine,
       SUM(DECODE(outcome_id,22,1,23,1,24,1,25,1,0)) sit,
       SUM(out_talk_time) talk_time,
       SUM(out_wrap_time) wrap_time,
       SUM(leads_created) leads_created,
       SUM(LEADS_AMOUNT) leads_amount,
       SUM(LEADS_AMOUNT_TXN) leads_amount_txn,
       SUM(OPPORTUNITIES_WON + OPPORTUNITIES_CROSS_SOLD + OPPORTUNITIES_UP_SOLD) OPPORTUNITIES_WON,
       SUM(OPPORTUNITIES_WON_AMOUNT) OPPORTUNITIES_WON_AMOUNT,
       SUM(OPPORTUNITIES_WON_AMOUNT_TXN) OPPORTUNITIES_WON_AMOUNT_TXN
    FROM   BIX_DM_INTERFACE
    WHERE  direction = 1    --OUTBOUND
    AND    period_start_date_time BETWEEN  p_start_date_time AND p_end_date_time
    GROUP BY
       campaign_schedule_id,
       source_list_id ,
       sublist_id,
       period_start_date,
       period_start_time,
       period_start_date_time;

  TYPE campaign_schedule_id IS TABLE OF bix_dm_advanced_outbound_sum.campaign_schedule_id%TYPE;
  TYPE source_list_id IS TABLE OF bix_dm_advanced_outbound_sum.source_list_id%TYPE;
  TYPE sublist_id  IS TABLE OF bix_dm_advanced_outbound_sum.sublist_id%TYPE;
  TYPE period_start_date IS TABLE OF bix_dm_advanced_outbound_sum.period_start_date%TYPE;
  TYPE period_start_time IS TABLE OF bix_dm_advanced_outbound_sum.period_start_time%TYPE;
  TYPE period_start_date_time IS TABLE OF bix_dm_advanced_outbound_sum.period_start_date_time%TYPE;
  TYPE agent_work_on IS TABLE OF bix_dm_advanced_outbound_sum.agent_work_on%TYPE;
  TYPE talk_time IS TABLE OF bix_dm_advanced_outbound_sum.talk_time%TYPE;
  TYPE wrap_time IS TABLE OF bix_dm_advanced_outbound_sum.wrap_time%TYPE;
  TYPE leads_created IS TABLE OF bix_dm_advanced_outbound_sum.leads_created%TYPE;
  TYPE leads_amount IS TABLE OF bix_dm_advanced_outbound_sum.leads_amount%TYPE;
  TYPE leads_amount_txn IS TABLE OF bix_dm_advanced_outbound_sum.leads_amount_txn%TYPE;
  TYPE opportunities_won IS TABLE OF bix_dm_advanced_outbound_sum.opportunities_won%TYPE;
  TYPE opportunities_won_amount IS TABLE OF bix_dm_advanced_outbound_sum.opportunities_won_amount%TYPE;
  TYPE opportunities_won_amount_txn IS TABLE OF bix_dm_advanced_outbound_sum.opportunities_won_amount_txn%TYPE;
  TYPE dialed IS TABLE OF bix_dm_advanced_outbound_sum.dialed_count%TYPE;
  TYPE connected IS TABLE OF bix_dm_advanced_outbound_sum.connected_count%TYPE;
  TYPE abandoned IS TABLE OF bix_dm_advanced_outbound_sum.abandoned_count%TYPE;
  TYPE busy IS TABLE OF bix_dm_advanced_outbound_sum.busy_count%TYPE;
  TYPE ring_no_answer IS TABLE OF bix_dm_advanced_outbound_sum.ring_no_answer_count%TYPE;
  TYPE answering_machine IS TABLE OF bix_dm_advanced_outbound_sum.answering_machine_count%TYPE;
  TYPE sit IS TABLE OF bix_dm_advanced_outbound_sum.sit_count%TYPE;


  l_campaign_schedule_id campaign_schedule_id;
  l_source_list_id source_list_id;
  l_sublist_id sublist_id;
  l_period_start_date period_start_date;
  l_period_start_time period_start_time;
  l_period_start_date_time period_start_date_time;
  l_agent_work_on agent_work_on;
  l_talk_time talk_time;
  l_wrap_time wrap_time;
  l_leads_created leads_created;
  l_leads_amount leads_amount;
  l_leads_amount_txn leads_amount_txn;
  l_opportunities_won opportunities_won;
  l_opportunities_won_amount opportunities_won_amount;
  l_opportunities_won_amount_txn opportunities_won_amount_txn;
  l_dialed dialed;
  l_connected  connected;
  l_abandoned abandoned;
  l_busy busy;
  l_ring_no_answer ring_no_answer;
  l_answering_machine answering_machine;
  l_sit sit;

BEGIN

  /* get the commit chunk size */

    IF (FND_PROFILE.DEFINED('BIX_DM_DELETE_SIZE')) THEN
      g_commit_chunk_size := TO_NUMBER(FND_PROFILE.VALUE('BIX_DM_DELETE_SIZE'));
    ELSE
      g_commit_chunk_size := 100;
    END IF;

  g_collect_start_date := p_start_date_time;
  g_collect_end_date  := p_end_date_time;

     fnd_file.put_line(fnd_file.log,TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                                   ' BIX_POP_AO_SUM_PKG.POPULATE: '||
                                   ' Start  Deleting rows in BIM_DM_AO_SUM table: ' );
 LOOP
       --dbms_output.put_line('Start deleting................');
        DELETE bix_dm_advanced_outbound_sum
        WHERE PERIOD_START_DATE_TIME >= p_start_date_time
        AND   PERIOD_START_DATE_TIME <= p_end_date_time
        AND  rownum <= g_commit_chunk_size ;

     IF(SQL%ROWCOUNT < g_commit_chunk_size) THEN
        g_delete_count := g_delete_count + SQL%ROWCOUNT;
        COMMIT;
        EXIT;
     ELSE
           g_delete_count := g_delete_count + SQL%ROWCOUNT;
           COMMIT;
     END IF;
 END LOOP;

     fnd_file.put_line(fnd_file.log,TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                                   ' BIX_POP_AO_SUM_PKG.POPULATE: '||
                                   ' Finished  Deleting rows in BIM_DM_AO_SUM table: '||
                                   'Row count: ' || g_delete_count );
 OPEN ao_sum;

     fnd_file.put_line(fnd_file.log,TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                                   ' BIX_POP_AO_SUM_PKG.POPULATE: '||
                                   ' Start  inserting rows in BIM_DM_AO_SUM table: ' );

 LOOP

  FETCH ao_sum  BULK COLLECT INTO
  l_campaign_schedule_id,
  l_source_list_id,
  l_sublist_id,
  l_period_start_date,
  l_period_start_time,
  l_period_start_date_time,
  l_agent_work_on,
  l_dialed,
  l_connected,
  l_abandoned,
  l_busy,
  l_ring_no_answer,
  l_answering_machine,
  l_sit,
  l_talk_time,
  l_wrap_time,
  l_leads_created,
  l_leads_amount,
  l_leads_amount_txn,
  l_opportunities_won,
  l_opportunities_won_amount,
  l_opportunities_won_amount_txn
  LIMIT g_commit_chunk_size;

 --dbms_output.put_line('number of rows: ' || l_campaign_schedule_id.COUNT);

 IF( l_campaign_schedule_id.COUNT > 0) THEN
 FORALL i IN l_campaign_schedule_id.FIRST .. l_campaign_schedule_id.LAST

	INSERT INTO  BIX_DM_ADVANCED_OUTBOUND_SUM
	(
	 ADVANCED_OUTBOUND_ID,
	 CAMPAIGN_SCHEDULE_ID,
	 SOURCE_LIST_ID,
	 SUBLIST_ID,
	 PERIOD_START_DATE,
	 PERIOD_START_TIME,
	 PERIOD_START_DATE_TIME,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 AGENT_WORK_ON,
	 DIALED_COUNT,
	 CONNECTED_COUNT,
	 ABANDONED_COUNT,
	 BUSY_COUNT,
	 RING_NO_ANSWER_COUNT,
	 ANSWERING_MACHINE_COUNT,
	 SIT_COUNT,
	 TALK_TIME,
	 WRAP_TIME,
	 LEADS_CREATED,
	 LEADS_AMOUNT,
	 LEADS_AMOUNT_TXN,
	 OPPORTUNITIES_WON,
	 OPPORTUNITIES_WON_AMOUNT,
	 OPPORTUNITIES_WON_AMOUNT_TXN,
	 REQUEST_ID,
	 PROGRAM_APPLICATION_ID,
	 PROGRAM_ID,
	 PROGRAM_UPDATE_DATE
	 )
	VALUES (
	bix_dm_advanced_outbound_sum_s.NEXTVAL,
	l_campaign_schedule_id(i),
	l_source_list_id(i),
	l_sublist_id(i),
	l_period_start_date(i),
	l_period_start_time(i),
	l_period_start_date_time(i),
	SYSDATE,
	g_user_id ,
	SYSDATE,
	g_user_id,
	l_agent_work_on(i),
	l_dialed(i),
	l_connected(i),
	l_abandoned(i),
	l_busy(i),
	l_ring_no_answer(i),
	l_answering_machine(i),
	l_sit(i),
	l_talk_time(i),
	l_wrap_time(i),
	l_leads_created(i),
	l_leads_amount(i),
	l_leads_amount_txn(i),
	l_opportunities_won(i),
	l_opportunities_won_amount(i),
	l_opportunities_won_amount_txn(i),
	g_request_id,
	g_program_appl_id,
	g_program_id,
	SYSDATE
	);

     g_insert_count := g_insert_count + l_campaign_schedule_id.COUNT;
 END IF;

     EXIT WHEN ao_sum%NOTFOUND;

   END LOOP;
     fnd_file.put_line(fnd_file.log,TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||
                                   ' BIX_POP_AO_SUM_PKG.POPULATE: '||
                                   ' finished inserting rows in BIM_DM_AO_SUM table: ' );
 g_status := 'SUCCESS';
 insert_log;

 EXCEPTION
   WHEN OTHERS THEN
      g_error_mesg :=  'BIX_POP_AO_SUM_PKG.POPULATE:  ERROR: '|| sqlerrm;
      g_status := 'FAILURE';
      clean_up;
END populate;

END BIX_POP_AO_SUM_PKG;

/
