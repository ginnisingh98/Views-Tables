--------------------------------------------------------
--  DDL for Package Body HXC_TKGQC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TKGQC_RKU" as
/* $Header: hxctkgqcrhi.pkb 120.2 2005/09/23 05:26:07 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:58:06 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_TK_GROUP_QUERY_CRITERIA_ID in NUMBER
,P_TK_GROUP_QUERY_ID in NUMBER
,P_CRITERIA_TYPE in VARCHAR2
,P_CRITERIA_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TK_GROUP_QUERY_ID_O in NUMBER
,P_CRITERIA_TYPE_O in VARCHAR2
,P_CRITERIA_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: HXC_TKGQC_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: HXC_TKGQC_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end HXC_TKGQC_RKU;

/
