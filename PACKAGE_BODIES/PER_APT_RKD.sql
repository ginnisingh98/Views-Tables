--------------------------------------------------------
--  DDL for Package Body PER_APT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_APT_RKD" as
/* $Header: peaptrhi.pkb 120.4.12010000.7 2010/02/09 15:06:58 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:36:14 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_APPRAISAL_TEMPLATE_ID in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_NAME_O in VARCHAR2
,P_DESCRIPTION_O in VARCHAR2
,P_INSTRUCTIONS_O in VARCHAR2
,P_DATE_FROM_O in DATE
,P_DATE_TO_O in DATE
,P_ASSESSMENT_TYPE_ID_O in NUMBER
,P_RATING_SCALE_ID_O in NUMBER
,P_QUESTIONNAIRE_TEMPLATE_ID_O in NUMBER
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
,P_OBJECTIVE_ASMNT_TYPE_ID_O in NUMBER
,P_MA_QUEST_TEMPLATE_ID_O in NUMBER
,P_LINK_APPR_TO_LEARNING_PATH_O in VARCHAR2
,P_FINAL_SCORE_FORMULA_ID_O in NUMBER
,P_UPDATE_PERSONAL_COMP_PROFI_O in VARCHAR2
,P_COMP_PROFILE_SOURCE_TYPE_O in VARCHAR2
,P_SHOW_COMPETENCY_RATINGS_O in VARCHAR2
,P_SHOW_OBJECTIVE_RATINGS_O in VARCHAR2
,P_SHOW_OVERALL_RATINGS_O in VARCHAR2
,P_SHOW_OVERALL_COMMENTS_O in VARCHAR2
,P_PROVIDE_OVERALL_FEEDBACK_O in VARCHAR2
,P_SHOW_PARTICIPANT_DETAILS_O in VARCHAR2
,P_ALLOW_ADD_PARTICIPANT_O in VARCHAR2
,P_SHOW_ADDITIONAL_DETAILS_O in VARCHAR2
,P_SHOW_PARTICIPANT_NAMES_O in VARCHAR2
,P_SHOW_PARTICIPANT_RATINGS_O in VARCHAR2
,P_AVAILABLE_FLAG_O in VARCHAR2
,P_SHOW_QUESTIONNAIRE_INFO_O in VARCHAR2
,P_SHOW_PARTICIPANT_COMMENTS_O in VARCHAR2
,P_SHOW_TERM_EMPLOYEE_O in VARCHAR2
,P_SHOW_TERM_CONTIGENT_O in VARCHAR2
,P_DISP_TERM_EMP_PERIOD_FROM_O in NUMBER
,P_SHOW_FUTURE_TERM_EMPLOYEE_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_APT_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_APT_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_APT_RKD;

/