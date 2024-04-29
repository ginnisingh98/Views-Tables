--------------------------------------------------------
--  DDL for Package Body BEN_ELIGY_CRITERIA_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIGY_CRITERIA_BK1" as
/* $Header: beeglapi.pkb 120.1 2005/07/29 09:06 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:53 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_ELIGY_CRITERIA_A
(P_ELIGY_CRITERIA_ID in NUMBER
,P_NAME in VARCHAR2
,P_SHORT_CODE in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_CRITERIA_TYPE in VARCHAR2
,P_CRIT_COL1_VAL_TYPE_CD in VARCHAR2
,P_CRIT_COL1_DATATYPE in VARCHAR2
,P_COL1_LOOKUP_TYPE in VARCHAR2
,P_COL1_VALUE_SET_ID in NUMBER
,P_ACCESS_TABLE_NAME1 in VARCHAR2
,P_ACCESS_COLUMN_NAME1 in VARCHAR2
,P_TIME_ENTRY_ACCESS_TAB_NAM1 in VARCHAR2
,P_TIME_ENTRY_ACCESS_COL_NAM1 in VARCHAR2
,P_CRIT_COL2_VAL_TYPE_CD in VARCHAR2
,P_CRIT_COL2_DATATYPE in VARCHAR2
,P_COL2_LOOKUP_TYPE in VARCHAR2
,P_COL2_VALUE_SET_ID in NUMBER
,P_ACCESS_TABLE_NAME2 in VARCHAR2
,P_ACCESS_COLUMN_NAME2 in VARCHAR2
,P_TIME_ENTRY_ACCESS_TAB_NAM2 in VARCHAR2
,P_TIME_ENTRY_ACCESS_COL_NAM2 in VARCHAR2
,P_ACCESS_CALC_RULE in NUMBER
,P_ALLOW_RANGE_VALIDATION_FLG in VARCHAR2
,P_USER_DEFINED_FLAG in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_EGL_ATTRIBUTE_CATEGORY in VARCHAR2
,P_EGL_ATTRIBUTE1 in VARCHAR2
,P_EGL_ATTRIBUTE2 in VARCHAR2
,P_EGL_ATTRIBUTE3 in VARCHAR2
,P_EGL_ATTRIBUTE4 in VARCHAR2
,P_EGL_ATTRIBUTE5 in VARCHAR2
,P_EGL_ATTRIBUTE6 in VARCHAR2
,P_EGL_ATTRIBUTE7 in VARCHAR2
,P_EGL_ATTRIBUTE8 in VARCHAR2
,P_EGL_ATTRIBUTE9 in VARCHAR2
,P_EGL_ATTRIBUTE10 in VARCHAR2
,P_EGL_ATTRIBUTE11 in VARCHAR2
,P_EGL_ATTRIBUTE12 in VARCHAR2
,P_EGL_ATTRIBUTE13 in VARCHAR2
,P_EGL_ATTRIBUTE14 in VARCHAR2
,P_EGL_ATTRIBUTE15 in VARCHAR2
,P_EGL_ATTRIBUTE16 in VARCHAR2
,P_EGL_ATTRIBUTE17 in VARCHAR2
,P_EGL_ATTRIBUTE18 in VARCHAR2
,P_EGL_ATTRIBUTE19 in VARCHAR2
,P_EGL_ATTRIBUTE20 in VARCHAR2
,P_EGL_ATTRIBUTE21 in VARCHAR2
,P_EGL_ATTRIBUTE22 in VARCHAR2
,P_EGL_ATTRIBUTE23 in VARCHAR2
,P_EGL_ATTRIBUTE24 in VARCHAR2
,P_EGL_ATTRIBUTE25 in VARCHAR2
,P_EGL_ATTRIBUTE26 in VARCHAR2
,P_EGL_ATTRIBUTE27 in VARCHAR2
,P_EGL_ATTRIBUTE28 in VARCHAR2
,P_EGL_ATTRIBUTE29 in VARCHAR2
,P_EGL_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_ALLOW_RANGE_VALIDATION_FLAG2 in VARCHAR2
,P_ACCESS_CALC_RULE2 in NUMBER
,P_TIME_ACCESS_CALC_RULE1 in NUMBER
,P_TIME_ACCESS_CALC_RULE2 in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_ELIGY_CRITERIA_BK1.CREATE_ELIGY_CRITERIA_A', 10);
hr_utility.set_location(' Leaving: BEN_ELIGY_CRITERIA_BK1.CREATE_ELIGY_CRITERIA_A', 20);
end CREATE_ELIGY_CRITERIA_A;
procedure CREATE_ELIGY_CRITERIA_B
(P_NAME in VARCHAR2
,P_SHORT_CODE in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_CRITERIA_TYPE in VARCHAR2
,P_CRIT_COL1_VAL_TYPE_CD in VARCHAR2
,P_CRIT_COL1_DATATYPE in VARCHAR2
,P_COL1_LOOKUP_TYPE in VARCHAR2
,P_COL1_VALUE_SET_ID in NUMBER
,P_ACCESS_TABLE_NAME1 in VARCHAR2
,P_ACCESS_COLUMN_NAME1 in VARCHAR2
,P_TIME_ENTRY_ACCESS_TAB_NAM1 in VARCHAR2
,P_TIME_ENTRY_ACCESS_COL_NAM1 in VARCHAR2
,P_CRIT_COL2_VAL_TYPE_CD in VARCHAR2
,P_CRIT_COL2_DATATYPE in VARCHAR2
,P_COL2_LOOKUP_TYPE in VARCHAR2
,P_COL2_VALUE_SET_ID in NUMBER
,P_ACCESS_TABLE_NAME2 in VARCHAR2
,P_ACCESS_COLUMN_NAME2 in VARCHAR2
,P_TIME_ENTRY_ACCESS_TAB_NAM2 in VARCHAR2
,P_TIME_ENTRY_ACCESS_COL_NAM2 in VARCHAR2
,P_ACCESS_CALC_RULE in NUMBER
,P_ALLOW_RANGE_VALIDATION_FLG in VARCHAR2
,P_USER_DEFINED_FLAG in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_EGL_ATTRIBUTE_CATEGORY in VARCHAR2
,P_EGL_ATTRIBUTE1 in VARCHAR2
,P_EGL_ATTRIBUTE2 in VARCHAR2
,P_EGL_ATTRIBUTE3 in VARCHAR2
,P_EGL_ATTRIBUTE4 in VARCHAR2
,P_EGL_ATTRIBUTE5 in VARCHAR2
,P_EGL_ATTRIBUTE6 in VARCHAR2
,P_EGL_ATTRIBUTE7 in VARCHAR2
,P_EGL_ATTRIBUTE8 in VARCHAR2
,P_EGL_ATTRIBUTE9 in VARCHAR2
,P_EGL_ATTRIBUTE10 in VARCHAR2
,P_EGL_ATTRIBUTE11 in VARCHAR2
,P_EGL_ATTRIBUTE12 in VARCHAR2
,P_EGL_ATTRIBUTE13 in VARCHAR2
,P_EGL_ATTRIBUTE14 in VARCHAR2
,P_EGL_ATTRIBUTE15 in VARCHAR2
,P_EGL_ATTRIBUTE16 in VARCHAR2
,P_EGL_ATTRIBUTE17 in VARCHAR2
,P_EGL_ATTRIBUTE18 in VARCHAR2
,P_EGL_ATTRIBUTE19 in VARCHAR2
,P_EGL_ATTRIBUTE20 in VARCHAR2
,P_EGL_ATTRIBUTE21 in VARCHAR2
,P_EGL_ATTRIBUTE22 in VARCHAR2
,P_EGL_ATTRIBUTE23 in VARCHAR2
,P_EGL_ATTRIBUTE24 in VARCHAR2
,P_EGL_ATTRIBUTE25 in VARCHAR2
,P_EGL_ATTRIBUTE26 in VARCHAR2
,P_EGL_ATTRIBUTE27 in VARCHAR2
,P_EGL_ATTRIBUTE28 in VARCHAR2
,P_EGL_ATTRIBUTE29 in VARCHAR2
,P_EGL_ATTRIBUTE30 in VARCHAR2
,P_EFFECTIVE_DATE in DATE
,P_ALLOW_RANGE_VALIDATION_FLAG2 in VARCHAR2
,P_ACCESS_CALC_RULE2 in NUMBER
,P_TIME_ACCESS_CALC_RULE1 in NUMBER
,P_TIME_ACCESS_CALC_RULE2 in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_ELIGY_CRITERIA_BK1.CREATE_ELIGY_CRITERIA_B', 10);
hr_utility.set_location(' Leaving: BEN_ELIGY_CRITERIA_BK1.CREATE_ELIGY_CRITERIA_B', 20);
end CREATE_ELIGY_CRITERIA_B;
end BEN_ELIGY_CRITERIA_BK1;

/