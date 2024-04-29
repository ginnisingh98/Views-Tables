--------------------------------------------------------
--  DDL for Package Body AME_RLU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_RLU_RKD" as
/* $Header: amrlurhi.pkb 120.5 2005/11/22 03:19 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:30:38 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_ITEM_ID in NUMBER
,P_RULE_ID in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_USAGE_TYPE_O in VARCHAR2
,P_START_DATE_O in DATE
,P_END_DATE_O in DATE
,P_SECURITY_GROUP_ID_O in NUMBER
,P_PRIORITY_O in NUMBER
,P_APPROVER_CATEGORY_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ame_rlu_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ame_rlu_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ame_rlu_RKD;

/