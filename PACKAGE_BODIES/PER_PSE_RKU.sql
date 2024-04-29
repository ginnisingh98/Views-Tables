--------------------------------------------------------
--  DDL for Package Body PER_PSE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PSE_RKU" as
/* $Header: pepserhi.pkb 120.0.12010000.2 2008/08/06 09:29:57 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:56 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_POS_STRUCTURE_ELEMENT_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_POS_STRUCTURE_VERSION_ID in NUMBER
,P_SUBORDINATE_POSITION_ID in NUMBER
,P_PARENT_POSITION_ID in NUMBER
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_POS_STRUCTURE_VERSION_ID_O in NUMBER
,P_SUBORDINATE_POSITION_ID_O in NUMBER
,P_PARENT_POSITION_ID_O in NUMBER
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_PSE_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PER_PSE_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PER_PSE_RKU;

/