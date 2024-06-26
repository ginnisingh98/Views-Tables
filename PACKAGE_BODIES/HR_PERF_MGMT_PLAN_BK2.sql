--------------------------------------------------------
--  DDL for Package Body HR_PERF_MGMT_PLAN_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERF_MGMT_PLAN_BK2" as
/* $Header: pepmpapi.pkb 120.2.12010000.3 2010/01/27 15:20:19 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:36:17 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_PERF_MGMT_PLAN_A
(P_EFFECTIVE_DATE in DATE
,P_PLAN_ID in NUMBER
,P_PLAN_NAME in VARCHAR2
,P_ADMINISTRATOR_PERSON_ID in NUMBER
,P_PREVIOUS_PLAN_ID in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_HIERARCHY_TYPE_CODE in VARCHAR2
,P_SUPERVISOR_ID in NUMBER
,P_SUPERVISOR_ASSIGNMENT_ID in NUMBER
,P_ORGANIZATION_STRUCTURE_ID in NUMBER
,P_ORG_STRUCTURE_VERSION_ID in NUMBER
,P_TOP_ORGANIZATION_ID in NUMBER
,P_POSITION_STRUCTURE_ID in NUMBER
,P_POS_STRUCTURE_VERSION_ID in NUMBER
,P_TOP_POSITION_ID in NUMBER
,P_HIERARCHY_LEVELS in NUMBER
,P_AUTOMATIC_ENROLLMENT_FLAG in VARCHAR2
,P_ASSIGNMENT_TYPES_CODE in VARCHAR2
,P_PRIMARY_ASG_ONLY_FLAG in VARCHAR2
,P_INCLUDE_OBJ_SETTING_FLAG in VARCHAR2
,P_OBJ_SETTING_START_DATE in DATE
,P_OBJ_SETTING_DEADLINE in DATE
,P_OBJ_SET_OUTSIDE_PERIOD_FLAG in VARCHAR2
,P_METHOD_CODE in VARCHAR2
,P_NOTIFY_POPULATION_FLAG in VARCHAR2
,P_AUTOMATIC_ALLOCATION_FLAG in VARCHAR2
,P_COPY_PAST_OBJECTIVES_FLAG in VARCHAR2
,P_SHARING_ALIGNMENT_TASK_FLAG in VARCHAR2
,P_INCLUDE_APPRAISALS_FLAG in VARCHAR2
,P_CHANGE_SC_STATUS_FLAG in VARCHAR2
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
,P_ATTRIBUTE21 in VARCHAR2
,P_ATTRIBUTE22 in VARCHAR2
,P_ATTRIBUTE23 in VARCHAR2
,P_ATTRIBUTE24 in VARCHAR2
,P_ATTRIBUTE25 in VARCHAR2
,P_ATTRIBUTE26 in VARCHAR2
,P_ATTRIBUTE27 in VARCHAR2
,P_ATTRIBUTE28 in VARCHAR2
,P_ATTRIBUTE29 in VARCHAR2
,P_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_STATUS_CODE in VARCHAR2
,P_DUPLICATE_NAME_WARNING in BOOLEAN
,P_NO_LIFE_EVENTS_WARNING in BOOLEAN
,P_UPDATE_LIBRARY_OBJECTIVES in VARCHAR2
,P_AUTOMATIC_APPROVAL_FLAG in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_PERF_MGMT_PLAN_BK2.UPDATE_PERF_MGMT_PLAN_A', 10);
hr_utility.set_location(' Leaving: HR_PERF_MGMT_PLAN_BK2.UPDATE_PERF_MGMT_PLAN_A', 20);
end UPDATE_PERF_MGMT_PLAN_A;
procedure UPDATE_PERF_MGMT_PLAN_B
(P_EFFECTIVE_DATE in DATE
,P_PLAN_ID in NUMBER
,P_PLAN_NAME in VARCHAR2
,P_ADMINISTRATOR_PERSON_ID in NUMBER
,P_PREVIOUS_PLAN_ID in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_HIERARCHY_TYPE_CODE in VARCHAR2
,P_SUPERVISOR_ID in NUMBER
,P_SUPERVISOR_ASSIGNMENT_ID in NUMBER
,P_ORGANIZATION_STRUCTURE_ID in NUMBER
,P_ORG_STRUCTURE_VERSION_ID in NUMBER
,P_TOP_ORGANIZATION_ID in NUMBER
,P_POSITION_STRUCTURE_ID in NUMBER
,P_POS_STRUCTURE_VERSION_ID in NUMBER
,P_TOP_POSITION_ID in NUMBER
,P_HIERARCHY_LEVELS in NUMBER
,P_AUTOMATIC_ENROLLMENT_FLAG in VARCHAR2
,P_ASSIGNMENT_TYPES_CODE in VARCHAR2
,P_PRIMARY_ASG_ONLY_FLAG in VARCHAR2
,P_INCLUDE_OBJ_SETTING_FLAG in VARCHAR2
,P_OBJ_SETTING_START_DATE in DATE
,P_OBJ_SETTING_DEADLINE in DATE
,P_OBJ_SET_OUTSIDE_PERIOD_FLAG in VARCHAR2
,P_METHOD_CODE in VARCHAR2
,P_NOTIFY_POPULATION_FLAG in VARCHAR2
,P_AUTOMATIC_ALLOCATION_FLAG in VARCHAR2
,P_COPY_PAST_OBJECTIVES_FLAG in VARCHAR2
,P_SHARING_ALIGNMENT_TASK_FLAG in VARCHAR2
,P_INCLUDE_APPRAISALS_FLAG in VARCHAR2
,P_CHANGE_SC_STATUS_FLAG in VARCHAR2
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
,P_ATTRIBUTE21 in VARCHAR2
,P_ATTRIBUTE22 in VARCHAR2
,P_ATTRIBUTE23 in VARCHAR2
,P_ATTRIBUTE24 in VARCHAR2
,P_ATTRIBUTE25 in VARCHAR2
,P_ATTRIBUTE26 in VARCHAR2
,P_ATTRIBUTE27 in VARCHAR2
,P_ATTRIBUTE28 in VARCHAR2
,P_ATTRIBUTE29 in VARCHAR2
,P_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_UPDATE_LIBRARY_OBJECTIVES in VARCHAR2
,P_AUTOMATIC_APPROVAL_FLAG in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_PERF_MGMT_PLAN_BK2.UPDATE_PERF_MGMT_PLAN_B', 10);
hr_utility.set_location(' Leaving: HR_PERF_MGMT_PLAN_BK2.UPDATE_PERF_MGMT_PLAN_B', 20);
end UPDATE_PERF_MGMT_PLAN_B;
end HR_PERF_MGMT_PLAN_BK2;

/
