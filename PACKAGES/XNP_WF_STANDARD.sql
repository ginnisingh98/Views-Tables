--------------------------------------------------------
--  DDL for Package XNP_WF_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_WF_STANDARD" AUTHID CURRENT_USER AS
/* $Header: XNPWFACS.pls 120.0 2005/05/30 11:48:52 appldev noship $ */



-- Global variables to maintain the SFM context information
--
g_ORDER_ID             NUMBER := NULL;
g_WORKITEM_INSTANCE_ID NUMBER := NULL;
g_FA_INSTANCE_ID       NUMBER := NULL;


-- Sets the SFM workitem and order context information
-- into the package global variables
-- g_ORDER_ID and g_WORKITEM_INSTANCE_ID. This ensures
-- proper order to workitem mapping.
--
-- Internal Name: None - Not a workflow activity
--
-- Display Name: None - Not a workflow activity
--
-- Called By:
-- Workflow directly if included as the selector
-- function for the item type
--
-- Called when:
-- The itemtype is initiated and before executing
-- each workflow activity
--
-- Caution: Each item type containing customized workflow
-- processes must have this function as the selector function.
--
PROCEDURE SET_SDP_CONTEXT
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,COMMAND IN VARCHAR2
 ,RESULT OUT NOCOPY  VARCHAR2
 );

-- Comments:
-- Procedure to complete workitem and update status
-- Item Type: XDPWFSTD
-- Internal Name: COMPLETE_WI_UPDATE_STATUS
-- Display Name : Complete work item and update status
-- Relevant Core Procedure Invoked: RESUME_SDP
-- Activity Attributes: None
-- Mandatory WI Params: None
-- Optional WI Params: None

-- Creates a record of numbers being provisioned
-- to enable porting. Called during the Provisioning
-- Phase of the business process. If an entry existed then
-- only the Network info and porting ID is updated for that entry
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: CREATE_SMS_PORTING_RECORD
--
-- Display Name: Create or Moidify SMS Porting Records
--
-- Relevant Core Procedures Invoked: SMS_CREATE_PORTED_NUMBER
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: PORTING_ID, STARTING_NUMBER,
-- ENDING_NUMBER, PORTING_TIME, ROUTING_NUMBER
--
-- PORTING_TIME - is the time when the number is provisioned
--
--  Optional WI Params: CNAM_ADDRESS, CNAM_SUBSYSTEM,
--  ISVM_ADDRESS, ISVM_SUBSYSTEM, LIDB_ADDRESS, LIDB_SUBSYSTEM,
--  CLASS_ADDRESS, CLASS_SUBSYSTEM, WSMSC_ADDRESS, WSMSC_SUBSYSTEM,
--  RN_ADDRESS, RN_SUBSYSTEM, SUBSCRIPTION_TYPE
--
PROCEDURE SMS_CREATE_PORTED_NUMBER
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 ) ;



-- Called during the deprovisioning of the number range.
-- This procedure deletes the network provisioning information
-- from the NP tables.
--
-- Internal Name: Not used currently
--
-- Display Name: Not used currently
--
-- Relevant Core Procedures Invoked: SMS_DELETE_PORTED_NUMBER
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: STARTING_NUMBER, ENDING_NUMBER
--
-- Optional WI Params: None
--
PROCEDURE SMS_DELETE_PORTED_NUMBER
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Updates the Cutoff Due date in the NP Soa tables
-- for each number in the range. The entries to update are
-- identified based on either the porting ID or current status
-- of the number range.
--
-- Internal Name: Not used currently
--
-- Display Name: Not used currently
--
-- Relevant Core Procedures Invoked: SOA_UPDATE_CUTOFF_DATE
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: CUR_STATUS_TYPE_CODE
--
-- Mandatory WI Params: STARTING_NUMBER, ENDING_NUMBER,
--  OLD_SP_CUTOFF_DUE_DATE, SP_NAME
--
-- Optional WI Params: PORTING_ID
--
-- Note: Its is recommended that SOA_UPDATE_DATE be used
--
PROCEDURE SOA_UPDATE_CUTOFF_DATE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Creates a porting order based on the SP role
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: CREATE_PORTING_ORDER
--
-- Display Name: Create Porting Order
--
-- Relevant Core Procedures Invoked:
-- SOA_CREATE_DON_PORT_ORDER or SOA_CREATE_NRC_PORT_ORDER
-- or SOA_CREATE_REC_PORT_ORDER
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: SP_ROLE
-- The SP_ROLE should say if its a DONOR,ORIGNAL_DONOR,
-- RECIPIENT,NRC or NRC_WITHOUT_VALIDATION
--
-- Mandatory WI Params:  STARTING_NUMBER, ENDING_NUMBER,
-- DONOR_SP_ID,RECIPIENT_SP_ID,NEW_SP_DUE_DATE, PORTING_ID
--
-- Optional WI Params: OLD_SP_CUTOFF_DUE_DATE,CUSTOMER_ID,
-- CUSTOMER_NAME, CUSTOMER_TYPE, ADDRESS_LINE1, ADDRESS_LINE2, CITY,PHONE,FAX,EMAIL,
-- ZIP_CODE, COUNTRY, RETAIN_TN_FLAG,CUSTOMER_CONTACT_REQ_FLAG,
-- RETAIN_DIR_INFO_FLAG,CONTACT_NAME, CNAM_ADDRESS,
-- CNAM_SUBSYSTEM, ISVM_ADDRESS, ISVM_SUBSYSTEM, LIDB_ADDRESS,
-- LIDB_SUBSYSTEM, CLASS_ADDRESS, CLASS_SUBSYSTEM, WSMSC_ADDRESS,
-- WSMSC_SUBSYSTEM, RN_ADDRESS, RN_SUBSYSTEM, PAGER, PAGER_PIN,
-- INTERNET_ADDRESS, PREORDER_AUTHORIZATION_CODE, ACTIVATION_DUE_DATE,
-- SUBSCRIPTION_TYPE,COMMENTS,NOTES, ROUTING_NUMBER, SUBSEQUENT_PORT,ORDER_PRIORITY
--
-- The Status Type code is set to the status configured with
-- initial flag = 'Y'
--
PROCEDURE SOA_CREATE_PORTING_ORDER
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Updates the status type code in the XNP_SV_SOA with the new status type code
-- All records with the porting ID and belonging
-- to the current SP are updated to th new status.
-- If the new status belongs to the ACTIVE phase, and if there
-- exists records for this number range already in ACTIVE phase,
-- then they first are reset to OLD phase. The actual updation of
-- the records with the given porting ID is done next.
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: UPDATE_PORTING_STATUS
--
-- Display Name: Update Porting Status
--
-- Relevant Core Procedures Invoked: SOA_UPDATE_SV_STATUS,
--  SOA_RESET_SV_STATUS
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: NEW_STATUS_TYPE_CODE, STATUS_CHANGE_CAUSE_CODE
--
-- Mandatory WI Params: PORTING_ID, STARTING_NUMBER,
-- ENDING_NUMBER, SP_NAME
--
-- Optional WI Params: None
--
--
PROCEDURE SOA_UPDATE_SV_STATUS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Subscribes for the mentioned business event with the given reference i
-- and halts the workflow till it arrives.
-- The state of the workflow at the end of this activity is
-- NOTIFIED.
--
-- Item Type: SFM Standard (XDPWFSTD)
--
-- Internal Name: SUBSCRIBE_TO_BUSINESS_EVENTS
--
-- Display Name: Subscribe to Business Events
--
-- Item Attributes: WORKITEM_INSTANCE_ID,
-- If CALLBACK_REF_ID_NAME is chosen as CUSTOM then this
-- activity would require an item attribute from which
-- the value for the REFERENCE_ID is determined.
--
-- Activity Attributes: EVENT_TYPE, CALLBACK_REF_ID_NAME,
-- CUSTOM_CALLBACK_REFERENCE_ID
--
-- Mandatory WI Params: The workitem parameter
-- chosen from the CALLBACK_REF_ID_NAME LOV is mandatory.
-- The LOV is seeded with PORTING_ID and STARTING_NUMBER
--
-- Optional WI Params: None
-- The Event Type can be chosen from the LOV associated
--
-- Choice of Reference Id: The reference ID is the value
-- to be chosen so that, when the message/event subscribed
-- for arrives into the SFM system, the workflow waiting
-- for this message is uniquely identified.
-- The reference ID value can be a workitem paramter or a
-- customized value stored in an item attribute.
-- If the Reference Id is a Workitem parameter, then the
-- name of this parameter must be chosen from the LOV
-- provided for CALLBACK_REF_ID_NAME. Else, if the ref ID
-- is a customized Item attribute then, choose CUSTOM as
-- the value for CALLBACK_REF_ID_NAME and then choose
-- then associate the item attribute with the
-- CUSTOM_CALLBACK_REFERENCE_ID. Alternatively, even a constant
-- value can be typed into the CUSTOM_CALLBACK_REFERENCE_ID
-- when one wishes to customize the value.
--
--
-- Relevant Procedures Invoked:
--  1. XNP_STANDARD.SUBSCRIBE_FOR_EVENT
--  2. XNP_UTILS.CHECK_TO_GET_REF_ID
--
--
--
PROCEDURE SUBSCRIBE_FOR_EVENT
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Subscribes to all the acks for this business event with the given reference ID
-- and halts the workflow till it arrives.
-- The state of the workflow at the end of this activity is
-- NOTIFIED.
--
-- Item Type: SFM Standard (XDPWFSTD)
--
-- Internal Name: SUBSCRIBE_TO_ACKS
--
-- Display Name: Subscribe to Acknowledgements
--
-- Item Attributes: WORKITEM_INSTANCE_ID,
-- If CALLBACK_REF_ID_NAME is chosen as CUSTOM then this
-- activity would require an item attribute from which
-- the value for the REFERENCE_ID is determined.
--
-- Activity Attributes: EVENT_TYPE, CALLBACK_REF_ID_NAME,
-- CUSTOM_CALLBACK_REFERENCE_ID
--
-- Mandatory  WI Params: The workitem parameter
-- chosen from the CALLBACK_REF_ID_NAME LOV is mandatory.
-- The LOV is seeded with PORTING_ID and STARTING_NUMBER
-- The Event type chosen serves to group all the responses
-- that can be expected for the chosen event type. One or
-- more events can be grouped under a user defined event type
-- using the Event Subscribers tab in iMessageStudio
--
-- The Event Type can be chosen from the LOV associated
--
-- Choice of Reference ID: The reference ID is the value
-- to be chosen so that, when the message/event subscribed
-- for arrives into the SFM system, the workflow waiting
-- for this message is uniquely IDentified.
-- The reference ID value can be a workitem paramter or a
-- customized value stored in an item attribute.
-- If the Reference ID is a Workitem parameter, then the
-- name of this parameter must be chosen from the LOV
-- provided for CALLBACK_REF_ID_NAME. Else, if the ref ID
-- is a customized Item attribute then, choose CUSTOM as
-- the value for CALLBACK_REF_ID_NAME and then choose
-- then associate the item attribute with the
-- CUSTOM_CALLBACK_REFERENCE_ID. Alternatively, even a constant
-- value can be typed into the CUSTOM_CALLBACK_REFERENCE_ID
-- when one wishes to customize the value.
--
-- Relevant Procedures Invoked:
--  1. XNP_STANDARD.SUBSCRIBE_FOR_ACKS
--  2. XNP_UTILS.CHECK_TO_GET_REF_ID
--  3. XNP_EVENT.SUBSCRIBE_FOR_ACKS
--
--
--
PROCEDURE SUBSCRIBE_FOR_ACKS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Prepares a default notification document.
-- The procedures to genereate the pl/sql documents are
-- part of NP seed data.
-- The roles which could get the notification NP_CUST_CARE_ADMIN,
-- NP_SYSADMIN are also seeded. Their values are stored in
-- the item attributes CUST_CARE_ADMIN and SYS_ADMIN respectively
--
-- The user needs to choose the notification into DOC_PROC_NAME.
-- If the user chooses one of the seeded (in NP Activities) notifns
-- then, this activity must be preceed the notification activity.
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: PREPARE_NOTIF_MESSAGE
--
-- Display Name: Prepare Notification Message
--
-- Prepares a default notification document.
-- The procedures to genereate the pl/sql documents are
-- part of NP seed data.
-- The roles which could get the notification NP_CUST_CARE_ADMIN,
-- NP_SYSADMIN are also seeded. Their values are stored in
-- the item attributes CUST_CARE_ADMIN and SYS_ADMIN respectively
--
-- The user needs to choose the notification into DOC_PROC_NAME.
-- If the user chooses one of the seeded (in NP Activities) notifns
-- then, this activity must be preceed the notification activity.
--
-- Relevant Procedures Invoked: Procedures in XNP_DOCUMENTS
--
-- Item Attributes: WORKITEM_INSTANCE_ID, MSG_ID,
-- CUST_CARE_ADMIN, SYS_ADMIN, DOC_REFERENCE
--
-- Activity Attributes: DOC_PROC_NAME
-- DOC_PROC_NAME gives the name of the document to prepare
--
-- Mandatory WI Params: PORTING_ID, STARTING_NUMBER,
--  ENDING_NUMBER, PORTING_TIME, NEW_SP_DUE_DATE
--
-- Optional WI Params: None
--
PROCEDURE PREPARE_NOTIFICATION
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Publishes for the mentioned business event with the given reference ID.
--
-- Item Type: SFM Standard (XDPWFSTD)
--
-- Internal Name: PUBLISH
--
-- Display Name: Publish Message
--
-- Item Attributes: WORKITEM_INSTANCE_ID,
-- If CALLBACK_REF_ID_NAME is chosen as CUSTOM then this
-- activity would require an item attribute from which
-- the value for the REFERENCE_ID is determined.
--
-- Activity Attributes: EVENT_TYPE, CALLBACK_REF_ID_NAME,
-- CUSTOM_CALLBACK_REFERENCE_ID, PARAM_LIST
--
-- Mandatory WI Params: The workitem parameter
-- chosen from the CALLBACK_REF_ID_NAME LOV is mandatory.
-- The LOV is seeded with PORTING_ID and STARTING_NUMBER.
-- The workitem parameters referred to in the PARAM_LIST are
-- also mandatory.
--
-- Optional WI Params: None
-- The Event Type can be chosen from the LOV associated
--
-- Choice of Reference Id: The reference ID is the value
-- to be chosen so that, when the message/event subscribed
-- for arrives into the SFM system, the workflow waiting
-- for this message is uniquely identified.
-- The reference ID value can be a workitem paramter or a
-- customized value stored in an item attribute.
-- If the Reference ID is a Workitem parameter, then the
-- name of this parameter must be chosen from the LOV
-- provided for CALLBACK_REF_ID_NAME. Else, if the ref ID
-- is a customized Item attribute then, choose CUSTOM as
-- the value for CALLBACK_REF_ID_NAME and then choose
-- then associate the item attribute with the
-- CUSTOM_CALLBACK_REFERENCE_ID. Alternatively, even a constant
-- value can be typed into the CUSTOM_CALLBACK_REFERENCE_ID
-- when one wishes to customize the value.
--
-- PARAM_LIST gives the list of parameters for the event
-- in the name value format. For eg. if the event is MY_EVT
-- and the 'IN' parameters for MY_EVT.PUBLISH is
-- XNP$SNO, XNP$DON_NAME then the user defined
-- param list should look like
-- 'SNO=$STARTING_NUMBER,DON_NAME=$DONOR_SP_ID'.
-- The string following the '=$' should mention the workitem parameter
-- from which the workflow must get the value from at runtime.
-- During runtime the invokation would look like
-- MY_EVT.PUBLISH
-- XNP$SNO      => <value in STARTING_NUMBER workitem parameter>
-- XNP$DON_NAME => <value in DONOR_SP_ID workitem parameter>
-- ...
--
--
-- Relevant Procedures Invoked:
--  1. XNP_STANDARD.PUBLISH_EVENT
--  2. XNP_UTILS.CHECK_TO_GET_REF_ID
--  3. <EVENT_TYPE chosen>.PUBLISH
--
--
--
PROCEDURE PUBLISH_EVENT
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Executes the fulfillment action to provision or deprovision or modify a network element
-- At the end it registers for an FA_DONE message with the FA_INSTANCE_ID
-- as the reference id.
-- The FA_DONE message is a message sent by the SFM system
-- once the provisioning operation is compeleted. The
-- success, aborted and error scenarios must be handled by
-- this user defined workflow.
--
-- Item Type: SFM Standard (XDPWFSTD)
--
-- Internal Name: EXECUTE_FA
--
-- Display Name: Execute Fulfillment Action
--
-- Executes the fulfillment action to provision or
-- deprovision or modify a network element. At the end
-- it registers for an FA_DONE message with the FA_INSTANCE_ID
-- as the reference ID.
-- The FA_DONE message is a message sent by the SFM system
-- once the provisioning operation is compeleted. The
-- success, aborted and error scenarios must be handled by
-- this user defined workflow.
--
-- Relevant Procedures Invoked: xdp_eng_util.execute_fa
--
-- Item Attributes: WORKITEM_INSTANCE_ID, ORDER_ID
--
-- Activity Attributes: FA_NAME, FE_NAME
--
PROCEDURE EXECUTE_FA
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


PROCEDURE EXECUTE_FA_N_SYNC_WI_PAR
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );

Procedure DownloadWIParams(itemtype in varchar2, itemkey  in varchar2);

Procedure uploadFAParams( itemtype IN VARCHAR2,
                          itemkey IN VARCHAR2,
                          actid IN NUMBER,
                          p_FAInstanceID IN NUMBER );


-- Updates the Billing and Charging information
-- for the given Porting Id
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: UPDATE_CHARGING_INFO
--
-- Display Name: Update Charging Information
--
-- Relevant Core Procedures Invoked: SOA_UPDATE_CHARGING_INFO
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: PORTING_ID, SP_NAME
--
-- Optional WI Params: INVOICE_DUE_DATE, CHARGING_INFO
-- BILLING_ID, USER_LOCTN_VALUE, USER_LOCTN_TYPE,
-- PRICE_CODE, PRICE_PER_MINUTE, PRICE_PER_CALL
--
PROCEDURE SOA_UPDATE_CHARGING_INFO
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Called during the deprovisioning of the number range.
-- Purpose: Checks if order requires directory services that need to be notified
--
-- Internal Name: Not used currently
--
-- Display Name: Not used currently
--
-- Relevant Core Procedures Invoked: SOA_CHECK_NOTIFY_DIR_SVS
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: PORTING_ID, SP_NAME
--
-- Optional WI Params: None
--
--
PROCEDURE SOA_CHECK_NOTIFY_DIR_SVS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Gets the FEs to be provisioned for this feature type and number range
-- For each FE the SFM's provisioning
-- procedure (execute fa) is invoked. At the end of this activty
-- the control passes on to the Provisioning subsystem which
-- executes the fulfillment procedure. An FA_DONE message is
-- subscribed for each FA being executed which gives the execution
-- result of the fulfillment procedure. The callback procedure
-- associated with the FA_DONE handles the responses received.
--
-- In must ensured that the immediate next activity following
-- the activity must be SFM Standard's Wait For Flow. This
-- is to ensure proper handoff from the provisioning system
-- back to the NP System.
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: PROVISION_FES
--
-- Display Name: Provision or Modify FEs
--
-- Relevant Procedures Invoked:
--    XNP_CORE.SMS_INSERT_FE_MAP,
--    XDP_ENG_UTIL.ADD_FA_TOWI - returns fa instance ID
--    XDP_ENG_UTIL.EXECUTE_FA - with INTERNAL option
--    XNP_EVENT.SUBSCRIBE with
--          - callback procedure XNP_FA_CP.PROCESS_FA_DONE
--          - reference ID as the returned fa instance ID
--
-- Item Attributes: ORDER_ID, WORKITEM_INSTANCE_ID
--
-- Activity Attributes: FEATURE_TYPE
--
-- Mandatory WI Params: STARTING_NUMBER, ENDING_NUMBER
--
--
PROCEDURE SMS_PROVISION_NES
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Purpose: Gets the fes to be Deprovisioned for this feature type and number range.
-- For each FE the SFM's provisioning
-- procedure (execute fa) is invoked. At the end of this activty
-- the control passes on to the Provisioning subsystem which
-- executes the fulfillment procedure. An FA_DONE message is
-- subscribed for each FA being executed which gives the execution
-- result of the fulfillment procedure. The callback procedure
-- associated with the FA_DONE handles the responses received.
--
-- In must ensured that the immediate next activity following
-- the activity must be SFM Standard's 'Wait For Flow'. This
-- is to ensure proper handoff from the provisioning system
-- back to the NP System.
--
-- Note: Only FEs which were earlier provisioned by this SP
-- can be modified. Otherwise the FEs will be ignored.
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: DEPROVISION_FES
--
-- Display Name: Deprovision FEs
--
-- Relevant Procedures Invoked:
--    XDP_ENG_UTIL.ADD_FA_TOWI - returns fa instance id
--    XDP_ENG_UTIL.EXECUTE_FA - with INTERNAL option
--    XNP_EVENT.SUBSCRIBE with
--          - callback procedure XNP_FA_CP.PROCESS_FA_DONE
--          - reference id as the returned fa instance ID
--
-- Item Attributes: ORDER_ID, WORKITEM_INSTANCE_ID
--
-- Activity Attributes: FEATURE_TYPE
--
-- Mandatory WI Params: STARTING_NUMBER, ENDING_NUMBER
--
PROCEDURE SMS_DEPROVISION_NES
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Completes the activity based on the value in the ORDER_RESULT workitem parameter.
--
-- Item Type: SFM Standard (XDPWFSTD)
--
-- Internal Name: CHECK_RESULT
--
-- Display Name: Check Order Workitem Result
--
-- Relevant Procedures Invoked:
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: ORDER_RESULT
--
PROCEDURE SOA_CHECK_ORDER_STATUS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


--  Checks if the records are in the given status
--  and if 'Y' then completes the 'YES' path
--  else completes the 'NO' path
--
-- Internal Name: Not used currently
--
-- Display Name: Not used currently
--
-- Relevant Procedures Invoked: XNP_CORE.CHECK_SOA_STATUS_EXISTS
--
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: SP_NAME, STARTING_NUMBER
-- ENDING_NUMBER
--
PROCEDURE CHECK_SOA_STATUS_EXISTS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Sets the ORDER_RESULT to the value passed in the activity attribute ORDER_STATUS
-- The order result may be set to indicate the current
-- status of the workitem transaction.
--
-- Item Type: SFM Standard (XDPWFSTD)
--
-- Internal Name: UPDATE_ORDER_STATUS
--
-- Display Name: Set Order Workitem Result
--
-- For e.g. it could indicate the notification response
-- or a message response if its positive(Y) or negative(N)
--
-- Relevant Procedures Invoked:
--          XNP_STANDARD.SOA_CHECK_ORDER_STATUS
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: ORDER_RESULT
--
PROCEDURE SET_ORDER_RESULT
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Determines if the current SP is a DONOR,or RECIPIENT or Original Donor.
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: DETERMINE_SP_ROLE
--
-- Display Name: Determine Current Service Provider Role
--
-- Relevant Procedures Invoked:
-- XNP_CORE.SOA_CHECK_IF_INITIAL_DONOR
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory  WI Params: STARTING_NUMBER, ENDING_NUMBER
-- DONOR_SP_ID, RECIPIENT_SP_ID, SP_NAME
--
PROCEDURE DETERMINE_SP_ROLE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Checks if it is a subsequent porting request and returns Y/N accordingly
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: IS_SUBSEQUENT_PORTING_REQUEST
--
-- Display Name: Determine if Subsequent Porting Request
--
-- Relevant Procedures Invoked: XNP_STANDARD.SOA_IS_SUBSEQUENT_PORT
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: SUBSEQUENT_PORT
--
PROCEDURE SOA_IS_SUBSEQUENT_PORT
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );

-- Sends for the mentioned business event
-- with the given reference id.
--
-- Item Type: SFM Standard (XDPWFSTD)
--
-- Internal Name: EXECUTE_FA_MSG
--
-- Display Name: Send Message
--
-- Item Attributes: WORKITEM_INSTANCE_ID, ORDER_ID,
-- If CALLBACK_REF_ID_NAME is chosen as CUSTOM then this
-- activity would require an item attribute from which
-- the value for the REFERENCE_ID is determined.
--
-- Activity Attributes: EVENT_TYPE, CALLBACK_REF_ID_NAME,
-- CUSTOM_CALLBACK_REFERENCE_ID, PARAM_LIST, CONSUMER, RECEIVER
--
-- Mandatory  WI Params: The workitem parameter
-- chosen from the CALLBACK_REF_ID_NAME LOV is mandatory.
-- The LOV is seeded with PORTING_ID and STARTING_NUMBER.
-- The workitem parameters referred to in the PARAM_LIST are
-- also mandatory.
-- The Event Type can be chosen from the LOV associated
--
-- Choice of Reference ID: The reference ID is the value
-- to be chosen so that, when the message/event subscribed
-- for arrives into the SFM system, the workflow waiting
-- for this message is uniquely identified.
-- The reference ID value can be a workitem paramter or a
-- customized value stored in an item attribute.
-- If the Reference ID is a Workitem parameter, then the
-- name of this parameter must be chosen from the LOV
-- provided for CALLBACK_REF_ID_NAME. Else, if the ref ID
-- is a customized Item attribute then, choose CUSTOM as
-- the value for CALLBACK_REF_ID_NAME and then choose
-- then associate the item attribute with the
-- CUSTOM_CALLBACK_REFERENCE_ID. Alternatively, even a constant
-- value can be typed into the CUSTOM_CALLBACK_REFERENCE_ID
-- when one wishes to customize the value.
--
-- PARAM_LIST gives the list of parameters for the event
-- in the name value format. For eg. if the event is MY_EVT
-- and the 'IN' parameters for MY_EVT.PUBLISH is
-- XNP$SNO, XNP$DON_NAME then the user defined
-- param list should look like
-- 'SNO=$STARTING_NUMBER,DON_NAME=$DONOR_SP_ID'.
-- The string following the '=$' should mention the workitem parameter
-- from which the workflow must get the value from at runtime.
-- During runtime the invokation would look like
-- MY_EVT.SEND
-- XNP$SNO      => <value in STARTING_NUMBER workitem parameter>
-- XNP$DON_NAME => <value in DONOR_SP_ID workitem parameter>
-- ...
--
-- CONSUMER gives the procedure which when executed returns
-- the adapter name. The consumer can be thought of as the
-- immediate recipient of the message incase the message needs
-- to make a FEw routing hops before reaching the intended
-- recipient
-- The API for this packaged procudure should look as follows
-- <package>.<procedure>
--  (p_order_id          in  number
--  ,p_wi_instance_id    in  number
--  ,p_fa_instance_id    in  number
--  ,x_fe_name           out NOCOPY varchar2
--  ,x_return_code       OUT NOCOPY  number
--  ,x_error_description OUT NOCOPY  varchar2
--  );
--
-- The procedure can be user defined but the <package>.<procedure> must be loaded as lookup values
-- against the fnd lookup code 'GET_CONSUMER_FE'.
-- NP is seeded with procedures to get the donor, recipient
-- NRC, original donor service provider's adapter.
--
-- RECEIVER gives the procedure which when executed returns
-- the reciever name. The reciever can be thought of as the
-- final recipient of the message
-- The API for this packaged procudure should look as follows
-- <package>.<procedure>
--  (p_order_id          in  number
--  ,p_wi_instance_id    in  number
--  ,p_fa_instance_id    in  number
--  ,x_recipient_name    OUT NOCOPY  varchar2
--  ,x_return_code       OUT NOCOPY  number
--  ,x_error_description OUT NOCOPY  varchar2
--  );
--
-- The procedure can be user defined but the <package>.<procedure>must be loaded as lookup values
-- against the fnd lookup code 'GET_RECEIVER_NAME'.
-- NP is seeded with procedures to get the donor, recipient
-- NRC, original donor service provider's name.
--
-- Relevant Procedures Invoked:
--  1. XNP_STANDARD.SEND_MESSAGE - to dynamically invoke the send
--  2. XNP_UTILS.CHECK_TO_GET_REF_ID
--  3. <EVENT_TYPE>.SEND
--
--
PROCEDURE SEND_MESSAGE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Deletes the FE Maps for the number range and feature type
--
-- Internal Name: Not used currently
--
-- Display Name: Not used currently
--
-- Relevant Procedures Invoked:
--  XNP_CORE.SMS_DELETE_FE_MAP
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: STARTING_NUMBER, ENDING_NUMBER
--
PROCEDURE SMS_DELETE_FE_MAP
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );

--  Checks if there exists a SV for the given TN range
--  in that phase  and in for the given SP Role i.e. as donor
--  or recipient
--
-- Internal Name: Not being used
--
-- Display Name: Not being used
--
-- Note: Phase is not exposed to user. So this
-- procedure shouldn't be used
--
-- Relevant Cores Invoked: CHECK_DONOR_PHASE,
-- CHECK_RECIPIENT_PHASE
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: SP_ROLE, PHASE
--
-- Mandatory WI Params: STARTING_NUMBER,
-- ENDING_NUMBER, SP_NAME
--
-- Optional Workitem parameters: None
--
PROCEDURE CHECK_PHASE_FOR_ROLE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Updates the FE map status for the given FEs and number range.
--
-- Internal Name: Not being used
--
-- Display Name: Not being used
--
-- Relevant Cores Invoked: SMS_UPDATE_FE_MAP_STATUS
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params           s: STARTING_NUMBER,
-- ENDING_NUMBER
--
-- Optional Workitem parameters: None
--
PROCEDURE SMS_UPDATE_FE_MAP_STATUS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Relevant Procedures Invoked: Update the status of the message to be rejected
--
-- Item Type: SFM Standard (XDPWFSTD)
--
-- Internal Name: REJECT_MESSAGE
--
-- Display Name: Reject Message
--
-- Item Attributes: MSG_ID, COMMENT, REJECTED
--
-- Activity Attributes: None
--
-- Mandatory WI Params: None
--
-- Optional WI Params: None
--
PROCEDURE REJECT_MESSAGE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
) ;


-- Attempts to Retry the message
--
-- Item Type: SFM Standard (XDPWFSTD)
--
-- Internal Name: RETRY_MESSAGE
--
-- Display Name: Retry Message
--
-- Relevant Procedures Invoked: XNP_MESSAGE.FIX
--
-- Item Attributes: MSG_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: None
--
-- Optional WI Params: None
--
PROCEDURE RETRY_MESSAGE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
) ;

-- SFM's Version of WAITFORFLOW
-- Make sure this procedure is invoked immediately after a
-- PROVISION_NES, DEPROVISION_NES and MODIFY_NES
--
-- Item Type: SFM Standard (XDPWFSTD)
--
-- Internal Name: WAITFORFLOW
--
-- Display Name: Wait For Flow
--
--
PROCEDURE WAITFORFLOW
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
) ;


-- SFM's Version of CONTINUEFLOW
--
-- Item Type: SFM Standard (XDPWFSTD)
--
-- Internal Name: CONTINUEFLOW
--
-- Display Name: Continue Flow
--
--
PROCEDURE CONTINUEFLOW
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
) ;


-- Sets the Locked flag to the given value for the enties in xnp_sv_soa
-- for the given  PORTING_ID workitem paramter.
--
-- Internal Name: Not being used - Use SET_FLAG_VALUE
--
-- Display Name: Not being used
--
-- Relevant Cores Invoked: SOA_SET_LOCKED_FLAG
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: None
--
-- Optional WI Params: None
--
PROCEDURE SOA_SET_LOCKED_FLAG
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Gets the Locked flag for the given PORTING_ID workitem paramter
-- The activity is completed with the flag value
--
-- Internal Name: Not being used - USE SET_FLAG_VALUE
--
-- Display Name: Not being used - USE SET_FLAG_VALUE
--
-- Relevant Cores Invoked: XNP_CORE.SOA_GET_LOCKED_FLAG
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: FLAG_VALUE
--
-- Mandatory WI Params: None
--
-- Optional WI Params: None
--
PROCEDURE SOA_GET_LOCKED_FLAG
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Checks if the STATUS_TYPE_CODE from xnp_sv_soa for the PORTING ID is same as the given status.
-- (in STATUS_TO_COMPARE_WITH)
-- @return 'T' if statuses match, 'F' if they don't
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: CHECK_SV_STATUS
--
-- Display Name: Verify Porting Status
--
-- Relevant Core Invoked: SOA_CHECK_SV_STATUS
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: STATUS_TO_COMPARE_WITH
--
-- Mandatory WI Params: PORTING_ID, SP_NAME
--
-- Optional WI Params: None
--
PROCEDURE SOA_CHECK_SV_STATUS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Gets the Status for the porting record for the PORTING_ID
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: GET_PORTING_STATUS
--
-- Display Name: Get Porting Status
--
-- Relevant Cores Invoked: SOA_GET_SV_STATUS
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: PORTING_ID, SP_NAME
--
-- Activity Attributes: None
--
-- Optional WI Params: None
--
PROCEDURE SOA_GET_SV_STATUS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Gets the FEs to be Modified for the feature type and number range
-- For each FE the SFM's provisioning
-- procedure (execute fa) is invoked. At the end of this activty
-- the control passes on to the Provisioning subsystem which
-- executes the fulfillment procedure. An FA_DONE message is
-- subscribed for each FA being executed which gives the execution
-- result of the fulfillment procedure. The callback procedure
-- associated with the FA_DONE handles the responses received.
--
-- In must ensured that the immediate next activity following
-- the activity must be SFM Standard's Wait For Flow. This
-- is to ensure proper handoff from the provisioning system
-- back to the NP System.
--
-- Note: Only FEs which were earlier provisioned by this SP
-- can be modified. Otherwise the FEs will be ignored.
--
-- Item Type: SFM Standard (XDPWFSTD)
--
-- Internal Name: MODIFY_FES
--
-- Display Name: Modify FEs
--
-- Relevant Procedures Invoked:
--    XDP_ENG_UTIL.ADD_FA_TOWI - returns fa instance id
--    XDP_ENG_UTIL.EXECUTE_FA - with INTERNAL option
--    XNP_EVENT.SUBSCRIBE with
--          - callback procedure XNP_FA_CP.PROCESS_FA_DONE
--          - reference ID as the returned fa instance ID
--
-- Item Attributes: ORDER_ID, WORKITEM_INSTANCE_ID
--
-- Activity Attributes: FEATURE_TYPE
--
-- Mandatory WI Params: STARTING_NUMBER, ENDING_NUMBER
--
-- Optional WI Params: None
--
PROCEDURE SMS_MODIFY_NES
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );




-- Updates the New SP Due date for the porting record for the current SP
--
-- Internal Name: Not used - Use UPDATE_DATE
--
-- Display Name: Not used - Use UPDATE_DATE
--
-- Relevant Procedures Invoked:
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: SP_NAME, NEW_SP_DUE_DATE
-- PORTING_ID
--
-- Optional WI Params: None
--
PROCEDURE SOA_UPDATE_NEW_SP_DUE_DATE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Updates the New SP Due date for the porting record for the current SP
--
-- Internal Name: Not used - Use UPDATE_DATE
--
-- Display Name: Not used - Use UPDATE_DATE
--
-- Relevant Procedures Invoked:
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: SP_NAME, OLD_SP_DUE_DATE
-- PORTING_ID
--
-- Optional WI Params: None
--
PROCEDURE SOA_UPDATE_OLD_SP_DUE_DATE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Procedure to check if there  exists a Porting record in the given status
-- for this TN range and beloging to the
-- with the given DONOR's SP ID
-- Completes with 'Y' or 'N'
--
-- Relevant Cores Invoked: SOA_CHECK_DON_STATUS_EXISTS
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: STARTING_NUMBER,ENDING_NUMBER,
-- DONOR_SP_ID
--
-- Optional WI Params: None
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: CHECK_DON_STATUS_EXISTS
--
-- Display Name: Does Porting Record Exist for the Donor
--
PROCEDURE SOA_CHECK_DON_STATUS_EXISTS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Procedure to check if there exists a Porting record in the given status
-- for this TN range and beloging to the
-- with the given Recipient's SP ID
-- Completes with 'Y' or 'N'
--
-- Relevant Cores Invoked: SOA_CHECK_REC_STATUS_EXISTS
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: CHECK_REC_STATUS_EXISTS
--
-- Display Name: Does Porting Record Exist for the Recipient
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: STARTING_NUMBER,ENDING_NUMBER,
-- RECIPIENT_SP_ID
--
-- Optional WI Params: None
--
PROCEDURE SOA_CHECK_REC_STATUS_EXISTS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Procedure to update the status of the Porting Order Records to the new status
-- for the given PORTING_ID
-- (a.k.a OBJECT_REFERENCE) and
-- belonging to the (local) SP ID.
--
-- Internal Name: Not being used - Use UPDATE_SV_STATUS
--
-- Display Name: Not being used - Use UPDATE_SV_STATUS
--
-- Relevant Cores Invoked: XNP_CORE.SOA_UPDATE_SV_STATUS
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes:
--
-- Mandatory WI Params: SP_NAME,PORTING_ID
--
-- Optional WI Params: None
--
PROCEDURE SOA_UPD_PORTING_ID_STATUS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );




-- Sets the flag to the given value
-- for the entries in xnp_sv_soa for the given
-- PORTING_ID workitem paramter and FLAG_NAME
-- for the current SP.
-- Values: 'Y' or 'N'
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: SET_FLAG_VALUE
--
-- Display Name: Set Flag Value
--
-- Relevant Procedures Invoked:
-- Calls the core function to set the corresponding
-- flag value
--  SOA_SET_LOCKED_FLAG
--  SOA_UPDATE_NEW_SP_AUTH_FLAG
--  SOA_UPDATE_OLD_SP_AUTH_FLAG
--  SOA_SET_BLOCKED_FLAG
--  SOA_SET_CONCURRENCE_FLAG
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: FLAG_NAME
--
-- Mandatory WI Params: PORTING_ID, SP_NAME
--
-- Optional WI Params: None
--
PROCEDURE SOA_SET_FLAG_VALUE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Gets the Locked flag for the given PORTING_ID workitem paramter.
-- The activity is completed with the flag value
-- Values: 'Y' or 'N'
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: GET_FLAG_VALUE
--
-- Display Name: Get Flag Value
--
-- Relevant Procedures Invoked:
-- Calls the core function to set the corresponding
-- flag value
--  SOA_GET_LOCKED_FLAG
--  SOA_GET_NEW_SP_AUTH_FLAG
--  SOA_GET_OLD_SP_AUTH_FLAG
--  SOA_GET_BLOCKED_FLAG
--  SOA_GET_CONCURRENCE_FLAG
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: FLAG_NAME
--
-- Mandatory WI Params: PORTING_ID, SP_NAME
--
-- Optional WI Params: None
--
PROCEDURE SOA_GET_FLAG_VALUE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Updates the DATE for the given porting record
-- given the PORTING_ID. The date to update i.e.
-- NEW_SP_DUE_DATE, OLD_SP_DUE_DATE,ACTIVATION_DUE_DATE,etc
--
-- Note: The date format must is the workitem parameter
-- must be 'YYYY/MM/DD HH24:MI:SS'
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: UPDATE_DATE_VALUE
--
-- Display Name: Update with new date
--
-- Relevant Cores Invoked:
-- Calls XNP_CORE.<function to update the right date>
-- SOA_UPDATE_NEW_SP_DUE_DATE or
-- SOA_UPDATE_ACTIVATION_DUE_DATE or
-- SOA_UPDATE_NEW_SP_DUE_DATE
-- SOA_UPDATE_DISCONNECT_DUE_DATE
-- SOA_UPDATE_EFFECTIVE_RELEASE_DUE_DATE
-- SOA_UPDATE_NUMBER_RETURNED_DUE_DATE
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: NEW_STATUS_TYPE_CODE,
-- STATUS_CHANGE_CAUSE_CODE
--
-- Mandatory WI Params: PORTING_ID
-- OLD_SP_DUE_DATE, NEW_SP_DUE_DATE, ACTIVATION_DUE_DATE,
-- DISCONNECT_DUE_DATE, EFFECTIVE_RELEASE_DUE_DATE,
-- NUMBER_RETURNED_DUE_DATE
--
-- Optional WI Params: None
--
--
PROCEDURE SOA_UPDATE_DATE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );



-- Checks if the donor SP of the porting transaction has provisioned the Number range
-- or is assigned the number  range
-- If either of them is true then it completes the
-- the activity with Y
--
-- Relevant Cores Invoked: XNP_CORE.CHECK_IF_SP_ASSIGNED
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: CHECK_IF_DONOR_CAN_PORT_OUT
--
-- Display Name: Check if donor is eligible to port out
--
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: STARTING_NUMBER,ENDING_NUMBER,
--  DONOR_SP_ID
--
-- Optional WI Params: None
--
PROCEDURE CHECK_IF_DONOR_CAN_PORT_OUT
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Checks if the DONOR_SP_ID (WI param) is the Initial donor
--
-- Relevant cores Invoked: XNP_CORE.SOA_CHECK_IF_INITIAL_DONOR
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: CHECK_IF_DON_IS_INITIAL_DON
--
-- Display Name: Check if Donor is also the Initial Donor
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: STARTING_NUMBER,
-- ENDING_NUMBER, DONOR_SP_ID
--
-- Optional WI Params: None
--
PROCEDURE CHECK_IF_DON_IS_INITIAL_DON
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Updates the Comments and Notes for the Porting ID and for the current SP
--
-- Relevant Procedures Invoked: SOA_UPDATE_NOTES_INFO
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: SOA_UPDATE_NOTES_INFO
--
-- Display Name: Update Comments and Notes Information
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: COMMENTS, NOTES
--
-- Mandatory WI Params: COMMENTS, NOTES, PORTING_ID
-- PREORDER_AUTHORIZATION_CODE, SP_NAME
--
-- Optional WI Params: None
--
PROCEDURE SOA_UPDATE_NOTES_INFO
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Updates the customer information for the current Porting ID and for the current SP
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: SOA_UPDATE_CUSTOMER_INFO
--
-- Display Name: Update Customer Information
--
-- Relevant Procedures Invoked: SOA_UPDATE_CUSTOMER_INFO
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: PORTING_ID, SP_NAME
--
-- Optional WI Params: CUSTOMER_ID,
-- CUSTOMER_NAME,CUSTOMER_TYPE, ADDRESS_LINE1,ADDRESS_LINE_2, CITY, PHONE, FAX, EMAIL,
-- ZIP_CODE, COUNTRY, CUSTOMER_CONTACT_REQ_FLAG, CONTACT_NAME,
-- PAGER, INTERNET_ADDRESS, SP_NAME
--
PROCEDURE SOA_UPDATE_CUSTOMER_INFO
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Updates the Network information for the current Porting ID
-- and for the current SP in the XNP_SV_SOA
--
-- Relevant Procedures Invoked: SOA_UPDATE_NETWORK_INFO
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: SOA_UPDATE_NETWORK_INFO
--
-- Display Name: Update Network Info in SOA
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: PORTING_ID, SP_NAME
--
-- Optional Workitem parameters: CNAM_ADDRESS, CNAM_SUBSYSTEM
-- ISVM_ADDRESS, ISVM_SUBSYSTEM, LIDB_ADDRESS, CLASS_ADDRESS,
-- CLASS_SUBSYSTEM, WSMSC_ADDRESS, WSMSC_SUBSYSTEM, RN_ADDRESS
-- RN_SUBSYSTEM, ROUTING_NUMBER,
--
PROCEDURE SOA_UPDATE_NETWORK_INFO
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Prepares Customized Notification.
-- The User can define the customized notification to be
-- desplayed at runtime by defining his own message.
-- The Message name should be of the format
--            'X%_NOTFN_%' - max 29 chars
--
-- An e.g. of the user define message would be
--
-- " Porting requested for &STARTING_NUMBER thru &ENDING_NUMBER
-- on &NEW_SP_DUE_DATE "
--
-- The tokens after the "&" should be then name of the workitem
-- parameter.
-- This activity scans the message and replaces the tokens
-- with the values in the workitem item parameters.
--
-- Once these messages are created, run the lookup loader
-- script to load these user defined messages onto
-- the workflow lookup code CUSTOMIZED_NOTN_MESSAGES.
-- This activity would set the frist line of the notification
-- message in the item attribute MSG_SUBJECT and the
-- entire contents in MSG_BODY. The created notification
-- would contain the message with all the referenced
-- workitem parameters with the actual value.
--
-- The user can create a Notification with these item
-- attributes for the subject and body.
--
-- Relevant Procedures Invoked:
-- xnp_utils.get_interpreted_notification
--
-- Item Type: SFM Standard (XDPWFSTD)
--
-- Internal Name: PREPARE_CUSTOM_NOTIFICATION
--
-- Display Name: Prepare Customized Notification
--
-- Item Attributes: ORDER_ID, WORKITEM_INSTANCE_ID
--  MSG_SUBJECT, MSG_BODY
--
-- Activity Attributes: NOTIFN_MSG_NAME
--
-- Optional WI Params: All wi parameters
-- referenced in the user defined notification message
--
-- Mandatory WI Params: None
--
PROCEDURE PREPARE_CUSTOM_NOTIFN
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Updates the status type code in the XNP_SV_SOA with the new status type code
-- All records with the porting ID and belonging
-- to the current SP are updated to th new status.
-- If the new status belongs to the ACTIVE phase, and if there
-- exists records for this number range already in ACTIVE phase,
-- then they first are reset to OLD phase. The actual updation of
-- the records with the given porting id is done next.
--
-- Relevant Core Procedures Invoked: SOA_UPDATE_SV_STATUS,
--  SOA_RESET_SV_STATUS
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: UPDATE_CUR_SV_STATUS
--
-- Display Name: Update Current SV Status
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: NEW_STATUS_TYPE_CODE, STATUS_CHANGE_CAUSE_CODE
--  CUR_STATUS_TYPE_CODE
--
-- Mandatory WI Params: STARTING_NUMBER, ENDING_NUMBER, SP_NAME
--
-- Optional WI Params: None
--
PROCEDURE SOA_UPDATE_CUR_SV_STATUS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );


-- Updates the Provisioning done date for the given number range with the current date
--
-- Relevant Core Procedures Invoked: None
--
-- Item Type: NP Standard (XNPWFSTD)
--
-- Internal Name: UPDATE_PROV_DONE_DATE
--
-- Display Name: Update Provisioning Done Date
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params: STARTING_NUMBER, ENDING_NUMBER
--
-- Optional WI Params: None
--
-- Tables: XNP_SV_SMS
--
--
PROCEDURE SMS_UPDATE_PROV_DONE_DATE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 );

-- Runtime Validation checks for NP Workitem
--
-- Item Type: NP STANDARD (XNPWFSTD)
--
-- Internal Name: VALIDATE_RUNTIME_DATA
--
-- Diaplay Name: Validate Runtime Data
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params:
--
-- Optional WI Params: STARTING_NUMBER,ENDING_NUMBER,ROUTING_NUMBER,
-- DONOR_SP_CODE,RECIPIENT_SP_CODE
--
PROCEDURE RUNTIME_VALIDATION
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY  VARCHAR2
 ) ;

-- Sync item parameter values with their corresponding work items.
--
-- Item Type: SFM STANDARD (XNPWFSTD)
--
-- Internal Name: SYNC_LI_PARAMETERS
--
-- Diaplay Name: Sync Line Item Parameters
--
-- Item Attributes: LINE_ITEM_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params:
--
-- Optional WI Params: None
--
--

Procedure SYNC_LI_PARAMETER_VALUES (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY  varchar2 );
--
-- To retrieve order fulfillment status.
--
-- Item Type: SFM STANDARD (XNPWFSTD)
--
-- Internal Name: GET_ORDER_FULFILLMENT_STATUS
--
-- Diaplay Name: Get Order Fulfillment Status
--
-- Item Attributes: ORDER_ID
--
-- Activity Attributes: None
--
-- Mandatory WI Params:
--
-- Optional WI Params: None
--
Procedure GET_ORD_FULFILLMENT_STATUS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY  varchar2 );

--
-- To set user defined order fulfillment status.
--
-- Item Type: SFM STANDARD (XNPWFSTD)
--
-- Internal Name: SET_ORDER_FULFILLMENT_STATUS
--
-- Diaplay Name: Set Order Fulfillment Status
--
-- Item Attributes: ORDER_ID
--
-- Activity Attributes:
--			FULFILLMENT_STATUS
--			FULFILLMENT_RESULT
--
-- Mandatory WI Params:
--
-- Optional WI Params: None
--
Procedure SET_ORD_FULFILLMENT_STATUS (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY  varchar2 );

--
-- To set user defined WI fulfillment status.
--
-- Item Type: SFM STANDARD (XNPWFSTD)
--
-- Internal Name: SET_ORDER_FULFILLMENT_STATUS
--
-- Diaplay Name: Set Order Fulfillment Status
--
-- Item Attributes: WORKITEM_INSTANCE_ID
--
-- Activity Attributes:
--			FULFILLMENT_STATUS
--			FULFILLMENT_RESULT
--
-- Mandatory WI Params:
--
-- Optional WI Params: None
--

Procedure SET_WI_FULFILLMENT_STATUS (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY  varchar2 ) ;

--
-- To De register all Waiting Timers and Events for the Order
--
-- Item Type: SFM STANDARD (XNPWFSTD)
--
-- Internal Name: DEREGISTER_ALL
--
-- Diaplay Name: De-Register All Order Events and Timers
--
-- Item Attributes: ORDER_ID
--
-- Activity Attributes:
--
-- Mandatory WI Params:
--
-- Optional WI Params: None
--

Procedure DEREGISTER_ALL (itemtype        in varchar2,
                          itemkey         in varchar2,
                          actid           in number,
                          funcmode        in varchar2,
                          resultout       OUT NOCOPY  varchar2 ) ;





END XNP_WF_STANDARD;

 

/
