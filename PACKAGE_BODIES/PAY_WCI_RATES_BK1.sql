--------------------------------------------------------
--  DDL for Package Body PAY_WCI_RATES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_WCI_RATES_BK1" as
/* $Header: pypwrapi.pkb 115.2 2002/12/05 15:26:16 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:23 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_WCI_RATE_A
(P_BUSINESS_GROUP_ID in NUMBER
,P_ACCOUNT_ID in NUMBER
,P_CODE in VARCHAR2
,P_RATE in NUMBER
,P_DESCRIPTION in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_RATE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_WCI_RATES_BK1.CREATE_WCI_RATE_A', 10);
hr_utility.set_location(' Leaving: PAY_WCI_RATES_BK1.CREATE_WCI_RATE_A', 20);
end CREATE_WCI_RATE_A;
procedure CREATE_WCI_RATE_B
(P_BUSINESS_GROUP_ID in NUMBER
,P_ACCOUNT_ID in NUMBER
,P_CODE in VARCHAR2
,P_RATE in NUMBER
,P_DESCRIPTION in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_WCI_RATES_BK1.CREATE_WCI_RATE_B', 10);
hr_utility.set_location(' Leaving: PAY_WCI_RATES_BK1.CREATE_WCI_RATE_B', 20);
end CREATE_WCI_RATE_B;
end PAY_WCI_RATES_BK1;

/