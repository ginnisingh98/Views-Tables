--------------------------------------------------------
--  DDL for Package Body BEN_AUD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_AUD_RKD" as
/* $Header: beaudrhi.pkb 120.0 2005/05/28 00:31 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:37:30 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_CWB_AUDIT_ID in NUMBER
,P_GROUP_PER_IN_LER_ID_O in NUMBER
,P_GROUP_PL_ID_O in NUMBER
,P_LF_EVT_OCRD_DT_O in DATE
,P_PL_ID_O in NUMBER
,P_GROUP_OIPL_ID_O in NUMBER
,P_AUDIT_TYPE_CD_O in VARCHAR2
,P_OLD_VAL_VARCHAR_O in VARCHAR2
,P_NEW_VAL_VARCHAR_O in VARCHAR2
,P_OLD_VAL_NUMBER_O in NUMBER
,P_NEW_VAL_NUMBER_O in NUMBER
,P_OLD_VAL_DATE_O in DATE
,P_NEW_VAL_DATE_O in DATE
,P_DATE_STAMP_O in DATE
,P_CHANGE_MADE_BY_PERSON_ID_O in NUMBER
,P_SUPPORTING_INFORMATION_O in VARCHAR2
,P_REQUEST_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_AUD_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: BEN_AUD_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end BEN_AUD_RKD;

/
