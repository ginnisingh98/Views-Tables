--------------------------------------------------------
--  DDL for Package Body PAY_RUN_TYPE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RUN_TYPE_BK3" as
/* $Header: pyprtapi.pkb 115.6 2003/02/01 13:41:18 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:15 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_RUN_TYPE_A
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_DELETE_MODE in VARCHAR2
,P_RUN_TYPE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PAY_RUN_TYPE_BK3.DELETE_RUN_TYPE_A', 10);
hr_utility.set_location(' Leaving: PAY_RUN_TYPE_BK3.DELETE_RUN_TYPE_A', 20);
end DELETE_RUN_TYPE_A;
procedure DELETE_RUN_TYPE_B
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_DELETE_MODE in VARCHAR2
,P_RUN_TYPE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_RUN_TYPE_BK3.DELETE_RUN_TYPE_B', 10);
hr_utility.set_location(' Leaving: PAY_RUN_TYPE_BK3.DELETE_RUN_TYPE_B', 20);
end DELETE_RUN_TYPE_B;
end PAY_RUN_TYPE_BK3;

/