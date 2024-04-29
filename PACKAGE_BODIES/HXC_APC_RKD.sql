--------------------------------------------------------
--  DDL for Package Body HXC_APC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APC_RKD" as
/* $Header: hxcapcrhi.pkb 120.2 2005/09/23 08:04:24 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:57:51 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_APPROVAL_PERIOD_COMP_ID in NUMBER
,P_TIME_RECIPIENT_ID_O in NUMBER
,P_RECURRING_PERIOD_ID_O in NUMBER
,P_APPROVAL_PERIOD_SET_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: HXC_APC_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: HXC_APC_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end HXC_APC_RKD;

/