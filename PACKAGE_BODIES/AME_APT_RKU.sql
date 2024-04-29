--------------------------------------------------------
--  DDL for Package Body AME_APT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_APT_RKU" as
/* $Header: amaptrhi.pkb 120.1 2006/04/21 08:44 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:30:30 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_APPROVER_TYPE_ID in NUMBER
,P_ORIG_SYSTEM in VARCHAR2
,P_QUERY_VARIABLE_1_LABEL in VARCHAR2
,P_QUERY_VARIABLE_2_LABEL in VARCHAR2
,P_QUERY_VARIABLE_3_LABEL in VARCHAR2
,P_QUERY_VARIABLE_4_LABEL in VARCHAR2
,P_QUERY_VARIABLE_5_LABEL in VARCHAR2
,P_VARIABLE_1_LOV_QUERY in VARCHAR2
,P_VARIABLE_2_LOV_QUERY in VARCHAR2
,P_VARIABLE_3_LOV_QUERY in VARCHAR2
,P_VARIABLE_4_LOV_QUERY in VARCHAR2
,P_VARIABLE_5_LOV_QUERY in VARCHAR2
,P_QUERY_PROCEDURE in VARCHAR2
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_START_DATE_O in DATE
,P_END_DATE_O in DATE
,P_ORIG_SYSTEM_O in VARCHAR2
,P_QUERY_VARIABLE_1_LABEL_O in VARCHAR2
,P_QUERY_VARIABLE_2_LABEL_O in VARCHAR2
,P_QUERY_VARIABLE_3_LABEL_O in VARCHAR2
,P_QUERY_VARIABLE_4_LABEL_O in VARCHAR2
,P_QUERY_VARIABLE_5_LABEL_O in VARCHAR2
,P_VARIABLE_1_LOV_QUERY_O in VARCHAR2
,P_VARIABLE_2_LOV_QUERY_O in VARCHAR2
,P_VARIABLE_3_LOV_QUERY_O in VARCHAR2
,P_VARIABLE_4_LOV_QUERY_O in VARCHAR2
,P_VARIABLE_5_LOV_QUERY_O in VARCHAR2
,P_QUERY_PROCEDURE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ame_apt_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ame_apt_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ame_apt_RKU;

/