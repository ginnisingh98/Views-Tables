--------------------------------------------------------
--  DDL for Package Body PER_SEU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SEU_RKD" as
/* $Header: peseurhi.pkb 120.4 2005/11/09 13:59:48 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:14 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_SECURITY_USER_ID in NUMBER
,P_USER_ID_O in NUMBER
,P_SECURITY_PROFILE_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_DEL_STATIC_LISTS_WARNING in BOOLEAN
)is
begin
hr_utility.set_location('Entering: PER_SEU_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_SEU_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_SEU_RKD;

/