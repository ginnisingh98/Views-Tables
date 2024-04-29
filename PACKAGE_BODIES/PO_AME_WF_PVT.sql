--------------------------------------------------------
--  DDL for Package Body PO_AME_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_AME_WF_PVT" AS
  -- $Header: PO_AME_WF_PVT.plb 120.0.12010000.23 2014/06/05 07:23:55 venuthot noship $

  -- Read the profile option that enables/disables the debug log
  g_po_wf_debug               VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
  g_next_approvers            ame_util.approversTable2;
  g_production_Indexes        ame_util.idList;
  g_variable_Names            ame_util.stringList;
  g_variable_Values           ame_util.stringList;
  g_debug_stmt                CONSTANT  BOOLEAN := PO_DEBUG.is_debug_stmt_on;
  g_pkg_name                  CONSTANT  VARCHAR2(20) := 'PO_AME_WF_PVT';
  g_module_prefix             CONSTANT  VARCHAR2(30) := 'po.plsql.' || g_pkg_name||'.';

FUNCTION position_has_valid_approvers(
           documentId        NUMBER,
           documentType      VARCHAR2)
RETURN VARCHAR2;

FUNCTION is_last_approver_record(
           documentId        NUMBER,
           documentType      VARCHAR2,
           approverRecord    IN ame_util.approverRecord2 )
RETURN VARCHAR2;

FUNCTION check_set_esigners(
           itemtype          IN VARCHAR2,
           itemkey           IN VARCHAR2 )
RETURN VARCHAR2;

PROCEDURE update_pending_signature (
           itemtype          IN VARCHAR2,
           itemkey           IN VARCHAR2,
           p_po_header_id    IN NUMBER);

PROCEDURE supress_existing_approvers(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2);

PROCEDURE update_auth_status_approve(
            p_document_id  IN  NUMBER,
            p_item_type      IN VARCHAR2,
            p_item_key       IN VARCHAR2);

--------------------------------------------------------------------------------
--Start of Comments
--Name: InsertActionHistoryPoAme
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This AUTONOMOUS procedure is used to create a new blank action history record
--Parameters:
--IN:
--  p_document_id
--  p_draft_id
--  p_document_type
--  p_document_subtype
--  p_revision_num
--  p_employee_id
--  p_approval_group_id
--  p_action
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE InsertActionHistoryPoAme(
    p_document_id       IN NUMBER,
    p_draft_id          IN VARCHAR2,
    p_document_type     IN VARCHAR2,
    p_document_subtype  IN VARCHAR2,
	p_revision_num      IN NUMBER,
    p_employee_id       IN NUMBER,
    p_approval_group_id IN NUMBER,
    p_action            IN VARCHAR2,
  	p_note              IN VARCHAR2 default null)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_sequence_num            PO_ACTION_HISTORY.SEQUENCE_NUM%TYPE;
BEGIN

   -----------------------------------------------------------------------
   -- SQL What: Get the document information from the latest action history record.
   -- SQL Why : Using this, we will fetch the other informaiton required for
   --           inserting the action history record.
   -----------------------------------------------------------------------
  SELECT MAX(sequence_num)
    INTO l_sequence_num
    FROM PO_ACTION_HISTORY
   WHERE object_type_code = p_document_type --'PO'
     AND object_sub_type_code = p_document_subtype --'STANDARD'
     AND object_id = p_document_id;

  po_forward_sv1.insert_action_history ( p_document_id,
                                         p_document_type,
                                         p_document_subtype,
                                         l_sequence_num + 1,
                                         p_action,
                                         sysdate,
                                         p_employee_id,
                                         NULL,
                                         p_note,
                                         p_revision_num,
                                         NULL,
                                         fnd_global.conc_request_id,
                                         fnd_global.prog_appl_id,
                                         fnd_global.conc_program_id,
                                         SYSDATE,
                                         fnd_global.user_id,
                                         fnd_global.login_id,
                                         p_approval_group_id);
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END InsertActionHistoryPoAme;

--------------------------------------------------------------------------------
--Start of Comments
--Name: UpdateActionHistoryPoAme
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
--  p_document_id
--  p_draft_id
--  p_document_type
--  p_document_subtype
--  p_action
--  p_note
--  p_current_approver
--OUT:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE UpdateActionHistoryPoAme(
    p_document_id           NUMBER,
    p_draft_id              NUMBER,
    p_document_type     IN  VARCHAR2,
    p_document_subtype  IN  VARCHAR2,
    p_action                VARCHAR2,
    p_note                  VARCHAR2,
    p_current_approver      NUMBER)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
   -----------------------------------------------------------------------
   -- Update the action history record with NULL action code with the
   -- appropriate action code.
   -- Compare the approver id if it is passed in. Else, update the record
   -- without the validation.
   -----------------------------------------------------------------------
  IF (p_current_approver IS NOT NULL) THEN

    UPDATE po_action_history
       SET action_code = p_action,
           note = p_note,
           action_date = sysdate
     WHERE object_id = p_document_id
       AND employee_id = p_current_approver
       AND action_code IS NULL
       AND object_type_code = p_document_type
       AND object_sub_type_code = p_document_subtype
       AND rownum =1;

  ELSE

     UPDATE po_action_history
        SET action_code = p_action, note = p_note, action_date = sysdate
      WHERE object_id = p_document_id
        AND action_code IS NULL
        AND object_type_code = p_document_type
        AND object_sub_type_code = p_document_subtype;

  END IF;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END UpdateActionHistoryPoAme;

----------------------------------------------------------------------------------
--Start of Comments
--Name: get_next_approvers
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
PROCEDURE get_next_approvers(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_document_id                   NUMBER;
  l_document_type                 PO_DOCUMENT_TYPES.DOCUMENT_TYPE_CODE%TYPE;
  l_document_subtype              PO_DOCUMENT_TYPES.DOCUMENT_SUBTYPE%TYPE;
  l_next_approver_id              NUMBER;
  l_next_approver_user_name       FND_USER.USER_NAME%TYPE;
  l_next_approver_disp_name       WF_USERS.DISPLAY_NAME%TYPE;
  l_orig_system                   WF_USERS.ORIG_SYSTEM%TYPE := ame_util.perOrigSystem;
  l_sequence_num                  NUMBER;
  l_approver_type                 VARCHAR2(30);
  l_doc_string                    VARCHAR2(200);
  l_preparer_user_name            FND_USER.USER_NAME%TYPE;
  l_org_id                        NUMBER;
  l_insertion_type                VARCHAR2(30);
  l_authority_type                VARCHAR2(30);
  l_transaction_type              PO_DOCUMENT_TYPES.AME_TRANSACTION_TYPE%TYPE;
  l_completeYNO                   VARCHAR2(1);
  l_position_has_valid_approvers  VARCHAR2(10);
  l_need_to_get_next_approver     BOOLEAN;
  l_ame_exception                 ame_util.longestStringType;
  l_transaction_id                NUMBER;
  l_next_approver                 ame_util.approverRecord;
  xitemIndexesOut                 ame_util.idList;
  xitemClassesOut                 ame_util.stringList;
  xitemIdsOut                     ame_util.stringList;
  xitemSourcesOut                 ame_util.longStringList;
  xtransVariableNamesOut          ame_util.stringList;
  xtransVariableValuesOut         ame_util.stringList;
  AME_GET_NEXT_APPRVR_EXCEPTION   EXCEPTION;
  l_progress                      VARCHAR2(3) := '000';
  l_api_name                      VARCHAR2(500) := 'get_next_approvers';
  l_log_head                      VARCHAR2(500) := g_module_prefix||l_api_name;
  l_esigner_flag                  VARCHAR2(1);
  l_esigner_exists                VARCHAR2(1);

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
  END IF;

  -- Logic :
  --  + Fetch all workflow related attributes.
  --  + In loop fetch next set of approvers. Using AME_API2.getNextApprovers3(..) will provide
  --    set of production rules (name/value pairs) being applied to currents set of approvers.
  --  + Check whether returned set of approvers have valid position or not by giving call to
  --    function position_has_valid_approvers or not.
  --  + When count of approvers reach to zero, check whether worklfow routing process is completed or
  --    not through OUT varaible l_completeYNO in AME_API2.getNextApprovers3(..)  */

  -- Check if there is any AME exception. If yes, then return 'invalid approver'
  l_ame_exception := po_wf_util_pkg.GetItemAttrText( aname => 'AME_EXCEPTION');

  IF l_ame_exception IS NOT NULL THEN
    resultout := wf_engine.eng_completed||':'||'INVALID_APPROVER';
    RETURN;
  END IF;

  l_document_type := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_TYPE');
  l_document_subtype := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_SUBTYPE');
  l_transaction_type := po_wf_util_pkg.GetItemAttrText( aname => 'AME_TRANSACTION_TYPE');
  l_transaction_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'AME_TRANSACTION_ID');
  l_document_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'DOCUMENT_ID');
  l_esigner_exists := po_wf_util_pkg.GetItemAttrText( aname => 'E_SIGNER_EXISTS');

  l_progress := '020';

  -- Get the next approver from AME.
  LOOP
    l_need_to_get_next_approver := FALSE;
    BEGIN
      l_progress := '030';
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Calling AME API with transaction id ' || l_transaction_id);
      END IF;

      ame_util2.detailedApprovalStatusFlagYN := ame_util.booleanTrue;
      AME_API2.getNextApprovers3 (
	       applicationIdIn              => applicationId,
        transactionTypeIn            => l_transaction_type,
        transactionIdIn              => l_transaction_id,
        flagApproversAsNotifiedIn    => ame_util.booleanTrue,
        approvalProcessCompleteYNOut => l_completeYNO,
        nextApproversOut             => g_next_approvers,
        itemIndexesOut               => xitemIndexesOut,
        itemClassesOut               => xitemClassesOut,
        itemIdsOut                   => xitemIdsOut,
        itemSourcesOut               => xitemSourcesOut,
        productionIndexesOut         => g_production_Indexes,
        variableNamesOut             => g_variable_Names,
        variableValuesOut            => g_variable_Values,
        transVariableNamesOut        => xtransVariableNamesOut,
        transVariableValuesOut       => xtransVariableValuesOut);

    EXCEPTION
      WHEN OTHERS THEN
        RAISE;
    END;
    l_progress := '040';
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||'.'||l_progress||':'||
                                                     ' g_next_approvers.count:'||g_next_approvers.count||
                                                     ' l_completeYNO:'||l_completeYNO);
    END IF;

    IF ( g_next_approvers.count > 0 ) THEN

      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' BEFORE ESIGNER EXISTS');
      END IF;

	   -- Check whether approver set is of signers or not. If yes, set the attribute and exit
      IF(l_esigner_exists = 'N') THEN
        l_esigner_flag := check_set_esigners(itemtype, itemkey);
		IF l_esigner_flag = 'Y' then
		  IF (g_po_wf_debug = 'Y') THEN
      	      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' BEFORE update_pending_signature');
      	  END IF;
		  update_pending_signature(itemtype, itemkey, l_document_id);
	      resultout:= wf_engine.eng_completed||':'||'VALID_ESIGNER';
		  RETURN;
		END IF; -- l_esigner_flag = 'Y'
	  END IF; -- l_esigner_exists = 'N'

      l_position_has_valid_approvers := position_has_valid_approvers(l_transaction_id, l_transaction_type);
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||'.'||l_progress||':'||
                                                       ' l_position_has_valid_approvers:'||l_position_has_valid_approvers||
                                                       ' g_next_approvers.count:'||g_next_approvers.count);
      END IF;

      IF( g_next_approvers.count = 0 AND 'NO_USERS' = l_position_has_valid_approvers ) THEN
        l_need_to_get_next_approver := TRUE;
      END IF;
    END IF; --g_next_approvers.count IF
    EXIT WHEN l_need_to_get_next_approver = FALSE;
  END LOOP; -- Get the next approver from AME

  -- Check the number of next approvers.
  -- If the count is greater than zero then verify whether position
  --  has valid approvers or not. Return INVALID_APPROVER and
  --  VALID_APPROVER depeding upon same.
  --  If the count is zero then verify the approval process is completed or not.

  IF ( g_next_approvers.count > 0 ) THEN
    IF( 'N' = l_position_has_valid_approvers ) THEN
      resultout := wf_engine.eng_completed||':'||'INVALID_APPROVER';
    ELSE
      resultout:= wf_engine.eng_completed||':'||'VALID_APPROVER';
    END IF; -- l_position_has_valid_approvers IF
  ELSE
    IF (l_completeYNO IN ('X','Y')) THEN
	  -- Check whether if signer existed. If yes, we need to end with Signer Complete process.
	  -- Else on normal approval process.
	  IF (l_esigner_exists = 'N') THEN
		resultout := wf_engine.eng_completed||':'||'NO_NEXT_APPROVER';
	  ELSE
	    resultout := wf_engine.eng_completed||':'||'NO_NEXT_APPROVER_ESIGNER';
	  END IF;
    ELSE
      resultout:= wf_engine.eng_completed||':'||'';
    END IF; -- l_completeYNO IF
  END IF;  --g_next_approvers.count > 0 IF

  RETURN;
EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context(g_pkg_name, l_api_name, l_progress, sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, l_progress, l_document_id);
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
    END IF;
    resultout:= wf_engine.eng_completed||':'||'INVALID_APPROVER';
    RETURN;
END get_next_approvers;

--------------------------------------------------------------------------------
--Start of Comments
--Name: is_ame_exception
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
PROCEDURE is_ame_exception(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_ame_exception   ame_util.longestStringType;
  l_progress        VARCHAR2(3) := '000';
  l_doc_string      VARCHAR2(200);
  l_api_name        VARCHAR2(500) := 'is_ame_exception';
  l_log_head        VARCHAR2(500) := g_module_prefix||l_api_name;
BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  l_ame_exception :=PO_WF_UTIL_PKG.GetItemAttrText (aname => 'AME_EXCEPTION');

  IF l_ame_exception IS NOT NULL THEN
    resultout := wf_engine.eng_completed || ':' ||'Y';
  ELSE
    resultout := wf_engine.eng_completed || ':' ||'N';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    wf_core.context(g_pkg_name, l_api_name, 'Unexpected Exception:', l_progress, SQLERRM);
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, l_log_head||':'||l_progress||':'||SQLERRM);
    END IF;
    RAISE;
END is_ame_exception;

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
--  This function is used to check whether to launch the parallel approval process or not.
--  If a position does not have any users, then this function will return 'N', otherwise return 'Y'
--Parameters:
--IN:
--    documentId : AME transaction id
--    documentType : AME Transaction Type
--OUT:
--  'Y'  We can launch the parallel approval process.
--  'N'  Invalid approver. We can not launch the parallel approval process.
--  'NO_USERS'  No users for position. This AME record will be deleted. Go to the next approver record.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION position_has_valid_approvers(
          documentId   NUMBER,
          documentType VARCHAR2)
RETURN VARCHAR2
IS
  l_next_approver_id              NUMBER;
  l_next_approver_name            per_employees_current_x.full_name%TYPE;
  l_position_has_valid_approvers  VARCHAR2(10);
  l_approver_index                NUMBER;
  l_first_approver_id             NUMBER := NULL;
  l_first_position_id             NUMBER := NULL;
BEGIN
  l_position_has_valid_approvers := 'Y';
  l_approver_index := g_next_approvers.first();

  WHILE ( l_approver_index IS NOT NULL ) LOOP

    l_position_has_valid_approvers := 'Y';
    IF (g_next_approvers(l_approver_index).orig_system = ame_util.posOrigSystem) THEN

      BEGIN
        -----------------------------------------------------------------------
		-- SQL What: Get the person assigned to position returned by AME.
        -- SQL Why : When AME returns position id, then using this sql we find
        --           one person assigned to this position and use this person
		--           as approver.
        -----------------------------------------------------------------------
         SELECT person_id, full_name
           INTO l_next_approver_id, l_next_approver_name
           FROM ( SELECT person.person_id, person.full_name
                    FROM per_all_people_f person,
                         per_all_assignments_f asg,
						 wf_users wu
                   WHERE asg.position_id = g_next_approvers(l_approver_index).orig_system_id
				     AND wu.orig_system     = ame_util.perorigsystem
                     AND wu.orig_system_id  = person.person_id
                     AND TRUNC(SYSDATE) BETWEEN person.effective_start_date AND NVL(person.effective_end_date, TRUNC( SYSDATE))
                     AND person.person_id = asg.person_id
                     AND asg.primary_flag = 'Y'
                     AND asg.assignment_type IN ( 'E', 'C' )
                     AND ( person.current_employee_flag = 'Y' OR person.current_npw_flag = 'Y' )
                     AND asg.assignment_status_type_id NOT IN
                                       ( SELECT assignment_status_type_id
                                           FROM per_assignment_status_types
                                          WHERE per_system_status = 'TERM_ASSIGN' )
                     AND TRUNC(SYSDATE) BETWEEN asg.effective_start_date AND asg.effective_end_date
                   ORDER BY person.last_name)
          WHERE ROWNUM = 1;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        -- No users for this position. Check whether this is last position or not.
        -- If this is last position then return 'N'.
        IF (is_last_approver_record(documentId, documentType, g_next_approvers(l_approver_index)) = 'Y') THEN
          RETURN 'N';
        ELSE
          -- As this is a blank record, remove it in AME and the global variable.
          -- Return 'NO_USERS'. We use PO_SYS_GENERATED_APPROVERS_SUPPRESS dynamic profile to
		  -- override AME mandatory attribute  ALLOW_DELETING_RULE_GENERATED_APPROVERS.
	      fnd_profile.put('PO_SYS_GENERATED_APPROVERS_SUPPRESS', 'Y');
          ame_api3.suppressApprover( applicationIdIn    => applicationId,
                                     transactionIdIn    => documentId,
                                     approverIn         => g_next_approvers(l_approver_index),
                                     transactionTypeIn  => documentType );
          fnd_profile.put('PO_SYS_GENERATED_APPROVERS_SUPPRESS', 'Y');
          g_next_approvers.delete(l_approver_index);
          l_position_has_valid_approvers := 'NO_USERS';
        END IF; -- is_last_approver_record IF
      END;
    END IF; --g_next_approvers(l_approver_index).orig_system = ame_util.posOrigSystem

    l_approver_index := g_next_approvers.next(l_approver_index);
  END LOOP; -- l_approver_index NOT NULL LOOP

  RETURN l_position_has_valid_approvers;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
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
--  This function is used to check whether the approver/position is last in the approval chain or not
--  This function will be invoked only if a particular position does not have any associated users.
--  If this function returns 'Y', then position_has_valid_approvers reruns 'N'
--Parameters:
--IN:
--    documentId : ReqHeaderId
--    documentType : AME Transaction Type
--    approverRecord : Current approver record
--OUT:
--  'Y'  The approver/position is last in the approval chain.
--  'N'  The approver/position is not last in the approval chain
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_last_approver_record(
    documentId        NUMBER,
    documentType      VARCHAR2,
    approverRecord IN ame_util.approverRecord2 )
RETURN VARCHAR2
IS
  l_is_last_approver_record VARCHAR2(1);
  l_total_approver_count    NUMBER;
  l_current_approver_index  NUMBER;
  tmpApproverList           ame_util.approversTable2;
  l_process_out             VARCHAR2(10);

BEGIN
  ame_api2.getAllApprovers7 ( applicationIdIn               => applicationId,
                              transactionIdIn               => documentId,
                              transactionTypeIn             => documentType,
                              approvalProcessCompleteYNOut  => l_process_out,
                              approversOut                  => tmpApproverList );

  l_total_approver_count := tmpApproverList.count;
  l_current_approver_index := 0;

  FOR i IN 1..tmpApproverList.count LOOP
    l_current_approver_index := i;
    IF (     tmpApproverList(i).name = approverRecord.name
         AND tmpApproverList(i).orig_system = approverRecord.orig_system
         AND tmpApproverList(i).orig_system_id = approverRecord.orig_system_id
         AND tmpApproverList(i).authority = approverRecord.authority
         AND tmpApproverList(i).group_or_chain_id = approverRecord.group_or_chain_id
         AND tmpApproverList(i).action_type_id = approverRecord.action_type_id
         AND tmpApproverList(i).item_id = approverRecord.item_id
         AND tmpApproverList(i).item_class = approverRecord.item_class
         AND tmpApproverList(i).approver_category = approverRecord.approver_category ) THEN
      EXIT;
    END IF;
  END LOOP;

  IF( l_current_approver_index = l_total_approver_count ) THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'Y';
END is_last_approver_record;

--------------------------------------------------------------------------------
--Start of Comments
--Name: launch_parallel_approval
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  + This procedure is used to send the notification for the approvers.
--  + Iterate through the list of approvers got from the API call
--    ame_api2.getNextApprovers3.
--  + Get the next approver name from the global variable g_next_approvers
--    and for each retrieved approver separate workflow process is kicked.
--  + They are marked as child of the current approval process (workflow
--    master detail co-ordination).
--  + For example, if there are 3 approvers, then 3 child process will be
--    created and each of them will be notified at the same time.
--  + If the next approver record is of Position Hierarchy type, then the
--    users associated to the position_id will be retrieved, will be
--    alphabetically sorted using last_name and to the first user
--    notification will be sent.
--  + To separate out APPROVER, REVIEWERS and SIGINERS added code to check
--    production rules (name/value pairs)and set approver_category
--    workflow attribute accordingly.
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

PROCEDURE launch_parallel_approval(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_progress                    VARCHAR2(3) DEFAULT '000';
  l_document_id                 NUMBER;
  l_item_key                    wf_items.item_key%TYPE;
  l_next_approver_id            NUMBER;
  l_next_approver_name          per_employees_current_x.full_name%TYPE;
  l_next_approver_user_name     VARCHAR2(100);
  l_next_approver_disp_name     VARCHAR2(240);
  l_orig_system                 VARCHAR2(48);
  l_org_id                      NUMBER;
  l_functional_currency         VARCHAR2(30);
  l_transaction_type            po_document_types.ame_transaction_type%TYPE;
  n_varname                     wf_engine.nametabtyp;
  n_varval                      wf_engine.numtabtyp;
  t_po_varname                  wf_engine.nametabtyp;
  t_po_varval                   wf_engine.texttabtyp;
  l_no_positionholder           EXCEPTION;
  l_preparer_user_name          fnd_user.user_name%TYPE;
  l_doc_string                  VARCHAR2(200);
  l_start_block_activity        VARCHAR2(1);
  l_has_fyi_app                 VARCHAR2(1);
  l_approver_index              NUMBER;
  l_first_position_id           NUMBER DEFAULT NULL;
  l_first_approver_id           NUMBER DEFAULT NULL;
  l_ame_transaction_id          NUMBER;
  l_document_type               po_document_types.document_type_code%TYPE;
  l_esigner_exists              VARCHAR2(1);
  l_api_name                    VARCHAR2(500) := 'launch_parallel_approval';
  l_log_head                    VARCHAR2(500) := g_module_prefix||l_api_name;
  l_owner_user_name             fnd_user.user_name%TYPE;
  l_userkey                     PO_HEADERS_ALL.SEGMENT1%TYPE;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
  END IF;

  --setting the bypass flag to N if document is getting forwarded
  po_wf_util_pkg.SetItemAttrText(aname => 'BYPASS_CHECKS_FLAG', avalue => 'N');

  --Fetch workflow attributes
  l_org_id := po_wf_util_pkg.GetItemAttrNumber(aname => 'ORG_ID');
  l_document_type := po_wf_util_pkg.GetItemAttrText (aname => 'DOCUMENT_TYPE');
  l_document_id := po_wf_util_pkg.GetItemAttrNumber (aname => 'DOCUMENT_ID');
  l_transaction_type := po_wf_util_pkg.GetItemAttrText (aname => 'AME_TRANSACTION_TYPE');
  l_ame_transaction_id := po_wf_util_pkg.GetItemAttrNumber (aname => 'AME_TRANSACTION_ID');
  l_esigner_exists := po_wf_util_pkg.GetItemAttrText (aname => 'E_SIGNER_EXISTS');

  l_start_block_activity := 'N';
  l_has_fyi_app := 'N';
  l_approver_index := g_next_approvers.first;

  --Loop through current set of approvers until l_approver_index is not null
  WHILE (l_approver_index IS NOT NULL) LOOP
    l_progress := '020';
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug (itemtype, itemkey, l_log_head||':'||l_progress
                                                       ||': g_next_approvers.name'
                                                       ||g_next_approvers(l_approver_index).name);
    END IF;

    --Fetch new item key
    SELECT TO_CHAR (l_document_id)||'-'||TO_CHAR (po_wf_itemkey_s.nextval)
      INTO l_item_key
      FROM sys.dual;

    --Create the parallel process
    wf_engine.CreateProcess ( itemtype => itemtype,
                              itemkey  => l_item_key,
                              process  => 'PARALLEL_APPROVAL_PROCESS');
    --Set parent attributes
    wf_engine.SetItemParent ( itemtype => itemtype,
                              itemkey  => l_item_key,
                              parent_itemtype => itemtype,
                              parent_itemkey  => itemkey,
                              parent_context  => NULL );

    --In array t_po_varname and t_po_varval, set all required workflow attributes
    t_po_varname (1)  := 'DOCUMENT_TYPE';
    t_po_varval (1)   := po_wf_util_pkg.GetItemAttrText (aname => 'DOCUMENT_TYPE');
    t_po_varname (2)  := 'DOCUMENT_SUBTYPE';
    t_po_varval (2)   := po_wf_util_pkg.GetItemAttrText (aname => 'DOCUMENT_SUBTYPE');
    t_po_varname (3)  := 'PREPARER_USER_NAME';
    t_po_varval (3)   := po_wf_util_pkg.GetItemAttrText (aname => 'PREPARER_USER_NAME');
    t_po_varname (4)  := 'PREPARER_DISPLAY_NAME';
    t_po_varval (4)   := po_wf_util_pkg.GetItemAttrText (aname => 'PREPARER_DISPLAY_NAME');
    t_po_varname (5)  := 'FUNCTIONAL_CURRENCY';
    t_po_varval (5)   := po_wf_util_pkg.GetItemAttrText (aname => 'FUNCTIONAL_CURRENCY');
    t_po_varname (6)  := 'TOTAL_AMOUNT_DSP';
    t_po_varval (6)   := po_wf_util_pkg.GetItemAttrText (aname => 'TOTAL_AMOUNT_DSP');
    t_po_varname (7)  := 'FORWARD_FROM_DISP_NAME';
    t_po_varval (7)   := po_wf_util_pkg.GetItemAttrText (aname => 'FORWARD_FROM_DISP_NAME');
    t_po_varname (8)  := 'FORWARD_FROM_USER_NAME';
    t_po_varval (8)   := po_wf_util_pkg.GetItemAttrText (aname => 'FORWARD_FROM_USER_NAME');
    t_po_varname (9)  := 'DOCUMENT_NUMBER';
    t_po_varval (9)   := po_wf_util_pkg.GetItemAttrText (aname => 'DOCUMENT_NUMBER');
    l_userkey         := t_po_varval (9);
    t_po_varname (10) := 'AME_TRANSACTION_TYPE';
    t_po_varval (10)  := po_wf_util_pkg.GetItemAttrText (aname => 'AME_TRANSACTION_TYPE');
    t_po_varname (11) := 'OPEN_FORM_COMMAND';
    t_po_varval (11)  := po_wf_util_pkg.GetItemAttrText (aname => 'OPEN_FORM_COMMAND');
    t_po_varname (12) := 'PO_DESCRIPTION';
    t_po_varval (12)  := po_wf_util_pkg.GetItemAttrText (aname => 'PO_DESCRIPTION');
    t_po_varname (13) := 'PO_AMOUNT_DSP';
    t_po_varval (13)  := po_wf_util_pkg.GetItemAttrText (aname => 'PO_AMOUNT_DSP');

    t_po_varname (14) := 'VIEW_DOC_URL';
    t_po_varval (14)  := po_wf_util_pkg.GetItemAttrText (aname => 'VIEW_DOC_URL');
				IF (t_po_varval (14) IS NOT NULL) THEN
        t_po_varval (14) := t_po_varval (14) || '&' || 'item_key=' || l_item_key;
    END IF;

    t_po_varname (15) := 'EDIT_DOC_URL';
    t_po_varval (15)  := po_wf_util_pkg.GetItemAttrText (aname => 'EDIT_DOC_URL');

    IF (t_po_varval (15) IS NOT NULL) THEN
        t_po_varval (15) := t_po_varval (15) || '&' || 'item_key=' || l_item_key;
    END IF;

    l_progress := '030';
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug (itemtype, itemkey, l_log_head||':'||l_progress
                                                       ||' g_next_approvers.orig_system:'
                                                       ||g_next_approvers (l_approver_index).orig_system);
    END IF;

    --Fetch next approver_id from the global list.
    -- If the approver is a PER role then use the same person id.
    -- If the approver is POS role, then find out the first user corresponding to that person.
    -- If it is an FND USER pick the employee_id corresponding to that FND USER
    IF (g_next_approvers (l_approver_index).orig_system = ame_util.perorigsystem) THEN

      l_next_approver_id := g_next_approvers (l_approver_index).orig_system_id;

    ELSIF (g_next_approvers (l_approver_index).orig_system = ame_util.posorigsystem) THEN

      BEGIN
	    -----------------------------------------------------------------------
	    -- SQL What: Get the person assigned to position returned by AME.
        -- SQL Why : When AME returns position id, then using this sql we find
        --           one person assigned to this position and use this person
		--           as approver.
        -----------------------------------------------------------------------
        SELECT person_id , full_name
          INTO l_next_approver_id, l_next_approver_name
          FROM ( SELECT person.person_id , person.full_name
                   FROM per_all_people_f person ,
                        per_all_assignments_f asg,
						wf_users wu
                  WHERE asg.position_id = g_next_approvers (l_approver_index).orig_system_id
				    AND wu.orig_system     = ame_util.perorigsystem
                    AND wu.orig_system_id  = person.person_id
                    AND TRUNC (sysdate) BETWEEN person.effective_start_date AND NVL (person.effective_end_date ,TRUNC (sysdate))
                    AND person.person_id = asg.person_id
                    AND asg.primary_flag = 'Y'
                    AND asg.assignment_type IN ('E','C')
                    AND ( person.current_employee_flag = 'Y' OR person.current_npw_flag = 'Y' )
                    AND asg.assignment_status_type_id NOT IN
                                         ( SELECT assignment_status_type_id
                                             FROM per_assignment_status_types
                                            WHERE per_system_status = 'TERM_ASSIGN'
                                          )
                    AND TRUNC (sysdate) BETWEEN asg.effective_start_date AND asg.effective_end_date
                  ORDER BY person.last_name )
         WHERE ROWNUM = 1;
      EXCEPTION
        WHEN no_data_found THEN
          RAISE;
      END;

    ELSIF (g_next_approvers (l_approver_index).orig_system = ame_util.fnduserorigsystem) THEN

      SELECT employee_id
        INTO l_next_approver_id
        FROM fnd_user
       WHERE user_id = g_next_approvers (l_approver_index).orig_system_id
         AND TRUNC (sysdate) BETWEEN start_date AND NVL (end_date ,sysdate + 1);

    END IF;

    l_progress := '040';

    t_po_varname (16) := 'AME_APPROVER_TYPE';
    t_po_varval (16)  := g_next_approvers (l_approver_index).orig_system;

    wf_directory.getusername (ame_util.perorigsystem, l_next_approver_id, l_next_approver_user_name, l_next_approver_disp_name);

    l_progress := '050';

    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_next_approver_user_name:'||l_next_approver_user_name);
    END IF;

    IF (g_next_approvers (l_approver_index).orig_system = ame_util.perorigsystem) THEN
      t_po_varname (17) := 'APPROVER_USER_NAME';
      t_po_varval (17)  := g_next_approvers (l_approver_index).name;
      t_po_varname (18) := 'APPROVER_DISPLAY_NAME';
      t_po_varval (18)  := g_next_approvers (l_approver_index).display_name;
    ELSE
      t_po_varname (17) := 'APPROVER_USER_NAME';
      t_po_varval (17)  := l_next_approver_user_name;
      t_po_varname (18) := 'APPROVER_DISPLAY_NAME';
      t_po_varval (18)  := l_next_approver_disp_name;
    END IF;

    -- set owner username
    l_owner_user_name :=  t_po_varval (17);

    t_po_varname (19) := 'IS_FYI_APPROVER';
    IF (g_next_approvers (l_approver_index).approver_category = ame_util.fyiapprovercategory) THEN
      t_po_varval (19) := 'Y';
      l_has_fyi_app    := 'Y';
      l_start_block_activity := 'N';
    ELSE
      t_po_varval (19) := 'N';
      IF (l_has_fyi_app = 'N') THEN
        l_start_block_activity := 'Y';
      END IF;
    END IF;

    t_po_varname (20) := 'DOCUMENT_TYPE_DISP';
    t_po_varval (20)  := po_wf_util_pkg.GetItemAttrText (aname => 'DOCUMENT_TYPE_DISP');
    t_po_varname (21) := 'REQUIRES_APPROVAL_MSG';
    t_po_varval (21)  := po_wf_util_pkg.GetItemAttrText (aname => 'REQUIRES_APPROVAL_MSG');
    t_po_varname (22) := 'WRONG_FORWARD_TO_MSG';
    t_po_varval (22)  := po_wf_util_pkg.GetItemAttrText (aname => 'WRONG_FORWARD_TO_MSG');
    t_po_varname (23) := 'OPERATING_UNIT_NAME';
    t_po_varval (23)  := po_wf_util_pkg.GetItemAttrText (aname => 'OPERATING_UNIT_NAME');
    t_po_varname (24) := 'NOTE';
    t_po_varval (24)  := po_wf_util_pkg.GetItemAttrText (aname => 'NOTE');
    t_po_varname (25) := 'PO_LINES_DETAILS';
    t_po_varval (25)  := po_wf_util_pkg.GetItemAttrText (aname => 'PO_LINES_DETAILS');
    t_po_varname (26) := 'DOCUMENT_SUBTYPE_DISP';
    t_po_varval (26)  := po_wf_util_pkg.GetItemAttrText (aname => 'DOCUMENT_SUBTYPE_DISP');
    t_po_varname (27) := 'ACTION_HISTORY';
    t_po_varval (27)  := po_wf_util_pkg.GetItemAttrText (aname => 'ACTION_HISTORY');
    t_po_varname (28) := 'PO_APPROVE_MSG';
    t_po_varval (28)  := po_wf_util_pkg.GetItemAttrText (aname => 'PO_APPROVE_MSG');
    t_po_varname (29) := 'SUPPLIER';
    t_po_varval (29)  := po_wf_util_pkg.GetItemAttrText (aname => 'SUPPLIER');
    t_po_varname (30) := 'SUPPLIER_SITE';
    t_po_varval (30)  := po_wf_util_pkg.GetItemAttrText (aname => 'SUPPLIER_SITE');
    t_po_varname (31) := 'AUTHORIZATION_STATUS';
    t_po_varval (31)  := po_wf_util_pkg.GetItemAttrText (aname => 'AUTHORIZATION_STATUS');
    t_po_varname (32) := 'WITH_TERMS';
    t_po_varval (32)  := po_wf_util_pkg.GetItemAttrText (aname => 'WITH_TERMS');
    t_po_varname (33) := 'LANGUAGE_CODE';
    t_po_varval (33)  := po_wf_util_pkg.GetItemAttrText (aname => 'LANGUAGE_CODE');

    l_progress := '060';
    --Adding code for setting attribute approver_category for on the basis of production rule.
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' g_production_Indexes.Count:'||g_production_Indexes.Count);
    END IF;

    --Determine the approver category
    t_po_varname (34) := 'APPROVER_CATEGORY';
    IF (g_production_Indexes.Count > 0) THEN
      FOR j IN 1..g_production_Indexes.Count LOOP

        IF (g_po_wf_debug = 'Y') THEN
          PO_WF_DEBUG_PKG.insert_debug (itemtype, itemkey, l_log_head||':'||l_progress||' j:' || j);
          PO_WF_DEBUG_PKG.insert_debug (itemtype, itemkey, l_log_head||':'||l_progress||' g_production_Indexes(j):' || g_production_Indexes(j));
          PO_WF_DEBUG_PKG.insert_debug (itemtype, itemkey, l_log_head||':'||l_progress||' l_approver_index:' || l_approver_index);
          PO_WF_DEBUG_PKG.insert_debug (itemtype, itemkey, l_log_head||':'||l_progress||' g_variable_Names(j):' || g_variable_Names(j));
          PO_WF_DEBUG_PKG.insert_debug (itemtype, itemkey, l_log_head||':'||l_progress||' g_variable_Values(j):' || g_variable_Values(j));
        END IF;

        IF g_production_Indexes(j) = l_approver_index THEN
          IF g_variable_Names(j) = 'REVIEWER' AND g_variable_Values(j)= 'YES' THEN
            t_po_varval (34) := 'REVIEWER';
          END IF;
        END IF;
      END LOOP; -- end of for loop for production rules
    ELSIF l_esigner_exists = 'Y' THEN
			PO_WF_DEBUG_PKG.insert_debug (itemtype, itemkey, l_log_head||':'||l_progress||' Esigner exists (into post approval grp)');
      t_po_varval (34) := 'ESIGNER';
    ELSE --g_production_Indexes.Count < 0
      PO_WF_DEBUG_PKG.insert_debug (itemtype, itemkey, l_log_head||':'||l_progress||' No Production Rules');
      t_po_varval (34) := 'APPROVER';
    END IF;

    l_progress := '070';
    t_po_varname (35) := 'BUYER_USER_NAME';
    t_po_varval (35)  := po_wf_util_pkg.GetItemAttrText (aname => 'BUYER_USER_NAME');
    t_po_varname (36) := 'NOTIFICATION_REGION';
    t_po_varval (36)  := po_wf_util_pkg.GetItemAttrText (aname => 'NOTIFICATION_REGION');
    t_po_varname (37) := 'REQUIRES_REVIEW_MSG';
    t_po_varval (37)  := po_wf_util_pkg.GetItemAttrText (aname => 'REQUIRES_REVIEW_MSG');
    t_po_varname (38) := 'PDF_ATTACHMENT_BUYER';
    t_po_varval (38)  := po_wf_util_pkg.GetItemAttrText (aname => 'PDF_ATTACHMENT_BUYER');
    t_po_varname (39) := 'PO_PDF_ERROR';
    t_po_varval (39)  := po_wf_util_pkg.GetItemAttrText (aname => 'PO_PDF_ERROR');
    t_po_varname (40) := '#HISTORY';
    t_po_varval (40)  := po_wf_util_pkg.GetItemAttrText (aname => '#HISTORY');
    t_po_varname (41) := 'REQUIRES_ESIGN_MSG';
    t_po_varval (41)  := po_wf_util_pkg.GetItemAttrText (aname => 'REQUIRES_ESIGN_MSG');

    --Start of code changes for the bug 17469843
    t_po_varname (42) := 'PO_OKC_ATTACHMENTS';
    t_po_varval (42)  := po_wf_util_pkg.GetItemAttrText (aname => 'PO_OKC_ATTACHMENTS');
    --End of code changes for the bug 17469843

    --Start of code changes for the mobile worklist ER
    t_po_varname (43) := 'TAX_AMOUNT_DSP';
    t_po_varval (43)  := po_wf_util_pkg.GetItemAttrText (aname => 'TAX_AMOUNT_DSP');
    --End of code changes for the mobile worklist ER

    --Set the item attributes from the array
    l_progress := '080';
    wf_engine.SetItemAttrTextarray (itemtype, l_item_key, t_po_varname, t_po_varval);

    l_progress := '090';
    n_varname (1) := 'DOCUMENT_ID';
    n_varval (1)  := l_document_id;
    n_varname (2) := 'ORG_ID';
    n_varval (2)  := l_org_id;
    n_varname (3) := 'AME_APPROVER_ID';
    n_varval (3)  := g_next_approvers (l_approver_index).orig_system_id;
    n_varname (4) := 'APPROVER_EMPID';
    n_varval (4)  := l_next_approver_id;
    n_varname (5) := 'APPROVAL_GROUP_ID';

    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug ( itemtype, itemkey, l_log_head||':'||l_progress
                                                        ||' g_next_approvers.api_insertion:'
                                                        ||g_next_approvers(l_approver_index).api_insertion);
    END IF;

    IF (g_next_approvers (l_approver_index).api_insertion = 'Y') THEN
      n_varval (5) := 1;
    ELSE
      n_varval (5) := g_next_approvers (l_approver_index).group_or_chain_id;
    END IF;

    n_varname (6) := 'RESPONSIBILITY_ID';
    n_varval (6)  := po_wf_util_pkg.GetItemAttrNumber (aname => 'RESPONSIBILITY_ID');
    n_varname (7) := 'APPLICATION_ID';
    n_varval (7)  := po_wf_util_pkg.GetItemAttrNumber (aname => 'APPLICATION_ID');

    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug (itemtype, itemkey, l_log_head||':'||l_progress
                                                       ||' RESP:'||n_varval(6)
                                                       ||' APPL_ID:'||n_varval(7));
    END IF;
    n_varname (8)  := 'AME_TRANSACTION_ID';
    n_varval (8)   := l_ame_transaction_id;
    n_varname (9)  := 'DRAFT_ID';
    n_varval (9)   := po_wf_util_pkg.GetItemAttrNumber (aname => 'DRAFT_ID');
    n_varname (10) := 'REVISION_NUMBER';
    n_varval (10)  := po_wf_util_pkg.GetItemAttrNumber (aname => 'REVISION_NUMBER');

    wf_engine.SetItemAttrNumberArray (itemtype, l_item_key, n_varname, n_varval);

    l_progress := '100';

    wf_engine.SetItemOwner(
      itemtype => itemtype,
      itemkey  => l_item_key,
      owner    => l_owner_user_name);

    wf_engine.SetItemUserKey(
      itemtype => itemtype,
      itemkey  => l_item_key,
      userkey  => l_userkey);

    --Kick off the process
    wf_engine.StartProcess (itemtype => itemtype ,itemkey => l_item_key);

    --Move to the next index
    l_approver_index := g_next_approvers.next (l_approver_index);

  END LOOP; --WHILE (l_approver_index IS NOT NULL)

  l_progress := '110';

  IF l_start_block_activity = 'Y' THEN
    resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED';
  ELSE
    resultout := wf_engine.eng_completed || ':' || '';
  END IF;

  -- After routing is done, delete approver list
  g_next_approvers.delete;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context(g_pkg_name, l_api_name, l_progress, sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, l_progress, l_document_id);
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
    END IF;
    RAISE;
END launch_parallel_approval;

--------------------------------------------------------------------------------
--Start of Comments
--Name: determine_approver_category
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This is uesd to determine approver_category.
--  Values can be 'APPROVER', 'ESIGNER' and 'REVIEWER'.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--  None
--End of Comments
---------------------------------------------------------------------------------
PROCEDURE determine_approver_category(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_approver_category VARCHAR2(100);
BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  --Logic is check for workflow attribute 'APPROVER_CATEGORY' and pass it ahead
  l_approver_category := po_wf_util_pkg.GetItemAttrText (aname => 'APPROVER_CATEGORY');
  resultout := wf_engine.eng_completed || ':' || l_approver_category;

END determine_approver_category;
--------------------------------------------------------------------------------
--Start of Comments
--Name: process_response_internal
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is used to inform AME about the approvers response.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE process_response_internal(
    itemtype   IN VARCHAR2,
    itemkey    IN VARCHAR2,
    p_response IN VARCHAR2 )
IS
  l_progress                VARCHAR2(3) := '000';
  l_document_id             NUMBER;
  l_transaction_type        po_document_types.ame_transaction_type%TYPE;
  l_current_approver        ame_util.approverRecord2;
  l_forwardee               ame_util.approverRecord2;
  l_approver_posoition_id   NUMBER;
  l_approver_type           VARCHAR2(10);
  l_parent_item_type        wf_items.parent_item_type%TYPE;
  l_parent_item_key         wf_items.parent_item_key%TYPE;
  l_document_type           po_document_types.document_type_code%TYPE;
  l_ame_transaction_id      NUMBER;
  l_error_message           ame_util.longestStringType;
  wf_role_not_found         EXCEPTION;
  l_api_name                VARCHAR2(500) := 'process_response_internal';
  l_log_head                VARCHAR2(500) := g_module_prefix||l_api_name;
BEGIN

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  -- Logic:
  --   Fetch all required workflow attributes
  --   Need l_forwardee approverRecord to be populated in case of FORWRAD and
  --     APPROVE AND FORWARD on the basis of current_approver_type.
  --     Also populate l_forwardee.name value or else AME throws exception
  --   Update current approval record attribute approval_status with proper
  --     status, so that same can be communicated to AME.
  --   Update AME about current status of approver through API ame_api2.updateApprovalStatus.

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
  END IF;

  l_document_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'DOCUMENT_ID');
  l_document_type := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_TYPE');
  l_ame_transaction_id := po_wf_util_pkg.GetItemAttrNumber(aname => 'AME_TRANSACTION_ID');
  l_transaction_type := po_wf_util_pkg.GetItemAttrText( aname => 'AME_TRANSACTION_TYPE');
  l_approver_type := po_wf_util_pkg.GetItemAttrText( aname => 'AME_APPROVER_TYPE');

  --Populate l_forwardee approverRecord on the basis of current approver_type
  IF (l_approver_type = ame_util.posOrigSystem) THEN
    l_current_approver.orig_system := ame_util.posOrigSystem;
  ELSIF (l_approver_type = ame_util.fndUserOrigSystem) THEN
    l_current_approver.orig_system := ame_util.fndUserOrigSystem;
  ELSE
    l_current_approver.orig_system := ame_util.perOrigSystem;
    l_current_approver.name := po_wf_util_pkg.GetItemAttrText( aname => 'APPROVER_USER_NAME');
  END IF;

  l_current_approver.orig_system_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'AME_APPROVER_ID');
  l_forwardee.orig_system := ame_util.perOrigSystem;
  l_forwardee.name := po_wf_util_pkg.GetItemAttrText( aname => 'FORWARD_TO_USERNAME_RESPONSE');

  BEGIN

     SELECT employee_id
      INTO    l_forwardee.orig_system_id
     FROM fnd_user
      WHERE user_name = l_forwardee.name;

  EXCEPTION

     WHEN OTHERS THEN
          l_forwardee.orig_system_id := NULL;
  END;

  l_progress := '020';

  --Update current approval record attribute approval_status with proper status
  --so that same can be communicated to AME.
  IF( p_response = 'APPROVE') THEN
    l_current_approver.approval_status := ame_util.approvedStatus;
  ELSIF( p_response = 'REJECT') THEN
    l_current_approver.approval_status := ame_util.rejectStatus;
  ELSIF( p_response = 'TIMEOUT') THEN
    l_current_approver.approval_status := ame_util.noResponseStatus;
  ELSIF( p_response = 'FORWARD') THEN
    l_current_approver.approval_status := ame_util.forwardStatus;
  ELSIF( p_response = 'APPROVE AND FORWARD') THEN
    l_current_approver.approval_status := ame_util.approveAndForwardStatus;
  ELSIF( p_response = 'EXCEPTION') THEN
    l_current_approver.approval_status := ame_util.exceptionStatus;
  END IF;

  l_progress := '030';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                   ||' p_response'||p_response
                                                   ||' l_forwardee.name:'||l_forwardee.name);
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                   ||' p_response'||p_response
                                                   ||' l_forwardee.orig_system:'||l_forwardee.orig_system);
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                   ||' l_forwardee.orig_system_id:'||l_forwardee.orig_system_id);
  END IF;

  -- Get the name value for the approverRecord2.
  -- This is a mandatory field. If we do not pass this value to AME, we will get invalid parameter exception.
  IF p_response IN ('FORWARD', 'APPROVE AND FORWARD') THEN

   IF l_forwardee.name IS NULL THEN
       SELECT name
         INTO l_forwardee.name
         FROM ( SELECT name
                  FROM wf_roles
                 WHERE orig_system = l_forwardee.orig_system
                   AND orig_system_id = l_forwardee.orig_system_id
                 ORDER BY start_date )
        WHERE ROWNUM = 1;
    END IF;

  END IF;

    IF l_current_approver.name IS NULL THEN
      SELECT name
        INTO l_current_approver.name
        FROM ( SELECT name
                 FROM wf_roles
                WHERE orig_system = l_current_approver.orig_system
                  AND orig_system_id = l_current_approver.orig_system_id
                ORDER BY start_date )
       WHERE ROWNUM = 1;
    END IF;


  l_progress := '040';
  IF l_current_approver.name IS NULL THEN
    RAISE wf_role_not_found;
  END IF;

    l_progress := '050';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                   ||' l_current_approver.name:'||l_current_approver.name);
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                   ||' l_current_approver.orig_system:'||l_current_approver.orig_system);
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                   ||' l_current_approver.orig_system_id:'||l_current_approver.orig_system_id);
  END IF;



  l_progress := '060';
  -- Update the Approval status with the response from the approver.
  IF p_response IN ('FORWARD', 'APPROVE AND FORWARD') THEN
    ame_api2.updateApprovalStatus(
	  applicationIdIn => applicationId,
      transactionIdIn => l_ame_transaction_id,
      transactionTypeIn => l_transaction_type,
      approverIn => l_current_approver,
      forwardeeIn => l_forwardee);
  ELSE
    ame_api2.updateApprovalStatus(
	  applicationIdIn => applicationId,
      transactionIdIn => l_ame_transaction_id,
      transactionTypeIn => l_transaction_type,
      approverIn => l_current_approver);
  END IF;

EXCEPTION
  WHEN wf_role_not_found THEN
    -- Exception is not passed on. This is expected to complete normally.
    l_error_message := SQLERRM;

    SELECT parent_item_type, parent_item_key
      INTO l_parent_item_type, l_parent_item_key
      FROM wf_items
     WHERE item_type = itemtype
       AND item_key = itemkey;

    po_wf_util_pkg.SetItemAttrText(
	  itemtype => l_parent_item_type,
      itemkey => l_parent_item_key,
      aname => 'AME_EXCEPTION',
      avalue => l_error_message );

  WHEN OTHERS THEN
    RAISE;
END process_response_internal;

--------------------------------------------------------------------------------
--Start of Comments
--Name: process_response_exception
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is the wrapper procedure of process_response_internal()
--  This procedure stmaps current approver workflow
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE process_response_exception(
    itemtype   IN        VARCHAR2,
    itemkey    IN        VARCHAR2,
    actid      IN        NUMBER,
    funcmode   IN        VARCHAR2,
    resultout OUT NOCOPY VARCHAR2 )
IS
  l_progress                      VARCHAR2(3) := '000';
  l_parent_item_type              wf_items.parent_item_type%TYPE;
  l_parent_item_key               wf_items.parent_item_key%TYPE;
  l_child_approver_empid          NUMBER;
  l_child_approver_user_name      wf_users.name%TYPE;
  l_child_approver_display_name   wf_users.display_name%TYPE;
  l_api_name                      VARCHAR2(500) := 'process_response_exception';
  l_log_head                      VARCHAR2(500) := g_module_prefix||l_api_name;
BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
  END IF;

  SELECT parent_item_type, parent_item_key
    INTO l_parent_item_type, l_parent_item_key
    FROM wf_items
   WHERE item_type = itemtype
     AND item_key = itemkey;

  -- Call process_response_internal with 'EXCEPTION'
  process_response_internal(itemtype, itemkey, 'EXCEPTION');
  po_wf_util_pkg.SetItemAttrText(aname => 'AME_SUB_APPROVAL_RESPONSE', avalue => 'EXCEPTION');
  resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED';
  RETURN;
END Process_Response_Exception;

--------------------------------------------------------------------------------
--Start of Comments
--Name: insert_action_history
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
PROCEDURE insert_action_history(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS

  l_progress            VARCHAR2(3) := '000';
  l_document_id         NUMBER;
  l_draft_id            NUMBER;
  l_revision_num        NUMBER;
  l_action              VARCHAR2(30) := NULL;
  l_next_approver_id    NUMBER :='';
  l_document_type       po_document_types.document_type_code%TYPE;
  l_document_subtype    po_document_types_all_b.document_subtype%TYPE;
  l_approval_group_id   NUMBER:='';
  l_doc_string          VARCHAR2(200);
  l_preparer_user_name  VARCHAR2(100);
  l_org_id              NUMBER;
  l_api_name            VARCHAR2(500) := 'insert_action_history';
  l_log_head            VARCHAR2(500) := g_module_prefix||l_api_name;
BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  -- Logic:
  --   + Fetch worklfow attributes required for inserting NULL record into action history.
  --     against current approver.
  --   + Call autonomous transaction InsertActionHistoryPoAme to insert record into action hsitory.
  --   + Reset attributes 'FORWARD_TO_USERNAME_RESPONSE' and 'NOTE'
  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, l_log_head||':'||l_progress);
  END IF;

  l_document_id       := po_wf_util_pkg.GetItemAttrNumber( aname => 'DOCUMENT_ID');
  l_draft_id          := po_wf_util_pkg.GetItemAttrText( aname => 'DRAFT_ID');
  l_next_approver_id  := po_wf_util_pkg.GetItemAttrNumber( aname=>'APPROVER_EMPID');
  l_document_type     := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_TYPE');
  l_document_subtype  := PO_WF_UTIL_PKG.GetItemAttrText ( aname => 'DOCUMENT_SUBTYPE');
  l_approval_group_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'APPROVAL_GROUP_ID');
  l_org_id            := po_wf_util_pkg.GetItemAttrNumber( aname => 'ORG_ID');
  l_revision_num      := po_wf_util_pkg.GetItemAttrNumber( aname => 'REVISION_NUMBER');

  IF l_org_id IS NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_org_id);
  END IF;

  l_progress := '020';
  InsertActionHistoryPoAme(
    p_document_id       => l_document_id,
    p_draft_id          => l_draft_id,
    p_document_type     => l_document_type,
    p_document_subtype  => l_document_subtype,
	p_revision_num      => l_revision_num,
    p_employee_id       => l_next_approver_id,
    p_approval_group_id => l_approval_group_id,
    p_action            => l_action );

  l_progress := '030';

  --Reset the FORWARD_TO_USERNAME_RESPONSE and NOTE attributes
  po_wf_util_pkg.SetItemAttrText( aname => 'FORWARD_TO_USERNAME_RESPONSE', avalue => NULL);
  po_wf_util_pkg.SetItemAttrText( aname => 'NOTE', avalue => NULL);
  resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED';

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context(g_pkg_name, l_api_name, l_progress, sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, l_progress, l_document_id);
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
    END IF;
    RAISE;
END insert_action_history;

--------------------------------------------------------------------------------
--Start of Comments
--Name: update_action_history_forward
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

PROCEDURE update_action_history_forward(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_progress           VARCHAR2(3) := '000';
  l_action             VARCHAR2(30) := 'FORWARD';
  l_forward_to_id      NUMBER :='';
  l_document_id        NUMBER;
  l_document_type      VARCHAR2(25):='';
  l_document_subtype   VARCHAR2(25):='';
  l_return_code        NUMBER;
  l_result             BOOLEAN:=FALSE;
  l_note               VARCHAR2(4000);
  l_doc_string         VARCHAR2(200);
  l_preparer_user_name VARCHAR2(100);
  l_org_id             NUMBER;
  l_current_approver   NUMBER;
  l_draft_id           NUMBER;
  l_api_name           VARCHAR2(500) := 'Update_Action_History_Forward';
  l_log_head           VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  -- Logic :
  -- + Fetch worklfow attributes required for updating NULL action to FORWARD action in
  --   action history against current approver.
  -- + Call autonomous transaction UpdateActionHistoryPoAme to update po_action_history.
  -- + Also set 'APPROVER_RESPONSE' workflow attribute with value 'FORWARD'

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
  END IF;

  l_current_approver := po_wf_util_pkg.GetItemAttrNumber( aname=>'APPROVER_EMPID');
  l_document_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'DOCUMENT_ID');
  l_document_type := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_TYPE');
  l_document_subtype := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_SUBTYPE');
  l_note := po_wf_util_pkg.GetItemAttrText( aname => 'NOTE');
  l_draft_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'DRAFT_ID');
  l_org_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'ORG_ID');

  IF l_org_id IS NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_org_id);
  END IF;

  l_progress := '020';
  UpdateActionHistoryPoAme (
    p_document_id      => l_document_id,
    p_draft_id         => l_draft_id,
    p_document_type    => l_document_type,
    p_document_subtype => l_document_subtype,
    p_action           => l_action,
    p_note             =>l_note,
    p_current_approver => l_current_approver);

  l_progress := '030';
  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_RESPONSE', avalue => 'FORWARD' );
  resultout := wf_engine.eng_completed||':'||'ACTIVITY_PERFORMED';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context(g_pkg_name, l_api_name, l_progress, sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, l_progress, l_document_id);
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Exception:'||sqlerrm);
    END IF;
    RAISE;
END Update_Action_History_Forward;

--------------------------------------------------------------------------------
--Start of Comments
--Name: update_action_history_approve
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
PROCEDURE update_action_history_approve(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_progress           VARCHAR2(3) := '000';
  l_action             VARCHAR2(30) := 'APPROVE';
  l_forward_to_id      NUMBER :='';
  l_document_id        NUMBER;
  l_document_type      VARCHAR2(25):='';
  l_document_subtype   VARCHAR2(25):='';
  l_return_code        NUMBER;
  l_result             BOOLEAN:=FALSE;
  l_note               VARCHAR2(4000);
  l_doc_string         VARCHAR2(200);
  l_preparer_user_name VARCHAR2(100);
  l_org_id             NUMBER;
  l_current_approver   NUMBER;
  l_draft_id           NUMBER;
  l_approver_category  VARCHAR2(100);
  l_api_name           VARCHAR2(500) := 'Update_Action_History_Approve';
  l_log_head           VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

    -- Logic :
  -- + Fetch worklfow attributes required for updating NULL action to APPROVE for approver,
  --   REVIEW ACCEPTED for Reviewer into action history, SIGNED for ESIGNER
  --   against current approver/reviewer/esigner.
  -- + Call autonomous transaction UpdateActionHistoryPoAme to update po_action_history.
  -- + Also set 'APPROVER_RESPONSE' workflow attribute with value 'APPROVE'

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
  END IF;

  l_current_approver := po_wf_util_pkg.GetItemAttrNumber( aname=>'APPROVER_EMPID');
  l_document_id      := po_wf_util_pkg.GetItemAttrNumber( aname => 'DOCUMENT_ID');
  l_document_type    := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_TYPE');
  l_document_subtype := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_SUBTYPE');
  l_note             := po_wf_util_pkg.GetItemAttrText( aname => 'NOTE');
  l_draft_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'DRAFT_ID');
  l_org_id           := po_wf_util_pkg.GetItemAttrNumber( aname => 'ORG_ID');

  IF l_org_id IS NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_org_id);
  END IF;

  --Change the l_action for REVIEWER
  l_approver_category := po_wf_util_pkg.GetItemAttrText ( aname => 'APPROVER_CATEGORY');
  IF l_approver_category = 'REVIEWER' THEN
    l_action := 'REVIEW ACCEPTED';
  ELSIF l_approver_category = 'ESIGNER' THEN
    l_action := 'SIGNED';
  ELSE
    l_action := 'APPROVE';
  END IF;

  l_progress := '020';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                   ||' Doc Info:'||TO_CHAR(l_document_id)||'-'
                                                   ||TO_CHAR(l_draft_id)||'-'||l_document_type
                                                   ||'-'||l_document_subtype);
  END IF;

  UpdateActionHistoryPoAme (
    p_document_id      => l_document_id,
    p_draft_id         => l_draft_id,
    p_document_type    => l_document_type,
    p_document_subtype => l_document_subtype,
    p_action           => l_action,
    p_note             =>l_note,
    p_current_approver => l_current_approver);

  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_RESPONSE', avalue => 'APPROVED' );
  resultout := wf_engine.eng_completed||':'||'ACTIVITY_PERFORMED';
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context(g_pkg_name, l_api_name, l_progress, sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, l_progress, l_document_id);
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
    END IF;
    RAISE;
END Update_Action_History_Approve;

--------------------------------------------------------------------------------
--Start of Comments
--Name: update_action_history_reject
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
PROCEDURE update_action_history_reject(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_progress           VARCHAR2(3) := '000';
  l_action             VARCHAR2(30) := 'REJECT';
  l_document_id        NUMBER;
  l_document_type      VARCHAR2(25):='';
  l_document_subtype   VARCHAR2(25):='';
  l_return_code        NUMBER;
  l_result             BOOLEAN:=FALSE;
  l_note               VARCHAR2(4000);
  l_doc_string         VARCHAR2(200);
  l_preparer_user_name VARCHAR2(100);
  l_org_id             NUMBER;
  l_current_approver   NUMBER;
  l_draft_id           NUMBER;
  l_approver_category  VARCHAR2(100);
  l_api_name           VARCHAR2(500) := 'Update_Action_History_Reject';
  l_log_head           VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
  END IF;

  -- Logic :
  -- + Fetch worklfow attributes required for updating NULL action to REJECT for approver,
  --   REVIEW REJECTED for Reviewer into action history, SIGNER REJECTED for ESIGNER
  --   against current approver/reviewer/esigner.
  -- + Call autonomous transaction UpdateActionHistoryPoAme to update po_action_history.
  -- + Also set 'APPROVER_RESPONSE' workflow attribute with value 'REJECTED'

  l_current_approver  := po_wf_util_pkg.GetItemAttrNumber( aname=>'APPROVER_EMPID');
  l_document_id       := po_wf_util_pkg.GetItemAttrNumber( aname => 'DOCUMENT_ID');
  l_document_type     := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_TYPE');
  l_document_subtype  := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_SUBTYPE');
  l_note              := po_wf_util_pkg.GetItemAttrText( aname => 'NOTE');
  l_draft_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'DRAFT_ID');
  l_org_id            := po_wf_util_pkg.GetItemAttrNumber( aname => 'ORG_ID');

  IF l_org_id IS NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_org_id);
  END IF;

  --Change the l_action for REVIEWER
  l_approver_category := po_wf_util_pkg.GetItemAttrText ( aname => 'APPROVER_CATEGORY');
  IF l_approver_category = 'REVIEWER' THEN
    l_action := 'REVIEW REJECTED';
  ELSIF l_approver_category = 'ESIGNER' THEN
    l_action := 'SIGNER REJECTED';
  ELSE
    l_action := 'REJECT';
  END IF;

  l_progress := '020';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                   ||' Doc Info:'||TO_CHAR(l_document_id)||'-'
                                                   ||TO_CHAR(l_draft_id)||'-'||l_document_type
                                                   ||'-'||l_document_subtype);
  END IF;

  UpdateActionHistoryPoAme (
    p_document_id      => l_document_id,
    p_draft_id         => l_draft_id,
    p_document_type    => l_document_type,
    p_document_subtype => l_document_subtype,
    p_action           => l_action,
    p_note             =>l_note,
    p_current_approver => l_current_approver);

  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_RESPONSE', avalue => 'REJECTED' );
  resultout := wf_engine.eng_completed||':'|| 'ACTIVITY_PERFORMED';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context(g_pkg_name, l_api_name, l_progress, sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, l_progress, l_document_id);
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
    END IF;
    RAISE;
END Update_Action_History_Reject;

--------------------------------------------------------------------------------
--Start of Comments
--Name: update_action_history_timeout
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
PROCEDURE update_action_history_timeout(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_progress           VARCHAR2(3) := '000';
  l_action             VARCHAR2(30) := 'TIMED OUT';
  l_document_id        NUMBER;
  l_document_type      VARCHAR2(25):='';
  l_document_subtype   VARCHAR2(25):='';
  l_return_code        NUMBER;
  l_result             BOOLEAN:=FALSE;
  l_note               VARCHAR2(4000);
  l_doc_string         VARCHAR2(200);
  l_preparer_user_name VARCHAR2(100);
  l_org_id             NUMBER;
  l_current_approver   NUMBER;
  l_draft_id           NUMBER;
  l_api_name           VARCHAR2(500) := 'Update_Action_History_Timeout';
  l_log_head           VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
  END IF;

  -- Logic:
  -- + Fetch worklfow attributes required for updating NULL action to NO ACTION action into action history
  --   against current approver.
  -- + Call autonomous transaction UpdateActionHistoryPoAme to update po_action_history.

  l_current_approver  := po_wf_util_pkg.GetItemAttrNumber( aname=>'APPROVER_EMPID');
  l_document_id       := po_wf_util_pkg.GetItemAttrNumber( aname => 'DOCUMENT_ID');
  l_draft_id          := po_wf_util_pkg.GetItemAttrNumber( aname => 'DRAFT_ID');
  l_document_type     := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_TYPE');
  l_document_subtype  := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_SUBTYPE');
  l_note              := fnd_message.get_string('ICX', 'ICX_POR_NOTIF_TIMEOUT');
  l_org_id            := po_wf_util_pkg.GetItemAttrNumber( aname => 'ORG_ID');
  IF l_org_id IS NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_org_id);
  END IF;

  l_progress := '020';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                   ||' Doc Info:'||TO_CHAR(l_document_id)
                                                   ||'-'||TO_CHAR(l_draft_id)||'-'
                                                   ||l_document_type||'-'||l_document_subtype);
  END IF;

  UpdateActionHistoryPoAme (
    p_document_id      => l_document_id,
    p_draft_id         => l_draft_id,
    p_document_type    => l_document_type,
    p_document_subtype => l_document_subtype,
    p_action           => l_action,
    p_note             =>l_note,
    p_current_approver => l_current_approver);

  resultout := wf_engine.eng_completed||':'||'ACTIVITY_PERFORMED';
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context(g_pkg_name, l_api_name, l_progress, sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, l_progress, l_document_id);
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
    END IF;
    RAISE;
END Update_Action_History_Timeout;

--------------------------------------------------------------------------------
--Start of Comments
--Name: update_action_history_timeout
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
PROCEDURE update_action_history_app_fwd(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_progress           VARCHAR2(3) := '000';
  l_action             VARCHAR2(30) := 'APPROVE AND FORWARD';
  l_document_id        NUMBER;
  l_document_type      VARCHAR2(25):='';
  l_document_subtype   VARCHAR2(25):='';
  l_return_code        NUMBER;
  l_result             BOOLEAN:=FALSE;
  l_note               VARCHAR2(4000);
  l_doc_string         VARCHAR2(200);
  l_preparer_user_name VARCHAR2(100);
  l_org_id             NUMBER;
  l_current_approver   NUMBER;
  l_draft_id           NUMBER;
  l_api_name           VARCHAR2(500) := 'update_action_history_app_fwd';
  l_log_head           VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
  END IF;

  -- Logic:
  -- + Fetch worklfow attributes required for updating NULL action to NO ACTION action into action history
  --   against current approver.
  -- + Call autonomous transaction UpdateActionHistoryPoAme to update po_action_history.

  l_current_approver  := po_wf_util_pkg.GetItemAttrNumber( aname=>'APPROVER_EMPID');
  l_document_id       := po_wf_util_pkg.GetItemAttrNumber( aname => 'DOCUMENT_ID');
  l_draft_id          := po_wf_util_pkg.GetItemAttrNumber( aname => 'DRAFT_ID');
  l_document_type     := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_TYPE');
  l_document_subtype  := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_SUBTYPE');
  l_note              := fnd_message.get_string('ICX', 'ICX_POR_NOTIF_TIMEOUT');
  l_org_id            := po_wf_util_pkg.GetItemAttrNumber( aname => 'ORG_ID');
  IF l_org_id IS NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_org_id);
  END IF;

  l_progress := '020';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                   ||' Doc Info:'||TO_CHAR(l_document_id)
                                                   ||'-'||TO_CHAR(l_draft_id)||'-'
                                                   ||l_document_type||'-'||l_document_subtype);
  END IF;

  UpdateActionHistoryPoAme (
    p_document_id      => l_document_id,
    p_draft_id         => l_draft_id,
    p_document_type    => l_document_type,
    p_document_subtype => l_document_subtype,
    p_action           => l_action,
    p_note             => l_note,
    p_current_approver => l_current_approver);

  resultout := wf_engine.eng_completed||':'||'ACTIVITY_PERFORMED';
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context(g_pkg_name, l_api_name, l_progress, sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, l_progress, l_document_id);
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
    END IF;
    RAISE;
END update_action_history_app_fwd;

--------------------------------------------------------------------------------
--Start of Comments
--Name: Process_Response_App_Forward
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is the wrapper procedure of process_response_internal()
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE process_response_app_forward(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_progress                      VARCHAR2(3) := '000';
  l_parent_item_type              wf_items.parent_item_type%TYPE;
  l_parent_item_key               wf_items.parent_item_key%TYPE;
  l_child_approver_empid          NUMBER;
  l_child_approver_user_name      wf_users.name%TYPE;
  l_child_approver_display_name   wf_users.display_name%TYPE;
  l_api_name                      VARCHAR2(500) := 'process_response_app_forward';
  l_log_head                      VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
  END IF;

  -- Logic :
  --   + Get parent_itemp_type and parent_item_key.
  --   + Call process_response_internal with action 'APPROVE and FORWARD'. It will update ame with status and forwadee record.
  --   + Set workflow attribute AME_SUB_APPROVAL_RESPONSE to APPROVE AND FORWARD' of parent.
  --   + Fetch required current approver related workflow attributes as child attributes.
  --   + Populate parent workflow attributes FORWARD_FROM_ID, FORWARD_FROM_USER_NAME, FORWARD_FROM_DISP_NAME
  --     APPROVER_EMPID, APPROVER_USER_NAME, APPROVER_DISPLAY_NAME with child approver attributes.

  SELECT parent_item_type, parent_item_key
    INTO l_parent_item_type, l_parent_item_key
    FROM wf_items
   WHERE item_type = itemtype
     AND item_key = itemkey;

  l_progress := '020';
  process_response_internal(itemtype, itemkey, 'APPROVE AND FORWARD');
  l_progress := '030';

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Returned from process_response_internal');
  END IF;

  l_child_approver_empid          := po_wf_util_pkg.GetItemAttrNumber( aname => 'APPROVER_EMPID');
  l_child_approver_user_name      := po_wf_util_pkg.GetItemAttrText( aname => 'APPROVER_USER_NAME');
  l_child_approver_display_name   := po_wf_util_pkg.GetItemAttrText( aname => 'APPROVER_DISPLAY_NAME');

  PO_WF_UTIL_PKG.G_ITEM_TYPE := l_parent_item_type;
  PO_WF_UTIL_PKG.G_ITEM_KEY := l_parent_item_key;
  po_wf_util_pkg.SetItemAttrText( aname => 'AME_SUB_APPROVAL_RESPONSE', avalue => 'APPROVE_AND_FORWARD');
  po_wf_util_pkg.SetItemAttrText( aname => 'FORWARD_FROM_ID', avalue => l_child_approver_empid );
  po_wf_util_pkg.SetItemAttrText( aname => 'FORWARD_FROM_USER_NAME', avalue => l_child_approver_user_name);
  po_wf_util_pkg.SetItemAttrText( aname => 'FORWARD_FROM_DISP_NAME', avalue => l_child_approver_display_name);
  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_EMPID', avalue => l_child_approver_empid );
  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_USER_NAME', avalue => l_child_approver_user_name );
  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_DISPLAY_NAME', avalue => l_child_approver_display_name );

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Process_Response_App_Forward completed');
  END IF;

  resultout := wf_engine.eng_completed||':'||'ACTIVITY_PERFORMED';
  RETURN;

END Process_Response_App_Forward;

--------------------------------------------------------------------------------
--Start of Comments
--Name: process_response_approve
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is the wrapper procedure of process_response_internal()
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE process_response_approve(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_progress                      VARCHAR2(3) := '000';
  l_parent_item_type              wf_items.parent_item_type%TYPE;
  l_parent_item_key               wf_items.parent_item_key%TYPE;
  l_child_approver_empid          NUMBER;
  l_child_approver_user_name      wf_users.name%TYPE;
  l_child_approver_display_name   wf_users.display_name%TYPE;
  l_api_name                      VARCHAR2(500) := 'process_response_approve';
  l_log_head                      VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
  END IF;

  -- Logic :
  --    + Get parent_itemp_type and parent_item_key.
  --    + Call process_response_internal with action 'APPROVE'. It will update ame with status and forwadee record.
  --    + Set workflow attribute AME_SUB_APPROVAL_RESPONSE to APPROVE' of parent.
  --    + Fetch required current approver related workflow attributes as child attributes.
  --    + Populate parent workflow attributes FORWARD_FROM_ID, FORWARD_FROM_USER_NAME, FORWARD_FROM_DISP_NAME
  --      APPROVER_EMPID, APPROVER_USER_NAME, APPROVER_DISPLAY_NAME with child approver attributes.

  SELECT parent_item_type, parent_item_key
    INTO l_parent_item_type, l_parent_item_key
    FROM wf_items
   WHERE item_type = itemtype
     AND item_key = itemkey;

  l_progress := '020';
  process_response_internal(itemtype, itemkey, 'APPROVE');
  l_progress := '030';

  l_child_approver_empid        := po_wf_util_pkg.GetItemAttrNumber( aname => 'APPROVER_EMPID');
  l_child_approver_user_name    := po_wf_util_pkg.GetItemAttrText( aname => 'APPROVER_USER_NAME');
  l_child_approver_display_name := po_wf_util_pkg.GetItemAttrText( aname => 'APPROVER_DISPLAY_NAME');

  PO_WF_UTIL_PKG.G_ITEM_TYPE := l_parent_item_type;
  PO_WF_UTIL_PKG.G_ITEM_KEY := l_parent_item_key;
  po_wf_util_pkg.SetItemAttrText( aname => 'AME_SUB_APPROVAL_RESPONSE', avalue => 'APPROVE');
  po_wf_util_pkg.SetItemAttrText( aname => 'FORWARD_FROM_ID', avalue => l_child_approver_empid );
  po_wf_util_pkg.SetItemAttrText( aname => 'FORWARD_FROM_USER_NAME', avalue => l_child_approver_user_name);
  po_wf_util_pkg.SetItemAttrText( aname => 'FORWARD_FROM_DISP_NAME', avalue => l_child_approver_display_name);
  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_EMPID', avalue => l_child_approver_empid );
  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_USER_NAME', avalue => l_child_approver_user_name );
  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_DISPLAY_NAME', avalue => l_child_approver_display_name );

  l_progress := '040';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Completed');
  END IF;

  resultout := wf_engine.eng_completed||':'||'ACTIVITY_PERFORMED';
  RETURN;

END Process_Response_Approve;

--------------------------------------------------------------------------------
--Start of Comments
--Name: process_response_reject
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is the wrapper procedure of process_response_internal()
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE process_response_reject(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_progress                      VARCHAR2(3) := '000';
  l_parent_item_type              wf_items.parent_item_type%TYPE;
  l_parent_item_key               wf_items.parent_item_key%TYPE;
  l_child_approver_empid          NUMBER;
  l_child_approver_user_name      wf_users.name%TYPE;
  l_child_approver_display_name   wf_users.display_name%TYPE;
  l_api_name                      VARCHAR2(500) := 'process_response_reject';
  l_log_head                      VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Start');
  END IF;

  -- Logic:
  --  + Get parent_itemp_type and parent_item_key.
  --  + Call process_response_internal with action 'REJECT'. It will update ame with status and forwadee record.
  --  + Set workflow attribute AME_SUB_APPROVAL_RESPONSE to REJECT' of parent.
  --  + Fetch required current approver related workflow attributes as child attributes.
  --  + Populate parent workflow attributes FORWARD_FROM_ID, FORWARD_FROM_USER_NAME, FORWARD_FROM_DISP_NAME
  --    APPROVER_EMPID, APPROVER_USER_NAME, APPROVER_DISPLAY_NAME with child approver attributes.

  l_progress := '020';
  process_response_internal(itemtype, itemkey, 'REJECT');
  l_progress := '030';

  SELECT parent_item_type, parent_item_key
    INTO l_parent_item_type, l_parent_item_key
    FROM wf_items
   WHERE item_type = itemtype
     AND item_key = itemkey;

  l_progress := '040';

  l_child_approver_empid        := po_wf_util_pkg.GetItemAttrNumber( aname => 'APPROVER_EMPID');
  l_child_approver_user_name    := po_wf_util_pkg.GetItemAttrText( aname => 'APPROVER_USER_NAME');
  l_child_approver_display_name := po_wf_util_pkg.GetItemAttrText( aname => 'APPROVER_DISPLAY_NAME');

  PO_WF_UTIL_PKG.G_ITEM_TYPE  := l_parent_item_type;
  PO_WF_UTIL_PKG.G_ITEM_KEY   := l_parent_item_key;
  po_wf_util_pkg.SetItemAttrText( aname => 'AME_SUB_APPROVAL_RESPONSE', avalue => 'REJECT');
  po_wf_util_pkg.SetItemAttrText( aname => 'FORWARD_FROM_ID', avalue => l_child_approver_empid );
  po_wf_util_pkg.SetItemAttrText( aname => 'FORWARD_FROM_USER_NAME', avalue => l_child_approver_user_name);
  po_wf_util_pkg.SetItemAttrText( aname => 'FORWARD_FROM_DISP_NAME', avalue => l_child_approver_display_name);
  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_EMPID', avalue => l_child_approver_empid );
  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_USER_NAME', avalue => l_child_approver_user_name );
  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_DISPLAY_NAME', avalue => l_child_approver_display_name );

  l_progress := '050';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Completed');
  END IF;

  resultout := wf_engine.eng_completed||':'||'ACTIVITY_PERFORMED';
  RETURN;

END Process_Response_Reject;

--------------------------------------------------------------------------------
--Start of Comments
--Name: process_response_forward
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is the wrapper procedure of process_response_internal()
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE process_response_forward(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_progress                      VARCHAR2(3) := '000';
  l_parent_item_type              wf_items.parent_item_type%TYPE;
  l_parent_item_key               wf_items.parent_item_key%TYPE;
  l_child_approver_empid          NUMBER;
  l_child_approver_user_name      wf_users.name%TYPE;
  l_child_approver_display_name   wf_users.display_name%TYPE;
  l_api_name                      VARCHAR2(500) := 'process_response_forward';
  l_log_head                      VARCHAR2(500) := g_module_prefix||l_api_name;
BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Start');
  END IF;

  -- Logic:
  --  + Get parent_itemp_type and parent_item_key.
  --  + Call process_response_internal with action 'FORWARD'. It will update ame with status and forwadee record.
  --  + Set workflow attribute AME_SUB_APPROVAL_RESPONSE to 'FORWARD' of parent.
  --  + Fetch required current approver related workflow attributes as child attributes.
  --  + Populate parent workflow attributes FORWARD_FROM_ID, FORWARD_FROM_USER_NAME, FORWARD_FROM_DISP_NAME
  --    APPROVER_EMPID, APPROVER_USER_NAME, APPROVER_DISPLAY_NAME with child approver attributes.

  SELECT parent_item_type, parent_item_key
    INTO l_parent_item_type, l_parent_item_key
    FROM wf_items
   WHERE item_type = itemtype
     AND item_key = itemkey;

  l_progress := '020';
  process_response_internal(itemtype, itemkey, 'FORWARD');
  l_progress := '030';

  l_child_approver_empid        := po_wf_util_pkg.GetItemAttrNumber( aname => 'APPROVER_EMPID');
  l_child_approver_user_name    := po_wf_util_pkg.GetItemAttrText( aname => 'APPROVER_USER_NAME');
  l_child_approver_display_name := po_wf_util_pkg.GetItemAttrText( aname => 'APPROVER_DISPLAY_NAME');

  PO_WF_UTIL_PKG.G_ITEM_TYPE := l_parent_item_type;
  PO_WF_UTIL_PKG.G_ITEM_KEY := l_parent_item_key;
  po_wf_util_pkg.SetItemAttrText( aname => 'AME_SUB_APPROVAL_RESPONSE', avalue => 'FORWARD');
  po_wf_util_pkg.SetItemAttrText( aname => 'FORWARD_FROM_ID', avalue => l_child_approver_empid );
  po_wf_util_pkg.SetItemAttrText( aname => 'FORWARD_FROM_USER_NAME', avalue => l_child_approver_user_name);
  po_wf_util_pkg.SetItemAttrText( aname => 'FORWARD_FROM_DISP_NAME', avalue => l_child_approver_display_name);
  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_EMPID', avalue => l_child_approver_empid );
  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_USER_NAME', avalue => l_child_approver_user_name );
  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_DISPLAY_NAME', avalue => l_child_approver_display_name );

  l_progress := '040';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Completed');
  END IF;

  resultout := wf_engine.eng_completed||':'||'ACTIVITY_PERFORMED';
  RETURN;

END Process_Response_Forward;

--------------------------------------------------------------------------------
--Start of Comments
--Name: process_response_timeout
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is the wrapper procedure of process_response_internal()
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE process_response_timeout(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_progress                      VARCHAR2(3) := '000';
  l_parent_item_type              wf_items.parent_item_type%TYPE;
  l_parent_item_key               wf_items.parent_item_key%TYPE;
  l_child_approver_empid          NUMBER;
  l_child_approver_user_name      wf_users.name%TYPE;
  l_child_approver_display_name   wf_users.display_name%TYPE;
  l_api_name                      VARCHAR2(500) := 'process_response_timeout';
  l_log_head                      VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Start');
  END IF;

  -- Logic:
  --  + Get parent_itemp_type and parent_item_key.
  --  + Call process_response_internal with action 'TIMEOUT'. It will update ame with status and forwadee record.
  --  + Set workflow attribute AME_SUB_APPROVAL_RESPONSE to 'TIMEOUT' of parent.
  --  + Fetch required current approver related workflow attributes as child attributes.
  --  + Populate parent workflow attributes FORWARD_FROM_ID, FORWARD_FROM_USER_NAME, FORWARD_FROM_DISP_NAME
  --    APPROVER_EMPID, APPROVER_USER_NAME, APPROVER_DISPLAY_NAME with child approver attributes.

  process_response_internal(itemtype, itemkey, 'TIMEOUT');
  l_progress := '020';

  SELECT parent_item_type, parent_item_key
    INTO l_parent_item_type, l_parent_item_key
    FROM wf_items
   WHERE item_type = itemtype
     AND item_key = itemkey;

  l_progress := '030';

  l_child_approver_empid        := po_wf_util_pkg.GetItemAttrNumber( aname => 'APPROVER_EMPID');
  l_child_approver_user_name    := po_wf_util_pkg.GetItemAttrText( aname => 'APPROVER_USER_NAME');
  l_child_approver_display_name := po_wf_util_pkg.GetItemAttrText( aname => 'APPROVER_DISPLAY_NAME');

  PO_WF_UTIL_PKG.G_ITEM_TYPE := l_parent_item_type;
  PO_WF_UTIL_PKG.G_ITEM_KEY := l_parent_item_key;
  po_wf_util_pkg.SetItemAttrText( aname => 'AME_SUB_APPROVAL_RESPONSE', avalue => 'TIMEOUT');
  po_wf_util_pkg.SetItemAttrText( aname => 'FORWARD_FROM_ID', avalue => l_child_approver_empid );
  po_wf_util_pkg.SetItemAttrText( aname => 'FORWARD_FROM_USER_NAME', avalue => l_child_approver_user_name);
  po_wf_util_pkg.SetItemAttrText( aname => 'FORWARD_FROM_DISP_NAME', avalue => l_child_approver_display_name);
  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_EMPID', avalue => l_child_approver_empid );
  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_USER_NAME', avalue => l_child_approver_user_name );
  po_wf_util_pkg.SetItemAttrText( aname => 'APPROVER_DISPLAY_NAME', avalue => l_child_approver_display_name );

  l_progress := '040';

  wf_engine.CompleteActivity (itemtype => l_parent_item_type,
                              itemkey  => l_parent_item_key,
                              activity => 'BLOCK',
                              result   => NULL);

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Completed');
  END IF;

  resultout := wf_engine.eng_completed||':'||'ACTIVITY_PERFORMED';
  RETURN;

END Process_Response_Timeout;

--------------------------------------------------------------------------------
--Start of Comments
--Name: increment_no_reminder_attr
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is use to increment workflow attibute no_reminder and track
--  only two reminders are received by an approver.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE increment_no_reminder_attr(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_no_reminder NUMBER;
  l_progress    VARCHAR2(3) := '000';
  l_api_name    VARCHAR2(500) := 'increment_no_reminder_attr';
  l_log_head    VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Start');
  END IF;

  l_no_reminder := po_wf_util_pkg.GetItemAttrNumber( aname => 'NO_REMINDER');
  IF (l_no_reminder < 2) THEN
    l_no_reminder := l_no_reminder + 1;
  END IF;
  po_wf_util_pkg.SetItemAttrNumber( aname => 'NO_REMINDER', avalue => l_no_reminder );

  l_progress := '020';

  IF l_no_reminder = 1 THEN
    po_wf_util_pkg.SetItemAttrText( aname => 'REMINDER_TEXT', avalue => 'First Reminder' );
  ELSIF l_no_reminder = 2 THEN
    po_wf_util_pkg.SetItemAttrText( aname => 'REMINDER_TEXT', avalue => 'Second Reminder' );
  END IF;

  resultout := wf_engine.eng_completed||':'||'ACTIVITY_PERFORMED';
  RETURN;

END Increment_No_Reminder_Attr;

--------------------------------------------------------------------------------
--Start of Comments
--Name: post_approval_notif
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is use to increment workflow attibute no_reminder and track
--  only two reminders are received by an approver.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE post_approval_notif(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_responder_id              fnd_user.user_id%TYPE;
  l_session_user_id           NUMBER;
  l_session_resp_id           NUMBER;
  l_session_appl_id           NUMBER;
  l_preparer_resp_id          NUMBER;
  l_preparer_appl_id          NUMBER;
  l_preserved_ctx             VARCHAR2(5);
  l_nid                       NUMBER;
  l_progress                  VARCHAR2(3);
  l_action                    po_action_history.action_code%TYPE := NULL;
  l_new_recipient_id          wf_roles.orig_system_id%TYPE;
  l_current_recipient_id      wf_roles.orig_system_id%TYPE;
  l_origsys                   wf_roles.orig_system%TYPE;
  l_document_id               NUMBER;
  l_revision_num              NUMBER;
  l_draft_id                  NUMBER;
  l_org_id                    NUMBER;
  l_document_type             po_document_types.document_type_code%TYPE;
  l_document_subtype          po_document_types_all_b.document_subtype%TYPE;
  l_approval_group_id         NUMBER:='';
  l_original_recipient        wf_notifications.original_recipient%TYPE;
  l_current_recipient_role    wf_notifications.recipient_role%TYPE;
  l_api_name                  VARCHAR2(500) := 'post_approval_notif';
  l_log_head                  VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

    l_nid := wf_engine.context_nid;
    po_wf_util_pkg.SetItemAttrNumber( aname => 'NOTIFICATION_ID', avalue => l_nid);

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Start');
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||' funcmode:'||funcmode);
  END IF;

  IF (funcmode IN ('FORWARD','QUESTION','ANSWER', 'TIMEOUT') )THEN

    --Determine the action
    IF (funcmode = 'FORWARD') THEN
      l_action := 'DELEGATE';
    ELSIF (funcmode = 'QUESTION') THEN
      l_action := 'QUESTION';
    ELSIF (funcmode = 'ANSWER') THEN
      l_action := 'ANSWER';
    ELSIF (funcmode = 'TIMEOUT') THEN
      l_action := 'TIMED OUT';
    END IF;

    l_progress := '020';
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_action:'||l_action);
    END IF;

    IF(l_action IS NOT NULL) THEN
      l_document_id       := po_wf_util_pkg.GetItemAttrNumber( aname => 'DOCUMENT_ID');
      l_document_type     := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_TYPE');
      l_org_id            := po_wf_util_pkg.GetItemAttrNumber( aname => 'ORG_ID');
      l_draft_id          := po_wf_util_pkg.GetItemAttrText( aname => 'DRAFT_ID');
      l_document_subtype  := PO_WF_UTIL_PKG.GetItemAttrText ( aname => 'DOCUMENT_SUBTYPE');
      l_approval_group_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'APPROVAL_GROUP_ID');
	  l_revision_num      := po_wf_util_pkg.GetItemAttrNumber( aname => 'REVISION_NUMBER');

      --If function mode in 'FORWARD','QUESTION','ANSWER', then fetch l_new_recipient_id from wf_engine.context_new_role.
      --Else fetch it from original_recipient.
      IF (funcmode <> 'TIMEOUT') THEN

        l_progress := '030';
        wf_directory.GetRoleOrigSysInfo (wf_engine.context_new_role, l_origsys, l_new_recipient_id);

      ELSE

        l_progress := '040';
        BEGIN
          SELECT original_recipient,
                 DECODE(more_info_role, NULL, recipient_role, more_info_role)
            INTO l_original_recipient, l_current_recipient_role
            FROM wf_notifications
           WHERE notification_id = WF_ENGINE.context_nid
             AND (more_info_role IS NOT NULL OR recipient_role <> original_recipient );
        EXCEPTION
          WHEN OTHERS THEN
            l_original_recipient := NULL;
        END;

        IF l_original_recipient IS NOT NULL THEN
          Wf_Directory.GetRoleOrigSysInfo(l_original_recipient, l_origsys, l_new_recipient_id);
        END IF;

      END IF;

      l_progress := '050';
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||
		                l_progress||' l_new_recipient_id:'||l_new_recipient_id);
      END IF;

      --We should not be allowing the delegation of a notication  to a user who is not an employee.
      IF ((funcmode = 'FORWARD') AND (l_origsys <> 'PER')) THEN
        fnd_message.set_name ('PO' ,'PO_INVALID_USER_FOR_REASSIGN');
        app_exception.raise_exception;
      END IF;

      l_progress := '060';

      --Fetch the current recepient id
      IF (funcmode = 'ANSWER') THEN
        wf_directory.getroleorigsysinfo (wf_engine.context_more_info_role, l_origsys, l_current_recipient_id);
      ELSIF (funcmode = 'TIMEOUT') THEN
        Wf_Directory.GetRoleOrigSysInfo(l_current_recipient_role, l_origsys, l_current_recipient_id);
      ELSE
        wf_directory.getroleorigsysinfo (wf_engine.context_recipient_role, l_origsys, l_current_recipient_id);
      END IF;

      l_progress := '070';
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                       ||' l_current_recipient_id:'||l_current_recipient_id);
      END IF;

      IF (funcmode = 'FORWARD' ) THEN
        po_wf_util_pkg.SetItemAttrNumber( aname => 'APPROVER_EMPID', avalue => l_new_recipient_id);
      END IF;

      l_progress := '080';

      IF l_new_recipient_id IS NOT NULL THEN
        --Update po_action_history NULL record against current approver/l_current_recipient_id with l_action.
        UpdateActionHistoryPoAme(
		  p_document_id      => l_document_id,
          p_draft_id         => l_draft_id,
          p_document_type    => l_document_type,
          p_document_subtype => l_document_subtype,
          p_action           => l_action,
          p_note             => wf_engine.context_user_comment,
          p_current_approver => l_current_recipient_id );
        --Insert null action record into action_history for l_new_recipient_id
        InsertActionHistoryPoAme(
		  p_document_id       => l_document_id,
          p_draft_id          => l_draft_id,
          p_document_type     => l_document_type,
          p_document_subtype  => l_document_subtype,
	      p_revision_num      => l_revision_num,
          p_employee_id       => l_new_recipient_id,
          p_approval_group_id => l_approval_group_id,
          p_action            => NULL );
      END IF;

      l_progress := '090';

      IF (funcmode <> 'TIMEOUT') THEN
        resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
      END IF;
      RETURN;

    END IF; --IF(l_action IS NOT NULL) THEN
  END IF; --IF (funcmode IN ('FORWARD','QUESTION','ANSWER', 'TIMEOUT') )THEN

  -- Preserve the response context
  IF (funcmode = 'RESPOND') THEN

    l_progress := '100';
    l_nid := wf_engine.context_nid;
    po_wf_util_pkg.SetItemAttrNumber( aname => 'NOTIFICATION_ID', avalue => l_nid);

    SELECT fu.user_id
      INTO l_responder_id
      FROM fnd_user fu,
           wf_notifications wfn
     WHERE wfn.notification_id = l_nid
       AND wfn.original_recipient = fu.user_name;

    IF (wf_engine.preserved_context = TRUE) THEN
      l_preserved_ctx := 'TRUE';
    ELSE
      l_preserved_ctx := 'FALSE';
    END IF;

    l_progress := '110';
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_preserved_ctx:'||l_preserved_ctx);
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_responder_id:'||l_responder_id);
    END IF;

    l_session_user_id := fnd_global.user_id;
    l_session_resp_id := fnd_global.resp_id;
    l_session_appl_id := fnd_global.resp_appl_id;

    IF (l_session_user_id = - 1) THEN
      l_session_user_id := NULL;
    END IF;

    IF (l_session_resp_id = - 1) THEN
      l_session_resp_id := NULL;
    END IF;

    IF (l_session_appl_id = - 1) THEN
      l_session_appl_id := NULL;
    END IF;

    l_progress := '120';
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_session_user_id:'||l_session_user_id);
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_session_resp_id:'||l_session_resp_id);
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_session_appl_id:'||l_session_appl_id);
    END IF;

    l_preparer_resp_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'RESPONSIBILITY_ID');
    l_preparer_appl_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'APPLICATION_ID');

    l_progress := '130';
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_preparer_resp_id:'||l_preparer_resp_id);
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_preparer_appl_id:'||l_preparer_appl_id);
    END IF;

    l_progress := '140';
    IF (l_responder_id IS NOT NULL) THEN

      IF (l_responder_id <> l_session_user_id) THEN
        --Possible in 2 scenarios:
        -- 1. when the response is made from email using guest user feature
        -- 2. When the response is made from sysadmin login
        -- In this case capture the session user with preparer resp and appl id
        po_wf_util_pkg.SetItemAttrNumber( aname => 'RESPONDER_USER_ID' ,avalue => l_responder_id);
        po_wf_util_pkg.SetItemAttrNumber( aname => 'RESPONDER_RESP_ID' ,avalue => l_preparer_resp_id);
        po_wf_util_pkg.SetItemAttrNumber( aname => 'RESPONDER_APPL_ID' ,avalue => l_preparer_appl_id);
      ELSE
        -- Possible when the response is made from the default worklist without choosing a valid responsibility
        -- In this case also capture the session user with preparer resp and appl id
        IF (l_session_resp_id IS NULL) THEN
          po_wf_util_pkg.SetItemAttrNumber( aname => 'RESPONDER_USER_ID' ,avalue => l_responder_id);
          po_wf_util_pkg.SetItemAttrNumber( aname => 'RESPONDER_RESP_ID' ,avalue => l_preparer_resp_id);
          po_wf_util_pkg.SetItemAttrNumber( aname => 'RESPONDER_APPL_ID' ,avalue => l_preparer_appl_id);
        ELSE
          -- All values available - Possible when the response is made after choosing a correct responsibility
          IF (l_preserved_ctx = 'TRUE') THEN
            po_wf_util_pkg.SetItemAttrNumber( aname => 'RESPONDER_USER_ID' ,avalue => l_responder_id);
            po_wf_util_pkg.SetItemAttrNumber( aname => 'RESPONDER_RESP_ID' ,avalue => l_session_resp_id);
            po_wf_util_pkg.SetItemAttrNumber( aname => 'RESPONDER_APPL_ID' ,avalue => l_session_appl_id);
          ELSE
            -- The current session is a background session. So cannot depend on the session resp and appl ids.
            -- Need to depend on the preparer resp and appl ids
            po_wf_util_pkg.SetItemAttrNumber( aname => 'RESPONDER_USER_ID' ,avalue => l_responder_id);
            po_wf_util_pkg.SetItemAttrNumber( aname => 'RESPONDER_RESP_ID' ,avalue => l_preparer_resp_id);
            po_wf_util_pkg.SetItemAttrNumber( aname => 'RESPONDER_APPL_ID' ,avalue => l_preparer_appl_id);
          END IF; --IF (l_preserved_ctx = 'TRUE') THEN

        END IF; --IF (l_session_resp_id IS NULL) THEN
      END IF; --IF (l_responder_id <> l_session_user_id) THEN
    END IF; --IF (l_responder_id IS NOT NULL) THEN

    resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;

    l_progress := '150';
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Completed');
    END IF;

    RETURN;

  END IF; --IF (funcmode = 'RESPOND') THEN

  IF (funcmode = 'TRANSFER') THEN
    fnd_message.set_name ('PO','PO_WF_NOTIF_NO_TRANSFER');
    app_exception.raise_exception;
    resultout := wf_engine.eng_completed;
    RETURN;
  END IF;

END post_approval_notif;

--------------------------------------------------------------------------------
--Start of Comments
--Name: generate_pdf_ame_buyer
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is used to generate pdf for buyer with or without terms and conditions.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE generate_pdf_ame_buyer(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_document_id           NUMBER;
  l_document_subtype      po_headers.type_lookup_code%TYPE;
  l_header_id             NUMBER;
  l_document_type         po_headers.type_lookup_code%TYPE;
  l_revision_num          NUMBER;
  l_request_id            NUMBER;
  l_conterm_exists        po_headers_all.conterms_exist_flag%TYPE;
  l_authorization_status  VARCHAR2(25);
  l_progress              VARCHAR2(200);
  l_withterms             VARCHAR2(1);
  l_set_lang              BOOLEAN;
  l_language_code         fnd_languages.language_code%TYPE;
  l_language              fnd_languages.nls_language%TYPE;
  l_territory             fnd_languages.nls_territory%TYPE;
  submission_error        EXCEPTION;
  l_msg                   VARCHAR2(500);
  l_terms_param           VARCHAR2(1);
  l_api_name              VARCHAR2(500) := 'generate_pdf_ame_buyer';
  l_log_head              VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Start');
  END IF;

  l_document_type         := PO_WF_UTIL_PKG.GetItemAttrText (aname => 'DOCUMENT_TYPE');
  l_document_subtype      := PO_WF_UTIL_PKG.GetItemAttrText (aname => 'DOCUMENT_SUBTYPE');
  l_document_id           := po_wf_util_pkg.GetItemAttrNumber (aname => 'DOCUMENT_ID');
  l_revision_num          := po_wf_util_pkg.GetItemAttrNumber (aname => 'REVISION_NUMBER');
  l_authorization_status  := PO_WF_UTIL_PKG.GetItemAttrText(aname => 'AUTHORIZATION_STATUS');
  l_withterms             := PO_WF_UTIL_PKG.GetItemAttrText (aname => 'WITH_TERMS');
  l_language_code         := PO_WF_UTIL_PKG.GetItemAttrText(aname=>'LANGUAGE_CODE');

  IF l_document_type IN ('PO', 'PA') AND l_document_subtype IN ('STANDARD', 'BLANKET', 'CONTRACT') THEN
    l_header_id := l_document_id;
  END IF;

  --Get the language code
  l_progress := '020';
  BEGIN
    SELECT nls_language, nls_territory
      INTO l_language, l_territory
      FROM fnd_languages
     WHERE language_code = l_language_code;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Error when fetching language:'||sqlerrm);
      END IF;
  END;

  IF l_withterms IN ('Y','T') THEN
    l_withterms := 'Y';
  ELSE
    l_withterms := 'N';
  END IF;

  --Set the language preference
  l_set_lang := fnd_request.set_options('NO', 'NO', l_language, l_territory, NULL, FND_PROFILE.VALUE('ICX_NUMERIC_CHARACTERS'));
  po_moac_utils_pvt.set_request_context(po_moac_utils_pvt.get_current_org_id);
  l_request_id := fnd_request.submit_request( 'PO',
                                              'POXPOPDF',
                                              NULL,
                                              NULL,
                                              FALSE,
                                              'R',                     --P_report_type
                                              NULL ,                   --P_agend_id
                                              NULL,                    --P_po_num_from
                                              NULL ,                   --P_po_num_to
                                              NULL ,                   --P_relaese_num_from
                                              NULL ,                   --P_release_num_to
                                              NULL ,                   --P_date_from
                                              NULL ,                   --P_date_to
                                              NULL ,                   --P_approved_flag
                                              'N',                     --P_test_flag
                                              NULL ,                   --P_print_releases
                                              NULL ,                   --P_sortby
                                              NULL ,                   --P_user_id
                                              NULL ,                   --P_fax_enable
                                              NULL ,                   --P_fax_number
                                              NULL ,                   --P_BLANKET_LINES
                                              'View',                  --View_or_Communicate,
                                              l_withterms,             --P_WITHTERMS
                                              'Y',                     --P_storeFlag
                                              'N',                     --P_PRINT_FLAG
                                              l_document_id,           --P_DOCUMENT_ID
                                              l_revision_num,          --P_REVISION_NUM
                                              l_authorization_status,  --P_AUTHORIZATION_STATUS
                                              l_document_subtype,      --P_DOCUMENT_TYPE
                                              NULL,                    -- P_PO_TEMPLATE_CODE
                                              NULL,                    -- P_CONTRACT_TEMPLATE_CODE
                                              fnd_global.local_chr(0),
                                              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                              NULL);

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_request_id:'||l_request_id);
  END IF;

  --If the request id is NULL or 0, then there is a submission check error.
  IF (l_request_id <= 0 OR l_request_id IS NULL) THEN
    RAISE SUBMISSION_ERROR;
  END IF;

  po_wf_util_pkg.SetItemAttrNumber (aname => 'REQUEST_ID', avalue => l_request_id);

EXCEPTION
  WHEN submission_error THEN
    l_msg := fnd_message.get;
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Exception when submitting the request');
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' fnd_message:'||l_msg);
    END IF;
    WF_CORE.context(g_pkg_name, l_api_name, l_progress, l_msg);
    RAISE;
  WHEN OTHERS THEN
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Exception:'||sqlerrm);
    END IF;
    WF_CORE.context(g_pkg_name, l_api_name, l_progress, sqlerrm);
    RAISE;
END generate_pdf_ame_buyer;

--------------------------------------------------------------------------------
--Start of Comments
--Name: generate_pdf_ame_supp
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is used to generate pdf for supplier in supplier's launguage along with Attachments.zip
-- with or without terms and conditions.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE generate_pdf_ame_supp(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_document_id           po_headers.po_header_id%TYPE;
  l_revision_num          po_headers.revision_num%TYPE;
  l_document_subtype      po_headers.type_lookup_code%TYPE;
  l_document_type         po_headers.type_lookup_code%TYPE;
  l_territory             fnd_languages.nls_territory%type;
  l_language_code         fnd_languages.language_code%type;
  l_supp_lang             po_vendor_sites_all.language%TYPE;
  l_language              fnd_languages.nls_language%type;
  l_authorization_status  po_headers.authorization_status%TYPE;
  l_header_id             po_headers.po_header_id%TYPE;
  l_with_terms            VARCHAR2(1);
  l_request_id            NUMBER;
  l_set_lang              BOOLEAN;
  l_progress              VARCHAR2(100);
  submission_error        EXCEPTION;
  l_msg                   VARCHAR2(500);
  l_terms_param           VARCHAR2(1);
  l_attachments_exist     VARCHAR2(1); -- Holds 'Y' if there are any supplier file attachments
  l_duplicate_filenames   VARCHAR2(1); -- Holds 'Y' if there are any supplier file attachments with same filename
  l_error_flag            NUMBER;      -- Determines if the error condition (same file namebut different file lengths has been met or not)
  l_max_attachment_size   po_system_parameters_all.max_attachment_size%type;
  l_filename_new          fnd_lobs.file_name%type;
  l_length                NUMBER;
  l_length_new            NUMBER;
  l_filename              fnd_lobs.file_name%type;
  l_api_name              VARCHAR2(500) := 'generate_pdf_ame_supp';
  l_log_head              VARCHAR2(500) := g_module_prefix||l_api_name;

  CURSOR l_get_po_attachments_csr(l_po_header_id NUMBER) IS
    SELECT fl.file_name, dbms_lob.getlength(fl.file_data)
      FROM fnd_documents d,
           fnd_attached_documents ad,
           fnd_doc_category_usages dcu,
           fnd_attachment_functions af,
           fnd_lobs fl
     WHERE ( (ad.pk1_value = TO_CHAR(l_po_header_id) AND ad.entity_name = 'PO_HEADERS') OR
             (ad.pk1_value =  (SELECT To_Char(vendor_id)
                                 FROM po_headers_all
                                WHERE po_header_id = l_po_header_id) AND ad.entity_name = 'PO_VENDORS') OR
             (ad.pk1_value IN (SELECT To_Char(po_line_id)
                                 FROM po_lines_all
                                WHERE po_header_id = l_po_header_id ) AND ad.entity_name = 'PO_LINES') OR
             (ad.pk1_value IN (SELECT To_Char(from_header_id)
                                 FROM po_lines_all
                                WHERE po_header_id = l_po_header_id
                                  AND from_header_id IS NOT NULL ) AND ad.entity_name = 'PO_HEADERS') OR
             (ad.pk1_value IN (SELECT To_Char(from_line_id)
                                 FROM po_lines_all
                                WHERE po_header_id = l_po_header_id
                                  AND from_line_id IS NOT NULL ) AND ad.entity_name = 'PO_LINES') OR
             (ad.pk1_value IN (SELECT To_Char(line_location_id)
                                 FROM po_line_locations_all
                                WHERE po_header_id = l_po_header_id
                                  AND shipment_type IN ('PRICE BREAK', 'STANDARD', 'PREPAYMENT')) AND ad.entity_name = 'PO_SHIPMENTS') OR
             (ad.pk2_value IN (SELECT To_Char(item_id)
                                 FROM po_lines_all
                                WHERE po_header_id = l_po_header_id
                                  AND TO_CHAR(PO_COMMUNICATION_PVT.getInventoryOrgId()) = ad.pk1_value
                                  AND item_id IS NOT NULL ) AND ad.entity_name = 'MTL_SYSTEM_ITEMS') )
       AND d.document_id = ad.document_id
       AND dcu.category_id = d.category_id
       AND dcu.attachment_function_id = af.attachment_function_id
       AND d.datatype_id = 6
       AND af.function_name = 'PO_PRINTPO'
       AND d.media_id = fl.file_id
       AND dcu.enabled_flag = 'Y'
     GROUP BY fl.file_name, dbms_lob.getlength(fl.file_data)
     ORDER BY fl.file_name;

BEGIN
  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Start');
  END IF;

  l_document_type         := PO_WF_UTIL_PKG.GetItemAttrText (aname => 'DOCUMENT_TYPE');
  l_document_subtype      := PO_WF_UTIL_PKG.GetItemAttrText (aname => 'DOCUMENT_SUBTYPE');
  l_document_id           := po_wf_util_pkg.GetItemAttrNumber (aname => 'DOCUMENT_ID');
  l_revision_num          := po_wf_util_pkg.GetItemAttrNumber (aname => 'REVISION_NUMBER');
  l_language_code         := PO_WF_UTIL_PKG.GetItemAttrText (aname => 'LANGUAGE_CODE');
  l_with_terms            := PO_WF_UTIL_PKG.GetItemAttrText (aname => 'WITH_TERMS');
  l_authorization_status  := PO_WF_UTIL_PKG.GetItemAttrText(aname => 'AUTHORIZATION_STATUS');

  IF l_document_type IN ('PO', 'PA') AND l_document_subtype IN ('STANDARD', 'BLANKET', 'CONTRACT') THEN
    l_header_id := l_document_id;
  END IF;

  l_progress := '020';

  BEGIN
    SELECT pv.language
      INTO l_supp_lang
      FROM po_vendor_sites_all pv, po_headers_all ph
     WHERE ph.po_header_id = l_header_id
       AND ph.vendor_site_id = pv.vendor_site_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                       ||' Error while fetching vendor site language:'||sqlerrm);
      END IF;
  END;

  l_progress := '030';
  BEGIN
    SELECT nls_language
      INTO l_language
      FROM fnd_languages
     WHERE language_code = l_language_code;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                       ||' Error while fetching the language code:'||sqlerrm);
      END IF;
  END;

  /*-------------------------------------------------------------------------
  In the whole of Zip generation process, all unexpected exceptions must
  be handled and none should be raised to the workflow because that will
  stop the workflow process would prevent sending the error notification.

  In case of any unexpected exceptions, the exception should be handled
  and workflow attribute ZIP_ERROR_CODE should be set to 'UNEXPECTED' so
  that corresponding error notification can be sent to buyer and supplier.

  Also in case of exception, l_max_attachment_size should be set to 0 so
  that Zip file is not generated.
  -------------------------------------------------------------------------*/
  BEGIN
    -- Get the 'Maximum Attachment Size' value from Purchasing Options
    -- A value of 0 means Zip Attachments are not supported
    l_progress := '040';
    l_max_attachment_size := PO_COMMUNICATION_PVT.get_max_zip_size(itemtype, itemkey);

    IF l_max_attachment_size > 0 THEN
      -- If PO has no 'To Supplier' file attachments then 'Zip Attachment' link
      -- should not show up in the notifications and Zip file should not be generated
      l_attachments_exist := 'N';

      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Checking for supplier file attachments');
      END IF;

      BEGIN
        l_attachments_exist := PO_COMMUNICATION_PVT.check_for_attachments(p_document_type => l_document_type, p_document_id => l_document_id);
      EXCEPTION
        WHEN no_data_found THEN
          IF (g_po_wf_debug = 'Y') THEN
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' No Supplier file attachments');
          END IF;
          l_max_attachment_size := 0; --No need to generate the pdf
      END;

      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_attachments_exist:'||l_attachments_exist);
      END IF;

      IF l_attachments_exist = 'Y' THEN
        l_progress := '050';
        po_wf_util_pkg.SetItemAttrText (aname  => 'ZIP_ATTACHMENT',
                                        avalue => 'PLSQLBLOB:PO_COMMUNICATION_PVT.ZIP_ATTACH/' || itemtype || ':' || itemkey);

        /*---------------------------------------------------------------------------------
        An error condition is when two or more file attachments have the same file name
        but different file sizes. In this case a zip error notification should be sent
        and zip file should not be generated.
        Following two cases are ok:
          1. There are no duplicate file names in the PO Attachments
          2. Files with same name also have the same sizes
        Case 1 would be most common and is given highest priority in terms of performance.
        So a separate query for finding duplicate file names is written. If no duplicate
        file names then cursors for checking the error condition are not opened.
        ---------------------------------------------------------------------------------*/
        IF (g_po_wf_debug = 'Y') THEN
          PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Check for duplicate filenames');
        END IF;

        l_duplicate_filenames := 'N';

        BEGIN
          SELECT 'Y'
            INTO l_duplicate_filenames
            FROM dual
           WHERE EXISTS ( SELECT fl.file_name
                            FROM fnd_documents d,
                                 fnd_attached_documents ad,
                                 fnd_doc_category_usages dcu,
                                 fnd_attachment_functions af,
                                 fnd_lobs fl
                           WHERE ( (ad.pk1_value = TO_CHAR(l_document_id) AND ad.entity_name = 'PO_HEADERS') OR
                                    --
                                   (ad.pk1_value = TO_CHAR((SELECT vendor_id
                                                              FROM po_headers_all
                                                             WHERE po_header_id = l_document_id))
                                                   AND ad.entity_name = 'PO_VENDORS') OR
                                    --
                                   (ad.pk1_value IN (SELECT po_line_id
                                                       FROM po_lines_all
                                                      WHERE po_header_id = l_document_id)
                                                AND ad.entity_name = 'PO_LINES') OR
                                    --
                                   (ad.pk1_value IN (SELECT from_header_id
                                                       FROM po_lines_all
                                                      WHERE po_header_id = l_document_id
                                                        AND from_header_id IS NOT NULL) AND ad.entity_name = 'PO_HEADERS') OR
                                    --
                                   (ad.pk1_value IN (SELECT from_line_id
                                                       FROM po_lines_all
                                                      WHERE po_header_id = l_document_id
                                                        AND from_line_id IS NOT NULL) AND ad.entity_name = 'PO_LINES') OR
                                    --
                                   (ad.pk1_value IN (SELECT line_location_id
                                                       FROM po_line_locations_all
                                                      WHERE po_header_id = l_document_id
                                                        AND shipment_type IN ('PRICE BREAK', 'STANDARD', 'PREPAYMENT'))
                                                AND ad.entity_name = 'PO_SHIPMENTS') OR
                                    --
                                   (ad.pk2_value IN (SELECT item_id
                                                       FROM po_lines_all
                                                      WHERE po_header_id = l_document_id
                                                        AND TO_CHAR(PO_COMMUNICATION_PVT.getInventoryOrgId()) = ad.pk1_value
                                                        AND item_id IS NOT NULL) AND ad.entity_name = 'MTL_SYSTEM_ITEMS'))
                             AND d.document_id = ad.document_id
                             AND dcu.category_id = d.category_id
                             AND dcu.attachment_function_id = af.attachment_function_id
                             AND d.datatype_id = 6
                             AND af.function_name = 'PO_PRINTPO'
                             AND d.media_id = fl.file_id
                             AND dcu.enabled_flag = 'Y'
                           GROUP BY fl.file_name
                          HAVING COUNT(*)>1);

          --If no_data_found then let l_duplicate_filename remain 'N'
          --so that cursor is not opened. All other exceptions raised
          --until caught by outer exception handler
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF (g_po_wf_debug = 'Y') THEN
              PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' No duplicate attachments');
            END IF;
        END;

        l_progress := '060';

        IF l_duplicate_filenames = 'Y' THEN
          IF (g_po_wf_debug = 'Y') THEN
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Duplicate filenames found');
          END IF;

          --Loop through the ordered records to verify if the same attachment has same different content
          OPEN l_get_po_attachments_csr(l_document_id);
          l_error_flag := 0;

          LOOP
            FETCH l_get_po_attachments_csr INTO l_filename_new, l_length_new;

            EXIT WHEN (l_get_po_attachments_csr%notfound);

            IF (l_filename_new = l_filename AND l_length_new <> l_length) THEN
              l_error_flag := 1;
              EXIT;
            END IF;

            l_filename := l_filename_new;
            l_length := l_length_new;
          END LOOP;

          CLOSE l_get_po_attachments_csr;

          IF (g_po_wf_debug = 'Y') THEN
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_error_flag:'||l_error_flag);
          END IF;

          IF l_error_flag = 1 THEN
            PO_COMMUNICATION_PVT.set_zip_error_code(itemtype, itemkey, 'DUPLICATE_FILENAME');
            l_max_attachment_size := 0; --No need to generate the pdf
          END IF;
        END IF; --IF l_duplicate_filenames = 'Y'
      END IF; --IF l_attachments_exist = 'Y'
    END IF; --IF l_max_attachment_size > 0

  EXCEPTION
    WHEN OTHERS THEN
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||'Exception when detecting duplicates');
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' sqlerrm:'||sqlerrm);
      END IF;
      PO_COMMUNICATION_PVT.set_zip_error_code(itemtype, itemkey, 'UNEXPECTED');
      l_max_attachment_size := 0; --No need to generate the pdf
  END;

  l_progress := '070';
  -- Submit the request to generate the zip file
  IF l_with_terms IN ('Y','T') THEN
    l_terms_param := 'Y';
  ELSE
    l_terms_param := 'N';
  END IF;

  l_progress := '080';
  IF l_language <> l_supp_lang THEN
    SELECT nls_territory
      INTO l_territory
      FROM fnd_languages
     WHERE nls_language = l_supp_lang;

    l_set_lang := fnd_request.set_options('NO', 'NO', l_supp_lang, l_territory, NULL, FND_PROFILE.VALUE('ICX_NUMERIC_CHARACTERS'));
    po_moac_utils_pvt.set_request_context(po_moac_utils_pvt.get_current_org_id);

    l_progress := '090';

    l_request_id := fnd_request.submit_request( 'PO',
                                                'POXPOPDF',
                                                NULL,
                                                NULL,
                                                FALSE,
                                                'R',                     --P_report_type
                                                NULL ,                   --P_agend_id
                                                NULL,                    --P_po_num_from
                                                NULL ,                   --P_po_num_to
                                                NULL ,                   --P_relaese_num_from
                                                NULL ,                   --P_release_num_to
                                                NULL ,                   --P_date_from
                                                NULL ,                   --P_date_to
                                                NULL ,                   --P_approved_flag
                                                'N',                     --P_test_flag
                                                NULL ,                   --P_print_releases
                                                NULL ,                   --P_sortby
                                                NULL ,                   --P_user_id
                                                NULL ,                   --P_fax_enable
                                                NULL ,                   --P_fax_number
                                                NULL ,                   --P_BLANKET_LINES
                                                'View',                  --View_or_Communicate,
                                                l_terms_param,           --P_WITHTERMS
                                                'Y',                     --P_storeFlag
                                                'N',                     --P_PRINT_FLAG
                                                l_document_id,           --P_DOCUMENT_ID
                                                l_revision_num,          --P_REVISION_NUM
                                                l_authorization_status,  --P_AUTHORIZATION_STATUS
                                                l_document_subtype,      --P_DOCUMENT_TYPE
                                                l_max_attachment_size,   --P_max_zip_size
                                                NULL,                    -- P_PO_TEMPLATE_CODE
                                                NULL,                    -- P_CONTRACT_TEMPLATE_CODE
                                                fnd_global.local_chr(0),
                                                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                NULL, NULL);

    l_progress := '100';
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_request_id:'||l_request_id);
    END IF;

    IF (l_request_id <= 0 OR l_request_id IS NULL) THEN
      RAISE SUBMISSION_ERROR;
    END IF;

    po_wf_util_pkg.SetItemAttrNumber( aname => 'REQUEST_ID', avalue => l_request_id);

  END IF;

EXCEPTION
  WHEN SUBMISSION_ERROR THEN
    l_msg := fnd_message.get;
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Exception when submitting the request');
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' fnd_message:'||l_msg);
    END IF;
    WF_CORE.context(g_pkg_name, l_api_name, l_progress, l_msg);
    RAISE;

  WHEN OTHERS THEN
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Exception:'||sqlerrm);
    END IF;
    WF_CORE.context(g_pkg_name, l_api_name, l_progress, sqlerrm);
    RAISE;

END generate_pdf_ame_supp;

  --------------------------------------------------------------------------------
  --Start of Comments
  --Name: forward_unable_to_reserve
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  --  Workflow activity PL/SQL handler.
  -- This procedure is used to set workflow attributes in case approver uses forward
  -- for Unable to Reserve Notification
  --Parameters:
  --IN:
  --  Standard workflow IN parameters
  --OUT:
  --  Standard workflow OUT parameters
  --Testing:
  --
  --End of Comments
  -------------------------------------------------------------------------------

PROCEDURE forward_unable_to_reserve(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_forward_to_username_response VARCHAR2(60) := NULL;
  l_document_id                  NUMBER;
  l_document_type                VARCHAR2(25):='';
  l_document_subtype             VARCHAR2(25):='';
  l_revision_num                 NUMBER;
  l_note                         VARCHAR2(4000);
  l_org_id                       NUMBER;
  l_current_approver             NUMBER;
  l_draft_id                     NUMBER;
  l_progress                     VARCHAR2(3);
  l_approval_group_id            NUMBER;
  l_api_name                     VARCHAR2(500) := 'forward_unable_to_reserve';
  l_log_head                     VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN
  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Start');
  END IF;

  l_forward_to_username_response := po_wf_util_pkg.GetItemAttrText( aname => 'FORWARD_TO_USERNAME_RESPONSE');
  po_wf_util_pkg.SetItemAttrText ( aname => 'APPROVER_USER_NAME', avalue => l_forward_to_username_response);

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                   ||' l_forward_to_username_response:'||l_forward_to_username_response);
  END IF;

  l_current_approver  := po_wf_util_pkg.GetItemAttrNumber( aname=>'APPROVER_EMPID');
  l_document_id       := po_wf_util_pkg.GetItemAttrNumber( aname => 'DOCUMENT_ID');
  l_draft_id          := po_wf_util_pkg.GetItemAttrNumber( aname => 'DRAFT_ID');
  l_document_type     := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_TYPE');
  l_document_subtype  := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_SUBTYPE');
  l_note              := po_wf_util_pkg.GetItemAttrText( aname => 'NOTE');
  l_approval_group_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'APPROVAL_GROUP_ID');
  l_revision_num      := po_wf_util_pkg.GetItemAttrNumber( aname => 'REVISION_NUMBER');

  IF l_org_id IS NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_org_id);
  END IF;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_current_approver:'||l_current_approver);
  END IF;

  l_progress := '020';

  InsertActionHistoryPoAme(
    p_document_id       => l_document_id,
    p_draft_id          => l_draft_id,
    p_document_type     => l_document_type,
    p_document_subtype  => l_document_subtype,
	p_revision_num      => l_revision_num,
    p_employee_id       => l_current_approver,
    p_approval_group_id => l_approval_group_id,
    p_action            => 'FORWARD');

  l_progress := '030';

  InsertActionHistoryPoAme(
    p_document_id       => l_document_id,
    p_draft_id          => l_draft_id,
    p_document_type     => l_document_type,
    p_document_subtype  => l_document_subtype,
	p_revision_num      => l_revision_num,
    p_employee_id       => l_current_approver,
    p_approval_group_id => l_approval_group_id,
    p_action            => NULL);

  resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED';

END forward_unable_to_reserve;

--------------------------------------------------------------------------------
--Name: process_beat_by_first
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
PROCEDURE process_beat_by_first(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_progress                VARCHAR2(3) := '000';
  l_parent_item_type        wf_items.parent_item_type%TYPE;
  l_parent_item_key         wf_items.parent_item_key%TYPE;
  l_child_approver_empid    NUMBER;
  l_child_approver_groupid  NUMBER;
  l_approver_group_id       NUMBER;
  l_po_header_id            NUMBER;
  l_process_out             VARCHAR2(10);
  l_approver_list           ame_util.approversTable2;
  ameTransactionType        po_document_types.ame_transaction_type%TYPE;
  l_response_action         VARCHAR2(20);
  l_note                    VARCHAR2(4000);
  l_person_id               NUMBER;
  l_orig_system             VARCHAR2(3);
  l_orig_system_id          NUMBER;
  l_preparer_user_name      fnd_user.user_name%TYPE;
  l_doc_string              VARCHAR2(200);
  l_ame_exception           ame_util.longestStringType;
  l_approver_response       VARCHAR2(20);
  l_transaction_type        po_document_types.ame_transaction_type%TYPE;
  l_ame_transaction_id      NUMBER;
  l_document_type           po_document_types.document_type_code%TYPE;
  l_document_subtype        po_document_types.document_subtype%TYPE;
  l_approver_category       VARCHAR2(20);
  l_api_name                VARCHAR2(500) := 'process_beat_by_first';
  l_log_head                VARCHAR2(500) := g_module_prefix||l_api_name;
  l_approver_disp_name      VARCHAR2(200);

  CURSOR l_child_wf ( itemtype IN wf_items.parent_item_type%TYPE,
                       itemkey IN wf_items.parent_item_key%TYPE ) IS
    SELECT wfi.item_type,
           wfi.item_key,
           wfn.recipient_role,
           wfn.original_recipient
      FROM wf_items wfi,
           wf_item_activity_statuses wfias,
           wf_notifications wfn
     WHERE wfi.parent_item_key = itemkey
       AND wfi.item_type = itemtype
       AND wfias.item_type = wfi.item_type
       AND wfias.item_key = wfi.item_key
       AND wfias.activity_status = 'NOTIFIED'
       AND wfias.notification_id IS NOT NULL
       AND wfias.notification_id = wfn.notification_id;

  l_child_wf_cur l_child_wf%ROWTYPE;
  l_draft_id NUMBER;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Start');
  END IF;

  SELECT parent_item_type, parent_item_key
    INTO l_parent_item_type, l_parent_item_key
    FROM wf_items
   WHERE item_type = itemtype
     AND item_key = itemkey;

  --Check if there we have encountered any ame exception.
  --If the value of ame_exception is not null, then we have faced some exception.
  --So just comlete the block activity and return

  l_approver_group_id   := po_wf_util_pkg.GetItemAttrNumber( aname => 'APPROVAL_GROUP_ID');
  l_po_header_id        := po_wf_util_pkg.GetItemAttrNumber( aname => 'DOCUMENT_ID');
  l_draft_id            := po_wf_util_pkg.GetItemAttrNumber( aname => 'DRAFT_ID');
  l_approver_response   := po_wf_util_pkg.GetItemAttrText( aname => 'APPROVER_RESPONSE');
  l_document_type       := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_TYPE');
  l_document_subtype    := PO_WF_UTIL_PKG.GetItemAttrText( aname => 'DOCUMENT_SUBTYPE');
  l_ame_transaction_id  := po_wf_util_pkg.GetItemAttrNumber( aname => 'AME_TRANSACTION_ID');
  l_transaction_type    := po_wf_util_pkg.GetItemAttrText( aname => 'AME_TRANSACTION_TYPE');
  l_approver_category   := po_wf_util_pkg.GetItemAttrText ( aname => 'APPROVER_CATEGORY');
  l_approver_disp_name   := po_wf_util_pkg.GetItemAttrText ( aname => 'APPROVER_DISPLAY_NAME');

  l_progress := '020';

  IF l_approver_response = 'APPROVED' THEN
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_ame_transaction_id:'||l_ame_transaction_id);
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_transaction_type:'||l_transaction_type);
    END IF;

    IF l_approver_category = 'REVIEWER' THEN
      fnd_message.set_name('PO', 'PO_ALREADY_REVIEW_ACCEPTED');
   	ELSIF l_approver_category = 'ESIGNER' THEN
      fnd_message.set_name('PO', 'PO_ALREADY_SIGNED');
    ELSE
      fnd_message.set_name('PO', 'PO_ALREADY_APPROVED');
    END IF;

    fnd_message.set_token('PERSON_NAME', l_approver_disp_name);
    l_note := fnd_message.get;

    ame_api2.getAllApprovers7 ( applicationIdIn => applicationId,
                                transactionIdIn => l_ame_transaction_id,
                                transactionTypeIn => l_transaction_type,
                                approvalProcessCompleteYNOut => l_process_out,
                                approversOut =>  l_approver_list );

    l_progress := '030';
    -- Once we get the approvers list from AME, we iterate through the approvers list,
    -- to find out the current first authority approver.

    FOR i IN 1.. l_approver_list.count LOOP
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                       ||' Index:'||TO_CHAR(i));
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                       ||' orig_system:'|| l_approver_list(i).orig_system);
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                       ||' orig_system_id:'|| l_approver_list(i).orig_system_id);
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                       ||' authority:'|| l_approver_list(i).authority);
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                       ||' approval_status:'|| l_approver_list(i).approval_status);
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                       ||' api_insertion:'|| l_approver_list(i).api_insertion);
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                       ||' group_or_chain_id:'|| l_approver_list(i).group_or_chain_id);
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                       ||' beatByFirstResponderStatus:'||ame_util.beatByFirstResponderStatus);
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                       ||' oamGenerated:'||ame_util.oamGenerated);
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                       ||' l_approver_group_id:'||l_approver_group_id);
      END IF;

      l_progress := '040';
      IF (      l_approver_list(i).approval_status = ame_util.beatByFirstResponderStatus
           AND  l_approver_list(i).api_insertion = ame_util.oamGenerated
           AND  l_approver_list(i).group_or_chain_id = l_approver_group_id) THEN

        l_orig_system :=  l_approver_list(i).orig_system;
        l_orig_system_id :=  l_approver_list(i).orig_system_id;

        IF ( l_orig_system = ame_util.perOrigSystem) THEN
          -- Employee Supervisor Record.
          l_person_id := l_orig_system_id;

        ELSIF ( l_orig_system = ame_util.posOrigSystem) THEN
          -- Position Hierarchy Record.
          BEGIN
		    -----------------------------------------------------------------------
		    -- SQL What: Get the person assigned to position returned by AME.
            -- SQL Why : When AME returns position id, then using this sql we find
            --           one person assigned to this position and use this person
		    --           as approver.
            -----------------------------------------------------------------------
            SELECT person_id
              INTO l_person_id
              FROM ( SELECT person.person_id
                       FROM per_all_people_f person,
                            per_all_assignments_f asg,
							wf_users wu
                      WHERE asg.position_id = l_orig_system_id
					    AND wu.orig_system     = ame_util.perorigsystem
                        AND wu.orig_system_id  = person.person_id
                        AND TRUNC(SYSDATE) BETWEEN person.effective_start_date AND NVL(person.effective_end_date, TRUNC( SYSDATE) )
                        AND person.person_id = asg.person_id
                        AND asg.primary_flag = 'Y'
                        AND asg.assignment_type IN ( 'E', 'C' )
                        AND ( person.current_employee_flag = 'Y' OR person.current_npw_flag = 'Y' )
                        AND asg.assignment_status_type_id NOT IN
                                         (SELECT assignment_status_type_id
                                            FROM per_assignment_status_types
                                           WHERE per_system_status = 'TERM_ASSIGN' )
                        AND TRUNC(SYSDATE) BETWEEN asg.effective_start_date AND asg.effective_end_date
                      ORDER BY person.last_name )
             WHERE ROWNUM = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_person_id := -1;
          END;

        ELSIF (l_orig_system = ame_util.fndUserOrigSystem) THEN
          --FND User Record.
          SELECT employee_id
            INTO l_person_id
            FROM fnd_user
           WHERE user_id = l_orig_system_id
             AND TRUNC(SYSDATE) BETWEEN start_date AND NVL(end_date, SYSDATE + 1);

        END IF; --l_orig_system =

        l_progress := '050';
        IF (g_po_wf_debug = 'Y') THEN
          PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' l_person_id:'||l_person_id);
        END IF;

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
          IF (g_po_wf_debug = 'Y') THEN
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                           ||' l_child_approver_empid:'||l_child_approver_empid);
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                           ||' l_child_approver_groupid:'||l_child_approver_groupid);
          END IF;

          IF ( ( l_child_approver_empid = l_person_id OR
               ( l_child_wf_cur.recipient_role <> l_child_wf_cur.original_recipient) ) AND
               l_child_approver_groupid = l_approver_group_id ) THEN

            IF (g_po_wf_debug = 'Y') THEN
              PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress
                                                             ||' l_child_wf_cur.item_key:'||l_child_wf_cur.item_key);
            END IF;

            l_progress := '060';
            wf_engine.AbortProcess(l_child_wf_cur.item_type ,l_child_wf_cur.item_key);

          END IF;

        END LOOP; --l_child_wf
        CLOSE l_child_wf;

        l_progress := '070';
		  UpdateActionHistoryPoAme (
	        p_document_id      => l_po_header_id,
            p_draft_id         => l_draft_id,
            p_document_type    => l_document_type,
            p_document_subtype => l_document_subtype,
            p_action           => 'NO ACTION',
            p_note             => l_note,
            p_current_approver => l_person_id);

      END IF; -- l_approver_list(i).approval_status = ame_util.beatByFirstResponderStatus
    END LOOP; -- l_approver_list.count

  ELSIF (l_approver_response = 'REJECTED') THEN

    l_progress := '080';

    OPEN l_child_wf(l_parent_item_type, l_parent_item_key);
    LOOP

      FETCH l_child_wf INTO l_child_wf_cur;
      EXIT WHEN l_child_wf%NOTFOUND;

      -- Get the approver id as the person id to update the action history
      l_person_id := po_wf_util_pkg.GetItemAttrNumber( itemtype => l_child_wf_cur.item_type,
                                                       itemkey  => l_child_wf_cur.item_key,
                                                       aname    => 'APPROVER_EMPID');
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' child item_key:'||l_child_wf_cur.item_key);
      END IF;

      wf_engine.AbortProcess(l_child_wf_cur.item_type ,l_child_wf_cur.item_key);

      -- update the action history table
      IF l_approver_category = 'REVIEWER' THEN
        fnd_message.set_name('PO', 'PO_ALREADY_REVIEW_REJECTED');
	     ELSIF l_approver_category = 'ESIGNER' THEN
        fnd_message.set_name('PO', 'PO_ALREADY_SIGNER_REJECTED');
      ELSE
        fnd_message.set_name('PO', 'PO_ALREADY_REJECTED');
      END IF;

      fnd_message.set_token('PERSON_NAME', l_approver_disp_name);
      l_note := fnd_message.get;

      l_progress := '090';

		    UpdateActionHistoryPoAme (
	           p_document_id      => l_po_header_id,
            p_draft_id         => l_draft_id,
            p_document_type    => l_document_type,
            p_document_subtype => l_document_subtype,
            p_action           => 'NO ACTION',
            p_note             => l_note,
            p_current_approver => l_person_id);

      l_progress := '100';
    END LOOP;
    CLOSE l_child_wf;

  END IF; --IF l_approver_response = 'APPROVED'

  l_progress := '110';

  wf_engine.CompleteActivity(
    itemtype => l_parent_item_type,
    itemkey  => l_parent_item_key,
    activity => 'BLOCK',
    result   => NULL);

  resultout := wf_engine.eng_completed||':'||'ACTIVITY_PERFORMED';
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context(g_pkg_name, l_api_name, l_progress, sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, l_progress, l_po_header_id);
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
    END IF;
    RAISE;
END process_beat_by_first;

--------------------------------------------------------------------------------
--Name: update_resp_verf_failed
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function: This procedure sets AME_SUB_APPROVAL_RESPONSE with FAILED_VERIFICATION. Document in this
-- case is not supposed to returned.
--  Workflow activity PL/SQL handler.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE update_resp_verf_failed(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_progress          VARCHAR2(3) := '000';
  l_parent_item_type  wf_items.parent_item_type%TYPE;
  l_parent_item_key   wf_items.parent_item_key%TYPE;
  l_api_name          VARCHAR2(500) := 'update_resp_verf_failed';
  l_log_head          VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Start');
  END IF;

  SELECT parent_item_type, parent_item_key
    INTO l_parent_item_type, l_parent_item_key
    FROM wf_items
   WHERE item_type = itemtype
     AND item_key = itemkey;

  l_progress := '020';

  po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                  itemkey  => l_parent_item_key,
                                  aname    => 'AME_SUB_APPROVAL_RESPONSE',
                                  avalue   => 'FAILED_VERIFICATION');
  resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED';

END update_resp_verf_failed;

--------------------------------------------------------------------------------
--Name: update_resp_verf_failed_reject
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function: This procedure sets AME_SUB_APPROVAL_RESPONSE with FALIED_VERIFICATION_REJECT.
--  Document in this case is not supposed to rejected.
--  Workflow activity PL/SQL handler.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE update_resp_verf_failed_reject(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_progress          VARCHAR2(3) := '000';
  l_parent_item_type  wf_items.parent_item_type%TYPE;
  l_parent_item_key   wf_items.parent_item_key%TYPE;
  l_api_name          VARCHAR2(500) := 'update_resp_verf_failed_reject';
  l_log_head          VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Start');
  END IF;

  SELECT parent_item_type, parent_item_key
    INTO l_parent_item_type, l_parent_item_key
    FROM wf_items
   WHERE item_type = itemtype
     AND item_key = itemkey;

  l_progress := '020';

  po_wf_util_pkg.SetItemAttrText( itemtype => l_parent_item_type,
                                  itemkey  => l_parent_item_key,
                                  aname    => 'AME_SUB_APPROVAL_RESPONSE',
                                  avalue   => 'FALIED_VERIFICATION_REJECT');

  --Bug#16569500, 16632623
  wf_engine.CompleteActivity(
    itemtype => l_parent_item_type,
    itemkey  => l_parent_item_key,
    activity => 'BLOCK',
    result   => NULL);

  resultout := wf_engine.eng_completed||':'||'ACTIVITY_PERFORMED';

END update_resp_verf_failed_reject;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_ame_sub_approval_response
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure is used to fetch workflow attribute AME_SUB_APPROVAL_RESPONSE.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_ame_sub_approval_response(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_ame_sub_approval_response VARCHAR2(50);
  l_progress                  VARCHAR2(3) := '000';
  l_api_name                  VARCHAR2(500) := 'get_ame_sub_approval_response';
  l_log_head                  VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Start');
  END IF;

  l_ame_sub_approval_response := po_wf_util_pkg.GetItemAttrText( aname => 'AME_SUB_APPROVAL_RESPONSE');

  resultout := wf_engine.eng_completed || ':' || l_ame_sub_approval_response;

END get_ame_sub_approval_response;

--------------------------------------------------------------------------------
--Start of Comments
--Name: update_action_history_reminder
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure updates the po_action_history with REMINDER based on no of reminder.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE update_action_history_reminder(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2)
IS
  l_no_of_reminder      NUMBER;
  l_progress            VARCHAR2(3) := '000';
  l_action              po_action_history.action_code%TYPE := NULL;
  l_current_approver    NUMBER;
  l_document_id         NUMBER;
  l_document_type       VARCHAR2(25);
  l_document_subtype    VARCHAR2(25);
  l_approval_group_id   NUMBER;
  l_org_id              NUMBER;
  l_draft_id            NUMBER;
  l_doc_string          VARCHAR2(200);
  l_preparer_user_name  fnd_user.user_name%TYPE;
  l_api_name            VARCHAR2(500) := 'update_action_history_reminder';
  l_log_head            VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Start');
  END IF;

  l_no_of_reminder := po_wf_util_pkg.GetItemAttrNumber( aname => 'NO_REMINDER');

  IF(l_no_of_reminder = 1) THEN
    l_action := 'FIRST REMINDER';
  ELSIF (l_no_of_reminder = 2) THEN
    l_action := 'SECOND REMINDER';
  END IF;

  l_current_approver  := po_wf_util_pkg.GetItemAttrNumber( aname=>'APPROVER_EMPID');
  l_document_id       := po_wf_util_pkg.GetItemAttrNumber( aname => 'DOCUMENT_ID');
  l_draft_id          := po_wf_util_pkg.GetItemAttrNumber( aname => 'DRAFT_ID');
  l_document_type     := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_TYPE');
  l_document_subtype  := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_SUBTYPE');
  l_approval_group_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'APPROVAL_GROUP_ID');
  l_org_id            := po_wf_util_pkg.GetItemAttrNumber( aname => 'ORG_ID');

  l_progress := '020';
  IF l_org_id IS NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_org_id);
  END IF;

  l_progress := '030';
  UpdateActionHistoryPoAme(
    p_document_id      => l_document_id,
    p_draft_id         => l_draft_id,
    p_document_type    => l_document_type,
    p_document_subtype => l_document_subtype,
    p_action           => l_action,
    p_note             => NULL,
    p_current_approver => l_current_approver);

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context(g_pkg_name, l_api_name, l_progress, sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, l_progress, l_document_id);
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
    END IF;
    RAISE;
END update_action_history_reminder;

--------------------------------------------------------------------------------
--Start of Comments
--Name: ame_is_forward_to_valid
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedure checks userame entered in the Forward-To field in response to the
--  the approval notification, a valid username. If not resend the
--  notification back to the user.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE ame_is_forward_to_valid(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2)
IS
  l_forward_to_username_response VARCHAR2(100);
  l_error_msg                    VARCHAR2(500);
  l_progress                     VARCHAR2(3) := '000';
  l_orgid                        NUMBER;
  x_user_id                      NUMBER;
  l_api_name                     VARCHAR2(500) := 'ame_is_forward_to_valid';
  l_log_head                     VARCHAR2(500) := g_module_prefix||l_api_name;
BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_progress := '010';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress||' Start');
  END IF;

  l_orgid := po_wf_util_pkg.GetItemAttrNumber ( aname => 'ORG_ID');

  IF l_orgid IS NOT NULL THEN
    po_moac_utils_pvt.set_org_context(l_orgid);
  END IF;

  --Check that the value entered by responder as the FORWARD-TO user, is actually
  --a valid employee (has an employee id).

  l_forward_to_username_response := po_wf_util_pkg.GetItemAttrText ( aname => 'FORWARD_TO_USERNAME_RESPONSE');
  l_forward_to_username_response := UPPER(l_forward_to_username_response);

  BEGIN
    SELECT HR.PERSON_ID
      INTO x_user_id
      FROM FND_USER FND, PO_WORKFORCE_CURRENT_X HR
     WHERE FND.USER_NAME = l_forward_to_username_response
       AND FND.EMPLOYEE_ID = HR.PERSON_ID
       AND ROWNUM = 1;

    fnd_message.set_name ('PO','PO_WF_NOTIF_REQUIRES_APPROVAL');
    l_error_msg := fnd_message.get;
    po_wf_util_pkg.SetItemAttrText ( aname => 'REQUIRES_APPROVAL_MSG' , avalue => l_error_msg);
    po_wf_util_pkg.SetItemAttrText ( aname => 'WRONG_FORWARD_TO_MSG' , avalue => '');
    resultout := wf_engine.eng_completed||':'||'Y';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    --+ Set the error message in WRONG_FORWARD_TO_MSG so that it will be shown to the user
    --+ Set the Subject of the Approval notification to "Invalid forward-to"
    --  since the user entered an invalid forward-to, then set the
    --  "requires your approval" message to NULL.
    fnd_message.set_name ('PO','PO_WF_NOTIF_INVALID_FORWARD');
    l_error_msg := fnd_message.get;
    po_wf_util_pkg.SetItemAttrText ( aname => 'REQUIRES_APPROVAL_MSG' , avalue => '');
    po_wf_util_pkg.SetItemAttrText ( aname => 'WRONG_FORWARD_TO_MSG' , avalue => l_error_msg);
    resultout := wf_engine.eng_completed || ':' || 'N';
  END;
END ame_is_forward_to_valid;

--------------------------------------------------------------------------------
--Start of Comments
--Name: abort_workflow
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This API aborts the workflow along with all the child workflows.
--Parameters:
--IN:
--itemtype
--itemkey
--OUT:
--x_return_message
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE abort_workflow(
		   itemtype         IN VARCHAR2,
           itemkey          IN VARCHAR2,
           x_return_message OUT NOCOPY VARCHAR2)
IS
pragma AUTONOMOUS_TRANSACTION;

l_log_head VARCHAR2(50) :=  g_module_prefix  || 'abort_workflow';

l_progress VARCHAR2(10);

CURSOR  wfstoabort(t_item_type VARCHAR2,t_item_key VARCHAR2) IS
SELECT LEVEL,
       item_type,
       item_key,
       end_date
FROM   wf_items
START WITH item_type = t_item_type
           AND item_key = t_item_key
CONNECT BY PRIOR item_type = parent_item_type
                 AND PRIOR item_key = parent_item_key
ORDER  BY LEVEL DESC;

wf_rec wfstoabort%ROWTYPE;

BEGIN

   open wfstoabort(itemtype,itemkey);
    loop
         fetch wfstoabort into wf_rec;
	         if wfstoabort%NOTFOUND then
	           close wfstoabort;
	           exit;
	          end if;

	 if (wf_rec.end_date is null) then

       IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt
            (p_log_head => l_log_head,
             p_token    => l_progress,
             p_message  => 'Aborting workflow : ' || wf_rec.item_type ||
                          ' - ' || wf_rec.item_key);
       END IF;

	   WF_Engine.AbortProcess(itemtype => wf_rec.item_type,
                            itemkey =>wf_rec.item_key,
                            verify_lock => TRUE );

	  end if;
	 end loop;
COMMIT;

EXCEPTION

WHEN OTHERS THEN
  ROLLBACK;
  x_return_message := 'Exception ' || SQLERRM || ' in abort_workflow';
     IF g_debug_stmt THEN
     	PO_DEBUG.debug_stmt
                    (p_log_head => l_log_head,
                     p_token    => l_progress,
                     p_message  => x_return_message);
       END IF;
  RAISE;
END abort_workflow;

--------------------------------------------------------------------------------
--Start of Comments
--Name: reset_authorization_status
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This API resets the authorization status to INCOMPLETE/REQUIRES REAPPROVAL.
-- Also resets all the required flags.
--Parameters:
--IN:
--p_document_id
--OUT:
--x_return_message
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE reset_authorization_status(
            p_document_id    IN NUMBER,
            p_item_type      IN VARCHAR2,
            p_item_key       IN VARCHAR2,
            x_return_message OUT NOCOPY VARCHAR2)
IS
pragma AUTONOMOUS_TRANSACTION;

l_log_head VARCHAR2(50) :=  g_module_prefix  || 'reset_authorization_status';
l_progress VARCHAR2(10);

BEGIN
       l_progress := '000';
       IF g_debug_stmt THEN
                 PO_DEBUG.debug_stmt
                    (p_log_head => l_log_head,
                     p_token    => l_progress,
                     p_message  => 'Updating authorization status of ' || p_document_id);
       END IF;

      UPDATE po_headers_all
      SET authorization_status = decode(approved_date, NULL, 'INCOMPLETE',
                                        'REQUIRES REAPPROVAL'),
          wf_item_type = p_item_type,
          wf_item_key = p_item_key,
	         approved_flag = decode(approved_date, NULL, 'N', 'R'),
          pending_signature_flag    = 'N',
          acceptance_required_flag  = 'N',
          acceptance_due_date       = Null,
          last_updated_by           = FND_GLOBAL.user_id,
          last_update_login         = FND_GLOBAL.login_id,
          last_update_date          = sysdate,
          ame_approval_id           = DECODE(ame_transaction_type,
		                                       NULL,NULL,
											   po_ame_approvals_s.NEXTVAL)
      WHERE po_header_id = p_document_id;

  COMMIT;

EXCEPTION

WHEN OTHERS THEN
  ROLLBACK;
  x_return_message := 'Exception ' || SQLERRM || ' in reset_authorization_status';
     IF g_debug_stmt THEN
     	PO_DEBUG.debug_stmt
                    (p_log_head => l_log_head,
                     p_token    => l_progress,
                     p_message  => x_return_message);
       END IF;
  RAISE;
END reset_authorization_status;

--------------------------------------------------------------------------------
--Start of Comments
--Name: send_withdraw_notification
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This API sends withdrawal notification.
--Parameters:
--IN:
--p_document_id
--p_document_num
--p_doc_type_disp
--p_from_user_name
--p_role - Role to which notififcation has to be sent.
--p_withdrawal_reason
--OUT:
--x_return_message
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE send_withdraw_notification(
            p_document_id       IN NUMBER,
            p_document_num      IN VARCHAR2,
            p_doc_type_disp     IN VARCHAR,
            p_from_user_name    IN VARCHAR,
            p_role              IN VARCHAR,
            p_withdrawal_reason IN VARCHAR2,
            p_view_po_url       IN VARCHAR2,
            p_edit_po_url       IN VARCHAR2)
IS
pragma AUTONOMOUS_TRANSACTION;

l_log_head VARCHAR2(50) :=  g_module_prefix  || 'send_withdraw_notification';
l_progress VARCHAR2(10);
l_notification_id NUMBER;

BEGIN

	l_notification_id := wf_notification.send(role =>p_role,
                                                msg_type => 'POAPPRV',
                                                msg_name => 'PO_WITHDRAWN');

    wf_notification.SetAttrText(nid =>l_notification_id,
                                  aname=> 'DOCUMENT_NUMBER',
                                  avalue =>p_document_num);

    wf_notification.SetAttrText(nid =>l_notification_id,
                                  aname=> 'DOCUMENT_TYPE_DISP',
                                  avalue =>p_doc_type_disp);

    wf_notification.SetAttrText(nid =>l_notification_id,
                                  aname=> '#FROM_ROLE',
                                  avalue =>p_from_user_name);

    wf_notification.SetAttrText(nid =>l_notification_id,
                                  aname=> 'NOTIFICATION_REGION',
                                  avalue =>'JSP:/OA_HTML/OA.jsp?OAFunc=PO_APPRV_NOTIF&poHeaderId=' || p_document_id);

    wf_notification.SetAttrText(nid =>l_notification_id,
                                  aname=> '#HISTORY',
                                  avalue =>'JSP:/OA_HTML/OA.jsp?OAFunc=PO_APPRV_NTF_ACTION_DETAILS&poHeaderId='
								            || p_document_id || '&showActions=Y');

    wf_notification.SetAttrText(nid =>l_notification_id,
                                  aname=> 'VIEW_DOC_URL',
                                  avalue =>p_view_po_url);

    wf_notification.SetAttrText(nid =>l_notification_id,
                                  aname=> 'EDIT_DOC_URL',
                                  avalue =>p_edit_po_url);

	IF g_debug_stmt THEN
      	PO_DEBUG.debug_stmt (p_log_head => l_log_head,
                     				 p_token    => l_progress,
                     				 p_message  => 'Sending notification ' || l_notification_id ||
                                            ' to ' || p_role);
    END IF;
  COMMIT;

EXCEPTION

WHEN OTHERS THEN
  ROLLBACK;
     IF g_debug_stmt THEN
     	PO_DEBUG.debug_stmt
                    (p_log_head => l_log_head,
                     p_token    => l_progress,
                     p_message  => 'Exception ' || SQLERRM || ' while sending notification to ' || p_role);
       END IF;
END send_withdraw_notification;

--------------------------------------------------------------------------------
--Start of Comments
--Name: notify_abt_withdrawal
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This API identifies all the approvers, buyer and supplier if acceptances exist
-- and calls send_withdraw_notification
--Parameters:
--IN:
--p_document_id
--p_from_user_name
--p_withdrawal_reason
--OUT:
--x_return_message
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE notify_abt_withdrawal(
            p_document_id IN NUMBER,
	    p_document_type IN VARCHAR2, --Bug 17720293
            p_from_user_name IN VARCHAR,
            p_withdrawal_reason IN VARCHAR2,
			         p_view_po_url  IN VARCHAR2,
			         p_edit_po_url  IN VARCHAR2)
IS

l_log_head VARCHAR2(50) :=  g_module_prefix  || 'notify_abt_withdrawal';
l_progress VARCHAR2(10);
l_emp_user_name VARCHAR2(100);
l_emp_disp_name VARCHAR2(240);
l_supplier_contact_id NUMBER;
l_acceptance_id NUMBER;
l_document_number po_headers_all.segment1%TYPE;
l_doc_type_disp VARCHAR2(240);
l_notification_id NUMBER;
l_supp_contact_email  VARCHAR2(200);
l_supp_contact_user_name VARCHAR2(100);

/*
Bug 17720293 fix: Added additional parameter p_doc_type to fetch the users associated to
the PO/PA only.
*/
CURSOR employee_to_send_notif(p_po_header_id NUMBER, p_doc_type VARCHAR2) IS
SELECT DISTINCT poh.employee_id
FROM   po_action_history poh
WHERE  poh.object_id = p_po_header_id
       AND poh.object_type_code = p_doc_type
       AND poh.employee_id IS NOT NULL
       AND poh.sequence_num >= (SELECT MAX(sequence_num)
                                FROM   po_action_history poh1
                                WHERE  poh1.object_id = p_po_header_id
                                       AND poh1.object_type_code = p_doc_type
                                       AND poh1.action_code = 'SUBMIT')
UNION
SELECT agent_id
FROM po_headers_all
WHERE po_header_id = p_po_header_id;

emp_rc employee_to_send_notif%ROWTYPE;

BEGIN

    l_progress := '000';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(p_log_head => l_log_head );
        PO_DEBUG.debug_stmt
            (p_log_head => l_log_head,
             p_token    =>l_progress,
             p_message  => 'In notify_abt_withdrawal');

    END IF;

  SELECT segment1
  INTO   l_document_number
  FROM   po_headers_all
  WHERE  po_header_id = p_document_id;

   l_progress := '001';

  l_doc_type_disp:= PO_DOC_STYLE_PVT.get_style_display_name(p_document_id);

   l_progress := '002';

   OPEN employee_to_send_notif(p_document_id, p_document_type); --Bug 17720293 fix
   LOOP
		FETCH employee_to_send_notif INTO emp_rc;

			IF employee_to_send_notif%NOTFOUND THEN
					CLOSE employee_to_send_notif;
					EXIT;
			END IF;

			PO_REQAPPROVAL_INIT1.get_user_name(emp_rc.employee_id , l_emp_user_name, l_emp_disp_name);

            l_progress := '003';
            IF g_debug_stmt THEN
                PO_DEBUG.debug_begin(p_log_head => l_log_head );
                PO_DEBUG.debug_stmt
                    (p_log_head => l_log_head,
                     p_token    => l_progress,
                     p_message  => 'Calling send withdraw notifictaion to ' || l_emp_user_name );
            END IF;

            send_withdraw_notification(p_document_id => p_document_id,
                                       p_document_num => l_document_number,
                                       p_doc_type_disp => l_doc_type_disp,
                                       p_from_user_name => p_from_user_name,
                                       p_role => l_emp_user_name,
                                       p_withdrawal_reason => p_withdrawal_reason,
               	   					               p_view_po_url => p_view_po_url,
							                                p_edit_po_url => p_edit_po_url);
  END LOOP;

  -- Check whether any acceptance is recorded by supplier, if yes send supplier contact id notification
  l_progress := '004';

  BEGIN
	SELECT acceptance_id
    INTO l_acceptance_id
 	  FROM po_acceptances
  	WHERE po_header_id=p_document_id;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(p_log_head => l_log_head );
        PO_DEBUG.debug_stmt
            (p_log_head => l_log_head,
             p_token    => l_progress,
             p_message  => 'l_acceptance_id ' || l_acceptance_id );
    END IF;

    SELECT psc.user_name
    INTO l_supp_contact_user_name
    FROM po_supplier_contacts_val_v psc,
         po_headers_all poh
    WHERE psc.vendor_contact_id= poh.vendor_contact_id
    AND psc.vendor_site_id= poh.vendor_site_id
    AND po_header_id=p_document_id;

    l_progress := '005';

    IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(p_log_head => l_log_head );
        PO_DEBUG.debug_stmt
            (p_log_head => l_log_head,
             p_token    => l_progress,
             p_message  => 'l_supp_contact_user_name ' || l_supp_contact_user_name );
    END IF;

    IF l_supp_contact_user_name IS NOT NULL THEN
            send_withdraw_notification( p_document_id => p_document_id,
                                 p_document_num => l_document_number,
                                 p_doc_type_disp => l_doc_type_disp,
                                 p_from_user_name => p_from_user_name,
                                 p_role => l_supp_contact_user_name,
                                 p_withdrawal_reason => p_withdrawal_reason,
								                         p_view_po_url => p_view_po_url,
							                          p_edit_po_url => p_edit_po_url);
    END IF;

 	EXCEPTION
    WHEN NO_DATA_FOUND THEN
      	IF g_debug_stmt THEN
      		PO_DEBUG.debug_stmt (p_log_head => l_log_head,
                     				 	 p_token    => l_progress,
                     				   p_message  => 'Need not send notifictaion to Supplier');
      	END IF;
  END;

EXCEPTION

WHEN OTHERS THEN
     IF g_debug_stmt THEN
     	PO_DEBUG.debug_stmt
                    (p_log_head => l_log_head,
                     p_token    => l_progress,
                     p_message  => 'Exception ' || SQLERRM || ' in notify_abt_withdrawal');
       END IF;
END notify_abt_withdrawal;

-- Add For Bug 18301936, delete attachment while withdraw document
PROCEDURE withdraw_delete_attachment(
  p_document_id         IN NUMBER,
	p_document_type       IN VARCHAR2,
	p_document_sub_type   IN VARCHAR2,
	p_revision_num        IN NUMBER
	)
IS
  l_log_head    VARCHAR2(100) := g_module_prefix || 'withdraw_delete_attachment';
  l_progress    VARCHAR2(10);
  l_entity_name VARCHAR2(30);
BEGIN
  l_progress := '000';
  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(p_log_head => l_log_head );
    PO_DEBUG.debug_stmt(p_log_head => l_log_head,
                        p_token => l_progress,
                        p_message => 'document_type: ' || p_document_type ||
                                     ' document_sub_type ' || p_document_sub_type ||
                                     ' document_id : ' || p_document_id ||
                                     ' revision_num : ' || p_revision_num);
  END IF;
  IF p_document_type IN ('PO', 'PA') AND p_document_sub_type IN ('STANDARD', 'BLANKET', 'CONTRACT') THEN
    l_entity_name      := 'PO_HEAD';
  ELSIF p_document_type = 'RELEASE' AND p_document_sub_type = 'BLANKET' THEN
    l_entity_name      := 'PO_REL';
  END IF;
  l_progress := '002';
  IF g_debug_stmt THEN
    PO_DEBUG.debug_stmt(p_log_head => l_log_head, p_token => l_progress, p_message => 'entity_name: ' || l_entity_name);
  END IF;
  FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(X_entity_name => l_entity_name,
                                                 X_pk1_value => TO_CHAR(p_document_id),
                                                 X_pk2_value => TO_CHAR(p_revision_num),
                                                 X_pk3_value => NULL,
                                                 X_pk4_value => NULL,
                                                 X_pk5_value => NULL,
                                                 X_delete_document_flag => 'Y',
                                                 X_automatically_added_flag => 'N');
  l_progress := '003';
EXCEPTION
WHEN OTHERS THEN
  IF g_debug_stmt THEN
    PO_DEBUG.debug_stmt(p_log_head => l_log_head, p_token => l_progress, p_message => 'Exception: ' || 'Withdraw Delete PDF attachment.');
  END IF;
  raise;
END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: withdraw_document
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This API withdraws document.
--Parameters:
--IN:
--p_document_id
--p_draft_id
--p_document_type
--p_document_sub_type
--p_revision_num
--p_current_employee_id
--p_note
--OUT:
--x_return_status
--x_return_message
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE withdraw_document(
            p_document_id         IN NUMBER,
            p_draft_id            IN NUMBER,
            p_document_type       IN VARCHAR2,
            p_document_sub_type   IN VARCHAR2,
            p_revision_num        IN NUMBER,
            p_current_employee_id IN NUMBER,
            p_note                IN VARCHAR2,
            x_return_status       OUT NOCOPY VARCHAR2,
            x_return_message      OUT NOCOPY VARCHAR2) IS

l_log_head                 VARCHAR2(50) :=  g_module_prefix  || 'withdraw_document';
l_progress                 VARCHAR2(10);
l_item_type                wf_items.item_type%TYPE;
l_item_key                 wf_items.item_key%TYPE;
l_note                     po_action_history.note%TYPE;
l_current_user_name        VARCHAR2(100);
l_disp_name                VARCHAR2(240);
l_send_notf_flag           VARCHAR2(1);
l_view_po_url              VARCHAR2(1000);
l_edit_po_url              VARCHAR2(1000);

BEGIN

    l_progress := '000';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(p_log_head => l_log_head );
        PO_DEBUG.debug_stmt
            (p_log_head => l_log_head,
             p_token    => l_progress,
             p_message  => 'document_type: ' || p_document_type ||
                          ' document_sub_type ' || p_document_sub_type
                           ||' document_id : ' || p_document_id
                           || ' current_employee_id ' || p_current_employee_id);

    END IF;

    -- Logic :
    -- + Get all the required values
    -- + Supress existing approvers in AME.
    -- + Abort the approval workflow
    -- + Update the authorization status
    -- + Update the action history
    -- + Notify all approvers if Send notification
    --  to all approvers is selected in the style

    SELECT wf_item_type, wf_item_key
    INTO l_item_type,l_item_key
    FROM po_headers_all
    WHERE po_header_id = p_document_id;

     l_progress := '001';

    IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(p_log_head => l_log_head );
        PO_DEBUG.debug_stmt
            (p_log_head => l_log_head,
             p_token    => l_progress,
             p_message  => 'itemkey is  ' || l_item_key);
    END IF;

    PO_REQAPPROVAL_INIT1.get_user_name(p_current_employee_id, l_current_user_name, l_disp_name);

    l_progress := '002';

    IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(p_log_head => l_log_head );
        PO_DEBUG.debug_stmt
            (p_log_head => l_log_head,
             p_token    => l_progress,
             p_message  => 'Current user is ' || l_current_user_name);
    END IF;

  	l_view_po_url := PO_WF_UTIL_PKG.GetItemAttrText ( itemtype   => l_item_type,
                                      itemkey    => l_item_key,
                                      aname      => 'VIEW_DOC_URL');

    l_edit_po_url:= PO_WF_UTIL_PKG.GetItemAttrText ( itemtype   => l_item_type,
                                      itemkey    => l_item_key,
                                      aname      => 'EDIT_DOC_URL' );
    BEGIN
 	  supress_existing_approvers(
        itemtype => l_item_type,
        itemkey  => l_item_key);
    EXCEPTION
	WHEN OTHERS THEN
	  NULL;
	END;

    -- Add For Bug 18301936, delete attachment while withdraw document
    withdraw_delete_attachment(p_document_id => p_document_id,
                               p_document_type => p_document_type,
                               p_document_sub_type => p_document_sub_type,
                               p_revision_num => p_revision_num );

    abort_workflow(itemtype => l_item_type,
                   itemkey => l_item_key,
                   x_return_message => x_return_message);

    l_progress := '003';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(p_log_head => l_log_head );
        PO_DEBUG.debug_stmt
            (p_log_head => l_log_head,
             p_token    => l_progress,
             p_message  => 'Successfully aborted workflow' );
    END IF;

    reset_authorization_status(
      p_document_id => p_document_id,
      p_item_type   => NULL,
      p_item_key    => NULL,
     x_return_message => x_return_message);

    l_progress := '004';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(p_log_head => l_log_head );
        PO_DEBUG.debug_stmt
            (p_log_head => l_log_head,
             p_token    => l_progress,
             p_message  => 'Authorization status update complete' );
    END IF;

     l_note :=  fnd_message.get_string('PO','PO_ACTION_HIST_WITHDRAW_NOTE');
     UpdateActionHistoryPoAme(
	   p_document_id      => p_document_id,
       p_draft_id         => p_draft_id,
       p_document_type    => p_document_type,
       p_document_subtype => p_document_sub_type,
       p_action           => 'NO ACTION',
       p_note             => l_note,
       p_current_approver => NULL);

    l_progress := '005';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(p_log_head => l_log_head );
        PO_DEBUG.debug_stmt
            (p_log_head => l_log_head,
             p_token    => l_progress,
             p_message  => 'Updated the existing NULL actions with NO ACTION');
    END IF;

     InsertActionHistoryPoAme (
	   p_document_id       => p_document_id,
       p_draft_id          => p_draft_id,
       p_document_type     => p_document_type,
       p_document_subtype  => p_document_sub_type,
		p_revision_num     => p_revision_num,
       p_employee_id       => p_current_employee_id,
       p_approval_group_id => NULL,
       p_action            => 'WITHDRAW',
       p_note              => p_note);

    l_progress := '006';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(p_log_head => l_log_head );
        PO_DEBUG.debug_stmt
            (p_log_head => l_log_head,
             p_token    => l_progress,
             p_message  => 'Inserted WITHDRAW action in action history');
    END IF;

    BEGIN
      SELECT nvl(SEND_WITHDRW_NOTF_FLAG,'N')
      INTO   l_send_notf_flag
      FROM   po_doc_style_headers ds,
             po_headers_all poh
      WHERE  poh.po_header_id = p_document_id
             AND poh.style_id = ds.style_id;
    EXCEPTION
        when others then
           l_send_notf_flag := 'N';
    END;

    l_progress := '007';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(p_log_head => l_log_head );
        PO_DEBUG.debug_stmt
            (p_log_head => l_log_head,
             p_token    => l_progress,
             p_message  => 'l_send_notf_flag : ' || l_send_notf_flag);
    END IF;

    IF(l_send_notf_flag = 'Y') THEN

        notify_abt_withdrawal(
          p_document_id       => p_document_id,
          p_document_type     => p_document_type, -- Bug 17720293 fix
          p_from_user_name    => l_current_user_name,
          p_withdrawal_reason => p_note,
          p_view_po_url       => l_view_po_url,
          p_edit_po_url       => l_edit_po_url);

        l_progress := '008';
        IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(p_log_head => l_log_head );
        PO_DEBUG.debug_stmt
            (p_log_head => l_log_head,
             p_token    => l_progress,
             p_message  => 'Notified all approvers');
        END IF;

    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.set_name('PO', 'PO_UNABLE_TO_WITHDRAW');
    FND_MESSAGE.set_token('ERR_MESSAGE', x_return_message);
    x_return_message := FND_MESSAGE.get;
    IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(p_log_head => l_log_head );
        PO_DEBUG.debug_stmt
            (p_log_head => l_log_head,
             p_token    => l_progress,
             p_message  => x_return_message);
    END IF;
END withdraw_document;

--------------------------------------------------------------------------------
--Start of Comments
--Name: check_set_esigners
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This is uesd to determine whether approver is post-approver or not.
--  And then correspondingly set values for attribute E_SIGNER_EXISTS as Y or N.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--  None
--End of Comments
---------------------------------------------------------------------------------

FUNCTION check_set_esigners(
           itemtype       IN VARCHAR2,
           itemkey        IN VARCHAR2)
RETURN VARCHAR2
IS
  l_approver_index                NUMBER;
  e_signer_flag                   VARCHAR2(1);
  l_transaction_type        po_document_types.ame_transaction_type%TYPE;
  l_ame_transaction_id      NUMBER;
  l_api_name                      VARCHAR2(500) := 'check_set_esigners';
  l_log_head                      VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN

  -- Logic :
  -- + Check whether approver is post approver or not. Post approvers are signers.
  --   approverRecord.authority = 'X' for Pre-approvers
  --   approverRecord.authority = 'Y' for Approvers
  --   approverRecord.authority = 'Z' for Post-Approvers(signers)
  -- + If e-signer exists, then set workflow attribute 'E_SIGNER_EXISTS' as Y.
  --   Also update ame for current set approver with approval status as NULL, so that
  --   they would be fetched next time in getNextApprovers(..) for E-Signer looping.

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  IF (g_po_wf_debug = 'Y') THEN
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_log_head || ' 001 ');
  END IF;

  l_ame_transaction_id := po_wf_util_pkg.GetItemAttrNumber(aname => 'AME_TRANSACTION_ID');
  l_transaction_type := po_wf_util_pkg.GetItemAttrText( aname => 'AME_TRANSACTION_TYPE');

  e_signer_flag := 'N';
  l_approver_index := g_next_approvers.first();

  -- Bug 17621368
  -- Checking for API Inserion
  -- Should not treat adhoc approver as esigner
  -- when there are no rule generated approvers in the set.

  WHILE ( l_approver_index IS NOT NULL ) LOOP
    IF (g_next_approvers(l_approver_index).authority = 'Z'
        AND e_signer_flag = 'N'
	AND g_next_approvers(l_approver_index).api_insertion <> ame_util.apiInsertion) THEN
  	  po_wf_util_pkg.SetItemAttrText (aname => 'E_SIGNER_EXISTS', avalue => 'Y');
	  e_signer_flag :='Y';
	  EXIT;
	END IF;
    l_approver_index := g_next_approvers.next(l_approver_index);
 END LOOP;

 IF(e_signer_flag = 'Y') THEN
   l_approver_index := g_next_approvers.first();
   WHILE ( l_approver_index IS NOT NULL ) LOOP
      g_next_approvers(l_approver_index).approval_status := ame_util.nullStatus;
      ame_api2.updateApprovalStatus ( applicationIdIn => applicationId,
                                    transactionIdIn => l_ame_transaction_id,
                                    transactionTypeIn => l_transaction_type,
                                    approverIn => g_next_approvers(l_approver_index),
                                    updateItemIn => TRUE);
       IF (g_po_wf_debug = 'Y') THEN
	 PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||' 002 :'||' updated ame for '||
		                       g_next_approvers(l_approver_index).name || ' with null status');
       END IF;
    l_approver_index := g_next_approvers.next(l_approver_index);
   END LOOP;
 END IF;

  IF (g_po_wf_debug = 'Y') THEN
   PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_log_head || ' return e_signer_flag=' || e_signer_flag);
  END IF;

 RETURN e_signer_flag;
END check_set_esigners;

--------------------------------------------------------------------------------
--Start of Comments
--Name: is_fyi_approver
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This is uesd to determine whether approver is FYI approver or not.
--  Values can be Y or N.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--  None
--End of Comments
---------------------------------------------------------------------------------
PROCEDURE is_fyi_approver(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2)
IS
  l_is_fyi_approver   VARCHAR2(1);
BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  --Logic is check first for workflow attribute 'IS_FYI_APPROVER', then attribute 'APPROVER_CATEGORY'
  --Fetch 'IS_FYI_APPROVER' value which is set in launch_parralel_approval
  l_is_fyi_approver := po_wf_util_pkg.GetItemAttrText (aname => 'IS_FYI_APPROVER');

  IF l_is_fyi_approver = 'Y' THEN
    resultout := wf_engine.eng_completed || ':' || 'Y';
  ELSE
    resultout := wf_engine.eng_completed || ':' || 'N';
  END IF;

END is_fyi_approver;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_current_future_approvers
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This function returns current/future approvers for a particular
-- AME transaction id/type.
--Parameters:
--IN:
-- transactionType
-- transactionId
--RETURNS:
--  po_ame_approver_tab
--End of Comments
---------------------------------------------------------------------------------
FUNCTION get_current_future_approvers(
            transactionType IN   VARCHAR2,
            transactionId   IN   NUMBER)
RETURN po_ame_approver_tab
IS

  l_is_last_approver_record VARCHAR2(1);
  l_total_approver_count    NUMBER;
  l_current_approver_index  NUMBER;
  ApproverList           ame_util.approversTable2;
  xprocess_out             VARCHAR2(10);
  xitemIndexesOut                 ame_util.idList;
  xitemClassesOut                 ame_util.stringList;
  xitemIdsOut                     ame_util.stringList;
  xitemSourcesOut                 ame_util.longStringList;
  xtransVariableNamesOut          ame_util.stringList;
  xtransVariableValuesOut         ame_util.stringList;
  xproduction_Indexes        ame_util.idList;
  xvariable_Names            ame_util.stringList;
  xvariable_Values           ame_util.stringList;
  l_next_approver_id            NUMBER;
  l_next_approver_name          per_employees_current_x.full_name%TYPE;
  l_next_approver_user_name     VARCHAR2(100);
  l_next_approver_disp_name     VARCHAR2(240);
  l_approver_category VARCHAR2(100);
  l_approver_order_number NUMBER;
  l_approver_index NUMBER;
  l_is_current_approver varchar2(1);
  l_log_head VARCHAR2(500);
  l_progress VARCHAR2(10);
  x_approver_tab PO_AME_APPROVER_TAB;

  --Bug 17621368
  l_esigner_exists VARCHAR2(1) := 'N';
  l_esigner_index  NUMBER;

BEGIN

  l_log_head := g_module_prefix  || 'get_current_future_approvers';

  l_progress := '000';
  IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(p_log_head => l_log_head );
      PO_DEBUG.debug_stmt
          (p_log_head => l_log_head,
           p_token    => l_progress,
           p_message  => 'transactionType: ' || transactionType ||
                        ' transactionId ' || transactionId);

  END IF;

  x_approver_tab := PO_AME_APPROVER_TAB();

  l_progress := '001';

  -- Logic - Loop through all the approvers returned by AME API - getAllApprovers3
  -- If the approval_status of a particualr approver is NULL then it is a future approver.
  -- If the approval_status is NOTIFIED then it is a current approver.
  -- Get the person name based on orig_system -> PER/POS/FND USER
  -- Get the approver category by checking production indexes - Reviewer,
  -- Post approval group - Signer else Approver.
  -- Populate the plsql table po_ame_approver_tab.

  ame_api2.getAllApprovers3(applicationIdIn => applicationId,
                             transactionTypeIn => transactionType,
                             transactionIdIn => transactionId,
                             approvalProcessCompleteYNOut => xprocess_out,
                             approversOut => ApproverList,
                             itemIndexesOut => xitemIndexesOut,
                             itemClassesOut => xitemClassesOut,
                             itemIdsOut => xitemIdsOut,
                             itemSourcesOut => xitemSourcesOut,
                             productionIndexesOut =>xproduction_Indexes,
                             variableNamesOut => xvariable_Names,
                             variableValuesOut => xvariable_Values,
                             transVariableNamesOut => xtransVariableNamesOut,
                             transVariableValuesOut => xtransVariableValuesOut);

  l_progress := '002';

 l_approver_index := ApproverList.first;

  WHILE (l_approver_index IS NOT NULL) LOOP

   BEGIN

   l_progress := '003';

   IF ( ApproverList(l_approver_index).approval_status IS NULL
     OR  ApproverList(l_approver_index).approval_status = ame_util.notifiedStatus)
   THEN

       l_progress := '004';

	   --Get the Order No.
       l_approver_order_number := ApproverList(l_approver_index).approver_order_number;

	  l_progress := '005';
	  -- Get the Approver Name
       IF (ApproverList(l_approver_index).orig_system = ame_util.perorigsystem) THEN

         l_next_approver_id := ApproverList(l_approver_index).orig_system_id;

       ELSIF (ApproverList(l_approver_index).orig_system = ame_util.posorigsystem) THEN

		   -----------------------------------------------------------------------
           -- SQL What: Get the person assigned to position returned by AME.
           -- SQL Why : When AME returns position id, then using this sql we find
           --           one person assigned to this position and use this person
		   --           as approver.
           -----------------------------------------------------------------------
           SELECT person_id , full_name
             INTO l_next_approver_id, l_next_approver_name
             FROM ( SELECT person.person_id , person.full_name
                      FROM per_all_people_f person ,
                           per_all_assignments_f asg ,
						   wf_users wu
                     WHERE asg.position_id = ApproverList(l_approver_index).orig_system_id
					   AND wu.orig_system     = ame_util.perorigsystem
                       AND wu.orig_system_id  = person.person_id
                       AND TRUNC (sysdate) BETWEEN person.effective_start_date AND NVL (person.effective_end_date ,TRUNC (sysdate))
                       AND person.person_id = asg.person_id
                       AND asg.primary_flag = 'Y'
                       AND asg.assignment_type IN ('E','C')
                       AND ( person.current_employee_flag = 'Y' OR person.current_npw_flag = 'Y' )
                       AND asg.assignment_status_type_id NOT IN
                                            ( SELECT assignment_status_type_id
                                                FROM per_assignment_status_types
                                               WHERE per_system_status = 'TERM_ASSIGN'
                                             )
                       AND TRUNC (sysdate) BETWEEN asg.effective_start_date AND asg.effective_end_date
                     ORDER BY person.last_name )
            WHERE ROWNUM = 1;

       ELSIF (ApproverList(l_approver_index).orig_system = ame_util.fnduserorigsystem) THEN
           SELECT employee_id
             INTO l_next_approver_id
             FROM fnd_user
            WHERE user_id = ApproverList(l_approver_index).orig_system_id
              AND TRUNC (sysdate) BETWEEN start_date AND NVL (end_date ,sysdate + 1);
       END IF;

       wf_directory.getusername (ame_util.perorigsystem, l_next_approver_id, l_next_approver_user_name, l_next_approver_disp_name);

       IF (ApproverList(l_approver_index).orig_system = ame_util.perorigsystem) THEN
          l_next_approver_disp_name := ApproverList(l_approver_index).display_name;
       END IF;

	   l_progress := '006';
	   -- Get the Approver category
       l_approver_category := null;
	   IF ApproverList(l_approver_index).approver_category = ame_util.fyiapprovercategory then
		   l_approver_category := 'FYI_APPROVER';

	   ELSE

       IF (xproduction_Indexes.Count > 0) THEN
         FOR j IN 1..xproduction_Indexes.Count LOOP
           IF xproduction_Indexes(j) = l_approver_index THEN
             IF xvariable_Names(j) = 'REVIEWER' AND xvariable_Values(j)= 'YES' THEN
               l_approver_category := 'REVIEWER';
             END IF;
           END IF;
         END LOOP;
       END IF;

       IF (l_approver_category is null) then
         IF (ApproverList(l_approver_index).authority = 'Z') THEN

	    -- Bug 17621368
	    -- Checking for API Inserion
	    -- Should not treat adhoc approver as esigner
	    -- when there are no rule generated approvers in the set.

	    IF l_esigner_exists = 'N' THEN
                l_esigner_index := l_approver_index;
		WHILE l_esigner_index IS NOT NULL
		LOOP
		   IF ApproverList(l_esigner_index).approver_order_number > l_approver_order_number THEN
		      EXIT;
                   ELSIF ApproverList(l_esigner_index).api_insertion <> ame_util.apiInsertion THEN
		      l_esigner_exists := 'Y';
		      EXIT;
		   END IF;
		   l_esigner_index := ApproverList.next (l_esigner_index);
		END LOOP;
	    END IF;

	    IF l_esigner_exists = 'Y' THEN
               l_approver_category := 'ESIGNER';
	    ELSE
	       l_approver_category := 'APPROVER';
	    END IF;
         ELSE
           l_approver_category := 'APPROVER';
         END IF;
       END IF;

	   END IF;

	   BEGIN
         SELECT displayed_field
           INTO l_approver_category
         FROM po_lookup_codes
           WHERE  lookup_type = 'PO_APPROVER_TYPE'
           AND lookup_code = l_approver_category;
       EXCEPTION
	   WHEN no_data_found THEN
         l_approver_category := NULL;
	   END;

	  l_progress := '007';
       -- Identify if it is current approver
       IF(ApproverList(l_approver_index).approval_status = ame_util.notifiedStatus
	      AND ApproverList(l_approver_index).approver_category <> ame_util.fyiapprovercategory)THEN
           l_is_current_approver := 'Y';
       ELSE
           l_is_current_approver := 'N';
       END IF;

       l_progress := '008';

	   IF NOT(ApproverList(l_approver_index).approver_category = ame_util.fyiapprovercategory
	        AND Nvl(ApproverList(l_approver_index).approval_status,-1) = ame_util.notifiedStatus) THEN

	   -- Insert record in x_approver_tab
       x_approver_tab.extend;
       x_approver_tab (x_approver_tab.last) := PO_AME_APPROVER_REC(l_approver_order_number,
                                                                   l_next_approver_disp_name,
                                                                   l_approver_category,
                                                                   l_is_current_approver);

       END IF;

    END IF;

	l_progress := '009';
    l_approver_index := ApproverList.next (l_approver_index);

    EXCEPTION
      WHEN OTHERS THEN
         IF g_debug_stmt THEN
            PO_DEBUG.debug_begin(p_log_head => l_log_head );
            PO_DEBUG.debug_stmt
            (p_log_head => l_log_head,
             p_token    => l_progress,
             p_message  => 'Exception ' || sqlerrm);
         END IF;

         l_approver_index := ApproverList.next (l_approver_index);

         --bug 16168369
         --Remove 'CONTINUE' as for Oracle 10g it's not compatible
         --CONTINUE ;
    END;

  END LOOP;

  l_progress := '010';

RETURN x_approver_tab;

EXCEPTION

WHEN OTHERS THEN

    IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(p_log_head => l_log_head );
        PO_DEBUG.debug_stmt
            (p_log_head => l_log_head,
             p_token    => l_progress,
             p_message  => 'Exception ' || sqlerrm);
    END IF;

    RETURN x_approver_tab;

END get_current_future_approvers;
--------------------------------------------------------------------------------
--Start of Comments
--Name: set_esigner_response_accepted
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This is uesd to set ESIGNER_RESPONSE to accepted
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--  None
--End of Comments
---------------------------------------------------------------------------------
PROCEDURE set_esigner_response_accepted(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2)
IS
BEGIN
  -- Logic :
  --  + Set worflow attribute for 'ESIGNER_RESPONSE' as ACCEPTED

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  po_wf_util_pkg.SetItemAttrText (aname => 'ESIGNER_RESPONSE', avalue => 'ACCEPTED');
  resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED';

END set_esigner_response_accepted;

--------------------------------------------------------------------------------
--Start of Comments
--Name: set_esigner_response_rejected
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This is uesd to set ESIGNER_RESPONSE to rejected
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--  None
--End of Comments
---------------------------------------------------------------------------------
PROCEDURE set_esigner_response_rejected(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2)
IS
BEGIN
  -- Logic :
  --  + Set worflow attribute for 'ESIGNER_RESPONSE' as REJECTED

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  po_wf_util_pkg.SetItemAttrText (aname => 'ESIGNER_RESPONSE', avalue => 'REJECTED');
  resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED';

END set_esigner_response_rejected;

-------------------------------------------------------------------------------
--Start of Comments
--Name: create_erecord
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Calls the APIs given by eRecords product team to store the signature
--  notification as an eRecord
--Parameters:
--IN:
--itemtype
--  Standard parameter to be used in a workflow procedure
--itemkey
--  Standard parameter to be used in a workflow procedure
--actid
--  Standard parameter to be used in a workflow procedure
--funcmode
--  Standard parameter to be used in a workflow procedure
--OUT:
--resultout
--  Standard parameter to be used in a workflow procedure
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE create_erecord(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2)
IS
  l_signature_id        NUMBER;
  l_evidence_store_id	NUMBER;
  l_notif_id 	        NUMBER;
  l_erecord_id 	        NUMBER;
  l_doc_parameters	    PO_ERECORDS_PVT.Params_tbl_type;
  l_sig_parameters	    PO_ERECORDS_PVT.Params_tbl_type;
  l_document_id 	    PO_HEADERS.po_header_id%TYPE;
  l_user_name 	        FND_USER.user_name%TYPE;
  l_requester 	        FND_USER.user_name%TYPE;
  l_esigner_response	VARCHAR2(20);
  l_response	        VARCHAR2(20);
  l_event_name          VARCHAR2(50);
  l_acceptance_note	    PO_ACCEPTANCES.note%TYPE;
  l_document_number     PO_HEADERS_ALL.segment1%TYPE;
  l_orgid               PO_HEADERS_ALL.org_id%TYPE;
  l_revision            PO_HEADERS_ALL.revision_num%TYPE;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_doc_string          VARCHAR2(200);
  l_preparer_user_name  WF_USERS.name%TYPE;
  l_trans_status        VARCHAR2(10);
  l_response_code       FND_LOOKUP_VALUES.meaning%TYPE;
  l_reason_code         FND_LOOKUP_VALUES.meaning%TYPE;
  l_signer_type         FND_LOOKUP_VALUES.meaning%TYPE;
  l_signer              VARCHAR2(10);
  l_erecords_exception  EXCEPTION;
  l_api_name            VARCHAR2(500) := 'CREATE_ERECORD';
  l_log_head            VARCHAR2(500) := g_module_prefix||l_api_name;
BEGIN
  -- Logic :
  -- + Call PO_ERECORDS_PVT.capture_signature to capture signature.
  -- + Call PO_ERECORDS_PVT.send_ackn to send acknowledgement.
  -- + Set ERECORD_ID and SIG_ID workflow attributes.

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  IF (g_po_wf_debug = 'Y') THEN
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_log_head || ' 001 ');
  END IF;

  l_document_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'DOCUMENT_ID');
  l_acceptance_note := PO_WF_UTIL_PKG.GetItemAttrText ( aname => 'SIGNATURE_COMMENTS');
  l_esigner_response := PO_WF_UTIL_PKG.GetItemAttrText ( aname => 'ESIGNER_RESPONSE');
  l_orgid := po_wf_util_pkg.GetItemAttrNumber (aname => 'ORG_ID');
  l_document_number := PO_WF_UTIL_PKG.GetItemAttrText( aname => 'DOCUMENT_NUMBER');
  l_revision := PO_WF_UTIL_PKG.GetItemAttrText( aname    => 'REVISION_NUMBER');

  l_signer := 'BUYER';
  l_event_name := 'oracle.apps.po.buyersignature';

  l_user_name := FND_GLOBAL.user_name;
  l_requester := PO_WF_UTIL_PKG.GetItemAttrText (aname    => 'BUYER_USER_NAME');
     --Get the Notification Id of the recent Signature Notification into l_notif_id.
  l_notif_id := po_wf_util_pkg.GetItemAttrNumber (aname    => 'NOTIFICATION_ID');


  BEGIN
      SELECT displayed_field
        INTO l_response_code
        FROM Po_Lookup_Codes
       WHERE Lookup_Type = 'ERECORD_RESPONSE'
         AND Lookup_Code = l_esigner_response;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_response_code := NULL;
  END;

  BEGIN
      SELECT displayed_field
        INTO l_reason_code
        FROM Po_Lookup_Codes
       WHERE Lookup_Type = 'ERECORD_REASON'
         AND Lookup_Code = 'ERES_REASON';
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_reason_code := NULL;
  END;

  BEGIN
      SELECT displayed_field
        INTO l_signer_type
        FROM Po_Lookup_Codes
       WHERE Lookup_Type = 'ERECORD_SIGNER_TYPE'
         AND Lookup_Code = Decode(l_signer,'BUYER','CUSTOMER');
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_signer_type := NULL;
  END;


  l_evidence_store_id := wf_notification.GetAttrText(l_notif_id, '#WF_SIG_ID');

  l_doc_parameters(1).Param_Name := 'PSIG_USER_KEY_LABEL';
  l_doc_parameters(1).Param_Value := fnd_message.get_string('PO', 'PO_EREC_PARAM_KEYVALUE');
  l_doc_parameters(1).Param_displayname := 'PSIG_USER_KEY_LABEL';
  l_doc_parameters(2).Param_Name := 'PSIG_USER_KEY_VALUE';
  l_doc_parameters(2).Param_Value :=    l_document_number;
  l_doc_parameters(2).Param_displayname := 'PSIG_USER_KEY_VALUE';

  l_sig_parameters(1).Param_Name := 'SIGNERS_COMMENT';
  l_sig_parameters(1).Param_Value := l_acceptance_note;
  l_sig_parameters(1).Param_displayname := 'Signer Comment';
  l_sig_parameters(2).Param_Name := 'REASON_CODE';
  l_sig_parameters(2).Param_Value := l_reason_code;
  l_sig_parameters(2).Param_displayname := '';
  l_sig_parameters(3).Param_Name := 'WF_SIGNER_TYPE';
  l_sig_parameters(3).Param_Value := l_signer_type;
  l_sig_parameters(3).Param_displayname := '';

  IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_log_head || ' 002 ');
			PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_log_head || ' l_response_code ' || l_response_code
      || ' l_reason_code' || l_reason_code || ' l_signer_type' || l_signer_type || ' l_event_name' || l_event_name
      || '  l_requester' ||l_requester || ' l_user_name' || l_user_name || ' l_notif_id ' || l_notif_id) ;
  END IF;

  -- Calling capture_signature API to store the eRecord
  PO_ERECORDS_PVT.capture_signature (
 	        p_api_version		 => 1.0,
	        p_init_msg_list		 => FND_API.G_FALSE,
	        p_commit		     => FND_API.G_FALSE,
	        x_return_status		 => l_return_status,
	        x_msg_count		     => l_msg_count,
	        x_msg_data		     => l_msg_data,
	        p_psig_xml		     => NULL,
	        p_psig_document		 => NULL,
	        p_psig_docFormat	 => 'HTML',
	        p_psig_requester	 => l_requester,
	        p_psig_source		 => 'SSWA',
	        p_event_name		 => l_event_name,
	        p_event_key		     => (l_document_number||'-'||l_revision),
	        p_wf_notif_id		 => l_notif_id,
	        x_document_id		 => l_erecord_id,
	        p_doc_parameters_tbl => l_doc_parameters,
	        p_user_name		     => l_user_name,
	        p_original_recipient => NULL,
	        p_overriding_comment => NULL,
	        x_signature_id		 => l_signature_id,
	        p_evidenceStore_id	 => l_evidence_store_id,
	        p_user_response		 => l_response_code,
	        p_sig_parameters_tbl => l_sig_parameters);


  IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
        RAISE l_erecords_exception;
  END IF;

  IF l_erecord_id IS NULL THEN
      l_trans_status := 'ERROR';
  ELSE
      l_trans_status := 'SUCCESS';
  END IF;

  PO_ERECORDS_PVT.send_ackn
          ( p_api_version        => 1.0,
            p_init_msg_list	     => FND_API.G_FALSE,
            x_return_status	     => l_return_status,
            x_msg_count		     => l_msg_count,
            x_msg_data		     => l_msg_data,
            p_event_name         => l_event_name,
            p_event_key          => (l_document_number||'-'||l_revision),
            p_erecord_id	     => l_erecord_id,
            p_trans_status	     => l_trans_status,
            p_ackn_by            => l_user_name,
            p_ackn_note	         => l_acceptance_note,
            p_autonomous_commit	 => FND_API.G_FALSE);

  IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_log_head || ' 003');
  END IF;

  IF l_return_status <> 'S' THEN
      RAISE l_erecords_exception;
  END IF;

  po_wf_util_pkg.SetItemAttrNumber (aname => 'ERECORD_ID', avalue => l_erecord_id);
  po_wf_util_pkg.SetItemAttrNumber(aname => 'SIG_ID', avalue => l_signature_id);

EXCEPTION
    WHEN l_erecords_exception then
      IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.INSERT_DEBUG(itemtype, itemkey, 'End erecords_exception:PO_AME_WF_PVT.CREATE_ERECORD ');
             PO_WF_DEBUG_PKG.INSERT_DEBUG(itemtype, itemkey, 'ERROR RETURNED '||l_msg_data || 'error is ' || SQLERRM  || ' code is ' || SQLCODE);
      END IF;
      l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemtype, itemkey);
      l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemtype, itemkey);
      wf_core.context('PO_AME_WF_PVT', 'Create_Erecord', 'l_erecords_exception');

      PO_REQAPPROVAL_INIT1.send_error_notif(itemtype, itemkey, l_preparer_user_name, l_doc_string, l_msg_data,'PO_AME_WF_PVT.Create_Erecord', l_document_id);
      RAISE;
END CREATE_ERECORD;

--------------------------------------------------------------------------------
--Start of Comments
--Name: check_for_esigner_exists
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This is uesd to determine e-signer/post approvers exists or not.
--  Fetch value for attribute E_SIGNER_EXISTS.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--  None
--End of Comments
---------------------------------------------------------------------------------

PROCEDURE check_for_esigner_exists(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2)
IS
	l_esigner_exists VARCHAR2(1);
BEGIN
  -- Logic :
  -- + Check worflow attribute for 'E_SIGNER_EXISTS' and return

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  --Logic is to check for workflow attribute 'E_SIGNER_EXISTS'
  l_esigner_exists := po_wf_util_pkg.GetItemAttrText (aname => 'E_SIGNER_EXISTS');
  IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, 'PO_AME_WF_PVT.check_for_esigner_exists: ' || l_esigner_exists);
  END IF;
  resultout := wf_engine.eng_completed || ':' || l_esigner_exists;

END check_for_esigner_exists;

--------------------------------------------------------------------------------
--Start of Comments
--Name: update_pending_signature
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedures update pending_signature_flag in po_headers_all
--  to 'E' if there are esigners and supplier signature is not required.
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--  None
--End of Comments
---------------------------------------------------------------------------------

PROCEDURE update_pending_signature(
            itemtype       IN VARCHAR2,
            itemkey        IN VARCHAR2,
            p_po_header_id IN NUMBER)
IS
  l_api_name                      VARCHAR2(100) := 'update_pending_signature';
  l_log_head                      VARCHAR2(500) := g_module_prefix||l_api_name;
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  -- Logic :
  -- + Update po_headers_all with pending_signature_flag = E which signifies there are
  --    post approvers/ e-sigenrs for this PO.
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head || ' 001');
  END IF;

  UPDATE po_headers_all
  SET pending_signature_flag='E'
  WHERE po_header_id = p_po_header_id
  AND NVL(acceptance_required_flag,'N') <>'S';

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_log_head || ' no os rows updated' || SQL%ROWCOUNT);
  END IF;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END update_pending_signature;

--------------------------------------------------------------------------------
--Start of Comments
--Name: update_auth_status_approve
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedures update authorization_satus to APPROVED after esigners process is complete
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--  None
--End of Comments
---------------------------------------------------------------------------------

PROCEDURE update_auth_status_approve(
            p_document_id  IN  NUMBER,
            p_item_type      IN VARCHAR2,
            p_item_key       IN VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
  l_user_id                       NUMBER;
  l_login_id                      NUMBER;
  l_api_name                      VARCHAR2(500) := 'update_auth_status_approve';
  l_log_head                      VARCHAR2(500) := g_module_prefix||l_api_name;

BEGIN
  -- Logic :
  -- + Update po_headers_all status to APPROVED and corresponding fields.
  -- + Update po_line_locations_all for approved flag

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(p_item_type,p_item_key, l_log_head || ' 001');
  END IF;

  PO_WF_UTIL_PKG.G_ITEM_TYPE := p_item_type;
  PO_WF_UTIL_PKG.G_ITEM_KEY := p_item_key;

  l_user_id := fnd_global.user_id;
  l_login_id := fnd_global.login_id;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(p_item_type,p_item_key, l_log_head || ' 002 Updating status for Userid-' || l_user_id
                                                   || ' LoginId-' || l_login_id || ' and DocumentId' || p_document_id);
  END IF;

  UPDATE  po_headers poh
  SET     poh.authorization_status = po_document_action_pvt.g_doc_status_approved
         ,poh.approved_flag = 'Y'
         ,poh.approved_date = sysdate
         ,poh.last_update_date = sysdate
         ,poh.last_updated_by = l_user_id
         ,poh.last_update_login = l_login_id
         ,poh.pending_signature_flag = 'N'
         ,poh.acceptance_required_flag  = 'N'
         ,acceptance_due_date = Null
  WHERE   poh.po_header_id = p_document_id;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(p_item_type,p_item_key, l_log_head || ' 003 : After updating po_headers_all ');
  END IF;

  --call the PO_UPDATE_DATE_PKG to update the promised date based on BPA lead time.
  PO_UPDATE_DATE_PKG.update_promised_date_lead_time (p_document_id);

  UPDATE  po_line_locations_all poll
  SET     poll.approved_flag = 'Y'
         ,poll.approved_date = sysdate
         ,poll.last_update_date = sysdate
         ,poll.last_updated_by = l_user_id
         ,poll.last_update_login = l_login_id
  WHERE   poll.po_header_id = p_document_id
  AND     poll.po_release_id IS NULL
  AND     nvl (poll.approved_flag,'N') <> 'Y';

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(p_item_type,p_item_key, l_log_head || ' After updating po_line_locations_all' );
  END IF;

  COMMIT;

END update_auth_status_approve;

--------------------------------------------------------------------------------
--Start of Comments
--Name: update_auth_status_esign
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Workflow activity PL/SQL handler.
--  This procedures update authorization_satus to APPROVED after esigners process is complete
--Parameters:
--IN:
--  Standard workflow IN parameters
--OUT:
--  Standard workflow OUT parameters
--Testing:
--  None
--End of Comments
---------------------------------------------------------------------------------

PROCEDURE update_auth_status_esign(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2)
IS
  l_document_id                   NUMBER;
  l_document_type                 PO_DOCUMENT_TYPES.DOCUMENT_TYPE_CODE%TYPE;
  l_document_subtype              PO_DOCUMENT_TYPES.DOCUMENT_SUBTYPE%TYPE;
  l_doc_string                    VARCHAR2(200);
  l_preparer_user_name            FND_USER.USER_NAME%TYPE;
  l_revision_num                  NUMBER;
  l_api_name                      VARCHAR2(500) := 'update_pending_signature';
  l_log_head                      VARCHAR2(500) := g_module_prefix||l_api_name;
  l_return_status                 VARCHAR2(1);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(2000);
  l_acceptance_date               DATE;
  x_error_msg                     VARCHAR2(2000);
  l_itemkey                       PO_HEADERS_ALL.wf_item_key%TYPE;
  l_binding_exception             EXCEPTION;
  l_progress                      VARCHAR2(3);
BEGIN
  -- Logic :
  -- + call update_auth_status_approve to update base tables.
  -- + if there were any acceptances like supplier siganture, need to update
  --   contract termss

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head || ' 001');
  END IF;

  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_document_id := po_wf_util_pkg.GetItemAttrNumber(aname => 'DOCUMENT_ID');
  l_document_type := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_TYPE');
  l_document_subtype := po_wf_util_pkg.GetItemAttrText( aname => 'DOCUMENT_SUBTYPE');
  l_revision_num      := po_wf_util_pkg.GetItemAttrNumber( aname => 'REVISION_NUMBER');

  l_progress := '001';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head || ' 002 Updating status DocumentId' || l_document_id);
  END IF;

  update_auth_status_approve(
    p_document_id => l_document_id,
    p_item_type   => itemtype,
    p_item_key    => itemkey);


  l_progress := '002';
  PO_DELREC_PVT.create_update_delrec (
     p_api_version      => 1.0,
     x_return_status    => l_return_status,
     x_msg_count        => l_msg_count,
     x_msg_data         => l_msg_data,
     p_action           => 'APPROVE',
     p_doc_type         => l_document_type,
     p_doc_subtype      => l_document_subtype,
     p_doc_id           => l_document_id,
     p_line_id          => NULL,
     p_line_location_id => NULL);

  l_progress := '003';
  -- Check whether supplier accpetance was recorded in case document was signed by supplier.
  -- If yes process document in same way as it is doen PO_SIGNATURE_PVT.POST_SIGNATURE, UPDATE_PO_DETAILS
  BEGIN
    SELECT max(action_date)
    INTO l_acceptance_date
    FROM PO_ACCEPTANCES
    WHERE Po_Header_Id = l_document_id
    AND Revision_Num = l_revision_num
    AND Signature_Flag = 'Y'
    AND ACCEPTING_PARTY IN ('B','S')
    AND ACCEPTED_FLAG= 'Y';

    -- Inform Contracts to activate deliverable, now that PO is successfully
    -- Changed status to approved

    l_progress := '004';
    PO_CONTERMS_WF_PVT.UPDATE_CONTRACT_TERMS(
      p_po_header_id      => l_document_id,
      p_signed_date       => l_acceptance_date,
      x_return_status     => l_return_status,
      x_msg_data          => l_msg_data,
      x_msg_count         => l_msg_count);

	IF l_return_status <> 'S' then
      x_error_msg := l_msg_data;
      RAISE l_binding_exception;
    END IF;

    l_progress := '005';
	PO_SIGNATURE_PVT.find_item_key(
      p_po_header_id  => l_document_id,
      p_revision_num  => l_revision_num,
      p_document_type => l_document_type,
      x_itemkey       => l_itemkey,
      x_result        => l_return_status);

    IF l_return_status = 'S' AND l_itemkey IS NOT NULL THEN
      PO_SIGNATURE_PVT.abort_doc_sign_process(
	    p_itemkey => l_itemkey,
        x_result  => l_return_status);
    ELSIF l_return_status = 'E' THEN
      x_error_msg := 'PO_MANY_SIGN_PROCESSES';
      RAISE l_binding_exception;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	  NULL;
  END;

 EXCEPTION
  WHEN l_binding_exception THEN
     IF (g_po_wf_debug = 'Y') THEN
       PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head || ' in binding excpetion with error messsage ' ||  x_error_msg);
 	 END IF;

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemtype, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemtype, itemkey);
    WF_CORE.context(g_pkg_name, l_api_name, l_progress, sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemtype, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, l_progress, l_document_id);
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head||':'||l_progress);
    END IF;
    RAISE;
END update_auth_status_esign;

-------------------------------------------------------------------------------
--Start of Comments
--Name: trigger_approval_workflow
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function triggers PO approval workflow block activity
--  from Document Signature Process
--Parameters:
--IN:
--itemtype
--  Standard parameter to be used in a workflow procedure
--itemkey
--  Standard parameter to be used in a workflow procedure
--actid
--  Standard parameter to be used in a workflow procedure
--funcmode
--  Standard parameter to be used in a workflow procedure
--OUT:
--resultout
--  Standard parameter to be used in a workflow procedure
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE trigger_approval_workflow(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2)
IS
 l_document_id NUMBER;
 l_api_name                      VARCHAR2(500) := 'trigger_approval_workflow';
 l_log_head                      VARCHAR2(500) := g_module_prefix||l_api_name;
 l_result                        VARCHAR2(1);
 l_po_itemkey                    PO_HEADERS_ALL.wf_item_key%TYPE;

BEGIN

  -- Logic :
  -- +  Call PO_SIGNATURE_PVT.Complete_Block_Activities to complete block activity in PO Approval workflow
  -- after supplier siganture part is done.

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head || ' 001');
  END IF;

  po_wf_util_pkg.g_item_type := itemtype;
  po_wf_util_pkg.g_item_key := itemkey;

  l_document_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'DOCUMENT_ID');

  -- Fetch PO approval workflow item key from pbase table.
  SELECT wf_item_key
  INTO  l_po_itemkey
  FROM po_headers_all poh
  WHERE poh.po_header_id = l_document_id;

  -- Completes the Blocked Activities in the PO Approval process
  PO_SIGNATURE_PVT.Complete_Block_Activities(p_itemkey => l_po_itemkey,
                                             p_status  => 'Y',
                                             x_result  => l_result);

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head || ' 002 result : ' || l_result);
  END IF;

  resultout := wf_engine.eng_completed;
END trigger_approval_workflow;

-------------------------------------------------------------------------------
--Start of Comments
--Name: suppress_existing_esigners
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function is called only if supplier rejected signature.
--  It supresses if they were any post-approvers/ e-signers.
--Parameters:
--IN:
--itemtype
--  Standard parameter to be used in a workflow procedure
--itemkey
--  Standard parameter to be used in a workflow procedure
--actid
--  Standard parameter to be used in a workflow procedure
--funcmode
--  Standard parameter to be used in a workflow procedure
--OUT:
--resultout
--  Standard parameter to be used in a workflow procedure
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE suppress_existing_esigners(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2)
IS
  l_api_name                      VARCHAR2(500) := 'suppress_existing_esigners';
  l_log_head                      VARCHAR2(500) := g_module_prefix||l_api_name;
  l_esigner_exists               VARCHAR2(1);

BEGIN
 -- Logic :
 -- 1. For post-approvers/e-signers where ameStatus is still NULL, we need to supress them.
 --    This function is called only if supplier signature was rejected.

  IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head || ' 001 ');
  END IF;
  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_esigner_exists := po_wf_util_pkg.GetItemAttrText(aname => 'E_SIGNER_EXISTS');

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head || ' l_esigners_exists ' ||  l_esigner_exists);
  END IF;

  IF l_esigner_exists = 'Y' THEN
    BEGIN
      supress_existing_approvers(
            itemtype => itemtype,
            itemkey => itemkey);
	EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;

  IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head || ' l_esigners_exists ' ||  l_esigner_exists);
  END IF;

  END IF;

  resultout := wf_engine.eng_completed;

END suppress_existing_esigners;

-------------------------------------------------------------------------------
--Start of Comments
--Name: supress_existing_approvers
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function is called if documnet is returned to supress existing approvers
--IN:
--itemtype
--  Standard parameter to be used in a workflow procedure
--itemkey
--  Standard parameter to be used in a workflow procedure
--actid
--  Standard parameter to be used in a workflow procedure
--funcmode
--  Standard parameter to be used in a workflow procedure
--OUT:
--resultout
--  Standard parameter to be used in a workflow procedure
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE supress_existing_approvers(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2)
IS
  l_api_name                      VARCHAR2(500) := 'supress_existing_approvers';
  l_log_head                      VARCHAR2(500) := g_module_prefix||l_api_name;
  l_approver_list                 ame_util.approversTable2;
  xprocess_out                    VARCHAR2(1);
  l_transaction_type              PO_DOCUMENT_TYPES.AME_TRANSACTION_TYPE%TYPE;
  l_transaction_id                NUMBER;
  l_approver_index                NUMBER;

BEGIN
 -- Logic :
 -- 1. For post-approvers/reviewers/approvers where ameStatus is still NULL or notified, we need to supress them.
 -- 2. Here we fetch all approvers through ame_api2.getAllApprovers7. Then check for approvers
 --    whose status is NULL, means for them AME routing havent been strated yet.
 -- 3. Call ame_api3.suppressApprover to suppress such approvers.
 --    We set-reset dynamic profile 'PO_SYS_GENERATED_APPROVERS_SUPPRESS', to override AME mandatory
 --    attribute  ALLOW_DELETING_RULE_GENERATED_APPROVERS.

  IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head || ' 001 ');
  END IF;
  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_transaction_type := po_wf_util_pkg.GetItemAttrText( aname => 'AME_TRANSACTION_TYPE');
  l_transaction_id := po_wf_util_pkg.GetItemAttrNumber( aname => 'AME_TRANSACTION_ID');

  IF l_transaction_id IS NOT NULL AND l_transaction_type IS NOT NULL THEN
    ame_api2.getAllApprovers7(applicationIdIn => applicationId,
                             transactionTypeIn => l_transaction_type,
                             transactionIdIn => l_transaction_id,
                             approvalProcessCompleteYNOut => xprocess_out,
                             approversOut =>  l_approver_list);

    l_approver_index :=  l_approver_list.first();

    WHILE ( l_approver_index IS NOT NULL ) LOOP
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head || ' supressing approver name ' ||  l_approver_list(l_approver_index).name);
 	    END IF;

      IF  l_approver_list(l_approver_index).approval_status IS NULL OR
         l_approver_list(l_approver_index).approval_status IN (ame_util.notifiedStatus, ame_util.notifiedByRepeatedStatus) THEN
	        fnd_profile.put('PO_SYS_GENERATED_APPROVERS_SUPPRESS', 'Y');
  	      ame_api3.suppressApprover( applicationIdIn => applicationId,
                                 transactionIdIn => l_transaction_id,
                                 transactionTypeIn => l_transaction_type,
                                 approverIn =>  l_approver_list(l_approver_index));
     	  	fnd_profile.put('PO_SYS_GENERATED_APPROVERS_SUPPRESS', 'N');
 	     END IF; -- l_approver_index loop
	      l_approver_index :=  l_approver_list.next(l_approver_index);
    	END LOOP;
  END IF; -- l_transaction_id IS NOT NULL AND l_transaction_type IS NOT NULL
END supress_existing_approvers;

-------------------------------------------------------------------------------
--Start of Comments
--Name: complete_ame_transaction
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function is called if documnet is returned to supress exixting approvers and
--  set new ame_approval_id.
--IN:
--itemtype
--  Standard parameter to be used in a workflow procedure
--itemkey
--  Standard parameter to be used in a workflow procedure
--actid
--  Standard parameter to be used in a workflow procedure
--funcmode
--  Standard parameter to be used in a workflow procedure
--OUT:
--resultout
--  Standard parameter to be used in a workflow procedure
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE complete_ame_transaction(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2)
IS
  l_api_name                      VARCHAR2(500) := 'complete_ame_transaction';
  l_log_head                      VARCHAR2(500) := g_module_prefix||l_api_name;
  l_document_id                   NUMBER;
  l_return_message                VARCHAR2(1000);

BEGIN
  IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, l_log_head || ' 001 ');
  END IF;
  --Set the global attributes in the po wrapper function
  PO_WF_UTIL_PKG.G_ITEM_TYPE := itemtype;
  PO_WF_UTIL_PKG.G_ITEM_KEY := itemkey;

  l_document_id := po_wf_util_pkg.GetItemAttrNumber(aname => 'DOCUMENT_ID');

  BEGIN
    supress_existing_approvers(
      itemtype => itemtype,
      itemkey  => itemkey);
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;

  reset_authorization_status(
    p_document_id    => l_document_id,
    p_item_type      => itemtype,
    p_item_key       => itemkey,
    x_return_message => l_return_message);

  resultout := wf_engine.eng_completed;

END complete_ame_transaction;

END PO_AME_WF_PVT;

/
