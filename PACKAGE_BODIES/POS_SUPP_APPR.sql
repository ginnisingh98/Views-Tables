--------------------------------------------------------
--  DDL for Package Body POS_SUPP_APPR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPP_APPR" as
/* $Header: POSSPAPB.pls 120.6.12010000.48 2014/11/25 12:24:37 spapana ship $ */

g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),noChar);
g_module_prefix CONSTANT VARCHAR2(50) := 'pos.plsql.' || 'POS_SUPP_APPR' || '.';

approvalListStr          VARCHAR2(32767) := NULL;

------------------
--Private Routines
------------------

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

------------------
--End Private Routines
------------------


-------------------------------------------------------------------------------
-- PROCEDURE INITIALIZE_WF
--
-- Initializes WF attributes
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   resultout
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
-------------------------------------------------------------------------------
PROCEDURE INITIALIZE_WF(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT nocopy VARCHAR2)
IS
  l_api_name VARCHAR2(50)  := 'INITIALIZE_WF';
  l_progress VARCHAR2(4000) := '000';
BEGIN
  l_progress := l_api_name || ' 001';
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    wf_engine.SetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname => 'AME_PROCESS_STATUS', avalue => ameInprocessStatus);
    wf_engine.SetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname => 'APPROVER_RESPONSE', avalue => ame_util.noResponseStatus);

    l_progress  := l_api_name|| '   002 Setting WF attributes AME_PROCESS_STATUS and APPROVER_RESPONSE';
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;
    -- no result needed

    resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;

    RETURN;

  END IF;
  --
  -- CANCEL mode - activity 'compensation'
  --
  IF (funcmode = 'CANCEL') THEN

    -- no result needed
    resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
    RETURN;

  END IF;
  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  resultout := wf_engine.eng_null;
  RETURN;

EXCEPTION
WHEN OTHERS THEN
  -- The line below records this function call in the error system
  -- in the case of an exception.
  wf_core.context('POS_SUPP_APPR', 'INITIALIZE_WF', itemtype, itemkey, TO_CHAR(actid), funcmode);
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  raise;
END INITIALIZE_WF;

-- PROCEDURE IS_AME_ENABLED
--
-- Procedure to check if AME is enabled for Supplier Approval Management
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   resultout
--       - COMPLETE:Y
--       - COMPLETE:N
-------------------------------------------------------------------------------
PROCEDURE IS_AME_ENABLED(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT nocopy VARCHAR2)
IS

  l_profile_value VARCHAR2(1);
  l_api_name      VARCHAR2(50)  := 'IS_AME_ENABLED';
  l_progress      VARCHAR2(4000) := '000';

BEGIN

  l_progress := l_api_name || '   001';
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    CHECK_IF_AME_ENABLED( result => l_profile_value );

    l_progress    := l_api_name || '   002 CHECK_IF_AME_ENABLED returned - '||l_profile_value;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

    resultout := wf_engine.eng_completed ||':'|| l_profile_value;

    wf_engine.SetItemAttrText ( itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'AME_ENABLED',
                                avalue    => l_profile_value);

    IF (l_profile_value = noChar) THEN

      wf_engine.SetItemAttrText ( itemtype  => itemtype,
                                  itemkey   => itemkey,
                                  aname     => 'AME_PROCESS_STATUS',
                                  avalue    => noAme);

    END IF;

    l_progress := l_api_name || '   003  - WF attributes set';
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

    RETURN;

  END IF;

  resultout := wf_engine.eng_null;
  RETURN;

EXCEPTION
WHEN OTHERS THEN
  wf_core.context('POSSPAPP', 'POSSPAPP_PROCESS', itemtype, itemkey, TO_CHAR(actid), funcmode);
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RAISE;
END IS_AME_ENABLED;
-------------------------------------------------------------------------------
-- PROCEDURE GET_NEXT_APPROVER
--
-- Procedure to get next set of approvers from AME
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   resultout
--       - COMPLETE:VALID_NEXT_APPROVER
--           activity has completed, there is a valid next approver
--       - COMPLETE:NO_NEXT_APPROVER
--           activity has completed, no more approvers
-------------------------------------------------------------------------------
PROCEDURE GET_NEXT_APPROVER(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT nocopy VARCHAR2)
IS

  l_api_name         VARCHAR2(50)  := 'GET_NEXT_APPROVER';
  l_progress         VARCHAR2(4000) := '000';
  l_completeYNO      VARCHAR2(100);
  suppid             NUMBER;

BEGIN

  l_progress := l_api_name || ': 001';
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

    wf_engine.SetItemAttrText ( itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'APPROVER_RESPONSE',
                                avalue    => ame_util.noResponseStatus);

    suppid := wf_engine.GetItemAttrText(itemtype  => wfitemtype,
                                        itemkey   => itemkey,
                                         aname    => 'SUPP_REG_ID');

    ame_api2.getNextApprovers4( applicationIdIn   =>ameApplicationId,
                                transactionIdIn   =>suppid,
                                transactionTypeIn =>ameTransactionType,
                                approvalProcessCompleteYNOut=>l_completeYNO,
                                nextApproversOut  =>g_next_approvers );


    l_progress := l_api_name || ': 002   for AME transactionId - '|| suppid || ' getNextApprovers4 returns completeYNO - '
                   || l_completeYNO || 'approvers count-->' || g_next_approvers.Count;
    IF g_fnd_debug  = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

    resultout := 'COMPLETE:'||'VALID_NEXT_APPROVER';

    IF ( g_next_approvers.count > 0 ) THEN

      resultout :='COMPLETE:'||'VALID_NEXT_APPROVER';

      -- Assume that all approves return by this API are either fyiapprovercategory or ApproverTypeCategory.
      -- There shouldn't be case that FYI and Approver type members under same group
      IF ( g_next_approvers(g_next_approvers.first).approver_category = ame_util.fyiapprovercategory ) THEN

          wf_engine.SetItemAttrText ( itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'APPROVER_CATEGORY_FYI',
                                avalue    => yesChar);
      ELSE

          wf_engine.SetItemAttrText ( itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'APPROVER_CATEGORY_FYI',
                                avalue    => noChar);

      END IF;

    ELSIF (l_completeYNO  = yesChar) THEN

      resultout := wf_engine.eng_completed||':'||'NO_NEXT_APPROVER';

      wf_engine.SetItemAttrText ( itemtype  => itemtype,
                                  itemkey   => itemkey,
                                  aname     => 'AME_PROCESS_STATUS',
                                  avalue    => ameApprovedStatus);

      l_progress := l_api_name || ' : 003   for AME transactionId - '||itemkey|| ' setting AME_PROCESS_STATUS to APPROVED';
      IF g_fnd_debug = yesChar THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
        END IF;
      END IF;

      RETURN;

    END IF;

    RETURN;

  END IF;
  --
  -- CANCEL mode
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  IF (funcmode = 'CANCEL') THEN

    -- no result needed
    resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
    RETURN;

  END IF;
  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  resultout := wf_engine.eng_null;
  RETURN;

EXCEPTION
WHEN OTHERS THEN
  -- The line below records this function call in the error system
  -- in the case of an exception.
  wf_core.context('POS_SUPP_APPR', 'GET_NEXT_APPROVER', itemtype, itemkey, TO_CHAR(actid), funcmode);
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  resultout:= wf_engine.eng_completed||':'||'INVALID_APPROVER';
  RAISE;
END GET_NEXT_APPROVER;
-------------------------------------------------------------------------------
-- PROCEDURE GET_APPROVER_IN_WF
--
-- Procedure to get information about next approver stored in workflow
--
-- IN
--   suppid -  (SuppRegId)
-- OUT
--   user_id  - user_id in fnd_user
--   user_name -  user_name in fnd_user
--   user_firstname - the first name of this user
--   user_lastname - the last name of this user
--   status - S/E
-------------------------------------------------------------------------------
PROCEDURE GET_APPROVER_IN_WF
  (
    suppid          IN VARCHAR2,
    user_id         OUT NOCOPY  VARCHAR2,
    user_name       OUT NOCOPY  VARCHAR2,
    user_firstname  OUT NOCOPY  VARCHAR2,
    user_lastname   OUT NOCOPY  VARCHAR2,
    status          IN OUT NOCOPY VARCHAR2
  )

IS

  isAmeEnabled          VARCHAR2(1);
  l_api_name            VARCHAR2(50)  := 'GET_APPROVER_IN_WF';
  l_progress            VARCHAR2(4000) := '000';
  isCurrentApprover     VARCHAR2(1);
  approverName          VARCHAR2(1000);
  wfItemKey             VARCHAR2(1000);

BEGIN

  status := 'S';

  l_progress := l_api_name || ': 001';
  --procedure returns Y for all users when AME is not enabled

  CHECK_IF_AME_ENABLED  ( result => isAmeEnabled  );

  IF (isAmeEnabled = noChar) THEN

    status := 'E';
    RETURN;

  END IF;

  wfItemKey := GET_WF_TOP_PROCESS_ITEM_KEY(suppid);

  get_current_approver_details(wfitemkey, FND_GLOBAL.user_name, isCurrentApprover, approverName);

  IF ( isCurrentApprover = yesChar ) THEN
    BEGIN
        SELECT fu.user_id, fu.user_name, hp.person_first_name, hp.person_last_name
          INTO user_id, user_name, user_firstname, user_lastname
        FROM fnd_user fu, hz_parties hp
        WHERE fu.user_name = FND_GLOBAL.user_name
          AND fu.person_party_id = hp.party_id(+)
          AND rownum = 1;
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	RAISE;
    END;
  ELSE
    status := 'E';
  END IF;

  l_progress := l_api_name || ': 003 values retreived for user_id, description, user_name are - '||user_id||', '||user_name||', '||user_firstname||','||user_lastname;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  status := 'E';
END GET_APPROVER_IN_WF;
-------------------------------------------------------------------------------
-- PROCEDURE CHECK_IF_APPROVER
--
-- Procedure to check if current user is the next APPROVER in AME
--
-- IN
--   suppid - itemkey for workflow (SuppRegId)
--   approver - username of user
-- OUT
--   result - Y/N
-------------------------------------------------------------------------------
PROCEDURE CHECK_IF_APPROVER
  (
    suppid   IN VARCHAR2,
    approver IN VARCHAR2,
    result   IN OUT nocopy VARCHAR2
  )

IS

  wfItemKey             VARCHAR2(100);
  isAmeEnabled          VARCHAR2(1);
  l_api_name            VARCHAR2(50)  := 'CHECK_IF_APPROVER';
  l_progress            VARCHAR2(4000) := '000';
  approverName          VARCHAR2(240);

BEGIN

  l_progress := l_api_name || ' : 001';


  --procedure returns Y for all users when AME is not enabled
  CHECK_IF_AME_ENABLED  ( result => isAmeEnabled  );

  IF (isAmeEnabled = noChar) THEN
    result := yesChar;
    RETURN;
  END IF;
  wfItemKey := GET_WF_TOP_PROCESS_ITEM_KEY(suppid);
  l_progress  := l_api_name || ' : 002 CHECK_IF_AME_ENABLED returns '|| isAmeEnabled;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;

  END IF;

  get_current_approver_details(wfItemKey, approver, result, approverName);

  l_progress :=  l_api_name || ' : 003 get_current_approver_details returns--> result '|| result || 'approverName-->' || approverName;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  result := noChar;
END CHECK_IF_APPROVER;
-------------------------------------------------------------------------------
-- PROCEDURE GET_AME_PROCESS_STATUS
--
-- Procedure to find status of AME WF
-- Returns value for attribute AME_PROCESS_STATUS
--
-- IN
--   suppid - suppid for workflow (SuppRegId)
-- OUT
--   resultout - INPROCESS/APPROVED/REJECTED/NOAME
-------------------------------------------------------------------------------
PROCEDURE GET_AME_PROCESS_STATUS
  (
    suppid IN VARCHAR2,
    result  IN OUT nocopy VARCHAR2
  )

IS

  process_status VARCHAR2(20);
  l_api_name     VARCHAR2(50)  := 'GET_AME_PROCESS_STATUS';
  l_progress     VARCHAR2(4000) := '000';
  l_itemKey      VARCHAR2(40);

BEGIN

  l_progress := l_api_name || ' : 001';
  result := NULL;

  BEGIN
    l_itemKey := GET_WF_TOP_PROCESS_ITEM_KEY(suppid);
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_itemKey := NULL;
    l_progress := l_api_name || ' : 001 no process found for given suppid';
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;
  END;
  IF l_itemKey IS NOT NULL THEN
  process_status := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                                itemkey   => l_itemKey,
                                                aname     => 'AME_PROCESS_STATUS',
                                                ignore_notfound => TRUE);
  result := process_status;

  END IF;
  l_progress := l_api_name || ' : 002 l_itemKey - '||l_itemKey||' WF attribute AME_PROCESS_STATUS '|| result;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RAISE;
END GET_AME_PROCESS_STATUS;

--Handle Request based on final approval result

PROCEDURE PROCESS_SUPP_REG
  (
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT NOCOPY VARCHAR2
  )

IS

  process_result VARCHAR2(100);
  return_status  VARCHAR2(100);
  msg_count      NUMBER;
  msg_data       VARCHAR2(4000);
  suppid         VARCHAR2(1000);
  l_api_name     VARCHAR2(50)  := 'PROCESS_SUPP_REG';
  l_progress     VARCHAR2(4000) := '000';
  l_regStatus    pos_supplier_registrations.registration_status%TYPE;
BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout  := wf_engine.eng_null;
    RETURN;
  END IF;

  l_progress := l_api_name || ' : 001';


  suppid := wf_engine.GetItemAttrText(  itemtype  => wfitemtype,
                                        itemkey   => itemkey,
                                        aname     => 'SUPP_REG_ID');
  SELECT registration_status INTO l_regStatus
  FROM pos_supplier_registrations
  WHERE supplier_reg_id = suppid;
  GET_AME_PROCESS_STATUS  ( suppid => suppid,
                            result  => process_result);

  l_progress := l_api_name || ' : 002 process_result - '|| process_result ||' WF attribute SUPP_REG_ID '|| suppid;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;
  -- Removed the final approver/reject api's calling from here and put the same code in individual approve/reject calls.
  -- Bug: 17234415 : if final approver approves the request, then we complete the all wf process
  --                 and call api approve_supplier_reg to approve the request. Problem here is that
  --				 if there is any problem during request approve, then we dont have control over wf process,
  --  				 bcz by this time all wf processes are complete and status history shows that request is approved, but its not.
  --				 To resolve this issue, we place this approve call on each approver approve action. So that
  --				 if approving the request fails then only that perticuluar user WF notification fails and rest will be AS-IS.
  --				 Though user notification is errored out, still user can be allowed to take approve/reject action from application.
  --				 Bcz he is still an current approver.
  /*
  IF(process_result = ameApprovedStatus) THEN

    -- approve
    POS_VENDOR_REG_PKG.approve_supplier_reg(suppid, return_status, msg_count, msg_data);

  ELSIF (process_result = ameRejectedStatus) THEN

    -- reject
    POS_VENDOR_REG_PKG.reject_supplier_reg(suppid, return_status, msg_count, msg_data);

  --ELSIF (process_result = ameReturnStatus) THEN
    -- RETURN
  END IF;

  l_progress := l_api_name || ' : 003 return_status: '|| return_status ||' msg_count: '|| msg_count || 'msg_data: ' || msg_data;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;
  */

  /*  Bug : 17367157
  Along with individual approval action, here we also call approve api.
  There are few scenarios where in current approver might become no longer be approver in AME due to dynamic data change
  i.e., Supplier data is changed in such way that current approver no longer be approver.
  OR AME returns NO APPROVERS FOUND, in that case we need to call approver api to approve the request
  otherwise it will be in pending approval status and there wont be any open notifications are available for
  approvers to approve the request.
  */
  IF(process_result = ameApprovedStatus AND l_regStatus = pos_vendor_reg_pkg.ACTN_PENDING) THEN
    -- approve
    POS_VENDOR_REG_PKG.approve_supplier_reg(suppid, return_status, msg_count, msg_data);
    IF g_fnd_debug = yesChar THEN
		    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
			    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, 'POS_VENDOR_REG_PKG.approve_supplier_reg is completed and status is ' || return_status);
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, 'and msg_count --> ' || msg_count || ', msg_data--> ' || msg_data || ', Sqlerrm--> ' || SQLERRM);
		    END IF;
	  END IF;
    IF(return_status <> 'S') THEN
      g_isAnyError := yesChar;
      IF(return_status = 'E') THEN
        fnd_message.set_name('POS', 'POS_REG_APPROVE_ERROR');
        fnd_message.set_token('ERR_MSG', msg_data);
      ELSIF(return_status = 'U') THEN
        fnd_message.set_name('POS', 'POS_UNEXP_ERROR');
      END IF;
      app_exception.raise_exception;
    ELSE
      g_isAnyError := noChar;
    END IF;
  END IF;
  resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED';

EXCEPTION
  WHEN OTHERS THEN
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '||
        l_progress ||' sqlerrm - '|| sqlerrm);
    END IF;
  END IF;
  RAISE;
END PROCESS_SUPP_REG;

-- This is called from WF to handle approve action

PROCEDURE PROCESS_APPROVE_WF_WRAPPER
  (
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT NOCOPY VARCHAR2
  )

IS

  approve_result VARCHAR2(100);
  process_result VARCHAR2(100);
  l_notes        pos_supplier_registrations.SM_BUYER_INTERNAL_NOTES%TYPE;
  l_suppid       pos_supplier_registrations.supplier_reg_id%TYPE;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout  := wf_engine.eng_null;
    RETURN;
  END IF;

  l_notes := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                         itemkey   => itemkey ,
                                         aname     => 'NOTE'  );
  l_suppid := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                          itemkey   => itemkey ,
                                          aname     => 'SUPP_REG_ID'  );

  UPDATE pos_supplier_registrations
    SET SM_BUYER_INTERNAL_NOTES = l_notes
  WHERE supplier_reg_id = l_suppid;

  PROCESS_APPROVE(itemkey ,approve_result, process_result);
  resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED';

END PROCESS_APPROVE_WF_WRAPPER;

-- This is called from WF to handle reject action

PROCEDURE PROCESS_REJECT_WF_WRAPPER
  (
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT NOCOPY VARCHAR2
  )
IS

  approve_result VARCHAR2(100);
  process_result VARCHAR2(100);
  l_notes        pos_supplier_registrations.SM_BUYER_INTERNAL_NOTES%TYPE;
  l_suppid       pos_supplier_registrations.supplier_reg_id%TYPE;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout  := wf_engine.eng_null;
    RETURN;
  END IF;

  l_notes := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                         itemkey   => itemkey ,
                                         aname     => 'NOTE'  );

  l_suppid := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                          itemkey   => itemkey ,
                                          aname     => 'SUPP_REG_ID'  );

  IF (FND_PROFILE.VALUE('POS_SM_ENABLE_SPM_EXTENSION') = 'Y') THEN
  UPDATE pos_supplier_registrations
    SET SM_NOTE_TO_SUPPLIER = l_notes
  WHERE supplier_reg_id = l_suppid;
  ELSE
    UPDATE pos_supplier_registrations
    SET note_to_supplier = l_notes
    WHERE supplier_reg_id = l_suppid;
  END IF;

  PROCESS_REJECT(itemkey, approve_result, process_result);
  resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED';

END PROCESS_REJECT_WF_WRAPPER;


-- This is called from WF to handle return to supplier action

PROCEDURE PROCESS_RETURN_WF_WRAPPER
  (
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT NOCOPY VARCHAR2
  )

IS

  result        VARCHAR2(100);
  processresult VARCHAR2(100);
  l_notes        pos_supplier_registrations.SM_BUYER_INTERNAL_NOTES%TYPE;
  l_suppid       pos_supplier_registrations.supplier_reg_id%TYPE;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout  := wf_engine.eng_null;
    RETURN;
  END IF;


  l_notes := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                         itemkey   => itemkey ,
                                         aname     => 'NOTE'  );

  l_suppid := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                          itemkey   => itemkey ,
                                          aname     => 'SUPP_REG_ID'  );

  IF (FND_PROFILE.VALUE('POS_SM_ENABLE_SPM_EXTENSION') = 'Y') THEN
  UPDATE pos_supplier_registrations
    SET SM_NOTE_TO_SUPPLIER = l_notes
  WHERE supplier_reg_id = l_suppid;
  ELSE
    UPDATE pos_supplier_registrations
    SET note_to_supplier = l_notes
    WHERE supplier_reg_id = l_suppid;
  END IF;

  g_userAction := ameReturnToSupplierStatus;
  PROCESS_RETURN(itemkey, result, processresult);
  resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED';

END PROCESS_RETURN_WF_WRAPPER;


-- This is called from WF to handle forward action

PROCEDURE PROCESS_FORWARD_WF_WRAPPER
  (
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT NOCOPY VARCHAR2
  )
IS

  approve_result VARCHAR2(100);
  process_result VARCHAR2(100);

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout  := wf_engine.eng_null;
    RETURN;
  END IF;

  PROCESS_FORWARD(itemkey, approve_result, process_result);
  resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED';

END PROCESS_FORWARD_WF_WRAPPER;

-- This is called from WF to handle Approve&Forward action

PROCEDURE PROCESS_APPR_FWD_WF_WRAPPER
  (
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout IN OUT NOCOPY VARCHAR2
  )
IS

  approve_result VARCHAR2(100);
  process_result VARCHAR2(100);

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout  := wf_engine.eng_null;
    RETURN;
  END IF;

  PROCESS_APPROVE_FORWARD(itemkey, approve_result, process_result);
  resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED';

END PROCESS_APPR_FWD_WF_WRAPPER;

-------------------------------------------------------------------------------
-- PROCEDURE PROCESS_APPROVE
--
-- Procedure to to Approve a Supplier Registration Request for an approver
-- Called when an Approver approves a request
--
-- IN
--   itemkey
-- OUT
--   result - SUCCESS/FAILURE
--   processresult - APPROVED/REJECTED/INPROCESS/ERROR
-------------------------------------------------------------------------------
PROCEDURE PROCESS_APPROVE
  (
    itemkey       IN VARCHAR2,
    result        IN OUT nocopy VARCHAR2,
    processresult IN OUT nocopy VARCHAR2
  )

IS

  p_itemkey    VARCHAR2(100);
  l_api_name   VARCHAR2(50) := 'PROCESS_APPROVE';
  abort_result VARCHAR2(20);
  lerrname     VARCHAR2(30);
  lerrmsg      VARCHAR2(2000);
  lerrstack    VARCHAR2(32000);
  l_progress   VARCHAR2(4000) := 000;
  wf_group_id  VARCHAR2(100);
  approver     VARCHAR2(100);
  l_suppid     VARCHAR2(100);
  l_approverId VARCHAR2(100);
  l_notes      VARCHAR2(4000);
  l_approver_list ame_util.approversTable2;
  l_process_out VARCHAR2(10);
  x_return_status    VARCHAR2(4000);
  x_msg_count        NUMBER;
  x_msg_data         VARCHAR2(4000);

BEGIN

  result := 'FAILURE';
  l_progress := l_api_name || ' : 001';

  approver := wf_engine.GetItemAttrText(  itemtype  => wfItemType, itemkey => itemkey, aname => 'APPROVER_USER_NAME');

  SELECT parent_item_key
    INTO p_itemkey
  FROM wf_items
  WHERE item_type = wfItemType
    AND item_key    = itemkey;
  l_suppid := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                          itemkey   => p_itemkey ,
                                          aname     => 'SUPP_REG_ID'  );

  wf_engine.SetItemAttrText ( itemtype  => wfItemType, itemkey   => itemkey,   aname     => 'APPROVER_RESPONSE', avalue    => ame_util.approvedStatus);
  wf_engine.SetItemAttrText ( itemtype  => wfItemType, itemkey   => p_itemkey, aname     => 'APPROVER_RESPONSE', avalue    => ame_util.approvedStatus);

  l_progress := l_api_name || ' : Invoked Process_Response_Internal with attributes - '|| itemkey ||' and APPROVE' || 'for approver : ' || approver;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  Process_Response_Internal( itemkey,ame_util.approvedStatus);

  IF g_fnd_debug = yesChar THEN
	  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
		FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, 'calling ame api ame_api2.getAllApprovers7 to get process status');
	  END IF;
  END IF;

  -- Is this final approve? If yes, then below api should give  l_process_out as 'Y'.
  ame_api2.getAllApprovers7 (   applicationIdIn => ameApplicationId,
                                transactionIdIn => l_suppid,
                                transactionTypeIn => 'POS_SUPP_APPR',
                                approvalProcessCompleteYNOut => l_process_out,
                                approversOut =>  l_approver_list );

  IF g_fnd_debug = yesChar THEN
	  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
		FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, 'ame api ame_api2.getAllApprovers7 is completed and status is ' || l_process_out);
	  END IF;
  END IF;

  IF (l_process_out = 'Y') THEN
    -- Approve the supplier registration request.
    POS_VENDOR_REG_PKG.approve_supplier_reg(l_suppid,x_return_status,x_msg_count,x_msg_data);

	IF g_fnd_debug = yesChar THEN
		  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
			    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, 'POS_VENDOR_REG_PKG.approve_supplier_reg is completed and status is ' || x_return_status);
         FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, 'and x_msg_count --> ' || x_msg_count || ', x_msg_data--> ' || x_msg_data || ', Sqlerrm--> ' || SQLERRM);
		  END IF;
	END IF;

    IF(x_return_status <> 'S') THEN

      g_isAnyError := yesChar;
      IF(x_return_status = 'E') THEN
        fnd_message.set_name('POS', 'POS_REG_APPROVE_ERROR');
        fnd_message.set_token('ERR_MSG', x_msg_data);
      ELSIF(x_return_status = 'U') THEN
      fnd_message.set_name('POS', 'POS_UNEXP_ERROR');
      END IF;
      app_exception.raise_exception;

    ELSE
      g_isAnyError := noChar;
    END IF;
  END IF;
  wf_group_id := wf_engine.GetItemAttrText( itemtype  => wfItemType,
                                            itemkey   => itemkey ,
                                            aname     => 'APPROVAL_GROUP_ID'  );

  l_progress := l_api_name || ' : update_reg_action_hist - l_suppid : ' || l_suppid || '- l_approverId : ' || l_approverId || ' - l_notes : ' || l_notes ;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;


  l_approverId := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                              itemkey   => itemkey ,
                                              aname     => 'APPROVER_EMPID'  );

  l_notes := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                         itemkey   => itemkey ,
                                         aname     => 'NOTE'  );

  pos_vendor_reg_pkg.update_reg_action_hist( p_supp_reg_id =>  l_suppid,
                                             p_action   =>  pos_vendor_reg_pkg.ACTN_APPROVE,
                                             p_note     =>  l_notes,
                                             p_from_user_id => l_approverId,
                                             p_to_user_id => NULL
                                           );

  IF (l_process_out <> 'Y') THEN
  -- Abort only specific processes  which are beatbyfirstresponder because of current approve
  abort_workflow_process(p_itemkey, approver, wf_group_id, ame_util.approvedStatus, result);
  END IF;

  l_progress := l_api_name || ': Try Complete BLOCK activity for top process -' || p_itemkey;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  BEGIN
    wf_engine.CompleteActivity( itemtype  => wfItemType,
                                itemkey   => p_itemkey,
                                activity  => 'BLOCK',
                                result    => NULL);
  EXCEPTION
  WHEN OTHERS THEN
    wf_core.get_error(lerrname,lerrmsg,lerrstack);
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
      END IF;
    END IF;
    IF lerrname = 'WFENG_NOT_NOTIFIED' THEN
      NULL;
    END IF;
  END;

  GET_AME_PROCESS_STATUS( suppid => l_suppid, result => processresult);

  l_progress := l_api_name || ' : AME process status for process -' || p_itemkey || 'is -' || processresult;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  -- Abort all process in case of request is approved fully
  IF ( processresult = ameApprovedStatus ) THEN -- or it can be IF (l_process_out = 'Y') THEN

    abort_workflow_process(p_itemkey, approver, wf_group_id, NULL, result);

  END IF;

  l_progress := l_api_name || ' is completed successfully';
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  result := 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
  result := 'FAILURE';
  g_isAnyError := yesChar;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RAISE;
END PROCESS_APPROVE;

-------------------------------------------------------------------------------
-- PROCEDURE PROCESS_REJECT
--
-- Procedure to to Reject a Supplier Registration Request
-- Called when an Approver rejects a request
--
-- IN
--   itemkey
--
-- OUT
--   result - SUCCESS/FAILURE
--   processresult - APPROVED/REJECTED/INPROCESS/ERROR
-------------------------------------------------------------------------------
PROCEDURE PROCESS_REJECT
  (
    itemkey       IN VARCHAR2,
    result        IN OUT nocopy VARCHAR2,
    processresult IN OUT nocopy VARCHAR2
  )

IS

  p_itemkey    VARCHAR2(100);
  l_api_name   VARCHAR2(50) := 'PROCESS_REJECT';
  abort_result VARCHAR2(20);
  lerrname     VARCHAR2(30);
  lerrmsg      VARCHAR2(2000);
  lerrstack    VARCHAR2(32000);
  l_progress   VARCHAR2(4000);
  wf_group_id  VARCHAR2(100);
  approver     VARCHAR2(100);
  l_suppid     VARCHAR2(100);
  l_approverId VARCHAR2(100);
  l_notes      VARCHAR2(4000);
  x_return_status    VARCHAR2(4000);
  x_msg_count        NUMBER;
  x_msg_data         VARCHAR2(4000);

BEGIN
  result := 'FAILURE';

  approver := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                          itemkey   => itemkey,
                                          aname     => 'APPROVER_USER_NAME');

  SELECT parent_item_key
    INTO p_itemkey
  FROM wf_items
  WHERE item_type = wfItemType
    AND item_key  = itemkey;

  l_suppid := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                          itemkey   => p_itemkey ,
                                          aname     => 'SUPP_REG_ID'  );
  l_progress := l_api_name || ' : Invoked Process_Response_Internal with attributes - '|| itemkey ||' and REJECT for approver ' || approver;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  Process_Response_Internal(itemkey, ame_util.rejectStatus);

  IF g_fnd_debug = yesChar THEN
	  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
		FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, 'calling api POS_VENDOR_REG_PKG.reject_supplier_reg');
	  END IF;
  END IF;

  -- Reject the supplier registration request.
  POS_VENDOR_REG_PKG.reject_supplier_reg(l_suppid, x_return_status, x_msg_count, x_msg_data);

  IF g_fnd_debug = yesChar THEN
	  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, 'api POS_VENDOR_REG_PKG.reject_supplier_reg completed : status  -->' || x_return_status );
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, 'and x_msg_count --> ' || x_msg_count || ', x_msg_data--> ' || x_msg_data || ', Sqlerrm--> ' || SQLERRM);
	  END IF;
  END IF;

  IF(x_return_status <> 'S') THEN

    g_isAnyError := yesChar;
    IF(x_return_status = 'E') THEN
      fnd_message.set_name('POS', 'POS_REG_REJECT_ERROR');
      fnd_message.set_token('ERR_MSG', x_msg_data);
    ELSIF(x_return_status = 'U') THEN
        fnd_message.set_name('POS', 'POS_UNEXP_ERROR');
    END IF;
        app_exception.raise_exception;

  ELSE
    g_isAnyError := noChar;
  END IF;

  l_progress := l_api_name || ': Set APPROVER_RESPONSE and AME_PROCESS_STATUS attributes ';
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  -- Stamp approver response as reject
  wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => itemkey, aname => 'APPROVER_RESPONSE', avalue => ame_util.rejectStatus);
  -- Stamp main process approver response as reject so that main/top process will be completed with rejected
  wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => p_itemkey, aname => 'APPROVER_RESPONSE', avalue => ame_util.rejectStatus);
  -- Set whole request as REJECTED
  wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => p_itemkey, aname => 'AME_PROCESS_STATUS', avalue => ameRejectedStatus);

  /* Bug 17331252
  l_progress := l_api_name || ': update_reg_action_hist - l_suppid : ' || l_suppid || '- l_approverId : ' || l_approverId || ' - l_notes : ' || l_notes ;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;


  l_approverId := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                              itemkey   => itemkey ,
                                              aname     => 'APPROVER_EMPID'  );

  l_notes := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                         itemkey   => itemkey ,
                                         aname     => 'NOTE'  );

  pos_vendor_reg_pkg.update_reg_action_hist( p_supp_reg_id =>  l_suppid,
                                        p_action   =>  pos_vendor_reg_pkg.ACTN_REJECT,
                                        p_note     =>  l_notes,
                                        p_from_user_id => l_approverId,
                                        p_to_user_id => NULL
                                      );
  */
  wf_group_id := wf_engine.GetItemAttrText( itemtype => wfItemType, itemkey => itemkey , aname => 'APPROVAL_GROUP_ID');

  -- Abort/Complete all workflow parallel sub process
  abort_workflow_process(p_itemkey, approver, wf_group_id, ame_util.rejectStatus, result);
  -- send fyi notifications to fyi approvers
  send_fyi_notification(l_suppid);

  l_progress := l_api_name || ' : Try Complete BLOCK activity for top process -' || p_itemkey;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  BEGIN
    wf_engine.CompleteActivity( itemtype => wfItemType, itemkey => p_itemkey, activity => 'BLOCK', result => NULL);
  EXCEPTION
  WHEN OTHERS THEN
    wf_core.get_error(lerrname,lerrmsg,lerrstack);
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
      END IF;
    END IF;
    IF lerrname = 'WFENG_NOT_NOTIFIED' THEN
      NULL;
    END IF;
  END;

  l_progress := l_api_name || ': completed PROCESS_REJECT' ;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  result := 'SUCCESS';
  processresult := ameRejectedStatus;

EXCEPTION
WHEN OTHERS THEN
  result := 'FAILURE';
  g_isAnyError := yesChar;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RAISE;
END PROCESS_REJECT;

-- To handle return to supplier action

PROCEDURE PROCESS_RETURN
  (
    itemkey       IN VARCHAR2,
    result        IN OUT NOCOPY VARCHAR2,
    processresult IN OUT NOCOPY VARCHAR2
  )

IS

  p_itemkey wf_items.parent_item_key%TYPE;
  abort_result  VARCHAR2(20);
  lerrname      VARCHAR2(30);
  lerrmsg       VARCHAR2(2000);
  lerrstack     VARCHAR2(32000);
  p_msg_subject VARCHAR2(4000);
  p_msg_body    VARCHAR2(32000);
  wf_group_id       VARCHAR2(100);
  suppid            VARCHAR2(100);
  approver          VARCHAR2(100);
  l_api_name     VARCHAR2(50)  := 'PROCESS_RETURN';
  l_progress     VARCHAR2(4000) := '000';
  l_approverId   VARCHAR2(100);

BEGIN

  result := 'FAILURE';
  SELECT parent_item_key
    INTO p_itemkey
  FROM wf_items
  WHERE item_type = wfItemType
    AND item_key  = itemkey;

  suppid    := wf_engine.GetItemAttrText(itemtype => wfItemType, itemkey => p_itemkey, aname => 'SUPP_REG_ID');
  approver  := wf_engine.GetItemAttrText(itemtype => wfItemType, itemkey => itemkey, aname => 'APPROVER_USER_NAME');

  l_progress := l_api_name || ': 002 suppid - '||suppid||' approver - '|| approver || 'g_userAction - ' || g_userAction;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  UPDATE pos_supplier_registrations
  SET REGISTRATION_STATUS = 'RIF_SUPPLIER',
    last_update_date      = Sysdate,
    last_updated_by       = fnd_global.user_id,
    last_update_login     = fnd_global.login_id
  WHERE supplier_reg_id   = suppid
  AND REGISTRATION_STATUS = 'PENDING_APPROVAL';

   l_progress := l_api_name || ': 003 updated REGISTRATION_STATUS to  RIF_SUPPLIER';
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  -- Stamp approver response 'RETURNTOSUPPLIER' to process
  wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => itemkey,   aname => 'APPROVER_RESPONSE',   avalue => ameReturnToSupplierStatus );
  -- Stamp approver response 'RETURNTOSUPPLIER' to top/main process so that main process will be completed
  wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => p_itemkey, aname => 'APPROVER_RESPONSE',   avalue => ameReturnToSupplierStatus);
  -- Set AME PROCESS STATUS
  wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => p_itemkey, aname => 'AME_PROCESS_STATUS',  avalue => ameReturnToSupplierStatus);


  -- Process_Response_Internal(itemkey, ameReturnStatus);

  -- We update action history while sending the notification for return to supplier action.
  -- Reason why we are not doing as another step is that here is that return to supplier action can be taken any number of times.
  -- So, it is not required always send through wf process. We have some scenarios where in from java layer
  -- we invoke the POS_SPM_WF_PKG1.PROS_SUPP_NOTIFICATION to send the notification.
  -- So, decided to update action history while sending the notificaiton.
  IF (g_userAction = ameReturnToSupplierStatus) THEN

	  l_progress := 'PROCESS_RETURN: 004 Notify supplier about registration request has been returned';
	  IF g_fnd_debug = yesChar THEN
		IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		  FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
		END IF;
	  END IF;

	  -- Send Notification to Supplier contact on clicking the Return To Supplier button
      -- p_msg_subject := 'Notification to Prospective Supplier';
      p_msg_body    := wf_engine.GetItemAttrText(itemtype => wfitemtype, itemkey => itemkey, aname => 'NOTE');

      POS_SPM_WF_PKG1.PROS_SUPP_NOTIFICATION(suppid, null, p_msg_body);

  END IF;

  IF (g_userAction = amePublishRFI) THEN -- We update action history here while publishing the RFI

	  l_approverId := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
												  itemkey   => itemkey ,
												  aname     => 'APPROVER_EMPID'  );
	  l_progress := l_api_name || ': update_reg_action_hist - suppid : ' || suppid || '- l_approverId : ' || l_approverId ;
	  IF g_fnd_debug = yesChar THEN
		IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		  FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
		END IF;
	  END IF;

	  pos_vendor_reg_pkg.update_reg_action_hist( p_supp_reg_id =>  suppid,
                                        p_action   =>  pos_vendor_reg_pkg.ACTN_RETURN_TO_SUPP,
                                        p_note     =>  NULL,
                                        p_from_user_id => l_approverId,
                                        p_to_user_id => NULL
                                      );

  END IF;
  ---UPDATE AME approver status and abort the pending notifications

  wf_group_id := wf_engine.GetItemAttrText(itemtype => wfItemType, itemkey => itemkey , aname => 'APPROVAL_GROUP_ID');

  abort_workflow_process(p_itemkey, approver, wf_group_id, ameReturnStatus, result);

  l_progress := l_api_name || ' : Try Complete BLOCK activity for top process -' || p_itemkey;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  BEGIN
    wf_engine.CompleteActivity( itemtype => wfItemType, itemkey => p_itemkey, activity => 'BLOCK', result => NULL);
  EXCEPTION
  WHEN OTHERS THEN
    wf_core.get_error(lerrname,lerrmsg,lerrstack);
    IF lerrname = 'WFENG_NOT_NOTIFIED' THEN
      NULL;
    END IF;
  END;

  l_progress := l_api_name || ': 005 completed PROCESS_RETURN';
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  result := 'SUCCESS';
  processresult := ameReturnStatus;

EXCEPTION
WHEN OTHERS THEN
  result := 'FAILURE';
  g_isAnyError := yesChar;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
RAISE;

END PROCESS_RETURN;


PROCEDURE PROCESS_APPROVE_FORWARD(
    itemkey       IN VARCHAR2,
    result        IN OUT nocopy VARCHAR2,
    processresult IN OUT nocopy VARCHAR2)

IS

  p_itemkey                      VARCHAR2(100);
  abort_result                   VARCHAR2(20);
  l_forward_to_username_response VARCHAR2(100) := NULL;
  l_progress                     VARCHAR2(4000);
  l_api_name                     VARCHAR2(50) := 'PROCESS_APPROVE_FORWARD';
  lerrname                       VARCHAR2(30);
  lerrmsg                        VARCHAR2(2000);
  lerrstack                      VARCHAR2(32000);
  l_suppid                       VARCHAR2(100);
  l_approverId                   VARCHAR2(100);
  l_notes                        VARCHAR2(4000);
  l_fwd_approver_id              VARCHAR2(100);

BEGIN

  SELECT parent_item_key
  INTO p_itemkey
  FROM wf_items
  WHERE item_type  = wfItemType
  AND item_key     = itemkey;

  l_progress    := l_api_name || ' : Invoke Process_Response_Internal with attributes itemkey - '|| itemkey ||' and approveAndForward';
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  Process_Response_Internal( itemkey, ame_util.approveAndForwardStatus );

  wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => itemkey,   aname => 'APPROVER_RESPONSE', avalue => ame_util.approveAndForwardStatus );
  wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => p_itemkey, aname => 'APPROVER_RESPONSE', avalue => ame_util.approveAndForwardStatus );

  l_progress := l_api_name || ' : update_reg_action_hist - l_suppid : ' || l_suppid || '- l_approverId : ' || l_approverId || ' - l_notes : ' || l_notes ;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  l_fwd_approver_id := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                         itemkey   => itemkey ,
                                         aname     => 'FORWARD_TO_EMPID'  );

  l_suppid := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                          itemkey   => p_itemkey ,
                                          aname     => 'SUPP_REG_ID'  );

  l_approverId := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                              itemkey   => itemkey ,
                                              aname     => 'APPROVER_EMPID'  );

  l_notes := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                         itemkey   => itemkey ,
                                         aname     => 'NOTE'  );

  pos_vendor_reg_pkg.update_reg_action_hist( p_supp_reg_id =>  l_suppid,
                                        p_action   =>  pos_vendor_reg_pkg.ACTN_APPR_FORWARD,
                                        p_note     =>  l_notes,
                                        p_from_user_id => l_approverId,
                                        p_to_user_id => l_fwd_approver_id
                                      );

  l_progress := l_api_name || ' : Try Complete BLOCK activity for top process -' || p_itemkey;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  --Complete BLOCK activity of top process so that new forwarded person gets notified
  BEGIN
    wf_engine.CompleteActivity( itemtype => wfItemType, itemkey => p_itemkey, activity => 'BLOCK', result => NULL);
  EXCEPTION
  WHEN OTHERS THEN
    wf_core.get_error(lerrname,lerrmsg,lerrstack);
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
      END IF;
    END IF;
    IF lerrname = 'WFENG_NOT_NOTIFIED' THEN
      NULL;
    END IF;
  END;

  l_progress := l_api_name || ' : completed ';
  IF g_fnd_debug  = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  result := 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
  result := 'FAILURE';
  g_isAnyError := yesChar;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RAISE;
END PROCESS_APPROVE_FORWARD;


PROCEDURE PROCESS_FORWARD(
    itemkey       IN VARCHAR2,
    result        IN OUT nocopy VARCHAR2,
    processresult IN OUT nocopy VARCHAR2)

IS

  p_itemkey                      VARCHAR2(100);
  abort_result                   VARCHAR2(20);
  l_forward_to_username_response VARCHAR2(100) := NULL;
  l_progress                     VARCHAR2(4000);
  l_api_name                     VARCHAR2(50) := 'PROCESS_FORWARD';
  lerrname                       VARCHAR2(30);
  lerrmsg                        VARCHAR2(2000);
  lerrstack                      VARCHAR2(32000);
  l_suppid                       VARCHAR2(100);
  l_approverId                   VARCHAR2(100);
  l_notes                        VARCHAR2(4000);
  l_fwd_approver_id              VARCHAR2(100);

BEGIN

  SELECT parent_item_key
  INTO p_itemkey
  FROM wf_items
  WHERE item_type  = wfItemType
  AND item_key     = itemkey;

  l_progress    := l_api_name || ' : Invoke Process_Response_Internal with attributes itemkey - '|| itemkey ||' and FORWARD';
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  Process_Response_Internal( itemkey, ame_util.forwardStatus );

  wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => itemkey,   aname => 'APPROVER_RESPONSE', avalue => ame_util.forwardStatus );
  wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => p_itemkey, aname => 'APPROVER_RESPONSE', avalue => ame_util.forwardStatus );

  l_progress := l_api_name || ' : update_reg_action_hist - l_suppid : ' || l_suppid || '- l_approverId : ' || l_approverId || ' - l_notes : ' || l_notes ;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  l_fwd_approver_id := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                         itemkey   => itemkey ,
                                         aname     => 'FORWARD_TO_EMPID'  );

  l_suppid := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                          itemkey   => p_itemkey ,
                                          aname     => 'SUPP_REG_ID'  );

  l_approverId := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                              itemkey   => itemkey ,
                                              aname     => 'APPROVER_EMPID'  );

  l_notes := wf_engine.GetItemAttrText(  itemtype  => wfItemType,
                                         itemkey   => itemkey ,
                                         aname     => 'NOTE'  );

  pos_vendor_reg_pkg.update_reg_action_hist( p_supp_reg_id =>  l_suppid,
                                        p_action   =>  pos_vendor_reg_pkg.ACTN_FORWARD,
                                        p_note     =>  l_notes,
                                        p_from_user_id => l_approverId,
                                        p_to_user_id => l_fwd_approver_id
                                      );

  l_progress := l_api_name || ' : Try Complete BLOCK activity for top process -' || p_itemkey;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  --Complete BLOCK activity of top process so that new forwarded person gets notified
  BEGIN
    wf_engine.CompleteActivity( itemtype => wfItemType, itemkey => p_itemkey, activity => 'BLOCK', result => NULL);
  EXCEPTION
  WHEN OTHERS THEN
    wf_core.get_error(lerrname,lerrmsg,lerrstack);
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
      END IF;
    END IF;
    IF lerrname = 'WFENG_NOT_NOTIFIED' THEN
      NULL;
    END IF;
  END;

  l_progress := l_api_name || ' : completed ';
  IF g_fnd_debug  = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  result := 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
  result := 'FAILURE';
  g_isAnyError := yesChar;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RAISE;
END PROCESS_FORWARD;

-------------------------------------------------------------------------------
-- PROCEDURE CHECK_IF_AME_ENABLED
--
-- Procedure to to find out if AME is enabled for Supplier Approval Management
--
-- IN
--
-- OUT
--   result - Y/N
-------------------------------------------------------------------------------
PROCEDURE CHECK_IF_AME_ENABLED
  (
    result IN OUT nocopy VARCHAR2
  )

IS

  l_api_name VARCHAR2(50) := 'CHECK_IF_AME_ENABLED';
  l_progress VARCHAR2(4000);

BEGIN

  result := NVL(FND_PROFILE.VALUE('POS_SAM_AME_ENABLED'), noChar);

  l_progress  := l_api_name || ' : 001 -- result :' || result ;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  result := noChar;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RAISE;
END CHECK_IF_AME_ENABLED;

-------------------------------------------------------------------------------
-- PROCEDURE Process_Response_Internal
--
-- Update AME with current approver response
--
-- IN
--   itemkey    -  itemkey
--   p_response  - APPROVE/REJECT/FORWARD/APPROVE&FORWARD
-- OUT
--
-------------------------------------------------------------------------------
PROCEDURE Process_Response_Internal
  (
    itemkey    IN VARCHAR2,
    p_response IN VARCHAR2
  )
IS

  l_progress VARCHAR2(4000) := '000';
  l_current_approver ame_util.approverRecord2;
  l_forwardee ame_util.approverRecord2;
  l_approver_type VARCHAR2(10);
  l_api_name      VARCHAR2(50) := 'Process_Response_Internal';
  p_itemkey wf_items.parent_item_key%TYPE;
  suppid             VARCHAR2(1000);
  l_transaction_type VARCHAR2(100);
  wf_role_not_found  EXCEPTION;

BEGIN

  SELECT parent_item_key
  INTO p_itemkey
  FROM wf_items
  WHERE item_type = wfItemType
  AND item_key    = itemkey;

  suppid := wf_engine.GetItemAttrText( itemtype => wfitemtype, itemkey => p_itemkey, aname => 'SUPP_REG_ID');

  l_progress := l_api_name || ' : 001 : itemkey' || itemkey ;

  l_transaction_type := wf_engine.GetItemAttrText( itemtype => wfItemType, itemkey => itemkey, aname => 'AME_TRANSACTION_TYPE');
  l_approver_type    := wf_engine.GetItemAttrText( itemtype => wfItemType, itemkey => itemkey, aname => 'AME_APPROVER_TYPE');

  l_progress := l_api_name || ' : 002 -- l_approver_type :' || l_approver_type || 'l_transaction_type: ' || l_transaction_type || 'suppid: ' || suppid || 'p_response: ' || p_response;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  IF (l_approver_type = 'POS') THEN

    l_current_approver.orig_system := 'POS';
    l_current_approver.name        := 'POS:'|| wf_engine.GetItemAttrText( itemtype => wfItemType, itemkey => itemkey, aname => 'AME_APPROVER_ID');

  ELSIF (l_approver_type = 'FND') THEN

    l_current_approver.orig_system := 'FND';
    l_current_approver.name        := wf_engine.GetItemAttrText( itemtype => wfItemType, itemkey => itemkey, aname => 'APPROVER_USER_NAME');

  ELSE

    l_current_approver.orig_system := 'PER';
    l_current_approver.name        := wf_engine.GetItemAttrText( itemtype => wfItemType, itemkey => itemkey, aname => 'APPROVER_USER_NAME');

  END IF;

  l_current_approver.orig_system_id := wf_engine.GetItemAttrText( itemtype => wfItemType, itemkey => itemkey, aname => 'AME_APPROVER_ID');
  l_forwardee.orig_system           := ame_util.perOrigSystem;
  l_forwardee.name                  := wf_engine.GetItemAttrText( itemtype => wfItemType, itemkey => itemkey, aname => 'FORWARD_TO_USERNAME_RESPONSE');
  l_forwardee.name                  := Upper(l_forwardee.name);

  BEGIN
    SELECT employee_id
    INTO l_forwardee.orig_system_id
    FROM fnd_user
    WHERE user_name = l_forwardee.name;
  EXCEPTION
  WHEN OTHERS THEN
    l_forwardee.orig_system_id := NULL;
  END;

  l_progress := l_api_name || ' : 003 -- l_current_approver.orig_system :' || l_current_approver.orig_system
                || 'l_current_approver.name: ' || l_current_approver.name || 'l_current_approver.orig_system_id: ' || l_current_approver.orig_system_id
                || 'l_forwardee.name: ' || l_forwardee.name || 'l_forwardee.orig_system: ' || l_forwardee.orig_system || 'l_forwardee.orig_system_id ' || l_forwardee.orig_system_id;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  IF( p_response  = ame_util.approvedStatus) THEN
    l_current_approver.approval_status := ame_util.approvedStatus;
  ELSIF( p_response = ame_util.rejectStatus) THEN
    l_current_approver.approval_status := ame_util.rejectStatus;
  ELSIF( p_response = ame_util.forwardStatus) THEN
    l_current_approver.approval_status := ame_util.forwardStatus;
  ELSIF( p_response = ame_util.approveAndForwardStatus) THEN
    l_current_approver.approval_status := ame_util.approveAndForwardStatus;
  ELSIF( p_response = ameReturnStatus) THEN
    l_current_approver.approval_status := ameReturnStatus;
  ELSIF( p_response = 'TIMEOUT') THEN
    l_current_approver.approval_status := ame_util.noResponseStatus;
  ELSIF( p_response = ame_util.noResponseStatus) THEN
    l_current_approver.approval_status := ame_util.noResponseStatus;
  END IF;

  l_progress  := l_api_name || ' : 004 -- p_response :' || p_response ;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  IF p_response IN ( ame_util.forwardStatus,  ame_util.approveAndForwardStatus ) THEN
    IF l_forwardee.name IS NULL THEN
      SELECT name
      INTO l_forwardee.name
      FROM
        (SELECT name
        FROM wf_roles
        WHERE orig_system  = l_forwardee.orig_system
        AND orig_system_id = l_forwardee.orig_system_id
        ORDER BY start_date
        )
      WHERE ROWNUM = 1;
    END IF;
    IF l_forwardee.name IS NULL THEN
      RETURN;
    END IF;
  END IF;

  IF l_current_approver.name IS NULL THEN
    SELECT name
    INTO l_current_approver.name
    FROM
      (SELECT name
      FROM wf_roles
      WHERE orig_system  = l_current_approver.orig_system
      AND orig_system_id = l_current_approver.orig_system_id
      ORDER BY start_date
      )
    WHERE ROWNUM = 1;
  END IF;

  IF l_current_approver.name IS NULL THEN
    RAISE wf_role_not_found;
  END IF;

  l_progress  := l_api_name || ': 005 -- Update AME for transactiontype -'|| ameTransactionType || ' and transactionId - '|| suppid || 'with approval status ' || p_response;
  IF g_fnd_debug  = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  --Update the Approval status with the response from the approver.
  IF p_response IN ( ame_util.forwardStatus, ame_util.approveAndForwardStatus) THEN

    ame_api2.updateApprovalStatus( applicationIdIn => ameApplicationId, transactionIdIn => suppid, transactionTypeIn => ameTransactionType, approverIn => l_current_approver, forwardeeIn => l_forwardee );

  ELSE

    ame_api2.updateApprovalStatus( applicationIdIn => ameApplicationId, transactionIdIn => suppid, transactionTypeIn => ameTransactionType, approverIn => l_current_approver );

  END IF;

  l_progress  := l_api_name || ' : Completed';
  IF g_fnd_debug  = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RAISE;
END Process_Response_Internal;

-------------------------------------------------------------------------------
-- PROCEDURE STARTWF_POSSPAPP
--
-- Procedure to start workflow for AME Approval
-- Called when Prospective supplier registration is submitted
--
-- IN
--   suppid  -  id for Prospective Supplier (SupplierRegId)
--   requestor    -  user name of requestor
-- OUT
--   result
--       - SUCCESS
--         When Workflow was completed successfully
--       - FAILURE
--         When Workflow was started successfully
--   processresult
--       - APPROVED
--       - ERROR
--       - REJECTED
--       - INPROCESS
-------------------------------------------------------------------------------
PROCEDURE STARTWF_POSSPAPP
  (
    suppid        IN VARCHAR2,
    suppname      IN VARCHAR2,
    requestor     IN VARCHAR2,
    result        IN OUT nocopy VARCHAR2,
    processresult IN OUT nocopy VARCHAR2
  )
IS

  l_progress VARCHAR2(4000) := 000;
  l_api_name VARCHAR2(50)   := 'STARTWF_POSSPAPP';
  l_item_key VARCHAR2(1000);
  l_regKey pos_supplier_registrations.reg_key%TYPE;
  l_responsibility_id NUMBER;
  l_application_id    NUMBER;
  l_orgid             NUMBER;
  l_user_id           NUMBER;
BEGIN

  l_progress := l_api_name || ' : -- Create WF itemkey for supplier reg id : ' || suppid;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  -- create wf item key
  SELECT TO_CHAR (suppid)
    ||TO_CHAR (pos_wf_itemkey_s1.nextval)
  INTO l_item_key
  FROM sys.dual;

  SELECT reg_key,
    ou_id
  INTO l_regKey,
    l_orgid
  FROM pos_supplier_registrations
  WHERE supplier_reg_id = suppid;
  l_progress                            := l_api_name || ' : -- WF itemkey for supplier reg id : ' || suppid || ' is :' || l_item_key || ', l_orgid: ' || l_orgid;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;
  FND_PROFILE.GET('USER_ID', l_user_id);
  FND_PROFILE.GET('RESP_ID', l_responsibility_id);
  FND_PROFILE.GET('RESP_APPL_ID', l_application_id);
  l_progress                            := l_api_name || 'l_user_id: ' || l_user_id || 'l_responsibility_id : ' || l_responsibility_id || ', l_application_id : ' || l_application_id;
  IF g_fnd_debug                         = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;
  -- create workflow process
  l_progress := l_api_name || ' : -- Create WF process : ';

  wf_engine.CreateProcess(    itemtype => wfItemType, itemkey => l_item_key, process => wfProcess );
  wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => l_item_key, aname => 'REQUESTOR', avalue => requestor );
  wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => l_item_key, aname => 'SUPPLIERNAME', avalue => suppname );
  wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => l_item_key, aname => 'SUPP_REG_ID', avalue => suppid );
  wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => l_item_key, aname => 'REG_KEY', avalue => l_regKey );
  IF l_orgid IS NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_orgid); -- <R12 MOAC>
    -- Set the Org_id item attribute. We will use it to get the context for every activity
    PO_WF_UTIL_PKG.SetItemAttrNumber ( itemtype => wfItemType, itemkey => l_item_key, aname => 'ORG_ID', avalue => l_orgid );
  END IF;
  PO_WF_UTIL_PKG.SetItemAttrNumber ( itemtype => wfItemType, itemkey => l_item_key, aname => 'USER_ID', avalue => l_user_id );
  PO_WF_UTIL_PKG.SetItemAttrNumber ( itemtype => wfItemType, itemkey => l_item_key, aname => 'RESPONSIBILITY_ID', avalue => l_responsibility_id );
  PO_WF_UTIL_PKG.SetItemAttrNumber ( itemtype => wfItemType, itemkey => l_item_key, aname => 'APPLICATION_ID', avalue => l_application_id );
  fnd_global.APPS_INITIALIZE (l_user_id, l_responsibility_id, l_application_id);
  l_progress := l_api_name || ' : -- Start WF process : ';

  wf_engine.StartProcess(itemtype => wfItemType, itemkey => l_item_key );

  l_progress := l_api_name || ' : -- WF process started  : ';
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Started workflow itemtype - '|| wfItemType ||' itemkey - '||l_item_key);
    END IF;
  END IF;

  GET_AME_PROCESS_STATUS( suppid => suppid, result =>  processresult);
  result := 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
  result := 'FAILURE';
  IF (g_fnd_debug = yesChar) THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,g_module_prefix ||l_api_name, 'Error in starting workflow l_progress - ' || l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RAISE;
END STARTWF_POSSPAPP;
--------------------------------------------------------------------------------
--Start of Comments
--Name: get_ame_approval_list_history
--Function:
--  Call AME API to build the approver list history.
--Parameters:
--IN:
--    pProspSupplierId       Prospective Supplier Id
--OUT:
--    pApprovalListStr   Approval List concatenated in a string
--    pApprovalListCount Number of Approvers.
--                       It has a value of 0, if the document does not require approval.
--    pQuoteChar         Quote Character, used for escaping purpose in tokenization
--    pFieldDelimiter    Field Delimiter, used for delimiting list string into elements.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_ame_approval_list_history(
    pProspSupplierId IN VARCHAR2,
    pApprovalListStr OUT NOCOPY   VARCHAR2,
    pApprovalListCount OUT NOCOPY NUMBER,
    pQuoteChar OUT NOCOPY         VARCHAR2,
    pFieldDelimiter OUT NOCOPY    VARCHAR2 )
IS

  l_api_name VARCHAR2(50):= 'get_ame_approval_list_history';
  approverList ame_util.approversTable2;
  l_process_out VARCHAR2(10);
  l_full_name per_people_f.full_name%TYPE;
  l_person_id per_people_f.person_id%TYPE;
  l_job_or_position VARCHAR2(2000);
  l_orig_system     VARCHAR2(10);
  l_orig_system_id  NUMBER;
  l_job_id          NUMBER;
  l_position_id     NUMBER;
  l_valid_approver  VARCHAR2(1);

BEGIN
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Entering get_ame_approval_list...');
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Input param - pProspSupplierId :' || pProspSupplierId );
    END IF;
  END IF;

  pQuoteChar         := quoteChar;
  pFieldDelimiter    := fieldDelimiter;
  approvalListStr    := NULL;
  pApprovalListCount := 0;

  get_all_approvers(pProspSupplierId, approverList, l_process_out);

  -- Iterate through the list of approvers.
  FOR i IN 1 .. approverList.Count  LOOP

    l_valid_approver := yesChar;

    IF g_fnd_debug   = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' Processing the approver :' || i );
      END IF;
    END IF;

    -- do not consider the deleted approver.
    --if the approval_status value is SUPPRESSED, then the user is deleted from the list.
    IF( ( ( l_process_out = yesChar OR l_process_out = noChar ) AND
      --changing the logic from AP implementation
      --( approverList(i).approval_status is not null AND approverList(i).approval_status <> 'SUPPRESSED' )
      ( approverList(i).approval_status IS NULL OR approverList(i).approval_status <> ame_util.suppressedStatus ) )
	  OR ( ( l_process_out = 'W' OR l_process_out = 'P' )AND (approverList(i).approval_status IS NULL
			OR approverList(i).approval_status <> ame_util.suppressedStatus))) THEN
      l_orig_system                     := approverList(i).orig_system;
      l_orig_system_id                  := approverList(i).orig_system_id;
      l_job_or_position                 := NULL;

      IF ( l_orig_system                 = 'PER') THEN

        -- Employee Supervisor Record.
        IF g_fnd_debug = yesChar THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Emp - Sup Record ...');
          END IF;
        END IF;

        l_full_name        := approverList(i).display_name;
        l_person_id        := l_orig_system_id;

      ELSIF( l_orig_system = 'POS') THEN

        -- Position Hierarchy Record. The logic is mentioned in the comments section.
        IF g_fnd_debug  = yesChar THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Position Hierarchy Record ...');
          END IF;
        END IF;

        BEGIN
          SELECT person_id,
            full_name
            INTO l_person_id,
            l_full_name
          FROM
            (SELECT person.person_id,
              person.full_name
            FROM per_all_people_f person,
              per_all_assignments_f asg
            WHERE asg.position_id = l_orig_system_id
              AND TRUNC(sysdate) BETWEEN person.effective_start_date AND NVL(person.effective_end_date, TRUNC(sysdate))
              AND person.person_id                   = asg.person_id
              AND asg.primary_flag                   = yesChar
              AND asg.assignment_type               IN ('E','C')
              AND ( person.current_employee_flag     = yesChar
              OR person.current_npw_flag             = yesChar )
              AND asg.assignment_status_type_id NOT IN
                (SELECT assignment_status_type_id
                FROM per_assignment_status_types
                WHERE per_system_status = 'TERM_ASSIGN'
                )
              AND TRUNC(sysdate) BETWEEN asg.effective_start_date AND asg.effective_end_date
            ORDER BY person.last_name
            )
          WHERE rownum = 1;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          --RAISE;
          l_valid_approver := noChar;
        END;

      ELSIF (l_orig_system = 'FND' OR l_orig_system = 'FND_USR' ) THEN

        -- FND User Record.
        IF g_fnd_debug = yesChar THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'FND User Record ...');
          END IF;
        END IF;

        SELECT employee_id
          INTO l_person_id
        FROM fnd_user
        WHERE user_id = l_orig_system_id
          AND TRUNC(sysdate) BETWEEN start_date AND NVL(end_date, sysdate+1);

        l_full_name := approverList(i).display_name;

      END IF;

      IF g_fnd_debug = yesChar THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' l_full_name :' || l_full_name );
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' l_person_id :' || l_person_id );
        END IF;
      END IF;

      -- Find position | job name
      IF ( l_orig_system   = 'POS' ) THEN
        l_job_or_position := approverList(i).display_name;
      ELSE
        l_job_or_position := NULL;
      END IF;

      -- Make sure position/job name is populated.
      IF( l_job_or_position IS NULL ) THEN

        -- retrieve the position name. if the position name is null check for the job name.
        SELECT position_id,
          job_id
        INTO l_position_id,
          l_job_id
        FROM per_all_assignments_f
        WHERE person_id                    = l_person_id
          AND primary_flag                   = yesChar
          AND assignment_type               IN ('E','C')
          AND assignment_status_type_id NOT IN
            (SELECT assignment_status_type_id
            FROM per_assignment_status_types
            WHERE per_system_status = 'TERM_ASSIGN'
            )
          AND TRUNC ( effective_start_date )           <= TRUNC(SYSDATE)
          AND NVL(effective_end_date, TRUNC( SYSDATE)) >= TRUNC(SYSDATE)
          AND rownum                                    = 1;

        IF l_position_id                             IS NOT NULL THEN
          SELECT name
          INTO l_job_or_position
          FROM per_all_positions
          WHERE position_id = l_position_id;
        END IF;

        IF l_job_or_position IS NULL AND l_job_id IS NOT NULL THEN
          SELECT name INTO l_job_or_position FROM per_jobs WHERE job_id = l_job_id;
        END IF;

        IF g_fnd_debug = yesChar THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, ' l_job_or_position :' || l_job_or_position );
          END IF;
        END IF;

      END IF;

      IF( l_valid_approver = yesChar ) THEN
        marshalField(l_full_name, quoteChar, fieldDelimiter);
        marshalField( TO_CHAR(l_person_id), quoteChar, fieldDelimiter);
        marshalField(l_job_or_position, quoteChar, fieldDelimiter);
        marshalField(approverList(i).name, quoteChar, fieldDelimiter);
        --marshalField(approversTableIn(i).orig_system, quoteChar, fieldDelimiter);
        --marshalField(to_char(approversTableIn(i).orig_system_id), quoteChar, fieldDelimiter);
        marshalField(l_orig_system, quoteChar, fieldDelimiter);
        marshalField(TO_CHAR(l_orig_system_id), quoteChar, fieldDelimiter);
        marshalField(approverList(i).api_insertion, quoteChar, fieldDelimiter);
        marshalField(approverList(i).authority, quoteChar, fieldDelimiter);
        marshalField(approverList(i).approval_status, quoteChar, fieldDelimiter);
        marshalField(approverList(i).approver_category, quoteChar, fieldDelimiter);
        marshalField(approverList(i).approver_order_number, quoteChar, fieldDelimiter);
        marshalField(approverList(i).action_type_id, quoteChar, fieldDelimiter);
        --changing the logic from AP implementation
        marshalField(approverList(i).group_or_chain_id, quoteChar, fieldDelimiter);
        --marshalField('', quoteChar, fieldDelimiter);
        marshalField(approverList(i).member_order_number, quoteChar, fieldDelimiter);
        --marshalField(to_char(i), quoteChar, fieldDelimiter);
        pApprovalListCount := pApprovalListCount +1;
        marshalField(TO_CHAR(pApprovalListCount), quoteChar, fieldDelimiter);
      END IF;

    END IF;

  END LOOP;

  pApprovalListStr := approvalListStr;

  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Leaving get_ame_approval_list...');
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- pApprovalListStr :' || pApprovalListStr);
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, 'Output param -- pApprovalListCount :' || pApprovalListCount);
    END IF;
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  pApprovalListCount := 0;
  pApprovalListStr   := 'NO_DATA_FOUND';
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix || l_api_name || '.NO_DATA_FOUND', 'NO_DATA_FOUND');
    END IF;
  END IF;
WHEN OTHERS THEN
  pApprovalListCount := 0;
  pApprovalListStr   := 'EXCEPTION';
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix || l_api_name || '.others_exception', sqlerrm);
    END IF;
  END IF;
END get_ame_approval_list_history;
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
--    ame_api2.getNextApprovers4.
--  + Get the next approver name from the global variable g_next_approvers
--    and for each retrieved approver separate workflow process is kicked.
--  + They are marked as child of the current approval process (workflow
--    master detail co-ordination).
--  + For example, if there are 3 approvers, then 3 child process will be
--    created and each of them will be notified at the same time.
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
    itemtype IN VARCHAR2,
    itemkey  IN VARCHAR2,
    actid    IN NUMBER,
    funcmode IN VARCHAR2,
    resultout OUT NOCOPY VARCHAR2)

IS

  l_progress    VARCHAR2(4000) DEFAULT '000';
  l_item_key wf_items.item_key%TYPE;
  l_next_approver_id NUMBER;
  l_next_approver_name per_employees_current_x.full_name%TYPE;
  l_next_approver_user_name VARCHAR2(100);
  l_next_approver_disp_name VARCHAR2(240);
  l_orig_system             VARCHAR2(48);
  l_org_id                  NUMBER;
  t_pos_varname wf_engine.nametabtyp;
  t_pos_varval wf_engine.texttabtyp;
  l_approver_index       NUMBER;
  l_ame_transaction_id   NUMBER;
  l_api_name       VARCHAR2(500) := 'launch_parallel_approval';
  l_log_head       VARCHAR2(500) := g_module_prefix||l_api_name;
  l_owner_user_name fnd_user.user_name%TYPE;
  l_userkey VARCHAR2(100);
  suppliername VARCHAR2(240);
  requester    VARCHAR2(240);
  suppid VARCHAR2(100);
  l_reg_key pos_supplier_registrations.reg_key%TYPE;

BEGIN

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout  := wf_engine.eng_null;
    RETURN;
  END IF;

  suppid       := wf_engine.GetItemAttrText ( itemtype => itemtype, itemkey => itemkey, aname => 'SUPP_REG_ID');
  suppliername := wf_engine.GetItemAttrText ( itemtype => itemtype, itemkey => itemkey, aname => 'SUPPLIERNAME');
  requester    := wf_engine.GetItemAttrText ( itemtype => itemtype, itemkey => itemkey, aname => 'REQUESTOR');
  l_userkey    := itemkey;

  SELECT reg_key
    INTO l_reg_key
  FROM pos_supplier_registrations
  WHERE supplier_reg_id = suppid;

  l_progress  := l_api_name || ' started: -- itemkey : ' || itemkey ;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  l_approver_index := g_next_approvers.first;
  --Loop through current set of approvers until l_approver_index is not null
  WHILE (l_approver_index IS NOT NULL)
  LOOP

    l_progress := l_api_name || ' : itemtype '|| itemtype ||'itemkey '|| itemkey
				|| 'g_next_approvers (l_approver_index).orig_system ' || g_next_approvers (l_approver_index).orig_system
				|| ': g_next_approvers.name' ||g_next_approvers(l_approver_index).name;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

    --Fetch new item key for parallel subprocess
    SELECT TO_CHAR (itemkey)
      ||'-'
      ||TO_CHAR (pos_wf_itemkey_s1.nextval)
      INTO l_item_key
    FROM sys.dual;

    --Create the parallel process
    wf_engine.CreateProcess ( itemtype => itemtype, itemkey => l_item_key, process => 'PARALLEL_APPROVAL_PROCESS');

    l_progress := l_api_name || ' : itemtype '|| itemtype ||'l_item_key '|| l_item_key || 'Parallel Sub process is created';
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

    --Set parent attributes
    wf_engine.SetItemParent (   itemtype => itemtype,   itemkey => l_item_key, parent_itemtype => itemtype, parent_itemkey => itemkey, parent_context => NULL );

    l_progress := 'WF attributes has been set to parallel sub process l_item_key: ' || l_item_key;

    getNextApprIdBasedOnApprType(g_next_approvers (l_approver_index).orig_system, g_next_approvers (l_approver_index).orig_system_id, l_next_approver_id, l_next_approver_name);

    l_progress := l_api_name || ' : l_next_approver_id : ' || l_next_approver_id || 'l_next_approver_name: ' || l_next_approver_name;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

    t_pos_varname (1) := 'AME_APPROVER_TYPE';
    t_pos_varval  (1)  := g_next_approvers (l_approver_index).orig_system;

    wf_directory.getusername (ame_util.perorigsystem, l_next_approver_id, l_next_approver_user_name, l_next_approver_disp_name);

    IF (g_next_approvers (l_approver_index).orig_system = ame_util.perorigsystem) THEN
      t_pos_varname (2) := 'APPROVER_USER_NAME';
      t_pos_varval  (2)  := g_next_approvers (l_approver_index).name;
      t_pos_varname (3) := 'CURRENT_APPROVER_USER_NAME';
      t_pos_varval  (3)  := g_next_approvers (l_approver_index).name;
      t_pos_varname (4) := 'APPROVER_DISPLAY_NAME';
      t_pos_varval  (4)  := g_next_approvers (l_approver_index).display_name;
    ELSE
      t_pos_varname (2) := 'APPROVER_USER_NAME';
      t_pos_varval  (2)  := l_next_approver_user_name;
      t_pos_varname (3) := 'CURRENT_APPROVER_USER_NAME';
      t_pos_varval  (3)  := l_next_approver_user_name;
      t_pos_varname (4) := 'APPROVER_DISPLAY_NAME';
      t_pos_varval  (4)  := l_next_approver_disp_name;
    END IF;

    l_progress := l_api_name || ' : AME_APPROVER_TYPE - ' || g_next_approvers (l_approver_index).orig_system || 'APPROVER_USER_NAME : ' || g_next_approvers (l_approver_index).name
                  || ' OR ' || l_next_approver_user_name || 'APPROVER_DISPLAY_NAME: '   || g_next_approvers (l_approver_index).display_name || ' OR ' || l_next_approver_disp_name;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

    -- set owner username
    l_owner_user_name := t_pos_varval (2);

    --Set the item attributes from the array

    t_pos_varname (5) := 'AME_APPROVER_ID';
    t_pos_varval  (5)  := g_next_approvers (l_approver_index).orig_system_id;
    t_pos_varname (6) := 'APPROVER_EMPID';
    t_pos_varval  (6)  := l_next_approver_id;
    t_pos_varname (7) := 'APPROVAL_GROUP_ID';

    --IF (g_next_approvers (l_approver_index).api_insertion = yesChar) THEN
    --t_pos_varval (7) := 1;
    --ELSE
      t_pos_varval (7) := g_next_approvers (l_approver_index).group_or_chain_id;
    --END IF;

    t_pos_varname (8) := 'IS_FYI_APPROVER';
    IF (g_next_approvers (l_approver_index).approver_category = ame_util.fyiapprovercategory) THEN
      t_pos_varval (8) := yesChar;
    ELSE
      t_pos_varval (8) := noChar;
    END IF;

    t_pos_varname (9)  := 'SUPPLIERNAME';
    t_pos_varval  (9)  := suppliername;
    t_pos_varname (10)  := 'REQUESTOR';
    t_pos_varval  (10)  := requester;
    t_pos_varname (11) := 'SUPP_REG_ID';
    t_pos_varval  (11) := suppid;
    t_pos_varname (12) := 'REG_KEY';
    t_pos_varval  (12) := l_reg_key;
    t_pos_varname (13) := 'APPROVER_RESPONSE';
    t_pos_varval  (13) := ame_util.noResponseStatus;
    t_pos_varname (14) := 'POS_SUPP_MESSAGE_SUB';
    IF (g_next_approvers (l_approver_index).approver_category = ame_util.fyiapprovercategory) THEN
      t_pos_varval (14):= GET_BUYER_FYI_NOTIF_SUBJECT(suppliername);
    ELSE
      t_pos_varval (14):= GET_BUYER_ACTN_NOTIF_SUBJECT(suppliername);
    END IF;

    l_progress := l_api_name || ' : AME_APPROVER_ID - ' || g_next_approvers (l_approver_index).orig_system_id || 'APPROVER_EMPID : ' || l_next_approver_id
                  || 'APPROVAL_GROUP_ID: '  || g_next_approvers (l_approver_index).group_or_chain_id;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

    wf_engine.SetItemAttrTextarray (itemtype, l_item_key, t_pos_varname, t_pos_varval);
    wf_engine.SetItemOwner(   itemtype => itemtype, itemkey => l_item_key, owner    => l_owner_user_name);
    wf_engine.SetItemUserKey( itemtype => itemtype, itemkey => l_item_key, userkey  => l_userkey);

    IF ( g_next_approvers (l_approver_index).approver_category <> ame_util.fyiapprovercategory ) THEN

      pos_vendor_reg_pkg.insert_reg_action_hist( p_supp_reg_id => suppid,
                            p_action      => pos_vendor_reg_pkg.ACTN_PENDING,
                            p_from_user_id => l_next_approver_id,
                            p_to_user_id => NULL,
                            p_note        => NULL,
                            p_approval_group_id => g_next_approvers (l_approver_index).group_or_chain_id
                        );
    ELSIF ( g_next_approvers (l_approver_index).approver_category = ame_util.fyiapprovercategory ) THEN

      pos_vendor_reg_pkg.insert_reg_action_hist( p_supp_reg_id => suppid,
                            p_action      => pos_vendor_reg_pkg.ACTN_FYI,
                            p_from_user_id => l_next_approver_id,
                            p_to_user_id => NULL,
                            p_note        => NULL,
                            p_approval_group_id => g_next_approvers (l_approver_index).group_or_chain_id
                        );
    END IF;

    --Kick off the process
    wf_engine.StartProcess (itemtype => itemtype ,itemkey => l_item_key);

    l_progress := l_api_name || ' : WF Process started : itemtype' || itemtype || 'l_item_key ' || l_item_key;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

    --Move to the next index
    l_approver_index := g_next_approvers.next (l_approver_index);

  END LOOP; --WHILE (l_approver_index IS NOT NULL)

  -- After routing is done, delete approver list
  g_next_approvers.delete;

  l_progress := l_api_name || ': Completed';
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  resultout  := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED';

EXCEPTION
WHEN OTHERS THEN
  WF_CORE.context('POS_SUPP_APPR', l_api_name, l_progress, sqlerrm);
  IF (g_fnd_debug = yesChar) THEN
	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		FND_LOG.string(FND_LOG.level_statement, 'itemtype '|| itemtype ||'itemkey '|| itemkey || 'l_log_head '|| l_log_head, 						'Launch_Parallel_Approval');
	END IF;
  END IF;
  RAISE;
END launch_parallel_approval;

/*
itemkey : Main workflow process itemkey
approver : current user logged into applciation
isApproverExists : check if approver is current approver
approverWFItemKey : this is parallel approval subprocess workflow item key associted for this approver
Descrption: Basically we loop through all parallel subprocess
and find out approver is available and also returns subprocess wf item key
*/

PROCEDURE get_wf_details
  (
    p_itemkey         IN VARCHAR2,
    approver          IN VARCHAR2,
    approverWFItemKey IN OUT nocopy VARCHAR2,
    notificationID    IN OUT NOCOPY VARCHAR2,
    wf_process_status IN OUT NOCOPY VARCHAR2
  )

IS

  wf_approver          VARCHAR2(100);
  wf_approver_response VARCHAR2(100);
  l_api_name     VARCHAR2(50)  := 'get_wf_details';
  l_progress     VARCHAR2(4000) := '000';
  l_log_head       VARCHAR2(500) := g_module_prefix||l_api_name;

  CURSOR l_open_ntfs ( itemtype    IN wf_items.parent_item_type%TYPE, p_itemkey IN wf_items.parent_item_key%TYPE, approver_name varchar2 )
  IS
    SELECT wfi.item_type,
      wfi.item_key,
      wf_fwkmon.getitemstatus(wfi.ITEM_TYPE, wfi.ITEM_KEY, wfi.END_DATE, wfi.ROOT_ACTIVITY, wfi.ROOT_ACTIVITY_VERSION) AS STATUS_CODE,
      wfn.recipient_role,
      wfn.original_recipient,
      wfias.activity_status,
      wfn.notification_id
    FROM wf_items wfi,
      wf_item_activity_statuses wfias,
      wf_notifications wfn
    WHERE wfi.parent_item_key  = p_itemkey
    AND wfi.item_type          = wfItemType
    AND wfias.item_type        = wfi.item_type
    AND wfias.item_key         = wfi.item_key
    --AND wfn.recipient_role     = approver_name
    --AND wfias.activity_status  = ame_util.notifiedStatus   // to make sure we get wf details even for errored out(validation failed) processes
    --AND wfn.status             = 'OPEN'
    AND wfn.message_name      IN ('SUPPLIER_PROPSAL')
    AND wfias.notification_id IS NOT NULL
    AND wfias.notification_id  = wfn.notification_id;

  l_open_ntf l_open_ntfs%ROWTYPE;

BEGIN

  approverWFItemKey := NULL;
  notificationID    := NULL;

  l_progress := l_api_name || ' : 001 Loop through all parallel sub processes to find process associted to approver :' || approver;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  OPEN l_open_ntfs(wfItemType, p_itemkey, approver);
  LOOP
    FETCH l_open_ntfs INTO l_open_ntf;
    EXIT
  WHEN l_open_ntfs%NOTFOUND;

    wf_approver          := wf_engine.GetItemAttrText(itemtype => wfItemType, itemkey => l_open_ntf.item_key, aname => 'APPROVER_USER_NAME');
    wf_approver_response := wf_engine.GetItemAttrText(itemtype => wfItemType, itemkey => l_open_ntf.item_key, aname => 'APPROVER_RESPONSE');

    l_progress := l_api_name || ' : wf_approver: ' || wf_approver || 'wf_approver_response: ' || wf_approver_response;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

   -- IF ( wf_approver = approver ) THEN
    IF ( l_open_ntf.recipient_role = approver OR wf_approver = approver ) THEN

      approverWFItemKey        := l_open_ntf.item_key;
      wf_process_status        := l_open_ntf.status_code;

      IF ( wf_approver_response = ame_util.noResponseStatus AND l_open_ntf.activity_status = ame_util.notifiedStatus ) THEN
        notificationID         := l_open_ntf.notification_id;
      END IF;

    END IF;

  END LOOP;

  CLOSE l_open_ntfs;

  l_progress := l_api_name || ' Completed and WF details are approverWFItemKey: ' || approverWFItemKey ||  'notificationID: ' || notificationID;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  WF_CORE.context('POS_SUPP_APPR', l_api_name, l_progress, sqlerrm);
  IF (g_fnd_debug = yesChar) THEN
	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		FND_LOG.string(FND_LOG.level_statement, 'l_log_head '|| l_log_head, 'get_wf_details');
	END IF;
  END IF;
  RAISE;

END get_wf_details;

-- This is gateway to call APPROVE/REJECT/RETURN(NOTIFY) from JAVA application
-- If approver has notification OPEN, then we should respond through it
-- Otherwise, we directly call approve/reject/return API to process request
--IN
-- suppid - registration id
-- approver - user who is taking the action
-- action - 'APPROVE/REJECT/RETURNTOSUPPLIER'
-- comments -- comments if any provided during action
-- OUT
-- result -- SUCCESS/FAILURE
-- processresult -- APPROVED/REJECTED/INPROCESS

PROCEDURE ACK_SUPP_REG
  (
    suppid        IN VARCHAR2,
    approver      IN VARCHAR2,
    action        IN VARCHAR2,
    comments      IN VARCHAR2,
    result        IN OUT nocopy VARCHAR2,
    processresult IN OUT NOCOPY VARCHAR2
  )

IS

  l_notification_id     VARCHAR2(50);
  l_approver_wf_itemkey VARCHAR2(100);
  wf_process_status     VARCHAR2(30);
  p_itemkey             VARCHAR2(1000);
  l_api_name            VARCHAR2(50)   := 'ACK_SUPP_REG';
  l_progress            VARCHAR2(4000) := '000';
  l_notes               VARCHAR2(4000) := NULL;
  l_notifAction         VARCHAR2(50)   := NULL;

BEGIN

  result := 'SUCCESS';
  p_itemkey := GET_WF_TOP_PROCESS_ITEM_KEY(suppid);
  g_userAction := action;

  l_progress := l_api_name || ' : suppid: ' || suppid || 'p_itemkey -' ||p_itemkey || 'approver: ' || approver || 'action: ' || action || 'comments: ' || comments ;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  IF( action IN ( ame_util.approvedStatus ) ) THEN

      SELECT SM_BUYER_INTERNAL_NOTES
        INTO l_notes
      FROM pos_supplier_registrations
      WHERE supplier_reg_id = suppid;

  ELSIF ( action IN ( ameReturnToSupplierStatus, ame_util.rejectStatus, amePublishRFI ) ) THEN

      IF (FND_PROFILE.VALUE('POS_SM_ENABLE_SPM_EXTENSION') = 'Y') THEN
      SELECT SM_NOTE_TO_SUPPLIER
        INTO l_notes
      FROM pos_supplier_registrations
      WHERE supplier_reg_id = suppid;
      ELSE
        SELECT NOTE_TO_SUPPLIER
          INTO l_notes
        FROM pos_supplier_registrations
        WHERE supplier_reg_id = suppid;
      END IF;

  END IF;

  get_wf_details(p_itemkey, approver, l_approver_wf_itemkey, l_notification_id, wf_process_status);

  wf_engine.SetItemAttrText( itemtype => wfitemtype, itemkey => l_approver_wf_itemkey, aname => 'NOTE', avalue => l_notes );

  -- If User has OPEN notification, then we should respond through notification
  IF ( l_approver_wf_itemkey IS NOT NULL AND l_notification_id IS NOT NULL ) THEN

    IF (action = amePublishRFI) THEN
      l_notifAction := ameReturnToSupplierStatus;
    ELSE
      l_notifAction := action;
    END IF;
    WF_NOTIFICATION.SetAttrText( nid => l_notification_id , aname => 'RESULT', avalue => l_notifAction );
    WF_NOTIFICATION.SetAttrText( nid => l_notification_id , aname => 'NOTE',   avalue => l_notes );
    WF_NOTIFICATION.Respond( nid => l_notification_id , respond_comment => l_notes, responder => approver );

    l_progress := l_api_name || ' : responding through notification - l_notification_id - '|| l_notification_id;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

  ELSIF (l_approver_wf_itemkey IS NOT NULL AND l_notification_id IS NULL ) THEN

    l_progress := l_api_name || ' : calling directly ';
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

    IF(action = ame_util.approvedStatus) THEN

      process_approve(l_approver_wf_itemkey, result, processresult);

    ELSIF (action = ame_util.rejectStatus) THEN

      process_reject(l_approver_wf_itemkey, result, processresult);

    ELSIF (action = ameReturnToSupplierStatus OR action = amePublishRFI) THEN

      process_return(l_approver_wf_itemkey, result, processresult);

    END IF;

    l_progress := l_api_name || ' : result:  ' || result || 'processresult: ' || processresult;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

  END IF;

  GET_AME_PROCESS_STATUS( suppid => suppid, result =>processresult );

  l_progress := l_api_name || ': completed -> ' || 'result: ' || result || ' processresult :  ' || processresult || 'g_isAnyError : ' || g_isAnyError;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  IF (g_isAnyError = yesChar) THEN
    processresult := 'ERROR';
    result := 'FAILURE';
  END IF;
EXCEPTION
WHEN OTHERS THEN
  result := 'FAILURE';
  WF_CORE.context('POS_SUPP_APPR', l_api_name, l_progress, sqlerrm);
  IF (g_fnd_debug = yesChar) THEN
	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
	END IF;
  END IF;
  RAISE;
END ACK_SUPP_REG;

-- Abort all workflow processes which are in completed status based on action

PROCEDURE abort_workflow_process
  (
    p_itemkey IN VARCHAR2,
    approver VARCHAR2,
    group_id VARCHAR2,
    action IN VARCHAR2,
    result IN OUT NOCOPY VARCHAR2
  )

IS

  l_api_name     VARCHAR2(50) := 'abort_workflow_process';
  approve_result VARCHAR2(100);
  process_result VARCHAR2(100);
  return_status  VARCHAR2(100);
  msg_count      NUMBER;
  msg_data       VARCHAR2(4000);
  abort_result   VARCHAR2(20);
  approverRecord ame_util.approverRecord2;
  l_approver_list ame_util.approversTable2;
  l_process_out         VARCHAR2(10);
  itemkey               VARCHAR2(1000);
  lerrname              VARCHAR2(30);
  lerrmsg               VARCHAR2(2000);
  lerrstack             VARCHAR2(32000);
  l_member_order_num    VARCHAR2(1000);
  l_notification_id     VARCHAR2(50);
  l_approver_exists     VARCHAR2(10);
  l_approver_wf_itemkey VARCHAR2(100);
  l_progress            VARCHAR2(4000);
  wf_process_status     VARCHAR2(100);
  approver_order_num    VARCHAR2(100);
  wf_group_id           VARCHAR2(100);
  l_suppid              VARCHAR2(100);
  l_approverId          VARCHAR2(100);
  l_no_actn_mesg        VARCHAR2(4000);
  l_approver_disp_name  per_all_people_f. full_name%TYPE;
  l_approverType        VARCHAR2(50);
  l_ameUserName         VARCHAR2(1000);
  l_wfUserName          VARCHAR2(1000);

BEGIN

  l_progress := l_api_name || ' : 000 p_itemkey - '||p_itemkey||' approver -'|| approver || 'group_id- ' || group_id || 'action - ' || action;

  -- Get current approver workflow details
  get_wf_details(p_itemkey, approver, l_approver_wf_itemkey, l_notification_id, wf_process_status);
  l_approverType := wf_engine.GetItemAttrText(  itemtype  => wfItemType, itemkey => l_approver_wf_itemkey ,aname => 'AME_APPROVER_TYPE'  );
  IF (l_approverType = 'POS') THEN
    l_ameUserName := 'POS:'|| wf_engine.GetItemAttrText( itemtype => wfItemType, itemkey => l_approver_wf_itemkey, aname => 'AME_APPROVER_ID');
  ELSE
    l_ameUserName  := wf_engine.GetItemAttrText( itemtype => wfItemType, itemkey => l_approver_wf_itemkey, aname => 'APPROVER_USER_NAME');
  END IF;
  l_progress  := l_api_name || ' : l_ameUserName - '||l_ameUserName || ' group_id: ' || group_id;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;
  -- Get approver information who performed the action
  get_approver_record( p_itemkey, l_ameUserName, group_id, approverRecord );
  approver_order_num := approverRecord.member_order_number;

  l_progress  := l_api_name || ' : 001 approver_order_num - '||approver_order_num || ' l_ameUserName: ' || l_ameUserName;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;
  -- Get current approver employee id who is taking an action
  l_approverId := wf_engine.GetItemAttrText(  itemtype  => wfItemType,itemkey => l_approver_wf_itemkey ,aname => 'APPROVER_EMPID'  );
  BEGIN
    SELECT full_name INTO l_approver_disp_name
    FROM per_all_people_f
    WHERE person_id = l_approverId
    AND TRUNC(sysdate) BETWEEN effective_start_date(+) AND effective_end_date(+);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    BEGIN
        SELECT hp.person_first_name || hp.person_last_name INTO l_approver_disp_name
        FROM fnd_user fu,
          hz_parties hp
        WHERE fu.user_id = l_approverId
        AND fu.person_party_id = hp.party_id(+)
        AND rownum = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_approver_disp_name := NULL;
    END;
  END;
  fnd_message.set_name('POS','POS_SUPPREG_NO_ACTION_MESG');
  fnd_message.set_token('APPROVER_NAME', l_approver_disp_name);
  l_no_actn_mesg := fnd_message.get;
  l_progress  := l_api_name || ' : 002 l_approver_disp_name - '||l_approver_disp_name;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  l_suppid := wf_engine.GetItemAttrText( itemtype => wfItemType, itemkey => p_itemkey, aname => 'SUPP_REG_ID' );

  -- get all approvers
  get_all_approvers(l_suppid, l_approver_list, l_process_out);

  FOR i IN 1.. l_approver_list.count
  LOOP

    l_progress  := l_api_name || ' Get user name to whom notification has been sent  : l_approver_list(i).orig_system_id - '||l_approver_list(i).orig_system_id
                              || 'l_approver_list (i).orig_system' || l_approver_list (i).orig_system;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;
    -- If approver type is POS(HR Positions), then obviously current user(or workflow user/approver) name will be
    -- different from the AME name l_approver_list(i).name: For ex: l_approver_list(i).name = POS:324.
    -- Here 324 is position id and we do sent notification to any user(see launch process how we find user of a given position) who has been assigned to this position.
    -- AND actual approver name(to whom we send notification for approval) is CBAKER
    -- In other approver types(FND_USR/PER), then ame name is same as actual approver/ user name
    IF ( l_approver_list (i).orig_system = ame_util.posorigsystem ) THEN
      BEGIN
        -- Get user name to whom notification has been sent
        SELECT user_name INTO l_wfUserName
        FROM fnd_user
        WHERE employee_id IN
          (SELECT FROM_USER
            FROM pos_action_history
            WHERE OBJECT_ID = l_suppid
            AND FROM_USER IN(SELECT DISTINCT person.person_id
                                FROM per_all_assignments_f asg,per_all_people_f person
                                WHERE asg.position_id = l_approver_list(i).orig_system_id
                                AND person.person_id = asg.person_id)
            AND ACTION_CODE = pos_vendor_reg_pkg.ACTN_PENDING)
        AND ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_wfUserName := NULL;
      END;
    ELSE
      l_wfUserName := l_approver_list(i).name;
    END IF;
    IF(l_wfUserName IS NOT NULL) THEN
    -- get WF details of this user
      get_wf_details(p_itemkey, l_wfUserName, l_approver_wf_itemkey, l_notification_id, wf_process_status);
      l_progress  := l_api_name || ' : 002 l_approver_list(i).approval_status - '||l_approver_list(i).approval_status || 'l_wfUserName - ' || l_wfUserName
                  || 'l_approver_list(i).group_or_chain_id - ' || l_approver_list(i).group_or_chain_id
                  || 'l_approver_wf_itemkey - ' || l_approver_wf_itemkey
                  || 'l_notification_id - ' || l_notification_id
                  || 'wf_process_status - ' || wf_process_status ;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
        END IF;
      END IF;
    END IF;

    -- shouldnt abort the WF proces associted same user who performed the action
    -- l_approver_list(i).approval_status IS NOT NULL means he is future approver, so there wont be any process launched for this user
    IF ( l_ameUserName <> l_approver_list(i).name AND l_approver_list(i).approval_status IS NOT NULL AND l_approver_wf_itemkey IS NOT NULL) THEN

        l_approverId := wf_engine.GetItemAttrText(  itemtype  => wfItemType,itemkey => l_approver_wf_itemkey ,aname => 'APPROVER_EMPID'  );
        wf_group_id := wf_engine.GetItemAttrText(itemtype => wfItemType,    itemkey => l_approver_wf_itemkey, aname => 'APPROVAL_GROUP_ID');

        get_approver_record( p_itemkey, l_approver_list(i).name, l_approver_list(i).group_or_chain_id, approverRecord );

        l_progress  := l_api_name || ' : 003 approverRecord.name - ' || approverRecord.name
                  || ' wf_group_id - ' || wf_group_id  || ' approverRecord.member_order_number - ' || approverRecord.member_order_number || ' approverRecord.approval_status - '
                  || approverRecord.approval_status || ' approver_order_num - ' || approver_order_num;
        IF g_fnd_debug = yesChar THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
          END IF;
        END IF;

        --abort process which has same order number same as that of approver who performed the action
        IF ( approver_order_num = approverRecord.member_order_number ) THEN

          IF( action = ame_util.approvedStatus ) THEN

          -- There could be chances of multiple WF processes for same user are launched with diff groupd id's
          -- So, we should abort only process which has same group id same as that of approver who performed the action
            IF( approverRecord.approval_status = ame_util.beatByFirstResponderStatus AND wf_group_id = group_id ) THEN

              l_progress  := l_api_name || ': 004 APPROVE:   abort proces : ' || l_approver_wf_itemkey;
              IF g_fnd_debug = yesChar THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                  FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
                END IF;
              END IF;

            IF ( wf_process_status = 'ACTIVE') THEN
              wf_engine.AbortProcess( wfItemType, l_approver_wf_itemkey );
            END IF;

            pos_vendor_reg_pkg.update_reg_action_hist( p_supp_reg_id =>  l_suppid,
                                                        p_action   =>  pos_vendor_reg_pkg.ACTN_NO_ACTION,
                                                        p_note     =>  l_no_actn_mesg,
                                                        p_from_user_id => l_approverId,
                                                        p_to_user_id => NULL
                                                      );

            END IF;

          ELSIF ( action = ame_util.rejectStatus ) THEN

            l_progress  := l_api_name || ' : 004 REJECT :   abort process : ' || l_approver_wf_itemkey;
            IF g_fnd_debug = yesChar THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
              END IF;
            END IF;

          IF ( wf_process_status = 'ACTIVE') THEN
            wf_engine.AbortProcess( wfItemType, l_approver_wf_itemkey );
          END IF;
          pos_vendor_reg_pkg.update_reg_action_hist( p_supp_reg_id =>  l_suppid,
                                                        p_action   =>  pos_vendor_reg_pkg.ACTN_NO_ACTION,
                                                        p_note     =>  l_no_actn_mesg,
                                                        p_from_user_id => l_approverId,
                                                        p_to_user_id => NULL
                                                      );

          -- in case of RETURN there wont be anything like beatbyfirstresponse as this action is not standard AME action
          ELSIF ( action = ameReturnStatus ) THEN

            l_progress  := l_api_name || ' : 004 RETURN    abort process : ' || l_approver_wf_itemkey;
            IF g_fnd_debug = yesChar THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
              END IF;
            END IF;

          IF ( wf_process_status = 'ACTIVE') THEN
            wf_engine.AbortProcess( wfItemType, l_approver_wf_itemkey );
          END IF;
          pos_vendor_reg_pkg.update_reg_action_hist( p_supp_reg_id =>  l_suppid,
                                                        p_action   =>  pos_vendor_reg_pkg.ACTN_NO_ACTION,
                                                        p_note     =>  l_no_actn_mesg,
                                                        p_from_user_id => l_approverId,
                                                        p_to_user_id => NULL
                                                      );

          -- Just abort the process
          ELSIF ( action IS NULL ) THEN

            l_progress  := l_api_name || ' : 004 action is NULL (this usually called from APPROVE which made whole request APPROVE) abort process : ' || l_approver_wf_itemkey;
            IF g_fnd_debug = yesChar THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
              END IF;
            END IF;

          IF ( wf_process_status = 'ACTIVE') THEN
              wf_engine.AbortProcess( wfItemType, l_approver_wf_itemkey );
          END IF;
		  pos_vendor_reg_pkg.update_reg_action_hist( p_supp_reg_id =>  l_suppid,
                                                         p_action   =>  pos_vendor_reg_pkg.ACTN_NO_ACTION,
                                                         p_note     =>  l_no_actn_mesg,
                                                         p_from_user_id => l_approverId,
                                                         p_to_user_id => NULL
                                                       );
        END IF;
      END IF;
    END IF;

  END LOOP;

  result := 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
  result := 'FAILURE';
  WF_CORE.context('POS_SUPP_APPR', l_api_name, l_progress, sqlerrm);
  IF (g_fnd_debug = yesChar) THEN
	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
	END IF;
  END IF;
  RAISE;
END abort_workflow_process;

-- Get Approver record for an given user name and goupd id

PROCEDURE get_approver_record
  (
    p_itemkey         IN VARCHAR2,
    approver          IN VARCHAR2,
    group_or_chain_id IN VARCHAR2,
    approverRecord    IN OUT NOCOPY ame_util.approverRecord2
  )
IS

  l_approver_list ame_util.approversTable2;
  l_process_out VARCHAR2(10);
  l_api_name     VARCHAR2(50)  := 'get_approver_record';
  l_progress     VARCHAR2(4000) := '000';
  l_suppid       pos_supplier_registrations.supplier_reg_id%TYPE;
  l_isUserExists BOOLEAN := FALSE;

BEGIN

  l_progress  := l_api_name || ' : approver :' || approver || 'group_or_chain_id: ' || group_or_chain_id;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  l_suppid := wf_engine.GetItemAttrText( itemtype => wfItemType, itemkey => p_itemkey, aname => 'SUPP_REG_ID' );

  get_all_approvers(l_suppid, l_approver_list, l_process_out);

  FOR i IN 1.. l_approver_list.Count LOOP

    IF ( l_approver_list(i).name = approver AND l_approver_list(i).group_or_chain_id = group_or_chain_id) THEN

      l_isUserExists := TRUE;
    END IF;
    IF (l_isUserExists) THEN
      l_progress  := l_api_name || ' : ' || approver || ':  exists';
      IF g_fnd_debug = yesChar THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
        END IF;
      END IF;

      approverRecord := l_approver_list(i);
      EXIT; -- exit loop as we found the user record

    END IF;

  END LOOP;

EXCEPTION
WHEN OTHERS THEN
  approverRecord := NULL;
  WF_CORE.context('POS_SUPP_APPR', l_api_name, l_progress, sqlerrm);
  IF (g_fnd_debug = yesChar) THEN
	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
	END IF;
  END IF;
  RAISE;
END get_approver_record;


-- Check if logged in user is current approver
FUNCTION CHECK_CURRENT_APPROVER
  (
    suppid IN VARCHAR2
  )
  RETURN VARCHAR2
IS

  isAmeEnabled          VARCHAR2(1);
  l_api_name            VARCHAR2(50)  := 'CHECK_CURRENT_APPROVER';
  l_progress            VARCHAR2(500) := '000';
  l_resultout           VARCHAR2(100);
  isCurrentApprover     VARCHAR2(1);
  approverName          VARCHAR2(1000);
  wfitemkey             VARCHAR2(1000);

BEGIN

  l_progress := l_api_name || ' : 001';

  --procedure returns Y for all users when AME is not enabled
  CHECK_IF_AME_ENABLED(result => isAmeEnabled);

  IF (isAmeEnabled = noChar) THEN
    RETURN yesChar;
  END IF;
  wfitemkey := GET_WF_TOP_PROCESS_ITEM_KEY(suppid);
  l_progress := l_api_name || ' : 002 CHECK_IF_AME_ENABLED returns '||isAmeEnabled || 'wfitemkey - ' || wfitemkey;
  IF g_fnd_debug                         = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;

  END IF;

  get_current_approver_details(wfitemkey, FND_GLOBAL.user_name, isCurrentApprover, approverName);

  RETURN isCurrentApprover;

EXCEPTION
WHEN OTHERS THEN
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RETURN noChar;
END CHECK_CURRENT_APPROVER;


-- Get current approver display name
FUNCTION GET_APPROVER_NAME_IN_WF
  (
    suppid IN VARCHAR2
  )
  RETURN VARCHAR2

IS

  isAmeEnabled          VARCHAR2(1);
  l_api_name            VARCHAR2(50)  := 'GET_APPROVER_NAME_IN_WF';
  l_progress            VARCHAR2(500) := '000';
  isCurrentApprover     VARCHAR2(1);
  approverName          VARCHAR2(1000);
  wfitemkey             VARCHAR2(1000);

BEGIN

  l_progress := l_api_name || ' : 001';


  --procedure returns Y for all users when AME is not enabled
  CHECK_IF_AME_ENABLED(result => isAmeEnabled);

  IF (isAmeEnabled = noChar) THEN
    RETURN '';
  END IF;

  wfItemKey := GET_WF_TOP_PROCESS_ITEM_KEY(suppid);
  l_progress := l_api_name || ' : 002 CHECK_IF_AME_ENABLED returns '||isAmeEnabled || 'wfItemKey: ' || wfItemKey;
  IF g_fnd_debug                         = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  get_current_approver_details(wfitemkey, FND_GLOBAL.user_name, isCurrentApprover, approverName);

  RETURN approverName;

EXCEPTION
WHEN OTHERS THEN
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RETURN '';
END GET_APPROVER_NAME_IN_WF;

-- Check if given approver is current approver in AME

PROCEDURE get_current_approver_details
  (
    itemkey           IN VARCHAR2,
    approver          IN VARCHAR2,
    isCurrentApprover IN OUT NOCOPY VARCHAR2,
    approverName      IN OUT NOCOPY VARCHAR2
  )

IS

  l_approver_list ame_util.approversTable2;
  l_process_out  VARCHAR2(10);
  user_firstname VARCHAR2(100);
  user_lastname  VARCHAR2(100);
  x_agent_id     NUMBER;
  l_api_name     VARCHAR2(50)  := 'get_current_approver_details';
  l_progress     VARCHAR2(4000) := '000';
  l_suppid       pos_supplier_registrations.supplier_reg_id%TYPE;
  --l_ame_approver_name VARCHAR2(50);
  l_is_fyi_approver VARCHAR2(5);
  l_requestStatus pos_supplier_registrations.registration_status%TYPE;
  l_approverStatus VARCHAR2(100);


  CURSOR l_open_ntfs ( itemtype    IN wf_items.parent_item_type%TYPE, p_itemkey IN wf_items.parent_item_key%TYPE, user_name VARCHAR2 )
  IS
    SELECT wfi.item_type,
      wfi.item_key,
      wf_fwkmon.getitemstatus(wfi.ITEM_TYPE, wfi.ITEM_KEY, wfi.END_DATE, wfi.ROOT_ACTIVITY, wfi.ROOT_ACTIVITY_VERSION) AS STATUS_CODE,
      wfn.recipient_role,
      wfn.original_recipient,
      wfias.activity_status,
      wfn.notification_id,
      wfn.more_info_role
    FROM wf_items wfi,
      wf_item_activity_statuses wfias,
      wf_notifications wfn
    WHERE wfi.parent_item_key  = p_itemkey
    AND wfi.item_type          = wfItemType
    AND wfias.item_type        = wfi.item_type
    AND wfias.item_key         = wfi.item_key
    AND wfn.recipient_role     = user_name
    --AND wfias.activity_status  = ame_util.notifiedStatus
    --AND wfn.status             = 'OPEN'    -- we don't check for any OPEN notification as there
                                             -- could be cases that wf might fail/complete but still approver has to take action.
    AND wfn.message_name      IN ('SUPPLIER_PROPSAL')
    AND wfias.notification_id IS NOT NULL
    AND wfias.notification_id  = wfn.notification_id;

  l_open_ntf l_open_ntfs%ROWTYPE;

BEGIN

  approverName :=  NULL;
  isCurrentApprover := noChar;
  l_suppid := wf_engine.GetItemAttrText( itemtype => wfItemType, itemkey => itemkey, aname => 'SUPP_REG_ID' );

  SELECT registration_status INTO  l_requestStatus
  FROM pos_supplier_registrations
  WHERE supplier_reg_id = l_suppid;

  l_progress := l_api_name || ' :  approver :'||approver || ' l_requestStatus:' || l_requestStatus;
  IF g_fnd_debug                         = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  IF(l_requestStatus = pos_vendor_reg_pkg.ACTN_PENDING) THEN
  OPEN l_open_ntfs(wfItemType, itemkey, approver);
  LOOP
    FETCH l_open_ntfs INTO l_open_ntf;
    EXIT
  WHEN l_open_ntfs%NOTFOUND;

    l_is_fyi_approver := wf_engine.GetItemAttrText(itemtype => wfItemType, itemkey => l_open_ntf.item_key, aname => 'IS_FYI_APPROVER');

    -- Get last user action of the approver.
    SELECT ACTION_CODE INTO l_approverStatus
    FROM (
      SELECT ACTION_CODE, SEQUENCE_NUM
      FROM pos_action_history
      WHERE object_id = l_suppid
      AND FROM_USER = (SELECT employee_id FROM fnd_user WHERE user_name = approver)
      ORDER BY SEQUENCE_NUM desc
    )
    WHERE ROWNUM < 2;
    l_progress := l_api_name || ' :  l_is_fyi_approver : '||l_is_fyi_approver
                             || 'l_open_ntf.more_info_role' || l_open_ntf.more_info_role
                             || 'l_open_ntf.activity_status' || l_open_ntf.activity_status;
    IF g_fnd_debug                         = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

    -- check if approver not requested any more info and process shouldnt be in COMPLETE status and he is not FYI approver
    --IF ( l_open_ntf.more_info_role IS NULL AND l_open_ntf.activity_status <> 'COMPLETE' AND l_is_fyi_approver = noChar)  THEN
    IF ( l_open_ntf.more_info_role IS NULL AND l_open_ntf.STATUS_CODE <> 'COMPLETE' AND l_open_ntf.STATUS_CODE <> 'FORCE' AND l_is_fyi_approver = noChar AND l_approverStatus = pos_vendor_reg_pkg.ACTN_PENDING)  THEN

          isCurrentApprover := yesChar;

    END IF;
      --Below Login will fail if a complete new approver list(doesn't include current approvers) is generated due to data change.
      --In  this case current user/approver will not find in new approver list hence this returns fasle for current user.
      -- Hence replaced this logic with above code to check if logged in user is current approver.
      /*
      l_suppid := wf_engine.GetItemAttrText( itemtype => wfItemType, itemkey => itemkey, aname => 'SUPP_REG_ID' );
      l_ame_approver_name := wf_engine.GetItemAttrText(itemtype => wfItemType, itemkey => l_open_ntf.item_key, aname => 'APPROVER_USER_NAME');

      l_progress := l_api_name || ' :  l_ame_approver_name : '||l_ame_approver_name;
      IF g_fnd_debug                         = yesChar THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
        END IF;
      END IF;

      get_all_approvers(l_suppid, l_approver_list, l_process_out);

      FOR i IN 1.. l_approver_list.count LOOP

        -- check if approver's workflow process ame approver is still pending with taking action(NOTIFIED).
        -- here current approver and workflow ame approver's name could be diff because of reassign action otherwise both will be same.
        IF ( l_approver_list(i).name = l_ame_approver_name AND l_approver_list(i).approval_status = ame_util.notifiedStatus AND l_approver_list(i).approver_category <> ame_util.fyiapprovercategory ) THEN

          isCurrentApprover := yesChar;

        END IF;

      END LOOP;

    END IF;
    */

    l_progress := l_api_name || ' :  isCurrentApprover : '||isCurrentApprover;
    IF g_fnd_debug                         = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

    IF ( isCurrentApprover = yesChar ) THEN

      BEGIN

        SELECT employee_id INTO x_agent_id FROM FND_USER WHERE user_name = approver;
        WF_DIRECTORY.GetUserName( 'PER', x_agent_id, approverName, approverName);

      EXCEPTION WHEN NO_DATA_FOUND THEN

        BEGIN

            SELECT hp.person_first_name,
              hp.person_last_name
            INTO user_firstname,
              user_lastname
            FROM fnd_user fu,
              hz_parties hp
            WHERE fu.user_name     = approver
            AND fu.person_party_id = hp.party_id(+)
            AND rownum             = 1;

            approverName := user_firstname||' '||user_lastname;

        EXCEPTION WHEN NO_DATA_FOUND THEN
          approverName := NULL;
        END;

      END;

    END IF;

  END LOOP;

  l_progress := l_api_name || ' :  approverName : '||approverName;
  IF g_fnd_debug                         = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  END IF;
EXCEPTION
WHEN OTHERS THEN
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
END get_current_approver_details;

-- Get all approverswho have been participated in AME TRX
PROCEDURE get_all_approvers(
    suppid       IN VARCHAR2,
    l_approver_list IN OUT NOCOPY ame_util.approversTable2,
    l_process_out   IN OUT NOCOPY VARCHAR2)

IS

  l_api_name     VARCHAR2(50)  := 'get_all_approvers';
  l_progress     VARCHAR2(4000) := '000';

BEGIN

  l_progress := l_api_name || ' :  Start';
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  ame_api2.getAllApprovers7 ( applicationIdIn => ameApplicationId, transactionIdIn => suppid, transactionTypeIn => ameTransactionType, approvalProcessCompleteYNOut => l_process_out, approversOut => l_approver_list );

  l_progress := l_api_name || ':  completed';
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RAISE;
END get_all_approvers;


-- This is called when approver takes an action on registration notification
PROCEDURE POST_APPROVAL_NOTIF(
    itemtype IN VARCHAR2,
    itemkey  IN VARCHAR2,
    actid    IN NUMBER,
    funcmode IN VARCHAR2,
    resultout OUT NOCOPY VARCHAR2)

IS

  p_itemkey wf_items.parent_item_key%TYPE;
  l_original_recipient wf_notifications.original_recipient%TYPE;
  l_current_recipient_role wf_notifications.recipient_role%TYPE;
  l_nid                          NUMBER;
  l_result                       VARCHAR2(100);
  l_progress                     VARCHAR2(4000);
  l_api_name                     VARCHAR2(50)  := 'POST_APPROVAL_NOTIF';
  l_forwardTo                    VARCHAR2(240);
  l_action                       VARCHAR2(100);
  l_origsys wf_roles.orig_system%TYPE;
  l_new_recipient_id wf_roles.orig_system_id%TYPE;
  l_fwd_approver_id   VARCHAR2(100);
  x_user_display_name VARCHAR2(240);
  x_agent_id          NUMBER;
  l_suppid VARCHAR2(20);
  l_groupid VARCHAR2(20);
  l_current_approver_id VARCHAR2(20);
  l_user_action VARCHAR2(100);
  l_error_mesg VARCHAR2(32000) := NULL;
  l_approver_user_name VARCHAR2(240);
  l_session_user_id    fnd_user.user_id%TYPE;
  l_session_resp_id NUMBER;
  l_session_appl_id NUMBER;
  l_responder_id       fnd_user.user_id%TYPE;
  l_preparer_resp_id NUMBER;
  l_preparer_appl_id NUMBER;
  l_preserved_ctx    VARCHAR2(5):= 'TRUE';
  l_user_id_to_set   NUMBER;
  l_resp_id_to_set   NUMBER;
  l_resp_key fnd_responsibility.responsibility_key%type;
  l_x_result varchar2(100);
  l_appl_id_to_set   NUMBER;
  l_org_id           NUMBER;
BEGIN

  l_progress :=  l_api_name|| ' : funcmode - '|| funcmode ||' itemkey - '|| itemkey || ' WF_ENGINE.CONTEXT_NEW_ROLE - ' || WF_ENGINE.CONTEXT_NEW_ROLE;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  SELECT parent_item_key
    INTO p_itemkey
  FROM wf_items
  WHERE item_type   = itemtype
    AND item_key    = itemkey;

  l_suppid := wf_engine.GetItemAttrText ( itemtype => itemtype, itemkey => p_itemkey, aname => 'SUPP_REG_ID');

  IF (funcmode     IN ('FORWARD', 'TRANSFER', 'QUESTION', 'ANSWER','TIMEOUT')) THEN

    IF (funcmode   IN ( 'FORWARD', 'TRANSFER' )) THEN
      l_action     := 'DELEGATE';
    ELSIF (funcmode = 'QUESTION') THEN
      l_action     := 'QUESTION';
    ELSIF (funcmode = 'ANSWER') THEN
      l_action     := 'ANSWER';
    ELSIF (funcmode = 'TIMEOUT') THEN
      l_action     := 'NO ACTION';
    END IF;

    IF (l_action <> 'NO ACTION') THEN

      Wf_Directory.GetRoleOrigSysInfo(WF_ENGINE.CONTEXT_NEW_ROLE, l_origsys, l_new_recipient_id);

    ELSE

      BEGIN
        SELECT original_recipient,
          DECODE(MORE_INFO_ROLE, NULL, RECIPIENT_ROLE, MORE_INFO_ROLE)
        INTO l_original_recipient,
          l_current_recipient_role
        FROM wf_notifications
        WHERE notification_id = WF_ENGINE.context_nid
        AND ( MORE_INFO_ROLE IS NOT NULL
        OR RECIPIENT_ROLE    <> ORIGINAL_RECIPIENT );
      EXCEPTION
      WHEN OTHERS THEN
        l_original_recipient := NULL;
      END;
      IF l_original_recipient IS NOT NULL THEN
        Wf_Directory.GetRoleOrigSysInfo(l_original_recipient, l_origsys, l_new_recipient_id);
      END IF;

    END IF;

    l_progress := l_api_name|| ' : l_new_recipient_id - '||l_new_recipient_id||' l_original_recipient - '|| l_original_recipient || 'l_origsys - ' || l_origsys;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

    -- We should not be allowing the delegation of a notication to a user who is not an employee.
    -- Or we shouldn't question user who is not an employee
    IF ( l_action IN ( 'DELEGATE' , 'QUESTION' ) ) THEN

      IF ( l_origsys <> 'PER' ) THEN

        fnd_message.set_name('POS', 'POS_INVALID_USER_FOR_REASSIGN');
        app_exception.raise_exception;

      END IF;

    END IF;

    IF l_new_recipient_id IS NOT NULL THEN

      l_current_approver_id := wf_engine.GetItemAttrText ( itemtype => itemtype, itemkey => itemkey, aname => 'APPROVER_EMPID');
      l_groupid := wf_engine.GetItemAttrText ( itemtype => itemtype, itemkey => itemkey, aname => 'APPROVAL_GROUP_ID');

      SELECT Decode (l_action, 'DELEGATE', pos_vendor_reg_pkg.ACTN_FORWARD,
                               'QUESTION', pos_vendor_reg_pkg.ACTN_REQUEST_MORE_INFO,
                               'ANSWER',   pos_vendor_reg_pkg.ACTN_ANSWER,
                               'TIMEOUT',  pos_vendor_reg_pkg.ACTN_NO_ACTION)
      INTO l_user_action
      FROM DUAL;

      l_progress := l_api_name|| ' : update pos_action_history -  l_new_recipient_id '||
					l_new_recipient_id || ' l_suppid - ' || l_suppid ||
					' l_current_approver_id - ' || l_current_approver_id ||
					' l_groupid -  ' || l_groupid || 'l_user_action--' || l_user_action;
      IF g_fnd_debug = yesChar THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
        END IF;
      END IF;

      --Update pos_action_history NULL record against current approver/l_current_recipient_id with l_action.
      pos_vendor_reg_pkg.update_reg_action_hist( p_supp_reg_id =>  l_suppid,
                                                 p_action   =>  l_user_action,
                                                 p_note     =>  wf_engine.context_user_comment,
                                                 p_from_user_id => l_current_approver_id,
                                                 p_to_user_id => l_new_recipient_id
                                               );

      --Insert null action record into pos_action_history for l_new_recipient_id
      pos_vendor_reg_pkg.insert_reg_action_hist( p_supp_reg_id => l_suppid,
                                                 p_action      => pos_vendor_reg_pkg.ACTN_PENDING,
                                                 p_from_user_id => l_new_recipient_id,
                                                 p_to_user_id => NULL,
                                                 p_note        => NULL,
                                                 p_approval_group_id => l_groupid
                                               );

      wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => itemkey, aname => 'APPROVER_EMPID', avalue => l_new_recipient_id );

      SELECT user_name INTO l_approver_user_name
      FROM FND_USER
      WHERE employee_id = l_new_recipient_id;

      wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => itemkey, aname => 'CURRENT_APPROVER_USER_NAME', avalue => l_approver_user_name );

    END IF;

  END IF;

  IF (funcmode = 'RESPOND') THEN

    l_nid    := WF_ENGINE.context_nid;
    l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

    l_progress := l_api_name || ' : l_nid ' || l_nid || 'l_result : ' || l_result;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

    --Begin Bug 17446656 -- set user context
    --Begin BUG 18721144 -- SET RESPONSIBILITY CONTEXT
    IF (wf_engine.preserved_context = TRUE) THEN
      l_preserved_ctx              := 'TRUE';
    ELSE
      l_preserved_ctx := 'FALSE';
    END IF;
    l_approver_user_name := wf_engine.GetItemAttrText ( itemtype => itemtype, itemkey => itemkey, aname => 'CURRENT_APPROVER_USER_NAME');
    SELECT user_id
    INTO l_responder_id
    FROM FND_USER
    WHERE user_name =  l_approver_user_name;
    l_progress                            := l_api_name|| ' : l_approver_user_name:  '|| l_approver_user_name || ' l_responder_id:' || l_responder_id || ' l_preserved_ctx: ' || l_preserved_ctx;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;
    -- <debug end>
    l_session_user_id := fnd_global.user_id;
    l_session_resp_id := fnd_global.resp_id;
    l_session_appl_id := fnd_global.resp_appl_id;
    l_progress := l_api_name|| ' : l_session_user_id:  '|| l_session_user_id || ' : l_session_resp_id:  '|| l_session_resp_id || ' : l_session_appl_id:  '|| l_session_appl_id;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;
    IF (l_session_user_id = -1) THEN
      l_session_user_id := NULL;
    END IF;
    IF (l_session_resp_id = -1) THEN
      l_session_resp_id := NULL;
    END IF;
    IF (l_session_appl_id = -1) THEN
      l_session_appl_id := NULL;
    END IF;
    /*
    l_preparer_resp_id := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => wfItemType,
                                                      itemkey  => p_itemkey,
                                                      aname   => 'RESPONSIBILITY_ID');
    l_preparer_appl_id := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => wfItemType,
                                                      itemkey  => p_itemkey,
                                                      aname   => 'APPLICATION_ID');
    l_org_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => wfItemType,
                                             itemkey  => p_itemkey,
                                             aname    => 'ORG_ID');
    l_progress := l_api_name|| ' : l_preparer_resp_id:  '|| l_preparer_resp_id || ' : l_preparer_appl_id:  '|| l_preparer_appl_id || ' : l_org_id:  '|| l_org_id;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;
    */
    if (l_responder_id is not null) then
      if (l_responder_id <> l_session_user_id) then
        /* possible in 2 scenarios :
           1. when the response is made from email
           2. When the response is made from sysadmin login
           In this case capture the session user with preparer resp and appl id
        */
        l_progress := l_api_name|| 'When the response is made from email or sysadmin';
        IF g_fnd_debug = yesChar THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
          END IF;
        END IF;
        /*
        PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => wfItemType,
                                    itemkey  => p_itemkey,
                                    aname   => 'RESPONDER_USER_ID',
                                    avalue  => l_responder_id);
        PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => wfItemType,
                                    itemkey  => p_itemkey,
                                    aname   => 'RESPONDER_RESP_ID',
                                    avalue  => l_preparer_resp_id);
        PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => wfItemType,
                                    itemkey  => p_itemkey,
                                    aname   => 'RESPONDER_APPL_ID',
                                    avalue  => l_preparer_appl_id);
        */
      else
        l_progress := l_api_name|| 'When the response is made from actual user login';
        IF g_fnd_debug = yesChar THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
          END IF;
        END IF;
        if (l_session_resp_id is null) THEN
	        /* possible when the response is made from the default worklist
	           without choosing a valid responsibility.
             In this case also capture the session user with preparer resp and appl id
          */
          l_progress := l_api_name|| 'When the response is made from the default worklist or email';
          IF g_fnd_debug = yesChar THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
            END IF;
          END IF;
          /*
          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => wfItemType,
                                      itemkey  => p_itemkey,
                                      aname   => 'RESPONDER_USER_ID',
                                      avalue  => l_responder_id);
          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => wfItemType,
                                      itemkey  => p_itemkey,
                                      aname   => 'RESPONDER_RESP_ID',
                                      avalue  => l_preparer_resp_id);
          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => wfItemType,
                                      itemkey  => p_itemkey,
                                      aname   => 'RESPONDER_APPL_ID',
                                      avalue  => l_preparer_appl_id);
          */
        else
          /* All values available - possible when the response is made after choosing a correct responsibility */
          /* If the values of responsibility_id and application
	           id are available but are incorrect. This may happen when a response is made
	           through the email or the background process picks the wf up.
	           This may happen due to the fact that the mailer / background process
	           carries the context set by the notification /wf it processed last */
          l_progress := l_api_name|| 'When the response is made after choosing a correct responsibility';
          IF g_fnd_debug = yesChar THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
            END IF;
          END IF;
          /*
          if ( l_preserved_ctx = 'TRUE') then
            PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => wfItemType,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_USER_ID',
                                        avalue  => l_responder_id);
            PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => wfItemType,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_RESP_ID',
                                        avalue  => l_session_resp_id);
            PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => wfItemType,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_APPL_ID',
                                        avalue  => l_session_appl_id);
          else
            PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => wfItemType,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_USER_ID',
                                        avalue  => l_responder_id);
            PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => wfItemType,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_RESP_ID',
                                        avalue  => l_preparer_resp_id);
            PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => wfItemType,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_APPL_ID',
                                        avalue  => l_preparer_appl_id);
          end if;
          */
        end if;
      end if;
    end if;
    -- Runs under actual notification user id
    /*l_user_id_to_set := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype  => wfItemType,
                                                       itemkey  => p_itemkey,
                                                       aname  => 'RESPONDER_USER_ID');
    l_resp_id_to_set := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype  => wfItemType,
                                                       itemkey  => p_itemkey,
                                                       aname  => 'RESPONDER_RESP_ID');
    l_appl_id_to_set := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype  => wfItemType,
                                                       itemkey  => p_itemkey,
                                                       aname  => 'RESPONDER_APPL_ID');
    */
    -- Currenlty I have set the reponsibility id to null as I feel this is actually not needed.
    -- In future if we face any context issues, we will think of passing reponsibility id
    l_resp_id_to_set := l_session_resp_id;
    -- If responsibility id is null, then randomly choose responsibility available for user which has the function POS_SM_REG_APPROVE_REJECT
    if(l_resp_id_to_set is null) then
      GET_RESP_ID(l_responder_id, 'POS_SM_REG_APPROVE_REJECT', ameApplicationId, l_resp_id_to_set, l_resp_key , l_x_result);
    end if;

    l_appl_id_to_set := l_session_appl_id;
    if(l_appl_id_to_set is null) then
      l_appl_id_to_set := ameApplicationId;
    end if;
    fnd_global.apps_initialize(l_responder_id, l_resp_id_to_set, l_appl_id_to_set);
    -- l_progress := l_api_name|| 'after set user context, current user id is: ' || fnd_global.user_id;
    l_progress := l_api_name|| 'l_responder_id: ' || l_responder_id || 'l_resp_id_to_set: ' || l_resp_id_to_set || 'l_appl_id_to_set: ' || l_appl_id_to_set;
    IF g_fnd_debug = yesChar THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
        END IF;
    END IF;

    /*
    -- To support back compatibility for supplier requests created before this fix for setting responsibility context: Bug 18721144
    IF(l_user_id_to_set IS NULL) THEN
      l_user_id_to_set := l_responder_id;
    END IF;
    IF(l_appl_id_to_set IS NULL) THEN
      l_appl_id_to_set := ameApplicationId;
    END IF;
    -- End : To support back compatibility
    -- Comment below apps initialization/context setting code if selector procedure POS_SUPP_REG_WF_SELECTOR is set for WF item type POSSPAPM
    -- WF_SELECTOR = "POS_SUPP_APPR.POS_SUPP_REG_WF_SELECTOR"
    -- Begin context setting
    --fnd_global.apps_initialize(l_user_id_to_set, l_resp_id_to_set, l_appl_id_to_set);
    -- obvious place to make such a call, since we are using an apps_initialize,
    -- this is required since the responsibility might have a different OU attached
    -- than what is required.
    IF l_org_id is NOT NULL THEN
      PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;
      --MO_GLOBAL.set_org_context('S',l_org_id) ;
    END IF;
    */
    l_progress := l_api_name|| 'fnd_global.apps_initialize, current user id is: ' || fnd_global.user_id;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      end if;
    end if;
    -- End context setting
    -- End BUG 18721144 -- SET RESPONSIBILITY CONTEXT
    -- End Bug 17446656
  /*  IF(l_result = ame_util.approvedStatus) THEN

        VALIDATE_DATA (l_suppid, l_error_mesg);
        IF( l_error_mesg IS NOT NULL) THEN

            fnd_message.set_name('POS', 'POS_SUPPREG_ERRORS');
            fnd_message.set_token('ERROR_TEXT', l_error_mesg);
            app_exception.raise_exception;

        END IF;

    END IF;
  */

    IF(l_result IN  ( ame_util.forwardStatus , ame_util.approveAndForwardStatus ) ) THEN

      l_forwardTo := wf_notification.GetAttrText(l_nid, 'FORWARD_TO_USERNAME_RESPONSE');

      -- It means approver has clicked on FORWARD/approveAndForward but not specified whom to forward
      IF(l_forwardTo IS NULL) THEN

        fnd_message.set_name('POS', 'POS_WF_NOTIF_NO_USER');
        app_exception.raise_exception;

      END IF;

      SELECT employee_id
        INTO l_fwd_approver_id
      FROM fnd_user
      WHERE user_name = l_forwardTo
        AND TRUNC (sysdate) BETWEEN start_date AND NVL (end_date ,sysdate + 1);

      -- Check if forwardee is employee type
      IF (l_fwd_approver_id IS NULL) THEN

        fnd_message.set_name('POS', 'POS_INVALID_USER_FOR_REASSIGN');
        app_exception.raise_exception;

      END IF;

      wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => itemkey, aname => 'FORWARD_TO_EMPID', avalue => l_fwd_approver_id );

    END IF;

    resultout := wf_engine.eng_completed || ':' || l_result;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RAISE;
END POST_APPROVAL_NOTIF;

-- Validate mandatory fields/ UDA attributes before approver take APPROVE action

PROCEDURE VALIDATE_MANDATORY_ATTR(
    itemtype IN VARCHAR2,
    itemkey  IN VARCHAR2,
    actid    IN NUMBER,
    funcmode IN VARCHAR2,
    resultout OUT NOCOPY VARCHAR2)

IS

  l_suppid pos_supplier_registrations.supplier_reg_id%TYPE;
  p_itemkey wf_items.parent_item_key%TYPE;
  l_error_mesg VARCHAR2(32000) := NULL;
  l_api_name     VARCHAR2(50)  := 'VALIDATE_MANDATORY_ATTR';
  l_progress     VARCHAR2(4000) := '000';
  l_suppName     VARCHAR2(50);
  l_url varchar2(4000);


BEGIN

  SELECT parent_item_key
    INTO p_itemkey
  FROM wf_items
  WHERE item_type = itemtype
    AND item_key  = itemkey;

  l_suppid  := wf_engine.GetItemAttrText(itemtype => wfitemtype, itemkey => p_itemkey, aname => 'SUPP_REG_ID');

  l_progress := l_api_name || ' : p_itemkey - '||p_itemkey||' l_suppid : '|| l_suppid;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  VALIDATE_DATA ( l_suppid, l_error_mesg );

  IF ( l_error_mesg IS NULL) THEN

    resultout := wf_engine.eng_completed || ':' || 'SUCCESS';

  ELSE

    l_suppName := wf_engine.GetItemAttrText(itemtype => wfitemtype, itemkey => p_itemkey, aname => 'SUPPLIERNAME');

    wf_engine.SetItemAttrText (itemtype => itemtype, itemkey => itemkey, aname => 'ERROR_TEXT', avalue => l_error_mesg);
    wf_engine.SetItemAttrText (itemtype => itemtype, itemkey => itemkey, aname => 'POS_ERROR_MESG_SUB', avalue => GET_BUYER_ERR_NOTIF_SUBJECT(l_suppName));
    GET_REG_REQ_EDIT_URL(l_suppid, l_url);
    wf_engine.SetItemAttrText (itemtype => itemtype, itemkey => itemkey, aname => 'URL', avalue => l_url);
    wf_engine.SetItemAttrText (itemtype => itemtype, itemkey => itemkey, aname => 'ERROR_DOC', avalue => 'PLSQLCLOB:POS_SUPP_APPR.GET_ERROR_DOC/' || itemkey);
    resultout := wf_engine.eng_completed || ':' || 'FAILURE';

  END IF;

  l_progress := l_api_name|| ' : completed successfully ' ;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RAISE;
END VALIDATE_MANDATORY_ATTR;

-- Validate mandatory fields/ UDA attributes before approver take APPROVE action

PROCEDURE VALIDATE_DATA(
    p_suppid IN VARCHAR2,
    p_error_mesg IN OUT NOCOPY VARCHAR2)

IS

  l_supplier_number pos_supplier_registrations.supplier_number%TYPE;
  x_attr_req_tbl EGO_VARCHAR_TBL_TYPE;
  x_return_status VARCHAR2(10);
  x_msg_count     NUMBER;
  x_msg_data      VARCHAR2(4000);
  l_supplier_number_err VARCHAR2(4000) := NULL;
  l_uda_attr_err VARCHAR2(32767) := NULL;
  l_index NUMBER;
  l_api_name     VARCHAR2(50)  := 'VALIDATE_DATA';
  l_progress     VARCHAR2(4000) := '000';
  l_suppNumRule VARCHAR2(20) := NULL;

BEGIN

  l_progress := l_api_name || ' :  p_suppid : '|| p_suppid;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  SELECT SUPPLIER_NUMBERING_METHOD INTO l_suppNumRule from ap_product_setup;

  IF ( l_suppNumRule = 'MANUAL' ) THEN

    SELECT supplier_number
      INTO l_supplier_number
    FROM pos_supplier_registrations
    WHERE supplier_reg_id  = p_suppid;

    IF ( l_supplier_number IS NULL ) THEN
      l_progress := l_api_name || ' :  supplier number is NULL ' ;
      l_supplier_number_err  := '<li>' || fnd_message.get_string('POS','POS_SUPPREG_MAN_SUPP_NUM_TIP') || '</li>';
    END IF;

  END IF;

  IF (FND_PROFILE.VALUE('POS_SM_ENABLE_SPM_EXTENSION') = 'Y') THEN
  l_progress := l_api_name|| ' : calling API POS_VENDOR_REG_PKG.validate_required_user_attrs ';
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  POS_VENDOR_REG_PKG.validate_required_user_attrs(p_suppid, yesChar, x_attr_req_tbl, x_return_status, x_msg_count, x_msg_data);

  l_progress := l_api_name|| ' : completed API POS_VENDOR_REG_PKG.validate_required_user_attrs: x_return_status - ' || x_return_status
                || 'x_msg_count : ' || x_msg_count  || 'x_msg_data :' || x_msg_data;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  IF ( x_return_status <> 'S' ) THEN

    l_uda_attr_err := '<li>' || x_msg_data || '</li>';

  ELSE

     IF ( x_attr_req_tbl IS NOT NULL AND x_attr_req_tbl.Count > 0 ) THEN

         l_progress := l_api_name || ' : there are some mandatory UDA attributes to fill in :' ;
         IF g_fnd_debug = yesChar THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
            END IF;
         END IF;

         l_uda_attr_err := l_uda_attr_err || '<br>' || fnd_message.get_string('POS','POS_SM_REQ_USER_ATTRS_WARN') || '<br>';
         l_index := x_attr_req_tbl.first;

         WHILE ( l_index < x_attr_req_tbl.Count ) LOOP

              l_uda_attr_err := l_uda_attr_err || '<li>';
              l_uda_attr_err := l_uda_attr_err || x_attr_req_tbl(l_index);        -- page
              l_uda_attr_err := l_uda_attr_err || ': ';
              l_uda_attr_err := l_uda_attr_err || x_attr_req_tbl(l_index + 1);    -- attribute group
              l_uda_attr_err := l_uda_attr_err || ': ';
              l_uda_attr_err := l_uda_attr_err || x_attr_req_tbl(l_index + 2);    -- attribute
              l_uda_attr_err := l_uda_attr_err || '</li>';

              l_index := x_attr_req_tbl.next (l_index) + 2;

         END LOOP;

     END IF;

  END IF;

  END IF;
  p_error_mesg :=  l_supplier_number_err || l_uda_attr_err;

  IF (p_error_mesg IS NOT NULL) THEN

    l_progress := l_api_name|| ' : there are some errors found in validation ';
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

  END IF;

  l_progress := l_api_name|| ' : completed successfully :' ;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RAISE;
END VALIDATE_DATA;

-- Check if registration request fresh submision or is it resubmission due to return to supplier action
PROCEDURE CHECK_IF_RESUBMIT
  (
    itemtype IN VARCHAR2,
    itemkey  IN VARCHAR2,
    actid    IN NUMBER,
    funcmode IN VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
  )

IS

  suppid pos_supplier_registrations.supplier_reg_id%TYPE;
  cnt NUMBER;
  l_approver_list ame_util.approversTable2;
  l_process_out      VARCHAR2(1);
  l_member_order_num NUMBER;
  l_approver_index   NUMBER;
  l_api_name     VARCHAR2(50)  := 'CHECK_IF_RESUBMIT';
  l_progress     VARCHAR2(4000) := '000';
  l_actionCode   pos_action_history.action_code%TYPE;
  l_groupIds Dbms_Sql.Number_Table;
  l_orderIds Dbms_Sql.Number_Table;


BEGIN

  suppid := wf_engine.GetItemAttrText(itemtype => wfitemtype, itemkey => itemkey, aname => 'SUPP_REG_ID');

  SELECT COUNT(1)
    INTO cnt
  FROM wf_items
  WHERE item_key LIKE suppid || '%'
    AND ROOT_ACTIVITY = wfProcess;

  l_progress := l_api_name || ' : suppid - '||suppid ||' is submission count is '|| cnt ;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  IF ( cnt > 1 ) THEN
    resultout := noChar; -- default to NO
    RESUBMIT_FOR_REJECT_OR_RETURN(suppid, l_actionCode);
    IF  (l_actionCode = pos_vendor_reg_pkg.ACTN_REJECT) THEN  -- resubmission after request was rejected
      resultout := noChar;
      l_progress := l_api_name || ' : resubmission after request was rejected' ;
      IF g_fnd_debug = yesChar THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
        END IF;
      END IF;
      -- Earlier we didnt concept of dynamic approver(allow buyer/current approver to add new adhoc approver for approval).
      -- So we were clearning all approvals when rejected request is getting resubmitted.
      -- Now we have dynamic approver concept and we should nt do this clearning at this point as there could be a case that buyer
      -- wants to add few more approvers to request before submitting the reopened request. Hence commented below code.
      -- Moved this clearing code to POS_VENDOR_REG_PKG.reopen_supplier_reg;
      --ame_api2.clearAllApprovals( applicationIdIn=>ameApplicationId, transactionTypeIn=>ameTransactionType, transactionIdIn=>suppid);
    ELSIF ( l_actionCode = pos_vendor_reg_pkg.ACTN_RETURN_TO_SUPP ) THEN -- resubmission after request was return back to supplier
    -- check profile if approval should start from first approver again
    IF ( 1 = 2 ) THEN  -- replace with propfile condition once corresponding profile is created

      resultout := noChar;

      l_progress := l_api_name || ' : profile is set to start from first approver again for approval' ;
      IF g_fnd_debug = yesChar THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
        END IF;
      END IF;

      ame_api2.clearAllApprovals( applicationIdIn=>ameApplicationId, transactionTypeIn=>ameTransactionType, transactionIdIn=>suppid);

    ELSE

      l_progress := l_api_name ||' : profile is set to continue approval process from where it was stuck before returning to supplier' ;
      IF g_fnd_debug = yesChar THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
        END IF;
      END IF;

      get_all_approvers(suppid, l_approver_list, l_process_out);
      l_approver_index  := l_approver_list.first;

      --get_current_appr_group_details(suppid, l_groupIds, l_orderIds);
      WHILE (l_approver_index IS NOT NULL)  LOOP

        --FOR j IN l_groupIds.first..l_groupIds.last LOOP
          --IF ( l_groupIds(j) = l_approver_list(l_approver_index).group_or_chain_id
            --  AND  l_orderIds(j) = l_approver_list(l_approver_index).member_order_number ) THEN
        IF ( l_approver_list(l_approver_index).approval_status = ame_util.notifiedStatus ) THEN

          l_progress := l_api_name || ' : re-notify approver :' || l_approver_list(l_approver_index).name || 'for approval' ;
          IF g_fnd_debug = yesChar THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
            END IF;
          END IF;

          g_next_approvers(l_approver_index) := l_approver_list(l_approver_index);
          resultout := yesChar;

        END IF;
        --END LOOP;

        l_approver_index := l_approver_list.next (l_approver_index);

      END LOOP;
      /*-- Call getNextApprovers to get approvers if any new adhoc approver being added by buyer during resubmit after return to supplier action
      ame_api2.getNextApprovers4( applicationIdIn   =>ameApplicationId,
                                transactionIdIn   =>suppid,
                                transactionTypeIn =>ameTransactionType,
                                approvalProcessCompleteYNOut=>l_process_out,
                                nextApproversOut  =>l_approver_list );
      l_approver_index  := l_approver_list.first;
      WHILE (l_approver_index IS NOT NULL)  LOOP
        l_progress := l_api_name || ' : notify approver :' || l_approver_list(l_approver_index).name || 'for approval' ;
        IF g_fnd_debug = yesChar THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
          END IF;
        END IF;
        g_next_approvers(g_next_approvers.Count + 1) := l_approver_list(l_approver_index);
        resultout := yesChar;
        l_approver_index := l_approver_list.next (l_approver_index);
      END LOOP;*/
      END IF;

    END IF;

  ELSE

    resultout := noChar;

  END IF;

  l_progress := l_api_name || ' : final result  :' || resultout ;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RAISE;
END CHECK_IF_RESUBMIT;

-- Get WF top process item key which is active
FUNCTION GET_WF_TOP_PROCESS_ITEM_KEY
  (
    suppid IN VARCHAR2
  )
  RETURN VARCHAR2

IS

  p_itemkey wf_items.parent_item_key%TYPE;
  l_api_name     VARCHAR2(50)  := 'GET_WF_TOP_PROCESS_ITEM_KEY';
  l_progress     VARCHAR2(4000) := '000';

BEGIN

  l_progress := l_api_name || '  input: suppid - '|| suppid ;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;

  BEGIN

    SELECT item_key
      INTO p_itemkey
    FROM
      (SELECT item_key,
        wf_fwkmon.getitemstatus(ITEM_TYPE, ITEM_KEY, END_DATE, ROOT_ACTIVITY, ROOT_ACTIVITY_VERSION) AS STATUS_CODE
      FROM wf_items
      WHERE item_key LIKE suppid  || '%'
        AND ROOT_ACTIVITY = wfProcess
      )
    WHERE status_code = 'ACTIVE';

    EXCEPTION WHEN NO_DATA_FOUND THEN
    -- This failed when trying to find approval history for completed registration,
    -- hence approval sequence diagram is not shown. Hence we order by begin date desc and get latest wf top process key
      SELECT item_key
        INTO p_itemkey
      FROM
        (SELECT item_key
        FROM wf_items
        WHERE item_key LIKE suppid  || '%'
          AND ROOT_ACTIVITY = wfProcess
        ORDER BY BEGIN_DATE  DESC
        )
      WHERE ROWNUM = 1;
    END;

    l_progress := l_api_name || ' workflow item key is  - '|| p_itemkey ;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
  END IF;

  RETURN p_itemkey;

EXCEPTION
WHEN OTHERS THEN
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RAISE;
END GET_WF_TOP_PROCESS_ITEM_KEY;

PROCEDURE GET_ERROR_DOC
  (
    document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	NOCOPY CLOB,
    document_type	in out	NOCOPY varchar2
  )

IS

  l_item_key     wf_items.item_key%TYPE;
  l_document      VARCHAR2(32000) := '';
  l_disp_type          VARCHAR2(20) := 'text/plain';
  NL              VARCHAR2(1) := fnd_global.newline;

BEGIN

  l_item_key := substr(document_id, instr(document_id, '/') + 1, length(document_id));

  IF display_type = 'text/html' THEN
    l_disp_type:= display_type;
    fnd_message.set_name('POS','POS_SUPP_ERR_NOTIF_HTML_BODY');
    fnd_message.set_token('ERROR_TEXT',wf_engine.GetItemAttrText ( itemtype => wfItemType, itemkey => l_item_key, aname => 'ERROR_TEXT'));
    fnd_message.set_token('URL',wf_engine.GetItemAttrText ( itemtype => wfItemType, itemkey => l_item_key, aname => 'URL'));
    l_document :=   l_document || NL || NL || fnd_message.get;
   	WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
    l_disp_type:= display_type;
    fnd_message.set_name('POS','POS_SUPP_ERR_NOTIF_TEXT_BODY');
    fnd_message.set_token('ERROR_TEXT',wf_engine.GetItemAttrText ( itemtype => wfItemType, itemkey => l_item_key, aname => 'ERROR_TEXT'));
    fnd_message.set_token('URL',wf_engine.GetItemAttrText ( itemtype => wfItemType, itemkey => l_item_key, aname => 'URL'));
    l_document :=   l_document || NL || NL || fnd_message.get;
   	WF_NOTIFICATION.WriteToClob(document, l_document);

  END IF;

END GET_ERROR_DOC;

PROCEDURE GET_REG_REQ_EDIT_URL
  (
    p_regId  IN VARCHAR2,
    p_url IN OUT NOCOPY VARCHAR2
  )
IS

  l_url VARCHAR2(4000);
  l_regKey pos_supplier_registrations.reg_key%TYPE;

BEGIN

    l_url := pos_url_pkg.get_dest_page_url('POS_FLEXREG_APPROVER', 'BUYER');

    SELECT reg_key
        INTO l_regKey
    FROM pos_supplier_registrations
    WHERE SUPPLIER_REG_ID = p_regId;

    p_url := l_url ||
            '&regkey=' || l_regKey ||
            '&submitFunc=WF_WORKLIST&cancelFunc=FND_WFNTF_DETAILS' ||
            '&retainAM=Y&addBreadCrumb=Y';

END GET_REG_REQ_EDIT_URL;

FUNCTION GET_BUYER_ACTN_NOTIF_SUBJECT(p_supp_name IN VARCHAR2)
RETURN VARCHAR2  IS
l_document VARCHAR2(32000);

BEGIN
    fnd_message.set_name('POS','POS_BUYER_ACTN_NOTIF_SUBJECT');
    fnd_message.set_token('SUPPLIERNAME', p_supp_name);
    l_document :=  fnd_message.get;
    RETURN l_document;
END GET_BUYER_ACTN_NOTIF_SUBJECT;

FUNCTION GET_BUYER_FYI_NOTIF_SUBJECT(p_supp_name IN VARCHAR2)
RETURN VARCHAR2  IS
l_document VARCHAR2(32000);

BEGIN
    fnd_message.set_name('POS','POS_BUYER_FYI_NOTIF_SUBJECT');
    fnd_message.set_token('SUPPLIERNAME', p_supp_name);
    l_document :=  fnd_message.get;
    RETURN l_document;
END GET_BUYER_FYI_NOTIF_SUBJECT;

FUNCTION GET_BUYER_ERR_NOTIF_SUBJECT(p_supp_name IN VARCHAR2)
RETURN VARCHAR2  IS
l_document VARCHAR2(32000);

BEGIN
    fnd_message.set_name('POS','POS_SUPP_ERR_NOTIF_SUBJECT');
    fnd_message.set_token('SUPPLIERNAME', p_supp_name);
    l_document :=  fnd_message.get;
    RETURN l_document;
END GET_BUYER_ERR_NOTIF_SUBJECT;

PROCEDURE IS_REOPENED_REQUEST
(
suppid IN VARCHAR2,
result IN OUT NOCOPY VARCHAR2
)
IS

last_actn_seq_num NUMBER;
last_reject_seq_num NUMBER;
last_submit_seq_num NUMBER;
l_api_name     VARCHAR2(50)  := 'IS_REOPENED_REQUEST';
l_progress     VARCHAR2(4000) := '000';
BEGIN
  result := noChar;

  SELECT Max(sequence_num) INTO last_actn_seq_num FROM pos_action_history WHERE object_id = suppid;
  SELECT Max(sequence_num) INTO last_reject_seq_num FROM pos_action_history WHERE object_id = suppid AND ACTION_CODE = pos_vendor_reg_pkg.ACTN_REJECT;

  IF (last_reject_seq_num IS NOT NULL) THEN

    BEGIN

      SELECT Max(sequence_num) INTO last_submit_seq_num FROM pos_action_history WHERE object_id = suppid AND ACTION_CODE = pos_vendor_reg_pkg.ACTN_SUBMIT AND sequence_num > last_reject_seq_num;

    EXCEPTION
      WHEN OTHERS THEN
      last_submit_seq_num := NULL;

    END;

    l_progress := l_api_name || ' : last_actn_seq_num  :' || last_actn_seq_num ||
                                ' : last_reject_seq_num :' || last_reject_seq_num ||
                                ' : last_submit_seq_num :' || last_submit_seq_num;

    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

    -- To say request is reopened(after REJECT, before SUBMIT):
    -- 1. There should be REJECT action
    -- 2. There shouldnt be any SUBMIT action after REJECT
    -- 3. Last Action shouldn't be REJECT
    IF ( last_reject_seq_num IS NOT NULL AND last_submit_seq_num IS NULL AND last_actn_seq_num > last_reject_seq_num  ) THEN

      result := yesChar;

    END IF;

  END IF;

END IS_REOPENED_REQUEST;

PROCEDURE RESUBMIT_FOR_REJECT_OR_RETURN
(
suppid IN VARCHAR2,
action_code IN OUT NOCOPY VARCHAR2
)
IS

last_actn_seq_num NUMBER;
last_reject_seq_num NUMBER;
last_submit_seq_num NUMBER;
last_b4_submit_seq_num NUMBER;
l_api_name     VARCHAR2(50)  := 'RESUBMIT_FOR_REJECT_OR_RETURN';
l_progress     VARCHAR2(4000) := '000';

BEGIN

  action_code := NULL;

  BEGIN

    SELECT Max(sequence_num) INTO last_actn_seq_num FROM pos_action_history WHERE object_id = suppid;
    SELECT Max(sequence_num) INTO last_submit_seq_num FROM pos_action_history WHERE object_id = suppid AND ACTION_CODE = pos_vendor_reg_pkg.ACTN_SUBMIT;

    BEGIN

      SELECT sequence_num INTO last_b4_submit_seq_num
      FROM (select sequence_num, rownum rnum from
                (select * from pos_action_history WHERE object_id = suppid AND ACTION_CODE = pos_vendor_reg_pkg.ACTN_SUBMIT ORDER BY sequence_num DESC)
            where rownum <= 2 )
      WHERE rnum >= 2;

    EXCEPTION
      WHEN OTHERS THEN
      last_b4_submit_seq_num := NULL;
    END;

    BEGIN

      SELECT Max(sequence_num) INTO last_reject_seq_num FROM pos_action_history WHERE object_id = suppid AND ACTION_CODE = pos_vendor_reg_pkg.ACTN_REJECT;

    EXCEPTION
      WHEN OTHERS THEN
        last_reject_seq_num := NULL;
    END;


    l_progress := l_api_name || ' : last_actn_seq_num  :' || last_actn_seq_num ||
                                ' : last_submit_seq_num :' || last_submit_seq_num ||
                                ' : last_b4_submit_seq_num :' || last_b4_submit_seq_num ||
                                ' : last_reject_seq_num :' || last_reject_seq_num;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;

    -- Request can be resubmitted for either REJECT or RETURN actions:
    -- 1. If there is REJECT action 2 consecutive last SUBMIT actions, then we say this submision is meant for REJECT action
    -- 2. ELSE we call it for RETURN action

    IF ( last_actn_seq_num = last_submit_seq_num ) THEN

      IF ( last_reject_seq_num IS NOT NULL AND last_reject_seq_num > last_b4_submit_seq_num AND last_reject_seq_num < last_submit_seq_num) THEN

          action_code := pos_vendor_reg_pkg.ACTN_REJECT;

      ELSE

          action_code := pos_vendor_reg_pkg.ACTN_RETURN_TO_SUPP;

      END IF;

    END IF;

  EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  action_code := NULL;
  END;

END RESUBMIT_FOR_REJECT_OR_RETURN;

PROCEDURE send_fyi_notification
(
  ameTrxId  IN VARCHAR2
)
IS
l_approver_list ame_util.approversTable2;
l_process_out     VARCHAR2(1);
l_notification_id NUMBER;
l_wfitemkey       VARCHAR2(1000);
l_suppliername    pos_supplier_registrations.supplier_name%TYPE;
l_regKey pos_supplier_registrations.reg_key%TYPE;
l_next_approver_id NUMBER;
l_next_approver_name per_employees_current_x.full_name%TYPE;
l_progress    VARCHAR2(4000) DEFAULT '000';
l_api_name       VARCHAR2(500) := 'send_fyi_notification';
BEGIN
    get_all_approvers(ameTrxId, l_approver_list, l_process_out);
    l_wfitemkey := GET_WF_TOP_PROCESS_ITEM_KEY(ameTrxId);
    l_suppliername := wf_engine.GetItemAttrText ( itemtype => wfItemType, itemkey => l_wfitemkey, aname => 'SUPPLIERNAME');
    l_regKey := wf_engine.GetItemAttrText ( itemtype => wfItemType, itemkey => l_wfitemkey, aname => 'REG_KEY');
    l_progress := l_api_name || ' : l_wfitemkey  :' || l_wfitemkey ||
                                ' : l_suppliername :' || l_suppliername ||
                                ' : l_regKey :' || l_regKey ;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;
    FOR i IN 1.. l_approver_list.Count LOOP
      -- send fyi notification only to future FYI approval group
      IF ( l_approver_list(i).approver_category = 'F' AND l_approver_list(i).approval_status IS NULL) THEN
        l_progress := l_api_name || ' : sending FYI notification to   :' || l_approver_list(i).name  ;
        IF g_fnd_debug = yesChar THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
          END IF;
        END IF;
        l_notification_id := wf_notification.send(role => l_approver_list(i).name,
                                                  msg_type => wfItemType,
                                                  msg_name => 'FYI_SUPPLIER_PROPOSAL');
        -- Message subject
        wf_notification.Setattrtext(nid => l_notification_id,
                                      aname =>'POS_SUPP_MESSAGE_SUB',
                                      avalue => GET_BUYER_FYI_NOTIF_SUBJECT(l_suppliername));
        -- Message Body
        wf_notification.Setattrtext(nid => l_notification_id,
                                      aname => 'DETAILS_AND_STATUS_FWK_RN',
                                      avalue => 'JSP:/OA_HTML/OA.jsp?OAFunc=POS_REG_DETAILS_STATUS_NTFN&regkey=' || l_regKey );
        wf_notification.Setattrtext(nid => l_notification_id,
                                      aname => '#HISTORY',
                                      avalue => 'JSP:/OA_HTML/OA.jsp?OAFunc=POS_REG_APPR_SEQ_NTFN&regkey=' || l_regKey );
        getNextApprIdBasedOnApprType(l_approver_list (i).orig_system, l_approver_list (i).orig_system_id, l_next_approver_id, l_next_approver_name);
        pos_vendor_reg_pkg.insert_reg_action_hist( p_supp_reg_id => ameTrxId,
                            p_action      => pos_vendor_reg_pkg.ACTN_FYI,
                            p_from_user_id => l_next_approver_id,
                            p_to_user_id => NULL,
                            p_note        => NULL,
                            p_approval_group_id => l_approver_list (i).group_or_chain_id
                            );
        l_progress := l_api_name || ' : Successfully sent FYI notification to employee l_next_approver_id  :' || l_next_approver_id ;
        IF g_fnd_debug = yesChar THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
          END IF;
        END IF;
    END IF;
  END LOOP;
END  send_fyi_notification;

PROCEDURE getNextApprIdBasedOnApprType
(
 p_origSystem IN VARCHAR2,
 p_origSystemId IN NUMBER,
 p_nextApproveId OUT NOCOPY NUMBER,
 l_next_approver_name OUT NOCOPY per_employees_current_x.full_name%TYPE
)
IS
l_progress    VARCHAR2(4000) DEFAULT '000';
l_api_name    VARCHAR2(500) := 'getNextApprIdBasedOnApprType';
BEGIN
  l_progress := l_api_name || ' : p_origSystem   :' || p_origSystem || 'p_origSystemId : ' || p_origSystemId  ;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;
  --Fetch next approver_id from the global list.
  -- If the approver is a PER role then use the same person id.
  -- If the approver is POS role, then find out the first user corresponding to that person.
  -- If it is an FND USER pick the employee_id corresponding to that FND USER
  IF (p_origSystem = ame_util.perorigsystem) THEN
    p_nextApproveId := p_origSystemId;
  ELSIF (p_origSystem = ame_util.posorigsystem) THEN
    BEGIN
      -----------------------------------------------------------------------
      -- SQL What: Get the person assigned to position returned by AME.
      -- SQL Why : When AME returns position id, then using this sql we find
      --           one person assigned to this position and use this person
      --           as approver.
      -----------------------------------------------------------------------
      SELECT person_id ,
        full_name
      INTO p_nextApproveId,
        l_next_approver_name
      FROM
        (SELECT person.person_id ,
          person.full_name
        FROM per_all_people_f person ,
          per_all_assignments_f asg,
          wf_users wu
        WHERE asg.position_id = p_origSystemId
        AND wu.orig_system    = ame_util.perorigsystem
        AND wu.orig_system_id = person.person_id
        AND TRUNC (sysdate) BETWEEN person.effective_start_date AND NVL (person.effective_end_date ,TRUNC (sysdate))
        AND person.person_id                   = asg.person_id
        AND asg.primary_flag                   = yesChar
        AND asg.assignment_type               IN ('E','C')
        AND ( person.current_employee_flag     = yesChar
        OR person.current_npw_flag             = yesChar )
        AND asg.assignment_status_type_id NOT IN
          (SELECT assignment_status_type_id
          FROM per_assignment_status_types
          WHERE per_system_status = 'TERM_ASSIGN'
          )
        AND TRUNC (sysdate) BETWEEN asg.effective_start_date AND asg.effective_end_date
        ORDER BY person.last_name
        )
      WHERE ROWNUM = 1;
    EXCEPTION
    WHEN no_data_found THEN
      RAISE;
    END;
  ELSIF (p_origSystem = ame_util.fnduserorigsystem) THEN
    SELECT employee_id
      INTO p_nextApproveId
    FROM fnd_user
    WHERE user_id = p_origSystemId
      AND TRUNC (sysdate) BETWEEN start_date AND NVL (end_date ,sysdate + 1);
  END IF;
  l_progress := l_api_name || ' : p_nextApproveId   :' || p_nextApproveId || 'l_next_approver_name : ' || l_next_approver_name  ;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;
END getNextApprIdBasedOnApprType;

--  Newely added person(approver / FYI aprpover) will be notified in case if this person is added as part of current approval group
PROCEDURE send_notif_to_new_approver
(
  p_suppId IN VARCHAR2
)
IS
l_progress    VARCHAR2(4000) DEFAULT '000';
l_api_name    VARCHAR2(500) := 'send_notif_to_new_approver';
l_wfItemKey   VARCHAR2(50);
lerrname              VARCHAR2(30);
lerrmsg               VARCHAR2(2000);
lerrstack             VARCHAR2(32000);
BEGIN
  l_wfItemKey := GET_WF_TOP_PROCESS_ITEM_KEY(p_suppId);
  -- Stamp main process approver response as null so that get_next_approver will be called to get these newly added approvers
  -- to send the notifications
  wf_engine.SetItemAttrText ( itemtype => wfItemType, itemkey => l_wfItemKey, aname => 'APPROVER_RESPONSE', avalue => ame_util.nullStatus);
  l_progress := l_api_name || ': Try Complete BLOCK activity for top process -' || l_wfItemKey;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;
  -- When we complete the BLOCK activity, get_next_approver will be fired in the workflow
  BEGIN
    wf_engine.CompleteActivity( itemtype  => wfItemType,
                                itemkey   => l_wfItemKey,
                                activity  => 'BLOCK',
                                result    => NULL);
  EXCEPTION
  WHEN OTHERS THEN
    wf_core.get_error(lerrname,lerrmsg,lerrstack);
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
      END IF;
    END IF;
    IF lerrname = 'WFENG_NOT_NOTIFIED' THEN
      NULL;
    END IF;
  END;
EXCEPTION
WHEN OTHERS THEN
  -- The line below records this function call in the error system
  -- in the case of an exception.
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  raise;
END send_notif_to_new_approver;

--  Get current approver Group Ids and its corresponding order numbers
PROCEDURE get_current_appr_group_details
(
  p_suppId IN VARCHAR2,
  p_groupIds OUT NOCOPY Dbms_Sql.Number_Table,
  p_orderIds OUT NOCOPY Dbms_Sql.Number_Table
)
IS
l_progress    VARCHAR2(4000) DEFAULT '000';
l_api_name    VARCHAR2(500) := 'get_current_approver_group_ids';
l_wfItemKey   VARCHAR2(50);
lerrname              VARCHAR2(30);
lerrmsg               VARCHAR2(2000);
lerrstack             VARCHAR2(32000);
l_approver_list ame_util.approversTable2;
l_process_out     VARCHAR2(1);
l_approver_index   NUMBER;
l_index       NUMBER DEFAULT 1;
l_exists BOOLEAN DEFAULT FALSE;
l_group_index NUMBER;
BEGIN
  get_all_approvers(p_suppId, l_approver_list, l_process_out);
  l_approver_index  := l_approver_list.first;
  WHILE (l_approver_index IS NOT NULL)  LOOP
    IF ( l_approver_list(l_approver_index).approval_status = ame_util.notifiedStatus ) THEN
      l_exists := FALSE;
      l_group_index := p_groupIds.first;
      WHILE ( l_group_index IS NOT NULL ) LOOP
        IF (p_groupIds(l_group_index) = l_approver_list(l_approver_index).group_or_chain_id) THEN
          l_exists := TRUE;
        END IF;
        l_group_index := p_groupids.NEXT(l_group_index);
      END LOOP;
      IF(NOT l_exists) THEN
        p_groupIds(l_index) := l_approver_list(l_approver_index).group_or_chain_id;
        -- Though always will have same order number if groups are in parallel, just captured in Array
        p_orderIds(l_index) := l_approver_list(l_approver_index).member_order_number;
        l_index := l_index + 1;
      END IF;
    END IF;
    l_approver_index := l_approver_list.next (l_approver_index);
  END LOOP;
  l_progress := l_api_name || ' : list of current approver groups ids are :' ;
  FOR i IN 1 .. p_groupIds.COUNT LOOP
    l_progress := l_progress || ' AG Id : ' || p_groupIds (i) || ' Order Number : ' || p_orderIds(i);
  END LOOP;
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  -- The line below records this function call in the error system
  -- in the case of an exception.
  IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Unexpected Error l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  raise;
END get_current_appr_group_details;
/* Bug 18721144.
Added the procedure POS_SUPP_REG_WF_SELECTOR to set the user context properly before
launching the concurrent request */
-------------------------------------------------------------------------------
-- Start of Comments
-- Name: POS_SUPP_REG_WF_SELECTOR
-- Pre-reqs: None.
-- Modifies:
--   Application user id
--   Application responsibility id
--   Application application id
-- Locks: None.
-- Function:
--   This procedure sets the correct application context when a process is
--   picked up by the workflow background engine. When called in
--   TEST_CTX mode it compares workflow attribute org id with the current
--   org id and workflow attributes user id, responsibility id and
--   application id with their corresponding profile values. It returns TRUE
--   if these values match and FALSE otherwise. When called in SET_CTX mode
--   it sets the correct apps context based on workflow parameters.
-- Parameters:
-- IN:
--   p_itemtype
--     Specifies the itemtype of the workflow process
--   p_itemkey
--     Specifies the itemkey of the workflow process
--   p_actid
--     activity id passed by the workflow
--   p_funcmode
--     Input values can be TEST_CTX or SET_CTX (RUN not implemented)
--     TEST_CTX to test if current context is correct
--     SET_CTX to set the correct context if current context is wrong
-- IN OUT:
--   p_x_result
--     For TEST_CTX a TRUE value means that the context is correct and
--     SET_CTX need not be called. A FALSE value means that current context
--     is incorrect and SET_CTX need to set correct context
-- Testing:
--   There is not script to test this procedure but the correct functioning
--   may be tested by verifying from the debug_message in table po_wf_debug
--   that if at any time the workflow process gets started with a wrong
--   context then the selector is called in TEST_CTX and SET_CTX modes and
--   correct context is set.
-- End of Comments
-------------------------------------------------------------------------------
PROCEDURE POS_SUPP_REG_WF_SELECTOR(
    p_itemtype IN VARCHAR2,
    p_itemkey  IN VARCHAR2,
    p_actid    IN NUMBER,
    p_funcmode IN VARCHAR2,
    p_x_result IN OUT NOCOPY VARCHAR2)
IS
  -- Declare context setting variables start
  l_session_user_id NUMBER;
  l_session_resp_id NUMBER;
  l_responder_id    NUMBER;
  l_user_id_to_set  NUMBER;
  l_resp_id_to_set  NUMBER;
  l_appl_id_to_set  NUMBER;
  l_progress        VARCHAR2(4000) DEFAULT '000';
  l_preserved_ctx   VARCHAR2(5):= 'TRUE';
  l_org_id          NUMBER;
  l_api_name        VARCHAR2(500) := 'POS_SUPP_REG_WF_SELECTOR';
  -- Declare context setting variables End
BEGIN
  l_progress                            := l_api_name || 'Inside POS_SUPP_REG_WF_SELECTOR procedure  - p_itemtype: ' || p_itemtype || ' p_itemkey: ' || p_itemkey || ' p_actid: ' || p_actid || ' p_funcmode: '|| p_funcmode ;
  IF g_fnd_debug                         = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;
  l_org_id             := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => p_itemtype, itemkey => p_itemkey, aname => 'ORG_ID');
  l_session_user_id    := fnd_global.user_id;
  l_session_resp_id    := fnd_global.resp_id;
  IF (l_session_user_id = -1) THEN
    l_session_user_id  := NULL;
  END IF;
  IF (l_session_resp_id = -1) THEN
    l_session_resp_id  := NULL;
  END IF;
  l_responder_id                        := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => p_itemtype, itemkey => p_itemkey, aname => 'RESPONDER_USER_ID');
  l_progress                            :='010 - ses_user_id:'||l_session_user_id ||' ses_resp_id :'||l_session_resp_id||' responder id:' ||l_responder_id||' org id :'||l_org_id;
  IF g_fnd_debug                         = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
    END IF;
  END IF;
  IF (p_funcmode = 'TEST_CTX') THEN
    -- wf shouldn't run without the session user, hence always set the ctx if session user id is null.
    IF (l_session_user_id IS NULL) THEN
      p_x_result          := 'NOTSET';
      RETURN;
    ELSE
      IF (l_responder_id   IS NOT NULL) THEN
        IF (l_responder_id <> l_session_user_id) THEN
          p_x_result       := 'FALSE';
          RETURN;
        ELSE
          IF (l_session_resp_id IS NULL) THEN
            p_x_result          := 'NOTSET';
            RETURN;
          ELSE
            -- If the selector fn is called from a background ps
            -- notif mailer then force the session to use preparer's or responder
            -- context. This is required since the mailer/bckgrnd ps carries the
            -- context from the last wf processed and hence even if the context values
            -- are present, they might not be correct.
            IF (wf_engine.preserved_context = TRUE) THEN
              p_x_result                   := 'TRUE';
            ELSE
              p_x_result:= 'NOTSET';
            END IF;
            IF l_org_id IS NOT NULL THEN
              PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;
            END IF;
            RETURN;
          END IF;
        END IF;
      ELSE
        -- always setting the ctx at the start of the wf
        p_x_result := 'NOTSET';
        RETURN;
      END IF;
    END IF; -- l_session_user_id is null
  ELSIF (p_funcmode                          = 'SET_CTX') THEN
    IF l_responder_id                       IS NOT NULL THEN
      l_user_id_to_set                      := l_responder_id;
      l_resp_id_to_set                      := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => p_itemtype, itemkey => p_itemkey, aname => 'RESPONDER_RESP_ID');
      l_appl_id_to_set                      := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => p_itemtype, itemkey => p_itemkey, aname => 'RESPONDER_APPL_ID');
      l_progress                            :='030 selector fn responder id not null: setting user id :'||l_responder_id ||' resp id '||l_resp_id_to_set||' l_appl id '||l_appl_id_to_set;
      IF g_fnd_debug                         = yesChar THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
        END IF;
      END IF;
    ELSE
      l_user_id_to_set                      := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => p_itemtype, itemkey => p_itemkey, aname => 'USER_ID');
      l_resp_id_to_set                      := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => p_itemtype, itemkey => p_itemkey, aname => 'RESPONSIBILITY_ID');
      l_appl_id_to_set                      := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => p_itemtype, itemkey => p_itemkey, aname => 'APPLICATION_ID');
      l_progress                            := '040 selector fn responder id null : set user '||l_user_id_to_set||' resp id ' ||l_resp_id_to_set||' appl id '||l_appl_id_to_set;
      IF g_fnd_debug                         = yesChar THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
        END IF;
      END IF;
    END IF;
    fnd_global.apps_initialize(l_user_id_to_set, l_resp_id_to_set,l_appl_id_to_set);
    -- obvious place to make such a call, since we are using an apps_initialize,
    -- this is required since the responsibility might have a different OU attached
    -- than what is required.
    IF l_org_id IS NOT NULL THEN
      PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;
    END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  IF g_fnd_debug                         = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Exception in Selector Procedure POS_SUPP_REG_WF_SELECTOR l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  WF_CORE.context('POS_SUPP_APPR', 'POS_SUPP_REG_WF_SELECTOR', p_itemtype, p_itemkey, p_actid, p_funcmode);
  RAISE;
END POS_SUPP_REG_WF_SELECTOR;
PROCEDURE GET_RESP_ID(
    p_userid IN VARCHAR2,
    p_funcname  IN VARCHAR2,
    p_applid IN NUMBER,
    p_respid IN OUT NOCOPY NUMBER,
    p_respkey IN OUT NOCOPY VARCHAR2,
    p_x_result IN OUT NOCOPY VARCHAR2)
IS
  l_resp_id fnd_responsibility.RESPONSIBILITY_ID%TYPE;
  l_resp_key fnd_responsibility.RESPONSIBILITY_key%TYPE;
  l_progress VARCHAR2(4000) DEFAULT '000';
  l_api_name        VARCHAR2(500) := 'GET_RESP_ID';
BEGIN
  p_x_result := 'F';
  BEGIN
    l_progress := 'p_userid : ' || p_userid || 'p_funcname : '   || p_funcname;
    IF g_fnd_debug = yesChar THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, g_module_prefix || l_api_name, l_progress );
      END IF;
    END IF;
    SELECT
      resp.RESPONSIBILITY_ID,
      resp.RESPONSIBILITY_key
      into
      p_respid,
      p_respkey
    FROM
      FND_RESPONSIBILITY resp,
      fnd_user fu,
      fnd_user_resp_groups furg,
      ( SELECT DISTINCT MenuEntries.MENU_ID
        --CONNECT_BY_ISLEAF AS TopLevelMenu
        FROM   FND_MENU_ENTRIES MenuEntries
        START WITH MenuEntries.FUNCTION_ID =
          ( SELECT FUNCTION_ID
        FROM   FND_FORM_FUNCTIONS
        WHERE  FUNCTION_NAME = p_funcname )
        CONNECT BY  PRIOR MenuEntries.MENU_ID = MenuEntries.SUB_MENU_ID) ApproverMenus
    WHERE
      resp.MENU_ID = ApproverMenus.MENU_ID and
      --ApproverMenus.TopLevelMenu = 1 and
      resp.application_id = p_applid and
      fu.user_id = p_userid and
      fu.user_id = furg.user_id and
      furg.responsibility_id = resp.responsibility_id and
      (furg.end_date is null or furg.end_date > sysdate) and
      rownum < 2;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name,
                ' Exception: No approver responsibility found : It looks like action is triggered from deault worklist or email, hence it expects responsibility to approve,  - '|| l_progress ||' sqlerrm - '||sqlerrm);
        END IF;
        p_x_result := 'F';
        p_respid := NULL;
        p_respkey := NULL;
  END;
  p_x_result := 'S';
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name,
                ' approver responsibility found : ' || p_respkey || ' : '|| l_progress ||' sqlerrm - '||sqlerrm);
  END IF;
  EXCEPTION
   WHEN OTHERS THEN
   IF g_fnd_debug = yesChar THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name, ' Exception in GET_RESP_ID l_progress - '|| l_progress ||' sqlerrm - '||sqlerrm);
    END IF;
  END IF;
  RAISE;
END GET_RESP_ID;
END POS_SUPP_APPR;

/
