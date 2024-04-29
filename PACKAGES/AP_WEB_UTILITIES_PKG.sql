--------------------------------------------------------
--  DDL for Package AP_WEB_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_UTILITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: apwxutls.pls 120.14.12010000.7 2010/06/26 16:29:22 rveliche ship $ */

-- rlangi - used for converting OIE specific messages to OME messages
C_WebApplicationVersion   CONSTANT VARCHAR2(1) := 'W';
C_MobileApplicationVersion   CONSTANT VARCHAR2(1) := 'M';
C_PAMessageCategory   CONSTANT VARCHAR2(15) := 'PA';  -- Project/Task errors
C_PATCMessageCategory   CONSTANT VARCHAR2(15) := 'PATC';  -- PATC errors
C_GMSMessageCategory   CONSTANT VARCHAR2(15) := 'GMS';  -- GMS errors
C_TaxMessageCategory   CONSTANT VARCHAR2(15) := 'TAX';  -- Tax errors
C_ItemizationMessageCategory   CONSTANT VARCHAR2(15) := 'ITEMIZATION';  -- Itemization errors
C_DFFMessageCategory   CONSTANT VARCHAR2(15) := 'DFF';  -- Flexfield errors
C_AcctgMessageCategory   CONSTANT VARCHAR2(15) := 'ACCTG';  -- Line accounting errors
C_OtherMessageCategory   CONSTANT VARCHAR2(15) := 'OTHER';  -- All other errors OME will display same OIE error

C_ErrorMessageType   CONSTANT VARCHAR2(10) := 'ERROR';
C_WarningMessageType CONSTANT VARCHAR2(10) := 'WARNING';
C_ProjectNumber_VRPrompt  CONSTANT NUMBER := 34;
C_TaskNumber_VRPrompt     CONSTANT NUMBER := 35;

-- chiho:1203036:
C_MSG_FIELD_LEN	CONSTANT NUMBER := 2000;
C_MSG_TEXT_LEN	CONSTANT NUMBER := 2000;

MSG_FIELD_TYPE	VARCHAR2(2000);
MSG_TEXT_TYPE	VARCHAR2(2000);


  C_IMG_DIR		CONSTANT VARCHAR2(10) := '/OA_MEDIA/';

  TYPE MiniString_Array IS TABLE OF VARCHAR2(25)
        INDEX BY BINARY_INTEGER;
  TYPE MedString_Array IS TABLE OF VARCHAR2(80)
        INDEX BY BINARY_INTEGER;
  TYPE BigString_Array IS TABLE OF VARCHAR2(240)
        INDEX BY BINARY_INTEGER;
  TYPE LongString_Array IS TABLE OF VARCHAR2(1000)
        INDEX BY BINARY_INTEGER;
  TYPE Number_Array IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
  TYPE Boolean_Array IS TABLE OF BOOLEAN
        INDEX BY BINARY_INTEGER;

TYPE MessageRec IS RECORD (
  receipt_num     INTEGER,
  message_type    VARCHAR2(10), -- ERROR/WARNING
  message_text    long := '',
  field_id1       integer,
  field_id2       integer,
  field_id3       integer,
  field_id4       integer,
  field_id5       integer );

TYPE MessageArray IS TABLE OF MessageRec
  INDEX BY BINARY_INTEGER;

TYPE expErrors IS RECORD (
  	text	LONG,
	type	VARCHAR2(25), -- Constant: error, warning
	field	VARCHAR2(35) := '',
	ind	BINARY_INTEGER := 0);

TYPE expError IS TABLE OF expErrors
	INDEX BY BINARY_INTEGER;

TYPE prompts_table IS table of varchar2(80)
        	    index by binary_integer;

-- Bug: 6220330
TYPE ExpensesToUpdate IS REF CURSOR;


FUNCTION GetIsMobileApp RETURN NUMBER;
FUNCTION IsMobileApp RETURN BOOLEAN;

-- rlangi: Diagnostic Logging
PROCEDURE LogException(p_pkgname IN VARCHAR2,
                       p_message IN VARCHAR2);

PROCEDURE LogEvent(p_pkgname IN VARCHAR2,
                       p_message IN VARCHAR2);

PROCEDURE LogProcedure(p_pkgname IN VARCHAR2,
                       p_message IN VARCHAR2);

PROCEDURE LogStatement(p_pkgname IN VARCHAR2,
                       p_message IN VARCHAR2);

PROCEDURE AddExpError(p_errors  IN OUT NOCOPY expError,
		p_text		IN VARCHAR2,
		p_type		IN VARCHAR2,
		p_field		IN VARCHAR2  DEFAULT NULL,
		p_index		IN BINARY_INTEGER DEFAULT 0,
		p_MessageCategory IN VARCHAR2 DEFAULT C_OtherMessageCategory,
                p_IsMobileApp   IN BOOLEAN DEFAULT false);

PROCEDURE AddExpErrorNotEncoded(p_errors  IN OUT NOCOPY expError,
		p_text		IN VARCHAR2,
		p_type		IN VARCHAR2,
		p_field		IN VARCHAR2  DEFAULT NULL,
		p_index		IN BINARY_INTEGER DEFAULT 0,
		p_MessageCategory IN VARCHAR2 DEFAULT C_OtherMessageCategory);

-- chiho:1203036:expand the fields length:
TYPE RECEIPT_ERROR_REC IS RECORD
(
  error_text		MSG_TEXT_TYPE%TYPE := '',
  error_fields   	MSG_FIELD_TYPE%TYPE := '',
  warning_text   	MSG_TEXT_TYPE%TYPE := '',
  warning_fields 	MSG_FIELD_TYPE%TYPE := ''
);

TYPE RECEIPT_ERROR_STACK IS TABLE OF RECEIPT_ERROR_REC
  INDEX BY BINARY_INTEGER;


PROCEDURE DisplayException (P_ErrorText Long);

PROCEDURE GetEmployeeInfo(p_employee_name       IN OUT NOCOPY  VARCHAR2,
                          p_employee_num        IN OUT NOCOPY  VARCHAR2,
                          p_cost_center         IN OUT NOCOPY  VARCHAR2,
                          p_employee_id         IN      NUMBER);


PROCEDURE MakeArray;
PROCEDURE MoneyFormat;
PROCEDURE MoneyFormat2;
PROCEDURE SetReceiptWarningErrorMessage;



PROCEDURE JustifFlagElement;
PROCEDURE RetrieveJustifFlag;
PROCEDURE RetrieveJustifFlagIndex;
PROCEDURE CurrencyInfo;
PROCEDURE RetrieveCurrencyIndex;
PROCEDURE PopulateCurrencyArray;
FUNCTION NDaysInCalendar(p_cal_end_date	IN DATE,
                         p_start_dow	IN NUMBER) RETURN NUMBER;
PROCEDURE GoBack;
PROCEDURE CancelExpenseReport;
PROCEDURE ExitExpenseReport;
PROCEDURE GetUserAgent(p_user_agent	IN OUT NOCOPY VARCHAR2);
PROCEDURE DisplayHelp(v_defHlp	IN VARCHAR2);
PROCEDURE OverrideRequired(p_apprReqCC  IN  varchar2,
                           p_overrideReq  IN  varchar2);

PROCEDURE PrepArg(p_arg in out nocopy long);
PROCEDURE DownloadHTML(P_FileName IN VARCHAR2);

FUNCTION ContainsErrorOrWarning(
  P_MessageArray          IN receipt_error_stack)
  RETURN BOOLEAN;

FUNCTION ContainsError(
  P_MessageArray          IN receipt_error_stack)
  RETURN BOOLEAN;

FUNCTION ContainsWarning(
  P_MessageArray          IN receipt_error_stack)
  RETURN BOOLEAN;

FUNCTION ReceiptContainsError(
  P_MessageArray          IN receipt_error_stack,
  P_ReceiptNumber         IN INTEGER)
  RETURN BOOLEAN;

FUNCTION ReceiptContainsWarning(
  P_MessageArray          IN receipt_error_stack,
  P_ReceiptNumber         IN INTEGER)
  RETURN BOOLEAN;

FUNCTION NumOfReceiptWithError(
  P_MessageArray          IN receipt_error_stack)
  RETURN NUMBER;

FUNCTION NumOfReceiptWithWarning(
  P_MessageArray IN receipt_error_stack)
  RETURN NUMBER;

FUNCTION NumOfValidReceipt(
  P_MessageArray          IN receipt_error_stack)
  RETURN NUMBER;

PROCEDURE AddMessage(
  P_MessageArray  IN OUT NOCOPY receipt_error_stack,
  P_ReceiptNum    IN INTEGER,
  P_MessageType   IN VARCHAR2,
  P_MessageText   IN VARCHAR2,
  P_Field1        IN VARCHAR2 DEFAULT NULL,
  P_Field2        IN VARCHAR2 DEFAULT NULL,
  P_Field3        IN VARCHAR2 DEFAULT NULL,
  P_Field4        IN VARCHAR2 DEFAULT NULL,
  P_Field5        IN VARCHAR2 DEFAULT NULL);

PROCEDURE MergeErrorStacks(p_ReceiptNum IN INTEGER,
                           P_Src1ReceiptStack IN
                             receipt_error_stack,
                           P_Src2ReceiptStack IN
                             receipt_error_stack,
                           P_TargetReceiptStack IN OUT
                             receipt_error_stack);

PROCEDURE MergeErrors(P_ExpErrors 		IN expError,
                      P_TargetReceiptStack 	IN OUT NOCOPY receipt_error_stack);

PROCEDURE MergeExpErrors(P_Src1 	IN  OUT NOCOPY expError,
                         P_Src2 	IN  expError);

PROCEDURE PrintMessages(P_SrcReceiptStack IN
                             receipt_error_stack);

PROCEDURE InitMessages(P_NumOfReceipts IN INTEGER,
                       P_SrcReceiptStack OUT
                             receipt_error_stack);

FUNCTION FieldContainsError(
  P_MessageArray          IN receipt_error_stack,
  P_ReceiptNumber         IN INTEGER,
  P_FieldNumber           IN VARCHAR2)
  RETURN BOOLEAN;

PROCEDURE ClearMessages(
            P_TargetReceiptStack OUT NOCOPY receipt_error_stack);

PROCEDURE CopyMessages(
            P_SrcReceiptStack IN receipt_error_stack,
            P_TargetReceiptStack IN OUT NOCOPY receipt_error_stack);

PROCEDURE ArrayifyText(P_ErrorText  IN LONG,
                       P_ErrorTextArray OUT NOCOPY LongString_Array);

PROCEDURE ArrayifyErrorText(P_ReceiptErrors  IN receipt_error_stack,
                            P_ReceiptNum     IN INTEGER,
                            P_ErrorTextArray OUT NOCOPY LongString_Array);

PROCEDURE ArrayifyWarningText(P_ReceiptErrors  IN receipt_error_stack,
                            P_ReceiptNum     IN INTEGER,
                            P_ErrorTextArray OUT NOCOPY LongString_Array);

PROCEDURE ArrayifyErrorFields(P_ReceiptErrors  IN receipt_error_stack,
                              P_ReceiptNum     IN INTEGER,
                              P_ErrorFieldArray OUT NOCOPY Number_Array);

PROCEDURE ArrayifyWarningFields(P_ReceiptErrors  IN receipt_error_stack,
                              P_ReceiptNum     IN INTEGER,
                              P_ErrorFieldArray OUT NOCOPY Number_Array);

PROCEDURE ConvertDate;

PROCEDURE DetermineConversion;


 FUNCTION  getEuroCode RETURN VARCHAR2;

/*------------------------------------------------------------+
   Fix 1435885 : To prevent pcard packages from getting
   Invalid. These functions are not used by SSE.
   Functions include IsNum, DisplayHelp, GenericButton,
   GenToolBarScript, GenToolBar, GenButton, StyleSheet
+-------------------------------------------------------------*/

 PROCEDURE IsNum;

 PROCEDURE DisplayHelp;

 PROCEDURE GenToolbarScript;

 PROCEDURE GenToolbar(p_title              VARCHAR2,
                     p_print_frame        VARCHAR2,
                     p_save_flag          BOOLEAN,
                     p_save_disabled_flag BOOLEAN,
                     p_save_call          VARCHAR2 DEFAULT NULL);

 PROCEDURE GenButton(P_Button_Text varchar2,
                    P_OnMouseOverText varchar2,
                    P_HyperTextCall varchar2);

 PROCEDURE StyleSheet;

 FUNCTION RtrimMultiByteSpaces(p_input_string IN varchar2) RETURN VARCHAR2;

 FUNCTION GetDistanceDisplayValue(p_value IN NUMBER,
         p_format IN VARCHAR2) RETURN NUMBER;

FUNCTION VALUE_SPECIFIC(p_name IN VARCHAR2,
         		p_user_id IN NUMBER default null,
			p_resp_id IN NUMBER default null,
			p_apps_id IN NUMBER default null) RETURN VARCHAR2;

FUNCTION  getMinipackVersion RETURN VARCHAR2;

/*
Written by:
  Maulik Vadera
Purpose:
  To get the override approver name, when profile option,
  IE:Approver Required = "Yes with Default" and approver name is not provided
  in the upload SpreadSheet data.
  Fix for bug 3786831
Input:
  p_EmpId: Employee Id of the employee
Output:
  Override approver Id for that Employee Id
  Override approver name for that Employee Id
Date:
  21-Mar-2005
*/

PROCEDURE GetOverrideApproverDetail(p_EmpId IN NUMBER,
				    p_appreq IN VARCHAR2,
                                    p_ApproverId OUT NOCOPY HR_EMPLOYEES.employee_num%TYPE,
				    p_OverrideApproverName OUT NOCOPY HR_EMPLOYEES.full_name%TYPE);



PROCEDURE ExpenseSetOrgContext(p_report_header_id	IN NUMBER);


/*=======================================================================
 | PUBLIC FUNCITON: OrgSecurity
 |
 | DESCRIPTION: This function will return the security predicate
 |              for  expense report templates and expense types table.
 |              It ensures that the seeded template and expense types
 |              with org_id = -99 are also picked up when querying
 |              the secured synonym
 |
 | PARAMETERS
 |      obj_schema       IN VARCHAR2  Object Schema
 |      obj_name         IN VARCHAR2  Object Name
 |
 | RETURNS
 |      Where clause to be appended to the object.
 *=======================================================================*/
 FUNCTION OrgSecurity ( obj_schema VARCHAR2,
                        obj_name   VARCHAR2) RETURN VARCHAR2;

-- Bug: 6220330, added a new parameter so that the trigger on ap_invoices_all can use this.
PROCEDURE UpdateExpenseStatusCode(
      p_invoice_id AP_INVOICES_ALL.invoice_id%TYPE,
      p_pay_status_flag AP_INVOICES_ALL.payment_status_flag%TYPE DEFAULT NULL
);

/*--------------------------------------------------+
Fix for bug 5586280 Do not pad the cost center if it
contains any character or special character including
a period
+--------------------------------------------------*/

FUNCTION ContainsChars(p_element IN VARCHAR2) RETURN BOOLEAN;

-- Bug: 6220330
PROCEDURE GetExpensesToUpdate(p_invoice_id         IN    AP_INVOICES_ALL.invoice_id%TYPE,
 	                      p_pay_status_flag    IN    AP_INVOICES_ALL.payment_status_flag%TYPE,
 	                      p_expenses_to_update OUT NOCOPY ExpensesToUpdate);

------------------------------------------------------------------------
-- FUNCTION Oie_Round_Currency
-- Bug 6136103
-- Returns Amount in the Rounded format per spec in fnd_currencies
-- Introduced as aputilsb.ap_round_currency errors out due to Caching.
------------------------------------------------------------------------
FUNCTION Oie_Round_Currency
                         (P_Amount         IN number
                         ,P_Currency_Code  IN varchar2)
RETURN NUMBER;

PROCEDURE UpdateImageReceiptStatus(p_report_header_id IN NUMBER);

FUNCTION GetImageAttachmentStatus(p_report_header_id IN NUMBER) RETURN VARCHAR2;

FUNCTION GetAttachmentExists(p_entity_name IN VARCHAR2, p_value IN VARCHAR2) RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------
FUNCTION GetShortPaidReportMsg(p_report_header_id in NUMBER) RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
PROCEDURE AddReportToAuditQueue(p_report_header_id IN NUMBER);
-----------------------------------------------------------------------------------------------
END AP_WEB_UTILITIES_PKG;

/
