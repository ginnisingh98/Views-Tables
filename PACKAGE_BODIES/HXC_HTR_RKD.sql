--------------------------------------------------------
--  DDL for Package Body HXC_HTR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HTR_RKD" as
/* $Header: hxchtrrhi.pkb 120.2 2005/09/23 07:45:11 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:57:39 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_TIME_RECIPIENT_ID in NUMBER
,P_NAME_O in VARCHAR2
,P_APPLICATION_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: HXC_HTR_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: HXC_HTR_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end HXC_HTR_RKD;

/