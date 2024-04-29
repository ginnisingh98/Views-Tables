--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_UTIL_PKG" AS
/* $Header: apwdbutb.pls 115.8 2003/10/15 21:26:06 skoukunt noship $ */

/* Other or Miscellaneous */
-------------------------------------------------------------------
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

-------------------------------------------------------------------
FUNCTION GetSysDate(
	p_sysDate	OUT	NOCOPY VARCHAR2
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  	SELECT 	 sysdate
  	INTO	 p_sysDate
  	FROM 	 sys.dual;

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		RaiseException( 'GetSysDate' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetSysDate;

-------------------------------------------------------------------
FUNCTION GetFormattedSysDate(
	p_format		IN	VARCHAR2,
	p_formatted_date	OUT	NOCOPY VARCHAR2
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN

  	SELECT 	TO_CHAR(SYSDATE,p_format)
  	INTO 	p_formatted_date
  	FROM 	sys.dual;

  	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		RaiseException( 'GetFormattedSysDate' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetFormattedSysDate;

-----------------------------------------------------
FUNCTION DayOfWeek(
	p_date		IN	VARCHAR2,
	p_day_of_week	OUT	NOCOPY NUMBER
) RETURN BOOLEAN IS
-----------------------------------------------------
BEGIN

	SELECT mod(to_char(to_date(p_date,AP_WEB_INFRASTRUCTURE_PKG.getDateFormat), 'J')+1, 7)
  	INTO   p_day_of_week
  	FROM   sys.dual;

	p_day_of_week := p_day_of_week + 1;

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		RaiseException( 'DayOfWeek' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END DayOfWeek;


-----------------------------------------------------
FUNCTION GetProductVersion(
	p_version	OUT	NOCOPY fndProdInst_prodVer
) RETURN BOOLEAN IS
-----------------------------------------------------
BEGIN

	SELECT	product_version
	INTO 	p_version
	FROM 	fnd_product_installations
	WHERE 	application_id = 200;

	RETURN TRUE;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		RaiseException( 'GetProductVersion' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetProductVersion;

-----------------------------------------------------
FUNCTION GetApplicationID RETURN  fndApp_appID IS
-----------------------------------------------------
  l_application_id	fndApp_appID;
BEGIN

	SELECT	application_id
	INTO 	l_application_id
	FROM 	fnd_application
	WHERE 	application_short_name = 'SQLAP';

	RETURN l_application_id;
EXCEPTION
	WHEN OTHERS THEN
		RaiseException( 'GetApplicationID' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
		return NULL;

END GetApplicationID;

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

Function AtLeastProd16 return boolean is
begin
  return true;
end AtLeastProd16;


FUNCTION CharToNumber (p_unformatted_amt IN VARCHAR)
         RETURN NUMBER
IS
l_formatmask varchar2(80);
l_nls_numeric_char varchar2(5);
l_formatted_amt  NUMBER;
BEGIN

      l_nls_numeric_char := icx_sec.getNLS_PARAMETER('NLS_NUMERIC_CHARACTERS');

      l_formatmask := translate(translate(p_unformatted_amt,'-+0123456789','SS9999999999'),
			l_nls_numeric_char,'DG');

      l_formatted_amt :=  to_number(p_unformatted_amt,l_formatmask );

      RETURN l_formatted_amt;

END CharToNumber;

END AP_WEB_DB_UTIL_PKG;

/
