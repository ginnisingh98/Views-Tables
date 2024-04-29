--------------------------------------------------------
--  DDL for Package Body POR_AME_APPROVAL_LIST_WF1S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_AME_APPROVAL_LIST_WF1S" AS
/* $Header: POXAME1B.pls 120.2.12010000.3 2011/05/24 13:06:23 rojain ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

-- private procedure
--------------------------------------------------------------------------------

--Start of Comments
--Name: updateApprovalListResponse
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Call AME API to update approval response
--Parameters:
--IN:
--itemtype
--  workflow item type
--itemtype
--  workflow item key
--p_transaction_type
--  AME transaction type
--p_document_id
--  document ID
--p_approver_id
--  approver ID, who responds to the notification
--p_insertion_type
--  AME insertion type of the approver who responds to the notification
--p_authority_type
--  AME authority type of the approver who responds to the notification
--p_forward_to_id
--  Forward to person ID
--p_response
--  Notification response
--OUT:
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE updateApprovalListResponse(itemtype        in varchar2,
                                        itemkey         in varchar2,
                                        p_transaction_type IN VARCHAR2,
                                        p_document_id      IN  NUMBER,
                                        p_approver_id      IN  NUMBER,
                                        p_insertion_type   IN VARCHAR2 default null,
                                        p_authority_type   IN VARCHAR2 default null,
                                        p_forward_to_id    IN  NUMBER default null,
                                        p_response         IN  VARCHAR2);

--------------------------------------------------------------------------------

--Public procedures
--------------------------------------------------------------------------------
--Start of Comments
--Name: setAmeAttributes
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler
--  set ame related attribute values and change first approver if user performs 'forwarding' via core-apps
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--End of Comments
-------------------------------------------------------------------------------

Procedure setAmeAttributes(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2 )
is

  l_progress                  VARCHAR2(100) := '000';
  l_transaction_type          PO_DOCUMENT_TYPES.AME_TRANSACTION_TYPE%TYPE;
  l_document_id               NUMBER;
  l_interface_source      VARCHAR2(30);

  l_tmp_approver ame_util.approverRecord2;
  l_forward_to                NUMBER;
  l_ApprovalListStr       VARCHAR2(32000);
  l_ApprovalListCount     NUMBER;
  l_QuoteChar             VARCHAR2(1);
  l_FieldDelimiter        VARCHAR2(1);
  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);


begin

   IF (funcmode = 'RUN') THEN
       l_progress := '001';
       IF (g_po_wf_debug = 'Y') THEN
           /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
       END IF;

       l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

       l_transaction_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'AME_TRANSACTION_TYPE');

       l_interface_source := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'INTERFACE_SOURCE_CODE');

       IF ( l_transaction_type is not null) THEN

   IF l_interface_source = 'REMIND_NOTIF' THEN

             l_progress := 'for ame when remin_notif clear all approvers';
              IF (g_po_wf_debug = 'Y') THEN
                      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
              END IF;

              BEGIN

        ame_api2.clearAllApprovals( applicationIdIn   => por_ame_approval_list.applicationId     ,
                                    transactionIdIn   => l_document_id,
                                    transactionTypeIn => l_transaction_type
                                  );

              EXCEPTION
              WHEN OTHERS THEN

             l_progress := 'for ame clear all approvers had exceptions '|| SQLERRM || ' code='|| sqlcode;
              IF (g_po_wf_debug = 'Y') THEN
                      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
              END IF;
              END;
         END IF;


           IF l_interface_source = 'PO_FORM' THEN

              l_forward_to := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_ID');
              l_progress := '002';
              IF (g_po_wf_debug = 'Y') THEN
                      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
              END IF;

              If ( l_forward_to is not null ) then
                   por_ame_approval_list.change_first_approver ( pReqHeaderId => l_document_id,
                                               pPersonId => l_forward_to,
                                               pApprovalListStr => l_ApprovalListStr,
                                               pApprovalListCount => l_ApprovalListCount,
                                               pQuoteChar => l_QuoteChar,
                                               pFieldDelimiter => l_FieldDelimiter   );

                   l_progress := '003';
                   IF (g_po_wf_debug = 'Y') THEN
                      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
                   END IF;

                   --  return the req to requester if forwarding fails
                   if ( l_ApprovalListCount = 0 or l_ApprovalListStr = 'NO_DATA_FOUND' or l_ApprovalListStr = 'EXCEPTION' ) then
                        resultout:='COMPLETE:'||'N';
                        return;
                   end if;

              End If; -- for l_forward_to is not null

          END IF;  -- for 'is_form'

          resultout:='COMPLETE:'||'Y';

      ELSE

          resultout:='COMPLETE:'||'N';

      END IF;

      l_progress := '004';
      IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
      END IF;

 END IF; -- FOR 'RUN' MODE

EXCEPTION
     WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('POR_AME_APPROVAL_LIST_WF1S','setAmeAttributes',l_progress,sqlerrm);

    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_APPROVAL_LIST_WF1S.setAmeAttributes');
    RAISE;

end;


--Public procedures
--------------------------------------------------------------------------------
--Start of Comments
--Name: Is_Ame_For_Approval
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler
--  Check if AME should be used for requisition approval process
--  if Yes then
--    initialize ame approval process
--    set attribute 'AME_TRANSACTION_TYPE' and 'IS_AME_APPROVAL'
--  Returns 'Y' if the workflow should be routed using AME for approval.
--  Returns 'N' if the workflow should not be routed using AME for approval.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
procedure Is_Ame_For_Approval(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(100) := '000';
  l_document_type             PO_DOCUMENT_TYPES.DOCUMENT_TYPE_CODE%TYPE;
  l_document_subtype          PO_DOCUMENT_TYPES.DOCUMENT_SUBTYPE%TYPE;
  l_is_ame_approval  boolean;
  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);
  l_transaction_type          PO_DOCUMENT_TYPES.AME_TRANSACTION_TYPE%TYPE;

begin

  IF (funcmode = 'RUN') THEN
    l_progress := 'Is_Ame_For_Approval: 001';
    IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

   l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

   l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');


    SELECT ame_transaction_type
      INTO l_transaction_type
      FROM po_document_types
     WHERE document_type_code = l_document_type
       and document_subtype = l_document_subtype;

    if (l_transaction_type is not null) then

       PO_WF_UTIL_PKG.SetItemAttrText( itemtype => itemType,
                              itemkey    => itemkey,
                              aname      => 'AME_TRANSACTION_TYPE',
                              avalue     => l_transaction_type);
       PO_WF_UTIL_PKG.SetItemAttrText( itemtype => itemType,
                              itemkey    => itemkey,
                              aname      => 'IS_AME_APPROVAL',
                              avalue     => 'Y');

      resultout:='COMPLETE:'||'Y';

    else
      PO_WF_UTIL_PKG.SetItemAttrText( itemtype => itemType,
                              itemkey    => itemkey,
                              aname      => 'IS_AME_APPROVAL',
                              avalue     => 'N');

      resultout:='COMPLETE:'||'N';

    end if;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('POR_AME_APPROVAL_LIST_WF1S','Is_Ame_For_Approval',l_progress,sqlerrm);

    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_APPROVAL_LIST_WF1S.Is_Ame_For_Approval');
    RAISE;

END Is_Ame_For_Approval;

--------------------------------------------------------------------------------
--Start of Comments
--Name: Is_Ame_For_Rco_Approval
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler
--  Check if AME should be used for RCO approval process
--  if Yes then
--    initialize ame approval process
--    set attribute 'AME_TRANSACTION_TYPE' and 'IS_AME_APPROVAL'
--  Returns 'Y' if the workflow should be routed using AME for approval.
--  Returns 'N' if the workflow should not be routed using AME for approval.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
procedure Is_Ame_For_Rco_Approval(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(100) := '000';
  l_is_ame_approval  boolean;
  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);
  l_transaction_type          PO_DOCUMENT_TYPES.AME_TRANSACTION_TYPE%TYPE;

begin

  IF (funcmode = 'RUN') THEN
    l_progress := 'Is_Ame_For_Rco_Approval: 001';
    IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;


    begin
       SELECT ame_transaction_type
       INTO l_transaction_type
       FROM po_document_types
       WHERE document_type_code = 'CHANGE_REQUEST'
          and document_subtype = 'REQUISITION' ;
    exception
    when others then
      PO_WF_UTIL_PKG.SetItemAttrText( itemtype => itemType,
                              itemkey    => itemkey,
                              aname      => 'IS_AME_APPROVAL',
                              avalue     => 'N');
    return;
    end;

    l_progress := 'Is_Ame_For_Rco_Approval: 002';
    IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

  if (l_transaction_type is not null) then

      PO_WF_UTIL_PKG.SetItemAttrText( itemtype => itemType,
                              itemkey    => itemkey,
                              aname      => 'AME_TRANSACTION_TYPE',
                              avalue     => l_transaction_type);
      PO_WF_UTIL_PKG.SetItemAttrText( itemtype => itemType,
                              itemkey    => itemkey,
                              aname      => 'IS_AME_APPROVAL',
                              avalue     => 'Y');

      resultout:='COMPLETE:'||'Y';

    else

      PO_WF_UTIL_PKG.SetItemAttrText( itemtype => itemType,
                              itemkey    => itemkey,
                              aname      => 'IS_AME_APPROVAL',
                              avalue     => 'N');
      resultout:='COMPLETE:'||'N';
    end if;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('POR_AME_APPROVAL_LIST_WF1S','Is_Ame_For_Rco_Approval',l_progress,sqlerrm);

    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_APPROVAL_LIST_WF1S.Is_Ame_For_Rco_Approval');
    RAISE;

END Is_Ame_For_Rco_Approval;

--------------------------------------------------------------------------------
--Start of Comments
--Name:
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler
--  Get the next approver name from the AME approval list
--  And update workflow attributes.
--  If no next approver is found, approval routing will terminate.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments

--Note: For 11.5 WF only.  Obsoleted in R12
-------------------------------------------------------------------------------
procedure Get_Next_Approver(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(100) := '000';
  l_document_id               NUMBER;
  l_document_type             PO_DOCUMENT_TYPES.DOCUMENT_TYPE_CODE%TYPE;
  l_document_subtype          PO_DOCUMENT_TYPES.DOCUMENT_SUBTYPE%TYPE;
  l_next_approver_id          NUMBER;
  l_next_approver_user_name   fnd_user.user_name%TYPE;
  l_next_approver_disp_name   wf_users.display_name%TYPE;
  l_orig_system               wf_users.orig_system%TYPE := 'PER';
  l_sequence_num              NUMBER;
  l_approver_type             VARCHAR2(30);
  E_FAILURE                   EXCEPTION;

  l_doc_string                varchar2(200);
  l_preparer_user_name        fnd_user.user_name%TYPE;
  l_org_id                    number;

  l_next_approver             ame_util.approverRecord;
  l_insertion_type            VARCHAR2(30);
  l_authority_type            VARCHAR2(30);
  l_transaction_type          PO_DOCUMENT_TYPES.AME_TRANSACTION_TYPE%TYPE;

BEGIN
   IF (funcmode = 'RUN') THEN

   l_progress := 'Get_Next_Approver: 001';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
   END IF;

   l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

   l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

   l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

   l_transaction_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'AME_TRANSACTION_TYPE');


   l_progress := 'Get_Next_Approver: 002-'||to_char(l_document_id)||'-'||
                           l_document_type||'-'||l_document_subtype;
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
   END IF;
   ame_api.getNextApprover(applicationIdIn=>applicationId,
                            transactionIdIn=>l_document_id,
                            transactionTypeIn=>l_transaction_type,
                            nextApproverOut=>l_next_approver);
   l_progress := ('l_next_approver=' || to_char(l_next_approver.person_id));
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
   END IF;

   IF l_next_approver.approval_status = ame_util.exceptionStatus THEN
     raise   E_FAILURE;
   ELSIF ((l_next_approver.user_id is null) and
     (l_next_approver.person_id is null) and
     (l_next_approver.first_name is null) and
     (l_next_approver.last_name is null) and
     (l_next_approver.api_insertion is null) and
     (l_next_approver.authority is null) and
     (l_next_approver.approval_status is null)) THEN
     resultout:='COMPLETE:'||'NO_NEXT_APPROVER';
     return;
   ELSE
     l_next_approver_id := l_next_approver.person_id;
     l_insertion_type := l_next_approver.api_insertion;
     l_authority_type := l_next_approver.authority;
     l_progress := 'Get_Next_Approver: 003- get_next_approver - '||
                       to_char(l_next_approver_id);

     IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
     END IF;

     wf_engine.SetItemAttrNumber ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'APPROVER_EMPID',
                                   avalue     => l_next_approver_id);


     wf_engine.SetItemAttrNumber ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'FORWARD_TO_ID',
                                   avalue     => l_next_approver_id);
     wf_engine.SetItemAttrText( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'AME_INSERTION_TYPE' ,
                              avalue     => l_insertion_type);

     wf_engine.SetItemAttrText( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'AME_AUTHORITY_TYPE' ,
                              avalue     => l_authority_type);

     l_orig_system:= 'PER';

     WF_DIRECTORY.GetUserName(l_orig_system,
                            l_next_approver_id,
                            l_next_approver_user_name,
                            l_next_approver_disp_name);

     l_progress := 'Get_Next_Approver: 004- GetUserName - '||
                    l_next_approver_user_name;
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
     END IF;


     wf_engine.SetItemAttrText( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_USER_NAME' ,
                              avalue     => l_next_approver_user_name);

     wf_engine.SetItemAttrText( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_DISPLAY_NAME' ,
                              avalue     => l_next_approver_disp_name);

     wf_engine.SetItemAttrText( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_TO_USERNAME' ,
                              avalue     => l_next_approver_user_name);

     wf_engine.SetItemAttrText( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_TO_DISPLAY_NAME' ,
                              avalue     => l_next_approver_disp_name);

     resultout:='COMPLETE:'||'VALID_APPROVER';
     return;
   END IF;
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('POR_AME_APPROVAL_LIST_WF1S','Get_Next_Approver',l_progress,sqlerrm);

    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_APPROVAL_LIST_WF1S.GET_NEXT_APPROVER');

    RAISE;

END Get_Next_Approver;



--------------------------------------------------------------------------------
--Start of Comments
--Name: Update_Approval_List_Response
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler
--  After an approval notification is responded, update AME approval list.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
procedure Update_Approval_List_Response(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(300) := '000';
  l_approver_id               NUMBER := NULL;
  l_document_id               NUMBER;


  l_doc_string                varchar2(200);

  l_org_id                    number;
  l_insertion_type            VARCHAR2(30);
  l_authority_type            VARCHAR2(30);
  l_value                     VARCHAR2(2000);
  l_responder_id              NUMBER := NULL;
  l_forward_to_id             NUMBER := NULL;
  l_end_date                  DATE; -- notification end date
  l_transaction_type          PO_DOCUMENT_TYPES.AME_TRANSACTION_TYPE%TYPE;

  l_document_type             PO_DOCUMENT_TYPES.DOCUMENT_TYPE_CODE%TYPE;
  l_document_subtype          PO_DOCUMENT_TYPES.DOCUMENT_SUBTYPE%TYPE;
  l_preparer_user_name        fnd_user.user_name%TYPE;

BEGIN

  l_progress := ' Update_Approval_List_Response: 001- at beginning of function';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
  END IF;

  IF (funcmode='RUN') THEN

      PO_APPROVAL_LIST_WF1S.get_approval_response(itemtype => itemtype,
                       itemkey  => itemkey,
                       responderId => l_responder_id,
                       response =>l_value,
                       responseEndDate =>l_end_date,
                       forwardToId => l_forward_to_id);

      l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

      l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

      l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

      l_approver_id := wf_engine.GetItemAttrNumber(itemtype=>itemtype,
                                                 itemkey=>itemkey,
                                                 aname=>'APPROVER_EMPID');

      l_insertion_type := wf_engine.GetItemAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'AME_INSERTION_TYPE');

      l_authority_type := wf_engine.GetItemAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'AME_AUTHORITY_TYPE');

      l_progress := 'Update_Approval_List_Response: 010 APP'||
                       to_char(l_approver_id) || ' RES'||to_char(l_responder_id);

      l_progress := l_progress || ' FWD'||to_char(l_forward_to_id) ||
                    ' RESPONSE' || l_value || ' INSERTION? '||
                    l_insertion_type|| ' AUTHORITY? ' || l_authority_type;

      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
      END IF;

      l_transaction_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'AME_TRANSACTION_TYPE');

      updateApprovalListResponse(itemtype=>itemtype,
                      itemkey=>itemkey,
                      p_transaction_type=>l_transaction_type,
                      p_document_id=>l_document_id,
                      p_approver_id=>l_approver_id,
                      p_insertion_type=>l_insertion_type,
                      p_authority_type=>l_authority_type,
                      p_forward_to_id=>l_forward_to_id,
                      p_response=>l_value);

      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
      END IF;

      resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
      RETURN;
  END IF; -- run mode

EXCEPTION

 WHEN OTHERS THEN

   l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
   l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
   wf_core.context('POR_AME_APPROVAL_LIST_WF1S',
                   'Update_Approval_List_Response',l_progress,sqlerrm);

   PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_REQAPPRV_PVT.UPDATE_APPROVAL_LIST_RESPONSE');

   RAISE;

END Update_Approval_List_Response;


--------------------------------------------------------------------------------
--Start of Comments
--Name: Update_Approver_Timeout
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler
--  After an approval notification is timed out, update AME approval list.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
procedure Update_Approver_Timeout(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(300) := '000';
  l_approver_id               NUMBER := NULL;
  l_document_id               NUMBER;
  l_doc_string                varchar2(200);
  l_transaction_type          PO_DOCUMENT_TYPES.AME_TRANSACTION_TYPE%TYPE;
  l_document_type             PO_DOCUMENT_TYPES.DOCUMENT_TYPE_CODE%TYPE;
  l_document_subtype          PO_DOCUMENT_TYPES.DOCUMENT_SUBTYPE%TYPE;
  l_preparer_user_name        fnd_user.user_name%TYPE;


BEGIN

  l_progress := ' Update_Approver_timeout: 001- at beginning of function';
  IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
  END IF;

  IF (funcmode='RUN') THEN
      l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

      l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

      l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

      l_approver_id := wf_engine.GetItemAttrNumber(itemtype=>itemtype,
                                                 itemkey=>itemkey,
                                                 aname=>'APPROVER_EMPID');

      l_transaction_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'AME_TRANSACTION_TYPE');
      updateApprovalListResponse(itemtype=>itemtype,
                      itemkey=>itemkey,
                      p_transaction_type=>l_transaction_type,
                      p_document_id=>l_document_id,
                      p_approver_id=>l_approver_id,
                      p_response=>'TIMEOUT');

      l_progress := ' Update_Approver_timeout: 002- at end of function';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
      END IF;

      resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
      RETURN;
  END IF; -- run mode

EXCEPTION

 WHEN OTHERS THEN

   l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
   l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
   wf_core.context('POR_AME_APPROVAL_LIST_WF1S',
                   'Update_Approval_List_Response',l_progress,sqlerrm);

   PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_REQAPPRV_PVT.UPDATE_APPROVAL_LIST_RESPONSE');

   RAISE;

END Update_Approver_Timeout;



--Note: procedure updateApprovalListResponse is For 11.5 WF only. Obsoleted in R12.
PROCEDURE updateApprovalListResponse(itemtype        in varchar2,
                                        itemkey         in varchar2,
                                        p_transaction_type IN VARCHAR2,
                                        p_document_id      IN  NUMBER,
                                        p_approver_id      IN  NUMBER,
                                        p_insertion_type   IN VARCHAR2 default null,
                                        p_authority_type   IN VARCHAR2 default null,
                                        p_forward_to_id    IN  NUMBER default null,
                                        p_response         IN  VARCHAR2) IS

  l_progress                VARCHAR2(100) := '000';
  forwardee                 ame_util.approverRecord;
  currentApprover           ame_util.approverRecord;

BEGIN

  l_progress := 'transaction: '|| p_transaction_type || '; response:' || p_response;
  currentApprover.person_id :=p_approver_id;
  currentApprover.api_insertion :=p_insertion_type;
  currentApprover.authority := p_authority_type;

  if(p_response='APPROVE') then
    ame_api.updateApprovalStatus2(applicationIdIn=>applicationId,
                            transactionIdIn=>p_document_id,
                            approvalStatusIn=>ame_util.approvedStatus,
                            approverPersonIdIn=>p_approver_id,
                            transactionTypeIn=>p_transaction_type);

  elsif(p_response='REJECT') then
    ame_api.updateApprovalStatus2(applicationIdIn=>applicationId,
                            transactionIdIn=>p_document_id,
                            approvalStatusIn=>ame_util.rejectStatus,
                            approverPersonIdIn=>p_approver_id,
                            transactionTypeIn=>p_transaction_type);

  elsif(p_response='FORWARD') then
    forwardee.authority := currentApprover.authority;
    forwardee.person_id :=  p_forward_to_id;
    if(currentApprover.authority = ame_util.authorityApprover and
        (currentApprover.api_insertion = ame_util.apiAuthorityInsertion or
         currentApprover.api_insertion = ame_util.oamGenerated)) then
      forwardee.api_insertion := ame_util.apiAuthorityInsertion;
    else
      forwardee.api_insertion := ame_util.apiInsertion;
    end if;

    currentApprover.approval_status := ame_util.forwardStatus;
    ame_api.updateApprovalStatus(applicationIdIn=>applicationId,
                            transactionIdIn=>p_document_id,
                            transactionTypeIn=>p_transaction_type,
                            approverIn=>currentApprover,
                            forwardeeIn=>forwardee);

  elsif  (p_response='APPROVE_AND_FORWARD') THEN

    forwardee.authority := currentApprover.authority;
    forwardee.person_id :=  p_forward_to_id;
    if(currentApprover.authority = ame_util.authorityApprover and
        (currentApprover.api_insertion = ame_util.apiAuthorityInsertion or
         currentApprover.api_insertion = ame_util.oamGenerated)) then
      forwardee.api_insertion := ame_util.apiAuthorityInsertion;
    else
      forwardee.api_insertion := ame_util.apiInsertion;
    end if;

    currentApprover.approval_status := ame_util.approveAndForwardStatus;
    ame_api.updateApprovalStatus(applicationIdIn=>applicationId,
                            transactionIdIn=>p_document_id,
                            transactionTypeIn=>p_transaction_type,
                            approverIn=>currentApprover,
                            forwardeeIn=>forwardee);
  elsif(p_response='TIMEOUT') then
    ame_api.updateApprovalStatus2(applicationIdIn=>applicationId,
                            transactionIdIn=>p_document_id,
                            approvalStatusIn=>ame_util.noResponseStatus,
                            approverPersonIdIn=>p_approver_id,
                            transactionTypeIn=>p_transaction_type);


  end if;

  RETURN;
EXCEPTION

 WHEN OTHERS THEN
   wf_core.context('PO_AME_APPROVAL_LIST_WF1S',
                   'updateApprovalListResponse',l_progress,sqlerrm);

   RAISE;
END updateApprovalListResponse;


procedure SET_FORWARD_RESERVE_APPROVER(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(300) := '000';


  l_doc_string                varchar2(200);

  l_value                     VARCHAR2(2000);
  l_responder_id              NUMBER := NULL;
  l_forward_to_id             NUMBER := NULL;
  l_end_date                  DATE; -- notification end date

  l_user_name        fnd_user.user_name%TYPE;
  l_preparer_user_name      fnd_user.user_name%TYPE;

  l_disp_user_name            VARCHAR2(2000);
 BEGIN

  l_progress := ' SET_FORWARD_RESERVE_APPROVER: 001- at beginning of function';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
  END IF;


   IF (funcmode='RUN') THEN


      PO_APPROVAL_LIST_WF1S.get_approval_response(itemtype => itemtype,
                       itemkey  => itemkey,
                       responderId => l_responder_id,
                       response =>l_value,
                       responseEndDate =>l_end_date,
                       forwardToId => l_forward_to_id);


  l_progress := ' DO 2 Roopal Update_Approval_List_Response:- p_itemtype: ' || itemtype || ' l_forward_to_id: ' || l_forward_to_id;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
  END IF;

                      po_wf_util_pkg.SetItemAttrNumber( itemtype   =>  itemtype,
                                         itemkey    =>  itemkey,
                                         aname      =>  'APPROVER_EMPID',
                                         avalue     =>  l_forward_to_id
                                       );



        PO_REQAPPROVAL_INIT1.get_user_name
    (
      p_employee_id =>l_forward_to_id,
      x_username =>l_user_name,
      x_user_display_name => l_disp_user_name);


               po_wf_util_pkg.SetItemAttrText( itemtype   =>  itemtype,
                                         itemkey    =>  itemkey,
                                         aname      =>  'APPROVER_USER_NAME',
                                         avalue     =>  l_user_name
                                       );



     l_progress := ' DO 2 Roopal Update_Approval_List_Response:- l_user_name: ' || l_user_name || ' l_disp_user_name: ' || l_disp_user_name;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
  END IF;

      resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
      RETURN;
  END IF; -- run mode

EXCEPTION

 WHEN OTHERS THEN

   l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
   l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
   wf_core.context('POR_AME_APPROVAL_LIST_WF1S',
                   'SET_FORWARD_RESERVE_APPROVER',l_progress,sqlerrm);

   PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_REQAPPRV_PVT.SET_FORWARD_RESERVE_APPROVER');

   RAISE;

END SET_FORWARD_RESERVE_APPROVER;



END POR_AME_APPROVAL_LIST_WF1S;

/
