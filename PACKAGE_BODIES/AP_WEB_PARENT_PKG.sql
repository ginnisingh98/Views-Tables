--------------------------------------------------------
--  DDL for Package Body AP_WEB_PARENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_PARENT_PKG" AS
/* $Header: apwxexpb.pls 120.4 2006/02/24 11:22:43 sbalaji ship $ */

/* The prompt index are relative to AP_WEB_EXP_VIEW_REC */
C_Date1_Prompt CONSTANT  varchar2(3) := '6';
C_Date2_Prompt CONSTANT  varchar2(3) := '7';
C_Days_Prompt  CONSTANT  varchar2(3) := '8';
C_DAmount_Prompt CONSTANT varchar2(3) := '9';
C_Amount_Prompt CONSTANT  varchar2(3) := '23';
C_Exptype_Prompt CONSTANT varchar2(3) := '11';
C_Just_Prompt  CONSTANT  varchar2(3) := '12';
C_Grp_Prompt CONSTANT varchar2(3) := '24';
C_Missing_Prompt CONSTANT varchar2(3) := '15';
C_RecAmt_Prompt CONSTANT varchar2(3) := '10';
C_Rate_Prompt CONSTANT varchar2(3) := '22';


/*
Written by:
  Quan Le
Purpose:
  To retrieve the first string that is delimited @att@ from p-string. The return string and its delimiter
will be removed from p_string
The format of the string is:
  <string>"@att@"<string>"@att@"...
Input:
  p_delimiterSize: size of the delimiter
Output:
  first string that is delimited @att@
Input Output:
    p_string : string of the above format
Assumption:
Date:
  11/10/99
*/
function getNext(p_string in out nocopy varchar2,
                 p_delimiterSize in number) return varchar2
is
  l_position number;
  l_out      varchar2(240);
begin
  l_position := instrb(p_string, '@att@');
  l_out := substrb(p_string, 1, l_position-1);
  p_string := substrb(p_string, l_position + p_delimiterSize);
  return l_out;
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'getNext');
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
      END;

end getNext;

function getNextLong(p_string in out nocopy varchar2,
                 p_delimiterSize in number) return long
is
  l_position number;
  l_out      long;
begin
  l_position := instrb(p_string, '@att@');
  l_out := substrb(p_string, 1, l_position-1);
  p_string := substrb(p_string, l_position + p_delimiterSize);
  return l_out;

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'getNextLong');
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
      END;

end getNextLong;


-----------------------------------
-- Given the long report string, only fetch header info, and return
-- the rest of the string.
-----------------------------------
PROCEDURE String2PLSQL_Header(V_line		in out nocopy long,
                        P_IsSessionProjectEnabled IN VARCHAR2,
           		ExpReportHeaderInfo out nocopy AP_WEB_DFLEX_PKG.ExpReportHeaderRec) IS

position	number;
debug_info varchar2(200);
l_org_id	AP_WEB_DB_HR_INT_PKG.empCurrent_orgID;
current_calling_sequence varchar2(100) := 'String2PLSQL_Header';

  V_ExpenditureOrganizationID VARCHAR2(15);
  V_IsSessionProjectEnabled varchar2(1);
BEGIN

  V_line := replace(V_line, '
', '');
  -- bug 225419: Do not use CHR character function in PL/SQL
  -- V_line := replace(V_line, chr(13) || '
  -- ', '');


  -- Get restored report header ID
  position := instrb(V_line, '@att@');
  ExpReportHeaderInfo.report_header_id := substrb(V_line, 1, position-1);
  V_line := substrb(V_line, position+5);

  -- Get position within array where user last was
  debug_info := 'Getting Start Date';
  position := instrb(V_line, '@att@');
  ExpReportHeaderInfo.summary_start_date := substrb(V_line, 1, position-1);
  V_line := substrb(V_line, position+5);

  -- Get approver id
  debug_info := 'Getting approver id';
  position := instrb(V_line, '@att@');
  ExpReportHeaderInfo.override_approver_id := substrb(V_line, 1, position-1);
  V_line := substrb(V_line, position+5);

  -- Get approver name
  debug_info := 'Getting approver name';
  position := instrb(V_line, '@att@');
  ExpReportHeaderInfo.override_approver_name := substrb(V_line, 1, position-1);
  V_line := substrb(V_line, position+5);


  -- Get Cost Center
  debug_info := 'Getting cost center';
  position := instrb(V_line, '@att@');
  ExpReportHeaderInfo.cost_center := substrb(V_line, 1, position-1);
  V_line := substrb(V_line, position+5);



  -- Get employee_id that ValidateReport has been called in
  debug_info := 'Getting employee id';
  position := instrb(V_line, '@att@');
  ExpReportHeaderInfo.employee_id := substrb(V_line, 1, position-1);
  V_line := substrb(V_line, position+5);


  -- Get exp_report_id (PK of Expense Report Templates)
  debug_info := 'Getting exp report id';
  position := instrb(V_line, '@att@');
  ExpReportHeaderInfo.template_id := substrb(V_line, 1, position-1);
  V_line := substrb(V_line, position+5);


  -- Get template name (PK of Expense Report Templates)
  debug_info := 'Getting exp report id';
  position := instrb(V_line, '@att@');
  ExpReportHeaderInfo.template_name := substrb(V_line, 1, position-1);
  V_line := substrb(V_line, position+5);



  -- Get Last Receipt Date
  debug_info := 'Getting last receipt date';
  position := instrb(V_line, '@att@');
  ExpReportHeaderInfo.last_receipt_date := substrb(V_line, 1, position-1);
  V_line := substrb(V_line, position+5);

  -- Get Reimbursement Currency
  debug_info := 'Getting reimbCurr';
  position := instrb(V_line, '@att@');
  ExpReportHeaderInfo.reimbursement_currency_code := substrb(V_line, 1, position-1);
  V_line := substrb(V_line, position+5);

  -- Get Reimbursement Currency Name
  debug_info := 'Getting reimbCurr name';
  position := instrb(V_line, '@att@');
  ExpReportHeaderInfo.reimbursement_currency_name := substrb(V_line, 1, position-1);
  V_line := substrb(V_line, position+5);

  -- Get Multi-Currency flag (Y, N)
  debug_info := 'Getting multi curr flag';
  position := instrb(V_line, '@att@');
  ExpReportHeaderInfo.multi_currency_flag := substrb(V_line, 1, position-1);
  V_line := substrb(V_line, position+5);


  -- Get Purpose
  debug_info := 'Getting purpose';
  position := instrb(V_line, '@att@');
  ExpReportHeaderInfo.purpose := substrb(V_line, 1, position-1);
  V_line := substrb(V_line, position+5);

  -- Get maximum number of flexfields used
  debug_info := 'Getting maximum number of flex fields';
  position := instrb(V_line, '@att@');
  ExpReportHeaderInfo.number_max_flexfield := substrb(V_line, 1, position-1);
  V_line := substrb(V_line, position+5);


  -- Get amount due employee
  debug_info := 'Getting amount due employee';
  position := instrb(V_line, '@att@');
  ExpReportHeaderInfo.amt_due_employee := substrb(V_line, 1, position-1);
  V_line := substrb(V_line, position+5);

  -- Get amount due cc company
  debug_info := 'Getting amount due cc company';
  position := instrb(V_line, '@att@');
  ExpReportHeaderInfo.amt_due_ccCompany := substrb(V_line, 1, position-1);
  V_line := substrb(V_line, position+5);


  -- Go past '@line@'
  debug_info := 'Past Line';
  position := instrb(V_line, '@line@');
  V_line := substrb(V_line, position+6);


  -- Get organization ID for employee if project enabled
  ExpReportHeaderInfo.expenditure_organization_id := NULL;

  AP_WEB_PROJECT_PKG.IsSessionProjectEnabled(ExpReportHeaderInfo.employee_id,
    ICX_SEC.getID(icx_sec.PV_WEB_USER_ID),
    V_IsSessionProjectEnabled);

  begin
    if V_IsSessionProjectEnabled = 'Y' then
      IF (AP_WEB_DB_HR_INT_PKG.GetEmpOrgId(ExpReportHeaderInfo.employee_id, l_org_id)) THEN
	ExpReportHeaderInfo.expenditure_organization_id := l_org_id;
      END IF;
    end if;
  exception
    when others then
       BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
	APP_EXCEPTION.RAISE_EXCEPTION;
      END;
  end;

END String2PLSQL_Header;

PROCEDURE String2PLSQL_Receipts(P_IsSessionTaxEnabled     IN VARCHAR2,
                        P_IsSessionProjectEnabled IN VARCHAR2,
			receipt_error_Array in out nocopy AP_WEB_UTILITIES_PKG.receipt_error_stack,
		        V_Line in out nocopy long,
          		ExpReportHeaderInfo in out nocopy   AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
          		ExpReportLinesInfo    out nocopy    AP_WEB_DFLEX_PKG.ExpReportLines_A,
          		Custom1_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom2_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom3_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom4_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom5_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom6_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom7_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom8_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom9_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom10_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom11_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom12_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom13_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          		Custom14_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
         		Custom15_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A)
IS

debug_info varchar2(255) := '';
current_calling_sequence varchar2(255) :=
		'AP_WEB_PARENT_PKG.String2PLSQL_Receipts';
position number;
V_ReceiptVisited VARCHAR2(1);
I                NUMBER;
  l_temp	   VARCHAR2(30);
  V_NumMaxPseudoFlexField NUMBER;
  V_AmtInclTax     VARCHAR2(1);
  V_TaxName        VARCHAR2(15);
  V_TaxOverrideFlag  VARCHAR2(2);
  V_TaxId	   VARCHAR2(15);
  V_PAProjectNumber  pa_projects.segment1%type;
  V_PATaskNumber     pa_tasks.task_number%type;
  l_PAProjectName  PA_PROJECTS_EXPEND_V.project_name%TYPE;
  l_PATaskName	   PA_TASKS_EXPEND_V.task_name%TYPE;
  V_PAProjectID    VARCHAR2(15) := NULL;
  V_PATaskID       VARCHAR2(15) := NULL;
  V_PAExpenditureType AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_paExpenditureType := NULL;

  V_ErrorMessage   		LONG;
  V_ErrorField     		VARCHAR2(100);
  V_WarningMessage 		LONG;
  V_WarningField   		VARCHAR2(100);
  V_ReceiptCount   		Number := 0;

-- chiho:
  l_exp_type	   		VARCHAR2(30);
  l_date_format    		VARCHAR2(30);
  l_date 	   		DATE;
  l_is_fixed_rate  		VARCHAR2(1);
  l_euro_rate      		NUMBER;
  l_inverse_rate_profile 	VARCHAR2(1);

  l_tax_code                    VARCHAR2(15);

BEGIN

  V_NumMaxPseudoFlexField := AP_WEB_DFLEX_PKG.GetMaxNumPseudoSegmentsUsed(
   P_IsSessionProjectEnabled);


  LOOP
    if (nvl(length(V_line),0) < 13) then
      Exit;
    end if;


    -- Increment Receipt Counter
    V_ReceiptCount := V_ReceiptCount + 1;

    -- Initialize custom fields array
    AP_WEB_DFLEX_PKG.ClearCustomFieldRec(Custom1_Array(V_ReceiptCount));
    AP_WEB_DFLEX_PKG.ClearCustomFieldRec(Custom2_Array(V_ReceiptCount));
    AP_WEB_DFLEX_PKG.ClearCustomFieldRec(Custom3_Array(V_ReceiptCount));
    AP_WEB_DFLEX_PKG.ClearCustomFieldRec(Custom4_Array(V_ReceiptCount));
    AP_WEB_DFLEX_PKG.ClearCustomFieldRec(Custom5_Array(V_ReceiptCount));
    AP_WEB_DFLEX_PKG.ClearCustomFieldRec(Custom6_Array(V_ReceiptCount));
    AP_WEB_DFLEX_PKG.ClearCustomFieldRec(Custom7_Array(V_ReceiptCount));
    AP_WEB_DFLEX_PKG.ClearCustomFieldRec(Custom8_Array(V_ReceiptCount));
    AP_WEB_DFLEX_PKG.ClearCustomFieldRec(Custom9_Array(V_ReceiptCount));
    AP_WEB_DFLEX_PKG.ClearCustomFieldRec(Custom10_Array(V_ReceiptCount));
    AP_WEB_DFLEX_PKG.ClearCustomFieldRec(Custom11_Array(V_ReceiptCount));
    AP_WEB_DFLEX_PKG.ClearCustomFieldRec(Custom12_Array(V_ReceiptCount));
    AP_WEB_DFLEX_PKG.ClearCustomFieldRec(Custom13_Array(V_ReceiptCount));
    AP_WEB_DFLEX_PKG.ClearCustomFieldRec(Custom14_Array(V_ReceiptCount));
    AP_WEB_DFLEX_PKG.ClearCustomFieldRec(Custom15_Array(V_ReceiptCount));

    debug_info := 'Parsing Receipt '||to_char(V_ReceiptCount);

    -- Pull Detail-level values
    --
    -- Get Start Date of Receipt
    ExpReportLinesInfo(V_ReceiptCount).start_date := getNext(V_line, 5);

    -- Get End Date of Receipt
    ExpReportLinesInfo(V_ReceiptCount).end_date := getNext(V_line, 5);

    -- Get Span of Expense in Days
    ExpReportLinesInfo(V_ReceiptCount).days := getNext(V_line, 5);

    -- Get Daily Amount
    ExpReportLinesInfo(V_ReceiptCount).daily_amount := getNext(V_line, 5);

    -- Get Receipt Amount
    ExpReportLinesInfo(V_ReceiptCount).receipt_amount := getNext(V_line, 5);

    -- Get Conversion Rate
    ExpReportLinesInfo(V_ReceiptCount).rate := substrb(getNext(V_line, 5),1,25);


    -- Get Receipt Amount (in Reimbursement Currency)
    ExpReportLinesInfo(V_ReceiptCount).amount := getNext(V_line, 5);

    -- Get Group
    ExpReportLinesInfo(V_ReceiptCount).group_value := getNext(V_line, 5);

    -- Get Justification
    -- bug 225419: Do not use CHR character function in PL/SQL
    -- ExpReportLinesInfo(V_ReceiptCount).justification := replace(getNext(V_line, 5), chr(13)||'
    -- ',' ');
    ExpReportLinesInfo(V_ReceiptCount).justification := replace(getNext(V_line, 5), '
',' ');

    -- Get Receipt Missing flag
    ExpReportLinesInfo(V_ReceiptCount).receipt_missing_flag :=  getNext(V_line, 5);

    -- Get Expense Type
-- chiho:make the expense type NULL if no valid value was entered:
BEGIN
    l_exp_type := getNext( V_line, 5 );
    ExpReportLinesInfo(V_ReceiptCount).parameter_id := TO_NUMBER( l_exp_type );

EXCEPTION
	WHEN OTHERS THEN
    		ExpReportLinesInfo(V_ReceiptCount).parameter_id := NULL;
END;

    -- Get Receipt Currency
    ExpReportLinesInfo(V_ReceiptCount).currency_code := getNext(V_line, 5);

    -- Determine if Euro currencies
    debug_info := 'Euro';
    l_date_format := ICX_SEC.getID(ICX_SEC.PV_DATE_FORMAT);
    l_date := nvl(to_date(ExpReportLinesInfo(V_ReceiptCount).end_date,
		          l_date_format),
		  to_date(ExpReportLinesInfo(V_ReceiptCount).start_date,
			  l_date_format));
    -- is_fixed_rate does not handle null date well.
    IF ((l_date is NOT NULL) AND (ExpReportLinesInfo(V_ReceiptCount).currency_code <> 'OTHER')) THEN
     	l_is_fixed_rate := GL_CURRENCY_API.is_fixed_rate(
				ExpReportLinesInfo(V_ReceiptCount).currency_code, ExpReportHeaderInfo.reimbursement_currency_code, l_date);
	IF (l_is_fixed_rate = 'Y') THEN
           l_euro_rate := GL_CURRENCY_API.get_rate(
 				   ExpReportLinesInfo(V_ReceiptCount).currency_code,
				   ExpReportHeaderInfo.reimbursement_currency_code,
				   l_date,
				   null);
           debug_info := 'Rate =  '  ||  to_char(l_euro_rate);
  	   -- Determine Inverse Rate Profile Option
  	   FND_PROFILE.GET('DISPLAY_INVERSE_RATE',l_inverse_rate_profile);
           IF (nvl(l_inverse_rate_profile,'N') = 'Y' AND nvl(l_euro_rate,0) <> 0) THEN
              l_euro_rate := 1/l_euro_rate;
           END IF;
	   ExpReportLinesInfo(V_ReceiptCount).rate := substrb(to_char(l_euro_rate), 1, 25);
	END IF;
    END IF;

    -- Get ItemizeID
    l_temp := getNext(V_line, 5);
    if (l_temp = 'null') then ExpReportLinesInfo(V_ReceiptCount).itemizeId := null;
    else ExpReportLinesInfo(V_ReceiptCount).itemizeId := l_temp;
    end if;

    -- Get CCTrxnID
    l_temp := getNext(V_line, 5);
    if (l_temp = 'null') then ExpReportLinesInfo(V_ReceiptCount).cCardTrxnId  := null;
    else ExpReportLinesInfo(V_ReceiptCount).cCardTrxnId  := l_temp;
    end if;

    -- Get Merchant
    ExpReportLinesInfo(V_ReceiptCount).merchant := getNext(V_line, 5);

    -- Get MerchantDoc
    ExpReportLinesInfo(V_ReceiptCount).merchantDoc := getNext(V_line, 5);

    -- Get TaxReference
    ExpReportLinesInfo(V_ReceiptCount).taxReference := getNext(V_line, 5);

    -- Get TaxRegNumber
    ExpReportLinesInfo(V_ReceiptCount).taxRegNumber := getNext(V_line, 5);

    -- Get TaxPayerID
    ExpReportLinesInfo(V_ReceiptCount).taxPayerId := getNext(V_line, 5);

    -- Get SupplyCountry
    ExpReportLinesInfo(V_ReceiptCount).supplyCountry := getNext(V_line, 5);

    -- Get TaxCodeID
    ExpReportLinesInfo(V_ReceiptCount).taxId := getNext(V_line, 5);

    -- Get VatCode
    IF (ExpReportLinesInfo(V_ReceiptCount).taxId is not null) THEN
      IF ( NOT AP_WEB_DB_AP_INT_PKG.GetVatCode(ExpReportLinesInfo(V_ReceiptCount).taxId, ExpReportLinesInfo(V_ReceiptCount).tax_code) ) THEN
         null;
      END IF;
    END IF;


    -- Get OverrideFlag
    ExpReportLinesInfo(V_ReceiptCount).taxOverrideFlag := getNext(V_line, 5);

    -- Get AmtIncludesTax
    ExpReportLinesInfo(V_ReceiptCount).amount_includes_tax := getNext(V_line, 5);

    -- Get TaxCode
    l_tax_code := getNext(V_line, 5);
    IF nvl(P_IsSessionTaxEnabled,'N') <> 'Y' THEN
       ExpReportLinesInfo(V_ReceiptCount).tax_code := l_tax_code;
    END IF;

    -- Get flexfield info
    Custom1_Array(V_ReceiptCount).value := NULL;
    IF (ExpReportHeaderInfo.number_max_flexfield >= 1) THEN
      Custom1_Array(V_ReceiptCount).value := getNext(V_line, 5);
    END IF;

    Custom2_Array(V_ReceiptCount).value := NULL;
    IF (ExpReportHeaderInfo.number_max_flexfield >= 2) THEN
      Custom2_Array(V_ReceiptCount).value := getNext(V_line, 5);
    END IF;

    Custom3_Array(V_ReceiptCount).value := NULL;
    IF (ExpReportHeaderInfo.number_max_flexfield >= 3) THEN
      Custom3_Array(V_ReceiptCount).value := getNext(V_line, 5);
    END IF;

    Custom4_Array(V_ReceiptCount).value := NULL;
    IF (ExpReportHeaderInfo.number_max_flexfield >= 4) THEN
      Custom4_Array(V_ReceiptCount).value := getNext(V_line, 5);
    END IF;

    Custom5_Array(V_ReceiptCount).value := NULL;
    IF (ExpReportHeaderInfo.number_max_flexfield >= 5) THEN
      Custom5_Array(V_ReceiptCount).value := getNext(V_line, 5);
    END IF;

    Custom6_Array(V_ReceiptCount).value := NULL;
    IF (ExpReportHeaderInfo.number_max_flexfield >= 6) THEN
      Custom6_Array(V_ReceiptCount).value := getNext(V_line, 5);
    END IF;

    Custom7_Array(V_ReceiptCount).value := NULL;
    IF (ExpReportHeaderInfo.number_max_flexfield >= 7) THEN
      Custom7_Array(V_ReceiptCount).value := getNext(V_line, 5);
    END IF;

    Custom8_Array(V_ReceiptCount).value := NULL;
    IF (ExpReportHeaderInfo.number_max_flexfield >= 8) THEN
      Custom8_Array(V_ReceiptCount).value := getNext(V_line, 5);
    END IF;

    Custom9_Array(V_ReceiptCount).value := NULL;
    IF (ExpReportHeaderInfo.number_max_flexfield >= 9) THEN
      Custom9_Array(V_ReceiptCount).value := getNext(V_line, 5);
    END IF;

    Custom10_Array(V_ReceiptCount).value := NULL;
    IF (ExpReportHeaderInfo.number_max_flexfield >= 10) THEN
      Custom10_Array(V_ReceiptCount).value := getNext(V_line, 5);
    END IF;

    Custom11_Array(V_ReceiptCount).value := NULL;
    IF (ExpReportHeaderInfo.number_max_flexfield >= 11) THEN
      Custom11_Array(V_ReceiptCount).value := getNext(V_line, 5);
    END IF;

    Custom12_Array(V_ReceiptCount).value := NULL;
    IF (ExpReportHeaderInfo.number_max_flexfield >= 12) THEN
      Custom12_Array(V_ReceiptCount).value := getNext(V_line, 5);
    END IF;

    Custom13_Array(V_ReceiptCount).value := NULL;
    IF (ExpReportHeaderInfo.number_max_flexfield >= 13) THEN
      Custom13_Array(V_ReceiptCount).value := getNext(V_line, 5);
    END IF;

    Custom14_Array(V_ReceiptCount).value := NULL;
    IF (ExpReportHeaderInfo.number_max_flexfield >= 14) THEN
      Custom14_Array(V_ReceiptCount).value := getNext(V_line, 5);
    END IF;

    Custom15_Array(V_ReceiptCount).value := NULL;
    IF (ExpReportHeaderInfo.number_max_flexfield >= 15) THEN
      Custom15_Array(V_ReceiptCount).value := getNext(V_line, 5);
    END IF;

    -- Project Pseudo flexfields
    V_PAProjectNumber := NULL;
    V_PATaskNumber := NULL;
    IF P_IsSessionProjectEnabled = 'Y' THEN
      -- Project Number
      debug_info := 'position 1';
      V_PAProjectNumber := getNext(V_line, 5);
      ExpReportLinesInfo(V_ReceiptCount).project_number := V_PAProjectNumber;

      ExpReportLinesInfo(V_ReceiptCount).project_id := NULL;


      -- Task Number
      V_PATaskNumber := getNext(V_line, 5);

      ExpReportLinesInfo(V_ReceiptCount).task_number := V_PATaskNumber;

      ExpReportLinesInfo(V_ReceiptCount).task_id := NULL;

    END IF;

    -- Get whether receipt was visited
    ExpReportLinesInfo(V_ReceiptCount).validation_required := getNext(V_line, 5);

    -- Get Error Table
    V_ErrorMessage := getNextLong(V_line, 5);

    V_ErrorField := getNext(V_line, 5);
    -- Convert the error message strings to MessageArray
    receipt_error_Array(V_ReceiptCount).error_text := V_ErrorMessage;
    receipt_error_Array(V_ReceiptCount).error_fields := V_ErrorField;

    -- Get Warning Table
    V_WarningMessage := getNextLong(V_line, 5);
    V_WarningField := getNext(V_line, 11);

    -- Convert the error message strings to MessageArray
    receipt_error_Array(V_ReceiptCount).warning_text := V_WarningMessage;
    receipt_error_Array(V_ReceiptCount).warning_fields := V_WarningField;


    -- Fill in other project information

    AP_WEB_PROJECT_PKG.DerivePAInfoFromUserInput(
         P_IsSessionProjectEnabled,
         V_PAProjectNumber,
         V_PAProjectID,
	 l_PAProjectName,
         V_PATaskNumber,
         V_PATaskID,
	 l_PATaskName,
         V_PAExpenditureType,
         ExpReportLinesInfo(V_ReceiptCount).parameter_id);

    if (V_PAExpenditureType IS NOT NULL) then
	ExpReportLinesInfo(V_ReceiptCount).expenditure_type := V_PAExpenditureType;
    end if;

    if (V_PAProjectID IS NOT NULL) then ExpReportLinesInfo(V_ReceiptCount).project_id := V_PAProjectID;
    end if;

    if (V_PATaskID IS NOT NULL) then ExpReportLinesInfo(V_ReceiptCount).task_id := V_PATaskID;
    end if;

  END LOOP;

  -- Set the new header data type
  ExpReportHeaderInfo.receipt_count := V_ReceiptCount;

  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
		'V_line=' || V_line
                                    );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        APP_EXCEPTION.RAISE_EXCEPTION;
      END;

END String2PLSQL_Receipts;


PROCEDURE String2PLSQL(P_IsSessionTaxEnabled     IN VARCHAR2,
                        P_IsSessionProjectEnabled IN VARCHAR2,
			receipt_error_Array in out nocopy AP_WEB_UTILITIES_PKG.receipt_error_stack,
		        ParseThis in long,
          ExpReportHeaderInfo   out nocopy   AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
          ExpReportLinesInfo    out nocopy    AP_WEB_DFLEX_PKG.ExpReportLines_A,
          Custom1_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom2_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom3_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom4_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom5_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom6_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom7_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom8_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom9_Array in out nocopy         AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom10_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom11_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom12_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom13_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom14_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A,
          Custom15_Array in out nocopy        AP_WEB_DFLEX_PKG.CustomFields_A)
IS
position	number;
V_line long := ParseThis;
debug_info varchar2(200);
current_calling_sequence varchar2(100) := 'String2PLSQL';
V_IsSessionProjectEnabled varchar2(1);

BEGIN

  -- Pull Header-level values
  --
  debug_info := 'Header level';
  String2PLSQL_Header(V_line,
                P_IsSessionProjectEnabled,
                ExpReportHeaderInfo);

  AP_WEB_PROJECT_PKG.IsSessionProjectEnabled(ExpReportHeaderInfo.employee_id,
    ICX_SEC.getID(icx_sec.PV_WEB_USER_ID),
    V_IsSessionProjectEnabled);

  --
  -- Get the receipts
  --
  String2PLSQL_Receipts(P_IsSessionTaxEnabled,
                        V_IsSessionProjectEnabled,
			receipt_error_Array,
		        V_line,
                        ExpReportHeaderInfo,
                        ExpReportLinesInfo,
                        Custom1_Array,
                        Custom2_Array,
                        Custom3_Array,
                        Custom4_Array,
                        Custom5_Array,
                        Custom6_Array,
                        Custom7_Array,
                        Custom8_Array,
                        Custom9_Array,
                        Custom10_Array,
                        Custom11_Array,
                        Custom12_Array,
                        Custom13_Array,
                        Custom14_Array,
                        Custom15_Array);

  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
       IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
		'V_line=' || V_line
                                    );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
       END IF;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END;

END String2PLSQL;


PROCEDURE MapCustomArrayToColumn(
                  P_Index               IN NUMBER,
                  ExpReportHeaderInfo   IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
                  ExpReportLinesInfo    IN AP_WEB_DFLEX_PKG.ExpReportLines_A,
                  Custom1_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom2_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom3_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom4_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom5_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom6_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom7_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom8_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom9_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom10_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom11_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom12_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom13_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom14_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  Custom15_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                  AttributeCol_Array  IN OUT NOCOPY BigString_Array)
IS

  V_CurrentCallingSequence  VARCHAR2(2000);
  V_DebugInfo               VARCHAR2(2000);

  PROCEDURE MapFlexFieldValueToColumn(
       P_Value            IN VARCHAR2,
       P_ColumnMapping    IN VARCHAR2,
       AttributeCol_Array IN OUT NOCOPY AP_WEB_PARENT_PKG.BigString_Array)
  IS
  BEGIN

    IF P_ColumnMapping = 'ATTRIBUTE1' THEN
      AttributeCol_Array(1) := P_Value;
    END IF;

    IF P_ColumnMapping = 'ATTRIBUTE2' THEN
      AttributeCol_Array(2) := P_Value;
    END IF;

    IF P_ColumnMapping = 'ATTRIBUTE3' THEN
      AttributeCol_Array(3) := P_Value;
    END IF;

    IF P_ColumnMapping = 'ATTRIBUTE4' THEN
      AttributeCol_Array(4) := P_Value;
    END IF;

    IF P_ColumnMapping = 'ATTRIBUTE5' THEN
      AttributeCol_Array(5) := P_Value;
    END IF;

    IF P_ColumnMapping = 'ATTRIBUTE6' THEN
      AttributeCol_Array(6) := P_Value;
    END IF;

    IF P_ColumnMapping = 'ATTRIBUTE7' THEN
      AttributeCol_Array(7) := P_Value;
    END IF;

    IF P_ColumnMapping = 'ATTRIBUTE8' THEN
      AttributeCol_Array(8) := P_Value;
    END IF;

    IF P_ColumnMapping = 'ATTRIBUTE9' THEN
      AttributeCol_Array(9) := P_Value;
    END IF;

    IF P_ColumnMapping = 'ATTRIBUTE10' THEN
      AttributeCol_Array(10) := P_Value;
    END IF;

    IF P_ColumnMapping = 'ATTRIBUTE11' THEN
      AttributeCol_Array(11) := P_Value;
    END IF;

    IF P_ColumnMapping = 'ATTRIBUTE12' THEN
      AttributeCol_Array(12) := P_Value;
    END IF;

    IF P_ColumnMapping = 'ATTRIBUTE13' THEN
      AttributeCol_Array(13) := P_Value;
    END IF;

    IF P_ColumnMapping = 'ATTRIBUTE14' THEN
      AttributeCol_Array(14) := P_Value;
    END IF;

    IF P_ColumnMapping = 'ATTRIBUTE15' THEN
      AttributeCol_Array(15) := P_Value;
    END IF;

  END MapFlexFieldValueToColumn;

BEGIN

  V_CurrentCallingSequence := 'AP_WEB_SUBMIT_PKG.MapCustomArrayToColumn';

  -- Initialize attribute column values
  FOR I IN 1..15 LOOP
    AttributeCol_Array(I) := NULL;
  END LOOP;

  -- Map values for index-th receipt
  IF AP_WEB_DFLEX_PKG.IsFlexFieldUsed(Custom1_Array(P_Index)) THEN

    MapFlexFieldValueToColumn(Custom1_Array(P_Index).value,
                         Custom1_Array(P_Index).column_mapping,
                         AttributeCol_Array);

  END IF;

  -- Map values for index-th receipt
  IF AP_WEB_DFLEX_PKG.IsFlexFieldUsed(Custom2_Array(P_Index)) THEN

    MapFlexFieldValueToColumn(Custom2_Array(P_Index).value,
                              Custom2_Array(P_Index).column_mapping,
                              AttributeCol_Array);
  END IF;

  -- Map values for index-th receipt
  IF AP_WEB_DFLEX_PKG.IsFlexFieldUsed(Custom3_Array(P_Index)) THEN

    MapFlexFieldValueToColumn(Custom3_Array(P_Index).value,
                              Custom3_Array(P_Index).column_mapping,
                              AttributeCol_Array);

  END IF;

  -- Map values for index-th receipt
  IF AP_WEB_DFLEX_PKG.IsFlexFieldUsed(Custom4_Array(P_Index)) THEN

    MapFlexFieldValueToColumn(Custom4_Array(P_Index).value,
                              Custom4_Array(P_Index).column_mapping,
                              AttributeCol_Array);

  END IF;

  -- Map values for index-th receipt
  IF AP_WEB_DFLEX_PKG.IsFlexFieldUsed(Custom5_Array(P_Index)) THEN

    MapFlexFieldValueToColumn(Custom5_Array(P_Index).value,
                              Custom5_Array(P_Index).column_mapping,
                              AttributeCol_Array);
  END IF;

  -- Map values for index-th receipt
  IF AP_WEB_DFLEX_PKG.IsFlexFieldUsed(Custom6_Array(P_Index)) THEN

    MapFlexFieldValueToColumn(Custom6_Array(P_Index).value,
                              Custom6_Array(P_Index).column_mapping,
                              AttributeCol_Array);
  END IF;

  -- Map values for index-th receipt
  IF AP_WEB_DFLEX_PKG.IsFlexFieldUsed(Custom7_Array(P_Index)) THEN

    MapFlexFieldValueToColumn(Custom7_Array(P_Index).value,
                              Custom7_Array(P_Index).column_mapping,
                              AttributeCol_Array);
  END IF;

  -- Map values for index-th receipt
  IF AP_WEB_DFLEX_PKG.IsFlexFieldUsed(Custom8_Array(P_Index)) THEN

    MapFlexFieldValueToColumn(Custom8_Array(P_Index).value,
                              Custom8_Array(P_Index).column_mapping,
                              AttributeCol_Array);
  END IF;

  -- Map values for index-th receipt
  IF AP_WEB_DFLEX_PKG.IsFlexFieldUsed(Custom9_Array(P_Index)) THEN

    MapFlexFieldValueToColumn(Custom9_Array(P_Index).value,
                              Custom9_Array(P_Index).column_mapping,
                              AttributeCol_Array);
  END IF;

  -- Map values for index-th receipt
  IF AP_WEB_DFLEX_PKG.IsFlexFieldUsed(Custom10_Array(P_Index)) THEN

    MapFlexFieldValueToColumn(Custom10_Array(P_Index).value,
                              Custom10_Array(P_Index).column_mapping,
                              AttributeCol_Array);
  END IF;

  -- Map values for index-th receipt
  IF AP_WEB_DFLEX_PKG.IsFlexFieldUsed(Custom11_Array(P_Index)) THEN

    MapFlexFieldValueToColumn(Custom11_Array(P_Index).value,
                              Custom11_Array(P_Index).column_mapping,
                              AttributeCol_Array);
  END IF;

  -- Map values for index-th receipt
  IF AP_WEB_DFLEX_PKG.IsFlexFieldUsed(Custom12_Array(P_Index)) THEN

    MapFlexFieldValueToColumn(Custom12_Array(P_Index).value,
                              Custom12_Array(P_Index).column_mapping,
                              AttributeCol_Array);
  END IF;

  -- Map values for index-th receipt
  IF AP_WEB_DFLEX_PKG.IsFlexFieldUsed(Custom13_Array(P_Index)) THEN

    MapFlexFieldValueToColumn(Custom13_Array(P_Index).value,
                              Custom13_Array(P_Index).column_mapping,
                              AttributeCol_Array);
  END IF;

  -- Map values for index-th receipt
  IF AP_WEB_DFLEX_PKG.IsFlexFieldUsed(Custom14_Array(P_Index)) THEN

    MapFlexFieldValueToColumn(Custom14_Array(P_Index).value,
                              Custom14_Array(P_Index).column_mapping,
                              AttributeCol_Array);
  END IF;

  -- Map values for index-th receipt
  IF AP_WEB_DFLEX_PKG.IsFlexFieldUsed(Custom15_Array(P_Index)) THEN

    MapFlexFieldValueToColumn(Custom15_Array(P_Index).value,
                              Custom15_Array(P_Index).column_mapping,
                              AttributeCol_Array);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', V_CurrentCallingSequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS','');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',V_DebugInfo);
      APP_EXCEPTION.Raise_Exception;
    END;

END MapCustomArrayToColumn;


END AP_WEB_PARENT_PKG;

/
