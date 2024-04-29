--------------------------------------------------------
--  DDL for Package Body AME_APG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_APG_RKD" as
/* $Header: amapgrhi.pkb 120.6 2006/10/05 16:02:47 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:30:30 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_APPROVAL_GROUP_ID in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_NAME_O in VARCHAR2
,P_START_DATE_O in DATE
,P_END_DATE_O in DATE
,P_DESCRIPTION_O in VARCHAR2
,P_QUERY_STRING_O in VARCHAR2
,P_IS_STATIC_O in VARCHAR2
,P_SECURITY_GROUP_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: AME_APG_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: AME_APG_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end AME_APG_RKD;

/