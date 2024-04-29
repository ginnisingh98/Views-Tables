--------------------------------------------------------
--  DDL for Package Body GHR_CDT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CDT_RKI" as
/* $Header: ghcdtrhi.pkb 115.4 2003/01/30 19:25:13 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:52:57 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_COMPL_CA_DETAIL_ID in NUMBER
,P_COMPL_CA_HEADER_ID in NUMBER
,P_AMOUNT in NUMBER
,P_ORDER_DATE in DATE
,P_DUE_DATE in DATE
,P_REQUEST_DATE in DATE
,P_COMPLETE_DATE in DATE
,P_CATEGORY in VARCHAR2
,P_PHASE in VARCHAR2
,P_ACTION_TYPE in VARCHAR2
,P_PAYMENT_TYPE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_DESCRIPTION in VARCHAR2
)is
begin
hr_utility.set_location('Entering: GHR_CDT_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: GHR_CDT_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end GHR_CDT_RKI;

/
