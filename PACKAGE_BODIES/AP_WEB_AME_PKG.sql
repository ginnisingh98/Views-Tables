--------------------------------------------------------
--  DDL for Package Body AP_WEB_AME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_AME_PKG" AS
/* $Header: apwxameb.pls 120.11.12010000.2 2009/04/02 05:01:28 rveliche ship $ */

-- Constants
C_HEADER VARCHAR2(50) := 'header';
C_LINE_ITEM VARCHAR2(50) := 'line item';
C_PROJECT VARCHAR2(50) := 'project';
C_AWARD VARCHAR2(50) := 'award';
C_COST_CENTER VARCHAR2(50) := 'cost center';


/*----------------------------------------------------------------------------*
 | Procedure
 |      getViolationTotal
 |
 | DESCRIPTION
 |	Get total violation amount.
 |	This function will be for the usage of AME attribute
 |	Policy Violations Total
 |
 | PARAMETERS
 |     	p_report_header_id - Report Header ID
 |
 | RETURNS
 |     	Violation Total - Total Violation Amount.
 *----------------------------------------------------------------------------*/
-------------------------------------------------------------------------
FUNCTION getViolationTotal(p_report_header_id IN VARCHAR2) RETURN NUMBER IS
-------------------------------------------------------------------------
  l_debug_info			VARCHAR2(200);
  l_violation_total	        NUMBER;
  l_extra_amount		NUMBER;

BEGIN
    -----------------------------------------------------
    l_debug_info := 'Start getViolationTotal';
    -----------------------------------------------------
    select sum(exceeded_amount)
    into l_violation_total
    from ap_pol_violations_all
    where report_header_id = p_report_header_id;

    -----------------------------------------------------
    l_debug_info := 'Get extra amount';
    -----------------------------------------------------

    /* 	If meals schedules are used with the Both option (both daily and
	individual checks), only rule that results in the higher policy
	violation should be used in the summation to prevent counting
	these violations twice.
    */

    select nvl(sum(least(viol1.exceeded_amount, viol2.exceeded_amount)), 0)
    into l_extra_amount
    from ap_pol_violations_all viol1, ap_pol_violations_all viol2
    where viol1.report_header_id = viol2.report_header_id
    and viol1.distribution_line_number = viol2.distribution_line_number
    and viol1.violation_type = 'DAILY_LIMIT'
    and viol2.violation_type = 'DAILY_SUM_LIMIT'
    and viol1.report_header_id = p_report_header_id;

    l_violation_total := l_violation_total - l_extra_amount;

    return l_violation_total;

EXCEPTION
  WHEN OTHERS THEN
    return 0;
END getViolationTotal;

/*----------------------------------------------------------------------------*
 | Procedure
 |      getAwardManagerID
 |
 | DESCRIPTION
 |	Get Award Manager ID base on an Award ID
 |	If couldn't find an active award manager, null will be returned and
 | 	the report will go to default manager for approval.
 |
 | PARAMETERS
 |     	p_award_id - Award ID
 |
 | RETURNS
 |     	Award Manager ID - Employee id of the Award manager.
 *----------------------------------------------------------------------------*/
FUNCTION getAwardManagerID(p_award_id   IN NUMBER,
                           p_as_of_date IN DATE) RETURN NUMBER
IS
  l_debug_info		VARCHAR2(200);
  l_award_manager_id 	NUMBER;
BEGIN
  -----------------------------------------------------
  l_debug_info := 'start getAwardManagerID';
  -----------------------------------------------------

  select gp.person_id
  into l_award_manager_id
  from gms_personnel gp,
       per_assignments_f pa,
       per_assignment_status_types past
  where gp.award_id = p_award_id
  and gp.award_role = C_AWARD_MANAGER_ROLE
  AND gp.start_date_active = ( select max(gp2.start_date_active)
                               from gms_personnel gp2
                               where gp2.award_role = C_AWARD_MANAGER_ROLE
                               and gp2.award_id = p_award_id
                               and gp2.start_date_active <= trunc(sysdate)
                             )
  AND gp.person_id = pa.person_id
  AND pa.primary_flag='Y'
  AND trunc(sysdate) between pa.effective_start_date and
      nvl(pa.effective_end_date, trunc(sysdate))
  AND pa.assignment_status_type_id= past.assignment_status_type_id
  AND past.per_system_status = C_ACTIVE_STATUS
  AND pa.assignment_type in ('E', 'C')
  AND rownum =1;

  return l_award_manager_id;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN NULL;

        WHEN OTHERS THEN
          IF (SQLCODE <> -20001) THEN
        	FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        	FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        	FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'getAwardManagerID');
        	FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
     	  END IF;
	APP_EXCEPTION.RAISE_EXCEPTION;
END getAwardManagerID;

/*----------------------------------------------------------------------------*
 | Procedure
 |      getProjectManagerID
 |
 | DESCRIPTION
 |	Get Project Manager ID based on a Project ID
 |	If couldn't find an active project manager, null will be returned and
 | 	the report will go to default manager for approval.
 |
 | PARAMETERS
 |     	p_project_id - Project ID
 |
 | RETURNS
 |     	Project Manager ID - Employee id of Project manager.
 *----------------------------------------------------------------------------*/
FUNCTION getProjectManagerID(p_project_id IN NUMBER,
                             p_as_of_date IN DATE) RETURN NUMBER
IS
  l_debug_info          VARCHAR2(200);
  l_project_manager_id 	NUMBER;
BEGIN
  -----------------------------------------------------
  l_debug_info := 'start getProjectManagerID';
  -----------------------------------------------------

  select ppp.person_id
  into l_project_manager_id
  from pa_project_players ppp,
       per_assignments_f pa,
       per_assignment_status_types past
  where ppp.project_id = p_project_id
  and ppp.project_role_type = C_PROJECT_MANAGER_ROLE_TYPE
  AND ppp.start_date_active = ( select max(pp2.start_date_active)
                                from pa_project_players pp2
                                where pp2.project_role_type = C_PROJECT_MANAGER_ROLE_TYPE
                                and pp2.project_id = p_project_id
                                and pp2.start_date_active <= trunc(sysdate)
                              )
  AND ppp.person_id = pa.person_id
  AND pa.primary_flag='Y'
  AND trunc(sysdate) between pa.effective_start_date and
      nvl(pa.effective_end_date, trunc(sysdate))
  AND pa.assignment_status_type_id= past.assignment_status_type_id
  AND past.per_system_status = C_ACTIVE_STATUS
  AND pa.assignment_type in ('E', 'C')
  AND rownum =1;

  return l_project_manager_id;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN NULL;

        WHEN OTHERS THEN
          IF (SQLCODE <> -20001) THEN
        	FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        	FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        	FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'getProjectManagerID');
        	FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
     	  END IF;
	APP_EXCEPTION.RAISE_EXCEPTION;
END getProjectManagerID;

/*----------------------------------------------------------------------------*
 | Procedure
 |      getTotalPerCostCenter
 |
 | DESCRIPTION
 |	Get total amount for a cost center.
 |	This function is used for AME attribute TOTAL_PER_COST_CENTER
 |
 | PARAMETERS
 |     	p_report_header_id - Report Header ID
 |	p_line_number      - Distribution Line Number
 |
 | RETURNS
 |     	Total Reimbursable Amount
 *----------------------------------------------------------------------------*/
-------------------------------------------------------------------------
FUNCTION getTotalPerCostCenter(p_report_header_id  IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE,
			       p_line_number       IN AP_EXPENSE_REPORT_LINES.distribution_line_number%TYPE) RETURN NUMBER
-------------------------------------------------------------------------
IS
  l_line_item_total	        NUMBER := 0;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_AME_PKG', 'start getTotalPerCostCenter');

  -- If project is enabled, then get the total reimbursable amount for the same project number. Otherwise, if line-level-accounting is enabled, get the total reimbursable amount for the same cost center

  SELECT SUM(AMOUNT)
  INTO l_line_item_total
  FROM AP_EXPENSE_REPORT_LINES_ALL
  WHERE REPORT_HEADER_ID = p_report_header_id
  AND FLEX_CONCATENATED = (
    SELECT FLEX_CONCATENATED
    FROM AP_EXPENSE_REPORT_LINES_ALL
    WHERE REPORT_HEADER_ID = p_report_header_id
    AND DISTRIBUTION_LINE_NUMBER = p_line_number
  )
  AND itemization_parent_id <> -1;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_AME_PKG', 'end getTotalPerCostCenter');
  return l_line_item_total;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN OTHERS THEN
    RETURN 0;
END getTotalPerCostCenter;

/*----------------------------------------------------------------------------*
 | Procedure
 |      getCostCenterOwner
 |
 | DESCRIPTION
 |	Get total amount for a cost center.
 |	This function is used for AME attribute TOTAL_PER_COST_CENTER
 |
 | PARAMETERS
 |     	p_report_header_id - Expense Report Header ID
 |      p_cost_center      - Cost Center
 |
 | RETURNS
 |     	Total Reimbursable Amount
 *----------------------------------------------------------------------------*/
-------------------------------------------------------------------------
FUNCTION getCostCenterOwner(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE,
			    p_cost_center IN AP_EXPENSE_REPORT_LINES.FLEX_CONCATENATED%TYPE) RETURN VARCHAR2
-------------------------------------------------------------------------
IS
  l_debug_info			VARCHAR2(200);
  l_segment_name 		FND_SEGMENT_ATTRIBUTE_VALUES.application_column_name%TYPE := NULL;
  l_cc_owner_id			HR_ORGANIZATION_INFORMATION.ORG_INFORMATION2%TYPE := NULL;
  l_rows_processed		NUMBER := 0;
  l_cur_hdl         		INTEGER;
  l_query_stmt	   		VARCHAR2(4000);
  l_errorText			VARCHAR2(200);
  l_char_of_accounts_id		GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE;

BEGIN

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
  l_debug_info := 'open cursor';
  -----------------------------------------------------
  l_cur_hdl := dbms_sql.open_cursor;

  -----------------------------------------------------
  l_debug_info := 'set query statement';
  -----------------------------------------------------
  -- 3176205: This query will only include current employees
  -- and contingent workers, not terminated ones.
  l_query_stmt := 'SELECT /*+ push_pred(PP) */ distinct HOIP.ORG_INFORMATION2  OWNER_ID
	FROM   GL_CODE_COMBINATIONS GLCC,
	       HR_ORGANIZATION_INFORMATION HOIP,
	       HR_ORGANIZATION_INFORMATION HOIC,
	       HR_ORGANIZATION_INFORMATION HOI,
	       PER_WORKFORCE_CURRENT_X PP
	-- Bug: 7558034AP_EXPENSE_REPORT_LINES_ALL LINES
	WHERE         ENABLED_FLAG = ''Y''
	       AND    GLCC.' || l_segment_name || ' = :costCenter
	       -- Bug 7558034AND    LINES.REPORT_HEADER_ID = :reportHeaderId
	       AND    CHART_OF_ACCOUNTS_ID = :charOfAccountsId
	       AND    COMPANY_COST_CENTER_ORG_ID IS NOT NULL
	       AND    HOI.ORG_INFORMATION_CONTEXT = ''CLASS''
	       AND    HOI.ORG_INFORMATION1 = ''CC''
	       AND    HOIC.ORGANIZATION_ID = HOI.ORGANIZATION_ID
	       AND    UPPER(HOIC.ORG_INFORMATION_CONTEXT) = ''COMPANY COST CENTER''
	       AND    GLCC.COMPANY_COST_CENTER_ORG_ID = HOIC.ORGANIZATION_ID
	       AND    HOIC.ORGANIZATION_ID = HOIP.ORGANIZATION_ID
	       AND    UPPER(HOIP.ORG_INFORMATION_CONTEXT) = ''ORGANIZATION NAME ALIAS''
	       AND    PP.PERSON_ID = HOIP.ORG_INFORMATION2';

  -----------------------------------------------------
  l_debug_info := 'parse cursor';
  -----------------------------------------------------
  dbms_sql.parse(l_cur_hdl, l_query_stmt,dbms_sql.native);

  -----------------------------------------------------
  l_debug_info := 'bind values to the placeholder';
  -----------------------------------------------------
  dbms_sql.bind_variable(l_cur_hdl, ':costCenter', p_cost_center);
  -- Bug: 7558034dbms_sql.bind_variable(l_cur_hdl, ':reportHeaderId', p_report_header_id);
  dbms_sql.bind_variable(l_cur_hdl, ':charOfAccountsId', l_char_of_accounts_id);

  -----------------------------------------------------
  l_debug_info := 'setup output';
  -----------------------------------------------------
  dbms_sql.define_column(l_cur_hdl, 1, l_cc_owner_id, 150);

  -----------------------------------------------------
  l_debug_info := 'execute cursor';
  -----------------------------------------------------
  l_rows_processed := dbms_sql.execute(l_cur_hdl);

  -----------------------------------------------------
  l_debug_info := 'fetch a row';
  -----------------------------------------------------
  IF dbms_sql.fetch_rows(l_cur_hdl) > 0 then
    -- fetch columns from the row
    dbms_sql.column_value(l_cur_hdl, 1, l_cc_owner_id);
  END IF;

  -----------------------------------------------------
  l_debug_info := 'close cursor';
  -----------------------------------------------------
  dbms_sql.close_cursor(l_cur_hdl);

  END IF;

  return l_cc_owner_id;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'getCostCenterOwner');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
     END IF;
  APP_EXCEPTION.RAISE_EXCEPTION;
END getCostCenterOwner;


/*----------------------------------------------------------------------------*
 | Procedure
 |   getViolationPercentage
 |
 | DESCRIPTION
 |   Get the violation percentage of total reimbursable amount.
 |   This function will be for the usage of AME attribute
 |   Policy Violations Percentage.
 |
 | PARAMETERS
 |   p_report_header_id - The expense report ID.
 |
 | RETURNS
 |   Violation percentage
 *----------------------------------------------------------------------------*/
-------------------------------------------------------------------------
FUNCTION getViolationPercentage(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE) RETURN NUMBER
-------------------------------------------------------------------------
IS
  l_debug_info		VARCHAR2(200);
  l_violationTotal 	NUMBER := 0;
  l_reportTotal		NUMBER;

BEGIN

  l_violationTotal := AP_WEB_AME_PKG.getViolationTotal(p_report_header_id);

  -----------------------------------------------------
  l_debug_info := 'If violation total less than 0 then return 0 percent violated.';
  -----------------------------------------------------
  IF (l_violationTotal <= 0) THEN
    return 0;
  END IF;

  -----------------------------------------------------
  l_debug_info := 'Get report total base on the report header id.';
  -----------------------------------------------------
  IF (NOT AP_WEB_DB_EXPRPT_PKG.GetHeaderTotal(p_report_header_id, l_reportTotal)) THEN
    return 0;
  END IF;

  -----------------------------------------------------
  -- If violation total greater than 0 but report total less than 0,
  -- return 100 percent violated.';
  -----------------------------------------------------
  IF (l_reportTotal <= 0) THEN
    return 100;
  -----------------------------------------------------
  -- Or return the desired violation percentage here for
  -- report total less than 0.
  -----------------------------------------------------
  END IF;

  return round(100*(l_violationTotal/l_reportTotal),2);


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'getViolationPercentage');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
     END IF;
   APP_EXCEPTION.RAISE_EXCEPTION;
END getViolationPercentage;


/*----------------------------------------------------------------------------*
 | Function
 |   isMissingReceiptsShortpay
 |
 | DESCRIPTION
 |   Checks if this is a Missing Receipts Shortpay
 |   This function will be for the usage of AME attribute:
 |   Missing Receipts Shortpay
 |
 | PARAMETERS
 |   p_report_header_id - The expense report ID.
 |
 | RETURNS
 |   ame_util.booleanAttributeTrue if Missing Receipts Shortpay
 |   ame_util.booleanAttributeFalse if not Missing Receipts Shortpay
 *----------------------------------------------------------------------------*/
-------------------------------------------------------------------------
FUNCTION isMissingReceiptsShortpay(p_report_header_id IN NUMBER) RETURN VARCHAR2 IS
-------------------------------------------------------------------------
  l_debug_info		VARCHAR2(200);

  l_is_missing_shortpay	varchar2(10) := ame_util.booleanAttributeFalse;

  l_apexp		VARCHAR2(8) := 'APEXP';
  l_no_receipts_shortpay_process	VARCHAR2(30) := 'NO_RECEIPTS_SHORTPAY_PROCESS';

BEGIN

  ------------------------------------------------------------
  l_debug_info := 'Check if in-process Missing Receipts Shortpay';
  ------------------------------------------------------------
  select ame_util.booleanAttributeTrue
  into   l_is_missing_shortpay
  from   ap_expense_report_headers aerh,
         wf_items wf
  where  aerh.report_header_id = p_report_header_id
  and    aerh.shortpay_parent_id is not null
  and    wf.item_type = l_apexp
  and    wf.Item_key = to_char(aerh.report_header_id)   -- Bug 6841589 (sodash) to solve the invalid number exception
  and    wf.end_date is null
  and    wf.root_activity = l_no_receipts_shortpay_process
  and    rownum = 1;

  return l_is_missing_shortpay;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN ame_util.booleanAttributeFalse;
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'isMissingReceiptsShortpay');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
     END IF;
   APP_EXCEPTION.RAISE_EXCEPTION;
END isMissingReceiptsShortpay;

/*
  Returns Award number based on award_id
*/
-------------------------------------------------------------------
FUNCTION GetAwardNumber(
	p_award_id 		IN 	NUMBER
) RETURN VARCHAR2 IS
-------------------------------------------------------------------
 l_award_number  GMS_AWARDS.AWARD_NUMBER%type;
BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_AME_PKG', 'Start GetAwardNumber');

  select award_number
  into   l_award_number
  from   GMS_AWARDS_ALL
  where  award_id = p_award_id;

  RETURN l_award_number;

EXCEPTION
	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetAwardNumber' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
END GetAwardNumber;

/*
  Calculates p_amount based on p_report_header_id, p_item_class and p_item_id
  p_item_id -> will have report_header_id if the item_class is C_HEADER
            -> will have distribution_line_number if the item_class is C_LINE_ITEM
            -> will have cost center if the item_class is C_COST_CENTER
            -> will have project_id if the item_class is C_PROJECT
            -> will have award_id if the item_class is C_AWARD
*/
-------------------------------------------------------------------------
PROCEDURE GetItemAmount(p_report_header_id IN NUMBER,
		p_item_class IN VARCHAR2,
              	p_item_id IN VARCHAR2,
              	p_amount OUT NOCOPY NUMBER) IS
-------------------------------------------------------------------------
BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_AME_PKG', 'Start GetItemAmount');

  if (p_item_class = C_HEADER) then
    select total
    into   p_amount
    from   ap_expense_report_headers_all
    where report_header_id = p_report_header_id;
  elsif (p_item_class = C_LINE_ITEM) then
    select sum(amount)
    into   p_amount
    from ap_expense_report_lines_all
    where report_header_id = p_report_header_id
    and distribution_line_number = p_item_id;
--    and report_line_id = p_item_id;
  elsif (p_item_class = C_PROJECT) then
    select nvl(sum(amount),0)
    into   p_amount
    from ap_exp_report_dists_all
    where report_header_id = p_report_header_id
    and project_id = p_item_id;
  elsif (p_item_class = C_AWARD) then
    select nvl(sum(amount),0)
    into   p_amount
    from ap_exp_report_dists_all
    where report_header_id = p_report_header_id
    and award_id = p_item_id;
  elsif (p_item_class = C_COST_CENTER) then
    select nvl(sum(amount),0)
    into   p_amount
    from ap_exp_report_dists_all
    where report_header_id = p_report_header_id
    and cost_center = p_item_id;
  end if;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_AME_PKG', 'End GetItemAmount');

EXCEPTION
	WHEN NO_DATA_FOUND THEN
    		null;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetItemAmount' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
END GetItemAmount;


/*
  Inserts data into table OIE_AME_NOTIF_GT
*/
-------------------------------------------------------------------------
PROCEDURE InsertToAMENotifGT(
			    p_report_header_id IN NUMBER,
			    p_orig_system IN VARCHAR2,
			    p_orig_system_id IN NUMBER,
			    p_item_class IN VARCHAR2,
			    p_item_id IN VARCHAR2,
			    p_amount IN NUMBER,
			    p_project_number IN VARCHAR2,
		 	    p_project_name IN VARCHAR2,
			    p_award_number IN VARCHAR2) as
-------------------------------------------------------------------------
BEGIN
   AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_AME_PKG', 'Start InsertToAMENotifGT');

               insert into OIE_AME_NOTIF_GT(
                            report_header_id,
			    orig_system,
			    orig_system_id,
			    item_class,
			    item_id ,
			    amount,
			    project_number,
		 	    project_name,
			    award_number
		)
		values
		(
			    p_report_header_id,
			    p_orig_system,
			    p_orig_system_id,
			    p_item_class,
			    p_item_id,
			    p_amount,
			    p_project_number,
			    p_project_name,
			    p_award_number
		);
   AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_AME_PKG', 'End InsertToAMENotifGT');

EXCEPTION
  WHEN OTHERS THEN
	AP_WEB_DB_UTIL_PKG.RaiseException( 'InsertToAMENotifGT' );
    	APP_EXCEPTION.RAISE_EXCEPTION;
END InsertToAMENotifGT;

/*
  Populates data into OIE_AME_NOTIF_GT and OIE_AME_APPROVER_AMT_GT.
  data in OIE_AME_NOTIF_GT will be used for displaying instructions to
  the approver in the approval notification.
  like, You are responsible for approving expenses that total 250.00 USD for cost center 420.
  data in OIE_AME_APPROVER_AMT_GT will be used for displaying Approver
  Amount in the approval notification.
  Calls ame_api2.getallapprovers1 to get the list of approver in the approval
  list, which would also have info on why the approver is placed on the
  approval list.
  p_display_instr -> is set to No if approver is on approval list due to
  header rules.
  Inserts only the data that is related to the p_approver_id.
  Data is populated into OIE_AME_APPROVER_AMT_GT by the call InitOieAmeApproverAmtGT
*/
-------------------------------------------------------------------------
PROCEDURE InitOieAmeNotifGT( p_report_header_id  IN   NUMBER,
                             p_approver_id       IN   NUMBER,
			     p_display_instr     OUT  NOCOPY VARCHAR2) iS
-------------------------------------------------------------------------
 l_debug_info			VARCHAR2(200);
 l_approvalProcessCompleteYNOut varchar2(10);
 l_approversOut 		ame_util.approversTable2;
 l_itemIndexesOut 		ame_util.idList;
 l_itemClassesOut  		ame_util.stringList;
 l_itemIdsOut   		ame_util.stringList;
 l_itemSourcesOut  		ame_util.longStringList;

 l_project_number  		pa_projects_all.segment1%type;
 l_project_name    		pa_projects_all.name%type;

 l_award_number    		gms_awards.award_number%type;

 l_item_class      		ame_item_classes.name%type;
 l_item_id         		ame_temp_old_approver_lists.item_id%type;

 l_amount  			number;

BEGIN

   AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_AME_PKG', 'Start InitOieAmeNotifGT');

   p_display_instr := 'Y';

   DELETE FROM OIE_AME_NOTIF_GT;

   -----------------------------------------------------------
   l_debug_info := 'Before call to ame_api2.getallapprovers1';
   -----------------------------------------------------------
   ame_api2.getallapprovers1(
     	   applicationIdIn   => AP_WEB_DB_UTIL_PKG.GetApplicationID,
	   transactionTypeIn => 'APEXP',
	   transactionIdIn   => to_char(p_report_header_id),
	   approvalProcessCompleteYNOut => l_approvalProcessCompleteYNOut,
	   approversOut      => l_approversOut,
	   itemIndexesOut    => l_itemIndexesOut,
	   itemClassesOut    => l_itemClassesOut,
	   itemIdsOut        => l_itemIdsOut,
	   itemSourcesOut    => l_itemSourcesOut);

   -----------------------------------------------------------
   l_debug_info := 'After call to ame_api2.getallapprovers1';
   -----------------------------------------------------------

   FOR i IN 1 .. l_approversOut.count LOOP

     if ( ((l_approversOut(i).approval_status IS NULL) OR
          (l_approversOut(i).approval_status <> 'REPEATED'))
        AND
          (l_approversOut(i).orig_system_id = p_approver_id) ) then

       if l_approversOut(i).item_id is null then

         for j in 1 .. l_itemIndexesOut.count loop
            if l_itemIndexesOut(j) = i then

               l_item_class := l_itemClassesOut(j);
               l_item_id := l_itemIdsOut(j);

	       if (l_item_class = C_HEADER) then
		  p_display_instr := 'N';
	       end if;

               if (l_item_class = C_PROJECT) then
                  if not AP_WEB_DB_PA_INT_PKG.GetProjectInfo(to_number(l_item_id),
			l_project_number,
			l_project_name) then
                     null;
                  end if;
               end if;

	       if (l_item_class = C_AWARD) then
                  l_award_number := GetAwardNumber(to_number(l_item_id));
               end if;

               -----------------------------------------------------------
               l_debug_info := 'Before call to GetItemAmount';
               -----------------------------------------------------------
	       GetItemAmount(p_report_header_id,
			     l_item_class,
			     l_item_id,
			     l_amount);

               -----------------------------------------------------------
               l_debug_info := 'Before call to InsertToAMENotifGT';
               -----------------------------------------------------------
	       InsertToAMENotifGT(
			    p_report_header_id,
			    l_approversOut(i).orig_system,
			    l_approversOut(i).orig_system_id,
			    l_itemClassesOut(j),
			    l_itemIdsOut(j),
			    l_amount,
			    l_project_number,
		 	    l_project_name,
			    l_award_number
		);
            end if;
         end loop; -- l_itemIndexesOut

       else -- if l_approversOut(i).item_id is null

               -- logic for l_approversOut(i).item_id is null
               l_item_class := l_approversOut(i).item_class;
               l_item_id := l_approversOut(i).item_id;

	       if (l_item_class = C_HEADER) then
		  p_display_instr := 'N';
	       end if;

               if (l_item_class = C_PROJECT) then
                  if not AP_WEB_DB_PA_INT_PKG.GetProjectInfo(to_number(l_item_id),
			l_project_number,
			l_project_name) then
                     null;
                  end if;
               end if;

	       if (l_item_class = C_AWARD) then
                  l_award_number := GetAwardNumber(to_number(l_item_id));
               end if;

               -----------------------------------------------------------
               l_debug_info := 'Before call to GetItemAmount';
               -----------------------------------------------------------
	       GetItemAmount(p_report_header_id,
			     l_item_class,
			     l_item_id,
			     l_amount);

               -----------------------------------------------------------
               l_debug_info := 'Before call to InsertToAMENotifGT';
               -----------------------------------------------------------
	       InsertToAMENotifGT(
			    p_report_header_id,
			    l_approversOut(i).orig_system,
			    l_approversOut(i).orig_system_id,
			    l_approversOut(i).item_class,
			    l_approversOut(i).item_id ,
			    l_amount,
			    l_project_number,
		 	    l_project_name,
			    l_award_number
		);
       end if;  -- if l_approversOut(i).item_id is null
     end if;

   END LOOP; -- l_approversOut.count

   -----------------------------------------------------------
   l_debug_info := 'Before call to InitOieAmeApproverAmtGT';
   -----------------------------------------------------------
   InitOieAmeApproverAmtGT(p_report_header_id);

   AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_AME_PKG', 'end InitOieAmeNotifGT');

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'InitOieAmeNotifGT');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
     END IF;
   APP_EXCEPTION.RAISE_EXCEPTION;
END InitOieAmeNotifGT;

/*
   populates the global temporary table OIE_AME_APPROVER_AMT_GT
   with approver amount for each line.
   If the approver is on the approver list due to line item rules
   then approver amount is same as line amount.
   otherwise the approver amount is calculated as sum of amount
   in the distributions for which the approver is on the approver
   list i.e, project or cost center or award.
   The information why the approver is on the approver list exist
   in oie_ame_notif_gt.
*/
PROCEDURE InitOieAmeApproverAmtGT(p_report_header_id IN NUMBER) IS

 -- 5213228: include only itemization parent lines in the cursor as we
 -- display only the parent lines in the notification.
 -- 5417790: include only itemization child lines in the cursor as we
 -- display only the child lines in the notification.
 cursor c1(p_report_header_id in number) is
   select report_line_id, nvl(amount,0) amount, distribution_line_number, itemization_parent_id
   from ap_expense_report_lines_all xl
   where xl.report_header_id = p_report_header_id
   and   (xl.itemization_parent_id is null or xl.itemization_parent_id <> -1);

 l_debug_info		VARCHAR2(200);
 l_line_approver  varchar2(1);
 l_approver_amount number;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_AME_PKG', 'start InitOieAmeApproverAmtGT');

  DELETE FROM OIE_AME_APPROVER_AMT_GT;

  for i in c1(p_report_header_id) loop
    begin
      -- gt.item_id -> will have distribution_line_number if the gt.item_class is C_LINE_ITEM
      select 'Y'
      into   l_line_approver
      from   oie_ame_notif_gt gt
      where  gt.item_class = C_LINE_ITEM
      and    gt.item_id = i.distribution_line_number;
--      and    gt.item_id = i.report_line_id;

      l_approver_amount := i.amount;

    exception
      when no_data_found then
        l_line_approver := 'N';
      when others then
        l_line_approver := 'N';
    end;

    if (l_line_approver = 'N') then
      /* gt.item_id -> will have cost center if the gt.item_class is C_COST_CENTER
                    -> will have project_id if the gt.item_class is C_PROJECT
                    -> will have award_id if the gt.item_class is C_AWARD
      */
      if i.itemization_parent_id = -1 then
        select nvl(sum(xd.amount),0)
        into   l_approver_amount
        from   ap_exp_report_dists_all xd,
               oie_ame_notif_gt gt
        where  xd.report_header_id = p_report_header_id
        and    xd.report_line_id in (
			select report_line_id
                        from ap_expense_report_lines_all
                        where report_header_id = p_report_header_id
                        and itemization_parent_id = i.report_line_id)
        and    ( (xd.cost_center = gt.item_id
                  and
                  gt.item_class = C_COST_CENTER)
                 or
                 (xd.project_id = gt.item_id
                  and
                  gt.item_class = C_PROJECT)
                 or
                 (xd.award_id = gt.item_id
                  and
                  gt.item_class = C_AWARD) );
      else
        select nvl(sum(xd.amount),0)
        into   l_approver_amount
        from   ap_exp_report_dists_all xd,
               oie_ame_notif_gt gt
        where  xd.report_header_id = p_report_header_id
        and    xd.report_line_id = i.report_line_id
        and    ( (xd.cost_center = gt.item_id
                  and
                  gt.item_class = C_COST_CENTER)
                 or
                 (xd.project_id = gt.item_id
                  and
                  gt.item_class = C_PROJECT)
                 or
                 (xd.award_id = gt.item_id
                  and
                  gt.item_class = C_AWARD) );
      end if;

      if (l_approver_amount > i.amount) then
        l_approver_amount := i.amount;
      end if;

    end if; -- (l_line_approver = 'N')


    insert into OIE_AME_APPROVER_AMT_GT(
		report_header_id,
		report_line_id,
		approver_amount)
    values (
		p_report_header_id,
		i.report_line_id,
		nvl(l_approver_amount,0));
  end loop;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_AME_PKG', 'end InitOieAmeApproverAmtGT');

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'InitOieAmeApproverAmtGT');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
     END IF;
   APP_EXCEPTION.RAISE_EXCEPTION;
END InitOieAmeApproverAmtGT;

END AP_WEB_AME_PKG;

/
