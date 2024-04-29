--------------------------------------------------------
--  DDL for Package Body PAY_PYR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYR_RKD" as
/* $Header: pypyrrhi.pkb 115.3 2003/09/15 04:18:59 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:24 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_RATE_ID in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PARENT_SPINE_ID_O in NUMBER
,P_NAME_O in VARCHAR2
,P_RATE_TYPE_O in VARCHAR2
,P_RATE_UOM_O in VARCHAR2
,P_COMMENTS_O in VARCHAR2
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
,P_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ATTRIBUTE1_O in VARCHAR2
,P_ATTRIBUTE2_O in VARCHAR2
,P_ATTRIBUTE3_O in VARCHAR2
,P_ATTRIBUTE4_O in VARCHAR2
,P_ATTRIBUTE5_O in VARCHAR2
,P_ATTRIBUTE6_O in VARCHAR2
,P_ATTRIBUTE7_O in VARCHAR2
,P_ATTRIBUTE8_O in VARCHAR2
,P_ATTRIBUTE9_O in VARCHAR2
,P_ATTRIBUTE10_O in VARCHAR2
,P_ATTRIBUTE11_O in VARCHAR2
,P_ATTRIBUTE12_O in VARCHAR2
,P_ATTRIBUTE13_O in VARCHAR2
,P_ATTRIBUTE14_O in VARCHAR2
,P_ATTRIBUTE15_O in VARCHAR2
,P_ATTRIBUTE16_O in VARCHAR2
,P_ATTRIBUTE17_O in VARCHAR2
,P_ATTRIBUTE18_O in VARCHAR2
,P_ATTRIBUTE19_O in VARCHAR2
,P_ATTRIBUTE20_O in VARCHAR2
,P_RATE_BASIS_O in VARCHAR2
,P_ASG_RATE_TYPE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_PYR_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PAY_PYR_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PAY_PYR_RKD;

/