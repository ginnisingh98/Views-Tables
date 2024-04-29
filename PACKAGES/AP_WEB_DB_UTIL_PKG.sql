--------------------------------------------------------
--  DDL for Package AP_WEB_DB_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbuts.pls 115.7 2003/10/15 21:26:01 skoukunt noship $ */

/* FND product installations */
---------------------------------------------------------------------------------------------------
SUBTYPE fndProdInst_prodVer			IS
FND_PRODUCT_INSTALLATIONS.product_version%TYPE;

SUBTYPE fndApp_appID				IS
FND_APPLICATION.application_id%TYPE;

/* Other or Miscellaneous */
-- Date format
C_DetailedDateFormat       CONSTANT VARCHAR2(100) := 'YYYY/MM/DD HH24:MI:SS';


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
-- Name: GetSysDate
-- Desc: get the current date
-- Params:	p_sysDate - used to store the current date info
-- Returns: 	true - succeed
--	 	false - fail
-------------------------------------------------------------------
FUNCTION GetSysDate(
	p_sysDate	OUT	NOCOPY VARCHAR2
) RETURN BOOLEAN;


-------------------------------------------------------------------
-- Name: GetFormattedSysDate
-- Desc: get the current date in the given format
-- Params: 	p_format - the given format for the date info
--		p_formatted_date - used to store the formatted date info
-- Returns: 	true - succeed
--	 	false - fail
-------------------------------------------------------------------
FUNCTION GetFormattedSysDate(
	p_format		IN	VARCHAR2,
	p_formatted_date	OUT	NOCOPY VARCHAR2
) RETURN BOOLEAN;


-------------------------------------------------------------------
-- Name: DayOfWeek
-- Desc: get the order of the given date in a week
-- Params: 	p_date - the given date
--		p_day_of_week - in what day of the week the given date is in
-- Returns: 	true - succeed
--	 	false - fail
-------------------------------------------------------------------
FUNCTION DayOfWeek(
	p_date		IN	VARCHAR2,
	p_day_of_week	OUT	NOCOPY NUMBER
) RETURN BOOLEAN;

-------------------------------------------------------------------
-- Name: GetProductVersion
-- Desc: get the version number of the installed product
-- Params: 	p_version - the returned version number of the product
-- Returns: 	true - succeed
--	 	false - fail
-------------------------------------------------------------------
FUNCTION GetProductVersion(
	p_version	OUT	NOCOPY fndProdInst_prodVer
) RETURN BOOLEAN;

-------------------------------------------------------------------
-- Name: GetApplicationID
-- Desc: get the applicationID for SQLAP
-- Params: 	None
-- Returns: 	Application ID
-------------------------------------------------------------------
FUNCTION GetApplicationID RETURN  fndApp_appID;


FUNCTION jsPrepString_long(p_string in long,
		      p_alertflag in boolean default FALSE,
		      p_jsargflag  in  boolean  default FALSE) RETURN LONG;

FUNCTION jsPrepString(p_string in varchar2,
		      p_alertflag in boolean default FALSE,
		      p_jsargflag  in  boolean  default FALSE) RETURN VARCHAR2;

FUNCTION AtLeastProd16 RETURN BOOLEAN;

FUNCTION CharToNumber (p_unformatted_amt IN VARCHAR)
         RETURN NUMBER ;


END AP_WEB_DB_UTIL_PKG;

 

/
