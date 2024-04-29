--------------------------------------------------------
--  DDL for Package AP_WEB_DB_UI_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_UI_SETUP_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbuis.pls 120.5 2006/06/27 16:47:28 nammishr ship $ */

/* AP Lookup Codes */
---------------------------------------------------------------------------------------------------
SUBTYPE lookupCodes_displayedField		IS AP_LOOKUP_CODES.displayed_field%TYPE;
SUBTYPE lookupCodes_lookupCode			IS AP_LOOKUP_CODES.lookup_code%TYPE;
SUBTYPE lookupCodes_lookupType			IS AP_LOOKUP_CODES.lookup_type%TYPE;

/*AK Region Items */
---------------------------------------------------------------------------------------------------
SUBTYPE regItem_regionCode			IS AK_REGION_ITEMS_VL.region_code%TYPE;

/* AK Regions */
SUBTYPE reg_name				IS AK_REGIONS_VL.name%TYPE;

/*AK Flow Region Relations */
---------------------------------------------------------------------------------------------------
SUBTYPE flowReg_fromRegionCode			IS AK_FLOW_REGION_RELATIONS.from_region_code%TYPE;
SUBTYPE flowReg_fromRegionApplID		IS AK_FLOW_REGION_RELATIONS.from_region_appl_id%TYPE;
SUBTYPE flowReg_fromPageCode			IS AK_FLOW_REGION_RELATIONS.from_page_code%TYPE;
SUBTYPE flowReg_fromPageApplID			IS AK_FLOW_REGION_RELATIONS.from_page_appl_id%TYPE;
SUBTYPE flowReg_toPageCode			IS AK_FLOW_REGION_RELATIONS.to_page_code%TYPE;
SUBTYPE flowReg_toPageApplID			IS AK_FLOW_REGION_RELATIONS.to_page_appl_id%TYPE;
SUBTYPE flowReg_flowCode			IS AK_FLOW_REGION_RELATIONS.flow_code%TYPE;
SUBTYPE flowReg_flowApplID			IS AK_FLOW_REGION_RELATIONS.flow_application_id%TYPE;

TYPE LookupCodesCursor 		IS REF CURSOR;
TYPE PromptsCursor 		IS REF CURSOR;
TYPE ReportAuthorsCursor 	IS REF CURSOR;



----------------------------------------------------------------------------------------------
-- Name: GetDisplayValForLookupCode
-- Desc: get the cursor of the displayed fields for the given lookup type and code
-- Params: 	p_lookup_type - the given lookup type
--		p_lookup_code - the given lookup code
--		p_displayed_field - the returned cursor
-- Returns: 	true - succeeded
--	 	false - failed
--------------------------------------------------------------------------------
FUNCTION GetDisplayValForLookupCode(p_lookup_type     	IN  lookupCodes_lookupType,
				    p_lookup_code     	IN  lookupCodes_lookupCode,
				    p_displayed_field  OUT NOCOPY lookupCodes_displayedField)
RETURN BOOLEAN;
----------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
-- Name: GetAKPageRowID
-- Desc: get the AK page row id
-- Params:	p_from_region_code - the given region code
--		p_from_page_code - the give "from" page code
-- 		p_to_page_code - the give to "to" page code
--		p_flow_code - the given flow code
--		p_application_id - the given application id
--		p_row_id - the returned row id
-- Returns: 	true - succeeded
--	 	false - failed
--------------------------------------------------------------------------------
FUNCTION GetAKPageRowID(P_FROM_REGION_CODE	IN  flowReg_fromRegionCode,
			P_FROM_PAGE_CODE	IN  flowReg_fromPageCode,
			P_TO_PAGE_CODE		IN  flowReg_toPageCode,
			P_FLOW_CODE		IN  flowReg_flowCode,
			P_APPLICATION_ID	IN  flowReg_flowApplID,
			P_ROW_ID	 OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
---------------------------------------------------------------------------------------


END AP_WEB_DB_UI_SETUP_PKG;

 

/
