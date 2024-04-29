--------------------------------------------------------
--  DDL for Package Body XNP_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_STANDARD" AS
/* $Header: XNPSTACB.pls 120.1.12010000.2 2008/09/25 05:24:11 mpathani ship $ */

 ------------------------------------------------------------------
 -- Wrapper function for XDP_ENGINE package
 -- Catches execptions incase of undefined
 -- values.
 -- When exception encountered logs it in
 -- the wf_core.context information
 ------------------------------------------------------------------
FUNCTION GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID NUMBER
   ,p_PARAMETER_NAME       VARCHAR2
   )
RETURN VARCHAR2
IS

l_VALUE VARCHAR2(4000) := NULL;

BEGIN

 l_VALUE :=
   XDP_ENGINE.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,p_PARAMETER_NAME
   );

 if (l_value IS NULL) then
   raise NO_DATA_FOUND;
 end if;

 RETURN l_VALUE;

 EXCEPTION
  WHEN OTHERS THEN
   XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_STANDARD'
       ,P_PROC_NAME            => 'GET_MANDATORY_WI_PARAM_VALUE'
       ,P_MSG_NAME             => 'GET_MANDATORY_WI_PARAM_ERR'
       ,P_WORKITEM_INSTANCE_ID => p_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'WIID'
       ,P_VAL1                 => to_char(p_WORKITEM_INSTANCE_ID)
       ,P_TOK2                 => 'PARAM_NAME'
       ,P_VAL2                 => p_PARAMETER_NAME
       ,P_TOK3                 => 'ERRTEXT'
       ,P_VAL3                 => SQLERRM
       );

   raise;

END GET_MANDATORY_WI_PARAM_VALUE;

 ------------------------------------------------------------------
 -- Wrapper function for XDP_ENGINE package
 -- Catches execptions incase of undefined
 -- values. A workflow notification is sent
 -- in case of exceptions
 ------------------------------------------------------------------
PROCEDURE SET_MANDATORY_WI_PARAM_VALUE
 (p_WORKITEM_INSTANCE_ID         NUMBER
 ,p_PARAMETER_NAME               VARCHAR2
 ,p_PARAMETER_VALUE              VARCHAR2
 ,p_PARAMETER_REFERENCE_VALUE IN VARCHAR2 DEFAULT NULL
 )
IS
BEGIN

 XDP_ENGINE.SET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,p_PARAMETER_NAME
   ,p_PARAMETER_VALUE
   ,p_PARAMETER_REFERENCE_VALUE
   );

 EXCEPTION
  WHEN OTHERS THEN

   XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_STANDARD'
       ,P_PROC_NAME            => 'SET_MANDATORY_WI_PARAM_VALUE'
       ,P_MSG_NAME             => 'SET_MANDATORY_WI_PARAM_ERR'
       ,P_WORKITEM_INSTANCE_ID => p_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'WIID'
       ,P_VAL1                 => to_char(p_WORKITEM_INSTANCE_ID)
       ,P_TOK2                 => 'PARAM_NAME'
       ,P_VAL2                 => p_PARAMETER_NAME
       ,P_TOK3                 => 'ERRTEXT'
       ,P_VAL3                 => SQLERRM
       );

   RAISE;

END SET_MANDATORY_WI_PARAM_VALUE;

 ------------------------------------------------------------------
 -- Wrapper function for XDP_ENGINE package
 -- Catches execptions incase of undefined
 -- values
 ------------------------------------------------------------------
PROCEDURE SET_WORKITEM_PARAM_VALUE
 (p_WORKITEM_INSTANCE_ID         NUMBER
 ,p_PARAMETER_NAME               VARCHAR2
 ,p_PARAMETER_VALUE              VARCHAR2
 ,p_PARAMETER_REFERENCE_VALUE IN VARCHAR2 DEFAULT NULL
 )
IS
BEGIN

 XDP_ENGINE.SET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,p_PARAMETER_NAME
   ,p_PARAMETER_VALUE
   ,p_PARAMETER_REFERENCE_VALUE
   );

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    null;
  WHEN OTHERS THEN
    null;

END SET_WORKITEM_PARAM_VALUE;

 ------------------------------------------------------------------
 -- Wrapper function for XDP_ENGINE package
 -- Catches execptions incase of undefined
 -- values. Ignores NO_DATA_FOUND errors
 ------------------------------------------------------------------
FUNCTION GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID NUMBER
   ,p_PARAMETER_NAME       VARCHAR2
   )
RETURN VARCHAR2
IS
l_VALUE VARCHAR2(4000) := NULL;
BEGIN

 l_VALUE :=
   XDP_ENGINE.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,p_PARAMETER_NAME
   );

 RETURN l_VALUE;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
   RETURN NULL;
  WHEN OTHERS THEN
   RETURN NULL;

END GET_WORKITEM_PARAM_VALUE;


 --------------------------------------------------------------------
 --
 -- Called when: there is a Create Ported Number
 -- request from NRC
 -- Called by: XNP_STANDARD.SMS_CREATE_PORTED_NUMBER
 -- Description: Extracts the order information from SFM
 -- Workitem params
 -- Mandatory: Gets the PORTING_ID, STARTING_NUMBER, ENDING_NUMBER,
 -- PORTING_TIME,ROUTING_NUMBER
 -- Optional: CNAM_ADDRESS, CNAM_SUBSYSTEM,
 -- ISVM_ADDRESS, ISVM_SUBSYSTEM, LIDB_ADDRESS, LIDB_SUBSYSTEM,
 -- CLASS_ADDRESS, CLASS_SUBSYSTEM, WSMSC_ADDRESS, WSMSC_SUBSYSTEM,
 -- RN_ADDRESS, RN_SUBSYSTEM, SUBSCRIPTION_TYPE
 -- Creates an entry in SMS table for each TN in the range
 ------------------------------------------------------------------
PROCEDURE SMS_CREATE_PORTED_NUMBER
 (
 p_ORDER_ID             IN  NUMBER,
 p_LINEITEM_ID          IN  NUMBER,
 p_WORKITEM_INSTANCE_ID IN  NUMBER,
 p_FA_INSTANCE_ID       IN  NUMBER,
 x_ERROR_CODE           OUT NOCOPY NUMBER,
 x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 )
IS
l_sv_id             NUMBER;
l_porting_id        VARCHAR2(80) := null;
l_routing_number    VARCHAR2(40);
l_starting_number   VARCHAR2(20);
l_porting_time      VARCHAR2(40);
l_ending_number     VARCHAR2(20);
l_counter           BINARY_INTEGER;
l_index             BINARY_INTEGER := 0;
l_NRC_ID            NUMBER ;
l_GEO_ID            NUMBER ;
l_ROUTING_NUMBER_ID NUMBER;

l_SUBSCRIPTION_TYPE VARCHAR2(80) := NULL;
l_CNAM_ADDRESS      VARCHAR2(80) := NULL;
l_CNAM_SUBSYSTEM    VARCHAR2(80) := NULL;
l_ISVM_ADDRESS      VARCHAR2(80) := NULL;
l_ISVM_SUBSYSTEM    VARCHAR2(80) := NULL;
l_LIDB_ADDRESS      VARCHAR2(80) := NULL;
l_LIDB_SUBSYSTEM    VARCHAR2(80) := NULL;
l_CLASS_ADDRESS     VARCHAR2(80) := NULL;
l_CLASS_SUBSYSTEM   VARCHAR2(80) := NULL;
l_WSMSC_ADDRESS     VARCHAR2(80) := NULL;
l_WSMSC_SUBSYSTEM   VARCHAR2(80) := NULL;
l_RN_ADDRESS        VARCHAR2(80) := NULL;
l_RN_SUBSYSTEM      VARCHAR2(80) := NULL;
l_NUMBER_RANGE_ID   NUMBER := NULL;

BEGIN
  x_error_code := 0;

  l_porting_id :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PORTING_ID'
   );

  l_porting_time :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PORTING_TIME'
   );

  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  -- verify if its a valid number range
  xnp_core.get_number_range_id( p_starting_number => l_starting_number,
                                p_ending_number   => l_ending_number,
                                x_number_range_id => l_number_range_id,
                                x_error_code      => x_error_code,
                                x_error_message   => x_error_message
                                );
  IF (x_error_code <> 0) THEN
        return;
  END IF;

  l_routing_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ROUTING_NUMBER'
   );

  -- Get the routing_number_id corresponding to the code

  XNP_CORE.GET_ROUTING_NUMBER_ID
   (l_ROUTING_NUMBER
   ,l_ROUTING_NUMBER_ID
   ,x_ERROR_CODE
   ,x_ERROR_MESSAGE
   );
  IF x_ERROR_CODE <> 0  THEN
    RETURN;
  END IF;

  l_SUBSCRIPTION_TYPE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'SUBSCRIPTION_TYPE'
   );
  IF (l_SUBSCRIPTION_TYPE IS null) THEN
    l_SUBSCRIPTION_TYPE := 'NP';
  END IF;

  l_CNAM_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CNAM_ADDRESS'
   );

  l_CNAM_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CNAM_SUBSYSTEM'
   );

  l_ISVM_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ISVM_ADDRESS'
   );

  l_ISVM_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ISVM_SUBSYSTEM'
   );

  l_LIDB_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'LIDB_ADDRESS'
   );

  l_LIDB_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'LIDB_SUBSYSTEM'
   );

  l_CLASS_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CLASS_ADDRESS'
   );

  l_CLASS_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CLASS_SUBSYSTEM'
   );

  l_WSMSC_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'WSMSC_ADDRESS'
   );

  l_WSMSC_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'WSMSC_SUBSYSTEM'
   );

  l_RN_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'RN_ADDRESS'
   );

  l_RN_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'RN_SUBSYSTEM'
   );

  XNP_CORE.SMS_CREATE_PORTED_NUMBER
   (p_PORTING_ID           =>l_porting_id
   ,p_STARTING_NUMBER      =>to_number(l_STARTING_NUMBER)
   ,p_ENDING_NUMBER        =>to_number(l_ENDING_NUMBER)
   ,p_SUBSCRIPTION_TYPE    =>l_SUBSCRIPTION_TYPE
   ,p_ROUTING_NUMBER_ID    =>l_ROUTING_NUMBER_ID
   ,p_PORTING_TIME         =>XNP_UTILS.CANONICAL_TO_DATE(l_porting_time)
   ,p_CNAM_ADDRESS         =>l_CNAM_ADDRESS
   ,p_CNAM_SUBSYSTEM       =>l_CNAM_SUBSYSTEM
   ,p_ISVM_ADDRESS         =>l_ISVM_ADDRESS
   ,p_ISVM_SUBSYSTEM       =>l_ISVM_SUBSYSTEM
   ,p_LIDB_ADDRESS         =>l_LIDB_ADDRESS
   ,p_LIDB_SUBSYSTEM       =>l_LIDB_SUBSYSTEM
   ,p_CLASS_ADDRESS        =>l_CLASS_ADDRESS
   ,p_CLASS_SUBSYSTEM      =>l_CLASS_SUBSYSTEM
   ,p_WSMSC_ADDRESS        =>l_WSMSC_ADDRESS
   ,p_WSMSC_SUBSYSTEM      =>l_WSMSC_SUBSYSTEM
   ,p_RN_ADDRESS           =>l_RN_ADDRESS
   ,p_RN_SUBSYSTEM         =>l_RN_SUBSYSTEM
   ,p_ORDER_ID             =>P_ORDER_ID
   ,p_LINEITEM_ID          =>p_LINEITEM_ID
   ,p_WORKITEM_INSTANCE_ID =>p_WORKITEM_INSTANCE_ID
   ,p_FA_INSTANCE_ID       =>p_FA_INSTANCE_ID
   ,x_ERROR_CODE           =>x_ERROR_CODE
   ,x_ERROR_MESSAGE        =>x_ERROR_MESSAGE
   );
  EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN'
          ,'XNP_STANDARD.SMS_CREATE_PORTED_NUMBER');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;
END SMS_CREATE_PORTED_NUMBER;


 --------------------------------------------------------------------
 --
 -- Called when: there is a Delete Ported Number
 -- request from NRC
 -- Called by: XNP_STANDARD.SMS_DELETE_PORTED_NUMBER
 -- Description: Extracts the order information from SFM
 -- Workitem params table
 -- Gets the STARTING_NUMBER, ENDING_NUMBER
 -- and calls XNP_CORE.SMS_DELETE_PORTED_NUMBER
 --
 ------------------------------------------------------------------
PROCEDURE SMS_DELETE_PORTED_NUMBER
 (p_WORKITEM_INSTANCE_ID IN NUMBER
 ,x_ERROR_CODE           OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 )
IS
l_starting_number VARCHAR2(20);
l_ending_number   VARCHAR2(20);

BEGIN

  x_error_code := 0;

  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  XNP_CORE.SMS_DELETE_PORTED_NUMBER
    (p_STARTING_NUMBER=>l_starting_number
    ,p_ENDING_NUMBER=>l_ending_number
    ,x_ERROR_CODE=>x_ERROR_CODE
    ,x_ERROR_MESSAGE=>x_ERROR_MESSAGE
    );

END SMS_DELETE_PORTED_NUMBER;

 --------------------------------------------------------------------
 --
 -- Called when: there is a Pre-order Peer's Porting
 --   Inquiry
 -- Called by: XNP_STANDARD.SOA_PORTING_INQUIRY
 -- Description:
 --  Inserts a row in the the SOA table based on the
 --   SP type (i.e. donor or recipient)
 --  All necessary values are got from the workitems table
 -- SV Status: PREORDER_PENDING
 ------------------------------------------------------------------
/*********   commented this procedure as this procedure is not found to be called any where in the code
PROCEDURE SOA_PORTING_INQUIRY
 (
 p_WORKITEM_INSTANCE_ID IN NUMBER
 ,x_ERROR_CODE          OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 )
IS
BEGIN
  x_error_code := 0;
  NULL;
END SOA_PORTING_INQUIRY;
************/
 --------------------------------------------------------------------
 --
 -- Called by: XNP_STANDARD.SOA_UPDATE_CUTOFF_DATE
 -- Description: Extracts the order information from SFM
 --   Workitem params table namely PORTING_ID, STARTING_NUMBER,
 --   ENDING_NUMBER, OLD_SP_CUTOFF_DUE_DATE
 -- Calls XNP_CORE.SOA_UPDATE_CUTOFF_DATE to update the
 --  cutoff date of each TN in the range
 ------------------------------------------------------------------
PROCEDURE SOA_UPDATE_CUTOFF_DATE
 ( p_ORDER_ID             IN  NUMBER,
   p_LINEITEM_ID          IN  NUMBER,
   p_WORKITEM_INSTANCE_ID IN  NUMBER,
   p_FA_INSTANCE_ID       IN  NUMBER,
   p_CUR_STATUS_TYPE_CODE     VARCHAR2,
   x_ERROR_CODE           OUT NOCOPY NUMBER,
   x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 )
IS
l_porting_id      VARCHAR2(40) := null;
l_sv_id           NUMBER;
l_starting_number VARCHAR2(20);
l_ending_number   VARCHAR2(20);
l_porting_time    VARCHAR2(40);
l_counter         BINARY_INTEGER;
l_index           BINARY_INTEGER := 0;
l_SV_ID           NUMBER;
l_LOCAL_SP_ID     NUMBER := 0;
l_cutoff_date     VARCHAR2(40);
l_SP_NAME         VARCHAR2(40) := NULL;

BEGIN

  x_error_code := 0;

  l_porting_id :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PORTING_ID'
   );

  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  l_cutoff_date :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'OLD_SP_CUTOFF_DUE_DATE'
   );

  l_SP_NAME :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'SP_NAME'
   );

  IF( l_porting_id is not null) THEN

    -- call updation procedure to update the status

    XNP_CORE.SOA_UPDATE_CUTOFF_DATE
     (p_porting_id            => l_porting_id
     ,p_old_sp_cutoff_due_date=> xnp_utils.canonical_to_date(l_cutoff_date)
     ,p_local_sp_id           => l_LOCAL_SP_ID
     ,p_order_id              => p_order_id
     ,p_lineitem_id           => p_lineitem_id
     ,p_workitem_instance_id  => p_workitem_instance_id
     ,p_fa_instance_id        => p_fa_instance_id
     ,x_error_code            => x_ERROR_CODE
     ,x_error_message         => x_ERROR_MESSAGE
     );
  ELSE
    -- call updation procedure to update the status

    XNP_CORE.SOA_UPDATE_CUTOFF_DATE
     (p_starting_number       => l_starting_number
     ,p_ending_number         => l_ending_number
     ,p_CUR_STATUS_TYPE_CODE  => p_CUR_STATUS_TYPE_CODE
     ,p_local_sp_id           => l_LOCAL_SP_ID
     ,p_old_sp_cutoff_due_date=> xnp_utils.canonical_to_date(l_cutoff_date)
     ,p_order_id              => p_order_id
     ,p_lineitem_id           => p_lineitem_id
     ,p_workitem_instance_id  => p_workitem_instance_id
     ,p_fa_instance_id        => p_fa_instance_id
     ,x_error_code            => x_ERROR_CODE
     ,x_error_message         => x_ERROR_MESSAGE
     );
  END IF;

   EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.SOA_UPDATE_CUTOFF_DATE');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END SOA_UPDATE_CUTOFF_DATE;


 --------------------------------------------------------------------
 --
 -- Called when: there is a order Peer's Porting
 -- Order or OMS porting order
 -- Called by: XNP_WF_STANDARD.SOA_CREATE_PORTING_ORDER
 -- Description:
 -- Updates corresponding rows in the the SOA table based on
 -- SP type (i.e. donor or recipient)
 -- All necessary values are got from the workitems table
 -- Mandatory Parameters needed: STARTING_NUMBER, ENDING_NUMBER,
 -- DONOR_SP_ID,RECIPIENT_SP_ID,NEW_SP_DUE_DATE,ROUTING_NUMBER
 -- Optional Parameters : OLD_SP_CUTOFF_DUE_DATE,CUSTOMER_ID,
 -- CUSTOMER_NAME,CUSTOMER_TYPE,ADDRESS_LINE1,ADDRESS_LINE2,CITY,PHONE,FAX,EMAIL,ZIP_CODE,COUNTRY,
 -- RETAIN_TN_FLAG,CUSTOMER_CONTACT_REQ_FLAG,ORDER_PRIORITY,
 -- RETAIN_DIR_INFO_FLAG,CONTACT_NAME, CNAM_ADDRESS,
 -- CNAM_SUBSYSTEM, ISVM_ADDRESS, ISVM_SUBSYSTEM, LIDB_ADDRESS,
 -- LIDB_SUBSYSTEM, CLASS_ADDRESS, CLASS_SUBSYSTEM, WSMSC_ADDRESS,
 -- WSMSC_SUBSYSTEM, RN_ADDRESS, RN_SUBSYSTEM, PAGER, PAGER_PIN,
 -- INTERNET_ADDRESS, PREORDER_AUTHORIZATION_CODE, ACTIVATION_DUE_DATE,
 -- SUBSCRIPTION_TYPE,COMMENTS,NOTES
 -- SV Status: Status with initial flag as true
 ------------------------------------------------------------------
PROCEDURE SOA_CREATE_PORTING_ORDER
 ( p_ORDER_ID             IN  NUMBER,
   p_LINEITEM_ID          IN  NUMBER,
   p_WORKITEM_INSTANCE_ID IN  NUMBER,
   p_FA_INSTANCE_ID       IN  NUMBER,
   p_SP_ROLE                  VARCHAR2,
   x_ERROR_CODE           OUT NOCOPY NUMBER,
   x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 )
IS
  l_PORTING_ID                VARCHAR2(40) := null;
  l_STARTING_NUMBER           VARCHAR2(40);
  l_ENDING_NUMBER             VARCHAR2(40);
  l_DONOR_SP_ID               NUMBER := 0;
  l_RECIPIENT_SP_ID           NUMBER := 0;
  l_ROUTING_NUMBER_ID         NUMBER := 0;
  l_ROUTING_NUMBER            VARCHAR2(40) := null;
  l_SP_DUE_DATE               VARCHAR2(40);
  l_OLD_SP_CUTOFF_DUE_DATE    VARCHAR2(40);
  l_CUSTOMER_ID               VARCHAR2(30);
  l_CUSTOMER_NAME             VARCHAR2(80);
  l_CUSTOMER_TYPE             VARCHAR2(10);
  l_ADDRESS_LINE1             VARCHAR2(400);
  l_ADDRESS_LINE2             VARCHAR2(400);
  l_CITY                      VARCHAR2(40);
  l_PHONE                     VARCHAR2(40);
  l_FAX                       VARCHAR2(40);
  l_EMAIL                     VARCHAR2(40);
  l_ZIP_CODE                  VARCHAR2(40);
  l_COUNTRY                   VARCHAR2(40);
  l_NEW_SP_DUE_DATE           VARCHAR2(40);
  l_OLD_SP_DUE_DATE           VARCHAR2(40);
  l_COMMENTS                  VARCHAR2(2000);
  l_NOTES                     VARCHAR2(2000);
  l_SUBSCRIPTION_TYPE         VARCHAR2(80) := 'NP';
  l_CUSTOMER_CONTACT_REQ_FLAG VARCHAR2(3);
  l_RETAIN_TN_FLAG            VARCHAR2(3);
  l_RETAIN_DIR_INFO_FLAG      VARCHAR2(3);
  l_RETAIN_TN                   VARCHAR2(5);
  l_RETAIN_DIR_INFO             VARCHAR2(5);
  l_DONOR_SP_CODE               VARCHAR2(80);
  l_RECIPIENT_SP_CODE           VARCHAR2(80);
  l_CONTACT_REQUESTED           VARCHAR2(5);
  l_counter                     BINARY_INTEGER;
  l_index                       BINARY_INTEGER := 0;
  l_CONTACT_NAME                VARCHAR2(40) := NULL;
  l_CNAM_ADDRESS                VARCHAR2(80) := NULL;
  l_CNAM_SUBSYSTEM              VARCHAR2(80) := NULL;
  l_ISVM_ADDRESS                VARCHAR2(80) := NULL;
  l_ISVM_SUBSYSTEM              VARCHAR2(80) := NULL;
  l_LIDB_ADDRESS                VARCHAR2(80) := NULL;
  l_LIDB_SUBSYSTEM              VARCHAR2(80) := NULL;
  l_CLASS_ADDRESS               VARCHAR2(80) := NULL;
  l_CLASS_SUBSYSTEM             VARCHAR2(80) := NULL;
  l_WSMSC_ADDRESS               VARCHAR2(80) := NULL;
  l_WSMSC_SUBSYSTEM             VARCHAR2(80) := NULL;
  l_RN_ADDRESS                  VARCHAR2(80) := NULL;
  l_RN_SUBSYSTEM                VARCHAR2(80) := NULL;

  l_PAGER                       VARCHAR2(20) := NULL;
  l_PAGER_PIN                   VARCHAR2(80) := NULL;
  l_INTERNET_ADDRESS            VARCHAR2(40) := NULL;
  l_PREORDER_AUTHORIZATION_CODE VARCHAR2(20) := NULL;
  l_ACTIVATION_DUE_DATE         VARCHAR2(40) := NULL;
  l_ORDER_PRIORITY              VARCHAR2(30) := NULL;
  l_SUBSEQUENT_PORT_FLAG        VARCHAR2(1) := 'N';
--  l_NUMBER_RANGE_ID             NUMBER := NULL;
  l_VALIDATION_FLAG             VARCHAR2(1):= 'Y';

BEGIN
  x_error_code := 0;

  l_PORTING_ID :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PORTING_ID'
   );

  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

/**** Moved this code to validate the number range to individual
      create_port_order APIs in XNP_CORE package on 04/11/2001 -- spusegao
      in order to accomodate NRC_NOVALIDATION SP Role

  -- verify if its a valid number range

  xnp_core.get_number_range_id(	p_starting_number => l_starting_number,
				p_ending_number   => l_ending_number,
				x_number_range_id => l_number_range_id,
				x_error_code      => x_error_code,
				x_error_message   => x_error_message
				);
  IF (x_error_code <> 0) THEN
	return;
  END IF;
******/

  l_DONOR_SP_CODE :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'DONOR_SP_ID'
   );

  -- Get the SP id for this SP code
  XNP_CORE.GET_SP_ID
   (l_DONOR_SP_CODE
   ,l_DONOR_SP_ID
   ,x_ERROR_CODE
   ,x_ERROR_MESSAGE
   );

  IF x_ERROR_CODE <> 0  THEN
   RETURN;
  END IF;

  l_RECIPIENT_SP_CODE :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'RECIPIENT_SP_ID'
   );

  -- Get the SP id for this recipient code
  XNP_CORE.GET_SP_ID
   (l_RECIPIENT_SP_CODE
   ,l_RECIPIENT_SP_ID
   ,x_ERROR_CODE
   ,x_ERROR_MESSAGE
   );

  IF x_ERROR_CODE <> 0  THEN
   RETURN;
  END IF;

  -- The new sp due date is part of order incase of recipient
  -- The new sp due date is part of inbound mesg incase of donor

  l_new_sp_due_date :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (p_WORKITEM_INSTANCE_ID
     ,'NEW_SP_DUE_DATE'
     );
    l_SP_DUE_DATE := l_new_sp_due_date;


  l_OLD_SP_CUTOFF_DUE_DATE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'OLD_SP_CUTOFF_DUE_DATE'
   );

  l_CUSTOMER_ID :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CUSTOMER_ID'
   );

  l_CUSTOMER_NAME :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CUSTOMER_NAME'
   );

  l_CUSTOMER_TYPE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CUSTOMER_TYPE'
   );

  l_ADDRESS_LINE1 :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ADDRESS_LINE1'
   );

  l_ADDRESS_LINE2 :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ADDRESS_LINE2'
   );

  l_CITY :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CITY'
   );

  l_PHONE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PHONE'
   );

  l_FAX :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'FAX'
   );

  l_EMAIL :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'EMAIL'
   );

  l_ZIP_CODE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ZIP_CODE'
   );

  l_COUNTRY :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'COUNTRY'
   );

  l_RETAIN_TN_FLAG :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'RETAIN_TN_FLAG'
   );

  l_CUSTOMER_CONTACT_REQ_FLAG :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CUSTOMER_CONTACT_REQ_FLAG'
   );

  l_CONTACT_NAME :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CONTACT_NAME'
   );

  l_CNAM_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CNAM_ADDRESS'
   );

  l_CNAM_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CNAM_SUBSYSTEM'
   );

  l_ISVM_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ISVM_ADDRESS'
   );

  l_ISVM_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ISVM_SUBSYSTEM'
   );

  l_LIDB_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'LIDB_ADDRESS'
   );

  l_LIDB_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'LIDB_SUBSYSTEM'
   );

  l_CLASS_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CLASS_ADDRESS'
   );

  l_CLASS_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CLASS_SUBSYSTEM'
   );

  l_WSMSC_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'WSMSC_ADDRESS'
   );

  l_WSMSC_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'WSMSC_SUBSYSTEM'
   );

  l_RN_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'RN_ADDRESS'
   );

  l_RN_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'RN_SUBSYSTEM'
   );

  l_PAGER :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PAGER'
   );

  l_PAGER_PIN :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PAGER_PIN'
   );

  l_INTERNET_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'INTERNET_ADDRESS'
   );

  l_RETAIN_DIR_INFO_FLAG :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'RETAIN_DIR_INFO_FLAG'
   );

  l_PREORDER_AUTHORIZATION_CODE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PREORDER_AUTHORIZATION_CODE'
   );

  l_ACTIVATION_DUE_DATE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ACTIVATION_DUE_DATE'
   );

  l_ORDER_PRIORITY :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ORDER_PRIORITY'
   );

  l_COMMENTS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'COMMENTS'
   );

  l_NOTES :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'NOTES'
   );

  l_SUBSCRIPTION_TYPE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'SUBSCRIPTION_TYPE'
   );
  IF (l_SUBSCRIPTION_TYPE IS null) THEN
    l_SUBSCRIPTION_TYPE := 'NP';
  END IF;

   ------------------------------------------------------------------
   -- Create an SV in the SOA table for each TN
   -- The due dates should be entered based on self's identity
   -- i.e. for recipient, enter NEW_SP_DUE_DATE and
   -- donor enter OLD...
   ------------------------------------------------------------------

   -- Get the routing number id

   l_ROUTING_NUMBER :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
      (p_WORKITEM_INSTANCE_ID
      ,'ROUTING_NUMBER'
      );


-- Bug 2239283. Set the Subsequent Porting Flag regardless of the
-- SP Role

     l_SUBSEQUENT_PORT_FLAG :=
     XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
      (p_WORKITEM_INSTANCE_ID
      ,'SUBSEQUENT_PORT'
      );

     IF (l_SUBSEQUENT_PORT_FLAG = NULL)  THEN
       l_SUBSEQUENT_PORT_FLAG := 'N';
     END IF;

/****
       Moved this validation call to individual create_porting_order
       APIs in XNPCORE package to accomodate NRC_NOVALIDATION
       on 04/11/2001 --spusegao

   -- Get the routing_number_id corresponding to the code

   IF (l_ROUTING_NUMBER IS NOT NULL) THEN

     XNP_CORE.GET_ROUTING_NUMBER_ID
      (l_routing_number
      ,l_ROUTING_NUMBER_ID
      ,x_ERROR_CODE
      ,x_ERROR_MESSAGE
      );

     IF x_ERROR_CODE <> 0  THEN
       RETURN;
     END IF;

   END IF;
****/

  IF   (p_SP_ROLE = 'RECIPIENT')
    OR (p_SP_ROLE = 'NRC')
    OR (p_SP_ROLE = 'NRC_WITHOUT_VALIDATION')  THEN

  --{ case of recipient or nrc
  --
-- Bug 2239283. Set the Subsequent Porting Flag regardless of the
-- SP Role. Moved the code above. Commented this code
--     l_SUBSEQUENT_PORT_FLAG :=
--     XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
--      (p_WORKITEM_INSTANCE_ID
--      ,'SUBSEQUENT_PORT'
--      );

--     IF (l_SUBSEQUENT_PORT_FLAG = NULL)  THEN
--       l_SUBSEQUENT_PORT_FLAG := 'N';
--     END IF;

     IF (p_SP_ROLE = 'RECIPIENT')  THEN
     --{  Create porting order for the recipient SP

      XNP_CORE.SOA_CREATE_REC_PORT_ORDER
      (p_PORTING_ID                 =>l_PORTING_ID
      ,p_STARTING_NUMBER            =>to_number(l_STARTING_NUMBER)
      ,p_ENDING_NUMBER              =>to_number(l_ENDING_NUMBER)
      ,p_SUBSCRIPTION_TYPE          =>l_SUBSCRIPTION_TYPE
      ,p_DONOR_SP_ID                =>l_DONOR_SP_ID
      ,p_RECIPIENT_SP_ID            =>l_RECIPIENT_SP_ID
      ,p_ROUTING_NUMBER             =>l_ROUTING_NUMBER
      ,p_NEW_SP_DUE_DATE            =>XNP_UTILS.CANONICAL_TO_DATE(l_SP_DUE_DATE)
      ,p_OLD_SP_CUTOFF_DUE_DATE     =>XNP_UTILS.CANONICAL_TO_DATE(l_OLD_SP_CUTOFF_DUE_DATE)
      ,p_CUSTOMER_ID                =>l_CUSTOMER_ID
      ,p_CUSTOMER_NAME              =>l_CUSTOMER_NAME
      ,p_CUSTOMER_TYPE              =>l_CUSTOMER_TYPE
      ,p_ADDRESS_LINE1              =>l_ADDRESS_LINE1
      ,p_ADDRESS_LINE2              =>l_ADDRESS_LINE2
      ,p_CITY                       =>l_CITY
      ,p_PHONE                      =>l_PHONE
      ,p_FAX                        =>l_FAX
      ,p_EMAIL                      =>l_EMAIL
      ,p_PAGER                      =>l_PAGER
      ,p_PAGER_PIN                  =>l_PAGER_PIN
      ,p_INTERNET_ADDRESS           =>l_INTERNET_ADDRESS
      ,p_ZIP_CODE                   =>l_ZIP_CODE
      ,p_COUNTRY                    =>l_COUNTRY
      ,p_CUSTOMER_CONTACT_REQ_FLAG  =>l_CUSTOMER_CONTACT_REQ_FLAG
      ,p_CONTACT_NAME               =>l_CONTACT_NAME
      ,p_RETAIN_TN_FLAG             =>l_RETAIN_TN_FLAG
      ,p_RETAIN_DIR_INFO_FLAG       =>l_RETAIN_DIR_INFO_FLAG
      ,p_CNAM_ADDRESS               =>l_CNAM_ADDRESS
      ,p_CNAM_SUBSYSTEM             =>l_CNAM_SUBSYSTEM
      ,p_ISVM_ADDRESS               =>l_ISVM_ADDRESS
      ,p_ISVM_SUBSYSTEM             =>l_ISVM_SUBSYSTEM
      ,p_LIDB_ADDRESS               =>l_LIDB_ADDRESS
      ,p_LIDB_SUBSYSTEM             =>l_LIDB_SUBSYSTEM
      ,p_CLASS_ADDRESS              =>l_CLASS_ADDRESS
      ,p_CLASS_SUBSYSTEM            =>l_CLASS_SUBSYSTEM
      ,p_WSMSC_ADDRESS              =>l_WSMSC_ADDRESS
      ,p_WSMSC_SUBSYSTEM            =>l_WSMSC_SUBSYSTEM
      ,p_RN_ADDRESS                 =>l_RN_ADDRESS
      ,p_RN_SUBSYSTEM               =>l_RN_SUBSYSTEM
      ,p_PREORDER_AUTHORIZATION_CODE=>l_PREORDER_AUTHORIZATION_CODE
      ,p_ACTIVATION_DUE_DATE        =>XNP_UTILS.CANONICAL_TO_DATE(l_ACTIVATION_DUE_DATE)
      ,p_ORDER_PRIORITY             =>l_ORDER_PRIORITY
      ,p_SUBSEQUENT_PORT_FLAG       => l_SUBSEQUENT_PORT_FLAG
      ,p_COMMENTS                   => l_COMMENTS
      ,p_NOTES                      => l_NOTES
      ,p_ORDER_ID                   => p_ORDER_ID
      ,p_LINEITEM_ID                => p_LINEITEM_ID
      ,p_WORKITEM_INSTANCE_ID       => p_WORKITEM_INSTANCE_ID
      ,p_FA_INSTANCE_ID             => p_FA_INSTANCE_ID
      ,x_ERROR_CODE                 =>x_ERROR_CODE
      ,x_ERROR_MESSAGE              =>x_ERROR_MESSAGE
      );
      --} end create porting order for recipient
     ELSE -- NRC OR NRC_WITHOUT_VALIDATION  and not a RECIPIENT
      --{ create porting order for NRC

      IF p_SP_ROLE = 'NRC_WITHOUT_VALIDATION'  THEN
         l_validation_flag := 'N';
      END IF;


      XNP_CORE.SOA_CREATE_NRC_PORT_ORDER
      (p_PORTING_ID                 =>l_PORTING_ID
      ,p_STARTING_NUMBER            =>to_number(l_STARTING_NUMBER)
      ,p_ENDING_NUMBER              =>to_number(l_ENDING_NUMBER)
      ,p_SUBSCRIPTION_TYPE          =>l_SUBSCRIPTION_TYPE
      ,p_DONOR_SP_ID                =>l_DONOR_SP_ID
      ,p_RECIPIENT_SP_ID            =>l_RECIPIENT_SP_ID
      ,p_ROUTING_NUMBER             =>l_ROUTING_NUMBER
      ,p_NEW_SP_DUE_DATE            =>XNP_UTILS.CANONICAL_TO_DATE(l_SP_DUE_DATE)
      ,p_OLD_SP_CUTOFF_DUE_DATE     =>XNP_UTILS.CANONICAL_TO_DATE(l_OLD_SP_CUTOFF_DUE_DATE)
      ,p_CUSTOMER_ID                =>l_CUSTOMER_ID
      ,p_CUSTOMER_NAME              =>l_CUSTOMER_NAME
      ,p_CUSTOMER_TYPE              =>l_CUSTOMER_TYPE
      ,p_ADDRESS_LINE1              =>l_ADDRESS_LINE1
      ,p_ADDRESS_LINE2              =>l_ADDRESS_LINE2
      ,p_CITY                       =>l_CITY
      ,p_PHONE                      =>l_PHONE
      ,p_FAX                        =>l_FAX
      ,p_EMAIL                      =>l_EMAIL
      ,p_PAGER                      =>l_PAGER
      ,p_PAGER_PIN                  =>l_PAGER_PIN
      ,p_INTERNET_ADDRESS           =>l_INTERNET_ADDRESS
      ,p_ZIP_CODE                   =>l_ZIP_CODE
      ,p_COUNTRY                    =>l_COUNTRY
      ,p_CUSTOMER_CONTACT_REQ_FLAG  =>l_CUSTOMER_CONTACT_REQ_FLAG
      ,p_CONTACT_NAME               =>l_CONTACT_NAME
      ,p_RETAIN_TN_FLAG             =>l_RETAIN_TN_FLAG
      ,p_RETAIN_DIR_INFO_FLAG       =>l_RETAIN_DIR_INFO_FLAG
      ,p_CNAM_ADDRESS               =>l_CNAM_ADDRESS
      ,p_CNAM_SUBSYSTEM             =>l_CNAM_SUBSYSTEM
      ,p_ISVM_ADDRESS               =>l_ISVM_ADDRESS
      ,p_ISVM_SUBSYSTEM             =>l_ISVM_SUBSYSTEM
      ,p_LIDB_ADDRESS               =>l_LIDB_ADDRESS
      ,p_LIDB_SUBSYSTEM             =>l_LIDB_SUBSYSTEM
      ,p_CLASS_ADDRESS              =>l_CLASS_ADDRESS
      ,p_CLASS_SUBSYSTEM            =>l_CLASS_SUBSYSTEM
      ,p_WSMSC_ADDRESS              =>l_WSMSC_ADDRESS
      ,p_WSMSC_SUBSYSTEM            =>l_WSMSC_SUBSYSTEM
      ,p_RN_ADDRESS                 =>l_RN_ADDRESS
      ,p_RN_SUBSYSTEM               =>l_RN_SUBSYSTEM
      ,p_PREORDER_AUTHORIZATION_CODE=>l_PREORDER_AUTHORIZATION_CODE
      ,p_ACTIVATION_DUE_DATE        =>XNP_UTILS.CANONICAL_TO_DATE(l_ACTIVATION_DUE_DATE)
      ,p_ORDER_PRIORITY             =>l_ORDER_PRIORITY
      ,p_SUBSEQUENT_PORT_FLAG       => l_SUBSEQUENT_PORT_FLAG
      ,p_COMMENTS                   => l_COMMENTS
      ,p_NOTES                      => l_NOTES
      ,p_ORDER_ID                   => p_ORDER_ID
      ,p_LINEITEM_ID                => p_LINEITEM_ID
      ,p_WORKITEM_INSTANCE_ID       => p_WORKITEM_INSTANCE_ID
      ,p_FA_INSTANCE_ID             => p_FA_INSTANCE_ID
      ,p_VALIDATION_FLAG            => l_VALIDATION_FLAG
      ,x_ERROR_CODE                 =>x_ERROR_CODE
      ,x_ERROR_MESSAGE              =>x_ERROR_MESSAGE
      );
      --} end create porting order for NRC
     END IF;
  --}
  ELSE --{ if DONOR
  -- create porting order from DONOR
    XNP_CORE.SOA_CREATE_DON_PORT_ORDER
      (p_PORTING_ID              =>l_PORTING_ID
      ,p_STARTING_NUMBER         =>to_number(l_STARTING_NUMBER)
      ,p_ENDING_NUMBER           =>to_number(l_ENDING_NUMBER)
      ,p_SUBSCRIPTION_TYPE       =>l_SUBSCRIPTION_TYPE
      ,p_DONOR_SP_ID             =>l_DONOR_SP_ID
      ,p_RECIPIENT_SP_ID         =>l_RECIPIENT_SP_ID
      ,p_ROUTING_NUMBER          =>l_ROUTING_NUMBER
      ,p_NEW_SP_DUE_DATE         =>XNP_UTILS.CANONICAL_TO_DATE(l_SP_DUE_DATE)
      ,p_OLD_SP_CUTOFF_DUE_DATE  =>XNP_UTILS.CANONICAL_TO_DATE(l_OLD_SP_CUTOFF_DUE_DATE)
      ,p_CUSTOMER_ID             =>l_CUSTOMER_ID
      ,p_CUSTOMER_NAME           =>l_CUSTOMER_NAME
      ,p_CUSTOMER_TYPE           =>l_CUSTOMER_TYPE
      ,p_ADDRESS_LINE1           =>l_ADDRESS_LINE1
      ,p_ADDRESS_LINE2           =>l_ADDRESS_LINE2
      ,p_CITY                    =>l_CITY
      ,p_PHONE                   =>l_PHONE
      ,p_FAX                     =>l_FAX
      ,p_EMAIL                   =>l_EMAIL
      ,p_PAGER                   =>l_PAGER
      ,p_PAGER_PIN               =>l_PAGER_PIN
      ,p_INTERNET_ADDRESS        =>l_INTERNET_ADDRESS
      ,p_ZIP_CODE                =>l_ZIP_CODE
      ,p_COUNTRY                 =>l_COUNTRY
      ,p_CUSTOMER_CONTACT_REQ_FLAG=>l_CUSTOMER_CONTACT_REQ_FLAG
      ,p_CONTACT_NAME            =>l_CONTACT_NAME
      ,p_RETAIN_TN_FLAG          =>l_RETAIN_TN_FLAG
      ,p_RETAIN_DIR_INFO_FLAG    =>l_RETAIN_DIR_INFO_FLAG
      ,p_CNAM_ADDRESS            =>l_CNAM_ADDRESS
      ,p_CNAM_SUBSYSTEM          =>l_CNAM_SUBSYSTEM
      ,p_ISVM_ADDRESS            =>l_ISVM_ADDRESS
      ,p_ISVM_SUBSYSTEM          =>l_ISVM_SUBSYSTEM
      ,p_LIDB_ADDRESS            =>l_LIDB_ADDRESS
      ,p_LIDB_SUBSYSTEM          =>l_LIDB_SUBSYSTEM
      ,p_CLASS_ADDRESS           =>l_CLASS_ADDRESS
      ,p_CLASS_SUBSYSTEM         =>l_CLASS_SUBSYSTEM
      ,p_WSMSC_ADDRESS           =>l_WSMSC_ADDRESS
      ,p_WSMSC_SUBSYSTEM         =>l_WSMSC_SUBSYSTEM
      ,p_RN_ADDRESS              =>l_RN_ADDRESS
      ,p_RN_SUBSYSTEM            =>l_RN_SUBSYSTEM
      ,p_PREORDER_AUTHORIZATION_CODE=>l_PREORDER_AUTHORIZATION_CODE
      ,p_ACTIVATION_DUE_DATE     =>XNP_UTILS.CANONICAL_TO_DATE(l_ACTIVATION_DUE_DATE)
      ,p_ORDER_PRIORITY             =>l_ORDER_PRIORITY
      ,p_SUBSEQUENT_PORT_FLAG    => l_SUBSEQUENT_PORT_FLAG
      ,p_COMMENTS                => l_COMMENTS
      ,p_NOTES                   => l_NOTES
      ,p_ORDER_ID                => p_ORDER_ID
      ,p_LINEITEM_ID             => p_LINEITEM_ID
      ,p_WORKITEM_INSTANCE_ID    => p_WORKITEM_INSTANCE_ID
      ,p_FA_INSTANCE_ID          => p_FA_INSTANCE_ID
      ,x_ERROR_CODE              =>x_ERROR_CODE
      ,x_ERROR_MESSAGE           =>x_ERROR_MESSAGE
      );
  --} create porting order from DONOR
  END IF;

  EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.SOA_CREATE_PORTING_ORDER');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END SOA_CREATE_PORTING_ORDER;

 --------------------------------------------------------------------
 -- Called by:Donor's XNP_WF_STANDARD.SOA_CHECK_NOTIFY_DIR_SVS
 -- Description: Gets the WI param PORTING_ID and calls
 -- XNP_CORE.SOA_CHECK_NOTIFY_DIR_SVS
 -- Returns: 'Y' if true
 ------------------------------------------------------------------
PROCEDURE SOA_CHECK_NOTIFY_DIR_SVS
 (
 p_WORKITEM_INSTANCE_ID IN NUMBER
 ,x_CHECK_STATUS        OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE          OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 )
IS
 l_porting_id      VARCHAR2(40) := null;
 l_RETAIN_DIR_INFO VARCHAR2(1);
 l_sp_name         VARCHAR2(80) := null;
 l_local_sp_id     NUMBER := 0;

BEGIN
  x_error_code := 0;

  -- Get the porting id and check the corr.
  l_porting_id :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PORTING_ID'
   );


  l_SP_NAME :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'SP_NAME'
   );

  XNP_CORE.SOA_CHECK_NOTIFY_DIR_SVS
    (p_porting_id   =>l_PORTING_ID
    ,p_local_sp_id  =>l_local_sp_id
    ,x_check_status =>x_CHECK_STATUS
    ,x_error_code   =>x_ERROR_CODE
    ,x_error_message=>x_ERROR_MESSAGE
    );
  EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.SOA_CHECK_NOTIFY_DIR_SVS');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END SOA_CHECK_NOTIFY_DIR_SVS;


 --------------------------------------------------------------------
 -- Called at: donor sp when need to check if its the
 -- initial donor
 -- Called by:Donor XNP_WF_STANDARD.DETERMINE_SP_ROLE
 -- Description:
 -- Extracts the (LOCAL)SP_NAME and compares it to donor,
 -- recipient. If either of them don't match checks
 -- if its INITIAL DONOR.
 -- The foll. WI params are referenced STARTING_NUMBER,
 -- ENDING_NUMBER, DONOR_SP_ID, SP_NAME, RECIPIENT_SP_ID
 -- Returns: DONOR, ORIG_DONOR, RECIPIENT
 ------------------------------------------------------------------
PROCEDURE DETERMINE_SP_ROLE
 (p_WORKITEM_INSTANCE_ID IN NUMBER
 ,x_SP_ROLE              OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE           OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 )
IS
 l_starting_number  VARCHAR2(20);
 l_ending_number    VARCHAR2(20);
 l_donor_sp_id      VARCHAR2(20);
 l_recipient_sp_id  VARCHAR2(20);
 l_SERVING_SP_ID    NUMBER;
 l_CHECK_STATUS     VARCHAR2(1) := 'Y';
 l_SP_NAME          VARCHAR2(40) := NULL;

BEGIN

  x_error_code := 0;


  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  l_donor_sp_id :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'DONOR_SP_ID'
   );

  l_recipient_sp_id :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'RECIPIENT_SP_ID'
   );

  l_SP_NAME :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'SP_NAME'
   );

  IF l_donor_sp_id = l_SP_NAME  THEN
    x_SP_ROLE := 'DONOR';
    RETURN;
  ELSIF l_recipient_sp_id = l_SP_NAME  THEN
    x_SP_ROLE := 'RECIPIENT';
    RETURN;
  ELSE
    XNP_CORE.SOA_CHECK_IF_INITIAL_DONOR
     (p_DONOR_SP_ID     =>l_DONOR_SP_ID
     ,p_STARTING_NUMBER =>l_STARTING_NUMBER
     ,p_ENDING_NUMBER   =>l_ENDING_NUMBER
     ,x_CHECK_STATUS    =>l_CHECK_STATUS
     ,x_ERROR_CODE      =>x_ERROR_CODE
     ,x_ERROR_MESSAGE   =>x_ERROR_MESSAGE
     );
  END IF;

  IF l_CHECK_STATUS = 'Y'  THEN
    x_SP_ROLE := 'ORIG_DONOR';
  ELSE
    x_SP_ROLE := 'OTHER';
  END IF;

  EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.DETERMINE_SP_ROLE');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END DETERMINE_SP_ROLE;


 ------------------------------------------------------------------
 -- Procedure used to update the status of a SV in
 -- XNP_SV_SOA to the given status
 -- Using the WORKITEM_INSTANCE_ID the starting and ending TN
 -- is found to derive the SV
 -- The foll WI params are checked STARTING_NUMBER,
 -- ENDING_NUMBER, PORTING_ID
 ------------------------------------------------------------------
PROCEDURE SOA_UPDATE_SV_STATUS
 ( p_ORDER_ID               IN  NUMBER,
   p_LINEITEM_ID            IN  NUMBER,
   p_WORKITEM_INSTANCE_ID   IN  NUMBER,
   p_FA_INSTANCE_ID         IN  NUMBER,
   p_CUR_STATUS_TYPE_CODE       VARCHAR2,
   p_NEW_STATUS_TYPE_CODE       VARCHAR2,
   p_STATUS_CHANGE_CAUSE_CODE   VARCHAR2,
   x_ERROR_CODE             OUT NOCOPY NUMBER,
   x_ERROR_MESSAGE          OUT NOCOPY VARCHAR2
 )

IS
l_starting_number     VARCHAR2(20);
l_ending_number       VARCHAR2(20);
l_LOCAL_SP_ID         NUMBER := 0;
l_SP_NAME             VARCHAR2(40) := NULL;
l_PHASE               VARCHAR2(40) := NULL;
l_NEW_PHASE_INDICATOR VARCHAR2(40) := NULL;

BEGIN

  x_error_code := 0;

  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ENDING_NUMBER :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  l_SP_NAME :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'SP_NAME'
   );

  -- Get the phase of new status being set
  XNP_CORE.GET_PHASE_FOR_STATUS
   (p_CUR_STATUS_TYPE_CODE =>p_NEW_STATUS_TYPE_CODE
   ,x_PHASE_INDICATOR      =>l_NEW_PHASE_INDICATOR
   ,x_ERROR_CODE           =>x_ERROR_CODE
   ,x_ERROR_MESSAGE        =>x_ERROR_MESSAGE
   );
  IF x_ERROR_CODE <> 0  THEN
   RETURN;
  END IF;

   ------------------------------------------------------------------
   -- If the new status is 'ACTIVE' (for example)
   -- Ensure that no other SV exists in Active state
   ------------------------------------------------------------------
  IF l_NEW_PHASE_INDICATOR = 'ACTIVE'  THEN

   XNP_CORE.SOA_RESET_SV_STATUS
   (p_STARTING_NUMBER          => l_starting_number
   ,p_ENDING_NUMBER            => l_ending_number
   ,p_LOCAL_SP_ID              => l_LOCAL_SP_ID
   ,p_CUR_PHASE_INDICATOR      => l_NEW_PHASE_INDICATOR
   ,p_RESET_PHASE_INDICATOR    => 'OLD'
   ,p_OMIT_STATUS              => p_CUR_STATUS_TYPE_CODE
   ,P_STATUS_CHANGE_CAUSE_CODE => 'Reset to OLD'
   ,p_ORDER_ID                 => p_ORDER_ID
   ,p_LINEITEM_ID              => p_LINEITEM_ID
   ,p_WORKITEM_INSTANCE_ID     => p_WORKITEM_INSTANCE_ID
   ,p_FA_INSTANCE_ID           => p_FA_INSTANCE_ID
   ,X_ERROR_CODE               => x_ERROR_CODE
   ,X_ERROR_MESSAGE            => x_ERROR_MESSAGE
   );
  END IF;

  -- call updation procedure to update the status

  XNP_CORE.SOA_UPDATE_SV_STATUS
   (p_STARTING_NUMBER          => l_starting_number
   ,p_ENDING_NUMBER            => l_ending_number
   ,p_CUR_STATUS_TYPE_CODE     => p_cur_status_type_code
   ,p_LOCAL_SP_ID              => l_LOCAL_SP_ID
   ,P_NEW_STATUS_TYPE_CODE     => p_new_status_type_code
   ,P_STATUS_CHANGE_CAUSE_CODE => p_status_change_cause_code
   ,p_ORDER_ID                 => p_ORDER_ID
   ,p_LINEITEM_ID              => p_LINEITEM_ID
   ,p_WORKITEM_INSTANCE_ID     => p_WORKITEM_INSTANCE_ID
   ,p_FA_INSTANCE_ID           => p_FA_INSTANCE_ID
   ,X_ERROR_CODE               => x_ERROR_CODE
   ,X_ERROR_MESSAGE            => x_ERROR_MESSAGE
   );

  EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.SOA_UPDATE_SV_STATUS');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END SOA_UPDATE_SV_STATUS;

 --------------------------------------------------------------------
 -- Descrition:
 -- Updates SVs in SOA table for the Porting Id
 -- with the invoice infomation
 -- Mandatory Parameters: PORTING_ID,STARTING_NUMBER ENDING_NUMBER, SP_NAME
 -- Optional Parameters: INVOICE_DUE_DATE, CHARGING_INFO, BILLING_ID,
 -- USER_LOCTN_VALUE, USER_LOCTN_TYPE
 --
 ------------------------------------------------------------------
PROCEDURE SOA_UPDATE_CHARGING_INFO
 ( p_ORDER_ID               IN  NUMBER,
   p_LINEITEM_ID            IN  NUMBER,
   p_WORKITEM_INSTANCE_ID   IN  NUMBER,
   p_FA_INSTANCE_ID         IN  NUMBER,
   p_CUR_STATUS_TYPE_CODE       VARCHAR2,
   x_ERROR_CODE             OUT NOCOPY NUMBER,
   x_ERROR_MESSAGE          OUT NOCOPY VARCHAR2
 )
IS
l_PORTING_ID       VARCHAR2(80) := null;
l_STARTING_NUMBER  VARCHAR2(20);
l_ENDING_NUMBER    VARCHAR2(20);
l_INVOICE_DUE_DATE VARCHAR2(20);
l_CHARGING_INFO    VARCHAR2(200);
l_LOCAL_SP_ID      NUMBER := 0;
l_SP_NAME          VARCHAR2(40) := NULL;
l_BILLING_ID       NUMBER := 0;
l_USER_LOCTN_VALUE VARCHAR2(80) := NULL;
l_USER_LOCTN_TYPE  VARCHAR2(40) := NULL;
l_PRICE_CODE       VARCHAR2(40);
l_PRICE_PER_CALL   VARCHAR2(40);
l_PRICE_PER_MINUTE VARCHAR2(40);

BEGIN

  x_error_code := 0;

  l_porting_id :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PORTING_ID'
   );

  l_invoice_due_date :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'INVOICE_DUE_DATE'
   );

  l_charging_info :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CHARGING_INFO'
   );

  l_BILLING_ID :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'BILLING_ID'
   );

  l_USER_LOCTN_VALUE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'USER_LOCTN_VALUE'
   );

  l_USER_LOCTN_TYPE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'USER_LOCTN_TYPE'
   );

  l_PRICE_CODE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PRICE_CODE'
   );

  l_PRICE_PER_CALL :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PRICE_PER_CALL'
   );

  l_PRICE_PER_MINUTE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PRICE_PER_MINUTE'
   );

  l_SP_NAME :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'SP_NAME'
   );

  -- call updation procedure to update the charging info

    XNP_CORE.SOA_UPDATE_CHARGING_INFO
     (p_porting_id           =>l_porting_id
     ,p_LOCAL_SP_ID          =>l_LOCAL_SP_ID
     ,p_INVOICE_DUE_DATE     =>XNP_UTILS.CANONICAL_TO_DATE(l_invoice_due_date)
     ,p_CHARGING_INFO        =>l_charging_info
     ,p_BILLING_ID           =>l_BILLING_ID
     ,p_USER_LOCTN_VALUE     =>l_USER_LOCTN_VALUE
     ,p_USER_LOCTN_TYPE      =>l_USER_LOCTN_TYPE
     ,p_PRICE_CODE           =>l_PRICE_CODE
     ,p_PRICE_PER_CALL       =>l_PRICE_PER_CALL
     ,p_PRICE_PER_MINUTE     =>l_PRICE_PER_MINUTE
     ,p_ORDER_ID             =>p_ORDER_ID
     ,p_LINEITEM_ID          =>p_LINEITEM_ID
     ,p_WORKITEM_INSTANCE_ID =>p_WORKITEM_INSTANCE_ID
     ,p_FA_INSTANCE_ID       =>p_FA_INSTANCE_ID
     ,x_ERROR_CODE           =>x_ERROR_CODE
     ,x_ERROR_MESSAGE        =>x_ERROR_MESSAGE
     );

   EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.SOA_UPDATE_CHARGING_INFO');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END SOA_UPDATE_CHARGING_INFO;

 --------------------------------------------------------------------
 --
 -- Called when: Inquiry or Order response is awaited
 -- Description:
 --  Gets the TN range and calls
 --    and calls XNP_CORE.SOA_CHECK_ORDER_STATUS
 -- References the following WI parameter
 --  ORDER_STATUS
 ------------------------------------------------------------------
PROCEDURE SOA_CHECK_ORDER_STATUS
 (p_WORKITEM_INSTANCE_ID IN NUMBER
 ,x_ORDER_STATUS         OUT NOCOPY VARCHAR2
 ,x_error_code           OUT NOCOPY NUMBER
 ,x_error_message        OUT NOCOPY VARCHAR2
 )
IS

BEGIN
   x_error_code := 0;

   -- Get the starting and ending TN for this workitem
  x_ORDER_STATUS :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ORDER_RESULT'
   );

   EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.SOA_CHECK_ORDER_STATUS');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END SOA_CHECK_ORDER_STATUS;

 --------------------------------------------------------------------
 -- Checks if the records in the given status
 --  and returns 'Y' if true
 --
 ------------------------------------------------------------------
PROCEDURE CHECK_SOA_STATUS_EXISTS
 (p_WORKITEM_INSTANCE_ID   NUMBER
 ,p_STATUS_TYPE_CODE       VARCHAR2
 ,x_CHECK_STATUS       OUT NOCOPY VARCHAR2
 ,x_error_code         OUT NOCOPY NUMBER
 ,x_error_message      OUT NOCOPY VARCHAR2
 )
IS
 l_starting_number VARCHAR2(20);
 l_ending_number   VARCHAR2(20);
 l_donor_sp_id     VARCHAR2(20);
 l_SERVING_SP_ID   NUMBER;
 l_LOCAL_SP_ID     NUMBER := 0;
 l_SP_NAME         VARCHAR2(40) := NULL;

BEGIN

  x_error_code := 0;


  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  l_SP_NAME :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'SP_NAME'
   );

  XNP_CORE.CHECK_SOA_STATUS_EXISTS
   (l_STARTING_NUMBER
   ,l_ENDING_NUMBER
   ,p_STATUS_TYPE_CODE
   ,l_LOCAL_SP_ID
   ,x_CHECK_STATUS
   ,x_ERROR_CODE
   ,x_ERROR_MESSAGE
   );

  EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.CHECK_SOA_STATUS_EXISTS');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END CHECK_SOA_STATUS_EXISTS;

 --------------------------------------------------------------------
 -- Sets the ORDER_RESULT work item
 -- parameter value to give one
 ------------------------------------------------------------------
PROCEDURE SET_ORDER_RESULT
 (p_WORKITEM_INSTANCE_ID NUMBER
 ,p_ORDER_RESULT         VARCHAR2
 ,p_ORDER_REJECT_CODE    VARCHAR2
 ,p_ORDER_REJECT_EXPLN   VARCHAR2
 ,x_error_code       OUT NOCOPY NUMBER
 ,x_error_message    OUT NOCOPY VARCHAR2
 )

IS

BEGIN

  x_error_code := 0;

   IF p_ORDER_RESULT = 'SUCCESS'  THEN

    -- Set the order result to 'Y'
    XNP_STANDARD.SET_WORKITEM_PARAM_VALUE
    (p_WORKITEM_INSTANCE_ID
    ,'ORDER_RESULT'
    ,'Y'
    ,NULL
    );

    XNP_STANDARD.SET_WORKITEM_PARAM_VALUE
     (p_WORKITEM_INSTANCE_ID
     ,'ORDER_REJECT_CODE'
     ,'SUCCESS'
     ,NULL
     );

    XNP_STANDARD.SET_WORKITEM_PARAM_VALUE
     (p_WORKITEM_INSTANCE_ID
     ,'ORDER_REJECT_EXPLN'
     ,'SUCCESS'
     ,NULL
     );

   ELSE

    -- Set the order result to 'N'
    XNP_STANDARD.SET_WORKITEM_PARAM_VALUE
    (p_WORKITEM_INSTANCE_ID
    ,'ORDER_RESULT'
    ,'N'
    ,NULL
    );

    XNP_STANDARD.SET_WORKITEM_PARAM_VALUE
     (p_WORKITEM_INSTANCE_ID
     ,'ORDER_REJECT_CODE'
     ,'FAILURE'
     ,NULL
     );

    XNP_STANDARD.SET_WORKITEM_PARAM_VALUE
     (p_WORKITEM_INSTANCE_ID
     ,'ORDER_REJECT_EXPLN'
     ,'FAILURE'
     ,NULL
     );

   END IF;

  EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.SET_ORDER_RESULT');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END SET_ORDER_RESULT;

 ------------------------------------------------------------------
 -- Called to publish a single business event
 -- The recipients of this event should have
 -- already subscribed for it incase of
 -- internal events
 --
 -- Note:
 --  EVENT TYPE: The message/event type to send
 -- PARAM LIST: gives names of the
 -- workitem parameters which contain the values.
 -- E.g. of format could be
 -- S=$STARTING_NUMBER,E=$ENDING_NUMBER
 --
 -- CALLBACK_REF_ID: Gives the callback handle.
 --
 ------------------------------------------------------------------
PROCEDURE PUBLISH_EVENT
 (p_ORDER_ID             NUMBER
 ,p_WORKITEM_INSTANCE_ID NUMBER
 ,p_FA_INSTANCE_ID       NUMBER
 ,p_EVENT_TYPE           VARCHAR2
 ,p_PARAM_LIST           VARCHAR2
 ,p_CALLBACK_REF_ID      VARCHAR2
 ,x_error_code       OUT NOCOPY NUMBER
 ,x_error_message    OUT NOCOPY VARCHAR2
 )
IS
 l_start_posn            NUMBER := 0;
 l_end_posn              NUMBER := 0;
 l_name                  VARCHAR2(256) := NULL;
 l_value                 VARCHAR2(256) := NULL;
 l_invocation_param_list VARCHAR2(1024) := NULL;
 l_temp                  VARCHAR2(1024);
 l_wf_value              VARCHAR2(1024);
 l_message_id            NUMBER := 0;
 l_recipient_list        VARCHAR2(2000) := NULL;
 l_consumer_list         VARCHAR2(4000) := NULL;
 l_version               NUMBER := 1;
 -- l_sender_name           VARCHAR2(40) := NULL;
 l_sender_name           VARCHAR2(300) := NULL;    -- increased the size from 40 to 300 for 6880763

--
-- The following line is added by Anping Wang, See comments below for
-- Details. 12/02/2000
--
 l_opp_reference   VARCHAR2(1024) := NULL;
--
 l_callback_reference VARCHAR2(1024) := NULL;

 l_CURSOR    NUMBER := 0;
 l_PROC_CALL VARCHAR2(2000) := NULL;
 l_NUM_ROWS  NUMBER := 0;
--
-- pre and suffixes with predefined strings
-- By Anping Wang, bug refer. 1650015
-- 02/19/2001
 l_pkg_name VARCHAR2(2000);

BEGIN

  x_error_code := 0;

  l_callback_reference := p_callback_ref_id;

  IF p_PARAM_LIST IS NOT NULL THEN

     ------------------------------------------------------------------
     -- Parse and retrieve the attribute to
     -- retrieve from Parameters
     -- Rule: The paramters are stored as
     -- name value pairs in the foll. format
     -- NAME1=$VALUE1,NAME2=$VALUE2,...
     -- Each VALUE referes to the corresponding
     -- workitem parameter name
     ------------------------------------------------------------------
    LOOP
      l_start_posn := l_end_posn+1;
      l_end_posn :=
       INSTR(p_PARAM_LIST, '=$',l_start_posn,1);

      l_name :=
        SUBSTR
         (p_PARAM_LIST
         , l_start_posn
         , (l_end_posn - l_start_posn));

      l_start_posn := l_end_posn+1;

      l_start_posn := l_start_posn+1; -- next to the '$'

      l_end_posn :=
       INSTR(p_PARAM_LIST, ',', l_start_posn, 1);
      IF l_end_posn <= l_start_posn
      THEN
        l_end_posn := LENGTH(p_PARAM_LIST)+1;
      END IF;

      l_value :=
        SUBSTR
         (p_PARAM_LIST
         ,l_start_posn
         ,(l_end_posn - l_start_posn)
         );

       -- Get the value from the WI Parameters
       l_wf_value :=
         XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
          (p_WORKITEM_INSTANCE_ID
          ,l_value
          );

       -- Append the NV pair to the message param list
      IF l_invocation_param_list IS NULL
      THEN
        l_temp := '''' || l_wf_value || '''';
      ELSE
        l_temp := ','|| '''' || l_wf_value || '''';
      END IF;

      -- Concatenate the paramter list
      l_invocation_param_list :=
        CONCAT(l_invocation_param_list,l_temp);

      EXIT WHEN l_end_posn >= LENGTH(p_PARAM_LIST);
    END LOOP;
  END IF; -- param list is not null

  -- Get the SENDER NAME
  l_sender_name :=
         XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
          (p_WORKITEM_INSTANCE_ID
          ,'SP_NAME'
          );


-- The following block was commented out by Anping Wang. Replaced with a new block
-- followed. The order of argument list was not consistent with the prototype used
-- to generate the publish procedure by iMessage studio.
--	12/06/2000
-- Construct the dynamic SQL

-- pre and suffixes with predefined strings
-- By Anping Wang, bug refer. 1650015
-- 02/19/2001
	l_pkg_name := XNP_MESSAGE.g_pkg_prefix || p_event_type || XNP_MESSAGE.g_pkg_suffix ;

  IF l_invocation_param_list IS NOT NULL
  THEN
    l_PROC_CALL :=
    'BEGIN
     '||l_pkg_name||'.PUBLISH(' ||
       l_invocation_param_list ||   '
        ,:l_message_id
        ,:x_error_code
        ,:x_error_message
        ,:l_consumer_list
        ,:l_sender_name
        ,:l_recipient_list
        ,:l_version
        ,:l_callback_reference
        ,:l_opp_reference_id
        ,:p_order_id
		,:p_workitem_instance_id
        ,:p_fa_instance_id
       );
     END;';
   ELSE

    -- Construct the dynamic SQL
    l_PROC_CALL :=
    'BEGIN
     '||l_pkg_name||'.PUBLISH(' ||  '
        :l_message_id
       ,:x_error_code
       ,:x_error_message
       ,:l_consumer_list
       ,:l_sender_name
       ,:l_recipient_list
       ,:l_version
       ,:l_callback_reference
       ,:l_opp_reference_id
       ,:p_order_id
	   ,:p_workitem_instance_id
       ,:p_fa_instance_id
       );
     END;';
   END IF; -- invocation param list is null

  BEGIN

    EXECUTE IMMEDIATE l_proc_call USING
	 OUT l_message_id
	,OUT x_error_code
	,OUT x_error_message
	,IN l_consumer_list
	,IN l_sender_name
	,IN l_recipient_list
	,IN l_version
	,IN l_callback_reference
	,IN l_opp_reference
	,IN p_order_id
	,IN p_workitem_instance_id
	,IN p_fa_instance_id;

EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN'
          ,'XNP_STANDARD.PUBLISH_EVENT');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;
  END;

END PUBLISH_EVENT;


 ------------------------------------------------------------------
 -- Sends a message to a single recipient. The message is
 -- sent to external recipients or internal ones based on
 -- the type of the message and queue name
 -- Parameters:
 --  ORDER ID: order id of this SFM order
 --  EVENT TYPE: The message/event type to send
 --  PARAM LIST: gives names of the
 --  workitem parameters which contain the values.
 --  E.g. of format could be
 --  S=$STARTING_NUMBER,E=$ENDING_NUMBER
 --  WORKITEM INSTANCE ID:gives the handle to fetch
 --  the values.
 --  CONSUMER: gives the procedure to get the fe name
 --  or adapter name) of the receiver
 --  CALLBACK_REF_ID: Gives the callback handle.
 --  RECEIVER: gives the procedure to get the recipient name
 --  VERSION: Version number of the message
 --  Mandatory Workitem parameters: Whatever parameter mentioned
 --  in the 'PARAM LIST' and additional workitem parameter which
 --  are configured as part of the message type definition.
 --
 ------------------------------------------------------------------
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
 )
IS
 l_start_posn            NUMBER := 0;
 l_end_posn              NUMBER := 0;
 l_name                  VARCHAR2(256) := NULL;
 l_value                 VARCHAR2(256) := NULL;
 l_invocation_param_list VARCHAR2(1024) := NULL;
 l_temp                  VARCHAR2(1024);
 l_wf_value              VARCHAR2(1024);
 l_message_id            NUMBER := 0;

 l_FE_NAME               VARCHAR2(40) := NULL; -- adapter name

 l_CURSOR                NUMBER := 0;
 l_PROC_CALL             VARCHAR2(2000) := NULL;
 l_NUM_ROWS              NUMBER := 0;

 l_CONSUMER_NAME         VARCHAR2(40) := NULL;
 l_CONSUMER_CURSOR       NUMBER := 0;
 l_CONSUMER_PROC_CALL    VARCHAR2(2000) := NULL;
 l_CONSUMER_NUM_ROWS     NUMBER := 0;

 l_RECIPIENT_NAME        VARCHAR2(40) := NULL; -- recipient name
 l_RECIPIENT_CURSOR      NUMBER := 0;
 l_RECIPIENT_PROC_CALL   VARCHAR2(2000) := NULL;
 l_RECIPIENT_NUM_ROWS    NUMBER := 0;

 -- l_sender_name           VARCHAR2(40) := NULL;
 l_sender_name           VARCHAR2(300) := NULL;   -- increased the size from 40 to 300 for 6880763
 l_OPP_REFERENCE_ID      VARCHAR2(240);
 l_pkg_name              VARCHAR2(2000);

BEGIN
  x_error_code := 0;

   ------------------------------------------------------------------
   -- Get the consumer name (ie. adpater name) and
   --  recipient name before proceeding to call SEND
   ------------------------------------------------------------------
  -- Get the consumer name

  -- Construct the dynamic SQL
  l_CONSUMER_PROC_CALL :=
    'BEGIN
     '||p_CONSUMER||'(' ||  '
        :p_ORDER_ID
       ,:p_WORKITEM_INSTANCE_ID
       ,:p_FA_INSTANCE_ID
       ,:l_CONSUMER_NAME
       ,:x_error_code
       ,:x_error_message);
     END;';

  BEGIN

    EXECUTE IMMEDIATE l_consumer_proc_call USING
	 IN p_order_id
	,IN p_workitem_instance_id
	,IN p_fa_instance_id
	,OUT l_consumer_name
	,OUT x_error_code
	,OUT x_error_message;

    IF x_error_code <> 0
    THEN
      fnd_message.set_name('XNP','STD_GET_FAILED');
      fnd_message.set_token
         ('FAILED_PROC','XNP_STANDARD.SEND_MESSAGE');
      fnd_message.set_token('ATTRNAME',p_CONSUMER);
      fnd_message.set_token('KEY','WORKITEM_INSTANCE_ID');
      fnd_message.set_token('VALUE',p_WORKITEM_INSTANCE_ID);
      x_error_message := fnd_message.get||':'||x_error_message;
      RETURN;
    END IF;

	-- BUG # 1500177
	-- l_consumer_proc now returns the FE_NAME (and not the ADAPTER_NAME)
	-- Get the ADAPTER_NAME for the FE_NAME

	l_fe_name := l_consumer_name;

	l_consumer_name := XDP_ADAPTER_CORE_DB.IS_MESSAGE_ADAPTER_AVAILABLE(p_fe_name => l_fe_name);

	IF l_consumer_name IS NULL
	THEN
        x_error_code := xnp_errors.g_no_adapter_for_fe;
        fnd_message.set_name('XNP','NO_ADAPTER_FOR_FE');
        fnd_message.set_token('NAME',l_fe_name );
        x_error_message := fnd_message.get;
    END IF;

    IF x_error_code <> 0
	THEN
      fnd_message.set_name('XNP','STD_GET_FAILED');
      fnd_message.set_token
         ('FAILED_PROC','XNP_STANDARD.SEND_MESSAGE');
      fnd_message.set_token('ATTRNAME',p_CONSUMER);
      fnd_message.set_token('KEY','WORKITEM_INSTANCE_ID');
      fnd_message.set_token('VALUE',p_WORKITEM_INSTANCE_ID);
      x_error_message := fnd_message.get||':'||x_error_message;
      RETURN;
	END IF;


  EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;
        fnd_message.set_name('XNP','XNP_DYNA_EXEC_FAILED');
        fnd_message.set_token
          ('FAILED_PROC','XNP_STANDARD.SEND_MESSAGE');
        fnd_message.set_token('DYNA_PROC',p_CONSUMER);
        fnd_message.set_token('KEY','WORKITEM_INSTANCE_ID');
        fnd_message.set_token('VALUE',p_WORKITEM_INSTANCE_ID);
        x_error_message :=
          fnd_message.get;
        x_error_message := x_error_message ||':'||SQLERRM;
  END;

  -- If error while getting consumer name then return
  IF x_error_code <> 0
  THEN
    -- Close the cursor
    RETURN;
  END IF;

  -- Get the recipient name

  -- Construct the dynamic SQL
  l_RECIPIENT_PROC_CALL :=
    'BEGIN
     '||p_receiver||'(' ||  '
       :p_order_id
      ,:p_workitem_instance_id
      ,:p_fa_instance_id
      ,:l_recipient_name
      ,:x_error_code
      ,:x_error_message);
     END;';


  BEGIN

    EXECUTE IMMEDIATE l_recipient_proc_call USING
	 IN p_order_id
	,IN p_workitem_instance_id
	,IN p_fa_instance_id
	,OUT l_recipient_name
	,OUT x_error_code
	,OUT x_error_message;

    IF x_error_code <> 0
    THEN
      fnd_message.set_name('XNP','STD_GET_FAILED');
      fnd_message.set_token('ATTRNAME',p_RECEIVER);
      fnd_message.set_token
         ('FAILED_PROC','XNP_STANDARD.SEND_MESSAGE');
      fnd_message.set_token('KEY','WORKITEM_INSTANCE_ID');
      fnd_message.set_token('VALUE',p_WORKITEM_INSTANCE_ID);
      x_error_message := fnd_message.get;
      x_error_message := fnd_message.get||':'||x_error_message;
      RETURN;
    END IF;


  EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','XNP_DYNA_EXEC_FAILED');
        fnd_message.set_token('DYNA_PROC',p_RECEIVER);
        fnd_message.set_token
         ('FAILED_PROC','XNP_STANDARD.SEND_MESSAGE');
        fnd_message.set_token('KEY','WORKITEM_INSTANCE_ID');
        fnd_message.set_token('VALUE',p_WORKITEM_INSTANCE_ID);
        x_error_message := fnd_message.get||':'||x_error_message;
  END;

  -- If error while getting recipient name then return
  IF x_error_code <> 0
  THEN
    RETURN;
  END IF;

     ------------------------------------------------------------------
     -- Parse and retrieve the attribute to
     -- retrieve from Parameters
     -- Rule: The paramters are stored as
     -- name value pairs in the foll. format
     -- NAME1=$VALUE1,NAME2=$VALUE2,...
     -- Each VALUE referes to the corresponding
     -- workitem parameter name
     ------------------------------------------------------------------
    l_start_posn := 0;
    l_end_posn := 0;
    l_invocation_param_list := NULL;

    IF p_PARAM_LIST IS NOT NULL
    THEN
     LOOP
      l_start_posn := l_end_posn+1;
      l_end_posn :=
       INSTR(p_PARAM_LIST, '=$',l_start_posn,1);

      l_name :=
        SUBSTR
         (p_PARAM_LIST
         , l_start_posn
         , (l_end_posn - l_start_posn));

      l_start_posn := l_end_posn+1;

      l_start_posn := l_start_posn+1; -- next to the '$'

      l_end_posn :=
       INSTR(p_PARAM_LIST, ',', l_start_posn, 1);
      IF l_end_posn <= l_start_posn
      THEN
        l_end_posn := LENGTH(p_PARAM_LIST)+1;
      END IF;

      l_value :=
        SUBSTR
         (p_PARAM_LIST
         ,l_start_posn
         ,(l_end_posn - l_start_posn)
         );


       -- Get the value from the WI Parameters
       l_wf_value :=
         XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
          (p_WORKITEM_INSTANCE_ID
          ,l_value
          );

       -- Append the NV pair to the message param list
      IF l_invocation_param_list IS NULL
      THEN
        l_temp := '''' || l_wf_value || '''';
      ELSE
        l_temp := ','|| '''' || l_wf_value || '''';
      END IF;


      -- Concatenate the paramter list
      l_invocation_param_list :=
        CONCAT(l_invocation_param_list,l_temp);

      EXIT WHEN l_end_posn >= LENGTH(p_PARAM_LIST);
     END LOOP;
    END IF; -- p_PARAM_LIST not null

  -- Get the SENDER NAME
  l_sender_name :=
         XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
          (p_WORKITEM_INSTANCE_ID
          ,'SP_NAME'
          );

  -- Get the opposite party's reference id
  l_OPP_REFERENCE_ID :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'OPP_REFERENCE_ID'
   );

  -- Construct the dynamic SQL

-- pre and suffixes with predefined strings
-- By Anping Wang, bug refer. 1650015
-- 02/19/2001
	l_pkg_name := XNP_MESSAGE.g_pkg_prefix || p_event_type || XNP_MESSAGE.g_pkg_suffix ;

  IF l_invocation_param_list IS NOT NULL
  THEN
   l_PROC_CALL :=
    'BEGIN
     '||l_pkg_name||'.SEND(' ||
       l_invocation_param_list ||  '
         ,:l_message_id
         ,:x_error_code
         ,:x_error_message
         ,:l_consumer_name
         ,:l_sender_name
         ,:l_recipient_name
         ,:p_version
         ,:p_callback_ref_id
         ,:l_opp_reference_id
         ,:p_order_id
         ,:p_workitem_instance_id
         ,:p_fa_instance_id);
     END;';
   ELSE

   l_PROC_CALL :=
    'BEGIN
     '||l_pkg_name||'.SEND(' ||  '
         :l_message_id
        ,:x_error_code
        ,:x_error_message
        ,:l_consumer_name
        ,:l_sender_name
        ,:l_recipient_name
        ,:p_version
        ,:p_callback_ref_id
        ,:l_opp_reference_id
        ,:p_order_id
        ,:p_workitem_instance_id
        ,:p_fa_instance_id);
     END;';
   END IF;

  -- BUG # 1500177
  -- This FE_NAME is used by the publish() called within the send()
  -- while doing push() to the queue to populate correct FE_NAME

  XNP_STANDARD.FE_NAME := l_fe_name;


  BEGIN
	EXECUTE IMMEDIATE l_proc_call USING
		 OUT l_message_id
		,OUT x_error_code
		,OUT x_error_message
		,IN l_consumer_name
		,IN l_sender_name
		,IN l_recipient_name
		,IN p_version
		,IN p_callback_ref_id
		,IN l_opp_reference_id
		,IN p_order_id
		,IN p_workitem_instance_id
		,IN p_fa_instance_id;

  EXCEPTION
      WHEN OTHERS THEN

  		XNP_STANDARD.FE_NAME := null;

        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.SEND_MESSAGE');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;
  END;

  XNP_STANDARD.FE_NAME := null;

END SEND_MESSAGE;


 --------------------------------------------------------------------
 --
 -- Called when: During provisioning phase of the order
 -- Called by:
 -- Description:
 -- Calls XNP_CORE.SMS_DELETE_FE_MAP
 -- References WI params STARTING_NUMBER, ENDING_NUMBER
 --
 ------------------------------------------------------------------
PROCEDURE SMS_DELETE_FE_MAP
 (p_WORKITEM_INSTANCE_ID IN NUMBER
 ,p_FE_ID IN                NUMBER
 ,p_FEATURE_TYPE            VARCHAR2
 ,x_ERROR_CODE          OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 )
IS
l_STARTING_NUMBER VARCHAR2(40);
l_ENDING_NUMBER   VARCHAR2(40);

BEGIN
   x_error_code := 0;
   -- Get the starting and ending TN for this workitem

  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

   -- Call XNP_CORE.SMS_DELETE_FE_MAP
   XNP_CORE.SMS_DELETE_FE_MAP
    (l_STARTING_NUMBER
    ,l_ENDING_NUMBER
    ,p_FE_ID
    ,p_FEATURE_TYPE
    ,x_ERROR_CODE
    ,x_ERROR_MESSAGE
    );

   EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN'
          ,'XNP_STANDARD.SMS_DELETE_FE_MAP');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END SMS_DELETE_FE_MAP;

 ------------------------------------------------------------------
 -- Gets the TN range for this order and
 -- checks if there exists a TN in the
 -- given phase with the local SP performing
 -- the given role
 -- Mandatory Workitem parameters:
 -- STARTING_NUMBER,
 -- ENDING_NUMBER, SP_NAME, PORTING_ID
 --
 ------------------------------------------------------------------

PROCEDURE CHECK_PHASE_FOR_ROLE
 (p_WORKITEM_INSTANCE_ID IN NUMBER
 ,p_SP_ROLE              IN VARCHAR2
 ,p_PHASE_INDICATOR      IN VARCHAR2
 ,x_CHECK_STATUS         OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE           OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 )
IS
 l_starting_number  VARCHAR2(20);
 l_ending_number    VARCHAR2(20);
 l_SP_NAME          VARCHAR2(20);
 l_SP_ID            NUMBER;
 l_donor_sp_id      VARCHAR2(20);
 l_recipient_sp_id  VARCHAR2(20);
 l_SERVING_SP_ID    NUMBER;

BEGIN

  x_error_code := 0;
  x_CHECK_STATUS := 'N';

  l_starting_number :=
  XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
  XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  l_SP_NAME :=
  XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'SP_NAME'
   );

  -- Get the SP id for this SP code
  XNP_CORE.GET_SP_ID
   (l_SP_NAME
   ,l_SP_ID
   ,x_ERROR_CODE
   ,x_ERROR_MESSAGE
   );

  IF x_ERROR_CODE <> 0
  THEN
   RETURN;
  END IF;

  IF p_SP_ROLE = 'DONOR'
  THEN
    -- check for TN in given phase with SP as donor
    XNP_CORE.CHECK_DONOR_PHASE
     (p_STARTING_NUMBER =>l_STARTING_NUMBER
     ,p_ENDING_NUMBER   =>l_ENDING_NUMBER
     ,p_SP_ID           =>l_SP_ID
     ,p_PHASE_INDICATOR =>p_PHASE_INDICATOR
     ,x_CHECK_EXISTS    =>x_CHECK_STATUS
     ,x_ERROR_CODE      =>x_ERROR_CODE
     ,x_ERROR_MESSAGE   =>x_ERROR_MESSAGE
     );
  ELSE
    -- check for TN in given phase with SP as recipient
    XNP_CORE.CHECK_RECIPIENT_PHASE
     (p_STARTING_NUMBER =>l_STARTING_NUMBER
     ,p_ENDING_NUMBER   =>l_ENDING_NUMBER
     ,p_SP_ID           =>l_SP_ID
     ,p_PHASE_INDICATOR =>p_PHASE_INDICATOR
     ,x_CHECK_EXISTS    =>x_CHECK_STATUS
     ,x_ERROR_CODE      =>x_ERROR_CODE
     ,x_ERROR_MESSAGE   =>x_ERROR_MESSAGE
     );
  END IF;

  EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.CHECK_PHASE_FOR_ROLE');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;
END CHECK_PHASE_FOR_ROLE;

 ------------------------------------------------------------------
 -- Purpose: Registers a callback for the given event
 -- from the remote or local system.
 -- Calls XNP_EVENT.SUBSCRIBE
 ------------------------------------------------------------------
PROCEDURE SUBSCRIBE_FOR_EVENT
 (p_MESSAGE_TYPE IN VARCHAR2
 ,p_WORKITEM_INSTANCE_ID IN NUMBER
 ,p_CALLBACK_REF_ID VARCHAR2
 ,p_PROCESS_REFERENCE IN VARCHAR2
 ,p_ORDER_ID IN NUMBER
 ,p_FA_INSTANCE_ID IN NUMBER
 ,x_ERROR_CODE OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 )
IS
 l_callback_reference VARCHAR2(1024) := NULL;
 l_name VARCHAR2(256) := NULL;
 l_value VARCHAR2(256) := NULL;
 l_start_posn NUMBER := 0;
 l_end_posn NUMBER := 0;
 l_wf_value VARCHAR2(1024);
 l_temp VARCHAR2(1024);
BEGIN

  x_error_code := 0;
  x_error_message := NULL ;
  l_callback_reference := p_CALLBACK_REF_ID;

  ------ Register callback for the event -------

    XNP_EVENT.SUBSCRIBE
      (P_MSG_CODE=>p_MESSAGE_TYPE
      ,P_REFERENCE_ID=>l_callback_reference
      ,P_PROCESS_REFERENCE=>p_process_reference
      ,P_PROCEDURE_NAME=>'XNP_EVENT.RESUME_WORKFLOW'
      ,P_CALLBACK_TYPE=>'PL/SQL'
      ,P_CLOSE_REQD_FLAG=>'Y'
      ,P_ORDER_ID=>p_ORDER_ID
      ,P_WI_INSTANCE_ID=>p_WORKITEM_INSTANCE_ID
      ,P_FA_INSTANCE_ID=>p_FA_INSTANCE_ID
      );

  EXCEPTION
    WHEN OTHERS THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
        ,'XNP_STANDARD.SUBSCRIBE_FOR_EVENT');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;
END SUBSCRIBE_FOR_EVENT;

 --------------------------------------------------------------------
 -- Checks if this is a subsequent porting
 -- request and returns Y/N accordingly
 -- Expects the workitem paramter 'SUBSEQUENT_PORT'
 ------------------------------------------------------------------
PROCEDURE SOA_IS_SUBSEQUENT_PORT
 (p_WORKITEM_INSTANCE_ID IN NUMBER
 ,x_CHECK_STATUS OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 )
IS
BEGIN

  -- Get the work item parameter 'SUBSEQUENT_PORT'
  x_CHECK_STATUS :=
     XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
     (p_WORKITEM_INSTANCE_ID
      ,'SUBSEQUENT_PORT'
      );

  if (x_CHECK_STATUS = NULL)
  then
    x_CHECK_STATUS := 'N';
  end if;

  EXCEPTION
    WHEN OTHERS THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
        ,'XNP_STANDARD.SOA_IS_SUBSEQUENT_PORT');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;
END SOA_IS_SUBSEQUENT_PORT;

 ------------------------------------------------------------------
 -- Updates the SMS_FE_MAP status for the
 -- SVs corresponding to the given TNs
 -- to the new PROVISION_STATUS
 ------------------------------------------------------------------
PROCEDURE SMS_UPDATE_FE_MAP_STATUS
 (p_ORDER_ID             IN NUMBER,
  p_LINEITEM_ID          IN NUMBER,
  p_WORKITEM_INSTANCE_ID IN NUMBER,
  p_FA_INSTANCE_ID       IN NUMBER,
  p_FEATURE_TYPE            VARCHAR2,
  p_FE_ID                   NUMBER,
  p_PROV_STATUS             VARCHAR2,
  x_ERROR_CODE          OUT NOCOPY NUMBER,
  x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 )
IS
l_STARTING_NUMBER VARCHAR2(20);
l_ENDING_NUMBER   VARCHAR2(20);

BEGIN

  x_error_code      := 0;

  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  -- call updation procedure to get the fe list

  XNP_CORE.SMS_UPDATE_FE_MAP_STATUS
   (p_STARTING_NUMBER      => l_STARTING_NUMBER
   ,p_ENDING_NUMBER        => l_ENDING_NUMBER
   ,p_FE_ID                => p_FE_ID
   ,p_PROV_STATUS          => p_PROV_STATUS
   ,p_FEATURE_TYPE         => p_FEATURE_TYPE
   ,p_ORDER_ID             => p_ORDER_ID
   ,p_LINEITEM_ID          => p_LINEITEM_ID
   ,p_WORKITEM_INSTANCE_ID => p_WORKITEM_INSTANCE_ID
   ,p_FA_INSTANCE_ID       => p_FA_INSTANCE_ID
   ,x_ERROR_CODE           => x_ERROR_CODE
   ,x_ERROR_MESSAGE        => x_ERROR_MESSAGE
   );


   EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN'
         ,'XNP_STANDARD.SMS_UPDATE_FE_MAP_STATUS');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END SMS_UPDATE_FE_MAP_STATUS;


 --------------------------------------------------------------------
 --
 -- Called when: there is a Modify Ported Number
 -- request from NRC
 -- Description: Extracts the order information from SFM
 -- Workitem params
 -- Mandatory: Gets the PORTING_ID, STARTING_NUMBER, ENDING_NUMBER,
 -- PORTING_TIME,ROUTING_NUMBER
 -- Optional: CNAM_ADDRESS, CNAM_SUBSYSTEM,
 -- ISVM_ADDRESS, ISVM_SUBSYSTEM, LIDB_ADDRESS, LIDB_SUBSYSTEM,
 -- CLASS_ADDRESS, CLASS_SUBSYSTEM, WSMSC_ADDRESS, WSMSC_SUBSYSTEM,
 -- RN_ADDRESS, RN_SUBSYSTEM, SUBSCRIPTION_TYPE
 -- Modifies entry in SMS table for each TN in the range
 ------------------------------------------------------------------
PROCEDURE SMS_MODIFY_PORTED_NUMBER
 ( p_ORDER_ID               IN  NUMBER,
   p_LINEITEM_ID            IN  NUMBER,
   p_WORKITEM_INSTANCE_ID   IN  NUMBER,
   p_FA_INSTANCE_ID         IN  NUMBER,
   x_ERROR_CODE             OUT NOCOPY NUMBER,
   x_ERROR_MESSAGE          OUT NOCOPY VARCHAR2
 )
IS
l_sv_id             NUMBER;
l_porting_id        VARCHAR2(80) :=  null;
l_routing_number    VARCHAR2(40);
l_starting_number   VARCHAR2(20);
l_porting_time      VARCHAR2(40);
l_ending_number     VARCHAR2(20);
l_counter           BINARY_INTEGER;
l_index             BINARY_INTEGER := 0;
l_NRC_ID            NUMBER;
l_GEO_ID            NUMBER;
l_ROUTING_NUMBER_ID NUMBER;

l_SUBSCRIPTION_TYPE VARCHAR2(80) := 'NP';
l_CNAM_ADDRESS      VARCHAR2(80) := NULL;
l_CNAM_SUBSYSTEM    VARCHAR2(80) := NULL;
l_ISVM_ADDRESS      VARCHAR2(80) := NULL;
l_ISVM_SUBSYSTEM    VARCHAR2(80) := NULL;
l_LIDB_ADDRESS      VARCHAR2(80) := NULL;
l_LIDB_SUBSYSTEM    VARCHAR2(80) := NULL;
l_CLASS_ADDRESS     VARCHAR2(80) := NULL;
l_CLASS_SUBSYSTEM   VARCHAR2(80) := NULL;
l_WSMSC_ADDRESS     VARCHAR2(80) := NULL;
l_WSMSC_SUBSYSTEM   VARCHAR2(80) := NULL;
l_RN_ADDRESS        VARCHAR2(80) := NULL;
l_RN_SUBSYSTEM      VARCHAR2(80) := NULL;

BEGIN

  x_error_code := 0;

  l_porting_id :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PORTING_ID'
   );

  l_porting_time :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PORTING_TIME'
   );

  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  l_routing_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ROUTING_NUMBER'
   );

  -- Get the routing_number_id corresponding to the code

  XNP_CORE.GET_ROUTING_NUMBER_ID
   (l_ROUTING_NUMBER
   ,l_ROUTING_NUMBER_ID
   ,x_ERROR_CODE
   ,x_ERROR_MESSAGE
   );
  IF x_ERROR_CODE <> 0
  THEN
    RETURN;
  END IF;

  l_SUBSCRIPTION_TYPE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'SUBSCRIPTION_TYPE'
   );
  if (l_SUBSCRIPTION_TYPE IS null) then
    l_SUBSCRIPTION_TYPE := 'NP';
  end if;

  l_CNAM_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CNAM_ADDRESS'
   );

  l_CNAM_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CNAM_SUBSYSTEM'
   );

  l_ISVM_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ISVM_ADDRESS'
   );

  l_ISVM_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ISVM_SUBSYSTEM'
   );

  l_LIDB_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'LIDB_ADDRESS'
   );

  l_LIDB_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'LIDB_SUBSYSTEM'
   );

  l_CLASS_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CLASS_ADDRESS'
   );

  l_CLASS_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CLASS_SUBSYSTEM'
   );

  l_WSMSC_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'WSMSC_ADDRESS'
   );

  l_WSMSC_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'WSMSC_SUBSYSTEM'
   );

  l_RN_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'RN_ADDRESS'
   );

  l_RN_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'RN_SUBSYSTEM'
   );

  XNP_CORE.SMS_MODIFY_PORTED_NUMBER
   (p_PORTING_ID           =>l_porting_id
   ,p_STARTING_NUMBER      =>to_number(l_STARTING_NUMBER)
   ,p_ENDING_NUMBER        =>to_number(l_ENDING_NUMBER)
   ,p_ROUTING_NUMBER_ID    =>l_ROUTING_NUMBER_ID
   ,p_PORTING_TIME         =>XNP_UTILS.CANONICAL_TO_DATE(l_porting_time)
   ,p_CNAM_ADDRESS         =>l_CNAM_ADDRESS
   ,p_CNAM_SUBSYSTEM       =>l_CNAM_SUBSYSTEM
   ,p_ISVM_ADDRESS         =>l_ISVM_ADDRESS
   ,p_ISVM_SUBSYSTEM       =>l_ISVM_SUBSYSTEM
   ,p_LIDB_ADDRESS         =>l_LIDB_ADDRESS
   ,p_LIDB_SUBSYSTEM       =>l_LIDB_SUBSYSTEM
   ,p_CLASS_ADDRESS        =>l_CLASS_ADDRESS
   ,p_CLASS_SUBSYSTEM      =>l_CLASS_SUBSYSTEM
   ,p_WSMSC_ADDRESS        =>l_WSMSC_ADDRESS
   ,p_WSMSC_SUBSYSTEM      =>l_WSMSC_SUBSYSTEM
   ,p_RN_ADDRESS           =>l_RN_ADDRESS
   ,p_RN_SUBSYSTEM         =>l_RN_SUBSYSTEM
   ,p_ORDER_ID             =>p_ORDER_ID
   ,p_LINEITEM_ID          =>p_LINEITEM_ID
   ,p_WORKITEM_INSTANCE_ID =>p_WORKITEM_INSTANCE_ID
   ,p_FA_INSTANCE_ID       =>p_FA_INSTANCE_ID
   ,x_ERROR_CODE           =>x_ERROR_CODE
   ,x_ERROR_MESSAGE        =>x_ERROR_MESSAGE
   );

  EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.SMS_MODIFY_PORTED_NUMBER');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;
END SMS_MODIFY_PORTED_NUMBER;

 ------------------------------------------------------------------
 -- Calls xnp_core.check_donor_status_exists
 -- to check if there exists a porting record
 -- for the number range and created by the donor
 -- with the given status type code
 -- Mandatory WI Parameters: STARTING_NUMBER,ENDING_NUMBER,DONOR_SP_ID
 ------------------------------------------------------------------
PROCEDURE SOA_CHECK_DON_STATUS_EXISTS
 (p_WORKITEM_INSTANCE_ID IN NUMBER
 ,P_STATUS_TO_CHECK_WITH IN VARCHAR2
 ,x_CHECK_STATUS        OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE          OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 )
IS
l_starting_number varchar2(80) := null;
l_ending_number   varchar2(80) := null;
l_donor_sp_code   varchar2(80) := null;
l_donor_sp_id     number := 0;

BEGIN

    l_STARTING_NUMBER :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (p_WORKITEM_INSTANCE_ID
     ,'STARTING_NUMBER'
     );

    l_ENDING_NUMBER :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (p_WORKITEM_INSTANCE_ID
     ,'ENDING_NUMBER'
     );

    l_DONOR_SP_CODE :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (p_WORKITEM_INSTANCE_ID
     ,'DONOR_SP_ID'
     );

    -- Get the SP id for this SP code
    XNP_CORE.GET_SP_ID
    (l_DONOR_SP_CODE
    ,l_DONOR_SP_ID
    ,x_ERROR_CODE
    ,x_ERROR_MESSAGE
    );

    -- check the status as donor for this number range
    XNP_CORE.CHECK_DONOR_STATUS_EXISTS
     (p_STARTING_NUMBER  =>l_starting_number
     ,p_ENDING_NUMBER    =>l_ending_number
     ,p_STATUS_TYPE_CODE => p_status_to_check_with
     ,p_DONOR_SP_ID      => l_donor_sp_id
     ,x_CHECK_STATUS     =>x_check_status
     ,x_error_code       =>x_error_code
     ,x_error_message    =>x_error_message
     );

    IF x_ERROR_CODE <> 0
    THEN
      RETURN;
    END IF;

EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.SOA_CHECK_DON_STATUS_EXISTS');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;
END SOA_CHECK_DON_STATUS_EXISTS;

 ------------------------------------------------------------------
 -- Calls xnp_core.check_recipient_status_exists
 -- to check if there exists a porting record
 -- for the number range and created by the donor
 -- with the given status type code
 -- Mandatory WI Parameters: STARTING_NUMBER,ENDING_NUMBER,RECIPIENT_SP_ID
 ------------------------------------------------------------------
PROCEDURE SOA_CHECK_REC_STATUS_EXISTS
 (p_WORKITEM_INSTANCE_ID IN NUMBER
 ,P_STATUS_TO_CHECK_WITH IN VARCHAR2
 ,x_CHECK_STATUS         OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE           OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 )
IS
l_starting_number   varchar2(80) := null;
l_ending_number     varchar2(80) := null;
l_recipient_sp_code varchar2(80) := null;
l_recipient_sp_id   number := 0;

BEGIN

    l_STARTING_NUMBER :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (p_WORKITEM_INSTANCE_ID
     ,'STARTING_NUMBER'
     );

    l_ENDING_NUMBER :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (p_WORKITEM_INSTANCE_ID
     ,'ENDING_NUMBER'
     );

    l_RECIPIENT_SP_CODE :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (p_WORKITEM_INSTANCE_ID
     ,'RECIPIENT_SP_ID'
     );

    -- Get the SP id for this SP code
    XNP_CORE.GET_SP_ID
    (l_RECIPIENT_SP_CODE
    ,l_RECIPIENT_SP_ID
    ,x_ERROR_CODE
    ,x_ERROR_MESSAGE
    );

    -- check the status as donor for this number range
    XNP_CORE.CHECK_RECIPIENT_STATUS_EXISTS
     (p_STARTING_NUMBER  =>l_starting_number
     ,p_ENDING_NUMBER    =>l_ending_number
     ,p_STATUS_TYPE_CODE => p_status_to_check_with
     ,p_RECIPIENT_SP_ID  => l_recipient_sp_id
     ,x_CHECK_STATUS     =>x_check_status
     ,x_error_code       =>x_error_code
     ,x_error_message    =>x_error_message
     );

    IF x_ERROR_CODE <> 0  THEN
      RETURN;
    END IF;

EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.SOA_CHECK_REC_STATUS_EXISTS');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;
END SOA_CHECK_REC_STATUS_EXISTS;

 ------------------------------------------------------------------
 -- Called when: need to update the SV status according
 --   to the activity parameter SV_STATUS
 --  Gets the Item Attributes WORKITEM_INSTANCE
 --  Calls XNP_CORE.SOA_UPDATE_SV_STATUS
 -- Description: Procedure to update the status of
 -- the Porting Order Records to the new status
 -- for the given PORTING_ID
 -- (a.k.a OBJECT_REFERENCE) and
 -- belonging to the (local) SP ID.
 ------------------------------------------------------------------
PROCEDURE SOA_UPDATE_SV_STATUS
 ( p_ORDER_ID               IN  NUMBER,
   p_LINEITEM_ID            IN  NUMBER,
   p_WORKITEM_INSTANCE_ID   IN  NUMBER,
   p_FA_INSTANCE_ID         IN  NUMBER,
   p_NEW_STATUS_TYPE_CODE       VARCHAR2,
   p_STATUS_CHANGE_CAUSE_CODE   VARCHAR2,
   x_ERROR_CODE             OUT NOCOPY NUMBER,
   x_ERROR_MESSAGE          OUT NOCOPY VARCHAR2
 )
IS
l_porting_id           VARCHAR2(80) := NULL;
l_starting_number      VARCHAR2(80) := NULL;
l_ending_number        VARCHAR2(80) := NULL;
l_cur_status_type_code VARCHAR2(80) := NULL;
l_new_phase_indicator  VARCHAR2(80) := NULL;
l_LOCAL_SP_ID          NUMBER := 0;
l_SP_NAME              VARCHAR2(40) := NULL;


CURSOR c_CUR_STATUS IS
  SELECT status_type_code
    FROM xnp_sv_soa
   WHERE object_reference = l_porting_id;

BEGIN
  x_error_code := 0;

  l_porting_id :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PORTING_ID'
   );

  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ENDING_NUMBER :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  l_SP_NAME :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'SP_NAME'
   );

  -- Get the phase of new status being set
  XNP_CORE.GET_PHASE_FOR_STATUS
   (p_NEW_STATUS_TYPE_CODE
   ,l_NEW_PHASE_INDICATOR
   ,x_ERROR_CODE
   ,x_ERROR_MESSAGE
   );
  IF x_ERROR_CODE <> 0
  THEN
   RETURN;
  END IF;

   ------------------------------------------------------------------
   -- If the new status is 'ACTIVE' (for example)
   -- Ensure that no other SV exists in Active state
   ------------------------------------------------------------------
  IF l_NEW_PHASE_INDICATOR = 'ACTIVE'
  THEN

   OPEN c_CUR_STATUS;
   FETCH c_CUR_STATUS INTO l_cur_status_type_code;

   IF c_CUR_STATUS%FOUND THEN

     XNP_CORE.SOA_RESET_SV_STATUS
     (p_STARTING_NUMBER          => l_starting_number
     ,p_ENDING_NUMBER            => l_ending_number
     ,p_LOCAL_SP_ID              => l_LOCAL_SP_ID
     ,p_CUR_PHASE_INDICATOR      => l_NEW_PHASE_INDICATOR
     ,p_RESET_PHASE_INDICATOR    => 'OLD'
     ,p_OMIT_STATUS              => l_CUR_STATUS_TYPE_CODE
     ,P_STATUS_CHANGE_CAUSE_CODE => 'Reset to OLD'
     ,p_ORDER_ID                 => p_ORDER_ID
     ,p_LINEITEM_ID              => p_LINEITEM_ID
     ,p_WORKITEM_INSTANCE_ID     => p_WORKITEM_INSTANCE_ID
     ,p_FA_INSTANCE_ID           => p_FA_INSTANCE_ID
     ,X_ERROR_CODE               => x_ERROR_CODE
     ,X_ERROR_MESSAGE            => x_ERROR_MESSAGE
     );

   END IF;
  END IF;

  -- call updation procedure to update the status

  XNP_CORE.SOA_UPDATE_SV_STATUS
   (p_PORTING_ID               => l_porting_id
   ,p_LOCAL_SP_ID              => l_LOCAL_SP_ID
   ,P_NEW_STATUS_TYPE_CODE     => p_new_status_type_code
   ,P_STATUS_CHANGE_CAUSE_CODE => p_status_change_cause_code
   ,p_ORDER_ID                 => p_ORDER_ID
   ,p_LINEITEM_ID              => p_LINEITEM_ID
   ,p_WORKITEM_INSTANCE_ID     => p_WORKITEM_INSTANCE_ID
   ,p_FA_INSTANCE_ID           => p_FA_INSTANCE_ID
   ,X_ERROR_CODE               => x_ERROR_CODE
   ,X_ERROR_MESSAGE            => x_ERROR_MESSAGE
   );

  EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.SOA_UPDATE_SV_STATUS');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END SOA_UPDATE_SV_STATUS;

 ------------------------------------------------------------------
 -- Updates the Notes info
 -- Mandatory WI Params: PORTING_ID
 -- Optional WI Params: COMMENTS,NOTES,PREORDER_AUTHORIZATION_CODE
 ------------------------------------------------------------------
PROCEDURE SOA_UPDATE_NOTES_INFO
 ( p_ORDER_ID               IN  NUMBER,
   p_LINEITEM_ID            IN  NUMBER,
   p_WORKITEM_INSTANCE_ID   IN  NUMBER,
   p_FA_INSTANCE_ID         IN  NUMBER,
   x_ERROR_CODE             OUT NOCOPY NUMBER,
   x_ERROR_MESSAGE          OUT NOCOPY VARCHAR2
 )
IS
  l_PORTING_ID                  VARCHAR2(40) := null;
  l_COMMENTS                    VARCHAR2(2000);
  l_NOTES                       VARCHAR2(2000);
  l_PREORDER_AUTHORIZATION_CODE VARCHAR2(40) := NULL;
  l_SP_NAME                     VARCHAR2(80) := NULL;
  l_LOCAL_SP_ID                 NUMBER := 0;

BEGIN

  x_error_code := 0;

  l_PORTING_ID :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PORTING_ID'
   );

  l_COMMENTS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'COMMENTS'
   );

   l_NOTES :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'NOTES'
   );

  l_PREORDER_AUTHORIZATION_CODE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PREORDER_AUTHORIZATION_CODE'
   );


  l_SP_NAME :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'SP_NAME'
   );

  XNP_CORE.SOA_UPDATE_NOTES_INFO
  (p_PORTING_ID                 => l_PORTING_ID
  ,p_LOCAL_SP_ID                => l_LOCAL_SP_ID
  ,p_PREORDER_AUTHORIZATION_CODE=> l_PREORDER_AUTHORIZATION_CODE
  ,p_COMMENTS                   => l_COMMENTS
  ,p_NOTES                      => l_NOTES
  ,p_ORDER_ID                   => p_ORDER_ID
  ,p_LINEITEM_ID                => p_LINEITEM_ID
  ,p_WORKITEM_INSTANCE_ID       => p_WORKITEM_INSTANCE_ID
  ,p_FA_INSTANCE_ID             => p_FA_INSTANCE_ID
  ,x_ERROR_CODE                 => x_ERROR_CODE
  ,x_ERROR_MESSAGE              => x_ERROR_MESSAGE
  );

  IF (x_error_code <> 0) THEN
    return;
  END IF;

  EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.SOA_UPDATE_NOTES_INFO');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END SOA_UPDATE_NOTES_INFO;


 ------------------------------------------------------------------
 -- Updates the Network information for the given
 -- Porting id in XNP_SV_SOA
 -- Mandatory WI parameter: ROUTING_NUMBER
 -- Optional WI Params: ROUTING_NUMBER,
 -- CNAM_ADDRESS, CNAM_SUBSYSTEM, ISVM_ADDRESS
 -- ISVM_SUBSYSTEM, LIDB_ADDRESS, LIDB_SUBSYSTEM
 -- CLASS_ADDRESS,CLASS_SUBSYSTEM,WSMSC_ADDRESS,
 -- WSMSC_SUBSYSTEM, RN_ADDRESS, RN_SUBSYSTEM
 ------------------------------------------------------------------
PROCEDURE SOA_UPDATE_NETWORK_INFO
 ( p_ORDER_ID               IN  NUMBER,
   p_LINEITEM_ID            IN  NUMBER,
   p_WORKITEM_INSTANCE_ID   IN  NUMBER,
   p_FA_INSTANCE_ID         IN  NUMBER,
   x_ERROR_CODE             OUT NOCOPY NUMBER,
   x_ERROR_MESSAGE          OUT NOCOPY VARCHAR2
 )
IS
  l_LOCAL_SP_ID       NUMBER := 0;
  l_ROUTING_NUMBER_ID NUMBER := 0;
  l_ROUTING_NUMBER    VARCHAR2(40);
  l_PORTING_ID        VARCHAR2(40) := null;
  l_CNAM_ADDRESS      VARCHAR2(80) := NULL;
  l_CNAM_SUBSYSTEM    VARCHAR2(80) := NULL;
  l_ISVM_ADDRESS      VARCHAR2(80) := NULL;
  l_ISVM_SUBSYSTEM    VARCHAR2(80) := NULL;
  l_LIDB_ADDRESS      VARCHAR2(80) := NULL;
  l_LIDB_SUBSYSTEM    VARCHAR2(80) := NULL;
  l_CLASS_ADDRESS     VARCHAR2(80) := NULL;
  l_CLASS_SUBSYSTEM   VARCHAR2(80) := NULL;
  l_WSMSC_ADDRESS     VARCHAR2(80) := NULL;
  l_WSMSC_SUBSYSTEM   VARCHAR2(80) := NULL;
  l_RN_ADDRESS        VARCHAR2(80) := NULL;
  l_RN_SUBSYSTEM      VARCHAR2(80) := NULL;
  l_SP_NAME           VARCHAR2(80) := NULL;

BEGIN

  x_error_code := 0;

  l_PORTING_ID :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PORTING_ID'
   );

  l_CNAM_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CNAM_ADDRESS'
   );

  l_CNAM_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CNAM_SUBSYSTEM'
   );

  l_ISVM_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ISVM_ADDRESS'
   );

  l_ISVM_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ISVM_SUBSYSTEM'
   );

  l_LIDB_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'LIDB_ADDRESS'
   );

  l_LIDB_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'LIDB_SUBSYSTEM'
   );

  l_CLASS_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CLASS_ADDRESS'
   );

  l_CLASS_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CLASS_SUBSYSTEM'
   );

  l_WSMSC_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'WSMSC_ADDRESS'
   );

  l_WSMSC_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'WSMSC_SUBSYSTEM'
   );

  l_RN_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'RN_ADDRESS'
   );

  l_RN_SUBSYSTEM :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'RN_SUBSYSTEM'
   );

  -- Get the routing number id
  l_ROUTING_NUMBER :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ROUTING_NUMBER'
   );

   -- Get the routing_number_id corresponding to the code
   XNP_CORE.GET_ROUTING_NUMBER_ID
      (l_routing_number
      ,l_ROUTING_NUMBER_ID
      ,x_ERROR_CODE
      ,x_ERROR_MESSAGE
      );

   IF x_ERROR_CODE <> 0
   THEN
     RETURN;
   END IF;


  l_SP_NAME :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'SP_NAME'
   );

   XNP_CORE.SOA_UPDATE_NETWORK_INFO
    (p_porting_id           => l_porting_id
    ,p_LOCAL_SP_ID          => l_LOCAL_SP_ID
    ,p_ROUTING_NUMBER_ID    => l_ROUTING_NUMBER_ID
    ,p_CNAM_ADDRESS         => l_CNAM_ADDRESS
    ,p_CNAM_SUBSYSTEM       => l_CNAM_SUBSYSTEM
    ,p_ISVM_ADDRESS         => l_ISVM_ADDRESS
    ,p_ISVM_SUBSYSTEM       => l_ISVM_SUBSYSTEM
    ,p_LIDB_ADDRESS         => l_LIDB_ADDRESS
    ,p_LIDB_SUBSYSTEM       => l_LIDB_SUBSYSTEM
    ,p_CLASS_ADDRESS        => l_CLASS_ADDRESS
    ,p_CLASS_SUBSYSTEM      => l_CLASS_SUBSYSTEM
    ,p_WSMSC_ADDRESS        => l_WSMSC_ADDRESS
    ,p_WSMSC_SUBSYSTEM      => l_WSMSC_SUBSYSTEM
    ,p_RN_ADDRESS           => l_RN_ADDRESS
    ,p_RN_SUBSYSTEM         => l_RN_SUBSYSTEM
    ,p_ORDER_ID             => p_ORDER_ID
    ,p_LINEITEM_ID          => p_LINEITEM_ID
    ,p_WORKITEM_INSTANCE_ID => p_WORKITEM_INSTANCE_ID
    ,p_FA_INSTANCE_ID       => p_FA_INSTANCE_ID
    ,x_ERROR_CODE           => x_ERROR_CODE
    ,x_ERROR_MESSAGE        => x_ERROR_MESSAGE
    );

  IF (x_error_code <> 0) THEN
    return;
  END IF;

  EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;
        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.SOA_UPDATE_NETWORK_INFO');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END SOA_UPDATE_NETWORK_INFO;

 ------------------------------------------------------------------
 -- Updates the Customer information for the Porting id
 -- Mandatory WI Params: PORTING_ID
 -- Optional WI Params: PAGER, PAGER_PIN,INTERNET_ADDRESS, CUSTOMER_ID,
 -- CUSTOMER_NAME,ADDRESS_LINE1,CITY,PHONE,FAX,EMAIL,ZIP_CODE,
 -- CUSTOMER_CONTACT_REQ_FLAG,CONTACT_NAME
 ------------------------------------------------------------------
PROCEDURE SOA_UPDATE_CUSTOMER_INFO
 ( p_ORDER_ID               IN  NUMBER,
   p_LINEITEM_ID            IN  NUMBER,
   p_WORKITEM_INSTANCE_ID   IN  NUMBER,
   p_FA_INSTANCE_ID         IN  NUMBER,
   x_ERROR_CODE             OUT NOCOPY NUMBER,
   x_ERROR_MESSAGE          OUT NOCOPY VARCHAR2
 )
IS
  l_PORTING_ID                VARCHAR2(40) := null;
  l_CUSTOMER_ID               VARCHAR2(30);
  l_CUSTOMER_NAME             VARCHAR2(80);
  l_CUSTOMER_TYPE             VARCHAR2(10);
  l_ADDRESS_LINE1             VARCHAR2(400);
  l_ADDRESS_LINE2             VARCHAR2(400);
  l_CITY                      VARCHAR2(40);
  l_PHONE                     VARCHAR2(40);
  l_FAX                       VARCHAR2(40);
  l_EMAIL                     VARCHAR2(40);
  l_ZIP_CODE                  VARCHAR2(40);
  l_COUNTRY                   VARCHAR2(40);
  l_CUSTOMER_CONTACT_REQ_FLAG VARCHAR2(3);
  l_CONTACT_REQUESTED         VARCHAR2(5);
  l_CONTACT_NAME              VARCHAR2(40) := NULL;
  l_PAGER                     VARCHAR2(20) := NULL;
  l_PAGER_PIN                 VARCHAR2(80) := NULL;
  l_INTERNET_ADDRESS          VARCHAR2(40) := NULL;
  l_SP_NAME                   VARCHAR2(80) := NULL;
  l_LOCAL_SP_ID               NUMBER := 0;

BEGIN

  x_error_code := 0;

  l_PORTING_ID :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PORTING_ID'
   );

  l_CUSTOMER_ID :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CUSTOMER_ID'
   );

  l_CUSTOMER_NAME :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CUSTOMER_NAME'
   );

  l_CUSTOMER_TYPE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CUSTOMER_TYPE'
   );

  l_ADDRESS_LINE1 :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ADDRESS_LINE1'
   );

  l_ADDRESS_LINE2 :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ADDRESS_LINE2'
   );

  l_CITY :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CITY'
   );

  l_PHONE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PHONE'
   );

  l_FAX :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'FAX'
   );

  l_EMAIL :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'EMAIL'
   );

  l_ZIP_CODE :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'ZIP_CODE'
   );

  l_COUNTRY :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'COUNTRY'
   );

  l_CUSTOMER_CONTACT_REQ_FLAG :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CUSTOMER_CONTACT_REQ_FLAG'
   );

  l_CONTACT_NAME :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'CONTACT_NAME'
   );


  l_PAGER :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PAGER'
   );

  l_PAGER_PIN :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'PAGER_PIN'
   );

  l_INTERNET_ADDRESS :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'INTERNET_ADDRESS'
   );


  l_SP_NAME :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'SP_NAME'
   );

  XNP_CORE.SOA_UPDATE_CUSTOMER_INFO
    (p_PORTING_ID                => l_PORTING_ID
    ,p_LOCAL_SP_ID               => l_LOCAL_SP_ID
    ,p_CUSTOMER_ID               => l_CUSTOMER_ID
    ,p_CUSTOMER_NAME             => l_CUSTOMER_NAME
    ,p_CUSTOMER_TYPE             => l_CUSTOMER_TYPE
    ,p_ADDRESS_LINE1             => l_ADDRESS_LINE1
    ,p_ADDRESS_LINE2             => l_ADDRESS_LINE2
    ,p_CITY                      => l_CITY
    ,p_PHONE                     => l_PHONE
    ,p_FAX                       => l_FAX
    ,p_EMAIL                     => l_EMAIL
    ,p_PAGER                     => l_PAGER
    ,p_PAGER_PIN                 => l_PAGER_PIN
    ,p_INTERNET_ADDRESS          => l_INTERNET_ADDRESS
    ,p_ZIP_CODE                  => l_ZIP_CODE
    ,p_COUNTRY                   => l_COUNTRY
    ,p_CUSTOMER_CONTACT_REQ_FLAG => l_CUSTOMER_CONTACT_REQ_FLAG
    ,p_CONTACT_NAME              => l_CONTACT_NAME
    ,p_ORDER_ID                  => p_ORDER_ID
    ,p_LINEITEM_ID               => p_LINEITEM_ID
    ,p_WORKITEM_INSTANCE_ID      => p_WORKITEM_INSTANCE_ID
    ,p_FA_INSTANCE_ID            => p_FA_INSTANCE_ID
    ,x_ERROR_CODE                => x_ERROR_CODE
    ,x_ERROR_MESSAGE             => x_ERROR_MESSAGE
    );

  IF (x_error_code <> 0) THEN
    return;
  END IF;

  EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;
        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN','XNP_STANDARD.SOA_UPDATE_CUSTOMER_INFO');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END SOA_UPDATE_CUSTOMER_INFO;

----------------------------------------------------------------------
-- Runtime Validation check for NP workitem.
-- Calls XNP_CORE.RUNTIME_VALIDATION
-- Optional WI Params: STARTING_NUMBER,ENDING_NUMBER,ROUTING_NUMBER,
-- DONOR_SP_CODE,RECIPIENT_SP_CODE
---------------------------------------------------------------------
 PROCEDURE RUNTIME_VALIDATION
 ( p_ORDER_ID             IN NUMBER
  ,p_LINE_ITEM_ID         IN NUMBER
  ,p_WORKITEM_INSTANCE_ID IN NUMBER
  ,x_ERROR_CODE           OUT NOCOPY NUMBER
  ,x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 )
IS
l_starting_number   varchar2(80) := null;
l_ending_number     varchar2(80) := null;
l_donor_sp_code     varchar2(80) := null;
l_recipient_sp_code varchar2(80):= null;
l_routing_number    varchar2(40):= null;

BEGIN

    x_ERROR_CODE:=0;

    l_starting_number :=
     XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
     (p_WORKITEM_INSTANCE_ID
     ,'STARTING_NUMBER'
     );

    l_ending_number :=
     XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
     (p_WORKITEM_INSTANCE_ID
     ,'ENDING_NUMBER'
     );

    l_donor_sp_code :=
     XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
     (p_WORKITEM_INSTANCE_ID
     ,'DONOR_SP_ID'
      );

  l_recipient_sp_code :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (p_WORKITEM_INSTANCE_ID
   ,'RECIPIENT_SP_ID'
   );

     l_routing_number :=
  	 XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
      (p_WORKITEM_INSTANCE_ID
      ,'ROUTING_NUMBER'
      );

    XNP_CORE.RUNTIME_VALIDATION
   (p_ORDER_ID     =>p_ORDER_ID
   ,p_LINE_ITEM_ID =>p_LINE_ITEM_ID
   ,p_WORKITEM_INSTANCE_ID=>p_WORKITEM_INSTANCE_ID
   ,p_STARTING_NUMBER=>l_starting_number
   ,p_ENDING_NUMBER=>l_ending_number
   ,p_ROUTING_NUMBER=>l_routing_number
   ,p_DONOR_SP_CODE=>l_donor_sp_code
   ,p_RECIPIENT_SP_CODE=>l_recipient_sp_code
   ,x_ERROR_CODE=>x_ERROR_CODE
   ,x_ERROR_MESSAGE=>x_ERROR_MESSAGE
   );

EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN' ,'XNP_STANDARD.RUNTIME_VALIDATION');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;


END RUNTIME_VALIDATION;


PROCEDURE DEREGISTER_ALL
( p_order_id 	IN NUMBER
 ,x_error_code 	OUT NOCOPY NUMBER
 ,x_error_message 	OUT NOCOPY VARCHAR2
)

IS

BEGIN

 x_error_code := 0;
 xnp_timer_standard.deregister(p_order_id => DEREGISTER_ALL.p_order_id,
                               x_error_code => DEREGISTER_ALL.x_error_code,
                               x_error_message => DEREGISTER_ALL.x_error_message);

 if (x_error_code <> 0 ) then
       return;
 end if;

 x_error_code := 0;
 xnp_event.deregister(p_order_id => DEREGISTER_ALL.p_order_id,
                      x_error_code => DEREGISTER_ALL.x_error_code,
                      x_error_message => DEREGISTER_ALL.x_error_message);

 if (x_error_code <> 0 ) then
        return;
 end if;

END DEREGISTER_ALL;

END XNP_STANDARD;

/
