--------------------------------------------------------
--  DDL for Package Body PAY_TDU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TDU_RKI" as
/* $Header: pytdurhi.pkb 120.2 2005/10/14 07:07 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:27 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_TIME_DEFINITION_ID in NUMBER
,P_USAGE_TYPE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_TDU_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PAY_TDU_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PAY_TDU_RKI;

/
