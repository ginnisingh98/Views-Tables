--------------------------------------------------------
--  DDL for Package Body AME_ITC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ITC_RKU" as
/* $Header: amitcrhi.pkb 120.2 2005/11/22 03:17 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:30:37 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_ITEM_CLASS_ID in NUMBER
,P_NAME in VARCHAR2
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_NAME_O in VARCHAR2
,P_START_DATE_O in DATE
,P_END_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: AME_ITC_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: AME_ITC_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end AME_ITC_RKU;

/