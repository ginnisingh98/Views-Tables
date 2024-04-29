--------------------------------------------------------
--  DDL for Package Body AP_CARD_DATABASE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CARD_DATABASE_PKG" AS
/* $Header: apwpcdbb.pls 115.4 2003/01/29 18:49:24 rlandows noship $ */

-------------------------------------------------------------------------------
FUNCTION GetCardProgramCurrencyCode(
	p_card_prog_id	IN	cardProgs_cardProgID,
	p_curr_code OUT NOCOPY cardProgs_cardProgCurrCode
) RETURN BOOLEAN IS
-------------------------------------------------------------------------------
BEGIN

    SELECT	card_program_currency_code
    INTO 	p_curr_code
    FROM 	ap_card_programs
    WHERE 	card_program_id = p_card_prog_id;

    RETURN TRUE;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN FALSE;

	WHEN OTHERS THEN
		AP_CARD_DATABASE_PKG.RaiseException( 'GetCardProgramCurrencyCode' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
        	return FALSE;

END GetCardProgramCurrencyCode;

-------------------------------------------------------------------------------
FUNCTION GetLookupCodesCursor(p_lookup_type 	IN  lookupCodes_lookupType,
			      p_lookup_codes  OUT NOCOPY LookupCodesCursor)
RETURN BOOLEAN IS
-------------------------------------------------------------------------------
BEGIN
OPEN p_lookup_codes FOR
  SELECT lookup_code, displayed_field
  FROM   ap_lookup_codes
  WHERE  lookup_type = p_lookup_type;

  RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
  WHEN OTHERS THEN
    AP_CARD_DATABASE_PKG.RaiseException('GetLookupCodesCursor');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetLookupCodesCursor;

-------------------------------------------------------------------------------
FUNCTION GetCurrCodeProperties(
	p_curr_code 		IN  curr_currCode,
	p_curr_name 	 OUT NOCOPY curr_name,
	p_precision 	 OUT NOCOPY curr_precision,
	p_minimum_acct_unit  OUT NOCOPY curr_minAcctUnit
) RETURN BOOLEAN IS
-------------------------------------------------------------------------------
BEGIN
	 SELECT fndcvl.name,
         	NVL(fndcvl.precision,0),
         	fndcvl.minimum_accountable_unit
	 INTO	p_curr_name,
		p_precision,
		p_minimum_acct_unit
         FROM   fnd_currencies_vl fndcvl
	 WHERE	currency_code = p_curr_code;

	RETURN TRUE;
EXCEPTION

	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_CARD_DATABASE_PKG.RaiseException( 'GetCurrCodeProperties' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;
END GetCurrCodeProperties;

-------------------------------------------------------------------------------
FUNCTION GetCOAofSOB(
	p_chart_of_accounts OUT NOCOPY glsob_chartOfAccountsID
) RETURN BOOLEAN IS
-------------------------------------------------------------------------------
BEGIN
  SELECT  GS.chart_of_accounts_id
  INTO    p_chart_of_accounts
  FROM    ap_system_parameters S,
          gl_sets_of_books GS
  WHERE   GS.set_of_books_id = S.set_of_books_id;

  RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_CARD_DATABASE_PKG.RaiseException( 'GetCOAOfSOB' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetCOAofSOB;

-------------------------------------------------------------------------------
FUNCTION GetAKPageRowID(P_FROM_REGION_CODE	IN  flowReg_fromRegionCode,
			P_FROM_PAGE_CODE	IN  flowReg_fromPageCode,
			P_TO_PAGE_CODE		IN  flowReg_toPageCode,
			P_FLOW_CODE		IN  flowReg_flowCode,
			P_APPLICATION_ID	IN  flowReg_flowApplID,
			P_ROW_ID	 OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS
-------------------------------------------------------------------------------
BEGIN

  SELECT  rowidtochar(ROWID)
  INTO    P_ROW_ID
  FROM    AK_FLOW_REGION_RELATIONS
  WHERE   FROM_REGION_CODE = P_FROM_REGION_CODE
  AND     FROM_REGION_APPL_ID = P_APPLICATION_ID
  AND     FROM_PAGE_CODE = P_FROM_PAGE_CODE
  AND     FROM_PAGE_APPL_ID = P_APPLICATION_ID
  AND     TO_PAGE_CODE = P_TO_PAGE_CODE
  AND     TO_PAGE_APPL_ID = P_APPLICATION_ID
  AND     FLOW_CODE = P_FLOW_CODE
  AND     FLOW_APPLICATION_ID = P_APPLICATION_ID;

  RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
  WHEN OTHERS THEN
    AP_CARD_DATABASE_PKG.RaiseException('GetAKPageRowID');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetAKPageRowID;


-------------------------------------------------------------------------------
FUNCTION GetEmployeeInfo(p_employee_id  IN  empCurrent_employeeID,
			 p_emp_info_rec OUT NOCOPY EmployeeInfoRec
) RETURN BOOLEAN IS
-------------------------------------------------------------------------------
BEGIN
 SELECT  EMP.full_name,
	 EMP.employee_num,
         EMP.default_code_combination_id
  INTO   p_emp_info_rec.employee_name,
	 p_emp_info_rec.employee_num,
         p_emp_info_rec.emp_ccid
  FROM   hr_employees_current_v EMP
  WHERE  EMP.employee_id = p_employee_id;

  RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_CARD_DATABASE_PKG.RaiseException( 'GetEmployeeInfo' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetEmployeeInfo;
-------------------------------------------------------------------------------
PROCEDURE getPrompts( c_region_application_id in number,
                      c_region_code in varchar2,
                      c_title out nocopy AK_REGIONS_VL.NAME%TYPE,
                      c_prompts out nocopy prompts_table)
IS
-------------------------------------------------------------------------------
  l_title         AK_REGIONS_VL.NAME%TYPE;
  l_prompts       icx_util.g_prompts_table;
  i               number;
BEGIN
  --
  -- Populate Prompt tables for translation
  --
  icx_util.getPrompts(c_region_application_id,
                      c_region_code,
                      l_title,
                      l_prompts);

  c_prompts(0) := l_prompts(0);

  FOR i in 1 .. to_number(l_prompts(0))
    LOOP
      c_prompts(i) := l_prompts(i);
    END LOOP;

END getPrompts;

function jsPrepString_long(p_string in long,
                      p_alertflag  in  boolean default FALSE,
                      p_jsargflag  in  boolean  default FALSE)
                      return long is

temp_string  long;

begin

-- check for double escapes
temp_string := replace(p_string,'\\','\');

-- replace double quotes
IF (p_jsargflag) THEN
temp_string := replace(temp_string,'"','\\' || '&' || 'quot;');
ELSIF (NOT p_alertflag) THEN
temp_string := replace(temp_string,'"','\' || '&' || 'quot;');
ELSE
temp_string := replace(temp_string,'"','\"');
END IF;

-- replace single quotes
IF (p_jsargflag) THEN
  temp_string := replace(temp_string,'''','\\''');
ELSIF (NOT p_alertflag) THEN
  temp_string := replace(temp_string,'''','\''');
END IF;

-- check for carridge returns
temp_string := replace(temp_string, '
', ' ');

return temp_string;

end;

function jsPrepString(p_string in varchar2,
                      p_alertflag  in  boolean default FALSE,
                      p_jsargflag  in  boolean  default FALSE)
                      return varchar2 is

begin

  return(substrb(jsPrepString_long(p_string,
			     p_alertflag,
			     p_jsargflag), 1, 2000));

end;

PROCEDURE RaiseException(
	p_calling_sequence 	IN VARCHAR2,
	p_debug_info		IN VARCHAR2 DEFAULT '',
	p_set_name		IN VARCHAR2 DEFAULT NULL,
	p_params		IN VARCHAR2 DEFAULT ''
) IS
-------------------------------------------------------------------
BEGIN
  FND_MESSAGE.SET_NAME('SQLAP', nvl(p_set_name,'AP_DEBUG'));
  FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
  FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', p_calling_sequence);
  FND_MESSAGE.SET_TOKEN('DEBUG_INFO', p_debug_info);
  FND_MESSAGE.SET_TOKEN('PARAMETERS', p_params);


END RaiseException;

END AP_CARD_DATABASE_PKG;

/
