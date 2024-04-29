--------------------------------------------------------
--  DDL for Package Body BEN_XRS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XRS_RKI" as
/* $Header: bexrsrhi.pkb 120.1 2005/06/08 14:21:35 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:41:18 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EXT_RSLT_ID in NUMBER
,P_RUN_STRT_DT in DATE
,P_RUN_END_DT in DATE
,P_EXT_STAT_CD in VARCHAR2
,P_TOT_REC_NUM in NUMBER
,P_TOT_PER_NUM in NUMBER
,P_TOT_ERR_NUM in NUMBER
,P_EFF_DT in DATE
,P_EXT_STRT_DT in DATE
,P_EXT_END_DT in DATE
,P_OUTPUT_NAME in VARCHAR2
,P_DRCTRY_NAME in VARCHAR2
,P_EXT_DFN_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_REQUEST_ID in NUMBER
,P_OUTPUT_TYPE in VARCHAR2
,P_XDO_TEMPLATE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_xrs_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_xrs_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_xrs_RKI;

/