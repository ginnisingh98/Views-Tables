--------------------------------------------------------
--  DDL for Package Body PQH_FYI_NOTIFY_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FYI_NOTIFY_BK2" as
/* $Header: pqfynapi.pkb 115.4 2002/12/06 18:06:21 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:22 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_FYI_NOTIFY_A
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
)is
begin
hr_utility.set_location('Entering: PQH_FYI_NOTIFY_BK2.UPDATE_FYI_NOTIFY_A', 10);
hr_utility.set_location(' Leaving: PQH_FYI_NOTIFY_BK2.UPDATE_FYI_NOTIFY_A', 20);
end UPDATE_FYI_NOTIFY_A;
procedure UPDATE_FYI_NOTIFY_B
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
)is
begin
hr_utility.set_location('Entering: PQH_FYI_NOTIFY_BK2.UPDATE_FYI_NOTIFY_B', 10);
hr_utility.set_location(' Leaving: PQH_FYI_NOTIFY_BK2.UPDATE_FYI_NOTIFY_B', 20);
end UPDATE_FYI_NOTIFY_B;
end PQH_FYI_NOTIFY_BK2;

/