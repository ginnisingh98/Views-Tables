--------------------------------------------------------
--  DDL for Package Body PQH_FYN_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FYN_RKU" as
/* $Header: pqfynrhi.pkb 115.6 2002/12/06 18:06:27 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:22 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_FYI_NOTIFIED_ID in NUMBER
,P_TRANSACTION_CATEGORY_ID in NUMBER
,P_TRANSACTION_ID in NUMBER
,P_NOTIFICATION_EVENT_CD in VARCHAR2
,P_NOTIFIED_TYPE_CD in VARCHAR2
,P_NOTIFIED_NAME in VARCHAR2
,P_NOTIFICATION_DATE in DATE
,P_STATUS in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_TRANSACTION_CATEGORY_ID_O in NUMBER
,P_TRANSACTION_ID_O in NUMBER
,P_NOTIFICATION_EVENT_CD_O in VARCHAR2
,P_NOTIFIED_TYPE_CD_O in VARCHAR2
,P_NOTIFIED_NAME_O in VARCHAR2
,P_NOTIFICATION_DATE_O in DATE
,P_STATUS_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_FYN_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQH_FYN_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQH_FYN_RKU;

/