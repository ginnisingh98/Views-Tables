--------------------------------------------------------
--  DDL for Package Body HXC_LKR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_LKR_RKI" as
/* $Header: hxclockrulesrhi.pkb 120.2 2005/09/23 07:58:43 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:58:01 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_LOCKER_TYPE_OWNER_ID in NUMBER
,P_LOCKER_TYPE_REQUESTOR_ID in NUMBER
,P_GRANT_LOCK in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HXC_LKR_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: HXC_LKR_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end HXC_LKR_RKI;

/