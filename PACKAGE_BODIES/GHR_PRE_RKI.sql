--------------------------------------------------------
--  DDL for Package Body GHR_PRE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PRE_RKI" as
/* $Header: ghprerhi.pkb 120.0.12010000.2 2009/05/26 10:42:14 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:35:42 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_PA_REMARK_ID in NUMBER
,P_PA_REQUEST_ID in NUMBER
,P_REMARK_ID in NUMBER
,P_DESCRIPTION in VARCHAR2
,P_REMARK_CODE_INFORMATION1 in VARCHAR2
,P_REMARK_CODE_INFORMATION2 in VARCHAR2
,P_REMARK_CODE_INFORMATION3 in VARCHAR2
,P_REMARK_CODE_INFORMATION4 in VARCHAR2
,P_REMARK_CODE_INFORMATION5 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: GHR_PRE_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: GHR_PRE_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end GHR_PRE_RKI;

/