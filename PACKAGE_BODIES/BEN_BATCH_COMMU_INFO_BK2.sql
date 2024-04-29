--------------------------------------------------------
--  DDL for Package Body BEN_BATCH_COMMU_INFO_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BATCH_COMMU_INFO_BK2" as
/* $Header: bebmiapi.pkb 115.3 2002/12/11 10:31:12 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:37:40 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_BATCH_COMMU_INFO_A
(P_BATCH_COMMU_ID in NUMBER
,P_BENEFIT_ACTION_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_PER_CM_ID in NUMBER
,P_CM_TYP_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PER_CM_PRVDD_ID in NUMBER
,P_TO_BE_SENT_DT in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_BATCH_COMMU_INFO_BK2.UPDATE_BATCH_COMMU_INFO_A', 10);
hr_utility.set_location(' Leaving: BEN_BATCH_COMMU_INFO_BK2.UPDATE_BATCH_COMMU_INFO_A', 20);
end UPDATE_BATCH_COMMU_INFO_A;
procedure UPDATE_BATCH_COMMU_INFO_B
(P_BATCH_COMMU_ID in NUMBER
,P_BENEFIT_ACTION_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_PER_CM_ID in NUMBER
,P_CM_TYP_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PER_CM_PRVDD_ID in NUMBER
,P_TO_BE_SENT_DT in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_BATCH_COMMU_INFO_BK2.UPDATE_BATCH_COMMU_INFO_B', 10);
hr_utility.set_location(' Leaving: BEN_BATCH_COMMU_INFO_BK2.UPDATE_BATCH_COMMU_INFO_B', 20);
end UPDATE_BATCH_COMMU_INFO_B;
end BEN_BATCH_COMMU_INFO_BK2;

/
