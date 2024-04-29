--------------------------------------------------------
--  DDL for Package Body HR_GRADE_SCALE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GRADE_SCALE_BK2" as
/* $Header: pepgsapi.pkb 120.1.12000000.1 2007/01/22 01:19:48 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/10/10 13:35:33 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_GRADE_SCALE_A
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_GRADE_SPINE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PARENT_SPINE_ID in NUMBER
,P_GRADE_ID in NUMBER
,P_CEILING_STEP_ID in NUMBER
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: HR_GRADE_SCALE_BK2.UPDATE_GRADE_SCALE_A', 10);
hr_utility.set_location(' Leaving: HR_GRADE_SCALE_BK2.UPDATE_GRADE_SCALE_A', 20);
end UPDATE_GRADE_SCALE_A;
procedure UPDATE_GRADE_SCALE_B
(P_EFFECTIVE_DATE in DATE
,P_GRADE_SPINE_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PARENT_SPINE_ID in NUMBER
,P_GRADE_ID in NUMBER
,P_CEILING_STEP_ID in NUMBER
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_GRADE_SCALE_BK2.UPDATE_GRADE_SCALE_B', 10);
hr_utility.set_location(' Leaving: HR_GRADE_SCALE_BK2.UPDATE_GRADE_SCALE_B', 20);
end UPDATE_GRADE_SCALE_B;
end HR_GRADE_SCALE_BK2;

/
