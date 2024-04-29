--------------------------------------------------------
--  DDL for Package Body HXC_HAT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HAT_RKU" as
/* $Header: hxchatrhi.pkb 120.2 2005/09/23 10:41:13 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:57:55 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_ALIAS_TYPE_ID in NUMBER
,P_ALIAS_TYPE in VARCHAR2
,P_REFERENCE_OBJECT in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ALIAS_TYPE_O in VARCHAR2
,P_REFERENCE_OBJECT_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: HXC_HAT_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: HXC_HAT_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end HXC_HAT_RKU;

/
