--------------------------------------------------------
--  DDL for Package Body IRC_INP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_INP_RKD" as
/* $Header: irinprhi.pkb 120.2 2006/02/23 15:36:24 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:06:35 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PARTY_ID_O in NUMBER
,P_PERSON_ID_O in NUMBER
,P_NOTIFICATION_PREFERENCE_ID in NUMBER
,P_MATCHING_JOBS_O in VARCHAR2
,P_MATCHING_JOB_FREQ_O in VARCHAR2
,P_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_RECEIVE_INFO_MAIL_O in VARCHAR2
,P_ALLOW_ACCESS_O in VARCHAR2
,P_ADDRESS_ID_O in NUMBER
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
,P_ATTRIBUTE21_O in VARCHAR2
,P_ATTRIBUTE22_O in VARCHAR2
,P_ATTRIBUTE23_O in VARCHAR2
,P_ATTRIBUTE24_O in VARCHAR2
,P_ATTRIBUTE25_O in VARCHAR2
,P_ATTRIBUTE26_O in VARCHAR2
,P_ATTRIBUTE27_O in VARCHAR2
,P_ATTRIBUTE28_O in VARCHAR2
,P_ATTRIBUTE29_O in VARCHAR2
,P_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_AGENCY_ID_O in NUMBER
,P_ATTEMPT_ID_O in NUMBER
)is
begin
hr_utility.set_location('Entering: IRC_INP_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: IRC_INP_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end IRC_INP_RKD;

/
