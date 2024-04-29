--------------------------------------------------------
--  DDL for Package Body BIX_DM_AGENT_CALL_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_DM_AGENT_CALL_SUMMARY_PKG" AS
/*$Header: bixxcalb.pls 115.109 2004/04/13 11:36:01 suray ship $ */

  g_request_id       NUMBER := FND_GLOBAL.CONC_REQUEST_ID();
  g_program_appl_id  NUMBER := FND_GLOBAL.PROG_APPL_ID();
  g_program_id       NUMBER := FND_GLOBAL.CONC_PROGRAM_ID();
  g_user_id          NUMBER := FND_GLOBAL.USER_ID();
  g_insert_count NUMBER := 0;
  g_delete_count NUMBER := 0;
  g_program_start_date  DATE := SYSDATE;
  g_collect_start_date     DATE;
  g_collect_end_date       DATE;
  g_error_mesg     VARCHAR2(4000) := NULL;
  g_status	   VARCHAR2(4000) := 'FAILED';
  g_table_name	   VARCHAR2(100) := 'BIX_DM_INTERFACE';
  g_proc_name	   VARCHAR2(4000);
  g_min_call_begin_date DATE;
  g_max_call_begin_date DATE;
  g_rounded_collect_start_date DATE;
  g_rounded_collect_end_date DATE;
  g_commit_chunk_size number;
  g_preferred_currency VARCHAR2(15);
  g_conversion_type VARCHAR2(30);
  g_bix_schema                  VARCHAR2(30) := 'BIX';

  g_dial_count NUMBER :=0;
  g_contact_count NUMBER :=0;
  g_noncontact_count NUMBER :=0;
  g_abandon_count NUMBER :=0;
  g_busy_count NUMBER :=0;
  g_rna_count NUMBER :=0;
  g_ansmc_count NUMBER :=0;
  g_sit_count NUMBER :=0;
  g_pr_count NUMBER :=0;
  g_connect_count NUMBER :=0;
  g_nonconnect_count NUMBER :=0;
  g_other_count NUMBER :=0;
  g_debug_flag                  VARCHAR2(1)  := 'N';

  G_DATE_MISMATCH  EXCEPTION;

  g_interaction_resource NUMBER;
  g_ao_dummy_resource NUMBER;

/*======================================================================================================+
| WRITE_LOG procedure writes error message into FND log file and also calls INSERT_LOG procedure        |
| for writing error details into BIX_DM_COLLECT_LOG table when ever any procedure fails in this Package.|
======================================================================================================+*/

-- GET_CALLS collects calls from OLTP to the temporary
-- Deletes in chunks, thus easing the rollback segments problem.
-- The chunk size (in rows) can be defined by the user by setting the
-- BIX_DM_DELETE_SIZE profile. If this is not set, then the default
-- chunk size is 100 rows.

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

PROCEDURE INSERT_LOG
AS
  l_bix_collect_log_seq NUMBER;
BEGIN

        SELECT BIX_DM_COLLECT_LOG_S.NEXTVAL INTO l_bix_collect_log_seq FROM DUAL;

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
	ROWS_INSERTED,
	ROWS_DELETED,
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
	l_bix_collect_log_seq,
 	NULL,
	g_table_name,
	'TABLE',
	g_program_start_date,
	SYSDATE,
	g_collect_start_date,
     g_collect_end_date,
	g_status,
	g_error_mesg,
	g_insert_count,
	g_delete_count,
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

  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END INSERT_LOG;

PROCEDURE WRITE_LOG(p_msg VARCHAR2, p_proc_name VARCHAR2) IS
	BEGIN

fnd_file.put_line(fnd_file.log,TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')|| p_proc_name || ' : '||p_msg);

END WRITE_LOG;

PROCEDURE DELETE_IN_CHUNKS(table_name in varchar2,
                           where_condition in varchar2 ,
                           rows_deleted out nocopy number)
is
l_delete_statement varchar2(4000);
l_rows_deleted number;
e_statement_too_long EXCEPTION;
e_invalid_condition EXCEPTION;

begin

--
--Changed on 08/21/2003 - SQL statement is not allowed to
--have variables concatenated to it.  Change to actual statement
--

l_rows_deleted := 0;

loop

   if upper(table_name) = 'BIX_DM_CALL_SUM'
   then
      DELETE BIX_DM_CALL_SUM
      WHERE period_start_date_time BETWEEN g_min_call_begin_date
         AND g_max_call_begin_date
      AND rownum <= g_commit_chunk_size;
   elsif upper(table_name) = 'BIX_DM_AGENT_SUM'
   then
      DELETE BIX_DM_AGENT_SUM
      WHERE period_start_date_time BETWEEN g_min_call_begin_date
         AND g_max_call_begin_date
      AND rownum <= g_commit_chunk_size;
   elsif upper(table_name) = 'BIX_DM_GROUP_SUM'
   then
      DELETE BIX_DM_GROUP_SUM
      WHERE period_start_date_time BETWEEN g_min_call_begin_date
         AND g_max_call_begin_date
      AND rownum <= g_commit_chunk_size;
   elsif upper(table_name) = 'BIX_DM_AGENT_OUTCOME_SUM'
   then
      DELETE BIX_DM_AGENT_OUTCOME_SUM
      WHERE period_start_date_time BETWEEN g_min_call_begin_date
         AND g_max_call_begin_date
      AND rownum <= g_commit_chunk_size;
   elsif upper(table_name) = 'BIX_DM_GROUP_OUTCOME_SUM'
   then
      DELETE BIX_DM_GROUP_OUTCOME_SUM
      WHERE period_start_date_time BETWEEN g_min_call_begin_date
         AND g_max_call_begin_date
      AND rownum <= g_commit_chunk_size;
   elsif upper(table_name) = 'BIX_DM_EXCEL'
   then
      DELETE BIX_DM_EXCEL
      WHERE creation_date < SYSDATE-2/24
      AND rownum <= g_commit_chunk_size;
   else
	 RAISE e_invalid_condition;
   end if;

	--execute immediate l_delete_statement;

	l_rows_deleted := l_rows_deleted + SQL%ROWCOUNT;

	-- dbms_output.put_line('Rows deleted: '||to_char(l_rows_deleted));

	if SQL%ROWCOUNT < g_commit_chunk_size then
		commit;
		exit;
	else
		commit;
	end if;

end loop;

rows_deleted := l_rows_deleted;

EXCEPTION
	when e_invalid_condition then
	    g_proc_name := 'BIX_DM_AGENT_CALL_SUMMARY_PKG.DELETE_IN_CHUNKS';
	    g_error_mesg := 'Invalid IF condition in delete ';
            raise;
	when e_statement_too_long then
	    g_error_mesg := ' SQL Statement too long (4000 char or more). ';
	when others then
	    g_proc_name := 'BIX_DM_AGENT_CALL_SUMMARY_PKG.DELETE_IN_CHUNKS';
	    g_error_mesg := g_proc_name || g_error_mesg ||' : '|| sqlerrm;
		raise;
end;

-- campaign list and sublist info for the call (only if the call has a campaign
-- schedule id associated with it)

PROCEDURE GET_LIST_INFO ( p_source_item_id in NUMBER,
                          p_campaign_id  OUT NOCOPY NUMBER,
                          p_campaign_schedule_id OUT NOCOPY NUMBER,
                          p_source_list_id OUT NOCOPY NUMBER,
                          p_sublist_id OUT NOCOPY NUMBER,
					 p_dialing_method OUT NOCOPY VARCHAR2) IS

BEGIN

          select a.list_subset_id,b.list_header_id,c.campaign_id,c.schedule_id,d.dialing_method
                 INTO p_sublist_id,p_source_list_id,p_campaign_id,p_campaign_schedule_id,p_dialing_method
          from
                 iec_g_list_subsets a,
			  ams_act_lists b,
                 AMS_CAMPAIGN_SCHEDULES_VL c,
                 ams_list_headers_all d
          where
                 a.list_header_id = b.list_header_id AND
                 b.list_used_by_id = c.schedule_id AND
			  b.list_act_type = 'TARGET' AND
			  b.list_used_by = 'CSCH' AND
			  b.list_header_id = d.list_header_id AND
                 a.list_subset_id = p_source_item_id ;
EXCEPTION
	WHEN OTHERS THEN
		p_source_list_id := NULL;
		p_sublist_id := NULL;
                p_campaign_id := NULL;
                p_campaign_schedule_id := NULL;
			 p_dialing_method := NULL;

END;

FUNCTION GET_DNIS(p_dnis in varchar2) return NUMBER is

    l_dnis number;

BEGIN
    if p_dnis is not null then
        select DNIS_ID into l_dnis from bix_dm_dnis where dnis = p_dnis;
	   return l_dnis;
    else
	   return null;
    end if;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
	select bix.bix_dm_dnis_s.nextval into l_dnis from dual;
	insert into bix_dm_dnis (dnis_id,dnis,last_update_date,last_updated_by,
				creation_date) values (l_dnis,p_dnis,sysdate,g_user_id,
				sysdate);
	commit;
	return l_dnis;
  WHEN OTHERS THEN
        return null;
END;




-- Leads Amount:

procedure GET_LEAD_AMOUNT ( p_lead_id in number,
                            p_resource_id in number,
                            p_act_start_time in DATE,
			    p_leads_amount out NOCOPY NUMBER,
			    p_currency_code out NOCOPY varchar2
			) is

BEGIN


select budget_amount,currency_code into p_leads_amount, p_currency_code
from as_sales_leads asl, jtf_rs_resource_extns res
where asl.sales_lead_id = p_lead_id
and asl.created_by = res.user_id
--and asl.creation_date >= p_act_start_time
and res.resource_id = p_resource_id;


EXCEPTION
        WHEN OTHERS THEN
		p_leads_amount := 0;
		 p_currency_code := NULL;
END;
-- Opportunity amount:

procedure GET_OPPORTUNITY_AMOUNT ( p_opp_id in NUMBER,
                                 p_resource_id in number,
                                 p_act_start_time in date,
				 p_opp_won out NOCOPY NUMBER,
				 p_opp_amount out NOCOPY NUMBER,
				 p_currency_code out NOCOPY varchar2) is

BEGIN

select total_amount,currency_code,1
into p_opp_amount, p_currency_code,p_opp_won
from as_leads_all a,
     as_statuses_vl asv,
     jtf_rs_resource_extns res
where a.lead_id = p_opp_id
and a.status = asv.status_code
and asv.win_loss_indicator = 'W'
and res.resource_id = p_resource_id
and a.created_by = res.user_id
--and a.creation_date >= p_act_start_time;
;

EXCEPTION
        WHEN OTHERS THEN
                p_opp_amount := 0;
                 p_currency_code := NULL;
		p_opp_won := 0;
END;

-- SR Status:

procedure GET_SR_STATUS (p_sr_id in number,
                         p_resource_id in number,
                         p_act_start_time in date,
                         p_sr_status out NOCOPY number) is

v_max_date DATE;

BEGIN

--select incident_status_id into p_sr_status from cs_incidents_all_b
--where INCIDENT_ID = p_sr_id;

--
--Find out if the agent changed the status from OPEN to CLOSED.
--We have to compare it with the activity start time and make sure
--the creation_date is greater than the activity start time. Also, there
--might be multiple records which meet this criteria, in case the agent
--updated the same SR multiple times. In order to take care of the case
--where the agnet has updated the same SR multiple times, we use a ORDER BY clause
--and ROWNUM = 1.
--

select incident_status_id
into p_sr_status
from
(
select incident_status_id
from CS_INCIDENTS_AUDIT_B AUD, JTF_RS_RESOURCE_EXTNS RES
where AUD.INCIDENT_ID = p_sr_id
and AUD.last_update_date >= p_act_start_time
and RES.resource_id = p_resource_id
and AUD.last_updated_by = RES.user_id
--and AUD.old_incident_status_id IN (1,3)  -- open status
--and AUD.incident_status_id IN (2,4)      -- closed status
and AUD.change_incident_status_flag = 'Y'
order by AUD.last_update_date
)
where rownum = 1;

EXCEPTION
        WHEN OTHERS THEN
                p_sr_status := 0;

END;



-- Retrievs source_code from the interactions table. If multiple records in
-- interactions with different source_codes (should not happen), retrieve
-- the first non null.

FUNCTION GET_SOURCE_CODE (p_media_id in varchar2) return VARCHAR2 is

  v_source_code varchar2(30);


BEGIN

   BEGIN

      select SOURCE_CODE
	 into v_source_code
	 from jtf_ih_interactions
      where productive_time_amount = p_media_id
      and SOURCE_CODE is not null
      and rownum = 1;

   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      select int.SOURCE_CODE
      into v_source_code
      from jtf_ih_interactions int, jtf_ih_activities act
      where int.interaction_id = act.interaction_id
      AND   act.media_id = p_media_id
      and int.SOURCE_CODE is not null
      and rownum = 1;

   END;

return v_source_code;

EXCEPTION
	WHEN OTHERS THEN
		return NULL;

END;


-- Retrievs entity type  - if campaign retrns 'CAMP', if campaign schedule,
-- returns 'CSCH'.

FUNCTION GET_CAMPAIGN_CODE (p_source_code in varchar2) return VARCHAR2 is

  sc_code varchar2(10);


BEGIN

select ARC_SOURCE_CODE_FOR into sc_code from ams_source_codes
      where source_code = p_source_code;

return sc_code;

EXCEPTION
	WHEN OTHERS THEN
		return NULL;
END;


procedure GET_CAMPAIGN_INFO (p_source_code in varchar2,
			    p_campaign_id out NOCOPY number,
			    p_campaign_schedule_id out NOCOPY number)
is

  v_sc_code varchar2(10);
begin

	select ARC_SOURCE_CODE_FOR into v_sc_code from ams_source_codes
      where source_code = p_source_code;

		if v_sc_code = 'CAMP' then
		     select campaign_id into p_campaign_id
                         from
                         ams_campaigns_all_b
			 where
                         source_code = p_source_code;

			p_campaign_schedule_id := NULL;

		elsif v_sc_code = 'CSCH' then
		         select campaign_schedule_id into p_campaign_schedule_id
			    from AMS_CAMPAIGN_SCHEDULES
			    where
			    source_code = p_source_code;

			p_campaign_id := NULL;
		else
				p_campaign_id := NULL;
				p_campaign_schedule_id := NULL;
		end if;

EXCEPTION
	WHEN OTHERS THEN
		p_campaign_id := NULL;
		p_campaign_schedule_id := NULL;
end;


-- Retrieves interaction end time to calculate wrap time:

FUNCTION GET_INTERACTION_END_TIME (p_resource_id in number,
	  					 p_media_id in number) return date is

int_end_date_time date;


BEGIN

select max(end_date_time)
into   int_end_date_time
from jtf_ih_interactions
where  resource_id = p_resource_id
and productive_time_amount = p_media_id;

IF int_end_date_time IS NULL
THEN

select max(int.end_date_time)
into   int_end_date_time
from jtf_ih_interactions int, jtf_ih_activities act
where  int.resource_id = p_resource_id
and int.interaction_id = act.interaction_id
AND   act.media_id = p_media_id;

END IF;

return int_end_date_time;

EXCEPTION
WHEN OTHERS THEN
   return NULL;

END;

PROCEDURE get_outcome_counts (P_MEDIA_ID IN NUMBER,
                              P_RESOURCE_ID IN NUMBER)
IS

v_resource_id NUMBER;

BEGIN

g_dial_count :=0;
g_contact_count :=0;
g_noncontact_count :=0;
g_abandon_count :=0;
g_busy_count :=0;
g_rna_count :=0;
g_ansmc_count :=0;
g_sit_count :=0;
g_pr_count :=0;
g_connect_count :=0;
g_nonconnect_count :=0;
g_other_count :=0;

BEGIN

IF (g_debug_flag = 'Y') THEN
   write_log('Entered get_outcome counts', g_proc_name);
END IF;

g_interaction_resource := NULL;

--select earliest agent who made/took the call
select resource_id
into v_resource_id
from jtf_ih_interactions int1, jtf_ih_activities act1
where int1.start_date_time =
(select min(int2.start_date_time)
from jtf_ih_interactions int2, jtf_ih_activities act2
where act2.media_id = p_media_id
and act2.interaction_id = int2.interaction_id
and int2.resource_id <> 0  --avoid PREVIEW calls have resourceid of 0
and int2.resource_id <> g_ao_dummy_resource
)
and act1.interaction_id = int1.interaction_id
and act1.media_id = p_media_id
and int1.resource_id <> 0  --avoid PREVIEW calls with resourceid of 0
and int1.resource_id <> g_ao_dummy_resource
and rownum = 1
;

IF (g_debug_flag = 'Y') THEN
   write_log('p_resource id is ' || p_resource_id, g_proc_name);
   write_log('v_resource id is ' || v_resource_id, g_proc_name);
END IF;

g_interaction_resource := v_resource_id;

EXCEPTION
WHEN NO_DATA_FOUND
THEN
IF (g_debug_flag = 'Y') THEN
   write_log('Exception - no with agent segs', g_proc_name);
END IF;
   --no with_agent segments --- credit 1 call at call row type
   v_resource_id := NULL;
   g_dial_count := 1; --credit 1 call at call row type
WHEN OTHERS
THEN
IF (g_debug_flag = 'Y') THEN
   write_log('Some other exception ' ||sqlerrm, g_proc_name);
END IF;
   v_resource_id := NULL;
END;

IF p_resource_id IS NOT NULL
THEN

   IF (g_debug_flag = 'Y') THEN
      write_log('p_resource_id is not null', g_proc_name);
   END IF;

   IF p_resource_id = v_resource_id  --earliest agent
   THEN

      IF (g_debug_flag = 'Y') THEN
         write_log('p = v hence dial count is 1', g_proc_name);
      END IF;

      g_dial_count   := 1;
   END IF;

   SELECT MAX(DECODE(clook.contact_flag,'Y',1,0)) contacts,
          MAX(DECODE(clook.contact_flag,'N',1,0)) noncontacts,
          MAX(DECODE(int.outcome_id,11,1,0)) abandoned,
          MAX(DECODE(int.outcome_id,2,1,0)) busy,
          MAX(DECODE(int.outcome_id,1,1,0)) ring_no_ansewr,
          MAX(DECODE(int.outcome_id,6,1,0)) answering_machine,
          MAX(DECODE(int.outcome_id,22,1,23,1,24,1,25,1,0)) sit,
          MAX(DECODE(rlook.positive_response_flag,'Y',1,0)) presp,
          MAX(DECODE(clook.connect_flag,'Y',1,0)) connects,
          MAX(DECODE(clook.connect_flag,'N',1,0)) nonconnects,
          MAX(DECODE(int.outcome_id,7,0,11,0,2,0,1,0,22,0,23,0,24,0,25,0,26,0,
                     decode(clook.connect_flag,'Y',0,'N',0,1))) others
   INTO   g_contact_count,
          g_noncontact_count,
          g_abandon_count,
          g_busy_count,
          g_rna_count,
          g_ansmc_count,
          g_sit_count,
          g_pr_count,
          g_connect_count,
          g_nonconnect_count,
          g_other_count
   from   jtf_ih_interactions int,
          jtf_ih_activities act,
          bix_dm_connect_lookups clook,
          bix_dm_response_lookups rlook
   where  int.interaction_id = act.interaction_id
   and    int.resource_id = p_resource_id
   and    act.media_id = p_media_id
   AND    int.outcome_id = clook.outcome_id (+)
   --AND    int.outcome_id = rlook.outcome_id (+)
   AND    int.result_id = rlook.result_id (+);

ELSIF p_resource_id IS NULL
THEN

   --Sometimes the resourceid might be valid at interaction level but
   --not at the lifecycle segment.  In this case we need to set dial count
   --to 1 here as it will not be trapped in the EXCEPTION condition in the
   --beginning of this procedure.

   g_dial_count   := 1;

   IF (g_debug_flag = 'Y') THEN
      write_log('p_resourceid is null', g_proc_name);
   END IF;

   SELECT MAX(DECODE(clook.contact_flag,'Y',1,0)) contacts,
          MAX(DECODE(clook.contact_flag,'N',1,0)) noncontacts,
          MAX(DECODE(int.outcome_id,11,1,0)) abandoned,
          MAX(DECODE(int.outcome_id,2,1,0)) busy,
          MAX(DECODE(int.outcome_id,1,1,0)) ring_no_ansewr,
          MAX(DECODE(int.outcome_id,6,1,0)) answering_machine,
          MAX(DECODE(int.outcome_id,22,1,23,1,24,1,25,1,0)) sit,
          MAX(DECODE(rlook.positive_response_flag,'Y',1,0)) presp,
          MAX(DECODE(clook.connect_flag,'Y',1,0)) connects,
          MAX(DECODE(clook.connect_flag,'N',1,0)) nonconnects,
          MAX(DECODE(int.outcome_id,7,0,11,0,2,0,1,0,22,0,23,0,24,0,25,0,26,0,
                     decode(clook.connect_flag,'Y',0,'N',0,1))) others
   INTO   g_contact_count,
          g_noncontact_count,
          g_abandon_count,
          g_busy_count,
          g_rna_count,
          g_ansmc_count,
          g_sit_count,
          g_pr_count,
          g_connect_count,
          g_nonconnect_count,
          g_other_count
   from   jtf_ih_interactions int,
          jtf_ih_activities act,
          bix_dm_connect_lookups clook,
          bix_dm_response_lookups rlook
   where  int.interaction_id = act.interaction_id
   and    act.media_id = p_media_id
   AND    int.outcome_id = clook.outcome_id (+)
   --AND    int.outcome_id = rlook.outcome_id (+)
   AND    int.result_id = rlook.result_id (+);
END IF;

EXCEPTION
WHEN OTHERS
THEN

IF (g_debug_flag = 'Y') THEN
   write_log('Exception occured '||sqlerrm, g_proc_name );
END IF;

  g_dial_count :=0;
  g_contact_count :=0;
  g_noncontact_count :=0;
  g_abandon_count :=0;
  g_busy_count :=0;
  g_rna_count :=0;
  g_ansmc_count :=0;
  g_sit_count :=0;
  g_pr_count :=0;
  g_connect_count :=0;
  g_nonconnect_count :=0;
  g_other_count :=0;

END get_outcome_counts;

--
--Function to calculate the preview time
--

FUNCTION GET_PREVIEW_TIME (p_media_id in number,
                           p_resource_id in number)
RETURN NUMBER IS

l_talk_start_time DATE;
l_int_start_time DATE;
l_int_end_time DATE;
l_preview_time NUMBER := 0;

BEGIN

SELECT min(start_date_time)
INTO   l_talk_start_time
FROM   jtf_ih_media_item_lc_segs
WHERE  media_id = p_media_id
AND    resource_id = p_resource_id;

SELECT min(start_date_time), max(end_date_time)
INTO   l_int_start_time, l_int_end_time
FROM   jtf_ih_interactions int
WHERE  resource_id = p_resource_id
AND
(
  productive_time_amount = p_media_id
  OR EXISTS (SELECT act.interaction_id from jtf_ih_activities act
             WHERE act.media_id = p_media_id
		   AND   act.interaction_id = int.interaction_id
		   )
);

l_preview_time := (least(l_talk_start_time, l_int_end_time) - l_int_start_time)*24*60*60;

return nvl(l_preview_time, 0);

EXCEPTION
WHEN OTHERS THEN
   return 0;

END GET_PREVIEW_TIME;


-- Calculates wrap time:

PROCEDURE GET_WRAP_TIME ( p_resource_id in number,
			 p_media_id in number,
			 p_ag_end_date_time in date,
			 p_direction in varchar2,
			 p_in_wrap_time out NOCOPY number,
			 p_out_wrap_time out NOCOPY number) is

l_wrap_time date;

BEGIN

 l_wrap_time := GET_INTERACTION_END_TIME(p_resource_id, p_media_id);

	 if l_wrap_time is NULL or
            l_wrap_time <= p_ag_end_date_time then
			    p_in_wrap_time := 0;
			    p_out_wrap_time := 0;
	 else
		    if p_direction = 'INBOUND' then
			    p_in_wrap_time := (l_wrap_time - p_ag_end_date_time) * 86400;
			    p_out_wrap_time := 0;
		    else
			    p_in_wrap_time := 0;
			    p_out_wrap_time := (l_wrap_time - p_ag_end_date_time) * 86400;
		    end if;
	 end if;

END;




FUNCTION GET_CLASSIFICATION (
					    p_classification in varchar2,
					    p_date           in date
					    ) return NUMBER is

v_classification_value_id number;

BEGIN

   BEGIN

   --
   --Classification value cannot be duplicated
   --for non-deleted classifications
   --
   select classification_value_id
   into v_classification_value_id
   from cct_classification_values
   where classification_value = p_classification
   and ( f_deletedflag <> 'D'
         or f_deletedflag IS NULL
       )
   and creation_date < p_date;

   return v_classification_value_id;

   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      select max(classification_value_id)
      into v_classification_value_id
      from cct_classification_values
      where classification_value = p_classification
      and f_deletedflag = 'D'
      and creation_date < p_date
	 and last_update_date > p_date;

      return v_classification_value_id;

   END;

EXCEPTION
WHEN OTHERS THEN
   return NULL;

END;


PROCEDURE GET_GOALS (p_classification_value_id in number,
			p_min_call_treshold_goal out NOCOPY number,
			p_sl_seconds_goal out NOCOPY number) is

  v_num_rows_returned number;


BEGIN
select count(*)
into v_num_rows_returned
from bix_dm_goals
WHERE classification_value_id = p_classification_value_id
and end_date_active IS NULL;

	if v_num_rows_returned = 1 then
		SELECT min_call_treshold_goal,sl_seconds_goal into
			p_min_call_treshold_goal, p_sl_seconds_goal
		FROM bix_dm_goals
		WHERE classification_value_id = p_classification_value_id
			and end_date_active IS NULL;
	elsif v_num_rows_returned = 0 then
		SELECT min_call_treshold_goal,sl_seconds_goal into
                        p_min_call_treshold_goal, p_sl_seconds_goal
                FROM bix_dm_goals
                WHERE classification_value_id = -999
                        and end_date_active IS NULL;
	end if;

EXCEPTION
	WHEN OTHERS THEN
		p_min_call_treshold_goal := 0;
		p_sl_seconds_goal := 0;
END;

FUNCTION IS_OTS_INSTALLED return VARCHAR2 is

  v_is_installed varchar2(1);

BEGIN

select application_installed into v_is_installed
from  bix_dm_apps_dependency
where application_short_name = 'BIX_DM_OTS_INSTALLED';

return v_is_installed;

EXCEPTION
	WHEN OTHERS THEN
		return 'N';
END;

FUNCTION IS_OAO_INSTALLED return VARCHAR2 is

  v_is_installed varchar2(1);

BEGIN

select application_installed into v_is_installed
from  bix_dm_apps_dependency
where application_short_name = 'BIX_DM_OAO_INSTALLED';

return v_is_installed;

EXCEPTION
	WHEN OTHERS THEN
		return 'N';
END;

FUNCTION IS_OSR_INSTALLED return VARCHAR2 is

  v_is_installed varchar2(1);

BEGIN

select application_installed into v_is_installed
from  bix_dm_apps_dependency
where application_short_name = 'BIX_DM_OSR_INSTALLED';

return v_is_installed;

EXCEPTION
	WHEN OTHERS THEN
		return 'N';
END;



-- table BIX_DM_CALL_INTERFACE:

PROCEDURE GET_CALLS
AS

 v_classification_value_id number;
 v_calls_in_queue number;
 v_in_calls_handled number;
 v_calls_transferred number;
 v_out_calls_handled number;
 v_in_talk_time number;
 v_in_wrap_time number;
 v_out_talk_time number;
 v_out_wrap_time number;
 v_campaign_id number;
 v_campaign_schedule_id number;
 v_campaign_schedule varchar2(30);
 v_total_in_talk_time number;
 v_total_out_talk_time number;
 v_ivr_time number;
 v_route_time number;
 v_queue_time number;
 v_abandon_time number;
 v_resource_id number;
 l_current_start_date_time date;
 l_current_end_date_time date;
 l_call_answered_by_r_id number;
 l_campaign_code varchar2(10);
 l_counter number;
 l_current_resource_id number;
 l_max_end_date date;
 l_wrap_time number;
 l_with_agent_segs number;
 l_delete_size NUMBER := 0;
 l_source_code varchar2(30);
 l_source_list_id number;
 l_sublist_id number;
 l_dialing_method varchar2(100);
 l_leads_amount number;
 l_opp_amount number;
 v_leads_amount number;
 v_opp_amount number;
 l_leads_amount_txn number;
 l_opp_amount_txn number;
 v_leads_amount_txn number;
 v_opp_amount_txn number;
 l_leads_created number;
 l_leads_updated number;
 l_sr_created number;
 l_sr_opened number;
 l_sr_closed number;
 l_sr_info_req number;
 l_opp_created number;
 l_opp_updated number;
 l_opp_cross_sold number;
 l_opp_up_sold number;
 l_opp_declined number;
 l_opp_won number;
 v_opp_won number;
 l_currency_code varchar2(15);
 l_sr_status number := 0;
 l_activity_counter number := 0;
 l_dnis varchar(30) := NULL;
 l_first_outcome_id number := NULL;
 l_prev_outcome_id number := NULL;
 l_in_cls_hdld_gt_thn_x_tm number := 0;
 l_ou_cls_hdld_gt_thn_x_tm number := 0;
 l_calls_answrd_within_x_time number := 0;
 l_min_call_treshold_goal number := 0;
 l_sl_seconds_goal number := 30;
 l_queue_time_for_calls_handled number := 0;
 l_number_of_rerouts number := 0;

 l_outcome_id NUMBER := NULL;
 l_result_id NUMBER := NULL;
 l_reason_id NUMBER := NULL;
 l_has_agent_segs VARCHAR2(1) := 'N';

 l_agent_preview_time NUMBER := 0;
 l_call_preview_time NUMBER := 0;

 CURSOR call_info IS
 SELECT ih_mitem.media_id MEDIA_ID,
	nvl(ih_mitem.server_group_id, -1) SERVER_GROUP_ID,
        CLASSIFICATION CLASSIFICATION,
        ih_mitem.dnis DNIS,
        ih_mitem.direction DIRECTION,
        TRUNC(ih_mitem.start_date_time) PERIOD_START_DATE,
        LPAD(TO_CHAR(ih_mitem.start_date_time,'HH24:'),3,'0')|| DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_mitem.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00') PERIOD_START_TIME,
	TO_DATE(TO_CHAR(ih_mitem.start_date_time,'YYYY/MM/DD ')||LPAD(TO_CHAR(ih_mitem.start_date_time,'HH24:'),3,'0') || DECODE(SIGN(TO_NUMBER(TO_CHAR(ih_mitem.start_date_time,'MI'))-29),0,'00',1,'30',-1,'00'),'YYYY/MM/DD HH24:MI') PERIOD_START_DATE_TIME,
        DECODE(UPPER(ih_mitem.direction),'INBOUND',1,0) CALLS_OFFERED,
	DECODE(UPPER(ih_mitem.direction),'INBOUND',DECODE(UPPER(ih_mitem.media_abandon_flag),'Y',1,0),0) CALLS_ABANDONED ,
        ih_mitem.media_abandon_flag MEDIA_ABANDON_FLAG ,
        ih_mitem.source_item_id SOURCE_ITEM_ID,
	   ih_mitem.start_date_time CALL_START_TIME
   FROM      JTF_IH_MEDIA_ITEMS ih_mitem
 WHERE  ih_mitem.start_date_time BETWEEN g_min_call_begin_date AND g_max_call_begin_date
 AND
 (
 ih_mitem.media_item_type = 'TELE_INB' or
 ih_mitem.media_item_type = 'TELE_DIRECT' or
 ih_mitem.media_item_type = 'TELEPHONE' or
 ih_mitem.media_item_type = 'CALL' or
 ih_mitem.media_item_type = 'TELE_MANUAL' or
 ih_mitem.media_item_type = 'TELE_WEB'
 )
 AND    ih_mitem.active = 'N' ;

 CURSOR agent_info (p_media_id NUMBER) is
        select msegs.resource_id RESOURCE_ID,
               mtyps.milcs_code MEDIA_TYPE,
               msegs.duration DURATION,
               msegs.start_date_time START_DATE_TIME,
               msegs.end_date_time END_DATE_TIME
        from
               JTF_IH_MEDIA_ITEM_LC_SEGS msegs,
               JTF_IH_MEDIA_ITM_LC_SEG_TYS mtyps
        where
               msegs.media_id = p_media_id and
               msegs.MILCS_TYPE_ID = mtyps.MILCS_TYPE_ID and
               msegs.resource_id is not null
        order by
	       msegs.resource_id,
               msegs.start_date_time;

 /**Change on 20-Mar-2002:
    Outcomes will be retrieved at interaction level not activities.
    Also, depending on whether it is a service request or lead etc
    change the join conditions.  This is because right now, leads and
    opportunities are using the mdeia_id on jtf_ih_activities table.
    So we can join with this.
    However for service requests, the media_id of jtf_ih_activities
    is populated only for the "CALL ANSWERED" activity.  For other actvities
    media_id is null on activites table.  The productive_time_amount
    column of jtf_ih_interactions is populated with the media_id.

 ***/

 CURSOR activity_info (p_media_id NUMBER, p_resource_id NUMBER) is
        select a.outcome_id OUTCOME_ID,
               a.action_id ACTION_ID,
               a.action_item_id ACTION_ITEM_ID,
               a.doc_ref DOC_REF,
               a.doc_id DOC_ID,
               a.start_date_time ACT_START_TIME
        from
            jtf_ih_activities a,
            jtf_ih_interactions b
        where
	    (
                a.media_id = p_media_id
             OR b.productive_time_amount = p_media_id
            ) and
            b.resource_id = p_resource_id and
            a.interaction_id = b.interaction_id
        order by b.outcome_id;

  /*
   *Right now the outcome_id from above will not be used for
   *outbounbd calls.
   *Outcome_info has the outcome result reason combinations
   *for a media_id-resource_id combination.
   *Since we are going for the outcome result reason at the interaction
   *level we will always insert these fields in the first activity row.
   *IF there are one or more WITH_AGENT segments.
   *If there are no WITH_AGENT segments then write it at the CALL
   *row.  this can happen for example for outbound calls which were
   *predictive dialed but never reached an agent.  We still need to
   *track the outcome for these calls.
  */

BEGIN

 v_classification_value_id := NULL;
 v_calls_in_queue := 0;
 v_in_calls_handled := 0;
 v_calls_transferred := 0;
 v_out_calls_handled := 0;
 v_in_talk_time := 0;
 v_in_wrap_time := 0;
 v_out_talk_time := 0;
 v_out_wrap_time := 0;
 v_campaign_id := NULL;
 v_campaign_schedule_id := NULL;
 v_campaign_schedule := NULL;
 v_total_in_talk_time := 0;
 v_total_out_talk_time := 0;
 v_ivr_time := 0;
 v_route_time := 0;
 v_queue_time := 0;
 v_abandon_time := 0;
 v_resource_id := NULL;
 l_current_start_date_time := NULL;
 l_current_end_date_time := NULL;
 l_call_answered_by_r_id := 0;
 l_campaign_code := 0;
 l_counter := 0;
 l_current_resource_id := 0;
 l_max_end_date := NULL;
 l_wrap_time := 0;
 l_source_list_id := NULL;
 l_sublist_id := NULL;
 l_leads_amount := 0;
 l_opp_amount := 0;
 v_leads_amount := 0;
 v_opp_amount := 0;
 l_leads_amount_txn := 0;
 l_opp_amount_txn := 0;
 v_leads_amount_txn := 0;
 v_opp_amount_txn := 0;
 l_leads_created := 0;
 l_leads_updated := 0;
 l_sr_created := 0;
 l_sr_opened := 0;
 l_sr_closed := 0;
 l_opp_created := 0;
 l_opp_updated := 0;
 l_opp_won := 0;
 v_opp_won := 0;
 l_currency_code := NULL;
 l_activity_counter := 0;
 l_sr_info_req := 0;
 l_opp_cross_sold := 0;
 l_opp_up_sold := 0;
 l_opp_cross_sold := 0;
 g_insert_count := 0;
 g_delete_count := 0;
 l_agent_preview_time := 0;
 l_call_preview_time := 0;


-- IGOR : initialize and check for 'no rows returned'

 --DELETE_IN_CHUNKS('BIX_DM_INTERFACE',NULL,g_delete_count);

 --
 --Change delete to truncate to avoid performance issue
 --with high water mark.
 --

 EXECUTE IMMEDIATE 'TRUNCATE TABLE '||g_bix_schema||'.BIX_DM_INTERFACE';

   -- DEBUG: dbms_output.put_line('started  collecting calls');
   --Added filter to include only call medias in following query
   --

   SELECT MIN(start_date_time),MAX(start_date_time)
   INTO   g_min_call_begin_date,g_max_call_begin_date
   FROM   jtf_ih_media_items
   WHERE  last_update_date BETWEEN g_collect_start_date AND g_collect_end_date
   AND
   (
   media_item_type = 'TELE_INB' or
   media_item_type = 'TELE_DIRECT' or
   media_item_type = 'TELEPHONE' or
   media_item_type = 'CALL' or
   media_item_type = 'TELE_MANUAL' or
   media_item_type = 'TELE_WEB'
    );


/* Round the Min begin date to nearest lower time bucket. ex: if time is between 10:00 and 10:29
   round it to 10:00.
*/

SELECT TO_DATE(
	TO_CHAR(g_min_call_begin_date,'YYYY/MM/DD')||
	LPAD(TO_CHAR(g_min_call_begin_date,'HH24:'),3,'0')||
	DECODE(SIGN(TO_NUMBER(TO_CHAR(g_min_call_begin_date,'MI'))-29),0,'00:00',1,'30:00',-1,'00:00'),
	'YYYY/MM/DDHH24:MI:SS')
INTO g_min_call_begin_date
FROM DUAL;


/* Round the Max begin date to nearest higher time bucket. ex: if time is between 10:00 and 10:29
   round it to 10:29:59
*/

SELECT TO_DATE(
	TO_CHAR(g_max_call_begin_date,'YYYY/MM/DD')||
	LPAD(TO_CHAR(g_max_call_begin_date,'HH24:'),3,'0')||
	DECODE(SIGN(TO_NUMBER(TO_CHAR(g_max_call_begin_date,'MI'))-29),0,'29:59',1,'59:59',-1,'29:59'),
	'YYYY/MM/DDHH24:MI:SS')
INTO g_max_call_begin_date
FROM DUAL;


BEGIN

select resource_id
into g_ao_dummy_resource
from jtf_rs_resource_extns
where user_name = 'IECAOUSER';

EXCEPTION
WHEN OTHERS THEN
g_ao_dummy_resource := NULL;

END;


   -- DEBUG: dbms_output.put_line('before the call loop');

      	FOR call in call_info LOOP

                 if call.dnis is not null then
				l_dnis := get_dnis(call.dnis);
                 else
				l_dnis := NULL;
                 end if;

   -- DEBUG: dbms_output.put_line('in the call loop');

-- get the ivr_time, route_time, queue_time and abandon_time from the call
-- segments with the appropriate media_id

		select
			SUM(DECODE(UPPER(call.direction),'INBOUND',DECODE(ih_milcs_ty.milcs_code,'IVR',NVL(ih_milcs.duration,0),0),0)) IVR_TIME,
			SUM(DECODE(UPPER(call.direction),'INBOUND',DECODE(ih_milcs_ty.milcs_code,'ROUTING',NVL(ih_milcs.duration,0),0),0)) ROUTE_TIME,
			SUM(DECODE(UPPER(call.direction),'INBOUND',DECODE(ih_milcs_ty.milcs_code,'IN_QUEUE',NVL(ih_milcs.duration,0),0),0)) QUEUE_TIME,
			SUM(DECODE(UPPER(call.direction),'INBOUND',DECODE(UPPER(call.media_abandon_flag),'Y',DECODE(ih_milcs_ty.milcs_code,'IN_QUEUE',NVL(ih_milcs.duration,0),0),0),0)) ABANDON_TIME,
                        SUM(DECODE(ih_milcs_ty.milcs_code,'WITH_AGENT',1,0)),
                        SUM(DECODE(ih_milcs_ty.milcs_code,'ROUTING',1,0))
	       into
			 v_ivr_time ,
			 v_route_time ,
			 v_queue_time ,
			 v_abandon_time ,
			 l_with_agent_segs,
			 l_number_of_rerouts
	       from
		       JTF_IH_MEDIA_ITEM_LC_SEGS ih_milcs,
		       JTF_IH_MEDIA_ITM_LC_SEG_TYS ih_milcs_ty
	       where
		       ih_milcs.media_id = call.media_id and
		       ih_milcs.MILCS_TYPE_ID = ih_milcs_ty.MILCS_TYPE_ID ;

--
--Fix for bug 2611727.  Reduce it by 1 so that it will be
--considered as a re-route only if it has more than one ROUTING
--segments
--

IF l_number_of_rerouts > 0
THEN
   l_number_of_rerouts := l_number_of_rerouts -1;
END IF;

-- if there are 'WITH_AGENT' segments then:

   -- DEBUG: dbms_output.put_line('in outer loop after first query');




             if v_queue_time > 0 then
		       v_calls_in_queue := 1;
             else
		       v_calls_in_queue := 0;
	     end if;

	     if call.source_item_id is not NULL AND call.direction = 'OUTBOUND' THEN
		   GET_LIST_INFO
				 (call.source_item_id,
                      v_campaign_id,
                      v_campaign_schedule_id,
		  		  l_source_list_id,
				  l_sublist_id,
				  l_dialing_method);
             else
                 l_source_code := get_source_code(call.media_id);
                 GET_CAMPAIGN_INFO(l_source_code,
                                        v_campaign_id,
                                        v_campaign_schedule_id);
	     end if;

	     if call.classification is not NULL then
			v_classification_value_id := GET_CLASSIFICATION(
										call.classification,
										call.call_start_time
												  );

	     end if;

	     GET_GOALS(v_classification_value_id,
		l_min_call_treshold_goal,
		l_sl_seconds_goal);


		-- start with agent stuff
		-- get agent info only if there are agent segments:
		if l_with_agent_segs > 0 then

		     select min(resource_id) into l_call_answered_by_r_id
			    from JTF_IH_MEDIA_ITEM_LC_SEGS
			    where JTF_IH_MEDIA_ITEM_LC_SEGS.media_id =
                                  call.media_id
                   and resource_id is not null
			    and start_date_time =
			    (select min(msegs.start_date_time) from
			     JTF_IH_MEDIA_ITEM_LC_SEGS msegs,
			     JTF_IH_MEDIA_ITM_LC_SEG_TYS mtyps
			     where
			     msegs.media_id = call.media_id and
			     msegs.MILCS_TYPE_ID = mtyps.MILCS_TYPE_ID and
			     mtyps.milcs_code = 'WITH_AGENT'
			     );


		l_counter := 1;

		FOR agent in agent_info(call.media_id) LOOP
   -- DEBUG: dbms_output.put_line('in agent loop');

                --
                --Assign l_has_agent_segs to Y
                --This is used while calculating the outcome/result/reason values
                --This will also be used to find out if we need to fill in the
                --call type row in the interface table with the measures.
                --If there are with agent segments then these will be added up
                --to form the values in BIX_DM_CALL_SUM else these will have to
                --be populated manually at the call type row.
                --ALso, if there are with agent segments then do not fill in the
                --measures at the call level as otherwise it will result in
                --double counting.
                --

                   l_has_agent_segs := 'Y';


			if l_counter = 1 then
			-- initialize:
				l_current_resource_id := agent.resource_id;
				v_resource_id := agent.resource_id;
				l_current_end_date_time := agent.end_date_time;
			   if call.direction = 'INBOUND' then
                                   v_in_talk_time := (agent.end_date_time -
                                         agent.start_date_time) * 24 * 3600;
                                   v_total_in_talk_time := (agent.end_date_time
                                         - agent.start_date_time) * 24 * 3600;
			   elsif call.direction = 'OUTBOUND' then
                                   v_out_talk_time := (agent.end_date_time -
                                         agent.start_date_time) * 24 * 3600;
                                   v_total_out_talk_time :=
                                         (agent.end_date_time -
                                         agent.start_date_time) * 24 * 3600;
			   end if;
			end if;

		if agent.resource_id <> l_current_resource_id then

   -- DEBUG: dbms_output.put_line('in agent loop, inserting agent record');
-- if we have completed calculations for one agent (i.e. retrieved
-- agent is different from current agent then first calculate the wrap time and
-- then complete with INSERT and CLEANUP for the previous agent:

                --
                --Get all the outcome counts
                --
                IF call.direction = 'OUTBOUND'
                THEN
                   get_outcome_counts(call.media_id, l_current_resource_id);
			    IF g_interaction_resource IS NULL
			    THEN
				  --
				  --Probably a TELE_MANUAL call with no interaction
				  --Fix for bug 3062185
				  --
				  IF l_current_resource_id = l_call_answered_by_r_id
				  THEN
					g_dial_count := 1;
                      ELSE
					g_dial_count :=0;
                      END IF;
                   END IF;
                END IF;

                --
                --Preview time
                --
			 IF l_dialing_method = 'PREV'
			 THEN
                   l_agent_preview_time := GET_PREVIEW_TIME(call.media_id, l_current_resource_id);
                   l_call_preview_time := l_call_preview_time + l_agent_preview_time;
                ELSE
			    l_agent_preview_time :=0;
			    l_call_preview_time:=0;
                END IF;

                --
                -- Wrap Time:
                --

			GET_WRAP_TIME ( l_current_resource_id,
					call.media_id,
					l_current_end_date_time,
					call.direction,
					v_in_wrap_time,
					v_out_wrap_time);



	 l_activity_counter := 1;
         l_outcome_id := NULL;
         l_result_id  := NULL;
         l_reason_id  := NULL;

IF (g_debug_flag = 'Y') THEN
   write_log('About to enter the activity cursor ', g_proc_name);
   write_log('Media id is '||call.media_id || ' l_activitycounter is ' || l_activity_counter || ' l_resource id is ' || l_current_resource_id, g_proc_name);
END IF;

       FOR activity in activity_info(call.media_id,l_current_resource_id) LOOP

-- IGOR: continue from here:

/*
 * Retrieve the outcome, result and reason here.
 *Right now applies only to outbound calls.
*/

IF (g_debug_flag = 'Y') THEN
   write_log('Inside  activity cursor loop ', g_proc_name);
   write_log('Media id is '||call.media_id || ' l_activitycounter is ' || l_activity_counter || ' l_resource id is ' || l_current_resource_id, g_proc_name);
END IF;

IF call.direction = 'OUTBOUND' AND l_activity_counter = 1
THEN
   BEGIN
      SELECT DISTINCT int.outcome_id,
                      int.result_id,
                      int.reason_id
      INTO   l_outcome_id, l_result_id, l_reason_id
      from   jtf_ih_interactions int,
             jtf_ih_activities act
      where  int.interaction_id = act.interaction_id
      and    int.resource_id = l_current_resource_id
      and    act.media_id = call.media_id;

IF (g_debug_flag = 'Y') THEN
   write_log('Retrieved outcome id '|| l_outcome_id ||' resultid ' ||l_result_id || ' reason id ' || l_reason_id, g_proc_name);
END IF;

   EXCEPTION
   WHEN OTHERS
   THEN
      l_outcome_id := NULL;
      l_result_id  := NULL;
      l_reason_id  := NULL;

      IF (g_debug_flag = 'Y') THEN
         write_log('Exception while getting outcome id '|| l_outcome_id ||' resultid ' ||l_result_id || ' reason id ' || l_reason_id, g_proc_name);
      END IF;

   END;
ELSE

  IF (g_debug_flag = 'Y') THEN
    write_log('Else condition while getting outcome id '|| l_outcome_id ||' resultid ' ||l_result_id || ' reason id ' || l_reason_id, g_proc_name);
  END IF;

END IF;

/***
   Change 20-Mar-2002:
   Action id values are:
   1 = Add, 6=Update, 7=Upsell, 8=Xsell, 13=SR Created
   14= SR Updated, 27=Close opportunity

   Action Item Id values are:
   8=Lead, 17=SR, 21=Opportunity, 22=Sales Lead
***/

/****Action id of 1 means added/created ****/
          if activity.action_id = 1 then -- item added/created
             if activity.action_item_id = 22   -- Sales lead
                OR activity.action_item_id = 8 -- Lead
             then
                l_leads_created := l_leads_created + 1;
				if activity.doc_ref = 'LEAD' or
				   activity.doc_ref = 'ASTSC_LEAD' then
					get_lead_amount( activity.doc_id,
                                                         l_current_resource_id,
                                                         activity.act_start_time,
							 l_leads_amount,
							 l_currency_code);
					v_leads_amount := v_leads_amount +  l_leads_amount;
				end if;
             elsif activity.action_item_id = 21 then  -- Opportunity
				l_opp_created := l_opp_created + 1;
				if activity.doc_ref = 'OPPORTUNITY' or
				   activity.doc_ref = 'ASTSC_OPP' then
					get_opportunity_amount( activity.doc_id,
                                                 l_current_resource_id,
                                                 activity.act_start_time,
						 l_opp_won,
						 l_opp_amount,
						 l_currency_code);
					v_opp_amount := v_opp_amount +  l_opp_amount;
					v_opp_won := v_opp_won + l_opp_won;
				 end if;
	     elsif activity.action_item_id = 17 then  -- Service Request
				l_sr_created := l_sr_created + 1;
				l_sr_opened := l_sr_opened + 1;
			   end if;
          end if;

/****Action id of 6 means updated ****/
--
--Change for bug 2298527:  Amounts will be not be calculated
--if the agent updates the lead or opportunity. Amounts are given
--to the agent who created the lead or opportunity. For cross-sold
--and up-sold etc, the amounts are calculated
--

          if activity.action_id = 6 then -- item updated
             if activity.action_item_id = 22   -- Sales lead
                OR activity.action_item_id = 8 -- Lead
             then
                l_leads_updated := l_leads_updated + 1;
                --if activity.doc_ref = 'LEAD' or
                   --activity.doc_ref = 'ASTSC_LEAD' then
                   --get_lead_amount( activity.doc_id,
                   --l_current_resource_id,
                   --activity.act_start_time,
                   --l_leads_amount,
                   --l_currency_code);
                   --v_leads_amount := v_leads_amount +  l_leads_amount;
                --end if;
             elsif activity.action_item_id = 21  -- Opportunity
             then
                l_opp_updated := l_opp_updated + 1;
                --if activity.doc_ref = 'OPPORTUNITY' or
                   --activity.doc_ref = 'ASTSC_OPP' then
                        --get_opportunity_amount( activity.doc_id,
                                         --l_current_resource_id,
                                         --activity.act_start_time,
                                         --l_opp_won,
                                         --l_opp_amount,
                                         --l_currency_code);
                        --v_opp_amount := v_opp_amount +  l_opp_amount;
                        --v_opp_won := v_opp_won + l_opp_won;
	        --end if;
             elsif activity.action_item_id = 17  -- Service request
             then
                get_sr_status (activity.doc_id,l_current_resource_id,activity.act_start_time,l_sr_status);
		if l_sr_status = 1 or l_sr_status = 3 then
			l_sr_opened := l_sr_opened + 1;
		elsif l_sr_status = 2 or l_sr_status = 4 then
			l_sr_closed := l_sr_closed + 1;
		end if;
             end if;
          end if;

/**** Service request specific action id value ****/
          if activity.action_id = 13 then -- sr created specific code
                l_sr_created := l_sr_created + 1;
                l_sr_opened := l_sr_opened + 1;
          end if;

          if activity.action_id = 14 then -- sr updated, specific code
                get_sr_status (activity.doc_id,l_current_resource_id,activity.act_start_time,l_sr_status);
                if l_sr_status = 1 or l_sr_status = 3 then
                        l_sr_opened := l_sr_opened + 1;
                elsif l_sr_status = 2 or l_sr_status = 4 then
                        l_sr_closed := l_sr_closed + 1;
                end if;
          end if;

/*** Other action id values ***/
          if activity.action_id = 3 then -- info requested
		if activity.action_item_id = 17 then -- service request
			l_sr_info_req := l_sr_info_req + 1;
		end if;
	  elsif activity.action_id = 8 then -- cross sold
		if activity.action_item_id = 21 then
		    get_opportunity_amount( activity.doc_id,
                                                 l_current_resource_id,
                                                 activity.act_start_time,
						 l_opp_won,
						 l_opp_amount,
						 l_currency_code);
		    v_opp_amount := v_opp_amount +  l_opp_amount;
			l_opp_cross_sold := l_opp_cross_sold + 1;
		end if;
	  elsif activity.action_id = 7 then -- up sold
		if activity.action_item_id = 21 then
		    get_opportunity_amount( activity.doc_id,
                                                 l_current_resource_id,
                                                 activity.act_start_time,
						 l_opp_won,
						 l_opp_amount,
						 l_currency_code);
		    v_opp_amount := v_opp_amount +  l_opp_amount;
			l_opp_up_sold := l_opp_up_sold + 1;
		end if;
	  elsif activity.action_id = 26 then -- declined
		if activity.action_item_id = 21 then
			l_opp_declined := l_opp_declined + 1;
		end if;
	  end if;


	if l_activity_counter > 1 then
-- insert activity row - continue here
			insert into bix_dm_interface
                        (
                        MEDIA_ID,
			RESOURCE_ID,
			--CLASSIFICATION_ID,
			CLASSIFICATION_VALUE_ID,
			SERVER_GROUP_ID,
			DNIS,
			--OUTCOME_ID,
			CURRENCY_CODE,
			PERIOD_START_DATE,
			PERIOD_START_TIME,
			PERIOD_START_DATE_TIME,
			CALLS_OFFERED,
			CALLS_IN_QUEUE,
			IN_CALLS_HANDLED,
			CALLS_TRANSFERED,
			CALLS_ABANDONED,
			OUT_CALLS_HANDLED,
			IVR_TIME,
			ROUTE_TIME,
			QUEUE_TIME,
			IN_TALK_TIME,
			IN_WRAP_TIME,
			ABANDON_TIME,
			OUT_TALK_TIME,
			OUT_WRAP_TIME,
			CAMPAIGN_ID,
			CAMPAIGN_SCHEDULE_ID,
                        SOURCE_LIST_ID,
                        SUBLIST_ID,
                        DIRECTION,
                        SERVICE_REQUESTS_CREATED,
			SERVICE_REQUESTS_OPENED,
			SERVICE_REQUESTS_CLOSED,
			LEADS_CREATED,
			LEADS_UPDATED,
			OPPORTUNITIES_CREATED,
			OPPORTUNITIES_UPDATED,
			OPPORTUNITIES_WON,
			LEADS_AMOUNT,
			OPPORTUNITIES_WON_AMOUNT,
			LEADS_AMOUNT_TXN,
			OPPORTUNITIES_WON_AMOUNT_TXN,
			OUT_CALLS_HANDLD_GT_THN_X_TIME,
			IN_CALLS_HANDLD_GT_THN_X_TIME,
			CALLS_ANSWRD_WITHIN_X_TIME,
			ROW_TYPE,
			QUEUE_TIME_FOR_CALLS_HANDLED,
                        OUTCOME_ID,
                        RESULT_ID,
                        REASON_ID
                        )
                        values
                        (
			call.media_id,
		        l_current_resource_id,
			v_classification_value_id,
			call.server_group_id,
			l_dnis,
--decode(activity.outcome_id,l_prev_outcome_id,NULL,activity.outcome_id),
			NULL,
			call.PERIOD_START_DATE,
			call.PERIOD_START_TIME,
			call.PERIOD_START_DATE_TIME,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			v_campaign_id,
			v_campaign_schedule_id,
                        l_source_list_id,
                        l_sublist_id,
                        decode(call.direction,'OUTBOUND',1,2),
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
			'T',
                        0,
                        l_outcome_id,
                        l_result_id,
                        l_reason_id
                        );

                        --IF activity.outcome_id IS NOT NULL
                        --THEN
                           --l_prev_outcome_id := activity.outcome_id;
                        --END IF;

			commit;
        g_insert_count := g_insert_count + 1;

        elsif l_activity_counter = 1 then
		l_first_outcome_id := activity.outcome_id;
	end if;

	 l_activity_counter := l_activity_counter + 1;

        END LOOP; -- end activity loop 1

		   -- IGOR: INSERT...   agent row:

			insert into bix_dm_interface
                        (
                        MEDIA_ID,
			RESOURCE_ID,
			--CLASSIFICATION_ID,
			CLASSIFICATION_VALUE_ID,
			SERVER_GROUP_ID,
			DNIS,
			CURRENCY_CODE,
			PERIOD_START_DATE,
			PERIOD_START_TIME,
			PERIOD_START_DATE_TIME,
			CALLS_OFFERED,
			CALLS_IN_QUEUE,
			IN_CALLS_HANDLED,
			CALLS_TRANSFERED,
			CALLS_ABANDONED,
			OUT_CALLS_HANDLED,
			IVR_TIME,
			ROUTE_TIME,
			QUEUE_TIME,
			IN_TALK_TIME,
			IN_WRAP_TIME,
			ABANDON_TIME,
			OUT_TALK_TIME,
			OUT_WRAP_TIME,
			CAMPAIGN_ID,
			CAMPAIGN_SCHEDULE_ID,
			--OUTCOME_ID,
                        SOURCE_LIST_ID,
                        SUBLIST_ID,
                        DIRECTION,
                        SERVICE_REQUESTS_CREATED,
			SERVICE_REQUESTS_OPENED,
			SERVICE_REQUESTS_CLOSED,
			LEADS_CREATED,
			LEADS_UPDATED,
			OPPORTUNITIES_CREATED,
			OPPORTUNITIES_UPDATED,
			OPPORTUNITIES_WON,
			LEADS_AMOUNT,
			OPPORTUNITIES_WON_AMOUNT,
			LEADS_AMOUNT_TXN,
			OPPORTUNITIES_WON_AMOUNT_TXN,
			OUT_CALLS_HANDLD_GT_THN_X_TIME,
			IN_CALLS_HANDLD_GT_THN_X_TIME,
			CALLS_ANSWRD_WITHIN_X_TIME,
			ROW_TYPE,
			QUEUE_TIME_FOR_CALLS_HANDLED ,
                        OUT_CALLS_DIALED,
                        OUT_CONTACT_COUNT,
                        OUT_NON_CONTACT_COUNT,
                        OUT_ABANDON_COUNT,
                        OUT_BUSY_COUNT ,
                        OUT_RING_NOANSWER_COUNT,
                        OUT_ANS_MC_COUNT ,
                        OUT_SIT_COUNT,
                        OUT_POSITIVE_RESPONSE_COUNT,
                        OUT_CONNECT_COUNT ,
                        OUT_NON_CONNECT_COUNT ,
                        OUT_OTHER_OUTCOME_COUNT,
                        OUT_PREVIEW_TIME,
                        OUT_CONTACT_HANDLE_TIME,
                        OUTCOME_ID,
                        RESULT_ID,
                        REASON_ID
                        )
                        values
                        (
			call.media_id,
		        l_current_resource_id,
			--v_classification_id,
			v_classification_value_id,
			call.server_group_id,
			l_dnis,
			l_currency_code,
			call.PERIOD_START_DATE,
			call.PERIOD_START_TIME,
			call.PERIOD_START_DATE_TIME,
			0,
			0,
			v_in_calls_handled,
			v_calls_transferred,
			0,
			v_out_calls_handled,
			0,
			0,
			0,
			v_in_talk_time,
			v_in_wrap_time,
			0,
			v_out_talk_time,
			v_out_wrap_time,
			v_campaign_id,
			v_campaign_schedule_id,
			--l_first_outcome_id,
                        l_source_list_id,
                        l_sublist_id,
                        decode(call.direction,'OUTBOUND',1,'INBOUND',2),
                        l_sr_created,
                        l_sr_opened,
                        l_sr_closed,
                        l_leads_created,
                        l_leads_updated,
                        l_opp_created,
                        l_opp_updated,
                        v_opp_won,
                        decode(l_currency_code,g_preferred_currency,v_leads_amount,null,v_leads_amount,gl_currency_api.convert_amount_sql(l_currency_code,g_preferred_currency,call.PERIOD_START_DATE_TIME,g_conversion_type,v_leads_amount)),
                        decode(l_currency_code,g_preferred_currency,v_opp_amount,null,v_opp_amount,gl_currency_api.convert_amount_sql(l_currency_code,g_preferred_currency,call.PERIOD_START_DATE_TIME,g_conversion_type,v_opp_amount)),
                        v_leads_amount,
                        v_opp_amount,
                        l_ou_cls_hdld_gt_thn_x_tm,
                        l_in_cls_hdld_gt_thn_x_tm,
                        l_calls_answrd_within_x_time,
                        'A',
			l_queue_time_for_calls_handled ,
                        g_dial_count,
                        g_contact_count,
                        g_noncontact_count,
                        g_abandon_count,
                        g_busy_count,
                        g_rna_count,
                        g_ansmc_count,
                        g_sit_count,
                        g_pr_count,
                        g_connect_count,
                        g_nonconnect_count,
                        g_other_count,
                        nvl(l_agent_preview_time,0),
                        nvl
				    (decode(g_contact_count,0,0,NULL,0,
				       nvl(v_out_talk_time,0) +
				       nvl(v_out_wrap_time,0) +
				       nvl(l_agent_preview_time,0)
				        ),0
				     ),
                        l_outcome_id,
                        l_result_id,
                        l_reason_id
                        );

                        --IF l_first_outcome_id IS NOT NULL
                        --THEN
                           --l_prev_outcome_id := l_first_outcome_id;
                        --END IF;

			commit;
			g_insert_count := g_insert_count + 1;

                   -- IGOR: agent CLEANUP ...
			v_in_talk_time := 0;
			v_out_talk_time := 0;
			l_current_resource_id := agent.resource_id;
			l_current_end_date_time := agent.start_date_time;

-- IGOR: agent cleanup

			 l_leads_amount := 0;
			 l_opp_amount := 0;
			 l_leads_amount_txn := 0;
			 l_opp_amount_txn := 0;
			 v_leads_amount := 0;
			 v_opp_amount := 0;
			 v_leads_amount_txn := 0;
			 v_opp_amount_txn := 0;
			 l_leads_created := 0;
			 l_leads_updated := 0;
			 l_sr_created := 0;
			 l_sr_opened := 0;
			 l_sr_closed := 0;
			 l_opp_created := 0;
			 l_opp_updated := 0;
			 l_opp_won := 0;
			 v_opp_won := 0;
			 l_activity_counter := 0;
			 l_currency_code := NULL;
			 l_first_outcome_id := NULL;
			 l_sr_info_req := 0;
			 l_opp_cross_sold := 0;
			 l_opp_up_sold := 0;
			 l_opp_cross_sold := 0;
                         l_ou_cls_hdld_gt_thn_x_tm := 0;
                         l_in_cls_hdld_gt_thn_x_tm := 0;
                         l_calls_answrd_within_x_time := 0;
			 l_queue_time_for_calls_handled := 0;
                         l_agent_preview_time := 0;

		end if;




			if agent.start_date_time >= l_current_end_date_time then
   -- DEBUG: dbms_output.put_line('in agent loop, no overlapping '||'agent '||to_char(l_current_resource_id)||' in_talk_time: '||to_char(v_in_talk_time)||'total talk time '||to_char(v_total_in_talk_time) );

				if call.direction = 'INBOUND' then
                                   v_in_talk_time := v_in_talk_time +
                                          (agent.end_date_time -
                                         agent.start_date_time) * 24 * 3600;
                                   v_total_in_talk_time := v_total_in_talk_time
                                         + (agent.end_date_time
                                         - agent.start_date_time) * 24 * 3600;
                                 elsif call.direction = 'OUTBOUND' then
                                   v_out_talk_time := v_out_talk_time +
                                         (agent.end_date_time -
                                         agent.start_date_time) * 24 * 3600;
                                   v_total_out_talk_time :=
                                          v_total_out_talk_time +
                                         (agent.end_date_time -
                                         agent.start_date_time) * 24 * 3600;
                                 end if;
                         else
   -- DEBUG: dbms_output.put_line('in agent loop, overlapping '||'agent '||to_char(l_current_resource_id)||' in_talk_time: '||to_char(v_in_talk_time)||'total talk time '||to_char(v_total_in_talk_time) );

				if call.direction = 'INBOUND' then
                                   v_in_talk_time := v_in_talk_time +
                                          (agent.end_date_time -
                                         l_current_end_date_time) * 24 * 3600;
                                   v_total_in_talk_time := v_total_in_talk_time
                                         + (agent.end_date_time
                                         - l_current_end_date_time) * 24 * 3600;
                                 elsif call.direction = 'OUTBOUND' then
                                   v_out_talk_time := v_out_talk_time +
                                         (agent.end_date_time -
                                         l_current_end_date_time) * 24 * 3600;
                                   v_total_out_talk_time :=
                                          v_total_out_talk_time +
                                         (agent.end_date_time -
                                         l_current_end_date_time) * 24 * 3600;
                                 end if;

                         end if;

			 l_current_end_date_time := agent.end_date_time;

			if agent.resource_id = l_call_answered_by_r_id
                           and call.direction = 'INBOUND'
                        then
				v_in_calls_handled := 1;
				v_out_calls_handled := 0;
				v_calls_transferred := 0;
				if v_in_talk_time >= l_min_call_treshold_goal then
					l_in_cls_hdld_gt_thn_x_tm := 1;
				else
					l_in_cls_hdld_gt_thn_x_tm := 0;
				end if;
				--if (v_ivr_time + v_route_time + v_queue_time) <=
				if v_queue_time <=
					l_sl_seconds_goal then
					-- dbms_output.put_line('answ time:'||to_char(v_ivr_time + v_route_time + v_queue_time)||' goal:'||to_char(l_sl_seconds_goal));
					l_calls_answrd_within_x_time	:= 1;
				else
					l_calls_answrd_within_x_time	:= 0;
				end if;
				l_queue_time_for_calls_handled := v_queue_time;
				-- dbms_output.put_line('call handled. ivr_time='||to_char(v_ivr_time)||' route_time='||to_char(v_route_time)||' queue_time='||to_char(v_queue_time)||' target='||to_char(l_sl_seconds_goal));
			elsif agent.resource_id = l_call_answered_by_r_id
                           and call.direction = 'OUTBOUND' then
				v_in_calls_handled := 0;
				v_out_calls_handled := 1;
				v_calls_transferred := 0;
				if v_out_talk_time >= l_min_call_treshold_goal then
					l_ou_cls_hdld_gt_thn_x_tm := 1;
				else
					l_ou_cls_hdld_gt_thn_x_tm := 0;
				end if;
                        else
				v_in_calls_handled := 0;
				v_out_calls_handled := 0;
				v_calls_transferred := 1;
			end if;





			l_counter := l_counter +1;
		END LOOP;
		-- end agent loop

               -- wrap time for last agent row:

		GET_WRAP_TIME ( l_current_resource_id,
				call.media_id,
				l_current_end_date_time,
				call.direction,
				v_in_wrap_time,
				v_out_wrap_time);


                --
                --Preview time for the last agent row
                --
			 IF l_dialing_method = 'PREV'
			 THEN
                   l_agent_preview_time := GET_PREVIEW_TIME(call.media_id, l_current_resource_id);
                   l_call_preview_time := l_call_preview_time + l_agent_preview_time;
                ELSE
			    l_agent_preview_time := 0;
			    l_call_preview_time:=0;
                END IF;

                --
                --Get all the outcome counts for the last agent row
                --
                IF call.direction = 'OUTBOUND'
                THEN
                   get_outcome_counts(call.media_id, l_current_resource_id);
			    IF g_interaction_resource IS NULL
			    THEN
				  --
				  --Probably a TELE_MANUAL call with no interaction
				  --Fix for bug 3062185
				  --
				  IF l_current_resource_id = l_call_answered_by_r_id
				  THEN
					g_dial_count := 1;
                      ELSE
					g_dial_count :=0;
                      END IF;
                   END IF;
                END IF;

                --
                --Assign l_has_agent_segs to Y
                --This is used while calculating the outcome/result/reason values
                --
                   l_has_agent_segs := 'Y';

	   -- IGOR: INSERT...
	   -- IGOR: CLEANUP ... for call row

-- activity loop for the last agent row:


	 l_activity_counter := 1;
         l_outcome_id := NULL;
         l_result_id  := NULL;
         l_reason_id  := NULL;

IF (g_debug_flag = 'Y') THEN
   write_log('ABout to enter the activity cursor for last agent', g_proc_name);
   write_log('Media id is '||call.media_id || ' l_activitycounter is ' || l_activity_counter || ' l_resource id is ' || l_current_resource_id, g_proc_name);
END IF;

       FOR activity in activity_info(call.media_id,l_current_resource_id) LOOP

          /*
           * Retrieve the outcome, result and reason here.
           *Right now applies only to outbound calls.
          */
IF (g_debug_flag = 'Y') THEN
   write_log('Inside the activity cursor for last agent ', g_proc_name);
   write_log('Media id is '||call.media_id || ' l_activitycounter is ' || l_activity_counter || ' l_resource id is ' || l_current_resource_id, g_proc_name);
END IF;

          IF call.direction = 'OUTBOUND' AND l_activity_counter = 1
          THEN
             BEGIN
                SELECT DISTINCT int.outcome_id,
                                int.result_id,
                                int.reason_id
                INTO   l_outcome_id, l_result_id, l_reason_id
                from   jtf_ih_interactions int,
                       jtf_ih_activities act
                where  int.interaction_id = act.interaction_id
                and    int.resource_id = l_current_resource_id
                and    act.media_id = call.media_id;
IF (g_debug_flag = 'Y') THEN
   write_log('Retrieved outcome id '|| l_outcome_id ||' resultid ' ||l_result_id || ' reason id ' || l_reason_id, g_proc_name);
END IF;
             EXCEPTION
             WHEN OTHERS
             THEN
IF (g_debug_flag = 'Y') THEN
   write_log('Exception while getting outcome id '|| l_outcome_id ||' resultid ' ||l_result_id || ' reason id ' || l_reason_id, g_proc_name);
END IF;
                l_outcome_id := NULL;
                l_result_id  := NULL;
                l_reason_id  := NULL;
             END;
          ELSE

          IF (g_debug_flag = 'Y') THEN
             write_log('Else section while getting outcome id '|| l_outcome_id ||' resultid ' ||l_result_id || ' reason id ' || l_reason_id, g_proc_name);
          END IF;

          END IF;


          if activity.action_id = 1 then -- item created
             if activity.action_item_id = 22
                OR activity.action_item_id = 8 THEN
                l_leads_created := l_leads_created + 1;
		if activity.doc_ref = 'LEAD' or
		   activity.doc_ref = 'ASTSC_LEAD' then
			get_lead_amount( activity.doc_id,
                                         l_current_resource_id,
                                         activity.act_start_time,
					 l_leads_amount,
					 l_currency_code);
			v_leads_amount := v_leads_amount +  l_leads_amount;
		end if;
             elsif activity.action_item_id = 21 then
		l_opp_created := l_opp_created + 1;
		if activity.doc_ref = 'OPPORTUNITY' or
		   activity.doc_ref = 'ASTSC_OPP' then
			get_opportunity_amount( activity.doc_id,
                                         l_current_resource_id,
                                         activity.act_start_time,
					 l_opp_won,
					 l_opp_amount,
					 l_currency_code);
			v_opp_amount := v_opp_amount +  l_opp_amount;
			v_opp_won := v_opp_won + l_opp_won;
	           end if;
	     elsif activity.action_item_id = 17 then
		l_sr_created := l_sr_created + 1;
		l_sr_opened := l_sr_opened + 1;
             end if;
          end if;

          if activity.action_id = 13 then -- sr created specific code
                l_sr_created := l_sr_created + 1;
                l_sr_opened := l_sr_opened + 1;
          end if;




          if activity.action_id = 6 then -- item updated
             if activity.action_item_id = 22
                OR activity.action_item_id = 8 THEN
                l_leads_updated := l_leads_updated + 1;
             elsif activity.action_item_id = 21 then
                l_opp_updated := l_opp_updated + 1;
                if activity.doc_ref = 'OPPORTUNITY' or
                   activity.doc_ref = 'ASTSC_OPP' then
                        get_opportunity_amount( activity.doc_id,
                                         l_current_resource_id,
                                         activity.act_start_time,
                                         l_opp_won,
                                         l_opp_amount,
                                         l_currency_code);
                        v_opp_amount := v_opp_amount +  l_opp_amount;
                        v_opp_won := v_opp_won + l_opp_won;
	        end if;
             elsif activity.action_item_id = 17 then
                get_sr_status (activity.doc_id,l_current_resource_id,activity.act_start_time,l_sr_status);
		if l_sr_status = 1 or l_sr_status = 3 then
			l_sr_opened := l_sr_opened + 1;
		elsif l_sr_status = 2 or l_sr_status = 4 then
			l_sr_closed := l_sr_closed + 1;
		end if;
             end if;
          end if;

          if activity.action_id = 14 then -- sr updated, specific code
                get_sr_status (activity.doc_id,l_current_resource_id,activity.act_start_time,l_sr_status);
                if l_sr_status = 1 or l_sr_status = 3 then
                        l_sr_opened := l_sr_opened + 1;
                elsif l_sr_status = 2 or l_sr_status = 4 then
                        l_sr_closed := l_sr_closed + 1;
                end if;
          end if;

          if activity.action_id = 3 then -- info requested
		if activity.action_item_id = 17 then -- service request
			l_sr_info_req := l_sr_info_req + 1;
		end if;
	  elsif activity.action_id = 8 then -- cross sold
		if activity.action_item_id = 21 then
			l_opp_cross_sold := l_opp_cross_sold + 1;
		end if;
	  elsif activity.action_id = 7 then -- up sold
		if activity.action_item_id = 21 then
			l_opp_up_sold := l_opp_up_sold + 1;
		end if;
	  elsif activity.action_id = 26 then -- declined
		if activity.action_item_id = 21 then
			l_opp_declined := l_opp_declined + 1;
		end if;
	  end if;



	if l_activity_counter > 1 then
-- insert last activity row - continue here
			insert into bix_dm_interface
                        (
                        MEDIA_ID,
			RESOURCE_ID,
			--CLASSIFICATION_ID,
			CLASSIFICATION_VALUE_ID,
			SERVER_GROUP_ID,
			DNIS,
			--OUTCOME_ID,
			CURRENCY_CODE,
			PERIOD_START_DATE,
			PERIOD_START_TIME,
			PERIOD_START_DATE_TIME,
			CALLS_OFFERED,
			CALLS_IN_QUEUE,
			IN_CALLS_HANDLED,
			CALLS_TRANSFERED,
			CALLS_ABANDONED,
			OUT_CALLS_HANDLED,
			IVR_TIME,
			ROUTE_TIME,
			QUEUE_TIME,
			IN_TALK_TIME,
			IN_WRAP_TIME,
			ABANDON_TIME,
			OUT_TALK_TIME,
			OUT_WRAP_TIME,
			CAMPAIGN_ID,
			CAMPAIGN_SCHEDULE_ID,
                        SOURCE_LIST_ID,
                        SUBLIST_ID,
                        DIRECTION,
                        SERVICE_REQUESTS_CREATED,
			SERVICE_REQUESTS_OPENED,
			SERVICE_REQUESTS_CLOSED,
			LEADS_CREATED,
			LEADS_UPDATED,
			OPPORTUNITIES_CREATED,
			OPPORTUNITIES_UPDATED,
			OPPORTUNITIES_WON,
			LEADS_AMOUNT,
			OPPORTUNITIES_WON_AMOUNT,
			LEADS_AMOUNT_TXN,
			OPPORTUNITIES_WON_AMOUNT_TXN,
			OUT_CALLS_HANDLD_GT_THN_X_TIME,
			IN_CALLS_HANDLD_GT_THN_X_TIME,
			CALLS_ANSWRD_WITHIN_X_TIME,
			ROW_TYPE,
			QUEUE_TIME_FOR_CALLS_HANDLED ,
                        OUTCOME_ID,
                        RESULT_ID,
                        REASON_ID
                        )
                        values
                        (
			call.media_id,
		        l_current_resource_id,
			--v_classification_id,
			v_classification_value_id,
			call.server_group_id,
			l_dnis,
--decode(activity.outcome_id,l_prev_outcome_id,NULL,activity.outcome_id),
			NULL,
			call.PERIOD_START_DATE,
			call.PERIOD_START_TIME,
			call.PERIOD_START_DATE_TIME,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			v_campaign_id,
			v_campaign_schedule_id,
                        l_source_list_id,
                        l_sublist_id,
                        decode(call.direction,'OUTBOUND',1,2),
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
			0,
                        0,
                        0,
                        0,
			'T',
                        0,
                        l_outcome_id,
                        l_result_id,
                        l_reason_id
                        );

                        --IF activity.outcome_id IS NOT NULL
                        --THEN
                           --l_prev_outcome_id := activity.outcome_id;
                        --END IF;

			commit;
			g_insert_count := g_insert_count + 1;

        elsif l_activity_counter = 1 then
		l_first_outcome_id := activity.outcome_id;
	end if;

	 l_activity_counter := l_activity_counter + 1;

        END LOOP; -- end activity loop 2





   -- DEBUG: dbms_output.put_line('inserting agent record');
-- inserting last agent record:

		   -- IGOR: INSERT...
			insert into bix_dm_interface
                        (
                        MEDIA_ID,
			RESOURCE_ID,
			--CLASSIFICATION_ID,
			CLASSIFICATION_VALUE_ID,
			SERVER_GROUP_ID,
			DNIS,
			CURRENCY_CODE,
			PERIOD_START_DATE,
			PERIOD_START_TIME,
			PERIOD_START_DATE_TIME,
			CALLS_OFFERED,
			CALLS_IN_QUEUE,
			IN_CALLS_HANDLED,
			CALLS_TRANSFERED,
			CALLS_ABANDONED,
			OUT_CALLS_HANDLED,
			IVR_TIME,
			ROUTE_TIME,
			QUEUE_TIME,
			IN_TALK_TIME,
			IN_WRAP_TIME,
			ABANDON_TIME,
			OUT_TALK_TIME,
			OUT_WRAP_TIME,
			CAMPAIGN_ID,
			CAMPAIGN_SCHEDULE_ID,
			--OUTCOME_ID,
                        SOURCE_LIST_ID,
                        SUBLIST_ID,
                        DIRECTION,
                        SERVICE_REQUESTS_CREATED,
			SERVICE_REQUESTS_OPENED,
			SERVICE_REQUESTS_CLOSED,
			SERVICE_REQUESTS_INFO_REQ,
			LEADS_CREATED,
			LEADS_UPDATED,
			OPPORTUNITIES_CREATED,
			OPPORTUNITIES_UPDATED,
			OPPORTUNITIES_WON,
			LEADS_AMOUNT,
			OPPORTUNITIES_WON_AMOUNT,
			OPPORTUNITIES_CROSS_SOLD,
			OPPORTUNITIES_UP_SOLD,
			OPPORTUNITIES_DECLINED,
			LEADS_AMOUNT_TXN,
			OPPORTUNITIES_WON_AMOUNT_TXN,
			OUT_CALLS_HANDLD_GT_THN_X_TIME,
			IN_CALLS_HANDLD_GT_THN_X_TIME,
			CALLS_ANSWRD_WITHIN_X_TIME,
			ROW_TYPE,
			QUEUE_TIME_FOR_CALLS_HANDLED ,
                        OUT_CALLS_DIALED,
                        OUT_CONTACT_COUNT,
                        OUT_NON_CONTACT_COUNT,
                        OUT_ABANDON_COUNT,
                        OUT_BUSY_COUNT ,
                        OUT_RING_NOANSWER_COUNT,
                        OUT_ANS_MC_COUNT ,
                        OUT_SIT_COUNT,
                        OUT_POSITIVE_RESPONSE_COUNT,
                        OUT_CONNECT_COUNT ,
                        OUT_NON_CONNECT_COUNT ,
                        OUT_OTHER_OUTCOME_COUNT,
                        OUT_PREVIEW_TIME,
                        OUT_CONTACT_HANDLE_TIME,
                        OUTCOME_ID,
                        RESULT_ID,
                        REASON_ID
                        )
                        values
                        (
			call.media_id,
		        l_current_resource_id,
			--v_classification_id,
			v_classification_value_id,
			call.server_group_id,
			l_dnis,
			l_currency_code,
			call.PERIOD_START_DATE,
			call.PERIOD_START_TIME,
			call.PERIOD_START_DATE_TIME,
			0,
			0,
			v_in_calls_handled,
			v_calls_transferred,
			0,
			v_out_calls_handled,
			0,
			0,
			0,
			v_in_talk_time,
			v_in_wrap_time,
			0,
			v_out_talk_time,
			v_out_wrap_time,
			v_campaign_id,
			v_campaign_schedule_id,
			--l_first_outcome_id,
                        l_source_list_id,
                        l_sublist_id,
                        decode(call.direction,'OUTBOUND',1,'INBOUND',2),
                        l_sr_created,
                        l_sr_opened,
                        l_sr_closed,
                        l_sr_info_req,
                        l_leads_created,
                        l_leads_updated,
                        l_opp_created,
                        l_opp_updated,
                        v_opp_won,
                        decode(l_currency_code,g_preferred_currency,v_leads_amount,null,v_leads_amount,gl_currency_api.convert_amount_sql(l_currency_code,g_preferred_currency,call.PERIOD_START_DATE_TIME,g_conversion_type,v_leads_amount)),
                        decode(l_currency_code,g_preferred_currency,v_opp_amount,null,v_opp_amount,gl_currency_api.convert_amount_sql(l_currency_code,g_preferred_currency,call.PERIOD_START_DATE_TIME,g_conversion_type,v_opp_amount)),
			l_opp_cross_sold,
			l_opp_up_sold,
			l_opp_declined,
                        v_leads_amount,
                        v_opp_amount,
                        l_ou_cls_hdld_gt_thn_x_tm,
                        l_in_cls_hdld_gt_thn_x_tm,
                        l_calls_answrd_within_x_time,
                        'A',
			l_queue_time_for_calls_handled ,
                        g_dial_count,
                        g_contact_count,
                        g_noncontact_count,
                        g_abandon_count,
                        g_busy_count,
                        g_rna_count,
                        g_ansmc_count,
                        g_sit_count,
                        g_pr_count,
                        g_connect_count,
                        g_nonconnect_count,
                        g_other_count,
                        nvl(l_agent_preview_time,0),
                        nvl
				    (decode(g_contact_count,0,0,NULL,0,
				       nvl(v_out_talk_time,0) +
				       nvl(v_out_wrap_time,0) +
				       nvl(l_agent_preview_time,0)
				        ),0
				     ),
                        l_outcome_id,
                        l_result_id,
                        l_reason_id
                        );

                        --IF l_first_outcome_id IS NOT NULL
                        --THEN
                           --l_prev_outcome_id := l_first_outcome_id;
                        --END IF;

			commit;
			g_insert_count := g_insert_count + 1;

	 end if;
	 -- end with agent stuff
-- IGOR - end if for 'with agent' segments
-- insert call row:
   -- DEBUG: dbms_output.put_line('inserting call record');

                --
                --Get all the outcome counts at call level
                --

      IF l_has_agent_segs = 'N' and call.direction = 'OUTBOUND'
      THEN
                   get_outcome_counts(call.media_id, NULL);
         /*
          *This means we have not inserted the outcome/result/reason
          *as there are no with agent segments.
          *This will happen only for predictive calls
          *which did not connect to an agent.  Assume
          *only one interaction row (rownum = 1) - confirmed
          *from AO - OLTP team.
          * Retrieve the outcome, result and reason here.
          *Right now applies only to outbound calls.
         */

            BEGIN
               SELECT DISTINCT int.outcome_id,
                               int.result_id,
                               int.reason_id
               INTO   l_outcome_id, l_result_id, l_reason_id
               from   jtf_ih_interactions int,
                      jtf_ih_activities act
               where  int.interaction_id = act.interaction_id
               and    act.media_id = call.media_id
               and    rownum = 1;
            EXCEPTION
            WHEN OTHERS
            THEN
               l_outcome_id := NULL;
               l_result_id  := NULL;
               l_reason_id  := NULL;
            END;

		  --
		  --Change on 10-JUL-2003:
		  --Add check to see if interaction level resource is valid.
		  --If so, then insert the agent level row here.
		  --Then, set the AO counts to NULL so that they
		  --do not get repeated at call level.
		  --If no interaction resource, do the other steps as usual.
		  --

		  IF g_interaction_resource IS NOT NULL
		  THEN
			insert into bix_dm_interface
                        (
                        MEDIA_ID,
			RESOURCE_ID,
			--CLASSIFICATION_ID,
			CLASSIFICATION_VALUE_ID,
			SERVER_GROUP_ID,
			DNIS,
			CURRENCY_CODE,
			PERIOD_START_DATE,
			PERIOD_START_TIME,
			PERIOD_START_DATE_TIME,
			CALLS_OFFERED,
			CALLS_IN_QUEUE,
			IN_CALLS_HANDLED,
			CALLS_TRANSFERED,
			CALLS_ABANDONED,
			OUT_CALLS_HANDLED,
			IVR_TIME,
			ROUTE_TIME,
			QUEUE_TIME,
			IN_TALK_TIME,
			IN_WRAP_TIME,
			ABANDON_TIME,
			OUT_TALK_TIME,
			OUT_WRAP_TIME,
			CAMPAIGN_ID,
			CAMPAIGN_SCHEDULE_ID,
			--OUTCOME_ID,
                        SOURCE_LIST_ID,
                        SUBLIST_ID,
                        DIRECTION,
                        SERVICE_REQUESTS_CREATED,
			SERVICE_REQUESTS_OPENED,
			SERVICE_REQUESTS_CLOSED,
			LEADS_CREATED,
			LEADS_UPDATED,
			OPPORTUNITIES_CREATED,
			OPPORTUNITIES_UPDATED,
			OPPORTUNITIES_WON,
			LEADS_AMOUNT,
			OPPORTUNITIES_WON_AMOUNT,
			LEADS_AMOUNT_TXN,
			OPPORTUNITIES_WON_AMOUNT_TXN,
			OUT_CALLS_HANDLD_GT_THN_X_TIME,
			IN_CALLS_HANDLD_GT_THN_X_TIME,
			CALLS_ANSWRD_WITHIN_X_TIME,
			ROW_TYPE,
			QUEUE_TIME_FOR_CALLS_HANDLED ,
                        OUT_CALLS_DIALED,
                        OUT_CONTACT_COUNT,
                        OUT_NON_CONTACT_COUNT,
                        OUT_ABANDON_COUNT,
                        OUT_BUSY_COUNT ,
                        OUT_RING_NOANSWER_COUNT,
                        OUT_ANS_MC_COUNT ,
                        OUT_SIT_COUNT,
                        OUT_POSITIVE_RESPONSE_COUNT,
                        OUT_CONNECT_COUNT ,
                        OUT_NON_CONNECT_COUNT ,
                        OUT_OTHER_OUTCOME_COUNT,
                        OUT_PREVIEW_TIME,
                        OUT_CONTACT_HANDLE_TIME,
                        OUTCOME_ID,
                        RESULT_ID,
                        REASON_ID
                        )
                        values
                        (
			call.media_id,
		     g_interaction_resource, --l_current_resource_id,
			--v_classification_id,
			v_classification_value_id,
			call.server_group_id,
			l_dnis,
			l_currency_code,
			call.PERIOD_START_DATE,
			call.PERIOD_START_TIME,
			call.PERIOD_START_DATE_TIME,
			0,
			0,
			0, --v_in_calls_handled,
			0, --v_calls_transferred,
			0,
			1, --v_out_calls_handled, make this 1 to indicate agent handled one call
			0,
			0,
			0,
			0, --v_in_talk_time,
			0, --v_in_wrap_time,
			0,
			0, --v_out_talk_time,
			0, --v_out_wrap_time,
			v_campaign_id,
			v_campaign_schedule_id,
			--l_first_outcome_id,
                        l_source_list_id,
                        l_sublist_id,
                        decode(call.direction,'OUTBOUND',1,'INBOUND',2),
                        0,--l_sr_created,
                        0,--l_sr_opened,
                        0,--l_sr_closed,
                        0,--l_leads_created,
                        0,--l_leads_updated,
                        0,--l_opp_created,
                        0,--l_opp_updated,
                        0,--v_opp_won,
                        0,
                        0,
				    0, --v_leads_amount,
                        0, --v_opp_amount,
                        0, --l_ou_cls_hdld_gt_thn_x_tm,
                        0, --l_in_cls_hdld_gt_thn_x_tm,
                        0, --l_calls_answrd_within_x_time,
                        'A',
			         0, --l_queue_time_for_calls_handled ,
                        g_dial_count,
                        g_contact_count,
                        g_noncontact_count,
                        g_abandon_count,
                        g_busy_count,
                        g_rna_count,
                        g_ansmc_count,
                        g_sit_count,
                        g_pr_count,
                        g_connect_count,
                        g_nonconnect_count,
                        g_other_count,
                        0, --nvl(l_agent_preview_time,0),
                        0, --nvl(decode(g_contact_count,0,0,NULL,0,v_out_talk_time+v_out_wrap_time),0),
                        l_outcome_id,
                        l_result_id,
                        l_reason_id
                        );

  g_dial_count :=0;
  g_contact_count :=0;
  g_noncontact_count :=0;
  g_abandon_count :=0;
  g_busy_count :=0;
  g_rna_count :=0;
  g_ansmc_count :=0;
  g_sit_count :=0;
  g_pr_count :=0;
  g_connect_count :=0;
  g_nonconnect_count :=0;
  g_other_count :=0;
  l_outcome_id := NULL;
  l_result_id := NULL;
  l_reason_id := NULL;

  g_interaction_resource := NULL;

            END IF;

      ELSE
         l_outcome_id  := NULL;
         l_result_id   := NULL;
         l_reason_id   := NULL;
  g_dial_count :=0;
  g_contact_count :=0;
  g_noncontact_count :=0;
  g_abandon_count :=0;
  g_busy_count:=0;
  g_rna_count :=0;
  g_ansmc_count :=0;
  g_sit_count :=0;
  g_pr_count :=0;
  g_connect_count :=0;
  g_nonconnect_count :=0;
  g_other_count :=0;
      END IF;

		insert into bix_dm_interface
		(
		MEDIA_ID,
		RESOURCE_ID,
		--CLASSIFICATION_ID,
		CLASSIFICATION_VALUE_ID,
		SERVER_GROUP_ID,
		DNIS,
		CURRENCY_CODE,
		PERIOD_START_DATE,
		PERIOD_START_TIME,
		PERIOD_START_DATE_TIME,
		CALLS_OFFERED,
		CALLS_IN_QUEUE,
		IN_CALLS_HANDLED,
		CALLS_TRANSFERED,
		CALLS_ABANDONED,
		OUT_CALLS_HANDLED,
		IVR_TIME,
		ROUTE_TIME,
		QUEUE_TIME,
		IN_TALK_TIME,
		IN_WRAP_TIME,
		ABANDON_TIME,
		OUT_TALK_TIME,
		OUT_WRAP_TIME,
		CAMPAIGN_ID,
		CAMPAIGN_SCHEDULE_ID,
                SOURCE_LIST_ID,
                SUBLIST_ID,
                DIRECTION,
		ROW_TYPE,
		OUT_CALLS_HANDLD_GT_THN_X_TIME,
		IN_CALLS_HANDLD_GT_THN_X_TIME,
		CALLS_ANSWRD_WITHIN_X_TIME,
		QUEUE_TIME_FOR_CALLS_HANDLED ,
		NUMBER_OF_REROUTS,
                OUTCOME_ID,
                RESULT_ID,
                REASON_ID,
                OUT_CALLS_DIALED,
                OUT_CONTACT_COUNT,
                OUT_NON_CONTACT_COUNT,
                OUT_ABANDON_COUNT,
                OUT_BUSY_COUNT ,
                OUT_RING_NOANSWER_COUNT,
                OUT_ANS_MC_COUNT ,
                OUT_SIT_COUNT,
                OUT_POSITIVE_RESPONSE_COUNT,
                OUT_CONNECT_COUNT ,
                OUT_NON_CONNECT_COUNT ,
                OUT_OTHER_OUTCOME_COUNT,
                OUT_PREVIEW_TIME
		)
		values
		(
		call.media_id,
		NULL,
		--v_classification_id,
		v_classification_value_id,
		call.server_group_id,
		l_dnis,
		l_currency_code,
		call.PERIOD_START_DATE,
		call.PERIOD_START_TIME,
		call.PERIOD_START_DATE_TIME,
		call.CALLS_OFFERED,
		v_calls_in_queue,
		0,
		0,
		call.CALLS_ABANDONED,
		0,
		v_ivr_time ,
		v_route_time ,
		v_queue_time ,
		0,
		0,
		v_abandon_time,
		0,
		0,
		v_campaign_id,
		v_campaign_schedule_id,
                l_source_list_id,
                l_sublist_id,
                decode(call.direction,'OUTBOUND',1,'INBOUND',2),
		'C',
                0,
                0,
                0,
                0,
		 l_number_of_rerouts,
                l_outcome_id,
                l_result_id,
                l_reason_id,
                g_dial_count,
                g_contact_count,
                g_noncontact_count,
                g_abandon_count,
                g_busy_count,
                g_rna_count,
                g_ansmc_count,
                g_sit_count,
                g_pr_count,
                g_connect_count,
                g_nonconnect_count,
                g_other_count,
                nvl(l_call_preview_time,0)
		);

		commit;
		g_insert_count := g_insert_count + 1;

	   -- IGOR: CLEANUP ...

	 v_classification_value_id := NULL;
	 v_calls_in_queue := 0;
	 v_in_calls_handled := 0;
	 v_calls_transferred := 0;
	 v_out_calls_handled := 0;
	 v_in_talk_time := 0;
	 v_in_wrap_time := 0;
	 v_out_talk_time := 0;
	 v_out_wrap_time := 0;
	 v_campaign_id := NULL;
	 v_campaign_schedule_id := NULL;
	 v_campaign_schedule := NULL;
	 v_total_in_talk_time := 0;
	 v_total_out_talk_time := 0;
	 v_ivr_time := 0;
	 v_route_time := 0;
	 v_queue_time := 0;
	 v_abandon_time := 0;
	 v_resource_id := NULL;
	 l_current_start_date_time := NULL;
	 l_current_end_date_time := NULL;
	 l_call_answered_by_r_id := 0;
	 l_campaign_code := 0;
	 l_counter := 0;
	 l_current_resource_id := 0;
	 l_max_end_date := NULL;
	 l_wrap_time := 0;
	 l_source_list_id := NULL;
	 l_sublist_id := NULL;

	 l_leads_amount := 0;
	 l_opp_amount := 0;
	 l_leads_amount_txn := 0;
	 l_opp_amount_txn := 0;
	 v_leads_amount := 0;
	 v_opp_amount := 0;
	 v_leads_amount_txn := 0;
	 v_opp_amount_txn := 0;
	 l_leads_created := 0;
	 l_leads_updated := 0;
	 l_sr_created := 0;
	 l_sr_opened := 0;
	 l_sr_closed := 0;
	 l_opp_created := 0;
	 l_opp_updated := 0;
	 l_opp_won := 0;
	 v_opp_won := 0;
	 l_activity_counter := 0;
	 l_currency_code := NULL;
         l_dnis := NULL;
	 l_first_outcome_id := NULL;
	 l_prev_outcome_id := NULL;
	 l_sr_info_req := 0;
	 l_opp_cross_sold := 0;
	 l_opp_up_sold := 0;
	 l_opp_cross_sold := 0;
	 l_ou_cls_hdld_gt_thn_x_tm := 0;
	 l_in_cls_hdld_gt_thn_x_tm := 0;
	 l_calls_answrd_within_x_time := 0;
	 l_min_call_treshold_goal := 0;
	 l_sl_seconds_goal := 30;
	 l_queue_time_for_calls_handled := 0;
	 l_number_of_rerouts := 0;

         l_has_agent_segs := 'N';

         l_agent_preview_time := 0;
         l_call_preview_time := 0;

      	END LOOP;


  EXCEPTION
	WHEN OTHERS THEN
		RAISE;

END GET_CALLS;


-- Summarizing the interface table by agent and inserting rows into
-- the BIX_DM_AGENT_SUM table

PROCEDURE SUM_AGENT AS

CURSOR agent_data IS
 SELECT call_stage.SERVER_GROUP_ID SERVER_GROUP_ID,
        call_stage.CLASSIFICATION_VALUE_ID CLASSIFICATION_VALUE_ID,
        call_stage.CAMPAIGN_ID CAMPAIGN_ID,
        call_stage.CAMPAIGN_SCHEDULE_ID CAMPAIGN_SCHEDULE_ID,
        call_stage.resource_id RESOURCE_ID,
        call_stage.PERIOD_START_DATE PERIOD_START_DATE,
        call_stage.PERIOD_START_TIME PERIOD_START_TIME,
        call_stage.PERIOD_START_DATE_TIME PERIOD_START_DATE_TIME,
        NVL(SUM(call_stage.IN_CALLS_HANDLED),0) IN_CALLS_HANDLED,
        NVL(SUM(call_stage.IN_CALLS_HANDLD_GT_THN_X_TIME),0) IN_CALLS_HANDLD_GT_THN_X_TIME,
           NVL(SUM(call_stage.CALLS_TRANSFERED),0) CALLS_TRANSFERED,
        NVL(SUM(call_stage.OUT_CALLS_HANDLED),0) OUT_CALLS_HANDLED,
	NVL(SUM(call_stage.OUT_CALLS_HANDLD_GT_THN_X_TIME),0) OUT_CALLS_HANDLD_GT_THN_X_TIME,
           NVL(SUM(NVL(call_stage.IN_TALK_TIME,0)),0) IN_TALK_TIME,
           NVL(SUM(NVL(call_stage.IN_WRAP_TIME,0)),0) IN_WRAP_TIME,
           NVL(SUM(NVL(call_stage.OUT_TALK_TIME,0)),0) OUT_TALK_TIME,
           NVL(SUM(NVL(call_stage.OUT_WRAP_TIME,0)),0) OUT_WRAP_TIME,
           NVL(MIN(call_stage.IN_TALK_TIME),0) IN_MIN_TALK_TIME,
           NVL(MAX(call_stage.IN_TALK_TIME),0) IN_MAX_TALK_TIME,
           NVL(MIN(call_stage.OUT_TALK_TIME),0) OUT_MIN_TALK_TIME,
           NVL(MAX(call_stage.OUT_TALK_TIME),0) OUT_MAX_TALK_TIME,
           NVL(MIN(call_stage.IN_WRAP_TIME),0) IN_MIN_WRAP_TIME,
           NVL(MAX(call_stage.IN_WRAP_TIME),0) IN_MAX_WRAP_TIME,
           NVL(MIN(call_stage.OUT_WRAP_TIME),0) OUT_MIN_WRAP_TIME,
           NVL(MAX(call_stage.OUT_WRAP_TIME),0) OUT_MAX_WRAP_TIME,
	   NVL(SUM(call_stage.SERVICE_REQUESTS_CREATED),0) SR_CREATED,
	   NVL(SUM(call_stage.SERVICE_REQUESTS_OPENED),0) SR_OPENED,
	   NVL(SUM(call_stage.SERVICE_REQUESTS_CLOSED),0) SR_CLOSED,
	   NVL(SUM(call_stage.SERVICE_REQUESTS_CONTACT_CL),0) SR_FIRST_CONTACT_CLOSE,
	   NVL(SUM(call_stage.SERVICE_REQUESTS_INFO_REQ),0) SR_ADDITIONAL_INFO_REQUESTED,
	   NVL(SUM(call_stage.SERVICE_REQUESTS_KB_UPDATES),0) SR_KB_UPDATES,
	   NVL(SUM(call_stage.LEADS_CREATED),0) LEADS_CREATED,
	   NVL(SUM(call_stage.LEADS_UPDATED),0) LEADS_UPDATED,
	   NVL(SUM(call_stage.LEADS_AMOUNT),0) LEADS_AMOUNT,
	   NVL(SUM(call_stage.LEADS_CONV_TO_OPP),0) LEADS_CONVERTED_TO_OPP,
	   NVL(SUM(call_stage.LEADS_AMOUNT_TXN),0) LEADS_AMOUNT_TXN,
	   NVL(SUM(call_stage.OPPORTUNITIES_CREATED),0) OPPORTUNITIES_CREATED,
	   NVL(SUM(call_stage.OPPORTUNITIES_UPDATED),0) OPPORTUNITIES_UPDATED,
	   NVL(SUM(call_stage.OPPORTUNITIES_WON),0) OPPORTUNITIES_WON,
	   NVL(SUM(call_stage.OPPORTUNITIES_WON_AMOUNT),0) OPPORTUNITIES_WON_AMOUNT,
	   NVL(SUM(call_stage.OPPORTUNITIES_WON_AMOUNT_TXN),0) OPPORTUNITIES_WON_AMOUNT_TXN,
	   NVL(SUM(call_stage.OPPORTUNITIES_CROSS_SOLD),0) OPPORTUNITIES_CROSS_SOLD,
	   NVL(SUM(call_stage.OPPORTUNITIES_UP_SOLD),0) OPPORTUNITIES_UP_SOLD,
	   NVL(SUM(call_stage.OPPORTUNITIES_DECLINED),0) OPPORTUNITIES_DECLINED,
	   NVL(SUM(call_stage.OPPORTUNITIES_LOST),0) OPPORTUNITIES_LOST,
           SUM(NVL(OUT_CALLS_DIALED,0)) OUT_CALLS_DIALED,
           SUM(NVL( OUT_CONTACT_COUNT,0)) OUT_CONTACT_COUNT,
           SUM(NVL( OUT_NON_CONTACT_COUNT,0)) OUT_NON_CONTACT_COUNT,
           SUM(NVL(OUT_ABANDON_COUNT,0)) OUT_ABANDON_COUNT,
           SUM(NVL(OUT_BUSY_COUNT ,0)) OUT_BUSY_COUNT,
           SUM(NVL(OUT_RING_NOANSWER_COUNT,0)) OUT_RING_NOANSWER_COUNT,
           SUM(NVL(OUT_ANS_MC_COUNT ,0)) OUT_ANS_MC_COUNT,
           SUM(NVL(OUT_SIT_COUNT,0)) OUT_SIT_COUNT,
           SUM(NVL(OUT_POSITIVE_RESPONSE_COUNT,0)) OUT_POSITIVE_RESPONSE_COUNT,
           SUM(NVL(OUT_CONNECT_COUNT ,0)) OUT_CONNECT_COUNT,
           SUM(NVL(OUT_NON_CONNECT_COUNT ,0)) OUT_NON_CONNECT_COUNT,
           SUM(NVL(OUT_OTHER_OUTCOME_COUNT,0)) OUT_OTHER_OUTCOME_COUNT,
           SUM(NVL(OUT_PREVIEW_TIME,0)) OUT_PREVIEW_TIME,
           SUM(NVL(OUT_CONTACT_HANDLE_TIME,0)) OUT_CONTACT_HANDLE_TIME
  FROM  bix_dm_interface call_stage
  where call_stage.RESOURCE_ID is not null
 GROUP BY call_stage.SERVER_GROUP_ID,
          call_stage.CLASSIFICATION_VALUE_ID,
             call_stage.CAMPAIGN_ID,
          call_stage.CAMPAIGN_SCHEDULE_ID,
             call_stage.resource_id,
          call_stage.period_start_date,
          call_stage.period_start_time,
          call_stage.PERIOD_START_DATE_TIME;

 l_bix_agent_seq number;
 l_num_calls number;

BEGIN

     g_insert_count := 0;
     g_delete_count := 0;

-- IGOR : initialize and check for 'no rows returned'

/* Get the count of rows from the */

      SELECT count(*) INTO   l_num_calls
      FROM   bix_dm_interface;

	if (l_num_calls > 0) THEN

     IF (g_debug_flag = 'Y') THEN
	     write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.AGENT_SUM: '||' Start Deleting rows in BIM_DM_AGENT_SUM Table', g_proc_name);
     END IF;

-- Delete the rows from summary table for the date range specified

     DELETE_IN_CHUNKS('BIX_DM_AGENT_SUM',
                       'period_start_date_time BETWEEN '||' to_date('||
                        ''''||
                        to_char(g_min_call_begin_date,'YYYY/MM/DDHH24:MI:SS')||
                        ''''||
                        ',''YYYY/MM/DDHH24:MI:SS'') AND '||'to_date('||
                        ''''||
                        to_char(g_max_call_begin_date,'YYYY/MM/DDHH24:MI:SS')||
                        ''''||
                        ',''YYYY/MM/DDHH24:MI:SS'')',
                        g_delete_count);

     --dbms_output.put_line('Deleted count:'||g_delete_count);

     COMMIT;

     IF (g_debug_flag = 'Y') THEN

        write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.COLLECT_CALLS: '||' Finished  Deleting rows in BIX_DM_AGENT_SUM table: ' || 'Row Count:' || g_delete_count, g_proc_name);

        write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_AGENT: '||' Start inserting rows into BIX_DM_AGENT_SUM table: ', g_proc_name);

	END IF;


	for ag_row in agent_data LOOP


	SELECT BIX_DM_AGENT_SUM_S.NEXTVAL INTO l_bix_agent_seq FROM DUAL;

     INSERT INTO BIX_DM_AGENT_SUM
        (
        AGENT_SUMMARY_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
         SERVER_GROUP_ID,
         --CLASSIFICATION_ID,
         CLASSIFICATION_VALUE_ID,
         CAMPAIGN_ID,
         CAMPAIGN_SCHEDULE_ID,
         RESOURCE_ID,
         PERIOD_START_DATE,
         PERIOD_START_TIME,
         PERIOD_START_DATE_TIME,
         IN_CALLS_HANDLED,
          IN_CALLS_HANDLD_GT_THN_X_TIME,
          CALLS_TRANSFERED,
         OUT_CALLS_HANDLED,
          OUT_CALLS_HANDLD_GT_THN_X_TIME,
          IN_TALK_TIME,
          IN_WRAP_TIME,
          OUT_TALK_TIME,
          OUT_WRAP_TIME,
          IN_MIN_TALK_TIME,
          IN_MAX_TALK_TIME,
          OUT_MIN_TALK_TIME,
          OUT_MAX_TALK_TIME,
          IN_MIN_WRAP_TIME,
          IN_MAX_WRAP_TIME,
          OUT_MIN_WRAP_TIME,
          OUT_MAX_WRAP_TIME,
	  SR_CREATED,
	  SR_OPENED,
	  SR_CLOSED,
	  SR_FIRST_CONTACT_CLOSE,
	  SR_ADDITIONAL_INFO_REQUESTED,
	  SR_KB_UPDATES,
	  LEADS_CREATED,
	  LEADS_UPDATED,
	  LEADS_AMOUNT,
	  LEADS_CONVERTED_TO_OPP,
	  OPPORTUNITIES_CREATED,
	  OPPORTUNITIES_UPDATED,
	  OPPORTUNITIES_WON,
	  OPPORTUNITIES_WON_AMOUNT,
	  OPPORTUNITIES_CROSS_SOLD,
	  OPPORTUNITIES_UP_SOLD,
	  OPPORTUNITIES_DECLINED,
	  OPPORTUNITIES_LOST,
	  LEADS_AMOUNT_TXN,
	  OPPORTUNITIES_WON_AMOUNT_TXN,
          OUT_CALLS_DIALED,
          OUT_CONTACT_COUNT,
          OUT_NON_CONTACT_COUNT,
          OUT_ABANDON_COUNT,
          OUT_BUSY_COUNT ,
          OUT_RING_NOANSWER_COUNT,
          OUT_ANS_MC_COUNT ,
          OUT_SIT_COUNT,
          OUT_POSITIVE_RESPONSE_COUNT,
          OUT_CONNECT_COUNT ,
          OUT_NON_CONNECT_COUNT ,
          OUT_OTHER_OUTCOME_COUNT,
		OUT_PREVIEW_TIME,
		OUT_CONTACT_HANDLE_TIME
	)
        VALUES
        (
        l_bix_agent_seq,
        SYSDATE,
        g_user_id,
        SYSDATE,
        g_user_id,
        SYSDATE,
        ag_row.SERVER_GROUP_ID,
        ag_row.CLASSIFICATION_VALUE_ID,
         ag_row.CAMPAIGN_ID,
         ag_row.CAMPAIGN_SCHEDULE_ID,
         ag_row.RESOURCE_ID,
         ag_row.PERIOD_START_DATE,
         ag_row.PERIOD_START_TIME,
         ag_row.PERIOD_START_DATE_TIME,
         ag_row.IN_CALLS_HANDLED,
         ag_row.IN_CALLS_HANDLD_GT_THN_X_TIME,
           ag_row.CALLS_TRANSFERED,
        ag_row.OUT_CALLS_HANDLED,
        ag_row.OUT_CALLS_HANDLD_GT_THN_X_TIME,
           ag_row.IN_TALK_TIME,
           ag_row.IN_WRAP_TIME,
           ag_row.OUT_TALK_TIME,
           ag_row.OUT_WRAP_TIME,
           ag_row.IN_MIN_TALK_TIME,
           ag_row.IN_MAX_TALK_TIME,
           ag_row.OUT_MIN_TALK_TIME,
           ag_row.OUT_MAX_TALK_TIME,
           ag_row.IN_MIN_WRAP_TIME,
           ag_row.IN_MAX_WRAP_TIME,
           ag_row.OUT_MIN_WRAP_TIME,
           ag_row.OUT_MAX_WRAP_TIME,
	   ag_row.SR_CREATED,
	   ag_row.SR_OPENED,
	   ag_row.SR_CLOSED,
	   ag_row.SR_FIRST_CONTACT_CLOSE,
	   ag_row.SR_ADDITIONAL_INFO_REQUESTED,
	   ag_row.SR_KB_UPDATES,
	   ag_row.LEADS_CREATED,
	   ag_row.LEADS_UPDATED,
	   ag_row.LEADS_AMOUNT,
	   ag_row.LEADS_CONVERTED_TO_OPP,
	   ag_row.OPPORTUNITIES_CREATED,
	   ag_row.OPPORTUNITIES_UPDATED,
	   ag_row.OPPORTUNITIES_WON,
	   ag_row.OPPORTUNITIES_WON_AMOUNT,
	   ag_row.OPPORTUNITIES_CROSS_SOLD,
	   ag_row.OPPORTUNITIES_UP_SOLD,
	   ag_row.OPPORTUNITIES_DECLINED,
	   ag_row.OPPORTUNITIES_LOST,
           ag_row.LEADS_AMOUNT_TXN,
           ag_row.OPPORTUNITIES_WON_AMOUNT_TXN,
           ag_row.OUT_CALLS_DIALED,
           ag_row.OUT_CONTACT_COUNT,
           ag_row.OUT_NON_CONTACT_COUNT,
           ag_row.OUT_ABANDON_COUNT,
           ag_row.OUT_BUSY_COUNT ,
           ag_row.OUT_RING_NOANSWER_COUNT,
           ag_row.OUT_ANS_MC_COUNT ,
           ag_row.OUT_SIT_COUNT,
           ag_row.OUT_POSITIVE_RESPONSE_COUNT,
           ag_row.OUT_CONNECT_COUNT ,
           ag_row.OUT_NON_CONNECT_COUNT ,
           ag_row.OUT_OTHER_OUTCOME_COUNT,
           ag_row.OUT_PREVIEW_TIME,
           ag_row.OUT_CONTACT_HANDLE_TIME
           );

	   commit;

	 g_insert_count := g_insert_count+1;

	END LOOP;
    end if; -- if there are rows in the interface table

EXCEPTION
        WHEN OTHERS THEN

        IF (g_debug_flag = 'Y') THEN
           write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||' BIX_DM_AGENT_SUMMARY_PKG.SUM_AGENT: '|| ' Failed to  Rolled back data in BIX_DM_AGENT_SUM table ', g_proc_name);
        END IF;

        g_proc_name := 'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_AGENT';
        g_error_mesg := g_proc_name ||' : '|| sqlerrm;
	RAISE;

END SUM_AGENT;




-- Summarizing the BIX_DM_AGENT_SUM table by group and inserting rows into
-- the BIX_DM_GROUP_SUM table. If an agent is in two or more groups the
-- numbers will be double-counted. Therefore this table is not additive.

PROCEDURE SUM_GROUP AS

CURSOR group_data IS
 SELECT group_denorm.parent_group_id GROUP_ID,
        agent_sum.SERVER_GROUP_ID SERVER_GROUP_ID,
        --agent_sum.CLASSIFICATION_ID CLASSIFICATION_ID,
        agent_sum.CLASSIFICATION_VALUE_ID CLASSIFICATION_VALUE_ID,
        agent_sum.CAMPAIGN_ID CAMPAIGN_ID,
        agent_sum.CAMPAIGN_SCHEDULE_ID CAMPAIGN_SCHEDULE_ID,
        agent_sum.PERIOD_START_DATE PERIOD_START_DATE,
        agent_sum.PERIOD_START_TIME PERIOD_START_TIME,
        agent_sum.PERIOD_START_DATE_TIME PERIOD_START_DATE_TIME,
	sum(agent_sum.IN_CALLS_HANDLED) IN_CALLS_HANDLED,
	sum(agent_sum.IN_CALLS_HANDLD_GT_THN_X_TIME) IN_CALLS_HANDLD_GT_THN_X_TIME,
	sum(agent_sum.OUT_CALLS_HANDLED) OUT_CALLS_HANDLED,
	sum(agent_sum.OUT_CALLS_HANDLD_GT_THN_X_TIME) OUT_CALLS_HANDLD_GT_THN_X_TIME,
	sum(agent_sum.CALLS_TRANSFERED) CALLS_TRANSFERED,
	sum(agent_sum.IN_TALK_TIME) IN_TALK_TIME,
	sum(agent_sum.OUT_TALK_TIME) OUT_TALK_TIME,
	sum(agent_sum.IN_WRAP_TIME) IN_WRAP_TIME,
	sum(agent_sum.OUT_WRAP_TIME) OUT_WRAP_TIME,
	sum(agent_sum.IN_MIN_TALK_TIME) IN_MIN_TALK_TIME,
	sum(agent_sum.IN_MAX_TALK_TIME) IN_MAX_TALK_TIME,
	sum(agent_sum.OUT_MIN_TALK_TIME) OUT_MIN_TALK_TIME,
	sum(agent_sum.OUT_MAX_TALK_TIME) OUT_MAX_TALK_TIME,
	sum(agent_sum.IN_MIN_WRAP_TIME) IN_MIN_WRAP_TIME,
	sum(agent_sum.IN_MAX_WRAP_TIME) IN_MAX_WRAP_TIME,
	sum(agent_sum.OUT_MIN_WRAP_TIME) OUT_MIN_WRAP_TIME,
	sum(agent_sum.OUT_MAX_WRAP_TIME) OUT_MAX_WRAP_TIME,
	sum(agent_sum.SR_CREATED) SR_CREATED,
	sum(agent_sum.SR_OPENED) SR_OPENED,
	sum(agent_sum.SR_CLOSED) SR_CLOSED,
	sum(agent_sum.SR_FIRST_CONTACT_CLOSE) SR_FIRST_CONTACT_CLOSE,
	sum(agent_sum.SR_ADDITIONAL_INFO_REQUESTED) SR_ADDITIONAL_INFO_REQUESTED,
	sum(agent_sum.SR_KB_UPDATES) SR_KB_UPDATES,
	sum(agent_sum.LEADS_CREATED) LEADS_CREATED,
	sum(agent_sum.LEADS_UPDATED) LEADS_UPDATED,
	sum(agent_sum.LEADS_AMOUNT) LEADS_AMOUNT,
	sum(agent_sum.LEADS_AMOUNT_TXN) LEADS_AMOUNT_TXN,
	sum(agent_sum.LEADS_CONVERTED_TO_OPP) LEADS_CONVERTED_TO_OPP,
	sum(agent_sum.OPPORTUNITIES_CREATED) OPPORTUNITIES_CREATED,
	sum(agent_sum.OPPORTUNITIES_UPDATED) OPPORTUNITIES_UPDATED,
	sum(agent_sum.OPPORTUNITIES_WON) OPPORTUNITIES_WON,
	sum(agent_sum.OPPORTUNITIES_WON_AMOUNT) OPPORTUNITIES_WON_AMOUNT,
	sum(agent_sum.OPPORTUNITIES_WON_AMOUNT_TXN) OPPORTUNITIES_WON_AMOUNT_TXN,
	sum(agent_sum.OPPORTUNITIES_CROSS_SOLD) OPPORTUNITIES_CROSS_SOLD,
	sum(agent_sum.OPPORTUNITIES_UP_SOLD) OPPORTUNITIES_UP_SOLD,
	sum(agent_sum.OPPORTUNITIES_DECLINED) OPPORTUNITIES_DECLINED,
	sum(agent_sum.OPPORTUNITIES_LOST) OPPORTUNITIES_LOST,
        SUM(agent_sum.OUT_CALLS_DIALED) OUT_CALLS_DIALED,
        SUM(agent_sum.OUT_CONTACT_COUNT) OUT_CONTACT_COUNT,
        SUM(agent_sum.OUT_NON_CONTACT_COUNT) OUT_NON_CONTACT_COUNT,
        SUM(agent_sum.OUT_ABANDON_COUNT) OUT_ABANDON_COUNT,
        SUM(agent_sum.OUT_BUSY_COUNT) OUT_BUSY_COUNT,
        SUM(agent_sum.OUT_RING_NOANSWER_COUNT) OUT_RING_NOANSWER_COUNT,
        SUM(agent_sum.OUT_ANS_MC_COUNT) OUT_ANS_MC_COUNT,
        SUM(agent_sum.OUT_SIT_COUNT) OUT_SIT_COUNT,
        SUM(agent_sum.OUT_POSITIVE_RESPONSE_COUNT) OUT_POSITIVE_RESPONSE_COUNT,
        SUM(agent_sum.OUT_CONNECT_COUNT) OUT_CONNECT_COUNT,
        SUM(agent_sum.OUT_NON_CONNECT_COUNT) OUT_NON_CONNECT_COUNT,
        SUM(agent_sum.OUT_OTHER_OUTCOME_COUNT) OUT_OTHER_OUTCOME_COUNT,
        SUM(agent_sum.OUT_PREVIEW_TIME) OUT_PREVIEW_TIME,
        SUM(agent_sum.OUT_CONTACT_HANDLE_TIME) OUT_CONTACT_HANDLE_TIME
  FROM  bix_dm_agent_sum agent_sum,
      jtf_rs_group_members groups,
      jtf_rs_groups_denorm group_denorm
WHERE agent_sum.period_start_date_time  BETWEEN g_min_call_begin_date AND g_max_call_begin_date
AND   agent_sum.resource_id = groups.resource_id
AND   groups.group_id    = group_denorm.group_id
--
--add the following to take care of cases where
--agent belongs to two groups which roll up to the
--same parent group to avoid duplicating the values
--for the parent group
--
AND   NVL(groups.delete_flag,'N') <> 'Y'
AND   agent_sum.period_start_date_time BETWEEN
NVL(group_denorm.start_date_active,agent_sum.period_start_date_time)
AND NVL(group_denorm.end_date_active,SYSDATE)
AND   groups.group_member_id =
                  (select max(mem1.group_member_id)
                   from jtf_rs_group_members mem1
                   where mem1.group_id in
                     (select den1.group_id
                      from   jtf_rs_groups_denorm den1
                      where  den1.parent_group_id = group_denorm.parent_group_id
                      AND    agent_sum.period_start_date_time BETWEEN
                             NVL(den1.start_date_active,agent_sum.period_start_date_time)
                             AND NVL(den1.end_date_active,SYSDATE)
                      )
                   AND mem1.resource_id = groups.resource_id
                   AND nvl(mem1.delete_flag,'N') <> 'Y'
                   )
GROUP BY group_denorm.parent_group_id,
         agent_sum.SERVER_GROUP_ID,
          agent_sum.CLASSIFICATION_VALUE_ID,
          agent_sum.CAMPAIGN_ID,
          agent_sum.CAMPAIGN_SCHEDULE_ID,
          agent_sum.period_start_date,
          agent_sum.period_start_time,
          agent_sum.PERIOD_START_DATE_TIME;

 l_bix_group_seq number;
 l_num_calls number;

BEGIN

     g_insert_count := 0;
     g_delete_count := 0;

-- IGOR : initialize and check for 'no rows returned'

/* Get the count of rows from the */

      SELECT count(*) INTO   l_num_calls
      FROM   bix_dm_agent_sum where period_start_date_time BETWEEN
      g_min_call_begin_date and g_max_call_begin_date;

	if (l_num_calls > 0) THEN

     IF (g_debug_flag = 'Y') THEN
	     write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.GROUP_SUM: '||' Start Deleting rows in BIM_DM_GROUP_SUM Table', g_proc_name);
     END IF;

-- Delete the rows from summary table for the date range specified

     DELETE_IN_CHUNKS('BIX_DM_GROUP_SUM',
                       'period_start_date_time BETWEEN '||' to_date('||
                        ''''||
                        to_char(g_min_call_begin_date,'YYYY/MM/DDHH24:MI:SS')||
                        ''''||
                        ',''YYYY/MM/DDHH24:MI:SS'') AND '||'to_date('||
                        ''''||
                        to_char(g_max_call_begin_date,'YYYY/MM/DDHH24:MI:SS')||
                        ''''||
                        ',''YYYY/MM/DDHH24:MI:SS'')',
                        g_delete_count);

     --dbms_output.put_line('Deleted count:'||g_delete_count);

     COMMIT;

     IF (g_debug_flag = 'Y') THEN

        write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_GROUP: '||' Finished  Deleting rows in BIX_DM_GROUP_SUM table: ' || 'Row Count:' || g_delete_count, g_proc_name);

        write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.AGENT_SUM: '||' Start inserting rows into BIX_DM_AGENT_SUM table: ', g_proc_name);

     END IF;


	for gr_row in group_data LOOP


	SELECT BIX_DM_GROUP_SUM_S.NEXTVAL INTO l_bix_group_seq FROM DUAL;

     INSERT INTO BIX_DM_GROUP_SUM
        (
        GROUP_SUMMARY_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
         SERVER_GROUP_ID,
         --CLASSIFICATION_ID,
         CLASSIFICATION_VALUE_ID,
         CAMPAIGN_ID,
         CAMPAIGN_SCHEDULE_ID,
         GROUP_ID,
         PERIOD_START_DATE,
         PERIOD_START_TIME,
         PERIOD_START_DATE_TIME,
         IN_CALLS_HANDLED,
          IN_CALLS_HANDLD_GT_THN_X_TIME,
          CALLS_TRANSFERED,
         OUT_CALLS_HANDLED,
          OUT_CALLS_HANDLD_GT_THN_X_TIME,
          IN_TALK_TIME,
          IN_WRAP_TIME,
          OUT_TALK_TIME,
          OUT_WRAP_TIME,
          IN_MIN_TALK_TIME,
          IN_MAX_TALK_TIME,
          OUT_MIN_TALK_TIME,
          OUT_MAX_TALK_TIME,
          IN_MIN_WRAP_TIME,
          IN_MAX_WRAP_TIME,
          OUT_MIN_WRAP_TIME,
          OUT_MAX_WRAP_TIME,
	  SR_CREATED,
	  SR_OPENED,
	  SR_CLOSED,
	  SR_FIRST_CONTACT_CLOSE,
	  SR_ADDITIONAL_INFO_REQUESTED,
	  SR_KB_UPDATES,
	  LEADS_CREATED,
	  LEADS_UPDATED,
	  LEADS_AMOUNT,
	  LEADS_CONVERTED_TO_OPP,
	  LEADS_AMOUNT_TXN,
	  OPPORTUNITIES_CREATED,
	  OPPORTUNITIES_UPDATED,
	  OPPORTUNITIES_WON,
	  OPPORTUNITIES_WON_AMOUNT,
	  OPPORTUNITIES_WON_AMOUNT_TXN,
	  OPPORTUNITIES_CROSS_SOLD,
	  OPPORTUNITIES_UP_SOLD,
	  OPPORTUNITIES_DECLINED,
	  OPPORTUNITIES_LOST,
          OUT_CALLS_DIALED,
          OUT_CONTACT_COUNT,
          OUT_NON_CONTACT_COUNT,
          OUT_ABANDON_COUNT,
          OUT_BUSY_COUNT ,
          OUT_RING_NOANSWER_COUNT,
          OUT_ANS_MC_COUNT ,
          OUT_SIT_COUNT,
          OUT_POSITIVE_RESPONSE_COUNT,
          OUT_CONNECT_COUNT ,
          OUT_NON_CONNECT_COUNT ,
          OUT_OTHER_OUTCOME_COUNT,
		OUT_PREVIEW_TIME,
		OUT_CONTACT_HANDLE_TIME
	)
        VALUES
        (
        l_bix_group_seq,
        SYSDATE,
        g_user_id,
        SYSDATE,
        g_user_id,
        SYSDATE,
        gr_row.SERVER_GROUP_ID,
        gr_row.CLASSIFICATION_VALUE_ID,
         gr_row.CAMPAIGN_ID,
         gr_row.CAMPAIGN_SCHEDULE_ID,
         gr_row.GROUP_ID,
         gr_row.PERIOD_START_DATE,
         gr_row.PERIOD_START_TIME,
         gr_row.PERIOD_START_DATE_TIME,
         gr_row.IN_CALLS_HANDLED,
         gr_row.IN_CALLS_HANDLD_GT_THN_X_TIME,
           gr_row.CALLS_TRANSFERED,
        gr_row.OUT_CALLS_HANDLED,
        gr_row.OUT_CALLS_HANDLD_GT_THN_X_TIME,
           gr_row.IN_TALK_TIME,
           gr_row.IN_WRAP_TIME,
           gr_row.OUT_TALK_TIME,
           gr_row.OUT_WRAP_TIME,
           gr_row.IN_MIN_TALK_TIME,
           gr_row.IN_MAX_TALK_TIME,
           gr_row.OUT_MIN_TALK_TIME,
           gr_row.OUT_MAX_TALK_TIME,
           gr_row.IN_MIN_WRAP_TIME,
           gr_row.IN_MAX_WRAP_TIME,
           gr_row.OUT_MIN_WRAP_TIME,
           gr_row.OUT_MAX_WRAP_TIME,
	   gr_row.SR_CREATED,
	   gr_row.SR_OPENED,
	   gr_row.SR_CLOSED,
	   gr_row.SR_FIRST_CONTACT_CLOSE,
	   gr_row.SR_ADDITIONAL_INFO_REQUESTED,
	   gr_row.SR_KB_UPDATES,
	   gr_row.LEADS_CREATED,
	   gr_row.LEADS_UPDATED,
	   gr_row.LEADS_AMOUNT,
	   gr_row.LEADS_CONVERTED_TO_OPP,
	   gr_row.LEADS_AMOUNT_TXN,
	   gr_row.OPPORTUNITIES_CREATED,
	   gr_row.OPPORTUNITIES_UPDATED,
	   gr_row.OPPORTUNITIES_WON,
	   gr_row.OPPORTUNITIES_WON_AMOUNT,
	   gr_row.OPPORTUNITIES_WON_AMOUNT_TXN,
	   gr_row.OPPORTUNITIES_CROSS_SOLD,
	   gr_row.OPPORTUNITIES_UP_SOLD,
	   gr_row.OPPORTUNITIES_DECLINED,
	   gr_row.OPPORTUNITIES_LOST,
           gr_row.OUT_CALLS_DIALED,
           gr_row.OUT_CONTACT_COUNT,
           gr_row.OUT_NON_CONTACT_COUNT,
           gr_row.OUT_ABANDON_COUNT,
           gr_row.OUT_BUSY_COUNT ,
           gr_row.OUT_RING_NOANSWER_COUNT,
           gr_row.OUT_ANS_MC_COUNT ,
           gr_row.OUT_SIT_COUNT,
           gr_row.OUT_POSITIVE_RESPONSE_COUNT,
           gr_row.OUT_CONNECT_COUNT ,
           gr_row.OUT_NON_CONNECT_COUNT ,
           gr_row.OUT_OTHER_OUTCOME_COUNT,
		 gr_row.OUT_PREVIEW_TIME,
		 gr_row.OUT_CONTACT_HANDLE_TIME
           );

	   commit;

	 g_insert_count := g_insert_count+1;

	END LOOP;
    end if; -- if there are rows in the interface table

EXCEPTION
        WHEN OTHERS THEN

     IF (g_debug_flag = 'Y') THEN

         write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||' BIX_DM_AGENT_SUMMARY_PKG.SUM_GROUP: '|| ' Failed to  Rolled back data in BIX_DM_GROUP_SUM table ', g_proc_name);

     END IF;

        g_proc_name := 'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_GROUP';
        g_error_mesg := g_proc_name ||' : '|| sqlerrm;
	RAISE;

END SUM_GROUP;



-- Summarizing the interface table by call and inserting rows into
-- the BIX_DM_CALL_SUM table

PROCEDURE SUM_CALL AS

CURSOR call_data IS
 SELECT call_stage.SERVER_GROUP_ID SERVER_GROUP_ID,
        --call_stage.CLASSIFICATION_ID CLASSIFICATION_ID,
        call_stage.CLASSIFICATION_VALUE_ID CLASSIFICATION_VALUE_ID,
        call_stage.DNIS DNIS,
	   call_stage.campaign_id CAMPAIGN_ID,
	   call_stage.campaign_schedule_id CAMPAIGN_SCHEDULE_ID,
        call_stage.PERIOD_START_DATE PERIOD_START_DATE,
        call_stage.PERIOD_START_TIME PERIOD_START_TIME,
        call_stage.PERIOD_START_DATE_TIME PERIOD_START_DATE_TIME,
        NVL(SUM(call_stage.IN_CALLS_HANDLED),0) IN_CALLS_HANDLED,
        NVL(SUM(call_stage.IN_CALLS_HANDLD_GT_THN_X_TIME),0) IN_CALLS_HANDLD_GT_THN_X_TIME,
           NVL(SUM(call_stage.CALLS_TRANSFERED),0) CALLS_TRANSFERED,
        NVL(SUM(call_stage.OUT_CALLS_HANDLED),0) OUT_CALLS_HANDLED,
	NVL(SUM(call_stage.OUT_CALLS_HANDLD_GT_THN_X_TIME),0) OUT_CALLS_HANDLD_GT_THN_X_TIME,
           NVL(SUM(NVL(call_stage.IN_TALK_TIME,0)),0) IN_TALK_TIME,
           NVL(SUM(NVL(call_stage.IN_WRAP_TIME,0)),0) IN_WRAP_TIME,
           NVL(SUM(NVL(call_stage.OUT_TALK_TIME,0)),0) OUT_TALK_TIME,
           NVL(SUM(NVL(call_stage.OUT_WRAP_TIME,0)),0) OUT_WRAP_TIME,
	   NVL(SUM(call_stage.CALLS_OFFERED),0) CALLS_OFFERED,
	   NVL(SUM(call_stage.CALLS_IN_QUEUE),0) CALLS_IN_QUEUE,
	   NVL(SUM(call_stage.CALLS_ABANDONED),0) CALLS_ABANDONED,
           NVL(SUM(call_stage.CALLS_ANSWRD_WITHIN_X_TIME),0) CALLS_ANSWRD_WITHIN_X_TIME,
	   NVL(SUM(call_stage.IVR_TIME),0) IVR_TIME,
	   NVL(SUM(call_stage.ROUTE_TIME),0) ROUTE_TIME,
	   NVL(SUM(call_stage.QUEUE_TIME),0) QUEUE_TIME,
	   NVL(SUM(call_stage.ABANDON_TIME),0) ABANDON_TIME,
	   NVL(MIN(call_stage.IVR_TIME),0) MIN_IVR_TIME,
	   NVL(MIN(call_stage.ROUTE_TIME),0) MIN_ROUTE_TIME,
	   NVL(MIN(call_stage.QUEUE_TIME),0) MIN_QUEUE_TIME,
	   NVL(MIN(call_stage.ABANDON_TIME),0) MIN_ABANDON_TIME,
	   NVL(MAX(call_stage.IVR_TIME),0) MAX_IVR_TIME,
	   NVL(MAX(call_stage.ROUTE_TIME),0) MAX_ROUTE_TIME,
	   NVL(MAX(call_stage.QUEUE_TIME),0) MAX_QUEUE_TIME,
	   NVL(MAX(call_stage.ABANDON_TIME),0) MAX_ABANDON_TIME,
	   NVL(SUM(call_stage.SERVICE_REQUESTS_CREATED),0) SR_CREATED,
	   NVL(SUM(call_stage.SERVICE_REQUESTS_OPENED),0) SR_OPENED,
	   NVL(SUM(call_stage.SERVICE_REQUESTS_CLOSED),0) SR_CLOSED,
	   NVL(SUM(call_stage.SERVICE_REQUESTS_CONTACT_CL),0) SR_FIRST_CONTACT_CLOSE,
	   NVL(SUM(call_stage.SERVICE_REQUESTS_INFO_REQ),0) SR_ADDITIONAL_INFO_REQUESTED,
	   NVL(SUM(call_stage.SERVICE_REQUESTS_KB_UPDATES),0) SR_KB_UPDATES,
	   NVL(SUM(call_stage.LEADS_CREATED),0) LEADS_CREATED,
	   NVL(SUM(call_stage.LEADS_UPDATED),0) LEADS_UPDATED,
	   NVL(SUM(call_stage.LEADS_AMOUNT),0) LEADS_AMOUNT,
	   NVL(SUM(call_stage.LEADS_AMOUNT_TXN),0) LEADS_AMOUNT_TXN,
	   NVL(SUM(call_stage.LEADS_CONV_TO_OPP),0) LEADS_CONVERTED_TO_OPP,
	   NVL(SUM(call_stage.OPPORTUNITIES_CREATED),0) OPPORTUNITIES_CREATED,
	   NVL(SUM(call_stage.OPPORTUNITIES_UPDATED),0) OPPORTUNITIES_UPDATED,
	   NVL(SUM(call_stage.OPPORTUNITIES_WON),0) OPPORTUNITIES_WON,
	   NVL(SUM(call_stage.OPPORTUNITIES_WON_AMOUNT),0) OPPORTUNITIES_WON_AMOUNT,
	   NVL(SUM(call_stage.OPPORTUNITIES_WON_AMOUNT_TXN),0) OPPORTUNITIES_WON_AMOUNT_TXN,
	   NVL(SUM(call_stage.OPPORTUNITIES_CROSS_SOLD),0) OPPORTUNITIES_CROSS_SOLD,
	   NVL(SUM(call_stage.OPPORTUNITIES_UP_SOLD),0) OPPORTUNITIES_UP_SOLD,
	   NVL(SUM(call_stage.OPPORTUNITIES_DECLINED),0) OPPORTUNITIES_DECLINED,
	   NVL(SUM(call_stage.OPPORTUNITIES_LOST),0) OPPORTUNITIES_LOST,
           NVL(SUM(decode(call_stage.OPPORTUNITIES_WON,0,0,NULL,0,1)),0) NO_OF_OPP_WON_CALLS,
           SUM(decode(NVL(call_stage.OPPORTUNITIES_WON,0)+NVL(call_stage.OPPORTUNITIES_CROSS_SOLD,0)+NVL(call_stage.OPPORTUNITIES_UP_SOLD,0),0,0,1)) NO_OF_OPP_SOLD_CALLS,
           NVL(SUM(call_stage.QUEUE_TIME_FOR_CALLS_HANDLED),0) QUEUE_TIME_FOR_CALLS_HANDLED,
           NVL(MAX(call_stage.QUEUE_TIME_FOR_CALLS_HANDLED),0) MAX_QUEUE_TIME_CALLS_HANDLD,
           NVL(SUM(call_stage.NUMBER_OF_REROUTS),0) NUMBER_OF_REROUTS,
           SUM(NVL(OUT_CALLS_DIALED,0)) OUT_CALLS_DIALED,
           SUM(NVL(OUT_CONTACT_COUNT,0)) OUT_CONTACT_COUNT,
           SUM(NVL(OUT_NON_CONTACT_COUNT,0)) OUT_NON_CONTACT_COUNT,
           SUM(NVL(OUT_ABANDON_COUNT,0)) OUT_ABANDON_COUNT,
           SUM(NVL(OUT_BUSY_COUNT,0)) OUT_BUSY_COUNT,
           SUM(NVL(OUT_RING_NOANSWER_COUNT,0)) OUT_RING_NOANSWER_COUNT,
           SUM(NVL(OUT_ANS_MC_COUNT,0)) OUT_ANS_MC_COUNT,
           SUM(NVL(OUT_SIT_COUNT,0)) OUT_SIT_COUNT,
           SUM(NVL(OUT_POSITIVE_RESPONSE_COUNT,0)) OUT_POSITIVE_RESPONSE_COUNT,
           SUM(NVL(OUT_CONNECT_COUNT,0)) OUT_CONNECT_COUNT,
           SUM(NVL(OUT_NON_CONNECT_COUNT,0)) OUT_NON_CONNECT_COUNT,
           SUM(NVL(OUT_OTHER_OUTCOME_COUNT,0)) OUT_OTHER_OUTCOME_COUNT,
           SUM(NVL(OUT_CONTACT_HANDLE_TIME,0)) OUT_CONTACT_HANDLE_TIME,
           SUM(NVL(DECODE(ROW_TYPE,'C',OUT_PREVIEW_TIME,0),0)) OUT_PREVIEW_TIME --do only "C" rowtype
FROM  bix_dm_interface call_stage
GROUP BY call_stage.SERVER_GROUP_ID,
          call_stage.CLASSIFICATION_VALUE_ID,
          call_stage.DNIS,
	     call_stage.campaign_id,
	     call_stage.campaign_schedule_id,
          call_stage.period_start_date,
          call_stage.period_start_time,
          call_stage.PERIOD_START_DATE_TIME;

 l_bix_call_seq number;
 l_num_calls number;

BEGIN

     g_insert_count := 0;
     g_delete_count := 0;

-- IGOR : initialize and check for 'no rows returned'

/* Get the count of rows from the */

      SELECT count(*) INTO   l_num_calls
      FROM   bix_dm_interface;

	if (l_num_calls > 0) THEN

     IF (g_debug_flag = 'Y') THEN
	     write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.CALL_SUM: '||' Start Deleting rows in BIM_DM_CALL_SUM Table', g_proc_name);
     END IF;

-- Delete the rows from summary table for the date range specified

     DELETE_IN_CHUNKS('BIX_DM_CALL_SUM',
                       'period_start_date_time BETWEEN '||' to_date('||
                        ''''||
                        to_char(g_min_call_begin_date,'YYYY/MM/DDHH24:MI:SS')||
                        ''''||
                        ',''YYYY/MM/DDHH24:MI:SS'') AND '||'to_date('||
                        ''''||
                        to_char(g_max_call_begin_date,'YYYY/MM/DDHH24:MI:SS')||
                        ''''||
                        ',''YYYY/MM/DDHH24:MI:SS'')',
                        g_delete_count);

     --dbms_output.put_line('Deleted count:'||g_delete_count);

     COMMIT;

     IF (g_debug_flag = 'Y') THEN
     write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.CALL_SUM: '||' Finished  Deleting rows in BIX_DM_CALL_SUM table: ' || 'Row Count:' || g_delete_count, g_proc_name);

     write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_CALL: '||' Start inserting rows into BIX_DM_CALL_SUM table: ', g_proc_name);
     END IF;


	for call_row in call_data LOOP


	SELECT BIX_DM_CALL_SUM_S.NEXTVAL INTO l_bix_call_seq FROM DUAL;

		INSERT INTO BIX_DM_CALL_SUM
		(
		CALL_SUMMARY_ID,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		SERVER_GROUP_ID,
		--CLASSIFICATION_ID,
		CLASSIFICATION_VALUE_ID,
		DNIS_ID,
		CAMPAIGN_ID,
		CAMPAIGN_SCHEDULE_ID,
		PERIOD_START_DATE,
		PERIOD_START_TIME,
		PERIOD_START_DATE_TIME,
		IN_CALLS_HANDLED,
		IN_CALLS_HANDLD_GT_THN_X_TIME,
		CALLS_TRANSFERED,
		OUT_CALLS_HANDLED,
		OUT_CALLS_HANDLD_GT_THN_X_TIME,
		IN_TALK_TIME,
		IN_WRAP_TIME,
		OUT_TALK_TIME,
		OUT_WRAP_TIME,
		CALLS_OFFERED,
		CALLS_IN_QUEUE,
		CALLS_ABANDONED,
		CALLS_ANSWRD_WITHIN_X_TIME,
		IVR_TIME,
		ROUTE_TIME,
		QUEUE_TIME,
		ABANDON_TIME,
		MIN_IVR_TIME,
		MIN_ROUTE_TIME,
		MIN_QUEUE_TIME,
		MIN_ABANDON_TIME,
		MAX_IVR_TIME,
		MAX_ROUTE_TIME,
		MAX_QUEUE_TIME,
		MAX_ABANDON_TIME,
		SR_CREATED,
		SR_OPENED,
		SR_CLOSED,
		SR_FIRST_CONTACT_CLOSE,
		SR_ADDITIONAL_INFO_REQUESTED,
		SR_KB_UPDATES,
		LEADS_CREATED,
		LEADS_UPDATED,
		LEADS_AMOUNT,
		LEADS_CONVERTED_TO_OPP,
		OPPORTUNITIES_CREATED,
		OPPORTUNITIES_UPDATED,
		OPPORTUNITIES_WON,
		OPPORTUNITIES_WON_AMOUNT,
		OPPORTUNITIES_CROSS_SOLD,
		OPPORTUNITIES_UP_SOLD,
		OPPORTUNITIES_DECLINED,
		OPPORTUNITIES_LOST,
		NO_OF_OPP_WON_CALLS,
		NO_OF_OPP_SOLD_CALLS,
		CALLS_OFFRD_GT_THN_X_TIME,
		QUEUE_TIME_FOR_CALLS_HANDLED,
		MAX_QUEUE_TIME_CALLS_HANDLD,
		NUMBER_OF_REROUTES,
		LEADS_AMOUNT_TXN,
		OPPORTUNITIES_WON_AMOUNT_TXN,
                OUT_CALLS_DIALED,
                OUT_CONTACT_COUNT,
                OUT_NON_CONTACT_COUNT,
                OUT_ABANDON_COUNT,
                OUT_BUSY_COUNT ,
                OUT_RING_NOANSWER_COUNT,
                OUT_ANS_MC_COUNT ,
                OUT_SIT_COUNT,
                OUT_POSITIVE_RESPONSE_COUNT,
                OUT_CONNECT_COUNT ,
                OUT_NON_CONNECT_COUNT ,
                OUT_OTHER_OUTCOME_COUNT,
                OUT_CONTACT_HANDLE_TIME,
                OUT_PREVIEW_TIME
		)
		VALUES
		(
		l_bix_call_seq,
		SYSDATE,
		g_user_id,
		SYSDATE,
		g_user_id,
		SYSDATE,
		call_row.SERVER_GROUP_ID,
		call_row.CLASSIFICATION_VALUE_ID,
		call_row.DNIS,
		call_row.CAMPAIGN_ID,
		call_row.CAMPAIGN_SCHEDULE_ID,
		call_row.PERIOD_START_DATE,
		call_row.PERIOD_START_TIME,
		call_row.PERIOD_START_DATE_TIME,
		call_row.IN_CALLS_HANDLED,
		call_row.IN_CALLS_HANDLD_GT_THN_X_TIME,
		call_row.CALLS_TRANSFERED,
		call_row.OUT_CALLS_HANDLED,
		call_row.OUT_CALLS_HANDLD_GT_THN_X_TIME,
		call_row.IN_TALK_TIME,
		call_row.IN_WRAP_TIME,
		call_row.OUT_TALK_TIME,
		call_row.OUT_WRAP_TIME,
		call_row.CALLS_OFFERED,
		call_row.CALLS_IN_QUEUE,
		call_row.CALLS_ABANDONED,
		call_row.CALLS_ANSWRD_WITHIN_X_TIME,
		call_row.IVR_TIME,
		call_row.ROUTE_TIME,
		call_row.QUEUE_TIME,
		call_row.ABANDON_TIME,
		call_row.MIN_IVR_TIME,
		call_row.MIN_ROUTE_TIME,
		call_row.MIN_QUEUE_TIME,
		call_row.MIN_ABANDON_TIME,
		call_row.MAX_IVR_TIME,
		call_row.MAX_ROUTE_TIME,
		call_row.MAX_QUEUE_TIME,
		call_row.MAX_ABANDON_TIME,
		call_row.SR_CREATED,
		call_row.SR_OPENED,
		call_row.SR_CLOSED,
		call_row.SR_FIRST_CONTACT_CLOSE,
		call_row.SR_ADDITIONAL_INFO_REQUESTED,
		call_row.SR_KB_UPDATES,
		call_row.LEADS_CREATED,
		call_row.LEADS_UPDATED,
		call_row.LEADS_AMOUNT,
		call_row.LEADS_CONVERTED_TO_OPP,
		call_row.OPPORTUNITIES_CREATED,
		call_row.OPPORTUNITIES_UPDATED,
		call_row.OPPORTUNITIES_WON,
		call_row.OPPORTUNITIES_WON_AMOUNT,
		call_row.OPPORTUNITIES_CROSS_SOLD,
		call_row.OPPORTUNITIES_UP_SOLD,
		call_row.OPPORTUNITIES_DECLINED,
		call_row.OPPORTUNITIES_LOST,
		call_row.NO_OF_OPP_WON_CALLS,
		call_row.NO_OF_OPP_SOLD_CALLS,
		call_row.IN_CALLS_HANDLD_GT_THN_X_TIME + call_row.CALLS_ABANDONED,
		call_row.QUEUE_TIME_FOR_CALLS_HANDLED,
		call_row.MAX_QUEUE_TIME_CALLS_HANDLD,
		call_row.NUMBER_OF_REROUTS,
		call_row.LEADS_AMOUNT_TXN,
		call_row.OPPORTUNITIES_WON_AMOUNT_TXN,
                call_row.OUT_CALLS_DIALED,
                call_row.OUT_CONTACT_COUNT,
                call_row.OUT_NON_CONTACT_COUNT,
                call_row.OUT_ABANDON_COUNT,
                call_row.OUT_BUSY_COUNT ,
                call_row.OUT_RING_NOANSWER_COUNT,
                call_row.OUT_ANS_MC_COUNT ,
                call_row.OUT_SIT_COUNT,
                call_row.OUT_POSITIVE_RESPONSE_COUNT,
                call_row.OUT_CONNECT_COUNT ,
                call_row.OUT_NON_CONNECT_COUNT ,
                call_row.OUT_OTHER_OUTCOME_COUNT,
                call_row.OUT_CONTACT_HANDLE_TIME,
                call_row.OUT_PREVIEW_TIME
		);

		commit;

		g_insert_count := g_insert_count+1;

	END LOOP;
    end if; -- if there are rows in the interface table

EXCEPTION
        WHEN OTHERS THEN
        IF (g_debug_flag = 'Y') THEN
            write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||' BIX_DM_AGENT_SUMMARY_PKG.SUM_CALL: '|| ' Failed to  Rolled back data in BIX_DM_CALL_SUM table ', g_proc_name);
        END IF;

        g_proc_name := 'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_CALL';
        g_error_mesg := g_proc_name ||' : '|| sqlerrm;
	RAISE;

END SUM_CALL;

/******************************************************************************************
 *
 *SUM_AGENT_OUTCOME will populate the BIX_DM_AGENT_OUTCOME_SUM table.
 *
 *****************************************************************************************/

-- Summarizing the interface table by and inserting into the
-- the BIX_DM_AGENT_OUTCOME_SUM table

PROCEDURE SUM_AGENT_OUTCOME AS

CURSOR outcome_data IS
 SELECT call_stage.campaign_id                 CAMPAIGN_ID,
	   call_stage.campaign_schedule_id        CAMPAIGN_SCHEDULE_ID,
	   call_stage.SERVER_GROUP_ID             SERVER_GROUP_ID,
	   nvl(call_stage.resource_id,-999)       RESOURCE_ID,
	   call_stage.period_start_date           PERIOD_START_DATE,
	   call_stage.period_start_time           PERIOD_START_TIME,
	   call_stage.period_start_date_time      PERIOD_START_DATE_TIME,
	   'OUTBOUND'                             DIRECTION,
	   call_stage.OUTCOME_ID                  OUTCOME_ID,
	   call_stage.RESULT_ID                   RESULT_ID,
	   call_stage.REASON_ID                   REASON_ID,
	   clook.connect_flag                     CONNECT_FLAG,
	   clook.contact_flag                     CONTACT_FLAG,
	   rlook.positive_response_flag           POSITIVE_RESPONSE_FLAG,
	   sum(call_stage.OUT_CALLS_DIALED)       NUMBER_OF_CALLS
FROM    bix_dm_interface call_stage,
	   bix_dm_connect_lookups clook,
	   bix_dm_response_lookups rlook
WHERE   clook.outcome_id (+) = call_stage.outcome_id
--AND     rlook.outcome_id (+) = call_stage.outcome_id
AND     rlook.result_id  (+) = call_stage.result_id
AND     call_stage.row_type IN ('C', 'A')   --ignore activity type rows
AND     call_stage.direction = '1'          --only OUTBOUND calls
GROUP BY call_stage.campaign_id,
         call_stage.campaign_schedule_id,
         call_stage.SERVER_GROUP_ID,
         nvl(call_stage.resource_id,-999),
         call_stage.period_start_date,
         call_stage.period_start_time,
         call_stage.period_start_date_time,
         'OUTBOUND',
         call_stage.OUTCOME_ID,
         call_stage.RESULT_ID,
         call_stage.REASON_ID,
         clook.connect_flag,
         clook.contact_flag,
         rlook.positive_response_flag;

 l_bix_call_seq number;
 l_num_calls number;

BEGIN

     g_insert_count := 0;
     g_delete_count := 0;

     IF (g_debug_flag = 'Y') THEN
        write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_AGENT_OUTCOME: Entered procedure', g_proc_name);
     END IF;


/* Get the count of rows from the */

      SELECT count(*) INTO   l_num_calls
      FROM   bix_dm_interface;

     IF (g_debug_flag = 'Y') THEN
     write_log('No of rows in injterface table is ' ||l_num_calls, g_proc_name);
     END IF;

	if (l_num_calls > 0) THEN

     IF (g_debug_flag = 'Y') THEN
	     write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_AGENT_OUTCOME: '||' Start Deleting rows in BIM_DM_AGENT_OUTCOME_SUM Table', g_proc_name);
     END IF;

-- Delete the rows from summary table for the date range specified

     DELETE_IN_CHUNKS('BIX_DM_AGENT_OUTCOME_SUM',
                       'period_start_date_time BETWEEN '||' to_date('||
                        ''''||
                        to_char(g_min_call_begin_date,'YYYY/MM/DDHH24:MI:SS')||
                        ''''||
                        ',''YYYY/MM/DDHH24:MI:SS'') AND '||'to_date('||
                        ''''||
                        to_char(g_max_call_begin_date,'YYYY/MM/DDHH24:MI:SS')||
                        ''''||
                        ',''YYYY/MM/DDHH24:MI:SS'')',
                        g_delete_count);

     --dbms_output.put_line('Deleted count:'||g_delete_count);

     COMMIT;

     IF (g_debug_flag = 'Y') THEN

     write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_AGENT_OUTCOME: '||' Finished  Deleting rows in BIX_DM_AGENT_OUTCOME_SUM table: ' || 'Row Count:' || g_delete_count, g_proc_name);

     write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_AGENT_OUTCOME: '||' Start inserting rows into BIX_DM_AGENT_OUTCOME_SUM table: ', g_proc_name);

     END IF;


	for outcome_row in outcome_data LOOP

		INSERT INTO BIX_DM_AGENT_OUTCOME_SUM
		(
		AGENT_OUTCOME_SUM_ID,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		CAMPAIGN_ID,
		CAMPAIGN_SCHEDULE_ID,
		SERVER_GROUP_ID,
		DIRECTION,
		RESOURCE_ID,
		PERIOD_START_DATE,
		PERIOD_START_TIME,
		PERIOD_START_DATE_TIME,
		OUTCOME_ID,
		RESULT_ID,
		REASON_ID,
		CONNECT_FLAG,
		CONTACT_FLAG,
		POSITIVE_RESPONSE_FLAG,
		NUMBER_OF_CALLS
		)
		VALUES
		(
		BIX_DM_AGENT_OUTCOME_SUM_S.NEXTVAL,
		SYSDATE,
		g_user_id,
		SYSDATE,
		g_user_id,
		g_user_id,
		outcome_row.CAMPAIGN_ID,
		outcome_row.CAMPAIGN_SCHEDULE_ID,
		outcome_row.SERVER_GROUP_ID,
		outcome_row.DIRECTION,
		outcome_row.RESOURCE_ID,
		outcome_row.PERIOD_START_DATE,
		outcome_row.PERIOD_START_TIME,
		outcome_row.PERIOD_START_DATE_TIME,
		outcome_row.OUTCOME_ID,
		outcome_row.RESULT_ID,
		outcome_row.REASON_ID,
		outcome_row.CONNECT_FLAG,
		outcome_row.CONTACT_FLAG,
		outcome_row.POSITIVE_RESPONSE_FLAG,
		outcome_row.NUMBER_OF_CALLS
		);

		commit;

		g_insert_count := g_insert_count+1;

	END LOOP;
    end if; -- if there are rows in the interface table

     IF (g_debug_flag = 'Y') THEN

        write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_AGENT_OUTCOME: Ended procedure', g_proc_name);

     END IF;

EXCEPTION
        WHEN OTHERS THEN

     IF (g_debug_flag = 'Y') THEN
        write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_AGENT_OUTCOME: Exception ', g_proc_name);
     END IF;

        g_proc_name := 'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_AGENT_OUTCOME';
        g_error_mesg := g_proc_name ||' : '|| sqlerrm;
	RAISE;

END SUM_AGENT_OUTCOME;



/******************End SUM_AGENT_OUTCOME **************************************************/

/******************************************************************************************
 *
 *SUM_GROUP_OUTCOME will populate the BIX_DM_GROUP_OUTCOME_SUM table.
 *
 *****************************************************************************************/


-- Summarizing the interface table by and inserting into the
-- the BIX_DM_GROUP_OUTCOME_SUM table

PROCEDURE SUM_GROUP_OUTCOME AS

CURSOR outcome_data IS
 SELECT call_stage.campaign_id                 CAMPAIGN_ID,
	   call_stage.campaign_schedule_id        CAMPAIGN_SCHEDULE_ID,
	   call_stage.SERVER_GROUP_ID             SERVER_GROUP_ID,
	   group_denorm.parent_group_id           GROUP_ID,
	   call_stage.period_start_date           PERIOD_START_DATE,
	   call_stage.period_start_time           PERIOD_START_TIME,
	   call_stage.period_start_date_time      PERIOD_START_DATE_TIME,
	   call_stage.direction                   DIRECTION,
	   call_stage.OUTCOME_ID                  OUTCOME_ID,
	   call_stage.RESULT_ID                   RESULT_ID,
	   call_stage.REASON_ID                   REASON_ID,
	   call_stage.connect_flag                CONNECT_FLAG,
	   call_stage.contact_flag                CONTACT_FLAG,
	   call_stage.positive_response_flag      POSITIVE_RESPONSE_FLAG,
	   sum(call_stage.number_of_calls)        NUMBER_OF_CALLS
FROM    bix_dm_agent_outcome_sum call_stage,
	   jtf_rs_group_members groups,
	   jtf_rs_groups_denorm group_denorm
WHERE   call_stage.resource_id = groups.resource_id
AND     call_stage.period_start_date_time BETWEEN g_min_call_begin_date AND g_max_call_begin_date
AND     groups.group_id    = group_denorm.group_id
AND     call_stage.resource_id IS NOT NULL
--
--add the following to take care of cases where
--agent belongs to two groups which roll up to the
--same parent group to avoid duplicating the values
--for the parent group
--
AND   NVL(groups.delete_flag,'N') <> 'Y'
AND   call_stage.period_start_date_time BETWEEN
NVL(group_denorm.start_date_active,call_stage.period_start_date_time)
AND NVL(group_denorm.end_date_active,SYSDATE)
AND   groups.group_member_id =
                  (select max(mem1.group_member_id)
                   from jtf_rs_group_members mem1
                   where mem1.group_id in
                     (select den1.group_id
                      from   jtf_rs_groups_denorm den1
                      where  den1.parent_group_id = group_denorm.parent_group_id
                      AND   call_stage.period_start_date_time BETWEEN
                            NVL(den1.start_date_active,call_stage.period_start_date_time)
                            AND NVL(den1.end_date_active,SYSDATE)
                      )
                   AND mem1.resource_id = groups.resource_id
                   AND nvl(mem1.delete_flag,'N') <> 'Y'
			    )
GROUP BY call_stage.campaign_id,
         call_stage.campaign_schedule_id,
         call_stage.SERVER_GROUP_ID,
         group_denorm.parent_group_id,
         call_stage.period_start_date,
         call_stage.period_start_time,
         call_stage.period_start_date_time,
         call_stage.direction,
         call_stage.OUTCOME_ID,
         call_stage.RESULT_ID,
         call_stage.REASON_ID,
         call_stage.connect_flag,
         call_stage.contact_flag,
         call_stage.positive_response_flag
UNION
 SELECT call_stage.campaign_id                 CAMPAIGN_ID,
	   call_stage.campaign_schedule_id        CAMPAIGN_SCHEDULE_ID,
	   call_stage.SERVER_GROUP_ID             SERVER_GROUP_ID,
	   -999,                                                         --calls with no agents
	   call_stage.period_start_date           PERIOD_START_DATE,
	   call_stage.period_start_time           PERIOD_START_TIME,
	   call_stage.period_start_date_time      PERIOD_START_DATE_TIME,
	   call_stage.direction                   DIRECTION,
	   call_stage.OUTCOME_ID                  OUTCOME_ID,
	   call_stage.RESULT_ID                   RESULT_ID,
	   call_stage.REASON_ID                   REASON_ID,
	   call_stage.connect_flag                CONNECT_FLAG,
	   call_stage.contact_flag                CONTACT_FLAG,
	   call_stage.positive_response_flag      POSITIVE_RESPONSE_FLAG,
	   sum(call_stage.number_of_calls)        NUMBER_OF_CALLS
FROM    bix_dm_agent_outcome_sum call_stage
WHERE   call_stage.resource_id IS NULL                                  --calls with no agents
AND     call_stage.period_start_date_time BETWEEN g_min_call_begin_date AND g_max_call_begin_date
GROUP BY call_stage.campaign_id,
         call_stage.campaign_schedule_id,
         call_stage.SERVER_GROUP_ID,
         -999,
         call_stage.period_start_date,
         call_stage.period_start_time,
         call_stage.period_start_date_time,
         call_stage.direction,
         call_stage.OUTCOME_ID,
         call_stage.RESULT_ID,
         call_stage.REASON_ID,
         call_stage.connect_flag,
         call_stage.contact_flag,
         call_stage.positive_response_flag
;


 l_bix_call_seq number;
 l_num_calls number;

BEGIN

     g_insert_count := 0;
     g_delete_count := 0;

/* Get the count of rows from the */

      SELECT count(*) INTO   l_num_calls
      FROM   bix_dm_interface;

	if (l_num_calls > 0) THEN

     IF (g_debug_flag = 'Y') THEN
	     write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_GROUP_OUTCOME: '||' Start Deleting rows in BIM_DM_GROUP_OUTCOME_SUM Table', g_proc_name);
     END IF;

-- Delete the rows from summary table for the date range specified

     DELETE_IN_CHUNKS('BIX_DM_GROUP_OUTCOME_SUM',
                       'period_start_date_time BETWEEN '||' to_date('||
                        ''''||
                        to_char(g_min_call_begin_date,'YYYY/MM/DDHH24:MI:SS')||
                        ''''||
                        ',''YYYY/MM/DDHH24:MI:SS'') AND '||'to_date('||
                        ''''||
                        to_char(g_max_call_begin_date,'YYYY/MM/DDHH24:MI:SS')||
                        ''''||
                        ',''YYYY/MM/DDHH24:MI:SS'')',
                        g_delete_count);

     --dbms_output.put_line('Deleted count:'||g_delete_count);

     COMMIT;

     IF (g_debug_flag = 'Y') THEN
     write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_GROUP_OUTCOME: '||' Finished  Deleting rows in BIX_DM_GROUP_OUTCOME_SUM table: ' || 'Row Count:' || g_delete_count, g_proc_name);

     write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_GROUP_OUTCOME: '||' Start inserting rows into BIX_DM_GROUP_OUTCOME_SUM table: ', g_proc_name);
     END IF;


	for outcome_row in outcome_data LOOP

		INSERT INTO BIX_DM_GROUP_OUTCOME_SUM
		(
		GROUP_OUTCOME_SUM_ID,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		CAMPAIGN_ID,
		CAMPAIGN_SCHEDULE_ID,
		SERVER_GROUP_ID,
		DIRECTION,
		GROUP_ID,
		PERIOD_START_DATE,
		PERIOD_START_TIME,
		PERIOD_START_DATE_TIME,
		OUTCOME_ID,
		RESULT_ID,
		REASON_ID,
		CONNECT_FLAG,
		CONTACT_FLAG,
		POSITIVE_RESPONSE_FLAG,
		NUMBER_OF_CALLS
		)
		VALUES
		(
		BIX_DM_GROUP_OUTCOME_SUM_S.NEXTVAL,
		SYSDATE,
		g_user_id,
		SYSDATE,
		g_user_id,
		g_user_id,
		outcome_row.CAMPAIGN_ID,
		outcome_row.CAMPAIGN_SCHEDULE_ID,
		outcome_row.SERVER_GROUP_ID,
		outcome_row.DIRECTION,
		outcome_row.GROUP_ID,
		outcome_row.PERIOD_START_DATE,
		outcome_row.PERIOD_START_TIME,
		outcome_row.PERIOD_START_DATE_TIME,
		outcome_row.OUTCOME_ID,
		outcome_row.RESULT_ID,
		outcome_row.REASON_ID,
		outcome_row.CONNECT_FLAG,
		outcome_row.CONTACT_FLAG,
		outcome_row.POSITIVE_RESPONSE_FLAG,
		outcome_row.NUMBER_OF_CALLS
		);

		commit;

		g_insert_count := g_insert_count+1;

	END LOOP;
    end if; -- if there are rows in the interface table

EXCEPTION
        WHEN OTHERS THEN

        IF (g_debug_flag = 'Y') THEN
         write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||' BIX_DM_AGENT_SUMMARY_PKG.SUM_GROUP_OUTCOME: '|| ' Failed to  Roll back data in BIX_DM_GROUP_OUTCOME_SUM table ', g_proc_name);
        END IF;

        g_proc_name := 'BIX_DM_AGENT_CALL_SUMMARY_PKG.SUM_GROUP_OUTCOME';
        g_error_mesg := g_proc_name ||' : '|| sqlerrm;
	RAISE;

END SUM_GROUP_OUTCOME;



/******************End SUM_GROUP_OUTCOME **************************************************/









/*========================================================================================================+
| COLLECT_CALLS_SUMMARY procedure is main procedure calls other procedures to collect the data            |
| The following procedures are invoked from this procedure to collect the data.                           |
| 1. GET_CALLS  	      : Which populates the BIX_DM_INTERFACE staging table                        |
| 2. AGENT_SUM                : Summarizes agent data and inserts it into the BIX_DM_AGENT_SUM table      |
| 3. GROUP_SUM                : Summarizes agent group data and inserts it into the BIX_DM_GROUP_SUM table|
| 4. BIX_POP_AO_SUM_PKG.populate: Summarizes adv. outbound data and inserts it into the BIX_DM_AO_SUM tbl |
| 5. CALL_SUM                 : Summarizes call data and inserts it into the BIX_DM_CALL_SUM table        |
|                                                                                                         |
| The procedure 1 populates BIX_DM_INTERFACE staging table, the others use the staging table to populate  |
| the other tables. After each procedure the insert_log procedure is called to insert the table data into |
| the log table BIX_DM_COLLECT_LOG.                                                                       |
| There are two versions of this procedure, one called from the concurrent manager and the other callable |
| from sqlplus for debugging purposses. The version below is the one callable from sqlplus.               |
========================================================================================================+*/

PROCEDURE COLLECT_CALLS_SUMMARY(p_start_date IN VARCHAR2,p_end_date   IN VARCHAR2)
AS
l_collect_end_date date;
l_collect_start_date date;
  BEGIN
 /* intialize all global variables */

  g_request_id       := FND_GLOBAL.CONC_REQUEST_ID();
  g_program_appl_id  := FND_GLOBAL.PROG_APPL_ID();
  g_program_id       := FND_GLOBAL.CONC_PROGRAM_ID();
  g_user_id          := FND_GLOBAL.USER_ID();
  g_insert_count     := 0;
  g_delete_count     := 0;
  g_program_start_date := SYSDATE;
  g_error_mesg       := NULL;
  g_status	     := 'FAILED';
  g_table_name	     := 'BIX_DM_INTERFACE';
  g_proc_name := 'BIX_DM_AGENT_CALL_SUMMARY_PKG.COLLECT_CALLS_SUMMARY';

  IF (FND_PROFILE.DEFINED('BIX_DM_PREFERRED_CURRENCY')) THEN
	g_preferred_currency := FND_PROFILE.VALUE('BIX_DM_PREFERRED_CURRENCY');
  ELSE
	g_preferred_currency := 'USD';
  END IF;

  IF (FND_PROFILE.DEFINED('BIX_DM_CURR_CONVERSION_TYPE')) THEN
	g_conversion_type := FND_PROFILE.VALUE('BIX_DM_CURR_CONVERSION_TYPE');
  ELSE
	g_preferred_currency := 'Corporate';
  END IF;

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

      l_collect_start_date := g_collect_start_date;
      l_collect_end_date := g_collect_end_date;



      IF (FND_PROFILE.DEFINED('BIX_DM_DELETE_SIZE')) THEN
          g_commit_chunk_size := TO_NUMBER(FND_PROFILE.VALUE('BIX_DM_DELETE_SIZE'));
      ELSE
          g_commit_chunk_size := 100;
      END IF;

  IF (FND_PROFILE.DEFINED('BIX_DBI_DEBUG')) THEN
    g_debug_flag := nvl(FND_PROFILE.VALUE('BIX_DBI_DEBUG'), 'N');
  ELSE
    g_debug_flag := 'N';
  END IF;

    /* Delete the rows from BIX_DM_EXCEL table which are older than 2 hours */

     IF (g_debug_flag = 'Y') THEN
        write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||' Start delete of BIX_DM_EXCEL table', g_proc_name);
     END IF;

     DELETE_IN_CHUNKS('BIX_DM_EXCEL',' creation_date < SYSDATE-2/24',g_delete_count);
     COMMIT;

     IF (g_debug_flag = 'Y') THEN
        write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||' End delete of BIX_DM_EXCEL table ' || g_delete_count, g_proc_name);
     END IF;

      loop
		if (g_collect_end_date - g_collect_start_date) > 1 then
			g_collect_end_date := g_collect_start_date + 1;
		end if;

		-- do the thing with g_collect_end_date and g_collect_start_date:


		/* Round the Collection start date nearest lower time bucket. ex: if time is between 10:00 and 10:29
		   round it to 10:00.
		*/

		SELECT TO_DATE(
			TO_CHAR(g_collect_start_date,'YYYY/MM/DD')||
			LPAD(TO_CHAR(g_collect_start_date,'HH24:'),3,'0')||
			DECODE(SIGN(TO_NUMBER(TO_CHAR(g_collect_start_date,'MI'))-29),0,'00:00',1,'30:00',-1,'00:00'),
			'YYYY/MM/DDHH24:MI:SS')
		INTO g_rounded_collect_start_date
		FROM DUAL;


		/* Round the Collection end date to nearest higher time bucket. ex: if time is between 10:00 and 10:29
		   round it to 10:29:59
		*/

		SELECT TO_DATE(
			TO_CHAR(g_collect_end_date,'YYYY/MM/DD')||
			LPAD(TO_CHAR(g_collect_end_date,'HH24:'),3,'0')||
			DECODE(SIGN(TO_NUMBER(TO_CHAR(g_collect_end_date,'MI'))-29),0,'29:59',1,'59:59',-1,'29:59'),
			'YYYY/MM/DDHH24:MI:SS')
		INTO g_rounded_collect_end_date
		FROM DUAL;


		/* Procedure collect calls from OLTP to the temporary table BIX_DM_INTERFACE: */
		  GET_CALLS;
		  g_status := 'SUCCESS';
		  g_table_name := 'BIX_DM_INTERFACE';
		  insert_log;

		/* Procedure collects all the calls information for the AGENT data */

		  --dbms_output.put_line('calling SUM_AGENT');
		  SUM_AGENT;

		  g_status := 'SUCCESS';
		  g_table_name := 'BIX_DM_AGENT_SUM';
		  insert_log;

		/* Procedure collects all the calls information for the GROUP data */

		  SUM_GROUP;
		  g_status := 'SUCCESS';
		  g_table_name := 'BIX_DM_GROUP_SUM';
		  insert_log;

		/* Procedure collects all the calls information for the GROUP data */

		  SUM_CALL;
		  g_status := 'SUCCESS';
		  g_table_name := 'BIX_DM_CALL_SUM';
		  insert_log;

		/* Advanced Outbound Data Population */

		--if upper(is_oao_installed) = 'Y' then
		  --BIX_POP_AO_SUM_PKG.populate(g_min_call_begin_date, g_max_call_begin_date);
		--end if;

		/* Procedure collects all the outcomes information for the AGENT data */

     IF (g_debug_flag = 'Y') THEN
        write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||' Calling procedure SUM_AGENT_OUTCOME', g_proc_name);
     END IF;

		  SUM_AGENT_OUTCOME;

		  g_status := 'SUCCESS';
		  g_table_name := 'BIX_DM_AGENT_OUTCOME_SUM';
		  insert_log;

		/* Procedure collects all the outcomes information for the GROUP data */

     IF (g_debug_flag = 'Y') THEN
        write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||' Calling procedure SUM_GROUP_OUTCOME', g_proc_name);
     END IF;

		  SUM_GROUP_OUTCOME;

		  g_status := 'SUCCESS';
		  g_table_name := 'BIX_DM_GROUP_OUTCOME_SUM';
		  insert_log;

		/* Cleanup: Delete all from the BIX_DM_INTERFACE table */

		  -- DELETE_IN_CHUNKS('BIX_DM_INTERFACE',NULL,g_delete_count);
		  -- g_insert_count := 0;
		  -- g_status := 'SUCCESS';
		  -- g_table_name := 'BIX_DM_INTERFACE';
		  -- insert_log;

		g_collect_start_date := g_collect_end_date;

		if (l_collect_end_date - g_collect_end_date) > 1 then
			g_collect_end_date := g_collect_end_date + 1;
		elsif ((l_collect_end_date - g_collect_end_date) > 0) and
			((l_collect_end_date - g_collect_end_date) <= 1) then
			g_collect_end_date := l_collect_end_date;
		else
			exit;
		end if;


      end loop;

EXCEPTION
   WHEN G_DATE_MISMATCH THEN
     IF (g_debug_flag = 'Y') THEN
        write_log('Collect Start Date cannot be greater than collection end date', g_proc_name);
     END IF;
WHEN OTHERS THEN
	g_status := 'FAILED';
     IF (g_debug_flag = 'Y') THEN
        write_log(g_error_mesg, g_proc_name);
     END IF;
	insert_log;
END COLLECT_CALLS_SUMMARY;

/*========================================================================================================+
| COLLECT_CALLS_SUMMARY procedure is main procedure calls other procedures to collect the data            |
| The following procedures are invoked from this procedure to collect the data.                           |
| 1. GET_CALLS  	      : Which populates the BIX_DM_INTERFACE staging table                        |
| 2. AGENT_SUM                : Summarizes agent data and inserts it into the BIX_DM_AGENT_SUM table      |
| 3. GROUP_SUM                : Summarizes agent group data and inserts it into the BIX_DM_GROUP_SUM table|
| 4. BIX_POP_AO_SUM_PKG.populate: Summarizes adv. outbound data and inserts it into the BIX_DM_AO_SUM tbl |
| 5. CALL_SUM                 : Summarizes call data and inserts it into the BIX_DM_CALL_SUM table        |
|                                                                                                         |
| The procedure 1 populates BIX_DM_INTERFACE staging table, the others use the staging table to populate  |
| the other tables. After each procedure the insert_log procedure is called to insert the table data into |
| the log table BIX_DM_COLLECT_LOG.                                                                       |
| There are two versions of this procedure, one called from the concurrent manager and the other callable |
| from sqlplus for debugging purposses. The version below is the one called from the concurrent manager.  |
========================================================================================================+*/

PROCEDURE COLLECT_CALLS_SUMMARY(errbuf out nocopy varchar2, retcode out nocopy varchar2, p_start_date IN VARCHAR2, p_end_date   IN VARCHAR2)
AS
  l_collect_start_date date;
  l_collect_end_date date;
  BEGIN

 /* intialize all global variables */

  g_request_id       := FND_GLOBAL.CONC_REQUEST_ID();
  g_program_appl_id  := FND_GLOBAL.PROG_APPL_ID();
  g_program_id       := FND_GLOBAL.CONC_PROGRAM_ID();
  g_user_id          := FND_GLOBAL.USER_ID();
  g_insert_count     := 0;
  g_delete_count     := 0;
  g_program_start_date := SYSDATE;
  g_error_mesg       := NULL;
  g_status	     := 'FAILED';
  g_table_name	     := 'BIX_DM_INTERFACE';
  g_proc_name := 'BIX_DM_AGENT_CALL_SUMMARY_PKG.COLLECT_CALLS_SUMMARY';

  IF (FND_PROFILE.DEFINED('BIX_DM_PREFERRED_CURRENCY')) THEN
	g_preferred_currency := FND_PROFILE.VALUE('BIX_DM_PREFERRED_CURRENCY');
  ELSE
	g_preferred_currency := 'USD';
  END IF;

  IF (FND_PROFILE.DEFINED('BIX_DM_CURR_CONVERSION_TYPE')) THEN
	g_conversion_type := FND_PROFILE.VALUE('BIX_DM_CURR_CONVERSION_TYPE');
  ELSE
	g_preferred_currency := 'Corporate';
  END IF;

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

      l_collect_start_date := g_collect_start_date;
      l_collect_end_date := g_collect_end_date;


      IF (FND_PROFILE.DEFINED('BIX_DM_DELETE_SIZE')) THEN
       g_commit_chunk_size := TO_NUMBER(FND_PROFILE.VALUE('BIX_DM_DELETE_SIZE'));
      ELSE
         g_commit_chunk_size := 100;
     END IF;

  IF (FND_PROFILE.DEFINED('BIX_DBI_DEBUG')) THEN
    g_debug_flag := nvl(FND_PROFILE.VALUE('BIX_DBI_DEBUG'), 'N');
  ELSE
    g_debug_flag := 'N';
  END IF;

    /* Delete the rows from BIX_DM_EXCEL table which are older than 2 hours */

     IF (g_debug_flag = 'Y') THEN
        write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||' Start delete of BIX_DM_EXCEL table', g_proc_name);
     END IF;

     DELETE_IN_CHUNKS('BIX_DM_EXCEL',' creation_date < SYSDATE-2/24',g_delete_count);
     COMMIT;

     IF (g_debug_flag = 'Y') THEN
        write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||' End delete of BIX_DM_EXCEL table ' || g_delete_count, g_proc_name);
     END IF;

      loop
		if (g_collect_end_date - g_collect_start_date) > 1 then
			g_collect_end_date := g_collect_start_date + 1;
		end if;

		-- do the thing with g_collect_end_date and g_collect_start_date:

		/* Round the Collection start date nearest lower time bucket. ex: if time is between 10:00 and 10:29
		   round it to 10:00.
		*/

		SELECT TO_DATE(
			TO_CHAR(g_collect_start_date,'YYYY/MM/DD')||
			LPAD(TO_CHAR(g_collect_start_date,'HH24:'),3,'0')||
			DECODE(SIGN(TO_NUMBER(TO_CHAR(g_collect_start_date,'MI'))-29),0,'00:00',1,'30:00',-1,'00:00'),
			'YYYY/MM/DDHH24:MI:SS')
		INTO g_rounded_collect_start_date
		FROM DUAL;


		/* Round the Collection end date to nearest higher time bucket. ex: if time is between 10:00 and 10:29
		   round it to 10:29:59
		*/

		SELECT TO_DATE(
			TO_CHAR(g_collect_end_date,'YYYY/MM/DD')||
			LPAD(TO_CHAR(g_collect_end_date,'HH24:'),3,'0')||
			DECODE(SIGN(TO_NUMBER(TO_CHAR(g_collect_end_date,'MI'))-29),0,'29:59',1,'59:59',-1,'29:59'),
			'YYYY/MM/DDHH24:MI:SS')
		INTO g_rounded_collect_end_date
		FROM DUAL;

		/* Get the commit size from the profile value. if the profile is not defined assume commit size as 100 */

		IF (FND_PROFILE.DEFINED('BIX_DM_DELETE_SIZE')) THEN
		   g_commit_chunk_size := TO_NUMBER(FND_PROFILE.VALUE('BIX_DM_DELETE_SIZE'));
		ELSE
		   g_commit_chunk_size := 100;
		END IF;

		/* Procedure collect calls from OLTP to the temporary table BIX_DM_INTERFACE: */
		  GET_CALLS;
		  g_status := 'SUCCESS';
		  g_table_name := 'BIX_DM_INTERFACE';
		  insert_log;

		/* Procedure collects all the calls information for the AGENT data */
		  SUM_AGENT;

		  g_status := 'SUCCESS';
		  g_table_name := 'BIX_DM_AGENT_SUM';
		  insert_log;

		/* Procedure collects all the calls information for the GROUP data */

		  SUM_GROUP;
		  g_status := 'SUCCESS';
		  g_table_name := 'BIX_DM_GROUP_SUM';
		  insert_log;

		/* Procedure collects all the calls information for the CALL data */

		  SUM_CALL;
		  g_status := 'SUCCESS';
		  g_table_name := 'BIX_DM_CALL_SUM';
		  insert_log;


		/* Advanced Outbound Data Population */

		--if upper(is_oao_installed) = 'Y' then
		  --BIX_POP_AO_SUM_PKG.populate(g_min_call_begin_date, g_max_call_begin_date);
		--end if;

		/* Procedure collects all the outcomes information for the AGENT data */

     IF (g_debug_flag = 'Y') THEN
        write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||' Calling procedure SUM_AGENT_OUTCOME', g_proc_name);
     END IF;

		  SUM_AGENT_OUTCOME;

		  g_status := 'SUCCESS';
		  g_table_name := 'BIX_DM_AGENT_OUTCOME_SUM';
		  insert_log;

		/* Procedure collects all the outcomes information for the GROUP data */

     IF (g_debug_flag = 'Y') THEN
        write_log(TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||' Calling procedure SUM_GROUP_OUTCOME', g_proc_name);
     END IF;

		  SUM_GROUP_OUTCOME;

		  g_status := 'SUCCESS';
		  g_table_name := 'BIX_DM_GROUP_OUTCOME_SUM';
		  insert_log;

		/* Cleanup: Delete all from the BIX_DM_INTERFACE table */

		  --DELETE_IN_CHUNKS('BIX_DM_INTERFACE',NULL,g_delete_count);
		  g_insert_count := 0;
		  g_status := 'SUCCESS';
		  g_table_name := 'BIX_DM_INTERFACE';
		  insert_log;




		g_collect_start_date := g_collect_end_date;

		if (l_collect_end_date - g_collect_end_date) > 1 then
			g_collect_end_date := g_collect_end_date + 1;
		elsif ((l_collect_end_date - g_collect_end_date) > 0) and
			((l_collect_end_date - g_collect_end_date) <= 1) then
			g_collect_end_date := l_collect_end_date;
		else
			exit;
		end if;


      end loop;

EXCEPTION
   WHEN G_DATE_MISMATCH THEN
     retcode := -1;
     errbuf := 'Collect Start Date cannot be greater than collection end date';

     IF (g_debug_flag = 'Y') THEN
        write_log('Collect Start Date cannot be greater than collection end date', g_proc_name);
     END IF;

WHEN OTHERS THEN
	retcode := SQLCODE;
	errbuf := SQLERRM;
	g_status := 'FAILED';

     IF (g_debug_flag = 'Y') THEN
	   write_log(g_error_mesg, g_proc_name);
     END IF;

	insert_log;
END COLLECT_CALLS_SUMMARY;

END BIX_DM_AGENT_CALL_SUMMARY_PKG;

/
