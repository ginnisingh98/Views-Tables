--------------------------------------------------------
--  DDL for Package Body PAY_PL_PAYE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PL_PAYE_BK3" as
/* $Header: pyppdapi.pkb 120.1 2005/12/08 19:08:54 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:12 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_PL_PAYE_DETAILS_A
(P_EFFECTIVE_DATE in DATE
,P_PAYE_DETAILS_ID in NUMBER
,P_DATETRACK_DELETE_MODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PAY_PL_PAYE_BK3.DELETE_PL_PAYE_DETAILS_A', 10);
hr_utility.set_location(' Leaving: PAY_PL_PAYE_BK3.DELETE_PL_PAYE_DETAILS_A', 20);
end DELETE_PL_PAYE_DETAILS_A;
procedure DELETE_PL_PAYE_DETAILS_B
(P_EFFECTIVE_DATE in DATE
,P_PAYE_DETAILS_ID in NUMBER
,P_DATETRACK_DELETE_MODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_PL_PAYE_BK3.DELETE_PL_PAYE_DETAILS_B', 10);
hr_utility.set_location(' Leaving: PAY_PL_PAYE_BK3.DELETE_PL_PAYE_DETAILS_B', 20);
end DELETE_PL_PAYE_DETAILS_B;
end PAY_PL_PAYE_BK3;

/
