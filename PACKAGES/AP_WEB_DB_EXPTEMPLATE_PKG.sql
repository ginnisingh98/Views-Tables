--------------------------------------------------------
--  DDL for Package AP_WEB_DB_EXPTEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_EXPTEMPLATE_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbets.pls 115.12 2003/08/15 10:59:50 jrautiai ship $ */

---------------------------------------------------------------------------------------------------
SUBTYPE expTempl_paramID			IS AP_EXPENSE_REPORT_PARAMS.parameter_id%TYPE;
SUBTYPE expTempl_reportID			IS AP_EXPENSE_REPORT_PARAMS.expense_report_id%TYPE;
SUBTYPE expTempl_flexConcat			IS AP_EXPENSE_REPORT_PARAMS.flex_concactenated%TYPE;
SUBTYPE expTempl_vatCode			IS AP_EXPENSE_REPORT_PARAMS.vat_code%TYPE;
SUBTYPE expTempl_amtInclTaxFlag			IS AP_EXPENSE_REPORT_PARAMS.amount_includes_tax_flag%TYPE;
SUBTYPE expTempl_lineTypeLookupCode		IS AP_EXPENSE_REPORT_PARAMS.line_type_lookup_code%TYPE;
SUBTYPE expTempl_prompt				IS AP_EXPENSE_REPORT_PARAMS.prompt%TYPE;
SUBTYPE expTempl_webFriendlyPrompt		IS AP_EXPENSE_REPORT_PARAMS.web_friendly_prompt%TYPE;
SUBTYPE expTempl_requireReceiptAmt		IS AP_EXPENSE_REPORT_PARAMS.require_receipt_amount%TYPE;
SUBTYPE expTempl_cardExpTypeLookupCode		IS AP_EXPENSE_REPORT_PARAMS.card_exp_type_lookup_code%TYPE;
SUBTYPE expTempl_justificationReqdFlag		IS AP_EXPENSE_REPORT_PARAMS.justification_required_flag%TYPE;
SUBTYPE expTempl_paExpenditureType		IS AP_EXPENSE_REPORT_PARAMS.pa_expenditure_type%TYPE;
SUBTYPE expTempl_calcAmtFlag			IS AP_EXPENSE_REPORT_PARAMS.calculate_amount_flag%TYPE;



SUBTYPE expTypes_reportID			IS AP_EXPENSE_REPORTS.expense_report_id%TYPE;
SUBTYPE expTypes_reportType			IS AP_EXPENSE_REPORTS.report_type%TYPE;
---------------------------------------------------------------------------------------------------

TYPE TemplateCursor 		IS REF CURSOR;
TYPE ExpTypesOfTemplateCursor 	IS REF CURSOR;
TYPE AllExpenseTypesCursor 	IS REF CURSOR;
TYPE ExpenseTypesCursor 	IS REF CURSOR;
TYPE WebExpenseTypesCursor 	IS REF CURSOR;
TYPE JustificationExpTypeCursor IS REF CURSOR;

--------------------------------------------------------------------------------------------
TYPE ExpTypeInfoRec IS RECORD (
  flex_concat		expTempl_flexConcat,
  vat_code		expTempl_vatCode,
  amt_incl_tax		expTempl_amtInclTaxFlag,
  line_type		expTempl_lineTypeLookupCode,
  pa_exp_type		expTempl_paExpendituretype
); /* End TYPE ExpTypeInfoRec */
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetWebEnabledTemplatesCursor(p_cursor OUT NOCOPY TemplateCursor)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetExpTypesOfTemplateCursor(p_xtemplateid IN  expTypes_reportID,
				p_cursor	   OUT NOCOPY ExpTypesOfTemplateCursor)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetAllExpenseTypesCursor(p_cursor OUT NOCOPY AllExpenseTypesCursor)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetExpTypesCursor(p_report_id IN  expTempl_reportID,
			   p_cursor    OUT NOCOPY ExpenseTypesCursor)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetWebExpTypesCursor(p_cursor    OUT NOCOPY WebExpenseTypesCursor)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetJustifReqdExpTypesCursor(p_cursor    OUT NOCOPY JustificationExpTypeCursor)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetTemplateName(P_TemplateID 		IN  expTypes_reportID,
			 P_TemplateName	    OUT NOCOPY expTypes_reportType)

RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetExpTemplateId(
	p_report_type	IN	expTypes_reportType,
	p_exp_temp_id OUT NOCOPY expTypes_reportID)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetExpTypePrompt(p_parameter_id 	   	IN  expTempl_paramID,
			  p_exp_prompt	 	 OUT NOCOPY expTempl_prompt
			 ) RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetPersonalParamID(p_parameter_id 	    OUT NOCOPY  expTempl_paramID)
RETURN BOOLEAN;
-------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetExpTypeInfo(P_ExpTypeID 	   		IN  expTempl_paramID,
			 P_ExpTypeRec	 		IN OUT NOCOPY ExpTypeInfoRec)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION IsExpTemplateWebEnabled(p_expense_report_id IN ap_expense_reports.expense_report_id%TYPE)
RETURN VARCHAR2;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetNumWebEnabledExpTemplates(p_count  OUT NOCOPY NUMBER)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

----------------------------------------------------------------------------
FUNCTION Get_ItemDesc_LookupCode(
	p_xtype 		IN 	VARCHAR2,
	p_item_description  OUT NOCOPY 	expTempl_prompt,
	p_line_type_lookup_code OUT NOCOPY 	expTempl_lineTypeLookupCode,
	p_require_receipt_amount OUT NOCOPY 	expTempl_requireReceiptAmt
) RETURN BOOLEAN;

FUNCTION GetDefaultTemplateId(
	p_default_template_id  OUT NOCOPY AP_SYSTEM_PARAMETERS.expense_report_id%TYPE
) RETURN BOOLEAN;

FUNCTION IsCustomCalculateEnabled(p_template_id	IN VARCHAR2,
				 p_parameter_id	IN VARCHAR2)
RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION GetRequireReceiptAmt(P_ExpTypeID IN  expTempl_paramID,
	   p_require_receipt_amount OUT NOCOPY expTempl_requireReceiptAmt
) RETURN BOOLEAN;
-------------------------------------------------------------------

/* jrautiai ADJ Fix Start */
FUNCTION GetRoundingParamID(p_parameter_id OUT NOCOPY expTempl_paramID)
RETURN BOOLEAN;
/* jrautiai ADJ Fix End */

END AP_WEB_DB_EXPTEMPLATE_PKG;

 

/
