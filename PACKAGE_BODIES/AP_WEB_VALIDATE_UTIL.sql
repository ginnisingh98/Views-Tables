--------------------------------------------------------
--  DDL for Package Body AP_WEB_VALIDATE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_VALIDATE_UTIL" AS
/* $Header: apwvutlb.pls 120.34.12010000.3 2009/05/12 06:57:18 meesubra ship $ */

/* The prompt index are relative to AP_WEB_EXP_VIEW_REC */
C_Date1_Prompt CONSTANT  varchar2(3) := '6';
C_Date2_Prompt CONSTANT  varchar2(3) := '7';
C_Days_Prompt  CONSTANT  varchar2(3) := '8';
C_DAmount_Prompt CONSTANT varchar2(3) := '9';
C_Amount_Prompt CONSTANT  varchar2(3) := '23';
C_Exptype_Prompt CONSTANT varchar2(3) := '11';
C_Just_Prompt  CONSTANT  varchar2(3) := '12';
C_Grp_Prompt CONSTANT varchar2(3) := '24';
C_Missing_Prompt CONSTANT varchar2(3) := '30';
C_RecAmt_Prompt CONSTANT varchar2(3) := '10';
C_Rate_Prompt CONSTANT varchar2(3) := '22';
C_TaxName_Prompt CONSTANT varchar2(3) := '33';

C_RateFormat           CONSTANT VARCHAR2(15) := '9999990D9999999';

-- Used in WithinTolerance to compare amounts
C_Tolerance	CONSTANT NUMBER := .01;

C_Yes           CONSTANT VARCHAR2(1) := 'Y';
C_No            CONSTANT VARCHAR2(1) := 'N';

-- Indicates Valid dates after this date only
C_MinimumYear CONSTANT NUMBER := 1900;

-- Justification array: to be initialized when the package is instantiated
C_justreq_array 	AP_WEB_PARENT_PKG.Number_Array;

FUNCTION WithinTolerance(P_actual number,
                         P_target number) RETURN BOOLEAN;




Function CheckNum
        (p_num 			in number,
         p_errors 	in out nocopy AP_WEB_UTILITIES_PKG.expError,
         p_index 		in number,
         p_prompt 		in varchar2,
	 p_allow_negative 	in boolean default TRUE,
         p_absolute 		in boolean default FALSE) Return Boolean IS

  l_IsMobileApp boolean;

BEGIN

  l_IsMobileApp := AP_WEB_UTILITIES_PKG.IsMobileApp;

       if (p_allow_negative) then
	  return TRUE;
       else
          if (((p_num < 0) AND (NOT p_absolute)) OR
	      ((p_num <= 0) AND (p_absolute)))  then
             fnd_message.set_name('SQLAP', 'AP_WEB_NOT_POS_NUM');
             fnd_message.set_token('VALUE', to_char(p_num));
             AP_WEB_UTILITIES_PKG.AddExpError(p_errors,
               fnd_message.get_encoded(),
               AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
               p_prompt,
               p_index,
               AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
             return false;
           end if; /* p_num < 0 */
	end if;
        return true;
END CheckNum;

Function CheckPosNum
	(p_num in number,
         p_receipt_errors in out nocopy AP_WEB_UTILITIES_PKG.receipt_error_stack,
         p_index in number,
         p_prompt in varchar2,
	 p_absolute in boolean default FALSE) Return Boolean IS
BEGIN
       if (((p_num < 0) AND (NOT p_absolute)) OR
		((p_num <= 0) AND (p_absolute)))  then
          fnd_message.set_name('SQLAP', 'AP_WEB_NOT_POS_NUM');
          fnd_message.set_token('VALUE', to_char(p_num));
          AP_WEB_UTILITIES_PKG.AddMessage(p_receipt_errors,
            p_index,
            AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
            fnd_message.get_encoded(),
            p_prompt);

          return false;
        end if; /* p_num < 0 */
        return true;
END CheckPosNum;

/*--------------------------------------------------------------*
 | Function                                                     |
 |   IsValidYear                                                |
 |                                                              |
 | DESCRIPTION                                                  |
 |      Checks whether the given date has a valid year or not.  |
 |                                                              |
 | ASSUMPTION                                                   |
 |      The given date is a valid date.                         |
 | PARAMETERS                                                   |
 |      P_Date IN                                               |
 | RETURNS                                                      |
 |      Boolean indicating whether the year is valid or not.    |
 *--------------------------------------------------------------*/
FUNCTION IsValidYear(P_Date IN DATE)  RETURN BOOLEAN
IS
  V_Year NUMBER;
BEGIN
  V_Year := to_number(to_char(P_Date, 'SYYYY'));

  IF V_Year < C_MinimumYear THEN
    return FALSE;
  END IF;

  return TRUE;
EXCEPTION
  when others then
    return FALSE;
END IsValidYear;


FUNCTION IsValidDate(P_DateStr IN VARCHAR2,
                     P_DateFormat IN VARCHAR2) RETURN BOOLEAN
IS
  V_Temp DATE;
BEGIN
  V_Temp := to_date(P_DateStr, P_DateFormat);
  return TRUE;
EXCEPTION
  when others then
    return FALSE;
END IsValidDate;

/*----------------------------------------------------------------------------*
 | Procedure                                                                  |
 |      ValidateExpLinesCustomFields                                          |
 |                                                                            |
 | DESCRIPTION                                                                |
 |	Server-Side validation for multiple receipt lines custom fields	      |
 |									      |
 | ASSUMPTION								      |
 |	Currently this procedure only be used by AP_WEB_SUBMIT_PKG.SaveOrSubmit
 |      for Blue-Gray UI						      |
 | PARAMETERS                                                                 |
 |                                                                            |
 | RETURNS                                                                    |
 |     none                                                                   |
 *----------------------------------------------------------------------------*/
PROCEDURE ValidateExpLinesCustomFields(
        p_report_header_info  IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
        p_report_lines_info   IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportLines_A,
        p_custom1_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom2_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom3_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom4_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom5_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom6_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom7_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom8_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom9_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom10_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom11_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom12_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom13_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom14_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom15_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_num_max_flex_field  IN NUMBER,
        P_IsSessionTaxEnabled IN VARCHAR2,
        P_IsSessionProjectEnabled IN VARCHAR2,
	p_receipts_count      IN BINARY_INTEGER,
	p_receipt_errors      IN OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack,
	p_receipts_with_errors_count  IN OUT NOCOPY BINARY_INTEGER,
	p_calculate_receipt_index     IN BINARY_INTEGER,
        p_error               IN OUT NOCOPY  AP_WEB_UTILITIES_PKG.expError,
        p_addon_rates         IN OIE_ADDON_RATES_T DEFAULT NuLL,
	p_report_line_id      IN NUMBER DEFAULT NULL,
        p_daily_breakup_id              IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_start_date                    IN      OIE_PDM_DATE_T DEFAULT NULL,
        p_end_date                      IN      OIE_PDM_DATE_T DEFAULT NULL,
        p_amount                        IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_number_of_meals               IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_meals_amount                  IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_breakfast_flag                IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
        p_lunch_flag                    IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
        p_dinner_flag                   IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
        p_accommodation_amount          IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_accommodation_flag            IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
        p_hotel_name                    IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL,
        p_night_rate_Type               IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL,
        p_night_rate_amount             IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_pdm_rate                      IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_rate_Type_code                IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL,
        p_pdm_breakup_dest_id           IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_pdm_destination_id            IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_dest_start_date               IN      OIE_PDM_DATE_T DEFAULT NULL,
        p_dest_end_date                 IN      OIE_PDM_DATE_T DEFAULT NULL,
        p_location_id                   IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_cust_meals_amount             IN OUT  NOCOPY OIE_PDM_NUMBER_T,
        p_cust_accommodation_amount     IN OUT  NOCOPY OIE_PDM_NUMBER_T,
        p_cust_night_rate_amount        IN OUT  NOCOPY OIE_PDM_NUMBER_T,
        p_cust_pdm_rate                 IN OUT  NOCOPY OIE_PDM_NUMBER_T
)
----------------------------------------------------------------------------
IS

  l_receipt_index		       BINARY_INTEGER := p_calculate_receipt_index;
  l_debug_info		       VARCHAR2(2000);

  i                            INTEGER;

  V_SysInfoRec		       AP_WEB_DB_AP_INT_PKG.APSysInfoRec;   -- For PATC: Exchange rate type in AP and  Functional currency
  V_EndExpenseDate             DATE;           -- For PATC: Latest receipt date
  V_DefaultExchangeRate        NUMBER;         -- For PATC: Exchange rate for func->reimb
  V_DateTemp                   DATE;           -- For PATC: Scratch variable
  V_DateFormat                 VARCHAR2(30);

  l_IsMobileApp boolean;
  l_DataDefaultedUpdateable BOOLEAN;
  l_vendor_id		AP_WEB_DB_AP_INT_PKG.vendors_vendorID;
  l_vend_pay_curr	AP_WEB_DB_AP_INT_PKG.vendors_paymentCurrCode;
  l_vend_pay_curr_name  AP_WEB_DB_COUNTRY_PKG.curr_name;

BEGIN

  l_IsMobileApp := AP_WEB_UTILITIES_PKG.IsMobileApp;

  IF (p_receipts_count = 0) THEN
    RETURN;
  END IF;
  p_receipts_with_errors_count := 0;

  -- The following calcuations marked with "For PATC" were
  -- added for the R11i support for multicurrency in PA.
  -- We need to retrieve currency and exchange rate information
  -- before calling PATC.

  -- For PATC: Used when doing projects verification
  --Bug 3336823
  V_DateFormat :=  nvl(icx_sec.g_date_format,icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT'));


  -- For PATC: Determine the time-wise last receipt to use as the
  -- exchange rate date
  -- Assumes has at least one receipt
  l_debug_info := 'Getting latest date in report'||V_DateFormat;
  V_EndExpenseDate := to_date(p_report_lines_info(1).start_date, V_DateFormat);

  FOR i IN 1 .. P_Receipts_Count LOOP
    V_DateTemp := to_date(p_report_lines_info(i).start_date, V_DateFormat);
    if (V_EndExpenseDate < V_DateTemp) then
      V_EndExpenseDate := V_DateTemp;
    end if;

    if (p_report_lines_info(i).end_date IS NOT NULL) then
      l_debug_info := 'Getting end_date';
      V_DateTemp := to_date(p_report_lines_info(i).end_date, V_DateFormat);
      if (V_EndExpenseDate < V_DateTemp) then
        V_EndExpenseDate := V_DateTemp;
      end if;
    end if;

  END LOOP;

  -- For PATC: Get information about functional currency and exchange
  -- rate for the last receipt date.  The last receipt date will be
  -- equal to sysdate.
  L_debug_info := 'Getting functional currency and exchange rate info';

  IF (NOT AP_WEB_DB_AP_INT_PKG.GetAPSysCurrencySetupInfo(V_SysInfoRec)) THEN
	NULL;
  END IF;

  IF (NOT AP_WEB_DB_AP_INT_PKG.GetVendorInfoOfEmp(p_report_header_info.employee_id,
			l_vendor_id,
                    	l_vend_pay_curr,
                    	l_vend_pay_curr_name
		    )) THEN
	  l_vendor_id := NULL;
          l_vend_pay_curr := NULL;
          l_vend_pay_curr_name := NULL;
  END IF;

  -- For PATC: Get the default exchange rate for the V_EndExpenseDate
  -- reimbursement currency/functional currency
  -- We are only calling this once for all receipts
     V_DefaultExchangeRate := AP_UTILITIES_PKG.get_exchange_rate(
      nvl(l_vend_pay_curr, V_SysInfoRec.base_currency),
      p_report_header_info.reimbursement_currency_code,
      V_SysInfoRec.default_exchange_rate_type,
      V_EndExpenseDate,
     'ValidatePATransaction');

  p_report_header_info.number_max_flexfield := p_num_max_flex_field;

  l_debug_info := 'Validate custom flexfields';
  -- Bug Fix 2280687 : Do not validate all lines when we select Calculate Amount
  IF ((p_calculate_receipt_index is not null) and (p_calculate_receipt_index > 0)) THEN
    p_report_lines_info(p_calculate_receipt_index).receipt_index := p_calculate_receipt_index;
    ValidateExpLineCustomFields(
        null,
	p_report_header_info,
	p_report_lines_info(p_calculate_receipt_index),
	l_receipt_index,
	V_SysInfoRec,
	V_DefaultExchangeRate,
	V_EndExpenseDate,
	V_DateFormat,
	p_custom1_array,
        p_custom2_array,
        p_custom3_array,
        p_custom4_array,
        p_custom5_array,
        p_custom6_array,
        p_custom7_array,
        p_custom8_array,
        p_custom9_array,
        p_custom10_array,
        p_custom11_array,
        p_custom12_array,
        p_custom13_array,
        p_custom14_array,
        p_custom15_array,
        P_IsSessionTaxEnabled,
        P_IsSessionProjectEnabled,
	p_receipt_errors,
	p_calculate_receipt_index,
        p_error,
	p_receipts_with_errors_count,
        l_DataDefaultedUpdateable,
        FALSE,
        false,
        p_addon_rates,
        p_report_line_id,
        p_daily_breakup_id,
        p_start_date,
        p_end_date,
        p_amount,
        p_number_of_meals,
        p_meals_amount,
        p_breakfast_flag,
        p_lunch_flag,
        p_dinner_flag,
        p_accommodation_amount,
        p_accommodation_flag,
        p_hotel_name,
        p_night_rate_Type,
        p_night_rate_amount,
        p_pdm_rate,
        p_rate_Type_code,
        p_pdm_breakup_dest_id,
        p_pdm_destination_id,
        p_dest_start_date,
        p_dest_end_date,
        p_location_id,
        p_cust_meals_amount,
        p_cust_accommodation_amount,
        p_cust_night_rate_amount,
        p_cust_pdm_rate
        );
  ELSE
    FOR l_receipt_index in 1 .. p_receipts_count LOOP
      p_report_lines_info(l_receipt_index).receipt_index := l_receipt_index;
      ValidateExpLineCustomFields(
        null,
	p_report_header_info,
	p_report_lines_info(l_receipt_index),
	l_receipt_index,
	V_SysInfoRec,
	V_DefaultExchangeRate,
	V_EndExpenseDate,
	V_DateFormat,
	p_custom1_array,
        p_custom2_array,
        p_custom3_array,
        p_custom4_array,
        p_custom5_array,
        p_custom6_array,
        p_custom7_array,
        p_custom8_array,
        p_custom9_array,
        p_custom10_array,
        p_custom11_array,
        p_custom12_array,
        p_custom13_array,
        p_custom14_array,
        p_custom15_array,
        P_IsSessionTaxEnabled,
        P_IsSessionProjectEnabled,
	p_receipt_errors,
	p_calculate_receipt_index,
        p_error,
	p_receipts_with_errors_count,
        l_DataDefaultedUpdateable,
        FALSE,
	TRUE, -- for Blue Gray UI,
        p_addon_rates,
        p_report_line_id,
        p_daily_breakup_id,
        p_start_date,
        p_end_date,
        p_amount,
        p_number_of_meals,
        p_meals_amount,
        p_breakfast_flag,
        p_lunch_flag,
        p_dinner_flag,
        p_accommodation_amount,
        p_accommodation_flag,
        p_hotel_name,
        p_night_rate_Type,
        p_night_rate_amount,
        p_pdm_rate,
        p_rate_Type_code,
        p_pdm_breakup_dest_id,
        p_pdm_destination_id,
        p_dest_start_date,
        p_dest_end_date,
        p_location_id,
        p_cust_meals_amount,
        p_cust_accommodation_amount,
        p_cust_night_rate_amount,
        p_cust_pdm_rate
      );

    END LOOP;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     'ValidateExpLinesCustomFields');
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'None passed.');
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;

        APP_EXCEPTION.RAISE_EXCEPTION;
      END;
END ValidateExpLinesCustomFields;

PROCEDURE ValidateApprover(p_employee_id in varchar2,
			     p_approverName in out nocopy varchar2,
			     p_approverID  in out nocopy varchar2,
			     p_ap_error out nocopy varchar2
			     ) IS
  l_approvercount 		NUMBER;                       -- Bug 709879
  l_approverid 			AP_WEB_DB_HR_INT_PKG.empCurrent_employeeID;
  l_approverfullname    	AP_WEB_DB_HR_INT_PKG.empCurrent_fullName;   -- Bug 709879
  l_upper_approver_name_exact   AP_WEB_DB_HR_INT_PKG.empCurrent_fullName;    -- Bug 709879
  l_upper_approver_name_fuzzy   AP_WEB_DB_HR_INT_PKG.empCurrent_fullName;
  l_paren_position		NUMBER;
  debug_info			VARCHAR2(2000);
  l_approvers_cursor 		AP_WEB_DB_HR_INT_PKG.EmpInfoCursor;

BEGIN
  p_approverName := ltrim(p_approverName);
  -- If the p_approverID argument is not null, then we are assuming that the
  -- approver name was (1) derived using an LOV or (2) restored from a report
  -- where the approver ID was already determined.
  -- In those scenarios, it is not necessary to derive the override approver name or ID.
  IF (p_approverID IS NOT NULL) THEN

    -- Store the current p_approverID
    l_approverID := p_approverID;

  ELSE

    -- Approver ID and name is not yet known
    l_approvercount := 0;
    p_approverID := null;
    p_ap_error := null;

    --Bug 2502624. Removed the trimming of the approverName to the first occurance
    --of '('.Terminating the employee name at the first '(' might result
    -- in duplicate employees being found.

    l_upper_approver_name_exact := UPPER(p_approverName);

    -- Bug 1363739, Added the condition to prevent performing validation
    -- if the value is null
    IF l_upper_approver_name_exact is null THEN
       return;
    END IF;

    l_upper_approver_name_fuzzy := l_upper_approver_name_exact || '%';

      --
      -- If 3rd party case, the person for whom the expense report is prepared
      -- for AND the preparer cannot be the Overriding Approver
      --

    BEGIN
      -- Bug 709879
      -- Problem: exact search on approver fullname would always result
      -- in too many approvers found if another approver's partial
      -- fullname was like the exact one being searched on due to fuzzy
      -- Solution: use a cursor for fuzzy search and check for exact match
      -- Caveat: Does not handle case where 2+ employees have exact same
      -- fullname; 1st employee found with exact fullname match wins
      IF (AP_WEB_DB_HR_INT_PKG.GetEmployeeInfoCursor(p_approverName,
		l_upper_approver_name_fuzzy, l_approvers_cursor)) THEN
      	 FETCH l_approvers_cursor
	 INTO  l_approverid, l_approverfullname;
      	 WHILE l_approvers_cursor%FOUND LOOP
      	   l_approvercount := l_approvercount + 1;

/*         Removing this check because we want to alert the user that there
           are other full names that roughly match.
           --  Bug 1363739, Added upper as l_upper_approver_name_exact is
           --  already in upper and the fetch would return what is in the DB
           IF (UPPER(l_approverfullname) = l_upper_approver_name_exact) THEN
      	     EXIT;
      	   END IF;
*/

           -- Bug 1363739, If a partial value is entered for approver and
           -- there are say 1000 matches found, then we need not loop for
           -- all thousand instead exit if there are more than 2 matches
           IF l_approvercount > 2 THEN
      	     EXIT;
           END IF;

      	   FETCH l_approvers_cursor INTO l_approverid, l_approverfullname;
      	 END LOOP;
      END IF;
      CLOSE l_approvers_cursor;

      if (l_approvercount > 1) then
        FND_MESSAGE.SET_NAME('SQLAP','AP_WEB_TOO_MANY_APPROVERS');
        p_ap_error:=  fnd_message.get_encoded();
        RETURN;
      elsif (l_approvercount = 0) then
        FND_MESSAGE.SET_NAME('SQLAP','AP_WEB_FOUND_NO_APPROVERS');
        p_ap_error :=  fnd_message.get_encoded();
        RETURN;
      end if;

    EXCEPTION
      when TOO_MANY_ROWS then
        FND_MESSAGE.SET_NAME('SQLAP','AP_WEB_TOO_MANY_APPROVERS');
        p_ap_error:=  fnd_message.get_encoded();
        RETURN;
      when NO_DATA_FOUND then
        FND_MESSAGE.SET_NAME('SQLAP','AP_WEB_FOUND_NO_APPROVERS');
        p_ap_error :=  fnd_message.get_encoded();
        RETURN;
      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE','ValidateApprover');
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
          FND_MESSAGE.SET_TOKEN('PARAMETERS','');
          AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get_encoded());
        END IF;
     END;
  END IF; --   IF (p_approverID IS NOT NULL) THEN

  -- Bug 711957/669360
  -- preparer and employee cannot be the approver
  -- and   hr.employee_id != to_number(p_employee_id);
  -- Bug 3198236 : corrected error messages
  if (l_ApproverID =  AP_WEB_DB_HR_INT_PKG.getEmployeeID) then
    fnd_message.set_name('SQLAP', 'AP_WEB_PREP_CANNOT_APPROVE');
    p_ap_error := fnd_message.get_encoded();
  elsif (l_ApproverID = to_number(p_employee_id)) then
    fnd_message.set_name('SQLAP', 'AP_WEB_EMP_CANNOT_APPROVE');
    p_ap_error := fnd_message.get_encoded();
  else
    -- Assign the p_approverID only if there are no errors
    p_approverID := to_char(l_approverid);
    p_approverName := l_approverfullname;
  end if;
END ValidateApprover;

PROCEDURE ValidateCostCenter(p_costcenter IN  AP_EXPENSE_FEED_DISTS.cost_center%TYPE,
			     p_cs_error     OUT NOCOPY varchar2,
        		     p_employee_id  IN  NUMBER) IS
p_CostCenterValid       boolean := FALSE;
l_customError           varchar2(2000);

l_CostCenterValid	BOOLEAN := FALSE;
l_IsMobileApp	        BOOLEAN := FALSE;
l_error_message         VARCHAR2(2000);
l_default_emp_segments  AP_OIE_KFF_SEGMENTS_T;
l_employee_ccid         AP_WEB_DB_EXPRPT_PKG.expHdr_employeeCCID;


BEGIN


  l_IsMobileApp := AP_WEB_UTILITIES_PKG.IsMobileApp;

  --
  -- Call custom cost center validation API
  --
  if (AP_WEB_CUST_DFLEX_PKG.CustomValidateCostCenter(
         l_customError,
         p_costcenter,
         p_CostCenterValid,
         p_employee_id)) then
    --
    -- Custom validation API returned TRUE; therefore custom validation
    -- is used in lieu of native cost center validation
    --
    if (p_CostCenterValid) then
      --
      -- If custom validation succeeds, clear the error text
      --
      p_cs_error := null;
    else
      --
      -- Custom validation failed; supply standard failure message if
      -- custom error message is null
      --
      if (l_customError is null) then
        if (not l_IsMobileApp) then
          FND_MESSAGE.SET_NAME('SQLAP','AP_WEB_COST_CENTER_INVALID');
        else
          FND_MESSAGE.SET_NAME('SQLAP','AP_OME_COST_CENTER_ERROR');
        end if;
        p_cs_error:= fnd_message.get_encoded();
      else
        p_cs_error := l_customError;
      end if;
    end if;
  else
    --
    -- Custom validation API returned FALSE; therefore we validate using
    -- the cursor declared above.
    --
    IF (NOT AP_WEB_DB_AP_INT_PKG.CostCenterValid(p_costCenter,
		l_CostCenterValid,
                p_employee_id)) THEN
	NULL;
    END IF;

    if (NOT l_CostCenterValid) then
      --
      -- Failed; set standard failure message.
      --
      if (not l_IsMobileApp) then
        FND_MESSAGE.SET_NAME('SQLAP','AP_WEB_COST_CENTER_INVALID');
      else
        FND_MESSAGE.SET_NAME('SQLAP','AP_OME_COST_CENTER_ERROR');
      end if;
      p_cs_error:= fnd_message.get_encoded();
    end if;
  end if;

  -- Bug: 5161664, Default Expense Account Validation.
  -- Same code is called from General Information and Spreadsheet upload
  IF (p_CostCenterValid OR l_CostCenterValid) THEN
      AP_WEB_ACCTG_PKG.BuildAccount(
                          p_report_header_id => null,
                          p_report_line_id => null,
                          p_employee_id => p_employee_id,
                          p_cost_center => p_costCenter,
                          p_line_cost_center => null,
                          p_exp_type_parameter_id => null,
                          p_segments => null,
                          p_ccid => null,
                          p_build_mode => AP_WEB_ACCTG_PKG.C_DEFAULT_VALIDATE,
                          p_new_segments => l_default_emp_segments,
                          p_new_ccid => l_employee_ccid,
                          p_return_error_message => l_error_message);
      IF (l_error_message IS NOT NULL) THEN
         -- BuildAccount will in itself add to fnd message pub, initialize to avoid that
         -- No side effects with initialize in Spread Sheet import, all error messages properly displayed.
         fnd_msg_pub.initialize;
         FND_MESSAGE.SET_NAME('SQLAP','OIE_DEA_VALIDATION_ERROR');
         FND_MESSAGE.SET_TOKEN('VAL_ERROR', l_error_message);
         p_cs_error:= fnd_message.get_encoded();
      END IF;
   END IF;

   EXCEPTION
      WHEN OTHERS THEN
        AP_WEB_DB_UTIL_PKG.RaiseException('Validate Cost Center');
        APP_EXCEPTION.RAISE_EXCEPTION;

END ValidateCostCenter;



FUNCTION IsReceiptRequired
        (p_require_receipt_amount number,
        p_amount varchar2,
        p_reimb_curr varchar2,
        p_base_currency varchar2) RETURN BOOLEAN IS
--
-- Returns true if the receipt is required, false otherwise.
-- The require_receipt_amount value in ap_expense_report_params is based
-- on base currency. Since we'll do currency exchange in a fairly late
-- state (in workflow), for any receipt that is in non-base currency,
-- if the require_receipt_amount is >= 0 for its expense type, we
-- set receipt required to true for this receipt. (7/15/97)
--

l_amt number;

BEGIN

  l_amt := nvl(p_require_receipt_amount, -1);
  if (l_amt >= 0) then
    if (nvl(p_reimb_curr, p_base_currency) <> p_base_currency) then
      -- receipt currency not equal to base currency
      return true;
    elsif (to_number(p_amount) > l_amt) then
      -- receipt amount exceed threshold
      return true;
    else
      return false;
    end if;
  else
    return false;
  end if;
  return false;
END IsReceiptRequired;

FUNCTION WithinTolerance(P_actual number,
			 P_target number) RETURN BOOLEAN
--
-- Used in comparing what user entered with our calculation.
-- Depending on currency format, that could be some diff in rounding.
-- Don't want to be too restrictive, but the tolerance can be adjusted.
--
IS
BEGIN
  RETURN ((P_actual < (P_target + C_Tolerance)) AND
	  (P_actual > (P_target - C_Tolerance)));
END;

---------------------------------------------------------------
PROCEDURE ValidateReportHeader(
	ExpReportHeaderInfo 	IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
	p_Error		  	IN OUT NOCOPY AP_WEB_UTILITIES_PKG.expError

) IS
---------------------------------------------------------------
  l_FuncCode			varchar2(50) := 'AP_WEB_EXPENSES';
BEGIN

  IF ( AP_WEB_INFRASTRUCTURE_PKG.validatesession(l_FuncCode) ) THEN
	ValidateHeaderNoValidSession(p_user_id 		 => null, -- 2242176, use preparer in blue gray
                                     ExpReportHeaderInfo => ExpReportHeaderInfo,
				     p_error 		 => p_Error,
				     p_bFull_Approver_Validation => TRUE);
  END IF;

END ValidateReportHeader;


/*----------------------------------------------------------------------------*
 | Procedure                                                                  |
 |      ValidateHeaderNoValidSession                                          |
 |                                                                            |
 | DESCRIPTION                                                                |
 |	Server-Side validation for report header without calling	      |
 |	validatesession	   						      |
 |									      |
 | ASSUMPTION								      |
 |									      |
 | PARAMETERS                                                                 |
 |                                                                            |
 | RETURNS                                                                    |
 |     none                                                                   |
 *----------------------------------------------------------------------------*/
PROCEDURE ValidateHeaderNoValidSession(
        p_user_id               IN NUMBER, -- 2242176, fnd user id
	ExpReportHeaderInfo 	IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
	p_error		  	IN OUT NOCOPY AP_WEB_UTILITIES_PKG.expError,
	p_bFull_Approver_Validation IN BOOLEAN

) IS
---------------------------------------------------------------
  l_last_receipt       		VARCHAR2(25);
  l_last_receipt_date		DATE;

  l_employee_name		AP_WEB_DB_HR_INT_PKG.empCurrent_fullName := 'McKee, Mr. David (Dave)';
  l_employee_num		AP_WEB_DB_HR_INT_PKG.empCurrent_empNum := 100;
  l_default_cost_center		VARCHAR2(80);
  current_calling_sequence      VARCHAR2(2000);
  debug_info                    VARCHAR2(100);

  l_allow_overrider		VARCHAR2(1) := 'N';
  l_require_overrider		VARCHAR2(1) := 'N';
  l_overrider_CC		VARCHAR2(1) := 'N';
  l_date_format			VARCHAR2(30);
  -- For displaying error table
  l_cs_error			varchar2(500) := '';
  l_ap_error			varchar2(500) := '';

  l_IsMobileApp boolean;

  -- For bug fix 1865355
  l_exp_reimb_curr_profile      VARCHAR2(1);
  l_apsys_info_rec	        AP_WEB_DB_AP_INT_PKG.APSysInfoRec;
  l_base_currency               AP_SYSTEM_PARAMETERS.base_currency_code%TYPE;
  l_vendor_id                   NUMBER;
  l_vend_pay_curr               VARCHAR2(15);
  l_vend_pay_curr_name          FND_CURRENCIES_VL.name%TYPE;
  l_default_reimb_curr          FND_CURRENCIES_VL.currency_code%TYPE;

BEGIN

  l_IsMobileApp := AP_WEB_UTILITIES_PKG.IsMobileApp;


  -- Get date mask
  --Bug 3336823
  l_date_format := nvl(icx_sec.g_date_format,icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT'));

  -- Update the calling sequence
  --
  IF (NOT AP_WEB_DB_UTIL_PKG.GetFormattedSysDate(l_date_format, l_last_receipt)) THEN
	NULL;
  END IF;

  current_calling_sequence := 'AP_WEB_VALIDATE_UTIL.ValidateReportHeader';
  -- Validate Approver Name
  -- If override approver name is provided and no approver id
  -- exists (non-wizard validated) then validate.
  -- Overriding approver cannot be the submitting employee
  --
   debug_info := 'Validate Override Approver';

   -- Bug 3525089 : Setting up l_allow_overrider, so that if p_bFull_Approver_Validation = false
   -- then ValidateApprover gets called
   l_allow_overrider := AP_WEB_UTILITIES_PKG.value_specific(
			p_name	  => 'AP_WEB_ALLOW_OVERRIDE_APPROVER',
			p_user_id => p_user_id,
			p_resp_id => null,
			p_apps_id => null);

   IF (p_bFull_Approver_Validation) THEN

     l_overrider_CC := AP_WEB_UTILITIES_PKG.value_specific(
				p_name    => 'AP_WEB_APPROVER_REQ_CC',
				p_user_id => p_user_id,
				p_resp_id => null,
				p_apps_id => null);

     IF ( l_allow_overrider = 'Y' ) THEN
	-- get the default cost center of the filer:
	AP_WEB_UTILITIES_PKG.GetEmployeeInfo(
				l_employee_name,
				l_employee_num,
				l_default_cost_center,
				ExpReportHeaderInfo.employee_id );

	l_require_overrider := AP_WEB_UTILITIES_PKG.value_specific(
				p_name    => 'AP_WEB_OVERRIDE_APPR_REQ',
				p_user_id => p_user_id,
				p_resp_id => null,
				p_apps_id => null );

        IF ( l_require_overrider = 'Y' OR  l_require_overrider = 'D') THEN
		IF ( ExpReportHeaderInfo.override_approver_name IS NULL ) THEN
			fnd_message.set_name('SQLAP', 'AP_WEB_OVERRIDER_REQUIRED');
	      		AP_WEB_UTILITIES_PKG.AddExpError(p_error,
				       fnd_message.get_encoded(),
			 	       AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                                       null,
                                       0,
                                       AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
		ELSE
			ValidateApprover(
				ExpReportHeaderInfo.employee_id,
				ExpReportHeaderInfo.override_approver_name,
				ExpReportHeaderInfo.override_approver_id,
				l_ap_error );
			IF ( l_ap_error IS NOT NULL ) THEN
				AP_WEB_UTILITIES_PKG.AddExpError(
						p_error,
						l_ap_error,
						AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
						'AP_WEB_FULLNAME',
                                                0,
                                                AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
			END IF;

		END IF;
	ELSIF (l_require_overrider = 'N' AND ExpReportHeaderInfo.override_approver_name IS NOT NULL) THEN
		ValidateApprover(
			ExpReportHeaderInfo.employee_id,
			ExpReportHeaderInfo.override_approver_name,
			ExpReportHeaderInfo.override_approver_id,
			l_ap_error );

		IF ( l_ap_error IS NOT NULL ) THEN
			AP_WEB_UTILITIES_PKG.AddExpError(
				p_error,
				l_ap_error,
				AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
				'AP_WEB_FULLNAME',
                                0,
                                AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
		END IF;
	ELSIF ( l_overrider_CC = 'Y' AND ExpReportHeaderInfo.cost_center <> l_default_cost_center ) THEN
		IF ( ExpReportHeaderInfo.override_approver_name IS NULL ) THEN
			fnd_message.set_name('SQLAP','AP_WEB_DISCON_OVERRIDER_CC');
          		AP_WEB_UTILITIES_PKG.AddExpError(
					p_error,
				       	fnd_message.get_encoded(),
			 	       	AP_WEB_UTILITIES_PKG.C_ErrorMessageType ,
                                        null,
                                        0,
                                        AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
		ELSE
			ValidateApprover(
				ExpReportHeaderInfo.employee_id,
				ExpReportHeaderInfo.override_approver_name,
				ExpReportHeaderInfo.override_approver_id,
				l_ap_error );

			IF ( l_ap_error IS NOT NULL ) THEN
				AP_WEB_UTILITIES_PKG.AddExpError(
					p_error,
					l_ap_error,
					AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
					'AP_WEB_FULLNAME',
                                        0,
                                        AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
			END IF;
		END IF;
	END IF;
     END IF;
   ELSE

     IF ( l_allow_overrider = 'Y' ) THEN
	IF ( ExpReportHeaderInfo.override_approver_name IS NOT NULL ) THEN
	  ValidateApprover(
		ExpReportHeaderInfo.employee_id,
		ExpReportHeaderInfo.override_approver_name,
		ExpReportHeaderInfo.override_approver_id,
		l_ap_error );

	  IF ( l_ap_error IS NOT NULL ) THEN
		AP_WEB_UTILITIES_PKG.AddExpError(
			p_error,
			l_ap_error,
			AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
			'AP_WEB_FULLNAME',
                        0,
                        AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
	  END IF;
	END IF;
     END IF;
  END IF;
  -- Validate Cost Center
  debug_info := 'Validate Cost Center';
  IF ( ExpReportHeaderInfo.cost_center IS NULL ) THEN
        if (not l_IsMobileApp) then
	  fnd_message.set_name( 'SQLAP', 'AP_WEB_COST_CENTER_INVALID' );
        else
	  fnd_message.set_name( 'SQLAP', 'AP_OME_COST_CENTER_ERROR' );
        end if;
	AP_WEB_UTILITIES_PKG.AddExpError(
				p_error,
				fnd_message.get_encoded(),
				AP_WEB_UTILITIES_PKG.C_errorMessageType,
				'txtCostCenter',
                                0,
                                AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
  ELSE
  	AP_WEB_VALIDATE_UTIL.ValidateCostCenter(
			ExpReportHeaderInfo.cost_center,
		       	l_cs_error,
                        ExpReportHeaderInfo.employee_id );

	IF ( l_cs_error IS NOT NULL ) THEN
		AP_WEB_UTILITIES_PKG.AddExpError(
					p_error,
					l_cs_error,
					AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
					'txtCostCenter',
                                        0,
                                        AP_WEB_UTILITIES_PKG.C_OtherMessageCategory,
					l_IsMobileApp);
	END IF;
  END IF;


  debug_info := 'Validate Expense Template';
  BEGIN
    -- Fix bug 1472710, removed initcap for ExpReportHeaderInfo.template_name
    IF (NOT AP_WEB_DB_EXPTEMPLATE_PKG.GetExpTemplateId(
				ExpReportHeaderInfo.template_name,
				ExpReportHeaderInfo.template_id)) THEN
	ExpReportHeaderInfo.template_id := NULL;
	ExpReportHeaderInfo.template_name := NULL;
	raise NO_DATA_FOUND;
    END IF;

  EXCEPTION
    when OTHERS then
      fnd_message.set_name('SQLAP', 'AP_WEB_DISCON_TEMP_INVALID');
      AP_WEB_UTILITIES_PKG.AddExpError(p_error,
					fnd_message.get_encoded(),
					AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
					'TEMPLATE',
                                        0,
                                        AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
  END;

  -- Validate Last Receipt Date
  debug_info := 'Validating Last Receipt Date';
  BEGIN
    debug_info := 'Store Last Receipt date string into the date format';
    l_last_receipt_date := to_date(l_last_receipt, l_date_format);
    IF (ExpReportHeaderInfo.last_receipt_date IS NOT NULL) THEN
      IF (l_last_receipt_date < to_date(ExpReportHeaderInfo.last_receipt_date, l_date_format)) THEN
      	l_last_receipt_date := ExpReportHeaderInfo.last_receipt_date;
      END IF;
    END IF;
  EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME( 'SQLAP','AP_WEB_LAST_RECDATE_INVALID' );
		AP_WEB_UTILITIES_PKG.AddExpError(
					p_error,
					fnd_message.get_encoded(),
					AP_WEB_UTILITIES_PKG.C_errorMessageType,
					'popEmployeeID',
                                        0,
                                        AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);

  END;

  -- For bug fix 1865355
  -- Validate reimbursement currency
  l_exp_reimb_curr_profile := AP_WEB_UTILITIES_PKG.VALUE_SPECIFIC(
				p_name    => 'AP_WEB_ALLOW_NON_BASE_REIMB',
				p_user_id => p_user_id,
				p_resp_id => null,
				p_apps_id => null);
  IF ( nvl(l_exp_reimb_curr_profile,'Y') = 'N' ) THEN
     IF ( NOT AP_WEB_DB_AP_INT_PKG.GetVendorInfoOfEmp(ExpReportHeaderInfo.employee_id,
             l_vendor_id,l_vend_pay_curr,l_vend_pay_curr_name) ) THEN
 	 NULL;
     END IF;

     IF ( AP_WEB_DB_AP_INT_PKG.GetAPSysCurrencySetupInfo(l_apsys_info_rec) = TRUE ) THEN
         l_base_currency := l_apsys_info_rec.base_currency;
     END IF;

     l_default_reimb_curr := nvl(l_vend_pay_curr, l_base_currency);
     IF ( ExpReportHeaderInfo.reimbursement_currency_code <> l_default_reimb_curr ) THEN
        ExpReportHeaderInfo.reimbursement_currency_code := l_default_reimb_curr;
        FND_MESSAGE.SET_NAME('SQLAP', 'OIE_INVALID_REIMB_CURR');
        FND_MESSAGE.SET_TOKEN('FUNCTIONAL_CURRENCY',l_default_reimb_curr);
        AP_WEB_UTILITIES_PKG.AddExpError(p_error,
                    fnd_message.get_encoded(),
                    AP_WEB_UTILITIES_PKG.C_ErrorMessageType);
     END IF;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      -- JMARY have to handle this error for NEWUI
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     current_calling_sequence);

        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);

        APP_EXCEPTION.RAISE_EXCEPTION;
      END;
END ValidateHeaderNoValidSession;

/*----------------------------------------------------------------------------*
 | Procedure                                                                  |
 |      ValidateExpLineCustomFields                                           |
 |                                                                            |
 | DESCRIPTION                                                                |
 |	Server-Side validation for single receipt line custom fields	      |
 |									      |
 | ASSUMPTION								      |
 |	p_report_header_info.number_max_flexfield has been set		      |
 |									      |
 | PARAMETERS                                                                 |
 |                                                                            |
 | RETURNS                                                                    |
 |     none                                                                   |
 *----------------------------------------------------------------------------*/
PROCEDURE ValidateExpLineCustomFields(
    	p_userId		      	        IN 	NUMBER,
        p_report_header_info  IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
        p_report_line_info    IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportLineRec,
	p_receipt_index	      IN INTEGER, -- for AddExpError
	p_SysInfoRec	      IN AP_WEB_DB_AP_INT_PKG.APSysInfoRec,
	p_DefaultExchangeRate IN NUMBER,
	p_EndExpenseDate      IN DATE,
	p_DateFormat	      IN VARCHAR2,
        p_custom1_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom2_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom3_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom4_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom5_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom6_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom7_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom8_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom9_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom10_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom11_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom12_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom13_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom14_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom15_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        P_IsSessionTaxEnabled IN VARCHAR2,
        P_IsSessionProjectEnabled IN VARCHAR2,
	p_receipt_errors      IN OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack,
	p_calculate_receipt_index     IN BINARY_INTEGER,
        p_errors               IN OUT NOCOPY  AP_WEB_UTILITIES_PKG.expError,
	p_receipts_with_errors_count  IN OUT NOCOPY BINARY_INTEGER,
	p_DataDefaultedUpdateable     IN OUT NOCOPY BOOLEAN,
	p_bCalling_from_disconnected  IN BOOLEAN,
	p_bForBlueGray		      IN BOOLEAN default FALSE,
        p_addon_rates                 IN OIE_ADDON_RATES_T DEFAULT NULL,
        p_report_line_id              IN NUMBER DEFAULT NULL,
        p_daily_breakup_id              IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_start_date                    IN      OIE_PDM_DATE_T DEFAULT NULL,
        p_end_date                      IN      OIE_PDM_DATE_T DEFAULT NULL,
        p_amount                        IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_number_of_meals               IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_meals_amount                  IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_breakfast_flag                IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
        p_lunch_flag                    IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
        p_dinner_flag                   IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
        p_accommodation_amount          IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_accommodation_flag            IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
        p_hotel_name                    IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL,
        p_night_rate_Type               IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL,
        p_night_rate_amount             IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_pdm_rate                      IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_rate_Type_code                IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL,
        p_pdm_breakup_dest_id           IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_pdm_destination_id            IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_dest_start_date               IN      OIE_PDM_DATE_T DEFAULT NULL,
        p_dest_end_date                 IN      OIE_PDM_DATE_T DEFAULT NULL,
        p_location_id                   IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_cust_meals_amount             IN OUT  NOCOPY OIE_PDM_NUMBER_T,
        p_cust_accommodation_amount     IN OUT  NOCOPY OIE_PDM_NUMBER_T,
        p_cust_night_rate_amount        IN OUT  NOCOPY OIE_PDM_NUMBER_T,
        p_cust_pdm_rate                 IN OUT  NOCOPY OIE_PDM_NUMBER_T
)
----------------------------------------------------------------------------
IS

  l_receipt_custom_fields_array  AP_WEB_DFLEX_PKG.CustomFields_A;

  l_curr_calling_sequence      VARCHAR2(200) := 'ValidateExpLinesCustomFields';
  l_debug_info		       VARCHAR2(2000);

  i                            INTEGER;
  AttributeCol_Array           AP_WEB_PARENT_PKG.BigString_Array;

  V_Field1                     NUMBER;
  V_Field2                     NUMBER;

  V_AcctRawCost                NUMBER;         -- For PATC: Raw cost in functional currency

  l_error1			AP_WEB_UTILITIES_PKG.expError;
  l_error2			AP_WEB_UTILITIES_PKG.expError;
  l_invRate			VARCHAR2(1) := 'N';
  l_calc_amt_enabled_for_disc   BOOLEAN := FALSE;

  V_EnteredByUserID		VARCHAR2(100);

  l_IsMobileApp boolean;

  l_report_lines_array   	AP_WEB_DFLEX_PKG.ExpReportLines_A;

  V_GrantsResult                 VARCHAR2(2000); -- For Grants: Error/warning message

  l_CostCenterErrorMsg          VARCHAR2(2000) := NULL;

BEGIN

  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', 'start ValidateExpLineCustomFields');
  l_IsMobileApp := AP_WEB_UTILITIES_PKG.IsMobileApp;


    -- Validate descriptive flexfields and call custom validation hook for both
    -- core and descriptive flexfields
    l_debug_info := 'Validate desc flexfields and custom validation hook';
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', l_debug_info);
    IF p_report_header_info.number_max_flexfield > 0 THEN

      -- validate only if an expense type is specified
      IF p_report_line_info.parameter_id IS NOT NULL THEN

       -----------------------------------------------------
       l_debug_info := 'GetReceiptCustomFields';
       AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', l_debug_info);
       -----------------------------------------------------

       AP_WEB_DFLEX_PKG.GetReceiptCustomFields(l_receipt_custom_fields_array,
  					     p_receipt_index,
  					     p_custom1_array,
  					     p_custom2_array,
  					     p_custom3_array,
  					     p_custom4_array,
  					     p_custom5_array,
  					     p_custom6_array,
  					     p_custom7_array,
  					     p_custom8_array,
  					     p_custom9_array,
  					     p_custom10_array,
  					     p_custom11_array,
  					     p_custom12_array,
  					     p_custom13_array,
  					     p_custom14_array,
  					     p_custom15_array);

       -----------------------------------------------------
       l_debug_info := 'ValidateReceiptCustomFields';
       AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', l_debug_info);
       -----------------------------------------------------
       AP_WEB_DFLEX_PKG.ValidateReceiptCustomFields(p_userId,
                                 p_report_header_info,
  				 p_report_line_info,
  				 l_receipt_custom_fields_array,
  				 p_receipt_errors,
  				 p_receipt_index,
				 l_error1);
      --chiho:1346208:
      p_receipts_with_errors_count := p_receipts_with_errors_count + l_error1.COUNT;

      -- Call custom validation hook for both core and pseudo descriptive flexfields
      l_debug_info := 'Call custom validation hook for both core and pseudo descriptive flexfields';
      AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', l_debug_info);
      AP_WEB_CUST_DFLEX_PKG.CustomValidateLine(p_report_header_info,
                         p_report_line_info,
                         l_receipt_custom_fields_array,
                         l_error2);

       -----------------------------------------------------
       l_debug_info := 'PropogateReceiptCustFldsInfo';
       AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', l_debug_info);
       -----------------------------------------------------
       AP_WEB_DFLEX_PKG.PropogateReceiptCustFldsInfo(
  					     l_receipt_custom_fields_array,
  					     p_receipt_index,
  					     p_custom1_array,
  					     p_custom2_array,
  					     p_custom3_array,
  					     p_custom4_array,
  					     p_custom5_array,
  					     p_custom6_array,
  					     p_custom7_array,
  					     p_custom8_array,
  					     p_custom9_array,
  					     p_custom10_array,
  					     p_custom11_array,
  					     p_custom12_array,
  					     p_custom13_array,
  					     p_custom14_array,
  					     p_custom15_array);

      END IF; -- (p_report_line_info.parameter_id IS NOT NULL)
    ELSE -- (p_report_header_info.number_max_flexfield > 0)

      -- Call custom validation hook for both core and pseudo descriptive flexfields
      l_debug_info := 'Call custom validation hook';
      -- Bug: 6617094, Expense type is null in Custom Validation.
      AP_WEB_DFLEX_PKG.PopulateExpTypeInLineRec(p_report_line_info);
      AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', l_debug_info);
      AP_WEB_CUST_DFLEX_PKG.CustomValidateLine(p_report_header_info,
                         p_report_line_info,
                         l_receipt_custom_fields_array,
                         l_error2);

    END IF;  -- (p_report_header_info.number_max_flexfield > 0)

    IF p_bCalling_from_disconnected THEN
      l_calc_amt_enabled_for_disc := AP_WEB_DB_EXPTEMPLATE_PKG.IsCustomCalculateEnabled(
			 	p_report_header_info.template_id,
				p_report_line_info.parameter_id);

    END IF;

    IF (p_receipts_with_errors_count = 0) THEN

      /* If calculate amount is being called from online entry, then
         p_calculate_receipt_index is not null. If we are uploading
         the spreadsheet, p_calculate_receipt_index is null and we need
         to call customcalculateamount if calculate amount is enabled for
         this expense type. */
      IF ((p_calculate_receipt_index IS NOT NULL) OR (l_calc_amt_enabled_for_disc)) THEN

        AP_WEB_CUST_DFLEX_PKG.CustomCalculateAmount(
			p_report_header_info,
			p_report_line_info,
			l_receipt_custom_fields_array,
                         p_addon_rates,
                         p_report_line_id,
                         p_daily_breakup_id,
                         p_start_date,
                         p_end_date,
                         p_amount,
                         p_number_of_meals,
                         p_meals_amount,
                         p_breakfast_flag,
                         p_lunch_flag,
                         p_dinner_flag,
                         p_accommodation_amount,
                         p_accommodation_flag,
                         p_hotel_name,
                         p_night_rate_Type,
                         p_night_rate_amount,
                         p_pdm_rate,
                         p_rate_Type_code,
                         p_pdm_breakup_dest_id,
                         p_pdm_destination_id,
                         p_dest_start_date,
                         p_dest_end_date,
                         p_location_id,
                         p_cust_meals_amount,
                         p_cust_accommodation_amount,
                         p_cust_night_rate_amount,
                         p_cust_pdm_rate
                         );

      END IF;

      IF (l_calc_amt_enabled_for_disc) THEN

        ----------------------------------------------
        l_debug_info := 'Propagate calculated amount';
        ----------------------------------------------
        IF (to_number(substr(p_report_line_info.receipt_amount,1,80)) <>
	     to_number(substr(p_report_line_info.calculated_amount,1,80)))THEN
          p_report_line_info.receipt_amount := p_report_line_info.calculated_amount;
          ----------------------------------------------
          l_debug_info := 'Set Datadefaulted to true';
          ----------------------------------------------
          p_DataDefaultedUpdateable := TRUE;
        ELSE
          p_DataDefaultedUpdateable := FALSE;

        END IF;

        ----------------------------------------------
        l_debug_info := 'Recalculate Daily Amount';
        ----------------------------------------------
        p_report_line_info.daily_amount := NULL;

        ----------------------------------------------
        l_debug_info := 'Recalculate Amount';
        ----------------------------------------------
        l_invRate := AP_WEB_UTILITIES_PKG.VALUE_SPECIFIC(
			p_name    => 'DISPLAY_INVERSE_RATE',
			p_user_id => p_userId,
			p_resp_id => null,
			p_apps_id => null);

        IF (l_invRate = 'N') THEN
          p_report_line_info.amount := p_report_line_info.receipt_amount * p_report_line_info.rate;
        ELSE
          p_report_line_info.amount := p_report_line_info.receipt_amount / p_report_line_info.rate;
        END IF;


        ----------------------------------------------
        l_debug_info := 'Revalidate new values';
        ----------------------------------------------
        AP_WEB_DFLEX_PKG.ValidateReceiptCustomFields(p_userId,
                                 p_report_header_info,
  				 p_report_line_info,
  				 l_receipt_custom_fields_array,
  				 p_receipt_errors,
  				 p_receipt_index,
				 l_error1);
      END IF;

    END IF;


--chiho:1346208:
    AP_WEB_UTILITIES_PKG.MergeExpErrors( p_errors, l_error1 );

    AP_WEB_UTILITIES_PKG.MergeExpErrors(p_errors, l_error2);

EXCEPTION
  WHEN OTHERS THEN
    BEGIN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     'ValidateExpLineCustomFields');
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'None passed.');
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END;
END ValidateExpLineCustomFields;


/*----------------------------------------------------------------------------*
 | Procedure                                                                  |
 |      ValidateExpLineCoreFields                                             |
 |                                                                            |
 | DESCRIPTION                                                                |
 |	Server-Side validation for single receipt line core fields            |
 |									      |
 | ASSUMPTION								      |
 |									      |
 | PARAMETERS                                                                 |
 |                                                                            |
 | RETURNS                                                                    |
 |     none                                                                   |
 *----------------------------------------------------------------------------*/
PROCEDURE ValidateExpLineCoreFields
	(p_user_id              IN NUMBER, -- 2242176, fnd user id
        p_report_header_info 	IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
        p_report_line_info  	IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportLineRec,
	p_receiptcount 		IN NUMBER,
	p_allow_credit_lines	IN BOOLEAN,
	p_justreq_array		IN AP_WEB_PARENT_PKG.Number_Array,
	p_reimbcurr_precision	IN FND_CURRENCIES_VL.PRECISION%TYPE,
	p_calculate_receipt_index  IN BINARY_INTEGER,
	p_exp_error		IN OUT NOCOPY AP_WEB_UTILITIES_PKG.expError)
-----------------------------------------------------------------------------
IS

/* Note: p_receipt_errors might not be empty --  Validation in disconnected
might have filled in something.
-Try to validate the receipt attributes in the same order as they'll appear
in View Receipts table.
-If the function is called from disconnected, since we don't support multi-curr
initially, some of the arrays are just empty ones.  So need to check if the
array size is zero before proceeding to avoid an exception.
*/

  l_DATE1_temp 		DATE;
  l_dates_ok 		BOOLEAN := true;
  l_date2_temp 		DATE;
  l_dailyAmount 	NUMBER;
  l_receiptAmount 	NUMBER;
  l_num 		NUMBER;
  l_orig_num 		NUMBER;  --added for bug 1056403
  l_rate 		NUMBER;
  l_rate_string 	VARCHAR2(15);
  l_amount 		NUMBER;
  l_sdate 		DATE := sysdate;
  l_edate 		DATE;
  l_acdate 		DATE; -- date1 if date2 is null, otherwise date2.
  l_receipt_custom_fields_array		AP_WEB_DFLEX_PKG.CustomFields_A;
  l_reimbcurr_format 	VARCHAR2(80);
  l_reccurr_format 	VARCHAR2(80);
  l_date_format 	VARCHAR2(30);
  i 			NUMBER;
  debug_info 		VARCHAR2(100) := '';
  l_inverse_rate_profile	VARCHAR2(1);

  l_is_fixed_rate 	VARCHAR2(1);
  l_fixed_rate_applied 	VARCHAR2(1) := 'N';
  l_fixed_msg 		VARCHAR2(2000);
  l_cal_amount_method   VARCHAR2(1) := '*';  --added for bug 1056403
  l_time_based_entry_flag varchar2(1);  -- Bug 6392916 (sodash)
  l_IsMobileApp boolean;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_VALIDATE_UTIL', 'start ValidateExpLineCoreFields');
  l_IsMobileApp := AP_WEB_UTILITIES_PKG.IsMobileApp;

  FND_MESSAGE.SET_NAME('SQLAP','AP_WEB_FIXED');
  l_fixed_msg :=  AP_WEB_DB_UTIL_PKG.jsPrepString(fnd_message.get_encoded(), TRUE);

  l_reimbcurr_format := FND_CURRENCY.get_format_mask(p_report_header_info.reimbursement_currency_code, 30);

  if (p_report_header_info.transaction_currency_type = 'reimbursement') then
    l_reccurr_format := l_reimbcurr_format;
  end if;

  --Bug 3336823
  l_date_format := nvl(icx_sec.g_date_format,icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT'));


  l_inverse_rate_profile := AP_WEB_UTILITIES_PKG.VALUE_SPECIFIC(
				p_name    => 'DISPLAY_INVERSE_RATE',
				p_user_id => p_user_id,
				p_resp_id => null,
				p_apps_id => null);

      l_fixed_rate_applied := 'N';

      debug_info:='checking trans';
      AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', debug_info);
      l_dates_ok := true;
      if (p_report_header_info.transaction_currency_type = 'multi') then
        l_reccurr_format :=
	  FND_CURRENCY.get_format_mask(p_report_line_info.currency_code, 30);
      end if;
      --
      -- Check if Valid Start Date was entered
      --
    debug_info:='Check Start Date';
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', debug_info);
    if (p_report_line_info.start_date is null) then
      l_dates_ok := false;
      fnd_message.set_name('SQLAP', 'AP_WEB_ST_DATE_FIRST');
      AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
	fnd_message.get_encoded(),
        AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
        C_Date1_Prompt,
        p_receiptcount,
        AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
    else
      BEGIN
        --Bug 6054643: Removing the to_date conversion
        l_date1_temp := trunc(p_report_line_info.start_date);

        -- Check whether year is Valid
        if (NOT IsValidYear(l_date1_temp) AND  (p_report_line_info.category_code <> 'PER_DIEM') )THEN
          l_dates_ok := false;
          fnd_message.set_name('SQLAP', 'OIE_INVALID_YEAR');
          fnd_message.set_token('MINIMUM_YEAR', to_char(C_MinimumYear));
          AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
	    fnd_message.get_encoded(),
            AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
            C_Date1_Prompt,
            p_receiptcount,
            AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
        end if;

	l_acdate := l_date1_temp;

	if (l_edate is null) then
	  l_edate := l_date1_temp;
	end if;
	if (l_date1_temp < l_sdate) then
	  l_sdate := l_date1_temp;
	elsif (l_date1_temp > l_edate) then
	  l_edate := l_date1_temp;
	end if;
      EXCEPTION
        when OTHERS then
	  l_dates_ok := false;
          FND_MESSAGE.SET_NAME('SQLAP', 'AP_WEB_START_DATE_INVALID');
          FND_MESSAGE.SET_TOKEN('START_DATE', p_report_line_info.start_date);
          FND_MESSAGE.SET_TOKEN('PROPER_FORMAT', to_char(sysdate, l_date_format));
          AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
  	    fnd_message.get_encoded(),
            AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
            C_Date1_Prompt,
            p_receiptcount,
            AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);

       END;
     end if; /* date 1 is null */

      --
      -- Check if Valid End Date was entered
      --
      debug_info := 'Check End Date';
      AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', debug_info);
      BEGIN
        --Bug 6054643: Removing the to_date conversion
        l_date2_temp := trunc(nvl(p_report_line_info.end_date, l_date1_temp));

        -- Check whether year is Valid

/*Bug 2292854: Raise End Date invalid error only if expense category
	       code is PER_DIEM. Dont raise for Receipt based and Mileage.
*/
	IF (p_report_line_info.category_code = 'PER_DIEM') THEN
	  -- Bug 6392916 (sodash)
	  -- Checking whether the start date is valid
	  if (NOT IsValidYear(l_date1_temp)) THEN
                l_dates_ok := false;
                fnd_message.set_name('SQLAP', 'OIE_INVALID_YEAR_START_DATE');
                fnd_message.set_token('MINIMUM_YEAR', to_char(C_MinimumYear));
  	        AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
  	        fnd_message.get_encoded(),
                AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                C_Date1_Prompt,
                p_receiptcount,
               AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
          end if;
          -- Bug 6392916 (sodash)
	  -- Checking whether entering the end date is compulsory for the Per Diem Schedule
	  select TIME_BASED_ENTRY_FLAG into l_time_based_entry_flag from AP_POL_HEADERS aph, AP_EXPENSE_REPORT_PARAMS_ALL param where aph.POLICY_ID = param.COMPANY_POLICY_ID and param.PARAMETER_ID = p_report_line_info.parameter_id;
          if (l_time_based_entry_flag='Y' AND
	      p_report_line_info.end_date IS NOT NULL AND
              NOT IsValidYear(l_date2_temp)) THEN
                     l_dates_ok := false;
                     fnd_message.set_name('SQLAP', 'OIE_INVALID_YEAR_END_DATE');
                     fnd_message.set_token('MINIMUM_YEAR', to_char(C_MinimumYear));
                     AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
	            fnd_message.get_encoded(),
                    AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                    C_Date2_Prompt,
                    p_receiptcount,
                    AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
          end if;
	END IF;

	l_acdate := l_date2_temp;
	if (l_date2_temp > l_edate) then
	  l_edate := l_date2_temp;
	elsif (l_date2_temp < l_sdate) then
	  l_sdate := l_date2_temp;
	end if;
      EXCEPTION
        when OTHERS then
	  l_dates_ok := false;
          FND_MESSAGE.SET_NAME('SQLAP', 'AP_WEB_END_DATE_INVALID');
          FND_MESSAGE.SET_TOKEN('END_DATE', p_report_line_info.end_date);
          FND_MESSAGE.SET_TOKEN('PROPER_FORMAT', to_char(sysdate, l_date_format));
          AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
 	    fnd_message.get_encoded(),
            AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
            C_Date2_Prompt,
            p_receiptcount,
            AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
      END;

      --
      -- Check if End Date falls on or after Start Date
      -- Only do it when both dates' format is fine.
      --
     debug_info:= 'Day1 < Day2?';
     AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', debug_info);
     if (l_dates_ok) then
      if (l_date1_temp > nvl(l_date2_temp, l_date1_temp)) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_WEB_START_AFTER_END');
        FND_MESSAGE.SET_TOKEN('START_DATE', p_report_line_info.start_date);
        FND_MESSAGE.SET_TOKEN('END_DATE', p_report_line_info.end_date);
        AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
  	    fnd_message.get_encoded(),
            AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
            C_Date2_Prompt,
            p_receiptcount,
            AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
        end if;
     end if;

      --
      -- Check if Days is a valid number. And if days entered equals to
      -- actual different between the two dates.
      --
      debug_info := 'Check days';
      AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', debug_info);
      BEGIN
        l_num := to_number(p_report_line_info.days);
        if (l_dates_ok) then
	  if (p_report_line_info.days is null) then
            if (p_report_line_info.end_date is null) then
	       -- bug 2190588: raise exception since we are not able to
	       -- calcualte the date range. This case should only happen
	       -- when upload spreadsheet
	       APP_EXCEPTION.RAISE_EXCEPTION;
	    else
	      /* Calculate the date range */
	      p_report_line_info.days :=
		to_char(l_date2_temp - l_date1_temp + 1);
            end if;

          -- Raise exception if number is not an integer or less than 1
          elsif (l_num < 1 OR floor(l_num) <> ceil(l_num)) then
            APP_EXCEPTION.RAISE_EXCEPTION;

          -- If no end date is given, obtain the end date
          -- by adding days to the start date
          -- Only check the range if both start and end date are given. Bug 1865586
          elsif (to_date(p_report_line_info.end_date, l_date_format) IS NULL) then
            l_date2_temp := l_date1_temp + l_num - 1;
            p_report_line_info.end_date := l_date2_temp;

	  -- Take away due to request from IES. 8/1/97
          -- Undo the Take away above. Bug # 688566
	  -- We DO want to make sure the number of days matches with
	  -- the real range of dates.
          elsif ((l_date2_temp - l_date1_temp + 1) <> l_num)
	   then
  	    fnd_message.set_name('SQLAP', 'AP_WEB_WRONG_NUM_OF_DAYS');
            AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
  	      fnd_message.get_encoded(),
              AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
              C_Days_Prompt,
              p_receiptcount,
              AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
  	  end if;
	end if; /* l_dates_ok */
      EXCEPTION
        when OTHERS then
          FND_MESSAGE.SET_NAME('SQLAP', 'AP_WEB_DAYS_INVALID');
          AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
  	      fnd_message.get_encoded(),
              AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
              C_Days_Prompt,
              p_receiptcount,
              AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
      END;

     debug_info := 'Check if the fields exist in the receipts array';
     AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', debug_info);

      --
      -- Check if Daily Amount is a valid number.
      --
     debug_info := 'Daily Amount';
     AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', debug_info);
     l_dailyAmount := null; -- initialize it since it will be used later!
     if (p_report_line_info.daily_amount IS NOT NULL) then
      BEGIN
        l_dailyAmount := AP_WEB_DB_UTIL_PKG.CharToNumber(p_report_line_info.daily_amount);
	if CheckNum(l_dailyAmount, p_exp_error, p_receiptcount,
		    C_DAmount_Prompt, p_allow_credit_lines, FALSE) then
	  -- p_report_line_info.daily_amount := to_char(l_num);
	  NULL;
	end if;
      EXCEPTION
        when OTHERS then
          FND_MESSAGE.SET_NAME('SQLAP', 'AP_WEB_DAILY_AMOUNT_INVALID');
          p_report_line_info.daily_amount := null;
          AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
  	      fnd_message.get_encoded(),
              AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
              C_DAmount_Prompt,
              p_receiptcount,
              AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);

      END;
     end if;

      --
      -- Check if Receipt Amount is a valid number.
      --
     debug_info := 'Check Receipt Amount';
     AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', debug_info);
     l_receiptAmount := null; -- initialize it since it will be used later
     BEGIN
       if (p_report_line_info.receipt_amount is not NULL) then
         l_receiptAmount := AP_WEB_DB_UTIL_PKG.CharToNumber(p_report_line_info.receipt_amount);
         if CheckNum(l_receiptAmount, p_exp_error, p_receiptcount,
		    C_RecAmt_Prompt, p_allow_credit_lines, FALSE) then
           --
           -- If l_dailyAmount and l_receiptAmount are both not null and zero then
           -- l_receiptAmount must be equal  l_dailyAmount * Days.
           BEGIN
	     if ((l_dailyAmount is not NULL) AND (l_dailyAmount <> 0)) then
               -- bug 2103589: we need to deal with difference due to formatting
               l_num := to_number(p_report_line_info.days);
               if (l_num = 1) then
  	           l_amount := l_receiptAmount;
               else
  	           l_amount := to_number(to_char(l_receiptAmount/l_num, l_reccurr_format));
               end if;

	       if ((l_receiptAmount <> 0) AND (NOT WithinTolerance(l_dailyAmount, l_amount))) then
                 FND_MESSAGE.SET_NAME('SQLAP', 'AP_WEB_RECEIPT_AMT_INCORRECT');
                 AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
                    fnd_message.get_encoded(),
                    AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                    C_RecAmt_Prompt,
                    p_receiptcount,
                    AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
	       elsif (l_receiptAmount = 0) then
                 if (l_dailyAmount <> 0) then -- dailyAmount is valid
		   -- Could have been pre-seeded to 0 in spreadsheet. Null it
		   -- out since don't want to mess with currency format.
		   p_report_line_info.receipt_amount := null;
		 end if;
	       end if;
	     end if;
	   EXCEPTION
	      WHEN OTHERS THEN
		-- Either DAmount or Days invalid. But both should have been
		-- reported earlier.
		NULL;
	   END; /* l_dailyAmount * Days equal to l_receiptAmount */

           --
           -- Check whether the receipt amount equals the rounded
           -- currency amount

           if (NOT WithinTolerance (l_receiptAmount,
                 AP_WEB_UTILITIES_PKG.OIE_ROUND_CURRENCY(l_receiptAmount,
                   p_report_line_info.currency_code))) then
             FND_MESSAGE.SET_NAME('SQLAP', 'OIE_CURRENCY_NO_DECIMALS');
             FND_MESSAGE.SET_TOKEN('RECEIPT_CURRENCY',
               p_report_line_info.currency_code);
             AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
                    fnd_message.get_encoded(),
                    AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                    C_RecAmt_Prompt,
                    p_receiptcount,
                    AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
           end if; /* Rounding */

	 end if; /* CheckNum */
       end if;
     EXCEPTION
        when OTHERS then
          FND_MESSAGE.SET_NAME('SQLAP', 'AP_WEB_RECEIPT_AMOUNT_INVALID');
          p_report_line_info.receipt_amount := null;
          AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
                    fnd_message.get_encoded(),
                    AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                    C_RecAmt_Prompt,
                    p_receiptcount,
                    AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);

     END;
-- chiho:bug#825307:extend the exception handling to include GL_CURRENCY_API.is_fixed_rate:
     BEGIN
      --
      -- Check if Rate is a valid number.
      --
     debug_info := 'Check rate';
     AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', debug_info);
     IF ((p_report_line_info.currency_code =
		p_report_header_info.reimbursement_currency_code) OR
	 (p_report_line_info.currency_code = 'OTHER')) THEN
	l_is_fixed_rate := 'N';
     ELSE
	-- This works around a GL is_fixed_rate bug. when disconnected
	-- upload has wrong date format, l_acdate is null. it shouldn't
	-- call is_fixed_rate to determine conversion.
	-- is_fixed_rate does not handle null date well.
        IF (l_acdate is NULL) THEN
	  l_is_fixed_rate := 'N';
	ELSE
     	  l_is_fixed_rate := GL_CURRENCY_API.is_fixed_rate(
			p_report_line_info.currency_code, p_report_header_info.reimbursement_currency_code, l_acdate);
	END IF;
     END IF;  -- IF (p_report_line_info.currency_code = p_report_header_info.reimbursement_currency_code)

     if (p_report_line_info.rate IS NOT NULL) then
	IF (l_is_fixed_rate = 'Y') THEN
	  l_num := 1;
	ELSE
          l_num := to_number(nvl(p_report_line_info.rate, '1'));
	END IF; -- IF (l_is_fixed_rate = 'Y')

	-- abosulte flag is set to true since rate should be > 0.
        -- **** USED TO BE CheckPosNum
	if not CheckNum(l_num, p_exp_error,
			p_receiptcount, C_Rate_Prompt, TRUE, TRUE) then
	  debug_info := 'rate is negative'; /* CheckPosNum is function */
      	  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', debug_info);
 	else
	  IF (l_is_fixed_rate = 'Y') THEN
	    p_report_line_info.rate:= '1'; -- Bug 1871739. Use '1' instead of l_fixed_msg
	  ELSE
            p_report_line_info.rate:=ltrim(to_char(l_num));
	  END IF;
	  -- get rid of trailing zeros, and if last char is a decimal then get
	  -- rid of it
    	  IF INSTRB(p_report_line_info.rate,'.') <> 0 THEN
            p_report_line_info.rate := RTRIM(p_report_line_info.rate,'0');
            p_report_line_info.rate := RTRIM(p_report_line_info.rate,'.');
          END IF;

	  --
          -- if RecCurr = p_report_header_info.reimbursement_currency_code, and rate <> 1, it's an error.
	  --
	  if (nvl(p_report_line_info.currency_code, p_report_header_info.reimbursement_currency_code) = p_report_header_info.reimbursement_currency_code) then
 	    if ((l_num <> 1) or (l_num <> null)) then
	      FND_MESSAGE.SET_NAME('SQLAP', 'AP_WEB_SAMECURR_RATE');
              AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
                    fnd_message.get_encoded(),
                    AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                    C_Rate_Prompt,
                   p_receiptcount,
                   AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
              -- Default rate to '1' since currency is not foreign.
              -- and adjust reimbursable amount
              p_report_line_info.rate:= '1'; -- Bug 2177344
              p_report_line_info.amount := p_report_line_info.receipt_amount;
	    end if;
	  end if;
	end if; /* CheckNum */
      end if; /* if l_rate_exists */

   EXCEPTION
        when OTHERS then
          FND_MESSAGE.SET_NAME('SQLAP', 'AP_WEB_RATE_INVALID');
          p_report_line_info.rate := null;
          AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
                    fnd_message.get_encoded(),
                    AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                    C_Rate_Prompt,
                   p_receiptcount,
                   AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
   END;

      --
      -- Check if (Total) Amount is a valid number.
      --
     debug_info := 'Amount';
     AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', debug_info);
     -- Only do this check in non "Calculate Amount" custom field calculation
     -- case.

     if (NOT(p_calculate_receipt_index > 0) OR
	     (p_calculate_receipt_index is NULL)) then
	-- First calculate what we would get from the daily amount, days,
	-- receipt amount and rate info that we have so far.

    	BEGIN
          -- Bug 2103589: since the receipt amt is already validated above, we just use it
	  if ((l_receiptAmount is not null) AND (l_receiptAmount <> 0)) then
	    l_num := l_receiptAmount;
	  elsif ((l_dailyAmount is not null) AND (l_dailyAmount <> 0)) then
	    l_num := l_dailyAmount * to_number(p_report_line_info.days);
	  else
	    l_num := null;
	  end if;

          if (p_report_line_info.rate <> l_fixed_msg) THEN
	    l_rate := to_number(nvl(p_report_line_info.rate, '1'));
          ELSE
	    l_rate := 1;
	  END IF;

	  if ((l_rate > 0) AND (l_num is not null)) then
	    debug_info := 'before calc l_amount';
      	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', debug_info);
	    IF (l_is_fixed_rate = 'Y') THEN
	      l_amount := GL_CURRENCY_API.convert_amount(
				p_report_line_info.currency_code,
				p_report_header_info.reimbursement_currency_code,
				l_acdate,
				null,
				l_num);
	    ELSE
              /* bugs 761336 and 1056403 */
	      if (l_inverse_rate_profile = 'Y') then
		  l_amount := ROUND(l_num/l_rate,p_reimbcurr_precision);
	      else
		  l_amount := ROUND(l_num * l_rate, p_reimbcurr_precision);
              end if; /* l_inverse_rate_profile = 'Y' */
	      l_orig_num := l_num;

	      /*** Round l_amount here. ***/
	    END IF; /* if (l_is_fixed_rate = 'Y') */
	  else
	    debug_info := 'l_amount is null';
      	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', debug_info);
	    l_amount := null;
	  end if; /* l_rate > 0 */

	  EXCEPTION
	    WHEN OTHERS then
	    -- Error should have been reported ealier. Do nothing here.
	    NULL;
	END;
       --
       -- If it's not null, check if it's a valid number >= 0
       --
       if (p_report_line_info.amount is not null and
           p_report_line_info.itemization_parent_id <> '-1') then
        BEGIN
          l_num := AP_WEB_DB_UTIL_PKG.CharToNumber(p_report_line_info.amount);
	  if CheckNum(l_num, p_exp_error, p_receiptcount,
		      C_Amount_Prompt, p_allow_credit_lines, FALSE) then
	  --
	  -- If Amount does not match value calculated from Daily amount,
	  -- Days, receipt amount and rate, report error.
	  -- Use format masks???
	  --
            --
            -- Corner case: user enters total amount only and leaves other
            -- amount as zero. (bug# 572569)
            --
            if (l_amount is null) then  -- note that l_amount can't be 0
              l_amount := l_num;
            end if;

	    -- For disconnected. When triangulation is involved.
	    IF (l_is_fixed_rate = 'Y') THEN
	      IF (NOT WithinTolerance(l_num, l_amount)) THEN
	        l_num := l_amount;
	        l_fixed_rate_applied := 'Y';
		p_report_line_info.amount := TO_CHAR(l_num);
	      END IF;
	    END IF;

        -- bug 6075479 do not validate amount for itemized lines
	    if ((l_num <> 0) AND (p_report_line_info.itemization_parent_id < 1)
                  AND (NOT WithinTolerance(l_num, l_amount))) then
 --added for bug 1056403
	      IF (l_inverse_rate_profile = 'Y') THEN
		l_cal_amount_method := '/';
              ELSE
	        l_cal_amount_method := '*';
	      END IF;

	      FND_MESSAGE.SET_NAME('SQLAP', 'AP_WEB_TOTAL_AMT_INCORRECT');
              FND_MESSAGE.SET_TOKEN('Total_Amount',
                                p_report_line_info.amount);
              FND_MESSAGE.SET_TOKEN('receipt_amount',to_char(l_orig_num));
              FND_MESSAGE.SET_TOKEN('amount_method',l_cal_amount_method);
              FND_MESSAGE.SET_TOKEN('rate',to_char(l_rate));
              FND_MESSAGE.SET_TOKEN('result',to_char(l_amount));

             -- JMARY Have to create a new message for this error
              AP_WEB_UTILITIES_PKG.AddExpError(
			p_exp_error,
                    	fnd_message.get_encoded(),
-- || TO_CHAR(l_orig_num) || l_cal_amount_method || TO_CHAR(l_rate) || '=' ||TO_CHAR(l_amount) ,
                    	AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
		        C_Amount_Prompt,
			p_receiptcount,
                        AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);

	    elsif (l_num = 0) then
	      -- It could be that 0 was pre-seeded in the spreadsheet. But
	      -- need to make sure that the calculated amount is not zero.
	      if (l_amount is not null) then
	 	p_report_line_info.amount := to_char(l_amount);
	      end if;
    	    end if;

	    /*
	    IF (l_fixed_rate_applied = 'Y') THEN
	    	  fnd_message.set_name('SQLAP','AP_WEB_FIXED_RATE_APPLIED');
                  AP_WEB_UTILITIES_PKG.AddExpError(P_Exp_Error,
                                fnd_message.get_encoded(),
                                AP_WEB_UTILITIES_PKG.C_WarningMessageType,
                                C_Rate_Prompt,
                                p_receiptcount,
                                AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);

	    END IF;
	    */
          end if; /* CheckNum */
        EXCEPTION
          when OTHERS then
            FND_MESSAGE.SET_NAME('SQLAP', 'AP_WEB_TOTAL_AMOUNT_INVALID');
            AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
                    fnd_message.get_encoded(),
                    AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                    C_Amount_Prompt,
                    p_receiptcount,
                    AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
        END;
       --
       -- If it's null, report error if daily amount and receipt amount are
       -- also null. Otherwise, try to calculate total amount.
       --
       else
	 if ((p_report_line_info.amount is null) AND
  	   (p_report_line_info.receipt_amount is null)) then
  	   fnd_message.set_name('SQLAP', 'AP_WEB_TOTAL_REQUIRED');
           AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
                    fnd_message.get_encoded(),
                    AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                    C_Amount_Prompt,
                    p_receiptcount,
                    AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
         else
           if (p_report_header_info.transaction_currency_type = 'reimbursement') then
            BEGIN
             l_num := to_number(p_report_line_info.amount);
	     if (l_num > 0) then
  	       p_report_line_info.amount :=
	        to_char(l_num * to_number(p_report_line_info.days));
	     end if;
  	    EXCEPTION
 	      when OTHERS then
	        NULL; /* checked DAmount and Days already, so sth useless. */
    	    END;
	   else
	     p_report_line_info.amount := to_char(l_amount);
	   end if; /* trans */
	  end if;
       end if; /* if Amount is not null */
     end if; /* if (NOT(p_calculate_receipt_index > 0)) */

     --- Check if at least one expense type is selected.  This should only
     --- be relavent in the disconnected case.
     --- Quan 1/22/99: Since this check is done in apwdiscb for disconnected report,
     --- we commented this out for bug 729876
/*
     debug_info := 'Expense type';
     BEGIN
       if (xtype_array(p_receiptcount) is null) then
	 debug_info := 'No expense type selected';
	 fnd_message.set_name('SQLAP', 'AP_WEB_EXPENSE_TYPE_REQUIRED');
         AP_WEB_UTILITIES_PKG.AddExpError(p_exp_error,
                    fnd_message.get_encoded(),
                    AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                    C_ExpType_Prompt,
                    p_receiptcount,
                    AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
       end if;
     END;
*/

     -------------------------------------------------------
     -- check if justification is required
     -------------------------------------------------------
     if (p_report_line_info.parameter_id is not null) then
       if (p_report_line_info.justification is null) then
	 -- Is justification required?
	 i := 1;
	 loop
	   if (i > p_justreq_array.COUNT) then
	     exit;
	   end if;
	   if (to_number(p_report_line_info.parameter_id) = p_justreq_array(i)) then

	     fnd_message.set_name('SQLAP', 'AP_WEB_JUSTIFICATION_REQUIRED');
             AP_WEB_UTILITIES_PKG.AddExpError(P_Exp_Error,
                                     fnd_message.get_encoded(),
                                     AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                                     C_Just_Prompt,
                                     p_receiptcount,
                                     AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, l_IsMobileApp);
             exit;
	   end if;
	   i := i + 1;
	 end loop;
       end if; /* justif is null? */
     end if; -- xtype is not null

   EXCEPTION
     WHEN OTHERS THEN
      BEGIN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     'ValidateExpLineCoreFields');
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'None passed.');
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;

        APP_EXCEPTION.RAISE_EXCEPTION;
      END;
END validateExpLineCoreFields;

/*----------------------------------------------------------------------------*
 | Procedure                                                                  |
 |      ValidateExplines                                                      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |      Server-Side validation for multiple receipt lines                     |
 |                                                                            |
 | ASSUMPTION                                                                 |
 |                                                                            |
 |                                                                            |
 | PARAMETERS                                                                 |
 |                                                                            |
 | RETURNS                                                                    |
 |     none                                                                   |
 *----------------------------------------------------------------------------*/

PROCEDURE ValidateExpLines(
    	p_userId	      IN 	NUMBER,
        p_report_header_info  IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
        p_report_line_info   IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportLines_A,
        p_custom1_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom2_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom3_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom4_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom5_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom6_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom7_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom8_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom9_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom10_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom11_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom12_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom13_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom14_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom15_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_has_core_field_errors         OUT NOCOPY BOOLEAN,
        p_has_custom_field_errors       OUT NOCOPY BOOLEAN,
        p_receipts_errors             IN  OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack,
        p_receipts_with_errors_count  IN  OUT NOCOPY BINARY_INTEGER,
        p_IsSessionProjectEnabled       IN VARCHAR2,
        p_calculate_receipt_index       IN BINARY_INTEGER DEFAULT NULL,
	p_bCalling_from_disconnected    IN BOOLEAN,
        p_addon_rates                   IN OIE_ADDON_RATES_T DEFAULT NULL,
        p_report_line_id                IN NUMBER DEFAULT NULL,
        p_daily_breakup_id              IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_start_date                    IN      OIE_PDM_DATE_T DEFAULT NULL,
        p_end_date                      IN      OIE_PDM_DATE_T DEFAULT NULL,
        p_amount                        IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_number_of_meals               IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_meals_amount                  IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_breakfast_flag                IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
        p_lunch_flag                    IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
        p_dinner_flag                   IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
        p_accommodation_amount          IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_accommodation_flag            IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
        p_hotel_name                    IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL,
        p_night_rate_Type               IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL,
        p_night_rate_amount             IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_pdm_rate                      IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_rate_Type_code                IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL,
        p_pdm_breakup_dest_id           IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_pdm_destination_id            IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_dest_start_date               IN      OIE_PDM_DATE_T DEFAULT NULL,
        p_dest_end_date                 IN      OIE_PDM_DATE_T DEFAULT NULL,
        p_location_id                   IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_cust_meals_amount             IN OUT  NOCOPY OIE_PDM_NUMBER_T,
        p_cust_accommodation_amount     IN OUT  NOCOPY OIE_PDM_NUMBER_T,
        p_cust_night_rate_amount        IN OUT  NOCOPY OIE_PDM_NUMBER_T,
        p_cust_pdm_rate                 IN OUT  NOCOPY OIE_PDM_NUMBER_T
	)
IS
  l_receipt_count         NUMBER;
  l_report_line_rec       AP_WEB_DFLEX_PKG.ExpReportLineRec;
  l_receipt_with_error NUMBER := 0;

BEGIN

  l_receipt_count := TO_NUMBER(p_report_header_info.receipt_count);

  -- For core case, do NOT assume that the error table is empty.  Certain
  -- errors are checked while processing the uploaded report in the discon.
  -- case.

  -- Whatever in p_receipts_errors should belong to core error stack.
  -- The only time it could be populated is during disconnected processing.
  -- Other times it should be given null since it'll be called after
  -- String2*.  If not so, make sure to initialize it before calling this
  -- procedure.
  --

  -- Clear p_receipts_errors_custom and p_receipts_errors
  AP_WEB_UTILITIES_PKG.InitMessages(l_receipt_count, p_receipts_errors);

  FOR i IN 1 .. l_Receipt_Count LOOP
     l_report_line_rec := p_report_line_info(i);

     AP_WEB_VALIDATE_UTIL.ValidateExpLine(
        p_userId,
        p_report_header_info	=>	p_report_header_info,
        p_report_line_info	=>	l_report_line_rec,
        p_custom1_array         =>	p_Custom1_Array,
        p_custom2_array		=>	p_Custom2_Array,
        p_custom3_array		=>	p_Custom3_Array,
        p_custom4_array		=>	p_Custom4_Array,
        p_custom5_array		=>	p_Custom5_Array,
        p_custom6_array		=>	p_Custom6_Array,
        p_custom7_array		=>	p_Custom7_Array,
        p_custom8_array		=>	p_Custom8_Array,
        p_custom9_array		=>	p_Custom9_Array,
        p_custom10_array	=>	p_Custom10_Array,
        p_custom11_array	=>	p_Custom11_Array,
        p_custom12_array	=>	p_Custom12_Array,
        p_custom13_array	=>	p_Custom13_Array,
        p_custom14_array	=>	p_Custom14_Array,
        p_custom15_array	=>	p_Custom15_Array,
        p_has_core_field_errors => 	p_has_core_field_errors,
        p_has_custom_field_errors     => p_has_custom_field_errors,
	p_receipts_errors     	      => p_receipts_errors,
	p_receipts_with_errors_count  => p_receipts_with_errors_count,
        p_IsSessionProjectEnabled     => p_IsSessionProjectEnabled,
	p_receipt_index		      => i,
        p_calculate_receipt_index     => NULL,
	p_bCalling_from_disconnected  => p_bCalling_from_disconnected,
        p_addon_rates                 => p_addon_rates,
        p_report_line_id              => p_report_line_id,
        p_daily_breakup_id            => p_daily_breakup_id,
        p_start_date                  => p_start_date,
        p_end_date                    => p_end_date,
        p_amount                      => p_amount,
        p_number_of_meals             => p_number_of_meals,
        p_meals_amount                => p_meals_amount,
        p_breakfast_flag              => p_breakfast_flag,
        p_lunch_flag                  => p_lunch_flag,
        p_dinner_flag                 => p_dinner_flag,
        p_accommodation_amount        => p_accommodation_amount,
        p_accommodation_flag          => p_accommodation_flag,
        p_hotel_name                  => p_hotel_name,
        p_night_rate_Type             => p_night_rate_type,
        p_night_rate_amount           => p_night_rate_amount,
        p_pdm_rate                    => p_pdm_rate,
        p_rate_Type_code              => p_rate_type_code,
        p_pdm_breakup_dest_id         => p_pdm_breakup_dest_id,
        p_pdm_destination_id          => p_pdm_destination_id,
        p_dest_start_date             => p_dest_start_date,
        p_dest_end_date               => p_dest_end_date,
        p_location_id                 => p_location_id,
        p_cust_meals_amount           => p_cust_meals_amount,
        p_cust_accommodation_amount   => p_cust_accommodation_amount,
        p_cust_night_rate_amount      => p_cust_night_rate_amount,
        p_cust_pdm_rate               => p_cust_pdm_rate
		);

    p_report_line_info(i):= l_report_line_rec ;

    l_receipt_with_error := l_receipt_with_error +p_receipts_with_errors_count ;

 END LOOP;
 p_receipts_with_errors_count := l_receipt_with_error;
END ValidateExplines;

/*----------------------------------------------------------------------------*
 | Procedure                                                                  |
 |      ValidateExpline                                                       |
 |                                                                            |
 | DESCRIPTION                                                                |
 |	Server-Side validation for single receipt line			      |
 |									      |
 | ASSUMPTION								      |
 |	p_report_header_info.number_max_flexfield has been set		      |
 |	p_report_header_info.summary_start_date has been set		      |
 |	p_report_header_info.summary_end_date has been set		      |
 |									      |
 | PARAMETERS                                                                 |
 |                                                                            |
 | RETURNS                                                                    |
 |     none                                                                   |
 *----------------------------------------------------------------------------*/

PROCEDURE ValidateExpLine(
    	p_userId		      	        IN 	NUMBER,
        p_report_header_info  IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
        p_report_line_info   IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportLineRec,
        p_custom1_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom2_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom3_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom4_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom5_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom6_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom7_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom8_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom9_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom10_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom11_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom12_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom13_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom14_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom15_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_has_core_field_errors     OUT NOCOPY BOOLEAN,
        p_has_custom_field_errors     OUT NOCOPY BOOLEAN,
	p_receipts_errors             IN OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack,
	p_receipts_with_errors_count  IN OUT NOCOPY BINARY_INTEGER,
        p_IsSessionProjectEnabled  	IN VARCHAR2,
	p_receipt_index			IN BINARY_INTEGER, --needed to reference CustomN_Array
        p_calculate_receipt_index      	IN BINARY_INTEGER DEFAULT NULL,
	p_bCalling_from_disconnected    IN BOOLEAN,
        p_addon_rates                   IN OIE_ADDON_RATES_T,
        p_report_line_id                IN      NUMBER DEFAULT NULL,
        p_daily_breakup_id              IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_start_date                    IN      OIE_PDM_DATE_T DEFAULT NULL,
        p_end_date                      IN      OIE_PDM_DATE_T DEFAULT NULL,
        p_amount                        IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_number_of_meals               IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_meals_amount                  IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_breakfast_flag                IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
        p_lunch_flag                    IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
        p_dinner_flag                   IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
        p_accommodation_amount          IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_accommodation_flag            IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
        p_hotel_name                    IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL,
        p_night_rate_Type               IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL,
        p_night_rate_amount             IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_pdm_rate                      IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_rate_Type_code                IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL,
        p_pdm_breakup_dest_id           IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_pdm_destination_id            IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_dest_start_date               IN      OIE_PDM_DATE_T DEFAULT NULL,
        p_dest_end_date                 IN      OIE_PDM_DATE_T DEFAULT NULL,
        p_location_id                   IN      OIE_PDM_NUMBER_T DEFAULT NULL,
        p_cust_meals_amount             IN OUT  NOCOPY OIE_PDM_NUMBER_T,
        p_cust_accommodation_amount     IN OUT  NOCOPY OIE_PDM_NUMBER_T,
        p_cust_night_rate_amount        IN OUT  NOCOPY OIE_PDM_NUMBER_T,
        p_cust_pdm_rate                 IN OUT  NOCOPY OIE_PDM_NUMBER_T
)
------------------------------------------------------------------------
IS
  l_receipts_with_errors_core   BINARY_INTEGER;
  l_receipts_with_errors_custom BINARY_INTEGER;
  l_errors                       AP_WEB_UTILITIES_PKG.expError;
  l_errors_custom		AP_WEB_UTILITIES_PKG.expError;

  V_IsSessionTaxEnabled		VARCHAR2(1);

  l_debug_info		       VARCHAR2(2000);

  l_recCount			INTEGER;

  l_allow_credit_lines_profile 	VARCHAR2(1) := 'N';
  l_allow_credit_lines 		BOOLEAN;

  l_curr_precision_cursor 	AP_WEB_DB_COUNTRY_PKG.CurrencyPrecisionCursor;
  l_reimbcurr_precision   	AP_WEB_DB_COUNTRY_PKG.curr_precision;

  V_SysInfoRec		       AP_WEB_DB_AP_INT_PKG.APSysInfoRec;   -- For PATC: Exchange rate type in AP and  Functional currency
  V_EndExpenseDate             DATE;           -- For PATC: Latest receipt date
  V_DefaultExchangeRate        NUMBER;         -- For PATC: Exchange rate for func->reimb
                                               -- on latest receipt date
  V_DateFormat                 VARCHAR2(30);

  I				INTEGER;
  l_DataDefaultedUpdateable     BOOLEAN;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_VALIDATE_UTIL', 'start validateExpLine');

  AP_WEB_DFLEX_PKG.IsSessionTaxEnabled(
    V_IsSessionTaxEnabled,
    p_userId); -- 2242176, fnd user id

  -- validate core lines fields
  l_debug_info := 'ValidateExpLinesCoreFields';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', l_debug_info);

  -- Bug 2204539: always allow credit line for credit card receipt
  if (p_report_line_info.cCardTrxnId is null) then
      l_allow_credit_lines_profile := AP_WEB_UTILITIES_PKG.VALUE_SPECIFIC(
					p_name    => 'AP_WEB_ALLOW_CREDIT_LINES',
					p_user_id =>  p_userId,
					p_resp_id =>  null,
					p_apps_id =>  null);
      if (l_allow_credit_lines_profile = 'Y') then
          l_allow_credit_lines := TRUE;
      else
          l_allow_credit_lines := FALSE;
      end if;
  else
          l_allow_credit_lines := TRUE;
  end if;

  l_reimbcurr_precision := AP_WEB_DB_COUNTRY_PKG.GetCurrencyPrecision(
	p_report_header_info.reimbursement_currency_code);


  AP_WEB_VALIDATE_UTIL.ValidateExpLineCoreFields(
                             p_userId, -- 2242176
			     p_report_header_info,
                             p_report_line_info,
                             p_receipt_index,
			     l_allow_credit_lines,
			     C_justreq_array,
			     l_reimbcurr_precision,
			     p_calculate_receipt_index,
			     l_errors);

 l_receipts_with_errors_core := l_errors.COUNT;


  -- validate flexfields
  l_debug_info := 'ValidateExpLinesCustomFields';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', l_debug_info);
  l_receipts_with_errors_custom := 0;

  -- The following calcuations marked with "For PATC" were
  -- added for the R11i support for multicurrency in PA.
  -- We need to retrieve currency and exchange rate information
  -- before calling PATC.

  -- For PATC: Used when doing projects verification
  --Bug 3336823
  V_DateFormat := nvl(icx_sec.g_date_format,icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT'));


  -- For PATC: Get information about functional currency and exchange
  -- rate for the last receipt date.  The last receipt date will be
  -- equal to sysdate.
  l_debug_info := 'Getting functional currency and exchange rate info';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', l_debug_info);

  -- for bug 3452403, get default currency information from header
  V_SysInfoRec.base_currency := p_report_header_info.default_currency_code;
  V_SysInfoRec.default_exchange_rate_type := p_report_header_info.default_exchange_rate_type;

  -- For PATC: Get the default exchange rate for the summary_end_date
  -- reimbursement currency/functional currency
  -- We are only calling this once for all receipts
     V_DefaultExchangeRate := AP_UTILITIES_PKG.get_exchange_rate(
      V_SysInfoRec.base_currency,
      p_report_header_info.reimbursement_currency_code,
      V_SysInfoRec.default_exchange_rate_type,
     p_report_header_info.summary_end_date,
     'ValidatePATransaction');

  l_receipts_with_errors_custom := 0;

  AP_WEB_VALIDATE_UTIL.ValidateExpLineCustomFields(
                               p_userId,
			       p_report_header_info,
                               p_report_line_info,
			       p_receipt_index,
			       V_SysInfoRec,
			       V_DefaultExchangeRate,
			       p_report_header_info.summary_end_date,
			       V_DateFormat,
                               p_custom1_array,
                               p_custom2_array,
                               p_custom3_array,
                               p_custom4_array,
                               p_custom5_array,
                               p_custom6_array,
                               p_custom7_array,
                               p_custom8_array,
                               p_custom9_array,
                               p_custom10_array,
                               p_custom11_array,
                               p_custom12_array,
                               p_custom13_array,
                               p_custom14_array,
                               p_custom15_array,
                               V_IsSessionTaxEnabled,
                               p_IsSessionProjectEnabled,
			       p_receipts_errors,
                               p_calculate_receipt_index,
                               l_errors_custom,
                               l_receipts_with_errors_custom,
			       l_DataDefaultedUpdateable,
			       p_bCalling_from_disconnected,
                               false,
                               p_addon_rates,
                         p_report_line_id,
                         p_daily_breakup_id,
                         p_start_date,
                         p_end_date,
                         p_amount,
                         p_number_of_meals,
                         p_meals_amount,
                         p_breakfast_flag,
                         p_lunch_flag,
                         p_dinner_flag,
                         p_accommodation_amount,
                         p_accommodation_flag,
                         p_hotel_name,
                         p_night_rate_Type,
                         p_night_rate_amount,
                         p_pdm_rate,
                         p_rate_Type_code,
                         p_pdm_breakup_dest_id,
                         p_pdm_destination_id,
                         p_dest_start_date,
                         p_dest_end_date,
                         p_location_id,
                         p_cust_meals_amount,
                         p_cust_accommodation_amount,
                         p_cust_night_rate_amount,
                         p_cust_pdm_rate
                         );

  --  bug#2188075 - Updated the amount, display a warning to the user
  IF (l_DataDefaultedUpdateable) THEN
    fnd_message.set_name('SQLAP', 'OIE_DATA_CALCULATED_DIFFER');
    AP_WEB_UTILITIES_PKG.AddExpError(l_errors_custom,
               fnd_message.get_encoded(),
		 AP_WEB_UTILITIES_PKG.C_WarningMessageType,
               'FlexField',
               p_receipt_index,
               AP_WEB_UTILITIES_PKG.C_DFFMessageCategory);
  END IF;


  -- determine whether there were errors in the custom field
  p_has_core_field_errors := (l_receipts_with_errors_core > 0);
  p_has_custom_field_errors := (l_receipts_with_errors_custom > 0);

  l_debug_info := 'merge error stacks';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', l_debug_info);

    AP_WEB_UTILITIES_PKG.MergeExpErrors(l_errors,
					l_errors_custom);

    AP_WEB_UTILITIES_PKG.MergeErrors(l_errors,
				     p_receipts_errors);

    p_receipts_with_errors_count :=
     AP_WEB_UTILITIES_PKG.NumOfReceiptWithError(p_receipts_errors);


EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     'ValidateExpLine');
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'None passed.');
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END;
END ValidateExpLine;

PROCEDURE MapColumnToCustomFields(
  p_userId           IN      NUMBER,
  P_ReceiptIndex     IN      NUMBER,
  Attribute_Array    IN      AP_WEB_PARENT_PKG.BigString_Array,
  ExpReportLinesInfo IN OUT NOCOPY  AP_WEB_DFLEX_PKG.ExpReportLines_A,
  Custom1_Array      IN OUT NOCOPY  AP_WEB_DFLEX_PKG.CustomFields_A,
  Custom2_Array      IN OUT NOCOPY  AP_WEB_DFLEX_PKG.CustomFields_A,
  Custom3_Array      IN OUT NOCOPY  AP_WEB_DFLEX_PKG.CustomFields_A,
  Custom4_Array      IN OUT NOCOPY  AP_WEB_DFLEX_PKG.CustomFields_A,
  Custom5_Array      IN OUT NOCOPY  AP_WEB_DFLEX_PKG.CustomFields_A,
  Custom6_Array      IN OUT NOCOPY  AP_WEB_DFLEX_PKG.CustomFields_A,
  Custom7_Array      IN OUT NOCOPY  AP_WEB_DFLEX_PKG.CustomFields_A,
  Custom8_Array      IN OUT NOCOPY  AP_WEB_DFLEX_PKG.CustomFields_A,
  Custom9_Array      IN OUT NOCOPY  AP_WEB_DFLEX_PKG.CustomFields_A,
  Custom10_Array     IN OUT NOCOPY  AP_WEB_DFLEX_PKG.CustomFields_A,
  Custom11_Array     IN OUT NOCOPY  AP_WEB_DFLEX_PKG.CustomFields_A,
  Custom12_Array     IN OUT NOCOPY  AP_WEB_DFLEX_PKG.CustomFields_A,
  Custom13_Array     IN OUT NOCOPY  AP_WEB_DFLEX_PKG.CustomFields_A,
  Custom14_Array     IN OUT NOCOPY  AP_WEB_DFLEX_PKG.CustomFields_A,
  Custom15_Array     IN OUT NOCOPY  AP_WEB_DFLEX_PKG.CustomFields_A)
IS

  l_CustomFieldsForOneReceipt AP_WEB_DFLEX_PKG.CustomFields_A;
  l_CustomField               AP_WEB_DFLEX_PKG.CustomFieldRec;
  I                           NUMBER;
  l_NumGlobalEnabledSegs      NUMBER;
  l_NumContextEnabledSegs     NUMBER;
  l_DFlexfield                FND_DFLEX.DFLEX_R;
  l_DFlexinfo                 FND_DFLEX.DFLEX_DR;
  l_DFlexfieldContexts        FND_DFLEX.CONTEXTS_DR;
  l_ContextIndex              NUMBER;

  -- Error
  l_CurrentCallingSequence VARCHAR2(240);
  l_DebugInfo              VARCHAR2(240);

  PROCEDURE MapColToField(
       Attribute_Array    IN AP_WEB_PARENT_PKG.BigString_Array,
       P_ColumnMapping    IN VARCHAR2,
       P_TargetValue      OUT NOCOPY VARCHAR2)
  IS
  BEGIN

    IF P_ColumnMapping = 'ATTRIBUTE1' THEN
      P_TargetValue := Attribute_Array(1);
    ELSIF P_ColumnMapping = 'ATTRIBUTE2' THEN
      P_TargetValue := Attribute_Array(2);
    ELSIF P_ColumnMapping = 'ATTRIBUTE3' THEN
      P_TargetValue := Attribute_Array(3);
    ELSIF P_ColumnMapping = 'ATTRIBUTE4' THEN
      P_TargetValue := Attribute_Array(4);
    ELSIF P_ColumnMapping = 'ATTRIBUTE5' THEN
      P_TargetValue := Attribute_Array(5);
    ELSIF P_ColumnMapping = 'ATTRIBUTE6' THEN
      P_TargetValue := Attribute_Array(6);
    ELSIF P_ColumnMapping = 'ATTRIBUTE7' THEN
      P_TargetValue := Attribute_Array(7);
    ELSIF P_ColumnMapping = 'ATTRIBUTE8' THEN
      P_TargetValue := Attribute_Array(8);
    ELSIF P_ColumnMapping = 'ATTRIBUTE9' THEN
      P_TargetValue := Attribute_Array(9);
    ELSIF P_ColumnMapping = 'ATTRIBUTE10' THEN
      P_TargetValue := Attribute_Array(10);
    ELSIF P_ColumnMapping = 'ATTRIBUTE11' THEN
      P_TargetValue := Attribute_Array(11);
    ELSIF P_ColumnMapping = 'ATTRIBUTE12' THEN
      P_TargetValue := Attribute_Array(12);
    ELSIF P_ColumnMapping = 'ATTRIBUTE13' THEN
      P_TargetValue := Attribute_Array(13);
    ELSIF P_ColumnMapping = 'ATTRIBUTE14' THEN
      P_TargetValue := Attribute_Array(14);
    ELSIF P_ColumnMapping = 'ATTRIBUTE15' THEN
      P_TargetValue := Attribute_Array(15);
    END IF;

  END MapColToField;

BEGIN

  l_CurrentCallingSequence := 'AP_WEB_VIEW_RECEIPTS_PKG';

  -- Initialize l_CustomFieldsForOneReceipt
  l_DebugInfo := 'Initialize l_CustomFieldsForOneReceipt';
  FOR I IN 1..15 LOOP
    AP_WEB_DFLEX_PKG.ClearCustomFieldRec(l_CustomFieldsForOneReceipt(I));
  END LOOP;

  -- Get information about custom fields
  l_DebugInfo := 'Get information about custom fields';
  AP_WEB_DFLEX_PKG.PopulateCustomFieldsInfo(
       p_userId                         => p_userId,
       p_exp_line_info 			=> ExpReportLinesInfo(P_ReceiptIndex),
       p_custom_fields_array 		=> l_CustomFieldsForOneReceipt,
       p_num_global_enabled_segs 	=> l_NumGlobalEnabledSegs,
       p_num_context_enabled_segs 	=> l_NumContextEnabledSegs,
       p_dflexfield 			=> l_DFlexField,
       p_dflexinfo 			=> l_DFlexInfo,
       p_dflexfield_contexts 		=> l_DFlexFieldContexts,
       p_context_index 			=> l_ContextIndex);

  -- Map the columns to custom value
  l_DebugInfo := 'Map the columns to custom value';
  FOR I IN 1..15 LOOP

    IF AP_WEB_DFLEX_PKG.IsFlexFieldUsed(l_CustomFieldsForOneReceipt(I)) THEN

      MapColToField(
	Attribute_Array,
        l_CustomFieldsForOneReceipt(I).column_mapping,
        l_CustomFieldsForOneReceipt(I).value);
    END IF;

  END LOOP;

  -- Propagate receipt info into the custom array
  l_DebugInfo := 'Propagate receipt info into the custom array';
  AP_WEB_DFLEX_PKG.PropogateReceiptCustFldsInfo(
        p_receipt_custom_fields_array 	=> l_CustomFieldsForOneReceipt,
        p_receipt_index 		=> P_ReceiptIndex,
        p_custom1_array 		=> Custom1_Array,
        p_custom2_array 		=> Custom2_Array,
        p_custom3_array 		=> Custom3_Array,
        p_custom4_array 		=> Custom4_Array,
        p_custom5_array 		=> Custom5_Array,
        p_custom6_array 		=> Custom6_Array,
        p_custom7_array 		=> Custom7_Array,
        p_custom8_array 		=> Custom8_Array,
        p_custom9_array 		=> Custom9_Array,
        p_custom10_array 		=> Custom10_Array,
        p_custom11_array 		=> Custom11_Array,
        p_custom12_array 		=> Custom12_Array,
        p_custom13_array 		=> Custom13_Array,
        p_custom14_array 		=> Custom14_Array,
        p_custom15_array 		=> Custom15_Array);

EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_CurrentCallingSequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS', '');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_DebugInfo);
      AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
    END;

END MapColumnToCustomFields;


PROCEDURE initJustificationRequiredArray IS
  l_debug_info		       VARCHAR2(2000);
  l_just_required_cursor       AP_WEB_DB_EXPTEMPLATE_PKG.JustificationExpTypeCursor;
  i				INTEGER;
BEGIN
  l_debug_info := 'Fill justification required array';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_VALIDATE_UTIL', l_debug_info);
  IF (AP_WEB_DB_EXPTEMPLATE_PKG.GetJustifReqdExpTypesCursor(l_just_required_cursor)) THEN
    i := 1;
    LOOP
      FETCH l_just_required_cursor INTO C_justreq_array(i);
      EXIT when l_just_required_cursor%NOTFOUND;
      i := i + 1;
    END LOOP;
  END IF;

  CLOSE l_just_required_cursor;
EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     'initJustificationRequiredArray');
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'None passed.');
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END;
END initJustificationRequiredArray;
-----------------------------------------------------------------------------


BEGIN  -- Package initialization
   initJustificationRequiredArray;

END AP_WEB_VALIDATE_UTIL;

/
