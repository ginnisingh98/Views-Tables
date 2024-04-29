--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_EXPLINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_EXPLINE_PKG" AS
/* $Header: apwdbelb.pls 120.113.12010000.19 2010/06/09 12:03:48 rveliche ship $ */


--------------------------------------------------------------------------------
FUNCTION GetTrxIdsAndAmtsCursor(p_reportId 	IN  expLines_headerID,
				p_cc_cursor  OUT NOCOPY CCTrxnCursor)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
  l_debugInfo   varchar2(240);
BEGIN
  l_debugInfo := 'Get ids and amts from expense report lines';

  OPEN p_cc_cursor FOR
    SELECT credit_card_trx_id, amount
      FROM AP_EXPENSE_REPORT_LINES
      WHERE (REPORT_HEADER_ID = p_reportId)
       AND  (credit_card_trx_id is not null)
       AND  (itemization_parent_id IS NULL OR
             itemization_parent_id <> -1);

  return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('GetTrxIdAndAmt',
				    l_debugInfo);
      APP_EXCEPTION.RAISE_EXCEPTION;
      return FALSE;
END GetTrxIdsAndAmtsCursor;

--------------------------------------------------------------------------------
FUNCTION GetReportLineCursor(p_reportId 	IN  expLines_headerID,
			     p_line_cursor  OUT NOCOPY ReportLinesCursor)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
  l_date_format   VARCHAR2(20);
BEGIN

  l_date_format := ICX_SEC.getID( ICX_SEC.PV_DATE_FORMAT );
  OPEN p_line_cursor FOR
    SELECT TO_CHAR(WEB_PARAMETER_ID),      -- xtype
      TO_CHAR(AMOUNT),                     -- amount
      RECEIPT_MISSING_FLAG,                -- receiptmissing
      JUSTIFICATION,                       -- justification
      EXPENSE_GROUP,                       -- group
-- chiho:1283146:
      TO_CHAR(START_EXPENSE_DATE, l_date_format),  -- xdate1
      TO_CHAR(END_EXPENSE_DATE, l_date_format),    -- xdate2
      RECEIPT_CURRENCY_CODE,      -- currency
      TO_CHAR(RECEIPT_CONVERSION_RATE),    -- rate array
      TO_CHAR(DAILY_AMOUNT),               -- damount
      TO_CHAR(RECEIPT_CURRENCY_AMOUNT),    -- recamount
      AERL.MERCHANT_NAME,
      AERL.MERCHANT_DOCUMENT_NUMBER,
      AERL.MERCHANT_REFERENCE,
      AERL.MERCHANT_TAX_REG_NUMBER,
      AERL.MERCHANT_TAXPAYER_ID,
      AERL.COUNTRY_OF_SUPPLY,
      AERL.TAX_CODE_ID,
      AERL.TAX_CODE_OVERRIDE_FLAG,
      AERL.AMOUNT_INCLUDES_TAX_FLAG,
      AERL.CREDIT_CARD_TRX_ID,
      AERL.ATTRIBUTE1,
      AERL.ATTRIBUTE2,
      AERL.ATTRIBUTE3,
      AERL.ATTRIBUTE4,
      AERL.ATTRIBUTE5,
      AERL.ATTRIBUTE6,
      AERL.ATTRIBUTE7,
      AERL.ATTRIBUTE8,
      AERL.ATTRIBUTE9,
      AERL.ATTRIBUTE10,
      AERL.ATTRIBUTE11,
      AERL.ATTRIBUTE12,
      AERL.ATTRIBUTE13,
      AERL.ATTRIBUTE14,
      AERL.ATTRIBUTE15,
      AMOUNT_INCLUDES_TAX_FLAG,
      VAT_CODE,
      TO_CHAR(AERL.PROJECT_ID),
      AERL.PROJECT_NUMBER,
      TO_CHAR(AERL.TASK_ID),
      AERL.TASK_NUMBER,
      EXPENDITURE_TYPE,
      AERL.DISTRIBUTION_LINE_NUMBER
    FROM AP_EXPENSE_REPORT_LINES AERL
    WHERE REPORT_HEADER_ID = p_reportId
    ORDER BY AERL.DISTRIBUTION_LINE_NUMBER;
  return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('GetReportLineCursor');
      APP_EXCEPTION.RAISE_EXCEPTION;
      return FALSE;
END GetReportLineCursor;

PROCEDURE FetchReportLineCursor(p_ReportLinesCursor IN OUT NOCOPY ReportLinesCursor,
  p_expLines            IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportLines_A,
  Attribute_Array       IN OUT NOCOPY AP_WEB_PARENT_PKG.BigString_Array,
  p_ReceiptIndex        IN OUT NOCOPY NUMBER,
  p_Rate                OUT NOCOPY expLines_receiptConvRate,
  p_AmtInclTax          OUT NOCOPY expLines_amtInclTaxFlag,
  p_TaxName             OUT NOCOPY expLines_vatCode,
  p_ExpenditureType     OUT NOCOPY expLines_expendType)
IS
l_distribution_line_number number;
BEGIN
    FETCH p_ReportLinesCursor INTO
      p_expLines(p_ReceiptIndex).parameter_id,
      p_expLines(p_ReceiptIndex).amount,
      p_expLines(p_ReceiptIndex).receipt_missing_flag,
      p_expLines(p_ReceiptIndex).justification,
      p_expLines(p_ReceiptIndex).group_value,
      p_expLines(p_ReceiptIndex).start_date,
      p_expLines(p_ReceiptIndex).end_date,
      p_expLines(p_ReceiptIndex).currency_code,
      p_Rate,
      p_expLines(p_ReceiptIndex).daily_amount,
      p_expLines(p_ReceiptIndex).receipt_amount,
      p_expLines(p_ReceiptIndex).merchant,
      p_expLines(p_ReceiptIndex).merchantDoc,
      p_expLines(p_ReceiptIndex).taxReference,
      p_expLines(p_ReceiptIndex).taxRegNumber,
      p_expLines(p_ReceiptIndex).taxPayerId,
      p_expLines(p_ReceiptIndex).supplyCountry,
      p_expLines(p_ReceiptIndex).taxId,
      p_expLines(p_ReceiptIndex).taxOverrideFlag,
      p_expLines(p_ReceiptIndex).amount_includes_tax,
      p_expLines(p_ReceiptIndex).itemizeId,
      p_expLines(p_ReceiptIndex).cCardTrxnId,
      Attribute_Array(1),
      Attribute_Array(2),
      Attribute_Array(3),
      Attribute_Array(4),
      Attribute_Array(5),
      Attribute_Array(6),
      Attribute_Array(7),
      Attribute_Array(8),
      Attribute_Array(9),
      Attribute_Array(10),
      Attribute_Array(11),
      Attribute_Array(12),
      Attribute_Array(13),
      Attribute_Array(14),
      Attribute_Array(15),
      p_AmtInclTax,
      p_TaxName,
      p_expLines(p_ReceiptIndex).project_id,
      p_expLines(p_ReceiptIndex).project_number,
      p_expLines(p_ReceiptIndex).task_id,
      p_expLines(p_ReceiptIndex).task_number,
      p_ExpenditureType,
      l_distribution_line_number;

EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE','FetchReportLineCursor');
	APP_EXCEPTION.RAISE_EXCEPTION;

END FetchReportLineCursor;


--------------------------------------------------------------------------------
FUNCTION GetDisplayXpenseLinesCursor(
	p_report_header_id	IN	expLines_headerID,
	p_xpense_lines_cursor OUT NOCOPY DisplayXpenseLinesCursor)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
  -- get all expense lines
  OPEN p_xpense_lines_cursor FOR
    SELECT XL.receipt_missing_flag,
-- Called from GenerateExpClobLines for rendering old notifications for
-- expenses created prior to 11.5.10, will not be used for reports submitted
-- in  R12 hence decision was made not to tune these old queries.
	   to_char(XL.start_expense_date),
	   LPAD(to_char((nvl(XL.end_expense_date,XL.start_expense_date) -
				XL.start_expense_date)+1),4),
	   LPAD(to_char(XL.daily_amount),9),
	   XL.receipt_currency_code,
	   LPAD(to_char(XL.receipt_conversion_rate),5),
	   LPAD(to_char(XL.receipt_currency_amount),10),
           XL.amount,
	   nvl(XL.justification, '&' || 'nbsp'),
           nvl(XP.web_friendly_prompt, XP.prompt),
           PAP.segment1, --PAP.project_number,
           nvl(PAT.task_number, '&' || 'nbsp'),
           XL.credit_card_trx_id,
           XL.distribution_line_number dist_num,
	   nvl(GMS.award_number, '&' || 'nbsp'),
	   av.displayed_field,
	   XL.merchant_name
   FROM    ap_expense_report_params XP,
	   ap_expense_report_lines XL,
	   ap_lookup_codes LC,
           PA_PROJECTS_ALL PAP, -- AP_WEB_PA_PROJECTS_V PAP,          -- bug 1652647
           PA_TASKS PAT, -- AP_WEB_PA_PROJECTS_TASKS_V PAT,     -- bug 1652647
	   GMS_AWARDS GMS,
	   AP_POL_VIOLATIONS_V AV
   WHERE   XL.report_header_id = p_report_header_id
   AND     XL.project_id is not null
   AND     XL.task_id is not null
   AND     XL.web_parameter_id = XP.parameter_id
   AND     XL.line_type_lookup_code = LC.lookup_code
   AND     LC.lookup_type = 'INVOICE DISTRIBUTION TYPE'
   AND     XL.project_id = PAP.project_id
   AND     XL.project_id = PAT.project_id
   AND     XL.task_id = PAT.task_id
   AND     XL.award_id = GMS.award_id(+)
   AND     XL.report_header_id = AV.report_header_id(+)
   AND	   XL.distribution_line_number = AV.distribution_line_number(+)
   AND     (XL.itemization_parent_id is null or XL.itemization_parent_id = -1)
   UNION ALL
    SELECT XL.receipt_missing_flag,
	   to_char(XL.start_expense_date),
	   LPAD(to_char((nvl(XL.end_expense_date,XL.start_expense_date) - XL.start_expense_date)+1),4),
	   LPAD(to_char(XL.daily_amount),9),
	   XL.receipt_currency_code,
	   LPAD(to_char(XL.receipt_conversion_rate),5),
	   LPAD(to_char(XL.receipt_currency_amount),10),
           XL.amount,
	   XL.justification,
           nvl(XP.web_friendly_prompt, XP.prompt),
           NULL,
	   NULL,
           XL.credit_card_trx_id,
           XL.distribution_line_number dist_num,
	   NULL,
	   av.displayed_field,
	   XL.merchant_name
   FROM    ap_expense_report_params XP,
	   ap_expense_report_lines XL,
	   ap_lookup_codes LC,
	   AP_POL_VIOLATIONS_V AV
   WHERE   XL.report_header_id = p_report_header_id
   AND     XL.web_parameter_id = XP.parameter_id
   AND     XL.line_type_lookup_code = LC.lookup_code
   AND     LC.lookup_type = 'INVOICE DISTRIBUTION TYPE'
   AND     XL.project_id is null
   AND     XL.task_id is null
   AND	   XL.award_id is null
   AND     XL.report_header_id = AV.report_header_id(+)
   AND	   XL.distribution_line_number = AV.distribution_line_number(+)
   AND     (XL.itemization_parent_id is null or XL.itemization_parent_id = -1)
   ORDER BY dist_num;

   return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetDisplayXpenseLinesCursor');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetDisplayXpenseLinesCursor;

--------------------------------------------------------------------------------
FUNCTION GetDisplayXpenseLinesCursor(
	p_report_header_id	IN	expLines_headerID,
	p_is_cc_lines		IN	BOOLEAN,
	p_xpense_lines_cursor OUT NOCOPY DisplayXpenseLinesCursor)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
  l_personalParameterId         AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_paramID;
BEGIN
  if p_is_cc_lines then
    IF (NOT AP_WEB_DB_EXPTEMPLATE_PKG.GetPersonalParamID(l_personalParameterId)) THEN
      return FALSE;
    END IF; /* GetPersonalParamID */

  -- get credit card lines only
  OPEN p_xpense_lines_cursor FOR
      SELECT XL.receipt_missing_flag,
-- Called from GenerateExpClobLines for rendering old notifications for
-- expenses created prior to 11.5.10, will not be used for reports submitted
-- in  R12 hence decision was made not to tune these old queries.
	     to_char(XL.start_expense_date),
	     LPAD(to_char((nvl(XL.end_expense_date,XL.start_expense_date) -
				  XL.start_expense_date)+1),4),
	     LPAD(to_char(XL.daily_amount),9),
	     XL.receipt_currency_code,
	     LPAD(to_char(XL.receipt_conversion_rate),5),
	     LPAD(to_char(XL.receipt_currency_amount),10),
             XL.amount,
	     nvl(XL.justification, '&' || 'nbsp'),
             nvl(XP.web_friendly_prompt, XP.prompt),
             PAP.segment1, --PAP.project_number,
             nvl(PAT.task_number, '&' || 'nbsp'),
             XL.credit_card_trx_id,
             XL.distribution_line_number,
	     nvl(GMS.award_number, '&' || 'nbsp'),
	     av.displayed_field,
	     XL.merchant_name,
	     nvl(XL.flex_concatenated, XH.flex_concatenated),
	     XL.mileage_rate_adjusted_flag
     FROM    ap_expense_report_params XP,
	     ap_expense_report_lines XL,
	     ap_expense_report_headers XH,
	     ap_credit_card_trxns CC,
	     ap_lookup_codes LC,
             PA_PROJECTS_ALL PAP, -- AP_WEB_PA_PROJECTS_V PAP,          -- bug 1652647
             PA_TASKS PAT, -- AP_WEB_PA_PROJECTS_TASKS_V PAT     -- bug 1652647
	     GMS_AWARDS GMS,
	     AP_POL_VIOLATIONS_V AV
     WHERE   XL.report_header_id = p_report_header_id
     AND     XL.report_header_id = XH.report_header_id
     AND     XL.project_id is not null
     AND     XL.task_id is not null
     AND     XL.web_parameter_id = XP.parameter_id
     AND     XL.line_type_lookup_code = LC.lookup_code
     AND     LC.lookup_type = 'INVOICE DISTRIBUTION TYPE'
     AND     XL.project_id = PAP.project_id
     AND     XL.project_id = PAT.project_id
     AND     XL.task_id = PAT.task_id
     AND     XL.credit_card_trx_id is not null
     AND     CC.trx_id = XL.credit_card_trx_id
     AND     (CC.category is null OR CC.category NOT IN ('PERSONAL','DEACTIVATED'))--not a personal expense
     AND     XL.web_parameter_id <> l_personalParameterId           -- not a personal expense
     AND     XL.award_id = GMS.award_id(+)
   AND     XL.report_header_id = AV.report_header_id(+)
   AND	   XL.distribution_line_number = AV.distribution_line_number(+)
     AND     (XL.itemization_parent_id is null or XL.itemization_parent_id = -1)
     UNION ALL
      SELECT XL.receipt_missing_flag,
	     to_char(XL.start_expense_date),
	     LPAD(to_char((nvl(XL.end_expense_date,XL.start_expense_date) - XL.start_expense_date)+1),4),
	     LPAD(to_char(XL.daily_amount),9),
	     XL.receipt_currency_code,
	     LPAD(to_char(XL.receipt_conversion_rate),5),
	     LPAD(to_char(XL.receipt_currency_amount),10),
             XL.amount,
	     XL.justification,
             nvl(XP.web_friendly_prompt, XP.prompt),
             NULL,
	     NULL,
             XL.credit_card_trx_id,
             XL.distribution_line_number,
	     NULL,
	     av.displayed_field,
	     XL.merchant_name,
	     nvl(XL.flex_concatenated, XH.flex_concatenated),
	     XL.mileage_rate_adjusted_flag
     FROM    ap_expense_report_params XP,
	     ap_expense_report_lines XL,
	     ap_expense_report_headers XH,
	     ap_credit_card_trxns CC,
	     ap_lookup_codes LC,
	     AP_POL_VIOLATIONS_V AV
     WHERE   XL.report_header_id = p_report_header_id
     AND     XL.report_header_id = XH.report_header_id
     AND     XL.web_parameter_id = XP.parameter_id
     AND     XL.line_type_lookup_code = LC.lookup_code
     AND     LC.lookup_type = 'INVOICE DISTRIBUTION TYPE'
     AND     XL.project_id is null
     AND     XL.task_id is null
     AND     XL.credit_card_trx_id is not null
     AND     CC.trx_id = XL.credit_card_trx_id
     AND     (CC.category is null OR CC.category NOT IN ('PERSONAL','DEACTIVATED'))--not a personal expense
     AND     XL.web_parameter_id <> l_personalParameterId           -- not a personal expense
     AND     XL.award_id is NULL
     AND     XL.report_header_id = AV.report_header_id(+)
     AND     XL.distribution_line_number = AV.distribution_line_number(+)
     AND     (XL.itemization_parent_id is null or XL.itemization_parent_id = -1)
     ORDER BY 14;
  else
    -- get cash lines only
    OPEN p_xpense_lines_cursor FOR
      SELECT XL.receipt_missing_flag,
	     to_char(XL.start_expense_date),
	     LPAD(to_char((nvl(XL.end_expense_date,XL.start_expense_date) -
				  XL.start_expense_date)+1),4),
	     LPAD(to_char(XL.daily_amount),9),
	     XL.receipt_currency_code,
	     LPAD(to_char(XL.receipt_conversion_rate),5),
	     LPAD(to_char(XL.receipt_currency_amount),10),
             XL.amount,
	     nvl(XL.justification, '&' || 'nbsp'),
             nvl(XP.web_friendly_prompt, XP.prompt),
             PAP.segment1, --PAP.project_number,
             nvl(PAT.task_number, '&' || 'nbsp'),
             XL.credit_card_trx_id,
             XL.distribution_line_number,
	     nvl(GMS.award_number, '&' || 'nbsp'),
	     av.displayed_field,
	     XL.merchant_name,
	     nvl(XL.flex_concatenated, XH.flex_concatenated),
	     XL.mileage_rate_adjusted_flag
     FROM    ap_expense_report_params XP,
	     ap_expense_report_lines XL,
	     ap_expense_report_headers XH,
	     ap_lookup_codes LC,
             PA_PROJECTS_ALL PAP, -- AP_WEB_PA_PROJECTS_V PAP,          -- bug 1652647
             PA_TASKS PAT, -- AP_WEB_PA_PROJECTS_TASKS_V PAT     -- bug 1652647
	     GMS_AWARDS GMS,
	     AP_POL_VIOLATIONS_V AV
     WHERE   XL.report_header_id = p_report_header_id
     AND     XL.report_header_id = XH.report_header_id
     AND     XL.project_id is not null
     AND     XL.task_id is not null
     AND     XL.web_parameter_id = XP.parameter_id
     AND     XL.line_type_lookup_code = LC.lookup_code
     AND     LC.lookup_type = 'INVOICE DISTRIBUTION TYPE'
     AND     XL.project_id = PAP.project_id
     AND     XL.project_id = PAT.project_id
     AND     XL.task_id = PAT.task_id
     AND     XL.credit_card_trx_id is null
     AND     XL.award_id = GMS.award_id(+)
     AND     XL.report_header_id = AV.report_header_id(+)
     AND     XL.distribution_line_number = AV.distribution_line_number(+)
     AND     (XL.itemization_parent_id is null or XL.itemization_parent_id = -1)
     UNION ALL
      SELECT XL.receipt_missing_flag,
	     to_char(XL.start_expense_date),
	     LPAD(to_char((nvl(XL.end_expense_date,XL.start_expense_date) - XL.start_expense_date)+1),4),
	     LPAD(to_char(XL.daily_amount),9),
	     XL.receipt_currency_code,
	     LPAD(to_char(XL.receipt_conversion_rate),5),
	     LPAD(to_char(XL.receipt_currency_amount),10),
             XL.amount,
	     XL.justification,
             nvl(XP.web_friendly_prompt, XP.prompt),
             NULL,
	     NULL,
             XL.credit_card_trx_id,
             XL.distribution_line_number,
	     NULL,
	     av.displayed_field,
	     XL.merchant_name,
	     nvl(XL.flex_concatenated, XH.flex_concatenated),
	     XL.mileage_rate_adjusted_flag
     FROM    ap_expense_report_params XP,
	     ap_expense_report_lines XL,
	     ap_expense_report_headers XH,
	     ap_lookup_codes LC,
	     AP_POL_VIOLATIONS_V av
     WHERE   XL.report_header_id = p_report_header_id
     AND     XL.report_header_id = XH.report_header_id
     AND     XL.web_parameter_id = XP.parameter_id
     AND     XL.line_type_lookup_code = LC.lookup_code
     AND     LC.lookup_type = 'INVOICE DISTRIBUTION TYPE'
     AND     XL.project_id is null
     AND     XL.task_id is null
     AND     XL.credit_card_trx_id is null
     AND     XL.award_id is null
     AND     XL.report_header_id = AV.report_header_id(+)
     AND     XL.distribution_line_number = AV.distribution_line_number(+)
     AND     (XL.itemization_parent_id is null or XL.itemization_parent_id = -1)
     ORDER BY 14;
  end if;

  return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetDisplayXpenseLinesCursor');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetDisplayXpenseLinesCursor;

--------------------------------------------------------------------------------
FUNCTION GetDisplayPersonalLinesCursor(
	p_report_header_id	IN	expLines_headerID,
	p_personal_lines_cursor OUT NOCOPY DisplayXpenseLinesCursor)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
  l_personalParameterId         AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_paramID;
BEGIN
  IF (NOT AP_WEB_DB_EXPTEMPLATE_PKG.GetPersonalParamID(l_personalParameterId)) THEN
    return FALSE;
  END IF; /* GetPersonalParamID */

  OPEN p_personal_lines_cursor FOR
    SELECT XL.receipt_missing_flag,
-- Called from GenerateExpClobLines for rendering old notifications for
-- expenses created prior to 11.5.10, will not be used for reports submitted
-- in  R12 hence decision was made not to tune these old queries.
	   to_char(XL.start_expense_date),
	   LPAD(to_char((nvl(XL.end_expense_date,XL.start_expense_date) -
				XL.start_expense_date)+1),4),
	   LPAD(to_char(XL.daily_amount),9),
	   XL.receipt_currency_code,
	   LPAD(to_char(XL.receipt_conversion_rate),5),
	   LPAD(to_char(XL.receipt_currency_amount),10),
           XL.amount,
	   nvl(XL.justification, '&' || 'nbsp'),
           nvl(XP.web_friendly_prompt, XP.prompt),
           PAP.segment1, --PAP.project_number,
           nvl(PAT.task_number, '&' || 'nbsp'),
           XL.credit_card_trx_id,
           XL.distribution_line_number,
           XL.MERCHANT_NAME --Bug 2942773
   FROM    ap_expense_report_params XP,
	   ap_expense_report_lines XL,
	   ap_credit_card_trxns CC,
	   ap_lookup_codes LC,
           PA_PROJECTS_ALL PAP, -- AP_WEB_PA_PROJECTS_V PAP,          -- bug 1652647
           PA_TASKS PAT -- AP_WEB_PA_PROJECTS_TASKS_V PAT     -- bug 1652647
   WHERE   XL.report_header_id = p_report_header_id
   AND     XL.project_id is not null
   AND     XL.task_id is not null
   AND     XL.web_parameter_id = XP.parameter_id
   AND     XL.line_type_lookup_code = LC.lookup_code
   AND     LC.lookup_type = 'INVOICE DISTRIBUTION TYPE'
   AND     XL.project_id = PAP.project_id
   AND     XL.project_id = PAT.project_id
   AND     XL.task_id = PAT.task_id
   AND     XL.credit_card_trx_id is not null
   AND     CC.trx_id = XL.credit_card_trx_id
   AND     (CC.category = 'PERSONAL' OR XL.web_parameter_id = l_personalParameterId)
   UNION ALL
    SELECT XL.receipt_missing_flag,
	   to_char(XL.start_expense_date),
	   LPAD(to_char((nvl(XL.end_expense_date,XL.start_expense_date) - XL.start_expense_date)+1),4),
	   LPAD(to_char(XL.daily_amount),9),
	   XL.receipt_currency_code,
	   LPAD(to_char(XL.receipt_conversion_rate),5),
	   LPAD(to_char(XL.receipt_currency_amount),10),
           XL.amount,
	   XL.justification,
           nvl(XP.web_friendly_prompt, XP.prompt),
           NULL,
	   NULL,
           XL.credit_card_trx_id,
           XL.distribution_line_number,
           XL.MERCHANT_NAME --Bug 2942773
   FROM    ap_expense_report_params XP,
	   ap_expense_report_lines XL,
	   ap_credit_card_trxns CC,
	   ap_lookup_codes LC
   WHERE   XL.report_header_id = p_report_header_id
   AND     XL.web_parameter_id = XP.parameter_id
   AND     XL.line_type_lookup_code = LC.lookup_code
   AND     LC.lookup_type = 'INVOICE DISTRIBUTION TYPE'
   AND     XL.project_id is null
   AND     XL.task_id is null
   AND     XL.credit_card_trx_id is not null
   AND     CC.trx_id = XL.credit_card_trx_id
   AND     (CC.category = 'PERSONAL' OR XL.web_parameter_id = l_personalParameterId)
   ORDER BY distribution_line_number;

   return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetDisplayPersonalLinesCursor');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetDisplayPersonalLinesCursor;

/**
* rlangi AUDIT
* Check to see if there are any line level audit issue
*/
--------------------------------------------------------------------------------
FUNCTION AnyAuditIssue(p_report_header_id IN  expLines_headerID)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
  l_temp VARCHAR2(1);
BEGIN

  SELECT 'Y'
  INTO   l_temp
  FROM   ap_expense_report_lines aerl
  WHERE  aerl.report_header_id = p_report_header_id
  AND    aerl.adjustment_reason_code is not null
  AND    rownum = 1;

  return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AnyAuditIssue');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END AnyAuditIssue;



/**
 * jrautiai ADJ Fix
 * Modified to fetch the cursor for both adjustments and shortpays, this was done
 * to group the logic together and to simplify it.
 */
--------------------------------------------------------------------------------
FUNCTION GetAdjustmentsCursor(p_report_header_id IN  expLines_headerID,
                              p_adjustment_type  IN  VARCHAR2,
			      p_cursor 		 OUT NOCOPY AdjustmentCursorType)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
  l_personalParameterId  AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_paramID;
  l_roundingParameterId  AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_paramID;
BEGIN
/**
 * Note the select statement needs to have the same number and type of columns in order for the reference cursor
 * to work. Currently the queries match except for where statement. Not using dynamic SQL here because there are
 * a lot of delimiters in the query and also the columns might be calculated differently for the cases in the
 * future.
 */

  /* jrautiai ADJ Fix Start */
  IF (NOT AP_WEB_DB_EXPTEMPLATE_PKG.GetPersonalParamID(l_personalParameterId)) THEN
    l_personalParameterId := fnd_api.G_MISS_NUM;
  END IF;

  IF (NOT AP_WEB_DB_EXPTEMPLATE_PKG.GetRoundingParamID(l_roundingParameterId)) THEN
    l_roundingParameterId := fnd_api.G_MISS_NUM;
  END IF;
  /* jrautiai ADJ Fix End */

  IF p_adjustment_type = 'ADJUSTMENT' THEN

    OPEN p_cursor FOR
      SELECT aerl.report_header_id,
             aerl.start_expense_date,
             aerl.amount,
             aerl.submitted_amount,
             (aerl.submitted_amount - aerl.amount) adjusted_amount,
             aerl.web_parameter_id,
             AP_WEB_AUDIT_UTILS.get_expense_type(aerl.web_parameter_id) expense_type_disp,
             aerl.justification,
             aerl.adjustment_reason_code,
             AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_LINE_ADJUSTMENT_REASONS',aerl.adjustment_reason_code) adjustment_reason_code_disp,
             AP_WEB_POLICY_UTILS.get_lookup_description('OIE_LINE_ADJUSTMENT_REASONS',aerl.adjustment_reason_code) adjustment_reason_description,
             aerl.adjustment_reason,
             DECODE(aerl.CREDIT_CARD_TRX_ID,
                    null,AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_AUDIT_YES_NO','N'),
                    AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_AUDIT_YES_NO','Y')) credit_card_expense_disp,
             DECODE(aerl.itemization_parent_id,
                    null,AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_AUDIT_YES_NO','N'),
                    AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_AUDIT_YES_NO','Y')) itemized_expense_disp
      FROM ap_expense_report_lines aerl
      WHERE  aerl.report_header_id in (select p_report_header_id from dual
                                       union
                                       select aerh1.report_header_id
                                       from ap_expense_report_headers_all aerh1
                                       where aerh1.SHORTPAY_PARENT_ID = p_report_header_id)
      AND    (itemization_parent_id is null OR itemization_parent_id = -1)
      AND    aerl.web_parameter_id <> l_roundingParameterId
      AND    aerl.amount <> NVL(aerl.submitted_amount,aerl.amount)
      ORDER BY aerl.distribution_line_number;

  ELSIF p_adjustment_type = 'AUDIT' THEN

    OPEN p_cursor FOR
      SELECT aerl.report_header_id,
             aerl.start_expense_date,
             aerl.amount,
             aerl.submitted_amount,
             (aerl.submitted_amount - aerl.amount) adjusted_amount,
             aerl.web_parameter_id,
             AP_WEB_AUDIT_UTILS.get_expense_type(aerl.web_parameter_id) expense_type_disp,
             aerl.justification,
             aerl.adjustment_reason_code,
             AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_LINE_ADJUSTMENT_REASONS',aerl.adjustment_reason_code) adjustment_reason_code_disp,
             AP_WEB_POLICY_UTILS.get_lookup_description('OIE_LINE_ADJUSTMENT_REASONS',aerl.adjustment_reason_code) adjustment_reason_description,
             aerl.adjustment_reason,
             DECODE(aerl.CREDIT_CARD_TRX_ID,
                    null,AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_AUDIT_YES_NO','N'),
                    AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_AUDIT_YES_NO','Y')) credit_card_expense_disp,
             DECODE(aerl.itemization_parent_id,
                    null,AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_AUDIT_YES_NO','N'),
                    AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_AUDIT_YES_NO','Y')) itemized_expense_disp
      FROM ap_expense_report_lines aerl
      WHERE  aerl.report_header_id = p_report_header_id
      AND    (itemization_parent_id is null OR itemization_parent_id = -1)
      AND    aerl.adjustment_reason_code is not null
      AND    aerl.web_parameter_id <> l_roundingParameterId
      ORDER BY aerl.distribution_line_number;

  ELSE
    OPEN p_cursor FOR
      SELECT aerl.report_header_id,
             aerl.start_expense_date,
             aerl.amount,
             aerl.submitted_amount,
             (aerl.submitted_amount - aerl.amount) adjusted_amount,
             aerl.web_parameter_id,
             AP_WEB_AUDIT_UTILS.get_expense_type(aerl.web_parameter_id) expense_type_disp,
             aerl.justification,
             aerl.adjustment_reason_code,
             AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_LINE_ADJUSTMENT_REASONS',aerl.adjustment_reason_code) adjustment_reason_code_disp,
             AP_WEB_POLICY_UTILS.get_lookup_description('OIE_LINE_ADJUSTMENT_REASONS',aerl.adjustment_reason_code) adjustment_reason_description,
             aerl.adjustment_reason,
             DECODE(aerl.CREDIT_CARD_TRX_ID,
                    null,AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_AUDIT_YES_NO','N'),
                    AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_AUDIT_YES_NO','Y')) credit_card_expense_disp,
             DECODE(aerl.itemization_parent_id,
                    null,AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_AUDIT_YES_NO','N'),
                    AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_AUDIT_YES_NO','Y')) itemized_expense_disp
      FROM ap_expense_report_lines aerl
      WHERE  aerl.report_header_id = p_report_header_id
      AND    (itemization_parent_id is null OR itemization_parent_id = -1)
      AND    aerl.web_parameter_id <> l_roundingParameterId
      ORDER BY aerl.distribution_line_number;
  END IF;

  return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetAdjustmentsCursor');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetAdjustmentsCursor;

/* This function was merged with the following functions:
   GetExpLineAcctTemplateCursor
   GetXpenseLineInfoForPATCCursor
   that selected columns from the same tables.
*/
--------------------------------------------------------------------------------
FUNCTION GetExpDistAcctCursor(p_exp_report_id 	IN  expLines_headerID,
			      p_cursor	 OUT NOCOPY XpenseLineAcctCursor)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
OPEN p_cursor FOR
    SELECT XL.distribution_line_number,
           XD.report_distribution_id,
           XL.start_expense_date,
           XD.amount,
           nvl(XP.web_friendly_prompt, XP.prompt) expense_type,
	   XL.credit_card_trx_id,
           XD.project_id,
           XD.task_id,
	   XD.award_id,
           XL.expenditure_item_date,
           XL.expenditure_type,
           XL.pa_quantity,
           XD.expenditure_organization_id,
           XL.web_parameter_id,
	   XL.adjustment_reason,
	   XP.flex_concactenated,
    	   XL.category_code,
           XL.attribute_category,
           XL.attribute1,
           XL.attribute2,
           XL.attribute3,
           XL.attribute4,
           XL.attribute5,
           XL.attribute6,
           XL.attribute7,
           XL.attribute8,
           XL.attribute9,
           XL.attribute10,
           XL.attribute11,
           XL.attribute12,
           XL.attribute13,
           XL.attribute14,
           XL.attribute15,
	   XD.cost_center,
	   XL.AP_VALIDATION_ERROR,
           XL.Report_Line_id
    FROM   ap_expense_report_params XP,
           ap_expense_report_lines  XL,
           ap_exp_report_dists XD
    WHERE  XL.report_header_id = p_exp_report_id
    AND    XL.web_parameter_id = XP.parameter_id
    AND    XD.report_line_id(+) = XL.report_line_id
    AND    (XL.itemization_parent_id is null OR XL.itemization_parent_id <> -1)
    ORDER BY XL.distribution_line_number;

    return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetExpDistAcctCursor');
      APP_EXCEPTION.RAISE_EXCEPTION;
      return FALSE;
END GetExpDistAcctCursor;

-------------------------------------------------------------------
FUNCTION CalcNoReceiptsShortpayAmts(
				p_report_header_id 	IN  expLines_headerID,
				p_no_receipts_ccard_amt OUT NOCOPY NUMBER,
				p_no_receipts_emp_amt  OUT NOCOPY NUMBER
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
      SELECT sum(DECODE(aerl.credit_card_trx_id,null,0,aerl.amount)),
	       sum(DECODE(aerl.credit_card_trx_id, null, aerl.amount,0))
      INTO   p_no_receipts_ccard_amt, p_no_receipts_emp_amt
      FROM   ap_expense_report_lines aerl,
             ap_expense_report_headers aerh
      WHERE  aerl.report_header_id = p_report_header_id
      AND    aerh.report_header_id = aerl.report_header_id
      AND    nvl(aerh.receipts_status,'NONE') <>  AP_WEB_RECEIPT_MANAGEMENT_UTIL.C_STATUS_WAIVED
      AND    nvl(aerl.receipt_required_flag, 'N') = 'Y'
      AND    nvl(aerl.receipt_verified_flag, 'N') = 'N'
      AND    nvl(aerl.policy_shortpay_flag, 'N') = 'N';

	return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_no_receipts_ccard_amt:= 0;
    p_no_receipts_emp_amt:= 0;
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('CalcNoReceiptsShortpayAmts');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END CalcNoReceiptsShortpayAmts;


-------------------------------------------------------------------
FUNCTION CalcNoReceiptsPersonalTotal(p_report_header_id IN expLines_headerID,
				     p_personal_total   OUT NOCOPY NUMBER
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
      	 SELECT nvl(sum(erl.amount),0)
      	 INTO   p_personal_total
      	 FROM   ap_expense_report_lines erl,
  	        ap_expense_report_headers aerh,
      		ap_credit_card_trxns cct
      	 WHERE  erl.report_header_id = p_report_header_id
         AND    aerh.report_header_id = erl.report_header_id
         AND    nvl(aerh.receipts_status,'NONE') <>  AP_WEB_RECEIPT_MANAGEMENT_UTIL.C_STATUS_WAIVED
      	 AND    nvl(erl.receipt_required_flag, 'N') = 'Y'
      	 AND    nvl(erl.receipt_verified_flag, 'N') = 'N'
      	 AND    nvl(erl.policy_shortpay_flag, 'N') = 'N'
      	 AND    erl.credit_card_trx_id = cct.trx_id
      	 AND    cct.category = 'PERSONAL';

	return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_personal_total:= 0;
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('CalcNoReceiptsPersonalTotal');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END CalcNoReceiptsPersonalTotal;

-------------------------------------------------------------------
FUNCTION CalculatePolicyShortpayAmts(
		p_report_header_id 	IN  expLines_headerID,
		p_policy_ccard_amt OUT NOCOPY NUMBER,
		p_policy_emp_amt  OUT NOCOPY NUMBER,
		p_policy_shortpay_total OUT NOCOPY NUMBER
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
      --bug 5518553 : exclude itemization parent line
      SELECT sum(DECODE(credit_card_trx_id, null,amount,0)), sum(DECODE(credit_card_trx_id, null,0,amount))
      INTO   p_policy_emp_amt, p_policy_ccard_amt
      FROM   ap_expense_report_lines
      WHERE  report_header_id = P_report_header_id
      AND    nvl(policy_shortpay_flag, 'N') = 'Y'
      AND    (itemization_parent_id is null OR itemization_parent_id <> -1);

      p_policy_shortpay_total := p_policy_ccard_amt + p_policy_emp_amt;

     RETURN true;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_policy_ccard_amt:= 0;
    p_policy_emp_amt:= 0;
    p_policy_shortpay_total := 0;
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('CalculatePolicyShortpayAmts');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END CalculatePolicyShortpayAmts;

-------------------------------------------------------------------
FUNCTION GetReceiptMissingTotal(p_report_header_id 	IN  expLines_headerID,
				p_sum_missing_receipts OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
      -- bug 5518553 : exclude itemization parent line
      SELECT sum(amount)
      INTO   p_sum_missing_receipts
      FROM   ap_expense_report_lines
      WHERE  report_header_id = p_report_header_id
      AND    amount >= 0
      AND    receipt_missing_flag = 'Y'
      AND    (itemization_parent_id is null OR itemization_parent_id <> -1);

      RETURN true;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_sum_missing_receipts:= 0;
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetReceiptMissingTotal');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetReceiptMissingTotal;
-------------------------------------------------------------------
FUNCTION GetReceiptViolationsTotal(p_report_header_id 	IN  expLines_headerID,
				   p_sum_violations OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN

      select sum(daily_amount *
      LPAD(to_char((nvl(end_expense_date,start_expense_date) -
      start_expense_date)+1),4)) violation_total
      into   p_sum_violations
      from   ap_expense_report_lines_all
      where  report_header_id = p_report_header_id
      and    amount >= 0
      and    receipt_missing_flag <> 'Y'
      and    distribution_line_number in (
        select	distinct (distribution_line_number)
	from	ap_pol_violations
	where	report_header_id = p_report_header_id);

      RETURN true;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_sum_violations:= 0;
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetReceiptViolationsTotal');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetReceiptViolationsTotal;

-------------------------------------------------------------------
FUNCTION GetPersonalTotalOfExpRpt(p_report_header_id 	IN  AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
				  p_personal_total OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
-------------------------------------------------------------------
  l_personalParameterId         AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_paramID;
BEGIN

  IF (NOT AP_WEB_DB_EXPTEMPLATE_PKG.GetPersonalParamID(l_personalParameterId)) THEN
    return FALSE;
  END IF; /* GetPersonalParamID */

      -- used (itemization_parent_id is null OR itemization_parent_id <> -1)
      -- as the same condition is used in CalculateAmtsDue
      SELECT nvl(sum(amount),0)
      INTO   p_personal_total
      FROM   ap_expense_report_lines erl
      WHERE  erl.report_header_id = p_report_header_id
      AND    erl.web_parameter_id = l_personalParameterId
      AND    (itemization_parent_id is null OR itemization_parent_id <> -1);

      return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_personal_total:= 0;
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetPersonalTotalOfExpRpt');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetPersonalTotalOfExpRpt;

--------------------------------------------------------------------------------
FUNCTION CalculateAmtsDue(p_report_header_id 	IN  expLines_headerID,
			p_emp_amt 	 OUT NOCOPY NUMBER,
			p_ccard_amt 	 OUT NOCOPY NUMBER
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
    SELECT sum(DECODE(credit_card_trx_id, null,amount,0)),
	   sum(DECODE(credit_card_trx_id, null,0,amount))
    INTO   p_emp_amt, p_ccard_amt
    FROM   ap_expense_report_lines
    WHERE  report_header_id = p_report_header_id
       AND (itemization_parent_id is null OR itemization_parent_id <> -1);

    return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_emp_amt := 0;
    p_ccard_amt := 0;
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('CalculateAmtsDue');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END CalculateAmtsDue;

-------------------------------------------------------------------
FUNCTION GetNumReceiptRequiredLines(p_report_header_id IN  expLines_headerID,
				    p_num_req_receipts OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
    SELECT count(*)
    INTO   p_num_req_receipts
    FROM   ap_expense_report_lines
    WHERE  report_header_id = p_report_header_id
    AND    nvl(receipt_required_flag, 'N') = 'Y';

    RETURN true;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNumReceiptRequiredLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetNumReceiptRequiredLines;


-----------------------------------------------------------------------------------------------------
FUNCTION GetNumReceiptShortpaidLines(p_report_header_id 		IN expLines_headerID,
				     p_num_req_receipt_not_verified  OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
-----------------------------------------------------------------------------------------------------
BEGIN
      SELECT count(*)
      INTO   p_num_req_receipt_not_verified
      FROM   ap_expense_report_lines aerl,
             ap_expense_report_headers aerh
      WHERE  aerl.report_header_id = p_report_header_id
      AND    aerh.report_header_id = aerl.report_header_id
      AND    nvl(aerh.receipts_status,'NONE') <>  AP_WEB_RECEIPT_MANAGEMENT_UTIL.C_STATUS_WAIVED
      AND    (nvl(aerl.receipt_required_flag, 'N') = 'Y'  OR nvl(aerl.image_receipt_required_flag, 'N') = 'Y')
      AND    nvl(aerl.receipt_missing_flag, 'N') = 'N'
      AND    nvl(aerl.receipt_verified_flag, 'N') = 'N';

    RETURN true;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNumReceiptShortpaidLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetNumReceiptShortpaidLines;

-------------------------------------------------------------------
FUNCTION GetNumShortpaidLines(p_report_header_id IN  expLines_headerID,
			      p_count		 OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
      SELECT count(*)
      INTO   p_count
      FROM   ap_expense_report_lines aerl,
             ap_expense_report_headers aerh
      WHERE  aerl.report_header_id = p_report_header_id
      AND    (aerl.itemization_parent_id is null or aerl.itemization_parent_id = -1)
      AND    aerh.report_header_id = aerl.report_header_id
      AND    (nvl(aerl.policy_shortpay_flag,'N') = 'Y'
              OR (    ((nvl(aerl.receipt_required_flag, 'N') = 'Y' AND
                          nvl(aerh.receipts_status,'NONE') <>  AP_WEB_RECEIPT_MANAGEMENT_UTIL.C_STATUS_WAIVED)
                      OR (nvl(aerl.image_receipt_required_flag, 'N') = 'Y' AND
                          nvl(aerh.image_receipts_status,'NONE') <>  AP_WEB_RECEIPT_MANAGEMENT_UTIL.C_STATUS_WAIVED))
                  AND nvl(aerl.receipt_verified_flag, 'N') = 'N'
                  )
              );

    RETURN true;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNumShortpaidLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetNumShortpaidLines;

-------------------------------------------------------------------
FUNCTION GetNumJustReqdLines(p_report_header_id IN  expLines_headerID,
			p_num_req_receipts  OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
    SELECT count(*)
    INTO   p_num_req_receipts
    FROM   ap_expense_report_lines
    WHERE  report_header_id = p_report_header_id
    AND    nvl(justification_required_flag, 'V') = 'Y'
    AND    amount >= 0;

    RETURN true;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNumJustReqdLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetNumJustReqdLines;


-------------------------------------------------------------------
FUNCTION GetNumberOfExpLines(p_report_header_id IN  AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
 			     p_count	 OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
    SELECT count(*)
    INTO   p_count
    FROM   ap_expense_report_lines
    WHERE  report_header_id = p_report_header_id;

    return true;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNumberOfExpLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetNumberOfExpLines;

-------------------------------------------------------------------
FUNCTION GetNumCCLinesIncluded(p_report_header_id IN  expLines_headerID,
				p_crd_card_count  OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
    SELECT count(*)
    INTO   p_crd_card_count
    FROM   ap_expense_report_lines
    WHERE  report_header_id = p_report_header_id
    AND    credit_card_trx_id IS NOT NULL;

    return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNumCCLinesIncluded');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetNumCCLinesIncluded;


-------------------------------------------------------------------
FUNCTION GetNumberOfPersonalLines(p_report_header_id IN  expLines_headerID,
                             p_personal_count            OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
-------------------------------------------------------------------
  l_personalParameterId         AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_paramID;
BEGIN
  IF (NOT AP_WEB_DB_EXPTEMPLATE_PKG.GetPersonalParamID(l_personalParameterId)) THEN
    return FALSE;
  END IF; /* GetPersonalParamID */

  SELECT count(*)
  INTO   p_personal_count
  FROM    ap_expense_report_lines XL,
          ap_credit_card_trxns CC
  WHERE   XL.report_header_id = p_report_header_id
  AND     XL.credit_card_trx_id is not null
  AND     CC.trx_id = XL.credit_card_trx_id
  AND     (CC.category = 'PERSONAL' OR XL.web_parameter_id = l_personalParameterId);

  return true;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNumberOfPersonalLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetNumberOfPersonalLines;


--------------------------------------------------------------------------------
FUNCTION ContainsProjectRelatedLine(
	p_ReportHeaderID 	IN  expLines_headerID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
  V_Temp VARCHAR2(20);
BEGIN

    return AP_WEB_DB_EXPDIST_PKG.ContainsProjectRelatedDist(p_report_header_id => p_ReportHeaderID);

EXCEPTION
    	WHEN TOO_MANY_ROWS THEN
      		return TRUE;
	WHEN NO_DATA_FOUND THEN
		return FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'ContainProjectRelatedLine' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;
END ContainsProjectRelatedLine;


--------------------------------------------------------------------------------
FUNCTION ContainsNonProjectRelatedLine(
	p_ReportHeaderID 	IN  expLines_headerID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
  V_Temp 		VARCHAR2(20);
BEGIN

    return AP_WEB_DB_EXPDIST_PKG.ContainsNonProjectRelatedDist(p_report_header_id => p_ReportHeaderID);

EXCEPTION
    	WHEN TOO_MANY_ROWS THEN
      		return TRUE;
	WHEN NO_DATA_FOUND THEN
		return FALSE;
	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'ContainsNonProjectRelatedLine' );

    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;
END ContainsNonProjectRelatedLine;

--------------------------------------------------------------------------------
FUNCTION AddReportLines(
	p_xpense_lines			IN XpenseLineRec,
        p_expLines 			IN AP_WEB_DFLEX_PKG.ExpReportLineRec,
	P_AttributeCol 			IN AP_WEB_PARENT_PKG.BigString_Array,
	i				IN NUMBER
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
C_LinesDescFlexName     CONSTANT VARCHAR2(50) := 'AP_EXPENSE_REPORT_LINES';
l_context_enabled       VARCHAR2(1) := 'N';
l_flexfield	        FND_DFLEX.DFLEX_R;
l_flexinfo	        FND_DFLEX.DFLEX_DR;
BEGIN

  FND_DFLEX.Get_Flexfield('SQLAP',
                          C_LinesDescFlexname,
			  l_flexfield,
			  l_flexinfo);

  BEGIN
    SELECT 'Y' INTO l_context_enabled
    FROM   fnd_descr_flex_contexts_vl
    WHERE  application_id = l_flexfield.application_id
    AND    descriptive_flexfield_name = l_flexfield.flexfield_name
    AND    enabled_flag = 'Y'
    AND    global_flag = 'N'
    AND    descriptive_flex_context_code = p_xpense_lines.item_description;
  EXCEPTION
    WHEN OTHERS THEN
         null;
  END;

-- chiho: dealing with the case of having invalid parameter id(NULL) hereL:
IF ( p_expLines.parameter_id IS NOT NULL ) THEN
INSERT INTO AP_EXPENSE_REPORT_LINES
       (report_header_id,
        code_combination_id,
        web_parameter_id,
        set_of_books_id,
        amount,
        item_description,
        line_type_lookup_code,
        currency_code,
        receipt_missing_flag,
	receipt_required_flag,
        justification,
        expense_group,
        start_expense_date,
        end_expense_date,
        receipt_currency_code,
        receipt_conversion_rate,
        daily_amount,
        receipt_currency_amount,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        distribution_line_number,
	amount_includes_tax_flag,
	tax_code_id,
	vat_code,				-- Bug 1303470
	tax_code_override_flag,
	merchant_name,
	merchant_document_number,
	merchant_reference,
	merchant_tax_reg_number,
	merchant_taxpayer_id,
	country_of_supply,
	credit_card_trx_id,
	project_id,
	project_number,
	task_id,
        task_number,
        expenditure_organization_id,
        expenditure_type,
        expenditure_item_date,
        project_accounting_context,
	company_prepaid_invoice_id,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        report_line_id,
        org_id)
       SELECT
         p_xpense_lines.new_report_header_id,
         p_xpense_lines.code_combination_id,
         p_expLines.parameter_id,
         p_xpense_lines.set_of_books_id,
         p_expLines.amount,
         p_xpense_lines.item_description,
         p_xpense_lines.line_type_lookup_code,
         p_xpense_lines.reimbursement_currency_code,
         p_expLines.receipt_missing_flag,
	 p_xpense_lines.require_receipt_flag,
         AP_WEB_UTILITIES_PKG.RtrimMultiByteSpaces(p_expLines.justification),
         p_expLines.group_value,
         p_xpense_lines.date1_temp,
         p_xpense_lines.date2_temp,
         p_expLines.currency_code,
         p_xpense_lines.rate,
         p_expLines.daily_amount,
         p_expLines.receipt_amount,
         sysdate,
         icx_sec.getID(icx_sec.PV_USER_ID),		-- Bug 1733370
         sysdate,
         icx_sec.getID(icx_sec.PV_USER_ID),		-- Bug 1733370
         i,
	 p_expLines.amount_includes_tax,
	 p_expLines.taxId,
	 p_expLines.tax_code,				-- Bug 1303470
	 p_expLines.taxOverrideFlag,
	 p_expLines.merchant,
	 p_expLines.merchantDoc,
	 p_expLines.taxReference,
	 p_expLines.taxRegNumber,
	 p_expLines.taxPayerId,
	 p_expLines.supplyCountry,
	 p_expLines.cCardTrxnId,
	 to_number(p_expLines.project_id),
	 p_expLines.project_number,
	 to_number(p_expLines.task_id),
	 p_expLines.task_number,
	 DECODE(p_xpense_lines.IsReceiptProjectEnabled,'Y',
p_xpense_lines.expenditure_organization_id,NULL),
         p_expLines.expenditure_type,
         DECODE(p_xpense_lines.IsReceiptProjectEnabled,'Y',NVL(p_xpense_lines.date2_temp, p_xpense_lines.date1_temp),NULL),
         p_xpense_lines.IsReceiptProjectEnabled,
	 p_xpense_lines.company_prepaid_invoice_id, --company prepaid invoice id
         DECODE(l_context_enabled,'Y',p_xpense_lines.item_description,NULL),
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
         P_AttributeCol(15),
         ap_expense_report_lines_s.nextval,
         mo_global.get_current_org_id()
       FROM  ap_expense_report_params
       WHERE parameter_id = p_expLines.parameter_id;

ELSE -- parameter_id IS NULL
INSERT INTO AP_EXPENSE_REPORT_LINES
       (report_header_id,
        code_combination_id,
        web_parameter_id,
        set_of_books_id,
        amount,
        item_description,
        line_type_lookup_code,
        currency_code,
        receipt_missing_flag,
	receipt_required_flag,
        justification,
        expense_group,
        start_expense_date,
        end_expense_date,
        receipt_currency_code,
        receipt_conversion_rate,
        daily_amount,
        receipt_currency_amount,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        distribution_line_number,
	amount_includes_tax_flag,
	tax_code_id,
	tax_code_override_flag,
	merchant_name,
	merchant_document_number,
	merchant_reference,
	merchant_tax_reg_number,
	merchant_taxpayer_id,
	country_of_supply,
	credit_card_trx_id,
	project_id,
	project_number,
	task_id,
        task_number,
        expenditure_organization_id,
        expenditure_type,
        expenditure_item_date,
        project_accounting_context,
	company_prepaid_invoice_id,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        report_line_id,
        org_id )
       VALUES (
         p_xpense_lines.new_report_header_id,
         p_xpense_lines.code_combination_id,
         p_expLines.parameter_id,
         p_xpense_lines.set_of_books_id,
         p_expLines.amount,
         p_xpense_lines.item_description,
         p_xpense_lines.line_type_lookup_code,
         p_xpense_lines.reimbursement_currency_code,
         p_expLines.receipt_missing_flag,
	 p_xpense_lines.require_receipt_flag,
         AP_WEB_UTILITIES_PKG.RtrimMultiByteSpaces(p_expLines.justification),
         p_expLines.group_value,
         p_xpense_lines.date1_temp,
         p_xpense_lines.date2_temp,
         p_expLines.currency_code,
         p_xpense_lines.rate,
         p_expLines.daily_amount,
         p_expLines.receipt_amount,
         sysdate,
         icx_sec.getID(icx_sec.PV_USER_ID),		-- Bug 1733370
         sysdate,
         icx_sec.getID(icx_sec.PV_USER_ID),		-- Bug 1733370
         i,
	 p_expLines.amount_includes_tax,
	 p_expLines.taxId,
	 p_expLines.taxOverrideFlag,
	 p_expLines.merchant,
	 p_expLines.merchantDoc,
	 p_expLines.taxReference,
	 p_expLines.taxRegNumber,
	 p_expLines.taxPayerId,
	 p_expLines.supplyCountry,
	 p_expLines.cCardTrxnId,
	 to_number(p_expLines.project_id),
	 p_expLines.project_number,
	 to_number(p_expLines.task_id),
	 p_expLines.task_number,
	 DECODE(p_xpense_lines.IsReceiptProjectEnabled,'Y',
p_xpense_lines.expenditure_organization_id,NULL),
         p_expLines.expenditure_type,
         DECODE(p_xpense_lines.IsReceiptProjectEnabled,'Y',NVL(p_xpense_lines.date2_temp, p_xpense_lines.date1_temp),NULL),
         p_xpense_lines.IsReceiptProjectEnabled,
	 p_xpense_lines.company_prepaid_invoice_id, --company prepaid invoice id
         DECODE(l_context_enabled,'Y',p_xpense_lines.item_description,NULL),
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
         P_AttributeCol(15),
         ap_expense_report_lines_s.nextval,
         mo_global.get_current_org_id() );
END IF;

	RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AddReportLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END AddReportLines;


--------------------------------------------------------------------------------
FUNCTION AddPolicyShortPaidExpLines(
p_new_expense_report_id 	IN expLines_headerID,
p_orig_expense_report_id 	IN expLines_headerID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------

CURSOR ReportLines IS
  SELECT REPORT_LINE_ID, ITEMIZATION_PARENT_ID
  FROM   AP_EXPENSE_REPORT_LINES
  WHERE  REPORT_HEADER_ID = p_orig_expense_report_id
  AND    nvl(policy_shortpay_flag,'N') = 'Y'
  AND    nvl(itemization_parent_id,-1) = -1;/*Bug:6131435*/

CURSOR ItemizationChildLines(p_report_line_id in number) IS
  SELECT REPORT_LINE_ID
  FROM   AP_EXPENSE_REPORT_LINES
  WHERE  itemization_parent_id = p_report_line_id
  and report_header_id = p_orig_expense_report_id; -- Bug: 6705839, Performance Issue during shortpay

l_OrigReportLineID expLines_report_line_id;
l_itemization_parent_id   AP_EXPENSE_REPORT_LINES.itemization_parent_id%type;
i number;

BEGIN

  -- Find all lines associated with this report
  OPEN ReportLines;

  LOOP
    FETCH ReportLines into l_OrigReportLineID, l_itemization_parent_id;
    EXIT WHEN ReportLines%NOTFOUND;

    UPDATE AP_EXPENSE_REPORT_LINES_ALL
    SET report_header_id = p_new_expense_report_id,
        mileage_rate_adjusted_flag = C_Unchanged,
        last_update_date = sysdate,
        creation_date = sysdate
    WHERE report_line_id = l_OrigReportLineID;

    if (l_itemization_parent_id = -1) then
       for i in ItemizationChildLines(l_OrigReportLineID) loop

           UPDATE AP_EXPENSE_REPORT_LINES_ALL
           SET report_header_id = p_new_expense_report_id,
               mileage_rate_adjusted_flag = C_Unchanged,
               last_update_date = sysdate,
               creation_date = sysdate
           WHERE report_line_id = i.report_line_id;

           -- Move distribution lines associated with this child line
           AP_WEB_DB_EXPDIST_PKG.MoveDistributions(
             p_target_report_header_id => p_new_expense_report_id,
             p_source_report_line_id   => i.report_line_id,
             p_target_report_line_id   => i.report_line_id);

       end loop;
    end if;


    -- Move distribution lines associated with this line
    /* Bug# 6131435 : Parent Line will not be having any distribution lines
       So Distribution lines need not be moved for a parent line */
    /* Bug# 6632585 : Distribution lines of non-itemized lines should be moved */
    IF (l_itemization_parent_id <> -1 OR l_itemization_parent_id is NULL) THEN
       AP_WEB_DB_EXPDIST_PKG.MoveDistributions(
           p_target_report_header_id => p_new_expense_report_id,
           p_source_report_line_id   => l_OrigReportLineID,
           p_target_report_line_id   => l_OrigReportLineID);
    END IF;
  END LOOP;

  return TRUE;

EXCEPTION -- Block which encapsulates the delete and insert code
  WHEN TOO_MANY_ROWS OR NO_DATA_FOUND THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AddPolicyShortPaidExpLines','',
				  'AP_WEB_SAVESUB_DELETE_FAILED');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
  WHEN OTHERS THEN
    IF (SQLCODE = -00054) THEN
        -- Tried to obtain lock when deleting on an already locked row
        -- Get invoice prefix profile option, and trim if it is too long
        -- Get message stating delete failed
      AP_WEB_DB_UTIL_PKG.RaiseException('AddPolicyShortPaidExpLines','',
				    'AP_WEB_SAVESUB_LOCK_FAILED',
				    'V_ReportHeaderID = ' || p_orig_expense_report_id);
      APP_EXCEPTION.RAISE_EXCEPTION;
      return FALSE;
    END IF;
END AddPolicyShortPaidExpLines;

--------------------------------------------------------------------------------
FUNCTION AddUnverifiedShortpaidLines(
p_new_expense_report_id 	IN expLines_headerID,
p_orig_expense_report_id 	IN expLines_headerID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
CURSOR ReportLines IS
  SELECT REPORT_LINE_ID, ITEMIZATION_PARENT_ID
  FROM   ap_expense_report_lines aerl1
  WHERE  aerl1.report_header_id = p_orig_expense_report_id
  AND  nvl(itemization_parent_id,-1) = -1 /*Bug# 6131435*/
      /* jrautiai ADJ Fix
       * We need to move all lines in the itemization when one of them is missing a receipt
       */
    AND (
            (    aerl1.receipt_required_flag = 'Y'
             AND nvl(aerl1.receipt_verified_flag,'N') = 'N'
             AND nvl(aerl1.policy_shortpay_flag, 'N') = 'N'
	     AND nvl(aerl1.adjustment_reason_code, 'X') IN ('MISSING_RECEIPT', 'ORIGINAL_RECEIPTS_MISSING')
            )
            OR
            ( EXISTS (SELECT aerl2.report_header_id
                      FROM   ap_expense_report_lines aerl2
                      WHERE  aerl2.report_header_id = aerl1.report_header_id
                      AND   ((aerl1.credit_card_trx_id IS NULL AND aerl2.credit_card_trx_id is NULL AND aerl1.itemization_parent_id = -1 AND aerl2.itemization_parent_id = aerl1.report_line_id)
                              OR
                             (aerl1.credit_card_trx_id IS NOT NULL AND aerl2.credit_card_trx_id = aerl1.credit_card_trx_id)
                             )
                      AND   aerl2.receipt_required_flag = 'Y'
                      AND   nvl(aerl2.receipt_verified_flag,'N') = 'N'
                      AND   nvl(aerl2.policy_shortpay_flag, 'N') = 'N'
		      AND   nvl(aerl1.adjustment_reason_code, 'X') IN ('MISSING_RECEIPT', 'ORIGINAL_RECEIPTS_MISSING')
                      )
            )
          );


CURSOR ItemizationChildLines(p_report_line_id in number) IS
  SELECT REPORT_LINE_ID
  FROM   AP_EXPENSE_REPORT_LINES
  WHERE  itemization_parent_id = p_report_line_id
  and report_header_id = p_orig_expense_report_id; -- Bug: 6705839, Performance Issue during shortpay

l_OrigReportLineID expLines_report_line_id;
l_itemization_parent_id   AP_EXPENSE_REPORT_LINES.itemization_parent_id%type;
i number;

BEGIN

  -- Find all lines associated with this report
  OPEN ReportLines;

  LOOP
    FETCH ReportLines into l_OrigReportLineID, l_itemization_parent_id;
    EXIT WHEN ReportLines%NOTFOUND;


    UPDATE AP_EXPENSE_REPORT_LINES_all
    SET report_header_id = p_new_expense_report_id,
        mileage_rate_adjusted_flag = C_Unchanged,
        last_update_date = sysdate,
        creation_date = sysdate
    WHERE report_line_id = l_OrigReportLineID;

    if (l_itemization_parent_id = -1) then
       for i in ItemizationChildLines(l_OrigReportLineID) loop

           UPDATE AP_EXPENSE_REPORT_LINES_ALL
           SET report_header_id = p_new_expense_report_id,
               mileage_rate_adjusted_flag = C_Unchanged,
               last_update_date = sysdate,
               creation_date = sysdate
           WHERE report_line_id = i.report_line_id;

           -- Move distribution lines associated with this child line
           AP_WEB_DB_EXPDIST_PKG.MoveDistributions(
             p_target_report_header_id => p_new_expense_report_id,
             p_source_report_line_id   => i.report_line_id,
             p_target_report_line_id   => i.report_line_id);

       end loop;
    end if;


    -- Move distribution lines associated with this line
    /* Bug# 6131435 : Parent Line will not be having any distribution lines.
       So Distribution lines need not be moved for a parent line */
    /* Bug# 6632585 : Distribution lines of non-itemized lines should be moved */
    IF (l_itemization_parent_id <> -1 OR l_itemization_parent_id is NULL) THEN
        AP_WEB_DB_EXPDIST_PKG.MoveDistributions(
           p_target_report_header_id => p_new_expense_report_id,
           p_source_report_line_id   => l_OrigReportLineID,
           p_target_report_line_id   => l_OrigReportLineID);
    END IF;
  END LOOP;

  return TRUE;

EXCEPTION -- Block which encapsulates the delete and insert code
  WHEN TOO_MANY_ROWS OR NO_DATA_FOUND THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AddUnverifiedShortpaidLines','',
				  'AP_WEB_SAVESUB_DELETE_FAILED',
				  'V_ReportHeaderID = ' || p_orig_expense_report_id);
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
  WHEN OTHERS THEN
      IF (SQLCODE = -00054) THEN
        -- Tried to obtain lock when deleting on an already locked row
        -- Get invoice prefix profile option, and trim if it is too long
        -- Get message stating delete failed
    	AP_WEB_DB_UTIL_PKG.RaiseException('AddUnverifiedShortpaidLines','',
				      'AP_WEB_SAVESUB_LOCK_FAILED',
				      'V_ReportHeaderID = ' || p_orig_expense_report_id);
    	APP_EXCEPTION.RAISE_EXCEPTION;
    	return FALSE;
      END IF;
END AddUnverifiedShortpaidLines;

--------------------------------------------------------------------------------
FUNCTION AddUnverifiedImgShortpaidLines(
p_new_expense_report_id 	IN expLines_headerID,
p_orig_expense_report_id 	IN expLines_headerID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
CURSOR ReportLines IS
  SELECT REPORT_LINE_ID, ITEMIZATION_PARENT_ID
  FROM   ap_expense_report_lines aerl1
  WHERE  aerl1.report_header_id = p_orig_expense_report_id
  AND  nvl(itemization_parent_id,-1) = -1 /*Bug# 6131435*/
      /* jrautiai ADJ Fix
       * We need to move all lines in the itemization when one of them is missing a receipt
       */
    AND (
            (image_receipt_required_flag ='Y'
             AND nvl(aerl1.policy_shortpay_flag, 'N') = 'N'
	     AND nvl(receipt_verified_flag, 'N') = 'N'
	     AND aerl1.adjustment_reason_code IN ('MISSING_IMAGE_RECEIPTS','IMAGE_RECEIPTS_UNCLEAR')
            )
            OR
            ( EXISTS (SELECT aerl2.report_header_id
                      FROM   ap_expense_report_lines aerl2
                      WHERE  aerl2.report_header_id = aerl1.report_header_id
                      AND   ((aerl1.credit_card_trx_id IS NULL AND aerl2.credit_card_trx_id is NULL AND aerl1.itemization_parent_id = -1 AND aerl2.itemization_parent_id = aerl1.report_line_id)
                              OR
                             (aerl1.credit_card_trx_id IS NOT NULL AND aerl2.credit_card_trx_id = aerl1.credit_card_trx_id)
                             )
                      AND   image_receipt_required_flag = 'Y'
                      AND   nvl(aerl2.policy_shortpay_flag, 'N') = 'N'
		      AND   nvl(receipt_verified_flag, 'N') = 'N'
		      AND   aerl1.adjustment_reason_code IN ('MISSING_IMAGE_RECEIPTS','IMAGE_RECEIPTS_UNCLEAR')
                      )
            )
          );


CURSOR ItemizationChildLines(p_report_line_id in number) IS
  SELECT REPORT_LINE_ID
  FROM   AP_EXPENSE_REPORT_LINES
  WHERE  itemization_parent_id = p_report_line_id
  and report_header_id = p_orig_expense_report_id; -- Bug: 6705839, Performance Issue during shortpay

l_OrigReportLineID expLines_report_line_id;
l_itemization_parent_id   AP_EXPENSE_REPORT_LINES.itemization_parent_id%type;
i number;

BEGIN

  -- Find all lines associated with this report
  OPEN ReportLines;

  LOOP
    FETCH ReportLines into l_OrigReportLineID, l_itemization_parent_id;
    EXIT WHEN ReportLines%NOTFOUND;


    UPDATE AP_EXPENSE_REPORT_LINES_all
    SET report_header_id = p_new_expense_report_id,
        mileage_rate_adjusted_flag = C_Unchanged,
        last_update_date = sysdate,
        creation_date = sysdate
    WHERE report_line_id = l_OrigReportLineID;

    if (l_itemization_parent_id = -1) then
       for i in ItemizationChildLines(l_OrigReportLineID) loop

           UPDATE AP_EXPENSE_REPORT_LINES_ALL
           SET report_header_id = p_new_expense_report_id,
               mileage_rate_adjusted_flag = C_Unchanged,
               last_update_date = sysdate,
               creation_date = sysdate
           WHERE report_line_id = i.report_line_id;

           -- Move distribution lines associated with this child line
           AP_WEB_DB_EXPDIST_PKG.MoveDistributions(
             p_target_report_header_id => p_new_expense_report_id,
             p_source_report_line_id   => i.report_line_id,
             p_target_report_line_id   => i.report_line_id);

       end loop;
    end if;


    -- Move distribution lines associated with this line
    /* Bug# 6131435 : Parent Line will not be having any distribution lines.
       So Distribution lines need not be moved for a parent line */
    /* Bug# 6632585 : Distribution lines of non-itemized lines should be moved */
    IF (l_itemization_parent_id <> -1 OR l_itemization_parent_id is NULL) THEN
        AP_WEB_DB_EXPDIST_PKG.MoveDistributions(
           p_target_report_header_id => p_new_expense_report_id,
           p_source_report_line_id   => l_OrigReportLineID,
           p_target_report_line_id   => l_OrigReportLineID);
    END IF;
  END LOOP;

  return TRUE;

EXCEPTION -- Block which encapsulates the delete and insert code
  WHEN TOO_MANY_ROWS OR NO_DATA_FOUND THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AddUnverifiedShortpaidLines','',
				  'AP_WEB_SAVESUB_DELETE_FAILED',
				  'V_ReportHeaderID = ' || p_orig_expense_report_id);
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
  WHEN OTHERS THEN
      IF (SQLCODE = -00054) THEN
        -- Tried to obtain lock when deleting on an already locked row
        -- Get invoice prefix profile option, and trim if it is too long
        -- Get message stating delete failed
    	AP_WEB_DB_UTIL_PKG.RaiseException('AddUnverifiedShortpaidLines','',
				      'AP_WEB_SAVESUB_LOCK_FAILED',
				      'V_ReportHeaderID = ' || p_orig_expense_report_id);
    	APP_EXCEPTION.RAISE_EXCEPTION;
    	return FALSE;
      END IF;
END AddUnverifiedImgShortpaidLines;


--------------------------------------------------------------------------------
FUNCTION AddUnverifiedBtShortpaidLines(
p_new_expense_report_id 	IN expLines_headerID,
p_orig_expense_report_id 	IN expLines_headerID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
CURSOR ReportLines IS
  SELECT REPORT_LINE_ID, ITEMIZATION_PARENT_ID
  FROM   ap_expense_report_lines aerl1
  WHERE  aerl1.report_header_id = p_orig_expense_report_id
  AND  nvl(itemization_parent_id,-1) = -1 /*Bug# 6131435*/
      /* jrautiai ADJ Fix
       * We need to move all lines in the itemization when one of them is missing a receipt
       */
    AND (
            (receipt_required_flag = 'Y' AND image_receipt_required_flag = 'Y'
             AND nvl(aerl1.policy_shortpay_flag, 'N') = 'N'
	     AND nvl(receipt_verified_flag, 'N') = 'N'
	     AND aerl1.adjustment_reason_code IN ('ORIG_REQ_IMG_UNCLEAR','RECEIPTS_NOT_RECEIVED')
            )
            OR
            ( EXISTS (SELECT aerl2.report_header_id
                      FROM   ap_expense_report_lines aerl2
                      WHERE  aerl2.report_header_id = aerl1.report_header_id
                      AND   ((aerl1.credit_card_trx_id IS NULL AND aerl2.credit_card_trx_id is NULL AND aerl1.itemization_parent_id = -1 AND aerl2.itemization_parent_id = aerl1.report_line_id)
                              OR
                             (aerl1.credit_card_trx_id IS NOT NULL AND aerl2.credit_card_trx_id = aerl1.credit_card_trx_id)
                             )
                      AND   receipt_required_flag = 'Y' AND image_receipt_required_flag = 'Y'
                      AND   nvl(aerl2.policy_shortpay_flag, 'N') = 'N'
		      AND   nvl(receipt_verified_flag, 'N') = 'N'
		      AND   aerl1.adjustment_reason_code IN ('ORIG_REQ_IMG_UNCLEAR','RECEIPTS_NOT_RECEIVED')
                      )
            )
          );


CURSOR ItemizationChildLines(p_report_line_id in number) IS
  SELECT REPORT_LINE_ID
  FROM   AP_EXPENSE_REPORT_LINES
  WHERE  itemization_parent_id = p_report_line_id
  and report_header_id = p_orig_expense_report_id; -- Bug: 6705839, Performance Issue during shortpay

l_OrigReportLineID expLines_report_line_id;
l_itemization_parent_id   AP_EXPENSE_REPORT_LINES.itemization_parent_id%type;
i number;

BEGIN

  -- Find all lines associated with this report
  OPEN ReportLines;

  LOOP
    FETCH ReportLines into l_OrigReportLineID, l_itemization_parent_id;
    EXIT WHEN ReportLines%NOTFOUND;


    UPDATE AP_EXPENSE_REPORT_LINES_all
    SET report_header_id = p_new_expense_report_id,
        mileage_rate_adjusted_flag = C_Unchanged,
        last_update_date = sysdate,
        creation_date = sysdate
    WHERE report_line_id = l_OrigReportLineID;

    if (l_itemization_parent_id = -1) then
       for i in ItemizationChildLines(l_OrigReportLineID) loop

           UPDATE AP_EXPENSE_REPORT_LINES_ALL
           SET report_header_id = p_new_expense_report_id,
               mileage_rate_adjusted_flag = C_Unchanged,
               last_update_date = sysdate,
               creation_date = sysdate
           WHERE report_line_id = i.report_line_id;

           -- Move distribution lines associated with this child line
           AP_WEB_DB_EXPDIST_PKG.MoveDistributions(
             p_target_report_header_id => p_new_expense_report_id,
             p_source_report_line_id   => i.report_line_id,
             p_target_report_line_id   => i.report_line_id);

       end loop;
    end if;


    -- Move distribution lines associated with this line
    /* Bug# 6131435 : Parent Line will not be having any distribution lines.
       So Distribution lines need not be moved for a parent line */
    /* Bug# 6632585 : Distribution lines of non-itemized lines should be moved */
    IF (l_itemization_parent_id <> -1 OR l_itemization_parent_id is NULL) THEN
        AP_WEB_DB_EXPDIST_PKG.MoveDistributions(
           p_target_report_header_id => p_new_expense_report_id,
           p_source_report_line_id   => l_OrigReportLineID,
           p_target_report_line_id   => l_OrigReportLineID);
    END IF;
  END LOOP;

  return TRUE;

EXCEPTION -- Block which encapsulates the delete and insert code
  WHEN TOO_MANY_ROWS OR NO_DATA_FOUND THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AddUnverifiedShortpaidLines','',
				  'AP_WEB_SAVESUB_DELETE_FAILED',
				  'V_ReportHeaderID = ' || p_orig_expense_report_id);
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
  WHEN OTHERS THEN
      IF (SQLCODE = -00054) THEN
        -- Tried to obtain lock when deleting on an already locked row
        -- Get invoice prefix profile option, and trim if it is too long
        -- Get message stating delete failed
    	AP_WEB_DB_UTIL_PKG.RaiseException('AddUnverifiedShortpaidLines','',
				      'AP_WEB_SAVESUB_LOCK_FAILED',
				      'V_ReportHeaderID = ' || p_orig_expense_report_id);
    	APP_EXCEPTION.RAISE_EXCEPTION;
    	return FALSE;
      END IF;
END AddUnverifiedBtShortpaidLines;


--------------------------------------------------------------------------------
-- Called from AddCCReportLines and CopyCCItemizationChildLines
-- Name: InsertCCLine
-- Desc: Copies line from p_report_line_id to a new report p_new_report_header_id
--       with p_new_report_line_id, p_itemization_parent_id,
--       p_distribution_line_number, rest all data comes from p_report_line_id
-- Input:
--    p_new_report_header_id - report header id in the new line
--    p_report_line_id - copy from line with p_report_line_id
--    p_itemization_parent_id - itemization_parent_id in the new line
--    p_new_report_line_id - report_line_id in the new line
--    p_distribution_line_number - distribution_line_number in the new line
--------------------------------------------------------------------------------
PROCEDURE InsertCCLine(
  p_new_report_header_id      IN expLines_headerID,
  p_report_line_id            IN NUMBER,
  p_itemization_parent_id     IN NUMBER,
  p_new_report_line_id        IN NUMBER,
  p_distribution_line_number  IN NUMBER) IS

  l_clearning_ccid	NUMBER;
  l_org_id		AP_EXP_REPORT_DISTS.ORG_ID%TYPE;
  l_sequence_num    	AP_EXP_REPORT_DISTS.SEQUENCE_NUM%TYPE;
  l_last_updated_by	AP_EXP_REPORT_DISTS.LAST_UPDATED_BY%TYPE;
  l_created_by		AP_EXP_REPORT_DISTS.CREATED_BY%TYPE;
  l_segment1		AP_EXP_REPORT_DISTS.SEGMENT1%TYPE;
  l_segment2		AP_EXP_REPORT_DISTS.SEGMENT2%TYPE;
  l_segment3		AP_EXP_REPORT_DISTS.SEGMENT3%TYPE;
  l_segment4		AP_EXP_REPORT_DISTS.SEGMENT4%TYPE;
  l_segment5		AP_EXP_REPORT_DISTS.SEGMENT5%TYPE;
  l_segment6		AP_EXP_REPORT_DISTS.SEGMENT6%TYPE;
  l_segment7		AP_EXP_REPORT_DISTS.SEGMENT7%TYPE;
  l_segment8		AP_EXP_REPORT_DISTS.SEGMENT8%TYPE;
  l_segment9		AP_EXP_REPORT_DISTS.SEGMENT9%TYPE;
  l_segment10		AP_EXP_REPORT_DISTS.SEGMENT10%TYPE;
  l_segment11		AP_EXP_REPORT_DISTS.SEGMENT11%TYPE;
  l_segment12		AP_EXP_REPORT_DISTS.SEGMENT12%TYPE;
  l_segment13		AP_EXP_REPORT_DISTS.SEGMENT13%TYPE;
  l_segment14		AP_EXP_REPORT_DISTS.SEGMENT14%TYPE;
  l_segment15		AP_EXP_REPORT_DISTS.SEGMENT15%TYPE;
  l_segment16		AP_EXP_REPORT_DISTS.SEGMENT16%TYPE;
  l_segment17		AP_EXP_REPORT_DISTS.SEGMENT17%TYPE;
  l_segment18		AP_EXP_REPORT_DISTS.SEGMENT18%TYPE;
  l_segment19		AP_EXP_REPORT_DISTS.SEGMENT19%TYPE;
  l_segment20		AP_EXP_REPORT_DISTS.SEGMENT20%TYPE;
  l_segment21		AP_EXP_REPORT_DISTS.SEGMENT21%TYPE;
  l_segment22		AP_EXP_REPORT_DISTS.SEGMENT22%TYPE;
  l_segment23		AP_EXP_REPORT_DISTS.SEGMENT23%TYPE;
  l_segment24		AP_EXP_REPORT_DISTS.SEGMENT24%TYPE;
  l_segment25		AP_EXP_REPORT_DISTS.SEGMENT25%TYPE;
  l_segment26		AP_EXP_REPORT_DISTS.SEGMENT26%TYPE;
  l_segment27		AP_EXP_REPORT_DISTS.SEGMENT27%TYPE;
  l_segment28		AP_EXP_REPORT_DISTS.SEGMENT28%TYPE;
  l_segment29		AP_EXP_REPORT_DISTS.SEGMENT29%TYPE;
  l_segment30		AP_EXP_REPORT_DISTS.SEGMENT30%TYPE;
  l_preparer_modified_flag	AP_EXP_REPORT_DISTS.PREPARER_MODIFIED_FLAG%TYPE;
  l_amount		AP_EXP_REPORT_DISTS.AMOUNT%TYPE;
  l_cost_center		AP_EXP_REPORT_DISTS.COST_CENTER%TYPE;

  -- Bug: 6611357, Removed References to Project Information and updated dists
  -- table with nulls when creating a .1 report with BothPay


  CURSOR copy_dist(p_line_id NUMBER) IS
    SELECT DT.ORG_ID,
	   DT.SEQUENCE_NUM,
	   DT.LAST_UPDATED_BY,
	   DT.CREATED_BY,
	   DT.PREPARER_MODIFIED_FLAG,
	   DT.AMOUNT,
	   DT.COST_CENTER
      FROM AP_EXP_REPORT_DISTS_ALL DT,
	   AP_EXPENSE_REPORT_LINES_ALL DL
      WHERE DT.REPORT_LINE_ID = p_line_id
        AND DT.REPORT_LINE_ID = DL.REPORT_LINE_ID
        AND (DL.ITEMIZATION_PARENT_ID IS NULL
	     OR
	     DL.ITEMIZATION_PARENT_ID <> -1);

BEGIN

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPLINE_PKG', 'Start InsertCCLine');

  SELECT AP_WEB_DB_AP_INT_PKG.GetExpenseClearingCCID(credit_card_trx_id)
  INTO l_clearning_ccid
  FROM   ap_expense_report_lines erl
  WHERE  report_line_id = p_report_line_id;

  INSERT INTO ap_expense_report_lines
    	       (report_header_id,
    	   	last_update_date,
    	   	last_updated_by,
    	   	code_combination_id,
    	   	item_description,
    	   	set_of_books_id,
    	   	amount,
    	   	currency_code,
    	   	exchange_rate_type,
    	   	exchange_rate,
    	   	exchange_date,
    	   	line_type_lookup_code,
    	   	last_update_login,
    	   	creation_date,
    	   	created_by,
    	   	stat_amount,
    	   	distribution_line_number,
    	   	reference_1,
    	   	reference_2,
    	   	awt_group_id,
    	   	org_id,
    	   	justification_required_flag,
    	   	receipt_required_flag,
    	   	receipt_verified_flag,
    	   	receipt_missing_flag,
    	   	justification,
    	   	expense_group,
    	   	start_expense_date,
    	   	end_expense_date,
    	   	receipt_currency_code,
    	   	receipt_conversion_rate,
    	   	daily_amount,
    	   	receipt_currency_amount,
    	   	web_parameter_id,
   	   	adjustment_reason,
 		policy_shortpay_flag,
 		merchant_document_number,
 		merchant_name,
 		merchant_reference,
 		merchant_tax_reg_number,
 		merchant_taxpayer_id,
 		country_of_supply,
		company_prepaid_invoice_id,
		location_id,
		itemization_parent_id,
		func_currency_amt,
		ap_validation_error,
		category_code, -- bug 3311471
		flex_concatenated,
       		location,
                adjustment_reason_code, -- jrautiai ADJ Fix
                submitted_amount, -- jrautiai ADJ Fix
                report_line_id, -- LLA
                allocation_split_code --Bug#6870253
   	)
    	SELECT    p_new_report_header_id,
	   	  sysdate,
	   	  last_updated_by,
		  l_clearning_ccid,
	   	  item_description,
	   	  set_of_books_id,
	   	  amount,
	   	  currency_code,
	   	  exchange_rate_type,
	   	  exchange_rate,
	   	  exchange_date,
	   	  'MISCELLANEOUS',
	   	  last_update_login,
	   	  sysdate,
	   	  created_by,
	   	  stat_amount,
	   	  p_distribution_line_number AS distribution_line_number,
	   	  reference_1,
	   	  reference_2,
	   	  awt_group_id,
	   	  erl.org_id,
	   	  justification_required_flag,
	   	  receipt_required_flag,
	   	  receipt_verified_flag,
	   	  receipt_missing_flag,
	   	  justification,
	   	  expense_group,
	   	  start_expense_date,
	   	  end_expense_date,
	   	  receipt_currency_code,
	   	  receipt_conversion_rate,
	   	  daily_amount,
	   	  receipt_currency_amount,
	   	  web_parameter_id,
	   	  adjustment_reason,
 		  policy_shortpay_flag,
 		  merchant_document_number,
 		  merchant_name,
 		  erl.merchant_reference,
 		  merchant_tax_reg_number,
 		  merchant_taxpayer_id,
 		  country_of_supply,
		  company_prepaid_invoice_id,
		  location_id,
		  p_itemization_parent_id AS itemization_parent_id,
		  func_currency_amt,
		  ap_validation_error,
		  category_code, -- bug 3311471
		  flex_concatenated,
       		  location,
                  adjustment_reason_code, -- jrautiai ADJ Fix
                  submitted_amount, -- jrautiai ADJ Fix
                  p_new_report_line_id,
                  allocation_split_code --Bug#6870253
    FROM   ap_expense_report_lines erl
    WHERE  report_line_id = p_report_line_id;

    -- for bug 5288256: insert a new row in ap_exp_report_dists_all table
    SELECT GL.SEGMENT1, GL.SEGMENT2,GL.SEGMENT3,GL.SEGMENT4, GL.SEGMENT5, GL.SEGMENT6,
	   GL.SEGMENT7, GL.SEGMENT8,GL.SEGMENT9,GL.SEGMENT10,GL.SEGMENT11, GL.SEGMENT12,
	   GL.SEGMENT13, GL.SEGMENT14, GL.SEGMENT15, GL.SEGMENT16, GL.SEGMENT17, GL.SEGMENT18,
	   GL.SEGMENT19, GL.SEGMENT20, GL.SEGMENT21, GL.SEGMENT22, GL.SEGMENT23, GL.SEGMENT24,
	   GL.SEGMENT25, GL.SEGMENT26, GL.SEGMENT27, GL.SEGMENT28, GL.SEGMENT29, GL.SEGMENT30
      INTO l_segment1, l_segment2, l_segment3, l_segment4, l_segment5, l_segment6,
	   l_segment7, l_segment8, l_segment9, l_segment10, l_segment11, l_segment12,
	   l_segment13, l_segment14, l_segment15, l_segment16, l_segment17, l_segment18,
	   l_segment19, l_segment20, l_segment21, l_segment22, l_segment23, l_segment24,
	   l_segment25, l_segment26, l_segment27, l_segment28, l_segment29, l_segment30
      FROM GL_CODE_COMBINATIONS GL
     WHERE GL.code_combination_id(+) = l_clearning_ccid;

    OPEN copy_dist(p_report_line_id);

    LOOP
	FETCH copy_dist into l_org_id, l_sequence_num, l_last_updated_by, l_created_by,
			     l_preparer_modified_flag, l_amount, l_cost_center;
	EXIT WHEN copy_dist%NOTFOUND;

  	INSERT INTO AP_EXP_REPORT_DISTS
    	(
      	  report_header_id,
      	  report_line_id,
      	  report_distribution_id,
	  org_id,
      	  sequence_num,
      	  last_update_date,
      	  last_updated_by,
      	  creation_date,
      	  created_by,
      	  code_combination_id,
      	  segment1,
      	  segment2,
      	  segment3,
      	  segment4,
      	  segment5,
      	  segment6,
      	  segment7,
      	  segment8,
      	  segment9,
      	  segment10,
      	  segment11,
      	  segment12,
      	  segment13,
      	  segment14,
      	  segment15,
      	  segment16,
      	  segment17,
      	  segment18,
      	  segment19,
      	  segment20,
      	  segment21,
      	  segment22,
      	  segment23,
      	  segment24,
      	  segment25,
      	  segment26,
      	  segment27,
      	  segment28,
      	  segment29,
      	  segment30,
      	  preparer_modified_flag,
      	  amount,
      	  project_id,
      	  task_id,
      	  award_id,
      	  expenditure_organization_id,
      	  cost_center
    	)
  	VALUES (
      	  p_new_report_header_id,
      	  p_new_report_line_id,
      	  AP_EXP_REPORT_DISTS_S.NEXTVAL,
	  l_org_id,
      	  l_sequence_num,
      	  SYSDATE,
      	  l_last_updated_by,
      	  SYSDATE,
      	  l_created_by,
      	  l_clearning_ccid,
      	  l_segment1,
      	  l_segment2,
      	  l_segment3,
      	  l_segment4,
      	  l_segment5,
      	  l_segment6,
      	  l_segment7,
      	  l_segment8,
      	  l_segment9,
      	  l_segment10,
      	  l_segment11,
      	  l_segment12,
      	  l_segment13,
      	  l_segment14,
      	  l_segment15,
      	  l_segment16,
      	  l_segment17,
      	  l_segment18,
      	  l_segment19,
      	  l_segment20,
      	  l_segment21,
      	  l_segment22,
      	  l_segment23,
      	  l_segment24,
      	  l_segment25,
      	  l_segment26,
      	  l_segment27,
      	  l_segment28,
      	  l_segment29,
      	  l_segment30,
      	  l_preparer_modified_flag,
      	  l_amount,
      	  null,
      	  null,
      	  null,
      	  null,
      	  l_cost_center);

    END LOOP;
    CLOSE copy_dist;

    /*Bug#8976900 - Add Reference for attachments from parent report line
      to the new short-paid report report*/
    AP_WEB_DB_EXPRPT_PKG.CopyAttachments(p_report_line_id,
                                         p_new_report_line_id,
                                         'OIE_LINE_ATTACHMENTS');

AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPLINE_PKG', 'end InsertCCLine');

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('InsertCCLine');
    APP_EXCEPTION.RAISE_EXCEPTION;
END InsertCCLine;

-------------------------------------------------------------------
-- Name: CopyCCItemizationChildLines
-- Desc: Copys all CCItemization Child Lines of p_source_parent_report_line_id
-- Input:
--    p_source_report_header_id - source report header id
--    p_new_report_header_id - target report header id
--    p_source_parent_report_line_id - source itemization parent report line id
--    p_target_parent_report_line_id - target itemization parent report line id
-------------------------------------------------------------------
PROCEDURE CopyCCItemizationChildLines(
  p_source_report_header_id     IN expLines_headerID,
  p_target_report_header_id     IN expLines_headerID,
  p_source_parent_report_line_id     IN NUMBER,
  p_target_parent_report_line_id     IN NUMBER) IS

  l_NewReportLineID expLines_report_line_id;
  i number;

  CURSOR ReportLines IS
    SELECT REPORT_LINE_ID
      FROM AP_EXPENSE_REPORT_LINES
      WHERE REPORT_HEADER_ID = P_source_report_header_id
        AND ITEMIZATION_PARENT_ID = p_source_parent_report_line_id;

BEGIN

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPLINE_PKG',
                                   'start CopyCCItemizationChildLines');

  FOR i in ReportLines LOOP

    -- Get new ID from sequence
    SELECT AP_EXPENSE_REPORT_LINES_S.NEXTVAL
    INTO l_NewReportLineID
    FROM DUAL;

    InsertCCLine(p_new_report_header_id  => p_target_report_header_id,
                 p_report_line_id        => i.report_line_id,
                 p_itemization_parent_id => p_target_parent_report_line_id,
                 p_new_report_line_id    => l_NewReportLineID,
                 p_distribution_line_number => l_NewReportLineID);

  END LOOP;

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPLINE_PKG',
                                   'end CopyCCItemizationChildLines');

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('CopyCCItemizationChildLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
END CopyCCItemizationChildLines;

--------------------------------------------------------------------------------
FUNCTION AddCCReportLines(p_report_header_id 	IN expLines_headerID,
			  p_new_report_id 	IN expLines_headerID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
  CURSOR CCReportLines IS
    SELECT report_line_id, itemization_parent_id, distribution_line_number
    FROM   ap_expense_report_lines
    WHERE  report_header_id = p_report_header_id
    AND    credit_card_trx_id IS NOT NULL
    AND    (itemization_parent_id is null
             OR
            itemization_parent_id = -1);

  i number;
  l_NewReportLineID expLines_report_line_id;

BEGIN

  for i in CCReportLines loop

    -- Get new ID from sequence
    SELECT AP_EXPENSE_REPORT_LINES_S.NEXTVAL
    INTO l_NewReportLineID
    FROM DUAL;

    InsertCCLine(p_new_report_header_id  => p_new_report_id,
                 p_report_line_id        => i.report_line_id,
                 p_itemization_parent_id => i.itemization_parent_id,
                 p_new_report_line_id    => l_NewReportLineID,
                 p_distribution_line_number => i.distribution_line_number);

    if (i.itemization_parent_id = -1) then
       CopyCCItemizationChildLines(
                                 p_report_header_id, --p_source_report_header_id
                                 p_new_report_id, --p_target_report_header_id
                                 i.report_line_id,
                                 l_NewReportLineID);
    end if;

  end loop;

	return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AddCCReportLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END AddCCReportLines;


-----------------------------------------------------------------------------
PROCEDURE DeleteAddonRates(P_ReportID             IN NUMBER) IS
--------------------------------------------------------------------------------
  l_temp    OIE_ADDON_MILEAGE_RATES.ADDON_RATE_TYPE%type;

  -- Selects report lines to delete.  The actual value being selected does not
  -- matter.  For some reason the compiler complains when the OF column-name
  -- in the FOR UPDATE is missing and NOWAIT is used, so the OF
  -- EMPLOYEE_FLAG is used as a place holder.
  CURSOR addonRates IS
    SELECT ADDON_RATE_TYPE
      FROM OIE_ADDON_MILEAGE_RATES addon, AP_EXPENSE_REPORT_LINES el
      WHERE (el.REPORT_HEADER_ID = P_ReportID AND
             el.REPORT_LINE_ID = addon.REPORT_LINE_ID)
      FOR UPDATE OF ADDON_RATE_TYPE NOWAIT;

BEGIN
  -- Delete the addon mileage rate from table.  An exception will occur if the row
  -- locks cannot be attained because of the NOWAIT argument for select.
  -- We are guaranteed a lock on the records because of the FOR UPDATE
  OPEN addonRates;

  LOOP
    FETCH addonRates into l_temp;
    EXIT WHEN addonRates%NOTFOUND;

    -- Delete matching line
    DELETE OIE_ADDON_MILEAGE_RATES WHERE CURRENT OF addonRates;
  END LOOP;

  CLOSE addonRates;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('DeleteAddonRates');
    APP_EXCEPTION.RAISE_EXCEPTION;
END DeleteAddonRates;


-----------------------------------------------------------------------------
PROCEDURE DeletePDMDailyBreakup(P_ReportID             IN NUMBER) IS
--------------------------------------------------------------------------------
  l_temp    OIE_PDM_DAILY_BREAKUPS.PDM_DAILY_BREAKUP_ID%type;

  -- Selects report lines to delete.  The actual value being selected does not
  -- matter.  For some reason the compiler complains when the OF column-name
  -- in the FOR UPDATE is missing and NOWAIT is used, so the OF
  -- EMPLOYEE_FLAG is used as a place holder.
  CURSOR dailyBreakup IS
    SELECT PDM_DAILY_BREAKUP_ID
      FROM OIE_PDM_DAILY_BREAKUPS db, AP_EXPENSE_REPORT_LINES el
      WHERE (el.REPORT_HEADER_ID = P_ReportID AND
             el.REPORT_LINE_ID = db.REPORT_LINE_ID)
      FOR UPDATE OF PDM_DESTINATION_ID NOWAIT;

BEGIN
  -- Delete the PDM daily breakup from table.  An exception will occur if the row
  -- locks cannot be attained because of the NOWAIT argument for select.
  -- We are guaranteed a lock on the records because of the FOR UPDATE
  OPEN dailyBreakup;

  LOOP
    FETCH dailyBreakup into l_temp;
    EXIT WHEN dailyBreakup%NOTFOUND;

    -- Delete matching line
    DELETE OIE_PDM_DAILY_BREAKUPS WHERE CURRENT OF dailyBreakup;
  END LOOP;

  CLOSE dailyBreakup;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('DeletePDMDailyBreakup');
    APP_EXCEPTION.RAISE_EXCEPTION;
END DeletePDMDailyBreakup;


-----------------------------------------------------------------------------
PROCEDURE DeletePDMDestination(P_ReportID             IN NUMBER) IS
--------------------------------------------------------------------------------
  l_temp    OIE_PDM_DESTINATIONS.PDM_DESTINATION_ID%type;

  -- Selects report lines to delete.  The actual value being selected does not
  -- matter.  For some reason the compiler complains when the OF column-name
  -- in the FOR UPDATE is missing and NOWAIT is used, so the OF
  -- EMPLOYEE_FLAG is used as a place holder.
  CURSOR pdmDestination IS
    SELECT PDM_DESTINATION_ID
      FROM OIE_PDM_DESTINATIONS db, AP_EXPENSE_REPORT_LINES el
      WHERE (el.REPORT_HEADER_ID = P_ReportID AND
             el.REPORT_LINE_ID = db.REPORT_LINE_ID)
      FOR UPDATE OF PDM_DESTINATION_ID NOWAIT;

BEGIN
  -- Delete the pdm destination from table.  An exception will occur if the row
  -- locks cannot be attained because of the NOWAIT argument for select.
  -- We are guaranteed a lock on the records because of the FOR UPDATE
  OPEN pdmDestination;

  LOOP
    FETCH pdmDestination into l_temp;
    EXIT WHEN pdmDestination%NOTFOUND;

    -- Delete matching line
    DELETE OIE_PDM_DESTINATIONS WHERE CURRENT OF pdmDestination;
  END LOOP;

  CLOSE pdmDestination;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('DeletePDMDestination');
    APP_EXCEPTION.RAISE_EXCEPTION;
END DeletePDMDestination;

--------------------------------------------------------------------------------
FUNCTION DeleteReportLines(P_ReportID             IN expLines_headerID)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------

  l_TempReportHeaderID   expLines_headerID;
  l_TempReportLineID   NUMBER;
  l_curr_calling_sequence VARCHAR2(100) := 'DeleteReportLines';

  -- Selects report lines to delete.  The actual value being selected does not
  -- matter.  For some reason the compiler complains when the OF column-name
  -- in the FOR UPDATE is missing and NOWAIT is used, so the OF
  -- REPORT_HEADER_ID is used as a place holder.
  CURSOR ReportLines IS
    SELECT REPORT_HEADER_ID, REPORT_LINE_ID
      FROM AP_EXPENSE_REPORT_LINES
      WHERE (REPORT_HEADER_ID = P_ReportID)
      FOR UPDATE OF REPORT_HEADER_ID NOWAIT;

BEGIN
  -- Delete distribution lines associated to this report first
  AP_WEB_DB_EXPDIST_PKG.DeleteReportDistributions(P_ReportID);

  -- Delete attendees
  AP_WEB_DB_EXP_ATTENDEES_PKG.deleteAttendees(P_ReportID);

  -- Delete additional mileage rates
  DeleteAddonRates(P_ReportID);
  -- Delete pdm daily breakup
  DeletePDMDailyBreakup(P_ReportID);
  -- Delete pdm destination
  DeletePDMDestination(P_ReportID);

  -- Delete the report lines from table.  An exception will occur if the row
  -- locks cannot be attained because of the NOWAIT argument for select.
  -- We are guaranteed a lock on the records because of the FOR UPDATE
  OPEN ReportLines;

  LOOP
    FETCH ReportLines into l_TempReportHeaderID, l_TempReportLineID;
    EXIT WHEN ReportLines%NOTFOUND;

    -- Delete matching line
    DELETE AP_EXPENSE_REPORT_LINES WHERE CURRENT OF ReportLines;

  /* Delete attachments assocated with the line */
  fnd_attached_documents2_pkg.delete_attachments(
    X_entity_name => 'OIE_LINE_ATTACHMENTS',
    X_pk1_value => l_TempReportLineID,
    X_delete_document_flag => 'Y'
  );

  END LOOP;

  CLOSE ReportLines;

  return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('DeleteReportLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END DeleteReportLines;


--------------------------------------------------------------------------------
FUNCTION DeletePersonalLines(p_report_header_id IN expLines_headerID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
l_personalParameterId         AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_paramID;

BEGIN

    IF (NOT AP_WEB_DB_EXPTEMPLATE_PKG.GetPersonalParamID(l_personalParameterId)) THEN
      return FALSE;
    END IF; /* GetPersonalParamID */

    -- Bug: 8588537 remove distributions on the personal lines
    DELETE FROM ap_exp_report_dists
    WHERE report_line_id in
          (SELECT report_line_id
           FROM ap_expense_report_lines
           WHERE web_parameter_id = l_personalParameterId
           AND report_header_id = p_report_header_id);


       DELETE FROM ap_expense_report_lines
       WHERE   web_parameter_id = l_personalParameterId
       AND report_header_id = p_report_header_id;

	return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('DeletePersonalLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END DeletePersonalLines;


--------------------------------------------------------------------------------
FUNCTION DeleteCreditReportLines(p_report_header_id IN expLines_headerID) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
      	DELETE FROM ap_expense_report_lines
      	WHERE  report_header_id = p_report_header_id
      	AND    credit_card_trx_id IS NOT NULL;

	return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('DeleteCreditReportLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END DeleteCreditReportLines;


--------------------------------------------------------------------------------
FUNCTION SetAWTGroupIDAndJustif(p_report_header_id 	IN expLines_headerID,
			p_sys_allow_awt_flag 	IN VARCHAR2,
			p_ven_allow_awt_flag 	IN VARCHAR2,
			p_ven_awt_group_id 	IN expLines_awtGroupID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
  UPDATE ap_expense_report_lines RL
  SET    awt_group_id   = decode(p_sys_allow_awt_flag, 'Y',
                          decode(p_ven_allow_awt_flag, 'Y', p_ven_awt_group_id,
                                 null), null),
	 justification_required_flag = (SELECT nvl(justification_required_flag,'V')
			       FROM   ap_expense_report_params
			       WHERE  parameter_id = RL.web_parameter_id)
  WHERE  report_header_id = p_report_header_id;

  return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('SetAWTGroupIDAndJustif');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END SetAWTGroupIDAndJustif;

-------------------------------------------------------------------
FUNCTION SetReceiptMissing(p_report_header_id 	IN expLines_headerID,
			p_flag	   		IN expLines_receiptMissingFlag)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  UPDATE ap_expense_report_lines
  SET    receipt_missing_flag = p_flag
  WHERE  report_header_id = p_report_header_id;

  return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('SetReceiptMissing');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END SetReceiptMissing;


--------------------------------------------------------------------------------
FUNCTION SetReceiptRequired(	p_report_header_id 	IN expLines_headerID,
				p_required_flag 	IN expLines_receiptReqdFlag
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
      UPDATE ap_expense_report_lines
      SET    receipt_required_flag = p_required_flag
      WHERE  nvl(receipt_missing_flag, 'N') = 'Y'
      AND    report_header_id = p_report_header_id;

 	return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('SetReceiptRequired');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END SetReceiptRequired;

--------------------------------------------------------------------------------
FUNCTION GetCCardLineCursor(p_expReportHeaderId IN  expLines_headerID,
			    p_cCardLineCursor  OUT NOCOPY CCardLinesCursor)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
    l_parameterId  number;
BEGIN
    if (AP_WEB_DB_EXPTEMPLATE_PKG.GetPersonalParamID(l_parameterId) <> TRUE) then
        APP_EXCEPTION.RAISE_EXCEPTION;
    end if;

    -- Bug 3253775: Included personal credit card transactions in the cursor and
    -- negated the personal transaction amt to be deducted later from invoice total.

    OPEN p_cCardLineCursor FOR
      SELECT  decode(erl.web_parameter_id,l_parameterId,-erl.amount,erl.amount),
	      cc.company_prepaid_invoice_id, cc.card_program_id,
	      decode(erl.web_parameter_id,l_parameterId, 'PERSONAL', 'BUSINESS'),
	      erl.org_id,
	      nvl(cc.transaction_date,sysdate),
	      erh.employee_id
      FROM    ap_expense_report_lines erl,
              ap_credit_card_trxns cc,
              ap_expense_report_headers erh
      WHERE   erl.report_header_id = erh.report_header_id
        AND   nvl(erl.itemization_parent_id,0) <> -1  /* Itemization Project */
        AND   cc.trx_id = erl.credit_card_trx_id	  -- is a credit card transaction
	AND   cc.payment_due_from_code in ('BOTH','COMPANY')  -- Both Pay split project
        AND   erh.report_header_id = p_expReportHeaderId
        AND   erh.source = 'SelfService';

    return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetCCardLineCursor');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetCCardLineCursor;

--------------------------------------------------------------------------------
PROCEDURE GetCCPrepaidAdjustedInvAmt(p_expReportHeaderId IN     NUMBER,
			             p_invAmt 	        IN OUT NOCOPY  VARCHAR2) IS
--------------------------------------------------------------------------------
    l_prepaid_amt   expLines_amount;
    l_parameterId  number;
    l_cCardLineCursor AP_WEB_DB_EXPLINE_PKG.CCTrxnCursor;
    l_invoiceAmt    AP_WEB_DB_AP_INT_PKG.invLines_amount := 0;
    l_baseAmt       AP_WEB_DB_AP_INT_PKG.invAll_baseAmount;
    l_totalCCardAmt  NUMBER := 0;
    l_prepaidInvId  AP_WEB_DB_CCARD_PKG.ccTrxn_companyPrepaidInvID;
    l_cCardLineAmt  AP_WEB_DB_EXPLINE_PKG.expLines_amount;
    l_cardProgramID NUMBER;
    l_Personal      VARCHAR2(10);
    l_debugInfo     VARCHAR2(2000);
    l_transaction_date DATE;
    l_employee_id      NUMBER;
    l_org_id        NUMBER;

BEGIN

/* Bug 3649748 : Calling   GetCCardLineCursor to get the COMPANY Pay
 *               lines
 */
/*
    if (AP_WEB_DB_EXPTEMPLATE_PKG.GetPersonalParamID(l_parameterId) <> TRUE) then
        APP_EXCEPTION.RAISE_EXCEPTION;
    end if;

  SELECT  sum(erl.amount)
  INTO    l_prepaid_amt
  FROM    ap_expense_report_lines erl,
          ap_credit_card_trxns cc
  WHERE   erl.report_header_id = p_expReportHeaderId
  AND   cc.trx_id = erl.credit_card_trx_id	  -- is a credit card transaction
  AND   (cc.category is null OR cc.category <> 'PERSONAL')     -- not a personal expense
  AND   erl.web_parameter_id <> l_parameterId      -- Not personal itemized line
  AND   cc.company_prepaid_invoice_id IS NOT null;  -- company prepaid

  p_invAmt := to_char(to_number(p_invAmt) - nvl(l_prepaid_amt,0));
*/
 ------------------------------------------------------------------
    l_debugInfo := 'Get the credit card report line cursor.';
    ----------------------------------------------------------------
    IF (AP_WEB_DB_EXPLINE_PKG.GetCCardLineCursor(
                                                 p_expReportHeaderId,
                                                 l_cCardLineCursor) = TRUE) THEN


        LOOP
            FETCH l_cCardLineCursor INTO
                l_cCardLineAmt, l_prepaidInvId, l_cardProgramID, l_Personal, l_org_id,
                l_transaction_date, l_employee_id;
            EXIT WHEN l_cCardLineCursor%NOTFOUND;

            l_totalCCardAmt := l_totalCCardAmt + l_cCardLineAmt;

        END LOOP;

        CLOSE l_cCardLineCursor;

        IF (l_totalCCardAmt <> 0) then
           -------------------------------------------------------------------
           l_debugInfo := 'Update the amount.';
           -------------------------------------------------------------------
           p_invAmt := p_invAmt - l_totalCCardAmt;
        END IF;


    END IF;


EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetCCPrepaidAdjustedInvAmt');
    APP_EXCEPTION.RAISE_EXCEPTION;
END GetCCPrepaidAdjustedInvAmt;

-------------------------------------------------------------------
FUNCTION GetReceiptsMissingFlag( p_report_header_id 	IN  expLines_headerID,
				p_missing_receipts_flag OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
-------------------------------------------------------------------

BEGIN
  select receipt_missing_flag
  into   p_missing_receipts_flag
  from   ap_expense_report_lines
  where  report_header_id = p_report_header_id
  and    receipt_missing_flag = 'Y'
  and    rownum = 1;

  RETURN TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_missing_receipts_flag := 'N';
    return FALSE;

  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetReceiptsMissingFlag');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;

END GetReceiptsMissingFlag;
--------------------------------------------------------------------------------
FUNCTION GetExpMileageLinesCursor(
	p_report_header_id	IN	expLines_headerID,
	p_mileage_lines_cursor OUT NOCOPY ExpLinesCursor)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
  -- get all mileage lines
  OPEN p_mileage_lines_cursor FOR
    SELECT XL.start_expense_date,
	   XL.end_expense_date,
	   LPAD(to_char((nvl(XL.end_expense_date,XL.start_expense_date) -
				XL.start_expense_date)+1),4),
           XL.distribution_line_number,
	   XP.company_policy_id,
	   XL.avg_mileage_rate,
	   XL.distance_unit_code,
	   nvl(XL.trip_distance,0),
	   nvl(XL.daily_distance,0),
	   XP.category_code,
	   XL.currency_code,
	   XL.amount,
           XL.number_people,
           XL.web_parameter_id,
           XL.rate_per_passenger,
           XL.attribute1,
           XL.attribute2,
           XL.attribute3,
           XL.attribute4,
           XL.attribute5,
           XL.attribute6,
           XL.attribute7,
           XL.attribute8,
           XL.attribute9,
           XL.attribute10,
           XL.attribute11,
           XL.attribute12,
           XL.attribute13,
           XL.attribute14,
           XL.attribute15,
           XL.report_line_id
   FROM    ap_expense_report_params XP,
	   ap_expense_report_lines XL,
	   ap_lookup_codes LC,
           PA_PROJECTS_ALL PAP,
           PA_TASKS PAT,
	   GMS_AWARDS GMS
   WHERE   XL.report_header_id = p_report_header_id
   AND     XL.project_id is not null
   AND     XL.task_id is not null
   AND     XL.web_parameter_id = XP.parameter_id
   AND     XL.line_type_lookup_code = LC.lookup_code
   AND     LC.lookup_type = 'INVOICE DISTRIBUTION TYPE'
   AND     XL.project_id = PAP.project_id
   AND     XL.project_id = PAT.project_id
   AND     XL.task_id = PAT.task_id
   AND     XL.award_id = GMS.award_id(+)
   UNION ALL
    SELECT XL.start_expense_date,
	   XL.end_expense_date,
	   LPAD(to_char((nvl(XL.end_expense_date,XL.start_expense_date) -
				XL.start_expense_date)+1),4),
           XL.distribution_line_number,
	   XP.company_policy_id,
	   XL.avg_mileage_rate,
	   XL.distance_unit_code,
	   nvl(XL.trip_distance,0),
	   nvl(XL.daily_distance,0),
	   XP.category_code,
	   XL.currency_code,
	   XL.amount,
           XL.number_people,
           XL.web_parameter_id,
           XL.rate_per_passenger,
           XL.attribute1,
           XL.attribute2,
           XL.attribute3,
           XL.attribute4,
           XL.attribute5,
           XL.attribute6,
           XL.attribute7,
           XL.attribute8,
           XL.attribute9,
           XL.attribute10,
           XL.attribute11,
           XL.attribute12,
           XL.attribute13,
           XL.attribute14,
           XL.attribute15,
           XL.report_line_id
   FROM    ap_expense_report_params XP,
	   ap_expense_report_lines XL,
	   ap_lookup_codes LC
   WHERE   XL.report_header_id = p_report_header_id
   AND     XL.web_parameter_id = XP.parameter_id
   AND     XL.line_type_lookup_code = LC.lookup_code
   AND     LC.lookup_type = 'INVOICE DISTRIBUTION TYPE'
   AND     XL.project_id is null
   AND     XL.task_id is null
   AND	   XL.award_id is null
   ORDER BY distribution_line_number;

   return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetExpMileageLinesCursor');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetExpMileageLinesCursor;

--------------------------------------------------------------------------------
PROCEDURE updateMileageExpLine(
	p_avg_mileage_rate	   IN expLines_avg_mileage_rate,
	p_report_header_id	   IN expLines_headerID,
	p_distribution_line_number IN expLines_distLineNum,
	p_new_dist_line_number	   IN expLines_distLineNum,
	p_amount		   IN expLines_amount,
	p_trip_distance		   IN expLines_trip_distance,
	p_daily_distance	   IN NUMBER,
	p_daily_amount		   IN expLines_dailyAmount,
	p_receipt_currency_amount  IN NUMBER,
	p_status_code		   IN expLines_mrate_adj_flag
)IS
--------------------------------------------------------------------------------
  l_debug_info	     VARCHAR2(200);
  l_report_line_id   NUMBER;
  l_currency_code    VARCHAR2(10);
BEGIN

  -- Bug: 8271275, Amount on Parent Line Distributions Not updated
  select report_line_id, receipt_currency_code
         into l_report_line_id, l_currency_code
         from ap_expense_report_lines_all
         where report_header_id = p_report_header_id and
         distribution_line_number = p_distribution_line_number;

  UPDATE ap_expense_report_lines
  SET	 avg_mileage_rate          = p_avg_mileage_rate,
	 amount			   = p_amount,
	 distribution_line_number  = p_new_dist_line_number,
	 trip_distance		   = p_trip_distance,
	 daily_distance		   = p_daily_distance,
	 daily_amount		   = p_daily_amount,
	 receipt_currency_amount   = p_receipt_currency_amount,
         mileage_rate_adjusted_flag = p_status_code
  WHERE  report_header_id	   = p_report_header_id
  AND	 distribution_line_number  = p_distribution_line_number;

  -- Bug: 8271275, Amount on Parent Line Distributions Not updated
  AP_WEB_DB_EXPDIST_PKG.ResplitDistAmounts(l_report_line_id,
                                           p_amount,
                                           l_currency_code);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('updateMileageExpLine: no data found');
    APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('updateMileageExpLine');
    APP_EXCEPTION.RAISE_EXCEPTION;
END updateMileageExpLine;


--------------------------------------------------------------------------------
PROCEDURE updateExpenseMileageLines(
p_mileage_line_array		IN Mileage_Line_Array,
p_bUpdatedHeader		OUT NOCOPY BOOLEAN
) IS
--------------------------------------------------------------------------------
  i		NUMBER := 1;
  l_amount	NUMBER;
  l_tab_idx	NUMBER;
  l_report_header_id	expLines_headerID := p_mileage_line_array(i).report_header_id;
  l_new_report_line_id AP_WEB_DB_EXPLINE_PKG.expLines_report_line_id;
  l_parent_line_number NUMBER;
  l_currency_code      VARCHAR2(10);

BEGIN

  l_tab_idx := p_mileage_line_array.FIRST;
  p_bUpdatedHeader := FALSE;

  LOOP
    EXIT WHEN l_tab_idx is null;

    IF (p_mileage_line_array(i).status <> C_Unchanged) THEN
       IF (p_mileage_line_array(i).status = C_New) THEN
	  -- New: add to database

          -- Bug: 7526203, Populate distributions for split mileage lines
          -- Get the parent line to duplicate distributions.
          select report_line_id, receipt_currency_code
          into l_parent_line_number, l_currency_code
          from ap_expense_report_lines_all
          where report_header_id = p_mileage_line_array(i).report_header_id and
          distribution_line_number = p_mileage_line_array(i).copy_From;

	  AddMileageExpLine(

	    p_new_distribution_line_number => p_mileage_line_array(i).new_dist_line_number,
	    p_new_trip_distance		   => p_mileage_line_array(i).trip_distance,
	    p_new_daily_distance	   => p_mileage_line_array(i).daily_distance,
	    p_new_amount		   => p_mileage_line_array(i).amount,
	    p_new_avg_mileage_rate	   => p_mileage_line_array(i).avg_mileage_rate,
	    p_orig_expense_report_id	   => p_mileage_line_array(i).report_header_id,
	    p_orig_dist_line_number	   => p_mileage_line_array(i).copy_From,
	    p_daily_amount		   => p_mileage_line_array(i).daily_amount,
	    p_receipt_currency_amount	   => p_mileage_line_array(i).amount,
            x_report_line_id               => l_new_report_line_id);

          --AP_WEB_DB_EXPDIST_PKG.AddDistributionLine(
          --  p_report_line_id               => l_new_report_line_id);
          AP_WEB_DB_EXPDIST_PKG.DuplicateDistributions(null, p_mileage_line_array(i).report_header_id,
 	                                               l_parent_line_number, l_new_report_line_id);
 	  -- Re-Split the Amounts on the new Line
 	  AP_WEB_DB_EXPDIST_PKG.ResplitDistAmounts(l_new_report_line_id, p_mileage_line_array(i).amount,
 	                                           l_currency_code);

       ELSIF (p_mileage_line_array(i).status = C_Modified
             OR p_mileage_line_array(i).status = C_Split) THEN

	  -- Modified: update database
	  updateMileageExpLine(
	    p_avg_mileage_rate		=> p_mileage_line_array(i).avg_mileage_rate,
	    p_report_header_id		=> p_mileage_line_array(i).report_header_id,
	    p_distribution_line_number	=> p_mileage_line_array(i).orig_dist_line_number,
	    p_new_dist_line_number	=> p_mileage_line_array(i).new_dist_line_number,
	    p_amount			=> p_mileage_line_array(i).amount,
	    p_trip_distance		=> p_mileage_line_array(i).trip_distance,
	    p_daily_distance		=> p_mileage_line_array(i).daily_distance,
	    p_daily_amount		=> p_mileage_line_array(i).daily_amount,
	    p_receipt_currency_amount	=> p_mileage_line_array(i).receipt_currency_amount,
            p_status_code               => p_mileage_line_array(i).status);

       END IF;
       p_bUpdatedHeader := TRUE;

    END IF;
    i := i + 1;
    l_tab_idx := p_mileage_line_array.NEXT(l_tab_idx);
  END LOOP;


EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('updateExpenseMileageLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
END updateExpenseMileageLines;


--------------------------------------------------------------------------------
PROCEDURE AddMileageExpLine(
	    p_new_distribution_line_number	IN NUMBER,
	    p_new_trip_distance			IN NUMBER,
	    p_new_daily_distance		IN NUMBER,
	    p_new_amount			IN NUMBER,
	    p_new_avg_mileage_rate		IN NUMBER,
	    p_orig_expense_report_id		IN expLines_headerID,
	    p_orig_dist_line_number		IN expLines_distLineNum,
	    p_daily_amount			IN NUMBER,
	    p_receipt_currency_amount		IN NUMBER,
            x_report_line_id                    OUT NOCOPY NUMBER
) IS
--------------------------------------------------------------------------------
  l_debug_info     varchar2(240);
  l_report_line_id NUMBER;
BEGIN

  l_debug_info := 'start of AddMileageExpLine';

  SELECT AP_EXPENSE_REPORT_LINES_S.NEXTVAL
  INTO l_report_line_id
  FROM DUAL;


  INSERT INTO ap_expense_report_lines
      (REPORT_HEADER_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CODE_COMBINATION_ID,
      ITEM_DESCRIPTION,
      SET_OF_BOOKS_ID,
      AMOUNT,
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
      ATTRIBUTE15,
      CURRENCY_CODE,
      EXCHANGE_RATE_TYPE,
      EXCHANGE_RATE,
      EXCHANGE_DATE,
      VAT_CODE,
      LINE_TYPE_LOOKUP_CODE,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY,
      STAT_AMOUNT,
      PROJECT_ACCOUNTING_CONTEXT,
      EXPENDITURE_TYPE,
      EXPENDITURE_ITEM_DATE,
      PA_QUANTITY,
      DISTRIBUTION_LINE_NUMBER,
      REFERENCE_1,
      REFERENCE_2,
      AWT_GROUP_ID,
      ORG_ID,
      RECEIPT_VERIFIED_FLAG,
      JUSTIFICATION_REQUIRED_FLAG,
      RECEIPT_REQUIRED_FLAG,
      RECEIPT_MISSING_FLAG,
      JUSTIFICATION,
      EXPENSE_GROUP,
      START_EXPENSE_DATE,
      END_EXPENSE_DATE,
      RECEIPT_CURRENCY_CODE,
      RECEIPT_CONVERSION_RATE,
      DAILY_AMOUNT,
      RECEIPT_CURRENCY_AMOUNT,
      WEB_PARAMETER_ID,
      GLOBAL_ATTRIBUTE_CATEGORY,
      GLOBAL_ATTRIBUTE1,
      GLOBAL_ATTRIBUTE2,
      GLOBAL_ATTRIBUTE3,
      GLOBAL_ATTRIBUTE4,
      GLOBAL_ATTRIBUTE5,
      GLOBAL_ATTRIBUTE6,
      GLOBAL_ATTRIBUTE7,
      GLOBAL_ATTRIBUTE8,
      GLOBAL_ATTRIBUTE9,
      GLOBAL_ATTRIBUTE10,
      GLOBAL_ATTRIBUTE11,
      GLOBAL_ATTRIBUTE12,
      GLOBAL_ATTRIBUTE13,
      GLOBAL_ATTRIBUTE14,
      GLOBAL_ATTRIBUTE15,
      GLOBAL_ATTRIBUTE16,
      GLOBAL_ATTRIBUTE17,
      GLOBAL_ATTRIBUTE18,
      GLOBAL_ATTRIBUTE19,
      GLOBAL_ATTRIBUTE20,
      ADJUSTMENT_REASON,
      POLICY_SHORTPAY_FLAG,
      MERCHANT_DOCUMENT_NUMBER,
      MERCHANT_NAME,
      MERCHANT_REFERENCE,
      MERCHANT_TAX_REG_NUMBER,
      MERCHANT_TAXPAYER_ID,
      COUNTRY_OF_SUPPLY,
      TAX_CODE_OVERRIDE_FLAG,
      TAX_CODE_ID,
      CREDIT_CARD_TRX_ID,
      ALLOCATION_REASON,
      ALLOCATION_SPLIT_CODE,
      PROJECT_NAME,
      TASK_NAME,
      COMPANY_PREPAID_INVOICE_ID,
      PROJECT_NUMBER,
      TASK_NUMBER,
      PA_INTERFACED_FLAG,
      AWARD_NUMBER,
      VEHICLE_CATEGORY_CODE,
      VEHICLE_TYPE,
      FUEL_TYPE,
      NUMBER_PEOPLE,
      DAILY_DISTANCE,
      AVG_MILEAGE_RATE,
      DESTINATION_FROM,
      DESTINATION_TO,
      TRIP_DISTANCE,
      DISTANCE_UNIT_CODE,
      LICENSE_PLATE_NUMBER,
      LOCATION_ID,
      NUM_PDM_DAYS1,
      NUM_PDM_DAYS2,
      NUM_PDM_DAYS3,
      PER_DIEM_RATE1,
      PER_DIEM_RATE2,
      PER_DIEM_RATE3,
      DEDUCTION_ADDITION_AMT1,
      DEDUCTION_ADDITION_AMT2,
      DEDUCTION_ADDITION_AMT3,
      NUM_FREE_BREAKFASTS1,
      NUM_FREE_LUNCHES1,
      NUM_FREE_DINNERS1,
      NUM_FREE_ACCOMMODATIONS1,
      NUM_FREE_BREAKFASTS2,
      NUM_FREE_LUNCHES2,
      NUM_FREE_DINNERS2,
      NUM_FREE_ACCOMMODATIONS2,
      NUM_FREE_BREAKFASTS3,
      NUM_FREE_LUNCHES3,
      NUM_FREE_DINNERS3,
      NUM_FREE_ACCOMMODATIONS3,
      ATTENDEES,
      NUMBER_ATTENDEES,
      TICKET_CLASS_CODE,
      TRAVEL_TYPE,
      TICKET_NUMBER,
      FLIGHT_NUMBER,
      LOCATION_TO_ID,
      ITEMIZATION_PARENT_ID,
      FLEX_CONCATENATED,
      MILEAGE_RATE_ADJUSTED_FLAG,
      FUNC_CURRENCY_AMT,
      CATEGORY_CODE,
      ADJUSTMENT_REASON_CODE,
      LOCATION,
      AP_VALIDATION_ERROR,
      REPORT_LINE_ID
      )
  SELECT
      REPORT_HEADER_ID,
      SYSDATE,
      LAST_UPDATED_BY,
      CODE_COMBINATION_ID,
      ITEM_DESCRIPTION,
      SET_OF_BOOKS_ID,
      p_new_amount,
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
      ATTRIBUTE15,
      CURRENCY_CODE,
      EXCHANGE_RATE_TYPE,
      EXCHANGE_RATE,
      EXCHANGE_DATE,
      VAT_CODE,
      LINE_TYPE_LOOKUP_CODE,
      LAST_UPDATE_LOGIN,
      SYSDATE,
      CREATED_BY,
      STAT_AMOUNT,
      PROJECT_ACCOUNTING_CONTEXT,
      EXPENDITURE_TYPE,
      EXPENDITURE_ITEM_DATE,
      PA_QUANTITY,
      p_new_distribution_line_number,
      REFERENCE_1,
      REFERENCE_2,
      AWT_GROUP_ID,
      ORG_ID,
      RECEIPT_VERIFIED_FLAG,
      JUSTIFICATION_REQUIRED_FLAG,
      RECEIPT_REQUIRED_FLAG,
      RECEIPT_MISSING_FLAG,
      JUSTIFICATION,
      EXPENSE_GROUP,
      START_EXPENSE_DATE,
      END_EXPENSE_DATE,
      RECEIPT_CURRENCY_CODE,
      RECEIPT_CONVERSION_RATE,
      p_daily_amount,
      p_receipt_currency_amount,
      WEB_PARAMETER_ID,
      GLOBAL_ATTRIBUTE_CATEGORY,
      GLOBAL_ATTRIBUTE1,
      GLOBAL_ATTRIBUTE2,
      GLOBAL_ATTRIBUTE3,
      GLOBAL_ATTRIBUTE4,
      GLOBAL_ATTRIBUTE5,
      GLOBAL_ATTRIBUTE6,
      GLOBAL_ATTRIBUTE7,
      GLOBAL_ATTRIBUTE8,
      GLOBAL_ATTRIBUTE9,
      GLOBAL_ATTRIBUTE10,
      GLOBAL_ATTRIBUTE11,
      GLOBAL_ATTRIBUTE12,
      GLOBAL_ATTRIBUTE13,
      GLOBAL_ATTRIBUTE14,
      GLOBAL_ATTRIBUTE15,
      GLOBAL_ATTRIBUTE16,
      GLOBAL_ATTRIBUTE17,
      GLOBAL_ATTRIBUTE18,
      GLOBAL_ATTRIBUTE19,
      GLOBAL_ATTRIBUTE20,
      ADJUSTMENT_REASON,
      POLICY_SHORTPAY_FLAG,
      MERCHANT_DOCUMENT_NUMBER,
      MERCHANT_NAME,
      MERCHANT_REFERENCE,
      MERCHANT_TAX_REG_NUMBER,
      MERCHANT_TAXPAYER_ID,
      COUNTRY_OF_SUPPLY,
      TAX_CODE_OVERRIDE_FLAG,
      TAX_CODE_ID,
      CREDIT_CARD_TRX_ID,
      ALLOCATION_REASON,
      ALLOCATION_SPLIT_CODE,
      PROJECT_NAME,
      TASK_NAME,
      COMPANY_PREPAID_INVOICE_ID,
      PROJECT_NUMBER,
      TASK_NUMBER,
      PA_INTERFACED_FLAG,
      AWARD_NUMBER,
      VEHICLE_CATEGORY_CODE,
      VEHICLE_TYPE,
      FUEL_TYPE,
      NUMBER_PEOPLE,
      p_new_daily_distance,
      p_new_avg_mileage_rate,
      DESTINATION_FROM,
      DESTINATION_TO,
      p_new_trip_distance,
      DISTANCE_UNIT_CODE,
      LICENSE_PLATE_NUMBER,
      LOCATION_ID,
      NUM_PDM_DAYS1,
      NUM_PDM_DAYS2,
      NUM_PDM_DAYS3,
      PER_DIEM_RATE1,
      PER_DIEM_RATE2,
      PER_DIEM_RATE3,
      DEDUCTION_ADDITION_AMT1,
      DEDUCTION_ADDITION_AMT2,
      DEDUCTION_ADDITION_AMT3,
      NUM_FREE_BREAKFASTS1,
      NUM_FREE_LUNCHES1,
      NUM_FREE_DINNERS1,
      NUM_FREE_ACCOMMODATIONS1,
      NUM_FREE_BREAKFASTS2,
      NUM_FREE_LUNCHES2,
      NUM_FREE_DINNERS2,
      NUM_FREE_ACCOMMODATIONS2,
      NUM_FREE_BREAKFASTS3,
      NUM_FREE_LUNCHES3,
      NUM_FREE_DINNERS3,
      NUM_FREE_ACCOMMODATIONS3,
      ATTENDEES,
      NUMBER_ATTENDEES,
      TICKET_CLASS_CODE,
      TRAVEL_TYPE,
      TICKET_NUMBER,
      FLIGHT_NUMBER,
      LOCATION_TO_ID,
      ITEMIZATION_PARENT_ID,
      FLEX_CONCATENATED,
      AP_WEB_DB_EXPLINE_PKG.C_New,
      FUNC_CURRENCY_AMT,
      CATEGORY_CODE,
      ADJUSTMENT_REASON_CODE,
      LOCATION,
      AP_VALIDATION_ERROR,
      l_report_line_id
  FROM  ap_expense_report_lines
  WHERE report_header_id = p_orig_expense_report_id
  AND   distribution_line_number = p_orig_dist_line_number;

  ---------------------------------------------------------------
  -- Assign the out parameter only when the insert is successful.
  ---------------------------------------------------------------
  x_report_line_id := l_report_line_id;

  -- copy additional mileage rate
    INSERT INTO OIE_ADDON_MILEAGE_RATES(REPORT_LINE_ID,
            ADDON_RATE_TYPE,
            MILEAGE_RATE,
            MILEAGE_AMOUNT,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATED_BY,
            CREATION_DATE)
  SELECT X_REPORT_LINE_ID,
          ADDON_RATE_TYPE,
          MILEAGE_RATE,
          MILEAGE_AMOUNT,
          SYSDATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          CREATED_BY,
          SYSDATE
  FROM OIE_ADDON_MILEAGE_RATES
  WHERE REPORT_LINE_ID = (SELECT REPORT_LINE_ID
                           FROM AP_EXPENSE_REPORT_LINES
                           WHERE  REPORT_HEADER_ID = P_ORIG_EXPENSE_REPORT_ID
                           AND DISTRIBUTION_LINE_NUMBER = P_ORIG_DIST_LINE_NUMBER
                           AND ROWNUM = 1);

EXCEPTION
  WHEN TOO_MANY_ROWS OR NO_DATA_FOUND THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AddMileageExpLine','',
				  'AP_WEB_SAVESUB_DELETE_FAILED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('AddMileageExpLine',
				    l_debug_Info);
      APP_EXCEPTION.RAISE_EXCEPTION;

END AddMileageExpLine;



PROCEDURE CopyAddonRates(p_from_report_line_id IN NUMBER,
                         p_to_report_line_id IN NUMBER)
IS
 l_category_code VARCHAR2(30);
BEGIN
   SELECT CATEGORY_CODE INTO L_CATEGORY_CODE
   FROM AP_EXPENSE_REPORT_LINES
   WHERE REPORT_LINE_ID = P_FROM_REPORT_LINE_ID;

   IF (L_CATEGORY_CODE = 'MILEAGE') THEN
 -- COPY ADDITIONAL MILEAGE RATE
      INSERT INTO OIE_ADDON_MILEAGE_RATES(REPORT_LINE_ID,
            ADDON_RATE_TYPE,
            MILEAGE_RATE,
            MILEAGE_AMOUNT,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATED_BY,
            CREATION_DATE)
      SELECT P_TO_REPORT_LINE_ID,
          ADDON_RATE_TYPE,
          MILEAGE_RATE,
          MILEAGE_AMOUNT,
          SYSDATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          CREATED_BY,
          SYSDATE
      FROM OIE_ADDON_MILEAGE_RATES
      WHERE REPORT_LINE_ID = P_FROM_REPORT_LINE_ID;
  END IF;
  EXCEPTION WHEN OTHERS THEN
   null;
END CopyAddonRates;


PROCEDURE CopyPDMDailyBreakup(p_from_report_line_id IN NUMBER,
                         p_to_report_line_id IN NUMBER)
IS
 l_category_code VARCHAR2(30);
BEGIN
   SELECT CATEGORY_CODE INTO L_CATEGORY_CODE
   FROM AP_EXPENSE_REPORT_LINES
   WHERE REPORT_LINE_ID = P_FROM_REPORT_LINE_ID;

   IF (L_CATEGORY_CODE = 'PER_DIEM') THEN
 -- COPY PDM DAILY BREAKUP
      INSERT INTO OIE_PDM_DAILY_BREAKUPS(PDM_DAILY_BREAKUP_ID,
            REPORT_LINE_ID,
            START_DATE,
            END_DATE,
            AMOUNT,
            NUMBER_OF_MEALS,
            MEALS_AMOUNT,
            BREAKFAST_FLAG,
            LUNCH_FLAG,
            DINNER_FLAG,
            ACCOMMODATION_FLAG,
            ACCOMMODATION_AMOUNT,
            HOTEL_NAME,
            NIGHT_RATE_TYPE,
            NIGHT_RATE_AMOUNT,
            PDM_RATE,
            RATE_TYPE_CODE,
            PDM_DESTINATION_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATED_BY,
            CREATION_DATE)
      SELECT OIE_PDM_DAILY_BREAKUPS_S.nextval,
            p_to_report_line_id,
            START_DATE+AP_WEB_DB_EXPLINE_PKG.C_NumDaysRollForward,
            END_DATE+AP_WEB_DB_EXPLINE_PKG.C_NumDaysRollForward,
            AMOUNT,
            NUMBER_OF_MEALS,
            MEALS_AMOUNT,
            BREAKFAST_FLAG,
            LUNCH_FLAG,
            DINNER_FLAG,
            ACCOMMODATION_FLAG,
            ACCOMMODATION_AMOUNT,
            HOTEL_NAME,
            NIGHT_RATE_TYPE,
            NIGHT_RATE_AMOUNT,
            PDM_RATE,
            RATE_TYPE_CODE,
            PDM_DESTINATION_ID,
            SYSDATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATED_BY,
            SYSDATE
      FROM OIE_PDM_DAILY_BREAKUPS
      WHERE REPORT_LINE_ID = P_FROM_REPORT_LINE_ID;
  END IF;
  EXCEPTION WHEN OTHERS THEN
   null;
END CopyPDMDailyBreakup;

PROCEDURE CopyPDMDestination(p_from_report_line_id IN NUMBER,
                         p_to_report_line_id IN NUMBER)
IS
 l_category_code VARCHAR2(30);
BEGIN
   SELECT CATEGORY_CODE INTO L_CATEGORY_CODE
   FROM AP_EXPENSE_REPORT_LINES
   WHERE REPORT_LINE_ID = P_FROM_REPORT_LINE_ID;

   IF (L_CATEGORY_CODE = 'PER_DIEM') THEN
      -- COPY PDM DESTINATION
      INSERT INTO OIE_PDM_DESTINATIONS(PDM_DESTINATION_ID,
            REPORT_LINE_ID,
            START_DATE,
            END_DATE,
            LOCATION_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATED_BY,
            CREATION_DATE)
      SELECT OIE_PDM_DESTINATIONS_S.nextval,
            p_to_report_line_id,
            START_DATE+AP_WEB_DB_EXPLINE_PKG.C_NumDaysRollForward,
            END_DATE+AP_WEB_DB_EXPLINE_PKG.C_NumDaysRollForward,
            LOCATION_ID,
            SYSDATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATED_BY,
            SYSDATE
      FROM OIE_PDM_DESTINATIONS
      WHERE REPORT_LINE_ID = P_FROM_REPORT_LINE_ID;
  END IF;
  EXCEPTION WHEN OTHERS THEN
   null;
END CopyPDMDestination;

--------------------------------------------------------------------------------
-------------------------------------------------------------------
-- Name: CopyItemizationChildLines
-- Desc: Copys all Itemization Child Lines of p_source_parent_report_line_id
-- Input:
--    p_user_id - user_id of employee
--    p_source_report_header_id - source report header id
--    p_target_report_header_id - target report header id
--    p_source_parent_report_line_id - source itemization parent report line id
--    p_target_parent_report_line_id - target itemization parent report line id
-------------------------------------------------------------------
PROCEDURE CopyItemizationChildLines(
  p_user_id     IN NUMBER,
  p_source_report_header_id     IN expLines_headerID,
  p_target_report_header_id     IN expLines_headerID,
  p_source_parent_report_line_id     IN NUMBER,
  p_target_parent_report_line_id     IN NUMBER) IS

  l_TempReportLineID expLines_report_line_id;
  l_NewReportLineID expLines_report_line_id;

  -- Bug 6689280 (sodash)
  l_Receipt_Conversion_Rate AP_EXPENSE_REPORT_LINES.RECEIPT_CONVERSION_RATE%type;
  -- Bug 7555144 - Swapping to and from Currency Codes
  l_from_currency_code AP_EXPENSE_REPORT_LINES.RECEIPT_CURRENCY_CODE%type;
  l_to_currency_code AP_EXPENSE_REPORT_LINES.CURRENCY_CODE%type;
  l_exchange_rate_type AP_EXPENSE_REPORT_LINES.EXCHANGE_RATE_TYPE%type;
  l_exchange_date AP_EXPENSE_REPORT_LINES.EXCHANGE_DATE%type;
  l_exchange_rate AP_EXPENSE_REPORT_LINES.EXCHANGE_RATE%type := null;
  l_lines_total AP_EXPENSE_REPORT_LINES.AMOUNT%type;
  l_amount AP_EXPENSE_REPORT_LINES.AMOUNT%type;
  l_default_exchange_rates  VARCHAR2(1);
  l_exchange_rate_allowance NUMBER;
  -- Bug 7555144 - Commenting since Display Inverse Profile is for Display Purposes only.
  -- l_display_inverse_profile fnd_profile_option_values.profile_option_value%type;

  -- Bug 7555144 - Changing the order to  match with the from and to currencies
  CURSOR ReportLines IS
      SELECT report_line_id, receipt_currency_code, currency_code, (start_expense_date+AP_WEB_DB_EXPLINE_PKG.C_NumDaysRollForward), receipt_currency_amount
      FROM AP_EXPENSE_REPORT_LINES
      WHERE REPORT_HEADER_ID = P_source_report_header_id
        AND CREDIT_CARD_TRX_ID is null
        AND ITEMIZATION_PARENT_ID = p_source_parent_report_line_id;
-- Bug 7150383(sodash) get the total of child lines and update the total of the parent line
  CURSOR update_new_parent_line_amt_c IS
    SELECT ael.*
      FROM ap_expense_report_lines ael
     WHERE report_header_id = p_target_report_header_id
       AND report_line_id = p_target_parent_report_line_id
    FOR UPDATE OF report_header_id, report_line_id NOWAIT;

  l_parent_line_rec               update_new_parent_line_amt_c%ROWTYPE;

BEGIN

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPLINE_PKG',
                                   'start CopyItemizationChildLines');
  l_lines_total:=0;
  -- Find all lines associated with this report
  OPEN ReportLines;

  LOOP
    FETCH ReportLines into l_TempReportLineID, l_from_currency_code, l_to_currency_code, l_exchange_date, l_amount;
    EXIT WHEN ReportLines%NOTFOUND;

    -- Get new ID from sequence
    SELECT AP_EXPENSE_REPORT_LINES_S.NEXTVAL
    INTO l_NewReportLineID
    FROM DUAL;

    -- Bug# 9182883: Get the default exchange rates and the allowance rate
    AP_WEB_DB_AP_INT_PKG.GetDefaultExchangeRates(l_default_exchange_rates, l_exchange_rate_allowance);

    IF l_default_exchange_rates = 'Y' THEN
    -- Bug 6689280 (sodash)
    AP_WEB_DB_AP_INT_PKG.GetDefaultExchange( l_exchange_rate_type);

    IF (l_from_currency_code <> l_to_currency_code) THEN
            l_exchange_rate := AP_UTILITIES_PKG.get_exchange_rate
                                         (l_from_currency_code,
                                          l_to_currency_code,
                                          l_exchange_rate_type,
                                          l_exchange_date,
	                        	 'CalculateReceiptConversionRate');
	    l_exchange_rate :=  l_exchange_rate * (1+l_exchange_rate_allowance/100);
    ELSE
            l_exchange_rate := 1;
    END IF;

    -- Bug 7555144 - Commenting since Display Inverse Profile is for Display Purposes only.
    -- FND_PROFILE.GET('DISPLAY_INVERSE_RATE', l_display_inverse_profile);


    IF (l_exchange_rate IS NULL) THEN
       l_Receipt_Conversion_Rate := null;
    -- ELSIF(l_display_inverse_profile = 'Y') THEN
    --   l_Receipt_Conversion_Rate := 1/l_exchange_rate ;
    ELSE
       l_Receipt_Conversion_Rate := l_exchange_rate;
    END IF;

    IF (l_exchange_rate IS NOT NULL) then
       l_amount := l_amount * l_Receipt_Conversion_Rate;
    ELSE
       l_amount := null;
    END IF;

    END IF;

    -- For each line, duplicate its columns
    insert into AP_EXPENSE_REPORT_LINES
        (
         REPORT_HEADER_ID,
         CODE_COMBINATION_ID,
         ITEM_DESCRIPTION,
         SET_OF_BOOKS_ID,
         ITEMIZATION_PARENT_ID,
         AMOUNT,
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
         ATTRIBUTE15,
         CURRENCY_CODE,
         EXCHANGE_RATE_TYPE,
         EXCHANGE_RATE,
         EXCHANGE_DATE,
         VAT_CODE,
         LINE_TYPE_LOOKUP_CODE,
         PROJECT_ACCOUNTING_CONTEXT,
         EXPENDITURE_TYPE,
         EXPENDITURE_ITEM_DATE,
         PA_QUANTITY,
         DISTRIBUTION_LINE_NUMBER,
         ORG_ID,
         GLOBAL_ATTRIBUTE_CATEGORY,
         GLOBAL_ATTRIBUTE1,
         GLOBAL_ATTRIBUTE2,
         GLOBAL_ATTRIBUTE3,
         GLOBAL_ATTRIBUTE4,
         GLOBAL_ATTRIBUTE5,
         GLOBAL_ATTRIBUTE6,
         GLOBAL_ATTRIBUTE7,
         GLOBAL_ATTRIBUTE8,
         GLOBAL_ATTRIBUTE9,
         GLOBAL_ATTRIBUTE10,
         GLOBAL_ATTRIBUTE11,
         GLOBAL_ATTRIBUTE12,
         GLOBAL_ATTRIBUTE13,
         GLOBAL_ATTRIBUTE14,
         GLOBAL_ATTRIBUTE15,
         GLOBAL_ATTRIBUTE16,
         GLOBAL_ATTRIBUTE17,
         GLOBAL_ATTRIBUTE18,
         GLOBAL_ATTRIBUTE19,
         GLOBAL_ATTRIBUTE20,
         JUSTIFICATION,
         EXPENSE_GROUP,
         START_EXPENSE_DATE,
         END_EXPENSE_DATE,
         RECEIPT_CURRENCY_CODE,
         RECEIPT_CONVERSION_RATE,
         DAILY_AMOUNT,
         RECEIPT_CURRENCY_AMOUNT,
         WEB_PARAMETER_ID,
         AMOUNT_INCLUDES_TAX_FLAG,
         MERCHANT_DOCUMENT_NUMBER,
         MERCHANT_NAME,
         MERCHANT_REFERENCE,
         MERCHANT_TAX_REG_NUMBER,
         MERCHANT_TAXPAYER_ID,
         COUNTRY_OF_SUPPLY,
         TAX_CODE_OVERRIDE_FLAG,
         TAX_CODE_ID,
         ALLOCATION_REASON,
         ALLOCATION_SPLIT_CODE,
         PROJECT_NAME,
         TASK_NAME,
         PA_INTERFACED_FLAG,
         PROJECT_NUMBER,
         TASK_NUMBER,
         AWARD_NUMBER,
         VEHICLE_TYPE,
         FUEL_TYPE,
         NUMBER_PEOPLE,
         AVG_MILEAGE_RATE,
         DESTINATION_FROM,
         DESTINATION_TO,
         TRIP_DISTANCE,
         LOCATION_ID,
         ATTENDEES,
         TICKET_NUMBER,
         FLIGHT_NUMBER,
         LICENSE_PLATE_NUMBER,
         NUMBER_ATTENDEES,
         LOCATION_TO_ID,
         NUM_PDM_DAYS1,
         NUM_PDM_DAYS2,
         NUM_PDM_DAYS3,
         PER_DIEM_RATE1,
         PER_DIEM_RATE2,
         PER_DIEM_RATE3,
         DEDUCTION_ADDITION_AMT1,
         DEDUCTION_ADDITION_AMT2,
         DEDUCTION_ADDITION_AMT3,
         NUM_FREE_BREAKFASTS1,
         NUM_FREE_LUNCHES1,
         NUM_FREE_DINNERS1,
         NUM_FREE_ACCOMMODATIONS1,
         NUM_FREE_BREAKFASTS2,
         NUM_FREE_LUNCHES2,
         NUM_FREE_DINNERS2,
         NUM_FREE_ACCOMMODATIONS2,
         NUM_FREE_BREAKFASTS3,
         NUM_FREE_LUNCHES3,
         NUM_FREE_DINNERS3,
         NUM_FREE_ACCOMMODATIONS3,
         TRAVEL_TYPE,
         FLEX_CONCATENATED,
         VEHICLE_CATEGORY_CODE,
         DISTANCE_UNIT_CODE,
         TICKET_CLASS_CODE,
         DAILY_DISTANCE,
         FUNC_CURRENCY_AMT,
         LOCATION,
         CATEGORY_CODE,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         REPORT_LINE_ID,
         RECEIPT_REQUIRED_FLAG
        )
    select
         p_target_report_header_id AS REPORT_HEADER_ID,
         CODE_COMBINATION_ID,
         ITEM_DESCRIPTION,
         SET_OF_BOOKS_ID,
         p_target_parent_report_line_id AS ITEMIZATION_PARENT_ID,
         l_amount,  -- Bug 6689280 (sodash)
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
         ATTRIBUTE15,
         CURRENCY_CODE,
         EXCHANGE_RATE_TYPE,
         EXCHANGE_RATE,
         (START_EXPENSE_DATE+AP_WEB_DB_EXPLINE_PKG.C_NumDaysRollForward) as EXCHANGE_DATE,
         VAT_CODE,
         LINE_TYPE_LOOKUP_CODE,
         PROJECT_ACCOUNTING_CONTEXT,
         EXPENDITURE_TYPE,
         EXPENDITURE_ITEM_DATE,
         PA_QUANTITY,
         l_NewReportLineID,
         ORG_ID,
         GLOBAL_ATTRIBUTE_CATEGORY,
         GLOBAL_ATTRIBUTE1,
         GLOBAL_ATTRIBUTE2,
         GLOBAL_ATTRIBUTE3,
         GLOBAL_ATTRIBUTE4,
         GLOBAL_ATTRIBUTE5,
         GLOBAL_ATTRIBUTE6,
         GLOBAL_ATTRIBUTE7,
         GLOBAL_ATTRIBUTE8,
         GLOBAL_ATTRIBUTE9,
         GLOBAL_ATTRIBUTE10,
         GLOBAL_ATTRIBUTE11,
         GLOBAL_ATTRIBUTE12,
         GLOBAL_ATTRIBUTE13,
         GLOBAL_ATTRIBUTE14,
         GLOBAL_ATTRIBUTE15,
         GLOBAL_ATTRIBUTE16,
         GLOBAL_ATTRIBUTE17,
         GLOBAL_ATTRIBUTE18,
         GLOBAL_ATTRIBUTE19,
         GLOBAL_ATTRIBUTE20,
         JUSTIFICATION,
         EXPENSE_GROUP,
         START_EXPENSE_DATE+AP_WEB_DB_EXPLINE_PKG.C_NumDaysRollForward AS START_EXPENSE_DATE,	-- roll forward 7 days
         END_EXPENSE_DATE+AP_WEB_DB_EXPLINE_PKG.C_NumDaysRollForward AS END_EXPENSE_DATE,	-- roll forward 7 days
         RECEIPT_CURRENCY_CODE,
         l_Receipt_Conversion_Rate, -- Bug 6689280 (sodash) reclculating the receipt conversion rate. Prior to it, It was getting set to null when the receipt currency and the reimbursement currency didn't match
         DAILY_AMOUNT,
         RECEIPT_CURRENCY_AMOUNT,
         WEB_PARAMETER_ID,
         AMOUNT_INCLUDES_TAX_FLAG,
         MERCHANT_DOCUMENT_NUMBER,
         MERCHANT_NAME,
         MERCHANT_REFERENCE,
         MERCHANT_TAX_REG_NUMBER,
         MERCHANT_TAXPAYER_ID,
         COUNTRY_OF_SUPPLY,
         TAX_CODE_OVERRIDE_FLAG,
         TAX_CODE_ID,
         ALLOCATION_REASON,
         ALLOCATION_SPLIT_CODE,
         PROJECT_NAME,
         TASK_NAME,
         PA_INTERFACED_FLAG,
         PROJECT_NUMBER,
         TASK_NUMBER,
         AWARD_NUMBER,
         VEHICLE_TYPE,
         FUEL_TYPE,
         NUMBER_PEOPLE,
         AVG_MILEAGE_RATE,
         DESTINATION_FROM,
         DESTINATION_TO,
         TRIP_DISTANCE,
         LOCATION_ID,
         ATTENDEES,
         TICKET_NUMBER,
         FLIGHT_NUMBER,
         LICENSE_PLATE_NUMBER,
         NUMBER_ATTENDEES,
         LOCATION_TO_ID,
         NUM_PDM_DAYS1,
         NUM_PDM_DAYS2,
         NUM_PDM_DAYS3,
         PER_DIEM_RATE1,
         PER_DIEM_RATE2,
         PER_DIEM_RATE3,
         DEDUCTION_ADDITION_AMT1,
         DEDUCTION_ADDITION_AMT2,
         DEDUCTION_ADDITION_AMT3,
         NUM_FREE_BREAKFASTS1,
         NUM_FREE_LUNCHES1,
         NUM_FREE_DINNERS1,
         NUM_FREE_ACCOMMODATIONS1,
         NUM_FREE_BREAKFASTS2,
         NUM_FREE_LUNCHES2,
         NUM_FREE_DINNERS2,
         NUM_FREE_ACCOMMODATIONS2,
         NUM_FREE_BREAKFASTS3,
         NUM_FREE_LUNCHES3,
         NUM_FREE_DINNERS3,
         NUM_FREE_ACCOMMODATIONS3,
         TRAVEL_TYPE,
         FLEX_CONCATENATED,
         VEHICLE_CATEGORY_CODE,
         DISTANCE_UNIT_CODE,
         TICKET_CLASS_CODE,
         DAILY_DISTANCE,
         FUNC_CURRENCY_AMT,
         LOCATION,
         CATEGORY_CODE,
         sysdate AS CREATION_DATE,
         p_user_id AS CREATED_BY,
         sysdate AS LAST_UPDATE_DATE,
         p_user_id AS LAST_UPDATED_BY,
         l_NewReportLineID,
         RECEIPT_REQUIRED_FLAG
    from   AP_EXPENSE_REPORT_LINES
    where  REPORT_LINE_ID = l_TempReportLineID;
    l_lines_total :=  l_lines_total+l_amount;
    -- Duplicate distribution lines associated with this line
    AP_WEB_DB_EXPDIST_PKG.DuplicateDistributions(
      p_user_id,
      p_target_report_header_id,
      l_TempReportLineID,
      l_NewReportLineID);

    -- Bug 5578059
    -- Duplicate Attendee info associated with this child line
    AP_WEB_DB_EXP_ATTENDEES_PKG.DuplicateAttendeeInfo(
      p_user_id,
      l_TempReportLineID,
      l_NewReportLineID);

    -- copy additional rates
    CopyAddonRates(l_TempReportLineID, l_NewReportLineID);
    -- copy pdm daily breakup
    CopyPDMDailyBreakup(l_TempReportLineID, l_NewReportLineID);
    -- copy pdm destination
    CopyPDMDestination(l_TempReportLineID, l_NewReportLineID);

  END LOOP;

  CLOSE ReportLines;

  -- Bug 7150383(sodash) get the total of child lines and update the total of the parent line
  OPEN update_new_parent_line_amt_c;
  FETCH update_new_parent_line_amt_c into l_parent_line_rec;

  UPDATE ap_expense_report_lines
     SET amount = l_lines_total
  WHERE CURRENT OF update_new_parent_line_amt_c;

  CLOSE update_new_parent_line_amt_c;

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPLINE_PKG',
                                   'end CopyItemizationChildLines');

END CopyItemizationChildLines;

--------------------------------------------------------------------------------

-------------------------------------------------------------------
-- Name: DuplicateLines
-- Desc: duplicates Expense Report Lines
-- Input:   p_source_report_header_id - source expense report header id
-- Returns: p_target_report_header_id - target expense report header id
-------------------------------------------------------------------
PROCEDURE DuplicateLines(
  p_user_id     IN NUMBER,
  p_source_report_header_id     IN expLines_headerID,
  p_target_report_header_id     IN OUT NOCOPY expLines_headerID) IS

   l_TempReportLineID expLines_report_line_id;
   l_NewReportLineID expLines_report_line_id;

  -- Bug 6689280 (sodash)
  l_Receipt_Conversion_Rate AP_EXPENSE_REPORT_LINES.RECEIPT_CONVERSION_RATE%type;
  -- Bug 7555144 - Swapping to and from Currency Codes
  l_from_currency_code AP_EXPENSE_REPORT_LINES.RECEIPT_CURRENCY_CODE%type;
  l_to_currency_code AP_EXPENSE_REPORT_LINES.CURRENCY_CODE%type;
  l_exchange_rate_type AP_EXPENSE_REPORT_LINES.EXCHANGE_RATE_TYPE%type;
  l_exchange_date AP_EXPENSE_REPORT_LINES.EXCHANGE_DATE%type;
  l_exchange_rate AP_EXPENSE_REPORT_LINES.EXCHANGE_RATE%type := null;
  l_amount AP_EXPENSE_REPORT_LINES.AMOUNT%type;
  -- Bug 7555144 - Commenting since Display Inverse Profile is for Display Purposes only.
  -- l_display_inverse_profile fnd_profile_option_values.profile_option_value%type;
  l_itemization_parent_id   AP_EXPENSE_REPORT_LINES.itemization_parent_id%type;
  l_default_exchange_rates  VARCHAR2(1);
  l_exchange_rate_allowance NUMBER;

  -- Bug 7555144 - Changing the Order to match with the from and to currencies
  CURSOR ReportLines IS
      SELECT report_line_id, itemization_parent_id, receipt_currency_code, currency_code, (start_expense_date+AP_WEB_DB_EXPLINE_PKG.C_NumDaysRollForward), receipt_currency_amount
      FROM AP_EXPENSE_REPORT_LINES
      WHERE REPORT_HEADER_ID = P_source_report_header_id
        AND CREDIT_CARD_TRX_ID is null
        AND (ITEMIZATION_PARENT_ID is null
             OR
             ITEMIZATION_PARENT_ID = -1);

BEGIN

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPLINE_PKG',
                                   'start DuplicateLines');

  -- Find all lines associated with this report
  OPEN ReportLines;

  LOOP
    FETCH ReportLines into l_TempReportLineID,l_itemization_parent_id,l_from_currency_code, l_to_currency_code, l_exchange_date, l_amount;
    EXIT WHEN ReportLines%NOTFOUND;

    -- Get new ID from sequence
    SELECT AP_EXPENSE_REPORT_LINES_S.NEXTVAL
    INTO l_NewReportLineID
    FROM DUAL;

    -- Bug# 9182883: Get the default exchange rates and the allowance rate
    AP_WEB_DB_AP_INT_PKG.GetDefaultExchangeRates(l_default_exchange_rates, l_exchange_rate_allowance);

    IF l_default_exchange_rates = 'Y' THEN
    -- Bug 6689280 (sodash)
    AP_WEB_DB_AP_INT_PKG.GetDefaultExchange( l_exchange_rate_type);

    IF (l_from_currency_code <> l_to_currency_code) THEN
            l_exchange_rate := AP_UTILITIES_PKG.get_exchange_rate
                                         (l_from_currency_code,
                                          l_to_currency_code,
                                          l_exchange_rate_type,
                                          l_exchange_date,
	                        	 'CalculateReceiptConversionRate');
	    l_exchange_rate :=  l_exchange_rate * (1+l_exchange_rate_allowance/100);
    ELSE
            l_exchange_rate := 1;
    END IF;

    -- Bug 7555144 - Commenting since Display Inverse Profile is for Display Purposes only.
    -- FND_PROFILE.GET('DISPLAY_INVERSE_RATE', l_display_inverse_profile);

    IF (l_exchange_rate IS NULL) THEN
       l_Receipt_Conversion_Rate := null;
    -- ELSIF (l_display_inverse_profile = 'Y') THEN
    --   l_Receipt_Conversion_Rate := 1/l_exchange_rate ;
    ELSE
       l_Receipt_Conversion_Rate := l_exchange_rate;
    END IF;

    IF (l_exchange_rate IS NOT NULL) then
	l_amount := l_amount * l_Receipt_Conversion_Rate;
    ELSE
        l_amount := null;
    END IF;

    END IF;

    -- For each line, duplicate its columns
    insert into AP_EXPENSE_REPORT_LINES
        (
         REPORT_HEADER_ID,
         CODE_COMBINATION_ID,
         ITEM_DESCRIPTION,
         SET_OF_BOOKS_ID,
         ITEMIZATION_PARENT_ID,
         AMOUNT,
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
         ATTRIBUTE15,
         CURRENCY_CODE,
         EXCHANGE_RATE_TYPE,
         EXCHANGE_RATE,
         EXCHANGE_DATE,
         VAT_CODE,
         LINE_TYPE_LOOKUP_CODE,
         PROJECT_ACCOUNTING_CONTEXT,
         EXPENDITURE_TYPE,
         EXPENDITURE_ITEM_DATE,
         PA_QUANTITY,
         DISTRIBUTION_LINE_NUMBER,
         ORG_ID,
         GLOBAL_ATTRIBUTE_CATEGORY,
         GLOBAL_ATTRIBUTE1,
         GLOBAL_ATTRIBUTE2,
         GLOBAL_ATTRIBUTE3,
         GLOBAL_ATTRIBUTE4,
         GLOBAL_ATTRIBUTE5,
         GLOBAL_ATTRIBUTE6,
         GLOBAL_ATTRIBUTE7,
         GLOBAL_ATTRIBUTE8,
         GLOBAL_ATTRIBUTE9,
         GLOBAL_ATTRIBUTE10,
         GLOBAL_ATTRIBUTE11,
         GLOBAL_ATTRIBUTE12,
         GLOBAL_ATTRIBUTE13,
         GLOBAL_ATTRIBUTE14,
         GLOBAL_ATTRIBUTE15,
         GLOBAL_ATTRIBUTE16,
         GLOBAL_ATTRIBUTE17,
         GLOBAL_ATTRIBUTE18,
         GLOBAL_ATTRIBUTE19,
         GLOBAL_ATTRIBUTE20,
         JUSTIFICATION,
         EXPENSE_GROUP,
         START_EXPENSE_DATE,
         END_EXPENSE_DATE,
         RECEIPT_CURRENCY_CODE,
         RECEIPT_CONVERSION_RATE,
         DAILY_AMOUNT,
         RECEIPT_CURRENCY_AMOUNT,
         WEB_PARAMETER_ID,
         AMOUNT_INCLUDES_TAX_FLAG,
         MERCHANT_DOCUMENT_NUMBER,
         MERCHANT_NAME,
         MERCHANT_REFERENCE,
         MERCHANT_TAX_REG_NUMBER,
         MERCHANT_TAXPAYER_ID,
         COUNTRY_OF_SUPPLY,
         TAX_CODE_OVERRIDE_FLAG,
         TAX_CODE_ID,
         ALLOCATION_REASON,
         ALLOCATION_SPLIT_CODE,
         PROJECT_NAME,
         TASK_NAME,
         PA_INTERFACED_FLAG,
         PROJECT_NUMBER,
         TASK_NUMBER,
         AWARD_NUMBER,
         VEHICLE_TYPE,
         FUEL_TYPE,
         NUMBER_PEOPLE,
         AVG_MILEAGE_RATE,
         DESTINATION_FROM,
         DESTINATION_TO,
         TRIP_DISTANCE,
         LOCATION_ID,
         ATTENDEES,
         TICKET_NUMBER,
         FLIGHT_NUMBER,
         LICENSE_PLATE_NUMBER,
         NUMBER_ATTENDEES,
         LOCATION_TO_ID,
         NUM_PDM_DAYS1,
         NUM_PDM_DAYS2,
         NUM_PDM_DAYS3,
         PER_DIEM_RATE1,
         PER_DIEM_RATE2,
         PER_DIEM_RATE3,
         DEDUCTION_ADDITION_AMT1,
         DEDUCTION_ADDITION_AMT2,
         DEDUCTION_ADDITION_AMT3,
         NUM_FREE_BREAKFASTS1,
         NUM_FREE_LUNCHES1,
         NUM_FREE_DINNERS1,
         NUM_FREE_ACCOMMODATIONS1,
         NUM_FREE_BREAKFASTS2,
         NUM_FREE_LUNCHES2,
         NUM_FREE_DINNERS2,
         NUM_FREE_ACCOMMODATIONS2,
         NUM_FREE_BREAKFASTS3,
         NUM_FREE_LUNCHES3,
         NUM_FREE_DINNERS3,
         NUM_FREE_ACCOMMODATIONS3,
         TRAVEL_TYPE,
         FLEX_CONCATENATED,
         VEHICLE_CATEGORY_CODE,
         DISTANCE_UNIT_CODE,
         TICKET_CLASS_CODE,
         DAILY_DISTANCE,
         FUNC_CURRENCY_AMT,
         LOCATION,
         CATEGORY_CODE,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         REPORT_LINE_ID,
         RECEIPT_REQUIRED_FLAG
        )
    select
         p_target_report_header_id AS REPORT_HEADER_ID,
         CODE_COMBINATION_ID,
         ITEM_DESCRIPTION,
         SET_OF_BOOKS_ID,
         ITEMIZATION_PARENT_ID,
         l_amount, -- Bug 6689280 (sodash) changed it because the earlier decode condition set the amount to null when the receipt currency and the reimbursement currency didn't match
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
         ATTRIBUTE15,
         CURRENCY_CODE,
         EXCHANGE_RATE_TYPE,
         EXCHANGE_RATE, -- Bug 6689280 (sodash)
         START_EXPENSE_DATE+AP_WEB_DB_EXPLINE_PKG.C_NumDaysRollForward AS EXCHANGE_DATE, -- bug 6689280 (sodash)
         VAT_CODE,
         LINE_TYPE_LOOKUP_CODE,
         PROJECT_ACCOUNTING_CONTEXT,
         EXPENDITURE_TYPE,
         EXPENDITURE_ITEM_DATE,
         PA_QUANTITY,
         AP_WEB_DB_EXPLINE_PKG.C_InitialDistLineNumber+DISTRIBUTION_LINE_NUMBER,
         ORG_ID,
         GLOBAL_ATTRIBUTE_CATEGORY,
         GLOBAL_ATTRIBUTE1,
         GLOBAL_ATTRIBUTE2,
         GLOBAL_ATTRIBUTE3,
         GLOBAL_ATTRIBUTE4,
         GLOBAL_ATTRIBUTE5,
         GLOBAL_ATTRIBUTE6,
         GLOBAL_ATTRIBUTE7,
         GLOBAL_ATTRIBUTE8,
         GLOBAL_ATTRIBUTE9,
         GLOBAL_ATTRIBUTE10,
         GLOBAL_ATTRIBUTE11,
         GLOBAL_ATTRIBUTE12,
         GLOBAL_ATTRIBUTE13,
         GLOBAL_ATTRIBUTE14,
         GLOBAL_ATTRIBUTE15,
         GLOBAL_ATTRIBUTE16,
         GLOBAL_ATTRIBUTE17,
         GLOBAL_ATTRIBUTE18,
         GLOBAL_ATTRIBUTE19,
         GLOBAL_ATTRIBUTE20,
         JUSTIFICATION,
         EXPENSE_GROUP,
         START_EXPENSE_DATE+AP_WEB_DB_EXPLINE_PKG.C_NumDaysRollForward AS START_EXPENSE_DATE,	-- roll forward 7 days
         END_EXPENSE_DATE+AP_WEB_DB_EXPLINE_PKG.C_NumDaysRollForward AS END_EXPENSE_DATE,	-- roll forward 7 days
         RECEIPT_CURRENCY_CODE,
         l_Receipt_Conversion_Rate, -- Bug 6689280 (sodash) reclculating the receipt conversion rate. Prior to it, It was getting set to null when the receipt currency and the reimbursement currency didn't match
         DAILY_AMOUNT,
         RECEIPT_CURRENCY_AMOUNT,
         WEB_PARAMETER_ID,
         AMOUNT_INCLUDES_TAX_FLAG,
         MERCHANT_DOCUMENT_NUMBER,
         MERCHANT_NAME,
         MERCHANT_REFERENCE,
         MERCHANT_TAX_REG_NUMBER,
         MERCHANT_TAXPAYER_ID,
         COUNTRY_OF_SUPPLY,
         TAX_CODE_OVERRIDE_FLAG,
         TAX_CODE_ID,
         ALLOCATION_REASON,
         ALLOCATION_SPLIT_CODE,
         PROJECT_NAME,
         TASK_NAME,
         PA_INTERFACED_FLAG,
         PROJECT_NUMBER,
         TASK_NUMBER,
         AWARD_NUMBER,
         VEHICLE_TYPE,
         FUEL_TYPE,
         NUMBER_PEOPLE,
         AVG_MILEAGE_RATE,
         DESTINATION_FROM,
         DESTINATION_TO,
         TRIP_DISTANCE,
         LOCATION_ID,
         ATTENDEES,
         TICKET_NUMBER,
         FLIGHT_NUMBER,
         LICENSE_PLATE_NUMBER,
         NUMBER_ATTENDEES,
         LOCATION_TO_ID,
         NUM_PDM_DAYS1,
         NUM_PDM_DAYS2,
         NUM_PDM_DAYS3,
         PER_DIEM_RATE1,
         PER_DIEM_RATE2,
         PER_DIEM_RATE3,
         DEDUCTION_ADDITION_AMT1,
         DEDUCTION_ADDITION_AMT2,
         DEDUCTION_ADDITION_AMT3,
         NUM_FREE_BREAKFASTS1,
         NUM_FREE_LUNCHES1,
         NUM_FREE_DINNERS1,
         NUM_FREE_ACCOMMODATIONS1,
         NUM_FREE_BREAKFASTS2,
         NUM_FREE_LUNCHES2,
         NUM_FREE_DINNERS2,
         NUM_FREE_ACCOMMODATIONS2,
         NUM_FREE_BREAKFASTS3,
         NUM_FREE_LUNCHES3,
         NUM_FREE_DINNERS3,
         NUM_FREE_ACCOMMODATIONS3,
         TRAVEL_TYPE,
         FLEX_CONCATENATED,
         VEHICLE_CATEGORY_CODE,
         DISTANCE_UNIT_CODE,
         TICKET_CLASS_CODE,
         DAILY_DISTANCE,
         FUNC_CURRENCY_AMT,
         LOCATION,
         CATEGORY_CODE,
         sysdate AS CREATION_DATE,
         p_user_id AS CREATED_BY,
         sysdate AS LAST_UPDATE_DATE,
         p_user_id AS LAST_UPDATED_BY,
         l_NewReportLineID,
         RECEIPT_REQUIRED_FLAG
    from   AP_EXPENSE_REPORT_LINES
    where  REPORT_LINE_ID = l_TempReportLineID;

    if (l_itemization_parent_id = '-1') then
       CopyItemizationChildLines(p_user_id,
                                 p_source_report_header_id,
                                 p_target_report_header_id,
                                 l_TempReportLineID,
                                 l_NewReportLineID);
    end if;

    -- Duplicate distribution lines associated with this line
    AP_WEB_DB_EXPDIST_PKG.DuplicateDistributions(
      p_user_id,
      p_target_report_header_id,
      l_TempReportLineID,
      l_NewReportLineID);

   -- Duplicate Attendee info associated with this line
   AP_WEB_DB_EXP_ATTENDEES_PKG.DuplicateAttendeeInfo(
	      p_user_id,
	      l_TempReportLineID,
	      l_NewReportLineID);

    -- copy additional rates
    CopyAddonRates(l_TempReportLineID, l_NewReportLineID);
    -- copy pdm daily breakup
    CopyPDMDailyBreakup(l_TempReportLineID, l_NewReportLineID);
    -- copy pdm destination
    CopyPDMDestination(l_TempReportLineID, l_NewReportLineID);

  END LOOP;

  CLOSE ReportLines;

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPLINE_PKG',
                                   'end DuplicateLines');

END DuplicateLines;

-------------------------------------------------------------------
PROCEDURE ResetAPValidationErrors(
  p_report_header_id     IN expLines_headerID) IS
-------------------------------------------------------------------
BEGIN

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPLINE_PKG', 'start ResetAPValidationErrors');

  UPDATE ap_expense_report_lines
  SET    ap_validation_error = ''
  WHERE  report_header_id = p_report_header_id;

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPLINE_PKG', 'end ResetAPValidationErrors');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('ResetAPValidationErrors');
      APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('ResetAPValidationErrors');
      APP_EXCEPTION.RAISE_EXCEPTION;

END ResetAPValidationErrors;

-------------------------------------------------------------------
PROCEDURE UpdateAPValidationError(
  p_report_header_id     IN expLines_headerID,
  p_dist_line_number     IN expLines_distLineNum,
  p_ap_validation_error  IN expLines_APValidationError) IS
-------------------------------------------------------------------
BEGIN

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPLINE_PKG', 'start UpdateAPValidationError');

/* Bug 3637166 : Doing a substrb before updation */

  UPDATE ap_expense_report_lines
  SET    ap_validation_error = substrb(ap_validation_error||p_ap_validation_error,1,240)
  WHERE  report_header_id = p_report_header_id
  AND    distribution_line_number = p_dist_line_number;

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPLINE_PKG', 'end UpdateAPValidationError');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('UpdateAPValidationError');
      APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('UpdateAPValidationError');
      APP_EXCEPTION.RAISE_EXCEPTION;

END UpdateAPValidationError;

-------------------------------------------------------------------
PROCEDURE resetAPflags(
  p_report_header_id     IN expLines_headerID) IS
-------------------------------------------------------------------
BEGIN

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPLINE_PKG', 'start resetAPflags');

  UPDATE ap_expense_report_lines
  SET    receipt_verified_flag = null,
         policy_shortpay_flag = null,
         adjustment_reason = null
  WHERE  report_header_id = p_report_header_id;

  UPDATE ap_expense_report_headers
  SET    audit_code = null, -- Bug 4019412
         report_submitted_date = null
  WHERE  report_header_id = p_report_header_id;

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPLINE_PKG', 'end resetAPflags');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('resetAPflags');
      APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('resetAPflags');
      APP_EXCEPTION.RAISE_EXCEPTION;

END resetAPflags;

-------------------------------------------------------------------
FUNCTION GetNumCashLinesWOMerch(p_report_header_id IN  expLines_headerID,
				p_count  OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
    SELECT count(*)
    INTO   p_count
    FROM   ap_expense_report_lines
    WHERE  report_header_id = p_report_header_id
    AND    merchant_name IS NOT NULL
    AND    credit_card_trx_id IS NULL;

    return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNumCashLinesWOMerch');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetNumCashLinesWOMerch;

-------------------------------------------------------------------

/**
 * jrautiai ADJ Fix start
 */

/**
 * jrautiai ADJ Fix
 * Need the ability to insert a single row, this procedure inserts a row in the
 * database, using the data provided in the record given as parameter.
 */
PROCEDURE InsertLine(expense_line_rec     in AP_EXPENSE_REPORT_LINES_ALL%ROWTYPE) IS
  l_debug_info varchar2(240);
BEGIN

  l_debug_info := 'InsertLine';

  INSERT INTO AP_EXPENSE_REPORT_LINES_ALL
    (REPORT_HEADER_ID,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CODE_COMBINATION_ID,
     ITEM_DESCRIPTION,
     SET_OF_BOOKS_ID,
     AMOUNT,
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
     ATTRIBUTE15,
     CURRENCY_CODE,
     EXCHANGE_RATE_TYPE,
     EXCHANGE_RATE,
     EXCHANGE_DATE,
     VAT_CODE,
     LINE_TYPE_LOOKUP_CODE,
     LAST_UPDATE_LOGIN,
     CREATION_DATE,
     CREATED_BY,
     STAT_AMOUNT,
     PROJECT_ACCOUNTING_CONTEXT,
     EXPENDITURE_TYPE,
     EXPENDITURE_ITEM_DATE,
     PA_QUANTITY,
     DISTRIBUTION_LINE_NUMBER,
     REFERENCE_1,
     REFERENCE_2,
     AWT_GROUP_ID,
     ORG_ID,
     RECEIPT_VERIFIED_FLAG,
     JUSTIFICATION_REQUIRED_FLAG,
     RECEIPT_REQUIRED_FLAG,
     RECEIPT_MISSING_FLAG,
     JUSTIFICATION,
     EXPENSE_GROUP,
     START_EXPENSE_DATE,
     END_EXPENSE_DATE,
     RECEIPT_CURRENCY_CODE,
     RECEIPT_CONVERSION_RATE,
     DAILY_AMOUNT,
     RECEIPT_CURRENCY_AMOUNT,
     WEB_PARAMETER_ID,
     GLOBAL_ATTRIBUTE_CATEGORY,
     GLOBAL_ATTRIBUTE1,
     GLOBAL_ATTRIBUTE2,
     GLOBAL_ATTRIBUTE3,
     GLOBAL_ATTRIBUTE4,
     GLOBAL_ATTRIBUTE5,
     GLOBAL_ATTRIBUTE6,
     GLOBAL_ATTRIBUTE7,
     GLOBAL_ATTRIBUTE8,
     GLOBAL_ATTRIBUTE9,
     GLOBAL_ATTRIBUTE10,
     AMOUNT_INCLUDES_TAX_FLAG,
     GLOBAL_ATTRIBUTE11,
     GLOBAL_ATTRIBUTE12,
     GLOBAL_ATTRIBUTE13,
     GLOBAL_ATTRIBUTE14,
     GLOBAL_ATTRIBUTE15,
     GLOBAL_ATTRIBUTE16,
     GLOBAL_ATTRIBUTE17,
     GLOBAL_ATTRIBUTE18,
     GLOBAL_ATTRIBUTE19,
     GLOBAL_ATTRIBUTE20,
     ADJUSTMENT_REASON,
     POLICY_SHORTPAY_FLAG,
     MERCHANT_DOCUMENT_NUMBER,
     MERCHANT_NAME,
     MERCHANT_REFERENCE,
     MERCHANT_TAX_REG_NUMBER,
     MERCHANT_TAXPAYER_ID,
     COUNTRY_OF_SUPPLY,
     TAX_CODE_OVERRIDE_FLAG,
     TAX_CODE_ID,
     CREDIT_CARD_TRX_ID,
     ALLOCATION_REASON,
     ALLOCATION_SPLIT_CODE,
     PROJECT_NAME,
     TASK_NAME,
     COMPANY_PREPAID_INVOICE_ID,
     PA_INTERFACED_FLAG,
     PROJECT_NUMBER,
     TASK_NUMBER,
     AWARD_NUMBER,
     VEHICLE_CATEGORY_CODE,
     VEHICLE_TYPE,
     FUEL_TYPE,
     NUMBER_PEOPLE,
     DAILY_DISTANCE,
     DISTANCE_UNIT_CODE,
     AVG_MILEAGE_RATE,
     DESTINATION_FROM,
     DESTINATION_TO,
     TRIP_DISTANCE,
     LICENSE_PLATE_NUMBER,
     MILEAGE_RATE_ADJUSTED_FLAG,
     LOCATION_ID,
     NUM_PDM_DAYS1,
     NUM_PDM_DAYS2,
     NUM_PDM_DAYS3,
     PER_DIEM_RATE1,
     PER_DIEM_RATE2,
     PER_DIEM_RATE3,
     DEDUCTION_ADDITION_AMT1,
     DEDUCTION_ADDITION_AMT2,
     DEDUCTION_ADDITION_AMT3,
     NUM_FREE_BREAKFASTS1,
     NUM_FREE_LUNCHES1,
     NUM_FREE_DINNERS1,
     NUM_FREE_ACCOMMODATIONS1,
     NUM_FREE_BREAKFASTS2,
     NUM_FREE_LUNCHES2,
     NUM_FREE_DINNERS2,
     NUM_FREE_ACCOMMODATIONS2,
     NUM_FREE_BREAKFASTS3,
     NUM_FREE_LUNCHES3,
     NUM_FREE_DINNERS3,
     NUM_FREE_ACCOMMODATIONS3,
     ATTENDEES,
     NUMBER_ATTENDEES,
     TRAVEL_TYPE,
     TICKET_CLASS_CODE,
     TICKET_NUMBER,
     FLIGHT_NUMBER,
     LOCATION_TO_ID,
     ITEMIZATION_PARENT_ID,
     FLEX_CONCATENATED,
     FUNC_CURRENCY_AMT,
     LOCATION,
     CATEGORY_CODE,
     ADJUSTMENT_REASON_CODE,
     AP_VALIDATION_ERROR,
     SUBMITTED_AMOUNT,
     REPORT_LINE_ID)
  VALUES (
     expense_line_rec.REPORT_HEADER_ID,
     expense_line_rec.LAST_UPDATE_DATE,
     expense_line_rec.LAST_UPDATED_BY,
     expense_line_rec.CODE_COMBINATION_ID,
     expense_line_rec.ITEM_DESCRIPTION,
     expense_line_rec.SET_OF_BOOKS_ID,
     expense_line_rec.AMOUNT,
     expense_line_rec.ATTRIBUTE_CATEGORY,
     expense_line_rec.ATTRIBUTE1,
     expense_line_rec.ATTRIBUTE2,
     expense_line_rec.ATTRIBUTE3,
     expense_line_rec.ATTRIBUTE4,
     expense_line_rec.ATTRIBUTE5,
     expense_line_rec.ATTRIBUTE6,
     expense_line_rec.ATTRIBUTE7,
     expense_line_rec.ATTRIBUTE8,
     expense_line_rec.ATTRIBUTE9,
     expense_line_rec.ATTRIBUTE10,
     expense_line_rec.ATTRIBUTE11,
     expense_line_rec.ATTRIBUTE12,
     expense_line_rec.ATTRIBUTE13,
     expense_line_rec.ATTRIBUTE14,
     expense_line_rec.ATTRIBUTE15,
     expense_line_rec.CURRENCY_CODE,
     expense_line_rec.EXCHANGE_RATE_TYPE,
     expense_line_rec.EXCHANGE_RATE,
     expense_line_rec.EXCHANGE_DATE,
     expense_line_rec.VAT_CODE,
     expense_line_rec.LINE_TYPE_LOOKUP_CODE,
     expense_line_rec.LAST_UPDATE_LOGIN,
     expense_line_rec.CREATION_DATE,
     expense_line_rec.CREATED_BY,
     expense_line_rec.STAT_AMOUNT,
     expense_line_rec.PROJECT_ACCOUNTING_CONTEXT,
     expense_line_rec.EXPENDITURE_TYPE,
     expense_line_rec.EXPENDITURE_ITEM_DATE,
     expense_line_rec.PA_QUANTITY,
     expense_line_rec.DISTRIBUTION_LINE_NUMBER,
     expense_line_rec.REFERENCE_1,
     expense_line_rec.REFERENCE_2,
     expense_line_rec.AWT_GROUP_ID,
     expense_line_rec.ORG_ID,
     expense_line_rec.RECEIPT_VERIFIED_FLAG,
     expense_line_rec.JUSTIFICATION_REQUIRED_FLAG,
     expense_line_rec.RECEIPT_REQUIRED_FLAG,
     expense_line_rec.RECEIPT_MISSING_FLAG,
     expense_line_rec.JUSTIFICATION,
     expense_line_rec.EXPENSE_GROUP,
     expense_line_rec.START_EXPENSE_DATE,
     expense_line_rec.END_EXPENSE_DATE,
     expense_line_rec.RECEIPT_CURRENCY_CODE,
     expense_line_rec.RECEIPT_CONVERSION_RATE,
     expense_line_rec.DAILY_AMOUNT,
     expense_line_rec.RECEIPT_CURRENCY_AMOUNT,
     expense_line_rec.WEB_PARAMETER_ID,
     expense_line_rec.GLOBAL_ATTRIBUTE_CATEGORY,
     expense_line_rec.GLOBAL_ATTRIBUTE1,
     expense_line_rec.GLOBAL_ATTRIBUTE2,
     expense_line_rec.GLOBAL_ATTRIBUTE3,
     expense_line_rec.GLOBAL_ATTRIBUTE4,
     expense_line_rec.GLOBAL_ATTRIBUTE5,
     expense_line_rec.GLOBAL_ATTRIBUTE6,
     expense_line_rec.GLOBAL_ATTRIBUTE7,
     expense_line_rec.GLOBAL_ATTRIBUTE8,
     expense_line_rec.GLOBAL_ATTRIBUTE9,
     expense_line_rec.GLOBAL_ATTRIBUTE10,
     expense_line_rec.AMOUNT_INCLUDES_TAX_FLAG,
     expense_line_rec.GLOBAL_ATTRIBUTE11,
     expense_line_rec.GLOBAL_ATTRIBUTE12,
     expense_line_rec.GLOBAL_ATTRIBUTE13,
     expense_line_rec.GLOBAL_ATTRIBUTE14,
     expense_line_rec.GLOBAL_ATTRIBUTE15,
     expense_line_rec.GLOBAL_ATTRIBUTE16,
     expense_line_rec.GLOBAL_ATTRIBUTE17,
     expense_line_rec.GLOBAL_ATTRIBUTE18,
     expense_line_rec.GLOBAL_ATTRIBUTE19,
     expense_line_rec.GLOBAL_ATTRIBUTE20,
     expense_line_rec.ADJUSTMENT_REASON,
     expense_line_rec.POLICY_SHORTPAY_FLAG,
     expense_line_rec.MERCHANT_DOCUMENT_NUMBER,
     expense_line_rec.MERCHANT_NAME,
     expense_line_rec.MERCHANT_REFERENCE,
     expense_line_rec.MERCHANT_TAX_REG_NUMBER,
     expense_line_rec.MERCHANT_TAXPAYER_ID,
     expense_line_rec.COUNTRY_OF_SUPPLY,
     expense_line_rec.TAX_CODE_OVERRIDE_FLAG,
     expense_line_rec.TAX_CODE_ID,
     expense_line_rec.CREDIT_CARD_TRX_ID,
     expense_line_rec.ALLOCATION_REASON,
     expense_line_rec.ALLOCATION_SPLIT_CODE,
     expense_line_rec.PROJECT_NAME,
     expense_line_rec.TASK_NAME,
     expense_line_rec.COMPANY_PREPAID_INVOICE_ID,
     expense_line_rec.PA_INTERFACED_FLAG,
     expense_line_rec.PROJECT_NUMBER,
     expense_line_rec.TASK_NUMBER,
     expense_line_rec.AWARD_NUMBER,
     expense_line_rec.VEHICLE_CATEGORY_CODE,
     expense_line_rec.VEHICLE_TYPE,
     expense_line_rec.FUEL_TYPE,
     expense_line_rec.NUMBER_PEOPLE,
     expense_line_rec.DAILY_DISTANCE,
     expense_line_rec.DISTANCE_UNIT_CODE,
     expense_line_rec.AVG_MILEAGE_RATE,
     expense_line_rec.DESTINATION_FROM,
     expense_line_rec.DESTINATION_TO,
     expense_line_rec.TRIP_DISTANCE,
     expense_line_rec.LICENSE_PLATE_NUMBER,
     expense_line_rec.MILEAGE_RATE_ADJUSTED_FLAG,
     expense_line_rec.LOCATION_ID,
     expense_line_rec.NUM_PDM_DAYS1,
     expense_line_rec.NUM_PDM_DAYS2,
     expense_line_rec.NUM_PDM_DAYS3,
     expense_line_rec.PER_DIEM_RATE1,
     expense_line_rec.PER_DIEM_RATE2,
     expense_line_rec.PER_DIEM_RATE3,
     expense_line_rec.DEDUCTION_ADDITION_AMT1,
     expense_line_rec.DEDUCTION_ADDITION_AMT2,
     expense_line_rec.DEDUCTION_ADDITION_AMT3,
     expense_line_rec.NUM_FREE_BREAKFASTS1,
     expense_line_rec.NUM_FREE_LUNCHES1,
     expense_line_rec.NUM_FREE_DINNERS1,
     expense_line_rec.NUM_FREE_ACCOMMODATIONS1,
     expense_line_rec.NUM_FREE_BREAKFASTS2,
     expense_line_rec.NUM_FREE_LUNCHES2,
     expense_line_rec.NUM_FREE_DINNERS2,
     expense_line_rec.NUM_FREE_ACCOMMODATIONS2,
     expense_line_rec.NUM_FREE_BREAKFASTS3,
     expense_line_rec.NUM_FREE_LUNCHES3,
     expense_line_rec.NUM_FREE_DINNERS3,
     expense_line_rec.NUM_FREE_ACCOMMODATIONS3,
     expense_line_rec.ATTENDEES,
     expense_line_rec.NUMBER_ATTENDEES,
     expense_line_rec.TRAVEL_TYPE,
     expense_line_rec.TICKET_CLASS_CODE,
     expense_line_rec.TICKET_NUMBER,
     expense_line_rec.FLIGHT_NUMBER,
     expense_line_rec.LOCATION_TO_ID,
     expense_line_rec.ITEMIZATION_PARENT_ID,
     expense_line_rec.FLEX_CONCATENATED,
     expense_line_rec.FUNC_CURRENCY_AMT,
     expense_line_rec.LOCATION,
     expense_line_rec.CATEGORY_CODE,
     expense_line_rec.ADJUSTMENT_REASON_CODE,
     expense_line_rec.AP_VALIDATION_ERROR,
     expense_line_rec.SUBMITTED_AMOUNT,
     ap_expense_report_lines_s.nextval);

EXCEPTION
  WHEN TOO_MANY_ROWS OR NO_DATA_FOUND THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('InsertLine','',
				  'AP_WEB_SAVESUB_DELETE_FAILED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('InsertLine',
				    l_debug_Info);
      APP_EXCEPTION.RAISE_EXCEPTION;

END InsertLine;

/**
 * jrautiai ADJ Fix
 * Modified the amount calculating routine to centralize the different payment scenario
 * calculations in one place.
 */
FUNCTION CalculateAmtsDue(p_report_header_id   IN  expLines_headerID,
                          p_payment_due_from   IN  VARCHAR2,
                          p_emp_amt            OUT NOCOPY NUMBER,
                          p_ccard_amt          OUT NOCOPY NUMBER,
                          p_total_amt          OUT NOCOPY NUMBER
) RETURN BOOLEAN IS
  l_personal_total NUMBER := 0;
  l_cash_amt       NUMBER := 0;
  l_ccard_amt      NUMBER := 0;
  l_total_amt      NUMBER := 0;
  l_company_pay    VARCHAR2(100) := AP_WEB_EXPENSE_WF.C_CompanyPay;
  l_personalParameterId  AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_paramID;
BEGIN

    IF (NOT AP_WEB_DB_EXPTEMPLATE_PKG.GetPersonalParamID(l_personalParameterId)) THEN
      l_personalParameterId := fnd_api.G_MISS_NUM;
    END IF;

   /**
    * Calculate the following amounts:
    * l_cash_amt = The total reimbursable amount of cash lines on the report
    * l_ccard_amt = The total reimbursable amount of credit card lines on the report.
    *               For company pay scenario this amount is always the original total
    *               amount, since it was already paid to the cc issuer.
    * l_total_amt = The total reimbursable amount of all lines. Since for company pay
    *               underitemization case we have negative amount for the personal amount
    *               which is already included in the reimbursable amounts of the other
    *               underitemized lines it is not included in the calculations.
    */
    SELECT sum(DECODE(credit_card_trx_id, null,amount,0)),
           sum(DECODE(credit_card_trx_id,
                      null,0,
                      DECODE(web_parameter_id,
                             l_personalParameterId,ABS(amount),
                             amount
                             )
                      )
               ),
           sum(DECODE(web_parameter_id,
                      l_personalParameterId,0,
                      AMOUNT))
    INTO   l_cash_amt, l_ccard_amt, l_total_amt
    FROM   ap_expense_report_lines
    WHERE  report_header_id = p_report_header_id
       AND (itemization_parent_id is null OR itemization_parent_id <> -1);

    l_cash_amt  := NVL(l_cash_amt,0);
    l_ccard_amt := NVL(l_ccard_amt,0);
    l_total_amt := NVL(l_total_amt,0);

   /**
    * Different calculations are different depending on the payment scenario. Branch the code
    * depending on the scenario.
    */
    IF (p_payment_due_from = AP_WEB_EXPENSE_WF.C_CompanyPay) THEN

      IF (NOT AP_WEB_DB_EXPLINE_PKG.GetPersonalTotalOfExpRpt(p_report_header_id, l_personal_total)) THEN
	  l_personal_total := 0;
      END IF;
     /**
      * For company pay the amount due employee is the total of cash lines subtracted with the personal
      * amount created for underitemization or auditor adjustment. In case the personal amount is greater
      * than the cash due, the amount due employee is also negative indicating that employee owes the
      * company money.
      */
      p_emp_amt   := l_cash_amt - ABS(l_personal_total);

     /**
      * For company pay the amount due credit card issuer always the original total amount, since it was
      * already paid to the cc issuer.
      */
      p_ccard_amt := l_ccard_amt;
      p_total_amt := l_total_amt;

    ELSIF (p_payment_due_from = AP_WEB_EXPENSE_WF.C_IndividualPay) THEN

     /**
      * For individual pay the employee is paying for all the expenses and receiving the reimbursement in cash.
      * So the amount due to the employee is the total of the expense report, amount due cc issuer is 0.
      */
      p_emp_amt   := l_total_amt;
      p_ccard_amt := 0;
      p_total_amt := l_total_amt;

    ELSIF (p_payment_due_from = AP_WEB_EXPENSE_WF.C_BothPay) THEN

     /**
      * For both pay the company is paying for business cc expenses, note this amount includes the auditor
      * adjustments, the adjusted amount is displayed to the user as personal cc expense.
      */
      p_emp_amt   := l_cash_amt;
      p_ccard_amt := l_ccard_amt;
      p_total_amt := l_total_amt;

    ELSE
     /**
      * If payment scenario not provided, populate based on the calculations.
      */
      p_emp_amt   := l_cash_amt;
      p_ccard_amt := l_ccard_amt;
      p_total_amt := l_total_amt;
    END IF;

    return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_emp_amt := 0;
    p_ccard_amt := 0;
    p_total_amt := 0;
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('CalculateAmtsDue');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END CalculateAmtsDue;

/**
 * jrautiai ADJ Fix
 * Check whether a report has been shortpaid, used in the workflow logic to display messages.
 */
FUNCTION GetShortpaidFlag( p_report_header_id 	IN  expLines_headerID,
                           p_shortpaid_flag     OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
BEGIN
  select decode(shortpay_parent_id, null, 'N','Y')
  into   p_shortpaid_flag
  from   ap_expense_report_headers
  where  report_header_id = p_report_header_id;

  RETURN TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_shortpaid_flag := 'N';
    return FALSE;

  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetShortpaidFlag');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;

END GetShortpaidFlag;

-----------------------------------------------------------------------------------------------------
FUNCTION GetNumPolicyShortpaidLines(p_report_header_id IN expLines_headerID,
				    p_count            OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
-----------------------------------------------------------------------------------------------------
BEGIN
      SELECT count(*)
      INTO   p_count
      FROM   ap_expense_report_lines
      WHERE  report_header_id = p_report_header_id
      AND    (itemization_parent_id is null or itemization_parent_id = -1)
      AND    nvl(policy_shortpay_flag, 'N') = 'Y';

    RETURN true;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNumPolicyShortpaidLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetNumPolicyShortpaidLines;

FUNCTION GetAdjustedLineExists(p_report_header_id IN  expLines_headerID)
RETURN BOOLEAN IS

  CURSOR result_cur IS
    SELECT sum(amount), sum(nvl(submitted_amount,0))
    FROM   ap_expense_report_lines aerl
    WHERE  aerl.report_header_id = p_report_header_id
    AND    (itemization_parent_id is null OR itemization_parent_id = -1)
    AND    aerl.credit_card_trx_id is null ;

  CURSOR cc_result_cur IS
    SELECT report_header_id
    FROM   ap_expense_report_lines aerl
    WHERE  aerl.report_header_id = p_report_header_id
    AND    (itemization_parent_id is null OR itemization_parent_id = -1)
    AND    aerl.credit_card_trx_id is not null
    AND    NVL(submitted_amount,amount) <> amount;

  cc_result_rec cc_result_cur%ROWTYPE;
  l_amount number;
  l_submitted_amount number;

BEGIN
    /* Bug 3693572 : If the expense report total is unchanged, and if
     * cash and other expenses only are adjusted, then do not send the
     * notification.
     */
  IF p_report_header_id is NULL THEN
    RETURN FALSE;
  END IF;

  OPEN cc_result_cur;
  FETCH cc_result_cur INTO cc_result_rec;
  IF cc_result_cur%FOUND THEN
    CLOSE cc_result_cur;
    RETURN TRUE;
  ELSE
    CLOSE cc_result_cur;
      OPEN result_cur;
      FETCH result_cur INTO l_amount, l_submitted_amount;
      IF result_cur%FOUND THEN
         CLOSE result_cur;
         IF l_amount <> l_submitted_amount THEN
           RETURN TRUE;
         ELSE
           RETURN FALSE;
         END IF;
      ELSE
         CLOSE result_cur;
         RETURN FALSE;
      END IF;
   END IF;
END GetAdjustedLineExists;


PROCEDURE ResetShortpayAdjustmentInfo(p_report_header_id IN  expLines_headerID) IS
BEGIN


    UPDATE ap_expense_report_lines
    SET    submitted_amount = amount
    WHERE  report_header_id = p_report_header_id;

EXCEPTION
  WHEN OTHERS THEN
    /* If an exception happens there is nothing we can do about it, so catching
     * the exception and suppressing it. In case the adjusted amount should have
     * been updated, but the update fails for some reason here, the implication is
     * that the employee will get a adjustment notification when the shortpaid report
     * is audited. Even if the auditor did not adjust the report. */
     null;
END ResetShortpayAdjustmentInfo;

/**
 * jrautiai ADJ Fix end
 */

-------------------------------------------------------------------
FUNCTION GetCountyProvince(
p_addressstyle  IN  per_addresses.style%TYPE,
p_region        IN  per_addresses.region_1%TYPE)
RETURN VARCHAR2
AS
 l_dflex_r                                               fnd_dflex.dflex_r;
 l_dflex_dr                                              fnd_dflex.dflex_dr;
 l_contexts_dr                                           fnd_dflex.contexts_dr;
 l_segments_dr                                           fnd_dflex.segments_dr;
 l_valueset_id                                           fnd_descr_flex_col_usage_vl.flex_value_set_id%TYPE;
 l_vset_r                                                fnd_vset.valueset_r;
 l_value_dr                                              fnd_vset.value_dr;
 l_vset_dr                                               fnd_vset.valueset_dr;
 l_resultval                                             VARCHAR2(2000);
 l_found                                                 BOOLEAN;
 l_rowcount                                              NUMBER;
 l_region                                                per_addresses.region_1%TYPE;
BEGIN

--Customizing for Guatemala,  Costa Rica, Chile
   -- Bug: 7365109
   l_region := p_region;
   IF p_addressstyle = 'CL_GLB' OR p_addressstyle = 'GT_GLB' OR p_addressstyle = 'CR_GLB'
      OR AP_WEB_CUST_DFLEX_PKG.CustomGetCountyProvince(p_addressstyle, l_region) then
     return l_region;
   END IF;

   fnd_dflex.get_flexfield('PER','Address Structure',l_dflex_r,l_dflex_dr);
   fnd_dflex.get_segments(fnd_dflex.make_context(l_dflex_r,p_addressStyle),l_segments_dr,TRUE);

   FOR i IN 1 .. l_segments_dr.nsegments LOOP
      IF (UPPER(l_segments_dr.segment_name(i)) IN ('COUNTY','PROVINCE')) THEN
                  l_valueset_id := l_segments_dr.value_set(i);
                  EXIT;
          END IF;
   END LOOP;

   fnd_vset.get_valueset(l_valueset_id, l_vset_r, l_vset_dr);

   fnd_vset.get_value_init(l_vset_r, TRUE);

   fnd_vset.get_value(l_vset_r, l_rowcount, l_found, l_value_dr);
   WHILE(l_found) LOOP
      IF (l_value_dr.id = p_region) THEN
          l_resultval := l_value_dr.value;
          EXIT;
      END IF;
      fnd_vset.get_value(l_vset_r, l_rowcount, l_found, l_value_dr);
   END LOOP;

   fnd_vset.get_value_end(l_vset_r);
   RETURN l_resultval;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      RETURN p_region;
  WHEN OTHERS THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('GetCountyProvince');
      APP_EXCEPTION.RAISE_EXCEPTION;
END;




/*Bug 2944363: Defined this function to get Personal Credit Card
               Information in Both Pay Scenario.
*/

--AMMISHRA - Both Pay Personal Only Lines project.

--------------------------------------------------------------------------------
FUNCTION GetBothPayPersonalLinesCursor(
        p_report_header_id      IN      expLines_headerID,
        p_personal_lines_cursor OUT NOCOPY DisplayXpenseLinesCursor)
RETURN BOOLEAN IS
-------------------------------------------------------------------------------
BEGIN

  OPEN p_personal_lines_cursor FOR
   SELECT to_char(nvl(CC.TRANSACTION_DATE,SYSDATE)),
           LPAD(to_char(CC.expensed_amount),9),
           CC.billed_currency_code,
           nvl(CC.Merchant_name1 , Merchant_name2)
   FROM    ap_expense_report_headers XH,
           ap_credit_card_trxns CC,
           ap_lookup_codes alc
   WHERE   XH.report_header_id = p_report_header_id
   AND     XH.report_header_id = CC.report_header_id
   AND     XH.total = 0
   AND     alc.lookup_type = 'PAYMENT_DUE_FROM'
   AND     alc.lookup_code = CC.payment_due_from_code
   AND     alc.lookup_code = 'BOTH'
   AND     NOT EXISTS(SELECT 1 from AP_EXPENSE_REPORT_LINES XL
                        WHERE XH.report_header_id = XL.report_header_id);
   return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetBothPayPersonalLinesCursor');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetBothPayPersonalLinesCursor;


/*Bug 2944363: Defined this function to get Personal Credit Card
               Information in Both Pay Scenario.
*/
--AMMISHRA - Both Pay Personal Only Lines project.
-------------------------------------------------------------------
FUNCTION GetNoOfBothPayPersonalLines(p_report_header_id IN  expLines_headerID,
                             p_personal_count            OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN

  SELECT count(*)
  INTO   p_personal_count
  FROM    ap_expense_report_headers XH,
          ap_credit_card_trxns CC,
          ap_lookup_codes alc
  WHERE   XH.report_header_id = p_report_header_id
  AND     XH.report_header_id = CC.report_header_id
  AND     XH.total = 0
  AND     alc.lookup_type = 'PAYMENT_DUE_FROM'
  AND     alc.lookup_code = CC.payment_due_from_code
  AND     alc.lookup_code = 'BOTH'
  AND     NOT EXISTS(SELECT 1 from AP_EXPENSE_REPORT_LINES XL
                        WHERE XH.report_header_id = XL.report_header_id);
  return true;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNoOfBothPayPersonalLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetNoOfBothPayPersonalLines;

-----------------------------------------------------------------------------
/*Written By :Ron Langi
  Purpose    :Clears the Audit Return Reason and Instruction
              using the report_header_id.
*/
-----------------------------------------------------------------------------
PROCEDURE clearAuditReturnReasonInstr(
                                   p_report_header_id IN expLines_headerID)
IS

BEGIN
       AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_DB_EXPRPT_PKG', 'start clearAuditReturnReasonInstr');

       UPDATE ap_expense_report_lines aerl
       SET    aerl.adjustment_reason_code = '',
              aerl.adjustment_reason = '',
              aerl.policy_shortpay_flag = '' -- Bug 3683276
       WHERE  aerl.report_header_id = p_report_header_id;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
               RETURN ;
        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException('clearAuditReturnReasonInstr');
                APP_EXCEPTION.RAISE_EXCEPTION;
END clearAuditReturnReasonInstr;

/**
* aling
* Check to see if there are any policy violation
*/
--------------------------------------------------------------------------------
FUNCTION AnyPolicyViolation(p_report_header_id IN  expLines_headerID)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
  l_temp VARCHAR2(1);
BEGIN

    SELECT 'Y'
    INTO   l_temp
    FROM   ap_pol_violations
    WHERE  report_header_id = p_report_header_id
    and    rownum = 1;

  return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AnyPolicyViolation');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END AnyPolicyViolation;

--------------------------------------------------------------------------------
FUNCTION GetLineCCIDCursor(p_reportId         IN  expLines_headerID,
                           p_line_cursor      OUT NOCOPY ExpLineCCIDCursor)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN

  OPEN p_line_cursor FOR
    SELECT AERL.report_line_id,
           AERL.code_combination_id,
           AERL.amount
    FROM   AP_EXPENSE_REPORT_LINES AERL
    WHERE  REPORT_HEADER_ID = p_reportId;

  return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('GetLineCCIDCursor');
      APP_EXCEPTION.RAISE_EXCEPTION;
      return FALSE;
END GetLineCCIDCursor;

-------------------------------------------------------------------
PROCEDURE resetApplyAdvances(
  p_report_header_id     IN expLines_headerID) IS
-------------------------------------------------------------------
BEGIN

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPLINE_PKG', 'start resetApplyAdvances');

  -- bug : 4001778/3654956
  UPDATE ap_expense_report_headers_all
  SET    maximum_amount_to_apply = null,
         advance_invoice_to_apply = null,
         apply_advances_default = null,
         prepay_apply_flag = null,
         prepay_num = null,
         prepay_dist_num = null,
         prepay_apply_amount = null,
         prepay_gl_date = null,
         advances_justification = null
  WHERE  report_header_id = p_report_header_id;

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPLINE_PKG', 'end resetApplyAdvances');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('resetApplyAdvances');
      APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('resetApplyAdvances');
      APP_EXCEPTION.RAISE_EXCEPTION;

END resetApplyAdvances;

      -- 5666256:  fp of 5464957 when accessing confirmation page from e-mail or comming from DBI
      -- or other resp that have profile OIE;Credit Cards set to N/null then the CC lines
      -- would not be displayed even if they exist in the report.
      FUNCTION ReportInclsCCardLines(p_report_header_id IN NUMBER) RETURN VARCHAR2 IS
      l_cc_lines_exist VARCHAR2(1);
      BEGIN
          l_cc_lines_exist := 'N';

          select 'Y' into l_cc_lines_exist
          from   ap_expense_report_lines_all
          where  report_header_id = p_report_header_id
          and    credit_card_trx_id is not null
          and    rownum = 1;

          RETURN l_cc_lines_exist;

      EXCEPTION
        WHEN OTHERS THEN
          RETURN l_cc_lines_exist;

      END ReportInclsCCardLines;

FUNCTION GetNumImageShortpaidLines(p_report_header_id 		IN expLines_headerID,
				   p_count            OUT NOCOPY NUMBER) RETURN BOOLEAN IS
BEGIN

SELECT count(*)
      INTO   p_count
      FROM   ap_expense_report_lines
      WHERE  report_header_id = p_report_header_id
      AND    nvl(policy_shortpay_flag, 'N') = 'N'
      AND    nvl(image_receipt_required_flag, 'N') = 'Y'
      AND    nvl(receipt_verified_flag, 'N') = 'N'
      AND    nvl(adjustment_reason_code,'X') IN ('MISSING_IMAGE_RECEIPTS', 'IMAGE_RECEIPTS_UNCLEAR');

    RETURN true;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNumImageShortpaidLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;

END GetNumImageShortpaidLines;

FUNCTION GetNumOriginalShortpaidLines(p_report_header_id           IN expLines_headerID,
                                   p_count            OUT NOCOPY NUMBER) RETURN BOOLEAN IS
BEGIN

SELECT count(*)
      INTO   p_count
      FROM   ap_expense_report_lines
      WHERE  report_header_id = p_report_header_id
      AND    nvl(policy_shortpay_flag, 'N') = 'N'
      AND    nvl(receipt_required_flag, 'N') = 'Y'
      AND    nvl(receipt_verified_flag, 'N') = 'N'
      AND    nvl(adjustment_reason_code,'X') IN ('MISSING_RECEIPT', 'ORIGINAL_RECEIPTS_MISSING');

    RETURN true;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNumOriginalShortpaidLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;

END GetNumOriginalShortpaidLines;


FUNCTION GetNumBothShortpaidLines(p_report_header_id 		IN expLines_headerID,
				   p_count            OUT NOCOPY NUMBER) RETURN BOOLEAN IS
BEGIN

SELECT count(*)
      INTO   p_count
      FROM   ap_expense_report_lines
      WHERE  report_header_id = p_report_header_id
      AND    nvl(policy_shortpay_flag, 'N') = 'N'
      AND    nvl(receipt_required_flag,'N') = 'Y'
      AND    nvl(image_receipt_required_flag, 'N') = 'Y'
      AND    nvl(receipt_verified_flag, 'N') = 'N'
      AND    nvl(adjustment_reason_code,'X') IN ('ORIG_REQ_IMG_UNCLEAR', 'RECEIPTS_NOT_RECEIVED');

    RETURN true;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNumImageShortpaidLines');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;

END GetNumBothShortpaidLines;

END AP_WEB_DB_EXPLINE_PKG;

/
