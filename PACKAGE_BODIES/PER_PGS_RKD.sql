--------------------------------------------------------
--  DDL for Package Body PER_PGS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PGS_RKD" as
/* $Header: pepgsrhi.pkb 120.0 2005/05/31 14:12:49 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:32:41 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_GRADE_SPINE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PARENT_SPINE_ID_O in NUMBER
,P_GRADE_ID_O in NUMBER
,P_CEILING_STEP_ID_O in NUMBER
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_PGS_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_PGS_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_PGS_RKD;

/