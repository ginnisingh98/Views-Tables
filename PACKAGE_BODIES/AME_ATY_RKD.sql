--------------------------------------------------------
--  DDL for Package Body AME_ATY_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ATY_RKD" as
/* $Header: amatyrhi.pkb 120.4 2005/11/22 03:14 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:30:32 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_ACTION_TYPE_ID in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_NAME_O in VARCHAR2
,P_PROCEDURE_NAME_O in VARCHAR2
,P_START_DATE_O in DATE
,P_END_DATE_O in DATE
,P_DESCRIPTION_O in VARCHAR2
,P_SECURITY_GROUP_ID_O in NUMBER
,P_DYNAMIC_DESCRIPTION_O in VARCHAR2
,P_DESCRIPTION_QUERY_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ame_aty_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ame_aty_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ame_aty_RKD;

/