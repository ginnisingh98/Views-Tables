--------------------------------------------------------
--  DDL for Package Body HXC_HEG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HEG_RKD" as
/* $Header: hxchegrhi.pkb 120.2 2005/09/23 10:42:21 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:57:39 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ENTITY_GROUP_ID in NUMBER
,P_NAME_O in VARCHAR2
,P_ENTITY_TYPE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_DESCRIPTION_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HXC_HEG_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: HXC_HEG_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end HXC_HEG_RKD;

/
