--------------------------------------------------------
--  DDL for Package Body XNP_WF_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_WF_STANDARD" AS
/* $Header: XNPWFACB.pls 120.0 2005/05/30 11:48:18 appldev noship $ */


-- Copies Item attributes defined in workflow to the equivalant
-- workitem parameters in xdp_worklist_details.

Procedure downloadFAParams( itemtype IN VARCHAR2,
                            itemkey IN VARCHAR2,
                            actid IN NUMBER,
                            p_FAInstanceID IN NUMBER );

 --------------------------------------------------------------------
 -- Called when: The itemtype is initiated
 -- Description:
 --  Sets the SFM workitem and order context information
 --  into the package global variables
 --  g_ORDER_ID and g_WORKITEM_INSTANCE_ID
 ------------------------------------------------------------------
PROCEDURE SET_SDP_CONTEXT
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,COMMAND IN VARCHAR2
 ,RESULT OUT NOCOPY VARCHAR2
 )
IS
x_progress VARCHAR2(2000) := NULL;
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (command = 'RUN') THEN
    result := '';
    return;
  END IF;

  --
  -- SET_CTX mode - set process context information
  --
  IF (command = 'SET_CTX') THEN

    -- set the context information
    XNP_WF_STANDARD.g_WORKITEM_INSTANCE_ID :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'WORKITEM_INSTANCE_ID'
      );

    XNP_WF_STANDARD.g_ORDER_ID :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'ORDER_ID'
      );

     -- Completion
     result := '';
     RETURN;

   ELSIF (command = 'SET_ORD') THEN

    -- set the context information

    XNP_WF_STANDARD.g_ORDER_ID :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'ORDER_ID'
      );

     -- Completion
     result := '';
     RETURN;


   ELSIF (command = 'SET_WI') THEN

    -- set the context information

    XNP_WF_STANDARD.g_WORKITEM_INSTANCE_ID :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'WORKITEM_INSTANCE_ID'
      );

     -- Completion
     result := '';
     RETURN;

   ELSIF (command = 'SET_FA') THEN

    -- set the context information

    XNP_WF_STANDARD.g_FA_INSTANCE_ID :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'FA_INSTANCE_ID'
      );

     -- Completion
     result := '';
     RETURN;
   ELSIF (command = 'SET_ORD_WI') THEN

    -- set the context information

    XNP_WF_STANDARD.g_ORDER_ID :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'ORDER_ID'
      );

    XNP_WF_STANDARD.g_WORKITEM_INSTANCE_ID :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'WORKITEM_INSTANCE_ID'
      );

     -- Completion
     result := '';
     RETURN;
   ELSIF (command = 'SET_ORD_FA') THEN

    -- set the context information

    XNP_WF_STANDARD.g_ORDER_ID :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'ORDER_ID'
      );

    XNP_WF_STANDARD.g_FA_INSTANCE_ID :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'FA_INSTANCE_ID'
      );

     -- Completion
     result := '';
     RETURN;
   ELSIF (command = 'SET_WI_FA') THEN

    -- set the context information

    XNP_WF_STANDARD.g_WORKITEM_INSTANCE_ID :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'WORKITEM_INSTANCE_ID'
      );

    XNP_WF_STANDARD.g_FA_INSTANCE_ID :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'FA_INSTANCE_ID'
      );

     -- Completion
     result := '';
     RETURN;
   ELSIF (command = 'SET_ORD_WI_FA') THEN

    -- set the context information

    XNP_WF_STANDARD.g_ORDER_ID :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'ORDER_ID'
      );

    XNP_WF_STANDARD.g_WORKITEM_INSTANCE_ID :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'WORKITEM_INSTANCE_ID'
      );

    XNP_WF_STANDARD.g_FA_INSTANCE_ID :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'FA_INSTANCE_ID'
      );

     -- Completion
     result := '';
     RETURN;

   END IF;
  --
  -- TEST_CTX mode
  --
  IF (command = 'TEST_CTX' ) THEN

    -- set the context information

    XNP_WF_STANDARD.g_WORKITEM_INSTANCE_ID :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'WORKITEM_INSTANCE_ID'
      );

    XNP_WF_STANDARD.g_ORDER_ID :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'ORDER_ID'
      );

    result := 'TRUE';
    return;
  END IF;

  -- For other execution modes: return null
  result := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN

     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------
     fnd_message.set_name('XNP','STD_ERROR');
     fnd_message.set_token(
       'ERROR_LOCN','XNP_WF_STANDARD.SET_SDP_CONTEXT');
     fnd_message.set_token('ERROR_TEXT',
       ':'||to_char(SQLCODE)||':'||SQLERRM);
     x_progress := fnd_message.get;
     wf_core.context(
        'XNP_WF_STANDARD'
        , 'SET_SDP_CONTEXT'
        , itemtype
        , itemkey
        , to_char(actid)
        , command
        , x_progress);

      RAISE;

END SET_SDP_CONTEXT;

 --------------------------------------------------------------------
 -- Called when: there is a Create Ported Number
 --   request from NRC
 -- Description:
 --  Gets the Item Attributes WORKITEM_INSTANCE, ORDER_ID
 --  Calls XNP_STANDARD.SMS_CREATE_PORTED_NUMBER
 ------------------------------------------------------------------
PROCEDURE SMS_CREATE_PORTED_NUMBER
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS

l_ORDER_ID                 NUMBER;
l_LINEITEM_ID              NUMBER;
l_WORKITEM_INSTANCE_ID     NUMBER;
l_FA_INSTANCE_ID           NUMBER;
l_error_code               NUMBER := 0;
l_error_message            VARCHAR2(2000);
x_progress                 VARCHAR2(2000) := NULL;
e_SMS_CREATE_PORTED_NUMBER EXCEPTION;

BEGIN

  --
  -- Call SET_SDP_CTX to set values for WI_ID and ORDER_ID
  --
  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_ORD_WI'
   ,RESULTOUT
   );

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

  l_ORDER_ID             := g_ORDER_ID;
  l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID ;

    XNP_STANDARD.SMS_CREATE_PORTED_NUMBER
     (l_ORDER_ID ,
      l_LINEITEM_ID ,
      l_WORKITEM_INSTANCE_ID,
      l_FA_INSTANCE_ID,
      l_error_code,
      l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SMS_CREATE_PORTED_NUMBER;
    END IF;
     -- Completion
     resultout := 'COMPLETE';
     RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN

     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------
      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SMS_CREATE_PORTED_NUMBER'
       ,P_MSG_NAME             => 'SMS_CREATE_PORTED_NUMBER_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );

      RAISE;

END SMS_CREATE_PORTED_NUMBER;

 --------------------------------------------------------------------
 -- Called when: there is a Delete Ported Number request
 --   from NRC
 -- Description:
 --  Gets the Item Attributes WORKITEM_INSTANCE, ORDER_ID
 --  Calls XNP_STANDARD.SMS_DELETE_PORTED_NUMBER
 ------------------------------------------------------------------
PROCEDURE SMS_DELETE_PORTED_NUMBER
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT  OUT NOCOPY VARCHAR2
 )
IS
l_WORKITEM_INSTANCE_ID     NUMBER;
l_error_code               NUMBER := 0;
l_error_message            VARCHAR2(2000);
x_progress                 VARCHAR2(2000);
e_SMS_DELETE_PORTED_NUMBER EXCEPTION;

BEGIN

  --
  -- Call SET_SDP_CTX to set values for WI_ID and ORDER_ID
  --
  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_WI'
   ,RESULTOUT
   );

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    XNP_STANDARD.SMS_DELETE_PORTED_NUMBER
     (l_WORKITEM_INSTANCE_ID
     ,l_error_code
     ,l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SMS_DELETE_PORTED_NUMBER;
    END IF;
    -- Completion
    resultout := 'COMPLETE';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------
      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SMS_DELETE_PORTED_NUMBER'
       ,P_MSG_NAME             => 'SMS_DELETE_PORTED_NUMBER_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );

      RAISE;

END SMS_DELETE_PORTED_NUMBER;

 --------------------------------------------------------------------
 -- Called when: response to OMS's portin req to peer +B1
 -- Description:
 --  Gets the Item Attributes WORKITEM_INSTANCE, ORDER_ID
 --  Calls XNP_STANDARD.SOA_UPDATE_CUTOFF_DATE
 ------------------------------------------------------------------
PROCEDURE SOA_UPDATE_CUTOFF_DATE
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_ORDER_ID                 NUMBER;
l_LINEITEM_ID              NUMBER;
l_WORKITEM_INSTANCE_ID     NUMBER;
l_FA_INSTANCE_ID           NUMBER;
l_error_code               NUMBER := 0;
l_error_message            VARCHAR2(2000);
l_STATUS_CHANGE_CAUSE_CODE VARCHAR2(512);
l_NEW_STATUS_TYPE_CODE     VARCHAR2(80);
l_CUR_STATUS_TYPE_CODE     VARCHAR2(80);
x_progress                 VARCHAR2(2000);
e_SOA_UPDATE_CUTOFF_DATE   EXCEPTION;

BEGIN

  --
  -- Call SET_SDP_CTX to set values for WI_ID and ORDER_ID
  --
  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_ORD_WI'
   ,RESULTOUT
   );

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

  l_ORDER_ID             := g_ORDER_ID;
  l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID ;

    l_CUR_STATUS_TYPE_CODE :=
      wf_engine.GetActivityAttrText (itemtype => itemtype,
      itemkey  => itemkey,
      actid => actid,
      aname   => 'CUR_STATUS_TYPE_CODE');

    XNP_STANDARD.SOA_UPDATE_CUTOFF_DATE
     (l_ORDER_ID ,
      L_LINEITEM_ID,
      l_WORKITEM_INSTANCE_ID,
      l_FA_INSTANCE_ID,
      l_CUR_STATUS_TYPE_CODE,
      l_error_code,
      l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SOA_UPDATE_CUTOFF_DATE;
    END IF;
    -- Completion
    resultout := 'COMPLETE';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------

      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SOA_UPDATE_CUTOFF_DATE'
       ,P_MSG_NAME             => 'SOA_UPDATE_CUTOFF_DATE_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );

      RAISE;
END SOA_UPDATE_CUTOFF_DATE;


 ------------------------------------------------------------------
 -- Called when: When there is a Porting Order from OMS
 --  and the
 -- Description:
 --  Gets the Item Attributes WORKITEM_INSTANCE, ORDER_ID
 --  Calls XNP_STANDARD.SOA_CREATE_PORTING_ORDER
 ------------------------------------------------------------------
PROCEDURE SOA_CREATE_PORTING_ORDER
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_ORDER_ID                 NUMBER;
l_LINEITEM_ID              NUMBER;
l_WORKITEM_INSTANCE_ID     NUMBER;
l_FA_INSTANCE_ID           NUMBER;
l_error_code               NUMBER := 0;
l_error_message            VARCHAR2(2000);
l_SP_ROLE                  VARCHAR2(80);
x_progress                 VARCHAR2(2000);
e_SOA_CREATE_PORTING_ORDER EXCEPTION;

BEGIN
  --
  -- Call SET_SDP_CTX to set values for WI_ID and ORDER_ID
  --
  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_ORD_WI'
   ,RESULTOUT
   );

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

  l_ORDER_ID             := g_ORDER_ID;
  l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID ;

    -- Get the context this workflow is operating in
    -- i.e. DONOR or RECIPIENT
    l_SP_ROLE :=
      wf_engine.GetActivityAttrText (itemtype => itemtype,
      itemkey  => itemkey,
      actid => actid,
      aname   => 'SP_ROLE');
    IF (l_sp_role IS NULL) THEN
      raise e_SOA_CREATE_PORTING_ORDER;
    END IF;

    XNP_STANDARD.SOA_CREATE_PORTING_ORDER
     (l_ORDER_ID,
      l_LINEITEM_ID,
      l_WORKITEM_INSTANCE_ID,
      l_FA_INSTANCE_ID,
      l_SP_ROLE,
      l_error_code,
      l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SOA_CREATE_PORTING_ORDER;
    END IF;
    -- Completion
    resultout := 'COMPLETE';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SOA_CREATE_PORTING_ORDER'
       ,P_MSG_NAME             => 'SOA_CREATE_PORTING_ORDER_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );

      RAISE;
END SOA_CREATE_PORTING_ORDER;


 ------------------------------------------------------------------
 -- Called when: need to update the SV status according
 --   to the activity parameter SV_STATUS
 -- Description:
 --  Gets the Item Attributes WORKITEM_INSTANCE, ORDER_ID
 --  Calls XNP_STANDARD.SOA_UPDATE_SV_STATUS
 ------------------------------------------------------------------
PROCEDURE SOA_UPDATE_SV_STATUS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_ORDER_ID                 NUMBER;
l_LINEITEM_ID              NUMBER;
l_WORKITEM_INSTANCE_ID     NUMBER;
l_FA_INSTANCE_ID           NUMBER;
l_NEW_STATUS_TYPE_CODE     VARCHAR2(40);
--l_CUR_STATUS_TYPE_CODE   VARCHAR2(40);
l_STATUS_CHANGE_CAUSE_CODE VARCHAR2(40);
l_error_code               NUMBER := 0;
l_error_message            VARCHAR2(2000);
x_progress                 VARCHAR2(2000);
e_SOA_UPDATE_SV_STATUS     EXCEPTION;

BEGIN

  --
  -- Call SET_SDP_CTX to set values for WI_ID and ORDER_ID
  --

  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_ORD_WI'
   ,RESULTOUT
   );

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

  l_ORDER_ID             := g_ORDER_ID;
  l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID ;

    l_NEW_STATUS_TYPE_CODE :=
      wf_engine.GetActivityAttrText (itemtype => itemtype,
      itemkey  => itemkey,
      actid => actid,
      aname   => 'NEW_STATUS_TYPE_CODE');

    l_STATUS_CHANGE_CAUSE_CODE :=
      wf_engine.GetActivityAttrText (itemtype => itemtype,
      itemkey  => itemkey,
      actid => actid,
      aname   => 'STATUS_CHANGE_CAUSE_CODE');

    XNP_STANDARD.SOA_UPDATE_SV_STATUS
     (p_ORDER_ID                 => l_ORDER_ID ,
      p_LINEITEM_ID              => l_LINEITEM_ID,
      p_WORKITEM_INSTANCE_ID     => l_WORKITEM_INSTANCE_ID,
      p_FA_INSTANCE_ID           => l_FA_INSTANCE_ID,
      p_NEW_STATUS_TYPE_CODE     => l_NEW_STATUS_TYPE_CODE,
      p_STATUS_CHANGE_CAUSE_CODE => l_STATUS_CHANGE_CAUSE_CODE,
      x_ERROR_CODE               => l_error_code,
      x_ERROR_MESSAGE            => l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SOA_UPDATE_SV_STATUS;
    END IF;
    -- Completion
    resultout := 'COMPLETE';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SOA_UPDATE_SV_STATUS'
       ,P_MSG_NAME             => 'SOA_UPDATE_SV_STATUS_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );

      RAISE;
END SOA_UPDATE_SV_STATUS;


 --------------------------------------------------------------------
 -- Called when: donor needs to check if initial donor
 --   for the TN range
 -- Description:
 --  Gets the Item Attributes WORKITEM_INSTANCE, ORDER_ID
 --  Calls XNP_STANDARD.SOA_CHECK_IF_INITIAL_DONOR
 --  Sets the RESULTOUT based on the result
 ------------------------------------------------------------------
PROCEDURE DETERMINE_SP_ROLE
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_WORKITEM_INSTANCE_ID NUMBER;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
l_check_status VARCHAR2(1);
l_SP_ROLE VARCHAR2(80);
x_progress VARCHAR2(2000);
e_DETERMINE_SP_ROLE EXCEPTION;
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_WI'
   ,RESULTOUT
   );

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID ;

    -- Check to see if initial donor

    XNP_STANDARD.DETERMINE_SP_ROLE
     (l_WORKITEM_INSTANCE_ID
     ,l_SP_ROLE
     ,l_error_code
     ,l_error_message
     );

    IF l_error_code <> 0
    THEN
      raise e_DETERMINE_SP_ROLE;
    END IF;

    -- Completion: with sp role
    -- role could be DONOR, ORIG_DONOR or RECIPIENT
    resultout := 'COMPLETE:'||l_SP_ROLE;
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'DETERMINE_SP_ROLE'
       ,P_MSG_NAME => 'DETERMINE_SP_ROLE_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );

      RAISE;
END DETERMINE_SP_ROLE;


PROCEDURE SUBSCRIBE_FOR_EVENT
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS

l_WORKITEM_INSTANCE_ID NUMBER;
l_ORDER_ID NUMBER;
--l_FA_INSTANCE_ID NUMBER := 0;
l_FA_INSTANCE_ID NUMBER := NULL;
l_error_code NUMBER := 0;
l_REFERENCE_ID NUMBER;
l_error_message VARCHAR2(2000);
l_MESSAGE_TYPE VARCHAR2(80);
l_CALLBACK_REF_ID VARCHAR2(1024);
l_activity_name VARCHAR2(80);
l_tmp_callback_ref_id VARCHAR2(2000) := NULL;
l_process_reference VARCHAR2(2000);
x_progress VARCHAR2(2000);
e_SUBSCRIBE_FOR_EVENT EXCEPTION;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

--
-- THE ABOVE LINE IS WRAPPED INTO A EXCEPTION BLOCK AS SHOW BELOW IN CASE
-- THE CALLER WORKITEM TYPE DOES NOT HAVE TO HAVE ITEM ATTRIBUTE WORKITEM_INSTANCE_ID
--

    BEGIN


     SET_SDP_CONTEXT
      (ITEMTYPE
      ,ITEMKEY
      ,ACTID
      ,'SET_ORD_WI'
      ,RESULTOUT
      );

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;
    l_ORDER_ID             := g_ORDER_ID;

    EXCEPTION
    WHEN OTHERS THEN
       l_WORKITEM_INSTANCE_ID := NULL;
       wf_core.clear;
    END;

    BEGIN

     SET_SDP_CONTEXT
      (ITEMTYPE
      ,ITEMKEY
      ,ACTID
      ,'SET_FA'
      ,RESULTOUT
      );

    l_FA_INSTANCE_ID := g_FA_INSTANCE_ID;

    EXCEPTION
    WHEN OTHERS THEN
       l_FA_INSTANCE_ID := NULL;
       wf_core.clear;
    END;

     -- Get the callback reference id

     XNP_UTILS.CHECK_TO_GET_REF_ID
     (p_itemtype       => itemtype
     ,p_itemkey        => itemkey
     ,p_actid          => actid
     ,p_workitem_instance_id => l_workitem_instance_id
     ,x_reference_id  => l_callback_ref_id
     );

-- If the Reference_ID is null make it -1

     if l_callback_ref_id is null then
	l_callback_ref_id := -1;
     end if;

     l_MESSAGE_TYPE :=
     wf_engine.GetActivityAttrText
       (itemtype => itemtype
       ,itemkey  => itemkey
       ,actid => actid
       ,aname   => 'EVENT_TYPE'
       );

    l_ACTIVITY_NAME := wf_engine.GETACTIVITYLABEL(actid);
    l_PROCESS_REFERENCE :=
      itemtype||':'||itemkey||':'||l_activity_name;

     ------------------------------------------------------------------
	-- Subscribe for this event
     ------------------------------------------------------------------
    XNP_STANDARD.SUBSCRIBE_FOR_EVENT
     (p_MESSAGE_TYPE=>l_MESSAGE_TYPE
     ,p_WORKITEM_INSTANCE_ID=>l_WORKITEM_INSTANCE_ID
     ,p_CALLBACK_REF_ID=>l_CALLBACK_REF_ID
     ,p_PROCESS_REFERENCE=>l_PROCESS_REFERENCE
     ,p_ORDER_ID=>l_ORDER_ID
     ,p_FA_INSTANCE_ID=>l_FA_INSTANCE_ID
     ,x_ERROR_CODE=>l_ERROR_CODE
     ,x_ERROR_MESSAGE=>l_ERROR_MESSAGE
     );

    IF l_error_code <> 0
    THEN
      raise e_SUBSCRIBE_FOR_EVENT;
    END IF;
     -- Completion
     -- Once Publish is ready
     resultout := 'NOTIFIED';
     RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'SUBSCRIBE_FOR_EVENT'
       ,P_MSG_NAME => 'SUBSCRIBE_FOR_EVENT_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );

      RAISE;
END SUBSCRIBE_FOR_EVENT;


 ------------------------------------------------------------------
 -- Registers for Acks corr to sent message
 -- Calls XNP_STANDARD SUBSCRIBE_FOR_ACKS
 ------------------------------------------------------------------
PROCEDURE SUBSCRIBE_FOR_ACKS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_WORKITEM_INSTANCE_ID NUMBER;
l_ORDER_ID NUMBER;
l_FA_INSTANCE_ID NUMBER;
l_REFERENCE_ID NUMBER;
l_EVENT_TYPE VARCHAR2(80);
l_tmp NUMBER := 0;
l_CALLBACK_REF_ID VARCHAR2(1024) := NULL;
l_activity_name VARCHAR2(80);
l_process_reference VARCHAR2(2000);
x_progress VARCHAR2(2000);
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
e_SUBSCRIBE_FOR_ACKS EXCEPTION;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code


     SET_SDP_CONTEXT
      (ITEMTYPE
      ,ITEMKEY
      ,ACTID
      ,'SET_ORD_WI'
      ,RESULTOUT
      );

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;
    l_ORDER_ID             := g_ORDER_ID;

    BEGIN

     SET_SDP_CONTEXT
      (ITEMTYPE
      ,ITEMKEY
      ,ACTID
      ,'SET_FA'
      ,RESULTOUT
      );

    l_FA_INSTANCE_ID := g_FA_INSTANCE_ID;

    EXCEPTION
    WHEN OTHERS THEN
      l_FA_INSTANCE_ID := NULL;
      wf_core.clear;
    END;

    -- Get the callback reference id
     XNP_UTILS.CHECK_TO_GET_REF_ID
     (p_itemtype       => itemtype
     ,p_itemkey        => itemkey
     ,p_actid          => actid
     ,p_workitem_instance_id => l_workitem_instance_id
     ,x_reference_id  => l_callback_ref_id
     );

-- If the Reference_ID is null make it -1

     if l_callback_ref_id is null then
	l_callback_ref_id := -1;
     end if;

     l_EVENT_TYPE :=
     wf_engine.GetActivityAttrText
       (itemtype => itemtype
       ,itemkey  => itemkey
       ,actid => actid
       ,aname   => 'EVENT_TYPE'
       );

    l_ACTIVITY_NAME := wf_engine.GETACTIVITYLABEL(actid);
    l_PROCESS_REFERENCE :=
      itemtype||':'||itemkey||':'||l_activity_name;


    XNP_EVENT.SUBSCRIBE_FOR_ACKS
    (P_MESSAGE_TYPE=>l_EVENT_TYPE
      ,P_REFERENCE_ID =>l_CALLBACK_REF_ID
      ,P_PROCESS_REFERENCE=>l_PROCESS_REFERENCE
      ,X_ERROR_CODE=>l_error_code
      ,X_ERROR_MESSAGE=>l_error_message
      ,P_ORDER_ID=>l_ORDER_ID
      ,P_WI_INSTANCE_ID=>l_WORKITEM_INSTANCE_ID
      ,P_FA_INSTANCE_ID=>l_FA_INSTANCE_ID
      );

    IF l_error_code <> 0
    THEN
      raise e_SUBSCRIBE_FOR_ACKS;
    END IF;
     -- Go to notified state to be woken up later
     resultout := 'NOTIFIED';
     RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------

      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'SUBSCRIBE_FOR_ACKS'
       ,P_MSG_NAME => 'SUBSCRIBE_FOR_ACKS_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );

      RAISE;
END SUBSCRIBE_FOR_ACKS;

 ------------------------------------------------------------------
 -- Prepares the notification to be sent to the target
 -- Uses the activity attr DOC_PROC_NAME and sets
 -- the Item Attribute DOC_REFERENCE
 ------------------------------------------------------------------
PROCEDURE PREPARE_NOTIFICATION
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_WORKITEM_INSTANCE_ID NUMBER;
l_DOC_PROC_NAME VARCHAR2(512);
l_MESSAGE_ID NUMBER;
x_progress VARCHAR2(2000);
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
e_PREPARE_NOTIFICATION EXCEPTION;
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

    l_DOC_PROC_NAME :=
      wf_engine.GetActivityAttrText
       (itemtype => itemtype
       ,itemkey  => itemkey
       ,actid => actid
       ,aname   => 'DOC_PROC_NAME'
      );

-- Modified avalue from FND_RESP534:21690 to FND_RESP535:21704, rnyberg 03/08/2002
    wf_engine.SetItemAttrText
     (itemtype => itemtype
     ,itemkey => itemkey
     ,aname => 'CUST_CARE_ADMIN'
     ,avalue => 'FND_RESP535:21704'
--     ,avalue => xdp_utilities.get_wf_notifrecipient('NP_CUST_CARE_ADMIN')
     );

-- Modified avalue from FND_RESP534:21690 to FND_RESP535:21704, rnyberg 03/08/2002
    wf_engine.SetItemAttrText
     (itemtype => itemtype
     ,itemkey => itemkey
     ,aname => 'SYS_ADMIN'
     ,avalue => 'FND_RESP535:21704'
--     ,avalue => xdp_utilities.get_wf_notifrecipient('NP_SYSADMIN')
     );

     ------------------------------------------------------------------
     -- Set the document procedure and the document id
     -- into the Item Attribute DOC_REFERENCE
     -- The document id is the WORKITEM_INSTANCE_ID
     --  or ITEMTYPE:ITEMKEY
     ------------------------------------------------------------------
    IF (l_DOC_PROC_NAME = 'SERVICE_PROCESSING_ERROR')
      OR (l_DOC_PROC_NAME = 'NO_ACK_RECEIVED')
    THEN

     l_MESSAGE_ID :=
      wf_engine.GetItemAttrNumber
       (itemtype => itemtype
       ,itemkey  => itemkey
       ,aname   => 'MSG_ID'
      );

     wf_engine.SetItemAttrText
       (itemtype => itemtype
       ,itemkey => itemkey
       ,aname => 'DOC_REFERENCE'
       ,avalue => 'PLSQL:XNP_DOCUMENTS.'||l_DOC_PROC_NAME
                  ||'/'||to_char(l_MESSAGE_ID)
       );
    ELSE


     SET_SDP_CONTEXT
      (ITEMTYPE
      ,ITEMKEY
      ,ACTID
      ,'SET_WI'
      ,RESULTOUT
      );

     l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

     wf_engine.SetItemAttrText
       (itemtype => itemtype
       ,itemkey => itemkey
       ,aname => 'DOC_REFERENCE'
       ,avalue => 'PLSQL:XNP_DOCUMENTS.'||l_DOC_PROC_NAME
                  ||'/'||to_char(l_WORKITEM_INSTANCE_ID)
       );
    END IF;

    resultout := 'COMPLETE';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------

      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'PREPARE_NOTIFICATION'
       ,P_MSG_NAME => 'PREPARE_NOTIFICATION_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );


      RAISE;

END PREPARE_NOTIFICATION;

 --------------------------------------------------------------------
 --
 -- Called when: FA execution to talk to a network element is
 --  to be done
 -- Description:
 --  Gets the Item Attributes WORKITEM_INSTANCE, ORDER_ID
 --  Given the FA name as an activity parameter, it gets the
 --    correct FA procedure to be called and executes it
 --    dynamically
 ------------------------------------------------------------------
PROCEDURE EXECUTE_FA
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_FA_NAME VARCHAR2(200);
l_WORKITEM_INSTANCE_ID NUMBER;
l_ORDER_ID NUMBER;
l_FA_INSTANCE NUMBER := NULL;
l_ERROR_CODE NUMBER := 0;
l_ERROR_MESSAGE VARCHAR2(2000);
--l_FA_INSTANCE_ID NUMBER := 0;
l_FA_INSTANCE_ID NUMBER := NULL;
l_FE_NAME VARCHAR2(80) := NULL;
l_activity_name VARCHAR2(2000);
l_process_reference VARCHAR2(2000);
e_EXECUTE_FA EXCEPTION;
x_progress VARCHAR2(2000);

BEGIN

  -- Get the fa name to be used
  l_error_code := 0;
  l_error_message := 'SUCCESS';

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code


    SET_SDP_CONTEXT
     (ITEMTYPE
     ,ITEMKEY
     ,ACTID
     ,'SET_ORD_WI'
     ,RESULTOUT
     );

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;
    l_ORDER_ID             := g_ORDER_ID ;


     l_FA_NAME :=
     wf_engine.GetActivityAttrText
       (itemtype => itemtype
       ,itemkey  => itemkey
       ,actid => actid
       ,aname   => 'FA_NAME'
       );

     -- Get the FE NAME to provision
     l_FE_NAME :=
     wf_engine.GetActivityAttrText
       (itemtype => itemtype
       ,itemkey  => itemkey
       ,actid => actid
       ,aname   => 'FE_NAME'
       );

     ------------------------------------------------------------------
     -- Add the FA to the workitem and get the FA instance id
     ------------------------------------------------------------------

    l_FA_INSTANCE_ID       := XDP_ENG_UTIL.ADD_FA_TOWI(l_WORKITEM_INSTANCE_ID,
                                                       l_FA_NAME,
                                                       l_FE_NAME);

     XDP_ENG_UTIL.EXECUTE_FA
     (l_ORDER_ID
     ,l_WORKITEM_INSTANCE_ID
     ,l_FA_INSTANCE_ID
     ,itemtype
     ,itemkey
     ,l_ERROR_CODE
     ,l_ERROR_MESSAGE
     );

    IF l_error_code <> 0
    THEN
      raise e_EXECUTE_FA;
    END IF;

    -- SUBSCRIBE for FA_DONE
    -- with the FA_INSTANCE_ID
    -- and let SFM resume workflow

    l_ACTIVITY_NAME := wf_engine.GETACTIVITYLABEL(actid);
    l_PROCESS_REFERENCE :=
      itemtype||':'||itemkey||':'||l_ACTIVITY_NAME;

    XNP_EVENT.SUBSCRIBE
        (P_MSG_CODE=>'FA_DONE'   -- Message type to expected
        ,P_REFERENCE_ID=>l_FA_INSTANCE_ID -- Reference id
        ,P_PROCESS_REFERENCE=>l_PROCESS_REFERENCE -- workflow id
        ,P_PROCEDURE_NAME=>'XNP_EVENT.RESUME_WORKFLOW' -- callback proc
        ,P_CALLBACK_TYPE=>'PL/SQL' -- callback proc type
        ,P_CLOSE_REQD_FLAG => 'Y'
        ,P_ORDER_ID=>l_order_id
        ,P_WI_INSTANCE_ID=>l_workitem_instance_id
        ,P_FA_INSTANCE_ID=>l_FA_INSTANCE_ID
        );

    -- Got to Notified state until SFM wakes you up
    resultout := 'NOTIFIED';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'EXECUTE_FA'
       ,P_MSG_NAME => 'EXECUTE_FA_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );


      RAISE;

END EXECUTE_FA;

PROCEDURE EXECUTE_FA_N_SYNC_WI_PAR
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS

  l_ORDER_ID NUMBER;
  l_WORKITEM_INSTANCE_ID NUMBER;
  l_FA_NAME VARCHAR2(200);
  l_FE_NAME VARCHAR2(80) := NULL;
  l_FA_INSTANCE_ID NUMBER := NULL;
  l_param_name VARCHAR2(40);
  l_param_val  VARCHAR2(4000);
  l_ERROR_CODE NUMBER := 0;
  l_ERROR_MESSAGE VARCHAR2(2000);
  l_activity_name VARCHAR2(2000);
  l_process_reference VARCHAR2(2000);
  lv_activity_label VARCHAR2(100);
  lv_colun_pos NUMBER;


  CURSOR c_get_params (cv_wi_instance_id  NUMBER)IS
  SELECT parameter_name,  parameter_value, parameter_ref_value
    FROM xdp_worklist_details
   WHERE workitem_instance_id = cv_wi_instance_id;

  e_EXECUTE_FA EXCEPTION;
  x_progress VARCHAR2(2000);

BEGIN

  IF (funcmode = 'RUN') THEN

    l_WORKITEM_INSTANCE_ID := wf_engine.getItemAttrNumber (itemtype => EXECUTE_FA_N_SYNC_WI_PAR.itemtype,
                                                           itemkey  => EXECUTE_FA_N_SYNC_WI_PAR.itemkey,
                                                           aname    => 'WORKITEM_INSTANCE_ID');

    FOR lv_rec in c_get_params( l_WORKITEM_INSTANCE_ID ) LOOP
      l_param_name := lv_rec.parameter_name;
      l_param_val := lv_rec.parameter_value;

      BEGIN
        -- Get the data type of the item attribute..
        wf_engine.setItemAttrText(itemtype => EXECUTE_FA_N_SYNC_WI_PAR.itemtype,
                                  itemkey  => EXECUTE_FA_N_SYNC_WI_PAR.itemkey,
                                  aname    => l_param_name,
                                  avalue   => l_param_val);

      EXCEPTION
        WHEN others THEN
          -- skilaru 05/20/2002
          -- User defined workflow didnt have this item attribute defined..
          -- Kick off Default error process? or send a dynamic notification?
          RAISE;
      END;
    END LOOP;
    l_ORDER_ID := wf_engine.getItemAttrText (itemtype => EXECUTE_FA_N_SYNC_WI_PAR.itemtype,
                                             itemkey  => EXECUTE_FA_N_SYNC_WI_PAR.itemkey ,
                                             aname    => 'ORDER_ID');

    l_FA_NAME := wf_engine.getActivityAttrText (itemtype => EXECUTE_FA_N_SYNC_WI_PAR.itemtype,
                                                itemkey  => EXECUTE_FA_N_SYNC_WI_PAR.itemkey ,
                                                actid => actid,
                                                aname    => 'FA_NAME');

    l_FE_NAME := wf_engine.getActivityAttrText (itemtype => EXECUTE_FA_N_SYNC_WI_PAR.itemtype,
                                                itemkey  => EXECUTE_FA_N_SYNC_WI_PAR.itemkey,
                                                actid => actid,
                                                aname    => 'FE_NAME');


    -- Add the FA to the workitem and get the FA instance id
    l_FA_INSTANCE_ID := XDP_ENG_UTIL.ADD_FA_TOWI(l_WORKITEM_INSTANCE_ID,
                                                 l_FA_NAME,
                                                 l_FE_NAME);


    -- STEP2: Download Work Item params from workflow to the xdp_fa_details table..
    downloadFAParams( EXECUTE_FA_N_SYNC_WI_PAR.itemtype,
                      EXECUTE_FA_N_SYNC_WI_PAR.itemkey,
                      EXECUTE_FA_N_SYNC_WI_PAR.actid,
                      l_FA_INSTANCE_ID );


    XDP_ENG_UTIL.EXECUTE_FA (l_ORDER_ID,
                             l_WORKITEM_INSTANCE_ID,
                             l_FA_INSTANCE_ID,
                             EXECUTE_FA_N_SYNC_WI_PAR.itemtype,
                             EXECUTE_FA_N_SYNC_WI_PAR.itemkey,
                             l_ERROR_CODE,
                             l_ERROR_MESSAGE);

    IF l_error_code <> 0
    THEN
      raise e_EXECUTE_FA;
    END IF;

    -- SUBSCRIBE for FA_DONE
    -- with the FA_INSTANCE_ID
    -- and let SFM resume workflow

    l_ACTIVITY_NAME := wf_engine.GETACTIVITYLABEL(actid);
    l_PROCESS_REFERENCE :=
      itemtype||':'||itemkey||':'||l_ACTIVITY_NAME;

    XNP_EVENT.SUBSCRIBE
        (P_MSG_CODE=>'FA_DONE'   -- Message type to expected
        ,P_REFERENCE_ID=>l_FA_INSTANCE_ID -- Reference id
        ,P_PROCESS_REFERENCE=>l_PROCESS_REFERENCE -- workflow id
        ,P_PROCEDURE_NAME=>'XNP_EVENT.SYNC_N_RESUME_WF' -- callback proc
        ,P_CALLBACK_TYPE=>'PL/SQL' -- callback proc type
        ,P_CLOSE_REQD_FLAG => 'Y'
        ,P_ORDER_ID=>l_order_id
        ,P_WI_INSTANCE_ID=>l_workitem_instance_id
        ,P_FA_INSTANCE_ID=>l_FA_INSTANCE_ID
        );

    -- Got to Notified state until SFM wakes you up
    resultout := 'NOTIFIED';
    RETURN;
  ELSIF (funcmode = 'CANCEL' ) THEN
    resultout := 'COMPLETE';
    return;
  END IF;


  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'EXECUTE_FA'
       ,P_MSG_NAME => 'EXECUTE_FA_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );


      RAISE;

END EXECUTE_FA_N_SYNC_WI_PAR;


 --------------------------------------------------------------------
 -- Description:
 --  Gets the Item Attributes WORKITEM_INSTANCE, ORDER_ID
 --  calls XNP_STANDARD.SOA_CHECK_NOTIFY_DIR_SVS
 --  Completes the path based on the result
 ------------------------------------------------------------------
PROCEDURE SOA_CHECK_NOTIFY_DIR_SVS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
x_progress VARCHAR2(2000);
l_WORKITEM_INSTANCE_ID NUMBER;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
l_check_status VARCHAR2(1);
e_SOA_CHECK_NOTIFY_DIR_SVS EXCEPTION;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

     SET_SDP_CONTEXT
      (ITEMTYPE
      ,ITEMKEY
      ,ACTID
      ,'SET_WI'
      ,RESULTOUT
      );

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    -- Get the value of to flag

    XNP_STANDARD.SOA_CHECK_NOTIFY_DIR_SVS
     (l_WORKITEM_INSTANCE_ID
     ,l_check_status
     ,l_error_code
     ,l_error_message
     );

    IF l_error_code <> 0
    THEN
      raise e_SOA_CHECK_NOTIFY_DIR_SVS;
    END IF;

    -- Completion: If check status is true the traces
    -- the 'YES' path else trace the 'NO' path
    IF l_check_status = 'Y'
    THEN
      resultout := 'COMPLETE:Y';
    ELSE
      resultout := 'COMPLETE:N';
    END IF;

    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------

      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'SOA_CHECK_NOTIFY_DIR_SVS'
       ,P_MSG_NAME => 'SOA_CHECK_NOTIFY_DIR_SVS_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );

      RAISE;

END SOA_CHECK_NOTIFY_DIR_SVS;



 --------------------------------------------------------------------
 -- Called at: Recipient side when charging info is recd
 -- Description:
 --  Gets the Item Attributes WORKITEM_INSTANCE, ORDER_ID
 --  calls XNP_STANDARD.UPDATE_CHARGING_INFO
 ------------------------------------------------------------------
PROCEDURE SOA_UPDATE_CHARGING_INFO
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
x_progress                 VARCHAR2(2000);
l_ORDER_ID                 NUMBER;
l_LINEITEM_ID              NUMBER;
l_WORKITEM_INSTANCE_ID     NUMBER;
l_FA_INSTANCE_ID           NUMBER;
l_error_code               NUMBER := 0;
l_error_message            VARCHAR2(2000);
l_CUR_STATUS_TYPE_CODE     VARCHAR2(80);
e_UPDATE_CHARGING_INFO     EXCEPTION;

BEGIN

  --
  -- Call SET_SDP_CTX to set values for WI_ID and ORDER_ID
  --
  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_ORD_WI'
   ,RESULTOUT
   );

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

  l_ORDER_ID             := g_ORDER_ID;
  l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID ;

    -- Update the charging info
    XNP_STANDARD.SOA_UPDATE_CHARGING_INFO
     (l_ORDER_ID ,
      l_LINEITEM_ID,
      l_WORKITEM_INSTANCE_ID,
      l_FA_INSTANCE_ID,
      l_CUR_STATUS_TYPE_CODE,
      l_error_code,
      l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_UPDATE_CHARGING_INFO;
    END IF;

    resultout := 'COMPLETE';

    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SOA_UPDATE_CHARGING_INFO'
       ,P_MSG_NAME             => 'SOA_UPDATE_CHARGING_INFO_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );

      RAISE;

END SOA_UPDATE_CHARGING_INFO;

 --------------------------------------------------------------------
 -- Called during provisioning phase
 -- Description:
 --  Gets the Item Attributes WORKITEM_INSTANCE, ORDER_ID
 --  Gets Workitem parameters STARTING_NUMBER, ENDING_NUMBER
 --  For each of the FEs executes a fulfillment action
 ------------------------------------------------------------------
PROCEDURE SMS_PROVISION_NES
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
x_progress              VARCHAR2(2000);
l_ORDER_ID              NUMBER;
l_LINEITEM_ID           NUMBER;
l_WORKITEM_INSTANCE_ID  NUMBER;
l_FA_INSTANCE_ID        NUMBER := NULL;
L_ERROR_CODE            NUMBER := 0;
L_ERROR_MESSAGE         VARCHAR2(2000);
L_ACTIVITY_NAME         VARCHAR2(240):=NULL;
L_PROCESS_REFERENCE     VARCHAR2(512) := null;
l_FEATURE_TYPE          VARCHAR2(80) := NULL;
l_STARTING_NUMBER       VARCHAR2(80) := NULL;
l_ENDING_NUMBER         VARCHAR2(80) := NULL;
l_NUMBER_RANGE_ID       NUMBER := 0;
l_count                 NUMBER := 1;

CURSOR c_ALL_FEs IS
    SELECT SNR.fe_id
      FROM xnp_served_num_ranges SNR
     WHERE SNR.feature_type    = l_feature_type
       AND SNR.number_range_id = l_number_range_id;

e_SMS_PROVISION_NES EXCEPTION;

BEGIN

  --
  -- Call SET_SDP_CTX to set values for WI_ID and ORDER_ID
  --
  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_ORD_WI'
   ,RESULTOUT
   );

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

    l_ORDER_ID             := g_ORDER_ID;
    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    l_FEATURE_TYPE :=
      wf_engine.GetActivityAttrText (itemtype => itemtype,
      itemkey  => itemkey,
      actid => actid,
      aname   => 'FEATURE_TYPE');

    l_STARTING_NUMBER :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'STARTING_NUMBER'
     );

    l_ENDING_NUMBER :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'ENDING_NUMBER'
     );

    -- Determine the number range id

    XNP_CORE.GET_NUMBER_RANGE_ID
    (l_STARTING_NUMBER
    ,l_ENDING_NUMBER
    ,l_NUMBER_RANGE_ID
    ,l_ERROR_CODE
    ,l_ERROR_MESSAGE
    );

    IF l_error_code <> 0 THEN
      raise e_SMS_PROVISION_NES;
    END IF;


     ------------------------------------------------------------------
     -- Record this function call in the error
     -- Set the necessary item attributes before starting
     -- i.e. FE_NAME
     ------------------------------------------------------------------

    -- get the fe list to provision
   FOR l_tmp_fe IN c_ALL_FEs

    LOOP
     IF XDP_ENGINE.IS_FE_VALID(l_tmp_fe.fe_id) THEN

      -- Insert the FE MAP for the FE to be provisioned

      /***Changed Call to proc to solve Bug # 2104648 -- 11/21/2001 mviswana***/

      XNP_CORE.SMS_INSERT_FE_MAP
      (p_ORDER_ID              =>   l_ORDER_ID,
       p_LINEITEM_ID           =>   l_LINEITEM_ID,
       p_WORKITEM_INSTANCE_ID  =>   l_WORKITEM_INSTANCE_ID,
       p_FA_INSTANCE_ID        =>   l_FA_INSTANCE_ID,
       p_STARTING_NUMBER       =>   to_number(l_STARTING_NUMBER),
       p_ENDING_NUMBER         =>   to_number(l_ENDING_NUMBER),
       p_FE_ID                 =>   l_TMP_FE.FE_ID,
       p_FEATURE_TYPE          =>   l_FEATURE_TYPE,
       x_ERROR_CODE            =>   l_ERROR_CODE,
       x_ERROR_MESSAGE         =>   l_ERROR_MESSAGE
      );

      IF l_ERROR_CODE <> 0 THEN
        raise e_SMS_PROVISION_NES;
      END IF;

       ------------------------------------------------------------------
       -- Add the FA to the workitem and get the FA instance id
       ------------------------------------------------------------------
      l_FA_INSTANCE_ID :=
       XDP_ENG_UTIL.ADD_FA_TOWI
        (l_WORKITEM_INSTANCE_ID
        ,'PROVISION_'||l_FEATURE_TYPE    -- the FA
        ,l_TMP_FE.FE_ID
        );

      -- Call fa exection procedure

      xdp_eng_util.execute_fa
       (p_order_id          => l_order_id
       ,p_wi_instance_id    => l_workitem_instance_id
       ,p_fa_instance_id    => l_fa_instance_id
       ,p_wi_item_type      => itemtype
       ,p_wi_item_key       => itemkey
       ,p_return_code       => l_error_code
       ,p_error_description => l_error_message
       ,p_fa_caller         => 'INTERNAL'
       );

       IF l_error_code <> 0 THEN
         raise e_SMS_PROVISION_NES;
       END IF;

       -- SUBSCRIBE for FA_DONE
       -- with the FA_INSTANCE_ID
       -- and let SFM resume workflow
       -- append FEATURE_TYPE and FE_ID to the process reference
       l_PROCESS_REFERENCE :=
         itemtype||':'||itemkey||':'||'PROV:'||l_FEATURE_TYPE||':'||to_char(l_tmp_fe.FE_ID);

        XNP_EVENT.SUBSCRIBE
        (P_MSG_CODE          => 'FA_DONE'   -- Message type to expected
        ,P_REFERENCE_ID      => l_FA_INSTANCE_ID -- Reference id
        ,P_PROCESS_REFERENCE => l_PROCESS_REFERENCE -- workflow id
        ,P_PROCEDURE_NAME    => 'XNP_FA_CB.PROCESS_FA_DONE' -- callback proc
        ,P_CALLBACK_TYPE     => 'PL/SQL' -- callback proc type
        ,P_CLOSE_REQD_FLAG   =>  'Y'
        ,P_ORDER_ID          => l_order_id
        ,P_WI_INSTANCE_ID    => l_workitem_instance_id
        ,P_FA_INSTANCE_ID    => l_FA_INSTANCE_ID
        );

     ELSE null;
     END IF;

    END LOOP;


    resultout := 'COMPLETE';

    RETURN;

  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------

      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SMS_PROVISION_NES'
       ,P_MSG_NAME             => 'SMS_PROVISION_NES_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );

      RAISE;

END SMS_PROVISION_NES;


 --------------------------------------------------------------------
 -- Called when: Checks the order/inquiry response
 -- Description:
 --  calls XNP_STANDARD.SOA_CHECK_ORDER_STATUS
 --  and completes the activityn based on the result
 ------------------------------------------------------------------

PROCEDURE SOA_CHECK_ORDER_STATUS
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
x_progress VARCHAR2(2000);
l_WORKITEM_INSTANCE_ID NUMBER;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
l_ORDER_STATUS VARCHAR2(40);
e_SOA_CHECK_ORDER_STATUS EXCEPTION;
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code


       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_WI'
        ,RESULTOUT
        );

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    -- Get the order status value
    XNP_STANDARD.SOA_CHECK_ORDER_STATUS
     (l_WORKITEM_INSTANCE_ID
     ,l_ORDER_STATUS
     ,l_error_code
     ,l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SOA_CHECK_ORDER_STATUS;
    END IF;

    -- Completion: If check status is true the traces
    -- the 'YES' path else trace the 'NO' path
    IF l_ORDER_STATUS = 'Y' THEN
      resultout := 'COMPLETE:Y';
    ELSE
      resultout := 'COMPLETE:N';
    END IF;

    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'SOA_CHECK_ORDER_STATUS'
       ,P_MSG_NAME => 'SOA_CHECK_ORDER_STATUS_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );


      RAISE;

END ;

 ------------------------------------------------------------------
 -- Called to publish a single business event
 -- The recipients of this event should have
 -- already subscribed for it incase of
 -- internal events
 -- Gets the activity attribute EVENT_TYPE, PARAM_LIST
 ------------------------------------------------------------------
PROCEDURE PUBLISH_EVENT
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
 x_progress VARCHAR2(2000);
 l_WORKITEM_INSTANCE_ID NUMBER;
 l_FA_INSTANCE_ID NUMBER;
 l_ORDER_ID NUMBER;
 l_REFERENCE_ID NUMBER;
 l_EVENT_TYPE VARCHAR2(80);
 l_PARAM_LIST VARCHAR2(2000);
 l_CALLBACK_REF_ID VARCHAR2(1024);
 l_tmp_param_list VARCHAR2(2000) := NULL;
 l_tmp_callback_ref_id VARCHAR2(2000) := NULL;
 l_error_code NUMBER := 0;
 l_error_message VARCHAR2(2000);
 e_PUBLISH_EVENT EXCEPTION;
BEGIN

  --
  -- RUN mode - normal process execution
  --

  IF (funcmode = 'RUN') THEN

    -- The run code


      SET_SDP_CONTEXT
       (ITEMTYPE
       ,ITEMKEY
       ,ACTID
       ,'SET_ORD_WI'
       ,RESULTOUT
       );

    l_ORDER_ID             := g_ORDER_ID;
    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    BEGIN

      SET_SDP_CONTEXT
       (ITEMTYPE
       ,ITEMKEY
       ,ACTID
       ,'SET_FA'
       ,RESULTOUT
       );

    l_FA_INSTANCE_ID := g_FA_INSTANCE_ID;

    EXCEPTION
    WHEN OTHERS THEN
      l_FA_INSTANCE_ID := NULL;
       wf_core.clear;
    END;

    -- Get the event type to publish

    l_EVENT_TYPE :=
     wf_engine.GetActivityAttrText
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,actid => actid
      ,aname   => 'EVENT_TYPE'
      );

    -- Get the names of the parameters for PUBLISH

    l_tmp_param_list :=
     wf_engine.GetActivityAttrText
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,actid => actid
      ,aname   => 'PARAM_LIST'
      );

    l_PARAM_LIST := replace(l_tmp_param_list,' ','');


    -- Get the callback reference id

    XNP_UTILS.CHECK_TO_GET_REF_ID
    (p_itemtype       => itemtype
    ,p_itemkey        => itemkey
    ,p_actid          => actid
    ,p_workitem_instance_id => l_workitem_instance_id
    ,x_reference_id  => l_callback_ref_id
    );

-- If the Reference_ID is null make it -1

     if l_callback_ref_id is null then
	l_callback_ref_id := -1;
     end if;

    -- Invoke publish event

    XNP_STANDARD.PUBLISH_EVENT
     (p_ORDER_ID => l_ORDER_ID
     ,p_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
     ,p_FA_INSTANCE_ID => l_FA_INSTANCE_ID
     ,p_EVENT_TYPE => l_EVENT_TYPE
     ,p_PARAM_LIST => l_PARAM_LIST
     ,p_CALLBACK_REF_ID => l_CALLBACK_REF_ID
     ,x_error_code => l_error_code
     ,x_error_message => l_error_message
     );

    IF l_error_code <> 0
    THEN
      raise e_PUBLISH_EVENT;
    END IF;

    resultout := 'COMPLETE';

    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------



      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'PUBLISH_EVENT'
       ,P_MSG_NAME => 'PUBLISH_EVENT_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );


      RAISE;

END PUBLISH_EVENT;



 --------------------------------------------------------------------
 -- Checks if the records in the given status
 --  and if 'Y' then completes the 'YES' path
 --  else completes the 'NO' path
 --
 ------------------------------------------------------------------
PROCEDURE CHECK_SOA_STATUS_EXISTS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )

IS
x_progress VARCHAR2(2000);
l_WORKITEM_INSTANCE_ID NUMBER;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
l_CHECK_STATUS VARCHAR2(5);
l_STATUS_TYPE_CODE VARCHAR2(80);
e_CHECK_SOA_STATUS_EXISTS EXCEPTION;
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

      SET_SDP_CONTEXT
       (ITEMTYPE
       ,ITEMKEY
       ,ACTID
       ,'SET_WI'
       ,RESULTOUT
       );

    -- The run code

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    l_STATUS_TYPE_CODE :=
      wf_engine.GetActivityAttrText (itemtype => itemtype,
      itemkey  => itemkey,
      actid => actid,
      aname   => 'STATUS_TYPE_CODE');

    -- Get the order status value
    XNP_STANDARD.CHECK_SOA_STATUS_EXISTS
     (l_WORKITEM_INSTANCE_ID
     ,l_STATUS_TYPE_CODE
     ,l_CHECK_STATUS
     ,l_error_code
     ,l_error_message
     );

    IF l_error_code <> 0
    THEN
      raise e_CHECK_SOA_STATUS_EXISTS;
    END IF;

    -- Completion: If check status is true the traces
    -- the 'YES' path else trace the 'NO' path
    IF l_CHECK_STATUS = 'Y'
    THEN
      resultout := 'COMPLETE:Y';
    ELSE
      resultout := 'COMPLETE:N';
    END IF;

    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'CHECK_SOA_STATUS_EXISTS'
       ,P_MSG_NAME => 'CHECK_SOA_STATUS_EXISTS_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );


      RAISE;

END CHECK_SOA_STATUS_EXISTS;

 --------------------------------------------------------------------
 -- Sets the ORDER_RESULT to the value passed
 -- in the activity attribute ORDER_STATUS
 -- This value will be embeded in the message
 -- sent to the other side to drive the workflow
 ------------------------------------------------------------------
PROCEDURE SET_ORDER_RESULT
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
x_progress VARCHAR2(2000);
l_WORKITEM_INSTANCE_ID NUMBER;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
l_ORDER_STATUS VARCHAR2(80) := NULL; -- SUCCESS or FAILURE
l_STATUS_TYPE_CODE VARCHAR2(80) := NULL;
l_ORDER_REJECT_CODE VARCHAR2(80) := NULL;
l_ORDER_REJECT_EXPLN VARCHAR2(512) := NULL;
e_SET_ORDER_RESULT EXCEPTION;
BEGIN

  --
  -- Call SET_SDP_CTX to set values for WI_ID and ORDER_ID
  --
  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_ORD_WI'
   ,RESULTOUT
   );

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;
    l_ORDER_STATUS         := g_ORDER_ID;


    -- Set the order result value
    XNP_STANDARD.SET_ORDER_RESULT
     (l_WORKITEM_INSTANCE_ID
     ,l_ORDER_STATUS
     ,l_ORDER_REJECT_CODE
     ,l_ORDER_REJECT_EXPLN
     ,l_error_code
     ,l_error_message
     );

    IF l_error_code <> 0
    THEN
      raise e_SET_ORDER_RESULT;
    END IF;

    resultout := 'COMPLETE';

    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------

      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'SET_ORDER_RESULT'
       ,P_MSG_NAME => 'SET_ORDER_RESULT_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );


      RAISE;

END SET_ORDER_RESULT;

 --------------------------------------------------------------------
 -- Checks if this is a subsequent porting
 -- request and returns Y/N accordingly
 ------------------------------------------------------------------
PROCEDURE SOA_IS_SUBSEQUENT_PORT
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
x_progress VARCHAR2(2000);
l_WORKITEM_INSTANCE_ID NUMBER;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
l_CHECK_STATUS VARCHAR2(5);
l_STATUS_TYPE_CODE VARCHAR2(80);
e_SOA_IS_SUBSEQUENT_PORT EXCEPTION;
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

      SET_SDP_CONTEXT
       (ITEMTYPE
       ,ITEMKEY
       ,ACTID
       ,'SET_WI'
       ,RESULTOUT
       );

    -- The run code

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    XNP_STANDARD.SOA_IS_SUBSEQUENT_PORT
     (l_WORKITEM_INSTANCE_ID
     ,l_CHECK_STATUS
     ,l_error_code
     ,l_error_message
     );

    IF l_CHECK_STATUS = 'Y' THEN
      resultout := 'COMPLETE:Y';
    ELSE
      resultout := 'COMPLETE:N';
    END IF;

    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'SOA_IS_SUBSEQUENT_PORT'
       ,P_MSG_NAME => 'SOA_IS_SUBSEQUENT_PORT_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );


      RAISE;

END SOA_IS_SUBSEQUENT_PORT;

PROCEDURE SEND_MESSAGE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
 x_progress VARCHAR2(2000);
-- l_WORKITEM_INSTANCE_ID NUMBER := 0;
 l_WORKITEM_INSTANCE_ID NUMBER := NULL;
--l_FA_INSTANCE_ID NUMBER := 0;
 l_FA_INSTANCE_ID NUMBER := NULL;
 l_PORTING_ID VARCHAR2(80) := 0;
 l_ORDER_ID NUMBER;
 l_REFERENCE_ID NUMBER;
 l_EVENT_TYPE VARCHAR2(80);
 l_PARAM_LIST VARCHAR2(1024);
 l_CONSUMER VARCHAR2(512) := NULL;
 l_RECEIVER VARCHAR2(512) := NULL;
 l_CALLBACK_REF_ID VARCHAR2(80) := NULL;
 l_CALLBACK_REF_ID_NAME VARCHAR2(80) := NULL;
 l_VERSION NUMBER := 1;
 l_error_code NUMBER := 0;
 l_error_message VARCHAR2(2000);
 l_ACTIVITY_LABEL VARCHAR2(2000) := NULL;
 l_PROCESS_REFERENCE VARCHAR2(2000) := NULL;
 l_str          VARCHAR2(2000) := NULL;
 l_start_pos    NUMBER  := 0;
 l_end_pos      NUMBER := 0;
 l_version_label VARCHAR2(200) := NULL;
 l_tmp_param_list VARCHAR2(2000) := NULL;
 l_tmp_callback_ref_id VARCHAR2(2000) := NULL;
 l_tmp NUMBER := 0;
 e_SEND_MESSAGE EXCEPTION;
BEGIN

  --
  -- RUN mode - normal process execution
  --

  IF (funcmode = 'RUN') THEN

    -- The run code


       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_ORD_WI'
        ,RESULTOUT
        );

    l_ORDER_ID             := g_ORDER_ID ;
    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID ;

    BEGIN

      SET_SDP_CONTEXT
       (ITEMTYPE
       ,ITEMKEY
       ,ACTID
       ,'SET_FA'
       ,RESULTOUT
       );

    l_FA_INSTANCE_ID := g_FA_INSTANCE_ID;

    EXCEPTION
     WHEN OTHERS THEN
       l_FA_INSTANCE_ID := NULL;
       wf_core.clear;
    END;


    -- Get the event type to publish
    l_EVENT_TYPE :=
     wf_engine.GetActivityAttrText
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,actid => actid
      ,aname   => 'EVENT_TYPE'
      );

    -- Get the names of the parameters for SEND_MESSAGE
    l_tmp_param_list :=
     wf_engine.GetActivityAttrText
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,actid => actid
      ,aname   => 'PARAM_LIST'
      );

    l_PARAM_LIST := replace(l_tmp_param_list,' ','');

    l_CONSUMER :=
     wf_engine.GetActivityAttrText
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,actid => actid
      ,aname   => 'CONSUMER'
      );

    l_RECEIVER :=
     wf_engine.GetActivityAttrText
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,actid => actid
      ,aname   => 'RECEIVER'
      );

    l_ACTIVITY_LABEL := wf_engine.GETACTIVITYLABEL(actid);


    -- Create a name for the version label
    l_version_label := l_ACTIVITY_LABEL;

    l_start_pos := l_end_pos + 1;
    l_end_pos := INSTR(l_ACTIVITY_LABEL, ':',l_start_pos,1);

    l_start_pos := l_end_pos + 1;
    l_end_pos := LENGTH(l_ACTIVITY_LABEL) + 1;

    l_version_label := SUBSTR
         (l_ACTIVITY_LABEL
         , l_start_pos
         , (l_end_pos - l_start_pos));


    -- Check if the version number is present else add
    BEGIN

    l_VERSION :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => l_version_label||'_VER'
      );

    EXCEPTION
      WHEN OTHERS THEN
      -- Item attr doesn't exist yet, so create it
      IF ( WF_CORE.ERROR_NAME = 'WFENG_ITEM_ATTR')
      THEN

        -- Clear the error buffers
        wf_core.clear;

        WF_ENGINE.AddItemAttr
         (itemtype => itemtype
         ,itemkey  => itemkey
         ,aname   => l_version_label||'_VER'
         );

        l_VERSION := 1; -- Initializing

        -- Set the value
        wf_engine.SetItemAttrNumber
        (itemtype => itemtype
        ,itemkey => itemkey
        ,aname => l_version_label||'_VER'
        ,avalue => l_VERSION
        );
        wf_core.clear;
      ELSE
        RAISE;
      END IF;
    END;

    -- Get the callback reference id
    XNP_UTILS.CHECK_TO_GET_REF_ID
    (p_itemtype       => itemtype
    ,p_itemkey        => itemkey
    ,p_actid          => actid
    ,p_workitem_instance_id => l_workitem_instance_id
    ,x_reference_id  => l_callback_ref_id
    );

-- If the Reference_ID is null make it -1

     if l_callback_ref_id is null then
	l_callback_ref_id := -1;
     end if;

     ------------------------------------------------------------------
     -- If send succeedes then increment version number
     ------------------------------------------------------------------
    XNP_STANDARD.SEND_MESSAGE
     (l_ORDER_ID
     ,l_WORKITEM_INSTANCE_ID
     ,l_FA_INSTANCE_ID
     ,l_EVENT_TYPE
     ,l_PARAM_LIST
     ,l_CALLBACK_REF_ID  -- Reference id
     ,l_CONSUMER
     ,l_RECEIVER
     ,l_VERSION
     ,l_error_code
     ,l_error_message
     );

    IF l_error_code <> 0
    THEN
        raise e_SEND_MESSAGE;
    ELSE
      -- Increment the version number and set it
      l_VERSION := l_VERSION + 1;
      wf_engine.SetItemAttrNumber
       (itemtype => itemtype
       ,itemkey => itemkey
       ,aname => l_version_label||'_VER'
       ,avalue => l_VERSION
       );
    END IF;

    resultout := 'COMPLETE';

    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION

    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------



      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'SEND_MESSAGE'
       ,P_MSG_NAME => 'SEND_MESSAGE_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );


      RAISE;

END SEND_MESSAGE;


 --------------------------------------------------------------------
 -- Called during deprovisioning phase
 --
 -- Description:
 --  Gets the Item Attributes WORKITEM_INSTANCE, ORDER_ID
 --  Gets the Activity Attribute FEATURE_TYPE
 --  Gets the workitem parameters STARTING_NUMBER, ENDING_NUMBER
 --  For each of the FEs executes and FA and subscribes for FA_DONE
 ------------------------------------------------------------------
PROCEDURE SMS_DEPROVISION_NES
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
x_progress VARCHAR2(2000);
l_FEATURE_TYPE VARCHAR2(80) := NULL;
--l_FA_INSTANCE_ID NUMBER := 0;
l_FA_INSTANCE_ID NUMBER := NULL;
l_process_reference varchar2(512) := null;
l_activity_name varchar2(240) := null;
l_ORDER_ID NUMBER;
l_WORKITEM_INSTANCE_ID NUMBER;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
l_STARTING_NUMBER VARCHAR2(80) := NULL;
l_FE_NAME VARCHAR2(200) := NULL;
l_ENDING_NUMBER VARCHAR2(80) := NULL;

CURSOR c_ALL_FEs IS
 SELECT FE_ID
 FROM XNP_SV_SMS_FE_MAPS
 WHERE SV_SMS_ID  IN
 (SELECT SV_SMS_ID FROM XNP_SV_SMS
 WHERE SUBSCRIPTION_TN
 BETWEEN l_STARTING_NUMBER AND l_ENDING_NUMBER
 )
 AND FEATURE_TYPE=l_FEATURE_TYPE
 ;

e_SMS_DEPROVISION_NES EXCEPTION;

BEGIN

  --
  -- Call SET_SDP_CTX to set values for WI_ID and ORDER_ID
  --
  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_ORD_WI'
   ,RESULTOUT
   );

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

    l_ORDER_ID             := g_ORDER_ID;
    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    l_FEATURE_TYPE :=
     wf_engine.GetActivityAttrText
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,actid => actid
      ,aname   => 'FEATURE_TYPE'
      );

    l_STARTING_NUMBER :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'STARTING_NUMBER'
     );

    l_ENDING_NUMBER :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'ENDING_NUMBER'
     );


     ------------------------------------------------------------------
     -- For each of the fe execute an FA
     -- for the deprovisioning and subscribe for FA_DONE
     ------------------------------------------------------------------

    FOR l_tmp_fe IN c_ALL_FEs LOOP

/*****
      XNP_UTILS.GET_FE_NAME
       (p_FE_ID=>l_TMP_FE.FE_ID
       ,x_FE_NAME=>l_FE_NAME
       ,x_ERROR_CODE=>l_ERROR_CODE
       ,x_ERROR_MESSAGE=>l_ERROR_MESSAGE
       );
      IF l_error_code <> 0
      THEN
        raise e_SMS_DEPROVISION_NES;
      END IF;
****/
       ------------------------------------------------------------------
       -- Add the FA to the workitem and get the FA instance id
       ------------------------------------------------------------------
      l_FA_INSTANCE_ID :=
       XDP_ENG_UTIL.ADD_FA_TOWI
        (l_WORKITEM_INSTANCE_ID
        ,'DEPROVISION_'||l_FEATURE_TYPE    -- the FA
        ,l_tmp_fe.fe_id
        );


      -- Call fa exection procedure
      xdp_eng_util.execute_fa
       (p_order_id=>l_order_id
       ,p_wi_instance_id=>l_workitem_instance_id
       ,p_fa_instance_id=>l_fa_instance_id
       ,p_wi_item_type=>itemtype
       ,p_wi_item_key=>itemkey
       ,p_return_code=>l_error_code
       ,p_error_description=>l_error_message
       ,p_fa_caller=>'INTERNAL'
       );

       IF l_error_code <> 0
       THEN
         raise e_SMS_DEPROVISION_NES;
       END IF;

       -- SUBSCRIBE for FA_DONE
       -- with the FA_INSTANCE_ID
       -- and let SFM resume workflow
       -- append FEATURE_TYPE and FE_ID to the process reference
       l_PROCESS_REFERENCE :=
         itemtype||':'||itemkey||':'||'DEPROV:'||l_FEATURE_TYPE||':'||to_char(l_tmp_fe.FE_ID);

       XNP_EVENT.SUBSCRIBE
        (P_MSG_CODE=>'FA_DONE'   -- Message type to expected
        ,P_REFERENCE_ID=>l_FA_INSTANCE_ID -- Reference id
        ,P_PROCESS_REFERENCE=>l_PROCESS_REFERENCE -- workflow id
        ,P_PROCEDURE_NAME=>'XNP_FA_CB.PROCESS_FA_DONE' -- callback proc
        ,P_CALLBACK_TYPE=>'PL/SQL' -- callback proc type
        ,P_CLOSE_REQD_FLAG => 'Y'
        ,P_ORDER_ID=>l_order_id
        ,P_WI_INSTANCE_ID=>l_workitem_instance_id
        ,P_FA_INSTANCE_ID=>l_FA_INSTANCE_ID
        );

    END LOOP;

    resultout := 'COMPLETE';

    RETURN;

  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'SMS_DEPROVISION_NES'
       ,P_MSG_NAME => 'SMS_DEPROVISION_NES_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );

      RAISE;

END SMS_DEPROVISION_NES;

 --------------------------------------------------------------------
 -- Called when: During provisioning phase of the order
 -- Called by:
 -- Description:
 --  Deletes mapping rows from the SMS sv id and the fe id
 --   for the feature type
 --  Gets values of the item attributes workitem instance id
 --   and fe id and calls XNP_STANDARD.SMS_DELETE_FE_MAP
 ------------------------------------------------------------------
PROCEDURE SMS_DELETE_FE_MAP
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
x_progress VARCHAR2(2000);
l_WORKITEM_INSTANCE_ID NUMBER;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
l_FE_ID NUMBER;
l_FEATURE_TYPE VARCHAR2(80) := NULL;
e_SMS_DELETE_FE_MAP EXCEPTION;
BEGIN

  --
  -- Call SET_SDP_CTX to set values for WI_ID and ORDER_ID
  --
  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_WI'
   ,RESULTOUT
   );

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

    -- Get the time out duration and set at Item attribute

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    l_FE_ID :=
      wf_engine.GetItemAttrNumber (itemtype => itemtype,
      itemkey  => itemkey,
      aname   => 'FE_ID');

    l_FEATURE_TYPE :=
      wf_engine.GetActivityAttrText (itemtype => itemtype,
      itemkey  => itemkey,
      actid => actid,
      aname   => 'FEATURE_TYPE');

    -- Delete the fe map
    XNP_STANDARD.SMS_DELETE_FE_MAP
     (l_WORKITEM_INSTANCE_ID
     ,l_FE_ID
     ,l_FEATURE_TYPE
     ,l_error_code
     ,l_error_message
     );

    IF l_error_code <> 0
    THEN
      raise e_SMS_DELETE_FE_MAP;
    END IF;

    resultout := 'COMPLETE';

    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'SMS_DELETE_FE_MAP'
       ,P_MSG_NAME => 'SMS_DELETE_FE_MAP_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );

      RAISE;

END SMS_DELETE_FE_MAP;

 --------------------------------------------------------------------
 -- Description: Checks if there exists a
 --  SV for the given TN range in that phase
 --  and in for the given SP Role i.e. as donor
 --  or recipient
 --   calls XNP_STANDARD.CHECK_PHASE_FOR_ROLE
 --  Completes activity with 'Y' or 'N'
 ------------------------------------------------------------------
PROCEDURE CHECK_PHASE_FOR_ROLE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
x_progress VARCHAR2(2000);
l_CHECK_STATUS VARCHAR2(1);
l_WORKITEM_INSTANCE_ID NUMBER;
l_SP_ROLE VARCHAR2(80);
l_PHASE_INDICATOR VARCHAR2(80);
l_ERROR_CODE NUMBER := 0;
l_ERROR_MESSAGE VARCHAR2(2000);
e_CHECK_PHASE_FOR_ROLE EXCEPTION;
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

      SET_SDP_CONTEXT
       (ITEMTYPE
       ,ITEMKEY
       ,ACTID
       ,'SET_WI'
       ,RESULTOUT
       );

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID ;

    -- Get the context this workflow is operating in
    -- i.e. DONOR or RECIPIENT
    l_SP_ROLE :=
      wf_engine.GetActivityAttrText (itemtype => itemtype,
      itemkey  => itemkey,
      actid => actid,
      aname   => 'SP_ROLE');

    if (l_sp_role IS NULL) then
      raise e_CHECK_PHASE_FOR_ROLE;
    end if;

    -- Get the Phase that the SV should be in
    l_PHASE_INDICATOR :=
      wf_engine.GetActivityAttrText
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,actid => actid
      ,aname   => 'PHASE'
      );

    -- Check if an SV exists in that phase
    XNP_STANDARD.CHECK_PHASE_FOR_ROLE
     (l_WORKITEM_INSTANCE_ID
     ,l_SP_ROLE
     ,l_PHASE_INDICATOR
     ,l_CHECK_STATUS
     ,l_error_code
     ,l_error_message
     );

    IF l_error_code <> 0 THEN
      -- if error then disallow
      raise e_CHECK_PHASE_FOR_ROLE;
    END IF;


    -- Completion: If check status is 'Y'
    -- the 'YES' path else trace the 'NO' path

    IF l_check_status = 'Y' THEN
      resultout := 'COMPLETE:Y';
    ELSE
      resultout := 'COMPLETE:N';
    END IF;
    RETURN;

  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------



      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'CHECK_PHASE_FOR_ROLE'
       ,P_MSG_NAME => 'CHECK_PHASE_FOR_ROLE_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );

      RAISE;

END CHECK_PHASE_FOR_ROLE;

 ------------------------------------------------------------------
 -- Updates the status of the provisioning FE map
 -- to the given status for the given FE
 -- The value of the FE id is an item attribute
 -- and the value of the status is an activity attr
 ------------------------------------------------------------------
PROCEDURE SMS_UPDATE_FE_MAP_STATUS
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_ORDER_ID                 NUMBER;
l_LINEITEM_ID              NUMBER;
l_WORKITEM_INSTANCE_ID     NUMBER := NULL;
l_FA_INSTANCE_ID           NUMBER;
l_PROV_STATUS              VARCHAR2(80) := NULL;
l_FE_ID                    NUMBER := 0;
l_FEATURE_TYPE             VARCHAR2(80) := NULL;
e_SMS_UPDATE_FE_MAP_STATUS EXCEPTION;
X_PROGRESS                 VARCHAR2(2000);
l_ERROR_CODE               NUMBER:=0;
l_ERROR_MESSAGE            VARCHAR2(2000):=0;

BEGIN

  --
  -- Call SET_SDP_CTX to set values for WI_ID and ORDER_ID
  --
  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_ORD_WI'
   ,RESULTOUT
   );

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

    l_ORDER_ID             := g_ORDER_ID;
    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    l_FE_ID :=
      wf_engine.GetItemAttrNumber
       (itemtype => itemtype,
       itemkey  => itemkey,
       aname   => 'FE_ID'
       );

    l_FEATURE_TYPE :=
      wf_engine.GetItemAttrText
       (itemtype => itemtype,
       itemkey  => itemkey,
       aname   => 'FEATURE_TYPE'
       );

    l_PROV_STATUS :=
      wf_engine.GetActivityAttrText (itemtype => itemtype,
      itemkey  => itemkey,
      actid => actid,
      aname   => 'PROV_STATUS');

    XNP_STANDARD.SMS_UPDATE_FE_MAP_STATUS
     (l_ORDER_ID ,
      l_LINEITEM_ID,
      l_WORKITEM_INSTANCE_ID,
      l_FA_INSTANCE_ID,
      l_FEATURE_TYPE,
      l_FE_ID,
      l_PROV_STATUS,
      l_error_code,
      l_error_message
     );

    IF l_error_code <> 0
    THEN
      raise e_SMS_UPDATE_FE_MAP_STATUS;
    END IF;
    -- Completion
    resultout := 'COMPLETE';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SMS_UPDATE_FE_MAP_STATUS'
       ,P_MSG_NAME             => 'SMS_UPDATE_FE_MAP_STATUS_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                  => x_progress
       );

      RAISE;
END SMS_UPDATE_FE_MAP_STATUS;

PROCEDURE REJECT_MESSAGE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_MSG_ID NUMBER := 0;
l_COMMENT VARCHAR2(4000) := NULL;
e_REJECT_MESSAGE EXCEPTION;
x_progress VARCHAR2(2000);
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

    l_MSG_ID :=
      wf_engine.GetItemAttrNumber
       (itemtype => itemtype,
       itemkey  => itemkey,
       aname   => 'MSG_ID'
       );

    l_COMMENT :=
      wf_engine.GetItemAttrText
       (itemtype => itemtype,
       itemkey  => itemkey,
       aname   => 'COMMENT'
       );

    XNP_MESSAGE.UPDATE_STATUS
     (l_MSG_ID
     ,'REJECTED'
     ,l_COMMENT
     );

    -- Completion
    resultout := 'COMPLETE';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     --  Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------

    fnd_message.set_name('XNP','STD_ERROR');
    fnd_message.set_token(
          'ERROR_LOCN','XNP_WF_STANDARD.REJECT_MESSAGE');
        fnd_message.set_token('ERROR_TEXT',
           ':'||to_char(SQLCODE)||':'||SQLERRM);
        x_progress := fnd_message.get;
    wf_core.context(
        'XNP_WF_STANDARD'
        , 'REJECT_MESSAGE'
        ,itemtype
        , itemkey
        , to_char(actid)
        , funcmode
        ,x_progress);

      RAISE;
END REJECT_MESSAGE;


PROCEDURE RETRY_MESSAGE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_MSG_ID NUMBER := 0;
l_COMMENT VARCHAR2(4000) := NULL;
e_RETRY_MESSAGE EXCEPTION;
x_progress VARCHAR2(2000);
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

    l_MSG_ID :=
      wf_engine.GetItemAttrNumber
       (itemtype => itemtype,
       itemkey  => itemkey,
       aname   => 'MSG_ID'
       );

    XNP_MESSAGE.FIX
     (l_MSG_ID
     );

    -- Completion
    resultout := 'COMPLETE';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     --  Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------

    fnd_message.set_name('XNP','STD_ERROR');
    fnd_message.set_token(
          'ERROR_LOCN','XNP_WF_STANDARD.RETRY_MESSAGE');
        fnd_message.set_token('ERROR_TEXT',
           ':'||to_char(SQLCODE)||':'||SQLERRM);
        x_progress := fnd_message.get;
    wf_core.context(
        'XNP_WF_STANDARD'
        , 'RETRY_MESSAGE'
        ,itemtype
        , itemkey
        , to_char(actid)
        , funcmode
        ,x_progress);

      RAISE;
END RETRY_MESSAGE;


Procedure WAITFORFLOW (itemtype in varchar2,
                      itemkey in varchar2,
                      actid in number,
                      funcmode in varchar2,
                      resultout out NOCOPY  varchar2)
is
 l_ActLabel varchar2(240);
 l_ColonLoc number := 0;
 e_InvalidLabelException EXCEPTION;
BEGIN

        IF funcmode = 'RUN' THEN
          l_ActLabel := wf_engine.GetActivityLabel(actid);
          l_ColonLoc := INSTR(l_ActLabel,':');
          if l_ColonLoc > 0 then
             l_ActLabel := SUBSTR(l_ActLabel,l_ColonLoc + 1, LENGTH(l_ActLabel));

                -------------------------------------------------
		-- Call the WAITFORFLOW API
		-------------------------------------------------
             XDP_UTILITIES.WAITFORFLOW(itemtype, itemkey, l_ActLabel);

	     --Set status to notified
             resultout := 'NOTIFIED';

             return;

          elsif l_ActLabel is not null then
             null;
          else
             RAISE e_InvalidLabelException;
          end if;


        END IF;

        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'others') THEN
            resultout := 'COMPLETE';
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XNP_WF_STANDARD','WAITFORFLOW', itemtype, itemkey, to_char(actid), SUBSTR(SQLERRM,1,1500));
 raise;
END WAITFORFLOW;




Procedure CONTINUEFLOW (itemtype in varchar2,
                      itemkey in varchar2,
                      actid in number,
                      funcmode in varchar2,
                      resultout out NOCOPY  varchar2)

is
BEGIN
        IF (funcmode = 'RUN' ) THEN
           XDP_UTILITIES.CONTINUEFLOW(itemtype, itemkey);
           resultout := 'COMPLETE';
           return;
        END IF;

        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'others') THEN
            resultout := 'COMPLETE';
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XNP_WF_STANDARD','CONTINUEFLOW', itemtype, itemkey, to_char(actid), SUBSTR(SQLERRM,1,1500));
 raise;
END CONTINUEFLOW;


 --------------------------------------------------------------------
 -- Sets the Locked flag to the given value
 -- for the enties in xnp_sv_soa for the given
 -- PORTING_ID workitem paramter.
 -- Values: 'Y' or 'N'
 -- Item Attr: Gets the Item Attributes WORKITEM_INSTANCE
 -- Activity Attr : Gets the value of Activity Attribute FLAG_VALUE
 -- Workitem Paramters : PORTING_ID
 -- Calls XNP_CORE.SOA_SET_LOCKED_FLAG
 --
 ------------------------------------------------------------------
PROCEDURE SOA_SET_LOCKED_FLAG
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_ORDER_ID                 NUMBER;
l_LINEITEM_ID              NUMBER;
l_WORKITEM_INSTANCE_ID     NUMBER;
l_FA_INSTANCE_ID           NUMBER;
l_error_code               NUMBER := 0;
l_error_message            VARCHAR2(2000);
l_porting_id               VARCHAR2(80);
l_flag_value               VARCHAR2(1);
l_sp_name                  VARCHAR2(80) := null;
l_local_sp_id              NUMBER := 0;
x_progress                 VARCHAR2(2000);
e_SOA_SET_LOCKED_FLAG      EXCEPTION;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_ORD_WI'
        ,RESULTOUT
        );


    l_ORDER_ID             :=  g_WORKITEM_INSTANCE_ID;
    l_WORKITEM_INSTANCE_ID :=  g_ORDER_ID;

    l_PORTING_ID :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'PORTING_ID'
     );

    l_sp_name :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'SP_NAME'
     );

    l_flag_value :=
      wf_engine.GetActivityAttrText (itemtype => itemtype,
      itemkey  => itemkey,
      actid => actid,
      aname   => 'FLAG_VALUE');

    -- Set the locked flag

    XNP_CORE.SOA_SET_LOCKED_FLAG
     (p_order_id             => l_order_id ,
      p_lineitem_id          => l_lineitem_id,
      p_workitem_instance_id => l_workitem_instance_id,
      p_fa_instance_id       => l_fa_instance_id,
      p_porting_id           =>l_porting_id,
      p_local_sp_id          =>l_local_sp_id,
      p_locked_flag          =>l_flag_value,
      x_error_code           =>l_error_code,
      x_error_message        =>l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SOA_SET_LOCKED_FLAG;
    END IF;

    -- Completion
    resultout := 'COMPLETE';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     --  Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SOA_SET_LOCKED_FLAG'
       ,P_MSG_NAME             => 'SOA_SET_LOCKED_FLAG_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );

      RAISE;
END SOA_SET_LOCKED_FLAG;


 --------------------------------------------------------------------
 -- Gets the Locked flag for the given
 -- PORTING_ID workitem paramter.
 -- The activity is completed with the flag value
 -- Values: 'Y' or 'N'
 -- Item Attr: Gets the Item Attributes WORKITEM_INSTANCE
 -- Workitem Paramters : PORTING_ID
 -- Calls XNP_CORE.SOA_GET_LOCKED_FLAG
 --
 ------------------------------------------------------------------
PROCEDURE SOA_GET_LOCKED_FLAG
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_WORKITEM_INSTANCE_ID NUMBER;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
l_porting_id VARCHAR2(80);
l_sp_name VARCHAR2(80);
l_local_sp_id number := 0;
l_flag_value VARCHAR2(1);
x_progress VARCHAR2(2000);
e_SOA_GET_LOCKED_FLAG EXCEPTION;
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

       SET_SDP_CONTEXT
       (ITEMTYPE
       ,ITEMKEY
       ,ACTID
       ,'SET_WI'
       ,RESULTOUT
       );

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    l_PORTING_ID :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'PORTING_ID'
     );

    l_sp_name :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'SP_NAME'
     );

    -- Get the locked flag
    XNP_CORE.SOA_GET_LOCKED_FLAG
     (p_porting_id=>l_porting_id
     ,p_local_sp_id=>l_local_sp_id
     ,x_locked_flag=>l_flag_value
     ,x_error_code=>l_error_code
     ,x_error_message=>l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SOA_GET_LOCKED_FLAG;
    END IF;

    -- Completion
    resultout := 'COMPLETE:'||l_flag_value;
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     --  Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'SOA_GET_LOCKED_FLAG'
       ,P_MSG_NAME => 'SOA_GET_LOCKED_FLAG_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );

      RAISE;
END SOA_GET_LOCKED_FLAG;

 --------------------------------------------------------------------
 -- Checks if the STATUS_TYPE_CODE from xnp_sv_soa for the
 -- given PORTING_ID aka object_reference is same as
 -- given status type code (in STATUS_TO_COMPARE_WITH)
 -- Returns: 'T' if statuses match, 'F' if they don't
 -- Item Attr: Gets the Item Attributes WORKITEM_INSTANCE
 -- Activity Attribute : STATUS_TO_COMPARE_WITH
 -- Workitem Paramters : PORTING_ID
 -- Calls XNP_CORE.SOA_CHECK_SV_STATUS
 --
 ------------------------------------------------------------------
PROCEDURE SOA_CHECK_SV_STATUS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_WORKITEM_INSTANCE_ID NUMBER;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
l_porting_id VARCHAR2(80);
l_status_matched VARCHAR2(1) := 'T';
l_STATUS_TO_COMPARE_WITH VARCHAR2(80);
x_progress VARCHAR2(2000);
l_sp_name varchar2(80) := null;
l_local_sp_id number := 0;
e_SOA_CHECK_SV_STATUS EXCEPTION;
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_WI'
        ,RESULTOUT
        );

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    l_PORTING_ID :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'PORTING_ID'
     );

    l_STATUS_TO_COMPARE_WITH :=
     wf_engine.GetActivityAttrText
       (itemtype => itemtype
       ,itemkey  => itemkey
       ,actid => actid
       ,aname   => 'STATUS_TO_COMPARE_WITH'
       );


    l_sp_name :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'SP_NAME'
     );

    -- Check to see if Statuses matech
    XNP_CORE.SOA_CHECK_SV_STATUS
     (p_porting_id=>l_porting_id
     ,p_local_sp_id=>l_local_sp_id
     ,p_STATUS_TYPE_CODE=>l_STATUS_TO_COMPARE_WITH
     ,x_STATUS_MATCHED_FLAG=>l_status_matched
     ,x_error_code=>l_error_code
     ,x_error_message=>l_error_message
     );

    IF l_error_code <> 0
    THEN
      raise e_SOA_CHECK_SV_STATUS;
    END IF;

    -- Completion
    resultout := 'COMPLETE:'||l_status_matched;
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     --  Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'SOA_CHECK_SV_STATUS'
       ,P_MSG_NAME => 'SOA_CHECK_SV_STATUS_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );

      RAISE;
END SOA_CHECK_SV_STATUS;

 --------------------------------------------------------------------
 -- Gets the Status for the porting record for the
 -- PORTING_ID
 -- Workitem Parameter: PORTING_ID
 -- Item Attr: Gets the Item Attributes WORKITEM_INSTANCE
 -- Workitem Paramters : PORTING_ID
 -- Calls XNP_CORE.SOA_GET_SV_STATUS
 --
 ------------------------------------------------------------------
PROCEDURE SOA_GET_SV_STATUS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_WORKITEM_INSTANCE_ID NUMBER;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
l_porting_id VARCHAR2(80);
l_SV_STATUS VARCHAR2(80);
l_sp_name varchar2(80) := null;
l_local_sp_id number := 0;
x_progress VARCHAR2(2000);
e_SOA_GET_SV_STATUS EXCEPTION;
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_WI'
        ,RESULTOUT
        );

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    l_PORTING_ID :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'PORTING_ID'
     );


    l_sp_name :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'SP_NAME'
     );

    -- Check to see if Statuses matech
    XNP_CORE.SOA_GET_SV_STATUS
     (p_porting_id=>l_porting_id
     ,p_local_sp_id=>l_local_sp_id
     ,x_SV_STATUS=>l_sv_status
     ,x_error_code=>l_error_code
     ,x_error_message=>l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SOA_GET_SV_STATUS;
    END IF;

    -- Completion
    resultout := 'COMPLETE:'||l_sv_status;
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------

      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'SOA_GET_SV_STATUS'
       ,P_MSG_NAME => 'SOA_GET_SV_STATUS_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );

      RAISE;
END SOA_GET_SV_STATUS;


 --------------------------------------------------------------------
 -- Called to modify provisioning
 --
 -- Description:
 --  Gets the Item Attributes WORKITEM_INSTANCE, ORDER_ID
 --  Gets the Activity Attribute FEATURE_TYPE
 --  Gets the workitem parameters STARTING_NUMBER, ENDING_NUMBER
 --  For each of the FEs executes and FA and subscribes for FA_DONE
 ------------------------------------------------------------------
PROCEDURE SMS_MODIFY_NES
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
x_progress VARCHAR2(2000);
l_FEATURE_TYPE VARCHAR2(80) := NULL;
--l_FA_INSTANCE_ID NUMBER := 0;
l_FA_INSTANCE_ID NUMBER := NULL;
l_process_reference varchar2(512) := null;
l_activity_name varchar2(240) := null;
l_ORDER_ID NUMBER;
l_WORKITEM_INSTANCE_ID NUMBER;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
l_STARTING_NUMBER VARCHAR2(80) := NULL;
l_FE_NAME VARCHAR2(200) := NULL;
l_ENDING_NUMBER VARCHAR2(80) := NULL;

CURSOR c_ALL_FEs IS
 SELECT FE_ID
 FROM XNP_SV_SMS_FE_MAPS
 WHERE SV_SMS_ID  IN
 (SELECT SV_SMS_ID FROM XNP_SV_SMS
 WHERE SUBSCRIPTION_TN
 BETWEEN l_STARTING_NUMBER AND l_ENDING_NUMBER
 )
 AND FEATURE_TYPE=l_FEATURE_TYPE
 ;

e_SMS_MODIFY_NES EXCEPTION;

BEGIN

  --
  -- Call SET_SDP_CTX to set values for WI_ID and ORDER_ID
  --
  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_ORD_WI'
   ,RESULTOUT
   );

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

    l_ORDER_ID             := g_ORDER_ID;
    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    l_FEATURE_TYPE :=
     wf_engine.GetActivityAttrText
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,actid => actid
      ,aname   => 'FEATURE_TYPE'
      );

    l_STARTING_NUMBER :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'STARTING_NUMBER'
     );

    l_ENDING_NUMBER :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'ENDING_NUMBER'
     );


     ------------------------------------------------------------------
     -- For each of the fe execute an FA
     -- for the fe modify and subscribe for FA_DONE
     ------------------------------------------------------------------

    FOR l_tmp_fe IN c_ALL_FEs LOOP
/*****                            Marked out to use overloaded xdp_eng_util.ad_fa_towi with fe_id itself.
      XNP_UTILS.GET_FE_NAME
       (p_FE_ID=>l_TMP_FE.FE_ID
       ,x_FE_NAME=>l_FE_NAME
       ,x_ERROR_CODE=>l_ERROR_CODE
       ,x_ERROR_MESSAGE=>l_ERROR_MESSAGE
       );
      IF l_error_code <> 0
      THEN
        raise e_SMS_MODIFY_NES;
      END IF;
*****/
       ------------------------------------------------------------------
       -- Add the FA to the workitem and get the FA instance id
       ------------------------------------------------------------------
      l_FA_INSTANCE_ID :=
       XDP_ENG_UTIL.ADD_FA_TOWI
        (l_WORKITEM_INSTANCE_ID
        ,'MODIFY_'||l_FEATURE_TYPE    -- the FA
        ,l_tmp_fe.fe_id
        );

      -- Call fa exection procedure
      xdp_eng_util.execute_fa
       (p_order_id=>l_order_id
       ,p_wi_instance_id=>l_workitem_instance_id
       ,p_fa_instance_id=>l_fa_instance_id
       ,p_wi_item_type=>itemtype
       ,p_wi_item_key=>itemkey
       ,p_return_code=>l_error_code
       ,p_error_description=>l_error_message
       ,p_fa_caller=>'INTERNAL'
       );

       IF l_error_code <> 0 THEN
         raise e_SMS_MODIFY_NES;
       END IF;

       -- SUBSCRIBE for FA_DONE
       -- with the FA_INSTANCE_ID
       -- and let SFM resume workflow
       -- append FEATURE_TYPE and FE_ID to the process reference
       l_PROCESS_REFERENCE :=
         itemtype||':'||itemkey||':'||'MOD:'||l_FEATURE_TYPE||':'||to_char(l_tmp_fe.FE_ID);

       XNP_EVENT.SUBSCRIBE
        (P_MSG_CODE=>'FA_DONE'   -- Message type to expected
        ,P_REFERENCE_ID=>l_FA_INSTANCE_ID -- Reference id
        ,P_PROCESS_REFERENCE=>l_PROCESS_REFERENCE -- workflow id
        ,P_PROCEDURE_NAME=>'XNP_FA_CB.PROCESS_FA_DONE' -- callback proc
        ,P_CALLBACK_TYPE=>'PL/SQL' -- callback proc type
        ,P_CLOSE_REQD_FLAG => 'Y'
        ,P_ORDER_ID=>l_order_id
        ,P_WI_INSTANCE_ID=>l_workitem_instance_id
        ,P_FA_INSTANCE_ID=>l_FA_INSTANCE_ID
        );

    END LOOP;

    resultout := 'COMPLETE';

    RETURN;

  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'SMS_MODIFY_NES'
       ,P_MSG_NAME => 'SMS_MODIFY_NES_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );

      RAISE;

END SMS_MODIFY_NES;

 --------------------------------------------------------------------
 -- Called when: there is a Modify Ported Number
 --   request from NRC
 -- Description:
 --  Gets the Item Attributes WORKITEM_INSTANCE, ORDER_ID
 --  Calls XNP_STANDARD.SMS_MODIFY_PORTED_NUMBER
 ------------------------------------------------------------------
PROCEDURE SMS_MODIFY_PORTED_NUMBER
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_ORDER_ID                 NUMBER;
l_LINEITEM_ID              NUMBER;
l_WORKITEM_INSTANCE_ID     NUMBER;
l_FA_INSTANCE_ID           NUMBER;
l_error_code               NUMBER := 0;
l_error_message            VARCHAR2(2000);
x_progress                 VARCHAR2(2000) := NULL;
e_SMS_MODIFY_PORTED_NUMBER EXCEPTION;

BEGIN

  --
  -- Call SET_SDP_CTX to set values for WI_ID and ORDER_ID
  --
  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_ORD_WI'
   ,RESULTOUT
   );

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

  l_ORDER_ID             := g_ORDER_ID;
  l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID ;

    -- The run code

    XNP_STANDARD.SMS_MODIFY_PORTED_NUMBER
     (l_ORDER_ID ,
      l_LINEITEM_ID,
      l_WORKITEM_INSTANCE_ID,
      l_FA_INSTANCE_ID,
      l_error_code,
      l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SMS_MODIFY_PORTED_NUMBER;
    END IF;
     -- Completion
     resultout := 'COMPLETE';
     RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN

     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------
      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SMS_MODIFY_PORTED_NUMBER'
       ,P_MSG_NAME             => 'SMS_MODIFY_PORTED_NUMBER_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );

      RAISE;

END SMS_MODIFY_PORTED_NUMBER;

 --------------------------------------------------------------------
 -- Updates the NEW_SP_DUE_DATE for the given porting record
 -- given the PORTING_ID
 -- Workitem Parameter: PORTING_ID
 -- Item Attr: Gets the Item Attributes WORKITEM_INSTANCE
 -- Workitem Paramters : PORTING_ID
 -- Calls XNP_CORE.SOA_UPDATE_NEW_SP_DUE_DATE
 --
 ------------------------------------------------------------------

PROCEDURE SOA_UPDATE_NEW_SP_DUE_DATE
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_ORDER_ID                   NUMBER;
l_LINEITEM_ID                NUMBER;
l_WORKITEM_INSTANCE_ID       NUMBER;
l_FA_INSTANCE_ID             NUMBER;
l_error_code                 NUMBER := 0;
l_error_message              VARCHAR2(2000);
l_porting_id                 VARCHAR2(80);
l_NEW_SP_DUE_DATE            VARCHAR2(80);
x_progress                   VARCHAR2(2000);
l_sp_name                    VARCHAR2(80) := null;
l_local_sp_id                NUMBER := 0;
e_SOA_UPDATE_NEW_SP_DUE_DATE EXCEPTION;

BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
    -- The run code

       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_ORD_WI'
        ,RESULTOUT
        );

  l_ORDER_ID             := g_ORDER_ID;
  l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID ;

    l_PORTING_ID :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'PORTING_ID'
     );

    l_NEW_SP_DUE_DATE :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'NEW_SP_DUE_DATE'
     );

    l_sp_name :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'SP_NAME'
     );

    -- Set the duedate
    XNP_CORE.SOA_UPDATE_NEW_SP_DUE_DATE
     (p_order_id             => l_order_id ,
      p_lineitem_id          => l_lineitem_id,
      p_workitem_instance_id => l_workitem_instance_id,
      p_fa_instance_id       => l_fa_instance_id,
      p_porting_id           => l_porting_id,
      p_local_sp_id          => l_local_sp_id,
      p_NEW_SP_DUE_DATE      => xnp_utils.canonical_to_date(l_NEW_SP_DUE_DATE),
      x_error_code           => l_error_code,
      x_error_message        => l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SOA_UPDATE_NEW_SP_DUE_DATE;
    END IF;

    -- Completion
    resultout := 'COMPLETE';
    RETURN;
  END IF;

  --
  -- CANCEL mode
  --

  -- This is in the event that the activity must be undone.
  --

  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code
    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null
  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------
      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;
      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SOA_UPDATE_NEW_SP_DUE_DATE'
       ,P_MSG_NAME             => 'SOA_UPDATE_NEW_SP_DUE_DATE_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );
      RAISE;

END SOA_UPDATE_NEW_SP_DUE_DATE;


 --------------------------------------------------------------------
 -- Updates the OLD_SP_DUE_DATE for the given porting record
 -- given the PORTING_ID
 -- Workitem Parameter: PORTING_ID
 -- Item Attr: Gets the Item Attributes WORKITEM_INSTANCE
 -- Workitem Paramters : PORTING_ID
 -- Calls XNP_CORE.SOA_UPDATE_OLD_SP_DUE_DATE
 --
 ------------------------------------------------------------------

PROCEDURE SOA_UPDATE_OLD_SP_DUE_DATE
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_ORDER_ID                   NUMBER;
l_LINEITEM_ID                NUMBER;
l_WORKITEM_INSTANCE_ID       NUMBER;
l_FA_INSTANCE_ID             NUMBER;
l_error_code                 NUMBER := 0;
l_error_message              VARCHAR2(2000);
l_porting_id                 VARCHAR2(80);
l_OLD_SP_DUE_DATE            VARCHAR2(80);
l_sp_name                    VARCHAR2(80) := null;
l_local_sp_id                number := 0;
x_progress                   VARCHAR2(2000);
e_SOA_UPDATE_OLD_SP_DUE_DATE EXCEPTION;

BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
    -- The run code

       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_ORD_WI'
        ,RESULTOUT
        );

    l_ORDER_ID             := g_ORDER_ID;
    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    l_PORTING_ID :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'PORTING_ID'
     );

    l_OLD_SP_DUE_DATE :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'OLD_SP_DUE_DATE'
     );


    l_sp_name :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'SP_NAME'
     );

    -- Set the duedate
    XNP_CORE.SOA_UPDATE_OLD_SP_DUE_DATE
     (p_order_id             => l_order_id ,
      p_lineitem_id          => l_lineitem_id ,
      p_workitem_instance_id => l_workitem_instance_id ,
      p_fa_instance_id       => l_fa_instance_id ,
      p_porting_id           => l_porting_id,
      p_local_sp_id          => l_local_sp_id,
      p_OLD_SP_DUE_DATE      => xnp_utils.canonical_to_date(l_OLD_SP_DUE_DATE),
      x_error_code           => l_error_code,
      x_error_message        => l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SOA_UPDATE_OLD_SP_DUE_DATE;
    END IF;

    -- Completion
    resultout := 'COMPLETE';
    RETURN;
  END IF;

  --
  -- CANCEL mode
  --

  -- This is in the event that the activity must be undone.
  --

  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code
    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null
  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------
      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;
      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SOA_UPDATE_OLD_SP_DUE_DATE'
       ,P_MSG_NAME             => 'SOA_UPDATE_OLD_SP_DUE_DATE_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );
      RAISE;

END SOA_UPDATE_OLD_SP_DUE_DATE;

 ------------------------------------------------------------------
 -- Description: Procedure to check if there
 -- exists a Porting record in the given status
 -- for this TN range and beloging to the
 -- with the given DONOR's SP ID
 -- Completes with 'Y' or 'N'
 -- Activity Attributes: STATUS_TO_COMPARE_WITH
 -- Mandatory WI Params: STARTING_NUMBER,ENDING_NUMBER,DONOR_SP_ID
 ------------------------------------------------------------------
PROCEDURE SOA_CHECK_DON_STATUS_EXISTS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_WORKITEM_INSTANCE_ID NUMBER;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
x_CHECK_STATUS VARCHAR2(1);
l_STATUS_TO_COMPARE_WITH varchar2(80);
x_progress VARCHAR2(2000);
e_SOA_CHECK_DON_STATUS_EXISTS EXCEPTION;
BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
    -- The run code

       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_WI'
        ,RESULTOUT
        );

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    l_STATUS_TO_COMPARE_WITH :=
     wf_engine.GetActivityAttrText
       (itemtype => itemtype
       ,itemkey  => itemkey
       ,actid => actid
       ,aname   => 'STATUS_TO_COMPARE_WITH'
       );

    XNP_STANDARD.SOA_CHECK_DON_STATUS_EXISTS
    (p_WORKITEM_INSTANCE_ID =>l_workitem_instance_id
    ,p_status_to_check_with =>l_status_to_compare_with
    ,x_CHECK_STATUS =>x_check_status
    ,x_ERROR_CODE =>l_error_code
    ,x_ERROR_MESSAGE =>l_error_message
    );

    IF l_error_code <> 0 THEN
      raise e_SOA_CHECK_DON_STATUS_EXISTS;
    END IF;

    -- Completion
    if (x_check_status = 'Y') then
      resultout := 'COMPLETE:T';
    else
      resultout := 'COMPLETE:F';
    end if;

    RETURN;
  END IF;

  --
  -- CANCEL mode
  --

  -- This is in the event that the activity must be undone.
  --

  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code
    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null
  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------
      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;
      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'SOA_CHECK_DON_STATUS_EXISTS'
       ,P_MSG_NAME => 'SOA_CHK_DON_STATUS_EXISTS_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );
      RAISE;

END SOA_CHECK_DON_STATUS_EXISTS;

 ------------------------------------------------------------------
 -- Description: Procedure to check if there
 -- exists a Porting record in the given status
 -- for this TN range and beloging to the
 -- with the given RECIPIENT's SP ID
 -- Completes with 'Y' or 'N'
 ------------------------------------------------------------------
PROCEDURE SOA_CHECK_REC_STATUS_EXISTS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_WORKITEM_INSTANCE_ID NUMBER;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
x_CHECK_STATUS VARCHAR2(1);
l_STATUS_TO_COMPARE_WITH varchar2(80);
x_progress VARCHAR2(2000);
e_SOA_CHECK_REC_STATUS_EXISTS EXCEPTION;
BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
    -- The run code

       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_WI'
        ,RESULTOUT
        );

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    l_STATUS_TO_COMPARE_WITH :=
     wf_engine.GetActivityAttrText
       (itemtype => itemtype
       ,itemkey  => itemkey
       ,actid => actid
       ,aname   => 'STATUS_TO_COMPARE_WITH'
       );

    XNP_STANDARD.SOA_CHECK_REC_STATUS_EXISTS
    (p_WORKITEM_INSTANCE_ID =>l_workitem_instance_id
    ,p_status_to_check_with =>l_status_to_compare_with
    ,x_CHECK_STATUS =>x_check_status
    ,x_ERROR_CODE =>l_error_code
    ,x_ERROR_MESSAGE =>l_error_message
    );

    IF l_error_code <> 0 THEN
      raise e_SOA_CHECK_REC_STATUS_EXISTS;
    END IF;

    -- Completion
    if (x_check_status = 'Y') then
      resultout := 'COMPLETE:T';
    else
      resultout := 'COMPLETE:F';
    end if;

    RETURN;
  END IF;

  --
  -- CANCEL mode
  --

  -- This is in the event that the activity must be undone.
  --

  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code
    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null
  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------
      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;
      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'SOA_CHECK_REC_STATUS_EXISTS'
       ,P_MSG_NAME => 'SOA_CHK_REC_STATUS_EXISTS_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );
      RAISE;

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
PROCEDURE SOA_UPD_PORTING_ID_STATUS
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_ORDER_ID                  NUMBER;
l_LINEITEM_ID               NUMBER;
l_WORKITEM_INSTANCE_ID      NUMBER;
l_FA_INSTANCE_ID            NUMBER;
l_NEW_STATUS_TYPE_CODE      VARCHAR2(40);
l_STATUS_CHANGE_CAUSE_CODE  VARCHAR2(40);
l_error_code                NUMBER := 0;
l_error_message             VARCHAR2(2000);
x_progress                  VARCHAR2(2000);
e_SOA_UPD_PORTING_ID_STATUS EXCEPTION;

BEGIN

  --
  -- Call SET_SDP_CTX to set values for WI_ID and ORDER_ID
  --
  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_ORD_WI'
   ,RESULTOUT
   );

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

  l_ORDER_ID             := g_ORDER_ID;
  l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID ;

    l_NEW_STATUS_TYPE_CODE :=
      wf_engine.GetActivityAttrText (itemtype => itemtype,
      itemkey  => itemkey,
      actid => actid,
      aname   => 'NEW_STATUS_TYPE_CODE');

    l_STATUS_CHANGE_CAUSE_CODE :=
      wf_engine.GetActivityAttrText (itemtype => itemtype,
      itemkey  => itemkey,
      actid => actid,
      aname   => 'STATUS_CHANGE_CAUSE_CODE');

    XNP_STANDARD.SOA_UPDATE_SV_STATUS
     (p_ORDER_ID                 => l_ORDER_ID ,
      p_LINEITEM_ID              => l_LINEITEM_ID ,
      p_WORKITEM_INSTANCE_ID     => l_WORKITEM_INSTANCE_ID,
      p_FA_INSTANCE_ID           => l_FA_INSTANCE_ID ,
      p_NEW_STATUS_TYPE_CODE     => l_NEW_STATUS_TYPE_CODE,
      p_STATUS_CHANGE_CAUSE_CODE => l_STATUS_CHANGE_CAUSE_CODE,
      x_ERROR_CODE               => l_error_code,
      x_ERROR_MESSAGE            => l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SOA_UPD_PORTING_ID_STATUS;
    END IF;
    -- Completion
    resultout := 'COMPLETE';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SOA_UPD_PORTING_ID_STATUS'
       ,P_MSG_NAME             => 'SOA_UPD_PORTING_ID_STATUS_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );

      RAISE;
END SOA_UPD_PORTING_ID_STATUS;

 --------------------------------------------------------------------
 -- Sets the flag to the given value
 -- for the enties in xnp_sv_soa for the given
 -- PORTING_ID workitem paramter and FLAG_NAME
 -- Values: 'Y' or 'N'
 -- Item Attr: Gets the Item Attributes WORKITEM_INSTANCE
 -- Activity Attr : Gets the value of Activity Attribute FLAG_VALUE
 --  Gets the value of Activity Attribute FLAG_NAME
 -- Workitem Paramters : PORTING_ID, SP_NAME
 -- Calls the core function to set the corresponding
 -- flag value
 ------------------------------------------------------------------
PROCEDURE SOA_SET_FLAG_VALUE
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_ORDER_ID             NUMBER;
l_LINEITEM_ID          NUMBER;
l_WORKITEM_INSTANCE_ID NUMBER;
l_FA_INSTANCE_ID       NUMBER;
l_error_code           NUMBER := 0;
l_error_message        VARCHAR2(2000):= null;
l_porting_id           VARCHAR2(80):= null;
l_flag_value           VARCHAR2(1):= null;
l_flag_name            VARCHAR2(40):= null;
l_sp_name              VARCHAR2(80) := null;
l_local_sp_id          NUMBER := 0;
x_progress             VARCHAR2(2000):= null;
e_SOA_SET_FLAG_VALUE   EXCEPTION;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_ORD_WI'
        ,RESULTOUT
        );

    l_ORDER_ID             :=  g_ORDER_ID;
    l_WORKITEM_INSTANCE_ID :=  g_WORKITEM_INSTANCE_ID;

    l_PORTING_ID :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'PORTING_ID'
     );

    l_sp_name :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'SP_NAME'
     );

    l_flag_value :=
      wf_engine.GetActivityAttrText (itemtype => itemtype,
      itemkey  => itemkey,
      actid    => actid,
      aname    => 'FLAG_VALUE');

    l_flag_name :=
      wf_engine.GetActivityAttrText
      (itemtype => itemtype,
      itemkey   => itemkey,
      actid     => actid,
      aname     => 'FLAG_NAME'
      );

    if (l_flag_name = 'LOCKED_FLAG') then
      -- Set the locked flag

      XNP_CORE.SOA_SET_LOCKED_FLAG
       (p_order_id             => l_order_id ,
        p_lineitem_id          => l_lineitem_id,
        p_workitem_instance_id => l_workitem_instance_id,
        p_fa_instance_id       => l_fa_instance_id,
        p_porting_id           => l_porting_id,
        p_local_sp_id          => l_local_sp_id,
        p_locked_flag          => l_flag_value,
        x_error_code           => l_error_code,
        x_error_message        => l_error_message
       );
    elsif (l_flag_name = 'NEW_SP_AUTHORIZATION_FLAG') then
       XNP_CORE.SOA_UPDATE_NEW_SP_AUTH_FLAG
       (p_order_id                  => l_order_id ,
        p_lineitem_id               => l_lineitem_id,
        p_workitem_instance_id      => l_workitem_instance_id,
        p_fa_instance_id            => l_fa_instance_id,
        p_porting_id                => l_porting_id,
        p_local_sp_id               => l_local_sp_id,
        p_new_sp_authorization_flag => l_flag_value,
        x_error_code                => l_error_code,
        x_error_message             => l_error_message
        );
    elsif (l_flag_name = 'OLD_SP_AUTHORIZATION_FLAG') then
       XNP_CORE.SOA_UPDATE_OLD_SP_AUTH_FLAG
       (p_order_id                  => l_order_id ,
        p_lineitem_id               => l_lineitem_id,
        p_workitem_instance_id      => l_workitem_instance_id,
        p_fa_instance_id            => l_fa_instance_id,
        p_porting_id                => l_porting_id,
        p_local_sp_id               => l_local_sp_id,
        p_old_sp_authorization_flag => l_flag_value,
        x_error_code                => l_error_code,
        x_error_message             => l_error_message
        );
    elsif (l_flag_name = 'BLOCKED_FLAG') then
      -- Set the blocked flag
      XNP_CORE.SOA_SET_BLOCKED_FLAG
       (p_order_id             => l_order_id ,
        p_lineitem_id          => l_lineitem_id,
        p_workitem_instance_id => l_workitem_instance_id,
        p_fa_instance_id       => l_fa_instance_id,
        p_porting_id           => l_porting_id,
        p_local_sp_id          => l_local_sp_id,
        p_blocked_flag         => l_flag_value,
        x_error_code           => l_error_code,
        x_error_message        => l_error_message
       );
    elsif (l_flag_name = 'CONCURRENCE_FLAG') then
      -- Set the concurrence flag

      XNP_CORE.SOA_SET_CONCURRENCE_FLAG
       (p_order_id             => l_order_id ,
        p_lineitem_id          => l_lineitem_id,
        p_workitem_instance_id => l_workitem_instance_id,
        p_fa_instance_id       => l_fa_instance_id,
        p_porting_id           => l_porting_id,
        p_local_sp_id          => l_local_sp_id,
        p_concurrence_flag     => l_flag_value,
        x_error_code           => l_error_code,
        x_error_message        => l_error_message
       );
    else
       null; -- Ignore it
    end if;

    IF l_error_code <> 0 THEN
      raise e_SOA_SET_FLAG_VALUE;
    END IF;

    -- Completion
    resultout := 'COMPLETE';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------
      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SOA_SET_FLAG_VALUE'
       ,P_MSG_NAME             => 'SOA_SET_FLAG_VALUE_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       ,P_TOK2                 => 'FLAG_NAME'
       ,P_VAL2                 => l_flag_name
       );

      RAISE;
END SOA_SET_FLAG_VALUE;


 --------------------------------------------------------------------
 -- Gets the Locked flag for the given
 -- PORTING_ID workitem paramter.
 -- The activity is completed with the flag value
 -- Values: 'Y' or 'N'
 -- Item Attr: Gets the Item Attributes WORKITEM_INSTANCE
 -- Workitem Paramters : PORTING_ID,SP_NAME
 -- Calls the core funtion to get the corresponding flag value
 ------------------------------------------------------------------
PROCEDURE SOA_GET_FLAG_VALUE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_WORKITEM_INSTANCE_ID NUMBER;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
l_porting_id VARCHAR2(80);
l_flag_value VARCHAR2(1):='N';
l_flag_name VARCHAR2(40);
l_SP_NAME VARCHAR2(40) := NULL;
l_local_sp_id NUMBER := 0;
x_progress VARCHAR2(2000);
e_SOA_GET_FLAG_VALUE EXCEPTION;
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_WI'
        ,RESULTOUT
        );

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    l_PORTING_ID :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'PORTING_ID'
     );

    l_sp_name :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'SP_NAME'
     );

    l_flag_name :=
      wf_engine.GetActivityAttrText
      (itemtype => itemtype,
      itemkey  => itemkey,
      actid => actid,
      aname   => 'FLAG_NAME'
      );

    if (l_flag_name = 'LOCKED_FLAG') then
      -- Get the locked flag
      XNP_CORE.SOA_GET_LOCKED_FLAG
       (p_porting_id=>l_porting_id
       ,p_local_sp_id=>l_local_sp_id
       ,x_locked_flag=>l_flag_value
       ,x_error_code=>l_error_code
       ,x_error_message=>l_error_message
       );
    elsif (l_flag_name = 'BLOCKED_FLAG') then
      -- Get the blocked flag
      XNP_CORE.SOA_GET_BLOCKED_FLAG
       (p_porting_id=>l_porting_id
       ,p_local_sp_id=>l_local_sp_id
       ,x_blocked_flag=>l_flag_value
       ,x_error_code=>l_error_code
       ,x_error_message=>l_error_message
       );
    elsif (l_flag_name = 'NEW_SP_AUTHORIZATION_FLAG') then
      -- Get the new_sp_auth flag
      XNP_CORE.SOA_GET_NEW_SP_AUTH_FLAG
       (p_porting_id=>l_porting_id
       ,p_local_sp_id=>l_local_sp_id
       ,x_new_sp_auth_flag=>l_flag_value
       ,x_error_code=>l_error_code
       ,x_error_message=>l_error_message
       );
    elsif (l_flag_name = 'OLD_SP_AUTHORIZATION_FLAG') then
      -- Get the old_sp_auth flag
      XNP_CORE.SOA_GET_OLD_SP_AUTH_FLAG
       (p_porting_id=>l_porting_id
       ,p_local_sp_id=>l_local_sp_id
       ,x_old_sp_auth_flag=>l_flag_value
       ,x_error_code=>l_error_code
       ,x_error_message=>l_error_message
       );
    elsif (l_flag_name = 'CONCURRENCE_FLAG') then
      -- Get the concurrence flag
      XNP_CORE.SOA_GET_CONCURRENCE_FLAG
       (p_porting_id=>l_porting_id
       ,p_local_sp_id=>l_local_sp_id
       ,x_concurrence_flag=>l_flag_value
       ,x_error_code=>l_error_code
       ,x_error_message=>l_error_message
       );
    else
      raise e_SOA_GET_FLAG_VALUE;
    end if;


    IF l_error_code <> 0 THEN
      raise e_SOA_GET_FLAG_VALUE;
    END IF;

    -- Completion
    resultout := 'COMPLETE:'||l_flag_value;
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'SOA_GET_FLAG_VALUE'
       ,P_MSG_NAME => 'SOA_GET_FLAG_VALUE_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       ,P_TOK2 => 'FLAG_NAME'
       ,P_VAL2 => l_flag_name
       );

      RAISE;
END SOA_GET_FLAG_VALUE;

 --------------------------------------------------------------------
 -- Updates the DATE for the given porting record
 -- given the PORTING_ID. The date to update i.e.
 -- NEW_SP_DUE_DATE, OLD_SP_DUE_DATE,ACTIVATION_DUE_DATE,etc
 --
 -- Workitem Parameter: PORTING_ID
 -- Item Attr: Gets the Item Attributes WORKITEM_INSTANCE
 -- Workitem Paramters : PORTING_ID
 -- Calls XNP_CORE.<function to update the right date>
 --
 ------------------------------------------------------------------
PROCEDURE SOA_UPDATE_DATE
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_ORDER_ID              NUMBER;
l_LINEITEM_ID           NUMBER;
l_WORKITEM_INSTANCE_ID  NUMBER;
l_FA_INSTANCE_ID        NUMBER;
l_error_code            NUMBER := 0;
l_error_message         VARCHAR2(2000);
l_porting_id            VARCHAR2(80);
l_date_value            VARCHAR2(200);
l_date_name             VARCHAR2(40);
l_sp_name               VARCHAR2(80) := null;
l_local_sp_id           NUMBER := 0;
x_progress              VARCHAR2(2000);
e_SOA_UPDATE_DATE       EXCEPTION;
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_ORD_WI'
        ,RESULTOUT
        );

    l_ORDER_ID             :=  g_ORDER_ID;
    l_WORKITEM_INSTANCE_ID :=  g_WORKITEM_INSTANCE_ID;

    l_PORTING_ID :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'PORTING_ID'
     );

    l_sp_name :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'SP_NAME'
     );

    l_date_name :=
      wf_engine.GetActivityAttrText
      (itemtype => itemtype,
      itemkey   => itemkey,
      actid     => actid,
      aname     => 'DATE_NAME'
      );

    if (l_date_name = 'NEW_SP_DUE_DATE') then

      l_date_value :=
       XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
       (l_WORKITEM_INSTANCE_ID
       ,'NEW_SP_DUE_DATE'
       );

      XNP_CORE.SOA_UPDATE_NEW_SP_DUE_DATE
       (p_order_id             =>l_order_id,
        p_lineitem_id          =>l_lineitem_id,
        p_workitem_instance_id =>l_workitem_instance_id ,
        p_fa_instance_id       =>l_fa_instance_id,
        p_porting_id           =>l_porting_id,
        p_local_sp_id          =>l_local_sp_id,
        p_new_sp_due_date      =>xnp_utils.canonical_to_date(l_date_value),
        x_error_code           =>l_error_code,
        x_error_message        =>l_error_message
       );

    elsif (l_date_name = 'OLD_SP_DUE_DATE') then

      l_date_value :=
       XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
       (l_WORKITEM_INSTANCE_ID
       ,'OLD_SP_DUE_DATE'
       );

      XNP_CORE.SOA_UPDATE_OLD_SP_DUE_DATE
       (p_order_id             =>l_order_id,
        p_lineitem_id          =>l_lineitem_id,
        p_workitem_instance_id =>l_workitem_instance_id ,
        p_fa_instance_id       =>l_fa_instance_id,
        p_porting_id           =>l_porting_id,
        p_local_sp_id          =>l_local_sp_id,
        p_OLD_SP_DUE_DATE      =>xnp_utils.canonical_to_date(l_date_value),
        x_error_code           =>l_error_code,
        x_error_message        =>l_error_message
       );

    elsif (l_date_name = 'ACTIVATION_DUE_DATE') then

      l_date_value :=
       XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
       (l_WORKITEM_INSTANCE_ID
       ,'ACTIVATION_DUE_DATE'
       );

      XNP_CORE.SOA_UPDATE_ACTIVATION_DUE_DATE
       (p_order_id             =>l_order_id,
        p_lineitem_id          =>l_lineitem_id,
        p_workitem_instance_id =>l_workitem_instance_id ,
        p_fa_instance_id       =>l_fa_instance_id,
        p_porting_id           =>l_porting_id,
        p_local_sp_id          =>l_local_sp_id,
        p_ACTIVATION_DUE_DATE  =>xnp_utils.canonical_to_date(l_date_value),
        x_error_code           =>l_error_code,
        x_error_message        =>l_error_message
       );

    elsif (l_date_name = 'DISCONNECT_DUE_DATE') then

      l_date_value :=
       XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
       (l_WORKITEM_INSTANCE_ID
       ,'DISCONNECT_DUE_DATE'
       );

      XNP_CORE.SOA_UPDATE_DISCONN_DUE_DATE
       (p_order_id             =>l_order_id,
        p_lineitem_id          =>l_lineitem_id,
        p_workitem_instance_id =>l_workitem_instance_id ,
        p_fa_instance_id       =>l_fa_instance_id,
        p_porting_id           =>l_porting_id,
        p_disconnect_due_date  =>xnp_utils.canonical_to_date(l_date_value),
        x_error_code           =>l_error_code,
        x_error_message        =>l_error_message
       );

    elsif (l_date_name = 'EFFECTIVE_RELEASE_DUE_DATE') then

      l_date_value :=
       XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
       (l_WORKITEM_INSTANCE_ID
       ,'EFFECTIVE_RELEASE_DUE_DATE'
       );

      XNP_CORE.SOA_UPDATE_EFFECT_REL_DUE_DATE
       (p_order_id                    =>l_order_id,
        p_lineitem_id                 =>l_lineitem_id,
        p_workitem_instance_id        =>l_workitem_instance_id ,
        p_fa_instance_id              =>l_fa_instance_id,
        p_porting_id                  =>l_porting_id,
        p_effective_release_due_date  =>xnp_utils.canonical_to_date(l_date_value),
        x_error_code                  =>l_error_code,
        x_error_message               =>l_error_message
       );

    elsif (l_date_name = 'NUMBER_RETURNED_DUE_DATE') then

      l_date_value :=
       XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
       (l_WORKITEM_INSTANCE_ID
       ,'NUMBER_RETURNED_DUE_DATE'
       );

      XNP_CORE.SOA_UPDATE_NUM_RETURN_DUE_DATE
       (p_order_id                    =>l_order_id,
        p_lineitem_id                 =>l_lineitem_id,
        p_workitem_instance_id        =>l_workitem_instance_id ,
        p_fa_instance_id              =>l_fa_instance_id,
        p_porting_id                  =>l_porting_id,
        p_number_returned_due_date    =>xnp_utils.canonical_to_date(l_date_value),
        x_error_code                  =>l_error_code,
        x_error_message               =>l_error_message
       );
    else
       null; -- Ignore it
    end if;

    IF l_error_code <> 0 THEN
      raise e_SOA_UPDATE_DATE;
    END IF;

    -- Completion
    resultout := 'COMPLETE';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------
      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SOA_UPDATE_DATE'
       ,P_MSG_NAME             => 'SOA_UPDATE_DATE_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       ,P_TOK2                 => 'DATE_NAME'
       ,P_VAL2                 => l_date_name
       );

      RAISE;
END SOA_UPDATE_DATE;


 --------------------------------------------------------------------
 -- Description:
 --  Gets the Item Attributes WORKITEM_INSTANCE, ORDER_ID
 --  calls XNP_CORE.CHECK_IF_SP_ASSIGNED
 --  Completes the path based on the result
 -- Mandatory WI params: STARTING_NUMBER,ENDING_NUMBER,DONOR_SP_ID
 ------------------------------------------------------------------
PROCEDURE CHECK_IF_DONOR_CAN_PORT_OUT
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
x_progress VARCHAR2(2000);
l_WORKITEM_INSTANCE_ID NUMBER;
l_starting_number varchar2(80) := null;
l_ending_number varchar2(80) := null;
l_donor_sp_name varchar2(80) := null;
l_donor_sp_id NUMBER := 0;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
l_check_status VARCHAR2(1);
e_CHECK_IF_DONOR_CAN_PORT_OUT EXCEPTION;
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_WI'
        ,RESULTOUT
        );

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    l_STARTING_NUMBER :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'STARTING_NUMBER'
     );

    l_ENDING_NUMBER :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'ENDING_NUMBER'
     );

    l_DONOR_SP_NAME :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'DONOR_SP_ID'
     );

    XNP_CORE.GET_SP_ID
    (p_SP_NAME=>l_DONOR_SP_NAME
    ,x_SP_ID=>l_donor_sp_id
    ,x_ERROR_CODE=>l_error_code
    ,x_ERROR_MESSAGE=>l_error_message
    );

    IF l_error_code <> 0 THEN
      raise e_CHECK_IF_DONOR_CAN_PORT_OUT;
    END IF;

    -- Check this is the SP which has provisioned the
    -- entire number range or is the assigned sp id

    XNP_CORE.CHECK_IF_SP_ASSIGNED
     (p_STARTING_NUMBER  =>l_starting_number
     ,p_ENDING_NUMBER    =>l_ending_number
     ,p_SP_ID            =>l_donor_sp_id
     ,x_CHECK_IF_ASSIGNED=>l_check_status
     ,x_ERROR_CODE       =>l_error_code
     ,x_ERROR_MESSAGE    =>l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_CHECK_IF_DONOR_CAN_PORT_OUT;
    END IF;

    -- Completion: If check status is true the traces
    -- the 'YES' path else trace the 'NO' path
    IF l_check_status = 'Y' THEN
      resultout := 'COMPLETE:T';
    ELSE
      resultout := 'COMPLETE:F';
    END IF;

    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------

      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'CHECK_IF_DONOR_CAN_PORT_OUT'
       ,P_MSG_NAME => 'CHECK_IF_SP_CAN_PORT_OUT_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );

      RAISE;

END CHECK_IF_DONOR_CAN_PORT_OUT;

 --------------------------------------------------------------------
 -- Description:
 -- Checks if the DONOR_SP_ID (WI param) is the Initial donor
 --  Gets the Item Attributes WORKITEM_INSTANCE
 --  calls XNP_CORE.SOA_CHECK_IF_INITIAL_DONOR
 --  Completes the path based on the result
 -- Mandatory WI params: STARTING_NUMBER,ENDING_NUMBER,DONOR_SP_ID
 ------------------------------------------------------------------
PROCEDURE CHECK_IF_DON_IS_INITIAL_DON
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
x_progress VARCHAR2(2000);
l_WORKITEM_INSTANCE_ID NUMBER;
l_starting_number varchar2(80) := null;
l_ending_number varchar2(80) := null;
l_donor_sp_name varchar2(80) := null;
l_donor_sp_id NUMBER := 0;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
l_check_status VARCHAR2(1);
e_CHECK_IF_DON_IS_INITIAL_DON EXCEPTION;
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_WI'
        ,RESULTOUT
        );

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    l_STARTING_NUMBER :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'STARTING_NUMBER'
     );

    l_ENDING_NUMBER :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'ENDING_NUMBER'
     );

    l_DONOR_SP_NAME :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'DONOR_SP_ID'
     );

    XNP_CORE.GET_SP_ID
    (p_SP_NAME      =>l_donor_sp_name
    ,x_SP_ID        =>l_donor_sp_id
    ,x_ERROR_CODE   =>l_error_code
    ,x_ERROR_MESSAGE=>l_error_message
    );
    IF l_error_code <> 0
    THEN
      raise e_CHECK_IF_DON_IS_INITIAL_DON;
    END IF;

    -- check if the given donor is the initial donor entire
    -- number range
    XNP_CORE.SOA_CHECK_IF_INITIAL_DONOR
     (p_DONOR_SP_ID    =>l_donor_sp_id
     ,p_STARTING_NUMBER=>l_starting_number
     ,p_ENDING_NUMBER  =>l_ending_number
     ,x_CHECK_STATUS   =>l_check_status
     ,x_ERROR_CODE     =>l_error_code
     ,x_ERROR_MESSAGE  =>l_error_message
     );
    IF l_error_code <> 0
    THEN
      raise e_CHECK_IF_DON_IS_INITIAL_DON;
    END IF;

    -- Completion: If check status is 'Y' then traces
    -- the 'T' path else trace the 'F' path
    if (l_check_status = 'Y') then
     resultout := 'COMPLETE:T';
    else
     resultout := 'COMPLETE:F';
    end if;

    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------

      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'CHECK_IF_DON_IS_INITIAL_DON'
       ,P_MSG_NAME => 'CHECK_IF_DON_IS_INIT_DON_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       ,P_TOK2 => 'DONOR_SP_ID'
       ,P_VAL2 => l_donor_sp_name
       );

      RAISE;

END CHECK_IF_DON_IS_INITIAL_DON;

PROCEDURE SOA_UPDATE_NOTES_INFO
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_ORDER_ID              NUMBER;
l_LINEITEM_ID           NUMBER;
l_WORKITEM_INSTANCE_ID  NUMBER;
l_FA_INSTANCE_ID        NUMBER;
x_progress              VARCHAR2(2000);
l_error_code            NUMBER := 0;
l_error_message         VARCHAR2(2000);
e_SOA_UPDATE_NOTES_INFO EXCEPTION;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_ORD_WI'
        ,RESULTOUT
        );

    l_ORDER_ID             :=  g_ORDER_ID;
    l_WORKITEM_INSTANCE_ID :=  g_WORKITEM_INSTANCE_ID;

    XNP_STANDARD.SOA_UPDATE_NOTES_INFO
     (l_order_id,
      l_lineitem_id,
      l_WORKITEM_INSTANCE_ID,
      l_fa_instance_id,
      l_error_code,
      l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SOA_UPDATE_NOTES_INFO;
    END IF;

    resultout := 'COMPLETE';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SOA_UPDATE_NOTES_INFO'
       ,P_MSG_NAME             => 'SOA_UPDATE_NOTES_INFO_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );

      RAISE;

END SOA_UPDATE_NOTES_INFO;


PROCEDURE SOA_UPDATE_NETWORK_INFO
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_ORDER_ID                 NUMBER;
l_LINEITEM_ID              NUMBER;
l_WORKITEM_INSTANCE_ID     NUMBER;
l_FA_INSTANCE_ID           NUMBER;
x_progress                 VARCHAR2(2000);
l_error_code               NUMBER := 0;
l_error_message            VARCHAR2(2000);
e_SOA_UPDATE_NETWORK_INFO  EXCEPTION;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_ORD_WI'
        ,RESULTOUT
        );

    l_ORDER_ID             := g_ORDER_ID;
    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    XNP_STANDARD.SOA_UPDATE_NETWORK_INFO
     (l_order_id,
      l_lineitem_id,
      l_WORKITEM_INSTANCE_ID,
      l_fa_instance_id,
      l_error_code,
      l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SOA_UPDATE_NETWORK_INFO;
    END IF;

    resultout := 'COMPLETE';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SOA_UPDATE_NETWORK_INFO'
       ,P_MSG_NAME             => 'SOA_UPDATE_NETWORK_INFO_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );


      RAISE;

END SOA_UPDATE_NETWORK_INFO;


PROCEDURE SOA_UPDATE_CUSTOMER_INFO
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_ORDER_ID                 NUMBER;
l_LINEITEM_ID              NUMBER;
l_WORKITEM_INSTANCE_ID     NUMBER;
l_FA_INSTANCE_ID           NUMBER;
x_progress                 VARCHAR2(2000);
l_error_code               NUMBER := 0;
l_error_message            VARCHAR2(2000);
e_SOA_UPDATE_CUSTOMER_INFO EXCEPTION;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_ORD_WI'
        ,RESULTOUT
        );

    l_ORDER_ID             := g_ORDER_ID;
    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    XNP_STANDARD.SOA_UPDATE_CUSTOMER_INFO
     (l_order_id,
      l_lineitem_id,
      l_workitem_instance_id,
      l_fa_instance_id,
      l_error_code,
      l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SOA_UPDATE_CUSTOMER_INFO;
    END IF;

    resultout := 'COMPLETE';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SOA_UPDATE_CUSTOMER_INFO'
       ,P_MSG_NAME             => 'SOA_UPDATE_CUSTOMER_INFO_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );

      RAISE;

END SOA_UPDATE_CUSTOMER_INFO;


PROCEDURE PREPARE_CUSTOM_NOTIFN
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
x_progress VARCHAR2(2000);
l_WORKITEM_INSTANCE_ID NUMBER;
l_ORDER_ID NUMBER;
l_FA_INSTANCE_ID NUMBER;
l_body varchar2(2000) := null;
l_subject varchar2(2000) := null;
l_error_code NUMBER := 0;
l_error_message VARCHAR2(2000);
l_notfn_msg_name varchar2(200) := null;
e_PREPARE_CUSTOM_NOTFN EXCEPTION;

BEGIN

    SET_SDP_CONTEXT
     (ITEMTYPE
     ,ITEMKEY
     ,ACTID
     ,'SET_ORD_WI'
     ,RESULTOUT
     );

    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;
    l_ORDER_ID             := g_ORDER_ID;

     ------------------------------------------------------------------
     -- Get the activity attribute NOTIFN_MSG_NAME
     -- Get the string corresponding to this FND message
     -- parse to see the tokens in it. Substitute the tokens
     -- with the value
     ------------------------------------------------------------------
    l_notfn_msg_name :=
      wf_engine.GetActivityAttrText
      (itemtype => itemtype,
      itemkey  => itemkey,
      actid => actid,
      aname => 'NOTIFN_MSG_NAME'
      );

     xnp_utils.get_interpreted_notification
      (p_workitem_instance_id => l_workitem_instance_id
      ,p_mls_message_name => l_notfn_msg_name
      ,x_subject => l_subject
      ,x_body => l_body
      ,x_error_code => l_error_code
      ,x_error_message => l_error_message
      );

     if (l_error_code <> 0) then
       raise e_PREPARE_CUSTOM_NOTFN;
     end if;

     ------------------------------------------------------------------
     -- Set the item attributes MSG_SUBJECT, MSG_BODY
     ------------------------------------------------------------------

    wf_engine.SetItemAttrText
     (itemtype => itemtype
     ,itemkey => itemkey
     ,aname => 'MSG_SUBJECT'
     ,avalue => l_subject
     );

    wf_engine.SetItemAttrText
     (itemtype => itemtype
     ,itemkey => itemkey
     ,aname => 'MSG_BODY'
     ,avalue => l_body
     );

    resultout := 'COMPLETE';
    RETURN;

EXCEPTION

    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message
;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME => 'XNP_WF_STANDARD'
       ,P_PROC_NAME => 'PREPARE_CUSTOM_NOTFN'
       ,P_MSG_NAME => 'PREPARE_CUSTOM_NOTFN_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1 => 'ERROR_TEXT'
       ,P_VAL1 => x_progress
       );


      RAISE;

END PREPARE_CUSTOM_NOTIFN;



 ------------------------------------------------------------------
 -- Called when: need to update the SV status according
 --   to the activity parameter SV_STATUS
 -- Description:
 --  Gets the Item Attributes WORKITEM_INSTANCE, ORDER_ID
 --  Calls XNP_STANDARD.SOA_UPDATE_SV_STATUS
 ------------------------------------------------------------------
PROCEDURE SOA_UPDATE_CUR_SV_STATUS
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_ORDER_ID                 NUMBER;
l_LINEITEM_ID              NUMBER;
l_WORKITEM_INSTANCE_ID     NUMBER;
l_FA_INSTANCE_ID           NUMBER;
l_NEW_STATUS_TYPE_CODE     VARCHAR2(40);
l_CUR_STATUS_TYPE_CODE     VARCHAR2(40);
l_STATUS_CHANGE_CAUSE_CODE VARCHAR2(40);
l_error_code               NUMBER := 0;
l_error_message            VARCHAR2(2000);
x_progress                 VARCHAR2(2000);
e_SOA_UPDATE_CUR_SV_STATUS EXCEPTION;

BEGIN
  --
  -- Call SET_SDP_CTX to set values for WI_ID and ORDER_ID
  --
  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_ORD_WI'
   ,RESULTOUT
   );

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

  l_ORDER_ID             := g_ORDER_ID;
  l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID ;

    l_CUR_STATUS_TYPE_CODE :=
      wf_engine.GetActivityAttrText (itemtype => itemtype,
      itemkey  => itemkey,
      actid    => actid,
      aname    => 'CUR_STATUS_TYPE_CODE');

    l_NEW_STATUS_TYPE_CODE :=
      wf_engine.GetActivityAttrText (itemtype => itemtype,
      itemkey  => itemkey,
      actid    => actid,
      aname    => 'NEW_STATUS_TYPE_CODE');

    l_STATUS_CHANGE_CAUSE_CODE :=
      wf_engine.GetActivityAttrText (itemtype => itemtype,
      itemkey  => itemkey,
      actid    => actid,
      aname    => 'STATUS_CHANGE_CAUSE_CODE');

    XNP_STANDARD.SOA_UPDATE_SV_STATUS
     (p_ORDER_ID                 => L_ORDER_ID,
      p_LINEITEM_ID              =>l_LINEITEM_ID,
      p_WORKITEM_INSTANCE_ID     => l_WORKITEM_INSTANCE_ID,
      p_FA_INSTANCE_ID           => l_FA_INSTANCE_ID,
      p_CUR_STATUS_TYPE_CODE     => l_CUR_STATUS_TYPE_CODE,
      p_NEW_STATUS_TYPE_CODE     => l_NEW_STATUS_TYPE_CODE,
      p_STATUS_CHANGE_CAUSE_CODE => l_STATUS_CHANGE_CAUSE_CODE,
      x_ERROR_CODE               => l_error_code,
      x_ERROR_MESSAGE            => l_error_message
     );

    IF l_error_code <> 0 THEN
      raise e_SOA_UPDATE_CUR_SV_STATUS;
    END IF;
    -- Completion
    resultout := 'COMPLETE';
    RETURN;
  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------


      IF (l_error_code <> 0) THEN
          x_progress := to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;

      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SOA_UPDATE_CUR_SV_STATUS'
       ,P_MSG_NAME             => 'SOA_UPDATE_SV_STATUS_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );

      RAISE;
END SOA_UPDATE_CUR_SV_STATUS;

PROCEDURE SMS_UPDATE_PROV_DONE_DATE
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_ORDER_ID                  NUMBER;
l_LINEITEM_ID               NUMBER;
l_WORKITEM_INSTANCE_ID      NUMBER;
l_FA_INSTANCE_ID            NUMBER;
l_STARTING_NUMBER           VARCHAR2(80) := NULL;
l_ENDING_NUMBER             VARCHAR2(80) := NULL;
l_error_code                NUMBER := 0;
l_error_message             VARCHAR2(2000);
x_progress                  VARCHAR2(2000);
e_SMS_UPDATE_PROV_DONE_DATE exception;

BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

       SET_SDP_CONTEXT
        (ITEMTYPE
        ,ITEMKEY
        ,ACTID
        ,'SET_ORD_WI'
        ,RESULTOUT
        );

    l_ORDER_ID             := g_ORDER_ID;
    l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;

    l_STARTING_NUMBER :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'STARTING_NUMBER'
     );

    l_ENDING_NUMBER :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (l_WORKITEM_INSTANCE_ID
     ,'ENDING_NUMBER'
     );

    XNP_CORE.SMS_UPDATE_PROV_DONE_DATE
	(p_order_id             => l_order_id,
         p_lineitem_id          => l_lineitem_id,
         p_workitem_instance_id => l_workitem_instance_id,
         p_fa_instance_id       => l_fa_instance_id,
         p_starting_number      => l_starting_number,
	 p_ending_number        => l_ending_number,
	 x_error_code           => l_error_code,
	 x_error_message        => l_error_message
	);

    IF (l_error_code <> 0) THEN
	raise e_SMS_UPDATE_PROV_DONE_DATE;
    END IF;

    -- Completion
    resultout := 'COMPLETE';
    RETURN;

  END IF;

  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code
     null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------

      x_progress := to_char(l_error_code)||':'||l_error_message;


      XNP_UTILS.NOTIFY_ERROR
       (P_PKG_NAME             => 'XNP_WF_STANDARD'
       ,P_PROC_NAME            => 'SMS_UPDATE_PROV_DONE_DATE'
       ,P_MSG_NAME             => 'SMS_UPDATE_PROV_DONE_DATE_ERR'
       ,P_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
       ,P_TOK1                 => 'ERROR_TEXT'
       ,P_VAL1                 => x_progress
       );

      RAISE;

END SMS_UPDATE_PROV_DONE_DATE;
--
--Runtime Validation for NP Workitem
--
PROCEDURE RUNTIME_VALIDATION
 (ITEMTYPE   IN VARCHAR2
 ,ITEMKEY    IN VARCHAR2
 ,ACTID      IN NUMBER
 ,FUNCMODE   IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
l_WORKITEM_INSTANCE_ID NUMBER;
l_ORDER_ID             NUMBER;
l_LINE_ITEM_ID         NUMBER;
l_error_code           NUMBER := 0;
l_error_message        VARCHAR2(2000);
x_progress             VARCHAR2(2000):= NULL;
l_ErrCode              NUMBER:=0;
l_ErrStr               VARCHAR2(2000):=NULL;
e_Add_Item_Attr        EXCEPTION;

BEGIN

 --
  -- Call SET_SDP_CTX to set values for WI_ID and ORDER_ID
  --
  SET_SDP_CONTEXT
   (ITEMTYPE
   ,ITEMKEY
   ,ACTID
   ,'SET_ORD_WI'
   ,RESULTOUT
   );

  --
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    -- The run code

   l_WORKITEM_INSTANCE_ID := g_WORKITEM_INSTANCE_ID;
   l_ORDER_ID             := g_ORDER_ID;

   l_LINE_ITEM_ID:=
      wf_engine.GetItemAttrNumber (itemtype => itemtype,
      itemkey  => itemkey,
      aname   => 'LINE_ITEM_ID');

    XNP_STANDARD.RUNTIME_VALIDATION
     (p_ORDER_ID             => l_ORDER_ID
     ,p_LINE_ITEM_ID         => l_lIne_Item_ID
     ,p_WORKITEM_INSTANCE_ID =>l_WORKITEM_INSTANCE_ID
     ,x_ERROR_CODE           => l_error_code
     ,x_ERROR_MESSAGE        => l_error_message
     );

   IF l_error_code <> 0
       THEN

       resultout:= 'FAILURE';
      XDPCORE.CheckNAddItemAttrNumber(itemtype=> itemtype,
                                    itemkey  => itemkey,
                                    AttrName => 'RVU_ERROR_CODE',
 			            Attrvalue =>l_error_code,
 			            ErrCode =>l_ErrCode,
                                    ErrStr =>l_ErrStr);

   IF l_ErrCode<>0 THEN
      raise e_Add_Item_Attr;
   END IF;

    XDPCORE.CheckNAddItemAttrText(  itemtype=> itemtype,
                                itemkey  => itemkey,
                                AttrName => 'RVU_ERROR_MESSAGE',
 			        Attrvalue =>l_error_message,
 			        ErrCode =>l_ErrCode,
                                ErrStr =>l_ErrStr);

       IF l_ErrCode<>0 THEN
         raise e_Add_Item_Attr;
       END IF;

         wf_core.context('XNP_WF_STANDARD', 'RUNTIME_VALIDATION', itemtype,
                         itemkey, null, l_error_message);

    ELSE
        -- Completion
        resultout := 'SUCCESS';
    END IF;

  END IF;

    EXCEPTION
      WHEN OTHERS THEN

     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------
      IF (l_error_code <> 0) THEN
          x_progress := to_char(SQLCODE)||
                        to_char(l_error_code)||':'||l_error_message;
      ELSE
          x_progress := to_char(SQLCODE)||':'||SQLERRM;
      END IF;



     IF l_ErrCode <>0 THEN
         x_progress:=to_char(l_ErrCode)||':'||l_ErrStr||
                     to_char(l_error_code)||':'||l_error_message;
     ELSE
        x_progress := to_char(SQLCODE)||':'||SQLERRM;
     END IF;


       wf_core.context('XNP_WF_STANDARD', 'RUNTIME_VALIDATION', itemtype,
                         itemkey,null, x_progress);
      raise;

END RUNTIME_VALIDATION;


 --------------------------------------------------------------------
 -- Description:
 --  Calls when neet to sync item parameter values with their corresponding work items.
 --  Gets the Item Attributes LINE_ITEM_ID
 --  Calls XDP_ENGINE.XDP_SYNC_LINE_ITEM_PV
 --
 ------------------------------------------------------------------

Procedure SYNC_LI_PARAMETER_VALUES (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       out NOCOPY  varchar2 ) IS
l_line_item_id Number;
l_rtn_code number;
l_rtn_status VARCHAR2(2000);
x_progress VARCHAR2(2000);
BEGIN
--
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                l_line_item_id := wf_engine.GetItemAttrNumber(itemtype => SYNC_LI_PARAMETER_VALUES.itemtype,
                                           itemkey => SYNC_LI_PARAMETER_VALUES.itemkey,
                                           aname => 'LINE_ITEM_ID');
				IF (l_line_item_id IS NOT NULL) THEN
					XDP_ENGINE.XDP_SYNC_LINE_ITEM_PV(l_line_item_id,l_rtn_code, l_rtn_status);
				END IF;
				IF l_rtn_code = 0 THEN
						resultout := 'COMPLETE:SUCCESS';
				ELSE
						resultout := 'COMPLETE:FAILURE';
				END IF;
        END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point

-- due to a loop back.
--

        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN

                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;


EXCEPTION
	WHEN OTHERS THEN

     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------
      x_progress := to_char(SQLCODE)||':'||SQLERRM;

      wf_core.context('XNP_WF_STANDARD', 'SYNC_LI_PARAMETER_VALUES', itemtype,
                         itemkey,null, x_progress);
      raise;
END SYNC_LI_PARAMETER_VALUES;

--
--  GET_ORD_FULFILLMENT_STATUS
--  For workflow function to retrieve order fulfillment status
--  should be called from a workflow function.
--	return order fulfillment status in resultout
--  this value is set in fulfillment procedures
--	12/06/2000
--  Anping Wang
--

Procedure GET_ORD_FULFILLMENT_STATUS (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       out NOCOPY  varchar2 ) IS

l_status VARCHAR2(256);
l_OrderID NUMBER;
l_result VARCHAR2(2000);
l_return_status VARCHAR2(256);
l_code NUMBER;
x_progress VARCHAR2(256);
BEGIN
--
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
 		       l_OrderID := wf_engine.GetItemAttrNumber(itemtype => GET_ORD_FULFILLMENT_STATUS.itemtype,
                            itemkey => GET_ORD_FULFILLMENT_STATUS.itemkey,
                            aname => 'ORDER_ID');

			XDP_INTERFACES.GET_ORD_FULFILLMENT_STATUS(l_OrderID,l_status,l_result,l_code,l_return_status);
    	    resultout := l_status;

    	    IF (l_code = 0) THEN
		        XDPCORE.CheckNAddItemAttrText(ItemType => ItemType,
                                ItemKey  => ItemKey,
                                AttrName => 'FULFILLMENT_RESULT',
                                AttrValue => l_result,
                                ErrCode  =>  l_code,
                                ErrStr  =>  l_return_status);
    	   		XDPCORE.CheckNAddItemAttrText(ItemType => ItemType,
                                ItemKey  => ItemKey,
                                AttrName => 'FULFILLMENT_STATUS',
                                AttrValue => l_status,
                                ErrCode  =>  l_code,
                                ErrStr  =>  l_return_status);
        	END IF;
        END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point

-- due to a loop back.
--
        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN

                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;

EXCEPTION
	WHEN OTHERS THEN

     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------
      x_progress := to_char(SQLCODE)||':'||SQLERRM;

      wf_core.context('XNP_WF_STANDARD', 'GET_ORD_FULFILLMENT_STATUS', itemtype,
                         itemkey,null, x_progress);
      raise;
END GET_ORD_FULFILLMENT_STATUS;

--
--  SET_ORD_FULFILLMENT_STATUS
--  For workflow function to set order fulfillment status
--  should be called from a workflow function.
--	return complete in resultout
--	12/06/2000
--  Anping Wang
--

Procedure SET_ORD_FULFILLMENT_STATUS (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       out NOCOPY  varchar2 ) IS

l_status VARCHAR2(256);
l_result VARCHAR2(2000);
l_code NUMBER;
l_OrderID NUMBER;
l_return_status VARCHAR2(256);
x_progress VARCHAR2(256);
BEGIN
--
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
 		       l_OrderID := wf_engine.GetItemAttrNumber(itemtype => SET_ORD_FULFILLMENT_STATUS.itemtype,
                            itemkey => SET_ORD_FULFILLMENT_STATUS.itemkey,
                            aname => 'ORDER_ID');
		       BEGIN
			   		l_status :=
      					wf_engine.GetActivityAttrText (itemtype => itemtype,
      						itemkey  => itemkey,
      						actid => actid,
      						aname   => 'FULFILLMENT_STATUS');
		       		l_result :=
      					wf_engine.GetActivityAttrText (itemtype => itemtype,
      						itemkey  => itemkey,
      						actid => actid,
      						aname   => 'FULFILLMENT_RESULT');
				EXCEPTION
					WHEN OTHERS THEN
						l_status := nvl(l_status,'Unknown status');
						l_result := nvl(l_result,'Unknown results');
				END;

				XDP_INTERFACES.SET_ORD_FULFILLMENT_STATUS(l_OrderID,l_status,l_result,l_code,l_return_status);
    	    	resultout := l_status;
        END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point

-- due to a loop back.
--
        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN

                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;

EXCEPTION
	WHEN OTHERS THEN

     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------
     x_progress := to_char(SQLCODE)||':'||SQLERRM;

     wf_core.context('XNP_WF_STANDARD', 'SET_ORD_FULFILLMENT_STATUS', itemtype,
                         itemkey,null, x_progress);
     raise;
END SET_ORD_FULFILLMENT_STATUS;

--
--  SET_WI_FULFILLMENT_STATUS
--  For workflow function to set order fulfillment status
--  should be called from a workflow function.
--	return complete in resultout
--	12/06/2000
--  Anping Wang
--

Procedure SET_WI_FULFILLMENT_STATUS (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       out NOCOPY  varchar2 ) IS

l_status VARCHAR2(256);
l_result VARCHAR2(2000);
l_code NUMBER;
l_return_status VARCHAR2(256);
x_progress VARCHAR2(256);
l_wi_instance_id number;
BEGIN
--
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
 		       l_wi_instance_id := wf_engine.GetItemAttrNumber(itemtype => SET_WI_FULFILLMENT_STATUS.itemtype,
                            itemkey => SET_WI_FULFILLMENT_STATUS.itemkey,
                            aname => 'WORKITEM_INSTANCE_ID');

		       BEGIN
			   		l_status :=
      					wf_engine.GetActivityAttrText (itemtype => itemtype,
      						itemkey  => itemkey,
      						actid => actid,
      						aname   => 'FULFILLMENT_STATUS');
		       		l_result :=
      					wf_engine.GetActivityAttrText (itemtype => itemtype,
      						itemkey  => itemkey,
      						actid => actid,
      						aname   => 'FULFILLMENT_RESULT');
				EXCEPTION
					WHEN OTHERS THEN
						l_status := nvl(l_status,'Unknown status');
						l_result := nvl(l_result,'Unknown results');
				END;

 				BEGIN
					XDP_ENGINE.SET_WORKITEM_PARAM_VALUE(l_wi_instance_id,'FULFILLMENT_STATUS',l_status,NULL);
   					XDP_ENGINE.SET_WORKITEM_PARAM_VALUE(l_wi_instance_id,'FULFILLMENT_RESULT',l_result,NULL);
					resultout := 'COMPLETE:SUCCESS';
				EXCEPTION
					WHEN OTHERS THEN
						resultout := 'COMPLETE:FAILURE';
				END;
        END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point

-- due to a loop back.
--
        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN

                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;

EXCEPTION
	WHEN OTHERS THEN

     ------------------------------------------------------------------
     -- Record this function call in the error
     -- system in case of an exception
     ------------------------------------------------------------------
      x_progress := to_char(SQLCODE)||':'||SQLERRM;


      wf_core.context('XNP_WF_STANDARD', 'SET_WI_FULFILLMENT_STATUS', itemtype,
                         itemkey,null, x_progress);
      raise;
END SET_WI_FULFILLMENT_STATUS;

-- Bug Fix 1790288
-- When the order finishes all the waiting timers and events for the order
-- must be expired/removed
-- Raja 05/31/2001
Procedure DEREGISTER_ALL (itemtype        in varchar2,
                          itemkey         in varchar2,
                          actid           in number,
                          funcmode        in varchar2,
                          resultout       out NOCOPY  varchar2 )

IS
 x_progress VARCHAR2(2000);
 l_order_id	NUMBER;
 l_error_code NUMBER := 0;
 l_error_message VARCHAR2(2000);
 e_DEREGISTER	EXCEPTION;

BEGIN

  --
  -- RUN mode - normal process execution
  --

  IF (funcmode = 'RUN') THEN

    l_order_id :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'ORDER_ID'
      );

    -- The run code

    -- Get the event type to publish

    XNP_STANDARD.DEREGISTER_ALL
    (
     p_order_id => l_order_id
     ,x_error_code => l_error_code
     ,x_error_message => l_error_message
    );

    IF l_error_code <> 0
    THEN
	raise e_DEREGISTER;
    END IF;

    -- Completion
    resultout := 'COMPLETE';
    return;

  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
    /* Record this function call in the error
     * system in case of an exception
     */
     fnd_message.set_name('XNP','STD_ERROR');
     fnd_message.set_token(
       'ERROR_LOCN','XNP_WF_TIMERS.DEREGISTER');
     if(l_error_code <> 0) then
		fnd_message.set_token('ERROR_TEXT',
       ':'||to_char(l_error_code)||':'||l_error_message);
     else
       fnd_message.set_token('ERROR_TEXT',
         ':'||to_char(SQLCODE)||':'||SQLERRM);
     end if;
     x_progress := fnd_message.get;
     wf_core.context(
        'XNP_WF_STANDARD'
        , 'DEREGISTERALL'
        , itemtype
        , itemkey
        , to_char(actid)
        , funcmode
        , x_progress);

      RAISE;

END DEREGISTER_ALL;


Procedure downloadWIParams(itemtype in varchar2, itemkey  in varchar2) IS

 CURSOR c_get_params (cv_wi_instance_id  NUMBER)IS
 SELECT parameter_name
   FROM xdp_worklist_details
   WHERE workitem_instance_id = cv_wi_instance_id
   FOR UPDATE;


 l_param_name VARCHAR2(40);
 l_param_val  VARCHAR2(4000);
 l_atype VARCHAR2(400);
 l_sub_type VARCHAR2(400);
 l_format VARCHAR2(400);
 l_WIInstanceID number;

BEGIN

 l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => downloadWIParams.itemtype,
                                               itemkey  => downloadWIParams.itemkey,
                                               aname    => 'WORKITEM_INSTANCE_ID');

 FOR lv_rec in c_get_params( l_WIInstanceID ) LOOP
   l_param_name := lv_rec.parameter_name;

   BEGIN
     l_param_val :=  wf_engine.GetItemAttrText(itemtype => downloadWIParams.itemtype,
                                               itemkey  => downloadWIParams.itemkey,
                                               aname    => l_param_name);
     UPDATE xdp_worklist_details
        SET parameter_value = l_param_val,
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
            LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
      WHERE current of c_get_params;
   EXCEPTION
     WHEN others THEN
       -- skilaru 05/20/2002
       -- User defined workflow didnt have this item attribute defined..
       NULL;
   END;
 END LOOP;


EXCEPTION
  WHEN others THEN
    wf_core.context('XNP_WF_STANDARD', 'downloadWIParams', null, null, null, l_WIInstanceID );
    RAISE;

END downloadWIParams;

Procedure downloadFAParams( itemtype IN VARCHAR2,
                            itemkey IN VARCHAR2,
                            actid IN NUMBER,
                            p_FAInstanceID IN NUMBER ) IS

  l_param_name VARCHAR2(40);
  l_item_attrib_name VARCHAR2(40);
  l_param_value  VARCHAR2(4000);

  CURSOR c_get_fa_params( cv_fa_instance_id NUMBER ) IS
  SELECT parameter_name
    FROM xdp_fa_details
   WHERE fa_instance_id = cv_fa_instance_id
     FOR UPDATE;

BEGIN

  FOR lv_rec in c_get_fa_params( p_FAInstanceID ) LOOP
    l_param_name := lv_rec.parameter_name;
    BEGIN
      --skilaru 05/22/2002
      --Assumption is users will only use Item Attributes to set the Activity Attributes..
      --If we allow users to use type CONSTANT for Activity Attribute then we should
      --resolve the type(whether CONSTANT or Item Attribute) first before getting the value..

      --get Item attribute name..
      l_item_attrib_name := wf_engine.GetActivityAttrText(itemtype => downloadFAParams.itemtype,
                                                          itemkey  => downloadFAParams.itemkey,
                                                          actid    => downloadFAParams.actid,
                                                          aname    => l_param_name);
      --get Item attribute value..
      l_param_value :=  wf_engine.GetItemAttrText(itemtype => downloadFAParams.itemtype,
                                                itemkey  => downloadFAParams.itemkey,
                                                aname    => l_item_attrib_name);
      UPDATE xdp_fa_details
         SET parameter_value = l_param_value,
             LAST_UPDATE_DATE = sysdate,
             LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
             LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
       WHERE current of c_get_fa_params;

    EXCEPTION
      WHEN others THEN
        -- skilaru 05/20/2002
        -- User havent used this activity attribute..
        NULL;
    END;
  END LOOP;

EXCEPTION
  WHEN others THEN
    wf_core.context('XNP_WF_STANDARD', 'downloadFAParams', null, null, null, p_FAInstanceID );
    RAISE;
END downloadFAParams;


Procedure uploadFAParams( itemtype IN VARCHAR2,
                          itemkey IN VARCHAR2,
                          actid IN NUMBER,
                          p_FAInstanceID IN NUMBER ) IS

  l_param_name VARCHAR2(40);
  l_item_attrib_name VARCHAR2(40);
  l_param_value  VARCHAR2(4000);

  CURSOR c_get_fa_params( cv_fa_instance_id NUMBER ) IS
  SELECT parameter_name, parameter_value
    FROM xdp_fa_details
   WHERE fa_instance_id = cv_fa_instance_id;

BEGIN

  FOR lv_rec in c_get_fa_params( p_FAInstanceID ) LOOP
    l_param_name := lv_rec.parameter_name;
    BEGIN
      --skilaru 05/22/2002
      --Assumption is users will only use Item Attributes to set the Activity Attributes..
      --If we allow users to use type CONSTANT for Activity Attribute then we should
      --resolve the type(whether CONSTANT or Item Attribute) first before getting the value..

      --get Item attribute name..
      l_item_attrib_name := wf_engine.GetActivityAttrText(itemtype => uploadFAParams.itemtype,
                                                          itemkey  => uploadFAParams.itemkey,
                                                          actid    => uploadFAParams.actid,
                                                          aname    => l_param_name);
      l_param_value := lv_rec.parameter_value;

      --set Item attribute value..
      wf_engine.setItemAttrText(itemtype => uploadFAParams.itemtype,
                                itemkey  => uploadFAParams.itemkey,
                                aname    => l_item_attrib_name,
                                avalue   => l_param_value );
    EXCEPTION
      WHEN others THEN
        -- skilaru 05/20/2002
        -- User havent used this activity attribute..
        NULL;
    END;
  END LOOP;

EXCEPTION
  WHEN others THEN
    wf_core.context('XNP_WF_STANDARD', 'uploadFAParams', null, null, null, p_FAInstanceID );
    RAISE;
END uploadFAParams;


END XNP_WF_STANDARD;


/
