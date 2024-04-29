--------------------------------------------------------
--  DDL for Package Body PQH_TCT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TCT_RKD" as
/* $Header: pqtctrhi.pkb 120.4 2005/10/12 20:19:57 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:46 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_TRANSACTION_CATEGORY_ID in NUMBER
,P_CUSTOM_WF_PROCESS_NAME_O in VARCHAR2
,P_CUSTOM_WORKFLOW_NAME_O in VARCHAR2
,P_FORM_NAME_O in VARCHAR2
,P_FREEZE_STATUS_CD_O in VARCHAR2
,P_FUTURE_ACTION_CD_O in VARCHAR2
,P_MEMBER_CD_O in VARCHAR2
,P_NAME_O in VARCHAR2
,P_SHORT_NAME_O in VARCHAR2
,P_POST_STYLE_CD_O in VARCHAR2
,P_POST_TXN_FUNCTION_O in VARCHAR2
,P_ROUTE_VALIDATED_TXN_FLAG_O in VARCHAR2
,P_PREVENT_APPROVER_SKIP_O in VARCHAR2
,P_WORKFLOW_ENABLE_FLAG_O in VARCHAR2
,P_ENABLE_FLAG_O in VARCHAR2
,P_TIMEOUT_DAYS_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_CONSOLIDATED_TABLE_ROUTE_I_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_SETUP_TYPE_CD_O in VARCHAR2
,P_MASTER_TABLE_ROUTE_I_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_TCT_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PQH_TCT_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PQH_TCT_RKD;

/