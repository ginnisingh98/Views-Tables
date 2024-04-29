--------------------------------------------------------
--  DDL for Package AP_WEB_DISC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DISC_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdiscs.pls 120.9 2006/06/27 16:54:28 nammishr ship $ */

/* PROCEDURE ValidateDiscReport(UploadArea           LONG,
                          AP_WEB_FULLNAME         VARCHAR2 default NULL,
                          AP_WEB_EMPID            VARCHAR2 default NULL); */

  TYPE MiniString_Array IS TABLE OF VARCHAR2(25)
        INDEX BY BINARY_INTEGER;
  TYPE MedString_Array IS TABLE OF VARCHAR2(80)
        INDEX BY BINARY_INTEGER;
  TYPE BigString_Array IS TABLE OF VARCHAR2(240)
        INDEX BY BINARY_INTEGER;
  TYPE Number_Array IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
  TYPE Boolean_Array IS TABLE OF BOOLEAN
        INDEX BY BINARY_INTEGER;
  TYPE PromptsCursor IS REF CURSOR;



TYPE PROMPT_REC IS RECORD (
-- chiho:1170729:modify the data type:
  prompt_text	fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE := '',
  prompt_code	fnd_descr_flex_col_usage_vl.end_user_column_name%TYPE := '',

  required	varchar2(2) := 'N',
  duplicate	varchar2(1) := 'N',
  global_flag	boolean := false);

-- Indicates the type of error encountered when parsing the spreadsheet
C_SetupError CONSTANT VARCHAR2(1) := 'S';
C_DataError CONSTANT VARCHAR2(1)  := 'D';
C_Warning CONSTANT VARCHAR2(1) :='W';
C_NoError CONSTANT VARCHAR2(1) :=' ';

-- Indicates whether this is being run with the old tech stack (PLSQL)
-- or the new tech stack (OA Framework)
-- Used in ParseExpReport
C_OldStack CONSTANT VARCHAR2(1):= 'O';
C_NewStack CONSTANT VARCHAR2(1) := 'N';

TYPE DISC_PROMPTS_TABLE IS TABLE OF PROMPT_REC
  INDEX BY BINARY_INTEGER;

TYPE RECEIPT_ERROR_REC IS RECORD (
  error_text	long := '',
  error_fields	varchar2(100) := '' );

TYPE RECEIPT_ERROR_STACK IS TABLE OF RECEIPT_ERROR_REC
  INDEX BY BINARY_INTEGER;

TYPE SETUP_ERROR_STACK IS TABLE OF VARCHAR2(2000)
  INDEX BY BINARY_INTEGER;


-- ParseExpReport to be accessed from AP_WEB_OA_DISC_PKG

PROCEDURE ParseExpReport(
        p_user_id       IN NUMBER, -- 2242176, fnd user id
        p_exp           in LONG,
        p_table         IN OUT NOCOPY disc_prompts_table,
        p_costcenter    in VARCHAR2,
        P_IsSessionProjectEnabled IN VARCHAR2,
        p_report_header_info    IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
        p_report_lines_info     OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportLines_A,
        Custom1_Array           OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom2_Array           OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom3_Array           OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom4_Array           OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom5_Array           OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom6_Array           OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom7_Array           OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom8_Array           OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom9_Array           OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom10_Array          OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom11_Array          OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom12_Array          OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom13_Array          OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom14_Array          OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom15_Array          OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        P_DataDefaultedUpdateable   OUT NOCOPY BOOLEAN,
        p_errors                OUT NOCOPY AP_WEB_UTILITIES_PKG.expError,
        p_receipt_errors        OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack,
        p_error_type            OUT NOCOPY VARCHAR2,
        p_techstack             IN  VARCHAR2 DEFAULT C_OldStack -- Old or new tech stack
);

-- Added ValidateExpenseLines to be accessed from AP_WEB_OA_DISC_PKG

  PROCEDURE discValidateExpLines(
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
        p_has_core_field_errors         OUT NOCOPY BOOLEAN,
        p_has_custom_field_errors       OUT NOCOPY BOOLEAN,
        p_receipts_errors               OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack,
        p_receipts_with_errors_count    OUT NOCOPY BINARY_INTEGER,
        p_IsSessionProjectEnabled       IN VARCHAR2,
        p_calculate_receipt_index       IN BINARY_INTEGER DEFAULT NULL,
        p_DataDefaultedUpdateable	IN OUT NOCOPY BOOLEAN);

PROCEDURE AP_WEB_INIT_PROMPTS_ARRAY(p_user_id in number, -- 2242176
                                    p_table in out nocopy DISC_PROMPTS_TABLE,
                                    p_format_errors in out nocopy setup_error_stack);

PROCEDURE InverseRates(p_receipts IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportLines_A);

PROCEDURE ValidateForeignCurrencies(
        p_report_header_info  IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
        p_report_lines_info   IN AP_WEB_DFLEX_PKG.ExpReportLines_A,
        p_receipts_errors      IN OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack);

------------------------------------------------------------------------------------------------
-- Name: GetAKRegionPromptsCursor
-- Desc: get the cursor of the prompts for the given AK region code
-- Params:	p_reg_code - the given AK region code
--		p_prompts_cursor - the returned cursor
-- Returns: 	true - succeeded
--	 	false - failed
--------------------------------------------------------------------------------
FUNCTION GetAKRegionPromptsCursor(
	p_reg_code 		IN  AK_REGION_ITEMS_VL.region_code%TYPE,
	p_prompts_cursor  OUT NOCOPY PromptsCursor)
RETURN  BOOLEAN;
-----------------------------------------------------------------------------------------------

PROCEDURE getPrompts( c_region_application_id in number,
                      c_region_code in varchar2,
                      c_title out nocopy AK_REGIONS_VL.NAME%TYPE,
                      c_prompts out nocopy AP_WEB_UTILITIES_PKG.prompts_table);


END AP_WEB_DISC_PKG;


 

/
