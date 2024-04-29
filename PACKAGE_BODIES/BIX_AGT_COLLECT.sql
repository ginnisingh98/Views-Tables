--------------------------------------------------------
--  DDL for Package Body BIX_AGT_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_AGT_COLLECT" AS
/* $Header: bixsesso.plb 115.0 2004/09/14 00:41:29 anasubra noship $ */
PROCEDURE WRITE_LOG(p_msg IN VARCHAR2, p_proc_name IN VARCHAR2);

PROCEDURE COLLATE_AGENT(p_start_date IN DATE,
                                   p_end_date   IN DATE)
AS
  v_available_time NUMBER;
  v_wrap_time NUMBER;
  v_talk_time NUMBER;
  v_idle_time NUMBER;
  v_logged_in_time NUMBER;
  v_calls_answered NUMBER;
  v_resource_id    NUMBER;
  v_ses_start_date DATE;
  v_ses_end_date   DATE;
  v_center_id NUMBER;

  CURSOR get_login_time IS
  select sum((iss.end_date_time - iss.begin_date_time) * 24 * 3600) login_time,
         iss.resource_id,
         iss.begin_date_time ,
         iss.end_date_time
  from   ieu_sh_sessions iss
   where	 iss.begin_date_time between p_start_date and p_end_date
           and iss.active_flag is NULL
   group by iss.resource_id, iss.begin_date_time,iss.end_date_time;

  CURSOR get_available_time IS
  select sum((isa.end_date_time - isa.begin_date_time) * 24 * 3600) available_time
  from   ieu_sh_activities isa, ieu_sh_sessions iss
   where isa.session_id = iss.session_id
	    and isa.activity_type_code = 'WORK_REQUEST'
	    and iss.begin_date_time =  v_ses_start_date
	    and iss.ACTIVE_FLAG is NULL
	    and iss.resource_id = v_resource_id;

  CURSOR get_times IS
  SELECT interaction_center_id,
         sum(talk_time) talk_time,
         sum(wrap_time) wrap_time,
         SUM(DECODE(NVL(USER_ATTRIBUTE2,'F'),'T',1,NULL)) calls_answered
  FROM   bix_interactions
  WHERE  resource_id = v_resource_id
  AND    start_ts BETWEEN  v_ses_start_date AND v_ses_end_date
  group by interaction_center_id;


/*
  CURSOR get_wrap_time IS
  SELECT sum((act.end_date_time - act.start_date_time) * 24 * 3600) wrap_time
  FROM   jtf_ih_activities act, ieu_sh_activities isa, jtf_ih_interactions int,  jtf_ih_action_items_vl actitems
  WHERE  act.media_id = isa.media_id
  AND    act.interaction_id = int.interaction_id
  AND    int.resource_id = v_resource_id
  AND    (act.start_date_time, 'DD/MON/YYYY') = v_day
  AND    act.action_item_id = actitems.action_item_id
  AND    actitems.action_item = 'Wrapup';
*/

/*
  CURSOR get_wrap_time IS
  SELECT sum((int.end_date_time - seg.end_date_time) * 24 * 3600) wrap_time
  FROM   jtf_ih_interactions int, jtf_ih_media_item_lc_segs seg, jtf_ih_media_itm_lc_seg_tys tys, ieu_sh_activities isa, ieu_sh_sessions iss
  WHERE  iss.resource_id = v_resource_id
  AND    iss.begin_date_time = v_day
  AND    iss.active_flag is null
  AND    isa.session_id = iss.session_id
  AND    int.productive_time_amount = isa.media_id
  AND    seg.media_id = int.productive_time_amount
  AND    seg.resource_id = int.resource_id
  AND    seg.milcs_type_id = tys.milcs_type_id
  AND    tys.milcs_code = 'WITH_AGENT'
  AND    int.end_date_time > seg.end_date_time;
*/


  CURSOR center_id IS
  SELECT server_group_id center_id
  FROM   jtf_rs_resource_extns
  WHERE  resource_id = v_resource_id;


BEGIN
      -- delete the existing data for the selected date range

      DELETE from BIX_SUM_AGENT
      WHERE  day between p_start_date and p_end_date;

      OPEN get_login_time;
	 FETCH get_login_time
	 INTO  v_logged_in_time, v_resource_id, v_ses_start_date,v_ses_end_date;
   /*
	   for center_data in center_id LOOP
	       v_center_id := center_data.center_id;
        end LOOP;
   */
        WHILE get_login_time%FOUND LOOP

		    v_available_time := 0;
		    v_talk_time := 0;
		    v_wrap_time := 0;
		    v_idle_time := 0;
              v_calls_answered := 0;
              v_center_id := NULL;

		for available_data IN get_available_time LOOP
		    v_available_time := available_data.available_time;
          end loop;

          for call_times IN get_times LOOP
                    v_center_id := call_times.interaction_center_id;
                    v_talk_time := call_times.talk_time;
                    v_wrap_time := call_times.wrap_time;
                    v_calls_answered := call_times.calls_answered;
          end loop;

      /*
		for talk_data IN get_talk_time LOOP
		    v_talk_time := talk_data.talk_time;
		    v_calls_answered := talk_data.calls_answered;
          end loop;
		for wrap_data IN get_wrap_time LOOP
		    v_wrap_time := wrap_data.wrap_time;
          end loop;
      */
-- if talk time is undefined set to 0
                if (v_talk_time is NULL) then
                    v_talk_time := 0;
                end if;
-- if available time is undefined set to 0
                if (v_available_time is NULL) then
                    v_available_time := 0;
                end if;
-- if wrap time is undefined set to 0
                if (v_wrap_time is NULL) then
                    v_wrap_time := 0;
                end if;
--		v_day_date := to_date(v_day, 'DD/MON/YYYY');
          v_idle_time := v_logged_in_time - v_talk_time - v_available_time - v_wrap_time;

	    IF ( v_center_id IS NULL) THEN
            for center_data in center_id LOOP
	         v_center_id := center_data.center_id;
	       end LOOP;
         END IF;

         INSERT INTO BIX_SUM_AGENT
      	(
          INTERACTION_CENTER_ID,
          RESOURCE_ID,
          TALK_TIME,
          AVAILABLE_TIME,
          WRAP_TIME,
          IDLE_TIME,
          LOGGED_IN_TIME,
          CALLS_ANSWERED,
	  DAY
          )
         VALUES
         (
	 v_center_id,
	 v_resource_id,
         v_talk_time,
         v_available_time,
	 v_wrap_time,
 	 v_idle_time,
	 v_logged_in_time,
	 v_calls_answered,
         v_ses_start_date
	);
	    FETCH get_login_time
	       INTO  v_logged_in_time, v_resource_id, v_ses_start_date,v_ses_end_date;
     /*
	    for center_data in center_id LOOP
	       v_center_id := center_data.center_id;
         end LOOP;

     */

     END LOOP;
     CLOSE get_login_time;
	COMMIT;
END COLLATE_AGENT;

PROCEDURE COLLECT_AGT_DATA( errbuf out nocopy varchar2,
					   retcode out nocopy varchar2,
					   p_start_date IN varchar2,
					   p_end_date   IN varchar2)
  AS

  no_messages exception;
  pragma exception_init (no_messages, -25228);
  l_start_date     DATE;
  l_end_date       DATE;

  l_ih_interaction_id  NUMBER(15,0);
  l_num_interactions NUMBER;

  l_b_remove  BOOLEAN;

  l_num_processed  PLS_INTEGER   := 0;
  l_num_skipped    PLS_INTEGER := 0;
  l_num_missing    PLS_INTEGER := 0;

  l_start_secs  NUMBER;
BEGIN
--	 dbms_output.put_line('starting');
      l_start_date := to_date(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
      l_end_date := to_date(p_end_date, 'YYYY/MM/DD HH24:MI:SS');
  -- defaults for request set program
  --   default start date to end date -1 if the dates are equal
   IF (l_start_date = l_end_date) THEN
      l_start_date := l_end_date - 1;
   END IF;
	 COLLATE_AGENT(l_start_date, l_end_date);
   EXCEPTION
	 WHEN OTHERS THEN
	    write_log('Error:' || sqlerrm, 'BIX_AGT_COLLECT.COLLECT_AGT_DATA');
END COLLECT_AGT_DATA;

PROCEDURE COLLECT_AGT_DATA(p_start_date IN VARCHAR2,
					  p_end_date   IN VARCHAR2)
AS
  l_ih_interaction_id  NUMBER(15,0);
  l_num_interactions NUMBER;
  l_start_date     DATE;
  l_end_date       DATE;
BEGIN
      l_start_date := to_date(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
      l_end_date := to_date(p_end_date, 'YYYY/MM/DD HH24:MI:SS');
	 COLLATE_AGENT(l_start_date, l_end_date);
   EXCEPTION
	 WHEN OTHERS THEN
	    write_log('Error:' || sqlerrm, 'BIX_AGT_COLLECT.COLLECT_AGT_DATA');
END COLLECT_AGT_DATA;

PROCEDURE WRITE_LOG(p_msg VARCHAR2, p_proc_name VARCHAR2) IS
BEGIN
    FND_FILE.PUT_LINE(fnd_file.log,'Load Interactions Log - ' || p_msg || ': '|| p_proc_name);
END WRITE_LOG;

END BIX_AGT_COLLECT;

/
