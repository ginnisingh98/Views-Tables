--------------------------------------------------------
--  DDL for Package Body IEC_REPORTS_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_REPORTS_UTIL_PVT" AS
/* $Header: IECVREPB.pls 120.2 2006/08/01 23:03:42 hhuang noship $ */

-- Sub-Program Unit Declarations

-- Update table
-- iec_rep_agent_status
-- resource_id
-- dial_server_id
-- campaign_id
-- campaign_schedule_id
-- status
-- status_reason
-- status_start_time
--  .... Std who columns
-- security_group_id
-- object_version_number

-- Check if a cpn is active..

PROCEDURE UPDATE_AGENT_STATE
  (P_RESOURCE_ID     IN  NUMBER
  ,P_DIAL_SERVER_ID  IN  NUMBER
  ,P_CAMPAIGN_ID     IN  NUMBER
  ,P_CPN_SCHEDULE_ID IN  NUMBER
  ,P_STATUS          IN  VARCHAR2
  ,P_STATUS_REASON   IN  VARCHAR2
  ,P_START_TIME      IN  VARCHAR2
  )
  AS
  l_start_time DATE;
BEGIN
  l_start_time := sysdate;
--   begin
--   	dbms_output.put_line( ' Begin work on Update_agent_state');
--	update iec_rep_agent_status
--           set campaign_schedule_id = P_CPN_SCHEDULE_ID,
--	       status = P_STATUS,
--	       status_reason = P_STATUS_REASON,
--	       status_start_time = to_date(P_START_TIME, 'yyyy-mm-dd HH24:MI:SS')
--         where  resource_id = P_RESOURCE_ID
--           and  dial_server_id = P_DIAL_SERVER_ID
--	   and  status = P_STATUS;

--	if SQL%ROWCOUNT = 0
--	then
	    if P_START_TIME IS NOT NULL then
		l_start_time := 	to_date(P_START_TIME, 'yyyy-mm-dd HH24:MI:SS');
          end if;
	      insert into iec_rep_agent_status (
        	resource_Id,
	  	dial_server_id,
		campaign_id,
          	campaign_schedule_id,
          	status,
          	status_reason,
	  	status_start_time,
	  	created_by,
	  	creation_date,
	  	last_updated_by,
	  	last_update_date,
	  	last_update_login,
	  	security_group_id,
          	object_version_number )
    		values(
       	  	P_RESOURCE_ID,
	  	P_DIAL_SERVER_ID,
            P_CAMPAIGN_ID,
	  	P_CPN_SCHEDULE_ID,
	  	P_STATUS,
	  	P_STATUS_REASON,
	  	l_start_time,
	  	NVL(FND_GLOBAL.user_id,-1),
	  	sysdate,
	  	NVL(FND_GLOBAL.conc_login_id,-1),
	  	sysdate,
	  	NVL(FND_GLOBAL.conc_login_id,-1),
	  	0,
	  	0
		);
--	end if;
--   Exception
     --WHEN OTHERS then
--	raise;
--   end;
--	dbms_output.put_line( 'Leaving.');
END UPDATE_AGENT_STATE;


-- Table columns -
-- AGENT_CPN_DETAIL_ID             NUMBER(15) NOT NULL,
-- CREATED_BY                      NUMBER(15) NOT NULL,
-- CREATION_DATE                   DATE NOT NULL,
-- LAST_UPDATED_BY                 NUMBER(15),
-- LAST_UPDATE_DATE                DATE  NOT NULL,
-- LAST_UPDATE_LOGIN               NUMBER(15),

-- RESOURCE_ID               	   NUMBER(15) NOT NULL,
-- CAMPAIGN_ID			   NUMBER(15) NOT NULL,
-- CAMPAIGN_SCHEDULE_ID            NUMBER(10) NOT NULL,
-- DIAL_SERVER_ID                  NUMBER(15) NOT NULL,
-- TOTAL_LOGIN_TIME                NUMBER(9) NOT NULL,
-- TOTAL_ACTIVITY_TIME             NUMBER(9) NOT NULL,
-- CURRENT_STATUS                  VARCHAR2(4) NOT NULL,
-- CURRENT_STATUS_BEGIN_TIME       DATE NOT NULL,
-- COMPLETED_TRANSACTION_COUNT     NUMBER(9) NOT NULL,
-- TOTAL_IDLE_TIME                 NUMBER(9),
-- TOTAL_WAIT_TIME                 NUMBER(9),
-- TOTAL_TALK_TIME                 NUMBER(9),
-- TOTAL_WRAPUP_TIME               NUMBER(9),
-- CALLS_OFFERED                   NUMBER(4) NOT NULL,
-- PREDICTIVE_CALLS_OFFERED        NUMBER(4) NOT NULL,
-- OUTCOME_ID                      NUMBER(10) NOT NULL,
-- RESULT_ID                       NUMBER(10) NOT NULL,
-- RESULT_COUNT                    NUMBER(10) NOT NULL,
-- POSITIVE_RESPONSE_FLAG          VARCHAR2(1),
-- SECURITY_GROUP_ID               NUMBER(15),
-- OBJECT_VERSION_NUMBER           NUMBER

PROCEDURE UPDATE_AGENT_OUTCOME_DETAILS
  ( P_RESOURCE_ID                 IN NUMBER
   ,P_DIAL_SERVER_ID		  IN NUMBER
   ,P_CAMPAIGN_ID	   	  IN NUMBER
   ,P_CAMPAIGN_SCHEDULE_ID        IN NUMBER
   ,P_OUTCOME_ID		  IN NUMBER
   ,P_RESULT_ID			  IN NUMBER
   ,P_RESULT_COUNT		  IN NUMBER
   ,P_FTC_ABANDON_COUNT    IN NUMBER
   ,P_MESSAGE_PLAYED_COUNT IN NUMBER
   ,P_POSITIVE_RESPONSE_FLAG	  IN VARCHAR2
   ,P_CONTACT_FLAG                IN VARCHAR2
   ,P_TOTAL_IDLE_TIME             IN NUMBER
   ,P_TOTAL_WAIT_TIME		  IN NUMBER
   ,P_TOTAL_TALK_TIME		  IN NUMBER
   ,P_TOTAL_WRAPUP_TIME		  IN NUMBER
   ,P_TOTAL_BREAK_TIME            IN NUMBER
   ,P_CALLS_OFFERED		  IN NUMBER
   ,P_PRED_CALLS_OFFERED	  IN NUMBER
   ,P_LOGIN_AGENT_COUNT		  IN NUMBER
  )

  AS
  l_result_count NUMBER := 0;

  l_login_time NUMBER := 0;
  l_activity_time NUMBER := 0;

BEGIN
--   begin
	l_activity_time := P_TOTAL_TALK_TIME + P_TOTAL_WRAPUP_TIME;
	l_login_time := l_activity_time + P_TOTAL_IDLE_TIME + P_TOTAL_BREAK_TIME + P_TOTAL_WAIT_TIME;

	l_result_count := P_RESULT_COUNT;

	if P_RESULT_COUNT = 0 AND P_OUTCOME_ID > 0
	then
	    l_result_count := 1;
	end if;

--   	dbms_output.put_line( ' Begin work on Update_agent_cpn_details');
--	update iec_rep_agent_cpn_details
--           set outcome_id = P_OUTCOME_ID,
--	       result_id = P_RESULT_ID,
--	       result_count = nvl( result_count, 0 ) + l_result_count,
--	       positive_response_flag = P_POSITIVE_RESPONSE_FLAG,
--	       contact_flag = P_CONTACT_FLAG,
--	       last_updated_by = NVL(FND_GLOBAL.conc_login_id,-1),
--	       last_update_date = sysdate
--       where  resource_id = P_RESOURCE_ID
--           and  dial_server_id = P_DIAL_SERVER_ID
--	   and  campaign_schedule_id = P_CAMPAIGN_SCHEDULE_ID
--	   and  ( outcome_id = P_OUTCOME_ID  OR nvl(outcome_id, 0 ) = 0 )
--	   and  ( result_id = P_RESULT_id OR nvl( result_id, 0 ) = 0 );

--	if SQL%ROWCOUNT = 0
--	then
	    insert into iec_rep_agent_cpn_details (
	    agent_cpn_detail_id,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
        resource_Id,
	  	dial_server_id,
            campaign_id,
        campaign_schedule_id,
		total_login_time,
		total_activity_time,
		total_idle_time,
		total_wait_time,
		total_wrapup_time,
		total_talk_time,
		calls_offered,
    predictive_calls_offered,
		outcome_id,
		result_id,
		result_count,
		positive_response_flag,
	  	security_group_id,
        object_version_number,
		current_status,
		current_Status_begin_time,
		contact_flag,
		login_agent_count
		)
    	values(
	    iec_rep_agent_cpn_details_s.nextval,
	  	NVL(FND_GLOBAL.user_id,-1),
	  	sysdate,
	  	NVL(FND_GLOBAL.conc_login_id,-1),
	  	sysdate,
	  	NVL(FND_GLOBAL.conc_login_id,-1),
       	P_RESOURCE_ID,
	  	P_DIAL_SERVER_ID,
		P_CAMPAIGN_ID,
	  	P_CAMPAIGN_SCHEDULE_ID,
		l_login_time,
		l_activity_time,
		P_TOTAL_IDLE_TIME,
		P_TOTAL_WAIT_TIME,
		P_TOTAL_WRAPUP_TIME,
		P_TOTAL_TALK_TIME,
		P_CALLS_OFFERED,
    P_PRED_CALLS_OFFERED,
		P_OUTCOME_ID,
		P_RESULT_ID,
		l_result_count,
		P_POSITIVE_RESPONSE_FLAG,
	  	0,
	  	0,
		'5',
		sysdate,
		P_CONTACT_FLAG,
		P_LOGIN_AGENT_COUNT
		);
--	end if;


	UPDATE_CPN_AGT_OUTCOME_DETAILS( P_DIAL_SERVER_ID
					,P_CAMPAIGN_ID
   					,P_CAMPAIGN_SCHEDULE_ID
   					,P_OUTCOME_ID
   					,P_RESULT_ID
   					,l_result_count
            ,P_FTC_ABANDON_COUNT
            ,P_MESSAGE_PLAYED_COUNT
   					,P_POSITIVE_RESPONSE_FLAG
					,P_CONTACT_FLAG
					,P_TOTAL_IDLE_TIME
					,P_TOTAL_WAIT_TIME
					,P_TOTAL_TALK_TIME
					,P_TOTAL_WRAPUP_TIME
					,P_TOTAL_BREAK_TIME
        	,P_CALLS_OFFERED
          ,P_PRED_CALLS_OFFERED
 					);

--	dbms_output.put_line( 'Leaving.');
END UPDATE_AGENT_OUTCOME_DETAILS;


PROCEDURE UPDATE_AGENT_CURRENT_STATE
  ( P_RESOURCE_ID                 IN NUMBER
   ,P_DIAL_SERVER_ID		  IN NUMBER
   ,P_CAMPAIGN_SCHEDULE_ID        IN NUMBER
   ,P_CURRENT_STATUS              IN VARCHAR2
   ,P_CURRENT_STATUS_BEGIN_TIME   IN VARCHAR2
  )
  AS
  l_current_status_begin_time DATE;
BEGIN
  l_current_status_begin_time := sysdate;
	if P_CURRENT_STATUS_BEGIN_TIME  IS NOT NULL then
	  l_current_status_begin_time := to_date(P_CURRENT_STATUS_BEGIN_TIME, 'yyyy-mm-dd HH24:MI:SS');
      end if;
--    begin
	-- Update all rows to '5' first and then set
	-- the supplied cpn value with the "STATE".
  -- '5' is state 'OUT' in fnd_lloups with lookup_type = 'BIX_DM_AGENT_STATUS'
  --
	Update iec_rep_agent_cpn_details /*+ index(iec_rep_agent_cpn_details iec_rep_agent_cpn_details_N1) */
	   set CURRENT_STATUS = '5'
	 where resource_Id = P_RESOURCE_ID
	   and dial_server_id = P_DIAL_SERVER_ID
	   and campaign_schedule_id <> P_CAMPAIGN_SCHEDULE_ID;

	-- This will always exist.
	if( P_CAMPAIGN_SCHEDULE_ID = -999999 )
	then
		Update iec_rep_agent_cpn_details /*+ index(iec_rep_agent_cpn_details iec_rep_agent_cpn_details_N1) */
		set CURRENT_STATUS = P_CURRENT_STATUS,
			current_status_begin_time = l_current_status_begin_time
		where resource_Id = P_RESOURCE_ID
		and dial_server_id = P_DIAL_SERVER_ID;
	else
		Update iec_rep_agent_cpn_details /*+ index(iec_rep_agent_cpn_details iec_rep_agent_cpn_details_N1) */
		set CURRENT_STATUS = P_CURRENT_STATUS,
			current_status_begin_time = l_current_status_begin_time
		where resource_Id = P_RESOURCE_ID
		and dial_server_id = P_DIAL_SERVER_ID
		and campaign_schedule_id = P_CAMPAIGN_SCHEDULE_ID;
	end if;
  --  exception
--	When others then
--		raise;
    --end;
END UPDATE_AGENT_CURRENT_STATE;


-- CAMPAIGN_REP_ID                  NUMBER(15) NOT NULL,
-- CREATED_BY                       NUMBER(15) NOT NULL,
-- CREATION_DATE                    DATE NOT NULL,
-- LAST_UPDATED_BY                  NUMBER(15) NOT NULL,
-- LAST_UPDATE_DATE                 DATE NOT NULL,
-- LAST_UPDATE_LOGIN                NUMBER,
-- CAMPAIGN_ID			    NUMBER(15) NOT NULL,
-- CAMPAIGN_SCHEDULE_ID             NUMBER(15) NOT NULL,
-- DIAL_SERVER_ID                   NUMBER(15) NOT NULL,
-- DIALING_MODE                     VARCHAR2(4) NOT NULL,
-- TOTAL_LOGIN_TIME                 NUMBER(9) NOT NULL,
-- TOTAL_ACTIVITY_TIME              NUMBER(9) NOT NULL,
-- NUM_LOGIN_AGENT                  NUMBER(4) NOT NULL,
-- MAX_LOGIN_AGENT                  NUMBER(4) NOT NULL,
-- COMPLETED_TRANSACTION_COUNT      NUMBER(9) NOT NULL,
-- TOTAL_IDLE_TIME                  NUMBER(9) NOT NULL,
-- TOTAL_WAIT_TIME                  NUMBER(9) NOT NULL,
-- TOTAL_PREVIEW_TIME               NUMBER(9) NOT NULL,
-- TOTAL_TALK_TIME                  NUMBER(9) NOT NULL,
-- TOTAL_WRAPUP_TIME                NUMBER(9) NOT NULL,
-- LONGEST_IDLE_TIME                NUMBER(9) NOT NULL,
-- LONGEST_WAIT_TIME                NUMBER(9) NOT NULL,
-- LONGEST_TALK_TIME                NUMBER(9) NOT NULL,
-- LONGEST_WRAPUP_TIME              NUMBER(9) NOT NULL,
-- SHORTEST_IDLE_TIME               NUMBER(9) NOT NULL,
-- SHORTEST_WAIT_TIME               NUMBER(9) NOT NULL,
-- SHORTEST_TALK_TIME               NUMBER(9) NOT NULL,
-- SHORTEST_WRAPUP_TIME             NUMBER(9) NOT NULL,
-- TOTAL_DIALS                      NUMBER(9) NOT NULL,
-- PREVIEW_DIALS                    NUMBER(9),
-- PROGRESSIVE_DIALS                NUMBER(9),
-- PREDICTIVE_DIALS                 NUMBER(9),
-- MANUAL_DIALS                     NUMBER(9),
-- PREDICTIVE_OUTCOME_ID            NUMBER(10),
-- PREDICTIVE_OUTCOME_COUNT         NUMBER(10),
-- PREDICTIVE_RESULT_ID             NUMBER(10),
-- PREDICTIVE_RESULT_COUNT          NUMBER(10),
-- PREDICTIVE_DIAL_FHQ_COUNT        NUMBER(9),
-- CALLS_OFFERED                    NUMBER(9) NOT NULL,
-- PREDICTIVE_CALLS_OFFERED         NUMBER(9) NOT NULL,
-- AGENT_OUTCOME_ID                 NUMBER(10),
-- AGENT_OUTCOME_COUNT              NUMBER(10),
-- AGENT_RESULT_ID                  NUMBER(10),
-- AGENT_RESULT_COUNT               NUMBER(10),
-- POSITIVE_RESPONSE_FLAG           VARCHAR2(1),
-- NUM_AGENTS_ON_CALL               NUMBER(10) NOT NULL,
-- NUM_AGENTS_IN_WRAPUP             NUMBER(10) NOT NULL,
-- NUM_AGENTS_AVAILABLE             NUMBER(10) NOT NULL ,
-- NUM_AGENTS_IDLE                  NUMBER(10) NOT NULL,
-- NUM_AGENTS_ON_BREAK              NUMBER(10) NOT NULL,
-- SECURITY_GROUP_ID                NUMBER(15),
-- OBJECT_VERSION_NUMBER            NUMBER

PROCEDURE UPDATE_CPN_AGT_OUTCOME_DETAILS
  ( P_DIAL_SERVER_ID		  IN NUMBER
   ,P_CAMPAIGN_ID	   	  IN  NUMBER
   ,P_CAMPAIGN_SCHEDULE_ID        IN NUMBER
   ,P_OUTCOME_ID		  IN NUMBER
   ,P_RESULT_ID			  IN NUMBER
   ,P_RESULT_COUNT		  IN NUMBER
   ,P_FTC_ABANDON_COUNT    IN NUMBER
   ,P_MESSAGE_PLAYED_COUNT IN NUMBER
   ,P_POSITIVE_RESPONSE_FLAG	  IN VARCHAR2
   ,P_CONTACT_FLAG                IN VARCHAR2
   ,P_TOTAL_IDLE_TIME             IN NUMBER
   ,P_TOTAL_WAIT_TIME 		  IN NUMBER
   ,P_TOTAL_TALK_TIME		  IN NUMBER
   ,P_TOTAL_WRAPUP_TIME		  IN NUMBER
   ,P_TOTAL_BREAK_TIME		  IN NUMBER
   ,P_CALLS_OFFERED		  IN NUMBER
   ,P_PRED_CALLS_OFFERED	  IN NUMBER
  )
  AS
  l_result_count NUMBER := 0;
  l_activity_time NUMBER := 0;
  l_login_time NUMBER := 0;

  l_ln_idle_time NUMBER := 0;
  l_ln_wait_time NUMBER := 0;
  l_ln_talk_time NUMBER := 0;
  l_ln_wrapup_time NUMBER := 0;

  l_sh_idle_time NUMBER := 0;
  l_sh_wait_time NUMBER := 0;
  l_sh_talk_time NUMBER := 0;
  l_sh_wrapup_time NUMBER := 0;

  l_mx_login_time NUMBER := 0;
  l_mx_activity_time NUMBER := 0;
  l_mx_idle_time NUMBER := 0;
  l_mx_wait_time NUMBER := 0;
  l_mx_talk_time NUMBER := 0;
  l_mx_wrapup_time NUMBER := 0;
  l_mx_calls_offered NUMBER := 0;
  l_mx_pred_calls_offered NUMBER := 0;

  l_dialing_method VARCHAR2(10);
BEGIN

   BEGIN
   	select dialing_method into l_dialing_method from
   	iec_g_executing_lists_v where schedule_id = P_CAMPAIGN_SCHEDULE_ID;

   Exception
   	When No_DATA_FOUND then
		l_dialing_method := 'UNKN';
   end;

   l_activity_time := P_TOTAL_TALK_TIME + P_TOTAL_WRAPUP_TIME;
   l_login_time := l_activity_time + P_TOTAL_IDLE_TIME + P_TOTAL_BREAK_TIME  + P_TOTAL_WAIT_TIME;

   l_result_count := P_RESULT_COUNT;

   if l_result_count <= 0 AND P_OUTCOME_ID > 0
   then
		l_result_count := 1;
   end if;

   begin
   	select max( nvl( total_login_time, 0 ) ),
	       max( nvl( total_activity_time, 0 ) ),
	       max( nvl( total_idle_time, 0 ) ),
	       max( nvl( total_wait_time, 0 ) ),
	       max( nvl( total_talk_time, 0 ) ),
	       max( nvl( total_wrapup_time, 0 ) ),
	       max( nvl( calls_offered, 0 ) ),
         max( nvl( predictive_calls_offered, 0 ) ),
		max(nvl( longest_idle_time, 0 )),
		max( nvl( longest_wait_time, 0 ) ),
		max(nvl( longest_talk_time, 0 ) ),
		max(nvl( longest_wrapup_time, 0 )),
		max(nvl( shortest_idle_time, 0 )),
		max(nvl( shortest_wait_time, 0 )),
		max(nvl( shortest_talk_time, 0 )),
		max(nvl( shortest_wrapup_time, 0 ))
	       into
	       l_mx_login_time,
	       l_mx_activity_time,
	       l_mx_idle_time,
	       l_mx_wait_time,
	       l_mx_talk_time,
	       l_mx_wrapup_time,
	       l_mx_calls_offered,
         l_mx_pred_calls_offered,
	  	l_ln_idle_time,
	  	l_ln_wait_time,
		l_ln_talk_time,
		l_ln_wrapup_time,
		l_sh_idle_time,
		l_sh_wait_time,
		l_sh_talk_time,
		l_sh_wrapup_time
	  from  iec_rep_campaign_details
         where  dial_server_id = P_DIAL_SERVER_ID
	   and  campaign_schedule_id = P_CAMPAIGN_SCHEDULE_ID;

   	-- dbms_output.put_line( 'After Select...<'|| l_mx_idle_time||'> <'||l_mx_login_time);
	if( l_mx_login_time is null AND l_mx_activity_time is null
	   and  l_mx_idle_time is null and l_mx_wait_time is null
	   and l_mx_talk_time is null and l_mx_wrapup_time is null
	   and  l_ln_idle_time is null and l_ln_wait_time is null
	   and l_sh_idle_time is null and l_sh_wait_time is null )
	then

	       l_mx_login_time := 0;
	       l_mx_activity_time := 0;
	       l_mx_idle_time := 0;
	       l_mx_wait_time := 0;
	       l_mx_talk_time := 0;
	       l_mx_wrapup_time := 0;
	       l_mx_calls_offered := 0;
         l_mx_pred_calls_offered := 0;
	  	l_ln_idle_time := 0;
	  	l_ln_wait_time := 0;
		l_ln_talk_time := 0;
		l_ln_wrapup_time := 0;
		l_sh_idle_time := 0;
		l_sh_wait_time := 0;
		l_sh_talk_time := 0;
		l_sh_wrapup_time := 0;

	       add_dummy_agent_record(
	       	P_DIAL_SERVER_ID,
		P_CAMPAIGN_ID,
		P_CAMPAIGN_SCHEDULE_ID,
		P_OUTCOME_ID,
		P_RESULT_ID,
		l_RESULT_COUNT,
    P_FTC_ABANDON_COUNT,
    P_MESSAGE_PLAYED_COUNT,
		P_POSITIVE_RESPONSE_FLAG,
		P_CONTACT_FLAG
	       );

	else
   		-- dbms_output.put_line( 'In the else part of things...');
		if l_ln_idle_time < P_TOTAL_IDLE_TIME
		then
			l_ln_idle_time := P_TOTAL_IDLE_TIME;
		end if;

		if l_ln_wait_time < P_TOTAL_WAIT_TIME
		then
			l_ln_wait_time := P_TOTAL_WAIT_TIME;
		end if;

		if l_ln_talk_time < P_TOTAL_TALK_TIME
		then
			l_ln_talk_time := P_TOTAL_TALK_TIME;
		end if;

		if l_ln_wrapup_time < P_TOTAL_WRAPUP_TIME
		then
			l_ln_wrapup_time := P_TOTAL_WRAPUP_TIME;
		end if;

		if P_TOTAL_IDLE_TIME > 0
		then
			if l_sh_idle_time > P_TOTAL_IDLE_TIME
			then
				l_sh_idle_time := P_TOTAL_IDLE_TIME;
			elsif l_sh_idle_time = 0
			then
				l_sh_idle_time := P_TOTAL_IDLE_TIME;
			end if;
		end if;

		if P_TOTAL_WAIT_TIME > 0
		then
			if l_sh_wait_time > P_TOTAL_WAIT_TIME
			then
				l_sh_wait_time := P_TOTAL_WAIT_TIME;
			elsif l_sh_wait_time = 0
			then
				l_sh_wait_time := P_TOTAL_WAIT_TIME;
			end if;
		end if;

		if P_TOTAL_TALK_TIME > 0
		then
			if l_sh_talk_time > P_TOTAL_TALK_TIME
			then
				l_sh_talk_time := P_TOTAL_TALK_TIME;
			elsif l_sh_talk_time = 0
			then
				l_sh_talk_time := P_TOTAL_TALK_TIME;
			end if;
		end if;

		if P_TOTAL_WRAPUP_TIME > 0
		then
			if l_sh_wrapup_time > P_TOTAL_WRAPUP_TIME
			then
				l_sh_wrapup_time := P_TOTAL_WRAPUP_TIME;
			elsif l_sh_wrapup_time = 0
			then
				l_sh_wrapup_time := P_TOTAL_WRAPUP_TIME;
			end if;
		end if;

		if P_OUTCOME_ID <> -999999
		then

			update iec_rep_campaign_details
			set
        agent_outcome_id = P_OUTCOME_ID,
				agent_result_id = P_RESULT_ID,
				dialing_mode = l_dialing_method,
			  agent_result_count = nvl( agent_result_count, 0 ) + l_result_count,
        FTC_ABANDONMENT_COUNT = nvl(FTC_ABANDONMENT_COUNT, 0) + P_FTC_ABANDON_COUNT,
        MESSAGE_PLAYED_COUNT = nvl(MESSAGE_PLAYED_COUNT, 0) + P_MESSAGE_PLAYED_COUNT,
				positive_response_flag = P_POSITIVE_RESPONSE_FLAG,
     		contact_flag = P_CONTACT_FLAG,
				last_updated_by = NVL(FND_GLOBAL.conc_login_id,-1),
				last_update_date = sysdate
			where  dial_server_id = P_DIAL_SERVER_ID
			and  campaign_schedule_id = P_CAMPAIGN_SCHEDULE_ID
			and  (
				(
					( agent_outcome_id = P_OUTCOME_ID  and agent_result_id = P_RESULT_id )
		     			OR
					( agent_outcome_id = -999999  and  agent_result_id = -999999 )
				)
				AND
				predictive_outcome_id = -999999
		  	);

			if SQL%ROWCOUNT = 0
			then
	   		-- dbms_output.put_line( 'Inserting a new row as the outcomes are different...');
				-- This is a different outcome.
				add_dummy_agent_record(
					P_DIAL_SERVER_ID,
					P_CAMPAIGN_ID,
					P_CAMPAIGN_SCHEDULE_ID,
					P_OUTCOME_ID,
					P_RESULT_ID,
					l_RESULT_COUNT,
          P_FTC_ABANDON_COUNT,
          P_MESSAGE_PLAYED_COUNT,
					P_POSITIVE_RESPONSE_FLAG,
					P_CONTACT_FLAG
				);
			end if;

		end if;
	end if;
    -- Do not udpate  num_voice_detected, calls_offered and predictive_calls_offered
    -- They are updated by UPDATE_CPN_AGENT_STATS

		update iec_rep_campaign_details
		    set total_login_time = nvl( l_mx_login_time, 0 ) + l_login_time,
			total_activity_time = nvl( l_mx_activity_time, 0 )+ l_activity_time,
			total_idle_time = nvl( l_mx_idle_time, 0 ) + P_TOTAL_IDLE_TIME,
			total_wait_time = nvl( l_mx_wait_time, 0 ) + P_TOTAL_WAIT_TIME,
			total_talk_time = nvl( l_mx_talk_time, 0 ) + P_TOTAL_TALK_TIME,
			total_wrapup_time = nvl( l_mx_wrapup_time, 0 ) + P_TOTAL_WRAPUP_TIME,
			longest_idle_time = l_ln_idle_time,
			longest_wait_time = l_ln_wait_time,
			longest_talk_time = l_ln_talk_time,
			longest_wrapup_time = l_ln_wrapup_time,
			shortest_idle_time = l_sh_idle_time,
			shortest_wait_time = l_sh_wait_time,
			shortest_talk_time = l_sh_talk_time,
			shortest_wrapup_time = l_sh_wrapup_time,
			dialing_mode = l_dialing_method,
			last_updated_by = NVL(FND_GLOBAL.conc_login_id,-1),
			last_update_date = sysdate
		where  dial_server_id = P_DIAL_SERVER_ID
		and  campaign_schedule_id = P_CAMPAIGN_SCHEDULE_ID;

    Exception
    	When others then
		raise;
   end;

END UPDATE_CPN_AGT_OUTCOME_DETAILS;

PROCEDURE UPDATE_CPN_AGENT_STATS
  ( P_DIAL_SERVER_ID		  IN NUMBER
   ,P_CAMPAIGN_ID	   	  IN NUMBER
   ,P_CAMPAIGN_SCHEDULE_ID        IN NUMBER
   ,P_NUM_LOGIN_AGENTS            IN NUMBER
   ,P_NUM_CPN_LOGIN_AGENTS	  IN NUMBER
   ,P_PREVIEW_DIALS               IN NUMBER
   ,P_TIMED_PREVIEW_DIALS         IN NUMBER
   ,P_PROGRESSIVE_DIALS           IN NUMBER
   ,P_PREDICTIVE_DIALS            IN NUMBER
   ,P_MANUAL_DIALS                IN NUMBER
   ,P_PREDICTIVE_DIAL_FHQ_COUNT   IN NUMBER
   ,P_CURRENT_IN_FHQ              IN NUMBER
   ,P_NUM_AGENTS_ON_CALL          IN NUMBER
   ,P_NUM_AGENTS_IN_WRAPUP        IN NUMBER
   ,P_NUM_AGENTS_AVAILABLE        IN NUMBER
   ,P_NUM_AGENTS_IDLE             IN NUMBER
   ,P_NUM_AGENTS_ON_BREAK         IN NUMBER
   ,P_NUM_VOICE_DETECTED          IN NUMBER
   ,P_CALLS_OFFERED		  IN NUMBER
   ,P_PRED_CALLS_OFFERED	  IN NUMBER
  )
  AS
  l_mx_login_agent NUMBER := 0;
  l_mx_cpn_login_agent NUMBER :=0;
  l_mx_total_dials NUMBER := 0;

  l_mx_preview_dials NUMBER := 0;
  l_mx_timed_preview_dials NUMBER := 0;
  l_mx_progressive_dials NUMBER := 0;
  l_mx_manual_dials NUMBER := 0;
  l_mx_predictive_dials NUMBER := 0;
  l_mx_voice_detected NUMBER := 0;
  l_mx_calls_offered NUMBER := 0;
  l_mx_pred_calls_offered NUMBER := 0;

BEGIN

   begin
   	select 	max( nvl( max_login_agent,0) ),
		max( nvl( cpn_max_login_agent, 0) ),
		max( nvl( preview_dials, 0 ) ),
		max( nvl( timed_preview_dials, 0 ) ),
		max( nvl( progressive_dials, 0 ) ),
		max( nvl( manual_dials, 0 ) ),
		max( nvl( predictive_dials, 0 ) ),
		max( nvl( num_voice_detected, 0 ) ),
    		max( nvl( calls_offered, 0 )),
    		max( nvl( predictive_calls_offered, 0 ))
	   into
	       	l_mx_login_agent,
		l_mx_cpn_login_agent,
		l_mx_preview_dials,
		l_mx_timed_preview_dials,
		l_mx_progressive_dials,
		l_mx_manual_dials,
		l_mx_predictive_dials,
    		l_mx_voice_detected,
    		l_mx_calls_offered,
    		l_mx_pred_calls_offered

	 from  iec_rep_campaign_details
         where  ( dial_server_id = P_DIAL_SERVER_ID OR dial_server_id = 0 )
	   	and  campaign_schedule_id = P_CAMPAIGN_SCHEDULE_ID;

	if( 	l_mx_login_agent is null AND
		l_mx_preview_dials is null AND
		l_mx_timed_preview_dials is null AND
		l_mx_progressive_dials is null AND
		l_mx_manual_dials is null AND
		l_mx_predictive_dials is null AND
    		l_mx_voice_detected is null)
	then
		l_mx_total_dials := P_PREVIEW_DIALS + P_TIMED_PREVIEW_DIALS + P_PROGRESSIVE_DIALS + P_PREDICTIVE_DIALS + P_MANUAL_DIALS;

	       insert into iec_rep_campaign_details (
	        campaign_rep_id,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		campaign_id,
        	campaign_schedule_id,
		dial_server_id,
		dialing_mode,
		total_login_time,
		total_activity_time,
		num_login_agent,
		max_login_agent,
		cpn_num_login_agent,
		cpn_max_login_agent,
		total_idle_time,
		total_wait_time,
		total_wrapup_time,
		total_talk_time,
		longest_idle_time,
		longest_wait_time,
		longest_talk_time,
		longest_wrapup_time,
		shortest_idle_time,
		shortest_wait_time,
		shortest_talk_time,
		shortest_wrapup_time,
		total_dials,
		preview_dials,
		timed_preview_dials,
		progressive_dials,
		predictive_dials,
		manual_dials,
		predictive_outcome_id,
		predictive_result_id,
		predictive_result_count,
		predictive_dial_fhq_count,
		calls_offered,
    		predictive_calls_offered,
		agent_outcome_id,
		agent_result_id,
		agent_result_count,
		positive_response_flag,
		num_agents_on_call,
		num_agents_in_wrapup,
		num_agents_available,
		num_agents_idle,
		num_agents_on_break,
		security_group_id,
		object_version_number,
		contact_flag,
		num_cust_in_fhq,
    		num_voice_detected
		)
		values
		(
		iec_rep_campaign_details_s.nextval,
		NVL(FND_GLOBAL.user_id,-1),
	  	sysdate,
	  	NVL(FND_GLOBAL.conc_login_id,-1),
	  	sysdate,
	  	NVL(FND_GLOBAL.conc_login_id,-1),
		P_CAMPAIGN_ID,
	  	P_CAMPAIGN_SCHEDULE_ID,
	  	P_DIAL_SERVER_ID,
		'UNKN',
		0,
		0,
		P_NUM_LOGIN_AGENTS,
		P_NUM_LOGIN_AGENTS,
		P_NUM_CPN_LOGIN_AGENTS,
		P_NUM_CPN_LOGIN_AGENTS,
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
		l_mx_total_dials,
		P_PREVIEW_DIALS,
		P_TIMED_PREVIEW_DIALS,
		P_PROGRESSIVE_DIALS,
		P_PREDICTIVE_DIALS,
		P_MANUAL_DIALS,
		-999999,
		-999999,
		0,
		P_PREDICTIVE_DIAL_FHQ_COUNT,
		0,
    		0,
		-999999,
		-999999,
		0,
		'N',
	  	P_NUM_AGENTS_ON_CALL,
	  	P_NUM_AGENTS_IN_WRAPUP,
		P_NUM_AGENTS_AVAILABLE,
		P_NUM_AGENTS_IDLE,
		P_NUM_AGENTS_ON_BREAK,
		0,
		0,
		'N',
		P_CURRENT_IN_FHQ,
    		0
		);

	else

		if l_mx_login_agent < P_NUM_LOGIN_AGENTS
		then
			l_mx_login_agent := P_NUM_LOGIN_AGENTS;
		end if;

		if l_mx_cpn_login_agent < P_NUM_CPN_LOGIN_AGENTS
		then
			l_mx_cpn_login_agent := P_NUM_CPN_LOGIN_AGENTS;
		end if;

		l_mx_preview_dials := l_mx_preview_dials + P_PREVIEW_DIALS;
		l_mx_timed_preview_dials := l_mx_timed_preview_dials + P_TIMED_PREVIEW_DIALS;
		l_mx_progressive_dials := l_mx_progressive_dials + P_PROGRESSIVE_DIALS;
		l_mx_manual_dials := l_mx_manual_dials + P_MANUAL_DIALS;
		l_mx_predictive_dials := l_mx_predictive_dials + P_PREDICTIVE_DIALS;

		l_mx_total_dials := l_mx_preview_dials + l_mx_progressive_dials + l_mx_manual_dials + l_mx_predictive_dials + l_mx_timed_preview_dials;

		update iec_rep_campaign_details
		set 	num_login_agent = P_NUM_LOGIN_AGENTS,
			max_login_agent = l_mx_login_agent,
			cpn_num_login_agent = P_NUM_CPN_LOGIN_AGENTS,
			cpn_max_login_agent = l_mx_cpn_login_agent,
			total_dials = l_mx_total_dials,
			preview_dials = l_mx_preview_dials,
			timed_preview_dials = l_mx_timed_preview_dials,
			progressive_dials = l_mx_PROGRESSIVE_DIALS,
			predictive_dials = l_mx_PREDICTIVE_DIALS,
			manual_dials = l_mx_MANUAL_DIALS,
      			num_voice_detected = nvl(l_mx_voice_detected, 0) +  P_NUM_VOICE_DETECTED,
      			calls_offered = nvl( l_mx_calls_offered, 0 ) + P_CALLS_OFFERED,
      			predictive_calls_offered = nvl( l_mx_pred_calls_offered, 0 ) + P_PRED_CALLS_OFFERED,
			predictive_dial_fhq_count = predictive_dial_fhq_count + P_PREDICTIVE_DIAL_FHQ_COUNT,
			num_cust_in_fhq = P_CURRENT_IN_FHQ,
			num_agents_on_call = P_NUM_AGENTS_ON_CALL,
			num_agents_in_wrapup = P_NUM_AGENTS_IN_WRAPUP,
			num_agents_available = P_NUM_AGENTS_AVAILABLE,
			num_agents_idle = P_NUM_AGENTS_IDLE,
			num_agents_on_break = P_NUM_AGENTS_ON_BREAK,
			last_updated_by = NVL(FND_GLOBAL.conc_login_id,-1),
			last_update_date = sysdate
		where  ( dial_server_id = P_DIAL_SERVER_ID OR dial_server_id = 0 )
		and  campaign_schedule_id = P_CAMPAIGN_SCHEDULE_ID;
	end if;
   Exception
   	When OTHERS THEN
		raise;
   end;
END UPDATE_CPN_AGENT_STATS;

PROCEDURE UPDATE_CPN_DIAL_STATS
  ( P_DIAL_SERVER_ID		  IN NUMBER
   ,P_CAMPAIGN_ID	   		  IN  NUMBER
   ,P_CAMPAIGN_SCHEDULE_ID        IN NUMBER
   ,P_OUTCOME_ID		  IN NUMBER
   ,P_RESULT_ID			  IN NUMBER
   ,P_RESULT_COUNT		  IN NUMBER
   ,P_FTC_ABANDON_COUNT    IN NUMBER
   ,P_MESSAGE_PLAYED_COUNT IN NUMBER
   ,P_POSITIVE_RESPONSE_FLAG	  IN VARCHAR2
   ,P_CONTACT_FLAG   		  IN VARCHAR2
   ,P_TOTAL_DIALS                 IN NUMBER
  )
  AS
  l_result_count NUMBER := 0;
BEGIN
--   begin
	l_result_count := P_RESULT_COUNT;

	if P_RESULT_COUNT = 0 AND P_OUTCOME_ID > 0
	then
	    l_result_count := 1;
	end if;

       insert into iec_rep_cpn_dial_stats (
	        cpn_dial_stats_id,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		campaign_id,
	  	campaign_schedule_id,
		dial_server_id,
		data_start_time,
		data_end_time,
		total_dials,
		outcome_id,
		result_id,
		result_count,
		positive_response_flag,
	  	security_group_id,
          	object_version_number,
		contact_flag
		)
    		values(
	        iec_rep_cpn_dial_stats_s.nextval,
	  	NVL(FND_GLOBAL.user_id,-1),
	  	sysdate,
	  	NVL(FND_GLOBAL.conc_login_id,-1),
	  	sysdate,
	  	NVL(FND_GLOBAL.conc_login_id,-1),
		P_CAMPAIGN_ID,
	  	P_CAMPAIGN_SCHEDULE_ID,
	  	P_DIAL_SERVER_ID,
		sysdate,
		sysdate,
		P_TOTAL_DIALS,
		P_OUTCOME_ID,
		P_RESULT_ID,
		l_result_count,
		P_POSITIVE_RESPONSE_FLAG,
	  	0,
		0,
		P_CONTACT_FLAG
		);

		UPDATE_CPN_SYS_OUTCOME_DETAILS
			( P_DIAL_SERVER_ID
			,P_CAMPAIGN_ID
			,P_CAMPAIGN_SCHEDULE_ID
			,P_OUTCOME_ID
			,P_RESULT_ID
			,l_RESULT_COUNT
      ,P_FTC_ABANDON_COUNT
      ,P_MESSAGE_PLAYED_COUNT
			,P_POSITIVE_RESPONSE_FLAG
			,P_CONTACT_FLAG
			,P_TOTAL_DIALS
			);

END  UPDATE_CPN_DIAL_STATS;


PROCEDURE UPDATE_CPN_SYS_OUTCOME_DETAILS
  ( P_DIAL_SERVER_ID		  IN NUMBER
   ,P_CAMPAIGN_ID	   		  IN  NUMBER
   ,P_CAMPAIGN_SCHEDULE_ID        IN NUMBER
   ,P_PREDICTIVE_OUTCOME_ID	  IN NUMBER
   ,P_PREDICTIVE_RESULT_ID	  IN NUMBER
   ,P_PREDICTIVE_RESULT_COUNT	  IN NUMBER
   ,P_FTC_ABANDON_COUNT    IN NUMBER
   ,P_MESSAGE_PLAYED_COUNT IN NUMBER
   ,P_POSITIVE_RESPONSE_FLAG	  IN VARCHAR2
   ,P_CONTACT_FLAG                IN VARCHAR2
   ,P_TOTAL_DIALS		  IN NUMBER
  )
  AS
  l_result_count NUMBER := 0;
  l_activity_time NUMBER := 0;
  l_login_time NUMBER := 0;

  l_rec_present NUMBER := 0;
  l_dialing_method VARCHAR2(10);

  l_ln_idle_time NUMBER := 0;
  l_ln_wait_time NUMBER := 0;
  l_ln_talk_time NUMBER := 0;
  l_ln_wrapup_time NUMBER := 0;

  l_sh_idle_time NUMBER := 0;
  l_sh_wait_time NUMBER := 0;
  l_sh_talk_time NUMBER := 0;
  l_sh_wrapup_time NUMBER := 0;

  l_mx_login_time NUMBER := 0;
  l_mx_activity_time NUMBER := 0;
  l_mx_idle_time NUMBER := 0;
  l_mx_wait_time NUMBER := 0;
  l_mx_talk_time NUMBER := 0;
  l_mx_wrapup_time NUMBER := 0;
  l_mx_calls_offered NUMBER := 0;
  l_mx_pred_calls_offered NUMBER := 0;

  l_total_dials NUMBER := 0;

BEGIN

   BEGIN
   	select dialing_method into l_dialing_method from
   	iec_g_executing_lists_v where schedule_id = P_CAMPAIGN_SCHEDULE_ID;

   Exception
   	When No_DATA_FOUND then
		l_dialing_method := 'UNKN';
   end;

   l_result_count := P_PREDICTIVE_RESULT_COUNT;

   if  l_result_count <= 0  AND P_PREDICTIVE_OUTCOME_ID > 0
   then
		l_result_count := 1;
		l_total_dials := 1;
   end if;

   begin
   	select campaign_rep_id
	       into
	       l_rec_present
	  from  iec_rep_campaign_details
         where  dial_server_id = P_DIAL_SERVER_ID
	   and  campaign_schedule_id = P_CAMPAIGN_SCHEDULE_ID
	   and  predictive_outcome_id = P_PREDICTIVE_OUTCOME_ID
	   and predictive_result_id = P_PREDICTIVE_RESULT_ID
   	   and nvl(agent_outcome_id, -999999 ) < 0;

	update iec_rep_campaign_details
	set  	predictive_outcome_id = P_PREDICTIVE_OUTCOME_ID,
		predictive_result_id = P_PREDICTIVE_RESULT_ID,
		dialing_mode = l_dialing_method,
		predictive_result_count = nvl( predictive_result_count, 0 ) + l_result_count,
    FTC_ABANDONMENT_COUNT = nvl(FTC_ABANDONMENT_COUNT, 0) + P_FTC_ABANDON_COUNT,
    MESSAGE_PLAYED_COUNT = nvl(MESSAGE_PLAYED_COUNT, 0) + P_MESSAGE_PLAYED_COUNT,
		positive_response_flag = P_POSITIVE_RESPONSE_FLAG,
		contact_flag = P_CONTACT_FLAG,
		total_dials = l_TOTAL_DIALS,
		last_updated_by = NVL(FND_GLOBAL.conc_login_id,-1),
		last_update_date = sysdate
	where  campaign_rep_id = l_rec_present;

   exception
   	When no_data_found then

	begin
		select campaign_rep_id
		into
		l_rec_present
		from  iec_rep_campaign_details
		where  dial_server_id = P_DIAL_SERVER_ID
		and  campaign_schedule_id = P_CAMPAIGN_SCHEDULE_ID
		and  nvl(predictive_outcome_id, -999999 ) = -999999
		and nvl(predictive_result_id, -999999) = -999999
		and nvl(agent_outcome_id, -999999 ) < 0;

		update iec_rep_campaign_details
		set  	predictive_outcome_id = P_PREDICTIVE_OUTCOME_ID,
			predictive_result_id = P_PREDICTIVE_RESULT_ID,
			dialing_mode = l_dialing_method,
			predictive_result_count = nvl( predictive_result_count, 0 ) + l_result_count,
      FTC_ABANDONMENT_COUNT = nvl(FTC_ABANDONMENT_COUNT, 0) + P_FTC_ABANDON_COUNT,
      MESSAGE_PLAYED_COUNT = nvl(MESSAGE_PLAYED_COUNT, 0) + P_MESSAGE_PLAYED_COUNT,
			positive_response_flag = P_POSITIVE_RESPONSE_FLAG,
			contact_flag = P_CONTACT_FLAG,
			total_dials = l_TOTAL_DIALS,
			last_updated_by = NVL(FND_GLOBAL.conc_login_id,-1),
			last_update_date = sysdate
		where  campaign_rep_id = l_rec_present;

	exception
		when no_data_found then
   		-- dbms_output.put_line( 'After Select...<'|| l_mx_idle_time||'> <'||l_mx_login_time);
			ADD_DUMMY_SYS_RECORD (
				P_DIAL_SERVER_ID
				,P_CAMPAIGN_ID
				,P_CAMPAIGN_SCHEDULE_ID
				,P_PREDICTIVE_OUTCOME_ID
				,P_PREDICTIVE_RESULT_ID
				,l_RESULT_COUNT
        ,P_FTC_ABANDON_COUNT
        ,P_MESSAGE_PLAYED_COUNT
				,P_POSITIVE_RESPONSE_FLAG
				,P_CONTACT_FLAG
				,l_dialing_method
			);
	end;
   end;

   	select max( nvl( total_login_time, 0 ) ),
	       max( nvl( total_activity_time, 0 ) ),
	       max( nvl( total_idle_time, 0 ) ),
	       max( nvl( total_wait_time, 0 ) ),
	       max( nvl( total_talk_time, 0 ) ),
	       max( nvl( total_wrapup_time, 0 ) ),
	       max( nvl( calls_offered, 0 ) ),
         max( nvl( predictive_calls_offered, 0 ) ),
		max(nvl( longest_idle_time, 0 )),
		max( nvl( longest_wait_time, 0 ) ),
		max(nvl( longest_talk_time, 0 ) ),
		max(nvl( longest_wrapup_time, 0 )),
		max(nvl( shortest_idle_time, 0 )),
		max(nvl( shortest_wait_time, 0 )),
		max(nvl( shortest_talk_time, 0 )),
		max(nvl( shortest_wrapup_time, 0 ))
	       into
	       l_mx_login_time,
	       l_mx_activity_time,
	       l_mx_idle_time,
	       l_mx_wait_time,
	       l_mx_talk_time,
	       l_mx_wrapup_time,
	       l_mx_calls_offered,
         l_mx_pred_calls_offered,
	  	l_ln_idle_time,
	  	l_ln_wait_time,
		l_ln_talk_time,
		l_ln_wrapup_time,
		l_sh_idle_time,
		l_sh_wait_time,
		l_sh_talk_time,
		l_sh_wrapup_time
	  from  iec_rep_campaign_details
         where  dial_server_id = P_DIAL_SERVER_ID
	   and  campaign_schedule_id = P_CAMPAIGN_SCHEDULE_ID;

	update iec_rep_campaign_details
	set total_login_time = l_mx_login_time,
		total_activity_time = l_mx_activity_time,
		total_idle_time = l_mx_idle_time,
		total_wait_time = l_mx_wait_time,
		total_talk_time = l_mx_talk_time,
		total_wrapup_time = l_mx_wrapup_time,
		longest_idle_time = l_ln_idle_time,
		longest_wait_time = l_ln_wait_time,
		longest_talk_time = l_ln_talk_time,
		longest_wrapup_time = l_ln_wrapup_time,
		shortest_idle_time = l_sh_idle_time,
		shortest_wait_time = l_sh_wait_time,
		shortest_talk_time = l_sh_talk_time,
		shortest_wrapup_time = l_sh_wrapup_time,
		calls_offered = l_mx_calls_offered,
    predictive_calls_offered = l_mx_pred_calls_offered,
		dialing_mode = l_dialing_method,
		last_updated_by = NVL(FND_GLOBAL.conc_login_id,-1),
		last_update_date = sysdate
	where  dial_server_id = P_DIAL_SERVER_ID
	and  campaign_schedule_id = P_CAMPAIGN_SCHEDULE_ID;

END UPDATE_CPN_SYS_OUTCOME_DETAILS;

PROCEDURE ADD_DUMMY_AGENT_RECORD
  ( P_DIAL_SERVER_ID		  IN NUMBER
   ,P_CAMPAIGN_ID	   		  IN  NUMBER
   ,P_CAMPAIGN_SCHEDULE_ID        IN NUMBER
   ,P_OUTCOME_ID		  IN NUMBER
   ,P_RESULT_ID			  IN NUMBER
   ,P_RESULT_COUNT		  IN NUMBER
   ,P_FTC_ABANDON_COUNT    IN NUMBER
   ,P_MESSAGE_PLAYED_COUNT IN NUMBER
   ,P_POSITIVE_RESPONSE_FLAG	  IN VARCHAR2
   ,P_CONTACT_FLAG                IN VARCHAR2
  )
  AS

  BEGIN

	       insert into iec_rep_campaign_details (
	        campaign_rep_id,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		campaign_id,
        	campaign_schedule_id,
		dial_server_id,
		dialing_mode,
		total_login_time,
		total_activity_time,
		num_login_agent,
		max_login_agent,
		total_idle_time,
		total_wait_time,
		total_wrapup_time,
		total_talk_time,
		longest_idle_time,
		longest_wait_time,
		longest_talk_time,
		longest_wrapup_time,
		shortest_idle_time,
		shortest_wait_time,
		shortest_talk_time,
		shortest_wrapup_time,
		total_dials,
		preview_dials,
		progressive_dials,
		predictive_dials,
		manual_dials,
		predictive_outcome_id,
		predictive_result_id,
		predictive_result_count,
		predictive_dial_fhq_count,
		calls_offered,
                predictive_calls_offered,
		agent_outcome_id,
		agent_result_id,
		agent_result_count,
		positive_response_flag,
		num_agents_on_call,
		num_agents_in_wrapup,
		num_agents_available,
		num_agents_idle,
		num_agents_on_break,
		security_group_id,
		object_version_number,
		contact_flag,
		num_cust_in_fhq,
    num_voice_detected,
    FTC_ABANDONMENT_COUNT,
    MESSAGE_PLAYED_COUNT
		)
		values
		(
		iec_rep_campaign_details_s.nextval,
		NVL(FND_GLOBAL.user_id,-1),
	  	sysdate,
	  	NVL(FND_GLOBAL.conc_login_id,-1),
	  	sysdate,
	  	NVL(FND_GLOBAL.conc_login_id,-1),
		P_CAMPAIGN_ID,
	  	P_CAMPAIGN_SCHEDULE_ID,
	  	P_DIAL_SERVER_ID,
		'UNKN',
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
		0,
		0,
		0,
		0,
		0,
		0,
		-999999,
		-999999,
		0,
		0,
		0,
                0,
		P_OUTCOME_ID,
		P_RESULT_ID,
		P_RESULT_COUNT,
		P_POSITIVE_RESPONSE_FLAG,
	  	0,
	  	0,
		0,
		0,
		0,
		0,
		0,
		P_CONTACT_FLAG,
		0,
    0,
    P_FTC_ABANDON_COUNT,
    P_MESSAGE_PLAYED_COUNT
		);

END ADD_DUMMY_AGENT_RECORD;


PROCEDURE ADD_DUMMY_SYS_RECORD
  ( P_DIAL_SERVER_ID		  IN NUMBER
   ,P_CAMPAIGN_ID	   		  IN  NUMBER
   ,P_CAMPAIGN_SCHEDULE_ID        IN NUMBER
   ,P_PREDICTIVE_OUTCOME_ID	  IN NUMBER
   ,P_PREDICTIVE_RESULT_ID	  IN NUMBER
   ,P_PREDICTIVE_RESULT_COUNT	  IN NUMBER
   ,P_FTC_ABANDON_COUNT    IN NUMBER
   ,P_MESSAGE_PLAYED_COUNT IN NUMBER
   ,P_POSITIVE_RESPONSE_FLAG	  IN VARCHAR2
   ,P_CONTACT_FLAG                IN VARCHAR2
   ,P_DIALING_METHOD		  IN VARCHAR2
  )
  AS
  BEGIN
  	insert into iec_rep_campaign_details (
	        campaign_rep_id,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		campaign_id,
        	campaign_schedule_id,
		dial_server_id,
		dialing_mode,
		total_login_time,
		total_activity_time,
		num_login_agent,
		max_login_agent,
		total_idle_time,
		total_wait_time,
		total_wrapup_time,
		total_talk_time,
		longest_idle_time,
		longest_wait_time,
		longest_talk_time,
		longest_wrapup_time,
		shortest_idle_time,
		shortest_wait_time,
		shortest_talk_time,
		shortest_wrapup_time,
		total_dials,
		preview_dials,
		progressive_dials,
		predictive_dials,
		manual_dials,
		predictive_outcome_id,
		predictive_result_id,
		predictive_result_count,
		predictive_dial_fhq_count,
		calls_offered,
    predictive_calls_offered,
		agent_outcome_id,
		agent_result_id,
		agent_result_count,
		positive_response_flag,
		num_agents_on_call,
		num_agents_in_wrapup,
		num_agents_available,
		num_agents_idle,
		num_agents_on_break,
		security_group_id,
		object_version_number,
		contact_flag,
		num_cust_in_fhq,
    num_voice_detected,
    FTC_ABANDONMENT_COUNT,
    MESSAGE_PLAYED_COUNT
		)
		values
		(
		iec_rep_campaign_details_s.nextval,
		NVL(FND_GLOBAL.user_id,-1),
	  	sysdate,
	  	NVL(FND_GLOBAL.conc_login_id,-1),
	  	sysdate,
	  	NVL(FND_GLOBAL.conc_login_id,-1),
		P_CAMPAIGN_ID,
	  	P_CAMPAIGN_SCHEDULE_ID,
	  	P_DIAL_SERVER_ID,
		P_DIALING_Method,
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
		0,
		P_PREDICTIVE_RESULT_COUNT,
		0,
		0,
		0,
		0,
		P_PREDICTIVE_OUTCOME_ID,
		P_PREDICTIVE_RESULT_ID,
		P_PREDICTIVE_RESULT_COUNT,
		0,
		0,
                0,
		-999999,
		-999999,
		0,
		P_POSITIVE_RESPONSE_FLAG,
	  	0,
	  	0,
		0,
		0,
		0,
		0,
		0,
		P_CONTACT_FLAG,
		0,
    0,
    P_FTC_ABANDON_COUNT,
    P_MESSAGE_PLAYED_COUNT
		);
  END ADD_DUMMY_SYS_RECORD;


-- HZH 04/27/2006 Add New Procedures for fixing a report problem
-- as decribed in bug 5123333. Four Procedures are added this time:
--
-- PROCEDURE UPDATE_ITEM_CC_TZS_COUNTS ()
-- PROCEDURE CHECK_ALL_CAMPAIGN_CC_TZS ()
-- PROCEDURE CHECK_ONE_CAMPAIGN_CC_TZS ()
-- PROCEDURE CHECK_SCHEDULE_CC_TZS()
--
-- At least one of the last three procedures should be called each time
-- when a report related to record counts is generated.
--
-- PROCEDURE UPDATE_ITEM_CC_TZS_COUNTS updates the Available and
-- Unavailable counts in IEC_G_MKTG_ITEM_CC_TZS
--
PROCEDURE UPDATE_ITEM_CC_TZS_COUNTS (
 X_ITM_CC_TZ_ID  IN NUMBER,
 X_STATUS OUT NOCOPY VARCHAR2
) is
  L_RECORD_AVAIL_COUNT   NUMBER;
  L_RECORD_UNAVAIL_COUNT NUMBER;
  L_CALLABLE_FLAG        VARCHAR2(1);
  L_LAST_CALLABLE_TIME   DATE;
BEGIN

  X_STATUS := 'SUCCESS';

    -- Get Unavailable Record Count First
    BEGIN
       SELECT NVL(COUNT(*), 0)
       INTO L_RECORD_UNAVAIL_COUNT
       FROM iec_g_return_entries a, IEC_G_MKTG_ITEM_CC_TZS C
       WHERE C.ITM_CC_TZ_ID = a.itm_cc_tz_id
             AND a.itm_cc_tz_id = X_ITM_CC_TZ_ID
             AND NVL(a.DO_NOT_USE_FLAG, 'N') = 'N'
             AND (C.CALLABLE_FLAG IS NULL
                  OR C.CALLABLE_FLAG <> 'Y'
                  OR C.LAST_CALLABLE_TIME < SYSDATE
                  OR (C.CALLABLE_FLAG = 'Y' AND C.LAST_CALLABLE_TIME > SYSDATE
                      AND a.callback_flag = 'Y' AND a.next_call_time > sysdate));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            L_RECORD_UNAVAIL_COUNT := 0;
         WHEN OTHERS THEN
            L_RECORD_UNAVAIL_COUNT := 0;
    END;

    L_CALLABLE_FLAG := NULL;

    -- Get Available Record Count
    --
    -- Check the section callable status first.
    -- If the section is not callable set the
    -- available count to 0 immediately
    -- to avoid scanning iec_g_return_entries

    BEGIN
       SELECT A.CALLABLE_FLAG,  A.LAST_CALLABLE_TIME
       INTO  L_CALLABLE_FLAG,  L_LAST_CALLABLE_TIME
       FROM IEC_G_MKTG_ITEM_CC_TZS A
       WHERE A.ITM_CC_TZ_ID = X_ITM_CC_TZ_ID;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            L_CALLABLE_FLAG := 'N';
          WHEN OTHERS THEN
            L_CALLABLE_FLAG := 'N';
    END;

    IF (L_CALLABLE_FLAG = NULL
        OR L_CALLABLE_FLAG = 'N'
        OR (L_CALLABLE_FLAG = 'Y'
            AND L_LAST_CALLABLE_TIME < SYSDATE))
    THEN
      -- Set the available count to 0 immediately
      -- if the section if not callable.
      --
      L_RECORD_AVAIL_COUNT := 0;
    ELSE
      --
      -- Section is callable, scan iec_g_return_entries
      -- All useable records are consider available except
      -- those records scheduled to be call back at
      -- a future time.
      --
      BEGIN
        SELECT NVL(COUNT(*), 0)
        INTO L_RECORD_AVAIL_COUNT
        FROM iec_g_return_entries a, IEC_G_MKTG_ITEM_CC_TZS C
        WHERE C.ITM_CC_TZ_ID = a.itm_cc_tz_id
             AND a.itm_cc_tz_id = X_ITM_CC_TZ_ID
             AND NVL(a.DO_NOT_USE_FLAG, 'N') = 'N'
             AND (C.CALLABLE_FLAG = 'Y' AND C.LAST_CALLABLE_TIME > SYSDATE
                  AND (NVL(a.callback_flag, 'N') = 'N'
                       OR a.next_call_time < sysdate));

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            L_RECORD_AVAIL_COUNT := 0;
          WHEN OTHERS THEN
            L_RECORD_AVAIL_COUNT := 0;
      END;
    END IF;

    -- Update IEC_G_MKTG_ITEM_CC_TZS with new Available and Unavailable counts.
    -- Some information updated by the servers are recorded for future reference
    -- in order to determine if a scan of records is needed.
    --
    BEGIN
        UPDATE IEC_G_MKTG_ITEM_CC_TZS
        SET
          ORG_CALLABLE_FLAG      = CALLABLE_FLAG,
          ORG_LAST_UPDATE_DATE   = LAST_UPDATE_DATE,
          ORG_LAST_CALLABLE_TIME = LAST_CALLABLE_TIME,
          COUNT_LAST_UPDATE_DATE = SYSDATE,
          ORG_RECORD_COUNT       = RECORD_COUNT,
          RECORD_AVAILABLE       = L_RECORD_AVAIL_COUNT,
          RECORD_UNAVAILABLE     = L_RECORD_UNAVAIL_COUNT
        WHERE ITM_CC_TZ_ID = X_ITM_CC_TZ_ID;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            X_STATUS := 'FAILED';
          WHEN OTHERS THEN
            X_STATUS := 'FAILED';
    END;
    COMMIT;
END UPDATE_ITEM_CC_TZS_COUNTS;

--
-- PROCEDURE CHECK_ALL_CAMPAIGN_CC_TZS checks all campaings
-- and updates the available and unavailable counts.
--
--
PROCEDURE CHECK_ALL_CAMPAIGN_CC_TZS
(
  X_CAMPAIGN_ID IN NUMBER
)
IS
  --------------------------------------------------------
  -- The following rules are set for the updates in order
  -- to keep the record counts recent and reduce the number of
  -- scans to avoid the performance problem, because each update
  -- needs to scan iec_g_return_entries.
  --
  -- The rules for checking all campaigns at the same time are
  -- the following:
  --
  --  1) COUNT_LAST_UPDATE_DATE is NULL, which
  --      happens when the  IEC_G_MKTG_ITEM_CC_TZS
  --      is updated the first time.
  --
  --  2) IEC_G_MKTG_ITEM_CC_TZS has been updated
  --      by the Central server or the Dial server
  --
  --  3) The CALLABLE_FLAG,  LAST_CALLABLE_TIME
  --      or RECORD_COUNT has been changed since
  --      the last update.
  --
  --  4) Available record count is greater than 0 when
  --      CC_TZ is not callable. This may happen when
  --      the LAST_CALLABLE_TIME is just past or
  --      the first time the record is checked since
  --      LAST_CALLABLE_TIME.
  --
  --  5) Unavailable record count is greater than 0 when
  --      CC_TZ is callable and the counts have not
  --      been updated in the past 3 minutes. This is
  --      to check if any callback records become available.
  --
  --  6) Any callable sections that are not checked for
  --       at least 5 minutes.
  --
  --  7) All CC_TZS record counts will be rechecked
  --     if the last update was at least 1 day ago.
  --
  --
  cursor check_all_camp_cursor is
    SELECT A.ITM_CC_TZ_ID
    FROM IEC_G_MKTG_ITEM_CC_TZS A
    WHERE  COUNT_LAST_UPDATE_DATE is NULL
           OR A.COUNT_LAST_UPDATE_DATE <  A.LAST_UPDATE_DATE
           OR A.ORG_LAST_UPDATE_DATE <> A.LAST_UPDATE_DATE
           OR A.ORG_CALLABLE_FLAG <> A.CALLABLE_FLAG
           OR A.ORG_LAST_CALLABLE_TIME <> A.LAST_CALLABLE_TIME
           OR A.ORG_RECORD_COUNT <> A.RECORD_COUNT
           OR ((A.CALLABLE_FLAG <> 'Y' OR A.LAST_CALLABLE_TIME < SYSDATE)
               AND RECORD_AVAILABLE > 0 )
           OR (A.CALLABLE_FLAG = 'Y'
               AND A.LAST_CALLABLE_TIME > SYSDATE
               AND RECORD_UNAVAILABLE > 0
               AND A.COUNT_LAST_UPDATE_DATE < SYSDATE - 3/(24*60))
           OR (A.CALLABLE_FLAG = 'Y'
               AND A.LAST_CALLABLE_TIME > SYSDATE
               AND A.COUNT_LAST_UPDATE_DATE < SYSDATE - 5/(24*60))
            OR A.COUNT_LAST_UPDATE_DATE < sysdate - 1;

  L_ITM_CC_TZ_ID         NUMBER;
  L_STATUS               VARCHAR2(30);

BEGIN

    OPEN check_all_camp_cursor;
    LOOP
      FETCH check_all_camp_cursor
        INTO L_ITM_CC_TZ_ID;
      EXIT WHEN check_all_camp_cursor%notfound;

      UPDATE_ITEM_CC_TZS_COUNTS (
          X_ITM_CC_TZ_ID          => L_ITM_CC_TZ_ID,
          X_STATUS                => L_STATUS
      );

      IF L_STATUS <> 'SUCCESS'
      THEN
        EXIT;
      END IF;
    END LOOP;

    CLOSE check_all_camp_cursor;

END CHECK_ALL_CAMPAIGN_CC_TZS;

--
-- PROCEDURE CHECK_ONE_CAMPAIGN_CC_TZS checks and
-- updates the available and unavailable counts
-- for a given campaign.
--
PROCEDURE CHECK_ONE_CAMPAIGN_CC_TZS
(
  X_CAMPAIGN_ID IN NUMBER
)
IS
  --------------------------------------------------------
  --
  -- The rules for checking one campaigns are
  -- similar to checking all campaings except
  -- rule 5:
  --
  --  5) Unavailable record count is greater than 0 when
  --      CC_TZ is callable and the counts have not
  --      been updated in the past 1 minutes. This is
  --      to check if any callback records become available.
  --

  cursor check_one_camp_cursor(X_CAMPAIGN_ID IN NUMBER) is
    SELECT A.ITM_CC_TZ_ID
    FROM IEC_G_MKTG_ITEM_CC_TZS A
    WHERE A.CAMPAIGN_SCHEDULE_ID in
          (SELECT UNIQUE C.SCHEDULE_ID
           FROM IEC_G_SCHEDULES_V c
           WHERE C.CAMPAIGN_ID = X_CAMPAIGN_ID)
        AND (A.COUNT_LAST_UPDATE_DATE is NULL
           OR A.COUNT_LAST_UPDATE_DATE <  A.LAST_UPDATE_DATE
           OR A.ORG_LAST_UPDATE_DATE <> A.LAST_UPDATE_DATE
           OR A.ORG_CALLABLE_FLAG <> A.CALLABLE_FLAG
           OR A.ORG_LAST_CALLABLE_TIME <> A.LAST_CALLABLE_TIME
           OR A.ORG_RECORD_COUNT <> A.RECORD_COUNT
           OR ((A.CALLABLE_FLAG <> 'Y' OR A.LAST_CALLABLE_TIME < SYSDATE)
               AND RECORD_AVAILABLE > 0 )
           OR (A.CALLABLE_FLAG = 'Y'
               AND A.LAST_CALLABLE_TIME > SYSDATE
               AND RECORD_UNAVAILABLE > 0
               AND A.COUNT_LAST_UPDATE_DATE < SYSDATE - 1/(24*60))
           OR (A.CALLABLE_FLAG = 'Y'
               AND A.LAST_CALLABLE_TIME > SYSDATE
               AND A.COUNT_LAST_UPDATE_DATE < SYSDATE - 5/(24*60))
            OR A.COUNT_LAST_UPDATE_DATE < sysdate - 1);

  L_ITM_CC_TZ_ID         NUMBER;
  L_STATUS               VARCHAR2(30);

  BEGIN

    OPEN check_one_camp_cursor(X_CAMPAIGN_ID);
    LOOP
      FETCH check_one_camp_cursor
        INTO L_ITM_CC_TZ_ID;
      EXIT WHEN check_one_camp_cursor%notfound;

      UPDATE_ITEM_CC_TZS_COUNTS (
          X_ITM_CC_TZ_ID          => L_ITM_CC_TZ_ID,
          X_STATUS                => L_STATUS
      );

      IF L_STATUS <> 'SUCCESS'
      THEN
        EXIT;
      END IF;
    END LOOP;

    CLOSE check_one_camp_cursor;

END CHECK_ONE_CAMPAIGN_CC_TZS;

--
-- PROCEDURE CHECK_SCHEDULE_CC_TZS checks and
-- updates the available and unavailable counts
-- for a given schedule.
--
PROCEDURE CHECK_SCHEDULE_CC_TZS
(
    X_SCHEDULE_ID IN NUMBER
)
IS
  --------------------------------------------------------
  --
  -- The rules for checking one schedule are
  -- same as those for one campaign.
  --

  cursor check_schedule_cursor(X_SCHEDULE_ID IN NUMBER) is
    SELECT A.ITM_CC_TZ_ID
    FROM IEC_G_MKTG_ITEM_CC_TZS A
    WHERE A.CAMPAIGN_SCHEDULE_ID =  X_SCHEDULE_ID
       AND (A.COUNT_LAST_UPDATE_DATE is NULL
           OR A.COUNT_LAST_UPDATE_DATE <  A.LAST_UPDATE_DATE
           OR A.ORG_LAST_UPDATE_DATE <> A.LAST_UPDATE_DATE
           OR A.ORG_CALLABLE_FLAG <> A.CALLABLE_FLAG
           OR A.ORG_LAST_CALLABLE_TIME <> A.LAST_CALLABLE_TIME
           OR A.ORG_RECORD_COUNT <> A.RECORD_COUNT
           OR ((A.CALLABLE_FLAG <> 'Y' OR A.LAST_CALLABLE_TIME < SYSDATE)
               AND RECORD_AVAILABLE > 0 )
           OR (A.CALLABLE_FLAG = 'Y'
               AND A.LAST_CALLABLE_TIME > SYSDATE
               AND RECORD_UNAVAILABLE > 0
               AND A.COUNT_LAST_UPDATE_DATE < SYSDATE - 1/(24*60))
           OR (A.CALLABLE_FLAG = 'Y'
               AND A.LAST_CALLABLE_TIME > SYSDATE
               AND A.COUNT_LAST_UPDATE_DATE < SYSDATE - 5/(24*60))
            OR A.COUNT_LAST_UPDATE_DATE < sysdate - 1);

  L_ITM_CC_TZ_ID         NUMBER;
  L_STATUS               VARCHAR2(30);

  BEGIN

    OPEN check_schedule_cursor(X_SCHEDULE_ID);
    LOOP
      FETCH check_schedule_cursor
        INTO L_ITM_CC_TZ_ID;
      EXIT WHEN check_schedule_cursor%notfound;

      UPDATE_ITEM_CC_TZS_COUNTS (
          X_ITM_CC_TZ_ID          => L_ITM_CC_TZ_ID,
          X_STATUS                => L_STATUS
      );

      IF L_STATUS <> 'SUCCESS'
      THEN
        EXIT;
      END IF;
    END LOOP;

    CLOSE check_schedule_cursor;

END CHECK_SCHEDULE_CC_TZS;

END IEC_REPORTS_UTIL_PVT;

/
