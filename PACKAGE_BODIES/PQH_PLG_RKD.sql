--------------------------------------------------------
--  DDL for Package Body PQH_PLG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PLG_RKD" as
/* $Header: pqplgrhi.pkb 115.5 2002/12/12 23:13:49 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:25 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PROCESS_LOG_ID in NUMBER
,P_MODULE_CD_O in VARCHAR2
,P_TXN_ID_O in NUMBER
,P_MASTER_PROCESS_LOG_ID_O in NUMBER
,P_MESSAGE_TEXT_O in VARCHAR2
,P_MESSAGE_TYPE_CD_O in VARCHAR2
,P_BATCH_STATUS_O in VARCHAR2
,P_BATCH_START_DATE_O in DATE
,P_BATCH_END_DATE_O in DATE
,P_TXN_TABLE_ROUTE_ID_O in NUMBER
,P_LOG_CONTEXT_O in VARCHAR2
,P_INFORMATION_CATEGORY_O in VARCHAR2
,P_INFORMATION1_O in VARCHAR2
,P_INFORMATION2_O in VARCHAR2
,P_INFORMATION3_O in VARCHAR2
,P_INFORMATION4_O in VARCHAR2
,P_INFORMATION5_O in VARCHAR2
,P_INFORMATION6_O in VARCHAR2
,P_INFORMATION7_O in VARCHAR2
,P_INFORMATION8_O in VARCHAR2
,P_INFORMATION9_O in VARCHAR2
,P_INFORMATION10_O in VARCHAR2
,P_INFORMATION11_O in VARCHAR2
,P_INFORMATION12_O in VARCHAR2
,P_INFORMATION13_O in VARCHAR2
,P_INFORMATION14_O in VARCHAR2
,P_INFORMATION15_O in VARCHAR2
,P_INFORMATION16_O in VARCHAR2
,P_INFORMATION17_O in VARCHAR2
,P_INFORMATION18_O in VARCHAR2
,P_INFORMATION19_O in VARCHAR2
,P_INFORMATION20_O in VARCHAR2
,P_INFORMATION21_O in VARCHAR2
,P_INFORMATION22_O in VARCHAR2
,P_INFORMATION23_O in VARCHAR2
,P_INFORMATION24_O in VARCHAR2
,P_INFORMATION25_O in VARCHAR2
,P_INFORMATION26_O in VARCHAR2
,P_INFORMATION27_O in VARCHAR2
,P_INFORMATION28_O in VARCHAR2
,P_INFORMATION29_O in VARCHAR2
,P_INFORMATION30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_PLG_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PQH_PLG_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PQH_PLG_RKD;

/