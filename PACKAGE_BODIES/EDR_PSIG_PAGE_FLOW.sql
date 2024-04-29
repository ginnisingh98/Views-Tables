--------------------------------------------------------
--  DDL for Package Body EDR_PSIG_PAGE_FLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_PSIG_PAGE_FLOW" AS
/* $Header: EDRESGPB.pls 120.11.12010000.3 2010/03/05 03:37:58 srpuri ship $ */

  --global variables
  G_YES CONSTANT varchar2(15) := 'COMPLETE:Y';
  G_NO CONSTANT varchar2(15) := 'COMPLETE:N';
  G_PRESUCCESS_STATUS CONSTANT varchar2(25) := 'PRESUCCESS';
  G_SUCCESS_STATUS CONSTANT varchar2(25) := 'SUCCESS';

  /*
  G_SEND_APPROVAL_NONE varchar2(50) := 'COMPLETE:SEND_NONE';
  G_SEND_APPROVAL_INDIVIDUAL varchar2(50) := 'COMPLETE:SEND_INDIVIDUAL';
  G_SEND_APPROVAL_FINAL varchar2(50) := 'COMPLETE:SEND_FINAL';
  */

  /*********************************************************************************
   ***   This procedure is executed when workflow process is completed in offline **
   ***   mode.                                                                    **
   *********************************************************************************/

   /********************************************************************************
    **** Bug#3368868   Starts: Function to get the transaction Status using Erecord id
    ******************************************************************/

FUNCTION GET_TRANSACTIONSTATUS (eRecordId  NUMBER)
      RETURN VARCHAR2 IS
      x_transaction_status VARCHAR2(100);
begin
      SELECT TRANSACTION_STATUS into x_transaction_status
        FROM EDR_TRANS_ACKN
       WHERE ERECORD_ID = eRecordId;
return (x_transaction_status);
end GET_TRANSACTIONSTATUS;
-- Bug #3368868   : Ends

-- Bug 3916445 : Starts
-- Introducing new wrapper Apis for workflow and notification Apis to get and
-- set item attributes (number and text)

-- returns wf number item attribute
FUNCTION GET_WF_ITEM_ATTRIBUTE_NUMBER(p_itemtype varchar2, p_itemkey varchar2,
                                      p_attname varchar2)
                   RETURN NUMBER
 IS
BEGIN

     return wf_engine.getitemattrnumber(p_itemtype, p_itemkey,p_attname, TRUE);
END GET_WF_ITEM_ATTRIBUTE_NUMBER;

-- returns wf text item attribute
FUNCTION GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype varchar2, p_itemkey varchar2,
                                    p_attname varchar2)
                   RETURN VARCHAR2
IS
BEGIN

     return wf_engine.getitemattrtext(p_itemtype, p_itemkey,p_attname, TRUE);
END GET_WF_ITEM_ATTRIBUTE_TEXT;

-- sets wf number item attribute
PROCEDURE SET_WF_ITEM_ATTRIBUTE_NUMBER(p_itemtype varchar2, p_itemkey varchar2,
                                       p_attname varchar2, p_attvalue NUMBER)
IS
BEGIN
   wf_engine.setitemattrnumber(p_itemtype,p_itemkey,p_attname,p_attvalue);
    EXCEPTION WHEN OTHERS THEN
      NULL;
END SET_WF_ITEM_ATTRIBUTE_NUMBER;

-- sets wf text item attribute
PROCEDURE SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype varchar2, p_itemkey varchar2,
                                     p_attname varchar2, p_attvalue varchar2)
IS
BEGIN
   wf_engine.setitemattrtext(p_itemtype,p_itemkey,p_attname,p_attvalue);
    EXCEPTION WHEN OTHERS THEN
      NULL;
END SET_WF_ITEM_ATTRIBUTE_TEXT;

-- returns workflow notification's number item attribute

FUNCTION GET_NOTIF_ITEM_ATTR_NUMBER(p_nid NUMBER, p_attname VARCHAR2)
                        RETURN NUMBER
IS
 l_number NUMBER;
BEGIN
  l_number := null;
  BEGIN
       l_number := wf_notification.GETATTRNUMBER(p_nid, p_attname);
    EXCEPTION WHEN OTHERS THEN
      NULL;
   END;
  return l_number;
END GET_NOTIF_ITEM_ATTR_NUMBER;
-- returns workflow notification's text item attribute

FUNCTION GET_NOTIF_ITEM_ATTR_TEXT(p_nid NUMBER, p_attname VARCHAR2)
                        RETURN VARCHAR2
IS
 l_text VARCHAR2(1000);
BEGIN
  l_text := null;
  BEGIN
    l_text := wf_notification.GETATTRTEXT(p_nid, p_attname);
    EXCEPTION WHEN OTHERS THEN
      NULL;
   END;
return l_text;
END GET_NOTIF_ITEM_ATTR_TEXT;
-- Bug 3916445 : Starts


  PROCEDURE EXECUTE_POST_OP_API(
                      p_itemtype   IN VARCHAR2,
                      p_itemkey    IN VARCHAR2,
                      p_result     IN VARCHAR2) IS
     L_POST_OP_API   VARCHAR2(4000) := null;
     l_sql           varchar2(4000);
     l_occur         number;
     l_last_char     VARCHAR2(1);
     l_trans_status  VARCHAR2(100);
     l_eRecord_id    NUMBER := null;
    BEGIN
    --  Bug #3368868  : Starts
    --  Get the transaction status

    --  Bug 3903471 : Start
        l_eRecord_id := GET_WF_ITEM_ATTRIBUTE_NUMBER(p_itemtype,p_itemkey,'EDR_PSIG_DOC_ID');

        if l_eRecord_id is NULL THEN
          l_eRecord_id := TO_NUMBER(GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#ERECORD_ID'),'999999999999.999999');
        end if;

        l_trans_status := GET_TRANSACTIONSTATUS(l_eRecord_id) ;
    --  Bug 3903471 : End

    --  Bug #3368868  : Ends

     EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS := p_result;
     EDR_STANDARD_PUB.G_SIGNATURE_STATUS := p_result;
    --  Bug #3368868  : Starts
    -- If transaction status is ERROR do not call post_op_api
      IF l_trans_status <> 'ERROR' THEN
    --  Bug #3368868  : Ends
        L_POST_OP_API := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'POST_OPERATION_API');
      END IF;

        IF nvl(L_POST_OP_API,'NONE') <> 'NONE'  THEN
        L_POST_OP_API := rtrim(L_POST_OP_API);
        l_last_char := SUBSTR(L_POST_OP_API,LENGTH(L_POST_OP_API));
        IF l_last_char <> ';' THEN
            L_POST_OP_API := L_POST_OP_API ||';';
        END IF;
            l_sql:='BEGIN'||FND_GLOBAL.Newline||
                   L_POST_OP_API|| FND_GLOBAL.Newline||
                   'END;'|| FND_GLOBAL.Newline;
            EXECUTE IMMEDIATE l_SQL;
    END IF;

    --  Bug 3411859 : Start
    --  Signature status should be set to null in all cases .
        EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS := null;
        EDR_STANDARD_PUB.G_SIGNATURE_STATUS := null;
    --  Bug 3411859  : End

  EXCEPTION
  WHEN OTHERS THEN
        EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS := null;
        EDR_STANDARD_PUB.G_SIGNATURE_STATUS := null;
        WF_CORE.CONTEXT('EDR_PSIG_PAGE_FLOW','Post Operation Proc Excution',p_itemtype,p_itemkey,l_SQL);
        raise;
   END;


/************************************************************************
***  Function to get event display name from workflow business events ***
***  Tables.                                                          ***
*************************************************************************/

  Function Get_event_disp_name (p_event_id varchar2) return VARCHAR2 IS
    L_event_name Varchar2(80);
    L_event_disp_name VARCHAR2(240);
  BEGIN
    SELECT event_name into l_event_name
    FROM EDR_ERECORDS
    WHERE event_id = p_event_id;
    select display_name into L_event_disp_name
    from wf_events_vl
    where name = l_event_name;
    return(L_event_disp_name);
  EXCEPTION WHEN OTHERS THEN
    WF_CORE.CONTEXT ('EDR_PSIG_PAGE_FLOW','Get_event_disp_name',p_event_id);
    raise;
  END;




/************************************************************************
***  Following Procedure Returns current page flow process status    ****
***  It accepts Event ID as in parameter                             ****
*************************************************************************/

  PROCEDURE GET_PAGE_FLOW_STATUS(P_EVENT_ID IN NUMBER ,
                                 P_SIGNATURE_STATUS  OUT NOCOPY VARCHAR2) IS
    l_count   NUMBER;

  BEGIN

    SELECT count(*)  INTO l_count
    from EDR_ESIGNATURES
    WHERE EVENT_ID = P_event_id
      AND SIGNATURE_STATUS <> 'APPROVED';

    IF l_count = 0 THEN  -- All Are Approved
      P_SIGNATURE_STATUS := 'SUCCESS';
    ELSE  -- Not All are Approved
      SELECT count(*)  INTO l_count
      from EDR_ESIGNATURES
      WHERE EVENT_ID = p_event_id
      AND SIGNATURE_STATUS = 'REJECTED';
      IF l_count > 0 THEN
        /* Means Some one is rejected */
        P_SIGNATURE_STATUS := 'REJECTED';
      ELSE
         SELECT count(*)  INTO l_count
         from EDR_ESIGNATURES
         WHERE EVENT_ID = p_event_id
         AND SIGNATURE_STATUS = 'TIMEDOUT';
         IF l_count > 0 THEN
        /* Means Timeout SKARIMIS*/
          P_SIGNATURE_STATUS := 'TIMEDOUT';
         ELSE
          P_SIGNATURE_STATUS := 'PENDING';
         END IF;
      END IF; -- Pending or rejected caeses
    END IF;
  END GET_PAGE_FLOW_STATUS;



 --Bug 4577122 : start
 PROCEDURE GET_PAGE_FLOW_STATUS_NEW(P_EVENT_ID IN NUMBER ,
                                     P_VOTING_REGIME IN VARCHAR2,
                                 P_SIGNATURE_STATUS  OUT NOCOPY VARCHAR2) IS
    l_count   NUMBER;

    --Change related to bug 4577122
    l_approver_count number;
    --Change related to bug 4577122

  BEGIN

    --Change related to bug 4577122
    if (p_voting_regime = ame_util.firstApproverVoting) then

      select count(*) into l_approver_count
      from edr_esignatures
      where event_id = p_event_id
      and signature_status = 'APPROVED';

      if (l_approver_count > 0) then
        P_SIGNATURE_STATUS := 'SUCCESS';
        return;
      end if;
    end if;
    --Change related to bug 4577122

    SELECT count(*)  INTO l_count
    from EDR_ESIGNATURES
    WHERE EVENT_ID = P_event_id
    AND SIGNATURE_STATUS <> 'APPROVED';

    IF l_count = 0 THEN  -- All Are Approved
      P_SIGNATURE_STATUS := 'SUCCESS';
    ELSE  -- Not All are Approved
      SELECT count(*)  INTO l_count
      from EDR_ESIGNATURES
      WHERE EVENT_ID = p_event_id
      AND SIGNATURE_STATUS = 'REJECTED';

      IF l_count > 0 THEN
        /* Means Some one is rejected */
        P_SIGNATURE_STATUS := 'REJECTED';
      ELSE
         SELECT count(*)  INTO l_count
         from EDR_ESIGNATURES
         WHERE EVENT_ID = p_event_id
         AND SIGNATURE_STATUS = 'TIMEDOUT';
         IF l_count > 0 THEN
        /* Means Timeout SKARIMIS*/
          P_SIGNATURE_STATUS := 'TIMEDOUT';
         ELSE
          P_SIGNATURE_STATUS := 'PENDING';
         END IF;
      END IF; -- Pending or rejected caeses

    END IF;
  END GET_PAGE_FLOW_STATUS_NEW;
  --Bug 4577122 : end

  /*******************************************************************************
   ***   This procedure is associated with EDRESGPF workflow.  This code will   **
   ***   execute when user clicks on Authenticate Button in list of signer page **
   *******************************************************************************/

  PROCEDURE AUTHENTICATE_RESPONSE(
     /* procedure to signature process response in case of Authenticate  */
      p_itemtype   IN VARCHAR2,
      p_itemkey    IN VARCHAR2,
      p_actid      IN NUMBER,
      p_funcmode   IN VARCHAR2,
      p_resultout  OUT NOCOPY VARCHAR2
   )
   IS
  BEGIN
       IF (p_funcmode = 'RUN') THEN
/*
           wf_engine.setitemAttrText(p_itemtype, p_itemkey,'REASON_CODE',null);
           wf_engine.setitemAttrText(p_itemtype, p_itemkey,'WF_SIGNER_TYPE',null);
*/
           SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'REASON_CODE','PSIG_NONE');
           SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'SIGNERS_COMMENT',null);
           SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'WF_SIGNER_TYPE','AUTHOR');
           SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'SIGNERS_COMMENT',null);

           SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'READ_RESPONSE','N');
           p_resultout := 'COMPLETE:';
       END IF;
  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('EDR_PSIG_PAGE_FLOW','AUTHENTICATE_RESPONSE',p_itemtype,p_itemkey,'Notified');
      raise;
  END;
/*******************************************************************************************
*****    Update record status to cancel assuming EVENT_ID and Workflow ITEM_KEY is Same  ***
********************************************************************************************/
  PROCEDURE CANCEL_RESPONSE(
     /* procedure to signature process response in case of Cancel   */
      p_itemtype   IN VARCHAR2,
      p_itemkey    IN VARCHAR2,
      p_actid      IN NUMBER,
      p_funcmode   IN VARCHAR2,
      p_resultout  OUT NOCOPY VARCHAR2
   )
   IS
     L_doc_id          NUMBER;
     EDR_PSIG_DOC_ERR  EXCEPTION;
     l_error_num       NUMBER;
     l_ERROR_MESG      VARCHAR(2000);
     --Bug 3634954 : Start
     --A new variable to hold the erecord id in varchar2 format
     --Bug 3634954 : End
     l_erecord_id      VARCHAR2(128);
   BEGIN
     IF (p_funcmode = 'RUN') THEN

           /* Update workflow STATUS to Cancel */

           UPDATE EDR_ERECORDS
           SET ERECORD_SIGNATURE_STATUS = 'CANCEL'
           WHERE  EVENT_ID   =  P_itemkey;

	   --Bug 3634954 : Start
	   --The following line is commented, as from now on erecord id will be fetched from the
	   --#ERECORD_ID workflow parameter instead of EDR_PSIG_DOC_ID parameter.

     --Bug 3903471 : Start
     --However #ERECORD_ID parameter is not used in older versions. Hence to
     --support backward compatibility a conditional check would be provided.

     l_doc_id := GET_WF_ITEM_ATTRIBUTE_NUMBER(p_itemtype, p_itemkey,'EDR_PSIG_DOC_ID');

     if l_doc_id is NULL THEN

  	   l_erecord_id := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,p_itemkey,'#ERECORD_ID');

           --Convert erecord id obtained in varchar2 to number format.
  	   --To ensure that no problems occur in MLS environments appropriate number format is used.

           l_doc_id := TO_NUMBER(l_erecord_id,'999999999999.999999');

     end if;
     --Bug 3903471 : End

	   --Bug 3634954 : End


           IF l_doc_id IS NOT NULL THEN
                EDR_PSIG.changeDocumentStatus( P_DOCUMENT_ID       => l_doc_id,
                                               P_STATUS            => 'CANCEL',
                                               P_ERROR             => l_error_num,
                                               P_ERROR_MSG         => l_error_mesg);
                --Bug 3207385: Start
                WF_ENGINE.ADDITEMATTR(itemtype   => p_itemtype,
                                      itemkey    => p_itemkey,
        		              aname      => EDR_CONSTANTS_GRP.G_FINAL_DOCUMENT_STATUS,
                                      text_value => EDR_CONSTANTS_GRP.G_CANCEL_STATUS);
                --Bug 3207385: End
             IF  l_ERROR_NUM IS NOT NULL THEN
               RAISE EDR_PSIG_DOC_ERR;
             END IF;
           END IF;
           -- Bug Fix: 3178035
           -- Modified Page flow status to 'ERROR'
           -- As per cookbook get transaction status returns one of these
           -- status ('SUCCESS','ERROR','REJECTED','PENDING','NOACTION')
           -- based on this we need to send 'ERROR'
           SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_PAGEFLOW_STATUS','ERROR');
           p_resultout := 'COMPLETE:';
    END IF;
   EXCEPTION
     WHEN EDR_PSIG_DOC_ERR THEN
        WF_CORE.CONTEXT ('EDR_PSIG_PAGE_FLOW','CANCEL_RESPONSE',p_itemtype,p_itemkey,
                         l_error_num,L_ERROR_MESG);
        raise;
     WHEN OTHERS THEN
      WF_CORE.CONTEXT ('EDR_PSIG_PAGE_FLOW','CANCEL_RESPONSE',p_itemtype,p_itemkey,'OK');
      raise;
   END;
   /******************************************************************************************
    ***  This is the main procedure which controls total offline flow and response to done ***
    ***  incase of on-line. When user clicks on done button and still some responses are   ***
    ***  pending then this procedure verifies deferred mode is allowed or not. if deferred ***
    ***  mode is allowed sets the workflow mode to OFFLINE.                                ***
    ******************************************************************************************/

   PROCEDURE PROCESS_RESPONSE(
     /* procedure to signature process Incase of all OFFLINE cases and ONLINE when user selects Done    */
      p_itemtype   IN VARCHAR2,
      p_itemkey    IN VARCHAR2,
      p_actid      IN NUMBER,
      p_funcmode   IN VARCHAR2,
      p_resultout  OUT NOCOPY VARCHAR2
   )
   IS
     L_CURR_MODE VARCHAR2(30);
     L_DEFER_MODE_ALLOWED VARCHAR2(30);
     l_EVENT_ID NUMBER;

     L_SIGNATURE_STATUS VARCHAR2(30);
     L_doc_id          NUMBER;
     EDR_PSIG_DOC_ERR  EXCEPTION;
     l_error_num       NUMBER;
     l_ERROR_MESG      VARCHAR(2000);
     l_ERROR_MSG       VARCHAR(4000);

     -- Bug 4213923 : Start
     l_username VARCHAR2(100);
     l_overriding_approver VARCHAR2(100);
     l_overriding_comments VARCHAR2(100);
     l_signature_id NUMBER;
     l_esign_id VARCHAR2(100);
     l_value VARCHAR2(100);

     CURSOR C1(l_document_id NUMBER) IS
       Select original_recipient from edr_psig_details
       where document_id = l_document_id and USER_RESPONSE is null;
     -- Bug 4213923 : End

     --Bug 4577122: Start
     l_ignore_wfattr_notfound boolean := true;
     l_voting_regime varchar2(1);
     --Bug 4577122: End

   BEGIN

     --Bug 4074173 : start
     L_CURR_MODE := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_CURRENT_MODE');
     L_DEFER_MODE_ALLOWED  := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'DEFERRED');
     l_EVENT_ID := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_PAGEFLOW_ITEMKEY');
     --Bug 4074173 : end

     --Bug 4577122: Start
     l_voting_regime := wf_engine.GetitemAttrText
                   (p_itemtype, p_itemkey,'AME_VOTING_REGIME',
                                  l_ignore_wfattr_notfound);
     --Bug 4577122: End

     IF (p_funcmode = 'RUN') THEN

       SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'REASON_CODE','PSIG_NONE');
       SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'SIGNERS_COMMENT',null);
       SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'WF_SIGNER_TYPE','AUTHOR');

       --Bug 4577122: Start
       --GET_PAGE_FLOW_STATUS(L_EVENT_ID,L_SIGNATURE_STATUS);
       GET_PAGE_FLOW_STATUS_NEW(L_EVENT_ID,l_voting_regime, L_SIGNATURE_STATUS);
       --Bug 4577122: End

       IF L_SIGNATURE_STATUS in ('SUCCESS','REJECTED','TIMEDOUT') THEN

         l_doc_id := GET_WF_ITEM_ATTRIBUTE_NUMBER(p_itemtype, p_itemkey,'EDR_PSIG_DOC_ID');

         --Bug 4577122: Start
         --clear out the status etc fields of edr_psig_details IFF voting regime is F
         if (l_voting_regime = ame_util.firstApproverVoting) then
              edr_psig.clear_pending_signatures(l_doc_id);
         end if;
         --Bug 4577122: End

         UPDATE EDR_ERECORDS
         SET ERECORD_SIGNATURE_STATUS = L_SIGNATURE_STATUS
         WHERE  EVENT_ID   =  l_event_id;


         IF L_SIGNATURE_STATUS = 'SUCCESS' THEN

           EDR_PSIG.closeDocument( P_DOCUMENT_ID       => l_doc_id,
                                   P_ERROR             => l_error_num,
                                   P_ERROR_MSG         => l_error_mesg);

           --Bug 3207385: Start
           WF_ENGINE.ADDITEMATTR(itemtype   => p_itemtype,
                                 itemkey    => p_itemkey,
                      		 aname      => EDR_CONSTANTS_GRP.G_FINAL_DOCUMENT_STATUS,
                                 text_value => EDR_CONSTANTS_GRP.G_COMPLETE_STATUS);
           --Bug 3207385: End

           IF  l_ERROR_NUM IS NOT NULL THEN
             RAISE EDR_PSIG_DOC_ERR;
           END IF;
         ELSIF L_SIGNATURE_STATUS ='REJECTED' THEN
           EDR_PSIG.changeDocumentStatus( P_DOCUMENT_ID       => l_doc_id,
                                          P_STATUS            => 'REJECTED',
                                          P_ERROR             => l_error_num,
                                          P_ERROR_MSG         => l_error_mesg);
           --Bug 3207385: Start
           WF_ENGINE.ADDITEMATTR(itemtype   => p_itemtype,
                                 itemkey    => p_itemkey,
        		         aname      => EDR_CONSTANTS_GRP.G_FINAL_DOCUMENT_STATUS,
                                 text_value => L_SIGNATURE_STATUS);
           --Bug 3207385: End
           IF  l_ERROR_NUM IS NOT NULL THEN
             RAISE EDR_PSIG_DOC_ERR;
           END IF;

         ELSIF L_SIGNATURE_STATUS ='TIMEDOUT' THEN
           /* Check for the first person timeout. In this case doc_id might be null.
              so fetch it from PSIG_DOCUMENT_ID */
           IF l_doc_id is NULL then
             l_doc_id := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'PSIG_DOCUMENT_ID');
           END IF;


           EDR_PSIG.changeDocumentStatus( P_DOCUMENT_ID       => l_doc_id,
                                          P_STATUS            => 'TIMEDOUT',
                                          P_ERROR             => l_error_num,
                                          P_ERROR_MSG         => l_error_mesg);
           --Bug 3207385: Start
           WF_ENGINE.ADDITEMATTR(itemtype   => p_itemtype,
                                 itemkey    => p_itemkey,
        		         aname      => EDR_CONSTANTS_GRP.G_FINAL_DOCUMENT_STATUS,
                                 text_value => L_SIGNATURE_STATUS);
           --Bug 3207385: End

           IF  l_ERROR_NUM IS NOT NULL THEN
             RAISE EDR_PSIG_DOC_ERR;
           END IF;

         END IF;

         IF L_CURR_MODE = 'OFFLINE' THEN
           EXECUTE_POST_OP_API
           (p_itemtype   ,
            p_itemkey    ,
            L_SIGNATURE_STATUS);
         END IF;

         SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_PAGEFLOW_STATUS',L_SIGNATURE_STATUS);
         IF L_SIGNATURE_STATUS = 'SUCCESS' THEN
           p_resultout := 'COMPLETE:RESP_DONE_COMPLETED';
         ELSE
           p_resultout := 'COMPLETE:PSIG_REJECTED';
         END IF;

       ELSE  -- Still Pending Cases are there

         l_doc_id := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'PSIG_DOCUMENT_ID');

         -- Bug 4213923 : Start

         OPEN C1(l_doc_id);

         --for all users which have not signed yet find out offline
         --overiding approvers and update the tables with that info
	 LOOP
	   fetch C1 into l_username;

           if C1%NOTFOUND THEN
             CLOSE C1;
             EXIT;
	   END IF;

           --obtain the overiding details for offline ntf
           EDR_STANDARD.FIND_WF_NTF_RECIPIENT
           (P_ORIGINAL_RECIPIENT      => l_username,
            P_MESSAGE_TYPE            => 'EDRPSIGF',
            P_MESSAGE_NAME            => 'PSIG_OFFLINE_MSG_11511',
            P_RECIPIENT               => l_overriding_approver,
            P_NTF_ROUTING_COMMENTS    => l_overriding_comments,
            P_ERR_CODE                => l_error_num,
            P_ERR_MSG                 => l_error_mesg);

           --update the edr_psig_details table for correct evidence store
           --information
	   UPDATE EDR_PSIG_DETAILS
           SET USER_NAME=nvl(l_overriding_approver,l_username),
           SIGNATURE_OVERRIDING_COMMENTS = l_overriding_comments
	   where document_id = l_doc_id
	   and user_response is null
           and ORIGINAL_RECIPIENT = l_username;

           --update the edr_esignature tables for correct ntf history rgn
           --information
           UPDATE EDR_ESIGNATURES
           SET USER_NAME = nvl(l_overriding_approver,l_username) ,
           SIGNATURE_OVERRIDING_COMMENTS = l_overriding_comments
           where event_id = l_event_id
           and ORIGINAL_RECIPIENT = l_username;

         END LOOP;
         -- Bug 4213923 : End

         IF  L_DEFER_MODE_ALLOWED <> 'Y' THEN
           UPDATE EDR_ERECORDS
           SET ERECORD_SIGNATURE_STATUS = 'FAILURE'
           WHERE  EVENT_ID   =  p_itemkey;

           p_resultout := 'COMPLETE:PSIG_INCOMPLETE';
           SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_PAGEFLOW_STATUS','FAILURE');
           IF l_doc_id IS NOT NULL THEN
             EDR_PSIG.changeDocumentStatus( P_DOCUMENT_ID       => l_doc_id,
                                            P_STATUS            => 'ERROR',
                                            P_ERROR             => l_error_num,
                                            P_ERROR_MSG         => l_error_mesg);
             IF  l_ERROR_NUM IS NOT NULL THEN
               RAISE EDR_PSIG_DOC_ERR;
             END IF;
           END IF;
         ELSE
           SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_CURRENT_MODE','OFFLINE');
           SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_PAGEFLOW_STATUS','PENDING');

           UPDATE EDR_ERECORDS
           SET ERECORD_SIGNATURE_STATUS = 'PENDING'
           WHERE  EVENT_ID   =  p_itemkey;

           IF l_doc_id IS NOT NULL THEN
             EDR_PSIG.changeDocumentStatus( P_DOCUMENT_ID       => l_doc_id,
                                            P_STATUS            => 'PENDING',
                                            P_ERROR             => l_error_num,
                                            P_ERROR_MSG         => l_error_mesg);
             IF  l_ERROR_NUM IS NOT NULL THEN
               RAISE EDR_PSIG_DOC_ERR;
             END IF;
           END IF;

           p_resultout := 'COMPLETE:RESP_DONE_OFFLINE';
         END IF; --end if L_DEFER_MODE_ALLOWED <> 'Y'

       END IF; --end if IF L_SIGNATURE_STATUS in ('SUCCESS','REJECTED','TIMEDOUT')

     END IF; -- end if Run Mode

   EXCEPTION
      WHEN EDR_PSIG_DOC_ERR THEN
        WF_CORE.CONTEXT ('EDR_PSIG_PAGE_FLOW','PROCESS_RESPONSE',p_itemtype,p_itemkey,
                         l_error_num,l_error_msg||L_ERROR_MESG);
        raise;
      WHEN OTHERS THEN
        WF_CORE.CONTEXT ('EDR_PSIG_PAGE_FLOW','PROCESS_RESPONSE',p_itemtype,p_itemkey,L_ERROR_MSG);
        raise;
   END;

/****************************************************************
*****  This procedure associated with Notification this is   ****
*****  used to store data in PSIG evidence store             ****
*****************************************************************/

   PROCEDURE UPDATE_NOTIF_RESPONSE(
      p_itemtype   IN VARCHAR2,
      p_itemkey    IN VARCHAR2,
      p_actid      IN NUMBER,
      p_funcmode   IN VARCHAR2,
      p_resultout  OUT NOCOPY VARCHAR2
   )
   IS
     l_SIGNER_TYPE     VARCHAR2(30);
     l_signer_reason   VARCHAR2(32);
     EDR_PSIG_NOT_NULL EXCEPTION;
     EDR_PSIG_DOC_ERR  EXCEPTION;
     EDR_PSIG_NOT_READ EXCEPTION;

     L_doc_id          NUMBER;
     L_signature_id    NUMBER;
     l_error_num       NUMBER;
     l_ERROR_MESG      VARCHAR(2000);

     l_doc_format      VARCHAR2(30);
     l_psig_event      WF_EVENT_T;
     l_paramlist       WF_PARAMETER_LIST_T;
     l_doc_params      EDR_PSIG.params_table;
     l_sign_params     EDR_PSIG.params_table;
     i                 INTEGER;

     l_event_xml       CLOB ;
     l_event_text      CLOB ;
     l_event_name      VARCHAR2(240);
     l_event_key       VARCHAR2(240);
     L_ROLE            VARCHAR2(320);
     L_MESSAGE_TYPE    VARCHAR2(80);
     L_MESSAGE_NAME    VARCHAR2(80);
     L_PRIORITY        VARCHAR2(80);
     L_DUE_DATE        VARCHAR2(80);
     L_STATUS          VARCHAR2(80);

     l_item_type       VARCHAR2(240);
     l_item_key        VARCHAR2(240);
     L_response        VARCHAR2(80);


     CURSOR GET_RESPONSE_ATTR IS
       select WMA.NAME,WMA.DISPLAY_NAME, WL.meaning
       from WF_NOTIFICATION_ATTRIBUTES WNA, WF_NOTIFICATIONS WN,
         WF_MESSAGE_ATTRIBUTES_VL WMA , WF_LOOKUPS WL
       where WNA.NOTIFICATION_ID = wf_engine.context_nid
         and WNA.NOTIFICATION_ID = WN.NOTIFICATION_ID
         and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
         and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
         and WNA.NAME = WMA.NAME
         and wma.subtype='RESPOND'
         and wma.format = wl.lookup_type
         and wna.text_value = wl.lookup_code
         and wma.type ='LOOKUP'
         and decode(wma.name,'RESULT','RESULT','NORESULT') = 'NORESULT'
      union
      select WMA.NAME,WMA.DISPLAY_NAME, decode(wma.type,'VARCHAR2',wna.text_value,'NUMBER',
           to_char(wna.number_value),'DATE',to_char(wna.date_value))
      from WF_NOTIFICATION_ATTRIBUTES WNA, WF_NOTIFICATIONS WN,
         WF_MESSAGE_ATTRIBUTES_VL WMA
      where WNA.NOTIFICATION_ID = wf_engine.context_nid
        and WNA.NOTIFICATION_ID = WN.NOTIFICATION_ID
        and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
        and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
        and WNA.NAME = WMA.NAME
        and wma.subtype='RESPOND'
        and wma.type <>'LOOKUP'
        and decode(wma.name,'RESULT','RESULT','NORESULT') = 'NORESULT';

     CURSOR GET_USER_RESPONSE_RESULT IS
       select WL.LOOKUP_CODE,WMA.DISPLAY_NAME, WL.meaning
       from WF_NOTIFICATION_ATTRIBUTES WNA, WF_NOTIFICATIONS WN,
         WF_MESSAGE_ATTRIBUTES_VL WMA , WF_LOOKUPS WL
       where WNA.NOTIFICATION_ID = wf_engine.context_nid
         and WNA.NOTIFICATION_ID = WN.NOTIFICATION_ID
         and WN.MESSAGE_NAME = WMA.MESSAGE_NAME
         and WN.MESSAGE_TYPE = WMA.MESSAGE_TYPE
         and WNA.NAME = WMA.NAME
         and wma.subtype='RESPOND'
         and wma.format = wl.lookup_type
         and wna.text_value = wl.lookup_code
         and wma.type ='LOOKUP'
         and decode(wma.name,'RESULT','RESULT','NORESULT') = 'RESULT';


      GET_USER_RESPONSE_RESULT_REC GET_USER_RESPONSE_RESULT%ROWTYPE;
      GET_RESPONSE_ATTR_REC GET_RESPONSE_ATTR%ROWTYPE;

  /* This Cursor is to build the temporary group for sending rejection notification */
     CURSOR GET_USER is
     SELECT distinct USER_NAME from EDR_ESIGNATURES where to_char(event_id)=l_item_key;

    l_requester VARCHAR2(4000) ;
    l_user varchar2(100);
    l_userlist  WF_DIRECTORY.UserTable;
    ui number := 1;

    l_display_name varchar2(240);
    l_group varchar2(240);
    l_ESIGN_ID VARCHAR2(30);

    /* this curosr is to get original approve */
    --Bug 3214398: start
    /*Get User_Name alongwith original recipient*/
    /*
    CURSOR original_recipient is
     SELECT ORIGINAL_RECIPIENT from EDR_ESIGNATURES where
     signature_id=l_esign_id;
    */
    CURSOR signer_detail is
     SELECT  ORIGINAL_RECIPIENT, USER_NAME from EDR_ESIGNATURES where
     signature_id = l_esign_id;
    l_user_name varchar2(200);
    l_overriding_approver varchar2(200);
    l_overriding_comments varchar2(4000);
    --Bug 3214398: end

    l_erec_template_type varchar2(256);
    l_responder varchar2(200);
    l_original_recipient varchar2(200);
    l_comments varchar2(4000);
    /* End of enhancemtns */
    L_NTF_RESPOND_ROLE  varchar2(320);
    L_NTF_MESSAGE_TYPE  varchar2(240);
    L_NTF_MESSAGE_NAME  varchar2(240);
    L_NTF_PRIORITY      varchar2(240);
    L_NTF_DUE_DATE      varchar2(240);
    L_NTF_STATUS        varchar2(240);

    L_RESPONSE_READ     varchar2(240);

    --Bug 2674799 : start
     l_count number;

     L_CURR_SIGN_LEVEL number;


     lp_itemtype varchar2(50);
     lp_itemkey varchar2(50);
     lp_status varchar2(50);
     lp_result varchar2(50);
     lp_notification_id varchar2(50);
     lp_curr number;
     lc_itemkey varchar2(50);


     CURSOR CURR_LIST_SIGNERS IS
       SELECT event_name, SIGNATURE_ID,NVL(ORIGINAL_RECIPIENT,USER_NAME) USER_NAME
       FROM EDR_ESIGNATURES
       WHERE EVENT_ID = lp_itemkey
         --Bug 4272262: Start
	 --Convert signature sequence to a number value.
         AND  to_number(SIGNATURE_SEQUENCE,'999999999999.999999') = L_CURR_SIGN_LEVEL
	 --Bug 4272262: End
         AND SIGNATURE_STATUS='PENDING';

     SIGNER_LIST_REC  CURR_LIST_SIGNERS%ROWTYPE;

    --Bug 2674799 : end


    --Bug 4577122: Start
    l_ignore_wfattr_notfound boolean := true;
    l_voting_regime varchar2(1);
    --Bug 4577122: End

  BEGIN

    --Bug 4074173 : start

     l_doc_format      := 'text/plain';
     l_item_type       := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_PAGEFLOW_ITEMTYPE');
     l_item_key        := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_PAGEFLOW_ITEMKEY');
     l_userlist(1)     := GET_WF_ITEM_ATTRIBUTE_TEXT(l_item_type, l_item_key,'#WF_SIGN_REQUESTER');
     l_requester       := GET_WF_ITEM_ATTRIBUTE_TEXT(l_item_type, l_item_key,'#WF_SIGN_REQUESTER');

     l_display_name :='eSignature Group';
     l_group :='EDRPSIG_ROLE';
     l_ESIGN_ID := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_ESIGN_ROW_ID');

     l_event_xml := null;
     l_event_text := null;

    --Bug 4074173 : end

    -- Bug 4577122: Start
     l_voting_regime := wf_engine.GetitemAttrText
                        (p_itemtype, p_itemkey,'AME_VOTING_REGIME',
                              l_ignore_wfattr_notfound);
    --Bug 4577122: End
    -- Bug 5120197 : start
    IF(p_funcmode = 'TRANSFER' OR p_funcmode = 'FORWARD') THEN
          OPEN signer_detail;
           FETCH signer_detail into  l_original_recipient, l_user_name;
          CLOSE signer_detail;

         -- Bug 3902969 : Start
         --  Check if the recipient l_user_name is same as WF_ENGINE.CONTEXT_TEXT
         --  if they are differnt then only call find wf ntf recipients API.

         IF( l_user_name = WF_ENGINE.CONTEXT_USER) THEN

            WF_CORE.CONTEXT ('EDR_PSIG_PAGE_FLOW','UPDATE_NOTIF_RESPONSE',
              p_itemtype,p_itemkey,
              FND_MESSAGE.GET_STRING('EDR','EDR_EREC_REASSIGN_ERR'));
	    raise_application_error(-20003,FND_MESSAGE.GET_STRING('EDR','EDR_EREC_REASSIGN_ERR'));
        END IF;
    END IF;

    -- Bug 5120197 : END

    IF (p_funcmode = 'RESPOND') THEN

      l_SIGNER_TYPE     := GET_NOTIF_ITEM_ATTR_TEXT(wf_engine.context_nid,'WF_SIGNER_TYPE');
      l_signer_reason   := GET_NOTIF_ITEM_ATTR_TEXT(wf_engine.context_nid,'REASON_CODE');
      IF l_signer_reason IS null OR l_SIGNER_TYPE IS NULL THEN
        WF_CORE.CONTEXT ('EDR_PSIG_PAGE_FLOW','UPDATE_NOTIF_RESPONSE',p_itemtype,p_itemkey,
                         'Signer Comment and Signing Reason code can not be null.');
        raise EDR_PSIG_NOT_NULL;
      END IF;

      -- Bug 3170251 : Check if user has selected yes for reading the attached eRecord
      OPEN GET_USER_RESPONSE_RESULT;
      FETCH GET_USER_RESPONSE_RESULT INTO GET_USER_RESPONSE_RESULT_REC;
      IF GET_USER_RESPONSE_RESULT%FOUND THEN
 	       IF GET_USER_RESPONSE_RESULT_REC.LOOKUP_CODE <> '#SIG_CANCEL' THEN
	         -- Begin Bug 3847779
                   -- The getattrtext has been wrapped in a being and end block to trap wf exception if
                   -- attribute is not found for previous notificaitons backward compitability.
		   	  L_RESPONSE_READ := GET_NOTIF_ITEM_ATTR_TEXT(wf_engine.context_nid, 'READ_RESPONSE');
                   -- End Bug 3847779
			  IF (L_RESPONSE_READ = 'N') THEN
			  	  	 WF_CORE.CONTEXT('EDR_PSIG_PAGE_FLOW', 'UPDATE_NOTIF_RESPONSE',p_itemtype, p_itemkey,
		 		 	 FND_MESSAGE.GET_STRING('EDR','EDR_EREC_NOT_REVIEWED_ERR'));
		             raise_application_error(-20002,FND_MESSAGE.GET_STRING('EDR','EDR_EREC_NOT_REVIEWED_ERR'));
	                  END IF;
                END IF;


                --BUg 2674799 : start
                 lp_curr := INSTR(p_itemkey,'-');
	         lp_itemkey := SUBSTR(p_itemkey,0,lp_curr-1);

                --Bug 4577122 : start

                 IF GET_USER_RESPONSE_RESULT_REC.LOOKUP_CODE = 'REJECTED' or
                    (GET_USER_RESPONSE_RESULT_REC.LOOKUP_CODE = 'APPROVED' AND
                      L_VOTING_REGIME = ame_util.firstApproverVoting) THEN
                --Bug 4577122 : end

                      --Bug 4272262: Start
                      --Convert signature sequence to a number value.
                      SELECT MIN(to_number(SIGNATURE_SEQUENCE,'999999999999.999999')) INTO L_CURR_SIGN_LEVEL
                      from EDR_ESIGNATURES
                      WHERE EVENT_ID =lp_itemkey
                      AND SIGNATURE_STATUS = 'PENDING' ;
                      --Bug 4272262: End

                      OPEN CURR_LIST_SIGNERS;
                      LOOP

                      FETCH CURR_LIST_SIGNERS INTO SIGNER_LIST_REC;
                      EXIT WHEN CURR_LIST_SIGNERS%NOTFOUND;

                         lc_itemkey := lp_itemkey || '-' || SIGNER_LIST_REC.SIGNATURE_ID;

                         WF_ENGINE.ITEMSTATUS ( itemtype => p_itemtype,
                                  itemkey => lc_itemkey,
                                  status => lp_status,
                                  result => lp_result);

                         if(lc_itemkey <> p_itemkey and lp_status = 'ACTIVE' ) then

                            select notification_id into lp_notification_id
                            from wf_item_activity_statuses where item_type=p_itemtype
                            and item_key = lc_itemkey and notification_id is not null
                            and activity_status ='NOTIFIED';


                            if lp_notification_id is not null and lp_notification_id > 0 then
                                wf_notification.cancel(lp_notification_id);

                            end if;


                            WF_ENGINE.ABORTPROCESS(itemtype => p_itemtype,
                                  itemkey => lc_itemkey
                                 );

                         end if;

                   END LOOP;

                   CLOSE CURR_LIST_SIGNERS;

                 END IF; -- REJECTED

               --Bug 2674799 : end

	  END IF;
	  CLOSE GET_USER_RESPONSE_RESULT;
     -- Bug 3170251 : End

       --Bug 2674799 : Start
       /* SELECT count(*)  INTO l_count
        FROM EDR_ESIGNATURES
        WHERE EVENT_ID = l_item_key
        AND SIGNATURE_STATUS = 'REJECTED';

        IF l_count > 0 then
          raise_application_error(-20002,FND_MESSAGE.GET_STRING('EDR','EDR_EREC_ALREADY_REJECTED'));
        END IF;
       */
       --Bug 2674799 : End

      /* Following statements are to store data in PSIG evidance store */
      l_doc_id := GET_WF_ITEM_ATTRIBUTE_NUMBER(l_item_type, l_item_key,'EDR_PSIG_DOC_ID');
      IF l_doc_id is null THEN
        l_psig_event := wf_engine.getItemAttrEvent(p_itemtype, p_itemkey,'#PSIG_EVENT');
        l_event_xml  := l_psig_event.getEventData();
        l_event_name := l_psig_event.getEventName();
        l_event_key  := l_psig_event.getEventKey();
        l_doc_id := GET_WF_ITEM_ATTRIBUTE_TEXT(l_item_type, l_item_key,'PSIG_DOCUMENT_ID');

      /* Fixed to take care of PDF format */

   	    l_erec_template_type := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey, 'EREC_TEMPLATE_TYPE');

            if (l_erec_template_type = 'RTF') then
       -- Bug 3474765 : Start
      /* Changing the file content type to be MIME Formatted */
                      l_doc_format:='application/pdf';
       -- Bug 3474765 : End
            end if;
      /* END of PDF fix */

        EDR_PSIG.updateDocument(P_PSIG_XML          => l_event_xml,
                              P_PSIG_DOCUMENT       => l_event_xml,
                              P_PSIG_DOCUMENTFORMAT => l_doc_format,
                              P_PSIG_REQUESTER      => GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_SIGN_REQUESTER'),
                              P_PSIG_SOURCE         => GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_SOURCE_APPLICATION_TYPE'),
                              P_EVENT_NAME          => l_event_name,
                              P_EVENT_KEY           => l_event_key,
                              P_WF_NID              => wf_engine.context_nid,
                              P_DOCUMENT_ID         => l_doc_id,
                              P_ERROR               => l_error_num,
                              P_ERROR_MSG           => L_ERROR_MESG);
         IF  l_ERROR_NUM IS NOT NULL THEN
          RAISE EDR_PSIG_DOC_ERR;
         ELSE
          SET_WF_ITEM_ATTRIBUTE_NUMBER(l_item_type, l_item_key,'EDR_PSIG_DOC_ID',l_doc_id);
           l_paramlist:=l_psig_event.Parameter_List;
           IF (l_paramlist is not null) THEN
             FOR i IN l_paramlist.first .. l_paramlist.last LOOP

               l_doc_params(i).param_name:=l_paramlist(i).GetName;
               l_doc_params(i).param_value:=l_paramlist(i).GetValue;
               l_doc_params(i).param_displayname:=l_paramlist(i).GetName;
             END LOOP;

             EDR_PSIG.POSTDOCUMENTPARAMETER( P_DOCUMENT_ID =>l_doc_id,
                                             P_PARAMETERS  =>l_doc_params,
                                             P_ERROR       =>l_error_num,
                                             P_ERROR_MSG   =>l_error_mesg);
             IF  l_ERROR_NUM IS NOT NULL THEN
               RAISE EDR_PSIG_DOC_ERR;
             END IF;
           END IF; -- Param List Error
        END IF;  -- Doc Error
      END IF; --  First Time

      OPEN GET_USER_RESPONSE_RESULT;
      FETCH GET_USER_RESPONSE_RESULT INTO GET_USER_RESPONSE_RESULT_REC;
      IF GET_USER_RESPONSE_RESULT%FOUND THEN
        IF GET_USER_RESPONSE_RESULT_REC.LOOKUP_CODE <> '#SIG_CANCEL' THEN
          --Bug 3214398: Start
          --We need to get the user_name and pass the overriding details for user_name
          --to edr_psig.postSignature to avoid partial routing rules in GQ
          --In postSignature the overriding comments are appended so if there is no change
          --after the signer process has started there will be no impact
          --and if the routing has changed GQ will be populated with correct results
          /*
          OPEN original_recipient;
            FETCH original_recipient into l_original_recipient;
          CLOSE original_recipient;
          */
          OPEN signer_detail;
           FETCH signer_detail into  l_original_recipient, l_user_name;
          CLOSE signer_detail;

         -- Bug 3902969 : Start
         --  Check if the recipient l_user_name is same as WF_ENGINE.CONTEXT_TEXT
         --  if they are differnt then only call find wf ntf recipients API.

         IF( l_user_name <> WF_ENGINE.CONTEXT_USER) THEN

                  EDR_STANDARD.FIND_WF_NTF_RECIPIENT(P_ORIGINAL_RECIPIENT => l_user_name,
					      P_MESSAGE_TYPE => 'EDRPSIGF',
				              P_MESSAGE_NAME => 'PSIG_EREC_MESSAGE_BLAF',
                                              P_RECIPIENT => l_overriding_approver,
                                              P_NTF_ROUTING_COMMENTS => l_overriding_comments,
                                              P_ERR_CODE => l_error_num,
                                              P_ERR_MSG => l_error_mesg);

         END IF;
         -- Bug 3902969 : End

          IF  (l_ERROR_NUM > 0 ) THEN
            RAISE EDR_PSIG_DOC_ERR;
          END IF;

          -- Bug 4190367 : Modifying to make use of wf_notification.getattrtext to populate Evidence store id.
          /*
          EDR_PSIG.postSignature(P_DOCUMENT_ID       => l_doc_id,
                               P_EVIDENCE_STORE_ID => wf_notification.getattrtext(wf_engine.context_nid,'#WF_SIG_ID'),
                               P_USER_NAME         => WF_ENGINE.context_text,
                               P_USER_RESPONSE     => GET_USER_RESPONSE_RESULT_REC.MEANING,
                               P_SIGNATURE_ID      => l_SIGNATURE_id,
                               P_ORIGINAL_RECIPIENT => l_ORIGINAL_RECIPIENT,
                               P_ERROR             => l_error_num,
                               P_ERROR_MSG         => L_ERROR_MESG);
          */


          EDR_PSIG.postSignature(P_DOCUMENT_ID       => l_doc_id,
                               P_EVIDENCE_STORE_ID => wf_notification.getattrtext(wf_engine.context_nid,'#WF_SIG_ID'),
                               P_USER_NAME         => WF_ENGINE.context_text,
                               P_USER_RESPONSE     => GET_USER_RESPONSE_RESULT_REC.MEANING,
                               P_SIGNATURE_ID      => l_SIGNATURE_id,
                               P_ORIGINAL_RECIPIENT => l_ORIGINAL_RECIPIENT,
			       P_OVERRIDING_COMMENTS => l_overriding_comments,
                               P_ERROR             => l_error_num,
                               P_ERROR_MSG         => L_ERROR_MESG);

          -- Bug 4190367 : End
	  --Bug 3214398: end

          IF  l_ERROR_NUM IS NOT NULL THEN
              RAISE EDR_PSIG_DOC_ERR;
          END IF;
          i := 0;
          OPEN GET_RESPONSE_ATTR;
          LOOP
            FETCH GET_RESPONSE_ATTR INTO GET_RESPONSE_ATTR_REC;
            EXIT WHEN GET_RESPONSE_ATTR%NOTFOUND;
              i := i + 1;
                   /* To support WF_NOTE attribute SKARIMIS*/
                IF GET_RESPONSE_ATTR_REC.Name = 'WF_NOTE' THEN
                   SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,
                                             p_itemkey,
                                             'SIGNERS_COMMENT',
                                             GET_RESPONSE_ATTR_REC.Meaning);
                   GET_RESPONSE_ATTR_REC.Name:='SIGNERS_COMMENT';
                END IF;
              l_sign_params(i).param_name:=GET_RESPONSE_ATTR_REC.Name;
              l_sign_params(i).param_value:=GET_RESPONSE_ATTR_REC.Meaning;
              l_sign_params(i).param_displayname:=GET_RESPONSE_ATTR_REC.display_Name;
          END LOOP;
          CLOSE GET_RESPONSE_ATTR;

          IF i > 0 THEN
            EDR_PSIG.postSignatureParameter(P_SIGNATURE_ID      => l_SIGNATURE_id,
                                          P_PARAMETERS        => l_sign_params,
                                          P_ERROR             => l_error_num,
                                          P_ERROR_MSG         => L_ERROR_MESG);
            IF  l_ERROR_NUM IS NOT NULL THEN
              RAISE EDR_PSIG_DOC_ERR;
            END IF;
          END IF;
        END IF;
      END IF;
      CLOSE GET_USER_RESPONSE_RESULT;

      /* Capture Current Notification Responder  BUG Fix 2903607 SKARIMIS*/
       wf_notification.getinfo(
		 NID               =>wf_engine.context_nid,
		 ROLE              =>L_NTF_RESPOND_ROLE,
		 MESSAGE_TYPE      =>L_NTF_MESSAGE_TYPE,
		 MESSAGE_NAME      =>L_NTF_MESSAGE_NAME,
		 PRIORITY          =>L_NTF_PRIORITY,
		 DUE_DATE          =>L_NTF_DUE_DATE,
		 STATUS            =>L_NTF_STATUS);

        SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,
                                   p_itemkey,
                                   'NTF_RESPONDER',
                                   L_NTF_RESPOND_ROLE);
    END IF;   -- Function Mode

    IF (p_funcmode = 'RUN') THEN


       SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,p_itemkey,
        				  '#WF_SIGNER_ROLE_DISPLAY_NAME',
                                          WF_DIRECTORY.GETROLEDISPLAYNAME(WF_ENGINE.context_text));
      /* SKARIMIS Get the user List */
      OPEN GET_USER;
       LOOP
         fetch GET_USER into l_user;
         EXIT when GET_USER%NOTFOUND;
        if l_requester <> l_user then
         l_userlist(ui+1):=l_user;
         ui := ui  +1;
        end if;
      END LOOP;
      CLOSE GET_USER;

      /* Create ADHOC group */

         If (wf_directory.getRoleDisplayName('EDRPSIG_ROLE') is NULL) then
            /* Start Creating the Role */

             wf_directory.CreateAdHocRole2(role_name=>l_group,
                                          role_display_name=>l_display_name,
					  role_users=>l_userlist,
				          expiration_date=>NULL);

         ELSE
            wf_directory.RemoveUsersFromAdHocRole(role_name=>'EDRPSIG_ROLE',
						  role_users=>NULL);

            wf_directory.AddUsersToAdHocRole2(role_name=>'EDRPSIG_ROLE',
						  role_users=>l_userlist);
           END IF;

            SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,p_itemkey,
           					  'ESIG_GROUP' ,
                                      'EDRPSIG_ROLE');

    END IF;   -- RUN function ends

    IF (p_funcmode ='TIMEOUT') then
          wf_notification.getinfo(
		 NID               =>wf_engine.context_nid,
		 ROLE              =>L_NTF_RESPOND_ROLE,
		 MESSAGE_TYPE      =>L_NTF_MESSAGE_TYPE,
		 MESSAGE_NAME      =>L_NTF_MESSAGE_NAME,
		 PRIORITY          =>L_NTF_PRIORITY,
		 DUE_DATE          =>L_NTF_DUE_DATE,
		 STATUS            =>L_NTF_STATUS);
                  SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,
                                             p_itemkey,
                                             'NTF_RESPONDER',
                                             L_NTF_RESPOND_ROLE);
   END IF;

    EXCEPTION WHEN EDR_PSIG_NOT_NULL THEN
        WF_CORE.CONTEXT ('EDR_PSIG_PAGE_FLOW','UPDATE_NOTIF_RESPONSE',p_itemtype,p_itemkey,
                         'Signer Comment and Signing Reason code can not be null.');
        raise;
    WHEN EDR_PSIG_DOC_ERR THEN
        WF_CORE.CONTEXT ('EDR_PSIG_PAGE_FLOW','UPDATE_NOTIF_RESPONSE',p_itemtype,p_itemkey,
                         l_error_num,L_ERROR_MESG);
        raise;
    WHEN EDR_PSIG_NOT_READ THEN
  	    WF_CORE.CONTEXT ('EDR_PSIG_PAGE_FLOW','UPDATE_NOTIF_RESPONSE',p_itemtype,p_itemkey,
                         FND_MESSAGE.GET_STRING('EDR','EDR_EREC_NOT_REVIEWED_ERR'));
	    raise;
    WHEN OTHERS THEN
        WF_CORE.CONTEXT ('EDR_PSIG_PAGE_FLOW','UPDATE_NOTIF_RESPONSE',p_itemtype,p_itemkey,
                         l_error_num,L_ERROR_MESG);
        raise;
  END UPDATE_NOTIF_RESPONSE;

  /******************************************************************************
   ***  This procedure is associated with EDRESGPF workflow.  This code will   **
   ***  execute when user clicks on Approve Button in response to notification **
   ******************************************************************************/

   PROCEDURE NOTIF_APPROVED(
      p_itemtype   IN VARCHAR2,
      p_itemkey    IN VARCHAR2,
      p_actid      IN NUMBER,
      p_funcmode   IN VARCHAR2,
      p_resultout  OUT NOCOPY VARCHAR2
   )
   IS
     l_ESIGN_ID VARCHAR2(30) ;
     l_EVENT_ID NUMBER ;
     l_SIGNER_TYPE VARCHAR2(30) ;
     l_signer_reason VARCHAR2(32) ;
     l_signer_comment VARCHAR2(4000) ;
     l_count  number;

     --Bug 4577122: Start
     l_ignore_wfattr_notfound boolean := true;
     l_voting_regime varchar2(1);
     --Bug 4577122: End

  BEGIN

    --Bug 4074173 : start
     l_ESIGN_ID  := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_ESIGN_ROW_ID');
     l_EVENT_ID  := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_PAGEFLOW_ITEMKEY');
     l_SIGNER_TYPE := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'WF_SIGNER_TYPE');
     l_signer_reason  := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'REASON_CODE');
     l_signer_comment := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'SIGNERS_COMMENT');
    --Bug 4074173 : end

    --Bug 4577122: Start
    l_voting_regime := wf_engine.GetitemAttrText
                       (p_itemtype, p_itemkey,'AME_VOTING_REGIME',
    l_ignore_wfattr_notfound);
    --Bug 4577122: End

    IF p_funcmode = 'RUN' THEN
      UPDATE EDR_ESIGNATURES
      SET SIGNATURE_STATUS    = 'APPROVED' ,
        SIGNATURE_TYPE        = l_SIGNER_TYPE,
        SIGNATURE_REASON_CODE = l_signer_reason,
        SIGNATURE_TIMESTAMP   = SYSDATE,
        SIGNER_COMMENTS       = l_signer_comment
      WHERE  SIGNATURE_ID = l_ESIGN_ID;

      /* Verify all are Approved */

      SELECT count(*)  INTO l_count
      from EDR_ESIGNATURES
      WHERE EVENT_ID = l_event_id
        AND SIGNATURE_STATUS <> 'APPROVED' ;

      --Bug 4577122: Start
      --IF l_count = 0 THEN
      IF (l_count = 0 or l_voting_regime = ame_util.firstApproverVoting) THEN
      --Bug 4577122: End

        /* if all signers are approved set the status of edr_erecords to presuccess.
         this will be used on list of signer screen to handle done button. */

        UPDATE EDR_ERECORDS
        SET ERECORD_SIGNATURE_STATUS = 'PRESUCCESS'
        WHERE  EVENT_ID              =  l_event_id;


       --Bug 4577122: Start
       --clear out the status etc fields of rest of the edr_esignatures
        if (l_voting_regime = ame_util.firstApproverVoting) then
          update edr_esignatures
          set signature_status = null
          where event_id = l_event_id
          and signature_status = 'PENDING';
        end if;
       --Bug 4577122: End

      END IF;
      -- p_resultout := 'COMPLETE:';
    END IF;

  END NOTIF_APPROVED;

  /*******************************************************************************
   ***   This procedure is associated with EDRESGPF workflow.  This code will   **
   ***   execute when user clicks on Cancel Button in response to notification  **
   ***   No processing is done here.                                            **
   *******************************************************************************/

   PROCEDURE NOTIF_CANCELED(
      p_itemtype   IN VARCHAR2,
      p_itemkey    IN VARCHAR2,
      p_actid      IN NUMBER,
      p_funcmode   IN VARCHAR2,
      p_resultout  OUT NOCOPY VARCHAR2
   )
   IS
  BEGIN
    IF (p_funcmode = 'RUN') THEN
       null;
     -- p_resultout := 'COMPLETE:';
    END IF;
  END NOTIF_CANCELED;

  /*****************************************************************************
   ***   This procedure is associated with EDRESGPF workflow.  This code will **
   ***   executed when use click on Reject Button in response to notification **
   *****************************************************************************/

   PROCEDURE NOTIF_REJECTED(
      p_itemtype   IN VARCHAR2,
      p_itemkey    IN VARCHAR2,
      p_actid      IN NUMBER,
      p_funcmode   IN VARCHAR2,
      p_resultout  OUT NOCOPY VARCHAR2
   )
   IS
     l_ESIGN_ID VARCHAR2(30);
     l_EVENT_ID NUMBER;
     l_SIGNER_TYPE VARCHAR2(30);
     l_signer_reason VARCHAR2(32);
     l_signer_comment VARCHAR2(4000);
     l_count  number;
  BEGIN

    --Bug 4074173 : start
     l_ESIGN_ID          := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_ESIGN_ROW_ID');
     l_EVENT_ID          := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_PAGEFLOW_ITEMKEY');
     l_SIGNER_TYPE      := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'WF_SIGNER_TYPE');
     l_signer_reason    := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'REASON_CODE');
     l_signer_comment   := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'SIGNERS_COMMENT');
    --Bug 4074173 : end



    IF p_funcmode = 'RUN' THEN
      /* Skarimis */

       wf_directory.RemoveUsersFromAdHocRole(role_name=>'EDRPSIG_ROLE', role_users=>NULL);

      /* Skarimis */

      /* Change following code to derieve Timezone info */
      UPDATE EDR_ESIGNATURES
      SET SIGNATURE_STATUS    = 'REJECTED' ,
        SIGNATURE_TYPE        = l_SIGNER_TYPE,
        SIGNATURE_REASON_CODE = l_signer_reason,
        SIGNATURE_TIMESTAMP   = SYSDATE,
        SIGNER_COMMENTS       = l_signer_comment
      WHERE  SIGNATURE_ID = l_ESIGN_ID;

      /* set the status of edr_erecords to pre rejected.  this will be used on list of signer screen.
         to handle done button.                */

      UPDATE EDR_ERECORDS
      SET ERECORD_SIGNATURE_STATUS = 'PREREJECTED'
      WHERE  EVENT_ID              =  l_event_id;

     -- p_resultout := 'COMPLETE:';
    END IF;
  END NOTIF_REJECTED;

/************************************************************************************
****   Following Procedure is used by list of signer screen. it accepts item_type  **
****   and Item_key returns current open notification id this is used to build     **
****   Notification URL. This is required as OANavigation.nextPage does not return **
****   notification URL.                                                          ***
*************************************************************************************/


FUNCTION getNotificationID(p_itemtype   IN VARCHAR2,
      p_itemkey    IN VARCHAR2) RETURN VARCHAR2 IS
-- Bug 5223211 : start
/*
  CURSOR CUR_NOTIFICATION IS
  SELECT NOTIFICATION_ID
  FROM WF_ITEM_ACTIVITIES_HISTORY_V
  WHERE  ITEM_KEY = p_itemkey
      AND ITEM_TYPE = p_itemtype
      AND ACTIVITY_TYPE = 'NOTICE'
      AND NOTIFICATION_STATUS = 'OPEN'
    ORDER BY BEGIN_DATE DESC;
*/
  CURSOR CUR_NOTIFICATION IS
  SELECT  NOTIFICATION_ID from  WF_ITEM_ACTIVITY_STATUSES_V
  WHERE  ITEM_KEY = p_itemkey
      AND ITEM_TYPE = p_itemtype
      AND   notification_id is not null
      ORDER BY activity_begin_date, execution_time;
-- Bug 5223211 : End
  l_notification_id NUMBER;
BEGIN
   OPEN CUR_NOTIFICATION;
   FETCH CUR_NOTIFICATION INTO l_notification_id;
   CLOSE CUR_NOTIFICATION;
   RETURN l_notification_id;
END;

/************************************************************************************************
******  Following Procedure is to spwan child process to get off-line electronic signatures   ***
******  It gets the current level to process and sends the notifications to all signers       ***
******  of current level.  It also copies required attributes parent process to child process ***
*************************************************************************************************/

  PROCEDURE SPWAN_OFFLINE_PROCESS(
      p_itemtype   IN VARCHAR2,
      p_itemkey    IN VARCHAR2,
      p_actid      IN NUMBER,
      p_funcmode   IN VARCHAR2,
      p_resultout  OUT NOCOPY VARCHAR2
   )
   IS
     L_CURR_SIGN_LEVEL NUMBER ;
     CURSOR CURR_LIST_SIGNERS IS
       /*Changed the Cursor to get ORIGNIAL RECIPIENT instead of USER_NAME SKARIMIS */
       SELECT event_name, SIGNATURE_ID,NVL(ORIGINAL_RECIPIENT,USER_NAME) USER_NAME
       FROM EDR_ESIGNATURES
       WHERE EVENT_ID = p_itemkey
         --Bug 4272262: Start
         --Convert signature sequence to a number value.
	 AND  to_number(SIGNATURE_SEQUENCE,'999999999999.999999') = L_CURR_SIGN_LEVEL
         AND SIGNATURE_STATUS = 'PENDING';
	 --Bug 4272262: End

      SIGNER_LIST_REC           CURR_LIST_SIGNERS%ROWTYPE;
      l_itemtype                WF_ITEMS.ITEM_TYPE%TYPE ;
      l_WorkflowProcess         VARCHAR2(30) ;
      l_performer_name          FND_USER.USER_NAME%TYPE ;
      l_performer_display_name  FND_USER.DESCRIPTION%TYPE ;
      l_item_key                VARCHAR2(100);

     --Bug 4577122: Start
     l_ignore_wfattr_notfound boolean := true;
     l_voting_regime varchar2(1);
     --Bug 4577122: End

  BEGIN

    --Bug 4074173 : Start
      l_itemtype        :=  'EDRPSIGF';
      l_WorkflowProcess := 'PSIG_OFFLINE_NOTIF_PROCESS';
    --Bug 4074173 : End

    if p_funcmode='RUN' then

           --Bug 4272262: Start
           SELECT MIN( to_number(SIGNATURE_SEQUENCE,'999999999999.999999')) INTO L_CURR_SIGN_LEVEL
           from EDR_ESIGNATURES
           WHERE EVENT_ID = p_itemkey
             AND SIGNATURE_STATUS = 'PENDING' ;
	   --Bug 4272262: End

        OPEN CURR_LIST_SIGNERS;
        LOOP
             FETCH CURR_LIST_SIGNERS INTO SIGNER_LIST_REC;
             EXIT WHEN CURR_LIST_SIGNERS%NOTFOUND;

             l_item_key := p_itemkey ||'-'||SIGNER_LIST_REC.SIGNATURE_ID;

             /* create the process */
      	     WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype,
                                     itemkey => l_item_key,
                                     process => l_WorkflowProcess) ;
            /* set the item attributes */

        --Bug 4577122: Start
         l_voting_regime := wf_engine.GetitemAttrText
                           (p_itemtype, p_itemkey,'AME_VOTING_REGIME',
                            l_ignore_wfattr_notfound);

         WF_ENGINE.ADDITEMATTR
         (itemtype => l_itemtype,
          itemkey => l_item_key,
          aname => 'AME_VOTING_REGIME',
          text_value => l_voting_regime);

       --Bug 4577122: End

  	 SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,
           					  '#WF_PAGEFLOW_ITEMKEY',
                                      GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_PAGEFLOW_ITEMKEY'));
      	 SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,
           					  '#WF_PAGEFLOW_ITEMTYPE',
                                      GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_PAGEFLOW_ITEMTYPE'));
      	 SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,
           					  'DEFERRED',
                                      GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'DEFERRED'));

             SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,
           					  '#WF_ESIGN_ROW_ID' ,
                                      SIGNER_LIST_REC.SIGNATURE_ID);
             SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,
           					  '#WF_CURRENT_MODE' ,
                                      GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_CURRENT_MODE'));
             SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,
           					  'PSIG_EVENT_NAME' ,
                                      GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'PSIG_EVENT_NAME'));
             SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,
           					  'PSIG_TIMEZONE' ,
                                      GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'PSIG_TIMEZONE'));
             SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,
           					  'PSIG_TIMESTAMP' ,
                                      GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'PSIG_TIMESTAMP'));

             SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,
           					  'PSIG_USER_KEY_LABEL' ,
                                      GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'PSIG_USER_KEY_LABEL'));
             SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,
           					  'PSIG_USER_KEY_VALUE' ,
                                      GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'PSIG_USER_KEY_VALUE'));

             SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,
           					  'SIGNATURE_HISTORY' ,
                                      GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'SIGNATURE_HISTORY'));

              /* Style Sheet Version Fix */
             SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,
           					  'TEXT_XSLNAME',
                                      GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'TEXT_XSLNAME'));

             SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,
           					  'TEXT_XSLVERSION' ,
                                      GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'TEXT_XSLVERSION'));

             SET_WF_ITEM_ATTRIBUTE_NUMBER(l_itemtype,
                                          l_item_key,
                                          '#WF_NOTIFICATION_TIMEOUT',
                                            GET_WF_ITEM_ATTRIBUTE_NUMBER(p_itemtype, p_itemkey,'#WF_NOTIFICATION_TIMEOUT'));
             /* SKARIMIS Added Resend count */

             SET_WF_ITEM_ATTRIBUTE_NUMBER(l_itemtype,
                                  l_item_key,
                                  'TIMEOUT_RESEND_COUNT',
                                  GET_WF_ITEM_ATTRIBUTE_NUMBER(p_itemtype, p_itemkey,'TIMEOUT_RESEND_COUNT'));
             SET_WF_ITEM_ATTRIBUTE_NUMBER(l_itemtype,
                                  l_item_key,
                                  '#WF_NOTIFICATION_TIMEOUT_HR',
                                  GET_WF_ITEM_ATTRIBUTE_NUMBER(p_itemtype, p_itemkey,'#WF_NOTIFICATION_TIMEOUT')/60);

             SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype, l_item_key,'PSIG_DOCUMENT_ID',
                                         GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'PSIG_DOCUMENT_ID'));

             SET_WF_ITEM_ATTRIBUTE_NUMBER(l_itemtype, l_item_key,'EDR_PSIG_DOC_ID',
                                         GET_WF_ITEM_ATTRIBUTE_NUMBER(p_itemtype, p_itemkey,'EDR_PSIG_DOC_ID'));

             SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,
           					  '#WF_SIGNER_ROLE' ,
                                      SIGNER_LIST_REC.USER_NAME);
             	/* set the item attributes */
       	 WF_ENGINE.SETITEMATTREVENT(itemtype => l_itemtype,itemkey => l_item_key,
           					  name => '#PSIG_EVENT',
                                      event => wf_engine.GETITEMATTREVENT(p_itemtype, p_itemkey,'#PSIG_EVENT'));
             SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,'#WF_ERECORD_TEXT',
                                 GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_ERECORD_TEXT'));

	 SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,
           					  '#WF_SIGN_REQUESTER',
                                      GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_SIGN_REQUESTER'));

	 SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,l_item_key,
           					  '#ATTACHMENTS',
                                      GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#ATTACHMENTS'));
         -- Bug: 3467353 - Start

   -- Bug 3903471 : Start
   BEGIN
	   WF_ENGINE.ADDITEMATTR(itemtype => l_itemtype,itemkey => l_item_key,
        		  aname => 'EREC_TEMPLATE_TYPE',
                           text_value => GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'EREC_TEMPLATE_TYPE'));
     EXCEPTION WHEN OTHERS THEN
       NULL;
   END;
   --Bug 3903471 : End

           --Bug 3998932 : Start
           --Isign Checklist ER
           SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,
                                     l_item_key,
                                     'RELATED_APPLICATION',
                                     GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,p_itemkey,'RELATED_APPLICATION'));
           --Bug 3998932 : End

           --Bug 4122622: Start
           --Fetch the related e-records and child e-record ids attribute values
           --from the parent workflow process and set them on the child
           --workflow process.
           SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,
                                     l_item_key,
                                     'RELATED_ERECORDS',
                                     GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,p_itemkey,'RELATED_ERECORDS'));

           SET_WF_ITEM_ATTRIBUTE_TEXT(l_itemtype,
                                     l_item_key,
                                     'CHILD_ERECORD_IDS',
                                     GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,p_itemkey,'CHILD_ERECORD_IDS'));

          --Bug 4122622: End

                 /* Setting Patent Child association */
         WF_ENGINE.SETITEMPARENT(itemtype =>l_itemtype,itemkey =>l_item_key,
                                    parent_itemtype => p_itemtype,
                                    parent_itemkey=> p_itemkey,
                                    parent_context=> NULL);
     	           /* start the Workflow process */


               /* Set process Owner SKARIMIS for BLAF standard */
                 wf_engine.setitemowner
                             (ITEMTYPE=>l_itemtype,
                              ITEMKEY=>l_item_key,
                             OWNER=>GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,p_itemkey,'#WF_SIGN_REQUESTER'));
           WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,itemkey => l_item_key);

           END LOOP;
           CLOSE CURR_LIST_SIGNERS;
     end if;
  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('EDR_PSIG_PAGE_FLOW','SPWAN_OFFLINE_PROCESS',l_itemtype,l_item_key,'Initial' );
      CLOSE CURR_LIST_SIGNERS;
      raise;
  END SPWAN_OFFLINE_PROCESS;

 /****************************************************************
 ***  Following procedure is associated to workflow activity.   **
 ***  This procedure set the mode os signature process.         **
 ***  If 'WF_SOURCE_APPLICATION_TYPE' is "DB" and Deferred      **
 ***  mode is allowed then we should not pop up List of signers **
 ***  page.  In this case This procedure simulates done button  **
 ***  on list of signers page.                                  **
 *****************************************************************/

  PROCEDURE IS_IT_TOTAL_OFFLINE(
      p_itemtype   IN VARCHAR2,
      p_itemkey    IN VARCHAR2,
      p_actid      IN NUMBER,
      p_funcmode   IN VARCHAR2,
      p_resultout  OUT NOCOPY VARCHAR2
	  )
  IS

    L_DOCUMENT_ID NUMBER;
    l_wf_timeout  NUMBER ;
    l_wf_timeout_interval NUMBER ;

    L_SOURCE_APPL_TYPE VARCHAR2(80) ;
    L_DEFER_MODE_ALLOWED VARCHAR2(30);
    l_plsql_clob_api VARCHAR2(2000);
    l_plsql_api      VARCHAR2(2000);
    l_history_api    VARCHAR2(2000);
    L_event_name  VARCHAR2(240);

    l_message     VARCHAR2(2000);
    l_return_status  VARCHAR2(1);
    l_msg_count  NUMBER;
    l_msg_data   VARCHAR2(240);
    l_document_rec  edr_psig_documents%ROWTYPE;
    l_doc_param_tbl EDR_EvidenceStore_PUB.Params_tbl_type;
    l_sig_tbl  EDR_EvidenceStore_PUB.Signature_tbl_type;
    l_erec_template_type varchar2(256);
    --Bug 4160412: Start
    l_signature_mode VARCHAR2(80);
    --Bug 4160412: End

  BEGIN

   --Bug 4074173 : start

   --Bug: 3499311 Start - Specify Number Format in TO_NUMBER
   --Bug: 3903471 : Start
   --Old versions do not use #ERECORD_ID parameter.
   --Hence for backward compatibility we should verify with EDR_PSIG_DOC_ID attribute.
   --If the attribute does not exist, then #ERECORD_ID should be used.
    L_DOCUMENT_ID := nvl(GET_WF_ITEM_ATTRIBUTE_NUMBER(p_itemtype, p_itemkey,'EDR_PSIG_DOC_ID'),
                         TO_NUMBER(GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#ERECORD_ID'),'999999999999.999999'));
    --Bug 3903471 : End

    l_wf_timeout      := TO_NUMBER(FND_PROFILE.VALUE('EDR_WF_TIMEOUT'),'999999999999.999999');
    l_wf_timeout_interval := TO_NUMBER(FND_PROFILE.VALUE('EDR_WF_TIMEOUT_INTERVAL'),'999999999999.999999');
   --Bug : 3499311 End.

    L_SOURCE_APPL_TYPE    := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_SOURCE_APPLICATION_TYPE');
    L_DEFER_MODE_ALLOWED  := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'DEFERRED');
    l_plsql_clob_api      := 'PLSQLCLOB:wf_render.XML_STYLE_SHEET/#PSIG_EVENT:&'||'#NID';
    l_plsql_api           := 'PLSQL:edr_xdoc_util_pkg.get_ntf_message_body/' || L_DOCUMENT_ID;
    l_history_api         := 'PLSQL:EDR_UTILITIES.EDR_NTF_HISTORY/'||p_itemkey;

   --Bug 4074173 : end

    --Bug 4160412: Start
    --Obtain the value of the signature mode.
    l_signature_mode := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,EDR_CONSTANTS_GRP.G_SIGNATURE_MODE);
    --Bug 4160412: End

    IF p_funcmode='RUN' THEN
     /* Set process Owner SKARIMIS for BLAF standard */
	 	     wf_engine.setitemowner
                (ITEMTYPE=>p_itemtype,
                 ITEMKEY=>p_itemkey,
                 OWNER=>GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,p_itemkey,'#WF_SIGN_REQUESTER'));

		   l_plsql_clob_api := l_plsql_clob_api ||'/'||
                   GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'TEXT_XSLNAME')||'/'||
                   GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'TEXT_XSLVERSION')||'/'||
                   GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'APPLICATION_CODE') ||'/'||
                   GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'HTML_XSLNAME')||'/'||
                   GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'HTML_XSLVERSION')||'/'||
                   GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'APPLICATION_CODE');


			-- Bug 3170251 : Start- Check if EREC_TEMPLATE TYPE IS XSL or RTF and based on that decide the ERECORD TEXT Content
			--               and Notification Subject Token
   			l_erec_template_type := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey, 'EREC_TEMPLATE_TYPE');

			if (l_erec_template_type = 'RTF') then
			     FND_MESSAGE.SET_NAME('EDR','EDR_WF_EREC_RTF_NTF_SUB');
	             FND_MESSAGE.SET_TOKEN('ERECORD_ID',l_document_id);

			     SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,p_itemkey,'WF_MSG_SUB_EREC_TOKEN',FND_MESSAGE.GET());
	             SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,p_itemkey,'#WF_ERECORD_TEXT', l_plsql_api);
			else
			     FND_MESSAGE.SET_NAME('EDR','EDR_WF_EREC_XSL_NTF_SUB');
	             FND_MESSAGE.SET_TOKEN('ERECORD_ID',l_document_id);

				 SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,p_itemkey,'WF_MSG_SUB_EREC_TOKEN',FND_MESSAGE.GET());
	             SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,p_itemkey,'#WF_ERECORD_TEXT', l_plsql_clob_api);
			end if;
  	        -- Bug 3170251 : End

            L_event_name := Get_event_disp_name(p_itemkey);
            SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,
                                       p_itemkey,
           			       'PSIG_EVENT_NAME',
                                       L_EVENT_NAME);

    /* Get the eRecrod */
    EDR_EvidenceStore_PUB.Get_DocumentDetails(p_api_version =>1.0,
                                             x_return_status => l_return_status,
                                             x_msg_count => l_msg_count,
                                             x_msg_data => l_msg_data,
                                             P_DOCUMENT_ID => L_DOCUMENT_ID,
                                             x_document_rec => l_document_rec,
                                             x_doc_parameters_tbl => l_doc_param_tbl,
                                             x_signatures_tbl => l_sig_tbl);

--Bug 3903471 : Start
      SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,
                              p_itemkey,
           		      'PSIG_TIMEZONE' ,
                              l_document_rec.PSIG_TIMEZONE);
--Bug 3903471 : End


-- BUG 3271711 : Start Calling FND_DATE.DATE_TO_DISPLAYDT with server timezone
--               Commenting the orignal code
/*
    wf_engine.setitemattrtext(itemtype => p_itemtype,
                              itemkey => p_itemkey,
           		      aname =>'PSIG_TIMESTAMP' ,
                              avalue => FND_DATE.DATE_TO_DISPLAYDT(l_document_rec.PSIG_TIMESTAMP));
*/
--Bug 3903471 : Start
      SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,
                              p_itemkey,
           		      'PSIG_TIMESTAMP' ,
                              FND_DATE.DATE_TO_DISPLAYDT(l_document_rec.PSIG_TIMESTAMP, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE));
--Bug 3903471 : End

-- BUG 3271711 : End

     /* UPDATE EDR_ERECORDS
      SET EVENT_TIMEZONE = fnd_timezones.GET_SERVER_TIMEZONE_CODE
      Replaced the  profile option to EDR_SERVER_ZONE
      SET EVENT_TIMEZONE = fnd_profile.VALUE('EDR_SERVER_TIMEZONE')
      WHERE event_id = p_itemkey;*/

      -- Converting days into minutes

      l_wf_timeout := round(l_wf_timeout * 60);

      SET_WF_ITEM_ATTRIBUTE_NUMBER(p_itemtype,
                                  p_itemkey,
                                  '#WF_NOTIFICATION_TIMEOUT',
                                  l_wf_timeout);

	  SET_WF_ITEM_ATTRIBUTE_NUMBER(p_itemtype,
                                  p_itemkey,
                                  'TIMEOUT_RESEND_COUNT',
                                  l_wf_timeout_interval);

	  l_message := FND_MESSAGE.GET_STRING('EDR','EDR_PSIG_PROCESS_ABORTED');

      SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,
                                  p_itemkey,
                                  '#WF_PAGEFLOW_MESSAGE',
                                  l_message);

      SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,
                                 p_itemkey,
                                 'SIGNATURE_HISTORY',
                                 l_history_api);

      IF L_SOURCE_APPL_TYPE = 'DB' and L_DEFER_MODE_ALLOWED  ='Y' THEN
        SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_CURRENT_MODE','OFFLINE');
        p_resultout := 'COMPLETE:TOTAL_OFFLINE';
       --Bug 2637353: Start
       --Set the result out value for MSCA source type.
       ELSIF L_SOURCE_APPL_TYPE='MSCA' then
        p_resultout := 'COMPLETE:MSCA';

       --Bug 4160412: Start

       --Bug 4543216: Start
       ELSIF L_SIGNATURE_MODE = EDR_CONSTANTS_GRP.G_ERES_LITE then
       --Bug 4543216: End

         p_resultout := 'COMPLETE:LITE_MODE';
       --Bug 4160412: End

       --Bug 2637353: End
       ELSE
        p_resultout := 'COMPLETE:NOT_TOTAL_OFFLINE';
      END IF;
    END IF;
END IS_IT_TOTAL_OFFLINE;

PROCEDURE CHECK_TIMEOUT(
      p_itemtype   IN VARCHAR2,
      p_itemkey    IN VARCHAR2,
      p_actid      IN NUMBER,
      p_funcmode   IN VARCHAR2,
      p_resultout  OUT NOCOPY VARCHAR2   ) IS

    l_wf_timeout      NUMBER;
    l_wf_temp_timeout NUMBER;
    l_item_key        VARCHAR2(240);
    l_message     VARCHAR2(2000);

  /* This Cursor is to build the temporary group for sending timeout notification */
  CURSOR GET_USER is
    SELECT distinct USER_NAME from EDR_ESIGNATURES where to_char(event_id)=l_item_key;

    l_requester  VARCHAR2(4000);
    l_user varchar2(100);
    l_userlist  WF_DIRECTORY.UserTable;
    ui number := 1;
    l_display_name varchar2(240);
    l_group varchar2(240);
    l_ESIGN_ID VARCHAR2(30);

BEGIN

    --Bug 4074173 : start
    l_wf_timeout       := GET_WF_ITEM_ATTRIBUTE_NUMBER(p_itemtype, p_itemkey,'TIMEOUT_RESEND_COUNT');
    l_wf_temp_timeout  := GET_WF_ITEM_ATTRIBUTE_NUMBER(p_itemtype, p_itemkey,'TEMP_RESEND_COUNT');
    l_item_key         := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_PAGEFLOW_ITEMKEY');

    l_userlist(1)  := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_SIGN_REQUESTER');
    l_requester  := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_SIGN_REQUESTER');
    l_display_name :='eSignature Group';
    l_group :='EDRPSIG_ROLE';
    l_ESIGN_ID := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_ESIGN_ROW_ID');
    --Bug 4074173 : end

    IF p_funcmode='RUN' THEN
     /* Figure out if the count exceeded */

     if l_wf_temp_timeout >= l_wf_timeout then

      /* Count Reached, prepare role */
      /* SKARIMIS Get the user List */
      OPEN GET_USER;
       LOOP
         fetch GET_USER into l_user;
         EXIT when GET_USER%NOTFOUND;
         IF l_requester <> l_user THEN
            l_userlist(ui+1):=l_user;
            ui := ui + 1;
         END IF;
      END LOOP;
      CLOSE GET_USER;

      /* Create ADHOC group */

         If (wf_directory.getRoleDisplayName('EDRPSIG_ROLE') is NULL) then
            /* Start Creating the Role */

             wf_directory.CreateAdHocRole2(role_name=>l_group,
                                          role_display_name=>l_display_name,
					  role_users=>l_userlist,
				          expiration_date=>NULL);
           ELSE
            wf_directory.RemoveUsersFromAdHocRole(role_name=>'EDRPSIG_ROLE',
						  role_users=>NULL);
            wf_directory.AddUsersToAdHocRole2(role_name=>'EDRPSIG_ROLE',
						  role_users=>l_userlist);
           END IF;

            SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,p_itemkey,
           					  'ESIG_GROUP' ,
                                      'EDRPSIG_ROLE');
               UPDATE EDR_ESIGNATURES
                 SET    SIGNATURE_STATUS    = 'TIMEDOUT'
                 WHERE  SIGNATURE_ID = l_ESIGN_ID;
        p_resultout := 'COMPLETE:Y';
      ELSE
        SET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'TEMP_RESEND_COUNT',l_wf_temp_timeout+1);
        p_resultout := 'COMPLETE:N';
      END IF;
    END IF;
  END CHECK_TIMEOUT;

/************************************************************************************
****   Following Procedure is used by sign-on screen. it accepts notification id  ***
****   and returns workflow item type ane item key these values are used to set   ***
****   page context in offline case.                                              ***
*************************************************************************************/

  PROCEDURE getItemKey(p_notif in varchar2,
                       p_item_key out NOCOPY varchar2,
                       p_item_type out NOCOPY varchar2) is
    cursor getItemKey is
      select ITEM_KEY, ITEM_TYPE
      from WF_ITEM_ACTIVITIES_HISTORY_V
      where NOTIFICATION_ID = p_notif;
  BEGIN
    open getItemKey;
    fetch getItemKey into p_item_key,p_item_type;
    close getItemKey;
  END;

--Bug 3072401: Start
PROCEDURE SEND_FINAL_APPROVAL_NTF
( p_itemtype                           VARCHAR2,
  p_itemkey                            VARCHAR2,
  p_actid                              NUMBER,
  p_funcmode                           VARCHAR2,
  p_resultout              OUT NOCOPY  VARCHAR2
)
AS
  l_return_status VARCHAR2(25);
  l_event_id NUMBER;
  l_signature_status VARCHAR2(25);
  L_CURR_MODE VARCHAR2(30);

BEGIN

  --Bug 4074173 : start
  l_return_status  := G_NO;
  l_event_id := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_PAGEFLOW_ITEMKEY');
  L_CURR_MODE := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_CURRENT_MODE');
  --Bug 4074173 : end

  --get the status of the signature process
  select ERECORD_SIGNATURE_STATUS into l_signature_status
  from EDR_ERECORDS
  WHERE  EVENT_ID =  l_event_id;

  if (l_signature_status = G_SUCCESS_STATUS and L_CURR_MODE='OFFLINE') then
    l_return_status := G_YES;
  end if;

  p_resultout := l_return_status;

END SEND_FINAL_APPROVAL_NTF;

PROCEDURE SEND_INDV_APPROVAL_NTF
( p_itemtype                           VARCHAR2,
  p_itemkey                            VARCHAR2,
  p_actid                              NUMBER,
  p_funcmode                           VARCHAR2,
  p_resultout               OUT NOCOPY  VARCHAR2
)
AS
  l_return_status VARCHAR2(25);

  l_event_id NUMBER;
  l_send_individual_ntf VARCHAR2(10);
  l_requester  VARCHAR2(4000);

  -- Bug 3315185 : Added to store requester id to fetch profile option
  l_requester_id number;

BEGIN

  --Bug 4074173 : start
  l_return_status := G_NO;
  l_event_id := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_PAGEFLOW_ITEMKEY');
  l_requester  := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#WF_SIGN_REQUESTER');
  --Bug 4074173 : end

  -- Bug 3315185 : Modified profile option access level to user level
  --               for accessing the requester's preference first.

  --read the profile option to find out when the requester needs the notification
  --l_send_individual_ntf := fnd_profile.value('EDR_INDIVIDUAL_APPROVAL_NTF');

  select user_id into l_requester_id from fnd_user where user_name = trim(l_requester);

  l_send_individual_ntf := fnd_profile.value_specific(NAME => 'EDR_INDIVIDUAL_APPROVAL_NTF',
						      USER_ID => l_requester_id );


  -- If the user has not set this profile option, access it at site level
  if ( l_send_individual_ntf is null) then
  	l_send_individual_ntf := fnd_profile.value_specific( NAME => 'EDR_INDIVIDUAL_APPROVAL_NTF');
  end if;

  -- Bug 3315185 : End

  if (l_send_individual_ntf = 'Y') then
    l_return_status := G_YES;
  end if;

  p_resultout := l_return_status;

END SEND_INDV_APPROVAL_NTF;
--Bug 3072401: End


--Bug 3207385: Start
PROCEDURE RAISE_APPR_COMPLETION_EVT
( p_itemtype                           VARCHAR2,
  p_itemkey                            VARCHAR2,
  p_actid                              NUMBER,
  p_funcmode                           VARCHAR2,
  p_resultout              OUT NOCOPY  VARCHAR2
)

is

--This variable would hold the event object store in workflow.
l_psig_event wf_event_t;

--This variable would hold the original event name.
l_orig_event_name varchar2(240);

--This variable would hold the original event key.
l_orig_event_key varchar2(240);

--This would hold the name of the approval completion event.
l_event_name varchar2(240);

--This would hold the name of the event key set while raising the approval completion event.
l_event_key varchar2(240);

--This would hold the e-record ID of the event which is being processed.
l_erecord_id varchar2(128);

--This would hold the document status as it exists in the evidence store for the e-record identified
--by the above e-record ID.
l_event_status varchar2(32);

l_param_list WF_PARAMETER_LIST_T;

BEGIN

l_psig_event := wf_engine.getItemAttrEvent(p_itemtype, p_itemkey,'#PSIG_EVENT');

l_orig_event_name := l_psig_event.getEventName();

l_orig_event_key := l_psig_Event.getEventKey();

--Obtain the e-record and event status from workflow from workflow.
l_erecord_id := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype, p_itemkey,'#ERECORD_ID');
l_event_status := GET_WF_ITEM_ATTRIBUTE_TEXT(p_itemtype,p_itemkey,EDR_CONSTANTS_GRP.G_FINAL_DOCUMENT_STATUS);


l_event_name := EDR_CONSTANTS_GRP.G_APPROVAL_COMPLETION_EVT;
l_event_key := l_erecord_id;

--Set the payload parameters for the approval completion event.

wf_event.addParameterToList(EDR_CONSTANTS_GRP.G_ORIGINAL_EVENT_NAME,l_orig_event_name,l_param_list);

wf_event.addParameterToList(EDR_CONSTANTS_GRP.G_ORIGINAL_EVENT_KEY,l_orig_event_key,l_param_list);

wf_event.addParameterToList(EDR_CONSTANTS_GRP.G_ERECORD_ID,l_erecord_id,l_param_list);

wf_event.addParameterToList(EDR_CONSTANTS_GRP.G_EVENT_STATUS,l_event_status,l_param_list);

--Raise the approval completion event.
WF_EVENT.RAISE3(L_EVENT_NAME,
                L_EVENT_KEY,
                null,
                L_PARAM_LIST,
                NULL);

END RAISE_APPR_COMPLETION_EVT;
--Bug 3207385: End
-- Bug 5166723 : start
PROCEDURE  MOVE_WF_ACTIVITY(P_ITEMTYPE                IN VARCHAR2,
                           P_ITEMKEY                 IN VARCHAR2,
                            P_CURRENT_ACTIVITY         IN VARCHAR2,
                           P_RESULT_CODE IN VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   -- P_CURRENT_ACTIVITY => PSIG_ESIGN_SIGNER_LIST
    FND_WF_ENGINE.COMPLETEACTIVITY(P_ITEMTYPE, P_ITEMKEY, P_CURRENT_ACTIVITY , P_RESULT_CODE);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    --Diagnostics Start
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_PSIG_PAGE_FLOW');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','MOVE_WF_ACTIVITY');
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_PSIG_PAGE_FLOW.MOVE_WF_ACTIVITY',
                      FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;
END MOVE_WF_ACTIVITY;
-- Bug 5166723 : End
END EDR_PSIG_PAGE_FLOW;

/
