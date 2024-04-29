--------------------------------------------------------
--  DDL for Package Body PAY_USER_ROW_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_USER_ROW_BK3" as
/* $Header: pypurapi.pkb 120.5 2008/04/08 09:44:58 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:33 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_USER_ROW_A
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_UPDATE_MODE in VARCHAR2
,P_USER_ROW_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_DISABLE_RANGE_OVERLAP_CHECK in BOOLEAN
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PAY_USER_ROW_BK3.DELETE_USER_ROW_A', 10);
hr_utility.set_location(' Leaving: PAY_USER_ROW_BK3.DELETE_USER_ROW_A', 20);
end DELETE_USER_ROW_A;
procedure DELETE_USER_ROW_B
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_UPDATE_MODE in VARCHAR2
,P_USER_ROW_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_DISABLE_RANGE_OVERLAP_CHECK in BOOLEAN
)is
begin
hr_utility.set_location('Entering: PAY_USER_ROW_BK3.DELETE_USER_ROW_B', 10);
hr_utility.set_location(' Leaving: PAY_USER_ROW_BK3.DELETE_USER_ROW_B', 20);
end DELETE_USER_ROW_B;
end PAY_USER_ROW_BK3;

/