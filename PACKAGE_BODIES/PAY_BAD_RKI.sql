--------------------------------------------------------
--  DDL for Package Body PAY_BAD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BAD_RKI" as
/* $Header: pybadrhi.pkb 115.3 2003/05/28 18:43:28 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:27:45 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_ATTRIBUTE_ID in NUMBER
,P_ATTRIBUTE_NAME in VARCHAR2
,P_ALTERABLE in VARCHAR2
,P_LEGISLATION_CODE in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_USER_ATTRIBUTE_NAME in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_BAD_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PAY_BAD_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PAY_BAD_RKI;

/