--------------------------------------------------------
--  DDL for Package Body PER_PDS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PDS_RKD" as
/* $Header: pepdsrhi.pkb 120.7 2006/05/18 16:47:13 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:51:29 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PERIOD_OF_SERVICE_ID in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PERSON_ID_O in NUMBER
,P_TERMINAT_ACCEPTED_PERSON_O in NUMBER
,P_DATE_START_O in DATE
,P_ACCEPTED_TERMINATION_DATE_O in DATE
,P_ACTUAL_TERMINATION_DATE_O in DATE
,P_COMMENTS_O in VARCHAR2
,P_ADJUSTED_SVC_DATE_O in DATE
,P_FINAL_PROCESS_DATE_O in DATE
,P_LAST_STANDARD_PROCESS_DATE_O in DATE
,P_LEAVING_REASON_O in VARCHAR2
,P_NOTIFIED_TERMINATION_DATE_O in DATE
,P_PROJECTED_TERMINATION_DATE_O in DATE
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
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_PRIOR_EMPLOYMENT_SSP_WEEKS_O in NUMBER
,P_PRIOR_EMPLOYMT_SSP_PAID_TO_O in DATE
,P_PDS_INFORMATION_CATEGORY_O in VARCHAR2
,P_PDS_INFORMATION1_O in VARCHAR2
,P_PDS_INFORMATION2_O in VARCHAR2
,P_PDS_INFORMATION3_O in VARCHAR2
,P_PDS_INFORMATION4_O in VARCHAR2
,P_PDS_INFORMATION5_O in VARCHAR2
,P_PDS_INFORMATION6_O in VARCHAR2
,P_PDS_INFORMATION7_O in VARCHAR2
,P_PDS_INFORMATION8_O in VARCHAR2
,P_PDS_INFORMATION9_O in VARCHAR2
,P_PDS_INFORMATION10_O in VARCHAR2
,P_PDS_INFORMATION11_O in VARCHAR2
,P_PDS_INFORMATION12_O in VARCHAR2
,P_PDS_INFORMATION13_O in VARCHAR2
,P_PDS_INFORMATION14_O in VARCHAR2
,P_PDS_INFORMATION15_O in VARCHAR2
,P_PDS_INFORMATION16_O in VARCHAR2
,P_PDS_INFORMATION17_O in VARCHAR2
,P_PDS_INFORMATION18_O in VARCHAR2
,P_PDS_INFORMATION19_O in VARCHAR2
,P_PDS_INFORMATION20_O in VARCHAR2
,P_PDS_INFORMATION21_O in VARCHAR2
,P_PDS_INFORMATION22_O in VARCHAR2
,P_PDS_INFORMATION23_O in VARCHAR2
,P_PDS_INFORMATION24_O in VARCHAR2
,P_PDS_INFORMATION25_O in VARCHAR2
,P_PDS_INFORMATION26_O in VARCHAR2
,P_PDS_INFORMATION27_O in VARCHAR2
,P_PDS_INFORMATION28_O in VARCHAR2
,P_PDS_INFORMATION29_O in VARCHAR2
,P_PDS_INFORMATION30_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_PDS_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_PDS_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_PDS_RKD;

/