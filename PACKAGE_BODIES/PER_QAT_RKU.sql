--------------------------------------------------------
--  DDL for Package Body PER_QAT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QAT_RKU" as
/* $Header: peqatrhi.pkb 115.3 2003/03/19 08:09:22 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:04 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_QUALIFICATION_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG in VARCHAR2
,P_TITLE in VARCHAR2
,P_GROUP_RANKING in VARCHAR2
,P_LICENSE_RESTRICTIONS in VARCHAR2
,P_AWARDING_BODY in VARCHAR2
,P_GRADE_ATTAINED in VARCHAR2
,P_REIMBURSEMENT_ARRANGEMENTS in VARCHAR2
,P_TRAINING_COMPLETED_UNITS in VARCHAR2
,P_MEMBERSHIP_CATEGORY in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
,P_TITLE_O in VARCHAR2
,P_GROUP_RANKING_O in VARCHAR2
,P_LICENSE_RESTRICTIONS_O in VARCHAR2
,P_AWARDING_BODY_O in VARCHAR2
,P_GRADE_ATTAINED_O in VARCHAR2
,P_REIMBURSEMENT_ARRANGEMENTS_O in VARCHAR2
,P_TRAINING_COMPLETED_UNITS_O in VARCHAR2
,P_MEMBERSHIP_CATEGORY_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_QAT_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PER_QAT_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PER_QAT_RKU;

/
