--------------------------------------------------------
--  DDL for Package Body HXC_HRP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HRP_RKD" as
/* $Header: hxchrprhi.pkb 120.2 2005/09/23 10:43:21 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:48:11 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_RECURRING_PERIOD_ID in NUMBER
,P_NAME_O in VARCHAR2
,P_START_DATE_O in DATE
,P_END_DATE_O in DATE
,P_PERIOD_TYPE_O in VARCHAR2
,P_DURATION_IN_DAYS_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: HXC_HRP_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: HXC_HRP_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end HXC_HRP_RKD;

/
