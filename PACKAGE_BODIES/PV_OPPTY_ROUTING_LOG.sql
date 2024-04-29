--------------------------------------------------------
--  DDL for Package Body PV_OPPTY_ROUTING_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_OPPTY_ROUTING_LOG" as
/* $Header: pvxvorlb.pls 120.1 2006/03/10 15:02:31 amaram noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_OPPTY_ROUTING_LOG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_OPPTY_ROUTING_LOG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvorlb.pls';

G_USER_ID    CONSTANT     NUMBER := NVL(FND_GLOBAL.USER_ID, -1);
G_LOGIN_ID   CONSTANT     NUMBER := NVL(FND_GLOBAL.CONC_LOGIN_ID, -1);

---------------------------------------------------------------------
-- FUNCTION
--    GET_ADDTNL_LOG_DETAILS
--
-- PURPOSE
--    Based on the OPPTY_ROUTING_log_id,  event, LEAD_WORKFLOW_ID, LEAD_ASSIGNMENT_ID
--   This function returns the additional details about oppty history log
--
-- PARAMETERS
--    OPPTY_ROUTING_log_id,  event, LEAD_WORKFLOW_ID, LEAD_ASSIGNMENT_ID
--    returns additional details as varchar2
--
-- NOTES
--
---------------------------------------------------------------------

FUNCTION GET_ADDTNL_LOG_DETAILS (       p_oppty_routing_log_id     NUMBER,
                                        p_event						VARCHAR2,
                                        p_lead_workflow_id			NUMBER,
										p_lead_assignment_id		NUMBER
				 )
RETURN VARCHAR2

AS

	CURSOR  lc_oppty_assign_addtnl_details (pc_oppty_routing_log_id NUMBER)
	IS
	SELECT
		party.party_name,
		decode (logs.BYPASS_CM_FLAG,
		'N',fnd_message.get_string('PV','PV_ASSIGN_CM_APPRVL_REQ'),
		'Y',fnd_message.get_string('PV','PV_ASSIGN_CM_APPRVL_NOT_REQ'),
		fnd_message.get_string('PV','PV_ASSIGN_CM_APPRVL_NOTREQ')) bypass_message,
		plkp1.meaning routing_type_meaning
	FROM
		pv_lead_assignments assgn,
		pv_lead_workflows ldwf,
		pv_partner_profiles partprof,
		hz_parties party,
		pv_oppty_routing_logs logs,
		pv_lookups plkp1
	WHERE
		logs.oppty_routing_log_id= pc_oppty_routing_log_id
		and ldwf.lead_workflow_id= logs.lead_workflow_id
		--and ldwf.WF_ITEM_TYPE <> 'PVLEADAS'
		and ldwf.WF_ITEM_TYPE = assgn.WF_ITEM_TYPE
		and ldwf.WF_ITEM_KEY = assgn.WF_ITEM_KEY
		and assgn.partner_id = partprof.partner_id
		and partprof.partner_party_id = party.party_id
		and plkp1.lookup_type (+)='PV_ASSIGNMENT_TYPE'
		and plkp1.lookup_code (+) = logs.routing_type
	;
	CURSOR  lc_assign_rej_acc_addtnl_dtls (pc_lead_assignment_id NUMBER)
	IS
	SELECT
		party.party_name
	FROM
		pv_lead_assignments assgn,
		pv_partner_profiles partprof,
		hz_parties party
	WHERE
		assgn.lead_assignment_id = pc_lead_assignment_id --10569
		and assgn.partner_id = partprof.partner_id
		and partprof.partner_party_id = party.party_id
	;
	CURSOR  lc_oppty_timeout_addtnl_dtls (pc_lead_assignment_id NUMBER)
	IS
	SELECT
		party.party_name
	FROM
		pv_lead_assignments assgn,
		pv_partner_profiles partprof,
		hz_parties party
	WHERE
		assgn.lead_assignment_id = pc_lead_assignment_id --10569
		and assgn.partner_id = partprof.partner_id
		and partprof.partner_party_id = party.party_id
	;
	CURSOR  lc_assign_withdr_addtnl_dtls (pc_lead_assignment_id NUMBER)
	IS
	SELECT
		party.party_name
	FROM
		pv_lead_assignments assgn,
		pv_partner_profiles partprof,
		hz_parties party
	WHERE
		assgn.lead_assignment_id = pc_lead_assignment_id --10569
		and assgn.partner_id = partprof.partner_id
		and partprof.partner_party_id = party.party_id
	;
	CURSOR  lc_oppty_withdr_addtnl_dtls (pc_lead_assignment_id NUMBER)
	IS
	SELECT
		party.party_name
	FROM
		pv_lead_assignments assgn,
		pv_partner_profiles partprof,
		hz_parties party
	WHERE
		assgn.lead_assignment_id = pc_lead_assignment_id --10569
		and assgn.partner_id = partprof.partner_id
		and partprof.partner_party_id = party.party_id
	;
	CURSOR  lc_oppty_decl_addtnl_details (pc_oppty_routing_log_id NUMBER)
	IS
	select
		logs.user_response,
		logs.reason_code,
		plkp1.meaning response_meaning,
		plkp2.meaning reason_meaning

	from
		pv_oppty_routing_logs logs,
		pv_lookups plkp1,
		pv_lookups plkp2

	where
		logs.oppty_routing_log_id= pc_oppty_routing_log_id
		and plkp1.lookup_type (+) = 'PV_ASSIGNMENT_STATUS'
		and plkp1.lookup_code (+) = logs.user_response
		and plkp2.lookup_type (+) = 'PV_REASON_CODES'
		and plkp2.lookup_code (+) = logs.reason_code
	;
	CURSOR  lc_oppty_abdn_addtnl_details (pc_oppty_routing_log_id NUMBER)
	IS
	select
		logs.user_response,
		logs.reason_code,
		plkp1.meaning response_meaning,
		plkp2.meaning reason_meaning

	from
		pv_oppty_routing_logs logs,
		pv_lookups plkp1,
		pv_lookups plkp2

	where
		logs.oppty_routing_log_id= pc_oppty_routing_log_id
		and plkp1.lookup_type (+) = 'PV_ASSIGNMENT_STATUS'
		and plkp1.lookup_code (+) = logs.user_response
		and plkp2.lookup_type (+) = 'PV_REASON_CODES'
		and plkp2.lookup_code (+) = logs.reason_code
	;
	CURSOR  lc_assgn_fail_addtnl_details (pc_lead_workflow_id NUMBER)
	IS
	select
		ldwf.failure_code,
		ldwf.failure_message
	from
		pv_lead_workflows ldwf
	where
		ldwf.lead_workflow_id= pc_lead_workflow_id
	;

	CURSOR  lc_oppty_check_cm_timeout (pc_lead_assignment_id NUMBER)
	IS
	select resource_response
	    from pv_party_notifications
	    where lead_assignment_id=pc_lead_assignment_id
	    and notification_type='MATCHED_TO';


	l_bypass_message         VARCHAR2(200);
	l_routing_type_meaning   VARCHAR2(200) ;
	l_addtnl_details	VARCHAR2(32000) ;
	l_cm_timeout       VARCHAR2(1) := 'N';
	l_lead_description VARCHAR2(240);

BEGIN

	l_bypass_message := '';
	l_routing_type_meaning   := '';
	l_addtnl_details := '';

	begin
		if(p_event= 'OPPTY_ASSIGN') then

			for x in lc_oppty_assign_addtnl_details(pc_oppty_routing_log_id => p_oppty_routing_log_id)
			loop
				l_routing_type_meaning := x.routing_type_meaning;
				l_bypass_message := x.bypass_message;
				l_addtnl_details := l_addtnl_details || gc_partner_message || ': ' || x.party_name || '<br>';
			end loop;

			l_addtnl_details := gc_assignment_type_message || ': '|| l_routing_type_meaning
			|| '. <br>' || l_bypass_message || '. ' || '<br>' || l_addtnl_details;


		elsif (p_event = 'ASSIGN_ACCEPT') then
			for y in lc_oppty_check_cm_timeout(pc_lead_assignment_id => p_lead_assignment_id)
			loop
				if(y.resource_response= 'CM_TIMEOUT') then
				    l_cm_timeout := 'Y';
				else
				    l_cm_timeout := 'N';
				    exit;
				end if;

			end loop;

			if(l_cm_timeout = 'Y' ) then
				select ldall.description
				into l_lead_description
				from as_leads_all ldall,
				pv_lead_assignments ldass
				where ldass.lead_id=ldall.lead_id and
				ldass.lead_assignment_id=p_lead_assignment_id;

				l_addtnl_details := l_addtnl_details || gc_oppty_cm_timeout_message || ': '  || l_lead_description || '.<br>';
			end if;

			for x in lc_assign_rej_acc_addtnl_dtls(pc_lead_assignment_id => p_lead_assignment_id)
			loop
				l_addtnl_details := l_addtnl_details || gc_partner_message || ': ' || x.party_name || '<br>';
			end loop;

		elsif (p_event = 'ASSIGN_REJECT') then

			for x in lc_assign_rej_acc_addtnl_dtls(pc_lead_assignment_id => p_lead_assignment_id)
			loop
				l_addtnl_details := l_addtnl_details || gc_partner_message || ': ' || x.party_name || '<br>';
			end loop;

		elsif (p_event = 'ASSIGN_WITHDRAW') then

			for x in lc_assign_withdr_addtnl_dtls(pc_lead_assignment_id => p_lead_assignment_id)
			loop
				l_addtnl_details := l_addtnl_details || gc_partner_message || ': ' || x.party_name || '<br>';
			end loop;

		elsif (p_event = 'OPPTY_WITHDRAW') then

			for x in lc_oppty_withdr_addtnl_dtls(pc_lead_assignment_id => p_lead_assignment_id)
			loop
				l_addtnl_details := l_addtnl_details || gc_partner_message || ': ' || x.party_name || '<br>';
			end loop;

		elsif (p_event = 'OPPTY_ABANDON') then

			for x in lc_oppty_abdn_addtnl_details(pc_oppty_routing_log_id => p_oppty_routing_log_id)
			loop
				l_addtnl_details := l_addtnl_details || gc_decline_reason_message  || ': ' || x.reason_meaning || '<br>';
			end loop;

		elsif (p_event = 'OPPTY_ACCEPT') then
			l_addtnl_details := ' ';

		elsif (p_event = 'OPPTY_DECLINE') then

			for x in lc_oppty_decl_addtnl_details(pc_oppty_routing_log_id => p_oppty_routing_log_id)
			loop
				l_addtnl_details := l_addtnl_details || gc_decline_reason_message  || ': ' || x.reason_meaning || '<br>';
			end loop;

		elsif (p_event = 'ASSIGN_FAIL') then

			for x in lc_assgn_fail_addtnl_details(pc_lead_workflow_id => p_lead_workflow_id)
			loop
				l_addtnl_details := l_addtnl_details || x.failure_code || '; ' || x.failure_message || '<br>';
			end loop;

		elsif (p_event = 'OPPTY_RECYCLE') then

			for x in lc_oppty_timeout_addtnl_dtls(pc_lead_assignment_id => p_lead_assignment_id)
			loop
				l_addtnl_details := l_addtnl_details || gc_oppty_timeout_message || ': ' || x.party_name || '<br>';
			end loop;

		elsif (p_event = 'OPPTY_TAKEN') then
			l_addtnl_details := ' ';
		else
			l_addtnl_details := ' ';
		end if;


	EXCEPTION
	when others then
		l_addtnl_details := ' ';

	end;

	--return  substr(l_value, 1, length(l_value)-2);
	return  l_addtnl_details;


END GET_ADDTNL_LOG_DETAILS;






END PV_OPPTY_ROUTING_LOG;

/
