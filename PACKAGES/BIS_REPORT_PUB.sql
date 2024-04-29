--------------------------------------------------------
--  DDL for Package BIS_REPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_REPORT_PUB" AUTHID CURRENT_USER as
/* $Header: BISPREPS.pls 120.0 2005/06/01 15:18:26 appldev noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.1=120.0):~PROD:~PATH:~FILE
-- Purpose: LOV for PM Viewer
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- mdamle     10/11/04  Initial Creation
---------------------------------------------------------------------

FUNCTION getRegionCode(pFunctionName IN VARCHAR2) return varchar2;

FUNCTION getRegionCode(pType IN VARCHAR2, pParameters IN VARCHAR2, webHtmlCall IN VARCHAR2, functionName IN VARCHAR2) RETURN CHAR;

FUNCTION getRegionApplicationId(pRegionCode IN VARCHAR2) RETURN NUMBER;

FUNCTION getPortletType(pType IN VARCHAR2, pParameters IN VARCHAR2) RETURN VARCHAR2;

FUNCTION getPortletTypeCode(pType IN VARCHAR2, pParameters IN VARCHAR2) RETURN CHAR;

FUNCTION getRegionApplicationName(pRegionCode IN VARCHAR2) RETURN VARCHAR2;

FUNCTION getRegionDataSourceType(pRegionCode IN VARCHAR2) RETURN VARCHAR2;

FUNCTION isRegionItemRequired(p_required_flag in VARCHAR2, p_dim_group_name in VARCHAR2 := NULL, p_attribute1 in VARCHAR2) RETURN NUMBER;

FUNCTION isWeightedAverageReport(p_region_code in VARCHAR2,p_region_application_id in NUMBER) RETURN CHAR;

end BIS_REPORT_PUB;

 

/
