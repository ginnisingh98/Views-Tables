--------------------------------------------------------
--  DDL for Package Body BEN_XRE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XRE_RKI" as
/* $Header: bexrerhi.pkb 115.8 2002/12/16 17:41:12 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:41:13 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EXT_RSLT_ERR_ID in NUMBER
,P_ERR_NUM in NUMBER
,P_ERR_TXT in VARCHAR2
,P_TYP_CD in VARCHAR2
,P_PERSON_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_EFFECTIVE_DATE in DATE
,P_EXT_RSLT_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_xre_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_xre_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_xre_RKI;

/
