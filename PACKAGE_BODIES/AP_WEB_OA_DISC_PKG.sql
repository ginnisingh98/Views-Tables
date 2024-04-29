--------------------------------------------------------
--  DDL for Package Body AP_WEB_OA_DISC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_OA_DISC_PKG" AS
/* $Header: apwoadib.pls 120.19.12010000.4 2009/05/12 06:06:38 meesubra ship $ */

/* Constants */
C_Yes           CONSTANT VARCHAR2(1) := 'Y';
C_No            CONSTANT VARCHAR2(1) := 'N';

C_REQUIRED                CONSTANT VARCHAR2(25) := 'REQUIRED';
C_ENABLED                 CONSTANT VARCHAR2(25) := 'ENABLED';

PROCEDURE AddLineNumbersToErrors (p_header_errors IN AP_WEB_UTILITIES_PKG.expError,
                             p_receipt_errors IN AP_WEB_UTILITIES_PKG.receipt_error_stack);

PROCEDURE CheckForReceiptWarnings (p_receipt_errors IN AP_WEB_UTILITIES_PKG.receipt_error_stack);

Procedure OAInsertTempData(
           p_report_header_info  IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
           p_report_lines_info   IN AP_WEB_DFLEX_PKG.ExpReportLines_A,
           p_receipt_errors      IN AP_WEB_UTILITIES_PKG.receipt_error_stack,
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
           Custom15_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A);

PROCEDURE ValidateRequiredProjectTask(
        p_employee_id         IN NUMBER, -- bug 2242176, employee's id
        p_user_id             IN NUMBER, -- bug 2242176, employee's user id
        p_report_header_info  IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
        p_report_lines_info   IN AP_WEB_DFLEX_PKG.ExpReportLines_A,
        p_receipts_errors      IN OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack);

PROCEDURE CheckForMileagePerDiemPolicy(
        p_user_id             IN NUMBER,
        p_report_header_info  IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
        p_report_lines_info   IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportLines_A,
        p_header_errors       IN OUT NOCOPY AP_WEB_UTILITIES_PKG.expError,
        p_receipts_errors     IN OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack);

PROCEDURE ValidateHeaderDFF(
        p_user_id             IN NUMBER,
        p_report_header_info  IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
        p_header_errors       IN OUT NOCOPY AP_WEB_UTILITIES_PKG.expError);


/*
  Written By
    JMARY
  Purpose
    Procedure called by Import Page to display the Setup Errors and  Data Validation Errors.
  Input
    p_exp
    p_empid
  Output
    p_error_type
    p_return_status
    p_msg_count
    p_msg_data
  InputOutput
    None
  Assumptions
    The application is WEB
  Date
   01-DEC-2000
*/

Procedure OAExpReport(
        p_exp            IN   VARCHAR2,
        p_empid          IN   VARCHAR2,
        p_receipt_count      OUT NOCOPY  NUMBER,
        p_receipt_with_error OUT NOCOPY  NUMBER,
        p_error_type     OUT NOCOPY  VARCHAR2,
        p_return_status  OUT NOCOPY  VARCHAR2,
        p_msg_count      OUT NOCOPY  NUMBER,
        p_msg_data       OUT NOCOPY  VARCHAR2
        ) IS

  l_table                    AP_WEB_DISC_PKG.disc_prompts_table;

  l_receipt_with_error       NUMBER;
  l_receipt_with_warning     NUMBER;
  l_debug_info               VARCHAR2(300) := '';
  l_current_calling_sequence VARCHAR2(255) := 'OAExpReport';
  l_receipt_count            NUMBER;
  l_employee_name            PER_WORKFORCE_X.full_name%TYPE;
  l_targ_emp_id              number;
  l_employee_num             PER_WORKFORCE_X.employee_number%TYPE ;
  l_cost_center              VARCHAR2(150);

  l_IsSessionProjectEnabled VARCHAR2(1);
  Custom1_Array         AP_WEB_DFLEX_PKG.CustomFields_A;
  Custom2_Array         AP_WEB_DFLEX_PKG.CustomFields_A;
  Custom3_Array         AP_WEB_DFLEX_PKG.CustomFields_A;
  Custom4_Array         AP_WEB_DFLEX_PKG.CustomFields_A;
  Custom5_Array         AP_WEB_DFLEX_PKG.CustomFields_A;
  Custom6_Array         AP_WEB_DFLEX_PKG.CustomFields_A;
  Custom7_Array         AP_WEB_DFLEX_PKG.CustomFields_A;
  Custom8_Array         AP_WEB_DFLEX_PKG.CustomFields_A;
  Custom9_Array         AP_WEB_DFLEX_PKG.CustomFields_A;
  Custom10_Array        AP_WEB_DFLEX_PKG.CustomFields_A;
  Custom11_Array        AP_WEB_DFLEX_PKG.CustomFields_A;
  Custom12_Array        AP_WEB_DFLEX_PKG.CustomFields_A;
  Custom13_Array        AP_WEB_DFLEX_PKG.CustomFields_A;
  Custom14_Array        AP_WEB_DFLEX_PKG.CustomFields_A;
  Custom15_Array        AP_WEB_DFLEX_PKG.CustomFields_A;
  l_has_core_field_errors       BOOLEAN;
  l_has_custom_field_errors     BOOLEAN;
  l_report_header_info  AP_WEB_DFLEX_PKG.ExpReportHeaderRec;
  l_report_lines_info   AP_WEB_DFLEX_PKG.ExpReportLines_A;
  l_temp_errors         AP_WEB_DISC_PKG.Setup_error_stack;

  l_DataDefaultedUpdateable     BOOLEAN;
  l_emp_id                      AP_WEB_DB_HR_INT_PKG.empCurrent_employeeID;

  l_receipt_line_errors         AP_WEB_UTILITIES_PKG.receipt_error_stack;
  l_validate_receipt_errors     AP_WEB_UTILITIES_PKG.receipt_error_stack;
  l_parse_header_errors         AP_WEB_UTILITIES_PKG.expError;
  l_parse_receipt_errors        AP_WEB_UTILITIES_PKG.receipt_error_stack;
  l_errortype                   VARCHAR2(1) ;
  l_techstack                   VARCHAR2(1) := AP_WEB_DISC_PKG.C_NewStack;
  l_userId                      VARCHAR2(20):= null;
  l_temp_array                  OIE_PDM_NUMBER_T; -- bug 5358186

BEGIN
  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_OA_DISC_PKG', 'start OAExpReport');

  ------------------------------------------------------
  l_debug_info := 'Initalize global message table';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
  ------------------------------------------------------
  fnd_msg_pub.initialize;

  ------------------------------------------------------
  l_debug_info := 'Retrieve employee information';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
  ------------------------------------------------------
  -- Retrieve internal employee id
  l_targ_emp_id := p_empid;

  -- Retrieve employee information
  AP_WEB_UTILITIES_PKG.GetEmployeeInfo(l_employee_name,
                      l_employee_num,
                      l_cost_center,
                      l_targ_emp_id);

  -------------------------------------------------
  l_debug_info := 'get userid';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
  --------------------------------------------------
  AP_WEB_OA_MAINFLOW_PKG.GetUserID(p_empid, l_userId);

  ------------------------------------------------------
  l_debug_info := 'Initalize prompt array';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
  ------------------------------------------------------
  AP_WEB_DISC_PKG.ap_web_init_prompts_array(TO_NUMBER(l_userId), l_table, l_temp_errors);

  ------------------------------------------------------
  l_debug_info := 'Check for prompt array errors';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
  ------------------------------------------------------
  IF l_temp_errors.count > 0 THEN
    fnd_message.set_name('SQLAP','AP_WEB_DISC_ZERO_PROMPTS');
    fnd_msg_pub.add();
    p_error_type := AP_WEB_DISC_PKG.C_SetupError;
    return;
  END IF;

  ------------------------------------------------------
  l_debug_info := 'Get more employee information';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
  ------------------------------------------------------
  -- Determine whether project enabled

  AP_WEB_PROJECT_PKG.IsSessionProjectEnabled(
    p_empid, l_userId,
    l_IsSessionProjectEnabled);

  -- Get organization ID for employee if project enabled
  IF ( l_IsSessionProjectEnabled = C_Yes ) THEN
    l_emp_id := TO_NUMBER(p_empid);
    IF ( AP_WEB_DB_HR_INT_PKG.GetEmpOrgId(
                        l_emp_id,
                        l_report_header_info.expenditure_organization_id) <> TRUE ) THEN
      l_report_header_info.expenditure_organization_id := NULL;
    END IF;
  END IF;

  -------------------------------------------------------
  l_debug_info := 'parse exp report';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
  -------------------------------------------------------
  l_report_header_info.employee_id := p_empid;
  AP_WEB_DISC_PKG.ParseExpReport(
                 TO_NUMBER(l_userId), -- Bug 2242176, Employee FND user id
                 p_exp,
                 l_table,
                 l_cost_center,
                 l_IsSessionProjectEnabled,
                 l_report_header_info,
                 l_report_lines_info,
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
                 Custom15_Array,
                 l_DataDefaultedUpdateable,
                 l_parse_header_errors,
                 l_parse_receipt_errors,
                 l_errortype,
                 l_techstack
                );

  -------------------------------------------------------
  l_debug_info := 'add line numbers to parse errors';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
  -------------------------------------------------------
  AddLineNumbersToErrors (l_parse_header_errors, l_parse_receipt_errors);

  -- fnd_msg_pub.count_and_get() returns the number of error messages in the table.
  IF (l_errortype = AP_WEB_DISC_PKG.C_SetupError) THEN
    fnd_msg_pub.count_and_get(p_count => p_msg_count,
                              p_data  => p_msg_data);
    p_error_type := l_errortype;
    return;
  END IF;

  -- Bug 4064985 - Need to prevent the user to skip to review if there are any required
  -- segments in Header level descriptive flexfield
  AP_WEB_OA_DISC_PKG.ValidateHeaderDFF(
      TO_NUMBER(l_userId),
      l_report_header_info,
      l_parse_header_errors);

  -------------------------------------------------
  l_debug_info := 'validate receipt lines';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
  --------------------------------------------------
  l_receipt_count := TO_NUMBER(l_report_header_info.receipt_count);
  p_receipt_count := l_receipt_count;
  IF (l_receipt_count > 0 ) THEN

    AP_WEB_VALIDATE_UTIL.ValidateExpLines(
                         TO_NUMBER(l_userId),  -- bug 2242176, employee fnd user id
                         l_report_header_info,
                         l_report_lines_info,
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
                         Custom15_Array,
                         l_has_core_field_errors,
                         l_has_custom_field_errors,
                         l_validate_receipt_errors,
                         p_receipt_with_error,
                         l_IsSessionProjectEnabled,
			 NULL,
			 TRUE,
                         p_cust_meals_amount => l_temp_array,
                         p_cust_accommodation_amount => l_temp_array,
                         p_cust_night_rate_amount => l_temp_array,
                         p_cust_pdm_rate => l_temp_array );

    -- delete reference to temp array as this is used for per diem only
    -- disconnected solution currently doe snot support per diem
    -- deleting prevents inadvertent data corruption

    If l_temp_array IS NOT NULL THEN

	l_temp_array.delete; -- bug 5358186

    END IF;

    -------------------------------------------------------
    l_debug_info := 'Validate Foreign Currencies';
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
    -------------------------------------------------------
    -- 1966365: Checks whether foreign currencies have a rate of 1 or null
    AP_WEB_DISC_PKG.ValidateForeignCurrencies(l_report_header_info,
      l_report_lines_info, l_validate_receipt_errors);

    -------------------------------------------------------
    l_debug_info := 'Validate Required Fields';
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
    -------------------------------------------------------
    -- 2159879: Checks whether Required fields are present or not
    AP_WEB_OA_DISC_PKG.ValidateRequiredProjectTask(TO_NUMBER(p_empid),
      TO_NUMBER(l_userId),
      l_report_header_info,
      l_report_lines_info, l_validate_receipt_errors);

    -------------------------------------------------------
    l_debug_info := 'Check for Mileage / Per Diem / Policy';
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
    -------------------------------------------------------
    AP_WEB_OA_DISC_PKG.CheckForMileagePerDiemPolicy(
      TO_NUMBER(l_userId),
      l_report_header_info,
      l_report_lines_info, l_parse_header_errors, l_validate_receipt_errors);

    -------------------------------------------------------
    l_debug_info := 'Merge parse errors and validate errors';
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
    -------------------------------------------------------
    AP_WEB_UTILITIES_PKG.MergeErrorStacks(l_receipt_count, l_parse_receipt_errors,
      l_validate_receipt_errors, l_validate_receipt_errors);

    -------------------------------------------------------
    l_debug_info := 'calculate number of receipts with errors';
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
    -------------------------------------------------------
    --calculate the correct number of receipts with errors:
    p_receipt_with_error := AP_WEB_UTILITIES_PKG.NumOfReceiptWithError(
                               l_validate_receipt_errors );

    -------------------------------------------------------
    l_debug_info := 'add line numbers to validation errors';
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
    -------------------------------------------------------
    AddLineNumbersToErrors (l_parse_header_errors, l_validate_receipt_errors);
  END IF;

  -----------------------------------------
  l_debug_info := 'Set number of errors and error type';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
  ------------------------------------------
  fnd_msg_pub.count_and_get(p_count => p_msg_count,
                            p_data  => p_msg_data);

  IF p_msg_count > 0 THEN
    p_error_type := AP_WEB_DISC_PKG.C_DataError;
  ELSE

    -----------------------------------------
    l_debug_info := 'Check for warnings';
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
    ------------------------------------------
    CheckForReceiptWarnings (l_validate_receipt_errors);

    -----------------------------------------
    l_debug_info := 'Add warnings to message stack';
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
    ------------------------------------------
    fnd_msg_pub.count_and_get(p_count => p_msg_count,
                              p_data  => p_msg_data);

    IF p_msg_count > 0 THEN
      p_error_type := AP_WEB_DISC_PKG.C_Warning;
    ELSE
      p_error_type := AP_WEB_DISC_PKG.C_NoError;
    END IF;
  END IF;

  -----------------------------------------
  l_debug_info := 'Inserts into the Temporary Table';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
  ------------------------------------------
  OAInsertTempData(
           l_report_header_info,
           l_report_lines_info,
           l_validate_receipt_errors,
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
  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_OA_DISC_PKG', 'end OAExpReport');

 EXCEPTION
   WHEN OTHERS THEN
     IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE','OAExpReport');
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
       FND_MESSAGE.SET_TOKEN('PARAMETERS','');
     END IF;
     FND_MSG_PUB.ADD();
     p_error_type := AP_WEB_DISC_PKG.C_SetupError;
     FND_MSG_PUB.COUNT_AND_GET(p_count => p_msg_count,
                            p_data  => p_msg_data);

End OAExpReport;

/*
  Written By
    JMARY
  Purpose
    Procedure called by OAExpReport to insert into the Temporary Tables .
  Input
    p_report_header_info  IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
    p_report_lines_info   IN AP_WEB_DFLEX_PKG.ExpReportLines_A,
    p_receipt_errors      IN AP_WEB_UTILITIES_PKG.receipt_error_stack,
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
    Custom15_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A
  Output
    p_error_type
    p_return_status
    p_msg_count
    p_msg_data
  InputOutput
    None
  Assumptions
    None
  Date
    01-DEC-2000
*/

Procedure OAInsertTempData(
           p_report_header_info  IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
           p_report_lines_info   IN AP_WEB_DFLEX_PKG.ExpReportLines_A,
           p_receipt_errors      IN AP_WEB_UTILITIES_PKG.receipt_error_stack,
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
           Custom15_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A) IS

  l_debug_info varchar2(1000);
  P_AttributeCol             AP_WEB_PARENT_PKG.BigString_Array;
  l_item_description      AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_prompt;
  l_line_type_lookup_code AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_lineTypeLookupCode;
  l_require_receipt_amount NUMBER;
BEGIN
  -----------------------------------------
  l_debug_info := 'Delete existing data in temporary files';
  ------------------------------------------
  DELETE FROM ap_web_disc_headers_gt;
  DELETE FROM ap_web_disc_lines_gt;

  -----------------------------------------
  l_debug_info := 'Insert header into temporary table';
  ------------------------------------------
  INSERT INTO ap_web_disc_headers_gt (EMPLOYEE_ID,
     COST_CENTER,
     TEMPLATE_ID,
     PURPOSE,
     REIMBURSEMENT_CURRENCY_CODE,
     OVERRIDE_APPROVER_NAME
     ) VALUES(
     to_number(p_report_header_info.employee_id),
     p_report_header_info.cost_center,
     to_number(p_report_header_info.template_id),
     p_report_header_info.purpose,
     p_report_header_info.reimbursement_currency_code,
     p_report_header_info.override_approver_name);
  -----------------------------------------
  l_debug_info := 'Insert line info into temporary table';
  ------------------------------------------

  FOR i IN 1 .. (p_report_lines_info.COUNT-1) LOOP

    IF ( NOT AP_WEB_DB_EXPTEMPLATE_PKG.Get_ItemDesc_LookupCode(p_report_lines_info(i).parameter_id,
             l_item_description,l_line_type_lookup_code,l_require_receipt_amount) ) THEN
        EXIT;
    END IF;

    AP_WEB_PARENT_PKG.MapCustomArrayToColumn(i,
                              p_report_header_info,
                              p_report_lines_info,
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
                              Custom15_Array,
                              P_AttributeCol);

    INSERT INTO ap_web_disc_lines_gt (
                    START_DATE,
                    END_DATE,
                    DAILY_AMOUNT,
                    RECEIPT_AMOUNT,
                    RATE,
                    PARAMETER_ID,
                    CURRENCY_CODE,
                    GROUP_VALUE,
                    JUSTIFICATION,
                    RECEIPT_MISSING_FLAG,
                    PROJECT_NUMBER,
                    TASK_NUMBER,
		    AWARD_NUMBER,
		    AMOUNT_INCLUDES_TAX_FLAG,
		    TAX_CODE_ID,
		    VAT_CODE,
                    RECEIPT_ERRORS_FLAG,
		    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
                    ATTRIBUTE5,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15)
    VALUES(
              to_date(p_report_lines_info(i).start_date, AP_WEB_INFRASTRUCTURE_PKG.getDateFormat),
              to_date(p_report_lines_info(i).end_date, AP_WEB_INFRASTRUCTURE_PKG.getDateFormat),
              AP_WEB_DB_UTIL_PKG.CharToNumber(p_report_lines_info(i).daily_amount),
              AP_WEB_DB_UTIL_PKG.CharToNumber(p_report_lines_info(i).receipt_amount),
              to_number(p_report_lines_info(i).rate),
              to_number(p_report_lines_info(i).parameter_id),
              p_report_lines_info(i).currency_code,
              p_report_lines_info(i).group_value,
              p_report_lines_info(i).justification,
              p_report_lines_info(i).receipt_missing_flag,
              p_report_lines_info(i).project_number,
              p_report_lines_info(i).task_number,
	      p_report_lines_info(i).award_number,
              p_report_lines_info(i).amount_includes_tax,
              to_number(p_report_lines_info(i).taxId),
              p_report_lines_info(i).tax_code,
              decode(p_receipt_errors(i).error_text, null, C_No, C_Yes),
              l_item_description,
              P_AttributeCol(1),
              P_AttributeCol(2),
              P_AttributeCol(3),
              P_AttributeCol(4),
              P_AttributeCol(5),
              P_AttributeCol(6),
              P_AttributeCol(7),
              P_AttributeCol(8),
              P_AttributeCol(9),
              P_AttributeCol(10),
              P_AttributeCol(11),
              P_AttributeCol(12),
              P_AttributeCol(13),
              P_AttributeCol(14),
              P_AttributeCol(15));


  END LOOP;

 COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DELETE FROM ap_web_disc_headers_gt;
    DELETE FROM ap_web_disc_lines_gt;
    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE','OAExpReport');
    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    FND_MESSAGE.SET_TOKEN('PARAMETERS','');
    APP_EXCEPTION.RAISE_EXCEPTION;
END OAInsertTempData;


/*
  Written By
    KWIDJAJA
  Purpose
    Procedure called by OAExpReport to add receipt line numbers
    to Import errors.
  Input
    p_header_errors
    p_receipt_errors
  Output
    None
  InputOutput
    None
  Assumptions
    The application is WEB
  Date
   04-OCT-2001
*/
PROCEDURE AddLineNumbersToErrors (p_header_errors IN AP_WEB_UTILITIES_PKG.expError,
                             p_receipt_errors IN AP_WEB_UTILITIES_PKG.receipt_error_stack) IS

  v_index BINARY_INTEGER;
  v_array_index BINARY_INTEGER;
  v_error_text AP_WEB_UTILITIES_PKG.MSG_TEXT_TYPE%TYPE;
  v_error_text_array AP_WEB_UTILITIES_PKG.LongString_Array;

BEGIN
  -- Clear current global message stack
  FND_MSG_PUB.Delete_Msg;

  -- Repopulate header level errors
  IF (p_header_errors.COUNT > 0) THEN
    -- Loop through header errors
    v_index := p_header_errors.FIRST;
    LOOP
      --Check if there are any errors.
      IF (p_header_errors(v_index).text IS NOT NULL) THEN
        fnd_message.set_name('SQLAP', 'OIE_GENERIC_MESSAGE');
        fnd_message.set_token ('MESSAGE', p_header_errors(v_index).text);
        fnd_msg_pub.add();
      END IF;

      EXIT WHEN v_index = p_header_errors.LAST;
      v_index := p_header_errors.NEXT(v_index);
    END LOOP;
  END IF;

  -- Repopulate receipt line errors
  IF (p_receipt_errors.COUNT > 0) THEN
    -- Loop through error stack
    v_index := p_receipt_errors.FIRST;
    LOOP
      --Check if there are any errors.
      IF (p_receipt_errors(v_index).error_text IS NOT NULL) THEN
        -- Parse error text into array
        AP_WEB_UTILITIES_PKG.ArrayifyText(p_receipt_errors(v_index).error_text, v_error_text_array);
        v_array_index := v_error_text_array.FIRST;
        LOOP
          IF (v_error_text_array(v_array_index) IS NOT NULL) THEN
            v_error_text := v_error_text_array(v_array_index);

            -- Build line with error message
            fnd_message.set_name('SQLAP', 'OIE_RECEIPT_LINE_ERROR');
            fnd_message.set_token('LINE', to_char(v_index));
            fnd_message.set_token('ERROR_MESSAGE', v_error_text);

            fnd_msg_pub.add();
          END IF;

          EXIT WHEN v_array_index = v_error_text_array.LAST;
          v_array_index := v_error_text_array.NEXT(v_array_index);
        END LOOP;
      END IF;

      EXIT WHEN v_index = p_receipt_errors.LAST;
      v_index := p_receipt_errors.NEXT(v_index);
    END LOOP;
  END IF;
END AddLineNumbersToErrors;


/*
  Written By
    KWIDJAJA
  Purpose
    Procedure called by OAExpReport to add receipt line numbers
    to Import errors.
  Input
    p_header_errors
    p_receipt_errors
  Output
    None
  InputOutput
    None
  Assumptions
    The application is WEB
  Date
   04-OCT-2001
*/
PROCEDURE CheckForReceiptWarnings (p_receipt_errors IN AP_WEB_UTILITIES_PKG.receipt_error_stack) IS

  v_index BINARY_INTEGER;
  v_array_index BINARY_INTEGER;
  v_warning_text AP_WEB_UTILITIES_PKG.MSG_TEXT_TYPE%TYPE;
  v_warning_text_array AP_WEB_UTILITIES_PKG.LongString_Array;

BEGIN
  -- Clear current global message stack
  FND_MSG_PUB.Delete_Msg;

  -- Repopulate receipt line warnings
  IF (p_receipt_errors.COUNT > 0) THEN
    -- Loop through error stack
    v_index := p_receipt_errors.FIRST;
    LOOP
      --Check if there are any warnings.
      IF (p_receipt_errors(v_index).warning_text IS NOT NULL) THEN
        -- Parse warning text into array
        AP_WEB_UTILITIES_PKG.ArrayifyText(p_receipt_errors(v_index).warning_text, v_warning_text_array);
        v_array_index := v_warning_text_array.FIRST;
        LOOP
          IF (v_warning_text_array(v_array_index) IS NOT NULL) THEN
            v_warning_text := v_warning_text_array(v_array_index);

            -- Build line with error message
            fnd_message.set_name('SQLAP', 'OIE_GENERIC_MESSAGE');
            fnd_message.set_token('MESSAGE', v_warning_text);

            fnd_msg_pub.add();
          END IF;

          EXIT WHEN v_array_index = v_warning_text_array.LAST;
          v_array_index := v_warning_text_array.NEXT(v_array_index);
        END LOOP;
      END IF;

      EXIT WHEN v_index = p_receipt_errors.LAST;
      v_index := p_receipt_errors.NEXT(v_index);
    END LOOP;
  END IF;
END CheckForReceiptWarnings;

-- Bug: 6619166, Project and Task Not Validated in Disconnected Expense Entry Skip to Review.
PROCEDURE ValidateProjectTransaction(
		p_report_header_info		IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
	        p_report_lines_info		IN AP_WEB_DFLEX_PKG.ExpReportLines_A,
		p_base_curr_code		IN AP_WEB_DB_AP_INT_PKG.apSetUp_baseCurrencyCode,
		p_acct_raw_cost			IN NUMBER,
		p_def_exchng_rate_type		IN VARCHAR2,
		p_default_exchange_rate		IN NUMBER,
		p_vendor_id			IN NUMBER,
		p_ei_date			IN DATE,
		p_rec_count			IN NUMBER,
		p_msg_type			OUT NOCOPY VARCHAR2,
		p_return_error_message		OUT NOCOPY VARCHAR2,
		p_procedure_billable_flag	OUT NOCOPY VARCHAR2
	) IS
BEGIN
	AP_WEB_PROJECT_PKG.ValidatePATransaction(p_project_id  => p_report_lines_info(p_rec_count).project_id,
				    p_task_id            => p_report_lines_info(p_rec_count).task_id,
				    p_ei_date            => p_ei_date,
				    p_expenditure_type   => p_report_lines_info(p_rec_count).expenditure_type,
				    p_non_labor_resource => NULL,
				    p_person_id          => p_report_header_info.employee_id,
				    p_quantity           => NULL,
				    p_denom_currency_code=> p_report_header_info.reimbursement_currency_code,
				    p_acct_currency_code => p_base_curr_code,
				    p_denom_raw_cost     => p_report_lines_info(p_rec_count).amount,
				    p_acct_raw_cost      => p_acct_raw_cost,
				    p_acct_rate_type     => p_def_exchng_rate_type,
				    p_acct_rate_date     => p_report_lines_info(p_rec_count).end_date,
				    p_acct_exchange_rate => p_default_exchange_rate,
				    p_transfer_ei        => NULL,
				    p_incurred_by_org_id => p_report_header_info.expenditure_organization_id,
				    p_nl_resource_org_id => NULL,
				    p_transaction_source => NULL,
				    p_calling_module     => 'SelfService',
				    p_vendor_id          => p_vendor_id,
				    p_entered_by_user_id => NULL,
				    p_attribute_category => NULL,
				    p_attribute1         => NULL,
				    p_attribute2         => NULL,
				    p_attribute3         => NULL,
				    p_attribute4         => NULL,
				    p_attribute5         => NULL,
				    p_attribute6         => NULL,
				    p_attribute7         => NULL,
				    p_attribute8         => NULL,
				    p_attribute9         => NULL,
				    p_attribute10        => NULL,
				    p_attribute11        => NULL,
				    p_attribute12        => NULL,
				    p_attribute13        => NULL,
				    p_attribute14        => NULL,
				    p_attribute15        => NULL,
				    p_msg_type           => p_msg_type,
				    p_msg_data           => p_return_error_message,
				    p_billable_flag      => p_procedure_billable_flag);


END ValidateProjectTransaction;
/*
Written by:
  Kristian Widjaja
Purpose:
  To check whether fields such as project and task are required for these receipts
  Fix for bug 2159879
Input:
  p_report_header_info: Expense Report Header Information
  p_report_lines_info:  Expense Report Lines Information
Output:
  None
Input Output:
  p_receipts_errors: Receipt error stack
Assumption:
  The application is WEB.
  Receipts have already passed general parsing and validation.
Date:
  18-Jan-2002
*/
PROCEDURE ValidateRequiredProjectTask(
        p_employee_id         IN NUMBER,
        p_user_id             IN NUMBER,
        p_report_header_info  IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
        p_report_lines_info   IN AP_WEB_DFLEX_PKG.ExpReportLines_A,
        p_receipts_errors      IN OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack) IS

l_errors AP_WEB_UTILITIES_PKG.expError;
l_receipt_count BINARY_INTEGER;
l_debug_info    VARCHAR2(300) := '';
rec_count 	NUMBER := 1; /* receipt count */

l_pa_expenditure_type AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_paExpendituretype;
l_is_project_required   VARCHAR2(2);--Bug#6852373 - changed size to 2.
l_IsSessionProjectEnabled VARCHAR2(1);
l_return_error_message          VARCHAR2(5000);
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(5000);
l_base_curr_code		AP_WEB_DB_AP_INT_PKG.apSetUp_baseCurrencyCode;
l_ret				BOOLEAN;
l_def_exchng_rate_type		VARCHAR2(100);
ln_default_exchange_rate	NUMBER;
ln_acct_raw_cost                NUMBER;
ln_vendor_id                    NUMBER;
lv_msg_type                    VARCHAR2(2000);
lv_procedure_billable_flag     VARCHAR2(200);

BEGIN
  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_OA_DISC_PKG', 'start ValidateRequiredProjectTask');
  ------------------------------------------------------
  l_debug_info := 'Verify that the user is a projects user';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
  ------------------------------------------------------
  AP_WEB_PROJECT_PKG.IsSessionProjectEnabled(
    p_employee_id, p_user_id,
    l_IsSessionProjectEnabled);

  IF ( l_IsSessionProjectEnabled = C_No ) THEN
    RETURN;
  END IF;

  ------------------------------------------------------
  l_debug_info := 'Verify that the OIE:Enable Projects profile option is set to Required';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
  ------------------------------------------------------
  l_is_project_required := AP_WEB_UTILITIES_PKG.VALUE_SPECIFIC(
					  p_name    => 'AP_WEB_ENABLE_PROJECT_ACCOUNTING',
					  p_user_id => p_user_id,
					  p_resp_id => null,
					  p_apps_id => null);

  l_receipt_count := TO_NUMBER(p_report_header_info.receipt_count);
  -- Loop through all receipts
  FOR rec_count IN 1..l_receipt_count LOOP
    ------------------------------------------------------
    l_debug_info := 'Get the expenditure type for receipt '|| to_char(rec_count);
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
    ------------------------------------------------------
    AP_WEB_PROJECT_PKG.GetExpenditureTypeMapping(p_report_lines_info(rec_count).parameter_id,
      l_pa_expenditure_type);

    -- If the expenditure type is not null
    IF (l_pa_expenditure_type IS NOT NULL) THEN
      ------------------------------------------------------
      l_debug_info := 'Check whether project number and task number are null';
      AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
      ------------------------------------------------------

        -- Output error message if project number and task number is null
	-- AP_WEB_ENABLE_PROJECT_ACCOUNTING can take Y, N, RA, YA, R
	-- Either Project or Task Can be Null.
	-- Bug: 6978992, validate Award.
        IF ((l_is_project_required = 'R' OR l_is_project_required = 'RA') AND
	    (p_report_lines_info(rec_count).project_number IS NULL OR
            p_report_lines_info(rec_count).task_number IS NULL
	    OR (IsGrantsEnabled() AND p_report_lines_info(rec_count).award_number IS NULL))) THEN

	  IF (p_report_lines_info(rec_count).project_number IS NULL OR
            p_report_lines_info(rec_count).task_number IS NULL) THEN
		  fnd_message.set_name('SQLAP', 'AP_WEB_PA_PROJTASK_REQUIRED');
		  AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
		    fnd_message.get_encoded(),
		    AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
		    null,
		    rec_count);
	  END IF;
	  -- Award is required.
	  IF (IsGrantsEnabled() AND p_report_lines_info(rec_count).award_number IS NULL) THEN
		  fnd_message.set_name('SQLAP', 'OIE_AWARD_REQUIRED');
		  AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
		    fnd_message.get_encoded(),
		    AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
		    null,
		    rec_count);
	  END IF;
	ELSE
	    -- Either Project or task is missing, but not both.
	    IF ((p_report_lines_info(rec_count).project_number IS NOT NULL AND
	         p_report_lines_info(rec_count).task_number IS NULL) OR
		(p_report_lines_info(rec_count).task_number IS NOT NULL AND
 		 p_report_lines_info(rec_count).project_number IS NULL) OR
		 (IsGrantsEnabled() AND p_report_lines_info(rec_count).award_number is not null AND
		 (p_report_lines_info(rec_count).project_number IS NULL OR p_report_lines_info(rec_count).task_number IS NULL))) THEN


		fnd_message.set_name('SQLAP', 'AP_WEB_PA_PROJTASK_REQUIRED');
		l_return_error_message := fnd_message.get;
		AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
		l_return_error_message,
		AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
		'SQLAP',
		rec_count,
		AP_WEB_UTILITIES_PKG.C_PATCMessageCategory, AP_WEB_UTILITIES_PKG.IsMobileApp);

	    ELSE
		 -- 6619166, Projects and Tasks not validated in disconnected expense entry.
		 -- Need to validate only when Project or Task are entered.
		 IF (p_report_lines_info(rec_count).project_number IS NOT NULL
			OR p_report_lines_info(rec_count).task_number IS NOT NULL) THEN

                          -- Bug: 7176464
                          IF (AP_WEB_CUS_ACCTG_PKG.CustomValidateProjectDist(
                              p_report_lines_info(rec_count).report_line_id,
                              p_report_lines_info(rec_count).parameter_id,
                              p_report_lines_info(rec_count).project_id,
                              p_report_lines_info(rec_count).task_id,
                              p_report_lines_info(rec_count).award_id,
                              p_report_header_info.expenditure_organization_id,
                              p_report_lines_info(rec_count).amount,
                              l_return_error_message)) THEN
                             -- Custom Validate Project Allocations
                             IF (l_return_error_message is not null) THEN

                                AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
                                                 l_return_error_message,
                                                 AP_WEB_DFLEX_PKG.C_CustValidResMsgTypeError,
                                                 'PATC',
                                                 rec_count,
                                                 AP_WEB_UTILITIES_PKG.C_PATCMessageCategory, AP_WEB_UTILITIES_PKG.IsMobileApp);
                                AP_WEB_UTILITIES_PKG.MergeErrors(l_errors, p_receipts_errors);
                                -- Bug 7497991: commenting return to continue validations.
                                -- return;
                             END IF;
                          END IF;
			  IF (NOT AP_WEB_DB_AP_INT_PKG.GetVendorID(p_report_header_info.employee_id, ln_vendor_id)) THEN
				 ln_vendor_id := NULL;
			  END IF; /* GetVendorID */

			  l_ret := AP_WEB_DB_AP_INT_PKG.GetBaseCurrInfo(l_base_curr_code);
			  AP_WEB_DB_AP_INT_PKG.GetDefaultExchange(l_def_exchng_rate_type);
			  ln_default_exchange_rate := AP_UTILITIES_PKG.get_exchange_rate(l_base_curr_code,
										  p_report_header_info.reimbursement_currency_code,
										  l_def_exchng_rate_type,
										  p_report_lines_info(rec_count).end_date,
										 'ValidatePATransaction');
			  -- Calculate the receipt amount in the functional currency
			  ln_acct_raw_cost := NULL;
			  IF ln_default_exchange_rate IS NOT NULL AND ln_default_exchange_rate <> 0 THEN
			    ln_acct_raw_cost := AP_WEB_UTILITIES_PKG.OIE_ROUND_CURRENCY(p_report_lines_info(rec_count).amount/ln_default_exchange_rate, l_base_curr_code);
			  END IF;

			  lv_msg_type := null;
			  l_return_error_message := null;
			  lv_procedure_billable_flag := null;

			  ValidateProjectTransaction(p_report_header_info,
						     p_report_lines_info,
						     l_base_curr_code,
						     ln_acct_raw_cost,
						     l_def_exchng_rate_type,
						     ln_default_exchange_rate,
						     ln_vendor_id,
						     p_report_lines_info(rec_count).start_date,
						     rec_count,
						     lv_msg_type,
						     l_return_error_message,
						     lv_procedure_billable_flag);

			  if (l_return_error_message IS NOT NULL AND lv_msg_type = AP_WEB_DFLEX_PKG.C_CustValidResMsgTypeError) then
				       AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
					       l_return_error_message,
					       lv_msg_type,
					       'PATC',
					       rec_count,
					       AP_WEB_UTILITIES_PKG.C_PATCMessageCategory, AP_WEB_UTILITIES_PKG.IsMobileApp);
			  else
				 IF (IsGrantsEnabled() AND p_report_lines_info(rec_count).award_number is not null) THEN
					-- 6978992, AwardFundingProject call below is a workaround, GMS API fails with
   				        -- Exact Fetch returns more numberof rows error, when the award is not enabled for a project.
					IF(not  GMS_OIE_INT_PKG.AwardFundingProject(
					      p_report_lines_info(rec_count).award_id,
					      p_report_lines_info(rec_count).project_id,
					      p_report_lines_info(rec_count).task_id)) THEN

					  fnd_message.set_name('GMS', 'GMS_INVALID_AWARD');
					  l_return_error_message := fnd_message.get;
					  AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
					      l_return_error_message,
					      AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
					      'GMS',
					      rec_count,
					      AP_WEB_UTILITIES_PKG.C_PATCMessageCategory, AP_WEB_UTILITIES_PKG.IsMobileApp);

					-- Validate for the start expense date
					ELSIF(not GMS_OIE_INT_PKG.DoGrantsValidation(p_project_id  => p_report_lines_info(rec_count).project_id,
							       p_task_id     => p_report_lines_info(rec_count).task_id,
							       p_award_id    => p_report_lines_info(rec_count).award_id,
							       p_award_number => p_report_lines_info(rec_count).award_number,
							       p_expenditure_type   => p_report_lines_info(rec_count).expenditure_type,
							       p_expenditure_item_date => p_report_lines_info(rec_count).start_date,
							       p_calling_module => 'SelfService',
							       p_err_msg => l_return_error_message)) then
					 AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
					      l_return_error_message,
					      AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
					      'GMS',
					      rec_count,
					      AP_WEB_UTILITIES_PKG.C_PATCMessageCategory, AP_WEB_UTILITIES_PKG.IsMobileApp);
					ELSE
					  l_return_error_message := null;
					  lv_msg_type := null;
					END IF;
				 END IF;
			  end if;
			  if (l_return_error_message is null and p_report_lines_info(rec_count).end_date is not null) then

				   ValidateProjectTransaction(p_report_header_info,
						     p_report_lines_info,
						     l_base_curr_code,
						     ln_acct_raw_cost,
						     l_def_exchng_rate_type,
						     ln_default_exchange_rate,
						     ln_vendor_id,
						     p_report_lines_info(rec_count).end_date,
						     rec_count,
						     lv_msg_type,
						     l_return_error_message,
						     lv_procedure_billable_flag);

				  if (l_return_error_message IS NOT NULL AND lv_msg_type = AP_WEB_DFLEX_PKG.C_CustValidResMsgTypeError) then
					       AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
						       l_return_error_message,
						       lv_msg_type,
						       'PATC',
						       rec_count,
						       AP_WEB_UTILITIES_PKG.C_PATCMessageCategory, AP_WEB_UTILITIES_PKG.IsMobileApp);
				  else
				     IF (IsGrantsEnabled() AND p_report_lines_info(rec_count).award_number is not null) THEN
					IF(not  GMS_OIE_INT_PKG.AwardFundingProject(
					      p_report_lines_info(rec_count).award_id,
					      p_report_lines_info(rec_count).project_id,
					      p_report_lines_info(rec_count).task_id)) THEN

					  fnd_message.set_name('GMS', 'GMS_INVALID_AWARD');
					  l_return_error_message := fnd_message.get;
					  AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
					      l_return_error_message,
					      AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
					      'GMS',
					      rec_count,
					      AP_WEB_UTILITIES_PKG.C_PATCMessageCategory, AP_WEB_UTILITIES_PKG.IsMobileApp);
					-- Validate for the start expense date
					ELSIF(not GMS_OIE_INT_PKG.DoGrantsValidation(p_project_id  => p_report_lines_info(rec_count).project_id,
							       p_task_id     => p_report_lines_info(rec_count).task_id,
							       p_award_id    => p_report_lines_info(rec_count).award_id,
							       p_award_number => p_report_lines_info(rec_count).award_number,
							       p_expenditure_type   => p_report_lines_info(rec_count).expenditure_type,
							       p_expenditure_item_date => p_report_lines_info(rec_count).end_date,
							       p_calling_module => 'SelfService',
							       p_err_msg => l_return_error_message)) then
					 AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
					      l_return_error_message,
					      AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
					      'GMS',
					      1,
					      AP_WEB_UTILITIES_PKG.C_PATCMessageCategory, AP_WEB_UTILITIES_PKG.IsMobileApp);
					ELSE
					  l_return_error_message := null;
					  lv_msg_type := null;
					END IF;
				     END IF;
				  end if;
			  end if;
		  END IF;
	  END IF; -- Check for missing Project or Task
        END IF;
    ELSE
       IF (p_report_lines_info(rec_count).project_number IS NOT NULL OR
           p_report_lines_info(rec_count).task_number IS NOT NULL OR
           p_report_lines_info(rec_count).award_number IS NOT NULL) THEN
	       fnd_message.set_name('SQLAP', 'OIE_NON_PROJ_EXP');
	       l_return_error_message := fnd_message.get;
	       AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
	       l_return_error_message,
	       AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
		      'SQLAP',
		      rec_count,
		      AP_WEB_UTILITIES_PKG.C_PATCMessageCategory, AP_WEB_UTILITIES_PKG.IsMobileApp);
       END IF;
    END IF; -- Check expenditure type
  END LOOP;

  -- Merge errors with receipt error stack
  AP_WEB_UTILITIES_PKG.MergeErrors(l_errors, p_receipts_errors);

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_OA_DISC_PKG', 'end ValidateRequiredProjectTask');
END ValidateRequiredProjectTask;


/*
Written by:
  Kristian Widjaja
Purpose:
  To check whether a type has a rate Mileage or Per Diem schedule assigned to it.
Input:
  p_parameter_id: Expense Type
Output:
  Boolean
Input Output:
Assumption:
Date:
  12-Jul-2002
*/
Function  AreMPDRateSchedulesAssigned (p_parameter_id IN ap_expense_report_params.parameter_id%TYPE)
  RETURN  boolean IS

  v_numRows NUMBER := 0;
BEGIN
  -- This query returns rows if there exist a company policy id
  -- of category Mileage or Per Diem for the given parameter ID
  SELECT 1
  INTO   v_numRows
  FROM   dual
  WHERE exists
  (SELECT 1
   FROM   ap_expense_report_params expTypes
   WHERE  expTypes.company_policy_id IS NOT NULL
   AND    expTypes.category_code in ('MILEAGE', 'PER_DIEM')
   AND    trunc(sysdate) <= trunc(NVL(expTypes.end_date, sysdate))
   AND    expTypes.parameter_id = p_parameter_id);

  -- Return true if there were rows, return false otherwise.
  IF v_numRows = 1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
 WHEN no_data_found  THEN
  return(false);
 WHEN OTHERS THEN
  raise;

END AreMPDRateSchedulesAssigned;

/*
Written by:
  Kristian Widjaja
Purpose:
  To check whether a type has a rate Policy Compliance schedule assigned to it.
Input:
  p_parameter_id: Expense Type
Output:
  Boolean
Input Output:
Assumption:
Date:
  12-Jul-2002
*/
Function  ArePCRateSchedulesAssigned (p_parameter_id IN ap_expense_report_params.parameter_id%TYPE)
  RETURN  boolean IS

  v_numRows NUMBER := 0;
BEGIN
  -- This query returns rows if there exist any schedule options
  -- of category Accommodations, Airfare, Car Rental, or Meals for the given parameter ID
  SELECT 1
  INTO   v_numRows
  FROM   dual
  WHERE EXISTS
  (SELECT 1
   FROM   ap_expense_report_params expTypes
   WHERE  expTypes.company_policy_id IS NOT NULL
   AND expTypes.category_code in ('ACCOMMODATIONS', 'AIRFARE', 'CAR_RENTAL', 'MEALS')
   AND trunc(sysdate) <= trunc(NVL(expTypes.end_date, sysdate))
   AND expTypes.parameter_id = p_parameter_id);

  -- Return true if there were rows, return false otherwise.
  IF v_numRows = 1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
 WHEN no_data_found  THEN
  return(false);
 WHEN OTHERS THEN
  raise;
END ArePCRateSchedulesAssigned;

/*
Written by:
  Kristian Widjaja
Purpose:
  To check whether a type has a schedules with required or enabled expense fields
Input:
  p_parameter_id: Expense Type
Output:
  Boolean
Input Output:
Assumption:
Date:
  12-Jul-2002
*/
Function  CheckExpenseFields (p_parameter_id IN ap_expense_report_params.parameter_id%TYPE, p_reqd_enabled IN VARCHAR2)
  RETURN  boolean IS

  v_numRows NUMBER := 0;
BEGIN
    -- This query returns rows if there exist any required expense fields
    -- of category Accommodations, Airfare, Car Rental, or Meals for the given parameter ID
  SELECT 1
  INTO   v_numRows
  FROM   dual
  WHERE EXISTS
  (SELECT 1
   FROM ap_expense_report_params expTypes,
        ap_pol_cat_options catOptions
   WHERE
    ((catOptions.category_code = 'ACCOMMODATIONS'
       AND (END_DATE_FIELD = p_reqd_enabled
            OR MERCHANT_FIELD = p_reqd_enabled))
     OR
     (catOptions.category_code = 'AIRFARE'
       AND (MERCHANT_FIELD = p_reqd_enabled
            OR TICKET_CLASS_FIELD = p_reqd_enabled
            OR TICKET_NUMBER_FIELD = p_reqd_enabled
            OR LOCATION_FROM_FIELD = p_reqd_enabled
            OR LOCATION_TO_FIELD = p_reqd_enabled))
     OR
     (catOptions.category_code = 'CAR_RENTAL'
       AND (MERCHANT_FIELD = p_reqd_enabled))
     OR
     (catOptions.category_code = 'MEALS'
       AND (ATTENDEES_FIELD = p_reqd_enabled
            OR ATTENDEES_NUMBER_FIELD = p_reqd_enabled))
     OR
     (catOptions.category_code = 'MILEAGE'
       AND (DESTINATION_FIELD = p_reqd_enabled
            OR LICENSE_PLATE_FIELD = p_reqd_enabled))
     )
     AND expTypes.category_code = catOptions.category_code
     AND trunc(sysdate) <= trunc(NVL(expTypes.end_date, sysdate))
     AND expTypes.parameter_id = p_parameter_id);

  -- Return true if there were rows, return false otherwise.
  IF v_numRows = 1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
 WHEN no_data_found  THEN
  return(false);
 WHEN OTHERS THEN
  raise;
END CheckExpenseFields;

Function  AreExpenseFieldsRequired (p_parameter_id IN ap_expense_report_params.parameter_id%TYPE)
  RETURN  boolean IS

BEGIN
  return CheckExpenseFields(p_parameter_id, C_REQUIRED);
END AreExpenseFieldsRequired;

Function  AreExpenseFieldsEnabled (p_parameter_id IN ap_expense_report_params.parameter_id%TYPE)
  RETURN  boolean IS

BEGIN
  return CheckExpenseFields(p_parameter_id, C_ENABLED);
END AreExpenseFieldsEnabled;



/*
Written by:
  Kristian Widjaja
Purpose:
  To check whether a type requires Itemization
Input:
  p_parameter_id: Expense Type
Output:
  Boolean
Input Output:
Assumption:
Date:
  12-Jul-2002
*/
Function      IsItemizationRequired (p_parameter_id IN ap_expense_report_params.parameter_id%TYPE)
  RETURN  boolean IS

  v_numRows NUMBER := 0;
BEGIN
  -- This query returns rows if itemizations are required for the given parameter ID
  SELECT 1
  INTO   v_numRows
  FROM   dual
  WHERE EXISTS
  (SELECT 1
   FROM   ap_expense_report_params expTypes
   WHERE  expTypes.itemization_required_flag = C_Yes
          AND trunc(sysdate) <= trunc(NVL(expTypes.end_date, sysdate))
          AND expTypes.parameter_id = p_parameter_id);

  -- Return true if there were rows, return false otherwise.
  IF v_numRows = 1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
 WHEN no_data_found  THEN
  return(false);
 WHEN OTHERS THEN
  raise;
END IsItemizationRequired;

/*
Written by:
  Kristian Widjaja
Purpose:
  To check whether any Merchant fields are required per VAT setup
Input:
Output:
  Boolean
Input Output:
Assumption:
Date:
  12-Jul-2002
*/
Function AreMerchantFieldsRequired
  RETURN  boolean IS

  l_debug_info    VARCHAR2(300) := '';
  l_is_tax_enabled VARCHAR2(1);
  v_numRows NUMBER := 0;
BEGIN
  ------------------------------------------------------
  l_debug_info := 'Verify that the OIE:Enable Tax profile option is set to Yes';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
  ------------------------------------------------------
  AP_WEB_DFLEX_PKG.IsSessionTaxEnabled(l_is_tax_enabled);
  IF (l_is_tax_enabled = C_Yes) THEN
    -- This query returns rows if any VAT merchant fields are required in this org
    SELECT 1
    INTO   v_numRows
    FROM   dual
    WHERE EXISTS
    (SELECT 1
     FROM   ap_web_vat_setup
     WHERE
       ENABLED_CODE = C_Yes
       AND
       (ENABLE_MERCHANT_NAME_CODE = C_REQUIRED
         OR ENABLE_MERCHANT_RECEIPT_CODE = C_REQUIRED
         OR ENABLE_MERCHANT_TAX_REG_CODE = C_REQUIRED
         OR ENABLE_MERCHANT_TAXPAYER_CODE = C_REQUIRED
         OR ENABLE_MERCHANT_REFERENCE_CODE = C_REQUIRED));

    -- Return true if there were rows, return false otherwise
    IF v_numRows = 1 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
 WHEN no_data_found  THEN
  return(false);
 WHEN OTHERS THEN
  raise;
END AreMerchantFieldsRequired;

/*
Written by:
  Kristian Widjaja
Purpose:
  To check whether exchange rates are set up
Input:
Output:
  Boolean
Input Output:
Assumption:
Date:
  12-Jul-2002
*/
FUNCTION IsExchangeRateSetup
  RETURN  boolean IS

  v_numRows NUMBER := 0;
BEGIN
  -- This query returns rows if there exist any exchange rate validation in this org
  SELECT 1
  INTO   v_numRows
  FROM   dual
  WHERE EXISTS
  (SELECT 1
   FROM AP_POL_EXRATE_OPTIONS WHERE ENABLED = 'Y');

  -- Return true if there were rows, return false otherwise
  IF v_numRows = 1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
 WHEN no_data_found  THEN
  return(false);
 WHEN OTHERS THEN
  raise;
END IsExchangeRateSetup;

/*
Written by:
  Ron Langi
Purpose:
  To check whether Grants is enabled
Input:
Output:
  Boolean
Input Output:
Assumption:
Date:
  12-Jul-2002
*/
FUNCTION IsGrantsEnabled
  RETURN  boolean IS

BEGIN
  return GMS_OIE_INT_PKG.IsGrantsEnabled();
END IsGrantsEnabled;

/*
Written by:
  Ron Langi
Purpose:
  To check whether Line Level Accounting is enabled
Input:
Output:
  Boolean
Input Output:
Assumption:
Date:
  12-Jul-2002
*/
FUNCTION IsLineLevelAcctingEnabled
  RETURN  boolean IS

BEGIN
  return (NVL(fnd_profile.value('OIE_ENABLE_LINE_LEVEL_ACCOUNTING'),'N') = 'Y');
END IsLineLevelAcctingEnabled;

/*
Written by:
  Kristian Widjaja
Purpose:
  To check whether a report has any Per Diem, Mileage, or Policy related items
Input:
Output:
  Boolean
Input Output:
Assumption:
Date:
  12-Jul-2002
*/

/*Bug 2686210: Dont display the policy related error messages
               in the Import Page after clicking Skip To Review
               Button. Allow user to go to Review Page if the Expense
               report contains only Policy Violated items. Display the
               policy warning in Review Page.
	Deleted all occurances of l_PC_present.
	Have a diff with earlier version for knowing the occurance of the
	policy violations checking.
*/

PROCEDURE CheckForMileagePerDiemPolicy(
        p_user_id             IN NUMBER,
        p_report_header_info  IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
        p_report_lines_info   IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportLines_A,
        p_header_errors       IN OUT NOCOPY AP_WEB_UTILITIES_PKG.expError,
        p_receipts_errors     IN OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack) IS

  l_receipt_count BINARY_INTEGER;
  l_debug_info    VARCHAR2(300) := '';
  l_errors AP_WEB_UTILITIES_PKG.expError;
  rec_count 	NUMBER := 1; /* receipt count */

  l_MPD_present BOOLEAN := false; -- Keeps track whether the report contains Mileage / Per Diem header exceptions
  l_foreign_currency_present BOOLEAN := false; -- Keeps track whether foreign currencies exist.
  l_reimbursement_currency_code AP_WEB_DFLEX_PKG.expLines_currCode;
  l_receipt_required_amount AP_EXPENSE_REPORT_PARAMS.require_receipt_amount%TYPE;
  l_base_currency_code AP_WEB_DB_AP_INT_PKG.apSetUp_baseCurrencyCode;

BEGIN
  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_OA_DISC_PKG', 'start CheckForPerDiemMileagePolicy');
  -- Get reimbursement currency
  l_reimbursement_currency_code := p_report_header_info.reimbursement_currency_code;

  ------------------------------------------------------
  l_debug_info := 'Check whether there are any required VAT merchant fields';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
  ------------------------------------------------------

  ------------------------------------------------------
  l_debug_info := 'Go through all lines and check whether there are any Mileage, Per Diem, or Policy items';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
  ------------------------------------------------------

  l_receipt_count := TO_NUMBER(p_report_header_info.receipt_count);

  -- Loop through all receipts
  FOR rec_count IN 1..l_receipt_count LOOP
    ------------------------------------------------------
    l_debug_info := 'Check Mileage/Per Diem for receipt '|| to_char(rec_count);
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
    ------------------------------------------------------
    -- Only check if one or more monetary values is not null
    IF   p_report_lines_info(rec_count).daily_amount IS NOT null
      OR p_report_lines_info(rec_count).receipt_amount	IS NOT null
      OR p_report_lines_info(rec_count).amount IS NOT null THEN

      IF AreMPDRateSchedulesAssigned(p_report_lines_info(rec_count).parameter_id) THEN
        ------------------------------------------------------
        l_debug_info := 'Blank out monetary values.';
        AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
        ------------------------------------------------------
        p_report_lines_info(rec_count).daily_amount := null;
        p_report_lines_info(rec_count).receipt_amount	:= null;
        p_report_lines_info(rec_count).amount	:= null;

        l_MPD_present := TRUE;
      END IF;
    END IF;

    -- Do not perform this check anymore if a foreign currency has been found.
    IF (NOT l_foreign_currency_present
          AND (l_reimbursement_currency_code <>
               p_report_lines_info(rec_count).currency_code)) THEN
      ------------------------------------------------------
      l_debug_info := 'Found foreign currency in receipt '|| to_char(rec_count);
      AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_OA_DISC_PKG', l_debug_info);
      ------------------------------------------------------
      l_foreign_currency_present := TRUE;
    END IF;
  END LOOP;


  -- Display Milage / Per Diem error message, if applicable
  IF l_MPD_present THEN
   	      fnd_message.set_name('SQLAP','OIE_DISC_PDM_REMOVE_VALUES');
	      AP_WEB_UTILITIES_PKG.AddExpError(p_header_errors,
				       fnd_message.get_encoded(),
			 	       AP_WEB_UTILITIES_PKG.C_ErrorMessageType);
  END IF;

  -- Merge errors with receipt error stack
  AP_WEB_UTILITIES_PKG.MergeErrors(l_errors, p_receipts_errors);

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_OA_DISC_PKG', 'end CheckForPerDiemMileagePolicy');
END CheckForMileagePerDiemPolicy;

/*
Written by:
  skoukunt
Purpose:
  To check wh/ether there are any required segments in Header level descriptive flexfield
Input:
Output:
Input Output:
Assumption:
Date:
  20-Dec-2004
*/

PROCEDURE ValidateHeaderDFF(
        p_user_id             IN NUMBER,
        p_report_header_info  IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
        p_header_errors       IN OUT NOCOPY AP_WEB_UTILITIES_PKG.expError) IS

l_DFFEnabled    VARCHAR2(1);

BEGIN

  l_DFFEnabled := AP_WEB_UTILITIES_PKG.VALUE_SPECIFIC(
                              p_name              => 'AP_WEB_DESC_FLEX_NAME',
                              p_user_id           => p_user_id,
                              p_resp_id		  => FND_PROFILE.VALUE('RESP_ID'),
                              p_apps_id           => FND_PROFILE.VALUE('RESP_APPL_ID') );

  IF (nvl(l_DFFEnabled,'N') in ('B','H')) THEN

    FND_FLEX_DESCVAL.Set_Context_Value(p_report_header_info.template_name);
    FND_FLEX_DESCVAL.Set_Column_Value('Attribute1','');
    FND_FLEX_DESCVAL.Set_Column_Value('Attribute2','');
    FND_FLEX_DESCVAL.Set_Column_Value('Attribute3','');
    FND_FLEX_DESCVAL.Set_Column_Value('Attribute4','');
    FND_FLEX_DESCVAL.Set_Column_Value('Attribute5','');
    FND_FLEX_DESCVAL.Set_Column_Value('Attribute6','');
    FND_FLEX_DESCVAL.Set_Column_Value('Attribute7','');
    FND_FLEX_DESCVAL.Set_Column_Value('Attribute8','');
    FND_FLEX_DESCVAL.Set_Column_Value('Attribute9','');
    FND_FLEX_DESCVAL.Set_Column_Value('Attribute10','');
    FND_FLEX_DESCVAL.Set_Column_Value('Attribute11','');
    FND_FLEX_DESCVAL.Set_Column_Value('Attribute12','');
    FND_FLEX_DESCVAL.Set_Column_Value('Attribute13','');
    FND_FLEX_DESCVAL.Set_Column_Value('Attribute14','');
    FND_FLEX_DESCVAL.Set_Column_Value('Attribute15','');

    IF (NOT FND_FLEX_DESCVAL.Validate_Desccols('SQLAP',
				    'AP_EXPENSE_REPORT_HEADERS',
				    'I',
				    sysdate,
				    TRUE)) THEN

      fnd_message.set_name('SQLAP','OIE_ADDITIONAL_INFO_REQUIRED');
      --fnd_message.set_token ('MESSAGE', FND_FLEX_DESCVAL.error_message);
      AP_WEB_UTILITIES_PKG.AddExpError(p_header_errors,
				       fnd_message.get_encoded(),
			 	       AP_WEB_UTILITIES_PKG.C_ErrorMessageType);

    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('ValidateHeaderDFF');
    APP_EXCEPTION.RAISE_EXCEPTION;
END ValidateHeaderDFF;

/*========================================================================
 | PUBLIC PROCEDURE GetPolicyRateOptions
 |
 | DESCRIPTION
 |   Get the default_exchange_rates from ap_pol_exrate_options
 |   can add other fields to the record PolicyRateOptionsRec and select
 |   the select statement to get values for other fields
 |
 | PARAMETERS
 |  None
 |
 | MODIFICATION HISTORY
 | Date                  Author                     Description of Changes
 | 28-JUL-2003           Srihari Koukuntla          Created
 |
 *=======================================================================*/
PROCEDURE GetPolicyRateOptions(p_policyRateOptions OUT NOCOPY PolicyRateOptionsRec)
IS
BEGIN

  SELECT nvl(default_exchange_rates,'N')
  INTO   p_policyRateOptions.default_exchange_rates
  FROM   ap_pol_exrate_options WHERE enabled = 'Y';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_policyRateOptions.default_exchange_rates := 'N';

  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetPolicyRateOptions');
    APP_EXCEPTION.RAISE_EXCEPTION;
END GetPolicyRateOptions;

END AP_WEB_OA_DISC_PKG;

/
