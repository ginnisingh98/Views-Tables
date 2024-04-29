--------------------------------------------------------
--  DDL for Package Body PER_PMA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PMA_RKI" as
/* $Header: pepmarhi.pkb 120.4.12010000.3 2009/10/23 13:48:57 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:36:16 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_APPRAISAL_PERIOD_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_PLAN_ID in NUMBER
,P_APPRAISAL_TEMPLATE_ID in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_TASK_START_DATE in DATE
,P_TASK_END_DATE in DATE
,P_INITIATOR_CODE in VARCHAR2
,P_APPRAISAL_SYSTEM_TYPE in VARCHAR2
,P_APPRAISAL_TYPE in VARCHAR2
,P_APPRAISAL_ASSMT_STATUS in VARCHAR2
,P_AUTO_CONC_PROCESS in VARCHAR2
,P_DAYS_BEFORE_TASK_ST_DT in NUMBER
,P_PARTICIPATION_TYPE in VARCHAR2
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
)is
begin
hr_utility.set_location('Entering: PER_PMA_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_PMA_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_PMA_RKI;

/