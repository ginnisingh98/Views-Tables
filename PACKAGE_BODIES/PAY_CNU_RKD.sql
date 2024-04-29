--------------------------------------------------------
--  DDL for Package Body PAY_CNU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CNU_RKD" as
/* $Header: pycnurhi.pkb 120.0 2005/05/29 04:04:56 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:27:49 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_CONTRIBUTION_USAGE_ID in NUMBER
,P_DATE_FROM_O in DATE
,P_DATE_TO_O in DATE
,P_GROUP_CODE_O in VARCHAR2
,P_PROCESS_TYPE_O in VARCHAR2
,P_ELEMENT_NAME_O in VARCHAR2
,P_RATE_TYPE_O in VARCHAR2
,P_CONTRIBUTION_CODE_O in VARCHAR2
,P_RETRO_CONTRIBUTION_CODE_O in VARCHAR2
,P_CONTRIBUTION_TYPE_O in VARCHAR2
,P_CONTRIBUTION_USAGE_TYPE_O in VARCHAR2
,P_RATE_CATEGORY_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_CODE_RATE_ID_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_CNU_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PAY_CNU_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PAY_CNU_RKD;

/