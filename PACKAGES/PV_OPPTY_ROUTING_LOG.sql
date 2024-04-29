--------------------------------------------------------
--  DDL for Package PV_OPPTY_ROUTING_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_OPPTY_ROUTING_LOG" AUTHID CURRENT_USER AS
/* $Header: pvxvorls.pls 120.1 2006/03/10 15:02:11 amaram noship $ */
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




---------------------------------------------------------------------
-- FUNCTION
--    GET_ADDTNL_LOG_DETAILS
--
-- PURPOSE
--    Based on the OPPTY_ROUTING_LOGS_ID,  event, LEAD_WORKFLOW_ID, LEAD_ASSIGNMENT_ID
--   This function returns the additional details about oppty history log
--
-- PARAMETERS
--    OPPTY_ROUTING_LOGS_ID,  event, LEAD_WORKFLOW_ID, LEAD_ASSIGNMENT_ID
--    returns additional details as varchar2
--
-- NOTES
--
---------------------------------------------------------------------

	gc_partner_message   VARCHAR2(200) := fnd_message.get_string('PV','PV_PARTNER');
	gc_assignment_type_message   VARCHAR2(200) := fnd_message.get_string('PV','PV_ASSIGNMENT_TYPE');
	gc_decline_reason_message   VARCHAR2(200) := fnd_message.get_string('PV','PV_DECLINE_REASON');
	gc_oppty_timeout_message   VARCHAR2(200) := fnd_message.get_string('PV','PV_ASSIGN_OPPTY_TIMEOUT');
        gc_oppty_cm_timeout_message   VARCHAR2(200) := fnd_message.get_string('PV','PV_ASSIGN_CM_TIMEOUT');

	FUNCTION GET_ADDTNL_LOG_DETAILS (       p_oppty_routing_log_id     NUMBER,
                                        p_event			VARCHAR2,
                                        p_lead_workflow_id     NUMBER,
					p_lead_assignment_id	NUMBER
				 )
RETURN VARCHAR2 DETERMINISTIC;

END PV_OPPTY_ROUTING_LOG;

 

/
