--------------------------------------------------------
--  DDL for Package EDR_CONSTANTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_CONSTANTS_PUB" AUTHID CURRENT_USER AS
/* $Header: EDRPCONS.pls 120.0.12000000.2 2007/02/20 11:41:11 rvsingh ship $

/* Global Constants */

-- status codes --
g_error_status                	CONSTANT VARCHAR2(20)   := 'ERROR';
g_pending_status            	CONSTANT VARCHAR2(20) 	:= 'PENDING';
g_no_action_status          	CONSTANT VARCHAR2(20) 	:= 'NOACTION';
g_complete_status          	CONSTANT VARCHAR2(20) 	:= 'COMPLETE';
g_indetermined_status 		CONSTANT VARCHAR2(20) 	:= 'INDETERMINED';
--g_initial_status 		CONSTANT VARCHAR2(20) 	:= 'INITIAL';

-- mandatory payload parameter names --
g_deferred_param      		CONSTANT VARCHAR2(30) 	:= 'DEFERRED';
g_postop_param      		CONSTANT VARCHAR2(30) 	:= 'POST_OPERATION_API';
g_user_label_param      	CONSTANT VARCHAR2(30) 	:= 'PSIG_USER_KEY_LABEL';
g_user_value_param      	CONSTANT VARCHAR2(30) 	:= 'PSIG_USER_KEY_VALUE';
g_audit_param      		CONSTANT VARCHAR2(30) 	:= 'PSIG_TRANSACTION_AUDIT_ID';
g_source_param      		CONSTANT VARCHAR2(30) 	:= '#WF_SOURCE_APPLICATION_TYPE';
g_requester_param      		CONSTANT VARCHAR2(30) 	:= '#WF_SIGN_REQUESTER';

-- additional payload parameter names --
g_wf_pageflow_itemtype_attr 	CONSTANT VARCHAR2(30) 	:= '#WF_PAGEFLOW_ITEMTYPE';
g_wf_pageflow_itemkey_attr  	CONSTANT VARCHAR2(30) 	:= '#WF_PAGEFLOW_ITEMKEY';
g_erecord_id_attr           	CONSTANT VARCHAR2(15) 	:= '#ERECORD_ID';
g_parent_event_name         	CONSTANT VARCHAR2(30) 	:= 'PARENT_EVENT_NAME';
g_parent_event_key          	CONSTANT VARCHAR2(30) 	:= 'PARENT_EVENT_KEY';
g_parent_erecord_id         	CONSTANT VARCHAR2(30) 	:= 'PARENT_ERECORD_ID';

-- relationship record group column name --
g_child_event_name          	CONSTANT VARCHAR2(30) 	:= 'CHILD_EVENT_NAME';
g_child_event_key           	CONSTANT VARCHAR2(30) 	:= 'CHILD_EVENT_KEY';
g_child_erecord_id          	CONSTANT VARCHAR2(30) 	:= 'CHILD_ERECORD_ID';

-- attachment entity name --
g_erecord_entity_name       	CONSTANT VARCHAR2(15) 	:= 'ERECORD';

-- susbcription parameter values for establishing inter event relationships --
g_evaluate_normal           	CONSTANT VARCHAR2(30) 	:= 'EVALUATE_NORMAL';
g_erecord_only		      	CONSTANT VARCHAR2(30) 	:= 'ERECORD_ONLY';
g_ignore_signature	      	CONSTANT VARCHAR2(30) 	:= 'IGNORE_SIGNATURE';

-- payload parameter count --
g_param_count 			CONSTANT PLS_INTEGER	:= 7;
g_inter_event_param_count	CONSTANT PLS_INTEGER	:= 3;

-- payload parameters values --
g_forms_mode      		CONSTANT VARCHAR2(15) 	:= 'FORMS';
g_db_mode      			CONSTANT VARCHAR2(15) 	:= 'DB';
g_default_char_param_value	CONSTANT VARCHAR2(15) 	:= 'NONE';
g_default_num_param_value	CONSTANT NUMBER 	:= -1;
--Bug 5891879:Start
g_kiosk_mode                  CONSTANT VARCHAR2(15)  :=  'KIOSK';
--Bug 5891879: End

-- messages --
/*
g_invalid_source_param_mesg 	CONSTANT VARCHAR2(2000) := fnd_message.get_string('EDR','EDR_VAL_INVALID_SOURCE');
g_invalid_deferred_param_mesg   CONSTANT VARCHAR2(2000) := fnd_message.get_string('EDR','EDR_VAL_INVALID_DEFERRED');
g_invalid_payload_mesg 		CONSTANT VARCHAR2(2000) := fnd_message.get_string('EDR','EDR_VAL_INVALID_PAYLOAD');
g_interevent_param_mesg 	CONSTANT VARCHAR2(2000) := fnd_message.get_string('EDR','EDR_VAL_INVALID_INTER_EVENT');
g_invalid_interevent_db_mesg	CONSTANT VARCHAR2(2000) := fnd_message.get_string('EDR','EDR_VAL_INTER_EVENT_DB');
g_event_raise_error_mesg	CONSTANT VARCHAR2(2000) := fnd_message.get_string('EDR','EDR_EVENT_RAISE_ERROR');
*/

-- mode of inter event processing --
g_strict_mode 			CONSTANT VARCHAR2(15) 	:= 'STRICT';

--Bug 2637353: Start
g_max_int CONSTANT NUMBER := 32767;
g_msca_source CONSTANT VARCHAR2(4) := 'MSCA';
--Bug 2367353: End


end EDR_CONSTANTS_PUB;

 

/
