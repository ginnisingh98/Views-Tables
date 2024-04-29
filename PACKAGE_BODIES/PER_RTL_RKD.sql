--------------------------------------------------------
--  DDL for Package Body PER_RTL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RTL_RKD" as
/* $Header: pertlrhi.pkb 120.0 2005/05/31 19:57:25 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:12 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_RATING_LEVEL_ID in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_STEP_VALUE_O in NUMBER
,P_RATING_SCALE_ID_O in NUMBER
,P_NAME_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_BEHAVIOURAL_INDICATOR_O in VARCHAR2
,P_COMPETENCE_ID_O in NUMBER
,P_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ATTRIBUTE1_O in VARCHAR2
,P_ATTRIBUTE2_O in VARCHAR2
,P_ATTRIBUTE3_O in VARCHAR2
,P_ATTRIBUTE4_O in VARCHAR2
,P_ATTRIBUTE5_O in VARCHAR2
,P_ATTRIBUTE6_O in VARCHAR2
,P_ATTRIBUTE7_O in VARCHAR2
,P_ATTRIBUTE8_O in VARCHAR2
,P_ATTRIBUTE9_O in VARCHAR2
,P_ATTRIBUTE10_O in VARCHAR2
,P_ATTRIBUTE11_O in VARCHAR2
,P_ATTRIBUTE12_O in VARCHAR2
,P_ATTRIBUTE13_O in VARCHAR2
,P_ATTRIBUTE14_O in VARCHAR2
,P_ATTRIBUTE15_O in VARCHAR2
,P_ATTRIBUTE16_O in VARCHAR2
,P_ATTRIBUTE17_O in VARCHAR2
,P_ATTRIBUTE18_O in VARCHAR2
,P_ATTRIBUTE19_O in VARCHAR2
,P_ATTRIBUTE20_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_RTL_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_RTL_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_RTL_RKD;

/