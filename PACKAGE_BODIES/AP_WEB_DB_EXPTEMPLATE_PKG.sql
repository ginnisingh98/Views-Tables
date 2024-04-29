--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_EXPTEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_EXPTEMPLATE_PKG" AS
/* $Header: apwdbetb.pls 120.8 2005/05/25 22:18:24 qle ship $ */
--------------------------------------------------------------------------------
FUNCTION GetWebEnabledTemplatesCursor(p_cursor OUT NOCOPY TemplateCursor)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
OPEN p_cursor FOR
    SELECT expense_report_id, report_type
    FROM   ap_expense_reports
    WHERE  web_enabled_flag = 'Y'
    AND    trunc(sysdate) <= trunc(nvl(inactive_date, sysdate))
    AND    AP_WEB_DB_EXPTEMPLATE_PKG.IsExpTemplateWebEnabled(expense_report_id) = 'Y'
    ORDER BY UPPER(report_type);

    return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetWebEnabledTemplatesCursor');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetWebEnabledTemplatesCursor;

--------------------------------------------------------------------------------
FUNCTION GetExpTypesOfTemplateCursor(p_xtemplateid IN  expTypes_reportID,
				p_cursor	   OUT NOCOPY ExpTypesOfTemplateCursor)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
OPEN P_cursor FOR
    SELECT  nvl(erp.web_friendly_prompt, erp.prompt),
            to_char(erp.parameter_id)
    FROM    ap_lookup_codes lc,
            ap_expense_report_params erp,
	    ap_expense_reports er
    WHERE   (erp.expense_report_id = p_xtemplateid
    OR      ( erp.web_enabled_flag = 'Y'
	       AND     trunc(sysdate) <= trunc(nvl(er.inactive_date, sysdate))
	     )
            )
    AND     lc.lookup_type = 'INVOICE DISTRIBUTION TYPE'
    AND     erp.expense_report_id = er.expense_report_id
    AND     erp.line_type_lookup_code = lc.lookup_code
    AND     trunc(sysdate) <= trunc(nvl(erp.end_date, sysdate))
    ORDER BY nvl(web_friendly_prompt, prompt);

    return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetExpTypesOfTemplateCursor');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetExpTypesOfTemplateCursor;

--------------------------------------------------------------------------------
FUNCTION GetAllExpenseTypesCursor(p_cursor OUT NOCOPY AllExpenseTypesCursor)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
OPEN p_cursor FOR
    SELECT  nvl(web_friendly_prompt, prompt) web_prompt,
            erp.parameter_id,
            erp.justification_required_flag,
            erp.require_receipt_amount
    FROM    ap_expense_report_params erp;

  return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetAllExpenseTypesCursor');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetAllExpenseTypesCursor;

--------------------------------------------------------------------------------
FUNCTION GetExpTypesCursor(p_report_id IN  expTempl_reportID,
			   p_cursor    OUT NOCOPY ExpenseTypesCursor)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
OPEN p_cursor FOR

    SELECT  distinct erp.parameter_id,
            nvl(erp.web_friendly_prompt,erp.prompt) web_prompt,
	    erp.require_receipt_amount,
	    erp.card_exp_type_lookup_code,
            erp.amount_includes_tax_flag,
	    nvl(erp.justification_required_flag,'V') justif_req
    FROM    ap_expense_report_params erp,
	    ap_expense_reports er
    WHERE   erp.expense_report_id = p_report_id
       OR   (erp.web_enabled_flag = 'Y'
       AND   er.web_enabled_flag = 'Y'
       AND    trunc(sysdate) <= trunc(nvl(inactive_date, sysdate))
       AND   erp.expense_report_id = er.expense_report_id)
       AND    trunc(sysdate) <= trunc(nvl(erp.end_date, sysdate))
    ORDER BY web_prompt;


  return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetExpTypesCursor');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetExpTypesCursor;

--------------------------------------------------------------------------------
FUNCTION GetWebExpTypesCursor(p_cursor    OUT NOCOPY WebExpenseTypesCursor)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
OPEN p_cursor FOR
    SELECT  erp.parameter_id,
	    nvl(erp.web_friendly_prompt,erp.prompt) web_prompt,
 	    erp.prompt,
	    erp.require_receipt_amount,
	    card_exp_type_lookup_code,
	    nvl(erp.justification_required_flag,'V') justif_req,
	    calculate_amount_flag,
	    erp.amount_includes_tax_flag,
	    erp.pa_expenditure_type
    FROM    ap_expense_report_params erp,
	    ap_expense_reports er
    WHERE   erp.expense_report_id = er.expense_report_id
      AND   trunc(sysdate) <= trunc(nvl(er.inactive_date, sysdate))
      AND   trunc(sysdate) <= trunc(nvl(erp.end_date, sysdate))
      AND   er.web_enabled_flag = 'Y';

    return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetWebExpTypesCursor');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetWebExpTypesCursor;


--------------------------------------------------------------------------------
FUNCTION GetJustifReqdExpTypesCursor(p_cursor    OUT NOCOPY JustificationExpTypeCursor)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
OPEN p_cursor FOR
    SELECT  erp.parameter_id
    FROM    ap_expense_report_params erp
    WHERE   nvl(erp.justification_required_flag,'V') = 'Y'
    ORDER BY nvl(web_friendly_prompt, prompt);

    return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetJustifReqdExpTypesCursor');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetJustifReqdExpTypesCursor;


--------------------------------------------------------------------------------
FUNCTION GetTemplateName(P_TemplateID 		IN  expTypes_reportID,
			 P_TemplateName	    OUT NOCOPY expTypes_reportType)

RETURN BOOLEAN IS
--------------------------------------------------------------------------------
  l_debugInfo    varchar2(240);
BEGIN

 -------------------------------------------------------
  l_debugInfo := 'getTemplateName';
 -------------------------------------------------------
      SELECT report_type
      INTO   P_TemplateName
      FROM   ap_expense_reports                                                      WHERE  web_enabled_flag = 'Y'
      AND    expense_report_id = P_TemplateID;

      return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetTemplateName');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetTemplateName;


--------------------------------------------------------------------------------
FUNCTION GetExpTemplateId(
	p_report_type	IN	expTypes_reportType,
	p_exp_temp_id OUT NOCOPY expTypes_reportID)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
        -- Fix 1472710, Added check to verify if the template is valid.
	SELECT 	expense_report_id
	INTO	p_exp_temp_id
	FROM	ap_expense_reports
	WHERE	web_enabled_flag = 'Y'
        AND     trunc(sysdate) <= trunc(nvl(inactive_date, sysdate))
	AND	report_type = p_report_type;

	return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetExpTemplateId');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetExpTemplateId;

-------------------------------------------------------------------
FUNCTION GetExpTypePrompt(p_parameter_id 	   	IN  expTempl_paramID,
			  p_exp_prompt	 	 OUT NOCOPY expTempl_prompt)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
      SELECT prompt
      INTO   p_exp_prompt
      FROM   ap_expense_report_params
      WHERE  parameter_id = p_parameter_id;

   return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetExpTypePrompt');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetExpTypePrompt;

-------------------------------------------------------------------
FUNCTION GetPersonalParamID(p_parameter_id 	    OUT NOCOPY  expTempl_paramID)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  SELECT parameter_id
  INTO p_parameter_id
  FROM ap_expense_report_params
  WHERE expense_type_code = 'PERSONAL';

   return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetPersonalParamID');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetPersonalParamID;

-------------------------------------------------------------------
FUNCTION GetExpTypeInfo(P_ExpTypeID 	   		IN  expTempl_paramID,
			 P_ExpTypeRec	 		IN OUT NOCOPY ExpTypeInfoRec
			 ) RETURN BOOLEAN IS
-------------------------------------------------------------------
l_debug_info		  VARCHAR2(100);
l_curr_calling_sequence   VARCHAR2(100) := 'GetExpTypeInfo';
BEGIN
  -----------------------------------------------------------------
  l_debug_info := 'Retrieving line_type_lookup_code';
  -------------------------------------------------------------------
  SELECT FLEX_CONCACTENATED,
         VAT_CODE,
         AMOUNT_INCLUDES_TAX_FLAG,
         LINE_TYPE_LOOKUP_CODE,
	 PA_EXPENDITURE_TYPE
  INTO   P_ExpTypeRec.flex_concat,
         P_ExpTypeRec.vat_code,
         P_ExpTypeRec.amt_incl_tax,
         P_ExpTypeRec.line_type,
	 p_ExpTypeRec.pa_exp_type
  FROM AP_EXPENSE_REPORT_PARAMS
  WHERE PARAMETER_ID = P_ExpTypeID;

    return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetExpTypeInfo', l_debug_info);
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetExpTypeInfo;


-------------------------------------------------------------------
FUNCTION IsExpTemplateWebEnabled(p_expense_report_id IN ap_expense_reports.expense_report_id%TYPE)
RETURN VARCHAR2 IS
-------------------------------------------------------------------

  l_exp_types_cursor            AP_WEB_DB_EXPTEMPLATE_PKG.ExpenseTypesCursor;
  l_parameter_id                AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_paramID;
  l_web_FriendlyPrompt          AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_webFriendlyPrompt;
  l_require_receipt_amount      AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_requireReceiptAmt;
  l_card_exp_type_lookup_code   AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_cardExpTypeLookupCode;
  l_amount_includes_tax_flag    AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_amtInclTaxFlag;
  l_justif_req                  AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_justificationReqdFlag;

BEGIN

  IF (AP_WEB_DB_EXPTEMPLATE_PKG.GetExpTypesCursor(to_number(p_expense_report_id), l_exp_types_cursor)) THEN
    LOOP
      FETCH l_exp_types_cursor
      INTO  l_parameter_id,
            l_web_FriendlyPrompt,
            l_require_receipt_amount,
            l_card_exp_type_lookup_code,
            l_amount_includes_tax_flag,
            l_justif_req;
      EXIT WHEN l_exp_types_cursor%NOTFOUND;

      if (AP_WEB_OA_DISC_PKG.AreMPDRateSchedulesAssigned(l_parameter_id)
          or AP_WEB_OA_DISC_PKG.ArePCRateSchedulesAssigned(l_parameter_id)
          or AP_WEB_OA_DISC_PKG.AreExpenseFieldsRequired(l_parameter_id)
          or AP_WEB_OA_DISC_PKG.AreExpenseFieldsEnabled(l_parameter_id)
          or AP_WEB_OA_DISC_PKG.IsItemizationRequired(l_parameter_id)
         ) then
        CLOSE l_exp_types_cursor;
        return 'N';
      end if;

    END LOOP;
    CLOSE l_exp_types_cursor;

    return 'Y';

  END IF;

  return 'N';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return 'N';
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('IsExpTemplateWebEnabled');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return 'N';
END IsExpTemplateWebEnabled;

-------------------------------------------------------------------
FUNCTION GetNumWebEnabledExpTemplates(p_count  OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  SELECT    COUNT(*)
  INTO      p_count
  FROM      ap_expense_reports
  WHERE     web_enabled_flag = 'Y'
  AND       trunc(sysdate) <= trunc(nvl(inactive_date, sysdate))
  AND       AP_WEB_DB_EXPTEMPLATE_PKG.IsExpTemplateWebEnabled(expense_report_id) = 'Y';

  return    TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_count := 0;
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNumWebEnabledExpTemplates');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetNumWebEnabledExpTemplates;


----------------------------------------------------------------------------
FUNCTION Get_ItemDesc_LookupCode(
	p_xtype 		IN 	VARCHAR2,
	p_item_description  OUT NOCOPY 	expTempl_prompt,
	p_line_type_lookup_code OUT NOCOPY 	expTempl_lineTypeLookupCode,
	p_require_receipt_amount OUT NOCOPY 	expTempl_requireReceiptAmt
) RETURN BOOLEAN IS
----------------------------------------------------------------------------
BEGIN
	IF (p_xtype is NULL) THEN
	  p_item_description := 'ITEM';
	  p_line_type_lookup_code := 'ITEM';
	  p_require_receipt_amount := 0;
        ELSE
	  SELECT nvl(prompt,'ITEM'),
                 nvl(line_type_lookup_code,'ITEM'),
	         nvl(require_receipt_amount,-1)
          INTO   p_item_description,
                 p_line_type_lookup_code,
	         p_require_receipt_amount
          FROM   AP_EXPENSE_REPORT_PARAMS
          WHERE  parameter_id = p_xtype;
	END IF;

	RETURN TRUE;

EXCEPTION
  	WHEN NO_DATA_FOUND THEN
   	 	RETURN FALSE;
  	WHEN OTHERS THEN
    		AP_WEB_DB_UTIL_PKG.RaiseException('Get_ItemDesc_LookupCode');
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END Get_ItemDesc_LookupCode;

-------------------------------------------------------------------
FUNCTION GetDefaultTemplateId(
	p_default_template_id  OUT NOCOPY AP_SYSTEM_PARAMETERS.expense_report_id%TYPE
)
RETURN BOOLEAN IS
-------------------------------------------------------------------
  l_base_curr_code              AP_WEB_DB_AP_INT_PKG.apSetup_baseCurrencyCode;
  l_set_of_books_id             AP_WEB_DB_AP_INT_PKG.apSetup_setOfBooksID;
  l_default_exch_rate_type      AP_WEB_DB_AP_INT_PKG.apSetUp_defaultExchRateType;
BEGIN
  return AP_WEB_DB_AP_INT_PKG.get_ap_system_params(p_base_curr_code => l_base_curr_code,
                                            p_set_of_books_id => l_set_of_books_id,
                                            p_expense_report_id => p_default_template_id,
                                            p_default_exch_rate_type => l_default_exch_rate_type);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_default_template_id := null;
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetDefaultTemplateId');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetDefaultTemplateId;


FUNCTION IsCustomCalculateEnabled(p_template_id	IN VARCHAR2,
				 p_parameter_id	IN VARCHAR2)
RETURN BOOLEAN IS

l_calculate_amount_enabled	AP_EXPENSE_REPORT_PARAMS.calculate_amount_flag%TYPE;
l_debug_info		       	VARCHAR2(2000);

BEGIN

   ------------------------------------------------------------------------
   l_debug_info := 'Retrieving Calculate Amount Flag for the expense type';
   ------------------------------------------------------------------------

    SELECT  erp.calculate_amount_flag
    INTO    l_calculate_amount_enabled
    FROM    ap_lookup_codes lc,
            ap_expense_report_params erp
    WHERE   (erp.expense_report_id 	= to_number(p_template_id)
    AND      erp.parameter_id 		= to_number(p_parameter_id))
    AND     erp.line_type_lookup_code = lc.lookup_code
    AND     lc.lookup_type = 'INVOICE DISTRIBUTION TYPE';

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    IF l_calculate_amount_enabled = 'Y' THEN
      return TRUE;
    ELSE
      return FALSE;
    END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN return FALSE;
  WHEN OTHERS THEN
    BEGIN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                   'IsCustomCalculateEnabled');
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
             'None passed.');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
	APP_EXCEPTION.RAISE_EXCEPTION;
      ELSE
        -- Do not need to set the token since it has been done in the
        -- child process
        RAISE;
      END IF;
    END;
END IsCustomCalculateEnabled;


-------------------------------------------------------------------
-- This function was added for bug 2771545
FUNCTION GetRequireReceiptAmt(P_ExpTypeID IN  expTempl_paramID,
           p_require_receipt_amount OUT NOCOPY expTempl_requireReceiptAmt
) RETURN BOOLEAN IS
-------------------------------------------------------------------
l_debug_info		  VARCHAR2(100);
l_curr_calling_sequence   VARCHAR2(100) := 'GetRequireReceiptAmt';

BEGIN
  -----------------------------------------------------------------
  l_debug_info := 'Retrieving require_receipt_amount';
  -------------------------------------------------------------------
  SELECT require_receipt_amount
  INTO p_require_receipt_amount
  FROM AP_EXPENSE_REPORT_PARAMS
  WHERE PARAMETER_ID = P_ExpTypeID;

  return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'GetRequireReceiptAmt');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
	APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      -- Do not need to set the token since it has been done in the
      -- child process
      RAISE;
    END IF;
END GetRequireReceiptAmt;

/* jrautiai ADJ Fix Start */
FUNCTION GetRoundingParamID(p_parameter_id OUT NOCOPY expTempl_paramID)
RETURN BOOLEAN IS
BEGIN
  SELECT parameter_id
  INTO p_parameter_id
  FROM ap_expense_report_params
  WHERE expense_type_code = 'ROUNDING';

   return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetRoundingParamID');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetRoundingParamID;
/* jrautiai ADJ Fix End */

END AP_WEB_DB_EXPTEMPLATE_PKG;

/
