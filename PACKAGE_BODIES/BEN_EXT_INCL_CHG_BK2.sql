--------------------------------------------------------
--  DDL for Package Body BEN_EXT_INCL_CHG_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_INCL_CHG_BK2" as
/* $Header: bexicapi.pkb 120.1 2005/06/08 13:23:25 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:41:12 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_EXT_INCL_CHG_A
(P_EXT_INCL_CHG_ID in NUMBER
,P_CHG_EVT_CD in VARCHAR2
,P_CHG_EVT_SOURCE in VARCHAR2
,P_EXT_RCD_IN_FILE_ID in NUMBER
,P_EXT_DATA_ELMT_IN_RCD_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_EXT_INCL_CHG_BK2.UPDATE_EXT_INCL_CHG_A', 10);
hr_utility.set_location(' Leaving: BEN_EXT_INCL_CHG_BK2.UPDATE_EXT_INCL_CHG_A', 20);
end UPDATE_EXT_INCL_CHG_A;
procedure UPDATE_EXT_INCL_CHG_B
(P_EXT_INCL_CHG_ID in NUMBER
,P_CHG_EVT_CD in VARCHAR2
,P_CHG_EVT_SOURCE in VARCHAR2
,P_EXT_RCD_IN_FILE_ID in NUMBER
,P_EXT_DATA_ELMT_IN_RCD_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_EXT_INCL_CHG_BK2.UPDATE_EXT_INCL_CHG_B', 10);
hr_utility.set_location(' Leaving: BEN_EXT_INCL_CHG_BK2.UPDATE_EXT_INCL_CHG_B', 20);
end UPDATE_EXT_INCL_CHG_B;
end BEN_EXT_INCL_CHG_BK2;

/