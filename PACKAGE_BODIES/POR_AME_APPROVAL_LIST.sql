--------------------------------------------------------
--  DDL for Package Body POR_AME_APPROVAL_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_AME_APPROVAL_LIST" AS
/* $Header: POXAPL2B.pls 120.65.12010000.19 2014/07/23 04:20:44 mitao ship $ */


-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

approvalListStr          VARCHAR2(32767) := NULL;

/* private routines */

--------------------------------------------------------------------------------
--Start of Comments
--Name: getAllApprovers
--Function:
--  Get the latest approval list from AME
--Parameters:
--IN:
--pReqHeaderId
--  Requisition Header ID
--pAmeTransactionType
--  AME transaction type
--OUT:
--pApprovalListStr
--  Approval List concatenated in a string
--pApprovalListCount
--  Number of Approvers.
--  It has a value of 0, if the document does not require approval.
--End of Comments
--------------------------------------------------------------------------------
procedure getAllApprovers(pReqHeaderId             IN  NUMBER,
                            pAmeTransactionType    IN VARCHAR2,
                            pApprovalListStr       OUT NOCOPY VARCHAR2,
                            pApprovalListCount     OUT NOCOPY NUMBER);


--------------------------------------------------------------------------------
--Start of Comments
--Name: getAbsolutePosition
--Function:
--  Return the absolute position given an input position.
--  The absolute position is added with an offset by the number of past approvers.
--Parameters:
--IN:
--pReqHeaderId
--  Requisition Header ID
--pAmeTransactionType
--  AME transaction type
--pPosition
--  This position is a relative value after the last of the past approvers.
--OUT:
--  None
--End of Comments
--------------------------------------------------------------------------------
function getAbsolutePosition(pReqHeaderId             IN  NUMBER,
                            pAmeTransactionType    IN VARCHAR2,
                            pPosition IN NUMBER)
return number;

--------------------------------------------------------------------------------
--Start of Comments
--Name: marshalField
--Function:
--  Append the input string into approval list string
--  Replace the input string if it contains either a quote or delimiter char.
--  Another quote char is added in front of a quote or delimiter char.

--Parameters:
--IN:
--p_string
--  Input string

--OUT:
--None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE marshalField(p_string     IN VARCHAR2,
                       p_quote_char IN VARCHAR2,
                       p_delimiter  IN VARCHAR2);

--------------------------------------------------------------------------------
--Start of Comments
--Name: serializeApproversTable
--Function:
--  Serialize approver list table into a string representation
--Parameters:
--IN:
--approversTableIn
--  Approver list table
--pReqHeaderId
--  Requisition Header Id
--OUT:
--approverCount
--  Number of approvers
--hasApprovalAction
--  'Y' if there is approver taken action
--End of Comments
--------------------------------------------------------------------------------

function serializeApproversTable(approversTableIn in ame_util.approversTable2,
                                 reqHeaderId in NUMBER,
                                 approverCount out nocopy number,
                                 hasApprovalAction out nocopy varchar2)
  return varchar2;

--------------------------------------------------------------------------------
--Start of Comments
--Name: getAmeTxnType
--Function:
--  Get the ame txn type given the document type and subtype
--Parameters:
--IN:
-- p_doc_type
--  Document Type
-- p_doc_subtype
--  Document subtype
-- p_org_id
--  Corresponding org id
--OUT:
-- ameTxnType
-- the corresponding ame txn type
--End of Comments
--------------------------------------------------------------------------------
function getAmeTxnType (p_doc_type in VARCHAR2,
                                      p_doc_subtype in VARCHAR2,
				      p_org_id in NUMBER)
return varchar2;


/* public API */
--------------------------------------------------------------------------------
--Start of Comments
--Name: change_first_approver
--Function:
--  Call AME API to get the new approval list for a requisition.
--  The new approval list is based on the person ID of a new first approver.
--Parameters:
--IN:
--    pReqHeaderId       Requisition Header ID
--    pPersonId          Person ID of a new first approver
--OUT:
--    pApprovalListStr   Approval List concatenated in a string
--    pApprovalListCount Number of Approvers.
--                       It has a value of 0, if the document does not require approval.
--    pQuoteChar         Quote Character, used for escaping purpose in tokenization
--    pFieldDelimiter    Field Delimiter, used for delimiting list string into elements.
--End of Comments
--------------------------------------------------------------------------------
procedure change_first_approver( pReqHeaderId        IN  NUMBER,
                                 pPersonId           IN  NUMBER,
                                 pApprovalListStr    OUT NOCOPY VARCHAR2,
                                 pApprovalListCount  OUT NOCOPY NUMBER,
                                 pQuoteChar          OUT NOCOPY VARCHAR2,
                                 pFieldDelimiter     OUT NOCOPY VARCHAR2
                               ) IS

  l_api_name varchar2(50):= 'change_first_approver';
  tmpApprover ame_util.approverRecord2;
  ameTransactionType po_document_types.ame_transaction_type%TYPE;

  approverList      ame_util.approversTable2;
  l_process_out      VARCHAR2(10);
  currentFirstApprover ame_util.approverRecord2;

begin

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering change_first_approver...');
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pReqHeaderId :' || pReqHeaderId );
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pPersonId :' || pPersonId );
      END IF;
  end if;

  getAmeTransactionType(pReqHeaderId => pReqHeaderId,
                    pAmeTransactionType => ameTransactionType);

  pQuoteChar :=quoteChar;
  pFieldDelimiter :=fieldDelimiter;

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame api ame_api2.getAllApprovers7() to get the list of approvers from AME.');
      END IF;
  end if;

  -- get the current approvers list from AME.
  ame_api2.getAllApprovers7( applicationIdIn=>applicationId,
                             transactionIdIn=>pReqHeaderId,
                             transactionTypeIn=>ameTransactionType,
                             approvalProcessCompleteYNOut => l_process_out,
                             approversOut=>approverList
                           );

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Retrieved the list of approvers from AME using ame_api2.getAllApprovers7()');
      END IF;
  end if;

  -- Once we get the approvers list from AME, we iterate through the approvers list,
  -- to find out the current first authority approver.
  for i in 1 .. approverList.count loop
    if( approverList(i).authority = ame_util.authorityApprover
        and approverList(i).approval_status is null
        and approverList(i).api_insertion = 'N'
        and approverList(i).group_or_chain_id < 3 ) then
          currentFirstApprover :=  approverList(i) ;
          if g_fnd_debug = 'Y' then
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Found the first authority approver...' || currentFirstApprover.name );
              END IF;
          end if;
          exit;
    end if;
  end loop;

  -- Once we get the current first authority approver, we check for the current first authority approver's action type(POS/PER).
  -- If the first approver record is of position hierarchy action type,
  --    then we need to find out the position id of the given approver and frame the new approver record.
  --    We also set the columns first_position_id and first_approver_id in po_requisition_headers_all
  -- If the first approver record is of emp supervisor action type,
  --    then we simply frame the new approver record from the input parameters.
  -- FND users cannot be set as first authority approver. So no need to check for the value 'FND'

  if currentFirstApprover.orig_system = ame_util.posOrigSystem then

        if g_fnd_debug = 'Y' then
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'First record is of type Position Hierarchy...' );
            END IF;
        end if;
        tmpApprover.orig_system := ame_util.posOrigSystem;
        SELECT position_id into tmpApprover.orig_system_id FROM PER_ALL_ASSIGNMENTS_F pa
                WHERE pa.person_id = pPersonId and pa.primary_flag = 'Y' and pa.assignment_type in ('E','C')
                and pa.position_id is not null and pa.assignment_status_type_id not in (
                select assignment_status_type_id from per_assignment_status_types where per_system_status = 'TERM_ASSIGN')
                and TRUNC ( pa.effective_start_date )
                <=  TRUNC(SYSDATE) AND NVL(pa.effective_end_date, TRUNC( SYSDATE)) >= TRUNC(SYSDATE);

        if g_fnd_debug = 'Y' then
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Got users position_id :' || tmpApprover.orig_system_id );
            END IF;
        end if;

        UPDATE po_requisition_headers_all
        SET first_position_id = tmpApprover.orig_system_id, first_approver_id = pPersonId
        WHERE requisition_header_id = pReqHeaderId;

        if g_fnd_debug = 'Y' then
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' Inserted the first_position_id and first_approver_id columns.' );
            END IF;
        end if;

        IF tmpApprover.orig_system_id IS NULL THEN
               raise_application_error(-20001, 'User is not associated to any position. ');
        END IF;
  else
        if g_fnd_debug = 'Y' then
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' First record is of type Emp-Sup Hierarchy...' );
            END IF;
        end if;
        tmpApprover.orig_system := ame_util.perOrigSystem;
        tmpApprover.orig_system_id := pPersonId;
  end if;

  -- set the mandatory default attributes for the first authority approver.
  tmpApprover.authority := ame_util.authorityApprover;
  tmpApprover.api_insertion := ame_util.apiAuthorityInsertion;
  tmpApprover.approval_status := ame_util.nullStatus;
  tmpApprover.approver_category := ame_util.approvalApproverCategory ;
  tmpApprover.item_class := currentFirstApprover.item_class ;
  tmpApprover.item_id := currentFirstApprover.item_id ;
  tmpApprover.action_type_id := currentFirstApprover.action_type_id ;
  tmpApprover.group_or_chain_id := currentFirstApprover.group_or_chain_id ;

  -- retrieve the name from wf_roles table for the given orig_system and orig_system_id values.
  -- this name field does not refer to neither employee name nor position name
  -- this name filed is the mandatory key field for the approverrecord2. We should pass this to ame. Otherwise ame will throw exception.

      -- bug 9395808
      -- fix The problem of just picking up the first approver randomly when an approver is manually
      -- inserted in the chain in iProc.
      -- it should pick up the approver with earliest start date.
      -- also validating the approver status
      SELECT name into tmpApprover.name FROM (
            SELECT name
            FROM wf_roles
            WHERE orig_system = tmpApprover.orig_system and orig_system_id = tmpApprover.orig_system_id
                  and status = 'ACTIVE' and trunc (nvl( expiration_date, sysdate)) >= trunc(sysdate)
            ORDER BY start_date
            )
      WHERE rownum = 1;

  IF tmpApprover.name IS NULL THEN
         raise_application_error(-20001, 'Record Not Found in WF_ROLES for the orig_system_id :' ||
                                          tmpApprover.orig_system_id || ' -- orig_system :' || tmpApprover.orig_system );
  END IF;

  -- call the ame api to set the first authority approver.
  -- tmpApprover is the new first authority approver record.

  if g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame_api2.setFirstAuthorityApprover()...' );
       END IF;
  end if;

  -- set a save point for failure rollback
  SAVEPOINT CHANGE_FIRST_APPROVER;

  ame_api2.setFirstAuthorityApprover( applicationIdIn      => applicationId,
                                      transactionIdIn      => pReqHeaderId,
                                      approverIn           => tmpApprover,
                                      transactionTypeIn    => ameTransactionType,
                                      clearChainStatusYNIn => ame_util.booleanTrue
                                    );
  if g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Done with ame_api2.setFirstAuthorityApprover()...' );
       END IF;
  end if;

  -- Once we change the first authority approver, then get the updated approvers list from ame.
  getAllApprovers(pReqHeaderId, ameTransactionType, pApprovalListStr, pApprovalListCount);

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Leaving change_first_approver...');
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- pApprovalListStr :' || pApprovalListStr);
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- pApprovalListCount :' || pApprovalListCount);
      END IF;
  end if;

exception
  when NO_DATA_FOUND then
    pApprovalListCount := 0;
    pApprovalListStr := 'NO_DATA_FOUND';
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.NO_DATA_FOUND', 'NO_DATA_FOUND');
      END IF;
    end if;
  when others then
    pApprovalListCount := 0;
    pApprovalListStr := 'EXCEPTION:' || sqlerrm;
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
    ROLLBACK TO CHANGE_FIRST_APPROVER;
end;

--------------------------------------------------------------------------------
--Start of Comments
--Name: insert_approver
--Function:
--  Call AME API to insert an approver into a specific position.
--  The new approval list is retrieved after the insertion.

--Parameters:
--IN:
--    pReqHeaderId       Requisition Header ID
--    pPersonId          Person ID of a new approver
--    pAuthority         AME Authority type of the new approver
--    pInsertionType     AME Insertion type of the new approver
--    pPosition          Position to be inserted
--    pApproverNumber    Exact insertion psition
--    pInsertionType     Where to insert, after or before
--    pApproverName      Username of the approver
--OUT:
--    pApprovalListStr   Approval List concatenated in a string
--    pApprovalListCount Number of Approvers.
--                       It has a value of 0, if the document does not require approval.
--    pQuoteChar         Quote Character, used for escaping purpose in tokenization
--    pFieldDelimiter    Field Delimiter, used for delimiting list string into elements.
--End of Comments
--------------------------------------------------------------------------------
procedure insert_approver(  pReqHeaderId        IN  NUMBER,
                            pPersonId           IN NUMBER,
                            pAuthority          IN VARCHAR2,
                            pApproverCategory   IN VARCHAR2,
                            pPosition           IN NUMBER,
			    pApproverNumber     IN NUMBER,
                            pInsertionType      IN VARCHAR2,
			    pApproverName   IN VARCHAR2,
                            pApprovalListStr    OUT NOCOPY VARCHAR2,
                            pApprovalListCount  OUT NOCOPY NUMBER,
                            pQuoteChar          OUT NOCOPY VARCHAR2,
                            pFieldDelimiter     OUT NOCOPY VARCHAR2
                          ) IS
  l_api_name varchar2(50):= 'insert_approver';

  tmpApprover ame_util.approverRecord2;
  insertOrder ame_util.insertionRecord2;
  upperLimit number;
  approverList      ame_util.approversTable2;
  hasAvailableOrder boolean := false;
  E_NO_AVAILABLE_INSERTION EXCEPTION;
  ameTransactionType po_document_types.ame_transaction_type%TYPE;
  absolutePosition number;
  availableInsertionList ame_util.insertionsTable2;
  l_process_out      VARCHAR2(10);
  l_group_or_chain_id NUMBER := 0;
  l_action_type_id NUMBER := 0;
  l_counter NUMBER := 0;
  l_approver_position NUMBER := 0;
  hasHiddenApprovers boolean := false; -- Flag to check hidden approvers
  l_insertion_type varchar2(1); -- To store insertion type

begin

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering insert_approver...');
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pReqHeaderId :' || pReqHeaderId );
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pPersonId :' || pPersonId );
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pAuthority :' || pAuthority );
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pPosition :' || pPosition );
      END IF;
  end if;

  getAmeTransactionType(pReqHeaderId => pReqHeaderId,
                    pAmeTransactionType => ameTransactionType);

  pQuoteChar :=quoteChar;
  pFieldDelimiter :=fieldDelimiter;

  /*
   past approvers are not in middle tier
   so need to deduce the real position
  */


  -- Frame the approverRecord2 from the input parameters.
  -- Set the default mandatory attributes also.
  tmpApprover.orig_system := ame_util.perOrigSystem;
  tmpApprover.orig_system_id := pPersonId;
  tmpApprover.authority := pAuthority;
  tmpApprover.api_insertion := ame_util.apiInsertion;
  tmpApprover.approver_category := pApproverCategory;
  tmpApprover.approval_status := ame_util.nullStatus;
  ame_api2.getAllApprovers7( applicationIdIn => applicationId,
                             transactionIdIn => pReqHeaderId,
                             transactionTypeIn => ameTransactionType,
                             approvalProcessCompleteYNOut => l_process_out,
                             approversOut => approverList
                           );

  /* Check if there is any supressed or repeated approver. As soon as we met any, set hasHiddenApprovers true and exit
     Added extra statuses to check if there is any hidden approver in approver checkout flow */
  For i In 1 .. approverList.count LOOP
     IF (approverList(i).approval_status IN (ame_util.repeatedStatus,ame_util.suppressedStatus,
                           ame_util.notifiedByRepeatedStatus, ame_util.approvedByRepeatedStatus,
                           ame_util.rejectedByRepeatedStatus, ame_util.approvedStatus,
                           ame_util.rejectStatus )) THEN
       hasHiddenApprovers := true;
       EXIT;
    END IF;
  END LOOP;

 /* If we  have any superessed approver then execute this code ,otherwise pass the pApproverNumber to absoluteposition
     Approvers with Approval_status 'REPEATED' OR 'SUPPRESSED'is not considered in getAllApprovers procedure
     Second condition will be used to avoid this code when we are inserting first approver */
  IF ( hasHiddenApprovers = true AND pApproverName IS NOT NULL ) THEN
     if g_fnd_debug = 'Y' then
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' Found Repeated/Skipped Approvers!'  );
        END IF;
     end if;

     for i in 1 .. approverList.count loop
        /* Find approver with given name and status NULL or not REPEATED or not SUPPRESSED
           Status XXXByRepeatedStatus is used because 'repeated' status gets modified to XXXByRepeatedStatus
           status when other approvers in group or PCOA gets notified or approve or reject .Also group can have pending as well
           as approved approvers */
        IF ( pApproverName = approverList(i).name AND ( approverList(i).approval_status IS NULL
             OR approverList(i).approval_status NOT IN (ame_util.repeatedStatus,ame_util.suppressedStatus,
                ame_util.notifiedByRepeatedStatus, ame_util.approvedByRepeatedStatus,
                ame_util.rejectedByRepeatedStatus, ame_util.approvedStatus,
                ame_util.rejectStatus))) THEN
           l_approver_position := i;
	   /* Once we locate the approver terminate the loop */
           EXIT;
        END IF;
     end loop;
     l_group_or_chain_id := approverList(l_approver_position).group_or_chain_id;
     l_action_type_id := approverList(l_approver_position).action_type_id;
     l_insertion_type := approverList(l_approver_position).api_insertion; -- Set insertion type which will be used to identify adhoc approver

     /* Condition 1.1: If we are inserting after an approver who belongs to a group
        Condition 1.2: If we are inserting after an approver who is either adhoc or belongs to COA
        Condition 2.1: If we are inserting approver before an approver who belongs to a group
        Condition 2.2: If we are inserting before an approver who is either adhoc or belongs to COA
        In each case we have to take care of approvers who are repeated or deleted (suppressed)
        And if there are approvers like this then either increment or decrement positionId depending upon whether
        we are inserting after or before */
     IF pInsertionType = 'A' THEN
        l_counter := l_approver_position +1;
        /* Check if the approver is adhoc or not. If adhoc then we need not to look for any repeated or supressed approver.
           Checking it for 'after' case and not 'before' because insertion before adhoc is only possible if adhoc is inserted at
           the left end of chain. And in that case action_type_id is enough to locate exact position of insertion
           Requirement of these extra statuses have beed explained earlier. Not included condition check of 'approvedStatus'
           for 'before' case, because we dont provide option to insert before approver who have approved */
        IF l_insertion_type <> ame_util.apiInsertion THEN
          if l_group_or_chain_id > 1  then
             while( l_counter <= approverList.count AND approverList(l_counter).group_or_chain_id = l_group_or_chain_id
	           AND approverList(l_counter).approval_status IN (ame_util.repeatedStatus,ame_util.suppressedStatus,
                       ame_util.notifiedByRepeatedStatus, ame_util.approvedByRepeatedStatus, ame_util.rejectedByRepeatedStatus,
                       ame_util.approvedStatus) ) LOOP
               l_counter := l_counter + 1;
             END LOOP;
	  else
	      while( l_counter <= approverList.count AND approverList(l_counter).action_type_id = l_action_type_id
	            AND approverList(l_counter).approval_status IN (ame_util.repeatedStatus,ame_util.suppressedStatus,
                        ame_util.notifiedByRepeatedStatus, ame_util.approvedByRepeatedStatus, ame_util.rejectedByRepeatedStatus,
                       ame_util.approvedStatus) ) LOOP
                l_counter := l_counter + 1;
              END LOOP;
	  end if;
        END IF;
        absolutePosition := l_counter;
    ELSE
        l_counter := l_approver_position - 1;
        if l_group_or_chain_id > 1 then
	   while( l_counter > 0 AND approverList(l_counter).group_or_chain_id = l_group_or_chain_id
	          AND approverList(l_counter).approval_status IN (ame_util.repeatedStatus,ame_util.suppressedStatus,
                      ame_util.notifiedByRepeatedStatus, ame_util.approvedByRepeatedStatus, ame_util.rejectedByRepeatedStatus)) LOOP
               l_counter := l_counter - 1;
            END LOOP;
	 else
	     while( l_counter > 0 AND approverList(l_counter).action_type_id = l_action_type_id
	            AND approverList(l_counter).approval_status IN (ame_util.repeatedStatus,ame_util.suppressedStatus,
                        ame_util.notifiedByRepeatedStatus, ame_util.approvedByRepeatedStatus, ame_util.rejectedByRepeatedStatus	)) LOOP
                l_counter := l_counter - 1;
             END LOOP;
	 end if;
	 absolutePosition := l_counter + 1;
     END IF;

  /* If we dont have any repeated approver */
  ELSE
    absolutePosition := pApproverNumber;
  END IF;

  -- Verify the available insertions list from ame by giving the position number
  -- Ame will give the output available list if the insertion is possible.
  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' final absolutePosition :'  || absolutePosition  );
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame_api3.getAvailableInsertions()..');
      END IF;
  end if;

  ame_api3.getAvailableInsertions( applicationIdIn        => applicationId,
                                   transactionIdIn        => pReqHeaderId,
                                   positionIn             => absolutePosition,
                                   transactionTypeIn      => ameTransactionType,
                                   availableInsertionsOut => availableInsertionList
                                 );

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Done with ame_api3.getAvailableInsertions()..');
      END IF;
  end if;

  -- Iterate through the available list and find out the authority approver insertion location.
  -- Once we get the exact available location, then simply populate the approver record's mandatory fields.

  IF(approverList.count = 0) THEN
    FOR i IN 1 .. availableInsertionList.COUNT LOOP
    IF availableInsertionList(i).order_type IN
        (ame_util.absoluteOrder,ame_util.afterApprover, ame_util.beforeApprover) AND
       availableInsertionList(i).api_insertion = tmpApprover.api_insertion AND
       availableInsertionList(i).authority = tmpApprover.authority THEN

      insertOrder := availableInsertionList(i);

      tmpApprover.item_class := insertOrder.item_class;
      tmpApprover.item_id := insertOrder.item_id;
      tmpApprover.action_type_id := insertOrder.action_type_id;
      tmpApprover.group_or_chain_id := insertOrder.group_or_chain_id;
      tmpApprover.api_insertion := insertOrder.api_insertion;
      tmpApprover.authority := insertOrder.authority;

      -- retrieve the name from wf_roles table for the given orig_system and orig_system_id values.
      -- this name field does not refer to neither employee name nor position name
      -- this name filed is the mandatory key field for the approverrecord2. We should pass this to ame. Otherwise ame will throw exception.

      -- bug 9395808
      -- fix The problem of just picking up the first approver randomly when an approver is manually
      -- inserted in the chain in iProc.
      -- it should pick up the approver with earliest start date.
      -- also validating the approver status
      SELECT name into tmpApprover.name FROM (
            SELECT name
            FROM wf_roles
            WHERE orig_system = tmpApprover.orig_system and orig_system_id = tmpApprover.orig_system_id
                  and status = 'ACTIVE' and trunc (nvl( expiration_date, sysdate)) >= trunc(sysdate)
            ORDER BY start_date
            )
      WHERE rownum = 1;

      IF tmpApprover.name IS NULL THEN
              raise_application_error(-20001, 'Record Not Found in WF_ROLES for the orig_system_id :' ||
                                               tmpApprover.orig_system_id || ' -- orig_system :' || tmpApprover.orig_system );
      END IF;

      if g_fnd_debug = 'Y' then
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
             FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Found the available position also to insert..');
           END IF;
      end if;

      hasAvailableOrder := true;
      EXIT;

    END IF;
    END LOOP;
 ELSE
  FOR i IN 1 .. availableInsertionList.COUNT LOOP
     /* We can insert after an approver if we have order_type in absoluteOrder,afterApprover or beforeApprover
        And for insertion before an approver we should have order_type as beforeApprover */
     IF ((pInsertionType = 'A' and availableInsertionList(i).order_type IN (ame_util.absoluteOrder, ame_util.afterApprover, ame_util.beforeApprover))
          OR (pInsertionType = 'B' and availableInsertionList(i).order_type = ame_util.beforeApprover)) AND
       availableInsertionList(i).api_insertion = tmpApprover.api_insertion AND
       availableInsertionList(i).authority = tmpApprover.authority THEN

      insertOrder := availableInsertionList(i);

      tmpApprover.item_class := insertOrder.item_class;
      tmpApprover.item_id := insertOrder.item_id;
      tmpApprover.action_type_id := insertOrder.action_type_id;
      tmpApprover.group_or_chain_id := insertOrder.group_or_chain_id;
      tmpApprover.api_insertion := insertOrder.api_insertion;
      tmpApprover.authority := insertOrder.authority;

      -- retrieve the name from wf_roles table for the given orig_system and orig_system_id values.
      -- this name field does not refer to neither employee name nor position name
      -- this name filed is the mandatory key field for the approverrecord2. We should pass this to ame. Otherwise ame will throw exception.

      -- bug 9395808
      -- fix The problem of just picking up the first approver randomly when an approver is manually
      -- inserted in the chain in iProc.
      -- it should pick up the approver with earliest start date.
      -- also validating the approver status

      SELECT name into tmpApprover.name FROM (
            SELECT name
            FROM wf_roles
            WHERE orig_system = tmpApprover.orig_system and orig_system_id = tmpApprover.orig_system_id
                  and status = 'ACTIVE' and trunc (nvl( expiration_date, sysdate)) >= trunc(sysdate)
            ORDER BY start_date
            )
      WHERE rownum = 1;

      IF tmpApprover.name IS NULL THEN
              raise_application_error(-20001, 'Record Not Found in WF_ROLES for the orig_system_id :' ||
                                               tmpApprover.orig_system_id || ' -- orig_system :' || tmpApprover.orig_system );
      END IF;

      if g_fnd_debug = 'Y' then
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
             FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Found the available position also to insert..');
           END IF;
      end if;

      hasAvailableOrder := true;
      EXIT;

    END IF;
  END LOOP;
 END IF;
  -- Call ame api to insert an approver if the hasAvailableOrder = true
  -- tmpApprover will be the new approver record and will be inserted in the absolutePosition.
  if (hasAvailableOrder) then

     if g_fnd_debug = 'Y' then
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame_api3.insertApprover()..');
          END IF;
     end if;

     ame_api3.insertApprover( applicationIdIn   => applicationId,
                              transactionIdIn   => pReqHeaderId,
                              approverIn        => tmpApprover,
                              positionIn        => absolutePosition,
                              insertionIn       => insertOrder,
                              transactionTypeIn => ameTransactionType
                           );

     if g_fnd_debug = 'Y' then
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Done with ame_api3.insertApprover()..');
          END IF;
     end if;
    -- Once we insert an approver to ame, get the updated list of approvers from ame.
    getAllApprovers(pReqHeaderId, ameTransactionType, pApprovalListStr, pApprovalListCount);

    if g_fnd_debug = 'Y' then
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Leaving insert_approver...');
        END IF;
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- pApprovalListStr :' || pApprovalListStr);
        END IF;
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- pApprovalListCount :' || pApprovalListCount);
        END IF;
    end if;

    return;
  end if;

  raise E_NO_AVAILABLE_INSERTION;

exception
  when E_NO_AVAILABLE_INSERTION then
    pApprovalListCount := 0;
    pApprovalListStr := 'EXCEPTION-E_NO_AVAILABLE_INSERTION';
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.E_NO_AVAILABLE_INSERTION', 'No available insertion order');
      END IF;
    end if;
  when NO_DATA_FOUND then
    pApprovalListCount := 0;
    pApprovalListStr := 'NO_DATA_FOUND';
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.NO_DATA_FOUND', 'NO_DATA_FOUND');
      END IF;
    end if;
  when others then
    pApprovalListCount := 0;
    pApprovalListStr := 'EXCEPTION';
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
end;

--------------------------------------------------------------------------------
--Start of Comments
--Name: delete_approver
--Function:
--  Call AME API to delete an approver from the current approver list.
--  The new approval list is retrieved after the deletion.

--Parameters:
--IN:
--    pReqHeaderId       Requisition Header ID
--    pPersonId          Person ID of the approver to be deleted
--OUT:
--    pApprovalListStr   Approval List concatenated in a string
--    pApprovalListCount Number of Approvers.
--                       It has a value of 0, if the document does not require approval.
--    pQuoteChar         Quote Character, used for escaping purpose in tokenization
--    pFieldDelimiter    Field Delimiter, used for delimiting list string into elements.
--End of Comments
--------------------------------------------------------------------------------
procedure delete_approver(  pReqHeaderId        IN  NUMBER,
                            pPersonId           IN  NUMBER,
                            pOrigSystem         IN VARCHAR2,
                            pOrigSystemId       IN NUMBER,
                            pRecordName         IN VARCHAR2,
                            pAuthority          IN VARCHAR2,
                            pApprovalListStr    OUT NOCOPY VARCHAR2,
                            pApprovalListCount  OUT NOCOPY NUMBER,
                            pQuoteChar          OUT NOCOPY VARCHAR2,
                            pFieldDelimiter     OUT NOCOPY VARCHAR2
                          ) IS

  l_api_name varchar2(50):= 'delete_approver';
  tmpApprover      ame_util.approverRecord2;
  ameTransactionType po_document_types.ame_transaction_type%TYPE;

  approverList      ame_util.approversTable2;
  l_process_out      VARCHAR2(10);
  l_first_position_id NUMBER;

begin

   if g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering delete_approver...');
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pReqHeaderId :' || pReqHeaderId );
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pPersonId :' || pPersonId );
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pOrigSystem :' || pOrigSystem );
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pOrigSystemId :' || pOrigSystemId );
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pRecordName :' || pRecordName );
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pAuthority :' || pAuthority );
       END IF;
   end if;

  getAmeTransactionType(pReqHeaderId => pReqHeaderId,
                    pAmeTransactionType => ameTransactionType);

  pQuoteChar :=quoteChar;
  pFieldDelimiter :=fieldDelimiter;

  -- Frame the approverRecord2 from the input parameters.
  tmpApprover.orig_system_id := pOrigSystemId;
  tmpApprover.orig_system    := pOrigSystem;
  tmpApprover.name           := pRecordName;
  tmpApprover.authority      := pAuthority;

  if g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame_api2.getAllApprovers7()..');
       END IF;
  end if;

  -- get the AME approvers list
  ame_api2.getAllApprovers7( applicationIdIn => applicationId,
                             transactionIdIn => pReqHeaderId,
                             transactionTypeIn => ameTransactionType,
                             approvalProcessCompleteYNOut => l_process_out,
                             approversOut => approverList
                           );

  if g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Done with ame_api2.getAllApprovers7()..');
       END IF;
  end if;

  -- check for the given approver details in the approval list
  -- the approver should be there in the approval list
  -- once we get the approver details in the list, simply copy the record to tmpApprover approverRecord2.
  for i in 1 .. approverList.count loop

    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Searching through list of Approvers for match');
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  name: ' || tmpApprover.name || ' ? ' || approverList(i).name);
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  orig_system: ' || tmpApprover.orig_system || ' ? ' || approverList(i).orig_system);
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  orig_system_id: ' || tmpApprover.orig_system_id || ' ? ' || approverList(i).orig_system_id);
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  authority: ' || tmpApprover.authority || ' ? ' || approverList(i).authority);
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  status is NULL or NOT SUPPRESSED: ' || approverList(i).approval_status);
      END IF;
    end if;

    if( approverList(i).name = tmpApprover.name and
        approverList(i).orig_system = tmpApprover.orig_system and
        approverList(i).orig_system_id = tmpApprover.orig_system_id and
        approverList(i).authority = tmpApprover.authority and
        ( approverList(i).approval_status is null or
          approverList(i).approval_status = ame_util.nullStatus or
          approverList(i).approval_status <> ame_util.suppressedStatus) ) then

           if g_fnd_debug = 'Y' then
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                  FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Found the approver to be deleted also in the list...');
                  FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  Approver Name = ' || tmpApprover.name);
                  FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  Approver Action Type Id = ' || approverList(i).action_type_id);
                  FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  Approver Status = ' ||  approverList(i).approval_status);
                END IF;
           end if;
          tmpApprover :=  approverList(i) ;
          exit;

    end if;
  end loop;

  -- Call the ame api to delete the approver.
  -- tmpApprover will be deleted from the approver list
  if g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame_api3.suppressApprover()..');
       END IF;
  end if;
  ame_api3.suppressApprover( applicationIdIn   => applicationId,
                             transactionIdIn   => pReqHeaderId,
                             approverIn        => tmpApprover,
                             transactionTypeIn => ameTransactionType
                           );

  if g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Done with ame_api3.suppressApprover()..');
       END IF;
  end if;

  if (tmpApprover.orig_system=ame_util.posOrigSystem) THEN

    SELECT FIRST_POSITION_ID
    INTO l_first_position_id
    FROM po_requisition_headers_all
    WHERE requisition_header_id = pReqHeaderId;

    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'POS Record is being suppressed.');
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Stored FIRST_POSITION_ID = ' || l_first_position_id);
      END IF;
    end if;

    if (tmpApprover.orig_system_id=l_first_position_id) then
    -- we are suppressing the First Position Approver;
    -- thus, we need to clear the values from the req headers table.

        UPDATE po_requisition_headers_all
        SET first_position_id = NULL, first_approver_id = NULL
        WHERE requisition_header_id = pReqHeaderId;

        if g_fnd_debug = 'Y' then
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name,
                 'Cleared first_position_id and first_approver_id from req_header table.');
          END IF;
        end if;

    END IF;
  END IF;

  -- Once we delete an approver from the approval list, get the updated approval list from ame.
  getAllApprovers(pReqHeaderId, ameTransactionType, pApprovalListStr, pApprovalListCount);

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Leaving delete_approver...');
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- pApprovalListStr :' || pApprovalListStr);
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- pApprovalListCount :' || pApprovalListCount);
      END IF;
  end if;

exception
  when NO_DATA_FOUND then
    pApprovalListCount := 0;
    pApprovalListStr := 'NO_DATA_FOUND';
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.NO_DATA_FOUND', 'NO_DATA_FOUND');
      END IF;
    end if;
  when others then
    pApprovalListCount := 0;
    pApprovalListStr := 'EXCEPTION:' || sqlerrm;
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
end;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_ame_approval_list
--Function:
--  Call AME API to build the latest approver list.
--  If the approver list should be defaulted,
--  Then the history of the list will be cleared before building a list, except the following case:
--    If the defaulting is for opening saved cart:
--    (an incompleted requisition which did not have past approval action)

--Parameters:
--IN:
--    pReqHeaderId       Requisition Header ID
--    pDefaultFlag       Value 1 if approver list should be defaulted.
--                       Value -1 if approver list is to be rebuilt for iP approver checkout
--                       null value if the latest approver list is to be
--                       retrieved in all other cases.

--OUT:
--    pApprovalListStr   Approval List concatenated in a string
--    pApprovalListCount Number of Approvers.
--                       It has a value of 0, if the document does not require approval.
--    pQuoteChar         Quote Character, used for escaping purpose in tokenization
--    pFieldDelimiter    Field Delimiter, used for delimiting list string into elements.
--    pApprovalAction    'Y' if there were approvers taken action on the document.
--                       Those approvers are not included in the list,
--                       Only the future approvers are returned.
--End of Comments
--------------------------------------------------------------------------------
procedure get_ame_approval_list(pReqHeaderId    IN  NUMBER,
                            pDefaultFlag        IN  NUMBER,
                            pApprovalListStr    OUT NOCOPY VARCHAR2,
                            pApprovalListCount  OUT NOCOPY NUMBER,
                            pQuoteChar              OUT NOCOPY VARCHAR2,
                            pFieldDelimiter         OUT NOCOPY VARCHAR2,
                            pApprovalAction OUT NOCOPY VARCHAR2
) IS

  l_api_name varchar2(50):= 'get_ame_approval_list';
  --approverList      ame_util.approversTable;
  clearListForSavedCart varchar2(1) := 'N';
  authorizationStatus po_requisition_headers.authorization_status%TYPE;
  preparerId po_requisition_headers.preparer_id%TYPE;
  ameTransactionType po_document_types.ame_transaction_type%TYPE;

  l_itemtype po_requisition_headers.wf_item_type%TYPE;
  l_itemkey po_requisition_headers.wf_item_key%TYPE;

  approverList      ame_util.approversTable2;
  l_process_out      VARCHAR2(10);
  l_progress      VARCHAR2(10);
  l_appr NUMBER;

BEGIN

   if g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering get_ame_approval_list...');
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pReqHeaderId :' || pReqHeaderId );
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pDefaultFlag :' || pDefaultFlag );
       END IF;
   end if;

  -- pDefaultFlag:
  --    -1: Approver Checkout
  --     1: Possible Reset
  --     2: Force Reset
  --  null: Load Current List

  if (pDefaultFlag = -1) then
    SELECT wf_item_type, wf_item_key
    INTO l_itemtype, l_itemkey
    FROM po_requisition_headers_all
    WHERE requisition_header_id = pReqHeaderId;
    ameTransactionType := PO_WF_UTIL_PKG.GetItemAttrText( itemtype => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'AME_TRANSACTION_TYPE');
  else
    getAmeTransactionType(pReqHeaderId => pReqHeaderId,
                    pAmeTransactionType => ameTransactionType);
  end if;

  pQuoteChar :=quoteChar;
  pFieldDelimiter :=fieldDelimiter;

  if (pDefaultFlag=1 OR pDefaultFlag=2) then
    /* check to see it is not open saved cart */
    select authorization_status, preparer_id
    into authorizationStatus, preparerId
    from po_requisition_headers
    where requisition_header_id = pReqHeaderId;

    -- Get the approval list from ame.
    -- Based on our function design, we clear the approval list before calling the getAllApprovers7 call.
    -- If we call clearAllApprovals all the inserted/deleted approvers by the users will be ignored.
    -- AME will return the rule generated approvers if we call getAllApprovers after the clearAllApprovals call.

    if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'authorizationStatus :' || authorizationStatus);
         END IF;
    end if;

    -- if INCOMPLETE and pDefaultFlag is 1 (non-force), then check to see if we should reset or not
    if (authorizationStatus = 'INCOMPLETE' AND pDefaultFlag=1) then

      if g_fnd_debug = 'Y' then
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
             FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame_api2.getAllApprovers7()a...');
           END IF;
      end if;

  BEGIN
 l_progress := '000';

 /*Bug 6314864 and 10107113: commented in case of final approver times out*/

      ame_api2.getAllApprovers7( applicationIdIn   => applicationId,
                                 transactionIdIn   => pReqHeaderId,
                                 transactionTypeIn => ameTransactionType,
                                 approvalProcessCompleteYNOut => l_process_out,
                                 approversOut      => approverList
                               );
     l_progress := '001';

      if g_fnd_debug = 'Y' then
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
             FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' Done with ame_api6.getApprovers...progress='|| l_progress );
           END IF;
      end if;

      for i in 1 .. approverList.count loop
        if(approverList(i).approval_status is not null
            and approverList(i).orig_system_id <> preparerId) then
          /* this is not a saved cart, need to clear the list */
          clearListForSavedCart := 'Y';
          l_progress := '005';
          exit;
        end if;
      end loop;

  EXCEPTION when others then
     SELECT Count(*) INTO  l_appr
      FROM po_action_history WHERE
      object_id =pReqHeaderId
      AND  OBJECT_TYPE_CODE =  'REQUISITION'
      AND  ACTION_CODE <> 'SUBMIT';

     if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Exception in ame_api2.getAllApprovers7,l_appr= ' || l_appr||' progress='|| l_progress );
         END IF;
      end if;
     IF l_appr <> 0 THEN
           clearListForSavedCart := 'Y';
     END IF;

   END;

      if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'clearListForSavedCart :' || clearListForSavedCart);
         END IF;
      end if;

      if (clearListForSavedCart = 'Y') then

         -- clear columns since we are rebuilding the approval list
         UPDATE po_requisition_headers_all
         SET first_position_id = NULL, first_approver_id = NULL
         WHERE requisition_header_id = pReqHeaderId;

         if g_fnd_debug = 'Y' then
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name,
                 'Cleared first_position_id and first_approver_id from req_header table.');
               FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame_api2.clearAllApprovals()a...');
             END IF;
         end if;

         ame_api2.clearAllApprovals( applicationIdIn   => applicationId,
                                     transactionIdIn   => pReqHeaderId,
                                     transactionTypeIn => ameTransactionType
                                   );

         if g_fnd_debug = 'Y' then
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Done with ame_api2.clearAllApprovals()a...');
             END IF;
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame_api2.getAllApprovers7()b...');
             END IF;
         end if;

         ame_api2.getAllApprovers7( applicationIdIn   => applicationId,
                                    transactionIdIn   => pReqHeaderId,
                                    transactionTypeIn => ameTransactionType,
                                    approvalProcessCompleteYNOut => l_process_out,
                                    approversOut      => approverList
                                  );
        if g_fnd_debug = 'Y' then
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Done with ame_api2.getAllApprovers7()b...');
             END IF;
         end if;

      end if; -- if(clearListForSavedCart = 'Y')

    else -- if (pDefaultFlag=2) or (pDefaultFlag=1 and not INCOMPLETE), this will force the reset

       -- clear columns since we are rebuilding the approval list
       UPDATE po_requisition_headers_all
       SET first_position_id = NULL, first_approver_id = NULL
       WHERE requisition_header_id = pReqHeaderId;

       if g_fnd_debug = 'Y' then
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
             FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name,
               'Cleared first_position_id and first_approver_id from req_header table.');
             FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame_api2.clearAllApprovals()b...');
           END IF;
       end if;

       ame_api2.clearAllApprovals( applicationIdIn   => applicationId,
                                   transactionIdIn   => pReqHeaderId,
                                   transactionTypeIn => ameTransactionType
                                  );

       if g_fnd_debug = 'Y' then
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Done with ame_api2.clearAllApprovals()b...');
             END IF;
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame_api2.getAllApprovers7()c...');
             END IF;
       end if;

       ame_api2.getAllApprovers7( applicationIdIn   => applicationId,
                                  transactionIdIn   => pReqHeaderId,
                                  transactionTypeIn => ameTransactionType,
                                  approvalProcessCompleteYNOut => l_process_out,
                                  approversOut      => approverList
                                );
      if g_fnd_debug = 'Y' then
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
             FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Done with ame_api2.getAllApprovers7()c...');
           END IF;
      end if;

   end if; -- if ( authorizationStatus = 'INCOMPLETE')

  else -- if pDefaultFlag is null or -1

   if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame_api2.getAllApprovers7()d...');
         END IF;
   end if;

   ame_api2.getAllApprovers7( applicationIdIn   => applicationId,
                              transactionIdIn   => pReqHeaderId,
                              transactionTypeIn => ameTransactionType,
                              approvalProcessCompleteYNOut => l_process_out,
                              approversOut      => approverList
                            );

   if g_fnd_debug = 'Y' then
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Done with ame_api2.getAllApprovers7()d...');
        END IF;
   end if;

  end if; -- if(pDefaultFlag = 1)

  if(approverList.count > 0) then
    pApprovalListStr := serializeApproversTable( approverList, pReqHeaderId, pApprovalListCount, pApprovalAction );
  else
    pApprovalListCount:=0;
  end if;
  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Leaving get_ame_approval_list...');
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- pApprovalListStr :' || pApprovalListStr);
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- pApprovalListCount :' || pApprovalListCount);
      END IF;
  end if;

exception
  when NO_DATA_FOUND then
    pApprovalListCount := 0;
    pApprovalListStr := 'NO_DATA_FOUND';
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.NO_DATA_FOUND', 'NO_DATA_FOUND');
      END IF;
    end if;
  when others then
    pApprovalListCount := 0;
    pApprovalListStr := 'EXCEPTION:' || sqlerrm;
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
END get_ame_approval_list;

--------------------------------------------------------------------------------
--Start of Comments
--Name: is_ame_reqapprv_workflow
--Function:
--  Returns 'Y' if the requisition workflow uses AME for approval routing
--  Returns 'N' if the requisition workflow does not AME for approval routing

--Parameters:
--IN:
--    pReqHeaderId       Requisition Header ID
--OUT:
--    None
--End of Comments
--------------------------------------------------------------------------------
function is_ame_reqapprv_workflow (pReqHeaderId    IN  NUMBER,
                                   pIsRcoApproval  IN BOOLEAN,
                                   xAmeTransactionType OUT NOCOPY VARCHAR2)
return varchar2 IS
  isAmeApproval varchar2 (1);
  l_itemtype po_requisition_headers.wf_item_type%TYPE;
  l_itemkey po_requisition_headers.wf_item_key%TYPE;

BEGIN

  if (pIsRcoApproval) then
    SELECT DISTINCT wf_item_type, wf_item_key
    INTO l_itemtype, l_itemkey
    FROM po_change_requests
    WHERE document_header_id= pReqHeaderId AND
          document_type = 'REQ' AND
          action_type IN ('MODIFICATION', 'CANCELLATION') AND
          creation_date = (select max(creation_date)
                          from PO_CHANGE_REQUESTS
                          where DOCUMENT_HEADER_ID = pReqHeaderId) AND
          request_status NOT IN ('ACCEPTED', 'REJECTED');
  else
    SELECT wf_item_type, wf_item_key
    INTO l_itemtype, l_itemkey
    FROM po_requisition_headers_all
    WHERE requisition_header_id = pReqHeaderId;
  end if;

  isAmeApproval := PO_WF_UTIL_PKG.GetItemAttrText( itemtype => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'IS_AME_APPROVAL');

  if (isAmeApproval = 'Y') then
   xAmeTransactionType := PO_WF_UTIL_PKG.GetItemAttrText( itemtype => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'AME_TRANSACTION_TYPE');
   return 'Y';
  else
   return 'N';
  end if;
END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_old_approval_list
--Function:
--  Call AME API to get the existing approval list for a requisition.
--  Only the future approval list is returned.

--Parameters:
--IN:
--    pReqHeaderId       Requisition Header ID
--OUT:
--    pApprovalListStr   Furture Approval List concatenated in a string
--    pApprovalListCount Number of Approvers. It has a value of 0,
--                       if AME did not build approval list for this transaction.
--    pQuoteChar         Quote Character, used for escaping purpose in tokenization
--    pFieldDelimiter    Field Delimiter, used for delimiting list string into elements.
--End of Comments
--------------------------------------------------------------------------------
procedure get_old_approval_list(pReqHeaderId    IN  NUMBER,
                            pApprovalListStr    OUT NOCOPY VARCHAR2,
                            pApprovalListCount  OUT NOCOPY NUMBER,
                            pQuoteChar          OUT NOCOPY VARCHAR2,
                            pFieldDelimiter     OUT NOCOPY VARCHAR2) IS

  l_api_name varchar2(50):= 'get_old_approval_list';
  hasApprovalAction varchar2(1);
  approverCount number;
  approverList      ame_util.approversTable2;
  ameTransactionType po_document_types.ame_transaction_type%TYPE;
  authorizationStatus po_requisition_headers_all.authorization_status%TYPE;
  isRcoApproval boolean := false;
  changeRequestExist number := 0;
  l_process_out VARCHAR2(10);

BEGIN

   if g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering get_old_approval_list...');
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pReqHeaderId :' || pReqHeaderId );
       END IF;
   end if;

  begin
    select authorization_status
    into authorizationStatus
    from po_requisition_headers_all
    where requisition_header_id = pReqHeaderId;
  exception
    when others then
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
    return;
  end;

  if g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'authorizationStatus :' || authorizationStatus);
       END IF;
  end if;

  if (authorizationStatus <> 'IN PROCESS' and authorizationStatus <> 'PRE-APPROVED') then
    -- if the requisition is approved, check if it is rco transaction
    if (authorizationStatus = 'APPROVED') then
      begin
        SELECT COUNT(1)
        INTO changeRequestExist
        FROM
          PO_CHANGE_REQUESTS pcr
        WHERE
          pcr.document_header_id = pReqHeaderId AND
          pcr.document_type = 'REQ' AND
          pcr.action_type IN ('MODIFICATION', 'CANCELLATION') AND
          pcr.approval_required_flag = 'Y' AND
          pcr.request_status NOT IN ('ACCEPTED', 'REJECTED');
      exception
        when others then
          null; -- assume not rco or the rco is approved/rejected.
      end;
      if (changeRequestExist>0) then
        isRcoApproval :=true;
      else
        return;
      end if;
    else
      return;
    end if;
  end if;

  if (is_ame_reqapprv_workflow (pReqHeaderId, isRcoApproval, ameTransactionType) <> 'Y') then

    pApprovalListCount := 0;
    if g_fnd_debug = 'Y' then
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Leaving get_old_approval_list due to the call is_ame_reqapprv_workflow()...');
        END IF;
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- pApprovalListCount :' || pApprovalListCount);
        END IF;
    end if;
    return;
  end if;

  pQuoteChar :=quoteChar;
  pFieldDelimiter :=fieldDelimiter;

   if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame_api3.getOldApprovers()...');
         END IF;
   end if;

  /*
  ame_api3.getOldApprovers(applicationIdIn=>applicationId,
                            transactionIdIn=>pReqHeaderId,
                            transactionTypeIn=>ameTransactionType,
                            oldApproversOut=>approverList);
  */

 /* ame_api2.getAllApprovers7( applicationIdIn => applicationId,
                             transactionIdIn => pReqHeaderId,
                             transactionTypeIn => ameTransactionType,
                             approvalProcessCompleteYNOut => l_process_out,
                             approversOut => approverList
                            );*/

  ame_api6.getApprovers2( applicationIdIn => applicationId,
	   transactionTypeIn => ameTransactionType,
 	   transactionIdIn => pReqHeaderId,
                             approversOut => approverList
                            );

   if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Done with ame_api3.getOldApprovers()...');
         END IF;
   end if;

  pApprovalListCount := approverList.count;

  if(approverList.count>0) then
    pApprovalListStr := serializeApproversTable(approverList, pReqHeaderId, approverCount, hasApprovalAction);
    pApprovalListCount := approverCount;
  end if;

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Leaving get_old_approval_list...');
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- pApprovalListStr :' || pApprovalListStr);
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- pApprovalListCount :' || pApprovalListCount);
      END IF;
  end if;

exception
  when NO_DATA_FOUND then
    pApprovalListCount := 0;
    pApprovalListStr := 'NO_DATA_FOUND';
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.NO_DATA_FOUND', 'NO_DATA_FOUND');
      END IF;
    end if;
  when others then
    pApprovalListCount := 0;
    pApprovalListStr := 'EXCEPTION';
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: is_req_pre_approved
--Function:
--  Approval workflow PL/SQL handler
--  Check AME approval list to determine if the document requires approval
--  from a chain of authority approver
--  Return 'Y' if yes
--  Return 'N' if no

--Parameters:
--  Standard workflow in/out parameters

--End of Comments
--------------------------------------------------------------------------------
procedure is_req_pre_approved(itemtype        in varchar2,
                                itemkey       in varchar2,
                                actid         in number,
                                funcmode      in varchar2,
                                resultout     out NOCOPY varchar2) is

  l_api_name varchar2(50):= 'is_req_pre_approved';
  x_progress  varchar2(100);
  x_resultout varchar2(30);
  l_document_id  number;
  l_return_val varchar2(1);

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  approverCount integer;
  approvers ame_util.approversTable2;
  ameTransactionType po_document_types.ame_transaction_type%TYPE;
  l_process_out VARCHAR2(10);

BEGIN

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering is_req_pre_approved...');
      END IF;
  end if;

  x_progress := 'POR_AME_APPROVAL_LIST.is_req_pre_approved: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  l_return_val := 'Y';


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  getAmeTransactionType(pReqHeaderId => to_number(l_document_id),
                    pAmeTransactionType => ameTransactionType);

  x_progress := 'POR_AME_APPROVAL_LIST.is_req_pre_approved: 02' || ameTransactionType;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- Get the list of approvers from ame.
  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame_api2.getAllApprovers7()...');
      END IF;
  end if;

  ame_api2.getAllApprovers7( applicationIdIn => applicationId,
                             transactionIdIn => l_document_id,
                             transactionTypeIn => ameTransactionType,
                             approvalProcessCompleteYNOut => l_process_out,
                             approversOut => approvers
                            );
  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Done with ame_api2.getAllApprovers7()...');
      END IF;
  end if;
  approverCount := approvers.count;

  -- Once we get the list of approvers from AME, check for the approval_status in all the record.
  for i in 1 .. approverCount loop
    if(approvers(i).authority = ame_util.authorityApprover and
           (approvers(i).api_insertion = ame_util.oamGenerated or
            approvers(i).api_insertion = ame_util.apiAuthorityInsertion) and
           (approvers(i).approval_status is null or
            approvers(i).approval_status = ame_util.nullStatus)) then
      l_return_val := 'N';
      exit;
    end if;
  end loop;

  resultout := wf_engine.eng_completed || ':' ||  l_return_val;
  x_resultout := l_return_val;

  x_progress := 'POR_AME_APPROVAL_LIST.is_req_pre_approved: 02. RESULT= ' || x_resultout;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Leaving is_req_pre_approved...');
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- x_resultout :' || x_resultout);
      END IF;
  end if;

EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('POR_AME_APPROVAL_LIST' , 'is_req_pre_approved', itemtype, itemkey, x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'POR_AME_APPROVAL_LIST.is_req_pre_approved');
    RAISE;

END is_req_pre_approved;


--------------------------------------------------------------------------------
--Start of Comments
--Name: get_first_authority_approver
--Function:
--  Call AME API to fetch the latest approval list
--  Then walk through the list to find a first chain of authority approver
--  for a requisition.
--  The procedure raises any exception thrown by AME engine.

--Parameters:
--IN:
--    pReqHeaderId       Requisition Header ID
--OUT:
--    xPersonId          The person ID of the chain of authority approver
--                       This variable will have a null value,
--                       if such an approver is not found.

--End of Comments
--------------------------------------------------------------------------------
procedure get_first_authority_approver(pReqHeaderId    IN  NUMBER,
                                       xPersonId       OUT NOCOPY VARCHAR2) IS

  l_api_name varchar2(50):= 'get_first_authority_approver';
  approverCount number;
  approvers      ame_util.approversTable2;
  ameTransactionType po_document_types.ame_transaction_type%TYPE;
  l_process_out VARCHAR2(10);

BEGIN

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering get_first_authority_approver...');
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param -- pReqHeaderId ' || pReqHeaderId );
      END IF;
  end if;

  xPersonId := null;
  getAmeTransactionType(pReqHeaderId => pReqHeaderId,
                    pAmeTransactionType => ameTransactionType);

  -- Get the approvers list from ame.
  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame_api2.getAllApprovers7()...');
      END IF;
  end if;

  ame_api2.getAllApprovers7( applicationIdIn => applicationId,
                             transactionIdIn => pReqHeaderId,
                             transactionTypeIn => ameTransactionType,
                             approvalProcessCompleteYNOut => l_process_out,
                             approversOut => approvers
                            );

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Done with ame_api2.getAllApprovers7()...');
      END IF;
  end if;

  approverCount := approvers.count;

  -- Once we get the list of approvers from ame, check for the first authority approver record in the list.
  -- Check for the action type(POS/PER) in the first authority approver record.
  -- If the first record is of position hierarchy type, then find out the person_id from the position id and return that.
  -- Otherwise simply return the person_id from the orig_system_id value.

  for i in 1 .. approverCount loop
    if(approvers(i).authority = ame_util.authorityApprover and
           approvers(i).api_insertion = ame_util.oamGenerated and
           (approvers(i).approval_status is null or
            approvers(i).approval_status = ame_util.nullStatus)) then

              if approvers(i).orig_system = ame_util.posOrigSystem then

                   if g_fnd_debug = 'Y' then
                        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'First record is Position Hierarchy action type...');
                        END IF;
                   end if;

                   begin
                       SELECT person_id into xPersonId FROM (
                          SELECT person.person_id FROM per_all_people_f person, per_all_assignments_f asg
                          WHERE asg.position_id = approvers(i).orig_system_id and trunc(sysdate) between person.effective_start_date
                          and nvl(person.effective_end_date, trunc(sysdate)) and person.person_id = asg.person_id
                          and asg.primary_flag = 'Y' and asg.assignment_type in ('E','C')
                          and ( person.current_employee_flag = 'Y' or person.current_npw_flag = 'Y' )
                          and asg.assignment_status_type_id not in (
                             SELECT assignment_status_type_id FROM per_assignment_status_types
                             WHERE per_system_status = 'TERM_ASSIGN'
                         ) and trunc(sysdate) between asg.effective_start_date and asg.effective_end_date order by person.last_name
                      ) where rownum = 1;
                   exception
                        WHEN NO_DATA_FOUND THEN
                        RAISE;
                   end;
              else
                  xPersonId := approvers(i).orig_system_id;
              end if;
      exit;
    end if;
  end loop;

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Leaving get_first_authority_approver...');
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- xPersonId :' || xPersonId);
      END IF;
  end if;

exception
  when others then
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
    raise;

END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: can_delete_oam_approvers
--Function:
--  Call AME API to fetch the value of the
--  ALLOW_DELETING_RULE_GENERATED_APPROVERS OAM attribute.
--  This attribute specifies whether approvers generated by
--  approval rules can be deleted from the approver list.

--Parameters:
--IN:
--    pReqHeaderId       Requisition Header ID
--OUT:
--    xResult            'Y' or 'N'
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE can_delete_oam_approvers( pReqHeaderId  IN NUMBER,
                                    xResult       OUT NOCOPY VARCHAR2) IS
  l_api_name varchar2(50):= 'can_delete_oam_approvers';
  attributeValue1 VARCHAR2(10);
  attributeValue2 VARCHAR2(10);
  attributeValue3 VARCHAR2(10);
  ameTransactionType po_document_types.ame_transaction_type%TYPE;

BEGIN

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering can_delete_oam_approvers...');
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param -- pReqHeaderId ' || pReqHeaderId );
      END IF;
  end if;

  getAmeTransactionType(pReqHeaderId => pReqHeaderId,
                    pAmeTransactionType => ameTransactionType);

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame_api3.getAttributeValue()...');
      END IF;
  end if;
  ame_api3.getAttributeValue(applicationIdIn => applicationId,
                             transactionTypeIn => ameTransactionType,
                             transactionIdIn => pReqHeaderId,
                             attributeNameIn => ame_util.allowDeletingOamApprovers,
                             itemIdIn => NULL,
                             attributeValue1Out => attributeValue1,
                             attributeValue2Out => attributeValue2,
                             attributeValue3Out => attributeValue3);

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Done with ame_api3.getAttributeValue()...');
      END IF;
  end if;

  IF attributeValue1 = 'true' THEN
    xResult := 'Y';
  ELSE
    xResult := 'N';
  END IF;

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Leaving can_delete_oam_approvers...');
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- xResult :' || xResult);
      END IF;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
    --raise;
    xResult := 'N';
END can_delete_oam_approvers;


/* private procedures */
procedure getAmeTransactionType(pReqHeaderId          IN  NUMBER,
                            pAmeTransactionType OUT NOCOPY VARCHAR2
) IS

  l_api_name varchar2(50):= 'getAmeTransactionType';
  changeRequestExist number := 0;
  docType po_document_types.document_type_code%TYPE;
  docSubType po_document_types.document_subtype%TYPE;
  lookupCode po_requisition_headers.type_lookup_code%TYPE;
  orgId NUMBER;

begin

  if g_fnd_debug = 'Y' then
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'pReqHeaderId: ' || pReqHeaderId);
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'current org id: ' || PO_MOAC_UTILS_PVT.get_current_org_id);
    END IF;
  end if;

  -- check if is rco, alternative is to check authorization status
  begin
    SELECT COUNT(1)
    INTO changeRequestExist
    FROM
     PO_CHANGE_REQUESTS pcr
    WHERE
     pcr.document_header_id = pReqHeaderId AND
     pcr.document_type = 'REQ' AND
     pcr.action_type IN ('MODIFICATION', 'CANCELLATION') AND
     pcr.request_status NOT IN ('ACCEPTED', 'REJECTED');
  exception
    when others then
        if g_fnd_debug = 'Y' then
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Not RCO');
          END IF;
        end if;
  end;

  if (changeRequestExist > 0) then
    docType := 'CHANGE_REQUEST';
    docSubType :='REQUISITION';

    SELECT org_id
      INTO orgId
      FROM po_requisition_headers_all
     WHERE requisition_header_id = pReqHeaderId;

  else
    docType := 'REQUISITION';
    begin
      SELECT type_lookup_code, org_id
      INTO lookupCode, orgId
      FROM po_requisition_headers_all
      WHERE requisition_header_id = pReqHeaderId;

    exception
      when others then
        if g_fnd_debug = 'Y' then
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Req not found');
          END IF;
        end if;
        lookupCode := 'PURCHASE'; -- assume not internal
    end;
    docSubType := lookupCode;
  end if;

  -- Use the private function to fetch the ame txn type given the doc type and subtype
  pAmeTransactionType := getAmeTxnType(docType, docSubType, orgId);

  if g_fnd_debug = 'Y' then
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'pAmeTransactionType: ' || pAmeTransactionType);
    END IF;
  end if;

end;

function getAmeTxnType (p_doc_type IN VARCHAR2,
                                      p_doc_subtype IN VARCHAR2,
				      p_org_id IN NUMBER)
				      return VARCHAR2 is
 x_ame_txn_type po_document_types_all_b.ame_transaction_type%TYPE;
BEGIN

    SELECT ame_transaction_type
    INTO x_ame_txn_type
    FROM po_document_types_all_b
    WHERE document_type_code = p_doc_type
    and document_subtype = p_doc_subtype
    and org_id = p_org_id;

    return x_ame_txn_type;

  EXCEPTION
    when others then
     return 'PURCHASE_REQ';
  END getAmeTxnType;

PROCEDURE marshalField(p_string     IN VARCHAR2,
                       p_quote_char IN VARCHAR2,
                       p_delimiter  IN VARCHAR2) IS
  l_string VARCHAR2(32767) := NULL;
BEGIN
  l_string := p_string;
  l_string := REPLACE(l_string, p_quote_char, p_quote_char || p_quote_char);
  l_string := REPLACE(l_string, p_delimiter, p_quote_char || p_delimiter);
  approvalListStr := approvalListStr ||l_string || p_delimiter;
END marshalField;


--------------------------------------------------------------------------------
--Start of Comments
--Name: serializeApproversTable
--Function:
-- This function will simply iterate thorugh the list
-- of approvers and frame an approver string from each approver record
-- and give the output.

-- If the approver record is of position hierarchy action type, then
-- the list of users associated to the position will be retrieved
-- and will be sort by last_name. Then the first user will be selected from the sorted list
-- and that user's person_id will be considered.

-- approverRecord.orig_system can have 3 values like following.
-- PER = Employee Supervisor action type --> approverRecord.orig_system_id will be person_id
-- POS = Position Hierarchy              --> approverRecord.orig_system_id will be position_id
-- FND = FND Users                       --> approverRecord.orig_system_id will be user_id

--Parameters:
--IN:
--    approversTableIn       Approvers List
--    reqHeaderId            ID of the requisition
--OUT:
--    approverCount          Total Number of approvers in the list.
--    hasApprovalAction      'Y' or 'N'
--End of Comments
--------------------------------------------------------------------------------
function serializeApproversTable( approversTableIn in ame_util.approversTable2,
                                  reqHeaderId in NUMBER,
                                  approverCount out nocopy number,
                                  hasApprovalAction out nocopy varchar2
                                )
                                return varchar2 as

  l_api_name varchar2(50):= 'serializeApproversTable';
  upperLimit integer;

  l_full_name per_all_people_f.full_name%TYPE;
  l_person_id per_all_people_f.person_id%TYPE;
  l_job_or_position VARCHAR2(2000);
  l_orig_system VARCHAR2(30);
  l_orig_system_id NUMBER;

  l_position_id NUMBER;
  l_job_id NUMBER;
  l_valid_approver VARCHAR2(1);
  l_preparer_id NUMBER;        --<bug 14395234>,
  l_preparer_pos_id NUMBER;    --<bug 14395234>

begin

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering serializeApproversTable...');
      END IF;
  end if;
  -- <bug 14395234>: enable this piece of code to get preparere_id
  select PREPARER_ID
  into l_preparer_id
  from po_requisition_headers_all
  where reqHeaderId = requisition_header_id;

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' l_preparer_id: ' || l_preparer_id);
      END IF;
  end if;

  approvalListStr := NULL;
  upperLimit := approversTableIn.count;

  approverCount := 0;
  hasApprovalAction := 'N';

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' upperLimit :' || upperLimit );
      END IF;
  end if;

  -- Iterate through the list of approvers.
  for i in 1 .. upperLimit loop

    if g_fnd_debug = 'Y' then
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' Processing the approver :' || i );
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  Orig_System :' || approversTableIn(i).orig_system);
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  Orig System Id :' || approversTableIn(i).orig_system_id);
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  Approval Status :' || approversTableIn(i).approval_status);
        END IF;
    end if;

    -- assume valid approver
    l_valid_approver := 'Y';
    -- <bug 14395234>: enable this piece of code in order to remove preparer from the approvals list when preparer is an approver
    -- and preparer's status is 'APPROVE'
    -- if we have a Emp-Sup approver, make sure the approverId
    -- is NOT the same as preparer's Id
    if (approversTableIn(i).orig_system = ame_util.perOrigSystem) then
      -- <bug 14395234>: added condition 'approversTableIn(i).approval_status = ame_util.approvedStatus'
      --bug 18673262:let preparer show up in the approval list when preparer is an approver
      if (approversTableIn(i).orig_system_id = l_preparer_id AND approversTableIn(i).approval_status = ame_util.approvedStatus AND approversTableIn(i).group_or_chain_id < 3) THEN
        l_valid_approver := 'N';
        if g_fnd_debug = 'Y' then
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  ApproverID matches l_preparer_id... skipping!');
          END IF;
        end if;
      end if;

    -- else if we have a position approver, make sure the position
    -- is NOT the same as preparer's position
    elsif (approversTableIn(i).orig_system = ame_util.posOrigSystem) then

      SELECT POSITION_ID
      INTO l_preparer_pos_id
      FROM PER_ALL_ASSIGNMENTS_F
      WHERE PERSON_ID = l_preparer_id
        and primary_flag = 'Y'
        and assignment_type in ('E','C')
        and assignment_status_type_id not in ( select assignment_status_type_id from per_assignment_status_types where per_system_status = 'TERM_ASSIGN')
        and TRUNC ( effective_start_date ) <=  TRUNC(SYSDATE)
        and NVL(effective_end_date, TRUNC( SYSDATE)) >= TRUNC(SYSDATE)
        and rownum = 1;
      -- <Bug 14395234>,added condition 'approversTableIn(i).approval_status = ame_util.approvedStatus'
      --bug 18673262:let preparer show up in the approval list when preparer is an approver
      if (approversTableIn(i).orig_system_id = l_preparer_pos_id AND approversTableIn(i).approval_status = ame_util.approvedStatus AND approversTableIn(i).group_or_chain_id < 3) then
        l_valid_approver := 'N';
        if g_fnd_debug = 'Y' then
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  Approvers Position matches preparers... skipping!');
          END IF;
        end if;
      end if;

    end if;  -- Checking PER and POS-based approver

-- bug 9559404 : end
   -- If the approval_status is not null, then we can assume the following.
   --  1. The approver is deleted.
   --  2. The approver is notified or approved/rejected.
   -- So if the approval_status is not null,
   -- we need to additionally check if the status is not notified and not suppressed and not approved,
   -- then do not consider the record.
   -- (we want to consider notified, suppressed and approved records)

   if( approversTableIn(i).approval_status is not null  AND
       approversTableIn(i).approval_status<>ame_util.notifiedStatus AND
       approversTableIn(i).approval_status<>ame_util.suppressedStatus AND
       approversTableIn(i).approval_status<>ame_util.approvedStatus) then

     hasApprovalAction := 'Y';
     if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  Approval_status is ' || approversTableIn(i).approval_status);
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '    ...so we do not consider this approver.');
         END IF;
     end if;

   elsif (l_valid_approver = 'Y') then

    l_orig_system    := approversTableIn(i).orig_system;
    l_orig_system_id := approversTableIn(i).orig_system_id;
    l_job_or_position := NULL;

    -- orig_system and orig_system_id should not be null.
    -- There is a bug 4403014 for the same. So this is a work-around to achieve the same.
    if l_orig_system is null and l_orig_system_id is null then
       SELECT orig_system, orig_system_id into l_orig_system, l_orig_system_id FROM wf_roles where name =  approversTableIn(i).name and rownum = 1;
    end if;

    if l_orig_system is null and l_orig_system_id is null then
         raise NO_DATA_FOUND;
    end if;

    if g_fnd_debug = 'Y' then
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  l_orig_system :' || l_orig_system );
        END IF;
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  l_orig_system_id :' || l_orig_system_id );
        END IF;
    end if;

    begin
        get_person_info( l_orig_system,
                         l_orig_system_id,
                         approversTableIn(i).display_name,
                         reqHeaderId,
                         g_fnd_debug,
                         l_person_id,
                         l_full_name);

    exception
         WHEN NO_DATA_FOUND THEN
                 -- No approvers found for this position. So we will skip this position.
                 l_valid_approver := 'N';

                 -- We raise the exception only for the last approver.
                 if i = upperLimit then
                     raise NO_DATA_FOUND;
                 end if;
    end;

    -- Find position | job name
    if ( l_orig_system = ame_util.posOrigSystem ) then
         l_job_or_position := approversTableIn(i).display_name;
    else
         l_job_or_position := null;
    end if;

    -- Verify the person_id is not null.
    if( l_valid_approver = 'Y' AND ( l_person_id is null or l_full_name is null ))then

        SELECT orig_system_id, display_name, description into l_person_id, l_full_name, l_job_or_position
        FROM wf_roles where name =  approversTableIn(i).name and rownum = 1;

        -- We raise the exception only for the last approver.
        --if l_person_id is null then
        if i = upperLimit then
            raise NO_DATA_FOUND;
        end if;

    end if;

    if g_fnd_debug = 'Y' then
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  l_full_name :' || l_full_name );
        END IF;
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  l_person_id :' || l_person_id );
        END IF;
    end if;

    -- Make sure position/job name is populated.
    if( l_job_or_position is null ) then

           -- retrieve the position name. if the position name is null check for the job name.

           SELECT position_id, job_id INTO l_position_id, l_job_id
           FROM per_all_assignments_f
           WHERE person_id = l_person_id
                and primary_flag = 'Y' and assignment_type in ('E','C')
                and assignment_status_type_id not in ( select assignment_status_type_id from per_assignment_status_types where per_system_status = 'TERM_ASSIGN')
                and TRUNC ( effective_start_date ) <=  TRUNC(SYSDATE) AND NVL(effective_end_date, TRUNC( SYSDATE)) >= TRUNC(SYSDATE)
                and rownum = 1;

           if l_position_id is not null then
               SELECT name INTO l_job_or_position FROM per_all_positions WHERE position_id = l_position_id;
           end if;

           if l_job_or_position is null and l_job_id is not null then
               SELECT name INTO l_job_or_position FROM per_jobs WHERE job_id = l_job_id;
           end if;

           if g_fnd_debug = 'Y' then
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  l_job_or_position :' || l_job_or_position );
                 END IF;
           end if;

    end if;

    -- If the approver is valid, then only frame the approver string.
    if( l_valid_approver = 'Y' ) then
        marshalField(l_full_name, quoteChar, fieldDelimiter);
        marshalField( to_char(l_person_id), quoteChar, fieldDelimiter);
        marshalField(l_job_or_position, quoteChar, fieldDelimiter);
        marshalField(approversTableIn(i).name, quoteChar, fieldDelimiter);

        --marshalField(approversTableIn(i).orig_system, quoteChar, fieldDelimiter);
        --marshalField(to_char(approversTableIn(i).orig_system_id), quoteChar, fieldDelimiter);

        marshalField(l_orig_system, quoteChar, fieldDelimiter);
        marshalField(to_char(l_orig_system_id), quoteChar, fieldDelimiter);

        marshalField(approversTableIn(i).api_insertion, quoteChar, fieldDelimiter);
        marshalField(approversTableIn(i).authority, quoteChar, fieldDelimiter);
        marshalField(approversTableIn(i).approval_status, quoteChar, fieldDelimiter);
        marshalField(approversTableIn(i).approver_category, quoteChar, fieldDelimiter);
        marshalField(approversTableIn(i).approver_order_number, quoteChar, fieldDelimiter);
        marshalField(approversTableIn(i).action_type_id, quoteChar, fieldDelimiter);
        marshalField(approversTableIn(i).group_or_chain_id, quoteChar, fieldDelimiter);
        marshalField(approversTableIn(i).member_order_number, quoteChar, fieldDelimiter);
        --marshalField(to_char(i), quoteChar, fieldDelimiter);
        approverCount := approverCount +1;
        marshalField(to_char(approverCount), quoteChar, fieldDelimiter);
    end if;

  end if; -- if approval_status is not null.
  end loop;

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Leaving serializeApproversTable...');
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- approvalListStr :' || approvalListStr );
      END IF;
  end if;
  return  approvalListStr;

exception
  when others then
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
    raise;
    return(null);
end serializeApproversTable;

procedure getAllApprovers(  pReqHeaderId             IN  NUMBER,
                            pAmeTransactionType      IN VARCHAR2,
                            pApprovalListStr         OUT NOCOPY VARCHAR2,
                            pApprovalListCount       OUT NOCOPY NUMBER)  IS

  l_api_name varchar2(50):= 'getAllApprovers';
  hasApprovalAction varchar2(1);
  approverList      ame_util.approversTable2;
  l_process_out     VARCHAR2(10);

begin


  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering getAllApprovers...');
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param -- pReqHeaderId :' || pReqHeaderId);
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame_api2.getAllApprovers7()...');
      END IF;
  end if;

  ame_api2.getAllApprovers7( applicationIdIn   => applicationId,
                             transactionIdIn   => pReqHeaderId,
                             transactionTypeIn => pAmeTransactionType,
                             approvalProcessCompleteYNOut => l_process_out,
                             approversOut      => approverList
                           );

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Done with ame_api2.getAllApprovers7()...');
      END IF;
  end if;

  if(approverList.count > 0) then
    /* no approver required */
    pApprovalListStr := serializeApproversTable(approverList, pReqHeaderId, pApprovalListCount, hasApprovalAction);
  else
    pApprovalListCount:=0;
  end if;

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Leaving getAllApprovers...');
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- approvalListStr :' || approvalListStr );
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- pApprovalListCount :' || pApprovalListCount );
      END IF;
  end if;

exception
  when others then
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
    raise;
end getAllApprovers;

function getAbsolutePosition(pReqHeaderId             IN  NUMBER,
                            pAmeTransactionType    IN VARCHAR2,
                            pPosition IN NUMBER)
return number  IS

  l_api_name varchar2(50):= 'getAbsolutePosition';
  approverList      ame_util.approversTable2;
  absolutePosition number := pPosition;
  numOfNullStatus number := 0;
  l_process_out      VARCHAR2(10);

begin

  ame_api2.getAllApprovers7( applicationIdIn=>applicationId,
                             transactionIdIn=>pReqHeaderId,
                             transactionTypeIn=>pAmeTransactionType,
                             approvalProcessCompleteYNOut => l_process_out,
                             approversOut=>approverList
                           );

  for i in 1 .. approverList.count loop
    if(approverList(i).approval_status is not null) then
      absolutePosition := absolutePosition + 1;
    else
      numOfNullStatus := numOfNullStatus + 1;
    end if;
    if(numOfNullStatus >= pPosition) then
      exit;
    end if;
  end loop;
  return absolutePosition;

exception
  when others then
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
    raise;

end getAbsolutePosition;

--------------------------------------------------------------------------------
--Start of Comments
--Name: retrieve_approval_info
--Function:
--  This procedure checks which approval is used.
--        -- whether AME is used for approval or PO Hierarchy approval.
--Parameters:
--IN:
--    pReqHeaderId                Requisition Header ID
--    pIsApprovalHistoryFlow   Flag indicating whether function is being
--                                         called from approval history flow
--OUT:
--    x_is_ame_approval  'Y' if AME is used for approval.
--    x_approval_status  Status of the req.
--    pQuoteChar         Quote Character, used for escaping purpose in tokenization
--    x_is_rco_approval  'Y' if RCO approval.
--End of Comments
--------------------------------------------------------------------------------
procedure retrieve_approval_info( p_req_header_id in number,
                                  p_is_approval_history_flow in varchar2,
                                  x_is_ame_approval out NOCOPY varchar2,
                                  x_approval_status out NOCOPY varchar2,
                                  x_is_rco_approval out NOCOPY varchar2
                                ) IS

  l_itemtype po_requisition_headers.wf_item_type%TYPE;
  l_itemkey po_requisition_headers.wf_item_key%TYPE;
  l_api_name varchar2(50):= 'retrieve_approval_info';

  l_change_request_group_id NUMBER;

  begin

   if g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering retrieve_approval_info...');
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - p_req_header_id :' || p_req_header_id );
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - p_is_approval_history_flow :' || p_is_approval_history_flow );

       END IF;
   end if;

   -- Initialize all the output params.
   x_is_rco_approval := 'N';
   x_is_ame_approval := 'N';
   x_approval_status := null;


   select authorization_status, wf_item_type, wf_item_key
      into x_approval_status, l_itemtype, l_itemkey
   from po_requisition_headers_all
         where requisition_header_id = p_req_header_id;

   if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' x_approval_status :' || x_approval_status );
         END IF;
   end if;

   -- Check whether it is ame approval or not.
   x_is_ame_approval := PO_WF_UTIL_PKG.GetItemAttrText( itemtype => l_itemtype,
                                                        itemkey    => l_itemkey,
                                                        aname      => 'IS_AME_APPROVAL'
                                                      );

   -- If the code is not being called from the approval history flow, check for pending change requests
   if (p_is_approval_history_flow <> 'Y') then

     -- First check whether change request is there or not.
     BEGIN
          SELECT max(change_request_group_id) INTO l_change_request_group_id
          FROM po_change_requests
          WHERE document_header_id = p_req_header_id
              AND document_type = 'REQ';
     EXCEPTION
        WHEN OTHERS THEN
            l_change_request_group_id := null;
     END;

     -- l_change_request_group_id is not null, then change request is there for the req.
     -- retrieve the status , wf_item_type and wf_item_key.
     IF l_change_request_group_id IS NOT NULL THEN

        x_is_rco_approval := 'Y';

        SELECT wf_item_type, wf_item_key,
               decode( request_status, 'ACCEPTED', x_approval_status,
                       'MGR_APP', 'APPROVED',
                       'REJECTED','REJECTED',
                       'IN PROCESS' )
        INTO l_itemtype, l_itemkey, x_approval_status
        FROM po_change_requests
        WHERE document_header_id = p_req_header_id
              AND change_request_group_id = l_change_request_group_id
              AND document_type = 'REQ'
              AND action_type <> 'DERIVED'
              AND rownum = 1;

     END IF;

   end if; -- end of RCO check...

   -- get the authorization status meaning from fnd_loopup_values_vl
   SELECT distinct meaning into x_approval_status
   FROM fnd_lookup_values_vl
   WHERE lookup_code = x_approval_status and lookup_type = 'AUTHORIZATION STATUS';

   -- Check RCO approval type is ame approval or not.
   if( 'Y' =  x_is_rco_approval ) then
       if( l_itemtype is not null AND  l_itemkey is not null ) then
           x_is_ame_approval := PO_WF_UTIL_PKG.GetItemAttrText( itemtype => l_itemtype,
                                                                itemkey    => l_itemkey,
                                                                aname      => 'IS_AME_APPROVAL'
                                                              );
       end if;
   end if;

   if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' x_is_ame_approval :' || x_is_ame_approval );
         END IF;
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' x_is_rco_approval :' || x_is_rco_approval );
         END IF;
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' x_approval_status :' || x_approval_status );
         END IF;
   end if;

exception
    when others then
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
    raise;
end RETRIEVE_APPROVAL_INFO;

--------------------------------------------------------------------------------
--Start of Comments
--Name: retrieve_approver_info
--Function:
--  This procedure retrieves the approver's title and email.
--Parameters:
--IN:
--    pReqHeaderId       Requisition Header ID
--OUT:
--    x_title - title of the approver.
--    x_email - email of the approver.
--End of Comments
--------------------------------------------------------------------------------
procedure retrieve_approver_info( p_approver_id in number,
                                  x_title out NOCOPY varchar2,
                                  x_email out NOCOPY varchar2
                                ) IS

  l_api_name varchar2(50):= 'retrieve_approver_info';
  l_position_id number;
  l_job_id number;

  begin

   if g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering retrieve_approver_info...');
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - p_approver_id :' || p_approver_id );
       END IF;
   end if;

   x_title := null;
   x_email := null;

   -- first get the email id.
   SELECT email_address INTO x_email FROM per_all_people_f
          WHERE person_id = p_approver_id
          AND TRUNC ( effective_start_date ) <=  TRUNC(SYSDATE) AND NVL(effective_end_date, TRUNC( SYSDATE)) >= TRUNC(SYSDATE)
          AND rownum = 1;

   if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' x_email :' || x_email );
         END IF;
   end if;

   -- retrieve the position name. if the position name is null check for the job name.
   SELECT position_id, job_id INTO l_position_id, l_job_id
   FROM per_all_assignments_f
   WHERE person_id = p_approver_id
        and primary_flag = 'Y' and assignment_type in ('E','C')
        and assignment_status_type_id not in ( select assignment_status_type_id from per_assignment_status_types where per_system_status = 'TERM_ASSIGN')
        and TRUNC ( effective_start_date ) <=  TRUNC(SYSDATE) AND NVL(effective_end_date, TRUNC( SYSDATE)) >= TRUNC(SYSDATE)
        and rownum = 1;

   if l_position_id is not null then
       SELECT name INTO x_title FROM per_all_positions WHERE position_id = l_position_id;
   end if;

   if x_title is null and l_job_id is not null then
       SELECT name INTO x_title FROM per_jobs WHERE job_id = l_job_id;
   end if;

   if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' x_title :' || x_title );
         END IF;
   end if;

exception
    when others then
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
end retrieve_approver_info;
--------------------------------------------------------------------------------
--Start of Comments
--Name: get_approval_group_name
--Function:
--  This procedure retrieves the approval group name for the given group id.
--Parameters:
--IN:
--    p_group_id       Group Id
--OUT:
--    x_group_name - Group name for the given group id.
--End of Comments
--------------------------------------------------------------------------------
function get_approval_group_name( p_group_id in number ) return varchar2 IS

  l_api_name varchar2(50):= 'get_approval_group_name';
  l_group_name varchar2(1000);

  begin

   if p_group_id is null then
       return '';
   end if;

   if g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering get_approval_group_name...');
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - p_group_id :' || p_group_id );
       END IF;
   end if;

   -- If the group id is less than 3, then it is not approval group.
   if p_group_id < 3 then
       return '';
   end if;

   l_group_name := 'Group:' || p_group_id;

   ame_api5.getApprovalGroupName( groupIdIn    => p_group_id,
                                  groupNameOut => l_group_name
                                );

   if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' l_group_name :' || l_group_name );
         END IF;
   end if;

   return l_group_name;

exception
    when others then
    l_group_name := 'Group:' || p_group_id;
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
    return l_group_name;
end get_approval_group_name;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_ame_approval_list_history
--Function:
--  Call AME API to build the approver list history.
--Parameters:
--IN:
--    pReqHeaderId       Requisition Header ID
--    pCallingPage         The page from which the function is being called
--OUT:
--    pApprovalListStr   Approval List concatenated in a string
--    pApprovalListCount Number of Approvers.
--                       It has a value of 0, if the document does not require approval.
--    pQuoteChar         Quote Character, used for escaping purpose in tokenization
--    pFieldDelimiter    Field Delimiter, used for delimiting list string into elements.
--End of Comments
--------------------------------------------------------------------------------
procedure get_ame_approval_list_history( pReqHeaderId        IN  NUMBER,
                                         pCallingPage IN VARCHAR2,
                                         pApprovalListStr    OUT NOCOPY VARCHAR2,
                                         pApprovalListCount  OUT NOCOPY NUMBER,
                                         pQuoteChar          OUT NOCOPY VARCHAR2,
                                         pFieldDelimiter     OUT NOCOPY VARCHAR2
                                        ) IS

  l_api_name varchar2(50):= 'get_ame_approval_list_history';
  ameTransactionType po_document_types.ame_transaction_type%TYPE;

  l_itemtype po_requisition_headers.wf_item_type%TYPE;
  l_itemkey po_requisition_headers.wf_item_key%TYPE;

  approverList       ame_util.approversTable2;
  l_process_out      VARCHAR2(10);

  l_full_name per_all_people_f.full_name%TYPE;
  l_person_id per_all_people_f.person_id%TYPE;
  l_job_or_position VARCHAR2(2000);
  l_orig_system VARCHAR2(30);
  l_orig_system_id NUMBER;

  l_job_id number;
  l_position_id number;
  l_valid_approver VARCHAR2(1);

  l_preparer_id NUMBER;
  l_first_approver_id NUMBER;
  l_first_position_id NUMBER;
  l_org_id NUMBER;
  p_doc_type po_document_types_all_b.document_type_code%type;
  p_doc_subtype po_document_types_all_b.document_subtype%type;
  l_authorizationStatus po_requisition_headers_all.AUTHORIZATION_STATUS%type;
  l_change_pending_flag po_requisition_headers_all.CHANGE_PENDING_FLAG%type;
  l_approval_reqd_flag PO_CHANGE_REQUESTS.APPROVAL_REQUIRED_FLAG%type;

BEGIN

   if g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering get_ame_approval_list_history...');
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pReqHeaderId :' || pReqHeaderId );
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' current org Id: ' || PO_MOAC_UTILS_PVT.get_current_org_id);
       END IF;
   end if;

  select PREPARER_ID,
         first_position_id,
         first_approver_id,
         org_id,
         AUTHORIZATION_STATUS,
         CHANGE_PENDING_FLAG
  into   l_preparer_id,
         l_first_position_id,
         l_first_approver_id,
         l_org_id,
         l_authorizationStatus,
         l_change_pending_flag
  from   po_requisition_headers_all
  where  pReqHeaderId = requisition_header_id;

  --PO_MOAC_UTILS_PVT.set_org_context(l_org_id);

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' PreparerID for this req :' || l_preparer_id );
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' l_first_position_id: ' || l_first_position_id);
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' l_first_approver_id: ' || l_first_approver_id);
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' l_authorizationStatus: ' || l_authorizationStatus);
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' l_change_pending_flag: ' || l_change_pending_flag);
      END IF;
  end if;

  pQuoteChar := quoteChar;
  pFieldDelimiter := fieldDelimiter;

  approvalListStr := NULL;
  pApprovalListCount := 0;

    /*
      If the function is being called from approval history page or the change history page
      Set the appropriate document type and subtype and then get the corresponding
      ame transaction type
    */

   if (pCallingPage = 'fromChangeHistoryPage' OR pCallingPage = 'fromRCONotificationPage') then
     -- We are in RCO Modes...
     -- need to check if approval is even required.
     -- If not, then no approval needed for this RCO
     -- Simply return and do NOT build AME list
    begin
     select DISTINCT  nvl(APPROVAL_REQUIRED_FLAG, 'N')
     into l_approval_reqd_flag
     from PO_CHANGE_REQUESTS
     where DOCUMENT_HEADER_ID = pReqHeaderId
     and action_type IN ('MODIFICATION', 'CANCELLATION')
     and creation_date = (select max(creation_date)
                          from PO_CHANGE_REQUESTS
                          where DOCUMENT_HEADER_ID = pReqHeaderId);
    exception
      when others then
        l_approval_reqd_flag := 'Y';
    end;

     if (l_approval_reqd_flag = 'N') then

       if g_fnd_debug = 'Y' then
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  No Approval Required! RETURNING....');
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Leaving get_ame_approval_list...');
         END IF;
       end if;

       pApprovalListCount := 0;
       pApprovalListStr := '';

       RETURN;
     END IF;

     -- otherwise, AME required... continue with existing logic.
     p_doc_type := 'CHANGE_REQUEST';
     p_doc_subtype := 'REQUISITION';
   else
     p_doc_type := 'REQUISITION';

     begin
       SELECT type_lookup_code
       INTO p_doc_subtype
       FROM po_requisition_headers_all
       WHERE requisition_header_id = pReqHeaderId;

     exception
       when others then
         p_doc_subtype := 'PURCHASE';
     end;

   end if;

   ameTransactionType := getAmeTxnType(p_doc_type, p_doc_subtype, l_org_id);

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'ameTransactionType: ' || ameTransactionType);
      END IF;
  end if;

  -- if called from RCO page or RCO notification, we use change_pending_flag to determine if txn is in process
  -- otherwise, we look at authorizationStatus

  if ( (pCallingPage <> 'fromRCONotificationPage' AND pCallingPage <> 'fromChangeHistoryPage' AND l_authorizationStatus = 'IN PROCESS') OR
       (pCallingPage = 'fromRCONotificationPage' AND l_change_pending_flag = 'Y') OR
       (pCallingPage = 'fromChangeHistoryPage' AND l_change_pending_flag = 'Y') ) then

    -- if req is in process, then use ame_api2 which will rebuild the approval list
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Req is IN PROCESS: Using ame_api2 to REBUILD');
      END IF;
    end if;

    -- If we are going to use the flag approvalProcessCompleteYNOut,
    -- then we have to set the following flag.
    ame_util2.detailedApprovalStatusFlagYN := ame_util.booleanTrue;

    ame_api2.getAllApprovers7( applicationIdIn   => applicationId,
                               transactionIdIn   => pReqHeaderId,
                               transactionTypeIn => ameTransactionType,
                               approvalProcessCompleteYNOut => l_process_out,
                               approversOut      => approverList
                             );

    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'approvalProcessCompleteYNOut = ' || l_process_out);
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'getAllApprovers7 Done');
      END IF;
    end if;

  else
    -- otherwise, req is completed... so use ame_api6 to get the stored history w/o rebuilding

    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Req is COMPLETED: Using ame_api6 - NO REBUILD');
      END IF;
    end if;

    ame_api6.getApprovers(applicationIdIn   => applicationId,
                          transactionTypeIn => ameTransactionType,
                          transactionIdIn   => pReqHeaderId,
                          approversOut      => approverList);

    -- process is completed.  Set flag.
    l_process_out := 'Y';

    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'getApprovers Done');
      END IF;
    end if;

  END IF;

  -- Iterate through the list of approvers.
  for i in 1 .. approverList.count loop

    l_valid_approver := 'Y';
    if g_fnd_debug = 'Y' then
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' Processing the approver :' || i );
        END IF;
    end if;

    --bug 18673262:let preparer show up in the approval list when preparer is an approver
    if (l_preparer_id=approverList(i).orig_system_id AND approverList(i).approval_status = ame_util.approvedStatus AND approverList(i).group_or_chain_id < 3) THEN
      l_valid_approver := 'N';
      if g_fnd_debug = 'Y' then
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' ApproverID matches PreparerID... invalid approver!');
        END IF;
      end if;
    end if;

    if( ( ( l_process_out = 'Y' OR l_process_out = 'N' ) AND
          ( approverList(i).approval_status is not null AND
             ( approverList(i).approval_status not in
                ( ame_util.notifiedByRepeatedStatus,
                  ame_util.approvedByRepeatedStatus,
                  ame_util.rejectedByRepeatedStatus,
                  ame_util.repeatedStatus,
                  ame_util.noResponseStatus
                )
             )
          )
        ) OR
        ( ( l_process_out = 'W' OR  l_process_out = 'P' )AND
          ( approverList(i).approval_status is null OR
             ( approverList(i).approval_status not in
                ( ame_util.notifiedByRepeatedStatus,
                  ame_util.approvedByRepeatedStatus,
                  ame_util.rejectedByRepeatedStatus,
                  ame_util.repeatedStatus,
                  ame_util.noResponseStatus
                )
             )
          )
        )
      ) then

      l_orig_system    := approverList(i).orig_system;
      l_orig_system_id := approverList(i).orig_system_id;
      l_job_or_position := NULL;

      if ( l_orig_system = ame_util.perOrigSystem) then

        -- Employee Supervisor Record.
        if g_fnd_debug = 'Y' then
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Emp - Sup Record ...');
            END IF;
        end if;
        l_full_name := approverList(i).display_name;
        l_person_id := l_orig_system_id;

      elsif ( l_orig_system = ame_util.posOrigSystem) then

        -- Position Hierarchy Record. The logic is mentioned in the comments section.
        if g_fnd_debug = 'Y' then
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Position Hierarchy Record ...');
             END IF;
        end if;

        begin

          if (l_first_position_id is not NULL AND l_first_position_id=l_orig_system_id) then

            if g_fnd_debug = 'Y' then
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  Approver position matches l_first_position_id.');
                FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  Using stored l_first_approver_id as person_id.');
              END IF;
            end if;

            l_person_id := l_first_approver_id;

            SELECT full_name
            INTO l_full_name
            FROM per_all_people_f
            WHERE person_id = l_first_approver_id
            AND TRUNC(sysdate) between effective_start_date and effective_end_date;

          else
              SELECT person_id, full_name into l_person_id,l_full_name FROM (
                       SELECT person.person_id, person.full_name FROM per_all_people_f person, per_all_assignments_f asg
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
                 --RAISE;
                 l_valid_approver := 'N';
      END;

      elsif (l_orig_system = ame_util.fndUserOrigSystem) then

        -- FND User Record.
        if g_fnd_debug = 'Y' then
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
             FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'FND User Record ...');
           END IF;
        end if;
        SELECT employee_id into l_person_id
             FROM fnd_user
             WHERE user_id = l_orig_system_id
             and trunc(sysdate) between start_date and nvl(end_date, sysdate+1);

        l_full_name := approverList(i).display_name;

      end if;

      if g_fnd_debug = 'Y' then
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' l_full_name :' || l_full_name );
          END IF;
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' l_person_id :' || l_person_id );
         END IF;
      end if;

      -- Find position | job name
      if ( l_orig_system = ame_util.posOrigSystem ) then
         l_job_or_position := approverList(i).display_name;
      else
         l_job_or_position := null;
      end if;

      -- Make sure position/job name is populated.
      if( l_job_or_position is null ) then

           -- retrieve the position name. if the position name is null check for the job name.

           -- bug #15883770 relax the condition on employee assignment, that is
           -- to allow user to view the approval list regardless the current
           -- employee status (Employee, Ex-employee , etc..) for approved requisition
           SELECT position_id, job_id INTO l_position_id, l_job_id
           FROM per_all_assignments_f
           WHERE person_id = l_person_id
             and (l_authorizationStatus = 'APPROVED'
                 or (primary_flag = 'Y' and assignment_type in ('E','C')
                    and assignment_status_type_id not in ( select assignment_status_type_id from per_assignment_status_types where per_system_status = 'TERM_ASSIGN')
                    and TRUNC ( effective_start_date ) <=  TRUNC(SYSDATE) AND NVL(effective_end_date, TRUNC( SYSDATE)) >= TRUNC(SYSDATE)
                   )
                 )
             and rownum = 1;

           if l_position_id is not null then
               SELECT name INTO l_job_or_position FROM per_all_positions WHERE position_id = l_position_id;
           end if;

           if l_job_or_position is null and l_job_id is not null then
               SELECT name INTO l_job_or_position FROM per_jobs WHERE job_id = l_job_id;
           end if;

           if g_fnd_debug = 'Y' then
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' l_job_or_position :' || l_job_or_position );
                 END IF;
           end if;

      end if;

      if( l_valid_approver = 'Y' ) then
          marshalField(l_full_name, quoteChar, fieldDelimiter);
          marshalField( to_char(l_person_id), quoteChar, fieldDelimiter);
          marshalField(l_job_or_position, quoteChar, fieldDelimiter);
          marshalField(approverList(i).name, quoteChar, fieldDelimiter);

          --marshalField(approversTableIn(i).orig_system, quoteChar, fieldDelimiter);
          --marshalField(to_char(approversTableIn(i).orig_system_id), quoteChar, fieldDelimiter);

          marshalField(l_orig_system, quoteChar, fieldDelimiter);
          marshalField(to_char(l_orig_system_id), quoteChar, fieldDelimiter);

          marshalField(approverList(i).api_insertion, quoteChar, fieldDelimiter);
          marshalField(approverList(i).authority, quoteChar, fieldDelimiter);
          marshalField(approverList(i).approval_status, quoteChar, fieldDelimiter);
          marshalField(approverList(i).approver_category, quoteChar, fieldDelimiter);
          marshalField(approverList(i).approver_order_number, quoteChar, fieldDelimiter);
          marshalField(approverList(i).action_type_id, quoteChar, fieldDelimiter);
          marshalField(approverList(i).group_or_chain_id, quoteChar, fieldDelimiter);
          marshalField(approverList(i).member_order_number, quoteChar, fieldDelimiter);
         --marshalField(to_char(i), quoteChar, fieldDelimiter);
          pApprovalListCount := pApprovalListCount +1;
         marshalField(to_char(pApprovalListCount), quoteChar, fieldDelimiter);
       end if;

    end if;
  end loop;

  pApprovalListStr := approvalListStr;

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- pApprovalListStr :' || pApprovalListStr);
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- pApprovalListCount :' || pApprovalListCount);
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Leaving get_ame_approval_list...');
      END IF;
  end if;

exception
  when NO_DATA_FOUND then
    pApprovalListCount := 0;
    pApprovalListStr := 'NO_DATA_FOUND';
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.NO_DATA_FOUND', 'NO_DATA_FOUND');
      END IF;
    end if;
  when others then
    pApprovalListCount := 0;
    pApprovalListStr := 'EXCEPTION';
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
END get_ame_approval_list_history;


--------------------------------------------------------------------------------
--Start of Comments
--Name: get_next_approvers_info
--Function:
--  Call AME API to get approverId and approverName

--Parameters:
--IN:
--    pReqHeaderId       Requisition Header ID

--OUT:
--    x_approverId   Approver's ID
--    x_approverName Full name of the approver
--End of Comments
--------------------------------------------------------------------------------
procedure get_next_approvers_info(pReqHeaderId    IN  NUMBER,
                                  x_approverId    OUT NOCOPY NUMBER,
                                  x_approverName  OUT NOCOPY VARCHAR2
) IS

l_itemtype po_requisition_headers.wf_item_type%TYPE;
l_itemkey po_requisition_headers.wf_item_key%TYPE;
l_ameTransactionType po_document_types.ame_transaction_type%TYPE;
l_completeYNO varchar2(100);

l_approversList      ame_util.approversTable2;
l_approver_index NUMBER;
l_preparer_id number;
l_approverId number;
l_approverName VARCHAR2(240);
l_next_app_count number  :=0;

l_api_name varchar2(50):= 'get_next_approvers_info';
x_progress varchar2(100);

BEGIN
  if g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering get_next_approvers_info...');
       END IF;
  end if;

  x_progress := '001';
  getAmeTransactionType(pReqHeaderId => pReqHeaderId,
                    pAmeTransactionType => l_ameTransactionType);

  x_progress := '002';

  ame_api2.getAllApprovers7( applicationIdIn   => applicationId,
                             transactionIdIn   => pReqHeaderId,
                             transactionTypeIn => l_ameTransactionType,
                             approvalProcessCompleteYNOut => l_completeYNO,
                             approversOut      => l_approversList
                             );

  x_progress := '003';

  select PREPARER_ID
  into l_preparer_id
  from po_requisition_headers_all
  where pReqHeaderId = requisition_header_id;

  x_progress := '004';

  for i in 1 .. l_approversList.count loop
    if ( l_approversList(i).approval_status= 'NOTIFIED'
     and l_approversList(i).approver_category = ame_util.approvalApproverCategory ) then

       get_person_info(   l_approversList(i).orig_system,
                          l_approversList(i).orig_system_id,
                          l_approversList(i).display_name,
                          pReqHeaderId,
                          g_fnd_debug,
                          l_approverId,
                          l_approverName);

       if (l_approverId <> l_preparer_id ) then
         l_next_app_count := l_next_app_count + 1;
         x_approverId := l_approverId;
         x_approverName := l_approverName;
       end if;

    end if;
  end loop;

  x_progress := '006';

  if (l_next_app_count > 1 ) then

    -- if more than 1 approvers, approver_name is shown as 'MULTIPLE'
    x_approverName := 'MULTIPLE';
    x_approverId := NULL;

  end if;

  x_progress := '007';

  if g_fnd_debug = 'Y' then
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'x_approverId :' || x_approverId );
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' x_approverName:' || x_approverName);
         FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Leaving get_next_approvers_info...');
     END IF;
  end if;

EXCEPTION
  when others then
    x_approverId := -999;
    x_approverName := null;
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
    raise;

END get_next_approvers_info;


procedure get_person_info( p_origSystem   IN VARCHAR2,
                           p_origSystemId IN NUMBER,
                           p_displayName  IN VARCHAR2,
                           p_reqHeaderId  IN NUMBER,
                           p_logFlag      IN VARCHAR2,
                           x_personId    OUT NOCOPY NUMBER,
                           x_fullName    OUT NOCOPY VARCHAR2
) IS

  l_first_approver_id NUMBER;
  l_first_position_id NUMBER;

  l_api_name varchar2(50):= 'get_person_info';

BEGIN

  if p_logFlag = 'Y' then
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'get_person_info(+)');
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  p_origSystem = ' || p_origSystem);
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  p_origSystemId = ' || p_origSystemId);
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  p_displayName = ' || p_displayName);
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  p_reqHeaderId = ' || p_reqHeaderId);
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  p_logFlag = ' || p_logFlag);
    END IF;
  end if;

  if ( p_origSystem = ame_util.perOrigSystem) then

    -- Employee Supervisor Record.
    if p_logFlag = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  Employee Supervisor Record ...');
      END IF;
    end if;

    x_fullName := p_displayName;
    x_personId := p_origSystemId;

  elsif ( p_origSystem = ame_util.posOrigSystem) then

    -- Position Hierarchy Record.
    if p_logFlag = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  Position Hierarchy Record ...');
      END IF;
    end if;

    select first_position_id, first_approver_id
    into l_first_position_id, l_first_approver_id
    from po_requisition_headers_all
    where p_reqHeaderId = requisition_header_id;

    if p_logFlag = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  l_first_position_id: ' || l_first_position_id);
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  l_first_approver_id: ' || l_first_approver_id);
      END IF;
    end if;

    if (l_first_position_id is not NULL AND l_first_position_id = p_origSystemId) then
      -- use stored approver_id since position_id matches stored id

      if p_logFlag = 'Y' then
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  Approver position matches l_first_position_id.');
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  Using stored l_first_approver_id as person_id.');
        END IF;
      end if;

      x_personId := l_first_approver_id;

      SELECT full_name
      INTO x_fullName
      FROM per_all_people_f
      WHERE person_id = l_first_approver_id
      AND trunc(sysdate) between effective_start_date and effective_end_date;

    else
      SELECT person_id, full_name
      into x_personId, x_fullName
      FROM (
              SELECT person.person_id, person.full_name
              FROM per_all_people_f person, per_all_assignments_f asg
              WHERE asg.position_id = p_origSystemId
              and trunc(sysdate) between person.effective_start_date
              and nvl(person.effective_end_date, trunc(sysdate)) and person.person_id = asg.person_id
              and asg.primary_flag = 'Y' and asg.assignment_type in ('E','C')
              and ( person.current_employee_flag = 'Y' or person.current_npw_flag = 'Y' )
              and asg.assignment_status_type_id not in (
                  SELECT assignment_status_type_id
                  FROM per_assignment_status_types
                  WHERE per_system_status = 'TERM_ASSIGN'
                  )
              and trunc(sysdate) between asg.effective_start_date and asg.effective_end_date
              order by person.last_name
              )
      WHERE rownum = 1;

    end if;

  elsif (p_origSystem = ame_util.fndUserOrigSystem) then

    -- FND User Record.
    if p_logFlag = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  FND User Record ...');
      END IF;
    end if;

    SELECT employee_id
    into x_personId
    FROM fnd_user
    WHERE user_id = p_origSystemId
    and trunc(sysdate) between start_date and nvl(end_date, sysdate+1);

    x_fullName := p_displayName;

  end if;

  if p_logFlag = 'Y' then
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  x_fullName :' || x_fullName );
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, '  x_personId :' || x_personId );
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'get_person_info(-)');
    END IF;
  end if;

end get_person_info;

/* public API */
--------------------------------------------------------------------------------
--Start of Comments
--Name: is_req_forward_valid
--Function:
--  Call AME API to check whether the requisition can be forwareded in case of AME approvals
--Parameters:
--IN:
--    pReqHeaderId       Requisition Header ID
--    pPersonId          Person ID of a new first approver
--OUT:
--    pApprovalListStr   Approval List concatenated in a string
--    pApprovalListCount Number of Approvers.
--                       It has a value of 0, if the document does not require approval.
--    pQuoteChar         Quote Character, used for escaping purpose in tokenization
--    pFieldDelimiter    Field Delimiter, used for delimiting list string into elements.
--End of Comments
--------------------------------------------------------------------------------
FUNCTION  is_req_forward_valid( pReqHeaderId  IN NUMBER) RETURN VARCHAR2 IS

  l_api_name varchar2(50):= 'is_req_forward_valid';
  tmpApprover ame_util.approverRecord2;
  ameTransactionType po_document_types.ame_transaction_type%TYPE;

  approverList      ame_util.approversTable2;
  l_process_out      VARCHAR2(10);
  currentFirstApprover ame_util.approverRecord2;
  approvalList VARCHAR2(3000);
  apprCt NUMBER;
  appChar  VARCHAR2(3000);
  appDelim    VARCHAR2(3000);
  flag VARCHAR2(1) := 'Y';
begin
  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering is_req_forward_valid...');
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pReqHeaderId :' || pReqHeaderId );
      END IF;
  end if;

  getAmeTransactionType(pReqHeaderId => pReqHeaderId,
                    pAmeTransactionType => ameTransactionType);


  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Invoking ame api ame_api2.getAllApprovers7() to get the list of approvers from AME.' ||ameTransactionType );
      END IF;
  end if;

  IF ameTransactionType IS NOT NULL THEN
  -- get the current approvers list from AME.
  ame_api2.getAllApprovers7( applicationIdIn=>applicationId,
                             transactionIdIn=>pReqHeaderId,
                             transactionTypeIn=>ameTransactionType,
                             approvalProcessCompleteYNOut => l_process_out,
                             approversOut=>approverList
                           );

  if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Retrieved the list of approvers from AME using ame_api2.getAllApprovers7()');
      END IF;
  end if;

  -- Once we get the approvers list from AME, we iterate through the approvers list,
  -- to find out the current first authority approver.
  for i in 1 .. approverList.count loop
    if( approverList(i).authority = ame_util.authorityApprover
        and approverList(i).approval_status is null
        and approverList(i).api_insertion = 'N'
        and approverList(i).group_or_chain_id < 3 ) then

          if g_fnd_debug = 'Y' then
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Found the first authority approver...' || currentFirstApprover.name );
                FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Returing can forward Y' );

              END IF;
          end if;

          RETURN 'Y';
    end if;
  end loop;
  ELSE
      RETURN 'Y';


  END IF;
      if g_fnd_debug = 'Y' then
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Returing cannot forward N' );

              END IF;
          end if;

          RETURN 'N';

exception
  when NO_DATA_FOUND then


    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.NO_DATA_FOUND', 'NO_DATA_FOUND');
      END IF;
    end if;
     RETURN 'N';

  when others then
     if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
    ROLLBACK TO is_req_forward_valid;
     RETURN 'N';

end;

/* For bug 16064617 :: adding following proc which will be used in a New WF EVENT
   created for clearing AME approval list when approver rejects the requisition
   and Reject action gets successful just before sending FYI notification to preparer
   about rejection of document. */

procedure Clear_ame_apprv_list_reject(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

l_document_type         PO_DOCUMENT_TYPES_ALL.document_type_code%TYPE;
l_document_subtype      PO_DOCUMENT_TYPES_ALL.document_subtype%TYPE;
l_document_id           NUMBER;
l_ame_Transaction_Type  PO_DOCUMENT_TYPES_ALL.ame_transaction_type%TYPE;
l_progress  VARCHAR2(300) := '000';
l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
l_orgid number;

BEGIN

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_progress := 'Get doc attributes: 001';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  l_document_type    :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'DOCUMENT_TYPE');

  l_document_subtype :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'DOCUMENT_SUBTYPE');

  l_document_id      :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'DOCUMENT_ID');

 l_progress := 'Get doc attributes: 002 l_document_type :: '||l_document_type||
                'l_document_subtype :: '||l_document_subtype||'l_document_id :: '||l_document_id;

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

/*
** Desc Need to set the org context
*/

  l_progress := 'Get org_id: 003';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  l_progress := 'Get doc attributes: 004 l_orgid :: '||l_orgid;

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  IF l_orgid is NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12.MOAC>
  END IF;

  l_progress := 'Get ame transaction type: 005';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  IF l_document_type = 'REQUISITION' THEN

   BEGIN

    SELECT ame_transaction_type
      INTO l_ame_Transaction_Type
      FROM po_document_types
    WHERE document_type_code = l_document_type
      and document_subtype   = l_document_subtype;

   EXCEPTION

    WHEN OTHERS THEN

     l_ame_Transaction_Type := null;

   END;

  END IF;

  l_progress := 'Get ame transaction type: 006 l_ame_Transaction_Type :: '||l_ame_Transaction_Type;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;


  IF l_ame_Transaction_Type IS NOT NULL THEN

  l_progress := 'Ame Clear all approvals call: 007 ';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

      ame_api2.clearAllApprovals(applicationIdIn=>201,
                  transactionIdIn=>l_document_id,
                  transactionTypeIn=>l_ame_Transaction_Type);

  END IF;

  l_progress := 'Get_req_preparer_msg_attribute End : 008 ';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';


EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('POR_AME_APPROVAL_LIST' , 'Clear_ame_apprv_list_reject', itemtype, itemkey,l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm,
                                          'POR_AME_APPROVAL_LIST.CLEAR_AME_APPRV_LIST_REJECT');
    raise;

END Clear_ame_apprv_list_reject;

END por_ame_approval_list;

/
