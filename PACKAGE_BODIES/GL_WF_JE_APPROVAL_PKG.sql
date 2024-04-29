--------------------------------------------------------
--  DDL for Package Body GL_WF_JE_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_WF_JE_APPROVAL_PKG" AS
/*  $Header: glwfjeab.pls 120.13.12010000.4 2009/06/22 10:42:26 skotakar ship $  */

-- +--------------------+
-- | PRIVATE PROCEDURES |
-- +--------------------+

-- ****************************************************************************
-- Private procedure: Display diagnostic message
-- ****************************************************************************
PROCEDURE diagn_msg (message_string   IN  VARCHAR2) IS
BEGIN
  IF diagn_msg_flag THEN
--    dbms_output.put_line (message_string);
    NULL;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END diagn_msg;


-- ****************************************************************************
-- Function: check_authorization_limit
-- Purpose: checks if the employee has enough authorization limits to approve
--          the entire batch.
-- ****************************************************************************

FUNCTION check_authorization_limit(p_employee_id NUMBER,
                                   p_batch_id    NUMBER) RETURN BOOLEAN IS
  CURSOR get_ledgers IS
    SELECT led.ledger_id,
           max(abs(nvl(jel.accounted_dr, 0) -
                   nvl(jel.accounted_cr, 0))) LARGEST_NET_AMOUNT
    FROM   GL_JE_HEADERS jeh, GL_JE_LINES jel, GL_LEDGERS led
    WHERE  jeh.je_batch_id = p_batch_id
    AND    jeh.currency_code <> 'STAT'
    AND    jel.je_header_id = jeh.je_header_id
    AND    led.ledger_id = jeh.ledger_id
    AND    led.enable_je_approval_flag = 'Y'
    GROUP BY led.ledger_id;

  l_limit NUMBER;
BEGIN
  FOR ledger_rec IN get_ledgers LOOP
    SELECT nvl(min(authorization_limit), -1)
    INTO   l_limit
    FROM   GL_AUTHORIZATION_LIMITS
    WHERE  employee_id = p_employee_id
    AND    ledger_id = ledger_rec.ledger_id;

    IF (l_limit < ledger_rec.largest_net_amount) THEN
      RETURN FALSE;
    END IF;
  END LOOP;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG',
                    'check_authorization_limit');
    raise;
END check_authorization_limit;


-- ****************************************************************************
-- Procedure: getmanager
-- Purpose: get the manager id of an employee.
-- ****************************************************************************

PROCEDURE getmanager(employee_id  IN NUMBER,
                     manager_id	  OUT NOCOPY NUMBER) IS
BEGIN
  diagn_msg('getmanager: employee_id = ' || to_char(employee_id));

  -- 4880614: Instead of using GL_HR_EMPLOYEES_CURRENT_V, use HR base tables
  -- to skip HR security in the workflow.
  SELECT A.supervisor_id
  INTO   manager_id
  FROM   PER_ALL_PEOPLE_F P, PER_ALL_ASSIGNMENTS_F A
  WHERE  P.business_group_id + 0 = A.business_group_id
  AND    P.employee_number IS NOT NULL
  AND    TRUNC(sysdate) BETWEEN P.effective_start_date AND P.effective_end_date
  AND    A.primary_flag = 'Y'
  AND    A.assignment_type = 'E'
  AND    A.person_id = P.person_id
  AND    TRUNC(sysdate) BETWEEN A.effective_start_date AND A.effective_end_date
  AND    P.person_id = employee_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    manager_id := NULL;
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'getmanager');
    raise;
END getmanager;


-- ****************************************************************************
-- Procedure: setpersonas
-- Purpose: set the given (manager) id as the MANAGER or the APPROVER.
-- ****************************************************************************

PROCEDURE setpersonas(manager_id     IN NUMBER,
                      item_type      IN VARCHAR2,
		      item_key       IN VARCHAR2,
		      manager_target IN VARCHAR2) IS
  l_manager_name		VARCHAR2(240);
  l_manager_display_name	VARCHAR2(240);
BEGIN
  diagn_msg('Executing the setpersonas activity..');

  WF_DIRECTORY.GetUserName('PER',
			    manager_id,
			    l_manager_name,
			    l_manager_display_name);

  diagn_msg('setpersonas: manager_name = ' || l_manager_name);
  diagn_msg('setpersonas: manager_display_name = ' || l_manager_display_name);

  IF (manager_target = 'MANAGER') THEN
    WF_ENGINE.SetItemAttrText(item_type,
			      item_key,
			      'MANAGER_ID',
			      manager_id);

    WF_ENGINE.SetItemAttrText(item_type,
			      item_key,
			      'MANAGER_NAME',
			      l_manager_name);

    WF_ENGINE.SetItemAttrText(item_type,
			      item_key,
			      'MANAGER_DISPLAY_NAME',
			      l_manager_display_name);

  ELSE
    WF_ENGINE.SetItemAttrText(item_type,
			      item_key,
			      'APPROVER_ID',
			      manager_id);

    WF_ENGINE.SetItemAttrText(item_type,
			      item_key,
			      'APPROVER_NAME',
			      l_manager_name);

    WF_ENGINE.SetItemAttrText(item_type,
			      item_key,
			      'APPROVER_DISPLAY_NAME',
			      l_manager_display_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'setpersonas',
                    item_type, item_key);
    raise;
END setpersonas;


-- ****************************************************************************
-- Procedure: getfinalapprover
-- Purpose: find the first approver who can approve the entire batch.
-- ****************************************************************************

PROCEDURE getfinalapprover(p_employee_id        IN NUMBER,
			   p_batch_id           IN NUMBER,
			   p_final_approver_id  OUT NOCOPY NUMBER) IS
  l_approver_id         NUMBER := p_employee_id;
  l_temp_employee_id    NUMBER;
BEGIN
  LOOP
    -- bug 2708423: can't pass the same variable as IN and OUT parameter
    l_temp_employee_id := l_approver_id;
    GetManager(l_temp_employee_id,
               l_approver_id);

    IF (l_approver_id IS NULL) THEN
      p_final_approver_id := NULL;
      return;
    END IF;

    IF (check_authorization_limit(l_approver_id, p_batch_id)) THEN
      p_final_approver_id := l_approver_id;
      return;
    END IF;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'getfinalapprover');
    raise;
END getfinalapprover;


-- ****************************************************************************
-- Procedure: getapprover
-- Purpose: get the next approver for a given employee id based upon the
--          find_approver_method.
-- ****************************************************************************

PROCEDURE getapprover(employee_id          IN NUMBER,
		      item_type            IN VARCHAR2,
		      item_key             IN VARCHAR2,
		      curr_approver_id     IN NUMBER,
		      find_approver_method IN VARCHAR2,
		      next_approver_id     IN OUT NOCOPY NUMBER) IS
  l_error_message    VARCHAR2(2000);
  l_batch_id         NUMBER;
BEGIN
  -- Get batch id
  l_batch_id := wf_engine.GetItemAttrNumber(
		itemtype  => item_type,
		itemkey   => item_key,
		aname     => 'BATCH_ID');

  IF (find_approver_method = 'CHAIN') THEN

    IF (next_approver_id IS NULL) THEN

      diagn_msg('Getapprover: Calling getmanager with method equal CHAIN');

      getmanager(curr_approver_id, next_approver_id);

    END IF;

  ELSIF (find_approver_method = 'DIRECT') THEN

    diagn_msg('Getapprover: Calling getfinalapprover with method equal DIRECT');

    getfinalapprover(employee_id,
		     l_batch_id,
		     next_approver_id);

  ELSIF (find_approver_method = 'ONE_STOP_DIRECT') THEN

    IF (next_approver_id IS NULL) THEN

      diagn_msg('Getapprover: Calling getfinalapprover with method equal ONE_STOP_DIRECT');

      getfinalapprover(curr_approver_id,
		       l_batch_id,
		       next_approver_id);
    END IF;

  ELSE
    FND_MESSAGE.Set_Name('SQLGL', 'GL_WF_INVALID_APPROVER_METHOD');
    l_error_message := FND_MESSAGE.Get;

    wf_engine.SetItemAttrText(item_type,
			      item_key,
			      'ERROR_MESSAGE',
			      l_error_message);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'getapprover',
                    item_type, item_key);
    raise;
END getapprover;


-- +-------------------+
-- | PUBLIC PROCEDURES |
-- +-------------------+

-- ****************************************************************************
--   start_approval_workflow
-- ****************************************************************************

PROCEDURE start_approval_workflow (p_je_batch_id           IN NUMBER,
                                   p_preparer_fnd_user_id  IN NUMBER,
                                   p_preparer_resp_id      IN NUMBER,
                                   p_je_batch_name         IN VARCHAR2) IS
  l_itemtype		VARCHAR2(10) := 'GLBATCH';
  l_itemkey		VARCHAR2(40);
  l_fnd_user_name	VARCHAR2(100);
  l_preparer_id		NUMBER;
  l_monitor_url		VARCHAR2(500);
  l_approval_run_id	NUMBER;
  l_business_group_id   NUMBER;
  l_reassign_role       VARCHAR2(320);
BEGIN
  diagn_msg('Executing Start_Approval_Workflow for JE batch '||
				to_char(p_je_batch_id));

  -- Update the approval status of the batch to 'I'
  UPDATE gl_je_batches
  SET approval_status_code = 'I'
  WHERE je_batch_id = p_je_batch_id;

  -- Get Approval run id
  SELECT GL_JE_APPROVAL_S.nextval
  INTO   l_approval_run_id
  FROM   DUAL;

  -- Get AOL user name and person id
  SELECT user_name, nvl(employee_id, -1)
  INTO   l_fnd_user_name, l_preparer_id
  FROM   fnd_user
  WHERE  user_id = p_preparer_fnd_user_id;

  -- generate the item key
  l_itemkey := to_char(p_je_batch_id) || '*' || to_char(l_approval_run_id);

  diagn_msg('Generated Item Key = ' || l_itemkey);

  -- Kick Off workflow process
  wf_engine.CreateProcess( itemtype => l_itemtype,
			   itemkey  => l_itemkey,
			   process  => 'GL_JE_APPROVAL_PROCESS' );
  diagn_msg('Process for GL_JE_APPROVAL_PROCESS created');

  -- Set item user key
  wf_engine.SetItemUserKey( itemtype => l_itemtype,
			    itemkey  => l_itemkey,
			    userkey  => p_je_batch_name );

  -- Set the process owner
  wf_engine.SetItemOwner( itemtype => l_itemtype,
                          itemkey  => l_itemkey,
                          owner    => l_fnd_user_name );

  -- Set the fnd user name
  wf_engine.SetItemAttrText( itemtype => l_itemtype,
			     itemkey  => l_itemkey,
			     aname    => 'FND_USER_NAME',
			     avalue   => l_fnd_user_name );

  --  Set batch id (JE batch ID)
  wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
			       itemkey  => l_itemkey,
			       aname    => 'BATCH_ID',
			       avalue   => p_je_batch_id );
  diagn_msg('Attribute JE_BATCH_ID set to ' || to_char(p_je_batch_id));

  -- Set the unique item key
  wf_engine.SetItemAttrText( itemtype => l_itemtype,
			     itemkey  => l_itemkey,
			     aname    => 'UNIQUE_ITEMKEY',
			     avalue   => l_itemkey );
  diagn_msg('Set the unique item key: '|| l_itemkey);

  --  Set PersonID attribute (HR personID from PER_PERSONS_F)
  wf_engine.SetItemAttrNumber( itemtype => l_itemtype,
			       itemkey  => l_itemkey,
			       aname    => 'PREPARER_ID',
			       avalue   => l_preparer_id );
  diagn_msg('Attribute PREPARER_ID set to ' || l_preparer_id);

  -- Set UserID attribute (AOL userID from FND_USER table).
  wf_engine.SetItemAttrNumber( itemtype => l_itemtype,
			       itemkey  => l_itemkey,
			       aname    => 'PREPARER_FND_ID',
			       avalue   => p_preparer_fnd_user_id );

  --  Set ResponsibilityID attribute
  wf_engine.SetItemAttrNumber( itemtype => l_itemtype,
			       itemkey  => l_itemkey,
			       aname    => 'PREPARER_RESP_ID',
			       avalue   => p_preparer_resp_id );
  diagn_msg('Attribute PREPARER_RESP_ID set');

  -- Get the monitor URL
  l_monitor_url := wf_monitor.GetUrl(wf_core.translate('WF_WEB_AGENT'),
				     l_itemtype, l_itemkey, 'NO');
  wf_engine.SetItemAttrText( itemtype => l_itemtype,
			     itemkey  => l_itemkey,
			     aname    => 'MONITOR_URL',
			     avalue   => l_monitor_url );
  diagn_msg('Attribute Monitor_URL set to ' || l_monitor_url);

  -- Set Reassignment Role
  SELECT min(business_group_id)
  INTO   l_business_group_id
  FROM   per_all_people_f
  WHERE  person_id = l_preparer_id
  AND    trunc(sysdate) BETWEEN effective_start_date AND effective_end_date;

  -- Take the Max to get the business group specific role if exists
  SELECT max(name)
  INTO   l_reassign_role
  FROM   WF_LOCAL_ROLES
  WHERE  name IN ('GL_JE_APPROVAL_REASSIGN_ROLE' || ' ' || l_business_group_id,
                  'GL_JE_APPROVAL_REASSIGN_ROLE')
  AND    nvl(expiration_date, sysdate + 1) > sysdate;

  wf_engine.SetItemAttrText ( itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => 'REASSIGNMENT_ROLE',
                              avalue   => l_reassign_role );

  -- Finally, start the process
  wf_engine.StartProcess( itemtype => l_itemtype,
			  itemkey  => l_itemkey );

  diagn_msg('Process GL_JE_APPROVAL_PROCESS started');

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'start_approval_workflow',
                    l_itemtype, l_itemkey);
    raise;

END start_approval_workflow;


-- ****************************************************************************
--   is_employee_set
-- ****************************************************************************

PROCEDURE is_employee_set (itemtype   IN VARCHAR2,
		     	   itemkey    IN VARCHAR2,
                       	   actid      IN NUMBER,
                       	   funcmode   IN VARCHAR2,
                           result     OUT NOCOPY VARCHAR2) IS
  l_preparer_id             NUMBER;
  l_preparer_name           VARCHAR2(240);
  l_preparer_display_name   VARCHAR2(240);
BEGIN

  IF ( funcmode = 'RUN' ) THEN
    -- Get PersonID attribute (already set when process started)
    l_preparer_id := wf_engine.GetItemAttrNumber(
                itemtype  => itemtype,
                itemkey   => itemkey,
                aname     => 'PREPARER_ID' );

    IF (l_preparer_id = -1 OR l_preparer_id IS NULL) THEN
      result := 'COMPLETE:N';
      return;
    ELSE
      -- Retrieve preparer's User name (Login name for Apps) and displayed name
      wf_directory.GetUserName( p_orig_system    => 'PER',
				p_orig_system_id => l_preparer_id,
				p_name           => l_preparer_name,
				p_display_name   => l_preparer_display_name );
      diagn_msg('Retrieved user name: '|| l_preparer_name);

      -- Copy username to Workfow
      wf_engine.SetItemAttrText( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'PREPARER_NAME',
				 avalue   => l_preparer_name );
      diagn_msg('Attribute PREPARER_NAME set to' || l_preparer_name);

      -- Copy displayed username to Workfow
      wf_engine.SetItemAttrText( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'PREPARER_DISPLAY_NAME',
				 avalue   => l_preparer_display_name );
      diagn_msg('Attribute PREPARER_DISPLAY_NAME set to '||l_preparer_display_name);
      result := 'COMPLETE:Y';
      return;
    END IF;

  ELSIF ( funcmode = 'CANCEL' ) THEN
    null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'is_employee_set',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END is_employee_set;


-- ****************************************************************************
--   get_sob_attributes
-- ****************************************************************************

PROCEDURE get_sob_attributes (itemtype  IN VARCHAR2,
			      itemkey   IN VARCHAR2,
			      actid     IN NUMBER,
			      funcmode  IN VARCHAR2,
			      result    OUT NOCOPY VARCHAR2) IS
  l_je_batch_id                NUMBER;
  l_current_ledger_id          NUMBER;
  l_ledger_id                  NUMBER;
  l_func_currency              VARCHAR2(15);
  l_average_balances_flag      VARCHAR2(1);
  l_cons_sob_flag              VARCHAR2(1);
  l_suspense_flag              VARCHAR2(1);
  l_period_set_name            VARCHAR2(15);
  l_budgetary_control_flag     VARCHAR2(1);
  l_enable_automatic_tax_flag  VARCHAR2(1);
  l_latest_encumbrance_year    VARCHAR2(15);
  recinfo                      gl_ledgers%ROWTYPE;

  l_ledger_approval_amount     NUMBER;

  CURSOR batch_ledgers (v_batch_id NUMBER, v_curr_ledger_id NUMBER) IS
    SELECT led.ledger_id
    FROM   GL_LEDGERS led
    WHERE  led.ledger_id IN (SELECT jeh.ledger_id
                             FROM   GL_JE_HEADERS jeh
                             WHERE  jeh.je_batch_id = v_batch_id)
    AND    led.ledger_id > v_curr_ledger_id
    ORDER BY led.ledger_id;

BEGIN

  IF ( funcmode = 'RUN' ) THEN
    -- Get JE batch ID
    l_je_batch_id := wf_engine.GetItemAttrNumber(
		itemtype  => itemtype,
		itemkey   => itemkey,
		aname     => 'BATCH_ID');

    -- Get current ledger ID
    l_current_ledger_id := wf_engine.GetItemAttrNumber(
		itemtype  => itemtype,
		itemkey   => itemkey,
		aname     => 'SET_OF_BOOKS_ID');

    OPEN batch_ledgers(l_je_batch_id, l_current_ledger_id);
    FETCH batch_ledgers INTO l_ledger_id;
    IF (batch_ledgers%NOTFOUND) THEN
      -- no more ledgers: reset Set of Books (Ledger) Attribute to -1
      CLOSE batch_ledgers;
      wf_engine.SetItemAttrText(itemtype => itemtype,
				itemkey  => itemkey,
				aname 	 => 'SET_OF_BOOKS_ID',
				avalue 	 => -1);
      result := 'COMPLETE:FAIL';
      return;
    END IF;
    CLOSE batch_ledgers;

    -- Retrieve set of books attributes
    recinfo.ledger_id := l_ledger_id;
    GL_LEDGERS_PKG.select_row(recinfo);

    l_func_currency := recinfo.currency_code;
    l_average_balances_flag := recinfo.enable_average_balances_flag;
    l_cons_sob_flag := recinfo.consolidation_ledger_flag;
    l_suspense_flag := recinfo.suspense_allowed_flag;
    l_period_set_name := recinfo.period_set_name;
    l_budgetary_control_flag := recinfo.enable_budgetary_control_flag;
    l_enable_automatic_tax_flag := recinfo.enable_automatic_tax_flag;
    l_latest_encumbrance_year := recinfo.latest_encumbrance_year;

    diagn_msg('Ledger Attributes retrieved from db');

    -- Set the corresponding attributes in workflow
    wf_engine.SetItemAttrText ( itemtype => itemtype,
			        itemkey  => itemkey,
  		 	        aname 	 => 'FUNC_CURRENCY',
			        avalue 	 => l_func_currency );
    diagn_msg('Get_SOB_Attributes: Func currency = '||l_func_currency);

    wf_engine.SetItemAttrNumber ( itemtype  => itemtype,
			      	  itemkey   => itemkey,
  		 	      	  aname     => 'SET_OF_BOOKS_ID',
			      	  avalue    => l_ledger_id );
    diagn_msg('Get_SOB_Attributes: Ledger id = ' ||to_char(l_ledger_id));

    wf_engine.SetItemAttrText ( itemtype   => itemtype,
			        itemkey    => itemkey,
  		 	        aname 	   => 'SUSPENSE_FLAG',
			        avalue 	   => l_suspense_flag );
    wf_engine.SetItemAttrText ( itemtype   => itemtype,
			        itemkey    => itemkey,
  		 	        aname 	   => 'AVERAGE_BALANCES_FLAG',
			        avalue 	   => l_average_balances_flag );
    wf_engine.SetItemAttrText ( itemtype => itemtype,
			        itemkey  => itemkey,
  		 	        aname 	 => 'CONS_SOB_FLAG',
			        avalue 	 => l_cons_sob_flag );
    wf_engine.SetItemAttrText ( itemtype => itemtype,
			        itemkey  => itemkey,
  		 	        aname 	 => 'BUDGETARY_CONTROL_FLAG',
			        avalue 	 => l_budgetary_control_flag );
    diagn_msg('Get_SOB_Attributes: budgetary control flag = '||l_budgetary_control_flag);

    wf_engine.SetItemAttrText ( itemtype => itemtype,
			        itemkey  => itemkey,
  		 	        aname 	 => 'AUTOMATIC_TAX_FLAG',
			        avalue 	 => l_enable_automatic_tax_flag );

    wf_engine.SetItemAttrNumber ( itemtype  => itemtype,
			      	  itemkey   => itemkey,
  		 	      	  aname     => 'LATEST_ENCUMBRANCE_YEAR',
			      	  avalue    => l_latest_encumbrance_year );

    SELECT max(abs(nvl(jel.accounted_dr, 0) - nvl(jel.accounted_cr, 0)))
    INTO   l_ledger_approval_amount
    FROM   GL_JE_HEADERS jeh, GL_JE_LINES jel
    WHERE  jeh.je_batch_id = l_je_batch_id
    AND    jeh.ledger_id = l_ledger_id
    AND    jeh.currency_code <> 'STAT'
    AND    jel.je_header_id = jeh.je_header_id;

    -- Copy the corresponding item attribute in workflow
    wf_engine.SetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'BATCH_TOTAL',
				 avalue   => l_ledger_approval_amount );

    result := 'COMPLETE:SUCCESS';

  ELSIF ( funcmode = 'CANCEL' ) THEN
    null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'get_sob_attributes',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
END get_sob_attributes;


-- ****************************************************************************
--   get_jeb_attributes
-- ****************************************************************************

PROCEDURE get_jeb_attributes(itemtype	IN VARCHAR2,
			     itemkey  	IN VARCHAR2,
			     actid	IN NUMBER,
			     funcmode	IN VARCHAR2,
                             result     OUT NOCOPY VARCHAR2) IS
  l_je_batch_id        NUMBER;
  l_je_batch_name      VARCHAR2(100);
  l_balance_type       VARCHAR2(1);
  l_budgetary_status   VARCHAR2(1);
  l_period_name        VARCHAR2(15);
  l_control_total      NUMBER;
  l_running_total_dr   NUMBER;
  l_running_total_cr   NUMBER;
  l_enter_journals     VARCHAR2(500);
BEGIN

  IF ( funcmode = 'RUN' ) THEN

    -- Get JE batch ID (primary key)
    l_je_batch_id := wf_engine.GetItemAttrNumber(
		itemtype  => itemtype,
		itemkey   => itemkey,
		aname     => 'BATCH_ID');

    diagn_msg('Executing Get_JEB_Attributes for JE batch '||to_char(l_je_batch_id));

    -- Get other batch info
    SELECT
           name,
           actual_flag,
           default_period_name,
           control_total,
           running_total_dr,
           running_total_cr,
           budgetary_control_status
    INTO   l_je_batch_name,
           l_balance_type,
	   l_period_name,
           l_control_total,
           l_running_total_dr,
           l_running_total_cr,
           l_budgetary_status
    FROM   GL_JE_BATCHES
    WHERE  je_batch_id = l_je_batch_id;

    diagn_msg('JEB Attributes retrieved from db');

    -- Copy JE batch name to corresponding item attribute in workflow
    wf_engine.SetItemAttrText ( itemtype => itemtype,
				itemkey  => itemkey,
				aname    => 'BATCH_NAME',
				avalue   => l_je_batch_name );
    diagn_msg('get_jeb_attributes JEB name = ' || l_je_batch_name);

    -- Copy JE batch period name to corresponding item attribute in workflow
    wf_engine.SetItemAttrText ( itemtype => itemtype,
				itemkey  => itemkey,
				aname    => 'PERIOD_NAME',
				avalue   => l_period_name );
    diagn_msg('get_jeb_attributes JEB period name = ' ||l_period_name );

    -- Copy control total of the batch in workflow
    wf_engine.SetItemAttrText ( itemtype => itemtype,
				itemkey  => itemkey,
				aname    => 'CONTROL_TOTAL',
				avalue   => l_control_total );

    -- Copy running totals of the batch in workflow
    wf_engine.SetItemAttrText ( itemtype => itemtype,
				itemkey  => itemkey,
				aname    => 'RUNNING_TOTAL_DR',
				avalue   => l_running_total_dr );
    wf_engine.SetItemAttrText ( itemtype => itemtype,
				itemkey  => itemkey,
				aname    => 'RUNNING_TOTAL_CR',
				avalue   => l_running_total_cr );

    -- Copy budgetary control status item attribute in workflow
    wf_engine.SetItemAttrText ( itemtype => itemtype,
				itemkey  => itemkey,
				aname    => 'BUDGETARY_CONTROL_STATUS',
				avalue   => l_budgetary_status );
    diagn_msg('get_jeb_attributes budgetary control status = ' || l_budgetary_status);

    -- Copy actual flag to corresponding item attribute in workflow
    wf_engine.SetItemAttrText ( itemtype => itemtype,
				itemkey  => itemkey,
				aname    => 'BALANCE_TYPE',
				avalue   => l_balance_type );
    diagn_msg('get_jeb_attributes: Balance Type = ' || l_balance_type);

    -- Based on the balance type, populate the enter_journals variable.
    IF (l_balance_type = 'E') THEN
      l_enter_journals := 'GLXJEENT_E:autoquery_level=BATCH ' ||
                          'autoquery_coordination=INITIAL ' ||
                          'autoquery_criteria=' || to_char(l_je_batch_id);
    ELSE
      l_enter_journals := 'GLXJEENT_A:autoquery_level=BATCH ' ||
                          'autoquery_coordination=INITIAL ' ||
                          'autoquery_criteria=' || to_char(l_je_batch_id);
    END IF;

    wf_engine.SetItemAttrText ( itemtype => itemtype,
				itemkey  => itemkey,
				aname    => 'ENTER_JOURNALS_FORM',
				avalue   => l_enter_journals );

    diagn_msg('JEB Attributes stored in WF tables');

  ELSIF ( funcmode = 'CANCEL' ) THEN
    null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'get_jeb_attributes',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END get_jeb_attributes;


-- ****************************************************************************
--   is_je_valid
-- ****************************************************************************

PROCEDURE is_je_valid(itemtype  IN VARCHAR2,
		      itemkey  	IN VARCHAR2,
		      actid     IN NUMBER,
		      funcmode  IN VARCHAR2,
		      result    OUT NOCOPY VARCHAR2) IS
  l_je_batch_id         	NUMBER;
  l_untaxed_cursor      	VARCHAR2(20);
  l_balance_type        	VARCHAR2(1);
  l_budgetary_control_flag  	VARCHAR2(1);
  l_budgetary_status      	VARCHAR2(1);
  l_control_total               NUMBER;
  l_running_total_dr            NUMBER;
  l_running_total_cr            NUMBER;
  l_invalid_error               VARCHAR2(2000);

  CURSOR check_untaxed IS
    SELECT 'untaxed journals'
    FROM DUAL
    WHERE EXISTS
          (SELECT 'UNTAXED'
           FROM   GL_JE_HEADERS JEH, GL_LEDGERS LED
           WHERE  JEH.je_batch_id = l_je_batch_id
           AND    JEH.tax_status_code = 'R'
           AND    JEH.currency_code <> 'STAT'
           AND    JEH.je_source = 'Manual'
           AND    LED.ledger_id = JEH.ledger_id
           AND    enable_automatic_tax_flag = 'Y');
BEGIN

  IF ( funcmode = 'RUN' ) THEN

    -- Get the batch id
    l_je_batch_id := wf_engine.GetItemAttrNumber(
                itemtype  => itemtype,
                itemkey   => itemkey,
                aname     => 'BATCH_ID');
    diagn_msg('Is JE Valid: Batch Id = ' || to_char(l_je_batch_id));

    -- Get the control total and running totals for the batch.
    l_control_total := wf_engine.GetItemAttrNumber(
                itemtype  => itemtype,
                itemkey   => itemkey,
                aname     => 'CONTROL_TOTAL');
    diagn_msg('Is JE Valid: Control Total = ' ||to_char(l_control_total));
    l_running_total_dr := wf_engine.GetItemAttrNumber(
                itemtype  => itemtype,
                itemkey   => itemkey,
                aname     => 'RUNNING_TOTAL_DR');
    diagn_msg('Is JE Valid: Running Total Debit = ' ||to_char(l_running_total_dr));
    l_running_total_cr := wf_engine.GetItemAttrNumber(
                itemtype  => itemtype,
                itemkey   => itemkey,
                aname     => 'RUNNING_TOTAL_CR');
    diagn_msg('Is JE Valid: Running Total Credit = ' ||to_char(l_running_total_cr));

    -- Get the actual flag
    l_balance_type := wf_engine.GetItemAttrText(
                itemtype  => itemtype,
                itemkey   => itemkey,
                aname     => 'BALANCE_TYPE');
    diagn_msg('Is JE Valid: Balance Type = ' ||l_balance_type);

    -- Get the budgetary control status
    l_budgetary_status :=  wf_engine.GetItemAttrText(
                itemtype  => itemtype,
                itemkey   => itemkey,
                aname     => 'BUDGETARY_CONTROL_STATUS');
    diagn_msg('Is JE Valid: Budgetary Control Status = ' ||l_budgetary_status);

    -- Check whether the batch contains untaxed journals.
    IF (l_balance_type = 'A') THEN
      OPEN check_untaxed;
      FETCH check_untaxed INTO l_untaxed_cursor;

      IF check_untaxed%FOUND THEN
        CLOSE check_untaxed;
        FND_MESSAGE.Set_Name('SQLGL', 'GL_WF_INVALID_UNTAXED');
        l_invalid_error := FND_MESSAGE.Get;
        wf_engine.SetItemAttrText( itemtype,
				   itemkey,
				   'INVALID_JE_ERROR',
				   l_invalid_error );
        result := 'COMPLETE:N';
        return;
      END IF;
      CLOSE check_untaxed;
    END IF;

    -- Check if budgetary control is on but funds have not been reserved.
    SELECT nvl(max(led.enable_budgetary_control_flag), 'N')
    INTO   l_budgetary_control_flag
    FROM   GL_JE_HEADERS jeh, GL_LEDGERS led
    WHERE  jeh.je_batch_id = l_je_batch_id
    AND    led.ledger_id = jeh.ledger_id
    AND    led.enable_budgetary_control_flag = 'Y';

    IF (l_budgetary_control_flag = 'Y' AND
       l_budgetary_status <> 'P'
       AND l_balance_type <> 'B') THEN  /* added this condition for bug7531835 */
      FND_MESSAGE.Set_Name('SQLGL', 'GL_WF_INVALID_RESERVE_FUNDS');
      l_invalid_error := FND_MESSAGE.Get;
      wf_engine.SetItemAttrText( itemtype,
				 itemkey,
				 'INVALID_JE_ERROR',
				 l_invalid_error );
      result := 'COMPLETE:N';
      return;
    END IF;

    -- Make sure the control total matches the
    -- running totals
    IF (   l_control_total IS NULL
        OR (    l_balance_type IN ('A', 'E')
            AND l_running_total_dr = l_control_total)
        OR (    l_balance_type = 'B'
            AND greatest(l_running_total_cr, l_running_total_dr)
                = l_control_total)
       ) THEN
      null;
    ELSE
      FND_MESSAGE.Set_Name('SQLGL', 'GL_WF_INVALID_CONTROL_TOTAL');
      l_invalid_error := FND_MESSAGE.Get;
      wf_engine.SetItemAttrText( itemtype,
			         itemkey,
			         'INVALID_JE_ERROR',
			         l_invalid_error);
      result := 'COMPLETE:N';
      return;
    END IF;

    -- If the batch passes all the above checks, then its valid.
    result := 'COMPLETE:Y';

  ELSIF (funcmode = 'CANCEL') THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'is_je_valid',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
END is_je_valid;


-- ****************************************************************************
--   set_je_invalid
-- ****************************************************************************

PROCEDURE set_je_invalid(itemtype    IN VARCHAR2,
			 itemkey     IN VARCHAR2,
			 actid       IN NUMBER,
			 funcmode    IN VARCHAR2,
			 result      OUT NOCOPY VARCHAR2) IS
  l_je_batch_id    NUMBER;
BEGIN
  IF ( funcmode = 'RUN' ) THEN
    -- Get JE batch ID
    l_je_batch_id := wf_engine.GetItemAttrNumber(
		itemtype  => itemtype,
		itemkey   => itemkey,
		aname     => 'BATCH_ID');

    UPDATE GL_JE_BATCHES
    SET    approval_status_code = 'V'
    WHERE  je_batch_id = l_je_batch_id;

  ELSIF ( funcmode = 'CANCEL' ) THEN
    null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'set_je_invalid',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
END set_je_invalid;


-- ****************************************************************************
--   does_je_need_approval
-- ****************************************************************************

PROCEDURE does_je_need_approval(itemtype  IN VARCHAR2,
				itemkey   IN VARCHAR2,
				actid     IN NUMBER,
				funcmode  IN VARCHAR2,
				result    OUT NOCOPY VARCHAR2) IS
  l_je_batch_id      NUMBER;
  l_non_stat_cursor  VARCHAR2(40);

  CURSOR non_stat IS
    SELECT 'non stat journal exists'
    FROM   DUAL
    WHERE  EXISTS
           (SELECT 'X'
            FROM   GL_JE_HEADERS
            WHERE  je_batch_id = l_je_batch_id
            AND    currency_code <> 'STAT');
BEGIN
  IF ( funcmode = 'RUN' ) THEN
    -- Get JE batch ID (primary key)
    l_je_batch_id := wf_engine.GetItemAttrNumber(
		itemtype  => itemtype,
		itemkey   => itemkey,
		aname     => 'BATCH_ID');

    -- Check whether STAT journal exists
    OPEN non_stat;
    FETCH non_stat INTO l_non_stat_cursor;

    IF non_stat%FOUND THEN
      CLOSE non_stat;
      result := 'COMPLETE:Y';
    ELSE
      CLOSE non_stat;
      result := 'COMPLETE:N';
    END IF;

  ELSIF ( funcmode = 'CANCEL' ) THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'does_je_need_approval',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
END does_je_need_approval;


-- ****************************************************************************
--   set_approval_not_required
-- ****************************************************************************

PROCEDURE set_approval_not_required(itemtype    IN VARCHAR2,
				    itemkey     IN VARCHAR2,
				    actid       IN NUMBER,
				    funcmode    IN VARCHAR2,
				    result     OUT NOCOPY VARCHAR2) IS
  l_je_batch_id   NUMBER;
BEGIN
  IF ( funcmode = 'RUN' ) THEN
    -- Get JE batch ID
    l_je_batch_id := wf_engine.GetItemAttrNumber(
		itemtype  => itemtype,
		itemkey   => itemkey,
		aname     => 'BATCH_ID');

    UPDATE GL_JE_BATCHES
    SET    approval_status_code = 'A'
    WHERE  je_batch_id = l_je_batch_id;

  ELSIF ( funcmode = 'CANCEL' ) THEN
    null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'set_approval_not_required',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
END set_approval_not_required;


-- ****************************************************************************
--   can_preparer_approve
-- ****************************************************************************

PROCEDURE can_preparer_approve(itemtype   IN VARCHAR2,
			       itemkey    IN VARCHAR2,
			       actid      IN NUMBER,
			       funcmode   IN VARCHAR2,
			       result     OUT NOCOPY VARCHAR2) IS
  l_preparer_id          NUMBER;
  l_batch_id             NUMBER;
  l_profile_option_val   fnd_profile_option_values.profile_option_value%TYPE;
BEGIN
  IF ( funcmode = 'RUN' ) THEN
    -- Get the preparer_id
    l_preparer_id := wf_engine.GetItemAttrNumber(
                itemtype  => itemtype,
                itemkey   => itemkey,
                aname     => 'PREPARER_ID');

    -- Get batch id
    l_batch_id := wf_engine.GetItemAttrNumber(
                itemtype  => itemtype,
                itemkey   => itemkey,
                aname     => 'BATCH_ID');

    -- Get the profile option value
    FND_PROFILE.GET('GL_ALLOW_PREPARER_APPROVAL', l_profile_option_val);
    IF (l_profile_option_val IS NULL) THEN
      l_profile_option_val := 'N';
    END IF;

    IF (    l_profile_option_val = 'Y'
        AND check_authorization_limit(l_preparer_id, l_batch_id)) THEN
      result := 'COMPLETE:Y';
    ELSE
      result := 'COMPLETE:N';
    END IF;

  ELSIF ( funcmode = 'CANCEL' ) THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'can_preparer_approve',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
END can_preparer_approve;


-- ****************************************************************************
--   set_approver_name
-- ****************************************************************************

PROCEDURE set_approver_name (itemtype   IN VARCHAR2,
		             itemkey    IN VARCHAR2,
		             actid      IN NUMBER,
		             funcmode   IN VARCHAR2,
                             result     OUT NOCOPY VARCHAR2) IS
  l_preparer_id	NUMBER;
  l_preparer_name VARCHAR2(240);
  l_preparer_display_name  VARCHAR2(240);
BEGIN
  IF ( funcmode = 'RUN' ) THEN
    l_preparer_id :=  wf_engine.GetItemAttrNumber(
		itemtype  => itemtype,
		itemkey   => itemkey,
		aname     => 'PREPARER_ID' );
    l_preparer_name := wf_engine.GetItemAttrText(
		itemtype  => itemtype,
		itemkey   => itemkey,
		aname     => 'PREPARER_NAME');
    l_preparer_display_name := wf_engine.GetItemAttrText(
		itemtype  => itemtype,
		itemkey   => itemkey,
		aname     => 'PREPARER_DISPLAY_NAME');

    wf_engine.SetItemAttrNumber( itemtype  => itemtype,
			         itemkey   => itemkey,
  		 	      	 aname 	   => 'APPROVER_ID',
			      	 avalue    => l_preparer_id );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'APPROVER_NAME',
			       avalue 	 => l_preparer_name );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'APPROVER_DISPLAY_NAME',
			       avalue 	 => l_preparer_display_name );
    diagn_msg('Approver name set for JE batch ');

  ELSIF ( funcmode = 'CANCEL' ) THEN
    null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'set_approver_name',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
END set_approver_name;


-- ****************************************************************************
--   set_je_approver
-- ****************************************************************************

PROCEDURE set_je_approver (itemtype	IN VARCHAR2,
			   itemkey	IN VARCHAR2,
			   actid	IN NUMBER,
			   funcmode	IN VARCHAR2,
			   result	OUT NOCOPY VARCHAR2) IS
  l_je_batch_id  NUMBER;
  l_approver_id  NUMBER;
BEGIN
  IF (funcmode = 'RUN') THEN
    l_je_batch_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
						  itemkey   => itemkey,
						  aname     => 'BATCH_ID' );
    l_approver_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
						  itemkey   => itemkey,
						  aname     => 'APPROVER_ID' );

    UPDATE GL_JE_BATCHES
    SET    approver_employee_id = l_approver_id
    WHERE  je_batch_id = l_je_batch_id;

  ELSIF (funcmode = 'CANCEL') THEN
    null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'set_je_approver',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
END set_je_approver;


-- ****************************************************************************
--   approve_je
-- ****************************************************************************

PROCEDURE approve_je (itemtype	   IN VARCHAR2,
		      itemkey      IN VARCHAR2,
		      actid	   IN NUMBER,
		      funcmode	   IN VARCHAR2,
		      result       OUT NOCOPY VARCHAR2) IS
  l_je_batch_id   NUMBER;
  l_param_list    WF_PARAMETER_LIST_T := wf_parameter_list_t();
BEGIN
  IF ( funcmode = 'RUN' ) THEN
    diagn_msg('Executing Approve_JE');
    l_je_batch_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
						  itemkey   => itemkey,
						  aname     => 'BATCH_ID' );

    UPDATE GL_JE_BATCHES
    SET    approval_status_code = 'A'
    WHERE  je_batch_id = l_je_batch_id;

--    diagn_msg('JE batch '||to_char(l_je_batch_id)||' is approved');

    -- Raise business event for journal approved
    WF_EVENT.AddParameterToList(p_name          => 'BATCH_ID',
                                p_value         => to_char(l_je_batch_id),
                                p_parameterlist => l_param_list);
    WF_EVENT.raise(p_event_name => 'oracle.apps.gl.Journals.journal.approve',
                   p_event_key  => itemkey,
                   p_parameters => l_param_list);

  ELSIF ( funcmode = 'CANCEL' ) THEN
    null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'approve_je',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
END approve_je;


-- ****************************************************************************
--   reject_je
-- ****************************************************************************

PROCEDURE reject_je (itemtype	IN VARCHAR2,
		     itemkey  	IN VARCHAR2,
		     actid	IN NUMBER,
		     funcmode	IN VARCHAR2,
                     result     OUT NOCOPY VARCHAR2) IS
  l_je_batch_id   NUMBER;
BEGIN
  IF ( funcmode = 'RUN' ) THEN
    l_je_batch_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
						  itemkey   => itemkey,
						  aname     => 'BATCH_ID' );

    UPDATE GL_JE_BATCHES
    SET    approval_status_code = 'J'
    WHERE  je_batch_id = l_je_batch_id;

  ELSIF ( funcmode = 'CANCEL' ) THEN
    null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'reject_je',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
END reject_je;


-- ****************************************************************************
--   find_approver
-- ****************************************************************************

PROCEDURE find_approver(item_type  IN VARCHAR2,
			item_key   IN VARCHAR2,
			actid      IN NUMBER,
			funcmode   IN VARCHAR2,
			result     OUT NOCOPY VARCHAR2) IS
  l_employee_id			NUMBER;
  l_resp_id                     NUMBER;
  l_user_id                     NUMBER;
  l_curr_approver_id		NUMBER		:= NULL;
  l_next_approver_id		NUMBER		:= NULL;
  l_dir_manager_id		NUMBER		:= NULL;
  l_find_approver_method	VARCHAR2(240);
  l_preparer_name		VARCHAR2(240);
  l_preparer_display_name       VARCHAR2(240);
  l_defined                     BOOLEAN;
  l_find_approver_counter	NUMBER;
  l_error_message               VARCHAR2(2000);
BEGIN

  IF (funcmode = 'RUN') THEN
    diagn_msg('Entering Find_Approver activity');

    l_employee_id := wf_engine.GetItemAttrNumber(item_type,
						 item_key,
						 'PREPARER_ID');
    l_curr_approver_id := wf_engine.GetItemAttrNumber(item_type,
						      item_key,
						      'APPROVER_ID');
    l_resp_id := wf_engine.GetItemAttrNumber(item_type,
					     item_key,
					     'PREPARER_RESP_ID');
    l_user_id := wf_engine.GetItemAttrNumber(item_type,
					     item_key,
					     'PREPARER_FND_ID');

    -- Get the profile option value for approver method
    FND_PROFILE.GET_SPECIFIC('GL_FIND_APPROVER_METHOD',
                              l_user_id,
                              l_resp_id,
                              101,
                              l_find_approver_method,
                              l_defined);

    IF (l_find_approver_method IS NULL) THEN
      l_find_approver_method := 'CHAIN';
    END IF;

    l_find_approver_counter := wf_engine.GetItemAttrNumber(
					item_type,
					item_key,
					'FIND_APPROVER_COUNTER');

    IF (l_find_approver_counter = 0) THEN

      diagn_msg('Find_Approver activity is called for the first time.');

      getmanager(l_employee_id, l_dir_manager_id);
      setpersonas(l_dir_manager_id,
		  item_type,
		  item_key,
		  'MANAGER');

      IF (l_dir_manager_id IS NOT NULL) THEN
        l_next_approver_id := l_dir_manager_id;
      ELSE
        FND_MESSAGE.Set_Name('SQLGL', 'GL_WF_CANNOT_FIND_MANAGER');
        l_error_message := FND_MESSAGE.Get;

	wf_engine.SetItemAttrText( item_type,
				   item_key,
				   'ERROR_MESSAGE',
				   l_error_message);

        result := 'COMPLETE:N';
      END IF;

    END IF;

    IF (l_curr_approver_id IS NOT NULL OR
	l_find_approver_method = 'DIRECT') THEN

      diagn_msg('Find_Approver: Calling Get Approver');

      GetApprover(l_employee_id,
		  item_type,
                  item_key,
		  l_curr_approver_id,
       		  l_find_approver_method,
		  l_next_approver_id);

    END IF;

    IF (l_next_approver_id IS NULL) THEN
      FND_MESSAGE.Set_Name('SQLGL', 'GL_WF_CANNOT_FIND_APPROVER');
      l_error_message := FND_MESSAGE.Get;

      WF_ENGINE.SetItemAttrText( item_type,
				 item_key,
				'ERROR_MESSAGE',
				l_error_message);

      result := 'COMPLETE:N';
    ELSE
      setpersonas(l_next_approver_id,
		  item_type,
		  item_key,
		  'APPROVER');

      WF_ENGINE.SetItemAttrNumber(item_type,
				  item_key,
				  'FIND_APPROVER_COUNTER',
				  l_find_approver_counter + 1);

      result := 'COMPLETE:Y';
    END IF;

  ELSIF (funcmode = 'CANCEL') THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'Find_Approver',
                    item_type, item_key, to_char(actid), funcmode);
    raise;

END find_approver;


-- ****************************************************************************
--   first_approver
-- ****************************************************************************

PROCEDURE first_approver(item_type    IN VARCHAR2,
			 item_key     IN VARCHAR2,
			 actid        IN NUMBER,
			 funcmode     IN VARCHAR2,
			 result       OUT NOCOPY VARCHAR2) IS
  l_find_approver_counter      NUMBER;
  l_preparer_name              VARCHAR2(240);
  l_forward_comment_from       VARCHAR2(300);
  l_forward_from_display_name  VARCHAR2(240);
BEGIN
  IF (funcmode = 'RUN') THEN
    diagn_msg('First_Approver: Retrieving Find_Approver_Counter Item Attribute');

    l_find_approver_counter := WF_ENGINE.GetItemAttrNumber(
				item_type,
				item_key,
				'FIND_APPROVER_COUNTER');

    -- Set the approver comment attribute to null
    WF_ENGINE.SetItemAttrText(item_type,
			      item_key,
			      'APPROVER_COMMENT',
			      '');

    IF (l_find_approver_counter = 1) THEN
      result := 'COMPLETE:Y';

      --bugfix 2926418
      WF_ENGINE.SetItemAttrText(item_type,
				item_key,
				'COMMENT_FROM',
				'');

      -- Put preparer name as the forward from name
      l_preparer_name := WF_ENGINE.GetItemAttrText(
				item_type,
				item_key,
				'PREPARER_NAME');
      WF_ENGINE.SetItemAttrText(item_type,
				item_key,
				'FORWARD_FROM_NAME',
				l_preparer_name);
    ELSE
      result := 'COMPLETE:N';

      --bugfix 2926418
      l_forward_from_display_name := WF_ENGINE.GetItemAttrText(
				item_type,
				item_key,
				'FORWARD_FROM_DISPLAY_NAME');

      FND_MESSAGE.Set_Name('SQLGL', 'GL_WF_FORWARD_COMMENT_FROM');
      FND_MESSAGE.Set_Token('APPROVER_NAME', l_forward_from_display_name);
      l_forward_comment_from := FND_MESSAGE.Get;

      WF_ENGINE.SetItemAttrText(item_type,
				item_key,
				'COMMENT_FROM',
				l_forward_comment_from);
    END IF;

  ELSIF (funcmode = 'CANCEL') THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'first_approver',
                    item_type, item_key, to_char(actid), funcmode);
    raise;
END first_approver;


-- ****************************************************************************
--   set_curr_approver
-- ****************************************************************************

PROCEDURE set_curr_approver(itemtype	IN VARCHAR2,
			    itemkey	IN VARCHAR2,
			    actid	IN NUMBER,
			    funcmode	IN VARCHAR2,
			    result	OUT NOCOPY VARCHAR2) IS
  l_TransferToID       NUMBER;
  l_Transferee         wf_users.name%type;
  l_TransferToName     wf_users.name%type;
  l_role               wf_roles.name%type;
  l_notification_id    number;

  CURSOR c_person_id IS
    SELECT orig_system_id
    FROM   wf_roles
    WHERE  orig_system = 'PER'
    AND    name = l_role;

BEGIN

  IF  (funcmode = 'RESPOND') THEN
    -- wf_engine.context_text = new responder
    l_notification_id := wf_engine.context_nid;

    SELECT original_recipient
    INTO   l_role
    FROM   wf_notifications
    WHERE  notification_id = l_notification_id;

    l_Transferee := wf_engine.context_text;

    OPEN c_person_id;
    FETCH c_person_id into l_TransferToID;

    IF c_person_id%NOTFOUND THEN
      result := wf_engine.eng_completed || ':' || wf_engine.eng_null;
      Wf_Core.Raise(wf_core.translate('NO_ROLE_FOUND'));
      RETURN;
    ELSE
      IF l_TransferToID IS NULL THEN
        result := wf_engine.eng_completed || ':' || wf_engine.eng_null;
        Wf_Core.Raise(wf_core.translate('PERSON_ID_NULL'));
        RETURN;
      END IF;
    END IF;

    CLOSE c_person_id;

    -- set approver name and approver display name
    setpersonas(l_TransferToID,
                itemtype,
	        itemkey,
                'APPROVER');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'set_curr_approver', itemtype, itemkey);
    raise;
END set_curr_approver;


-- ****************************************************************************
--   mgr_equalto_aprv
-- ****************************************************************************

PROCEDURE mgr_equalto_aprv(item_type	IN VARCHAR2,
			   item_key	IN VARCHAR2,
			   actid	IN NUMBER,
			   funcmode	IN VARCHAR2,
			   result	OUT NOCOPY VARCHAR2) IS
  l_approver_id    NUMBER;
  l_manager_id     NUMBER;
BEGIN
  IF (funcmode = 'RUN') THEN
    l_approver_id := WF_ENGINE.GetItemAttrNumber(item_type,
						 item_key,
						 'APPROVER_ID');

    l_manager_id := WF_ENGINE.GetItemAttrNumber(item_type,
						item_key,
						'MANAGER_ID');

    IF (l_approver_id <> l_manager_id) THEN
      result := 'COMPLETE:N';
    ELSE
      result := 'COMPLETE:Y';
    END IF;

  ELSIF (funcmode = 'CANCEL') THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'mgr_equalto_aprv',
                    item_type, item_key, to_char(actid), funcmode);
    raise;
END mgr_equalto_aprv;


-- ****************************************************************************
--   notifyprep_noaprvresp
-- ****************************************************************************

PROCEDURE notifyprep_noaprvresp(item_type  IN VARCHAR2,
				item_key   IN VARCHAR2,
				actid      IN NUMBER,
				funcmode   IN VARCHAR2,
				result     OUT NOCOPY VARCHAR2) IS
  l_approver_id		NUMBER;
  l_manager_id		NUMBER;
  l_count		NUMBER;
  l_limit		NUMBER;
BEGIN
  IF (funcmode = 'RUN') THEN
    l_count := WF_ENGINE.GetItemAttrNumber(item_type,
					   item_key,
					   'MANAGER_APPROVAL_SEND_COUNT');

    l_limit := WF_ENGINE.GetActivityAttrNumber(item_type,
					       item_key,
					       actid,
					       'MANAGER_SEND_LIMIT');

    WF_ENGINE.SetItemAttrNumber(item_type,
				item_key,
				'MANAGER_APPROVAL_SEND_COUNT',
				l_count + 1);

    IF (l_count+1 >= l_limit) THEN
      WF_ENGINE.SetItemAttrNumber(item_type,
				  item_key,
				  'MANAGER_APPROVAL_SEND_COUNT',
				  0);
      result := 'COMPLETE:Y';
    ELSE
      result := 'COMPLETE:N';
    END IF;

  ELSIF (funcmode = 'CANCEL') THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'notifyprep_noaprvresp',
                     item_type, item_key, to_char(actid), funcmode);
    raise;
END notifyprep_noaprvresp;


-- ****************************************************************************
--   get_approver_manager
-- ****************************************************************************

PROCEDURE get_approver_manager(item_type	IN VARCHAR2,
		     	       item_key		IN VARCHAR2,
		     	       actid		IN NUMBER,
		     	       funcmode		IN VARCHAR2,
		     	       result		OUT NOCOPY VARCHAR2) IS
  l_approver_id    NUMBER;
  l_manager_id     NUMBER;
BEGIN

  IF ( funcmode = 'RUN' ) THEN
    l_approver_id := WF_ENGINE.GetItemAttrNumber( item_type,
						  item_key,
						  'APPROVER_ID' );

    getmanager(l_approver_id, l_manager_id);

    IF (l_manager_id IS NULL) THEN
      result := 'COMPLETE:FAIL';
    ELSE
      setpersonas(l_manager_id,
                  item_type,
	          item_key,
                  'APPROVER');
      result := 'COMPLETE:PASS';
    END IF;

  ELSIF ( funcmode = 'CANCEL' ) THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'get_approver_manager',
                    item_type, item_key, to_char(actid), funcmode);
    raise;
END get_approver_manager;


-- ****************************************************************************
--   record_forward_from_info
-- ****************************************************************************

PROCEDURE record_forward_from_info(item_type  IN VARCHAR2,
				   item_key   IN VARCHAR2,
				   actid      IN NUMBER,
				   funcmode   IN VARCHAR2,
				   result     OUT NOCOPY VARCHAR2) IS
  l_approver_id            NUMBER;
  l_approver_name          VARCHAR2(240);
  l_approver_display_name  VARCHAR2(240);
  l_approver_comment       VARCHAR2(2000);
BEGIN
  IF (funcmode = 'RUN') THEN
    l_approver_id := WF_ENGINE.GetItemAttrNumber(item_type,
						 item_key,
						 'APPROVER_ID');

    l_approver_name := WF_ENGINE.GetItemAttrText(item_type,
						 item_key,
						 'APPROVER_NAME');

    l_approver_display_name := WF_ENGINE.GetItemAttrText(
						item_type,
						item_key,
						'APPROVER_DISPLAY_NAME');

    l_approver_comment := WF_ENGINE.GetItemAttrText(item_type,
						    item_key,
						    'APPROVER_COMMENT');

    WF_ENGINE.SetItemAttrNumber(item_type,
				item_key,
				'FORWARD_FROM_ID',
				l_approver_id);

    WF_ENGINE.SetItemAttrText(item_type,
			      item_key,
			      'FORWARD_FROM_NAME',
			      l_approver_name);

    WF_ENGINE.SetItemAttrText(item_type,
			      item_key,
			      'FORWARD_FROM_DISPLAY_NAME',
			      l_approver_display_name);

    -- bugfix 2926418
    WF_ENGINE.SetItemAttrText(item_type,
			      item_key,
			      'FORWARD_APPROVER_COMMENT',
			      l_approver_comment);

  ELSIF (funcmode = 'CANCEL') THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'record_forward_from_info',
                     item_type, item_key, to_char(actid), funcmode);
    raise;
END record_forward_from_info;


-- ****************************************************************************
--   verify_authority
-- ****************************************************************************

PROCEDURE verify_authority(itemtype	IN VARCHAR2,
			   itemkey	IN VARCHAR2,
			   actid	IN NUMBER,
			   funcmode	IN VARCHAR2,
			   result	OUT NOCOPY VARCHAR2) IS
  l_approver_id    NUMBER;
  l_batch_id       NUMBER;
BEGIN
  IF ( funcmode = 'RUN' ) THEN

    diagn_msg('Executing Verify_Authority');
    l_approver_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
						  itemkey  => itemkey,
						  aname    => 'APPROVER_ID' );
    l_batch_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
					       itemkey   => itemkey,
					       aname     => 'BATCH_ID' );

    IF (check_authorization_limit(l_approver_id, l_batch_id)) THEN
      result := 'COMPLETE:PASS';
    ELSE
      result := 'COMPLETE:FAIL';
    END IF;

  ELSIF ( funcmode = 'CANCEL' ) THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'verify_authority',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
END verify_authority;


-- ****************************************************************************
--   Abort_Process
-- ****************************************************************************

PROCEDURE abort_process(itemtype IN VARCHAR2,
                        itemkey  IN VARCHAR2,
                        actid    IN NUMBER,
                        funcmode IN VARCHAR2,
                        result OUT NOCOPY VARCHAR2) IS
  l_je_batch_id   NUMBER;
BEGIN
  IF (funcmode = 'RUN') THEN
    -- reset approval status of JE batch back to 'Required'
    l_je_batch_id :=  wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => 'BATCH_ID');

    UPDATE GL_JE_BATCHES
    SET    approval_status_code = 'R'
    WHERE  je_batch_id = l_je_batch_id;

    -- then abort the process
    WF_ENGINE.AbortProcess(itemtype, itemkey, '', WF_ENGINE.eng_timeout);

  ELSIF (funcmode = 'CANCEL') THEN
    null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'abort_process',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
END abort_process;


END GL_WF_JE_APPROVAL_PKG;

/
