--------------------------------------------------------
--  DDL for Package XNP_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_STANDARD" AUTHID CURRENT_USER AS
/* $Header: XNPSTACS.pls 120.1 2005/06/24 04:46:11 appldev ship $ */


	-- BUG # 1500177
	-- used by publish in the generated code to pass correct fe_name to push()

   FE_NAME VARCHAR2(40) := NULL;

-- Extracts the order information from SFM
-- WI params
-- Called when: There is a Create Ported Number
-- request from NRC
-- Called by: XNP_STANDARD.SMS_CREATE_PORTED_NUMBER
-- Mandatory WI Params: Gets the PORTING_ID, STARTING_NUMBER, ENDING_NUMBER,
-- PORTING_TIME,ROUTING_NUMBER
-- Optional WI Params: CNAM_ADDRESS, CNAM_SUBSYSTEM,
-- ISVM_ADDRESS, ISVM_SUBSYSTEM, LIDB_ADDRESS, LIDB_SUBSYSTEM,
-- CLASS_ADDRESS, CLASS_SUBSYSTEM, WSMSC_ADDRESS, WSMSC_SUBSYSTEM,
-- RN_ADDRESS, RN_SUBSYSTEM  , SUBSCRIPTION_TYPE
-- Creates an entry in SMS table for each TN in the range

PROCEDURE SMS_CREATE_PORTED_NUMBER
 (
  p_ORDER_ID             IN NUMBER,
  p_LINEITEM_ID          IN NUMBER,
  p_WORKITEM_INSTANCE_ID IN NUMBER,
  p_FA_INSTANCE_ID       IN NUMBER,
  x_ERROR_CODE           OUT NOCOPY NUMBER,
  x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 );

-- Extracts the order information from SFM Workitem params table
-- Gets the STARTING_NUMBER, ENDING_NUMBER
-- and calls XNP_CORE.SMS_DELETE_PORTED_NUMBER
-- Called when: There is a Delete Ported Number
-- request from NRC
-- Called by: XNP_STANDARD.SMS_DELETE_PORTED_NUMBER
--
PROCEDURE SMS_DELETE_PORTED_NUMBER
 (p_WORKITEM_INSTANCE_ID IN NUMBER
 ,x_ERROR_CODE          OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 );

-- Updates SV in SOA table for each TN in the range
-- with the invoice infomation
-- Mandatory WI Params : STARTING_NUMBER ENDING_NUMBER, SP_NAME
-- Optional WI Params : INVOICE_DUE_DATE, CHARGING_INFO, BILLING_ID,
-- USER_LOCTN_VALUE, USER_LOCTN_TYPE
--
-- Called when: Recipient requested port succeeds
-- Called by: XNP_STANDARD.SOA_UPDATE_CHARGING_INFO

PROCEDURE SOA_UPDATE_CHARGING_INFO
 (p_ORDER_ID             IN NUMBER,
  p_LINEITEM_ID          IN NUMBER,
  p_WORKITEM_INSTANCE_ID IN NUMBER,
  p_FA_INSTANCE_ID       IN NUMBER,
  p_CUR_STATUS_TYPE_CODE    VARCHAR2,
  x_ERROR_CODE           OUT NOCOPY NUMBER,
  x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 );

-- Extracts the order information from SFM Workitem params table
-- namely STARTING_NUMBER,
-- ENDING_NUMBER, OLD_SP_CUTOFF_DUE_DATE
--
-- Calls XNP_CORE.SOA_UPDATE_CUTOFF_DATE to update the
-- cutoff date and the new status of each TN in the range
-- Called by: XNP_WF_STANDARD.SOA_UPDATE_CUTOFF_DATE

PROCEDURE SOA_UPDATE_CUTOFF_DATE
 (p_ORDER_ID             IN NUMBER,
  p_LINEITEM_ID          IN NUMBER,
  p_WORKITEM_INSTANCE_ID IN NUMBER,
  p_FA_INSTANCE_ID       IN NUMBER,
  p_CUR_STATUS_TYPE_CODE    VARCHAR2,
  x_ERROR_CODE           OUT NOCOPY NUMBER,
  x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 );

-- Updates corresponding rows in the the SOA table based on SP type (i.e. donor or recipient)
-- All necessary values are got from the workitems table
-- Mandatory WI params : STARTING_NUMBER, ENDING_NUMBER,
-- DONOR_SP_ID,RECIPIENT_SP_ID,NEW_SP_DUE_DATE,ROUTING_NUMBER
-- Optional WI Params: OLD_SP_CUTOFF_DUE_DATE,CUSTOMER_ID,
-- CUSTOMER_NAME,ADDRESS_LINE1,CITY,PHONE,FAX,EMAIL,ZIP_CODE,
-- RETAIN_TN_FLAG,CUSTOMER_CONTACT_REQ_FLAG,
-- RETAIN_DIR_INFO_FLAG,CONTACT_NAME, CNAM_ADDRESS,
-- CNAM_SUBSYSTEM, ISVM_ADDRESS, ISVM_SUBSYSTEM, LIDB_ADDRESS,
-- LIDB_SUBSYSTEM, CLASS_ADDRESS, CLASS_SUBSYSTEM, WSMSC_ADDRESS,
-- WSMSC_SUBSYSTEM, RN_ADDRESS, RN_SUBSYSTEM, PAGER, PAGER_PIN,
-- INTERNET_ADDRESS, PREORDER_AUTHORIZATION_CODE, ACTIVATION_DUE_DATE
-- SUBSCRIPTION_TYPE
-- Called when: There is a order Peer's Porting
-- Order or OMS porting order
-- Called by: XNP_WF_STANDARD.SOA_CREATE_PORTING_ORDER
-- SV Status: Status with initial flag as true

PROCEDURE SOA_CREATE_PORTING_ORDER
 (p_ORDER_ID             IN NUMBER,
  p_LINEITEM_ID          IN NUMBER,
  p_WORKITEM_INSTANCE_ID IN NUMBER,
  p_FA_INSTANCE_ID       IN NUMBER,
  p_SP_ROLE                 VARCHAR2,
  x_ERROR_CODE           OUT NOCOPY NUMBER,
  x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 );

-- Gets the WI parameter PORTING_ID
-- and calls XNP_CORE.SOA_CHECK_NOTIFY_DIR_SVS
-- Called by:Donor's XNP_WF_STANDARD.SOA_CHECK_NOTIFY_DIR_SVS
-- @return 'Y' if true

PROCEDURE SOA_CHECK_NOTIFY_DIR_SVS
 (
 p_WORKITEM_INSTANCE_ID IN NUMBER
 ,x_CHECK_STATUS        OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE          OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 );

-- Extracts the (LOCAL)SP_NAME and compares it to donor,recipient
-- If either of them don't match checks
-- if its INITIAL DONOR.
-- WI parameters are referenced STARTING_NUMBER,
-- ENDING_NUMBER, DONOR_SP_ID,SP_NAME,RECIPIENT_SP_ID
-- Returns: DONOR, ORIG_DONOR, RECIPIENT
-- Called at: donor sp when need to check if its the
-- initial donor
-- Called by:Donor XNP_WF_STANDARD.DETERMINE_SP_ROLE

PROCEDURE DETERMINE_SP_ROLE
 (p_WORKITEM_INSTANCE_ID IN NUMBER
 ,x_SP_ROLE             OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE          OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 );


-- Procedure used to update the status of a SV
-- in XNP_SV_SOA to the given status
-- Using the WI_ID the starting and ending TN
-- is found to derive the SV
-- The foll WI parameters are checked STARTING_NUMBER,
-- ENDING_NUMBER, PORTING_ID

PROCEDURE SOA_UPDATE_SV_STATUS
 (p_ORDER_ID               IN NUMBER,
  p_LINEITEM_ID            IN NUMBER,
  p_WORKITEM_INSTANCE_ID   IN NUMBER,
  p_FA_INSTANCE_ID         IN NUMBER,
  p_CUR_STATUS_TYPE_CODE      VARCHAR2,
  p_NEW_STATUS_TYPE_CODE      VARCHAR2,
  p_STATUS_CHANGE_CAUSE_CODE  VARCHAR2,
  x_ERROR_CODE            OUT NOCOPY NUMBER,
  x_ERROR_MESSAGE         OUT NOCOPY VARCHAR2
 );

-- Update the status of the Porting Order Records to the new status
-- for the given PORTING_ID
-- (a.k.a OBJECT_REFERENCE) and
-- belonging to the (local) SP ID.
-- Called when: need to update the SV status according
-- to the activity parameter SV_STATUS
-- Gets the Item Attributes WORKITEM_INSTANCE
-- Calls XNP_CORE.SOA_UPDATE_SV_STATUS

PROCEDURE SOA_UPDATE_SV_STATUS
 (p_ORDER_ID               IN NUMBER,
  p_LINEITEM_ID            IN NUMBER,
  p_WORKITEM_INSTANCE_ID   IN NUMBER,
  p_FA_INSTANCE_ID         IN NUMBER,
  p_NEW_STATUS_TYPE_CODE      VARCHAR2,
  p_STATUS_CHANGE_CAUSE_CODE  VARCHAR2,
  x_ERROR_CODE             OUT NOCOPY NUMBER,
  x_ERROR_MESSAGE          OUT NOCOPY VARCHAR2
 );

-- Gets the TN range and calls XNP_CORE.SOA_CHECK_ORDER_STATUS
-- References the following WI parameter
-- ORDER_STATUS
-- Called when: Inquiry or Order response is awaited

PROCEDURE SOA_CHECK_ORDER_STATUS
 (p_WORKITEM_INSTANCE_ID IN NUMBER
 ,x_ORDER_STATUS         OUT NOCOPY VARCHAR2
 ,x_error_code           OUT NOCOPY NUMBER
 ,x_error_message        OUT NOCOPY VARCHAR2
 );

-- Checks if the records in the given status
-- @return 'Y' if true
--

PROCEDURE CHECK_SOA_STATUS_EXISTS
 (p_WORKITEM_INSTANCE_ID     NUMBER
 ,p_STATUS_TYPE_CODE         VARCHAR2
 ,x_CHECK_STATUS         OUT NOCOPY VARCHAR2
 ,x_error_code           OUT NOCOPY NUMBER
 ,x_error_message        OUT NOCOPY VARCHAR2
 );


-- Sets the ORDER_RESULT work item parameter value to give one

PROCEDURE SET_ORDER_RESULT
 (p_WORKITEM_INSTANCE_ID NUMBER
 ,p_ORDER_RESULT         VARCHAR2
 ,p_ORDER_REJECT_CODE    VARCHAR2
 ,p_ORDER_REJECT_EXPLN   VARCHAR2
 ,x_error_code       OUT NOCOPY NUMBER
 ,x_error_message    OUT NOCOPY VARCHAR2
 );

-- Publishes a single business event
-- The recipients of this event should have
-- already subscribed for it incase of
-- internal events
--
-- Note:
-- EVENT TYPE: The message/event type to send
-- PARAM LIST: gives names of the
-- workitem parameters which contain the values.
-- E.g. of format could be
-- S=$STARTING_NUMBER,E=$ENDING_NUMBER
--
-- CALLBACK_REF_ID: Gives the callback handle.

PROCEDURE PUBLISH_EVENT
 (p_ORDER_ID             NUMBER
 ,p_WORKITEM_INSTANCE_ID NUMBER
 ,p_FA_INSTANCE_ID       NUMBER
 ,p_EVENT_TYPE           VARCHAR2
 ,p_PARAM_LIST           VARCHAR2
 ,p_CALLBACK_REF_ID      VARCHAR2
 ,x_error_code       OUT NOCOPY NUMBER
 ,x_error_message    OUT NOCOPY VARCHAR2
 );

--  Sends a message to a single recipient
--  The recipients of this event should have
--  already subscribed for it incase of
--  internal events
--  WI Params:
--  ORDER ID: order id of this SFM order
--  EVENT TYPE: The message/event type to send
--  PARAM LIST: gives names of the
--  workitem parameters which contain the values.
--  E.g. of format could be
--  S=$STARTING_NUMBER,E=$ENDING_NUMBER
--  WORKITEM INSTANCE ID:gives the handle to fetch
--  the values.
--  CONSUMER: gives the procedure to get the fe name
--  (or adapter name) of the receiver
--  CALLBACK_REF_ID: Gives the callback handle.
--  RECEIVER: gives the procedure to get the recipient name
--  VERSION: Version number of the message
--  Mandatory WI params : Whatever parameter mentioned
--  in the 'PARAM LIST' and additional workitem parameter which
--  are configured as part of the message type definition.
--
--  The send procedure first checks if an adapter is available for
--  the recipient of the message and then goes ahead with the send.
--  If the adapter is not ready, an callback is registered to get
--  notified once the adapter is available.
--
-- @return XNP_ERRORS.G_ADAPTER_NOT_READY if ADAPTER is not ready
--
PROCEDURE SEND_MESSAGE
 (p_ORDER_ID             NUMBER
 ,p_WORKITEM_INSTANCE_ID NUMBER
 ,p_FA_INSTANCE_ID       NUMBER
 ,p_EVENT_TYPE           VARCHAR2
 ,p_PARAM_LIST           VARCHAR2
 ,p_CALLBACK_REF_ID      VARCHAR2
 ,p_CONSUMER             VARCHAR2
 ,p_RECEIVER             VARCHAR2
 ,p_VERSION              NUMBER
 ,x_error_code       OUT NOCOPY NUMBER
 ,x_error_message    OUT NOCOPY VARCHAR2
 );

-- Calls XNP_CORE.SMS_DELETE_FE_MAP
-- References WI params STARTING_NUMBER, ENDING_NUMBER
-- Called when: During provisioning phase of the order
--
PROCEDURE SMS_DELETE_FE_MAP
 (p_WORKITEM_INSTANCE_ID IN NUMBER
 ,p_FE_ID                IN NUMBER
 ,p_FEATURE_TYPE            VARCHAR2
 ,x_ERROR_CODE          OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 );

-- Gets the TN range for the given order
-- and checks if There exists a TN in the
-- given phase with the local SP performing
-- the given role
-- Mandatory WI params: STARTING_NUMBER,
-- ENDING_NUMBER, SP_NAME, PORTING_ID
--
PROCEDURE CHECK_PHASE_FOR_ROLE
 (p_WORKITEM_INSTANCE_ID IN NUMBER
 ,p_SP_ROLE              IN VARCHAR2
 ,p_PHASE_INDICATOR      IN VARCHAR2
 ,x_CHECK_STATUS        OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE          OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 );

-- Wrapper function for XDP_ENGINE package
-- Catches execptions incase of undefined
-- values. Ignores NO_DATA_FOUND errors
--
FUNCTION GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID NUMBER
   ,p_PARAMETER_NAME       VARCHAR2
   )
RETURN VARCHAR2;

-- Wrapper function for XDP_ENGINE package
-- Catches execptions incase of undefined
-- values. A workflow notification is sent
-- in case of exceptions
--
PROCEDURE SET_MANDATORY_WI_PARAM_VALUE
 (p_WORKITEM_INSTANCE_ID         NUMBER
 ,p_PARAMETER_NAME               VARCHAR2
 ,p_PARAMETER_VALUE              VARCHAR2
 ,p_PARAMETER_REFERENCE_VALUE IN VARCHAR2 DEFAULT NULL
 );

-- Wrapper function for XDP_ENGINE package
-- Catches execptions incase of undefined
-- values. raises NO_DATA_FOUND errors and
-- logs it in the wf_core.context information
--
FUNCTION GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID NUMBER
   ,p_PARAMETER_NAME       VARCHAR2
   )
RETURN VARCHAR2;

-- Wrapper function for XDP_ENGINE package
-- Catches execptions incase of undefined
-- values
--
PROCEDURE SET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID NUMBER
   ,p_PARAMETER_NAME       VARCHAR2
   ,p_PARAMETER_VALUE      VARCHAR2
   ,p_PARAMETER_REFERENCE_VALUE IN VARCHAR2 DEFAULT NULL
   );


-- Registers a callback for the given event
-- from the remote or local system.
-- Calls XNP_EVENT.SUBSCRIBE
--
PROCEDURE SUBSCRIBE_FOR_EVENT
 (p_MESSAGE_TYPE         IN VARCHAR2
 ,p_WORKITEM_INSTANCE_ID IN NUMBER
 ,p_CALLBACK_REF_ID         VARCHAR2
 ,p_PROCESS_REFERENCE    IN VARCHAR2
 ,p_ORDER_ID                NUMBER
 ,p_FA_INSTANCE_ID          NUMBER
 ,x_ERROR_CODE          OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 );

-- Checks if this is a subsequent porting request
-- @return Y or N
-- Expects the WI paramter 'SUBSEQUENT_PORT'
--
PROCEDURE SOA_IS_SUBSEQUENT_PORT
 (p_WORKITEM_INSTANCE_ID IN NUMBER
 ,x_CHECK_STATUS        OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE          OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 );

-- Updates the SMS_FE_MAP status for the SVs corresponding to the given TNs
-- to the new PROVISION_STATUS
--
PROCEDURE SMS_UPDATE_FE_MAP_STATUS
 (p_ORDER_ID               IN NUMBER,
  p_LINEITEM_ID            IN NUMBER,
  p_WORKITEM_INSTANCE_ID   IN NUMBER,
  p_FA_INSTANCE_ID         IN NUMBER,
  p_FEATURE_TYPE              VARCHAR2,
  p_FE_ID                     NUMBER,
  p_PROV_STATUS               VARCHAR2,
  x_ERROR_CODE            OUT NOCOPY NUMBER,
  x_ERROR_MESSAGE         OUT NOCOPY VARCHAR2
 );

-- Extracts the order information from SFM WI parameters
-- Mandatory WI Params: Gets the PORTING_ID, STARTING_NUMBER, ENDING_NUMBER,
-- PORTING_TIME,ROUTING_NUMBER
-- Optional WI Params: CNAM_ADDRESS, CNAM_SUBSYSTEM,
-- ISVM_ADDRESS, ISVM_SUBSYSTEM, LIDB_ADDRESS, LIDB_SUBSYSTEM,
-- CLASS_ADDRESS, CLASS_SUBSYSTEM, WSMSC_ADDRESS, WSMSC_SUBSYSTEM,
-- RN_ADDRESS, RN_SUBSYSTEM, SUBSCRIPTION_TYPE
-- Modifies entry in SMS table for each TN in the range
-- Called when: There is a Modify Ported Number
-- request from NRC
--
PROCEDURE SMS_MODIFY_PORTED_NUMBER
 (p_ORDER_ID               IN NUMBER,
  p_LINEITEM_ID            IN NUMBER,
  p_WORKITEM_INSTANCE_ID   IN NUMBER,
  p_FA_INSTANCE_ID         IN NUMBER,
  x_ERROR_CODE            OUT NOCOPY NUMBER,
  x_ERROR_MESSAGE         OUT NOCOPY VARCHAR2
 );

-- Calls xnp_core.check_donor_status_exists to check for a porting record
-- It checks if the record exists
-- for the number range and created by the donor
-- with the given status type code
-- Mandatory WI Params: STARTING_NUMBER,ENDING_NUMBER,DONOR_SP_ID
--
PROCEDURE SOA_CHECK_DON_STATUS_EXISTS
 (p_WORKITEM_INSTANCE_ID IN NUMBER
 ,P_STATUS_TO_CHECK_WITH IN VARCHAR2
 ,x_CHECK_STATUS        OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE          OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 );

-- Calls xnp_core.check_recipient_status_exists
-- to check if there exists a porting record
-- for the number range and created by the donor
-- with the given stxatus type code
-- Mandatory WI Params: STARTING_NUMBER,ENDING_NUMBER,RECIPIENT_SP_ID
--
PROCEDURE SOA_CHECK_REC_STATUS_EXISTS
 (p_WORKITEM_INSTANCE_ID IN NUMBER
 ,P_STATUS_TO_CHECK_WITH IN VARCHAR2
 ,x_CHECK_STATUS        OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE          OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 );

-- Updates the Notes info
-- Mandatory WI Params: PORTING_ID
-- Optional WI Params COMMETS,NOTES,PREORDER_AUTHORIZATION_CODE
--
PROCEDURE SOA_UPDATE_NOTES_INFO
 (p_ORDER_ID               IN NUMBER,
  p_LINEITEM_ID            IN NUMBER,
  p_WORKITEM_INSTANCE_ID   IN NUMBER,
  p_FA_INSTANCE_ID         IN NUMBER,
  x_ERROR_CODE            OUT NOCOPY NUMBER,
  x_ERROR_MESSAGE         OUT NOCOPY VARCHAR2
 );

-- Updates the Network information for the given Porting ID in XNP_SV_SOA
-- Mandatory WI Params: ROUTING_NUMBER
-- Optional WI Params: ROUTING_NUMBER,
-- CNAM_ADDRESS, CNAM_SUBSYSTEM, ISVM_ADDRESS
-- ISVM_SUBSYSTEM, LIDB_ADDRESS, LIDB_SUBSYSTEM
-- CLASS_ADDRESS,CLASS_SUBSYSTEM,WSMSC_ADDRESS,
-- WSMSC_SUBSYSTEM, RN_ADDRESS, RN_SUBSYSTEM
--
PROCEDURE SOA_UPDATE_NETWORK_INFO
 (p_ORDER_ID               IN NUMBER,
  p_LINEITEM_ID            IN NUMBER,
  p_WORKITEM_INSTANCE_ID   IN NUMBER,
  p_FA_INSTANCE_ID         IN NUMBER,
  x_ERROR_CODE            OUT NOCOPY NUMBER,
  x_ERROR_MESSAGE         OUT NOCOPY VARCHAR2
 );


-- Updates the Customer information for the Porting ID
-- Mandatory WI Params: PORTING_ID
-- Optional WI Params: PAGER, PAGER_PIN,INTERNET_ADDRESS, CUSTOMER_ID,
-- CUSTOMER_NAME,ADDRESS_LINE1,CITY,PHONE,FAX,EMAIL,ZIP_CODE,
-- CUSTOMER_CONTACT_REQ_FLAG,CONTACT_NAME
--
PROCEDURE SOA_UPDATE_CUSTOMER_INFO
 (p_ORDER_ID               IN NUMBER,
  p_LINEITEM_ID            IN NUMBER,
  p_WORKITEM_INSTANCE_ID   IN NUMBER,
  p_FA_INSTANCE_ID         IN NUMBER,
  x_ERROR_CODE            OUT NOCOPY NUMBER,
  x_ERROR_MESSAGE         OUT NOCOPY VARCHAR2
 );

-- Runtime Validation for NP Work item
-- Calls XNP_CORE.Runtime_validation
-- Optional WI Params: STARTING_NUMBER,ENDING_NUMBER,ROUTING_NUMBER,
-- DONOR_SP_ID,RECIPIENT_SP_ID

  PROCEDURE RUNTIME_VALIDATION
 ( p_ORDER_ID             IN NUMBER
  ,p_LINE_ITEM_ID         IN NUMBER
  ,p_WORKITEM_INSTANCE_ID IN NUMBER
  ,x_ERROR_CODE          OUT NOCOPY NUMBER
  ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 );

-- Remove all Waiting/Active Timers and Expire all Waiting/Activ
-- Callback Events
   PROCEDURE DEREGISTER_ALL
    ( p_order_id 	IN NUMBER
     ,x_error_code 	OUT NOCOPY NUMBER
     ,x_error_message 	OUT NOCOPY VARCHAR2
    );

END XNP_STANDARD;

 

/
