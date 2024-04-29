--------------------------------------------------------
--  DDL for Package Body PER_PRT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PRT_RKI" as
/* $Header: peprtrhi.pkb 120.2 2006/05/03 18:37:44 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:32:57 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_PERFORMANCE_RATING_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_OBJECTIVE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_APPRAISAL_ID in NUMBER
,P_PERFORMANCE_LEVEL_ID in NUMBER
,P_COMMENTS in VARCHAR2
,P_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ATTRIBUTE1 in VARCHAR2
,P_ATTRIBUTE2 in VARCHAR2
,P_ATTRIBUTE3 in VARCHAR2
,P_ATTRIBUTE4 in VARCHAR2
,P_ATTRIBUTE5 in VARCHAR2
,P_ATTRIBUTE6 in VARCHAR2
,P_ATTRIBUTE7 in VARCHAR2
,P_ATTRIBUTE8 in VARCHAR2
,P_ATTRIBUTE9 in VARCHAR2
,P_ATTRIBUTE10 in VARCHAR2
,P_ATTRIBUTE11 in VARCHAR2
,P_ATTRIBUTE12 in VARCHAR2
,P_ATTRIBUTE13 in VARCHAR2
,P_ATTRIBUTE14 in VARCHAR2
,P_ATTRIBUTE15 in VARCHAR2
,P_ATTRIBUTE16 in VARCHAR2
,P_ATTRIBUTE17 in VARCHAR2
,P_ATTRIBUTE18 in VARCHAR2
,P_ATTRIBUTE19 in VARCHAR2
,P_ATTRIBUTE20 in VARCHAR2
,P_APPR_LINE_SCORE in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_PRT_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_PRT_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_PRT_RKI;

/
