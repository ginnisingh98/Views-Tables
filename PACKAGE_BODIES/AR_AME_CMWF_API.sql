--------------------------------------------------------
--  DDL for Package Body AR_AME_CMWF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_AME_CMWF_API" AS
/* $Header: ARAMECMB.pls 120.21.12010000.2 2008/09/01 09:49:30 naneja ship $ */


/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/

-- This procedure is called restore the context.  This is necessary
-- after notifications because the process gets deferred, and workflow
-- application specific context when it resumes.
--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');


PROCEDURE callback_routine (
  p_item_type   IN VARCHAR2,
  p_item_key    IN VARCHAR2,
  p_activity_id IN NUMBER,
  p_command     IN VARCHAR2,
  p_result      IN OUT NOCOPY VARCHAR2) IS

  CURSOR org IS
    SELECT org_id
    FROM   ra_cm_requests_all
    WHERE  request_id = p_item_key;

  l_debug_mesg  VARCHAR2(240);
  l_org_id      ra_cm_requests_all.org_id%TYPE;

BEGIN

  OPEN org;
  FETCH org INTO l_org_id;
  CLOSE org;

  wf_engine.setitemattrnumber(
    p_item_type,
    p_item_key,
    'ORG_ID',
    l_org_id);

  l_debug_mesg := 'Org ID: ' || l_org_id;

  IF ( p_command = 'RUN' ) THEN

     -- executable statements for RUN mode
     -- resultout := 'CMREQ_APPROVAL';
     RETURN;
  END IF;

  IF ( p_command = 'SET_CTX' ) THEN

    -- executable statements for establishing context information
    mo_global.set_policy_context(
      p_access_mode => 'S',
      p_org_id      => l_org_id);


  END IF;

  IF ( p_command = 'TEST_CTX' ) THEN

    -- your executable statements for testing the validity of the current
    -- context information
    IF (NVL(mo_global.get_access_mode, '-9999') <> 'S') OR
       (NVL(mo_global.get_current_org_id, -9999) <> l_org_id) THEN
       p_result := 'FALSE';
    ELSE
       p_result := 'TRUE';
    END IF;
    RETURN;

  END IF;

  EXCEPTION
    WHEN OTHERS THEN

    wf_core.context(
      pkg_name  => 'ARP_CMREQ_WF',
      proc_name => 'CALLBACK_ROUTINE',
      arg1      => p_item_type,
      arg2      => p_item_key,
      arg3      => to_char(p_activity_id),
      arg4      => p_command,
      arg5      => l_debug_mesg);

    RAISE;

END callback_routine;


PROCEDURE restore_context (p_item_key  IN  VARCHAR2) IS

  l_org_id     wf_item_attribute_values.number_value%TYPE;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered RESTORE_CONTEXT';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('restore_context: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  l_org_id := wf_engine.GetItemAttrNumber(
    itemtype => c_item_type,
    itemkey  => p_item_key,
    aname    => 'ORG_ID');

  fnd_client_info.set_org_context (
    context => l_org_id);

  arp_global.init_global;

  EXCEPTION
    WHEN OTHERS THEN

    wf_core.context(
      pkg_name  => 'AR_AME_CMWF_API',
      proc_name => 'RESTORE_CONTEXT',
      arg1      => c_item_type,
      arg2      => NULL,
      arg3      => NULL,
      arg4      => NULL,
      arg5      => g_debug_mesg);

    RAISE;

END restore_context;


-- This procedure is called save the context.  This is necessary
-- after notifications because the process gets deferred, and workflow
-- application specific context when it resumes.
--
PROCEDURE save_context (p_item_key  IN  VARCHAR2) IS

  l_org_id     wf_item_attribute_values.number_value%TYPE;

  CURSOR c IS
    SELECT org_id
    FROM   ra_cm_requests_all
    WHERE  request_id = p_item_key;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered SAVE_CONTEXT';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('save_context: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  OPEN c;
  FETCH c INTO l_org_id;
  CLOSE c;

  wf_engine.SetItemAttrNumber(
    itemtype => c_item_type,
    itemkey  => p_item_key,
    aname    => 'ORG_ID',
    avalue   => l_org_id);

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'SAVE_CONTEXT',
        arg1      => c_item_type,
        arg2      => NULL,
        arg3      => NULL,
        arg4      => NULL,
        arg5      => g_debug_mesg);

      RAISE;

END save_context;
/*4139346: Added employee_valid */

FUNCTION employee_valid (p_employee_id IN NUMBER)
  RETURN BOOLEAN IS

  CURSOR c IS
    SELECT 1
    FROM  wf_roles
    WHERE orig_system = 'PER'
    AND   orig_system_id = p_employee_id
    AND   status = 'ACTIVE'
    AND   (expiration_date IS NULL OR
           sysdate < expiration_date)
    AND   rownum < 2;

  l_dummy NUMBER;
  l_result BOOLEAN;

BEGIN

  OPEN c;
  FETCH c INTO l_dummy;
  l_result := c%FOUND;
  CLOSE c;

  RETURN l_result;

END employee_valid;


PROCEDURE validate_first_approver (p_item_key IN NUMBER) IS

  l_employee_id          NUMBER;
  l_manager_employee_id  NUMBER;

  CURSOR mgr IS
    SELECT supervisor_id
    FROM  per_all_assignments_f
    WHERE  person_id = l_employee_id
    AND    per_all_assignments_f.primary_flag = 'Y'
    AND    per_all_assignments_f.assignment_type in ('E','C')
    AND    per_all_assignments_f.assignment_status_type_id
             NOT IN
             (SELECT assignment_status_type_id
              FROM  per_assignment_status_types
              WHERE  per_system_status = 'TERM_ASSIGN');

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered VALIDATE_FIRST_APPROVER';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('VALIDATE_FIRST_APPROVER: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  l_employee_id := wf_engine.getitemattrnumber(
    itemtype => c_item_type,
    itemkey  => p_item_key,
    aname    => 'NON_DEFAULT_START_PERSON_ID');

  -- Now that we allow users to setup HR Hierarchy and Non HR Hierarchy
  -- based approvers, we must look into this variable and determine
  -- if HR Hierarchy is being used only then do this validation and
  -- correction.

  IF l_employee_id IS NULL THEN
    RETURN;
  END IF;

  -- if the employee is valid then proceed with the current first approver.
  IF employee_valid(l_employee_id) THEN
    RETURN;
  END IF;

   -- employee is not valid anymore, so go ahead and lookup the manager
   OPEN  mgr;
   FETCH mgr INTO l_manager_employee_id;
   CLOSE mgr;

   -- now set the manager as the first approver.
   wf_engine.setitemattrnumber(
     itemtype => c_item_type,
     itemkey  => p_item_key,
     aname    => 'NON_DEFAULT_START_PERSON_ID',
     avalue   => l_manager_employee_id);

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'VALIDATE_FIRST_APPROVER',
        arg1      => c_item_type,
        arg2      => NULL,
        arg3      => NULL,
        arg4      => NULL,
        arg5      => g_debug_mesg);

      RAISE;

END validate_first_approver;



-- This procedure is simply a central place to get an employee id
-- given a user id.
--
FUNCTION get_employee_id (p_user_id NUMBER) RETURN NUMBER IS

    CURSOR c IS
        SELECT employee_id
        FROM   fnd_user
        WHERE  user_id = p_user_id;

  l_employee_id NUMBER;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered GET_EMPLOYEE_ID';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('get_employee_id: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  OPEN c;
  FETCH c INTO l_employee_id;
  CLOSE c;

  RETURN l_employee_id;


  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'GET_EMPLOYEE_ID',
        arg1      => c_item_type,
        arg2      => NULL,
        arg3      => NULL,
        arg4      => NULL,
        arg5      => g_debug_mesg);

      RAISE;

END get_employee_id;


-- This procedure is simply a central place to get a user id
-- given an employee id.
--
FUNCTION get_user_id (p_employee_id IN NUMBER) RETURN NUMBER IS

    CURSOR c IS
        SELECT user_id
        FROM   fnd_user
        WHERE  employee_id = p_employee_id
        AND    NVL(end_date,sysdate) >= sysdate ;

  l_user_id NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO l_user_id;
    CLOSE c;

    RETURN l_user_id;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'GET_USER_ID',
        arg1      => c_item_type,
        arg2      => NULL,
        arg3      => NULL,
        arg4      => NULL,
        arg5      => g_debug_mesg);

      RAISE;

END get_user_id;


PROCEDURE GetUserInfoFromTable(
  p_user_id      IN  NUMBER,
  p_user_name    OUT NOCOPY VARCHAR2,
  p_display_name OUT NOCOPY VARCHAR2) IS

  l_employee_id NUMBER;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered GETUSERINFOFROMTABLE';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('GetUserInfoFromTable: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  -- Modifed for Bug # 3778203.  We need to eliminate the restriction
  -- that the approver must be an employee.  As a result, now we can
  -- simply use the api provided by the workflow team to get the user
  -- name and the display name.
  --
  -- ORASHID 04-NOV-2004

  wf_directory.getusername (
    p_orig_system    => 'FND_USR',
    p_orig_system_id => p_user_id,
    p_name           => p_user_name,   -- out variable
    p_display_name   => p_display_name -- out variable
  );

  -- it is possible the user is question was originally created
  -- as person, so look for it as PER.

  IF (p_user_name IS NULL) THEN

    l_employee_id := get_employee_id(p_user_id);

    wf_directory.getusername (
      p_orig_system    => 'PER',
      p_orig_system_id => l_employee_id,
      p_name           => p_user_name,   -- out variable
      p_display_name   => p_display_name -- out variable
    );

  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_user_name := NULL ;
      p_display_name := NULL ;

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'GETUSERINFOFROMTABLE',
        arg1      => c_item_type,
        arg2      => p_user_id,
        arg3      => l_employee_id,
        arg4      => NULL,
        arg5      => g_debug_mesg);

      RAISE;

    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'GETUSERINFOFROMTABLE',
        arg1      => c_item_type,
        arg2      => p_user_id,
        arg3      => NULL,
        arg4      => NULL,
        arg5      => g_debug_mesg);

      RAISE;

END GetUserInfoFromTable;


PROCEDURE GetEmployeeInfo(
  p_user_id   IN  NUMBER,
  p_item_type IN  VARCHAR2,
  p_item_key  IN  VARCHAR2) IS

  l_approver_user_name      wf_users.name%TYPE;
  l_approver_display_name  wf_users.display_name%TYPE;
  l_manager_name           VARCHAR2(100);
  l_manager_display_name   wf_users.display_name%TYPE;

BEGIN


  ----------------------------------------------------------
  g_debug_mesg := 'Entered GETEMPLOYEEINFO';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('GetEmployeeInfo: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  -- set username and display name for a primary approver

  GetUserInfoFromTable(
    p_user_id,
    l_approver_user_name,
    l_approver_display_name);

  IF l_approver_user_name IS NOT NULL THEN

    wf_engine.SetItemAttrNumber(p_item_type,
      p_item_key,
      'APPROVER_ID',
      p_user_id);

    wf_engine.SetItemAttrText(p_item_type,
      p_item_key,
      'APPROVER_USER_NAME',
      l_approver_user_name);

    wf_engine.SetItemAttrText(p_item_type,
      p_item_key,
      'APPROVER_DISPLAY_NAME',
      l_approver_display_name);

  ELSE
    g_debug_mesg := 'USER NAME not found, ' ||
                    'user may not be setup as an employee!';
    RAISE no_data_found;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'GETEMPLOYEEINFO',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_user_id,
        arg4      => NULL,
        arg5      => g_debug_mesg);

      RAISE;

END GetEmployeeInfo;

/*4139346: Added handle_ntf_forward */

PROCEDURE handle_ntf_forward (
  p_item_type IN VARCHAR2,
  p_item_key  IN VARCHAR2,
  p_actid    IN NUMBER,
  p_funcmode IN VARCHAR2,
  p_result   OUT NOCOPY VARCHAR2) IS

  CURSOR c (p_user_name VARCHAR2) IS
    SELECT user_id
    FROM   fnd_user
    WHERE  user_name = p_user_name;

  l_document_id             NUMBER;
  l_customer_trx_id         NUMBER;
  l_note_id                 NUMBER;
  l_note_text               ar_notes.text%type;
  l_responder_user_id       wf_users.orig_system_id%TYPE;
  l_responder_user_name     wf_users.name%TYPE;
  l_responder_display_name  wf_users.display_name%TYPE;

BEGIN

  l_responder_user_name := wf_engine.context_text;

  OPEN c(l_responder_user_name);
  FETCH c INTO l_responder_user_id;
  CLOSE c;

  GetUserInfoFromTable(
    p_user_id      => l_responder_user_id,
    p_user_name    => l_responder_user_name,
    p_display_name => l_responder_display_name);

  IF p_funcmode = 'TRANSFER' OR p_funcmode = 'FORWARD' THEN

    -- insert the reassignment note here

    l_document_id := wf_engine.GetItemAttrNumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'WORKFLOW_DOCUMENT_ID');

    l_customer_trx_id := wf_engine.GetItemAttrNumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'CUSTOMER_TRX_ID');

    fnd_message.set_name('AR', 'AR_WF_APPROVAL_REASSIGNED');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('APPROVER',  l_responder_display_name);

    l_note_text := fnd_message.get;

    InsertTrxNotes (
      x_customer_call_id       => NULL,
      x_customer_call_topic_id => NULL,
      x_action_id              => NULL,
      x_customer_trx_id        => l_customer_trx_id,
      x_note_type              => 'MAINTAIN',
      x_text                   => l_note_text,
      x_note_id                => l_note_id);

  ELSIF (p_funcmode = 'RESPOND') THEN

    wf_engine.setitemattrtext(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'DEBUG',
      avalue   => '2: ' || l_responder_user_name);

    -- insert the reassignment note here

    wf_engine.SetItemAttrNumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'APPROVER_ID',
      avalue   => l_responder_user_id);

    wf_engine.SetItemAttrText(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'APPROVER_USER_NAME',
      avalue   => l_responder_user_name);

    wf_engine.SetItemAttrText(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'APPROVER_DISPLAY_NAME',
      avalue   => l_responder_display_name);

  END IF;

END handle_ntf_forward;


PROCEDURE CheckUserInTable(p_item_type        IN  VARCHAR2,
                           p_item_key         IN  VARCHAR2,
			   p_employee_id      IN NUMBER,
			   p_primary_flag     IN VARCHAR2,
			   p_count            OUT NOCOPY NUMBER) IS

  l_reason_code   VARCHAR2(45);
  l_currency_code VARCHAR2(30);

  CURSOR c1 IS
    SELECT count(*)
    FROM   ar_approval_user_limits aul
    WHERE  aul.reason_code   = l_reason_code
    AND    aul.currency_code = l_currency_code
    AND    aul.primary_flag  = p_primary_flag
    AND    user_id = p_employee_id
    ORDER BY - aul.amount_from;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered CHECKUSERINTABLE';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('CheckUserInTable: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  l_reason_code    := wf_engine.GetItemAttrText(
    p_item_type,
    p_item_key,
    'REASON');

  l_currency_code   := wf_engine.GetItemAttrText(
    p_item_type,
    p_item_key,
    'CURRENCY_CODE');

  OPEN c1;
  FETCH c1 into p_count;
  CLOSE c1;

  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'CHECKUSERINTABLE',
        arg1      => c_item_type,
        arg2      => NULL,
        arg3      => NULL,
        arg4      => NULL,
        arg5      => g_debug_mesg);

      RAISE;

END CheckUserInTable;


/*************************************************************************/
-- Written For AME Integration
--
-- This procedure is called to find the next approver for the transaction
-- type. It also stores the person retrieved in a workflow attribute
-- appropriately named PERSON_ID.  It also cals getemployeeinfo to set some
-- attributes to make sure notifications are sent smoothly to this approver.
--
PROCEDURE FindNextApprover (
  p_item_type    IN VARCHAR2,
  p_item_key     IN VARCHAR2,
  p_ame_trx_type IN VARCHAR2,
  x_approver_user_id OUT NOCOPY NUMBER,
  x_approver_employee_id OUT NOCOPY NUMBER) IS

  l_next_approver        ame_util.approverrecord;
  l_admin_approver       ame_util.approverRecord;
  l_approver_user_id     NUMBER DEFAULT NULL;
  l_approver_employee_id NUMBER;
  l_error_message        fnd_new_messages.message_text%TYPE;

BEGIN

    ----------------------------------------------------------
    g_debug_mesg := 'Entered FINDNEXTAPPROVER';
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('FindNextApprover: ' || g_debug_mesg);
    END IF;
    ----------------------------------------------------------

    ame_api.getnextapprover(
      applicationidin   => c_application_id,
      transactionidin   => p_item_key,
      transactiontypein => p_ame_trx_type,
      nextapproverout   => l_next_approver);

    ------------------------------------------------------------------------
    g_debug_mesg := 'AME call to getNextApprover returned: ';
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('FindNextAprrover: ' || g_debug_mesg);
    END IF;
    ------------------------------------------------------------------------

    IF (l_next_approver.person_id IS NULL) THEN

      IF (l_next_approver.user_id IS NULL) THEN
        -- no more approvers left
        RETURN;

      ELSE
        l_approver_user_id := l_next_approver.user_id;
        l_approver_employee_id := get_employee_id(l_approver_user_id);

      END IF;

    ELSE

      -- check if the person id matches admin person id
      -- which means there was an error retrieving
      -- the approver and this should be reported.

      ame_api.getadminapprover(adminapproverout => l_admin_approver);

      IF l_next_approver.person_id = l_admin_approver.person_id THEN
        Fnd_message.set_name(
          application => 'AR',
          name        => 'AR_CMWF_AME_NO_APPROVER_MESG');
        l_error_message := fnd_message.get;
        app_exception.raise_exception;

      ELSE

        -- the person id returned is a valid approver.

        l_approver_employee_id := l_next_approver.person_id;
        l_approver_user_id := get_user_id(
          p_employee_id => l_approver_employee_id);

      END IF;

    END IF;

    wf_engine.SetItemAttrNumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'PERSON_ID',
      avalue   => l_approver_employee_id);

    x_approver_user_id := l_approver_user_id;
    x_approver_employee_id := l_approver_employee_id;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'FINDNEXTAPPROVER',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => NULL,
        arg4      => NULL,
        arg5      => g_debug_mesg);

      RAISE;

END FindNextApprover;


/***********************************************************************/
 -- Written For AME Integration
 --
 -- We reach this function because the approver has approved or rejected
 -- or not responded to the the request and therefore we must communicate
 -- that to AME.  Only complicaton we have here is that this same function is
 -- called for collector as well as for the subsequent approvers. We must
 -- know where we are in the process for updateApprovalStatus2 to work
 -- correctly.  That is why we look at the CURRENT_HUB attribute to find
 -- what value of transaction type to pass to AME.

PROCEDURE RecordResponseWithAME (
  p_item_type    IN VARCHAR2,
  p_item_key     IN VARCHAR2,
  p_response     IN VARCHAR2) IS

  l_transaction_type      VARCHAR2(30);
  --l_approver_id           NUMBER;
  l_approver_user_id      NUMBER;
  l_approver_employee_id  NUMBER;
  l_next_approver         ame_util.approverrecord;

BEGIN

    l_transaction_type := wf_engine.GetItemAttrText(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'CURRENT_HUB');

    g_debug_mesg := 'Before call to getNextApprover';


    ame_api.getnextapprover(
      applicationidin   => c_application_id,
      transactionidin   => p_item_key,
      transactiontypein => l_transaction_type,
      nextapproverout   => l_next_approver);

    ------------------------------------------------------------------------
    g_debug_mesg := 'AME call to getNextApprover returned: ';
    IF pg_debug IN ('Y', 'C') THEN
       arp_standard.debug('FindNextAprrover: ' || g_debug_mesg);
    END IF;
    ------------------------------------------------------------------------

    IF (l_next_approver.person_id IS NULL) THEN
      l_approver_user_id := l_next_approver.user_id;
      l_approver_employee_id := NULL;
    ELSE
      l_approver_user_id := NULL;
      l_approver_employee_id := l_next_approver.person_id;
    END IF;

    g_debug_mesg := 'call AME updateApprovalStatus - ' ||
     'l_approver_user_id: ' || l_approver_user_id ||
     ' l_approver_employee_id: ' || l_approver_employee_id;


    ame_api.updateApprovalStatus2(
      applicationIdIn    => c_application_id,
      transactionIdIn    => p_item_key,
      approvalStatusIn   => p_response,
      approverPersonIdIn => l_approver_employee_id,
      approverUserIdIn   => l_approver_user_id,
      transactionTypeIn  => l_transaction_type);

    g_debug_mesg := 'Returned successfully from updateApprovalStatus!';

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'RECORDRESPONSEWITHAME',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => null,
        arg4      => null,
        arg5      => g_debug_mesg);

      RAISE;

END RecordResponseWithAME;


/*************************************************************************/
-- Written For AME Integration
-- This is a subroutine to sync timeout scenarios with AME. Currently,
-- due to AME limitations, we ourselves are handling the logic for timeouts.
-- As a result, there is a need to sync up with AME when the manager responds
-- to the escalation notice.  In case the manager is one of the approvers then
-- we must skip him so that he does not have to approve the same transaction
-- twice.

PROCEDURE SkipIfDuplicate (
  p_item_type    IN VARCHAR2,
  p_item_key     IN VARCHAR2,
  p_ame_trx_type IN VARCHAR2,
  p_approver_user_id IN VARCHAR2,
  p_approver_employee_id IN VARCHAR2,
  x_approver_user_id OUT NOCOPY NUMBER,
  x_approver_employee_id OUT NOCOPY NUMBER) IS

  l_manager_employee_id  fnd_user.employee_id%TYPE;

BEGIN

  l_manager_employee_id := wf_engine.getitemattrnumber(
    itemtype => p_item_type,
    itemkey  => p_item_key,
    aname    => 'MANAGER_ID');

  g_debug_mesg := 'Manager ID: ' || l_manager_employee_id;

  IF (p_approver_employee_id = l_manager_employee_id) THEN

    -- The next approver in the approval chain is the manager
    -- who has approved this transaction once before.

    g_debug_mesg := 'Skipping approver';

    -- inform AME that the approver has approved this.
    RecordResponseWithAME (
      p_item_type => p_item_type,
      p_item_key  => p_item_key,
      p_response  => ame_util.approvedStatus);

   -- now get the next approver in the list.
    FindNextApprover(
      p_item_type    => p_item_type,
      p_item_key     => p_item_key,
      p_ame_trx_type => p_ame_trx_type,
      x_approver_user_id => x_approver_user_id,
      x_approver_employee_id => x_approver_employee_id);

    g_debug_mesg := 'Retrieved the next approver';

    -- reset the scalation related attributes.
    wf_engine.setitemattrnumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'MANAGER_ID',
      avalue   => -9999);

    wf_engine.setitemattrnumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'ESCALATION_COUNT',
      avalue   => 0);

  ELSE
    g_debug_mesg := 'Not skipping the approver';
    x_approver_user_id     := p_approver_user_id;
    x_approver_employee_id := p_approver_employee_id;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'SKIPIFDUPLICATE',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => NULL,
        arg4      => NULL,
        arg5      => g_debug_mesg);

      RAISE;

END SkipIfDuplicate;


PROCEDURE FindTrx(p_item_type        IN  VARCHAR2,
                  p_item_key         IN  VARCHAR2,
                  p_actid            IN  NUMBER,
                  p_funcmode         IN  VARCHAR2,
                  p_result           OUT NOCOPY VARCHAR2) IS

  l_workflow_document_id     NUMBER;
  l_customer_trx_id          NUMBER;
  l_amount                   NUMBER;
  l_tax_amount               NUMBER;
  l_line_amount              NUMBER;
  l_freight_amount           NUMBER;
  l_original_line_amount     NUMBER;
  l_original_tax_amount      NUMBER;
  l_original_freight_amount  NUMBER;
  l_original_total           NUMBER;
  l_reason_code              VARCHAR2(45);
  l_reason_meaning           VARCHAR2(80);
  l_currency_code            VARCHAR2(15);
  l_requestor_id		   NUMBER;
  l_requestor_user_name       wf_users.name%TYPE;
  l_requestor_display_name   wf_users.display_name%TYPE;
  /*Bug3206020 Changed comments size from 240 to 1760. */
  l_comments                 VARCHAR2(1760);
   l_orig_trx_number          ra_cm_requests_all.orig_trx_number%TYPE;
  l_tax_ex_cert_num          ra_cm_requests_all.tax_ex_cert_num%TYPE;
  l_internal_comment                 VARCHAR2(1760) DEFAULT NULL;  /*7367350*/


  CURSOR c1 is
    SELECT name, display_name
    FROM   wf_users
    WHERE  orig_system = 'PER'
    AND    orig_system_id = l_requestor_id;

  CURSOR c2 is
    SELECT name, display_name
    FROM   wf_users
    WHERE  orig_system = 'FND_USR'
    AND    orig_system_id = l_requestor_id;


BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered FINDTRX';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('FindTrx: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  -- save_context(p_item_key);

  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then

    ------------------------------------------------------------
    g_debug_mesg := 'Get the requested trx and request_id';
    ------------------------------------------------------------
    /*7367350 As per enhacement passed parmeter to get vlaue and set
      in newly added attribute for the workflow. */
    GetCustomerTrxInfo(
      p_item_type,
      p_item_key,
      l_workflow_document_id,
      l_customer_trx_id,
      l_amount,
      l_line_amount,
      l_tax_amount,
      l_freight_amount,
      l_reason_code,
      l_reason_meaning,
      l_requestor_id,
      l_comments,
      l_orig_trx_number,
      l_tax_ex_cert_num,
      l_internal_comment
    );

    IF l_customer_trx_id <> -1 then

      wf_engine.SetItemAttrNumber(
        p_item_type,
        p_item_key,
        'WORKFLOW_DOCUMENT_ID',
        l_workflow_document_id);

      wf_engine.SetItemAttrNumber(
        p_item_type,
        p_item_key,
        'CUSTOMER_TRX_ID',
        l_customer_trx_id);

      wf_engine.SetItemAttrNumber(
        p_item_type,
        p_item_key,
        'TOTAL_CREDIT_TO_INVOICE',
        l_amount);

      wf_engine.SetItemAttrNumber(
        p_item_type,
        p_item_key,
        'TOTAL_CREDIT_TO_LINES',
        l_line_amount);

      wf_engine.SetItemAttrNumber(
        p_item_type,
        p_item_key,
        'TOTAL_CREDIT_TO_TAX',
        l_tax_amount);

      wf_engine.SetItemAttrNumber(
        p_item_type,
        p_item_key,
        'TOTAL_CREDIT_TO_FREIGHT',
        l_freight_amount);

      wf_engine.SetItemAttrText(
        p_item_type,
        p_item_key,
        'REASON',
        l_reason_code);

      wf_engine.SetItemAttrText(
        p_item_type,
        p_item_key,
        'REASON_MEANING',
        l_reason_meaning);

      wf_engine.SetItemAttrText(
        p_item_type,
	p_item_key,
	'COMMENTS',
	l_comments);

      wf_engine.SetItemAttrNumber(
        p_item_type,
        p_item_key,
        'REQUESTOR_ID',
        l_requestor_id);

      wf_engine.SetItemAttrText(
        p_item_type,
        p_item_key,
        'ORIG_TRX_NUMBER',
        l_orig_trx_number);

      wf_engine.SetItemAttrText(
        p_item_type,
        p_item_key,
        'TAX_EX_CERT_NUM',
        l_tax_ex_cert_num);

    wf_engine.SetItemAttrText(
        p_item_type,
	p_item_key,
	'INTERNAL_COMMENTS',
	l_internal_comment);

      -- set requestor name and display name
      IF ( l_requestor_id <> -1)  then
        OPEN c1;
	FETCH c1 into l_requestor_user_name, l_requestor_display_name;
        IF c1%notfound then
          l_requestor_user_name    := NULL;
	  l_requestor_display_name := NULL;
          OPEN c2;
          FETCH c2 into l_requestor_user_name, l_requestor_display_name;
          IF c2%notfound then
            l_requestor_user_name    := NULL;
            l_requestor_display_name := NULL;
            g_debug_mesg             := 'could not find the requestor';
          END if;
        END if;
      END if;

      wf_engine.SetItemAttrText(
        p_item_type,
	p_item_key,
	'REQUESTOR_USER_NAME',
	l_requestor_user_name);

      wf_engine.SetItemAttrText(
        p_item_type,
	p_item_key,
	'REQUESTOR_DISPLAY_NAME',
	l_requestor_display_name);

       -- set amount for trx.

      GetTrxAmount(
        p_item_type,
        p_item_key,
        l_customer_trx_id,
        l_original_line_amount,
        l_original_tax_amount,
        l_original_freight_amount,
        l_original_total ,
	l_currency_code);

      wf_engine.SetItemAttrNumber(
        p_item_type,
        p_item_key,
        'ORIGINAL_LINE_AMOUNT',
        l_original_line_amount);

      wf_engine.SetItemAttrNumber(
        p_item_type,
        p_item_key,
        'ORIGINAL_TAX_AMOUNT',
        l_original_tax_amount);

      wf_engine.SetItemAttrNumber(
        p_item_type,
        p_item_key,
        'ORIGINAL_FREIGHT_AMOUNT',
        l_original_freight_amount);

      wf_engine.SetItemAttrNumber(
        p_item_type,
        p_item_key,
        'ORIGINAL_TOTAL',
        l_original_total);

      wf_engine.SetItemAttrText(
        p_item_type,
        p_item_key,
        'CURRENCY_CODE',
        l_currency_code);

       p_result := 'COMPLETE:T';
       RETURN;
     ELSE
       p_result := 'COMPLETE:F';
       RETURN;
     END if;

   END if; -- END of run mode

   --
   -- CANCEL mode
   --
   -- This is an event point is called with the effect of the activity must
   -- be undone, for example when a process is reset to an earlier point
   -- due to a loop back.
   --
   IF (p_funcmode = 'CANCEL') then

   -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
   END if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning NULL
  --
  p_result := '';
  RETURN;

  EXCEPTION
  WHEN OTHERS THEN

    wf_core.context(
      pkg_name  => 'AR_AME_CMWF_API',
      proc_name => 'FINDTRX',
      arg1      => p_item_type,
      arg2      => p_item_key,
      arg3      => p_funcmode,
      arg4      => to_char(p_actid),
      arg5      => g_debug_mesg);

END FindTrx;


/*7367350 Changed procedure to retrive value for internal comment as well */
PROCEDURE GetCustomerTrxInfo(p_item_type             IN  VARCHAR2,
                             p_item_key              IN  VARCHAR2,
                             p_workflow_document_id  OUT NOCOPY NUMBER,
                             p_customer_trx_id       OUT NOCOPY NUMBER,
                             p_amount                OUT NOCOPY NUMBER,
                             p_line_amount           OUT NOCOPY NUMBER,
                             p_tax_amount            OUT NOCOPY NUMBER,
                             p_freight_amount        OUT NOCOPY NUMBER,
			     p_reason                OUT NOCOPY VARCHAR2,
			     p_reason_meaning	     OUT NOCOPY VARCHAR2,
			     p_requestor_id	     OUT NOCOPY NUMBER,
                             p_comments              OUT NOCOPY VARCHAR2,
			     p_orig_trx_number       OUT NOCOPY VARCHAR2,
                             p_tax_ex_cert_num       OUT NOCOPY VARCHAR2,
						p_internal_comment              OUT NOCOPY VARCHAR2) IS

  l_workflow_document_id    NUMBER;
  l_customer_trx_id         NUMBER;
  l_amount                  NUMBER;
  l_line_amount             NUMBER;
  l_tax_amount              NUMBER;
  l_freight_amount          NUMBER;
  l_created_by              NUMBER;
  l_line_credit_flag        VARCHAR2(1);
  l_tax_disclaimer          VARCHAR2(250);
  l_orig_trx_number          ra_cm_requests_all.orig_trx_number%TYPE;
  l_tax_ex_cert_num          ra_cm_requests_all.tax_ex_cert_num%TYPE;

  CURSOR c IS
    SELECT r.request_id,
           r.customer_trx_id,
           r.total_amount,
           r.cm_reason_code,
           l.meaning,
           r.created_by,
           r.comments,
           r.line_credits_flag,
           r.line_amount,
           r.tax_amount,
           r.freight_amount,
           r.ORIG_TRX_NUMBER,
           r.TAX_EX_CERT_NUM,
	   r.internal_comment
    FROM   ar_lookups l, ra_cm_requests r
    WHERE  r.request_id = p_item_key
    AND    r.cm_reason_code = l.lookup_code
    AND    l.lookup_type = 'CREDIT_MEMO_REASON';

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered GETCUSTOMERTRXINFO';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('GetCustomerTrxInfo: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  OPEN c;
  FETCH c INTO
    l_workflow_document_id,
    l_customer_trx_id,
    l_amount,
    p_reason,
    p_reason_meaning,
    l_created_by,
    p_comments,
    l_line_credit_flag,
    l_line_amount,
    l_tax_amount,
    l_freight_amount,
    l_orig_trx_number,
    l_tax_ex_cert_num,
    p_internal_comment;
  CLOSE c;

  p_workflow_document_id := l_workflow_document_id;
  p_customer_trx_id      := l_customer_trx_id;
  p_amount               := l_amount;
  p_line_amount          := l_line_amount;
  p_tax_amount           := l_tax_amount;
  p_freight_amount       := l_freight_amount;
  p_orig_trx_number      := l_orig_trx_number;
  p_tax_ex_cert_num      := l_tax_ex_cert_num;


  IF l_line_credit_flag = 'Y' THEN
     p_line_amount := l_amount;
  END IF;

  p_requestor_id := get_employee_id(l_created_by);

  IF (p_requestor_id IS NULL) THEN
    p_requestor_id := l_created_by;
  END IF;

  l_tax_disclaimer := NULL;

  IF l_line_credit_flag = 'Y' THEN
    fnd_message.set_name('AR', 'ARW_INV_MSG10');
    l_tax_disclaimer := fnd_message.get;
  END IF;

  wf_engine.SetItemAttrText(p_item_type,
                               p_item_key,
                               'TAX_DISCLAIMER',
                               l_tax_disclaimer);

  EXCEPTION
    WHEN OTHERS THEN

      p_workflow_document_id := -1;
      p_customer_trx_id      := -1;
      p_amount               := 0;
      p_tax_amount           := 0;
      p_line_amount          := 0;
      p_freight_amount       := 0;
      p_reason               := NULL;
      p_reason_meaning       := NULL;
      p_comments             := NULL;
      p_requestor_id         := -1;
      p_orig_trx_number      := NULL;
      p_tax_ex_cert_num      := NULL;
      p_internal_comment    := NULL;

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'GETCUSTOMERTRXINFO',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => NULL,
        arg4      => NULL,
        arg5      => g_debug_mesg);

      RAISE;

END GetCustomerTrxInfo;


PROCEDURE GetTrxAmount(p_item_type                IN  VARCHAR2,
                       p_item_key                 IN  VARCHAR2,
                       p_customer_trx_id          IN  NUMBER,
                       p_original_line_amount     OUT NOCOPY NUMBER,
                       p_original_tax_amount      OUT NOCOPY NUMBER,
                       p_original_freight_amount  OUT NOCOPY NUMBER,
                       p_original_total           OUT NOCOPY NUMBER,
		       p_currency_code            OUT NOCOPY VARCHAR2) IS

  CURSOR c IS
    SELECT   sum(ps.amount_line_items_original),
             sum(ps.tax_original),
             sum(ps.freight_original),
             sum(ps.amount_due_original),
             ps.invoice_currency_code
    FROM     ar_payment_schedules ps
    WHERE    ps.customer_trx_id = p_customer_trx_id
    GROUP BY ps.invoice_currency_code ;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered GETTRXAMOUNT';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('GetTrxAmount: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  OPEN c;
  FETCH c INTO
    p_original_line_amount,
    p_original_tax_amount,
    p_original_freight_amount,
    p_original_total,
    p_currency_code;
  CLOSE c;

  EXCEPTION
    WHEN OTHERS THEN

      p_original_line_amount    := NULL;
      p_original_tax_amount     := NULL;
      p_original_freight_amount := NULL;
      p_original_total          := NULL;
      p_currency_code           := NULL;

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'GETTRXAMOUNT',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => NULL,
        arg4      => NULL,
        arg5      => g_debug_mesg);

      RAISE;

END GetTrxAmount;


PROCEDURE FindCustomer(p_item_type        IN  VARCHAR2,
                       p_item_key         IN  VARCHAR2,
                       p_actid            IN  NUMBER,
                       p_funcmode         IN  VARCHAR2,
                       p_result           OUT NOCOPY VARCHAR2) IS

  l_customer_trx_id          NUMBER;
  l_customer_id              number(15);
  l_bill_to_site_use_id      NUMBER;
  l_bill_to_customer_name    VARCHAR2(50);
  l_bill_to_customer_number  VARCHAR2(30);
  l_ship_to_customer_number  VARCHAR2(30);
  l_ship_to_customer_name    VARCHAR2(50);
  l_trx_number               VARCHAR2(20);
  l_request_url              ra_cm_requests.url%TYPE;
  l_url                      ra_cm_requests.url%TYPE;
  l_request_id               NUMBER;
  l_trans_url                ra_cm_requests.transaction_url%TYPE;
  l_act_url                  ra_cm_requests.activities_url%TYPE;
  wf_flag		     VARCHAR2(1) := 'Y';

  CURSOR c IS
    SELECT url, transaction_url, activities_url
    FROM   ra_cm_requests
    WHERE  request_id = p_item_key;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered FINDCUSTOMER';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('FindCustomer: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------
  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     g_debug_mesg := 'Get requested trx id ';
     ------------------------------------------------------------
     l_customer_trx_id  :=  wf_engine.GetItemAttrNumber(
                                         p_item_type,
                                         p_item_key,
                                         'CUSTOMER_TRX_ID');

     ------------------------------------------------------------
     g_debug_mesg := 'Get Customer info based on requested trx ';
     ------------------------------------------------------------

     FindCustomerInfo(l_customer_trx_id,
                      l_bill_to_site_use_id,
                      l_customer_id,
                      l_bill_to_customer_name,
                      l_bill_to_customer_number,
                      l_ship_to_customer_number,
                      l_ship_to_customer_name,
                      l_trx_number );

      IF l_bill_to_customer_name is NULL then
         -- no customer has been found.
         p_result := 'COMPLETE:F';
         RETURN;
      END if;



     ----------------------------------------------------------------------
     g_debug_mesg := 'Set value for customer_id(name)  in workflow process';
     -----------------------------------------------------------------------

     wf_engine.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'CUSTOMER_ID',
                                 l_customer_id);


     wf_engine.SetItemAttrText(p_item_type,
                               p_item_key,
                               'CUSTOMER_NAME',
                               l_bill_to_customer_name);

     -- set the bill to and ship to customer info.

     wf_engine.SetItemAttrText(p_item_type,
                               p_item_key,
                               'BILL_TO_CUSTOMER_NAME',
                               l_bill_to_customer_name);

    -- Bug Fix 1882580. Since l_bill_to_customer_number is changed
    --   from number to VARCHAR2, replaced the function in call to
    --   wf_engine fom SetItemAttrNumber to SetItemAttrText

    wf_engine.SetItemAttrText(p_item_type,
                                 p_item_key,
                                 'BILL_TO_CUSTOMER_NUMBER',
                                 l_bill_to_customer_number);

    wf_engine.SetItemAttrText(p_item_type,
                               p_item_key,
                               'SHIP_TO_CUSTOMER_NAME',
                               l_ship_to_customer_name);

    -- Bug Fix 1882580. Since l_bill_to_customer_number is changed
    -- from number to VARCHAR2, replaced the function in call to
    -- wf_engine fom SetItemAttrNumber to SetItemAttrText

    wf_engine.SetItemAttrText(p_item_type,
                                 p_item_key,
                                 'SHIP_TO_CUSTOMER_NUMBER',
                                 l_ship_to_customer_number);

    -- set the trx number

    wf_engine.SetItemAttrText(p_item_type,
                                 p_item_key,
                                 'TRX_NUMBER',
                                 l_trx_number);



     ----------------------------------------------------------------------
     g_debug_mesg := 'Set value for bill_to_site_use_id  in workflow process';
     -----------------------------------------------------------------------
     wf_engine.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'BILL_TO_SITE_USE_ID',
                                 l_bill_to_site_use_id);



     -- set the URL site

    l_request_id  := wf_engine.GetItemAttrNumber(
                                    p_item_type,
                                    p_item_key,
				   'WORKFLOW_DOCUMENT_ID');

    OPEN c;
    FETCH c INTO l_request_url, l_trans_url, l_act_url;
    CLOSE c;

    wf_engine.SetItemAttrText(p_item_type,
                               p_item_key,
                               'REQUEST_URL',
                               l_request_url);

    wf_engine.SetItemAttrText(p_item_type,
                               p_item_key,
                               'TRANSACTION_NUMBER_URL',
                               l_trans_url);

    wf_engine.SetItemAttrText(p_item_type,
                               p_item_key,
                               'TRANSACTION_ACTIVITY_URL',
                               l_act_url);

    p_result := 'COMPLETE:T';
    RETURN;

  END if; -- END of run mode

  --
  -- CANCEL mode
  --
  --
  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes.
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'FINDCUSTOMER',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END FindCustomer;


PROCEDURE FindCustomerInfo(p_customer_trx_id          IN  NUMBER,
                           p_bill_to_site_use_id      OUT NOCOPY NUMBER,
                           p_customer_id              OUT NOCOPY NUMBER,
                           p_bill_to_customer_name    OUT NOCOPY VARCHAR2,
                           p_bill_to_customer_number  OUT NOCOPY VARCHAR2,
                           p_ship_to_customer_number  OUT NOCOPY VARCHAR2,
                           p_ship_to_customer_name    OUT NOCOPY VARCHAR2,
                           p_trx_number               OUT NOCOPY VARCHAR2 ) IS


  CURSOR c IS
    SELECT rct.bill_to_site_use_id,
           rct.bill_to_customer_id,
           substrb(party.party_name,1,50),
           bill_to_cust.account_number,
           rct.trx_number
    FROM   hz_cust_accounts bill_to_cust,
           hz_parties party,
           ra_customer_trx  rct
    WHERE  rct.customer_trx_id = p_customer_trx_id
    AND    rct.bill_to_customer_id = bill_to_cust.cust_account_id
    AND     bill_to_cust.party_id = party.party_id ;

  CURSOR c2 IS
    SELECT substrb(party.party_name,1,50),
           ship_to_cust.account_number
    FROM   hz_cust_accounts ship_to_cust,
           hz_parties  party,
           ra_customer_trx  rct
    WHERE  rct.customer_trx_id = p_customer_trx_id
    AND    rct.ship_to_customer_id   = ship_to_cust.cust_account_id
    AND    ship_to_cust.party_id = party.party_id;


BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered FINDCUSTOMERINFO';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('FindCustomer: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  OPEN c;
  FETCH c INTO
        p_bill_to_site_use_id,
        p_customer_id,
        p_bill_to_customer_name,
        p_bill_to_customer_number,
        p_trx_number;
  CLOSE c;

  ----------------------------------------------------------------------------
  g_debug_mesg := 'find ship to cust id and name based on requested invoice';
  ----------------------------------------------------------------------------

  OPEN c2;
  FETCH c2 INTO
    p_ship_to_customer_name,
    p_ship_to_customer_number;
  CLOSE c2;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      p_customer_id   :=  NULL ;
      p_bill_to_customer_name := NULL;
      p_bill_to_customer_number := NULL;

    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'FINDCUSTOMERINFO',
        arg1      => c_item_type,
        arg2      => NULL,
        arg3      => NULL,
        arg4      => NULL,
        arg5      => g_debug_mesg);

      RAISE;

END FindCustomerInfo;


PROCEDURE FindCollector(p_item_type        IN  VARCHAR2,
                        p_item_key         IN  VARCHAR2,
                        p_actid            IN  NUMBER,
                        p_funcmode         IN  VARCHAR2,
                        p_result           OUT NOCOPY VARCHAR2) IS

  l_customer_trx_id          NUMBER(15);
  l_customer_id              NUMBER;
  l_bill_to_site_use_id      NUMBER(15);
  l_collector_employee_id    NUMBER(15);
  l_collector_user_id        NUMBER(15);
  l_collector_id             NUMBER(15);
  l_collector_name           VARCHAR2(30); -- name displayed in collector form.
  l_collector_user_name       wf_users.name%TYPE;
  l_collector_display_name   wf_users.display_name%TYPE; -- name for collector as employee

  CURSOR c (p_employee_id NUMBER) IS
    SELECT  collector_id, name
    FROM    ar_collectors
    WHERE   employee_id = p_employee_id;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered FINDCOLLECTOR';


  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('FindCollector: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------
  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then

    -----------------------------------------------------------------
    g_debug_mesg := 'Get the value of customer_trx_id(customer id)';
    -----------------------------------------------------------------

    l_customer_trx_id := wf_engine.GetItemAttrNumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'CUSTOMER_TRX_ID');

    l_customer_id := wf_engine.getitemattrnumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'CUSTOMER_ID');

    ----------------------------------------------------------------------
    g_debug_mesg := 'get value of bill_to_site_use_id from workflow process';
    -----------------------------------------------------------------------

    l_bill_to_site_use_id := wf_engine.getitemattrnumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'BILL_TO_SITE_USE_ID');

    -----------------------------------------------------------------------
    g_debug_mesg := 'Find Collector Info';
    -----------------------------------------------------------------------

    -- Notice that this calls AME using c_collector_transaction_type.

    FindNextApprover(
      p_item_type    => p_item_type,
      p_item_key     => p_item_key,
      p_ame_trx_type => c_collector_transaction_type,
      x_approver_user_id => l_collector_user_id,
      x_approver_employee_id => l_collector_employee_id);

    IF l_collector_user_id IS NULL THEN
      p_result := 'COMPLETE:F';
      RETURN;
    END IF;

    wf_engine.SetItemAttrText(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'CURRENT_HUB',
      avalue   => c_collector_transaction_type);

    OPEN c (l_collector_employee_id);
    FETCH c INTO l_collector_id, l_collector_name;
    CLOSE c;

    ----------------------------------------------------------------
    g_debug_mesg := 'Set value for collector in workflow process';
    ----------------------------------------------------------------

    wf_engine.SetItemAttrNumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'COLLECTOR_EMPLOYEE_ID',
      avalue   => l_collector_employee_id);

    wf_engine.SetItemAttrNumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'COLLECTOR_ID',
      avalue   => l_collector_id);

    wf_engine.SetItemAttrText(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'COLLECTOR_NAME',
      avalue   => l_collector_name);

    -------------------------------------------------------------------
    g_debug_mesg := 'Set user name for the collector';
    ------------------------------------------------------------------

    wf_directory.GetUserName(
      'PER',
      l_collector_employee_id,
      l_collector_user_name,
      l_collector_display_name);

    IF l_collector_user_name is NULL then

      ----------------------------------------------------------------
      g_debug_mesg := 'The collector has not been defined in directory';
      -----------------------------------------------------------------
      p_result := 'COMPLETE:F';
      RETURN;
    ELSE
      wf_engine.SetItemAttrText(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'COLLECTOR_USER_NAME',
        avalue   => l_collector_user_name);

      wf_engine.SetItemAttrText(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'COLLECTOR_DISPLAY_NAME',
        avalue   => l_collector_display_name);

      wf_engine.SetItemAttrText(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'APPROVER_ID',
        avalue   => l_collector_user_id);

      wf_engine.SetItemAttrText(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'APPROVER_USER_NAME',
        avalue   => l_collector_user_name);

      wf_engine.SetItemAttrText(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'APPROVER_DISPLAY_NAME',
        avalue   => l_collector_display_name);

     END IF;


   p_result := 'COMPLETE:T';
   RETURN;

  END if; -- END of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by RETURNing NULL
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'FINDCOLLECTOR',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END FindCollector;


/*************************************************************************/
-- Written For AME Integration
--
-- This procedure is called to check the integrity of the invoicing rule.
-- Previously this was part of default send to subroutine, which is now
-- obsolete.

PROCEDURE AMECheckRule (
  p_item_type        IN  VARCHAR2,
  p_item_key         IN  VARCHAR2,
  p_actid            IN  NUMBER,
  p_funcmode         IN  VARCHAR2,
  p_result           OUT NOCOPY VARCHAR2) IS

  l_customer_trx_id         wf_item_attribute_values.number_value%TYPE;
  l_invoicing_rule_id       wf_item_attribute_values.number_value%TYPE;
  l_need_rule_mesg          wf_item_attribute_values.text_value%TYPE;
  l_credit_accounting_rule  wf_item_attribute_values.text_value%TYPE;
  l_reason_code             wf_item_attribute_values.text_value%TYPE;
  l_currency_code      	    wf_item_attribute_values.text_value%TYPE;

  CURSOR c (p_cust_trx_id NUMBER) IS
    SELECT invoicing_rule_id
    FROM ra_customer_trx
    WHERE customer_trx_id = p_cust_trx_id;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered AMECHECKRULE';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('AMECheckRule: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------
  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') THEN

    --------------------------------------------------------------------------
    g_debug_mesg := 'AME Check Rule';
     -------------------------------------------------------------------------

    -- Bug 991922 : check if message body needs to say rule is required
    --              get additional info to determine if rule is required

    l_customer_trx_id :=  wf_engine.getitemattrnumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'CUSTOMER_TRX_ID');

    l_credit_accounting_rule := wf_engine.getitemattrtext(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'CREDIT_ACCOUNTING_RULE');

    l_reason_code := wf_engine.getitemattrtext(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'REASON');

    l_currency_code := wf_engine.GetItemAttrText(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'CURRENCY_CODE');

    OPEN c(l_customer_trx_id);
    FETCH c INTO l_invoicing_rule_id;
    CLOSE c;

    IF l_invoicing_rule_id is NOT NULL THEN
      IF nvl(l_credit_accounting_rule,'*')
        NOT IN ('LIFO','PRORATE','UNIT') THEN

        fnd_message.set_name(
          application => 'AR',
          name        => 'ARW_NEED_RULE');

        l_need_rule_mesg := fnd_message.get;

        wf_engine.SetItemAttrText(
          itemtype => p_item_type,
          itemkey  => p_item_key,
          aname    => 'INVALID_RULE_MESG',
          avalue   => l_need_rule_mesg);
      END IF;
    END IF;

    p_result := 'COMPLETE:';
    RETURN;

  END IF; -- end of run mode

  --
  -- CANCEL mode
  --

  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  End if;

  --
  -- Other execution modes.
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'AMECHECKRULE',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END AMECheckRule;


/*************************************************************************/
-- Written For AME Integration
--
-- This function is called to figure out what path has the collector
-- chosen.  It simply looks at an workflow attribute APPROVAL_PATH
-- to determine that.  If it has a value of LIMITS then the path taken
-- is primary, otherwise it is non-primary.

PROCEDURE AMECheckPrimaryApprover(
  p_item_type IN  VARCHAR2,
  p_item_key  IN  VARCHAR2,
  p_actid     IN  NUMBER,
  p_funcmode  IN  VARCHAR2,
  p_result    OUT NOCOPY VARCHAR2) IS

  l_approval_path  wf_item_attribute_values.text_value%TYPE;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered AMECHECKPRIMARYAPPROVER';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('AMECheckPrimaryApprover: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------
  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') THEN

    l_approval_path := wf_engine.getitemattrtext(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'APPROVAL_PATH');

    IF (l_approval_path = 'LIMITS') THEN
      p_result := 'COMPLETE:T';
    ELSE
      p_result := 'COMPLETE:F';
    END if;

    RETURN;

  END IF; -- END of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by RETURNing NULL
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_result := 'COMPLETE:N';
      RETURN;
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'AMECHECKPRIMARYAPPROVER',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END AMECheckPrimaryApprover;

/*************************************************************************/



/*************************************************************************/
-- Written For AME Integration
--
-- This procedure is called to find the the first primary approver,
-- as well as any subsequent approver from AME. After retrieving the
-- person id from AME, it stores in a workflow attribute appropriately
-- named PERSON_ID.  It also cals getemployeeinfo to set some attributes
-- to make sure notifications are sent smoothly to this approver.

PROCEDURE AMEFindPrimaryApprover(
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid     IN  NUMBER,
    p_funcmode  IN  VARCHAR2,
    p_result    OUT NOCOPY VARCHAR2) IS


  l_next_approver         ame_util.approverrecord;
  l_admin_approver        ame_util.approverrecord;
  l_error_message         fnd_new_messages.message_text%TYPE;

  l_approver_employee_id  wf_item_attribute_values.number_value%TYPE;
  l_approver_user_id      wf_item_attribute_values.number_value%TYPE;
  l_escalation_count	  NUMBER;
  l_timeout_occured       VARCHAR2(1) ; /*4139346 */

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered AMEFINDPRIMARYAPPROVER';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('AMEFindPrimaryApprover: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------
  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') THEN

    -- Bug # 4139346
    -- In the case of HR Hierarchy AME is dependent on the first person
    -- in the hierarchy.  However, the approval has moved and the first
    -- is terminated then AME errors out.  In that case, we would like
    -- to make the person's manager as the first person.

    validate_first_approver(p_item_key => p_item_key);

    -- now that we know the first approver is set correctly, go ahead
    -- and fetch the next approver and notice that this calls AME using
    -- c_approvals_transaction_type.

    BEGIN
      FindNextApprover(
        p_item_type    => p_item_type,
        p_item_key     => p_item_key,
        p_ame_trx_type => c_approvals_transaction_type,
        x_approver_user_id => l_approver_user_id,
        x_approver_employee_id => l_approver_employee_id);

    EXCEPTION
      WHEN OTHERS THEN

        -- Bug # 3865317.
        --
        -- We are anticapting that AME will raise the following exception if
        -- if the last approver times out:
        --
        -- "ORA-20001: AN APPROVER LACKED A SURROGATE, EITHER BECAUSE THEY WERE
        --  NOT IN ANY OF THE REQUIRED APPROVAL GROUPS OR BECAUSE THEY WERE THE
        --  FINAL APPROVER IN ONE OF THE REQUIRED APPROVAL GROUPS."
        --
        -- In this case we need to identify that this is the case and handle it
        -- correctly.  We need to check if we are operating under timeout mode,
        -- if so then the last approver has timed out and we do not know who to
        -- send the approval to. So, we should error out and send notification
        -- to SYSADMIN.

        l_timeout_occured := wf_engine.GetItemAttrText(
          itemtype => p_item_type,
          itemkey  => p_item_key,
          aname    => 'TIMEOUT_OCCURRED');

        IF NVL(l_timeout_occured,'N') = 'Y' THEN
          p_result := 'COMPLETE:E';
          RETURN;
        ELSE
          -- if that is not the case, then this is an unexpected case
          -- raise the exception.
          RAISE;
        END IF;

    END;

    IF (l_approver_user_id IS NOT NULL) THEN

      -- Bug # 3865317.
      -- We need to reset a flag to indicate that we are no
      -- longer in a timeout mode.

      wf_engine.setitemattrtext(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'TIMEOUT_OCCURRED',
        avalue   => 'N');

      l_escalation_count := wf_engine.getitemattrnumber(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'ESCALATION_COUNT');

      IF (l_escalation_count <> 0) THEN
        SkipIFDuplicate(
          p_item_type            => p_item_type,
          p_item_key             => p_item_key,
          p_ame_trx_type         => c_approvals_transaction_type,
          p_approver_user_id     => l_approver_user_id,
          p_approver_employee_id => l_approver_employee_id,
          x_approver_user_id     => l_approver_user_id,
          x_approver_employee_id => l_approver_employee_id);
      END IF;

    END IF;

    IF l_approver_user_id IS NULL THEN

      -- end of hub, reset the scalation related attributes.
      wf_engine.setitemattrnumber(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'MANAGER_ID',
        avalue   => -9999);

      wf_engine.setitemattrnumber(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'ESCALATION_COUNT',
        avalue   => 0);

      -- no issue, return F to indicate no more approvers left.
      p_result := 'COMPLETE:F';
      RETURN;

    END IF;

    -- The following call will set the following attributes:
    --
    -- 1. APPROVER_ID
    -- 2. APPROVER_USER_NAME
    -- 3. APPROVER_DISPLAY_NAME

    getemployeeinfo(
      p_user_id               => l_approver_user_id,
      p_item_type             => p_item_type,
      p_item_key              => p_item_key);

    p_result := 'COMPLETE:T';

    RETURN;

  END IF; -- END of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning NULL
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'AMEFINDPRIMARYAPPROVER',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END AMEFindPrimaryApprover;

/*************************************************************************/

/*************************************************************************/
-- Written For AME Integration
--
-- This procedure is called to retrieve the person selected by the collector
-- to be first person in HR hierarchy. Using the retrieved user name, it then
-- computes the employee and user id.  It checks to see if this guy is truely
-- in HR.  This function does another important task of indicating the first
-- person in the supervisory hierarchy.  It assigns person id to a workflow
-- attribute named NON_DEFAULT_START_PERSON_ID, which will be used to derive
-- the value of SUPERVISORY_NON_DEFAULT_STARTING_POINT_PERSON_ID.

PROCEDURE AMESetNonPrimaryApprover(
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid     IN  NUMBER,
    p_funcmode  IN  VARCHAR2,
    p_result    OUT NOCOPY VARCHAR2) IS

  l_approver_id         fnd_user.user_id%TYPE;
  l_employee_id		fnd_user.employee_id%TYPE;
  l_approver_user_name  wf_item_attribute_values.text_value%TYPE;

  CURSOR c (p_user_name VARCHAR2) IS
    SELECT employee_id, user_id
    FROM   fnd_user
    WHERE  user_name = p_user_name;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered AMESETNONPRIMARYAPPROVER';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('AMESetNonPrimaryApprover: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------
  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') THEN

    l_approver_user_name  := wf_engine.GetItemAttrText(
       itemtype => p_item_type,
       itemkey  => p_item_key,
       aname    => 'ROLE');

    OPEN  c (l_approver_user_name);
    FETCH c INTO l_employee_id, l_approver_id;
    CLOSE c;

    -- set employee id as the non_default_starting_point_person_id.
    -- This is used as the value for the following attributes:
    --
    --   SUPERVISORY_NON_DEFAULT_STARTING_POINT_PERSON_ID
    --   JOB_LEVEL_NON_DEFAULT_STARTING_POINT_PERSON_ID
    --
    -- If this is not populated here supervisory and job level
    -- hierarchy would not work.

    wf_engine.setitemattrnumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'NON_DEFAULT_START_PERSON_ID',
      avalue   => l_employee_id);

    p_result := 'COMPLETE:';

    RETURN;

  END IF;

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by RETURNing NULL
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'AMESETNONPRIMARYAPPROVER',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END AMESetNonPrimaryApprover;


/*************************************************************************/


/*************************************************************************/
-- Written For AME Integration
--
-- This procedure is called to find the first non primary approver.
-- It then stores person in a workflow attribute appropriately named
-- PERSON_ID.  It also cals getemployeeinfo to set some attributes
-- to make sure notifications are sent smoothly to this approver.

PROCEDURE AMEFindNonPrimaryApprover(
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid     IN  NUMBER,
    p_funcmode  IN  VARCHAR2,
    p_result    OUT NOCOPY VARCHAR2) IS

  l_next_approver         ame_util.approverrecord;
  l_admin_approver        ame_util.approverrecord;
  l_error_message         fnd_new_messages.message_text%TYPE;
  l_count		  NUMBER;

  l_approver_employee_id  wf_item_attribute_values.number_value%TYPE;
  l_approver_user_id      wf_item_attribute_values.number_value%TYPE;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered AMEFINDNONPRIMARYAPPROVER';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('AMEFindNonPrimaryApprover: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------
  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') THEN

    -- Notice that this calls AME using c_approvals_transaction_type.
    FindNextApprover(
      p_item_type    => p_item_type,
      p_item_key     => p_item_key,
      p_ame_trx_type => c_approvals_transaction_type,
      x_approver_user_id => l_approver_user_id,
      x_approver_employee_id => l_approver_employee_id);

    IF l_approver_user_id IS NULL THEN
      p_result := 'COMPLETE:F';
      RETURN;
    END IF;

    getemployeeinfo(
      p_user_id               => l_approver_user_id,
      p_item_type             => p_item_type,
      p_item_key              => p_item_key);

    p_result := 'COMPLETE:T';

    RETURN;

  END IF; -- END of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by RETURNing NULL
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'AMEFINDNONPRIMARYAPPROVER',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END AMEFindNonPrimaryApprover;


/*************************************************************************/

/*************************************************************************/
-- Written For AME Integration
--
-- This procedure is called to find the subsequent non primary approvers.
-- It also stores person in a workflow attribute appropriately named
-- PERSON_ID.  It also cals getemployeeinfo to set some attributes
-- to make sure notifications are sent smoothly to this approver.

/*4139346 */
PROCEDURE AMEFindNextNonPrimaryApprover (
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid     IN  NUMBER,
    p_funcmode  IN  VARCHAR2,
    p_result    OUT NOCOPY VARCHAR2) IS

  l_debug_info            VARCHAR2(200);
  l_approver_id           NUMBER;
  l_approver_display_name wf_users.display_name%TYPE;
  l_approver_user_name     wf_users.name%TYPE;
  l_count		  NUMBER;

  l_approver_employee_id  wf_item_attribute_values.number_value%TYPE;
  l_approver_user_id      wf_item_attribute_values.number_value%TYPE;
  l_timeout_occured       VARCHAR2(1) ; /*4139346 */
  l_escalation_count	  NUMBER;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered AMEFINDNEXTNONPRIMARYAPPROVER';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('AMEFindNextNonPrimaryApprover: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------
  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') THEN

    -- Bug # 4139346
    -- In the case of HR Hierarchy AME is dependent on the first person
    -- in the hierarchy.  However, the approval has moved and the first
    -- is terminated then AME errors out.  In that case, we would like
    -- to make the person's manager as the first person.

    validate_first_approver(p_item_key => p_item_key);

    -- now that we know the first approver is set correctly, go ahead
    -- and fetch the next approver.

    BEGIN

      FindNextApprover(
        p_item_type    => p_item_type,
        p_item_key     => p_item_key,
        p_ame_trx_type => c_approvals_transaction_type,
        x_approver_user_id => l_approver_user_id,
        x_approver_employee_id => l_approver_employee_id);

    EXCEPTION
      WHEN OTHERS THEN

        -- Bug # 3865317.
        --
        -- We are anticapting that AME will raise the following exception if
        -- if the last approver times out:
        --
        -- "ORA-20001: AN APPROVER LACKED A SURROGATE, EITHER BECAUSE THEY WERE
        --  NOT IN ANY OF THE REQUIRED APPROVAL GROUPS OR BECAUSE THEY WERE THE
        --  FINAL APPROVER IN ONE OF THE REQUIRED APPROVAL GROUPS."
        --
        -- In this case we need to identify that this is the case and handle it
        -- correctly.  We need to check if we are operating under timeout mode,
        -- if so then the last approver has timed out and we do not know who to
        -- send the approval to. So, we should error out and send notification
        -- to SYSADMIN.

        l_timeout_occured := wf_engine.GetItemAttrText(
          itemtype => p_item_type,
          itemkey  => p_item_key,
          aname    => 'TIMEOUT_OCCURRED');

        IF NVL(l_timeout_occured,'N') = 'Y' THEN
          p_result := 'COMPLETE:E';
          RETURN;
        ELSE
          -- if that is not the case, then this is an unexpected case
          -- raise the exception.
          RAISE;
        END IF;

    END;

    IF (l_approver_user_id IS NOT NULL) THEN

      -- Bug # 3865317.
      -- We need to reset a flag to indicate that we are no
      -- longer in a timeout mode.

      wf_engine.setitemattrtext(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'TIMEOUT_OCCURRED',
        avalue   => 'N');

      l_escalation_count := wf_engine.getitemattrnumber(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'ESCALATION_COUNT');

      IF (l_escalation_count <> 0) THEN
        SkipIFDuplicate(
          p_item_type            => p_item_type,
          p_item_key             => p_item_key,
          p_ame_trx_type         => c_approvals_transaction_type,
          p_approver_user_id     => l_approver_user_id,
          p_approver_employee_id => l_approver_employee_id,
          x_approver_user_id     => l_approver_user_id,
          x_approver_employee_id => l_approver_employee_id);
      END IF;
    END IF;

    IF l_approver_user_id IS NULL THEN

      -- end of hub, reset the scalation related attributes.
      wf_engine.setitemattrnumber(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'MANAGER_ID',
        avalue   => -9999);

      wf_engine.setitemattrnumber(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'ESCALATION_COUNT',
        avalue   => 0);

      -- no issue, return F to indicate no more approvers left.
      p_result := 'COMPLETE:F';
      RETURN;
    END IF;

    wf_engine.SetItemAttrNumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'PERSON_ID',
      avalue   => l_approver_employee_id);

      -- get employee info works if you pass user id

    l_approver_id := get_user_id(
      p_employee_id => l_approver_employee_id);

    g_debug_mesg := 'Approver ID: ' || l_approver_id;

    getemployeeinfo(
      p_user_id               => l_approver_id,
      p_item_type             => p_item_type,
      p_item_key              => p_item_key);

    p_result := 'COMPLETE:T';

    RETURN;

  END IF; -- END of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  IF (p_funcmode = 'CANCEL') THEN

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;

  END IF;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by RETURNing NULL
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'AMEFINDNEXTNONPRIMARYAPPROVER',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END AMEFindNextNonPrimaryApprover;

/*************************************************************************/




/*************************************************************************/
-- Written For AME Integration
--
-- This is the procedure that gets called if we do not hear from the approver.
-- We let AME know that the approver has not responded, and the we retrieve
-- manager's information based on the person id of the nonresponsive approver
-- and set appropriate attributes to notify him.

PROCEDURE AMEFindManager  (p_item_type IN  VARCHAR2,
                           p_item_key  IN  VARCHAR2,
                           p_actid     IN  NUMBER,
                           p_funcmode  IN  VARCHAR2,
                           p_result    OUT NOCOPY VARCHAR2) IS


  CURSOR manager (p_employee_id NUMBER) IS
    SELECT supervisor_id
    FROM   per_all_assignments_f
    WHERE  person_id = p_employee_id
    AND    primary_flag = 'Y' -- get primary assgt
    AND    assignment_type = 'E' -- ensure emp assgt, not applicant assgt
    AND    trunc(sysdate) BETWEEN effective_start_date
                          AND     effective_end_date;


  l_approval_path               wf_item_attribute_values.text_value%TYPE;
  l_nonresponsive_employee_id   fnd_user.employee_id%TYPE;
  l_nonresponsive_user_id       fnd_user.user_id%TYPE;
  l_nonresponsive_user_name     wf_users.name%TYPE;
  l_nonresponsive_display_name  wf_users.display_name%TYPE;
  l_manager_employee_id         fnd_user.employee_id%TYPE;
  l_manager_user_name           wf_users.name%TYPE;
  l_manager_display_name        wf_users.display_name%TYPE;
  l_escalation_count	        NUMBER;
  l_transaction_type            VARCHAR2(30);

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered AMEFINDMANAGER';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('AMEFindManager: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------
  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') THEN

    -- First record the fact with AME that the current approver
    -- has not responded to the notification.  This way when
    -- we call getnextapprover it will give us the next approver
    -- not the current approver back.

    -- However, for Limits Only path, to work around a AME limitation
    -- we must pass approved status to AME,  so that AME does not try
    -- to find a manager and error out.

    l_approval_path := wf_engine.getitemattrtext(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'APPROVAL_PATH');

    l_transaction_type := wf_engine.GetItemAttrText(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'CURRENT_HUB');

    g_debug_mesg := 'Approval Path: ' || l_approval_path;


    -- If the transaction type is anything other approval transaction
    -- type dont even respond.

    IF (l_transaction_type = c_approvals_transaction_type) THEN

      IF (l_approval_path = 'HR') THEN
        RecordResponseWithAME (
          p_item_type => p_item_type,
          p_item_key  => p_item_key,
          p_response  => ame_util.noResponseStatus);
      END IF;

    END IF;


    -- Determine the number of escalations.  It is possible that the
    -- current approver does not respond.  The notification is sent
    -- to his/her manager and he/she too may not respond.  In that case
    -- notification has be to sent to the manager's manager in a recursive
    -- manner.

    l_escalation_count := wf_engine.getitemattrnumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'ESCALATION_COUNT');

    IF l_escalation_count=0 THEN

      l_nonresponsive_user_id := wf_engine.getitemattrnumber(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'APPROVER_ID');

      l_nonresponsive_employee_id := get_employee_id(l_nonresponsive_user_id);

    ELSE
      l_nonresponsive_employee_id := wf_engine.getitemattrnumber(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'MANAGER_ID');
    END IF;

    l_escalation_count := l_escalation_count + 1;

    wf_engine.setitemattrnumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'ESCALATION_COUNT',
      avalue   => l_escalation_count);

    -- When the escalation notfication is sent to the manager, the manager
    -- must know who did not respond to the notification. So, we must
    -- update/populate some attributes so that notification will contain that
    -- information.

    g_debug_mesg := 'Getting User Name: ';

    wf_directory.getusername(
      'PER',
      to_char(l_nonresponsive_employee_id),
      l_nonresponsive_user_name,
      l_nonresponsive_display_name);

    wf_engine.setitemattrnumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'FORWARD_FROM_ID',
      avalue   => l_nonresponsive_user_id);

    wf_engine.setitemattrtext(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'FORWARD_FROM_USER_NAME',
      avalue   => l_nonresponsive_user_name);

    wf_engine.setitemattrtext(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'FORWARD_FROM_DISPLAY_NAME',
      avalue   => l_nonresponsive_display_name);

    -- Now get the manager for the nonresponsive approver.

    g_debug_mesg := 'Nonresponsive Employee ID: ' ||
      l_nonresponsive_employee_id ;

    OPEN  manager(l_nonresponsive_employee_id);
    FETCH manager INTO l_manager_employee_id;
    CLOSE manager;

    IF l_manager_employee_id IS NULL THEN

      p_result := 'COMPLETE:F';
      RETURN;

    ELSE
      wf_engine.setitemattrnumber(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'MANAGER_ID',
        avalue   => l_manager_employee_id);

      wf_directory.getusername(
        'PER',
        to_char(l_manager_employee_id),
        l_manager_user_name,
        l_manager_display_name);

      wf_engine.setitemattrtext(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'MANAGER_USER_NAME',
        avalue   => l_manager_user_name);

      wf_engine.setitemattrtext(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'MANAGER_DISPLAY_NAME',
        avalue   => l_manager_display_name);

      p_result := 'COMPLETE:T';
      RETURN;

    END IF;

  END IF;

  IF (p_funcmode = 'CANCEL') THEN
    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'AMEFINDMANAGER',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END AMEFindManager;


PROCEDURE RecordCollectorAsForwardFrom(p_item_type        IN  VARCHAR2,
                                       p_item_key         IN  VARCHAR2,
                                       p_actid            IN  NUMBER,
                                       p_funcmode         IN  VARCHAR2,
                                       p_result           OUT NOCOPY VARCHAR2) IS

 l_collector_employee_id           NUMBER;
 l_collector_display_name          wf_users.display_name%TYPE;
 l_collector_user_name              wf_users.name%TYPE;
 l_notes                           wf_item_attribute_values.text_value%TYPE;
 l_approver_notes                  wf_item_attribute_values.text_value%TYPE;
 CRLF        			   VARCHAR2(1);

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered RECORDCOLLECTORASFORWARDFROM';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('RecordCollectorAsForwardFrom: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------
  --
  -- Bug 2105483 : rather then calling arp_global at the start
  -- of the package, WHERE it can error out NOCOPY since org_id is not yet set,
  -- do the call right before it is needed

  -- arp_global.init_global;
  CRLF := arp_global.CRLF;

  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     g_debug_mesg := 'Get the user name of collector';
     ------------------------------------------------------------


     l_collector_employee_id   := wf_engine.GetItemAttrNumber(
                                                      p_item_type,
                                                      p_item_key,
                                                      'COLLECTOR_EMPLOYEE_ID');
     wf_engine.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'FORWARD_FROM_ID',
                                 l_collector_employee_id);





     l_collector_user_name    := wf_engine.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'COLLECTOR_USER_NAME');
     wf_engine.SetItemAttrText(p_item_type,
                               p_item_key,
                              'FORWARD_FROM_USER_NAME',
                              l_collector_user_name);


     l_collector_display_name  := wf_engine.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'COLLECTOR_DISPLAY_NAME');
     wf_engine.SetItemAttrText(p_item_type,
                               p_item_key,
                               'FORWARD_FROM_DISPLAY_NAME',
                               l_collector_display_name);

     -- Add the collector user name in front of notes field.



     l_approver_notes          :=  wf_engine.GetItemAttrText(p_item_type,
                                                      p_item_key,
                                                     'APPROVER_NOTES');

     l_notes                   := l_collector_user_name  ||
                                  ': ' || l_approver_notes  || CRLF;

     wf_engine.SetItemAttrText(p_item_type,
                               p_item_key,
                               'NOTES',
                               l_notes);

     -- Initialize the approver_notes

    l_approver_notes          := NULL;

    wf_engine.SetItemAttrText(p_item_type,
                               p_item_key,
                               'APPROVER_NOTES',
                               l_approver_notes);


    -- end of hub, reset the scalation related attributes.
    wf_engine.setitemattrnumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'MANAGER_ID',
      avalue   => -9999);

    wf_engine.setitemattrnumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'ESCALATION_COUNT',
      avalue   => 0);

    p_result := 'COMPLETE:T';
    RETURN;

  END if; -- END of run mode

  --
  -- CANCEL mode
  --

  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'RECORDCOLLECTORASFORWARDFROM',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END RecordCollectorAsForwardFrom;


PROCEDURE RecordForwardToUserInfo(p_item_type        IN  VARCHAR2,
                                  p_item_key         IN  VARCHAR2,
                                  p_actid            IN  NUMBER,
                                  p_funcmode         IN  VARCHAR2,
                                  p_result           OUT NOCOPY VARCHAR2) IS


  l_approver_id                    NUMBER;
  l_approver_display_name          wf_users.display_name%TYPE;
  l_approver_user_name              wf_users.name%TYPE;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered RECORDFORWARDTOUSERINFO';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('RecordForwardToUserInfo: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------
  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     g_debug_mesg := 'Get the user name of approver';
     ------------------------------------------------------------

     l_approver_id := wf_engine.GetItemAttrNumber(
       p_item_type,
       p_item_key,
       'APPROVER_ID');

     wf_engine.SetItemAttrNumber(
       p_item_type,
       p_item_key,
       'FORWARD_TO_ID',
       l_approver_id);

     l_approver_user_name := wf_engine.GetItemAttrText(
       p_item_type,
       p_item_key,
       'APPROVER_USER_NAME');

     wf_engine.SetItemAttrText(
       p_item_type,
       p_item_key,
       'FORWARD_TO_USER_NAME',
       l_approver_user_name);


     l_approver_display_name  := wf_engine.GetItemAttrText(
       p_item_type,
       p_item_key,
       'APPROVER_DISPLAY_NAME');

     wf_engine.SetItemAttrText(
       p_item_type,
       p_item_key,
       'FORWARD_TO_DISPLAY_NAME',
       l_approver_display_name);

   p_result := 'COMPLETE:T';

   RETURN;

  END if; -- END of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by RETURNing NULL
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN


      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'RECORDFORWARDTOUSERINFO',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END RecordForwardToUserInfo;


PROCEDURE CheckForwardFromUser(p_item_type        IN  VARCHAR2,
                               p_item_key         IN  VARCHAR2,
                               p_actid            IN  NUMBER,
                               p_funcmode         IN  VARCHAR2,
                               p_result           OUT NOCOPY VARCHAR2) IS

  l_forward_from_user_name             VARCHAR2(100);

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered CHECKFORWARDFROMUSER';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('CheckForwardFromUser: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------
  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     g_debug_mesg := 'Get the user name of forward from user';
     ------------------------------------------------------------

     l_forward_from_user_name    := wf_engine.GetItemAttrText(
                                                     p_item_type,
                                                     p_item_key,
                                                     'FORWARD_FROM_USER_NAME');


     IF  l_forward_from_user_name is NOT NULL then
       p_result := 'COMPLETE:T';
       RETURN;
     ELSE
       p_result := 'COMPLETE:F';
       RETURN;
     END if;

  END if; -- END of run mode

  --
  -- CANCEL mode
  --
  --
  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution mode

  p_result := '';
  RETURN;

  EXCEPTION
     WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'CHECKFORWARDFROMUSER',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END CheckForwardFromUser;


PROCEDURE RecordApproverAsForwardFrom(p_item_type         IN  VARCHAR2,
                                       p_item_key         IN  VARCHAR2,
                                       p_actid            IN  NUMBER,
                                       p_funcmode         IN  VARCHAR2,
                                       p_result           OUT NOCOPY VARCHAR2) IS

  l_approver_id               NUMBER;
  l_approver_user_name         wf_users.name%TYPE;
  l_approver_display_name     wf_users.display_name%TYPE;
  l_notes                     wf_item_attribute_values.text_value%TYPE;
  l_approver_notes            wf_item_attribute_values.text_value%TYPE;
  CRLF    		      VARCHAR2(1);

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered RECORDAPPROVERASFORWARDFROM';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('RecordApproverAsForwardFrom: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  -- Bug 2105483 : rather then calling arp_global at the start
  -- of the package, WHERE it can error out since org_id is not yet set,
  -- do the call right before it is needed

  -- arp_global.init_global;
  CRLF := arp_global.CRLF;

  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     g_debug_mesg := 'Get info for an approver';
     ------------------------------------------------------------



     l_approver_id         := wf_engine.GetItemAttrNumber(p_item_type,
                                                          p_item_key,
                                                          'APPROVER_ID');
     wf_engine.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'FORWARD_FROM_ID',
                                 l_approver_id);



     l_approver_user_name    := wf_engine.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'APPROVER_USER_NAME');
     wf_engine.SetItemAttrText(p_item_type,
                               p_item_key,
                              'FORWARD_FROM_USER_NAME',
                              l_approver_user_name);


     l_approver_display_name    := wf_engine.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'APPROVER_DISPLAY_NAME');
     wf_engine.SetItemAttrText(p_item_type,
                               p_item_key,
                               'FORWARD_FROM_DISPLAY_NAME',
                               l_approver_display_name);

      -- Add the approver user name in front of notes field.

     l_notes                   :=  wf_engine.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'NOTES');

     l_approver_notes          :=  wf_engine.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'APPROVER_NOTES');


     l_notes                   := l_notes ||  l_approver_user_name ||
                                  ': ' || l_approver_notes || CRLF;

     wf_engine.SetItemAttrText(p_item_type,
                               p_item_key,
                               'NOTES',
                               l_notes);

    -- Initialize the approver_notes

    l_approver_notes          := NULL;

    wf_engine.SetItemAttrText(p_item_type,
                               p_item_key,
                               'APPROVER_NOTES',
                               l_approver_notes);



   p_result := 'COMPLETE:T';
   RETURN;

  END if; -- END of run mode

  --
  -- CANCEL mode
  --

  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'RECORDAPPROVERASFORWARDFROM',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END RecordApproverAsForwardFrom;


PROCEDURE CheckFinalApprover(p_reason_code                 IN  VARCHAR2,
                             p_currency_code               IN  VARCHAR2,
                             p_amount	 	           IN  VARCHAR2,
                             p_approver_id                 IN  NUMBER,
                             p_result_flag                 OUT NOCOPY VARCHAR2) IS

  l_amount_to     NUMBER;
  l_amount_from   NUMBER;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered CHECKFINALAPPROVER';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('CheckFinalApprover: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  SELECT aul.amount_to, aul.amount_from INTO  l_amount_to, l_amount_from
  FROM ar_approval_user_limits aul
  WHERE aul.user_id     = p_approver_id
  AND aul.reason_code   = p_reason_code
  AND aul.currency_code = p_currency_code ;

  IF ( ( p_amount <   l_amount_to) and
       ( p_amount >=  l_amount_from)) then

    p_result_flag := 'Y';

  ELSE

      p_result_flag := 'N';
  END IF ;

  RETURN;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       p_result_flag := 'N';
       RETURN;

     WHEN OTHERS THEN

       wf_core.context(
         pkg_name  => 'AR_AME_CMWF_API',
         proc_name => 'CHECKFINALAPPROVER',
         arg1      => c_item_type,
         arg2      => NULL,
         arg3      => NULL,
         arg4      => NULL,
         arg5      => g_debug_mesg);

       RAISE;

END CheckFinalApprover;


PROCEDURE RemoveFromDispute     (p_item_type        IN  VARCHAR2,
                                 p_item_key         IN  VARCHAR2,
                                 p_actid            IN  NUMBER,
                                 p_funcmode         IN  VARCHAR2,
                                 p_result           OUT NOCOPY VARCHAR2) IS

 l_approver_id                NUMBER;
 l_reason_code                VARCHAR2(45);
 l_currency_code              VARCHAR2(15);
 l_total_credit_to_invoice    NUMBER;
 l_result_flag                VARCHAR2(1);
 l_customer_trx_id            NUMBER;

 /* bug 4469453 */
 l_request_id                 number;
 new_dispute_date             date;
 new_dispute_amt              number;
 remove_from_dispute_amt      number;

/*4432212 */

CURSOR ps_cur(p_customer_trx_id NUMBER) IS
      SELECT payment_schedule_id, due_date, amount_in_dispute, dispute_date
        FROM ar_payment_schedules ps
       WHERE ps.customer_trx_id = p_customer_trx_id;


BEGIN


  ----------------------------------------------------------
  g_debug_mesg := 'Entered REMOVEFROMDISPUTE';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('RemoveFromDispute: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then

        l_customer_trx_id   := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

        l_request_id  := WF_ENGINE.GetItemAttrNumber(
                                    p_item_type,
                                    p_item_key,
                                    'WORKFLOW_DOCUMENT_ID');

        -- the amount stored in ra_cm_requests is the Credit amount, it needs to
        -- be negated to get the correct dispute amount
        SELECT total_amount  * -1
          into remove_from_dispute_amt
          from ra_cm_requests
         WHERE request_id = l_request_id;


     /*4432212 */
      BEGIN

         FOR ps_rec  IN ps_cur (l_customer_trx_id )
         LOOP

               new_dispute_amt := ps_rec.amount_in_dispute - remove_from_dispute_amt;

               if new_dispute_amt = 0 then
                  new_dispute_date := null;
               else
                  new_dispute_date := ps_rec.dispute_date;
               end if;


                arp_process_cutil.update_ps
                     (p_ps_id=> ps_rec.payment_schedule_id,
	              p_due_date=> ps_rec.due_date,
                      p_amount_in_dispute=> new_dispute_amt,
                      p_dispute_date=> new_dispute_date,
                      p_update_dff => 'N',
	              p_attribute_category=>NULL,
	              p_attribute1=>NULL,
	              p_attribute2=>NULL,
	              p_attribute3=>NULL,
	              p_attribute4=>NULL,
	              p_attribute5=>NULL,
	              p_attribute6=>NULL,
	              p_attribute7=>NULL,
	              p_attribute8=>NULL,
	              p_attribute9=>NULL,
	              p_attribute10=>NULL,
	              p_attribute11=>NULL,
	              p_attribute12=>NULL,
	              p_attribute13=>NULL,
	              p_attribute14=>NULL,
	              p_attribute15=>NULL );

         END LOOP;
      END;

    l_reason_code    := wf_engine.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'REASON');

   l_currency_code   := wf_engine.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'CURRENCY_CODE');

   l_total_credit_to_invoice
                      := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'TOTAL_CREDIT_TO_INVOICE');



    l_approver_id      := wf_engine.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'APPROVER_ID');

    CheckFinalApprover(l_reason_code,
                       l_currency_code,
                       l_total_credit_to_invoice,
                       l_approver_id,
                       l_result_flag);



   IF (l_result_flag = 'Y')  then

     -- it is a final aprrover
     p_result := 'COMPLETE:T';
     RETURN;
   ELSE
     p_result := 'COMPLETE:F';
     RETURN;
   END if;

  END if; -- END of run mode

  --
  -- CANCEL mode
  --

  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'REMOVEFROMDISPUTE',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END RemoveFromDispute;


/****************************************************************************/
--
-- This procedure is called to find the Receivable user.
-- Notice that this calls AME using c_receivable_transaction_type.

PROCEDURE AMEFindReceivableApprover(
  p_item_type        IN  VARCHAR2,
  p_item_key         IN  VARCHAR2,
  p_actid            IN  NUMBER,
  p_funcmode         IN  VARCHAR2,
  p_result           OUT NOCOPY VARCHAR2) IS

  l_next_approver         ame_util.approverrecord;
  l_admin_approver        ame_util.approverrecord;
  l_error_message         VARCHAR2(2000);

  l_approver_employee_id  wf_item_attribute_values.number_value%TYPE;
  l_approver_user_id      wf_item_attribute_values.number_value%TYPE;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered FINDRECEIVABLEROLE';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('AMEFindReceivableApprover: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then

     -----------------------------------------------------------------
     g_debug_mesg := 'Check if Receivable Approver has been defined';
     -----------------------------------------------------------------

    FindNextApprover(
      p_item_type    => p_item_type,
      p_item_key     => p_item_key,
      p_ame_trx_type => c_receivable_transaction_type,
      x_approver_user_id => l_approver_user_id,
      x_approver_employee_id => l_approver_employee_id);

    IF l_approver_user_id IS NULL THEN
      p_result := 'COMPLETE:F';
      RETURN;
    END IF;

    wf_engine.SetItemAttrText(
      itemtype => c_item_type,
      itemkey  => p_item_key,
      aname    => 'CURRENT_HUB',
      avalue   => c_receivable_transaction_type);

    -- The following call will set the following attributes:
    --
    -- 1. APPROVER_ID
    -- 2. APPROVER_USER_NAME
    -- 3. APPROVER_DISPLAY_NAME

    getemployeeinfo(
      p_user_id               => l_approver_user_id,
      p_item_type             => p_item_type,
      p_item_key              => p_item_key);

    p_result := 'COMPLETE:T';

    RETURN;

  END if; -- END of run mode

  --
  -- CANCEL mode
  --
  --
  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning NULL
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'AMEFINDRECEIVABLEAPPROVER',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END AMEFindReceivableApprover;

/*****************************************************************************/


PROCEDURE FindResponder         (p_item_type        IN  VARCHAR2,
                                 p_item_key         IN  VARCHAR2,
                                 p_actid            IN  NUMBER,
                                 p_funcmode         IN  VARCHAR2,
                                 p_result           OUT NOCOPY VARCHAR2) IS

  l_approver_id		NUMBER;
  l_approver_user_name    wf_users.name%TYPE;
  l_approver_display_name wf_users.display_name%TYPE;
  l_notification_id	NUMBER;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered FINDRSPONDER';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('FindResponder: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RESPOND') then

     -----------------------------------------------------------------
     g_debug_mesg := 'Find user in Receivable role who responded to
			the notification';
     -----------------------------------------------------------------

	l_notification_id :=    wf_engine.context_nid;
        l_approver_user_name := wf_engine.context_text;

        SELECT orig_system_id, display_name
	INTO l_approver_id, l_approver_display_name
        FROM wf_users
        WHERE orig_system = 'PER'
        AND   name = l_approver_user_name;

        wf_engine.SetItemAttrText(p_item_type,
                                      p_item_key,
                                      'APPROVER_ID',
                                      l_approver_id);

         wf_engine.SetItemAttrText(p_item_type,
                                      p_item_key,
                                      'APPROVER_USER_NAME',
                                      l_approver_user_name);

	 wf_engine.SetItemAttrText(p_item_type,
                                      p_item_key,
                                      'APPROVER_DISPLAY_NAME',
                                      l_approver_display_name);

   	p_result := 'COMPLETE:T';
   	RETURN;

  END if; -- END of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by RETURNing NULL
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'FINDRESPONDER',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END FindResponder;

/*7367350 Changed procedure to insert note in Invoice maintenance notes.
          A new note is inserted in for internal comment     */
PROCEDURE InsertSubmissionNotes(p_item_type        IN  VARCHAR2,
                                p_item_key         IN  VARCHAR2,
                                p_actid            IN  NUMBER,
                                p_funcmode         IN  VARCHAR2,
                                p_result           OUT NOCOPY VARCHAR2) IS

  l_document_id                NUMBER;
  l_requestor_user_name         wf_users.name%TYPE;
  l_customer_trx_id            NUMBER;
  l_note_id                    NUMBER;
  l_reason_code                VARCHAR2(45);
  l_total_credit_to_invoice    NUMBER;
  l_note_text                  ar_notes.text%type;
  /*Bug3206020 Changed comments size from 240 to 1760. */
  l_comments                   VARCHAR2(1760);
  l_reason_meaning             VARCHAR2(100);

   /*7367350*/
   l_internal_comment           VARCHAR2(1760) DEFAULT NULL;
   l_note_text1                  ar_notes.text%type;
   l_comment_type              VARCHAR2(20);

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered INSERTSUBMISSIONNOTES';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('InsertSubmissionNotes: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then


    l_document_id    := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_requestor_user_name
                     := wf_engine.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'REQUESTOR_USER_NAME');


    l_reason_code    := wf_engine.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'REASON');


    l_total_credit_to_invoice
                      := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'TOTAL_CREDIT_TO_INVOICE');


    l_customer_trx_id   := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_comments         := wf_engine.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'COMMENTS');

    /*7367350 Retrieve internal comment*/
    l_internal_comment     := wf_engine.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'INTERNAL_COMMENTS');

    -- bug fix 1202680 -- notes should reflect meaning and not the code.

    BEGIN
        SELECT meaning into l_reason_meaning
        from ar_lookups
        WHERE lookup_type = 'CREDIT_MEMO_REASON'
          and lookup_code = l_reason_code;
    EXCEPTION
        when others then
            l_reason_meaning := l_reason_code;
    END;

    fnd_message.set_name('AR', 'AR_WF_SUBMISSION');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('REQUESTOR',  l_requestor_user_name);
    fnd_message.set_token('AMOUNT',     to_char(l_total_credit_to_invoice));
    fnd_message.set_token('REASON',     l_reason_meaning);

    l_note_text := fnd_message.get;
    l_note_text1 := l_note_text;

    IF l_comments is NOT NULL then
	  select meaning into l_comment_type
 	  from ar_lookups
	  where  LOOKUP_TYPE='AR_COMMENT_CLASSIFICATION'
	  AND    LOOKUP_CODE='C';
          l_note_text := l_note_text || ' :' || l_comment_type || ':  "' || l_comments || '"';
    END IF;

    /*bug 7367350 Changes to insert internla commen notes in invoice maintenance */
    IF  l_internal_comment  is NOT NULL then
	  select meaning into l_comment_type
 	  from ar_lookups
	  where  LOOKUP_TYPE='AR_COMMENT_CLASSIFICATION'
	  AND    LOOKUP_CODE='I';
  	  l_note_text1 := l_note_text1 || ' :' || l_comment_type || ':  "' || l_internal_comment || '"';

	  		   InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text1,
                        l_note_id);
    END IF;


         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text,
                        l_note_id);




     p_result := 'COMPLETE:T';
     RETURN;


  END if; -- END of run mode

  --
  -- CANCEL mode
  --

  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'INSERTSUBMISSIONNOTES',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END InsertSubmissionNotes;


PROCEDURE InsertApprovalReminderNotes(p_item_type        IN  VARCHAR2,
                                     p_item_key         IN  VARCHAR2,
                                     p_actid            IN  NUMBER,
                                     p_funcmode         IN  VARCHAR2,
                                     p_result           OUT NOCOPY VARCHAR2) IS

  l_document_id                NUMBER;
  l_customer_trx_id            NUMBER;
  l_approver_display_name      wf_users.display_name%TYPE;
  l_note_id                    NUMBER;
  l_note_text                  ar_notes.text%type;
  l_notes                      wf_item_attribute_values.text_value%TYPE;  /*5119049 */

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered INSERTAPPROVALREMINDERNOTES';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('InsertApprovalReminderNotes: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then

    l_document_id    := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_customer_trx_id   := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_approver_display_name
                      := wf_engine.GetItemAttrText(
                                             p_item_type,
                                             p_item_key,
                                             'APPROVER_DISPLAY_NAME');

    l_notes  := wf_engine.GetItemAttrText( p_item_type,  p_item_key,'NOTES'); /*5119049*/

    fnd_message.set_name('AR', 'AR_WF_APPROVAL_REMINDER');
    fnd_message.set_token('APPROVER',     l_approver_display_name);
 -- bug fix 1122477

    l_note_text := fnd_message.get;

    IF l_notes is NOT NULL then
       l_note_text := SUBSTRB(l_note_text || ' "' || l_notes || '"',1,2000) ;  /*5119049*/
    END IF;

         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text,
                        l_note_id);


     p_result := 'COMPLETE:T';
     RETURN;


  END if; -- END of run mode

  --
  -- CANCEL mode
  --

  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'INSERTAPPROVALREMINDERNOTES',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END InsertApprovalReminderNotes;


PROCEDURE InsertEscalationNotes     (p_item_type        IN  VARCHAR2,
                                     p_item_key         IN  VARCHAR2,
                                     p_actid            IN  NUMBER,
                                     p_funcmode         IN  VARCHAR2,
                                     p_result           OUT NOCOPY VARCHAR2) IS

  l_document_id                NUMBER;
  l_customer_trx_id            NUMBER;
  l_manager_user_name         VARCHAR2(100);
  l_note_id                    NUMBER;
  l_note_text                  ar_notes.text%type;
  l_notes                      wf_item_attribute_values.text_value%TYPE;  /*5119049 */

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered INSERTESCAlATIONNOTES';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('InsertEscalationNotes: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then


    l_document_id    := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_customer_trx_id   := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_manager_user_name
                      := wf_engine.GetItemAttrText(
                                             p_item_type,
                                             p_item_key,
                                             'MANAGER_USER_NAME');

    l_notes  := wf_engine.GetItemAttrText( p_item_type,  p_item_key,'NOTES'); /*5119049*/

    fnd_message.set_name('AR', 'AR_WF_APPROVAL_ESCALATION');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('APPROVER',     l_manager_user_name);

    l_note_text := fnd_message.get;


    IF l_notes is NOT NULL then
       l_note_text := SUBSTRB(l_note_text || ' "' || l_notes || '"',1,2000) ;  /*5119049*/
    END IF;
         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text,
                        l_note_id);


     p_result := 'COMPLETE:T';
     RETURN;


  END if; -- END of run mode

  --
  -- CANCEL mode
  --

  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'INSERTESCALATIONNOTES',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END InsertEscalationNotes;


PROCEDURE InsertRequestManualNotes  (p_item_type        IN  VARCHAR2,
                                     p_item_key         IN  VARCHAR2,
                                     p_actid            IN  NUMBER,
                                     p_funcmode         IN  VARCHAR2,
                                     p_result           OUT NOCOPY VARCHAR2) IS

  l_document_id                NUMBER;
  l_customer_trx_id            NUMBER;
  l_receivable_role            VARCHAR2(100);
  l_role_display_name	       wf_users.display_name%TYPE;
  l_note_id                    NUMBER;
  l_note_text                  ar_notes.text%type;
  l_notes                      wf_item_attribute_values.text_value%TYPE;  /*5119049 */

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered INSERTREQUESTMANUALNOTES';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('InsertRequestManualNotes: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then

    l_document_id    := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_customer_trx_id   := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_receivable_role
                      := wf_engine.GetItemAttrText(
                                             p_item_type,
                                             p_item_key,
                                             'RECEIVABLE_ROLE');
    l_notes  := wf_engine.GetItemAttrText( p_item_type,  p_item_key,'NOTES'); /*5119049*/
     SELECT display_name INTO l_role_display_name
     FROM wf_roles
     WHERE name = l_receivable_role;

    fnd_message.set_name('AR', 'AR_WF_REQUEST_MANUAL');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('RECEIVABLE_ROLE',l_role_display_name);

    l_note_text := fnd_message.get;

    IF l_notes is NOT NULL then
       l_note_text := SUBSTRB(l_note_text || ' "' || l_notes || '"',1,2000) ;  /*5119049*/
    END IF;

         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text,
                        l_note_id);


     p_result := 'COMPLETE:T';
     RETURN;


  END if; -- END of run mode

  --
  -- CANCEL mode
  --

  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'INSERTREQUESTMANUALNOTES',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END InsertRequestManualNotes;


PROCEDURE InsertCompletedManualNotes(p_item_type        IN  VARCHAR2,
                                     p_item_key         IN  VARCHAR2,
                                     p_actid            IN  NUMBER,
                                     p_funcmode         IN  VARCHAR2,
                                     p_result           OUT NOCOPY VARCHAR2) IS

  l_document_id                NUMBER;
  l_customer_trx_id            NUMBER;
  l_receivable_role            VARCHAR2(100);
  l_role_display_name	       wf_users.display_name%TYPE;
  l_note_id                    NUMBER;
  l_note_text                  ar_notes.text%type;
  l_notes                      wf_item_attribute_values.text_value%TYPE;  /*5119049 */

  l_last_updated_by     NUMBER;
  l_last_update_login   NUMBER;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered INSERTCOMPLETEDMANUALNOTES';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('InsertCompletedManualNotes: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  -- Bug 2105483 : rather THEN calling arp_global at the start
  -- of the package, WHERE it can error out NOCOPY since org_id is not yet set,
  -- do the call right before it is needed
  -- arp_global.init_global;
  -- Bug 1908252

  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then

    -- restore_context(p_item_key);
    l_last_updated_by   := ARP_GLOBAL.user_id;
    l_last_update_login := ARP_GLOBAL.last_update_login ;

    l_document_id    := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_customer_trx_id   := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_receivable_role
                      := wf_engine.GetItemAttrText(
                                             p_item_type,
                                             p_item_key,
                                             'RECEIVABLE_ROLE');
    l_notes  := wf_engine.GetItemAttrText( p_item_type,  p_item_key,'NOTES'); /*5119049*/

    SELECT display_name INTO l_role_display_name
    FROM wf_roles
    WHERE   name = l_receivable_role;



    fnd_message.set_name('AR', 'AR_WF_COMPLETED_MANUAL');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('APPROVER',l_role_display_name);

    l_note_text := fnd_message.get;

    IF l_notes is NOT NULL then
       l_note_text := SUBSTRB(l_note_text || ' "' || l_notes || '"',1,2000) ;  /*5119049*/
    END IF;

    InsertTrxNotes(NULL,
                   NULL,
                   NULL,
                   l_customer_trx_id,
                   'MAINTAIN',
                   l_note_text,
                   l_note_id);

     -- Bug 1908252 : update last_update* fields
     update ra_cm_requests
	set status = 'COMPLETE',
	    approval_date = SYSDATE,
            last_updated_by = l_last_updated_by,
            last_update_date = SYSDATE,
            last_update_login = l_last_update_login
	WHERE request_id = p_item_key;

     p_result := 'COMPLETE:T';
     RETURN;


  END if; -- END of run mode

  --
  -- CANCEL mode
  --

  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'INSERTCOMPLETEDMANUALNOTES',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END InsertCompletedManualNotes;


PROCEDURE InsertRequestApprovalNotes(p_item_type        IN  VARCHAR2,
                                     p_item_key         IN  VARCHAR2,
                                     p_actid            IN  NUMBER,
                                     p_funcmode         IN  VARCHAR2,
                                     p_result           OUT NOCOPY VARCHAR2) IS

  l_document_id                NUMBER;
  l_customer_trx_id            NUMBER;
  l_approver_display_name      wf_users.display_name%TYPE;
  l_note_id                    NUMBER;
  l_note_text                  ar_notes.text%type;
  l_notes                      wf_item_attribute_values.text_value%TYPE;  /*5119049 */
BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered INSERTREQUESTAPPROVALNOTES';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('InsertRequestApprovalNotes: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------
  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then


    l_document_id    := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_customer_trx_id   := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_approver_display_name
                      := wf_engine.GetItemAttrText(
                                             p_item_type,
                                             p_item_key,
                                             'APPROVER_DISPLAY_NAME');

    l_notes  := wf_engine.GetItemAttrText( p_item_type,  p_item_key,'NOTES'); /*5119049*/

    fnd_message.set_name('AR', 'AR_WF_REQUEST_APPROVAL');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('APPROVER',     l_approver_display_name);
-- bug fix 1122477

    l_note_text := fnd_message.get;

    IF l_notes is NOT NULL then
       l_note_text := SUBSTRB(l_note_text || ' "' || l_notes || '"',1,2000) ;  /*5119049*/
    END IF;

         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text,
                        l_note_id);


     p_result := 'COMPLETE:T';
     RETURN;


  END if; -- END of run mode

  --
  -- CANCEL mode
  --

  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'INSERTREQUESTAPPROVALNOTES',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END InsertRequestApprovalNotes;


PROCEDURE InsertApprovedResponseNotes(p_item_type        IN  VARCHAR2,
                                      p_item_key         IN  VARCHAR2,
                                      p_actid            IN  NUMBER,
                                      p_funcmode         IN  VARCHAR2,
                                      p_result           OUT NOCOPY VARCHAR2) IS

  l_document_id                NUMBER;
  l_customer_trx_id            NUMBER;
  l_approver_display_name      wf_users.display_name%TYPE;
  l_note_id                    NUMBER;
  l_note_text                  ar_notes.text%type;
  l_notes                      wf_item_attribute_values.text_value%TYPE;  /*5119049 */

  l_approver_id NUMBER;
  l_transaction_type VARCHAR2(30);

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered INSERTAPPROVEDRESPONSENOTES';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('InsertApprovedResponseNotes: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  --  arp_standard.enable_debug;
  --  arp_standard.enable_file_debug('/sqlcom/out/findv115',
  --    'OB'|| p_item_key || '.log');
  --  Setorgcontext (p_item_key);

  ---------------------------------------------------------------------
  g_debug_mesg   := 'Insert Approved Response notes';
  ---------------------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then


    l_document_id    := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_customer_trx_id   := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_approver_display_name
                      := wf_engine.GetItemAttrText(
                                             p_item_type,
                                             p_item_key,
                                             'APPROVER_DISPLAY_NAME');
    l_notes  := wf_engine.GetItemAttrText( p_item_type,  p_item_key,'NOTES'); /*5119049*/


    fnd_message.set_name('AR', 'AR_WF_APPROVED_RESPONSE');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('APPROVER',  l_approver_display_name);
    -- bug fix 1122477

    l_note_text := fnd_message.get;

    IF l_notes is NOT NULL then
       l_note_text := SUBSTRB(l_note_text || ' "' || l_notes || '"',1,2000) ;  /*5119049*/
    END IF;
    InsertTrxNotes(NULL,
                   NULL,
                   NULL,
                   l_customer_trx_id,
                   'MAINTAIN',
                   l_note_text,
                   l_note_id);

    /***********************************************************************/
    -- Written For AME Integration
    --
    -- This piece of code communicates to AME and lets it know about the
    -- reponse.

    g_debug_mesg := 'About to call RecordResponseWithAME ';

    RecordResponseWithAME (
      p_item_type => p_item_type,
      p_item_key  => p_item_key,
      p_response  => ame_util.approvedStatus);

    --------------------------------------------------------------------------
    g_debug_mesg := 'InsertApprovedResponseNotes - return from RecordResponse';

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('InsertApprovedResponseNotes: ' || g_debug_mesg);
    END IF;
    ---------------------------------------------------------------------------

    wf_engine.SetItemAttrText(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'CURRENT_HUB',
      avalue   => c_approvals_transaction_type);

    /*************************************************************************/

    p_result := 'COMPLETE:';
    RETURN;

  END if; -- END of run mode

  --
  -- CANCEL mode
  --

  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;

  --
  -- Other execution modes
  --

  p_result := 'COMPLETE:';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'INSERTAPPROVEDRESPONSENOTES',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END InsertApprovedResponseNotes;


PROCEDURE InsertRejectedResponseNotes(p_item_type        IN  VARCHAR2,
                                      p_item_key         IN  VARCHAR2,
                                      p_actid            IN  NUMBER,
                                      p_funcmode         IN  VARCHAR2,
                                      p_result           OUT NOCOPY VARCHAR2) IS

  l_document_id                NUMBER;
  l_customer_trx_id            NUMBER;
  l_approver_display_name      wf_users.display_name%TYPE;
  l_note_id                    NUMBER;
  l_note_text                  ar_notes.text%type;
  l_notes                      wf_item_attribute_values.text_value%TYPE;  /*5119049 */

  --Bug 1908252
  l_last_updated_by     NUMBER;
  l_last_update_login   NUMBER;
  l_approver_id 	NUMBER;
  l_transaction_type 	VARCHAR2(30);

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered INSERTREJECTEDRESPONSENOTES';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('InsertRejectedResponseNotes: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  -- Bug 2105483 : rather then calling arp_global at the start
  -- of the package, WHERE it can error out NOCOPY since org_id is not yet set,
  -- do the call right before it is needed

  -- arp_global.init_global;

  -- Bug 1908252

  l_last_updated_by := ARP_GLOBAL.user_id;
  l_last_update_login := ARP_GLOBAL.last_update_login ;

  ---------------------------------------------------------------------
  g_debug_mesg   := 'Insert Rejected Response notes';
  ---------------------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then

    l_document_id    := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_customer_trx_id   := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_approver_display_name
                      := wf_engine.GetItemAttrText(
                                             p_item_type,
                                             p_item_key,
                                             'APPROVER_DISPLAY_NAME');

    l_notes  := wf_engine.GetItemAttrText( p_item_type,  p_item_key,'NOTES'); /*5119049*/

    fnd_message.set_name('AR', 'AR_WF_REJECTED_RESPONSE');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('APPROVER',     l_approver_display_name);
    -- bug fix 1122477

    l_note_text := fnd_message.get;

    IF l_notes is NOT NULL then
       l_note_text := SUBSTRB(l_note_text || ' "' || l_notes || '"',1,2000) ;  /*5119049*/
    END IF;

         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text,
                        l_note_id);

     -- Bug 1908252 : update last_update* fields

     UPDATE ra_cm_requests
     SET status = 'NOT_APPROVED',
         last_updated_by = l_last_updated_by,
         last_update_date = SYSDATE,
         last_update_login = l_last_update_login
     WHERE request_id = p_item_key;

     /*COMMIT;*/


    /***********************************************************************/
    -- Written For AME Integration
    --
    -- This piece of code communicates to AME and lets it know about the
    -- reponse.

    RecordResponseWithAME (
      p_item_type => p_item_type,
      p_item_key  => p_item_key,
      p_response  => ame_util.rejectStatus);


    -------------------------------------------------------------------------
    g_debug_mesg := 'InsertRejectedResponseNotes -return from updt Approval';
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('InsertRejectedResponseNotes: ' || g_debug_mesg);
    END IF;
    -------------------------------------------------------------------------

    wf_engine.SetItemAttrText(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'CURRENT_HUB',
      avalue   => c_approvals_transaction_type);

    /*************************************************************************/

     p_result := 'COMPLETE:T';
     RETURN;


  END if; -- END of run mode

  --
  -- CANCEL mode
  --

  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'INSERTREJECTEDRESPONSENOTES',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;


END InsertRejectedResponseNotes;


PROCEDURE InsertSuccessfulAPINotes(p_item_type        IN  VARCHAR2,
                                   p_item_key         IN  VARCHAR2,
                                   p_actid            IN  NUMBER,
                                   p_funcmode         IN  VARCHAR2,
                                   p_result           OUT NOCOPY VARCHAR2) IS

  l_document_id                NUMBER;
  l_credit_memo_number            VARCHAR2(20);
  l_customer_trx_id	      NUMBER;
  l_note_id                    NUMBER;
  l_note_text                  ar_notes.text%type;
  l_notes                      wf_item_attribute_values.text_value%TYPE;  /*5119049 */

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered INSERTSUCCESFULAPINOTES';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('InsertSuccessfulAPINotes: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------
  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then


    l_document_id    := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_credit_memo_number   := wf_engine.GetItemAttrText(
                                             p_item_type,
                                             p_item_key,
                                             'CREDIT_MEMO_NUMBER');

    l_customer_trx_id   := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_notes  := wf_engine.GetItemAttrText( p_item_type,  p_item_key,'NOTES'); /*5119049*/
 /* Get trx number for CM and the insert into note text */


    fnd_message.set_name('AR', 'AR_WF_COMPLETED_SUCCESSFUL');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('TRXNUMBER', l_credit_memo_number);

    l_note_text := fnd_message.get;


    IF l_notes is NOT NULL then
       l_note_text := SUBSTRB(l_note_text || ' "' || l_notes || '"',1,2000) ;  /*5119049*/
    END IF;
         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text,
                        l_note_id);


     p_result := 'COMPLETE:T';
     RETURN;


  END if; -- END of run mode

  --
  -- CANCEL mode
  --

  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'INSERTSUCCESSFULAPINOTES',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END InsertSuccessfulAPINotes;


PROCEDURE InsertNotes(p_item_type        IN  VARCHAR2,
                      p_item_key         IN  VARCHAR2,
                      p_actid            IN  NUMBER,
                      p_funcmode         IN  VARCHAR2,
                      p_result           OUT NOCOPY VARCHAR2) IS


  l_customer_id                NUMBER;
  l_collector_id               NUMBER;
  l_customer_trx_id            NUMBER;
  l_bill_to_site_use_id        NUMBER;
  l_customer_call_id           NUMBER;
  l_customer_call_topic_id     NUMBER;
  l_action_id                  NUMBER;
  l_note_id                    NUMBER;
  l_reason_code                VARCHAR2(45);
  l_currency_code              VARCHAR2(15);
  l_entered_amount_display     NUMBER;
  l_result_flag                VARCHAR2(1);

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered INSERTNOTES';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('InsertNotes: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then

    l_reason_code    := wf_engine.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'REASON');

    l_currency_code   := wf_engine.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'CURRENCY_CODE');

    l_entered_amount_display
                      := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'ENTERED_AMOUNT_DISPLAY');

    l_customer_id     := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_ID');

    l_collector_id     := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'COLLECTOR_ID');


    l_customer_trx_id   := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_bill_to_site_use_id   := wf_engine.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'BILL_TO_SITE_USE_ID');



         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        'Credit Memo request was approved by receivable role.',
                        l_note_id);


     p_result := 'COMPLETE:T';
     RETURN;


  END if; -- END of run mode

  --
  -- CANCEL mode
  --

  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;
  END if;


  --
  -- Other execution modes
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'INSERTNOTES',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

    RAISE;

END InsertNotes;


PROCEDURE InsertTrxNotes(x_customer_call_id          IN  NUMBER,
                           x_customer_call_topic_id    IN  NUMBER,
                           x_action_id                 IN  NUMBER,
                           x_customer_trx_id           IN  NUMBER,
                           x_note_type                 IN  VARCHAR2,
                           x_text                      IN  VARCHAR2,
                           x_note_id                   OUT NOCOPY NUMBER) IS

  l_last_updated_by     NUMBER;
  l_last_update_date    date;
  l_last_update_login   NUMBER;
  l_creation_date       date;
  l_created_by          NUMBER;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered INSERTTRXNOTES';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('InsertTrxNotes: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  -- Bug 2105483 : rather then calling arp_global at the start
  -- of the package, WHERE it can error out NOCOPY since org_id is not yet set,
  -- do the call right before it is needed


  -- Bug 1690118 : replace FND_GLOBAL with ARP_GLOBAL

  l_created_by            := ARP_GLOBAL.USER_ID;
  l_creation_date         := sysdate;
  l_last_update_login     := ARP_GLOBAL.last_update_login;
  l_last_update_date      := sysdate;
  l_last_updated_by       := ARP_GLOBAL.USER_ID;

  g_debug_mesg := 'WHO columns retrieved';

  arp_notes_pkg.insert_cover(
    p_note_type              => x_note_type,
    p_text                   => x_text,
    p_customer_call_id       => NULL,
    p_customer_call_topic_id => NULL,
    p_call_action_id         => NULL,
    p_customer_trx_id        => x_customer_trx_id,
    p_note_id                => x_note_id,
    p_last_updated_by        => l_last_updated_by,
    p_last_update_date       => l_last_update_date,
    p_last_update_login      => l_last_update_login,
    p_created_by             => l_created_by,
    p_creation_date          => l_creation_date);

  ----------------------------------------------------------
  g_debug_mesg := 'INSERTTRXNOTES - notes inserted';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('InsertTrxNotes: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  EXCEPTION
    WHEN OTHERS THEN
      x_note_id := -1;
      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'INSERTTRXNOTES',
        arg1      => c_item_type,
        arg2      => NULL,
        arg3      => NULL,
        arg4      => NULL,
        arg5      => g_debug_mesg);

      RAISE;

END InsertTrxNotes;


PROCEDURE CallTrxApi(p_item_type        IN  VARCHAR2,
                     p_item_key         IN  VARCHAR2,
                     p_actid            IN  NUMBER,
                     p_funcmode         IN  VARCHAR2,
                     p_result           OUT NOCOPY VARCHAR2) IS


  l_customer_trx_id     		NUMBER;
  l_amount              		NUMBER;
  l_request_id	      		NUMBER;
  l_error_tab	      		arp_trx_validate.Message_Tbl_Type;
  l_batch_source_name		VARCHAR2(50);
  l_credit_method_rules		VARCHAR2(65);
  l_credit_method_installments	VARCHAR2(65);
  l_cm_creation_error		VARCHAR2(250);
  l_credit_memo_number    	VARCHAR2(20);
  l_credit_memo_id    		NUMBER;
  CRLF        			VARCHAR2(1);
  l_status		        VARCHAR2(255);

  -- bug 1908252
  l_last_updated_by     NUMBER;
  l_last_update_login   NUMBER;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered CALLTRXAPI';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('CallTrxApi: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  -- Bug 2105483 : rather then calling arp_global at the start
  -- of the package, WHERE it can error out NOCOPY since org_id is not yet set,
  -- do the call right before it is needed

  --
  -- RUN mode - normal process execution
  --
  IF (p_funcmode = 'RUN') then

    -- restore_context(p_item_key);

    crlf := arp_global.CRLF;

    -- Bug 1908252
    l_last_updated_by   := ARP_GLOBAL.user_id;
    l_last_update_login := ARP_GLOBAL.last_update_login ;

    -- call transaction API here

    l_customer_trx_id   := wf_engine.GetItemAttrNumber(
                            p_item_type,
                            p_item_key,
                            'CUSTOMER_TRX_ID');

    l_amount           := wf_engine.GetItemAttrNumber(
                            p_item_type,
                            p_item_key,
                            'ORIGINAL_TOTAL');

   l_request_id  := wf_engine.GetItemAttrNumber(
                      p_item_type,
                      p_item_key,
                      'WORKFLOW_DOCUMENT_ID');

   l_batch_source_name := wf_engine.GetItemAttrText(
                            p_item_type,
                            p_item_key,
                            'BATCH_SOURCE_NAME');


   l_credit_method_installments    := wf_engine.GetItemAttrText(
                                        p_item_type,
                                        p_item_key,
                                        'CREDIT_INSTALLMENT_RULE');

   l_credit_method_rules     := wf_engine.GetItemAttrText(
                                  p_item_type,
                                  p_item_key,
                                  'CREDIT_ACCOUNTING_RULE');

   l_cm_creation_error := NULL;

/* bug 3155533 : do not raise an error if user does not set-up batch source name
   in workflow definition

   IF l_batch_source_name IS NULL THEN

     fnd_message.set_name('AR', 'AR_WF_NO_BATCH');
     l_cm_creation_error := fnd_message.get;

     wf_engine.SetItemAttrText(p_item_type,
        p_item_key,
        'CM_CREATION_ERROR',
        l_cm_creation_error);

     p_result := 'COMPLETE:F';
     RETURN;

   END IF;
*/
   IF (l_credit_method_installments = 'N') THEN
     l_credit_method_installments := NULL;
   END if;

   IF (l_credit_method_rules = 'N') THEN
     l_credit_method_rules := NULL;
   END if;

   g_debug_mesg := 'Before calling arw_cmreq_cover.ar_autocreate_cm';


   -- BUG 2290738 : added a new OUT NOCOPY parameter p_status
   arw_cmreq_cover.ar_autocreate_cm(
     p_request_id		  => l_request_id,
     p_batch_source_name	  => l_batch_source_name,
     p_credit_method_rules	  => l_credit_method_rules,
     p_credit_method_installments => l_credit_method_installments,
     p_error_tab		  => l_error_tab,
     p_status			  => l_status);

   g_debug_mesg := 'After calling arw_cmreq_cover.ar_autocreate_cm';

   l_cm_creation_error := NULL;


   BEGIN

     SELECT cm_customer_trx_id INTO l_credit_memo_id
     FROM ra_cm_requests
     WHERE request_id = l_request_id;

     EXCEPTION
       WHEN OTHERS THEN
   	 p_result := 'COMPLETE:F';
	 l_cm_creation_error := 'Could not find the request';
         wf_engine.SetItemAttrText(p_item_type,
           p_item_key,
           'CM_CREATION_ERROR',
           l_cm_creation_error);
         RETURN;
   END;

   g_debug_mesg := 'Credit Memo ID: ' || l_credit_memo_id;

   --   IF l_error_tab.count = 0  THEN
   IF (l_credit_memo_id is NOT NULL) THEN
     p_result := 'COMPLETE:T';

     -- Bug 1908252 : update last_update* fields
     UPDATE ra_cm_requests
     SET status='COMPLETE',
         approval_date     = SYSDATE,
         last_updated_by   = l_last_updated_by,
         last_update_date  = SYSDATE,
         last_update_login = l_last_update_login
     WHERE request_id = p_item_key;

     /*commit;*/

     BEGIN

       SELECT trx_number INTO l_credit_memo_number
       FROM ra_customer_trx
       WHERE  customer_trx_id = l_credit_memo_id;

       wf_engine.SetItemAttrText(p_item_type,
         p_item_key,
         'CREDIT_MEMO_NUMBER',
         l_credit_memo_number);

       EXCEPTION
         WHEN OTHERS THEN
           p_result := 'COMPLETE:F';
	   l_cm_creation_error := 'Could not find the credit memo';
           wf_engine.SetItemAttrText(p_item_type,
             p_item_key,
             'CM_CREATION_ERROR',
             l_cm_creation_error);
           RETURN;
     END;

   ELSE

     g_debug_mesg := 'Credit Memo ID Is NULL';

     FOR i IN 1..l_error_tab.COUNT LOOP
       l_cm_creation_error := l_cm_creation_error ||
         l_error_tab(i).translated_message || CRLF;
     END LOOP;

     wf_engine.SetItemAttrText(p_item_type,
       p_item_key,
       'CM_CREATION_ERROR',
       l_cm_creation_error);

     -- Bug 1908252 : update last_update* fields

     g_debug_mesg := 'last Updated By: '
                      || l_last_updated_by || ' '
                      || l_last_update_login;


     UPDATE ra_cm_requests
     SET status='APPROVED_PEND_COMP',
         approval_date = SYSDATE,
         last_updated_by = l_last_updated_by,
         last_update_date = SYSDATE,
         last_update_login = l_last_update_login
     WHERE request_id = p_item_key;

     g_debug_mesg := 'After Update';

     p_result := 'COMPLETE:F';

   END IF;

   g_debug_mesg := 'Before Return';

   RETURN;

  END IF; -- END of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  IF (p_funcmode = 'CANCEL') THEN

    -- no result needed
    p_result := 'COMPLETE:';
    RETURN;

  END IF;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning NULL
  --
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'CALLTRXAPI',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END CallTrxApi;


PROCEDURE CheckCreditMethods(p_item_type        IN  VARCHAR2,
                             p_item_key         IN  VARCHAR2,
                             p_actid            IN  NUMBER,
                             p_funcmode         IN  VARCHAR2,
                             p_result           OUT NOCOPY VARCHAR2) IS

  l_customer_trx_id	     NUMBER;
  l_credit_installment_rule  VARCHAR2(65);
  l_credit_accounting_rule   VARCHAR2(65);
  l_invalid_rule_value       VARCHAR2(80);
  l_invalid_rule_mesg        VARCHAR2(2000);
  l_count		     NUMBER;
  l_invoicing_rule_id	     NUMBER;

  CURSOR c (p_cust_trx_id NUMBER) IS
    SELECT COUNT(*)
    FROM ra_terms_lines
    WHERE term_id =
      (SELECT term_id
       FROM ra_customer_trx
       WHERE customer_trx_id = p_cust_trx_id);

  CURSOR c2 (p_cust_trx_id NUMBER) IS
    SELECT invoicing_rule_id
    FROM   ra_customer_trx
    WHERE  customer_trx_id = p_cust_trx_id;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered CHECKCREDITMETHODS';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('CheckCreditMethods: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  -- arp_standard.enable_debug;
  -- arp_standard.enable_file_debug('/sqlcom/out/findv115',
  --    'OB'||userenv('SESSIONID')|| '.log');
  -- fnd_global.apps_initialize(1318,50559,222);
  -- mo_global.init;
  -- Setorgcontext (p_item_key);

  --
  -- RUN mode - normal process execution
  --

  IF (p_funcmode = 'RUN') then

    -- restore_context(p_item_key);
    -- Setorgcontext (p_item_key);

    ------------------------------------------------------------
    g_debug_mesg := 'Get the user value of rules';
    ------------------------------------------------------------

    l_customer_trx_id := wf_engine.GetItemAttrNumber(
                           p_item_type,
                           p_item_key,
                           'CUSTOMER_TRX_ID');

    l_credit_installment_rule := wf_engine.GetItemAttrText(
                                   p_item_type,
                                   p_item_key,
                                   'CREDIT_INSTALLMENT_RULE');

    l_credit_accounting_rule := wf_engine.GetItemAttrText(
                                  p_item_type,
                                  p_item_key,
                                  'CREDIT_ACCOUNTING_RULE');

    l_invalid_rule_value := wf_engine.GetItemAttrText(
                              p_item_type,
                              p_item_key,
                              'INVALID_RULE_VALUE');

    l_invalid_rule_mesg := wf_engine.GetItemAttrText(
                             p_item_type,
                             p_item_key,
                              'INVALID_RULE_MESG');


    OPEN  c (l_customer_trx_id);
    FETCH c INTO l_count;
    CLOSE c;

    g_debug_mesg := 'After Cursor: ' || l_count;

    -- the l_count will always be >= 1, and the credit installment_rule is
    -- required for count > 1.

    IF l_count > 1 then

      IF l_credit_installment_rule  not in ('LIFO', 'FIFO', 'PRORATE') then
        -- invalid credit method
        wf_engine.SetItemAttrText(p_item_type,
                                  p_item_key,
                                  'INVALID_RULE_MESG',
                                 l_invalid_rule_value);
        p_result := 'COMPLETE:F';
        RETURN;
      END if;
    END if;


    OPEN  c2 (l_customer_trx_id);
    FETCH c2 INTO l_invoicing_rule_id;
    CLOSE c2;

    IF l_invoicing_rule_id is not  NULL then

      IF l_credit_accounting_rule   not in ('LIFO', 'PRORATE','UNIT') THEN
        -- invalid credit method
        wf_engine.SetItemAttrText(p_item_type,
                                  p_item_key,
                                  'INVALID_RULE_MESG',
                                  l_invalid_rule_value);
        p_result := 'COMPLETE:F';
        RETURN;
      END if;
    END if;

     -- the credit methods are valid
    IF l_invalid_rule_mesg is NOT NULL THEN

      l_invalid_rule_mesg := NULL;
      wf_engine.SetItemAttrText(p_item_type,
                                p_item_key,
                                'INVALID_RULE_MESG',
                                l_invalid_rule_mesg);
    END if;

    g_debug_mesg := 'Before Return';

    p_result := 'COMPLETE:T';

    RETURN;

  END IF; -- END of run mode

  --
  -- CANCEL mode
  --

  IF (p_funcmode = 'CANCEL') then

    -- no result needed
    g_debug_mesg := 'Cancel Mode';
    p_result := 'COMPLETE:';
    RETURN;
  END if;

  --
  -- Other execution modes
  --

  g_debug_mesg := 'Should not come here';
  p_result := '';
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'CHECKCREDITMETHODS',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END CheckCreditMethods;


-- This procedure is called to find the primary salesrep associated with
-- the invoice.  It loooks ra_customer_trx to find the information.
-- Once we find the salesrep, we need to determine if salesperson is the one
-- initiating the credit memo request.  If so then he need not be notified
-- again.  Otherwise, we will notify him/her to make him/her aware of this
-- credit memo.
--
PROCEDURE find_primary_salesrep (
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid    	IN  NUMBER,
    p_funcmode 	IN  VARCHAR2,
    p_result   	IN OUT NOCOPY VARCHAR2) IS


  l_requestor_user_name  wf_item_attribute_values.text_value%TYPE;
  l_customer_trx_id 	 wf_item_attribute_values.number_value%TYPE;
  l_employee_id 	 ra_salesreps_all.person_id%TYPE;
  l_user_name  		 wf_users.name%TYPE;
  l_display_name    	 wf_users.display_name%TYPE;

  CURSOR c (p_id IN NUMBER) IS
    SELECT rsa.person_id
    FROM ra_customer_trx_all rcta, ra_salesreps_all rsa
    WHERE rcta.primary_salesrep_id = rsa.salesrep_id
    AND rcta.customer_trx_id = p_id;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered FIND_PRIMARY_SALESREP';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('find_primary_salesrep: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  IF (p_funcmode = 'RUN') THEN

    -- restore_context(p_item_key);

    l_customer_trx_id := wf_engine.GetItemAttrNumber(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'CUSTOMER_TRX_ID');

    OPEN c (l_customer_trx_id);
    FETCH c INTO l_employee_id;
    CLOSE c;

    wf_directory.getusername(
      p_orig_system     => 'PER',
      p_orig_system_id => l_employee_id,
      p_name           => l_user_name,
      p_display_name   => l_display_name);

    IF (l_user_name IS NULL) THEN
      p_result := 'COMPLETE:N';
      RETURN;
    END IF;

    wf_engine.SetItemAttrText(
      itemtype =>p_item_type,
      itemkey  => p_item_key,
      aname    => 'SALESREP_USER_NAME',
      avalue   => l_user_name);

    l_requestor_user_name := wf_engine.GetItemAttrText(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'REQUESTOR_USER_NAME');

    IF (l_user_name = l_requestor_user_name) THEN
      p_result := 'COMPLETE:N';
    ELSE
      p_result := 'COMPLETE:Y';
    END IF;

    RETURN;

  END IF;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'FIND_PRIMARY_SALESREP',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END find_primary_salesrep;


-- The following subroutine checks to see if collector forgot to put in a
-- first approver for the HR hierarchy flow or put in a first primary for
-- Limts flow. If either of this happens it returns the approproate errors.
-- Otherwise it returns no error.

PROCEDURE check_first_approver (
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid    	IN  NUMBER,
    p_funcmode 	IN  VARCHAR2,
    p_result   	IN OUT NOCOPY VARCHAR2) IS

  l_approval_path    	wf_item_attribute_values.text_value%TYPE;
  l_approver_user_name  wf_item_attribute_values.text_value%TYPE;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered CHECK_FIRST_APPROVER';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('check_first_approver: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  l_approval_path := wf_engine.getitemattrtext(
    itemtype => p_item_type,
    itemkey  => p_item_key,
    aname    => 'APPROVAL_PATH');

  l_approver_user_name  := wf_engine.GetItemAttrText(
    itemtype => p_item_type,
    itemkey  => p_item_key,
    aname    => 'ROLE');

  IF (l_approval_path = 'LIMITS') THEN

    IF (l_approver_user_name IS NOT NULL) THEN
      p_result := 'COMPLETE:UNNECESSARY_FIRST_APPROVER';
    ELSE
      p_result := 'COMPLETE:NO_ERROR';
    END IF;

  ELSE -- HR hierarchy needs a first approver.

    IF (l_approver_user_name IS NULL) THEN
      p_result := 'COMPLETE:MISSING_FIRST_APPROVER';
    ELSE
      p_result := 'COMPLETE:NO_ERROR';
    END IF;

  END if;

  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'CHECK_FIRST_APPROVER',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END check_first_approver;


-- This subroutine determines if the credit memo created is an on account
-- credit memo.  It looks at the row in ra_customer_trx given the credit
-- memo customer trx id.  In that row if the previous customer trx id is
-- empty implying that this memo was not applied against any invoice then
-- we conclude that the credit memo created is an on account credit memo.
--
PROCEDURE on_account_credit_memo (
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid    	IN  NUMBER,
    p_funcmode 	IN  VARCHAR2,
    p_result   	IN OUT NOCOPY VARCHAR2) IS

  l_credit_memo_number 	wf_item_attribute_values.text_value%TYPE;
  l_approver_user_name  wf_item_attribute_values.text_value%TYPE;
  l_dummy		wf_item_attribute_values.text_value%TYPE;
  l_on_account		BOOLEAN DEFAULT FALSE;

  -- If the previous customer trx id is null then
  -- the credit memo is an on account credit memo.
  -- So, if this cursor returns a row that means
  -- it is a on account credit memo

  CURSOR c (p_credit_memo_id VARCHAR2) IS
    SELECT customer_trx_id
    FROM   ra_customer_trx
    WHERE  customer_trx_id = p_credit_memo_id
    AND    previous_customer_trx_id IS NULL;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered ON_ACCOUNT_CREDIT_MEMO';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('on_account_credit_memo: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  l_credit_memo_number := wf_engine.getitemattrtext(
    itemtype => p_item_type,
    itemkey  => p_item_key,
    aname    => 'CREDIT_MEMO_NUMBER');

  OPEN 	c (l_credit_memo_number);
  FETCH c INTO l_dummy;
  l_on_account := c%FOUND;
  CLOSE c;

  IF l_on_account THEN
    p_result := 'COMPLETE:Y';
  ELSE
    p_result := 'COMPLETE:N';
  END IF;

  RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'ON_ACCOUNT_CREDIT_MEMO',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END on_account_credit_memo;


-- This subroutine determines if the collector shoudl be notified of the
-- credit memo approval and creation.  If the collector him/herself is the
-- requestor then then he must not get two notifications.  But, if he is not
-- requestor then he must be informed.

PROCEDURE inform_collector (
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid    	IN  NUMBER,
    p_funcmode 	IN  VARCHAR2,
    p_result   	IN OUT NOCOPY VARCHAR2) IS

  l_requestor_user_name wf_item_attribute_values.text_value%TYPE;
  l_collector_user_name wf_item_attribute_values.text_value%TYPE;

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered INFORM_COLLECTOR';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('inform_collector: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------

  IF (p_funcmode = 'RUN') THEN

    -- restore_context(p_item_key);

    l_requestor_user_name := wf_engine.GetItemAttrText(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'REQUESTOR_USER_NAME');

    l_collector_user_name := wf_engine.GetItemAttrText(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'COLLECTOR_USER_NAME');

    IF (l_collector_user_name = l_requestor_user_name) THEN
      p_result := 'COMPLETE:N';
    ELSE
      p_result := 'COMPLETE:Y';
    END IF;

    RETURN;

  END IF;

  EXCEPTION
    WHEN OTHERS THEN

      wf_core.context(
        pkg_name  => 'AR_AME_CMWF_API',
        proc_name => 'INFORM_COLLECTOR',
        arg1      => p_item_type,
        arg2      => p_item_key,
        arg3      => p_funcmode,
        arg4      => to_char(p_actid),
        arg5      => g_debug_mesg);

      RAISE;

END inform_collector;

/*4139346 */
/* This was inntroduced for bug # 3865317 */

PROCEDURE AMEHandleTimeout (p_item_type IN  VARCHAR2,
                            p_item_key  IN  VARCHAR2,
                            p_actid     IN  NUMBER,
                            p_funcmode  IN  VARCHAR2,
                            p_result    OUT NOCOPY VARCHAR2) IS

  l_profile_value VARCHAR2(30);
  l_result        VARCHAR2(100);

BEGIN

  ----------------------------------------------------------
  g_debug_mesg := 'Entered AMEHANDLETIMEOUT';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('AMEHandleTimeout: ' || g_debug_mesg);
  END IF;
  ----------------------------------------------------------
  --
  -- RUN mode - normal process execution
  --

  IF (p_funcmode = 'RUN') THEN

    l_profile_value := NVL(fnd_profile.value('AR_CMWF_TIME_OUT'), 'MANAGER');

    wf_engine.setitemattrtext(
      itemtype => p_item_type,
      itemkey  => p_item_key,
      aname    => 'DEBUG',
      avalue   => 'Profile: ' || l_profile_value);

    IF l_profile_value = 'APPROVER' THEN

      -- Profile option is set to look for the next approver (who may
      -- not be the manager) and send it to that approver. So, we will
      -- proceed in that direction.  To do that all we need to is flag
      -- that we are in the timeout mode and simply put a value of "N"
      -- (next) in the result attribute.

      wf_engine.setitemattrtext(
        itemtype => p_item_type,
        itemkey  => p_item_key,
        aname    => 'TIMEOUT_OCCURRED',
        avalue   => 'Y');

      -- let AME know that the current approver timed out, so that next
      -- time next time we ask for an approver it gives the next approver
      -- in line.

      RecordResponseWithAME (
          p_item_type => p_item_type,
          p_item_key  => p_item_key,
          p_response  => ame_util.noResponseStatus);

      -- Complete with transition set to "N" for next.
      p_result := 'COMPLETE:N';
      RETURN;

    ELSE

      -- profile option is set to look for manager, so continue
      -- with our original logic.

      ar_ame_cmwf_api.amefindmanager(
        p_item_type => p_item_type,
        p_item_key  => p_item_key,
        p_actid     => p_actid,
        p_funcmode  => p_funcmode,
        p_result    => l_result);

        -- in this branch the values that can be returned is T/F
        p_result := l_result;

    END IF;

  END IF;

END AMEHandleTimeout;

END ar_ame_cmwf_api;

/
