--------------------------------------------------------
--  DDL for Package Body BIX_CALL_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_CALL_UPDATE_PKG" AS
/*$Header: bixcaupd.plb 120.2 2005/09/09 15:22:28 anasubra noship $ */

  g_request_id                  NUMBER;
  g_program_appl_id             NUMBER;
  g_program_id                  NUMBER;
  g_user_id                     NUMBER;
  g_bix_schema                  VARCHAR2(30) := 'BIX';
  g_rows_ins_upd                NUMBER;
  g_commit_chunk_size           NUMBER;
  g_no_of_jobs                  NUMBER := 0;
  g_required_workers            NUMBER := 0;
  g_collect_start_date          DATE;
  g_collect_end_date            DATE;
  g_sysdate                     DATE;
  g_debug_flag                  VARCHAR2(1)  := 'N';

  g_errbuf                      VARCHAR2(1000);
  g_retcode                     VARCHAR2(10) := 'S';

  MAX_LOOP CONSTANT             NUMBER := 180;

  G_TIME_DIM_MISSING            EXCEPTION;
  G_CHILD_PROCESS_ISSUE         EXCEPTION;
  G_OLTP_CLEANUP_ISSUE          EXCEPTION;

  TYPE WorkerList is table of NUMBER index by binary_integer;
  g_worker WorkerList;

  TYPE ProcRec IS RECORD
  (
  media_id NUMBER,
  name VARCHAR2(100),
  value1 NUMBER,
  value2 VARCHAR2(10)
  );

  TYPE ProcTable IS TABLE OF ProcRec;

  l_proc_table ProcTable;

PROCEDURE write_Log (p_msg IN VARCHAR2
                    ) IS
BEGIN

  --IF (g_debug_flag = 'Y') THEN
    BIS_COLLECTION_UTILITIES.log(p_msg);
    --BIS_COLLECTION_UTILITIES.log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --p_msg);

	--fnd_file.put_line(fnd_file.log,TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||  ' : '||p_msg);

	--insert into bixtest
	--values(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||' : '||p_msg);
	--commit;

  --END IF;

--g_test:=g_test+1;
  --insert into bixtest values(to_char(sysdate,'HH:MI:SS')||':'||p_msg);
  --commit;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Write_Log;

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

--
--IEU Session History Cleanup
--
--BEGIN
   --g_errbuf := NULL;
   --g_retcode := 'S';
   --IEU_SH_CON_PVT.IEU_SH_END_IDLE_TRANS(g_errbuf, g_retcode);
--
   --IF g_retcode <> 'S'
   --THEN
      --RAISE G_OLTP_CLEANUP_ISSUE;
   --END IF;
--
--EXCEPTION
--WHEN OTHERS THEN
   --write_log('Timeout Media Items exited with: ' ||g_retcode || ' error buffer is: ' || g_errbuf);
   --RAISE G_OLTP_CLEANUP_ISSUE;
--END;

END cleanup_oltp;

PROCEDURE INSERT_DNIS
IS

BEGIN

INSERT /*+ APPEND */ INTO BIX_DM_DNIS
(
dnis_id, dnis, last_update_date, last_updated_by, creation_date
)
SELECT BIX_DM_DNIS_S.NEXTVAL, DNIS, g_sysdate, g_user_id, g_sysdate
FROM
(
   SELECT DISTINCT decode(DIRECTION, 'OUTBOUND', 'OUTBOUND', DNIS) DNIS
   FROM BIX_MEDIAS_FOR_WORKER WORK
   WHERE NOT EXISTS
      (SELECT 1
       FROM BIX_DM_DNIS DNIS
       WHERE WORK.DNIS = DNIS.DNIS
       )
   AND DNIS IS NOT NULL
);

COMMIT;

EXCEPTION
WHEN OTHERS THEN
   NULL;

END INSERT_DNIS;

--Start 002
--Commenting out these two procedures as the
--values returned by these are not used anywhere in ICI.
/*********************
PROCEDURE GET_LEAD_AMOUNT ( p_lead_id in number,
				p_leads_amount out NOCOPY NUMBER,
				p_currency_code out NOCOPY varchar2
			) is

BEGIN


select budget_amount,currency_code into p_leads_amount, p_currency_code
from as_sales_leads where SALES_LEAD_ID = p_lead_id;


EXCEPTION
        WHEN OTHERS THEN
		p_leads_amount := 0;
		 p_currency_code := NULL;
END;
-- Opportunity amount:

procedure GET_OPPORTUNITY_AMOUNT ( p_opp_id in NUMBER,
				 p_opp_won out NOCOPY NUMBER,
				 p_opp_amount out NOCOPY NUMBER,
				 p_currency_code out NOCOPY varchar2) is

BEGIN

select total_amount,currency_code,1 into
p_opp_amount, p_currency_code,p_opp_won
from
as_leads_all a,
as_statuses_vl asv
where a.lead_id = p_opp_id and
a.status = asv.status_code and
asv.win_loss_indicator = 'W';


EXCEPTION
        WHEN OTHERS THEN
                p_opp_amount := 0;
                 p_currency_code := NULL;
		p_opp_won := 0;
END;
**********/
--End 002
--Commenting out these two procedures as the
--values returned by these are not used anywhere in ICI.

PROCEDURE mark_as_processed (
                             p_media_id NUMBER,
			     p_name VARCHAR2,
			     p_value1 NUMBER,
                             p_value2 VARCHAR2
			   )
IS

BEGIN

NULL;
--INSERT INTO BIX_CALL_PROCESSED_RECS
--(media_id, name, value1, value2)
--VALUES (p_media_id, p_name, p_value1, p_value2);

l_proc_table.extend();
l_proc_table(l_proc_table.count).media_id := p_media_id;
l_proc_table(l_proc_table.count).name     := p_name;
l_proc_table(l_proc_table.count).value1   := p_value1;
l_proc_table(l_proc_table.count).value2   := p_value2;

--IF g_debug_flag = 'Y'
--THEN
--write_log('Values in l_proc_table are: ' ||
		 --'Media id: ' ||l_proc_table(l_proc_table.count).media_id ||
		 --'Name    : ' ||l_proc_table(l_proc_table.count).name     ||
		 --'Value 1 : ' ||l_proc_table(l_proc_table.count).value1   ||
		 --'Value 2 : ' ||l_proc_table(l_proc_table.count).value2);
--END IF;
--COMMIT;

END;

FUNCTION check_if_processed (
                             p_media_id NUMBER,
			     p_name  VARCHAR2,
			     p_value1 NUMBER,
                             p_value2 VARCHAR2
			     )
RETURN VARCHAR2
IS

l_count NUMBER;
l_agent_flag VARCHAR2(1);
l_both_flag VARCHAR2(1);

BEGIN

l_count := 0;

  IF p_value1 IS NULL AND p_value2 IS NULL
  THEN
     RETURN 'Y';
  END IF;

IF p_name <> 'BUCKET' AND p_name <> 'AGENT_BUCKET'
THEN

FOR x IN l_proc_table.FIRST .. l_proc_table.LAST
LOOP
   IF l_proc_table(x).media_id = p_media_id
   AND l_proc_table(x).name = p_name
   AND l_proc_table(x).value1 = p_value1
   THEN
	 RETURN 'Y';
   END IF;
END LOOP;

ELSIF p_name = 'AGENT_BUCKET'
THEN

FOR x IN l_proc_table.FIRST .. l_proc_table.LAST
LOOP
   IF l_proc_table(x).media_id = p_media_id
   AND l_proc_table(x).name = p_name
   AND l_proc_table(x).value1 = p_value1
   AND l_proc_table(x).value2 = p_value2
   THEN
	 l_both_flag := 'B'; -- this means both agent and bucket matched
   END IF;

   IF l_proc_table(x).media_id = p_media_id
   AND l_proc_table(x).name = p_name
   AND l_proc_table(x).value1 = p_value1
   --AND l_proc_table(x).value2 = p_value2 -- dont check for bucket here
   THEN
	 l_agent_flag := 'A'; -- this means only agent matched
   END IF;
END LOOP;

IF l_both_flag = 'B'
THEN
   RETURN 'B';
ELSIF l_agent_flag = 'A'
THEN
   RETURN 'A';
END IF;

ELSE

--SELECT count(*)
--INTO l_count
--FROM BIX_CALL_PROCESSED_RECS
--WHERE name = p_name
--AND value2 = p_value2
--AND media_id = p_media_id;

FOR x IN l_proc_table.FIRST .. l_proc_table.LAST
LOOP
   IF l_proc_table(x).media_id = p_media_id
   AND l_proc_table(x).name = p_name
   AND l_proc_table(x).value2 = p_value2
   THEN
	 RETURN 'Y';
   END IF;
END LOOP;

END IF;

--IF l_count  > 0
--THEN
  --IF (g_debug_flag = 'Y') THEN
--write_log ('Count > 0');
  --END IF;
   --RETURN 'Y';
--ELSE
  --IF (g_debug_flag = 'Y') THEN
--write_log ('Count = 0');
  --END IF;
   --RETURN 'N';
--END IF;

RETURN 'N';

EXCEPTION
WHEN OTHERS
THEN
  --IF (g_debug_flag = 'Y') THEN
--write_log('Exception in check_if_processed');
  --END IF;
   RETURN 'N';

END check_if_processed;

PROCEDURE get_campaign_details (
                                p_media_id       IN  NUMBER,
                                p_direction      IN  VARCHAR2,
                                p_source_item_id IN  NUMBER,
                                p_source_code    IN  VARCHAR2,
                                p_campaign_id    OUT NOCOPY  NUMBER,
                                p_schedule_id    OUT NOCOPY NUMBER,
                                p_source_code_id OUT NOCOPY NUMBER,
						  p_dialing_method OUT NOCOPY VARCHAR2
                               )
IS

l_source_code_for VARCHAR2(50);

BEGIN

  --IF (g_debug_flag = 'Y') THEN
--write_log('Called get_campaign_details with source_code ' || p_source_code ||
          --'media id ' || p_media_id ||
          --'source item id ' || p_source_item_id ||
          --'direction ' || p_direction
         --);
  --END IF;


--002 , Commenting out the IF...else Block processing as
--      outbound is not needed and so no point in processing
--      an "IF" statement

--IF p_direction = 'INBOUND' 002
--THEN 002

   p_dialing_method := 'N/A';

   --
   --For AI calls use the source_code from interactions table
   --
   SELECT source_code_id, ARC_SOURCE_CODE_FOR
   INTO   p_source_code_id, l_source_code_for
   FROM   ams_source_codes
   WHERE  source_code = p_source_code;

   if l_source_code_for = 'CAMP' then
      select campaign_id
      into p_campaign_id
      from ams_campaigns_all_b
      where source_code = p_source_code;

      p_schedule_id := NULL;

   elsif l_source_code_for = 'CSCH'
   then
      select schedule_id, campaign_id
      into p_schedule_id, p_campaign_id
      from AMS_CAMPAIGN_SCHEDULES_B
      where source_code = p_source_code;

   else
      p_campaign_id := NULL;
      p_schedule_id := NULL;
   end if;

--Start 002
/******
ELSIF p_direction = 'OUTBOUND'
THEN
   --
   --For AO calls use a different path
   --

select c.campaign_id,c.schedule_id, code.source_code_id, d.dialing_method
INTO p_campaign_id,p_schedule_id,p_source_code_id,p_dialing_method
from iec_g_list_subsets a,
     ams_act_lists b,
     AMS_CAMPAIGN_SCHEDULES_B c,
     ams_list_headers_all d,
     ams_source_codes code
where
a.list_header_id = b.list_header_id AND
b.list_used_by_id = c.schedule_id AND
b.list_act_type = 'TARGET' AND
b.list_used_by = 'CSCH' AND
b.list_header_id = d.list_header_id AND
a.list_subset_id = p_source_item_id AND
code.source_code = c.source_code;

END IF;

*********/
--End 002

EXCEPTION
WHEN OTHERS
THEN
   p_campaign_id    := NULL;
   p_schedule_id    := NULL;
   p_source_code_id := NULL;
   p_dialing_method := 'N/A';

END get_campaign_details;

PROCEDURE get_segment_details    (p_media_id IN NUMBER,
                                 p_resource_id IN NUMBER,
                                 p_milcs_id IN NUMBER,
                                 p_final_segment OUT NOCOPY VARCHAR2,
                                 p_max_talk_end_date_time OUT NOCOPY DATE
                                 )
IS

l_max_milcs_id NUMBER;

BEGIN

SELECT max(milcs_id), max(end_date_time)
INTO l_max_milcs_id, p_max_talk_end_date_time
FROM JTF_IH_MEDIA_ITEM_LC_SEGS SEGS, JTF_IH_MEDIA_ITM_LC_SEG_TYS TYPES
WHERE media_id = p_media_id
AND resource_id = p_resource_id
AND SEGS.milcs_type_id = TYPES.milcs_type_id
AND milcs_code = 'WITH_AGENT';

IF l_max_milcs_id = p_milcs_id
THEN
   p_final_segment := 'Y';
ELSE
   p_final_segment := 'N';
END IF;

EXCEPTION
WHEN OTHERS
THEN
   RAISE;

END get_segment_details;

PROCEDURE get_media_details (p_media_id       IN  NUMBER,
                             p_has_agent_segs OUT NOCOPY VARCHAR2,
                             p_earliest_agent OUT NOCOPY NUMBER,
                             p_min_talk_start OUT NOCOPY DATE,
                             p_max_talk_end   OUT NOCOPY DATE
                             )
IS

l_agent_segments NUMBER := 0;

BEGIN

SELECT min(resource_id)
INTO   p_earliest_agent
FROM   JTF_IH_MEDIA_ITEM_LC_SEGS SEGS, JTF_IH_MEDIA_ITM_LC_SEG_TYS TYPES
WHERE  SEGS.media_id = p_media_id
AND    SEGS.milcs_type_id = TYPES.milcs_type_id
AND    TYPES.milcs_code = 'WITH_AGENT'
AND    SEGS.start_date_time = (select min(start_date_time)
                          FROM   JTF_IH_MEDIA_ITEM_LC_SEGS SEGS,
                                 JTF_IH_MEDIA_ITM_LC_SEG_TYS TYPES
                          WHERE  SEGS.media_id = p_media_id
                          AND    SEGS.milcs_type_id = TYPES.milcs_type_id
                          AND    TYPES.milcs_code = 'WITH_AGENT'
                          );

IF p_earliest_agent IS NOT NULL
THEN
   p_has_agent_segs := 'Y';
ELSE
   p_has_agent_segs := 'N';
END IF;

SELECT min(start_date_time), max(end_date_time)
INTO   p_min_talk_start, p_max_talk_end
FROM   JTF_IH_MEDIA_ITEM_LC_SEGS SEGS,
       JTF_IH_MEDIA_ITM_LC_SEG_TYS TYPES
WHERE  SEGS.media_id      = p_media_id
AND    SEGS.milcs_type_id = TYPES.milcs_type_id
AND    TYPES.milcs_code   = 'WITH_AGENT';

EXCEPTION
WHEN NO_DATA_FOUND
THEN
   p_earliest_agent := NULL;
   p_has_agent_segs := 'N';
   p_min_talk_start := NULL;
   p_max_talk_end := NULL;
WHEN OTHERS
THEN
   RAISE;

END get_media_details;


PROCEDURE truncate_table (p_tle_name in varchar2) is

  l_stmt varchar2(400);
BEGIN
  --IF (g_debug_flag = 'Y') THEN
  --write_log('Start of the procedure truncate_table at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
--
  --END IF;
  l_stmt:='truncate table '||g_bix_schema||'.'|| p_tle_name;
  execute immediate l_stmt;

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Table ' || p_tle_name || ' has been truncated');
  --write_log('Finished procedure truncate_table at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;
EXCEPTION
  WHEN OTHERS THEN
  --IF (g_debug_flag = 'Y') THEN
    --write_log('Error in truncate_table : Error : ' || sqlerrm);
  --END IF;
    RAISE;
END truncate_table;

PROCEDURE init IS

  l_status   VARCHAR2(30);
  l_industry VARCHAR2(30);

BEGIN

  --IF (g_debug_flag = 'Y') THEN
--write_log('Start of the procedure init at : ' ||
	   --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

IF (BIS_COLLECTION_UTILITIES.SETUP('BIX_CALL_DETAILS_F') = FALSE) THEN
   RAISE_APPLICATION_ERROR(-20000,
                           'BIS_COLLECTION_UTILITIES.setup has failed');
END IF;


  --IF (g_debug_flag = 'Y') THEN
  --write_log('Initializing global variables');
  --END IF;

  g_request_id        := FND_GLOBAL.CONC_REQUEST_ID();
  g_program_appl_id   := FND_GLOBAL.PROG_APPL_ID();
  g_program_id        := FND_GLOBAL.CONC_PROGRAM_ID();
  g_user_id           := FND_GLOBAL.USER_ID();
  g_sysdate           := SYSDATE;
  g_commit_chunk_size := 1500;
  g_rows_ins_upd      := 0;


  IF(FND_INSTALLATION.GET_APP_INFO('BIX', l_status, l_industry, g_bix_schema)) THEN
     NULL;
  END IF;
  --IF (g_debug_flag = 'Y') THEN
  --write_log('BIX Schema : ' || g_bix_schema);
  --END IF;

  --SETUP will do this - no need to call this
  --write_log('Setting the sort and hash area size');
  execute immediate 'alter session set sort_area_size=524288000';
  execute immediate 'alter session set hash_area_size=524288000';

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Finished procedure init at : ' ||
		   --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

EXCEPTION
  WHEN OTHERS THEN
  --IF (g_debug_flag = 'Y') THEN
    --write_log('Error in init : Error : ' || sqlerrm);
  --END IF;
    RAISE;
END init;

FUNCTION launch_worker(p_worker_no in NUMBER) RETURN NUMBER IS

  l_request_id NUMBER;
l_message VARCHAR2(1000);

test1 varchar2(100);
test2 varchar2(100);

BEGIN

  IF (g_debug_flag = 'Y') THEN
  write_log('Start of the procedure launch_worker for worker ' ||p_worker_no||' at : ' ||
		   to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  END IF;

  -- Submit the parallel concurrent request
  BEGIN

  l_request_id := FND_REQUEST.SUBMIT_REQUEST('BIX',
                                             'BIX_CALL_UPDATE_SUBWORKER',
                                             NULL,
                                             NULL,
                                             FALSE,
                                             p_worker_no);
/*
l_request_id := 123456;
worker (test1,test2,p_worker_no);
*/



  EXCEPTION
  WHEN OTHERS THEN
l_message:=SQLERRM;
  --IF (g_debug_flag = 'Y') THEN
  write_log('Worker exception is ' || l_message);
  --END IF;
  END;

  --IF (g_debug_flag = 'Y') THEN
  write_log('Request ID of the concurrent request launched : ' || to_char(l_request_id));
  --END IF;

  -- if the submission of the request fails , abort the program
  IF (l_request_id = 0) THEN
     rollback;
  --IF (g_debug_flag = 'Y') THEN
     write_log('Error in launching child workers');
  --END IF;
     RAISE G_CHILD_PROCESS_ISSUE;
  END IF;

  --IF (g_debug_flag = 'Y') THEN
  write_log('Finished procedure launch_worker at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;
  RETURN l_request_id;

EXCEPTION
  WHEN OTHERS THEN
  --IF (g_debug_flag = 'Y') THEN
    write_log('Error in launch_worker : Error : ' || sqlerrm);
  --END IF;
    RAISE;
END LAUNCH_WORKER;

PROCEDURE register_jobs IS

  --l_start_date_range DATE;
  --l_end_date_range   DATE;
  l_count            NUMBER := 0;

BEGIN
  --IF (g_debug_flag = 'Y') THEN
  --write_log('Start of the procedure register_jobs at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

  -- No of jobs to be submitted = No of days for which we need to collect data
  --SELECT ceil(g_collect_end_date - g_collect_start_date)
  --INTO   l_count
  --FROM   dual;

  g_no_of_jobs := l_count;

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Number of workers that need to ne instantiated : ' || to_char(l_count));
  --END IF;

  Delete BIX_WORKER_JOBS WHERE OBJECT_NAME = 'BIX_CALL_DETAILS_F';

  --IF (l_count > 0) THEN
    --l_start_date_range := g_collect_start_date;

    -- Register a job for each day of the collection date range
    --FOR i IN 1..l_count
    --LOOP
     --  End date range is end of day of l_start_date_range
      --l_end_date_range := trunc(l_start_date_range) + 86399/86400;

      --IF (l_start_date_range > g_collect_end_date) THEN
        --EXIT;
      --END IF;

      --IF (l_end_date_range > g_collect_end_date) THEN
        --l_end_date_range := g_collect_end_date;
      --END IF;

      --INSERT INTO BIX_WORKER_JOBS(OBJECT_NAME,
                                  --START_DATE_RANGE,
                                  --END_DATE_RANGE,
                                  --WORKER_NUMBER,
                                  --STATUS)
                            --VALUES (
                                 --'BIX_CALL_DETAILS_F',
                                  --l_start_date_range,
                                  --l_end_date_range,
                                  --l_count,
                                  --'UNASSIGNED');

      --l_start_date_range := l_end_date_range + 1/86400;
    --END LOOP;
  --END IF;

--
--Insert the medias to be processed into the worker table
--

INSERT /* APPEND */
INTO bix_medias_for_worker
( MEDIA_ID
 ,DIRECTION
 ,START_DATE_TIME
 ,END_DATE_TIME
 ,SOURCE_ITEM_ID
 ,MEDIA_ITEM_TYPE
 ,MEDIA_ABANDON_FLAG
 ,MEDIA_TRANSFERRED_FLAG
 ,ANI
 ,DNIS
 ,SERVER_GROUP_ID
 ,CLASSIFICATION
 ,WORKER_NUMBER
 ,STATUS
)
SELECT
 MEDIA_ID
--, nvl(DIRECTION, 'INBOUND')
,decode(DIRECTION,NULL,'INBOUND','N/A','INBOUND',DIRECTION)
, START_DATE_TIME
, END_DATE_TIME
, SOURCE_ITEM_ID
, decode(MEDIA_ITEM_TYPE,'TELE_WEB','TELE_WEB_CALLBACK',MEDIA_ITEM_TYPE)
, MEDIA_ABANDON_FLAG
, MEDIA_TRANSFERRED_FLAG
, ANI
,decode(DIRECTION,'OUTBOUND','OUTBOUND', DNIS) DNIS
, SERVER_GROUP_ID
, CLASSIFICATION
, 1
, 'NO WORKER DEFINED'
--med.media_id, 1, 'NO WORKER DEFINED'
FROM   JTF_IH_MEDIA_ITEMS MED
WHERE  med.last_update_date BETWEEN g_collect_start_date
		                  AND g_collect_end_date
AND    med.active = 'N'
AND   (
       med.direction IN ('INBOUND','OUTBOUND') OR
	  med.media_item_type = 'UNSOLICITED'  -- if unsolicited it may have NULL direction
	 )
AND
(
med.media_item_type = 'TELE_INB' or
med.media_item_type = 'TELE_DIRECT' or
--002 commenting out "Telephone" media type as it is meant for
--"Outbound Telphony" which has been obsoleted.
--med.media_item_type = 'TELEPHONE' or
med.media_item_type = 'CALL' or
med.media_item_type = 'TELE_MANUAL' or
med.media_item_type = 'TELE_WEB' or
med.media_item_type = 'TELE_WEB_CALLBACK' or
med.media_item_type = 'UNSOLICITED'
);

g_no_of_jobs := SQL%ROWCOUNT;
write_log('SQLrowcount = ' || g_no_of_jobs);

COMMIT;

DBMS_STATS.gather_table_stats(ownname => g_bix_schema,
                                tabName => 'bix_medias_for_worker',
                                cascade => TRUE,
                    degree => bis_common_parameters.get_degree_of_parallelism,
                                estimate_percent => 10,
                                granularity => 'GLOBAL');

--
--Insert the missing DNIS values
--
insert_dnis;

--execute immediate 'analyze index bix.bix_medias_for_worker_n1 compute statistics';

/*
SELECT max(ranking)
INTO g_no_of_jobs
FROM bix_medias_for_worker;
*/

--
--Set the worker number correctly
--
IF g_no_of_jobs > 0
THEN

--dbms_output.put_line('outside loop');
--dbms_output.put_line('g_no_of_jobs='||g_no_of_jobs);
--dbms_output.put_line('g_required_workers='||g_required_workers);

  FOR x IN 1 .. g_required_workers LOOP

--dbms_output.put_line('Inside loop with x = ' || x );

     --UPDATE bix_medias_for_worker
     UPDATE bix_medias_for_worker
     SET worker_number = x,
         status = 'UNASSIGNED'
     WHERE worker_number   = 1
     AND status = 'NO WORKER DEFINED'
     --AND rownum < 10
     AND rownum <= ceil(g_no_of_jobs/g_required_workers)
     --AND ranking > ceil(g_no_of_jobs/g_required_workers)*(x-1)
     --AND ranking <= ceil(g_no_of_jobs/g_required_workers)*x
     ;

     IF SQL%ROWCOUNT > 0
	THEN

     INSERT INTO BIX_WORKER_JOBS
     (
     OBJECT_NAME,
     START_DATE_RANGE,
     END_DATE_RANGE,
     WORKER_NUMBER,
     STATUS
     )
     VALUES
     (
     'BIX_CALL_DETAILS_F',
     sysdate,
     sysdate,
     x,
     'UNASSIGNED'
     );

	END IF;

  END LOOP;

  COMMIT;

--insert into bixtest
--select 'worker number is ' || worker_number
--from bix_medias_for_worker;
--commit;

END IF;

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Finished procedure register_jobs at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

EXCEPTION
  WHEN OTHERS THEN
  --IF (g_debug_flag = 'Y') THEN
    --write_log('Error in register_jobs : Error : ' || sqlerrm);
  --END IF;
    RAISE;
END REGISTER_JOBS;

PROCEDURE clean_up IS

  l_total_rows_deleted NUMBER := 0;
  l_rows_deleted       NUMBER := 0;

BEGIN
  --IF (g_debug_flag = 'Y') THEN
  --write_log('Start of the procedure clean_up at ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

  rollback;

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Deleting data from bix_call_details_f');
  --END IF;

  -- Delete all the rows inserted from subworkers
  IF (g_worker.COUNT > 0) THEN
    FOR i IN g_worker.FIRST .. g_worker.LAST
    LOOP
      LOOP
        DELETE BIX_CALL_DETAILS_F
        WHERE  request_id = g_worker(i)
        AND last_update_date >= g_sysdate
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

  -- Deleting all rows inserted by this main program
  LOOP

    DELETE BIX_CALL_DETAILS_F
    WHERE  request_id = g_request_id
    AND last_update_date >= g_sysdate
    AND    rownum <= g_commit_chunk_size ;

    l_rows_deleted := SQL%ROWCOUNT;
    l_total_rows_deleted := l_total_rows_deleted + l_rows_deleted;

    COMMIT;

    IF (l_rows_deleted < g_commit_chunk_size) THEN
      EXIT;
    END IF;
  END LOOP;

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Number of rows deleted from BIX_CALL_DETAILS_F : ' || to_char(l_total_rows_deleted));
  --END IF;

  truncate_table('BIX_CALL_DETAILS_STG');
  --truncate_table('BIX_CALL_PROCESSED_RECS');
  --IF (g_debug_flag = 'Y') THEN
  --write_log('Done truncating bix_call_details_stg
             --and bix_call_processed_recs');
--
  --write_log('Finished procedure clean_up at ' ||
             --to_char(sysdate,'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

EXCEPTION
  WHEN OTHERS THEN
  --IF (g_debug_flag = 'Y') THEN
    --write_log('Error in cleaning up the tables : Error : ' || sqlerrm);
  --END IF;
    RAISE;
END CLEAN_UP;

PROCEDURE insert_half_hour_rows (
                      p_collect_start_date IN DATE,
                      p_collect_end_date   IN DATE,
                      p_worker_no IN NUMBER
                     )
IS

CURSOR get_call_info IS
SELECT
MEDIA.media_id                    MEDIA_ID,
MEDIA.server_group_id             SERVER_GROUP_ID,
MEDIA.CLASSIFICATION              CLASSIFICATION,
MEDIA.dnis                        DNIS,
MEDIA.direction                   DIRECTION,
MEDIA.media_item_type             MEDIA_ITEM_TYPE,
MEDIA.media_start_time            MEDIA_START_TIME,
MEDIA.media_end_time              MEDIA_END_TIME,
MEDIA.abandon_flag                ABANDON_FLAG ,
MEDIA.transfer_flag               TRANSFER_FLAG,
MEDIA.source_item_id              SOURCE_ITEM_ID,
--MEDIA.MILCS_ID                    MILCS_ID,
MEDIA.resource_id                 RESOURCE_ID,
--MEDIA.segment_type                SEGMENT_TYPE,
--MEDIA.segment_start_time          SEGMENT_START_TIME,
--MEDIA.segment_end_time            SEGMENT_END_TIME,
MEDIA.MAX_AGENT_TALK_END          MAX_TALK_END_TIME,
MEDIA.FIRST_AGENT                 FIRST_AGENT,
MEDIA.CALL_TALK_START             CALL_TALK_START,
MEDIA.CALL_TALK_END               CALL_TALK_END,
INTACT.INTERACTION_ID             INTERACTION_ID,
INTACT.OUTCOME_ID                 OUTCOME_ID,
INTACT.RESULT_ID                  RESULT_ID,
INTACT.REASON_ID                  REASON_ID,
first_value(INTACT.PARTY_ID)
over(partition by nvl(intact.media_id,media.media_id)
order by intact.int_end_time DESC NULLS LAST
     )                            PARTY_ID,
first_value(INTACT.SOURCE_CODE)
over(partition by nvl(intact.media_id,media.media_id)
order by intact.int_end_time DESC NULLS LAST
     )                            SOURCE_CODE,
INTACT.INT_START_TIME             INT_START_TIME,
INTACT.INT_END_TIME               INT_END_TIME,
INTACT.MAX_AGENT_INT_END          MAX_INT_END_TIME,
INTACT.ACTIVITY_ID                ACTIVITY_ID,
INTACT.ACT_START_TIME             ACT_START_TIME,
INTACT.ACTION_ID                  ACTION_ID,
INTACT.ACTION_ITEM_ID             ACTION_ITEM_ID,
INTACT.DOC_REF                    DOC_REF,
INTACT.DOC_ID                     DOC_ID,
MEDIA.ROUTE_MILCS_ID,
MEDIA.ROUTE_SEGS_START_TIME,
MEDIA.ROUTE_SEGS_END_TIME,
MEDIA.IVR_MILCS_ID,
MEDIA.IVR_SEGS_START_TIME,
MEDIA.IVR_SEGS_END_TIME,
MEDIA.FIRST_QUEUE,
MEDIA.LAST_QUEUE,
MEDIA.QUEUE_MILCS_ID,
MEDIA.QUEUE_SEGS_START_TIME,
MEDIA.QUEUE_SEGS_END_TIME,
MEDIA.AGENT_MILCS_ID,
MEDIA.AGENT_SEGS_START_TIME,
MEDIA.AGENT_SEGS_END_TIME
FROM
(
SELECT /*+ use_nl(MED,IVR_SEGS,ROUTE_SEGS,QUEUE_SEGS,AGENT_SEGS) */
MED.media_id               MEDIA_ID,
MED.server_group_id               SERVER_GROUP_ID,
MED.CLASSIFICATION                CLASSIFICATION,
MED.dnis                          DNIS,
MED.direction                     DIRECTION,
MED.media_item_type               MEDIA_ITEM_TYPE,
MED.start_date_time               MEDIA_START_TIME,
MED.end_date_time                 MEDIA_END_TIME,
MED.media_abandon_flag            ABANDON_FLAG ,
MED.MEDIA_TRANSFERRED_FLAG        TRANSFER_FLAG,
MED.source_item_id                SOURCE_ITEM_ID,
--SEGS.MILCS_ID                   MILCS_ID,
ROUTE_SEGS.MILCS_ID               ROUTE_MILCS_ID,
ROUTE_SEGS.START_DATE_TIME        ROUTE_SEGS_START_TIME,
ROUTE_SEGS.END_DATE_TIME          ROUTE_SEGS_END_TIME,
IVR_SEGS.MILCS_ID                 IVR_MILCS_ID,
IVR_SEGS.START_DATE_TIME          IVR_SEGS_START_TIME,
IVR_SEGS.END_DATE_TIME            IVR_SEGS_END_TIME,
FIRST_VALUE(QUEUE_SEGS.MILCS_ID)
OVER(PARTITION BY QUEUE_SEGS.MEDIA_ID
     ORDER BY QUEUE_SEGS.START_DATE_TIME ASC NULLS LAST
     )                            FIRST_QUEUE,
FIRST_VALUE(QUEUE_SEGS.MILCS_ID)
OVER(PARTITION BY QUEUE_SEGS.MEDIA_ID
     ORDER BY QUEUE_SEGS.START_DATE_TIME DESC NULLS LAST
     )                            LAST_QUEUE,
QUEUE_SEGS.MILCS_ID               QUEUE_MILCS_ID,
QUEUE_SEGS.START_DATE_TIME        QUEUE_SEGS_START_TIME,
QUEUE_SEGS.END_DATE_TIME          QUEUE_SEGS_END_TIME,
AGENT_SEGS.MILCS_ID               AGENT_MILCS_ID,
AGENT_SEGS.START_DATE_TIME        AGENT_SEGS_START_TIME,
AGENT_SEGS.END_DATE_TIME          AGENT_SEGS_END_TIME,
AGENT_SEGS.resource_id            RESOURCE_ID,
--SEGTYPES.milcs_code             SEGMENT_TYPE,
--SEGS.start_date_time            SEGMENT_START_TIME,
--SEGS.end_date_time              SEGMENT_END_TIME,
--
--use decode to make sure segment id of 5 (with_agent) comes first
--
FIRST_VALUE(AGENT_SEGS.RESOURCE_ID)
OVER(PARTITION BY AGENT_SEGS.MEDIA_ID
     ORDER BY decode(AGENT_SEGS.MILCS_TYPE_ID,5,1000,AGENT_SEGS.MILCS_TYPE_ID) DESC NULLS LAST,
              AGENT_SEGS.START_DATE_TIME
     )                            FIRST_AGENT,
FIRST_VALUE(AGENT_SEGS.START_DATE_TIME)
OVER(PARTITION BY AGENT_SEGS.MEDIA_ID
     ORDER BY decode(AGENT_SEGS.MILCS_TYPE_ID,5,1000,AGENT_SEGS.MILCS_TYPE_ID) DESC NULLS LAST,
	          AGENT_SEGS.START_DATE_TIME
	 )                        CALL_TALK_START,
FIRST_VALUE(AGENT_SEGS.END_DATE_TIME)
OVER(PARTITION BY AGENT_SEGS.MEDIA_ID
     ORDER BY decode(AGENT_SEGS.MILCS_TYPE_ID,5,1000,AGENT_SEGS.MILCS_TYPE_ID) DESC NULLS LAST,
	          AGENT_SEGS.END_DATE_TIME DESC NULLS LAST
	 )                        CALL_TALK_END,
FIRST_VALUE(AGENT_SEGS.END_DATE_TIME)
OVER(PARTITION BY AGENT_SEGS.MEDIA_ID, AGENT_SEGS.RESOURCE_ID
     ORDER BY decode(AGENT_SEGS.MILCS_TYPE_ID,5,1000,AGENT_SEGS.MILCS_TYPE_ID) DESC NULLS LAST,
	          AGENT_SEGS.END_DATE_TIME DESC NULLS LAST
	 )                        MAX_AGENT_TALK_END
--FROM (JTF_IH_MEDIA_ITEMS MED LEFT OUTER JOIN
     --JTF_IH_MEDIA_ITEM_LC_SEGS    AGENT_SEGS
	--ON MED.media_id = AGENT_SEGS.media_id
	--)
	--LEFT OUTER JOIN
     --JTF_IH_MEDIA_ITM_LC_SEG_TYS  SEGTYPES
	--ON SEGS.MILCS_TYPE_ID = SEGTYPES.MILCS_TYPE_ID
FROM
bix_medias_for_worker MED,
(select *
from jtf_ih_media_item_lc_segs
where milcs_type_id = 1) IVR_SEGS,
(select *
from jtf_ih_media_item_lc_segs
where milcs_type_id = 4) ROUTE_SEGS,
(select *
from jtf_ih_media_item_lc_segs
where milcs_type_id = 3) QUEUE_SEGS,
(select *
from jtf_ih_media_item_lc_segs
where milcs_type_id = 5) AGENT_SEGS
WHERE MED.worker_number = p_worker_no
AND MED.status = 'IN PROCESS'
--WHERE  MED.last_update_date BETWEEN g_collect_start_date
--		                  AND g_collect_end_date
AND med.media_id = ROUTE_SEGS.media_id (+)
and med.media_id = IVR_SEGS.media_id (+)
and med.media_id = QUEUE_SEGS.media_id (+)
and med.media_id = AGENT_SEGS.media_id (+)
--AND    MED.active = 'N'
--AND MED.direction IN ('INBOUND','OUTBOUND')
--AND
--(
--MED.media_item_type = 'TELE_INB' or
--MED.media_item_type = 'TELE_DIRECT' or
--MED.media_item_type = 'TELEPHONE' or
--MED.media_item_type = 'CALL' or
--MED.media_item_type = 'TELE_MANUAL' or
--MED.media_item_type = 'TELE_WEB'
--)
) MEDIA LEFT OUTER JOIN
(
select distinct INTERACTION_ID,
      MEDIA_ID,
      RESOURCE_ID,
      OUTCOME_ID,
      RESULT_ID,
      REASON_ID,
      INT_START_TIME,
      INT_END_TIME,
      ACTIVITY_ID,
      ACT_START_TIME,
      ACTION_ID,
      ACTION_ITEM_ID,
      DOC_REF,
      DOC_ID,
      PARTY_ID,
      SOURCE_CODE,
      MAX_AGENT_INT_END
from (
SELECT /*+ FIRST_ROWS */
      INT.INTERACTION_ID INTERACTION_ID,
      --MED.MEDIA_ID MEDIA_ID,
      WORK.MEDIA_ID MEDIA_ID,
      INT.RESOURCE_ID RESOURCE_ID,
      INT.OUTCOME_ID OUTCOME_ID,
      INT.RESULT_ID RESULT_ID,
      INT.REASON_ID REASON_ID,
      INT.START_DATE_TIME INT_START_TIME,
      INT.END_DATE_TIME INT_END_TIME,
      ACT.ACTIVITY_ID ACTIVITY_ID,
      ACT.START_DATE_TIME ACT_START_TIME,
      ACT.ACTION_ID ACTION_ID,
      ACT.ACTION_ITEM_ID ACTION_ITEM_ID,
      ACT.DOC_REF DOC_REF,
      ACT.DOC_ID DOC_ID,
      INT.PARTY_ID PARTY_ID,
     INT.SOURCE_CODE SOURCE_CODE,
      first_value(INT.END_DATE_TIME)
      over(partition by
           --med.media_id,
           work.media_id,
           int.resource_id
           order by int.end_date_time DESC NULLS LAST
           ) MAX_AGENT_INT_END
FROM
    --JTF_IH_MEDIA_ITEMS MED,
    BIX_MEDIAS_FOR_WORKER WORK,
    JTF_IH_INTERACTIONS INT LEFT OUTER JOIN JTF_IH_ACTIVITIES ACT
    ON INT.interaction_id = ACT.interaction_id
--WHERE MED.last_update_date BETWEEN p_collect_start_date
                                  --AND p_collect_end_date
--AND INT.start_date_time BETWEEN p_collect_start_date-1
--AND p_collect_end_date+1
--AND MED.active = 'N'
--AND MED.direction IN ('INBOUND','OUTBOUND')
--AND MED.media_id = int.productive_time_amount
WHERE int.productive_time_amount = work.media_id
AND work.status = 'IN PROCESS'
AND work.worker_number = p_worker_no
--AND
--(
--MED.media_item_type = 'TELE_INB' or
--MED.media_item_type = 'TELE_DIRECT' or
--MED.media_item_type = 'TELEPHONE' or
--MED.media_item_type = 'CALL' or
--MED.media_item_type = 'TELE_MANUAL' or
--MED.media_item_type = 'TELE_WEB'
--)
UNION ALL
SELECT /*+ FIRST_ROWS */
      INT.INTERACTION_ID INTERACTION_ID,
      ACT.MEDIA_ID MEDIA_ID,
      INT.RESOURCE_ID RESOURCE_ID,
      INT.OUTCOME_ID OUTCOME_ID,
      INT.RESULT_ID RESULT_ID,
      INT.REASON_ID REASON_ID,
      INT.START_DATE_TIME INT_START_TIME,
      INT.END_DATE_TIME INT_END_TIME,
      ACT.ACTIVITY_ID ACTIVITY_ID,
      ACT.START_DATE_TIME ACT_START_TIME,
      ACT.ACTION_ID ACTION_ID,
      ACT.ACTION_ITEM_ID ACTION_ITEM_ID,
      ACT.DOC_REF DOC_REF,
      ACT.DOC_ID DOC_ID,
      INT.PARTY_ID PARTY_ID,
      INT.SOURCE_CODE SOURCE_CODE ,
      first_value(INT.END_DATE_TIME)
      over(partition by act.media_id,int.resource_id
           order by int.end_date_time DESC NULLS LAST
           ) MAX_AGENT_INT_END
FROM
    --JTF_IH_MEDIA_ITEMS MED,
    BIX_MEDIAS_FOR_WORKER WORK,
    JTF_IH_INTERACTIONS INT, JTF_IH_ACTIVITIES ACT
--WHERE MED.last_update_date BETWEEN p_collect_start_date
                                  --AND p_collect_end_date
--AND MED.active = 'N'
WHERE INT.interaction_id = ACT.interaction_id
AND ACT.media_id = WORK.media_id
AND work.status = 'IN PROCESS'
AND work.worker_number = p_worker_no
--AND MED.direction IN ('INBOUND','OUTBOUND')
--AND MED.media_id = ACT.media_id
--AND
--(
--MED.media_item_type = 'TELE_INB' or
--MED.media_item_type = 'TELE_DIRECT' or
--MED.media_item_type = 'TELEPHONE' or
--MED.media_item_type = 'CALL' or
--MED.media_item_type = 'TELE_MANUAL' or
--MED.media_item_type = 'TELE_WEB'
--)
)
) INTACT
ON (MEDIA.MEDIA_ID = INTACT.MEDIA_ID
AND INTACT.RESOURCE_ID = decode(media.agent_milcs_id,NULL,INTACT.resource_id,
                                MEDIA.resource_id)
)
GROUP BY
MEDIA.media_id,
MEDIA.server_group_id,
MEDIA.CLASSIFICATION,
MEDIA.dnis,
MEDIA.direction,
MEDIA.media_item_type,
MEDIA.media_start_time,
MEDIA.media_end_time,
MEDIA.abandon_flag,
MEDIA.transfer_flag,
MEDIA.source_item_id,
--MEDIA.MILCS_ID,
MEDIA.resource_id,
--MEDIA.segment_type,
--MEDIA.segment_start_time,
--MEDIA.segment_end_time,
INTACT.INTERACTION_ID,
INTACT.OUTCOME_ID,
INTACT.RESULT_ID,
INTACT.REASON_ID,
INTACT.INT_START_TIME,
INTACT.INT_END_TIME,
INTACT.ACTIVITY_ID,
INTACT.ACT_START_TIME,
INTACT.ACTION_ID,
INTACT.ACTION_ITEM_ID,
INTACT.DOC_REF,
INTACT.DOC_ID,
INTACT.MEDIA_ID,
INTACT.RESOURCE_ID,
MEDIA.MAX_AGENT_TALK_END,
MEDIA.FIRST_AGENT,
MEDIA.CALL_TALK_START,
MEDIA.CALL_TALK_END,
INTACT.MAX_AGENT_INT_END,
INTACT.PARTY_ID,
INTACT.SOURCE_CODE,
MEDIA.ROUTE_MILCS_ID,
MEDIA.ROUTE_SEGS_START_TIME,
MEDIA.ROUTE_SEGS_END_TIME,
MEDIA.IVR_MILCS_ID,
MEDIA.IVR_SEGS_START_TIME,
MEDIA.IVR_SEGS_END_TIME,
MEDIA.FIRST_QUEUE,
MEDIA.LAST_QUEUE,
MEDIA.QUEUE_MILCS_ID,
MEDIA.QUEUE_SEGS_START_TIME,
MEDIA.QUEUE_SEGS_END_TIME,
MEDIA.AGENT_MILCS_ID,
MEDIA.AGENT_SEGS_START_TIME,
MEDIA.AGENT_SEGS_END_TIME
ORDER BY MEDIA.media_id,
         --MEDIA.MILCS_ID,
         --MEDIA.media_start_time, MEDIA.resource_id, MEDIA.SEGMENT_TYPE,
	    INTACT.INTERACTION_ID, INTACT.ACTIVITY_ID
;

--
--Source Table Datatype Declarations
--

TYPE L_MEDIA_ID_t IS TABLE OF jtf_ih_media_items.media_id%TYPE INDEX BY BINARY_INTEGER;
TYPE L_MEDIA_ITEM_TYPE_t IS TABLE OF jtf_ih_media_items.media_item_type%TYPE INDEX BY BINARY_INTEGER;
TYPE L_SERVER_GROUP_ID_t IS TABLE OF jtf_ih_media_items.SERVER_GROUP_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE L_CLASSIFICATION_VALUE_t IS TABLE OF jtf_ih_media_items.CLASSIFICATION%TYPE INDEX BY BINARY_INTEGER;
TYPE L_DNIS_NAME_t IS TABLE OF jtf_ih_media_items.DNIS%TYPE INDEX BY BINARY_INTEGER;
TYPE L_DIRECTION_t IS TABLE OF jtf_ih_media_items.DIRECTION%TYPE INDEX BY BINARY_INTEGER;
TYPE L_MEDIA_START_TIME_t IS TABLE OF jtf_ih_media_items.START_DATE_TIME%TYPE INDEX BY BINARY_INTEGER;
TYPE L_MEDIA_END_TIME_t IS TABLE OF jtf_ih_media_items.END_DATE_TIME%TYPE INDEX BY BINARY_INTEGER;
TYPE L_ABANDON_FLAG_t IS TABLE OF jtf_ih_media_items.MEDIA_ABANDON_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE L_TRANSFER_FLAG_t IS TABLE OF jtf_ih_media_items.MEDIA_TRANSFERRED_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE L_SOURCE_ITEM_ID_t IS TABLE OF jtf_ih_media_items.SOURCE_ITEM_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE L_MILCS_ID_t IS TABLE OF jtf_ih_media_item_lc_segs.MILCS_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE L_RESOURCE_ID_t IS TABLE OF jtf_ih_media_item_lc_segs.RESOURCE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE L_SEGMENT_TYPE_t IS TABLE OF jtf_ih_media_itm_lc_seg_tys.MILCS_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE L_SEGMENT_START_TIME_t IS TABLE OF jtf_ih_media_item_lc_segs.START_DATE_TIME%TYPE INDEX BY BINARY_INTEGER;
TYPE L_SEGMENT_END_TIME_t IS TABLE OF jtf_ih_media_item_lc_segs.END_DATE_TIME%TYPE INDEX BY BINARY_INTEGER;
--
--Target Table Datatype Declarations
--
TYPE L_TIME_ID_T IS TABLE OF BIX_CALL_DETAILS_F.TIME_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE L_PERIOD_TYPE_ID_T IS TABLE OF BIX_CALL_DETAILS_F.PERIOD_TYPE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE L_PERIOD_START_DATE_t IS TABLE OF BIX_CALL_DETAILS_F.PERIOD_START_DATE%TYPE INDEX BY BINARY_INTEGER;
TYPE L_PERIOD_START_TIME_t IS TABLE OF BIX_CALL_DETAILS_F.PERIOD_START_TIME%TYPE INDEX BY BINARY_INTEGER;
TYPE L_DAY_OF_WEEK_t IS TABLE OF BIX_CALL_DETAILS_F.DAY_OF_WEEK%TYPE INDEX BY BINARY_INTEGER;
TYPE L_PARTY_ID_t IS TABLE OF BIX_CALL_DETAILS_F.PARTY_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE L_CAMPAIGN_ID_t IS TABLE OF BIX_CALL_DETAILS_F.CAMPAIGN_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE L_SCHEDULE_ID_t IS TABLE OF BIX_CALL_DETAILS_F.SCHEDULE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE L_SOURCE_CODE_ID_t IS TABLE OF BIX_CALL_DETAILS_F.SOURCE_CODE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE L_DIALING_METHOD_t IS TABLE OF BIX_CALL_DETAILS_F.DIALING_METHOD%TYPE INDEX BY BINARY_INTEGER;
TYPE L_OUTCOME_ID_t IS TABLE OF BIX_CALL_DETAILS_F.OUTCOME_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE L_RESULT_ID_t IS TABLE OF BIX_CALL_DETAILS_F.RESULT_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE L_REASON_ID_t IS TABLE OF BIX_CALL_DETAILS_F.REASON_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE L_PARTITION_KEY_t IS TABLE OF BIX_CALL_DETAILS_F.PARTITION_KEY%TYPE INDEX BY BINARY_INTEGER;
TYPE L_CALL_CALLS_off_TOTAL_t IS TABLE OF BIX_CALL_DETAILS_F.CALL_CALLS_OFFERED_TOTAL%TYPE INDEX BY BINARY_INTEGER;
TYPE L_CALL_CALLS_off_ABOVE_TH_t IS TABLE OF BIX_CALL_DETAILS_F.CALL_CALLS_OFFERED_ABOVE_TH%TYPE INDEX BY BINARY_INTEGER;
TYPE L_CALL_CALLS_aband_t IS TABLE OF BIX_CALL_DETAILS_F.CALL_CALLS_ABANDONED%TYPE INDEX BY BINARY_INTEGER;
TYPE L_CALL_CALLS_aband_us_t IS TABLE OF BIX_CALL_DETAILS_F.CALL_CALLS_ABANDONED_US%TYPE INDEX BY BINARY_INTEGER;
TYPE L_CALL_CALLS_TRANSFERRED_t IS TABLE OF BIX_CALL_DETAILS_F.CALL_CALLS_TRANSFERRED%TYPE INDEX BY BINARY_INTEGER;
TYPE L_CALL_IVR_TIME_t IS TABLE OF BIX_CALL_DETAILS_F.CALL_IVR_TIME%TYPE INDEX BY BINARY_INTEGER;
TYPE L_CALL_ROUTE_TIME_t IS TABLE OF BIX_CALL_DETAILS_F.CALL_ROUTE_TIME%TYPE INDEX BY BINARY_INTEGER;
TYPE l_call_queue_time_t IS TABLE OF BIX_CALL_DETAILS_F.call_queue_time%TYPE INDEX BY BINARY_INTEGER;
TYPE L_CALL_TALK_TIME_t IS TABLE OF BIX_CALL_DETAILS_F.CALL_TALK_TIME%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_TALK_TIME_NAC_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_TALK_TIME_NAC%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_WRAP_TIME_NAC_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_WRAP_TIME_NAC%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_PREVIEW_TIME_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_PREVIEW_TIME%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_CALLS_TRAN_CONF_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_CALLS_TRAN_CONF_TO_NAC%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_CONT_CALLS_HAND_NA_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_CONT_CALLS_HAND_NA%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_CALLS_hand_TOTAL_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_CALLS_HANDLED_TOTAL%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_CALLS_hand_ABOVE_TH_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_CALLS_HANDLED_ABOVE_TH%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_CALLS_ans_BY_GOAL_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_CALLS_ANSWERED_BY_GOAL%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_LEADS_CREATED_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_LEADS_CREATED%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_SR_CREATED_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_SR_CREATED%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_LEADS_AMOUNT_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_LEADS_AMOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_LEADS_conv_TO_OPP_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_LEADS_CONVERTED_TO_OPP%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_opps_CREATED_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_OPPORTUNITIES_CREATED%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_opps_WON_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_OPPORTUNITIES_WON%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_opps_WON_AMOUNT_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_OPPORTUNITIES_WON_AMOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_opps_CROSS_SOLD_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_OPPORTUNITIES_CROSS_SOLD%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_opps_UP_SOLD_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_OPPORTUNITIES_UP_SOLD%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_opps_DECLINED_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_OPPORTUNITIES_DECLINED%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENT_opps_LOST_t IS TABLE OF BIX_CALL_DETAILS_F.AGENT_OPPORTUNITIES_LOST%TYPE INDEX BY BINARY_INTEGER;
TYPE L_AGENTCALL_ORR_COUNT_t IS TABLE OF BIX_CALL_DETAILS_F.AGENTCALL_ORR_COUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE l_agentcall_pr_count_t IS TABLE OF BIX_CALL_DETAILS_F.AGENTCALL_PR_COUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE l_agentcall_contact_count_t IS TABLE OF BIX_CALL_DETAILS_F.AGENTCALL_CONTACT_COUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE l_int_id_t IS TABLE OF JTF_IH_INTERACTIONS.interaction_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_source_code_t IS TABLE OF JTF_IH_INTERACTIONS.source_code%TYPE INDEX BY BINARY_INTEGER;
TYPE l_int_start_time_t IS TABLE OF JTF_IH_INTERACTIONS.start_date_time%TYPE INDEX BY BINARY_INTEGER;
TYPE l_int_end_time_t IS TABLE OF JTF_IH_INTERACTIONS.end_date_time%TYPE INDEX BY BINARY_INTEGER;
TYPE l_act_id_t IS TABLE OF JTF_IH_ACTIVITIES.activity_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_act_start_time_t IS TABLE OF JTF_IH_ACTIVITIES.start_date_time%TYPE INDEX BY BINARY_INTEGER;
TYPE l_action_id_t IS TABLE OF JTF_IH_ACTIVITIES.action_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_action_item_id_t IS TABLE OF JTF_IH_ACTIVITIES.action_item_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_doc_ref_t IS TABLE OF JTF_IH_ACTIVITIES.doc_ref%TYPE INDEX BY BINARY_INTEGER;
TYPE l_doc_id_t IS TABLE OF JTF_IH_ACTIVITIES.doc_id%TYPE INDEX BY BINARY_INTEGER;

TYPE SourceRecordType IS RECORD
(
media_id L_MEDIA_ID_t,
media_item_type L_MEDIA_ITEM_TYPE_t,
server_group_id L_SERVER_GROUP_ID_t,
classification_value L_CLASSIFICATION_VALUE_t,
dnis_name L_DNIS_NAME_t,
direction L_DIRECTION_t,
media_start_time L_MEDIA_START_TIME_t,
media_end_time L_MEDIA_END_TIME_t,
abandon_flag L_ABANDON_FLAG_t,
transfer_flag L_TRANSFER_FLAG_t,
source_item_id L_SOURCE_ITEM_ID_t,
--milcs_id L_MILCS_ID_t,
resource_id L_RESOURCE_ID_t,
--segment_type L_SEGMENT_TYPE_t,
--segment_start_time L_SEGMENT_START_TIME_t,
--segment_end_time L_SEGMENT_END_TIME_t,
int_id l_int_id_t,
act_id l_act_id_t,
outcome_id l_outcome_id_t,
result_id l_result_id_t,
reason_id l_reason_id_t,
party_id l_party_id_t,
source_code l_source_code_t,
int_start_time l_int_start_time_t,
int_end_time l_int_end_time_t,
action_id l_action_id_t,
action_item_id l_action_item_id_t,
doc_ref l_doc_ref_t,
doc_id l_doc_id_t,
first_agent l_resource_id_t,
max_agent_talk_end l_segment_start_time_t,
call_talk_start l_segment_start_time_t,
call_talk_end l_segment_start_time_t,
max_agent_int_end l_segment_start_time_t,
act_start_time l_segment_start_time_t,
ROUTE_MILCS_ID l_milcs_id_t,
ROUTE_SEGS_START_TIME l_segment_start_time_t,
ROUTE_SEGS_END_TIME l_segment_start_time_t,
IVR_MILCS_ID l_milcs_id_t,
IVR_SEGS_START_TIME l_segment_start_time_t,
IVR_SEGS_END_TIME l_segment_start_time_t,
FIRST_QUEUE l_milcs_id_t,
LAST_QUEUE l_milcs_id_t,
QUEUE_MILCS_ID l_milcs_id_t,
QUEUE_SEGS_START_TIME l_segment_start_time_t,
QUEUE_SEGS_END_TIME l_segment_start_time_t,
AGENT_MILCS_ID l_milcs_id_t,
AGENT_SEGS_START_TIME l_segment_start_time_t,
AGENT_SEGS_END_TIME l_segment_start_time_t
);


l_source_record SourceRecordType;
l_source_null_record SourceRecordType;

TYPE TargetRecordType IS RECORD
(
media_id L_MEDIA_ID_T,
time_id L_TIME_ID_T,
period_type_id L_PERIOD_TYPE_ID_T,
period_start_date L_PERIOD_START_DATE_t,
period_start_time L_PERIOD_START_TIME_t,
day_of_week L_DAY_OF_WEEK_t,
direction L_DIRECTION_T,
media_item_type L_MEDIA_ITEM_TYPE_T,
classification_value L_CLASSIFICATION_VALUE_T,
dnis_name L_DNIS_NAME_T,
server_group_id L_SERVER_GROUP_ID_T,
resource_id L_RESOURCE_ID_T,
party_id L_PARTY_ID_t,
campaign_id L_CAMPAIGN_ID_t,
schedule_id L_SCHEDULE_ID_t,
source_code_id L_SOURCE_CODE_ID_t,
dialing_method L_DIALING_METHOD_t,
outcome_id L_OUTCOME_ID_t,
result_id L_RESULT_ID_t,
reason_id L_REASON_ID_t,
partition_key L_PARTITION_KEY_t,
call_calls_offered_total l_call_CALLS_off_TOTAL_t,
call_calls_offered_above_th l_call_CALLS_off_ABOVE_TH_t,
call_calls_abandoned l_call_CALLS_aband_t,
call_calls_abandoned_us L_CALL_CALLS_aband_us_t,
call_calls_transferred l_call_CALLS_TRANSFERRED_t,
call_ivr_time l_call_IVR_TIME_t,
call_route_time l_call_ROUTE_TIME_t,
call_queue_time l_call_queue_time_t,
call_talk_time l_call_TALK_TIME_t,
call_calls_hand_tot l_call_calls_off_total_t,
call_calls_hand_above_th l_call_calls_off_total_t,
CALL_CONT_CALLS_OFFERED_NA l_call_calls_off_total_t,
CALL_CONT_CALLS_HANDLED_TOT_NA l_call_calls_off_total_t,
agent_talk_time_nac l_agent_TALK_TIME_NAC_t,
agent_wrap_time_nac l_agent_WRAP_TIME_NAC_t,
agent_preview_time l_agent_PREVIEW_TIME_t,
agent_calls_tran_conf_to_nac l_agent_CALLS_TRAN_CONF_t,
agent_cont_calls_hand_na l_agent_CONT_CALLS_HAND_NA_t,
agent_cont_calls_tc_na l_agent_CONT_CALLS_HAND_NA_t,
agent_calls_handled_total l_agent_CALLS_hand_TOTAL_t,
agent_calls_handled_above_th l_agent_CALLS_hand_ABOVE_TH_t,
agent_calls_answered_by_goal l_agent_CALLS_ans_BY_GOAL_t,
agent_leads_created l_agent_LEADS_CREATED_t,
agent_sr_created l_agent_SR_CREATED_t,
agent_leads_amount l_agent_LEADS_AMOUNT_t,
agent_leads_converted_to_opp l_agent_LEADS_conv_TO_OPP_t,
agent_opportunities_created l_agent_opps_CREATED_t,
agent_opportunities_won l_agent_opps_WON_t,
agent_opportunities_won_amount l_agent_opps_WON_AMOUNT_t,
agent_opportunities_cross_sold l_agent_opps_CROSS_SOLD_t,
agent_opportunities_up_sold l_agent_opps_UP_SOLD_t,
agent_opportunities_declined l_agent_opps_DECLINED_t,
agent_opportunities_lost l_agent_opps_LOST_t,
agentcall_orr_count l_agentcall_ORR_COUNT_t,
agentcall_pr_count l_agentcall_pr_count_t,
agentcall_contact_count l_agentcall_contact_count_t,
CALL_TOT_QUEUE_TO_ABANDON l_call_queue_time_t,
call_tot_queue_to_answer l_call_queue_time_t
);

l_target_record TargetRecordType;
l_target_null_record TargetRecordType;

--
--Miscellaneous Variables
--
l_segment_start DATE;
l_segment_end DATE;
l_secs NUMBER;
l_row_counter NUMBER;
counter NUMBER;
l_period_start  DATE;
l_final_segment VARCHAR2(1) := NULL;
l_max_talk_end_date_time DATE := NULL;
--l_has_agent_segs VARCHAR2(1) := NULL;
--l_earliest_agent NUMBER := NULL;
l_met_goal VARCHAR2(1) := NULL;
l_cumulative_queue NUMBER := 0;
l_sl_goal NUMBER;
l_threshold NUMBER;
l_prev_media_id NUMBER;

l_prev_campaign_id NUMBER;
l_prev_schedule_id NUMBER;
l_prev_outcome_id NUMBER;
l_prev_result_id NUMBER;
l_prev_reason_id NUMBER;
l_prev_source_code_id NUMBER;
l_prev_dialing_method VARCHAR2(30);

l_begin_date DATE;
l_end_date DATE;

i NUMBER;
j NUMBER;

l_call_start_bucket VARCHAR2(5);
l_call_start_date DATE;

l_temp_flag VARCHAR2(1) := NULL;
l_transferred_agent VARCHAR2(1) := NULL;

l_currency_code varchar2(15);


l_test varchar2(1000);

--
--Define some variables to hold the bucket name and
--counter number of records already processed and if they are
--already processed then re-write to the same counter number
--
l_cs_bucket DATE := NULL; --call start time bucket
l_ts_bucket DATE := NULL; --talk start time bucket
l_te_bucket DATE := NULL; --talk end bucket
l_cs_counter NUMBER := NULL; --call start counter
l_ts_counter NUMBER := NULL; --talk start counter
l_te_counter NUMBER := NULL; --talk end counter

BEGIN

--g_debug_flag := 'Y';

--DBMS_PROFILER.START_PROFILER('ICI Test ');
--DBMS_PROFILER.FLUSH_DATA;

l_proc_table := ProcTable();

  --IF (g_debug_flag = 'Y') THEN
  write_log('Start of the procedure insert_half_hour_rows at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'Start insert_half_hour_rows ');

--insert into bixtest
--values ('Start insert_half_hour at ' ||
         --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
       --);
--commit;

--
--Initialize source collections
--
l_source_record := l_source_null_record;


  --IF (g_debug_flag = 'Y') THEN
--write_log('Initialized source collections');
  --END IF;
--
--Initialize target collections
--
l_target_record := l_target_null_record;

  --IF (g_debug_flag = 'Y') THEN
--write_log('Initialized target collections');
  --END IF;
--
--Retrieve any required profile values
--
IF (FND_PROFILE.DEFINED('BIX_CALL_THRESHOLD_SECS')) THEN
begin
   l_threshold := to_number(FND_PROFILE.VALUE('BIX_CALL_THRESHOLD_SECS'));
exception
   when others then
   l_threshold:=0;
end;
ELSE
   l_threshold := 0;
END IF;

IF (FND_PROFILE.DEFINED('BIX_CALL_SLGOAL_SECS')) THEN
begin
   l_sl_goal := to_number(FND_PROFILE.VALUE('BIX_CALL_SLGOAL_SECS'));
exception
when others then
  l_sl_goal:=0;
end;
ELSE
   l_sl_goal := 0;
END IF;

  --IF (g_debug_flag = 'Y') THEN
write_log('Opening call_info cursor at '||
           to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
         );
  --END IF;

--DBMS_PROFILER.START_PROFILER('ICI Test ');
--DBMS_PROFILER.FLUSH_DATA;

IF get_call_info%ISOPEN
THEN
   CLOSE get_call_info;
END IF;

OPEN get_call_info;

  LOOP  -- loop till all the records are bulk fetched and processed

  --IF (g_debug_flag = 'Y') THEN
--write_log('Before bulk fetch cursor at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
         --);

--
  --END IF;

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'Start fetch bulk collect    ');

--insert into bixtest values('before fetch');
--commit;
  /* Fetch the rows in bulk and process them row by row */
  FETCH get_call_info BULK COLLECT INTO
  l_source_record.media_id,
  l_source_record.server_group_id,
  l_source_record.classification_value,
  l_source_record.dnis_name,
  l_source_record.direction,
  l_source_record.media_item_type,
  l_source_record.media_start_time,
  l_source_record.media_end_time,
  l_source_record.abandon_flag ,
  l_source_record.transfer_flag,
  l_source_record.source_item_id,
  --l_source_record.milcs_id,
  l_source_record.resource_id,
  --l_source_record.segment_type,
  --l_source_record.segment_start_time,
  --l_source_record.segment_end_time,
  l_source_record.max_agent_talk_end,
  l_source_record.first_agent,
  l_source_record.call_talk_start,
  l_source_record.call_talk_end,
  l_source_record.int_id,
  l_source_record.outcome_id,
  l_source_record.result_id,
  l_source_record.reason_id,
  l_source_record.party_id,
  l_source_record.source_code,
  l_source_record.int_start_time,
  l_source_record.int_end_time,
  l_source_record.max_agent_int_end,
  l_source_record.act_id,
  l_source_record.act_start_time,
  l_source_record.action_id,
  l_source_record.action_item_id,
  l_source_record.doc_ref,
  l_source_record.doc_id,
l_source_record.ROUTE_MILCS_ID,
l_source_record.ROUTE_SEGS_START_TIME,
l_source_record.ROUTE_SEGS_END_TIME,
l_source_record.IVR_MILCS_ID,
l_source_record.IVR_SEGS_START_TIME,
l_source_record.IVR_SEGS_END_TIME,
l_source_record.FIRST_QUEUE,
l_source_record.LAST_QUEUE,
l_source_record.QUEUE_MILCS_ID,
l_source_record.QUEUE_SEGS_START_TIME,
l_source_record.QUEUE_SEGS_END_TIME,
l_source_record.AGENT_MILCS_ID,
l_source_record.AGENT_SEGS_START_TIME,
l_source_record.AGENT_SEGS_END_TIME
  LIMIT 5000;
  --LIMIT g_commit_chunk_size;

--insert into bixtest values('After fetch');
--commit;

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'Completed bulk fetch        ');

  --IF (g_debug_flag = 'Y') THEN
--write_log('Completed bulk fetch cursor at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
         --);
  --END IF;

  counter := 0;


    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'Start looping thru medias fetched ' );

IF l_source_record.media_id.COUNT > 0
THEN

  /* Loop through all the media rows returned by the cursor */
  FOR i in l_source_record.media_id.FIRST .. l_source_record.media_id.LAST LOOP

--
--Check if it is a new media - if so need to set call counts
--
IF l_source_record.media_id(i) <> l_prev_media_id
OR l_prev_media_id IS NULL
THEN
--
--Set the values for the CALL row
--
counter := counter + 1;

l_met_goal := NULL;
l_cumulative_queue := 0;

/*
IF to_number(to_char(l_source_record.media_start_time(i),'MI')) >= 30
THEN
l_target_record.period_start_time(counter) := lpad(to_char(l_source_record.media_start_time(i),
                                             'HH24:'),3,'0')
                                || '30';
ELSE
l_target_record.period_start_time(counter) := lpad(to_char(l_source_record.media_start_time(i),
                                             'HH24:'),3,'0')
                                || '00';
END IF;
*/
l_target_record.period_start_time(counter) := '00:00';

l_target_record.time_id(counter) := to_char(l_source_record.media_start_time(i),'J');
l_target_record.period_type_id(counter) := 1;
l_target_record.period_start_date(counter) := trunc(l_source_record.media_start_time(i));
l_target_record.day_of_week(counter) := to_char(l_source_record.media_start_time(i),'D');
l_target_record.direction(counter) := nvl(l_source_record.direction(i),'N/A');
l_target_record.media_item_type(counter) := nvl(l_source_record.media_item_type(i),-1);
l_target_record.resource_id(counter) := -1; -- since it is a CALL row
l_target_record.party_id(counter) := nvl(l_source_record.party_id(i),-1); -- need to set this down the line
l_target_record.classification_value(counter) := nvl(l_source_record.classification_value(i),'N/A');
l_target_record.dnis_name(counter) := nvl(l_source_record.dnis_name(i),'N/A');
l_target_record.server_group_id(counter) := nvl(l_source_record.server_group_id(i),-1);
l_target_record.outcome_id(counter) := -1; -- need to set this down the line
l_target_record.result_id(counter) := -1; -- need to set this down the line
l_target_record.reason_id(counter) := -1; -- need to set this down the line

IF l_source_record.direction(i) = 'INBOUND'
THEN
   l_target_record.partition_key(counter) := 'IC';
ELSIF l_source_record.direction(i) = 'OUTBOUND'
THEN
   l_target_record.partition_key(counter) := 'OC';
END IF;

l_target_record.call_calls_offered_total(counter) := 0;
l_target_record.call_calls_offered_above_th(counter) := 0;
l_target_record.call_calls_abandoned(counter) := 0;
l_target_record.call_calls_abandoned_us(counter) := 0;
l_target_record.call_calls_transferred(counter) := 0;
l_target_record.call_ivr_time(counter) := 0;
l_target_record.call_route_time(counter) := 0;
l_target_record.call_queue_time(counter) := 0;
l_target_record.CALL_TOT_QUEUE_TO_ABANDON(counter) := 0;
l_target_record.call_tot_queue_to_answer(counter) := 0;
l_target_record.call_talk_time(counter) := 0;
l_target_record.agent_talk_time_nac(counter) := 0;
l_target_record.agent_wrap_time_nac(counter) := 0;
l_target_record.agent_calls_tran_conf_to_nac(counter) := 0;
l_target_record.agent_cont_calls_hand_na(counter) := 0; --needs to be NULL
l_target_record.agent_cont_calls_tc_na(counter) := 0; --needs to be NULL
l_target_record.agent_calls_handled_total(counter) := 0;
l_target_record.agent_calls_handled_above_th(counter) := 0;
l_target_record.agent_calls_answered_by_goal(counter) := 0;
l_target_record.agent_sr_created(counter) := 0;
l_target_record.agent_leads_created(counter) := 0;
l_target_record.agent_leads_amount(counter) := 0;
l_target_record.agent_leads_converted_to_opp(counter) := 0;
l_target_record.agent_opportunities_created(counter) := 0;
l_target_record.agent_opportunities_won(counter) := 0;
l_target_record.agent_opportunities_won_amount(counter) := 0;
l_target_record.agent_opportunities_cross_sold(counter) := 0;
l_target_record.agent_opportunities_up_sold(counter) := 0;
l_target_record.agent_opportunities_declined(counter) := 0;
l_target_record.agent_opportunities_lost(counter) := 0;
l_target_record.agent_preview_time(counter) := 0;
l_target_record.agentcall_orr_count(counter) := 0;
l_target_record.agentcall_pr_count(counter) := 0;
l_target_record.agentcall_contact_count(counter) := 0;
l_target_record.call_cont_calls_offered_na(counter) := 0;
l_target_record.CALL_CONT_CALLS_HANDLED_TOT_NA(counter) := 0;
l_target_record.call_calls_hand_tot(counter) := 0;
l_target_record.call_calls_hand_above_th(counter) := 0;

--IF g_debug_flag = 'Y'
--THEN
   --write_log('New media, current size of l_proc_table is '||l_proc_table.COUNT);
--END IF;

   l_proc_table.TRIM(l_proc_table.COUNT);

--
--Store the call start bucket into a local variable
--so that we can compare it to the bucket for the continued
--call measures.
--
l_call_start_bucket := l_target_record.period_start_time(counter);
l_call_start_date  := l_target_record.period_start_date(counter);

      --
      --Get the campaign details - a call can be tied to only one
      --campaign schedule/campaign - hence we will do this at call level
      --
  --IF (g_debug_flag = 'Y') THEN
--write_log('Before get_campaign_details at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
         --);
  --END IF;

	 --
	 --This call should be enhanced to not go back to interactions
	 --table as we have that info for AI already
	 --
      get_campaign_details(l_source_record.media_id(i),
                           l_source_record.direction(i),
                           l_source_record.source_item_id(i),
                           l_source_record.source_code(i),
                           l_target_record.campaign_id(counter),
                           l_target_record.schedule_id(counter),
                           l_target_record.source_code_id(counter) ,
                           l_target_record.dialing_method(counter)
                           );

  --IF (g_debug_flag = 'Y') THEN
       --write_log ('Source code id retrieved is ' || l_target_record.source_code_id(counter) ||
           --'campaign id ' || l_target_record.campaign_id(counter) ||
           --'schedule_id ' || l_target_record.schedule_id(counter)
          --);
  --END IF;

--
--l_source_record.first_agent will indicate the l_earliest_agent
--l_source_record.call_talk_start will indicate call level talk start time.
--l_source_record.call_talk_end will indicate call level talk end time.
--

IF l_target_record.campaign_id(counter) IS NULL
THEN
   l_target_record.campaign_id(counter) := -1;
END IF;

IF l_target_record.schedule_id(counter) IS NULL
THEN
   l_target_record.schedule_id(counter) := -1;
END IF;

IF l_target_record.source_code_id(counter) IS NULL
THEN
   l_target_record.source_code_id(counter) := -1;
END IF;

IF l_target_record.dialing_method(counter) IS NULL
THEN
   l_target_record.dialing_method(counter) := 'N/A';
END IF;

      --
      --After the above call, campaign_id, schedule_id, source_code_id are set
      --
  --IF (g_debug_flag = 'Y') THEN
      --write_log('Setting previous values ');
  --END IF;
      l_prev_media_id := l_source_record.media_id(i);
      l_prev_campaign_id := l_target_record.campaign_id(counter);
      l_prev_schedule_id := l_target_record.schedule_id(counter);
      l_prev_source_code_id := l_target_record.source_code_id(counter);
      l_prev_dialing_method := l_target_record.dialing_method(counter);

      l_target_record.call_calls_offered_total(counter) := 1;

      IF (l_source_record.media_end_time(i)-
          l_source_record.media_start_time(i))*24*60*60 > l_threshold
      THEN
         l_target_record.call_calls_offered_above_th(counter) := 1;
      END IF;

      IF l_source_record.transfer_flag(i) = 'T'  -- transferred
      OR l_source_record.transfer_flag(i) = 'B'  -- both transferred and conferenced
      THEN
         l_target_record.call_calls_transferred(counter) := 1;
      END IF;

   --
   --At this point, for the new call, all dimensions have been set
   --for the call start bucket. Store the counter and bucket for
   --later re-use.
   --
write_log('Storing cs bucket in counter : ' || counter );
   l_cs_bucket := to_date(
            to_char(l_target_record.period_start_date(counter),'DD-MM-YYYY')||
                    ' ' || l_target_record.period_start_time(counter)
                          ,'DD-MM-YYYY HH24:MI');
   l_cs_counter := counter;
write_log('Storing cs bucket: ' || l_cs_bucket ||
          ' l_cs_counter: ' || l_cs_counter);

   --
   --Now loop through and stripe the call level talk time
   --

   IF l_source_record.call_talk_start(i) IS NOT NULL
   AND l_source_record.call_talk_end(i) IS NOT NULL
   THEN

   l_begin_date := l_source_record.call_talk_start(i);
   l_end_date   := l_source_record.call_talk_end(i);

   l_period_start := trunc(l_begin_date);

/**
   IF TO_NUMBER(TO_CHAR(l_begin_date,'MI')) >= 30
   THEN
      l_period_start :=
              TO_DATE(
               TO_CHAR(l_begin_date,'YYYY/MM/DD')||
               LPAD(TO_CHAR(l_begin_date,'HH24:'),3,'0')|| '30',
               'YYYY/MM/DDHH24:MI'
                      );
   ELSE
      l_period_start :=
              TO_DATE(
               TO_CHAR(l_begin_date,'YYYY/MM/DD')||
               LPAD(TO_CHAR(l_begin_date,'HH24:'),3,'0')|| '00',
               'YYYY/MM/DDHH24:MI'
                      );
   END IF;
   **/

   -- Variable to identify the first row of the talk time in the while loop
    l_row_counter := 0;

    WHILE ( l_period_start < l_end_date )
       LOOP

   IF l_cs_bucket = l_period_start
   THEN
write_log('Buckets matched in call talk time');
      --
      --Just set the measures for counter of l_cs_counter
      --other dimensions are already set. Also no need to
      --increase counter if this is the case
      --
      IF (l_row_counter = 0 )
      THEN
          l_segment_start := l_source_record.call_talk_start(i);
		--
		--Give calls handled to beginning of talk segment
		--
          l_target_record.call_calls_hand_tot(l_cs_counter) := 1;

          IF (l_source_record.media_end_time(i)-
              l_source_record.media_start_time(i))*24*60*60 > l_threshold
          THEN
                l_target_record.call_calls_hand_above_th(l_cs_counter) := 1;
          END IF;
      ELSE
          l_segment_start := l_period_start;
          l_target_record.CALL_CONT_CALLS_HANDLED_TOT_NA(l_cs_counter) := 1;
      END IF;

      --l_segment_end := l_period_start + 1/48;
      l_segment_end := l_period_start + 1;

      IF ( l_segment_end > l_end_date )
      THEN
        l_segment_end := l_end_date ;
      END IF;

      l_secs := round((l_segment_end - l_segment_start) * 24 * 3600);
      l_target_record.call_talk_time(l_cs_counter) := l_secs;

      l_row_counter := l_row_counter + 1;
      --l_period_start := l_period_start + 1/48;
      l_period_start := l_period_start + 1;

   ELSE

      counter := counter + 1;
     --
     --These are dimensions which need to be set every time a row is inserted:
     --
      l_target_record.period_type_id(counter) := 1;
      l_target_record.direction(counter) := nvl(l_source_record.direction(i),'N/A');
      l_target_record.media_item_type(counter) := nvl(l_source_record.media_item_type(i),'N/A');
      l_target_record.classification_value(counter) := nvl(l_source_record.classification_value(i),'N/A');
      l_target_record.dnis_name(counter) := nvl(l_source_record.dnis_name(i),'N/A');
      l_target_record.server_group_id(counter) := nvl(l_source_record.server_group_id(i),-1);
      l_target_record.resource_id(counter) := -1; --CALL ROW

      l_target_record.campaign_id(counter) := nvl(l_prev_campaign_id,-1);
      l_target_record.schedule_id(counter) := nvl(l_prev_schedule_id,-1);
      l_target_record.source_code_id(counter) := nvl(l_prev_source_code_id,-1);
      l_target_record.dialing_method(counter) := nvl(l_prev_dialing_method,'N/A');

      l_target_record.outcome_id(counter) := -1;
      l_target_record.result_id(counter) := -1;
      l_target_record.reason_id(counter) := -1;

      l_target_record.party_id(counter) := nvl(l_source_record.party_id(i),-1);

      IF l_source_record.direction(i) = 'INBOUND'
      THEN
         l_target_record.partition_key(counter) := 'IC';
      ELSIF l_source_record.direction(i) = 'OUTBOUND'
      THEN
         l_target_record.partition_key(counter) := 'OC';
      END IF;

l_target_record.call_calls_offered_total(counter) := 0;
l_target_record.call_calls_offered_above_th(counter) := 0;
l_target_record.call_calls_abandoned(counter) := 0;
l_target_record.call_calls_abandoned_us(counter) := 0;
l_target_record.call_calls_transferred(counter) := 0;
l_target_record.call_ivr_time(counter) := 0;
l_target_record.call_route_time(counter) := 0;
l_target_record.call_queue_time(counter) := 0;
l_target_record.CALL_TOT_QUEUE_TO_ABANDON(counter) := 0;
l_target_record.call_tot_queue_to_answer(counter) := 0;
l_target_record.call_talk_time(counter) := 0;
l_target_record.agent_talk_time_nac(counter) := 0;
l_target_record.agent_wrap_time_nac(counter) := 0;
l_target_record.agent_calls_tran_conf_to_nac(counter) := 0;
l_target_record.agent_cont_calls_hand_na(counter) := 0; --needs to be NULL
l_target_record.agent_cont_calls_tc_na(counter) := 0; --needs to be NULL
l_target_record.agent_calls_handled_total(counter) := 0;
l_target_record.agent_calls_handled_above_th(counter) := 0;
l_target_record.agent_calls_answered_by_goal(counter) := 0;
l_target_record.agent_sr_created(counter) := 0;
l_target_record.agent_leads_created(counter) := 0;
l_target_record.agent_leads_amount(counter) := 0;
l_target_record.agent_leads_converted_to_opp(counter) := 0;
l_target_record.agent_opportunities_created(counter) := 0;
l_target_record.agent_opportunities_won(counter) := 0;
l_target_record.agent_opportunities_won_amount(counter) := 0;
l_target_record.agent_opportunities_cross_sold(counter) := 0;
l_target_record.agent_opportunities_up_sold(counter) := 0;
l_target_record.agent_opportunities_declined(counter) := 0;
l_target_record.agent_opportunities_lost(counter) := 0;
l_target_record.agent_preview_time(counter) := 0;
l_target_record.agentcall_orr_count(counter) := 0;
l_target_record.agentcall_pr_count(counter) := 0;
l_target_record.agentcall_contact_count(counter) := 0;
l_target_record.call_cont_calls_offered_na(counter) := 0;
l_target_record.CALL_CONT_CALLS_HANDLED_TOT_NA(counter) := 0;
l_target_record.call_calls_hand_tot(counter) := 0;
l_target_record.call_calls_hand_above_th(counter) := 0;
      IF (l_row_counter = 0 )
      THEN
          l_segment_start := l_source_record.call_talk_start(i);
		--
		--Give calls handled to beginning of talk segment
		--
          l_target_record.call_calls_hand_tot(counter) := 1;

          IF (l_source_record.media_end_time(i)-
              l_source_record.media_start_time(i))*24*60*60 > l_threshold
          THEN
                l_target_record.call_calls_hand_above_th(counter) := 1;
          END IF;
      ELSE
          l_segment_start := l_period_start;
          l_target_record.CALL_CONT_CALLS_HANDLED_TOT_NA(counter) := 1;
      END IF;

      --l_segment_end := l_period_start + 1/48;
      l_segment_end := l_period_start + 1;
      IF ( l_segment_end > l_end_date )
      THEN
        l_segment_end := l_end_date ;
      END IF;

      l_target_record.time_id(counter) := to_char(l_period_start,'J');
      l_target_record.period_start_date(counter) := trunc(l_period_start);
      --l_target_record.period_start_time(counter) := to_char(l_period_start,'HH24:MI');
	 l_target_record.period_start_time(counter) := '00:00';
      l_target_record.day_of_week(counter) := to_char(l_period_start,'D');

      l_secs := round((l_segment_end - l_segment_start) * 24 * 3600);
      l_target_record.call_talk_time(counter) := l_secs;

      --
      --Set the continued call offered measures here
      --
      IF l_target_record.period_start_time(counter) <> l_call_start_bucket
      THEN
         IF check_if_processed(l_prev_media_id,'BUCKET',NULL,l_target_record.period_start_time(counter))='N'
         THEN
            l_target_record.call_cont_calls_offered_na(counter)     :=1;
            mark_as_processed(l_prev_media_id,'BUCKET',NULL,l_target_record.period_start_time(counter));
         END IF;
      END IF;

      l_row_counter := l_row_counter + 1;
      --l_period_start := l_period_start + 1/48;
      l_period_start := l_period_start + 1;

  END IF; -- for if which checks if bucket = call start bucket

    END LOOP;  -- end of WHILE loop for striping CALL TALK time across buckets

    END IF;  -- if to make sure l_begin is not null

  --IF (g_debug_flag = 'Y') THEN
--write_log('Completed CALL level TALK time at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
         --);
  --END IF;

 ELSE      -- for if which checks if this is a new media_id
      --
      --Its the same media as before - set the dimensions which need to be set
      --down the line
      --
      /***********************
      counter := counter+1;
      l_target_record.campaign_id(counter) := l_prev_campaign_id;
      l_target_record.schedule_id(counter) := l_prev_schedule_id;
      l_target_record.source_code_id(counter) := l_prev_source_code_id;
      --Cannot set ORR at call level as one call might have multiple ORRs
      l_target_record.outcome_id(counter) := -1;
      l_target_record.result_id(counter) := -1;
      l_target_record.reason_id(counter) := -1;
      ************************/
      NULL;

   END IF;  --for if which checks if this is a new media

   --
   --IN_QUEUE processing
   --
   IF check_if_processed(l_prev_media_id,'MILCS_ID',l_source_record.queue_milcs_id(i),NULL) = 'N'
   THEN

      mark_as_processed(l_prev_media_id,'MILCS_ID', l_source_record.queue_milcs_id(i),NULL);

      --
      --If this is the first IN_QUEUE segment for the media
      --then see if the call was ans within goal- this logic will
      --only work if CURSOR is sorted on MILCS_ID, as it is.
      --
      IF l_met_goal IS NULL
      THEN
         IF (l_source_record.queue_segs_end_time(i)-
             l_source_record.queue_segs_start_time(i)
            )*24*60*60 <= l_sl_goal
         THEN
            l_met_goal := 'Y';
         ELSE
            l_met_goal := 'N';
         END IF;
      END IF;

      --
      --Stripe queue time by half hour buckets.
      --

      l_begin_date := l_source_record.queue_segs_start_time(i);
      l_end_date := l_source_record.queue_segs_end_time(i);

l_period_start := trunc(l_begin_date);

/***
   IF TO_NUMBER(TO_CHAR(l_begin_date,'MI')) >= 30
   THEN
      l_period_start :=
              TO_DATE(
               TO_CHAR(l_begin_date,'YYYY/MM/DD')||
               LPAD(TO_CHAR(l_begin_date,'HH24:'),3,'0')|| '30',
               'YYYY/MM/DDHH24:MI'
                      );
   ELSE
      l_period_start :=
              TO_DATE(
               TO_CHAR(l_begin_date,'YYYY/MM/DD')||
               LPAD(TO_CHAR(l_begin_date,'HH24:'),3,'0')|| '00',
               'YYYY/MM/DDHH24:MI'
                      );
   END IF;
***/

   -- Variable to identify the first row of the talk time in the while loop
    l_row_counter := 0;

    WHILE ( l_period_start < l_end_date )
       LOOP

   --
   --Check if bucket is same as call start bucket
   --
   IF l_cs_bucket = l_period_start
   THEN
     --
     --Just set the measures for counter of l_cs_counter
     --other dimensions are already set. Also no need to
     --increase counter if this is the case
     --
      IF (l_row_counter = 0 )
      THEN
          l_segment_start := l_source_record.queue_segs_start_time(i);
      ELSE
          l_segment_start := l_period_start;
      END IF;

      --l_segment_end := l_period_start + 1/48;
      l_segment_end := l_period_start + 1;

      IF ( l_segment_end >= l_end_date )
      THEN

	   --This is the last queue bucket - set the abandon count
	   --and other measures which go to the last queue bucket
	   --This is the last queue bucket. We need to check if this is the
	   --last queue segment for this media_id since a call might have
	   --multiple QUEUE segments. Set the abandon count, total queue to
	   --answer, total queue to abandon etc only for the last bucket of
	   --the last queue segment.

        l_segment_end := l_end_date ;

	   --
	   --l_cumulative_queue is used to keep track of the cumulative queue times
	   --of all the QUEUE segments for a given media.
	   --
	   l_cumulative_queue := l_cumulative_queue +
                              (l_source_record.queue_segs_end_time(i)-
                               l_source_record.queue_segs_start_time(i)
						 )*24*60*60;

        IF l_source_record.abandon_flag(i) = 'Y'
           AND l_source_record.direction(i) = 'INBOUND' -- for AO calls abandone count goes to ORR row
	   AND l_source_record.queue_milcs_id(i) =
		  l_source_record.last_queue(i)
        THEN
           l_target_record.call_calls_abandoned(l_cs_counter) := 1;
	      --l_target_record.CALL_TOT_QUEUE_TO_ABANDON(l_cs_counter) :=
                                   --(l_source_record.queue_segs_end_time(i)-
                                   --l_source_record.queue_segs_start_time(i))*24*60*60;
	   l_target_record.CALL_TOT_QUEUE_TO_ABANDON(l_cs_counter) :=
	              nvl(l_target_record.CALL_TOT_QUEUE_TO_ABANDON(l_cs_counter),0) +
			    l_cumulative_queue;
	   l_cumulative_queue := 0;
        END IF;

	   IF l_source_record.first_agent(i) IS NOT NULL
	   AND l_source_record.queue_milcs_id(i) =
		  l_source_record.last_queue(i)
	   THEN
	      --l_target_record.call_tot_queue_to_answer(l_cs_counter) :=
                                   --(l_source_record.queue_segs_end_time(i)-
                                   --l_source_record.queue_segs_start_time(i))*24*60*60;
	     l_target_record.call_tot_queue_to_answer(l_cs_counter) :=
	              nvl(l_target_record.call_tot_queue_to_answer(l_cs_counter),0) +
			    l_cumulative_queue;

		IF l_cumulative_queue <= l_sl_goal
		THEN
		   l_met_goal := 'Y';
		ELSE
		   l_met_goal := 'N';
          END IF;

		l_cumulative_queue := 0;

	   END IF;

      END IF;

      l_secs := round((l_segment_end - l_segment_start) * 24 * 3600);
      l_target_record.call_queue_time(l_cs_counter) :=
         nvl(l_target_record.call_queue_time(l_cs_counter),0) + l_secs;

      l_row_counter := l_row_counter + 1;
      --l_period_start := l_period_start + 1/48;
      l_period_start := l_period_start + 1;

   ELSE

      counter := counter + 1;
      l_target_record.period_type_id(counter) := 1;
      l_target_record.direction(counter) := nvl(l_source_record.direction(i),'N/A');
      l_target_record.media_item_type(counter) := nvl(l_source_record.media_item_type(i),'N/A');
      l_target_record.classification_value(counter) := nvl(l_source_record.classification_value(i),'N/A');
      l_target_record.dnis_name(counter) := nvl(l_source_record.dnis_name(i),'N/A');
      l_target_record.server_group_id(counter) := nvl(l_source_record.server_group_id(i),-1);
      l_target_record.resource_id(counter) := -1; --CALL ROW

      l_target_record.campaign_id(counter) := nvl(l_prev_campaign_id,-1);
      l_target_record.schedule_id(counter) := nvl(l_prev_schedule_id,-1);
      l_target_record.source_code_id(counter) := nvl(l_prev_source_code_id,-1);
      l_target_record.dialing_method(counter) := nvl(l_prev_dialing_method,'N/A');

      l_target_record.outcome_id(counter) := -1;
      l_target_record.result_id(counter) := -1;
      l_target_record.reason_id(counter) := -1;

      l_target_record.party_id(counter) := nvl(l_source_record.party_id(i),-1);

      IF l_source_record.direction(i) = 'INBOUND'
      THEN
         l_target_record.partition_key(counter) := 'IC';
      ELSIF l_source_record.direction(i) = 'OUTBOUND'
      THEN
         l_target_record.partition_key(counter) := 'OC';
      END IF;
l_target_record.call_calls_offered_total(counter) := 0;
l_target_record.call_calls_offered_above_th(counter) := 0;
l_target_record.call_calls_abandoned(counter) := 0;
l_target_record.call_calls_abandoned_us(counter) := 0;
l_target_record.call_calls_transferred(counter) := 0;
l_target_record.call_ivr_time(counter) := 0;
l_target_record.call_route_time(counter) := 0;
l_target_record.call_queue_time(counter) := 0;
l_target_record.CALL_TOT_QUEUE_TO_ABANDON(counter) := 0;
l_target_record.call_tot_queue_to_answer(counter) := 0;
l_target_record.call_talk_time(counter) := 0;
l_target_record.agent_talk_time_nac(counter) := 0;
l_target_record.agent_wrap_time_nac(counter) := 0;
l_target_record.agent_calls_tran_conf_to_nac(counter) := 0;
l_target_record.agent_cont_calls_hand_na(counter) := 0; --needs to be NULL
l_target_record.agent_cont_calls_tc_na(counter) := 0; --needs to be NULL
l_target_record.agent_calls_handled_total(counter) := 0;
l_target_record.agent_calls_handled_above_th(counter) := 0;
l_target_record.agent_calls_answered_by_goal(counter) := 0;
l_target_record.agent_sr_created(counter) := 0;
l_target_record.agent_leads_created(counter) := 0;
l_target_record.agent_leads_amount(counter) := 0;
l_target_record.agent_leads_converted_to_opp(counter) := 0;
l_target_record.agent_opportunities_created(counter) := 0;
l_target_record.agent_opportunities_won(counter) := 0;
l_target_record.agent_opportunities_won_amount(counter) := 0;
l_target_record.agent_opportunities_cross_sold(counter) := 0;
l_target_record.agent_opportunities_up_sold(counter) := 0;
l_target_record.agent_opportunities_declined(counter) := 0;
l_target_record.agent_opportunities_lost(counter) := 0;
l_target_record.agent_preview_time(counter) := 0;
l_target_record.agentcall_orr_count(counter) := 0;
l_target_record.agentcall_pr_count(counter) := 0;
l_target_record.agentcall_contact_count(counter) := 0;
l_target_record.call_cont_calls_offered_na(counter) := 0;
l_target_record.CALL_CONT_CALLS_HANDLED_TOT_NA(counter) := 0;
l_target_record.call_calls_hand_tot(counter) := 0;
l_target_record.call_calls_hand_above_th(counter) := 0;

      IF (l_row_counter = 0 )
      THEN
          l_segment_start := l_source_record.queue_segs_start_time(i);
      ELSE
          l_segment_start := l_period_start;
      END IF;

      --l_segment_end := l_period_start + 1/48;
      l_segment_end := l_period_start + 1;

      IF ( l_segment_end >= l_end_date )
      THEN

	   --This is the last queue bucket - set the abandon count
	   --and other measures which go to the last queue bucket
	   --This is the last queue bucket. We need to check if this is the
	   --last queue segment for this media_id since a call might have
	   --multiple QUEUE segments. Set the abandon count, total queue to
	   --answer, total queue to abandon etc only for the last bucket of
	   --the last queue segment.

        l_segment_end := l_end_date ;
	   --
	   --l_cumulative_queue is used to keep track of the cumulative queue times
	   --of all the QUEUE segments for a given media.
	   --
	   l_cumulative_queue := l_cumulative_queue +
                              (l_source_record.queue_segs_end_time(i)-
                               l_source_record.queue_segs_start_time(i)
						 )*24*60*60;

        IF l_source_record.abandon_flag(i) = 'Y'
           AND l_source_record.direction(i) = 'INBOUND' -- for AO calls abandone count goes to ORR row
	   AND l_source_record.queue_milcs_id(i) =
		  l_source_record.last_queue(i)
        THEN
           l_target_record.call_calls_abandoned(counter) := 1;
	   --l_target_record.CALL_TOT_QUEUE_TO_ABANDON(counter) :=
                                   --(l_source_record.queue_segs_end_time(i)-
                                   --l_source_record.queue_segs_start_time(i))*24*60*60;
	   l_target_record.CALL_TOT_QUEUE_TO_ABANDON(counter) := l_cumulative_queue;
	   l_cumulative_queue := 0;
        END IF;

	   IF l_source_record.first_agent(i) IS NOT NULL
	   AND l_source_record.queue_milcs_id(i) =
		  l_source_record.last_queue(i)
	   THEN
	      --l_target_record.call_tot_queue_to_answer(counter) :=
                                   --(l_source_record.queue_segs_end_time(i)-
                                   --l_source_record.queue_segs_start_time(i))*24*60*60;
	      l_target_record.call_tot_queue_to_answer(counter) := l_cumulative_queue;

		 IF l_cumulative_queue <= l_sl_goal
		 THEN
		    l_met_goal := 'Y';
		 ELSE
		    l_met_goal := 'N';
           END IF;

           l_cumulative_queue := 0;

	   END IF;

      END IF;

      l_target_record.time_id(counter) := to_char(l_period_start,'J');
      l_target_record.period_start_date(counter) := trunc(l_period_start);
      --l_target_record.period_start_time(counter) := to_char(l_period_start,'HH24:MI');
	 l_target_record.period_start_time(counter) := '00:00';
      l_target_record.day_of_week(counter) := to_char(l_period_start,'D');

      l_secs := round((l_segment_end - l_segment_start) * 24 * 3600);
      l_target_record.call_queue_time(counter) := l_secs;

      --
      --Set the continued call measures here
      --
      IF l_target_record.period_start_time(counter) <> l_call_start_bucket
      THEN
         IF check_if_processed(l_prev_media_id,'BUCKET',NULL,l_target_record.period_start_time(counter))='N'
         THEN
  --IF (g_debug_flag = 'Y') THEN
            --write_log('Setting continued measures');
  --END IF;
            l_target_record.call_cont_calls_offered_na(counter)     :=1;
            mark_as_processed(l_prev_media_id,'BUCKET',NULL,l_target_record.period_start_time(counter));
         END IF;
      END IF;

      l_row_counter := l_row_counter + 1;
      --l_period_start := l_period_start + 1/48;
      l_period_start := l_period_start + 1;

   END IF; -- for if which checks if same as call start bucket

    END LOOP;  -- end of WHILE loop for striping queue time across half hour buckets

  --IF (g_debug_flag = 'Y') THEN
--write_log('Completed queue time at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
         --);
  --END IF;


      -------------------------------------------------------------------


   END IF;  -- for if which check if it is IN_QUEUE

   --
   --IVR Processing
   --

   IF check_if_processed(l_prev_media_id,'MILCS_ID',l_source_record.ivr_milcs_id(i),NULL) = 'N'
   THEN
      mark_as_processed(l_prev_media_id,'MILCS_ID', l_source_record.ivr_milcs_id(i),NULL);

      --
      --Stripe IVR time by half hour buckets.
      --
      l_begin_date := l_source_record.ivr_segs_start_time(i);
      l_end_date := l_source_record.ivr_segs_end_time(i);

l_period_start := trunc(l_begin_date);

/****
   IF TO_NUMBER(TO_CHAR(l_begin_date,'MI')) >= 30
   THEN
      l_period_start :=
              TO_DATE(
               TO_CHAR(l_begin_date,'YYYY/MM/DD')||
               LPAD(TO_CHAR(l_begin_date,'HH24:'),3,'0')|| '30',
               'YYYY/MM/DDHH24:MI'
                      );
   ELSE
      l_period_start :=
              TO_DATE(
               TO_CHAR(l_begin_date,'YYYY/MM/DD')||
               LPAD(TO_CHAR(l_begin_date,'HH24:'),3,'0')|| '00',
               'YYYY/MM/DDHH24:MI'
                      );
   END IF;
***/

   -- Variable to identify the first row of the talk time in the while loop
    l_row_counter := 0;

    WHILE ( l_period_start < l_end_date )
       LOOP

    --
    --Check if bucket is same as call start bucket
    --
    IF l_cs_bucket = l_period_start
    THEN
     --
     --Just set the measures for counter of l_cs_counter
     --other dimensions are already set. Also no need to
     --increase counter if this is the case
     --
      IF (l_row_counter = 0 )
      THEN
          l_segment_start := l_source_record.ivr_segs_start_time(i);
      ELSE
          l_segment_start := l_period_start;
      END IF;

      --l_segment_end := l_period_start + 1/48;
      l_segment_end := l_period_start + 1;
      IF ( l_segment_end > l_end_date )
      THEN
        l_segment_end := l_end_date ;
      END IF;

      l_secs := round((l_segment_end - l_segment_start) * 24 * 3600);
      l_target_record.call_ivr_time(l_cs_counter) := l_secs;

      l_row_counter := l_row_counter + 1;
      --l_period_start := l_period_start + 1/48;
      l_period_start := l_period_start + 1;

    ELSE

      counter := counter + 1;
      l_target_record.period_type_id(counter) := 1;
      l_target_record.direction(counter) := nvl(l_source_record.direction(i),'N/A');
      l_target_record.media_item_type(counter) := nvl(l_source_record.media_item_type(i),'N/A');
      l_target_record.classification_value(counter) := nvl(l_source_record.classification_value(i),'N/A');
      l_target_record.dnis_name(counter) := nvl(l_source_record.dnis_name(i),'N/A');
      l_target_record.server_group_id(counter) := nvl(l_source_record.server_group_id(i),-1);
      l_target_record.resource_id(counter) := -1; --CALL ROW

      l_target_record.campaign_id(counter) := nvl(l_prev_campaign_id,-1);
      l_target_record.schedule_id(counter) := nvl(l_prev_schedule_id,-1);
      l_target_record.source_code_id(counter) := nvl(l_prev_source_code_id,-1);
      l_target_record.dialing_method(counter) := nvl(l_prev_dialing_method,'N/A');

      l_target_record.outcome_id(counter) := -1;
      l_target_record.result_id(counter) := -1;
      l_target_record.reason_id(counter) := -1;

      l_target_record.party_id(counter) := nvl(l_source_record.party_id(i),-1);

      IF l_source_record.direction(i) = 'INBOUND'
      THEN
         l_target_record.partition_key(counter) := 'IC';
      ELSIF l_source_record.direction(i) = 'OUTBOUND'
      THEN
         l_target_record.partition_key(counter) := 'OC';
      END IF;
l_target_record.call_calls_offered_total(counter) := 0;
l_target_record.call_calls_offered_above_th(counter) := 0;
l_target_record.call_calls_abandoned(counter) := 0;
l_target_record.call_calls_abandoned_us(counter) := 0;
l_target_record.call_calls_transferred(counter) := 0;
l_target_record.call_ivr_time(counter) := 0;
l_target_record.call_route_time(counter) := 0;
l_target_record.call_queue_time(counter) := 0;
l_target_record.CALL_TOT_QUEUE_TO_ABANDON(counter) := 0;
l_target_record.call_tot_queue_to_answer(counter) := 0;
l_target_record.call_talk_time(counter) := 0;
l_target_record.agent_talk_time_nac(counter) := 0;
l_target_record.agent_wrap_time_nac(counter) := 0;
l_target_record.agent_calls_tran_conf_to_nac(counter) := 0;
l_target_record.agent_cont_calls_hand_na(counter) := 0; --needs to be NULL
l_target_record.agent_cont_calls_tc_na(counter) := 0; --needs to be NULL
l_target_record.agent_calls_handled_total(counter) := 0;
l_target_record.agent_calls_handled_above_th(counter) := 0;
l_target_record.agent_calls_answered_by_goal(counter) := 0;
l_target_record.agent_sr_created(counter) := 0;
l_target_record.agent_leads_created(counter) := 0;
l_target_record.agent_leads_amount(counter) := 0;
l_target_record.agent_leads_converted_to_opp(counter) := 0;
l_target_record.agent_opportunities_created(counter) := 0;
l_target_record.agent_opportunities_won(counter) := 0;
l_target_record.agent_opportunities_won_amount(counter) := 0;
l_target_record.agent_opportunities_cross_sold(counter) := 0;
l_target_record.agent_opportunities_up_sold(counter) := 0;
l_target_record.agent_opportunities_declined(counter) := 0;
l_target_record.agent_opportunities_lost(counter) := 0;
l_target_record.agent_preview_time(counter) := 0;
l_target_record.agentcall_orr_count(counter) := 0;
l_target_record.agentcall_pr_count(counter) := 0;
l_target_record.agentcall_contact_count(counter) := 0;
l_target_record.call_cont_calls_offered_na(counter) := 0;
l_target_record.CALL_CONT_CALLS_HANDLED_TOT_NA(counter) := 0;
l_target_record.call_calls_hand_tot(counter) := 0;
l_target_record.call_calls_hand_above_th(counter) := 0;

      IF (l_row_counter = 0 )
      THEN
          l_segment_start := l_source_record.ivr_segs_start_time(i);
      ELSE
          l_segment_start := l_period_start;
      END IF;

      --l_segment_end := l_period_start + 1/48;
      l_segment_end := l_period_start + 1;
      IF ( l_segment_end > l_end_date )
      THEN
        l_segment_end := l_end_date ;
      END IF;

      l_target_record.time_id(counter) := to_char(l_period_start,'J');
      l_target_record.period_start_date(counter) := trunc(l_period_start);
      --l_target_record.period_start_time(counter) := to_char(l_period_start,'HH24:MI');
	 l_target_record.period_start_time(counter) := '00:00';
      l_target_record.day_of_week(counter) := to_char(l_period_start,'D');

      l_secs := round((l_segment_end - l_segment_start) * 24 * 3600);
      l_target_record.call_ivr_time(counter) := l_secs;

      --
      --Set the continued call measures here
      --
      IF l_target_record.period_start_time(counter) <> l_call_start_bucket
      THEN
         IF check_if_processed(l_prev_media_id,'BUCKET',NULL,l_target_record.period_start_time(counter))='N'
         THEN
  --IF (g_debug_flag = 'Y') THEN
            --write_log('Setting continued measures');
  --END IF;
            l_target_record.call_cont_calls_offered_na(counter)     :=1;
            mark_as_processed(l_prev_media_id,'BUCKET',NULL,l_target_record.period_start_time(counter));
         END IF;
       END IF;

      l_row_counter := l_row_counter + 1;
      --l_period_start := l_period_start + 1/48;
      l_period_start := l_period_start + 1;

   END IF; --for if which checks if = call start bucket

    END LOOP;  -- end of WHILE loop for striping IVR time across buckets

   END IF;  --check if IVR processed

   --
   --ROUTE processing
   --

   IF check_if_processed(l_prev_media_id,'MILCS_ID',l_source_record.route_milcs_id(i),NULL) = 'N'
   THEN
      mark_as_processed(l_prev_media_id,'MILCS_ID', l_source_record.route_milcs_id(i),NULL);
      --
      --Stripe ROUTE time by half hour buckets.
      --
      l_begin_date := l_source_record.route_segs_start_time(i);
      l_end_date := l_source_record.route_segs_end_time(i);

l_period_start := trunc(l_begin_date);
/***
   IF TO_NUMBER(TO_CHAR(l_begin_date,'MI')) >= 30
   THEN
      l_period_start :=
              TO_DATE(
               TO_CHAR(l_begin_date,'YYYY/MM/DD')||
               LPAD(TO_CHAR(l_begin_date,'HH24:'),3,'0')|| '30',
               'YYYY/MM/DDHH24:MI'
                      );
   ELSE
      l_period_start :=
              TO_DATE(
               TO_CHAR(l_begin_date,'YYYY/MM/DD')||
               LPAD(TO_CHAR(l_begin_date,'HH24:'),3,'0')|| '00',
               'YYYY/MM/DDHH24:MI'
                      );
   END IF;
   ***/

   -- Variable to identify the first row of the talk time in the while loop
    l_row_counter := 0;

    WHILE ( l_period_start < l_end_date )
    LOOP

    --
    --Check if bucket is same as call start bucket
    --
    IF l_cs_bucket = l_period_start
    THEN
     --
     --Just set the measures for counter of l_cs_counter
     --other dimensions are already set. Also no need to
     --increase counter if this is the case
     --
      IF (l_row_counter = 0 )
      THEN
          l_segment_start := l_source_record.route_segs_start_time(i);
      ELSE
          l_segment_start := l_period_start;
      END IF;

      --l_segment_end := l_period_start + 1/48;
      l_segment_end := l_period_start + 1;
      IF ( l_segment_end > l_end_date )
      THEN
        l_segment_end := l_end_date ;
      END IF;

      l_secs := round((l_segment_end - l_segment_start) * 24 * 3600);
      l_target_record.call_route_time(l_cs_counter) := l_secs;

      l_row_counter := l_row_counter + 1;
      --l_period_start := l_period_start + 1/48;
      l_period_start := l_period_start + 1;

    ELSE

      counter := counter + 1;

      l_target_record.period_type_id(counter) := 1;
      l_target_record.direction(counter) := nvl(l_source_record.direction(i),'N/A');
      l_target_record.media_item_type(counter) := nvl(l_source_record.media_item_type(i),'N/A');
      l_target_record.classification_value(counter) := nvl(l_source_record.classification_value(i),'N/A');
      l_target_record.dnis_name(counter) := nvl(l_source_record.dnis_name(i),'N/A');
      l_target_record.server_group_id(counter) := nvl(l_source_record.server_group_id(i),-1);
      l_target_record.resource_id(counter) := -1; --CALL ROW

      l_target_record.campaign_id(counter) := nvl(l_prev_campaign_id,-1);
      l_target_record.schedule_id(counter) := nvl(l_prev_schedule_id,-1);
      l_target_record.source_code_id(counter) := nvl(l_prev_source_code_id,-1);
      l_target_record.dialing_method(counter) := nvl(l_prev_dialing_method,'N/A');

      l_target_record.outcome_id(counter) := -1;
      l_target_record.result_id(counter) := -1;
      l_target_record.reason_id(counter) := -1;

      l_target_record.party_id(counter) := nvl(l_source_record.party_id(i),-1);

      IF l_source_record.direction(i) = 'INBOUND'
      THEN
         l_target_record.partition_key(counter) := 'IC';
      ELSIF l_source_record.direction(i) = 'OUTBOUND'
      THEN
         l_target_record.partition_key(counter) := 'OC';
      END IF;
l_target_record.call_calls_offered_total(counter) := 0;
l_target_record.call_calls_offered_above_th(counter) := 0;
l_target_record.call_calls_abandoned(counter) := 0;
l_target_record.call_calls_abandoned_us(counter) := 0;
l_target_record.call_calls_transferred(counter) := 0;
l_target_record.call_ivr_time(counter) := 0;
l_target_record.call_route_time(counter) := 0;
l_target_record.call_queue_time(counter) := 0;
l_target_record.CALL_TOT_QUEUE_TO_ABANDON(counter) := 0;
l_target_record.call_tot_queue_to_answer(counter) := 0;
l_target_record.call_talk_time(counter) := 0;
l_target_record.agent_talk_time_nac(counter) := 0;
l_target_record.agent_wrap_time_nac(counter) := 0;
l_target_record.agent_calls_tran_conf_to_nac(counter) := 0;
l_target_record.agent_cont_calls_hand_na(counter) := 0; --needs to be NULL
l_target_record.agent_cont_calls_tc_na(counter) := 0; --needs to be NULL
l_target_record.agent_calls_handled_total(counter) := 0;
l_target_record.agent_calls_handled_above_th(counter) := 0;
l_target_record.agent_calls_answered_by_goal(counter) := 0;
l_target_record.agent_sr_created(counter) := 0;
l_target_record.agent_leads_created(counter) := 0;
l_target_record.agent_leads_amount(counter) := 0;
l_target_record.agent_leads_converted_to_opp(counter) := 0;
l_target_record.agent_opportunities_created(counter) := 0;
l_target_record.agent_opportunities_won(counter) := 0;
l_target_record.agent_opportunities_won_amount(counter) := 0;
l_target_record.agent_opportunities_cross_sold(counter) := 0;
l_target_record.agent_opportunities_up_sold(counter) := 0;
l_target_record.agent_opportunities_declined(counter) := 0;
l_target_record.agent_opportunities_lost(counter) := 0;
l_target_record.agent_preview_time(counter) := 0;
l_target_record.agentcall_orr_count(counter) := 0;
l_target_record.agentcall_pr_count(counter) := 0;
l_target_record.agentcall_contact_count(counter) := 0;
l_target_record.call_cont_calls_offered_na(counter) := 0;
l_target_record.CALL_CONT_CALLS_HANDLED_TOT_NA(counter) := 0;
l_target_record.call_calls_hand_tot(counter) := 0;
l_target_record.call_calls_hand_above_th(counter) := 0;

      IF (l_row_counter = 0 )
      THEN
          l_segment_start := l_source_record.route_segs_start_time(i);
      ELSE
          l_segment_start := l_period_start;
      END IF;

      --l_segment_end := l_period_start + 1/48;
      l_segment_end := l_period_start + 1;
      IF ( l_segment_end > l_end_date )
      THEN
        l_segment_end := l_end_date ;
      END IF;

      l_target_record.time_id(counter) := to_char(l_period_start,'J');
      l_target_record.period_start_date(counter) := trunc(l_period_start);
      --l_target_record.period_start_time(counter) := to_char(l_period_start,'HH24:MI');
	 l_target_record.period_start_time(counter) := '00:00';
      l_target_record.day_of_week(counter) := to_char(l_period_start,'D');

      l_secs := round((l_segment_end - l_segment_start) * 24 * 3600);
      l_target_record.call_route_time(counter) := l_secs;

      --
      --Set the continued call measures here
      --
      IF l_target_record.period_start_time(counter) <> l_call_start_bucket
      THEN
         IF check_if_processed(l_prev_media_id,'BUCKET',NULL,l_target_record.period_start_time(counter))='N'
         THEN
            l_target_record.call_cont_calls_offered_na(counter)     := 1;
            mark_as_processed(l_prev_media_id,'BUCKET',NULL,l_target_record.period_start_time(counter));
      END IF;
      END IF;

      l_row_counter := l_row_counter + 1;
      --l_period_start := l_period_start + 1/48;
      l_period_start := l_period_start + 1;

   END IF; --to check if same as call start bucket

    END LOOP;  -- end of WHILE loop for striping queue time across half hour buckets

   END IF; --if ROUTE not processed

--
--This is the end of processing for the call level row.
--Now start the agent level row after incrementing counter.
--

IF l_source_record.agent_milcs_id(i) IS NOT NULL --means with_agent segment is there
THEN

IF check_if_processed(l_prev_media_id,'MILCS_ID',l_source_record.agent_milcs_id(i),NULL) = 'N'
THEN
	 mark_as_processed(l_prev_media_id,'MILCS_ID', l_source_record.agent_milcs_id(i),NULL);

  --IF (g_debug_flag = 'Y') THEN
--write_log('Starting agent processing');
  --END IF;
   --
   --Agent level processing
   --
   counter := counter+1;

  --IF (g_debug_flag = 'Y') THEN
--write_log('Counter value agent proc is '||counter);
  --END IF;

   --
   --These are the dimensions which need to be set every time a row is inserted:
   --

  --IF (g_debug_flag = 'Y') THEN
--write_log('Completed Extending agent level dimensions ');
  --END IF;
   --
   --Figure out what the bucket start time is at the call level
   --This will be used for period start time
   --
   --select lpad(to_char(l_source_record.segment_start_time(i),'HH24:'),3,'0') ||
            --decode(sign(to_number(to_char(l_source_record.segment_start_time(i)
            --,'MI'))-29),0,'00',1,'30',-1,'00')
   --into l_target_record.period_start_time(counter)
   --from dual;

l_target_record.period_start_time(counter) := '00:00';

/***
   IF to_number(to_char(l_source_record.agent_segs_start_time(i),'MI')) >= 30
   THEN
      l_target_record.period_start_time(counter):=
          lpad(to_char(l_source_record.agent_segs_start_time(i),'HH24:'),3,'0')||'30';
   ELSE
      l_target_record.period_start_time(counter) :=
             lpad(to_char(l_source_record.agent_segs_start_time(i),'HH24:'),3,'0') ||
             '00';
   END IF;
   ****/

   l_target_record.time_id(counter) := to_char(l_source_record.agent_segs_start_time(i),'J');
   l_target_record.period_type_id(counter) := 1;
   l_target_record.period_start_date(counter) := trunc(l_source_record.agent_segs_start_time(i));
   l_target_record.day_of_week(counter) := to_char(l_source_record.agent_segs_start_time(i),'D');
l_target_record.media_id(counter) := l_source_record.media_id(i);
   l_target_record.direction(counter) := l_source_record.direction(i);
   l_target_record.media_item_type(counter) := nvl(l_source_record.media_item_type(i),'N/A');
   l_target_record.resource_id(counter) := nvl(l_source_record.resource_id(i),-1);
   l_target_record.party_id(counter) := nvl(l_source_record.party_id(i),-1);
   l_target_record.classification_value(counter) := nvl(l_source_record.classification_value(i),'N/A');
   l_target_record.dnis_name(counter) := nvl(l_source_record.dnis_name(i),'N/A');
   l_target_record.server_group_id(counter) := nvl(l_source_record.server_group_id(i),-1);

   l_target_record.campaign_id(counter) := nvl(l_prev_campaign_id,-1);
   l_target_record.schedule_id(counter) := nvl(l_prev_schedule_id,-1);
   l_target_record.source_code_id(counter) := nvl(l_prev_source_code_id,-1);
      l_target_record.dialing_method(counter) := nvl(l_prev_dialing_method,'N/A');

   l_target_record.outcome_id(counter) := -1; -- need to set this down the line
   l_target_record.result_id(counter) := -1; -- need to set this down the line
   l_target_record.reason_id(counter) := -1; -- need to set this down the line

   IF l_source_record.direction(i) = 'INBOUND'
   THEN
      l_target_record.partition_key(counter) := 'IA';
   ELSIF l_source_record.direction(i) = 'OUTBOUND'
   THEN
      l_target_record.partition_key(counter) := 'OA';
   END IF;

l_target_record.call_calls_offered_total(counter) := 0;
l_target_record.call_calls_offered_above_th(counter) := 0;
l_target_record.call_calls_abandoned(counter) := 0;
l_target_record.call_calls_abandoned_us(counter) := 0;
l_target_record.call_calls_transferred(counter) := 0;
l_target_record.call_ivr_time(counter) := 0;
l_target_record.call_route_time(counter) := 0;
l_target_record.call_queue_time(counter) := 0;
l_target_record.CALL_TOT_QUEUE_TO_ABANDON(counter) := 0;
l_target_record.call_tot_queue_to_answer(counter) := 0;
l_target_record.call_talk_time(counter) := 0;
l_target_record.agent_talk_time_nac(counter) := 0;
l_target_record.agent_wrap_time_nac(counter) := 0;
l_target_record.agent_calls_tran_conf_to_nac(counter) := 0;
l_target_record.agent_cont_calls_hand_na(counter) := 0; --needs to be NULL
l_target_record.agent_cont_calls_tc_na(counter) := 0; --needs to be NULL
l_target_record.agent_calls_handled_total(counter) := 0;
l_target_record.agent_calls_handled_above_th(counter) := 0;
l_target_record.agent_calls_answered_by_goal(counter) := 0;
l_target_record.agent_sr_created(counter) := 0;
l_target_record.agent_leads_created(counter) := 0;
l_target_record.agent_leads_amount(counter) := 0;
l_target_record.agent_leads_converted_to_opp(counter) := 0;
l_target_record.agent_opportunities_created(counter) := 0;
l_target_record.agent_opportunities_won(counter) := 0;
l_target_record.agent_opportunities_won_amount(counter) := 0;
l_target_record.agent_opportunities_cross_sold(counter) := 0;
l_target_record.agent_opportunities_up_sold(counter) := 0;
l_target_record.agent_opportunities_declined(counter) := 0;
l_target_record.agent_opportunities_lost(counter) := 0;
l_target_record.agent_preview_time(counter) := 0;
l_target_record.agentcall_orr_count(counter) := 0;
l_target_record.agentcall_pr_count(counter) := 0;
l_target_record.agentcall_contact_count(counter) := 0;
l_target_record.call_cont_calls_offered_na(counter) := 0;
l_target_record.CALL_CONT_CALLS_HANDLED_TOT_NA(counter) := 0;
l_target_record.call_calls_hand_tot(counter) := 0;
l_target_record.call_calls_hand_above_th(counter) := 0;
   --
   --These are the measures which need to be set every time a row is inserted
   --

  --IF (g_debug_flag = 'Y') THEN
--write_log('Completed Extending agent level measures ');
  --END IF;

  --IF (g_debug_flag = 'Y') THEN
--write_log('Completed initializing agent level measures ');
  --END IF;

   --IF l_source_record.resource_id(i) = l_earliest_agent

   l_temp_flag := NULL;
   l_transferred_agent := NULL;

   IF l_source_record.resource_id(i) = l_source_record.first_agent(i)
   THEN
	 l_transferred_agent := 'N';
	 --
	 --This means this agent was the first agent to answer the call and hence
	 --gets credit for the handled count.
	 --However, in some cases the same agent might have records in the segments
	 --multiple times - example in case of transfers. For such cases we need
	 --to make sure the agent has not already been given credit for this call.
	 --If we dont do this then we will double count the calls.
      --

	 l_temp_flag := check_if_processed(l_prev_media_id,'AGENT_BUCKET',
	         l_source_record.resource_id(i),
		    l_target_record.period_start_time(counter));

      IF l_temp_flag = 'N'
      THEN

         mark_as_processed(l_prev_media_id,'AGENT_BUCKET',
	         l_source_record.resource_id(i),
		    l_target_record.period_start_time(counter));

	    --
         --Set the calls hand and other measures which go only to first agent
         --
         l_target_record.agent_calls_handled_total(counter) := 1;

         IF (l_source_record.media_end_time(i)-
             l_source_record.media_start_time(i)
            )*24*60*60 > l_threshold
         THEN
            l_target_record.agent_calls_handled_above_th(counter) := 1;
         ELSE
            l_target_record.agent_calls_handled_above_th(counter) := 0;
         END IF;

         IF l_met_goal = 'Y'
         THEN
            l_target_record.agent_calls_answered_by_goal(counter) := 1;
         ELSE
            l_target_record.agent_calls_answered_by_goal(counter) := 0;
         END IF;

	 ELSIF l_temp_flag = 'A' --this means agent was processed but not bucket
						--set the continued calls measure
      THEN

          l_target_record.agent_cont_calls_hand_na(counter) := 1;

      ELSIF l_temp_flag = 'N'
	 THEN
	    NULL;  --this means the agents bucket was already processed so do not
			 --assign any counts as it will double count

      END IF;  -- for if which checks if agent has been processed already for media

   ELSE     -- this means not the earliest agent to handle call
	 l_transferred_agent := 'Y';
      l_target_record.agent_calls_tran_conf_to_nac(counter) := 1;
   END IF;  -- for check for earliest agent to handle call

--
--First set the AGENT level talk time and wrap time which need
--splitting across multiple half hour buckets
--

--
--Talk time
--
   l_begin_date := l_source_record.agent_segs_start_time(i);
   l_end_date := l_source_record.agent_segs_end_time(i);

  --IF (g_debug_flag = 'Y') THEN
   --write_log('Starting talk time at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss') ||
           --'with begin of '||to_char(l_begin_date,'mm/dd/yyyy hh24:mi:ss') ||
           --'end of ' ||to_char(l_end_date,'mm/dd/yyyy hh24:mi:ss')
         --);
  --END IF;

l_period_start := trunc(l_begin_date);
/***
   IF TO_NUMBER(TO_CHAR(l_begin_date,'MI')) >= 30
   THEN
      l_period_start :=
              TO_DATE(
               TO_CHAR(l_begin_date,'YYYY/MM/DD')||
               LPAD(TO_CHAR(l_begin_date,'HH24:'),3,'0')|| '30',
               'YYYY/MM/DDHH24:MI'
                      );
   ELSE
      l_period_start :=
              TO_DATE(
               TO_CHAR(l_begin_date,'YYYY/MM/DD')||
               LPAD(TO_CHAR(l_begin_date,'HH24:'),3,'0')|| '00',
               'YYYY/MM/DDHH24:MI'
                      );
   END IF;
**/

   -- Variable to identify the first row of the talk time in the while loop
    l_row_counter := 0;

    WHILE ( l_period_start < l_end_date )
       LOOP

      counter := counter + 1;
  --IF (g_debug_flag = 'Y') THEN
      --write_log('Counter value talk time is '||counter);
  --END IF;
      --
      --These are dimensions which need to be set every time a row is inserted:
      --

      l_target_record.period_type_id(counter) := 1;

l_target_record.media_id(counter) := l_source_record.media_id(i);
      l_target_record.direction(counter) := nvl(l_source_record.direction(i),'N/A');
      l_target_record.media_item_type(counter) := nvl(l_source_record.media_item_type(i),'N/A');
      l_target_record.classification_value(counter) := nvl(l_source_record.classification_value(i),'N/A');
      l_target_record.dnis_name(counter) := nvl(l_source_record.dnis_name(i),'N/A');
      l_target_record.server_group_id(counter) := nvl(l_source_record.server_group_id(i),-1);
      l_target_record.resource_id(counter) := nvl(l_source_record.resource_id(i),-1);

      l_target_record.campaign_id(counter) := nvl(l_prev_campaign_id,-1);
      l_target_record.schedule_id(counter) := nvl(l_prev_schedule_id,-1);
      l_target_record.source_code_id(counter) := nvl(l_prev_source_code_id,-1);
      l_target_record.dialing_method(counter) := nvl(l_prev_dialing_method,'N/A');

      l_target_record.outcome_id(counter) := -1;
      l_target_record.result_id(counter) := -1;
      l_target_record.reason_id(counter) := -1;

      l_target_record.party_id(counter) := nvl(l_source_record.party_id(i),-1);

      IF l_source_record.direction(i) = 'INBOUND'
      THEN
         l_target_record.partition_key(counter) := 'IA';
      ELSIF l_source_record.direction(i) = 'OUTBOUND'
      THEN
         l_target_record.partition_key(counter) := 'OA';
      END IF;

l_target_record.call_calls_offered_total(counter) := 0;
l_target_record.call_calls_offered_above_th(counter) := 0;
l_target_record.call_calls_abandoned(counter) := 0;
l_target_record.call_calls_abandoned_us(counter) := 0;
l_target_record.call_calls_transferred(counter) := 0;
l_target_record.call_ivr_time(counter) := 0;
l_target_record.call_route_time(counter) := 0;
l_target_record.call_queue_time(counter) := 0;
l_target_record.CALL_TOT_QUEUE_TO_ABANDON(counter) := 0;
l_target_record.call_tot_queue_to_answer(counter) := 0;
l_target_record.call_talk_time(counter) := 0;
l_target_record.agent_talk_time_nac(counter) := 0;
l_target_record.agent_wrap_time_nac(counter) := 0;
l_target_record.agent_calls_tran_conf_to_nac(counter) := 0;
l_target_record.agent_cont_calls_hand_na(counter) := 0; --needs to be NULL
l_target_record.agent_cont_calls_tc_na(counter) := 0; --needs to be NULL
l_target_record.agent_calls_handled_total(counter) := 0;
l_target_record.agent_calls_handled_above_th(counter) := 0;
l_target_record.agent_calls_answered_by_goal(counter) := 0;
l_target_record.agent_sr_created(counter) := 0;
l_target_record.agent_leads_created(counter) := 0;
l_target_record.agent_leads_amount(counter) := 0;
l_target_record.agent_leads_converted_to_opp(counter) := 0;
l_target_record.agent_opportunities_created(counter) := 0;
l_target_record.agent_opportunities_won(counter) := 0;
l_target_record.agent_opportunities_won_amount(counter) := 0;
l_target_record.agent_opportunities_cross_sold(counter) := 0;
l_target_record.agent_opportunities_up_sold(counter) := 0;
l_target_record.agent_opportunities_declined(counter) := 0;
l_target_record.agent_opportunities_lost(counter) := 0;
l_target_record.agent_preview_time(counter) := 0;
l_target_record.agentcall_orr_count(counter) := 0;
l_target_record.agentcall_pr_count(counter) := 0;
l_target_record.agentcall_contact_count(counter) := 0;
l_target_record.call_cont_calls_offered_na(counter) := 0;
l_target_record.CALL_CONT_CALLS_HANDLED_TOT_NA(counter) := 0;
l_target_record.call_calls_hand_tot(counter) := 0;
l_target_record.call_calls_hand_above_th(counter) := 0;
      --
      --These are the measures which need to be set every time a row is inserted
      --

      IF (l_row_counter = 0 )
      THEN
          l_segment_start := l_source_record.agent_segs_start_time(i);
      ELSE
          l_segment_start := l_period_start;
		IF l_transferred_agent = 'N'
		THEN
             l_target_record.agent_cont_calls_hand_na(counter) := 1;
          ELSIF l_transferred_agent = 'Y'
		THEN
		   l_target_record.agent_cont_calls_tc_na(counter) := 1;
          END IF;
      END IF;

      --l_segment_end := l_period_start + 1/48;
      l_segment_end := l_period_start + 1;
      IF ( l_segment_end > l_end_date )
      THEN
        l_segment_end := l_end_date ;
      END IF;

      l_secs := round((l_segment_end - l_segment_start) * 24 * 3600);

  --IF (g_debug_flag = 'Y') THEN
      --write_log('Completed calculating l_secs value ');
      --write_log('Setting agent talk time period start date and time ');
      --write_log('l_period_start is ' || l_period_start);
  --END IF;

      l_target_record.time_id(counter) := to_char(l_period_start,'J');
      l_target_record.period_start_date(counter) := trunc(l_period_start);
      --l_target_record.period_start_time(counter) := to_char(l_period_start,'HH24:MI');
	 l_target_record.period_start_time(counter) := '00:00';
      l_target_record.day_of_week(counter) := to_char(l_period_start,'D');

  --IF (g_debug_flag = 'Y') THEN
      --write_log('Setting agent l_agent_talk_time');
  --END IF;
      l_target_record.agent_talk_time_nac(counter) := l_secs;

      l_row_counter := l_row_counter + 1;
      --l_period_start := l_period_start + 1/48;
      l_period_start := l_period_start + 1;

    END LOOP;  -- end of WHILE loop for striping talk time across half hour buckets

  --IF (g_debug_flag = 'Y') THEN
--write_log('Completed talk time at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
         --);
  --END IF;

mark_as_processed(l_prev_media_id,'MILCS_ID',l_source_record.agent_milcs_id(i),NULL);

END IF; -- for if does check_if_processed for the segment

IF check_if_processed(l_prev_media_id,'WRAP',l_source_record.resource_id(i),NULL) = 'N'
THEN

  --IF (g_debug_flag = 'Y') THEN
--write_log('Started wrap time at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
         --);
  --END IF;
--
--Calculate wrap time here
--Wrap time will be equal to the max(interaction end date) - max(talk end date)
--for that agent and media.
--

l_begin_date := l_source_record.max_agent_talk_end(i);
l_end_date   := l_source_record.max_agent_int_end(i);

/*
--The agent may not perform any wrap up.
--Or he may complete the wrap up before releasing the call.
--So in some cases the interaction end time might be lesser than talk end time.
*/

if l_begin_date > l_end_date then
	l_begin_date := l_end_date;
end if;

l_period_start := trunc(l_begin_date);
/**
   IF TO_NUMBER(TO_CHAR(l_begin_date,'MI')) >= 30
   THEN
      l_period_start :=
              TO_DATE(
               TO_CHAR(l_begin_date,'YYYY/MM/DD')||
               LPAD(TO_CHAR(l_begin_date,'HH24:'),3,'0')|| '30',
               'YYYY/MM/DDHH24:MI'
                      );
   ELSE
      l_period_start :=
              TO_DATE(
               TO_CHAR(l_begin_date,'YYYY/MM/DD')||
               LPAD(TO_CHAR(l_begin_date,'HH24:'),3,'0')|| '00',
               'YYYY/MM/DDHH24:MI'
                      );
   END IF;
   **/

l_row_counter := 0;

 WHILE ( l_period_start < l_end_date )
    LOOP
      IF (l_row_counter = 0 )
      THEN
        --l_segment_start := l_begin_date;
          --l_segment_start := l_max_talk_end_date_time;  --CHECK THIS!!
          l_segment_start := l_begin_date;
      ELSE
        --
        --Wrap time is being striped to the next half hour bucket
        --
        l_segment_start := l_period_start;
      END IF;

      --l_segment_end := l_period_start + 1/48;
      l_segment_end := l_period_start + 1;
      IF ( l_segment_end > l_end_date )
      THEN
        l_segment_end := l_end_date ;
      END IF;

      l_secs := round((l_segment_end - l_segment_start) * 24 * 3600);

      counter := counter + 1;

   --
   --These are the dimensions which need to be set every time a row is inserted:
   --

   l_target_record.period_type_id(counter) := 1;
l_target_record.media_id(counter) := l_source_record.media_id(i);
   l_target_record.direction(counter) := nvl(l_source_record.direction(i),'N/A');
   l_target_record.media_item_type(counter) := nvl(l_source_record.media_item_type(i),'N/A');
   l_target_record.classification_value(counter) := nvl(l_source_record.classification_value(i),'N/A');
   l_target_record.dnis_name(counter) := nvl(l_source_record.dnis_name(i),'N/A');
   l_target_record.server_group_id(counter) := nvl(l_source_record.server_group_id(i),-1);
   l_target_record.resource_id(counter) := nvl(l_source_record.resource_id(i),-1);

   l_target_record.campaign_id(counter) := nvl(l_prev_campaign_id,-1);
   l_target_record.schedule_id(counter) := nvl(l_prev_schedule_id,-1);
   l_target_record.source_code_id(counter) := nvl(l_prev_source_code_id,-1);
      l_target_record.dialing_method(counter) := nvl(l_prev_dialing_method,'N/A');

   l_target_record.outcome_id(counter) := -1;
   l_target_record.result_id(counter) := -1;
   l_target_record.reason_id(counter) := -1;

   l_target_record.party_id(counter) := nvl(l_source_record.party_id(i),-1);

   IF l_source_record.direction(i) = 'INBOUND'
   THEN
      l_target_record.partition_key(counter) := 'IA';
   ELSIF l_source_record.direction(i) = 'OUTBOUND'
   THEN
      l_target_record.partition_key(counter) := 'OA';
   END IF;

   --
   --These are the measures which need to be set every time a row is inserted
   --
l_target_record.call_calls_offered_total(counter) := 0;
l_target_record.call_calls_offered_above_th(counter) := 0;
l_target_record.call_calls_abandoned(counter) := 0;
l_target_record.call_calls_abandoned_us(counter) := 0;
l_target_record.call_calls_transferred(counter) := 0;
l_target_record.call_ivr_time(counter) := 0;
l_target_record.call_route_time(counter) := 0;
l_target_record.call_queue_time(counter) := 0;
l_target_record.CALL_TOT_QUEUE_TO_ABANDON(counter) := 0;
l_target_record.call_tot_queue_to_answer(counter) := 0;
l_target_record.call_talk_time(counter) := 0;
l_target_record.agent_talk_time_nac(counter) := 0;
l_target_record.agent_wrap_time_nac(counter) := 0;
l_target_record.agent_calls_tran_conf_to_nac(counter) := 0;
l_target_record.agent_cont_calls_hand_na(counter) := 0; --needs to be NULL
l_target_record.agent_cont_calls_tc_na(counter) := 0; --needs to be NULL
l_target_record.agent_calls_handled_total(counter) := 0;
l_target_record.agent_calls_handled_above_th(counter) := 0;
l_target_record.agent_calls_answered_by_goal(counter) := 0;
l_target_record.agent_sr_created(counter) := 0;
l_target_record.agent_leads_created(counter) := 0;
l_target_record.agent_leads_amount(counter) := 0;
l_target_record.agent_leads_converted_to_opp(counter) := 0;
l_target_record.agent_opportunities_created(counter) := 0;
l_target_record.agent_opportunities_won(counter) := 0;
l_target_record.agent_opportunities_won_amount(counter) := 0;
l_target_record.agent_opportunities_cross_sold(counter) := 0;
l_target_record.agent_opportunities_up_sold(counter) := 0;
l_target_record.agent_opportunities_declined(counter) := 0;
l_target_record.agent_opportunities_lost(counter) := 0;
l_target_record.agent_preview_time(counter) := 0;
l_target_record.agentcall_orr_count(counter) := 0;
l_target_record.agentcall_pr_count(counter) := 0;
l_target_record.agentcall_contact_count(counter) := 0;
l_target_record.call_cont_calls_offered_na(counter) := 0;
l_target_record.CALL_CONT_CALLS_HANDLED_TOT_NA(counter) := 0;
l_target_record.call_calls_hand_tot(counter) := 0;
l_target_record.call_calls_hand_above_th(counter) := 0;

  --IF (g_debug_flag = 'Y') THEN
   --write_log('Setting wrap time period start date and time ');
   --write_log('l_period_start is ' || l_period_start);
  --END IF;

   l_target_record.time_id(counter) := to_char(l_period_start,'J');
   l_target_record.period_start_date(counter) := trunc(l_period_start);
   --l_target_record.period_start_time(counter) := to_char(l_period_start,'HH24:MI');
	 l_target_record.period_start_time(counter) := '00:00';
   l_target_record.day_of_week(counter) := to_char(l_period_start,'D');

  --IF (g_debug_flag = 'Y') THEN
   --write_log('Setting l_wrap_time to l_secs  ');
  --END IF;

   l_target_record.agent_wrap_time_nac(counter) := l_secs;

   l_row_counter := l_row_counter + 1;
   --l_period_start := l_period_start + 1/48;
   l_period_start := l_period_start + 1;

   END LOOP;  -- end of WHILE loop

   mark_as_processed(l_prev_media_id,'WRAP', l_source_record.resource_id(i),NULL);

END IF;  -- for if which checks if wrap has been calculated for agent

  --IF (g_debug_flag = 'Y') THEN
--write_log('Completed wrap time at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
         --);
  --END IF;

END IF;  -- for if which chekcs if this a WITH_AGENT segment
         --WRAP HAS to be calculated only if it is a WITH AGENT segment

  --IF (g_debug_flag = 'Y') THEN
--write_log('Exited loop which sets wrap time ');
  --END IF;

--
--Now set the AGENT level measures which do not require
--splitting across multiple half hour buckets
--

  --IF (g_debug_flag = 'Y') THEN
--write_log('Started interaction processing at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
         --);
  --END IF;

IF l_source_record.int_id(i) IS NOT NULL
AND check_if_processed(l_prev_media_id,'INTERACTION_ID',l_source_record.int_id(i),NULL) = 'N'
THEN

   counter := counter+1;
  --IF (g_debug_flag = 'Y') THEN
   --write_log('Int_id: ' || l_source_record.int_id(i) ||' counter is '||counter);
  --END IF;

   --
   --Within this loop calculate the outcome, result, reason,
   --

   --
   --These are the dimensions which need to be set every time a row is inserted:
   --

l_target_record.period_start_time(counter) := '00:00';
/***
   IF to_number(to_char(l_source_record.int_start_time(i),'MI')) >= 30
   THEN
      l_target_record.period_start_time(counter) :=
             lpad(to_char(l_source_record.int_start_time(i),'HH24:'),3,'0') ||
             '30';
   ELSE
      l_target_record.period_start_time(counter) :=
             lpad(to_char(l_source_record.int_start_time(i),'HH24:'),3,'0') ||
             '00';
   END IF;
   ****/

  --IF (g_debug_flag = 'Y') THEN
   --write_log('Period start time after '||l_target_record.period_start_time(counter));
   --write_log('Int start time is ' || l_source_record.int_start_time(i));
  --END IF;

   l_target_record.time_id(counter) := to_char(l_source_record.int_start_time(i),'J');
   l_target_record.period_type_id(counter) := 1;
   l_target_record.period_start_date(counter) := trunc(l_source_record.int_start_time(i));
   l_target_record.day_of_week(counter) := to_char(l_source_record.int_start_time(i),'D');
l_target_record.media_id(counter) := l_source_record.media_id(i);
   l_target_record.direction(counter) := nvl(l_source_record.direction(i),'N/A');
   l_target_record.media_item_type(counter) := nvl(l_source_record.media_item_type(i),'N/A');
   l_target_record.resource_id(counter) := nvl(l_source_record.resource_id(i),-1);
   l_target_record.classification_value(counter) := nvl(l_source_record.classification_value(i),'N/A');
   l_target_record.dnis_name(counter) := nvl(l_source_record.dnis_name(i),'N/A');
   l_target_record.server_group_id(counter) := nvl(l_source_record.server_group_id(i),-1);

   l_target_record.campaign_id(counter) := nvl(l_prev_campaign_id,-1);
   l_target_record.schedule_id(counter) := nvl(l_prev_schedule_id,-1);
   l_target_record.source_code_id(counter) := nvl(l_prev_source_code_id,-1);
      l_target_record.dialing_method(counter) := nvl(l_prev_dialing_method,'N/A');

   l_target_record.party_id(counter) := nvl(l_source_record.party_id(i),-1);

   --
   --Only for interaction records, it is possible that the
   --resource_id at the segment level may be NULL. In this case
   --we assign the ORRs to the call level. This is the way it was
   --done in DCF. One thing we might miss with this approach is if
   --the interaction had a valid resource_id - example for WITHDRAWN
   --DURING RINGING then we miss the fact that this particular agent
   --initiated the call. This is because this agent does not have a
   --WITH_AGENT segment. Might need to look into enhancing this.
   --
   --Also note that it is not possible to get a report which gives
   --call measures such as TALK time by ORR. This is becasue a call
   --can have multiple ORR values. There is no way to say which ORR
   --combination had which talk times. This is the same in DCF version.
   --
   IF l_source_record.direction(i) = 'INBOUND'
   AND l_source_record.resource_id(i) IS NOT NULL
   THEN
      l_target_record.partition_key(counter) := 'IA';
   ELSIF l_source_record.direction(i) = 'INBOUND'
   AND l_source_record.resource_id(i) IS NULL
   THEN
      l_target_record.partition_key(counter) := 'IC';
   ELSIF l_source_record.direction(i) = 'OUTBOUND'
   AND l_source_record.resource_id(i) IS NOT NULL
   THEN
      l_target_record.partition_key(counter) := 'OA';
   ELSIF l_source_record.direction(i) = 'OUTBOUND'
   AND l_source_record.resource_id(i) IS NULL
   THEN
      l_target_record.partition_key(counter) := 'OC';
   END IF;
l_target_record.call_calls_offered_total(counter) := 0;
l_target_record.call_calls_offered_above_th(counter) := 0;
l_target_record.call_calls_abandoned(counter) := 0;
l_target_record.call_calls_abandoned_us(counter) := 0;
l_target_record.call_calls_transferred(counter) := 0;
l_target_record.call_ivr_time(counter) := 0;
l_target_record.call_route_time(counter) := 0;
l_target_record.call_queue_time(counter) := 0;
l_target_record.CALL_TOT_QUEUE_TO_ABANDON(counter) := 0;
l_target_record.call_tot_queue_to_answer(counter) := 0;
l_target_record.call_talk_time(counter) := 0;
l_target_record.agent_talk_time_nac(counter) := 0;
l_target_record.agent_wrap_time_nac(counter) := 0;
l_target_record.agent_calls_tran_conf_to_nac(counter) := 0;
l_target_record.agent_cont_calls_hand_na(counter) := 0; --needs to be NULL
l_target_record.agent_cont_calls_tc_na(counter) := 0; --needs to be NULL
l_target_record.agent_calls_handled_total(counter) := 0;
l_target_record.agent_calls_handled_above_th(counter) := 0;
l_target_record.agent_calls_answered_by_goal(counter) := 0;
l_target_record.agent_sr_created(counter) := 0;
l_target_record.agent_leads_created(counter) := 0;
l_target_record.agent_leads_amount(counter) := 0;
l_target_record.agent_leads_converted_to_opp(counter) := 0;
l_target_record.agent_opportunities_created(counter) := 0;
l_target_record.agent_opportunities_won(counter) := 0;
l_target_record.agent_opportunities_won_amount(counter) := 0;
l_target_record.agent_opportunities_cross_sold(counter) := 0;
l_target_record.agent_opportunities_up_sold(counter) := 0;
l_target_record.agent_opportunities_declined(counter) := 0;
l_target_record.agent_opportunities_lost(counter) := 0;
l_target_record.agent_preview_time(counter) := 0;
l_target_record.agentcall_orr_count(counter) := 0;
l_target_record.agentcall_pr_count(counter) := 0;
l_target_record.agentcall_contact_count(counter) := 0;
l_target_record.call_cont_calls_offered_na(counter) := 0;
l_target_record.CALL_CONT_CALLS_HANDLED_TOT_NA(counter) := 0;
l_target_record.call_calls_hand_tot(counter) := 0;
l_target_record.call_calls_hand_above_th(counter) := 0;

  --IF (g_debug_flag = 'Y') THEN
   --write_log('Setting outcome result reason ');
   --write_log('Period start time is ' || l_target_record.period_start_time(counter));
  --END IF;

   l_target_record.outcome_id(counter) := nvl(l_source_record.outcome_id(i),-1);
   l_target_record.result_id(counter) := nvl(l_source_record.result_id(i),-1);
   l_target_record.reason_id(counter) := nvl(l_source_record.reason_id(i),-1);

   l_target_record.agentcall_orr_count(counter) := 1;
  --IF (g_debug_flag = 'Y') THEN
   --write_log('Set orr count to 1 for counter ' || counter);
  --END IF;

   IF l_target_record.outcome_id(counter) = 11 --ABANDON
   THEN
      l_target_record.call_calls_abandoned(counter) := 1;
   END IF;

   IF l_target_record.outcome_id(counter) = 7
   THEN
      l_target_record.agentcall_contact_count(counter) := 1;
   ELSE
      l_target_record.agentcall_contact_count(counter) := 0;
   END IF;

   SELECT nvl(max(decode(positive_response_flag,'Y',1,0)),0)
   INTO l_target_record.agentcall_pr_count(counter)
   FROM jtf_ih_results_b
   WHERE result_id = l_target_record.result_id(counter);

   /* Add count for US Predictive Abandoned rate */
   IF l_source_record.abandon_flag(i) = 'U' and l_source_record.direction(i) = 'OUTBOUND'
   THEN
      l_target_record.call_calls_abandoned_us(counter):= 1;
   ELSE
      l_target_record.call_calls_abandoned_us(counter) := 0;
   END IF;

  --IF (g_debug_flag = 'Y') THEN
   --write_log('Set pr count to '|| l_target_record.agentcall_pr_count(counter) ||
             --' for counter '   || counter);
  --END IF;

   mark_as_processed(l_prev_media_id,'INTERACTION_ID',l_source_record.int_id(i),NULL);

END IF;  -- for if which checks if int_id has been processed

--
--Process business measures
--
IF l_source_record.act_id(i) IS NOT NULL
AND check_if_processed(l_prev_media_id,'ACTIVITY_ID',l_source_record.act_id(i),NULL)='N'
THEN

   --
   --Take care of case where it might be a fresh set of records from cursor
   --in which case you cannot depend on counter value
   --
   IF counter = 0
   THEN
   write_log ('Entered counter = 0 if ');

   counter := counter+1;
   --
   --These are the dimensions which need to be set every time a row is inserted:
   --
l_target_record.period_start_time(counter) := '00:00';

/***
   IF to_number(to_char(l_source_record.int_start_time(i),'MI')) >= 30
   THEN
      l_target_record.period_start_time(counter) :=
             lpad(to_char(l_source_record.int_start_time(i),'HH24:'),3,'0') ||
             '30';
   ELSE
      l_target_record.period_start_time(counter) :=
             lpad(to_char(l_source_record.int_start_time(i),'HH24:'),3,'0') ||
             '00';
   END IF;
***/

   l_target_record.time_id(counter) := to_char(l_source_record.int_start_time(i),'J');
   l_target_record.period_type_id(counter) := 1;
   l_target_record.period_start_date(counter) := trunc(l_source_record.int_start_time(i));
   l_target_record.day_of_week(counter) := to_char(l_source_record.int_start_time(i),'D');
l_target_record.media_id(counter) := l_source_record.media_id(i);
   l_target_record.direction(counter) := nvl(l_source_record.direction(i),'N/A');
   l_target_record.media_item_type(counter) := nvl(l_source_record.media_item_type(i),'N/A');
   l_target_record.resource_id(counter) := nvl(l_source_record.resource_id(i),-1);
   l_target_record.classification_value(counter) := nvl(l_source_record.classification_value(i),'N/A');
   l_target_record.dnis_name(counter) := nvl(l_source_record.dnis_name(i),'N/A');
   l_target_record.server_group_id(counter) := nvl(l_source_record.server_group_id(i),-1);

   l_target_record.campaign_id(counter) := nvl(l_prev_campaign_id,-1);
   l_target_record.schedule_id(counter) := nvl(l_prev_schedule_id,-1);
   l_target_record.source_code_id(counter) := nvl(l_prev_source_code_id,-1);
      l_target_record.dialing_method(counter) := nvl(l_prev_dialing_method,'N/A');

   l_target_record.party_id(counter) := nvl(l_source_record.party_id(i),-1);

   IF l_source_record.direction(i) = 'INBOUND'
   AND l_source_record.resource_id(i) IS NOT NULL
   THEN
      l_target_record.partition_key(counter) := 'IA';
   ELSIF l_source_record.direction(i) = 'INBOUND'
   AND l_source_record.resource_id(i) IS NULL
   THEN
      l_target_record.partition_key(counter) := 'IC';
   ELSIF l_source_record.direction(i) = 'OUTBOUND'
   AND l_source_record.resource_id(i) IS NOT NULL
   THEN
      l_target_record.partition_key(counter) := 'OA';
   ELSIF l_source_record.direction(i) = 'OUTBOUND'
   AND l_source_record.resource_id(i) IS NULL
   THEN
      l_target_record.partition_key(counter) := 'OC';
   END IF;
l_target_record.call_calls_offered_total(counter) := 0;
l_target_record.call_calls_offered_above_th(counter) := 0;
l_target_record.call_calls_abandoned(counter) := 0;
l_target_record.call_calls_abandoned_us(counter) := 0;
l_target_record.call_calls_transferred(counter) := 0;
l_target_record.call_ivr_time(counter) := 0;
l_target_record.call_route_time(counter) := 0;
l_target_record.call_queue_time(counter) := 0;
l_target_record.CALL_TOT_QUEUE_TO_ABANDON(counter) := 0;
l_target_record.call_tot_queue_to_answer(counter) := 0;
l_target_record.call_talk_time(counter) := 0;
l_target_record.agent_talk_time_nac(counter) := 0;
l_target_record.agent_wrap_time_nac(counter) := 0;
l_target_record.agent_calls_tran_conf_to_nac(counter) := 0;
l_target_record.agent_cont_calls_hand_na(counter) := 0; --needs to be NULL
l_target_record.agent_cont_calls_tc_na(counter) := 0; --needs to be NULL
l_target_record.agent_calls_handled_total(counter) := 0;
l_target_record.agent_calls_handled_above_th(counter) := 0;
l_target_record.agent_calls_answered_by_goal(counter) := 0;
l_target_record.agent_sr_created(counter) := 0;
l_target_record.agent_leads_created(counter) := 0;
l_target_record.agent_leads_amount(counter) := 0;
l_target_record.agent_leads_converted_to_opp(counter) := 0;
l_target_record.agent_opportunities_created(counter) := 0;
l_target_record.agent_opportunities_won(counter) := 0;
l_target_record.agent_opportunities_won_amount(counter) := 0;
l_target_record.agent_opportunities_cross_sold(counter) := 0;
l_target_record.agent_opportunities_up_sold(counter) := 0;
l_target_record.agent_opportunities_declined(counter) := 0;
l_target_record.agent_opportunities_lost(counter) := 0;
l_target_record.agent_preview_time(counter) := 0;
l_target_record.agentcall_orr_count(counter) := 0;
l_target_record.agentcall_pr_count(counter) := 0;
l_target_record.agentcall_contact_count(counter) := 0;
l_target_record.call_cont_calls_offered_na(counter) := 0;
l_target_record.CALL_CONT_CALLS_HANDLED_TOT_NA(counter) := 0;
l_target_record.call_calls_hand_tot(counter) := 0;
l_target_record.call_calls_hand_above_th(counter) := 0;

   l_target_record.outcome_id(counter) := nvl(l_source_record.outcome_id(i),-1);
   l_target_record.result_id(counter) := nvl(l_source_record.result_id(i),-1);
   l_target_record.reason_id(counter) := nvl(l_source_record.reason_id(i),-1);

   END IF;  --for counter if
-----------------------------------------------------------------
--
-- Action id values are:
-- 1 = Add, 6=Update, 7=Upsell, 8=Xsell, 13=SR Created
-- 14= SR Updated, 27=Close opportunity
--
-- Action Item Id values are:
-- 8=Lead, 17=SR, 21=Opportunity, 22=Sales Lead
--

if l_source_record.action_id(i) = 1
then -- item added/created
   if l_source_record.action_item_id(i) = 22   -- Sales lead
   OR l_source_record.action_item_id(i) = 8 -- Lead
   then
      l_target_record.agent_leads_created(counter) := l_target_record.agent_leads_created(counter)+ 1;
      --Start 002 . Comment out call to get_lead_amount
      /********
      if l_source_record.doc_ref(i) = 'LEAD' or
         l_source_record.doc_ref(i) = 'ASTSC_LEAD'
      then
         get_lead_amount( l_source_record.doc_id(i),
                       l_target_record.agent_leads_amount(i),
                       l_currency_code);
      end if;
      *******/
      --End 002 . Comment out call to get_lead_amount
   elsif l_source_record.action_item_id(i) = 21
   then  -- Opportunity
      l_target_record.agent_opportunities_created(counter) := 1;
      --Start 002 . Comment out call to get_opportunity_amount
      /********
      if l_source_record.doc_ref(i) = 'OPPORTUNITY' or
         l_source_record.doc_ref(i) = 'ASTSC_OPP'
      then
         get_opportunity_amount( l_source_record.doc_id(i),
                                 l_target_record.agent_opportunities_won(counter),
                                 l_target_record.agent_opportunities_won_amount(counter),
                                 l_currency_code);
      end if;
      *******/
      --End 002 . Comment out call to get_opportunity_amount
   elsif l_source_record.action_item_id(i) = 17
   then  -- Service Request
      l_target_record.agent_sr_created(counter) := l_target_record.agent_sr_created(counter)+ 1;
   end if;
end if;

-- Service request specific action id value
if l_source_record.action_id(i) = 13
then -- sr created specific code
   l_target_record.agent_sr_created(counter) :=  l_target_record.agent_sr_created(counter)+ 1;
end if;

if l_source_record.action_id(i) = 8
then -- cross sold
   if l_source_record.action_item_id(i) = 21
   then
      l_target_record.agent_opportunities_cross_sold(counter) := l_target_record.agent_opportunities_cross_sold(counter)+1;
   end if;
elsif l_source_record.action_id(i) = 7
then -- up sold
   if l_source_record.action_item_id(i) = 21
   then
      l_target_record.agent_opportunities_up_sold(counter) := l_target_record.agent_opportunities_up_sold(counter)+1;
   end if;
elsif l_source_record.action_id(i) = 26
then -- declined
   if l_source_record.action_item_id(i) = 21
   then
      l_target_record.agent_opportunities_declined(counter) := l_target_record.agent_opportunities_declined(counter)+1;
   end if;
end if;

  --IF (g_debug_flag = 'Y') THEN
--write_log('Completed business measure at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
         --);
  --END IF;
mark_as_processed(l_prev_media_id,'ACTIVITY_ID',l_source_record.act_id(i),NULL);

END IF; -- for if which checks if ACT_ID has been processed
         --this is the end of the agent measures
/*****
--
--Process business measures
--
  --IF (g_debug_flag = 'Y') THEN
--write_log('Starting business measure at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
         --);
  --END IF;

IF l_source_record.act_id(i) IS NOT NULL
AND check_if_processed(l_prev_media_id,'ACTIVITY_ID',l_source_record.act_id(i),NULL)='N'
THEN

   counter := counter+1;
   --
   --These are the dimensions which need to be set every time a row is inserted:
   --

   l_target_record.period_start_time(counter) := '00:00';

   l_target_record.time_id(counter) := to_char(l_source_record.int_start_time(i),'J');
   l_target_record.period_type_id(counter) := 1;
   l_target_record.period_start_date(counter) := trunc(l_source_record.int_start_time(i));
   l_target_record.day_of_week(counter) := to_char(l_source_record.int_start_time(i),'D');
l_target_record.media_id(counter) := l_source_record.media_id(i);
   l_target_record.direction(counter) := nvl(l_source_record.direction(i),'N/A');
   l_target_record.media_item_type(counter) := nvl(l_source_record.media_item_type(i),'N/A');
   l_target_record.resource_id(counter) := nvl(l_source_record.resource_id(i),-1);
   l_target_record.classification_value(counter) := nvl(l_source_record.classification_value(i),'N/A');
   l_target_record.dnis_name(counter) := nvl(l_source_record.dnis_name(i),'N/A');
   l_target_record.server_group_id(counter) := nvl(l_source_record.server_group_id(i),-1);

   l_target_record.campaign_id(counter) := nvl(l_prev_campaign_id,-1);
   l_target_record.schedule_id(counter) := nvl(l_prev_schedule_id,-1);
   l_target_record.source_code_id(counter) := nvl(l_prev_source_code_id,-1);
      l_target_record.dialing_method(counter) := nvl(l_prev_dialing_method,'N/A');

   l_target_record.outcome_id(counter) := nvl(l_source_record.outcome_id(i),-1);
   l_target_record.result_id(counter) := nvl(l_source_record.result_id(i),-1);
   l_target_record.reason_id(counter) := nvl(l_source_record.reason_id(i),-1);

   l_target_record.party_id(counter) := nvl(l_source_record.party_id(i),-1);

   IF l_source_record.direction(i) = 'INBOUND'
   THEN
      l_target_record.partition_key(counter) := 'IA';
   ELSIF l_source_record.direction(i) = 'OUTBOUND'
   THEN
      l_target_record.partition_key(counter) := 'OA';
   END IF;
l_target_record.call_calls_offered_total(counter) := 0;
l_target_record.call_calls_offered_above_th(counter) := 0;
l_target_record.call_calls_abandoned(counter) := 0;
l_target_record.call_calls_transferred(counter) := 0;
l_target_record.call_ivr_time(counter) := 0;
l_target_record.call_route_time(counter) := 0;
l_target_record.call_queue_time(counter) := 0;
l_target_record.CALL_TOT_QUEUE_TO_ABANDON(counter) := 0;
l_target_record.call_tot_queue_to_answer(counter) := 0;
l_target_record.call_talk_time(counter) := 0;
l_target_record.agent_talk_time_nac(counter) := 0;
l_target_record.agent_wrap_time_nac(counter) := 0;
l_target_record.agent_calls_tran_conf_to_nac(counter) := 0;
l_target_record.agent_cont_calls_hand_na(counter) := 0; --needs to be NULL
l_target_record.agent_cont_calls_tc_na(counter) := 0; --needs to be NULL
l_target_record.agent_calls_handled_total(counter) := 0;
l_target_record.agent_calls_handled_above_th(counter) := 0;
l_target_record.agent_calls_answered_by_goal(counter) := 0;
l_target_record.agent_sr_created(counter) := 0;
l_target_record.agent_leads_created(counter) := 0;
l_target_record.agent_leads_amount(counter) := 0;
l_target_record.agent_leads_converted_to_opp(counter) := 0;
l_target_record.agent_opportunities_created(counter) := 0;
l_target_record.agent_opportunities_won(counter) := 0;
l_target_record.agent_opportunities_won_amount(counter) := 0;
l_target_record.agent_opportunities_cross_sold(counter) := 0;
l_target_record.agent_opportunities_up_sold(counter) := 0;
l_target_record.agent_opportunities_declined(counter) := 0;
l_target_record.agent_opportunities_lost(counter) := 0;
l_target_record.agent_preview_time(counter) := 0;
l_target_record.agentcall_orr_count(counter) := 0;
l_target_record.agentcall_pr_count(counter) := 0;
l_target_record.agentcall_contact_count(counter) := 0;
l_target_record.call_cont_calls_offered_na(counter) := 0;
l_target_record.CALL_CONT_CALLS_HANDLED_TOT_NA(counter) := 0;
l_target_record.call_calls_hand_tot(counter) := 0;
l_target_record.call_calls_hand_above_th(counter) := 0;

-----------------------------------------------------------------
--
-- Action id values are:
-- 1 = Add, 6=Update, 7=Upsell, 8=Xsell, 13=SR Created
-- 14= SR Updated, 27=Close opportunity
--
-- Action Item Id values are:
-- 8=Lead, 17=SR, 21=Opportunity, 22=Sales Lead
--

if l_source_record.action_id(i) = 1
then -- item added/created
   if l_source_record.action_item_id(i) = 22   -- Sales lead
   OR l_source_record.action_item_id(i) = 8 -- Lead
   then
      l_target_record.agent_leads_created(counter) := 1;
      if l_source_record.doc_ref(i) = 'LEAD' or
         l_source_record.doc_ref(i) = 'ASTSC_LEAD'
      then
         get_lead_amount( l_source_record.doc_id(i),
                       l_target_record.agent_leads_amount(i),
                       l_currency_code);
      end if;
   elsif l_source_record.action_item_id(i) = 21
   then  -- Opportunity
      l_target_record.agent_opportunities_created(counter) := 1;
      if l_source_record.doc_ref(i) = 'OPPORTUNITY' or
         l_source_record.doc_ref(i) = 'ASTSC_OPP'
      then
         get_opportunity_amount( l_source_record.doc_id(i),
                                 l_target_record.agent_opportunities_won(counter),
                                 l_target_record.agent_opportunities_won_amount(counter),
                                 l_currency_code);
      end if;
   elsif l_source_record.action_item_id(i) = 17
   then  -- Service Request
      l_target_record.agent_sr_created(counter) := 1;
   end if;
end if;

-- Service request specific action id value
if l_source_record.action_id(i) = 13
then -- sr created specific code
   l_target_record.agent_sr_created(counter) := 1;
end if;

if l_source_record.action_id(i) = 8
then -- cross sold
   if l_source_record.action_item_id(i) = 21
   then
      l_target_record.agent_opportunities_cross_sold(counter) := 1;
   end if;
elsif l_source_record.action_id(i) = 7
then -- up sold
   if l_source_record.action_item_id(i) = 21
   then
      l_target_record.agent_opportunities_up_sold(counter) := 1;
   end if;
elsif l_source_record.action_id(i) = 26
then -- declined
   if l_source_record.action_item_id(i) = 21
   then
      l_target_record.agent_opportunities_declined(counter) := 1;
   end if;
end if;

  --IF (g_debug_flag = 'Y') THEN
--write_log('Completed business measure at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
         --);
  --END IF;
mark_as_processed(l_prev_media_id,'ACTIVITY_ID',l_source_record.act_id(i),NULL);

END IF; -- for if which checks if ACT_ID has been processed
         --this is the end of the agent measures

******/

END LOOP; -- media id cursor loop ends when LIMIT clause is reached

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
		   --'End loop for PL/SQL processing 5000 medias in FETCH ');

-- Bulk merge all the rows into the staging area

  --IF (g_debug_flag = 'Y') THEN
write_log('Starting bulk merge into staging table at '||
           to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')  ||
		 'for ' || counter || ' number of rows '
		 );
  --END IF;

--insert into bixtest
--values ('Start merge of '|| counter || 'at ' ||
         --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
       --);

--insert into bixtest
--values ('Merging at ' ||
         --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
       --);

commit;

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'Before merge of staging table ');

write_log('Max counter is ' || counter);
write_log('Max value of the collection is '||l_target_record.time_id.COUNT);

--for i in 1 .. counter
--loop
--l_target_record.media_id(i) := 0;
--end loop;

--for i in 1 .. counter
--loop
--write_log('l_target.media_id is ' || nvl(l_target_record.media_id(i),-1));
--write_log('l_target.time_id is ' || l_target_record.time_id(i));
--write_log('l_target.direction is ' || nvl(l_target_record.direction(i),-1));
--end loop;

FORALL k IN 1 .. counter
INSERT /*+ APPEND */
INTO bix_call_details_stg STG
(
 time_id                                ,
 period_type_id                         ,
 period_start_date                      ,
 period_start_time                      ,
 day_of_week                            ,
 direction                              ,
 media_item_type                        ,
 resource_id                            ,
 party_id                               ,
 classification_value                   ,
 dnis_name                              ,
 server_group_id                        ,
 campaign_id                            ,
 schedule_id                            ,
 outcome_id                             ,
 result_id                              ,
 reason_id                              ,
 source_code_id                         ,
 dialing_method                         ,
 partition_key                          ,
 call_calls_offered_total               ,
 call_calls_offered_above_th            ,
 call_calls_handled_total               ,
 call_calls_handled_above_th            ,
 call_calls_abandoned                   ,
 call_calls_abandoned_us                ,
 call_calls_transferred                 ,
 call_ivr_time                          ,
 call_route_time                        ,
 call_queue_time                        ,
 CALL_TOT_QUEUE_TO_ABANDON              ,
 call_tot_queue_to_answer               ,
 call_talk_time                         ,
 CALL_CONT_CALLS_OFFERED_NA             ,
 CALL_CONT_CALLS_HANDLED_TOT_NA         ,
 agent_talk_time_nac                    ,
 agent_wrap_time_nac                    ,
 agent_calls_tran_conf_to_nac           ,
 AGENT_CONT_CALLS_HAND_NA               ,
 AGENT_CONT_CALLS_TC_NA                 ,
 agent_calls_handled_total              ,
 agent_calls_handled_above_th           ,
 agent_calls_answered_by_goal           ,
 agent_sr_created                       ,
 agent_leads_created                    ,
 agent_leads_amount                     ,
 agent_leads_converted_to_opp           ,
 agent_opportunities_created            ,
 agent_opportunities_won                ,
 agent_opportunities_won_amount         ,
 agent_opportunities_cross_sold         ,
 agent_opportunities_up_sold            ,
 agent_opportunities_declined           ,
 agent_opportunities_lost               ,
 agent_preview_time                     ,
 agentcall_orr_count                    ,
 agentcall_pr_count                     ,
 agentcall_contact_count
)
VALUES
(
to_char(l_target_record.period_start_date(k),'J'),
1,
l_target_record.period_start_date(k),
l_target_record.period_start_time(k),
l_target_record.day_of_week(k),
l_target_record.direction(k),
l_target_record.media_item_type(k),
l_target_record.resource_id(k),
l_target_record.party_id(k),
l_target_record.classification_value(k),
l_target_record.dnis_name(k),
l_target_record.server_group_id(k),
l_target_record.campaign_id(k),
l_target_record.schedule_id(k),
l_target_record.outcome_id(k),
l_target_record.result_id(k),
l_target_record.reason_id(k),
l_target_record.source_code_id(k),
l_target_record.dialing_method(k),
l_target_record.partition_key(k),
l_target_record.call_calls_offered_total(k),
l_target_record.call_calls_offered_above_th(k),
l_target_record.call_calls_hand_tot(k),
l_target_record.call_calls_hand_above_th(k),
l_target_record.call_calls_abandoned(k),
l_target_record.call_calls_abandoned_us(k),
l_target_record.call_calls_transferred(k),
l_target_record.call_ivr_time(k),
l_target_record.call_route_time(k),
l_target_record.call_queue_time(k),
l_target_record.CALL_TOT_QUEUE_TO_ABANDON(k),
l_target_record.call_tot_queue_to_answer(k),
l_target_record.call_talk_time(k),
l_target_record.call_cont_calls_offered_na(k),
l_target_record.CALL_CONT_CALLS_HANDLED_TOT_NA(k),
l_target_record.agent_talk_time_nac(k),
l_target_record.agent_wrap_time_nac(k),
l_target_record.agent_calls_tran_conf_to_nac(k),
l_target_record.agent_cont_calls_hand_na(k),
l_target_record.agent_cont_calls_tc_na(k),
l_target_record.agent_calls_handled_total(k),
l_target_record.agent_calls_handled_above_th(k),
l_target_record.agent_calls_answered_by_goal(k),
l_target_record.agent_sr_created(k),
l_target_record.agent_leads_created(k),
l_target_record.agent_leads_amount(k),
l_target_record.agent_leads_converted_to_opp(k),
l_target_record.agent_opportunities_created(k),
l_target_record.agent_opportunities_won(k),
l_target_record.agent_opportunities_won_amount(k),
l_target_record.agent_opportunities_cross_sold(k),
l_target_record.agent_opportunities_up_sold(k),
l_target_record.agent_opportunities_declined(k),
l_target_record.agent_opportunities_lost(k),
l_target_record.agent_preview_time(k),
l_target_record.agentcall_orr_count(k),
l_target_record.agentcall_pr_count(k),
l_target_record.agentcall_contact_count(k)
)
;
/****
MERGE INTO BIX_CALL_DETAILS_STG STG
USING (
SELECT
--l_target_record.media_id(k) media_id,
to_char(l_target_record.period_start_date(k),'J') time_id,
-1 period_type_id,
l_target_record.period_start_date(k) period_start_date,
l_target_record.period_start_time(k) period_start_time,
l_target_record.day_of_week(k) day_of_week,
l_target_record.direction(k) direction,
l_target_record.media_item_type(k) media_item_type,
l_target_record.resource_id(k) resource_id,
l_target_record.party_id(k) party_id,
l_target_record.classification_value(k) classification_value,
l_target_record.dnis_name(k) dnis_name,
l_target_record.server_group_id(k) server_group_id,
l_target_record.campaign_id(k) campaign_id,
l_target_record.schedule_id(k) schedule_id,
l_target_record.outcome_id(k) outcome_id,
l_target_record.result_id(k) result_id,
l_target_record.reason_id(k) reason_id,
l_target_record.source_code_id(k) source_code_id,
l_target_record.dialing_method(k) dialing_method,
l_target_record.partition_key(k) partition_key,
l_target_record.call_calls_offered_total(k) call_calls_offered_total,
l_target_record.call_calls_offered_above_th(k) call_calls_offered_above_th,
l_target_record.call_calls_hand_tot(k) call_calls_handled_total,
l_target_record.call_calls_hand_above_th(k) call_calls_handled_above_th,
l_target_record.call_calls_abandoned(k) call_calls_abandoned,
l_target_record.call_calls_transferred(k) call_calls_transferred,
l_target_record.call_ivr_time(k) call_ivr_time,
l_target_record.call_route_time(k) call_route_time,
l_target_record.call_queue_time(k) call_queue_time,
l_target_record.CALL_TOT_QUEUE_TO_ABANDON(k) CALL_TOT_QUEUE_TO_ABANDON,
l_target_record.call_tot_queue_to_answer(k) call_tot_queue_to_answer,
l_target_record.call_talk_time(k) call_talk_time,
l_target_record.call_cont_calls_offered_na(k) call_cont_calls_offered_na,
l_target_record.CALL_CONT_CALLS_HANDLED_TOT_NA(k) CALL_CONT_CALLS_HANDLED_TOT_NA,
l_target_record.agent_talk_time_nac(k) agent_talk_time_nac,
l_target_record.agent_wrap_time_nac(k) agent_wrap_time_nac,
l_target_record.agent_calls_tran_conf_to_nac(k) agent_calls_tran_conf_to_nac,
l_target_record.agent_cont_calls_hand_na(k) AGENT_CONT_CALLS_HAND_NA,
l_target_record.agent_cont_calls_tc_na(k) AGENT_CONT_CALLS_TC_NA,
l_target_record.agent_calls_handled_total(k) agent_calls_handled_total,
l_target_record.agent_calls_handled_above_th(k) agent_calls_handled_above_th,
l_target_record.agent_calls_answered_by_goal(k) agent_calls_answered_by_goal,
l_target_record.agent_sr_created(k) agent_sr_created,
l_target_record.agent_leads_created(k) agent_leads_created,
l_target_record.agent_leads_amount(k) agent_leads_amount,
l_target_record.agent_leads_converted_to_opp(k) agent_leads_converted_to_opp,
l_target_record.agent_opportunities_created(k) agent_opportunities_created,
l_target_record.agent_opportunities_won(k) agent_opportunities_won,
l_target_record.agent_opportunities_won_amount(k) agent_opportunities_won_amount,
l_target_record.agent_opportunities_cross_sold(k) agent_opportunities_cross_sold,
l_target_record.agent_opportunities_up_sold(k) agent_opportunities_up_sold,
l_target_record.agent_opportunities_declined(k) agent_opportunities_declined,
l_target_record.agent_opportunities_lost(k) agent_opportunities_lost,
l_target_record.agent_preview_time(k) agent_preview_time,
l_target_record.agentcall_orr_count(k) agentcall_orr_count,
l_target_record.agentcall_pr_count(k) agentcall_pr_count,
l_target_record.agentcall_contact_count(k) agentcall_contact_count
FROM DUAL
) SUMM
ON
(
stg.time_id = summ.time_id
--AND stg.media_id = summ.media_id
AND stg.period_type_id = summ.period_type_id
AND stg.period_start_date = summ.period_start_date
AND stg.period_start_time = summ.period_start_time
AND stg.day_of_week = summ.day_of_week
AND stg.direction = summ.direction
AND stg.media_item_type = summ.media_item_type
AND stg.resource_id = summ.resource_id
AND stg.party_id = summ.party_id
AND stg.classification_value = summ.classification_value
AND stg.dnis_name = summ.dnis_name
AND stg.server_group_id = summ.server_group_id
AND stg.campaign_id = summ.campaign_id
AND stg.schedule_id = summ.schedule_id
AND stg.outcome_id = summ.outcome_id
AND stg.result_id = summ.result_id
AND stg.reason_id = summ.reason_id
AND stg.source_code_id = summ.source_code_id
AND stg.dialing_method = summ.dialing_method
AND stg.partition_key = summ.partition_key
)
WHEN MATCHED
THEN
   UPDATE
   SET
stg.call_calls_offered_total       = nvl(stg.call_calls_offered_total,0) +
                                     nvl(summ.call_calls_offered_total,0),
stg.call_calls_offered_above_th    = nvl(stg.call_calls_offered_above_th,0) +
                                     nvl(summ.call_calls_offered_above_th,0),
stg.call_calls_handled_total            = nvl(stg.call_calls_handled_total,0) +
                                     nvl(summ.call_calls_handled_total,0),
stg.call_calls_handled_above_th       = nvl(stg.call_calls_handled_above_th,0) +
                                     nvl(summ.call_calls_handled_above_th,0),
stg.call_calls_abandoned           = nvl(stg.call_calls_abandoned,0) +
                                     nvl(summ.call_calls_abandoned,0),
stg.call_calls_transferred         = nvl(stg.call_calls_transferred,0) +
                                     nvl(summ.call_calls_transferred,0),
stg.call_ivr_time                  = nvl(stg.call_ivr_time,0) +
                                     nvl(summ.call_ivr_time,0),
stg.call_route_time                = nvl(stg.call_route_time,0) +
                                     nvl(summ.call_route_time,0),
stg.call_queue_time          = nvl(stg.call_queue_time,0) +
                                     nvl(summ.call_queue_time,0),
stg.CALL_TOT_QUEUE_TO_ABANDON  = nvl(stg.CALL_TOT_QUEUE_TO_ABANDON,0) +
                                     nvl(summ.CALL_TOT_QUEUE_TO_ABANDON,0),
stg.call_tot_queue_to_answer  = nvl(stg.call_tot_queue_to_answer,0) +
                                     nvl(summ.call_tot_queue_to_answer,0),
stg.call_talk_time                 = nvl(stg.call_talk_time,0) +
                                     nvl(summ.call_talk_time,0),
stg.call_cont_calls_offered_na         = nvl(stg.call_cont_calls_offered_na,0) +
                                     nvl(summ.call_cont_calls_offered_na,0),
stg.call_cont_calls_handled_tot_na    = nvl(stg.call_cont_calls_handled_tot_na,0) +
                                     nvl(summ.call_cont_calls_handled_tot_na,0),
stg.agent_talk_time_nac            = nvl(stg.agent_talk_time_nac,0) +
                                     nvl(summ.agent_talk_time_nac,0),
stg.agent_wrap_time_nac            = nvl(stg.agent_wrap_time_nac,0) +
                                     nvl(summ.agent_wrap_time_nac,0),
stg.agent_calls_tran_conf_to_nac   = nvl(stg.agent_calls_tran_conf_to_nac,0) +
                                     nvl(summ.agent_calls_tran_conf_to_nac,0),
stg.AGENT_CONT_CALLS_HAND_NA       = nvl(stg.AGENT_CONT_CALLS_HAND_NA,0) +
                                     nvl(summ.AGENT_CONT_CALLS_HAND_NA,0),
stg.AGENT_CONT_CALLS_TC_NA         = nvl(stg.AGENT_CONT_CALLS_TC_NA,0) +
                                     nvl(summ.AGENT_CONT_CALLS_TC_NA,0),
stg.agent_calls_handled_total      = nvl(stg.agent_calls_handled_total,0) +
                                     nvl(summ.agent_calls_handled_total,0),
stg.agent_calls_handled_above_th   = nvl(stg.agent_calls_handled_above_th,0) +
                                     nvl(summ.agent_calls_handled_above_th,0),
stg.agent_calls_answered_by_goal   = nvl(stg.agent_calls_answered_by_goal,0) +
                                     nvl(summ.agent_calls_answered_by_goal,0),
stg.agent_sr_created               = nvl(stg.agent_sr_created,0) +
                                     nvl(summ.agent_sr_created,0),
stg.agent_leads_created            = nvl(stg.agent_leads_created,0) +
                                     nvl(summ.agent_leads_created,0),
stg.agent_leads_amount             = nvl(stg.agent_leads_amount,0) +
                                     nvl(summ.agent_leads_amount,0),
stg.agent_leads_converted_to_opp   = nvl(stg.agent_leads_converted_to_opp,0) +
                                     nvl(summ.agent_leads_converted_to_opp,0),
stg.agent_opportunities_created    = nvl(stg.agent_opportunities_created,0) +
                                     nvl(summ.agent_opportunities_created,0),
stg.agent_opportunities_won        = nvl(stg.agent_opportunities_won,0) +
                                     nvl(summ.agent_opportunities_won,0),
stg.agent_opportunities_won_amount = nvl(stg.agent_opportunities_won_amount,0)+
                                     nvl(summ.agent_opportunities_won_amount,0),
stg.agent_opportunities_cross_sold = nvl(stg.agent_opportunities_cross_sold,0) +
                                     nvl(summ.agent_opportunities_cross_sold,0),
stg.agent_opportunities_up_sold    = nvl(stg.agent_opportunities_up_sold,0) +
                                     nvl(summ.agent_opportunities_up_sold,0),
stg.agent_opportunities_declined   = nvl(stg.agent_opportunities_declined,0) +
                                     nvl(summ.agent_opportunities_declined,0),
stg.agent_opportunities_lost       = nvl(stg.agent_opportunities_lost,0) +
                                     nvl(summ.agent_opportunities_lost,0),
stg.agent_preview_time             = nvl(stg.agent_preview_time,0) +
                                     nvl(summ.agent_preview_time,0),
stg.agentcall_orr_count            = nvl(stg.agentcall_orr_count,0) +
                                     nvl(summ.agentcall_orr_count,0),
stg.agentcall_pr_count             = nvl(stg.agentcall_pr_count,0) +
                                     nvl(summ.agentcall_pr_count,0),
stg.agentcall_contact_count        = nvl(stg.agentcall_contact_count,0) +
                                     nvl(summ.agentcall_contact_count,0),
stg.last_update_date = g_sysdate,
stg.last_updated_by = g_user_id
WHEN NOT MATCHED
THEN
INSERT
(
 --media_id                               ,
 time_id                                ,
 period_type_id                         ,
 period_start_date                      ,
 period_start_time                      ,
 day_of_week                            ,
 direction                              ,
 media_item_type                        ,
 resource_id                            ,
 party_id                               ,
 classification_value                   ,
 dnis_name                              ,
 server_group_id                        ,
 campaign_id                            ,
 schedule_id                            ,
 outcome_id                             ,
 result_id                              ,
 reason_id                              ,
 source_code_id                         ,
 dialing_method                         ,
 partition_key                          ,
 call_calls_offered_total               ,
 call_calls_offered_above_th            ,
 call_calls_handled_total               ,
 call_calls_handled_above_th            ,
 call_calls_abandoned                   ,
 call_calls_transferred                 ,
 call_ivr_time                          ,
 call_route_time                        ,
 call_queue_time                  ,
 CALL_TOT_QUEUE_TO_ABANDON          ,
 call_tot_queue_to_answer          ,
 call_talk_time                         ,
 CALL_CONT_CALLS_OFFERED_NA             ,
 call_cont_calls_handled_tot_na         ,
 agent_talk_time_nac                    ,
 agent_wrap_time_nac                    ,
 agent_calls_tran_conf_to_nac           ,
 AGENT_CONT_CALLS_HAND_NA               ,
 AGENT_CONT_CALLS_TC_NA               ,
 agent_calls_handled_total              ,
 agent_calls_handled_above_th           ,
 agent_calls_answered_by_goal           ,
 agent_sr_created                       ,
 agent_leads_created                    ,
 agent_leads_amount                     ,
 agent_leads_converted_to_opp           ,
 agent_opportunities_created            ,
 agent_opportunities_won                ,
 agent_opportunities_won_amount         ,
 agent_opportunities_cross_sold         ,
 agent_opportunities_up_sold            ,
 agent_opportunities_declined           ,
 agent_opportunities_lost               ,
 agent_preview_time                     ,
 agentcall_orr_count                    ,
 agentcall_pr_count                     ,
 agentcall_contact_count                     ,
 created_by                             ,
 creation_date                          ,
 last_updated_by                        ,
 last_update_date                       ,
 last_update_login                      ,
 request_id                             ,
 program_application_id                 ,
 program_id                             ,
 program_update_date
)
values
(
 --summ.media_id                          ,
 summ.time_id                           ,
 summ.period_type_id                    ,
 summ.period_start_date                 ,
 summ.period_start_time                 ,
 summ.day_of_week                       ,
 summ.direction                         ,
 summ.media_item_type                   ,
 summ.resource_id                       ,
 summ.party_id                          ,
 summ.classification_value              ,
 summ.dnis_name                         ,
 summ.server_group_id                   ,
 summ.campaign_id                       ,
 summ.schedule_id                       ,
 summ.outcome_id                        ,
 summ.result_id                         ,
 summ.reason_id                         ,
 summ.source_code_id                    ,
 summ.dialing_method                    ,
 nvl(summ.partition_key,'NA')           ,
 summ.call_calls_offered_total          ,
 summ.call_calls_offered_above_th       ,
 summ.CALL_CALLS_HANDLED_TOTAL          ,
 summ.CALL_CALLS_HANDLED_ABOVE_TH       ,
 summ.call_calls_abandoned              ,
 summ.call_calls_transferred            ,
 summ.call_ivr_time                     ,
 summ.call_route_time                   ,
 summ.call_queue_time             ,
 summ.CALL_TOT_QUEUE_TO_ABANDON     ,
 summ.call_tot_queue_to_answer     ,
 summ.call_talk_time                    ,
 summ.CALL_CONT_CALLS_OFFERED_NA        ,
 summ.CALL_CONT_CALLS_HANDLED_TOT_NA    ,
 summ.agent_talk_time_nac               ,
 summ.agent_wrap_time_nac               ,
 summ.agent_calls_tran_conf_to_nac      ,
 summ.AGENT_CONT_CALLS_HAND_NA          ,
 summ.AGENT_CONT_CALLS_TC_NA          ,
 summ.agent_calls_handled_total         ,
 summ.agent_calls_handled_above_th      ,
 summ.agent_calls_answered_by_goal      ,
 summ.agent_sr_created                  ,
 summ.agent_leads_created               ,
 summ.agent_leads_amount                ,
 summ.agent_leads_converted_to_opp      ,
 summ.agent_opportunities_created       ,
 summ.agent_opportunities_won           ,
 summ.agent_opportunities_won_amount    ,
 summ.agent_opportunities_cross_sold    ,
 summ.agent_opportunities_up_sold       ,
 summ.agent_opportunities_declined      ,
 summ.agent_opportunities_lost          ,
 summ.agent_preview_time                ,
 summ.agentcall_orr_count               ,
 summ.agentcall_pr_count                ,
 summ.agentcall_contact_count                ,
 g_user_id                              ,
 g_sysdate                              ,
 g_user_id                              ,
 g_sysdate                              ,
 g_user_id                              ,
 g_request_id                           ,
 g_program_appl_id                      ,
 g_program_id                           ,
 g_sysdate
);
****/

--insert into bixtest
--values ('Completed merge of '|| counter || 'at ' ||
         --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
       --);

COMMIT;

    write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   'Completed merge of staging table ');

  --IF (g_debug_flag = 'Y') THEN
--write_log('Completed bulk merge into staging table at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')  ||
		 --'for ' || counter || ' number of rows '
		 --);
  --END IF;

END IF; -- for if which checks if l_source_record.media_id.COUNT > 0

--Trim all table collections

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'Before initializing record of tables ');

l_source_record := l_source_null_record;
l_target_record := l_target_null_record;

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'After initializing record of tables ');
--

-----

EXIT WHEN get_call_info%NOTFOUND;

END LOOP;  -- end loop for fetching all the cursor records.

    write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
	   'Ended loop of all medias in cursor ');

CLOSE get_call_info;

--DBMS_PROFILER.STOP_PROFILER;

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Finished procedure insert_half_hour_rows at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;
EXCEPTION
  WHEN OTHERS THEN
  --IF (g_debug_flag = 'Y') THEN
    write_log('Error in insert_half_hour_rows : Error : ' || sqlerrm);
--l_test := SQLERRM;
--insert into bixtest values ('Error: ' || l_test);
--commit;
  --END IF;
    IF (get_call_info%ISOPEN) THEN
      CLOSE get_call_info;
    END IF;
    RAISE;

--DBMS_PROFILER.STOP_PROFILER;

--insert into bixtest
--values ('Ended insert_half_hour at ' ||
         --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')
       --);

commit;

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'End insert_half_hour_rows ');

END insert_half_hour_rows;

PROCEDURE move_stg_to_fact IS

BEGIN

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Start of the procedure move_stg_to_fact at : ' ||
		   --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'Start move_stg_to_fact ');

--
--Move the data from the staging area to the summary table BIX_CALL_DETAILS_F
--

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'Before analyze ');

--ANalyze fact before merge
--DBMS_STATS.gather_table_stats(ownname => g_bix_schema,
                              --tabName => 'BIX_CALL_DETAILS_F',
                              --cascade => TRUE,
                              --degree => bis_common_parameters.get_degree_of_parallelism,
                              --estimate_percent => 10,
                              --granularity => 'GLOBAL');

--execute immediate 'analyze index bix.bix_sum_n1 compute statistics';
--execute immediate 'analyze index bixbitmap compute statistics';

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'After analyze complete ');

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'Starting merge to fact from staging ');
--
--This can be a INSERT APPEND only in initial load, not in incremental.
--
/*
INSERT
INTO BIX_CALL_DETAILS_F SUMM
(
TIME_ID,
PERIOD_TYPE_ID,
PERIOD_START_DATE,
PERIOD_START_TIME,
DAY_OF_WEEK,
DIRECTION,
MEDIA_ITEM_TYPE,
CLASSIFICATION_VALUE,
DNIS_NAME,
SERVER_GROUP_ID,
RESOURCE_ID,
CAMPAIGN_ID,
SCHEDULE_ID,
SOURCE_CODE_ID,
DIALING_METHOD,
OUTCOME_ID,
RESULT_ID,
REASON_ID,
PARTY_ID,
PARTITION_KEY,
CALL_CALLS_OFFERED_TOTAL,
CALL_CALLS_OFFERED_ABOVE_TH,
CALL_CALLS_HANDLED_TOTAL,
CALL_CALLS_HANDLED_ABOVE_TH,
CALL_CALLS_ABANDONED,
CALL_CALLS_TRANSFERRED,
CALL_IVR_TIME,
CALL_ROUTE_TIME,
CALL_QUEUE_TIME,
CALL_TOT_QUEUE_TO_ABANDON,
CALL_TOT_QUEUE_TO_ANSWER,
CALL_TALK_TIME,
CALL_CONT_CALLS_OFFERED_NA,
CALL_CONT_CALLS_HANDLED_TOT_NA,
AGENT_TALK_TIME_NAC,
AGENT_WRAP_TIME_NAC,
AGENT_CALLS_TRAN_CONF_TO_NAC,
AGENT_CALLS_HANDLED_TOTAL,
AGENT_CALLS_HANDLED_ABOVE_TH,
AGENT_CALLS_ANSWERED_BY_GOAL,
AGENT_SR_CREATED,
AGENT_LEADS_CREATED,
AGENT_LEADS_AMOUNT,
AGENT_LEADS_CONVERTED_TO_OPP,
AGENT_OPPORTUNITIES_CREATED,
AGENT_OPPORTUNITIES_WON,
AGENT_OPPORTUNITIES_WON_AMOUNT,
AGENT_OPPORTUNITIES_CROSS_SOLD,
AGENT_OPPORTUNITIES_UP_SOLD,
AGENT_OPPORTUNITIES_DECLINED,
AGENT_OPPORTUNITIES_LOST,
AGENT_PREVIEW_TIME,
AGENTCALL_ORR_COUNT,
AGENTCALL_PR_COUNT,
AGENTCALL_CONTACT_COUNT,
AGENT_CONT_CALLS_HAND_NA,
AGENT_CONT_CALLS_TC_NA
)
SELECT
TIME_ID,
PERIOD_TYPE_ID,
PERIOD_START_DATE,
PERIOD_START_TIME,
DAY_OF_WEEK,
DIRECTION,
MEDIA_ITEM_TYPE,
CLASSIFICATION_VALUE,
DNIS_NAME,
SERVER_GROUP_ID,
RESOURCE_ID,
CAMPAIGN_ID,
SCHEDULE_ID,
SOURCE_CODE_ID,
DIALING_METHOD,
OUTCOME_ID,
RESULT_ID,
REASON_ID,
PARTY_ID,
PARTITION_KEY,
SUM(CALL_CALLS_OFFERED_TOTAL) CALL_CALLS_OFFERED_TOTAL,
SUM(CALL_CALLS_OFFERED_ABOVE_TH) CALL_CALLS_OFFERED_ABOVE_TH,
SUM(CALL_CALLS_HANDLED_TOTAL) CALL_CALLS_HANDLED_TOTAL,
SUM(CALL_CALLS_HANDLED_ABOVE_TH) CALL_CALLS_HANDLED_ABOVE_TH,
SUM(CALL_CALLS_ABANDONED) CALL_CALLS_ABANDONED,
SUM(CALL_CALLS_TRANSFERRED) CALL_CALLS_TRANSFERRED,
SUM(CALL_IVR_TIME) CALL_IVR_TIME,
SUM(CALL_ROUTE_TIME) CALL_ROUTE_TIME,
SUM(CALL_QUEUE_TIME) CALL_QUEUE_TIME,
SUM(CALL_TOT_QUEUE_TO_ABANDON) CALL_TOT_QUEUE_TO_ABANDON,
SUM(CALL_TOT_QUEUE_TO_ANSWER) CALL_TOT_QUEUE_TO_ANSWER,
SUM(CALL_TALK_TIME) CALL_TALK_TIME,
SUM(CALL_CONT_CALLS_OFFERED_NA) CALL_CONT_CALLS_OFFERED_NA,
SUM(CALL_CONT_CALLS_HANDLED_TOT_NA) CALL_CONT_CALLS_HANDLED_TOT_NA,
SUM(AGENT_TALK_TIME_NAC) AGENT_TALK_TIME_NAC,
SUM(AGENT_WRAP_TIME_NAC) AGENT_WRAP_TIME_NAC,
SUM(AGENT_CALLS_TRAN_CONF_TO_NAC) AGENT_CALLS_TRAN_CONF_TO_NAC,
SUM(AGENT_CALLS_HANDLED_TOTAL) AGENT_CALLS_HANDLED_TOTAL,
SUM(AGENT_CALLS_HANDLED_ABOVE_TH) AGENT_CALLS_HANDLED_ABOVE_TH,
SUM(AGENT_CALLS_ANSWERED_BY_GOAL) AGENT_CALLS_ANSWERED_BY_GOAL,
SUM(AGENT_SR_CREATED) AGENT_SR_CREATED,
SUM(AGENT_LEADS_CREATED) AGENT_LEADS_CREATED,
SUM(AGENT_LEADS_AMOUNT) AGENT_LEADS_AMOUNT,
SUM(AGENT_LEADS_CONVERTED_TO_OPP) AGENT_LEADS_CONVERTED_TO_OPP,
SUM(AGENT_OPPORTUNITIES_CREATED) AGENT_OPPORTUNITIES_CREATED,
SUM(AGENT_OPPORTUNITIES_WON) AGENT_OPPORTUNITIES_WON,
SUM(AGENT_OPPORTUNITIES_WON_AMOUNT) AGENT_OPPORTUNITIES_WON_AMOUNT,
SUM(AGENT_OPPORTUNITIES_CROSS_SOLD) AGENT_OPPORTUNITIES_CROSS_SOLD,
SUM(AGENT_OPPORTUNITIES_UP_SOLD) AGENT_OPPORTUNITIES_UP_SOLD,
SUM(AGENT_OPPORTUNITIES_DECLINED) AGENT_OPPORTUNITIES_DECLINED,
SUM(AGENT_OPPORTUNITIES_LOST) AGENT_OPPORTUNITIES_LOST,
SUM(AGENT_PREVIEW_TIME) AGENT_PREVIEW_TIME,
SUM(AGENTCALL_ORR_COUNT) AGENTCALL_ORR_COUNT,
SUM(AGENTCALL_PR_COUNT) AGENTCALL_PR_COUNT,
SUM(AGENTCALL_CONTACT_COUNT) AGENTCALL_CONTACT_COUNT,
NVL(SUM(AGENT_CONT_CALLS_HAND_NA),-1) AGENT_CONT_CALLS_HAND_NA
FROM  bix_call_details_stg stg
GROUP BY
TIME_ID,
PERIOD_TYPE_ID,
PERIOD_START_DATE,
PERIOD_START_TIME,
DAY_OF_WEEK,
DIRECTION,
MEDIA_ITEM_TYPE,
CLASSIFICATION_VALUE,
DNIS_NAME,
SERVER_GROUP_ID,
RESOURCE_ID,
CAMPAIGN_ID,
SCHEDULE_ID,
SOURCE_CODE_ID,
DIALING_METHOD,
OUTCOME_ID,
RESULT_ID,
REASON_ID,
PARTY_ID,
PARTITION_KEY
;
*/
MERGE INTO BIX_CALL_DETAILS_F SUMM
USING
(
SELECT
TIME_ID,
PERIOD_TYPE_ID,
PERIOD_START_DATE,
PERIOD_START_TIME,
DAY_OF_WEEK,
DIRECTION,
MEDIA_ITEM_TYPE,
CLASSIFICATION_VALUE,
DNIS_NAME,
SERVER_GROUP_ID,
RESOURCE_ID,
CAMPAIGN_ID,
SCHEDULE_ID,
SOURCE_CODE_ID,
DIALING_METHOD,
OUTCOME_ID,
RESULT_ID,
REASON_ID,
PARTY_ID,
PARTITION_KEY,
SUM(CALL_CALLS_OFFERED_TOTAL) CALL_CALLS_OFFERED_TOTAL,
SUM(CALL_CALLS_OFFERED_ABOVE_TH) CALL_CALLS_OFFERED_ABOVE_TH,
SUM(CALL_CALLS_HANDLED_TOTAL) CALL_CALLS_HANDLED_TOTAL,
SUM(CALL_CALLS_HANDLED_ABOVE_TH) CALL_CALLS_HANDLED_ABOVE_TH,
SUM(CALL_CALLS_ABANDONED) CALL_CALLS_ABANDONED,
SUM(CALL_CALLS_ABANDONED_US) CALL_CALLS_ABANDONED_US,
SUM(CALL_CALLS_TRANSFERRED) CALL_CALLS_TRANSFERRED,
SUM(CALL_IVR_TIME) CALL_IVR_TIME,
SUM(CALL_ROUTE_TIME) CALL_ROUTE_TIME,
SUM(CALL_QUEUE_TIME) CALL_QUEUE_TIME,
SUM(CALL_TOT_QUEUE_TO_ABANDON) CALL_TOT_QUEUE_TO_ABANDON,
SUM(CALL_TOT_QUEUE_TO_ANSWER) CALL_TOT_QUEUE_TO_ANSWER,
SUM(CALL_TALK_TIME) CALL_TALK_TIME,
--decode(PERIOD_TYPE_ID,-1,SUM(CALL_CONT_CALLS_OFFERED_NA),0) CALL_CONT_CALLS_OFFERED_NA,
--decode(period_type_id,-1,SUM(CALL_CONT_CALLS_HANDLED_TOT_NA),0) CALL_CONT_CALLS_HANDLED_TOT_NA,
decode(PERIOD_TYPE_ID,1,SUM(CALL_CONT_CALLS_OFFERED_NA),0) CALL_CONT_CALLS_OFFERED_NA,
decode(period_type_id,1,SUM(CALL_CONT_CALLS_HANDLED_TOT_NA),0) CALL_CONT_CALLS_HANDLED_TOT_NA,
SUM(AGENT_TALK_TIME_NAC) AGENT_TALK_TIME_NAC,
SUM(AGENT_WRAP_TIME_NAC) AGENT_WRAP_TIME_NAC,
SUM(AGENT_CALLS_TRAN_CONF_TO_NAC) AGENT_CALLS_TRAN_CONF_TO_NAC,
SUM(AGENT_CALLS_HANDLED_TOTAL) AGENT_CALLS_HANDLED_TOTAL,
SUM(AGENT_CALLS_HANDLED_ABOVE_TH) AGENT_CALLS_HANDLED_ABOVE_TH,
SUM(AGENT_CALLS_ANSWERED_BY_GOAL) AGENT_CALLS_ANSWERED_BY_GOAL,
SUM(AGENT_SR_CREATED) AGENT_SR_CREATED,
SUM(AGENT_LEADS_CREATED) AGENT_LEADS_CREATED,
SUM(AGENT_LEADS_AMOUNT) AGENT_LEADS_AMOUNT,
SUM(AGENT_LEADS_CONVERTED_TO_OPP) AGENT_LEADS_CONVERTED_TO_OPP,
SUM(AGENT_OPPORTUNITIES_CREATED) AGENT_OPPORTUNITIES_CREATED,
SUM(AGENT_OPPORTUNITIES_WON) AGENT_OPPORTUNITIES_WON,
SUM(AGENT_OPPORTUNITIES_WON_AMOUNT) AGENT_OPPORTUNITIES_WON_AMOUNT,
SUM(AGENT_OPPORTUNITIES_CROSS_SOLD) AGENT_OPPORTUNITIES_CROSS_SOLD,
SUM(AGENT_OPPORTUNITIES_UP_SOLD) AGENT_OPPORTUNITIES_UP_SOLD,
SUM(AGENT_OPPORTUNITIES_DECLINED) AGENT_OPPORTUNITIES_DECLINED,
SUM(AGENT_OPPORTUNITIES_LOST) AGENT_OPPORTUNITIES_LOST,
SUM(AGENT_PREVIEW_TIME) AGENT_PREVIEW_TIME,
SUM(AGENTCALL_ORR_COUNT) AGENTCALL_ORR_COUNT,
SUM(AGENTCALL_PR_COUNT) AGENTCALL_PR_COUNT,
SUM(AGENTCALL_CONTACT_COUNT) AGENTCALL_CONTACT_COUNT,
--decode(period_type_id,-1,SUM(AGENT_CONT_CALLS_HAND_NA),-1) AGENT_CONT_CALLS_HAND_NA,
--decode(period_type_id,-1,SUM(AGENT_CONT_CALLS_TC_NA),0) AGENT_CONT_CALLS_TC_NA
decode(period_type_id,1,SUM(AGENT_CONT_CALLS_HAND_NA),-1) AGENT_CONT_CALLS_HAND_NA,
decode(period_type_id,1,SUM(AGENT_CONT_CALLS_TC_NA),0) AGENT_CONT_CALLS_TC_NA
FROM  bix_call_details_stg stg
GROUP BY
TIME_ID,
PERIOD_TYPE_ID,
PERIOD_START_DATE,
PERIOD_START_TIME,
DAY_OF_WEEK,
DIRECTION,
MEDIA_ITEM_TYPE,
CLASSIFICATION_VALUE,
DNIS_NAME,
SERVER_GROUP_ID,
RESOURCE_ID,
CAMPAIGN_ID,
SCHEDULE_ID,
SOURCE_CODE_ID,
DIALING_METHOD,
OUTCOME_ID,
RESULT_ID,
REASON_ID,
PARTY_ID,
PARTITION_KEY
) STG
ON
(
summ.PERIOD_TYPE_ID = stg.PERIOD_TYPE_ID
AND summ.PERIOD_START_DATE = stg.PERIOD_START_DATE
AND summ.PERIOD_START_TIME = stg.PERIOD_START_TIME
AND summ.DAY_OF_WEEK         =stg.DAY_OF_WEEK
AND summ.PARTITION_KEY = stg.PARTITION_KEY
AND summ.DIRECTION = stg.DIRECTION
AND summ.MEDIA_ITEM_TYPE=stg.MEDIA_ITEM_TYPE
AND summ.RESOURCE_ID = stg.RESOURCE_ID
AND summ.PARTY_ID = stg.PARTY_ID
AND summ.CLASSIFICATION_VALUE = stg.CLASSIFICATION_VALUE
AND summ.DNIS_NAME = stg.DNIS_NAME
AND summ.SERVER_GROUP_ID = stg.SERVER_GROUP_ID
AND summ.CAMPAIGN_ID = stg.CAMPAIGN_ID
AND summ.SCHEDULE_ID = stg.SCHEDULE_ID
AND summ.OUTCOME_ID = stg.OUTCOME_ID
AND summ.RESULT_ID = stg.RESULT_ID
AND summ.REASON_ID = stg.REASON_ID
AND summ.SOURCE_CODE_ID = stg.SOURCE_CODE_ID
AND summ.DIALING_METHOD = stg.DIALING_METHOD
AND summ.TIME_ID = stg.TIME_ID
)
WHEN MATCHED
THEN
   UPDATE
   SET
summ.call_calls_offered_total = nvl(summ.call_calls_offered_total,0) + nvl(stg.call_calls_offered_total,0),
summ.call_calls_offered_above_th = nvl(summ.call_calls_offered_above_th,0) +nvl(stg.call_calls_offered_above_th,0),
summ.call_calls_handled_total    = nvl(summ.call_calls_handled_total,0) +
                                     nvl(stg.call_calls_handled_total,0),
summ.call_calls_handled_above_th       = nvl(summ.call_calls_handled_above_th,0) +
                                     nvl(stg.call_calls_handled_above_th,0),
summ.call_calls_abandoned = nvl(summ.call_calls_abandoned,0) + nvl(stg.call_calls_abandoned,0),
summ.call_calls_abandoned_us = nvl(summ.call_calls_abandoned_us,0) + nvl(stg.call_calls_abandoned_us,0),
summ.call_calls_transferred = nvl(summ.call_calls_transferred,0) + nvl(stg.call_calls_transferred,0),
summ.call_ivr_time = nvl(summ.call_ivr_time,0) + nvl(stg.call_ivr_time,0),
summ.call_route_time = nvl(summ.call_route_time,0) + nvl(stg.call_route_time,0),
summ.call_queue_time = nvl(summ.call_queue_time,0) + nvl(stg.call_queue_time,0),
summ.CALL_TOT_QUEUE_TO_ABANDON = nvl(summ.CALL_TOT_QUEUE_TO_ABANDON,0) + nvl(stg.CALL_TOT_QUEUE_TO_ABANDON,0),
summ.call_tot_queue_to_answer = nvl(summ.call_tot_queue_to_answer,0) + nvl(stg.call_tot_queue_to_answer,0),
summ.call_talk_time = nvl(summ.call_talk_time,0) + nvl(stg.call_talk_time,0),
summ.call_cont_calls_offered_na         = nvl(summ.call_cont_calls_offered_na,0) +
                                     nvl(stg.call_cont_calls_offered_na,0),
summ.CALL_CONT_CALLS_HANDLED_TOT_NA    = nvl(summ.CALL_CONT_CALLS_HANDLED_TOT_NA,0) +
                                     nvl(stg.CALL_CONT_CALLS_HANDLED_TOT_NA,0),
summ.agent_talk_time_nac = nvl(summ.agent_talk_time_nac,0) + nvl(stg.agent_talk_time_nac,0),
summ.agent_wrap_time_nac = nvl(summ.agent_wrap_time_nac,0) + nvl(stg.agent_wrap_time_nac,0),
summ.agent_calls_tran_conf_to_nac = nvl(summ.agent_calls_tran_conf_to_nac,0) + nvl(stg.agent_calls_tran_conf_to_nac,0),
summ.AGENT_CONT_CALLS_HAND_NA = nvl(summ.AGENT_CONT_CALLS_HAND_NA,0) + nvl(stg.AGENT_CONT_CALLS_HAND_NA,0),
summ.AGENT_CONT_CALLS_TC_NA = nvl(summ.AGENT_CONT_CALLS_TC_NA,0) + nvl(stg.AGENT_CONT_CALLS_TC_NA,0),
summ.agent_calls_handled_total = nvl(summ.agent_calls_handled_total,0) + nvl(stg.agent_calls_handled_total,0),
summ.agent_calls_handled_above_th = nvl(summ.agent_calls_handled_above_th,0) + nvl(stg.agent_calls_handled_above_th,0),
summ.agent_calls_answered_by_goal = nvl(summ.agent_calls_answered_by_goal,0) + nvl(stg.agent_calls_answered_by_goal,0),
summ.agent_sr_created = nvl(summ.agent_sr_created,0) + nvl(stg.agent_sr_created,0),
summ.agent_leads_created = nvl(summ.agent_leads_created,0) + nvl(stg.agent_leads_created,0),
summ.agent_leads_amount = nvl(summ.agent_leads_amount,0) + nvl(stg.agent_leads_amount,0),
summ.agent_leads_converted_to_opp = nvl(summ.agent_leads_converted_to_opp,0) + nvl(stg.agent_leads_converted_to_opp,0),
summ.agent_opportunities_created = nvl(summ.agent_opportunities_created,0) + nvl(stg.agent_opportunities_created,0),
summ.agent_opportunities_won = nvl(summ.agent_opportunities_won,0) + nvl(stg.agent_OPPORTUNITIES_won,0),
summ.agent_opportunities_won_amount = nvl(summ.agent_opportunities_won_amount,0)+nvl(stg.agent_opportunities_won_amount,0),
summ.agent_opportunities_cross_sold = nvl(summ.agent_opportunities_cross_sold,0) + nvl(stg.agent_opportunities_cross_sold,0),
summ.agent_opportunities_up_sold = nvl(summ.agent_opportunities_up_sold,0) + nvl(stg.agent_opportunities_up_sold,0),
summ.agent_opportunities_declined = nvl(summ.agent_opportunities_declined,0) + nvl(stg.agent_opportunities_declined,0),
summ.agent_opportunities_lost = nvl(summ.agent_opportunities_lost,0) + nvl(stg.agent_opportunities_lost,0),
summ.agent_preview_time = nvl(summ.agent_preview_time,0) + nvl(stg.agent_preview_time,0),
summ.agentcall_orr_count = nvl(summ.agentcall_orr_count,0) + nvl(stg.agentcall_orr_count,0),
summ.agentcall_pr_count = nvl(summ.agentcall_pr_count,0) + nvl(stg.agentcall_pr_count,0),
summ.agentcall_contact_count = nvl(summ.agentcall_contact_count,0) + nvl(stg.agentcall_contact_count,0),
summ.last_update_date = g_sysdate,
summ.last_updated_by = g_user_id,
summ.request_id = g_request_id
WHEN NOT MATCHED
THEN
INSERT
(
 summ.time_id                                ,
 summ.period_type_id                         ,
 summ.period_start_date                      ,
 summ.period_start_time                      ,
 summ.day_of_week                            ,
 summ.direction                              ,
 summ.media_item_type                        ,
 summ.resource_id                            ,
 summ.party_id                               ,
 summ.classification_value                   ,
 summ.dnis_name                              ,
 summ.server_group_id                        ,
 summ.campaign_id                            ,
 summ.schedule_id                            ,
 summ.outcome_id                             ,
 summ.result_id                              ,
 summ.reason_id                              ,
 summ.source_code_id                         ,
 summ.DIALING_METHOD                         ,
 summ.partition_key                          ,
 summ.call_calls_offered_total               ,
 summ.call_calls_offered_above_th            ,
 summ.call_calls_handled_total               ,
 summ.call_calls_handled_above_th            ,
 summ.call_calls_abandoned                   ,
 summ.call_calls_abandoned_us                ,
 summ.call_calls_transferred                 ,
 summ.call_ivr_time                          ,
 summ.call_route_time                        ,
 summ.call_queue_time                        ,
 summ.CALL_TOT_QUEUE_TO_ABANDON              ,
 summ.call_tot_queue_to_answer              ,
 summ.call_talk_time                         ,
 summ.CALL_CONT_CALLS_OFFERED_NA             ,
 summ.CALL_CONT_CALLS_HANDLED_TOT_NA         ,
 summ.agent_talk_time_nac                    ,
 summ.agent_wrap_time_nac                    ,
 summ.agent_calls_tran_conf_to_nac           ,
 summ.AGENT_CONT_CALLS_HAND_NA               ,
 summ.AGENT_CONT_CALLS_TC_NA                 ,
 summ.agent_calls_handled_total              ,
 summ.agent_calls_handled_above_th           ,
 summ.agent_calls_answered_by_goal           ,
 summ.agent_sr_created                       ,
 summ.agent_leads_created                    ,
 summ.agent_leads_amount                     ,
 summ.agent_leads_converted_to_opp           ,
 summ.agent_opportunities_created            ,
 summ.agent_opportunities_won                ,
 summ.agent_opportunities_won_amount         ,
 summ.agent_opportunities_cross_sold         ,
 summ.agent_opportunities_up_sold            ,
 summ.agent_opportunities_declined           ,
 summ.agent_opportunities_lost               ,
 summ.agent_preview_time                     ,
 summ.agentcall_orr_count                    ,
 summ.agentcall_pr_count                     ,
 summ.agentcall_contact_count                     ,
 summ.created_by                             ,
 summ.creation_date                          ,
 summ.last_updated_by                        ,
 summ.last_update_date                       ,
 summ.last_update_login                      ,
 summ.request_id                             ,
 summ.program_application_id                 ,
 summ.program_id                             ,
 summ.program_update_date
)
values
(
 stg.time_id                                ,
 stg.period_type_id                         ,
 stg.period_start_date                      ,
 stg.period_start_time                      ,
 stg.day_of_week                            ,
 stg.direction                              ,
 stg.media_item_type                        ,
 stg.resource_id                            ,
 stg.party_id                               ,
 stg.classification_value                   ,
 stg.dnis_name                              ,
 stg.server_group_id                        ,
 stg.campaign_id                            ,
 stg.schedule_id                            ,
 stg.outcome_id                             ,
 stg.result_id                              ,
 stg.reason_id                              ,
 stg.source_code_id                         ,
 stg.dialing_method                         ,
 stg.partition_key                          ,
 stg.call_calls_offered_total               ,
 stg.call_calls_offered_above_th            ,
 stg.CALL_CALLS_HANDLED_TOTAL               ,
 stg.CALL_CALLS_HANDLED_ABOVE_TH            ,
 stg.call_calls_abandoned                   ,
 stg.call_calls_abandoned_us                   ,
 stg.call_calls_transferred                 ,
 stg.call_ivr_time                          ,
 stg.call_route_time                        ,
 stg.call_queue_time                  ,
 stg.CALL_TOT_QUEUE_TO_ABANDON          ,
 stg.call_tot_queue_to_answer          ,
 stg.call_talk_time                         ,
 stg.CALL_CONT_CALLS_OFFERED_NA             ,
 stg.CALL_CONT_CALLS_HANDLED_TOT_NA         ,
 stg.agent_talk_time_nac                    ,
 stg.agent_wrap_time_nac                    ,
 stg.agent_calls_tran_conf_to_nac           ,
 stg.AGENT_CONT_CALLS_HAND_NA               ,
 stg.AGENT_CONT_CALLS_TC_NA                 ,
 stg.agent_calls_handled_total              ,
 stg.agent_calls_handled_above_th           ,
 stg.agent_calls_answered_by_goal           ,
 stg.agent_sr_created                       ,
 stg.agent_leads_created                    ,
 stg.agent_leads_amount                     ,
 stg.agent_leads_converted_to_opp           ,
 stg.agent_opportunities_created            ,
 stg.agent_opportunities_won                ,
 stg.agent_opportunities_won_amount         ,
 stg.agent_opportunities_cross_sold         ,
 stg.agent_opportunities_up_sold            ,
 stg.agent_opportunities_declined           ,
 stg.agent_opportunities_lost               ,
 stg.agent_preview_time                     ,
 stg.agentcall_orr_count                    ,
 stg.agentcall_pr_count                     ,
 stg.agentcall_contact_count                     ,
 g_user_id                                   ,
 g_sysdate                                   ,
 g_user_id                                   ,
 g_sysdate                                   ,
 g_user_id                                   ,
 g_request_id                                ,
 g_program_appl_id                           ,
 g_program_id                                ,
 g_sysdate
);

g_rows_ins_upd := g_rows_ins_upd + SQL%ROWCOUNT;
  --IF (g_debug_flag = 'Y') THEN
--write_log('Total rows merged in BIX_CALL_DETAILS_F : ' ||
		   --g_rows_ins_upd);
  --END IF;

COMMIT;

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'Completed merge to fact from staging ');

LOOP

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'Before UPDATE of FACT table ');

UPDATE BIX_CALL_DETAILS_F FACT1
SET
(
AGENT_CONT_CALLS_HAND_NA,
AGENT_CONT_CALLS_TC_NA,
CALL_CONT_CALLS_OFFERED_NA,
CALL_CONT_CALLS_HANDLED_TOT_NA,
LAST_UPDATE_DATE,
LAST_UPDATED_BY
) =
(
SELECT
NVL(MAX(AGENT_CONT_CALLS_HAND_NA),0),
NVL(MAX(AGENT_CONT_CALLS_TC_NA),0),
NVL(MAX(CALL_CONT_CALLS_OFFERED_NA),0),
NVL(MAX(CALL_CONT_CALLS_HANDLED_TOT_NA),0),
g_sysdate,
g_user_id
FROM BIX_CALL_DETAILS_F FACT2
WHERE FACT1.TIME_ID = FACT2.TIME_ID
AND FACT2.PERIOD_TYPE_ID = 1
AND FACT2.PERIOD_START_TIME = '00:00'
AND FACT1.DAY_OF_WEEK = FACT2.DAY_OF_WEEK
AND FACT1.DIRECTION = FACT2.DIRECTION
AND FACT1.MEDIA_ITEM_TYPE = FACT2.MEDIA_ITEM_TYPE
AND FACT1.RESOURCE_ID = FACT2.RESOURCE_ID
AND FACT1.PARTY_ID = FACT2.PARTY_ID
AND FACT1.CLASSIFICATION_VALUE = FACT2.CLASSIFICATION_VALUE
AND FACT1.DNIS_NAME = FACT2.DNIS_NAME
AND FACT1.SERVER_GROUP_ID = FACT2.SERVER_GROUP_ID
AND FACT1.CAMPAIGN_ID = FACT2.CAMPAIGN_ID
AND FACT1.SCHEDULE_ID = FACT2.SCHEDULE_ID
AND FACT1.OUTCOME_ID = FACT2.OUTCOME_ID
AND FACT1.RESULT_ID = FACT2.RESULT_ID
AND FACT1.REASON_ID = FACT2.REASON_ID
AND FACT1.SOURCE_CODE_ID = FACT2.SOURCE_CODE_ID
AND FACT1.DIALING_METHOD = FACT2.DIALING_METHOD
AND FACT1.PARTITION_KEY = FACT2.PARTITION_KEY
)
WHERE REQUEST_ID = G_REQUEST_ID
AND AGENT_CONT_CALLS_HAND_NA < 0
AND LAST_UPDATE_DATE >= G_SYSDATE
AND FACT1.PERIOD_TYPE_ID > 1
AND ROWNUM <= 50000;
--AND ROWNUM <= G_COMMIT_CHUNK_SIZE;

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'AFter UPDATE of fact table ');

IF SQL%ROWCOUNT < G_COMMIT_CHUNK_SIZE
THEN
   COMMIT;
  --IF (g_debug_flag = 'Y') THEN
   --write_log('Commiting and exiting g_commit_size is ' || g_commit_chunk_size);
  --END IF;
   EXIT;
ELSE
   COMMIT;
  --IF (g_debug_flag = 'Y') THEN
   --write_log('Commiting g_commit_size is ' || g_commit_chunk_size);
  --END IF;
END IF;

END LOOP;

COMMIT;
  --IF (g_debug_flag = 'Y') THEN
--write_log('Finished procedure move_stg_to_fact at : ' || to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'Completed move_stg_to_fact ');

EXCEPTION
  WHEN OTHERS THEN
  --IF (g_debug_flag = 'Y') THEN
    --write_log('Error in procedure move_stg_to_fact : Error : ' || sqlerrm);
  --END IF;
    RAISE;
END move_stg_to_fact;

PROCEDURE rollup_data IS

BEGIN

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Start of the procedure rollup_data at : ' ||
		   --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'Before rollup_data  ');

  --Rollup half-hour information to day, month, quarter and year time bucket

--
--This can be a INSERT and not a MERGE if we assume that all the
--half hour rows would be inserted at this time into the STAGING table,
--which would be the case, provided we wait for all the workers to complete.
--
  INSERT /*+ APPEND */ INTO bix_call_details_stg STG
     (
      STG.TIME_ID,
      STG.PERIOD_TYPE_ID,
      STG.PERIOD_START_DATE,
      STG.PERIOD_START_TIME,
      STG.DAY_OF_WEEK,
      STG.DIRECTION,
      STG.MEDIA_ITEM_TYPE,
      STG.RESOURCE_ID,
      STG.PARTY_ID,
      STG.CLASSIFICATION_VALUE,
      STG.DNIS_NAME,
      STG.SERVER_GROUP_ID,
      STG.CAMPAIGN_ID,
      STG.SCHEDULE_ID,
      STG.OUTCOME_ID,
      STG.RESULT_ID,
      STG.REASON_ID,
      STG.SOURCE_CODE_ID,
	 STG.DIALING_METHOD,
      STG.PARTITION_KEY,
      STG.CALL_CALLS_OFFERED_TOTAL,
      STG.CALL_CALLS_OFFERED_ABOVE_TH,
      STG.CALL_CALLS_HANDLED_TOTAL,
      STG.CALL_CALLS_HANDLED_ABOVE_TH,
      STG.CALL_CALLS_ABANDONED,
      STG.CALL_CALLS_ABANDONED_US,
      STG.CALL_CALLS_TRANSFERRED,
      STG.CALL_IVR_TIME,
      STG.CALL_ROUTE_TIME,
      STG.call_queue_time,
      STG.CALL_TOT_QUEUE_TO_ABANDON,
      STG.call_tot_queue_to_answer,
      STG.CALL_TALK_TIME,
      STG.AGENT_TALK_TIME_NAC,
      STG.AGENT_WRAP_TIME_NAC,
      STG.AGENT_CALLS_TRAN_CONF_TO_NAC,
      STG.AGENT_CONT_CALLS_HAND_NA, --FORCE THIS TO NULL SO THAT THE UPDATE WORKS
      STG.AGENT_CALLS_HANDLED_TOTAL,
      STG.AGENT_CALLS_HANDLED_ABOVE_TH,
      STG.AGENT_CALLS_ANSWERED_BY_GOAL,
      STG.AGENT_SR_CREATED,
      STG.AGENT_LEADS_CREATED,
      STG.AGENT_LEADS_AMOUNT,
      STG.AGENT_LEADS_CONVERTED_TO_OPP,
      STG.AGENT_OPPORTUNITIES_CREATED,
      STG.AGENT_OPPORTUNITIES_WON,
      STG.AGENT_OPPORTUNITIES_WON_AMOUNT,
      STG.AGENT_OPPORTUNITIES_CROSS_SOLD,
      STG.AGENT_OPPORTUNITIES_UP_SOLD,
      STG.AGENT_OPPORTUNITIES_DECLINED,
      STG.AGENT_OPPORTUNITIES_LOST,
      STG.AGENT_PREVIEW_TIME,
      STG.AGENTCALL_ORR_COUNT,
      STG.AGENTCALL_PR_COUNT,
      STG.AGENTCALL_CONTACT_COUNT,
      STG.CREATED_BY,
      STG.CREATION_DATE,
      STG.LAST_UPDATED_BY,
      STG.LAST_UPDATE_DATE,
      STG.LAST_UPDATE_LOGIN,
      STG.REQUEST_ID,
      STG.PROGRAM_APPLICATION_ID,
      STG.PROGRAM_ID,
      STG.PROGRAM_UPDATE_DATE
      )
	 (
  SELECT
      --decode(ftd.report_date_julian, null, decode(ftd.week_id, null, decode(ftd.ent_period_id, null,
	--decode(ftd.ent_qtr_id, null, decode(ftd.ent_year_id, null, to_number(null), ftd.ent_year_id),
	--ftd.ent_qtr_id), ftd.ent_period_id), ftd.week_id), ftd.report_date_julian),
      --decode(ftd.report_date_julian, null, decode(ftd.week_id, null, decode(ftd.ent_period_id, null,
	--decode(ftd.ent_qtr_id, null, decode(ftd.ent_year_id, null, to_number(null),
                                                           --128), 64), 32), 16), 1),
      --decode(ftd.report_date_julian, null, decode(ftd.week_id, null, decode(ftd.ent_period_id, null,
	--decode(ftd.ent_qtr_id, null, decode(ftd.ent_year_id, null, to_date(null),
               --min(ftd.ent_year_start_date)),min(ftd.ent_qtr_start_date)),
               --min(ftd.ent_period_start_date)), min(ftd.week_start_date)),
	       --min(stg.period_start_date)),
      decode(ftd.week_id, null, decode(ftd.ent_period_id, null,
	decode(ftd.ent_qtr_id, null, decode(ftd.ent_year_id, null, to_number(null), ftd.ent_year_id),
	ftd.ent_qtr_id), ftd.ent_period_id), ftd.week_id),
      decode(ftd.week_id, null, decode(ftd.ent_period_id, null,
	decode(ftd.ent_qtr_id, null, decode(ftd.ent_year_id, null, to_number(null),
                                                           128), 64), 32), 16),
      decode(ftd.week_id, null, decode(ftd.ent_period_id, null,
	decode(ftd.ent_qtr_id, null, decode(ftd.ent_year_id, null, to_date(null),
               min(ftd.ent_year_start_date)),min(ftd.ent_qtr_start_date)),
               min(ftd.ent_period_start_date)), min(ftd.week_start_date)),
      '00:00',
      DAY_OF_WEEK,
      DIRECTION,
      MEDIA_ITEM_TYPE,
      RESOURCE_ID,
      PARTY_ID,
      CLASSIFICATION_VALUE,
      DNIS_NAME,
      SERVER_GROUP_ID,
      CAMPAIGN_ID,
      SCHEDULE_ID,
      OUTCOME_ID,
      RESULT_ID,
      REASON_ID,
      SOURCE_CODE_ID,
	 DIALING_METHOD,
      PARTITION_KEY,
      SUM(CALL_CALLS_OFFERED_TOTAL),
      SUM(CALL_CALLS_OFFERED_ABOVE_TH),
      SUM(CALL_CALLS_HANDLED_TOTAL),
      SUM(CALL_CALLS_HANDLED_ABOVE_TH),
      SUM(CALL_CALLS_ABANDONED),
      SUM(CALL_CALLS_ABANDONED_US),
      SUM(CALL_CALLS_TRANSFERRED),
      SUM(CALL_IVR_TIME),
      SUM(CALL_ROUTE_TIME),
      SUM(call_queue_time),
      SUM(CALL_TOT_QUEUE_TO_ABANDON),
      SUM(call_tot_queue_to_answer),
      SUM(CALL_TALK_TIME),
      SUM(AGENT_TALK_TIME_NAC),
      SUM(AGENT_WRAP_TIME_NAC),
      SUM(AGENT_CALLS_TRAN_CONF_TO_NAC),
      --NULL, SUM(AGENT_CONT_CALLS_HAND_NA),
	 -1,
      SUM(AGENT_CALLS_HANDLED_TOTAL),
      SUM(AGENT_CALLS_HANDLED_ABOVE_TH),
      SUM(AGENT_CALLS_ANSWERED_BY_GOAL),
      SUM(AGENT_SR_CREATED),
      SUM(AGENT_LEADS_CREATED),
      SUM(AGENT_LEADS_AMOUNT),
      SUM(AGENT_LEADS_CONVERTED_TO_OPP),
      SUM(AGENT_OPPORTUNITIES_CREATED),
      SUM(AGENT_OPPORTUNITIES_WON),
      SUM(AGENT_OPPORTUNITIES_WON_AMOUNT),
      SUM(AGENT_OPPORTUNITIES_CROSS_SOLD),
      SUM(AGENT_OPPORTUNITIES_UP_SOLD),
      SUM(AGENT_OPPORTUNITIES_DECLINED),
      SUM(AGENT_OPPORTUNITIES_LOST),
      SUM(AGENT_PREVIEW_TIME),
      SUM(AGENTCALL_ORR_COUNT),
      SUM(AGENTCALL_PR_COUNT),
      SUM(AGENTCALL_CONTACT_COUNT),
      g_user_id,
      g_sysdate,
      g_user_id,
      g_sysdate,
      g_user_id,
      g_request_id,
      g_program_appl_id,
      g_program_id,
      g_sysdate
   FROM  bix_call_details_stg stg,
         fii_time_day ftd
   WHERE stg.time_id = ftd.report_date_julian
   AND   stg.period_type_id = 1
   GROUP BY
      DAY_OF_WEEK,
      DIRECTION,
      MEDIA_ITEM_TYPE,
      RESOURCE_ID,
      PARTY_ID,
      CLASSIFICATION_VALUE,
      DNIS_NAME,
      SERVER_GROUP_ID,
      CAMPAIGN_ID,
      SCHEDULE_ID,
      OUTCOME_ID,
      RESULT_ID,
      REASON_ID,
      SOURCE_CODE_ID,
	 DIALING_METHOD,
      PARTITION_KEY,
   ROLLUP (
      ftd.ent_year_id,
      ftd.ent_qtr_id,
      ftd.ent_period_id,
      ftd.week_id
      --ftd.report_date_julian)
	 )
   HAVING
      --decode(ftd.report_date_julian, null, decode(ftd.week_id, null, decode(ftd.ent_period_id, null,
	  --decode(ftd.ent_qtr_id, null, decode(ftd.ent_year_id, null, to_number(null), 128), 64), 32), 16), 1) IS NOT NULL
	  --)
      decode(ftd.week_id, null, decode(ftd.ent_period_id, null,
	  decode(ftd.ent_qtr_id, null, decode(ftd.ent_year_id, null, to_number(null)
	         ,128), 64), 32), 16) IS NOT NULL
	  )
	   ;

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Total rows inserted in the staging area for day, month and year : ' || to_char(SQL%ROWCOUNT));
  --END IF;

  COMMIT;

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Finished procedure rollup_data at : ' ||
		   --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

    --write_log(to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss: ')||
						   --'After rollup_data ');

EXCEPTION
  WHEN OTHERS THEN
  --IF (g_debug_flag = 'Y') THEN
    --write_log('Error in procedure rollup_data : Error : ' || sqlerrm);
  --END IF;
    RAISE;
END rollup_data;

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

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Start of the procedure worker at : ' ||
		   --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

--dbms_output.put_line('Called worker with p_worker_no ' || p_worker_no);

  errbuf  := NULL;
  retcode := 0;

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Calling procedure init');
  --END IF;
  init;

  l_count:= 0;

  LOOP

    /* Get the status of all the jobs in BIX_WORKER_JOBS */
    --SELECT NVL(sum(decode(status,'UNASSIGNED', 1, 0)),0),
           --NVL(sum(decode(status,'FAILED', 1, 0)),0),
           --NVL(sum(decode(status,'IN PROCESS', 1, 0)),0),
           --NVL(sum(decode(status,'COMPLETED',1 , 0)),0),
           --count(*)
    --INTO   l_unassigned_cnt,
           --l_failed_cnt,
           --l_wip_cnt,
           --l_completed_cnt,
           --l_total_cnt
    --FROM   BIX_WORKER_JOBS
    --WHERE  object_name = 'BIX_CALL_DETAILS_F';

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
    WHERE worker_number = p_worker_no
    AND   object_name = 'BIX_CALL_DETAILS_F';

--dbms_output.put_line(
--'Unassigned: '||l_unassigned_cnt||
--' In Process: '||l_wip_cnt||
--' Completed: '||l_completed_cnt||
--' Failed: '||l_failed_cnt||
--' Total: '|| l_total_cnt);

  --IF (g_debug_flag = 'Y') THEN
    --write_log('Job status - Unassigned: '||l_unassigned_cnt||
                       --' In Process: '||l_wip_cnt||
                       --' Completed: '||l_completed_cnt||
                       --' Failed: '||l_failed_cnt||
                       --' Total: '|| l_total_cnt);
  --END IF;

    IF (l_failed_cnt > 0) THEN
  --IF (g_debug_flag = 'Y') THEN
      --write_log('Another worker have errored out.  Stop processing.');
  --END IF;
      EXIT;
    ELSIF (l_unassigned_cnt = 0) THEN
  --IF (g_debug_flag = 'Y') THEN
      --write_log('No more jobs left.  Terminating.');
  --END IF;
      EXIT;
    ELSIF (l_completed_cnt = l_total_cnt) THEN
  --IF (g_debug_flag = 'Y') THEN
      --write_log('All jobs completed, no more job.  Terminating');
  --END IF;
      EXIT;
    ELSIF (l_unassigned_cnt > 0) THEN
--dbms_output.put_line('setting to in process for worker ' || p_worker_no);

      /* Pickup any one unassigned job to process */
      --UPDATE BIX_WORKER_JOBS
      --SET    status        = 'IN PROCESS',
             --worker_number = p_worker_no
      --WHERE  status = 'UNASSIGNED'
      --AND    rownum < 2
      --AND    object_name = 'BIX_CALL_DETAILS_F';

      UPDATE BIX_WORKER_JOBS
      SET status = 'IN PROCESS'
      WHERE object_name = 'BIX_CALL_DETAILS_F'
      AND worker_number = p_worker_no;

      UPDATE bix_medias_for_worker
      SET    status        = 'IN PROCESS'
             --worker_number = p_worker_no
      WHERE  status = 'UNASSIGNED'
      AND worker_number = p_worker_no;

      l_count := sql%rowcount;
      COMMIT;
    END IF;

    -- -----------------------------------
    -- There could be rare situations where
    -- the unassigned job gets taken by
    -- another worker.  So, if unassigned
    -- job no longer exist.  Do nothing.
    -- -----------------------------------

    IF (l_count > 0) THEN

      DECLARE
      BEGIN

	   --
        --Collect data for half hour time buckets for the date range of the job
	   --
        --SELECT start_date_range, end_date_range
        --INTO   l_start_date_range, l_end_date_range
        --FROM   BIX_WORKER_JOBS
        --WHERE worker_number = p_worker_no
        --AND   status        = 'IN PROCESS'
        --AND   object_name   = 'BIX_CALL_DETAILS_F';

  --IF (g_debug_flag = 'Y') THEN
        --write_log('Calling procedure insert_half_hour_rows');
  --END IF;

        --insert_half_hour_rows (
                    --l_start_date_range,
                    --l_end_date_range
                   --);

        insert_half_hour_rows (
                    g_collect_start_date,
                    g_collect_end_date,
                    p_worker_no
                   );

  --IF (g_debug_flag = 'Y') THEN
        --write_log('End procedure insert_half_hour_rows');
  --END IF;

	   --
        -- Update the status of job to 'COMPLETED'
	   --
        --UPDATE BIX_WORKER_JOBS
        --SET    status = 'COMPLETED'
        --WHERE  status = 'IN PROCESS'
        --AND    worker_number = p_worker_no
        --AND    object_name = 'BIX_CALL_DETAILS_F';

        UPDATE bix_medias_for_worker
        SET    status = 'COMPLETED'
        WHERE  status = 'IN PROCESS'
        AND    worker_number = p_worker_no;

        UPDATE BIX_WORKER_JOBS
        SET    status = 'COMPLETED'
        WHERE  object_name = 'BIX_CALL_DETAILS_F'
        AND    status = 'IN PROCESS'
        AND    worker_number = p_worker_no;

        COMMIT;

      EXCEPTION
        WHEN OTHERS THEN
          retcode := -1;

          --UPDATE BIX_WORKER_JOBS
          --SET    status = 'FAILED'
          --WHERE  worker_number = p_worker_no
          --AND    status = 'IN PROCESS'
          --AND    object_name = 'BIX_CALL_DETAILS_F';

          UPDATE BIX_WORKER_JOBS
          SET    status = 'FAILED'
          WHERE  object_name = 'BIX_CALL_DETAILS_F'
          AND    status = 'IN PROCESS'
          AND    worker_number = p_worker_no;

          UPDATE bix_medias_for_worker
          SET    status = 'FAILED'
          WHERE  worker_number = p_worker_no
          AND    status = 'IN PROCESS';

          COMMIT;
  --IF (g_debug_flag = 'Y') THEN
          write_log('Error in worker');
  --END IF;
          RAISE G_CHILD_PROCESS_ISSUE;
      END;

    END IF; -- for if which checks count > 0

  END LOOP;

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Finished procedure worker at : ' ||
		   --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

EXCEPTION
   WHEN OTHERS THEN
  --IF (g_debug_flag = 'Y') THEN
     --write_log('Error in procedure worker : Error : ' || sqlerrm);
  --END IF;
     RAISE;
END WORKER;

PROCEDURE main (errbuf                OUT NOCOPY VARCHAR2,
                retcode               OUT NOCOPY VARCHAR2,
                p_number_of_processes IN         NUMBER
                )
IS

  l_has_missing_date  BOOLEAN := FALSE;
  l_no_of_workers NUMBER;
  l_last_start_date  DATE;
  l_last_end_date    DATE;
  l_last_period_from DATE;
  l_last_period_to   DATE;
  l_start_date       DATE;

BEGIN

  IF (FND_PROFILE.DEFINED('BIX_DBI_DEBUG')) THEN
    g_debug_flag := nvl(FND_PROFILE.VALUE('BIX_DBI_DEBUG'), 'N');
  END IF;

--g_debug_flag := 'Y';


g_required_workers := p_number_of_processes;

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Debug Flag : ' || g_debug_flag);
  --END IF;

  --IF (FND_PROFILE.DEFINED('BIX_DM_DELETE_SIZE')) THEN
    --g_commit_chunk_size := TO_NUMBER(FND_PROFILE.VALUE('BIX_DM_DELETE_SIZE'));
  --END IF;

    g_commit_chunk_size := 1500;

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Commit SIZE : ' || g_commit_chunk_size);
--
  --write_log('Start of the procedure main at : ' ||
             --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

  errbuf  := null;
  retcode := 0;

  truncate_table('bix_medias_for_worker');

  truncate_table('BIX_CALL_DETAILS_STG');
  --truncate_table('BIX_CALL_PROCESSED_RECS');

   cleanup_oltp; --001

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Done truncating bix_call_details_stg and bix_call_procesed_recs');
  --END IF;

--Analyze with zero rows to enable MERGE on FACT to perform with index
 DBMS_STATS.gather_table_stats(ownname => g_bix_schema,
                                tabName => 'BIX_CALL_DETAILS_STG',
                                cascade => TRUE,
                                degree => bis_common_parameters.get_degree_of_parallelism,
                                estimate_percent => 10,
                                granularity => 'GLOBAL');


  init;

  BIS_COLLECTION_UTILITIES.get_last_refresh_dates('BIX_CALL_DETAILS_F',
                                                   l_last_start_date,
                                                   l_last_end_date,
                                                   l_last_period_from,
                                                   l_last_period_to);

  --IF (g_debug_flag = 'Y') THEN
  --write_log('After get_last_refresh '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

 -- cleanup_oltp; --001 shifted the call just above,after the truncates

  IF l_last_period_to IS NULL THEN
    l_last_period_to := to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'),
						  'MM/DD/YYYY');
  END IF;

  l_last_period_to := l_last_period_to + 1/86400;

  l_start_date := l_last_period_to;

  g_collect_start_date := l_start_date;
  g_collect_end_date := sysdate;

--g_collect_start_date:=to_date('10-OCT-2003 00:00:00','DD-MON-YYYY HH24:MI:SS');
--g_collect_end_date:=to_date('11-OCT-2003 00:00:00','DD-MON-YYYY HH24:MI:SS');

  --
  -- Check if time dimension is populated for the collection date range
  --
  --IF (g_debug_flag = 'Y') THEN
  --write_log('Checking if time dimension is populated between ' ||
             --g_collect_start_date || ' and ' ||
             --g_collect_end_date
            --);
  --END IF;

  fii_time_api.check_missing_date(g_collect_start_date,
                                  g_collect_end_date,
                                  l_has_missing_date
                                 );

  IF (l_has_missing_date)
  THEN
  --IF (g_debug_flag = 'Y') THEN
     --write_log('Time dimension is not populated for the entire
			 --collection date range');
  --END IF;
     RAISE G_TIME_DIM_MISSING;
  END IF;

  --
  --If the collection date range is more than 1 day and user has
  --specified to launch more than 1 worker
  -- then launch parallel workers to do the half hour collection of each day
  --

  --IF (((g_collect_end_date - g_collect_start_date) > 1) AND
          --(p_number_of_processes > 1)) THEN
  --IF (g_debug_flag = 'Y') THEN
    --write_log('Calling register_jobs at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

--
--We will call register_jobs every time
--Do not check date range
--

    register_jobs;

                               /* Inserting PR count only into bix_call_details for the purpose of marketing mv */

    INSERT /*+ APPEND */
    INTO bix_call_details_stg STG
    (
     time_id                                ,
     period_type_id                         ,
     period_start_date                      ,
     period_start_time                      ,
     source_code_id                         ,
	party_id                               ,
     partition_key                          ,
     day_of_week                            ,
     Direction                              ,
     agentcall_pr_count                     ,
     call_calls_offered_total               ,
     call_calls_offered_above_th            ,
     call_calls_handled_total               ,
     call_calls_handled_above_th            ,
     call_calls_abandoned                   ,
     call_calls_abandoned_us                   ,
     call_calls_transferred                 ,
     call_ivr_time                          ,
     call_route_time                        ,
     call_queue_time                         ,
     CALL_TOT_QUEUE_TO_ABANDON                ,
     call_tot_queue_to_answer                 ,
     call_talk_time                         ,
     CALL_CONT_CALLS_OFFERED_NA             ,
     CALL_CONT_CALLS_HANDLED_TOT_NA         ,
     agent_talk_time_nac                    ,
     agent_wrap_time_nac                    ,
     agent_calls_tran_conf_to_nac           ,
     AGENT_CONT_CALLS_HAND_NA               ,
     AGENT_CONT_CALLS_TC_NA                  ,
     agent_calls_handled_total              ,
     agent_calls_handled_above_th           ,
     agent_calls_answered_by_goal           ,
     agent_sr_created                       ,
     agent_leads_created                    ,
     agent_leads_amount                     ,
     agent_leads_converted_to_opp           ,
     agent_opportunities_created            ,
     agent_opportunities_won                ,
     agent_opportunities_won_amount         ,
     agent_opportunities_cross_sold         ,
     agent_opportunities_up_sold            ,
     agent_opportunities_declined           ,
     agent_opportunities_lost               ,
     agent_preview_time                     ,
     agentcall_orr_count

    )
    (
    select to_char(trunc(start_date_time),'J')
    ,1,trunc(start_date_time),'00:00',source_code_id ,
    a.party_id,
    'PR',
    to_char(trunc(start_date_time),'D') ,
    'N/A',
    count(*) ,
    0,0,0,0,0,
    0,0,0,0,0,
    0,0,0,0,0,
    0,0,0,0,0,
    0,0,0,0,0,
    0,0,0,0,0,
    0,0,0,0,0,0
    from jtf_ih_interactions a, jtf_ih_results_b b
    where a.result_id=b.result_id
    and a.end_date_time between g_collect_start_date and g_collect_end_date
    and b.positive_response_flag='Y'
    and a.active='N'
    group by trunc(start_date_time),source_code_id,a.party_id
    );









  --IF (g_debug_flag = 'Y') THEN
    --write_log('Ended register_jobs at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

  --
  --Launch a parallel worker for each day of the collection date
  --range or number of processes user has requested for , whichever is less
  --
    l_no_of_workers := least(g_no_of_jobs, p_number_of_processes);

  IF (g_debug_flag = 'Y') THEN
    write_log ('g_no_of_jobs='||g_no_of_jobs||' p_num_proc='||p_number_of_processes);
    write_log('Launching workers at '||
           to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  END IF;
    FOR i IN 1 .. l_no_of_workers
    LOOP
      g_worker(i) := LAUNCH_WORKER(i);
      NULL;
    END LOOP;

  --IF (g_debug_flag = 'Y') THEN
    --write_log('Completed Launching workers at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
    --write_log('Number of Workers launched : ' || to_char(l_no_of_workers));
  --END IF;

    COMMIT;

    --
    -- Monitor child processes after launching them
    --

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

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Before worker status select '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

        --SELECT NVL(sum(decode(status,'UNASSIGNED',1,0)),0),
               --NVL(sum(decode(status,'COMPLETED',1,0)),0),
               --NVL(sum(decode(status,'IN PROCESS',1,0)),0),
               --NVL(sum(decode(status,'FAILED',1,0)),0),
               --count(*)
        --INTO   l_unassigned_cnt,
               --l_completed_cnt,
               --l_wip_cnt,
               --l_failed_cnt,
               --l_tot_cnt
        --FROM   BIX_WORKER_JOBS
        --WHERE  OBJECT_NAME = 'BIX_CALL_DETAILS_F';
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
        WHERE object_name = 'BIX_CALL_DETAILS_F';

  --IF (g_debug_flag = 'Y') THEN
  --write_log('After worker status select '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

        IF (l_failed_cnt > 0) THEN
          RAISE G_CHILD_PROCESS_ISSUE;
        END IF;

        IF (l_tot_cnt = l_completed_cnt) THEN
  --IF (g_debug_flag = 'Y') THEN
            --write_log('Total count '     ||l_tot_cnt ||
                      --'Completed count ' || l_completed_cnt ||
                      --'- can exit loop now');
  --END IF;
             EXIT;
        END IF;

        IF (l_unassigned_cnt = l_last_unassigned_cnt AND
            l_completed_cnt = l_last_completed_cnt AND
            l_wip_cnt = l_last_wip_cnt) THEN
          l_cycle := l_cycle + 1;
        ELSE
          l_cycle := 1;
        END IF;

        --IF (l_cycle > MAX_LOOP) THEN
            --write_log('Infinite loop');
            --dbms_output.put_line('Infinite loop');
            --RAISE G_CHILD_PROCESS_ISSUE;
        --END IF;

        dbms_lock.sleep(5);

        l_last_unassigned_cnt := l_unassigned_cnt;
        l_last_completed_cnt := l_completed_cnt;
        l_last_wip_cnt := l_wip_cnt;

      END LOOP;

    END;   -- Monitor child process Ends here.

--
--At this point bix_medias_for_worker is no longer needed.  Truncate this
--so that we can save some space.
--
truncate_table('bix_medias_for_worker');

  --ELSE
    --
    --Collecting only one day - so call insert_half_hour_rows
    --
  --IF (g_debug_flag = 'Y') THEN
  --write_log('Before calling insert_half_hour_rows (no workers) '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

    --insert_half_hour_rows(
               --g_collect_start_date,
               --g_collect_end_date
              --);

  --IF (g_debug_flag = 'Y') THEN
  --write_log('Completed insert_half_hour_rows '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

  --END IF;

--DBMS_STATS.gather_table_stats(ownname => g_bix_schema,
                                --tabName => 'BIX_CALL_DETAILS_STG',
                                --cascade => TRUE,
                                --degree => bis_common_parameters.get_degree_of_parallelism,
                                --estimate_percent => 10,
                                --granularity => 'GLOBAL');






  --
  -- Summarize data to day, week, month, quater and year time buckets
  --
  --IF (g_debug_flag = 'Y') THEN
  --write_log('Calling rollup_data at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;
  rollup_data;
  --IF (g_debug_flag = 'Y') THEN
  --write_log('Ended rollup_data at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

  --
  -- Merge the data to the main summary table from staging area
  --
  move_stg_to_fact;
  --IF (g_debug_flag = 'Y') THEN
  --write_log('Ended move_stg_to_fact at '||
           --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  --write_log('Total Rows Inserted/Updated : ' || to_char(g_rows_ins_upd));

  --write_log('Finished Procedure BIX_CALL_LOAD with success at : ' ||
             --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

  --END IF;
  truncate_table('BIX_CALL_DETAILS_STG');
  --truncate_table('BIX_CALL_PROCESSED_RECS');
  --IF (g_debug_flag = 'Y') THEN
  --write_log('Done truncating bix_call_details_stg and bix_call_procesed_recs');
--
  --write_log('Calling procedure WRAPUP');
  --END IF;
  bis_collection_utilities.wrapup(
      p_status      => TRUE,
      p_count       => g_rows_ins_upd,
      p_message     => NULL,
      p_period_from => g_collect_start_date,
      p_period_to   => g_collect_end_date);

  --IF (g_debug_flag = 'Y') THEN
  --write_log('End of the procedure main at : ' ||
             --to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  --END IF;

EXCEPTION
  WHEN G_TIME_DIM_MISSING THEN
    retcode := -1;
    errbuf := 'Time Dimension is not populated for the entire collection range';
    bis_collection_utilities.wrapup(
      p_status      => FALSE,
      p_count       => 0,
      p_message     => 'Load Calls summary package failed : Error : Time dimension is not populated',
      p_period_from => g_collect_start_date,
      p_period_to   => g_collect_end_date);
  WHEN G_CHILD_PROCESS_ISSUE THEN
    clean_up;
    retcode := SQLCODE;
    errbuf := SQLERRM;
    bis_collection_utilities.wrapup(
      p_status      => FALSE,
      p_count       => 0,
      p_message     => 'Load Calls summary package failed : error : ' || sqlerrm,
      p_period_from => g_collect_start_date,
      p_period_to   => g_collect_end_date);
  WHEN G_OLTP_CLEANUP_ISSUE THEN
    clean_up;
    --retcode := SQLCODE;
    --errbuf := SQLERRM;
    bis_collection_utilities.wrapup(
      p_status      => FALSE,
      p_count       => 0,
      p_message     => 'Update Calls summary package failed in OLTP cleanup : error : ' || g_errbuf,
      p_period_from => g_collect_start_date,
      p_period_to   => g_collect_end_date);
  WHEN OTHERS THEN
    clean_up;
    retcode := SQLCODE;
    errbuf := SQLERRM;
    bis_collection_utilities.wrapup(
      p_status      => FALSE,
      p_count       => 0,
      p_message     => 'Load Calls summary package failed : error : ' || sqlerrm,
      p_period_from => g_collect_start_date,
      p_period_to   => g_collect_end_date);
END main;

END BIX_CALL_UPDATE_PKG;

/
