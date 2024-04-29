--------------------------------------------------------
--  DDL for Package EDR_CONSTANTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_CONSTANTS_GRP" AUTHID CURRENT_USER AS
/* $Header: EDRGCONS.pls 120.3.12000000.1 2007/01/18 05:53:23 appldev ship $

/* Global Constants */

-- status codes --

-- These are different statuses that are returned to the calling code
-- from ERES Framework to indicate the status of the ERES processing

-- All the code using these constants and the cookbook need to be changed
-- if any chages are made

g_error_status                  CONSTANT VARCHAR2(20)   := 'ERROR';
g_pending_status              CONSTANT VARCHAR2(20)   := 'PENDING';
g_no_action_status            CONSTANT VARCHAR2(20)   := 'NOACTION';
g_complete_status           CONSTANT VARCHAR2(20)   := 'COMPLETE';
g_indetermined_status     CONSTANT VARCHAR2(20)   := 'INDETERMINED';

-- mandatory payload parameter names --

-- These are the names of the parameters that are REQUIRED to be present
-- in the payload at the time of raising an ERES event

g_deferred_param          CONSTANT VARCHAR2(30)   := 'DEFERRED';
g_postop_param          CONSTANT VARCHAR2(30)   := 'POST_OPERATION_API';
g_user_label_param        CONSTANT VARCHAR2(30)   := 'PSIG_USER_KEY_LABEL';
g_user_value_param        CONSTANT VARCHAR2(30)   := 'PSIG_USER_KEY_VALUE';
g_audit_param         CONSTANT VARCHAR2(30)   := 'PSIG_TRANSACTION_AUDIT_ID';
g_source_param          CONSTANT VARCHAR2(30)   := '#WF_SOURCE_APPLICATION_TYPE';
g_requester_param         CONSTANT VARCHAR2(30)   := '#WF_SIGN_REQUESTER';

-- additional payload parameter names --

-- These are additional parameters that are added to the payload implicitly at the
-- time of raising an event by the ERES code itself

g_wf_pageflow_itemtype_attr   CONSTANT VARCHAR2(30)   := '#WF_PAGEFLOW_ITEMTYPE';
g_wf_pageflow_itemkey_attr    CONSTANT VARCHAR2(30)   := '#WF_PAGEFLOW_ITEMKEY';
g_erecord_id_attr             CONSTANT VARCHAR2(15)   := '#ERECORD_ID';

-- These are additional mandatory parameters required to be present in the payload
-- if the event is a child event in the context of an inter event relationship

g_parent_event_name           CONSTANT VARCHAR2(30)   := 'PARENT_EVENT_NAME';
g_parent_event_key            CONSTANT VARCHAR2(30)   := 'PARENT_EVENT_KEY';
g_parent_erecord_id           CONSTANT VARCHAR2(30)   := 'PARENT_ERECORD_ID';

-- relationship record group column name --

g_child_event_name            CONSTANT VARCHAR2(30)   := 'CHILD_EVENT_NAME';
g_child_event_key             CONSTANT VARCHAR2(30)   := 'CHILD_EVENT_KEY';
g_child_erecord_id            CONSTANT VARCHAR2(30)   := 'CHILD_ERECORD_ID';

-- attachment entity name --
g_erecord_entity_name         CONSTANT VARCHAR2(15)   := 'ERECORD';

-- susbcription parameter values for establishing inter event relationships --
g_evaluate_normal             CONSTANT VARCHAR2(30)   := 'EVALUATE_NORMAL';
g_erecord_only            CONSTANT VARCHAR2(30)   := 'ERECORD_ONLY';
g_ignore_signature          CONSTANT VARCHAR2(30)   := 'IGNORE_SIGNATURE';

-- payload parameter count --
g_param_count       CONSTANT PLS_INTEGER  := 7;
g_inter_event_param_count CONSTANT PLS_INTEGER  := 3;

-- payload parameters values --
g_forms_mode          CONSTANT VARCHAR2(15)   := 'FORMS';
g_db_mode           CONSTANT VARCHAR2(15)   := 'DB';
g_msca_mode                   CONSTANT VARCHAR2(15)   := 'MSCA';
g_change_signer_adhoc         CONSTANT VARCHAR2(15)   := 'ADHOC';
g_oaf_mode          CONSTANT VARCHAR2(15)   := 'SSWA';
g_default_char_param_value  CONSTANT VARCHAR2(15)   := 'NONE';
g_default_num_param_value CONSTANT NUMBER   := -1;


-- mode of inter event processing --
g_strict_mode       CONSTANT VARCHAR2(20)   := 'STRICT';

-- name of the standard ERES rule function --
g_rule_function                 CONSTANT VARCHAR2(240)   := 'EDR_PSIG_RULE.PSIG_RULE';

-- transaction acknowledgement statuses --
g_success_ack_status            CONSTANT VARCHAR2(30)    := 'SUCCESS';
g_error_ack_status              CONSTANT VARCHAR2(30)    := 'ERROR';
g_no_ack_status                 CONSTANT VARCHAR2(30)    := 'NOTACKNOWLEDGED';
g_migration_ack_status          CONSTANT VARCHAR2(30)    := 'NOTCOLLECTED';


-- mode of the redling  --
g_redline_mode                  CONSTANT VARCHAR2(30)   := 'REDLINE';
g_redline_with_appendix_mode    CONSTANT VARCHAR2(30)   := 'REDLINE_WITH_APPENDIX';

--Bug 4122622: Start
G_TEMP_PARAM_LIST               FND_WF_EVENT.PARAM_TABLE;
--This would hold a constant empty parameter list variable.
G_EMPTY_PARAM_LIST              CONSTANT FND_WF_EVENT.PARAM_TABLE := G_TEMP_PARAM_LIST;

--The child e-record IDs attribute value set on the event.
G_CHILD_ERECORD_IDS             CONSTANT VARCHAR2(30)             :=  'CHILD_ERECORD_IDS';


G_DEFAULT_CHAR_ID_VALUE         CONSTANT NUMBER                   := '-1';
--Bug 4122622: End

--Bug 4150616: Start
G_FORCE_ERECORD                 CONSTANT VARCHAR2(30)             :=  'FORCE_ERECORD';
G_FORCE_ERECORD_USED            CONSTANT VARCHAR2(30)             :=  'FORCE_ERECORD_USED';
--Bug 4150616: End

--Bug 3207385: Start
G_ORIGINAL_EVENT_NAME           CONSTANT VARCHAR2(30)             :=  'ORIGINAL_EVENT_NAME';
G_ORIGINAL_EVENT_KEY            CONSTANT VARCHAR2(30)             :=  'ORIGINAL_EVENT_KEY';
G_ERECORD_ID                    CONSTANT VARCHAR2(30)             :=  'ERECORD_ID';
G_EVENT_STATUS                  CONSTANT VARCHAR2(30)             :=  'EVENT_STATUS';
G_NO_ERES_STATUS                CONSTANT VARCHAR2(30)             :=  'NO_ERES';
G_CANCEL_STATUS                 CONSTANT VARCHAR2(30)             :=  'CANCEL';
G_FINAL_DOCUMENT_STATUS         CONSTANT VARCHAR2(30)             :=  'FINAL_DOCUMENT_STATUS';
G_APPROVAL_COMPLETION_EVT       CONSTANT VARCHAR2(40)             :=  'oracle.apps.edr.approvalcompletion';
--Bug 3207385: End

--Bug 4160412: Start
G_SIGNATURE_MODE                CONSTANT VARCHAR2(30)             :=  'SIGNATURE_MODE';
G_SIGNATURE_MODE_VALUE          CONSTANT VARCHAR2(30)             :=  'SIGNATURE_MODE_VALUE';
G_APPROVER_COUNT                CONSTANT VARCHAR2(30)             :=  'APPROVER_COUNT';
G_APPROVER_LIST                 CONSTANT VARCHAR2(30)             :=  'APPROVER_LIST';
G_EINITIALS_DEFER_MODE          CONSTANT VARCHAR2(30)             :=  'EINITIALS_DEFER_MODE';
G_DO_RESPS_EXIST                CONSTANT VARCHAR2(30)             :=  'DO_RESPS_EXIST';
G_ERECORD_XML_HEADER            CONSTANT VARCHAR2(60)             :=  '<?xml version="1.0" encoding="utf-8"?><ERecord>';
G_ERECORD_XML_FOOTER            CONSTANT VARCHAR2(30)             :=  '</ERecord>';
--Bug 4160412: End

-- Bug 4450651   Start For Http Service Ticket
g_service_name                  CONSTANT VARCHAR2(30)             := 'EDR_HTTP_SERVICE_TICKET';
g_fail_service_req_status       CONSTANT VARCHAR2(20)             := 'FAIL';
g_success_service_req_status    CONSTANT VARCHAR2(30)             := 'SUCCESS';
-- Bug 4450651   End

--Bug 4543216: Start
G_ERES_LITE                     CONSTANT VARCHAR2(30)             := 'SHORT';
G_ERES_REGULAR                  CONSTANT VARCHAR2(30)             := 'FULL';
--bUG 4543216: End

end EDR_CONSTANTS_GRP;

 

/
