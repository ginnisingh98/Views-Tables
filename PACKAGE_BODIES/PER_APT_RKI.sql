--------------------------------------------------------
--  DDL for Package Body PER_APT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_APT_RKI" as
/* $Header: peaptrhi.pkb 120.4.12010000.7 2010/02/09 15:06:58 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:36:15 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_APPRAISAL_TEMPLATE_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_NAME in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_INSTRUCTIONS in VARCHAR2
,P_DATE_FROM in DATE
,P_DATE_TO in DATE
,P_ASSESSMENT_TYPE_ID in NUMBER
,P_RATING_SCALE_ID in NUMBER
,P_QUESTIONNAIRE_TEMPLATE_ID in NUMBER
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
,P_OBJECTIVE_ASMNT_TYPE_ID in NUMBER
,P_MA_QUEST_TEMPLATE_ID in NUMBER
,P_LINK_APPR_TO_LEARNING_PATH in VARCHAR2
,P_FINAL_SCORE_FORMULA_ID in NUMBER
,P_UPDATE_PERSONAL_COMP_PROFILE in VARCHAR2
,P_COMP_PROFILE_SOURCE_TYPE in VARCHAR2
,P_SHOW_COMPETENCY_RATINGS in VARCHAR2
,P_SHOW_OBJECTIVE_RATINGS in VARCHAR2
,P_SHOW_OVERALL_RATINGS in VARCHAR2
,P_SHOW_OVERALL_COMMENTS in VARCHAR2
,P_PROVIDE_OVERALL_FEEDBACK in VARCHAR2
,P_SHOW_PARTICIPANT_DETAILS in VARCHAR2
,P_ALLOW_ADD_PARTICIPANT in VARCHAR2
,P_SHOW_ADDITIONAL_DETAILS in VARCHAR2
,P_SHOW_PARTICIPANT_NAMES in VARCHAR2
,P_SHOW_PARTICIPANT_RATINGS in VARCHAR2
,P_AVAILABLE_FLAG in VARCHAR2
,P_SHOW_QUESTIONNAIRE_INFO in VARCHAR2
,P_MA_OFF_TEMPLATE_CODE in VARCHAR2
,P_APPRAISEE_OFF_TEMPLATE_CODE in VARCHAR2
,P_OTHER_PART_OFF_TEMPLATE_CODE in VARCHAR2
,P_PART_APP_OFF_TEMPLATE_CODE in VARCHAR2
,P_PART_REV_OFF_TEMPLATE_CODE in VARCHAR2
,P_SHOW_PARTICIPANT_COMMENTS in VARCHAR2
,P_SHOW_TERM_EMPLOYEE in VARCHAR2
,P_SHOW_TERM_CONTIGENT in VARCHAR2
,P_DISP_TERM_EMP_PERIOD_FROM in NUMBER
,P_SHOW_FUTURE_TERM_EMPLOYEE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_APT_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_APT_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_APT_RKI;

/
