--------------------------------------------------------
--  DDL for Package Body PAY_PBA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PBA_RKD" as
/* $Header: pypbarhi.pkb 120.1 2005/09/05 06:39:03 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:05 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_BALANCE_ATTRIBUTE_ID in NUMBER
,P_ATTRIBUTE_ID_O in NUMBER
,P_DEFINED_BALANCE_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_PBA_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PAY_PBA_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PAY_PBA_RKD;

/