--------------------------------------------------------
--  DDL for Package Body POR_AME_REQ_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_AME_REQ_WF_PVT" AS
/* $Header: POXAMEPB.pls 120.41.12010000.12 2014/08/12 05:26:32 mitao ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

g_next_approvers ame_util.approversTable2;

FUNCTION position_has_valid_approvers( documentId NUMBER, documentType VARCHAR2 )RETURN VARCHAR2;

Function is_last_approver_record( documentId NUMBER, documentType VARCHAR2, approverRecord in ame_util.approverRecord2 ) RETURN VARCHAR2;

PROCEDURE UpdateActionHistory(p_document_id      NUMBER,
                              p_action           VARCHAR2,
                              p_note             VARCHAR2,
                              p_current_approver NUMBER);

--------------------------------------------------------------------------------
--Start of Comments
--Name: Get_Next_Approvers
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
-------------------------------------------------------------------------------
procedure Get_Next_Approvers(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(3500) := '000';
  l_document_id               NUMBER;
  l_document_type             PO_DOCUMENT_TYPES.DOCUMENT_TYPE_CODE%TYPE;
  l_document_subtype          PO_DOCUMENT_TYPES.DOCUMENT_SUBTYPE%TYPE;
  l_next_approver_id          NUMBER;
  l_next_approver_user_name   fnd_user.user_name%TYPE;
  l_next_approver_disp_name   wf_users.display_name%TYPE;
  l_orig_system               wf_users.orig_system%TYPE := ame_util.perOrigSystem;
  l_sequence_num              NUMBER;
  l_approver_type             VARCHAR2(30);

  l_doc_string                varchar2(200);
  l_preparer_user_name        fnd_user.user_name%TYPE;
  l_org_id                    number;

  l_next_approver             ame_util.approverRecord;
  l_insertion_type            VARCHAR2(30);
  l_authority_type            VARCHAR2(30);
  l_transaction_type          PO_DOCUMENT_TYPES.AME_TRANSACTION_TYPE%TYPE;

  l_completeYNO                   varchar2(100);
  l_position_has_valid_approvers  varchar2(10);
  l_need_to_get_next_approver     boolean;

  l_ame_exception                ame_util.longestStringType;

BEGIN
   IF (funcmode = 'RUN') THEN

       l_progress := 'Get_Next_Approver: 001';
       IF (g_po_wf_debug = 'Y') THEN
           PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
       END IF;

       /* Check if there is any AME exception.
          If yes, then return 'invalid approver' */
       l_ame_exception := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'AME_EXCEPTION');
       IF l_ame_exception IS NOT NULL THEN
          resultout:='COMPLETE:'||'INVALID_APPROVER';
	  RETURN;
       END IF;

       l_document_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'DOCUMENT_ID');

       l_document_type := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'DOCUMENT_TYPE');

       l_document_subtype := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                             itemkey  => itemkey,
                                                             aname    => 'DOCUMENT_SUBTYPE');

       l_transaction_type := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                             itemkey  => itemkey,
                                                             aname    => 'AME_TRANSACTION_TYPE');

       l_progress := 'Get_Next_Approver: 002-'||to_char(l_document_id)||'-'|| l_document_type||'-'||l_document_subtype;

       IF (g_po_wf_debug = 'Y') THEN
          PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
       END IF;

       -- Get the next approver from AME.
       LOOP

           l_need_to_get_next_approver := FALSE;
           BEGIN

               ame_util2.detailedApprovalStatusFlagYN := ame_util.booleanTrue;
               ame_api2.getNextApprovers4( applicationIdIn=>applicationId,
                                           transactionIdIn=>l_document_id,
                                           transactionTypeIn=>l_transaction_type,
                                           approvalProcessCompleteYNOut=>l_completeYNO,
                                           nextApproversOut=>g_next_approvers
                                         );

           EXCEPTION
               WHEN OTHERS THEN

                   l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
                   l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
                   wf_core.context('POR_AME_REQ_WF_PVT','Get_Next_Approvers: Unable to get the next approvers from AME.',l_progress,sqlerrm);

                   IF (g_po_wf_debug = 'Y') THEN
                      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_doc_string);
                   END IF;

                   PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_REQ_WF_PVT.GET_NEXT_APPROVERS',l_document_id);

                   resultout:='COMPLETE:'||'INVALID_APPROVER';
                   return;
           END;

           l_progress := 'Get_Next_Approver: 003- getNextApprovers4(). Approvers :' || g_next_approvers.count || ' --  Approval Process Completed :' || l_completeYNO ;
           IF (g_po_wf_debug = 'Y') THEN
              PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
           END IF;

          if ( g_next_approvers.count > 0 ) then

             l_position_has_valid_approvers := position_has_valid_approvers(l_document_id, l_transaction_type) ;

             l_progress := 'Get_Next_Approver: 004 - l_position_has_valid_approvers :' || l_position_has_valid_approvers;
             IF (g_po_wf_debug = 'Y') THEN
                PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
             END IF;

             l_progress := 'Get_Next_Approver: 005- Approvers after the validation process :' || g_next_approvers.count;
             IF (g_po_wf_debug = 'Y') THEN
                PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
             END IF;

             if(  'NO_USERS' = l_position_has_valid_approvers ) then
                l_need_to_get_next_approver := TRUE;
             end if;

           end if;

           EXIT WHEN l_need_to_get_next_approver = FALSE;
       END LOOP;

       -- Check the number of next approvers. If the count is zero, then verify the approval process is completed or not.
       if ( g_next_approvers.count > 0 ) then

         if( 'N' = l_position_has_valid_approvers ) then
                resultout:='COMPLETE:'||'INVALID_APPROVER';
         else
                resultout:='COMPLETE:'||'VALID_APPROVER';
         end if;
         return;

       else

           -- 'X' is the code when there is no rule needed and applied.

           if (l_completeYNO in ('X','Y')) then
               resultout:='COMPLETE:'||'NO_NEXT_APPROVER';
               return;
           else
               resultout:='COMPLETE:'||'';
               return;
           end if;
       end if;
  end if;
EXCEPTION
  WHEN OTHERS THEN

        l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
        l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
        wf_core.context('POR_AME_REQ_WF_PVT','Get_Next_Approvers - Unexpected Exception: ',l_progress,sqlerrm);

        IF (g_po_wf_debug = 'Y') THEN
           PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_doc_string);
        END IF;

        PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_REQ_WF_PVT.GET_NEXT_APPROVERS');
        resultout:='COMPLETE:'||'INVALID_APPROVER';
        return;
END Get_Next_Approvers;


--------------------------------------------------------------------------------
--Start of Comments
--Name: Launch_Parallel_Approval
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler. This procedure is used to send the notification for the approvers.
--  Iterate through the list of approvers got from the API call ame_api2.getNextApprovers4.
--  Get the next approver name from the global variable g_next_approvers and for each retrieved approver
--  separate workflow process is kicked. Each process is called child process.
--  If there are 3 approvers, then 3 child process will be created and each of them will be notified at the same time.
--
--  If the next approver record is of Position Hierarchy type, then the users associated to the position_id will be
--  retrieved, will be alphabetically sorted using last_name and to the first user notification will be sent.
--
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
procedure Launch_Parallel_Approval(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(500) := '000';
  l_document_id   number;
  l_item_key wf_items.item_key%TYPE;
  l_next_approver_id number;
  l_next_approver_name per_employees_current_x.full_name%TYPE;
  l_next_approver_user_name   VARCHAR2(100);
  l_next_approver_disp_name   VARCHAR2(240);
  l_orig_system               VARCHAR2(48);
  l_org_id number;
  l_functional_currency       VARCHAR2(30);
  l_transaction_type PO_DOCUMENT_TYPES.AME_TRANSACTION_TYPE%TYPE;

  n_varname   Wf_Engine.NameTabTyp;
  n_varval    Wf_Engine.NumTabTyp;

  t_varname   Wf_Engine.NameTabTyp;
  t_varval    Wf_Engine.TextTabTyp;

  l_no_positionholder exception;
  l_preparer_user_name        fnd_user.user_name%TYPE;
  l_doc_string                varchar2(200);
  l_start_block_activity varchar2(1);
  l_has_fyi_app varchar2(1);
  l_approver_index NUMBER;

  l_first_position_id NUMBER;
  l_first_approver_id NUMBER;

begin
  IF (funcmode='RUN') THEN

       l_progress := 'Launch_Parallel_Approval: 001';
       IF (g_po_wf_debug = 'Y') THEN
           PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
       END IF;

      l_document_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'DOCUMENT_ID');

      l_org_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'ORG_ID');

      l_start_block_activity := 'N';
      l_has_fyi_app := 'N';
      -- Iterate through the list of next approvers.
      l_approver_index := g_next_approvers.first();
      while ( l_approver_index is not null ) loop

        l_progress := 'Launch_Parallel_Approval: 002 -- Next Approver :' || g_next_approvers(l_approver_index).name;
        IF (g_po_wf_debug = 'Y') THEN
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
        END IF;

        SELECT
            to_char(l_document_id) || '-' || to_char(PO_WF_ITEMKEY_S.nextval)
        INTO l_item_key
        FROM sys.dual;

        -- Create a child process for the retrieved approver.
        wf_engine.CreateProcess( itemtype => itemtype,
                                 itemkey  => l_item_key,
                                 process  => 'AME_PARALLEL_APPROVAL');


        /* Need to set the parent child relationship between processes */
        wf_engine.SetItemParent( itemtype        => itemtype,
		                		 itemkey         => l_item_key,
                				 parent_itemtype => itemtype,
				                 parent_itemkey  => itemkey,
                				 parent_context  => NULL);

        t_varname(1) := 'DOCUMENT_TYPE';
        t_varval(1)  := 'REQUISITION';

        t_varname(2) := 'DOCUMENT_SUBTYPE';
        t_varval(2)  := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'DOCUMENT_SUBTYPE');

        t_varname(3) := 'PREPARER_USER_NAME';
        t_varval(3)  := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'PREPARER_USER_NAME');

        t_varname(4) := 'PREPARER_DISPLAY_NAME';
        t_varval(4)  := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'PREPARER_DISPLAY_NAME');

        t_varname(5) := 'FUNCTIONAL_CURRENCY';
        t_varval(5)  := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'FUNCTIONAL_CURRENCY');

        t_varname(6) := 'IS_AME_APPROVAL';
        t_varval(6)  := 'Y';

        t_varname(7) := 'TOTAL_AMOUNT_DSP';
        t_varval(7)  := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'TOTAL_AMOUNT_DSP');

        t_varname(8) := 'FORWARD_FROM_DISP_NAME';
        t_varval(8)  :=  po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'FORWARD_FROM_DISP_NAME');

        t_varname(9)  := 'FORWARD_FROM_USER_NAME';
        t_varval(9)  := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'FORWARD_FROM_USER_NAME');

        t_varname(10) := 'REQ_DESCRIPTION';
        t_varval(10)  := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'REQ_DESCRIPTION');

        t_varname(11) := 'REQ_AMOUNT_CURRENCY_DSP';
        t_varval(11)  :=  po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                         aname    => 'REQ_AMOUNT_CURRENCY_DSP');

        t_varname(12) := 'TAX_AMOUNT_CURRENCY_DSP';
        t_varval(12)  :=  po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'TAX_AMOUNT_CURRENCY_DSP');

        t_varname(13) := 'JUSTIFICATION';
        t_varval(13)  :=  po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'JUSTIFICATION');

        t_varname(14) := 'CONTRACTOR_REQUISITION_FLAG';
        t_varval(14)  :=  po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'CONTRACTOR_REQUISITION_FLAG');

        t_varname(15) := 'CONTRACTOR_REQUISITION_FLAG';
        t_varval(15)  :=  po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'CONTRACTOR_REQUISITION_FLAG');

        t_varname(16) := 'CONTRACTOR_STATUS';
        t_varval(16)  :=  po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'CONTRACTOR_STATUS');

        t_varname(17) := 'VENDOR_DISPLAY_NAME';
        t_varval(17)  :=  po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'VENDOR_DISPLAY_NAME');

        t_varname(18) := 'IS_SUPPLIER_EMAIL_NOT_AVAIL';
        t_varval(18)  :=  po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'IS_SUPPLIER_EMAIL_NOT_AVAIL');

        t_varname(19) := 'CONTRACTOR_ASSIGNMENT_REQD';
        t_varval(19)  :=  po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                         aname    => 'CONTRACTOR_ASSIGNMENT_REQD');

        t_varname(20) := 'DOCUMENT_NUMBER';
        t_varval(20)  := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'DOCUMENT_NUMBER');

        t_varname(21) := 'AME_TRANSACTION_TYPE';
        t_varval(21)  :=  po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'AME_TRANSACTION_TYPE');

        l_progress := 'Launch_Parallel_Approval: 003 -- Record Type :' || g_next_approvers(l_approver_index).orig_system;
        IF (g_po_wf_debug = 'Y') THEN
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
        END IF;

        -- Check whether Position Hierarchy or Employee-Sup Hierarchy setup or FND users.
        if (g_next_approvers(l_approver_index).orig_system = ame_util.perOrigSystem) then
            l_next_approver_id := g_next_approvers(l_approver_index).orig_system_id;
        elsif (g_next_approvers(l_approver_index).orig_system = ame_util.posOrigSystem) then

        begin

            select first_position_id, first_approver_id
            into l_first_position_id, l_first_approver_id
            from po_requisition_headers_all
            where l_document_id = requisition_header_id;

            if (l_first_position_id is not NULL AND l_first_position_id=g_next_approvers(l_approver_index).orig_system_id ) then

              l_next_approver_id := l_first_approver_id;

              SELECT full_name
              INTO l_next_approver_name
              FROM per_all_people_f person
              WHERE person_id = l_first_approver_id
            --Bug#7207213#This query fetches multiple records so adding a filter
              and trunc(sysdate) between person.effective_start_date and nvl(person.effective_end_date, trunc(sysdate));


            else

              /* find the persond id from the position_id*/
              SELECT person_id, full_name into l_next_approver_id,l_next_approver_name FROM (
                       SELECT person.person_id, person.full_name FROM per_all_people_f person, per_all_assignments_f asg
                       WHERE asg.position_id = g_next_approvers(l_approver_index).orig_system_id and trunc(sysdate) between person.effective_start_date
                       and nvl(person.effective_end_date, trunc(sysdate)) and person.person_id = asg.person_id
                       and asg.primary_flag = 'Y' and asg.assignment_type in ('E','C')
                       and ( person.current_employee_flag = 'Y' or person.current_npw_flag = 'Y' )
                       and asg.assignment_status_type_id not in (
                          SELECT assignment_status_type_id FROM per_assignment_status_types
                          WHERE per_system_status = 'TERM_ASSIGN'
                       ) and trunc(sysdate) between asg.effective_start_date and asg.effective_end_date order by person.last_name
              ) where rownum = 1;

            end if;

        exception
             WHEN NO_DATA_FOUND THEN
                 RAISE;
        END;

        elsif (g_next_approvers(l_approver_index).orig_system = ame_util.fndUserOrigSystem) then
            SELECT employee_id
               into l_next_approver_id
            FROM fnd_user
            WHERE user_id = g_next_approvers(l_approver_index).orig_system_id
               and trunc(sysdate) between start_date and nvl(end_date, sysdate+1);
        end if;

        t_varname(22) := 'AME_APPROVER_TYPE';
        t_varval(22) := g_next_approvers(l_approver_index).orig_system;


        WF_DIRECTORY.GetUserName(ame_util.perOrigSystem, l_next_approver_id, l_next_approver_user_name, l_next_approver_disp_name);

        l_progress := 'Launch_Parallel_Approval: 004 -- Next Approver User Name -- display Name:' || l_next_approver_user_name || ' -- ' || l_next_approver_disp_name;
        IF (g_po_wf_debug = 'Y') THEN
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
        END IF;
     --bug6843383 start
     IF (g_next_approvers(l_approver_index).orig_system = ame_util.perOrigSystem) then
          t_varname(23) := 'APPROVER_USER_NAME';
          t_varval(23) := g_next_approvers(l_approver_index).name;

          t_varname(24) := 'APPROVER_DISPLAY_NAME';
          t_varval(24) :=  g_next_approvers(l_approver_index).display_name;

    ELSE

        t_varname(23) := 'APPROVER_USER_NAME';
        t_varval(23) := l_next_approver_user_name;

        t_varname(24) := 'APPROVER_DISPLAY_NAME';
        t_varval(24) :=  l_next_approver_disp_name;
   END IF;
        /* Kick off the process */
        l_progress:= '30: start_wf_line_process: Kicking off StartProcess';
        IF (g_po_wf_debug = 'Y') THEN
            po_wf_debug_pkg.insert_debug(itemtype,itemkey,l_progress);
        END IF;

        t_varname(25) := 'AME_IS_FYI_APPROVER';
        if (g_next_approvers(l_approver_index).approver_category = ame_util.fyiApproverCategory) then
          t_varval(25) :='Y';
          l_has_fyi_app := 'Y';
          l_start_block_activity := 'N';
        else
          t_varval(25) :='N';

          if (l_has_fyi_app = 'N') then
            -- only start BLOCK if there are no FYI approvers
            l_start_block_activity := 'Y';
          end if;

        end if;

        t_varname(26) := 'VIEW_REQ_DTLS_URL';
        t_varval(26)  := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'VIEW_REQ_DTLS_URL');
       t_varval (26) := t_varval(26) || '&' || 'item_key=' || l_item_key;

        t_varname(27) := 'EDIT_REQ_URL';
        t_varval(27)  := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'EDIT_REQ_URL');
       t_varval (27) := t_varval(27) || '&' || 'item_key=' || l_item_key;

        t_varname(28) := 'RESUBMIT_REQ_URL';
        t_varval(28)  := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'RESUBMIT_REQ_URL');

        t_varname(28) := 'OPEN_FORM_COMMAND';
        t_varval(28)  := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'OPEN_FORM_COMMAND');

        -- Set the item attributes.
        Wf_Engine.SetItemAttrTextArray(itemtype, l_item_key,t_varname,t_varval);

        n_varname(1) := 'DOCUMENT_ID';
        n_varval(1)  := l_document_id;

        n_varname(2) := 'ORG_ID';
        n_varval(2)  := l_org_id;

        n_varname(3) := 'AME_APPROVER_ID';
        n_varval(3)  := g_next_approvers(l_approver_index).orig_system_id;

        n_varname(4) := 'APPROVER_EMPID';
        n_varval(4)  := l_next_approver_id;

        -- Set the approval group id as 1 for adhoc approvers
        n_varname(5) := 'APPROVAL_GROUP_ID';

        if (g_next_approvers(l_approver_index).api_insertion = 'Y') then
	  n_varval(5) := 1;
	else
          n_varval(5)  := g_next_approvers(l_approver_index).group_or_chain_id;
	end if;

        --Bug: 9877170   Setting Responsibility_id and Application_id
        n_varname(6) := 'RESPONSIBILITY_ID';
        n_varval(6)  := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'RESPONSIBILITY_ID');
        n_varname(7) := 'APPLICATION_ID';
        n_varval(7)  := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPLICATION_ID');
        l_progress := 'Launch_Parallel_Approval - setting responsibility_id:'||n_varval(6)||' and application_id:'||n_varval(7);
        IF (g_po_wf_debug = 'Y') THEN
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
        END IF;


       Wf_Engine.SetItemAttrNumberArray(itemtype, l_item_key,n_varname,n_varval);

        wf_engine.SetItemAttrDocument( itemtype => itemtype,
                                       itemkey  => l_item_key,
                                       aname    => 'ATTACHMENT',
                                       documentid   => ( wf_engine.GetItemAttrDocument( itemtype => itemtype,
                                                                                        itemkey  => itemkey,
                                                                                        aname    => 'ATTACHMENT')));


        l_progress := 'Launch_Parallel_Approval: 005 -- Launch Parallel Approval';
        IF (g_po_wf_debug = 'Y') THEN
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
        END IF;


        wf_engine.StartProcess( itemtype => itemtype,
                                itemkey  => l_item_key );

        l_approver_index := g_next_approvers.next(l_approver_index);
      end loop; -- end of for loop.

      if l_start_block_activity = 'Y' then
         resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
      else
         resultout:='COMPLETE' || ':' ||  '';
      end if;
      g_next_approvers.delete;

      RETURN;

  END IF; --run mode

exception
  when NO_DATA_FOUND then
    l_progress:= '50: start_wf_line_process: NO_DATA_FOUND -- EXCEPTION';
    l_doc_string := l_progress || PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('POR_AME_REQ_WF_PVT','Launch_Parallel_Approval-NO_DATA_FOUND Exception:',l_progress,sqlerrm);

    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_doc_string );
    END IF;
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_REQ_WF_PVT.GET_NEXT_APPROVER');
    raise;
  when others then
    l_progress:= '50: start_wf_line_process: IN EXCEPTION';
    l_doc_string := l_progress || PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('POR_AME_REQ_WF_PVT','Launch_Parallel_Approval-Unexpected Exception:',l_progress,sqlerrm);

    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_doc_string );
    END IF;

    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_REQ_WF_PVT.GET_NEXT_APPROVER');
    raise;

end Launch_Parallel_Approval;


--------------------------------------------------------------------------------
--Start of Comments
--Name: Process_Response_Internal
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler. This procedure is used to inform AME about the approvers response.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
procedure Process_Response_Internal( itemtype    in varchar2,
                                     itemkey     in varchar2,
                                     p_response  in varchar2 ) IS

l_progress                  VARCHAR2(500) := '000';
l_document_id number;
l_transaction_type PO_DOCUMENT_TYPES.AME_TRANSACTION_TYPE%TYPE;
l_current_approver ame_util.approverRecord2;
l_approver_posoition_id number;
l_approver_type varchar2(10);
l_error_code                   NUMBER;
l_error_message                ame_util.longestStringType;
l_parent_item_type             wf_items.parent_item_type%TYPE;
l_parent_item_key              wf_items.parent_item_key%TYPE;
l_approval_group_id            NUMBER; --Bug:17830532
begin

    l_progress := 'Process_Response_Internal: 001';
        IF (g_po_wf_debug = 'Y') THEN
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

    l_document_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                       itemkey  => itemkey,
                                                       aname    => 'DOCUMENT_ID');

    l_transaction_type := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'AME_TRANSACTION_TYPE');

    l_approver_type := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                       itemkey  => itemkey,
                                                       aname    => 'AME_APPROVER_TYPE');

    l_progress := 'Process_Response_Internal: 002 -- l_approver_type :' || l_approver_type ;
    IF (g_po_wf_debug = 'Y') THEN
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

    if (l_approver_type = ame_util.posOrigSystem) then
        l_current_approver.orig_system := ame_util.posOrigSystem;
    elsif (l_approver_type = ame_util.fndUserOrigSystem) then
        l_current_approver.orig_system := ame_util.fndUserOrigSystem;
    else
        l_current_approver.orig_system := ame_util.perOrigSystem;
         l_current_approver.name := po_wf_util_pkg.GetItemAttrText( itemtype   => itemType,
                                                                    itemkey    => itemkey,
                                                                    aname      => 'APPROVER_USER_NAME');
    end if;

    l_current_approver.orig_system_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                                           itemkey  => itemkey,
                                                                           aname    => 'AME_APPROVER_ID');

    l_progress := 'Process_Response_Internal: 003 -- l_current_approver.orig_system_id :' || l_current_approver.orig_system_id ;
    IF (g_po_wf_debug = 'Y') THEN
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

    if( p_response = 'APPROVE') then
        l_current_approver.approval_status := ame_util.approvedStatus;
    elsif( p_response = 'REJECT') then
        l_current_approver.approval_status := ame_util.rejectStatus;
    elsif( p_response = 'TIMEOUT') then
        l_current_approver.approval_status := ame_util.noResponseStatus;
    end if;

    l_progress := 'Process_Response_Internal: 004 -- p_response :' || p_response ;
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

    -- Get the name value for the approverRecord2.
    -- This is a mandatory field. If we do not pass this value to AME, we will get invalid parameter exception.
    -- bug# 4936145
    IF l_current_approver.name IS NULL THEN
         SELECT name into l_current_approver.name FROM
             ( SELECT name FROM wf_roles WHERE orig_system = l_current_approver.orig_system
                 and orig_system_id = l_current_approver.orig_system_id
                 order by start_date
              )
         WHERE rownum = 1;
    END IF;

    IF l_current_approver.name IS NULL THEN
         raise_application_error(-20001, 'Record Not Found in WF_ROLES for the orig_system_id :' ||
                                          l_current_approver.orig_system_id || ' -- orig_system :' || l_current_approver.orig_system );
    END IF;

    --Bug:17830532 pass approval_group_id value to AME
    l_approval_group_id:=po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                           itemkey  => itemkey,
                                                           aname    => 'APPROVAL_GROUP_ID');

    --Bug:18898656 pass approval_group_id=NULL for ad-hoc approver
    IF (l_approval_group_id = 1) THEN
    l_current_approver.group_or_chain_id := NULL;
    ELSE
    l_current_approver.group_or_chain_id := l_approval_group_id;
    END IF;

    l_progress := 'Process_Response_Internal: 005 -- l_approval_group_id :' || l_approval_group_id ;
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

    -- Update the Approval status with the response from the approver.
    ame_api2.updateApprovalStatus( applicationIdIn=>applicationId,
                                   transactionIdIn=>l_document_id,
                                   transactionTypeIn=>l_transaction_type,
                                   approverIn => l_current_approver);

  exception
  when others then
    l_error_code := SQLCODE;
    /* Get the sql code of the exception. IF code is -20001 then this is a valid AME exception .We need to
       get the exception text and store it in an attribute */
    IF l_error_code = -20001 THEN
       l_error_message := SQLERRM;

       SELECT parent_item_type, parent_item_key
          into l_parent_item_type, l_parent_item_key
       FROM wf_items
       WHERE item_type = itemtype and item_key = itemkey;

       po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                       itemkey  => l_parent_item_key,
	      			       aname    => 'AME_EXCEPTION',
				       avalue   => l_error_message );

    ELSE  -- If not valid excpetion , just raise the error
       raise;
    END IF;
end Process_Response_Internal;


--------------------------------------------------------------------------------
--Name: Process_Beat_By_First
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure handles the stopping of workflow and the updating of the
--    action history table in the case of approvers being beat by first
--    responder.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
procedure Process_Beat_By_First(  itemtype        in varchar2,
                                  itemkey         in varchar2,
                                  actid           in number,
                                  funcmode        in varchar2,
                                  resultout       out NOCOPY varchar2) IS

  l_progress                      VARCHAR2(500) := '000';
  l_parent_item_type              wf_items.parent_item_type%TYPE;
  l_parent_item_key               wf_items.parent_item_key%TYPE;

  l_child_approver_empid          NUMBER;
  l_child_approver_groupid        NUMBER;

  l_approver_group_id             NUMBER;
  l_req_header_id                 NUMBER;
  l_process_out                   VARCHAR2(10);
  approverList                    ame_util.approversTable2;
  ameTransactionType              po_document_types.ame_transaction_type%TYPE;
  l_response_action               VARCHAR2(20);
  l_note                          VARCHAR2(4000);
  l_person_id                     NUMBER;
  l_orig_system                   VARCHAR2(3);
  l_orig_system_id                NUMBER;
  l_first_approver_id             NUMBER;
  l_first_position_id             NUMBER;
  --l_beat_by_first_responder_appv   BOOLEAN :=FALSE;--bug 17046689

  l_preparer_user_name            fnd_user.user_name%TYPE;
  l_doc_string                    VARCHAR2(200);
  l_ame_exception                 ame_util.longestStringType;
  l_approver_response   varchar2(20);
  l_abort_flag boolean :=true;--Bug:19346509

  CURSOR l_child_wf (itemtype IN wf_items.parent_item_type%TYPE,itemkey IN wf_items.parent_item_key%TYPE) IS
        SELECT wfi.item_type, wfi.item_key,wfn.recipient_role, wfn.original_recipient
        FROM wf_items wfi,wf_item_activity_statuses wfias,wf_notifications wfn
        WHERE wfi.parent_item_key =itemkey
        and wfi.item_type=itemtype
        AND wfias.item_type=wfi.item_type
        AND wfias.item_key=wfi.item_key
        AND wfias.activity_status='NOTIFIED'
        AND wfias.notification_id IS NOT null
        AND wfias.notification_id = wfn.notification_id;
  l_child_wf_cur l_child_wf%ROWTYPE;

begin

    l_progress := 'Process_Beat_By_First: 001';
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

    SELECT parent_item_type, parent_item_key
        into l_parent_item_type, l_parent_item_key
    FROM wf_items
    WHERE item_type = itemtype and item_key = itemkey;

    /* Check if there we have encountered any ame exception.
       If the value of ame_exception is not null, then we have faced some exception.
       So just comlete the block activity and return */
    l_ame_exception := po_wf_util_pkg.GetItemAttrText( itemtype => l_parent_item_type,
                                                       itemkey  => l_parent_item_key,
                                                       aname    => 'AME_EXCEPTION' );

    IF l_ame_exception IS NOT NULL THEN
       wf_engine.CompleteActivity( itemtype => l_parent_item_type,
                                   itemkey  => l_parent_item_key,
                                   activity => 'BLOCK',
                                   result => null);
       resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
       RETURN;
    END IF;

    l_progress := 'Process_Beat_By_First: 002';
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

    l_approver_group_id := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                           itemkey  => itemkey,
                                                           aname    => 'APPROVAL_GROUP_ID');

    l_req_header_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'DOCUMENT_ID');

    l_approver_response := po_wf_util_pkg.GetItemAttrText(itemtype => itemtype,
                                                           itemkey  => itemkey,
                                                           aname   => 'APPROVER_RESPONSE');

    select first_position_id, first_approver_id
    into l_first_position_id, l_first_approver_id
    from po_requisition_headers_all
    where l_req_header_id = requisition_header_id;

    l_progress := 'Process_Beat_By_First: 003';
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

    if l_approver_response = 'APPROVED' then
      por_ame_approval_list.getAmeTransactionType(pReqHeaderId => l_req_header_id,
                                                         pAmeTransactionType => ameTransactionType);

      l_progress := 'Process_Beat_By_First: 004';
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
      END IF;

      -- Note for Approve
      l_note := fnd_message.get_string('ICX', 'ICX_POR_REQ_ALREADY_APPROVED');

      ame_api2.getAllApprovers7( applicationIdIn   => applicationId,
                                                transactionIdIn   => l_req_header_id,
                                                transactionTypeIn => ameTransactionType,
                                                approvalProcessCompleteYNOut => l_process_out,
                                                approversOut      => approverList
                                              );

      l_progress := 'Process_Beat_By_First: 005';
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
      END IF;

      -- Once we get the approvers list from AME, we iterate through the approvers list,
      -- to find out the current first authority approver.
      for i in 1 .. approverList.count loop

        IF (g_po_wf_debug = 'Y') THEN
          PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);

          PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, approverList(i).orig_system || to_char(i) || ' ' ||
                                                         approverList(i).orig_system_id);
          PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'authority' || ' ' || approverList(i).authority);
          PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'approval_status'|| ' ' || approverList(i).approval_status);
          PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'api_insertion'|| ' ' || approverList(i).api_insertion);
          PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'group_or_chain_id' || ' ' || approverList(i).group_or_chain_id);

        END IF;

        if( approverList(i).approval_status = ame_util.beatByFirstResponderStatus
            and approverList(i).api_insertion = ame_util.oamGenerated
            and approverList(i).group_or_chain_id = l_approver_group_id) then

            --l_beat_by_first_responder_appv:=TRUE;--bug 17046689
            l_orig_system     := approverList(i).orig_system;
            l_orig_system_id  := approverList(i).orig_system_id;

            if ( l_orig_system = ame_util.perOrigSystem) then

              -- Employee Supervisor Record.
              l_person_id := l_orig_system_id;

            elsif ( l_orig_system = ame_util.posOrigSystem) then

             -- Position Hierarchy Record.
             begin

             if (l_first_position_id is not NULL AND l_first_position_id = l_orig_system_id) then
                l_person_id := l_first_approver_id;

             else
              SELECT person_id into l_person_id FROM (
                       SELECT person.person_id FROM per_all_people_f person, per_all_assignments_f asg
                       WHERE asg.position_id = l_orig_system_id and trunc(sysdate) between person.effective_start_date
                       and nvl(person.effective_end_date, trunc(sysdate)) and person.person_id = asg.person_id
                       and asg.primary_flag = 'Y' and asg.assignment_type in ('E','C')
                       and ( person.current_employee_flag = 'Y' or person.current_npw_flag = 'Y' )
                       and asg.assignment_status_type_id not in (
                          SELECT assignment_status_type_id FROM per_assignment_status_types
                          WHERE per_system_status = 'TERM_ASSIGN'
                       ) and trunc(sysdate) between asg.effective_start_date and asg.effective_end_date order by person.last_name
                ) where rownum = 1;

            end if;

            exception
             WHEN NO_DATA_FOUND THEN
                 l_person_id := -1;
            end;

          elsif (l_orig_system = ame_util.fndUserOrigSystem) then

            -- FND User Record.
             SELECT employee_id into l_person_id
             FROM fnd_user
             WHERE user_id = l_orig_system_id
             and trunc(sysdate) between start_date and nvl(end_date, sysdate+1);

          end if;

          -- stop the workflow
          OPEN l_child_wf(l_parent_item_type, l_parent_item_key);

          LOOP
           FETCH l_child_wf INTO l_child_wf_cur;
           EXIT WHEN l_child_wf%NOTFOUND;

	   l_child_approver_empid := po_wf_util_pkg.GetItemAttrNumber( itemtype => l_child_wf_cur.item_type,
                                                                       itemkey  => l_child_wf_cur.item_key,
                                                                       aname    => 'APPROVER_EMPID');

           l_child_approver_groupid := po_wf_util_pkg.GetItemAttrNumber( itemtype => l_child_wf_cur.item_type,
                                                                         itemkey  => l_child_wf_cur.item_key,
                                                                         aname    => 'APPROVAL_GROUP_ID');

-- Bug 10043085 extra condition is added to check whether the notification is a delegated one.
           IF ((l_child_approver_empid = l_person_id OR (l_child_wf_cur.recipient_role <> l_child_wf_cur.original_recipient)) and
                l_child_approver_groupid = l_approver_group_id) THEN

                wf_engine.AbortProcess(l_child_wf_cur.item_type ,l_child_wf_cur.item_key);
                UpdateActionHistory(l_req_header_id, 'NO ACTION',
                            l_note, l_child_approver_empid);
                EXIT;

           END IF;

        END LOOP;

        CLOSE l_child_wf;

          -- update the action history table
          UpdateActionHistory(l_req_header_id, 'NO ACTION',
                            l_note, l_person_id);

      end if;
    end loop;
--Bug#19346509 Start:Abort pending notification if receipient isn't in the current approval list now
--bug 17046689 Start
--IF (l_beat_by_first_responder_appv) THEN
      --Bug15881165 Begin
      OPEN l_child_wf(l_parent_item_type, l_parent_item_key);
        LOOP
          FETCH l_child_wf INTO l_child_wf_cur;
          EXIT WHEN l_child_wf%NOTFOUND;

          -- Get the approver id as the person id to update the action history
          /*l_person_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => l_child_wf_cur.item_type,
                                                    itemkey  => l_child_wf_cur.item_key,
                                                    aname    => 'APPROVER_EMPID');*/
          l_abort_flag :=TRUE;

          l_child_approver_empid := po_wf_util_pkg.GetItemAttrNumber( itemtype => l_child_wf_cur.item_type,
                                                                       itemkey  => l_child_wf_cur.item_key,
                                                                       aname    => 'APPROVER_EMPID');

          l_child_approver_groupid := po_wf_util_pkg.GetItemAttrNumber( itemtype => l_child_wf_cur.item_type,
                                                                         itemkey  => l_child_wf_cur.item_key,
                                                                         aname    => 'APPROVAL_GROUP_ID');

          l_progress := 'Process_Beat_By_First: 0051,l_child_approver_empid:'||l_child_approver_empid||',l_child_approver_groupid:'||l_child_approver_groupid;
          IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
          END IF;

          FOR i in 1 .. approverList.COUNT LOOP

            IF (g_po_wf_debug = 'Y') THEN
              PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, approverList(i).orig_system || to_char(i) || ' ' ||
                                                         approverList(i).orig_system_id);
              PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'authority' || ' ' || approverList(i).authority);
              PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'approval_status'|| ' ' || approverList(i).approval_status);
              PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'api_insertion'|| ' ' || approverList(i).api_insertion);
              PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'group_or_chain_id' || ' ' || approverList(i).group_or_chain_id);

            END IF;

            l_orig_system     := approverList(i).orig_system;
            l_orig_system_id  := approverList(i).orig_system_id;

            if ( l_orig_system = ame_util.perOrigSystem) then

              -- Employee Supervisor Record.
              l_person_id := l_orig_system_id;

            elsif ( l_orig_system = ame_util.posOrigSystem) then

             -- Position Hierarchy Record.
             begin

             if (l_first_position_id is not NULL AND l_first_position_id = l_orig_system_id) then
                l_person_id := l_first_approver_id;

             else
              SELECT person_id into l_person_id FROM (
                       SELECT person.person_id FROM per_all_people_f person, per_all_assignments_f asg
                       WHERE asg.position_id = l_orig_system_id and trunc(sysdate) between person.effective_start_date
                       and nvl(person.effective_end_date, trunc(sysdate)) and person.person_id = asg.person_id
                       and asg.primary_flag = 'Y' and asg.assignment_type in ('E','C')
                       and ( person.current_employee_flag = 'Y' or person.current_npw_flag = 'Y' )
                       and asg.assignment_status_type_id not in (
                          SELECT assignment_status_type_id FROM per_assignment_status_types
                          WHERE per_system_status = 'TERM_ASSIGN'
                       ) and trunc(sysdate) between asg.effective_start_date and asg.effective_end_date order by person.last_name
                ) where rownum = 1;

            end if;

            exception
             WHEN NO_DATA_FOUND THEN
                 l_person_id := -1;
            end;

          elsif (l_orig_system = ame_util.fndUserOrigSystem) then

            -- FND User Record.
             SELECT employee_id into l_person_id
             FROM fnd_user
             WHERE user_id = l_orig_system_id
             and trunc(sysdate) between start_date and nvl(end_date, sysdate+1);

          end if;

          l_progress := 'Process_Beat_By_First: 0052,l_person_id:'||l_person_id;
          IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
          END IF;

          IF((l_child_approver_empid = l_person_id OR (l_child_wf_cur.recipient_role <> l_child_wf_cur.original_recipient)) AND
              l_child_approver_groupid = approverList(i).group_or_chain_id) THEN
            l_abort_flag :=FALSE;
            EXIT;
          END IF;

      END LOOP;

      IF(l_abort_flag) THEN

          wf_engine.AbortProcess(l_child_wf_cur.item_type ,l_child_wf_cur.item_key);

          -- update the action history table with the ICX_POR_REQ_ALREADY_APPROVED note
          UpdateActionHistory(l_req_header_id, 'NO ACTION',
                                l_note, l_child_approver_empid);

          l_progress := 'Process_Beat_By_First: 0053';
          IF (g_po_wf_debug = 'Y') THEN
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
          END IF;
       END IF;
     END LOOP;
   CLOSE l_child_wf;
      --Bug15881165 End
--END IF;
--bug 17046689 End
--Bug#19346509 End

    elsif (l_approver_response = 'REJECTED') then
     OPEN l_child_wf(l_parent_item_type, l_parent_item_key);

        LOOP
           FETCH l_child_wf INTO l_child_wf_cur;
           EXIT WHEN l_child_wf%NOTFOUND;

	   -- Get the approver id as the person id to update the action history
	   l_person_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => l_child_wf_cur.item_type,
                                                            itemkey  => l_child_wf_cur.item_key,
                                                            aname    => 'APPROVER_EMPID');

	   l_progress := 'Process_Beat_By_First: 006';
           IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
           END IF;

           -- Note for rejection
           l_note := fnd_message.get_string('ICX', 'ICX_POR_REQ_ALREADY_REJECTED');

	   wf_engine.AbortProcess(l_child_wf_cur.item_type ,l_child_wf_cur.item_key);

	   -- update the action history table
           UpdateActionHistory(l_req_header_id, 'NO ACTION',
                                        l_note, l_person_id);

	   l_progress := 'Process_Beat_By_First: 007';
           IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
           END IF;

        END LOOP;

     CLOSE l_child_wf;

   end if;

    l_progress := 'Process_Beat_By_First: 008';
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

    wf_engine.CompleteActivity( itemtype => l_parent_item_type,
                                itemkey  => l_parent_item_key,
                                activity => 'BLOCK',
                                result => null);

    resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
    RETURN;

exception
  when others then
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('POR_AME_REQ_WF_PVT','Process_Beat_By_First',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_REQ_WF_PVT.Process_Beat_By_First');
    RAISE;

end Process_Beat_By_First;


--------------------------------------------------------------------------------
--Start of Comments
--Name: Process_Response_Approve
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is the wrapper procedure of Process_Response_Internal()
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
procedure Process_Response_Approve( itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(500) := '000';
  l_parent_item_type wf_items.parent_item_type%TYPE;
  l_parent_item_key wf_items.parent_item_key%TYPE;

  l_child_approver_empid   number;
  l_child_approver_user_name   wf_users.name%TYPE;
  l_child_approver_display_name   wf_users.display_name%TYPE;

begin

    l_progress := 'Process_Response_Approve: 001';
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

    SELECT parent_item_type, parent_item_key
        into l_parent_item_type, l_parent_item_key
    FROM wf_items
    WHERE item_type = itemtype and item_key = itemkey;

    Process_Response_Internal(itemtype, itemkey, 'APPROVE');
    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'AME_SUB_APPROVAL_RESPONSE',
                                    avalue  => 'APPROVE');


    l_child_approver_empid :=     po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVER_EMPID');

    l_child_approver_user_name :=     po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVER_USER_NAME');

    l_child_approver_display_name :=  po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVER_DISPLAY_NAME');


    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'FORWARD_FROM_ID',
                                    avalue  => l_child_approver_empid );

    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'FORWARD_FROM_USER_NAME',
                                    avalue  =>  l_child_approver_user_name);

    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'FORWARD_FROM_DISP_NAME',
                                    avalue  =>  l_child_approver_display_name);

    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'APPROVER_EMPID',
                                    avalue  => l_child_approver_empid );

    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'APPROVER_USER_NAME',
                                    avalue  =>  l_child_approver_user_name );


     po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'APPROVER_DISPLAY_NAME',
                                    avalue  =>   l_child_approver_display_name );

    l_progress := 'Process_Response_Approve: 002 -- Completing the BLOCK activity for the APPROVED notification.';
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

    resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
    RETURN;
end Process_Response_Approve;

--------------------------------------------------------------------------------
--Start of Comments
--Name: Process_Response_Reject
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is the wrapper procedure of Process_Response_Internal()
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
procedure Process_Response_Reject( itemtype        in varchar2,
                                   itemkey         in varchar2,
                                   actid           in number,
                                   funcmode        in varchar2,
                                   resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(500) := '000';
  l_parent_item_type wf_items.parent_item_type%TYPE;
  l_parent_item_key wf_items.parent_item_key%TYPE;

  l_child_approver_empid   number;
  l_child_approver_user_name   wf_users.name%TYPE;
  l_child_approver_display_name   wf_users.display_name%TYPE;

begin

    l_progress := 'Process_Response_Reject: 001';
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

    Process_Response_Internal(itemtype, itemkey, 'REJECT');

    SELECT parent_item_type, parent_item_key
        into l_parent_item_type, l_parent_item_key
    FROM wf_items
    WHERE item_type = itemtype and item_key = itemkey;

    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'AME_SUB_APPROVAL_RESPONSE',
                                    avalue  => 'REJECT');

    l_child_approver_empid :=     po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVER_EMPID');

    l_child_approver_user_name :=     po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVER_USER_NAME');

    l_child_approver_display_name :=  po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVER_DISPLAY_NAME');


    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'FORWARD_FROM_ID',
                                    avalue  => l_child_approver_empid );


    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'FORWARD_FROM_USER_NAME',
                                    avalue  =>  l_child_approver_user_name);

    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'FORWARD_FROM_DISP_NAME',
                                    avalue  =>  l_child_approver_display_name);



    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'APPROVER_EMPID',
                                    avalue  => l_child_approver_empid );


    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'APPROVER_USER_NAME',
                                    avalue  =>  l_child_approver_user_name );


     po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'APPROVER_DISPLAY_NAME',
                                    avalue  =>   l_child_approver_display_name );


    l_progress := 'Process_Response_Reject: 002 -- Completing the BLOCK activity for the REJECTED notification.';
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

    resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
    RETURN;

end Process_Response_Reject;


--------------------------------------------------------------------------------
--Start of Comments
--Name: Process_Response_Timeout
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is the wrapper procedure of Process_Response_Internal()
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
procedure Process_Response_Timeout( itemtype        in varchar2,
                                   itemkey         in varchar2,
                                   actid           in number,
                                   funcmode        in varchar2,
                                   resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(500) := '000';
  l_parent_item_type wf_items.parent_item_type%TYPE;
  l_parent_item_key wf_items.parent_item_key%TYPE;

  l_child_approver_empid   number;
  l_child_approver_user_name   wf_users.name%TYPE;
  l_child_approver_display_name   wf_users.display_name%TYPE;


begin

    l_progress := 'Process_Response_Timeout: 001';
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

    Process_Response_Internal(itemtype, itemkey, 'TIMEOUT');

    SELECT parent_item_type, parent_item_key
        into l_parent_item_type, l_parent_item_key
    FROM wf_items
    WHERE item_type = itemtype and item_key = itemkey;

    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'AME_SUB_APPROVAL_RESPONSE',
                                    avalue   => 'TIMEOUT');

    l_child_approver_empid :=     po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVER_EMPID');

    l_child_approver_user_name :=     po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVER_USER_NAME');

    l_child_approver_display_name :=  po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVER_DISPLAY_NAME');


    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'FORWARD_FROM_ID',
                                    avalue  => l_child_approver_empid );


    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'FORWARD_FROM_USER_NAME',
                                    avalue  =>  l_child_approver_user_name);

    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'FORWARD_FROM_DISP_NAME',
                                    avalue  =>  l_child_approver_display_name);



    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'APPROVER_EMPID',
                                    avalue  => l_child_approver_empid );


    po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'APPROVER_USER_NAME',
                                    avalue  =>  l_child_approver_user_name );


     po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                    itemkey  => l_parent_item_key,
                                    aname    => 'APPROVER_DISPLAY_NAME',
                                    avalue  =>   l_child_approver_display_name );


    wf_engine.CompleteActivity (itemtype => l_parent_item_type,
                                itemkey  => l_parent_item_key,
                                activity => 'BLOCK',
                                result => null);

    l_progress := 'Process_Response_Timeout: 002 -- Completing the BLOCK activity for the REJECTED notification.';
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_progress);
    END IF;

    resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
    RETURN;

end Process_Response_Timeout;

--------------------------------------------------------------------------------
--Start of Comments
--Name: insertActionHistory
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is used to keep the history of each notification.
--  The inserted records will be displayed in Approval History page.
--Parameters:
--IN:
--  Requistion Header Id
--  Employee Id
--  Approver Group Id
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
procedure insertActionHistory( p_req_header_id in number,
                               p_employee_id in number,
                               p_approval_group_id in number)

is
pragma AUTONOMOUS_TRANSACTION;

  l_object_sub_type_code   PO_ACTION_HISTORY.OBJECT_SUB_TYPE_CODE%TYPE;
  l_sequence_num           PO_ACTION_HISTORY.SEQUENCE_NUM%TYPE;
  l_object_revision_num    PO_ACTION_HISTORY.OBJECT_REVISION_NUM%TYPE;
  l_approval_path_id       PO_ACTION_HISTORY.APPROVAL_PATH_ID%TYPE;
  l_request_id             PO_ACTION_HISTORY.REQUEST_ID%TYPE;
  l_program_application_id PO_ACTION_HISTORY.PROGRAM_APPLICATION_ID%TYPE;
  l_program_date           PO_ACTION_HISTORY.PROGRAM_DATE%TYPE;
  l_program_id             PO_ACTION_HISTORY.PROGRAM_ID%TYPE;
  l_progress                  VARCHAR2(100) := '000';

begin

  SELECT max(sequence_num)
  INTO l_sequence_num
  FROM PO_ACTION_HISTORY
  WHERE object_type_code = 'REQUISITION'
      AND object_id = p_req_header_id;

  SELECT object_sub_type_code,
          object_revision_num, approval_path_id, request_id,
          program_application_id, program_date, program_id
  INTO l_object_sub_type_code,
          l_object_revision_num, l_approval_path_id, l_request_id,
          l_program_application_id, l_program_date, l_program_id
  FROM PO_ACTION_HISTORY
  WHERE object_type_code = 'REQUISITION'
     AND object_id = p_req_header_id
     AND sequence_num = l_sequence_num;

       /* update po action history */
           po_forward_sv1.insert_action_history (
      	   p_req_header_id,
      	   'REQUISITION',
     	   l_object_sub_type_code,
     	   l_sequence_num + 1,
     	   NULL,
     	   NULL,
     	   p_employee_id,
     	   NULL,
     	   NULL,
		l_object_revision_num,
		NULL,                  /* offline_code */
		l_request_id,
		l_program_application_id,
		l_program_id,
		l_program_date,
     	   fnd_global.user_id,
     	   fnd_global.login_id,
           p_approval_group_id);

  commit;

end insertActionHistory;


--------------------------------------------------------------------------------
--Start of Comments
--Name: Insert_Action_History
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is the wrapper procedure of insertActionHistory()
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
procedure Insert_Action_History( itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(500) := '000';
  l_action                    VARCHAR2(30)  := 'APPROVE';
  l_next_approver_id             NUMBER:='';
  l_req_header_id                NUMBER:='';
  l_approval_group_id            NUMBER:='';

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;

BEGIN

    l_progress := 'Insert_Action_History: 001';
    IF (g_po_wf_debug = 'Y') THEN
         PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    IF (funcmode='RUN') THEN


        l_next_approver_id := po_wf_util_pkg.GetItemAttrNumber( itemtype=>itemtype,
                                                                itemkey=>itemkey,
                                                                aname=>'APPROVER_EMPID');


        l_req_header_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                             itemkey  => itemkey,
                                                             aname    => 'DOCUMENT_ID');

        l_approval_group_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                                 itemkey  => itemkey,
                                                                 aname    => 'APPROVAL_GROUP_ID');

        -- Set the multi-org context
        l_org_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'ORG_ID');

        IF l_org_id is NOT NULL THEN
            PO_MOAC_UTILS_PVT.set_org_context(l_org_id);
        END IF;

        l_progress := 'Insert_Action_History: 004 - Calling insertActionHistory.';
        insertActionHistory(l_req_header_id, l_next_approver_id, l_approval_group_id);

        l_progress := 'Insert_Action_History: 005 - Done with insertActionHistory.';
        IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
        END IF;

        /* Reset the FORWARD_TO_USERNAME_RESPONSE attribute */
        po_wf_util_pkg.SetItemAttrText( itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'FORWARD_TO_USERNAME_RESPONSE',
                                        avalue   => NULL);

        /* Reset the NOTE attribute */
        po_wf_util_pkg.SetItemAttrText( itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'NOTE',
                                        avalue   => NULL);

        resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
        return;

    END IF; -- run mode

    l_progress := 'Insert_Action_History: 999';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('POR_AME_REQ_WF_PVT','Insert_Action_History',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_REQ_WF_PVT.INSERT_ACTION_HISTORY');
    RAISE;
 END Insert_Action_History;


--------------------------------------------------------------------------------
--Start of Comments
--Name: Update_Action_History_Approve
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure updates the po_action_history table based on the approvers response.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
procedure Update_Action_History_Approve( itemtype        in varchar2,
                                         itemkey         in varchar2,
                                         actid           in number,
                                         funcmode        in varchar2,
                                         resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(500) := '000';
  l_action                    VARCHAR2(30)  := 'APPROVE';
  l_forward_to_id             NUMBER:='';
  l_document_id               NUMBER;
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_result                    BOOLEAN:=FALSE;
  l_note                      VARCHAR2(4000);

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;
  l_current_approver number;

BEGIN

    l_progress := 'Update_Action_History_Approve: 001';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    IF (funcmode='RUN') THEN

        l_current_approver := po_wf_util_pkg.GetItemAttrNumber( itemtype=>itemtype,
                                                                itemkey=>itemkey,
                                                                aname=>'APPROVER_EMPID');

        l_document_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                           itemkey  => itemkey,
                                                           aname    => 'DOCUMENT_ID');

        l_document_type := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                           itemkey  => itemkey,
                                                           aname    => 'DOCUMENT_TYPE');

        l_document_subtype := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                              itemkey  => itemkey,
                                                              aname    => 'DOCUMENT_SUBTYPE');

        l_note := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => 'NOTE');

        -- Set the multi-org context
        l_org_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'ORG_ID');

        IF l_org_id is NOT NULL THEN
            PO_MOAC_UTILS_PVT.set_org_context(l_org_id);
        END IF;

        l_progress := 'Update_Action_History_Approve: 002-'|| to_char(l_document_id)||'-'||
                           l_document_type||'-'||l_document_subtype;
        IF (g_po_wf_debug = 'Y') THEN
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
        END IF;

    /*    UpdateActionHistory(l_document_id, l_action,
                            l_note, l_current_approver); bug 10100356*/
       PO_APPROVAL_LIST_HISTORY_SV.Update_Action_History( itemtype=>itemtype,
                                          itemkey=>itemkey,
                                          x_action=>l_action,
                                         x_req_header_id=>l_document_id,
                                         x_last_approver=>l_result,
                                          x_note=>l_note);

	 po_wf_util_pkg.SetItemAttrText( itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'APPROVER_RESPONSE',
                                        avalue   => 'APPROVED' );

        resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';

    END IF; -- run mode

    l_progress := 'Update_Action_History_Approve: 003';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;


EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('POR_AME_REQ_WF_PVT','Update_Action_History_Approve',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_REQ_WF_PVT.UPDATE_ACTION_HISTORY_APPROVE');
    RAISE;

END Update_Action_History_Approve;


--------------------------------------------------------------------------------
--Start of Comments
--Name: Update_Action_History_Reject
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure updates the po_action_history table based on the approvers response.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
procedure Update_Action_History_Reject(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(100) := '000';
  l_action                    VARCHAR2(30)  := 'REJECT';
  l_forward_to_id             NUMBER:='';
  l_document_id               NUMBER;
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_result                    BOOLEAN:=FALSE;
  l_note                      VARCHAR2(4000);

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;
  l_current_approver number;

BEGIN

    l_progress := 'Update_Action_History_Reject: 001';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    IF (funcmode='RUN') THEN

        l_current_approver := po_wf_util_pkg.GetItemAttrNumber( itemtype=>itemtype,
                                                                itemkey=>itemkey,
                                                                aname=>'APPROVER_EMPID');

        l_document_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                           itemkey  => itemkey,
                                                           aname    => 'DOCUMENT_ID');

        l_document_type := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                           itemkey  => itemkey,
                                                           aname    => 'DOCUMENT_TYPE');

        l_document_subtype := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                              itemkey  => itemkey,
                                                              aname    => 'DOCUMENT_SUBTYPE');

        l_note := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => 'NOTE');

        -- Set the multi-org context
        l_org_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'ORG_ID');

        IF l_org_id is NOT NULL THEN
            PO_MOAC_UTILS_PVT.set_org_context(l_org_id);
        END IF;

        l_progress := 'Update_Action_History_Reject: 002-'|| to_char(l_document_id)||'-'||
                           l_document_type||'-'||l_document_subtype;
        IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
        END IF;

      /*  UpdateActionHistory(l_document_id, l_action,
                            l_note, l_current_approver);  bug 10100356*/
       PO_APPROVAL_LIST_HISTORY_SV.Update_Action_History( itemtype=>itemtype,
                                          itemkey=>itemkey,
                                          x_action=>l_action,
                                         x_req_header_id=>l_document_id,
                                         x_last_approver=>l_result,
                                          x_note=>l_note);

	 po_wf_util_pkg.SetItemAttrText( itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'APPROVER_RESPONSE',
                                        avalue   => 'REJECTED' );

        resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';

    END IF; -- run mode

    l_progress := 'Update_Action_History_Reject: 003';
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('POR_AME_REQ_WF_PVT','Update_Action_History_Reject',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_REQ_WF_PVT.Update_Action_History_Reject');
    RAISE;

END Update_Action_History_Reject;


--------------------------------------------------------------------------------
--Start of Comments
--Name: Update_Action_History_Timeout
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure updates the po_action_history table based on the approvers response.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
procedure Update_Action_History_Timeout(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(100) := '000';
  l_action                    VARCHAR2(30)  := 'NO ACTION';
  l_forward_to_id             NUMBER:='';
  l_document_id               NUMBER;
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_result                    BOOLEAN:=FALSE;
  l_note                      VARCHAR2(4000);

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;
  l_current_approver number;

BEGIN

    l_progress := 'Update_Action_History_Timeout: 001';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    IF (funcmode='RUN') THEN

        l_current_approver := po_wf_util_pkg.GetItemAttrNumber( itemtype=>itemtype,
                                                                itemkey=>itemkey,
                                                                aname=>'APPROVER_EMPID');

        l_document_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                           itemkey  => itemkey,
                                                           aname    => 'DOCUMENT_ID');

        l_document_type := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                           itemkey  => itemkey,
                                                           aname    => 'DOCUMENT_TYPE');

        l_document_subtype := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                              itemkey  => itemkey,
                                                              aname    => 'DOCUMENT_SUBTYPE');

        l_note := fnd_message.get_string('ICX', 'ICX_POR_NOTIF_TIMEOUT');

        -- Set the multi-org context
        l_org_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'ORG_ID');

        IF l_org_id is NOT NULL THEN
            PO_MOAC_UTILS_PVT.set_org_context(l_org_id);
        END IF;

        l_progress := 'Update_Action_History_Timeout: 002-'|| to_char(l_document_id)||'-'||
                           l_document_type||'-'||l_document_subtype;

        IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
        END IF;

    /*    UpdateActionHistory(l_document_id, l_action,
                            l_note, l_current_approver);  bug 10100356*/
       PO_APPROVAL_LIST_HISTORY_SV.Update_Action_History( itemtype=>itemtype,
                                          itemkey=>itemkey,
                                          x_action=>l_action,
                                         x_req_header_id=>l_document_id,
                                         x_last_approver=>l_result,
                                          x_note=>l_note);

        resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';

    END IF; -- run mode

    l_progress := 'Update_Action_History_Timeout: 003';
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('POR_AME_REQ_WF_PVT','Update_Action_History_Timeout',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_REQ_WF_PVT.Update_Action_History_Timeout');
    RAISE;

END Update_Action_History_Timeout;

--------------------------------------------------------------------------------
--Start of Comments
--Name: Update_Action_History_No_Action
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  If it is a first responder wins setup in ame, then once the first reponder wins, others will not be able to take decisions.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
procedure Update_Action_History_No_Act (itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    resultout       out NOCOPY varchar2    ) is
l_doc_header_id         NUMBER;
l_doc_type              VARCHAR2(14);
l_note                  VARCHAR2(4000);
x_progress              varchar2(500);
l_response_action       VARCHAR2(20);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

    x_progress := 'POR_AME_REQ_WF_PVT.Update_Action_History_No_Act: 01';

    if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
    end if;


    l_doc_header_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'DOCUMENT_ID');

    l_doc_type := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'DOCUMENT_TYPE');

    BEGIN

      l_response_action := po_wf_util_pkg.GetItemAttrText( itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'AME_SUB_APPROVAL_RESPONSE');
      IF( l_response_action = 'APPROVE' ) THEN
          l_note := fnd_message.get_string('ICX', 'ICX_POR_REQ_ALREADY_APPROVED');
      ELSIF ( l_response_action = 'REJECT' ) THEN
          l_note := fnd_message.get_string('ICX', 'ICX_POR_REQ_ALREADY_REJECTED');
      ELSE
          l_note := NULL;
      END IF;

    EXCEPTION
        WHEN OTHERS THEN
           l_note := NULL;
    END;


    x_progress := 'POR_AME_REQ_WF_PVT.Update_Action_History_No_Act: 02 - l_doc_header_id ' || l_doc_header_id || ' -- l_doc_type :' || l_doc_type ;

    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
    END IF;

    -- If the setup is first responder wins, then once the first approver responds, the others will not be able to take decisions.

    IF ( l_response_action is not null) THEN

         UpdateActionHistory(l_doc_header_id, 'NO ACTION', l_note, NULL);

    END IF;

    resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

    x_progress := 'POR_AME_REQ_WF_PVT.Update_Action_History_No_Act: 03';
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
    END IF;

EXCEPTION
WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('POR_AME_REQ_WF_PVT','Update_Action_History_No_Act',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_REQ_WF_PVT.Update_Action_History_No_Act');
    raise;
END Update_Action_History_No_Act;

--------------------------------------------------------------------------------
--Start of Comments
--Name: UpdateActionHistory
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure updates the po_action_history table based on the approvers response.
--Parameters:
--IN:
--  p_document_id : Requisition Header Id
--  p_action : Action
--  p_note : Notes
--  p_current_approver: Approver person Id
--OUT:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE UpdateActionHistory(p_document_id      NUMBER,
                              p_action           VARCHAR2,
                              p_note             VARCHAR2,
                              p_current_approver NUMBER) IS

pragma AUTONOMOUS_TRANSACTION;

BEGIN

  if (p_current_approver is not null) then

       UPDATE po_action_history
          SET action_code = p_action,
              note = p_note,
              action_date = sysdate
        WHERE object_id = p_document_id and
              employee_id = p_current_approver and
              action_code is null and
              object_type_code = 'REQUISITION'
              and rownum=1;

  else

       UPDATE po_action_history
          SET action_code = p_action,
              note = p_note,
              action_date = sysdate
        WHERE object_id = p_document_id and
              action_code is null and
              object_type_code = 'REQUISITION'
;
  end if;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE;

END UpdateActionHistory;

--------------------------------------------------------------------------------
--Start of Comments
--Name: IS_AME_EXCEPTION
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  It checks if the AME_EXCEPTION attribute is NULL or not.
--  If not NULL, it means there have been some AME exception encountered,
--  and it returns 'Y'.
--  Else it will return 'N'
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE IS_AME_EXCEPTION ( itemtype        in varchar2,
                                                              itemkey         in varchar2,
                                                              actid           in number,
                                                              funcmode        in varchar2,
                                                              resultout       out NOCOPY varchar2) IS
l_ame_exception              ame_util.longestStringType;
l_progress                   VARCHAR2(500) := '000';
l_doc_string                 VARCHAR2(200);
Begin
  IF (funcmode = 'RUN') THEN
    l_progress := 'IS_AME_EXCEPTION: 001';
    l_ame_exception :=PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'AME_EXCEPTION');

    if l_ame_exception IS NOT NULL then
      resultout := wf_engine.eng_completed || ':' ||'Y';
    else
      resultout := wf_engine.eng_completed || ':' ||'N';
    end if;
  END IF;
  EXCEPTION
    when others then
      l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
      wf_core.context('POR_AME_REQ_WF_PVT','IS_AME_EXCEPTION: Unexpected Exception:',l_progress,sqlerrm);
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_doc_string );
      END IF;
    raise;
End IS_AME_EXCEPTION;

--------------------------------------------------------------------------------
--Start of Comments
--Name: position_has_valid_approvers
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This function is used to check whether to launch the parallel approval process or not.
--  If a position does not have any users, then this function will return 'N', otherwise return 'Y'
--Parameters:
--IN:
--    documentId : ReqHeaderId
--    documentType : AME Transaction Type
--OUT:
--  'Y'  We can launch the parallel approval process.
--  'N'  Invalid approver. We can not launch the parallel approval process.
--  'NO_USERS'  No users for position. This AME record will be deleted. Go to the next approver record.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION position_has_valid_approvers( documentId NUMBER, documentType VARCHAR2 )RETURN VARCHAR2 is

l_next_approver_id number;
l_next_approver_name per_employees_current_x.full_name%TYPE;
l_position_has_valid_approvers VARCHAR2(10);
l_approver_index NUMBER;
l_option_value VARCHAR(20);

l_first_approver_id NUMBER;
l_first_position_id NUMBER;

BEGIN

        l_position_has_valid_approvers := 'Y';
        l_approver_index := g_next_approvers.first();

        select first_position_id, first_approver_id
        into l_first_position_id, l_first_approver_id
        from po_requisition_headers_all
        where documentId = requisition_header_id;

        while( l_approver_index is not null ) loop
             l_position_has_valid_approvers := 'Y';
             if (g_next_approvers(l_approver_index).orig_system = ame_util.posOrigSystem) then

                BEGIN

                if (l_first_position_id is not NULL AND l_first_position_id=g_next_approvers(l_approver_index).orig_system_id) then

                  l_next_approver_id := l_first_approver_id;

                  SELECT full_name
                  INTO l_next_approver_name
                  FROM per_all_people_f person
                  WHERE person_id = l_first_approver_id
                  --Bug#7207213#This query fetches multiple records so adding a filter
                  and trunc(sysdate) between person.effective_start_date and nvl(person.effective_end_date, trunc(sysdate));

                else

                        /* find the persond id from the position_id*/
                        SELECT person_id, full_name into l_next_approver_id,l_next_approver_name FROM (
                               SELECT person.person_id, person.full_name FROM per_all_people_f person, per_all_assignments_f asg
                               WHERE asg.position_id = g_next_approvers(l_approver_index).orig_system_id and trunc(sysdate) between person.effective_start_date
                               and nvl(person.effective_end_date, trunc(sysdate)) and person.person_id = asg.person_id
                               and asg.primary_flag = 'Y' and asg.assignment_type in ('E','C')
                               and ( person.current_employee_flag = 'Y' or person.current_npw_flag = 'Y' )
                               and asg.assignment_status_type_id not in (
                                  SELECT assignment_status_type_id FROM per_assignment_status_types
                                  WHERE per_system_status = 'TERM_ASSIGN'
                               ) and trunc(sysdate) between asg.effective_start_date and asg.effective_end_date order by person.last_name
                        ) where rownum = 1;

                end if;

             EXCEPTION
             WHEN NO_DATA_FOUND THEN

                 -- No users for this position. Check whether this is last position or not.
                 -- If this is last position then return the req to imcomplete status.
                 --   Otherwise set this approver record to 'Approved'
                 if( is_last_approver_record(documentId, documentType, g_next_approvers(l_approver_index)) = 'Y' )then
                     return 'N';
                 else

                     /*
                     g_next_approvers(l_approver_index).approval_status := ame_util.noResponseStatus;
                     -- Update the Approval status with the response from the approver.
                     ame_api2.updateApprovalStatus( applicationIdIn    =>applicationId,
                                                    transactionIdIn    =>documentId,
                                                    transactionTypeIn  =>documentType,
                                                    approverIn         => g_next_approvers(l_approver_index)
                                                  );
                     */
                    --- need to add a profile
                    -- bug 11849654
                     fnd_profile.put('POR_SYS_GENERATED_APPROVERS_SUPPRESS', 'Y');

                     ame_api3.suppressApprover( applicationIdIn   => applicationId,
                                                transactionIdIn   => documentId,
                                                approverIn        => g_next_approvers(l_approver_index),
                                                transactionTypeIn => documentType
                                              );

                      fnd_profile.put('POR_SYS_GENERATED_APPROVERS_SUPPRESS', 'N');

                     -- remove this approver from the global list.
                     g_next_approvers.delete(l_approver_index);
                     l_position_has_valid_approvers := 'NO_USERS';

                 end if;
             END;
             end if;
               l_approver_index := g_next_approvers.next(l_approver_index);
        end loop;
        return l_position_has_valid_approvers;

EXCEPTION
WHEN OTHERS THEN
        return 'N';
END position_has_valid_approvers;


--------------------------------------------------------------------------------
--Start of Comments
--Name: is_last_approver_record
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This function is used to check whether the approver/position is last in the approval chain or not
--  This function will be invoked only if a particular position does not have any associated users.
--  If this function returns 'Y', then the req will be put back in incomplete status.
--Parameters:
--IN:
--    documentId : ReqHeaderId
--    documentType : AME Transaction Type
--OUT:
--  'Y'  The approver/position is last in the approval chain.
--  'N'  The approver/position is not last in the approval chain
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
Function is_last_approver_record( documentId NUMBER, documentType VARCHAR2, approverRecord in ame_util.approverRecord2 ) RETURN VARCHAR2 is

l_is_last_approver_record VARCHAR2(1);
l_total_approver_count NUMBER;
l_current_approver_index NUMBER;
tmpApproverList   ame_util.approversTable2;
l_process_out     VARCHAR2(10);

BEGIN

        ame_api2.getAllApprovers7( applicationIdIn    =>applicationId,
                                   transactionIdIn    =>documentId,
                                   transactionTypeIn  =>documentType,
                                   approvalProcessCompleteYNOut => l_process_out,
                                   approversOut       =>tmpApproverList
                                 );

        l_total_approver_count := tmpApproverList.count;
        l_current_approver_index := 0;

        for i in 1 .. tmpApproverList.count loop

             l_current_approver_index := i;
             if ( tmpApproverList(i).name = approverRecord.name AND
                  tmpApproverList(i).orig_system = approverRecord.orig_system AND
                  tmpApproverList(i).orig_system_id = approverRecord.orig_system_id AND
                  tmpApproverList(i).authority = approverRecord.authority AND
                  tmpApproverList(i).group_or_chain_id = approverRecord.group_or_chain_id AND
                  tmpApproverList(i).action_type_id = approverRecord.action_type_id AND
                  tmpApproverList(i).item_id = approverRecord.item_id AND
                  tmpApproverList(i).item_class = approverRecord.item_class AND
                  tmpApproverList(i).approver_category = approverRecord.approver_category
                ) then

                EXIT;
             end if;
        end loop;

        if( l_current_approver_index = l_total_approver_count ) then
            return 'Y';
        else
            return 'N';
        end if;

EXCEPTION
WHEN OTHERS THEN
        return 'Y';
END is_last_approver_record;

END POR_AME_REQ_WF_PVT;

/
