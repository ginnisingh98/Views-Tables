--------------------------------------------------------
--  DDL for Package Body PAY_PWR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PWR_RKI" as
/* $Header: pypwrrhi.pkb 115.2 2002/12/05 15:39:29 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:23 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_RATE_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_ACCOUNT_ID in NUMBER
,P_CODE in VARCHAR2
,P_RATE in NUMBER
,P_DESCRIPTION in VARCHAR2
,P_COMMENTS in LONG
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_PWR_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PAY_PWR_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PAY_PWR_RKI;

/
