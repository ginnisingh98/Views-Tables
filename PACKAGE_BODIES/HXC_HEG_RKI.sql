--------------------------------------------------------
--  DDL for Package Body HXC_HEG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HEG_RKI" as
/* $Header: hxchegrhi.pkb 120.2 2005/09/23 10:42:21 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:57:39 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ENTITY_GROUP_ID in NUMBER
,P_NAME in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_DESCRIPTION in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HXC_HEG_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: HXC_HEG_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end HXC_HEG_RKI;

/