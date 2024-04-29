--------------------------------------------------------
--  DDL for Package Body AP_WEB_CUST_AME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_CUST_AME_PKG" AS
/* $Header: apwamecb.pls 120.7 2006/02/24 07:06:17 sbalaji noship $ */

/*----------------------------------------------------------------------------*
  Function
	checkAndGetApprover

  Description
	Added the function for fixing Bug : 4112598

  PARAMETERS
	p_approver_id - approver ID
	p_employee_id - employee ID

  RETURNS
	Return approver ID if approver <> employee or approver is null
        else return approver's manager ID
 *----------------------------------------------------------------------------*/
FUNCTION checkAndGetApprover(p_approver_id IN AP_WEB_DB_EXPRPT_PKG.expHdr_overrideApprID,
                             p_employee_id  IN NUMBER)
RETURN VARCHAR2 IS
  l_debugInfo   varchar2(240);
  l_dir_manager_id		NUMBER		:= NULL;
BEGIN
    if (p_approver_id is null) then
       return (p_approver_id);
    end if;

    if (p_approver_id <> p_employee_id) then
      return (p_approver_id);
    else
       AP_WEB_EXPENSE_WF.GetManager(p_employee_id, l_dir_manager_id);
       return to_char(l_dir_manager_id);
    end if;
EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AP_WEB_CUST_AME_PKG.checkAndGetApprover',
				    l_debugInfo);
    APP_EXCEPTION.RAISE_EXCEPTION;
END;

/*----------------------------------------------------------------------------*
 | Procedure
 |   getHeaderLevelApprover
 |
 | DESCRIPTION
 |   This function is to get the Approver ID for AME attribute
 |   Job Level Non Default Starting Point Person ID.
 |   Seeded logic for this function is as following:
 |     - If approver is entered, return the approver ID.
 |     - If only one award number is entered, get the award manager ID.
 |     - If only one project number is entered, get the project manager ID.
 |     - Return the cost center owner ID if the cost center is different
 |       than the employee's cost center. If the same, get the employee's
 |       supervisor ID.
 |     - If none of the above are entered, system should get the employee's
 |       supervisor ID.
 |
 | PARAMETERS
 |   p_report_header_id - The expense report ID.
 |
 | RETURNS
 |   Approver ID - Employee id of Header Level Approver.
 |      	 - Return NULL means default manager will be used to build
 | 	  	   the approver list.
 *----------------------------------------------------------------------------*/
-------------------------------------------------------------------------
FUNCTION getHeaderLevelApprover(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE) RETURN VARCHAR2 IS
-------------------------------------------------------------------------
  l_debug_info			VARCHAR2(200);
  l_approver_id			AP_WEB_DB_EXPRPT_PKG.expHdr_overrideApprID;
  l_employee_id			NUMBER;
  l_num_of_distinct_awards      INTEGER;
  l_num_of_awards		INTEGER;
  l_num_of_distinct_projects	INTEGER;
  l_num_of_projects		INTEGER;
  l_award_manager_id 		NUMBER;
  l_project_manager_id          NUMBER;
  l_cost_center_owner_id        NUMBER;
  l_cost_center_manager_id      NUMBER;
  l_default_cost_center		VARCHAR2(240);
  l_cost_center			VARCHAR2(240);
  l_employee_num		VARCHAR2(30);
  l_employee_name		VARCHAR2(240);
  l_project_id			NUMBER;
  l_award_id			NUMBER;
  l_week_end_date               DATE;
  l_personalParameterId  	AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_paramID;
  l_roundingParameterId  	AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_paramID;
BEGIN
  SELECT aeh.week_end_date, aeh.employee_id, flex_concatenated
  INTO l_week_end_date, l_employee_id, l_cost_center
  FROM ap_expense_report_headers_all aeh
  WHERE report_header_id = p_report_header_id;

  -----------------------------------------------------
  l_debug_info := 'Check whether user entered an Approver';
  -----------------------------------------------------
  IF (NOT (AP_WEB_DB_EXPRPT_PKG.GetOverrideApproverID(to_number(p_report_header_id), l_approver_id))) THEN
    l_approver_id := NULL;
  END IF;

  IF (l_approver_id IS NOT NULL) THEN
    RETURN to_char(l_approver_id);
  END IF;


  -----------------------------------------------------
  -- Start getting Award Manager ID based on entered Award Number.
  -- Please comment out the following code if it's not desired to have
  -- the Award Manager be included in the Approver list under any
  -- circumstance.
  -----------------------------------------------------

  IF (NOT AP_WEB_DB_EXPTEMPLATE_PKG.GetPersonalParamID(l_personalParameterId)) THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

  IF (NOT AP_WEB_DB_EXPTEMPLATE_PKG.GetRoundingParamID(l_roundingParameterId)) THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

  -----------------------------------------------------
  l_debug_info := 'Check whether there is only one Award Number entered and all lines have an Award Number';
  -----------------------------------------------------
  select count(distinct award_id), count(distinct nvl(award_id, -1)),
         count(distinct project_id), count(distinct nvl(project_id, -1))
  into l_num_of_distinct_awards, l_num_of_awards, l_num_of_distinct_projects, l_num_of_projects
  from ap_exp_report_dists_all dist
  where report_header_id = p_report_header_id
    and report_line_id not in (
        	select report_line_id
		from ap_expense_report_lines_all line
	        where line.report_header_id = dist.report_header_id
		  and web_parameter_id in (l_personalParameterId, l_roundingParameterId));

  -----------------------------------------------------
  l_debug_info := 'Try to get Award Manager ID if only one Award Number entered';
  -----------------------------------------------------
  IF (l_num_of_distinct_awards = 1 AND l_num_of_awards = 1) THEN
    select distinct award_id
    into l_award_id
    from ap_exp_report_dists_all dist
    where report_header_id = p_report_header_id
      and report_line_id not in (
        	select report_line_id
		from ap_expense_report_lines_all line
	        where line.report_header_id = dist.report_header_id
		  and web_parameter_id in (l_personalParameterId, l_roundingParameterId));

    l_approver_id := AP_WEB_AME_PKG.getAwardManagerID(l_award_id, nvl(l_week_end_date,trunc(sysdate)));
    RETURN checkAndGetApprover(l_approver_id,l_employee_id);
  END IF;

  -----------------------------------------------------
  -- End of getting Award Manager ID.
  -----------------------------------------------------


  -----------------------------------------------------
  -- Start getting Project Manager ID based on entered Project Number.
  -- Please comment out the following code if it's not desired to include
  -- Project Manager in the Approver list under any circumstance.
  -----------------------------------------------------

  -----------------------------------------------------
  l_debug_info := 'Try to get Project Manager ID if only one Project Number entered';
  -----------------------------------------------------
  IF (l_num_of_distinct_projects = 1 AND l_num_of_projects = 1) THEN
    select distinct project_id
    into l_project_id
    from ap_exp_report_dists_all dist
    where report_header_id = p_report_header_id
      and report_line_id not in (
        	select report_line_id
		from ap_expense_report_lines_all line
	        where line.report_header_id = dist.report_header_id
		  and web_parameter_id in (l_personalParameterId, l_roundingParameterId));

    l_approver_id := AP_WEB_AME_PKG.getProjectManagerID(l_project_id, nvl(l_week_end_date,trunc(sysdate)));
    RETURN checkAndGetApprover(l_approver_id,l_employee_id);
  END IF;
  -----------------------------------------------------
  -- End of getting Project Manager ID.
  -----------------------------------------------------


  -----------------------------------------------------
  -- Start getting Cost Center Owner ID based on entered Cost Center.
  -- Please comment out the following code if it's not desired to include
  -- the Cost Center owner in the Approver list under any circumstance.
  -----------------------------------------------------

  -----------------------------------------------------
  l_debug_info := 'Check whether entered Cost Center equals to Employee Default Cost Center';
  -----------------------------------------------------

  AP_WEB_UTILITIES_PKG.GetEmployeeInfo(
                  l_employee_name,
                  l_employee_num,
                  l_default_cost_center,
                  l_employee_id);

  IF (l_default_cost_center = l_cost_center) THEN
    RETURN NULL;
  END IF;

  -----------------------------------------------------
  l_debug_info := 'Return Cost Center Business Manager or Cost Center Owner if cost center if different from default';
  -----------------------------------------------------

  l_cost_center_manager_id := getCCBusinessManager(p_report_header_id, l_cost_center);

  IF (l_cost_center_manager_id IS NOT NULL) THEN
    RETURN checkAndGetApprover(l_cost_center_manager_id,l_employee_id);
  ELSE
    l_cost_center_owner_id := AP_WEB_CUST_AME_PKG.getCustomCostCenterOwner(p_report_header_id, l_cost_center);
    RETURN checkAndGetApprover(l_cost_center_owner_id,l_employee_id);
  END IF;

  -----------------------------------------------------
  -- End of getting Cost Center Owner ID.
  -----------------------------------------------------

  -----------------------------------------------------
  -- Return NULL if none of the above logic is enabled.
  -----------------------------------------------------
  RETURN NULL;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'getHeaderLevelApprover');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
	APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      -- Do not need to set the token since it has been done in the
      -- child process
      RAISE;
    END IF;
END getHeaderLevelApprover;


/*----------------------------------------------------------------------------*
 | Procedure
 |   getLineLevelApprover
 |
 | DESCRIPTION
 |   This function is to get the Approver ID for AME attribute
 |   Item Starting Point Person ID.
 |   Seeded logic for this function is as following:
 |     - If award number is entered, get the award manager ID.
 |     - If project number is entered, get the project manager ID.
 |     - Return the cost center owner ID if the line-level cost center
 |       is different than the employee's cost center. If the same,
 |       get the employee's supervisor ID.
 |
 | PARAMETERS
 |   p_report_header_id - The expense report ID.
 |   p_dist_line_number - The distribution line number of the
 |                              expense line.
 |
 | RETURNS
 |   Approver ID - Employee id of Line-Level Approver.
 |
 *----------------------------------------------------------------------------*/
-------------------------------------------------------------------------
FUNCTION getLineLevelApprover(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE,
			      p_dist_line_number IN AP_EXPENSE_REPORT_LINES.distribution_line_number%TYPE) RETURN VARCHAR2 IS
-------------------------------------------------------------------------
  l_debug_info			VARCHAR2(200);

BEGIN

 return null;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'getLineLevelApprover');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
	APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      -- Do not need to set the token since it has been done in the
      -- child process
      RAISE;
    END IF;
END getLineLevelApprover;




/*----------------------------------------------------------------------------*
 | Procedure
 |   getCustomCostCenterOwner
 |
 | DESCRIPTION
 |   This procedure provides a way to get Cost Center owner bases on
 |   report header ID and cost center.
 |   This function will be used for AME attribute
 |   Line Item Starting Point Person ID.
 |
 | PARAMETERS
 |   p_report_header_id - The expense report id of the report.
 |   p_cost_center      - The cost center entered by the user.
 |
 | RETURNS
 |   Cost Center Owner ID - Employee id of Cost Center owner.
 |   			  - Return null from this function means the associated
 |                	    AME attributes will have null value at run-time.
 |                	    The corresponding AME rules won't take affect.
 *----------------------------------------------------------------------------*/
-------------------------------------------------------------------------
FUNCTION getCustomCostCenterOwner(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE,
			    p_cost_center IN AP_EXPENSE_REPORT_LINES.FLEX_CONCATENATED%TYPE) RETURN VARCHAR2
-------------------------------------------------------------------------
IS
  l_debug_info			VARCHAR2(200);

BEGIN

  --
  -- Example: If cost center 999 doesn't have a cost center owner and it's
  -- used to later allocate the charge to the appropriate cost centers.
  -- All charges to this cost center will be approved by the employee's
  -- supervisor.
  --
  -- IF p_cost_center = '999' THEN
  --   RETURN NULL;
  -- END IF;
  --

  RETURN AP_WEB_AME_PKG.getCostCenterOwner(p_report_header_id, p_cost_center);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'getCustomCostCenterOwner');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
	APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      -- Do not need to set the token since it has been done in the
      -- child process
      RAISE;
    END IF;
END getCustomCostCenterOwner;

/*----------------------------------------------------------------------------*
 | Procedure
 |   getCCBusinessManager
 |
 | DESCRIPTION
 |   This function is to get the cost center business manager's ID.
 |
 | PARAMETERS
 |   p_report_header_id - The expense report ID.
 |   p_cost_center - The cost center entered by the user.
 |
 | RETURNS
 |   Cost Center Business Manager ID - Employee ID of Cost Center Business Owner.
 *----------------------------------------------------------------------------*/
-------------------------------------------------------------------------
FUNCTION getCCBusinessManager(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE,
			          p_cost_center IN AP_EXPENSE_REPORT_LINES.FLEX_CONCATENATED%TYPE) RETURN VARCHAR2
-------------------------------------------------------------------------
IS
  l_debug_info			VARCHAR2(200);
  l_cc_business_mgr_id		HR_ORGANIZATION_INFORMATION.ATTRIBUTE2%TYPE := NULL;
  l_segment_name 		FND_SEGMENT_ATTRIBUTE_VALUES.application_column_name%TYPE := NULL;
  l_rows_processed		NUMBER := 0;
  l_cur_hdl         		INTEGER;
  l_query_stmt	   		VARCHAR2(4000);
  l_char_of_accounts_id		GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE;

BEGIN
  -----------------------------------------------------
  l_debug_info := 'open the cursor for processing';
  -----------------------------------------------------
  l_cur_hdl := dbms_sql.open_cursor;

  -----------------------------------------------------
  l_debug_info := 'Get the Column Name which implements the Cost Center Segment';
  -----------------------------------------------------
  l_segment_name := AP_WEB_OA_REPORTING_UTIL.GetCostCenterSegmentName;

  IF (l_segment_name is not null) THEN

    -----------------------------------------------------
    l_debug_info := 'get char of accounts id';
    -----------------------------------------------------
    SELECT GS.chart_of_accounts_id
    INTO l_char_of_accounts_id
    FROM   ap_system_parameters_all S,
	   gl_sets_of_books GS,
	   ap_expense_report_headers_all erh
    WHERE  GS.set_of_books_id = S.set_of_books_id
    AND    S.org_id = erh.org_id
    AND    erh.report_header_id = p_report_header_id;

    -----------------------------------------------------
    l_debug_info := 'set query statement';
    -----------------------------------------------------
    -- This query will only include current employees
    -- and contingent workers, not terminated ones.

    l_query_stmt := 'SELECT DISTINCT HOIP.ATTRIBUTE2 business_manager_id
	FROM   GL_CODE_COMBINATIONS GLCC,
	       HR_ORGANIZATION_INFORMATION HOIP,
	       HR_ORGANIZATION_INFORMATION HOIC,
	       HR_ORGANIZATION_INFORMATION HOI,
	       PER_WORKFORCE_CURRENT_X PP
	WHERE  ENABLED_FLAG = ''Y''
	       AND    GLCC.' || l_segment_name || ' = :costCenter
	       AND    CHART_OF_ACCOUNTS_ID = :charOfAccountsId
	       AND    COMPANY_COST_CENTER_ORG_ID IS NOT NULL
	       AND    HOI.ORG_INFORMATION_CONTEXT = ''CLASS''
	       AND    HOI.ORG_INFORMATION1 = ''CC''
	       AND    HOIC.ORGANIZATION_ID = HOI.ORGANIZATION_ID
	       AND    UPPER(HOIC.ORG_INFORMATION_CONTEXT) = ''COMPANY COST CENTER''
	       AND    GLCC.COMPANY_COST_CENTER_ORG_ID = HOIC.ORGANIZATION_ID
	       AND    HOIC.ORGANIZATION_ID = HOIP.ORGANIZATION_ID
	       AND    UPPER(HOIP.ORG_INFORMATION_CONTEXT) = ''ORGANIZATION NAME ALIAS''
	       AND    PP.PERSON_ID = HOIP.ATTRIBUTE2';

    -----------------------------------------------------
    l_debug_info := 'parse cursor';
    -----------------------------------------------------
    dbms_sql.parse(l_cur_hdl, l_query_stmt,dbms_sql.native);

    -----------------------------------------------------
    l_debug_info := 'bind values to the placeholder';
    -----------------------------------------------------
    dbms_sql.bind_variable(l_cur_hdl, ':costCenter', p_cost_center);
    dbms_sql.bind_variable(l_cur_hdl, ':charOfAccountsId', l_char_of_accounts_id);

    -----------------------------------------------------
    l_debug_info := 'setup output';
    -----------------------------------------------------
    dbms_sql.define_column(l_cur_hdl, 1, l_cc_business_mgr_id, 150);

    -----------------------------------------------------
    l_debug_info := 'execute cursor';
    -----------------------------------------------------
    l_rows_processed := dbms_sql.execute(l_cur_hdl);

    -----------------------------------------------------
    l_debug_info := 'fetch a row';
    -----------------------------------------------------
    IF dbms_sql.fetch_rows(l_cur_hdl) > 0 then
      -- fetch columns from the row
      dbms_sql.column_value(l_cur_hdl, 1, l_cc_business_mgr_id);
    END IF;

    -----------------------------------------------------
    l_debug_info := 'close cursor';
    -----------------------------------------------------
    dbms_sql.close_cursor(l_cur_hdl);


  END IF;

  return l_cc_business_mgr_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'getCCBusinessManager');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
	APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      -- Do not need to set the token since it has been done in the
      -- child process
      RAISE;
    END IF;
END getCCBusinessManager;

/*----------------------------------------------------------------------------*
 | Procedure
 |   getCostCenterApprover
 |
 | DESCRIPTION
 |   This function is to get the Approver ID for AME post-chain-of-authority
 |   approvals
 |   Seeded logic for this function is as following:
 |     - If default cost center is not changed and the entered approver is
 |       not equal to employee's supervisor and the approver does not belong
 |       to employee's cost center then return the cost center owner's ID.
 |     - Else if default cost center is not changed then return NULL.
 |     - If default cost center is changed and the entered approver is not
 |       equal to employee's supervisor and the approver's cost center is
 |       the same as the entered cost center then return Null.
 |     - Else if default cost center is changed then return the cost center
 |       owner's ID.
 |
 | PARAMETERS
 |   p_report_header_id - The expense report ID.
 |
 | RETURNS
 |   Approver ID - Cost center owner ID.
 |      	 - Return NULL means no post-chain-of-authority approval
 |                 is required.
 *----------------------------------------------------------------------------*/
-------------------------------------------------------------------------
FUNCTION getCostCenterApprover(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE) RETURN VARCHAR2 IS
-------------------------------------------------------------------------
  l_debug_info			VARCHAR2(200);
  l_approver_id			AP_WEB_DB_EXPRPT_PKG.expHdr_overrideApprID;
  l_employee_id			NUMBER;
  l_cost_center_approver_id     NUMBER;
  l_default_cost_center		VARCHAR2(240);
  l_approver_default_cost_center  VARCHAR2(240);
  l_cost_center			VARCHAR2(240);
  l_employee_num		VARCHAR2(30);
  l_employee_name		VARCHAR2(240);
  l_manager_id			AP_WEB_DB_HR_INT_PKG.perEmp_supervisorID;

BEGIN

  -----------------------------------------------------
  -- Start getting Cost Center Owner ID based on entered Cost Center.
  -- Please comment out the following code if it's not desired to include
  -- the Cost Center owner in the Approver list under any circumstance.
  -----------------------------------------------------

  -----------------------------------------------------
  l_debug_info := 'Check whether entered Cost Center equals to Employee Default Cost Center';
  -----------------------------------------------------
  SELECT employee_id, flex_concatenated
  INTO   l_employee_id, l_cost_center
  FROM   AP_EXPENSE_REPORT_HEADERS_ALL
  WHERE report_header_id = p_report_header_id;

  AP_WEB_UTILITIES_PKG.GetEmployeeInfo(
                  l_employee_name,
                  l_employee_num,
                  l_default_cost_center,
                  l_employee_id);

  l_cost_center_approver_id := getCCBusinessManager(p_report_header_id, l_cost_center);

  IF (l_cost_center_approver_id IS NULL) THEN
    l_cost_center_approver_id := AP_WEB_CUST_AME_PKG.getCustomCostCenterOwner(p_report_header_id, l_cost_center);
  END IF;

  IF (l_default_cost_center = l_cost_center) THEN
    -----------------------------------------------------
    l_debug_info := 'Check whether user entered an Approver';
    -----------------------------------------------------
    IF (NOT (AP_WEB_DB_EXPRPT_PKG.GetOverrideApproverID(to_number(p_report_header_id), l_approver_id))) THEN
      l_approver_id := NULL;
    END IF;

    IF (l_approver_id IS NOT NULL) THEN
      -----------------------------------------------------
      l_debug_info := 'Check whether the entered Approvers cost center equals to employees default cost center';
      -----------------------------------------------------
      AP_WEB_UTILITIES_PKG.GetEmployeeInfo(
                  l_employee_name,
                  l_employee_num,
                  l_approver_default_cost_center,
                  l_approver_id);
      IF (l_default_cost_center <> l_approver_default_cost_center) THEN
        RETURN checkAndGetApprover(l_cost_center_approver_id,l_employee_id);
      ELSE
	RETURN NULL;
      END IF;
    ELSE
      RETURN NULL;
    END IF;
  ELSE
    -----------------------------------------------------
    l_debug_info := 'Check whether user entered an Approver';
    -----------------------------------------------------
    IF (NOT (AP_WEB_DB_EXPRPT_PKG.GetOverrideApproverID(to_number(p_report_header_id), l_approver_id))) THEN
      l_approver_id := NULL;
    END IF;

    IF (l_approver_id IS NOT NULL) THEN
      -----------------------------------------------------
      l_debug_info := 'Check whether the entered Approvers cost center equals to employees default cost center';
      -----------------------------------------------------
      AP_WEB_UTILITIES_PKG.GetEmployeeInfo(
                  l_employee_name,
                  l_employee_num,
                  l_approver_default_cost_center,
                  l_approver_id);

      IF (l_default_cost_center <> l_approver_default_cost_center) THEN
        RETURN checkAndGetApprover(l_cost_center_approver_id,l_employee_id);
      ELSE
	RETURN NULL;
      END IF;
    ELSE
      RETURN checkAndGetApprover(l_cost_center_approver_id,l_employee_id);
    END IF;
  END IF;

  -----------------------------------------------------
  -- Return NULL if none of the above logic is enabled.
  -----------------------------------------------------
  RETURN NULL;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'getCostCenterApprover');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
  	APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      -- Do not need to set the token since it has been done in the
      -- child process
      RAISE;
    END IF;
END getCostCenterApprover;

/*----------------------------------------------------------------------------*
  Function
	getTransactionRequestor

  Description
	Added the function for fixing Bug : 4387063
        called from AME attribute TRANSACTION_REQUESTOR_PERSON_ID

  PARAMETERS
	p_report_header_id - report_header_id

  RETURNS
	Return employee_id if the employee is Active i.e, Not suspended/terminated
        Return employee's manager if the employee is inactive
 *----------------------------------------------------------------------------*/
FUNCTION getTransactionRequestor(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE) RETURN NUMBER
IS
-------------------------------------------------------------------------
  l_debug_info			VARCHAR2(200);
  l_approver_id			AP_WEB_DB_EXPRPT_PKG.expHdr_overrideApprID;
  l_employee_id			NUMBER;
  l_emp_active                  VARCHAR2(1);

BEGIN

  select employee_id into l_employee_id
  from ap_expense_report_headers_all
  where report_header_id = p_report_header_id;

  --------------------------------------------------------------
  l_debug_info := 'Calling AP_WEB_DB_HR_INT_PKG.IsPersonActive';
  --------------------------------------------------------------
  l_emp_active := AP_WEB_DB_HR_INT_PKG.IsPersonActive(l_employee_id);
  if (l_emp_active = 'Y') then
     return l_employee_id;
  else
     --------------------------------------------------------------
     l_debug_info := 'Calling AP_WEB_EXPENSE_WF.GetManager';
     --------------------------------------------------------------
     return (AP_WEB_DB_HR_INT_PKG.getFinalActiveManager(l_employee_id));
  end if;

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AP_WEB_CUST_AME_PKG.getTransactionRequestor',
				    l_debug_info);
    APP_EXCEPTION.RAISE_EXCEPTION;
END getTransactionRequestor;

-------------------------------------------------------------------------
FUNCTION getProjectApprover(p_project_id IN VARCHAR2) RETURN NUMBER IS
-------------------------------------------------------------------------
  l_debug_info			VARCHAR2(200);

BEGIN

 return AP_WEB_AME_PKG.getProjectManagerID(to_number(p_project_id), trunc(sysdate));

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AP_WEB_CUST_AME_PKG.getProjectApprover',
				    l_debug_info);
    APP_EXCEPTION.RAISE_EXCEPTION;
END getProjectApprover;

-------------------------------------------------------------------------
FUNCTION getAwardApprover(p_award_id IN VARCHAR2) RETURN NUMBER IS
-------------------------------------------------------------------------
  l_debug_info			VARCHAR2(200);

BEGIN

 return AP_WEB_AME_PKG.getAwardManagerID(to_number(p_award_id), trunc(sysdate));

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AP_WEB_CUST_AME_PKG.getAwardApprover',
				    l_debug_info);
    APP_EXCEPTION.RAISE_EXCEPTION;
END getAwardApprover;

-------------------------------------------------------------------------
FUNCTION getDistCostCenterApprover(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE,
                                   p_cost_center IN VARCHAR2) RETURN NUMBER IS
-------------------------------------------------------------------------
  l_debug_info			VARCHAR2(200);
  l_cost_center_manager_id      NUMBER;
  l_cost_center_owner_id        NUMBER;
BEGIN

  l_cost_center_manager_id := to_number(getCCBusinessManager(p_report_header_id, p_cost_center));

  IF (l_cost_center_manager_id IS NOT NULL) THEN
    RETURN l_cost_center_manager_id;
  ELSE
    l_cost_center_owner_id := to_number(AP_WEB_CUST_AME_PKG.getCustomCostCenterOwner(p_report_header_id, p_cost_center));
    RETURN l_cost_center_owner_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AP_WEB_CUST_AME_PKG.getDistCostCenterApprover',
				    l_debug_info);
    APP_EXCEPTION.RAISE_EXCEPTION;
END getDistCostCenterApprover;

/*----------------------------------------------------------------------------*
 | Procedure
 |   getJobSupervisorApprover
 |
 | DESCRIPTION
 |   This function is to get person ID of non-default first approver
 |   for job-level/supervisor authority approval types.
 |   This function is called from JOB_LEVEL_NON_DEFAULT_STARTING_POINT_PERSON_ID
 |   and SUPERVISORY_NON_DEFAULT_STARTING_POINT_PERSON_ID
 |   Seeded logic for this function is as following:
 |     - If default cost center is not changed and the entered approver is
 |       not equal to employee's supervisor and the approver does not belong
 |       to employee's cost center then return the cost center owner's ID.
 |     - Else if default cost center is not changed then return NULL.
 |     - If default cost center is changed and the entered approver is not
 |       equal to employee's supervisor and the approver's cost center is
 |       the same as the entered cost center then return Null.
 |     - Else if default cost center is changed then return the cost center
 |       owner's ID.
 |
 | PARAMETERS
 |   p_item_class - The item class (header,line item,project,award,cost center)
 |   p_report_header_id - The expense report ID.
 |   p_item_id -> will have report_header_id if the item_class is 'header'
 |          -> will have distribution_line_number if the item_class is 'line item'
 |          -> will have cost center if the item_class is 'cost center'
 |          -> will have project_id if the item_class is 'project'
 |          -> will have award_id if the item_class is 'award'
 |
 | RETURNS
 |   Approver ID - Override approver as value for header attribute
 |           - project manager id for project attribute
 |           - award manager id for award attribute
 |           - cost center business manager's ID if its not null else
 |             it returns Cost Center owner
 | Note: When null is returned, value of Transaction_requestor_id is used as
 |       starting point person id.
 *----------------------------------------------------------------------------*/
-------------------------------------------------------------------------
FUNCTION getJobSupervisorApprover(p_item_class IN VARCHAR2,
                                  p_report_header_id IN NUMBER,
              			  p_item_id IN VARCHAR2
                                 ) RETURN NUMBER IS
-------------------------------------------------------------------------
  l_debug_info			VARCHAR2(200);
  l_override_approver_id        NUMBER;
  l_cost_center_manager_id      NUMBER;
  l_cost_center_owner_id        NUMBER;
BEGIN

  l_debug_info := 'item class: ' || p_item_class || ' item_id: ' || p_item_id;

  if (p_item_class = 'header') then

     select override_approver_id
     into l_override_approver_id
     from ap_expense_report_headers_all
     where report_header_id = p_report_header_id;

     return l_override_approver_id;

  elsif (p_item_class = 'project') then
     return getProjectApprover(p_item_id);
  elsif (p_item_class = 'award') then
     return getAwardApprover(p_item_id);
  elsif (p_item_class = 'cost center') then
     return getDistCostCenterApprover(p_report_header_id,p_item_id);
  else
     return null;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AP_WEB_CUST_AME_PKG.getJobSupervisorApprover',
				    l_debug_info);
    APP_EXCEPTION.RAISE_EXCEPTION;
END getJobSupervisorApprover;

END AP_WEB_CUST_AME_PKG;

/
