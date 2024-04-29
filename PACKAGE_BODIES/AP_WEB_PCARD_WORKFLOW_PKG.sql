--------------------------------------------------------
--  DDL for Package Body AP_WEB_PCARD_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_PCARD_WORKFLOW_PKG" AS
/* $Header: apwpcwfb.pls 120.12.12010000.2 2009/08/21 09:14:42 syeluri ship $ */

PROCEDURE DistributeEmpVerifications (errbuf		OUT NOCOPY VARCHAR2,
				      retcode		OUT NOCOPY  NUMBER,
                                      p_card_program_id	IN NUMBER DEFAULT NULL,
				      p_employee_id	IN NUMBER DEFAULT NULL,
				      p_status_lookup_code IN VARCHAR2,
				      p_org_id IN NUMBER)
IS
  l_item_type			 VARCHAR2(100) := 'APEMPVFY';
  l_item_key			 VARCHAR2(100);
  l_employee_id			 NUMBER;
  l_status_lookup_code		 VARCHAR2(15);
  l_employee_name                wf_users.name%type; --8770726
  l_employee_display_name	 wf_users.display_name%type; --8770726
  l_employee_notification_method AP_CARD_PROFILES.emp_notification_lookup_code%TYPE;
  l_new_emp_verification_id	 NUMBER;
  l_num_records_updated		 NUMBER;
  l_lines_without_dists_flag     BOOLEAN := FALSE;
  l_url				 VARCHAR2(1000);
  l_debug_info			 VARCHAR2(200);
  l_test number;
--bug5058949
--Performance fix

  CURSOR Emp_Verification_Workflows IS
   SELECT decode(nvl(fl.create_distribution_flag,'N'),
                                'N', 'I', cp.emp_notification_lookup_code),
           decode(cp.emp_notification_lookup_code, 'N', null, fl.employee_id),
           decode(cp.emp_notification_lookup_code, 'Y',
                                fd.status_lookup_code, null)
    FROM   ap_expense_feed_lines fl,
           ap_expense_feed_dists_all fd,
           ap_cards_all c,
           ap_card_profiles_all cp,
           IBY_CREDITCARD IBY
    WHERE  fl.create_distribution_flag = 'Y'    AND
           fd.feed_line_id = fl.feed_line_id    AND
           fd.status_lookup_code =
           nvl(p_status_lookup_code,fd.status_lookup_code) AND
           fd.status_lookup_code IN ('VALIDATED', 'HOLD', 'REJECTED') AND
           fd.employee_verification_id IS NULL AND
           fl.card_id = c.card_id  AND
           c.card_reference_id=IBY.instrid AND
           c.profile_id = cp.profile_id AND
           (
            (p_card_program_id IS NULL) OR
            (cp.card_program_id = p_card_program_id)
           )
    AND    (
            (p_employee_id IS NULL) OR
            (fl.employee_id = p_employee_id)
           )
    GROUP BY decode(nvl(fl.create_distribution_flag,'N'),
                                'N', 'I', cp.emp_notification_lookup_code),
            decode(cp.emp_notification_lookup_code, 'N', null, fl.employee_id),
            decode(cp.emp_notification_lookup_code, 'Y',
                                        fd.status_lookup_code, null),fl.org_id
    UNION
    SELECT decode(nvl(fl.create_distribution_flag,'N'),
                                'N', 'I', cp.emp_notification_lookup_code),
           decode(cp.emp_notification_lookup_code, 'N', null, fl.employee_id),
           decode(cp.emp_notification_lookup_code, 'Y',
                                fd.status_lookup_code, null)
    FROM   ap_expense_feed_lines fl,
           ap_expense_feed_dists_all fd,
           ap_cards_all c,
           ap_card_profiles_all cp,
           IBY_CREDITCARD IBY
    WHERE
    nvl(fl.create_distribution_flag,'N') = 'N' AND
    fl.employee_verification_id IS NULL AND
    fd.feed_line_id(+) = fl.feed_line_id    AND
    fl.employee_verification_id is null AND
    fl.card_id = c.card_id  AND
    c.card_reference_id=IBY.instrid AND
    c.profile_id = cp.profile_id AND
    (
     (p_card_program_id IS NULL) OR
     (cp.card_program_id = p_card_program_id)
    ) AND
    (
     (p_employee_id IS NULL) OR
     (fl.employee_id = p_employee_id)
    )
    GROUP BY decode(nvl(fl.create_distribution_flag,'N'),
                                'N', 'I', cp.emp_notification_lookup_code),
            decode(cp.emp_notification_lookup_code, 'N', null, fl.employee_id),
            decode(cp.emp_notification_lookup_code, 'Y',
                                        fd.status_lookup_code, null),fl.org_id;







      /*MOAC Changes->Group it according to org-id to
	send one notification for every org*/
BEGIN
  -----------------------------
  l_debug_info := 'Set Org ID';
  -----------------------------
/*  FND_CLIENT_INFO.SetUp_Client_Info(200,
 				    FND_GLOBAL.Resp_ID,
				    FND_GLOBAL.User_ID,
				    FND_GLOBAL.Security_Group_ID);*/
    /*Setting the MOAC Access*/
    Mo_global.init('SQLAP');
    if p_org_id is not null then
     Mo_Global.set_policy_context('S',p_org_id);
    else
     Mo_Global.set_policy_context('M',null);
    end if;

  OPEN Emp_Verification_Workflows;

  LOOP

    FETCH Emp_Verification_Workflows INTO l_employee_notification_method,
				          l_employee_id,
					  l_status_lookup_code;

    EXIT WHEN Emp_Verification_Workflows%NOTFOUND;

    ---------------------------------------------------------
    l_debug_info := ' Generate New Employee Verification ID';
    ---------------------------------------------------------
    SELECT ap_card_emp_verify_s.nextval
    INTO   l_new_emp_verification_id
    FROM   sys.dual;

    ------------------------------------------------------------------------
    l_debug_info := 'Mark records to be included with this verification_id';
    ------------------------------------------------------------------------
--bug5058949
--Performance fix

      UPDATE ap_expense_feed_lines fl
      SET    employee_verification_id = l_new_emp_verification_id
      WHERE  (create_distribution_flag = 'N' OR
              create_distribution_flag IS NULL)
      AND    employee_verification_id IS NULL
      AND    EXISTS (SELECT 'feed distribution falls in this workflow'
                     FROM   ap_expense_feed_dists fd,
	                    ap_cards c,
	                    ap_card_profiles cp,
	                    IBY_CREDITCARD IBY
                     WHERE  fl.feed_line_id = fd.feed_line_id
		     AND    c.card_reference_id=IBY.instrid
                     AND    fl.card_id = c.card_id
                     AND    c.profile_id = cp.profile_id
                     AND    cp.emp_notification_lookup_code
                                               = l_employee_notification_method
                     AND    decode(cp.emp_notification_lookup_code, 'N',
                                  1, fl.employee_id) = nvl(l_employee_id,1)
                     AND    decode(cp.emp_notification_lookup_code, 'R',
			fd.status_lookup_code,1) = nvl(l_status_lookup_code,1)
    		     AND    ((p_card_program_id IS NULL) OR
            			(cp.card_program_id = p_card_program_id))
    		     AND    ((p_employee_id IS NULL) OR
					(fl.employee_id = p_employee_id)) );
--bug5058949
--Performance fix

      UPDATE ap_expense_feed_dists fd
      SET    employee_verification_id = l_new_emp_verification_id
      WHERE  status_lookup_code in ('VALIDATED', 'HOLD', 'REJECTED')
      AND    employee_verification_id IS NULL
      AND    EXISTS (SELECT 'feed distribution falls in this workflow'
                     FROM   ap_expense_feed_lines fl,
	                    ap_cards c,
	                    ap_card_profiles cp,
	                    IBY_CREDITCARD IBY
                     WHERE  fl.feed_line_id = fd.feed_line_id
		     AND    c.card_reference_id=IBY.instrid
                     AND    fl.card_id = c.card_id
                     AND    c.profile_id = cp.profile_id
                     AND    cp.emp_notification_lookup_code
                                               = l_employee_notification_method
                     AND    decode(cp.emp_notification_lookup_code, 'N',
                                  1, fl.employee_id) = nvl(l_employee_id,1));

   -------------------------------------------------------------------
   l_debug_info := 'Make sure records where updated with this verification_id';
   --------------------------------------------------------------------
    SELECT count(*)
    INTO   l_num_records_updated
    FROM   ap_expense_feed_lines fl,
           ap_expense_feed_dists fd
    WHERE  fl.employee_verification_id = l_new_emp_verification_id
    OR     fd.employee_verification_id = l_new_emp_verification_id;

    IF (l_num_records_updated > 0) THEN
      l_item_key := to_char(l_new_emp_verification_id);

      --------------------------------------------------
      l_debug_info := 'Calling WorkFlow Create Process';
      --------------------------------------------------
      WF_ENGINE.CreateProcess(l_item_type,
	  		      l_item_key,
			      'MAIN_PROCESS');

      -------------------------------------------------------------
      l_debug_info := 'Set Emp Notification ID Item Attribute';
      -------------------------------------------------------------
      WF_ENGINE.SetItemAttrNumber(l_item_type,
			          l_item_key,
			          'EMPLOYEE_VERIFICATION_ID',
			          l_new_emp_verification_id);

      -------------------------------------------------------------
      l_debug_info := 'Set Emp Notification Method Item Attribute';
      -------------------------------------------------------------
      WF_ENGINE.SetItemAttrText(l_item_type,
			        l_item_key,
			        'EMPLOYEE_NOTIFICATION_METHOD',
			        l_employee_notification_method);

      IF (l_employee_id IS NOT NULL) THEN

        ------------------------------------------------------------
        l_debug_info := 'Get Name Info Associated With Employee_Id';
        ------------------------------------------------------------
        WF_DIRECTORY.GetUserName('PER',
                                 l_employee_id,
                                 l_employee_name,
                                 l_employee_display_name);

        ------------------------------------------------------
        l_debug_info := 'Set WF Employee_ID Item Attribute';
        ------------------------------------------------------
        WF_ENGINE.SetItemAttrNumber(l_item_type,
                                    l_item_key,
                                    'EMPLOYEE_ID',
                                    l_employee_id);

        ------------------------------------------------------
        l_debug_info := 'Set WF Employee_Name Item Attribute';
        ------------------------------------------------------
        WF_ENGINE.SetItemAttrText(l_item_type,
                                  l_item_key,
                                  'EMPLOYEE_NAME',
                                  l_employee_name);

        --------------------------------------------------------------
        l_debug_info := 'Set WF Preparer_Display_Name Item Attribute';
        --------------------------------------------------------------
        WF_ENGINE.SetItemAttrText(l_item_type,
                                  l_item_key,
                                  'EMPLOYEE_DISPLAY_NAME',
                                  l_employee_display_name);

      END IF;

      IF (l_status_lookup_code IS NOT NULL) THEN

        ------------------------------------------------------
        l_debug_info := 'Set WF Employee_Name Item Attribute';
        ------------------------------------------------------
        WF_ENGINE.SetItemAttrText(l_item_type,
                                  l_item_key,
                                  'STATUS_LOOKUP_CODE',
                                  l_status_lookup_code);

      END IF;

      --------------------------------------------------------
      l_debug_info := 'Call JumpIntoFunction to retrieve URL';
      --------------------------------------------------------
      /*AP_WEB_INTERFACE_PKG.JumpIntoFunction(l_new_emp_verification_id,
                                            'PCARD EMP VERI',
                                            l_url);*/

      -----------------------------------------------------
      l_debug_info := 'Set EXPENSE DETAILS Item Attribute';
      -----------------------------------------------------

      -- Be sure to clear these values.  If we are resubmitting, we don't want
      -- the values from the previous process traversal to hang around.
      WF_ENGINE.SetItemAttrText(l_item_type,
                                l_item_key,
                                'PCARD_TRANS_DETAILS',
                                l_url);
      /*MOAC CHANGES MADE FOR PCARD PROJECT*/
       WF_ENGINE.SetItemAttrNumber(l_item_type,
                                    l_item_key,
                                    'ORG_ID',
                                    nvl(p_org_id,mo_utils.get_default_org_id));

      ------------------------------------------------------------
      l_debug_info := 'Start the Expense Report Workflow Process';
      ------------------------------------------------------------
      WF_ENGINE.StartProcess(l_item_type,
			     l_item_key);

    ELSE

       l_lines_without_dists_flag := TRUE;

    END IF;
  END LOOP;

  CLOSE Emp_Verification_Workflows;

  COMMIT;

  IF (l_lines_without_dists_flag) THEN
       errbuf := 'There are credit card lines out there without associated' ||
                 ' distributions and as a result did not get processed.';
       retcode := 1;
  ELSE
       retcode := 0;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'DistributeEmpVerificationss');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      errbuf := FND_MESSAGE.Get;
      retcode := 2;
   END IF;
END DistributeEmpVerifications;


PROCEDURE DistributeManagerApprovals (errbuf		OUT NOCOPY VARCHAR2,
				      retcode		OUT NOCOPY NUMBER,
				      p_manager_id IN NUMBER DEFAULT NULL,
				      p_org_id IN NUMBER)IS
  l_item_type			VARCHAR2(100) := 'APPCMGR';
  l_item_key			VARCHAR2(100);
  l_employee_id			NUMBER;
  l_employee_name               VARCHAR2(30);
  l_employee_display_name	VARCHAR2(80);
  l_manager_id			NUMBER;
  l_manager_name		VARCHAR2(30);
  l_manager_display_name	VARCHAR2(80);
  l_manager_approval_method 	AP_CARD_PROFILES.mgr_approval_lookup_code%TYPE;
  l_new_manager_approval_id	NUMBER;
  l_url				VARCHAR2(1000);
  l_debug_info		        VARCHAR2(200);
  l_records_undistributed_flag  BOOLEAN := FALSE;
  l_num_records_updated		NUMBER;

  l_log_employee_name           HR_EMPLOYEES_CURRENT_V.full_name%TYPE;
  l_log_employee_num            HR_EMPLOYEES_CURRENT_V.employee_num%TYPE;
--bug5058949
--Performance fix

  CURSOR Manager_Approval_Workflows IS
  SELECT cp.mgr_approval_lookup_code,
         decode(cp.mgr_approval_lookup_code, 'N', null, hr.supervisor_id),
         decode(cp.mgr_approval_lookup_code, 'N', null, fl.employee_id)
  FROM   ap_expense_feed_lines fl,
	 ap_expense_feed_dists_all fd,
	 ap_cards_all c,
	 ap_card_profiles_all cp,
	 per_employees_x hr,
         IBY_CREDITCARD IBY
  WHERE  fd.status_lookup_code = 'VERIFIED'
  AND    fd.manager_approval_id IS NULL
  AND    fd.feed_line_id = fl.feed_line_id
  AND    fl.card_id = c.card_id
  AND    c.card_reference_id=IBY.instrid
  AND    c.profile_id = cp.profile_id
  AND    fl.employee_id = hr.employee_id
  AND    (hr.supervisor_id = p_manager_id OR
          p_manager_id IS NULL)
  GROUP BY cp.mgr_approval_lookup_code,
           decode(cp.mgr_approval_lookup_code, 'N', null, hr.supervisor_id),
           decode(cp.mgr_approval_lookup_code, 'N', null, fl.employee_id),fd.org_id;
  /*Send one notification for every org*/
BEGIN

  -----------------------------
  l_debug_info := 'Set Org ID';
  -----------------------------
  /*FND_CLIENT_INFO.SetUp_Client_Info(200,
 				    FND_GLOBAL.Resp_ID,
				    FND_GLOBAL.User_ID,
				    FND_GLOBAL.Security_Group_ID)*/
  /*MOAC Changes to be done*/
  Mo_global.init('SQLAP');
  if p_org_id is not null then
   Mo_Global.set_policy_context('S',p_org_id);
  else
   Mo_Global.set_policy_context('M',null);
  end if;

  OPEN Manager_Approval_Workflows;

  LOOP

    FETCH Manager_Approval_Workflows INTO l_manager_approval_method,
					  l_manager_id,
					  l_employee_id;

    ----------------------------------------------------
    -- Do not process records if there is no manager or
    -- employee information.
    ----------------------------------------------------
    EXIT WHEN Manager_Approval_Workflows%NOTFOUND;

    ------------------------------------------------------------
    -- Check for null manager_id, which is a setup error if
    -- employee_id is not null
    ------------------------------------------------------------
    if (l_manager_id is null and l_employee_id is not null) then

      -----------------------------
      l_debug_info := 'Retrieve employee info for log.';
      -----------------------------
      select full_name,
             employee_num
      into   l_log_employee_name,
             l_log_employee_num
      from   hr_employees_current_v
      where  employee_id = l_employee_id;

      -----------------------------
      l_debug_info := 'Write employee info to log.';
      -----------------------------
      fnd_file.put_line(FND_FILE.LOG,'Warning: Employee '||
                     l_log_employee_name||' ('||
                     l_log_employee_num ||') does not have a manager.');

      fnd_file.put_line(FND_FILE.LOG,
                     'No transactions will be processed for this employee.');

      fnd_file.put_line(FND_FILE.LOG,'');

    else

      ----------------------------------------------------
      l_debug_info := ' Generate New Manager Approval ID';
      ----------------------------------------------------
      SELECT ap_card_mgr_approval_s.nextval
      INTO   l_new_manager_approval_id
      FROM   sys.dual;

--bug5058949
--Performance fix

      UPDATE ap_expense_feed_dists fd
      SET    manager_approval_id = l_new_manager_approval_id
      WHERE  status_lookup_code = 'VERIFIED'
      AND    manager_approval_id IS NULL
      AND    EXISTS (SELECT 'feed distribution falls in this workflow'
                       FROM   ap_expense_feed_lines fl,
	                      ap_cards c,
	                      ap_card_profiles cp,
			      hr_employees_current_v hr,
	                    IBY_CREDITCARD IBY
                     WHERE  fl.feed_line_id = fd.feed_line_id
		     AND    c.card_reference_id=IBY.instrid
                     AND    fl.card_id = c.card_id
                       AND    c.profile_id = cp.profile_id
                       AND    fl.employee_id = hr.employee_id
		       AND    (hr.supervisor_id = p_manager_id OR
		               p_manager_id IS NULL)
                       AND    decode(cp.mgr_approval_lookup_code, 'N',
                                    1, hr.supervisor_id) = nvl(l_manager_id,1)
                       AND    decode(cp.mgr_approval_lookup_code, 'N',
                                    1, hr.employee_id) = nvl(l_employee_id,1));

      -------------------------------------------------------------------------
      l_debug_info := 'Check if no records got assigned to this current ' ||
                      'workflow process.';
      -------------------------------------------------------------------------
      SELECT count(*)
      INTO   l_num_records_updated
      FROM   ap_expense_feed_dists
      WHERE  manager_approval_id = l_new_manager_approval_id;


    IF (l_num_records_updated > 0) THEN
      l_item_key := to_char(l_new_manager_approval_id);

      --------------------------------------------------
      l_debug_info := 'Calling WorkFlow Create Process';
      --------------------------------------------------
      WF_ENGINE.CreateProcess(l_item_type,
	  		      l_item_key,
			      'AP_PC_MGR_APRVL_MAIN_PROCESS');

      ---------------------------------------------------------
      l_debug_info := 'Set Emp Notification ID Item Attribute';
      ---------------------------------------------------------
      WF_ENGINE.SetItemAttrNumber(l_item_type,
			          l_item_key,
			          'MANAGER_APPROVAL_ID',
			          l_new_manager_approval_id);

      -------------------------------------------------------------
      l_debug_info := 'Set Emp Notification Method Item Attribute';
      -------------------------------------------------------------
      WF_ENGINE.SetItemAttrText(l_item_type,
			        l_item_key,
			        'MANAGER_APPROVAL_METHOD',
			        l_manager_approval_method);

      IF (l_manager_id IS NOT NULL) THEN

        ------------------------------------------------------------
        l_debug_info := 'Get Name Info Associated With Manager_Id';
        ------------------------------------------------------------
        WF_DIRECTORY.GetUserName('PER',
                                 l_manager_id,
                                 l_manager_name,
                                 l_manager_display_name);

        ---------------------------------------------------
        l_debug_info := 'Set WF Manager_ID Item Attribute';
        ---------------------------------------------------
        WF_ENGINE.SetItemAttrNumber(l_item_type,
                                    l_item_key,
                                    'MANAGER_ID',
                                    l_manager_id);

        ------------------------------------------------------
        l_debug_info := 'Set WF Manager_Name Item Attribute';
        ------------------------------------------------------
        WF_ENGINE.SetItemAttrText(l_item_type,
                                  l_item_key,
                                  'MANAGER_NAME',
                                  l_manager_name);

        --------------------------------------------------------------
        l_debug_info := 'Set WF Manager_Display_Name Item Attribute';
        --------------------------------------------------------------
        WF_ENGINE.SetItemAttrText(l_item_type,
                                  l_item_key,
                                  'MANAGER_DISPLAY_NAME',
                                  l_manager_display_name);

      END IF;

      IF (l_employee_id IS NOT NULL) THEN

        ------------------------------------------------------------
        l_debug_info := 'Get Name Info Associated With Employee_Id';
        ------------------------------------------------------------
        WF_DIRECTORY.GetUserName('PER',
                                 l_employee_id,
                                 l_employee_name,
                                 l_employee_display_name);

        ------------------------------------------------------
        l_debug_info := 'Set WF Employee_ID Item Attribute';
        ------------------------------------------------------
        WF_ENGINE.SetItemAttrNumber(l_item_type,
                                    l_item_key,
                                    'EMPLOYEE_ID',
                                    l_employee_id);

        ------------------------------------------------------
        l_debug_info := 'Set WF Employee_Name Item Attribute';
        ------------------------------------------------------
        WF_ENGINE.SetItemAttrText(l_item_type,
                                  l_item_key,
                                  'EMPLOYEE_NAME',
                                  l_employee_name);

        --------------------------------------------------------------
        l_debug_info := 'Set WF Preparer_Display_Name Item Attribute';
        --------------------------------------------------------------
        WF_ENGINE.SetItemAttrText(l_item_type,
                                  l_item_key,
                                  'EMPLOYEE_DISPLAY_NAME',
                                  l_employee_display_name);

      END IF;

      --------------------------------------------------------
      l_debug_info := 'Call JumpIntoFunction to retrieve URL';
      --------------------------------------------------------
      /*AP_WEB_INTERFACE_PKG.JumpIntoFunction(l_new_manager_approval_id,
       					    'PCARD MANAGER APPR',
                                            l_url);*/

      -----------------------------------------------------
      l_debug_info := 'Set EXPENSE DETAILS Item Attribute';
      -----------------------------------------------------

      -- Be sure to clear these values.  If we are resubmitting, we don't want
      -- the values from the previous process traversal to hang around.
      WF_ENGINE.SetItemAttrText(l_item_type,
                                l_item_key,
                                'PCARD_TRANS_DETAILS',
                                l_url);
       /*MOAC CHANGES MADE FOR PCARD PROJECT*/
       WF_ENGINE.SetItemAttrNumber(l_item_type,
                                    l_item_key,
                                    'ORG_ID',
                                    nvl(p_org_id,mo_utils.get_default_org_id));


      ------------------------------------------------------------
      l_debug_info := 'Start the Expense Report Workflow Process';
      ------------------------------------------------------------
      WF_ENGINE.StartProcess(l_item_type,
			     l_item_key);


    ELSE

      l_records_undistributed_flag := TRUE;
      errbuf := 'No records selected for Manager Approval';
      retcode := '1';

     END IF;

   end if; -- (l_manager_id is not null)
  END LOOP;

  CLOSE Manager_Approval_Workflows;

  COMMIT;

  IF (l_records_undistributed_flag) THEN
      errbuf := 'There were records out there that somehow did not get ' ||
                'distributed to a manager.';
      retcode := '1';
  ELSE
      retcode := 0;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'DistributeManagerApprovals');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      errbuf := FND_MESSAGE.Get;
      retcode := 2;
   END IF;
END DistributeManagerApprovals;


-------------------------------------
PROCEDURE OpenP(p1    varchar2,
                p2    varchar2,
                p11   varchar2 Default NULL) IS
-------------------------------------
 l_param                 varchar2(240);
 c_rowid                 varchar2(20);
 l_document_type         varchar2(30) := icx_call.decrypt(p2);
 l_session_id            number;
 --l_icx_application_id    number := AP_WEB_INTERFACE_PKG.GetICXApplicationId;
 l_application_id    number := 200;
BEGIN
/*
  IF AP_WEB_INTERFACE_PKG.ValidateSession THEN

    l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
    AP_WEB_INTERFACE_PKG.ICXSetOrgContext(l_session_id, p11);

  -- The following information needs to be set up through ON forms, on
  -- particular page relations.

    IF (l_document_type = 'PCARD EMP VERI') THEN

      SELECT  rowidtochar(ROWID)
      INTO    c_rowid
      FROM    AK_FLOW_REGION_RELATIONS
      WHERE   FROM_REGION_CODE = 'AP_EXP_NOTIFICATIONS'
      AND     FROM_REGION_APPL_ID = l_application_id
      AND     FROM_PAGE_CODE = 'AP_EXP_EMP_NOTIFY'
      AND     FROM_PAGE_APPL_ID = l_application_id
      AND     TO_PAGE_CODE = 'AP_EXP_FEED_DISTS_OPEN'
      AND     TO_PAGE_APPL_ID = l_application_id
      AND     FLOW_CODE = 'AP_CARD_INQUIRIES'
      AND     FLOW_APPLICATION_ID = l_application_id;

      l_param := 'D*****1****' || c_rowid || '*AP_CARD_NOTIFICATIONS_PK1*' || icx_call.decrypt(p1) || '**]';

--      l_param := 'W*200*AP_CARD_INQUIRIES*200*AP_EXP_FEED_DIST_OPEN*where employee_verification_id = ' || icx_call.decrypt(p1) || '**]';

    ELSIF (l_document_type = 'PCARD MANAGER APPR' ) THEN

      SELECT  rowidtochar(ROWID)
      INTO    c_rowid
      FROM    AK_FLOW_REGION_RELATIONS
      WHERE   FROM_REGION_CODE = 'AP_EXP_NOTIFICATIONS'
      AND     FROM_REGION_APPL_ID = l_application_id
      AND     FROM_PAGE_CODE = 'AP_EXP_MGR_NOTIFY'
      AND     FROM_PAGE_APPL_ID = l_application_id
      AND     TO_PAGE_CODE = 'AP_EXP_FEED_DISTS_HIST'
      AND     TO_PAGE_APPL_ID = l_application_id
      AND     FLOW_CODE = 'AP_CARD_INQUIRIES'
      AND     FLOW_APPLICATION_ID = l_application_id;

--      l_param := 'D*****1****' || c_rowid || '*AP_EXP_FEED_DISTS_PK1*' || icx_call.decrypt(p1) || '**]';

      l_param := 'D*****1****' || c_rowid || '*AP_CARD_NOTIFICATIONS_PK1*' || icx_call.decrypt(p1) || '**]';

    END IF;


    IF (l_session_id IS NULL) THEN
      OracleOn.IC(Y=>icx_call.encrypt2(l_param,-999));
    ELSE
      OracleOn.IC(Y=>icx_call.encrypt2(l_param,l_session_id));
    END IF;

  END IF;
 */
   null;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    c_rowid := NULL;
  WHEN OTHERS THEN
   htp.p(SQLERRM);
END OpenP;


PROCEDURE EmpVfyPCardSetOrgContext(p_employee_verification_id	IN NUMBER) IS
  l_org_id	NUMBER;
  l_debug_info	VARCHAR2(2000);
BEGIN
    SELECT distinct(nvl(fl.org_id,fd.org_id))
    INTO   l_org_id
    FROM   ap_expense_feed_lines_all fl,
           ap_expense_feed_dists_all fd
    WHERE  fl.employee_verification_id = p_employee_verification_id
    OR     (fd.feed_line_id = fl.feed_line_id AND
            fd.employee_verification_id = p_employee_verification_id);
    if (l_org_id is not null) then
        Mo_Global.set_policy_context('S', l_org_id);
    else
        raise NO_DATA_FOUND;
    end if;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'EmpVfyPCardSetOrgContext');
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END EmpVfyPCardSetOrgContext;

PROCEDURE MgrAprvlPCardSetOrgContext(p_manager_approval_id	IN NUMBER) IS
l_org_id	NUMBER;
BEGIN

    SELECT distinct(org_id)
    INTO   l_org_id
    FROM   ap_expense_feed_dists_all fd
    WHERE  fd.manager_approval_id = p_manager_approval_id;

    if (l_org_id is not null) then
        Mo_Global.set_policy_context('S', l_org_id);
    else
        raise NO_DATA_FOUND;
    end if;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'MgrAprvlPCardSetOrgContext');
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END MgrAprvlPCardSetOrgContext;

------------------------------------------------------------------------
PROCEDURE CheckEmpNotificationMethod(p_item_type	IN VARCHAR2,
			     	     p_item_key		IN VARCHAR2,
			     	     p_actid		IN NUMBER,
			     	     p_funmode		IN VARCHAR2,
			     	     p_result		OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_emp_notification_method     VARCHAR2(1);
  l_return_error_message	VARCHAR2(2000) := NULL;
  l_debug_info			VARCHAR2(200);
BEGIN

  IF (p_funmode = 'RUN') THEN

    -------------------------------------------------------------
    l_debug_info := 'Set Emp Notification Method Item Attribute';
    -------------------------------------------------------------
    l_emp_notification_method := WF_ENGINE.GetItemAttrText(p_item_type,
			      			p_item_key,
			      		'EMPLOYEE_NOTIFICATION_METHOD');

    IF (l_emp_notification_method = 'I') THEN
      p_result := 'COMPLETE:AP_INFORM_ONLY';
    ELSIF (l_emp_notification_method = 'Y') THEN
      p_result := 'COMPLETE:AP_VERIFICATION_REQ';
    ELSE
      p_result := 'COMPLETE:AP_NONE';
    END IF;

  ELSIF (p_funmode = 'CANCEL') THEN

    p_result := 'COMPLETE';

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_PCARD_WORKFLOW_PKG', 'CheckEmpNotificationMethod',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END CheckEmpNotificationMethod;

------------------------------------------------------------------------
PROCEDURE MarkRemainingTransVerified(p_item_type	IN VARCHAR2,
			     	     p_item_key		IN VARCHAR2,
			     	     p_actid		IN NUMBER,
			     	     p_funmode		IN VARCHAR2,
			     	     p_result		OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_emp_verification_id		NUMBER;
  l_status_lookup_code		VARCHAR2(25);
  l_return_error_message	VARCHAR2(2000) := NULL;
  l_debug_info			VARCHAR2(200);
  l_org_id NUMBER;
BEGIN

  IF (p_funmode = 'RUN') THEN

    -------------------------------------------------------------
    l_debug_info := 'Set Emp Notification Method Item Attribute';
    -------------------------------------------------------------
    l_emp_verification_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
			      			p_item_key,
			      			'EMPLOYEE_VERIFICATION_ID');

    --------------------------------------------------------
    l_debug_info := 'Set Status Lookup Code Item Attribute';
    ---------------------------------------------------------
    l_status_lookup_code := WF_ENGINE.GetItemAttrText(p_item_type,
			      			p_item_key,
			      			'STATUS_LOOKUP_CODE');

    ----------------------------------
    l_debug_info := 'Set Org Context';
    ----------------------------------
   -- EmpVfyPCardSetOrgContext(l_emp_verification_id);
    l_org_id:= WF_ENGINE.GetItemAttrNumber(p_item_type,
						         p_item_key,
						   'ORG_ID');
    Mo_Global.set_policy_context('S', l_org_id);
    WF_ENGINE.SetItemAttrNumber(p_item_type,p_item_key,'ORG_ID',l_org_id);


    -------------------------------------------
    l_debug_info := 'Update Expense Feed Dists';
    -------------------------------------------
    BEGIN
      UPDATE ap_expense_feed_dists
      SET    status_lookup_code = 'VERIFIED'
      WHERE  employee_verification_id = l_emp_verification_id
      AND    (status_lookup_code = l_status_lookup_code
             OR l_status_lookup_code IS NULL);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

  ELSIF (p_funmode = 'CANCEL') THEN

    p_result := 'COMPLETE';

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_PCARD_WORKFLOW_PKG', 'MarkRemainingTransVerified',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END MarkRemainingTransVerified;

------------------------------------------------------------------------
PROCEDURE AutoApprvVeriTransNotReqAprvl(p_item_type	IN VARCHAR2,
			     	        p_item_key	IN VARCHAR2,
			     	  	p_actid		IN NUMBER,
			     	  	p_funmode	IN VARCHAR2,
			     	  	p_result	OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_emp_verification_id		NUMBER;
  l_return_error_message	VARCHAR2(2000) := NULL;
  l_debug_info			VARCHAR2(200);
  l_org_id NUMBER;
BEGIN

  IF (p_funmode = 'RUN') THEN

    -------------------------------------------------------------
    l_debug_info := 'Set Emp Notification Method Item Attribute';
    -------------------------------------------------------------
    l_emp_verification_id := WF_ENGINE.GetItemAttrText(p_item_type,
			      			p_item_key,
			      			'EMPLOYEE_VERIFICATION_ID');

    ----------------------------------
    l_debug_info := 'Set Org Context';
    ----------------------------------
    --EmpVfyPCardSetOrgContext(l_emp_verification_id);
    l_org_id:= WF_ENGINE.GetItemAttrNumber(p_item_type,
						         p_item_key,
						   'ORG_ID');
    Mo_Global.set_policy_context('S', l_org_id);
    WF_ENGINE.SetItemAttrNumber(p_item_type,p_item_key,'ORG_ID',l_org_id);
    BEGIN
--bug5058949
--Performance fix
      UPDATE ap_expense_feed_dists fd
      SET    status_lookup_code = 'APPROVED'
      WHERE  employee_verification_id = l_emp_verification_id
      AND    status_lookup_code = 'VERIFIED'
      AND    exists (select 'no manager approval required'
                     from    ap_expense_feed_lines fl,
			     ap_cards c,
			     ap_card_profiles cp,
	                    IBY_CREDITCARD IBY
                     WHERE  fl.feed_line_id = fd.feed_line_id
		     AND    c.card_reference_id=IBY.instrid
                     AND    fl.card_id = c.card_id
                     AND     c.profile_id = cp.profile_id
                     AND     nvl(cp.mgr_approval_lookup_code,'N') = 'N');
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

  ELSIF (p_funmode = 'CANCEL') THEN

    p_result := 'COMPLETE';

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_PCARD_WORKFLOW_PKG',
			'AutoApprvVeriTransNotReqAprvl',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END AutoApprvVeriTransNotReqAprvl;

------------------------------------------------------------------------
PROCEDURE CheckEmpVerificationComplete(p_item_type	IN VARCHAR2,
			     	       p_item_key	IN VARCHAR2,
			     	       p_actid		IN NUMBER,
			     	       p_funmode	IN VARCHAR2,
			     	       p_result	OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_emp_verification_id		NUMBER;
  l_orig_status_lookup_code	VARCHAR2(25);
  l_num_dists_not_processed	NUMBER;
  l_return_error_message	VARCHAR2(2000) := NULL;
  l_debug_info			VARCHAR2(200);
  l_org_id number;
BEGIN

  IF (p_funmode = 'RUN') THEN

    -------------------------------------------------------------
    l_debug_info := 'Set Emp Notification Method Item Attribute';
    -------------------------------------------------------------
    l_emp_verification_id := WF_ENGINE.GetItemAttrText(p_item_type,
			      			p_item_key,
			      			'EMPLOYEE_VERIFICATION_ID');

    --------------------------------------------------------
    l_debug_info := 'Set Status Lookup Code Item Attribute';
    ---------------------------------------------------------
    l_orig_status_lookup_code := WF_ENGINE.GetItemAttrText(p_item_type,
			      			p_item_key,
			      			'STATUS_LOOKUP_CODE');

    ----------------------------------
    l_debug_info := 'Set Org Context';
    ----------------------------------
    --EmpVfyPCardSetOrgContext(l_emp_verification_id);
    l_org_id:= WF_ENGINE.GetItemAttrNumber(p_item_type,
						         p_item_key,
						   'ORG_ID');
    Mo_Global.set_policy_context('S', l_org_id);
    WF_ENGINE.SetItemAttrNumber(p_item_type,p_item_key,'ORG_ID',l_org_id);


    SELECT count(*)
    INTO   l_num_dists_not_processed
    FROM   ap_expense_feed_dists
    WHERE  employee_verification_id = l_emp_verification_id
    AND    status_lookup_code = l_orig_status_lookup_code;

    IF (l_num_dists_not_processed > 0) THEN
      p_result := 'COMPLETE:N';
    ELSE
      p_result := 'COMPLETE:Y';
    END IF;

  ELSIF (p_funmode = 'CANCEL') THEN

    p_result := 'COMPLETE';

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE','CheckEmpVerificationComplete');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END CheckEmpVerificationComplete;

------------------------------------------------------------------------------
PROCEDURE BuildEmpVerificationMessage(p_item_type	IN VARCHAR2,
				p_item_key	IN VARCHAR2,
				p_actid		IN NUMBER,
		       		p_funmode	IN VARCHAR2,
		       		p_result	OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------------
  l_emp_verification_id	NUMBER;
  l_status_lookup_code	VARCHAR2(25);
  l_transaction_date	VARCHAR2(15);
  l_merchant_name	VARCHAR2(30);
  l_amount              NUMBER;
  l_currency_code	VARCHAR2(15);
  l_message_name	VARCHAR2(30);
  l_debug_info		VARCHAR2(1000);
  l_line_info		VARCHAR2(200);
  l_attribute_name	VARCHAR2(30);
  l_line_info_body1	VARCHAR2(2000) := '';
  l_line_info_body2	VARCHAR2(2000) := '';
--  c_prompts		AP_WEB_INTERFACE_PKG.prompts_table;
  c_title		VARCHAR2(80);
  i			NUMBER;
  j			NUMBER;
  l_num_lines		NUMBER;
  l_message_text	VARCHAR2(2000);
  l_description		VARCHAR2(240);
--bug5058949
--Performance fix

  CURSOR EmpPCardTransactions IS
    SELECT fl.transaction_date,
	   rpad(merchant_name,30),
	   fl.amount,
           nvl(fl.posted_currency_code, cpr.card_program_currency_code),
	   fd.description
    FROM   ap_expense_feed_dists fd,
           ap_expense_feed_lines fl,
	   ap_cards c,
	   ap_card_profiles cp,
           ap_card_programs cpr,
	   IBY_CREDITCARD IBY
    WHERE  ((fd.employee_verification_id = l_emp_verification_id AND
             fd.feed_line_id = fl.feed_line_id) OR
            (fl.employee_verification_id = l_emp_verification_id))
    AND    fl.card_id = c.card_id
    AND    c.card_reference_id=IBY.instrid
    AND    c.profile_id = cp.profile_id
    AND    cp.card_program_id = cpr.card_program_id;
    l_org_id number;
BEGIN

  IF (p_funmode = 'RUN') THEN

    --------------------------------------------------------------------
    l_debug_info := 'Retrieve Employee Verification ID Item Attribute';
    ---------------------------------------------------------------------
    l_emp_verification_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
						   p_item_key,
						   'EMPLOYEE_VERIFICATION_ID');
    l_org_id:=WF_ENGINE.GetItemAttrNumber(p_item_type,
						   p_item_key,
						   'ORG_ID');

    Mo_Global.set_policy_context('S', l_org_id);

    l_status_lookup_code := WF_ENGINE.GetItemAttrNumber(p_item_type,
							p_item_key,
							'STATUS_LOOKUP_CODE');

    IF (l_status_lookup_code = 'VALIDATED') THEN

      l_message_name := 'AP_PCARD_EMP_VERIFY_VALIDATED';

    ELSIF (l_status_lookup_code = 'HOLD') THEN

      l_message_name := 'AP_PCARD_EMP_VERIFY_HELD';

    ELSIF (l_status_lookup_code = 'REJECTED') THEN

      l_message_name := 'AP_PCARD_EMP_VERIFY_REJECTED';

    ELSE

      -- raise exception
      NULL;

    END IF;

    fnd_message.set_name('SQLAP', l_message_name);
    l_message_text := FND_MESSAGE.Get;
    WF_ENGINE.SetItemAttrNumber(p_item_type,p_item_key,'EMPLOYEE_VERIFICATION_ID',l_emp_verification_id);
    WF_ENGINE.SetItemAttrNumber(p_item_type,p_item_key,'ORG_ID',l_org_id);

    WF_ENGINE.SetItemAttrText(p_item_type,
	 		      p_item_key,
			      'EMP_VERIFY_MSG_INTRO',
			      l_message_text);

    ----------------------------------
    l_debug_info := 'Set Org Context';
    ----------------------------------
    --EmpVfyPCardSetOrgContext(l_emp_verification_id);

    ----------------------------------------------------------
    l_debug_info := 'Open Employee Verification Lines Cursor';
    ----------------------------------------------------------
    /*OPEN EmpPCardTransactions;


    FOR i IN 1..100 LOOP

      -----------------------------------------------------------
      l_debug_info := 'Fetch employee verification lines Cursor';
      -----------------------------------------------------------
      FETCH EmpPCardTransactions INTO l_transaction_date,
  				      l_merchant_name,
  				      l_amount,
  				      l_currency_code,
				      l_description;

      EXIT WHEN EmpPCardTransactions%NOTFOUND;

      ---------------------------------------------------------
      l_debug_info := 'Format Employee Verification Line Info';
      ---------------------------------------------------------
      l_line_info := '> ' || l_transaction_date || ' ' || l_currency_code || ' '
                          || LPAD(to_char(l_amount,
			     FND_CURRENCY.Get_Format_Mask(l_currency_code,22)),14)
                          || ' ' || l_merchant_name;

      --------------------------------------------------------
      l_debug_info := 'Set Item Attribute Name for line_info';
      --------------------------------------------------------
      l_attribute_name := 'LINE_INFO' || to_char(2*i-1);

    ------------------------------------------------------------------------
    l_debug_info := 'Set Line_Info Item Attribute with formatted expense line';
    ---------------------------------------------------------------------------
      WF_ENGINE.SetItemAttrText(p_item_type,
	 		      p_item_key,
			      l_attribute_name,
			      l_line_info);


      -----------------------------------------------------------------
      l_debug_info := 'Set Item Attribute Name for line justification';
      -----------------------------------------------------------------
      l_attribute_name := 'LINE_INFO' || to_char(2*i);

      ---------------------------------------------------------
      l_debug_info := 'Set Line Justification Item Attribute';
      ---------------------------------------------------------
      WF_ENGINE.SetItemAttrText(p_item_type,
	 		      p_item_key,
			      l_attribute_name,
			      '----> ' || l_description);

      l_line_info := '';
      l_num_lines := i;
    END LOOP;

    ---------------------------------------------------------
    l_debug_info := 'Populating line_info_body with tokens';
    ---------------------------------------------------------

    FOR j in 1..l_num_lines LOOP

      ------------------------------------------
      l_debug_info := 'j equals ' || to_char(j);
      ------------------------------------------
      IF (j < 50) THEN

        l_line_info_body1 := l_line_info_body1 || '
' || '&LINE_INFO' || to_char(2*j-1) || '
' || '&LINE_INFO' || to_char(2*j);

      ELSE

        l_line_info_body2 := l_line_info_body2 || '
' || '&LINE_INFO' || to_char(2*j-1) || '
' || '&LINE_INFO' || to_char(2*j);

      END IF;

    END LOOP;*/

    ---------------------------------------------------------
    l_debug_info := 'Set Item Attribute Line_Info_Body1';
    ---------------------------------------------------------
    WF_ENGINE.SetItemAttrText(p_item_type,
	 		      p_item_key,
			      'LINE_BODY_00001',
			      l_line_info_body1);

    IF (i > 50) THEN

      ---------------------------------------------------------
      l_debug_info := 'Set Item Attribute Line_Info_Body2';
      ---------------------------------------------------------
      WF_ENGINE.SetItemAttrText(p_item_type,
	 		      p_item_key,
			      'LINE_BODY_00002',
			      l_line_info_body2);

    END IF;

  ELSIF (p_funmode = 'CANCEL') THEN

    p_result := 'COMPLETE';

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_EXPENSE_WF', 'BuildEmpVerificationMessage',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END BuildEmpVerificationMessage;

------------------------------------------------------------------------
PROCEDURE CheckManagerApprovalMethod(p_item_type	IN VARCHAR2,
			     	     p_item_key		IN VARCHAR2,
			     	     p_actid		IN NUMBER,
			     	     p_funmode		IN VARCHAR2,
			     	     p_result		OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_manager_approval_method     VARCHAR2(1);
  l_return_error_message	VARCHAR2(2000) := NULL;
  l_debug_info			VARCHAR2(200);
BEGIN

  IF (p_funmode = 'RUN') THEN

    -------------------------------------------------------------
    l_debug_info := 'Set Emp Notification Method Item Attribute';
    -------------------------------------------------------------
    l_manager_approval_method := WF_ENGINE.GetItemAttrText(p_item_type,
			      			p_item_key,
			      			'MANAGER_APPROVAL_METHOD');

    IF (l_manager_approval_method = 'I') THEN
      p_result := 'COMPLETE:AP_INFORM_ONLY';
    ELSIF (l_manager_approval_method = 'Y') THEN
      p_result := 'COMPLETE:AP_VERIFICATION_REQ';
    ELSE
      p_result := 'COMPLETE:AP_NONE';
    END IF;

  ELSIF (p_funmode = 'CANCEL') THEN

    p_result := 'COMPLETE';

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'CheckManagerApprovalMethod');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END CheckManagerApprovalMethod;

------------------------------------------------------------------------
PROCEDURE MarkTransactionsAsRejected(p_item_type	IN VARCHAR2,
			     	     p_item_key		IN VARCHAR2,
			     	     p_actid		IN NUMBER,
			     	     p_funmode		IN VARCHAR2,
			     	     p_result		OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_manager_approval_id		NUMBER;
  l_return_error_message	VARCHAR2(2000) := NULL;
  l_debug_info			VARCHAR2(200);
  l_org_id number;
BEGIN

  IF (p_funmode = 'RUN') THEN

    -------------------------------------------------------------
    l_debug_info := 'Set Emp Notification Method Item Attribute';
    -------------------------------------------------------------
    l_manager_approval_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
			      			p_item_key,
			      			'MANAGER_APPROVAL_ID');

    ----------------------------------
    l_debug_info := 'Set Org Context';
    ----------------------------------
    --MgrAprvlPCardSetOrgContext(l_manager_approval_id);
    l_org_id:= WF_ENGINE.GetItemAttrNumber(p_item_type,
						         p_item_key,
						   'ORG_ID');
    Mo_Global.set_policy_context('S', l_org_id);
    WF_ENGINE.SetItemAttrNumber(p_item_type,p_item_key,'ORG_ID',l_org_id);


    BEGIN
      UPDATE ap_expense_feed_dists
      SET    status_lookup_code = 'REJECTED'
      WHERE  manager_approval_id = l_manager_approval_id;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

  ELSIF (p_funmode = 'CANCEL') THEN

    p_result := 'COMPLETE';

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'MarkTransactionsAsRejected');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END MarkTransactionsAsRejected;

------------------------------------------------------------------------
PROCEDURE MarkTransactionsAsApproved(p_item_type	IN VARCHAR2,
			     	     p_item_key		IN VARCHAR2,
			     	     p_actid		IN NUMBER,
			     	     p_funmode		IN VARCHAR2,
			     	     p_result		OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_manager_approval_id		NUMBER;
  l_return_error_message	VARCHAR2(2000) := NULL;
  l_debug_info			VARCHAR2(200);
  l_org_id number;
BEGIN

  IF (p_funmode = 'RUN') THEN

    -------------------------------------------------------------
    l_debug_info := 'Set Emp Notification Method Item Attribute';
    -------------------------------------------------------------
    l_manager_approval_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
			      			p_item_key,
			      			'MANAGER_APPROVAL_ID');
    ----------------------------------
    l_debug_info := 'Set Org Context';
    ----------------------------------
    --MgrAprvlPCardSetOrgContext(l_manager_approval_id);
    l_org_id:= WF_ENGINE.GetItemAttrNumber(p_item_type,
						         p_item_key,
						   'ORG_ID');
    Mo_Global.set_policy_context('S', l_org_id);
    WF_ENGINE.SetItemAttrNumber(p_item_type,p_item_key,'ORG_ID',l_org_id);

    BEGIN
      UPDATE ap_expense_feed_dists
      SET    status_lookup_code = 'APPROVED'
      WHERE  manager_approval_id = l_manager_approval_id;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

  ELSIF (p_funmode = 'CANCEL') THEN

    p_result := 'COMPLETE';

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'MarkTransactionsAsApproved');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END MarkTransactionsAsApproved;

------------------------------------------------------------------------------
PROCEDURE BuildManagerApprovalMessage(p_item_type	IN VARCHAR2,
				      p_item_key	IN VARCHAR2,
				      p_actid		IN NUMBER,
		       		      p_funmode		IN VARCHAR2,
		       		      p_result		OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------------
  l_manager_approval_id	NUMBER;
  l_employee_id		NUMBER;
  l_employee_name	VARCHAR2(30);
  l_employee_display_name VARCHAR2(80);
  l_transaction_date	VARCHAR2(15);
  l_merchant_name	VARCHAR2(30);
  l_amount		NUMBER;
  l_currency_code	VARCHAR2(15);
  l_description		VARCHAR2(240);
  l_debug_info		VARCHAR2(1000);
  l_line_info_body1	VARCHAR2(2000) := '';
  l_line_info_body2	VARCHAR2(2000) := '';
--  c_prompts			AP_WEB_INTERFACE_PKG.prompts_table;
  c_title			VARCHAR2(80);
  i				NUMBER;
  j				NUMBER;
  l_num_lines			NUMBER;
  l_line_info			VARCHAR2(2000);
  l_attribute_name		VARCHAR2(30);
  l_org_id number;
  CURSOR MgrPCardTransactions IS
    SELECT fl.transaction_date,
           fl.employee_id,
	   rpad(merchant_name,30),
	   fl.amount,
           nvl(fl.posted_currency_code, cpr.card_program_currency_code),
	   fd.description
    FROM   ap_expense_feed_dists fd,
           ap_expense_feed_lines fl,
	   ap_cards c,
	   ap_card_profiles cp,
           ap_card_programs cpr,
	   IBY_CREDITCARD IBY
    WHERE  fd.manager_approval_id = l_manager_approval_id
    AND    fd.feed_line_id = fl.feed_line_id
    AND    fl.card_id = c.card_id
    AND    c.card_reference_id=IBY.instrid
    AND    c.profile_id = cp.profile_id
    AND    cp.card_program_id = cpr.card_program_id
    ORDER BY fl.employee_id, fl.transaction_date;
BEGIN

  IF (p_funmode = 'RUN') THEN

    --------------------------------------------------------------------
    l_debug_info := 'Retrieve Employee Verification ID  Item Attribute';
    ---------------------------------------------------------------------
    l_manager_approval_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
						         p_item_key,
						   'MANAGER_APPROVAL_ID');

    ----------------------------------
    l_debug_info := 'Set Org Context';
    ----------------------------------
    --MgrAprvlPCardSetOrgContext(l_manager_approval_id);
    WF_ENGINE.SetItemAttrNumber(p_item_type,p_item_key,'MANAGER_APPROVAL_ID',l_manager_approval_id);
    l_org_id:= WF_ENGINE.GetItemAttrNumber(p_item_type,
						         p_item_key,
						   'ORG_ID');
    Mo_Global.set_policy_context('S', l_org_id);
    WF_ENGINE.SetItemAttrNumber(p_item_type,p_item_key,'ORG_ID',l_org_id);

    --------------------------------------------
    l_debug_info := 'Open Expense Lines Cursor';
    --------------------------------------------
    OPEN MgrPCardTransactions;


    FOR i IN 1..100 LOOP

      --------------------------------------------
      l_debug_info := 'Fetch Expense Lines Cursor';
      --------------------------------------------
      FETCH MgrPCardTransactions INTO l_transaction_date,
				      l_employee_id,
  				      l_merchant_name,
  				      l_amount,
  				      l_currency_code,
				      l_description;

      EXIT WHEN MgrPCardTransactions%NOTFOUND;


      ------------------------------------------------------------
      l_debug_info := 'Get Name Info Associated With Employee_Id';
      ------------------------------------------------------------
      WF_DIRECTORY.GetUserName('PER',
                               l_employee_id,
                               l_employee_name,
                               l_employee_display_name);
      /*
      --------------------------------------------
      l_debug_info := 'Format Expense Line Info';
      --------------------------------------------
      l_line_info := '> ' || l_transaction_date || ' ' || l_currency_code || ' '
                          || LPAD(to_char(l_amount,
			     FND_CURRENCY.Get_Format_Mask(l_currency_code,22)),14)
                          || ' ' || l_merchant_name;

      --------------------------------------------------------
      l_debug_info := 'Set Item Attribute Name for line_info';
      --------------------------------------------------------
      l_attribute_name := 'LINE_INFO' || to_char(2*i-1);

    ------------------------------------------------------------------------
    l_debug_info := 'Set Line_Info Item Attribute with formatted expense line';
    ---------------------------------------------------------------------------
      WF_ENGINE.SetItemAttrText(p_item_type,
	 		      p_item_key,
			      l_attribute_name,
			      l_line_info);


      -----------------------------------------------------------------
      l_debug_info := 'Set Item Attribute Name for line justification';
      -----------------------------------------------------------------
      l_attribute_name := 'LINE_INFO' || to_char(2*i);

      ---------------------------------------------------------
      l_debug_info := 'Set Line Justification Item Attribute';
      ---------------------------------------------------------
      WF_ENGINE.SetItemAttrText(p_item_type,
	 		      p_item_key,
			      l_attribute_name,
			      '----> ' || l_description);
     */
      l_line_info := '';
      l_num_lines := i;
    END LOOP;

    ---------------------------------------------------------
    l_debug_info := 'Populating line_info_body with tokens';
    ---------------------------------------------------------
/*
    FOR j in 1..l_num_lines LOOP

      ------------------------------------------
      l_debug_info := 'j equals ' || to_char(j);
      ------------------------------------------
      IF (j < 50) THEN

        l_line_info_body1 := l_line_info_body1 || '
' || '&LINE_INFO' || to_char(2*j-1) || '
' || '&LINE_INFO' || to_char(2*j);

      ELSE

        l_line_info_body2 := l_line_info_body2 || '
' || '&LINE_INFO' || to_char(2*j-1) || '
' || '&LINE_INFO' || to_char(2*j);

      END IF;

    END LOOP;*/

    ---------------------------------------------------------
    l_debug_info := 'Set Item Attribute Line_Info_Body1';
    ---------------------------------------------------------
    WF_ENGINE.SetItemAttrText(p_item_type,
	 		      p_item_key,
			      'LINE_BODY_00001',
			      l_line_info_body1);

    IF (i > 50) THEN

      ---------------------------------------------------------
      l_debug_info := 'Set Item Attribute Line_Info_Body2';
      ---------------------------------------------------------
      WF_ENGINE.SetItemAttrText(p_item_type,
	 		      p_item_key,
			      'LINE_BODY_00002',
			      l_line_info_body2);

    END IF;

  ELSIF (p_funmode = 'CANCEL') THEN

    p_result := 'COMPLETE';

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_EXPENSE_WF', 'BuildManagerApprvalMessage',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END BuildManagerApprovalMessage;

END AP_WEB_PCARD_WORKFLOW_PKG;

/
