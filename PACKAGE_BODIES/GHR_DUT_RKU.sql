--------------------------------------------------------
--  DDL for Package Body GHR_DUT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_DUT_RKU" as
/* $Header: ghdutrhi.pkb 120.0.12000000.1 2007/01/18 13:42:07 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:57:15 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_DUTY_STATION_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_LOCALITY_PAY_AREA_ID in NUMBER
,P_LEO_PAY_AREA_CODE in VARCHAR2
,P_NAME in VARCHAR2
,P_DUTY_STATION_CODE in VARCHAR2
,P_IS_DUTY_STATION in VARCHAR2
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_UPDATE_MODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: GHR_DUT_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: GHR_DUT_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end GHR_DUT_RKU;

/