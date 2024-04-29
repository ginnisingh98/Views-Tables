--------------------------------------------------------
--  DDL for Package Body OTA_CPR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CPR_RKD" as
/* $Header: otcprrhi.pkb 120.1.12000000.2 2007/01/30 11:32:16 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/10/10 13:33:54 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ACTIVITY_VERSION_ID in NUMBER
,P_PREREQUISITE_COURSE_ID in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PREREQUISITE_TYPE_O in VARCHAR2
,P_ENFORCEMENT_MODE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: OTA_CPR_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: OTA_CPR_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end OTA_CPR_RKD;

/