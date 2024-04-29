--------------------------------------------------------
--  DDL for Package XNP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_UTILS" AUTHID CURRENT_USER AS
/* $Header: XNPUTILS.pls 120.1 2005/06/24 04:49:47 appldev ship $ */

G_DEBUG_LEVEL     NUMBER ;
G_ERROR           CONSTANT NUMBER := 1 ;
G_WARNING         CONSTANT NUMBER := 2 ;
G_INFORMATIONAL   CONSTANT NUMBER := 3 ;

-- Cursor to retrive the fe name for a service provider given
-- what adapters are serving the service provider
--
	CURSOR g_get_fe_name_for_sp_csr( p_sp_id IN NUMBER ) IS
                SELECT fulfillment_element_name
		FROM xdp_fes FET,
			xnp_sp_adapters SPA,
			xdp_fe_generic_config SWG
		WHERE FET.fe_id = SPA.fe_id
		AND SPA.fe_id = SWG.fe_id
		AND SPA.sp_id = p_sp_id
		AND (sysdate BETWEEN SWG.start_date
		AND NVL(SWG.end_date, sysdate))
		ORDER BY preferred_flag desc, sequence asc ;

-- Retrieves order parameters from a flat XML message
-- Poplulates the Order header and line item structures
-- for submitting the order.
-- Note: Works only to extract values from flat XML structure
--
PROCEDURE MSG_TO_ORDER
 (P_MSG_TEXT IN VARCHAR2
 ,P_WI_NAME IN VARCHAR2
 ,X_LINE_PARAM_LIST OUT NOCOPY XDP_TYPES.LINE_PARAM_LIST
 ,X_ORDER_LINE_LIST  OUT NOCOPY XDP_TYPES.ORDER_LINE_LIST
 ,X_ERROR_CODE OUT NOCOPY NUMBER
 ,X_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 );

-- Returns the Geo area name for the given porting ID.
-- Returned from xnp_geo_areas_b
--
FUNCTION GET_GEO_INFO ( P_PORTING_ID IN VARCHAR2 )
  RETURN VARCHAR2 ;

-- Internal procedure for creating an ACK message.
-- Note: Not an user API
--
PROCEDURE SEND_ACK_MSG (P_MSG_TO_ACK IN NUMBER
 ,P_CODE IN NUMBER
 ,P_DESCRIPTION IN VARCHAR2
 ,X_ERROR_CODE OUT NOCOPY NUMBER
 ,X_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 ) ;

-- Get the adapter of the donor for current transaction.
--
--
PROCEDURE GET_DONOR_FE
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_FE_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  );

-- Get the adapter of the initial donor for current transaction.
--
PROCEDURE GET_ORIG_DONOR_FE
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_FE_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  );

-- Get the adapter of the NRC for current transaction.
--
PROCEDURE GET_NRC_FE
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_FE_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  );

-- Get the adapter of the Recipient SP for current transaction.
--
PROCEDURE GET_RECIPIENT_FE
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_FE_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  );

-- Get the adapter of the Sedner for current transaction.
--
PROCEDURE GET_SENDER_FE
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_FE_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  );


-- Logs an error message into XNP_DEBUG
--
PROCEDURE LOG_MSG
( P_SEVERITY_LEVEL IN NUMBER
 ,P_CONTEXT IN VARCHAR2
 ,P_DESCRIPTION IN VARCHAR2
 );

--  Converts dates to the canonical format.
-- The date string format should be 'YYYY/MM/DD HH24:MI:SS'
-- or 'YYYY/MM/DD'
--
FUNCTION CANONICAL_TO_DATE
  (p_DATE_AS_CHAR  VARCHAR2
  )
RETURN DATE;

-- Converts dates to the canonical format chars.
-- Canonical format : 'YYYY/MM/DD' or 'YYYY/MM/DD HH24:MI:SS'
--
FUNCTION DATE_TO_CANONICAL
  (p_DATE  DATE
  ,p_MASK_TYPE VARCHAR2 DEFAULT 'DATETIME'
  )
RETURN VARCHAR2;

-- Get the name (SP code) of the donor for current transaction..
--
PROCEDURE GET_DONOR_NAME
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_RECIPIENT_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  );

-- Get the name (SP code) of the sender for earlier message.
--
PROCEDURE GET_SENDER_NAME
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_RECIPIENT_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  );

-- Get the name (SP code) of the initial donor for current transaction .
--
PROCEDURE GET_ORIG_DONOR_NAME
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_RECIPIENT_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  );

-- Get the name (SP code) of the NRC for the current transaction.
--
PROCEDURE GET_NRC_NAME
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_RECIPIENT_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  );

-- Get the name (SP code) of the Recipient SP for current transaction.
--
PROCEDURE GET_RECIPIENT_NAME
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_RECIPIENT_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  );

-- Gets the FE Name for the given SP ID.
--
PROCEDURE GET_FE_NAME_FOR_SP
   (p_SP_ID NUMBER
   ,x_FE_NAME OUT NOCOPY VARCHAR2
   ,x_ERROR_CODE OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
   );

-- Gets the FE Name for the given SP ID.
--
PROCEDURE GET_FE_NAME
   (p_SP_ID NUMBER
   ,x_FE_NAME OUT NOCOPY VARCHAR2
   ,x_ERROR_CODE OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
   );

-- Gets the FE Name for the given FE ID.
--
PROCEDURE GET_FE_NAME
   (p_FE_ID NUMBER
   ,x_FE_NAME OUT NOCOPY VARCHAR2
   ,x_ERROR_CODE OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
   );

-- Get the Adapter Name for the given SP ID.
--
PROCEDURE GET_ADAPTER_NAME
   (p_SP_ID NUMBER
   ,x_ADAPTER_NAME OUT NOCOPY VARCHAR2
   ,x_ERROR_CODE OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
   );

-- Execute dynamic SQL for message create.
--
PROCEDURE EXEC_DYNAMIC_CREATE_MSG
 (P_DYNAMIC_MSG_TEXT IN VARCHAR2
 ,X_MSG_TEXT OUT NOCOPY VARCHAR2
 ,X_ERROR_CODE OUT NOCOPY NUMBER
 ,X_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 );

-- Execute dynamic SQL for message send and publish.
--
PROCEDURE EXEC_DYNAMIC_SEND_PUBLISH
 (P_DYNAMIC_MSG_TEXT IN VARCHAR2
 ,X_MSG_ID OUT NOCOPY NUMBER
 ,X_ERROR_CODE OUT NOCOPY NUMBER
 ,X_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 );

-- Utility to notify errors in the NP workflow activities.
-- Takes a mesg name and upto 3 tokens and values for each.
-- Internally the STARTING_NUMBER and ENDING_NUMBER
-- tokens are set.
-- Note: the defined message must have STARTING_NUMBER
-- and ENDING_NUMBER defined as tokens.
--
PROCEDURE NOTIFY_ERROR
 (P_PKG_NAME VARCHAR2
 ,P_PROC_NAME VARCHAR2
 ,P_MSG_NAME VARCHAR2
 ,P_WORKITEM_INSTANCE_ID NUMBER
 ,P_TOK1 VARCHAR2 DEFAULT NULL
 ,P_VAL1 VARCHAR2 DEFAULT NULL
 ,P_TOK2 VARCHAR2 DEFAULT NULL
 ,P_VAL2 VARCHAR2 DEFAULT NULL
 ,P_TOK3 VARCHAR2 DEFAULT NULL
 ,P_VAL3 VARCHAR2 DEFAULT NULL
 );
--
-- Gets the WF instance by parsing  the reference ID
--  into its constituent item type, key and activity.
-- Usage Notes: This is done from the process refernce in the format
-- "itemtype:itemkey:activitylabel" or any string in the
-- above format. The string is parsed and the 3 tokens delimited
-- by ':' are returned.
--
PROCEDURE GET_WF_INSTANCE
(
 P_PROCESS_REFERENCE IN VARCHAR2
 ,X_WF_TYPE     OUT NOCOPY VARCHAR2
 ,X_WF_KEY      OUT NOCOPY VARCHAR2
 ,X_WF_ACTIVITY OUT NOCOPY VARCHAR2
 );
--
-- Utility to get the associated Workitem instance ID.
-- for the reference ID in the message.
-- This can be used in the processing logic for a
-- REGISTERED message to the workitem instance ID
-- of the associated workflow. This way, the processing
-- logic gets a handle to all the context information
-- of the workflow.
-- Procedure the process reference against the reference_ID
-- from xnp_callback_events. Then looks up the WF to
-- get the item attribute WORKITEM_INSTANCE_ID
--
PROCEDURE GET_WORKITEM_INSTANCE_ID
(p_reference_id VARCHAR2
,x_workitem_instance_id OUT NOCOPY NUMBER
,x_error_code OUT NOCOPY NUMBER
,x_error_message OUT NOCOPY VARCHAR2
);
--
-- Procedure Get the PORTING_ID from the body text
-- of the message and overwrites the REFERENCE_ID
-- with this value
-- For the subsequent transactions, the PORITNG_ID's
-- value will be the REFERENCE_ID for this transaction
-- Note: Not to be used! The reseting of the
-- reference ID must be done in the adapter only
--
PROCEDURE RESET_REFERENCE_ID
(
p_msg_header IN OUT NOCOPY XNP_MESSAGE.MSG_HEADER_REC_TYPE,
p_msg_text IN VARCHAR2,
x_error_code OUT NOCOPY  NUMBER,
x_error_message  OUT NOCOPY VARCHAR2 );
--
--  Get the reference id value based on the user choice.
--  and is used in the workflow function
-- Gets the value in CALLBACK_REF_ID_NAME activity attribute
-- if the value is NOT CUSTOM
-- then it refers to a WI param name so the value is
-- got from there if the value IS CUSTOM
-- then the actual value is got from the CUSTOM_CALLBACK_REFERENCE_ID
-- activity attrbute and directly returned.
--
--
PROCEDURE CHECK_TO_GET_REF_ID
 (p_itemtype        in varchar2
 ,p_itemkey         in varchar2
 ,p_actid           in number
 ,p_workitem_instance_id in number
 ,x_reference_id  OUT NOCOPY varchar2
 );
--
-- Copies the workitem parameter value from source to destination.
-- Usage Notes: Must be used incase of a modify
-- order to keep multiple workitem context information
-- in sync.
--
PROCEDURE COPY_WI_PARAM_VALUE
 (p_src_wi_id number
 ,p_dest_wi_id number
 ,p_param_name varchar2
 );
--
-- Copies  all WI parameter values from the source to destination.
-- Usage Notes: Must be used incase of a modify
-- order to keep multiple workitem context information
-- in sync.
--
PROCEDURE COPY_ALL_WI_PARAMS
 (p_src_wi_id number
 ,p_dest_wi_id number
 );
--
-- Utility used by PREPARE_CUSTOM_NOTIFICATION workflow activity.
-- All the tokens in the MLS message are replaced by
-- the values as in the workitem parameters
-- The first line in the MLS message is returned in x_subject
-- while the whole message with the tokens interepreted
-- is returned in the x_body.
-- Note:
--  1. Ensure that each workitem parameter (token) has
--   atleast 1 space after it
--  2. The subject will be the character after the first new line
--
PROCEDURE GET_INTERPRETED_NOTIFICATION
 (p_workitem_instance_id number
 ,p_mls_message_name varchar2
 ,x_subject OUT NOCOPY varchar2
 ,x_body OUT NOCOPY varchar2
 ,x_error_code OUT NOCOPY number
 ,x_error_message OUT NOCOPY varchar2
 );
--
-- Gets the Adapter for the given FE.
--
FUNCTION GET_ADAPTER_USING_FE
(
	p_fe_name IN VARCHAR2
)
RETURN VARCHAR2 ;

PRAGMA RESTRICT_REFERENCES(get_adapter_using_fe, WNDS);
--
--
-- Checks if the number range exists.
--
PROCEDURE CHECK_IF_NUM_RANGE_EXISTS
  (p_STARTING_NUMBER IN VARCHAR2
  ,p_ENDING_NUMBER IN VARCHAR2
  ,p_NUMBER_RANGE_ID IN NUMBER
  );

END XNP_UTILS;

 

/
