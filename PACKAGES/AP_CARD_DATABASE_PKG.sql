--------------------------------------------------------
--  DDL for Package AP_CARD_DATABASE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_CARD_DATABASE_PKG" AUTHID CURRENT_USER AS
/* $Header: apwpcdbs.pls 115.3 2002/12/26 10:14:41 srinvenk noship $ */

-------------------------------------------------------------------------------
/*HR Employees */
-------------------------------------------------------------------------------
SUBTYPE empCurrent_employeeID			IS HR_EMPLOYEES_CURRENT_V.employee_id%TYPE;
SUBTYPE empCurrent_fullName			IS HR_EMPLOYEES_CURRENT_V.full_name%TYPE;
SUBTYPE empCurrent_empNum			IS HR_EMPLOYEES_CURRENT_V.employee_num%TYPE;
SUBTYPE empCurrent_checkAddrFlag	        IS HR_EMPLOYEES_CURRENT_V.expense_check_address_flag%TYPE;
SUBTYPE empCurrent_defaultCodeCombID		IS HR_EMPLOYEES_CURRENT_V.default_code_combination_id%TYPE;
SUBTYPE empCurrent_orgID			IS HR_EMPLOYEES_CURRENT_V.ORGANIZATION_ID%TYPE;

-------------------------------------------------------------------------------
/* AP Lookup Codes */
-------------------------------------------------------------------------------
SUBTYPE lookupCodes_displayedField		IS AP_LOOKUP_CODES.displayed_field%TYPE;
SUBTYPE lookupCodes_lookupCode			IS AP_LOOKUP_CODES.lookup_code%TYPE;
SUBTYPE lookupCodes_lookupType			IS AP_LOOKUP_CODES.lookup_type%TYPE;

-------------------------------------------------------------------------------
/* AP Card Profiles */
-------------------------------------------------------------------------------
SUBTYPE cardProf_profileName                    IS AP_CARD_PROFILES.profile_name%TYPE;
SUBTYPE cardProf_directAcctEntryFlag		IS AP_CARD_PROFILES.direct_acct_entry_flag%TYPE;
SUBTYPE cardProf_cardGLSetID			IS AP_CARD_PROFILES.card_gl_set_id%TYPE;
SUBTYPE cardProf_empNotifLookupCode		IS AP_CARD_PROFILES.emp_notification_lookup_code%TYPE;
SUBTYPE cardProf_mgrApprvlLookupCode            IS AP_CARD_PROFILES.mgr_approval_lookup_code%TYPE;

-------------------------------------------------------------------------------
/* GL Sets Of Books */
-------------------------------------------------------------------------------
SUBTYPE glsob_chartOfAccountsID 	IS GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;

-------------------------------------------------------------------------------
/* AP Card Programs */
-------------------------------------------------------------------------------
SUBTYPE cardProgs_cardProgID			IS AP_CARD_PROGRAMS.card_program_id%TYPE;
SUBTYPE cardProgs_cardProgName			IS AP_CARD_PROGRAMS.card_program_name%TYPE;
SUBTYPE cardProgs_cardProgCurrCode		IS AP_CARD_PROGRAMS.card_program_currency_code%TYPE;

-------------------------------------------------------------------------------
/* Currency */
-------------------------------------------------------------------------------
SUBTYPE curr_name                    IS FND_CURRENCIES_VL.name%TYPE;
SUBTYPE curr_currCode		     IS FND_CURRENCIES_VL.currency_code%TYPE;
SUBTYPE curr_precision               IS FND_CURRENCIES_VL.precision%TYPE;
SUBTYPE curr_minAcctUnit             IS FND_CURRENCIES_VL.minimum_accountable_unit%TYPE;

-------------------------------------------------------------------------------
/*AK Flow Region Relations */
-------------------------------------------------------------------------------
SUBTYPE flowReg_fromRegionCode			IS AK_FLOW_REGION_RELATIONS.from_region_code%TYPE;
SUBTYPE flowReg_fromRegionApplID		IS AK_FLOW_REGION_RELATIONS.from_region_appl_id%TYPE;
SUBTYPE flowReg_fromPageCode			IS AK_FLOW_REGION_RELATIONS.from_page_code%TYPE;
SUBTYPE flowReg_fromPageApplID			IS AK_FLOW_REGION_RELATIONS.from_page_appl_id%TYPE;
SUBTYPE flowReg_toPageCode			IS AK_FLOW_REGION_RELATIONS.to_page_code%TYPE;
SUBTYPE flowReg_toPageApplID			IS AK_FLOW_REGION_RELATIONS.to_page_appl_id%TYPE;
SUBTYPE flowReg_flowCode			IS AK_FLOW_REGION_RELATIONS.flow_code%TYPE;
SUBTYPE flowReg_flowApplID			IS AK_FLOW_REGION_RELATIONS.flow_application_id%TYPE;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
TYPE prompts_table 		IS table of varchar2(50)
        		        index by binary_integer;

TYPE LookupCodesCursor 		IS REF CURSOR;

TYPE EmployeeInfoRec	IS RECORD (
	employee_id 		empCurrent_employeeID,
	employee_name 		empCurrent_fullName,
	employee_num 		empCurrent_empNum,
	emp_ccid 		empCurrent_defaultCodeCombID
);

-------------------------------------------------------------------------------
FUNCTION GetCardProgramCurrencyCode(
	p_card_prog_id	IN	cardProgs_cardProgID,
	p_curr_code OUT NOCOPY cardProgs_cardProgCurrCode
) RETURN BOOLEAN;
-------------------------------------------------------------------------------

-- Name: GetLookupCodesCursor
-- Desc: get the cursor reference of the lookup codes for the given lookup type
-- Params:	p_lookup_type - the given lookup type
--		p_lookup_codes - the returned lookup code cursor
-- Returns: 	true - succeeded
--	    	false - failed
-------------------------------------------------------------------------------
FUNCTION GetLookupCodesCursor(p_lookup_type 	IN  lookupCodes_lookupType,
			      p_lookup_codes  OUT NOCOPY LookupCodesCursor)
RETURN BOOLEAN;

-------------------------------------------------------------------------------
FUNCTION GetCurrCodeProperties(
	p_curr_code 		IN  curr_currCode,
	p_curr_name 	 OUT NOCOPY curr_name,
	p_precision 	 OUT NOCOPY curr_precision,
	p_minimum_acct_unit  OUT NOCOPY curr_minAcctUnit
) RETURN BOOLEAN;

-------------------------------------------------------------------------------
FUNCTION GetCOAofSOB(
	p_chart_of_accounts OUT NOCOPY glsob_chartOfAccountsID
) RETURN BOOLEAN;

-------------------------------------------------------------------------------
--  Name: GetAKPageRowID
-- Desc: get the AK page row id
-- Params:	p_from_region_code - the given region code
--		p_from_page_code - the give "from" page code
-- 		p_to_page_code - the give to "to" page code
--		p_flow_code - the given flow code
--		p_application_id - the given application id
--		p_row_id - the returned row id
-- Returns: 	true - succeeded
--	 	false - failed
-------------------------------------------------------------------------------
FUNCTION GetAKPageRowID(P_FROM_REGION_CODE	IN  flowReg_fromRegionCode,
			P_FROM_PAGE_CODE	IN  flowReg_fromPageCode,
			P_TO_PAGE_CODE		IN  flowReg_toPageCode,
			P_FLOW_CODE		IN  flowReg_flowCode,
			P_APPLICATION_ID	IN  flowReg_flowApplID,
			P_ROW_ID	 OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-------------------------------------------------------------------------------
FUNCTION GetEmployeeInfo(p_employee_id  IN  empCurrent_employeeID,
			 p_emp_info_rec OUT NOCOPY EmployeeInfoRec
) RETURN BOOLEAN;

-------------------------------------------------------------------------------
PROCEDURE getPrompts( c_region_application_id in number,
                      c_region_code in varchar2,
                      c_title out nocopy AK_REGIONS_VL.NAME%TYPE,
                      c_prompts out nocopy prompts_table);
-------------------------------------------------------------------
-- Name: RaiseException
-- Desc: common routine for handling unrecoverrable(database) errors
-- Params: 	p_calling_squence - the name of the caller function
--		p_debug_info - additional error message
--		p_set_name - fnd message name
--		p_params - fnd message parameters
-------------------------------------------------------------------
PROCEDURE RaiseException(
	p_calling_sequence 	IN VARCHAR2,
	p_debug_info		IN VARCHAR2 DEFAULT '',
	p_set_name		IN VARCHAR2 DEFAULT NULL,
	p_params		IN VARCHAR2 DEFAULT ''
);

-------------------------------------------------------------------
FUNCTION jsPrepString_long(p_string in long,
		      p_alertflag in boolean default FALSE,
		      p_jsargflag  in  boolean  default FALSE) RETURN LONG;
-------------------------------------------------------------------
FUNCTION jsPrepString(p_string in varchar2,
                      p_alertflag in boolean default FALSE,
                      p_jsargflag  in  boolean  default FALSE) RETURN VARCHAR2;



END AP_CARD_DATABASE_PKG;

 

/
