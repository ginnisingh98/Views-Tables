--------------------------------------------------------
--  DDL for Package Body BEN_PGI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PGI_RKI" as
/* $Header: bepgirhi.pkb 115.0 2003/09/23 10:19:40 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:24 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_PGM_EXTRA_INFO_ID in NUMBER
,P_INFORMATION_TYPE in VARCHAR2
,P_PGM_ID in NUMBER
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_PGI_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PGI_ATTRIBUTE1 in VARCHAR2
,P_PGI_ATTRIBUTE2 in VARCHAR2
,P_PGI_ATTRIBUTE3 in VARCHAR2
,P_PGI_ATTRIBUTE4 in VARCHAR2
,P_PGI_ATTRIBUTE5 in VARCHAR2
,P_PGI_ATTRIBUTE6 in VARCHAR2
,P_PGI_ATTRIBUTE7 in VARCHAR2
,P_PGI_ATTRIBUTE8 in VARCHAR2
,P_PGI_ATTRIBUTE9 in VARCHAR2
,P_PGI_ATTRIBUTE10 in VARCHAR2
,P_PGI_ATTRIBUTE11 in VARCHAR2
,P_PGI_ATTRIBUTE12 in VARCHAR2
,P_PGI_ATTRIBUTE13 in VARCHAR2
,P_PGI_ATTRIBUTE14 in VARCHAR2
,P_PGI_ATTRIBUTE15 in VARCHAR2
,P_PGI_ATTRIBUTE16 in VARCHAR2
,P_PGI_ATTRIBUTE17 in VARCHAR2
,P_PGI_ATTRIBUTE18 in VARCHAR2
,P_PGI_ATTRIBUTE19 in VARCHAR2
,P_PGI_ATTRIBUTE20 in VARCHAR2
,P_PGI_INFORMATION_CATEGORY in VARCHAR2
,P_PGI_INFORMATION1 in VARCHAR2
,P_PGI_INFORMATION2 in VARCHAR2
,P_PGI_INFORMATION3 in VARCHAR2
,P_PGI_INFORMATION4 in VARCHAR2
,P_PGI_INFORMATION5 in VARCHAR2
,P_PGI_INFORMATION6 in VARCHAR2
,P_PGI_INFORMATION7 in VARCHAR2
,P_PGI_INFORMATION8 in VARCHAR2
,P_PGI_INFORMATION9 in VARCHAR2
,P_PGI_INFORMATION10 in VARCHAR2
,P_PGI_INFORMATION11 in VARCHAR2
,P_PGI_INFORMATION12 in VARCHAR2
,P_PGI_INFORMATION13 in VARCHAR2
,P_PGI_INFORMATION14 in VARCHAR2
,P_PGI_INFORMATION15 in VARCHAR2
,P_PGI_INFORMATION16 in VARCHAR2
,P_PGI_INFORMATION17 in VARCHAR2
,P_PGI_INFORMATION18 in VARCHAR2
,P_PGI_INFORMATION19 in VARCHAR2
,P_PGI_INFORMATION20 in VARCHAR2
,P_PGI_INFORMATION21 in VARCHAR2
,P_PGI_INFORMATION22 in VARCHAR2
,P_PGI_INFORMATION23 in VARCHAR2
,P_PGI_INFORMATION24 in VARCHAR2
,P_PGI_INFORMATION25 in VARCHAR2
,P_PGI_INFORMATION26 in VARCHAR2
,P_PGI_INFORMATION27 in VARCHAR2
,P_PGI_INFORMATION28 in VARCHAR2
,P_PGI_INFORMATION29 in VARCHAR2
,P_PGI_INFORMATION30 in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PGI_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: BEN_PGI_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end BEN_PGI_RKI;

/