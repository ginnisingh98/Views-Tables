--------------------------------------------------------
--  DDL for Package Body BIX_DM_REAL_QUEUE_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_DM_REAL_QUEUE_SUMMARY_PKG" AS
/*$Header: bixxrqsb.pls 115.7 2003/01/09 20:19:48 achanda noship $ */


FUNCTION GET_CLASSIFICATION (p_classification in varchar2) return NUMBER is

  v_classification_id number;
  v_classification_count number;


BEGIN

select count(classification_id)
into   v_classification_count
from   cct_classifications
where classification = p_classification;

if (v_classification_count = 0) then
   v_classification_id := -9999;
else
  select classification_id into v_classification_id from cct_classifications where classification = p_classification;
end if;

return v_classification_id;

EXCEPTION
	WHEN OTHERS THEN
		return NULL;
END;
-- GET_CALLS collects calls from OLTP to the temporary
-- table BIX_DM_REAL_QUEUE_SUM:


PROCEDURE GET_CALLS(p_session_id IN NUMBER)
AS
 v_calls_offered NUMBER;
 v_calls_abandoned NUMBER;
 v_abandon_time    NUMBER;
 v_talk_time    NUMBER;
 v_calls_answrd_within_x_time NUMBER;
 v_queue_time_answered NUMBER;
 v_calls_answered      NUMBER;
 v_calls_handled       NUMBER;
 v_period_start_date   DATE;
 v_period_start_time   VARCHAR2(30);
 v_period_start_date_time DATE;
 v_server_group_id    NUMBER;
 v_classification    VARCHAR2(64);
 v_classification_id    NUMBER;
 v_default_goal    NUMBER;
 v_goal    NUMBER;

 l_start_date  DATE;
 l_end_date  DATE;



 CURSOR call_info IS
 SELECT sum(DECODE(UPPER(ih_mitem.direction),'INBOUND',1,0)) CALLS_OFFERED,
        sum(DECODE(UPPER(ih_mitem.direction),'INBOUND',DECODE(UPPER(ih_mitem.media_abandon_flag),'Y',1,0),0)) CALLS_ABANDONED,
	ih_mitem.server_group_id SERVER_GROUP_ID,
        ih_mitem.classification CLASSIFICATION,
        TRUNC(ih_mitem.start_date_time) PERIOD_START_DATE,
        LPAD(TO_CHAR(ih_mitem.start_date_time,'HH24:'),3,'0')|| DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_mitem.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00') PERIOD_START_TIME,
	TO_DATE(TO_CHAR(ih_mitem.start_date_time,'YYYY/MM/DD ')||LPAD(TO_CHAR(ih_mitem.start_date_time,'HH24:'),3,'0') || DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_mitem.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'YYYY/MM/DD HH24:MI') PERIOD_START_DATE_TIME
   FROM      JTF_IH_MEDIA_ITEMS ih_mitem
 WHERE  ih_mitem.start_date_time BETWEEN l_start_date and l_end_date
 AND
 (
 ih_mitem.media_item_type = 'TELE_INB' or
 ih_mitem.media_item_type = 'TELE_DIRECT' or
 ih_mitem.media_item_type = 'TELE_MANUAL' or
 ih_mitem.media_item_type = 'TELE_WEB'
 )
 AND    ih_mitem.active = 'N'
GROUP BY ih_mitem.server_group_id,
         ih_mitem.classification,
         TRUNC(ih_mitem.start_date_time),
         LPAD(TO_CHAR(ih_mitem.start_date_time,'HH24:'),3,'0')|| DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_mitem.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),
	TO_DATE(TO_CHAR(ih_mitem.start_date_time,'YYYY/MM/DD ')||LPAD(TO_CHAR(ih_mitem.start_date_time,'HH24:'),3,'0') || DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_mitem.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'YYYY/MM/DD HH24:MI');

CURSOR call_data1(p_server_group_id NUMBER,
                 p_classification VARCHAR2,
                 p_period_start_date DATE,
                 p_period_start_time VARCHAR2,
                 p_period_start_date_time DATE) IS
SELECT		SUM(NVL(msegs.duration,0)) ABANDON_TIME
FROM   jtf_ih_media_items ih_mitem,
       JTF_IH_MEDIA_ITEM_LC_SEGS msegs,
       JTF_IH_MEDIA_ITM_LC_SEG_TYS mtyps
where ih_mitem.server_group_id =  p_server_group_id
and   ih_mitem.classification = p_classification
and   TRUNC(ih_mitem.start_date_time) = p_period_start_date
and   LPAD(TO_CHAR(ih_mitem.start_date_time,'HH24:'),3,'0')|| DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_mitem.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00') = p_period_start_time
and 	TO_DATE(TO_CHAR(ih_mitem.start_date_time,'YYYY/MM/DD ')||LPAD(TO_CHAR(ih_mitem.start_date_time,'HH24:'),3,'0') ||
DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_mitem.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'YYYY/MM/DD HH24:MI') = p_period_start_date_time
and  ih_mitem.media_id = msegs.media_id
and  mtyps.milcs_type_id = msegs.milcs_type_id
and  mtyps.milcs_code = 'IN_QUEUE'
and  ih_mitem.direction = 'INBOUND'
and  ih_mitem.media_abandon_flag = 'Y' ;

CURSOR call_data2(p_server_group_id NUMBER,
                 p_classification VARCHAR2,
			  p_classification_id NUMBER,
                 p_period_start_date DATE,
                 p_period_start_time VARCHAR2,
                 p_period_start_date_time DATE) IS
SELECT count(distinct msegs.media_id) CALLS_ANSWRD_WITHIN_X_TIME
FROM   jtf_ih_media_items ih_mitem,
       JTF_IH_MEDIA_ITEM_LC_SEGS msegs,
       JTF_IH_MEDIA_ITM_LC_SEG_TYS mtyps
where ih_mitem.server_group_id =  p_server_group_id
and   ih_mitem.classification = p_classification
and   TRUNC(ih_mitem.start_date_time) = p_period_start_date
and   LPAD(TO_CHAR(ih_mitem.start_date_time,'HH24:'),3,'0')|| DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_mitem.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00') = p_period_start_time
and 	TO_DATE(TO_CHAR(ih_mitem.start_date_time,'YYYY/MM/DD ')||LPAD(TO_CHAR(ih_mitem.start_date_time,'HH24:'),3,'0') ||
DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_mitem.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'YYYY/MM/DD HH24:MI') = p_period_start_date_time
and  ih_mitem.media_id = msegs.media_id
and  mtyps.milcs_type_id = msegs.milcs_type_id
and  mtyps.milcs_code = 'IN_QUEUE'
and  ih_mitem.direction = 'INBOUND'
and  msegs.duration <= v_goal
and (ih_mitem.media_abandon_flag = 'N' or ih_mitem.media_abandon_flag is null);

CURSOR call_data3(p_server_group_id NUMBER,
                 p_classification VARCHAR2,
                 p_period_start_date DATE,
                 p_period_start_time VARCHAR2,
                 p_period_start_date_time DATE) IS
SELECT		SUM(NVL(msegs.duration,0)) queue_time_answered,
                count(distinct(ih_mitem.media_id)) calls_answered
FROM   jtf_ih_media_items ih_mitem,
       JTF_IH_MEDIA_ITEM_LC_SEGS msegs,
       JTF_IH_MEDIA_ITM_LC_SEG_TYS mtyps
where ih_mitem.server_group_id =  p_server_group_id
and   ih_mitem.classification = p_classification
and   ih_mitem.active = 'N'
and   TRUNC(ih_mitem.start_date_time) = p_period_start_date
and   LPAD(TO_CHAR(ih_mitem.start_date_time,'HH24:'),3,'0')|| DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_mitem.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00') = p_period_start_time
and 	TO_DATE(TO_CHAR(ih_mitem.start_date_time,'YYYY/MM/DD ')||LPAD(TO_CHAR(ih_mitem.start_date_time,'HH24:'),3,'0') ||
DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_mitem.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'YYYY/MM/DD HH24:MI') = p_period_start_date_time
and  ih_mitem.media_id = msegs.media_id
and  mtyps.milcs_type_id = msegs.milcs_type_id
and  mtyps.milcs_code = 'IN_QUEUE'
and  ih_mitem.direction = 'INBOUND'
and (ih_mitem.media_abandon_flag = 'N' or ih_mitem.media_abandon_flag is null);

CURSOR call_data4(p_server_group_id NUMBER,
                 p_classification VARCHAR2,
                 p_period_start_date DATE,
                 p_period_start_time VARCHAR2,
                 p_period_start_date_time DATE) IS
SELECT		SUM(NVL(msegs.duration,0)) talk_time,
                count(distinct(msegs.media_id)) calls_handled
FROM   jtf_ih_media_items ih_mitem,
       JTF_IH_MEDIA_ITEM_LC_SEGS msegs,
       JTF_IH_MEDIA_ITM_LC_SEG_TYS mtyps
where ih_mitem.server_group_id =  p_server_group_id
and   ih_mitem.classification = p_classification
and   ih_mitem.active = 'N'
and   TRUNC(ih_mitem.start_date_time) = p_period_start_date
and   LPAD(TO_CHAR(ih_mitem.start_date_time,'HH24:'),3,'0')|| DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_mitem.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00') = p_period_start_time
and 	TO_DATE(TO_CHAR(ih_mitem.start_date_time,'YYYY/MM/DD ')||LPAD(TO_CHAR(ih_mitem.start_date_time,'HH24:'),3,'0')
|| DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_mitem.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'YYYY/MM/DD HH24:MI') = p_period_start_date_time
and  ih_mitem.media_id = msegs.media_id
and  mtyps.milcs_type_id = msegs.milcs_type_id
and  mtyps.milcs_code = 'WITH_AGENT'
and  ih_mitem.direction = 'INBOUND';

CURSOR goal_default_c
IS  SELECT goals.SL_SECONDS_GOAL goal from bix_dm_goals goals
where goals.call_type_id = -999
and  goals.end_date_active is null;

CURSOR goal_c
IS   SELECT goals.SL_SECONDS_GOAL goal from bix_dm_goals goals
where goals.call_type_id = v_classification_id
and  goals.end_date_active is null;

BEGIN
l_start_date := trunc(sysdate);
l_end_date   := sysdate;
delete from bix_dm_real_queue_sum
where session_id = p_session_id;

FOR call in call_info LOOP
    v_calls_offered := call.calls_offered;
    v_calls_abandoned := call.calls_abandoned;
    v_period_start_date := call.period_start_date;
    v_period_start_time := call.period_start_time;
    v_period_start_date_time := call.period_start_date_time;
    v_classification := call.classification;
    v_server_group_id := call.server_group_id;
    v_classification_id := GET_CLASSIFICATION(v_classification);
    v_default_goal := 30;
    for defaultgoal in goal_default_c
    LOOP
          v_default_goal := defaultgoal.goal;
    END LOOP;
    v_goal := v_default_goal;
    for goalclass in goal_c
    LOOP
          v_goal := goalclass.goal;
    END LOOP;
    for calldata1 in call_data1(v_server_group_id, v_classification,
	     v_period_start_date, v_period_start_time, v_period_start_date_time)
    LOOP
             v_abandon_time := calldata1.abandon_time;
    end LOOP;
    for calldata2 in call_data2(v_server_group_id, v_classification, v_classification_id ,
	     v_period_start_date, v_period_start_time, v_period_start_date_time)
    LOOP
             v_calls_answrd_within_x_time := calldata2.calls_answrd_within_x_time;
    end LOOP;
    for calldata3 in call_data3(v_server_group_id, v_classification,
	     v_period_start_date, v_period_start_time, v_period_start_date_time)
    LOOP
             v_queue_time_answered := calldata3.queue_time_answered;
             v_calls_answered := calldata3.calls_answered;
    end LOOP;
    for calldata4 in call_data4(v_server_group_id, v_classification,
	     v_period_start_date, v_period_start_time, v_period_start_date_time)
    LOOP
             v_talk_time := calldata4.talk_time;
             v_calls_handled := calldata4.calls_handled;
    end LOOP;

    insert into BIX_DM_REAL_QUEUE_SUM
		(
		calls_offered,
		calls_abandoned,
		abandon_time,
		talk_time,
		calls_answrd_within_x_time,
		queue_time_answered,
		calls_answered,
		calls_handled,
		server_group_id,
		classification,
		classification_id,
		period_start_date,
		period_start_time,
		period_start_date_time,
		session_id
		)
		values
		(
		v_calls_offered,
		v_calls_abandoned,
		v_abandon_time,
		decode(v_talk_time, NULL, 0, v_talk_time),
		decode(v_calls_answrd_within_x_time, NULL, 0, v_calls_answrd_within_x_time),
		v_queue_time_answered,
		v_calls_answered,
		v_calls_handled,
		v_server_group_id,
		v_classification,
		v_classification_id,
		v_period_start_date,
		v_period_start_time,
		v_period_start_date_time,
		p_session_id
		);
  END LOOP;
COMMIT;
END  GET_CALLS;
END BIX_DM_REAL_QUEUE_SUMMARY_PKG;

/
