--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_UI_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_UI_SETUP_PKG" AS
/* $Header: apwdbuib.pls 120.6 2006/06/27 16:47:57 nammishr ship $ */


----------------------------------------------------------------------------------------------
FUNCTION GetDisplayValForLookupCode(p_lookup_type     	IN  lookupCodes_lookupType,
				    p_lookup_code     	IN  lookupCodes_lookupCode,
				    p_displayed_field  OUT NOCOPY lookupCodes_displayedField)
RETURN BOOLEAN IS
----------------------------------------------------------------------------------------------
BEGIN
    SELECT displayed_field
    INTO   p_displayed_field
    FROM   ap_lookup_codes
    WHERE  lookup_type = p_lookup_type
    AND    lookup_code = p_lookup_code;

    return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetDisplayValForLookupCode');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetDisplayValForLookupCode;

---------------------------------------------------------------------------------------
FUNCTION GetAKPageRowID(P_FROM_REGION_CODE	IN  flowReg_fromRegionCode,
			P_FROM_PAGE_CODE	IN  flowReg_fromPageCode,
			P_TO_PAGE_CODE		IN  flowReg_toPageCode,
			P_FLOW_CODE		IN  flowReg_flowCode,
			P_APPLICATION_ID	IN  flowReg_flowApplID,
			P_ROW_ID	 OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS
---------------------------------------------------------------------------------------
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

  return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetAKPageRowID');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetAKPageRowID;



END AP_WEB_DB_UI_SETUP_PKG;

/
